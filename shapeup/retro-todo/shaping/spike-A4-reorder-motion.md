---
shaping: true
feature: "[[retro-todo]]"
doc_type: spike
part: A4
status: resolved
---

# Spike: Can an item's move between the open and done groups animate without custom animation code?

## Question
When a toggled item moves from the open group to the done group (R7), does ArkUI animate the move for a
list rendered with `Repeat` or `ForEach`, using only a built-in mechanism?

## Acceptance Condition
Yes: a built-in transition softens the move at no extra cost.
No: the move is instant — the RH2 bound.

## Investigation
- `ui/rendering-control/arkts-new-rendering-control-repeat.md`: "Currently, **Repeat** does not support animations."
- For `ForEach`, the documented pattern covers insertion and deletion only — `ListItem().transition(TransitionEffect.OPACITY)` with `animateTo` around a `splice` (`reference/apis-arkui/arkui-ts/ts-container-listitem.md`). `onMove` (API 12+) is drag-to-sort, which is a no-go.
- Whether re-sorting a `ForEach` inside `animateTo` animates the move is undocumented; answering it needs an on-device spike. Confidence: medium.

Sources: gitee.com/openharmony/docs, master (`en/application-dev/`); researched 2026-09-15.

## Decision
**No.** The move is instant; no animation in this pitch (G3).

## Constraints Discovered
- Items render through `Repeat` (`docs/index.md` §8), keyed on every field the card draws — id, title and done. An id-only key left a renamed row stale in hero-todo, and here it would leave a toggled card looking open.
