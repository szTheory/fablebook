---
phase: 06-bounded-ex-177-provenance-supplement
plan: 01
subsystem: evidence
tags: [EX-177, provenance, Python]

requires:
  - phase: 05
    provides: Four selected EX-177 keys and the archived pending complement
provides:
  - Machine-readable provenance supplement for the four reviewed source/caller keys
  - Local allowlisted checker for lane facts, exact membership, complement, and preserved stops
affects: [GSR-07, guard-aggregate]

actuals:
  tokens: 6887
  tasks: 1
  commits: 2
  plan_head_before: f78804b1d5cfc5c80a73af390169a659daff2dab
  plan_head_after: d170877a241696fd0b15c20dcc6f39fedf5c87ae

tech-stack:
  added: []
  patterns:
    - Explicit allowlist for saved evidence reads
    - Raw-line digest for the exact pending complement

key-files:
  created:
    - .planning/phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json
    - .planning/phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py
  modified: []

key-decisions:
  - "Keep Phoenix paths as recorded string values; the checker reads only its fixed saved-evidence allowlist."
  - "Treat one observed direct run/1 call per lane as non-exhaustive caller evidence."

requirements-completed: [GSR-07]

coverage:
  - id: D1
    description: "Four-key supplement binds both lane identities, source facts, spans, and the exact complement."
    requirement: GSR-07
    verification:
      - kind: other
        ref: "python3 .planning/phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py --check"
        status: pass
    human_judgment: false
  - id: D2
    description: "Focused controls reject scope, source-fact, citation, complement, stop-state, and path-boundary drift."
    requirement: GSR-07
    verification:
      - kind: other
        ref: "python3 .planning/phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py --self-test"
        status: pass
    human_judgment: false

metrics:
  duration: 17 min
  completed: 2026-11-19
  status: complete
---

# Phase 6 Plan 1: Bounded EX-177 provenance supplement Summary

**Four reviewed EX-177 source/caller observations are machine-readable, with the 9,712-row complement and all existing stops preserved.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-11-19T15:15:51Z
- **Completed:** 2026-11-19T15:33:11Z
- **Tasks:** 1
- **Files created:** 2 task artifacts

## Accomplishments

- Added exactly four keyed observations: one source and one caller row for each lane.
- Bound both lane pins, source byte counts and digest, helper definition span, and the observed direct call span to the reviewed discovery and archived Phase 5 scope.
- Added a standard-library checker with fixed evidence inputs, exact row selection, raw-line complement digest validation, preserved-stop checks, and a value-only source-path boundary.
- Passed the focused self-test with ten negative controls.

## Task Commits

1. **Task 1: Record and validate the four reviewed EX-177 observations end to end** — `78b7bbc` (feat)
2. **Task 1 boundary hardening** — `d170877` (fix)

The separate owner-authorization record is `f78804b`. Plan metadata is recorded in the plan completion commit containing this summary.

## Files Created/Modified

- `.planning/phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json` — lane facts, four observation citations, complement binding, and open-stop states.
- `.planning/phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py` — standard-library checker that reads only its explicit saved-evidence allowlist.

## Decisions Made

The source paths remain provenance values. The checker extracts them from the reviewed discovery table, compares them as strings, and rejects them before any file access because they are absent from its read allowlist.

## Deviations from Plan

### Auto-fixed Issues

**1. [Project instruction — authorization provenance] Recorded the owner's separate execution authorization**

- **Found during:** Phase start
- **Issue:** The existing handoff stated that Phase 6 execution required a separate owner decision.
- **Fix:** Added an append-only intent entry quoting `$gsd-execute-phase 6` and carrying forward the plan's exact limits.
- **Files modified:** `.planning/intent/sources/2026-11-19-03-authorize-phase6-execution.md`
- **Verification:** The execute preflight passed before the entry was added; the recorded command matches the owner instruction.
- **Committed in:** `f78804b`

**2. [Rule 1 — Safety boundary] Kept source paths out of checker path constants**

- **Found during:** Task 1
- **Issue:** Repeating the recorded Phoenix paths as checker constants made the value-versus-input boundary less clear.
- **Fix:** Extracted each path from the reviewed discovery report as a string; the checker permits reads only from its fixed allowlist and self-tests rejection of both recorded values.
- **Files modified:** `.planning/phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py`
- **Verification:** `--check`, `--self-test`, and the allowlist inspection passed.
- **Committed in:** `d170877`

**Total deviations:** 2 required or safety-focused adjustments. **Impact:** No source reads, new scope, product behavior, or gate changes.

## Issues Encountered

The first checker draft expected the complement digest and R9 disposition to appear in the Phase 5 context prose. Those facts are authoritative in the archived R9 result and the raw JSONL; the checker was corrected to validate each fact against its proper saved record. No disagreement among the approved evidence was found.

## User Setup Required

None.

## Next Phase Readiness

The plan artifacts and local checks are complete. Phase-level review, security and validation gates remain to run. Candidate fit remains unresolved, the candidate is null, the aggregate gate remains open, R9 remains denied and unconsumed, Walking Skeleton remains blocked, SEC-01 remains Pending, actual library collision remains unknown, and the Macro and legacy digest questions remain open. No automatic follow-up is authorized.

---
*Phase: 06-bounded-ex-177-provenance-supplement*
*Completed: 2026-11-19*
