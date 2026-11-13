# Phase 1: Bounded guard continuation - Context

**Gathered:** 2026-11-11
**Status:** Scope selected; ready for research. Exact source binding, connected-source sizing and effort fit must pass before executable planning.
**Milestone:** v0.2 / guard-recovery
**Authority:** INT-20261111-05; inherited rolling allocation in INT-20261110-01

<domain>
## Phase Boundary

Review and deliver the complete EX-010 exclusion row: `inets:enable_trace/2` and `inets:enable_trace/3` on each pinned lane, including necessary caller-input and delegate paths. The recorded direct delegates are `inets_trace:enable/2` and `/3`; their local helpers and any further relevant boundaries must be included in semantic source tracing. Four preliminary source identities cover `inets.erl` and `inets_trace.erl` on core and floor. This is a selected candidate, not a verdict or a certified plan.

The concrete contribution is a complete, individually evidenced disposition for one currently pending original row and its two recorded matches per lane. This reduces unfinished guard evidence; it does not itself remove the complete product blocker or expose new product behavior. GRC-01 through GRC-03 remain the active acceptance criteria.
</domain>

<decisions>
## Implementation Decisions

### Selected membership and pending complement
- **D-01:** Own EX-010 only. Reconcile the recorded two-MFA set independently against the current complete installed graph on core and floor. Preserve the original matcher identity and enumerate any newly discovered match; do not cap the result at two or infer safety from a name.
- **D-02:** Include `inets_trace` as supporting source, without claiming disposition of adjacent EX-011 or other rows sharing those files. Preserve every original exclusion identity, current match, caller/delegate edge and existing disposition outside EX-010. Emit exact selected/remainder equality evidence before planning; outside this row, statuses remain as their current owners record them, rather than resetting delivered evidence to pending.
- **D-03:** Use the narrow provenance snapshot `01-CANDIDATE-EVIDENCE.json` to locate and reconcile the preserved uncommitted pilot. It is a research lead, not a second audit authority or an approved semantic record. Do not import its full mechanical batch grouping or convert it into a phase schedule.

### Source authority and fit before plans
- **D-04:** Bind exact source bytes to core OTP 29.1.2 and floor OTP 27.3.4.9, with the existing pinned runtime identities and approved offline source/archive mechanism. `inets.erl` is already archived; the pilot's `inets_trace.erl` bytes still require archive binding and provenance validation. Local snapshot availability is unknown. Opposite-lane or unmatched source cannot substitute; do not invent provenance or add recurring network fetches.
- **D-05:** The pilot records 13,953 full-file source tokens across four identities: core 6,998 and floor 6,955. These are historical tokenizer observations, not a complete connected-source budget, current retokenization or an effort estimate. Validate hashes, inventory and archive authority; include all necessary downstream, callback and dynamic-call context plus implementation/review/verification reserve. Recorded zero direct incoming edges does not establish absence of dynamic callers.
- **D-06:** Before executable plans are written, record complete connected membership, source/context sizing and an itemized effort estimate. Preserve the 100,000-token planning bound, at most five total exact source files read per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan under INT-20261110-01. Count already-bound source when re-read; structured prior findings may be reused within their scope. Do not truncate files, functions, citations or caller paths to fit.
- **D-07:** If missing source, relevant source expansion or estimated effort prevents fit, stop and report the concrete gap and a proposed bounded remedy. Do not silently replace EX-010 with another candidate, expand into EX-011, create another phase or resume a historical five-slot plan. A standalone timing pilot and a full-remainder schedule are not prerequisites; actual execution intervals must later be recorded honestly.

### Semantic proof and security
- **D-08:** Determine caller influence from exact source, including destinations, trace callbacks, service selection and relevant evaluator/loader/atom boundaries. The earlier source-only pilot is not a decision to retain or remove this exclusion. Source citation/schema checks and green CI do not supply a semantic verdict.
- **D-09:** Use the existing audit/guard authority and static compile-only fixtures. Preserve benign controls and prove deliberate violations are detected through applicable direct/capture/apply/source forms. Each retained matcher needs an individual non-vacuous lane witness; removed/replaced matchers need evidence-backed replacement/detection proof, including overlap controls. Record explicit genuine lane absence rather than silently skipping it. Never invoke audited OTP APIs, trace callbacks or atom sinks, and never claim runtime SEC-01 safety from static evidence.
- **D-10:** A newly justified guard colliding with a real `lib/` call site stops the affected work. Report the exact MFA, call site, input trace and triggering guard. The owner chooses a separately recorded remedy; do not auto-allowlist or refactor production. Preserve the separate Macro caller-AST and exact explanation-wording checkpoints. Do not change explanation wording in this slice.

### Delivery and bounded exit
- **D-11:** Add no dependency, production feature, new CI lane or generic audit framework. Keep guard work contract-only: no bundled `lib/`, `.github/`, `mix.exs`, lockfile or `.credo.exs` changes. Reuse existing exact-source resolution, ledger, lane discovery and ExUnit/Credo checks; apply ADR 0021 separation and existing review limits.
- **D-12:** Exit only with complete source-backed EX-010 dispositions and selected/remainder proof, individual lane witnesses, meaningful static negative/positive controls, required local validation/review, and an actual green merged PR with hosted candidate receipts. Carry source-bound pending gaps honestly; no halted predecessor satisfies completion. Reuse merged legacy deliveries only within their scope; do not replay them because shared-source fingerprints later changed.
- **D-13:** Stop at the phase/milestone boundary after this selected delivery. Record what changed, what remains open, measured cost and the recommended next scope; the owner chooses whether to authorize another bounded increment or revisit the aggregate strategy. Do not generate automatic follow-on phases or milestones. The full guard aggregate, installed-wide remainder and walking-skeleton activation gate remain open; SEC-01 stays Pending with controls-bundle / Phase 1.

