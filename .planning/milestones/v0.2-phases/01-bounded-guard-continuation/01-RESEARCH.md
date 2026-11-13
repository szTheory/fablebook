# Phase 1: Bounded guard continuation — Research

**Researched:** 2026-11-11  
**Domain:** Exact-source static guard review for Erlang/OTP tracing entry points  
**Confidence:** MEDIUM; exact source identities and current core/floor graph membership verified; semantic disposition and execution evidence remain pending

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Implementation Decisions

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

### Deferred Ideas (OUT OF SCOPE)
- EX-011 and other rows sharing tracing sources retain their existing owners/statuses. Source relevance does not authorize their disposition here.
- The remaining ASN.1 matches, other original exclusions, installed-wide source gaps and aggregate closure remain outside this selected scope.
- Runtime properties/mutation proof remain with controls-bundle / Phase 1; walking-skeleton activation waits for aggregate-scoped closure.
- No future audit ladder, additional milestone or aggregate-policy change was approved. Select any next work at the actual boundary, using this increment's result and measured cost.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GRC-01 | Before execution, bind the next source-connected slice to exact core/floor source identities, all selected MFAs and caller/delegate paths, a complete selected/remainder partition, and the existing source/context/effort limits. No truncated source or invented ready phase. | Six exact source identities, current core/floor graph observations, selected/remainder equality, delegate paths, and per-isolated-plan fit are recorded below and in `01-SIZING.md`. |
| GRC-02 | Deliver the selected slice's source-backed static-guard dispositions and non-vacuous positive/negative coverage on both pinned lanes, without invoking audited APIs; merge a reviewed green contract-only candidate under the existing delivery rules. | Existing source resolver, tier sweep, and banned-call contract are the implementation/testing pattern. No semantic disposition or witness is certified by this research. |
| GRC-03 | Preserve every original exclusion identity and pending complement, prior merged evidence, source-size and actual-library-collision stops, and all aggregate/product gates. Scope completion only to that slice; SEC-01 stays Pending with its future controls/property owner. | Keep EX-011 and outside-row states with current owners; phase exit remains scoped to EX-010 and leaves the aggregate/product gates unchanged. |
</phase_requirements>

## Research Status

**RESEARCH COMPLETE — bounded planning fit is certified per isolated serial plan context.** Exact bytes for six known connected source identities match the pinned lane identities. The current core/floor graph contract passed; `01-GRAPH-OBSERVATIONS.json` records the two selected EX-010 MFAs per lane, zero additional within-row remainder, equal selected/remainder partition, and delegate edges into `inets_trace`. Outside-row ledger identities and statuses remain with their existing owners. The graph and zero-incoming observations do not establish absence of dynamic callers or semantic disposition.

The earlier raw sum of 75,406 source tokens plus one 31,000 reserve was not the inherited budget model: the 100,000-token ceiling applies to each isolated serial plan context. Three contexts preserve the full 31,000 reserve in each and remain below the ceiling; see `01-SIZING.md` for assumptions, source grouping and stop conditions. This certifies research fit only. It does not decide EX-010 disposition or waive execution-time full-source review, exact archive binding for `inets_trace.erl`, witnesses, validation, review, delivery, or existing safety stops.

## Summary

The original API delegates through `inets_trace` to debugger tracing. Source inspection established that the destination can be a path, integer port, `io`, or a callback pair; the callback/port dispatch continues inside `dbg.erl`. Both lane versions of `inets.erl`, `inets_trace.erl`, and `dbg.erl` are available locally with hashes matching the recorded or archived exact identities. The existing archive already carries both lane versions of `inets.erl` and `dbg.erl`; `inets_trace.erl` still needs binding into the approved archive before execution can use the established resolver.

**Primary recommendation:** plan three serial bounded contexts: one full-source review for each pinned lane, followed by integration using only exact-hash-scoped structured findings from those reviews. Do not reopen source in integration or treat graph observations as semantic dispositions. Bind `inets_trace.erl` to the approved archive before executable source resolution.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Exact OTP source identity and match inventory | API / Backend (test contracts) | Database / Storage — | Existing contract support owns lane discovery, source resolution, and graph evidence. |
| Static source/BEAM guard behavior | API / Backend (test contracts) | — | Credo and ExUnit contracts are the project’s enforcement boundary; production files stay out of scope. |

