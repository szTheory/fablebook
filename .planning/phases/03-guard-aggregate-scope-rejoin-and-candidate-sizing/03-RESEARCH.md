# Phase 3: Guard aggregate scope rejoin and candidate sizing - Research

**Researched:** 2026-11-13  
**Domain:** Static guard-ledger reconciliation, exact OTP lane inventories, source provenance, caller/delegate traceability, and bounded sizing  
**Confidence:** MEDIUM — the source-of-truth constraints, helper patterns, historical sizing, and delivery records are present; a fresh current two-lane aggregate inventory and candidate-fit measurement do not yet exist.

<user_constraints>
## User Constraints

### Locked Decisions

#### Evidence package and review
- **D-01:** Use lane-specific machine-readable inventory and provenance records as the evidence source of truth, with a concise human-readable row-level crosswalk that links to those records and exact sources. Keep the full per-lane membership, additions, missing members, delivered scope, and pending complement inspectable; counts alone are not proof. Generate or link the summary to the records rather than maintaining duplicate facts by hand.
- **D-02:** Reuse the existing inventory and source-resolution helpers where they provide the required current evidence. Add only a narrowly scoped collector if a required receipt cannot otherwise be produced. Do not add a dependency or a general-purpose audit framework. Treat prior inventories as historical inputs, not as a substitute for a fresh current-lane inventory.

#### Candidate-sizing decision point
- **D-03:** Present one evidence-backed recommendation for a later bounded increment when the complete join and measured source/context/effort fit support it. Include the exact remaining complement and sizing basis. If evidence is missing or the candidate exceeds any inherited limit, select no candidate and state the concrete gap and bounded remedy.
- **D-04:** End at an explicit owner decision point. A Phase 3 recommendation is not approval to implement, add dispositions, open another phase automatically, or claim aggregate closure. The owner decides separately whether to authorize any later guard increment after reviewing the rejoin and sizing.

### the agent's Discretion
- Choose the precise record schema, filenames, and crosswalk layout; use the existing test/support patterns and keep the output easy to audit.
- Choose the smallest implementation boundary for a collector and the task/plan grouping, provided all source and evidence remains complete and the inherited limits are met. Fail closed on identity, provenance, caller, membership, or fit gaps.

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within the approved Phase 3 scope. Product UI, brand canon, dogfood apps, SEC-01 work, and any later guard implementation remain outside this phase under their existing owners.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| GSR-01 | A repeatable read-only procedure, using existing support or a narrowly scoped collector if needed, inventories the current target modules and exports on core and floor using the pinned runtimes and records lane identity and inventory provenance. It does not invoke audited OTP functions, callbacks, atom sinks, or generated code paths. | Reuse the lane checks and export inventory path in `InstalledOtp`; persist lane/runtime/lock identity, inventory digest, and exact export records. No fresh inventory was run during research. |
| GSR-02 | The rejoin maps every original guard exclusion identity to its current row owner and exact live per-lane MFA set, preserving delivered dispositions and reporting exact missing, added, and pending members. Counts alone do not establish equality; the full selected and pending complements are inspectable. | Preserve the original ledger identities and owner statuses, join each to independent live core/floor sets, and materialize set differences and complements instead of count-only summaries. Historical snapshots are leads only. |
| GSR-03 | For surviving scope on both lanes, the evidence links each row's matched targets to exact source identities and relevant caller/delegate paths. Missing source, caller, or provenance evidence is reported as an open gap and prevents candidate selection. | Reuse `SweepEvidence` source-resolution and digest checks plus structured lane evidence records. Treat unresolved dynamic callers and source gaps as explicit limitations. |
| GSR-04 | The output preserves prior delivery receipts and keeps distinct historical partitions distinct, including the delivered EX-010 scope and EX-107's 3/174 and historical 13/164/161 partitions. It does not reinterpret a prior slice as aggregate closure. | Preserve the two actual registry receipts and separate EX-010/EX-107 evidence; reproduce each partition as its own identity set and cross-reference the unchanged historical artifacts. |
| GSR-05 | The rejoin produces current source-file, context-token, and effort sizing for a candidate bounded increment. Any proposal fits the 100,000-token planning limit, at most five exact-source files per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan; otherwise it reports the concrete gap without truncation or substitution. | Build a fresh candidate sizing table from exact lane-specific file identities, per-task full-file/reread counts, isolated plan-context totals and reserves, and itemized effort. No current candidate fit is certified by historical estimates. |
| GSR-06 | The milestone ends with an inspectable owner decision point for any later guard implementation. It preserves the actual-library collision stop, the static-only boundary, SEC-01 ownership, the open aggregate gate, and the Walking Skeleton block. It does not add guard dispositions or claim aggregate closure. | Close the evidence package with a recommendation or explicit “no candidate” gap, and quote the preserved stops and actual owner decision. Do not author a guard disposition or mark a gate complete. |
</phase_requirements>

