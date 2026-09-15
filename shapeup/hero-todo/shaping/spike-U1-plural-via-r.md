---
shaping: true
feature: "[[hero-todo]]"
doc_type: spike
part: A4, A7
status: resolved
---

# Spike U1: Can `$r('app.plural.x', n)` be used directly, or must plurals go through `resourceManager.getPluralStringValue`?

## Question
ui-layer.md §8 U1. The doc's §3.5 shows `plural.json` but only describes the `resourceManager` path. Can a `Text` take a plural Resource straight from `$r`, so the TodoList count row (R2) needs no wrapper?

## Acceptance Condition
Yes: TodoList's count is `Text($r('app.plural.todoList_itemCount', n, n))` (built in a `@Computed` getter of the ViewModel). No wrapper in `shared/uikit/i18n`.
No: add a `pluralText(key, n): string` helper in `shared/uikit/i18n` that calls `resourceManager.getPluralStringValue` — the one folder allowed to resolve eagerly (§3.6 rule 2), re-called on every draw.

## Investigation
Official OpenHarmony doc *Resource Categories and Access* (same content as the HarmonyOS guide of the same name):
- `plural.json` declares quantity forms (`one`, `other`, …) under `element/`.
- Direct usage is documented verbatim: `Text($r('app.plural.eat_apple', 2, 2))` — the first argument selects the quantity form, the following arguments fill `%d`.
- There is no statement that plurals must go through `resourceManager`.

Source: https://gitee.com/openharmony/docs/blob/master/en/application-dev/quick-start/resource-categories-and-access.md

## Decision
**Yes.** R2's count uses `$r('app.plural.todoList_itemCount', n, n)`; covered by A4 + A7, no i18n wrapper. Architecture unchanged (as the doc predicted).

## Constraints Discovered
- The count is passed twice (form selector + `%d` value). Build the plural Resource only inside a `@Computed` getter of the ViewModel: `count` stays `@Trace`, the Resource is derived — the same rule as §3.5 "derive at draw, never cache formatted text".
- Vietnamese has only `other`; English has `one`/`other`. `base/element/plural.json` (English) must carry both forms because `base` is the complete fallback.
- Doc update (R18): §8 U1 → resolved; §3.5 example gains the `$r(key, n, n)` form.
