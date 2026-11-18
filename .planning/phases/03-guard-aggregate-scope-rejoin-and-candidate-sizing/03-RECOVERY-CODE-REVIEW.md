---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
reviewed: 2026-11-18T17:27:32Z
depth: standard
files_reviewed: 5
files_reviewed_list:
  - mix.exs
  - test/contract/ci_shape_test.exs
  - test/contract/guard_aggregate_metadata_test.exs
  - test/contract/tier_sweep_test.exs
  - test/support/guard_aggregate_reconciliation_evidence.ex
findings:
  critical: 0
  warning: 0
  info: 0
  total: 0
initial_findings:
  warning: 1
  total: 1
  necessity: 0
status: pass_after_recheck
---

# Phase 03: Recovery Code Review Report

**Reviewed:** 2026-11-18T17:27:32Z
**Depth:** standard
**Files Reviewed:** 5
**Status:** pass after recheck

## Summary

Reviewed the Mix test-file filtering change, the CI-shape contract, the metadata gap contract, the aggregate reconciliation helpers, and their tier-sweep callers. The source/caller joins remain fail-closed, candidate authorization remains closed, and the extracted helper paths preserve the validated association and gap checks. The initial review found one metadata-test coverage weakness: it could accept an extra row with an unrecognized `record_type`. That finding is resolved below; it was not evidence that the current index was malformed.

The corrected CI command is `MIX_ENV=test bin/lane core mix ci`; the executor reports it passed (454 tests, 10 excluded). The no-prefix `bin/lane core mix ci` attempt is an invocation mismatch because the workflow runs with `MIX_ENV=test`; it is not treated as valid CI evidence. The latest metadata contract test also passed on both pinned lanes.

## Resolved initial finding

### WR-01: Metadata index contract accepts unrecognized extra rows

**Severity:** WARNING
**File:** `test/contract/guard_aggregate_metadata_test.exs:36`
**Issue:** The test partitions rows into the two recognized record types, verifies those filtered sets against expected membership and counts, then checks that the receipt's total merely equals the parsed row count. A third row with an unknown `record_type` and a valid lane input hash is excluded from both filtered sets, while the receipt and hashes can be updated to match it; the contract would still pass. The plan requires the hash-bound index to contain exactly 4,815 rows, with 4,797 known gaps and 18 unknown target sets.
**Fix:** Assert `length(rows) == 4_815` and that every row has one of the two allowed record types, then require the receipt total to equal 4,815. This makes the row-schema and exact-total contract reject added or unclassified rows.

**Resolution:** The standalone contract now asserts the exact 4,815-row total, allows only `known_target_gap` and `unknown_target_set`, and pins the receipt total to 4,815. The focused metadata test passes on both core and floor (1 passed each, 0.1 seconds). No review findings remain open.

## Confirmed Clean Areas

- `mix.exs` and `ci_shape_test.exs` consistently exclude `test/support/` from Mix test discovery while retaining the existing fixture filter.
- `validate_aggregate_lane!/1` checks source-join completeness against the recorded target-source gaps; source coverage and closure remain independently required for sizing evidence.
- `attach_target_sources!/3` records one explicit status per live target and retains the no-target `not_applicable` case; validators check membership, row status, keys, and associations.
- Caller attachment still validates target-source closure first, so the unbound source mappings fail closed before caller evidence can be attached.
- The tier-sweep changes extract the prior aggregate mapping and creator-match logic into helpers; no behavioral defect was confirmed in those changes.

---

_Reviewed: 2026-11-18T17:27:32Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
