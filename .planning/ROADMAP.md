# Roadmap: Fablebook

## Completed Milestones

- ✅ **v0.5 Bounded EX-177 Provenance Follow-through** — closed 2026-11-19 after the bounded Phase 6 delivery and archive closeout; all wider guard and product gates remain open. [Roadmap](milestones/v0.5-ROADMAP.md) · [requirements](milestones/v0.5-REQUIREMENTS.md) · [closeout](milestones/v0.5-CLOSEOUT.md)
- ✅ **v0.4 Guard Aggregate Reconciliation** — archived 2026-11-19; the wider guard aggregate remains open. [Roadmap](milestones/v0.4-ROADMAP.md) · [closeout](milestones/v0.4-CLOSEOUT.md)
- ✅ **v0.3 Bounded ASN.1 RTT Guard Evidence** — archived 2026-11-13. [Roadmap](milestones/v0.3-ROADMAP.md) · [closeout](milestones/v0.3-CLOSEOUT.md)
- ✅ **v0.2 Guard coverage recovery** — archived 2026-11-11. [Roadmap](milestones/v0.2-ROADMAP.md) · [closeout](milestones/v0.2-CLOSEOUT.md)
- ⚠️ **v0.1 Legacy planning cycle** — superseded and incomplete; not a whole-product ship claim. [Historical roadmap](milestones/v0.1-ROADMAP.md)

## v0.6 — Guard Scope Reconciliation

**Milestone key:** guard-recovery

**Milestone goal:** Reconcile current pinned-lane guard membership and source identities, propose one exact family and its complete complement with bounded caller/delegate evidence, refresh sizing, and stop for the owner's next-scope decision.

Phase 7 originally delivered a bounded, read-only reconciliation package and passed verification against the then-pinned lock. After required hosted CI found a new LiveView advisory, the owner authorized a narrow pre-delivery amendment under [INT-20261120-07](intent/sources/2026-11-20-07-authorize-phase7-security-rebaseline.md): update the existing `phoenix_live_view` dependency to patched 1.2.14 and refresh/review only the lock-bound core and source-schedule evidence needed for current verification. This does not implement guards, invoke audited runtime APIs, consume R9, claim exhaustive or package-wide caller closure, promote a code candidate, close the aggregate, start Walking Skeleton, or build product UI/Books. The actual-library-collision stop, candidate-null state, Macro caller-AST and explanation gaps, SEC-01 Pending, legacy digest gap, all inherited source/budget limits, and every spent request remain unchanged. This amendment does not authorize another guard increment or automatic follow-on. See [selected intent](intent/sources/2026-11-19-05-select-v06-guard-reconciliation.md), [research synthesis](research/2026-11-19-v0.6-guard-scope-reconciliation.md), and the [rolling product roadmap](references/PRODUCT-ROADMAP.md).

## Phases

- [x] **Phase 7: Guard Scope Reconciliation** - Rejoin the current two-lane inventory and produce one bounded, reviewable reconciliation package for an owner decision; refresh lock-bound evidence for the owner-approved LiveView security patch before delivery. (verified 2026-11-20; delivery pending exact-head hosted CI and merge)

## Phase Details

### Phase 7: Guard Scope Reconciliation
**Goal**: The owner can review one current, lane-pinned guard-scope reconciliation with its full complement, bounded evidence and gaps, refreshed sizing, and a clear recommendation; its core evidence and reviewed source schedule are bound to the security-patched lock before this phase is delivered.
**Depends on**: Phase 6 delivery and v0.5 closeout
**Requirements**: RSC-01, RSC-02, RSC-03, RSC-04
**Success Criteria** (what must be TRUE):
  1. The owner can review the complete relevant surviving row/function membership and exact source identity for each pinned lane, see differences from saved inventories, and see mismatches stop the work for rescoping. (RSC-01)
  2. The owner can review one exact proposed family and its complete, disjoint complement for each current lane, with reproducible counts and digests and a clear distinction from a selected or promoted code candidate. (RSC-02)
  3. The owner can review lane-pinned, provenance-linked source, caller, and delegate observations for the proposed family, along with explicit gaps and limits that do not imply exhaustive or package-wide caller closure. (RSC-03)
  4. The owner can review refreshed source, context, and effort sizing within inherited limits, all preserved safety stops, and a recommendation that ends at an explicit owner decision before any further increment. (RSC-04)
**Plans**: 5 existing plans; the narrow security-rebaseline amendment was completed inside the existing final plan. The phase's five-plan limit remains in force; no sixth plan was added.
- [x] 07-01-PLAN.md
- [x] 07-02-PLAN.md
- [x] 07-03-PLAN.md
- [x] 07-04-PLAN.md
- [x] 07-05-PLAN.md
**Current status**: The original verification for LiveView 1.2.13 remains preserved in history. The authorized 1.2.14 rebaseline is now independently reviewed and verified 4/4 against the current core lock, while the accepted ENV06 floor evidence is retained unchanged. Core inventory rows, proposed family/complement, all consumed request IDs, and no-retry gaps reconcile exactly; the candidate remains null and the aggregate stays open. The lock checker, reconciliation validator, Hex audit, focused contract tests, and local core CI pass; code review is clean. PR #96 still points to the earlier vulnerable head. The reviewed local candidate is ready to commit and push so hosted exact-head CI can run; merge and v0.6 closeout remain pending. See the [ship receipt](phases/07-guard-scope-reconciliation/07-SHIP-STATUS.md).

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 7. Guard Scope Reconciliation | 5/5 | Verification passed; hosted delivery pending | 2026-11-20 |

## Next

The next action is to commit and push the reviewed local candidate to PR #96, then require green hosted checks on that exact head before the authorized squash merge and v0.6 closeout. The original verification and failed security receipt remain preserved as history. Do not reopen consumed requests, change the five-plan limit, or start a next milestone. The aggregate remains open and still blocks Walking Skeleton, the Fablebook/Logistify Books, and runnable demos. The authored Fablebook Brand Book is viewable, but it is not an implemented catalog or demo. No guard implementation, candidate promotion, gate change, or automatic follow-on is authorized. R10 and R11 remain spent; do not resume either request.
