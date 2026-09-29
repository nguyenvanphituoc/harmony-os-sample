---
type: domain-model
feature: settle-across-screens
---

# Domain Model — settle-across-screens

No new bounded context, aggregate, value object, domain event or repository method. `TodoItem`,
`TodoStore`, `ToggleItem` and `ItemDeleteOpener.openDelete` are frozen by this pitch's No-goes —
the fault this pitch fixes is where the settle window's state lives, not any domain rule about
toggling or deletion.

## New class: `SettleWindow` (A1)

One new plain state/timing class, placed at `app/entry/src/main/ets/features/todo/domain/
SettleWindow.ts` — domain-scoped (alongside `ToggleItem.ts`, `AddItem.ts`), not kernel-scoped,
because the breadboard's S1 frames it as "for the whole app" *within the todo module*, not an
app-wide timing primitive `shared/kernel/` would suggest (code-surface.md flagged both as
naming-consistent; this pitch picks domain explicitly per the discovered-task seed D2, so a later
attempt cannot duplicate it in the other folder under a different unstated assumption).

| Field / Method | Type | Rule | Writer |
|---|---|---|---|
| `lastToggleAt` | `number \| null` | private; starts `null` | `mark(now)` only |
| `windowMs` | `number` (constructor param, defaults to `SETTLE_WINDOW_MS`) | one value, unchanged from toggle-once; not re-derived or duplicated | set once at construction |
| `isSettling(now: number): boolean` | method | `lastToggleAt !== null && now - lastToggleAt < windowMs` — identical logic to today's private `ListViewModel.isSettling`, moved verbatim | — (read-only) |
| `mark(now: number): void` | method | sets `lastToggleAt = now` | called only from `ListViewModel.onToggle`, after its own settle check (unchanged call order) |

`SettleWindow` takes the existing `Clock` seam (`shared/kernel/Clock.ts`) nowhere itself — it is
stamped with a `now: number` its caller already computed via `clock.now()`, exactly as
`isSettling`/`lastToggleAt` are read and written today. No new seam.

## Ownership (A2) — one instance, held above the screen's lifetime

`TodoModule` builds exactly one `SettleWindow` in its own constructor (same lifetime as
`this.store`, `this.lists` — built once per app) and passes that same instance into every
`listViewModel(listId, clock?)` call. Because `TodoModule` itself is built once (`Index.ets:26`)
and `listViewModel()` is called again on every navigation to `List` (`Index.ets:31`), the
`SettleWindow` instance — unlike the `ListViewModel` that reads it — survives leaving and
reopening a list. This is the entire fix: no new cache, no new persisted store, one object moved
up one level of the object graph it was already part of.

## `ListViewModel`'s side (A3) — an optional collaborator, not a required one

`ListViewModel`'s constructor gains one new **optional, trailing** parameter (after `clock`,
making it the 8th positional param) holding a `SettleWindow`. Built with one (as `TodoModule`
does from now on), `ListViewModel` reads/writes that shared instance instead of its own
`lastToggleAt`/`windowMs` fields, which are deleted. Built without one — as all 6 existing unit
tests in `ListViewModel.test.ets` do — it constructs its own private `SettleWindow(SETTLE_WINDOW_
MS)`, so every existing test call site keeps compiling and keeps its current behavior unchanged
(R4): a `ListViewModel` with no shared window still has *a* window, scoped to itself, exactly as
today.

`onToggle` and `onDeleteItem` change to call `this.window.isSettling(now)` / `this.window.mark
(now)` instead of the private fields/method they call today — same call order, same two call
sites, no new caller.

| Call site | Before | After |
|---|---|---|
| `onToggle` (reader + writer) | `this.isSettling(now)`; on pass, `this.lastToggleAt = now` | `this.window.isSettling(now)`; on pass, `this.window.mark(now)` |
| `onDeleteItem` (reader only) | `this.isSettling(now)` | `this.window.isSettling(now)` — never calls `mark` |

## Repository / contract

Unchanged. `ItemDeleteOpener.openDelete(itemId, title)`, `ToggleItem.execute(itemId)` and their
wiring through `TodoModule` are called exactly as before — no `⏳ TBD`, no new Request/Response
pair.

## Use case index

[[UC-01]] toggle and delete, guarded by a settle window that survives leaving and reopening the
screen.