## Standard Stack

### Core

| Library/tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Elixir / OTP core | Elixir 1.20.4 / OTP 29.1.2 | Current exact lane for source inventory and static Xref | Existing project pin. `[VERIFIED: test/support/sweep_evidence.ex:17-24]` Verbatim: `"core" => %{` / `"otp" => ["29.1.2", "d199a49a01a2079afb6f2c5c9ae047cd4555e68d"]` |
| Elixir / OTP floor | Elixir 1.18.5 / OTP 27.3.4.9 | Compatibility floor for independent source inventory and witnesses | Existing project pin. `[VERIFIED: test/support/sweep_evidence.ex:21-24]` Verbatim: `"floor" => %{` / `"otp" => ["27.3.4.9", "4aa809ae4eb4a20ad89c23837376acf179877f39"]` |
| Existing `SweepEvidence` and installed OTP inventory | In-repo | Bind source archive/runtime identities and discover installed app sources | Reuse project mechanisms; add no dependency. |
| Existing ExUnit / Credo guard contracts | In-repo | Static fixture compilation, BEAM scanning, source checks, exact-lane evidence | Reuse current authority rather than introducing another checker. |

### Supporting

| Library/tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| Erlang Xref | Installed with each pinned OTP | Non-invoking export/call graph discovery over BEAM files | Research and existing lane graph contract only; it does not establish dynamic caller absence. |
| `BeamWalker` | In-repo | Inspect compiled fixture BEAM metadata without calling fixture functions | Use for compile-only positive and benign negative controls. |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Existing source resolver and Xref/BEAM contracts | A new source-analysis framework | Out of scope, adds dependency/authority and conflicts with D-11. |
| Local exact install and approved archive | A different lane or network fetch | Wrong-lane bytes do not prove exact lane identity; recurring network fetch is forbidden by D-04. |

## Package Legitimacy Audit

Not applicable: this phase adds no external package. `[CITED: 01-CONTEXT.md D-11]`

## Exact Source Inventory and Provenance

Candidate source identities for `inets.erl` and `inets_trace.erl` are recorded in `01-CANDIDATE-EVIDENCE.json`; the table below includes the two additional `dbg.erl` identities because callback dispatch reaches that module. All six files were hash/byte-compared against the exact installed lane source. The existing archive manifest also binds both lane `dbg.erl` files to their pinned OTP refs. These checks establish source-byte identity only; they do not establish EX-010’s final semantic disposition.

| Lane | Exact source file | Bytes | Historical full-file tokens | SHA-256 | Archive state |
|------|------------------|------:|---------------------------:|---------|---------------|
| core | `inets/src/inets_app/inets.erl` | 18,519 | 4,188 | `18d0c8091e7c9ce34fad897734c1b4105fd8c19d0912da28a32856664c760f00` | Present in approved archive |
| floor | `inets/src/inets_app/inets.erl` | 18,409 | 4,154 | `d8786fea1edde0d055e7198cdb279e9a1999daa070d4dc229f3ec66b75e8bd5e` | Present in approved archive |
| core | `inets/src/inets_app/inets_trace.erl` | 11,112 | 2,810 | `1f67a0bda05227eddd8ffb4909ec8a31465ef2d8582e0ff9ff5d2b72638c7599` | Available locally; archive binding pending |
| floor | `inets/src/inets_app/inets_trace.erl` | 11,073 | 2,801 | `3e03ac1b03d2a01e7ddb1b1e29543e632aa3a63e16aa1f5a8c19ba935ae4dffd` | Available locally; archive binding pending |
| core | `runtime_tools/src/dbg.erl` | 105,185 | 29,520 | `d996e990b75251edb65d4930a1edf5c1914f6c18f77ac526313157612f95f5f2` | Present in approved archive |
| floor | `runtime_tools/src/dbg.erl` | 112,878 | 31,933 | `808aa7980e020fc529e153fc907b606fd0e2ff5fb4ad0b74e548b5eafaea0dae` | Present in approved archive |
| **Total** | **6 lane-specific source identities** | **277,176** | **75,406** | — | — |

