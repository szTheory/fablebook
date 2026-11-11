---
phase: 01-release-pipeline-ci-gate-and-guards
verified: 2026-11-07T14:44:00Z
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
  - ".planning/phases/01.1-close-phase-1-guard-gaps/01.1-UAT.md"
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
covered_digest: "v4:sha256:62af3b513d3d6b4d9d743c67208bc944a0363995154a113820248cf6681a5f0b"
behavior_unverified: 0
overrides_applied: 0
re_verification:
  previous_status: passed
  previous_score: 9/9
  gaps_closed: []
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
**Verified:** 2026-11-07T14:44:00Z
**Status:** passed
**Re-verification:** Yes — refreshed after the Phase 01.1 UAT update; later guard evidence was reconciled.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | Version 0.1.0 is published on Hex and its release includes the post-publish smoke, recovery path and SBOM. | ✓ VERIFIED | The prior recorded Hex API/release evidence confirms 0.1.0 and its SBOM; release run 40803980465 completed release-please, build, publish, both smoke lanes and finalize. Phase 01.1 UAT items 14–22 add current contract and merge evidence for the recovery path. The one live recovery dispatch is explicitly deferred to an independently authorized release and is not required to prove that the package was published. |
| 2 | Guarded prod hosts compile without Fablebook routes or story beams, and unguarded mounts fail with the canonical CompileError. | ✓ VERIFIED | `lib/fablebook/router.ex` implements the macro guard; `test/contract/prod_guard_test.exs` exercises guarded and unguarded fixture hosts. Recorded run 40806648656 passed core and floor checks. The CI prod fixture checks route/story-beam absence; adopter-wide checks remain owned by later phases. |
| 3 | CI enforces workflow caps, one required ci-gate, intent integrity and citation rules, and the required gate guarded the first merge. | ✓ VERIFIED | `.github/workflows/ci.yml`, `.github/actions/setup/action.yml`, `mix.exs`, and the contract/planning tests wire these checks into core and floor CI. The original first-merge evidence and later PR #73 run 42354468061 establish the gate and current scanner compatibility. |
| 4 | CI publishes weekly p50/p95 timing feedback while timing overages do not block release or phase closure; genuine quality regressions remain blocking. | ✓ VERIFIED | `bin/ci_health`, `.github/workflows/ci.yml`, `01-09-TIMING-CLOSURE.json`, and the recorded UAT cover reporting and both timing-only and genuine-regression classification. The unrelated dirty edit in `ci_health_test.exs` was not treated as phase evidence or changed here. |
| 5 | CI rejects eval and runtime EEx/HEEx compilation paths in the phase scope. | ✓ VERIFIED | `test/contract/banned_calls_test.exs`, `credo/checks/banned_calls.ex`, and the CI aliases wire source and compiled-BEAM checks. Phase 01.1 and 01.1.1 verification records later literal-dispatch and code-loading fixes as passed on the supported lanes. |
| 6 | CI rejects atom creation through the scoped String/List constructors, including literal and indirect dispatch forms. | ✓ VERIFIED | `01-06-ATOM-EVIDENCE.json` records the exact core/floor evidence. Later Phase 01.1 UAT records 21 passing checks and 155 focused contract tests on each lane; Phase 01.1.1 verification records the subsequent parser/runtime ban work as passed. |
| 7 | Prohibited dependencies in the prod closure fail CI. | ✓ VERIFIED | `test/contract/dependency_budget_test.exs` exercises dependency declarations and closure rules; `mix ci` and the core/floor CI test paths include it. Existing hosted checks recorded by the phase passed. |
| 8 | Package files outside the allowlist or invalid metadata/PII fail before publication. | ✓ VERIFIED | `test/contract/tarball_test.exs` builds/unpacks the package and checks its allowlist and metadata; release evidence shows the checks preceded publication of 0.1.0. |
| 9 | Required CI checks were active before the first merge. | ✓ VERIFIED | The first PR's recorded core, floor, dialyzer, security and ci-gate checks passed, and the main ruleset requires `ci-gate`; the later PR #73 run confirms the gate remains wired. |

**Score:** 9/9 roadmap truths verified. `behavior_unverified: 0`.

## Required Artifacts

| Artifact | Expected | Status | Evidence |
|---|---|---|---|
| CI, release-please, Hex publish workflows and setup action | Guarded build and publication flow | ✓ VERIFIED | Workflow files connect core/floor checks, ci-gate, release-please, package validation, publish and smoke jobs. |
| Prod guard and contract fixtures | Compile-time guard and positive/negative prod controls | ✓ VERIFIED | Router macro and guarded/unguarded fixture tests are present and wired into CI. |
| Guard, planning and dependency tests | Regressions fail the CI lanes | ✓ VERIFIED | Test paths are included by `mix ci`; later Phase 01.1/01.1.1 records support the ban-list follow-ups. |
| CI health script and timing closure receipt | Measured feedback separated from release blocking | ✓ VERIFIED | Script and receipt cover p50/p95 reporting, performance feedback, and independent regression blocking. |
| Release package and SBOM evidence | Published 0.1.0 and release artifacts | ✓ VERIFIED | Recorded Hex API and GitHub release evidence; release workflow completed both smoke jobs. |

