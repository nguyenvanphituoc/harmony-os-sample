---
shaping: true
feature: "[[retro-todo]]"
status: shaped
appetite: ~2 weeks
---

# Retro Todo — Shaping

A small todo app with several named lists. Finished items sink to the bottom and look finished, and the
whole app wears one high-contrast, neo-brutalist retro style. English is the working language of the
pitch; the design docs it follows (`docs/index.md`, `docs/ui-layer.md`) are in Vietnamese and are cited
by section. The PO shaped it in Vietnamese; the gate decisions are recorded at the end.

## Problem Frame

The person using the app keeps several kinds of to-dos — groceries, work, plans for the weekend — and has
nowhere to keep them: the repository is the DevEco Hello World template, one V1 page showing a hard-coded
string. The earlier hero-todo app had a single flat list. Everything shared one place, and a finished item
stayed where it was and looked like an open one apart from its switch (its on-device walkthrough, step
"toggle in place"), so a glance did not tell what was left. Its screens were plain white, rows running into
each other. Success: the to-dos are split into named lists; opening a list shows what is still to do at the
top, while finished items sit at the bottom and plainly read as finished; and the app has one distinctive
look that stays easy to read.

## Appetite

**~2 weeks.** A fresh, minimal todolist — not a rebuild of hero-todo. Most of the time goes to the retro
kit and to ArkTS friction (hero-todo's feature code hit 58 ArkTS errors the first time it was compiled);
the list logic is deliberately tiny and nothing is persisted.

## Baseline

The untouched template: `app/entry/src/main/ets/entryability/EntryAbility.ets` loads `pages/Index`
(`main_pages.json`), a V1 `@Component` that shows "Hello World". hero-todo's code is no longer in this
checkout and no git ref holds it, so it is not a base for this pitch; its run is used only for the lessons
in Rabbit Holes.

## Constraints

| Constraint | Value | Source |
|---|---|---|
| Platform | HarmonyOS phone only. The module stays ArkUI-X cross-platform (`crossplatform: true`), so every API must carry the SDK's `@crossplatform` tag or `CompileArkTS` fails with 11706007. `app/.arkui-x/**` is untouched | G1 · G2 · spikes |
| SDK | `6.1.1(24)` | `app/build-profile.json5` |
| Language / UI | ArkTS · state management V2 only · one `entry` HAP | `docs/index.md` · G2 |
| Entry | Keep the template entry, `EntryAbility` → `pages/Index`. `module.json5` and `main_pages.json` do not change | G2 (RH1) |
| Data | In memory, seeded on every cold start, nothing persists | G1 |
| Resources | `base` only: English strings, one light palette, no `dark/` resources, no locale qualifier. The empty `resources/dark/` and `resources/vi_VN/` folders left over from hero-todo stay empty | G1 |
| Done | hvigor `assembleHap` green and the app launches on the Pura 90 emulator — never `tsc` or a grep as a stand-in | G2 |

## Requirements

**Lists**
- **R0** With no lists (for example after deleting every list), the lists screen invites the user to create the first one — never a blank screen.
- **R1** The user can create a list with a name. An empty or whitespace-only name is refused with a message at the field. Duplicate names are allowed.
- **R2** The user sees every list, each with its name and its progress (done / total, e.g. "3/5 done").
- **R3** Opening a list shows that list's items and no other list's.
- **R4** The user can delete a list, together with its items, after confirming.
- **R16** The user can rename a list. An empty or whitespace-only name is refused with a message at the field.

**Items**
- **R5** Inside a list the user can add an item with a title. An empty or whitespace-only title is refused with a message at the field.
- **R6** One tap on the list marks an item done or not done.
- **R7** Done items always sit below every open item. In each group the newest-created item comes first. Marking an item done moves it into the done group at once; marking it not done returns it to its creation-order place among the open items.
- **R8** A done item reads as finished: its text is struck through and changes color, so the difference never rests on color alone.
- **R9** The user can delete an item after confirming.
- **R10** A list with no items invites the user to add the first one.

**Look**
- **R11** Every list and every item is its own card.
- **R12** All text has a contrast ratio of at least 4.5:1 against its background — done-item text included — and card borders and the check control at least 3:1 (WCAG 2.x AA).
- **R13** Every screen follows one retro visual style — palette, type, card treatment — defined once.

**Data and language**
- **R14** Data lives in memory only: every cold start begins with the same sample lists and items, and nothing survives a restart.
- **R15** Every visible string is in English.

## Rabbit Holes

- **RH1 Entry wiring.** hero-todo launched to a blank page because `module.json5` never registered `routerMap`, its route map named page files that did not exist, and the template `EntryAbility` still loaded instead of the composition root (its GATE H report, M1–M3). Bound: keep the template entry (`EntryAbility` → `pages/Index`); `pages/Index.ets` hosts the single `Navigation` with a builder route table; no `route_map.json`, no AppStartup task, no DI container, no change to `module.json5`.
- **RH2 Reorder motion.** Animating an item sliding to the bottom can absorb days, and `Repeat` has no animation support ([[spike-A4-reorder-motion]]). Bound: the move is instant.
- **RH3 Bundled retro font.** Licence, glyph coverage, and a `fontFamily` on every `Text` (there is no app-wide default). Closed by the neo-brutalist choice: the system font, bold, uppercase headings.
- **RH4 The muted done color against R12.** The usual light-grey strikethrough fails 4.5:1. Closed: the palette is computed ([[spike-A5-retro-rendering]]) — done text on a done card is 6.26:1.
- **RH5 Hard offset shadow.** `.shadow()` with radius 0 draws nothing, per the docs ([[spike-A5-retro-rendering]]). Bound: the card is a `Stack` over a solid ink block offset by the shadow token.
- **RH6 Gravity of the full architecture in `docs/`** — use cases, ports, DI, AppStartup, the §1.8 catalog, the enforce task — the scope that took hero-todo to ~6 weeks. Bound: Shape A's thin slice; the kit holds only what two screens and two dialogs use.
- **RH7 ArkTS strictness and the V1 template.** No `any`, spread, destructuring, structural typing or `as const`, and the template `pages/Index.ets` is V1 — never copy it. Budget for it; never an escape hatch. Done means an hvigor build plus a launch on the device: hero-todo's checks stayed green on `tsc` and grep while the real build failed.

## No-goes

- No Settings screen, no Gallery screen, no second language, no L1–L11 enforce task, no traceability doc — hero-todo scope is not rebuilt (G0).
- No persistence of anything: no database, no `preferences`, no `PersistenceV2` (G1).
- HarmonyOS phone only; the Android/iOS shells stay untouched (G1).
- No separate dark theme: the retro palette is the same when the system is in dark mode (G1).
- No due dates, reminders, tags, search, sharing, sync or accounts.
- No drag-to-reorder of items or lists — order is automatic.
- No sub-tasks, and no moving an item to another list.
- No item detail screen, no editing an item's title, no "clear completed" action (G1).
- No Loading or Error demo switch: in-memory data can be neither slow nor failing (S3).
- No reorder animation (G3).

## Selected Shape — A · Thin doc-conformant slice

Rationale: the smallest shape that still follows `docs/index.md`'s chain View → ViewModel → use case →
repository → store, so the ordering rule and the blank-name rules live in `domain/`, where device-free
tests reach them. Everything hero-todo spent its weeks on — route map, startup tasks, module container,
full catalog, enforce task — stays out. It fits ~2 weeks because the domain is six one-function use
cases and the kit is sized to two screens and two dialogs.

### Parts
- **A1** `shared/kernel` + `features/todo/domain` (.ts): the entities, `TodoRules`, `ItemOrder`, and six one-function use cases that return `Result`.
- **A2** `features/todo/data` + `state`: one in-memory repository, seeded on cold start, the only writer of `TodoStore`.
- **A3** Lists screen: list cards with name and progress, create, rename, confirmed delete, and an invitation when there are no lists.
- **A4** List screen: item cards ordered by `ItemOrder`, add, one-tap toggle, confirmed delete, and an invitation when the list is empty.
- **A5** `shared/uikit` retro kit: role-named tokens in `resources/base` and the few primitives these screens use, styled through `AttributeModifier`s.
- **A6** App shell: the template `EntryAbility` pins light mode and captures the `UIContext`, and `pages/Index.ets` becomes the single V2 `Navigation` host that assembles `TodoModule` once.

Screens keep the docs' four-state contract (`@Computed status` → `AsyncBoundary`, `docs/ui-layer.md`
§2.4): Loading lasts one frame, Empty carries R0 and R10, and the Error branch exists with no trigger.

