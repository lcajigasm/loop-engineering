#!/bin/sh
# stop-verify.sh — generic Stop-hook gate for Claude Code and Codex CLI.
#
# Wired as a Stop hook in .claude/settings.json or .codex/hooks.json. Blocks
# ending a session while the active loop's gate is red —
# the technical enforcement of rule #1 ("nothing simulated"): the agent
# memory file is context, not enforcement; this is what actually stops a
# session from being declared done while the verify still fails.
#
# The active gate is read from `.le-active-verify` at the repo root (line 1:
# the verify command; line 2: the goal id). The `goal`/`auto` commands write
# it when a loop starts and delete it when the loop closes. No file, nothing
# to enforce.
#
# Safety valve: after MAX_BLOCKS consecutive blocks in one session the hook
# lets the session end anyway (marking the state clearly) — a permanently
# red gate needs the `stuck` protocol, not an unclosable terminal.
# Hook contract: exit 2 blocks/continues the turn and feeds stderr back to the
# agent; stdin is JSON with session_id.
set -eu
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

MARKER=".le-active-verify"
MAX_BLOCKS=3

[ -f "$MARKER" ] || exit 0
VERIFY=$(head -n 1 "$MARKER")
[ -z "$VERIFY" ] && exit 0

# session_id from the hook's stdin JSON (no jq dependency).
session=$(sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' 2>/dev/null | head -n 1 || true)
counter="${TMPDIR:-/tmp}/le-stop-blocks-${session:-nosession}"

log=$(mktemp "${TMPDIR:-/tmp}/le-stop-verify.XXXXXX")
if sh -c "$VERIFY" >"$log" 2>&1; then
  rm -f "$log" "$counter"
  exit 0
fi

blocks=$(cat "$counter" 2>/dev/null || echo 0)
blocks=$((blocks + 1))
echo "$blocks" > "$counter"

if [ "$blocks" -ge "$MAX_BLOCKS" ]; then
  echo "Gate still red after $MAX_BLOCKS blocked stops: \`$VERIFY\`. Letting the session end — this loop is stuck. Update the receipt with Result: stuck and run the stuck protocol. Log: $log" >&2
  rm -f "$counter"
  exit 0
fi

echo "The active loop's gate is still red: \`$VERIFY\` (see $log). Fix the real cause before treating this goal as done, or record the loop as stuck in its receipt and delete $MARKER." >&2
exit 2
