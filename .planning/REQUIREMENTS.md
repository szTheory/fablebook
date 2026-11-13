# Requirements: v0.3 Bounded ASN.1 RTT Guard Evidence

**Defined:** 2026-11-12  
**Milestone goal:** Establish source-backed dispositions for three pending EX-107 RTT functions on both pinned lanes while preserving the original row and every wider safety gate.  
**Core value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, is visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.

## v0.3 Requirements

### Bounded guard evidence

- [ ] **GRC-04**: Before executable phase planning, the reviewed context revalidates the complete current EX-107 match set independently on core and floor, confirms the approved selection (`asn1ct_rtt:assert_defined/1`, `code/0`, and `dependencies/1`) and exact remaining complement against the archived evidence, and records the lane-specific source identities. Any membership or identity mismatch stops the slice for rescoping; counts alone do not establish membership. Existing source, context, task, plan, and effort bounds remain in force. (INT-20261111-13, INT-20261111-01, INT-20261110-01, ADR 0021)

- [ ] **GRC-05**: For each selected function on each lane, the evidence records exact source spans, its direct caller path, and a source-backed disposition. Each function has individually non-vacuous positive and negative controls. The large literal table in `code/0` is checked by the bounded byte-only procedure outside the prompt; audited APIs are never invoked, and runtime behavior, dynamic callers, and native internals remain unproven. (INT-20261111-13, INT-20261110-01, ADR 0004, ADR 0021)

- [ ] **GRC-06**: The selected slice is delivered through the existing reviewed-candidate, exact-head, and required CI gates. Preserve EX-107's complete identity, selected/remainder partition, inherited limits, and every existing safety stop. Completion applies only to this slice: it does not close the full EX-107 row or guard aggregate, unblock Walking Skeleton, resolve SEC-01, or authorize automatic follow-up work. (INT-20261111-13, INT-20261111-01, INT-20261110-01, ADR 0021)

## Future Requirements

No additional future requirement is promoted into v0.3. The full EX-107 row, installed-wide remainder, guard aggregate, Walking Skeleton prerequisites, SEC-01, acknowledged unresolved deferrals, and product commitments retain their existing owners and status in the [product requirements](references/PRODUCT-REQUIREMENTS.md), [planning gates](references/PLANNING-GATES.json), and [carry-forward register](migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md).

## Out of Scope

| Item | Reason |
|---|---|
| Invoking the audited functions or claiming runtime safety | This milestone establishes static source and caller evidence only; ADR 0004 remains in force. |
| Closing EX-107 as a whole, the guard aggregate, or the installed-wide remainder | Only the approved three-function slice is in scope; the complete row and pending complement remain visible. |
| Unblocking Walking Skeleton or resolving SEC-01 | Their separate aggregate and Controls / first-bundle owners remain unchanged. |
| Selecting or automatically starting another guard increment | Each bounded milestone requires a fresh owner decision. |
| Implementing Fablebook or Logistify brand canon, catalogs, screens, or demo flows | These are later product-roadmap work with separate prerequisites and milestone approval. |

## Traceability

| Requirement | Phase | Status |
|---|---|---|
| GRC-04 | Phase 2 | Pending (independent membership evidence exists; full core/floor validation failed in Plan 02-05) |
| GRC-05 | Phase 2 | Pending (focused review is complete; full core/floor validation failed in Plan 02-05) |
| GRC-06 | Phase 2 | Pending (local readiness is blocked by full-suite failures; final-head hosted delivery remains pending) |

**Coverage:**
- v0.3 requirements: 3 total
- Mapped to phases: 3
- Unmapped: 0

---
*Requirements approved: 2026-11-12*  
*Last updated: 2026-11-12 after roadmap approval, traceability mapping and phase-number correction.*
