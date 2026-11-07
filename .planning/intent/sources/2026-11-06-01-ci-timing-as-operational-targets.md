---
id: INT-20261106-01
date: 2026-11-06
source: Codex session, owner instruction to sanity-check timing limits and follow the recommendation
captured_by: Codex (GPT-6)
context: Phase 1 verification found the rolling seven-day PR timing sample over the existing p50/p95 targets and an open quality-regression issue that blocks releases.
---

> Verbatim owner direction:
>
> What do you recommend? Let's follow that. I don't know what's the value in these timing limits or whatever. Like, just sanity check that. I don't want to be hamstrung by arbitrary limits.

**Resolution:** Keep the existing 420-second p50 and 600-second p95 as visible CI feedback-time objectives. Continue publishing the measured values and track overages for optimization. A timing-only overage must use a separate `ci-performance` issue and must not create or update `quality-regression`, block a release, or prevent phase closure. Functional, security, ruleset-drift, release-smoke, and required-check failures retain their existing gates. Review future CI changes for measured, repeatable iteration-time savings without reducing coverage. This records the owner's instruction to follow the recommendation and is the owner-signed decision required by the gate-change rule.
