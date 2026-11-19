# Phase 6: Bounded EX-177 provenance supplement - Context

**Gathered:** 2026-11-19
**Status:** Ready for planning

<domain>
## Phase Boundary

Create a supplementary machine-readable record for exactly the four existing EX-177 source/caller keys on the core and floor lanes. Bind each lane to the previously reviewed runtime and Phoenix package identity, source path, byte count, SHA-256, complete target definition span, and one observed direct-caller span. Preserve the exact 9,712-row pending complement and its recorded digest. Make clear that one observed caller does not establish exhaustive caller closure.

Use only the reviewed EX-177 discovery report and archived Phase 5 receipts. This phase is planning-only until separately authorized for execution. Do not reread Phoenix source bodies, consume R9, search package-wide for callers, invoke audited runtime paths, implement product or guard behavior, promote a candidate, close the aggregate gate, or trigger automatic follow-up. Keep the archived Phase 5 evidence and all existing safety stops unchanged.

</domain>

<decisions>
## Implementation Decisions

### Evidence scope and claims
- **D-01:** Preserve the existing four-key selection: one `source` and one `caller` row for `Elixir.Mix.Tasks.Phx.Gen.Context.prompt_for_code_injection/1` on each of `core` and `floor`. Do not add, remove, or substitute rows.
- **D-02:** Reuse the separately reviewed discovery report and archived Phase 5 scope/result as the only source observations. These records identify Phoenix 1.8.16 on core and 1.8.9 on floor; both target files are 14,760 bytes with SHA-256 `c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e`; the helper definition is lines 445–451 and the observed `run/1` call is line 131 within lines 112–136.
- **D-03:** Bind and preserve the exact 9,712-row pending complement with SHA-256 `dd95380d2114a10a54ddbb79cc6ec5aab4805a52847dcacb4e2ca3daeda653b5`. A single observed direct caller per lane is not an exhaustive caller-closure claim.
- **D-04:** Preserve candidate fit unresolved and candidate null; keep the guard aggregate gate open, R9 denied and unconsumed, Walking Skeleton blocked, SEC-01 pending, actual library collision unknown, and the Macro caller-AST, Macro explanation, and legacy digest questions open.
- **D-05:** If the saved discovery and archived evidence disagree or omit a required fact, record the precise mismatch and stop. Do not read target source, broaden the search, or generate a replacement request to fill the gap.

### Verification and implementation latitude
- **D-06:** Use the cheapest local consistency check that proves exact key membership, lane and source/caller bindings, complement count and digest, and preservation of the open gates. Run deterministic format/schema/hash checks before any longer check; stop at the first mismatch.
- **D-07:** Prefer existing project conventions and a small standard-library-only checker. No new dependency, recurring CI job, or source-dependent suite is needed for this evidence-only supplement.
- **D-08:** Keep archived Phase 5 receipts immutable. Do not rerun Phase 5 suites or the historical validator wholesale when their inputs are no longer the same; rely on the saved receipts and validate only the new supplement and its bindings.

### the agent's Discretion
- Choose the supplementary record's exact filename and a minimal schema consistent with nearby machine-readable evidence.
- Choose a small standard-library implementation and focused negative cases for the local check, provided they do not read Phoenix sources, invoke runtime behavior, consume R9, or claim broader closure.
- Skip broad suites and CI if they cannot add evidence to this static, record-only deliverable; report what was checked and what was intentionally not run.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Owner authorization and current scope
- `.planning/intent/sources/2026-11-19-01-authorize-bounded-source-discovery.md` — permits the bounded static discovery for the four existing EX-177 keys; does not authorize runtime behavior, implementation, aggregate closure, or automatic follow-up.
- `.planning/intent/sources/2026-11-19-02-v04-closeout-and-continuation.md` — records v0.4 closeout choices, carries the four audit items as debt, and authorizes planning-only continuation under the bounded scope.
- `.planning/ROADMAP.md` — active v0.5 Phase 6 goal, acceptance criteria, exact saved lane facts, and boundaries.
- `.planning/REQUIREMENTS.md` — GSR-07 and its explicit out-of-scope rules.

### Saved evidence and prior scope
- `.planning/research/2026-11-19-ex177-source-discovery.md` — reviewed source identity and observed spans; explicitly says the call observation is not exhaustive caller closure.
- `.planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-CONTEXT.md` — original four-row scope, complement, evidence constraints, and preserved stops.
- `.planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-01-PLAN.md` — delivered Phase 5 work and evidence controls.
- `.planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-R9-RESULT.json` — archived Phase 5 result and immutable evidence receipt; consult as saved data only, without rerunning or consuming R9.
- `.planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-VERIFICATION.md` — historical Phase 5 verification and its limits.
- `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-TYPED-GAPS-ENV06.jsonl` — source rows for the four selected keys and their pending complement.
- `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-PROVENANCE-MANIFEST.json` — lane identity and evidence-generation bindings.
- `.planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-validate-artifacts.py` — existing standard-library artifact-check patterns; do not treat the archived validator as current proof without checking its inputs.

### Safety and verification policy
- `.planning/references/PLANNING-GATES.json` — guard aggregate remains open and automatic follow-up is disabled.
- `.planning/VERIFICATION.md` — automate useful checks, start with the cheapest evidence, reuse only receipts whose guarded inputs are unchanged, and avoid unnecessary CI.
- `docs/adr/0004-no-eval-no-new-atoms.md` — prohibits runtime evaluation and input-derived atoms.
- `docs/adr/0014-testing-strategy.md` — choose the cheapest boundary that proves the contract.
- `docs/adr/0021-delivery-rules.md` — phase size, review, delivery, and safety-gate rules.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- The reviewed discovery report and archived Phase 5 records already contain all source identity and span observations needed; the phase should bind those saved records rather than inspect Phoenix source again.
- Archived Phase 5 validator code demonstrates standard-library parsing, hashing, exact key sets, and fail-closed checks. It is tied to earlier mutable inputs and R9 controls, so use it as a pattern reference rather than rerunning it wholesale.

### Established Patterns
- Keep lane-specific identity and provenance explicit; exact membership and complement digest are stronger than count-only checks.
- Distinguish an observed caller from exhaustive caller closure, and leave unknowns and gates visibly open.
- Run cheap structural and digest checks before longer work; add no dependency or recurring CI for a one-off evidence record.

### Integration Points
- The deliverable is a new planning evidence artifact plus a local consistency check. It must not change application code, archived Phase 5 evidence, source-request state, or the aggregate gate.
- No phase-specific codebase maps or actionable todos were present. Product source inspection is outside the approved scope and does not help this record-only phase.
</code_context>

<specifics>
## Specific Ideas

Keep the supplement narrowly machine-readable and traceable to both the reviewed discovery report and archived Phase 5 evidence. Run its cheapest format, exact-key, lane-binding, and complement checks first. Preserve a human-readable boundary statement that one direct `run/1` observation per lane does not prove complete caller closure.

</specifics>

<deferred>
## Deferred Ideas

- Complete direct, dynamic, delegated, callback, or package-wide caller closure; this requires a separately authorized bounded scope.
- Resolve the legacy digest, Macro caller-AST, Macro explanation, SEC-01, actual collision, or candidate-fit questions under their existing owners and gates.
- Consume R9, request more source, invoke runtime behavior, implement a guard, promote a candidate, close the aggregate, or activate the Walking Skeleton.

</deferred>

---

*Phase: 6-bounded-ex-177-provenance-supplement*
*Context gathered: 2026-11-19*
