# Phase 2: Bounded ASN.1 RTT guard evidence - Research

**Researched:** 2026-11-12  
**Domain:** Static source evidence and lane-specific contract guards for OTP ASN.1 functions  
**Confidence:** MEDIUM — membership, pinned lane identities, static caller closure, per-task context fit, and itemized effort ranges are recorded; active effort for this exact slice is still an estimate based on completed comparable work.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Implementation Decisions

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

### the agent's Discretion
Choose evidence-file organization, helper boundaries, conservative task grouping, and the cheapest meaningful automated proofs within the limits above. Do not change the selected set, lower a gate, infer a runtime verdict, or select follow-up work.

### Deferred Ideas (OUT OF SCOPE)
- The other 174 original EX-107 row members remain outside this slice. EX-011 and other rows sharing the same files keep their existing owners and statuses.
- The full guard aggregate and installed-wide remainder remain open. Walking Skeleton remains blocked until aggregate-scoped proof passes.
- SEC-01 remains Pending with Controls and the first bundle's first local slot; allocate its global integer only when that milestone activates.
- The acknowledged v0.2 deferrals, scheduled observations, clearance C1–C10, and other carried safety/product obligations retain their existing owners.
- No automatic next guard increment, new product milestone, brand implementation, release, or deployment is selected.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GRC-04 | Before executable phase planning, revalidate complete current EX-107 membership, exact selection/complement and lane source identities; preserve source/context/task/plan/effort bounds. | Context records live/archive equality, 177 matches per lane, exact selected three, 174 full-row complement, 161 historical-subset remainder, and four lane source identities. Remaining caller/context/effort gates are documented below. |
| GRC-05 | Record exact source spans, direct caller path, source-backed disposition and individual non-vacuous positive/negative control per function/lane; use byte-only literal-table proof for `code/0`; never invoke audited APIs. | Reuse source/archive resolver, generator-dispatch records and existing code/0 byte scanner; plans must add function-specific lane evidence and controls without invoking audited functions. |
| GRC-06 | Deliver the selected slice under existing reviewed-candidate, exact-head and CI gates while preserving full EX-107 identity, partitions and all safety stops. | ADR 0021 and project delivery policy define contract separation, review and merged-green receipt requirements; completion stays scoped to this slice. |
</phase_requirements>

## Summary

Treat this as a bounded, contract-only source review over three exported functions on two fixed OTP lanes. The approved evidence archive already contains the exact `asn1ct_rtt.erl` and direct caller `asn1ct_func.erl` bytes for both lanes; prior source records identify the direct routes `need/1 → assert_defined/1`, `generate/1 → code/0`, and `handle_cast/2 → pull_in_deps/2 → dependencies/1`. These prior findings are caller-path leads only; they do not satisfy this phase's source spans, dispositions, or individual control requirements. `[CITED: .planning/phases/02-bounded-asn-1-rtt-guard-evidence/02-CONTEXT.md; test/support/sweep_evidence.ex:755-863, 985-1053]`

**Primary recommendation:** use five bounded plans in four dependency waves: core and floor evidence run in parallel; cross-lane membership/control integration follows; independent review and accepted fixes follow that; full local checks and a local readiness handoff close the plan sequence. After all plan and summary commits, normal phase verification/ship binds final-head checks, reviewed candidate PR, hosted CI, and merge/main receipts. Keep all source reads exact-hash scoped. Keep the full `code/0` bytes outside the model context and apply the existing byte-only grammar check. Treat execution and delivery as a static contract proof, with the existing review, security, exact-head and hosted CI gates intact. `[CITED: .planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md; docs/adr/0021-delivery-rules.md]`

The appended ledger reconciles the existing full installed-lane Xref records with direct-call source searches and binds the four exact target/caller files to the approved lane archive. It records fresh per-task source/context counts and an itemized effort estimate based on the larger completed ASN.1 slice. The three pre-plan gates pass for this bounded static scope. The revised plan waves keep the conservative critical-path range below the ADR 0021 phase target; any new source, identity mismatch, context growth, or projected overrun still requires a bounded remedy inside the approved scope. `[CITED: Pre-plan Gate Ledger; 02-CONTEXT.md D-03/D-07]`

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| OTP export/source identity and EX-107 membership | API / Backend (contract support) | — | Existing lane inventory, archive resolver and contract tests own exact source binding and row partition evidence. `[CITED: test/support/installed_otp.ex; test/support/sweep_evidence.ex; test/contract/tier_sweep_test.exs]` |
| Static guard dispositions and controls | API / Backend (contract tests) | — | This slice changes contract evidence only; production implementation remains out of scope. `[CITED: 02-CONTEXT.md D-08; docs/adr/0021-delivery-rules.md]` |
| Exact full-table shape validation | API / Backend (byte-only test support) | — | `code/0` literal data is checked as bytes without evaluation or inclusion in the prompt. `[CITED: test/contract/tier_sweep_test.exs:109-137, 274-302]` |

