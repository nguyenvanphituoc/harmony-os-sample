---
type: ship-report
feature: settle-across-screens
date: 2026-09-29
verdict: PASS
rounds_used: 1
rounds_judged: 1
qa: run
intake_sha256: 81b9208cf5d3350b95b72c0f796d214c2fdcee450119433348bf35213bc5811b
---

# settle-across-screens — ship report

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
| v1-shared-settle-window | 2/2 | — | 1 | kept | baseline |
| v2-cross-screen-device-flow | 2/2 | — | 1 | kept | baseline |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**5/5 PASS** · run `settle-across-screens-20260929T045649Z-4f29bfab`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-1 | shaping/shaping.md R1 | PASS | UC-01: Two `ListViewModel`s are built over one shared `SettleWindow` (mirroring how `TodoModule` | TS-01-01 → PASS | 6e7caec16783, 4ff4799e92ee |
| REQ-2 | shaping/shaping.md R2 | PASS | UC-01: Same two-VM setup: inside the window, a toggle tap on the second VM does not call | TS-01-02 → PASS | 6e7caec16783, 4ff4799e92ee |
| REQ-3 | shaping/shaping.md R3 (split 1/2) | PASS | UC-01: Same two-VM setup, clock advanced past `SETTLE_WINDOW_MS`: a ✕ tap on the second VM opens (+1) | TS-01-03 (+1) → PASS,PASS | 6e7caec16783, 4ff4799e92ee |
| REQ-4 | shaping/shaping.md R4 | PASS | UC-01: Every existing case in `ListViewModel.test.ets` (toggle-once TS-01-01..03, delete-settle's | TS-01-05 → PASS | 6e7caec16783, 4ff4799e92ee |
| REQ-5 | shaping/shaping.md R3 (split 2/2) | PASS | UC-01: Same two-VM setup, clock advanced past `SETTLE_WINDOW_MS`: a toggle tap on the second VM | TS-01-04 → PASS | 6e7caec16783, 4ff4799e92ee |

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

| Criterion | Dimension | Verdict | Confidence | Evidence |
|---|---|---|---|---|
| UC-01 Step 1 — `TodoModule` builds one `SettleWindow` in its own constructor, passes it into every `listViewModel()` call | spec-conformance | PASS | high | `app/entry/src/main/ets/features/todo/TodoModule.ets:64,74,81-85` — `this.window` built once in ctor, threaded into `new ListViewModel(...)` on every call |
| UC-01 Step 2 — `ListViewModel` takes the window as new optional 8th ctor param, builds a private one when absent | spec-conformance | PASS | high | `app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:32,40` |
| UC-01 Step 3 — `onToggle` checks `isSettling` first, ignores inside, executes+marks outside | spec-conformance | PASS | high | `ListViewModel.ets:66-76`; unit test `ListViewModel.test.ets:62-79` (TS-01-01 non-shared) |
| UC-01 Step 4/5 — a new visit's VM reads the same window a prior visit's VM wrote; delete inside window no-ops, outside window opens dialog naming the item | spec-conformance | PASS | high | `ListViewModel.test.ets:188-257` ("shared window" TS-01-01..03) |
| UC-01 Step 6 — toggle inside shared window guarded identically; outside toggles | spec-conformance | PASS | high | `ListViewModel.test.ets:211-232,259-281` ("shared window" TS-01-02/04) |
| UC-01 Step 7 — one-visit behavior unchanged | spec-conformance | PASS | high | pre-existing non-shared cases (`TS-01-01..03`, `delete TS-01-01..03`) still present/passing |
| INV-01 — `SETTLE_WINDOW_MS` stays the one constant, no second added | completeness | PASS | high | `app/entry/src/main/ets/features/todo/domain/SettleWindow.ts:1,7` — one constant, used once |
| INV-02 — exactly one `SettleWindow` per app session, owned by `TodoModule` | completeness | PASS | high | `TodoModule.ets:64,74` — field built once in ctor, never reassigned |
| INV-03 — `mark` called only from `onToggle`'s success path, never from `onDeleteItem` | completeness | PASS | high | `ListViewModel.ets:66-76` (`mark` call) vs `:95-104` (`onDeleteItem`, no `mark` call) |
| INV-04 — a `ListViewModel` built with no window arg builds its own, keeping predates-pitch behavior | completeness | PASS | high | `ListViewModel.ets:40`; non-shared unit tests (`TS-01-01..03`, `delete TS-01-01..03`) pass unmodified |
| INV-05 — `TodoModule.listViewModel()` still constructs a new `ListViewModel` every call, no caching added | completeness | PASS | high | `TodoModule.ets:81-85` — `return new ListViewModel(...)` on every call, no cache field |
| Error Cases — `found === undefined` no-dialog branch reached unchanged | spec-conformance | PASS | high | `ListViewModel.ets:100-103` unchanged lookup-then-guard shape |
| TS-01-01 | test-surface-conformance | PASS | high | `ListViewModel.test.ets:188-209` ("shared window TS-01-01") — toggle on vm1, delete tap on vm2 inside window, `opener.callCount` asserted 0; suite exits 0 via T0 `r1-a1-t1.json` fixture `./scripts/t0-test.sh` |
| TS-01-02 | test-surface-conformance | PASS | high | `ListViewModel.test.ets:211-232` — toggle on vm1, toggle on vm2 inside window, `doneMap` unchanged |
| TS-01-03 | test-surface-conformance | PASS | high | `ListViewModel.test.ets:234-257` — toggle on vm1, delete tap on vm2 past window, dialog opens naming `eggs` |
| TS-01-04 | test-surface-conformance | PASS | high | `ListViewModel.test.ets:259-281` — toggle on vm1, toggle on vm2 past window, `eggsAfter` flips |
| TS-01-05 | test-surface-conformance | PASS | high | every pre-existing non-shared case in `ListViewModel.test.ets` (`TS-01-01..03` non-shared, `delete TS-01-01..03`) still present, unmodified, included in `List.test.ets` aggregator, exits 0 |
| TS-01-06 | test-surface-conformance | PASS | high | T0 artifact the run trace names `"PASS TS-01-06"`; check file `device-flows/v2-cross-screen-device-flow/TS-01-06.flow` (sha256 `f8350ad7…` matches the artifact's `check_files` entry) asserts back→reopen→delete-tap-with-no-prior-toggle opens `confirm.message` naming `"Bread"` — matches the row's Expect exactly |
| tdd-surface — unit + device fixtures both green this round | tdd-surface | PASS | high | both T0 artifacts `overall: green`, `fixtures_passed: 2/2` |
| Non-Go — no caching of `ListViewModel`, no change to window length/second constant, no dialog/screen/persistence change | spec-conformance | PASS | high | `TodoModule.ets:81-85` (no cache); `SettleWindow.ts` (one constant, unchanged value); no diff in `ConfirmDialogHost`/`ItemDeleteOpener`/dialogs |

### Refuted criteria and bugs

None.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ③ state interruption | C-01, C-02 | 1 | 0 |
| ④ cross-UC journey | C-03 | 0 (inconclusive — see session notes) | 0 |

→ finding detail lives in the run trace under the
`## Discovered` section ingest appends for this hunt's order.

### Summary of the one confirmed finding

**[QA-001]** MY LISTS (P1) shows a "done" count badge (e.g. "1/3 done") that goes stale: after
toggling items on the list-detail screen (P2) and returning to P1, the badge does not reflect the
new count, and the wrong count survives a full `aa force-stop` + relaunch of the app — not
merely a screen-navigation refresh gap, but a summary that never resyncs with the underlying item
state. Repro'd twice (once immediately after two toggles + return, once again after cold
relaunch, confirming a live re-check of the same list's actual item states via P2 showed 2/3 done
against a persistently-displayed "1/3 done" on P1).

Not part of this pitch's spec (UC-01 only touches the toggle/delete guard on P2, not P1's summary
rendering) — filed as an edge found on the running app, not a contradiction of any PASSED
criterion.

## Discovered, not built

~ D1 (orient discovered-seed): MAP SCOPES must grant the scope owning ListViewModel.ets/TodoModule.ets a writable flow directory (device-flows/v2-cross-screen-device-flow/) for UC-01's TS-01-06.flow — scripts/ui-flow.sh reads a scope's own directory, not a shared path, and retro-todo run 8 shipped a FAIL when this was missed (probe owner returned null)

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
