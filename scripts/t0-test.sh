#!/usr/bin/env bash
# T0 fixture — the feature's ArkTS build unit-test tier must pass, with no ERROR: line and no 'Failure: N'.
#
# WHY THIS IS A SCRIPT AND NOT AN INLINE FIXTURE. The assertion needs three things a T0 fixture
# cannot express inline in an agent session: a subshell (hvigor resolves its project from the
# working directory and there is no --project-dir flag), a command substitution to capture the
# output, and a grep over that output. An agent's Bash tool refuses a command carrying a subshell
# or a $(...) capture — it cannot be analysed statically — and that refusal happens before any
# permission rule is consulted, so no grant reaches it. The harness then records the refusal
# exactly as it records a failing build: exit 1, 0/2, and an empty diagnostic digest.
#
# Inside a script those constructs run in a real shell, and the fixture becomes one invocation a
# permission rule can name. The assertion is unchanged — in particular the ERROR: grep stays,
# because hvigor can exit 0 while printing errors, so an exit-code-only check would trade a
# refusal for a false green.
set -uo pipefail

export DEVECO_SDK_HOME="${DEVECO_SDK_HOME:-/Applications/DevEco-Studio.app/Contents/sdk}"
HVIGORW="${HVIGORW:-/Applications/DevEco-Studio.app/Contents/tools/hvigor/bin/hvigorw}"

if [ ! -x "$HVIGORW" ]; then
  echo "T0-FIXTURE-CANNOT-RUN: hvigorw not executable at $HVIGORW" >&2
  exit 2   # not a failing build: the probe could not run, which is a different finding
fi

out=$( ( cd app && "$HVIGORW" test -p module=entry -p coverage=false --no-daemon ) 2>&1 )
rc=$?
echo "$out" | tail -30
[ "$rc" -eq 0 ] && ! echo "$out" | grep -q 'ERROR:' && ! echo "$out" | grep -qE 'Failure: [1-9]'
