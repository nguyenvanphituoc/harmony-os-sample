# Knowledge Base — scope-architect

> Team-shared guidelines distilled by `/coach` from PO/TL feedback at the Ship Gate (L4), a
> project scan, or official-docs research. Read by `scope-architect` at the top of its run.
> **Guidelines, not invariants** — they steer the worker; they never override a spec, widen a
> substrate, resolve a gate or change the spec-evaluator verdict (single-judge rule).
> Committed on purpose: a teammate inherits these on `git pull`.

## Guidelines
- **KB-SA-001** — Give each wiring file exactly one owning scope: `app/entry/src/main/module.json5` (`srcEntry`, `routerMap`, `appStartup`), `route_map.json` and every `pageSourceFile` it names, `startup_config.json` and its task files, the `EntryAbility`, the `Navigation` host page, the `AppModules` container, `oh-package.json5` with its lockfile, and `build-profile.json5`. _(why: in the hero-todo run no scope owned `module.json5`'s routerMap, the page files, `startup/**` or the DI container, and the app launched blank)_  ·  from project-scan @ b8377ad (`app/entry/src/main/module.json5:12-16`, `app/entry/src/main/resources/base/profile/main_pages.json:3`, `app/entry/src/main/ets/entryability/EntryAbility.ets:20`)
- **KB-SA-002** — `resources/base/element/{string,color,float}.json` — plus their `dark/` and per-locale copies — cannot be split per screen, and every UI scope adds keys to them. Give them to one scope the UI scopes depend on, or state up front that the scopes touching them build one at a time. _(why: two scopes editing one file concurrently drop each other's changes — AGENTS.md, "Your scope cut decides your concurrency")_  ·  from project-scan @ b8377ad (`docs/ui-layer.md:476-477`)
- **KB-SA-003** — A fixture that claims the code compiles or a screen is reachable runs the project's hvigor build (the run's `run_cmd`) or the launch probe — never `tsc`, a grep of source text, or a check that pins verbatim implementation code. _(why: all 30 hero-todo T0 trials were green while the real build failed)_  ·  from project-scan @ b8377ad
- **KB-SA-004** — Keep `app/.arkui-x/**` out of every scope's substrate unless a pitch targets Android or iOS: it is a generated shell with Gradle cache files committed to git and another developer's SDK path (`app/.arkui-x/android/local.properties:7`). _(why: a worker "fixing" it breaks the cross-platform shell for everyone)_  ·  from project-scan @ b8377ad (`git ls-files app/.arkui-x`)
- **KB-SA-005** — Slice scopes along `features/<context>/**`; code that spans contexts goes only through `adapters/` and each slice's `index.ets`. _(why: per-context directories keep substrates disjoint by construction)_  ·  from project-scan @ b8377ad (`docs/index.md:120-123,190`)
