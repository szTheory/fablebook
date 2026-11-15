---
phase: 03
plan: 03-03
date: 2026-11-15
status: bounded-replan; source-read gate closed
---

# Plan 03-03 bounded context replan

## Trigger and preserved scope

The prior 70,000-token working projection plus the fixed 31,000-token reserve
totaled 101,000, over the 100,000 ceiling. This replan keeps the existing two
tasks, five exact-source-file reads per task, full lane joins and complements,
all relevant target/caller/delegate evidence, review/fix/test gates, and every
existing safety stop. It does not add a phase or authorize implementation. The
untracked `03-03-SOURCE-SCHEDULE.md` remains an immutable failed count-only
review receipt; it is not approval to emit source text.

The current keyed evidence has incomplete source joins and caller coverage, so
no candidate is currently supportable. `candidate=null` with the exact missing
evidence and bounded remedy is a valid complete outcome. No callers, lane
members, complements, or other evidence may be dropped to obtain a fit.

## Hard context envelope

| Component | Maximum tokens |
|---|---:|
| Selected required documents, keyed lane evidence metadata, and execution framing | 46,000 |
| Task 03-03-01 exact complete source spans, including rereads | 10,000 |
| Task 03-03-02 exact complete source spans, including rereads | 6,000 |
| Generated output and bounded verification output | 5,000 |
| Post-count receipt/framing cushion | 2,000 |
| **Working envelope** | **69,000** |
| Fixed reserve | 31,000 |
| **Total hard ceiling** | **100,000** |

These are ceilings, not assumed measurements. Keep the five-file exact-source
limit independently for each task. Count every file read or reread. Counts,
unknowns, or remaining allowances may not be coerced to zero. If any required
source span or full caller context exceeds its task cap or the total envelope,
preserve the complete gap and use the no-candidate outcome.

## Source-span and emission gate

For `test/support/guard_aggregate_reconciliation_evidence.ex` and the relevant
regions of `test/contract/tier_sweep_test.exs`, first prepare a metadata-only
schedule: exact path and file SHA-256; complete function/test identity; inclusive
line start/end; line count; byte count; and SHA-256 of each complete span. The
756 KB test module must never be read or emitted as a full-file body. Do not
emit any implementation or candidate source text until all three conditions
hold for the exact current schedule and payload:

1. Independent schedule review passes and records the schedule digest.
2. `bin/planning_health --stage execute --phase 3` passes on the current checkout.
3. A fresh direct combined count covers the exact current required context,
   selected keyed evidence, schedule and review receipts, every scheduled span,
   current output allowance, 2,000-token cushion, and the 31,000-token reserve;
   its working total is at most 69,000 and total at most 100,000.

Repeat the count after any plan, schedule, receipt, or selected-input change and
before each new source emission. If a condition fails or the endpoint is
unavailable, keep source bodies un-emitted and stop at the precise gap.

## Permitted token-count methods

First use an already-installed, positively identified `tiktoken` with
`o200k_base.encode_ordinary` over exact UTF-8 text and preserved line endings.
If unavailable, the owner-approved no-cost fallback is exactly `POST
/v1/responses/input_tokens` for model `gpt-6-luna`, reusing only the existing
ignored `.env.local` credential. The key must never be printed, copied to an
artifact, or used for any other endpoint or purpose. Do not create or rotate a
key, install a dependency, or call a generation endpoint. Record the model,
endpoint, method, redacted harness/command, response count, and SHA-256 of the
exact serialized payload for every count request. If neither count method is
available, leave counts unknown and keep the source-emission gate closed.

## Verification and authority unchanged

Keep all original evidence criteria, two-lane focused checks, independent
review, accepted-fix and retest gates. Keep static-only proof, actual-library
collision stop, Macro caller-AST and wording checkpoints, aggregate open,
Walking Skeleton blocked, SEC-01 Pending, and `implementation_authorized=false`.
No fit result changes ownership, closes aggregate evidence, or authorizes later
implementation. No source body was read or emitted while preparing this replan.

## Independent plan/replan review — PASS

**2026-11-15.** The working-envelope arithmetic is consistent: 46,000 document,
evidence, and framing tokens + 10,000 Task 1 source tokens + 6,000 Task 2 source
tokens + 5,000 output tokens + 2,000 cushion = 69,000, plus the 31,000 reserve
= 100,000. Per-task five-file limits count reads and rereads; source caps are
10,000 and 6,000 tokens. Only complete, scheduled function/test spans may be
read; the full 756 KB test module is explicitly excluded. The count-only
fallback matches the previously approved `gpt-6-luna` input-token endpoint and
keeps the credential restricted to that purpose. Full lane joins, complements,
caller evidence, candidate-null behavior on gaps, static-only collection, the
actual-library collision stop, Macro checkpoints, aggregate-open state,
Walking-Skeleton block, SEC-01 Pending, and `implementation_authorized=false`
remain intact; the owner's later decision remains separate.

This review approves the plan/replan contract only. It does not authorize source
reads: each exact execution schedule still requires independent review, current
execute preflight, and a fresh direct combined count before any body is emitted.
