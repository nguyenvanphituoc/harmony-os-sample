---
shaping: true
feature: "[[list-above-keyboard]]"
status: breadboarded
---

# List Above Keyboard — Breadboard

Designed from Shape A in [[shaping]], on the list screen lists-badge-sync shipped. Affordance IDs (U, N, S)
are the traceability anchors.

## Fat Marker Sketch (B0)

```
P2 List, new-item field focused
┌─────────────────────────────┐
│ [←] GROCERIES               │
│ [ New item...     ] [ ADD ] │
│ ┃ [ ] Batteries      [✕] ┃  │  ┐
│ ┃ [ ] Bread          [✕] ┃  │  │ the list ends here now, and scrolls
│ ┃ [ ] Buy eggs       [✕] ┃  │  ┘ ↓ Buy milk ✓ is one swipe away
├─────────────────────────────┤
│        soft keyboard        │
└─────────────────────────────┘
```

## Places

| # | Place | Kind | Description |
|---|---|---|---|
| P2 | List | screen | The items of one list, with the add row above them |
| P3 | List-name dialog | dialog | New list / rename list, with a text field (unchanged; must stay visible) |

## UI Affordances

| # | Place | Affordance | Control | Wires Out |
|---|---|---|---|---|
| U1 | P2 | new-item field (`list.newItemField`) | focus / type | → keyboard up → N1 |
| U2 | P2 | ADD (`list.addButton`) | tap | → `AddItem` (unchanged) |
| U3 | P2 | item list | swipe | scrolls, now that it fits above the keyboard |
| U4 | P3 | name field (`listname.field`) | focus / type | → keyboard up → N1 |

## Code Affordances

| # | Place | Affordance | Wires Out |
|---|---|---|---|
| N1 | P2 (and P3 if window-wide) | keyboard avoid setting chosen by the spike | resizes P2's content above the keyboard |
| N2 | — | `ui-flow.sh` `swipe id "<node>" up|down` step | device check |

## Data Stores

| # | Store | Description |
|---|---|---|
| S1 | `TodoStore` items | unchanged |

## Vertical slices

- **V1** — The spike's keyboard setting on the list screen, with device flows for R1, R2 and R3, and the
  `swipe` step they need.
- **V2** — The dialog check for R4.
