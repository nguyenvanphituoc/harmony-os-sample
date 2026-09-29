---
shaping: true
feature: "[[list-above-keyboard]]"
status: shaped
appetite: ~1 day
---

# List Above Keyboard — Shaping

While the user types a new item, every item in the list should stay reachable. Today the soft keyboard
covers the bottom of the list and the list cannot be scrolled, so the last items, done ones included since
done items sink to the bottom, are out of reach until the keyboard is closed.

## Problem Frame

The QA hunt on lists-badge-sync reported (finding QA-002) that adding an item makes a done item "vanish"
from the list screen. A hand repro on the emulator (2026-09-29, `127.0.0.1:5555`, screen 1320×2856) shows
the item does not vanish:

```
launch
tap text "Groceries"
tap id "list.newItemField"
type id "list.newItemField" "Batteries"
tap id "list.addButton"
expect no text "Buy milk"          # passes: with the keyboard up, Buy milk is not on screen
back                               # the system back key closes the keyboard only
expect id "list.title"             # still on the list screen
expect text "Buy milk"             # passes: it was there all along, done, at the bottom
expect order text "Buy eggs" "Buy milk"
```

The store, the order and the render are all correct. The keyboard takes the lower ~40% of the screen, the
list keeps its full height behind it, and two swipes on the visible part of the list do not scroll it:
the list's content still fits its own (unshrunk) height, so there is nothing to scroll. The hunter read
the layout tree, which leaves out what the keyboard covers, and saw a missing item. What a user sees is the
same: after adding "Batteries", "Buy milk ✓" cannot be seen or touched until they close the keyboard.
Success: with the keyboard up, the user can scroll to and touch every item.

## Appetite

**~1 day.** Make the list screen give way to the keyboard, and give the device check a way to scroll.
Not a redesign of the list screen.

## Baseline

`soak/retro-todo-4` as lists-badge-sync shipped it.
- `ListPage` is a `NavDestination` → `Column` with the title row, the add row (`RetroField` +
  `RetroButton`), then `List` with `layoutWeight(1)` over `Repeat<TodoItem>`.
- Nothing in the app sets how the keyboard is avoided: no `setKeyboardAvoidMode`, no `expandSafeArea`,
  no per-page setting. The platform default applies.
- `scripts/ui-flow.sh` has `launch`, `tap`, `doubletap`, `type`, `back`, `wait` and the `expect` family.
  It has no step that scrolls.

## Constraints

- The build-enforced house rules (L1–L11) apply as for retro-todo.
- Screens without a focused field look exactly as they do today.
- The rename and new-list dialogs, which also take text, stay fully visible with the keyboard up.
- The permission grant is not widened; the device check uses the existing `ui-flow.sh` grant.

## Requirements

- **R1** — With the new-item field focused and the keyboard up, the list occupies only the space above
  the keyboard, and scrolling it reaches the last item.
- **R2** — After adding an item with the keyboard up, the new item is visible and every done item can be
  reached by scrolling, without closing the keyboard.
- **R3** — With the keyboard closed, the list screen and the MY LISTS screen are laid out exactly as today.
- **R4** — The list-name dialogs (new, rename) stay fully visible with the keyboard up.
- **R5** — The device check language can scroll a list, so R1 and R2 are graded on the emulator.

## Rabbit Holes

- **App-wide versus one screen.** The keyboard avoid mode can be set for the whole window (the UI
  context's keyboard avoid mode) or handled on one page. Either may be right; the spike decides, and R4 is
  there because an app-wide switch reaches the dialogs too.
- **Scrolling the new item into view.** Nice, and not asked: the new item appears at the top of the open
  items already. Out of scope.
- **The Done key submits an empty field.** Tapping the keyboard's Done key (完成) on an empty field shows
  "Title can't be empty". Seen during the repro; it is a separate question and not this pitch.

## No-goes

- No change to how items are sorted, added, toggled or deleted.
- No custom keyboard, no hiding the keyboard automatically after ADD.
- No change to the MY LISTS screen beyond what R3 already requires.

## Selected Shape — A · The list gives way to the keyboard

- **A1** — A spike picks the smallest setting that makes the list screen resize above the keyboard
  (window-wide or page-level) and checks R4 on the dialogs before committing to it.
- **A2** — The list screen applies it; the `List` keeps `layoutWeight(1)` and so shrinks to the space left.
- **A3** — `scripts/ui-flow.sh` gains a `swipe` step (`swipe id "<node>" up|down`) that swipes across the
  node found by id, as `tap` finds its node.
- **A4** — Device flows for R1, R2 (the repro above, extended with a swipe instead of `back`), R3 and R4.

## Fit Check

| Requirement | A |
|---|---|
| R1 | ✅ A1 + A2 |
| R2 | ✅ A2, A4 |
| R3 | ✅ A1 (keyboard-only effect), A4 |
| R4 | ✅ A1, A4 |
| R5 | ✅ A3 |

## Gate decisions (for downstream skills)

- PO asked to repro lists-badge-sync's QA-002 by hand and shape it (2026-09-29). The repro showed the item
  was never gone, only covered and unreachable behind the keyboard; this pitch shapes that, not a render bug.
- Shape A; the empty-submit message on the Done key is left out.
