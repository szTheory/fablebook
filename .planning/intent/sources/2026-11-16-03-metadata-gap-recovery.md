---
id: INT-20261116-03
date: 2026-11-16
source: user
captured_by: Codex
supersedes: INT-20261116-02
context: Owner directed Codex to continue forensics/planning and find an alternative if the missing evidence could not be recovered directly.
---

# Recover the blocked evidence handoff

**Verbatim owner direction:** “I mean, I don't even know what that means. It's not going to happen on its own. So, can you do that automatically? Unblock us. And if you can't find it, you're going to have to figure out your own way around it. Cut out your losses, figure something else out.”

**Decision:** Do not make recovery depend on the owner supplying data that may already exist locally. Inspect the existing Phase 3 records and, where target membership is present but source/caller linkage is not, produce a streaming, identity-keyed metadata gap register and a bounded human-readable handoff. Mark unresolved associations as unknown, never as absent; retain the 18 unknown target-list rows separately. Do not invent provenance, extend any budget, read additional source bodies without the established schedule/review/preflight/count gates, or start Phase 4 automatically. Preserve candidate=null and all existing safety stops.