`[CITED: 01-CANDIDATE-EVIDENCE.json, source_identities]` records the four inets hashes/bytes/tokens and identifies its tokenizer observation as `tiktoken 0.14.0 o200k_base`; these were historical counts. Preserved source-review-unit metadata supplies the `dbg.erl` full-file counts. Each `dbg.erl` hash and byte size matches both the local exact install and the current approved archive manifest. The tokenizer was not available for a fresh retokenization. Therefore token totals are cited historical measurements over the verified identical bytes, not new tokenizer output.

The exact local source locations observed were `~/.asdf/installs/erlang/29.1.2/lib/inets-9.8.1/src/inets_app/` and `~/.asdf/installs/erlang/27.3.4.9/lib/inets-9.3.2.3/src/inets_app/`, plus their corresponding `runtime_tools` app source directories. The preserved local floor source archive for OTP 27.3.4.9 at pinned ref `4aa809ae4eb4a20ad89c23837376acf179877f39` also yielded the exact floor inets source hashes; its archive SHA-256 was `ad04b56dbb0115c73bb6102ac10a8c828846d08c9ac44020ec9b2d988bb1e622`. No source was downloaded.

### Current OTP-only static graph observation

Static Xref was run over every installed OTP application `ebin` directory: 35/35 additions succeeded for core and 34/34 for floor. Both lanes reported the recorded exported endpoints:

- `inets:enable_trace/2`
- `inets:enable_trace/3`

Both lanes reported direct edges `inets:enable_trace/2 -> inets_trace:enable/2` and `inets:enable_trace/3 -> inets_trace:enable/3`, with no direct incoming Xref edges. In `inets_trace`, Xref also reported `enable/2 -> enable/3`, `enable/3 -> enable2/3`, and `enable/3 -> valid_trace_service/1`. This is a current OTP-only scan, not the project’s complete installed graph: Elixir apps and project dependencies were not included. D-05 and the candidate input state verbatim: “Recorded zero direct incoming xref edges does not establish absence of dynamic callers.”

## Architecture Patterns

### Data flow

```text
caller inputs (level, destination, service)
  -> inets:enable_trace/2 or /3
  -> inets_trace:enable/2 or /3
       -> fixed service validation
       -> destination dispatch: file | integer port | io | {Fun, Data}
       -> dbg:tracer / dbg:trace_port
       -> trace setup: dbg pattern and process calls
       -> trace event callback or port destination
```

Source citations are the exact OTP files in the source table and immutable refs recorded by the repository’s source manifest. No OTP API, caller trace callback, or atom sink was invoked during this research.

### Recommended Project Structure

Keep implementation within the existing guard contracts and approved source archive. Preserve the ownership boundary between EX-010 and EX-011; `inets_trace.erl` is supporting source and does not grant EX-011 disposition.

### Pattern: Static source plus compile-only BEAM witnesses

**What:** Resolve exact lane source citations, inspect complete function bodies and call paths, compile deliberately safe/unsafe fixture functions, then inspect their BEAM metadata without calling them.  
**When to use:** Contract-only checks for static bans, input paths, callbacks, and caller-source forms.  
**Example:** `BeamWalker.scan/1` reads BEAM debug metadata and returns structured errors when source metadata is absent. `[CITED: test/support/beam_walker.ex]`

### Anti-Patterns to Avoid

- **Treating zero static incoming edges as proof of no callers:** dynamic calls can be absent from Xref’s direct-edge output; reconcile full exports and retain explicit uncertainty about dynamic call forms.
- **Treating API names as semantics:** inspect destinations, callback invocation, service validation, and source sinks before proposing a verdict.
- **Reusing a neighboring row’s decision:** EX-011 and shared files remain separately owned.
- **Running fixtures or traced code to prove static detection:** fixtures must remain uncalled; do not execute the audited trace API or callback.
- **Truncating source to fit the token bound:** split the work or reuse only scoped structured findings; never drop connected code or citations.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Exact source resolution | New source fetcher or provenance format | `SweepEvidence` and `test/fixtures/guards/exact_sources.tar.gz` | Existing resolver enforces pinned refs, archive hash, lane identity, and exact source bytes. |
| Export/call graph inventory | A custom static call scanner | Existing installed OTP inventory and Xref support | Existing mechanism is lane-aware and checks graph completeness. |
| Fixture BEAM inspection | Runtime fixture invocation | `BeamWalker` static scan | Compile-only witness preserves the no-invocation boundary. |

