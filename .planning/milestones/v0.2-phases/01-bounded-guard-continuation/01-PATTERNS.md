# Phase 1: Bounded guard continuation — Pattern Map

**Mapped:** 2026-11-11  
**Files analyzed:** 5 anticipated delivery touchpoints  
**Analogs found:** 5 / 5

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `test/fixtures/guards/exact_sources.tar.gz` (embedded `manifest.json`) | test fixture | file-I/O | Archive loader and manifest validation in `test/support/sweep_evidence.ex` | role-match |
| `test/support/sweep_evidence.ex` | utility | file-I/O | Existing exact-source identities, resolver, and GeneratorDispatch evidence records in the same file | exact |
| `test/contract/tier_sweep_test.exs` | test | batch / transform | GeneratorDispatch row, source, caller-edge, and guard contracts in the same file | exact |
| `credo/checks/banned_calls.ex` | utility | transform | Existing exact-MFA table and Credo AST visitor in the same file | exact, conditional on source findings |
| `test/contract/banned_calls_test.exs` | test | transform | Existing uncalled direct/capture/apply probes in the same file | exact, conditional on source findings |

The manifest is embedded in the tracked archive; there is no separate manifest file. Keep semantic records in the existing support and contract authority. Do not add a source-only evidence file. The Credo checker and its contract test are candidates only if the two-lane source review justifies an active static guard.

## Pattern Assignments

### `test/fixtures/guards/exact_sources.tar.gz` (test fixture, file-I/O)

**Analog:** `test/support/sweep_evidence.ex`, lines 283–297 and 360–420.

The fixture is binary, so it has no source excerpt. Extend the approved archive's embedded manifest and archive digest together. Preserve separate `core` and `floor` source identities. The research says the `inets.erl` and `dbg.erl` entries are already present; bind the exact `inets_trace.erl` bytes and hashes before any contract depends on them. Keep using the existing offline archive.

```elixir
def load_archive!(path, expected_sha) do
  bytes = read!(path)
  if digest(bytes) != expected_sha, do: fail!(:archive_digest, path)
  files = archive_files!(bytes)
  manifest = archive_manifest!(files)
  validate_manifest!(manifest, files)
  %{archive_root: extract_files!(files), manifest: manifest}
end
```

`validate_manifest!/2` checks the complete archive inventory and every declared member before source resolution. Do not create a second provenance authority or allow an installed copy to hide a missing lane entry.

### `test/support/sweep_evidence.ex` (utility, file-I/O)

**Analog:** The existing exact-source resolver and `GeneratorDispatch*Evidence` records in this file.

Archive resolution checks path containment, the source digest, and citation line bounds (`resolve!/2`, lines 306–322). Existing lane review records bind each path to its byte length and SHA-256, then store per-MFA citations, interim disposition, and a finding (`GeneratorDispatchCoreEvidence.records/0`, lines 667–854):

```elixir
exact_sources: [
  {"asn1/src/asn1ct_func.erl", 4465,
   "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"}
],
...
function_evidence(
  {:asn1ct_func, :handle_call, 3},
  :active_dynamic_atom_creation_candidate,
  [
    {"asn1/src/asn1ct_func.erl:109", "handle_call({gen_func,Prefix,Key,GenFun}"},
    {"asn1/src/asn1ct_func.erl:112",
     "Name = list_to_atom(Prefix ++ integer_to_list(Gc0))"}
  ],
  "On cache miss, concatenates the request Prefix with a decimal counter and interns the result."
)
```

Keep this record shape but create EX-010-specific source citations, semantic findings, and caller/delegate traces for each lane. Preserve the original row identity and outside-row ownership. Do not copy the ASN.1 finding or claim that a graph edge is a semantic verdict. `GeneratorDispatchIntegrationEvidence.lane_records/0` (lines 1480–1567) shows how structured core and floor findings are joined for integration without reopening source.

### `test/contract/tier_sweep_test.exs` (test, batch / transform)

**Analog:** `assert_asn1_generator_dispatch_audit!/4` and its source, edge, guard, and omission helpers (lines 12045–12359).

The existing audit first compares the complete live lane match set with the original ledger row, then checks the selected subset and remaining matches. The project-defined counts and dispositions here are EX-107-specific; recompute EX-010 membership from the current full lane graph and preserve all other rows.

```elixir
assert live_matches == lane_matches,
       "EX-107/#{lane} differs from the complete live lane match set"

selected_mfas = GeneratorDispatchIntegrationEvidence.selected_mfas()
selected = selected_mfas |> Enum.map(&mfa_string!/1) |> MapSet.new()
assert MapSet.subset?(selected, lane_matches)
assert MapSet.size(MapSet.difference(lane_matches, selected)) == 166
```

