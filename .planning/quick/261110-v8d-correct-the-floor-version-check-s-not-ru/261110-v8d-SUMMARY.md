---
phase: quick-261110-v8d
plan: "01"
status: complete
delivery_status: ready-for-owner-merge
source_commit: 5fa9f080372fffc39485a77d00ce8d40c02fcdd9
requirements_completed: []
---

# Floor-version check reporting

The core lane now excludes the floor-version test through ExUnit instead of printing not-run and recording a successful no-op. A selected floor lane runs the unchanged Phoenix/LiveView loaded-version assertions. The existing FABLEBOOK_FLOOR presence policy, including an empty string, stays aligned with Mix's lockfile selection. CI-shape explicitly permits the core floor filter and rejects it on floor. Workflow, library, dependencies and lockfiles remain unchanged.

## Execution evidence

All commands used locked local lane caches, sequential Mix execution and background/piped processes. Raw logs live in ignored `_build/quick-261110-v8d/`.

| Check | Result / receipt |
|---|---|
| RED: `bin/lane core test --warnings-as-errors test/contract/floor_selection_test.exs` | Three intended failures: missing actual floor tag and missing core floor exclusion on resolved/unresolved local diff; CI unresolved diff already rejects. `selection-red.log`. |
| Final focused core: dependency_budget, ci_shape, floor_selection with warnings-as-errors | 77 passed, 1 excluded; `core-focused.log`. |
| Final focused floor: same three files with warnings-as-errors | 78 passed; `floor-focused.log`. |
| Actual budget TAP, core | Floor event `ok ... # SKIP "due to floor filter"`; `budget-core.tap`. |
| Actual budget TAP, floor | Same floor event `ok` with no SKIP; `budget-floor.tap`. |
| Wrong-version control, actual floor | Nonzero exit and `not ok` floor event; decoded assertion shows Phoenix 1.8.9 versus 0.0.0. `budget-mismatch.tap`. |
| Format; core and floor compile with warnings-as-errors | Passed; `format.log`, `compile-core.log`, `compile-floor.log`. |
| Strict Credo | No issues; `credo.log`. |
| Planning intent and contract-rule suites | 32 passed; `planning.log`. |
| Protected diff and whitespace | Empty .github/lib/mix.exs/lockfile diff against freshly fetched main; diff --check clean. |
| `act pull_request -W .github/workflows/ci.yml` | Unavailable: installed act rejects existing concurrency.queue before starting jobs; exit 1, `act.log`. No workflow edits or repeat attempt. |

The first green probe exposed the VM launcher's removal of an empty environment entry: a child launched with that entry reads nil. The isolated probe now sets/deletes its own flag after boot, before loading the real helper. This preserves genuine empty-string coverage without mutating the parent environment. That harness correction is not a product-policy change.

A diagnostic TAP attempt with warnings-as-errors aborted after execution because the existing test_helper loader redefines the already-compiled formatter. It remains a failed command (`budget-core.log`). TAP diagnostics were then run without that flag solely to inspect actual events; their existing redefinition warning is recorded in `budget-*-report.log`. They do not substitute for the separate clean focused warnings-as-errors suites or required hosted full suites. The intentionally wrong-version copy also has an unused-variable warning; its decoded failed assertion independently proves the expected mismatch, not merely a warning exit. The unrelated formatter loader is unchanged.

[Inline review](261110-v8d-REVIEW.md) found no significant issue in one pass. Native full-suite repetition is unnecessary for this selection boundary: the real-helper probe, actual-version events and wrong-version negative cover it, while full hosted core/floor, Dialyzer, security and ci-gate remain mandatory. No quality gate is weakened.

## Source identity

| File | SHA-256 |
|---|---|
| `test/contract/ci_shape_test.exs` | `2e97edfaf56dbad112766c7392316cbf4a8207a2a26faad58fa183fba499ab6a` |
| `test/contract/dependency_budget_test.exs` | `a8f98438865a1ec600f53c262768cf37689468fc94ecfcd229f67bafee8c9df3` |
| `test/contract/floor_selection_test.exs` | `97e960013c0f57a7f6d97e886a72ea73cd3f415d52b5326ef697fa065d788d67` |
| `test/test_helper.exs` | `c434ffbe8bf48b22adfd145c594bcc4ad9eb54edb2f4d30f0a8f6508993252c5` |

