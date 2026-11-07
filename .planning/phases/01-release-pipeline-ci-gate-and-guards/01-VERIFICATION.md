---
phase: 01-release-pipeline-ci-gate-and-guards
verified: 2026-11-07T08:29:25Z
status: passed
score: 9/9 must-haves verified
covered_files:
  - ".github/actions/setup/action.yml"
  - ".github/workflows/ci.yml"
  - ".github/workflows/hex-publish.yml"
  - ".github/workflows/release-please.yml"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-01-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-01-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-02-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-02-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-03-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-03-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-04-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-04-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-05-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-05-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-06-ATOM-EVIDENCE.json"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-06-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-06-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-07-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-07-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-08-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-08-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-09-PLAN.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-09-SUMMARY.md"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-09-TIMING-CLOSURE.json"
  - ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-UAT.md"
  - "bin/ci_health"
  - "bin/smoke_consumer"
  - "lib/fablebook/router.ex"
  - "mix.exs"
  - "test/contract/banned_calls_test.exs"
  - "test/contract/ci_health_test.exs"
  - "test/contract/ci_shape_test.exs"
  - "test/contract/dependency_budget_test.exs"
  - "test/contract/prod_guard_test.exs"
  - "test/contract/style_attr_test.exs"
  - "test/contract/tarball_test.exs"
  - "test/planning/contract_rule_test.exs"
  - "test/planning/intent_test.exs"
  - "test/support/beam_walker.ex"
  - "test/support/git_diff.ex"
covered_digest: "v4:sha256:86adcf76246755491cbc9e8163b6ad0e12b41f47ef1dc0782c2306f59db2e4cc"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: gaps_found
  previous_score: 8/9
  gaps_closed:
    - "G-01-15: CI timing overages now publish as non-blocking ci-performance feedback; genuine regression blocking remains intact."
    - "CR-01: literal String/List atom-constructor dispatch is rejected on exact core and floor lanes."
  gaps_remaining: []
  regressions: []
decision_coverage:
  honored: 31
  total: 31
  not_honored: []
human_verification: []
---

# Phase 01: Release pipeline, CI gate and guards — Verification Report

