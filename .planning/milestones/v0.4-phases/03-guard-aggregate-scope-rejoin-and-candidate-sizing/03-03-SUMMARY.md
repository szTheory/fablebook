---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
plan: "03"
subsystem: testing
tags: [static-evidence, candidate-sizing, fail-closed]
requires:
  - phase: 03-02
    provides: Immutable two-lane scope and evidence records
provides:
  - Hash-bound sizing evidence and a fail-closed no-candidate result
  - Validation for source, context, plan, task, and effort limits
affects: [phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing]
actuals:
  tokens: 36096
  tasks: 2
  commits: 2
  plan_head_before: efcec4a1d77ff0b4c2896a0597b9af4769a4a48d
  plan_head_after: 9463f56b0eee63bb630a2ae404390b542a1be733
tech-stack:
  added: []
  patterns: ["Hash-bound static evidence projection", "Fail-closed sizing validation"]
key-files:
  created:
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json
  modified:
    - test/support/guard_aggregate_reconciliation_evidence.ex
    - test/contract/tier_sweep_test.exs
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-SIZING.json
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md
    - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-EXECUTION-SOURCE-SCHEDULE.md
key-decisions:
  - "Keep candidate null because both evidence lanes remain incomplete and the effort ceiling is unproven."
  - "Bind all scope counts and complement digests to immutable lane records and the keyed projection."
patterns-established:
  - "Unknown measurements fail validation instead of being treated as zero."
  - "Report crosswalks remain available when coverage is incomplete, while incomplete coverage still blocks selection."
requirements-completed: [GSR-03, GSR-04, GSR-05, GSR-06]
coverage:
  - id: D1
    description: "Sizing validator enforces measured fit limits, exact lane membership, canonical complement digests, and fail-closed candidate selection."
    requirement: GSR-03
    verification:
      - kind: unit
        ref: "test/contract/tier_sweep_test.exs — focused core and floor selectors"
        status: pass
    human_judgment: false
  - id: D2
    description: "Sizing report preserves incomplete source and caller crosswalk evidence and records the bounded no-candidate outcome."
    requirement: GSR-06
    verification:
      - kind: unit
        ref: "test/contract/tier_sweep_test.exs — report-write and bundle-shape assertions"
        status: pass
    human_judgment: true
    rationale: "The report leaves a separate future owner decision; static evidence cannot authorize later implementation."
duration: "not captured"
completed: 2026-11-15
status: complete
---

# Phase 3 Plan 03: Guard Aggregate Scope Rejoin and Candidate Sizing Summary

**Hash-bound sizing evidence now explains why no later candidate can be selected under the current evidence and effort limits.**

## Performance

- **Duration:** Not captured by the execution session.
- **Started:** Not recorded.
- **Completed:** 2026-11-15
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Added a compact keyed projection and validated original, delivered, and pending membership against immutable lane-record digests.
- Preserved the source and static-caller crosswalks in the generated report while clearly retaining incomplete coverage status.
- Recorded a no-candidate outcome: candidate remains null, source/caller evidence remains incomplete, and future effort is unknown against the three-working-day limit.
- Kept implementation unauthorized, aggregate gate open, Walking Skeleton blocked, and SEC-01 Pending.

## Task Commits

1. **Task 1: Produce hash-bound sizing evidence and preserve incomplete crosswalks** — `62c0373` (`feat`)
2. **Task 2: Validate sizing against canonical scope and record the no-candidate decision** — `9463f56` (`feat`)

## Files Created/Modified

- `test/support/guard_aggregate_reconciliation_evidence.ex` — validates measurements and lane scope; renders the bounded fail-closed sizing report.
- `test/contract/tier_sweep_test.exs` — covers limits, missing evidence, scope mismatches, collisions, candidate selection, and report integrity.
- `03-03-KEYED-EVIDENCE.json` — compact keyed evidence projection.
- `03-SIZING.json`, `03-RECONCILIATION.md`, and `03-03-EXECUTION-SOURCE-SCHEDULE.md` — sizing decision, rationale, exact fit receipts, and review trail.
- `03-03-PLAN.md` and `03-03-REPLAN.md` — revised and independently reviewed execution envelope.

## Decisions Made

- No candidate is selected because source and caller coverage remain incomplete and the candidate-specific effort estimate is unknown.
- All original/delivered/pending sets are bound to canonical projection counts and immutable lane evidence; incomplete evidence remains visible in the report.
- Later implementation remains a separate owner decision and is not authorized by this plan.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Preserve crosswalk evidence when report coverage is incomplete**
- **Found during:** Task 1
- **Issue:** The report writer replaced the report with a smaller invalid document when coverage was incomplete, dropping the existing crosswalks.
- **Fix:** Updated the production writer to retain both crosswalks while keeping incomplete status and candidate null; publication remains gated by bundle validation and row-shape checks.
- **Files modified:** `test/support/guard_aggregate_reconciliation_evidence.ex`, `test/contract/tier_sweep_test.exs`
- **Verification:** Cheap shape/provenance checks and focused core/floor selectors passed; report retained 452 source rows and 3,481 caller rows.
- **Committed in:** `62c0373`

**2. [Rule 1 - Bug] Use canonical lane-set digests for complement validation**
- **Found during:** Task 2
- **Issue:** Locally hashing selected MFA arrays did not match the canonical lane evidence digest contract.
- **Fix:** Bound the sizing artifact to projection-provided original, delivered, and pending counts/digests and validate exact set relationships.
- **Files modified:** `test/support/guard_aggregate_reconciliation_evidence.ex`, `test/contract/tier_sweep_test.exs`, `03-SIZING.json`, `03-RECONCILIATION.md`
- **Verification:** Focused core and floor selectors passed; metadata checks confirmed both lane digests against the keyed projection.
- **Committed in:** `9463f56`

**Total deviations:** 2 auto-fixed (Rule 1: 2). Both were needed for correct, fail-closed report generation and canonical scope validation.

## Issues Encountered

- An initial report-write attempt produced an invalid smaller candidate; the committed report was restored, the writer defect was isolated, and the corrected path was checked before publication.
- The final report is 13,115,491 bytes. Task 2 used only its bounded 730-byte section and metadata; it did not reopen the report JSON body or any source bodies.

## User Setup Required

None.

## Next Phase Readiness

Plan 03-03 is complete with a bounded no-candidate result. The aggregate gate remains open, Walking Skeleton remains blocked, SEC-01 remains Pending, and implementation remains unauthorized. No later plan or phase is authorized by this result; the owner must make the separately recorded future-scope decision before any new work is planned.

## Self-Check: PASSED

- Summary file created and both task commits are ancestors of the current phase branch.
- Task commit count and before/after plan heads were measured from the plan ledger.
- The Task 2 focused selectors passed; broader suites were not run under the scoped verification instruction.

---
*Phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Completed: 2026-11-15*
