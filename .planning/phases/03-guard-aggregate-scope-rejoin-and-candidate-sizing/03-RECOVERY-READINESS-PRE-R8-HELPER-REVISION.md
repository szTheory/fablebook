# Phase 3 recovery readiness

**Recorded:** 2026-11-18  
**Checkout:** `/Users/jon/projects/fablebook`  
**Branch:** `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing`  
**HEAD:** `7317bd0ea112dbe9c2a60e15322ec6bfccc4681d`; conflict-free merge in progress from PR #90  
**Plan:** 03-05 recovery  
**Current outcome:** The formatter and whitespace checks now pass on the normalized helper. The owner explicitly authorized one Phase 4 R7 request for the same bounded helper span because those whitespace changes invalidated consumed request R6. R7 has not yet been scheduled or emitted; no source-dependent suite has run on the formatted revision.

## Current continuation status

R6 was consumed once for the pre-format helper identity (7,728 bytes, 168 lines; helper SHA-256 `15a9f27f05492b8a5cdf39eeff267595c95ce18925ea983d5b3d6c68c6d31edf`; span SHA-256 `ab130b8e64c9b1a5c880cd00c0135002f7c473aeb5938ec1a1f52a903fc193e0`). The authorized formatter changed only whitespace inside that span. The formatted helper is 83,805 bytes, 2,287 lines, SHA-256 `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370`; the corresponding span is bytes `[63660,71408)`, lines 1748–1923, 7,748 bytes, SHA-256 `2861e6e06895760381c8ae3bd0fa7e5d9bc126493fc1173cb4ddbeaaec147682`. Existing Phase 4 `--all`, Phase 3 `--phase4-only`, and `--consumer` receipts predate formatting and must be rerun after R7; they are not current proof. Source resolution, caller closure, legacy digest and all implementation/safety gates remain open.

R2/R3 remain bound to historical producer SHA `75d23e5b48d17c632fd42c3d052aea7b1f25531ca359d897fc40ae577f61bbd6`; R5 remains a verified pre-repair snapshot; R6 remains the pre-format observation. The owner authorized exactly one Phase 4 R7 refresh in INT-20261118-03 and confirmed it in a follow-up reply. R7 covers only the formatted identity-validation span and caller context. Next actor: Codex prepares the exact schedule, independent review, fresh execute preflight, direct count, and one-use gate; then runs cheap checks before suites.

## Historical cheap evidence checks (helper SHA 5aeb1631)

The standard-library validator self-test passed all 16 controls. `--phase4-only` returned `pass_with_open_gaps` for generation `ENV-20261117-06-supported-20261117T204102Z`; `--consumer` returned `consumer_consistent` for the same generation. The current partition is 0 source associations and 9,716 typed gaps: 4,849 source gaps, 4,849 caller gaps, and 18 unknown target sets. There are 2,469 core and 2,380 floor known MFA keys, plus 452 identity-membership rows. The generated crosswalk digest is checked by `--consumer`; it is not copied here because Phase 4 manifest changes feed that crosswalk.

These results establish that the records and typed gaps reconcile. They do not resolve source or caller gaps. Source resolution remains unresolved, caller closure incomplete, the legacy digest unresolved, `candidate=null`, and `implementation_authorized=false`.

| Artifact | Current SHA-256 |
|---|---|
| `test/contract/tier_sweep_test.exs` | `f66d5c7f8467b1665d4eb593808788ee151a6fccf3301de14bb170a6b9bdc439` |
| Historical helper before the provenance-validator fix | `5aeb1631123bfaf1a6914c3e324486adef3369b762bbdc0a57a7f93d2d16e1f1` |
| `03-RECOVERY-RECONCILIATION.md` | `d2281402a0401751cf00c2257ec2cdefef5d0e2786ea789214520da411964218` |
| `03-05-validate-evidence.py` | `572f3197b122ad9efdf5ba08fd3b811a16c610d696d6fba954c6cb4af5962beb` |

## Historical local validation (helper SHA 5aeb1631)

