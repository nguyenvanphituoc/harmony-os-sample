---
type: synthesis
feature: delete-settle
---

# Synthesis — delete-settle

## Traceability (requirement -> use case -> screen)

| Requirement | Use case | Screen / rule |
|---|---|---|
| REQ-1 a ✕ tap inside the settle window opens no dialog and deletes nothing | [[UC-01]] Step 2 | P2 U1 |
| REQ-2 a ✕ tap outside the settle window opens the dialog naming that row's item, as before | [[UC-01]] Step 3 | P2 U1 |
| REQ-3 toggling still swallows a second toggle (split 1/3) | toggle-once UC-01 (frozen, not re-graded) | P2 U1, unchanged |
| REQ-4 toggling still lets a deliberate one through (split 2/3) | toggle-once UC-01 (frozen, not re-graded) | P2 U1, unchanged |
| REQ-5 done items still sink at once (split 3/3) | retro-todo `ItemOrder` (frozen, not re-graded) | P2, unchanged |

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| The guard accidentally writes `lastToggleAt`, silently changing toggle behavior too | low (spike: `lastToggleAt` has exactly one writer today, `onToggle`'s last line) | TS-01-03 asserts a delete inside the window leaves `lastToggleAt` untouched |
| A device flow is used to try to prove R1 (the inside-the-window case) and comes back flaky | ruled out by the pitch's own rabbit hole | R1 is proven only by the unit test with `SettableClock`; the device tier only carries R2 (TS-01-04) |
| The guard is implemented per-row instead of screen-wide, missing the reproduced fault | known, ruled out by the pitch's own spike (reuses `isSettling`, which is already screen-wide) | INV-02: the window guards any itemId, not the row that was originally tapped |
| A second named constant is introduced for the delete side | explicit No-go | domain-model.md: `windowMs` / `SETTLE_WINDOW_MS` is the single source, read by both `onToggle` and `onDeleteItem` |

## Hammered out

Locking the whole row (disabling the ✕ visually during the window) — pitch Rabbit Holes, a UI
change nobody asked for; any change to the settle window's length or a second constant, any
change to the dialogs, the list screen's layout or persistence, any animation of the reorder — all
pitch No-goes, not open questions; proving R1 on the device — the pitch's own rabbit-hole answer
(unit test only), matching what `SettableClock` already supports.

## Dependency graph

`isSettling`/`lastToggleAt`/`SETTLE_WINDOW_MS` (toggle-once, already built) -> guard added to
`ListViewModel.onDeleteItem` + unit tests for both sides (breadboard V1) -> one device flow for R2
on the seeded list (breadboard V2, depends on V1's guard existing to have anything to prove).
