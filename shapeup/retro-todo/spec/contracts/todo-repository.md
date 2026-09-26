---
type: contract
feature: retro-todo
---

# Contract — TodoRepository (in-memory)

No network and no third-party API, so no `⏳ TBD`. Every method returns `Result<T>`.

| Method | Request | Response (Ok) | Errors |
|---|---|---|---|
| `createList` | `name: string` (already checked) | `TodoList` | — |
| `renameList` | `listId: string`, `name: string` | `TodoList` | `LIST_NOT_FOUND` |
| `deleteList` | `listId: string` | `void` (the list and all its items are gone) | `LIST_NOT_FOUND` |
| `addItem` | `listId: string`, `title: string` | `TodoItem` (`done=false`, `createdAt` now) | `LIST_NOT_FOUND` |
| `setDone` | `itemId: string`, `done: boolean` | `TodoItem` | `ITEM_NOT_FOUND` |
| `deleteItem` | `itemId: string` | `void` | `ITEM_NOT_FOUND` |

Time and ids come from `Clock` / `IdGen` ports so local tests control them.
