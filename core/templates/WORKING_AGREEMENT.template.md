<!-- loop-engineering:begin -->
## Working Agreement (loop engineering)

This project is driven as verified loops. Full method:
`docs/GOALS.md` (the goal map) · `docs/receipts/` (run logs) ·
`docs/STATUS.md` (what actually exists) · `docs/adr/` (decisions).

Non-negotiable rules:

1. **Nothing simulated.** A capability is fully implemented or it does not
   exist. No stubs returning plausible data, no UI for unimplemented
   features.
2. **The gate decides, not the generator.** A goal is done when its VERIFY
   command passes in an independent run — never because the session that
   wrote the code says so.
3. **Scoped verifies.** Goal gates run on the goal's scope:
   `<SCOPED_GATE_PATTERN>`. The project-wide gate (`<FULL_GATE_COMMAND>`)
   runs only at milestone close. Every gate must be runnable exactly as
   written — test it once before recording it.
4. **Budgets always.** Every loop declares iteration and identical-failure
   ceilings before starting (defaults: 10 / 3), plus time/cost when
   unattended.
5. **Stuck → diagnose, don't relaunch.** Read the receipt, classify the
   cause (bad gate / missing dependency / ambiguous goal / environment),
   then reformulate, split, or escalate to an ADR. Never just raise the
   budget.
6. **Memory discipline.** A correction that repeats goes here (this file);
   decisions go to `docs/adr/`; reality to `docs/STATUS.md`; every loop run
   to `docs/receipts/`.
7. **When a target is unreachable, stop and report** with alternatives —
   explicitly preferred over shipping something that looks like it works.

Durable corrections (append below; one imperative rule per line, with its
trigger context):

<!-- loop-engineering:end -->
