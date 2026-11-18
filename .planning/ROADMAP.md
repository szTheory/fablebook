# Roadmap: v0.4 Guard Aggregate Reconciliation — Fablebook

## Milestones

- 🔄 **v0.4 Guard Aggregate Reconciliation** — active; Phase 3 owns the current full-scope rejoin and next-scope sizing.
- ✅ **v0.3 Bounded ASN.1 RTT Guard Evidence** — Phase 2 shipped 2026-11-13; [full roadmap and phase details](milestones/v0.3-ROADMAP.md).
- ✅ **v0.2 Guard coverage recovery** — Phase 1 shipped 2026-11-11; [full roadmap and phase details](milestones/v0.2-ROADMAP.md).
- ⚠️ **v0.1 Legacy planning cycle** — superseded and incomplete; [historical roadmap](milestones/v0.1-ROADMAP.md).

## Phases

- [ ] **Phase 3: Guard aggregate scope rejoin and candidate sizing** — Reconcile the complete current two-lane scope and size a bounded next decision.
- [ ] **Phase 4: Evidence-only source and gap provenance closure** — Complete the lane-pinned source and typed-gap provenance needed to explain Phase 3's coverage and digest gaps.

**Milestone key:** guard-recovery

### Phase 3: Guard aggregate scope rejoin and candidate sizing

**Goal:** The owner can inspect the complete current row-to-MFA join on core and floor, lane-specific source identities and caller/delegate paths, exact pending complements, and measured sizing for a possible bounded guard increment. If the evidence or fit is insufficient, the phase reports the exact gap and selects no implementation slice.

**Depends on:** Delivered v0.2 Phase 1 and v0.3 Phase 2 receipts are reusable only within their proven scopes. This phase continues global numbering at 3 and does not reopen delivered work.

**Requirements:** GSR-01, GSR-02, GSR-03, GSR-04, GSR-05, GSR-06.

**Success criteria:**
1. The read-only inventory records both pinned lane identities and provenance, with the complete current target inventory needed by the original exclusion set.
2. Every original exclusion identity maps to its current owner and exact live per-lane MFA set, with additions, missing members, delivered rows, and pending complements inspectable.
3. Each surviving row's target set links to exact per-lane sources and relevant caller/delegate paths, or lists the specific missing evidence.
4. Historical EX-010 and EX-107 partitions and the actual merged delivery receipts remain distinct and traceable; no bounded slice is represented as aggregate closure.
5. Current source-file, context-token, and effort sizing either yields a candidate within inherited limits or names the concrete fit gap and leaves the next owner decision explicit.

**Boundaries:** Static evidence only. No audited API, callback, atom-sink, or generated-code invocation. Preserve the actual-library collision stop, SEC-01 Pending status, the open guard gate, and the Walking Skeleton block. Product UI and brand work remain outside this milestone.

<details>
<summary>✅ v0.3 Bounded ASN.1 RTT Guard Evidence (Phase 2) — SHIPPED 2026-11-13</summary>

- [x] Phase 2: Bounded ASN.1 RTT guard evidence (5/5 plans) — completed 2026-11-13.

</details>

<details>
<summary>✅ v0.2 Guard coverage recovery (Phase 1) — SHIPPED 2026-11-11</summary>

- [x] Phase 1: Bounded guard continuation — completed 2026-11-11.

</details>

### Phase 4: Evidence-only source and gap provenance closure

**Goal:** For all 226 identities on core and floor, produce complete lane-pinned target-source association and typed-gap rows; trace the caller that derives source-coverage status; and establish the nested SIZING digest recipe. If inputs are missing or evidence cannot fit within inherited limits, report exact identity/provenance gaps and leave candidate null.
**Requirements:** GSR-03, GSR-05
**Depends on:** Phase 3's recorded bounded trace stop; Phase 4 supplies evidence only and does not close Phase 3 or authorize a guard implementation.
**Boundaries:** Static evidence only. No audited OTP APIs, callbacks, atom sinks, runtime evaluation, generated-code paths, guard behavior changes, candidate promotion, aggregate closure, or automatic follow-on. Preserve the collision and Macro stops, SEC-01 Pending status, and Walking Skeleton block.
**Plans:** 0 plans

Plans:
- [ ] To be planned with the standard 100,000-token ceiling and fixed 31,000-token reserve.