## Source and Context Fit

| Work grouping (research sizing only; not an executable plan) | Exact source identities | Source files per task | Historical source tokens |
|-------------------------------------------------------------|-------------------------|-----------------------:|------------------------:|
| Core semantic source review | Core `inets.erl`, `inets_trace.erl`, `dbg.erl` | 3 | 36,518 |
| Floor semantic source review | Floor `inets.erl`, `inets_trace.erl`, `dbg.erl` | 3 | 38,888 |
| **Known source baseline** | **6** | **3 per lane task** | **75,406** |

The two source groups respect the maximum of five exact source files per task. Full semantic review remains execution work. The passed graph identifies no further static delegate source beyond `inets_trace`; the relevant source path terminates at `dbg` callback and trace-port dispatch. The callback function is caller input and native trace-port internals are a fixed runtime boundary, so no arbitrary callback implementation or recursive library closure is included. The graph does not rule out dynamic callers. Any additional exact source found necessary during source review triggers a new fit calculation with the full reserve; do not truncate or ignore it.

| Planning/verification reserve item | Conservative token allowance | Basis |
|------------------------------------|-----------------------------:|-------|
| Phase constraints, current ownership and prior evidence mapping | 5,000 | `[ASSUMED]` planning allowance; includes current decisions and delivery/aggregate boundaries. |
| Full graph, selected/remainder reconciliation and archive binding for `inets_trace` | 8,000 | `[ASSUMED]` implementation/evidence allowance; no fixture/schema changes yet estimated. |
| Individual lane dispositions, compile-only direct/capture/apply/source controls, collision evidence | 10,000 | `[ASSUMED]` task design and implementation allowance, subject to exact source review. |
| Review, local lane validation, CI receipt and bounded retest/handoff | 8,000 | `[ASSUMED]` reserve for review/verification bookkeeping and one correction cycle. |
| **Reserve total** | **31,000** | **Planning estimate only; no completion-rate claim.** |
| **Isolated context fit** | **67,518 core; 69,888 floor; up to 71,000 integration** | **Each independently below 100,000; see `01-SIZING.md`.** |

The 31,000-token reserve and 40,000-token integration findings allowance are explicit conservative assumptions, not measured evidence. Integration consumes only exact-hash-scoped structured findings from lane reviews and does not reopen the six source files. Historical sibling execution windows vary and do not support a tokens-per-hour conversion. The prior source-only pilot cannot estimate implementation, review or validation. No work may be silently trimmed to force a fit.

### Effort basis and task constraints

- Known full-source input is 75,406 historical tokens; implementation may reuse only findings scoped to the exact callback/delegate path and source hash. Existing archived `dbg.erl` bytes do not automatically provide an EX-010 semantic review.
- Use three serial plans with 2–3 tasks each: one full-source review per lane, then integration from their structured findings. Any source reread counts toward the five-file task cap. Keep each plan within roughly three working days; conservative effort assumptions are 1–2 days per lane and 0.5–1.5 days for integration. Stop and re-scope if a plan approaches the limit or its context estimate exceeds the certified allowance.

## Common Pitfalls

### Pitfall 1: Confusing source availability with archive binding

**What goes wrong:** A local source file is used by an executable contract without the approved resolver knowing its exact lane identity.  
**Why it happens:** `inets_trace.erl` is installed and hash-matched but absent from the current archive.  
**How to avoid:** Add the verified core/floor bytes and pinned-ref manifest rows using the existing archive procedure; retain hash/size checks.  
**Warning signs:** Resolver falls back to opposite-lane source or reports unresolved identity.

### Pitfall 2: Treating OTP-only graph as complete repository membership

**What goes wrong:** Project dependency callers or dynamic forms are omitted from the selected/remainder equality.  
**Why it happens:** The first successful scan covered only OTP application `ebin` directories.  
**How to avoid:** Consume the orchestrator’s current full core/floor graph receipt and retain dynamic-caller caveats.  
**Warning signs:** Graph receipt lists only OTP app roots or does not reconcile the full exclusion ledger.

### Pitfall 3: Budgeting only the four API files

