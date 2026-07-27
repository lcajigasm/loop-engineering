# Receipt: <goal id> — <goal name>

A receipt records one loop's execution — how many iterations it took, what
failed along the way, what fixed it, and whether it got stuck. It is not an
ADR: an ADR explains a design decision that survives forever; a receipt is
the log of one concrete run, mainly so the next session knows exactly where
the work was left without a human having to explain it.

- Goal: <one sentence, the verifiable condition — not a task list>
- Scope: <module/package>
- Verify: `<exact command that decided pass/fail>`
- Iterations: <n> / <max>
- Result: passed | stuck | budget-exhausted
- Opened: <YYYY-MM-DD>
- Closed: <YYYY-MM-DD>
- Human check: <only for `Verify: human` goals — who checked, what they
  observed. Delete this line otherwise.>
- Notes: what failed along the way, what the fix was, decisions taken that
  the goal text didn't specify, anything left explicitly out of scope, and
  whether any lesson is worth promoting to the agent memory file (see
  METHODOLOGY.md, "four memory layers").
