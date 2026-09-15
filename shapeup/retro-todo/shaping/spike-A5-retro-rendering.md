---
shaping: true
feature: "[[retro-todo]]"
doc_type: spike
part: A5
status: resolved
---

# Spike: Can ArkUI draw the neo-brutalist card, the done state and a fixed light palette at API 24 in a cross-platform module?

## Question
1. Can `.shadow()` draw a hard, unblurred offset shadow?
2. Is there a strikethrough text decoration that takes a color?
3. Does a `base`-only palette hold when the system is in dark mode, and how is light mode pinned?
4. Does the proposed palette meet R12?

## Acceptance Condition
Yes: A5 renders the card, the done state and the palette with platform attributes and no bundled assets.
No: A5 composes the shadow from shapes, or R8 / R12 need a different treatment.

## Investigation

**How the cross-platform check decides.** In the installed SDK 6.1.1.125 the ets-loader
(`api_check_define.js`, `api_check_utils.js`) raises 11706007 "can't support crossplatform application"
only when `projectConfig.isCrossplatform` is set, and it decides by the `@crossplatform` JSDoc tag in
`DevEco-Studio.app/Contents/sdk/default/openharmony/ets/{api,component}/*.d.ts`. The SDK tag, not the
older ArkUI-X docs, is what decides whether a call compiles.

1. **Shadow.** `shadow(value: ShadowOptions | ShadowStyle)`; `ShadowOptions { radius, type?, color?, offsetX?, offsetY?, fill? }`, all in px, `@crossplatform` since 11. `ui/arkts-shadow-effect.md`: "When the radius or color opacity in **ShadowOptions** is set to **0**, there is no shadow effect." `fill` fills the component's inside with shadow; it does not sharpen the edge. ArkUI's `shadow.h` `IsValid()` accepts an offset-only shadow — source code contradicting the docs, so not relied on.
2. **Strikethrough.** `decoration({ type: TextDecorationType.LineThrough, color?, style? })`. The interface form is API 12, `LineThrough` 11, `TextDecorationStyle` 12 (SOLID by default); all `@crossplatform`. Sources: `reference/apis-arkui/arkui-ts/ts-basic-components-text.md`, `ts-appendix-enums.md`.
3. **Dark mode.** `ui/ui-dark-light-color-adaptation.md`: "If no dark resources are available, system components maintain light color appearances in dark mode"; `base`-only app colors do not change. The repository holds an empty, untracked `resources/dark/` folder left over from hero-todo, and the docs do not say whether an empty folder counts as dark resources. `ApplicationContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT)` exists since API 11, runs on the main thread after `loadContent`, and its effect "takes precedence"; SDK `@crossplatform` since 18 (ArkUI-X's own ApplicationContext page omits it, but the tag lets it compile).
4. **Contrast.** WCAG 2.x relative luminance, computed for each pair:

| Foreground on background | Ratio | Needs | Used for |
|---|---|---|---|
| `ink` #1A1A1A on `background` #FFF4E0 | 15.97 | 4.5 | titles, list names |
| `ink` on `surface` #FFFFFF | 17.40 | 4.5 | open item text |
| `inkMuted` #5E5242 on `surface` | 7.60 | 4.5 | secondary text ("3/5 done") |
| `inkMuted` on `surfaceDone` #F2E8D5 | **6.26** | 4.5 | done item text (R8 + R12) |
| `inkMuted` on `background` | 6.98 | 4.5 | secondary text on the ground |
| `ink` on `brand` #FFD23F | 12.05 | 4.5 | primary button label |
| `onDanger` #FFFFFF on `danger` #C1121F | 6.22 | 4.5 | destructive button label |
| `ink` border on `background` / `surface` / `surfaceDone` | 15.97 / 17.40 / 14.32 | 3.0 | card border, check box |

Sources: gitee.com/openharmony/docs, master (`en/application-dev/`, paths above) and the SDK 6.1.1.125
declarations; researched 2026-09-15.

## Decision
1. **No.** The card is a `Stack`: a solid `ink` block offset by the shadow token, behind a face with a 2vp `ink` border.
2. **Yes.** Done text uses `decoration` LineThrough in `inkMuted`.
3. **Pin light mode.** `setColorMode(COLOR_MODE_LIGHT)` in the `loadContent` callback of `EntryAbility` (A6); ship no `dark/` resources.
4. **Yes.** Every pair passes; the lowest text pair is 6.26:1.

## Constraints Discovered
- `.offset()` reserves no layout space: the card reserves its shadow offset as margin, and its parent does not clip.
- No app-wide default-font API exists; this does not matter while the system font is used.
- Residual device check: with the system in dark mode on the Pura 90, the app — dialogs and text fields included — stays light.
