#!/bin/sh
# verify-loop.sh — generic act -> verify -> re-prompt loop runner.
#
# Repeats a headless `claude -p` turn against a fixed verify command until it
# passes, gets stuck (same failure N times in a row), or hits the iteration
# ceiling. Stack-agnostic: the verify command IS the contract.
#
# Usage:
#   verify-loop.sh --goal "<description>" --verify "<command>" \
#     [--max N] [--stuck N] [--receipt <path>] [--allowed-tools <tools>]
#
# Example (adapt --verify to your stack; `start` writes a project copy with
# your real gates):
#   ./scripts/verify-loop.sh \
#     --goal "all parser unit tests pass" \
#     --verify "npx tsc --noEmit && npx vitest run src/parser" \
#     --max 10 --receipt docs/receipts/G-101-parser.md
#
# Claude Code flags verified against CLI 2.1.212 (2026-07). They change
# between versions — if this breaks after an upgrade, re-check
# `claude --help` for -p / --output-format json / --resume / --allowedTools.
# Requires `jq` for session-id extraction.
set -eu

usage() {
  echo "Usage: verify-loop.sh --goal \"<description>\" --verify \"<command>\" [--max N] [--stuck N] [--receipt <path>] [--allowed-tools <tools>]" >&2
  exit 1
}

GOAL="" VERIFY="" MAX=10 STUCK=3 RECEIPT=""
ALLOWED_TOOLS="Read,Edit,Write,Bash"
while [ $# -gt 0 ]; do
  case "$1" in
    --goal) GOAL="$2"; shift 2 ;;
    --verify) VERIFY="$2"; shift 2 ;;
    --max) MAX="$2"; shift 2 ;;
    --stuck) STUCK="$2"; shift 2 ;;
    --receipt) RECEIPT="$2"; shift 2 ;;
    --allowed-tools) ALLOWED_TOOLS="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[ -z "$GOAL" ] && usage
[ -z "$VERIFY" ] && usage

write_receipt() {
  # Loop-runner fields only; complete the narrative with the `receipt`
  # command afterwards.
  result="$1"; iters="$2"
  [ -z "$RECEIPT" ] && return 0
  mkdir -p "$(dirname "$RECEIPT")"
  cat > "$RECEIPT" <<EOF
# Receipt: $(basename "$RECEIPT" .md)

- Goal: $GOAL
- Verify: \`$VERIFY\`
- Iterations: $iters / $MAX
- Result: $result
- Closed: $(date -u +%Y-%m-%dT%H:%MZ)
- Notes: written by verify-loop.sh — complete with the \`receipt\` command.
EOF
}

iter=0
session=""
last_output=""
identical_count=0

while [ "$iter" -lt "$MAX" ]; do
  iter=$((iter + 1))
  echo "== iteration $iter/$MAX =="

  if output=$(eval "$VERIFY" 2>&1); then
    echo "Gate green at iteration $iter."
    write_receipt "passed" "$iter"
    exit 0
  fi

  # Stuck: the same failure N times in a row means the loop isn't learning
  # from feedback — it needs a human (run `stuck <goal-id>`), not more
  # iterations burning budget.
  if [ "$output" = "$last_output" ]; then
    identical_count=$((identical_count + 1))
  else
    identical_count=0
  fi
  last_output="$output"
  if [ "$identical_count" -ge $((STUCK - 1)) ]; then
    echo "Same failure $STUCK times in a row. Stopping."
    write_receipt "stuck" "$iter"
    exit 2
  fi

  prompt="Goal: $GOAL
The verify gate failed. Fix the real cause, not the check — never weaken a
test or skip an assertion to go green.
Verify command: $VERIFY
Output:
$output"

  if [ -z "$session" ]; then
    session=$(claude -p "$prompt" \
      --allowedTools "$ALLOWED_TOOLS" \
      --output-format json | jq -r '.session_id')
  else
    claude -p "$prompt" \
      --allowedTools "$ALLOWED_TOOLS" \
      --resume "$session" >/dev/null
  fi
done

echo "Iteration ceiling ($MAX) reached without a green gate."
write_receipt "budget-exhausted" "$iter"
exit 1
