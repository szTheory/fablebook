---
phase: quick-261110-v8d
plan: "01"
status: incomplete
delivery_status: awaiting-hosted-ci
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

Required hosted candidate checks and owner merge are pending. No quick completion row or UAT closure is claimed yet. Four UAT groups retain their current count until landing, and the other three owners remain unchanged. Phase 01.1.1.18 stays complete; the parent source-audit stop, SEC-01 Pending with Phase 5 and Phase 2 gate remain. Brand source assets and original/recovery checkouts are untouched; no Phase 17 implementation or publication occurs.

Next action: publish this reviewed/tested candidate under standing authorization and obtain required hosted receipts. Owner handles merge after the concrete green PR is ready.
