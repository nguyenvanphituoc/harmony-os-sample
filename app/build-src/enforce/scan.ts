// One check function per `RULE_TABLE` row (`checkId`), each a text scan or a set comparison —
// no AST, no parser project (RH4). A rule whose target directory does not exist yet (most
// `features/**`/`shared/**` paths, before their owning scope builds them) reports zero
// violations rather than erroring — an absent tree is not a rule violation.

import * as fs from "fs";
import * as path from "path";
import { RuleDefinition, RuleSeverity } from "./rule-table";
import { listFilesWithExt, readIfExists, readJsonIfExists, scanMatches } from "./fs-scan";

export interface Violation {
  rule: RuleDefinition;
  severity: RuleSeverity;
  file: string;
  line: number;
  message: string;
}

function violation(rule: RuleDefinition, file: string, line: number, message: string): Violation {
  return { rule, severity: rule.severity, file, line, message };
}

function relPath(root: string, file: string): string {
  return path.relative(root, file);
}

/** Flat JSON object's own keys, one level deep — the shape every `element/*.json` resource file uses. */
function jsonKeys(value: unknown): Set<string> {
  const keys = new Set<string>();
  if (value && typeof value === "object" && !Array.isArray(value)) {
    const record = value as Record<string, unknown>;
    const list = record["string"] ?? record["plural"] ?? record["array"];
    if (Array.isArray(list)) {
      for (const entry of list) {
        if (entry && typeof entry === "object" && typeof (entry as Record<string, unknown>).name === "string") {
          keys.add((entry as Record<string, unknown>).name as string);
        }
      }
    }
  }
  return keys;
}

function noRawHexColor(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  for (const file of listFilesWithExt(root, ".ets")) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, /#[0-9a-fA-F]{3,8}\b/)) {
      out.push(violation(rule, relPath(root, file), hit.line, `raw hex color literal "${hit.match}"`));
    }
  }
  return out;
}

function noStylesExtendInUikit(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const uikitRoot = path.join(root, "shared", "uikit");
  for (const file of listFilesWithExt(uikitRoot, ".ets")) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, /@(Styles|Extend)\b/)) {
      out.push(violation(rule, relPath(root, file), hit.line, `"${hit.match}" decorator inside shared/uikit`));
    }
  }
  return out;
}

function noLiteralDisplayText(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const pattern = /\b(?:Text|\.label|\.placeholder)\(\s*(['"])(?:(?!\1).)*\1/;
  for (const file of listFilesWithExt(root, ".ets")) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, pattern)) {
      out.push(violation(rule, relPath(root, file), hit.line, `literal string display text "${hit.match}"`));
    }
  }
  return out;
}

function errorCodeMappingComplete(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const kernelDir = path.join(root, "shared", "kernel");
  const enumFile = listFilesWithExt(kernelDir, ".ts").find((f) => /error\.(ts|ets)$/.test(f))
    ?? listFilesWithExt(kernelDir, ".ets").find((f) => /error\.(ts|ets)$/.test(f));
  if (!enumFile) return out; // shared/kernel/error not built yet in this scope
  const text = readIfExists(enumFile);
  if (!text) return out;
  const enumMatch = /enum\s+ErrorCode\s*{([^}]*)}/.exec(text);
  if (!enumMatch) return out;
  const members = Array.from(enumMatch[1].matchAll(/([A-Z][A-Z0-9_]*)\s*(?:=|,|$)/g)).map((m) => m[1]);
  const stringJson = readJsonIfExists(path.join(root, "resources", "base", "element", "string.json"));
  const keys = jsonKeys(stringJson);
  for (const member of members) {
    if (!text.includes(member) || keys.size === 0) continue;
    const key = member.toLowerCase().replace(/_/g, "_");
    if (!Array.from(keys).some((k) => k.toLowerCase().includes(key))) {
      out.push(
        violation(rule, relPath(root, enumFile), lineAtMember(text, member), `ErrorCode.${member} has no matching string.json key`),
      );
    }
  }
  return out;
}

function lineAtMember(text: string, member: string): number {
  const idx = text.indexOf(member);
  if (idx < 0) return 1;
  return text.slice(0, idx).split("\n").length;
}

function everyBaseKeyTranslated(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const baseDir = path.join(root, "resources", "base", "element");
  const resourcesDir = path.join(root, "resources");
  let langs: string[] = [];
  try {
    langs = fs
      .readdirSync(resourcesDir, { withFileTypes: true })
      .filter((e: fs.Dirent) => e.isDirectory() && e.name !== "base" && e.name !== "dark")
      .map((e: fs.Dirent) => e.name);
  } catch {
    return out; // resources/ not built yet
  }
  for (const fileName of ["string.json", "plural.json"]) {
    const baseJson = readJsonIfExists(path.join(baseDir, fileName));
    if (!baseJson) continue;
    const baseKeys = jsonKeys(baseJson);
    if (baseKeys.size === 0) continue;
    for (const lang of langs) {
      const langJson = readJsonIfExists(path.join(resourcesDir, lang, "element", fileName));
      const langKeys = jsonKeys(langJson);
      for (const key of baseKeys) {
        if (!langKeys.has(key)) {
          out.push(
            violation(
              rule,
              relPath(root, path.join(resourcesDir, lang, "element", fileName)),
              1,
              `key "${key}" missing from ${lang}/element/${fileName}`,
            ),
          );
        }
      }
    }
  }
  return out;
}

