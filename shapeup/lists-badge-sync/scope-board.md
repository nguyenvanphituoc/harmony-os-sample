# Scope board — lists-badge-sync

A view of the committed scope contracts (`scopes/*.md`), nothing more. Build order lives in each
contract's `depends_on`; this table only shows it.

| scope_id | topology | use_cases | depends_on | files | lint |
|---|---|---|---|---|---|
| v1-badge-render-fix | CHOWDER | UC-01 | — | `ListsPage.ets`, `ListsViewModel.ets`, `ListsViewModel.test.ets`, `List.test.ets`, `device-flows/v1-badge-render-fix/**` | pending |
| v2-badge-device-flows | CHOWDER | UC-01 | v1-badge-render-fix | `device-flows/v2-badge-device-flows/**` | pending |
