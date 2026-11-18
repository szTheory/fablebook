# Phase 4: Evidence-only source and gap provenance closure - Context

**Gathered:** 2026-11-16
**Status:** Ready for planning
**Milestone:** v0.4 / guard-recovery

<domain>
## Phase Boundary

Produce a supplemental, lane-pinned evidence package for all 226 identities on core and floor. The package must materialize target-to-source association rows or exact typed-gap rows with identity, MFA, relative source path, byte count, digest, repository ref, lane lock, archive row, citation/review provenance, status, reason, and remedy. It must include keyed provenance for the existing source/caller gaps, trace the derivation of `target_source_coverage_complete`, reconcile it with the nonzero gap counts, and establish the nested SIZING digest selector and encoding.

Run cheap JSON/schema, complete ID-set, cross-file digest, and keyed row/count checks before any long test or suite. If required inputs are absent or the evidence cannot fit inside the inherited limits, record the exact missing identity/provenance keys and consequence, then stop. This phase adds evidence only; it does not complete Phase 3, publish a Phase 3 candidate, alter guard behavior, or close the aggregate gate.
</domain>

<decisions>
## Implementation Decisions

### Evidence coverage and provenance
- **D-01:** Cover the complete 226-ID set independently for core and floor. Aggregate counts and representative examples are not sufficient. Every source association or gap must remain keyed to its identity and lane.
- **D-02:** Keep callback/delegate and graph limitations visible as keyed gaps with exact reason and remedy. Never invoke audited functions or infer safety from missing or unrun observations.
- **D-03:** Trace the caller that computes source coverage and establish the stored nested SIZING digest recipe against the complete records.

### Limits and bounded outcome
- **D-04:** Use the standard 100,000-token ceiling with the fixed 31,000-token reserve. Do not increase the budget. Retain the 34,000-token compact-context ceiling, the five-exact-source-file cap per task, and the no-truncation rule. Allocate source tokens only after exact spans, independent metadata review, execute preflight, and fresh direct count are bound.
- **D-05:** Run cheap consistency checks before long tests or suites. If the selected evidence does not fit or required provenance is unavailable, record the exact gap and stop; do not fabricate rows, select a candidate, or request automatic budget expansion.
- **D-06:** Preserve Phase 3's stop and all safety gates. Phase 4 evidence does not automatically resume or complete Phase 3 and does not authorize implementation or another follow-on.

### the agent's Discretion
- Select the smallest auditable supplemental record format and deterministic digest procedure that the evidence supports.
- Use the existing lane-specific inventory, source-resolution, archive-lock, and test-support patterns. Prefer a separate Phase 4 supplement so earlier Phase 3 records and receipts remain unchanged.
- Decide whether any focused test is necessary after the evidence package passes cheap consistency checks; do not run long lane suites unless the plan establishes that they are required.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Active scope and owner direction
- `.planning/ROADMAP.md` — Phase 3 and Phase 4 goals, requirements, and boundaries.
- `.planning/REQUIREMENTS.md` — GSR-03/GSR-05 acceptance and the complete aggregate limits.
- `.planning/STATE.md` — current Phase 3 stop, limits, and owners.
- `.planning/intent/sources/2026-11-16-01-select-evidence-only-closure.md` — owner selection of a separate evidence-only scope under 100k, with no implementation or budget increase.
- `.planning/intent/sources/2026-11-14-01-cheap-checks-and-bottlenecks.md` — cheap consistency checks before long processes and bounded replanning at bottlenecks.
- `.planning/intent/sources/2026-11-15-02-authorize-phase3-recovery-envelope.md` — Phase 3-only 110k exception; future work retains 100k.

### Current Phase 3 evidence and stop
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-BOUNDED-TRACE-STOP.md` — exact observed evidence gaps, counts, and bounded exit.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-TASK2-GATE-STOP.md` — complete 226-ID set.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-PLAN.md` — existing source, task, review, and output limits.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-REPLAN.md` — trace accounting and stop conditions.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-SIZING.json` — active source ledger and lane evidence counts.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json` and `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json` — current lane records and digests.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md` — reusable lane-specific evidence and source-resolution patterns.

### Safety, verification, and lifecycle
- `docs/adr/0004-no-eval-no-new-atoms.md` — static-only safety boundary.
- `docs/adr/0014-testing-strategy.md` — cheapest meaningful automated evidence and negative controls.
- `docs/adr/0021-delivery-rules.md` — source/file/task limits and phase gates.
- `.planning/VERIFICATION.md` — evidence provenance and honest not-run reporting.
- `.planning/references/PLANNING-LIFECYCLE.md` — canonical planning owners and stage preflights.
- `.planning/references/PLANNING-GATES.json` and `.planning/migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md` — open aggregate gate, pending complement, and existing owners.
- `.planning/references/PHASE-DELIVERIES.json` — actual EX-010 and EX-107 deliveries remain distinct.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Fablebook.Test.InstalledOtp.export_inventory!/2` and `Fablebook.Test.SweepEvidence` are the established read-only lane identity, archive-lock, and source-resolution surfaces described in Phase 3 context.
- Phase 3 already inspected `target_source!/5` and `source_key_index!/2`; its stop receipt describes their exact-match and fail-closed behavior.

### Established Patterns
- Preserve lane-specific machine records, full identity sets, archive digests, and review provenance. Do not treat historical inventory as current evidence.
- Use deterministic keyed records and explicit gap reasons; never equate aggregate counts with identity-level coverage.
- No new source body is authorized by this context. Exact Phase 4 source selection remains subject to a fresh reviewed schedule, preflight, and direct count.

### Integration Points
- Add a separate Phase 4 evidence supplement and link it from the owner-facing Phase 3 handoff only after its evidence passes. Do not rewrite prior Phase 3 lane records or immutable delivery receipts.
</code_context>

<specifics>
## Specific Ideas

The owner asked for cheap consistency checks before any long test or process and for work to replan around the narrow bottleneck. The existing Phase 3 stop identifies the immediate bottleneck: keyed lane-pinned associations/gaps, the coverage-flag caller, and the nested SIZING digest recipe are absent or unresolved.
</specifics>

<deferred>
## Deferred Ideas

Guard implementation, callback execution, dynamic-caller or native-runtime claims, candidate promotion, aggregate closure, Walking Skeleton, SEC-01, and any automatic follow-on remain outside this phase.
</deferred>

---

*Phase: 4-evidence-only-source-and-gap-provenance-closure*
*Context gathered: 2026-11-16*
