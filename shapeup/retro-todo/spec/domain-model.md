---
type: domain-model
feature: retro-todo
---

# Domain Model — retro-todo

One bounded context, **Todo**. Everything is in memory; nothing persists (pitch R14). Domain code is
plain `.ts` under `features/todo/domain` and `shared/kernel`, device-free and never importing `.ets`.

## Aggregates

| Aggregate | Status | Fields | Notes |
|---|---|---|---|
| `TodoList` | new | `id`, `name`, `createdAt` | Owns its items: deleting a list deletes them. Names are not unique (R1). |
| `TodoItem` | new | `id`, `listId`, `title`, `done`, `createdAt` | Belongs to exactly one list; never moves to another (No-go). |

## Value objects

- `ListName` / `ItemTitle` — a string trimmed by `TodoRules`; blank after trim is invalid.
- `Result<T>` — `Ok(value)` or `Err(ErrorCode)`; every use case returns it, nothing throws.
- `ErrorCode` — `LIST_NAME_EMPTY`, `ITEM_TITLE_EMPTY`, `LIST_NOT_FOUND`, `ITEM_NOT_FOUND`.

## Domain services (pure functions)

| Service | Signature | Rule |
|---|---|---|
| `TodoRules.checkListName` | `(name) -> Result<string>` | trim; empty or whitespace-only -> `LIST_NAME_EMPTY`; duplicates allowed |
| `TodoRules.checkItemTitle` | `(title) -> Result<string>` | trim; blank -> `ITEM_TITLE_EMPTY` |
| `ItemOrder.sort` | `(items) -> TodoItem[]` | open items before done items; within each group `createdAt` descending (newest-created first) |

## Domain events

None. State changes are observed through `TodoStore` (`@Trace` arrays), not events.

## Repository interface

`TodoRepository` (implemented by `InMemoryTodoRepository`, the only writer of `TodoStore`):
`createList(name)` · `renameList(listId, name)` · `deleteList(listId)` · `addItem(listId, title)` ·
`setDone(itemId, done)` · `deleteItem(itemId)`. `seed()` runs on every cold start.

## Store

`TodoStore.lists` (S1) and `TodoStore.items` (S2): `@Trace` arrays read by the ViewModels. Only the
repository writes them; no View touches the store.

## Seed data (every cold start)

Lists created Weekend -> Work -> Groceries (so newest-first reads Groceries, Work, Weekend). Groceries:
Buy milk (done), Buy eggs, Bread. Work: Book meeting room (done), Send weekly report. Weekend: no items.
Items are created in the order listed, so newest-created-first within a group reads Bread before Buy
eggs, and Send weekly report first in Work.

## Use case index

[[UC-01]] create list · [[UC-02]] rename list · [[UC-03]] delete list · [[UC-04]] add item ·
[[UC-05]] toggle item · [[UC-06]] delete item · [[UC-07]] view lists · [[UC-08]] view list
