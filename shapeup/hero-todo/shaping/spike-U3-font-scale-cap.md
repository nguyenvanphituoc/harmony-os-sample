---
shaping: true
feature: "[[hero-todo]]"
doc_type: spike
part: A7
status: resolved
---

# Spike U3: Can the app cap the system font-size scale at application level?

## Question
ui-layer.md §8 U3. `fontSizeScale` can be read from the configuration; is there an API to set a ceiling? If not, layouts must survive the largest system setting (R12).

## Acceptance Condition
Yes: a declarative cap exists; decide whether the hero app uses it.
No: §4.4 stands unchanged — every layout must survive the maximum scale.

## Investigation
Official OpenHarmony doc *app.json5 Configuration File* (same as the HarmonyOS guide):
- `app.json5` has a `configuration` field: *"Whether the font size of the current application follows the system"*, pointing at a profile, e.g. `"$profile:configuration"`.
- The profile lives at `AppScope/resources/base/profile/configuration.json`:

| Field | Values | Default |
|---|---|---|
| `fontSizeScale` | `followSystem` · `nonFollowSystem` | **`nonFollowSystem`** |
| `fontSizeMaxScale` | `1` · `1.15` · `1.3` · `1.45` · `1.75` · `2` · `3.2` | `3.2` (only applies with `followSystem`) |

```json
{ "configuration": { "fontSizeScale": "followSystem", "fontSizeMaxScale": "3.2" } }
```

Source: https://gitee.com/openharmony/docs/blob/master/en/application-dev/quick-start/app-configuration-file.md

## Decision
**Yes, a cap exists — but the important finding is the default.** Per the doc an app does **not** follow the system font size unless it opts in. The hero app opts in (`followSystem`) and does **not** cap (`3.2`), because R12 is "no clipping at the largest size": a cap would hide exactly the failures the rule exists to catch.

## Constraints Discovered
- A7 gains `AppScope/resources/base/profile/configuration.json` and the `configuration` field in `AppScope/app.json5`.
- Doc update (R18): §4.4 keeps its rule and gains one line — *`fp` only scales when `configuration.json` says `followSystem`; the default is not to follow.*
- Verify on device that `fp` text scales after opting in (the default-value claim is from the doc text; confirm during slice V1 with the system font slider).
