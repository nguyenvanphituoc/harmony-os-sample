---
schema_version: 1
feature: settle-across-screens
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
---

# Wiring Map — settle-across-screens

`entry_point` echoes `project-profile.md`. `EntryAbility.ets` loads `pages/Index`
(`windowStage.loadContent('pages/Index', ...)`), which already hosts the `Navigation` that routes
to `ListPage` — this pitch adds no route and no screen; it moves where one piece of state
(`SettleWindow`) lives inside a chain already reachable from the entry point. Per KB-SOL-001, the
seam below is resolved against the `EntryAbility` → `pages/Index` chain that exists today. No new
routed screen is introduced, so KB-SOL-002's `<Screen>Page.ets` / `<Screen>PageBuilder` naming
rule has nothing new to bite.

## Wiring

| use_case | engine | wiring_seam | entry_call_site | affordance |
|---|---|---|---|---|
| UC-01 | app/entry/src/main/ets/features/todo/domain/SettleWindow.ts | New plain class (domain-model.md's `SettleWindow`), constructed once by `TodoModule`'s own constructor and held as an instance field (same lifetime as `this.store`/`this.lists`); no ArkUI event attaches to it directly — it is read/written only through `ListViewModel.onToggle`/`onDeleteItem` (rows below) | app/entry/src/main/ets/entryability/EntryAbility.ets — `pages/Index` → `TodoModule` construction (existing composition root for the todo feature, unchanged) — `TodoModule`'s constructor gains one `new SettleWindow()` field assignment | S1 settle window (breadboard) — no direct UI surface of its own; it is the shared state every U1/U2 tap on P2 List now reads/writes through N1/N2 |
| UC-01 | app/entry/src/main/ets/features/todo/TodoModule.ets | `listViewModel(listId, clock?)` (`TodoModule.ets:78`, called from `Index.ets:31` on every navigation to P2) passes `this.settleWindow` — the one instance built in the constructor — as the new 8th constructor argument to every `ListViewModel` it builds; no caching added (INV-05), so a revisit still builds a fresh `ListViewModel` but hands it the same window | app/entry/src/main/ets/entryability/EntryAbility.ets — `pages/Index` → `Navigation` → `ListPage` `NavDestination`'s route builder, which calls `TodoModule.listViewModel(listId)` on every visit (existing call site, unchanged signature call shape — one new positional argument) | U4 list card open (P1 → P2) — every reopen of a list now carries forward the same S1 instance instead of a fresh one |
| UC-01 | app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets | `ItemCard`'s toggle tap (`list.itemCard.toggle`) already calls `ListViewModel.onToggle(itemId)` (`ListPage.ets`'s existing `Repeat` handler, per toggle-once); the ✕ tap (`list.deleteItemButton`) already calls `onDeleteItem(itemId)` (per delete-settle). This pitch changes both methods' bodies to call `this.window.isSettling(now)` / `this.window.mark(now)` against the injected `SettleWindow` (or a private fallback one when none is given, INV-04) instead of the view model's own `lastToggleAt`/`windowMs` fields — no new attachment, the handlers already reach these methods | app/entry/src/main/ets/entryability/EntryAbility.ets — `pages/Index` → `ListPage` `NavDestination` → `ItemCard` tap handlers inside `ListPage`'s `Repeat` (existing route, unchanged from toggle-once/delete-settle) | U1 item card toggle → N1 `onToggle` (mark/guard on S1); U2 item card ✕ → N2 `onDeleteItem` (guard-only read of S1) — both on P2 List, across the revisit V2 exercises |

## Deviations

- No new route, no new screen, no new dialog — every attachment above is an existing seam
  (toggle-once's `onToggle` handler, delete-settle's `onDeleteItem` handler, `TodoModule`'s
  existing `listViewModel()` call site) whose *body* changes to read/write a relocated piece of
  state. The only genuinely new attachment is `SettleWindow`'s construction inside `TodoModule`'s
  constructor (row 1) — there is no player-facing affordance for that row on its own; its
  affordance is exercised transitively through rows 2 and 3, which is why row 1's `affordance`
  cell names S1 itself rather than a tap.
- Per KB-SOL-001, all three `entry_call_site` cells resolve against the `EntryAbility.ets` →
  `pages/Index` → `TodoModule`/`ListPage` chain that exists on disk today, not any docs-planned
  `AppModules`/`route_map.json` host — none of that scaffolding exists in this project and this
  pitch does not add it.
- No UC in this pitch has a purely internal/background engine with no eventual player-facing
  seam — `SettleWindow` (row 1) has no direct tap of its own, but every row traces to an
  on-screen affordance through N1/N2, so no boot/cron attachment case applies here.

## Assumptions

- `engine` for the shared-state row is named as the new file `domain/SettleWindow.ts`
  (domain-model.md's placement — domain-scoped, alongside `ToggleItem.ts`/`AddItem.ts`, per the
  discovered-task seed D2 cited there), not `shared/kernel/` — consistent with domain-model.md's
  explicit placement rule so a later attempt does not duplicate it in the other folder.
- `TodoModule.ets` and `ListViewModel.ets` are named as separate engine rows (not folded into one
  cell) because they are two distinct files each with their own edit surface and call site,
  consistent with toggle-once's and delete-settle's one-row-per-engine convention.
