---
scope_id: lists-and-open
topology_type: CHOWDER
use_cases: [UC-07, UC-08]
covers: []
depends_on: []
allowed_file_substrate:
  - device-flows/lists-and-open/**
  - app/entry/src/main/ets/shared/kernel/*.ts
  - app/entry/src/main/ets/shared/uikit/*.ets
  - app/entry/src/main/ets/features/todo/domain/Result.ts
  - app/entry/src/main/ets/features/todo/domain/TodoList.ts
  - app/entry/src/main/ets/features/todo/domain/TodoItem.ts
  - app/entry/src/main/ets/features/todo/domain/TodoRules.ts
  - app/entry/src/main/ets/features/todo/domain/ItemOrder.ts
  - app/entry/src/main/ets/features/todo/domain/TodoRepository.ts
  - app/entry/src/main/ets/features/todo/domain/TodoStore.ets
  - app/entry/src/main/ets/features/todo/domain/InMemoryTodoRepository.ts
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/ets/features/todo/screens/lists/*.ets
  - app/entry/src/main/ets/features/todo/screens/list/*.ets
  - app/entry/src/main/ets/pages/Index.ets
  - app/entry/src/main/ets/entryability/EntryAbility.ets
  - app/entry/src/main/resources/base/element/color.json
  - app/entry/src/main/resources/base/element/float.json
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/ItemOrder.test.ets
  - app/entry/src/test/TodoRules.test.ets
  - app/entry/src/test/InMemoryTodoRepository.test.ets
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/ListsScreen.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
shared_substrate:
  - app/entry/src/main/resources/base/element/string.json
  - app/entry/src/test/List.test.ets
  - app/entry/src/ohosTest/ets/test/List.test.ets
  - app/entry/src/main/ets/features/todo/TodoModule.ets
  - app/entry/src/main/ets/features/todo/screens/lists/*.ets
  - app/entry/src/main/ets/features/todo/screens/list/*.ets
hill_phase: UPHILL_UNKNOWN
delivers_slices: [V1, V2]
e2e_verification_fixtures:
  - "./scripts/t0-assemble.sh"
  - "./scripts/t0-test.sh"
  - "./scripts/ui-flow.sh device-flows/lists-and-open"
---

# Scope: lists-and-open

## Affordances

| test_id | role | required_states | source |
|---|---|---|---|
| lists.card | button | [ready] | U2 |
| lists.card.open | button | [ready] | U3 |
| list.backButton | button | [ready, empty] | U7 |
| list.title | text | [ready, empty] | U8 |
| list.itemCard | checkbox | [ready] | U12 |
| list.emptyInvite | status | [empty] | U15 |

## Why this slice

Breadboard V1 and V2 (adjacent): a cold start shows the seeded cards and a tap opens the list with done items at the bottom. It owns the foundation every later slice stands on (kernel, entities, TodoRules, ItemOrder, store, repository, the retro kit, color and float resources, the app shell and the single Navigation host with the List route), so each shared file has one owner the other scopes depend on (KB-SA-001, KB-SA-002, KB-SA-007). Later scopes add their own string keys and extend the Lists and List page and ViewModel files, TodoModule and the suite entries, so those are declared shared and those scopes build after this one.

Its device-tier Test Surface rows are flows under `device-flows/lists-and-open/`, driven from outside the app by `scripts/ui-flow.sh` after a fresh assemble (KB-SA-008).
