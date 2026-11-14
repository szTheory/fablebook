---
phase: 03
plan: 03-01
task: 03-01-03
status: reviewed-awaiting-execution
updated: 2026-11-13
---

# Phase 03-01 Bounded Recovery Receipt

## Position and retained incident

- Checkout: canonical project root on branch `main`; v0.4 Phase 3, Plan 03-01, Wave 1. Planning updates remain local and unpushed; no new source-body evidence event has begun.
- Retired task 03-01-01 made 13 source-body events (nine in `tier_sweep_test.exs`, two in `installed_otp.ex`, two in `sweep_evidence.ex`), exceeding its five-event limit by eight. It produced no task changes, commits, or summary. The original identity excerpt and ASN.1 integration test body were not semantically read. The exact prior regions and the owner's stop/replan decision remain in the immutable [READ-LEDGER](03-01-READ-LEDGER.md) and [CHECKPOINT](03-01-CHECKPOINT.md).
- The owner authorized a re-plan within the existing per-task and context caps. No cap or authority is renewed by the retired attempt.

## Current task ceilings and source schedule

No semantic source-body event has occurred for tasks 03-01-03, 03-01-04, or 03-01-05. Count-only API transfers are listed separately below and do not count as semantic review.

| Task | Purpose | Actual semantic events | Maximum |
|---|---|---:|---:|
| 03-01-03 | Update recovery and prove fit | 0 | 0 |
| 03-01-04 | One-row core/floor tracer | 0 | 5 |
| 03-01-05 | Full identity and partition expansion | 0 | 4 |

03-01-04 uses the five bounded events in [03-01-PLAN.md](03-01-PLAN.md): the batched TierSweepTest regions, InstalledOtp regions, SweepEvidence regions, then a complete created collector capped at 3,000 tokens and the authored aggregate test region capped at 2,000 tokens.

03-01-05 uses four events: the completed aggregate test region capped at 3,000 tokens; the complete final collector capped at 4,000; ASN.1 integration lines 1–114; and the immutable original identity excerpt after validating its archived SHA-256. It reuses the complete pre-expansion source notes and authored patch from 03-01-04; it does not reread those bodies. No supplementary or fifth read is allowed. If a complete required region exceeds its token cap, stop before reading it, retain the gap, and re-slice without truncation.

## Measured context fit

The isolated-plan ceiling remains 100,000 tokens. The fixed reserve is 31,000, leaving 69,000 for selected planning inputs, exact scheduled source spans, future source-read maxima, and intermediate/output allowance. Task boundaries do not reset either limit.

The initial exact count for the selected bundle is:

| Count-only input transfer | GPT-6 Luna input tokens |
|---|---:|
| Selected planning inputs: state, config, verification, phase context, compact execution context, this recovery receipt, current plan, delivery/gate registries, safety ADRs, and only the matching archive-manifest row | 20,297 |
| Task 03-01-04 known source spans: TierSweepTest, InstalledOtp, and SweepEvidence ranges listed in the plan event table | 17,805 |
| Task 03-01-05 known source spans: ASN.1 integration lines 1–114 and the complete immutable original identity excerpt | 11,332 |
| **Measured combined baseline** | **49,422** |
| Four capped future source reads (3,000 + 2,000 + 3,000 + 4,000) | 12,000 |
| Intermediate notes, event receipts, and task output allowance | 5,000 |
| **Projected maximum in the 69,000-token working allocation** | **66,422** |
| **Unused working-allocation slack** | **2,578** |

The three group calls are separate count-only requests, so their standalone counts are not additive: 20,297 + 17,805 + 11,332 = 49,434. A direct combined request containing the full selected planning input and both scheduled known-span payloads returned 49,422. The 12-token difference comes from separate versus combined request framing/tokenization. Use the directly measured combined request (49,422) as the fit baseline; do not derive it by summing group calls or by applying an adjustment.

With the fixed 31,000-token reserve, the projected maximum is 97,422 of the 100,000-token ceiling. The planning-input transfer includes the compact execution note, this plan and recovery receipt, the selected state/config/verification/phase-context/receipt/ADR inputs, and only the matching archive-manifest row. Never load the full archive manifest. The known source-span transfers correspond to the exact paths/ranges in the plan event table. Recount before each future source event and update actual totals/slack; this initial measurement does not renew allowance if context or outputs grow.

The count-only method is `POST /v1/responses/input_tokens` for model `gpt-6-luna`. A harmless setup probe returned 11 tokens. The Personal-project key is in ignored `.env.local` with mode 600; no secret is recorded here. The count endpoint is free and produces no model response. The key's Request permission could incur charges if used on other model endpoints, so use it only for this count endpoint. Count-only path/range transfers are not semantic source events and must be logged separately.

## Safety and authority state

- No implementation source, archived identity excerpt body, ASN.1 integration body, or archived OTP body was opened for semantic review in the recovery task. No audited API, callback, atom sink, or generated-code path was invoked.
- Evidence remains static. Stop at any actual-library collision with its exact MFA, site, input trace, and triggering guard. Keep the Macro caller-AST and explanation-wording checkpoints in force.
- Keep `candidate=null`, `implementation_authorized=false`, `aggregate_gate=open`, Walking Skeleton blocked, and SEC-01 Pending with owner `controls-bundle:1`. No disposition, gate change, implementation authority, or automatic follow-on is created.

## Pause and next action

The independent plan checker passed the numeric bounds, compact cited context, and safety boundaries. Plan 03-01 remains paused before source work. The owner acts next by starting `$gsd-execute-phase 3` when ready; its first task only finalizes this recovery receipt and permits zero semantic source events. The tracer remains gated until that task finishes and the exact inputs are recounted. No code source was reviewed and no tests ran during planning.