## Project Constraints (from AGENTS.md)

- Follow `CLAUDE.md`; preserve intent → ADR → requirements precedence and retain INT/ADR citations on requirements.
- Never lower quality gates. No runtime evaluation or input-derived atoms (ADR 0004).
- Do not add dependencies without a new ADR; adopters must not need Node.
- Every phase delivery ends in a merged green PR with an actual CI receipt link; local `act` augments, not replaces, hosted CI.
- Contract tests must not be edited in the same PR as the implementation they guard (ADR 0021).
- Preserve existing review/security/verification gates and use the project planning preflight before planning-state mutations.
- Preserve recovery worktrees and artifacts; do not reset, stash, clean, or switch the preserved checkout.
- End the workflow with a concrete next command and its purpose; stop at the approved phase boundary.

## Standard Stack

### Core

| Library/tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Elixir / OTP core | Elixir 1.20.4 / OTP 29.1.2 | Core installed-lane inventory and contracts | Pinned project core lane. `[VERIFIED: test/support/sweep_evidence.ex:17-24]` Verbatim: `"core" => %{` and `"otp" => ["29.1.2", "d199a49a01a2079afb6f2c5c9ae047cd4555e68d"]`. |
| Elixir / OTP floor | Elixir 1.18.5 / OTP 27.3.4.9 | Independent compatibility-lane inventory and contracts | Pinned project floor lane. `[VERIFIED: test/support/sweep_evidence.ex:21-24]` Verbatim: `"floor" => %{` and `"otp" => ["27.3.4.9", "4aa809ae4eb4a20ad89c23837376acf179877f39"]`. |
| `Fablebook.Test.SweepEvidence` | In-repo | Archive lock, source identity and exact citation resolution | Existing approved offline resolver. `[CITED: test/support/sweep_evidence.ex]` |
| ExUnit / Credo contract checks | In-repo | Byte-shape, static guard and compile-only controls | Existing enforcement surface; no new dependency or CI lane. `[CITED: test/contract/tier_sweep_test.exs; test/contract/banned_calls_test.exs; credo/checks/banned_calls.ex]` |

### Supporting

| Tool | Purpose | When to Use |
|------|---------|-------------|
| `Fablebook.Test.InstalledOtp` | Independent lane export inventory and Xref helpers | Recompute exact live membership and relevant graph evidence; graph output is not semantic disposition. `[CITED: test/support/installed_otp.ex]` |
| Existing byte-only `code/0` checker | Validate the full literal data shape without parsing/evaluating payloads | Use outside the prompt, preserve lane-specific boundaries and controls. `[CITED: test/contract/tier_sweep_test.exs:109-137, 274-302]` |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Existing resolver, Xref and contract helpers | New analysis framework or package | Prohibited by scope; adds dependency/authority and no needed capability. `[CITED: 02-CONTEXT.md D-08]` |
| Exact lane archive bytes | Opposite lane or fresh network source | Does not prove pinned identity and violates approved source provenance. `[CITED: 02-CONTEXT.md discussion-time source identities and canonical refs]` |

**Installation:** None. This phase adds no packages. `[CITED: 02-CONTEXT.md D-08]`

## Package Legitimacy Audit

Not applicable: no external package installation is in scope. `[CITED: 02-CONTEXT.md D-08]`

## Architecture Patterns

### System Architecture Diagram

```text
Pinned core/floor installed OTP trees
  → independently inventory exported asn1ct_* MFAs
  → compare complete EX-107 lane sets to the archived 177-MFA row
  → bind exact lane source from approved archive
  → inspect selected target spans and direct asn1ct_func caller paths
  → byte-only check full code/0 literal table outside prompt
  → record per-function/lane disposition and individual controls
  → contract validation, review/security/exact-head checks, candidate CI
  → merge and record hosted main CI receipt
```

The distinct historical and phase partitions must remain visible: the selected three leave 174 members in the complete row, while the historical 164-member pending subset leaves 161 after this selection. `[CITED: 02-CONTEXT.md D-01/D-02 and discussion-time membership check]`

### Recommended Project Structure

Keep `test/support/sweep_evidence.ex` as the read-only approved archive resolver and use `test/support/installed_otp.ex` for inventory/Xref helpers without modification. Core owns `test/support/asn1_rtt_core_evidence.ex` and `test/contract/asn1_rtt_core_guard_test.exs`; floor owns separate `test/support/asn1_rtt_floor_evidence.ex` and `test/contract/asn1_rtt_floor_guard_test.exs`; Plan 02-03 owns integration-only evidence assertions inline in `test/contract/asn1_rtt_integration_test.exs`. This preserves lane isolation and keeps the total new code outputs at five. `[CITED: 02-CONTEXT.md D-07/D-08 and owner-selected remedy; 02-PATTERNS.md]`

### Pattern 1: Exact lane source with byte-only table proof

