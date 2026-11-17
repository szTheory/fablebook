---
gsd_state_version: "1.0"
milestone: v0.4
milestone_name: Guard Aggregate Reconciliation — Fablebook
current_phase: 03
current_phase_name: Guard aggregate scope rejoin and candidate sizing
current_plan: 5
status: "Stopped: ENV-06 Plan 04-02 Task 1 exceeded its cap; source access remains closed"
resumed_at: "2026-11-17T20:12:27Z under owner authorization INT-20261117-08 and bounded envelope ENV-20261117-06"
last_updated: "2026-11-17T20:50:09.607Z"
last_activity: 2026-11-17
last_activity_desc: Reconciled ENV-06 headroom, fixed validator routing and budget checks, and found one stale historical plan-input hash
state_head: 962e6f7d5cd560119ae15d5f57f487b5088b9863
progress:
  total_phases: 2
  completed_phases: 0
  total_plans: 5
  completed_plans: 4
  percent: 0
---

# Project State

## Project Reference

See [PROJECT.md](PROJECT.md), [ROADMAP.md](ROADMAP.md), the
[v0.3 closeout](milestones/v0.3-CLOSEOUT.md), the
[worktree reconciliation](references/WORKTREE-RECONCILIATION-2026-11-13.md), and the
[v0.2 closeout](milestones/v0.2-CLOSEOUT.md).

**Core value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.
**Current focus:** Phase 03 — Guard aggregate scope rejoin and candidate sizing

## Current Position

Phase: 03 (Guard aggregate scope rejoin and candidate sizing) — OPEN. Plan 03-05 Task 1 is complete; Tasks 2–3 are not-run and remain behind Phase 4 evidence gates.
Current Plan: 5 of 5
Status: At 2026-11-17T21:45:32.266Z, ENV-06 use is 592,316; 17,684 working tokens remain, with 40,000 protected. The remaining Phase 3 task cap is 38,000 before contingency, so execution cannot start within the approved ceiling.
Last activity: 2026-11-17 — corrected the ENV-06 validator ceiling, passed cheap consistency checks, and recorded the exact budget stop.

## Active Handoff

- Checkout: `/private/tmp/fablebook-phase3-remediation`; branch `gsd/phase-03-recovery-and-provenance-closure`; HEAD `962e6f7`. The primary checkout remains untouched.
- Completed: Phase 3 Plan 03-05 Task 1; Phase 4 preservation bridge and metadata rebind reviews; blocked and supported partitions; input reconciliation; validator self-test (31 checks); Phase 3 and Phase 4 execute preflights.
- Unfinished: Phase 4 R1 schedule/review/direct count and final review/handoff/summary; Phase 3 Plan 03-05 Tasks 2–3. No source body was read or emitted, no direct count or long suite ran.
- Safety stops: source access closed; no audited OTP/runtime paths, candidate remains null, implementation unauthorized, aggregate gate open, Walking Skeleton blocked, SEC-01 pending. Preserve the 40,000 reserve.
- Budget: one-time ceiling 650,000 total / 610,000 working / 40,000 reserve. Current measured use 592,316; remaining working balance 17,684. The 38,000 Phase 3 cap is short by 20,316 even before the required 10,000 contingency. The exact next-step arithmetic and receipts are in [the budget stop replan](phases/04-evidence-only-source-and-gap-provenance-closure/04-02-REPLAN-20261117-06.md) and [resource ledger](phases/04-evidence-only-source-and-gap-provenance-closure/04-RESOURCE-LEDGER.json).
- Next actor: the owner must authorize a new bounded ceiling/replan to continue. The calculated minimum total ceiling is 700,316; recommend rounding once to 705,000 while keeping the reserve at 40,000. If not, keep Phase 3 open and do not start the gated tasks.
- Provenance: INT-20261117-10 is the one-time 650,000 authorization. No further renewal is automatic.


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

No additional work is promoted into v0.3. Wider product work remains in the separate [rolling roadmap](references/PRODUCT-ROADMAP.md).

### Blockers and concerns

The pre-plan membership/source-identity, connected-source, context-sizing, and effort gates passed for the exact pinned-lane scope. Core, floor, and integration outputs are complete; independent review, focused/full lane receipts, exact PR-head CI, merged PR/main CI, and 5/5 goal verification support GRC-04–06. High-severity delivery threat T-02-08 is closed. Four medium collision-verification findings remain explicitly open below the configured high blocking threshold; no actual collision is claimed, no production guard was added, and the manual owner stop remains binding. The static-only boundary, full EX-107 remainder, Walking Skeleton block, and SEC-01 Pending status are unchanged.

