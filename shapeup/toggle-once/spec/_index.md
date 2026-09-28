---
type: index
feature: toggle-once
lens: standard
appetite: ~2 days
---

# toggle-once — Spec index

A small fix inside retro-todo's List screen (P2): one tap on a to-do toggles that to-do, and only
that one. Today a quick double-tap on an open item's row marks two items done — the item touched
and the item that slid into its place, because the list re-sorts on the same frame and a second
touch at the same screen coordinates lands on a different item (QA-102). The fix is a short,
named settle window in `ListViewModel`, screen-wide, not per-row; the device flow language gains a
`doubletap` step so R1/R2 are graded on the emulator and not only in a unit test.

Source: the committed shaping in `shapeup/toggle-once/shaping/` (shaping.md, breadboard.md) and
the requirement registry `shapeup/toggle-once/requirements.md`. Orient's recon for this run (code
surface, the settle-window timing spike, discovered-task seed, hill signal) fed this analysis but
is run-tier and not cited here by path.

## Boundaries

In: a settle window in `ListViewModel` that ignores further toggles for a short, named window
after one fires; a settable fake `Clock` seam for the unit test; a `doubletap` step in
`scripts/ui-flow.sh`; device flows proving R1, R2, R3 on the emulator.

Out (No-goes, frozen by the pitch): animating the reorder; any change to the list screen's layout,
dialogs, or persistence; any change to retro-todo's spec or its Test Surface rows (`shapeup/retro-
todo/spec/**` stays untouched); fixing this in `ToggleItem` (it is correct — the fault is which id
the second touch reaches, a screen concern).

## Document map

| Document | What |
|---|---|
| [[domain-model]] | why this pitch adds no domain aggregate — the settle window is a screen policy |
| [[ux-behavior]] | Screen P2 (List) — the guarded toggle affordance, unchanged states |
| [[UC-01]] | Toggle an item guarded by a settle window |
| [[integration]] | ViewModel -> Clock chain, `ui-flow.sh` `doubletap` step, silent-failure risks |
| [[synthesis]] | traceability, risk register, dependency graph |
| [[feedback]] | PO / TL feedback template |
