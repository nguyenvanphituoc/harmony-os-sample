---
type: ship-report
feature: retro-todo
date: 2026-09-26
verdict: PASS
rounds_used: 1
rounds_judged: 1
qa: not-hunted
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
| Board | 6/10 tasks done |
| T0 artifacts | 4 |
| QA | not-hunted |

> **4 task(s) did not finish** — use cases: UC-07, UC-08.
> The verdict above grades what was built, not what was planned.

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

**0/28 PASS · 28 no evidence (REQ-0 ← shapeup/retro-todo/shaping/shaping.md R0, REQ-1 ← shapeup/retro-todo/shaping/shaping.md R1, REQ-17 ← shapeup/retro-todo/shaping/shaping.md R1 (split 2/3), …)** · run `retro-todo-20260926T204952Z-ea80c642`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-0 | shapeup/retro-todo/shaping/shaping.md R0 | no evidence | UC-03: After deleting every list P1 shows "No lists yet" and "CREATE YOUR FIRST LIST", never a blank screen; tapping it opens the name dialog (covers: REQ-0) | — | — |
| REQ-1 | shapeup/retro-todo/shaping/shaping.md R1 | no evidence | UC-01: "+ NEW LIST" opens the dialog titled "NEW LIST"; SAVE with "Travel" adds a Travel card as the first card (TS-01-04) (covers: REQ-1) | — | — |
| REQ-17 | shapeup/retro-todo/shaping/shaping.md R1 (split 2/3) | no evidence | UC-07/UC-08: `TodoRules.checkListName` and `checkItemTitle` trim and return `Err` for blank input, with unit rows in `TodoRules.test.ets` (TS-01-01, TS-01-03) (covers: REQ-17, REQ-20) (+1) | — | — |
| REQ-18 | shapeup/retro-todo/shaping/shaping.md R1 (split 3/3) | no evidence | UC-01: Creating "Travel" twice yields two lists with the same name (TS-01-02) (covers: REQ-18) | — | — |
| REQ-2 | shapeup/retro-todo/shaping/shaping.md R2 | no evidence | UC-07: Cold start shows MY LISTS with Groceries "1/3 done", Work "1/2 done", Weekend "No items", newest-created first, verified by the flow under `device-flows/lists-and-open/` via `./scripts/ui-flow.sh device-flows/lists-and-open` (TS-07 device rows) (covers: REQ-2) | — | — |
| REQ-3 | shapeup/retro-todo/shaping/shaping.md R3 | no evidence | UC-07/UC-08: Items of Work never appear in the item list of Groceries (TS-08-03) (covers: REQ-3) (+1) | — | — |
| REQ-4 | shapeup/retro-todo/shaping/shaping.md R4 | no evidence | UC-03: ✕ on Groceries opens `Delete "Groceries" and its 2 items?`; DELETE removes the list and its items, CANCEL keeps both (covers: REQ-4) | — | — |
| REQ-16 | shapeup/retro-todo/shaping/shaping.md R16 | no evidence | UC-02: ✎ on a card opens "RENAME LIST" with the current name pre-filled; SAVE with "Trips" renames the list and its items stay (covers: REQ-16) | — | — |
| REQ-19 | shapeup/retro-todo/shaping/shaping.md R16 (split 2/2) | no evidence | UC-02: SAVE with an empty or whitespace-only value shows "Name can't be empty" at the field and keeps the old name (covers: REQ-19) | — | — |
| REQ-5 | shapeup/retro-todo/shaping/shaping.md R5 | no evidence | UC-04: Typing "Hike" and tapping ADD (or the keyboard submit) adds a card, newest first among the open items, and the empty invitation disappears (covers: REQ-5) | — | — |
| REQ-20 | shapeup/retro-todo/shaping/shaping.md R5 (split 2/2) | no evidence | UC-07/UC-08: `TodoRules.checkListName` and `checkItemTitle` trim and return `Err` for blank input, with unit rows in `TodoRules.test.ets` (TS-01-01, TS-01-03) (covers: REQ-17, REQ-20) (+1) | — | — |
| REQ-6 | shapeup/retro-todo/shaping/shaping.md R6 | no evidence | UC-05: One tap anywhere on an item card flips its done state; `ToggleItem("missing")` returns `Err(ITEM_NOT_FOUND)` (TS-05-06) (covers: REQ-6) | — | — |
| REQ-7 | shapeup/retro-todo/shaping/shaping.md R7 | no evidence | UC-07/UC-08: `ItemOrder.sort` puts every done item after every open item and orders each group by `createdAt` descending; `hvigorw test -p module=entry -p coverage=false` runs `ItemOrder.test.ets` green (TS-05-01, TS-05-02) (covers: REQ-7, REQ-21) (+1) | — | — |
| REQ-21 | shapeup/retro-todo/shaping/shaping.md R7 (split 2/4) | no evidence | UC-07/UC-08: `ItemOrder.sort` puts every done item after every open item and orders each group by `createdAt` descending; `hvigorw test -p module=entry -p coverage=false` runs `ItemOrder.test.ets` green (TS-05-01, TS-05-02) (covers: REQ-7, REQ-21) (+2) | — | — |
| REQ-22 | shapeup/retro-todo/shaping/shaping.md R7 (split 3/4) | no evidence | UC-05: Marking Bread done places it in the done group before Buy milk and leaves Buy eggs alone in the open group (TS-05-04) (covers: REQ-22) | — | — |
| REQ-23 | shapeup/retro-todo/shaping/shaping.md R7 (split 4/4) | no evidence | UC-05: Toggling Bread done then not done returns it above Buy eggs (TS-05-03) (covers: REQ-23) | — | — |
| REQ-8 | shapeup/retro-todo/shaping/shaping.md R8 | no evidence | UC-08: A done item carries the state id `item.done` and a checked box; an open item carries `item.open` (TS-05-05); the strike-through and colour change are checked by eye at sign-off (covers: REQ-8, REQ-24) (+1) | — | — |
| REQ-24 | shapeup/retro-todo/shaping/shaping.md R8 (split 2/2) | no evidence | UC-08: A done item carries the state id `item.done` and a checked box; an open item carries `item.open` (TS-05-05); the strike-through and colour change are checked by eye at sign-off (covers: REQ-8, REQ-24) (+1) | — | — |
| REQ-9 | shapeup/retro-todo/shaping/shaping.md R9 | no evidence | UC-06: ✕ on Buy milk opens `Delete "Buy milk"?`; CANCEL keeps it, DELETE removes it (covers: REQ-9) | — | — |
| REQ-10 | shapeup/retro-todo/shaping/shaping.md R10 | no evidence | UC-08: Weekend opens to "No items yet" and "Add your first item above" with id `list.emptyInvite` (TS-08-04) (covers: REQ-10) (+1) | — | — |
| REQ-11 | shapeup/retro-todo/shaping/shaping.md R11 | no evidence | UC-07/UC-08: `RetroCard` is the single card primitive with `surface` and `surfaceDone` variants, so a list and an item each render as their own card (covers: REQ-11, REQ-25) (+1) | — | — |
| REQ-25 | shapeup/retro-todo/shaping/shaping.md R11 (split 2/2) | no evidence | UC-07/UC-08: `RetroCard` is the single card primitive with `surface` and `surfaceDone` variants, so a list and an item each render as their own card (covers: REQ-11, REQ-25) (+1) | — | — |
| REQ-12 | shapeup/retro-todo/shaping/shaping.md R12 | no evidence | UC-07/UC-08: Every text/background pair used (`ink` on `surface`, `inkMuted` on `surfaceDone`, `onDanger` on `danger`) has a contrast ratio of at least 4.5:1, computed by a script and printed (covers: REQ-12) | — | — |
| REQ-26 | shapeup/retro-todo/shaping/shaping.md R12 (split 2/2) | no evidence | UC-07/UC-08: The card border (`ink` on `background`) and the `RetroCheck` box have a contrast ratio of at least 3:1, computed by a script and printed (covers: REQ-26) | — | — |
| REQ-13 | shapeup/retro-todo/shaping/shaping.md R13 | no evidence | UC-07/UC-08: `color.json` defines `background`, `surface`, `surfaceDone`, `ink`, `inkMuted`, `brand`, `danger`, `onDanger`; `float.json` defines border 2vp, shadow offset 4vp, radius, spacing, font sizes and minimum touch target; no screen hard-codes a colour or size (covers: REQ-13) | — | — |
| REQ-14 | shapeup/retro-todo/shaping/shaping.md R14 | no evidence | UC-07/UC-08: `seed()` yields Groceries (Buy milk done, Buy eggs, Bread), Work (Book meeting room done, Send weekly report), Weekend (no items); a cold start always begins from this same data (TS-08-01, TS-08-02) (covers: REQ-14) (+1) | — | — |
| REQ-27 | shapeup/retro-todo/shaping/shaping.md R14 (split 2/2) | no evidence | UC-07/UC-08: The repository holds data in memory only: no file, preferences or database API is imported by `InMemoryTodoRepository.ts`; a fresh instance re-seeds identically, so nothing survives a restart (D1 INV in UC-07) (covers: REQ-27) | — | — |
| REQ-15 | shapeup/retro-todo/shaping/shaping.md R15 | no evidence | UC-07/UC-08: Every visible string lives in `resources/base/element/string.json` in English, with the same keys and Vietnamese values in `vi_VN/element/string.json`, and a diff of the two key sets is empty (KB-BA-006) (covers: REQ-15) | — | — |

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

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| all six | not hunted | 0 | 0 |

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
