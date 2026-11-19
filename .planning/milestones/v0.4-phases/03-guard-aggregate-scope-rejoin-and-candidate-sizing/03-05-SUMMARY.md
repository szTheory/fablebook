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
completed: 2026-11-19
status: complete
---

# Phase 3 Plan 05: Local Recovery Summary

**Phase 3 goal verification passed on the current local candidate. Hosted PR CI and delivery remain pending; unresolved provenance and product gates stay explicit.**

## Performance

- **Duration:** Not measured across resumed sessions.
- **Tasks:** 3 local tasks completed.
- **Task commits:** No separate task commits; all recovered work is grouped in the final phase candidate commit.
- **Files:** See the exact artifact hashes and test receipts in [03-RECOVERY-READINESS.md](03-RECOVERY-READINESS.md).
- **Measured checks:** Core and floor focused selections took 60s and 53.6s. Core CI took 413s total (403.5s test stage; 459 passed, 10 excluded). The full floor suite took 403.2s (467 passed, 2 excluded). The planning-intent corpus check took 14.6s (22 passed).

## Accomplishments

- Corrected the nullable collision fixture and source/caller consumer path. The validator binds evidence to the actual artifact bytes, exact generation, lane records, identity pointers and canonical digest; negative controls reject stale and substituted inputs.
- Generated a full identity-level recovery crosswalk. Its gap partition is complete, while source resolution is unresolved, caller closure is incomplete, the legacy digest is unresolved, and the candidate remains null.
- Ran the cheap validator checks, focused core and floor selections, core CI, the full floor suite and the intent-corpus check. The core focused selection passed 9/9 selected cases; the floor focused selection passed 9/9; core CI passed 459 tests with 10 excluded; the full floor suite passed 467 tests with 2 excluded.
- Preserved the failures and repaired their causes before continuing: strict Credo flagged four ungrouped integer literals; later core CI found malformed intent frontmatter. The literal-only formatting fix preserved values, and the intent source metadata was normalized without changing its text or any tests. The final focused corpus check passed 22/22.
- The narrow independent review of the final helper formatting change passed, and the broader code review has no unresolved blocking finding. The final Phase 4 bridge and evidence subjects received independent metadata-only PASS reviews; Phase 4 `--all` and the Phase 3 consumer check pass on the resulting bound receipts, with source access closed.
- Updated the active plan to remove the cumulative output stop and the nonexistent `--all` command. Per-request source counts, review, preflight, exact scope, no-truncation and security gates remain.
- Reconciled the validation task inventory to twelve tasks across the five plans and updated the current state handoff. The original failed readiness receipt remains preserved as history.
- Reverified all 21 Phase 3 must-haves, passed both automated UAT checks, and confirmed the existing security record has no open threats. No human UAT is needed for this evidence-only result.

## Task Commits

No separate task commits were made during recovery. The verified recovery candidate is grouped in the final phase delivery commit; hosted CI and merge are still pending.

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

Plan 03-05's ordered local execution gates are complete. The full Phase 3 goal verification, security closeout, hosted candidate CI, actual merge/main CI, and delivery receipt are not complete and are not inferred from these local runs. The complete typed-gap partition preserves 9,716 unresolved rows; source resolution, caller closure, and legacy digest remain unresolved, and candidate remains null. No manual safety stop is waived. Next, Codex completes the normal Phase 3 verification and security workflow, then updates PR #90 under the standing authorization to obtain hosted receipts. The owner remains the merge decision-maker. No owner action is needed for this routine work.

---
*Phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Completed: 2026-11-17*
