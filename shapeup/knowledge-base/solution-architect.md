# Knowledge Base — solution-architect

> Team-shared guidelines distilled by `/coach` from PO/TL feedback at the Ship Gate (L4), a
> project scan, or official-docs research. Read by `solution-architect` at the top of its run.
> **Guidelines, not invariants** — they steer the worker; they never override a spec, widen a
> substrate, resolve a gate or change the spec-evaluator verdict (single-judge rule).
> Committed on purpose: a teammate inherits these on `git pull`.

## Guidelines
- **KB-SOL-001** — Resolve wiring against the entry point that exists, not the one the docs plan. Today `module.json5` names `EntryAbility` at `./ets/entryability/EntryAbility.ets` (`app/entry/src/main/module.json5:6,16`), which loads `pages/Index` (`EntryAbility.ets:20`, listed in `main_pages.json:3`); the docs' `ets/app/EntryAbility.ets`, `Navigation` host, `route_map.json`, startup tasks and `AppModules` do not exist yet. A route is reachable only when `module.json5` registers `routerMap: "$profile:route_map"`, the `pageSourceFile` exists, and `buildFunction` names its exported global `@Builder` — without `routerMap` the app shows an empty `NavDestination` instead of failing to compile. Name who creates each link. _(why: the hero-todo app launched blank for exactly this reason)_  ·  from project-scan @ b8377ad; confirmed by web-research (https://gitee.com/openharmony/docs/blob/master/en/application-dev/quick-start/module-configuration-file.md#routermap, API 24, 2026-09-15)
