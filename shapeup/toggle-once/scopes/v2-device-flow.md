---
scope_id: v2-device-flow
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-1, REQ-2, REQ-3, REQ-4, REQ-5]
depends_on: [v1-settle-window]
allowed_file_substrate:
  - scripts/ui-flow.sh
  - device-flows/v2-device-flow/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V2]
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/ui-flow.sh device-flows/v2-device-flow"
---

# Scope: v2-device-flow

## Affordances

| test_id | role | required_states | source |
|---|---|---|---|
| list.itemCard.toggle | checkbox | [ready] | U1 |

## Why this slice

Breadboard V2: the device-flow language (`scripts/ui-flow.sh`) has no `doubletap` step yet (grep
confirms only `tap`/`type` are dispatched at `scripts/ui-flow.sh:118`), so R1/R2/R3 stay
unverifiable on the emulator until this scope lands. It adds the `doubletap` op — two
`uitest uiInput click` calls back-to-back with no `settle()` between them, then one trailing
`settle()` after the pair (integration.md risk row 1) — and the device flows under its own
`device-flows/v2-device-flow/**` directory (KB-SA-008) that exercise `list.itemCard.toggle`, the
same test_id retro-todo's `toggle-and-add` scope already stamped on U13/this pitch's U1, on the
Groceries seed.

It builds after `v1-settle-window` (`depends_on`) because there is nothing to drive until that
scope's settle window exists — a flow that double-taps today just toggles twice. Its fixture runs
`./scripts/t0-assemble.sh` first so the flow drives the build this scope actually produced
(KB-SA-008), then `./scripts/ui-flow.sh device-flows/v2-device-flow`, red on a deliberately broken
flow before it is made green on the real one. It does not touch `app/entry/src/test/**`, so
`./scripts/t0-test.sh` is not its fixture — that tier belongs to `v1-settle-window`.

Device-tier Test Surface rows TS-01-04, TS-01-05, TS-01-06 and TS-01-07 are this scope's flows.