**What:** Resolve complete exact source by archive identity; record target spans and caller citations; scan the complete `code/0` literal body as bytes against its anchored grammar without parsing payloads or invoking the function. `[CITED: test/contract/tier_sweep_test.exs:109-137, 274-302; .planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-EX-107-ASN1-GENERATOR-DISPATCH-LEAF-SIZING.md]`

**When to use:** For both pinned lanes, with lane-specific function boundaries and exact source hash. The existing table boundary is core lines 542–1055 and floor lines 534–1039; bytes and prior token observations are historical sizing data, not fresh tokenization. `[CITED: 01.1.1.1-EX-107-ASN1-GENERATOR-DISPATCH-LEAF-SIZING.md]`

**Example:**

The existing contract contains these exact operations: `source = SweepEvidence.resolve!(evidence, "asn1/src/asn1ct_rtt.erl:542")` and `assert Regex.match?(grammar, body)`. `[VERIFIED: test/contract/tier_sweep_test.exs:111,116]` Verbatim: `source = SweepEvidence.resolve!(evidence, "asn1/src/asn1ct_rtt.erl:542")`; `assert Regex.match?(grammar, body)`.

```elixir
source = SweepEvidence.resolve!(evidence, "asn1/src/asn1ct_rtt.erl:542")
body = rtt_body!(File.read!(source.path))
assert Regex.match?(rtt_grammar(), body)
```

This is a source-pattern sketch from the existing contract. It is illustrative and does not substitute for reading the source-of-truth lines or for an execution result. `[CITED: test/contract/tier_sweep_test.exs:109-137]`

### Anti-Patterns to Avoid

- Inferring disposition from function/module names, source hashes, Xref alone, or green CI. `[CITED: 02-CONTEXT.md D-04/D-05; .planning/REQUIREMENTS.md GRC-05]`
- Replacing the phase's exact three-MFA set with the historical 13-MFA set or confusing the 174 and 161 complements. `[CITED: 02-CONTEXT.md D-01/D-02]`
- Pasting or tokenizing the huge `code/0` payload inside a planning prompt; use the complete byte-only check and stop if its grammar fails. `[CITED: 01.1.1.1-EX-107-ASN1-GENERATOR-DISPATCH-LEAF-SIZING.md]`
- Invoking audited OTP functions, fixture functions, callbacks, or atom sinks. `[CITED: 02-CONTEXT.md D-05; docs/adr/0004-no-eval-no-new-atoms.md]`
- Claiming runtime behavior, dynamic caller absence, native internals, or SEC-01 safety from static evidence. `[CITED: 02-CONTEXT.md D-05]`

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Lane inventory and Xref | Parallel inventory/graph tool | `Fablebook.Test.InstalledOtp` | Existing project contract surface and lane helpers. |
| Exact source resolution | Network fetch or local-path-only citation | `Fablebook.Test.SweepEvidence` and approved archive | Locks bytes and provenance to each pinned lane. |
| Full literal table interpretation | Erlang parser, evaluation or prompt inclusion | Existing bounded byte-only grammar check | Prevents payload execution/parsing and keeps the table out of context. |
| New guard test framework | New package/generic audit framework | Existing ExUnit and Credo contracts | No new dependency/framework is authorized. |

**Key insight:** source identity, source semantics, and control effectiveness are separate evidence obligations. A hash proves which bytes were reviewed; it does not determine their disposition or show that an individual guard catches and rejects the intended case. `[CITED: 02-CONTEXT.md D-04; docs/adr/0014-testing-strategy.md]`

## Planning Fit and Effort Gate

The five plans retain two tasks each. The selected disjoint outputs preserve independent Wave 1 core/floor work; integration follows in Wave 2, review/correction in Wave 3, then local checks/readiness in Wave 4. Normal phase verification/ship follows after all plan and summary commits to bind the final PR head and hosted receipts. Including that lifecycle, the estimated 1.75–2.75-working-day critical path remains within ADR 0021's roughly three-day target; summed person-effort remains 2.25–3.5 days. Treat these as bounded estimates; stop and record a concrete remedy if actual projection crosses three working days. `[CITED: 02-01..02-05-PLAN.md; docs/adr/0021-delivery-rules.md]`

| Plan | Wave | Grouping | Task context ceilings | Plan estimate | Effort |
|------|------|----------|-----------------------|---------------|--------|
| 02-01 | 1 | Core lane evidence and individual controls | 78,769 / 71,353 tokens | 75,061 tokens | 0.5–0.75 working day |
| 02-02 | 1 | Floor lane evidence and individual controls | 77,566 / 70,982 tokens | 74,274 tokens | 0.5–0.75 working day |
| 02-03 | 2 | Exact cross-lane membership, partitions and controls | 73,000 / 75,000 tokens | 74,000 tokens | 0.5–0.75 working day |
| 02-04 | 3 | Independent review of five outputs and bounded corrections | 78,000 / 78,000 tokens | 78,000 tokens | 0.25–0.5 working day |
| 02-05 | 4 | Full local checks and readiness handoff | 70,000 / 68,000 tokens | 69,000 tokens | 0.375–0.5 working day |

