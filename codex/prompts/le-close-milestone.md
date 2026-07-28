---
description: Verify all milestone receipts passed, run the full project gate, update STATUS.md, draft release notes, propose the tag.
argument-hint: <id>
---
Run the loop-engineering `close-milestone` command.

Follow the canonical spec's `close-milestone` section exactly, including the Codex
capability notes (optional Stop hook; re-run VERIFY yourself in a fresh invocation
before declaring any goal done): read
`~/.agents/skills/loop-engineering/core/COMMANDS.md` (or, if this project has
its own copy, `.agents/skills/loop-engineering/core/COMMANDS.md`).
Methodology and templates live next to it. Converse in the user's language;
write files in English.

Arguments: $ARGUMENTS
