---
description: Verify all milestone receipts passed, run the full project gate, update STATUS.md, draft release notes, propose the tag.
argument-hint: <id>
---
Run the loop-engineering `close-milestone` command.

Follow the canonical spec's `close-milestone` section exactly. The spec is
`core/COMMANDS.md` inside the loop-engineering skill directory — read it
from the first of these that exists:

1. `${CLAUDE_PLUGIN_ROOT}/skills/loop-engineering/core/COMMANDS.md` (plugin install)
2. `.claude/skills/loop-engineering/core/COMMANDS.md` (project install)
3. `~/.claude/skills/loop-engineering/core/COMMANDS.md` (global install)

Methodology and templates live next to it. Converse in the user's language;
write files in English.

Arguments: $ARGUMENTS
