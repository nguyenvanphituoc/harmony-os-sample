---
shaping: true
feature: "[[delete-settle]]"
status: breadboarded
---

# Delete Settle — Breadboard

Designed from Shape A in [[shaping]], on the list screen toggle-once shipped. Affordance IDs (U, N, S)
are the traceability anchors.

## Fat Marker Sketch (B0)

```
P2 List (unchanged layout)
┌─────────────────────────────┐
│ [←] GROCERIES               │
│ [ New item...     ] [ ADD ] │
│ ┃ [ ] Bread          [✕] ┃  │  ← slid up after "Buy eggs" was toggled; a ✕ tap now is ignored
│ ┃ [x] Buy eggs       [✕] ┃  │
│ ┃ [x] Buy milk       [✕] ┃  │
└─────────────────────────────┘
```

## Places

| # | Place | Kind | Description |
|---|---|---|---|
| P2 | List | screen | The items of one list, open on top, done at the bottom (retro-todo) |

## UI Affordances

| # | Place | Affordance | Control | Wires Out |
|---|---|---|---|---|
| U1 | P2 | item card ✕ (`list.deleteItemButton`) | tap | → N1 |

## Code Affordances

| # | Place | Affordance | Wires Out |
|---|---|---|---|
| N1 | P2 | `ListViewModel.onDeleteItem(itemId)` — opens the dialog only outside the settle window | → N2, reads S1 |
| N2 | P2 | `ItemDeleteOpener.openDelete(itemId, title)` (unchanged) | → delete dialog |

## Data Stores

| # | Store | Description |
|---|---|---|
| S1 | settle window | when the last toggle happened on this screen (toggle-once); read, never written, by delete |

## Vertical slices

- **V1** — The settle window covers delete in the list view model, with unit tests for both sides (R1, R2, R3).
- **V2** — A device flow for R2 on the seeded list: a ✕ tap with no toggle before it opens the dialog naming that item.
