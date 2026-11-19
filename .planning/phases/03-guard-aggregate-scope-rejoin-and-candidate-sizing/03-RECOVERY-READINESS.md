# Phase 3 Recovery Readiness — final local Plan 03-05 gates

**Observed at:** 2026-11-19T01:01:31Z  
**Checkout:** `/Users/jon/projects/fablebook`, branch `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing`, HEAD `7317bd0ea112dbe9c2a60e15322ec6bfccc4681d`; dirty primary checkout preserved.  
**Status:** Plan 03-05 local execution gates pass on the recorded current code and evidence identities. Phase goal verification, security closeout, hosted candidate CI, merge/main CI, and delivery remain separate and pending. This report does not claim phase delivery.

The owner-authorized Phase 4 R8 request was consumed once. Its immutable helper snapshot is 83,805 bytes, SHA-256 `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370`; observed span bytes `[63660,71408)`, lines 1748–1923, SHA-256 `2861e6e06895760381c8ae3bd0fa7e5d9bc126493fc1173cb4ddbeaaec147682`. No source body was reread and no request was replayed. The current helper includes only the documented post-observation revisions: binding fixes and four digit separators whose integer values are unchanged. R8 is the final authorized source request; source access is closed.

## Tested code identities

| File | SHA-256 | Bytes |
|---|---|---:|
| `test/contract/tier_sweep_test.exs` | `f66d5c7f8467b1665d4eb593808788ee151a6fccf3301de14bb170a6b9bdc439` | 780065 |
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `2b6eb2b1033ad429edc6f751ed2f55298a272610123085027c87ece59b379fdb` | 86693 |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-validate-evidence.py` | `8d39106a4431638fcd53ff3064c90f22bdecd31e9d63aebcf77ec72716ad7812` | 64572 |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-T2-POST-R8-HELPER-REVISION.json` | `6049a4dcd6dd73835a8bef6e9f60bb08de577b2958a0cdaa8900b7a81f07f8dc` | 5676 |
| `.planning/intent/sources/2026-11-18-04-authorize-one-recovery-request.md` | `280e09e00975ad56ffa03df08ac2b683ccb47df762065f0c224e7f0ac803c088` | 783 |

The pre-final-tests intermediate snapshot is preserved as `03-RECOVERY-READINESS-PRE-FINAL-TESTS-20261119.md`. The original failed `03-READINESS.md` also remains unchanged.

## Cheap gates and evidence consistency

Before the long lanes, the Phase 4 and Phase 3 provenance validators, helper self-tests, formatter, strict Credo, and consumer checks passed. Phase 3 self-test exercised 38 controls; Phase 4 self-test exercised 69 controls. Phase 4 validation returned `pass_with_open_gaps`; the Phase 3 `--phase4-only` and `--consumer` checks passed with source access closed. The generated partition contains 9,716 typed gap rows, zero source associations, 18 unknown target sets, and zero stale current bindings. The result means the typed records are internally complete; it does not mean the unresolved sources or callers were proven.

The Phase 3 execute preflight and Phase 4 execute preflight both passed. Formatting passed for the two changed Elixir files, strict core Credo passed, and the intent corpus focused check passed (22 tests, 0 failures). The targeted `git diff --check HEAD` for the changed Elixir, intent, validation, summary, and state files exited 0. A prior whole-tree check exited 2 on inherited trailing whitespace in historical planning and forensics artifacts; that known broad failure was not repeated.

## Focused and full local suites

