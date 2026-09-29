---
shaping: true
feature: "[[settle-across-screens]]"
status: shaped
appetite: ~1 day
---

# Settle Across Screens — Shaping

The settle window protects the list screen for 400 ms after a toggle. It should still do that when the
user leaves the list and comes straight back. Today, leaving and reopening a list clears the window, so a
✕ tap right after the reopen opens the delete dialog for an item toggled a moment earlier.

## Problem Frame

toggle-once added a settle window that ignores a second toggle while the list re-sorts, and delete-settle
extended it to the ✕. Both keep the window on the `ListViewModel` instance, and the app builds a new
`ListViewModel` each time the list screen is opened (`pages/Index.ets` calls `TodoModule.listViewModel()`
inside its route builder). So the window lasts only as long as one visit to the screen.

The QA hunt on delete-settle reproduced it on the emulator (finding QA-001). On the seeded "Groceries"
list: toggle "Bread", tap back, reopen "Groceries", then tap the ✕ on the first row. All four taps took
about 10 ms. The delete dialog opened, although the ✕ tap came well inside the 400 ms that delete-settle's
INV-02 promises. The confirm dialog is still the last guard. Success: a toggle's settle window holds for
its full length whether or not the user leaves the screen and returns.

## Appetite

**~1 day.** Move one piece of state out of the view model to where it outlives a visit to the screen, and
prove it. Not a redesign of navigation or of how view models are built.

## Baseline

`soak/retro-todo-4` as delete-settle shipped it.
- `ListViewModel` holds `lastToggleAt` and `windowMs = SETTLE_WINDOW_MS` (400), and `isSettling(now)` reads
  them. `onToggle` checks the window and stamps `lastToggleAt`. `onDeleteItem` checks it and never writes it.
- `TodoModule` is built once for the app. It keeps one `ListsViewModel` for the whole session, but
  `listViewModel(listId, clock?)` returns a new `ListViewModel` on every call.
- Unit tests in `app/entry/src/test/ListViewModel.test.ets` build `ListViewModel` directly with a
  settable clock, and hold one instance per test.

## Constraints

- The build-enforced house rules (L1–L11) apply as for retro-todo.
- The window's length stays one named constant (`SETTLE_WINDOW_MS`, 400 ms). No second constant, and the
  length does not change.
- toggle-once's and delete-settle's rules stay exactly as they are within one visit to the screen: a toggle
  opens the window, a delete only reads it.
- The permission grant is not widened.

## Requirements

- **R1** — A ✕ tap inside the settle window after a toggle opens no delete dialog, even when the list screen
  was left and reopened between the toggle and the tap.
- **R2** — A toggle inside the settle window is ignored in the same case: after leaving and reopening the
  list, a second toggle within the window changes nothing.
- **R3** — Outside the window, a ✕ tap on a reopened list opens the dialog naming that row's item, and a
  toggle toggles, exactly as today.
- **R4** — Within one visit to the screen, toggle-once's and delete-settle's behavior is unchanged: their
  existing unit tests and device flows still pass without edits.

## Rabbit Holes

- **Keeping the view model alive across navigation.** Caching one `ListViewModel` per list in `TodoModule`
  would also keep the window, but it changes the view model's lifetime for everything else it holds
  (`newTitle`, `hasTitleError`, `loaded`), and that is a behavior change nobody asked for. Move only the
  window.
- **One window per list versus one for the app.** A window keyed per list would let a delete on a
  *different* list through in the same 400 ms. That case has no reorder under the finger, but it is also
  harmless to swallow, and a single window is the simpler thing to prove. One window for the module.
- **Proving R1 on the device.** The hunter reproduced it with raw `uitest uiInput click` taps. The device-flow
  language looks each target up first, which is slower than 400 ms, so a flow cannot land inside the
  window. R1 and R2 are graded by unit tests with a controlled clock, and the device flow covers R3.

## No-goes

- No change to how view models are cached or built, beyond handing each one the shared window.
- No change to the window's length, the dialogs, the lists screen, or persistence.
- No animation of the reorder.

## Selected Shape — A · The module owns the settle window

- **A1** — A small `SettleWindow` holds `lastToggleAt`, the clock and `SETTLE_WINDOW_MS`, with `isSettling(now)`
  and `mark(now)`. It moves out of `ListViewModel` without changing its logic.
- **A2** — `TodoModule` builds one `SettleWindow` for the app and hands it to every `ListViewModel` it
  creates, so leaving and reopening a list reads the same window.
- **A3** — `ListViewModel` takes the window as an optional constructor argument. Built without one, as the
  existing unit tests do, it makes its own, so those tests run unchanged (R4).
- **A4** — Unit tests: two `ListViewModel`s built over one `SettleWindow` — a toggle on the first, then a ✕ tap
  and a toggle on the second inside the window, then both outside it (R1, R2, R3). A device flow for R3 on a
  reopened list.

## Fit Check

| Requirement | A |
|---|---|
| R1 | ✅ A1 + A2 |
| R2 | ✅ A1 + A2 |
| R3 | ✅ A1 (outside the window), A4 |
| R4 | ✅ A3 |

## Gate decisions (for downstream skills)

- PO asked to shape delete-settle's QA-001 as its own pitch (2026-09-29).
- Shape A: one window for the module, not per list, and not by caching view models.
- R1 and R2 are graded by unit test; the device flow covers R3.
