# Phase 7: Guard Scope Reconciliation - Pattern Map

**Mapped:** 2026-11-19  
**Files analyzed:** 3 inferred evidence artifacts (names are suggestions; CONTEXT.md leaves filenames and shape to planning)  
**Analogs found:** 3 / 3 artifact roles

The phase needs a machine-readable lane reconciliation, a small local validator, and a concise human decision summary. The planner may combine the last two outputs if that keeps the record reviewable. Phase 3 is the closest membership/rejoin precedent; Phase 6 is the closest small evidence-record/checker precedent. All historical numbers, selected keys, lane facts, and hashes below are examples of shape only. None is a Phase 7 baseline.

## File Classification

| New/Modified File (suggested) | Role | Data Flow | Closest Analog | Match Quality |
|-------------------------------|------|-----------|----------------|---------------|
| `.planning/phases/07-guard-scope-reconciliation/07-RECONCILIATION.json` | model | batch | `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json`; `.planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json` | role-match: explicit lane, source identity, bounded observations, complement, and stops; Phase 3 adds full per-lane membership shape |
| `.planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py` | utility | transform / validation | `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py` | strong: local standard-library checker with explicit inputs, exact record checks, reproducible complement, stop checks, and negative controls |
| `.planning/phases/07-guard-scope-reconciliation/07-RECONCILIATION.md` | model | transform | `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-VALIDATION.md` | role-match: concise human-readable scope, automated evidence, limitations, and sign-off; include the required recommendation and owner decision boundary |

## Pattern Assignments

### `07-RECONCILIATION.json` (model, batch)

**Primary analog:** `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json`.

**Separate pinned lane records** (lines 23-37 and 53-65):

```json
"lanes": {
  "core": {
    "runtime": {"elixir": "1.20.4", "otp": "29.1.2"},
    "phoenix": {"version": "1.8.16", "lock_file": "mix.lock"},
    "source": {
      "recorded_value": "_build/lanes/core/deps/phoenix/lib/mix/tasks/phx.gen.context.ex",
      "bytes": 14760,
      "sha256": "c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e"
    }
  },
  "floor": {
    "runtime": {"elixir": "1.18.5", "otp": "27.3.4.9"},
    "phoenix": {"version": "1.8.9", "lock_file": "mix.floor.lock"},
    "source": {"recorded_value": "...", "bytes": 14760, "sha256": "..."}
  }
}
```

Retain this explicit per-lane provenance shape, replacing every example with freshly checked Phase 7 values. Keep identity and membership independent per lane through reconciliation. Stop on any lane/source identity mismatch; do not merge inventories from different generations. Source paths may be recorded as evidence values, but the checker should only read inputs explicitly authorized by the phase.

**Membership and complement shape** (Phase 3 `.planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json`, lines 40-66 and 115-166):

```json
"inventory_universe": {"count": 50568, "exported_mfas_sha256": "..."},
"identity_rows": {"selector": "identity_rows", "count": 226, "sha256": "..."},
"pending_complement": {
  "set_difference": "unique_sorted_union(identity_rows[*].original_live_mfas) minus unique_sorted_union(identity_rows[*].delivered_scope_mfas)",
  "original_live_mfas": {"unique_mfas": 1754, "canonical_mfa_set_sha256": "..."},
  "delivered_scope_mfas": {"unique_mfas": 5, "canonical_mfa_set_sha256": "..."},
  "new_selected_mfas": [],
  "unique_mfas": 1749,
  "canonical_mfa_set_sha256": "..."
}
```

Use the explicit universe, selected-family, and complement relationship, with sorted canonical members, counts, and reproducible digests for each lane. Preserve exact additions and removals against that lane's saved inventory. The old EX-010 identity, historical counts, and hashes are not current evidence and must not be copied as values.

**Bounded observation and stop fields** (Phase 6 record, lines 83-107, 133-162):

```json
"caller_closure": {
  "observed_direct_calls_per_lane": 1,
  "exhaustive": false,
  "statement": "One observed direct run/1 call per lane does not establish exhaustive caller closure; external callers, dynamic edges, callbacks, and delegates remain open."
},
"preserved_stops": {
  "candidate_fit": "unresolved",
  "candidate": null,
  "aggregate_gate": "open",
  "actual_library_collision": "unknown",
  "automatic_followup": false
}
```

Keep source/caller/delegate observations keyed to lane and provenance, and make dynamic, external, callback, and unresolved paths explicit gaps. Preserve all Phase 7 stops from CONTEXT.md and RESEARCH.md exactly; the example values above illustrate the shape only. A proposed evidence family remains distinct from candidate selection or promotion.

### `07-validate-reconciliation.py` (utility, transform / validation)

**Analog:** `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py`.

