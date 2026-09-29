---
feature: settle-across-screens
type: scope-board
---

# Scope Board — settle-across-screens

A VIEW of the committed scope contracts under `scopes/*.md` — nothing more; every column below
restates a field the contract already declares, so this file can be thrown away and rebuilt.

| scope_id | topology | use_cases | depends_on | files | lint |
|---|---|---|---|---|---|
| v1-shared-settle-window | CHOWDER | UC-01 | — | `app/entry/src/main/ets/features/todo/domain/SettleWindow.ts` (new), `app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets`, `app/entry/src/main/ets/features/todo/TodoModule.ets`, `app/entry/src/test/ListViewModel.test.ets` | 0 red |
| v2-cross-screen-device-flow | CHOWDER | UC-01 | v1-shared-settle-window | `device-flows/v2-cross-screen-device-flow/**` | 0 red |

`verify spec --slug settle-across-screens`: 0 red, 1 warn (`BREADBOARD-TRACE`: U1–U4 name no
manifest entry as `source` — expected, `affordance_manifest: []` on both scopes since this pitch
changes no UI element, state or copy on either screen; ux-behavior.md).
