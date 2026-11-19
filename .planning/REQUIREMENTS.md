# Requirements: Fablebook

**Milestone:** v0.5 Bounded EX-177 Provenance Follow-through
**Defined:** 2026-11-19
**Core Value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.

## v1 Requirements

### EX-177 provenance supplement

- [x] **GSR-07**: A supplementary machine-readable record binds exactly the four selected EX-177 source/caller keys to the two pinned lane identities, the discovered source path, byte count and SHA-256, the target definition span, and the one observed direct-caller span. It preserves the 9,712-row complement and its recorded digest, states that one observed caller does not prove complete caller closure, and leaves candidate fit and the aggregate gate open. It uses the existing reviewed discovery report and does not repeat source reads or consume R9. (INT-20261119-01, INT-20261119-02, ADR 0021)

## Future Requirements

- Complete direct, dynamic, delegated, callback, or package-wide caller closure only after a separately authorized bounded scope.
- Establish candidate fit and complete aggregate-scoped proof under their existing owners and gates.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Package-wide caller search or claims that all callers are known | Outside the four-row authorization; one direct caller per lane is only an observation. |
| New source request, R9 consumption, OTP/runtime invocation, callback, or generated-code execution | The current owner approval is planning-only and the discovery report leaves R9 unconsumed. |
| Guard implementation, candidate promotion, aggregate closure, or Walking Skeleton activation | Existing safety stops and typed prerequisites remain in force. |
| Editing archived Phase 5 receipts or changing the four-row selection or 9,712-row complement | Historical evidence and scope are preserved. |
| New dependency, product-code change, or recurring CI lane | This is a bounded evidence-record planning scope. |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| GSR-07 | Phase 6 | Complete |

The [Phase 6 roadmap](ROADMAP.md#phase-6-bounded-ex-177-provenance-supplement) owns delivery of GSR-07.

**Coverage:**
- v1 requirements: 1 total
- Mapped to phases: 1
- Unmapped: 0

---
*Requirements defined: 2026-11-19*
*Last updated: 2026-11-19 after v0.5 scope selection*