## Summary

Plan this as a read-only evidence pipeline with lane-specific machine-readable records as authority and a linked row-level crosswalk for review. The core work is to rebuild current exports on the pinned core and floor lanes, rejoin those sets to every original exclusion identity and its existing owner/disposition, then attach exact lane source identities and relevant caller/delegate paths. Existing inventory and archive helpers already cover key pieces; a narrowly scoped collector is appropriate only for a missing aggregate receipt. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22; test/support/installed_otp.ex:255-317; test/support/sweep_evidence.ex:274-347]`

Prior work proves only its recorded slices. The actual merged receipts identify v0.2 Phase 1 / EX-010 and v0.3 Phase 2 / EX-107, and Phase 2 keeps its full-row and historical partitions distinct. These do not replace the fresh aggregate join. `[VERIFIED: .planning/milestones/v0.2-CLOSEOUT.md:4, 10-18; .planning/milestones/v0.3-CLOSEOUT.md:6, 10-12]` The old full-audit sizing reports 221 original exclusion rows and 226 identities including metadata, with thousands of lane matches and hundreds of source files; this warns against sizing by row count or treating old source-byte estimates as current token/effort measurements. `[VERIFIED: .planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.md:5-18]` Verbatim: `**221 actual exclusion rows and 226 original identities including metadata**`; lane totals: `2,395 | 310 | 10,970,916` for core and `2,307 | 307 | 10,244,028` for floor (unique matching functions | source files | source bytes).

| Delivered slice | Actual receipt |
|----------------|----------------|
| v0.2 guard-recovery, Phase 1 / EX-010 | `[VERIFIED: .planning/references/PHASE-DELIVERIES.json:5-12]` Verbatim: `"milestone": "v0.2", "milestone_key": "guard-recovery", "phase": "1", "status": "merged", "pr": 85, "reviewed_head": "a90ef1dfe7bad10ac3d303b82f8ba7b32c949745", "merge_commit": "fb2e31be861acca65ef85399d0845901a3cc2b30", "ci_run": "https://github.com/szTheory/fablebook/actions/runs/43138409677"` |
| v0.3 guard-recovery, Phase 2 / EX-107 | `[VERIFIED: .planning/references/PHASE-DELIVERIES.json:15-22]` Verbatim: `"milestone": "v0.3", "milestone_key": "guard-recovery", "phase": "2", "status": "merged", "pr": 88, "reviewed_head": "ded4af612df3346b8516f4a027772ed3d2bbd53f", "merge_commit": "3817912c861286608183c057d2e38ff7a260bd6e", "ci_run": "https://github.com/szTheory/fablebook/actions/runs/43451903473"` |

**Primary recommendation:** Make the aggregate join and provenance package a prerequisite to candidate selection. Then recommend one bounded later increment only if exact selected and remaining sets, source/caller evidence, per-task file caps, isolated context totals, and effort all fit. If any of those inputs is incomplete, record the exact gap and select no candidate. This phase is not implementation approval and must leave the aggregate gate open. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:24-30; .planning/REQUIREMENTS.md:9-14]`

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Current lane exports and inventory provenance | Test/support static tooling | Contract-test evidence | Existing `InstalledOtp` owns export discovery and validates module identity and duplicate records; evidence should stay lane-separated. `[VERIFIED: test/support/installed_otp.ex:255-317]` |
| Original-row to current MFA reconciliation | Contract-test evidence | Test/support collector | The original guard ledger and current export sets are joined as static records; do not change runtime guard behavior. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:83-99]` |
| Exact source and caller/delegate links | Test/support static tooling | Human-readable crosswalk | `SweepEvidence` resolves citations and validates lane source digests; caller paths must reference the exact lane record. `[VERIFIED: test/support/sweep_evidence.ex:328-347]` |
| Candidate sizing and owner decision | Planning artifacts | Evidence records | The phase ends at a scoped recommendation or no-candidate gap; the owner separately authorizes any later increment. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:24-30]` |

