---
phase: 01-bounded-guard-continuation
plan: "03"
subsystem: testing
tags: [OTP, inets, tracing, static-analysis, lane-selection]
requires:
  - phase: 01-bounded-guard-continuation
    provides: Independent exact-hash core and floor source findings from Plans 01 and 02.
provides:
  - Integrated EX-010 retained callback-front dispositions and individual both-lane matcher controls.
  - Symmetric core/floor test selection with wrong-lane and unrelated-exclusion negatives.
  - Reviewed, locally tested and hosted-green candidate PR 85 at the same source head.
affects: [guard-coverage, inets, phase-verification, delivery]
actuals:
  tokens: 9263
  tasks: 2
  commits: 5
plan_head_before: 3c81a1b67274e18ad6699017dbfcf2d02afbc7b1
plan_head_after: a90ef1dfe7bad10ac3d303b82f8ba7b32c949745
tech-stack:
  added: []
  patterns: [hash-scoped integration, individual matcher removal, symmetric lane selection, exact-head candidate receipts]
key-files:
  created:
    - .planning/phases/01-bounded-guard-continuation/01-CANDIDATE.md
  modified:
    - test/support/sweep_evidence.ex
    - test/contract/tier_sweep_test.exs
    - test/contract/banned_calls_test.exs
    - test/contract/ci_shape_test.exs
    - test/test_helper.exs
key-decisions:
  - "Retain EX-010 as a callback front with a fixed native-driver boundary; no new evaluator or atom-creation ban is justified."
  - "Use symmetric core/floor selection and reject excluding the selected lane or unrelated tests."
  - "Keep actual delivery, phase requirements, aggregate, walking skeleton and SEC-01 open after candidate implementation completion."
requirements-covered: [GRC-01, GRC-02, GRC-03]
requirements-completed: []
coverage:
  - id: D1
    description: "Integrated source-backed static disposition and individually necessary retained matcher for both selected exports on each exact lane."
    verification:
      - kind: integration
        ref: "Final core and floor focused integration/guard/source/control runs: seven selected tests per lane, exit 0."
        status: pass
      - kind: other
        ref: "01-CANDIDATE.md#independent-review-and-exact-head-binding: recorded independent semantic review and exact-head delta chain."
        status: pass
    human_judgment: false
  - id: D2
    description: "Symmetric lane selection with both-lane CI-shape and unrelated/wrong-lane negative controls."
    verification:
      - kind: unit
        ref: "test/contract/ci_shape_test.exs: final core and floor runs, 71 passed each."
        status: pass
      - kind: integration
        ref: "Full core CI and full floor prod_guard suite at a90ef1dfe7bad10ac3d303b82f8ba7b32c949745."
        status: pass
    human_judgment: false
  - id: D3
    description: "Published candidate with matching independent review, local gates and five successful hosted jobs."
    verification:
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/43124394402"
        status: pass
      - kind: other
        ref: "gh pr checks 85 --required: exit 0; PR head equals the reviewed/tested source head."
        status: pass
    human_judgment: false
duration: 90min
completed: 2026-11-12
status: complete
delivery: pending
---

# Phase 1 Plan 3: Integrated inets trace candidate Summary

**Both EX-010 exports retain source-backed callback-front dispositions with individual lane witnesses; the exact reviewed candidate passes local and hosted checks.**

## Performance

- **Plan interval:** 2026-11-11T22:45:40Z–2026-11-12T00:16:10Z, 90m30s including validation, review, recovery, owner decisions and receipt authoring.
- **Task 1:** 22:45:40Z–22:55:40Z; both focused lane controls passed.
- **Task 2:** began 22:56:35Z; final local gates ended 23:56:24Z; hosted acceptance ended 2026-11-12T00:13:33Z.
- **Tasks:** 2/2 implementation tasks. Actual phase delivery is pending.
- **Task files:** six, including the candidate receipt; this summary is normal execution metadata.
- **Measured actuals:** 37,055 added/removed textual diff characters divided by four, floored to 9,263 proxy tokens. Five task commits measured from the persisted Plan 01-03 ledger through the tested head. This excludes this summary and later canonical bookkeeping; it is not harness-token/context consumption, which is unavailable.
- **Hosted wait:** 628s, from actual run creation to completion. Owner-decision and server-restart waits are included in elapsed time; no separately instrumented duration is invented.
- **Remaining projection:** post-plan independent verification, ship and the exact-candidate owner decision remain; no additional implementation or next scope is assumed. Existing source/context/effort bounds remain unchanged and within the approved working-day envelope.

## Accomplishments

