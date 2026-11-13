# Phase 2: Bounded ASN.1 RTT guard evidence - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in `02-CONTEXT.md` — this log preserves the alternatives considered.

**Date:** 2026-11-12
**Phase:** 2-Bounded ASN.1 RTT guard evidence
**Areas discussed:** None — the approved scope and evidence gates already resolve the owner decisions.

---

No new gray area required an owner choice. The v0.3 scope, three-function selection, source/context/effort limits, static-only proof boundary, and unchanged safety gates are already locked by the cited intent and requirements. The live membership and lane source identity checks were completed as part of this discussion; connected-source sizing and itemized effort remain required before executable plans.

## the agent's Discretion

- Evidence-file organization, helper boundaries, task grouping within the five-source and plan limits, and the cheapest meaningful automated proofs, as already allowed by the inherited guard context.

## Deferred Ideas

- No new ideas were raised. Existing out-of-scope work remains recorded in `02-CONTEXT.md` and the carry-forward register.

## Owner-selected remedy and replan

The owner selected separate lane-owned evidence outputs so core and floor remain independent Wave 1 plans. Core owns `test/support/asn1_rtt_core_evidence.ex` and `test/contract/asn1_rtt_core_guard_test.exs`; floor owns `test/support/asn1_rtt_floor_evidence.ex` and `test/contract/asn1_rtt_floor_guard_test.exs`; integration owns the dedicated `test/contract/asn1_rtt_integration_test.exs`, with cross-lane evidence assertions inline. Existing `test/support/sweep_evidence.ex` remains the read-only approved archive resolver. Integration consumes lane evidence in Wave 2. Replanning recounts task-specific source reads including created-output rereads and reconciles context and effort while preserving scope and all gates. Final independent review is pending; execution remains stopped; no implementation or tests were run.


## Post-discussion planning gate outcome

After the discussion, the required connected-source closure, per-task context sizing, and itemized effort checks were completed and recorded as PASS in `02-RESEARCH.md`. Five two-task plans were drafted in four waves. Every task and plan estimate is below the 80,000-token planning target, and the 1.75–2.75-working-day critical path depends on core and floor running concurrently in Wave 1. The independent review is reconciling those updates. The approved three-function/two-lane scope and all existing safety and delivery stops are unchanged; no implementation or tests were run.

## Final plan review result

The second independent plan check passed after resolving three findings: core and floor use disjoint Wave 1 files; final-head hosted receipts are owned by phase verification/ship after plan summaries rather than written back into `02-CANDIDATE.md`; and the exact historical 13-MFA selection is an explicit fifth source read for integration Task 1. Plan 02-04's correction scope consistently covers the five approved evidence/test outputs. The effort estimate, including phase ship, remains 1.75–2.75 working days. Planning is complete and the plan set is ready for owner review. Implementation and tests remain unstarted.