## Project Constraints (from AGENTS.md)

- Follow `CLAUDE.md` and keep intent → ADR → requirements precedence. Preserve INT/ADR citations on requirements.
- Do not lower a quality gate. Do not invoke runtime eval or create atoms from input.
- Do not add dependencies or a general-purpose audit framework; adopters do not need Node.
- Keep evidence static and honest: no audited OTP API, callback, atom-sink, or generated-code invocation; do not claim dynamic-caller absence or runtime safety.
- Preserve the real-library collision stop and separate Macro caller-AST and explanation-wording checkpoints.
- Preserve the actual EX-010 and EX-107 delivery receipts, every original exclusion identity and owner, and distinct historical partitions.
- Keep SEC-01 with its existing owner, the guard aggregate open, and Walking Skeleton blocked; do not authorize a follow-on automatically. The gate record states `"id": "guard-aggregate", "status": "open", "blocks_milestones": ["walking-skeleton"]`; its owner remains `"SEC-01": "controls-bundle:1"`. `[VERIFIED: .planning/references/PLANNING-GATES.json:5-20]` Verbatim: `"id": "guard-aggregate"`, `"status": "open"`, `"blocks_milestones": ["walking-skeleton"]`, `"SEC-01": "controls-bundle:1"`.
- Run `bin/planning_health --stage plan --phase 3` before planning-state mutation. Preserve branch/worktree recovery evidence and do not reset/stash/clean a preserved checkout.
- The complete approved phase includes its review, required CI and delivery bookkeeping; a delivery receipt must use actual merge and hosted CI evidence.
- At the pause/phase boundary, state the concrete next command and its purpose; owner action is required only for the later increment decision.

`CLAUDE.md` additionally requires that every contract-test change remain separate from the production implementation it guards. This scope changes no production implementation, so keep work confined to the evidence/support and contract surfaces. `[VERIFIED: AGENTS.md; CLAUDE.md; docs/adr/0004-no-eval-no-new-atoms.md; docs/adr/0021-delivery-rules.md:14-30]`

## Standard Stack

### Core

| Library/tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Elixir / OTP core lane | Elixir 1.20.4 / OTP 29.1.2 | Read-only installed BEAM export inventory and core-lane evidence | This is the pinned project core lane. `[VERIFIED: test/support/installed_otp.ex:28-31]` Verbatim: `"core" => %{elixir: "1.20.4", otp: "29.1.2"}`. |
| Elixir / OTP floor lane | Elixir 1.18.5 / OTP 27.3.4.9 | Independent floor inventory and compatibility evidence | This is the pinned floor lane. `[VERIFIED: test/support/installed_otp.ex:28-31]` Verbatim: `"floor" => %{elixir: "1.18.5", otp: "27.3.4.9"}`. |
| `Fablebook.Test.InstalledOtp` | In-repo | Enumerate installed exports with lane/module checks; use `export_inventory!/2` where sufficient | Reuse the existing fail-closed inventory contract instead of creating another BEAM scanner. `[VERIFIED: test/support/installed_otp.ex:255-317]` |
| `Fablebook.Test.SweepEvidence` | In-repo | Validate archive/lock identity, resolve exact citations, and check source digests | Existing lane-aware, pinned source resolver. `[VERIFIED: test/support/sweep_evidence.ex:14-24, 274-347]` |
| ExUnit contract surface | In-repo | Assert inventory equality, provenance, partitions, and missing/added membership | Existing contract examples test exact set equality, disjointness, union, and complement. `[VERIFIED: test/contract/asn1_rtt_integration_test.exs:42-89]` |

### Supporting

| Library/tool | Version | Purpose | When to Use |
|--------------|---------|---------|-------------|
| `test/support/asn1_rtt_core_evidence.ex` and `test/support/asn1_rtt_floor_evidence.ex` | In-repo | Lane-specific structured target/caller/source record shape | Use as record design examples; their facts remain scoped to EX-107 and must not be generalized to other rows. `[VERIFIED: test/support/asn1_rtt_core_evidence.ex:4-40; test/support/asn1_rtt_floor_evidence.ex:4-18]` |
| `test/contract/asn1_rtt_integration_test.exs` | In-repo | Historical partition and exact membership assertion example | Reuse set operations as a pattern; do not reuse its selected set as the aggregate candidate. `[VERIFIED: test/contract/asn1_rtt_integration_test.exs:14-34, 61-88]` |
| Exact lane source archive | Existing fixture | Offline source identity and citation resolution | Resolve source spans only after validating archive lock, lane, path, and digest. `[VERIFIED: test/support/sweep_evidence.ex:14-24, 305-347]` |

