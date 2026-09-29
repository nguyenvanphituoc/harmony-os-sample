---
type: index
feature: delete-settle
lens: standard
appetite: ~1 day
---

# delete-settle — Spec index

A small fix beside toggle-once's List screen (P2): a tap on a row's ✕ (`list.deleteItemButton`)
opens the delete dialog for whatever item now sits at that row, even when a toggle just re-sorted
the list under the finger. toggle-once's settle window already guards `onToggle` against this same
class of mis-hit; this pitch extends the guard to `onDeleteItem` so the ✕ the user aimed at never
opens a dialog for another item (QA finding C-02, toggle-once).

Source: the committed shaping in `shapeup/delete-settle/shaping/` (shaping.md, breadboard.md) and
the requirement registry `shapeup/delete-settle/requirements.md`. Orient's recon for this run
(code surface, the settle-guard spike, discovered-task seed, hill signal) fed this analysis but is
run-tier and not cited here by path.

## Boundaries

In: a settle-window guard on `ListViewModel.onDeleteItem`, reusing the existing `isSettling` /
`lastToggleAt` / `SETTLE_WINDOW_MS` state `onToggle` already owns — no new constant, no new field;
unit tests for both sides of the window on delete, with the existing test clock; a device flow
proving R2 (a ✕ tap with no toggle before it still opens the dialog naming that item) on the
seeded list.

Out (No-goes, frozen by the pitch): any change to the settle window's length or a second constant;
any change to the dialogs, the list screen's layout, or persistence; any animation of the reorder;
proving R1 on the device (the pitch's own rabbit hole — a device flow cannot reliably land a
second tap inside 400ms, so R1 is proven by a unit test with a controlled clock only).

## Document map

| Document | What |
|---|---|
| [[domain-model]] | why this pitch adds no domain aggregate — the guard reuses toggle-once's screen-level settle-window policy |
| [[ux-behavior]] | Screen P2 (List) — the guarded ✕ affordance, unchanged states |
| [[UC-01]] | Delete an item, guarded by the settle window |
| [[integration]] | ListViewModel -> Clock chain (unchanged), device-flow proof for R2, silent-failure risks |
| [[synthesis]] | traceability, risk register, dependency graph |
| [[feedback]] | PO / TL feedback template |
