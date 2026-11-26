# Requirements for v0.8 Fixed Logistify Scenario Bundle

**Defined** 2026-11-26

**Goal** A developer can hand an owner or coding agent one repeatable, cited context bundle for “A failed shipment” in the local Logistify operator Book.

## Milestone requirements

### Scenario and bundle

- [ ] **BND-01**: A developer can run the local no-browser command for the compiled “A failed shipment” Scenario and receive `BUNDLE.md` and `bundle.json` (`fablebook.bundle/1`). Selection uses the existing Book, Story and Scenario identity. The entry point rejects unsupported selections without evaluating input or creating atoms. (INT-20261126-02, INT-20261126-03, ADR 0004, ADR 0008, ADR 0010. Scoped evidence for LLM-01/02/04.)
- [ ] **BND-02**: The bundle contains the situation, the declared component Contract, sanitized Scenario content markup and citations that identify the pinned source repository, revision, relative file and section or pointer. The command distinguishes missing material from present evidence and labels browser checks `not-run`. (INT-20261113-01, INT-20261121-01, INT-20261126-03, ADR 0010. Scoped evidence for LLM-02/04.)
- [ ] **BND-03**: The disconnected bundle render and the hosted Canvas use the same presentational renderer. The Scenario content agrees across both consumers. Existing Canvas navigation and host behavior continue to work. (INT-20261126-03, ADR 0003, ADR 0022. Scoped evidence for CORE-09.)
- [ ] **BND-04**: Two runs from identical source, fixture and configuration inputs produce byte-identical bundle files. A changed Scenario value changes the render digest. A text golden checks the expected artifact shape using approved fixture content. (INT-20261126-03, ADR 0010, ADR 0014.)
- [ ] **BND-05**: Bundle output is confined to the local development/test project and excludes host paths, environment values, credentials and session or CSRF material. The command refuses output outside its approved destination, and production excludes the operator Book and bundle entry point. A clean production build and the existing reachable-mount rejection control continue to pass. (INT-20261126-03, ADR 0004, ADR 0006, ADR 0010, ADR 0027. Scoped redaction and containment evidence under SEC-04.)

## Deferred scope

The wider Story model, render subjects, selectors, Controls and URL overrides, custom redaction hooks, applied canon, browser capture, allocator, broader bundle distribution and adopter dogfood retain their existing roadmap owners. SEC-01 remains Pending with Controls. SEC-04 stays Pending for the full redaction contract. Walking Skeleton remains blocked by the open guard aggregate. The v0.7 exception expired at closeout. The approved boundary is local development/test with the shipped compiled Book and its reviewed citations. There is no release, deployment or change to the guard scope.

## Traceability

| Requirement | Phase | Status |
|---|---|---|
| BND-01 | Phase 9 | Pending |
| BND-02 | Phase 9 | Pending |
| BND-03 | Phase 9 | Pending |
| BND-04 | Phase 9 | Pending |
| BND-05 | Phase 9 | Pending |
