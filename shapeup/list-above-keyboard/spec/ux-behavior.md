---
type: ux-behavior
feature: list-above-keyboard
---

# UX Behavior — list-above-keyboard

Two breadboard Places own UI affordances (P2 List, P3 List-name dialog); My Lists (P1) is cited
below only because R3 names it explicitly as a screen that must render exactly as today. The
four-state contract (Loading, Empty, Ready, Error) is unchanged everywhere — this pitch changes no
state, no copy and no affordance's behavior; it changes how much vertical space P2's content and
list resolve against while the keyboard is up.

## Screen: My Lists (P1) — unchanged

Entirely unchanged by this pitch (R3). Listed here because it is the screen the No-goes explicitly
scope R3 to, and because its `lists.newButton` opens P3, one of the two Places this pitch does
touch.

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| — | `lists.newButton` (tap) | unchanged: opens P3 (new-list dialog) |
| — | `lists.card.open` (tap) | unchanged: opens P2 for that list |
| — | `lists.renameButton` (tap) | unchanged: opens P3 (rename dialog) |

## Screen: List (P2) — the keyboard no longer covers unreachable items

Everything not listed here (item order, add/toggle/delete behavior, error text, the Loading/Empty/
Error states) is exactly as lists-badge-sync shipped it. Use case: [[UC-01]].

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U1 | new-item field (`list.newItemField`, focus / type) | focusing it raises the keyboard as before; now the list screen's content resizes to fit above it (N1) instead of staying full-height and unreachable at the bottom (R1) |
| U2 | ADD (`list.addButton`, tap) | unchanged: adds the item (`AddItem`, unchanged domain logic) — with the keyboard still up afterward, the new item is visible and every done item stays reachable by scrolling (R2) |
| U3 | item list (`list.itemList` or equivalent, swipe) | new: scrolls the list, now that it fits above the keyboard and has something to scroll to (N1 + N2's new `swipe` device step) |
| — | back (`list.backButton`, tap) | unchanged |

With no field focused (keyboard down), P2 renders byte-for-byte as it does today — the setting
this pitch adds is a keyboard-driven resize, not a permanent layout change (R3).

## Screen: List-name dialog (P3) — stays fully visible

`promptAction.openCustomDialog` overlay (`ListNameDialogHost.ets`), used for both "new list" (from
P1) and "rename" (from P1's `lists.renameButton`) — same component (`ListNameDialog.ets`), same
field id, different `ListNameForm` content. Not a child of `ListPage`'s `NavDestination` tree.

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U4 | name field (`listName.field` — code casing; the breadboard's own `listname.field` does not match, discovered-seed.md D1) (focus / type) | focusing it raises the keyboard as before; the dialog itself (title, field, error text, Save/Cancel) stays fully visible above the keyboard regardless of which setting Wire/Build picks (R4) |

## ASCII flow — the list gives way to the keyboard

```
P2, no field focused                      P2, list.newItemField focused
┌─────────────────────────────┐           ┌─────────────────────────────┐
│ [←] GROCERIES                │           │ [←] GROCERIES                │
│ [ New item...     ] [ ADD ]  │           │ [ New item...     ] [ ADD ]  │
│ ┃ [ ] Buy eggs         [✕] ┃ │           │ ┃ [ ] Buy eggs         [✕] ┃ │  ┐ list's
│ ┃ [ ] Bread            [✕] ┃ │           │ ┃ [ ] Bread            [✕] ┃ │  │ own height
│ ┃ [x] Buy milk         [✕] ┃ │           ├─────────────────────────────┤  ┘ shrinks
│                               │           │        soft keyboard         │
└─────────────────────────────┘           └─────────────────────────────┘
  (today's layout — unchanged, R3)           swipe U3 up ──> Buy milk [x] scrolls
                                              into view and stays tappable (R1)
```

## Cases

| Case | When | Outcome |
|---|---|---|
| Field focused, list not yet scrolled | keyboard just raised | items above the keyboard's top edge are visible/tappable; the list's own height has shrunk to fit above the keyboard, so it now has something to scroll (R1) |
| Field focused, swipe up on the list | keyboard up | the last item(s), including done ones sunk to the bottom, become visible/tappable without closing the keyboard (R1) |
| ADD tapped with the keyboard up | new item added, keyboard stays up | the new item is visible (it lands at the top of the open items — unaffected by this pitch) and every done item is still reachable by scrolling (R2) |
| No field focused | keyboard down | P2 and P1 render exactly as today — no resize, no layout delta (R3) |
| List-name dialog open, field focused | keyboard up | the dialog (title, field, error, Save/Cancel) stays fully visible — no part of it is covered (R4) |

No new Loading/Empty/Error branch, no new dialog, no new copy — nothing here touches
`resources/base`, so no `vi_VN` parity concern (KB-BA-006 does not apply: no key is added to
`string.json`).