**Installation:** None. No external package is required or recommended for this phase. The context explicitly forbids adding a dependency or general-purpose framework. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22]`

## Architecture Patterns

### Evidence flow

```text
Original guard ledger + current owner/status + actual delivery registry
                         │
               ┌─────────┴─────────┐
               ▼                   ▼
      Core pinned lane       Floor pinned lane
      BEAM export inventory  BEAM export inventory
      runtime/lock identity  runtime/lock identity
      inventory provenance  inventory provenance
               │                   │
               └─────────┬─────────┘
                         ▼
     Exact per-row MFA sets + additions/missing differences
                         │
                         ▼
       Lane source hashes + caller/delegate path references
                         │
                         ▼
 Delivered scope + exact pending complement + candidate sizing
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
  One bounded recommendation   No candidate + exact fit gap
              └──────────┬──────────┘
                         ▼
                  Explicit owner decision
```

The diagram represents a proposed evidence flow, not a claim that the full join already exists. The current phase context calls for lane-specific records as evidence authority and a linked crosswalk, while the historical inventory files remain inputs only. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22, 91-99]`

### Recommended Project Structure

```text
test/support/
├── installed_otp.ex                 # existing lane inventory/export helper
├── sweep_evidence.ex                # existing archive and source resolver
└── <narrow aggregate evidence helper> # only if existing helper cannot emit a required record
test/contract/
└── tier_sweep_test.exs               # extend existing authoritative ledger/graph test with aggregate tags
.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/
├── <lane-specific machine-readable inventory and provenance records>
├── <row-level linked crosswalk>
└── <source/context/effort sizing and owner decision>
```

Precise filenames and schema are discretionary; the plan should nominate one source of truth and derive or link the crosswalk rather than hand-maintaining duplicate membership facts. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22, 28-30]`

Plans 03-01 through 03-04 choose the existing `test/contract/tier_sweep_test.exs` as the aggregate contract entry point because its module owns the authoritative private `original_identity_ledger!`, compiled matcher tables and current full graph. Extend it in place with `:guard_aggregate_reconciliation`, records and bundle tags, passing its existing authority to the narrow collector rather than duplicating or moving the ledger. `test/contract/asn1_rtt_integration_test.exs` remains a secondary analog for exact-set, historical-partition and source-identity assertions; it is not the aggregate entry point. This records the chosen planning boundary, not executed aggregate coverage.

### Pattern 1: Fail-closed, lane-specific inventory

**What:** Record lane/runtime/lock identity and a digest-backed export inventory independently for each pinned lane. Reject wrong lane identity, duplicate modules/exports, unreadable inventory, and source provenance mismatches. Do not merge lane records before each independently passes its checks. `[VERIFIED: test/support/installed_otp.ex:28-31, 255-317, 1683-1695]`

**When to use:** Any current-membership claim or row rejoin.

**Example:**

```elixir
exports = Fablebook.Test.InstalledOtp.export_inventory!(beam_dirs, lane: lane_name)
```

This uses the existing helper surface shown in `InstalledOtp.export_inventory!/2`; `beam_dirs` and `lane_name` are supplied by the lane-specific collector. `[VERIFIED: test/support/installed_otp.ex:255-278]`

### Pattern 2: Exact set reconciliation, not count comparison

**What:** For each original identity and each lane, assert the full live set equals the expected set or materialize selected, missing, added, delivered, and pending sets with explicit equality, disjointness, and union checks. Keep any historical selection partition separate. `[VERIFIED: test/contract/asn1_rtt_integration_test.exs:42-89]`

**When to use:** The complete row-to-MFA rejoin and every reported complement.

**Example:**

```elixir
missing = MapSet.difference(expected, live)
added = MapSet.difference(live, expected)
pending = MapSet.difference(live, delivered)
```

These are set operations from the repository's existing contract pattern; a complete record must retain the actual members, not just these set sizes. `[VERIFIED: test/contract/asn1_rtt_integration_test.exs:70-88]`

### Pattern 3: Source identity and caller-path records

**What:** Each surviving target points to its lane's exact source identity and reviewed spans, then follows source-backed caller/delegate edges to the relevant boundary. Missing source or caller evidence is an open record, not a guessed link. Xref/source evidence cannot establish absence of dynamic callers or runtime safety. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:91-95; test/support/sweep_evidence.ex:328-347]`

