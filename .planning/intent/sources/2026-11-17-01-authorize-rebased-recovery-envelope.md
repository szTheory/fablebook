---
id: INT-20261117-01
date: 2026-11-17
source: user
captured_by: Codex
supersedes: INT-20261116-01 and INT-20261116-05 resource ceiling only; all scope and safety stops remain
context: Owner accepted the recommendation to set a new hard ceiling before resuming and reconcile actual usage after each work wave.
---

# Authorize a rebased recovery envelope

## Verbatim owner reply

> follow ur recs

## Decision

The owner accepted the recommendation to establish a new bounded work envelope before continuing, with usage reconciled after each work wave. The selected evidence-only Phase 4 scope and bounded Phase 3 Plan 03-05 recovery remain the work; this reply does not change source-read gates, implementation authority, candidate status, or any safety stop.

Codex operationalizes that instruction as a **150,000 generated-output-token envelope** for Phase 4 provenance closure and the remaining Plan 03-05 work plus required review/verification. INT-20261117-02 records the owner's selection of the recommended post-review/preflight start point and resolves the reviewer's sole budget-boundary finding. The exact UTC start and initial balance are recorded in `../../forensics/phase4-budget-reset-20261117.md`. A fixed **31,000-token reserve remains protected**, leaving a maximum 119,000-token working allocation. The previously measured 191,582 output tokens and subsequent setup work remain sunk historical usage; they are not erased or reclassified, and their combined total is not claimed as measured. The new envelope cannot be increased automatically.

After each plan/task wave beginning inside the envelope, reconcile exact session input and output counts to the work performed; charge all new assistant output to the 150,000-token ceiling, record input/cached-input separately, and recompute the remaining balance before dispatching more work. Source request inputs still need their own exact direct count and must fit every compact-context, source-file, schedule, review, preflight, reserve, and no-truncation gate. If exact attribution or fit fails, close source access and stop with the precise missing evidence. Run cheap consistency checks before long tests.
