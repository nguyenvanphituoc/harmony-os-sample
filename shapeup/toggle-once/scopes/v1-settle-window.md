---
scope_id: v1-settle-window
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-1, REQ-2, REQ-3, REQ-4]
depends_on: []
allowed_file_substrate:
  - app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/ets/shared/kernel/Clock.ts
  - app/entry/src/test/List.test.ets
  - app/entry/src/test/ListViewModel.test.ets
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V1]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
---

# Scope: v1-settle-window

## Why this slice

Breadboard V1: the settle window is screen-layer state owned by `ListViewModel`
(domain-model.md — not a domain aggregate, `ToggleItem`/`TodoStore`/`TodoRepository` stay frozen).
It widens `ListViewModel`'s constructor to accept an optional `Clock` (the port already exists at
`app/entry/src/main/ets/shared/kernel/Clock.ts`, following the existing `toggleItem?`/`addItem?`
optional-param style) and widens `TodoModule.listViewModel(...)` to pass one, defaulting to
`SystemClock`. It owns the new settable fake-clock unit test and the registration file it must be
imported from (KB-SA-001, KB-SA-009) — no scope in this pitch may add a `*.test.ets` without also
owning `app/entry/src/test/List.test.ets`, or the test compiles and never runs.

It adds no UI element and changes no screen file's markup, so it declares no
`affordance_manifest` entry (INV-04: an ignored tap surfaces nothing new to the user). It builds
first because there is nothing for the device flow language to drive against until this settle
window exists (synthesis.md dependency graph).

`./scripts/t0-test.sh` is this scope's own tier: TS-01-01, TS-01-02 and TS-01-03 are exactly the
unit-test rows this scope's file adds.
