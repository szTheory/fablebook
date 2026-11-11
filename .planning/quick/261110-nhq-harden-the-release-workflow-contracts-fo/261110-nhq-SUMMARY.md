---
phase: quick-261110-nhq
plan: "01"
status: complete
delivery_status: merged
source_commit: 08857f4c68e2c10d90ccef786df0d124c26e4b9a
source_sha256: 9354a54779c5b2a67978f2bcc25bbcdd7c03083097e57d6b958d9a4fb5bcf736
requirements_completed: []
---

# Release workflow contract hardening

The only implementation change is `test/contract/hex_publish_test.exs`. It strengthens detection of the reproduced release-workflow omissions while preserving the unchanged workflow as the passing authority. Workflow, library, dependencies and lockfiles are unchanged. Carried documentation records the already merged Phase 01.1.1.18 and the preceding UAT audit; it is batched here with the substantive contract change.

## Implemented tasks

| Task | Result | Commit |
|---|---|---|
| Runner shell and independent release fixtures | Extracted scripts run under Bash 5+ with `-e`, without pipefail; tag shape, version equality and ancestry vary independently; pipeline masking is rejected; fixture identity has no email-shaped literal. | a99e4b4 |
| Root secret scope and accepted ordering | A secret in root env after jobs is rejected; legitimate env reordering and harmless comments pass all validators. | 597766c |
| Execution, environment and smoke controls | Finalize/smoke conditions, publish environment, release/prod_guard filters, pre/post-publish smoke, checksum/version wiring and both matrix lanes have scoped checks and attributable mutations. | 08857f4 |

## Evidence before and after

The prior immutable [UAT audit](../../audits/2026-11-10-UAT-AUDIT.md) records the old-validator misses and audited source digests. The Task 2 regression demonstrated the root-env-after-jobs leak returning no finding instead of `secret_scope`. A separate old structural-validator probe returned no findings for the Task 3 omitted controls. Each final mutation requires a nonempty edit and its intended rule identity; the unchanged workflow and both benign controls return no findings.

After the final source edit, focused core and floor contract runs each passed all 61 tests. Formatting and strict Credo passed. Logs are in ignored `_build/quick-261110-nhq/`: `task2-red-root-env.log`, `task3-red-pure-old-controls.log`, `task3-rule-targeting-2.log`, `task3-core-final3.log`, `task3-floor-final.log`, and `task3-credo-attempt4.log`. Earlier failed fixture/shell diagnostics and empty-selection attempts are retained separately and are not counted as intentional regression evidence or passes.

The shell correction required selecting an already installed Bash 5+ once: macOS Bash 3.2 did not reproduce the Linux runner's errexit behavior for a bare conditional. No shell was installed and no global PATH was changed. Missing Bash 5+ produces a clear failure.

## Delivery validation

Full native core CI passed (398 tests; exit 0, 673.61 seconds). Floor compile and forced no-optional compile passed (exit 0, 1.25 and 2.59 seconds). The full floor suite passed (398 tests, 0 failures, 4 configured exclusions; exit 0, 551.71 seconds). All four receipts identify source commit `08857f4c68e2c10d90ccef786df0d124c26e4b9a` and the source digest above. No source edit followed these runs. Native lanes run sequentially because nested Mix fixtures can share their own build directories. Command, source digest, tested revision, exit and timing receipts are captured in ignored `delivery-local.json` beside individual logs.

`act pull_request -W .github/workflows/ci.yml` exited 1 before jobs: installed act rejects the existing `concurrency.queue` field. This is unavailable local Actions execution, never a passing receipt. No workflow edit or repeated act attempt is needed.

After the delivery-record edits, the planning intent/contract-rule checks passed (19 tests). `git diff --check origin/main` is clean. The protected-tree diff is empty. Phase 01.1.1.18's independent verification fingerprint still returns passed. [Inline review](261110-nhq-REVIEW.md) found no blocking correctness or security findings in one pass. No package publication, release dispatch, messaging, package installation or audited ASN.1 execution was used for this hardening.

