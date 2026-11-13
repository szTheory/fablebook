# Phase 2: Bounded ASN.1 RTT guard evidence - Pattern Map

**Mapped:** 2026-11-12  
**Files classified:** 5 new outputs plus two read-only helpers  
**Analogs found:** 5 / 5; lane evidence and contract files map to existing close analogs

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `test/support/sweep_evidence.ex` | existing archive resolver; read-only in Phase 2 | resolve exact lane-bound source bytes | `test/support/sweep_evidence.ex` | exact |
| `test/support/asn1_rtt_core_evidence.ex` | core lane evidence model / utility | static evidence assembly | `test/support/sweep_evidence.ex` (`GeneratorDispatchCoreEvidence`) | exact |
| `test/support/asn1_rtt_floor_evidence.ex` | floor lane evidence model / utility | static evidence assembly | `test/support/sweep_evidence.ex` (`GeneratorDispatchFloorEvidence`) | exact |
| `test/support/installed_otp.ex` | test utility (reuse point; modification not currently expected) | batch lane inventory and Xref | `test/support/installed_otp.ex` (`export_inventory!/2`, `assert_xref_query!/5`) | exact |
| `test/contract/asn1_rtt_core_guard_test.exs` (new) | core lane contract test | core source evidence and individual controls | `test/contract/tier_sweep_test.exs` (EX-107 audit and lane-specific table checks) | close |
| `test/contract/asn1_rtt_floor_guard_test.exs` (new) | floor lane contract test | floor source evidence and individual controls | `test/contract/tier_sweep_test.exs` (EX-107 audit and lane-specific table checks) | close |
| `test/contract/asn1_rtt_integration_test.exs` (new) | integration-only contract and inline evidence assertions | cross-lane membership, partitions, control reconciliation | `test/contract/tier_sweep_test.exs` (EX-107 audit) | close |

Core and floor write to their own support modules and contract tests. Plan 02-03 owns one integration contract file with evidence assertions inline; it reads both lane evidence modules only after Wave 1. `test/support/sweep_evidence.ex` remains the read-only approved archive resolver, and `test/support/installed_otp.ex` supplies inventory/Xref helpers without modification. No production file, dependency, CI lane, or generic audit framework is in scope.

## Pattern Assignments

### `test/support/sweep_evidence.ex` (test evidence model / utility, static evidence assembly)

**Analog:** `test/support/sweep_evidence.ex`, `GeneratorDispatchCoreEvidence` (lines 702-890) and `GeneratorDispatchFloorEvidence` (lines 896-1078).

**Lane-bound record pattern** (lines 901-930):

```elixir
@exact_sources [
  {"asn1/src/asn1ct_func.erl", 4347,
   "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"},
  {"asn1/src/asn1ct_rtt.erl", 134_820,
   "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"}
]

def record do
  %{
    lane: "floor",
    original_id: "EX-107",
    owner: "01.1.1.4",
    semantic_status: :pending,
    method: :source_only,
    exact_sources: @exact_sources,
    selected_function_evidence: selected_function_evidence(),
    callback_trace: [...],
    rtt_literal_body: %{...}
  }
end
```

**Per-function source evidence pattern** (lines 964-989; the core record uses the same shape at lines 755-863):

```elixir
function(
  {:asn1ct_func, :need, 1},
  :existing_atom_lookup,
  [
    {"asn1/src/asn1ct_func.erl:44", "need({binary,_,_}) ->"},
    {"asn1/src/asn1ct_func.erl:46", "need({erlang,_,_}) ->"},
    {"asn1/src/asn1ct_func.erl:48", "need(MFA) ->"},
    {"asn1/src/asn1ct_func.erl:49", "asn1ct_rtt:assert_defined(MFA)"}
  ],
  "Only fixed binary and erlang module exceptions bypass the exact RTT lookup; the ordinary path checks an already formed MFA and sends a fixed need request."
)
```

The phase should add exact lane-specific entries for only `asn1ct_rtt:assert_defined/1`, `code/0`, and `dependencies/1`, including complete target spans, direct caller citations, and a reasoned static disposition. Keep core and floor identities separate; `@asn1_source_identities` already binds the RTT source bytes in `sweep_evidence.ex:92-253`. Existing generator-dispatch records are pending source leads for other selected functions: preserve their `semantic_status: :pending` and do not treat their eleven-function selection or interim findings as this phase's verdict. The historical 13-MFA selection remains independently owned by the contract test.

