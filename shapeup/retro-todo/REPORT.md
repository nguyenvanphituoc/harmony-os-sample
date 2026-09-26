---
type: ship-report
feature: retro-todo
date: 2026-09-26
verdict: FAIL
rounds_used: 3
rounds_judged: 3
qa: skipped
intake_sha256: 3bcc3493c9e94b991ed58af6996b5098d2701bd3dced631b8187bf0618a140d3
---

# retro-todo — ship report

> **Shipped with a FAIL verdict.** Not every criterion passed; GATE H's baseline comparison cleared it (census: ship-now) with 3 items cut. Read the failed criteria and the cut list below before treating this feature as done.

Frozen at GATE L4. Every figure below is derived from run artifacts on disk — the trial
ledger, the verdict artifacts, the board — never from a summary of the run.

## Outcome

| | |
|---|---|
| Verdict | **FAIL** |
| Rounds used | 3 |
| Rounds judged | 3 |
| Board | 7/8 tasks done |
| T0 artifacts | 15 |
| QA | skipped |

> **1 task(s) did not finish** — use cases: UC-05.
> The verdict above grades what was built, not what was planned.

## Verification (T0)

The surviving trial per scope — the one describing code that is actually on the branch.

| scope | fixtures | regressions | trials | last status | delta |
|---|---|---|---|---|---|
| delete-confirm | 3/3 | — | 4 | kept | no change |
| list-name | 3/3 | — | 4 | kept | no change |
| lists-and-open | 3/3 | — | 3 | kept | no change |
| toggle-and-add | 3/3 | — | 4 | kept | no change |

## Requirements

One row per registered clause. A requirement has evidence when an acceptance criterion
covers it AND a criterion grading it passed — `covers:` is the join, the judge's anchor is the
path back. This is a projection, never a verdict: it never blocked this ship.

