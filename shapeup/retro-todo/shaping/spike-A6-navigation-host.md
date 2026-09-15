---
shaping: true
feature: "[[retro-todo]]"
doc_type: spike
part: A6
status: resolved
---

# Spike: Can `pages/Index.ets` host the app's only `Navigation` with a builder route table and no `routerMap`?

## Question
At API 24, in a cross-platform module, can a single `Navigation(NavPathStack)` take its destinations from a
`@Builder` route table passed to `.navDestination(...)` — with no `route_map.json` and no `routerMap` in
`module.json5` — and does `pushPathByName` resolve through that table?

## Acceptance Condition
Yes: A6 keeps the template entry (`EntryAbility` → `pages/Index`); `Index` holds the builder route table;
`module.json5` does not change.
No: A6 registers `routerMap`, writes `route_map.json` and one page-builder file per screen — the wiring that
blanked hero-todo's launch (RH1).

## Investigation
- `navDestination(builder: (name: string, param: unknown) => void)` exists since API 10 and carries the SDK `@crossplatform` tag since 11; `Navigation(pathInfos: NavPathStack)` and `pushPathByName` are `@crossplatform` too.
- The Navigation reference: the name passed to `pushPathByName` "matches … 1. Custom route table, which is passed via the navDestination method. 2. System route table … routerMap".
- `ui/arkts-navigation-cross-package.md`: "The custom routing table and system routing table can be used together." It calls the custom table "complex to use" — a trade-off, not a deprecation.
- The ArkUI-X navigation guide shows `.navDestination(this.PageMap)`.

Sources: gitee.com/openharmony/docs, master (`en/application-dev/`), the SDK 6.1.1.125 declarations, and
gitee.com/arkui-x/docs; researched 2026-09-15.

## Decision
**Yes.** `pages/Index.ets` becomes the single V2 `Navigation` host; its builder route table maps `List` to the
List screen; the Lists screen is the root content. Nothing in `module.json5` or `main_pages.json` changes.

## Constraints Discovered
- The builder route table deliberately departs from `docs/ui-layer.md` §2.2 (`route_map.json`), within the RH1 bound.
- The route parameter is the list id — a string, never the list object (`docs/ui-layer.md` §2.6).
- The stack is restored after a process kill only with an opt-in `recoverable(true)`, which this pitch does not use; with in-memory data a restored id would point nowhere anyway.
- The template `pages/Index.ets` is V1 (`@Entry @Component @State`); the host is rewritten in V2, never extended.
- The template `EntryAbility` already loads `pages/Index`, so no entry file moves and `srcEntry` stays put.
