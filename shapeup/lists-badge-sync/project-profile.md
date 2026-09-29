---
schema_version: 1
archetype: mobile
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
stack: "HarmonyOS 6.1.1 (API 24), ArkTS, ArkUI state management V2 only (@ComponentV2 / @ObservedV2 / @Trace / @Computed), ArkUI-X cross-platform module (crossplatform: true), hvigor + ohpm (DevEco Studio 6.1.1), @ohos/hypium 1.0.25 + @ohos/hamock 1.0.0, build-enforced house rules L1–L11 (app/build-src/enforce)"
build_probe: "./scripts/t0-assemble.sh"
launch_probe: "./scripts/launch-probe.sh"
---

# Project profile — lists-badge-sync

Re-derived on 2026-09-29 for branch `soak/retro-todo-4`, at this run's open
(`lists-badge-sync-20260929T064503Z-39c61f5a`, first run on this slug). `archetype`, `entry_point`
and `stack` are unchanged from the settle-across-screens / delete-settle / toggle-once profiles
(same project); every value below was re-measured on this checkout, not carried forward.

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `archetype` | `mobile` | one `entry` HAP, `"type": "entry"`, `deviceTypes: ["phone"]` — `app/entry/src/main/module.json5` |
| `entry_point` | `app/entry/src/main/ets/entryability/EntryAbility.ets` | `module.json5` → `abilities[0].srcEntry` |
| `build_probe` | `./scripts/t0-assemble.sh` | **executed green at this open** — `BUILD SUCCESSFUL in 4 s 479 ms`, house rules running, HAP unsigned (`signingConfigs` is `[]`) |
| `launch_probe` | `./scripts/launch-probe.sh` | **executed green at this open**: target `127.0.0.1:5555`, unsigned HAP installs, `start ability successfully`, pid alive, 14-node `uitest dumpLayout` tree — three seeded cards read `1/3 done` (Groceries), `1/2 done` (Work), `No items` (Weekend) |

## State of the tree at run open — this pitch's surface

Fresh pitch: no `shapeup/lists-badge-sync/spec/` or `shapeup/lists-badge-sync/scopes/` exist yet —
ANALYZE and MAP SCOPES have not run.

- `app/entry/src/main/ets/features/todo/screens/lists/ListsViewModel.ets:40-48` — `cards` is a
  `@Computed` getter over `this.store.lists` and `this.store.items`, mapping each list to a
  `ListCard(id, name, done, total)`. On paper this is observed correctly (`store` fields are
  `@Trace` on the `@ObservedV2 TodoStore`), which is what makes the break non-obvious — the pitch's
  Rabbit Holes call this out explicitly.
- `app/entry/src/main/ets/features/todo/screens/lists/ListsPage.ets:56-63` — `Repeat<ListCard>(this.vm.cards)`
  is keyed on `card.id + '|' + card.name + '|' + card.done + '|' + card.total` (line 63), so a key
  change should force a re-render; the badge text itself is built inside `cardBuilder(card: ListCard)`
  (line 12), a `@Builder` taking `card` as a plain parameter — the pitch's first suspect for where
  the update is passed by value instead of by reference.
- `app/entry/src/main/ets/features/todo/TodoModule.ets:63,71` — `this.lists` is a single
  `ListsViewModel` built once in the module's constructor (not per-visit), so — unlike the
  settle-across-screens `ListViewModel` bug — instance identity is not the suspect here; the module
  is not itself the link that drops the update.
- No `A1` spike has run yet: which exact link in store → `cards` → `Repeat` key → `@Builder`
  parameter → `AppText` drops the update is still unconfirmed. This is Shape A's first step and is
  ORIENT/spike territory, not something to pre-empt in this profile.

## House rules: what bites

Same `app/build-src/enforce/rule-table.ts` as retro-todo, toggle-once, delete-settle and
settle-across-screens: L1 (no hex literals), L3 (no quoted `Text(…)`/`.label(…)`/`.placeholder(…)`
literals — any new state/warning string goes through `string.json`), state management V2 only, no
`@Provider`/`@Consumer`. The pitch's No-goes rule out any new UI copy, so L1/L3 exposure should be
minimal — the fix is expected to land in a view model or its computed property, not new UI text.

## Verification tiers available at T0 and in the round build gate

- `./scripts/t0-assemble.sh` — green at this open.
- `./scripts/t0-test.sh` — unit tier; memory from prior runs on this project: `LocalUnit.test.ets`
  calls `assertNotEqual`, not present in `@ohos/hypium` 1.0.25, so the unit tier is red at baseline
  for a reason no scope owns. `ListsViewModel.ets` has no dedicated unit test file yet (only
  `ListViewModel.test.ets`, `List.test.ets` and the CRUD-flow tests exist under `app/entry/src/test/`)
  — R1–R3's unit proof (if any) needs a new or extended test file that avoids `assertNotEqual`.
- `./scripts/launch-probe.sh` — green at this open, device `127.0.0.1:5555` attached, so R4's device
  flow (the repro in shaping.md) and the QA hunt are both possible this run.
- `app/entry/src/ohosTest` fixtures need a signed HAP; `signingConfigs` is `[]`, so they stay red for
  an environment reason no scope owns (unchanged from every prior pitch on this project).
