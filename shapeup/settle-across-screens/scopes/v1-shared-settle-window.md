---
scope_id: v1-shared-settle-window
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-1, REQ-2, REQ-3, REQ-4, REQ-5]
depends_on: []
allowed_file_substrate:
  - app/entry/src/main/ets/features/todo/domain/SettleWindow.ts
  - app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/test/ListViewModel.test.ets
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V1]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
---

# Scope: v1-shared-settle-window

## Why this slice

Breadboard V1: the settle window's state moves out of `ListViewModel` (screen-layer, one visit's
lifetime) into a new `SettleWindow` class `TodoModule` owns as one instance for the whole app
(domain-model.md A1/A2). The diff crosses exactly the object graph this fix touches: the new
domain class, the view model that stops owning the state and starts reading/writing a shared
instance, and the module that builds that instance once and hands it into every
`listViewModel()` call — one call chain, not a layer. No repository, no `Clock` seam, no route,
no other screen (`ListsViewModel`, `ListPage`, dialogs) is touched (domain-model.md — repository/
contract unchanged; ux-behavior.md — no new state, no new copy).

`ListViewModel.test.ets` is already imported by `app/entry/src/test/List.test.ets`
(project-profile.md's code-surface note), so this scope adds new two-`ListViewModel` cases to an
already-registered file and does not need `List.test.ets` in its substrate (KB-SA-001/KB-SA-009
do not apply — no new test file is created).

It adds no UI element and changes no screen markup or copy, so it declares no
`affordance_manifest` entry (ux-behavior.md: this pitch changes no state, no layout, no copy on
either screen). It builds first because `v2-cross-screen-device-flow` has nothing to drive on the
device until the shared window exists (synthesis.md-equivalent: integration.md's dependency
note).

`./scripts/t0-test.sh` is this scope's own tier: TS-01-01..05 are exactly the new/kept unit-test
rows this scope's diff owns — the two-`ListViewModel`-over-one-shared-window cases (TS-01-01..04)
and the no-shared-window regression case (TS-01-05, every existing `ListViewModel.test.ets` case
passing unmodified). `./scripts/t0-assemble.sh` runs first per KB-SA-003 (a fixture must run the
real build, never a source-text check).