## Key Link Verification

| From | To | Via | Status | Evidence |
|---|---|---|---|---|
| `.github/workflows/ci.yml` | `mix.exs` CI alias | Core/floor jobs invoke `mix ci` | WIRED | Workflow and alias configuration; recorded hosted CI passes. |
| CI jobs | Guard and planning tests | `mix ci` test path | WIRED | Contract/planning tests are in the alias and CI lanes. |
| `ci-gate` | Required component jobs | `needs` and always-result aggregation | WIRED | Workflow aggregation and repository ruleset evidence. |
| release-please | Hex publish workflow | Reusable workflow call | WIRED | Release run 40803980465 completed. |
| Hex publish workflow | Validated artifact, publish, smoke and finalize | Build/checksum/artifact dependencies | WIRED | Workflow chain and completed release run. |
| Prod guard fixture | `Fablebook.Router.fablebook/2` | Fixture host compilation | WIRED | Guarded and unguarded cases exercise the macro. |
| CI health timing branch | `ci-performance` and release guard | Issue classification | WIRED | Timing closure receipt and existing contract evidence. |
| Intent/contract scanners | Git diff and CI | Planning tests use real diff seam | WIRED | `test/planning/intent_test.exs`, `contract_rule_test.exs`, and CI wiring. |

## Data-Flow Trace (Level 4)

Not applicable to rendered application data. Release artifact flow is documented from build and checksum through publication and smoke. CI timing values flow from Actions history into p50/p95 feedback and the intended issue label, covered by the recorded contracts and closure receipt.

## Behavioral Spot-Checks

| Behavior | Existing evidence | Result | Status |
|---|---|---|---|
| Published package and release artifacts | Hex API/release record; run 40803980465 | 0.1.0 published, SBOM attached, release jobs succeeded | ✓ PASS |
| Guarded/unguarded prod host behavior | Run 40806648656 | Core/floor checks passed | ✓ PASS |
| Current scanner compatibility | PR #73 run 42354468061 | Required checks passed | ✓ PASS |
| Phase 01.1 guard/recovery contracts | `01.1-UAT.md` | 21 checks passed; 155 focused tests on each lane, plus focused Credo | ✓ PASS |
| Live recovery dispatch | `01.1-UAT.md` item 22 | Deferred until an independently authorized release | Intentionally deferred; not a Phase 01 unmet truth |

No tests, CI runs, or live dispatches were started during this verification.

## Probe Execution

Not applicable. Phase plans do not declare a probe path.

## Requirements Coverage

| Requirement | Source plans | Status | Evidence |
|---|---|---|---|
| REL-01 | 01-01, 01-02, 01-03, 01-05, 01-06 | ✓ SATISFIED | Published 0.1.0, release workflow, smoke, recovery path and SBOM evidence. |
| CI-01 | 01-02, 01-04–01-09 | ✓ SATISFIED | Workflow caps/gate contracts and recorded weekly timing feedback with non-blocking timing classification. |
| INTENT-01 | 01-04–01-06 | ✓ SATISFIED | Intent add-only, ID and citation rules are enforced by planning tests wired into CI; recorded red control demonstrates rejection. |
| SEC-02 | 01-01, 01-06 | ✓ SATISFIED (scoped caveat) | Prod macro guard and CI fixture evidence; universal adopter enforcement remains assigned to later phases. |

SEC-01 is partial delivery only; its full property/mutation requirement remains assigned to Phase 5. No Phase 01 requirement mapped in the roadmap is orphaned.

## Anti-Patterns Found

| File | Finding | Severity | Impact |
|---|---|---|---|
| `test/contract/ci_health_test.exs` | An unrelated uncommitted edit contains a Credo refactoring warning recorded by Phase 01.1 UAT. | Info | Preserved as requested; it does not alter the Phase 01 verification conclusions and was not tested or edited here. |

No unresolved `TBD`, `FIXME`, or `XXX` debt marker was identified in the phase implementation evidence.

## Human Verification Required

None. This is a CI/release foundation phase. Published release and guard behavior have existing automated or hosted evidence; the only deferred UAT check is a live dispatch that must occur with an independently authorized release and was explicitly excluded from Phase 01 completion.

## Gaps Summary

No Phase 01 gap remains. The refreshed Phase 01.1 UAT closes the stale evidence concern and records the later guard fixes as covered by Phase 01.1.1 verification. The live recovery dispatch remains deferred by design and is not required to repeat publication of 0.1.0. No new CI run, test, or release dispatch was initiated. The unrelated working-tree edit to `test/contract/ci_health_test.exs` was preserved.

### Decision Coverage

The decision coverage check found 31 of 31 trackable CONTEXT decisions honored, with no unhonored decisions.

### Advisory (New Scope, Unevidenced)

Not applicable: this verification refreshes a previously passing report whose only stale input was the UAT file. No new blocker finding was raised.

---

_Verified: 2026-11-07T14:44:00Z_  
_Verifier: gsd-verifier_
