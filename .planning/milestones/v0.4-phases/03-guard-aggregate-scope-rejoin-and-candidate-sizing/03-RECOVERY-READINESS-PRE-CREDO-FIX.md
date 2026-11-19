# Phase 3 recovery readiness

**Recorded:** 2026-11-18 23:48 UTC  
**Checkout:** `/Users/jon/projects/fablebook`  
**Branch:** `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing`  
**HEAD:** `7317bd0ea112dbe9c2a60e15322ec6bfccc4681d`; no Git merge is in progress.  
**Plan:** 03-05 recovery; incomplete.

> This is a timestamped gate snapshot. Final test and delivery outcomes belong in `03-VALIDATION.md` and `.planning/STATE.md`; keep this bridge-bound snapshot unchanged after its review.

## State at this snapshot

R8 was consumed once and is the last authorized source request. The immutable R8 helper snapshot is 83,805 bytes, SHA-256 `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370`. Later changes are separate live-helper revisions; no source request was replayed or added.

Three focused core attempts found three consumer-binding defects, each preserved with its own failure receipt: R6 was still pinned after R8; the helper treated the manifest's live identity as the old snapshot; and the helper compared R8's old span offsets against the edited live file. The latest fix binds the current helper by its own hash/size, links its manifest input to the R8 snapshot through the revision receipt, and validates historical span bounds against R8's recorded file size/line count. It does not compare the old span bytes to the edited helper.

Cheap local checks currently pass: Phase 3 validator self-test (38 controls), the formatter check for the contract/helper, and targeted whitespace validation. The latest code review is pending. Phase 4 manifest, preservation bridge, evidence review and Phase 3 consumer crosswalk need refresh after the latest helper revision. The most recent successful Phase 4 package check and Phase 3 consumer check predate this final helper edit, so they are not current proof. No source-dependent suite has run on the latest helper revision.

## Current identities

| Artifact | SHA-256 | Bytes |
|---|---|---:|
| `test/contract/tier_sweep_test.exs` | `f66d5c7f8467b1665d4eb593808788ee151a6fccf3301de14bb170a6b9bdc439` | 780,065 |
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `add4fc21d05cc3ec2a4915b4ecfbb2976e0e95ad6ad800a215e5a3a916678585` | 86,689 |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-validate-evidence.py` | `8d39106a4431638fcd53ff3064c90f22bdecd31e9d63aebcf77ec72716ad7812` | 64,572 |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-T2-POST-R8-HELPER-REVISION.json` | `52d6d23017b80b4b432f188a630af02d419eff4fb9e0272089699cc63d38098b` | 4,201 |

## Preserved status and next action

Phase 4 record accounting remains 0 source associations, 9,716 typed gaps and 18 unknown target sets. Source resolution and legacy digest remain unresolved; caller closure is incomplete; candidate is null; implementation is unauthorized. R1/R4 remain incomplete, R2/R3/R5/R6/R8 are verified, and R7 delivery remains unverified and excluded.

The actual collision is unknown; aggregate gate remains open; Walking Skeleton is blocked; SEC-01 is pending; source access is closed. No safety stop changed. Next, finish independent review and rebind the manifest/bridge/evidence chain, pass the cheap Phase 3/4 validators on one generation, then rerun the focused core selection before broader suites. Codex continues; no owner action is needed now.
