---
phase: quick-261110-she
plan: "01"
status: complete
delivery_status: merged
source_commit: 97aa76973eed7c9f2e5268bec4b249ad497237db
source_sha256: 15286b846642249b66a056e1171736427817ae5f4c011e35e4fcc598a4465b1c
requirements_completed: []
---

# CI-gate predicate contract hardening

Only `test/contract/ci_shape_test.exs` changes as implementation. The correct workflow predicate stays unchanged: every required job must succeed, with skipped nightly allowed only for non-release heads. The previous marker-string acceptance is replaced by scoped checks of NEEDS/HEAD_REF bindings and the exact canonical shell/jq program. Blank rows, YAML/leading shell comments and env-key ordering remain accepted; quoted-program text is preserved.

## Task 1: regression controls

Seven rejected mutations cover all-to-any, a core-only result filter, nightly and-to-or, removing the release-head skip restriction, wrong HEAD_REF binding, marker tokens in a comment beside a no-op, and the quoted-comment pipeline bypass found during review. Existing rules and mutations remain unchanged. Every edit is non-vacuous and reaches exactly ci_gate_step. The unchanged real and base workflows, and both benign controls for each, pass all validators.

Fail-before evidence: after correcting an initial syntax diagnostic and a too-long mutation line, `task1-red.log` reports six intended failures, each showing an empty finding list where ci_gate_step was expected. Those earlier diagnostics are retained separately and are not RED proof. The comment-filtering regression then produced one intended failure in `review-comment-red.log`. Actual local shell probes in `predicate-behavior.json` and `quoted-comment-probe.json` demonstrate that the weakened predicates can return success for failed prerequisites or skipped release nightly, whereas the canonical command rejects those inputs.

Pass-after evidence: final focused core and floor runs each pass all 68 tests, in `task1-green-core-final.log` and `task1-green-floor-final.log`. Source commits are `7d7ecfa` (initial scoped predicate guard) and `97aa769` (quoted-program review fix). The earlier 67-test runs are historical and not the final source receipt.

## Task 2: delivery

[Two-pass inline review](261110-she-REVIEW.md) is complete with the quoted-comment finding fixed and no remaining blocking issue. Full native core CI completed against the final source commit/digest above in 998.13s: format, dependency, compilation, strict Credo, cycle and documentation checks passed; ExUnit reported 406/407 passed. The sole failure was the unchanged saved-settings receipt acceptance test exceeding its existing 60000ms limit while grouping installed-OTP membership data. The failed command remains a failure, never relabelled as a green full run. Its receipt is `delivery-core-with-timeout.json`.

The affected test and both helpers are byte-identical to origin/main. A process snapshot showed other project/test and browser load on the shared machine; this is a possible timing contributor, not an established root cause. No foreign process was stopped, no restart was proposed, and no timeout, filter, exclusion or quality gate changed. One bounded isolated retest of saved_settings_receipt passed under the same limit (1 passed, 93 excluded; 282.61s including fresh graph setup), recorded in `saved-settings-retest.json`. Reuse the other 406 passing results rather than repeating the entire native suite after a successful unchanged-boundary retest. Required hosted full core/floor checks remain mandatory and must provide a complete green candidate receipt. This is a documented validation deviation, not a gate reduction.

The first full-core attempt was stopped with targeted SIGTERM after the review finding, before changing source. Its Mix process returned zero during shutdown but emitted no suite completion. `delivery-core-cancelled.json` marks it cancelled; it is never counted as a pass. Only the attributed task process was stopped, after verifying its command and checkout directory.

Focused floor validation proves compatibility of the pure contract helper before required hosted full-floor CI. Repeating the unchanged full native floor suite is unnecessary here; its prior full run took about nine minutes, while the affected focused suite takes under a second. Hosted floor compile/no-optional/full-test gates remain mandatory and unchanged. Native Mix lanes run sequentially.

`act pull_request -W .github/workflows/ci.yml` cannot start jobs because installed act rejects the existing concurrency.queue field. The one attempt is recorded in `delivery-act.log`, exit 1. It is not a pass, and no workflow edit or repeat attempt is warranted.

Planning intent/contract-rule checks passed after the brand intake and quick-record edits (19 tests; `planning-final.log`). The phase 01.1.1.18 verification fingerprint still returns passed.