## Scope and remaining delivery

Fresh main remains the PR #81 squash merge. Four verified documentation-only receipt commits accompany this substantive change. Default quick planning/execution ran inline under the automatic-spawn restriction; supported worktree creation does not claim harness isolation. API detection is negative, assumption-delta is typed phase_unresolved, no schema path applies and the plan records its threat model. Optional discussion/research/checker/verifier were omitted by default quick mode.

Required hosted candidate checks have passed and the quick completion row is recorded. Owner merge remains pending; no UAT landing closure is claimed yet. Four UAT groups retain their current count until landing, and the other three owners remain unchanged. Phase 01.1.1.18 stays complete; the parent source-audit stop, SEC-01 Pending with Phase 5 and Phase 2 gate remain. Brand source assets and original/recovery checkouts are untouched; no Phase 17 implementation or publication occurs.

The reviewed/tested candidate was published under standing authorization. Owner handles merge; the required hosted receipt is below.

## Final hosted receipt and owner boundary

[PR #82](https://github.com/szTheory/fablebook/pull/82), head `95ba228ef33c3b88fda61ffebed30958d1be5927`, passed all required [hosted CI](https://github.com/szTheory/fablebook/actions/runs/42954945700). Full core/floor, Dialyzer, security and ci-gate succeeded; scheduled-only nightly and ci-health were correctly skipped. Read-only run metadata confirms the pull_request event and exact reviewed head. GitHub reports the PR clean and mergeable. Source bytes still match the identities above; no code changed after local checks. This is candidate completion, not a merged-main claim.

| Job | Result | Duration | Receipt |
|---|---|---|---|
| core | success | 553s | [job](https://github.com/szTheory/fablebook/actions/runs/42954945700/job/130307704030) |
| floor | success | 599s | [job](https://github.com/szTheory/fablebook/actions/runs/42954945700/job/130307704268) |
| dialyzer | success | 22s | [job](https://github.com/szTheory/fablebook/actions/runs/42954945700/job/130307704297) |
| security | success | 27s | [job](https://github.com/szTheory/fablebook/actions/runs/42954945700/job/130307704312) |
| ci-gate | success | 4s | [job](https://github.com/szTheory/fablebook/actions/runs/42954945700/job/130311089514) |

Core and floor overlapped. Core's mix-ci step took 536s and floor tests 574s; setup was 10s/11s. The run entered execution in its creation second. Recent preceding candidate/main core/floor totals were 443s/728s and 537s/600s; this run is 553s/599s. Tests dominate, with substantial run variation and short cached setup. No repeatable quality-preserving workflow shortcut is established. Preserve the existing timing objectives as feedback and every required gate; no extra run, speculative cache, concurrency or dependency change is warranted. This task has changed no workflow bytes.

The connector's optional full core-log download exceeded its transport frame limit; job/run metadata independently supplies the successful hosted receipts and timings. No suite or CI retry was triggered to work around that read-only tooling limitation.

Final receipt-only SUMMARY/STATE/audit updates are committed locally for the next substantive push, avoiding an identical hosted run. Live green CI is linked from the PR. The UAT audit still counts four groups until owner merge; the other three owners remain unchanged. The completed Phase 01.1.1.18 verification fingerprint still returns passed. Parent source-size stops, SEC-01 Phase 5 ownership, Phase 2 gate and the unapplied brand source remain preserved. No owner UAT is needed.

Next command, after owner approval: `gh pr merge 82 --squash --match-head-commit 95ba228ef33c3b88fda61ffebed30958d1be5927` — merge the reviewed green candidate. The quick workflow says "User handles merge/rebase afterward"; this is the remaining owner boundary. No next phase starts automatically.
