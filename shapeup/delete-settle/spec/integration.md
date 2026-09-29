---
type: integration
feature: delete-settle
---

# Integration — delete-settle

No new cross-system flow, no network, no persistence change. Two integration surfaces, both
already built by toggle-once: the in-process `ListViewModel -> Clock` chain (this pitch adds a
second reader, not a second writer), and the device-flow language (`scripts/ui-flow.sh`), which
already has every step this pitch's one device check needs.

## In-process chain (unchanged shape, no new seam)

| Node | What | Notes |
|---|---|---|
| N1 | `ListViewModel.onDeleteItem(itemId)` | gains the settle-window check (UC-01); calls N2 only outside the window |
| N2 | `ItemDeleteOpener.openDelete(itemId, title)` | unchanged (toggle-once / retro-todo) |
| — | `TodoModule.listViewModel(listId, clock?)` | already passes a real `Clock` (toggle-once) — no composition-root change this pitch makes |

## Device-flow language

`scripts/ui-flow.sh` already supports every step this pitch's device check needs: a single `tap`
on `list.deleteItemButton` with no toggle before it (TS-01-04, proving R2). Unlike toggle-once,
this pitch adds **no** new step — the `doubletap` op toggle-once added stays unused here, since
the pitch's own rabbit hole scopes R1 (the inside-the-window case) to the unit test only; a device
flow cannot reliably land a second tap inside 400ms because each step looks its target up in the
layout tree first.

| Risk | Guard |
|---|---|
| The guard is placed after the item lookup instead of before it | behaviorally identical for R1/R2 (spike finding: a settling return never opens the dialog either way), but placed before the lookup here (UC-01 Step 2) so an ignored tap does the least work |
| A screen or ViewModel opens the dialog directly, bypassing `ItemDeleteOpener` | unchanged from toggle-once — only `onDeleteItem` calls `openDelete`; this pitch adds no new caller |
| The guard is implemented per-row instead of screen-wide | INV-02 (UC-01) — a per-row guard would miss the case where the ✕ lands on a *different* row object entirely (the reproduced fault, QA C-02) |

## Silent-failure risks specific to this pitch

- A guard added after `this.store.items.find(...)` instead of before it would still work
  functionally (the dialog never opens either way), but would do a needless lookup on every
  ignored tap — not a correctness risk, noted only because the spike considered both orderings.
- Reusing `isSettling`/`lastToggleAt`/`windowMs` as read-only state means a bug that makes
  `onDeleteItem` accidentally *write* `lastToggleAt` would silently change toggle behavior too
  (R3) — TS-01-03 exists specifically to catch that class of regression, not just to prove A2 in
  isolation.
