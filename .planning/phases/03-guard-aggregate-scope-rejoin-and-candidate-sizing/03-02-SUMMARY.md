---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
plan: "02"
subsystem: testing
tags: [aggregate-evidence, static-callers, source-provenance, lane-scope]
requires:
  - phase: 03-01
    provides: Complete lane identity rows, partitions, delivery receipts, and crosswalk
provides:
  - Per-live-MFA target source keys or explicit source gaps on both lanes
  - Lane-scoped selected caller edges, exact available citations, and explicit caller gaps
  - Phase-wide caller gap index that keeps the recommendation gate false
affects: [phase-03-plans-03-through-05, aggregate-guard-evidence]
actuals:
  tokens: 8130789
  tasks: 2
  commits: 3
commits: 3
plan_head_before: a9fe24c50c144d5e9e252408d14aec8a13ea2b3f
plan_head_after: 3c3578fd484ee8dcd89f5da92b0380f0d17f59a1
tech-stack:
  added: []
  patterns: [lane-qualified static edge keys, keyed per-MFA gaps, fail-closed recommendation gate]
key-files:
  created: [.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-02-SUMMARY.md]
  modified: [test/support/guard_aggregate_reconciliation_evidence.ex, test/contract/tier_sweep_test.exs, .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json, .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json, .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md, .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-02-SOURCE-SCHEDULE.md]
key-decisions:
  - "Only preserve caller edges whose lane and hash-scoped source evidence match; all other targets retain keyed gaps."
  - "A saved EX-010 projection is limited historical evidence, not a complete current graph or proof of dynamic-caller absence."
  - "Any source, graph, callback, or delegate gap keeps candidate null and the recommendation gate false."
patterns-established:
  - "Graph-edge records include stable lane-qualified keys, exact MFA identities, source keys, and available citation links."
  - "Caller evidence records distinguish a scoped observed edge from missing current graph coverage and unproven dynamic boundaries."
requirements-completed: [GSR-01, GSR-02, GSR-03, GSR-04, GSR-06]
coverage:
  - id: D1
    description: Every live target on core and floor has an exact source key or an individual lane-specific gap.
    requirement: GSR-01
    verification:
      - kind: unit
        ref: "bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_sources --warnings-as-errors"
        status: pass
      - kind: unit
        ref: "bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_sources --warnings-as-errors"
        status: pass
    human_judgment: false
  - id: D2
    description: Selected EX-010 graph edges link to exact lane source identities and available delegate citations; all remaining current-graph and callback uncertainty stays in keyed gaps.
    requirement: GSR-02
    verification:
      - kind: unit
        ref: "FABLEBOOK_GUARD_AGGREGATE_CALLER_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_callers --warnings-as-errors"
        status: pass
      - kind: unit
        ref: "bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_callers --warnings-as-errors"
        status: pass
    human_judgment: false
  - id: D3
    description: Both lane records and the report retain Plan 03-01 partitions and unchanged stops, while any required gap blocks recommendation.
    requirement: GSR-04
    verification:
      - kind: other
        ref: "Keyed Python equality and crosswalk digest/count checks against Plan 03-01 commit 12ecc23"
        status: pass
    human_judgment: false
# Metrics
duration: "not reconstructed across resumed sessions"
completed: 2026-11-14
status: complete
---

# Phase 3 Plan 2: Guard Source and Caller Reconciliation Summary

Every live target now has an exact lane-scoped source identity or a per-MFA gap; the selected EX-010 caller edges retain their pinned source links while the unavailable full graph remains an explicit blocker.

## Performance

- **Duration:** Not reconstructed across resumed sessions.
- **Started:** Not recorded.
- **Completed:** 2026-11-14.
- **Tasks:** 2.
- **Files modified:** 6 plan files; this summary is the seventh unique plan artifact.

## Accomplishments

- Completed source mapping for 1,763 core and 1,718 floor live targets. Each target is attached to a verified lane source key or a precise row/MFA source gap; the generated source crosswalk contains 3,477 gaps.
- Added stable caller-edge and delegate-path records for the two selected EX-010 MFAs on each lane. Edge records link the exact lane source identities, delegate path keys, and available citations. The stored graph observation covers only the selected EX-010 projection.
- Added explicit current-graph, callback/delegate, and source gaps for unresolved coverage. The crosswalk contains 3,481 target rows and 10,439 required caller gaps. Missing coverage is not described as an empty caller set or runtime safety evidence.
- Preserved all Plan 03-01 identity, membership, partition, owner, and delivery receipt subtrees. Candidate remains null, implementation authorization remains false, aggregate gate remains open, Walking Skeleton remains blocked, and SEC-01 remains Pending.
- Kept graph and lane metadata on disk, selected only keyed EX-010 rows for the agent context, and did not invoke audited targets or read additional source bodies.

## Context Budget and Source Scope

