# Wiring the stop hook (per project)

The stop hook is the enforcement layer for rule #2 ("the gate decides, not
the generator"): it blocks ending a Claude Code session while the active
loop's gate is red. It is **per-project** — the skill installs the generic
script, but each project wires it explicitly (a global stop hook running
arbitrary verify commands in every repo would be a footgun).

`/le:start` offers to do all of this for you (Phase 3, step 7). Manually:

1. Copy the generic gate into the project:

   ```sh
   mkdir -p .claude/hooks
   cp ~/.claude/skills/loop-engineering/core/scripts/stop-verify.sh .claude/hooks/
   chmod +x .claude/hooks/stop-verify.sh
   ```

2. Wire it in `.claude/settings.json` (merge into existing hooks):

   ```json
   {
     "hooks": {
       "Stop": [
         { "hooks": [ { "type": "command", "command": ".claude/hooks/stop-verify.sh" } ] }
       ]
     }
   }
   ```

3. Add the marker file to `.gitignore`:

   ```sh
   echo .le-active-verify >> .gitignore
   ```

How it behaves: when a loop is running, `.le-active-verify` at the repo root
holds the active VERIFY command (written by `/le:goal` / `/le:auto`, deleted
on close). On session stop, the hook runs it; red gate ⇒ exit 2, which
blocks the stop and feeds the reason back to Claude. No marker file ⇒
nothing to enforce. After 3 consecutive blocked stops it lets the session
end and tells you to run the stuck protocol — a permanently red gate needs
diagnosis, not an unclosable terminal.

Verified against Claude Code 2.1.212 (2026-07): Stop hooks in
`settings.json`, exit code 2 blocks the stop. Hook behavior changes between
versions — re-check the hooks documentation if this stops working.
