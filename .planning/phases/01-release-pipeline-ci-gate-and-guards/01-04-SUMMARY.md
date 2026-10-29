---
phase: 01-release-pipeline-ci-gate-and-guards
plan: 04
subsystem: ci
tags: [intent, diff-seam, contract-rule, ci-shape, github-actions, exunit]

requires:
  - phase: 01-01
    provides: "mix ci alias, test_helper, test_ignore_filters, floor lane"
  - phase: 01-02
    provides: "ci.yml with core full-history checkout and EVENT_BEFORE, ci-health and nightly regression steps, PR #1"
  - phase: 01-03
    provides: "contract-test conventions: rules as private pure functions with synthetic negatives"
provides:
  - "Fablebook.Test.GitDiff.base/2 and changes/2: the D-19 diff seam, driven by an explicit env map and working directory"
  - "test_helper: raises in CI on an unresolved diff base; locally excludes :git_diff and prints the not-run reason"
  - "test/planning/intent_test.exs: add-only sources, source file rules, INT and ADR citations, REQ lines (19 tests)"
  - "test/planning/contract_rule_test.exs: D-21 pairing rule plus seven real-repository seam tests (13 tests)"
  - "test/contract/ci_shape_test.exs: D-17 restricted-dialect scanner, 41 mutation rows, inventory and test-wiring pins (59 tests)"
  - "test/fixtures/ci_shape/base.yml: the valid baseline the mutations break"
  - "PR #1 green under the all-checks merge rule on head aad6aa2 (run 40796388523)"
affects: [01-05]

actuals:
  tokens: 12200
  tasks: 3
  commits: 6
plan_head_before: 07fe6474737e9ff2d39086eedce9667be87520d1
plan_head_after: aad6aa231024a41321f3e4a66a6f4ce1fbcd3315

tech-stack:
  added: []
  patterns:
    - "Guard logic lives as private functions inside the guarded test files; test/support holds only the git seam"
    - "Mutation tables: {rule, target, from, to} rows applied in-test, asserting the text changed and exactly one rule fired"
    - "Corpus scans read git's tracked plus untracked-not-ignored list, so local and CI see the same files"

key-files:
  created:
    - test/support/git_diff.ex
    - test/planning/intent_test.exs
    - test/planning/contract_rule_test.exs
    - test/contract/ci_shape_test.exs
    - test/fixtures/ci_shape/base.yml
  modified:
    - test/test_helper.exs
    - docs/research/OWNER-DNA.md
    - .planning/phases/01-release-pipeline-ci-gate-and-guards/01-RESEARCH.md

key-decisions:
  - "The contract-test rule flags any non-addition status on a guard path (M, D and also T), not only M and D, so a type change cannot slip past it"
  - "GitDiff rejects a push before value that is not a full hex SHA before asking git, and scrubs GIT_DIR, GIT_WORK_TREE and GIT_INDEX_FILE from every git call"
  - "changes/2 reads git diff -z output, so quoted or unusual paths parse exactly"

patterns-established:
  - "A guard test pins the wiring that sits outside the D-21 guard paths (alias step, ignore filters, test path keys, ExUnit excludes)"

requirements-completed: []
requirements-advanced: [INTENT-01, CI-01]

coverage:
  - id: D1
    description: "Intent rules: add-only sources over the diff seam, source file rules, INT and ADR citations, REQ lines; the real corpus passes"
    requirement: INTENT-01
    verification:
      - kind: unit
        ref: "mix test --warnings-as-errors test/planning/intent_test.exs (19 passed, :git_diff included, Elixir 1.20.4 / OTP 29.1.1)"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40796388523 (core and floor, :git_diff not excluded)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Zero before SHA in CI fails closed"
    requirement: INTENT-01
    verification:
      - kind: unit
        ref: "GITHUB_EVENT_NAME=push EVENT_BEFORE=<40 zeros> CI=true mix test test/planning/intent_test.exs -> exit 1, 'diff base unresolved in CI: push with zero before SHA'"
        status: pass
    human_judgment: false
  - id: D3
    description: "D-21 pairing rule and the seam proven against a real git repository"
    requirement: CI-01
    verification:
      - kind: unit
        ref: "mix test --warnings-as-errors test/planning/contract_rule_test.exs (13 passed; probe changes/2 -> [] failed the real-repo diff test, reverted)"
        status: pass
    human_judgment: false
  - id: D4
    description: "CI shape: every D-17 rule fires on its mutation, the real .github tree and the test wiring pass"
    requirement: CI-01
    verification:
      - kind: unit
        ref: "mix test --warnings-as-errors test/contract/ci_shape_test.exs (59 passed)"
        status: pass
    human_judgment: false
  - id: D5
    description: "mix ci green locally on both lanes and PR #1 green under the all-checks merge rule"
    requirement: CI-01
    verification:
      - kind: other
        ref: "mix ci (exit 0, Result: 119 passed); floor 1.18.4 / OTP 27.3.4.15: 119 tests, 0 failures, 4 excluded"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40796388523 (attempt 1, head aad6aa2)"
        status: pass
    human_judgment: false
  - id: D6
    description: "D-22 red run (a PR that edits an intent source fails ci-gate) and the live ci-health shape scan on main"
    requirement: INTENT-01
    verification:
      - kind: other
        ref: "Plan 01-05"
        status: not-run
    human_judgment: false

