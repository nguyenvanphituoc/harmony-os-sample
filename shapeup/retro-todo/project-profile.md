---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — retro-todo

Re-derived on 2026-09-27 for branch `soak/retro-todo-4`. Every field below was measured on this
checkout at this run's open, not carried from the previous profile. The previous profile described a
tree that carried the prior run's output uncommitted; that output has since been committed, so `HEAD`
now holds the feature and the old "no `features/`, no `shared/`" statements are void.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `stack` | above | `app/build-profile.json5`, `app/oh-package.json5`, `app/hvigorfile.ts`, `app/.arkui-x/arkui-x-config.json5` |
| `build_probe` | `./scripts/t0-assemble.sh` | committed fixture, grant-covered, **executed green at this open** — `BUILD SUCCESSFUL in 3 s 143 ms` (incremental, mostly UP-TO-DATE), house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | committed fixture, one grantable command, **executed green at this open**: target `127.0.0.1:5555`, the unsigned HAP installs, `start ability successfully`, pid alive, and a `uitest dumpLayout` tree with 14 text nodes — `MY LISTS`, `+ NEW LIST`, and three seeded list cards (`Groceries` 1/3 done, `Work` 1/2 done, `Weekend` No items) each with `✎` / `✕` |

## State of the tree at run open — the baseline is no longer the template

The pitch's Baseline section measures against the untouched DevEco template, and the spec and scope
contracts are still measured against that. The checkout is not the template. `HEAD` already holds a
committed implementation from an earlier from-scratch run, so a worker reads the tree as **existing code
to converge on**, and the round's work is to verify it against the spec and repair what does not
conform — not to write it from nothing.

- `app/entry/src/main/ets/` holds `entryability/`, `pages/Index.ets`, `features/todo/` (`TodoModule.ets`,
  `domain/` with the use-case files, repository, rules and `TodoStore.ets`, and `screens/` with `confirm/`,
  `list/`, `listname/`, `lists/`) and `shared/` (`kernel/`, `uikit/` with the `Retro*` components).
- `app/entry/src/test/` holds eleven `*.test.ets` files; `app/entry/src/ohosTest/` exists; `scripts/`
  holds `t0-assemble.sh`, `t0-test.sh`, `launch-probe.sh` and `ui-flow.sh`.
- `module.json5` still declares no `routerMap` and no `appStartup`; `resources/base/profile/` holds only
  `main_pages.json` — no `route_map.json`, no `startup_config.json`. The pitch's RH1 bound (no route file,
  no AppStartup task, no `module.json5` change) is met and stays the zero-change option.
- `app/.arkui-x/` is present and `arkui-x-config.json5` says `crossplatform: true`, so an API without the
  SDK's `@crossplatform` tag fails `CompileArkTS` with 11706007.
- The committed spec is at `shapeup/retro-todo/spec/` with four scope contracts (`delete-confirm`,
  `list-name`, `lists-and-open`, `toggle-and-add`), `requirements.md` (28 `REQ-<n>` rows), `wiring-map.md`
  and a frozen `REPORT.md` from the previous run. The spec tree carries no `tasks/`, so `verify spec`
  reads zero tasks and reports every requirement as `REQ-UNCOVERED` (28 red) until ANALYZE writes the
  board and its acceptance criteria — that is the expected pre-ANALYZE reading, not a spec defect.

## House rules: what bites

`app/build-src/enforce/rule-table.ts` runs at hvigorfile module-evaluation time, so one error-level hit
reds **every** hvigor target before any task runs (L1–L9 `error`, L10–L11 `warning`).

- **L6 is inert while there is no `route_map.json`.** Its check returns no finding when that file is
  absent (`app/build-src/enforce/scan.ts:155`). Creating `route_map.json` would arm L6 in both directions
  *and* require a `module.json5` change the pitch forbids — so no scope should create it.
- **L1** forbids hex literals in any `.ets`, comments included: the retro palette goes in `color.json`
  and is read through `$r('app.color.…')`. **L3** forbids quoted literals in `Text(…)`, `.label(…)`,
  `.placeholder(…)`: every visible string goes through `string.json`. **L8** forbids `LazyForEach` (use
  `Repeat`). **L9** forbids `@Provider`/`@Consumer`. **L7** forbids `getStringSync(`. **L10** warns on a
  raw dimension literal outside `shared/uikit`.

## Concurrency consequence for BUILD

The committed scope contracts overlap: `verify spec` reports `SHARED-CONCURRENT` between
`delete-confirm` and each of `list-name` and `lists-and-open` (and others) on `TodoModule.ets`,
`ListsPage.ets`, `ListsViewModel.ets`, `string.json` and both `List.test.ets` files. Two scopes that both
declare a write to one path never build at the same time, so BUILD runs those scopes one at a time
whatever `--parallel-scopes` says. The ceiling is the BUILD-order line's to state; re-cutting the scopes
so exactly one owns each of those files is the only fix, and it is a scope-cut decision for L1b, not a
dial.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — `assembleHap` with the house rules, **green at this open**.
- `./scripts/t0-test.sh` — `hvigorw test` unit tier, **green at this open** (`BUILD SUCCESSFUL in 4 s
  177 ms`). A new `*.test.ets` runs only if `app/entry/src/test/List.test.ets` imports it.
- `./scripts/launch-probe.sh` — install, start, liveness, faultlog delta and the live UI tree (written
  beside the run trace as `layout.json` and `screen.png`). It exits 2, not 1, when no device is attached,
  so a missing emulator reads as an environment gap rather than a failing feature. A device is attached
  at this open (`hdc list targets` → `127.0.0.1:5555`), so the pitch's "launches on the emulator"
  done-criterion is gradeable, and the QA hunt can run.
- `app/entry/src/ohosTest` fixtures need a signed HAP; `signingConfigs` is `[]`, so they go red for an
  environment reason no scope owns.
