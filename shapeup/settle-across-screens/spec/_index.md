---
type: index
feature: settle-across-screens
lens: standard
appetite: ~1 day
---

# settle-across-screens — Spec index

The settle window toggle-once introduced and delete-settle extended lives on `ListViewModel`
today, and `TodoModule` builds a new `ListViewModel` on every visit to the list screen (P2), so
the window resets whenever the user leaves and reopens a list. This pitch moves the window's
state out of `ListViewModel` into one `SettleWindow` instance `TodoModule` owns for the whole app
and hands to every `ListViewModel` it builds, so the window's lifetime survives the visit that
opened it (QA-001, delete-settle).

Source: the committed shaping in `shapeup/settle-across-screens/shaping/` (shaping.md,
breadboard.md) and the requirement registry `shapeup/settle-across-screens/requirements.md`.
Orient's recon for this run (code surface, the device-flow spike, discovered-task seed, hill
signal) fed this analysis but is run-tier and not cited here by path.

## Boundaries

In: extracting `lastToggleAt` / `windowMs` (`SETTLE_WINDOW_MS`) / `isSettling` into a small
`SettleWindow` class (A1); `TodoModule` building one instance and passing it into every
`listViewModel()` call (A2); `ListViewModel` taking it as a new optional, trailing constructor
argument that defaults to a fresh window when absent (A3); unit tests over two `ListViewModel`s
sharing one `SettleWindow` (A4, R1/R2/R3); a device flow proving R3 (outside the window, on a
reopened list) unchanged.

Out (No-goes, frozen by the pitch): caching `ListViewModel` itself, or otherwise changing how view
models are built or how long they live, beyond handing each one the shared window; any change to
the window's length or a second constant; any change to the dialogs, the lists screen, or
persistence; any animation of the reorder; a per-list window (Shape A is one window for the whole
module, per the pitch's Rabbit Holes).

## Document map

| Document | What |
|---|---|
| [[domain-model]] | the new `SettleWindow` class, its one owner (`TodoModule`), and the two read/write call sites |
| [[ux-behavior]] | Screen P2 (List) — unchanged states, the same two affordances now guarded by a window that outlives one visit |
| [[UC-01]] | Toggle and delete guarded by a settle window that survives leaving and reopening the screen |
| [[integration]] | `TodoModule -> SettleWindow -> ListViewModel` wiring, the device-flow proof for R3, silent-failure risks |
| [[synthesis]] | traceability, risk register, dependency graph |
| [[feedback]] | PO / TL feedback template |
