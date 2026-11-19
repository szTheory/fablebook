---
phase: 02-bounded-asn-1-rtt-guard-evidence
plan: 01
subsystem: testing
tags: [elixir, otp, asn1, static-evidence]

requires:
  - phase: 01-bounded-guard-continuation
    provides: Locked EX-107 source archive and read-only lane-specific resolver
provides:
  - Core lane evidence and exact source/caller spans for the three approved ASN.1 RTT functions
  - Individual static caller controls and a byte-only `code/0` table check
affects:
  - 02-02-floor-evidence
  - 02-03-cross-lane-integration
  - 02-04-independent-review

actuals:
  tokens: 2725
  tasks: 2
  commits: 4

tech-stack:
  added: []
  patterns:
    - Lane-bound archive identity and complete-span digest assertions
    - Anchored byte-only grammar validation for the complete literal table

key-files:
  created:
    - test/support/asn1_rtt_core_evidence.ex
    - test/contract/asn1_rtt_core_guard_test.exs
  modified: []

key-decisions:
  - "Reuse the locked archive resolver and bind core RTT and caller bytes to their pinned identities."
  - "Keep dispositions static; validate the complete code/0 literal as bytes without parsing or execution."

patterns-established:
  - "Every core target span and caller path carries lane identity, line bounds, and a span digest."
  - "Each selected MFA has an independent positive caller probe and negative overlap/removal controls."

requirements-completed: []

coverage:
  - id: D1
    description: "Core lane source spans, direct caller paths, dispositions, and per-MFA static controls for the approved RTT selection."
    requirement: GRC-05
    verification:
      - kind: unit
        ref: "mix test test/contract/asn1_rtt_core_guard_test.exs --warnings-as-errors"
        status: pass
    human_judgment: true
    rationale: "The checks pin source bytes and control attribution; a reviewer still judges the source-backed dispositions."

duration: 22min
completed: 2026-11-12
status: complete
plan_head_before: 7ca5725a9f7e7f4fcae7c288f925a6752be787d6
plan_head_after: 37347edeeabd5a665d4378e3ee4d68c37c3c939b
commits: 4
---

# Phase 2 Plan 01: Core Evidence Summary

**Core ASN.1 RTT evidence binds all three approved functions and direct callers to the pinned OTP archive, with independent controls and a byte-only table check.**

## Performance

- **Duration:** 22 minutes
- **Started:** 2026-11-12T22:46:22Z
- **Completed:** 2026-11-12T23:07:52Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments

- Recorded core lane identities, complete source spans, direct caller paths, and static dispositions for `assert_defined/1`, `code/0`, and `dependencies/1`.
- Added one target-specific positive and negative caller control pair for each selected MFA.
- Checked the full `code/0` literal table with the anchored byte grammar, expected row count, and malformed-shape controls. The table remains unparsed and unevaluated.
- Kept runtime behavior, dynamic callers, native internals, SEC-01, the full EX-107 row, and its remaining complement explicitly open.

## Task Commits

1. **Task 1: Trace one core source citation through evidence to a passing contract**
   - `7412dba` — RED: failing `assert_defined/1` evidence assertion
   - `4c1307c` — GREEN: core `assert_defined/1` source and caller evidence
2. **Task 2: Complete core evidence and byte-only controls for all three selected functions**
   - `b6262b6` — RED: selected-function and individual-control assertions
   - `37347ed` — GREEN: complete core RTT evidence and byte controls

## Files Created

- `test/support/asn1_rtt_core_evidence.ex` — lane-bound source/caller evidence, dispositions, and per-function control definitions.
- `test/contract/asn1_rtt_core_guard_test.exs` — exact archive/span assertions, target-specific controls, and byte-only literal-table validation.

## Decisions Made

- Reused `SweepEvidence` for archive identity, containment, and line-bound checks.
- Kept the three selected functions separate from the historical 13-MFA selection and from the 174-member EX-107 complement.
- Left GRC-04 and GRC-05 pending because this plan supplies only core-lane evidence; floor evidence and cross-lane reconciliation remain outstanding.

## TDD Execution

- Task 1 RED run failed on the planned assertion because the evidence list was empty; its GREEN commit made the archived source and caller span contract pass.
- Task 2 RED run of the selected-function test failed on the planned exact-selection assertion while only the Task 1 entry was present; its GREEN commit added the remaining two entries and byte controls.
- The focused contract passed after each GREEN commit and again on the final task head.

## Dependency Setup

The first focused test attempt could not start because seven already-declared dependencies were absent locally. The owner approved `MIX_ENV=test mix deps.get`; it completed successfully and the dependencies are available. `mix.exs` and `mix.lock` remained unchanged at SHA-256 `020c0767840f658bf2b6eab7739a7d08a3ca0cd4515b78e02dd18e25056fc139` and `4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Corrected a malformed byte-literal test expression**
- **Found during:** Task 2
- **Issue:** The initial quote marker in the malformed-table control caused an Elixir syntax error.
- **Fix:** Represented the marker as the bytes `<<60, 60, 34>>`, preserving the byte-only check.
- **Files modified:** `test/contract/asn1_rtt_core_guard_test.exs`
- **Verification:** The focused core contract passed with `--warnings-as-errors`.
- **Committed in:** `37347ed`

**Total deviations:** 1 auto-fixed (Rule 1)
**Impact on plan:** The correction only repaired the planned malformed-shape control; scope and claims are unchanged.

## Issues Encountered

- The sandbox initially denied writes to the linked worktree's `.git` metadata. The already-authorized git operations then completed through the approved escalation path with hooks enabled; only task-scoped files were staged.
- No actual-library collision was observed. The collision stop remains in force if later evidence reveals one.

## User Setup Required

None. Dependency setup was approved and completed during execution.

## Next Phase Readiness

Core evidence is ready for the floor lane and later integration/review. No requirement or broader safety gate is closed by this plan. Continue with `$gsd-execute-phase 2` to execute the remaining approved Phase 2 plans.

---
*Phase: 02-bounded-asn-1-rtt-guard-evidence*
*Completed: 2026-11-12*

## Self-Check: PASSED

- Both core output files and this summary exist.
- All four task commits are ancestors of the current head.
- The measured task commit count is 4, matching `actuals.commits`.
