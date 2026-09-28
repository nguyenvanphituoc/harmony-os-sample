---
type: ship-report
feature: toggle-once
date: 2026-09-28
verdict: PASS
rounds_used: 1
rounds_judged: 1
qa: run
intake_sha256: 53584f8cd022429f671b2a1339f9924bf01b41da5a48a0e2aa29459fa3f73615
---

# toggle-once — ship report

Frozen at GATE L4. Every figure below is derived from run artifacts on disk — the trial
ledger, the verdict artifacts, the board — never from a summary of the run.

## Outcome

| | |
|---|---|
| Verdict | **PASS** |
| Rounds used | 1 |
| Rounds judged | 1 |
| Board | 2/2 tasks done |
| T0 artifacts | 2 |
| QA | run |

## Verification (T0)

The surviving trial per scope — the one describing code that is actually on the branch.

| scope | fixtures | regressions | trials | last status | delta |
|---|---|---|---|---|---|
| v1-settle-window | 2/2 | — | 1 | kept | baseline |
| v2-device-flow | 2/2 | — | 1 | kept | baseline |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**5/5 PASS** · run `toggle-once-20260928T111133Z-3f49258a`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-1 | shaping.md R1 | PASS | UC-01: `ListViewModel` gains a `SettleWindow` (domain-model.md: `lastToggleAt: number \| null`, (+1) | TS-01-01 (+1) → PASS,PASS | f5779bab0a0c, 0346afffb2d2 |
| REQ-2 | shaping.md R2 | PASS | UC-01: `ListViewModel` gains a `SettleWindow` (domain-model.md: `lastToggleAt: number \| null`, (+1) | TS-01-01 (+1) → PASS,PASS | f5779bab0a0c, 0346afffb2d2 |
| REQ-3 | shaping.md R3 | PASS | UC-01: A call to `onToggle` for a *different* itemId inside the open window is also ignored — the (+2) | TS-01-02 (+2) → PASS,PASS,PASS | f5779bab0a0c, 0346afffb2d2 |
| REQ-4 | shaping.md R4 | PASS | UC-01: `ToggleItem.execute`'s existing re-sort (`ItemOrder`, retro-todo UC-05) is unchanged by this (+1) | TS-01-07 (+1) → PASS,PASS | f5779bab0a0c, 0346afffb2d2 |
| REQ-5 | shaping.md R5 | PASS | UC-01: `scripts/ui-flow.sh` dispatches a new `doubletap` step to two `uitest uiInput click` calls | doubletap step composition (one trailing settle) → PASS | f5779bab0a0c, 0346afffb2d2 |

## Ratchet

Measured over this run's trial ledger. A monotone series is a ratchet working; a flat or
sawtooth series says the loop is still a budgeted retry loop wearing a ratchet's shape.

| | |
|---|---|
| Trials | 2 across 2 scope(s), 0 with more than one attempt |
| Improvement rate | 0 — kept ÷ trials after the first |
| Monotone rate | 0 — multi-trial scopes whose score never decreased |
| Sawtooth count | 0 — a revert immediately after a keep |
| Mean trials to green | 1 |
| Statuses | kept 2 |

> No scope needed a second attempt, so the rates above are vacuous rather than bad:
> the ratchet was never asked to climb. The Day-1 question — does the loop measurably
> improve across attempts — needs a run where at least one scope retries.

## Evaluation

| Criterion | Dimension | Verdict | Confidence | Evidence | traces_to |
|---|---|---|---|---|---|
| TS-01-01 second `onToggle` within `windowMs` is a no-op | spec-conformance | PASS | high | Named PASS in T0 artifact t1 (fixture `./scripts/t0-test.sh`, exit 0); check `app/entry/src/test/ListViewModel.test.ets:52` asserts `doneMap` unchanged after a second call at t=1100 (< windowMs=400 boundary read against t=1000) — matches INV-01/INV-04 | [REQ-1, REQ-2] |
| TS-01-02 `onToggle` at/after `windowMs` calls `ToggleItem` again | spec-conformance | PASS | high | `ListViewModel.test.ets:63-77`: t=1000 then t=1400 (≥400ms later) flips `done` again (`afterSecond === !afterFirst`); fixture green in t1 | [REQ-3] |
| TS-01-03 window guards a different itemId, screen-wide | spec-conformance | PASS | high | `ListViewModel.test.ets:79-95`: toggle Bread at t=1000, toggle Buy eggs at t=1100 (inside window) — `doneMap` unchanged; `ListViewModel.isSettling` (`ListViewModel.ets:67-69`) keys off a single `lastToggleAt` field, not per-item, confirming INV-02 | [REQ-3] |
| TS-01-04 live double-tap on Bread marks only Bread done | spec-conformance | PASS | high | Named PASS in T0 artifact t2 (`ui-flow.sh device-flows/v2-device-flow`, exit 0); `device-flows/v2-device-flow/TS-01-04.flow` (sha256 `99c9f286…` matches `check_files` in t2) asserts item.done 1→2, item.open 2→1, Buy eggs still present | [REQ-1] |
| TS-01-05 live double-tap on a done row reopens only that row | spec-conformance | PASS | high | Named PASS TS-01-05 in T0 artifact t2; `TS-01-05.flow` sha256 matches `check_files` | [REQ-2] |
| TS-01-06 two deliberate taps toggle both rows | spec-conformance | PASS | high | Named PASS TS-01-06 in T0 artifact t2; `TS-01-06.flow` sha256 matches; two plain `tap` steps use the existing per-action `settle()` (spaced beyond `windowMs`) | [REQ-3] |
| TS-01-07 toggle moves the card immediately, no reorder animation | spec-conformance | PASS | high | Named PASS TS-01-07 in T0 artifact t2; `TS-01-07.flow` sha256 matches; retro-todo's `ItemOrder`/re-sort untouched (frozen, not re-graded) | [REQ-4] |
| `doubletap` step: two clicks, no settle between, one trailing settle | spec-conformance | PASS | high | `scripts/ui-flow.sh:120-132`: `doubletap` branch issues two `sh(...uitest uiInput click...)` calls back-to-back then one `settle()` before `continue` — matches `tap`'s one-trailing-settle composition | [REQ-5] |
| `ToggleItem`/domain layer unchanged (frozen) | spec-conformance | PASS | high | `app/entry/src/main/ets/features/todo/domain/**` shows no diff for this feature (git status: only `TodoModule.ets`, `ListViewModel.ets`, `List.test.ets`, `ListViewModel.test.ets`, `scripts/ui-flow.sh` touched) | [REQ-4] |
| Non-Go: no change to list-screen layout/dialogs/persistence, no reorder animation added | spec-conformance | PASS | high | Diff confined to settle-window logic, Clock port, and test/device-flow additions; no animation code introduced | [] |

### Refuted criteria and bugs

None.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ②concurrency | C-01 | 0 | 0 |
| ④cross-UC journey | C-02 | 1 | 0 |
| ③state interruption | C-03 | 0 (charter exhausted time with open scent) | 0 |

→ finding detail lives in the run trace under the `## Discovered`
  section ingest appends for this hunt's order.

### C-01 — rapid triple/quad tap (no finding)

Baseline single tap on Bread (open→done) followed by 3 more rapid taps on the same screen
position: only the first tap toggled state; taps 2–4 landed inside the still-open window and
were no-ops (`✓ Bread` after 4 taps total, matching a single toggle). Consistent with
INV-01/INV-04 as already graded by TS-01-01 — no new territory found here beyond what EVAL
covered; closing this charter with no finding.

### C-02 — toggle then tap the old position of a delete control (confirmed finding)

1. Groceries list open, rows in order: Bread (done), Buy eggs (open), Buy milk (done).
2. Tap "Buy eggs" text (toggles it — no-animation re-sort fires immediately per TS-01-07).
3. Immediately tap the screen coordinates where Buy eggs' own "✕" control was rendered
   *before* step 2's re-sort (same (x,y), no wait).
4. Result: a delete-confirmation dialog appears reading `Delete "Bread"?` — the tap in step 3
   landed on Bread's "✕", not Buy eggs', because the animation-free re-sort moved a different
   row under that exact position between the two taps.
5. Dialog cancelled (CANCEL tapped) to leave app state unmodified; final state confirmed via
   `uitest dumpLayout` — all 3 items intact, none deleted.

This is a live, reproduced hazard: any rapid second tap aimed at a screen position right after
a toggle can act on whichever row the instantaneous re-sort put there, not the row the user was
looking at — for the delete control specifically, that is a wrong-item deletion one CANCEL away
from being real. TS-01-07 graded PASS on "the card moves immediately" as a fact; it did not
probe what a co-located control now sitting under a stale tap position does — that is the gap
this charter was chartered for.

### C-03 — background/foreground mid-window (not completed)

Time-boxed session ended before a clean repro of any state-interruption scenario around
`lastToggleAt` surviving an `onWillHide`/`onShown` cycle could be captured; noted here as an
open scent rather than logged as a finding (no repro = no finding, per the hunt's own rule).
Worth a follow-up hunt session.

## Discovered, not built

~ [lens:④cross-UC journey] [QA-001] [UC-01] Toggling a row re-sorts the list instantly (no animation, TS-01-07); a second tap immediately aimed at the previous screen position of that row's delete control ("✕") lands on a different row that the re-sort moved underneath it, opening that other row's delete-confirmation dialog instead
    repro: 1. Groceries list: Bread=done, Buy eggs=open, Buy milk=done. 2. Tap 'Buy eggs' text row to toggle it (triggers immediate re-sort per TS-01-07). 3. Without waiting, tap the exact (x,y) where Buy eggs' own '✕' control was rendered before step 2. 4. Observe: a 'Delete "Bread"?' confirmation dialog appears — the tap hit Bread's '✕', which the re-sort moved into that position, not Buy eggs'. 5. Cancel the dialog; confirm via uitest dumpLayout that all 3 items remain.
    severity-hint: data-integrity
    test-gap: exploratory-only

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
