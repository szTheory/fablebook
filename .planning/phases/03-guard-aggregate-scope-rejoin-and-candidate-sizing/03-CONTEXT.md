# Phase 3: Guard aggregate scope rejoin and candidate sizing - Context

**Gathered:** 2026-11-13
**Status:** Ready for planning
**Milestone:** v0.4 / guard-recovery

<domain>
## Phase Boundary

Produce a repeatable, read-only rejoin of the complete surviving original guard exclusion scope against the current pinned core and floor lanes. The evidence must show lane identity and inventory provenance; map every original exclusion identity to its current owner and exact per-lane MFA membership; make additions, missing members, delivered work, and pending complements inspectable; and link surviving targets to lane-specific sources and relevant caller/delegate paths. Preserve the distinct historical partitions and the actual v0.2 EX-010 and v0.3 EX-107 delivery receipts.

Size one possible bounded next increment against exact source files, task-context tokens, plan structure, and effort. Recommend a candidate only if the full evidence and all inherited fit limits support it. Otherwise, report the exact gap and select no candidate.

This phase is static evidence only. It does not invoke audited OTP functions, callbacks, atom sinks, or generated-code paths; make runtime-safety claims; add guard dispositions; close the aggregate gate; complete SEC-01; or unblock the Walking Skeleton. Preserve the manual actual-library-collision stop and all existing caller-AST and wording checkpoints. Product UI, brand work, and dogfood implementation are outside this phase.
</domain>

<decisions>
## Implementation Decisions

### Evidence package and review
- **D-01:** Use lane-specific machine-readable inventory and provenance records as the evidence source of truth, with a concise human-readable row-level crosswalk that links to those records and exact sources. Keep the full per-lane membership, additions, missing members, delivered scope, and pending complement inspectable; counts alone are not proof. Generate or link the summary to the records rather than maintaining duplicate facts by hand.
- **D-02:** Reuse the existing inventory and source-resolution helpers where they provide the required current evidence. Add only a narrowly scoped collector if a required receipt cannot otherwise be produced. Do not add a dependency or a general-purpose audit framework. Treat prior inventories as historical inputs, not as a substitute for a fresh current-lane inventory.

### Candidate-sizing decision point
- **D-03:** Present one evidence-backed recommendation for a later bounded increment when the complete join and measured source/context/effort fit support it. Include the exact remaining complement and sizing basis. If evidence is missing or the candidate exceeds any inherited limit, select no candidate and state the concrete gap and bounded remedy.
- **D-04:** End at an explicit owner decision point. A Phase 3 recommendation is not approval to implement, add dispositions, open another phase automatically, or claim aggregate closure. The owner decides separately whether to authorize any later guard increment after reviewing the rejoin and sizing.

### the agent's Discretion
- Choose the precise record schema, filenames, and crosswalk layout; use the existing test/support patterns and keep the output easy to audit.
- Choose the smallest implementation boundary for a collector and the task/plan grouping, provided all source and evidence remains complete and the inherited limits are met. Fail closed on identity, provenance, caller, membership, or fit gaps.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Active scope, requirements, and owner direction
- `.planning/ROADMAP.md` — Phase 3 goal, success criteria, boundaries, and stop condition.
- `.planning/REQUIREMENTS.md` — GSR-01 through GSR-06 and exact acceptance requirements.
- `.planning/PROJECT.md` — active v0.4 scope and inherited project constraints.
- `.planning/STATE.md` — current phase, delivery history, open gates, and continuity.
- `.planning/intent/sources/2026-11-13-02-select-guard-aggregate-reconciliation.md` — owner-selected full-scope rejoin and the reason Phase 3 does not repeat EX-010 or EX-107.
- `.planning/intent/sources/2026-11-13-01-ai-assisted-ui-quality-and-dogfood.md` — recommendation-first continuity; product UI and dogfood remain outside v0.4.
- `.planning/intent/sources/2026-11-11-13-approve-rtt-guard-slice-and-brand-dogfood-roadmap.md` — approved EX-107 slice and the wider requirements it left open.
- `.planning/intent/sources/2026-11-10-01-rolling-allocation-for-bounded-work.md` — inherited source, task, context, plan, and effort limits.
- `.planning/intent/sources/2026-11-12-04-continue-global-phase-numbering.md` — global integer phase sequence and preserved historical IDs.

