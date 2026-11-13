# Phase 2 Local Readiness Evidence

This file records local validation evidence for the Phase 2 candidate. Both required full-suite commands passed on PR-shaped merge checkout `3c87cdb0e1ba20eaefa50d4b918b8970b006bcfd`, with prerequisite PR #87 as first parent and Phase 2 source commit `a391b0dcb0fa5c82502b2d7e1399da0b1355ad33` as second parent. The candidate branch subsequently received a documentation-only readiness update. Hosted CI for the Phase 2 PR and actual merge/main receipts remain pending.

local_readiness: PASS — both required full-suite commands passed.
candidate_source_head_at_test: a391b0dcb0fa5c82502b2d7e1399da0b1355ad33
local_tested_head: 3c87cdb0e1ba20eaefa50d4b918b8970b006bcfd
local_tested_merge_head: 3c87cdb0e1ba20eaefa50d4b918b8970b006bcfd
core_command: `GITHUB_EVENT_NAME=pull_request bin/lane core test --warnings-as-errors --include prod_guard`
core_result: PASS — Elixir 1.20.4 / OTP 29.1.2; 442 passed, 14 excluded; 1301.0 seconds.
floor_command: `GITHUB_EVENT_NAME=pull_request bin/lane floor test --warnings-as-errors --include prod_guard`
floor_result: PASS — Elixir 1.18.5 / OTP 27.3.4.9; 456 tests, 0 failures, 6 excluded; 636.7 seconds.
act_outcome: ATTEMPTED — `act --list -W .github/workflows/ci.yml` failed schema validation because the installed `act` rejects the workflow's hosted Actions `concurrency.queue` property at line 167; Docker is available. No local Actions jobs ran.
prerequisite_hosted_ci: PASS — PR #87 (`gsd/phase2-planning-tests`) at head `2768a58a2dea1d58055c950aac2c30b3bb17e87a`; [hosted run 276](https://github.com/szTheory/fablebook/actions/runs/43355783802) completed green.
phase2_hosted_ci: PENDING — the Phase 2 PR has not yet been opened; hosted core/floor receipts must be bound to its final reviewed head.
review_disposition: CLOSED — `.planning/phases/02-bounded-asn-1-rtt-guard-evidence/02-REVIEW.md` reports no open high-severity finding; accepted review fixes are closed.
security_disposition: STATIC ONLY — review preserves the actual-library collision stop. No runtime behavior, dynamic-caller absence, native-internals safety, complete EX-107 row, aggregate closure, Walking Skeleton, or SEC-01 completion is established. Walking Skeleton remains blocked and SEC-01 remains Pending.
delivery_handoff: Local readiness passed on the tested merge tree; final candidate head and hosted receipts are pending phase verification/ship. Phase verification/ship must rerun required checks on the final pushed candidate head, reconcile hosted core/floor receipts against that PR head, and record actual merge/main evidence. GRC-04/GRC-05/GRC-06 and wider safety gates remain open until their own acceptance evidence is complete.

## Local Run Details

- Both lane commands used the same source tree and PR-shaped merge checkout. `GITHUB_EVENT_NAME=pull_request` makes the diff-boundary check use the merge commit's first parent, the test-only prerequisite branch, matching the stacked PR base.
- The candidate includes the complete numbered intent corpus, including the preserved owner source `2026-11-11-12` and its linked Clinicly handoff note.
- The core test helper marks the floor-owned RTT suite with `@moduletag :floor`, so core excludes those source-specific checks and floor includes them.
- The slow source, receipt, and citation checks have bounded per-test timeouts where needed. The CN-004 test passed at its existing default timeout on the uncontended full core run.
- The `act` attempt was supplementary only and ran no workflow jobs; hosted CI remains the required receipt source.
- The tested merge head is not the final Phase 2 PR head. Final candidate and merged-main evidence remain pending phase verification/ship.