- Task 1 scheduled source payload: 6,253 tokens; Task 2 approved spans: 4,892 tokens; total: 11,145 of 17,000.
- The reviewed Task 2 schedule covered six complete spans in three files. Its independent review passed, execute preflight passed, and the pre-emission direct count was 60,026 tokens.
- A second count including the selected on-disk graph-observation keys returned 60,661 tokens. With 1,108 remaining Task 2 source tokens, 5,000 output tokens, and a 2,000 cushion, the working projection was 68,769/69,000. The unchanged 31,000 reserve brought the total to 99,769/100,000.
- The 60,661 recount happened after the approved source spans were emitted, when graph metadata was identified as additional context. This sequencing deviation used 635 tokens of the existing cushion; the refreshed total remained within the hard bound. No additional source body was read.
- The realized plan diff is 32,523,159 characters. Actuals use the required `chars/4` scale (8,130,789 tokens); this artifact-size figure is not the measured model context count.

## Verification

- Both modified Elixir files passed the formatter check.
- `git diff --check` — passed.
- `bin/planning_health --stage execute --phase 3` — passed before Task 2 acquisition and at plan completion.
- Task 1 focused core source selector — 1 passed, 105 excluded, 55.3s; focused source writer and integrity checks also passed on both lanes. The prior core aggregate selector reported 5 passed, 101 excluded, 60.5s.
- `FABLEBOOK_GUARD_AGGREGATE_CALLER_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_callers --warnings-as-errors` — 1 relevant test passed, 106 excluded, 61.6s; it wrote both lane records and the crosswalk report.
- `bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_callers --warnings-as-errors` — 1 relevant test passed, 106 excluded, 43.0s.
- Keyed post-write checks passed for exact source keys/citations, observation-file digests, unique per-MFA records/gaps, crosswalk row/gap counts, equality with Plan 03-01 partitions, and unchanged safety stops.
- All final focused selectors used `--warnings-as-errors`; their summaries reported no warnings.

## Task Commits

1. **03-02-01 source links and gaps** — `16c929c` (`test`).
2. **03-02-02 RED caller contract** — `2ff63f4` (`test`).
3. **03-02-02 GREEN caller evidence and gaps** — `3c3578f` (`feat`).

No push was made. The measured plan commit count is three from baseline `a9fe24c50c144d5e9e252408d14aec8a13ea2b3f` through plan head `3c3578fd484ee8dcd89f5da92b0380f0d17f59a1`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed caller-cycle identity to include MFA arity.**
- **Found during:** Task 03-02-02 negative controls.
- **Issue:** A reverse edge for `inets_trace:enable/2` initially marked the separate `/3` edge as cyclic because cycle detection compared only module/function names.
- **Fix:** Cycle keys now compare full lane-qualified MFAs; the two-edge mutation reports exactly two cycle-marked edges.
- **Files modified:** `test/support/guard_aggregate_reconciliation_evidence.ex`, `test/contract/tier_sweep_test.exs`.
- **Verification:** Final focused core write selector passed with `--warnings-as-errors`.
- **Committed in:** `3c3578f`.

**2. [Rule 1 - Bug] Corrected caller-test module loading and evidence assembly.**
- **Found during:** Task 03-02-02 focused runs.
- **Issue:** The initial check asked `function_exported?/3` before loading the module, and the writer omitted the source crosswalk when validating the combined report.
- **Fix:** Load the module before the assertion and include both source and caller crosswalks before report validation.
- **Files modified:** `test/contract/tier_sweep_test.exs`.
- **Verification:** Final core writer and floor focused selectors passed; report rows and gaps matched keyed lane records.
- **Committed in:** `3c3578f`.

**3. [Rule 1 - Bug] Matched stop checks to the existing record schema.**
- **Found during:** Task 03-02-02 focused run.
- **Issue:** The test treated `sec_01` and `walking_skeleton` as nested maps though the records store their statuses as strings.
- **Fix:** Assert the existing string values directly.
- **Files modified:** `test/contract/tier_sweep_test.exs`.
- **Verification:** Final focused core and floor selectors passed.
- **Committed in:** `3c3578f`.

### Count Sequencing Deviation

The pre-emission 60,026-token count included the approved source ranges and selected lane evidence. After reading those spans, the selected graph-observation keys needed for the edge joins were recognized and included in a second direct count (60,661). The refreshed projection remained within the working cap and reserve; no source allowance or safety stop was changed. The schedule receipt records this order explicitly.

## Issues Encountered

- The focused test setup writes large `FABLEBOOK_OTP_INVENTORY_V2` records to stdout. All test output was redirected to local logs and only filtered ExUnit summaries were surfaced.
- No current complete two-lane graph snapshot was present among the approved on-disk observations. Only the saved EX-010 projection could be linked; every other MFA and current graph freshness remains a keyed gap.

## User Setup Required

None.

## Next Phase Readiness

Plan 03-03 may consume these lane records and explicit gaps. Any unresolved source, current graph, callback, or delegate gap continues to block candidate recommendation. The aggregate and implementation gates remain open/false, and the existing owner collision and Macro stops remain binding.

## Self-Check: PASSED

- Task 1, RED, and GREEN commits are reachable from the recorded plan baseline.
- Both lane evidence records and the crosswalk report were regenerated and passed keyed identity/provenance/count checks.
- The plan head and measured commit count are recorded in frontmatter; no changes were pushed.

---
*Phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Completed: 2026-11-14; plan head: 3c3578f*
