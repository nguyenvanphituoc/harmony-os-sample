---
type: domain-model
feature: lists-badge-sync
---

# Domain Model — lists-badge-sync

No new bounded context, aggregate, value object, domain event or repository method. `TodoStore`,
`TodoList`, `TodoItem`, `ToggleItem`, `InMemoryTodoRepository` and their reassign-the-whole-array
update pattern are frozen by this pitch's No-goes — the fault this pitch fixes is where the
render chain drops an already-correct store update, not any domain rule about lists or items.

## `ListCard` (`ListsViewModel.ets:13-25`) — unchanged shape, implicated lifetime

`ListCard` is a plain, undecorated class (`readonly id/name/done/total`, no
`@ObservedV2`/`@Trace`) built fresh on every read of `ListsViewModel.cards` (a `@Computed`
getter). This pitch's No-goes rule out changing what a `ListCard` carries; the spike narrowed the
suspect to how the *view layer* consumes a freshly-built `ListCard[]`, not to the array itself
being stale — `cards` recomputes correctly on every read (confirmed live: a fresh mount of the
same list shows the post-toggle count).

## The render-layer suspect the spike isolated

Two structurally different chains render list state today:

| Screen | State source | Render unit | Independently tracked by V2? |
|---|---|---|---|
| P2 List, per item (`ItemCard.ets`) | `ListViewModel.items` (`@Computed`) | `@ComponentV2 struct ItemCard`, `@Param @Require item: TodoItem` | yes — its own render scope per `Repeat` item |
| P1 My Lists, per card (`ListsPage.ets`) | `ListsViewModel.cards` (`@Computed`) | `cardBuilder(card: ListCard)`, a `@Builder` method inlined two levels down (`AsyncBoundary`'s `@BuilderParam ready` slot → `readyBuilder` → `Repeat.each` → `cardBuilder`), never a component of its own | the open question A1 answers |

The working chain's render unit is a real `@ComponentV2` with its own `@Param`; the broken
chain's is a `@Builder` method with no independent V2 render scope, called from inside a parent
(`ListsPage`) that — by design (`TodoModule.ets:63,71`, one `ListsViewModel` per session) — is
never torn down and rebuilt while a list is open above it in the `Navigation` stack. This is the
leading candidate the spike surfaced, not a conclusion: A1 (task-level) confirms it, or rules it
out in favor of another link in the same chain, before A2 touches any file.

## A2 — the fix is scoped to this one link

Whichever link A1 confirms, the fix lands in `ListsPage.ets` and/or `ListsViewModel.ets` only —
no new class, no new store field, no change to `TodoStore`, `TodoList`, `TodoItem` or any
repository method. If A1 confirms the `@Builder`-vs-`@ComponentV2` gap, the shape of A2 is: give
the card's rendered content its own independently-tracked V2 render unit (e.g. a
`@ComponentV2 struct` taking `card: ListCard` as an `@Param`) in place of the inlined `@Builder`
call — a change local to how P1 renders `cards`, touching neither `ListsViewModel.cards`'s
computation nor any other screen.

## Repository / contract

Unchanged. `InMemoryTodoRepository.setDone`/`addItem`/`deleteItem`/`renameList` and their wiring
through `TodoModule` are called exactly as before — no `⏳ TBD`, no new Request/Response pair.

## Use case index

[[UC-01]] the MY LISTS card stays in sync with its list's items and name whenever MY LISTS is on
screen, including a return to it after it has stayed mounted underneath an open List screen.
