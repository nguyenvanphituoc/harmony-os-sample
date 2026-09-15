---
shaping: true
feature: "[[hero-todo]]"
status: shaped
appetite: ~6 weeks
---

# Hero Todo — Shaping

A team reference app: a todo list built to exemplify every rule in `docs/ui-layer.md`, on top of the
layer model in `docs/index.md`. English is the working language of the pitch; the design docs it
implements are in Vietnamese and are cited by section number.

## Problem Frame

The team has a written UI-layer design (`docs/ui-layer.md`) for the HarmonyOS client, but no code
that proves it. The repository is the untouched DevEco Hello World template: one V1 `@Component`
page, a hard-coded string, no `features/`, no `shared/uikit`, no route map. A developer starting the
first real screen has only prose to follow, and the design's own open questions (§8, U1–U5) were
unverified against a real build. Nothing in the repo can be pointed at and copied as "this is what a
screen looks like here."

## Appetite

**~6 weeks.** Todo list plus the full §1.8 starter catalog, a settings screen for color mode and
language, a gallery screen, and the eleven enforce rules of §5. The uikit foundation and the enforce
task are the bulk of the work; the todo logic is deliberately tiny.

## Constraints

| Constraint | Value | Source |
|---|---|---|
| Platform | **HarmonyOS only.** The repo is configured for ArkUI-X (`crossplatform: true`, Android/iOS folders); those stay untouched and are not a target | GATE 2 |
| SDK | Build against the project's `6.1.1(24)` (doc text says 22/23; the project wins) | GATE 2 |
| Language / UI | ArkTS · ArkUI state management **V2** only (`@ComponentV2`, `@ObservedV2`) · one `entry` HAP | index.md |
| Data | **Volatile in-memory mock data**; nothing persists — not todos, not settings | GATE 1 |
| Resources | `base` = English (complete fallback) · `vi_VN` = the one qualifier · `dark` color qualifier | GATE 1 |
| Build | Keep the ArkUI-X hvigor plugin; the enforce task registers alongside it | GATE 2 / U5 |

## Requirements

**Todo capability**
- **R0** The list is the first screen. With no todos it shows an invitation to create the first one, never a blank screen or "no data".
- **R1** The user can add a todo with a title. An empty or whitespace title is refused with a message at the field. The submit control cannot fire twice while a save is in flight.
- **R2** The list shows every todo with its title and done state, newest first, plus a count of todos that is grammatically correct in each language.
- **R3** Toggling done / not done from the list is reflected immediately.
- **R4** Opening a todo shows its detail: title, done state, created time formatted for the current language. From there the user can edit the title or delete it. Delete asks for confirmation first.
- **R5** Todo data is in-memory mock data: seeded with a few sample todos on cold start, reset on every cold start, no database, no network.
- **R6** Leaving the edit form with unsaved changes asks for confirmation before discarding.
- **R7** Opening a todo that no longer exists — deleted, or a navigation stack restored after the process was killed (mock data does not survive) — shows "this item was deleted" with a way back, not a crash.

**Design-mandated observables**
- **R8** Every data-showing screen (list, detail) has a distinct loading, error-with-retry, empty and ready presentation, each demonstrable on device.
- **R9** Coming back to the list after add, edit or delete updates it in place with no loading flash.
- **R10** Switching the device between light and dark recolors every screen without restart.
- **R11** Switching language (English ⇄ Vietnamese) changes every visible string without restart: labels, error messages, accessibility labels, plural counts, formatted dates.
- **R12** At the largest system font size no text is clipped and no layout breaks on any screen.
- **R13** Every tappable element meets the minimum touch target, has an accessibility label, and visibly shows pressed, disabled, busy and focused states.
- **R14** A settings screen offers Light / Dark / Follow system and a language choice (English / Tiếng Việt). Both apply immediately to the whole app and reset on cold start.
- **R15** Test surface: every interactive element carries a stable `<screen>_<role>` id; each data screen has instrumented tests for all four presentations; form rules and date/plural formatting have device-free tests.

**Reference-app value**
- **R16** Every primitive and pattern in the §1.8 starter catalog exists in `shared/uikit` and is exercised by at least one screen.
- **R17** The build fails on the nine error-level rules of §5 (L1–L9) and reports the two warnings (L10, L11).
- **R18** The five open questions of §8 (U1–U5) each have a recorded, build-verified answer, and the doc is updated wherever the answer changes a recommendation.
- **R19** A traceability index in the repo maps every numbered section of `ui-layer.md` to the file(s) that exemplify it, every row pointing at real code.
- **R20** A gallery screen shows every catalog primitive in all six states of §1.7, so the dark-mode and largest-font review is one screen.

