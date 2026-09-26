---
type: ship-report
feature: retro-todo
date: 2026-09-26
verdict: PASS
rounds_used: 2
rounds_judged: 2
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
| Rounds used | 2 |
| Rounds judged | 2 |
| Board | 7/10 tasks done |
| T0 artifacts | 22 |
| QA | run |

> **3 task(s) did not finish** — use cases: UC-07, UC-08.
> The verdict above grades what was built, not what was planned.

## Verification (T0)

The surviving trial per scope — the one describing code that is actually on the branch.

| scope | fixtures | regressions | trials | last status | delta |
|---|---|---|---|---|---|
| delete-confirm | 3/3 | — | 5 | kept | no change |
| list-name | 3/3 | — | 6 | kept | no change |
| lists-and-open | 3/3 | — | 5 | kept | no change |
| toggle-and-add | 3/3 | — | 6 | kept | no change |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**0/28 PASS · 28 no evidence (REQ-0 ← shapeup/retro-todo/shaping/shaping.md R0, REQ-1 ← shapeup/retro-todo/shaping/shaping.md R1, REQ-17 ← shapeup/retro-todo/shaping/shaping.md R1 (split 2/3), …)** · run `retro-todo-20260926T171259Z-961ef78e`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-0 | shapeup/retro-todo/shaping/shaping.md R0 | no evidence | UC-07: Progress for Groceries reads 1/3 and Weekend has no items; deleting every list leaves S1 empty. Verify: unit tests TS-07-02 and TS-07-03 pass. (covers: REQ-0) (+2) | — | — |
| REQ-1 | shapeup/retro-todo/shaping/shaping.md R1 | no evidence | UC-01: `CreateList("  Trips ")` stores "Trips"; `CreateList("Travel")` makes it the first card on P1. Verify: unit test TS-01-03 and device flow TS-01-04. (covers: REQ-1) | — | — |
| REQ-17 | shapeup/retro-todo/shaping/shaping.md R1 (split 2/3) | no evidence | UC-01: `CreateList("")` and `("   ")` return `Err(LIST_NAME_EMPTY)` and add no list. Verify: unit test TS-01-01. (covers: REQ-17) (+1) | — | — |
| REQ-18 | shapeup/retro-todo/shaping/shaping.md R1 (split 3/3) | no evidence | UC-01: Creating "Travel" twice yields two lists with the same name. Verify: unit test TS-01-02. (covers: REQ-18) | — | — |
| REQ-2 | shapeup/retro-todo/shaping/shaping.md R2 | no evidence | UC-07: Cold start shows MY LISTS with Groceries "1/3 done", Work "1/2 done", Weekend "No items", newest-created first, each list as its own `RetroCard`. Verify: device flow under `device-flows/lists-and-open/` asserts the three card ids and texts (TS-07-05). (covers: REQ-2, REQ-11, REQ-14) | — | — |
| REQ-3 | shapeup/retro-todo/shaping/shaping.md R3 | no evidence | UC-08: Opening a list shows only that list's items. Verify: unit test TS-08-03 (Work items never under Groceries). (covers: REQ-3) | — | — |
| REQ-4 | shapeup/retro-todo/shaping/shaping.md R4 | no evidence | UC-03: `DeleteList(A)` removes A and its items only; `DeleteList("missing")` returns `Err(LIST_NOT_FOUND)`. Verify: unit tests TS-03-01, TS-03-02. (covers: REQ-4) (+1) | — | — |
| REQ-16 | shapeup/retro-todo/shaping/shaping.md R16 | no evidence | UC-02: `RenameList(id, "Trips")` changes only the name; `id`, `createdAt` and items are untouched. Verify: unit test TS-02-02. (covers: REQ-16) (+1) | — | — |
| REQ-19 | shapeup/retro-todo/shaping/shaping.md R16 (split 2/2) | no evidence | UC-02: `RenameList(id, "  ")` returns `Err(LIST_NAME_EMPTY)` and keeps the old name; `RenameList("missing", "X")` returns `Err(LIST_NOT_FOUND)`. Verify: unit tests TS-02-01, TS-02-03. (covers: REQ-19) | — | — |
| REQ-5 | shapeup/retro-todo/shaping/shaping.md R5 | no evidence | UC-04: `AddItem(id, "")` and `("  ")` return `Err(ITEM_TITLE_EMPTY)` and add nothing; `AddItem(A, "Hike")` adds an open item visible only under A. Verify: unit tests TS-04-01, TS-04-02. (covers: REQ-5) | — | — |
| REQ-20 | shapeup/retro-todo/shaping/shaping.md R5 (split 2/2) | no evidence | UC-04: ADD on an empty or whitespace field shows "Title can't be empty" at the field and keeps the text. Verify: device flow TS-04-03 asserts the error text. (covers: REQ-20) | — | — |
| REQ-6 | shapeup/retro-todo/shaping/shaping.md R6 | no evidence | UC-05: `ToggleItem(id)` flips `done`; an unknown id returns `Err(ITEM_NOT_FOUND)` with no state change. Verify: unit test TS-05-06. (covers: REQ-6) (+1) | — | — |
| REQ-7 | shapeup/retro-todo/shaping/shaping.md R7 | no evidence | UC-08: `ItemOrder.sort` puts every done item after every open item and orders each group by `createdAt` descending. Verify: unit tests TS-05-01, TS-05-02. (covers: REQ-7, REQ-21) (+1) | — | — |
| REQ-21 | shapeup/retro-todo/shaping/shaping.md R7 (split 2/4) | no evidence | UC-08: `ItemOrder.sort` puts every done item after every open item and orders each group by `createdAt` descending. Verify: unit tests TS-05-01, TS-05-02. (covers: REQ-7, REQ-21) (+2) | — | — |
| REQ-22 | shapeup/retro-todo/shaping/shaping.md R7 (split 3/4) | no evidence | UC-05: Marking Bread done in seeded Groceries places it in the done group before Buy milk, leaving Buy eggs alone in the open group. Verify: unit test TS-05-04. (covers: REQ-22) | — | — |
| REQ-23 | shapeup/retro-todo/shaping/shaping.md R7 (split 4/4) | no evidence | UC-05: Toggling Bread done then not done returns it above Buy eggs. Verify: unit test TS-05-03. (covers: REQ-23) | — | — |
| REQ-8 | shapeup/retro-todo/shaping/shaping.md R8 | no evidence | UC-08: Each item is its own `RetroCard`; a done item is struck through and shown in `inkMuted` on `surfaceDone` with a checked box, an open item in `ink` on `surface`. Verify: the view sets the id `item.done` on done cards; device flow TS-08-05 asserts Buy milk carries `item.done` and is last, and a source check finds `TextDecorationType.LineThrough` plus the `inkMuted` token in the item card. (covers: REQ-8, REQ-24, REQ-25) | — | — |
| REQ-24 | shapeup/retro-todo/shaping/shaping.md R8 (split 2/2) | no evidence | UC-08: Each item is its own `RetroCard`; a done item is struck through and shown in `inkMuted` on `surfaceDone` with a checked box, an open item in `ink` on `surface`. Verify: the view sets the id `item.done` on done cards; device flow TS-08-05 asserts Buy milk carries `item.done` and is last, and a source check finds `TextDecorationType.LineThrough` plus the `inkMuted` token in the item card. (covers: REQ-8, REQ-24, REQ-25) | — | — |
| REQ-9 | shapeup/retro-todo/shaping/shaping.md R9 | no evidence | UC-06: `DeleteItem(id)` removes only that item; `DeleteItem("missing")` returns `Err(ITEM_NOT_FOUND)`. Verify: unit tests TS-06-01, TS-06-02. (covers: REQ-9) (+1) | — | — |
| REQ-10 | shapeup/retro-todo/shaping/shaping.md R10 | no evidence | UC-04: Opening Weekend shows "No items yet" and "Add your first item above"; adding "Hike" replaces the invitation with its card. Verify: device flows TS-08-04 and TS-04-04. (covers: REQ-10) (+1) | — | — |
| REQ-11 | shapeup/retro-todo/shaping/shaping.md R11 | no evidence | UC-07: Cold start shows MY LISTS with Groceries "1/3 done", Work "1/2 done", Weekend "No items", newest-created first, each list as its own `RetroCard`. Verify: device flow under `device-flows/lists-and-open/` asserts the three card ids and texts (TS-07-05). (covers: REQ-2, REQ-11, REQ-14) | — | — |
| REQ-25 | shapeup/retro-todo/shaping/shaping.md R11 (split 2/2) | no evidence | UC-08: Each item is its own `RetroCard`; a done item is struck through and shown in `inkMuted` on `surfaceDone` with a checked box, an open item in `ink` on `surface`. Verify: the view sets the id `item.done` on done cards; device flow TS-08-05 asserts Buy milk carries `item.done` and is last, and a source check finds `TextDecorationType.LineThrough` plus the `inkMuted` token in the item card. (covers: REQ-8, REQ-24, REQ-25) | — | — |
| REQ-12 | shapeup/retro-todo/shaping/shaping.md R12 | no evidence | UC-07: Every text/background pair of the tokens has a contrast ratio of at least 4.5:1, with `inkMuted` on `surfaceDone` at least 6.26:1. Verify: a script computes WCAG ratios from `color.json` and exits non-zero below 4.5. (covers: REQ-12) | — | — |
| REQ-26 | shapeup/retro-todo/shaping/shaping.md R12 (split 2/2) | no evidence | UC-07: The card border and the `RetroCheck` box (`ink` on `surface`/`surfaceDone`) reach at least 3:1. Verify: same script, non-text pairs at 3.0. (covers: REQ-26) | — | — |
| REQ-13 | shapeup/retro-todo/shaping/shaping.md R13 | no evidence | UC-07: `color.json` and `float.json` define the color tokens (`background`, `surface`, `surfaceDone`, `ink`, `inkMuted`, `brand`, `danger`, `onDanger`) and the size tokens (border 2vp, shadow offset 4vp, radius, spacing, font sizes in fp, minimum touch target) once, and `AppText`, `RetroButton`, `RetroCard`, `RetroCheck`, `RetroField`, `EmptyState`, `RetroDialog` read only those tokens. Verify: `grep -rE "#[0-9A-Fa-f]{6}" app/entry/src/main/ets/shared/uikit` returns nothing. (covers: REQ-13) (+1) | — | — |
| REQ-14 | shapeup/retro-todo/shaping/shaping.md R14 | no evidence | UC-07: `Result`, `TodoList`, `TodoItem`, `TodoRules`, `TodoRepository`, `TodoStore` (`@Trace` S1 and S2) and `InMemoryTodoRepository` exist under `features/todo/domain/` per the [[todo-repository]] contract; the repository is the store's only writer. Verify: `hvigorw assembleHap` exits 0 and the enforce rules report no violation. (covers: REQ-14) (+2) | — | — |
| REQ-27 | shapeup/retro-todo/shaping/shaping.md R14 (split 2/2) | no evidence | UC-07: A fresh repository never reads or writes storage: no `preferences`, `relationalStore` or file import under `features/todo/`. Verify: `grep -rE "preferences\|relationalStore\|fs" app/entry/src/main/ets/features/todo` returns nothing. (covers: REQ-27) (+1) | — | — |
| REQ-15 | shapeup/retro-todo/shaping/shaping.md R15 | no evidence | UC-07: Every visible string comes from `resources/base/element/string.json` and is English; no other language qualifier directory exists. Verify: `ls app/entry/src/main/resources` lists only `base` (and `dark` if colors only), and `grep -rE "Text\(['\"]" app/entry/src/main/ets` returns nothing. (covers: REQ-15) | — | — |

## Ratchet

Measured over this run's trial ledger. A monotone series is a ratchet working; a flat or
sawtooth series says the loop is still a budgeted retry loop wearing a ratchet's shape.

| | |
|---|---|
| Trials | 22 across 4 scope(s), 4 with more than one attempt |
| Improvement rate | 1 — kept ÷ trials after the first |
| Monotone rate | 1 — multi-trial scopes whose score never decreased |
| Sawtooth count | 0 — a revert immediately after a keep |
| Mean trials to green | 1.5 |
| Statuses | kept 22 |

## Discovered, not built

~ reduce board reports total_hours 0: task frontmatter field `hours` may not be the field the kernel sums; hours not counted in appetite arithmetic

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
