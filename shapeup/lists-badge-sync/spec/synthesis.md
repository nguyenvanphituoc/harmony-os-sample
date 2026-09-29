---
type: synthesis
feature: lists-badge-sync
---

# Synthesis — lists-badge-sync

## Traceability (requirement -> use case -> screen)

| Requirement | Use case | Screen / rule |
|---|---|---|
| REQ-1 toggling an item and going back shows the new done count | [[UC-01]] Step 4, TS-01-02 | P1 U1 |
| REQ-2 adding an item and going back shows the new total | [[UC-01]] Step 4, TS-01-03 | P1 U1 |
| REQ-3 renaming a list updates its card's name | [[UC-01]] Step 4, TS-01-05 | P1 U1 |
| REQ-4 the device repro flow is committed and passes | [[UC-01]] Step 6, TS-01-02 | P1 U1 |
| REQ-5 deleting an item shows the new done count/total, as applicable | [[UC-01]] Step 4, TS-01-04 | P1 U1 |
| REQ-6 renaming a list does not change card order | [[UC-01]] Step 5, INV-03, TS-01-05 | P1 (card order) |

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| A1 is not actually confirmed before A2 lands — the fix patches whatever makes the toggle repro pass without isolating the real link | the pitch's core risk, named in its own Rabbit Holes | domain-model.md scopes A2 to the link A1 names; TS-01-03..05 (add/delete/rename) fail independently of TS-01-02 if the fix only happens to cover toggle |
| The fix touches `ListsViewModel.cards`'s computation instead of only the render layer | low (spike: `cards` already reads correctly on a fresh mount) | INV-01/INV-04 name the computation frozen; TS-01-01 regression-guards it |
| The device-flow fixture directory is not granted to the scope that owns the lists screen, repeating a prior run's `probe owner: null` failure | known and flagged (orient's discovered-task seed) | not fixable here — carried to L1b's substrate-disjointness lint as a scope-cut check |
| A re-keying or lifecycle mistake in the candidate fix (a `@ComponentV2` sub-component keyed wrong) shows up as flicker or reordering rather than a clean pass/fail | low, but not zero given the render-layer change | the device flows' repeated-visit shape (open the same list more than once) would surface this as a visibly wrong card order, not silently |

## Hammered out

Re-creating `ListsViewModel` on every visit (shaping.md Rabbit Holes) — would hide the bug and
change the view model's lifetime, a behavior change nobody asked for; a manual refresh hook
(`onShown`/`aboutToAppear`) that re-reads the store (Rabbit Holes) — papers over the break and
still leaves the card wrong while it is on screen, only a PO-approved fallback if the spike shows
V2 genuinely cannot carry the update, which it has not; any change to the list screen, the
dialogs, the settle window, persistence, or new UI copy — all pitch No-goes, not open questions.

## Dependency graph

`store.items`/`store.lists` mutations (unchanged, toggle-once/delete-settle/settle-across-screens
already built) -> `ListsViewModel.cards` recomputing a fresh `ListCard[]` on every read (already
correct, confirmed by the spike) -> A1 names the render-layer link that drops the update on an
already-mounted P1 (breadboard V1) -> A2 fixes that link, in `ListsPage.ets`/`ListsViewModel.ets`
only (breadboard V1) -> the device flow for R1/R4 proves it (breadboard V1) -> device flows for
R2/R5 (add/delete) and R3/R6 (rename, card order) prove the same fix covers every store-change
path, not only toggle (breadboard V2, depends on V1's fix existing to have anything to prove).
