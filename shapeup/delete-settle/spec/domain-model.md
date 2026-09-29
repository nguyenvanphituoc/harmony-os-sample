---
type: domain-model
feature: delete-settle
---

# Domain Model — delete-settle

No new bounded context, aggregate, value object, domain event or repository method. `TodoItem`,
`TodoStore`, `ToggleItem` and `ItemDeleteOpener.openDelete` are frozen by this pitch's No-goes —
the fault this pitch fixes is which item the delete dialog names, not any domain rule about
deletion itself.

## Screen-level policy (reused, not new)

`SettleWindow` — the same screen-layer state toggle-once introduced in `ListViewModel`
(`lastToggleAt: number | null`, `windowMs` = `SETTLE_WINDOW_MS`, a single named constant). This
pitch adds no field and no constant: `onDeleteItem` becomes a second **reader** of
`isSettling(now)`, exactly as `onToggle` already is.

| Field | Type | Rule | Writer |
|---|---|---|---|
| `lastToggleAt` | `number \| null` | set to `clock.now()` only by `onToggle`, after its own settle check | `onToggle` (sole writer, unchanged) |
| `windowMs` | `number` (named constant) | one value, chosen by toggle-once, not re-derived or duplicated | — |

`isSettling(now)` = `lastToggleAt !== null && now - lastToggleAt < windowMs` (unchanged, private,
already parameterized — no toggle-specific state). `onDeleteItem(itemId)` calls
`isSettling(clock.now())` first; when it holds, `onDeleteItem` returns without looking the item
up and without calling `dialogs.openDelete` — no error, no state change, nothing surfaced to the
user. `onDeleteItem` never writes `lastToggleAt`: the window does not open, extend or reset on a
delete, only on a toggle (pitch A2).

## Testability seam

None needed. `ListViewModel`'s constructor already accepts an optional `Clock` (toggle-once), and
`onDeleteItem` already reads `this.clock` for nothing today — the guard is the first place it
reads it. `ListViewModel.test.ets`'s existing `SettableClock` double (used by TS-01-01..03 for
toggle) is reused as-is for the new delete-side rows.

## Repository / contract

Unchanged. `ItemDeleteOpener.openDelete(itemId, title)` and its wiring through
`TodoModule.listViewModel` are called exactly as before, only conditionally — no `⏳ TBD`, no new
Request/Response pair.

## Use case index

[[UC-01]] delete an item, guarded by the settle window.
