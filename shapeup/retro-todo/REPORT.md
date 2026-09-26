---
type: ship-report
feature: retro-todo
date: 2026-09-26
verdict: PASS
rounds_used: 1
rounds_judged: 1
qa: run
intake_sha256: 3bcc3493c9e94b991ed58af6996b5098d2701bd3dced631b8187bf0618a140d3
---

# retro-todo — ship report

Frozen at GATE L4. Every figure below is derived from run artifacts on disk — the trial
ledger, the verdict artifacts, the board — never from a summary of the run.

## Outcome

| | |
|---|---|
| Verdict | **PASS** |
| Rounds used | 1 |
| Rounds judged | 1 |
| Board | 9/9 tasks done |
| T0 artifacts | 4 |
| QA | run |

## Verification (T0)

The surviving trial per scope — the one describing code that is actually on the branch.

| scope | fixtures | regressions | trials | last status | delta |
|---|---|---|---|---|---|
| delete-confirm | 3/3 | — | 1 | kept | baseline |
| list-name | 3/3 | — | 1 | kept | baseline |
| lists-and-open | 3/3 | — | 1 | kept | baseline |
| toggle-and-add | 3/3 | — | 1 | kept | baseline |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**0/28 PASS · 28 no evidence (REQ-0 ← shapeup/retro-todo/shaping/shaping.md R0, REQ-1 ← shapeup/retro-todo/shaping/shaping.md R1, REQ-17 ← shapeup/retro-todo/shaping/shaping.md R1 (split 2/3), …)** · run `retro-todo-20260926T202453Z-1ed75688`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-0 | shapeup/retro-todo/shaping/shaping.md R0 | no evidence | UC-07: With no lists P1 renders the invitation and its create button, never a blank screen; TS-07-03, TS-07-04 (covers: REQ-0) | — | — |
| REQ-1 | shapeup/retro-todo/shaping/shaping.md R1 | no evidence | UC-01: Creating Travel adds a card on top of P1; TS-01-03, TS-01-04 (covers: REQ-1) | — | — |
| REQ-17 | shapeup/retro-todo/shaping/shaping.md R1 (split 2/3) | no evidence | UC-01: SAVE with an empty or whitespace name shows Name can't be empty and the dialog stays; TS-01-01, TS-01-05 (covers: REQ-17) | — | — |
| REQ-18 | shapeup/retro-todo/shaping/shaping.md R1 (split 3/3) | no evidence | UC-01: Creating Travel twice yields two lists with the same name; TS-01-02 (covers: REQ-18) | — | — |
| REQ-2 | shapeup/retro-todo/shaping/shaping.md R2 | no evidence | UC-07: Cold start shows one card per list with its name and progress (Groceries 1/3 done, Work 1/2 done, Weekend No items); TS-07-02, TS-07-05 (covers: REQ-2) | — | — |
| REQ-3 | shapeup/retro-todo/shaping/shaping.md R3 | no evidence | UC-08: Opening Groceries shows only its items and Back returns to P1; TS-08-01, TS-08-02, TS-08-03, TS-08-06 (covers: REQ-3) | — | — |
| REQ-4 | shapeup/retro-todo/shaping/shaping.md R4 | no evidence | UC-03: Deleting Groceries after confirming removes it and its items and leaves other lists; CANCEL keeps it; TS-03-01, TS-03-02, TS-03-03, TS-03-04 (covers: REQ-4) | — | — |
| REQ-16 | shapeup/retro-todo/shaping/shaping.md R16 | no evidence | UC-02: Renaming a list changes its name and keeps id, createdAt and items; TS-02-02, TS-02-03, TS-02-04 (covers: REQ-16) | — | — |
| REQ-19 | shapeup/retro-todo/shaping/shaping.md R16 (split 2/2) | no evidence | UC-02: A blank rename value is refused with a message at the field and the name is unchanged; TS-02-01 (covers: REQ-19) | — | — |
| REQ-5 | shapeup/retro-todo/shaping/shaping.md R5 | no evidence | UC-04: Adding Hike under Weekend shows its card on top and removes the invitation; TS-04-02, TS-04-04 (covers: REQ-5) | — | — |
| REQ-20 | shapeup/retro-todo/shaping/shaping.md R5 (split 2/2) | no evidence | UC-04: ADD on an empty or whitespace field shows Title can't be empty and keeps the text; TS-04-01, TS-04-03 (covers: REQ-20) | — | — |
| REQ-6 | shapeup/retro-todo/shaping/shaping.md R6 | no evidence | UC-05: One tap on an item card marks it done or not done; TS-05-05, TS-05-06 (covers: REQ-6) | — | — |
| REQ-7 | shapeup/retro-todo/shaping/shaping.md R7 | no evidence | UC-08: Sort places every done item after every open item; TS-08-01 (covers: REQ-7) | — | — |
| REQ-21 | shapeup/retro-todo/shaping/shaping.md R7 (split 2/4) | no evidence | UC-05: Within each group createdAt is descending; TS-05-02 (covers: REQ-21) | — | — |
| REQ-22 | shapeup/retro-todo/shaping/shaping.md R7 (split 3/4) | no evidence | UC-05: Toggling Bread to done places it in the done group at its creation-order place, before Buy milk; TS-05-04 (covers: REQ-22) | — | — |
| REQ-23 | shapeup/retro-todo/shaping/shaping.md R7 (split 4/4) | no evidence | UC-05: Toggling Bread again returns it above Buy eggs among open items; TS-05-03 (covers: REQ-23) | — | — |
| REQ-8 | shapeup/retro-todo/shaping/shaping.md R8 | no evidence | UC-08: A done item's text is struck through, exposed as state id `item.done`; TS-08-05 (covers: REQ-8) | — | — |
| REQ-24 | shapeup/retro-todo/shaping/shaping.md R8 (split 2/2) | no evidence | UC-08: A done item's text uses `inkMuted` on `surfaceDone`, a color change beyond the strike-through; TS-08-05 (covers: REQ-24) | — | — |
| REQ-9 | shapeup/retro-todo/shaping/shaping.md R9 | no evidence | UC-06: Deleting Buy milk after confirming removes only that item; CANCEL keeps it; tapping the cross does not toggle; TS-06-01 to TS-06-05 (covers: REQ-9) | — | — |
| REQ-10 | shapeup/retro-todo/shaping/shaping.md R10 | no evidence | UC-08: A list with no items shows `list.emptyInvite` reading No items yet; TS-08-04 (covers: REQ-10) | — | — |
| REQ-11 | shapeup/retro-todo/shaping/shaping.md R11 | no evidence | UC-07: Each list renders as its own card (`lists.card`); TS-07-05 (covers: REQ-11) | — | — |
| REQ-25 | shapeup/retro-todo/shaping/shaping.md R11 (split 2/2) | no evidence | UC-08: Each item renders as its own card (`list.itemCard`) (covers: REQ-25) | — | — |
| REQ-12 | shapeup/retro-todo/shaping/shaping.md R12 | no evidence | UC-07: Text/background pairs, done-item text included, are at least 4.5:1, verified by a script computing ratios from `color.json` (covers: REQ-12) | — | — |
| REQ-26 | shapeup/retro-todo/shaping/shaping.md R12 (split 2/2) | no evidence | UC-07: Card border and check-control colors are at least 3:1 against their background, verified by the same script (covers: REQ-26) | — | — |
| REQ-13 | shapeup/retro-todo/shaping/shaping.md R13 | no evidence | UC-07: One retro style (palette, type, card treatment) is defined once in `color.json`, `float.json` and the uikit kit; no screen hard-codes its own values (covers: REQ-13) | — | — |
| REQ-14 | shapeup/retro-todo/shaping/shaping.md R14 | no evidence | UC-07: `./scripts/t0-test.sh` passes TS-07-01: `seed()` yields the three lists and five items in documented order on every call from a fresh store; the repository keeps data in memory only (covers: REQ-14) | — | — |
| REQ-27 | shapeup/retro-todo/shaping/shaping.md R14 (split 2/2) | no evidence | UC-07: Restart flow (TS-07-06): force-stop and relaunch shows exactly the seed, nothing created earlier survives (covers: REQ-27) | — | — |
| REQ-15 | shapeup/retro-todo/shaping/shaping.md R15 | no evidence | UC-07: Every visible string is defined in `resources/base/element/string.json` in English (covers: REQ-15) | — | — |

## Ratchet

Measured over this run's trial ledger. A monotone series is a ratchet working; a flat or
sawtooth series says the loop is still a budgeted retry loop wearing a ratchet's shape.

| | |
|---|---|
| Trials | 4 across 4 scope(s), 0 with more than one attempt |
| Improvement rate | 0 — kept ÷ trials after the first |
| Monotone rate | 0 — multi-trial scopes whose score never decreased |
| Sawtooth count | 0 — a revert immediately after a keep |
| Mean trials to green | 1 |
| Statuses | kept 4 |

> No scope needed a second attempt, so the rates above are vacuous rather than bad:
> the ratchet was never asked to climb. The Day-1 question — does the loop measurably
> improve across attempts — needs a run where at least one scope retries.

## QA findings

No findings.

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
