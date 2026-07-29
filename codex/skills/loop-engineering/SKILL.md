---
name: loop-engineering
description: Drive a project as verified loops (goal → action → feedback → stop). Trigger when the user wants to loop until tests pass, keep going until the build is green, resume the project, ask where we left off, set up loop engineering, plan a project as loops, run/verify/diagnose/review/watch a goal, inspect parallel work, or close a milestone. Not for exploratory design work or one-shot trivial edits.
---

# Loop Engineering (Codex)

Methodology, canonical command spec and templates live in this skill's
`core/` directory — read them on demand, don't guess:

- `core/METHODOLOGY.md` (relative to this SKILL.md) — the method: loop
  anatomy, verification principles, memory layers, stuck protocol.
- `core/COMMANDS.md` — exact behavior of every command (`start`, `plan`,
  `auto`, `goal`, `verify`, `status`, `receipt`, `stuck`,
  `close-milestone`, `memory`, `parallel`, `watch`, `review`, `help`). Route the user's
  request to the matching command section and follow it exactly. The same
  commands are also invocable explicitly as `/prompts:le-<name>`.
- `core/templates/` and `core/scripts/` — files `start` generates.

Codex CLI supports Stop hooks, but has no worktree flag or scheduled-task
manager. Offer the optional Stop hook during `start`; regardless, before
declaring ANY goal done, re-run its VERIFY command in a fresh invocation and
record that output in the receipt. `parallel` emits a sequential plan.

Detect project state first: `docs/GOALS.md` with a `# Goals —` header means
an initialized project — read it plus relevant `docs/plans/` and
`docs/receipts/` before proposing
anything; otherwise the entry point is `start`.

Converse in the user's language; every file you create is in English.
Never declare a goal done without its VERIFY command passing in an
independent run. Before closing it, require its plan, reproducible receipt
evidence and a passing scope check as specified in `core/COMMANDS.md`.
