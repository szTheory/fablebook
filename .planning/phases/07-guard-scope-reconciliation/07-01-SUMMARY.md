---
phase: 07-guard-scope-reconciliation
plan: 01
subsystem: evidence-reconciliation
tags: [lane-pins, membership, fail-closed]
requires: [accepted ENV06 receipt, root lane lockfiles, saved Phase 3 and Phase 6 evidence]
provides:
  - Exact core lane identity stop receipt
  - Fixed-input membership validator for accepted ENV06 evidence
affects: [RSC-01, RSC-02]
tech_stack:
  added: []
  patterns: [Python standard-library strict parser, fixed evidence allowlist]
key_files:
  created:
    - .planning/phases/07-guard-scope-reconciliation/07-RECONCILIATION.json
    - .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py
    - .planning/phases/07-guard-scope-reconciliation/07-01-SUMMARY.md
  modified:
    - .planning/STATE.md
    - .planning/ROADMAP.md
decisions:
  - Stop Plan01 at the core lane digest mismatch; do not edit the accepted pin or combine evidence generations.
  - Do not calculate a family or create a source schedule until the owner decides whether to rescope the core lane identity.
requirements-completed: []
duration: 23m
completed: 2026-11-19
status: halted
actuals:
  tokens: 5366
  tasks: 1
  commits: 1
---

# Phase 07 Plan 01: Guard Scope Reconciliation Summary

The accepted ENV06 evidence is intact, but the current core `mix.lock` digest differs from its saved lane identity. Plan01 recorded the exact mismatch and stopped before any family, complement, or source schedule was created.

## Result

- The accepted receipt is passed for generation `ENV-20261117-06-supported-20261117T204102Z`.
- Its typed-gap file has 9,716 rows, 19,633,625 bytes, and SHA-256 `128032ab929f831bb516186bbe9844b6bd36e0b55327a9cc998f16c65b0d4011`; lane row counts are core 4,944 and floor 4,772. The accepted association file has zero rows.
- Core expected lock SHA-256 `4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85`; current root `mix.lock` SHA-256 `31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112`. Both lock records pin Phoenix 1.8.16, but the full core lock identity does not match.
- Floor expected and observed `mix.floor.lock` SHA-256 both equal `ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847`; both records pin Phoenix 1.8.9.
- The ENV06 receipt records Elixir 1.20.4 / OTP 29 for core and Elixir 1.18.5 / OTP 27 for floor. The historical Phase 6 receipt records OTP 29.1.2 / 27.3.4.9. Current runtime versions are not present in the allowlisted lockfile/receipt inputs and were not observed.
- The validator reads only the Plan01 evidence allowlist plus its reconciliation record. It does not open any recorded source path.

## Stop and next decision

The membership validator confirms the fail-closed stop. Exact membership equality was not asserted after the core identity mismatch. Task 2's precondition therefore did not pass: no proposed family, complement, or `07-SOURCE-SCHEDULE.json` was produced. No target source body was read; R9 remains unconsumed.

The owner must decide whether to rescope the core lane pin/evidence provenance and authorize a fresh Plan01 identity and membership reconciliation. Recommendation: keep the stop, do not rewrite the saved baseline in this plan, and hold Plans 02–04 until that decision. Phase 7 remains open; all inherited safety stops remain active.

## Verification

- `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --stage membership` — confirmed the recorded core digest mismatch, matching floor pin, accepted ENV06 generation and row counts, no partition/schedule, and no target source reads.

## Deviations from Plan

None. The recorded stop is the plan's required outcome for an unexplained lane identity mismatch. The conditional partition and schedule task was not entered because its precondition requires both lane identities and memberships to reconcile.

## Known Stubs

None. `proposed_family: null` and `source_schedule: null` are intentional fail-closed values, not incomplete data placeholders.

## Self-Check: PASSED

- Reconciliation record and validator exist.
- Task1 commit `0db9cd0` is an ancestor of the current branch.
- No target source schedule or target source body read was produced.
