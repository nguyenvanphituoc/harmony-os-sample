#!/usr/bin/env bash
# Device fixture — drive the running app through declared flows and assert what the screen shows.
#
# WHY FLOWS FROM OUTSIDE THE APP. `entry` is an ArkUI-X cross-platform module, and the build rejects
# the platform test APIs an in-app UI test would need (UiTest's Driver, abilityDelegatorRegistry —
# error 11706007). So a device-tier Test Surface row cannot be an ohosTest case here. It can be a flow
# driven from outside, through the SDK's own `hdc shell uitest`: read the live component tree, find a
# node by id or text, press its centre, read the tree again. That is what a person would do, written
# down so it runs the same way every time, in every round, without depending on the judge to do it.
#
# A flow file is one Test Surface row, named after it: `<dir>/TS-05-05.flow`. One step per line:
#   launch                      force-stop and start the ability (a clean cold start)
#   tap text "Groceries"        press the first visible node whose text is exactly this
#   tap id "lists.card.open" 2  press the Nth node (1-based) with this id
#   doubletap text "Bread"      two clicks on the same node back-to-back (no settle between),
#                               then one trailing settle() — same targeting as tap (kind, value, nth)
#   type id "listname.field" "Trips"   focus the node and type
#   swipe id "list.items" up    swipe across the resolved node's bounds, bottom toward top
#   swipe id "list.items" down  swipe across the resolved node's bounds, top toward bottom
#   back                        the system back key
#   wait 500                    milliseconds
#   expect text "Bread"         a node with this text is on screen
#   expect no text "Bread"      no node with this text is on screen
#   expect count id "lists.card" 3
#   expect order text "Bread" "Buy milk"   the first is drawn above the second
# Blank lines and lines starting with # are ignored.
#
# Output: one line per flow — `PASS TS-05-05` or `FAIL TS-05-05 step 4: <why>` — then a summary.
# Exit 0 all pass · 1 any flow failed, or no flows written yet · 2 could not run (no device, no HAP,
# stale HAP).
set -uo pipefail

HDC="${HDC:-/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc}"
BUNDLE="${BUNDLE:-com.example.myapplication}"
ABILITY="${ABILITY:-EntryAbility}"
MODULE="${MODULE:-entry}"
HAP="${HAP:-app/entry/build/default/outputs/default/entry-default-unsigned.hap}"

