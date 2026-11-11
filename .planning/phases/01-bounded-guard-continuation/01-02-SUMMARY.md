---
phase: 01-bounded-guard-continuation
plan: "02"
subsystem: testing
tags: [OTP, inets, tracing, source-provenance, static-analysis]
requires:
  - phase: 01-bounded-guard-continuation
    provides: Core EX-010 source findings and archive/graph contracts from Plan 01.
provides:
  - Independent OTP 27.3.4.9 floor-lane EX-010 findings bound to exact archived source.
  - Complete floor matcher membership, lane-specific source resolution, and per-MFA removal controls.
  - Floor-only adverse archive, review, citation, overlap, and uncalled-form controls.
affects: [01-03, guard-coverage, inets]
actuals:
  tokens: 8847
  tasks: 2
  commits: 5
plan_head_before: cb6d0358576e6a30028f2bab9838f92671d4d4c6
plan_head_after: c18e16700f4121bfc962599e5acc3e934bcac685
tech-stack:
  added: []
  patterns: [lane-keyed exact-source archive identities, full matcher-set equality, individual removal and overlap witnesses]
key-files:
  created: []
  modified:
    - test/fixtures/guards/exact_sources.tar.gz
    - test/support/sweep_evidence.ex
    - test/contract/tier_sweep_test.exs
    - test/contract/banned_calls_test.exs
    - test/test_helper.exs
key-decisions:
  - "Keep EX-010 pending and checker status candidate-only; the floor source review does not decide integration or runtime safety."
  - "Resolve the identical source path separately by lane so core citations cannot be supplied by floor bytes or vice versa."
  - "Run the two core-only EX-010 tests on the core lane and exclude only those tagged tests from the floor lane."
patterns-established:
  - "Key source authority by lane plus source path when two pinned versions share a path."
  - "Demonstrate each retained matcher by removing only that matcher from the live exclusion set and checking that each selected MFA becomes uncovered."
requirements-completed: []
coverage:
  - id: D1
    description: "Complete exact-source floor review for both EX-010 exports with lane-bound citations."
    verification:
      - kind: unit
        ref: "test/contract/tier_sweep_test.exs --only inets_trace_floor_source"
        status: pass
    human_judgment: true
    rationale: "The contracts establish exact source identity and cited text; deciding the callback and native boundaries still requires source interpretation and Plan 03 integration."
  - id: D2
    description: "Individual floor matcher-removal witnesses and adverse archive/static-form controls."
    verification:
      - kind: integration
        ref: "bin/lane floor test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs --only inets_trace_floor_controls"
        status: pass
      - kind: integration
        ref: "bin/lane floor test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs"
        status: pass
    human_judgment: false
    rationale: "Automated static controls pass; runtime behavior and final cross-lane semantics remain outside this acceptance claim."
duration: 40min
completed: 2026-11-11
status: complete
---

# Phase 1 Plan 2: Independent floor inets trace evidence Summary

**OTP 27.3.4.9 floor EX-010 findings now have exact archived source authority, complete matcher equality, per-MFA removal witnesses, and falsifiable adverse controls.**

## Performance

- **Duration:** 40 minutes (2026-11-11T21:55:50Z–2026-11-11T22:36:06Z)
- **Task 1 interval:** 2026-11-11T21:55:50Z–2026-11-11T22:05:41Z
- **Task 2 interval:** 2026-11-11T22:09:02Z–2026-11-11T22:36:06Z
- **Tasks:** 2/2
- **Files modified:** 5
- **Task commits:** 5, measured from the persisted Plan 01-02 head ledger.
- **Actuals method:** 35,391 added/removed textual diff characters divided by four = 8,847 tokens as a diff-size proxy. This is not measured context-token use; that value is unavailable. The binary archive diff is not represented in this textual proxy.

## Accomplishments

- Added the exact OTP 27.3.4.9 floor `inets_trace.erl` source (11,073 bytes, SHA-256 `3e03ac1b03d2a01e7ddb1b1e29543e632aa3a63e16aa1f5a8c19ba935ae4dffd`) at OTP ref `4aa809ae4eb4a20ad89c23837376acf179877f39`. Extended the source archive to 307 members, preserved prior source-member bytes while extending the manifest, and pinned archive SHA-256 `7d4bd66fe72224cf49f849148b5e737443588ca66c12873938bfa30fa3d0ea58`.
- Reviewed all three complete floor source files against their exact archived bytes: `inets.erl` (18,409 bytes; SHA-256 `d8786fea1edde0d055e7198cdb279e9a1999daa070d4dc229f3ec66b75e8bd5e`), `inets_trace.erl` (11,073 bytes; SHA-256 above), and `runtime_tools/src/dbg.erl` (112,878 bytes; SHA-256 `808aa7980e020fc529e153fc907b606fd0e2ff5fb4ad0b74e548b5eafaea0dae`). Citations resolve from the lane-specific archive entries.
- Reconciled the complete live floor EX-010 matcher set against both selected exports, disjoint remainder, incoming/delegate edges, and the original EX-010 row. Each selected MFA has a removal witness that removes only EX-010 and verifies no remaining exclusion covers it; overlapping call-name and boundary exclusions are checked as well.
- Added floor source tampering and archive controls for omitted/duplicate source and review records, changed citations, wrong lane/ref/size/hash, missing archive member, and core bytes substituted into the floor archive path. Added uncalled direct, capture, and apply forms for each selected MFA and a benign API control.
- Scoped the two core-only EX-010 tests so the floor runner does not resolve core citations through floor evidence. Ran the source and controls on the actual core lane; both passed. The complete floor run executed 211 tests and excluded only these two separately verified core-only tests.

## Source findings and limits