duration: 17min
completed: 2026-10-29
status: complete
---

# Phase 1 Plan 04: Intent, contract-rule and CI-shape guards Summary

**Three guard tests now run in `mix ci`. The intent test enforces add-only sources, source rules, citations and REQ lines. The contract-rule test pairs guard paths with what they guard. The CI-shape test scans the workflows with 41 single-rule mutations and pins the test wiring. A git diff seam is proven against a real repository on every run, and PR #1 is green with every guard included.**

## Performance

- **Duration:** about 17 min (2026-10-29T00:35:35Z to 00:52Z)
- **Tasks:** 3 of 3
- **Files:** 5 created, 3 modified

## Links

- **Green run:** https://github.com/szTheory/fablebook/actions/runs/40796388523 (attempt 1, event `pull_request`, head `aad6aa2`). The all-checks merge rule holds: core, floor, dialyzer, security and ci-gate passed. nightly and ci-health were skipped.
- **`:git_diff` ran in CI.** The core log has no `git_diff tests: not-run` line. It shows `Including tags: [:prod_guard, :release]` and `Result: 119 passed`. The floor log shows `Excluding tags: [:release]` and `119 tests, 0 failures, 4 excluded` (the four `:release` tests). The PR base resolved through the pull_request rule.

## Accomplishments

- **Diff seam (`Fablebook.Test.GitDiff`).**
  - `base/2` returns HEAD's first parent on `pull_request` and fails unless HEAD has two parents.
  - On `push` it returns `EVENT_BEFORE`, failing closed on an all-zero, malformed or unknown SHA.
  - Every other event resolves `git merge-base origin/main HEAD`.
  - `changes/2` runs `git diff --no-renames --name-status -z` against the working tree.
- **test_helper.**
  - With `CI` set, an unresolved base raises.
  - Locally it excludes `:git_diff` and prints `git_diff tests: not-run (<reason>)`. A simulated one-parent pull_request run showed `git_diff tests: not-run (pull_request HEAD has 1 parents, expected 2)` and `1 excluded`.
- **Intent test (19 tests).**
  - Add-only: M, D and T fail; A passes. Added INT files go to `$GITHUB_STEP_SUMMARY`.
  - Ten source-rule cases run in tmp_dir, one per D-19 rule plus valid controls.
  - INT citations, singular and plural ADR forms, and REQ-line rules.
  - The real corpus passes: 19 sources, 129 REQ lines, 129 traceability rows.
- **Contract-rule test (13 tests).**
  - Five synthetic pairing cases.
  - Seven real-repository seam tests: A, M and D, with a rename seen as D plus A; the pull_request first parent; one-parent rejection; zero, known and unknown push `before`; merge-base with origin/main.
- **CI-shape test (59 tests).**
  - The real tree and base.yml pass.
  - 41 mutation rows each fire exactly their rule. Positive controls: Node in `nightly` passes, and `p50` is not a phase name.
  - Four inventory cases (fourth workflow, extra action, `.js`, `package.json`) and nine wiring checks.
  - The day-1 allowlists are `@node_jobs ~w(e2e nightly)`, `@schedule_only ~w(ci-health)` and `@allowed_reusable` (release-please.yml to hex-publish.yml only).

## Probe result (Task 2 acceptance)

I temporarily changed `changes/2` to return `[]`. The real-repo diff test then failed:

