# Phase 5: Bounded two-lane source provenance slice — Context

**Gathered:** 2026-11-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Use one bounded evidence scope to address the source and direct-caller gaps for EX-177 on the core and floor lanes. The exact target is `Elixir.Mix.Tasks.Phx.Gen.Context.prompt_for_code_injection/1`, one known MFA per lane. The retained citation `phoenix/lib/mix/tasks/phx.gen.context.ex:445` is only a locator; it does not prove current lane source identity or caller closure.

The selected scope is exactly four current typed-gap rows: source and caller, once per lane. The other 9,712 rows remain the pending complement, including all 18 unknown-target-set rows and 225 other identities per lane. The legacy nested SIZING digest remains unresolved because its selector, field order, and exact input terms are not retained. The versioned integrity supplement is not a reproduction. This scope does not select a candidate, close the aggregate, or authorize implementation.
</domain>

<decisions>
## Implementation Decisions

### Selected evidence slice
- **D-01:** Select only EX-177 on both lanes. Its retained reason is `project_build`, and its matcher names `prompt_for_code_injection`; prioritize it because the named boundary is security-relevant and the exact membership is one MFA per lane with four matching gap rows. This does not assert that a vulnerability exists.
- **D-02:** Preserve all unselected rows as the exact pending complement. Any EX-177 row not resolved by valid evidence also remains pending. Never infer aggregate closure from this slice.

### Source and caller evidence
- **D-03:** Use a new, unique request ID only if the pinned core and floor sources and exact spans can be identified and counted. Require independent schedule review, exact identity/path/span/hash bindings, fresh direct count, execute preflight, context-fit and security checks, and a one-use gate before source output. If the request changes, repeat review and count. Never replay a consumed, incomplete, or truncated request.
- **D-04:** Trace statically evidenced direct caller/delegate paths for this exact target only. Keep callbacks, dynamic callers, and unobserved paths as explicit gaps; do not claim system-wide caller absence.
- **D-05:** If exact source membership, available pinned files, source count, context fit, or caller file count fails a gate, stop before source output and record the precise cause. Do not select a replacement family automatically.

### Verification and preserved stops
- **D-06:** Run cheap checks on lane identity sets, selected rows, complement counts/digests, schemas, hashes, byte counts, and schedule bindings before any source output or broad checks. Reuse fresh Phase 4 evidence when its inputs are unchanged; do not rerun the Phase 3 suites for a metadata-only result.
- **D-07:** Keep the legacy digest gap open; do not reread the helper or guess its selector/field order. No new dependency is needed.
- **D-08:** Preserve static-only collection, candidate null, implementation unauthorized, guard aggregate open, Walking Skeleton blocked, SEC-01 Pending, actual collision unknown, and Macro caller-AST/explanation checkpoints unresolved. No automatic follow-on.

### the agent's Discretion
- Use existing project validators and a small standard-library consistency check; avoid adding dependencies or CI work for this one-off evidence slice.
- Narrow the source request to the smallest complete spans that establish the selected target's identity and directly relevant caller path. The five-file-per-task ceiling remains absolute.
- Skip suites that do not add evidence to this static-only slice; record the reason instead.
</decisions>

<canonical_refs>
## Canonical References

### Owner direction and project boundaries
- `.planning/intent/sources/2026-11-18-05-authorize-one-bounded-evidence-scope.md` — authorization for one additional bounded evidence scope; EX-177 is the agent's metadata-derived candidate, not an identity explicitly selected by the owner.
- `.planning/ROADMAP.md` — active v0.4 goals, Phase 3/4 boundary, and this Phase 5 scope.
- `.planning/REQUIREMENTS.md` — GSR-03 source/caller evidence and inherited limits.
- `.planning/VERIFICATION.md` — automated evidence, fresh-input reuse, and honest not-run reporting.
- `.planning/references/PLANNING-LIFECYCLE.md` — planning owners, lifecycle gates, and handoff rules.
- `.planning/references/PLANNING-GATES.json` — guard-aggregate remains open; automatic follow-up is disabled.
- `.planning/references/PRODUCT-ROADMAP.md` — exact selected family, complete complement, caller/delegate evidence, and fresh sizing are prerequisites for any guard increment.

### Prior phase evidence
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json` — current core membership and EX-177 row.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json` — current floor membership and EX-177 row.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-PLAN.md` — Phase 3's exact evidence contract and preserved stops.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-VERIFICATION.md` — Phase 3 result and still-open safety gates.
- `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-CONTEXT.md` — previous full-set provenance scope and source-request controls.
- `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-HANDOFF.md` — record-valid outcome, consumed request ledger summary, and semantic gaps.
- `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-PROVENANCE-MANIFEST.json` — current lane identities, set counts, source gate status, and request status.
- `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-TYPED-GAPS-ENV06.jsonl` — the four exact EX-177 source/caller gap rows and 9,712-row complement.
- `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-SIZING-DIGEST-PROOF.json` — exact limits of legacy digest evidence.
- `.planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-validate-artifacts.py` — existing cheap package and partition consistency checks.

### Safety and delivery
- `docs/adr/0004-no-eval-no-new-atoms.md` — no runtime evaluation or new atoms.
- `docs/adr/0014-testing-strategy.md` — cheapest meaningful checks and negative controls.
- `docs/adr/0021-delivery-rules.md` — exact source, task, review, and delivery constraints.
- `.planning/references/PHASE-DELIVERIES.json` — actual merged deliveries and non-overlap evidence.
</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable assets
- The Phase 4 artifact validator already checks the stable aliases, active generation, keyed partitions, and preservation receipts.
- Phase 3 lane records provide complete identity/MFA membership and historical source citations, but the citations are not current source or caller proof.

### Established patterns
- Keep lane-specific identities, hashes, source spans, and caller edges separate; unknown remains unknown.
- Use keyed evidence rows and an exact complement; aggregate counts alone do not establish equality.
- Source reads require independent review, a fresh direct count, execute preflight, and one-use authorization.

### Integration points
- Phase 5 adds separate evidence under `.planning/phases/05-bounded-two-lane-source-provenance-slice/`; it does not rewrite Phase 3/4 history or change runtime behavior.
</code_context>

<specifics>
## Specific Ideas

The Phase 4 handoff reports 9,716 typed gaps: 4,849 source, 4,849 caller, and 18 unknown-target-set rows. EX-177 contributes exactly four rows: one source and one caller gap on each lane. The source request should only cover the smallest exact pinned source/caller spans needed for this identity. The four rows and full complement must be checked before any longer process.
</specifics>

<deferred>
## Deferred Ideas

- Any second target family, another helper refresh, or a new guard increment.
- Legacy nested digest reproduction until the exact selector and values are available without guessing.
- Candidate promotion, implementation, aggregate closure, Walking Skeleton, SEC-01, dynamic caller absence, callback execution, or runtime safety claims.
</deferred>

---

*Phase: 5-bounded-two-lane-source-provenance-slice*
*Context gathered: 2026-11-18*
