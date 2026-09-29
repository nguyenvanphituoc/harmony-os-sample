---
scope_id: v2-badge-device-flows
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-2, REQ-3, REQ-5, REQ-6]
depends_on: [v1-badge-render-fix]
allowed_file_substrate:
  - device-flows/v2-badge-device-flows/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V2]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/ui-flow.sh device-flows/v2-badge-device-flows"
---

# Scope: v2-badge-device-flows

## Why this slice

Breadboard V2: device flows proving `v1-badge-render-fix`'s fix generalizes past toggle — add
(R2/TS-01-03), delete (R5/TS-01-04), and rename with card-order check (R3/R6/TS-01-05) — using
the same render link V1 confirmed. No new production code is expected here (domain-model.md,
integration.md's dependency graph); if a flow in this scope fails against V1's fix, that is the
signal the fix did not generalize, which is exactly what these flows exist to catch.

`scripts/ui-flow.sh` already supports every step these flows need (`launch`, `tap`, `back`,
`expect count`, `expect text` — integration.md), so this scope's substrate is only its own
`device-flows/v2-badge-device-flows/**` directory (KB-SA-008), never `scripts/ui-flow.sh` itself,
and it does not touch `app/entry/src/test/**` — that tier belongs to `v1-badge-render-fix`.

It declares no `affordance_manifest` entry: every control these flows drive (`lists.card.open`,
`list.itemCard.toggle`, the add control, `list.deleteItemButton`, `lists.renameButton`) is an
existing affordance this pitch does not add or restyle (ux-behavior.md — no new state, layout, or
copy).

It builds after `v1-badge-render-fix` (`depends_on`): there is nothing for these device flows to
prove until that scope's fix exists — running them first would only prove today's broken
behavior stays broken, not that the fix generalizes. Its fixture runs
`./scripts/t0-assemble.sh` first so the flows drive the build this pitch actually produced
(KB-SA-008), then `./scripts/ui-flow.sh device-flows/v2-badge-device-flows`.

Device-tier Test Surface rows TS-01-03, TS-01-04 and TS-01-05 are this scope's flows.
