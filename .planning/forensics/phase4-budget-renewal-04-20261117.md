# Recovery budget renewal 4

Owner authorization: INT-20261117-07
Envelope: ENV-20261117-05
Checkout: `/private/tmp/fablebook-phase3-remediation`, branch `gsd/phase-03-recovery-and-provenance-closure`
Fresh baseline: 2026-11-17T18:46:55.030Z

## Hard limits

- Total generated-output ceiling: 440,000 tokens from this fresh baseline, extended under INT-20261117-07 after measured planning/review usage showed the initial headroom was insufficient.
- Protected reserve: 40,000 tokens.
- Working ceiling: 400,000 generated-output tokens across the parent and every child.
- No further automatic renewal. Stop before the working ceiling or a smaller task cap; keep the reserve untouched.
- Preserve the existing 34,000-token exact compact-request ceiling, five-source-file-per-task limit, no-truncation rule, and all source/implementation safety gates.

## Baseline and reconciliation

Counter: `payload.thread_token_usage` only, using the same fields at every boundary.

- Parent thread: `01a1e766-afb2-77a1-8977-350fde6d15dd`
- Parent log: `~/.codex/sessions/2026/11/16/rollout-2026-11-16T21-47-09-01a1e766-afb2-77a1-8977-350fde6d15dd.jsonl`
- Baseline event: 2026-11-17T18:46:55.030Z
- Baseline `output_tokens`: 1,057,978
- Baseline `input_tokens`: 143,829,369
- Baseline `cached_input_tokens`: 141,399,808
- ENV-04 final known snapshot at the same event: 171,723 output tokens used of 179,000 working; 7,277 remained. This old envelope is closed and is not carried as spend into ENV-05.
- The completed ENV-04 plan-cap reviewer is historical, with 17,101 output tokens already charged to ENV-04. Any new child starts at zero and must be recorded before further work.

## Replanned task caps

| Work | New cap | Measurement and setup |
|---|---:|---|
| Plan 04-02 Task 1 | 120,000 lifetime | 65,606 previously charged across ENV-03/04; 54,394 remains. Includes one 17,700 setup allowance and all remaining task output. The prior 40,000 and 100,000 caps are superseded by INT-20261117-07. |
| Plan 04-02 Task 2 / R1 | 50,000 combined request/work/review/output | Exact request input is at most 34,000; reserve 14,000 for analysis/review and 2,000 for R1 output. The validator must recompute `task_charge_tokens = serialized_input_tokens + analysis_review_allowance_tokens + output_allowance_tokens` and require the recorded components/total to fit 50,000 before access. |
| Provenance-bridge review | 20,000 output | Independent reviewer setup and complete review of the exact three preservation deltas, using hash-bound Task 03-05-01 command evidence; no R1 source analysis or body emission. |
| Plan 04-03 Task 1 | 30,000 output | Includes one 17,700 setup allowance and task work. |
| Plan 04-03 Task 2 | 10,000 output | Metadata-only final validation and handoff if upstream gates remain blocked. |
| Plan 03-05 Tasks 2/3 | 40,000 combined output | Includes one 17,700 setup allowance and up to 22,300 task output. Execute only after Phase 4 `--all` passes and each exact request clears its gate. |
| Parent orchestration and phase verification | 30,000 remaining output | Independent plan review is complete; its measured output is already included in current ENV-05 usage. Keep the remaining parent work bounded. |

Remaining output-only caps above total 184,394. R1 output up to 2,000 is separately included in its 50,000 combined request/work cap and is charged to the aggregate output ceiling when emitted. Thus the remaining output maxima are 186,394. The completed plan reviewer used 17,229 output tokens across its two review passes; this is sunk in ENV-05 usage, not counted again in the remaining maxima. The estimate does not guarantee that R1 or Phase 3 source work will pass its gates.

## Execution sequence and cheap stop conditions

