---
type: ux-behavior
feature: lists-badge-sync
---

# UX Behavior — lists-badge-sync

Two breadboard Places own UI affordances: P1 My Lists and P2 List. The four-state contract
(Loading, Empty, Ready, Error) is unchanged — this pitch changes no state, no layout and no copy
on either screen; it changes what the already-mounted P1 card shows once P2 has changed the store
underneath it.

## Screen: My Lists (P1) — the badge's contract

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U1 | list card badge (`app.string.progress_done`, "x/y done" / `app.string.progress_none`) | reads the current `done`/`total` for that list at all times MY LISTS is on screen — including immediately after returning from a List screen (P2) that changed the list, whether or not MY LISTS was torn down and rebuilt in between |
| U2 | list card (`lists.card.open`, tap) | unchanged: opens P2 for that list |
| — | list card name | reads the list's current name at all times MY LISTS is on screen, under the same rule as U1's count |
| — | card order | sorted by `createdAt` descending (unchanged, `ListsViewModel.cards`); renaming a list does not change this order, because rename does not touch `createdAt` |

## Screen: List (P2) — unchanged

Everything here (states, affordances, the settle window, visual rules) is exactly as
settle-across-screens shipped it. Use case: [[UC-01]] (P2's affordances are the trigger for a
store change P1 must reflect; P2 itself renders none of the fix).

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U3 | item toggle (`list.itemCard.toggle`), add (`lists.newButton`-equivalent add-item control), ✕ (`list.deleteItemButton`) | unchanged: each reassigns `store.items` (or `store.lists` for a rename done from P1) exactly as before |
| U4 | back (`list.backButton`, tap) | unchanged: pops to P1 — the pop itself is not what fixes the badge; U1's read on the still-mounted P1 card is |

## ASCII flow — the card must read live, not remembered

```
P1 (mounted): "Groceries"  1/3 done
     │ tap U2 (open Groceries)
P2: tap U3 (toggle "Bread") ──> store.items reassigned, done: 1 -> 2
     │ back (U4)
P1 (SAME mounted instance, not rebuilt): "Groceries" must now read  2/3 done  ◀── this pitch's fix
```

## Cases

| Case | Trigger | Outcome |
|---|---|---|
| Toggle an item, go back | P2 toggle, then U4 | that list's card shows the new done count (R1) |
| Add an item, go back | P2 add, then U4 | that list's card shows the new total (R2) |
| Delete an item, go back | P2 delete, then U4 | that list's card shows the new done count and/or total, as applicable (R5) |
| Rename a list, go back | rename dialog (P1's own `lists.renameButton`, unchanged trigger), then dialog confirm | that list's card shows the new name; card order is unchanged (R3, R6) |
| The committed device flow (toggle → back → expect badge) | — | passes (R4) |

No new Loading/Empty/Error branch, no new dialog, no new copy — nothing here touches
`resources/base` or the visual rules, so no `vi_VN` parity concern (KB-BA-006 does not apply: no
key is added to `string.json`).