- Added `InetsTraceIntegrationEvidence` with both selected exports, both hash-scoped lane records, final `:retained_callback_front` dispositions and no newly justified active guard.
- Reconciled each live selected/remainder partition, both delegate edges and the full original identity mapping. Only EX-010 advances to `:inets_trace_retained`, owned by `v0.2/1`; EX-011 and every outside-row status/owner survive.
- Proved individual non-vacuous retained-matcher removal, overlap rejection, unsupported/missing/wrong-lane evidence rejection and ordering invariance. Uncalled direct/capture/apply/source forms and benign controls remain static.
- Corrected lane selection through an explicitly owner-approved three-file policy fix. Both CI and non-CI controls reject excluding the lane's own tests and continue rejecting unrelated exclusions.
- Published [PR #85](https://github.com/szTheory/fablebook/pull/85) at `a90ef1dfe7bad10ac3d303b82f8ba7b32c949745`; full local checks, composed independent review and all five required hosted jobs pass at that same head.

## Semantic result and scope limits

The independent core and floor findings support retaining the original matcher. Both `inets:enable_trace/2,3` exports forward inputs to `inets_trace:enable/2,3`. Service selection is fixed or validated; destinations choose file, integer IP port, `io`, or caller-provided `{Fun, Data}`. The reviewed `dbg` path invokes the supplied callback and uses the fixed `trace_ip_drv` native driver. No evaluator or atom-creation ban is justified by that recorded path.

Integration opened zero full OTP source files; it reused the two lane plans' independently reviewed exact-hash findings within their scope. Core and floor findings retain their historical pending/candidate-only provenance; the integration record supplies the final selected disposition. The archive remains `7d4bd66fe72224cf49f849148b5e737443588ca66c12873938bfa30fa3d0ea58`. No audited API, callback, fixture function or atom sink was invoked.

Callback implementations, dynamic callers and native internals remain outside proof. A zero incoming-edge graph is not dynamic-caller absence. No runtime SEC-01 safety, complete guard aggregate, installed-wide completion or walking-skeleton authorization is claimed. Macro caller-AST, explanation wording, actual production-collision and source-expansion stops remain. No production, workflow, dependency, lockfile, active guard or explanation change was bundled.

## Task Commits

1. **Task 1 RED: require integrated inets trace dispositions** — `2dd6936` (`test`).
2. **Task 1 GREEN: integrate retained inets trace dispositions** — `1f6de5d` (`feat`).
3. **Task 2 lint and rationale-integrity fixes** — `1b2b281` (`fix`).
4. **Task 2 floor-only annotations** — `93fe204` (`fix`).
5. **Task 2 owner-approved symmetric lane-selection policy** — `a90ef1d` (`fix`).

The local summary/candidate bookkeeping commit follows these task commits. It is not a newly hosted-tested candidate and will not trigger a receipt-only push.

## Verification

- **RED:** the named integration target executed and failed at the missing integration-module assertion, exit 2. Saved complete TAP evidence passed `RED_EVIDENCE_OK`; semantic inspection ruled out fixture, load and syntax failures. GREEN followed the genuine RED commit.
- **Task 1 focused controls:** both lanes exited 0, five selected tests each; 68.7s core and 34.0s floor.
- **Final cheap gates:** formatting and strict Credo exited 0; complete CI-shape checks passed 71 tests on each lane. Final focused integration/guard and applicable lane source/control checks passed seven selected tests per lane (63.7s core / 40.0s floor).
- **Full core at final head:** `MIX_ENV=test bin/lane core mix ci` exited 0, 23:39:32Z–23:48:34Z; 438 passed, three floor exclusions. Format, unused locks, force compile, strict Credo, cycles, docs, production and release tests all ran.
- **Floor at final head:** normal compile and force compile with `--no-optional-deps` exited 0. Full `--warnings-as-errors --include prod_guard` run exited 0, 23:48:37Z–23:56:24Z; 441 total, zero failures, six expected core/release exclusions.
- **Independent review:** two whole-phase passes resolved the rationale warning. Owner-approved focused reviews of the subsequent two-tag and symmetric-policy deltas both passed without findings and compose through the final head. No additional whole-phase audit or OTP-source replay occurred.
- **Hosted:** [run 43124394402](https://github.com/szTheory/fablebook/actions/runs/43124394402) completed successfully at the same head. Core, floor, Dialyzer, security and ci-gate each succeeded. Fresh required-check query exited 0. Scheduled nightly/CI-health skips are not substituted for required checks.
- **Separation and privacy:** protected-path diff against approved main is empty; `git diff --check` passed. Added tracked text contains no absolute home paths, prohibited external names or separate brand-intake paths.
- **Local Actions limitation:** existing dry-run receipt fails because installed `act` cannot parse `concurrency.queue`; the unchanged infeasible check was not retried. Actual hosted proof supplies the required outcome.

[01-CANDIDATE.md](01-CANDIDATE.md) records exact source hashes, final file hashes, commands, historical failures, all T-1-01–T-1-14 and supply-chain mitigation evidence, actual job URLs and cost. Generated local logs and raw review/hosted records remain under `_build/phase1-execution/`.

## Decisions Made

Retain the original matcher with the explicit caller-code boundary; no new active ban is supported. The exact reviewed rationale is pinned so contradictory callback/runtime-safety wording fails. Use symmetric `:core`/`:floor` tags under wrong-lane enforcement rather than a custom exclusion that bypasses CI wiring.

The owner explicitly approved one two-tag review and, after the later floor failure, the concrete three-file policy fix plus one focused review and required checks. These are bounded continuations, not another audit phase or merge approval. Their post-CI intent captures are reserved as INT-20261111-09 and INT-20261111-10.

## Deviations from Plan

### Auto-fixed and owner-authorized issues

**1. [Rule 1 - Bug] Correct integration range normalization.**
- **Found during:** Task 1 focused verification.
- **Fix:** Corrected the recorded Task 1 range-normalization issue before passing both lanes.
- **Files:** `test/contract/tier_sweep_test.exs`.
- **Verification/commit:** both Task 1 focused runs passed; `1f6de5d`.

**2. [Rule 1 - Bug] Strict lint and rationale-integrity warning.**
- **Found during:** Task 2 initial strict Credo and independent review.
- **Fix:** Small aliases/helper refactors preserved evidence values; exact rationale and adverse false-SEC-01 assertion replaced a permissive substring check.
- **Files:** support, tier-sweep and banned-call contracts.
- **Verification/commit:** strict Credo and focused checks passed; independent pass 2 found no remaining issue; `1b2b281`.

**3. [Rule 1 - Bug] Select floor-only source tests on floor.**
- **Found during:** Task 2 full core run, which failed only the two untagged floor tests.
- **Fix:** Added the existing `:floor` annotation to those two tests.
- **Verification/commit:** full core at `93fe204` passed; owner-approved focused two-line delta review passed; `93fe204`.

**4. [Owner-authorized bounded continuation] Reconcile core-only selection with CI policy.**
- **Found during:** Task 2 full floor suite: the custom exclusion was correctly rejected by CI-shape.
- **Fix:** Surfaced the fix/review cap and obtained explicit approval before applying the prepared three-file symmetric lane policy and unrelated/wrong-lane negatives.
- **Files:** `test/test_helper.exs`, `test/contract/tier_sweep_test.exs`, `test/contract/ci_shape_test.exs`.
- **Verification/commit:** cheap checks, both focused/full lanes, final focused review and hosted checks passed; `a90ef1d`.

All changes remain contract-only. The two added policy paths were a concrete approved scope adjustment; no gate was silently relaxed and no further review was assumed.

## Issues Encountered and efficiency lesson

Historical full core/floor failures took 609.7s and 605.6s of test time (1,215.3s total), exposing test-selection wiring late. The server restart interrupted agent sessions but the surviving core OS process was monitored to its actual successful exit; no duplicate run or machine cleanup was launched.

For future selection changes, run cheap strict lint and CI-shape on both affected lanes before expensive graph/full suites. Spend the final focused review after broad local green. The approved continuation followed this order. Hosted core was the critical path: 619s job / 603s `mix ci`; floor was 518s job / 497s tests. Setup was only 10s/9s, with the existing Dialyzer PLT cache working. Current and recorded CI history support no safe cache, concurrency, dependency or workflow change within this slice. Timing objectives remain visible without weakening correctness gates.

## Known Stubs

None introduced. No source/UI placeholder prevents the selected implementation goal. Pending actual delivery and wider safety work retain their explicit owners and are not represented as completed stubs.

## User Setup Required

None.

## Next Phase Readiness

All three implementation plans are complete. Phase 1, GRC-01–GRC-03 delivery acceptance, and the milestone remain open pending the parent's single independent technical verification, ship preflight, exact-candidate owner merge approval, actual merge, required main CI and delivery registry facts. Do not call `phase.complete`, close requirements or start later work.

The parent continues the active `$gsd-execute-phase 1` at its shared post-plan phase-verification pipeline to produce the single technical report, then the existing ship/owner boundary. A resumed execution skips the completed plans; no manual-UAT or status-command loop is required. No routine user action is needed now. Preserve the separate brand intake on its own remote branch and carry its handoff pointer in canonical state; it is outside this guard candidate.

## Self-Check: PASSED

All six task files exist. The five listed task commits are ancestors of the candidate head, and the persisted ledger measures exactly five commits from `3c81a1b` through `a90ef1d`. Candidate source hashes match the reviewed/local/hosted source identity. The summary was written to the required phase path; its existence and final metadata checks are verified before the local bookkeeping commit.
