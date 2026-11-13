# Roadmap: Fablebook

## Milestones

- **v0.3 Bounded ASN.1 RTT Guard Evidence** — active scope; all five reviewed Phase 2 plans have summaries. Plan 02-05's full core/floor checks failed, so local readiness is blocked and phase requirements remain pending.
- v0.2 Guard coverage recovery — Phase 1 complete, archived 2026-11-11; [roadmap and phase details](milestones/v0.2-ROADMAP.md).
- v0.1 Legacy planning cycle — superseded and incomplete; [historical roadmap](milestones/v0.1-ROADMAP.md).

## v0.3 — Bounded ASN.1 RTT Guard Evidence

**Milestone key:** guard-recovery

Establish source-backed dispositions for `asn1ct_rtt:assert_defined/1`,
`asn1ct_rtt:code/0`, and `asn1ct_rtt:dependencies/1` on both pinned lanes,
preserving the complete EX-107 row and its exact pending complement. This
reduces unfinished static source evidence for three selected functions per
lane; it does not remove the complete product blocker. The three approved
requirements form one coherent phase even at fine granularity.
(INT-20261111-13, INT-20261111-01, INT-20261110-01, INT-20261112-03, ADR 0004, ADR 0021)

## Phases

Phase numbers are ordinary integers in one project-wide sequence. v0.2 Phase 1
was delivered; this first and only v0.3 phase is Phase 2. Later milestones
continue after the highest delivered integer. Future roadmap slots receive
global IDs when their milestone activates. (INT-20261112-04)

- [ ] **Phase 2: Bounded ASN.1 RTT guard evidence** - Disposition only the approved three-function EX-107 slice on both lanes through existing source, review and delivery gates.

## Phase Details

### Phase 2: Bounded ASN.1 RTT guard evidence

**Goal**: The owner can inspect source-backed dispositions and individually falsifiable controls for the three selected RTT functions on each pinned lane, delivered through a reviewed green PR with the full EX-107 remainder and wider gates intact.
**Depends on**: Nothing within v0.3 (first phase); reuse archived deliveries only within their proven scope. Before executable planning, the reviewed context must revalidate current EX-107 membership and lane-specific source identities and establish source/context/effort fit; `02-RESEARCH.md` records these gates as passed for this exact scope.
**Requirements**: GRC-04, GRC-05, GRC-06
**Success Criteria** (what must be TRUE):
  1. The owner can compare independently revalidated core and floor EX-107 match sets with archived evidence, identify exactly the approved three-function selection and remaining complement, and inspect each lane's source identities. A membership or identity mismatch stops planning for rescoping; matching counts alone cannot pass. (GRC-04)
  2. For every selected function on each lane, the owner can follow exact source spans and its direct caller path to a source-backed disposition, with runtime behavior, dynamic callers and native internals explicitly left unproven. (GRC-05)
  3. Each selected function has individually non-vacuous positive and negative controls on both lanes. The owner can inspect the bounded byte-only result for the large literal table in `code/0`, produced outside the prompt without invoking audited APIs. (GRC-05)
  4. The owner can follow the reviewed candidate to required exact-head CI and the actual green merged PR/main delivery; evidence and completion identify the same selected slice under existing review, security and verification gates. (GRC-06)
  5. At the bounded exit, the owner can see EX-107's complete identity, exact selected/remainder partition, preserved limits and remaining obligations: the full row and guard aggregate remain open, Walking Skeleton stays blocked, SEC-01 stays Pending with Controls and first bundle / its first local slot (global ID assigned on activation), and another increment requires a fresh owner decision. (GRC-06)
**Plans**:
- [x] 02-01-PLAN.md
- [x] 02-02-PLAN.md
- [x] 02-03-PLAN.md
- [x] 02-04-PLAN.md
- [x] 02-05-PLAN.md
  1. [02-01 — Core evidence](phases/02-bounded-asn-1-rtt-guard-evidence/02-01-PLAN.md)
  2. [02-02 — Floor evidence](phases/02-bounded-asn-1-rtt-guard-evidence/02-02-PLAN.md)
  3. [02-03 — Cross-lane integration](phases/02-bounded-asn-1-rtt-guard-evidence/02-03-PLAN.md)
  4. [02-04 — Independent review and bounded corrections](phases/02-bounded-asn-1-rtt-guard-evidence/02-04-PLAN.md)
  5. [02-05 — Full local checks and readiness handoff](phases/02-bounded-asn-1-rtt-guard-evidence/02-05-PLAN.md)

**Planning complete:** The owner selected separate core, floor, and integration evidence/test outputs. The five-plan set passed independent review. Core plan 02-01 and floor plan 02-02 are complete; cross-lane integration, independent review/corrections, and full local checks remain in the approved sequence.

### Inherited limits and stop conditions

- Before executable planning, record complete connected-source membership, context sizing and an itemized effort estimate. These Phase 2 pre-plan gates are recorded as passed in `02-RESEARCH.md`; if source scope, identity or context changes, stop and recheck. Preserve the 100,000-token planning bound, at most five total exact source files read per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. Count already-bound source when re-read; reuse structured findings only within their scope. Do not truncate functions, files, citations or caller paths to fit. The approved bounded byte-only procedure for `code/0` keeps its large literal table outside the prompt. (INT-20261110-01, INT-20261111-13)
- Bind core and floor independently to their pinned lane identities and approved source/archive authority. Missing source, mismatched membership or identity, relevant source expansion or an effort/context overrun stops the slice for a concrete bounded remedy; no implicit scope substitution or extra phase is authorized. (GRC-04)
- Preserve actual-library-collision stops, Macro caller-AST and explanation checkpoints. Never invoke audited functions, callbacks or atom sinks; source evidence and green CI do not establish runtime safety. Keep ADR 0021 contract-test separation, the existing review cap and all required candidate/main CI gates. (ADR 0004, ADR 0021)

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 2. Bounded ASN.1 RTT guard evidence | 5/5 | In Progress; core plan 02-01 complete | - |

**Coverage:** 3/3 approved v0.3 requirements mapped exactly once; no unmapped requirements. All remain Pending until their phase evidence passes.

## Preserved boundaries and next action

The complete guard aggregate and installed-wide remainder remain open; Walking
Skeleton stays blocked and SEC-01 remains Pending with Controls and first
bundle's first local slot (global ID assigned on activation). Five acknowledged
v0.2 deferrals remain unresolved. Scheduled
observations, clearance C1–C10, visual acceptance and other unfinished safety
stops retain their owners in the [carry-forward register](migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md)
and [planning gates](references/PLANNING-GATES.json).

Logistify/Fablebook brandbooks, UI catalog and demo work stay in the separate
[rolling product roadmap](references/PRODUCT-ROADMAP.md); no product implementation,
release, deployment, brand application or automatic follow-up is authorized here.
After selected delivery and the required closeout, the owner chooses whether to
authorize another bounded increment or revisit the aggregate strategy.

Current position: Phase 2 is executing under the approved scope. Core plan 02-01 is complete; plans 02-02 through 02-05 remain. The actual-library collision stop, static-only evidence limit, complete EX-107 remainder, Walking Skeleton block, and SEC-01 Pending status remain unchanged. Next: continue with `$gsd-execute-phase 2` at plan 02-02.