**What goes wrong:** The plan misses callback and port-generator dispatch reached through `dbg`.  
**Why it happens:** The preliminary source pilot stopped at `inets.erl` and `inets_trace.erl`.  
**How to avoid:** Include exact `dbg.erl` source in both lane contexts or cite a prior structured semantic finding for the exact connected functions and matching source hash.

## Code Examples

Verified implementation pattern: the existing `Fablebook.Test.BeamWalker.scan/1` returns structured metadata/error outcomes and does not call the fixture function. Use the existing compile-only fixture pattern in `test/contract/banned_calls_test.exs`; retain benign negative controls and ensure every selected matcher has a non-vacuous lane witness. No new executable example was introduced by this research.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Historical fixed active app list and pilot row-neighborhood snapshot | Current installed lane inventory plus Xref over the installed graph, followed by exact-source binding | Current core/floor receipt in `01-GRAPH-OBSERVATIONS.json`; full receipts retained under `_build/phase1-research-receipts/` | Use current lane graph as authority; historical metadata is a research lead only. |

**Deprecated/outdated:** the 13,953-token four-identity pilot is incomplete for callback context and is not a fit proof.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The 31,000 reserve is conservative enough for each isolated plan context. | Source and Context Fit | If underestimated, that plan must stop and be re-sized or re-sliced before exceeding 100,000 tokens. |
| A2 | The known six-source set is sufficient after full graph and dynamic-caller reconciliation. | Exact Source Inventory / Fit | New callers or sinks add source files and may invalidate fit. |
| A3 | Three serial plans can each remain within roughly three working days. | Effort basis | Existing sibling durations vary; actual work may exceed the bound and require stopping/replanning. |

## Resolved Planning Questions

1. **RESOLVED — What source set and stop govern execution-time semantic review?**
   - Current exact-lane graphs select the two EX-010 endpoints per lane and their `inets_trace` delegates. Research identifies the complete known connected file set as `inets.erl`, `inets_trace.erl` and `dbg.erl` per lane, bounded at the caller-supplied callback and fixed native trace-port boundaries described above. No additional required source file is currently identified. Zero direct incoming edges does not prove absence of dynamic callers.
   - The pre-execution decision is to allocate these three full exact files independently to each lane plan, with all reserves intact, then integrate only their reviewed hash-scoped findings. This uses the existing discretion and source-expansion stop in D-06/D-07; it changes no owner scope or limit.
   - Semantic dispositions and witness results are execution deliverables, not unanswered planning choices. They are not certified here. If full review discovers a necessary source beyond the allocation or an unsupported boundary, the affected work stops before further source consumption or disposition; source identities, context and effort must be re-sized and reviewed first. No truncation, silent expansion or automatic new phase is permitted.

There is no remaining owner/design question blocking this plan set. The explicit execution proof obligations and falsifiable assumptions remain in force; a resolved planning decision is not a claim that execution has passed.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Core Elixir/OTP | Core graph and tests | ✓ | Elixir 1.20.4 / OTP 29.1.2 | — |
| Floor Elixir/OTP | Floor graph and tests | ✓ | Elixir 1.18.5 / OTP 27.3.4.9 | — |
| Project Mix dependencies | Full project graph and contract test | Pending in reviewed checkout during initial attempt; orchestrator has since staged an offline source copy in the worktree | — | Use the orchestrator-managed isolated copy; do not fetch packages. |

**Missing dependencies with no fallback:** none. The orchestrator staged local dependency sources and the current core/floor graph contract passed in the isolated build environment.

## Validation Architecture

Nyquist validation is enabled. `[VERIFIED: .planning/config.json:25]` Verbatim: `"nyquist_validation": true,`; security enforcement is enabled. `[VERIFIED: .planning/config.json:49]` Verbatim: `"security_enforcement": true,`.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | ExUnit (existing project test suite) |
| Config file | Existing `mix.exs` and `.formatter.exs`; no new test framework needed |
| Quick run command | `bin/lane core test test/contract/tier_sweep_test.exs:5234` and corresponding floor lane |
| Full suite command | `bin/lane core test --warnings-as-errors test/contract/banned_calls_test.exs test/contract/tier_sweep_test.exs`; repeat on floor |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| GRC-01 | Exact per-lane source identity, complete current matcher set, selected/remainder equality, bounded connected scope | static graph + source contract | Existing tier-sweep graph test and new EX-010 row contract, run per lane | Existing graph receipt; EX-010 semantic completion evidence pending |
| GRC-02 | Individual non-vacuous witnesses and meaningful positive/negative static controls; no audited API calls | contract / compile-only fixture | Existing `banned_calls_test.exs` and tier-sweep contracts, run per lane | Existing files; EX-010 witness completeness pending |
| GRC-03 | Preserve row identities, outside-row dispositions, collision stop and aggregate gates | contract + review | Existing audit tables and source-citation checks, run per lane | Current graph partition recorded; delivered semantic and witness contracts pending |

