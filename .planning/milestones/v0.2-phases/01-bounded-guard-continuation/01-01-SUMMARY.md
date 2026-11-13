---
phase: 01-bounded-guard-continuation
plan: "01"
subsystem: testing
tags: [OTP, inets, tracing, source-provenance, static-analysis]
requires: []
provides:
  - Hash-scoped core OTP source findings for the retained EX-010 inets trace row.
  - Archive, live graph, citation, and matcher-witness contracts for the core evidence.
affects: [01-02, 01-03, guard-coverage, inets]
actuals:
  tokens: 9108
  tasks: 2
  commits: 5
plan_head_before: bdbf4a589f41de0917bf4ce81d3ea04190e9d24e
plan_head_after: 420dd57a21769c6c332a9a67389092b02556c0cf
tech-stack:
  added: []
  patterns: [offline exact-source archive, live-graph equality, uncalled static-form controls]
key-files:
  created: []
  modified:
    - test/fixtures/guards/exact_sources.tar.gz
    - test/support/sweep_evidence.ex
    - test/contract/tier_sweep_test.exs
    - test/contract/banned_calls_test.exs
key-decisions:
  - "Keep EX-010 pending and the core checker status candidate-only until independent floor and integration work."
  - "Preserve the dynamic-caller and caller-supplied callback limits; static graph membership is not runtime proof."
patterns-established:
  - "Resolve source citations from exact pinned archive bytes even when installed source is available."
  - "Normalize live graph and manifest enumeration while rejecting reordered or incomplete canonical evidence records."
requirements-completed: []
coverage:
  - id: D1
    description: "Pinned core inets trace source and body-backed review record"
    verification:
      - kind: unit
        ref: "test/contract/tier_sweep_test.exs:8372"
        status: pass
    human_judgment: true
    rationale: "Tests establish provenance and citations; source semantics and the callback boundary require the recorded source review."
  - id: D2
    description: "Live membership, integrity, and individual exclusion-removal controls"
    verification:
      - kind: unit
        ref: "test/contract/tier_sweep_test.exs --only inets_trace_core_controls"
        status: pass
      - kind: integration
        ref: "tier_sweep_test.exs + banned_calls_test.exs full affected contract run"
        status: pass
    human_judgment: false
duration: 89min
completed: 2026-11-11
status: complete
---

# Phase 1 Plan 1: Core inets trace evidence Summary

**The core EX-010 row now has exact OTP source findings and independently falsifiable archive, graph, citation, and matcher-removal controls.**

## Performance

- **Duration:** 89 minutes (measured interval 2026-11-11T20:13:41Z–2026-11-11T21:42:40Z)
- **Task 1 interval:** 2026-11-11T20:13:41Z–2026-11-11T20:31:52Z
- **Task 2 interval:** 2026-11-11T20:35:48Z–2026-11-11T21:42:40Z
- **Tasks:** 2/2
- **Files modified:** 4
- **Actuals method:** 36,431 added/removed textual diff characters divided by four = 9,108 tokens as a diff-size proxy; this is not measured context consumption, which is unavailable. Git represents the exact-source archive as a binary diff.

## Accomplishments

- Added the exact OTP 29.1.2 core source `inets/src/inets_app/inets_trace.erl` (11,112 bytes, SHA-256 `1f67a0bda05227eddd8ffb4909ec8a31465ef2d8582e0ff9ff5d2b72638c7599`) at pinned ref `d199a49a01a2079afb6f2c5c9ae047cd4555e68d`. The archive now has 306 members; all 305 prior source-member bytes were preserved and the manifest was extended. Archive SHA-256: `36803a5ccbd928cbee99ca719cdb58baaf5fa88724e3d7040cb242ada6337b0c`.
- Reviewed the complete three-source core path: `inets.erl` (18,519 bytes / 566 lines), `inets_trace.erl` (11,112 bytes / 355 lines), and `runtime_tools/src/dbg.erl` (105,185 bytes / 3,197 lines), against the exact archived hashes. Citations resolve from archive bytes and each cited line is checked against its reviewed body.
- Reconciled the two selected exports, complete live match set, incoming and delegate edges, EX-011 ownership/matches, exact source identities, and individual non-vacuous EX-010 removal witnesses. Graph edge/export order and manifest row order are accepted after normalization; canonical record lists reject omission, duplication, and permutation.
- Added uncalled direct, capture, and apply static-form fixtures for both selected MFAs. Candidate destinations are reconciled without changing active Credo/BannedCalls behavior; benign controls remain intact.

## Source findings and limits