### Retro style — neo-brutalist

Cream ground; white cards with a 2vp ink border and a hard ink shadow offset 4vp down-right; one yellow
accent for primary actions and the checked box; red only for destructive actions. The system font, bold,
with uppercase headings and button labels — no bundled font. A pressed button or card face shifts onto
its shadow.

| Token (role) | Value | Used for |
|---|---|---|
| `background` | `#FFF4E0` | page ground |
| `surface` | `#FFFFFF` | open card, dialog |
| `surfaceDone` | `#F2E8D5` | done card |
| `ink` | `#1A1A1A` | text, borders, hard shadow |
| `inkMuted` | `#5E5242` | done text, secondary text |
| `brand` | `#FFD23F` | primary button, checked box |
| `danger` | `#C1121F` | destructive button |
| `onDanger` | `#FFFFFF` | destructive label |

Written as 8-digit ARGB in `color.json` (`docs/ui-layer.md` §4.1). The contrast table is in
[[spike-A5-retro-rendering]]; every pair passes R12.

### Alternatives considered
- **B — Screens first, no core.** Two pages share one observed state object, with the blank-name and ordering rules inside the ViewModels. Rejected: it breaks `docs/index.md` §1 (business rules only in `domain/`, only the repository writes the store), and the ordering rule gets no device-free test.
- **C — Doc-literal.** `route_map.json` with page builders, an AppStartup task, `AppModules`, the full §1.8 catalog and four-state demo switches. Rejected for this appetite: it is hero-todo's scope, which ran ~6 weeks and launched blank (RH1).