function routeMapMatchesPages(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const routeMap = readJsonIfExists(path.join(root, "entry", "src", "main", "resources", "base", "profile", "route_map.json"))
    ?? readJsonIfExists(path.join(root, "resources", "base", "profile", "route_map.json"));
  if (!routeMap || typeof routeMap !== "object") return out; // not built yet
  const entries = (routeMap as Record<string, unknown>)["routerMap"];
  if (!Array.isArray(entries)) return out;
  const buildFunctions = new Set(
    entries
      .map((e) => (e && typeof e === "object" ? (e as Record<string, unknown>).buildFunction : null))
      .filter((v): v is string => typeof v === "string"),
  );
  const pageFiles = listFilesWithExt(root, "Page.ets");
  const declaredBuilders = new Set<string>();
  for (const file of pageFiles) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const m of text.matchAll(/@Builder\s+function\s+([A-Za-z0-9_]+)/g)) declaredBuilders.add(m[1]);
  }
  for (const fn of buildFunctions) {
    if (!declaredBuilders.has(fn)) {
      out.push(violation(rule, "route_map.json", 1, `buildFunction "${fn}" has no matching @Builder in a *Page.ets`));
    }
  }
  for (const builder of declaredBuilders) {
    if (!buildFunctions.has(builder)) {
      out.push(violation(rule, "route_map.json", 1, `@Builder "${builder}" has no route_map.json entry`));
    }
  }
  return out;
}

function getStringSyncScopedToI18n(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const allowedPrefix = path.join(root, "shared", "uikit", "i18n") + path.sep;
  for (const file of listFilesWithExt(root, ".ets")) {
    if (file.startsWith(allowedPrefix)) continue;
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, /\bgetStringSync\s*\(/)) {
      out.push(violation(rule, relPath(root, file), hit.line, "getStringSync used outside shared/uikit/i18n"));
    }
  }
  return out;
}

function noLazyForEach(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  for (const file of listFilesWithExt(root, ".ets")) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, /\bLazyForEach\b/)) {
      out.push(violation(rule, relPath(root, file), hit.line, "LazyForEach is banned — use Repeat"));
    }
  }
  return out;
}

function noProviderConsumer(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  for (const file of listFilesWithExt(root, ".ets")) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, /@(Provider|Consumer)\b/)) {
      out.push(violation(rule, relPath(root, file), hit.line, `"${hit.match}" decorator is banned`));
    }
  }
  return out;
}

function noRawDimensionOutsideUikit(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const uikitPrefix = path.join(root, "shared", "uikit") + path.sep;
  const pattern = /\.(padding|width|height|margin|fontSize|borderRadius)\(\s*-?\d+(\.\d+)?\s*\)/;
  for (const file of listFilesWithExt(root, ".ets")) {
    if (file.startsWith(uikitPrefix)) continue;
    const text = readIfExists(file);
    if (!text) continue;
    for (const hit of scanMatches(text, pattern)) {
      out.push(violation(rule, relPath(root, file), hit.line, `raw dimension literal "${hit.match}" outside shared/uikit`));
    }
  }
  return out;
}

function noUnusedStringKey(root: string, rule: RuleDefinition): Violation[] {
  const out: Violation[] = [];
  const stringJsonPath = path.join(root, "resources", "base", "element", "string.json");
  const stringJson = readJsonIfExists(stringJsonPath);
  const keys = jsonKeys(stringJson);
  if (keys.size === 0) return out; // resources/base/element/string.json not built yet
  const sources = [...listFilesWithExt(root, ".ets"), ...listFilesWithExt(root, ".ts")];
  const used = new Set<string>();
  for (const file of sources) {
    const text = readIfExists(file);
    if (!text) continue;
    for (const m of text.matchAll(/\$r\(\s*['"]app\.string\.([A-Za-z0-9_]+)['"]/g)) used.add(m[1]);
  }
  for (const key of keys) {
    if (!used.has(key)) {
      out.push(violation(rule, relPath(root, stringJsonPath), 1, `string key "${key}" is never referenced via $r('app.string.${key}')`));
    }
  }
  return out;
}

const CHECKS: Record<string, (root: string, rule: RuleDefinition) => Violation[]> = {
  noRawHexColor,
  noStylesExtendInUikit,
  noLiteralDisplayText,
  errorCodeMappingComplete,
  everyBaseKeyTranslated,
  routeMapMatchesPages,
  getStringSyncScopedToI18n,
  noLazyForEach,
  noProviderConsumer,
  noRawDimensionOutsideUikit,
  noUnusedStringKey,
};

/** Runs every rule in `rules` against `root`, in table order. */
export function runChecks(root: string, rules: RuleDefinition[]): Violation[] {
  const out: Violation[] = [];
  for (const rule of rules) {
    const check = CHECKS[rule.checkId];
    if (!check) continue;
    out.push(...check(root, rule));
  }
  return out;
}
