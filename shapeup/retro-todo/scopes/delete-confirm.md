---
scope_id: delete-confirm
topology_type: CHOWDER
use_cases: [UC-03, UC-06]
covers: []
depends_on: [lists-and-open, list-name, toggle-and-add]
allowed_file_substrate:
  - device-flows/delete-confirm/**
  - app/entry/src/main/ets/features/todo/domain/DeleteList.ts
  - app/entry/src/main/ets/features/todo/domain/DeleteItem.ts
  - app/entry/src/main/ets/features/todo/screens/confirm/*.ets
  - app/entry/src/main/ets/features/todo/screens/lists/*.ets
  - app/entry/src/main/ets/features/todo/screens/list/*.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/main/resources/base/element/plural.json
  - app/entry/src/test/DeleteList.test.ets
  - app/entry/src/test/DeleteItem.test.ets
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/RoundTrip.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
shared_substrate:
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/ets/features/todo/screens/lists/*.ets
  - app/entry/src/main/ets/features/todo/screens/list/*.ets
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V6]
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
  - "./scripts/ui-flow.sh device-flows/delete-confirm"
---

# Scope: delete-confirm

## Affordances

| test_id | role | required_states | source |
|---|---|---|---|
| lists.deleteButton | button | [ready] | U5 |
| lists.emptyInvite | button | [empty] | U6 |
| list.deleteItemButton | button | [ready] | U14 |
| confirm.message | text | [ready] | U21 |
| confirm.deleteButton | button | [ready] | U22 |
| confirm.cancelButton | button | [ready] | U23 |

## Why this slice

Breadboard V6: both deletions share one confirm dialog, so both use cases and the dialog travel together; it also owns the closing round-trip test. It comes last because it needs the Lists and List screens and the name dialog (U6 opens it), and it extends their files, which are shared.

Its device-tier Test Surface rows are flows under `device-flows/delete-confirm/`, driven from outside the app by `scripts/ui-flow.sh` after a fresh assemble (KB-SA-008).
