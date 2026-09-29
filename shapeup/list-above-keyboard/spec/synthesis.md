---
type: synthesis
feature: list-above-keyboard
---

# Synthesis — list-above-keyboard

## Traceability (requirement -> use case -> screen)

| Requirement | Use case | Screen / rule |
|---|---|---|
| REQ-1 with the field focused, the list occupies only the space above the keyboard and scrolling reaches the last item | [[UC-01]] Steps 1-2 | P2 U1, U3 |
| REQ-2 after adding an item with the keyboard up, the new item is visible and every done item stays reachable by scrolling | [[UC-01]] Step 3 | P2 U2 |
| REQ-3 with the keyboard closed, the list screen and My Lists render exactly as today | [[UC-01]] Step 4, INV-03 | P1, P2 |
| REQ-4 the list-name dialogs stay fully visible with the keyboard up | [[UC-01]] Step 5, INV-04 | P3 U4 |
| REQ-5 the device check language can scroll a list, so R1/R2 are graded on the emulator | [[UC-01]] Step 6, INV-05 | N2 |

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| The concrete keyboard-avoid API (N1) is guessed from a stale `docs/` claim instead of verified against the SDK's own `.d.ts` or a device probe | moderate — KB-OR-001 has flagged this exact platform's docs wrong before | domain-model.md marks N1 `⏳ TBD` explicitly rather than naming a symbol; Wire/Build verifies before committing to it |
| N1 is applied window-wide when page-level suffices, unintentionally reaching P3 and changing its resting (keyboard-down) position | low-moderate, unconfirmed by the spike either way | INV-03/INV-04, TS-01-03/04/05 all check both keyboard states on both screens |
| A device flow for R1/R2 is built on a `dumpLayout` bounds diff, which the spike found does not move for the keyboard | real, already seen in this project (the pitch's own hunter misread a covered item as vanished) | UC-01's Test Surface rows are worded reachability-first (text/id present or absent), never bounds-based |
| `scripts/ui-flow.sh`'s flow directory for this pitch is not granted to the scope that owns `ListPage.ets` — the exact failure retro-todo run 8 hit for a different script | known and flagged (discovered-seed.md D3) | not fixable here — carried to L1b's substrate-disjointness lint as a scope-cut check |
| The breadboard's `listname.field` id (lowercase n) is used verbatim in a device flow instead of the shipped `listName.field` (capital N) | real, already found by orient | discovered-seed.md D1; this spec's ux-behavior.md and UC-01 use the code's casing throughout |

## Hammered out

Scrolling the new item into view (shaping.md Rabbit Holes) — the new item already lands at the top
of the open items, unaffected by this pitch; the Done-key-on-empty-field message (seen during the
repro, shaping.md Rabbit Holes) — a separate question, not this pitch; any change to sorting,
adding, toggling or deleting, a custom keyboard, auto-hiding the keyboard after ADD, or any change
to My Lists beyond R3 — all pitch No-goes, not open questions; picking N1's concrete API in this
phase — left `⏳ TBD` for Wire/Build per the two-pass contract rule, because the spike could not
reach the official docs or the local SDK's `.d.ts` from its sandboxed run.

## Dependency graph

Zero keyboard-avoid setting today (spike-keyboard-avoid.md: clean-zero baseline confirmed) ->
Wire/Build picks N1's concrete API against the SDK/docs (breadboard V1) -> N1 applied above P2's
`List`, which shrinks via its existing `.layoutWeight(1)` with no code change of its own (V1) ->
`scripts/ui-flow.sh` gains the `swipe` step (V1, independent of N1 — device-tooling only) ->
device flows for R1, R2, R3 (V1, depend on both N1 being applied and `swipe` existing) -> device
flow for R4 on P3 (breadboard V2, depends on N1 being decided to have anything meaningful to
verify against).
