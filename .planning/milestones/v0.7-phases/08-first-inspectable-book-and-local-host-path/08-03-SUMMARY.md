---
phase: first-inspectable-book-and-local-host-path
plan: "03"
subsystem: router-contracts-and-production-guards
tags: [elixir, phoenix, compile-time, ci]
requires:
  - PR #99 hardened the public mount macro on main
provides:
  - Separate active public macro contract test
  - Development/test fixture inclusion and positive/negative production controls
  - Indexed operator-host development-adapter decision
affects: [phase-08-host-and-catalog]
actuals:
  tasks: 2
  files: 8
tech-stack:
  added: []
key-decisions:
  - "Keep the mount implementation and its contract test in distinct PRs, as required by ADR 0021."
  - "Prove dev/test inclusion with a compiled callable sentinel and retain clean-prod plus reachable-negative controls."
  - "Keep Bandit host-only and development-only; root dependency declarations and lockfiles stay unchanged."
requirements-completed: []
coverage:
  - id: MOUNT-01
    description: "The exact caller-AST contract is active on hardened main after its own test-only PR."
    verification:
      - kind: unit
        ref: "test/contract/mount_literal_ast_test.exs"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/44879867181"
        status: pass
    human_judgment: false
  - id: HOST-01/HOST-02 fixture controls
    description: "The fixture includes the sentinel in dev and test, excludes it from normal prod, and fails a reachable prod mount with the canonical error."
    verification:
      - kind: integration
        ref: "core and floor focused prod_guard_test runs; one test passed in each lane"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/44882143058"
        status: pass
    human_judgment: false
duration: "multi-session; active time not tracked"
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 08-03 Summary

**The separate macro contract and before-Book fixture controls are merged and green; exact Logistify source custody remains the next gate.**

## Accomplishments

- PR #100 added only `test/contract/mount_literal_ast_test.exs`, preserving ADR 0021's implementation/test split. Reviewed head `06b7cb4422241585356efc96ae757ab4aff73b46` passed required CI run 44879867181 and merged as `2b05a2ee302c0eacd8d53e03c5694678d01a55cc`.
- PR #101 added the dev/test compiled sentinel checks, the fixture configuration change, and indexed ADR 0027. It also corrected this plan's file list to include the contract test. Reviewed head `1380a45ec188151ad755c05862f719198d2cce7e` passed required CI run 44882143058 and merged as `5b08774fa915c53d54fcbdcb34c0844ec969f5eb`.
- The existing fixture contract now proves the mount and callable sentinel in both dev and test; normal prod retains its unrelated route without Fablebook routes or Story/Book BEAMs, and the reachable negative control emits the canonical production error.
- ADR 0027 keeps the future listener in `hosts/operator` with a separate development-only lock. Root library declarations and locks did not change.

## Verification

- `bin/planning_health --stage execute --phase 8` passed before execution and before this handoff update.
- Focused production-guard test passed in the primary checkout's core lane (1 test, 33.4s) and floor lane (1 test, 54.4s).
- PR #100 exact-head CI passed: core 10m56s (`mix ci` 10m40s), floor 9m28s (test 9m06s), Dialyzer 27s, security 29s, gate 4s. Post-merge main CI run 44880742370 passed.
- PR #101 exact-head CI passed: core 8m38s (`mix ci` 8m18s), floor 8m47s (test 8m19s), Dialyzer 24s, security 35s, gate 5s. Post-merge main CI [run 44884141633](https://github.com/szTheory/fablebook/actions/runs/44884141633) passed on merge `5b08774fa915c53d54fcbdcb34c0844ec969f5eb`; core and floor overlapped and floor was the critical path.
- The independent review in [08-03-REVIEW.md](08-03-REVIEW.md) found no issues. `git diff --check` and ADR index/root-lock checks passed.
- The isolated delivery worktree lacked installed Mix dependencies, so its duplicate focused test stopped before compilation. SHA-256 comparison confirmed its test and fixture files were identical to the successfully tested primary-checkout files; hosted CI also passed the exact candidate.
- `bin/verify_logistify_source --check-pinned` remains correctly blocked because the source excerpt manifest is missing. No source bytes or source-derived Book content were added.

## Next Readiness

Plan 08-03 is complete. Plan 08-04 remains gated by the pinned-source precondition. Resume only after the exact approved originals are readable and the source verifier passes; preserve all milestone limits and the visual-baseline owner gate.

---
*Phase: 08-first-inspectable-book-and-local-host-path*
*Plan: 08-03*
*Completed: 2026-11-21*
