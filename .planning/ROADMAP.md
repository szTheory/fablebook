# Roadmap: v0.8 Fixed Logistify Scenario Bundle

**Milestone key:** fixed-book-bundle

## Milestone goal

A developer can generate one deterministic, cited no-browser context bundle for “A failed shipment” in the shipped Logistify operator Book. This milestone exercises the minimum shared render seam and uses the delivered Phase 8 catalog, Canvas and source custody.

## Phases

- [ ] **Phase 9: Generate the fixed Scenario bundle** — Share the Canvas renderer and produce reproducible local artifacts with pinned citations.

## Phase Details

### Phase 9: Generate the fixed Scenario bundle

**Goal:** As a developer, I can hand an owner or coding agent the Scenario’s situation, the content actually rendered and the source behind its facts.

**Mode:** mvp

**Depends on:** Delivered `first-inspectable-book:8` and the owner-reviewed planning checker prerequisite [PR #108](https://github.com/szTheory/fablebook/pull/108).

**Requirements:** BND-01, BND-02, BND-03, BND-04, BND-05

**Success Criteria** (what must be true):

1. The local development/test command selects the fixed compiled Scenario through its existing identity and writes `BUNDLE.md` and `bundle.json`. Unsupported selections fail closed. (BND-01)
2. Both consumers use the same presentational renderer and agree on the Scenario content. The bundle includes its situation, Contract, sanitized markup and citations verified against the pinned source. Browser checks are `not-run`. (BND-02, BND-03)
3. Two clean runs give byte-identical artifacts and a changed Scenario value changes the render digest. A text golden verifies the artifact shape. (BND-04)
4. Synthetic sensitive inputs are excluded and attempted writes outside the approved local destination are rejected. Existing dev/test and clean production checks continue to demonstrate the operator Book’s environment boundary, including the production reachable-mount control. (BND-05)

**Plans:** Defined after Phase 9 discussion.

**Verification:** Run source pin and focused checks first. Verify content parity, determinism, redaction, containment and production exclusion locally and on the required hosted lanes. Use source-cited demo data for local output and keep public artifacts within their approved content boundary. See [verification policy](VERIFICATION.md) and [scoped requirements](REQUIREMENTS.md).

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 9. Generate the fixed Scenario bundle | 0/0 | Ready for discussion | — |

## Completed milestones

- **v0.7 First Inspectable Book** — Phase 8 delivered through PR #106 with green exact-head hosted CI. [Closeout](milestones/v0.7-CLOSEOUT.md) · [archive](milestones/v0.7-ROADMAP.md) · [requirements](milestones/v0.7-REQUIREMENTS.md) · [audit](milestones/v0.7-MILESTONE-AUDIT.md)
- **v0.6 Guard Scope Reconciliation** — closed 2026-11-20 as a bounded evidence milestone; Phase 7 delivered through PR #96 with green exact-head and post-merge CI; archive closeout tracked in [PR #97](https://github.com/szTheory/fablebook/pull/97). [Closeout](milestones/v0.6-CLOSEOUT.md) · [archive](milestones/v0.6-ROADMAP.md)
- **v0.5 Bounded EX-177 Provenance Follow-through** — closed 2026-11-19; wider guard and product gates remain open. [Closeout](milestones/v0.5-CLOSEOUT.md) · [archive](milestones/v0.5-ROADMAP.md)
- **v0.4 Guard Aggregate Reconciliation** — archived 2026-11-19; wider guard aggregate remains open. [Closeout](milestones/v0.4-CLOSEOUT.md) · [archive](milestones/v0.4-ROADMAP.md)
- **v0.3 Bounded ASN.1 RTT Guard Evidence** — archived 2026-11-13. [Closeout](milestones/v0.3-CLOSEOUT.md) · [archive](milestones/v0.3-ROADMAP.md)
- **v0.2 Guard coverage recovery** — archived 2026-11-11. [Closeout](milestones/v0.2-CLOSEOUT.md) · [archive](milestones/v0.2-ROADMAP.md)
- **v0.1 Legacy planning cycle** — superseded and incomplete; not a whole-product ship claim. [Historical archive](milestones/v0.1-ROADMAP.md)
