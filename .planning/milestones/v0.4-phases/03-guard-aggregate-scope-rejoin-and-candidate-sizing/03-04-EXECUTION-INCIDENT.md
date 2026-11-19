# Phase 03-04 Task 2 source-search incident

## What happened

During executor preparation for the owner-approved target-source trace, an `rg -n` source search ran before the new schedule review and fresh direct count. It searched these two files:

- `test/support/guard_aggregate_reconciliation_evidence.ex`
- `test/contract/tier_sweep_test.exs`

The search terms were `target_source_coverage_complete`, `target_source_gaps`, `source_record`, `associations`, `source_join_complete`, `acquire_target`, and `target_source`. The command also followed a bounded SIZING JSON projection and the last 85 lines of the replan receipt.

The executor reported original tool-output size of 10,353 tokens. The output was truncated and not saved, so its exact source lines, complete output, and content hash cannot be recovered from the available receipt. No code or test files were edited and no tests ran in that executor turn. The output was not repeated.

## Conservative accounting and authorization

Charge the full 10,353 reported output tokens to Task 03-04-02 source usage. This is an upper-bound accounting charge, not a claim that the exact source selection was measured. With the V20 baseline of 2,387 tokens, charged cumulative Task 2 source usage is 12,740.

Under [INT-20261115-02](../../intent/sources/2026-11-15-02-authorize-phase3-recovery-envelope.md), the one-time Phase 3 envelope is 110,000 total tokens: context 34,000; Task 1 source 22,000; Task 2 source 16,000; Task 3 new reads 0; cumulative output 5,000; cushion 2,000; fixed reserve 31,000. This leaves 3,260 Task 2 source tokens for the scheduled trace/correction. The five-source-file task cap remains unchanged.

## Execution status

The incident does not authorize further source emission. Candidate remains `null`; the corrected report remains unpublished; Plan 03-05 remains unstarted; and every static-only, collision, Macro, authority, and aggregate-gate stop remains in force. Before any new source body is emitted, bind the incident charge and current SIZING hash into the exact source schedule, obtain independent schedule review, rerun execute preflight, and pass a fresh direct count for the complete active ledger.