**0/28 PASS · 28 no evidence (REQ-0 ← shapeup/retro-todo/shaping/shaping.md R0, REQ-1 ← shapeup/retro-todo/shaping/shaping.md R1, REQ-17 ← shapeup/retro-todo/shaping/shaping.md R1 (split 2/3), …)** · run `retro-todo-20260926T174134Z-f1de19fc`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-0 | shapeup/retro-todo/shaping/shaping.md R0 | no evidence | UC-07: When no list remains, `status` is Empty (TS-07-03) and P1 shows "No lists yet" with the "CREATE YOUR FIRST LIST" button, never a blank screen; TS-07-04. (covers: REQ-0) (+2) | — | — |
| REQ-1 | shapeup/retro-todo/shaping/shaping.md R1 | no evidence | UC-01/UC-02: SAVE with a valid name creates a list and it is the first card on P1; TS-01-04. (covers: REQ-1) (+1) | — | — |
| REQ-17 | shapeup/retro-todo/shaping/shaping.md R1 (split 2/3) | no evidence | UC-01/UC-02: `checkListName("")` and `("   ")` return `Err(LIST_NAME_EMPTY)` and add no list; TS-01-01. (covers: REQ-17) (+1) | — | — |
| REQ-18 | shapeup/retro-todo/shaping/shaping.md R1 (split 3/3) | no evidence | UC-01/UC-02: Creating "Travel" twice yields two lists with the same name; TS-01-02. (covers: REQ-18) | — | — |
| REQ-2 | shapeup/retro-todo/shaping/shaping.md R2 | no evidence | UC-07/UC-08: List progress is derived as done/total per list, Groceries reads 1/3 and Weekend reads "No items"; TS-07-02. (covers: REQ-2) (+3) | — | — |
| REQ-3 | shapeup/retro-todo/shaping/shaping.md R3 | no evidence | UC-07/UC-08: Repository item queries return only the items of the requested list; Work items never appear under Groceries; TS-08-03. (covers: REQ-3) (+2) | — | — |
| REQ-4 | shapeup/retro-todo/shaping/shaping.md R4 | no evidence | UC-03/UC-06: After `DeleteList(A)` the items of A are gone and the items of B remain; TS-03-01. (covers: REQ-4) (+3) | — | — |
| REQ-16 | shapeup/retro-todo/shaping/shaping.md R16 | no evidence | UC-01/UC-02: The rename icon opens the dialog pre-filled with the current name and SAVE shows the new name on the same card; TS-02-04. (covers: REQ-16) (+2) | — | — |
| REQ-19 | shapeup/retro-todo/shaping/shaping.md R16 (split 2/2) | no evidence | UC-01/UC-02: `RenameList(id, "  ")` returns `Err(LIST_NAME_EMPTY)` and the name is unchanged; the dialog shows "Name can't be empty"; TS-02-01. (covers: REQ-19) | — | — |
| REQ-5 | shapeup/retro-todo/shaping/shaping.md R5 | no evidence | UC-04: `AddItem(A, "Hike")` adds an open item visible only under list A; TS-04-02. (covers: REQ-5) | — | — |
| REQ-20 | shapeup/retro-todo/shaping/shaping.md R5 (split 2/2) | no evidence | UC-04: `AddItem(id, "")` and `("  ")` return `Err(ITEM_TITLE_EMPTY)` and add no item; TS-04-01. (covers: REQ-20) (+1) | — | — |
| REQ-6 | shapeup/retro-todo/shaping/shaping.md R6 | no evidence | UC-05: One tap on an item card flips done/not done and the checked box follows; component id `list.itemCard.toggle`. (covers: REQ-6) (+1) | — | — |
| REQ-7 | shapeup/retro-todo/shaping/shaping.md R7 | no evidence | UC-07/UC-08: `ItemOrder.sort` puts every done item after every open item; TS-05-01, TS-08-01, TS-08-02. (covers: REQ-7) (+2) | — | — |
| REQ-21 | shapeup/retro-todo/shaping/shaping.md R7 (split 2/4) | no evidence | UC-07/UC-08: Within each group `createdAt` is descending (newest-created first); TS-05-02. (covers: REQ-21) (+2) | — | — |
| REQ-22 | shapeup/retro-todo/shaping/shaping.md R7 (split 3/4) | no evidence | UC-05: Seed Groceries: toggling Bread to done places it in the done group before Buy milk and the open group reads Buy eggs only; TS-05-04. (covers: REQ-22) (+1) | — | — |
| REQ-23 | shapeup/retro-todo/shaping/shaping.md R7 (split 4/4) | no evidence | UC-05: Seed Groceries: toggling Bread done then not done returns it above Buy eggs; TS-05-03. (covers: REQ-23) | — | — |
| REQ-8 | shapeup/retro-todo/shaping/shaping.md R8 | no evidence | UC-08: A done item's card sets the id `item.done` and its text is struck through; a manual check confirms the strike-through visually (KB-BA-009); TS-08-05. (covers: REQ-8) (+1) | — | — |
| REQ-24 | shapeup/retro-todo/shaping/shaping.md R8 (split 2/2) | no evidence | UC-07/UC-08: Done-item text uses a different color token from open-item text (`inkMuted` on `surfaceDone` vs `ink` on `surface`), asserted by a token check; the strike-through half is checked in a board task (covers: REQ-24) (+2) | — | — |
| REQ-9 | shapeup/retro-todo/shaping/shaping.md R9 | no evidence | UC-03/UC-06: CANCEL keeps the item; DELETE removes it and leaves the other items; TS-06-03, TS-06-01. (covers: REQ-9) (+2) | — | — |
| REQ-10 | shapeup/retro-todo/shaping/shaping.md R10 | no evidence | UC-08: Weekend opens to "No items yet" and "Add your first item above"; TS-08-04. (covers: REQ-10) (+2) | — | — |
| REQ-11 | shapeup/retro-todo/shaping/shaping.md R11 | no evidence | UC-07/UC-08: `RetroCard` (`surface`) is the single card primitive used for list cards and item cards. (covers: REQ-11) (+1) | — | — |
| REQ-25 | shapeup/retro-todo/shaping/shaping.md R11 (split 2/2) | no evidence | UC-08: Every item is its own `RetroCard` (component id `list.itemCard`). (covers: REQ-25) | — | — |
| REQ-12 | shapeup/retro-todo/shaping/shaping.md R12 | no evidence | UC-07/UC-08: Every text/background token pair in `color.json` (ink on surface, inkMuted on surfaceDone, and every other pair used) has a contrast ratio of at least 4.5:1, computed by a script whose output is attached; done-item text included. (covers: REQ-12) | — | — |
| REQ-26 | shapeup/retro-todo/shaping/shaping.md R12 (split 2/2) | no evidence | UC-07/UC-08: Card border and check-control colors against their background have a contrast ratio of at least 3:1, computed by the same script. (covers: REQ-26) | — | — |
| REQ-13 | shapeup/retro-todo/shaping/shaping.md R13 | no evidence | UC-07/UC-08: Palette, type sizes and card treatment are defined once in `color.json`, `float.json` and the `RetroCard` kit primitive; a grep shows no screen file declaring its own hex color or font size literal. (covers: REQ-13) (+2) | — | — |
| REQ-14 | shapeup/retro-todo/shaping/shaping.md R14 | no evidence | UC-07/UC-08: `seed()` yields Groceries (3 items, 1 done), Work (2 items, 1 done), Weekend (0 items), in that order, on every call from a fresh store; TS-07-01. (covers: REQ-14) (+1) | — | — |
| REQ-27 | shapeup/retro-todo/shaping/shaping.md R14 (split 2/2) | no evidence | UC-07/UC-08: The store and repository keep data in memory only; a fresh store is exactly the seed and nothing is written to disk or preferences; INV-17. (covers: REQ-27) (+1) | — | — |
| REQ-15 | shapeup/retro-todo/shaping/shaping.md R15 | no evidence | UC-07/UC-08: Every string in `resources/base/element/string.json` is English (no non-ASCII words) and no screen file holds a visible string literal. (covers: REQ-15) (+1) | — | — |

## Ratchet

Measured over this run's trial ledger. A monotone series is a ratchet working; a flat or
sawtooth series says the loop is still a budgeted retry loop wearing a ratchet's shape.

| | |
|---|---|
| Trials | 15 across 4 scope(s), 4 with more than one attempt |
| Improvement rate | 1 — kept ÷ trials after the first |
| Monotone rate | 1 — multi-trial scopes whose score never decreased |
| Sawtooth count | 0 — a revert immediately after a keep |
| Mean trials to green | 1.25 |
| Statuses | kept 15 |

## Evaluation

| Criterion | Verdict | Confidence | Evidence |
|---|---|---|---|
| Device rows TS-01-04/05, 02-04, 03-03/04/05, 04-03/04, 05-07, 06-03/04/05, 07-04/05/06, 08-04/05/06 | PASS | medium | named PASS in t1-t4 |
| TS-05-05 done card strikethrough + inkMuted on surfaceDone + checked box | FAIL | high | flow still admits (TS-05-05.flow:2) strikethrough/inkMuted/surfaceDone are not asserted; only counts. Check weaker than row; re-read, same |
| Local rows | PASS | low | unit tier builds |

### Refuted criteria and bugs

- TS-05-05 check weaker than its row: device-flows/toggle-and-add/TS-05-05.flow:2. Assert style or PO waives.

## Discovered, not built

~ scripts/ui-flow.sh has no style assertion (strikethrough, font color), so TS-05-05 cannot assert inkMuted on surfaceDone from a flow

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