| Check | Result | Receipt and full log |
|---|---|---|
| Core focused aggregate contract | 9 passed, 100 excluded; 60.0 seconds | `03-05-CORE-FOCUSED-R8-FINAL4-PASS.json` (`b7fd9a3886bc7e176be7bd20efe456e0f108f4ddbef2bb9bb3fe46c43020a7de`); `/private/tmp/fablebook-phase3-core-focused-R8-final4-full.log` (`1584deff88030b780ed1f6f3ab3bfe75a8d547cc48ee913f9caffc7697782f76`, 60,438,291 bytes) |
| Floor focused aggregate contract | 9 passed, 100 excluded; 53.6 seconds | `03-05-FLOOR-FOCUSED-R8-FINAL2-PASS.json` (`c0ef2144be12b90ad9796beee7b9b6719b4ccf7d8ba4b7ae9658f65319e58630`); `/private/tmp/fablebook-phase3-floor-focused-R8-final2-full.log` (`e9e1f7ba90674b878e171a54e353e4385c58ed1227838117214f1bb7e937ce35`, 54,871,992 bytes) |
| Core CI | 459 passed, 10 excluded; test stage 403.5 seconds, total 413 seconds | `03-05-CORE-CI-R8-FINAL3-PASS.json` (`c236344efa8136e8e5777b29300bf620b8aabb8562ac4065c517514c857dc1c3`); `/private/tmp/fablebook-phase3-core-ci-R8-final3-full.log` (`f06c233cefca99e48b5f0dd06b1878a8d781f27f4748ca1620d092b2edfd9b1c`, 60,443,179 bytes) |
| Full floor suite | 467 passed, 0 failed, 2 excluded; 403.2 seconds | `03-05-FLOOR-FULL-R8-FINAL1-PASS.json` (`f474dfef445102d520590e958bfa4ee29843252c9da8e1e9ccd641b7881af956`); `/private/tmp/fablebook-phase3-floor-full-R8-final1-full.log` (`e38a4895560e2a209d377060ac6beac573ef2c821e63291af2d8dfcb67c756c1`, 54,876,346 bytes) |

## Failures and repairs preserved

- The first core CI attempt stopped at strict Credo on four integer literals written without digit separators; no test stage ran. The helper-only formatting revision added separators without changing values. See `03-05-CORE-CI-R8-FAILURE.json` and `03-05-T2-POST-R8-HELPER-REVISION.json`.
- A later core CI attempt reached the planning corpus and found that the existing owner authorization note used bullet metadata where the corpus requires YAML frontmatter. Its metadata was normalized while preserving the exact owner reply and approved scope; no test assertion or guard was changed. The focused intent check then passed 22/22, followed by the final green core CI run. See `03-05-CORE-CI-R8-FINAL2-FAILURE.json` and `03-05-INTENT-CORPUS-R8-FIX.json`.
- Earlier focused core attempts exposed stale helper/manifest revision bindings. The bounded helper revision receipt records the causes and repairs. The final core and floor focused selections both pass on the current helper identity. Failed receipts remain available as history; no unchanged failure was retried without a cause-specific repair.

## Current evidence and stops

Phase 4 accounting remains 0 source associations, 9,716 typed gaps, and 18 unknown target sets. Source resolution and the legacy digest remain unresolved; caller closure is incomplete; candidate is null; implementation is unauthorized. R1 and R4 remain incomplete; R2, R3, R5, R6, and R8 are verified; R7 delivery remains unverified, excluded from claims, and preserved as history. No source access remains open.

The actual library collision remains unknown; the aggregate gate remains open; Walking Skeleton remains blocked; SEC-01 remains pending. The static-only boundary, Macro caller-AST and explanation checkpoints, and all original safety stops remain unchanged. No audited OTP/runtime path was invoked. Phase 4 `pass_with_open_gaps` and the complete typed-gap partition are not source/caller closure.

## Next action

Codex completes the final Phase 4 metadata rebind to this readiness report, reruns the cheap artifact and Phase 3 consumer validators, refreshes the canonical planning-state projection, then continues Phase 3 goal verification, security review, and the authorized PR #90 delivery workflow. Local results do not replace exact final-head hosted CI, actual merge/main CI, or the owner merge boundary. No owner action is needed for this routine work; any new source request, implementation, or guard increment remains outside this completed recovery authorization.
