---
schema_version: 1
feature: delete-settle
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
---

# Wiring Map — delete-settle

## Wiring

| use_case | engine | wiring_seam | entry_call_site | affordance |
|---|---|---|---|---|
| UC-01 | app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets | already-attached ArkUI event handler: `ItemCard`'s ✕ button (`list.deleteItemButton`) calls `this.vm.onDeleteItem(r.item.id)` in `ListPage.ets:26`; this pitch adds the `isSettling` guard inside the existing `onDeleteItem` method — no new attachment | app/entry/src/main/ets/entryability/EntryAbility.ets → `pages/Index` (`main_pages.json`) → `ListPage.ets` (routed via toggle-once/retro-todo's existing navigation, unchanged by this pitch) — `ListPage.ets:26` `Button(...).onClick` on `ItemCard`'s ✕ | U1 item card ✕ (`list.deleteItemButton`) → N1 `onDeleteItem` guarded no-op inside the settle window, or → N2 `ItemDeleteOpener.openDelete` outside it (P2 List) |

## Deviations

- No new seam is introduced by this pitch. `ListPage.ets:26` already wires `ItemCard`'s ✕
  (`list.deleteItemButton`) to `ListViewModel.onDeleteItem`, and `ListPage`/`ListViewModel` are
  already reachable from `entry_point` via `pages/Index` — that reachability chain was wired by
  toggle-once/retro-todo and is unchanged here (per shaping.md's No-goes: no dialog/screen
  change). This pitch's entire scope is internal to `onDeleteItem` (reading `isSettling` before
  the existing lookup + `dialogs.openDelete` call) — a body edit to an already-orphan-free engine,
  not a new attachment. Per KB-SOL-002, `ListPage.ets` already follows the enforced
  `<Screen>Page.ets` / `<Screen>PageBuilder` naming from prior pitches, so no L6 risk is
  introduced by this map.

## Assumptions

- `engine` is named as `ListViewModel.ets` (the file `onDeleteItem` lives in, per domain-model.md
  and UC-01 Steps) rather than `ListPage.ets` (the view), consistent with toggle-once's wiring
  convention of naming the view-model as the engine for screen-level policy use cases.
