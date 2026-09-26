---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — retro-todo

Re-derived on 2026-09-26 for branch `soak/retro-todo-3`, cut from `main` (the untouched DevEco
template) with the harness infrastructure carried over and no feature code: the T0 fixture scripts
and the launch probe, the permission grant, the knowledge base, `docs/`, and the build-enforced house
rules (`app/build-src/enforce`, wired from both hvigorfiles). `app/entry/src/main/` is byte-identical
to `main`. Every field below was measured on this branch, not carried from the previous profile — that
one described a branch that already held hero-todo's feature, and every consequence it drew from that
is void here.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `stack` | above | `app/build-profile.json5`, `app/oh-package.json5`, `app/hvigorfile.ts`, `app/.arkui-x/arkui-x-config.json5` |
| `build_probe` | `./scripts/t0-assemble.sh` | committed fixture, grant-covered, **executed green on this branch** — `BUILD SUCCESSFUL in 4 s 292 ms`, house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | committed fixture, one grantable command, **executed green on this branch**: target `127.0.0.1:5555`, the unsigned HAP installs, `start ability successfully`, process alive, no new faultlog, and a `uitest dumpLayout` tree with exactly one text node — `[Text] Hello World`, the template |

## The baseline is the pitch's baseline

Measured on this branch, and matching the pitch's Baseline section:

- `pages/Index.ets` is the template's V1 `@Entry @Component` showing "Hello World"; `EntryAbility.ets`
  loads it through `main_pages.json`.
- `module.json5` declares no `routerMap` and no `appStartup`; there is no `route_map.json`, no
  `startup_config.json`, no `ets/appstartup/`.
- `app/entry/src/main/ets/` holds only `entryability/` and `pages/` — no
  `features/`, no `shared/`.
- `app/.arkui-x/` is present and `arkui-x-config.json5` says `crossplatform: true`, so the pitch's
  constraint is live: an API without the SDK's `@crossplatform` tag fails `CompileArkTS` with 11706007.

The pitch's RH1 bound — no `route_map.json`, no AppStartup task, no change to `module.json5` — is
therefore the zero-change option here, not a removal.

## House rules: what bites on this baseline

`app/build-src/enforce/rule-table.ts` runs at hvigorfile module-evaluation time, so one error-level hit
reds **every** hvigor target before any task runs (L1–L9 `error`, L10–L11 `warning`).

- **L6 is inert while there is no `route_map.json`.** Its check returns no finding when that file is
  absent (`app/build-src/enforce/scan.ts:155`). A builder route table inside `pages/Index.ets` is the
  navigation design that needs no route file, and a screen named `*Page.ets` declaring a
  `@Builder function` trips nothing. Creating `route_map.json` would arm L6 in both directions *and*
  require a `module.json5` change the pitch forbids — so no scope should create it.
- **L1** forbids hex literals in any `.ets`, comments included: the retro palette goes in `color.json`
  and is read through `$r('app.color.…')`. **L3** forbids quoted literals in `Text(…)`, `.label(…)`,
  `.placeholder(…)`: every visible string goes through `string.json`. **L8** forbids `LazyForEach` (use
  `Repeat`). **L9** forbids `@Provider`/`@Consumer`. **L7** forbids `getStringSync(`. **L10** warns on a
  raw dimension literal outside `shared/uikit`.

## Concurrency consequence for MAP SCOPES at GATE L1b

`color.json`, `float.json`, `string.json` and `pages/Index.ets` are each one file edited
read-modify-write. Each must appear in exactly **one** scope's `allowed_file_substrate`, or the scopes
that share it serialise regardless of `--parallel-scopes`. That is a reason to give each resource file
an owner, not a reason to collapse the feature into one scope.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — `assembleHap` with the house rules, green at baseline.
- `./scripts/t0-test.sh` — `hvigorw test` unit tier, green at baseline on the template's own tests. A new
  `*.test.ets` runs only if `app/entry/src/test/List.test.ets` imports it.
- `./scripts/launch-probe.sh` — install, start, liveness, faultlog delta and the live UI tree
  (written beside the run trace as `layout.json` and `screen.png`). It exits 2, not 1, when no device is attached, so
  a missing emulator reads as an environment gap rather than a failing feature. The pitch's "launches on
  the emulator" done-criterion is gradeable on this machine.
