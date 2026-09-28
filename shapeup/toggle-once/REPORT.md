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

**0/5 PASS · 5 no evidence (REQ-1 ← shaping.md R1, REQ-2 ← shaping.md R2, REQ-3 ← shaping.md R3, …)** · run `toggle-once-20260928T114548Z-e2675ab4`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-1 | shaping.md R1 | no evidence | UC-01: A second `onToggle` call within `windowMs` of the first does not call `ToggleItem.execute` (+1) | — | — |
| REQ-2 | shaping.md R2 | no evidence | UC-01: A second `onToggle` call within `windowMs` of the first does not call `ToggleItem.execute` (+1) | — | — |
| REQ-3 | shaping.md R3 | no evidence | UC-01: The window guards the whole screen, not one row: a second `onToggle` call for a *different* (+1) | — | — |
| REQ-4 | shaping.md R4 | no evidence | UC-01: After a call that does reach `ToggleItem`, the items list re-sorts so done items sink below (+1) | — | — |
| REQ-5 | shaping.md R5 | no evidence | UC-01: `ui-flow.sh` accepts a `doubletap` step: two clicks on the same node with no `settle()` | — | — |

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

| Criterion | Probe | Verdict | Confidence | Evidence |
|---|---|---|---|---|
| INV-01 — windowMs is one named constant, chosen once, not per-call | [cmd] | PASS | high | `SETTLE_WINDOW_MS: number = 400` declared once at module scope; `readonly windowMs = SETTLE_WINDOW_MS` set once in the constructor — app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:12,28 |
| INV-02 — window is screen-wide, not per-row | [cmd] | PASS | high | `lastToggleAt`/`isSettling` are instance fields on `ListViewModel`, not keyed by `itemId` — a settling window opened by one row's tap blocks every row's `onToggle` — app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:27,67-69 |
| INV-03 — a tap outside the window always reaches ToggleItem | [cmd] | PASS | high | `onToggle` calls `this.toggleItem.execute(itemId)` whenever `isSettling(now)` is false, unconditionally on itemId — app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:71-81 |
| INV-04 — an ignored tap changes no state and surfaces nothing | [cmd] | PASS | high | the `isSettling` branch is a bare `return;` — no state write, no nav call, no dialog — app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:76-78 |
| TS-01-01 — second onToggle within windowMs does not call ToggleItem again | [cmd] (T0 unit fixture) | PASS | high | `./scripts/t0-test.sh` exit 0 within the run trace; source assertion at app/entry/src/test/ListViewModel.test.ets:49-66 asserts `doneMap` unchanged after a second tap at clock 1100 (100ms after the first, inside 400ms window) |
| TS-01-02 — onToggle at/after windowMs calls ToggleItem again | [cmd] (T0 unit fixture) | PASS | high | same T0 fixture, green; app/entry/src/test/ListViewModel.test.ets:68-86 asserts `afterSecond === !afterFirst` at clock 1400 (400ms after the first, at the window boundary) |
| TS-01-03 — window guards a call for a different itemId in the same window | [cmd] (T0 unit fixture) | PASS | high | same T0 fixture, green; app/entry/src/test/ListViewModel.test.ets:88-106 asserts Bread's toggle at 1000 is unaffected by an eggs-tap at 1100 |
| TS-01-04 — live double-tap on Bread marks only Bread done; Buy eggs unaffected (REQ-1) | [ui] (named T0 device fixture) | PASS | high | `device-flows/v2-device-flow/TS-01-04.flow` sha256 `99c9f286a9ed4c5ea37c3d65933d012f190eaab99d2b0aa1667bace166240e8b` matches the check_files entry recorded in the run trace; `named_results.TS-01-04 = PASS`; the flow's own Expect (done count 1→2, open count 2→1, Buy eggs still present) matches the row |
| TS-01-05 — live double-tap on a done row marks only that row open again (REQ-2) | [ui] (named T0 device fixture) | PASS | high | `device-flows/v2-device-flow/TS-01-05.flow` sha256 `88a56092a936ab755ccaf497ae0288b49a5c0e09c074eb682d33646b84f67aea` matches; `named_results.TS-01-05 = PASS`; flow's Expect (done count 1→0, open count 2→3) matches the row |
| TS-01-06 — two deliberate taps on two different rows toggle both (REQ-3) | [ui] (named T0 device fixture) | PASS | high | `device-flows/v2-device-flow/TS-01-06.flow` sha256 `04aa6f216ebc405075806452133a4f35db6f21ca7cad8277663531db6d260b07` matches; `named_results.TS-01-06 = PASS`; flow uses two separate `tap` steps (each with its own trailing `settle()`, ~800ms apart), matching "spaced at a normal pace"; Expect (done count 1→3, open count 2→0) matches the row |
| TS-01-07 — after a toggle, card moves immediately, done items stay below open, no animation (REQ-4) | [ui] (named T0 device fixture) | PASS | high | `device-flows/v2-device-flow/TS-01-07.flow` sha256 `6889ab7214cb1e2d15a634b04c2bd138207ca0ead41592e88cd5685350481ba6` matches; `named_results.TS-01-07 = PASS`; flow's `expect order` assertions match the row (frozen retro-todo `ItemOrder`, not re-graded here) |
| Step 5 / REQ-5 — device flow language expresses a double-tap as one `doubletap` step | [cmd] | PASS | high | `scripts/ui-flow.sh:118-129` dispatches `doubletap` to two back-to-back `uitest uiInput click` calls with no `settle()` between them, then one trailing `settle()` — matching integration.md's guard against the 800ms-apart failure mode |
| Testability seam — `ListViewModel` constructor widens to accept an optional `Clock`, default `SystemClock` | [cmd] | PASS | high | app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets:33-41; `clock === undefined ? new SystemClock() : clock` |
| Registration — the new `*.test.ets` is imported from `List.test.ets` (KB-SA-001/009) | [cmd] | PASS | high | app/entry/src/test/List.test.ets imports and calls `listViewModelTest()` |
| Repository/contract unchanged — `ToggleItem`/`TodoRepository.setDone` untouched | [cmd] | PASS | high | scope substrate for v1-settle-window lists only `ListViewModel.ets`, `TodoModule.ets`, `Clock.ts`, and the two test files; no domain file in the diff (git show 3c953f7 --stat) |
| Non-Go — no reorder animation added | [cmd] | PASS | high | no animation API/dependency appears in `ListViewModel.ets`; TS-01-07's flow asserts order only, no animation-timing assertion |
| Non-Go — no change to list screen layout/dialogs/persistence, retro-todo spec/Test Surface untouched | [cmd] | PASS | high | diff (git show 3c953f7 --stat) touches no file under `shapeup/retro-todo/spec/**` and no screen `.ets` other than `ListViewModel.ets`'s logic |