Both `inets:enable_trace/2,3` exports delegate unchanged arguments to `inets_trace:enable/2,3`. Arity 2 fixes the service to `all`; arity 3 validates `all`, `httpc`, or `httpd`. Destination clauses route list destinations to file output, integer destinations to the fixed IP trace port, `io` to standard output, and `{Fun, Data}` to `dbg:tracer(process, {Handler, HandlerData})`. `dbg` later invokes the caller-supplied handler with trace events and its data. The native path uses the fixed `trace_ip_drv` name from the runtime_tools private library directory. The reviewed path does not derive a module name or evaluator input from these arguments; the generated match specification compares the supplied level.

The findings are provisional and source-bounded. Caller callback implementation, callback semantics, dynamically registered callers, and native driver internals are not established here. Zero observed direct incoming graph edges is not evidence that dynamic callers do not exist. No audited API, callback, or atom sink was invoked. No production guard, explanation, or runtime behavior changed. EX-010 and EX-011 retain their pending status and original owners; `checker_status` is `candidate_only`. The core result awaits Plan 02's independent floor comparison and Plan 03 integration. No semantic verdict, SEC-01 runtime proof, aggregate completion, or delivery is claimed. The phase requirements GRC-01–GRC-03 remain Pending.

## Task Commits

1. **Task 1 RED: require core inets trace evidence record** — `9d843a7` (`test`).
2. **Task 1 GREEN: record core inets trace source review** — `28a78d9` (`feat`).
3. **Task 2 RED: distinguish provisional trace evidence and static forms** — `f8b1307` (`test`).
4. **Task 2 GREEN: prove core trace evidence integrity and exclusion witnesses** — `9300640` (`test`).
5. **Ordering invariance follow-up** — `420dd57` (`test`).

## Verification

- Task 1 RED intentionally failed because `Fablebook.Test.InetsTraceCoreEvidence` was not registered: exit 2, 0/1 target tests passed. Task 1 GREEN focused contract passed: exit 0, 1 passed / 94 excluded, 101.4s.
- Task 2 RED intentionally failed on the planned missing `checker_status` value (`nil` versus `:candidate_only`): exit 3, 1/2 selected tests passed. Static-form controls passed separately: exit 0, 1 passed / 113 excluded. Task 2 focused integrity controls passed: exit 0, 2 passed / 208 excluded, 60.4s.
- The first full contract run (default 60s test timeout) exited 2 after 782.9s with 208/210 passing: one stale expected archive hash and one slow archive extraction/write exceeding the per-test timeout in saved-settings receipt validation. Updated the expected archive hash and reran with a command-scoped `--timeout 180000` (repository defaults unchanged): exit 0, 210 passed, 692.6s.
- Ordering follow-up checks passed: controls exit 0, 1 passed / 95 excluded, 79.8s; source line selection exit 0, 4 passed / 92 excluded, 112.6s. `git diff --check` and Elixir syntax parsing passed.

## Decisions Made

- No active checker change was justified by this core-only review; retain the exclusion as a candidate pending floor and integration decisions.
- Keep the original dynamic-caller limitation and caller-code boundary explicit, even though this graph has no direct incoming edges.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Updated the archive digest assertion after adding the exact source member.**
- **Found during:** Task 2 full contract verification.
- **Issue:** The existing source-corruption contract asserted the prior archive digest.
- **Fix:** Updated the test expectation to the new exact archive digest.
- **Files modified:** `test/contract/tier_sweep_test.exs`.
- **Verification:** Full affected contracts passed 210/210 with the updated expectation.
- **Committed in:** `9300640`.

**Total deviations:** 1 auto-fixed issue. The command-scoped test timeout was used only for the rerun; no project timeout setting changed.

## Issues Encountered

The default per-test timeout was too short for the existing archive extraction and receipt-validation test on the full run. The stack ended while writing extracted archive files; no hang or deadlock was indicated. A 180-second timeout on that one test command completed successfully. No machine-wide process cleanup or restart was performed.

## User Setup Required

None.

## Next Phase Readiness

Plan 01 is complete and its exact-source core evidence is ready for Plan 02's separate floor review. Plan 03 must still integrate both lanes and retain all existing gates. The phase remains executing at Plan 02 of 3; phase and milestone completion are not claimed.

## Self-Check: PASSED

The summary exists, and task commits `9d843a7`, `28a78d9`, `f8b1307`, `9300640`, and `420dd57` are ancestors of the current branch head.

---
*Phase: 01-bounded-guard-continuation*
*Completed: 2026-11-11*
