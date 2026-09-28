---
shaping: true
feature: "[[toggle-once]]"
status: shaped
appetite: ~2 days
---

# Toggle Once — Shaping

One tap on a to-do toggles that to-do, and only that one. Today a quick double-tap on an open item marks
two items done: the item you touched, and the item that moved into its place.

## Problem Frame

The list keeps open items at the top and finished items at the bottom (retro-todo, UC-05). A toggle moves
the item at once, with no animation, so the row under the finger is a different item a moment later. A
second tap that lands in that gap — a double-tap, or a tap that bounced — toggles the neighbour that slid
up. Found by the QA hunt after retro-todo shipped (finding QA-102). Repro on the seeded "Groceries" list
(Bread open, Buy eggs open, Buy milk done): a double-tap on Bread leaves Bread **and** Buy eggs done.
Nothing warns the user, and an item they never touched is now marked finished. Success: one gesture on
one row changes that row's item and no other.

## Appetite

**~2 days.** A small fix inside the existing list screen, plus the device check that proves it. Not a
redesign of how items move.

## Baseline

`main` of this branch as retro-todo shipped it. The list screen is `features/todo/screens/list/`
(`ListPage.ets`, `ItemCard.ets`, `ListViewModel.ets`). `ItemCard`'s toggle calls the view model, which
runs the `ToggleItem` use case, and `ListPage` re-renders with a `Repeat` keyed on the item's id, title
and done state, so a toggled item is re-sorted immediately. The device flows live under `device-flows/`
and are run by `scripts/ui-flow.sh`, whose step language has `tap` but no double-tap.

## Constraints

- The build-enforced house rules (L1–L11) apply as for retro-todo: no hex literals, no quoted text
  literals in `Text(…)`, state management V2 only, no `@Provider`/`@Consumer`.
- The retro-todo spec stays as it is: done items still sink to the bottom, at once.
- The permission grant is not widened; the device check uses the existing `ui-flow.sh` grant.

## Requirements

- **R1** — One double-tap on an open item's row marks that item done and changes no other item.
- **R2** — One double-tap on a done item's row marks that item open and changes no other item.
- **R3** — Two deliberate taps on two different rows, at a normal pace, toggle both items (the fix does
  not swallow real taps).
- **R4** — Done items still sink to the bottom and open items still stay on top, as retro-todo's UC-05
  requires.
- **R5** — The device check language can express a double-tap on a row, so R1 and R2 are graded on the
  emulator and not only in a unit test.

## Rabbit Holes

- **Animating the reorder.** A motion that keeps the row in place while the finger is down would also
  help, but spike A4 of retro-todo found the reorder motion costly on this stack. Out of scope.
- **Guessing a timing that is too long.** A settle window long enough to swallow a double-tap must stay
  short enough that R3 holds. Pick one number, name it once, and prove both sides on the device.
- **Fixing it in the use case.** `ToggleItem` is correct: it toggles the id it is given. The fault is
  which id the second touch reaches, which is a screen concern.

## No-goes

- No animation of the reorder.
- No change to the lists screen, the dialogs, or persistence.
- No change to the retro-todo spec's Test Surface rows.

## Selected Shape — A · A short settle window after a toggle

- **A1** — After a toggle, the list screen ignores further toggles for a short settle window, one named
  constant (a few hundred milliseconds). The item still sinks at once.
- **A2** — The window belongs to the list screen's view model, so it covers every row, including the
  one that slid under the finger.
- **A3** — `scripts/ui-flow.sh` gains a `doubletap` step that sends one double-click gesture to the
  element found by id or text, as `tap` already does for a single one.
- **A4** — Device flows for R1, R2 and R3, and a unit test for the settle window's two sides.

## Fit Check

| Requirement | A |
|---|---|
| R1 | ✅ A1 + A2 |
| R2 | ✅ A1 + A2 |
| R3 | ✅ A1, the window shorter than a deliberate second tap |
| R4 | ✅ unchanged sort |
| R5 | ✅ A3 |

## Gate decisions (for downstream skills)

- PO chose to take QA-102 as its own pitch rather than a retro-todo fix round (2026-09-28).
- Shape A only; the reorder animation is a No-go.
