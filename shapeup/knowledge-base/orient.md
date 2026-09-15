# Knowledge Base — orient

> Team-shared guidelines distilled by `/coach` from PO/TL feedback at the Ship Gate (L4), a
> project scan, or official-docs research. Read by `orient` at the top of its run.
> **Guidelines, not invariants** — they steer the worker; they never override a spec, widen a
> substrate, resolve a gate or change the spec-evaluator verdict (single-judge rule).
> Committed on purpose: a teammate inherits these on `git pull`.

## Guidelines
- **KB-OR-001** — `docs/index.md` and `docs/ui-layer.md` (Vietnamese) are the architecture authority, but check their platform claims before a pitch leans on them. Each of these is **unconfirmed** — the official docs at API 24 disagree, so verify (or spike) before speccing:
  - SDK level: the docs say 22/23; `app/build-profile.json5:8-9` says `6.1.1(24)` — check every API against 24.
  - `.ts` layering (`docs/index.md:114`): the docs say the compiler bars `domain/*.ts` from `@kit.*`; officially only `.ts` importing `.ets` is barred, and ArkTS validation covers `.ets` files.
  - AppStartup (`docs/index.md:504-508`): the docs say a `mainThread` task with `waitOnMainThread: false` does not block the first frame; officially `waitOnMainThread` applies only to `taskPool` tasks.
  - `@Concurrent` in `data/*.ts` (`docs/index.md:380`): officially `.ets` only.
  - Stack restore after a kill, `onWillHide` on backgrounding, `fp` following the system font, and element file names (`docs/ui-layer.md` §2.2, §2.5, §4.4, §3.2) — each contradicted.
  - Open questions U1, U2, U3, U5 (`docs/ui-layer.md` §8) are answered officially — plural `$r` works directly, `@BuilderParam` works in `@ComponentV2`, `fontSizeMaxScale`/`maxFontScale`/`setFontSizeScale` cap scaling, `extRuleSet` exists since DevEco 5.1.0; U4 only partly.

  _(why: a spec built on a doc claim the platform contradicts fails on the device, not at review)_  ·  from project-scan @ b8377ad; web-research (https://gitee.com/openharmony/docs/blob/master/en/application-dev/application-models/app-startup.md, https://gitee.com/openharmony/docs/blob/master/en/application-dev/quick-start/typescript-to-arkts-migration-guide.md, https://gitee.com/openharmony/docs/blob/master/en/application-dev/arkts-utils/taskpool-introduction.md, https://developer.huawei.com/consumer/en/doc/harmonyos-guides/ide-code-linter, API 24, 2026-09-15)
- **KB-OR-002** — Settle per pitch whether it targets HarmonyOS only. `crossplatform: true` (`app/.arkui-x/arkui-x-config.json5:2`) makes the ArkUI-X checker apply to every build either way, and AppStartup, Asset Store Kit and Remote Communication Kit (`rcp`) — central to `docs/index.md` — are not on ArkUI-X's API list (relationalStore is, without Worker support). A pitch that needs any of them on Android/iOS spikes it first. _(why: whole features can be missing on Android/iOS; the list evidence is by absence, so it is inferred)_  ·  from project-scan @ b8377ad; confirmed by web-research (https://gitee.com/arkui-x/docs/blob/master/zh-cn/application-dev/reference/apis/README.md, ArkUI-X API 24, 2026-09-15)
- **KB-OR-003** — The architecture in `docs/` is a plan, not code: `features/`, `adapters/`, `shared/`, `route_map.json`, `startup_config.json`, `AppModules` and the hvigor import-rule task do not exist yet (`app/hvigorfile.ts` and `app/entry/hvigorfile.ts` are stock), and 6 of the 8 design docs are unwritten (`docs/index.md:74-84`). Report which of these a pitch must create and which it can rely on. _(why: a spec that assumes them builds on nothing)_  ·  from project-scan @ b8377ad
