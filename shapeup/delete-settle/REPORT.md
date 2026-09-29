---
type: ship-report
feature: delete-settle
date: 2026-09-29
verdict: PASS
rounds_used: 1
rounds_judged: 1
qa: run
intake_sha256: e92cf6fac42ec8dae479a0243d973aa3a6dfa5b49c4fb602a0a79f8c9932a035
---

# delete-settle — ship report

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
| v1-settle-window-delete | 2/2 | — | 1 | kept | baseline |
| v2-device-flow-r2 | 2/2 | — | 1 | kept | baseline |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**5/5 PASS** · run `delete-settle-20260929T031445Z-607891db`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-1 | shaping/shaping.md R1 | PASS | UC-01: A ✕ tap (`onDeleteItem` call) within `SETTLE_WINDOW_MS` of a toggle opens no dialog — | UC-01 Step 2: inside window, no lookup, no openDelete, lastToggleAt untouched (+1) → PASS,PASS | d611b4724e44, a195eae998e0 |
| REQ-2 | shaping/shaping.md R2 | PASS | UC-01: A ✕ tap at `SETTLE_WINDOW_MS` or later after a toggle opens the dialog naming that row's (+1) | UC-01 Step 3: outside window, lookup + openDelete(itemId, title) (+2) → PASS,PASS,PASS | d611b4724e44, a195eae998e0 |
| REQ-3 | shaping/shaping.md R3 (split 1/3) | PASS | UC-01: `onToggle` itself is untouched by this task's diff, and toggle-once's own settle-window | UC-01 Step 4: onToggle untouched → PASS | d611b4724e44, a195eae998e0 |
| REQ-4 | shaping/shaping.md R3 (split 2/3) | PASS | UC-01: toggle-once's own settle-window test (an `onToggle` call at `windowMs` or later after the | UC-01 Step 4: onToggle untouched → PASS | d611b4724e44, a195eae998e0 |
| REQ-5 | shaping/shaping.md R3 (split 3/3) | PASS | UC-01: toggle-once's own reorder behavior (a toggled item still sinks/rises immediately, done below | UC-01 Step 4: onToggle untouched → PASS | d611b4724e44, a195eae998e0 |

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

| Criterion | Verdict | Confidence | Evidence |
|---|---|---|---|
| UC-01 Step 1 (reads clock, checks isSettling) | PASS | high | `ListViewModel.ets:100-103` |
| UC-01 Step 2 (inside window: no lookup, no openDelete, lastToggleAt untouched) | PASS | high | `ListViewModel.ets:100-104`; TS-01-01/03 tests |
| UC-01 Step 3 (outside window: lookup + openDelete(itemId, title)) | PASS | high | `ListViewModel.ets:105-108`; TS-01-02, TS-01-04 |
| UC-01 Step 4 (onToggle untouched) | PASS | high | `git diff HEAD -- ListViewModel.ets` shows only lines 100-104 added; `onToggle` (lines 71-81) unchanged |
| UC-01 Error Cases (no new code; not-found branch unchanged) | PASS | high | `ListViewModel.ets:105-108` unchanged `found !== undefined` gate |

### Refuted criteria and bugs

None.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ③ State interruption / ④ Cross-UC journey | C-01: toggle → back → reopen → delete, same item, cumulative time inside `SETTLE_WINDOW_MS` | 1 | 1 (INV-02) |
| ② Concurrency | C-02: toggle item A, immediately delete a *different* item B on the same screen (no navigation) | 0 — guard held (dialog did not open, matches INV-02) | 0 |
| ② Concurrency | C-03: double-tap the delete button on an already-settled item | 0 confirmed — see session notes (inconclusive, not recorded as a finding) | 0 |

→ details below; ingest appends the confirmed finding to
the run trace under `## Discovered`.

### QA-001 (confirmed)

```
[QA-001] [UC-01] Navigating away from and back into a list screen resets the settle-window
guard, letting a delete dialog open on an item toggled moments earlier — even when the
elapsed wall-clock time between the toggle and the delete tap is far inside
SETTLE_WINDOW_MS (400ms).
```

