# Recovery budget renewal 3

Owner authorization: INT-20261117-06
Envelope: ENV-20261117-04
Starting checkout: /private/tmp/fablebook-phase3-remediation, branch gsd/phase-03-recovery-and-provenance-closure, HEAD 962e6f7
Effective baseline event: 2026-11-17T17:50:42.160Z

## Hard limits

- Total generated-output ceiling: 210,000 tokens.
- Protected reserve: 31,000 tokens.
- Working ceiling: 179,000 tokens across the parent and every child. Stop before it is crossed; no automatic renewal.
- Compact input ceiling: 34,000 tokens per exact request; retain the existing source-file, schedule, review, preflight, direct-count and no-truncation rules.

## Exact parent baseline

- Counter: `payload.thread_token_usage` only; compare the same field at every later read.
- Parent thread ID: `01a1e766-afb2-77a1-8977-350fde6d15dd`
- Session log: `~/.codex/sessions/2026/11/16/rollout-2026-11-16T21-47-09-01a1e766-afb2-77a1-8977-350fde6d15dd.jsonl`
- Latest persisted record time: 2026-11-17T17:50:42.160Z
- Baseline output: 903356
- Baseline input: 130132961
- Baseline cached input: 128100352
- A new child thread starts at zero. Any existing thread used for future work must be registered with its current same-field baseline before dispatch. Unknown, stale or unflushed threads block further dispatch.

## Remaining task allocations

- Plan 04-02 Task 1 lifetime cap: 40,000; prior measured use: 17,688; remaining task allowance: 22,312, including all new executor startup/context and task output.
- Plan 04-02 Task 2 cap: 18,000, including R1 source input, analysis, review and output; the 12,000 calibrated estimate is a projection, not permission. Output inside R1 remains at most 2,000.
- Plan 04-03 Task 1 lifetime cap: 22,700, including one 17,700 executor setup allowance plus up to 5,000 task work. Task 2 cap: 3,000.
- Plan 03-05 Tasks 2/3 combined cap: 31,700, including one 17,700 executor setup allowance plus the plan estimate of up to 14,000 generated-output tokens for remaining work. The plan table values 14,000 and 6,000 are raw context allocations, not output caps.
- At the 2026-11-17T18:11:09.907Z counter snapshot, ENV-04 had spent 64,394 (parent delta 50,746 plus the plan reviewer delta 13,648). Projected generated output for the remaining work is 84,100, including one 17,700 executor setup for each remaining plan; against the 179,000 work ceiling, this leaves 30,506 for further review, parent orchestration, verification and variance. Per-task caps use different measurement domains and must not be added as if they were output. Reconcile again before dispatch; estimates do not prove fit. Reconcile actual usage before each task and plan boundary.

## Scope and stops

This envelope covers only Phase 4 Plans 04-02/04-03 and Phase 3 Plan 03-05 Tasks 2/3. Task 03-05-01 already passed and must not be repeated. Before execution, reconcile the new caps into the executable plans and complete the independent budget-plan review. Phase 3 source-dependent work remains gated on Phase 4 validation and each exact source request’s written schedule, independent review, fresh execute preflight, direct count and verified cumulative fit. No implementation authority, new phase, production action or reserve use is granted.

## Updated execution snapshot and cost control

At 2026-11-17T18:20:37Z, same-field `payload.thread_token_usage.output_tokens` was 979,355 for the parent against baseline 903,356 (delta 75,999), and 17,101 for the completed plan-review child against baseline zero. ENV-04 spend was 93,100; 85,900 working tokens remain. The earlier 18:11 and 18:17 snapshots above are historical.

The 84,100 remaining-work forecast assumes one 17,700-output executor startup per remaining plan, leaving only 1,800 tokens for variance and wrap-up at this snapshot. To stay inside the approved ceiling, execute bounded plan tasks in the already-running session when their measured task caps permit, avoiding repeated startup output. This changes no scope, task cap, source gate, or reserve. Reconcile the live counters before and after each task; stop if either the aggregate or smaller task cap would be exceeded.


## Task-cap stop snapshot

At 2026-11-17T18:40:58.174Z, same-field ENV-04 usage is 159,613 output tokens total (142,512 parent plus 17,101 completed reviewer), leaving 19,387 working tokens. Plan 04-02 Task 1 has 47,918 output tokens since its recorded 18:26:26.813Z baseline plus 17,688 prior charged tokens: 65,606 against its 40,000 lifetime cap, over by 25,606. Execution stopped. The aggregate balance does not waive the task cap. See `phase4-task-cap-stop-20261117.md`; no source read or source-dependent suite occurred.