`code/0` bytes remain outside prompt context. Task ceilings include project/executor context, relevant excerpts, and bounded outputs; recount before any source or output grows. `[CITED: 02-CONTEXT.md D-03/D-07; 02-RESEARCH.md Gate 2 and Gate 3 ledgers; docs/adr/0021-delivery-rules.md]`

## Pre-plan Gate Ledger

**Status:** All three pre-plan gates PASS for the pinned lanes and approved scope: connected-source closure is complete for the recorded static Xref/source set; every task and plan estimate is below the 80,000-token planning target (80% of the 100,000 hard limit); and the itemized four-wave critical path including phase verification/ship is estimated at 1.75–2.75 working days under ADR 0021. This relies on running core and floor work concurrently in Wave 1 and remains an estimate, not a guarantee. Dynamic callers, native internals, runtime behavior, and SEC-01 remain explicitly unproven/outstanding.

### Gate 1 — Connected-source closure: PASS (static, scoped)

The lane inventories in `01.1.1.2-INVENTORY-core.jsonl` and `01.1.1.2-INVENTORY-floor.jsonl` are complete installed-OTP inventory records for the pinned versions: core Elixir 1.20.4 / OTP 29.1.2 and floor Elixir 1.18.5 / OTP 27.3.4.9. Filtering their `active_edge` rows to `callee_module = asn1ct_rtt` and each selected `callee_function` yields exactly one incoming edge per target on each lane. This matches a fresh recursive source search across each installed ASN.1 source directory and the prior lane-specific caller citations in `sweep_evidence.ex`. The source search found no additional literal remote call sites for these three functions. `[CITED: .planning/milestones/v0.1-phases/01.1.1.2-installed-otp-inventory-and-common-test-guard-slice/01.1.1.2-INVENTORY-core.jsonl:1,27845,27880,27883; ...INVENTORY-floor.jsonl:1,25699,25734,25737; test/support/sweep_evidence.ex:788-863, 982-1055]`

| Lane | Selected target | Xref incoming edge | Caller file/function and exact installed source span | Target source identity |
|------|----------------|--------------------|------------------------------------------------------|-----------------------|
| Core | `asn1ct_rtt:assert_defined/1` | `asn1ct_func:need/1` | `asn1/src/asn1ct_func.erl`, `need/1`, lines 48–54; remote call line 54 | `asn1/src/asn1ct_rtt.erl`, 135654 bytes, SHA-256 `dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374` |
| Core | `asn1ct_rtt:code/0` | `asn1ct_func:generate/1` | `asn1/src/asn1ct_func.erl`, `generate/1`, lines 64–72; remote call line 69 | Same core RTT identity above |
| Core | `asn1ct_rtt:dependencies/1` | `asn1ct_func:pull_in_deps/2` | `asn1/src/asn1ct_func.erl`, `handle_cast/2` → `pull_in_deps/2`, lines 95–98 and 130–138; remote call line 137 | Same core RTT identity above |
| Floor | `asn1ct_rtt:assert_defined/1` | `asn1ct_func:need/1` | `asn1/src/asn1ct_func.erl`, `need/1`, lines 44–49; remote call line 49 | `asn1/src/asn1ct_rtt.erl`, 134820 bytes, SHA-256 `828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d` |
| Floor | `asn1ct_rtt:code/0` | `asn1ct_func:generate/1` | `asn1/src/asn1ct_func.erl`, `generate/1`, lines 59–67; remote call line 64 | Same floor RTT identity above |
| Floor | `asn1ct_rtt:dependencies/1` | `asn1ct_func:pull_in_deps/2` | `asn1/src/asn1ct_func.erl`, `handle_cast/2` → `pull_in_deps/2`, lines 90–93 and 125–133; remote call line 132 | Same floor RTT identity above |

Required exact source files are four lane-specific files total: core `asn1/src/asn1ct_rtt.erl` and `asn1/src/asn1ct_func.erl`; floor equivalents. The exact RTT and caller files match the approved archive identities by the checked installed SHA-256 and byte sizes. `[VERIFIED: test/support/sweep_evidence.ex:17-24, 242-253, 728-729, 910-915, 1097-1098, 1182-1183]` Verbatim source tuples: `{"core", "asn1/src/asn1ct_rtt.erl"} => {135_654, "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"}`, `{"core", "asn1/src/asn1ct_func.erl", 4465, "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"}`, `{"floor", "asn1/src/asn1ct_rtt.erl", 134_820, "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"}`, and `{"asn1/src/asn1ct_func.erl", 4347, "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"}`.

