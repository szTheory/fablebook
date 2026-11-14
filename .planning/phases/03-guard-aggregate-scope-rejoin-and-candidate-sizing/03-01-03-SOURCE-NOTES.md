---
phase: 03
plan: 03-01
task: 03-01-03
status: complete
source-events:
  incomplete: [1]
  complete: [2, 3, 4]
---

# Task 03-01-03 Source Notes

This is a static, source-anchored handoff for the existing TierSweepTest,
InstalledOtp, and SweepEvidence seams. It records only complete scheduled
ranges from continuation events 2–4. It does not turn either incomplete event
into evidence and does not authorize implementation.

## Event accounting

| Event | Source | Result |
|---:|---|---|
| 1 | Eight scheduled TierSweepTest ranges | Permanently consumed/incomplete; explicit truncation marker. No claims below derive from it. |
| 2 | `test/contract/tier_sweep_test.exs`: 1360–1485, 2840–2905, 5030–5125, 7670–7905, 8390–8560, 10620–10695, 13440–13620, 14070–14330 | Complete exact ranges emitted together once, with all eight labels, under the existing 16,000 inner / 18,000 outer token ceilings; no truncation marker. |
| 3 | `test/support/installed_otp.ex`: 1–130, 245–345, 1683–1701 | Complete exact ranges emitted together once; all three labels present, no truncation marker. |
| 4 | `test/support/sweep_evidence.ex`: 1–110, 245–370 | Complete exact ranges emitted together once; both labels present, no truncation marker. |

No implementation source was edited and no tests were run. No audited OTP
API, callback, atom sink, or generated-code path was invoked.

## Count-only transfers (separate from source review)

The event-2 rendered payload used plain extraction with one concise anchor label
per range. It contained 1,213 source lines and 8 label lines (1,221 total),
47,039 bytes, SHA-256
`1a30248724a2a5697bc79aba53d791475fa876ade17e7039e1402007203c4537`, and
12,356 `gpt-6-luna` input tokens from `POST /v1/responses/input_tokens`.

The fresh combined count-only bundle covered 16 file inputs: the six
plan-selected documents (config, plan, execution context, replan,
phase-deliveries, planning-gates), plus ten additional project/executor context
and receipt files loaded for this task (AGENTS, CLAUDE, STATE, North Star,
Clearance, Glossary, ADR README, Verification, recovery receipt, checkpoint).
It also covered the exact payloads for source events 2–4 and incomplete-event
receipt text only. It did not include either partial source body or access the
full archive manifest. The direct combined count was 48,851 tokens before event 2, before
event 3 (including complete event 2), and before event 4 (including complete
events 2–3). At each gate the projection remained 48,851 + 12,000 future-source
cap + 5,000 task-output allowance = 65,851 / 69,000 working tokens, plus the
31,000 reserve = 96,851 / 100,000 total, leaving 3,149 tokens of slack.

Count-only transfer scope was limited to the event-2 payload and the combined
fit bundles just described. These counts are sizing measurements, not semantic
evidence. The prior partial event bodies were neither loaded nor reproduced.

## Source handoff

### TierSweepTest

- The archive citation assertion at `test/contract/tier_sweep_test.exs:1360–1485`
  resolves each citation through `SweepEvidence.resolve!/2` and checks archive
  origin, matching digest, expected text, and recorded byte size.
- The matcher fixtures at `2840–2905` keep core/floor expected match sets
  lane-specific and define explicit exclusion reasons. The nearby table and
  caller-chain test region at `5030–5125` preserves duplicate caller edges and
  lowest-arity selection in its expected index.
- `setup_all` creates one graph for the suite at `5030–5125`. The identity
  contract at `7670–7905` calls `original_identity_ledger!/0`, checks 221
  exclusions and five distinct lane-metadata identities, and rejects dropped,
  duplicated, substituted, misowned, or payload-mutated rows. It keeps
  exclusion identities distinct from lane metadata.
- Retained event-2 output confirms `setup_all` calls `build_graph/0`, binds the
  result as `graph`, and returns `{:ok, graph: graph}`. The tracer test can be
  inserted after that setup block and before the first caller-chain index test.
  Its exact line number was not retained; no additional source read is needed
  to apply the unique test-name anchor.
- The EX-010 test inputs in `8390–8560` are `evidence =
  SweepEvidence.source_roots!()`, `ledger = original_identity_ledger!()`,
  `tier = BannedCalls.banned_mfas()`, and
  `records = InetsTraceIntegrationEvidence.lane_records()`. The existing
  integration call is `assert_inets_trace_audit!(ctx.graph, evidence, ledger,
  tier)`; the tracer guard uses `ctx.graph.full_edges` and
  `ctx.graph.exported`. The recorded integration result carries lane,
  selected-function evidence, reviews, exact sources, matched MFAs, delegate
  edges and remainder MFAs. No distinct delivery-registry API was retained;
  use the actual phase delivery registry separately and do not infer a helper.
