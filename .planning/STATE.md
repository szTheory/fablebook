---
gsd_state_version: "1.0"
milestone: v0.4
milestone_name: Guard Aggregate Reconciliation — Fablebook
current_phase: 03
current_phase_name: Guard aggregate scope rejoin and candidate sizing
current_plan: 5
status: "Phase 3 recovery active under a fresh capped Phase 4 provenance gate"
stopped_at: "The 80,000-token envelope exceeded its 49,000 working ceiling; a fresh 90,000-token envelope is active with 31,000 reserve"
last_updated: "2026-11-17T16:11:11Z"
last_activity: 2026-11-17
last_activity_desc: Owner authorized a fresh 90,000-token recovery envelope after the previous working ceiling was exceeded
state_head: 60c5a9eca2f2216cd2071829456991f858b1f4d1
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

Phase: 03 (Guard aggregate scope rejoin and candidate sizing) — OPEN; bounded recovery continues under INT-20261117-04 through the Phase 4 provenance gate
Current Plan: 5
Total Plans in Phase: 5
Progress: 4/5 plans complete ([░░░░░░░░░░] 0%)
Plan: 5 of 5; Plan 03-05 Task 1 local repairs pass; Tasks 2–3 remain behind the active Phase 4 provenance gate
Status: The prior 150,000-token envelope exceeded its ceiling by 112,847. The next 80,000-token envelope used 60,773 parent output tokens and exceeded its 49,000 working ceiling by 11,773 before execution. The owner authorized a fresh 90,000-token envelope with 59,000 working tokens and 31,000 reserve. Phase 4 Plan 04-02 is next; source emission and Phase 3 source-dependent suites remain gated.
Last activity: 2026-11-17 — Owner authorized the fresh capped envelope; Phase 4 Plan 04-02 is next

## Active Handoff

- Current checkout: isolated recovery worktree at `/private/tmp/fablebook-phase3-remediation`, branch `gsd/phase-03-recovery-and-provenance-closure`, with Plan 04-01 task commits `7b24c19` and `1fbd36c`, summary commit `72c5cdd`, and prior state handoff `6d1e79a`. The exact 44-path transfer is recorded in `forensics/phase3-recovery-transfer-20261117.json`; generated `.planning/state.json` is refreshed from canonical owners. The original dirty checkout at `~/projects/fablebook` on `gsd/phase-03-guard-aggregate-scope-rejoin-and-candidate-sizing` remains untouched; the old worktree at `~/.claude/worktrees/agent-planning-main-261111` remains preserved. No push, PR, hosted CI, or delivery is claimed.
- Delivered: v0.2 Phase 1 EX-010 and v0.3 Phase 2 EX-107, with merged PR and hosted CI receipts in PHASE-DELIVERIES.json. A read-only pinned-lane probe reconfirmed those delivered row memberships.
- Delivered in this phase: Plans 03-01 through 03-03 are complete. Plan03-04's metadata route produced and validated [the gap report](phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAP-REPORT.md), [the index](phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAPS.jsonl), [the receipt](phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAP-RECEIPT.json), and [the validation record](phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAP-VALIDATION.json). This route only exposes retained metadata membership and unresolved mappings.
- Unfinished: The original [03-READINESS.md](phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-READINESS.md) remains immutable. On the isolated candidate, the two formatting errors and intent-corpus numbering/citation failures are repaired; the focused intent test passes 22/22. Plan 03-05 Task 2 has not started: the nullable collision fixture, keyed source/caller consumers and full crosswalk remain unverified. Phase 4 Plan 04-01 produced [the blocked summary](phases/04-evidence-only-source-and-gap-provenance-closure/04-01-SUMMARY.md), [metadata manifest](phases/04-evidence-only-source-and-gap-provenance-closure/04-PROVENANCE-MANIFEST.json), and [closed request schedule](phases/04-evidence-only-source-and-gap-provenance-closure/04-SOURCE-SCHEDULE.json). Three preservation hashes differ. The child log records 81,800 output tokens across Plan 04-01 and Plan 04-02 setup, exceeding their combined 32,000-token allocations; its task-level split is unavailable and parent output is unmeasured. Plan 04-02 produced no artifacts. Phase 3 is not ready for verification or complete.
- Safety stops unchanged: static-only evidence; no audited OTP APIs, callbacks, atom sinks, runtime eval or generated-code paths; stop on an actual-library collision; preserve Macro caller-AST and explanation checkpoints; `candidate=null`; `implementation_authorized=false`; `aggregate_gate=open`; Walking Skeleton blocked; SEC-01 Pending.
- Next action: Codex executes Phase 4 Plan 04-02 under ENV-20261117-03. Reconcile parent and child output before source emission and at each plan boundary. Continue only while total spend remains below 59,000; run Phase 3 source-dependent checks only after the six Phase 4 consumer files pass.
- Scope decision provenance: INT-20261113-02, bounded trace approval INT-20261115-01, one-time Phase 3 budget authorization INT-20261115-02, metadata-only recovery direction INT-20261116-03, bounded continuation authorization INT-20261116-04, bounded recovery authorization INT-20261116-05, budget rebase INT-20261117-01, and reset-point selection INT-20261117-02. Requirements and bounded exit: ROADMAP.md, REQUIREMENTS.md, 03-04-REPLAN.md, the Phase 4 context, and the budget-reset receipt.


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
- Preserve the standard 100,000-token bound for other work, at most five exact source files per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. INT-20261117-01 is a one-time 150,000 generated-output-token incremental envelope for this Phase 4/Phase 3 recovery only; its 31,000-token reserve remains protected. Count re-read source; do not truncate source/caller evidence to fit. The large `code/0` literal table uses its bounded byte-only check outside the prompt (INT-20261110-01, INT-20261111-13).
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