1. Replan Phase 4 Plan 04-02 so the known preservation mismatches get a separately reviewed, hash-bound provenance bridge before any R1 schedule review or source request. Use the existing Plan 03-05 Task 1 hashes, formatter/test receipts, and blocked manifest; do not expose or analyze the R1 body to establish this bridge. Preserve the original manifest and stop receipt unchanged. If those records do not prove the three exact changes, stop source access and carry the blocker forward.
2. Finish and independently review the in-progress validator/ledger edits before relying on them. Run syntax and metadata-only self-tests first.
3. Run the bridge validator and Phase 4 metadata consistency checks. Only after the bridge passes, write a fresh exact R1 schedule and obtain independent review.
4. Run the exact Phase 4 execute preflight, direct no-generation request count, and live same-field usage fit in that order. Prove `serialized_input_tokens + 14,000 analysis/review allowance + 2,000 output allowance = task_charge_tokens <= 50,000`, while the exact input remains at most 34,000. Stop before source emission if any component or the sum is missing, inconsistent, or over its cap.
5. Run Phase 4 `--all` before any Phase 3 source-dependent checks. If Phase 4 remains blocked, Plan 03-05 Tasks 2/3 and their suites stay not-run.
6. At each task boundary, wait for child completion/counter flush, reconcile parent and all children, and compare task and aggregate caps. Missing attribution is a hard stop.

## Bridge feasibility audit

A read-only evidence audit returned PASS for whether the known three changes can be bridged without R1 body access. It verified all six old/current transfer and manifest hashes, the exact successful mutating formatter command on the two approved paths, clean formatter/diff checks, the five exact citation replacements, and the after-hash records. The five citation edits reproduce the current compact schedule bytes exactly. Evidence is bound to the parent session log `~/.codex/sessions/2026/11/16/rollout-2026-11-16T21-47-09-01a1e766-afb2-77a1-8977-350fde6d15dd.jsonl` and the transfer/readiness/manifest receipts. Event-group SHA-256 values: transfer `cacb6b834d4d7d3fd3639371cb83bac318780b3f58c1d86a46000e368f8313dc`; formatter and checks `fb968d1fbfe9a8014b342b93cbc97665011563585ae3c1514cce1d1cb2e51ef2`; citation edits `42ce18046e698b1f97dfadb6de3b60be4a83fc84fb29c85e9f7265a8a7a49cc0`; after hashes `11304097dc57fa05d4822524e8ac83cdbb7b02a0625c8b804d1c2a81f19dbbdf`. This audit establishes evidence sufficiency only. The bridge still needs its own detached review and validator pass; R1 source access remains closed.


## Earlier ENV-05 snapshot before independent plan review

Parent baseline: output 1,057,978 at 2026-11-17T18:46:55.030Z. Parent latest persisted record: output 1,113,184 at 2026-11-17T19:04:07.649Z (delta 55,206). The completed read-only provenance evidence audit thread `01a1ead9-74fe-7122-85b0-2678600cea2c` started at zero and ended at 8,726 output tokens at 2026-11-17T18:54:40.965Z. No other new child appears in the current collaboration tree. Reconcile again after the independent plan review completes.

## Reconciled ENV-05 usage immediately before independent plan review

Parent baseline: output 1,057,978 at 2026-11-17T18:46:55.030Z. Parent latest persisted record: output 1,134,095 at 2026-11-17T19:10:55.242Z (delta 76,117). The completed read-only provenance evidence audit thread `01a1ead9-74fe-7122-85b0-2678600cea2c` started at zero and ended at 8,726 output tokens at 2026-11-17T18:54:40.965Z. No other new child appears in the current collaboration tree. Total measured ENV-05 output is 84,843; 235,157 working tokens remain. After remaining output caps of 177,394 and maximum R1 output of 2,000, contingency is 55,763. Reconcile again after the independent plan review completes.

## Current ENV-05 usage before independent review dispatch

Parent baseline: output 1,057,978 at 2026-11-17T18:46:55.030Z. Parent latest persisted record: output 1,195,897 at 2026-11-17T19:34:41.492Z (delta 137,919). Completed child output: provenance evidence audit `01a1ead9-74fe-7122-85b0-2678600cea2c` = 8,726; two-pass plan review `01a1eaed-eb5b-7953-881e-a94e7060ebdb` = 17,229. Total measured ENV-05 output is 163,874. Under the extended 400,000 working ceiling, 236,126 remain. After the remaining 186,394 output maxima, 49,732 remain for measured variance and bounded retests. The 40,000 reserve remains separate. Reconcile all counters again immediately before executor dispatch and at every task boundary.
