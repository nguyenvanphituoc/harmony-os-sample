---
type: index
feature: lists-badge-sync
lens: standard
appetite: ~1 day
---

# lists-badge-sync — Spec index

The "done" badge on each MY LISTS card stops tracking its list's items once MY LISTS has been
mounted: toggling, adding to, deleting from, or renaming a list is reflected correctly on a fresh
visit to that list, and the underlying store is correct immediately, but the already-mounted MY
LISTS card keeps showing whatever it rendered before (QA-001, settle-across-screens). This pitch
(Shape A) spikes the exact link in the render chain that drops the update and fixes it there —
nothing about the lists screen's layout, the dialogs, the settle window or persistence changes.

Source: the committed shaping in `shapeup/lists-badge-sync/shaping/` (shaping.md, breadboard.md)
and the requirement registry `shapeup/lists-badge-sync/requirements.md`. Orient's recon for this
run (code surface, the on-device spike, discovered-task seed, hill signal) fed this analysis but
is run-tier and not cited here by path.

## Boundaries

In: A1 — naming the exact link in `TodoStore -> ListsViewModel.cards -> Repeat -> cardBuilder ->
AppText` that drops the update on an already-mounted MY LISTS card, with evidence for which check
passes and which fails; A2 — the fix, made at that one link, in the lists screen or its view
model only; A3 — device flows for R1 (the repro), R2 (add/delete) and R3 (rename, card order).

Out (No-goes, frozen by the pitch): any change to the List screen (P2), the dialogs, the settle
window, or persistence; any new state library or pattern beyond the existing V2 decorators;
re-creating `ListsViewModel` on every visit (would hide the bug and change the view model's
lifetime); a manual refresh hook (`onShown`/`aboutToAppear`) that re-reads the store (papers over
the break, only a PO-approved fallback if the spike shows V2 genuinely cannot carry the update);
any new UI copy.

## Document map

| Document | What |
|---|---|
| [[domain-model]] | no new domain concept; the render-layer suspect the spike narrowed (`ListCard`, `cardBuilder`, the `AsyncBoundary` hop) and the candidate structural fix Build confirms |
| [[ux-behavior]] | Screen P1 (My Lists) — the badge's observable contract across toggle/add/delete/rename while the screen stays mounted; Screen P2 unchanged |
| [[UC-01]] | MY LISTS card state (badge count, total, name, order) stays in sync with its list's items and name whenever MY LISTS is on screen, including across a return from an already-mounted List screen |
| [[integration]] | the render chain the spike isolated, the device-flow proof for R4, silent-failure risks |
| [[synthesis]] | traceability, risk register, dependency graph |
| [[feedback]] | PO / TL feedback template |