Exact target spans are complete function bodies: core `assert_defined/1` lines 17–120, `dependencies/1` lines 122–539, and `code/0` lines 541–1055; floor `assert_defined/1` lines 17–120, `dependencies/1` lines 122–531, and `code/0` lines 533–1039. The `code/0` literal payload is consumed by the full anchored byte-only check outside prompt context. Static Xref and literal-source searches do not find dynamic calls. Dynamic callers, generated call paths, runtime behavior, native internals, and SEC-01 safety remain unproven. No audited function, callback, atom sink, or generated code was invoked. `[CITED: 01.1.1.1-EX-107-ASN1-GENERATOR-DISPATCH-LEAF-SIZING.md; 02-CONTEXT.md D-04/D-05]`

### Gate 2 — Per-task context sizing: PASS (80% target)

Fresh source counts continue to use the project-precedent method: `tiktoken 0.14.0`, `o200k_base.encode_ordinary`, UTF-8 text, inclusive line spans concatenated with existing line endings and no added separators. Core RTT lines 17–540 measured 6,673 tokens; selected complete caller functions measured 283 tokens (6,956 combined). Floor RTT lines 17–532 measured 6,571 and selected caller functions 282 (6,853 combined). The `code/0` literal payload is never included in prompt context and is processed offline by the existing byte-only checker.

The three generated phase references remain within their shared 16,000-token ceiling. The shared fixed-context baseline remains 71,012 tokens before task-specific measured sources and bounded outputs: 23,863 across applicable project/phase instructions and records; up to 16,000 across the three generated phase references; 11,649 for GSD executor instructions; and the inherited 19,500 reserve. Each plan's selective context omits irrelevant generated references and bounds the evidence/output excerpts, which yields the task ceilings listed below. A task that requires more than its listed excerpts must recount; do not truncate evidence to fit. The five-source cap counts implementation/support/test source files, including created-then-reread contract files; planning documents and ADRs are fixed context rather than exact implementation source files.

| Proposed plan/task | Exact implementation/support/test source files read (rereads included) | Count | Measured/capped task additions | Full task context ceiling | Result |
|--------------------|---------------------------------------------------------------|-------|----------------------------|----------------------------|--------|
| 02-01 / Task 1: core assert-defined source-to-contract path | Core RTT; core caller; read-only resolver; create/reread core evidence module and core contract test | 5 | 6,956 target/caller tokens; 3,032 evidence tokens; 769 test-pattern excerpt from PATTERNS; bounded output | 78,769 | PASS |
| 02-01 / Task 2: core `code/0` and `dependencies/1` evidence/controls | Core RTT bytes offline; core caller; read-only resolver; core evidence module; core contract test | 5 | Table excluded from prompt; 769 checker-pattern tokens; 572 resolver/identity tokens; 2,000 output allowance | 71,353 | PASS |
| 02-02 / Task 1: floor assert-defined source-to-contract path | Floor RTT; floor caller; read-only resolver; create/reread floor evidence module and floor contract test | 5 | 6,853 target/caller tokens; 2,303 floor evidence tokens; 398 test-pattern excerpt from PATTERNS; bounded output | 77,566 | PASS |
| 02-02 / Task 2: floor `code/0` and `dependencies/1` evidence/controls | Floor RTT bytes offline; floor caller; read-only resolver; floor evidence module; floor contract test | 5 | Table excluded from prompt; 398 checker-pattern tokens; 572 resolver/identity tokens; 2,000 output allowance | 70,982 | PASS |
| 02-03 / Task 1: exact cross-lane selection and partitions | Read-only resolver; core evidence module; floor evidence module; `tier_sweep_test.exs` historical 13-MFA constant; create/reread integration contract | 5 | Up to 4,000 compact lane inventory; 4,000 structured lane evidence; 4,000 Gate 1 summary; 1,000 historical membership; 2,000 bounded output | 73,000 | PASS |
| 02-03 / Task 2: cross-lane controls and security boundaries | Core evidence module; floor evidence module; integration contract | 3 | Up to 6,000 structured lane findings; 5,000 contract excerpts; 3,000 control-pattern excerpt; 2,000 bounded output | 75,000 | PASS |
| 02-04 / Task 1: independent review and finding classification | Core evidence module; core contract; floor evidence module; floor contract; integration contract | 5 | Five bounded output excerpts; security context; review findings | 78,000 | PASS |
| 02-04 / Task 2: accepted corrections and focused validation | Same five evidence/test outputs; review artifact is planning documentation | 5 | Findings, five bounded output excerpts, affected-lane test output | 78,000 | PASS |
| 02-05 / Task 1: full core/floor checks and local readiness evidence | No exact source reread; use scoped commands and prior findings | 0 | 2,000 lane/tool setup; 2,000 command excerpts; 10,000 bounded local/act output | 70,000 | PASS |
| 02-05 / Task 2: local readiness report and final-head delivery handoff | No exact source reread; consume Task 1 report and review disposition | 0 | Up to 5,000 candidate/review evidence; 2,000 readiness report; 5,000 single correction reserve | 68,000 | PASS |