Active planning target: v0.4 Phase 3 recovery in isolated worktree `/private/tmp/fablebook-phase3-remediation`, branch `gsd/phase-03-recovery-and-provenance-closure`, based on HEAD `46e0b350b3ccd38a72660c5844616ec4c1d063c2`; exact transfer provenance is recorded in `forensics/phase3-recovery-transfer-20261117.json`. Plans 03-01 through 03-04 are complete under their recorded scopes. Plan 03-05 Task 1's formatting, intent recovery, citation corrections, and intent-corpus check pass; Tasks 2–3 remain behind Phase 4's exact evidence and per-request gates. INT-20261117-01 supplies a 150,000 generated-output-token incremental envelope with the 31,000-token reserve protected; prior measured Phase 4 usage remains sunk and traceable. No Phase 4 source read, source-dependent suite, commit, push, PR, hosted CI, phase verification, or delivery is claimed. The original dirty checkout and old recovery worktree remain preserved. Candidate remains null, implementation unauthorized, aggregate gate open, Walking Skeleton blocked, SEC-01 Pending and all static-only/collision/Macro stops remain binding.

Last activity: 2026-11-17T13:19:47Z
Current work: Plan 03-05 Task 1 local repairs pass. The 150,000-token envelope and following 80,000-token envelope were exceeded. Owner authorization INT-20261117-05 starts a fresh 90,000-token envelope at 2026-11-17T16:11:11.228Z, with 59,000 working tokens and 31,000 reserve. Phase 4 Plan 04-02 is next; source access remains gated. See forensics/phase4-budget-renewal-02-20261117.md.

The original Phase 4 ceiling was exceeded by a conservative 191,582 output-token lower bound across nine dedicated sessions; its accounting remains in `forensics/phase4-budget-stop-20261117.md`. The owner later accepted a separate 150,000 generated-output-token incremental envelope under INT-20261117-01, with 31,000 still protected; the new receipt and exact scope are in `forensics/phase4-budget-reset-20261117.md`. This does not open any source request. The previous `bin/refresh_planning_state`, `git diff --check`, and Phase 3 execute preflight passed before the budget reset; rerun canonical refresh and lifecycle checks after these edits.

Next action: Codex executes Phase 4 Plan 04-02 under the fresh 59,000 working ceiling, updating the resource ledger and request validator before any source emission. Reconcile all thread output at the plan boundary; Phase 3 suites remain gated.

Resume file: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECOVERY-READINESS.md

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
