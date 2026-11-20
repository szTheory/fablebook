# Requirements: Fablebook

**Milestone:** v0.6 Guard Scope Reconciliation  
**Defined:** 2026-11-19  
**Core Value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.

## v1 Requirements

### Guard-scope reconciliation

- [x] **RSC-01**: The reconciliation records the complete relevant surviving guard row/function membership and exact source identities independently for both pinned lanes, identifies differences from prior saved inventories, and stops for rescoping if source or membership inputs do not match. (INT-20261119-05, INT-20261111-13, ADR 0021)
- [x] **RSC-02**: The reconciliation names one exact proposed scope family and records its complete, disjoint complement against the current per-lane membership, with reproducible counts/digests and explicit distinction between a proposed scope and a selected/promoted code candidate. (INT-20261119-05, INT-20261119-01, ADR 0021)
- [x] **RSC-03**: For the proposed family, the evidence records bounded source, caller, and delegate observations with lane identity, provenance, known gaps, and limits; it does not claim exhaustive or package-wide caller closure from bounded/static observations. (INT-20261119-05, INT-20261119-01, ADR 0004, ADR 0021)
- [x] **RSC-04**: The phase refreshes source/context/effort sizing under inherited per-task and per-phase limits, confirms that the evidence is bounded or identifies the reason to stop, preserves every inherited safety stop, and ends with a recommendation plus an explicit owner decision before any further increment. (INT-20261119-05, INT-20261119-06, ADR 0021)

## Future Requirements

- Establish candidate fit or promote a candidate only after its complete evidence and named owner decision.
- Close the guard aggregate, including installed-wide acceptance, before the Walking Skeleton.
- Build the Fablebook UI catalog, applied brand canons, Fablebook and Logistify Books/scenarios, and runnable branded demos in the existing typed product order.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Runtime probes, audited API calls, or generated-code execution | This milestone is a read-only source/evidence reconciliation; inherited runtime stops remain binding. |
| Consuming R9 or launching package-wide caller searches | No authorization exists for either; caller coverage remains bounded and explicitly incomplete where applicable. |
| Candidate fit decision, candidate promotion, guard implementation, or aggregate closure | These are separate safety decisions and are not implied by a proposed scope family. |
| Walking Skeleton, product UI, canon application, new Books/scenarios, or brand asset integration | The open aggregate blocks product implementation; this milestone only informs an owner decision. |
| New dependency or recurring CI lane | Existing source and standard-library evidence tools are sufficient for this planning/evidence result. |
| Automatic follow-on guard increment | The phase must stop at the owner decision; automatic follow-up remains disabled. |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| RSC-01 | Phase 7 | Complete |
| RSC-02 | Phase 7 | Complete |
| RSC-03 | Phase 7 | Complete |
| RSC-04 | Phase 7 | Complete |

**Coverage:**
- v1 requirements: 4 total
- Mapped to phases: 4
- Unmapped: 0

---
*Requirements defined: 2026-11-19*
*Last updated: 2026-11-20 after Phase 7 verification; hosted delivery remains pending.*