Task ceilings peak at 78,769 tokens and plan estimates are at or below 78,000. Every task explicitly counts created-output rereads and stays at or below five exact source files; each plan has two tasks and the phase has five plans. The resolver is read-only, core and floor do not read one another's outputs, and integration reads both lane evidence modules only after Wave 1. Recount before any growth; never truncate required evidence. Historical literal-body counts (37,666 core / 37,387 floor) remain offline only. `[CITED: 02-CONTEXT.md D-03/D-07; owner-selected remedy; prior exact-span sizing artifact]`

### Gate 3 — Itemized effort: PASS (bounded phase critical path)

Comparable completed work remains the earlier larger ASN.1 generator-dispatch slice: core source/evidence took 23 elapsed minutes across three tasks; floor took 27 minutes; integration Task 1 took 39–42 minutes and its CI/receipt interval 49 minutes. That work reviewed eleven selected functions and more source than this slice. Active independent review time remains unmeasured, so the ranges below reserve bounded review and correction time and must be compared with actual elapsed intervals during execution. `[CITED: .planning/milestones/v0.1-phases/01.1.1.18-bound-asn-1-generator-dispatch-exclusions/01.1.1.18-01-SUMMARY.md; ...18-02-SUMMARY.md; ...18-03-SUMMARY.md; ...18-02-PLAN.md:65]`

| Plan/task | Effort estimate | Basis and reserve |
|------------|-----------------|-------------------|
| 02-01 Task 1: core source citation and first focused contract path | 2–3 hours | Comparable core lane review; includes evidence entry and focused check. |
| 02-01 Task 2: remaining core spans, byte-only table and controls | 2–3 hours | Existing byte grammar and malformed-shape controls; bounded adaptation. |
| **Plan 02-01 total** | **0.5–0.75 working day** | Two sequential tasks; pinned source identities and existing resolver. |
| 02-02 Task 1: floor source citation and first focused contract path | 2–3 hours | Comparable floor lane review; exact archive identity and focused check. |
| 02-02 Task 2: remaining floor spans, byte-only table and controls | 2–3 hours | Existing floor byte grammar and malformed-shape controls; bounded adaptation. |
| **Plan 02-02 total** | **0.5–0.75 working day** | Runs in parallel with Plan 02-01 in Wave 1. |
| 02-03 Task 1: exact full-row and historical membership assertions | 2–3 hours | Prior integration reconciliation took 39–42 minutes; preserve exact membership. |
| 02-03 Task 2: cross-lane control/security reconciliation | 2–3 hours | Bounded structured findings; no new source unless stopped and resized. |
| **Plan 02-03 total** | **0.5–0.75 working day** | Sequential after both lane plans. |
| 02-04 Task 1: independent contract/security review | 1–2 hours | High-severity independent review; findings only, no overlapping fixes. |
| 02-04 Task 2: accepted corrections and focused retests | 1–2 hours | One bounded correction/retest pass; no-source expansion stop. |
| **Plan 02-04 total** | **0.25–0.5 working day** | Review all five bounded outputs, correct accepted findings, and retain lane ownership. |
| 02-05 Task 1: full local core/floor checks and act attempt | 2–3 hours | Existing test lanes; bounded output; local act supplements hosted receipts. |
| 02-05 Task 2: local readiness report and delivery handoff | 1 hour | Reconcile local findings and review disposition; no PR or hosted output. |
| **Plan 02-05 total** | **0.375–0.5 working day** | Includes full local checks and readiness report. |
| Phase verification/ship: final-head checks and hosted receipts | 1–2 hours | Existing exact-head PR and hosted CI lifecycle; prior candidate receipt interval was 49 minutes. |
| **Summed person-effort** | **2.25–3.5 working days** | Sum of all plan work, counting parallel Wave 1 work separately. |
| **Elapsed critical path** | **1.75–2.75 working days** | `max(Plan 02-01, 02-02) + 02-03 + 02-04 + 02-05 + phase verification/ship`; fits ADR 0021's roughly three-day phase target. |

The effort gate remains estimated within the phase target because the selected disjoint outputs preserve concurrent Wave 1 core/floor work and final hosted delivery remains bounded in the phase verification/ship lifecycle. Plan 02-04's expanded five-output review remains within its 0.25–0.5-day reserve; the end-to-end critical path including verification/ship is 1.75–2.75 working days and summed person-effort remains 2.25–3.5 days. Do not automatically split into another phase. Record actual work and hosted-wait intervals; stop and record a concrete bounded remedy if the critical path projection exceeds three working days. `[ASSUMED: forward estimate informed by comparable completed work above; CITED: docs/adr/0021-delivery-rules.md]`

**Wave order:** Wave 1 parallel core/floor; Wave 2 integration; Wave 3 review/correction; Wave 4 local checks/readiness report; normal phase verification/ship then binds the final PR head and hosted receipts after plan summaries are committed. `code/0` bytes remain outside prompt context. Final independent review passed. `[CITED: 02-CONTEXT.md D-03/D-07; owner-selected remedy; 02-PLAN-REVIEW.md; docs/adr/0021-delivery-rules.md]`

## Common Pitfalls