## Fit Check

| R# | Requirement | Covered by | Status |
|----|-------------|------------|--------|
| R0 | No lists → invitation to create one | A3 · A5 | ✅ |
| R1 | Create a list, blank name refused | A1 · A3 · A5 | ✅ |
| R2 | Every list with name + progress | A1 · A2 · A3 | ✅ |
| R3 | Opening a list shows only its items | A3 · A4 · A6 | ✅ |
| R4 | Delete a list with its items, confirmed | A1 · A2 · A3 · A5 | ✅ |
| R5 | Add an item, blank title refused | A1 · A4 · A5 | ✅ |
| R6 | One-tap toggle | A1 · A4 | ✅ |
| R7 | Done below open, newest-created first | A1 · A4 | ✅ (instant move — [[spike-A4-reorder-motion]]) |
| R8 | Strikethrough + color change | A4 · A5 | ✅ ([[spike-A5-retro-rendering]]) |
| R9 | Delete an item, confirmed | A1 · A4 · A5 | ✅ |
| R10 | Empty list → invitation | A4 · A5 | ✅ |
| R11 | Cards | A5 | ✅ (Stack shadow — [[spike-A5-retro-rendering]]) |
| R12 | Contrast 4.5:1 text, 3:1 borders | A5 · A6 | ✅ (computed; light mode pinned) |
| R13 | One retro style, defined once | A5 | ✅ |
| R14 | In memory, seeded, reset on cold start | A2 | ✅ |
| R15 | English strings | A3 · A4 · A5 | ✅ |
| R16 | Rename a list, blank name refused | A1 · A3 · A5 | ✅ |

## Unknowns → Spikes

All resolved from the official docs and the `@crossplatform` tags of the installed SDK 6.1.1.

- [x] A5 retro rendering → [[spike-A5-retro-rendering]] — hard shadow through a `Stack` (`.shadow` radius 0 draws nothing); strikethrough through `decoration`; light mode pinned with `setColorMode`; the palette passes R12.
- [x] A6 navigation host → [[spike-A6-navigation-host]] — a builder `navDestination` without `routerMap` is supported, not deprecated, and cross-platform.
- [x] A4 reorder motion → [[spike-A4-reorder-motion]] — no built-in move animation; the move is instant.
- Residual device check: with the system in dark mode, the app — its dialogs and text fields included — stays light.

## Gate decisions (for downstream skills)

| Gate | Decision |
|---|---|
| G0 | A fresh, minimal todolist, not a hero-todo rebuild (its code is gone) · ~2 weeks |
| G1 | R0–R16 confirmed · in-memory seeded data · English only · both groups newest-created first · list rename and list progress in; item title edit and clear-completed out · proposed no-goes accepted (no dark theme, phone only, no item detail, no drag) |
| G2 | Shape A · neo-brutalist retro · constraints as listed |
| G3 | Fit check clean · no reorder animation |
| G4 | Places and affordances confirmed · card actions are icon buttons · lists newest first · a tap anywhere on an item card toggles it · seed data Groceries / Work / Weekend |
