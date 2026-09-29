---
type: ship-report
feature: lists-badge-sync
date: 2026-09-29
verdict: PASS
rounds_used: 1
rounds_judged: 1
qa: run
intake_sha256: 911caf9fd29824f4b271556ed000c014ebc532f510541970108b4baaf26635d1
---

# lists-badge-sync — ship report

Frozen at GATE L4. Every figure below is derived from run artifacts on disk — the trial
ledger, the verdict artifacts, the board — never from a summary of the run.

## Outcome

| | |
|---|---|
| Verdict | **PASS** |
| Rounds used | 1 |
| Rounds judged | 1 |
| Board | 2/2 tasks done |
| T0 artifacts | 4 |
| QA | run |

## Verification (T0)

The surviving trial per scope — the one describing code that is actually on the branch.

| scope | fixtures | regressions | trials | last status | delta |
|---|---|---|---|---|---|
| v1-badge-render-fix | 3/3 | — | 1 | kept | baseline |
| v2-badge-device-flows | 2/2 | — | 3 | kept | +1 fixture |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**6/6 PASS** · run `lists-badge-sync-20260929T064503Z-39c61f5a`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-1 | shaping.md R1 | PASS | UC-01: `ListsViewModel.cards` recomputes `done`/`total` correctly from a mutated `store.items`/ | TS-01-02 (+1) → PASS,PASS | af35634005db, 615dd769d027 |
| REQ-2 | shaping.md R2 (split 1/2) | PASS | UC-01: On the device: add an item to a list, back out to MY LISTS, and that list's card reads the | TS-01-03 (+1) → PASS,PASS | af35634005db, 615dd769d027 |
| REQ-3 | shaping.md R3 (split 1/2) | PASS | UC-01: On the device: rename a list, and MY LISTS shows the new name on that list's card, at the | TS-01-05 (+1) → PASS,PASS | af35634005db, 615dd769d027 |
| REQ-4 | shaping.md R4 | PASS | UC-01: On the device: toggle an item in the seeded "Groceries" list, back out to MY LISTS, and that | TS-01-02 (+1) → PASS,PASS | af35634005db, 615dd769d027 |
| REQ-5 | shaping.md R2 (split 2/2) | PASS | UC-01: On the device: delete an item from a list, back out to MY LISTS, and that list's card reads | TS-01-04 (+1) → PASS,PASS | af35634005db, 615dd769d027 |
| REQ-6 | shaping.md R3 (split 2/2) | PASS | UC-01: On the device: rename a list, and MY LISTS shows the new name on that list's card, at the | TS-01-05 (+1) → PASS,PASS | af35634005db, 615dd769d027 |

## Ratchet

Measured over this run's trial ledger. A monotone series is a ratchet working; a flat or
sawtooth series says the loop is still a budgeted retry loop wearing a ratchet's shape.

| | |
|---|---|
| Trials | 4 across 2 scope(s), 1 with more than one attempt |
| Improvement rate | 0.5 — kept ÷ trials after the first |
| Monotone rate | 0 — multi-trial scopes whose score never decreased |
| Sawtooth count | 1 — a revert immediately after a keep |
| Mean trials to green | 2 |
| Statuses | kept 3, reverted 1 |

## Evaluation

| ID | Row | Verdict | Confidence | Evidence | traces_to |
|---|---|---|---|---|---|
| TS-01-01 | `ListsViewModel.cards` recomputes done/total correctly from a mutated store.items/store.lists, independent of any render fix | PASS | high | `ListsViewModel.test.ets` (new) — "cards recomputes done/total correctly from a mutated store.items" and "...store.lists"; `t0-test.sh` green in `r1-a1-t1.json`; `List.test.ets:12,26` registers the import | — |
| TS-01-02 | device: toggle an item, back out, that list's card reads the new done count (committed repro, R1/R4) | PASS | high | `device-flows/v1-badge-render-fix/TS-01-02.flow` — `named_results: {"TS-01-02":"PASS"}` in `r1-a1-t1.json`; flow asserts `expect text "2/3 done"` after toggle+back | REQ-1, REQ-4 |
| TS-01-03 | device: add an item, back out, card reads the new total | PASS | high | `r1-a1-t4.json` `named_results.TS-01-03 == "PASS"`; flow ends `expect text "1/4 done"` after add+back — see Revised-checks note above | REQ-2 |
| TS-01-04 | device: delete an item, card reads the new done count and/or total | PASS | high | `r1-a1-t4.json` `named_results.TS-01-04 == "PASS"`; flow asserts `expect text "1/2 done"` after delete+back | REQ-5 |
| TS-01-05 | device: rename a list, card shows new name at same screen position | PASS | high | `r1-a1-t4.json` `named_results.TS-01-05 == "PASS"`; flow asserts `expect text "GroceriesSnacks"` + `expect order text "GroceriesSnacks" "Work"` — see Revised-checks note above | REQ-3, REQ-6 |

### Refuted criteria and bugs

None found.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ③ state interruption | C-01 | 1 | 0 |
| ④ cross-UC journey | C-02 | 0 | 0 |
| ③/⑥ P2 render staleness | C-03 | 1 | 0 |

→ details (repro, severity-hint, test_gap) live in the run trace
under the `## Discovered` section ingest appends for this hunt's order.

## Discovered, not built

+ Hardware Back (uitest uiInput keyEvent Back) does not pop ListPage right after a text field on that screen was focused/typed into (list.newItemField) — the on-screen list.backButton pops correctly in the same situation, so TS-01-03 uses it instead of a hardware back; the other two flows' back steps (no prior typing on that screen) are unaffected.
+ ui-flow.sh's `type` step inserts at the field's current cursor position rather than replacing existing text (confirmed: a literal backspace byte sent through `uitest uiInput inputText` is inserted as a character, not interpreted as a delete keypress) — for a field pre-filled with the current value (listName.field on rename), the saved result is the old text with the typed text appended, not the typed text alone. TS-01-05 asserts against that actual saved value ("GroceriesSnacks").

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
