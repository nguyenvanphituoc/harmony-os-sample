---
type: integration
feature: list-above-keyboard
---

# Integration — list-above-keyboard

No new cross-system flow, no network, no repository, no persistence change. One layout seam
(window or page container → the list's existing `.layoutWeight(1)`) and one device-tooling
addition (`swipe` in `scripts/ui-flow.sh`) are the entire integration surface.

## In-process chain

| Node | What | Notes |
|---|---|---|
| N1 | Keyboard-avoid setting — `⏳ TBD`, window-level (`EntryAbility.onWindowStageCreate`'s `windowStage`/`getMainWindowSync()`) or page-level (`ListPage.ets`'s outer `Column`/`NavDestination`) | Decided at Wire/Build against the SDK's own `.d.ts` or a device probe (domain-model.md); this is the pitch's only production-code decision |
| — | `ListPage.ets`'s `List({ space: 12 }).layoutWeight(1)` | Unchanged — shrinks for free once N1 shrinks the container above it (INV-01) |
| N2 | `scripts/ui-flow.sh`'s `swipe id "<node>" up\|down` step | New DSL op, added to the existing `if op == …` chain (around line 120 per code-surface.md), resolving its target via the same `find(nodes, kind, value)` lookup `tap`/`doubletap` already use, then driving `hdc shell uitest uiInput swipe <x1> <y1> <x2> <y2>` across the resolved node's bounds |

## Device-flow language

`scripts/ui-flow.sh` already supports `launch`, `tap`, `type`, `doubletap`, `back`, `wait`, and the
`expect` family (`expect`, `expect no`, `expect count`, `expect order`) — this pitch's only gap is
`swipe` (A3). Per the spike (`spike-keyboard-avoid.md`), `uitest dumpLayout` does not model the
keyboard as a resize or an occlusion signal in its **bounds**, so no flow may assert "the list
resized" by diffing bounds pre/post-focus. What the existing tooling already does track (per
`nodes()`'s own `visible` filter in `scripts/ui-flow.sh`, confirmed by the pitch's own repro —
`expect no text "Buy milk"` passes with the keyboard up on today's baseline) is reachable-and-
visible: every device row in UC-01's Test Surface is worded that way (a target's text/id present
or absent, never a bounds comparison).

| Risk | Guard |
|---|---|
| N1 is applied window-wide when page-level would have sufficed, silently reaching P3 in a way that changes its resting position when the keyboard is *not* up | INV-03/INV-04 and TS-01-04/05 catch this — a dialog check runs with the keyboard up either way, and TS-01-03 (keyboard down) would catch a resting-position change on P2/P1 |
| N1 is applied in a way that also changes P2's byte-for-byte layout with no field focused | INV-03; TS-01-03 is the direct guard |
| A device flow for R1/R2 is written as a bounds-diff against `dumpLayout` instead of a reachability check, and silently always passes (or always fails) because the tree never reflects a resize the spike already ruled unreliable | flagged directly (discovered-seed.md D2); UC-01's Test Surface rows are worded reachability-first for exactly this reason |
| `swipe`'s target resolves to the wrong node because multiple items share the same id (`list.itemCard.toggle`, `list.itemCard`) — `find()` returns the first match, same as `tap` today | not a new risk this pitch introduces — `tap`'s existing `nth` parameter already exists for disambiguation; a device flow that needs a specific item swipes from whichever item resolves first and asserts on a *different* target text becoming reachable, not on which node the swipe started from |
| The flow directory this pitch's device checks write into is not granted to the scope that owns `ListPage.ets`/`scripts/ui-flow.sh` | seeded as a risk from prior-run precedent (retro-todo run 8, `probe owner` returning null for `scripts/ui-flow.sh`) — a MAP SCOPES / L1b concern, not fixable in this phase |

## Silent-failure risks specific to this pitch

- Picking N1's concrete API without checking it against the SDK's own `.d.ts` or a device probe —
  KB-OR-001's precedent (prior `docs/` claims about this exact platform contradicted by the
  official API-24 docs) applies here too; domain-model.md marks the symbol `⏳ TBD` explicitly so no
  attempt guesses it from a stale doc.
- Writing an R1/R2 device flow that reads `expect` against `dumpLayout` bounds instead of
  visible-text/id reachability — the spike's finding (bounds don't move) would make such a flow
  either always pass (never actually testing anything) or always fail (asserting a bounds delta
  that a correct fix still won't produce), and neither failure mode surfaces as "the flow is wrong"
  without cross-checking against the spike's own dumps.
