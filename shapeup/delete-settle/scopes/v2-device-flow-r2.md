---
scope_id: v2-device-flow-r2
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-2]
depends_on: [v1-settle-window-delete]
allowed_file_substrate:
  - device-flows/v2-device-flow-r2/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V2]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/ui-flow.sh device-flows/v2-device-flow-r2"
---

# Scope: v2-device-flow-r2

## Why this slice

Breadboard V2: one device check that a live ✕ tap with no toggle before it still opens the
delete dialog naming that item (R2, TS-01-04), on the seeded Groceries list. Unlike
toggle-once's own v2 scope, `scripts/ui-flow.sh` already supports every step this flow needs (a
plain `tap` on `list.deleteItemButton`) — integration.md is explicit that this pitch adds no new
interpreter step — so this scope's substrate is only its own `device-flows/v2-device-flow-r2/**`
directory (KB-SA-008), never `scripts/ui-flow.sh` itself.

It declares no `affordance_manifest` entry: `list.deleteItemButton` is an existing affordance
this pitch does not add or restyle (ux-behavior.md — no new Loading/Empty/Error branch, no new
dialog, no new copy); the flow drives an existing control, it does not stamp a new one.

It builds after `v1-settle-window-delete` (`depends_on`) because there is nothing for the
device flow to prove until that scope's guard exists — a tap today opens the dialog with or
without the guard, which would prove nothing about R2 specifically. R1 (the inside-the-window
case) is out of scope for the device tier by the pitch's own rabbit hole (a device flow cannot
reliably land a second tap inside 400ms); that assertion lives only in `v1-settle-window-delete`'s
unit test.

Its fixture runs `./scripts/t0-assemble.sh` first so the flow drives the build this pitch
actually produced (KB-SA-008), then `./scripts/ui-flow.sh device-flows/v2-device-flow-r2`. It
does not touch `app/entry/src/test/**`, so `./scripts/t0-test.sh` is not its fixture — that tier
belongs to `v1-settle-window-delete`.

Device-tier Test Surface row TS-01-04 is this scope's one flow.
