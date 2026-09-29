---
type: ux-behavior
feature: delete-settle
---

# UX Behavior — delete-settle

One breadboard Place with UI affordances: P2 List (unchanged layout, per the breadboard's B0
sketch). The four-state contract (Loading, Empty, Ready, Error) is unchanged from retro-todo's
`ux-behavior.md` — this pitch changes no state, no layout and no copy; it changes what happens
when the Ready state's ✕ affordance is touched while a toggle's settle window is still open.

## Screen: List (P2) — delta only

Everything not listed here (states, other affordances, visual rules) is exactly as toggle-once
shipped it. Use case: [[UC-01]].

| ID | Affordance | Behavior (this pitch) |
|---|---|---|
| U1 | item card ✕ (`list.deleteItemButton`, tap) | a tap that lands while the settle window is open (opened by the last toggle) is silently ignored — no dialog, no error, no visible change; a tap outside the window opens the delete dialog naming that row's item exactly as before |

## ASCII flow — the delete guard reads the same window a toggle opens

```
idle ──tap on card X's ✕──> window open? ──yes──> ignored (no-op, no dialog)
                                         └─no───> ItemDeleteOpener.openDelete(X) — dialog names X
```

The window is the same screen-wide state toggle-once already owns: a ✕ tap that lands on a row
holding a *different* item than the one the user meant (because the list re-sorted under the
finger after a toggle) is guarded exactly like a ✕ tap on the same row that just toggled — this is
why the fix reads `isSettling` rather than adding any per-row state.

## Cases

| Case | When | Outcome |
|---|---|---|
| ✕ tap right after a toggle | inside the settle window opened by that toggle | no dialog opens for any item; nothing deletes (R1) |
| ✕ tap with no recent toggle | outside any settle window | the delete dialog opens, naming that row's item, as before (R2) |
| A toggle, before or after a delete | any time | unaffected: the window still swallows a second toggle and still lets a deliberate one through, and done items still sink at once (R3) — `onToggle` code is untouched by this pitch |

No new Loading/Empty/Error branch, no new dialog, no new copy — nothing here touches
`resources/base` or the visual rules, so no `vi_VN` parity concern (KB-BA-006 does not apply: no
key is added to `string.json`).
