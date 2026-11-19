---
phase: "04"
slug: "evidence-only-source-and-gap-provenance-closure"
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-17"
---

# Phase 04 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Python3 standard-library artifact validator; existing ExUnit/lane suites remain owned by Phase 3 and are not scheduled here. |
| **Config file** | Existing project and lane configuration; no new config or dependency. |
| **Quick run command** | `python3 .planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-validate-artifacts.py --self-test`, then the stage-specific command below. |
| **Full suite command** | Not scheduled by default. A long lane suite is required only if the checked plan identifies a behavior that needs it after all cheap checks pass. |
| **Estimated runtime** | Not measured; planning research did not run tests. |

## Sampling Rate

- Before each source-body request: bind the exact schedule and spans, independent review, passing Phase 4 execute preflight, and fresh direct count for that exact request. No source read occurs before all four pass.
- After producing or changing evidence: run format/whitespace checks, then schema, exact ID/MFA-set, association-or-gap partition, required-provenance, count, cross-file link, and digest validation.
- Run any focused contract only after the cheap validator passes. Run a long lane suite only when the plan establishes that it is required; stop at the first failed gate and diagnose before any scoped retest.
- Before `$gsd-verify-work`: verify the exact final evidence generation and independent review receipt. Phase 4 does not close Phase 3.

## Per-Task Verification Map

Three serial plans contain six tasks. Every command runs from the isolated recovery checkout root. These are planned commands, not executed test receipts. Python3 availability was confirmed without running tests. Prior planning/research token spend remains unmeasured; source access is blocked until supported exact cumulative accounting and the unchanged limits can be verified.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 04-01 | 1 | GSR-03 | T-04-01, T-04-02 | Independent exact lane sets and exhaustive association-or-gap partition | artifact tracer + negative controls | Validator `--self-test`, then `--partition` | Created by task | ⬜ pending |
| 04-01-02 | 04-01 | 1 | GSR-05 | T-04-03 | Exact complete request schedule; unmeasured fit cannot open source access | metadata gate | Validator `--schedule` | Created by 04-01-01 | ⬜ pending |
| 04-02-01 | 04-02 | 2 | GSR-03, GSR-05 | T-04-04 | Written schedule → independent review → execute preflight → fresh direct count/fit → one-use emission | request gate + negative controls | Validator `--self-test`; `bin/planning_health --stage execute --phase 4`; validator `--request-gate --request R1` | Extended by task | ⬜ pending |
| 04-02-02 | 04-02 | 2 | GSR-03, GSR-05 | T-04-05, T-04-06 | Actual coverage producer/selector and proved or honestly unresolved nested recipe | static trace + artifact controls | Validator `--self-test` | Extended by task | ⬜ pending |
| 04-03-01 | 04-03 | 3 | GSR-03, GSR-05 | T-04-08 | Full exact keys/provenance/hash generation; hostile controls fail | complete artifact tracer | Validator `--self-test`, then `--all --allow-review-pending` | Extended by task | ⬜ pending |
| 04-03-02 | 04-03 | 3 | GSR-03, GSR-05 | T-04-07, T-04-09 | Detached independent review, final six-path receipt and truthful handoff | final artifact contract | Validator `--self-test`, `--write-validation`, then `--all`; scoped `git diff --check HEAD` | Created/extended by prior tasks | ⬜ pending |

`Validator` expands exactly to `python3 .planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-validate-artifacts.py`. The scoped whitespace command is exactly `git diff --check HEAD -- .planning/phases/04-evidence-only-source-and-gap-provenance-closure`. Each runnable task command has its own `<fails_when>` sibling in its PLAN file; those define observable rejection, rather than count-only success. No validator currently exists, and none ran during planning.

The cheap sequence is negative controls → partition/schedule/request checks → trace/digest/schema/provenance/cross-file checks → independent review → final receipt write → read-only final recomputation. No long lane suite is required by this evidence-only change. No OTP/library body read or direct count occurred during planning. All actual source requests, including a distinct reviewer request, require the full ordered gate and count their rereads; a missing counter, stale receipt, unverifiable total spend or fit failure stops without unchanged retry.

## Wave 0 Requirements

No new test framework or dependency. The plan must create any validator needed for the cheap gate and include negative controls for duplicate/missing keys, wrong-lane records, malformed provenance, digest mismatch, and fabricated completeness claims.

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Independent schedule and source-evidence review | GSR-03, GSR-05 | Automated checks can prove record consistency but cannot decide whether each cited source span supports its association or typed gap. | Reviewer checks the exact schedule and complete keyed evidence against cited source spans without invoking audited code; record unresolved findings explicitly. |
| Legacy digest reproduction | GSR-05 | The previous selector and encoding must be established from exact known inputs; a plausible reconstruction is not proof. | Reproduce only from known selector/encoding inputs. Otherwise record the legacy claim as unresolved and publish a separate supplement digest. |

## Validation Sign-Off

- [ ] Every plan task has an observable automated check or an explicit schedule/preflight/count dependency.
- [ ] Cheap consistency validation passes before any source-dependent suite.
- [ ] The exact review and source-read gates are bound in the task receipts.
- [ ] No watch-mode flags or new dependencies.
- [ ] `nyquist_compliant: true` is set only after validation confirms the final task map.

**Approval:** pending plan review and execution.