### Roadmap Evolution

- Phase 4: Evidence-only source and gap provenance closure remains separate from Phase 3 delivery. INT-20261117-01 rebases only their bounded recovery budget; Phase 4 still adds evidence only and does not close Phase 3.

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
| debug_sessions | ci-timing-release-blocker | diagnosed; writer acknowledgement | 2026-11-11 | v0.2 |
| seeds | SEED-261110-iry | dormant; writer acknowledgement | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: IN-02 smoke route positive control | unresolved; acknowledged in closeout | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: SEC-02 fixture-only story-beam exclusion | unresolved; acknowledged in closeout | 2026-11-11 | v0.2 |
| deferred_items | archived v0.1 / 01.1 / deferred-items.md: scheduled security registry failure | unresolved; acknowledged in closeout | 2026-11-11 | v0.2 |
| seeds | SEED-261112-sln | dormant; acknowledged at close | 2026-11-13 | v0.3 |
| deferred_items | Phase 02 / deferred-items.md: local act concurrency.queue limitation | deferred; acknowledged at close | 2026-11-13 | v0.3 |

## Session Continuity

Active target: v0.4 Phase 3 recovery in `/private/tmp/fablebook-phase3-remediation`, branch `gsd/phase-03-recovery-and-provenance-closure`, HEAD `962e6f7d5cd560119ae15d5f57f487b5088b9863`. Plans 03-01 through 03-04 are complete; Plan 03-05 Task 1 local repairs pass, and Tasks 2–3 remain not-run. Phase 4 Plan 04-01 is a metadata-only stop. Plan 04-02 Task 1 is active; validator self-test, bridge validation/review, and input-reconciliation review pass within their scopes. The supported generation and ENV-06 active ledger are not yet created. One stale historical `03-05-PLAN.md` input hash is separately preserved for rebind. No helper body, direct count, source-dependent suite, implementation, PR, hosted CI, merge, or delivery is claimed.

ENV-20261117-06 has 368,420 measured output tokens at the latest exact snapshot (2026-11-17T20:30:04.820Z), leaving 131,580 under its 500,000 working ceiling; the 40,000 reserve is protected. Remaining ceilings total 130,742, while calibrated estimates project 115,142 and 16,438 contingency at that snapshot. Task 04-02-01 has a 220,000 lifetime cap with at most 17,427 remaining. Post-snapshot output has not yet been reconciled. The original dirty checkout and historical worktree remain untouched. Candidate remains null, implementation unauthorized, aggregate gate open, Walking Skeleton blocked, SEC-01 Pending, and all static-only/collision/Macro stops remain binding.

Next action: continue the supported metadata-generation construction and cheap partition/ledger checks; the detached bridge and rebind review already returned. Before any schedule review or source gate, reconcile the live output counters and require at least 10,000 contingency beyond measured next-work cost. R1 stays closed until the fresh schedule review, Phase 4 execute preflight, direct count, and exact cumulative fit pass. No owner action is needed for this bounded work; stop at any failed gate or active cap.

Resume file: `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-02-REPLAN-20261117-04.md`
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

### Blockers

- The metadata index records membership, not source proof. Keyed target-source/gap provenance, coverage-flag caller derivation and the nested SIZING digest recipe remain unresolved. Candidate remains null; implementation unauthorized; aggregate gate open; SEC-01 Pending; Walking Skeleton blocked.

## Operator Next Steps

- Codex next: run Phase 4 Plan 04-01's bounded metadata tasks, then reconcile exact input/output usage and remaining balance before the next plan wave. Keep the source schedule/review/preflight/direct-count gates and all safety stops active. The local repair and budget history are in [03-RECOVERY-READINESS.md](phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECOVERY-READINESS.md), [the historical budget stop](forensics/phase4-budget-stop-20261117.md), and [the active envelope](forensics/phase4-budget-reset-20261117.md).


## Latest handoff — ENV-06 stop

Checkout: `/private/tmp/fablebook-phase3-remediation`, branch `gsd/phase-03-recovery-and-provenance-closure`. Task 04-02-01 stopped for a 29,234-token cap overrun; exact stop and completed checks are in [the ENV-06 stop receipt](forensics/phase4-task-cap-stop-env06-20261117.md). The supported metadata partition passes, but the two missing Phase 4 consumer artifacts keep Plan 04-03 and Phase 3 Tasks 2–3 not-run. Source access remains closed. Next actor: owner, only if authorizing a bounded budget replan.
