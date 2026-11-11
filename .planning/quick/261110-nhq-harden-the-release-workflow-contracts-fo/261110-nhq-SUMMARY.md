---
phase: quick-261110-nhq
plan: "01"
status: in-progress
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

Hosted candidate checks remain pending. Required core, floor, dialyzer, security and ci-gate results must be green on the published candidate; local checks do not replace them. Merge is a separate owner boundary under the quick workflow.

## Preserved boundaries

Only the release-contract UAT group is in scope. The other five UAT groups retain their owners. The parent source-audit stop remains unresolved, SEC-01 remains Pending with Phase 5, and Phase 2 stays gated. No roadmap phase or requirement is completed by this quick task. The original dirty checkout and recovery worktrees are preserved.
