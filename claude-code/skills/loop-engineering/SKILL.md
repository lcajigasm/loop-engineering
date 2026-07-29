---
name: loop-engineering
description: Drive a project as verified loops (goal → action → feedback → stop). Use when the user wants to loop until tests pass, keep going until the build is green, resume the project, ask where we left off, set up loop engineering, plan a project as loops, run/verify/diagnose/review/watch a goal, inspect parallel work, or close a milestone. Detects initialized projects by docs/GOALS.md.
---

# Loop Engineering

Methodology, canonical command spec and templates live in this skill's
`core/` directory — load them on demand, don't guess:

- `${CLAUDE_SKILL_DIR}/core/METHODOLOGY.md` — the method: loop anatomy,
  verification principles, memory layers, stuck protocol, orchestration.
- `${CLAUDE_SKILL_DIR}/core/COMMANDS.md` — exact behavior of every command.
- `${CLAUDE_SKILL_DIR}/core/templates/` and `core/scripts/` — files `start`
  generates into projects.

Converse in the user's language; every file you create is in English.

## Detect project state first

`docs/GOALS.md` with a `# Goals —` header ⇒ initialized project: read it
plus relevant `docs/plans/` and `docs/receipts/` before proposing anything. No `docs/GOALS.md` ⇒ not
initialized: the only sensible entry points are `start` (or `help`).

## Route natural language to commands

| User says something like | Command (spec in core/COMMANDS.md) |
|---|---|
| "set up loop engineering", "plan this project as loops" | `start` |
| "the scope changed", "re-plan the goals" | `plan` |
| "resume the project", "where did we leave off", "continue" | `auto` (or `status` if they only want to look) |
| "loop until tests pass", "keep going until the build is green" | `goal` (ad-hoc, six fields declared first) |
| "just run the checks", "does it pass?" | `verify` |
| "how are we doing" | `status` |
| "log that run", "write the receipt" | `receipt` |
| "it keeps failing", "the loop is stuck" | `stuck` |
| "ship it", "close this phase/milestone" | `close-milestone` |
| "remember this", "stop making that mistake" | `memory` |
| "what can run in parallel" | `parallel` |
| "watch this goal", "re-check after pushes" | `watch` |
| "prepare this for review", "show plan/diff/evidence" | `review` |
| "how does this work" | `help` |

For everything else — designing gates, budgets, when not to loop — follow
`core/METHODOLOGY.md`. Never declare a goal done without its VERIFY command
passing in an independent run, reproducible receipt evidence and a passing
scope check.
