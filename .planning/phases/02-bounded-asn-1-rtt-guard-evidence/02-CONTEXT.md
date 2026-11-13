# Phase 2: Bounded ASN.1 RTT guard evidence - Context

**Gathered:** 2026-11-12
**Status:** Scope, EX-107 membership, selected source identities, connected-source closure, per-task source/context limits, and itemized effort are validated. The owner selected separate evidence and contract-test outputs for core, floor, and integration so Wave 1 core/floor remain independent. The five plans passed independent review. No execution has started.
**Milestone:** v0.3 / guard-recovery
**Authority:** INT-20261111-13, INT-20261112-03, INT-20261112-04, INT-20261110-01

<domain>
## Phase Boundary

Produce source-backed static dispositions and individually falsifiable controls for exactly these EX-107 functions on both pinned lanes:

- `asn1ct_rtt:assert_defined/1`
- `asn1ct_rtt:code/0`
- `asn1ct_rtt:dependencies/1`

The complete EX-107 row remains authoritative. Phase 2 does not dispose of the other row members, close EX-107 or the guard aggregate, unblock Walking Skeleton, resolve SEC-01, or authorize an automatic follow-up increment.

### Discussion-time membership and source-identity check

On 2026-11-12, a read-only export inventory was independently built from the installed core and floor OTP `lib` trees, filtering exported MFAs whose module name starts with `asn1ct_` and excluding generated `module_info` and `__info__` exports. The sorted live sets matched the archived lane sets exactly: 177 MFAs on each lane, with no core/floor set difference. The archived `.jsonl.gz` files' byte counts and SHA-256 values match `.planning/migrations/2026-11-11-milestone-reset/ARCHIVE-MANIFEST.json`.

The approved selection is the exact three-MFA set above on each lane. All three are members of each live set. For this increment, the exact complement is each archived 177-MFA set minus those three: 174 remaining MFAs per lane. The sorted complement SHA-256 is `78c31d7b6e2bf8eb43791fc80540ff7cf8b093ce5248664df8f6eeea4ec33a69` on both lanes; the selected-set SHA-256 is `53136572d18b652f528410b5a38dab2b5397a4162e383e626241e77414e08cf7`.

The existing contract also preserves a historical 13-MFA selection and its 164-MFA complement. The three Phase 2 MFAs are all in that 164-MFA complement. After selecting them, 161 MFAs remain in that prior pending subset; its sorted SHA-256 is `959b11f08164556e4b413b67e9038b556e7327c0f870bdd4fc0628df78ace975` on both lanes. Thus the 174-MFA full-row complement consists of those 13 historically selected members plus the 161 still unselected members. These are two distinct partitions; do not substitute one count for the other.

The archived match-set inputs are 405819 bytes with SHA-256 `8bf95f884745a19aa50e0cccf6261459ebd2091de3cba155146674936367ab9c` (core) and 384623 bytes with SHA-256 `8bfc6f58582296aa7e5ea1d5aefb7a7ae828f63f285eb57d8a008e51629fa479` (floor). The exact-source archive SHA-256 is `7d4bd66fe72224cf49f849148b5e737443588ca66c12873938bfa30fa3d0ea58`.

The approved exact-source archive's full SHA-256 matches its lock in `test/support/sweep_evidence.ex`. It contains these lane-specific identities:

| Lane | Source | Bytes | SHA-256 |
|---|---|---:|---|
| Core, Elixir 1.20.4 / OTP 29.1.2 | `asn1/src/asn1ct_rtt.erl` | 135654 | `dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374` |
| Floor, Elixir 1.18.5 / OTP 27.3.4.9 | `asn1/src/asn1ct_rtt.erl` | 134820 | `828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d` |
| Core, Elixir 1.20.4 / OTP 29.1.2 | `asn1/src/asn1ct_func.erl` | 4465 | `da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753` |
| Floor, Elixir 1.18.5 / OTP 27.3.4.9 | `asn1/src/asn1ct_func.erl` | 4347 | `5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf` |

These identities bind candidate target and caller files; they do not certify complete caller closure or semantic dispositions. Those remain Phase 2 work. The measured byte sizes are not token counts or effort estimates.

</domain>

<decisions>
## Implementation Decisions

