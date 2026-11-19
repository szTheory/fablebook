# Phase 3: Guard aggregate scope rejoin and candidate sizing - Pattern Map

**Mapped:** 2026-11-13
**Files analyzed:** 5 planned evidence boundaries (one existing contract file is extended)
**Analogs found:** 5 pattern groups / 7 tracked files

The phase context leaves evidence filenames and layout to planning. Plans 03-01 through 03-04 choose two independent lane records as the machine-readable source of truth, one derived review/sizing report, tagged extensions to the existing authoritative TierSweepTest, and a narrow collector for the missing aggregate receipt. Reuse the existing inventory/source helpers; do not duplicate their mechanisms or the private ledger. No inventory or candidate fit is already established by these analogs.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `test/contract/tier_sweep_test.exs` (extend existing) | test | transform | `test/contract/tier_sweep_test.exs` | exact implementation site; owns private ledger, compiled matchers and full graph; ASN.1 integration is a secondary assertion analog |
| `test/support/guard_aggregate_reconciliation_evidence.ex` | utility | transform | `test/support/installed_otp.ex` | partial; same current-export collection, not the full ledger join |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json` | model | batch | `test/support/asn1_rtt_core_evidence.ex` | role-match |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json` | model | batch | `test/support/asn1_rtt_floor_evidence.ex` | role-match |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md` | model | transform | `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md` | role-match |

Each lane record should retain lane/runtime/lock provenance, the complete export inventory, original exclusion identity and owner mapping, exact per-row member sets and differences, plus lane-specific source and caller/delegate references. The markdown should derive its crosswalk and sizing/owner-decision summary from those records instead of maintaining another copy of membership facts. These names record the plans' choices within the discretion granted by CONTEXT.md.

## Pattern Assignments

### `test/contract/tier_sweep_test.exs` (existing test, transform)

**Primary analog and implementation site:** `test/contract/tier_sweep_test.exs`.

Extend the existing TierSweepTest module because it owns the authoritative private `original_identity_ledger!`, compiled matcher tables and current full graph. Add aggregate, records and bundle tags as specified in Plans 03-01/03-04, then pass the existing ledger/matcher/graph values to the narrow collector. Preserve the private authority in place; do not move, duplicate or reinterpret it in another contract file. The planned checks are not yet execution evidence.

**Secondary assertion analog:** `test/contract/asn1_rtt_integration_test.exs` for exact membership, distinct historical partitions and lane/source assertions. The excerpts below belong to that secondary analog. Retain TierSweepTest's existing module/setup; do not copy ASN.1-specific aliases or its selected membership as aggregate authority.

**Secondary analog imports** (within its module, lines 2-7):

```elixir
use ExUnit.Case, async: false

alias Fablebook.Test.Asn1RttCoreEvidence
alias Fablebook.Test.Asn1RttFloorEvidence
alias Fablebook.Test.InstalledOtp
alias Fablebook.Test.SweepEvidence
```

**Fixture setup** (lines 36-40):

```elixir
setup do
  evidence = SweepEvidence.source_roots!()
  on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
  {:ok, evidence: evidence}
end
```

Use the project's ExUnit contract surface and lane-aware helpers. There is no application authentication or request guard in this static-evidence flow. Preserve the hard boundary: inventory exports and inspect source bytes; do not invoke an audited OTP function, callback, atom sink, or generated-code path.

**Exact membership and distinct partitions** (lines 42-88):

```elixir
assert live == expected,
       "EX-107/#{lane} differs from the preserved exact lane membership"

full_complement = MapSet.difference(expected, selected)
assert MapSet.disjoint?(selected, full_complement)
assert MapSet.union(selected, full_complement) == expected

historical_complement = MapSet.difference(expected, historical)
assert MapSet.disjoint?(historical, historical_complement)
assert MapSet.union(historical, historical_complement) == expected
assert MapSet.disjoint?(historical, selected)