Both floor `inets:enable_trace/2,3` exports delegate to `inets_trace:enable/2,3`. Arity 2 supplies service `all`; arity 3 accepts only `all`, `httpc`, or `httpd` before destination handling. List destinations open a file, integer destinations use the fixed IP trace port, `io` selects standard output, and `{Fun, Data}` passes a caller-provided function and data to the process tracer. `dbg` later invokes that handler for trace events. The native path uses the fixed `trace_ip_drv` name. The supplied integer level is inserted in a fixed comparison match specification; the reviewed path does not derive evaluator input, module names, or atoms from these arguments.

This is a source-bounded static finding. The caller's callback implementation, dynamic callers, and native driver internals remain outside the review. Zero direct incoming edges is not proof that dynamic callers do not exist. The compile-only direct/capture/apply fixtures were not invoked. No production guard, public API, or semantic disposition changed. EX-010 and EX-011 retain their existing owners and pending statuses; the floor evidence remains `candidate_only`. No phase requirement, aggregate gate, runtime proof, integration verdict, or delivery is closed.

## Task Commits

1. **Task 1 RED: require floor inets trace evidence record** — `ad90303` (`test`).
2. **Task 1 GREEN: record independent floor inets trace findings** — `b6f02d8` (`feat`).
3. **Task 2 RED: add floor matcher-removal witness contract** — `8193661` (`test`).
4. **Task 2 GREEN: prove floor exclusion removal witnesses** — `70c843a` (`test`).
5. **Task 2 adverse controls follow-up** — `c18e167` (`test`).

## Verification

- Task 1 RED failed on the missing floor evidence module, exit 2. Task 1 focused floor source contract passed: 97 tests, 0 failures, 1 selected / 96 excluded.
- Task 2 RED reached the runtime assertion for the absent individual witness field: exit 2, 1 failure / 211 excluded. Earlier compile-time or mismatched-assertion attempts were invalid REDs and are not counted as evidence.
- Focused floor witness and uncalled-form controls passed: exit 0, 213 tests total, 0 failures, 2 selected / 211 excluded. After adding archive tampering controls, the focused run again passed with the same 2 selected tests.
- The complete affected floor contract command passed: exit 0, 213 tests total, 0 failures, 211 executed / 2 core-only excluded.
- Core-only EX-010 source and controls passed on the actual core lane: exit 0, 2 passed / 96 excluded. A prior run exposed an outdated wrong-lane archive fixture expectation; the fixture was corrected to mutate only the core row and now asserts the intended source-root failure.
- `git diff --check` passed before the task commits. The final adverse controls change only the contract test file; the complete affected floor suite had already passed after all authority and test-helper changes.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking issue] Support identical archived source paths in separate lanes.**
- **Found during:** Task 1
- **Issue:** The resolver treated `inets_trace.erl` as core-only and could not validate the floor archive identity while preserving both lanes.
- **Fix:** Keyed the existing source identity validation by `{lane, source_path}` and tested lane-specific archive resolution and inventory.
- **Files modified:** `test/support/sweep_evidence.ex`, `test/contract/tier_sweep_test.exs`, `test/fixtures/guards/exact_sources.tar.gz`.
- **Verification:** Focused floor source contract and complete floor contracts passed.
- **Committed in:** `b6f02d8`.

**2. [Rule 3 - Blocking issue] Keep core-only EX-010 evidence on the core resolver.**
- **Found during:** Task 2 full-suite preparation
- **Issue:** The floor runner would execute the existing core-only source tests with floor `source_roots!()`, risking wrong-lane citations.
- **Fix:** Tagged only the two core EX-010 tests for the core lane, excluded that tag on floor, and ran those tests separately on core.
- **Files modified:** `test/test_helper.exs`, `test/contract/tier_sweep_test.exs`.
- **Verification:** Core focused run passed 2/2; full floor run excluded exactly those two and passed 211/211 executed tests.
- **Committed in:** `70c843a`.

**3. [Rule 1 - Bug] Correct the existing wrong-lane archive control for two lane identities.**
- **Found during:** Task 2 core focused verification
- **Issue:** The existing negative fixture changed both core and floor manifest rows because it matched only `source_path`; changing the core row's lane also changes the intended failure from source identity to source-root mismatch.
- **Fix:** Mutated only the core lane row and asserted the resulting `:source_root` failure. Added matching floor-specific negative cases for lane/ref/size/hash, records, member presence, and cross-lane bytes.
- **Files modified:** `test/contract/tier_sweep_test.exs`.
- **Verification:** Actual-core focused run and floor adverse-control focused run passed.
- **Committed in:** `70c843a` (core fixture correction), with floor-specific adverse controls in `c18e167`.

**Total deviations:** 3 auto-fixed issues. They were limited to lane-specific offline test/archive correctness; production code and active guard behavior were not changed.

## Source and context fit

The approved full floor source baseline is 38,888 historical tokens plus the full 31,000-token reserve, a 69,888-token raw planning projection below the 100,000 per-context ceiling. Exactly the three approved floor files were read; no new source boundary was consumed. These are sizing inputs, not measured token consumption. Semantic source interpretation is recorded review work, not an outstanding request for owner UAT.

## Next Phase Readiness

Plan 02 is complete. Its hash-bound floor findings and controls are ready for Plan 03 integration. Plan 03 has not started. GRC-01–GRC-03, the phase aggregate, runtime proof, final semantic disposition, and delivery remain pending; no phase or milestone completion is claimed.

## Self-Check: PASSED

The floor source archive, evidence record, contract tests, and lane test selection were committed in the five task commits listed above. The persisted Plan 01-02 ledger records base `cb6d0358576e6a30028f2bab9838f92671d4d4c6`; all five task commits are included in the measured count.

---
*Phase: 01-bounded-guard-continuation*
*Completed: 2026-11-11*