- The retained identity test shows `ledger.exclusions` and `ledger.metadata`
  as lists of map-like rows. Exclusions have string `id` and `table`,
  `identity_class: :exclusion`, raw matcher/reason strings, atom semantic
  statuses, string owners, string-list replacement refs, and lane-keyed match
  lists. Metadata rows have string `id`, `table`, original raw values, owner,
  `identity_class: :lane_metadata`, `semantic_status: :pending`, and
  string-list replacement refs. It checks 221 exclusions and five metadata
  identities. The source and compiled tables are `call_name_exclusions` /
  `@call_name_exclusions`, `exclusions` / `@exclusions`,
  `boundary_exclusions` / `@boundary_exclusions`,
  `call_name_lane_specific` / `@call_name_lane_specific`, and
  `boundary_lane_specific` / `@boundary_lane_specific`; expected lane maps
  include `@cn004_expected_matches_by_lane`,
  `@cn006_expected_matches_by_lane`, and `@inets_trace_core_mfas`.
- `InetsTraceIntegrationEvidence.lane_records/0` is consumed as a list of
  map-like rows with string `lane` and list-valued
  `selected_function_evidence`, `reviews`, `exact_sources`, `matched_mfas`,
  `delegate_edges`, and `remainder_mfas`. Nested item types beyond the
  retained source assertions were not recorded. The existing assertion helpers
  are `assert_inets_trace_audit!/4`, `assert_inets_trace_partition!/3`, and
  `assert_inets_trace_guards!/3`; `InetsTraceIntegrationEvidence.selected_mfas/0`
  supplies the selected set. Use these only with the recorded lane and source
  identities; do not infer unrecorded nested fields.
- EX-010 assertions at `8390–8560` require both lane records, retained callback
  front dispositions for `inets:enable_trace/2,3`, empty guard patterns, and
  reject missing, duplicated, wrong-lane, reordered, or unsupported evidence.
- The `build_graph` excerpt at `10620–10695` shows lane-bound installed OTP
  discovery, completeness checking, inspection and source inventory calls,
  followed by inclusion of historical-active and pending installed apps. This
  scheduled excerpt ends inside the builder; its remaining graph construction
  was not inspected, so no claim is made about those omitted lines.
- The helper assertions at `13440–13620` compare exact recorded MFA, trace,
  verdict, replacement, fixture, citation and lane sets. The identity loader at
  `14070–14330` verifies the snapshot and budget SHA-256 values before deriving
  original rows and replacement references. Those are source-level checks; the
  loader was not run.

### InstalledOtp

- `test/support/installed_otp.ex:1–130` pins core and floor Elixir/OTP
  identities. `discover!/2` expands the root, rejects symlink and invalid app
  roots, and rejects duplicate applications or modules while preserving
  structured inventory errors.
- At `245–345`, the discovery-completeness contract reports missing or extra
  discovered, inspected and ingested sets. `export_inventory!/2` accepts an
  injectable BEAM-chunk reader, rejects duplicate exports, validates each BEAM
  module name against its filename, and includes the predefined metadata
  exports used by edges.
- At `1683–1701`, lane/version validation uses the pinned identity and receipt
  lock hashes must be lowercase 64-character SHA-256 values equal to the
  expected lane digest. Receipt paths must be relative and exclude traversal,
  empty segments, backslashes, NULs and colons.

### SweepEvidence

- `test/support/sweep_evidence.ex:1–110` pins the exact-source archive digest,
  core/floor OTP and Elixir lock identities, and source identities with paths,
  byte counts and digests. The error type carries a stable reason and detail.
- At `245–370`, `source_roots!/0` validates archive locks and joins the
  lane-bound installed inventory with Elixir and dependency roots. Archive
  entries must be regular files at safe relative paths. `resolve!/2` resolves
  a citation under its real source root, verifies the content digest, and
  rejects out-of-range line references.

## Handoff limits

These observations describe existing source contracts only. The static evidence
boundary remains in force; candidate stays null, implementation authorization
stays false, the aggregate gate stays open, Walking Skeleton stays blocked, and
SEC-01 remains Pending. Keep the actual-library-collision stop and Macro
caller-AST and explanation checkpoints. The next implementation task must first
meet its own reviewed preconditions and retain the early record consistency
checks in the plan.

## Late Task 03-01-03 continuation event 5: Task 03-01-04 collector interface

This post-tracer supplement reads only the complete `build_lane!/1` and
`validate_lane!/1` definitions at
`test/support/guard_aggregate_reconciliation_evidence.ex:16–89`. It was a
single 805-token source event, 74 lines and 2,899 bytes, SHA-256
`72f4b50c7f2b376a8f9a143305e43a45799350cbd5c624fb752668b92e7c269a`.

