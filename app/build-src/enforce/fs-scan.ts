// Plain Node.js file-walking helpers for the enforce task. This file runs inside hvigor's
// Node.js process while hvigorfile.ts is evaluated — never on-device — so plain `fs`/`path`
// (not ArkTS) is correct here.

import * as fs from "fs";
import * as path from "path";

/** Named (non-dot) directories every scan skips — build output, package stores. */
const SKIP_DIRS = new Set(["node_modules", "oh_modules", "build"]);

/**
 * Recursively lists every file under `root` whose name ends with `ext`, skipping build/VCS
 * directories. Missing `root` yields an empty list rather than throwing — most feature
 * directories this rule table scans do not exist yet in early scopes.
 */
export function listFilesWithExt(root: string, ext: string): string[] {
  const out: string[] = [];
  walk(root, ext, out);
  return out;
}

function walk(dir: string, ext: string, out: string[]): void {
  let entries: fs.Dirent[];
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return;
  }
  for (const entry of entries) {
    if (entry.isDirectory()) {
      // Dot-directories (.git, .hvigor, .idea, .arkui-x, .test, .preview, ...) are tooling or
      // IDE-generated scaffolding, never app source owned by a scope — skip all of them.
      if (entry.name.startsWith(".") || SKIP_DIRS.has(entry.name)) continue;
      walk(path.join(dir, entry.name), ext, out);
    } else if (entry.isFile() && entry.name.endsWith(ext)) {
      out.push(path.join(dir, entry.name));
    }
  }
}

/** Reads a file as UTF-8, or `null` if it does not exist. */
export function readIfExists(filePath: string): string | null {
  try {
    return fs.readFileSync(filePath, "utf-8");
  } catch {
    return null;
  }
}

/** Parses a JSON file, or `null` if it is missing or not valid JSON. */
export function readJsonIfExists(filePath: string): unknown | null {
  const text = readIfExists(filePath);
  if (text === null) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

/** 1-based line number of `index` within `text`. */
export function lineAt(text: string, index: number): number {
  let line = 1;
  for (let i = 0; i < index && i < text.length; i++) {
    if (text[i] === "\n") line++;
  }
  return line;
}

/** Every non-overlapping match of `pattern` (must carry the `g` flag) in `text`, with lines. */
export function scanMatches(
  text: string,
  pattern: RegExp,
): Array<{ line: number; match: string }> {
  const results: Array<{ line: number; match: string }> = [];
  const re = new RegExp(pattern.source, pattern.flags.includes("g") ? pattern.flags : pattern.flags + "g");
  let m: RegExpExecArray | null;
  while ((m = re.exec(text)) !== null) {
    results.push({ line: lineAt(text, m.index), match: m[0] });
    if (m[0].length === 0) re.lastIndex++;
  }
  return results;
}
