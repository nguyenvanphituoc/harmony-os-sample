---
type: synthesis
feature: retro-todo
---

# Synthesis — retro-todo

## Traceability (requirement -> use case -> screen)

| Requirement | Use case | Screen / rule |
|---|---|---|
| R0 empty lists invitation | [[UC-07]] | P1 U6 |
| R1 create a list, blank refused, duplicates allowed | [[UC-01]] | P3 |
| R2 list with progress | [[UC-07]] | P1 U2 |
| R3 a list shows only its items | [[UC-08]] | P2 |
| R4 delete a list, confirmed | [[UC-03]] | P4 |
| R5 add an item, blank refused | [[UC-04]] | P2 U9–U11 |
| R6 one tap toggles | [[UC-05]] | P2 U13 |
| R7 done below open, newest-created first | [[UC-05]], [[UC-08]] | ItemOrder |
| R8 struck through and color change | [[UC-05]], [[UC-08]] | P2 U12 |
| R9 delete an item, confirmed | [[UC-06]] | P4 |
| R10 empty list invitation | [[UC-08]] | P2 U15 |
| R11 every list and item is a card | [[UC-07]], [[UC-08]] | RetroCard |
| R12 contrast | [[ux-behavior]] visual rules | tokens |
| R13 one retro style | [[ux-behavior]] visual rules | kit |
| R14 in memory, seeded | [[UC-07]] | repository seed |
| R15 English strings | [[ux-behavior]] | resources/base |
| R16 rename a list | [[UC-02]] | P3 |

Non-functional clauses (R12, R13, R15) have no actor+action; they are carried by a dedicated conformance
task whose criteria cite the spec, not left in this table alone.

## Risk register

| Risk | Likelihood | Mitigation |
|---|---|---|
| ArkTS strictness (no `any`, spread, destructuring, `as const`); hero-todo hit 58 errors | high | build with hvigor early in every scope; never an escape hatch |
| Shared resource files (colors, sizes, strings) edited by many scopes | high | one owner per file: tokens, strings, the shell entry files |
| Hard shadow via `.shadow` radius 0 draws nothing | medium | `Stack` over an ink block |
| Dark-mode leak | medium | pin light mode; device check |
| Unit-tier red at baseline (`assertNotEqual` in a template test) | known | reported, not owned |
| Hero-todo's launch-blank failure (entry wiring) | medium | template entry kept; launch probe every round |

## Hammered out

Item title edit, clear-completed, drag reorder, reorder animation, dark theme, persistence: all No-goes.

## Dependency graph

Kernel and rules -> ItemOrder and repository -> use cases -> shell -> Lists screen -> List screen ->
toggle, add, dialogs, delete -> conformance pass. Tokens, strings and kit primitives run in parallel
with the domain chain and join at the screens.
