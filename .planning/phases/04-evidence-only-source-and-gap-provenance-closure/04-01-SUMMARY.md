---
phase: 04-evidence-only-source-and-gap-provenance-closure
plan: "01"
subsystem: planning
tags: [provenance, metadata, source-gates]

# Dependency graph
requires:
  - phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
    provides: retained Phase 3 lane identities, MFA metadata, and immutable gap receipts
provides:
  - Exhaustive metadata-only unresolved partition and validator
  - Closed source request schedule with honest cumulative-fit status
affects: [phase-03-plan-03-05, phase-04-plans-02-and-03]

# Actuals (#2632)
actuals:
  tokens: 4980903
  tasks: 2
  commits: 3

# Tech tracking
tech-stack:
  added: []
  patterns: [machine-selected metadata partition, fail-closed source schedule]

key-files:
  created:
    - 04-validate-artifacts.py
    - 04-PROVENANCE-MANIFEST.json
    - 04-TARGET-SOURCE-ASSOCIATIONS.jsonl
    - 04-TYPED-GAPS.jsonl
    - 04-SOURCE-SCHEDULE.json
    - 04-RESOURCE-LEDGER.json
    - 04-01-SUMMARY.md
  modified: []

key-decisions:
  - Preserve the three expected/current file-hash mismatches as provenance gaps; source access remains closed.
  - Keep cumulative usage and remaining balance unknown because the executor child runtime did not expose attributable token records.

patterns-established:
  - Metadata blockers remain explicit typed rows with exact keys and null unavailable source fields.
  - A passing blocked-consistency check confirms the stop record only; it does not grant source access.

requirements-completed: []
duration: 33m
completed: 2026-11-17
status: complete
outcome: blocked-metadata-closeout
---

# Phase 4 Plan 01: Metadata partition and closed source schedule

Plan 04-01 completed its metadata-only route. Both lanes contain 226 identities and corroborate against retained authority: 221 archived IDs plus five preserved lane IDs. The partition contains 9,716 unresolved rows, including 2,469 core keys, 2,380 floor keys, and 18 unknown target sets.

Three preservation hashes differ from their immutable expected values: `03-04-EXECUTION-SOURCE-SCHEDULE-COMPACT.md`, `test/support/guard_aggregate_reconciliation_evidence.ex`, and `test/contract/tier_sweep_test.exs`. These files were touched by the authorized citation/formatting repairs, but this metadata-only check does not establish that the byte changes are limited to those edits. The manifest records both hashes. The request schedule remains blocked with `source_access=closed`; review, source-request preflight, and direct count are `not_run`, and cumulative fit is `unverifiable`. The resource ledger retains null usage and balance values because this executor runtime did not expose exact child-session accounting.

## Performance

- **Duration:** approximately 33 minutes, including the validator correction and metadata verification
- **Started:** 2026-11-17T13:53Z
- **Completed:** 2026-11-17T14:27Z
- **Tasks:** 2
- **Files created:** 7

## Task Commits

1. **Task 04-01-01: Materialize and validate the exhaustive unresolved partition** — `7b24c19`
2. **Task 04-01-02: Write the exact request schedule and fail-closed budget ledger** — `1fbd36c`
3. **Plan metadata:** summary commit recorded separately

## Files Created

- `04-validate-artifacts.py` — standard-library-only metadata partition and schedule validator
- `04-PROVENANCE-MANIFEST.json` — identities, selectors, preserved inputs, and three hash mismatches
- `04-TARGET-SOURCE-ASSOCIATIONS.jsonl` — empty because no source association passed provenance
- `04-TYPED-GAPS.jsonl` — retained unresolved membership and source/caller gaps
- `04-SOURCE-SCHEDULE.json` — blocked R1 schedule with missing spans and gates
- `04-RESOURCE-LEDGER.json` — active cap, protected reserve, and unknown measured usage

## Verification

- `--self-test`: pass, 15 checks; repository inputs unchanged
- `--partition`: returned the expected blocked result because metadata requires the explicit blocked mode
- `--partition --blocked`: `blocked_consistent`; 9,716 rows and three preservation mismatches
- `--schedule`: `blocked_consistent`; source gate closed and fit unverifiable
- `git diff --cached --check`: pass for both task commits
- No source body was analyzed, no direct count or lane/ExUnit suite ran, and no dependency was installed.

The first blocked partition attempt exposed a validator field-name mismatch. The checker was corrected to count the manifest's explicit `unknown_baseline_target_ids`; the ordered checks then passed on the blocked route.

## Next Phase Readiness

Phase 4 Plan 04-01 is complete as a blocked metadata result. Continue Plans 04-02 and 04-03 only on their preplanned blocked closeout branches; source analysis remains prohibited while usage attribution and the exact source gates are unresolved. Phase 3 Plan 03-05 Tasks 2–3 remain pending that closeout and any future approved source gate. The next actor is Codex; no owner action is needed now.
