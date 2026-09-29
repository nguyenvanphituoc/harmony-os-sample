---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — list-above-keyboard

Re-derived on 2026-09-29 for branch `soak/retro-todo-4`, at this run's open
(`list-above-keyboard-20260929T080442Z-50fdd025`, first run on this slug). `archetype`, `entry_point`
and `stack` are unchanged from the lists-badge-sync / settle-across-screens / delete-settle /
toggle-once profiles (same project); every value below was re-measured on this checkout, not carried
forward.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `build_probe` | `./scripts/t0-assemble.sh` | **executed green at this open** — `BUILD SUCCESSFUL in 3 s 760 ms`, house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | **executed green at this open**: target `127.0.0.1:5555`, unsigned HAP installs, `start ability successfully`, pid 6293 alive, 14-node `uitest dumpLayout` tree — three seeded cards read `1/3 done` (Groceries), `1/2 done` (Work), `No items` (Weekend) |

## State of the tree at run open — this pitch's surface

Fresh pitch: no `shapeup/list-above-keyboard/spec/` or `shapeup/list-above-keyboard/scopes/` exist
yet — ANALYZE and MAP SCOPES have not run.

- `app/entry/src/main/ets/features/todo/screens/list/ListPage.ets` — a `NavDestination` → `Column`
  with the back/title row, the add row (`RetroField` `list.newItemField` + `RetroButton`
  `list.addButton`), an optional error `Text`, then `AsyncBoundary` → `readyBuilder()`: a `List({
  space: 12 })` with `.layoutWeight(1)` over `Repeat<TodoItem>(this.vm.items)`. Confirms the
  shaping doc's read: nothing in this file or its ancestors sets a keyboard-avoid mode
  (`setKeyboardAvoidMode`, `expandSafeArea`) — the platform default applies, so the `List`'s
  `layoutWeight(1)` currently resolves against the *full* page height, not the height above the
  keyboard.
- `app/entry/src/main/ets/features/todo/screens/listname/ListNameDialog.ets` and
  `ListNameForm.ets` — the new-list / rename dialogs (R4's surface); not yet read for how they're
  presented (dialog controller vs. inline), which the A1 spike needs before it picks window-wide vs.
  page-level.
- `scripts/ui-flow.sh` — confirmed: dispatches `launch`, `tap`, `doubletap`, `type`, `back`, `wait`,
  and the `expect` family (`text`, `no text`, `count`, `order`). No `swipe` op exists — A3 is a real
  gap, not a restatement; the executor adds a case to the `if op == …` chain in the embedded Python
  (around line 120), following the existing `tap`/`doubletap` shape (resolve the node by `id`, then
  drive `uitest` — here `uiInput swipe <x1> <y1> <x2> <y2>` inside the node's bounds — rather than a
  raw coordinate swipe, so the step stays keyed to `id` like every other op).
- No `A1` spike has run yet: window-wide (`UIContext.getWindowUtils` grabs no keyboard-avoid API
  directly — the app-level hook is `Window.on('avoidAreaChange')`/`setKeyboardAvoidMode` on the
  `UIAbility`'s main window, reached from `EntryAbility.ets`) versus page-level
  (`.expandSafeArea`/a `keyboardAvoidMode` on `ListPage`'s own `NavDestination`) is still open. This
  is Shape A's first step and is ORIENT/spike territory, not something to pre-empt in this profile.

## House rules: what bites

Same `app/build-src/enforce/rule-table.ts` as retro-todo, toggle-once, delete-settle,
settle-across-screens and lists-badge-sync: L1 (no hex literals), L3 (no quoted
`Text(…)`/`.label(…)`/`.placeholder(…)` literals — any new state/warning string goes through
`string.json`), state management V2 only, no `@Provider`/`@Consumer`. The pitch's No-goes rule out
any new UI copy beyond what's already in `string.json`, so L1/L3 exposure should be minimal — the
fix is expected to land in layout/window config, not new UI text.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — green at this open.
- `./scripts/t0-test.sh` — unit tier; memory from prior runs on this project: `LocalUnit.test.ets`
  calls `assertNotEqual`, not present in `@ohos/hypium` 1.0.25, so the unit tier is red at baseline
  for a reason no scope owns. R1/R2 are layout/keyboard-avoid behavior with no natural unit-test
  surface; R5's proof is the device tier (`ui-flow.sh`), not this tier.
- `./scripts/launch-probe.sh` — green at this open, device `127.0.0.1:5555` attached, so R1, R2, R3,
  R4's device flows and the QA hunt are all possible this run.
- `app/entry/src/ohosTest` fixtures need a signed HAP; `signingConfigs` is `[]`, so they stay red for
  an environment reason no scope owns (unchanged from every prior pitch on this project).
