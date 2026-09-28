---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — toggle-once

Re-derived on 2026-09-28 for branch `soak/retro-todo-4`, at this run's open. `archetype`,
`entry_point`, `stack`, `build_probe` and `launch_probe` are unchanged from `shapeup/retro-todo/
project-profile.md` — same app, same HAP — but every value below was re-measured on this checkout,
not carried forward.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `build_probe` | `./scripts/t0-assemble.sh` | **executed green at this open** — `BUILD SUCCESSFUL in 3 s 874 ms` (incremental, mostly UP-TO-DATE), house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | **executed green at this open**: target `127.0.0.1:5555`, unsigned HAP installs, `start ability successfully`, pid alive, 14-node `uitest dumpLayout` tree (`MY LISTS`, three seeded list cards) |

## State of the tree at run open — this pitch's surface

The baseline is retro-todo as shipped (`main` of this branch), not the template. This pitch is a
narrow fix inside the list screen retro-todo already built, found by the QA hunt (finding QA-102).

- `app/entry/src/main/ets/features/todo/screens/list/` holds `ListPage.ets`, `ItemCard.ets`,
  `ListViewModel.ets`. `ListViewModel.onToggle(itemId)` calls `ToggleItem.execute(itemId)`
  directly today — **no settle window exists yet**; this is the pre-fix state the pitch's A1/A2
  will change.
- `scripts/ui-flow.sh`'s step language (`tap`, `type`) has **no `doubletap` op** — grep confirms
  only `tap`/`type` are handled (`scripts/ui-flow.sh:118`). A3 adds it.
- The retro-todo spec at `shapeup/retro-todo/spec/` (four scope contracts, `requirements.md`,
  `wiring-map.md`, frozen `REPORT.md`) is untouched by this pitch — R4/No-goes require it to stay
  that way. `shapeup/toggle-once/spec/` does not exist yet; ANALYZE creates it.
- No `scopes/*.md` exist yet for this pitch — MAP SCOPES creates them. Given the single Place (P2
  List, unchanged layout) and single UI affordance (U1) in the breadboard, this is a small, single-
  screen surface; expect one scope, not several.

## House rules: what bites

Same `app/build-src/enforce/rule-table.ts` as retro-todo — L1 (no hex literals), L3 (no quoted
`Text(…)`/`.label(…)`/`.placeholder(…)` literals — any new state/warning string goes through
`string.json`), state management V2 only, no `@Provider`/`@Consumer`. This pitch adds one named
constant (the settle window length) and no new UI copy is implied by the shaping doc, so L1/L3
exposure is low but not zero if a fix needs a log or debug string.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — green at this open.
- `./scripts/t0-test.sh` — unit tier; memory from the retro-todo runs: `LocalUnit.test.ets` calls
  `assertNotEqual`, not present in `@ohos/hypium` 1.0.25, so the unit tier was red at baseline for
  a reason no scope owns. A1/A4's settle-window unit test should avoid that matcher.
- `./scripts/launch-probe.sh` — green at this open, device `127.0.0.1:5555` attached, so R5's
  on-device grading and the QA hunt are both possible this run.
- `app/entry/src/ohosTest` fixtures need a signed HAP; `signingConfigs` is `[]`, so they stay red
  for an environment reason no scope owns (unchanged from retro-todo).
