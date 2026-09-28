---
type: domain-model
feature: toggle-once
---

# Domain Model — toggle-once

No new bounded context, aggregate, value object, domain event or repository method. `TodoItem`,
`TodoStore` and the `ToggleItem` use case are frozen by this pitch's No-goes and rabbit holes — the
domain use case is correct today: it toggles the id it is given. The fault QA-102 found is which id
the second touch reaches, and that lives in the screen, not the domain.

## Screen-level policy (not a domain aggregate)

`SettleWindow` — a small piece of state owned by `ListViewModel` (screen layer, `.ets`), not the
Todo domain (`.ts`). It is not persisted, not part of `TodoStore`, and not passed to `ToggleItem`.

| Field | Type | Rule |
|---|---|---|
| `lastToggleAt` | `number \| null` | set to `clock.now()` every time `onToggle` actually calls `ToggleItem` |
| `windowMs` | `number` (named constant) | one value, named once, chosen and proved on-device (pitch rabbit hole) |

`isSettling(now)` = `lastToggleAt !== null && now - lastToggleAt < windowMs`. `onToggle(itemId)`
calls `ToggleItem(itemId)` only when `!isSettling(clock.now())`, then sets `lastToggleAt =
clock.now()`; otherwise it is a no-op — no error, no state change, nothing surfaced to the user.

## Testability seam

`ListViewModel`'s constructor widens to accept an optional `Clock` (matching the existing
`toggleItem?`/`addItem?` optional-param style), defaulting to `SystemClock` from the composition
root (`TodoModule.listViewModel`). The unit test needs a *settable* fake clock (`now()` can be
advanced between calls) — the existing `FixedClock` in the repository's own test returns a
constant and cannot exercise both sides of the window.

## Repository / contract

Unchanged. `TodoRepository.setDone` and its `Result<TodoItem>` / `ITEM_NOT_FOUND` shape (retro-
todo's contract) are called exactly as before, through the unchanged `ToggleItem` use case — no
`⏳ TBD`, no new Request/Response pair.

## Use case index

[[UC-01]] toggle an item, guarded by a settle window.