`build_lane!/1` requires an input map with `:lane`, `:identity`,
`:selected_mfas`, `:live_mfas`, `:lane_evidence`, `:delivery`, `:runtime`, and
`:lock_sha256`. The lane must be core or floor. For this tracer, identity must
be EX-010 with `identity_class == "exclusion"`. The builder normalizes both
MFA lists through `mfa!/1`, removes duplicates and sorts them, then requires
`live_mfas` to be a subset of `selected_mfas`. The lane evidence must carry the
same lane and list-valued `selected_function_evidence`, `reviews`,
`exact_sources`, `matched_mfas`, `delegate_edges`, and `remainder_mfas`.
Delivery must be merged and include a binary CI-run identity. Runtime and lock
digest are passed separately. The serialized record retains identity, owner,
delivery, selected/live MFAs, lane evidence, and the fixed safety stops.

`validate_lane!/1` checks schema/collector/lane, matching generation and input
hash, a 64-character lock digest, EX-010 exclusion identity, evidence-lane
match, owner/identity agreement, sorted unique MFA lists, `live_mfas` subset
of `selected_mfas`, merged delivery, and exact stop flags. It validates this
tracer record shape; it does not compute original-row matches or current
replacement sets. Those inputs are precomputed by the caller. Task 03-01-05
must derive its row-specific `selected_mfas` and `live_mfas` from the existing
ledger, compiled tables and full lane export, preserving separate identities
and the explicitly recorded replacement references. Do not treat this
interface note as evidence that such a mapping was already implemented.

## Task 03-01-05 event 1: exact current matcher interfaces

Task05 event 1 acquired only TierSweepTest ranges 13836–13872,
14004–14149, 14644–14713, and 12492–12540. The plain labeled payload was
302 source lines, 310 rendered lines, 11,670 bytes, 3,149 `gpt-6-luna`
input tokens, SHA-256
`4c17fdfda670b7138f560bfddf9d615a202c67a9deae45e9a8ade144f9ab7833`.
All four function groups reached their known next-function boundary and the
explicit end marker was present; no truncation occurred. The source file was
not modified during acquisition.

The source rows use 1-based indices. `source_row_indices/1` maps an equal raw
row to every index and restores ascending source order, preserving duplicates.
The historical accessor reads `lane_baselines[lane][id]["matches"]`, converts
those MFAs to their recorded strings, and asserts uniqueness. Current
call-name lookup matches the exact compiled matcher and returns
`source:CN:<1-based-index>`.

The observed predicates are table-specific. Call-name matching requires the
same module and membership in the functions list. Boundary matching accepts an
atom module or a `{module, functions}` pair. Generic exclusion matching handles
module/function lists, module prefixes, function-name prefixes, and exact
module/function pairs. The logger-family helper accepts its explicit module,
function/list, or module-prefix forms. Lane-specific boundary/call-name
helpers select the floor path when `FABLEBOOK_FLOOR` is set and avoid attaching
a lane-only row when a generic match already exists.

The retained `assert_creator_audit!/5` body directly validates the EX-159
`:file` creator record: it derives matches from that lane's `graph.exported`
using the record's original matcher, removes metadata exports, and asserts exact
equality with `record.matched_mfas`; it also pins replacement/tier membership.
This observation does not establish every creator-audit family. The aggregate
builder must keep creator refs separate, validate each referenced record against
the matching lane's full export set using a supported source-anchored matcher,
and fail closed on an unsupported matcher or missing/duplicate record. Do not
claim the whole creator mapping is closed until that guard passes for every
referenced row.

## Task 03-01-05 event 2: creator-family live-set contracts

Task05 event2 acquired the six exact ranges at TierSweepTest: 12541–12553,
12611–12623, 13630–13642, 13660–13667, 13688–13804, and 13805–13815.
The rendered payload was 175 source lines, 187 rendered lines, 8,074 bytes,
2,024 `gpt-6-luna` input tokens, SHA-256
`58aabdf37871de43db1e0ed562d7f69fd7b47d204ef6e414c6a35ea99333d12d`.
All selected ranges and function boundaries were complete, and the end marker
was present. No source file changed during acquisition.

- EX-165/LEEX uses original matcher `{:leex, [:file]}`. The source assertion
  filters `graph.full_exported` through `creator_original_match?/2`, removes
  metadata exports, and checks exact equality with the pinned LEEX MFA set. It
  separately converts the record's `matched_mfas` and checks exact equality
  with the original lane baseline.
- EX-089/YECC uses `{:yecc, :epp_guard}`. Its matcher accepts only `:yecc`
  exports other than `module_info` and `__info__`; the source assertion checks
  the exact-lane filtered set equals the record's `matched_mfas`.
- Logger creator records have one exact MFA each, with matcher `{:mfa, mfa}`.
  The source assertion proves each expected lane MFA is exported and that the
  complete live family set (reachable tier members plus explicit tier and
  exclusion roots) exactly equals both the pinned lane universe and the union
  of recorded creator MFAs.
- Together with event1's EX-159 assertion and the previously observed
  `creator:<id>:<lane>` reference construction, these contracts cover the
  supported creator refs. Implementation must resolve by both id and lane,
  preserve per-row identity, and reject missing/duplicate refs or any unknown
  matcher form. These are source-level assertions; they have not been run yet.