### Pitfall 1: Merge the two remainder counts

**What goes wrong:** A plan preserves 174 members but loses the historical 161 still-pending subset (or treats 161 as the complete-row remainder).  
**Why it happens:** The old 13-member selection and Phase 2 three-member selection partition the same 177-member row differently.  
**How to avoid:** Assert complete row equality, exact selected-three membership, 174 full-row complement, and the historical 13/164 partition with 161 still pending as separate checks.  
**Warning signs:** A report contains only one remainder count or calls 161 the EX-107 remainder. `[CITED: 02-CONTEXT.md D-01/D-02]`

### Pitfall 2: Count the literal data in model context

**What goes wrong:** The 100,000-token planning bound is exceeded or source is truncated to fit.  
**Why it happens:** The whole-file token size includes a very large fixed table.  
**How to avoid:** Run the exact full-body byte-only grammar check outside the prompt; carry its identity, full boundaries, row count and control outcomes into structured evidence. Recompute fit if the grammar or source hash changes.  
**Warning signs:** The table is pasted, evaluated, parsed into terms, or treated as part of the prompt budget. `[CITED: 01.1.1.1-EX-107-ASN1-GENERATOR-DISPATCH-LEAF-SIZING.md]`

### Pitfall 3: Treat a source lead as final caller closure

**What goes wrong:** Prior generator-dispatch notes stand in for current direct caller/source evidence.  
**Why it happens:** Prior records bind `asn1ct_func.erl` and `asn1ct_rtt.erl` but remain `semantic_status: :pending` and cover different selected functions.  
**How to avoid:** Reconcile all direct edges on both lanes for exactly the selected three functions and cite exact spans for the current phase. New connected source triggers re-sizing.  
**Warning signs:** Source hashes or graph edges are presented as dispositions. `[CITED: test/support/sweep_evidence.ex:710-863, 910-1053; 02-CONTEXT.md discussion-time source identity note]`

### Pitfall 4: Infer runtime safety or dynamic-caller absence

**What goes wrong:** Static review is overstated as runtime or SEC-01 proof.  
**Why it happens:** Static graphs only enumerate calls visible to the selected analysis.  
**How to avoid:** State the static scope and unproven runtime/dynamic/native limits on each disposition. Never invoke the audited functions, callbacks, or sinks.  
**Warning signs:** Claims use “safe at runtime,” “no dynamic callers,” or close SEC-01 based on this slice. `[CITED: 02-CONTEXT.md D-05; docs/adr/0004-no-eval-no-new-atoms.md]`

## Code Examples

### Resolve a source citation and assert byte-only table shape

See the exact resolver and grammar assertion in Pattern 1 above. The existing test also checks exact row count and rejects altered computed payload, expression-in-MFA, trailing-code, and truncation shapes. Do not interpret the embedded generated-code strings or call `asn1ct_rtt:code/0`. `[CITED: test/contract/tier_sweep_test.exs:109-137, 274-302]`

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Historical 13-MFA EX-107 selection treated as current | Preserve as a historical partition; independently select exactly the new three MFAs | Phase 2 context, 2026-11-12 | Keep 177 full set, 174 Phase 2 complement and distinct historical 161 remainder. `[CITED: 02-CONTEXT.md D-01/D-02]` |
| Treat prior source identity/caller notes as completion | Reuse only scoped leads; add exact current spans, dispositions and individual controls | Phase 2 context, 2026-11-12 | Hash and previous source notes cannot substitute for GRC-05 evidence. `[CITED: 02-CONTEXT.md D-03/D-04]` |

**Deprecated/outdated:** None asserted; this phase reuses project-owned contract patterns and does not introduce packages. `[CITED: 02-CONTEXT.md D-08]`

## Environment Availability

No external tool is required for research. Elixir 1.20.4 / OTP 29.1.2 is available in this checkout; floor Elixir/OTP 1.18.5 / 27.3.4.9 is a required execution lane and its availability should be checked during plan preflight rather than inferred from the core runtime. `[VERIFIED: observed `elixir --version` in this session; pinned identities at test/support/sweep_evidence.ex:17-24]`

## Security Domain

Static source/contract review only. Security enforcement is enabled at ASVS level 1 in `.planning/config.json`; no runtime claim is in scope. `[VERIFIED: .planning/config.json:49-50]` Verbatim: `"security_enforcement": true,` and `"security_asvs_level": 1,`.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | No authentication boundary is changed. |
| V3 Session Management | No | No session handling is changed. |
| V4 Access Control | No | No access-control boundary is changed. |
| V5 Input Validation | Yes, static control scope | Preserve exact function-specific source and compile-only positive/negative controls; do not invoke input-reaching audited functions. |
| V6 Cryptography | No | No cryptographic code is changed. |