### Selected membership and preserved remainder
- **D-01:** Keep the complete original EX-107 row and own only the three approved `asn1ct_rtt` functions on core and floor. The live-to-archive equality above is the membership baseline. The Phase 2 selection leaves a 174-member complement in the full row and a 161-member remainder in the historical 164-member pending subset; count-only evidence is insufficient.
- **D-02:** Treat older EX-107 sub-slice records as scoped historical evidence. The existing `@asn1_expected_selected_mfas` set of 13 in `test/contract/tier_sweep_test.exs` is not Phase 2's selected set. Preserve that set and its 164-member complement as a separate historical partition; do not use it to redefine Phase 2 selection or close the original row.
- **D-03:** Before executable plans, finish connected-source membership, per-task source/context sizing, and an itemized effort estimate within the inherited limits. Count exact-source rereads; reuse structured prior findings only within their scope. Do not truncate files, functions, citations, caller paths, or evidence to make a task fit.

### Static evidence and safety boundary
- **D-04:** For each selected function on each lane, record exact source spans, the direct caller path, and a source-backed disposition. Provide an individually non-vacuous positive and negative control per function per lane. For `code/0`, use the existing bounded byte-only procedure for the large literal table outside the prompt.
- **D-05:** Never invoke the audited OTP functions, callbacks, or atom sinks. Static source review does not prove runtime behavior, dynamic callers, native internals, or SEC-01 safety. Keep these limits explicit in the evidence.
- **D-06:** Preserve actual-library-collision stops. If a newly justified guard collides with a real `lib/` call site, stop the affected work and report the exact MFA, call site, input trace, and triggering guard for an owner decision. Keep the Macro caller-AST and exact explanation-wording checkpoints separate and unchanged.

### Fit, implementation, and delivery limits
- **D-07:** Preserve the 100,000-token planning bound, at most five total exact source files read per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. If membership or source identity differs, or connected source/context/effort cannot fit, stop with the concrete gap and a bounded remedy; do not substitute another slice, expand into EX-011, or create another phase automatically.
- **D-08:** Keep implementation contract-only. Add no dependency, production feature, new CI lane, or generic audit framework. Preserve ADR 0021's separation between contract-test changes and the implementation they guard.
- **D-09:** Complete the selected slice through existing review, security, verification, exact-head, and required candidate/main CI gates, then a merged green PR. Run relevant GitHub Actions locally with `act` when feasible; local results supplement hosted receipts.
- **D-10:** Stop at the phase boundary. The owner decides whether to authorize another bounded increment or revisit aggregate strategy after seeing this slice's result and measured cost.

### The agent's Discretion
Choose evidence-file organization, helper boundaries, conservative task grouping, and the cheapest meaningful automated proofs within the limits above. Do not change the selected set, lower a gate, infer a runtime verdict, or select follow-up work.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Active scope, phase state, and owner intent
- `.planning/ROADMAP.md` — approved global Phase 2 goal, acceptance summary, and stopping boundary.
- `.planning/REQUIREMENTS.md` — GRC-04 through GRC-06, exact phase acceptance and out-of-scope items.
- `.planning/STATE.md` — current phase, prior delivery, and session continuity.
- `.planning/intent/sources/2026-11-11-13-approve-rtt-guard-slice-and-brand-dogfood-roadmap.md` — owner-approved three-function slice and preserved limits/gates.
- `.planning/intent/sources/2026-11-12-03-approve-v03-roadmap.md` — approval of the bounded v0.3 milestone.
- `.planning/intent/sources/2026-11-12-04-continue-global-phase-numbering.md` — v0.3 is global Phase 2; future numbering policy.
- `.planning/intent/sources/2026-11-10-01-rolling-allocation-for-bounded-work.md` — source, task, token, plan, and effort limits.
- `.planning/intent/NORTH-STAR.md` and `.planning/intent/CLEARANCE.md` — product quality bar and unchanged clearance gates.
- `.planning/VERIFICATION.md` — automated evidence, CI, and handoff policy.
- `GLOSSARY.md` — authoritative vocabulary.

### Prior guard decisions and carried obligations
- `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-CONTEXT.md` — inherited source, collision, semantic, review, and delivery boundaries.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-CONTEXT.md` — original semantic, lane, collision, and wording checkpoints, subject to later intent.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-REPLAN-RECOMMENDATION.md` — original row identities and historical planning stop.
- `.planning/migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md` — open guard/product obligations and their owners.
- `.planning/references/PLANNING-GATES.json` — guard aggregate and SEC-01 owners.
- `.planning/references/PLANNING-LIFECYCLE.md` — canonical state owners, preflights, and phase boundaries.
- `.planning/references/PHASE-DELIVERIES.json` — immutable delivered-phase receipts.
- `.planning/migrations/2026-11-11-milestone-reset/PHASE-MAP.json` — future local slots and typed prerequisites; not a source of new Phase 2 scope.

