---
scope_id: v2-cross-screen-device-flow
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-3]
depends_on: [v1-shared-settle-window]
allowed_file_substrate:
  - device-flows/v2-cross-screen-device-flow/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V2]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/ui-flow.sh device-flows/v2-cross-screen-device-flow"
---

# Scope: v2-cross-screen-device-flow

## Why this slice

Breadboard V2: one device check (TS-01-06) proving that, once the shared window lands, a ✕ tap
outside the window still opens the dialog naming that row's item on a list the user just left
and reopened (R3). `scripts/ui-flow.sh` already supports every step this flow needs — `launch`,
`tap`, `back`, `tap` again, `expect text` — integration.md is explicit that this pitch adds no new
interpreter op, unlike toggle-once's `doubletap`. This scope's substrate is therefore only its own
`device-flows/v2-cross-screen-device-flow/**` directory (KB-SA-008), never `scripts/ui-flow.sh`
itself.

It declares no `affordance_manifest` entry: `list.deleteItemButton` and `lists.card.open` are
existing affordances this pitch does not add or restyle (ux-behavior.md — no new state, no new
copy on either screen); the flow drives existing controls across an existing navigation, it
stamps nothing new.

It builds after `v1-shared-settle-window` (`depends_on`) because there is nothing for the device
flow to prove until the shared window exists — a ✕ tap outside any window opens the dialog today
too, with or without this pitch's fix, so running the flow first would prove nothing about R3
specifically surviving a leave-and-reopen. R1/R2 (the inside-the-window cases) are out of scope
for the device tier by the pitch's own rabbit hole (integration.md: the flow language's own
`settle()`, 0.8s between steps, is structurally incapable of landing a tap inside a 400ms window)
— those assertions live only in `v1-shared-settle-window`'s unit tests.

Its fixture runs `./scripts/t0-assemble.sh` first so the flow drives the build this pitch
actually produced (KB-SA-003/KB-SA-008), then `./scripts/ui-flow.sh device-flows/v2-cross-screen-
device-flow`. It does not touch `app/entry/src/test/**`, so `./scripts/t0-test.sh` is not its
fixture — that tier belongs to `v1-shared-settle-window`.

Device-tier Test Surface row TS-01-06 is this scope's one flow.