All raw logs/probes are in ignored `_build/quick-261110-she/`. The protected .github/lib/dependency/lockfile diff is empty. [PR #81](https://github.com/szTheory/fablebook/pull/81) at candidate `5a1a0183f190d412b762d2154e51b530088bc9e6` passed all required [hosted CI](https://github.com/szTheory/fablebook/actions/runs/42944194233): core, floor, Dialyzer, security and ci-gate. Scheduled-only jobs were correctly skipped. Full hosted core/floor provide complete green suite receipts on the reviewed source; the native timeout remains separately recorded, with its successful unchanged isolated retest. GitHub reports a clean, mergeable PR. Owner merge remains pending. Final receipt-only updates will stay local for the next substantive push, with live CI linked from the PR.

## Preserved scope

Other four UAT groups retain their owners; the CI-gate landing requirement stays open until merged. Parent source-audit stops, SEC-01 Pending with Phase 5 and the Phase 2 gate remain. No roadmap phase, requirement, release or production behavior is completed by this task. Original/recovery checkouts remain untouched.

Default quick mode ran planning/execution inline under the skill adapter's automatic-spawn restriction. The supported worktree helper created the separate task branch; no harness isolation is claimed. Planner hooks returned no external integration, skipped assumption-delta because a quick task has no roadmap phase, and found no schema-relevant paths. The plan includes the configured security threat model. Four previously saved documentation-only receipts accompany this substantive change.

## Additional owner-requested planning capture

A background GPT-6 Luna worker read the owner-provided Logistify source and wrote a compact [Phase 17 reference](../../references/logistify-brand-intake.md), a dormant seed, owner excerpts and a PROJECT pointer. Root checked the three source hashes, corrected excerpt fidelity and scope wording, and committed the capture separately. Source assets remain uncommitted in the preserved primary checkout; no brand, schema mapping, file move or Phase 17 implementation was applied. This separate capture was explicitly requested during the quick task and is not part of its implementation-source scope.

## Final hosted receipt and feedback time

| Job | Result | Duration | Receipt |
|---|---|---|---|
| core | success | 443s | [job](https://github.com/szTheory/fablebook/actions/runs/42944194233/job/130272912357) |
| floor | success | 728s | [job](https://github.com/szTheory/fablebook/actions/runs/42944194233/job/130272912429) |
| dialyzer | success | 22s | [job](https://github.com/szTheory/fablebook/actions/runs/42944194233/job/130272912578) |
| security | success | 28s | [job](https://github.com/szTheory/fablebook/actions/runs/42944194233/job/130272912087) |
| ci-gate | success | 3s | [job](https://github.com/szTheory/fablebook/actions/runs/42944194233/job/130277626913) |

Core and floor overlapped. Core's CI step took 425s, floor's test step 702s and setup 12s/13s. Previous PR job totals were 460s/639s; the following main totals were 585s/537s. Tests dominate, with substantial duration variation and already short cached setup. No repeatable quality-preserving workflow shortcut is established; do not add speculative caches/concurrency/dependencies or weaken gates. Timing objectives remain non-blocking feedback.

Final hosted receipts and quick-task completion bookkeeping stay local for the next substantive push, avoiding another receipt-only run. The CI-gate audit group remains a landing requirement until PR #81 merges; four unrelated UAT groups retain their owners. Logistify capture is stored in the reviewed candidate, linked from PROJECT, and has not applied or moved original assets.

Next command: `gh pr merge 81 --squash --match-head-commit 5a1a0183f190d412b762d2154e51b530088bc9e6` — owner-authorized merge of the reviewed green candidate. Parent source-size stops, SEC-01 Phase 5 ownership and the Phase 2 gate remain.

## Approved merge closure

[INT-20261110-09](../../intent/sources/2026-11-10-09-approve-ci-gate-contract-merge.md) records the owner's approval. [PR #81](https://github.com/szTheory/fablebook/pull/81) was squash-merged at `2026-11-11T02:35:52Z`, commit `79e1a4ffdb7634c9d0d9c8d43e352e1b3daf030a`, with expected head `5a1a0183f190d412b762d2154e51b530088bc9e6` enforced. Required candidate CI passed before merge. The preceding pending-merge statements are historical snapshots.

Fresh main source SHA-256 is `15286b846642249b66a056e1171736427817ae5f4c011e35e4fcc598a4465b1c`, matching every final contract receipt. The pre-merge base-to-main workflow, library, dependencies and lockfiles have no diff. Logistify's reference, owner excerpts, seed and PROJECT pointer also match the reviewed candidate and are now on main; original book assets remain untouched and unapplied.

The CI-gate UAT group is closed; four unrelated groups remain. The [post-merge main run](https://github.com/szTheory/fablebook/actions/runs/42947113449) is in progress and is not a passing receipt yet. Merge/closure bookkeeping is saved locally for the next substantive push; no extra receipt-only run is triggered. The primary/recovery worktrees, parent source-size stops, SEC-01 Phase 5 ownership and Phase 2 gate remain.

Next command: `gh run watch 42947113449 --exit-status` — observe post-merge main CI. No owner action is required to let that automation finish; no new phase or release is started.
