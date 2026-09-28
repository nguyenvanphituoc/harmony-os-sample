---
type: integration
feature: toggle-once
---

# Integration — toggle-once

No new cross-system flow, no network, no persistence change. Two integration surfaces: the in-
process `ListViewModel -> Clock` chain, and the device-flow language (`scripts/ui-flow.sh`) that
has to be able to deliver a real double-tap gesture to prove R1/R2 on the emulator (R5).

## In-process chain (unchanged shape, one widened seam)

| Node | What | Notes |
|---|---|---|
| N1 | `ListViewModel.onToggle(itemId)` | gains the settle-window check (UC-01); calls N2 only outside the window |
| N2 | `ToggleItem.execute(itemId)` | unchanged (retro-todo) |
| — | `TodoModule.listViewModel(listId)` | widens to pass a `Clock` (default `SystemClock`) into `ListViewModel`'s constructor — the only composition-root change this pitch makes |

## Device-flow language

`scripts/ui-flow.sh` embeds a Python step interpreter (`tap`, `type`, `expect`, `wait`, `back`,
`launch`) that calls `settle()` — an 800ms sleep — after every scripted action. A1's device flows
(R1, R2, R3) need one new step, `doubletap`, that the interpreter dispatches to two `uitest
uiInput click` calls at the same coordinates.

| Risk | Guard |
|---|---|
| `doubletap` reuses the existing per-action `settle()` between its two clicks | the two clicks would land roughly 800ms apart — an order of magnitude past any few-hundred-ms settle window — and the flow would never actually exercise the fix. `doubletap` must issue its two clicks back-to-back with no `settle()` between them, then one trailing `settle()` after the pair, matching how `tap`/`type` already compose one action with one trailing `settle()` |
| The settle-window constant is chosen with no headroom over real gesture timing | the constant is proved on-device (both directions: a double-tap caught, a deliberate second tap at a normal pace let through), not only against a fake clock in the unit test |
| A screen or ViewModel writes `TodoStore` directly, bypassing `ToggleItem` | unchanged from retro-todo — only the repository writes S1/S2; this pitch adds no new writer |
| The window is implemented per-row instead of screen-wide | INV-02 (UC-01); a per-row guard would miss the case where the second touch lands on a *different* row object entirely (the reproduced fault) |

## Silent-failure risks specific to this pitch

- A settle window implemented with real wall-clock `Date.now()` and no injectable `Clock` makes the
  unit test slow and flaky rather than deterministic — the `Clock` seam (domain-model.md) exists so
  the test controls time exactly, the same pattern `InMemoryTodoRepository.test.ets` already uses.
- `windowMs` picked without measuring the device flow's own click-to-click latency risks either
  swallowing a deliberate second tap (breaks R3) or failing to catch a real double-tap (breaks
  R1/R2) — both directions are device-checked (TS-01-04..06), not assumed from the unit test alone.
