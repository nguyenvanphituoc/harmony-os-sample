---
schema_version: 1
feature: list-above-keyboard
entry_point: app/entry/src/main/ets/entryability/EntryAbility.ets
---

# Wiring Map — list-above-keyboard

## Wiring

| use_case | engine | wiring_seam | entry_call_site | affordance |
|---|---|---|---|---|
| UC-01 | app/entry/src/main/ets/entryability/EntryAbility.ets | `⏳ TBD` keyboard-avoid setting (N1) — a window-level hook on `onWindowStageCreate`'s `windowStage.getMainWindowSync()` (e.g. `Window.on('avoidAreaChange')` / a `setKeyboardAvoidMode` equivalent) OR, if the spike at Build confirms page-level suffices, this row is superseded by the `ListPage.ets` row below; the concrete API name/enum is verified against the SDK's own `.d.ts` or a device probe at Wire/Build, not guessed here (domain-model.md) | app/entry/src/main/ets/entryability/EntryAbility.ets — `onWindowStageCreate`, after `windowStage.loadContent('pages/Index', …)` succeeds, alongside the existing `UiContextHolder.capture(...)` call | U1 new-item field (P2) → keyboard up → N1 resizes P2's content above the keyboard |
| UC-01 | app/entry/src/main/ets/features/todo/screens/list/ListPage.ets | candidate B for N1 (page-level): a `keyboardAvoidMode`/`.expandSafeArea` attribute on `ListPage`'s own `NavDestination`/outer `Column` — the alternative the spike is weighing against the window-level candidate above; whichever the spike confirms, `ListPage.ets`'s `List({ space: 12 }).layoutWeight(1)` itself is unchanged (INV-01) — it inherits the resized container for free | app/entry/src/main/ets/features/todo/screens/list/ListPage.ets — outer `Column`/`NavDestination` declaration, no change to the `List` component itself | U1 new-item field (P2) → keyboard up → N1 shrinks P2's `Column`, `List.layoutWeight(1)` shrinks with it |
| UC-01 | app/entry/src/main/ets/features/todo/screens/list/ListPage.ets | existing `Repeat<TodoItem>` inside the `List` — reachable once N1 shrinks the container, unchanged list/scroll mechanics; N2's `swipe` device step (below) is what proves it, not a code change here | app/entry/src/main/ets/features/todo/screens/list/ListPage.ets — `List({ space: 12 }).width('100%').layoutWeight(1)` (INV-01: no change to this declaration) | U3 item list (P2) → swipe → done item scrolled into view and tappable (R1) |
| UC-01 | app/entry/src/main/ets/features/todo/screens/list/ListViewModel.ets | unchanged `AddItem` call from `list.addButton`'s tap handler — no new wiring; cited so the chain from U2 to the resized list (R2) is traceable end to end | app/entry/src/main/ets/features/todo/screens/list/ListPage.ets — `RetroButton` `list.addButton` tap handler (existing) | U2 ADD (P2) → `AddItem` (unchanged) → new item visible, still within N1's resized `List` (R2) |
| UC-01 | app/entry/src/main/ets/features/todo/screens/listname/ListNameDialogHost.ets | `promptAction.openCustomDialog` overlay (existing `ListNameDialogHost.show`) — independent of `ListPage`'s `NavDestination` tree; whether it also receives N1 depends on which candidate (window-level vs. page-level) Build picks — verified by a device check against the dialog per R4, not assumed | app/entry/src/main/ets/features/todo/screens/listname/ListNameDialogHost.ets — `ListNameDialogHost.show()`, called from `ListsPage.ets`'s `lists.newButton`/`lists.renameButton` tap handlers (existing) | U4 name field (P3) → keyboard up → dialog stays fully visible (R4) |
| UC-01 | scripts/ui-flow.sh | new `swipe` op case added to the `if op == …` / `elif op == …` dispatch chain (around line ~118, following the existing `tap`/`doubletap` shape): resolves the target node by `id` via the existing `find(nodes, kind, value)` lookup (INV-05), then drives `uitest uiInput swipe <x1> <y1> <x2> <y2>` across that node's bounds instead of raw coordinates | scripts/ui-flow.sh — the step-dispatch `for i, line in enumerate(lines, 1)` loop, alongside the `tap`/`doubletap`/`type` branches | N2 `swipe id "<node>" up\|down` → device check exercises U3 (TS-01-01, TS-01-02, TS-01-06) |

## Deviations

- **N1's concrete API is `⏳ TBD` by design (domain-model.md, synthesis.md).** Two candidate
  attachment points are named above — a window-level hook in `EntryAbility.ets` (broader, reaches
  P3 directly) and a page-level attribute in `ListPage.ets` (narrower, requires a device check to
  confirm it doesn't leave P3 uncovered). This wiring map carries both rows deliberately: Build
  resolves N1 to exactly one of them against the SDK's own `.d.ts` or a device probe, per the
  synthesis risk register, and the row not chosen is dropped rather than built. The entry_call_site
  for both is named as design intent (a symbolic attachment), not an existing line number — the
  code for either candidate does not exist yet.
- **`EntryAbility.ets`'s `onWindowStageCreate` today calls only `windowStage.loadContent(...)` and
  `UiContextHolder.capture(...)`** — no window/keyboard-avoid call exists yet. The window-level N1
  candidate is a new statement in that same callback, not a modification of an existing one.
- No use case's engine is left without an attachment path — every row above names a real
  repo-relative file and an existing or design-intent seam. KB-SOL-002 (route/builder naming)
  does not apply here: this pitch adds no new routed screen (`route_map.json`/`pageSourceFile`
  entries), only a keyboard-avoid setting on the existing entry ability and list page, and a device-
  tooling change to `scripts/ui-flow.sh`. KB-SOL-001 (resolve wiring against the entry point that
  exists) is honored: `EntryAbility.ets` → `windowStage.loadContent('pages/Index', ...)` is the
  verified composition root, matching `module.json5`'s `mainElement: "EntryAbility"`.
