---
shaping: true
feature: "[[lists-badge-sync]]"
status: breadboarded
---

# Lists Badge Sync — Breadboard

Designed from Shape A in [[shaping]], on the lists screen retro-todo shipped. Affordance IDs (U, N, S)
are the traceability anchors.

## Fat Marker Sketch (B0)

```
P2 List: toggle "Bread" ── back ──▶ P1 MY LISTS
                                    ┃ Groceries        2/3 done ┃   ← must read the new count (today: 1/3)
                                    ┃ Work             1/2 done ┃
```

## Places

| # | Place | Kind | Description |
|---|---|---|---|
| P1 | My Lists | screen | One card per list with its name and a "done/total" badge |
| P2 | List | screen | The items of one list (unchanged) |

## UI Affordances

| # | Place | Affordance | Control | Wires Out |
|---|---|---|---|---|
| U1 | P1 | list card badge ("x/y done") | display | ← N2 |
| U2 | P1 | list card (`lists.card.open`) | tap | → P2 |
| U3 | P2 | item toggle (`list.itemCard.toggle`), add, ✕ | tap | → N1 |
| U4 | P2 | back (`list.backButton`) | tap | → P1 |

## Code Affordances

| # | Place | Affordance | Wires Out |
|---|---|---|---|
| N1 | P2 | `ToggleItem` / `AddItem` / `DeleteItem` → `store.items` reassigned (unchanged) | → S1 |
| N2 | P1 | `ListsViewModel.cards` → `Repeat` → `cardBuilder` → badge text — the chain the spike checks | reads S1 |

## Data Stores

| # | Store | Description |
|---|---|---|
| S1 | `TodoStore` lists and items | observed V2 state (unchanged) |

## Vertical slices

- **V1** — Spike the chain N2, fix the link that drops the update, and the device flow for R1 (the repro).
- **V2** — Device flows for R2 (add, delete) and R3 (rename, card order).
