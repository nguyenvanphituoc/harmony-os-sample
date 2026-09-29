---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — settle-across-screens

Re-derived on 2026-09-29 for branch `soak/retro-todo-4`, at this run's open
(`settle-across-screens-20260929T045649Z-4f29bfab`, first run on this slug). `archetype`,
`entry_point` and `stack` are unchanged from the delete-settle / toggle-once profiles (same
project); every value below was re-measured on this checkout, not carried forward.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `build_probe` | `./scripts/t0-assemble.sh` | **executed green at this open** — `BUILD SUCCESSFUL in 4 s 520 ms`, house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | **executed green at this open**: target `127.0.0.1:5555`, unsigned HAP installs, `start ability successfully`, pid alive, 14-node `uitest dumpLayout` tree (`MY LISTS`, three seeded list cards) |

## State of the tree at run open — this pitch's surface

This is a fresh pitch: no `shapeup/settle-across-screens/spec/` or
`shapeup/settle-across-screens/scopes/` exist yet — ANALYZE and MAP SCOPES have not run.

- `app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:12,27-28,67-68,71,100-105` —
  `SETTLE_WINDOW_MS = 400` is a module-level constant; `lastToggleAt` and `windowMs` are private
  fields on `ListViewModel` itself, so the window's lifetime is the view model's lifetime.
  `isSettling(now)` reads `lastToggleAt`; `onToggle` calls it and stamps `lastToggleAt` when not
  settling; `onDeleteItem` calls it but never writes it. This is the baseline the pitch targets:
  the window resets whenever a new `ListViewModel` is built.
- `app/entry/src/main/ets/features/todo/TodoModule.ets:58-83` — `TodoModule` holds one
  `ListsViewModel` for the app (`this.lists`, built once in the constructor), but
  `listViewModel(listId, clock?)` (line 78) constructs and returns a brand-new `ListViewModel` on
  every call — no caching by `listId`. `pages/Index.ets`'s route builder calls this on every visit
  to the list screen, per shaping.md's Problem Frame, so leaving and reopening a list always loses
  `lastToggleAt`.
- No `SettleWindow` type exists yet anywhere in the tree — Shape A's A1–A4 (shaping.md) are
  unbuilt: extracting the window into its own class, giving `TodoModule` one instance for the app,
  and threading it into `ListViewModel` as an optional constructor argument are all still to do.
- `app/entry/src/test/ListViewModel.test.ets` builds `ListViewModel` directly with a settable
  clock and holds one instance per test (shaping.md's Baseline) — this is the R4 non-regression
  surface the pitch must not break.

## House rules: what bites

Same `app/build-src/enforce/rule-table.ts` as retro-todo, toggle-once and delete-settle: L1 (no
hex literals), L3 (no quoted `Text(…)`/`.label(…)`/`.placeholder(…)` literals — any new state/
warning string goes through `string.json`), state management V2 only, no `@Provider`/`@Consumer`.
This pitch's No-goes rule out any new UI copy or dialog/screen change, so L1/L3 exposure is
minimal — the new surface is a plain state-holder class (`SettleWindow`), not a component.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — green at this open.
- `./scripts/t0-test.sh` — unit tier; memory from prior runs on this project: `LocalUnit.test.ets`
  calls `assertNotEqual`, not present in `@ohos/hypium` 1.0.25, so the unit tier is red at baseline
  for a reason no scope owns. This pitch's R1/R2 proof (unit tests over a controlled clock, per
  shaping.md's Rabbit Holes — a device flow cannot reliably land a tap inside 400 ms) should avoid
  that matcher.
- `./scripts/launch-probe.sh` — green at this open, device `127.0.0.1:5555` attached, so the V2
  device flow (R3, back → reopen → ✕ outside the window) and the QA hunt are both possible this
  run.
- `app/entry/src/ohosTest` fixtures need a signed HAP; `signingConfigs` is `[]`, so they stay red
  for an environment reason no scope owns (unchanged from retro-todo/toggle-once/delete-settle).
