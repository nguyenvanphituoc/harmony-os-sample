---
shaping: true
feature: "[[hero-todo]]"
doc_type: spike
part: A5
status: resolved
---

# Spike U2: Can `@BuilderParam` be used inside `@ComponentV2`?

## Question
ui-layer.md §8 U2. The doc's §1.2 routes all child content through `WrappedBuilder<[XParams]>` passed as `@Param`, and notes the V2 docs are unclear on `@BuilderParam`. If it works, patterns with a fixed slot (`ScreenScaffold` body, `AppCard` content, `FormFrame` fields) could take the slot natively.

## Acceptance Condition
Yes: fixed slots may use `@BuilderParam`; keyed selection keeps the registry mechanism (§1.4).
No: every slot is a `WrappedBuilder` via `@Param` — the doc's stated fallback; architecture unchanged either way.

## Investigation
Official OpenHarmony doc *@BuilderParam Decorator* (same as the HarmonyOS guide):
> "Use the global or local @Builder to initialize the @BuilderParam attribute in the custom component decorated with @ComponentV2."
> "When the @Require and @BuilderParam decorators are used together, the latter must be initialized."
> "@BuilderParam decorated variables can be initialized only by using the @Builder function."

The *@Require Decorator* doc lists `@BuilderParam` among the decorators `@Require` can validate (since API 11) and shows `@ComponentV2` examples. The *@ComponentV2 Decorator* page lists only *state-variable* decorators (`@Local`, `@Param`, `@Once`, `@Event`, `@Provider`, `@Consumer`) — `@BuilderParam` is not a state-variable decorator, which is why it is absent there, not because it is forbidden.

Sources:
- https://gitee.com/openharmony/docs/blob/master/en/application-dev/ui/state-management/arkts-builderparam.md
- https://gitee.com/openharmony/docs/blob/master/en/application-dev/ui/state-management/arkts-require.md
- https://gitee.com/openharmony/docs/blob/master/en/application-dev/ui/state-management/arkts-new-componentV2.md

## Decision
**Yes.** Convention for the hero app (recorded for the doc):
- **Fixed slot** (exactly one child area, no selection by key): `@Require @BuilderParam` — `ScreenScaffold.body`, `AppCard.content`, `FormFrame.fields`.
- **Keyed selection** (field leaf, overlay body, list item renderer, status branch, theme): the registry — `enum` key → `WrappedBuilder<[XParams]>` — exactly as §1.4. One mechanism for the five keyed places stays true.

## Constraints Discovered
- `@BuilderParam` accepts only `@Builder` functions; a registry value (`WrappedBuilder`) is passed through `@Param` and invoked with `.builder(p)`. The two are not interchangeable, so a pattern's signature says which one it is.
- The single-object-parameter rule (§1.4 trap 1) applies to both: slot builders are `(p: XParams)` too, or they lose reactivity.
- Doc update (R18): §1.2 row "Nội dung con" splits into the two cases above; §8 U2 → resolved.
