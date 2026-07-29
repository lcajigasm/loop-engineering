#!/bin/sh
# watch-verify.sh — bounded local revalidation after commits touching a scope.
#
# Usage:
#   watch-verify.sh --scope <path> --verify <command> --minutes <n> \
#     [--interval <seconds>] [--log <path>]
#
# It never edits code, fetches, pushes, or starts an agent. It runs VERIFY
# only after a new local commit changes SCOPE, then stops at the time budget
# or after three identical failed outputs.
set -eu

usage() {
  echo "Usage: watch-verify.sh --scope <path> --verify <command> --minutes <n> [--interval <seconds>] [--log <path>]" >&2
  exit 1
}

SCOPE="" VERIFY="" MINUTES="" INTERVAL=30 LOG=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scope) SCOPE="$2"; shift 2 ;;
    --verify) VERIFY="$2"; shift 2 ;;
    --minutes) MINUTES="$2"; shift 2 ;;
    --interval) INTERVAL="$2"; shift 2 ;;
    --log) LOG="$2"; shift 2 ;;
    *) usage ;;
  esac
done
[ -n "$SCOPE" ] && [ -n "$VERIFY" ] && [ -n "$MINUTES" ] || usage
case "$MINUTES" in *[!0-9]*|'') usage ;; esac
case "$INTERVAL" in *[!0-9]*|'') usage ;; esac
[ "$MINUTES" -gt 0 ] && [ "$INTERVAL" -gt 0 ] || usage

cd "$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "watch-verify.sh requires a git worktree" >&2; exit 1;
}
[ -n "$LOG" ] || LOG="docs/receipts/watch-$(date -u +%Y%m%dT%H%M%SZ).log"
mkdir -p "$(dirname "$LOG")"

started=$(date +%s)
deadline=$((started + MINUTES * 60))
last_commit=$(git rev-parse HEAD)
last_failure=""
identical_failures=0
printf 'watch started=%s scope=%s verify=%s base=%s\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$SCOPE" "$VERIFY" "$last_commit" >> "$LOG"

while [ "$(date +%s)" -lt "$deadline" ]; do
  current=$(git rev-parse HEAD)
  if [ "$current" != "$last_commit" ]; then
    changed=$(git diff --name-only "$last_commit" "$current")
    if printf '%s\n' "$changed" | awk -v scope="$SCOPE" \
      'scope == "." || $0 == scope || index($0, scope "/") == 1 { found=1 } END { exit !found }'
    then
      timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      if output=$(sh -c "$VERIFY" 2>&1); then
        printf '%s commit=%s result=passed command=%s\n%s\n' \
          "$timestamp" "$current" "$VERIFY" "$output" >> "$LOG"
        last_failure=""; identical_failures=0
      else
        failure=$(printf '%s' "$output" | cksum | awk '{print $1 ":" $2}')
        if [ "$failure" = "$last_failure" ]; then
          identical_failures=$((identical_failures + 1))
        else
          identical_failures=1
        fi
        last_failure="$failure"
        printf '%s commit=%s result=failed identical=%s command=%s\n%s\n' \
          "$timestamp" "$current" "$identical_failures" "$VERIFY" "$output" >> "$LOG"
        if [ "$identical_failures" -ge 3 ]; then
          echo "Stopped after three identical failures; evidence: $LOG" >&2
          exit 2
        fi
      fi
    fi
    last_commit="$current"
  fi
  sleep "$INTERVAL"
done

echo "Watch budget exhausted; evidence: $LOG"
