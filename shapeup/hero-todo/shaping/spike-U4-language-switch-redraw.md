---
shaping: true
feature: "[[hero-todo]]"
doc_type: spike
part: A6, A11
status: resolved
---

# Spike U4: Does `setAppPreferredLanguage` redraw every open screen at once, or does the UI need rebuilding?

## Question
ui-layer.md §8 U4. R11 promises a live language switch without restart; R14's Settings screen triggers it. Does the running app's UI switch, and do screens lower in the navigation stack repaint?

## Acceptance Condition
Yes: Settings ViewModel calls `i18n.System.setAppPreferredLanguage(tag)`; every screen's `$r` re-resolves; no further code.
No: after the call the app must rebuild its UI (clear the `NavPathStack` and re-push); R11 holds only with that trick and it becomes part of A6.

## Investigation
API reference *System.setAppPreferredLanguage* (API 11+):
> "Sets the preferred language of the application. Resources are loaded in the preferred language when the application is launched. If the preferred language is set to **default**, the application's language will be the same as the system language, and the setting will take effect upon cold starting of the application."

Guide *Preferred Language* (Localization Kit):
> "After the preferred language of the application is set to the target language, the application UI is switched to the target language." · "This setting is subject only to the application. It does not affect the system language settings." · default → "the setting will take effect upon application restarting."

Reading of both together: setting a **concrete** language tag switches the running app's UI; only resetting to **`default`** waits for a cold start. Neither page states whether screens *below the top of the stack* repaint immediately or on their next `onShown`. That residual is the doc's own proposed test (switch on the third screen, pop back twice) and needs a device.

Sources:
- https://gitee.com/openharmony/docs/blob/master/en/application-dev/reference/apis-localization-kit/js-apis-i18n.md
- https://gitee.com/openharmony/docs/blob/master/en/application-dev/internationalization/i18n-preferred-language.md

## Decision
**Yes for concrete tags.** Consequence under the GATE 1 decision that settings are volatile: a "Follow system" option would be a no-op for the running process (it applies at the next cold start, which resets to the system language anyway). The Settings language picker therefore offers **English / Tiếng Việt only**; the fresh-launch state *is* "follow system". (Decided at GATE 3.)

## Constraints Discovered
- Strings must never be cached: components hold `Resource`, `getStringSync` stays inside `shared/uikit/i18n` (§3.6 rule 2) — otherwise the switch leaves stale text on screen.
- Residual device check goes into A9 as an instrumented test: set language on TodoDetail (third screen), pop to TodoList, assert both screens show the new language. If a lower screen is stale, add a silent refresh in `onShown` (no shape change).
- Doc update (R18): §3.6 table row "user picks in app" gains *"a concrete tag applies immediately; `default` applies at the next cold start"*; for this app the "write to `preferences`, re-apply at startup" clause is dropped (volatile settings).
