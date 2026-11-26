---
gsd_state_version: "1.0"
milestone: v0.7
milestone_name: First Inspectable Book
current_phase: 8
current_phase_name: First inspectable Book and local host path
status: executing
stopped_at: null
last_updated: "2026-11-26T00:58:03.070Z"
last_activity: 2026-11-25
last_activity_desc: Phase 8 planning complete — 6 plans ready
state_head: 12b242c250222002d791d402a3dd03bc784c58b0
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 6
  completed_plans: 5
  percent: 0
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

Phase: 8 (First inspectable Book and local host path) — READY TO EXECUTE
Plan: 08-06 ready to execute; 5 of 6 plans complete; delivery incomplete
Total Plans in Phase: 6
Status: Authorized work continues; delivery incomplete
Last activity: 2026-11-25 — planned the verified UI-SPEC gap closure and clarified source-check scope
Last Activity Description: Plan 08-06 passed independent plan review; execute the UI closure before refreshing goal verification


## Active Handoff

- Checkout: `~/projects/fablebook` on `main` at `f23da6e341997999a084049436037bd6bd55c0af`; after fetching, `origin/main` is `0e406e648d52b93da52f4d641116cfa28cf9bb6c`. The histories diverge at `5b08774`: 26 local commits and uncommitted planning/source/code work remain here, while four newer commits are on `origin/main`. Preserve this checkout and do not push its full local branch. The dirty historical worktree and dormant brand-intake checkout remain untouched.
- Active delivery checkout: `/private/tmp/fablebook-v07-phase8-screenshot-free` on `gsd/phase-8-first-inspectable-book`, based on `origin/main` at `0e406e6`; local HEAD is `12b242c` before the plan-state commit. The Journey-scoped Scenario route fix and host-test additions have clean incremental reviews; the focused operator-host suite, strict Credo, and full core lane (467 passed, 10 configured exclusions) are recorded. Draft PR #106 is still at public head `2e648f5efa4c440541d0cd25b397370d8637af05`, green in exact-head CI run 45713720366; local evidence and gap-plan commits are not on that public head. UAT is 6/6 complete. UI review found explicit contract gaps, and reviewed gap-closure plan 08-06 is ready to execute. INT-20261125-06 confirms source custody is checked before authoring and in CI; local browsing does not require the ignored originals cache. The verification report is stale after the new decision and gap plan and must be regenerated after plan 08-06. The canonical planning checkout above remains on `main` and untouched.
- The earlier linked candidate checkout remains preserved at `/private/tmp/fablebook-v07-phase8-resume-20261122` at c954411. Its Git metadata lives in the read-only shared checkout, so use the independent active clone for further branch updates.
- Delivered: v0.6 Phase 7, 5 plans, 12 tasks. Exact-head hosted CI [run 44827619883](https://github.com/szTheory/fablebook/actions/runs/44827619883) passed; PR #96 merged as `0ea95d4c8cdf6ce9a1af363c7ea0033d632b0e6d`; post-merge main CI [run 44828949627](https://github.com/szTheory/fablebook/actions/runs/44828949627) passed. Planning archive closeout PR #97 is merged. The v0.7 planning-only PR #98 is merged with passing exact-head CI [run 44872457695](https://github.com/szTheory/fablebook/actions/runs/44872457695); it is not an implementation delivery.
- Current: v0.7 “First Inspectable Book” remains active under the existing authorization. Plans 08-01 through 08-05 and prerequisite PRs #99–#105 are delivered; plan 08-06 is reviewed and ready to execute for the UI-SPEC findings. Draft PR [#106](https://github.com/szTheory/fablebook/pull/106) remains at public head `2e648f5efa4c440541d0cd25b397370d8637af05`, green in [run 45713720366](https://github.com/szTheory/fablebook/actions/runs/45713720366); local source/test and planning evidence commits still need to be pushed after verification. The owner accepted the live visual baseline in [INT-20261125-04](intent/sources/2026-11-25-04-accept-phase8-visual-baseline.md), accepted the existing Chrome ready/failure evidence as manual verification in [INT-20261125-05](intent/sources/2026-11-25-05-accept-canvas-lifecycle-browser-evidence.md), and clarified source custody as an authoring/CI gate in [INT-20261125-06](intent/sources/2026-11-25-06-clarify-phase8-source-custody-boundary.md). UAT is 6/6 complete. No automated test executes the JavaScript ready/failure transitions; the owner accepted the recorded browser evidence for this phase. Execute plan 08-06, run its focused host and browser-geometry checks, then refresh goal verification through the phase gates. The old verification report is stale. Existing guard aggregate, walking-skeleton, R9 and SEC-01 stops remain unchanged.
- Limits: the guard candidate remains null; guard implementation remains unauthorized; aggregate gate open; actual-library collision unknown; R9 denied and unconsumed; SEC-01 Pending; broader Macro caller-AST and explanation gaps and the legacy digest remain unresolved; the original `walking-skeleton` key stays blocked. R10 and R11 remain spent and immutable. The v0.7 exception allows one fixed, developer-authored compiled Book in development/test only and expires at v0.7 closeout. Its macro contract and implementation PRs remain separate, and both production controls passed before Book work. No Controls, user-provided values or code, audited-API use, persistence, product publication/deployment, release or follow-on milestone work is included. INT-20261121-01 permits only minimal public cited Logistify source-derived content in reviewed PRs; full repos and unrelated assets stay in the ignored cache. The unrelated Logistify brand-canon seed stays dormant.
- Inherited deferrals: IN-02, SEC-02, and 01.1-01 remain unresolved and were acknowledged as carry-forwards at v0.6 closeout.
- Product outcome: one inspectable Logistify operator Book across 2–3 addressable screens with fixed cited illustrative data, minimal navigation and the real compiled Story/Scenario and host Canvas path. Records and actions are illustrative; no logistics backend or external writes are included. The broader three-Book showcase remains future scope.
- Next action: execute Phase 8 plan 08-06 (`$gsd-execute-phase 08 --gaps-only`), perform the focused host tests and the planned 320px/375px/200% browser geometry checks, then rerun the verification gates. After a passing report, run ship preflight and review, publish the final evidence candidate, obtain green required CI on its exact head, make PR #106 ready, and squash-merge the reviewed green head. Record actual delivery and close v0.7 against its own requirements. Do not deploy, release, or start another milestone.
- **Next actor: Codex.** Plan 08-06 is reviewed and ready to execute in the isolated screenshot-free worktree. The source-custody boundary is resolved by INT-20261125-06; the current goal-verification report must be refreshed after implementation. Then exact-head hosted CI, ship review, merge, delivery receipt and v0.7 closeout remain. The guard aggregate remains open, walking-skeleton blocked, R9 denied and unconsumed, SEC-01 Pending.

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

**Last session:** 2026-11-26T00:59:32Z
**Stopped at:** Phase 8 UAT is complete 6/6. The owner accepted the visual baseline (INT-20261125-04), accepted the existing Chrome ready/failure evidence as manual verification (INT-20261125-05), and clarified that source custody is an authoring/CI gate only (INT-20261125-06). Plan 08-06 passed independent plan review and is ready to execute in `/private/tmp/fablebook-v07-phase8-screenshot-free` on `gsd/phase-8-first-inspectable-book`. Draft PR #106 public head `2e648f5efa4c440541d0cd25b397370d8637af05` passed required CI run 45713720366, but does not include the local gap plan or final evidence. Execute plan 08-06 and its host/browser checks, then refresh verification through the phase gates before ship review. Obtain exact-head hosted CI, merge, record delivery and close v0.7. Preserve the dirty canonical checkout and earlier linked candidate checkout. Existing guard aggregate, walking-skeleton, R9 and SEC-01 stops remain unchanged. No deploy, release or new milestone.
**Resume file:** .planning/phases/08-first-inspectable-book-and-local-host-path/08-05-RESUMPTION-2026-11-25.md

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

Plan 08-06 passed independent review. Execute it in the isolated screenshot-free checkout, run the focused host suite and browser geometry checks at 320x900, 375x812 and 200% text zoom, then regenerate Phase 8 verification through the configured gates. After it passes, ship review, final evidence commit, exact-head hosted CI, merge, delivery receipt and v0.7 closeout remain. Preserve the dirty canonical `main` and do not change the guard aggregate, walking-skeleton, R9 or SEC-01 stops. No deployment, release or follow-on milestone is authorized.
