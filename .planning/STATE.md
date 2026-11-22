---
gsd_state_version: "1.0"
milestone: v0.7
milestone_name: First Inspectable Book
current_phase: 8
current_phase_name: First inspectable Book and local host path
status: executing
stopped_at: null
last_updated: "2026-11-22T23:11:07.000Z"
last_activity: 2026-11-22
last_activity_desc: Verified Canvas ready and failure recovery in Chrome, captured current mobile and desktop evidence, passed the post-fix full core lane and operator host checks, and opened draft PR #106 for exact-head hosted CI
state_head: ae32bda80f5fc1c040459329956bea6b42a635ee
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 5
  completed_plans: 3
  percent: 60
---

# Project State

## Project Reference

See [PROJECT.md](PROJECT.md) (updated 2026-11-21), [ROADMAP.md](ROADMAP.md), the
[v0.6 closeout](milestones/v0.6-CLOSEOUT.md),
[v0.6 archive roadmap](milestones/v0.6-ROADMAP.md),
[v0.6 audit](milestones/v0.6-MILESTONE-AUDIT.md),
[v0.5 closeout](milestones/v0.5-CLOSEOUT.md),
[v0.5 audit](milestones/v0.5-MILESTONE-AUDIT.md),
[v0.4 closeout](milestones/v0.4-CLOSEOUT.md),
[v0.4 audit](milestones/v0.4-MILESTONE-AUDIT.md),
[v0.3 closeout](milestones/v0.3-CLOSEOUT.md), the
[worktree reconciliation](references/WORKTREE-RECONCILIATION-2026-11-13.md), and the
[v0.2 closeout](milestones/v0.2-CLOSEOUT.md).

**Core value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.
**Current focus:** Phase 8 — First inspectable Book and local host path

## Current Position

Phase: 8 (First inspectable Book and local host path) — EXECUTING
Plan: 5 of 5 locally verified; delivery incomplete
Total Plans in Phase: 5
Status: Authorized work continues; delivery incomplete
Last activity: 2026-11-22 — opened draft PR #106 after the post-fix full core lane and real-host browser evidence passed
Last Activity Description: Chrome confirmed both valid Scenarios reach ready, the invalid Canvas reaches the expected failure copy, and current 320 px/1280 px screenshots are captured. Source checks, focused core/floor host suites, production controls and the final core lane pass. Hosted CI is running on the PR head; owner baseline review, phase verification, merge and delivery remain.


## Active Handoff