still_pending = MapSet.difference(historical_complement, selected)
assert MapSet.disjoint?(selected, still_pending)
assert MapSet.union(historical, selected) |> MapSet.union(still_pending) == expected
```

Copy the equality/disjointness/union structure, then assert exact lane-specific additions, missing members, delivered sets, and pending complements. Keep EX-010 and the separate EX-107 3/174 and 13/164/161 historical partitions as distinct identity sets; do not turn counts into proof or reuse the EX-107 set as the new candidate.

**Source identity checks** (lines 101-114):

```elixir
for entry <- core_entries do
  assert entry.source.identity.lane == "core"
  assert entry.caller.identity.lane == "core"
  positive_source = SweepEvidence.resolve!(core, positive_span.citation)
  assert Asn1RttCoreEvidence.guard_matches?(entry, positive_text)
end
```

Apply the lane-equality and resolver checks to every surviving target and caller/delegate edge. Represent missing evidence explicitly and fail candidate selection when a required source or path is missing. Static graph evidence must not be described as proof that dynamic callers are absent or that runtime behavior is safe.

### `test/support/guard_aggregate_reconciliation_evidence.ex` (utility, transform)

**Analog:** `test/support/installed_otp.ex`

**Pinned lane identity and fail-closed export inventory** (`test/support/installed_otp.ex`, lines 28-31 and 255-278):

```elixir
@lanes %{
  "core" => %{elixir: "1.20.4", otp: "29.1.2"},
  "floor" => %{elixir: "1.18.5", otp: "27.3.4.9"}
}

def export_inventory!(directories, opts \\ []) when is_list(directories) do
  lane = Keyword.get(opts, :lane, lane_name())
  beam_chunks = Keyword.get(opts, :beam_chunks, &:beam_lib.chunks/2)
  used_predefined_exports = predefined_export_targets!(Keyword.get(opts, :edges, []), lane)

  exports =
    directories
    |> Enum.flat_map(
      &export_inventory_directory!(&1, lane, beam_chunks, used_predefined_exports)
    )

  duplicate = exports |> Enum.frequencies() |> Enum.filter(fn {_row, count} -> count > 1 end)
  if duplicate != [], do: fail!(:export_inventory_duplicate, %{lane: lane, exports: duplicate})
  exports
rescue
  error in Error ->
    reraise error, __STACKTRACE__

  error ->
    fail!(:export_inventory_read, %{
      lane: Keyword.get(opts, :lane, lane_name()),
      error: Exception.message(error)
    })
end
```

Reuse `export_inventory!/2` rather than creating another BEAM scanner. Plans 03-01 through 03-04 choose the narrow aggregate collector to materialize the missing complete original-row-to-live-MFA receipt, receiving authoritative ledger/graph inputs from TierSweepTest. Keep each lane independent, reject duplicate or mismatched identities, and emit all members rather than counts.

**Source/archive provenance helper:** `test/support/sweep_evidence.ex` (lines 274-303, 328-347) is the companion pattern for lock validation and exact source resolution:

```elixir
for {_lane, lock} <- evidence.manifest["locks"] do
  actual = read!(lock["path"]) |> digest()
  if actual != lock["sha256"], do: fail!(:lock_identity, lock["path"])
end

{path, root, origin} = source_file!(evidence, row, relative, citation)
path = realpath!(path)
root = realpath!(root)
if not String.starts_with?(path, root <> "/"), do: fail!(:source_escape, citation)
data = read!(path)
if digest(data) != row["sha256"], do: fail!(:source_digest, {citation, origin})
```

The helper checks lane-specific pins, safe resolved paths, and source digests before returning a citation. Do not hand-roll archive extraction or silently substitute a source from the other lane.

### `03-CORE-AGGREGATE-EVIDENCE.json` and `03-FLOOR-AGGREGATE-EVIDENCE.json` (model, batch)

**Analog pair:** `test/support/asn1_rtt_core_evidence.ex` and `test/support/asn1_rtt_floor_evidence.ex`

Core evidence records bind each target and caller to a lane-specific source identity, citation/span, digest, and caller path (`test/support/asn1_rtt_core_evidence.ex`, lines 4-37):

```elixir
@rtt_identity %{
  lane: "core",
  path: "asn1/src/asn1ct_rtt.erl",
  bytes: 135_654,
  sha256: "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"
}