[PR #80](https://github.com/szTheory/fablebook/pull/80) publishes candidate `22c24b6a5a3d55c3fd2468b7c983a0cc563af7c0`. The source digest is unchanged from all local receipts. [Required hosted CI passed](https://github.com/szTheory/fablebook/actions/runs/42927843212) on that exact candidate: core, floor, dialyzer, security and ci-gate all succeeded. Scheduled-only nightly and ci-health jobs were correctly skipped. GitHub reports the PR mergeable with a clean merge state. Merge remains the owner boundary under the quick workflow; this summary does not claim it happened.

## Preserved boundaries

Only the release-contract UAT group is in scope. The other five UAT groups retain their owners. The parent source-audit stop remains unresolved, SEC-01 remains Pending with Phase 5, and Phase 2 stays gated. No roadmap phase or requirement is completed by this quick task. The original dirty checkout and recovery worktrees are preserved.

## Hosted trigger observation

After opening the PR, both the connector and direct Actions API reported no workflow run for its branch/head; Actions permissions report enabled. The PR also continued to report unknown mergeability and no check rollup. One close/reopen through the GitHub CLI refreshed the normal pull-request trigger without changing the candidate, dispatching a workflow, invoking scheduled reporting or pushing an empty commit. This observation is not a CI pass.

The original trigger arrived late, and reopening was premature. Two runs materialized for the same candidate: [42927626866](https://github.com/szTheory/fablebook/actions/runs/42927626866) was superseded by [42927843212](https://github.com/szTheory/fablebook/actions/runs/42927843212). The first run's gate log explicitly contains cancelled core/floor prerequisites and successful security/dialyzer; its gate failed correctly. It is not a passing receipt or a code failure. The latest run is authoritative. Do not refresh a new PR merely because initial API queries return no checks: first inspect the workflow/PR state and allow for trigger propagation; avoid creating duplicate runs without evidence of a missing event. No further trigger or rerun was issued.

## Final hosted receipt and feedback time

| Job | Result | Duration | Receipt |
|---|---|---|---|
| core | success | 460s | [job](https://github.com/szTheory/fablebook/actions/runs/42927843212/job/130219018915) |
| floor | success | 639s | [job](https://github.com/szTheory/fablebook/actions/runs/42927843212/job/130219018859) |
| dialyzer | success | 23s | [job](https://github.com/szTheory/fablebook/actions/runs/42927843212/job/130219018774) |
| security | success | 32s | [job](https://github.com/szTheory/fablebook/actions/runs/42927843212/job/130219018428) |
| ci-gate | success | 2s | [job](https://github.com/szTheory/fablebook/actions/runs/42927843212/job/130223868922) |

Core and floor overlapped. Core's CI step took 443s, floor's test step 613s, and setup 9s/12s. The preceding PR's job totals were 589s/595s and the following main run's 511s/606s. Variation across these runs does not establish an avoidable serial dependency, absent cache or removable required check. Tests dominate; no evidence-supported workflow shortcut is established within this contract-only scope. Timing remains feedback, not a new release gate.

The final receipt and quick-task completion bookkeeping are held locally for the next substantive push, and linked from the PR, avoiding another receipt-only CI run. No further source edit followed validation. The audit keeps the release-hardening landing requirement outstanding until the owner merges PR #80; the other five groups stay open.

Next command: `gh pr merge 80 --squash --match-head-commit 22c24b6a5a3d55c3fd2468b7c983a0cc563af7c0` — owner-authorized merge of the reviewed green candidate. Do not start another phase or release.

## Approved merge closure

Owner authorization is recorded in [INT-20261110-06](../../intent/sources/2026-11-10-06-approve-release-contract-merge.md). [PR #80](https://github.com/szTheory/fablebook/pull/80) was squash-merged at `2026-11-11T00:24:51Z`, merge commit `ea2b09914512b9059be951157e0f1b4cd7d91007`, with the expected reviewed head enforced by the merge API. All required candidate jobs had passed in [42927843212](https://github.com/szTheory/fablebook/actions/runs/42927843212). The earlier pending-merge statements above describe the pre-approval receipt.

A fresh fetch confirms main's release-contract digest matches the tested `9354a54779c5b2a67978f2bcc25bbcdd7c03083097e57d6b958d9a4fb5bcf736`; the workflow, library, dependencies and lockfiles remain unchanged. The [post-merge main run](https://github.com/szTheory/fablebook/actions/runs/42931152814) is in progress and is not claimed as passed. The release-contract audit group is resolved by this merged green candidate; five unrelated groups remain. No new phase or release is started.

Closure bookkeeping stays local for the next substantive push. Original/recovery worktrees remain preserved. Next command: `gh run watch 42931152814 --exit-status` — observe the separate post-merge main CI. No owner action is required to let that automation finish.

## Post-merge main CI complete

The [main run](https://github.com/szTheory/fablebook/actions/runs/42931152814) passed on merge commit `ea2b09914512b9059be951157e0f1b4cd7d91007`; all five required jobs succeeded. Scheduled-only jobs were correctly skipped. This supersedes the in-progress observation above.

| Job | Result | Duration |
|---|---|---|
| core | success | 585s |
| floor | success | 537s |
| dialyzer | success | 25s |
| security | success | 33s |
| ci-gate | success | 4s |

Core and floor overlapped; setup and test steps remain the same as the reviewed candidate. This run does not establish a new quality-preserving workflow shortcut; no workflow change or extra run is warranted. The merged quick task and its post-merge observation are complete. Five unrelated UAT groups, the parent source-audit stop, SEC-01 Phase 5 ownership and the Phase 2 gate remain. Final receipts stay local for the next substantive push.

Next command: `$gsd-progress --forensic` — review remaining work before choosing another bounded task or phase. No owner action is needed for the completed merge.
