// Single rule-table data file for the §5 "Enforce" rules (docs/ui-layer.md §5).
//
// Bound by RH4: every rule below is a text scan or a set comparison — no AST, no parser
// project. `severity` is the only thing that decides whether a hit fails the build (`error`)
// or only warns (`warning`): L1-L9 are `error`, L10-L11 are `warning`.
//
// This table is data only. The scan/compare logic that reads it lives in `scan.ts`, one
// function per `checkId`, kept 1:1 with the row below so the table stays the single source of
// truth for "which rule is which severity" (the boundary AC: exactly nine error, exactly two
// warning).

export type RuleSeverity = "error" | "warning";

export interface RuleDefinition {
  /** L1-L11, per docs/ui-layer.md §5. */
  id: string;
  /** One line naming the rule, echoed into every violation message. */
  title: string;
  /** How the rule is checked — echoed into escalations/docs, not parsed. */
  scanPattern: string;
  severity: RuleSeverity;
  /** Key into `scan.ts`'s dispatch table; 1:1 with `id`. */
  checkId: string;
}

export const RULE_TABLE: RuleDefinition[] = [
  {
    id: "L1",
    title: "No raw hex color literal in .ets",
    scanPattern: "/#[0-9a-fA-F]{3,8}/ in **/*.ets",
    severity: "error",
    checkId: "noRawHexColor",
  },
  {
    id: "L2",
    title: "No @Styles / @Extend in shared/uikit",
    scanPattern: "@Styles|@Extend decorator in shared/uikit/**/*.ets",
    severity: "error",
    checkId: "noStylesExtendInUikit",
  },
  {
    id: "L3",
    title: "No literal string in display-text position",
    scanPattern: "Text('…') | .label('…') | .placeholder('…') in **/*.ets",
    severity: "error",
    checkId: "noLiteralDisplayText",
  },
  {
    id: "L4",
    title: "Every ErrorCode has a mapping and a real string.json key",
    scanPattern: "enum ErrorCode members ↔ mapping table ↔ resources/base/element/string.json keys",
    severity: "error",
    checkId: "errorCodeMappingComplete",
  },
  {
    id: "L5",
    title: "Every base/ resource key present in every language qualifier",
    scanPattern: "key set of resources/base/element/{string,plural}.json ⊆ every resources/<lang>/element/*.json",
    severity: "error",
    checkId: "everyBaseKeyTranslated",
  },
  {
    id: "L6",
    title: "route_map.json entries match @Builder pages two ways",
    scanPattern: "route_map.json buildFunction ↔ global @Builder in **/*Page.ets",
    severity: "error",
    checkId: "routeMapMatchesPages",
  },
  {
    id: "L7",
    title: "getStringSync only inside shared/uikit/i18n",
    scanPattern: "getStringSync( occurrences outside shared/uikit/i18n/**",
    severity: "error",
    checkId: "getStringSyncScopedToI18n",
  },
  {
    id: "L8",
    title: "No LazyForEach — use Repeat",
    scanPattern: "LazyForEach identifier in **/*.ets",
    severity: "error",
    checkId: "noLazyForEach",
  },
  {
    id: "L9",
    title: "No @Provider / @Consumer",
    scanPattern: "@Provider|@Consumer decorator in **/*.ets",
    severity: "error",
    checkId: "noProviderConsumer",
  },
  {
    id: "L10",
    title: "No raw dimension literal outside shared/uikit",
    scanPattern: ".padding(16) | .width(200) style numeric literals outside shared/uikit/**",
    severity: "warning",
    checkId: "noRawDimensionOutsideUikit",
  },
  {
    id: "L11",
    title: "Unused string resource key",
    scanPattern: "resources/base/element/string.json keys ⊆ $r('app.string.…') occurrences",
    severity: "warning",
    checkId: "noUnusedStringKey",
  },
];

export const ERROR_RULE_COUNT = RULE_TABLE.filter((rule) => rule.severity === "error").length;
export const WARNING_RULE_COUNT = RULE_TABLE.filter((rule) => rule.severity === "warning").length;