**When to use:** All surviving rows before sizing a candidate.

### Anti-Patterns to Avoid

- **Reusing a historical inventory as current membership:** use it to locate original identity and previous measurements, then regenerate current lane inventories. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22, 91-95]`
- **Treating counts as proof:** keep complete member sets, row owners, exact differences, and complements inspectable. `[VERIFIED: .planning/REQUIREMENTS.md:9-13]`
- **Combining historical partitions:** preserve EX-107's delivered three-member slice, full-row 174-member complement, historical 13/164 partition, and remaining 161 subset as distinct sets. `[VERIFIED: test/contract/asn1_rtt_integration_test.exs:14-34, 61-88]` Verbatim values: `@selected_mfas` has three tuples; `@historical_mfas` has thirteen tuples; assertions are `MapSet.size(full_complement) == 174`, `MapSet.size(historical_complement) == 164`, and `MapSet.size(still_pending) == 161`.
- **Inferring no caller from an empty static edge result:** dynamic dispatch and external callers remain outside the proof; report those boundaries. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:91-95]`
- **Sizing by row count or bytes/4 alone:** measure exact source files and tokenized context per isolated plan, count rereads, reserve review/verification effort, and keep token-to-effort conversion explicitly unproven. `[VERIFIED: .planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.md:28-32; .planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md:17-25]`
- **Selecting a candidate before provenance/caller fit is complete:** fail closed and record no candidate. `[VERIFIED: .planning/REQUIREMENTS.md:11-14]`

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| BEAM export enumeration | A second module scanner or manual export list | `Fablebook.Test.InstalledOtp.export_inventory!/2` | It already validates lane/module identity, reads export chunks, and rejects duplicate or unreadable records. `[VERIFIED: test/support/installed_otp.ex:255-317]` |
| Exact source archive loading and citation checks | A new archive format or unchecked path resolver | `Fablebook.Test.SweepEvidence` | It pins archive identity, checks source paths and digests, and resolves exact citations. `[VERIFIED: test/support/sweep_evidence.ex:14-24, 305-347, 364-370]` |
| Aggregate audit framework | General-purpose audit package, dependency, or new CI lane | A narrowly scoped collector and contract test in the existing support surface | The phase decision explicitly disallows a general audit framework, new dependency, and new CI lane. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22, 97-99]` |

**Key insight:** Keep the evidence source of truth machine-readable and lane-specific, then derive the row crosswalk and sizing summary from it. That structure makes omissions and lane mismatches visible and avoids maintaining conflicting summaries by hand. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22]`

## Common Pitfalls

### Pitfall 1: Historical receipts mistaken for a fresh rejoin

**What goes wrong:** A prior EX-010/EX-107 slice or compressed sizing inventory is treated as the current complete aggregate result.

**Why it happens:** The historical artifacts contain useful exact members and lane records, but their coverage and timestamp are bounded to earlier scopes.

**How to avoid:** Produce fresh pinned-lane export records and join every original row before reporting current membership. Preserve the historical artifacts as separate inputs and receipts.

**Warning signs:** A crosswalk cites only the delivered row records or reports old match counts without current inventory digests. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22, 91-99]`

### Pitfall 2: Losing identities or merging complements

**What goes wrong:** Delivered items disappear from the original row model, a row's owner is overwritten, or distinct EX-107 partition counts are summed/substituted.

**Why it happens:** The delivered scope, full row, and prior historical selection are separate ownership/evidence dimensions.

**How to avoid:** Keep original row IDs and owner/disposition status stable, retain each partition as its own member set, and show exact delivered and pending complements per lane.

**Warning signs:** The report has only totals, one “remaining” count, or no link to the actual delivery registry. `[VERIFIED: .planning/REQUIREMENTS.md:10-12; test/contract/asn1_rtt_integration_test.exs:61-88]`

### Pitfall 3: Source graph overclaim

**What goes wrong:** Direct Xref/source links are presented as complete caller coverage or as runtime-safety proof.

**Why it happens:** Static graph edges show only observed source relationships; they do not settle dynamic calls, caller callbacks, or native internals.

**How to avoid:** Preserve exact source spans and relevant direct/delegate links, identify unresolved edges and boundaries explicitly, and block candidate selection if required caller/provenance evidence is missing.

**Warning signs:** “No callers” or “safe at runtime” appears without an authoritative complete proof. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:91-95; .planning/REQUIREMENTS.md:11, 25]`