**Phase Goal:** A published 0.1.0 reserves the Hex name, and the guards every later phase relies on (CI caps, intent integrity, the prod guard, the eval and atom bans, the dependency budget) are enforced by CI from the first merge.
**Verified:** 2026-11-07T08:29:25Z
**Status:** passed
**Re-verification:** Yes — after the timing gap closure and merged CI scanner compatibility fix.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | 0.1.0 is published on Hex after release checks; the pipeline includes recovery, post-publish smoke and an SBOM. | ✓ VERIFIED | The Hex package API lists 0.1.0. GitHub release `v0.1.0` is published with `fablebook-0.1.0.cdx.json`. Release run [40803980465](https://github.com/szTheory/fablebook/actions/runs/40803980465) succeeded across release-please, build, publish, both smoke lanes and finalize. The reusable publish workflow checks prod-guard cases and the unpacked tarball before publishing; it also supports manual recovery. |
| 2 | Guarded hosts compile in prod without Fablebook routes or story beams; an unguarded mount fails with the canonical CompileError. | ✓ VERIFIED | `lib/fablebook/router.ex` returns the prod error from the macro expansion path. `test/contract/prod_guard_test.exs` checks dev positive controls and guarded/unguarded prod cases. Run [40806648656](https://github.com/szTheory/fablebook/actions/runs/40806648656) passed core, floor, security, dialyzer and ci-gate. The no-story-beam check is fixture-scoped; universal adopter coverage remains with Phases 2/10. |
| 3 | CI enforces workflow shape/caps, intent integrity and citation rules, and required checks were active before the first merge. | ✓ VERIFIED | `ci.yml` runs `mix ci` and its `ci-gate` checks core, floor, dialyzer, security and nightly. `mix.exs` wires the contract and planning tests into the CI alias. The D-22 intent mutation produced a red CI run (40802432347); the current scanner compatibility fix is in merged PR [#73](https://github.com/szTheory/fablebook/pull/73), whose run [42354468061](https://github.com/szTheory/fablebook/actions/runs/42354468061) passed core, floor, dialyzer, security and ci-gate. Only the permitted ci-health and nightly jobs were skipped. |
| 4 | Weekly timing reports remain visible and timing overages do not block release or phase closure. | ✓ VERIFIED | `bin/ci_health` publishes measured p50/p95 and the 420/600-second objectives, routing overages to `ci-performance`; the release guard checks only `quality-regression`. Strict contracts cover timing-only, mixed and genuine-regression cases. Plan 01-09's closure receipt records the live report, issue #37 migration and release-guard controls; the owner decision is recorded in UAT. |
| 5 | CI rejects eval and runtime EEx/HEEx compilation paths covered by the phase criteria. | ✓ VERIFIED | `test/contract/banned_calls_test.exs` and the Credo check cover source and compiled-BEAM calls, with literal-dispatch fixtures and fail-closed debug-info behavior. `mix ci` and the floor CI job run these tests; the current PR #73 run passed both lanes. |
| 6 | CI rejects atom creation through the phase's String/List constructors, including literal dispatch forms. | ✓ VERIFIED | The compiled-BEAM MFA guard and Credo parity check include the literal atom-constructor dispatches. `01-06-ATOM-EVIDENCE.json` records exact core/floor runs, output and input digests; the evidence target is on current main. These tests are included in the CI test path. |
| 7 | A prohibited dependency declaration or prod-closure dependency fails CI. | ✓ VERIFIED | `test/contract/dependency_budget_test.exs` exercises direct-dependency rules and metadata-based prod closure, including synthetic negative cases. It is reached by `mix ci` and the core/floor CI test jobs. |
| 8 | An extra package file or invalid metadata/PII fails before publication. | ✓ VERIFIED | `test/contract/tarball_test.exs` builds and unpacks the package and checks the exact allowlist, metadata and PII patterns. The release build and publish run succeeded before the package was published. |
| 9 | The required CI gate guarded the first merge. | ✓ VERIFIED | PR #1 merged with core, floor, dialyzer, security and ci-gate passing. The main ruleset requires only ci-gate. The current run for PR #73 confirms the gate still passes after the scanner compatibility change. |

**Score:** 9/9 roadmap-derived truths verified. `behavior_unverified: 0`.

## Required Artifacts

| Artifact group | Status | Evidence |
|---|---|---|
| `.github/workflows/{ci,release-please,hex-publish}.yml` and setup action | ✓ VERIFIED | Current workflow files connect core/floor checks to `mix ci`, ci-gate, release-please and reusable Hex publication. PR #73's hosted run passed all required checks. |
| Release package, manifest and consumer smoke | ✓ VERIFIED | Hex API exposes 0.1.0; the GitHub release contains the SBOM; the release run completed both smoke jobs and finalize. |
| `lib/fablebook/router.ex` and prod-guard fixtures/tests | ✓ VERIFIED | Macro behavior is exercised by guarded and unguarded host fixture builds on core and floor. |
| Contract and planning tests, including `ci_shape_test.exs` | ✓ VERIFIED | Substantive negative and positive controls are wired through CI. PR #73 modifies only `test/contract/ci_shape_test.exs`; its hosted core/floor/security/dialyzer/ci-gate checks passed. |
| `bin/ci_health` and timing closure evidence | ✓ VERIFIED | Current script distinguishes performance reports from blocking regressions; 01-09 receipt records deployment and live guard controls. |
| `01-06-ATOM-EVIDENCE.json` | ✓ VERIFIED | Revision-bound core/floor receipt with matching source/runtime input digests. |

## Key Link Verification

| From | To | Status | Evidence |
|---|---|---|---|
| `.github/workflows/ci.yml` | `mix.exs` CI alias | WIRED | Core runs `mix ci`; the alias includes compilation, Credo, docs and the test suite. |
| CI test jobs | Guard and planning contract tests | WIRED | Core and floor use the CI test path; hosted run 42354468061 passed both jobs after PR #73. |
| `ci-gate` | core, floor, dialyzer, security, nightly | WIRED | The gate's `needs` and `always()` result check are present. Current ruleset requires the `ci-gate` context. |
| release-please workflow | Hex publish workflow | WIRED | The reusable workflow call is present; release run 40803980465 completed the release flow. |
| Hex publish workflow | built package, smoke lanes and release | WIRED | The build's checked package feeds publish, then both smoke lanes and finalize; run 40803980465 passed all six jobs. |
| prod-guard fixture | `Fablebook.Router.fablebook/2` | WIRED | Nested fixture compilation invokes the macro and asserts the guarded and unguarded outcomes. |
| `bin/ci_health` timing branch | `ci-performance` vs release guard | WIRED | Timing overages use the performance label; `.github/workflows/ci.yml` blocks releases only for `quality-regression`. Receipt records positive and negative inventory controls. |
| intent/contract scanners | Git diff and CI | WIRED | Planning tests use the git diff seam and are included in CI; a real add-only violation was rejected, and PR #73 passes the current scanner contracts. |

## Data-Flow Trace (Level 4)

Not applicable to rendered data. The release data flow is verified from package build and checksum through publish and post-publish smoke. CI timing measurements flow from Actions run/job APIs into numeric summaries and the intended issue label, as covered by strict contracts and the closure receipt.

## Behavioral Spot-Checks

| Behavior | Command or live evidence | Result | Status |
|---|---|---|---|
| Published Hex version and GitHub release | Hex package API; `gh release view v0.1.0`; run 40803980465 | 0.1.0 exists; release is not draft, SBOM attached, release jobs succeeded | ✓ PASS |
| Guarded and unguarded prod host cases | Run 40806648656 | Core and floor jobs passed with ci-gate | ✓ PASS |
| Current workflow-shape scanner compatibility | PR #73; run 42354468061 | Core, floor, dialyzer, security and ci-gate passed | ✓ PASS |
| Timing reports and release guard classification | 01-09-TIMING-CLOSURE.json; UAT item 15 | Performance-only inventory passes; synthetic genuine and mixed regressions block | ✓ PASS |
| Atom constructor literal dispatch | 01-06-ATOM-EVIDENCE.json | Exact core and floor fixture runs passed with current input digests | ✓ PASS |

No local suite was rerun: the current hosted PR run exercises the updated scanner and both supported test lanes. No probe is declared by the phase plans.

## Probe Execution

Not applicable. No plan declares a `probe-*.sh` path, and no conventional phase probe is present.

## Requirements Coverage

| Requirement | Source plans | Status | Evidence |
|---|---|---|---|
| REL-01 | 01-01, 01-02, 01-03, 01-05, 01-06 | ✓ SATISFIED | Published 0.1.0, successful release-please/Hex workflow, recovery trigger, SBOM and post-publish smoke evidence. |
| CI-01 | 01-02, 01-04, 01-05, 01-06, 01-07, 01-08, 01-09 | ✓ SATISFIED | Workflow shape and gate are tested; weekly timing and 420/600 objectives are visible; timing-only overages are non-blocking while genuine regressions remain blocking. |
| INTENT-01 | 01-04, 01-05, 01-06 | ✓ SATISFIED | Add-only intent, full-form IDs, valid citations and requirement traceability are enforced by tests included in CI; D-22 provides a real red control. |
| SEC-02 | 01-01, 01-06 | ✓ SATISFIED, scoped caveat | Prod macro guard and CI fixture builds pass. The fixture demonstrates no story beams; universal adopter enforcement remains Phase 2/10 scope. The owner confirmed the SEC-02 source probe remains unclassified/open in Phase 1 UAT item 17. |
| SEC-01 (partial delivery) | 01-03 | ✓ PARTIAL DELIVERY | Static bans and `style=` checks are present for Phase 1; properties and mutation-proven tests remain assigned to Phase 5. SEC-01 is not a Phase 1 completion requirement. |

All four requirements mapped to Phase 1 appear in plan frontmatter. SEC-01 is accounted for as partial delivery and remains mapped to Phase 5. No Phase 1 traceability requirement is orphaned.

## Anti-Patterns Found

| File | Finding | Severity | Impact |
|---|---|---|---|
| Relevant workflow, guard and contract files | No unreferenced TBD/FIXME/XXX markers, empty implementations or runtime placeholders found. | None | No blocker found. The placeholder module is intentional for the 0.1.0 name-reservation package. |
| Phase plan prohibitions | Reviewed in UAT items 16–18; owner retained the SEC-02 scope boundary and assigned Q35/D-21 follow-up to separate planning. | None for Phase 01 | No silent acceptance inferred; those scope decisions are recorded in the UAT artifact. |

## Human Verification Required

None. UAT items 16–18 record the owner decisions for credential scope/revocation, the SEC-02 unclassified probe, and inherited plan prohibitions; all are resolved for this phase's acceptance boundary. This report does not claim independent access to Hex secret contents or universal adopter enforcement.

## Gaps Summary

No remaining Phase 01 gap was found. The prior timing gap is closed by the deployed performance-only reporting path and the regression-preserving release guard. The atom dispatch gap is covered by exact core/floor evidence. PR #73's scanner compatibility update is merged and its hosted required checks pass. Phase 01's goal and mapped requirements are achieved. SEC-01's remaining full completion, the aggregate installed-wide audit, and adopter checks stay with their already assigned later phases.

### Decision Coverage

The decision coverage check found 31 of 31 trackable CONTEXT decisions honored, with no unhonored decisions.

---

_Verified: 2026-11-07T08:29:25Z_
_Verifier: gsd-verifier_