### Refuted criteria and bugs

None.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ② Concurrency | C-01 | 1 | 1 |
| ⑥ Data residue | C-02 | 0 | 0 |

→ full finding detail lives in the run trace under the `## Discovered`
  section ingest appends for this hunt's order; summarized here for convenience:

**[QA-001] [UC-01] Two taps landed on two different item rows in quick back-to-back succession
both silently fail to toggle — no error, no toggle, no evidence to the user that anything was
dropped.**

- lens: ②concurrency
- severity_hint: ux-degradation
- test_gap: exploratory-only
- contradicts: INV-03 ("A tap outside the window always reaches ToggleItem") — the first of the
  two taps landed on a row (`Buy eggs` / `Bread`, in the two repros below) that was genuinely
  outside any settle window (no toggle had run on this screen instance, or the prior toggle was
  well past `windowMs`), so per INV-03 it should have reached `ToggleItem` regardless of what the
  second tap does. It did not.
- repro (Groceries list, cold start, seed 1/3 done — Bread/Buy eggs open, Buy milk done):
  1. `hdc shell uitest dumpLayout` → resolve on-screen centers for the "Bread" row (604,857) and
     the "Buy eggs" row (604,1235).
  2. `hdc shell uitest uiInput click 604 857` (tap Bread) issued, immediately followed by
     `hdc shell uitest uiInput click 604 1235` (tap Buy eggs) issued as a second, independent
     dispatch with no wait between them.
  3. `hdc shell uitest dumpLayout` (after a 1s settle) → done count is still 1/3, Bread and Buy
     eggs both still show as open (`item.open`), Buy milk unchanged. Neither tap registered.
  4. Repro #2 (role-swapped, to rule out a coordinate mistake): from the resulting 2/3-done state
     (Bread now done, Buy eggs open), the same rapid pair was fired at Buy eggs's row (604,857)
     then Bread's row (604,1235) — result again: no change to either row.
  - Control: a single tap at the same coordinate, issued alone with a settle wait before the next
    dump, reliably toggles the row every time (used to establish both starting states above).
- Caveat for triage: the two taps here are two independent `hdc` process dispatches, not a
  literal two-finger simultaneous press — the underlying timing between them is whatever two
  back-to-back shell round-trips produce (unmeasured, but the same order of magnitude as a fast
  real double-tap by two hands). Whether the drop sits in `uitest`'s input injection, the ArkUI
  gesture recognizer treating two near-simultaneous touch points ~380px apart as an ambiguous
  gesture, or `ListViewModel` itself is not established by this repro — only that the live app,
  probed the way `TS-01-04`..`06` are probed, shows both taps lost with nothing surfaced.

## Discovered, not built

~ [lens:②concurrency] [QA-001] [UC-01] Two taps landed on two different item rows in quick back-to-back succession both silently fail to toggle — no error, no toggle, no evidence to the user that anything was dropped
    repro: 1. hdc shell uitest dumpLayout on the Groceries list (cold start, seed 1/3 done — Bread/Buy eggs open, Buy milk done); resolve on-screen centers for the Bread row (604,857) and the Buy eggs row (604,1235). 2. hdc shell uitest uiInput click 604 857 (tap Bread) issued immediately followed by hdc shell uitest uiInput click 604 1235 (tap Buy eggs) as a second, independent dispatch with no wait between them. 3. hdc shell uitest dumpLayout (after a 1s settle) — done count still 1/3, Bread and Buy eggs both still open, Buy milk unchanged; neither tap registered. 4. Repro #2 (role-swapped): from the resulting 2/3-done state (Bread now done, Buy eggs open), fired the same rapid pair at Buy eggs's row (604,857) then Bread's row (604,1235) — result again: no change to either row. Control: a single tap alone, with a settle wait before the next dump, reliably toggles the row every time.
    severity-hint: ux-degradation
    test-gap: exploratory-only
    contradicts: INV-03

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
