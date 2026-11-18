# Phase 4 recovery budget renewal — ENV-20261117-06

**Recorded:** 2026-11-17T20:04:51Z  
**Checkout:** `/private/tmp/fablebook-phase3-remediation`  
**Branch:** `gsd/phase-03-recovery-and-provenance-closure`  
**Owner authorization:** INT-20261117-08  
**Scope:** Continue the already approved Phase 3 recovery prerequisite through Phase 4 provenance closure, preserving every existing source and delivery gate.

## Bounded envelope

- Generated-output ceiling: 540,000 tokens, measured from the existing ENV-05 baseline; usage is not reset.
- Working ceiling: 500,000 tokens across the parent and all child sessions.
- Protected reserve: 40,000 tokens; do not spend it.
- No further automatic renewal. Any later limit change requires a new explicit owner direction.

## Reconciled usage at the replan

ENV-05 parent baseline: 1,057,978 output tokens at 2026-11-17T18:46:55.030Z. At the 20:04:51 snapshot, the parent was at 1,289,589 (delta 231,611), and the two completed ENV-05 children added 8,726 and 17,229. That historical snapshot totaled 257,566 used.

At the latest reconciled snapshot (2026-11-17T20:30:04.820Z), the parent was at 1,367,549 (delta 309,571 from the ENV-05 baseline). Including the completed provenance audit (8,726) and the plan review's full measured output (50,123), cumulative ENV-06 usage is 368,420 and the working balance is 131,580. The review emitted 32,894 during ENV-06, 12,894 above its 20,000 allowance; record that as sunk usage and do not repeat the review. For conservative task accounting, charge all 136,967 parent-output tokens since the 19:46:08 snapshot to Plan 04-02 Task 1, including setup, diagnostics and replan edits. Its cumulative measured charge is 202,573 against the revised 220,000 lifetime cap, leaving at most 17,427 at this snapshot. Charge the 32,685 parent-output delta from 19:34:41 to 19:46:08 to orchestration and replan work; its 50,000 cap leaves 17,315. These are the last exact counters available; deduct all later generated output before authorizing work at a task boundary.

## Remaining reviewed caps

| Work | Remaining output or combined cap | Basis |
|---|---:|---|
| Plan 04-02 Task 1 | at most 17,427 output | Revised 220,000 lifetime cap less 65,606 prior charge and 136,967 continuation charge |
| R1 request/work/review | 50,000 combined; at most 16,000 generated output | Exact serialized input ≤34,000 + 14,000 analysis/review + 2,000 output; do not double-count input as generated output |
| Plan 04-03 Tasks 1–2 | 40,000 output | Existing 30,000 and 10,000 task caps |
| Phase 3 Plans 03-05 Tasks 2–3 | 40,000 output | Existing combined cap, still gated on Phase 4 |
| Parent orchestration and phase verification | 17,315 output | Revised 50,000 cap less 32,685 charged |

Remaining output maxima total 130,742. They leave only 838 against the 131,580 working balance if every ceiling is consumed, so do not treat ceilings as a forecast. The plan's calibrated estimates instead project 5,000 task output plus the existing 17,700 executor setup for Plan 04-03 Task 1, 10,000 for Task 2, 14,000 for Phase 3's remaining work plus one 17,700 executor setup, and the full 16,000 R1 generated-output allowance. Including the 17,427 Task 1 and 17,315 parent ceilings, that forecast is 115,142 and leaves 16,438 working contingency at this snapshot, separate from the protected 40,000 reserve. No additional independent reviewer or long suite is in this forecast. Before any task boundary or gated request, reconcile the same `payload.thread_token_usage` fields and require the remaining balance to cover the specific measured next work plus at least 10,000 contingency; if current counters are unavailable, keep source access closed and perform only metadata-only work.

## Execution gates and newly found input drift

The immutable blocked manifest has exactly three known preservation mismatches. Its historical `inputs[]` also binds an older SHA-256 for `03-05-PLAN.md`; the current plan hash differs, and the exact prior bytes are not present in the recovery checkout or available Git revisions. Preserve that old binding in the original manifest and report it as stale. The new supported generation must bind the current plan bytes explicitly and record this as a separate metadata-input rebind. A reviewer must confirm that the rebind does not change the retained authority or selector evidence. If that cannot be established, keep R1 and Phase 3 source work not-run.

The preservation bridge remains limited to the three listed file deltas; it must not absorb the stale plan input. The active supported partition validates the refreshed input hashes, bridge hash, exact record membership, and unchanged source-access-closed status. Only after the bridge review and these checks pass may the fresh R1 schedule be reviewed, Phase 4 execute preflight run, the exact request be directly counted without generation, and cumulative fit be checked. No helper body is emitted before all gates pass. No source-dependent suite runs until the bridge, supported partition, schedule, preflight, count, and cap-fit checks pass.

**Exit:** Complete the reviewed tasks within ENV-06 and preserve truthful blocked receipts if any gate fails. No automatic renewal, safety-stop waiver, Phase 3 completion, delivery, push, or PR is included.
