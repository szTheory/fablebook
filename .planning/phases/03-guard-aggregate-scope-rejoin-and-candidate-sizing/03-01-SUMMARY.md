---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
plan: "01"
subsystem: testing
tags: [aggregate-evidence, tier-sweep, mfa-membership, receipts]
requires: []
provides:
  - Complete core and floor joins across all original exclusion and lane-metadata identities
  - Digest-linked combined crosswalk with exact historical, live, delivered, missing, and pending sets
affects: [phase-03-plans-02-through-05, aggregate-guard-evidence]
actuals:
  tokens: 1430580
  tasks: 3
  commits: 13
plan_head_before: 4fd00ea9afdfc7780ff628861da794420f6daa5f
plan_head_after: 12ecc239e0ac5d1f86e4bb24b5d512cc07c8404c
tech-stack:
  added: []
  patterns: [lane-bound aggregate records, exact MFA set partitions, fail-closed identity/reference joins]
key-files:
  created: [.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json, .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json, .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md]
  modified: [test/support/guard_aggregate_reconciliation_evidence.ex, test/contract/tier_sweep_test.exs]
key-decisions:
  - "Keep the full installed export inventory in memory for subset validation, but serialize only its count, digest, lane, and provenance."
  - "Keep historical baseline, current live membership, delivered scope, delivered-now-missing, and pending as distinct exact sets."
  - "Preserve source and authority gates; this evidence does not select a candidate or authorize implementation."
requirements-completed: [GSR-01, GSR-02, GSR-04, GSR-06]
duration: "not recorded across resumed sessions"
completed: 2026-11-14
status: complete
---

# Phase 03 Plan 01: Guard Aggregate Scope Rejoin and Candidate Sizing Summary

Completed the all-row core/floor identity join and produced deterministic lane records plus a combined crosswalk. The implementation and evidence are committed locally on `main`; no push was made. Elapsed wall time is not reconstructed because execution spanned several resumed sessions; individual lane-check durations are recorded below.

## Task Commits

1. **03-01-03: Recovery and source-note continuation** — `9b74391`, `ad31503` (docs)
2. **03-01-04: EX-010 both-lane tracer** — `884684b` (test)
3. **03-01-05: Complete aggregate row join** — `12ecc23` (test)

Plan revisions and checkpoints are retained in the plan history, including the owner-approved one-time lookup exception at `bad20ce`. Thirteen commits are reachable from the plan's initial commit through the Plan 03-01 delivery commit; the approval and recovery trail remains intact.

## Accomplishments

- Preserved all 226 original identities per lane, including 221 exclusions and 5 lane-metadata rows.
- Derived exact live, replacement, added, missing, delivered, delivered-now-missing, and pending MFA sets with fail-closed reference and receipt validation.
- Kept the EX-010 delivery slice and EX-107 three-member delivery distinct from EX-107 historical and pending partitions.
- Rendered a 226-row crosswalk with separate core/floor membership and links to the two digest-backed records.
- Retained all candidate, authority, aggregate, source, Walking Skeleton, and SEC-01 stops.

## Verification

- Cheap structural checks: both lane records have 226 unique identities, with 221 exclusions and 5 metadata rows; lane identities match; all row equations and delivered/pending disjointness/union checks pass.
- EX-010 delivered set: 2. EX-107: delivered 3, historical 13, complement 164, pending 161.
- Combined report: 226 crosswalk rows, two receipt references, both lane record links present, and source join remains open.
- Focused core preflight: 1 passed in 93.6s.
- Core record generation: 2 passed in 64.6s. Floor record generation: 2 passed in 70.6s.
- Bundle selector: 1 passed in 51.9s with actual command exit 0. An earlier run also passed ExUnit but its wrapper returned 1 because zsh reserves the variable name status; the corrected run confirms the true exit code.
- Core broad aggregate selector: 4 passed in 74.6s. Floor broad aggregate selector: 4 passed in 63.7s.
- mix format --check-formatted and git diff --check passed.

## Artifact digests

| Artifact | Bytes | SHA-256 |
|---|---:|---|
| test/support/guard_aggregate_reconciliation_evidence.ex | 18,215 | effcd366fcbb94de9b9e8cf71a7a4ac00622c4f66c3cd59c94bc7b4c49401361 |
| test/contract/tier_sweep_test.exs | 743,771 | 8c9c6f7fb0c0ed642baf916f61480c6f2adf22817ec54de0bd40359c8d0a0c29 |
| 03-CORE-AGGREGATE-EVIDENCE.json | 1,418,156 | 70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd |
| 03-FLOOR-AGGREGATE-EVIDENCE.json | 1,390,810 | 955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d |
| 03-RECONCILIATION.md | 2,624,216 | 3230fde0ffcb2de96ca213671836d38d3ce20a01dd1a545863fe3bf97d544394 |

## Context fit and source boundary

The reviewed fit receipt measures 41,727 selected planning-context tokens. Adding the 1,000-token post-count cushion, full 12,000-token source allocation (including the one-time owner-approved event6 charge), 5,000-token output allowance, and 31,000-token reserve yields 90,727/100,000, leaving 9,273 slack. No source body was reread after event6. The consumed/incomplete event4 body was not used; its receipt metadata remains the only representation.

## Deviations and resolved checks

- Corrected the final MFA suffix parser to accept any slash count before a numeric final arity and reject malformed suffixes.
- Kept nonmatching-lane creator references as metadata and excluded them from current-lane membership; validated metadata table/index references without applying exclusion matchers.
- Retained exact creator-current-set equality against each creator record's matched_mfas, and kept historical-baseline equality only for the evidence-supported EX-165 path. EX-089 current drift remains visible as additions/missing membership.
- Fixed the negative control to mutate the known two-member EX-010 live set while preserving cardinality.
- Applied current-export subset checks only to current original/replacement live sets; historical baseline and delivered scope members absent from current live membership remain explicit missing partitions.
- Kept global export data out of JSON serialization while checking row membership against the in-memory export.

The earlier red attempts were resolved before any broad selector ran: malformed multi-slash MFA suffix parsing; creator refs for the other lane incorrectly entering membership; an unsupported EX-089 current-set-equals-baseline assumption; metadata references passing through exclusion predicates; tuple-versus-string EX-165 baseline comparison; an empty-row negative-control target; and a compact-record subset guard that incorrectly required historical baseline and delivered members to be current. A first independent JavaScript artifact check also compared JSON tuple arrays by object identity, then assumed equal core/floor export counts; the corrected check compares tuple values and accepts each lane's measured inventory count. The initial bundle wrapper's shell-only exit mistake is recorded above; the corrected bundle run exited 0.

## Unchanged safety stops and remaining work

Static-only inventory evidence; no audited APIs, callbacks, atom sinks, runtime evaluation, or generated-code path. Stop on an actual-library collision. Preserve Macro caller-AST and explanation checkpoints. Candidate remains null, implementation authorization false, aggregate gate open, source join open, Walking Skeleton blocked, and SEC-01 Pending. Plans 03-02 through 03-05 remain unfinished.

## Self-check

Evidence files and this summary exist; the implementation commit is `12ecc239e0ac5d1f86e4bb24b5d512cc07c8404c`. Plan 03-01 checks and all safety gates are recorded above. The fit receipt covers only Plan 03-01 and is not a fit certificate for Plan 03-02. Nothing was pushed.

---
*Phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Completed: 2026-11-14; commit: 12ecc239e0ac5d1f86e4bb24b5d512cc07c8404c*
