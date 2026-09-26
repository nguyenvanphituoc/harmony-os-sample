#!/usr/bin/env bash
# Launch probe — the built HAP must install on a reachable target, start, stay up, and render a
# UI tree the evaluator can grade.
#
# WHY THIS IS A SCRIPT AND NOT AN INLINE PROBE. Same reason as the T0 fixtures: the assertion
# needs command substitution and greps over captured output, which an agent's Bash tool refuses
# before any permission rule is consulted. Inside a script the whole chain becomes one invocation
# a permission rule can name.
#
# WHY IT DUMPS THE UI TREE. Spec criteria tagged [ui] are graded "NO EVIDENCE on running app"
# whenever the evaluator cannot observe the app. `uitest dumpLayout` returns the live component
# tree with each node's type and text, which is exactly that evidence — machine-readable, and
# produced by the SDK's own tooling rather than by a screenshot someone has to eyeball.
#
# Exit codes follow the T0 convention: 0 pass, 1 fail, 2 the probe could not run (not a failing
# app — a different finding, and the run should say so rather than blame the feature).
set -uo pipefail

BUNDLE="${BUNDLE:-com.example.myapplication}"
ABILITY="${ABILITY:-EntryAbility}"
MODULE="${MODULE:-entry}"
HDC="${HDC:-/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/toolchains/hdc}"
HAP="${HAP:-app/entry/build/default/outputs/default/entry-default-unsigned.hap}"
OUT="${OUT:-.shapeup/launch-probe}"

[ -x "$HDC" ] || { echo "LAUNCH-PROBE-CANNOT-RUN: hdc not executable at $HDC" >&2; exit 2; }
[ -f "$HAP" ] || { echo "LAUNCH-PROBE-CANNOT-RUN: no HAP at $HAP — run the build probe first" >&2; exit 2; }
# A HAP OLDER THAN THE SOURCE IS NOT THIS BUILD. When the build fails, the previous HAP is still on
# disk, and installing it launches whatever last built — a green launch over a red build. Any source
# file newer than the HAP means the artifact does not describe the tree, so the probe cannot run.
newer=$(find app/entry/src/main app/AppScope -type f -newer "$HAP" 2>/dev/null | head -1)
if [ -n "$newer" ]; then
  echo "LAUNCH-PROBE-CANNOT-RUN: $HAP is older than the source ($newer) — build it first; a stale HAP launches the last build, not this one" >&2
  exit 2
fi

target=$("$HDC" list targets 2>/dev/null | head -1 | tr -d '\r')
case "$target" in
  ""|"[Empty]"|*"Empty"*)
    echo "LAUNCH-PROBE-CANNOT-RUN: no target attached (hdc list targets → '${target:-<none>}')" >&2
    echo "  boot one: /Applications/DevEco-Studio.app/Contents/tools/emulator/Emulator -hvd <name>" >&2
    exit 2 ;;
esac
echo "target: $target"
T="-t $target"

# Crash evidence is only meaningful against a before-picture: faultlogger keeps old logs from
# other bundles and other days, so count ours before we start rather than after.
before=$("$HDC" $T shell "ls /data/log/faultlog/faultlogger 2>/dev/null | grep -c $BUNDLE" 2>/dev/null | tr -dc '0-9')
before=${before:-0}

out=$("$HDC" $T install -r "$HAP" 2>&1)
echo "$out" | tail -2
echo "$out" | grep -q 'install bundle successfully' || { echo "FAIL: install rejected" >&2; exit 1; }

"$HDC" $T shell "aa force-stop $BUNDLE" >/dev/null 2>&1
out=$("$HDC" $T shell "aa start -a $ABILITY -b $BUNDLE -m $MODULE" 2>&1)
echo "$out" | head -2
echo "$out" | grep -q 'start ability successfully' || { echo "FAIL: ability did not start" >&2; exit 1; }

pid=$("$HDC" $T shell "pidof $BUNDLE" 2>/dev/null | tr -dc '0-9')
[ -n "$pid" ] || { echo "FAIL: no process after start — the app died on launch" >&2; exit 1; }
echo "pid: $pid"

after=$("$HDC" $T shell "ls /data/log/faultlog/faultlogger 2>/dev/null | grep -c $BUNDLE" 2>/dev/null | tr -dc '0-9')
after=${after:-0}
[ "$after" -le "$before" ] || { echo "FAIL: $((after-before)) new faultlog(s) for $BUNDLE" >&2; exit 1; }

mkdir -p "$OUT"
"$HDC" $T shell "uitest dumpLayout -p /data/local/tmp/layout.json -b $BUNDLE" >/dev/null 2>&1
"$HDC" $T file recv /data/local/tmp/layout.json "$OUT/layout.json" >/dev/null 2>&1
"$HDC" $T shell "uitest screenCap -p /data/local/tmp/screen.png" >/dev/null 2>&1
"$HDC" $T file recv /data/local/tmp/screen.png "$OUT/screen.png" >/dev/null 2>&1

# The tree is the evidence; this flattening is what makes it readable in a probe log. A UI that
# renders nothing is a failure the process check cannot see — an app can stay up showing a blank
# page — so an empty tree is red here, not merely quiet.
if [ -f "$OUT/layout.json" ]; then
  python3 - "$OUT/layout.json" <<'PY'
import json, sys
seen = []
def walk(n):
    a = n.get('attributes', {})
    t = (a.get('text') or '').strip()
    if t:
        seen.append((a.get('type', '?'), t))
    for c in n.get('children', []):
        walk(c)
walk(json.load(open(sys.argv[1])))
print(f"ui nodes with text: {len(seen)}")
for typ, txt in seen:
    print(f"  [{typ}] {txt}")
PY
  nodes=$(python3 -c "
import json,sys
n=0
def w(x):
    global n
    if (x.get('attributes',{}).get('text') or '').strip(): n+=1
    for c in x.get('children',[]): w(c)
w(json.load(open('$OUT/layout.json'))); print(n)" 2>/dev/null)
  [ "${nodes:-0}" -gt 0 ] || { echo "FAIL: app is up but its UI tree has no text — blank render" >&2; exit 1; }
  echo "artifacts: $OUT/layout.json, $OUT/screen.png"
else
  echo "WARN: no layout dumped — [ui] criteria stay unevidenced" >&2
fi
