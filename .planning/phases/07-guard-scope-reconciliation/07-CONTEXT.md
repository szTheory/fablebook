# Phase 7: Guard Scope Reconciliation - Context

**Gathered:** 2026-11-19  
**Status:** Ready for planning

<domain>
## Phase Boundary

Reconcile the current complete relevant guard membership and pinned source identities across both lanes; define one exact proposed evidence-scope family and its full complement; record bounded source/caller/delegate observations and explicit gaps; refresh source/context/effort sizing; and present a recommendation for the owner's next decision.

This is a read-only evidence phase. A proposed evidence family is not a code candidate and does not establish candidate fit. Do not invoke audited runtime APIs or generated code, consume R9, perform package-wide caller searches, claim exhaustive caller closure, implement guards, promote a candidate, close the aggregate, begin the Walking Skeleton, build product UI/Books, or apply brand sources. Stop for rescoping if pinned source identity or exact membership does not reconcile. At phase exit the owner decides whether to authorize any next guard increment; automatic follow-up stays disabled.

</domain>

<decisions>
## Implementation Decisions

### Membership and lane identity
- Recompute current membership independently for each pinned lane and bind each result to the exact lane/source identity; counts alone do not establish matching inputs.
- Compare the complete relevant surviving row/function set to its saved inventory, report exact differences, and stop on identity or membership drift rather than combining generations.
- Preserve the prior EX-177 four-key and 9,712-row figures as historical evidence only; do not assume they are the current family or complement.

### Proposed family, complement, and claim boundaries
- Name one exact proposed evidence-scope family, clearly distinguish it from a selected/promoted code candidate, and prove the per-lane complement is complete and disjoint with reproducible counts/digests.
- Record only the bounded caller and delegate paths supported by the approved source inspection. Mark dynamic, external, callback, and otherwise unresolved paths as gaps; do not make package-wide or exhaustive caller-absence claims.
- Keep actual-library collision unresolved and retain the owner stop. Candidate remains null; implementation remains unauthorized; the aggregate gate remains open.

### Sizing, checks, and exit
- Refresh source, context, and effort estimates before execution; retain all recorded per-task/per-plan/per-phase limits and do not impose a new assistant-side cumulative token ceiling.
- Prefer a small standard-library-only checker or existing repository tooling; add no dependency or recurring CI job for one evidence reconciliation.
- Run cheap lane-identity, membership, schema, count, and digest checks before any longer review. Stop at the first unexplained mismatch.
- Deliver a reviewable machine-readable reconciliation with a concise human explanation, explicit unknowns, and one recommendation. Stop at the owner decision; do not choose a follow-on increment automatically.

### the agent's Discretion
- Choose the minimal record/checker shape consistent with existing phase evidence, with fields that preserve per-lane provenance, exact membership, complements, gaps, sizing, and open-stop state.
- Choose focused positive and negative controls that prove the new evidence contract without rerunning historical suites or reading outside the authorized source set.
- If a decision would expand source access, change a protected gate, accept candidate fit, or change the next-scope authority, stop and bring the exact decision to the owner.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Owner selection, scope, and milestone gates
- `.planning/intent/sources/2026-11-19-05-select-v06-guard-reconciliation.md` — selected v0.6 / Phase 7 and its evidence-only scope and stops.
- `.planning/intent/sources/2026-11-19-06-research-first-rolling-roadmap.md` — research-first fan-out and rolling-roadmap preference.
- `.planning/research/2026-11-19-v0.6-guard-scope-reconciliation.md` — fan-out synthesis and product-state facts.
- `.planning/REQUIREMENTS.md` and `.planning/ROADMAP.md` — active acceptance and Phase 7 exit criteria.
- `.planning/references/PLANNING-GATES.json` — aggregate open; automatic follow-up disabled.
- `.planning/migrations/2026-11-11-milestone-reset/PHASE-MAP.json` and `CARRY-FORWARD.md` — typed product prerequisites and inherited scope limits.

### Prior lane evidence and checker patterns
- `.planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/` — most recent complete lane membership and identity reconciliation; compare its exact schema and input provenance.
- `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/` — preserved row associations, typed gaps, provenance manifest, and validation receipts.
- `.planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/` — selected EX-177 evidence and full complement; R9 controls are saved data only and must not be consumed.
- `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json` and `06-validate-supplement.py` — recent exact-key/complement/stop-state checker pattern, not a current membership baseline.
- `.planning/references/PRODUCT-ROADMAP.md` — current guard boundary and rolling product/demo sequence.