[ "$#" -ge 1 ] || { echo "usage: ui-flow.sh <flow-file-or-dir>..." >&2; exit 2; }
# Flows first: whether any exist does not depend on the device, and none written is the scope's work
# not done yet — a named failure the next attempt receives — never a could-not-run it never hears of.
found=0
for p in "$@"; do
  if [ -d "$p" ]; then ls "$p"/*.flow >/dev/null 2>&1 && found=1; elif [ -f "$p" ] && [ "${p%.flow}" != "$p" ]; then found=1; fi
done
if [ "$found" -eq 0 ]; then
  for p in "$@"; do
    echo "FAIL ${p%/} no .flow files — write one flow per device-tier Test Surface row of this scope as ${p%/}/<TS-id>.flow (steps documented at the top of scripts/ui-flow.sh)"
  done
  echo "ui-flow: 0/0 flows — none written"
  exit 1
fi
[ -x "$HDC" ] || { echo "UI-FLOW-CANNOT-RUN: hdc not executable at $HDC" >&2; exit 2; }
[ -f "$HAP" ] || { echo "UI-FLOW-CANNOT-RUN: no HAP at $HAP — build first" >&2; exit 2; }
newer=$(find app/entry/src/main app/AppScope -type f -newer "$HAP" 2>/dev/null | head -1)
[ -z "$newer" ] || { echo "UI-FLOW-CANNOT-RUN: $HAP is older than the source ($newer) — build first" >&2; exit 2; }
target=$("$HDC" list targets 2>/dev/null | head -1 | tr -d '\r')
case "$target" in ""|*Empty*) echo "UI-FLOW-CANNOT-RUN: no target attached" >&2; exit 2 ;; esac

# The installed app must be this build, or every flow asserts against an older one.
"$HDC" -t "$target" install -r "$HAP" 2>&1 | grep -q 'install bundle successfully' \
  || { echo "UI-FLOW-CANNOT-RUN: install of $HAP was rejected" >&2; exit 2; }

exec python3 - "$HDC" "$target" "$BUNDLE" "$ABILITY" "$MODULE" "$@" <<'PY'
import json, os, re, shlex, subprocess, sys, tempfile, time

hdc, target, bundle, ability, module, *paths = sys.argv[1:]

def sh(cmd, timeout=30):
    r = subprocess.run([hdc, "-t", target, "shell", cmd], capture_output=True, text=True, timeout=timeout)
    return (r.stdout or "") + (r.stderr or "")

def tree():
    remote = "/data/local/tmp/uiflow.json"
    sh(f"uitest dumpLayout -p {remote} -b {bundle}")
    local = tempfile.mktemp(suffix=".json")
    subprocess.run([hdc, "-t", target, "file", "recv", remote, local], capture_output=True, text=True, timeout=30)
    try:
        with open(local) as f: return json.load(f)
    except Exception:
        return {}
    finally:
        try: os.unlink(local)
        except OSError: pass

def nodes(t):
    out = []
    def walk(n):
        a = n.get("attributes", {})
        m = re.match(r"\[(-?\d+),(-?\d+)\]\[(-?\d+),(-?\d+)\]", a.get("bounds", ""))
        if m:
            x1, y1, x2, y2 = map(int, m.groups())
            if x2 > x1 and y2 > y1 and a.get("visible", "true") != "false":
                out.append({"id": a.get("id", ""), "text": a.get("text", ""), "x": (x1 + x2) // 2, "y": (y1 + y2) // 2, "top": y1, "bottom": y2})
        for c in n.get("children", []): walk(c)
    walk(t)
    return out

def find(ns, kind, value):
    return [n for n in ns if n[kind] == value]

def settle():
    time.sleep(0.8)

def run(path):
    name = os.path.splitext(os.path.basename(path))[0]
    lines = [l.strip() for l in open(path, encoding="utf-8")]
    for i, line in enumerate(lines, 1):
        if not line or line.startswith("#"): continue
        try:
            w = shlex.split(line)
        except ValueError as e:
            return f"FAIL {name} step {i}: unreadable step ({e})"
        op = w[0]
        if op == "launch":
            sh(f"aa force-stop {bundle}"); sh(f"aa start -a {ability} -b {bundle} -m {module}"); time.sleep(2.0); continue
        if op == "wait":
            time.sleep(int(w[1]) / 1000); continue
        if op == "back":
            sh("uitest uiInput keyEvent Back"); settle(); continue
        ns = nodes(tree())
        if op in ("tap", "type", "doubletap"):
            kind, value = w[1], w[2]
            nth = int(w[3]) if op in ("tap", "doubletap") and len(w) > 3 else 1
            hits = find(ns, kind, value)
            if len(hits) < nth:
                return f"FAIL {name} step {i}: no {kind} {value!r} to {op} (found {len(hits)})"
            n = hits[nth - 1]
            if op == "doubletap":
                sh(f"uitest uiInput click {n['x']} {n['y']}")
                sh(f"uitest uiInput click {n['x']} {n['y']}")
                settle()
                continue
            sh(f"uitest uiInput click {n['x']} {n['y']}"); settle()
            if op == "type":
                sh(f"uitest uiInput inputText {n['x']} {n['y']} {shlex.quote(w[3])}"); settle()
            continue
        if op == "swipe":
            kind, value, direction = w[1], w[2], w[3]
            hits = find(ns, kind, value)
            if not hits:
                return f"FAIL {name} step {i}: no {kind} {value!r} to swipe (found 0)"
            n = hits[0]
            x1 = x2 = n["x"]
            y1, y2 = (n["bottom"], n["top"]) if direction == "up" else (n["top"], n["bottom"])
            sh(f"uitest uiInput swipe {x1} {y1} {x2} {y2}"); settle()
            continue
        if op == "expect":
            if w[1] == "no":
                if find(ns, w[2], w[3]): return f"FAIL {name} step {i}: {w[2]} {w[3]!r} is on screen"
            elif w[1] == "count":
                got = len(find(ns, w[2], w[3]))
                if got != int(w[4]): return f"FAIL {name} step {i}: {got} × {w[2]} {w[3]!r}, expected {w[4]}"
            elif w[1] == "order":
                a, b = find(ns, w[2], w[3]), find(ns, w[2], w[4])
                if not a or not b: return f"FAIL {name} step {i}: cannot order — {w[3]!r} {'found' if a else 'missing'}, {w[4]!r} {'found' if b else 'missing'}"
                if not a[0]["top"] < b[0]["top"]: return f"FAIL {name} step {i}: {w[3]!r} is not above {w[4]!r}"
            else:
                if not find(ns, w[1], w[2]):
                    seen = sorted({n["text"] for n in ns if n["text"]})[:12]
                    return f"FAIL {name} step {i}: no {w[1]} {w[2]!r} on screen (visible text: {seen})"
            continue
        return f"FAIL {name} step {i}: unknown step {op!r}"
    return f"PASS {name}"

files = []
for p in paths:
    if os.path.isdir(p): files += sorted(os.path.join(p, f) for f in os.listdir(p) if f.endswith(".flow"))
    elif p.endswith(".flow") and os.path.isfile(p): files.append(p)
if not files:
    # No flows is not an environment the scope cannot fix — it is the scope's work not done yet, so it
    # is a named failure the next attempt receives, not a could-not-run it never hears about.
    for p in paths:
        print(f"FAIL {p} no .flow files — write one flow per device-tier Test Surface row of this scope as {p.rstrip('/')}/<TS-id>.flow (steps documented at the top of scripts/ui-flow.sh)")
    print("ui-flow: 0/0 flows — none written"); sys.exit(1)
results = [run(f) for f in files]
for r in results: print(r)
failed = sum(r.startswith("FAIL") for r in results)
print(f"ui-flow: {len(results) - failed}/{len(results)} flows passed")
sys.exit(1 if failed else 0)
PY
