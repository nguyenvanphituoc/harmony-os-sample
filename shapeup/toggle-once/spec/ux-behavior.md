---
type: ux-behavior
feature: toggle-once
---

# UX Behavior — toggle-once

One breadboard Place with UI affordances: P2 List (unchanged layout, per the breadboard's B0
sketch). The four-state contract (Loading, Empty, Ready, Error) is unchanged from retro-todo's
`ux-behavior.md` — this pitch changes no state, no layout and no copy; it changes what happens
when the Ready state's item card is touched twice in quick succession.

## Screen: List (P2) — delta only

Everything not listed here (states, other affordances, visual rules) is exactly as retro-todo
shipped it. Use case: [[UC-01]].

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U1 | item card toggle (tap / double-tap anywhere on the card) | a tap that lands while the settle window is open is silently ignored — no error, no visible change, no message; a tap outside the window toggles that card exactly as before and opens a new window |

## ASCII flow — one settle window, screen-wide

```
idle ──tap on card X──> ToggleItem(X) fires, window opens (now = t0)
window open [t0, t0+windowMs) ──any tap, any card──> ignored (no-op)
window closed (now >= t0+windowMs) ──tap on card Y──> ToggleItem(Y) fires, window opens (now = t1)
```

The window is a property of the **screen**, not of any one card: a second touch that lands on a
different card object (because the list re-sorted under the finger) is ignored exactly like a
second touch on the same card — this is why A1/A2 fixes it screen-wide rather than per-row (see
the pitch's spike finding: the second touch is a genuinely different row object, not just a
different visual position).

## Cases

| Case | When | Outcome |
|---|---|---|
| Double-tap / bounced tap on one row | second touch inside the settle window | that row's state does not change a second time; no other row's state changes |
| Two deliberate taps on two different rows, normal pace | both touches land after the window from any prior toggle has closed | both rows toggle (R3) |
| Marking an item done or not done, once the window lets it through | — | unchanged: instant, no reorder animation, done items still sink to the bottom (retro-todo's ItemOrder, R4) |

No new Loading/Empty/Error branch, no new dialog, no new copy — nothing here touches
`resources/base` or the visual rules, so no `vi_VN` parity concern (KB-BA-006 does not apply: no
key is added to `string.json`).
