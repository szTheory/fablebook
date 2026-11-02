---
id: INT-20261101-02
date: 2026-11-01
source: Codex session, owner direction
captured_by: Codex
context: Owner wants to return to easy-to-read OpenGSD phase numbers and stop accumulating nested decimal insertions.
---

> Verbatim owner direction: “With these crazy version numbers .01,.1,.1,.3,.1,.2, are we going to get back to regular opengsd style phase numbers? Because this is still driving me insane. I'd like to, as soon as possible, for the next milestone or whatever, fix these phase numbers. It's okay. We don't have to commit to this insanity going forward.”

**Resolution:** Preserve all current phase IDs and historical references. When the current milestone is complete and archived, start the next milestone at Phase 1 using `$gsd-new-milestone --reset-phase-numbers`. Use ordinary sequential integer phase numbers. Avoid nested decimal insertions; use a one-level decimal only for an exceptional urgent insertion within a milestone.