```
1) test the seam reports A, M and D, and a rename as D plus A (Fablebook.Planning.ContractRuleTest)
   Assertion with == failed
   code:  assert Enum.sort(GitDiff.changes(first, dir)) == [{"A", "b"}, {"A", "s"}, {"D", "c"}, {"D", "r"}, {"M", "a"}]
```

I reverted the change before committing.

## Corpus offenders fixed by the intent test

The first real-corpus run reported exactly four non-canonical citations, all the hyphenated form of ADR 0002:

- `docs/research/OWNER-DNA.md:119`: rewritten as `ADR 0002`.
- `01-RESEARCH.md:385`, `:1150` and `:1156`: rewritten as prose ("the hyphenated form").

The test reported no other offenders. No file under `.planning/intent/sources/` was touched, and `git diff --name-status --diff-filter=DMTRCUXB main -- .planning/intent/sources/` prints nothing.

## Task Commits

1. **Task 1: Diff seam, CI base resolution and the intent test.** RED `995d927` (13 of 19 failing with the rules stubbed), then GREEN `592ff31`.
2. **Task 2: Contract-test rule and the real-repository seam tests.** RED `17587c9` (3 of 13 failing; the seam tests passed against Task 1's seam), then GREEN `0c77ade`.
3. **Task 3: CI-shape test, then push and PR #1 green.** RED `2c673f1` (53 of 59 failing), then GREEN `aad6aa2`. Pushed as a fast-forward `aa1ee71..aad6aa2` after a clean pre-push scan.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Correctness] The contract-test rule treats every non-addition as a change**
- **Found during:** Task 2
- **Issue:** D-21 names M and D. A type change (T, for example a test replaced by a symlink) would modify a guard without either status.
- **Fix:** `violations/1` flags any status other than A on a guard path. A is still allowed, and every synthetic case behaves as the plan lists.
- **Files modified:** test/planning/contract_rule_test.exs
- **Commit:** 0c77ade

**2. [Rule 2 - Correctness] Seam hardening**
- **Found during:** Task 1
- **Fix:**
  - `push_base` rejects a `before` that is not a full hex SHA before calling git.
  - Every git call scrubs `GIT_DIR`, `GIT_WORK_TREE` and `GIT_INDEX_FILE`, so a hook or nested context cannot point the seam at another repository.
  - `changes/2` reads `-z` output.
- **Files modified:** test/support/git_diff.ex
- **Commit:** 995d927, 592ff31

**3. [Note] The first RED commit was committed before formatting**
- `995d927` was committed before `mix format` ran, because the format call lacked the local `ASDF_ERLANG_VERSION`. `592ff31` carries the formatting, and `mix format --check-formatted` passes at every later commit.

**4. [Note] One mutation row was retargeted**
- The first alias row put `*thirty` on a `timeout-minutes` line, which also fired `timeout_not_literal`. The row now puts `*runner` on nightly's `runs-on`, which no other rule reads, so exactly `:anchor` fires.

### Honesty notes (ADR 0010)

- **The no-origin/main local path was simulated, not run.** The local repository has `origin/main`, so the plain local run included `:git_diff`. I exercised the not-run path with a one-parent `GITHUB_EVENT_NAME=pull_request` run instead.
- **INTENT-01 and CI-01 are advanced, not complete.** Two pieces of evidence are still missing: the D-22 red run (an intent-source edit failing ci-gate) and the first live ci-health shape scan on main. Both land in Plan 01-05.

## Watch item for Plan 01-05

`hex-publish.yml`'s `build` job runs `mix test --only release --only prod_guard` with `CI` set. There the event is `push` and no `EVENT_BEFORE` is set (that env lives only in ci.yml), so test_helper resolves `git merge-base origin/main HEAD`. The checkout uses `fetch-depth: 0`, which should provide `origin/main`. If it does not, test_helper raises and the build stops. That fails closed, but it is worth checking on the first release run.

## Pre-push scan

The scan (with `--untracked`, plus the noreply author and committer check) printed nothing before the push.

## Next Phase Readiness

- PR #1 stays a draft and is not merged. Plan 01-05 lands the ADR amendments, pushes this SUMMARY and runs the D-22 red run.
- This SUMMARY commit stays local, per the plan's output section.

## Self-Check: PASSED

- All 5 created files exist. Commits `995d927`, `592ff31`, `17587c9`, `0c77ade`, `2c673f1` and `aad6aa2` are ancestors of HEAD.