| Check | Result | Receipt |
|---|---|---|
| Regression selection for gap-free source-join completeness and open caller gaps | 5 passed, 104 excluded; exit 0 | `/private/tmp/phase3-crosswalk-regression-fixes.log`, SHA-256 `bd55cbc8f0e25695776dd08afa13141ef1144ce8d260190f43c957e7c55a071b` |
| Core CI (`MIX_ENV=test bin/lane core mix ci`) | 454 passed, 10 excluded; exit 0; 416.7 seconds | `/private/tmp/phase3-core-ci-final-review-fix.log`, SHA-256 `42e90864d66f6dc94db96b7cdf64a4688044fd184ea5da9508be886c79cd94da` |
| Full floor suite (`MIX_ENV=test bin/lane floor mix test`) | 464 tests, 0 failures, 7 excluded; exit 0; 414.3 seconds | `/private/tmp/phase3-floor-full-review-fix.log`, SHA-256 `5b66402a105ed7a3929c3e6bcb275620a62e72fee988a1b9dd5b3a4607d3ee33` |
| Validator self-test | 16 controls passed; exit 0 | `03-05-validate-evidence.py --self-test` |
| Phase 4 evidence and Phase 3 consumer checks | `pass_with_open_gaps`; `consumer_consistent`; exit 0 | `03-05-validate-evidence.py --phase4-only` and `--consumer` |
| Formatter and whitespace checks | exit 0 | `env MIX_ENV=test bin/lane core mix format --check-formatted test/contract/tier_sweep_test.exs test/support/guard_aggregate_reconciliation_evidence.ex`; `git diff --check HEAD` |

The final local `act` feasibility receipt is reused: installed `act 0.2.87` does not support the workflow's `concurrency.queue` field, and the workflow hash matches `origin/main`. It was not retried. Hosted CI remains the next delivery gate.

## Historical review and verification state (helper SHA 5aeb1631)

The prior independent source review is clean: [03-EXECUTION-CODE-REVIEW.md](03-EXECUTION-CODE-REVIEW.md), reviewed 2026-11-18 04:02:22Z, two changed source/test files, zero findings. It predates the formatter-only helper change. Refresh the review against the formatted helper after the R7 span is delivered; do not treat the earlier source hashes as current. The prior regression verifies that a complete source join can be reported while caller evidence remains open; cases with source gaps remain incomplete.

`03-REVIEW.md` is a pre-existing recovery decision log, so it is not overwritten with a code-review report. The standard review artifact is `03-EXECUTION-CODE-REVIEW.md`; it is clean and has no findings requiring a disposition row.

The Nyquist coverage audit found no missing automated task coverage across the 12 active tasks. `03-VALIDATION.md` records the audit and the final suite counts. `03-SECURITY.md` reports zero open threats at ASVS L1. The current [03-VERIFICATION.md](03-VERIFICATION.md) report lists 21/21 must-haves, `behavior_unverified: 0`, and status `passed`. Both UAT checks are automated and pass; no owner verification remains for this evidence-only result.

## Stops retained

No source association is resolved; caller closure remains incomplete; the actual collision remains unknown; Macro caller-AST and explanation wording remain unresolved; static-only limits remain binding; candidate is null; implementation is unauthorized; the aggregate gate is open; Walking Skeleton is blocked; and SEC-01 remains Pending. No audited runtime or library call was introduced. No source-access or safety stop was removed.

## Current tested artifact identity

| Artifact | Current SHA-256 | Status |
|---|---|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370` | Formatter and whitespace checks pass; R7 has not yet refreshed provenance |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-validate-evidence.py` | `96e621d0838e8753ab6cd080142adb6641a062ab9a1c9cde79b774c8361fdf6d` | Current-helper receipt still points to pre-format R6; rerun and refresh after R7 |

Generated validation and crosswalk hashes are recorded by their own machine receipts and recomputed by `--all`/`--consumer`; they are not duplicated here because this readiness file is itself bound by the preservation bridge.

## Delivery state and next action

No hosted candidate CI, merge, main CI, or delivery-registry entry exists. The owner has authorized one bounded Phase 4 R7 request for the same identity-validation helper span; the new dated replans record the exception to the old R7 denial. R7 must pass fresh review, preflight, direct count and one-use gate before any suite. All existing source/caller, collision, Macro, candidate, implementation, aggregate, Walking Skeleton and SEC-01 stops remain unchanged.