### Membership, exact sources, and existing guard patterns
- `.planning/migrations/2026-11-11-milestone-reset/ARCHIVE-MANIFEST.json` — immutable hashes and byte counts for archived sizing evidence.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-CURRENT-SIZING-CORE.jsonl.gz` and `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-CURRENT-SIZING-FLOOR.jsonl.gz` — complete archived lane match sets, including EX-107.
- `test/fixtures/guards/exact_sources.tar.gz` — approved lane-specific exact-source archive.
- `test/support/sweep_evidence.ex` — archive lock, source resolution, lane identities, and scoped prior records.
- `test/support/installed_otp.ex` — installed-lane inventory, export, and Xref helpers.
- `test/contract/tier_sweep_test.exs` — EX-107 full-row assertions, prior scoped patterns, and bounded `code/0` literal-table check.
- `test/contract/banned_calls_test.exs` and `credo/checks/banned_calls.ex` — existing static guard and compile-only control patterns.

### Security, testing, dependency, and delivery constraints
- `docs/adr/0004-no-eval-no-new-atoms.md` — no runtime eval or input-derived atoms.
- `docs/adr/0014-testing-strategy.md` — test boundaries and static control expectations.
- `docs/adr/0018-dependency-budget.md` — dependency restrictions.
- `docs/adr/0021-delivery-rules.md` — plan sizing, merged-green delivery, review cap, and contract-test separation.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Fablebook.Test.SweepEvidence` resolves approved lane-specific source bytes from `test/fixtures/guards/exact_sources.tar.gz`, checks its archive lock, and rejects identity or provenance mismatches.
- `Fablebook.Test.InstalledOtp` provides installed-app discovery, export inventory, Xref graph construction, and lane-parity checks. Reuse it for durable coverage rather than adding a parallel inventory mechanism.
- `test/contract/banned_calls_test.exs` and `credo/checks/banned_calls.ex` contain source-only and compile-only positive/negative control patterns; prior exact-lane records may be reused only where their source and finding scope match.

### Established Patterns
- `test/contract/tier_sweep_test.exs` asserts the full EX-107 lane union and source-backed row boundaries. Its historical 13-member selected set and 164-member remainder are not the Phase 2 partition.
- Existing `asn1ct_rtt:code/0` coverage checks the complete literal table with a bounded byte-only procedure and malformed-shape controls. Keep the table outside the prompt and do not invoke the function.
- Existing ASN.1 generator-dispatch records bind `asn1ct_func.erl` and `asn1ct_rtt.erl` to exact core/floor bytes. They are source leads, not final dispositions for this phase's selected functions.

### Integration Points
- Phase 2 updates the existing EX-107 static evidence and lane controls in the guard contract surface. Preserve original exclusion identity and all other rows' owners/statuses.
- Contract-test changes must be delivered separately from the implementation they guard under ADR 0021.

</code_context>

<specifics>
## Specific Ideas

The owner approved one bounded EX-107 slice and explicitly retained the complete row, pending complement, inherited limits, and wider safety gates. No new product decision was needed for this discussion. The live-set equality, source identity, connected-source closure, context fit, and itemized effort gates are recorded as passed in `02-RESEARCH.md`. They do not establish runtime behavior or close any wider safety/product gate.

</specifics>

<deferred>
## Deferred Ideas

- The other 174 original EX-107 row members remain outside this slice. EX-011 and other rows sharing the same files keep their existing owners and statuses.
- The full guard aggregate and installed-wide remainder remain open. Walking Skeleton remains blocked until aggregate-scoped proof passes.
- SEC-01 remains Pending with Controls and the first bundle's first local slot; allocate its global integer only when that milestone activates.
- The acknowledged v0.2 deferrals, scheduled observations, clearance C1–C10, and other carried safety/product obligations retain their existing owners.
- No automatic next guard increment, new product milestone, brand implementation, release, or deployment is selected.

</deferred>

---

*Phase: 2-Bounded ASN.1 RTT guard evidence*
*Context gathered: 2026-11-12*
