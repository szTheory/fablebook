---
gsd_state_version: "1.0"
milestone: v0.3
milestone_name: Bounded ASN.1 RTT Guard Evidence
current_phase: 2
current_phase_name: Bounded ASN.1 RTT guard evidence
status: executing
stopped_at: "The owner chose separate deliveries. Automated UAT is complete in `02-UAT.md`; both local full lanes passed on PR-shaped tree `3c87cdb`, and remote PR #88 source head `2e35c62135c436a2ef953381024f82c237db188f` passed hosted checks in [run 43362320210](https://github.com/szTheory/fablebook/actions/runs/43362320210). Security audit closed 11/16 threats; only high T-02-08 remains open because PR #87 and #88 are unmerged and actual merge/main receipts are absent. Four collision threats are not presently triggered because the phase adds no production guard; D-06/manual stop remains binding for future guard work. The local candidate branch has two validation-document commits after the hosted head; they do not alter tests or runtime code. Formal phase verification is stopped at the security gate. Next: owner reviews/merges #87, then #88 targets/rebases onto main, runs required checks on the final head, and records merge/main receipts. Keep GRC-04/05/06, static-only limits, full EX-107 remainder, Walking Skeleton block and SEC-01 Pending unchanged."
last_updated: "2026-11-13T06:00:33.611Z"
last_activity: 2026-11-13
last_activity_desc: Phase 2 UAT and security audit recorded; T-02-08 remains open for merge/main receipts
state_head: 005f8f112f422323517a58817c1602e9a7fcb45e
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 5
  completed_plans: 5
  percent: 0
---

# Project State

## Project Reference

See [PROJECT.md](PROJECT.md), [ROADMAP.md](ROADMAP.md) and the
[v0.2 closeout](milestones/v0.2-CLOSEOUT.md).

**Core value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.
**Current focus:** Phase 2 — Bounded ASN.1 RTT guard evidence

## Current Position

Phase: 2 (Bounded ASN.1 RTT guard evidence) — EXECUTING
Plan: 5 of 5
Status: Automated UAT complete; security gate blocks formal verification pending merge/main receipts
Last activity: 2026-11-13 — Recorded Phase 2 UAT and security findings

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

- v0.3 plans drafted: 5; independent plan review passed; all five plans executed.
- Ten tasks are grouped across five plans and four waves. The local full core/floor suites pass on PR-shaped tree `3c87cdb`; remote PR #88 source head `2e35c62` passed hosted core/floor/security/dialyzer/gate checks. Automated UAT is complete. Formal verification is stopped by high threat T-02-08 pending merge/main receipts.

**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 02 P01 | 22min | 2 tasks | 2 files |
| Phase 02 P02 | 23min | 2 tasks | 2 files |
| Phase 02 P03 | 16min | 2 tasks | 1 file |
| Phase 02 P04 | 9min | 2 tasks | 1 files |
| Phase 02 P05 | 90min | 2 tasks | 5 files |

## Accumulated Context

### Decisions and gates

- Use one global sequence of ordinary integer phases across active-era milestones: v0.2 Phase 1, v0.3 Phase 2, then continue from the highest delivered integer when a later milestone activates. Historical dotted IDs are evidence identities, never executable routes (INT-20261112-04).
- v0.3 owns only `asn1ct_rtt:assert_defined/1`, `code/0` and `dependencies/1` on both pinned lanes under GRC-04–06. Independently revalidate the complete EX-107 sets, exact selection/complement and lane source identities in reviewed context before planning; a mismatch stops for rescoping (INT-20261111-13).
- Preserve the 100,000-token planning bound, at most five total exact source files read per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. Count re-read source; do not truncate source/caller evidence to fit. The large `code/0` literal table uses its bounded byte-only check outside the prompt (INT-20261110-01, INT-20261111-13).
- Only GRC-01–03 and selected EX-010 tracing-front static coverage close. The complete guard aggregate, installed-wide remainder and unfinished source/caller coverage remain open. Walking skeleton remains blocked.
- SEC-01 remains Pending with Controls and first bundle / its first local slot; allocate the global integer when that milestone activates. Callback implementations, dynamic callers and native internals remain outside static proof.
- Preserve original source/context/effort limits, actual-library-collision stops, Macro caller-AST and explanation checkpoints. Do not resume the halted old five-slot decomposition.
- Five older artifacts are acknowledged and unresolved. Three legacy deferrals retain immutable original bytes and statuses; the new closeout receipt owns their acknowledgement. No quality threshold, requirement or safety stop is waived.
- Scheduled UAT/observations, clearance C1–C10 and visual acceptance retain their existing owners. Missing scheduled history remains not-run. See [CARRY-FORWARD.md](migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md).
- Preserve the dirty primary checkout, old recovery worktrees and separate brand-intake branch/assets. No release, deployment, brand application or new scope is included.

### Pending Todos

No additional work is promoted into v0.3. Wider product work remains in the separate [rolling roadmap](references/PRODUCT-ROADMAP.md).

### Blockers and concerns