`assert_generator_dispatch_sources!/3` verifies manifest byte/hash identity and forces archive-origin resolution; `assert_generator_dispatch_reviews!/4` requires findings and source citations; `assert_generator_dispatch_edges_match!/3` compares the complete recorded edge set with the current graph. Reuse that chain for exact lane hashes, per-MFA source evidence, delegate/caller traces, and selected/remainder equality. Keep the installed-set graph receipt distinct from semantic findings.

The current guard proof tests overlap and removal by showing that removing only an active pattern falls back to the original exclusion, while removing both exposes the selected MFA. The row-preservation helpers also fail when a selected record, edge, or citation is omitted (`assert_generator_dispatch_guards!/3`, `assert_generator_dispatch_omissions!/6`). Use these as control patterns only where an EX-010 disposition requires them; do not carry over EX-107's numbers or matcher.

### `credo/checks/banned_calls.ex` (utility, transform; conditional)

**Analog:** Exact MFA entries in `@mfas` (lines 184–190) and `run/2` with `Credo.Code.prewalk/3` (lines 401–420).

```elixir
@impl Credo.Check
def run(%SourceFile{} = source_file, params) do
  ctx = Context.build(source_file, params, __MODULE__, %{line: nil, aliases: %{}})
  Credo.Code.prewalk(source_file, &walk/2, ctx).issues
end
```

Only add a narrow exact MFA or arity pattern after both-lane source evidence supports retaining a guard. Preserve the existing AST checker and corresponding BEAM tier; the graph, API name, or an unresolved source path alone does not justify a new ban. Keep the contract-only boundary and do not alter production code.

### `test/contract/banned_calls_test.exs` (test, transform; conditional)

**Analog:** Existing uncalled `asn1ct_check.check/2` probes (lines 691–733).

```elixir
for form <- [:direct, :capture, :apply] do
  # Build a fixture function for the selected source form.
  [beam] = compile!([path], dir, true)
  assert {:ok, scan} = BeamWalker.scan(beam)
  assert Enum.any?(hits(scan), &mfa_hit?(&1, mfa))
  tier_without_check = Enum.reject(@mfa_tier, &(&1 == mfa))
  refute Enum.any?(hits(scan, tier_without_check), &mfa_hit?(&1, mfa))
end

assert credo_issues("Regex.compile(pattern)", "asn1ct_check_benign.ex") == []
```

If EX-010 source review retains a guard, use deliberately uncalled direct, capture, and `apply` fixtures, verify both BEAM and Credo detection, prove the specific pattern is necessary, and keep benign and overlap controls. Never execute an audited trace API, callback, or atom sink.

## Shared Patterns

### Exact-lane source authority

**Sources:** `test/support/sweep_evidence.ex:283-297,306-322,360-420`; `test/contract/tier_sweep_test.exs:12136-12190`  
Add only exact core/floor archive identities, require archive-origin citations with matching hashes and byte sizes, and preserve separate lane records. No source truncation or opposite-lane fallback.

### Semantic record and complete partition

**Sources:** `test/support/sweep_evidence.ex:667-854,1480-1567`; `test/contract/tier_sweep_test.exs:12045-12125,12192-12229,12339-12359`  
Record a hash-scoped finding and source citations per selected MFA, caller/delegate edges separately from Xref, individual non-vacuous witnesses, and equality between the full live row and its selected plus remainder sets. Treat EX-011 as outside EX-010 despite shared supporting source.

### Static guard proof

**Sources:** `credo/checks/banned_calls.ex:184-190,401-420`; `test/contract/banned_calls_test.exs:691-733`; `test/contract/tier_sweep_test.exs:12255-12359`  
Apply only if a source-backed disposition requires an active guard. Use uncalled static probes, benign controls, and removal/overlap controls. Keep the fixed no-audited-call boundary.

### Serial plan contexts

Follow `01-SIZING.md`: core review of its three exact sources, floor review of its three exact sources, then integration from hash-scoped structured findings without reopening the six files. Keep tasks at no more than five exact source files, plans serial, and all evidence/reserve intact.

## No Analog Found

There is no existing EX-010 semantic record or `inets_trace` callback/port-dispatch finding. Create those findings in the existing lane evidence authority after full source review. Existing Xref or GeneratorDispatch conclusions cannot supply the EX-010 verdict.

## Metadata

**Analog search scope:** `test/support/`, `test/contract/`, `test/fixtures/guards/`, `credo/checks/`, and the delivered GeneratorDispatch Phase 01.1.1.18 pattern/evidence files.  
**Tracked-source gate:** All repository analogs named above are tracked source; the source archive is tracked.  
**Pattern extraction date:** 2026-11-11
