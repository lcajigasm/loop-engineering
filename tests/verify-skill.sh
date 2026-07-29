#!/bin/sh
# Minimal contract check for the shared core and both install adapters.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMMANDS='start plan auto goal verify status receipt stuck close-milestone memory parallel watch review help'

for script in "$ROOT"/install.sh "$ROOT"/core/scripts/*.sh; do
  sh -n "$script"
done

for command in $COMMANDS; do
  rg -q "^## ${command}( |$)" "$ROOT/core/COMMANDS.md"
  test -f "$ROOT/claude-code/commands/le/$command.md"
  test -f "$ROOT/codex/prompts/le-$command.md"
done

for template in PLAN.template.md INTEGRATION.template.md CAPABILITIES.template.md RECEIPT.template.md STATUS.template.md; do
  test -f "$ROOT/core/templates/$template"
done

rg -q 'watch-verify\.sh' "$ROOT/core/COMMANDS.md"
rg -q 'Scope check:' "$ROOT/core/templates/RECEIPT.template.md"
rg -q 'Revalidation required' "$ROOT/core/templates/STATUS.template.md"
rg -q 'docs/plans/' "$ROOT/claude-code/skills/loop-engineering/SKILL.md"
rg -q 'docs/plans/' "$ROOT/codex/skills/loop-engineering/SKILL.md"

TEST_PROJECT=$(mktemp -d "${TMPDIR:-/tmp}/loop-engineering-test.XXXXXX")
trap 'rm -rf "$TEST_PROJECT"' EXIT HUP INT TERM
"$ROOT/install.sh" --all --project "$TEST_PROJECT" >/dev/null

for command in $COMMANDS; do
  test -f "$TEST_PROJECT/.claude/commands/le/$command.md"
done
test -f "$TEST_PROJECT/.claude/skills/loop-engineering/core/scripts/watch-verify.sh"
test -x "$TEST_PROJECT/.claude/skills/loop-engineering/core/scripts/watch-verify.sh"
test -f "$TEST_PROJECT/.agents/skills/loop-engineering/core/templates/PLAN.template.md"
test -f "$TEST_PROJECT/.agents/skills/loop-engineering/core/templates/INTEGRATION.template.md"
test -f "$TEST_PROJECT/.agents/skills/loop-engineering/core/templates/CAPABILITIES.template.md"

echo "loop-engineering contract: ok"