Repro (device: `127.0.0.1:5555`, bundle `com.example.myapplication`, list "Groceries",
row 1 = "Bread"):
1. Open the Groceries list (`lists.card.open` → List screen).
2. Tap the toggle control on row 1 ("Bread") — `list.itemCard.toggle` — this starts the
   settle window (`lastToggleAt = now`).
3. Immediately tap `list.backButton` to return to the Lists screen.
4. Immediately tap the same list's card (`lists.card.open`, "Groceries") to reopen it.
5. Immediately tap `list.deleteItemButton` on row 1 ("Bread").
6. All four taps (steps 2–5) were issued back-to-back via `uitest uiInput click`; wall-clock
   timestamps around the sequence measured ~10ms total — several orders of magnitude inside
   the 400ms window.

Expected (UC-01 Step 2 / INV-02): the tap in step 5 lands inside the settle window opened
in step 2, so no dialog should open and nothing should delete.

Actual: the delete confirmation dialog opened (`confirm.message`, `confirm.deleteButton`,
`confirm.cancelButton` all present in the post-step-5 UI tree) — dismissed via
`confirm.cancelButton` to avoid destructive state.

Root cause (read, not asserted as the finding itself — the finding is the observed
behavior): `app/entry/src/main/ets/pages/Index.ets:31` calls
`this.todo.listViewModel(param as string)` inline inside the `@Builder routes` function,
so `TodoModule.listViewModel()` (`app/entry/src/main/ets/features/todo/TodoModule.ets:78-82`)
constructs a brand-new `ListViewModel` — with a fresh `lastToggleAt = null` — every time the
List screen is (re-)navigated to. The settle window is `ListViewModel`-instance state, not
`TodoStore`(shared) state, so it does not survive a screen exit/re-entry no matter how
quickly the user returns.

- severity_hint: data-integrity — this is exactly the accidental-tap scenario the settle
  window exists to prevent (per the pitch's own framing: a delete tap landing right after a
  toggle's reorder animation), and a quick back/forward (a normal enough user action — e.g.
  to glance at another list) fully defeats it.
- test_gap: exploratory-only — invisible to TS-01-01/02/03 (unit tests hold one
  long-lived `ListViewModel` instance) and to TS-01-04 (device flow never navigates away
  mid-window); only a live session that crosses the navigation boundary surfaces it.
- contradicts: INV-02 — INV-02's stated guarantee ("a ✕ tap inside the window opens no
  dialog... for any item") is written and graded as a screen-wide, item-agnostic guard, but
  is observably not time-window-wide across a re-entered screen.

### Confirmed non-findings (guard held)

- C-02: toggled row 2 ("Buy eggs") then, ~10ms later, tapped delete on row 1 ("Bread") —
  a different item, same screen, no navigation. No dialog opened — INV-02's screen-wide
  guard held correctly within a single VM instance, on-device (this scenario is unit-tested
  but had not been confirmed live).

## Discovered, not built

~ [lens:③state-interruption] [QA-001] [UC-01] Navigating back to Lists and immediately reopening the list resets the settle-window guard (fresh ListViewModel per navigation, Index.ets:31 -> TodoModule.listViewModel), letting the delete dialog open on an item toggled ~10ms earlier, well inside SETTLE_WINDOW_MS (400ms)
    repro: 1. Open Groceries list. 2. Tap toggle on row 1 ("Bread", list.itemCard.toggle) — starts settle window. 3. Immediately tap list.backButton. 4. Immediately tap the Groceries card (lists.card.open) to reopen the list. 5. Immediately tap list.deleteItemButton on row 1. All 4 taps issued back-to-back (~10ms total). Expected: no dialog (inside window). Actual: confirm.message/confirm.deleteButton dialog opens.
    severity-hint: data-integrity
    test-gap: exploratory-only
    contradicts: INV-02

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