## Rabbit Holes

- **RH1 Data-layer gravity.** `index.md` §5 describes remote + generated codecs + DAO + TaskPool. This pitch has one in-memory fake repository behind the domain port and nothing else. "While we're here" building a real DAO eats the UI budget.
- **RH2 First-frame ordering.** Theme (`ThemeControl.setDefaultTheme`) and the UIContext capture belong in the `loadContent` callback; module assembly in the startup task. Wrong order is visible only on device. With nothing persisted the risk is smaller than first thought, but the order is still a contract.
- **RH3 The five open questions.** Resolved during shaping (see Unknowns). Residuals are device checks, not shape changes.
- **RH4 Hand-rolled linter.** L1–L11 as hvigor tasks can grow into a parser project. Bound: text scans and set comparisons, one task, one rule table as data, no AST.
- **RH5 Six-state polish.** Pressed / focused / disabled / busy on every primitive can absorb days of tuning. Bound: `AttributeModifier` hooks with token values, one review pass on the Gallery in dark mode and largest font.
- **RH6 ArkTS friction.** No structural typing, spread, destructuring, `as const`, type predicates or `any`. Not avoidable; budget for it and never work around it with escape hatches (they are forbidden anyway).
- **RH7 Demo triggers.** The Loading and Error branches need a trigger on a mock. It is a demo switch on the fake repository, reached only through the Settings screen — it must not leak into screen code or become a second data path.

## No-goes

- No persistence of anything: no database, no `preferences`, no `PersistenceV2`.
- No network, sync or server.
- No second bounded context, so no composite screen (§2.8), no `adapters/` residents beyond `wiring/`, no EventBus consumer.
- No codec generator, no TaskPool parsing.
- No import-table enforcement from `index.md` §1 — that belongs to the unwritten `architecture.md`. Only the eleven UI-layer rules.
- No third language and no RTL qualifier. The start/end rules of §3.7 still apply.
- No foldable or multi-window layouts beyond `NavigationMode.Auto`.
- No deep links.
- No todo extras: due dates, tags, search, reminders, sharing, accounts.
- No writing of the other missing docs. The app touches domain, data and state as thinly as `index.md` allows.

## Selected Shape — A · Doc-literal vertical slice

Rationale: the only shape whose parts map one-to-one onto the doc's sections — which is the whole
point of R19 — while the non-UI layers stay at the thinnest form `index.md` allows (one fake
repository, five one-function use cases, one store).

### Parts
- **A1** `shared/kernel` (.ts): `Result` / `Ok` / `Err`, `AppError`, `ErrorCode` enum, `TodoId` identifier type — the types every other part speaks.
- **A2** `features/todo/domain` (.ts): `Todo` entity, `TodoRules` (title → `ErrorCode`), `TodoPorts` (repository, `Clock`, `IdGen`), five one-function use cases (`ListTodos`, `CreateTodo`, `RenameTodo`, `ToggleTodo`, `DeleteTodo`) returning `Result`.
- **A3** `features/todo/data` + `state`: one in-memory fake repository implementing the port, seeded, with two demo knobs (delay, fail-next-load), as the sole writer of `TodoStore`.
- **A4** `features/todo` screens: `TodoList`, `TodoDetail`, `TodoEdit` (create and rename share the form), each as Page / ViewModel / view / parts, plus the `TodoCard` organism, `TodoModule` and `index.ets`.
- **A5** `shared/uikit`: tokens, the full §1.8 catalog, `AttributeModifier`s, four registries (field, overlay, status, theme), the `ErrorCode → Resource` i18n table.
- **A6** `app/`: thin `EntryAbility` (theme, UIContext capture, `onConfigurationUpdate` → `AppearanceStore`), one AppStartup task assembling `AppModules`, the single `Navigation` host with `NavigationMode.Auto`, `Settings` screen (color mode, language, demo knobs, gallery link), `Gallery` screen.
- **A7** resources and profiles: `base` (en) + `vi_VN` strings and plurals, `base` + `dark` colors, floats, `route_map.json`, `startup_config.json`, `configuration.json` (`fontSizeScale: followSystem`, no cap).
- **A8** hvigor enforce task: L1–L11 as text scans and set comparisons driven by one rule table (data, reusable by a later `extRuleSet` port).
- **A9** tests: local (rules, date/plural format) and instrumented (four states per data screen, restore after kill, language switch across the stack, ids).
- **A10** docs: U1–U5 answers folded into §8 (and §1.2, §3.5, §3.6, §4.4 where the answers change a line), plus `docs/ui-layer-trace.md` mapping section → file.
- **A11** `shared/runtime` + `shared/utils` (added at the fit check): UIContext holder, `AppearanceStore` (`AppStorageV2`), `Clock` / `IdGen` implementations, locale-parameter date formatter.

