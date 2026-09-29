---
type: ship-report
feature: list-above-keyboard
date: 2026-09-29
verdict: PASS
rounds_used: 3
rounds_judged: 3
qa: run
intake_sha256: 15a9dc87505b597df252849e7d5174684124506075d0677db553a7c17aed1ccd
---

# list-above-keyboard — ship report

Frozen at GATE L4. Every figure below is derived from run artifacts on disk — the trial
ledger, the verdict artifacts, the board — never from a summary of the run.

## Outcome

| | |
|---|---|
| Verdict | **PASS** |
| Rounds used | 3 |
| Rounds judged | 3 |
| Board | 4/4 tasks done |
| T0 artifacts | 5 |
| QA | run |

## Verification (T0)

The surviving trial per scope — the one describing code that is actually on the branch.

| scope | fixtures | regressions | trials | last status | delta |
|---|---|---|---|---|---|
| v1-list-resize-above-keyboard | 2/2 | — | 2 | kept | +1 fixture |
| v2-dialog-keyboard-visibility | 2/2 | — | 3 | kept | no change |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**5/5 PASS** · run `list-above-keyboard-20260929T080442Z-50fdd025`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-1 | `shapeup/list-above-keyboard/shaping/shaping.md` R1 | PASS | UC-01: With `list.newItemField` focused (keyboard up) on the seeded "Groceries" list, a swipe on the | TS-01-01 (+5) → FAIL,FAIL,FAIL,FAIL,PASS,PASS | 3a10812fef7b, 98cd29868e80, d2fd9ce8a9a4, 44008d413cb3 |
| REQ-2 | `shapeup/list-above-keyboard/shaping/shaping.md` R2 | PASS | UC-01: With the keyboard up, adding a new item ("Batteries") via `list.addButton` shows the new | TS-01-02 (+5) → FAIL,FAIL,FAIL,FAIL,PASS,PASS | 3a10812fef7b, 98cd29868e80, d2fd9ce8a9a4, 44008d413cb3 |
| REQ-3 | `shapeup/list-above-keyboard/shaping/shaping.md` R3 | PASS | UC-01: With no field focused, the seeded "Groceries" list (`list.itemCard`, `list.title`) and the | TS-01-03 (+7) → FAIL,FAIL,FAIL,FAIL,FAIL,FAIL,PASS,PASS | 3a10812fef7b, 98cd29868e80, d2fd9ce8a9a4, 44008d413cb3 |
| REQ-4 | `shapeup/list-above-keyboard/shaping/shaping.md` R4 | PASS | UC-01: Opening the rename dialog (`lists.renameButton`) and focusing `listName.field` (keyboard up) (+1) | TS-01-04 (+10) → PASS,PASS,PASS,PASS,PASS,PASS,PASS,PASS,PASS,PASS,PASS | 3a10812fef7b, 98cd29868e80, d2fd9ce8a9a4, 44008d413cb3 |
| REQ-5 | `shapeup/list-above-keyboard/shaping/shaping.md` R5 | PASS | UC-01: `scripts/ui-flow.sh` parses a `swipe id "<node>" up\|down` step, resolving `<node>` via the (+1) | TS-01-06 (+7) → FAIL,FAIL,PASS,FAIL,FAIL,PASS,PASS,PASS | 3a10812fef7b, 98cd29868e80, d2fd9ce8a9a4, 44008d413cb3 |

## Ratchet

Measured over this run's trial ledger. A monotone series is a ratchet working; a flat or
sawtooth series says the loop is still a budgeted retry loop wearing a ratchet's shape.

| | |
|---|---|
| Trials | 5 across 2 scope(s), 2 with more than one attempt |
| Improvement rate | 1 — kept ÷ trials after the first |
| Monotone rate | 1 — multi-trial scopes whose score never decreased |
| Sawtooth count | 0 — a revert immediately after a keep |
| Mean trials to green | 1.5 |
| Statuses | kept 5 |

## Evaluation

