---
type: ux-behavior
feature: settle-across-screens
---

# UX Behavior — settle-across-screens

Two breadboard Places own UI affordances: P1 My Lists and P2 List (unchanged layout on both, per
the breadboard's B0 sketch). The four-state contract (Loading, Empty, Ready, Error) is unchanged
from retro-todo's `ux-behavior.md` — this pitch changes no state, no layout and no copy on either
screen; it changes how long a guard already visible to the user (toggle-once's settle window)
lasts on P2: across a visit to the screen, not only within one.

## Screen: My Lists (P1) — unchanged

Entirely unchanged by this pitch. Listed here because the breadboard gives it one UI affordance
(U4) that this pitch's use case cites as the trigger for a revisit to P2 — not because P1 itself
does anything new.

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U4 | list card (`lists.card.open`, tap) | unchanged: opens P2 for that list, building a new `ListViewModel` exactly as before — but that new `ListViewModel` now reads the same `SettleWindow` the previous visit's `ListViewModel` (if any) wrote to |

## Screen: List (P2) — delta only

Everything not listed here (states, other affordances, visual rules) is exactly as
delete-settle shipped it. Use case: [[UC-01]].

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U1 | item card toggle (`list.itemCard.toggle`, tap) | a tap that lands while the settle window opened by an earlier toggle is still open — even if the screen was left and reopened since — is silently ignored (no toggle, no error); outside the window it toggles exactly as before |
| U2 | item card ✕ (`list.deleteItemButton`, tap) | a tap that lands while the window is still open — even across a leave-and-reopen — is silently ignored (no dialog, no error); outside the window the delete dialog opens naming that row's item exactly as before |
| U3 | back (`list.backButton`, tap) | unchanged: pops to P1. Leaving the screen no longer resets the settle window (this pitch's fix) |
| U4 | list card (`lists.card.open`, tap) | unchanged: opens P2 for that list, building a new `ListViewModel` exactly as before — but that new `ListViewModel` now reads the same `SettleWindow` the previous visit's `ListViewModel` wrote to |

## ASCII flow — leaving and reopening no longer resets the window

```
P2 (visit 1): tap toggle on "Bread" ──> SettleWindow.mark(now) [owned by TodoModule]
     │ back
P1
     │ reopen "Groceries"
P2 (visit 2, a NEW ListViewModel, SAME SettleWindow):
     tap ✕ on row 1, inside the window ──> window.isSettling(now) == true ──> ignored, no dialog
     tap toggle on row 1, inside the window ──> ignored, no toggle
     (same taps, once the window has elapsed) ──> dialog opens / item toggles, exactly as today
```

## Cases

| Case | When | Outcome |
|---|---|---|
| ✕ tap after a toggle, screen left and reopened in between | inside the settle window that toggle opened | no dialog opens for any item; nothing deletes (R1) |
| Toggle tap after a toggle, screen left and reopened in between | inside the settle window that toggle opened | no toggle happens; nothing changes (R2) |
| ✕ tap on a reopened list, no toggle recent enough | outside any settle window | the delete dialog opens, naming that row's item, as before (R3) |
| Toggle tap on a reopened list, no toggle recent enough | outside any settle window | the item toggles, as before (R3) |
| Toggle then ✕ then toggle, all within one visit, no navigation | any time within one visit | unaffected: toggle-once's and delete-settle's existing behavior, unit-tested and device-tested, is unchanged (R4) |

No new Loading/Empty/Error branch, no new dialog, no new copy — nothing here touches
`resources/base` or the visual rules, so no `vi_VN` parity concern (KB-BA-006 does not apply: no
key is added to `string.json`).
