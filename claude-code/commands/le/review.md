---
description: Produce a read-only review packet for a goal: plan, diff, verification evidence, risks and open questions.
argument-hint: <goal-id>
---
Run the loop-engineering `review` command.

Follow the canonical spec's `review` section exactly. The spec is
`core/COMMANDS.md` inside the loop-engineering skill directory — read it
from the first of these that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/loop-engineering/core/COMMANDS.md` (plugin install)
2. `.claude/skills/loop-engineering/core/COMMANDS.md` (project install)
3. `~/.claude/skills/loop-engineering/core/COMMANDS.md` (global install)

Methodology and templates live next to it. Converse in the user's language;
write files in English.

Arguments: $ARGUMENTS