| Criterion | Dimension | Verdict | Confidence | Evidence | traces_to |
|---|---|---|---|---|---|
| UC-01 Step 1 (N1 — keyboard-avoid setting applied) | spec-conformance | PASS | high | `app/entry/src/main/ets/entryability/EntryAbility.ets:27` — `uiCtx.setKeyboardAvoidMode(KeyboardAvoidMode.RESIZE)`; `t0/verdicts/r3-a1-t1.json` fixture `./scripts/t0-assemble.sh` BUILD SUCCESSFUL | [] |
| UC-01 Step 2 (R1 — swipe reveals done item) | spec-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-01 = PASS; `device-flows/v1-list-resize-above-keyboard/TS-01-01.flow` | [REQ-1] |
| UC-01 Step 3 (R2 — add while keyboard up, still reachable) | spec-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-02 = PASS; `device-flows/v1-list-resize-above-keyboard/TS-01-02.flow` | [REQ-2] |
| UC-01 Step 4 (R3 — idle state unchanged) | spec-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-03 = PASS; `device-flows/v1-list-resize-above-keyboard/TS-01-03.flow` | [REQ-3] |
| UC-01 Step 5 (R4 — dialogs stay visible) | spec-conformance | PASS | high | `t0/verdicts/r3-a1-t2.json` named_results TS-01-04/TS-01-05 = PASS | [REQ-4] |
| UC-01 Step 6 (R5 — swipe device step exercised) | spec-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-06 = PASS; `device-flows/v1-list-resize-above-keyboard/TS-01-06.flow` | [REQ-5] |
| TS-01-01 (swipe reveals done item above keyboard, P2) | test-surface-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-01 = PASS, check-file sha256 recomputed match | [REQ-1] |
| TS-01-02 (add item while keyboard up, still reachable) | test-surface-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-02 = PASS, check-file sha256 recomputed match | [REQ-2] |
| TS-01-03 (idle state unchanged, keyboard closed) | test-surface-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-03 = PASS, check-file sha256 recomputed match | [REQ-3] |
| TS-01-04 (rename dialog stays visible, keyboard up) | test-surface-conformance | PASS | high | `t0/verdicts/r3-a1-t2.json` named_results.TS-01-04 = PASS, check-file sha256 recomputed match | [REQ-4] |
| TS-01-05 (new-list dialog stays visible, keyboard up) | test-surface-conformance | PASS | high | `t0/verdicts/r3-a1-t2.json` named_results.TS-01-05 = PASS, check-file sha256 recomputed match | [REQ-4] |
| TS-01-06 (`swipe` step interpreter, ui-flow.sh) | test-surface-conformance | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-06 = PASS, check-file sha256 recomputed match; `device-flows/v1-list-resize-above-keyboard/TS-01-06.flow` now present (was missing round 2) | [REQ-5] |
| INV-01 (List's own layout code unchanged) | completeness | PASS | high | `git diff --stat HEAD` — `ListPage.ets` not in the changed-file list; block byte-for-byte unchanged | [] |
| INV-02 (item order/add/toggle/delete unchanged) | completeness | PASS | high | no diff touching `AddItem`/`ToggleItem`/delete domain-logic files | [] |
| INV-03 (idle layout byte-for-byte, R3) | completeness | PASS | high | `t0/verdicts/r3-a1-t1.json` named_results.TS-01-03 = PASS (idle-state device proof) | [] |
| INV-04 (P3 stays fully visible, R4) | completeness | PASS | high | `t0/verdicts/r3-a1-t2.json` named_results TS-01-04/TS-01-05 = PASS | [] |
| INV-05 (swipe resolves via existing find()) | completeness | PASS | high | `scripts/ui-flow.sh` diff — swipe op reuses `find(ns, kind, value)`, no new lookup mechanism; `t0/verdicts/r3-a1-t1.json` named_results.TS-01-06 = PASS | [] |
| T0 discipline — v1-list-resize-above-keyboard (round-scoped fixture green) | tdd-surface | PASS | high | the run trace, `overall: green`, both fixtures pass, 4/4 named flows pass | [] |
| T0 discipline — v2-dialog-keyboard-visibility (round-scoped fixture green) | tdd-surface | PASS | high | the run trace, `overall: green`, both fixtures pass, 2/2 named flows pass | [] |

`traces_to` on the UC-01 step and Test Surface rows above is copied from each row's own
`(covers: REQ-…)` clause as it appears on the run trace board task`,
`a board task` and `a board task`'s acceptance criteria (TS-01-01→REQ-1, TS-01-02→REQ-2,
TS-01-03→REQ-3, TS-01-04/05→REQ-4, TS-01-06→REQ-5) — the invariant/T0-discipline rows carry no
`covers:` clause of their own and are left with an empty `traces_to`.

### Refuted criteria and bugs

None. All 19 graded criteria (6 UC-01 steps, 6 Test Surface rows, 5 invariants, 2 T0-discipline
rows) PASS with high confidence and re-probable evidence.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ① Boundary | C-01, C-04 | 0 | 0 |
| ② Concurrency | C-05 | 0 | 0 |
| ③ State interruption | C-02, C-03 | 0 | 0 |
| ④ Cross-UC journey | C-04 | 0 | 0 |
| ⑤ No-go probing | — | not chartered (no access-control/no-go route in this pitch beyond the unchanged-domain-logic invariant, itself exercised incidentally by C-05) | — |
| ⑥ Data residue | — | not hunted (hammered out for time) | — |

No findings this round — nothing added to `discovery/ledger.md`.

## Discovered, not built

~ the flow directory this pitch's device checks write into (device-flows/v1-list-resize-above-keyboard/, device-flows/v2-dialog-keyboard-visibility/) may not be granted to the scope that owns ListPage.ets/scripts/ui-flow.sh — retro-todo run 8 hit the same probe-owner-null failure for a different script; carry to L1b's substrate-disjointness lint as a scope-cut check

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
