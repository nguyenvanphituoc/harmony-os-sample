---
type: synthesis
feature: settle-across-screens
---

# Synthesis — settle-across-screens

## Traceability (requirement -> use case -> screen)

| Requirement | Use case | Screen / rule |
|---|---|---|
| REQ-1 a ✕ tap inside the settle window opens no dialog, even across a leave-and-reopen | [[UC-01]] Step 5 | P2 U2 |
| REQ-2 a toggle inside the settle window is ignored, even across a leave-and-reopen | [[UC-01]] Step 6 | P2 U1 |
| REQ-3 outside the window, a ✕ tap opens the dialog naming that row's item, on a reopened list | [[UC-01]] Step 5 | P2 U2 |
| REQ-4 within one visit, toggle-once's and delete-settle's behavior is unchanged | [[UC-01]] Step 7, INV-04 | P2 U1/U2, unchanged |
| REQ-5 outside the window, a toggle toggles, on a reopened list | [[UC-01]] Step 6 | P2 U1 |

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| `SettleWindow` ends up built per-visit instead of once on `TodoModule`, reproducing the exact bug this pitch fixes | the pitch's core risk, not a tail case | INV-02 names ownership explicitly; TS-01-01..04 (two `ListViewModel`s over one window) fail immediately if the window is not actually shared |
| `onDeleteItem` is wired to also call `SettleWindow.mark`, silently reopening the window on every delete | low (spike D3: today's `onDeleteItem` has zero writes to `lastToggleAt`, confirmed by reading it) | INV-03; TS-01-01/02 probe the shared window's edge from a toggle-only mark |
| The flow directory this pitch's device check (TS-01-06) needs is not granted to the owning scope, repeating retro-todo run 8's `probe owner: null` failure | known and flagged (D1) | not fixable here — carried to L1b's substrate-disjointness lint as a scope-cut check |
| `SettleWindow` lands in two folders across two attempts (`features/todo/domain/` vs `shared/kernel/`) | low once decided | domain-model.md picks `features/todo/domain/SettleWindow.ts` explicitly (D2) |
| A per-list window is built instead of one for the whole module | ruled out by Shape A | breadboard S1 and shaping.md's Rabbit Holes are explicit: one window for the module, not per list |

## Hammered out

Caching one `ListViewModel` per list in `TodoModule` (shaping.md Rabbit Holes) — changes the view
model's lifetime for `newTitle`/`hasTitleError`/`loaded` too, a behavior change nobody asked for;
a window keyed per list (Rabbit Holes) — lets a delete on a *different* list through in the same
400ms, a case Shape A judges harmless to swallow and not worth the complexity; any change to the
window's length, a second constant, the dialogs, the list screen or persistence, any animation of
the reorder — all pitch No-goes, not open questions; proving R1/R2 on the device — the pitch's own
rabbit hole (unit tests with a controlled clock only, per the confirmed spike).

## Dependency graph

`isSettling`/`lastToggleAt`/`SETTLE_WINDOW_MS` (toggle-once, already built; delete-settle already
reads them from `onDeleteItem`) -> extracted into `SettleWindow` (breadboard V1) -> `TodoModule`
builds one instance and threads it through `listViewModel()` (V1) -> `ListViewModel` takes it as
an optional trailing ctor param, defaulting to a private instance when absent (V1) -> unit tests
over two `ListViewModel`s sharing one window (V1) -> one device flow proving R3 on a reopened list
(breadboard V2, depends on V1's wiring existing to have anything to prove).