### Sampling Rate

- **Per task commit:** focused changed contract tests on the affected exact lane.
- **Per plan review:** full banned-call and tier-sweep contract files on both lanes as applicable.
- **Phase gate:** required local validation, independent review, green hosted candidate CI, and merged PR before phase completion.

### Wave 0 Gaps

- [ ] Bind verified `inets_trace.erl` exact bytes for both lanes into the approved source archive.
- [ ] Complete source-backed EX-010 dispositions and lane witnesses; the graph receipt and research fit do not provide these.

## Security Domain

Security enforcement is enabled and no security threshold changes are in scope. This phase provides static evidence only; it cannot close SEC-01 runtime/property proof.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No authentication feature in scope |
| V3 Session Management | no | No session feature in scope |
| V4 Access Control | yes | Preserve guard ownership and stop on an actual production `lib/` collision; do not auto-allowlist |
| V5 Input Validation | yes | Source-review service and destination validation; compile-only static witnesses |
| V6 Cryptography | no | No cryptographic feature in scope |

### Known Threat Patterns for static OTP guard review

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Caller-controlled callback receives trace events | Elevation of Privilege | Trace exact callback invocation path statically; never invoke callback during the audit; do not claim caller-supplied function semantics from OTP source alone. |
| Dynamic caller not present in direct Xref edge set | Spoofing / Tampering | Reconcile full installed graph and document the dynamic-call limitation; zero direct callers is not proof of absence. |
| Guard catches valid production call | Denial of Service | Preserve benign controls and stop at the actual collision for owner-directed disposition. |

## Sources

### Primary (HIGH confidence)

- `test/support/sweep_evidence.ex` — exact lane refs, archive hash and existing source resolution path.
- `test/support/installed_otp.ex` and `test/contract/tier_sweep_test.exs` — installed source/BEAM inventory, Xref graph, exact-lane contract patterns.
- `test/fixtures/guards/exact_sources.tar.gz` — approved manifest and exact core/floor `inets.erl` and `dbg.erl` source identities.
- Exact local OTP 29.1.2 and OTP 27.3.4.9 installed source trees — SHA-256 and byte-size comparisons for all six known source identities.
- Static OTP Xref query on every installed OTP application `ebin` directory — current OTP-only endpoint and direct-edge observation; not the complete project graph.

### Secondary (MEDIUM confidence)

- `.planning/phases/01-bounded-guard-continuation/01-CANDIDATE-EVIDENCE.json` — narrow provenance snapshot of the earlier four-source pilot and its tokenizer observation.
- Preserved prior `SOURCE-REVIEW-UNITS` metadata — historical `dbg.erl` full-file token observations; source hashes were independently compared to current exact bytes.
- `.planning/intent/sources/2026-11-11-05-select-inets-tracing-scope.md` and `2026-11-10-01-rolling-allocation-for-bounded-work.md` — scope and inherited limits.

### Tertiary (LOW confidence)

- Token reserve and elapsed effort envelope in this report are explicit assumptions, not measurements or approval.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — pinned lane identities were checked against in-repo source and installed runtimes.
- Architecture: MEDIUM — current graph identifies selected membership and static delegates; exact-source path bounds the callback/destination boundary, while dynamic callers and final semantic dispositions remain for execution review.
- Pitfalls: HIGH — current source and project constraints establish the callback boundary, archive gap and fit gate.

**Research date:** 2026-11-11  
**Valid until:** Revalidate source hashes/archive binding and graph against exact pinned lanes before execution; no fixed calendar expiry while this phase remains in planning.
