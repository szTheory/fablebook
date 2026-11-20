# Test-writer feasibility inspection

**Date:** 2026-11-20
**Phase:** v0.6 Phase 7 — Guard Scope Reconciliation
**Outcome:** NO-GO — the historic test writer is not a safe current-core producer under the reviewed phase boundary.

## Scope and method

Read-only inspection of one producer test and four directly referenced project helpers. The execute preflight passed for v0.6 Phase 7. Exact inspected Git blobs:

| File | Git blob |
|---|---|
| `test/contract/tier_sweep_test.exs` | `1683cea9033c8b9f1a05f4dffc196a985e543483` |
| `test/support/installed_otp.ex` | `80774f40a3d5a165a0c78cae006aebed1eec9e27` |
| `test/support/sweep_evidence.ex` | `5dd7d60f02635e4930285529a5c00bfca3b4520a` |
| `test/support/guard_aggregate_evidence_paths.ex` | `f44add0b337f7897f45386e330ed9fea06deb0a5` |
| `credo/checks/banned_calls.ex` | `5153d8e905c1f3cc8d4bcfd2dbbd070527f71638` |

No target OTP source body was opened. No test, build, compile, helper, runtime API, or evidence writer was executed. No evidence or archived file was modified.

## Findings

1. The `guard_aggregate_reconciliation_records` test can assemble a lane record using a live graph, lane evidence, delivery receipts, runtime, and the current lock digest. It writes only behind `FABLEBOOK_GUARD_AGGREGATE_WRITE=1`, through `phase3_writable_evidence_dir!`.
2. The test's `setup_all` calls `build_graph()`. That path invokes `InstalledOtp.source_inventory!`; its helper reads installed OTP source files to calculate their sizes. Running the record writer therefore crosses the existing no-target-source-body boundary.
3. The caller writer uses `phase3_evidence_dir!` for both reads and outputs. The path helper selects a complete archived Phase 3 directory first. The caller writer then writes the enriched lane records and crosswalk directly to that directory under `FABLEBOOK_GUARD_AGGREGATE_CALLER_WRITE=1`. The normal record/source writers refuse archived writes, but this caller path does not.
4. Caller evidence is attached to existing Phase 3 records and saved v0.2 graph observations. Its test assertions retain explicit gaps, `candidate == nil`, and the open aggregate gate; it is not a current-core baseline producer.
5. `SweepEvidence.source_roots!/0` loads a pinned historical source archive and permits one recorded Plug lock overlay. That does not establish current source identities for the current full core lock.
6. `InstalledOtp.export_inventory!/2` is a possible metadata-only lead because it requests BEAM exports, but its special `behaviour_info/1` handling also reads debug-info forms. This inspection does not establish a deterministic way to generate the complete required maps without target code bodies or an audited operation.

The phase's cheap `execute` preflight passed. The `verify` preflight did not: it reported the 07-01 summary as incomplete and summaries missing for 07-02 through 07-05. No verification report, milestone audit, completion, or cleanup was run because the downstream work is blocked and those summaries must not be fabricated.

## GSD decision

An independent goal-backward review of Plans 07-01–07-05 found that Plan 07-01 Task 2's precondition remains false. No family, complete complement, source schedule, or approved observation manifest exists. Plans 07-01 Tasks 2–3 and Plans 07-02–07-05 cannot execute without a fresh, provenance-bound current-core map path.

Do not run the historical writer or write its outputs into archived Phase 3. R9 remains denied; R10 and R11 remain spent; candidate remains null; implementation and aggregate closure remain unauthorized; SEC-01 remains Pending; Walking Skeleton remains blocked. The phase is not complete and no milestone audit/closeout should run.

## Bounded next step

Resume only if a complete provenance-bound current-core map package is supplied, or a separately reviewed metadata-only producer scope proves a deterministic path that avoids source/debug-info bodies, audited runtime operations, and archived writes. Preserve the owner decision boundary after that evidence exit; do not auto-chain another guard increment.