### Technical and safety references
- [OTP xref documentation](https://www.erlang.org/doc/apps/tools/xref.html) — limits on dynamic caller analysis and module data completeness.
- [Mix dependency documentation](https://mix.hexdocs.pm/1.18.1/Mix.Tasks.Deps.html) — lane-specific pinned dependency identity.
- `docs/adr/0004-no-eval-no-new-atoms.md`, `docs/adr/0021-delivery-rules.md`, and `.planning/VERIFICATION.md` — no-eval boundary, delivery limits, and cheapest useful verification.
</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- Phase 3/4 evidence and validation records contain lane-specific memberships, source identities, typed gaps, and saved checksums to reconcile. Treat these as inputs to compare, not proof that current inputs are unchanged.
- Phase 5/6 Python standard-library validators demonstrate exact key, lane binding, raw-row digest, and preserved-stop checks; their old four-key scope must not be reused as the current selection.

### Established Patterns
- Keep each lane independently identified; prove exact set equality/complement, not count-only similarity.
- Store source paths as evidence values and maintain an explicit source-read allowlist. Bounded static observations do not prove dynamic/external caller closure.
- Reuse immutable receipts when hashes match; stop with exact expected/observed facts when they do not.

### Integration Points
- This phase produces planning evidence and a local checker only. It does not change the Fablebook library, host app, brand assets, product requirements, aggregate gate, or archived receipts.
- The open guard-aggregate gate blocks the Walking Skeleton; the milestone roadmap preserves the existing route to a runnable product and branded demo Books.
</code_context>

<specifics>
## Specific Ideas

Keep the exact selected-family definition and every row of its complement reproducible. Make the difference between “we observed these paths” and “all callers are known” impossible to miss. Treat Phase 7 as the evidence needed for one informed owner decision, not as a way to ratchet into another automatic audit phase.
</specifics>

<deferred>
## Deferred Ideas

- Any next guard increment after this reconciliation; present a recommendation and wait for the owner decision.
- Guard implementation, runtime use, candidate promotion/fit, aggregate closure, and Walking Skeleton work.
- Applied Fablebook/Logistify canon, demo Books and scenarios, a live browser UI, brand asset integration, and dogfood; these remain in the product roadmap behind the typed guard and product prerequisites.
</deferred>

---

*Phase: 07-guard-scope-reconciliation*  
*Context gathered: 2026-11-19*

## Owner-approved security rebaseline (2026-11-20)

Source: [INT-20261120-07](../../intent/sources/2026-11-20-07-authorize-phase7-security-rebaseline.md). This additive decision reopens Phase 7 only to resolve the required hosted security failure before delivery. The prior context, plans, observations, and verification remain preserved as evidence for the original LiveView 1.2.13 lock; they are not silently relabeled as current after a lock change.

### Included

- Update only the existing core `phoenix_live_view` package from 1.2.13 to patched 1.2.14. The declared `mix.exs` constraint already admits 1.2.14; do not widen constraints or update unrelated dependencies.
- Produce a separate, versioned current-core compiled-export inventory bound to the resulting full `mix.lock` digest and unchanged pinned OTP/Elixir runtime. Compare every saved core row, preserve the 226-row family/complement contract, and stop for owner rescoping if the family or membership changes.
- Independently review the regenerated exact core source schedule before any new target source body is opened. Use fresh request identifiers only; all existing core/floor request IDs and markers stay immutable, and every prior no-retry gap stays closed. Keep the existing per-task file cap and one-use controls.
- Keep the accepted floor lane, `mix.floor.lock`, ENV06 generation, saved floor membership and floor source observations byte-for-byte unchanged. Treat them only as the historical comparison lane; do not refresh or claim the floor is current production security evidence.
- Preserve all existing inherited limits and stops: no runtime/API evaluation, no R9, no package-wide caller search, no candidate fit/promotion, no guard implementation, no aggregate closure, no Walking Skeleton, no product UI/Book/demo, and no automatic next increment.

### Required exit

The patched core lock passes the required audit; the new compiled-export inventory and reviewed current-core schedule bind to it; unchanged saved membership and the proposed family/complements validate, or a concrete mismatch stops for rescoping; the bounded observations and gaps remain explicit; independent code/evidence review and fresh phase verification pass; and exact-head hosted CI is green before PR #96 is merged and v0.6 is closed. Preserve the prior verification and failed hosted receipt as history. Keep five plans maximum for this phase by revising the existing final plan slot; do not add a sixth plan.
