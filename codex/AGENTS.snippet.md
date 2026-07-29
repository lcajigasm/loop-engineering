<!-- Append this block to a project's AGENTS.md to make any Codex session
     loop-engineering-aware even when the skill isn't triggered. `le-start`
     appends the fuller Working Agreement (which includes these rules) for
     you; use this snippet for a manual, minimal setup. -->

<!-- loop-engineering:begin -->
## Loop engineering

This project is driven as verified loops. State lives in files, not in
anyone's memory: `docs/GOALS.md` (goal map), `docs/plans/` (intent and scope
exceptions), `docs/receipts/` (run logs and evidence), `docs/STATUS.md` (what
actually exists), `docs/adr/` (decisions). Read them before writing code;
resume from them, don't ask the human to re-explain.

Method reference: `~/.agents/skills/loop-engineering/core/METHODOLOGY.md`.
Commands: `/prompts:le-help` lists them; `/prompts:le-auto` resumes work.

Hard rules: nothing simulated; a goal is done only when its VERIFY command
passes in a fresh, independent run (re-run it yourself — there is no hook
to catch you); gates stay scoped to the goal, project-wide only at
milestone close; every loop has budgets (10 iterations / 3 identical
failures by default); a stuck loop gets diagnosed, never relaunched with a
bigger budget; plan before editing; every passing receipt includes final
VERIFY evidence, revision, changed files and a scope check.
<!-- loop-engineering:end -->
