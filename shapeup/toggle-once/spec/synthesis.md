---
type: synthesis
feature: toggle-once
---

# Synthesis — toggle-once

## Traceability (requirement -> use case -> screen)

| Requirement | Use case | Screen / rule |
|---|---|---|
| REQ-1 double-tap on an open row marks only that item done | [[UC-01]] | P2 U1 |
| REQ-2 double-tap on a done row marks only that item open | [[UC-01]] | P2 U1 |
| REQ-3 two deliberate taps toggle both items | [[UC-01]] | P2 U1 (INV-03) |
| REQ-4 done sinks below open, unchanged from retro-todo | [[UC-01]] Step 4 | retro-todo `ItemOrder` (frozen) |
| REQ-5 device flow can express a double-tap | [[UC-01]] Step 5, [[integration]] | `scripts/ui-flow.sh` `doubletap` |

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| `doubletap` reuses `ui-flow.sh`'s existing 800ms `settle()` between its two clicks, so the device flow can never trip the fix's own window | high (concrete, spiked) | implement `doubletap` as two clicks with no `settle()` between them, one trailing `settle()` after the pair |
| `ListViewModel` has no injectable `Clock`, so the unit test runs against real wall-clock time | medium | widen the constructor (optional `Clock`, default `SystemClock`), add a settable fake beside `FixedClock` |
| `windowMs` picked without on-device measurement either swallows R3 or misses R1/R2 | medium | prove both directions on the device (TS-01-04..06), not only the fake-clock unit test |
| Fixing this per-row instead of screen-wide misses the reproduced fault (second touch lands on a different row object) | known, ruled out by the pitch's own spike | INV-02: the window belongs to the screen, not any one card |

## Hammered out

Animating the reorder (spike found it costly on this stack); any timing guess not proved on-device
both ways; fixing this inside `ToggleItem` (the fault is which id the second touch reaches, a
screen concern, not the use case) — all pitch No-goes / rabbit holes, not open questions.

## Dependency graph

`Clock` seam + settle-window state in `ListViewModel` (breadboard V1) -> unit test proving both
sides -> `doubletap` step in `ui-flow.sh` (breadboard V2, independent of V1's code but graded
against it) -> device flows for R1, R2, R3.
