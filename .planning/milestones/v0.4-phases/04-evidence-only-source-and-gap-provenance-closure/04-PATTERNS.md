# Phase 4: Evidence-only source and gap provenance closure - Pattern Map

**Mapped:** 2026-11-17  
**Files mapped:** 6 planned output artifacts  
**Analogs found:** 6 / 6 (four data/code-shape analogs; two contract-only)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `04-PROVENANCE-MANIFEST.json` | config / evidence manifest | batch | `03-04-METADATA-GAP-RECEIPT.json` | role-match |
| `04-TARGET-SOURCE-ASSOCIATIONS.jsonl` | model / evidence rows | batch | `test/support/guard_aggregate_reconciliation_evidence.ex` | role + keyed-row match |
| `04-TYPED-GAPS.jsonl` | model / evidence rows | batch | `03-04-METADATA-GAPS.jsonl`; `03-04-METADATA-GAP-VALIDATION.json` | exact gap-data shape |
| `04-COVERAGE-CALLER-TRACE.json` | model / derivation record | transform | `03-05-PLAN.md` consumer contract | contract-only; no implemented caller-trace analog |
| `04-SIZING-DIGEST-PROOF.json` | model / digest proof | transform | `03-04-METADATA-GAP-RECEIPT.json`; `03-05-PLAN.md` | contract-only; no proven legacy recipe analog |
| `04-VALIDATION.json` | test / validation receipt | batch | `03-04-METADATA-GAP-VALIDATION.json` | role-match |

These are six stable machine-artifact paths, not six application modules. The exact consumer fields are defined in [`03-05-PLAN.md:130-139`](../03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-PLAN.md). Keep Phase 3 records and historical receipts byte-for-byte unchanged.

## Pattern Assignments

### `04-PROVENANCE-MANIFEST.json` (config, batch)

**Analog:** `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAP-RECEIPT.json`

Use the Phase 3 receipt shape to bind version/schema, each input path and digest, the preservation manifest, and limits. The receipt's `inputs`, `preservation_manifest`, and `input_files` fields are shown at lines 7-17, 39-64, and 126-139. For Phase 4, add the exact original-ID authority and independent core/floor identity/MFA selectors, then bind the exact paths and raw-byte SHA-256 values for both JSONL supplements. Do not turn a historical input hash into fresh source evidence.

**Consumer contract** (`03-05-PLAN.md:132`):

```text
04-PROVENANCE-MANIFEST.json: versioned schema, input file identities,
exact original-ID and per-lane identity/MFA selectors, supplement row
paths/digests, and preservation hashes.
```

### `04-TARGET-SOURCE-ASSOCIATIONS.jsonl` (model, batch)

**Analog:** `test/support/guard_aggregate_reconciliation_evidence.ex`

The helper creates association rows with `cited_static_evidence` or `source_gap` status, links gap keys, and sorts deterministically (lines 329-363, 380-389). Its validator compares expected and actual MFA keys, rejects duplicate association keys, checks source identity against lane and lock, and checks source path, byte count, and SHA shape (lines 399-410, 430-464). The support file is tracked and is the closest code analog. Phase 4's consumer contract stores source associations and source-gap rows as separate JSONL partitions, so adapt the shape instead of copying the helper's combined list.

**Association/gap partition excerpt** (lines 399-410):

```elixir
expected =
  for row <- record["identity_rows"],
      mfa <- row["live_mfas"],
      do: {row["identity"]["id"], mfa}

actual =
  record["target_source_associations"]
  |> Enum.map(&{&1["identity_id"], &1["mfa"]})
  |> Enum.reject(fn {_id, mfa} -> is_nil(mfa) end)

true = length(actual) == length(Enum.uniq(actual))
true = Enum.sort(actual) == Enum.sort(expected)
```

Adapt this to explicit `(lane, original_id, module, function, integer_arity)` keys across **both** lanes. Derive expected keys from the retained memberships, require association keys to be unique, and compare exact key sets before checking counts. Include lane, repository ref, runtime/lock, archive row, citation/span, independent review, safe relative source path, exact byte count, and raw-byte SHA-256 on every resolved association. A digest confirms bytes match the recorded selector; it cannot prove that the selected source semantically corresponds to an MFA.

