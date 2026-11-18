---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
plan: 05
subsystem: testing
tags: [elixir, otp, evidence-provenance, local-readiness]
requires:
  - phase: 03-04
    provides: Complete metadata index and no-candidate handoff
  - phase: 04-evidence-only-source-and-gap-provenance-closure
    provides: Exact-generation provenance artifacts with explicit unresolved gaps
provides:
  - Corrected aggregate consumers and negative controls that preserve unresolved source and caller status
  - Reproducible Phase 3 recovery crosswalk and exact local test receipts
  - Current execution handoff that removes the cumulative output stop and preserves per-request safety gates
affects: [phase 03 verification, phase 04 provenance]
actuals:
  tokens: 2035683 # diff-size estimate, dominated by the machine-generated crosswalk; not model usage or a stop
  tasks: 3
  commits: 0
  plan_head_before: 7b333dbe27eff85ddbc206bce03521c255b6d0c2
  plan_head_after: 7b333dbe27eff85ddbc206bce03521c255b6d0c2
tech-stack:
  added: []
  patterns:
    - Validate exact generation, lane, identity and digest bindings before rendering evidence
    - Run cheap provenance and focused checks before long pinned-lane suites
key-files:
  created:
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-validate-evidence.py
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECOVERY-RECONCILIATION.md
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECOVERY-READINESS.md
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECOVERY-CODE-REVIEW.md
  modified:
    - test/contract/tier_sweep_test.exs
    - test/support/guard_aggregate_reconciliation_evidence.ex
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-PLAN.md
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-VALIDATION.md
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-EXECUTION-SOURCE-SCHEDULE-COMPACT.md
    - .planning/STATE.md
key-decisions:
  - "Complete keyed gap records are valid consumer inputs but do not mean source resolution or caller closure."
  - "Per-request source checks remain; there is no cumulative assistant-output ceiling or reserve stop."
  - "The core CI lane must run with MIX_ENV=test so the test-support modules compile."
patterns-established:
  - "Run the validator and focused lane checks before core CI and the full floor suite."
  - "Bind test receipts to exact code, crosswalk and provenance hashes."
requirements-completed: []
duration: not measured across resumed sessions
completed: 2026-11-17
status: complete
---

# Phase 3 Plan 05: Local Recovery Summary

**The recorded consumer and fixture failures are repaired and all scheduled local checks pass, while unresolved provenance and product gates remain explicit.**

## Performance

- **Duration:** Not measured across resumed sessions.
- **Tasks:** 3 local tasks completed.
- **Task commits:** None; the recovery worktree remains available for verification and delivery review.
- **Files:** See the exact artifact hashes and test receipts in [03-RECOVERY-READINESS.md](03-RECOVERY-READINESS.md).

## Accomplishments

- Corrected the nullable collision fixture and source/caller consumer path. The validator binds evidence to the actual artifact bytes, exact generation, lane records, identity pointers and canonical digest; negative controls reject stale and substituted inputs.
- Generated a full identity-level recovery crosswalk. Its gap partition is complete, while source resolution is unresolved, caller closure is incomplete, the legacy digest is unresolved, and the candidate remains null.
- Ran the cheap validator checks, focused core and floor selections, core CI, the full floor suite and the intent-corpus check. The independent final code review has no unresolved blocking finding.
- Updated the active plan to remove the cumulative output stop and the nonexistent `--all` command. Per-request source counts, review, preflight, exact scope, no-truncation and security gates remain.
- Reconciled the validation task inventory to twelve tasks across the five plans and updated the current state handoff. The original failed readiness receipt remains preserved as history.

## Task Commits

None. The isolated recovery checkout is preserved at the reviewed base head shown in the readiness receipt; no delivery commit or pull request is claimed.

## Decisions Made

- A passing `pass_with_open_gaps` check permits validation of the typed-gap behavior only. It cannot be presented as resolved source or caller evidence.
- The original aggregate and manual stops remain binding: actual library collision unknown, Macro caller-AST and explanation wording unresolved, static-only scope, candidate null, implementation unauthorized, aggregate gate open, Walking Skeleton blocked, and SEC-01 Pending.
- Hosted CI, merge/main CI and phase delivery are separate gates and have not occurred.

## Deviations from Plan

- Corrected the core CI invocation to `MIX_ENV=test bin/lane core mix ci` after the lane wrapper selected the development environment for generic `mix ci`; this was an invocation fix and required no dependency change.
- Replaced the plan's nonexistent Phase 4 `--all` check with the implemented `--phase4-only` and consumer checks, and clarified that a complete typed-gap partition does not close semantic gaps.
- Removed stale aggregate-token ceilings and output-reserve wording under owner direction INT-20261117-11. Exact per-request context/provenance gates remain.

## Issues Encountered

The final code review found one provenance-binding gap. The validator now recomputes artifact digests, binds the historical producer identity to the exact reviewed manifest and R2/R3 schedules, and checks generation/lane/identity pointers for every typed gap. The second review pass confirmed the finding resolved. The saved local `act` incompatibility was reused; no unsupported repeat was made.

## Next Phase Readiness

Plan 03-05's local execution is complete. Goal-backward verification passed 5/5 criteria in the documented-gap/no-candidate outcome, security is verified at ASVS L1, and the validation audit found no missing automated coverage across the twelve task IDs. Source/caller and manual gates remain unresolved by design and are not waived. The next actor is Codex for the existing UAT/delivery workflow; hosted candidate CI, merge and main CI must still pass before phase delivery. No owner action is needed for that routine work.

---
*Phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Completed: 2026-11-17*
