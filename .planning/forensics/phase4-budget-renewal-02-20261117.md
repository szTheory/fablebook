# Recovery budget renewal 2

Owner authorization: INT-20261117-05
Envelope: ENV-20261117-03
Starting checkout: /private/tmp/fablebook-phase3-remediation, branch gsd/phase-03-recovery-and-provenance-closure, HEAD 30060b7
Effective at: 2026-11-17T16:11:11.228Z
Ceiling: 90,000 generated-output tokens; reserve 31,000; working ceiling 59,000.

## Prior envelope stop

The previous 80,000-token envelope used 60,773 parent output tokens by 16:11:11.228Z (baseline 722,634; current 783,407) and no new child output (child remained at its 81,800 baseline). This exceeded its 49,000 working ceiling by 11,773 and entered the protected reserve. No Phase 4 execution task had started. Preserve the earlier receipts.

## New measured baseline

- Parent thread 01a1e766-afb2-77a1-8977-350fde6d15dd: 783,407 cumulative output tokens at 16:11:11.228Z; log ~/.codex/sessions/2026/11/16/rollout-2026-11-16T21-47-09-01a1e766-afb2-77a1-8977-350fde6d15dd.jsonl.
- Existing executor child 01a1e9c9-1241-7733-b115-68ff213e25db: 81,800 cumulative output tokens at 14:47:41.639Z; log ~/.codex/sessions/2026/11/17/rollout-2026-11-17T08-53-51-01a1e9c9-1241-7733-b115-68ff213e25db.jsonl.
- New child sessions start at zero. Subtract each baseline once and include all later thread output.

This covers only Phase 4 plans 04-02/04-03 and Phase 3 Plan 03-05 Tasks 2/3. Existing 49,000 plan ceilings leave at most 10,000 for execution overhead inside the 59,000 work ceiling. Reconcile at each plan boundary and before each source emission. Stop at 59,000 total spend; preserve the reserve and do not auto-renew.

Preflights for Phase 3 and Phase 4 plan/execute stages passed immediately before this renewal. Source access and Phase 3 source-dependent suites remain gated by the exact schedule, independent review, execute preflight, fresh direct count, measured fit, and Phase 4 consumer validation.