### `04-TYPED-GAPS.jsonl` (model, batch)

**Analogs:**

- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAPS.jsonl:1` — an actual keyed unresolved row with `lane`, `identity_id`, `mfa`, `missing_fields`, `reason`, and `remedy`.
- `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAP-VALIDATION.json:140-219` — row schema, unique key, known/unknown row rules, and exact evidence-reference selector rules.
- `test/support/guard_aggregate_reconciliation_evidence.ex:351-359,430-464` — explicit source-gap status and unique gap-key checks.

**Existing schema excerpt** (validation artifact lines 202-219):

```json
"unique_key": ["lane", "identity_id", "mfa"],
"unknown_row_rule": "one row per empty retained list; mfa and baseline_mfa_index null; target_set_status unknown; missing_fields includes target_mfa_list",
"known_row_rule": "one row per exact retained baseline MFA tuple and matching identity; no deduplication across identities"
```

Carry this keyed, typed-gap style forward, extending the key to the Phase 4 identity/MFA contract. Keep source, caller, graph, callback, and delegate gaps typed separately; preserve exact status, reason, remedy, missing-field cause, and all known citation/review provenance. A valid gap completes the record partition while leaving the corresponding semantic claim unresolved.

For the 18 identities whose target list is unknown, emit explicit identity-level unknown membership. Do not omit the identity, synthesize an MFA, or translate unknown into an observed empty set. Reject duplicate or opposite-lane keys and reject missing or extra expected keys. Caller/graph/callback/delegate keys must not be counted as duplicate source-partition rows.

### `04-COVERAGE-CALLER-TRACE.json` (model, transform)

**Analog:** `03-05-PLAN.md:135,167-169` defines the consumer proof; there is no implemented caller-trace artifact to copy.

Trace the static caller and selector that produce `target_source_coverage_complete`, bind them to the exact schedule/count/preflight and source/graph identities, and explain source-resolution and caller-closure outcomes independently. Reconcile each result with keyed nonzero gaps. Keep record completeness, source resolution, caller closure, and runtime/safety claims as distinct states. Counts and nonzero edge counts are diagnostics after key equality; they do not establish complete semantic coverage.

**Important caution:** the current support helper sets `target_source_coverage_complete` to `true` at line 388 even when its collected `gaps` list is nonempty (lines 329-359, 380-389), and its validator requires that value at line 394. Do not copy that assignment as Phase 4 proof. The requested trace must show the actual derivation and explain why the old aggregate flag does or does not agree with the exact source/caller partitions.

### `04-SIZING-DIGEST-PROOF.json` (model, transform)

**Analog:** `03-05-PLAN.md:136` is the exact contract; `03-04-METADATA-GAP-RECEIPT.json:39-64` illustrates preservation and input hashing. No existing analog establishes the legacy nested SIZING recipe.

Record the exact legacy selector, field order, byte encoding, and digest only if independently recomputed from complete, known inputs. If the recipe remains unknown, state that explicitly and give the supplement its own versioned selector, encoding, and digest. Never label the supplement digest as a reproduction of the legacy value.

**Digest caution:** the helper's `digest/1` at lines 1424-1427 hashes deterministic Erlang term encoding. That is an in-memory semantic-record digest, not a digest of exact JSON/JSONL file bytes. For artifact-integrity fields, hash the exact bytes written/read and retain the matching byte count; do not parse then reserialize before hashing. Use the existing project JSON serializer/reader where applicable, with no new dependency.

### `04-VALIDATION.json` (test, batch)

**Analog:** `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-METADATA-GAP-VALIDATION.json`.

Reuse its concrete schema/key/rule reporting style (especially its `row_schema`, `unique_key`, `unknown_row_rule`, and `direct_reference_contract` fields at lines 140-219), and its compact receipt bindings rather than embedding full inventories in prose. Validate the exact generation named by the manifest: schema and types, duplicate JSON object keys, safe paths and links, complete independent 226-ID lane sets, duplicate/wrong-lane/missing/extra key rejection, disjoint exhaustive source association/source-gap partitions, typed non-source gaps, provenance fields, cross-file byte digests, preserved input hashes, and all review/schedule/preflight/direct-count receipt links. Check counts only after exact keys match.

`04-VALIDATION.json` should report each check and precise missing key/provenance field. Unresolved but correctly typed evidence may validate as a complete record package; it must still leave source/caller closure unresolved. Each actual source request must bind a reviewed exact schedule, fresh Phase 4 execute preflight, and fresh direct count before any source body read; cap each task at five exact source files, keep requests untruncated and inside the 34,000 compact-input and 150,000 incremental generated-output-token limits with the fixed 31,000 reserve. A missing, failed, stale, or over-limit gate means stop and record the exact gap. The new total applies only to the remaining Phase 4/Phase 3 recovery under INT-20261117-01; all older usage remains in the historical budget receipt.

## Shared Patterns

### Lane and key integrity

**Source:** `test/support/guard_aggregate_reconciliation_evidence.ex:116-131,399-410,430-464` (tracked). The helper explicitly restricts lane values, checks the source evidence lane matches its containing lane, validates lock/hash shapes, enforces unique rows, and compares exact membership. Apply that structure to all six artifacts. Build the expected keys independently for core and floor; reject duplicates, opposite-lane rows, missing keys, extra keys, and lost identity owners before interpreting counts.

### Byte integrity and safe paths

**Sources:** `03-05-PLAN.md:132-137`; metadata-gap receipt `03-04-METADATA-GAP-RECEIPT.json:39-64`.

Keep paths repository-relative; reject absolute paths, traversal components, and links that escape the reviewed repository/archive root. Record path, byte count, and SHA-256 from the same exact byte sequence. Preserve Phase 3 inputs and verify their recorded hashes. A valid hash proves byte identity only; source association meaning still needs matching lane, identity/MFA, archive row, citation/span, repository ref, and independent review.

### Static-only source access gate

**Source:** `04-CONTEXT.md:23-26,78-80`; `03-05-PLAN.md:137-139,153`.

Do not read any target source body before all of these bind to the same exact request: complete file identities and spans, independent metadata review of the schedule, passing `bin/planning_health --stage execute --phase 4`, and a fresh direct count. Rebuild the schedule, review, preflight, and count after any input/span/context change. Once permitted, inspect only the exact scheduled complete spans and keep the request within the file/token caps without truncation. Keep the phase static-only: never invoke audited functions, callbacks, atom sinks, runtime evaluation, or generated-code paths. If a gate or provenance item is missing, emit a typed gap and stop.

## No Exact Implementation Analog

| File | Missing analog | Planner guidance |
|------|----------------|------------------|
| `04-COVERAGE-CALLER-TRACE.json` | No independently reviewed caller/selector derivation exists yet. | Follow the exact Phase 3 consumer contract; do not infer closure from counts or port the helper's unconditional `true` flag. |
| `04-SIZING-DIGEST-PROOF.json` | The legacy nested digest selector/encoding is not established. | Reproduce only from known selector/order/encoding; otherwise preserve unresolved legacy status and separately version the supplement digest. |

The Phase 3 metadata-gap JSONL is a requested generated-data analog in this in-progress worktree; it is not a tracked source file. The only source-code analog named above was verified with `git ls-files` and is tracked. No OTP/library target source bodies or Phase 4 output-file bytes were read.

## Metadata

**Analog search scope:** Phase 3 plans/metadata-gap artifacts and the two support/test files explicitly permitted for this map.  
**Source patterns excerpted:** `test/support/guard_aggregate_reconciliation_evidence.ex`; both permitted support/test files were searched for existing helpers.  
**Large generated evidence:** `03-04-METADATA-GAPS.jsonl` is 4,815 rows; inspected only its first row as a shape sample, not the full generated evidence set.  
**Pattern extraction date:** 2026-11-17
