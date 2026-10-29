---
id: INT-20261029-05
date: 2026-10-29
source: Claude Code session, /gsd-plan-phase 01.1.1, owner message sent while execute-phase 01.1.1 plan 01 was running
captured_by: Claude (Opus 5.5)
context: plan-phase had auto-advanced into /gsd-execute-phase 01.1.1 --auto because workflow.auto_advance was true in .planning/config.json.
---

> Verbatim.

oh btw i dont think we need to do GSD auto advance for this project can u disable that? i like to be able to see the steps

**Resolution:** `workflow.auto_advance` is set to `false` in `.planning/config.json`. GSD steps no longer chain into the next command on their own: each step ends with its Next Up block, and the owner runs the next command.
