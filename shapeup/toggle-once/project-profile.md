---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — toggle-once

Re-derived on 2026-09-28 for branch `soak/retro-todo-4`, at this run's open (second run on this
slug — `toggle-once-20260928T114548Z-e2675ab4`; the prior run,
`toggle-once-20260928T111133Z-3f49258a`, already shipped this pitch, frozen in this file's
`REPORT.md`). `archetype`, `entry_point` and `stack` are unchanged from the prior open; every
value below was re-measured on this checkout, not carried forward.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `build_probe` | `./scripts/t0-assemble.sh` | **executed green at this open** — `BUILD SUCCESSFUL in 3 s 257 ms`, house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | **executed green at this open**: target `127.0.0.1:5555`, unsigned HAP installs, `start ability successfully`, pid alive, 14-node `uitest dumpLayout` tree (`MY LISTS`, three seeded list cards) |

## State of the tree at run open — this pitch's surface

This pitch already shipped in the prior run on this slug: the tree is the **post-fix** state, not
the baseline this file described at that run's open.

- `app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:71-81` — `onToggle`
  already has the settle window: it reads `this.clock.now()`, short-circuits via
  `this.isSettling(now)` before calling `ToggleItem.execute`, and stamps `this.lastToggleAt = now`
  after. A1/A2 are built.
- `scripts/ui-flow.sh` already has the `doubletap` op (line 15 doc comment, dispatch at line 120,
  handling at line 127). A3 is built.
- `shapeup/toggle-once/spec/` is committed (`_index.md`, `domain-model.md`, `usecases/`,
  `integration.md`, `ux-behavior.md`, `synthesis.md`, `feedback.md`) — ANALYZE ran in the prior
  run; a fresh ANALYZE this run should find the tree on disk and not re-derive it.
- `shapeup/toggle-once/scopes/` is committed: two contracts, `v1-settle-window` (UC-01, 5 files)
  and `v2-device-flow` (UC-01, 2 files, depends on v1) — MAP SCOPES ran in the prior run.
- The prior run's frozen `REPORT.md` records PASS in one round plus a QA finding (QA-001,
  discovered-not-built): a rapid second tap aimed at a toggled row's now-vacated delete-control
  position can land on a different row's delete control after the animation-free re-sort. That
  finding is still open (no scope owns a fix for it) — this run's own QA pass may re-surface it.

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
