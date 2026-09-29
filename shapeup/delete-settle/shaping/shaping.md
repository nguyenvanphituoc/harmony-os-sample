---
shaping: true
feature: "[[delete-settle]]"
status: shaped
appetite: ~1 day
---

# Delete Settle — Shaping

A tap on a row's ✕ deletes the item the user was looking at. Today, a tap on a ✕ right after a toggle can
open the delete dialog for a different item: the one that slid into that row when the list re-sorted.

## Problem Frame

A toggle re-sorts the list at once (retro-todo, UC-05), so the row under the finger holds a different item
a moment later. toggle-once added a short settle window that ignores a second toggle in that gap, but the
✕ is not covered. The QA hunt on toggle-once reproduced it (charter C-02): on the seeded "Groceries" list,
a tap on "Buy eggs" and then an immediate tap where its ✕ had been opened `Delete "Bread"?`. Only the
confirm dialog stands between the user and deleting an item they never meant to touch. Success: the ✕
the user aimed at never opens a dialog for another item.

## Appetite

**~1 day.** One more guard in the list view model, the same window toggle-once already uses, and its tests.

## Baseline

`soak/retro-todo-4` as toggle-once shipped it. `ListViewModel.onToggle` checks `isSettling(now)` against
`SETTLE_WINDOW_MS` (400 ms) and stamps `lastToggleAt`. `ListViewModel.onDeleteItem(itemId)` opens the
delete dialog through `ItemDeleteOpener.openDelete` with no such check. `ItemCard`'s ✕ (`list.deleteItemButton`)
calls `onDelete`, which `ListPage` wires to `vm.onDeleteItem(r.item.id)`.

## Constraints

- The build-enforced house rules (L1–L11) apply as for retro-todo.
- The settle window stays one named constant, shared by toggle and delete; its length does not change.
- The permission grant is not widened; device checks use the existing `ui-flow.sh` grant.

## Requirements

- **R1** — A tap on any row's ✕ inside the settle window after a toggle opens no delete dialog and deletes
  nothing.
- **R2** — A tap on a row's ✕ outside the settle window opens the delete dialog naming that row's item, as
  before.
- **R3** — Toggling is unchanged: the settle window still swallows a second toggle and still lets a
  deliberate one through, and done items still sink at once.

## Rabbit Holes

- **Proving R1 on the device.** A device flow cannot reliably land a second tap inside 400 ms, because each
  step looks its target up in the layout tree first. R1 is proven by a unit test with a controlled clock;
  the device flow proves R2 on the emulator.
- **Locking the whole row.** Disabling the ✕ visually during the window is a UI change nobody asked for.

## No-goes

- No change to the settle window's length, and no second constant.
- No change to the dialogs, the lists screen, or persistence.
- No animation of the reorder.

## Selected Shape — A · The settle window covers delete too

- **A1** — `ListViewModel.onDeleteItem` returns without opening a dialog while `isSettling(now)` holds.
- **A2** — A delete does not open or extend the window; only a toggle does.
- **A3** — Unit tests for both sides of the window on delete, with the existing test clock; a device flow for
  R2 on the seeded list.

## Fit Check

| Requirement | A |
|---|---|
| R1 | ✅ A1 |
| R2 | ✅ A1 (outside the window), A3 |
| R3 | ✅ A2, toggle code untouched |

## Gate decisions (for downstream skills)

- PO chose to take toggle-once's QA finding C-02 as its own pitch (2026-09-29).
- Shape A only; R1 is graded by unit test, not on the device.
