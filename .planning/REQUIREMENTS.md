# Requirements: Fablebook

**Milestone:** v0.7 First Inspectable Book  
**Defined:** 2026-11-20  
**Core Value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.

This milestone is the narrowly approved first-Book exception in [INT-20261120-14](intent/sources/2026-11-20-14-approve-first-book-gate-exception.md). It does not close the guard aggregate or unblock the original `walking-skeleton` key.

## v1 Requirements

### Source grounding

- [ ] **SRC-01**: Before the Book uses Logistify source content, the exact text/token subset is reproducible from public commit-pinned sources and SHA-256 checked; every cited content claim and fixture maps to its repository, tag, commit, file, and section. (INT-20261120-08, INT-20261111-06, INT-20261120-14, INT-20261121-01)

### Mount and production boundary

- [ ] **MOUNT-01**: The public mount macro accepts only literal module alias/reference AST forms and rejects other expressions before expanding them; its contract tests and implementation land in separate PRs. (INT-20261120-14, ADR 0021)
- [ ] **HOST-01**: A production build has no Fablebook route and no compiled Story or Book modules, while development and test can compile the fixed Book. (INT-20261120-14, ADR 0001, ADR 0006)
- [ ] **HOST-02**: A reachable production mount fails compilation with the canonical Fablebook production-mount error; a negative production control proves the rejection. (INT-20261120-14, ADR 0006)

### Catalog and Book

- [ ] **CAT-01**: A developer can start the local host, open the Fablebook UI catalog, select the single operator Book, and move through its two or three addressable screens using minimal navigation. (INT-20261120-08, INT-20261120-09, INT-20261120-14, ADR 0013)
- [ ] **CAT-02**: The operator Book is developer-authored and compiled from Fablebook Story/Scenario modules, appears in the catalog in development and test, and does not load stories dynamically or evaluate runtime input. (INT-20261120-09, INT-20261120-14, ADR 0001, ADR 0008)
- [ ] **CANVAS-01**: Each Book screen renders through the real host Canvas path in a same-origin iframe, inheriting the host pipeline and root layout with its CSS, JavaScript, hooks, fonts and CSP. (INT-20261120-08, INT-20261120-14, ADR 0003)
- [ ] **BOOK-01**: The Book presents one source-supported dispatcher job with a normal state and a meaningful source-supported edge or error state, deterministic fixed cited data, and visibly illustrative records and actions; it creates no persistent state or external writes. (INT-20261120-08, INT-20261120-09, INT-20261120-14, ADR 0002)

## Future Requirements

- Complete the operator, shipper and driver Books under a shared applied brand canon.
- Add general Stories/Scenarios catalog discovery, broad Journey tooling, Controls, URL state, bundles and the complete workbench.
- Run adopter dogfood and clearance work separately from this fictional Book.

## Out of Scope

| Feature | Reason |
|---------|--------|
| Full logistics application, backend, database, authentication or shipment persistence | This milestone demonstrates an inspectable Book; its records and actions are fixed and illustrative. (INT-20261120-08, INT-20261120-14) |
| Other Books, full Logistify sourcebook application, applied brand canon, unreviewed artwork, sound or fonts, marketing/clearance claims, product publication, deployment or release | Public citations and the minimal cited source-derived content in a reviewed PR are permitted; the demo remains one fixed dev/test Book and is not deployed. The name is not cleared, and unreviewed asset rights remain open. (INT-20261120-08, INT-20261120-14, INT-20261121-01) |
| Controls, user-provided values or code, arbitrary runtime story loading, audited-API use, or input-selected modules/atoms/topics | The exception is limited to one fixed developer-authored compiled Book in development/test. (INT-20261120-09, INT-20261120-14, ADR 0004) |
| Persistence, external writes, release, or follow-on milestone work | Explicitly excluded by the one-milestone exception, which expires at v0.7 closeout. (INT-20261120-14) |
| New runtime dependency or required Node setup | Existing Elixir/Phoenix and optional tooling are sufficient for this bounded result. (INT-20261120-13, ADR 0018) |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SRC-01 | Phase 8 | Pending |
| MOUNT-01 | Phase 8 | Pending |
| HOST-01 | Phase 8 | Pending |
| HOST-02 | Phase 8 | Pending |
| CAT-01 | Phase 8 | Pending |
| CAT-02 | Phase 8 | Pending |
| CANVAS-01 | Phase 8 | Pending |
| BOOK-01 | Phase 8 | Pending |

**Coverage:**
- v1 requirements: 8 total
- Mapped to phases: 8
- Unmapped: 0

---
*Requirements defined: 2026-11-20*
*Last updated: 2026-11-20 after Phase 8 mapping*
