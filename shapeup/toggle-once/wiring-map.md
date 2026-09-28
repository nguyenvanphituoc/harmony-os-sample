---
schema_version: 1
feature: toggle-once
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
---

# Wiring Map — toggle-once

`entry_point` echoes `project-profile.md`. `EntryAbility.ets` loads `pages/Index`
(`windowStage.loadContent('pages/Index', ...)`), which already hosts the `Navigation` that
routes to `ListPage` — this pitch changes no routing; it changes what runs inside a screen
already reachable from the entry point. Per KB-SOL-001, the seam below is resolved against the
`EntryAbility` → `pages/Index` chain that exists today, not a docs-planned `AppModules` host.

## Wiring

| use_case | engine | wiring_seam | entry_call_site | affordance |
|---|---|---|---|---|
| UC-01 | app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets | `ItemCard`'s `onToggle` event (tap on `list.itemCard.toggle`) calls `ListViewModel.onToggle(itemId)`, which will read `clock.now()` against a new `SettleWindow` (domain-model.md) before deciding whether to call `ToggleItem.execute` | app/entry/src/main/ets/entryability/EntryAbility.ets — `pages/Index` → `Navigation` → `ListPage` `NavDestination` (existing route, unchanged) → `ItemCard` tap handler inside `ListPage.readyBuilder`'s `Repeat` | U1 item card toggle (P2 List) — a live double-tap on a row marks only that row, a normal-paced second tap on a different row still toggles it |
| UC-01 | app/entry/src/main/ets/features/todo/domain/ToggleItem.ets | Unchanged call from `ListViewModel.onToggle`, made only when `!isSettling(clock.now())` — retro-todo's existing seam, re-declared here because this pitch's guard sits directly in front of it | app/entry/src/main/ets/entryability/EntryAbility.ets — `pages/Index` → `ListPage` → `ListViewModel.onToggle` (row above), unchanged from retro-todo's UC-05 | U1 item card toggle (P2 List) — the toggle that reaches `TodoStore` and re-sorts via `ItemOrder` |
| UC-01 | scripts/ui-flow.sh | New `doubletap` step: two `uitest uiInput click` calls on the same node with no `settle()` between them, one trailing `settle()` after the pair — added beside the existing `tap`/`type` step dispatch (`ui-flow.sh:118`) | scripts/ui-flow.sh — the step-language `case`/dispatch block that already handles `tap`/`type` (not the app's composition root; this is the device-flow harness that drives it) | Device flows TS-01-04..06 can express "double-tap a row" and "two deliberate taps on two rows" as scripted steps, making R1/R2/R3 gradable on-device |

## Deviations

- The `ToggleItem` row is unchanged plumbing (retro-todo's UC-05 seam), re-listed here per the
  "one row per use case + engine pair" rule since UC-01's steps name it directly; no new
  attachment is designed for it.
- `scripts/ui-flow.sh` is not part of the app's composition root (it drives the device from the
  outside via `uitest`), so it has no `entry_call_site` in the `EntryAbility` sense — the cell
  above names the harness's own step dispatcher, the closest analog, and this is flagged so the
  reachability oracle (which resolves `engine` against the import graph from `entry_point`) does
  not expect this row to trace back to `EntryAbility.ets`. Ownership of this file is a scope-cut
  question for `scope-architect`, not resolved here — the project-profile notes "no `doubletap`
  op" as pre-fix state, per QA-102.
- No UC in this pitch has a purely internal/background engine with no player-facing seam — all
  three rows above end at a screen affordance or a device-flow capability, so no boot/cron
  attachment case applies here.