%{
  mfa: {:asn1ct_rtt, :assert_defined, 1},
  source: %{
    identity: @rtt_identity,
    citation: "asn1/src/asn1ct_rtt.erl:17",
    first_line: 17,
    last_line: 120,
    span_sha256: "7987a2f35a6e22363efb55fb5df65084046b47fa7a574d1107e66443838a2066"
  },
  caller: %{
    identity: @caller_identity,
    path: [{:asn1ct_func, :need, 1}],
    spans: [
      %{
        citation: "asn1/src/asn1ct_func.erl:48",
        first_line: 48,
        last_line: 54,
        span_sha256: "04570a05b813bcc8d28cdcd9524c214018b2df0e26ff8a7d13ba24f1602f3597"
      }
    ]
  }
}
```

The floor record similarly puts `lane: "floor"`, `original_id`, method, exact sources, and selected-function evidence together (`test/support/asn1_rtt_floor_evidence.ex`, lines 9-18). Copy the explicit lane and provenance shape only. Its facts and EX-107 membership are bounded to that historical row and must not be generalized to the aggregate ledger. In the new JSON records, retain full inventory and exact per-row sets, not just selected evidence.

### `03-RECONCILIATION.md` (model, transform)

**Analog:** `.planning/milestones/v0.2-phases/01-bounded-guard-continuation/01-SIZING.md`

**Sizing table and isolated context/reserve** (lines 15-25):

```markdown
| Serial plan | Source or structured findings context | Preserved reserve | Total ceiling estimate | Conservative effort |
|---|---:|---:|---:|---|
| Core lane: full review ... | 36,518 | 31,000 | 67,518 | 1–2 working days |
| Floor lane: full review ... | 38,888 | 31,000 | 69,888 | 1–2 working days |

Each plan is under 100,000 in its own isolated context. ... Never truncate relevant source or omit a connected file to meet the ceiling.
```

Use a source-file manifest and isolated plan-context table with exact full-file and reread counts, reserves, and itemized effort. Recompute them for Phase 3; historical figures are a shape example only. End with either one evidence-backed candidate and its full complement or a concrete no-candidate gap/remedy, plus the explicit owner decision. Keep the aggregate gate open, SEC-01 with its existing owner, the Walking Skeleton blocked, and the manual actual-library-collision stop in force.

## Shared Patterns

### Authoritative ledger and tagged aggregate entry

**Implementation site:** `test/contract/tier_sweep_test.exs`, as chosen by Plans 03-01 through 03-04.

Keep original identity, matcher and full-graph authority in the existing module. Aggregate checks use `:guard_aggregate_reconciliation`; records-only and bundle checks also carry their respective sub-tags. Use the same tagged entry on both pinned lanes and verify nonzero test selection. The ASN.1 integration test supplies assertion patterns only.

### Lane identity and provenance

**Sources:** `test/support/installed_otp.ex:28-31, 255-278`; `test/support/sweep_evidence.ex:274-303, 328-347`; lane evidence analogs above.

Keep core and floor evidence separate from collection through review. Bind each record to pinned runtime/lock identity and exact source digests, and fail closed on lane, export, archive, path, or digest mismatch.

### Exact set reconciliation

**Source:** `test/contract/asn1_rtt_integration_test.exs:42-88`.

Store and compare full identity/member sets. Show selected, delivered, added, missing, and pending members directly; use set equality, disjointness, and union assertions. Preserve every original exclusion identity and row owner, and preserve historical partitions independently.

### Static-only evidence

**Sources:** `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md:8-14, 91-99`; `docs/adr/0004-no-eval-no-new-atoms.md`.

Inventory BEAM metadata and inspect source bytes only. Source/caller records and empty static edge sets do not establish dynamic-caller absence or runtime safety. A missing provenance or caller path remains an explicit evidence gap.

## No Exact Analog Found

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | utility | transform | No existing single helper joins every original exclusion identity and owner to fresh current core/floor inventories and emits aggregate receipts. Compose the existing inventory and source-resolution helpers with authoritative inputs from TierSweepTest; keep this collector narrowly scoped and read-only. |

## Metadata

**Analog search scope:** `test/support/`, `test/contract/`, and prior guard phase artifacts under `.planning/milestones/`.
**Tracked analogs verified:** `git ls-files -- <path>` returned each named analog path; no gitignored capability/runtime mirror is referenced.
**Files scanned:** 6 previously extracted representative files across 5 pattern groups; the existing TierSweepTest entry-point choice is aligned from Plans 03-01 through 03-04 without another source read.
**Pattern extraction date:** 2026-11-13
