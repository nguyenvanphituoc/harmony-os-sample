---
scope_id: v1-badge-render-fix
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-1, REQ-4]
depends_on: []
allowed_file_substrate:
  - app/entry/src/main/ets/features/todo/screens/lists/ListsPage.ets
  - app/entry/src/main/ets/features/todo/screens/lists/ListsViewModel.ets
  - app/entry/src/test/ListsViewModel.test.ets
  - app/entry/src/test/List.test.ets
  - device-flows/v1-badge-render-fix/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V1]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
  - "./scripts/ui-flow.sh device-flows/v1-badge-render-fix"
---

# Scope: v1-badge-render-fix

## Why this slice

Breadboard V1: confirm A1 (the render-layer link between `ListsViewModel.cards` and P1's
on-screen badge that drops an update on an already-mounted card) and fix it there, in
`ListsPage.ets` and/or `ListsViewModel.ets` only (domain-model.md A2, INV-04). No new class, no
store field, no repository method, and `ListsViewModel.cards`'s own computation stays
byte-for-byte unchanged (INV-01) — the fix is confined to how P1 renders an already-correct
`ListCard[]`.

`ListsViewModel.test.ets` does not exist yet (KB-SA-009): this scope adds it as the new unit-test
coverage for TS-01-01 (the computation regression guard), and — because a `*.test.ets` the suite
entry does not import compiles but never runs — this scope also owns
`app/entry/src/test/List.test.ets` to register the new import (KB-SA-001). No other scope needs
either file.

It adds no new UI element and changes no state/layout/copy (ux-behavior.md), so it declares no
`affordance_manifest` entry. It builds first because `v2-badge-device-flows` has nothing to prove
on the device until this fix exists (synthesis.md's dependency graph).

`./scripts/t0-test.sh` is this scope's unit tier per KB-SA-003 (the real hvigor unit-test run,
not a grep or a pinned-code check): TS-01-01 is exactly the new unit-test row this scope's diff
adds. Breadboard V1 also carries the device flow for R1/REQ-4 (the committed repro: toggle an
item, back out, expect the updated badge) — TS-01-02 — so this scope owns its own
`device-flows/v1-badge-render-fix/**` directory (KB-SA-008) and drives it with
`./scripts/ui-flow.sh device-flows/v1-badge-render-fix` after `./scripts/t0-assemble.sh`, so the
flow exercises the build this scope actually produced. R2/R3/R5 (add, delete, rename) are a
separate slice (V2) and a separate scope's fixture.
