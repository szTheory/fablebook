---
phase: first-inspectable-book-and-local-host-path
plan: "02"
subsystem: compiler
tags: [elixir, macros, phoenix, contracts]
requires: []
provides:
  - Literal-only public Book mount implementation, merged separately from its contract test
affects: [phase-08-production-controls]
actuals:
  tokens: 3000
  tasks: 2
  commits: 3
tech-stack:
  added: []
  patterns: ["Validate caller AST before alias resolution and raise a caller-located CompileError"]
key-files:
  created: [test/contract/mount_literal_ast_test.exs]
  modified: [lib/fablebook/router.ex, .planning/CI-PERFORMANCE.md]
key-decisions:
  - "Accept only literal alias ASTs and existing module-reference atoms before calling Macro.expand/2."
  - "Keep the contract test in its own test-only PR; PR #99 contains only the router implementation."
patterns-established:
  - "Public macro input is checked syntactically before resolution or expansion."
requirements-completed: []
coverage:
  - id: D1
    description: "The public mount macro accepts literal Book module forms and rejects computed forms before expansion."
    requirement: MOUNT-01
    verification:
      - kind: unit
        ref: "test/contract/mount_literal_ast_test.exs#Fablebook.Contract.MountLiteralASTTest"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/44874757036"
        status: pass
    human_judgment: true
    rationale: "MOUNT-01 also requires the separately delivered test-only PR; Plan 08-03 owns that remaining delivery."
duration: "multi-session; active time not tracked"
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 08-02 Summary

**The router-only literal Book AST guard is merged after exact-head CI, with the authored contract retained for its separate test-only PR.**

## Accomplishments

- Authored and retained a public-macro contract covering caller aliases, fully qualified aliases, literal module references, variables, attributes, dynamic alias components, computed terms, macro calls, and non-module values.
- Proved the original router's selected rejection probe failed for the expected reason: the harmless disallowed macro expanded before the guard.
- Changed the non-production macro path to validate literal alias/reference syntax before resolution. Invalid forms raise a caller-located `CompileError`; the production branch and its canonical diagnostic remain unchanged.
- Merged PR #99 with only `lib/fablebook/router.ex` in its diff. Reviewed head `1c786ffdb7b10c681390e9fe4238c2d7d2184019` passed required hosted CI and was squash-merged as `a60d21b8cf513f400fee3363c3f6b6aa23031857`.
- Preserved test and implementation separation required by ADR 0021. The retained test's current blob is `29b3507e7ffbead85e43e3bf9c48523da5c027d4`; it will be applied from its two test-only commits in Plan 08-03.

## Verification

- Original baseline: `fbaeafc06a8834bb736688bce39a8d351231e139`; the selected `:mount_rejection_probe` failed with `disallowed Book macro expanded` while the router was unchanged.
- Focused literal-AST and production-message contracts passed: 4 tests.
- Selected rejection probe passed after implementation: 1 test.
- Strict Credo on the pinned core lane passed after replacing the atom-creating `Module.concat/2` test example with `Enum.at/2`.
- Full local core lane passed: 464 passed, 10 configured exclusions; ExUnit took 397.9s.
- Independent code review found no actionable defects.
- PR #99 required hosted CI passed on the exact reviewed head: core, floor, security, Dialyzer, and `ci-gate`. Post-merge triggered only the `release-please` workflow; its publish job was skipped, and no separate main CI run was triggered.

## Task Commits

1. **Task 1: Author the public macro contract and prove its red baseline** — `4d1241b` and test-only follow-up `3f1eb6a`.
2. **Task 2: Harden the macro and land only the implementation** — implementation `c078c7f`, cherry-picked as PR head `1c786ff`.

The independent review is recorded in [08-REVIEW.md](08-REVIEW.md). Exact hosted run timings and the CI assessment are in [CI-PERFORMANCE.md](../../CI-PERFORMANCE.md).

## Decisions Made

- No CI structure, cache, dependency, or coverage change is justified by these runs. Core and floor already run concurrently, setup took 7–11 seconds, queue was 3 seconds, and test steps dominated.
- The local `act` setup stop remains unchanged; the known failing setup was not retried.

## Issues Encountered

- Credo rejected the initial computed test probe because `Module.concat/2` can create atoms. The test-only probe was changed to `Enum.at/2`, then strict Credo and the complete core lane passed.

## Next Phase Readiness

- The router implementation and separate contract test are both merged: PR #99 (`a60d21b8cf513f400fee3363c3f6b6aa23031857`) and PR #100 (`2b05a2ee302c0eacd8d53e03c5694678d01a55cc`). The active contract's exact-head CI passed in run 44879867181.
- Plan 08-03 completed the development/test sentinel and positive/negative production fixture controls in PR #101, merged as `5b08774fa915c53d54fcbdcb34c0844ec969f5eb`; candidate and post-merge CI passed.
- Plan 08-01 remains halted because the excerpt manifest and exact originals are missing. Do not start host or Book implementation until the approved source originals are readable and the pinned verifier passes.

---
*Phase: 08-first-inspectable-book-and-local-host-path*
*Plan: 08-02*
*Completed: 2026-11-21*
