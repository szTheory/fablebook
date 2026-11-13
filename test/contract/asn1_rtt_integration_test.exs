defmodule Fablebook.Test.Asn1RttIntegrationTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.InstalledOtp
  alias Fablebook.Test.Asn1RttCoreEvidence
  alias Fablebook.Test.Asn1RttFloorEvidence
  alias Fablebook.Test.SweepEvidence

  @budget_path Path.expand(
                 "../../.planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.json",
                 __DIR__
               )
  @budget_sha256 "c25de2e909b972d308a4c28820e99ae7731b78edfdbdcb941c2eb1b77c506aa0"
  @selected_mfas [
    {:asn1ct_rtt, :assert_defined, 1},
    {:asn1ct_rtt, :code, 0},
    {:asn1ct_rtt, :dependencies, 1}
  ]
  @historical_mfas [
    {:asn1ct_table, :new, 1},
    {:asn1ct_table, :new_reuse, 1},
    {:asn1ct_table, :exists, 1},
    {:asn1ct_table, :size, 1},
    {:asn1ct_table, :insert, 2},
    {:asn1ct_table, :lookup, 2},
    {:asn1ct_table, :match, 2},
    {:asn1ct_table, :to_list, 1},
    {:asn1ct_table, :delete, 1},
    {:asn1ct_check, :check, 2},
    {:asn1ct_gen, :insert_once, 2},
    {:asn1ct_eval_ext, :transform_to_EXTERNAL1994, 1},
    {:asn1ct_eval_ext, :transform_to_EXTERNAL1994_maps, 1}
  ]
  @collision_report_fields [:mfa, :call_site, :input_trace, :triggering_guard]

  setup do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    {:ok, evidence: evidence}
  end

  test "the full EX-107 row matches each exact lane archive and retains separate partitions", %{
    evidence: evidence
  } do
    lane_sets = archived_lane_sets!()
    assert Map.keys(lane_sets) |> Enum.sort() == ["core", "floor"]

    core = Map.fetch!(lane_sets, "core")
    floor = Map.fetch!(lane_sets, "floor")
    assert core == floor, "the pinned core and floor EX-107 memberships differ"
    assert MapSet.size(core) == 177
    assert MapSet.size(floor) == 177

    lane = evidence.lane.name
    expected = Map.fetch!(lane_sets, lane)
    live = live_asn1_matches!(evidence, lane)
    assert live == expected,
           "EX-107/#{lane} differs from the preserved exact lane membership"

    selected = MapSet.new(Enum.map(@selected_mfas, &mfa_string/1))
    assert selected == MapSet.new([
             "asn1ct_rtt:assert_defined/1",
             "asn1ct_rtt:code/0",
             "asn1ct_rtt:dependencies/1"
           ])
    assert MapSet.subset?(selected, expected)
    full_complement = MapSet.difference(expected, selected)
    assert MapSet.size(full_complement) == 174
    assert MapSet.disjoint?(selected, full_complement)
    assert MapSet.union(selected, full_complement) == expected

    historical = MapSet.new(Enum.map(@historical_mfas, &mfa_string/1))
    assert MapSet.size(historical) == 13
    assert MapSet.subset?(historical, expected)
    historical_complement = MapSet.difference(expected, historical)
    assert MapSet.size(historical_complement) == 164
    assert MapSet.disjoint?(historical, historical_complement)
    assert MapSet.union(historical, historical_complement) == expected
    assert MapSet.disjoint?(historical, selected)

    still_pending = MapSet.difference(historical_complement, selected)
    assert MapSet.size(still_pending) == 161
    assert MapSet.disjoint?(selected, still_pending)
    assert MapSet.union(historical, selected) |> MapSet.union(still_pending) == expected
  end

  test "the six lane/function controls stay individual, non-vacuous, and static", %{
    evidence: evidence
  } do
    assert Asn1RttCoreEvidence.entries() |> Enum.map(& &1.mfa) == @selected_mfas

    core = archive_lane!(evidence, "core")
    core_entries = Asn1RttCoreEvidence.entries()
    core_guards = MapSet.new(Enum.map(core_entries, & &1.control.guard))
    assert MapSet.size(core_guards) == 3

    for entry <- core_entries do
      assert entry.source.identity.lane == "core"
      assert entry.caller.identity.lane == "core"
      assert String.length(entry.disposition) > 0
      positive_span = Enum.at(entry.caller.spans, entry.control.positive_span)
      positive_source = SweepEvidence.resolve!(core, positive_span.citation)
      positive_text = span!(positive_source.path, positive_span.first_line, positive_span.last_line)
      assert Asn1RttCoreEvidence.guard_matches?(entry, positive_text)

      negative = SweepEvidence.resolve!(core, entry.control.negative_citation)
      refute Asn1RttCoreEvidence.guard_matches?(entry, negative.text)
      refute Asn1RttCoreEvidence.guard_matches?(
               entry,
               String.replace(positive_text, entry.control.guard, "", global: false)
             )

      assert Enum.all?(core_entries -- [entry], fn other ->
               other.control.guard != entry.control.guard
             end)
    end

    floor = archive_lane!(evidence, "floor")
    floor_record = Asn1RttFloorEvidence.record()
    assert floor_record.lane == "floor"
    assert floor_record.original_id == "EX-107"
    floor_entries = floor_record.selected_function_evidence
    assert Enum.map(floor_entries, & &1.mfa) == @selected_mfas

    for entry <- floor_entries do
      assert entry.disposition in [
               :static_existing_mfa_membership_check,
               :static_literal_code_table,
               :static_dependency_lookup
             ]

      target = mfa_call(entry.mfa)
      matching_citations =
        Enum.filter(entry.caller_path, fn {_citation, line} -> String.contains?(line, target) end)

      assert length(matching_citations) == 1
      [{citation, expected_line}] = matching_citations
      source = SweepEvidence.resolve!(floor, citation)
      assert source.origin == :archive
      assert source.text =~ expected_line
      assert source.text =~ target

      refute Enum.any?(floor_entries -- [entry], fn other ->
               Enum.any?(other.caller_path, fn {_other_citation, line} ->
                 String.contains?(line, target)
               end)
             end)
    end

    core_code = Enum.find(core_entries, &(&1.mfa == {:asn1ct_rtt, :code, 0}))
    floor_code = Enum.find(floor_entries, &(&1.mfa == {:asn1ct_rtt, :code, 0}))
    assert core_code.literal_table.row_count == 258
    assert floor_record.rtt_literal_body.method == :anchored_byte_grammar
    assert floor_record.rtt_literal_body.row_count == 250
    assert floor_code.target_span == 533..1038

    assert @collision_report_fields == [:mfa, :call_site, :input_trace, :triggering_guard]
    assert Enum.all?(floor_entries, &String.contains?(String.downcase(&1.finding), "runtime behavior"))
  end

  defp archived_lane_sets! do
    bytes = File.read!(@budget_path)
    assert digest(bytes) == @budget_sha256
    budget = JSON.decode!(bytes)

    Map.new(["core", "floor"], fn lane ->
      [row] = Enum.filter(budget["lanes"][lane]["rows"], &(&1["id"] == "EX-107"))
      matches = MapSet.new(row["matches"], &budget_mfa_string!/1)
      assert MapSet.size(matches) == 177
      {lane, matches}
    end)
  end

  defp live_asn1_matches!(evidence, lane) do
    evidence.installed
    |> Map.fetch!("asn1")
    |> Path.join("ebin")
    |> then(&InstalledOtp.export_inventory!([&1], lane: lane))
    |> Enum.filter(fn {module, function, _arity} ->
      String.starts_with?(Atom.to_string(module), "asn1ct_") and
        function not in [:module_info, :__info__]
    end)
    |> MapSet.new(&mfa_string/1)
  end

  defp archive_lane!(evidence, lane) do
    %{evidence | lane: Map.put(evidence.lane, :name, lane)}
    |> Map.update!(:installed, fn installed ->
      Map.new(installed, fn {app, _path} ->
        {app, Path.join(evidence.archive_root, "missing-#{app}")}
      end)
    end)
  end

  defp span!(path, first_line, last_line) do
    path
    |> File.read!()
    |> String.split("\n", trim: false)
    |> Enum.slice((first_line - 1)..(last_line - 1))
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp mfa_call({module, function, arity}) do
    args = if arity == 0, do: "()", else: "("
    "#{Atom.to_string(module)}:#{Atom.to_string(function)}#{args}"
  end

  defp budget_mfa_string!([module, function, arity])
       when is_binary(module) and is_binary(function) and is_integer(arity) do
    "#{module}:#{function}/#{arity}"
  end

  defp mfa_string({module, function, arity}) do
    "#{Atom.to_string(module)}:#{Atom.to_string(function)}/#{arity}"
  end

  defp digest(bytes), do: :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
end