**Exact citation resolver** (lines 328-342):

```elixir
def resolve!(evidence, citation) do
  {relative, line} = parse_citation!(citation)
  row = source_record!(evidence, relative, citation)
  {path, root, origin} = source_file!(evidence, row, relative, citation)
  path = realpath!(path)
  root = realpath!(root)
  if not String.starts_with?(path, root <> "/"), do: fail!(:source_escape, citation)
  data = read!(path)
  if digest(data) != row["sha256"], do: fail!(:source_digest, {citation, origin})
  lines = source_lines(data)
  if line > length(lines), do: fail!(:source_line, citation)
  ...
end
```

Use the resolver for exact archive citations and retain its lane, containment, digest, and line-bound checks. The archive already contains the approved core and floor `asn1ct_rtt.erl` and `asn1ct_func.erl` source identities; do not add network fetches or substitute the opposite lane.

---

### `test/contract/tier_sweep_test.exs` (contract test, batch inventory and static evidence assertions)

**Analog:** `test/contract/tier_sweep_test.exs`, the `code/0` lane tests at lines 109-137 and 274-316, and `assert_asn1_generator_dispatch_audit!/4` at lines 12819-13120.

**Byte-only full-table proof** (lines 109-137):

```elixir
evidence = archive_only_evidence!()
source = SweepEvidence.resolve!(evidence, "asn1/src/asn1ct_rtt.erl:542")
bytes = File.read!(source.path)
body = rtt_body!(bytes)
grammar = rtt_grammar()

assert Regex.match?(grammar, body)
assert length(Regex.scan(Regex.compile!(row_pattern()), body)) == 258

refute Regex.match?(grammar, String.replace(body, <<"<<\"">>, "<<integer_to_binary(1)>>", global: false))
refute Regex.match?(grammar, body <> " erlang:halt().")
truncated = String.trim_trailing(body) |> then(&binary_part(&1, 0, byte_size(&1) - 2))
refute Regex.match?(grammar, truncated)
```

The floor test uses the same bounded byte grammar with its own archived start line, end line, row count, digest, and malformed-shape controls (lines 274-316). Keep all `code/0` bytes outside the planning prompt and inspect them only as bytes. Never parse/evaluate the payload or invoke the audited function.

**Preserve the original row while asserting the active lane set** (lines 12825-12860):

```elixir
lane_matches = Map.fetch!(row.lane_matches, lane) |> MapSet.new()

live_matches =
  graph.full_exported
  |> Enum.filter(&asn1_original_match?/1)
  |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
  |> Enum.map(&mfa_string!/1)
  |> MapSet.new()

assert live_matches == lane_matches
assert MapSet.size(lane_matches) == 177
```

Copy complete-row equality and add explicit Phase 2 assertions for the selected three and their 174-member full-row complement. Preserve the existing `@asn1_expected_selected_mfas` 13-member historical selection and its 164-member remainder as a separate partition; the historical audit also covers a different 11-function generator-dispatch selection. Do not edit those constants/counts to make them represent the new slice.

**Non-vacuous guard-removal controls** (lines 12935-13075):

```elixir
for mfa <- guarded do
  pattern = Enum.find(guard_patterns, fn {module, function, arity} ->
    module == elem(mfa, 0) and function == elem(mfa, 1) and arity in [:_, elem(mfa, 2)]
  end)

  assert pattern in tier
  without_guard = Enum.reject(tier, &(&1 == pattern))

  assert disposition(mfa, without_guard, BannedCalls.banned_names(), @exclusions) ==
           :compiler_pass
  assert disposition(
           mfa,
           without_guard,
           BannedCalls.banned_names(),
           List.delete(@exclusions, safe_exclusion)
         ) == nil
end
```

This existing removal pattern makes the target observable first through its individual active guard and then through the EX-107 fallback. Adapt the control to each selected function and lane: each positive control must demonstrate the intended static finding, and each negative control must independently show the matching guard rejects a non-target or altered shape. Retain the actual-library-collision stop; the existing generator-dispatch audit checks the `lib/` call set in `assert_generator_dispatch_lib_scope!/2` (around lines 12985-13010), but any newly justified collision must still report the exact MFA, call site, input trace, and triggering guard for owner review.

