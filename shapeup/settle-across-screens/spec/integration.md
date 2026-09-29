---
type: integration
feature: settle-across-screens
---

# Integration — settle-across-screens

No new cross-system flow, no network, no persistence change. One in-process seam moves up one
level of the object graph (`TodoModule -> SettleWindow -> ListViewModel`, replacing `ListViewModel`
owning its own window fields), and one device-flow check (already fully supported by
`scripts/ui-flow.sh`) proves the outside-the-window case is unaffected across a real navigation.

## In-process chain (one seam moved, no new external dependency)

| Node | What | Notes |
|---|---|---|
| N4 | `TodoModule.listViewModel(listId, clock?)` | now also passes `this.window` (the module's one `SettleWindow`, built in `TodoModule`'s constructor) into every `ListViewModel` it builds |
| N1 | `ListViewModel.onToggle(itemId)` | reads/writes `this.window` (shared or private-default) instead of its own fields |
| N2 | `ListViewModel.onDeleteItem(itemId)` | reads `this.window`; never writes it (unchanged rule, delete-settle INV-03) |
| N3 | `SettleWindow.isSettling(now)` / `mark(now)` | new class; logic moved verbatim from `ListViewModel`'s private method/fields |

No repository, no `Clock` seam change — `SettleWindow` receives `now: number` from its caller's
existing `clock.now()` call, the same way `isSettling` does today.

## Device-flow language

`scripts/ui-flow.sh` already supports every step this pitch's device check needs: `launch`,
`tap`, `back`, `tap` again (reopen), `tap id "list.deleteItemButton"`, `expect text`. No new op is
required — unlike toggle-once (which added `doubletap`), this pitch's device check (TS-01-06,
outside the window, R3) is a sequence of existing ops. The spike
(`spike-device-flow-ownership.md`) confirmed the flow language's own `settle()` (0.8s between
steps) makes it structurally incapable of landing a tap *inside* a 400ms window, which is exactly
why R1/R2 (inside-the-window) stay unit-test-only and only R3 (outside) is proven on the device.

| Risk | Guard |
|---|---|
| `SettleWindow` is instantiated fresh inside `listViewModel()` instead of stored once on `TodoModule` | would silently reproduce the exact bug this pitch fixes (a new window per visit) — INV-02 exists to name this directly; TS-01-01..04's two-`ListViewModel` setup would catch it (both VMs would see an unset window, so a ✕ tap the shared-window test expects to be ignored would open the dialog instead) |
| The flow-directory this pitch's device check writes into is not granted to the scope that owns `ListViewModel.ets`/`TodoModule.ets` | seeded to discovery (D1, orient) — a MAP SCOPES / L1b concern, not fixable in this phase; `probe owner` returning null for the flow path repeated this exact failure on retro-todo run 8 |
| `onDeleteItem` is changed to also call `mark` while wiring the shared window through | would reopen the window on every delete, silently changing R1/R2's boundary — INV-03 names this; TS-01-01/02's two-VM setup (delete first, then probe at the *original* window's edge) would catch a drift here too |

## Silent-failure risks specific to this pitch

- `ListViewModel`'s constructor already has 7 existing call sites (1 prod, 6 unit test); adding
  the `window` param as anything other than the new **last** optional positional argument would
  break call-site compatibility silently at the type level in some of them and require touching
  every one — the ctor-compatibility spike (discovered-seed.md D3) already confirmed the
  trailing-optional-param shape is source-compatible with all 7 unchanged.
- Building `SettleWindow` in two places (`features/todo/domain/` and `shared/kernel/`) across two
  execution attempts would silently duplicate the class with two import paths — domain-model.md
  picks `features/todo/domain/SettleWindow.ts` explicitly (discovered-seed.md D2) so no attempt
  re-decides it.
