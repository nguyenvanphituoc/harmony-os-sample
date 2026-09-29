---
scope_id: v2-dialog-keyboard-visibility
topology_type: CHOWDER
use_cases: [UC-01]
covers: [REQ-4]
depends_on: [v1-list-resize-above-keyboard]
allowed_file_substrate:
  - device-flows/v2-dialog-keyboard-visibility/**
shared_substrate: []
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V2]
affordance_manifest: []
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/ui-flow.sh device-flows/v2-dialog-keyboard-visibility"
---

# Scope: v2-dialog-keyboard-visibility

## Why this slice

Breadboard V2: two device flows proving the list-name dialog (`ListNameDialog.ets`, the same
component and the same `listName.field` id for both "new" and "rename") stays fully visible with
the keyboard up, whichever candidate `v1-list-resize-above-keyboard` picked (window-wide or
page-level) — R4, INV-04. There is nothing meaningful to prove until that setting exists: a
✕/rename-dialog check today would pass by accident regardless of what this pitch does, so this
scope `depends_on` `v1-list-resize-above-keyboard` and builds after it.

`scripts/ui-flow.sh` already supports every step these flows need once `swipe` lands in
`v1-list-resize-above-keyboard` — `launch`, `tap`, `type`, `wait`, `expect text` — this use case's
own flow steps (opening a dialog, focusing a field, checking every dialog element stays on
screen) need no new interpreter op, so this scope's substrate is only its own
`device-flows/v2-dialog-keyboard-visibility/**` directory (KB-SA-008), never `scripts/ui-flow.sh`
itself.

It declares no `affordance_manifest` entry: `lists.newButton`, `lists.renameButton` and
`listName.field` are existing affordances this pitch does not add or restyle (ux-behavior.md — no
new state, layout, or copy on P3; the dialog's title, field, error text and Save/Cancel are all
already-rendered elements this flow only asserts stay visible). It touches no
`app/entry/src/test/**` file, so `./scripts/t0-test.sh` is not its fixture — that tier does not
apply to this pitch at all (UC-01's Test Surface note).

Its fixture runs `./scripts/t0-assemble.sh` first (KB-SA-003/KB-SA-008) so the flows drive the
build `v1-list-resize-above-keyboard` actually produced, then `./scripts/ui-flow.sh
device-flows/v2-dialog-keyboard-visibility` drives TS-01-04 (rename dialog) and TS-01-05 (new-list
dialog).
