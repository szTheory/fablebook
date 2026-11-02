---
id: INT-20261102-01
date: 2026-11-02
source: Codex session, owner direction
captured_by: Codex
context: Owner wants workflow snags fixed, lessons retained, and context handoffs to end with one concrete next OpenGSD command and the checkout where it should run.
---

> Verbatim owner direction: “I wish we could remember that going forward. What's going on here? We should do lessons learned. Missing local dependency cache. Okay, can you fix that? Maybe we should do. Do we need to have a cleaner use Docker developer experience? You can kind of look at. some of the other projects in ~/projects my other elixir oss libs maybe u learn some dx docker stuff from there to reduce contention/cache issues...”

> Verbatim owner direction: “Carry it out such that I can clear context, run the next opengsd command once you're done, and we won't lose important signal or context or information. And then make sure you give me very clear, non AI slop next steps at the end. And then also, you know, the opengsd command itself that I would run. And remember all of this going forward, especially whenever we had a snag like this. We should get lessons learned and apply them.”

**Resolution:** When a workflow snag changes the path, fix the underlying cause where authorized, record the cause/remedy/limits in project guidance and the handoff, and end with the exact next command, working checkout, and next actor. Research Docker and cache approaches against this project's actual needs before adding infrastructure.
