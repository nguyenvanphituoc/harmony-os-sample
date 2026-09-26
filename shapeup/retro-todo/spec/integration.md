---
type: integration
feature: retro-todo
---

# Integration — retro-todo (P5 App runtime)

No cross-system flows: no network, no persistence, no third-party API. The integration surface is the
in-process chain View -> ViewModel -> use case -> repository -> store, assembled once.

## Startup and navigation

| Node | What | Notes |
|---|---|---|
| N1 | `EntryAbility.onWindowStageCreate` loads `pages/Index`; in its callback pins light mode (`setColorMode(COLOR_MODE_LIGHT)`) and captures the `UIContext` | template entry stays |
| N2 | `Index` — the single V2 `Navigation` + `NavPathStack`; builder route table `List` -> P2; root content P1 | no `routerMap`, no `route_map.json` |
| N3 | `TodoModule` builds the repository, the store and the six use cases, and hands them to the ViewModels | assembled once by N2 |

## Domain chain

N4 `TodoRules` and N5 `ItemOrder` are pure. N6–N11 are the six use cases (`CreateList`, `RenameList`,
`DeleteList`, `AddItem`, `ToggleItem`, `DeleteItem`). N12 `InMemoryTodoRepository` is the only writer of
S1 (`TodoStore.lists`) and S2 (`TodoStore.items`); N13 `seed()` runs on cold start through the same writer.
ViewModels N14–N15 (P1), N21–N27 (P2) and the form N20 (P3) read the stores through `@Computed`.

## Silent-failure risks

| Risk | Guard |
|---|---|
| A View or ViewModel writes the store directly | only N12 / N13 write S1 and S2; a spec row per use case checks the change went through the repository |
| A screen or dialog bakes in a color, string or number | palette only in `color.json` (no hex in `.ets`), strings only through `$r('app.string.*')`, dimensions from tokens |
| The app renders dark in system dark mode | N1 pins light mode; device check with the system in dark mode |
| A new unit-test file never runs | it must be imported from `src/test/List.test.ets` |
| API without `@crossplatform` tag | `CompileArkTS` fails 11706007; the build gate catches it |
| Build green but the app launches blank | done means an hvigor build plus a device launch and a layout dump, never `tsc` or grep |
