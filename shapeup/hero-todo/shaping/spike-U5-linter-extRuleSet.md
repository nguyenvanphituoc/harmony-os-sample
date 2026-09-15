---
shaping: true
feature: "[[hero-todo]]"
doc_type: spike
part: A8
status: resolved
---

# Spike U5: From which DevEco Studio version does `code-linter.json5` accept `extRuleSet`?

## Question
ui-layer.md §8 U5. If `extRuleSet` works, rules L1–L11 could report in the IDE while typing instead of at build time.

## Acceptance Condition
Yes: the field exists → decide whether this pitch ports L1–L11 to Code Linter rules or keeps the hvigor task.
No: L1–L11 stay a hvigor task (build-time); §5 unchanged.

## Investigation
The official page *Code Linter* (`ide-code-linter`) did not render for fetching (JS-only site). Three independent write-ups that quote the DevEco guide agree on the same facts:
- `code-linter.json5` fields: `files`, `ignore`, `ruleSet`, `rules`, `overrides`, **`extRuleSet`**.
- `extRuleSet` "configures custom rules to be checked" and is **supported since DevEco Studio 5.1.0 Release**; custom rules are written per a separate *Custom Rule Development Guide*.

Sources (secondary — official page unreachable from here):
- https://www.cnblogs.com/strengthen/p/18469004
- https://blog.csdn.net/m0_70748845/article/details/143365163
- https://cloud.tencent.com/developer/article/2512754

Ten-second confirmation in the IDE: type `extRuleSet` in `app/code-linter.json5` and check completion — the project's toolchain is model 6.1.1, above 5.1.0.

## Decision
**Yes, the field exists — and this pitch still ships L1–L11 as the hvigor task (A8).** Custom Code Linter rules are a rule-development project of their own (RH4), and R17 is satisfied by build-time failure. Porting to `extRuleSet` becomes a follow-up raw idea for the Betting Table, not part of this appetite.

## Constraints Discovered
- A8's rule table is data (one table of `{ id, glob, pattern | check, level }`), so a later `extRuleSet` port reuses it instead of re-encoding eleven rules.
- `hvigorfile.ts` currently exports the ArkUI-X plugin tasks; the enforce task registers alongside them via hvigor's custom-task API. HarmonyOS-only target (GATE 2) means the plugin stays as is. Verified in the first build slice, not a spike.
- Doc update (R18): §8 U5 → "yes, ≥ 5.1.0 Release; rules stay build-time in the hero app, in-IDE port is a separate bet".
