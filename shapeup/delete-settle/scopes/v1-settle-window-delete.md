---
scope_id: v1-settle-window-delete
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-1, REQ-2, REQ-3, REQ-4, REQ-5]
depends_on: []
allowed_file_substrate:
  - app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets
  - app/entry/src/test/ListViewModel.test.ets
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V1]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
---

# Scope: v1-settle-window-delete

## Why this slice

Breadboard V1: the settle window (`isSettling` / `lastToggleAt` / `SETTLE_WINDOW_MS`) is
screen-layer state `ListViewModel` already owns (toggle-once); this pitch's whole in-process
change is making `onDeleteItem` a second reader of it, exactly as `onToggle` already is
(domain-model.md — no new field, no new constant, no composition-root change, no new
`Clock`-port wiring). The scope's substrate is therefore exactly the one production file the
diff touches plus its existing unit-test file.

`ListViewModel.test.ets` is already imported by `app/entry/src/test/List.test.ets`
(code-surface.md), so this scope adds new `it(...)` blocks to an already-registered file and
does not need `List.test.ets` in its substrate (KB-SA-001/KB-SA-009 do not apply here — unlike
toggle-once's v1, which added the file for the first time).

It adds no UI element and changes no screen markup, so it declares no `affordance_manifest`
entry (ux-behavior.md: this pitch changes no state, no layout, no copy). It builds first
because `v2-device-flow-r2` has nothing to drive on the device until this guard exists
(synthesis.md dependency graph).

`./scripts/t0-test.sh` is this scope's own tier: TS-01-01, TS-01-02 and TS-01-03 are exactly
the new unit-test rows this scope's diff adds, alongside toggle-once's own settle-window and
reorder tests (REQ-3/4/5), which this scope's diff must leave passing unmodified since it does
not touch `onToggle` or `ItemOrder`.