## Shared Patterns

### `test/support/installed_otp.ex` (test utility, batch lane inventory and Xref)

**Source:** `test/support/installed_otp.ex:255-269, 400-435`  
**Use as-is for:** integration assertions over the pinned core and floor lanes. The existing inventory and Xref parity helpers appear sufficient; only modify this file if preflight finds a concrete missing helper.

```elixir
def export_inventory!(directories, opts \\ []) when is_list(directories) do
  lane = Keyword.get(opts, :lane, lane_name())
  beam_chunks = Keyword.get(opts, :beam_chunks, &:beam_lib.chunks/2)
  used_predefined_exports = predefined_export_targets!(Keyword.get(opts, :edges, []), lane)

  exports = directories |> Enum.flat_map(...)
  duplicate = exports |> Enum.frequencies() |> Enum.filter(fn {_row, count} -> count > 1 end)
  if duplicate != [], do: fail!(:export_inventory_duplicate, %{lane: lane, exports: duplicate})
  exports
end
```

Reuse the existing exported-MFA inventory and graph. The contract can filter the exact `asn1ct_rtt` targets and compare Xref edges; graph membership is caller evidence, not by itself a semantic disposition or proof that dynamic callers do not exist.

### Compile-only, individually attributable controls

**Source:** `test/contract/banned_calls_test.exs:1714` and surrounding selected-file debugger control; the EX-107 removal-based pattern is in `test/contract/tier_sweep_test.exs:12935-13075`.  
**Apply to:** positive and negative static controls; no audited OTP function, callback, or atom sink may be invoked.

```elixir
assert {:ok, scan} = BeamWalker.scan(beam)
mfa = {:dbg_wx_interpret, :start, 4}
assert {:mfa, mfa} in hits(scan)

refute {:mfa, mfa} in hits(scan, Enum.reject(@mfa_tier, &(&1 == mfa))),
       "the uncalled positive probe must depend on its individual MFA tier"
```

Existing fixtures create an uncalled module, compile it, then inspect its BEAM and source check. Keep that static/compile-only boundary. Do not invoke fixtures or audited library behavior to produce evidence.

### Safety and delivery boundary

**Sources:** `docs/adr/0004-no-eval-no-new-atoms.md`, `docs/adr/0014-testing-strategy.md`, `docs/adr/0021-delivery-rules.md`, and phase `02-CONTEXT.md` D-04 through D-10.  
**Apply to:** all support and contract changes.

- Keep changes contract-only and separate from any implementation they guard.
- Never invoke the three audited functions, callbacks, generated code, or atom sinks.
- State the static evidence limits: runtime behavior, dynamic callers, native internals, and SEC-01 remain unproven.
- If a newly justified guard hits a real `lib/` call site, stop that affected work and report the exact MFA, call site, input trace, and triggering guard.
- Keep both full-row and historical-subset counts distinct; don't select further work automatically.
- Retain the source-per-task, task-per-plan, plan-per-phase, token, effort, review, exact-head, and hosted candidate/main CI gates from the locked context.

## New Surface Without an Exact Analog

The three lane-scoped contract files do not exist yet. Their closest analog is the EX-107 evidence and byte-table coverage in `test/contract/tier_sweep_test.exs`; the integration file owns only cross-lane membership, exact partitions, and reconciliation, leaving lane controls in their independent tests.

## Metadata

**Analog search scope:** `test/support/`, `test/contract/`, `credo/checks/`, plus phase CONTEXT/RESEARCH.  
**Source files read for patterns:** 5 tracked analog files; 5 planned outputs classified. Plan 02-03 Task 1 also reads only the historical membership constant and its component MFA lists at `tier_sweep_test.exs:4208-4227`; this fifth exact-source read is included in that task's source/context ledger. Other tasks use this extracted map instead of rereading the file.
**Tracked-source check:** All named analogs (`test/support/sweep_evidence.ex`, `test/support/installed_otp.ex`, `test/contract/tier_sweep_test.exs`, `test/contract/banned_calls_test.exs`, `credo/checks/banned_calls.ex`) are git-tracked source files.  
**Pattern extraction date:** 2026-11-12.
