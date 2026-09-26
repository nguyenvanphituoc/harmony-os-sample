// The enforce entry point both hvigorfile.ts files call. Runs every §5 rule (docs/ui-layer.md
// §5) from the single `RULE_TABLE`, prints one line per hit, and — for error-severity rules
// only — throws, which fails the hvigor process (and therefore `assembleHap`) the same way any
// other hvigorfile-evaluation error does, citing the rule and the offending file:line.
// Warning-severity rules only print; they never fail the build.
//
// Runs at hvigorfile module-evaluation time, i.e. on every hvigor invocation (any target),
// alongside — never instead of — the ArkUI-X plugin's own exported tasks: this module changes
// nothing about `AppTasksForArkUIX` / `HapTasks`, it only runs before hvigor hands control to
// them.

import { RULE_TABLE } from "./rule-table";
import { runChecks, Violation } from "./scan";

function formatViolation(v: Violation): string {
  return `${v.severity === "error" ? "ERROR" : "WARNING"}: [${v.rule.id}] ${v.file}:${v.line} ${v.message}`;
}

/**
 * Runs the full L1-L11 rule table against `projectRoot` (the `app/` directory — the parent of
 * both `hvigorfile.ts` and `entry/`). Throws on the first evaluation if any error-severity
 * violation is found; always prints every warning-severity hit.
 */
export function runEnforce(projectRoot: string): void {
  const violations = runChecks(projectRoot, RULE_TABLE);
  const errors = violations.filter((v) => v.severity === "error");
  const warnings = violations.filter((v) => v.severity === "warning");

  for (const w of warnings) {
    console.warn(formatViolation(w));
  }
  if (errors.length > 0) {
    for (const e of errors) {
      console.error(formatViolation(e));
    }
    throw new Error(
      `enforce: ${errors.length} error-level §5 rule violation(s) — see ERROR lines above ` +
        `(first: [${errors[0].rule.id}] ${errors[0].file}:${errors[0].line})`,
    );
  }
}
