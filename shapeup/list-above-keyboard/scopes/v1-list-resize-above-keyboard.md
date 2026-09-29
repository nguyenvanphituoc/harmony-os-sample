---
scope_id: v1-list-resize-above-keyboard
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-1, REQ-2, REQ-3, REQ-5]
depends_on: []
allowed_file_substrate:
  - app/entry/src/main/ets/entryability/EntryAbility.ets
  - app/entry/src/main/ets/features/todo/screens/list/ListPage.ets
  - scripts/ui-flow.sh
  - device-flows/v1-list-resize-above-keyboard/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V1]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/ui-flow.sh device-flows/v1-list-resize-above-keyboard"
---

# Scope: v1-list-resize-above-keyboard

## Why this slice

Breadboard V1: pick and apply the keyboard-avoid setting that makes P2's content shrink above the
keyboard (domain-model.md's two candidates — window-level via `EntryAbility.ets`'s
`windowStage`/`getMainWindowSync()`, or page-level via `ListPage.ets`'s outer `Column`/
`NavDestination`), verified against the SDK's own `.d.ts` or a device probe, never copied from an
unverified `docs/` claim (INV-01). Whichever candidate is picked touches exactly one of these two
files — this scope owns both because the choice is Build's to make, not Map Scopes', and only one
scope may own either file (KB-SA-001: `EntryAbility.ets` is a wiring registration file).
`ListPage.ets`'s `List({ space: 12 }).width('100%').layoutWeight(1).scrollBar(BarState.Off)` block
and its `Repeat<TodoItem>` stay byte-for-byte unchanged either way (INV-01) — the fix lives in the
container above the `List`, never in the `List`'s own declaration.

This scope also owns `scripts/ui-flow.sh`: the device-check language gains a `swipe id "<node>"
up|down` step, resolving `<node>` via the same `find(nodes, kind, value)` lookup `tap`/`doubletap`
already use, then driving `hdc shell uitest uiInput swipe` across the resolved node's bounds
(INV-05). This is independent of the keyboard-avoid setting itself (device tooling only, no
production-app code) but travels in the same scope because both are prerequisites the V1 device
flows need before they can run — splitting the interpreter change into its own scope would buy no
extra concurrency (nothing else in this pitch touches `scripts/ui-flow.sh`) while adding a
`depends_on` edge for no reason.

It adds no new UI element and changes no screen markup or copy (ux-behavior.md: U1/U2/U3 are
existing controls whose *behavior* changes, not new affordances; R3 is explicit that idle-state
layout is byte-for-byte unchanged), so it declares no `affordance_manifest` entry.

`./scripts/t0-test.sh` is not this scope's fixture: no unit-test surface applies to this pitch
(UC-01's own Test Surface note — R1/R2 are layout/keyboard-avoid behavior with no natural unit
tier on this project), so it does not appear in `e2e_verification_fixtures`, and this scope
touches no file under `app/entry/src/test/**` (KB-SA-001/KB-SA-009 do not apply — no new unit-test
file is created). `./scripts/t0-assemble.sh` runs first per KB-SA-003 (a fixture must exercise the
real build, never a source-text check), then `./scripts/ui-flow.sh
device-flows/v1-list-resize-above-keyboard` (KB-SA-008) drives this scope's own device flows
(TS-01-01, TS-01-02, TS-01-03 — R1, R2, R3) over the setting and the new `swipe` step this same
scope adds, so the flows exercise the build this scope actually produced.

It builds first because `v2-dialog-keyboard-visibility` has nothing to prove until the setting
exists — a dialog check today would pass by accident regardless of what this pitch does.