- Checkout: `~/projects/fablebook` on `main` at `f23da6e341997999a084049436037bd6bd55c0af`; after fetching, `origin/main` is `0e406e648d52b93da52f4d641116cfa28cf9bb6c`. The histories diverge at `5b08774`: 26 local commits and uncommitted planning/source/code work remain here, while four newer commits are on `origin/main`. Preserve this checkout and do not push its full local branch. The dirty historical worktree and dormant brand-intake checkout remain untouched.
- Active delivery worktree: `/private/tmp/fablebook-v07-phase8-resume-20261122` on `gsd/phase-8-first-inspectable-book`, based on `origin/main` at `0e406e6`. It holds the Phase 8 candidate and current implementation edits; the canonical planning checkout above remains on `main`.
- Delivered: v0.6 Phase 7, 5 plans, 12 tasks. Exact-head hosted CI [run 44827619883](https://github.com/szTheory/fablebook/actions/runs/44827619883) passed; PR #96 merged as `0ea95d4c8cdf6ce9a1af363c7ea0033d632b0e6d`; post-merge main CI [run 44828949627](https://github.com/szTheory/fablebook/actions/runs/44828949627) passed. Planning archive closeout PR #97 is merged. The v0.7 planning-only PR #98 is merged with passing exact-head CI [run 44872457695](https://github.com/szTheory/fablebook/actions/runs/44872457695); it is not an implementation delivery.
- Current: v0.7 “First Inspectable Book” remains active under the existing authorization. Plan 08-01 and prerequisite PRs #99–#105 are delivered; the latest four prerequisite PRs have green exact-head CI. The isolated delivery worktree is based on `origin/main` at `0e406e648d52b93da52f4d641116cfa28cf9bb6c`; the dirty canonical `main` checkout remains untouched and must not be pushed. Draft PR [#106](https://github.com/szTheory/fablebook/pull/106) is open for the fixed, dev/test-only Book and approved Book → Journey → Scenario navigation; required hosted CI is running on its exact head. The post-fix full core lane passed 467 tests with 10 exclusions; the preceding full floor lane passed 477 with 6 exclusions. After the readiness retry fix, both focused 12-test host suites, both source-tool self-tests, pinned-source checks and both operator production-boundary checks passed. The deep review's two warnings were fixed; the later readiness retry received a follow-up review. Chrome confirmed both stable Scenarios reach `Screen ready`, an invalid Canvas route reaches the approved parent failure copy, and recovery returns to ready. Current mobile/desktop captures are in [08-BROWSER.md](phases/08-first-inspectable-book-and-local-host-path/08-BROWSER.md); browser behavior is verified, while visual-baseline acceptance remains with the owner. The full resumption evidence is in [08-05-RESUMPTION-2026-11-22.md](phases/08-first-inspectable-book-and-local-host-path/08-05-RESUMPTION-2026-11-22.md); the 2026-11-21 halted report remains preserved byte-for-byte in [08-05-HALTED-SUMMARY-2026-11-21.md](phases/08-first-inspectable-book-and-local-host-path/08-05-HALTED-SUMMARY-2026-11-21.md). Phase verification, baseline decision, exact-head merge and v0.7 closeout remain.
- Limits: the guard candidate remains null; guard implementation remains unauthorized; aggregate gate open; actual-library collision unknown; R9 denied and unconsumed; SEC-01 Pending; broader Macro caller-AST and explanation gaps and the legacy digest remain unresolved; the original `walking-skeleton` key stays blocked. R10 and R11 remain spent and immutable. The v0.7 exception allows one fixed, developer-authored compiled Book in development/test only and expires at v0.7 closeout. Its macro contract and implementation PRs remain separate, and both production controls passed before Book work. No Controls, user-provided values or code, audited-API use, persistence, product publication/deployment, release or follow-on milestone work is included. INT-20261121-01 permits only minimal public cited Logistify source-derived content in reviewed PRs; full repos and unrelated assets stay in the ignored cache. The unrelated Logistify brand-canon seed stays dormant.
- Inherited deferrals: IN-02, SEC-02, and 01.1-01 remain unresolved and were acknowledged as carry-forwards at v0.6 closeout.
- Product outcome: one inspectable Logistify operator Book across 2–3 addressable screens with fixed cited illustrative data, minimal navigation and the real compiled Story/Scenario and host Canvas path. Records and actions are illustrative; no logistics backend or external writes are included. The broader three-Book showcase remains future scope.
- Next action: monitor the required hosted checks on PR #106 until the exact head is green. Present the screenshots for owner baseline approval, then complete phase verification and pass ship preflight. Merge only the exact green required-check head, record the delivery receipt and close v0.7. Do not deploy or start another milestone.
- **Next actor: Codex continues the already-authorized Phase 8 delivery in the isolated candidate.** Owner action is required only when the attached captures are presented for visual-baseline acceptance. The owner does not need to rerun status commands or repeat existing authorization. The guard aggregate remains open, `walking-skeleton` blocked, R9 denied and unconsumed, SEC-01 Pending, and the one-Book exception expires at v0.7 closeout.

## Performance Metrics

- v0.3 plans drafted: 5; independent plan review passed; all five plans executed.
- Ten tasks were grouped across five plans and four waves. Phase 2 verification passed 5/5 must-haves with no unresolved human checks. PR #88 reviewed head `ded4af612df3346b8516f4a027772ed3d2bbd53f` merged as `3817912c861286608183c057d2e38ff7a260bd6e`; final-head CI [43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316) and main CI [43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473) passed. PR #87’s prerequisite delivery and main CI also passed; see [02-UAT.md](milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-UAT.md), [02-SECURITY.md](milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-SECURITY.md), and [delivery registry](references/PHASE-DELIVERIES.json).
- The v0.3 milestone audit reports all three requirements and the evidence integration flow pass; six tracked items remain nonblocking debt. See [v0.3-MILESTONE-AUDIT.md](milestones/v0.3-MILESTONE-AUDIT.md).

**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 02 P01 | 22min | 2 tasks | 2 files |
| Phase 02 P02 | 23min | 2 tasks | 2 files |
| Phase 02 P03 | 16min | 2 tasks | 1 file |
| Phase 02 P04 | 9min | 2 tasks | 1 files |
| Phase 02 P05 | 90min | 2 tasks | 5 files |
| Phase 03 P02 | not reconstructed across resumed sessions | 2 tasks | 6 files |
| Phase 03 P03 | not captured | 2 tasks | 8 files |
| Phase 06 P01 | 17 min | 1 tasks | 2 files |
| Phase 8 P01 | 12 | 1 tasks | 1 files |

## Accumulated Context

### Decisions and gates

- Owner’s systematic UI quality and AI-assisted dogfood direction, including recommendation-first continuity, is recorded in INT-20261113-01 and PRODUCT-ROADMAP.md. The real mailglass dogfood and authored Logistify showcase are separate proofs; v0.4 now owns the guard aggregate reconciliation prerequisite.
- Use one global sequence of ordinary integer phases across active-era milestones: v0.2 Phase 1, v0.3 Phase 2, then continue from the highest delivered integer when a later milestone activates. Historical dotted IDs are evidence identities, never executable routes (INT-20261112-04).
- v0.3 owns only `asn1ct_rtt:assert_defined/1`, `code/0` and `dependencies/1` on both pinned lanes under GRC-04–06. Independently revalidate the complete EX-107 sets, exact selection/complement and lane source identities in reviewed context before planning; a mismatch stops for rescoping (INT-20261111-13).
- Preserve the standard 100,000-token bound for other work, at most five exact source files per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. Recovery budgets ENV-03 and ENV-04 are one-time, scoped envelopes; ENV-04 is recorded in the active renewal receipt with a protected 31,000-token reserve. Count re-read source; do not truncate source/caller evidence to fit. The large `code/0` literal table uses its bounded byte-only check outside the prompt (INT-20261110-01, INT-20261111-13).
- GRC-04–06 are complete for the bounded Phase 2 slice; the complete EX-107 row, guard aggregate, installed-wide remainder and unfinished source/caller coverage remain open. Walking Skeleton remains blocked.
- SEC-01 remains Pending with Controls and first bundle / its first local slot; allocate the global integer when that milestone activates. Callback implementations, dynamic callers and native internals remain outside static proof.
- Preserve original source/context/effort limits, actual-library-collision stops, Macro caller-AST and explanation checkpoints. Do not resume the halted old five-slot decomposition.
- Five older artifacts are acknowledged and unresolved. Three legacy deferrals retain immutable original bytes and statuses; the new closeout receipt owns their acknowledgement. No quality threshold, requirement or safety stop is waived.
- Scheduled UAT/observations, clearance C1–C10 and visual acceptance retain their existing owners. Missing scheduled history remains not-run. See [CARRY-FORWARD.md](migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md).
- The previous primary checkout changes are preserved on a local archive branch before `~/projects/fablebook` returns to `main`; old recovery worktrees and the separate brand-intake branch/assets remain preserved. No release, deployment, brand application or new scope is included.

### Pending Todos

Phase 8 in the [active roadmap](ROADMAP.md) holds the selected work. Wider product work remains in the separate [rolling roadmap](references/PRODUCT-ROADMAP.md). At each new milestone start, treat the last owner-reviewed roadmap and original research as the baseline and refresh affected horizons. Automate useful, objective verification by default and preserve the recorded `act` environment stop unless its cause changes. See [INT-20261120-11](intent/sources/2026-11-20-11-delta-curated-rolling-roadmap.md), [INT-20261120-12](intent/sources/2026-11-20-12-upstream-milestone-scope.md), and [INT-20261120-13](intent/sources/2026-11-20-13-automated-verification-and-resource-hygiene.md).

### Blockers and concerns

The pre-plan membership/source-identity, connected-source, context-sizing, and effort gates passed for the exact pinned-lane scope. Core, floor, and integration outputs are complete; independent review, focused/full lane receipts, exact PR-head CI, merged PR/main CI, and 5/5 goal verification support GRC-04–06. High-severity delivery threat T-02-08 is closed. Four medium collision-verification findings remain explicitly open below the configured high blocking threshold; no actual collision is claimed, no production guard was added, and the manual owner stop remains binding. The static-only boundary, full EX-107 remainder, Walking Skeleton block, and SEC-01 Pending status are unchanged.

### Roadmap Evolution

- Phase 4: Evidence-only source and gap provenance closure remains separate from Phase 3 delivery. INT-20261117-01 rebases only their bounded recovery budget; Phase 4 still adds evidence only and does not close Phase 3.
- Phase 5: INT-20261118-05 authorized four keyed EX-177 rows across core/floor and the unchanged 9,712-row complement. The later saved discovery supplied source identity/span facts for the Phase 6 supplement; package-wide caller closure remains open, R9 remains unconsumed, and the aggregate stays open.

## Delivered work and archive

PR #85 is squash-merged from reviewed/tested `a90ef1d` at actual main `fb2e31b`.
Required [candidate CI](https://github.com/szTheory/fablebook/actions/runs/43124394402)
and actual [main CI](https://github.com/szTheory/fablebook/actions/runs/43138409677)
passed. Fresh closeout reads confirm merged identity and current main; guarded
implementation bytes match. [01-MERGE.md](milestones/v0.2-phases/01-bounded-guard-continuation/01-MERGE.md)
and the append-only [delivery registry](references/PHASE-DELIVERIES.json) own
immutable delivery facts. The [milestone audit](milestones/v0.2-MILESTONE-AUDIT.md)
remains passed for its selected scope; older deferrals make the archive an
explicit `override_closeout`, not a failed scoped audit.

[Roadmap](milestones/v0.2-ROADMAP.md), [requirements](milestones/v0.2-REQUIREMENTS.md),
[phase evidence](milestones/v0.2-phases/), [pre-close state](milestones/v0.2-STATE.md)
and [full closeout](milestones/v0.2-CLOSEOUT.md) preserve history. Original phase
files and the audit were moved byte-for-byte. The v0.1 cycle remains superseded
and incomplete; its archive and migration manifests remain immutable.

PR #82 and the three earlier release-contract/CI-gate/floor-reporting quick tasks
are already delivered with their recorded green receipts. PR #83 delivered the
numbering reset; PR #84 delivered lifecycle repairs, not guard implementation.
The [migration receipt](migrations/2026-11-11-milestone-reset/README.md) and
[repair delivery](audits/2026-11-11-planning-health/DELIVERY.json) retain their facts.

### Quick Tasks Completed

| # | Description | Date | Commit | Directory |
|---|-------------|------|--------|-----------|
| 261110-nhq | Harden release-workflow contracts | 2026-11-10 | 22c24b6 | [261110-nhq](quick/261110-nhq-harden-the-release-workflow-contracts-fo/) |
| 261110-she | Harden ci-gate predicate contracts | 2026-11-10 | 5a1a018 | [261110-she](quick/261110-she-harden-the-ci-gate-predicate-contracts-f/) |
| 261110-v8d | Correct floor-version not-run reporting | 2026-11-10 | 95ba228 | [261110-v8d](quick/261110-v8d-correct-the-floor-version-check-s-not-ru/) |

## Archive compatibility delivery

[PR #86](https://github.com/szTheory/fablebook/pull/86) delivered the one-file
requirements-contract fix separately from the intent/requirements archival
(ADR 0021). The owner approved exact candidate `5af1ec1` in INT-20261112-02;
actual squash merge `af83701` has complete candidate tree equality and successful
[main CI](https://github.com/szTheory/fablebook/actions/runs/43145523755).
Native post-removal planning checks pass on core and floor. The local archive
checkout contains that exact merged test file; every non-planning byte matches
actual main. Its history reconciles that actual merge as an ancestor while
retaining the newer archive tree. This is maintenance, not a new phase delivery
or aggregate closure. The annotated v0.2 tag remains local.

## Deferred Items

Items explicitly acknowledged at this milestone close; existing unresolved
statuses and owners remain authoritative. Full sanitized scan text and the
immutable-source acknowledgement exception are in [v0.2-CLOSEOUT.md](milestones/v0.2-CLOSEOUT.md).

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| verification_gaps | Phase 04 / 04-VERIFICATION-GAPS-FOUND.md | stale historical report; acknowledged, underlying verdict preserved | 2026-11-19 | v0.4 |
| debug_sessions | ci-timing-release-blocker | diagnosed; writer acknowledgement | 2026-11-11 | v0.2 |
| seeds | SEED-261110-iry | dormant; writer acknowledgement | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: IN-02 smoke route positive control | unresolved; acknowledged in closeout | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: SEC-02 fixture-only story-beam exclusion | unresolved; acknowledged in closeout | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: scheduled security registry failure | unresolved; acknowledged in closeout | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: IN-02 smoke route positive control | unresolved; re-acknowledged at closeout | 2026-11-20 | v0.6 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: SEC-02 fixture-only story-beam exclusion | unresolved; re-acknowledged at closeout | 2026-11-20 | v0.6 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: 01.1-01 transient security registry fetch failure | unresolved; re-acknowledged at closeout | 2026-11-20 | v0.6 |
| seeds | SEED-261112-sln | dormant; acknowledged at close | 2026-11-13 | v0.3 |
| deferred_items | Phase 02 / deferred-items.md: local act concurrency.queue limitation | deferred; acknowledged at close | 2026-11-13 | v0.3 |

## Session Continuity

**Last session:** 2026-11-22T23:11:07Z
**Stopped at:** Real-browser checks and captures are complete; source, focused host, production-boundary and post-fix full core checks pass. The host is stopped. Draft PR #106 is open from `/private/tmp/fablebook-v07-phase8-resume-20261122` on `gsd/phase-8-first-inspectable-book`; required hosted CI is running. Owner visual-baseline acceptance remains required before phase verification and closeout. Canonical `~/projects/fablebook` remains dirty and untouched.
**Resume file:** .planning/phases/08-first-inspectable-book-and-local-host-path/08-05-RESUMPTION-2026-11-22.md

Phase 04's three plans and goal verification are complete. The stable consumer repair preserves the old typed-gap bytes and validates both the archived stop generation and active ENV06 generation. Phase 5's four selected EX-177 rows now have the reviewed source/caller facts recorded by discovery and Phase 6; the other 9,712 rows remain unchanged. Package-wide caller closure remains unproven, R1–R8 statuses remain unchanged, R9 was not consumed, and no source body was reread for Phase 6. Candidate remains null, implementation unauthorized, aggregate gate open, legacy digest unresolved, and no automatic follow-on is authorized.

## Decisions

- [Phase 02]: Core evidence reuses the locked lane-specific resolver and pins full file and span digests for the RTT targets and direct callers.
- [Phase 02]: GRC-04–06 passed within the bounded selected slice; full EX-107 and wider safety obligations stay open.
- [Phase 02]: Floor evidence binds exact spans and callers for all three selected RTT functions to the pinned floor archive.
- [Phase 02]: Floor code/0 literal data is validated only by anchored byte grammar; runtime behavior, dynamic callers, native internals, and SEC-01 remain unproven.
- [Phase 02]: Use the immutable audit-budget records as exact membership baselines and compare each live lane against its own set.
- [Phase 02]: Keep the Phase 2 3/174 partition separate from the historical 13/164/161 partition.
- [Phase 02]: Use lane-specific selectors for floor and integration checks so each run resolves its pinned source set.
- [Phase 02]: Static source evidence does not establish runtime behavior, dynamic callers, native internals, or SEC-01 safety.
- [Phase 02]: The owner selected separate deliveries. PR #87 and PR #88 both merged with matching final-head/main CI receipts; final Phase 2 verification binds to the reviewed source slice and preserves wider gates.
- [Phase 02]: T-02-08 is closed against actual merge/main receipts. T-02-11 and T-02-SC close for their recorded events; four medium collision-verification limitations remain open below the high blocking threshold, with the manual D-06 owner stop binding.
- [Phase 03]: Preserve only lane/hash-scoped caller edges when source identity is proven; record all other graph and callback coverage as keyed gaps.
- [Phase 03]: Treat the saved EX-010 graph projection as scoped historical evidence, not a complete current graph or a dynamic-caller absence claim.
- [Phase 03]: Keep candidate null and recommendation disabled while any required source, graph, callback, or delegate gap remains.
- [Phase 03]: Keep candidate null because both evidence lanes remain incomplete and candidate-specific effort is unknown against the three-working-day limit.
- [Phase 03]: Bind all scope counts and pending-complement digests to the immutable lane records and compact keyed projection.
- [Phase 06]: Phoenix source paths remain recorded values and are excluded from the checker read allowlist. — The checker must not inspect the recorded Phoenix source targets; it reads only the approved saved evidence files.
- [Phase 06]: One observed direct run/1 call per lane is not exhaustive caller closure. — The reviewed discovery establishes only one observed direct call per lane; dynamic, delegated, callback, and external callers remain open.

### Blockers

- The metadata index records membership, not source proof. Keyed target-source/gap provenance, coverage-flag caller derivation and the nested SIZING digest recipe remain unresolved. Candidate remains null; implementation unauthorized; aggregate gate open; SEC-01 Pending; Walking Skeleton blocked.

## Operator Next Steps

Codex continues the approved Phase 8 delivery in `/private/tmp/fablebook-v07-phase8-resume-20261122` on `gsd/phase-8-first-inspectable-book`, based on current `origin/main`. Draft PR #106 is open and exact-head hosted CI is running. Real-host ready/failure behavior is verified and the current 320 px/1280 px captures are available in `08-BROWSER.md`; the owner must accept or reject the visual baseline before phase verification and closeout. Post-fix source, host and production checks pass, including the full core lane. Preserve the dirty canonical `main`; do not push its divergent 26-commit branch. Keep the Book fixed and dev/test-only, retain pinned public-source provenance and exact source gaps, and do not change the guard aggregate or `walking-skeleton` statuses. Do not retry `act`; no deployment or release is authorized. The one-Book exception expires at v0.7 closeout.