### Pitfall 4: False sizing precision

**What goes wrong:** An old bytes/4 proxy or prior plan duration is reused as if it were a current tokenizer count and effort measurement.

**Why it happens:** The old full audit explicitly labels bytes/4 uncalibrated, while earlier EX-010 sizing was a specific six-file scope.

**How to avoid:** Recompute source identities, actual token context, rereads, fixed reserve, and itemized effort for the selected candidate. Treat previous durations as comparison evidence only.

**Warning signs:** No exact-source manifest per task, no isolated plan context estimate, missing review reserve, or a plan exceeding inherited bounds. `[VERIFIED: .planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.md:28-32; .planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md:17-25]`

## Validation Architecture

Nyquist validation is enabled in `.planning/config.json`. This research did not run tests, and the next phase should keep validation static and focused on the evidence contract. `[VERIFIED: .planning/config.json; docs/adr/0014-testing-strategy.md]`

### Test Framework

| Property | Value |
|----------|-------|
| Framework | ExUnit, in-repo contract tests |
| Config file | `mix.exs` includes `test/support` in the test compile paths and the `ci` alias runs the test task. `[VERIFIED: mix.exs:30-37, 52-62]` |
| Quick run command | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` (after implementation; not run during this research) |
| Full suite command | `bin/lane core mix ci && bin/lane floor test --warnings-as-errors --include prod_guard --include release` (after implementation; not run during this research) |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| GSR-01 | Current inventory on both pinned lanes has explicit lane/runtime/lock and provenance records; collector never calls audited targets | contract | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` | Yes — existing file; aggregate-tagged cases to add |
| GSR-02 | Every original identity retains owner and exact per-lane selected, added, missing, delivered, and pending sets | contract | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` | Yes — existing file; aggregate-tagged cases to add |
| GSR-03 | Each surviving target links to exact lane source identity and cited caller/delegate edges or an explicit evidence gap | contract | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` | Yes — existing file; aggregate-tagged cases to add |
| GSR-04 | Existing merged receipts and EX-010/EX-107 partitions remain distinct and unchanged | contract | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` | Yes — existing file; aggregate cases to add using the secondary EX-107 partition analog |
| GSR-05 | Candidate source/context/effort record obeys all inherited limits or reports a concrete no-candidate gap | contract + review | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` plus plan sizing review | Yes — existing file; aggregate sizing cases to add |
| GSR-06 | Report retains static-only boundary, collision stop, SEC-01 owner, open aggregate gate, Walking Skeleton block, and explicit owner choice | contract + document review | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` plus phase verification | Yes — existing file; aggregate acceptance cases to add |

Each focused command above must also run on floor as `bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors`. The file's existence is not evidence that the planned tagged cases exist or pass; capture nonzero selected-test counts on both lanes during execution. Records-only correction and bundle-publication selectors follow the separate tags in Plans 03-01/03-04.

### Sampling Rate

- Per task: the focused aggregate contract test once its implementation exists.
- Per wave: the changed contract surface on core and floor.
- Phase gate: required full project checks and hosted exact-head/main CI remain delivery requirements; they are not substitutes for reviewing the source evidence and final owner decision.

### Wave 0 Gaps

- Extend `test/contract/tier_sweep_test.exs` with aggregate-tagged row/MFA, inventory-provenance, source-link and sizing cases. Reuse its authoritative private ledger, compiled matchers and full graph in place; do not create a separate aggregate test file or duplicate the identity authority. Use `test/contract/asn1_rtt_integration_test.exs` only as the secondary set/partition/source-assertion analog.
- Add/extend only a narrow `test/support/` collector if current helper output cannot provide required records.
- Do not change production guards or add a new CI lane.

## Security Domain

Security enforcement is enabled. The relevant security surface is static file/archive evidence handling and fail-closed identity validation, not application authentication or session behavior. `[VERIFIED: .planning/config.json; .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:8-14]`

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | No application authentication is added or changed. |
| V3 Session Management | no | No sessions or runtime request flows are in scope. |
| V4 Access Control | no | No product authorization surface is touched. |
| V5 Input Validation | yes | Validate lane identity, archive paths, source citations, record shape, and missing/added sets; fail closed on mismatch. Existing source paths are checked as safe relative paths. `[VERIFIED: test/support/installed_otp.ex:1697-1701; test/support/sweep_evidence.ex:364-370]` |
| V6 Cryptography | yes, limited | Use existing SHA-256 identity/digest checks only to verify source/archive provenance. Do not invent a cryptographic protocol. `[VERIFIED: test/support/sweep_evidence.ex:14-24, 305-347]` |

### Known Threat Patterns for Static Evidence Collection

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Wrong lane or stale inventory presented as current | Tampering | Bind runtime/lock identity and inventory digest to every lane-specific record; regenerate the current inventory. |
| Unsafe archive/source path or mismatched source bytes | Tampering / Elevation | Reuse safe-path and digest validation; reject traversal, links, lane mismatch, and digest mismatch. |
| Count-only or merged historical partitions hiding missing members | Tampering | Compare exact sets and preserve each partition/receipt independently. |
| Calling audited OTP targets while collecting evidence | Elevation | Inventory exports and read source only; prohibit target/callback/atom-sink/generated-code invocation in the collector and its tests. |

## Environment Availability

Static command presence was checked; runtime version commands and tests were not run. The installed Elixir/OTP lane versions therefore remain unverified in this session, even though the repository has explicit core/floor pins. `[VERIFIED: test/support/installed_otp.ex:28-31]` Verbatim: `"core" => %{elixir: "1.20.4", otp: "29.1.2"}` and `"floor" => %{elixir: "1.18.5", otp: "27.3.4.9"}`.

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| `elixir` / `mix` | Static inventory collector and contract checks on both lanes | ✓ command present | Not queried | None for pinned-lane verification |
| `erl` | OTP lane/runtime setup and source inventory support | ✓ command present | Not queried | None for pinned-lane verification |
| `tar`, `gzip`, `gzcat`, `shasum` | Inspect existing archive/history and verify recorded artifact digests | ✓ commands present | Not queried | Existing Mix/OTP archive helper can be used during implementation |
| Core and floor toolchains | Fresh installed-lane inventory and parity evidence | Unverified | Repository pins are present; active runtime not checked | Do not substitute one lane for the other; report a concrete blocker if either lane cannot be run |

**Missing dependencies with no fallback:** None found by command-presence inspection. Pinned runtime versions still need a controlled execution-stage check on each lane.

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Require a full remainder schedule before any bounded replacement work | Rolling allocation: select a bounded increment when its exact sources, complement, context, and effort fit are measured | INT-20261110-01 | Keep the complete original remainder visible; size only a complete candidate and never infer a verdict for unreviewed rows. `[VERIFIED: .planning/intent/sources/2026-11-10-01-rolling-allocation-for-bounded-work.md:10-14]` |
| Treat a historical row inventory as enough to plan from | Rejoin the complete surviving original scope to fresh current pinned-lane inventories | Phase 3 owner selection, 2026-11-13 | Historical work remains reusable only within its actual delivery/evidence scope. `[VERIFIED: .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:20-22]` |

**Deprecated/outdated:**

- The 2026-11-11 full-scope bytes/4 budget is an uncalibrated planning proxy, not a current tokenizer result or effort estimate. It is useful for scale and historical provenance only. `[VERIFIED: .planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.md:28-32]`
- Earlier EX-010 source/context estimates certify only the specifically reviewed EX-010 slice; they do not certify the wider aggregate or a different candidate. `[VERIFIED: .planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md:5-25]`

## Assumptions Log

> No `[ASSUMED]` technical claims are used to select a candidate. Current aggregate membership, source closure, and fit remain unobserved until the phase produces fresh evidence; the report recommends no preselected candidate.

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| — | None | — | — |

## Open Questions

No unresolved planning-method or scope questions remain. The resolutions below settle how Phase 3 will produce and assess its evidence; they do not resolve the factual results. Current membership, source/caller completeness and candidate fit remain unobserved execution outputs under GSR-01 through GSR-06 and D-01 through D-04. No current inventory or fit is certified here, and no candidate is preselected.

1. **RESOLVED — How will exact current core and floor row-to-MFA membership be established?**
   - Planning resolution: Plan 03-01 first proves one real both-lane path, then rejoins every original identity to independently acquired pinned-lane export inventories using the existing helpers and a narrow collector. Lane-specific machine-readable records retain owners, exact member sets, additions, absences, delivered scope, historical partitions and full pending complements; the crosswalk is derived from them per D-01/D-02.
   - Execution evidence still required (unobserved): the actual current core/floor memberships, inventory provenance, differences and complete remaining complements. Historical records remain historical inputs. Acquisition or identity failures fail closed; they cannot be filled with prior counts or opposite-lane evidence.

2. **RESOLVED — How will complete source and relevant caller/delegate provenance be assessed?**
   - Planning resolution: Plan 03-02 joins every surviving lane/row/MFA to exact lane source identities and observed static caller/delegate paths using the existing resolver and full graph. It retains an exhaustive phase-wide required-evidence-gap index. Any required source, caller or provenance gap prevents recommending a candidate, even if a possible candidate's own row appears complete, per GSR-03/D-03.
   - Execution evidence still required (unobserved): which associations are complete and the exact missing evidence across both lanes. Static edges never establish dynamic-caller absence or runtime safety. Missing evidence is an explicit result with a bounded remedy, not an assumed closure.

3. **RESOLVED — How will later candidate fit and the owner decision be determined?**
   - Planning resolution: Plan 03-03 measures at most one diagnostic pending scope after the complete join, using current exact source identities, tokenizer counts, reads/rereads, isolated context/reserve totals, task/plan grouping and itemized effort. A recommendation requires complete phase-wide evidence and every inherited limit to pass. Missing measurements, any evidence/fit failure or an unresolved actual-library collision select no candidate and name the concrete gap/remedy per D-03. Plans 03-04/03-05 independently review the result and preserve the separate later owner decision per D-04.
   - Execution evidence still required (unobserved): the actual source/context/effort measurements and whether any candidate qualifies. No-candidate remains a valid completed reconciliation outcome. Recommendation never grants implementation authority; the collision stop, static-only boundary, SEC-01 ownership, open aggregate gate and Walking Skeleton block remain intact.

## Sources

### Primary (HIGH confidence for repository-owned decisions and definitions)

- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md` — locked evidence architecture, static-only scope, candidate condition, and owner decision.
- `.planning/REQUIREMENTS.md` — GSR-01 through GSR-06, acceptance and explicit exclusions.
- `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/PROJECT.md` — active phase, current handoff, current gates, and scope.
- `.planning/references/PHASE-DELIVERIES.json`, `.planning/references/PLANNING-GATES.json`, `.planning/references/PLANNING-LIFECYCLE.md` — actual receipt records, gate ownership, and phase transitions.
- `.planning/intent/sources/2026-11-13-02-select-guard-aggregate-reconciliation.md` and the required prior intent files — provenance and rolling limits.
- `test/support/installed_otp.ex`, `test/support/sweep_evidence.ex`, `test/support/asn1_rtt_core_evidence.ex`, `test/support/asn1_rtt_floor_evidence.ex` — installed export inventory, source resolver, and lane-specific evidence records.
- `test/contract/asn1_rtt_integration_test.exs`, `test/contract/tier_sweep_test.exs` — exact set/partition and full-row contract patterns.
- `docs/adr/0004-no-eval-no-new-atoms.md`, `docs/adr/0014-testing-strategy.md`, `docs/adr/0021-delivery-rules.md` — static safety, contract validation, task/plan/delivery limits.
- `.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.md` and its JSON, plus `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md` and `.planning/milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-RESEARCH.md` — historical scale and bounded sizing precedent, not current fit certification.
- `test/fixtures/guards/exact_sources.tar.gz` — existing pinned-lane source archive.

### Secondary

- `CLAUDE.md`, `AGENTS.md`, `.planning/VERIFICATION.md`, `docs/adr/README.md` — repository-specific planning and evidence rules.
- `FABLEBOOK-SEED.md` and `docs/research/*.md` — read per repository instructions; no UI/brand research applies to this static guard phase.

## Metadata

**Confidence breakdown:**

- Standard stack: HIGH — pinned lane definitions and reusable helper source are explicit in repository code.
- Architecture: HIGH for the mandated evidence flow; MEDIUM for the exact collector boundary and output schema, which remain a discretionary planning choice.
- Pitfalls: HIGH — prior reports and current context explicitly document stale membership, partition, source/caller, and sizing risks.
- Candidate fit: LOW until fresh lane inventory, source closure, token sizing, and effort measurement exist.

**Research date:** 2026-11-13  
**Valid until:** 2026-12-13 for stable repository-owned constraints; candidate membership and fit are valid only for the exact generated inventory/source identities.
