---
scope_id: toggle-and-add
topology_type: CHOWDER
use_cases: [UC-05, UC-04]
covers: []
depends_on: [lists-and-open]
allowed_file_substrate:
  - device-flows/toggle-and-add/**
  - app/entry/src/main/ets/features/todo/domain/ToggleItem.ts
  - app/entry/src/main/ets/features/todo/domain/AddItem.ts
  - app/entry/src/main/ets/features/todo/screens/list/*.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/ToggleItem.test.ets
  - app/entry/src/test/AddItem.test.ets
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
shared_substrate:
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/ets/features/todo/screens/list/*.ets
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V3, V4]
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
  - "./scripts/ui-flow.sh device-flows/toggle-and-add"
---

# Scope: toggle-and-add

## Affordances

| test_id | role | required_states | source |
|---|---|---|---|
| list.newItemField | textfield | [ready, empty] | U9 |
| list.addButton | button | [ready, empty] | U10 |
| list.newItemError | status | [ready, empty] | U11 |
| list.itemCard.toggle | checkbox | [ready] | U13 |

## Why this slice

Breadboard V3 and V4: toggle re-sorts and add with an empty-field error, both on the List screen. Each use case has its own class file; the screen wiring extends the List page and ViewModel that lists-and-open created, so those files are shared and this scope builds after it.

Its device-tier Test Surface rows are flows under `device-flows/toggle-and-add/`, driven from outside the app by `scripts/ui-flow.sh` after a fresh assemble (KB-SA-008).