### Known Threat Patterns for static OTP guard contracts

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Input-derived atom/evaluator sink accidentally invoked by evidence | Tampering / Elevation of Privilege | Static byte/source review and compile-only fixtures; never execute audited APIs or sinks (ADR 0004). |
| Guard pattern masks legitimate library call | Denial of Service | Actual `lib/` collision is a hard stop with exact MFA, site, input trace and triggering guard. |
| Vacuous test passes while selected MFA is still covered elsewhere | Tampering | Individual removal and overlap controls per function/lane. |
| False security claim from graph-only evidence | Spoofing | Keep dynamic caller, native internals and runtime safety explicitly unproven. |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The four-wave critical path can fit within ADR 0021 when Wave 1 is parallel. | Pre-plan Gate Ledger | Historical analogous work supports the ranges; exact active review time is unmeasured, so record intervals and stop if the projected critical path exceeds three working days. |
| A2 | The archived complete installed-OTP Xref inventories plus recursive pinned source search close the direct caller set for the recorded core/floor versions. | Pre-plan Gate Ledger | Lane/version drift or a new direct source edge stops the affected task for re-sizing; dynamic callers remain unproven. |
| A3 | The inherited reserve plus scoped counts provides a conservative bound; 80,000 tokens is the planning target. | Pre-plan Gate Ledger | Recount if inputs or outputs grow; stop above the 80,000 target and never exceed 100,000 tokens. |

## Resolved Pre-plan Questions

1. **Direct caller closure for the pinned lanes: resolved within the static scope.** The complete archived core/floor Xref inventories have exactly one incoming edge per selected MFA; recursive installed ASN.1 source searches agree, and the target/caller source files match all four pinned archive identities. Plans recheck lane/source identity before use and stop for any drift or new static edge. This does not prove absence of dynamic callers or modified environments outside these pinned lanes.

2. **Effort fit: independently reviewed and passed.** Five two-task plans remain within the plan cap; disjoint lane outputs preserve concurrent Wave 1 work and the projected critical path, including phase verification/ship, remains 1.75–2.75 working days. If parallel execution becomes unavailable or actual work moves the upper estimate past three working days, stop and record a concrete bounded remedy; do not start serial work under the existing estimate.

## Sources

### Primary (HIGH confidence)

- `.planning/phases/02-bounded-asn-1-rtt-guard-evidence/02-CONTEXT.md` — locked slice, hashes, partitions, direct caller/source identities, gates.
- `.planning/REQUIREMENTS.md` — GRC-04 through GRC-06 and out-of-scope boundary.
- `.planning/STATE.md` — active phase, passed pre-plan gates and execution stop.
- `test/support/sweep_evidence.ex` — exact lane archive identities and scoped generator-dispatch evidence.
- `test/support/installed_otp.ex` and `test/contract/tier_sweep_test.exs` — inventory, existing EX-107 row and byte-only table contract patterns.
- `docs/adr/0004-no-eval-no-new-atoms.md`, `0014-testing-strategy.md`, `0018-dependency-budget.md`, `0021-delivery-rules.md` — locked security, testing, package and delivery rules.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-EX-107-ASN1-GENERATOR-DISPATCH-LEAF-SIZING.md` — historical exact source and byte-only table sizing, caller-support boundary, and explicit token/fit limitations.
- `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md` — prior bounded planning-context method and stop conditions.
- `.planning/milestones/v0.1-phases/01.1.1.2-installed-otp-inventory-and-common-test-guard-slice/01.1.1.2-INVENTORY-core.jsonl` and `01.1.1.2-INVENTORY-floor.jsonl` — full installed-lane static Xref edge evidence for the three direct callers.
- Installed core/floor `asn1ct_rtt.erl` and `asn1ct_func.erl` source files — fresh direct call-site search and exact SHA-256 comparison against archived evidence.
- `.planning/milestones/v0.1-phases/01.1.1.18-bound-asn-1-generator-dispatch-exclusions/01.1.1.18-01-SUMMARY.md`, `01.1.1.18-02-SUMMARY.md`, `01.1.1.18-03-SUMMARY.md`, and `01.1.1.18-02-PLAN.md` — measured analogous source/integration durations and explicitly bounded estimates.

### Secondary (MEDIUM confidence)

- `.planning/VERIFICATION.md` — automated acceptance and evidence policy.
- `.planning/references/PLANNING-LIFECYCLE.md` — planning preflight and canonical state owners.
- `AGENTS.md` and `CLAUDE.md` — project-specific constraints and workflow rules.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — current pinned lane declarations and project-owned helpers read directly.
- Architecture: MEDIUM — exact caller identity and lane binding are confirmed for the pinned static source/Xref evidence; dynamic callers remain outside proof.
- Pitfalls: HIGH — inherited partition, static-only and delivery constraints are explicit in reviewed context/ADRs.
- Context/effort fit: MEDIUM — every proposed task has a fresh context bound below 100,000; effort remains an evidence-based estimate rather than measured duration for this exact slice.

**Research date:** 2026-11-12  
**Valid until:** 2026-12-12 for stable project contracts; source identities must be rechecked against the pinned lanes at plan preflight.
