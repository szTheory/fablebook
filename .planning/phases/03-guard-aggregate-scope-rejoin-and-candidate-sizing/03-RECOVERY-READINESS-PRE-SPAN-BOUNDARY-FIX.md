# Phase 3 recovery readiness

**Recorded:** 2026-11-18 23:31 UTC  
**Checkout:** `/Users/jon/projects/fablebook`  
**Branch:** `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing`  
**HEAD:** `7317bd0ea112dbe9c2a60e15322ec6bfccc4681d`; no Git merge is in progress.  
**Plan:** 03-05 recovery; incomplete.

> This is a timestamped gate snapshot. Final test and delivery outcomes belong in `03-VALIDATION.md` and `.planning/STATE.md`; keep this bridge-bound snapshot unchanged after its review.

## Current state at this snapshot

R8 was consumed once and is the last authorized source request. The R8 helper span remains the immutable pre-edit observation (83,805 bytes, SHA-256 `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370`). Later helper edits are bound as a separate revision; no source request was replayed or added.

The first focused core run exposed a stale R6 request ID; the fix exposed a second stale assumption that the manifest helper row still equaled the R8 snapshot. The corrected helper now checks the current live identity and the nested revision link to R8. The second failure is preserved in `03-05-CORE-FOCUSED-R8-RETEST-FAILURE.json`; the earlier failure remains in `03-05-CORE-FOCUSED-R8-FAILURE.json`. Neither failed run was retried before its cause was fixed.

Cheap checks currently pass: Phase 3 validator self-test (34 controls), formatter check for the contract/helper, and targeted whitespace check. The Phase 4 manifest, bridge and final review still need rebinding to the new helper/revision identities; the earlier successful Phase 4 and consumer receipts predate this final helper edit and are not current. No source-dependent suite has been run on this final revision.

## Current identities

| Artifact | SHA-256 | Bytes |
|---|---|---:|
| `test/contract/tier_sweep_test.exs` | `f66d5c7f8467b1665d4eb593808788ee151a6fccf3301de14bb170a6b9bdc439` | 780,065 |
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `2ee75c2c70990314f8d8905f26d7f074f21cc506159198184a34582297b44999` | 86,734 |
| `03-05-validate-evidence.py` | `3abf579454598fd52ec7bf16db7d0fa53ded00bf183ff82086fe5f1b0d1c1567` | 61,844 |
| `03-05-T2-POST-R8-HELPER-REVISION.json` | `40641260db427327b15c6b596a8b7e55726426e628e185d4ff01eacbc40cb625` | 2,995 |

The live helper update is still limited to the already authorized helper span. It changes how the consumer validates the current manifest identity and revision receipt; it adds no source resolution, caller closure, digest, candidate or implementation claim.

## Preserved status and next action

Phase 4 still records 0 source associations, 9,716 typed gaps and 18 unknown target sets. Source resolution and legacy digest remain unresolved; caller closure is incomplete; candidate is null; implementation is unauthorized. R1/R4 remain incomplete, R2/R3/R5/R6/R8 are verified, and R7 delivery remains unverified and excluded.

The actual collision is unknown; aggregate gate remains open; Walking Skeleton is blocked; SEC-01 is pending; source access is closed. No safety stop changed. Next, complete independent review and exact manifest/bridge/evidence rebinding, pass the cheap Phase 3/4 validators on one generation, then rerun the focused core selection before any broader suite. Codex continues; no owner action is needed now.
