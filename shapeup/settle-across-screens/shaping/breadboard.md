---
shaping: true
feature: "[[settle-across-screens]]"
status: breadboarded
---

# Settle Across Screens — Breadboard

Designed from Shape A in [[shaping]], on the list screen delete-settle shipped. Affordance IDs (U, N, S)
are the traceability anchors.

## Fat Marker Sketch (B0)

```
P2 List ── back ──▶ P1 My Lists ── open Groceries ──▶ P2 List (a new visit)
toggle "Bread"                                         ✕ on row 1 inside 400 ms → ignored
      └────────────── one settle window (S1), owned by the module ──────────────┘
```

## Places

| # | Place | Kind | Description |
|---|---|---|---|
| P1 | My Lists | screen | The lists (unchanged) |
| P2 | List | screen | The items of one list; a new view model on every visit (unchanged) |

## UI Affordances

| # | Place | Affordance | Control | Wires Out |
|---|---|---|---|---|
| U1 | P2 | item card toggle (`list.itemCard.toggle`) | tap | → N1 |
| U2 | P2 | item card ✕ (`list.deleteItemButton`) | tap | → N2 |
| U3 | P2 | back (`list.backButton`) | tap | → P1 |
| U4 | P1 | list card (`lists.card.open`) | tap | → P2, → N4 |

## Code Affordances

| # | Place | Affordance | Wires Out |
|---|---|---|---|
| N1 | P2 | `ListViewModel.onToggle(itemId)` — runs only outside S1, then marks it | reads + writes S1 |
| N2 | P2 | `ListViewModel.onDeleteItem(itemId)` — opens the dialog only outside S1 | reads S1 |
| N3 | — | `SettleWindow.isSettling(now)` / `mark(now)` | S1 |
| N4 | — | `TodoModule.listViewModel(listId)` — hands the module's one `SettleWindow` to each new view model | → N1, N2 |

## Data Stores

| # | Store | Description |
|---|---|---|
| S1 | settle window | when the last toggle happened, for the whole app; one named constant for its length |

## Vertical slices

- **V1** — `SettleWindow` moved out of `ListViewModel` and owned by `TodoModule`, with unit tests over two view
  models sharing one window (R1, R2, R3, R4).
- **V2** — A device flow for R3: back, reopen the list, and a ✕ tap outside the window opens the dialog naming
  that row's item.
