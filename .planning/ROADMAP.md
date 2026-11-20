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

This was one bounded, read-only evidence phase. It did not implement guards, invoke audited runtime APIs, consume R9, claim exhaustive or package-wide caller closure, promote a code candidate, close the aggregate, start Walking Skeleton, or build product UI/Books. The actual-library-collision stop, candidate-null state, Macro caller-AST and explanation gaps, SEC-01 Pending, legacy digest gap, and all inherited source/budget limits remain active. Phase exit is an owner decision boundary; no automatic follow-on is authorized. See [selected intent](intent/sources/2026-11-19-05-select-v06-guard-reconciliation.md), [research synthesis](research/2026-11-19-v0.6-guard-scope-reconciliation.md), and the [rolling product roadmap](references/PRODUCT-ROADMAP.md).

## Phases

- [x] **Phase 7: Guard Scope Reconciliation** - Rejoin the current two-lane inventory and produce one bounded, reviewable reconciliation package for an owner decision. (verified 2026-11-20; delivery pending)

## Phase Details

### Phase 7: Guard Scope Reconciliation
**Goal**: The owner can review one current, lane-pinned guard-scope reconciliation with its full complement, bounded evidence and gaps, refreshed sizing, and a clear recommendation before deciding whether to authorize another increment.
**Depends on**: Phase 6 delivery and v0.5 closeout
**Requirements**: RSC-01, RSC-02, RSC-03, RSC-04
**Success Criteria** (what must be TRUE):
  1. The owner can review the complete relevant surviving row/function membership and exact source identity for each pinned lane, see differences from saved inventories, and see mismatches stop the work for rescoping. (RSC-01)
  2. The owner can review one exact proposed family and its complete, disjoint complement for each current lane, with reproducible counts and digests and a clear distinction from a selected or promoted code candidate. (RSC-02)
  3. The owner can review lane-pinned, provenance-linked source, caller, and delegate observations for the proposed family, along with explicit gaps and limits that do not imply exhaustive or package-wide caller closure. (RSC-03)
  4. The owner can review refreshed source, context, and effort sizing within inherited limits, all preserved safety stops, and a recommendation that ends at an explicit owner decision before any further increment. (RSC-04)
**Plans**: 5/5 plans complete
- [x] 07-01-PLAN.md
- [x] 07-02-PLAN.md
- [x] 07-03-PLAN.md
- [x] 07-04-PLAN.md
- [x] 07-05-PLAN.md
**Current status**: Phase verification passed all four criteria. The current core lane has a reviewed compiled-export inventory; 226 saved rows reconcile in each lane; CN-002 through CN-006 form the proposed family with its complete per-lane complements; and the bounded source record retains three no-retry gaps. No code candidate was promoted and the aggregate gate remains open. PR #96 is open, but its required hosted security check fails because the pinned `phoenix_live_view` 1.2.13 is affected by a newly published advisory. The evidence is bound to the current lockfile; changing that dependency requires a fresh current-core inventory and a newly reviewed source schedule. The completed-phase planning gate rejects re-entry. No merge or milestone closeout has occurred; the owner decision and exact check result are recorded in [the ship receipt](phases/07-guard-scope-reconciliation/07-SHIP-STATUS.md).

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 7. Guard Scope Reconciliation | 5/5 | Verification passed; PR #96 blocked on security check | 2026-11-20 |

## Next

The next action is the owner's decision on the new security blocker: amend the verified Phase 7 scope to refresh current-core evidence after moving LiveView to its patched release, or leave PR #96 blocked and defer that change to a separately scoped task. Do not bypass the completed-phase re-entry gate or reopen any consumed request. After the chosen path passes exact-head hosted CI, finish reviewed delivery, milestone audit, and archive closeout. The aggregate remains open and still blocks Walking Skeleton, the Fablebook/Logistify Books, and runnable demos. The authored Fablebook Brand Book is viewable, but it is not an implemented catalog or demo. No guard implementation, candidate promotion, gate change, automatic follow-on, or next milestone is authorized by Phase 7. R10 and R11 remain spent; do not resume either request.