The pre-plan membership/source-identity, connected-source, context-sizing, and effort gates passed for the exact pinned-lane scope. The owner selected disjoint outputs: core owns `test/support/asn1_rtt_core_evidence.ex` and `test/contract/asn1_rtt_core_guard_test.exs`; floor owns `test/support/asn1_rtt_floor_evidence.ex` and `test/contract/asn1_rtt_floor_guard_test.exs`; integration owns the dedicated `test/contract/asn1_rtt_integration_test.exs` with evidence assertions inline. `test/support/sweep_evidence.ex` remains the read-only archive resolver. Plans 02-01 through 02-05 are complete. Both full pinned-lane suites pass on the PR-shaped local candidate tree; the exact Phase 2 PR head still needs hosted CI and delivery verification. The actual-library collision stop, static-only boundary, full EX-107 remainder, Walking Skeleton block, and SEC-01 Pending status are unchanged.

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

## Session Continuity

Working checkout: `/private/tmp/fablebook-phase2-candidate` on
`gsd/phase2-bounded-asn1-rtt-evidence`, stacked on the green test-only prerequisite PR #87. The preserved primary checkout remains on `gsd/phase-1-bounded-guard-continuation` with unrelated dirty user material untouched.
Actual main contains approved PR #85 implementation and PR #86 compatibility
maintenance. Local history incorporates that main commit without restoring old
active phase paths. Phase 2 implementation artifacts are in open PR #88 at remote
head `2e35c62`; the local candidate is at `5776488` with two validation-document
commits plus local verification reports. Keep the open delivery stop until #87
merges and #88 is retargeted/rebased to main, then carry receipts with the next
substantive push. Do not trigger a receipt-only CI loop. Preserve this checkout.

Separate brand intake: `origin/agent-brand-intake-261111` at `1ad8bde`;
[the intake handoff](references/fablebook-brand-intake.md) owns future use.
INT-20261111-06, INT-20261111-07 and INT-20261111-08 and the handoff pointer are retained unchanged. Assets are
unapplied; source/instructions/seed/brief remain on their separate branch.

Last session: 2026-11-13T06:00:33Z

Stopped at: Phase 2 automated UAT is complete. Local full core/floor suites pass on the recorded PR-shaped tree and remote PR #88 source head has green hosted checks. `02-SECURITY.md` records one open high threat, T-02-08, because PR #87/#88 remain unmerged and no hosted main receipt exists. The old partial UAT in the primary checkout is preserved as historical; this separate-delivery candidate has superseding complete automated evidence. GRC-04/05/06 remain pending; static-only boundaries, future collision stop, full EX-107 remainder, Walking Skeleton block and SEC-01 Pending remain unchanged.

Next action: Owner reviews/merges green prerequisite PR #87. Then retarget/rebase PR #88 onto main, confirm required hosted checks on that final candidate head, complete formal phase verification, and record actual merge/main receipts. Do not mark Phase 2 verified or delivered before that evidence exists.
Do not execute the delivered v0.2 Phase 1 again, automatically select another
guard increment, bypass the Walking Skeleton block or close SEC-01. Generated
state.json was refreshed through the SDK publisher after the canonical state
update. It
remains advisory and cannot override the canonical stopping point or authorize
phase discussion.

Resume file: None

## Decisions

- [Phase 02]: Core evidence reuses the locked lane-specific resolver and pins full file and span digests for the RTT targets and direct callers.
- [Phase 02]: GRC-04 and GRC-05 remain pending until floor-lane evidence and cross-lane reconciliation complete their full requirement scope.
- [Phase 02]: Floor evidence binds exact spans and callers for all three selected RTT functions to the pinned floor archive.
- [Phase 02]: Floor code/0 literal data is validated only by anchored byte grammar; runtime behavior, dynamic callers, native internals, and SEC-01 remain unproven.
- [Phase 02]: Use the immutable audit-budget records as exact membership baselines and compare each live lane against its own set.
- [Phase 02]: Keep the Phase 2 3/174 partition separate from the historical 13/164/161 partition.
- [Phase 02]: Use lane-specific selectors for floor and integration checks so each run resolves its pinned source set.
- [Phase 02]: Static source evidence does not establish runtime behavior, dynamic callers, native internals, or SEC-01 safety.
- [Phase 02]: The owner selected separate deliveries. Planning tests are isolated in PR #87 from guarded Phase 2 outputs in PR #88; both local full lanes and remote hosted core/floor checks pass for their recorded heads.
- [Phase 02]: T-02-11 and T-02-SC close for their recorded events. Collision findings are not presently triggered because no production guard was added; preserve the manual D-06 owner stop for future guard work. T-02-08 remains open until actual merge/main evidence is reconciled.

### Blockers

- Formal phase verification is held at the security gate by T-02-08. PR #87 is green but unmerged; PR #88 is stacked on it. After the owner merges #87, rebase/retarget #88 to `main`, confirm its exact-head hosted checks and actual main CI, then complete phase verification. Do not change the static-only boundary or mark GRC-04/05/06 complete before their own acceptance evidence.
