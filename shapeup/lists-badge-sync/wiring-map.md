---
schema_version: 1
feature: lists-badge-sync
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
---

# Wiring Map — lists-badge-sync

## Wiring

| use_case | engine | wiring_seam | entry_call_site | affordance |
|---|---|---|---|---|
| UC-01 | app/entry/src/main/ets/features/todo/screens/lists/ListsPage.ets | existing render chain already attached to the composition root — this pitch's fix replaces the inlined `cardBuilder` `@Builder` call inside `AsyncBoundary`'s `readyBuilder` → `Repeat.each` chain with an independently-tracked V2 render unit (e.g. a `@ComponentV2 struct` taking `card: ListCard` as `@Param`), so the already-mounted P1 re-renders per-card on a `store` change instead of only on a fresh mount | app/entry/src/main/ets/entryability/EntryAbility.ets — `loadContent('pages/Index', …)` (no `routerMap`/route_map registration on this project; `pages/Index` hosts the `Navigation` stack that already mounts `TodoModule` → `ListsPage`, unchanged by this pitch) | U1 badge / card name on P1 My Lists reads the new `done`/`total`/`name` immediately on return to an already-mounted P1 (R1–R6) |
| UC-01 | app/entry/src/main/ets/features/todo/screens/lists/ListsViewModel.ets | `cards` (`@Computed` getter over `store.lists`/`store.items`, both `@Trace`) is the read side of the same chain — unchanged by this pitch (frozen, INV-01/INV-04); named as its own row because the fix in `ListsPage.ets` reads through this getter's output and the reachability oracle resolves each engine path independently | app/entry/src/main/ets/entryability/EntryAbility.ets — `loadContent('pages/Index', …)` → `TodoModule` (built once per session, `TodoModule.ets:63,71`) → `ListsPage` reads `this.vm.cards` | U1 badge / card name — same affordance as the row above; this engine supplies the data the render-unit fix (row above) must reflect on every read |

## Deviations

- No new screen, route, or entry point is introduced by this pitch (No-goes: domain-model.md,
  synthesis.md). The project has no `routerMap`/`route_map.json` registration on this module —
  `main_pages.json` names only `pages/Index`, and `EntryAbility.ets` loads it directly — so
  KB-SOL-002's routed-screen naming rule (`…Page.ets` file + `<Screen>PageBuilder` builder,
  matched by house rule L6) does not apply here: `ListsPage.ets` is an existing file already
  reachable from the composition root, not a new routed screen this map is asking the build to
  register. The two engine rows above name the render-unit fix and its data source as design
  intent for A1/A2 (domain-model.md); which exact link inside `ListsPage.ets` changes shape (a
  new `@ComponentV2` sub-component vs. some other fix A1 confirms) is spike/build-time territory,
  not this map's — the attachment to the entry point is unchanged either way.
- `ListsViewModel.ets` and `ListsPage.ets` are both already wired to the composition root
  (`TodoModule`, built once per session per `TodoModule.ets:63,71`); there is no orphaned-engine
  risk here of the kind this artifact usually exists to catch. Both rows are still written
  explicitly, per the "no use case is exempt" rule, rather than left as a single ambiguous cell.
