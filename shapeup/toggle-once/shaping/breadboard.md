---
shaping: true
feature: "[[toggle-once]]"
status: breadboarded
---

# Toggle Once — Breadboard

Designed from Shape A in [[shaping]], on the list screen retro-todo shipped. Affordance IDs (U, N, S)
are the traceability anchors.

## Fat Marker Sketch (B0)

```
P2 List (unchanged layout)
┌─────────────────────────────┐
│ [←] GROCERIES               │
│ [ New item...     ] [ ADD ] │
│ ┃ [ ] Bread          [✕] ┃  │  ← double-tap here: only Bread changes
│ ┃ [ ] Buy eggs       [✕] ┃  │  ← slides up into Bread's slot; the second touch is ignored
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
| U1 | P2 | item card toggle | tap / double-tap | → N1 |

## Code Affordances

| # | Place | Affordance | Wires Out |
|---|---|---|---|
| N1 | P2 | `ListViewModel.toggle(itemId)` — runs only outside the settle window, then opens it | → N2, → S1 |
| N2 | P2 | `ToggleItem.execute(itemId)` (unchanged) | → S2 |

## Data Stores

| # | Store | Description |
|---|---|---|
| S1 | settle window | when the last toggle happened on this screen; one named constant for its length |
| S2 | `TodoStore` items | unchanged |

## Vertical slices

- **V1** — Settle window in the list view model, with a unit test for both sides (R1, R2, R3, R4).
- **V2** — `doubletap` step in the device flow language, and device flows for R1, R2 and R3 (R5).