### Delivery history and retained obligations
- `.planning/references/PHASE-DELIVERIES.json` — actual merged v0.2 Phase 1 and v0.3 Phase 2 receipts.
- `.planning/references/PLANNING-GATES.json` — guard aggregate and SEC-01 ownership/status.
- `.planning/references/PLANNING-LIFECYCLE.md` — canonical planning owners, preflights, and delivery transitions.
- `.planning/migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md` — unfinished guard and product obligations with existing owners.
- `.planning/milestones/v0.2-CLOSEOUT.md` — bounded EX-010 delivery and its retained limits.
- `.planning/milestones/v0.3-CLOSEOUT.md` — bounded EX-107 delivery and its retained limits.

### Original membership, prior partitions, and sizing precedent
- `.planning/migrations/2026-11-11-milestone-reset/ARCHIVE-MANIFEST.json` — immutable archive hashes and byte counts.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.json` — original row identities and archived lane matches.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-CURRENT-SIZING-CORE.jsonl.gz` — historical core lane match inventory.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-CURRENT-SIZING-FLOOR.jsonl.gz` — historical floor lane match inventory.
- `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-CONTEXT.md` — inherited EX-010 evidence, collision, and ownership boundaries.
- `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md` — isolated context-sizing method and fit-gap stop.
- `.planning/milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-CONTEXT.md` — exact EX-107 membership, its distinct 3/174 and historical 13/164/161 partitions, and phase stop.
- `.planning/milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-RESEARCH.md` — current-lane inventory precedent, source/caller evidence, and measured context/effort examples.
- `test/fixtures/guards/exact_sources.tar.gz` — hash-locked lane-specific OTP source archive.

### Existing evidence and safety patterns
- `test/support/installed_otp.ex` — installed lane inventory, BEAM module identity checks, export inventory, and Xref support.
- `test/support/sweep_evidence.ex` — lane identity, archive lock, safe source resolution, and source digest checks.
- `test/support/asn1_rtt_core_evidence.ex` and `test/support/asn1_rtt_floor_evidence.ex` — lane-specific structured source/caller evidence patterns.
- `test/contract/asn1_rtt_integration_test.exs` — exact set equality, disjointness, union, and separate historical partition assertions.
- `test/contract/tier_sweep_test.exs` — original EX-107 full-row and historical membership assertions.
- `docs/adr/0004-no-eval-no-new-atoms.md` — static-only safety boundary and prohibited execution/atom paths.
- `docs/adr/0014-testing-strategy.md` — cheapest meaningful automated evidence and control expectations.
- `docs/adr/0021-delivery-rules.md` — task/source caps, phase effort bound, review cap, and merged-green delivery rule.
- `.planning/VERIFICATION.md` — evidence provenance, automated checks, and honest not-run reporting.

No UI or brand references apply: product UI and brand work are explicitly outside Phase 3, and this checkout has no `prompts/` directory.
</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Fablebook.Test.InstalledOtp.export_inventory!/2` reads installed BEAM exports, checks module identity, rejects duplicate entries, and fails on unreadable inventory. It can support a fresh read-only export inventory for each pinned lane.
- `Fablebook.Test.SweepEvidence` validates the source archive and citations, resolves to installed or archived bytes, and verifies the lane-specific SHA-256 before returning source evidence.
- `test/contract/asn1_rtt_integration_test.exs` demonstrates exact membership checks using equality, disjointness, union, and explicit complements instead of counts alone.

### Established Patterns
- Core and floor inventories and evidence remain lane-specific. Prior JSONL inventories and source records are useful for locating history but do not establish current membership or provenance.
- The EX-107 contract keeps the full-row 3/174 partition separate from the historical 13/164/161 partition. Preserve each original identity and receipt; never sum or substitute their counts.
- Source/Xref evidence does not prove dynamic-caller absence or runtime safety. Report those limits and missing links explicitly.
- Planning records exact source files, rereads, context estimates, bounded output, and an itemized effort reserve. Recalculate for this wider phase; prior estimates do not certify its fit.

### Integration Points
- The current evidence is implemented in the existing `test/support/` and `test/contract/` surface. A narrow collector may be needed for the current full-row join; keep it read-only and fail closed.
- Do not change production guard behavior or add a new CI lane for this reconciliation. Preserve existing contract-test separation and phase delivery gates.
</code_context>

<specifics>
## Specific Ideas

The owner requested broad, evidence-grounded consideration and a coherent recommendation-first result, and directed that recommendations be followed to reduce decision overhead. That discretion applies to presentation and evidence organization only; the approved scope, static-only boundary, open aggregate gate, and later owner decision remain unchanged. The phase is an engineering evidence task, so UI/UX and brand-design lenses do not apply.
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within the approved Phase 3 scope. Product UI, brand canon, dogfood apps, SEC-01 work, and any later guard implementation remain outside this phase under their existing owners.
</deferred>

---

*Phase: 3-guard-aggregate-scope-rejoin-and-candidate-sizing*
*Context gathered: 2026-11-13*
