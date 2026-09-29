---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — delete-settle

Re-derived on 2026-09-29 for branch `soak/retro-todo-4`, at this run's open
(`delete-settle-20260929T025442Z-9a98ccde`, first run on this slug). `archetype`, `entry_point`
and `stack` are unchanged from the toggle-once profile (same project); every value below was
re-measured on this checkout, not carried forward.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `build_probe` | `./scripts/t0-assemble.sh` | **executed green at this open** — `BUILD SUCCESSFUL in 4 s 392 ms`, house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | **executed green at this open**: target `127.0.0.1:5555`, unsigned HAP installs, `start ability successfully`, pid alive, 14-node `uitest dumpLayout` tree (`MY LISTS`, three seeded list cards) |

## State of the tree at run open — this pitch's surface

This is a fresh pitch: no `shapeup/delete-settle/spec/` or `shapeup/delete-settle/scopes/` exist
yet — ANALYZE and MAP SCOPES have not run.

- `app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:12,27-28,67-68,71-81` —
  toggle-once's settle-window infrastructure is already in place: `SETTLE_WINDOW_MS = 400`,
  `lastToggleAt`, `isSettling(now)`, and `onToggle` stamping the window. This pitch reads that
  infrastructure; it does not change its length or add a second constant (per shaping.md's
  Constraints and No-goes).
- `ListViewModel.ets:100-105` — `onDeleteItem` has no `isSettling` check. It looks the item up in
  `this.store.items`, then calls `this.dialogs.openDelete(itemId, found.title)` unconditionally.
  This is the baseline bug: a ✕ tap inside the settle window opens the dialog for whatever item
  now sits at that row. R1 (guard `onDeleteItem` with `isSettling`) is unbuilt.
- `ItemCard`'s ✕ (`list.deleteItemButton`) and `ItemDeleteOpener.openDelete` are unchanged from
  toggle-once, per the shaping doc's baseline section.

## House rules: what bites

Same `app/build-src/enforce/rule-table.ts` as retro-todo and toggle-once: L1 (no hex literals),
L3 (no quoted `Text(…)`/`.label(…)`/`.placeholder(…)` literals — any new state/warning string goes
through `string.json`), state management V2 only, no `@Provider`/`@Consumer`. This pitch adds no
new UI copy (shaping.md No-goes: no dialog/screen change), so L1/L3 exposure is minimal.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — green at this open.
- `./scripts/t0-test.sh` — unit tier; memory from prior runs on this project: `LocalUnit.test.ets`
  calls `assertNotEqual`, not present in `@ohos/hypium` 1.0.25, so the unit tier is red at baseline
  for a reason no scope owns. R1's settle-window unit test (shaping.md's stated proof for R1 — a
  device flow cannot reliably land a tap inside 400 ms) should avoid that matcher.
- `./scripts/launch-probe.sh` — green at this open, device `127.0.0.1:5555` attached, so R2's
  on-device grading and the QA hunt are both possible this run.
- `app/entry/src/ohosTest` fixtures need a signed HAP; `signingConfigs` is `[]`, so they stay red
  for an environment reason no scope owns (unchanged from retro-todo/toggle-once).
