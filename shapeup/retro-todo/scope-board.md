# Scope board

| scope_id | topology | use_cases | depends_on | files | lint |
|---|---|---|---|---|---|
| lists-and-open | CHOWDER | UC-07, UC-08 | - | 25 | pending |
| toggle-and-add | CHOWDER | UC-05, UC-04 | lists-and-open | 10 | pending |
| list-name | CHOWDER | UC-01, UC-02 | lists-and-open | 11 | pending |
| delete-confirm | CHOWDER | UC-03, UC-06 | lists-and-open, list-name, toggle-and-add | 14 | pending |

Slices: V1, V2 in lists-and-open; V3, V4 in toggle-and-add; V5 in list-name; V6 in delete-confirm.