### Agent's Discretion
Choose exact local helper boundaries, source extraction/binding mechanics within the approved archive policy, conservative source-connected task decomposition, truthful failure messages, and the cheapest meaningful automated proofs. Use existing Elixir/OTP/ExUnit tools and reuse current evidence. No UI, brand, motion or other product-design choice is part of this phase.
</decisions>

<canonical_refs>
## Canonical References

Downstream agents must read these before planning or implementing. Paths below are relative to the reviewed checkout.

### Scope and persistent gates
- `.planning/intent/sources/2026-11-11-05-select-inets-tracing-scope.md` — owner selection and limits.
- `.planning/intent/sources/2026-11-10-01-rolling-allocation-for-bounded-work.md` — rolling allocation and per-plan effort limits.
- `.planning/ROADMAP.md` and `.planning/REQUIREMENTS.md` — active Phase 1 and GRC-01 through GRC-03.
- `.planning/phases/01-bounded-guard-continuation/01-CANDIDATE-EVIDENCE.json` — narrow, hash-bound research lead from preserved pilot metadata; not semantic authority.
- `.planning/migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md` — all surviving obligations and future owners.
- `.planning/references/PLANNING-GATES.json` and `.planning/references/PLANNING-LIFECYCLE.md` — aggregate gate, delivery-aware routing and bounded exit.
- `.planning/intent/NORTH-STAR.md`, `.planning/intent/CLEARANCE.md` and `.planning/VERIFICATION.md` — product goal, release boundaries and automated evidence policy.

### Original acceptance and delivered patterns
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-CONTEXT.md` — inherited semantic, lane, collision and wording boundaries, subject to later cited intent.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-REPLAN-RECOMMENDATION.md` — original identities, blocked historical plans and aggregate acceptance.
- `.planning/milestones/v0.1-phases/01.1.1.18-bound-asn-1-generator-dispatch-exclusions/01.1.1.18-MERGE.md` and `.planning/milestones/v0.1-phases/01.1.1.18-bound-asn-1-generator-dispatch-exclusions/01.1.1.18-VERIFICATION.md` — delivered scoped source/witness pattern; not EX-010 approval.
- `docs/adr/0004-no-eval-no-new-atoms.md`, `docs/adr/0014-testing-strategy.md`, `docs/adr/0018-dependency-budget.md` and `docs/adr/0021-delivery-rules.md` — security, testing, dependency and delivery constraints.
- `GLOSSARY.md` — authoritative vocabulary.

### Existing implementation and upstream limitation
- `test/contract/tier_sweep_test.exs`, `test/contract/banned_calls_test.exs`, `test/support/sweep_evidence.ex`, `test/support/installed_otp.ex` and `credo/checks/banned_calls.ex` — existing authority, archive resolver, discovery and static guard boundaries.
- `test/fixtures/guards/exact_sources.tar.gz` — approved existing exact-lane source archive.
- https://www.erlang.org/doc/apps/tools/xref.html — upstream documents unresolved dynamic calls and incomplete graph analysis; exact pinned source remains the semantic authority.
</canonical_refs>

<code_context>
## Existing Code Insights
- `tier_sweep_test.exs` has EX-010's original `{:inets, [:enable_trace]}` matcher alongside the separately owned `inets_trace` exclusion. Keep supporting-source reuse separate from row ownership.
- `SweepEvidence` resolves exact lane source identities from the approved archive and rejects integrity/provenance errors. Extend the established mechanism only as needed for verified bytes.
- Existing generator-dispatch and other delivered contracts demonstrate complete match/edge equality, source citations and non-vacuous individual removal controls. Reuse these patterns without importing their target membership or claiming their semantic conclusions for EX-010.
- `InstalledOtp` and the current lane inventories support independent installed-set reconciliation; historical application counts are observations, not fixed scope.
- No codebase maps or `prompts/` directory exist in this reviewed checkout. Unrelated design research is not input to this guard slice.
</code_context>

<specifics>
## Specific Ideas
The owner selected the smaller whole-row candidate after an engineering, security and delivery fan-out. The two offered routes were this bounded increment or reconsidering the aggregate strategy first. Prefer a completed row with exact evidence over another mechanically numbered source bin; no full-backlog schedule or automatic continuation was selected.
</specifics>

<deferred>
## Deferred Ideas
- EX-011 and other rows sharing tracing sources retain their existing owners/statuses. Source relevance does not authorize their disposition here.
- The remaining ASN.1 matches, other original exclusions, installed-wide source gaps and aggregate closure remain outside this selected scope.
- Runtime properties/mutation proof remain with controls-bundle / Phase 1; walking-skeleton activation waits for aggregate-scoped closure.
- No future audit ladder, additional milestone or aggregate-policy change was approved. Select any next work at the actual boundary, using this increment's result and measured cost.
</deferred>
