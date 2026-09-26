---
scope_id: list-name
topology_type: CHOWDER
use_cases: [UC-01, UC-02]
covers: []
depends_on: [lists-and-open]
allowed_file_substrate:
  - device-flows/list-name/**
  - app/entry/src/main/ets/features/todo/domain/CreateList.ts
  - app/entry/src/main/ets/features/todo/domain/RenameList.ts
  - app/entry/src/main/ets/features/todo/screens/listname/*.ets
  - app/entry/src/main/ets/features/todo/screens/lists/*.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/CreateList.test.ets
  - app/entry/src/test/RenameList.test.ets
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
shared_substrate:
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/ets/features/todo/screens/lists/*.ets
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V5]
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
  - "./scripts/ui-flow.sh device-flows/list-name"
---

# Scope: list-name

## Affordances

| test_id | role | required_states | source |
|---|---|---|---|
| lists.newButton | button | [ready, empty] | U1 |
| lists.renameButton | button | [ready] | U4 |
| listName.title | text | [ready] | U16 |
| listName.field | textfield | [ready] | U17 |
| listName.error | status | [ready] | U18 |
| listName.saveButton | button | [ready] | U19 |
| listName.cancelButton | button | [ready] | U20 |

## Why this slice

Breadboard V5: create and rename share one name dialog and one form, so both use cases and the dialog travel together. It hooks the New and rename buttons into the Lists screen files lists-and-open owns, so those are shared and this scope builds after it.

Its device-tier Test Surface rows are flows under `device-flows/list-name/`, driven from outside the app by `scripts/ui-flow.sh` after a fresh assemble (KB-SA-008).
