---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
plan: 05
subsystem: planning-validation
tags: [phase3, metadata, provenance, pinned-lanes]
requires:
  - Plans 03-01 through 03-04 evidence receipts
provides:
  - Green local core/floor readiness for the evidence-only Phase 3 boundary
  - Exact metadata-only no-candidate handoff with keyed unknown and unresolved gaps
affects: [phase3-validation, phase3-handoff]
key-files:
  created:
    - 03-READINESS.md
    - 03-RECOVERY-CODE-REVIEW.md
    - test/contract/guard_aggregate_metadata_test.exs
  modified:
    - mix.exs
    - test/contract/ci_shape_test.exs
    - test/contract/tier_sweep_test.exs
    - test/support/guard_aggregate_reconciliation_evidence.ex
    - 03-VALIDATION.md
    - ../../STATE.md
key-decisions:
  - Use a standalone metadata contract so the cheap gap/schema gate avoids the tier-sweep graph setup.
  - Match local core CI to the hosted job with MIX_ENV=test.
  - Preserve unresolved source/caller gaps and select no candidate; do not infer source proof from metadata.
  - Keep SEC-01, actual-collision, implementation and Phase 4 stops unchanged.
requirements-completed: []
completed: 2026-11-18
---

# Phase 03 Plan 05 Summary — Local Evidence Readiness

## Result

Completed the approved local recovery. The full core pipeline passes (454 tests, 10 excluded) and the full floor suite passes (464 tests, 2 excluded). The standalone metadata gate and CI-shape contract also pass on the pinned lanes; strict Credo and formatting checks are clean. Review findings were resolved, and the exact commands, results, hashes and logs are in [03-READINESS.md](03-READINESS.md).

A status mismatch in prior `MIX_ENV=dev` invocations was corrected: local core CI now matches the GitHub job’s explicit test environment. A separate metadata test prevents the graph-building setup from making the cheap consistency gate take nearly a minute. Exact count/type assertions reject unknown row types as well as missing or duplicated known records.

## Evidence boundary

This plan closes local validation for the evidence-only no-candidate outcome. It does not close the source/caller provenance requirements: 4,797 known target mappings remain unresolved and 18 target lists remain unknown. Source proof, caller closure, actual collision status, candidate choice, implementation authorization, SEC-01 and Walking Skeleton remain open/pending exactly as recorded. No target OTP source bodies were read, and Phase 4 was not started.

## CI efficiency

Core ExUnit completed in 427.8 seconds and floor in 411.4 seconds. Existing CI history and cache wiring show no repeatable safe change from this local sample, so no CI workflow or dependency changes were made. The long graph inventory stays captured in temporary logs instead of the chat and repository.

## Remaining lifecycle

The validation map and canonical STATE now record local execution as complete and phase-level verification as pending. Hosted candidate/main CI and merge receipts remain pending. No user action is needed for this routine verification and handoff bookkeeping.

---
*Phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Completed: 2026-11-18 (local evidence readiness)*
