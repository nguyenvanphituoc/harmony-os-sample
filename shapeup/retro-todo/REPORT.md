---
type: ship-report
feature: retro-todo
date: 2026-09-27
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
| Board | 8/8 tasks done |
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

**22/28 PASS · 6 no evidence (REQ-11 ← shapeup/retro-todo/shaping/shaping.md R11, REQ-25 ← shapeup/retro-todo/shaping/shaping.md R11 (split 2/2), REQ-12 ← shapeup/retro-todo/shaping/shaping.md R12, …)** · run `retro-todo-20260927T063004Z-4db8f5ed`

| REQ | source | evidence | covering AC | criterion | T0 |
|---|---|---|---|---|---|
| REQ-0 | shapeup/retro-todo/shaping/shaping.md R0 | PASS | UC-07: With no lists, `status` is Empty (TS-07-03) and P1 shows "No lists yet" with (+1) | TS-07-03 (+1) → PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-1 | shapeup/retro-todo/shaping/shaping.md R1 | PASS | UC-01/UC-02: "+ NEW LIST" (`lists.newButton`) or "CREATE YOUR FIRST LIST" (`lists.emptyInvite`) opens | TS-01-04 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-17 | shapeup/retro-todo/shaping/shaping.md R1 (split 2/3) | PASS | UC-07/UC-08: `checkListName("")` and `("   ")` return `Err(LIST_NAME_EMPTY)`; `checkListName("  Trips ")` (+1) | TS-01-01 (+2) → PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-18 | shapeup/retro-todo/shaping/shaping.md R1 (split 3/3) | PASS | UC-01/UC-02: Creating "Travel" twice yields two lists with the same name (TS-01-02) (covers: REQ-18) | TS-01-02 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-2 | shapeup/retro-todo/shaping/shaping.md R2 | PASS | UC-07: Each card shows its name and progress as on-screen text — "1/3 done" for Groceries, (+1) | TS-05-07 (+1) → PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-3 | shapeup/retro-todo/shaping/shaping.md R3 | PASS | UC-07/UC-08: The repository's list/item queries return only the rows of the requested list; deleting a (+2) | TS-08-03 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-4 | shapeup/retro-todo/shaping/shaping.md R4 | PASS | UC-03/UC-06: The delete icon (`lists.deleteButton`) opens `Delete "Groceries" and its 3 items?` (+2) | TS-03-01 (+3) → PASS,PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-16 | shapeup/retro-todo/shaping/shaping.md R16 | PASS | UC-01/UC-02: The rename icon (`lists.renameButton`) opens the dialog titled "RENAME LIST" pre-filled (+1) | TS-02-01 (+2) → PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-19 | shapeup/retro-todo/shaping/shaping.md R16 (split 2/2) | PASS | UC-01/UC-02: `RenameList(id, "  ")` returns `Err(LIST_NAME_EMPTY)`, the name is unchanged, and the dialog | TS-02-01 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-5 | shapeup/retro-todo/shaping/shaping.md R5 | PASS | UC-04: `AddItem(A, "Hike")` adds an open item visible only under list A (TS-04-02) (+1) | TS-04-02 (+1) → PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-20 | shapeup/retro-todo/shaping/shaping.md R5 (split 2/2) | PASS | UC-07/UC-08: `checkItemTitle("")` and `("  ")` return `Err(ITEM_TITLE_EMPTY)` (TS-04-01) (covers: REQ-20) (+2) | TS-04-01 (+1) → PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-6 | shapeup/retro-todo/shaping/shaping.md R6 | PASS | UC-05: One tap anywhere on an item card (component id `list.itemCard.toggle`) flips its done | TS-05-06 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-7 | shapeup/retro-todo/shaping/shaping.md R7 | PASS | UC-07/UC-08: `ItemOrder.sort` puts every done item after every open item, and within each group orders (+2) | TS-05-01 (+2) → PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-21 | shapeup/retro-todo/shaping/shaping.md R7 (split 2/4) | PASS | UC-07/UC-08: `ItemOrder.sort` puts every done item after every open item, and within each group orders (+2) | TS-04-04 (+2) → PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-22 | shapeup/retro-todo/shaping/shaping.md R7 (split 3/4) | PASS | UC-05: Marking Bread done places it in the done group before Buy milk (Bread is newer-created) | TS-05-04 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-23 | shapeup/retro-todo/shaping/shaping.md R7 (split 4/4) | PASS | UC-05: Toggling Bread done then not done returns it above Buy eggs, its creation-order place among | TS-05-03 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-8 | shapeup/retro-todo/shaping/shaping.md R8 | PASS | UC-08: A done card carries the state id `item.done` and a checked box (✓); an open card carries (+1) | TS-05-05 (+1) → PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-24 | shapeup/retro-todo/shaping/shaping.md R8 (split 2/2) | PASS | UC-07/UC-08: Done-item text uses a token distinct from open-item text (`inkMuted`/`surfaceDone` vs (+2) | TS-05-05 (+1) → PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-9 | shapeup/retro-todo/shaping/shaping.md R9 | PASS | UC-03/UC-06: The item delete icon (`list.deleteItemButton`) opens `Delete "Buy milk"?` and does not (+1) | TS-06-01 (+3) → PASS,PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-10 | shapeup/retro-todo/shaping/shaping.md R10 | PASS | UC-08: Weekend opens to "No items yet" / "Add your first item above" (component id (+2) | TS-04-04 (+2) → PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-11 | shapeup/retro-todo/shaping/shaping.md R11 | no evidence | UC-07/UC-08: `RetroCard` is the single card primitive, with `surface` and `surfaceDone` variants, so a | — | — |
| REQ-25 | shapeup/retro-todo/shaping/shaping.md R11 (split 2/2) | no evidence | UC-07/UC-08: `RetroCard` is the single card primitive, with `surface` and `surfaceDone` variants, so a (+1) | — | — |
| REQ-12 | shapeup/retro-todo/shaping/shaping.md R12 | no evidence | UC-07/UC-08: Every text/background token pair actually used (`ink` on `surface`, `inkMuted` on | — | — |
| REQ-26 | shapeup/retro-todo/shaping/shaping.md R12 (split 2/2) | no evidence | UC-07/UC-08: The card border (`ink` on `background`) and the `RetroCheck` box have a contrast ratio of | — | — |
| REQ-13 | shapeup/retro-todo/shaping/shaping.md R13 | PASS | UC-07/UC-08: Palette, type sizes and card treatment are defined once — in `color.json`, `float.json` (+2) | TS-08-07 → PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-14 | shapeup/retro-todo/shaping/shaping.md R14 | PASS | UC-07/UC-08: `seed()` yields Groceries (Buy milk done, Buy eggs, Bread), Work (Book meeting room done, (+2) | TS-07-01 (+2) → PASS,PASS,PASS | b12dbc40cbd3, e8f32144ce14, 1818a2ba6047, f8ad992d1f7a |
| REQ-27 | shapeup/retro-todo/shaping/shaping.md R14 (split 2/2) | no evidence | UC-07/UC-08: The store and repository keep data in memory only — no file, preferences or database API (+1) | — | — |
| REQ-15 | shapeup/retro-todo/shaping/shaping.md R15 | no evidence | UC-07/UC-08: Every visible string in `resources/base/element/string.json` is in English (no non-ASCII (+4) | — | — |

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

## Evaluation

| Criterion | Tier | Verdict | Confidence | Evidence | traces_to |
|---|---|---|---|---|---|
| TS-01-01 | local | PASS | high | `CreateList.test.ets:22` — blank/whitespace name → `LIST_NAME_EMPTY`, no list added; t0-test.sh green | REQ-17 |
| TS-01-02 | local | PASS | high | `CreateList.test.ets:33` — "Travel" twice → 2 lists, same name, different id | REQ-18 |
| TS-01-03 | local | PASS | high | `CreateList.test.ets:43` — `"  Trips "` stores `"Trips"` | REQ-17 |
| TS-01-04 | device | PASS | high | `device-flows/list-name/TS-01-04.flow` named PASS — new "Travel" card first, order Travel→Groceries | REQ-1 |
| TS-01-05 | device | PASS | high | `device-flows/list-name/TS-01-05.flow` named PASS — empty SAVE shows "Name can't be empty", dialog stays | REQ-17 |
| TS-02-01 | local | PASS | high | `RenameList.test.ets:19` — blank name → `LIST_NAME_EMPTY`, old name kept | REQ-16, REQ-19 |
| TS-02-02 | local | PASS | high | `RenameList.test.ets:29` — rename keeps `id`, `createdAt`, items | — |
| TS-02-03 | local | PASS | high | `RenameList.test.ets:44` — unknown id → `LIST_NOT_FOUND` | REQ-16 |
| TS-02-04 | device | PASS | high | `device-flows/list-name/TS-02-04.flow` named PASS — dialog pre-filled, "Groceries" appears twice (card+field) | REQ-16 |
| TS-03-01 | local | PASS | high | `DeleteList.test.ets:19` — delete A removes only A's items, B intact | REQ-4 |
| TS-03-02 | local | PASS | high | `DeleteList.test.ets:35` — unknown id → `LIST_NOT_FOUND` | REQ-4 |
| TS-03-03 | device | PASS | high | `device-flows/delete-confirm/TS-03-03.flow` named PASS — CANCEL keeps list+items | REQ-4 |
| TS-03-04 | device | PASS | high | `device-flows/delete-confirm/TS-03-04.flow` named PASS — confirm message for seeded list | REQ-4 |
| TS-04-01 | local | PASS | high | `AddItem.test.ets:20` — empty/blank title → `ITEM_TITLE_EMPTY`, no item | REQ-20 |
| TS-04-02 | local | PASS | high | `AddItem.test.ets:33` — new item open, visible only under its list | REQ-5 |
| TS-04-03 | device | PASS | high | `device-flows/toggle-and-add/TS-04-03.flow` named PASS — empty ADD shows error, keeps text | REQ-20 |
| TS-04-04 | device | PASS | high | `device-flows/toggle-and-add/TS-04-04.flow` named PASS — Weekend invitation replaced by card | REQ-5, REQ-21, REQ-10 |
| TS-05-01 | local | PASS | high | `ItemOrder.test.ets:11` — done items after every open item | REQ-7, REQ-21 |
| TS-05-02 | local | PASS | high | `ItemOrder.test.ets:19` — each group newest-created first | REQ-7, REQ-21 |
| TS-05-03 | local | PASS | high | `ToggleItem.test.ets:51` — toggling Bread twice returns it above Buy eggs | REQ-23 |
| TS-05-04 | local | PASS | high | `ToggleItem.test.ets:42` — Bread done sits before Buy milk, open group is Buy eggs only | REQ-22 |
| TS-05-05 | device | PASS | high | `device-flows/toggle-and-add/TS-05-05.flow` named PASS — `item.done`/`item.open` ids + "✓" count flip on toggle | REQ-8, REQ-24 |
| TS-05-06 | local | PASS | high | `ToggleItem.test.ets:32` — unknown id → `ITEM_NOT_FOUND`, no state change | REQ-6 |
| TS-05-07 | device | PASS | high | `device-flows/toggle-and-add/TS-05-07.flow` named PASS — reorder happens on the same frame, no animation wait | REQ-2 |
| TS-06-01 | local | PASS | high | `DeleteItem.test.ets:19` — removes only that item | REQ-9 |
| TS-06-02 | local | PASS | high | `DeleteItem.test.ets:32` — unknown id → `ITEM_NOT_FOUND` | REQ-9 |
| TS-06-03 | device | PASS | high | `device-flows/delete-confirm/TS-06-03.flow` named PASS — CANCEL keeps item, DELETE removes it | REQ-9 |
| TS-06-04 | device | PASS | high | `device-flows/delete-confirm/TS-06-04.flow` named PASS — ✕ opens dialog, `item.done` count unchanged (no toggle) | REQ-9 |
| TS-06-05 | device | PASS | high | `device-flows/delete-confirm/TS-06-05.flow` named PASS — last item deleted shows "No items yet" | REQ-10 |
| TS-07-01 | local | PASS | high | `InMemoryTodoRepository.test.ets:41` — `seed()` deterministic across two fresh stores | REQ-14 |
| TS-07-02 | local | PASS | high | `InMemoryTodoRepository.test.ets:46` — Groceries 1/3, Weekend 0 items | REQ-2 |
| TS-07-03 | local | PASS | high | `InMemoryTodoRepository.test.ets:54` — deleting every list → `status` Empty | REQ-0 |
| TS-07-04 | device | PASS | high | `device-flows/lists-and-open/TS-07-04.flow` named PASS — invitation + button on empty P1 | REQ-0 |
| TS-07-05 | device | PASS | high | `device-flows/lists-and-open/TS-07-05.flow` named PASS — cold start, 3 seeded cards, newest first | REQ-14 |
| TS-07-06 | device | PASS | high | `device-flows/lists-and-open/TS-07-06.flow` named PASS — `aa force-stop`+relaunch (real process kill, `scripts/ui-flow.sh:112`) restores exactly the seed | REQ-14 |
| TS-08-01 | local | PASS | high | `InMemoryTodoRepository.test.ets:72` — Groceries orders Bread, Buy eggs, Buy milk | REQ-7 |
| TS-08-02 | local | PASS | high | `InMemoryTodoRepository.test.ets:78` — Work orders Send weekly report, Book meeting room | — |
| TS-08-03 | local | PASS | high | `InMemoryTodoRepository.test.ets:84` — Work items never appear under Groceries | REQ-3 |
| TS-08-04 | device | PASS | high | `device-flows/lists-and-open/TS-08-04.flow` named PASS — Weekend opens to empty invitation | REQ-10 |
| TS-08-05 | device | PASS | high | `device-flows/lists-and-open/TS-08-05.flow` named PASS — order Bread→Buy eggs→Buy milk, exactly 1 `item.done` (Buy milk, per TS-08-01 order) | REQ-8 |
| TS-08-06 | device | PASS | high | `device-flows/lists-and-open/TS-08-06.flow` named PASS — Back returns to P1 with cards rendered (not Loading) | REQ-24 |
| TS-08-07 | local | PASS | high | Direct probe: `git status --porcelain app/entry/src/main/module.json5 app/entry/src/main/resources/base/profile/main_pages.json` → empty (byte-unchanged vs HEAD); `find app/entry/src -iname "*route_map*"` → no match under source (only a build-intermediate copy under `.test/`, not authored) | REQ-13 |

### Refuted criteria and bugs

None.

## QA findings

| Lens | Hunted | Findings | Of which contradicts-EVAL |
|---|---|---|---|
| ① Boundary | C-01 | 1 | 0 |
| ② Concurrency | C-02, C-03 | 1 | 0 |

→ details live in the run trace under the `## Discovered` section
  ingest appends for this hunt's order.

## Discovered, not built

+ No vi_VN/element/string.json exists in the project — REQ-15's vi_VN parity requirement has no locale resource file to check against; pre-existing gap, not introduced by this scope
+ app/entry/src/ohosTest/ets/test/ListsScreen.test.ets is listed in this scope's allowed substrate but does not exist on disk; only List.test.ets is present under ohosTest

---

*Run state (board, orders, results, T0 artifacts, evaluation and QA reports) stays in the
gitignored local tier (ADR-0001). This report
is the frozen conclusion of it.*