**Explicit input boundary and duplicate-key rejection** (lines 148-160):

```python
def read_input(relative_path):
    if relative_path not in INPUT_PATHS:
        raise ValueError("unapproved evidence input: " + str(relative_path))
    return (ROOT / relative_path).read_bytes()

def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON object key: " + key)
        result[key] = value
    return result
```

Build a small explicit Phase 7 input allowlist. Do not turn recorded target paths into implicit checker reads or add caller searches. Parse strict JSON/JSONL and reject duplicate object keys, malformed rows, and unexpected top-level fields.

**Exact record, lane, family, and complement checks** (lines 183-200, 264-309, and 407-433):

```python
def exact_equal(expected, observed):
    if type(expected) is not type(observed):
        return False
    if isinstance(expected, dict):
        return expected.keys() == observed.keys() and all(
            exact_equal(expected[key], observed[key]) for key in expected
        )
    if isinstance(expected, list):
        return len(expected) == len(observed) and all(
            exact_equal(left, right) for left, right in zip(expected, observed)
        )
    return expected == observed

complement_digest = hashlib.sha256(b"".join(complement_lines)).hexdigest()
expect("complement.sha256", complement_digest, COMPLEMENT_SHA256)
```

For Phase 7, recompute the current membership and exact set partition independently for each lane: the proposed family and complement must be disjoint and their union must equal that lane's full relevant membership. Validate lane identity before comparing counts or digests; counts alone are not identity. Verify schema, full member lists, additions/removals, canonical count/hash pairs, observation keys, and explicit stop-state. Fail at the first unexplained mismatch.

**Focused negative controls** (lines 436-483):

```python
rejects("missing key", lambda record: record["observations"].pop())
rejects("wrong lane", lambda record: record["observations"][0].update({"lane": "floor"}))
rejects("complement count drift", lambda record: record["complement"].update({"rows": COMPLEMENT_COUNT + 1}))
rejects("complement digest drift", lambda record: record["complement"].update({"sha256": "0" * 64}))
rejects("changed stop state", lambda record: record["preserved_stops"].update({"aggregate_gate": "closed"}))
```

Adapt these controls to reject missing/extra membership rows, lane swaps or source identity drift, incomplete/overlapping partitions, count or digest drift, accidental exhaustive-caller claims, and any mutation of candidate-null, aggregate-open, R9-unconsumed, collision, or automatic-follow-up stops. Keep the checker standard-library-only and phase-local, as Phase 6's validation strategy does (06-VALIDATION.md lines 12-22 and 37-43).

### `07-RECONCILIATION.md` (model, transform)

**Analog:** `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-VALIDATION.md`.

The Phase 6 receipt presents a one-off evidence checker, its quick command, focused scope, and explicit limit on caller claims (lines 12-22 and 37-43). Use the same concise structure, adapted to Phase 7's required result: per-lane identity/membership outcome, exact proposed family and full complement counts/digests, bounded observations and gaps, refreshed source/context/effort sizing, preserved stops, one recommendation, and the explicit owner decision point. Keep older membership and EX-177 facts labeled as historical inputs.

## Shared Patterns

### Exact per-lane set reconciliation

**Source:** `.planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-PATTERNS.md`, lines 54-74.

```elixir
assert live == expected,
       "EX-107/#{lane} differs from the preserved exact lane membership"

full_complement = MapSet.difference(expected, selected)
assert MapSet.disjoint?(selected, full_complement)
assert MapSet.union(selected, full_complement) == expected
```

Use the equality, disjointness, and union checks with Phase 7's exact lane membership and proposed family. In a Python evidence checker, use equivalent set assertions; do not transfer the historical selection.

### Cheapest checks first

**Source:** Phase 7 CONTEXT.md and `.planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-validate-supplement.py`, lines 252-309.

Order checks as: pinned lane/source identity; input schema/duplicate keys; prior-inventory membership equality and exact diff; family/complement partition, counts, and digests; then bounded source/caller/delegate observation references. Stop at the first unexplained mismatch instead of combining generations or performing longer review on invalid inputs.

## No Exact Analog Found

| File / concern | Role | Data Flow | Reason |
|----------------|------|-----------|--------|
| Fresh complete current membership rejoin across both pinned lanes | model / utility | batch | Archived Phase 3 records and Phase 6's complement describe prior, bounded evidence. Neither is the current Phase 7 membership baseline. Recompute the authorized current evidence and compare it with the saved inventories; stop on identity or membership drift. |

## Metadata

**Analog search scope:** v0.4 Phase 3 pattern map and keyed evidence; v0.5 Phase 6 evidence record, checker, and validation receipt.  
**Tracked analogs verified:** each named analog path is tracked by Git; no ignored install/runtime mirror is referenced.  
**Pattern extraction date:** 2026-11-19