### Alternatives considered
- **B — Screens first, no core.** ViewModels own mock arrays; no domain, store or use cases. Rejected: breaks §2.3 and §3.4, so R1's field-error path and R19 cannot be doc-conformant.
- **C — A plus screen-template generator and linter in `extRuleSet`.** Both hinted at in the doc (§2.1, U5). Rejected as speculative for this appetite; the U5 spike confirms the field exists and defers the port to its own bet.

## Fit Check

| R# | Requirement | Covered by | Status |
|----|-------------|------------|--------|
| R0 | List first, empty invitation | A4 · A5 · A6 | ✅ |
| R1 | Add, empty refused at field, no double submit | A2 · A4 · A5 | ✅ |
| R2 | List newest first + plural count | A3 · A4 · A5 · A7 | ✅ (U1) |
| R3 | Toggle done, immediate | A2 · A3 · A4 | ✅ |
| R4 | Detail, edit, delete with confirm, locale date | A2 · A4 · A5 · A11 | ✅ |
| R5 | Seeded in-memory mock, resets | A3 | ✅ |
| R6 | Dirty form blocks back | A4 · A5 | ✅ |
| R7 | Missing id → "deleted" + way back | A4 · A5 · A7 | ✅ |
| R8 | Four presentations, demonstrable | A3 · A4 · A5 · A6 | ✅ |
| R9 | Silent refresh on return | A4 | ✅ |
| R10 | Dark mode live | A5 · A6 · A7 | ✅ |
| R11 | Language switch live | A5 · A6 · A7 · A11 | ✅ (U4) |
| R12 | Largest font, no clipping | A5 · A6 · A7 | ✅ (U3) |
| R13 | Touch target, a11y, six states | A5 | ✅ |
| R14 | Settings: color mode + language, volatile | A6 · A11 | ✅ (U4) |
| R15 | Test surface | A4 · A9 | ✅ |
| R16 | Catalog complete + exercised | A4 · A5 · A6 | ✅ |
| R17 | Build fails L1–L9, warns L10–L11 | A8 | ✅ (U5) |
| R18 | U1–U5 answered, doc updated | A10 + spikes | ✅ |
| R19 | Traceability index | A10 | ✅ |
| R20 | Gallery, six states | A5 · A6 | ✅ |

## Unknowns → Spikes

All five resolved from official docs during shaping. Residual device checks are listed inside each file and land in A9.

- [x] U1 plural via `$r` directly → [[spike-U1-plural-via-r]] — **yes**, `$r(key, n, n)`; no wrapper.
- [x] U2 `@BuilderParam` in `@ComponentV2` → [[spike-U2-builderparam-in-v2]] — **yes**; fixed slots use `@BuilderParam`, keyed selection keeps the registry.
- [x] U3 app-level font-scale cap → [[spike-U3-font-scale-cap]] — **yes**, but the default is *not* to follow the system; the app opts in via `configuration.json` and does not cap.
- [x] U4 `setAppPreferredLanguage` redraw → [[spike-U4-language-switch-redraw]] — **yes** for concrete tags; `default` needs a cold start; stack-redraw residual → instrumented test.
- [x] U5 `extRuleSet` availability → [[spike-U5-linter-extRuleSet]] — **yes** since DevEco 5.1.0 Release (secondary sources); rules stay a hvigor task in this pitch.

## Gate decisions (for downstream skills)

| Gate | Decision |
|---|---|
| G0 | Team reference app · ~6 weeks · (initially "persisted", revised at G1) |
| G1 | R0–R20 confirmed · todo data volatile, seeded · settings volatile too · Gallery screen in · English base + `vi_VN` |
| G2 | Shape A · HarmonyOS only · project SDK 6.1.1(24) |
| G3 | Fit check clean · A11 added · language picker offers English / Tiếng Việt only (U4 + volatile settings) · `followSystem`, no font cap (U3) · L1–L11 stay in hvigor (U5) |
