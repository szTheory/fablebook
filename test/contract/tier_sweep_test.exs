defmodule Fablebook.Test.DebuggerPendingOwnership do
  alias Fablebook.Test.DebuggerSettings

  @baseline_modules [
    :dbg_wx_mon,
    :dbg_wx_mon_win,
    :dbg_wx_filedialog_win,
    :dbg_wx_win,
    :dbg_iload,
    :dbg_ieval
  ]

  def baseline_modules, do: @baseline_modules

  def owners do
    current = DebuggerSettings.pending_owners()
    Map.new(@baseline_modules, &{&1, Map.fetch!(current, Atom.to_string(&1))})
  end

  def validation_error(owners) when is_map(owners) do
    expected = MapSet.new(@baseline_modules)
    assigned = MapSet.new(Map.keys(owners))
    missing = MapSet.difference(expected, assigned)
    unexpected = MapSet.difference(assigned, expected)
    current_owners = owners()

    wrong_owner =
      Enum.filter(@baseline_modules, &(Map.get(owners, &1) != Map.get(current_owners, &1)))

    if MapSet.size(missing) == 0 and MapSet.size(unexpected) == 0 and wrong_owner == [] do
      nil
    else
      "missing owner entries=#{format_owners(missing, owners)}; " <>
        "unexpected owner entries=#{format_owners(unexpected, owners)}; " <>
        "wrong owner entries=#{format_owners(wrong_owner, owners)}"
    end
  end

  def assert_valid!(owners) do
    case validation_error(owners) do
      nil ->
        :ok

      message ->
        raise ExUnit.AssertionError,
          message: "pending debugger ownership map differs; " <> message
    end
  end

  defp format_owners(modules, owners) do
    modules
    |> Enum.sort()
    |> Enum.map_join("; ", fn module ->
      expected = Map.fetch!(owners(), module)
      "#{module} expected=#{expected} actual=#{Map.get(owners, module, "<missing>")}"
    end)
  end
end

defmodule Fablebook.Contract.GeneratorDispatchCoreEvidenceTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.GeneratorDispatchCallerAEvidence
  alias Fablebook.Test.GeneratorDispatchCallerBEvidence
  alias Fablebook.Test.GeneratorDispatchCoreEvidence
  alias Fablebook.Test.GeneratorDispatchFloorCallerAEvidence
  alias Fablebook.Test.GeneratorDispatchFloorCallerBEvidence
  alias Fablebook.Test.GeneratorDispatchFloorEvidence
  alias Fablebook.Test.SweepEvidence

  @archive Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
  @sources %{
    "asn1/src/asn1ct_func.erl" =>
      {4465, "da8b3b3e951120b1cdbd0622b72d698bd3103c92341d42ba4c6556388818e753"},
    "stdlib/src/gen_server.erl" =>
      {114_546, "45e1cea8e87a49c8f6cec49ec50e082dde6690c3696f9e67de376947fc8f34a3"},
    "stdlib/src/gen.erl" =>
      {27_099, "b828697b055865df24aad48ec4cd7f23821fa54a7aa2baa0408a444a5d0d04be"},
    "stdlib/src/proc_lib.erl" =>
      {57_067, "a8fc8e94f9ad47ace46cd204fc5eb6fd227c09787f3be906d80d2e4547e6a8c5"},
    "asn1/src/asn1ct_rtt.erl" =>
      {135_654, "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"}
  }

  @tag :generator_dispatch_011118
  test "core support identities and callback trace resolve from the exact archive" do
    evidence = archive_only_evidence!()
    [record] = GeneratorDispatchCoreEvidence.records()

    assert record.original_id == "EX-107"
    assert record.semantic_status == :pending
    assert length(record.exact_sources) == 5

    for {path, {bytes, sha256}} <- @sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    for {citation, expected} <- record.callback_trace do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected
    end
  end

  @tag :generator_dispatch_011118
  test "the complete core RTT code/0 body is literal table data and rejects altered shapes" do
    evidence = archive_only_evidence!()
    source = SweepEvidence.resolve!(evidence, "asn1/src/asn1ct_rtt.erl:542")
    bytes = File.read!(source.path)
    body = rtt_body!(bytes)
    grammar = rtt_grammar()

    assert Regex.match?(grammar, body)
    assert length(Regex.scan(Regex.compile!(row_pattern()), body)) == 258

    refute Regex.match?(
             grammar,
             String.replace(body, "<<\"", "<<integer_to_binary(1)>>", global: false)
           )

    refute Regex.match?(
             grammar,
             String.replace(body, "{{ber,ber_encode,1}", "{{erlang,apply(),1}", global: false)
           )

    refute Regex.match?(grammar, body <> " erlang:halt().")
    truncated = String.trim_trailing(body) |> then(&binary_part(&1, 0, byte_size(&1) - 2))
    refute Regex.match?(grammar, truncated)
  end

  @tag :generator_dispatch_011118
  test "core caller batch A sources and generated-call traces resolve from the exact archive" do
    evidence = archive_only_evidence!()
    record = GeneratorDispatchCallerAEvidence.record()

    assert record.original_id == "EX-107"
    assert record.semantic_status == :pending
    assert length(record.exact_sources) == 5
    assert length(record.reviews) == 4

    for {path, bytes, sha256} <- record.exact_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    for review <- record.reviews do
      assert String.length(review.finding) > 120

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.text =~ expected, citation
      end
    end
  end

  @tag :generator_dispatch_011118
  test "core caller batch B completes selected-MFA and full direct-edge evidence" do
    evidence = archive_only_evidence!()
    record = GeneratorDispatchCallerBEvidence.record()
    [core] = GeneratorDispatchCoreEvidence.records()

    assert length(record.exact_sources) == 5
    assert length(record.reviews) == 4
    assert length(core.selected_function_evidence) == 11

    expected_mfas =
      MapSet.new([
        {:asn1ct_func, :call, 3},
        {:asn1ct_func, :call_gen, 3},
        {:asn1ct_func, :call_gen, 4},
        {:asn1ct_func, :generate, 1},
        {:asn1ct_func, :handle_call, 3},
        {:asn1ct_func, :handle_cast, 2},
        {:asn1ct_func, :init, 1},
        {:asn1ct_func, :is_used, 1},
        {:asn1ct_func, :need, 1},
        {:asn1ct_func, :start_link, 0},
        {:asn1ct_func, :terminate, 2}
      ])

    assert MapSet.new(core.selected_function_evidence, & &1.mfa) == expected_mfas

    for {path, bytes, sha256} <- record.exact_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    for review <- record.reviews do
      assert String.length(review.finding) > 120

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.text =~ expected, citation
      end
    end

    for function <- core.selected_function_evidence,
        {citation, expected} <- function.citations do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
      assert String.length(function.trace) > 100
    end

    assert Enum.count(
             core.selected_function_evidence,
             &(&1.interim_disposition == :active_dynamic_atom_creation_candidate)
           ) == 1

    assert length(record.incoming_edges) == 28

    external_callers =
      record.incoming_edges
      |> Enum.map(& &1.caller)
      |> Enum.reject(&match?({:asn1ct_func, _, _}, &1))
      |> MapSet.new()

    assert MapSet.size(external_callers) == 25

    for edge <- record.incoming_edges, {citation, expected} <- edge.citations do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end
  end

  @tag :generator_dispatch_011118
  test "floor support identities, callback path and all selected-function traces resolve from the exact archive" do
    evidence = archive_only_evidence!("floor")
    record = GeneratorDispatchFloorEvidence.record()

    assert record.original_id == "EX-107"
    assert record.semantic_status == :pending
    assert length(record.exact_sources) == 5
    assert length(record.selected_function_evidence) == 11

    for {path, bytes, sha256} <- record.exact_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    for {citation, expected} <- record.callback_trace do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end

    for function <- record.selected_function_evidence,
        {citation, expected} <- function.citations do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
      assert String.length(function.trace) > 100
    end

    assert Enum.count(
             record.selected_function_evidence,
             &(&1.interim_disposition == :active_dynamic_atom_creation_candidate)
           ) == 1
  end

  @tag :generator_dispatch_011118
  test "the complete floor RTT code/0 body is literal table data and rejects altered shapes" do
    evidence = archive_only_evidence!("floor")
    source = SweepEvidence.resolve!(evidence, "asn1/src/asn1ct_rtt.erl:534")
    body = rtt_body!(File.read!(source.path))
    grammar = rtt_grammar()

    [record] = [
      GeneratorDispatchFloorEvidence.record()
    ]

    assert record.rtt_literal_body == %{
             start_line: 534,
             end_line: 1039,
             bytes: byte_size(body),
             sha256: :crypto.hash(:sha256, body) |> Base.encode16(case: :lower),
             rows: 254,
             grammar: :pass,
             controls: [:computed_payload, :expression_in_mfa, :trailing_code, :truncation]
           }

    assert Regex.match?(grammar, body)
    assert length(Regex.scan(Regex.compile!(row_pattern()), body)) == 254

    computed_payload = String.replace(body, <<"<<\"">>, "<<integer_to_binary(1)>>", global: false)

    expression_in_mfa =
      String.replace(body, "{{ber,ber_decode_erlang,1}", "{{erlang,apply(),1}", global: false)

    assert computed_payload != body
    assert expression_in_mfa != body
    refute Regex.match?(grammar, computed_payload)
    refute Regex.match?(grammar, expression_in_mfa)
    refute Regex.match?(grammar, body <> " erlang:halt().")

    truncated = String.trim_trailing(body) |> then(&binary_part(&1, 0, byte_size(&1) - 2))
    refute Regex.match?(grammar, truncated)
  end

  @tag :generator_dispatch_011118
  test "floor caller batch A identities, generated-call traces and direct edges resolve from the exact archive" do
    evidence = archive_only_evidence!("floor")
    record = GeneratorDispatchFloorCallerAEvidence.record()

    assert record.original_id == "EX-107"
    assert record.semantic_status == :pending
    assert length(record.exact_sources) == 5
    assert length(record.reviews) == 4
    assert length(record.incoming_edges) == 17

    for {path, bytes, sha256} <- record.exact_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    for review <- record.reviews do
      assert String.length(review.finding) > 120

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.text =~ expected, citation
      end
    end

    for edge <- record.incoming_edges, {citation, expected} <- edge.citations do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end

    [per_review] =
      Enum.filter(record.reviews, &(&1.source_path == "asn1/src/asn1ct_constructed_per.erl"))

    assert String.contains?(per_review.finding, "caller-derived compiler metadata")
    assert String.contains?(per_review.finding, "no user-controlled-input claim")
  end

  @tag :generator_dispatch_011118
  test "floor caller batch B completes all eleven findings and the exact 28-edge caller graph" do
    evidence = archive_only_evidence!("floor")
    record = GeneratorDispatchFloorCallerBEvidence.record()
    support = GeneratorDispatchFloorEvidence.record()
    caller_a = GeneratorDispatchFloorCallerAEvidence.record()

    assert record.original_id == "EX-107"
    assert record.owner == "01.1.1.4"
    assert record.semantic_status == :pending
    assert length(record.exact_sources) == 5
    assert length(record.reviews) == 4
    assert length(record.selected_function_evidence) == 11

    all_sources = [support, caller_a, record] |> Enum.flat_map(& &1.exact_sources)
    assert MapSet.size(MapSet.new(all_sources, &elem(&1, 0))) == 13

    for {path, bytes, sha256} <- record.exact_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    for review <- record.reviews do
      assert String.length(review.finding) > 120

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.text =~ expected, citation
      end
    end

    assert length(record.incoming_edges) == 28
    external_edges = Enum.reject(record.incoming_edges, &match?({:asn1ct_func, _, _}, &1.caller))
    assert length(external_edges) == 27
    assert MapSet.size(MapSet.new(external_edges, & &1.caller)) == 25

    for edge <- record.incoming_edges, {citation, expected} <- edge.citations do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end
  end

  defp rtt_body!(bytes) do
    [_, body] = Regex.run(~r/\ncode\(\) ->\n([\s\S]*)\z/, bytes)
    body
  end

  defp rtt_grammar do
    row = row_pattern()
    Regex.compile!("\\A\\s*\\[#{row}(?:,\\s*#{row})*\\]\\.\\s*\\z")
  end

  defp row_pattern do
    ~S/\{\{[a-z][A-Za-z0-9_]*,[a-z][A-Za-z0-9_]*,[0-9]+\},\s*<<"(?:[^"\\]|\\.)*">>\}/
  end

  defp archive_only_evidence!(lane \\ "core") do
    archive = SweepEvidence.load_archive!(@archive, SweepEvidence.archive_sha256())
    on_exit(fn -> File.rm_rf!(archive.archive_root) end)

    Map.merge(archive, %{
      lane: %{name: lane},
      installed: Map.new(~w(asn1 stdlib), &{&1, Path.join(archive.archive_root, "missing-#{&1}")})
    })
  end
end

defmodule Fablebook.Test.ExternalTransformEvidence do
  @moduledoc false

  @core_started_at "2026-11-10T04:54:12Z"
  @core_completed_at "2026-11-10T04:59:24Z"
  @core_identities %{
    "asn1/src/asn1ct_eval_ext.erl" =>
      {2092, "c2fddfd1f6091b225ae4f6eadda70b789927e9476a916ec960e6a64a2e6504ae"},
    "asn1/src/asn1ct_constructed_ber_bin_v2.erl" =>
      {49_717, "ecb21fb22cf3c5607fff6d49aba5b81a7aed3cc33114fb19c11fea5440699e54"},
    "asn1/src/asn1ct_constructed_per.erl" =>
      {68_996, "581c66a8c24f1994679ced99693e37ae4e7bbdd4c15d75b8e22244a81ed76d60"},
    "asn1/src/asn1ct_value.erl" =>
      {12_384, "48db2e0d04491968b79ed91b7641c968c541f8917225f00e277627d38ea67b0f"},
    "asn1/src/asn1ct_rtt.erl" =>
      {135_654, "dbdbad10a9af2d46dd617315ef63e226f8425de0ad64a3446058200980d67374"}
  }
  @floor_identities %{
    "asn1/src/asn1ct_eval_ext.erl" =>
      {2092, "c2fddfd1f6091b225ae4f6eadda70b789927e9476a916ec960e6a64a2e6504ae"},
    "asn1/src/asn1ct_constructed_ber_bin_v2.erl" =>
      {49_528, "a173873d7d7a3082cd77ec8caac860b64f421bda2a91a9166845710e69bc97f5"},
    "asn1/src/asn1ct_constructed_per.erl" =>
      {68_908, "0e732766bf11e1e5bc73e79f8529b91eb065efba34fe0d6e29b323e778dbba5c"},
    "asn1/src/asn1ct_value.erl" =>
      {12_270, "771476506bfa10fae9db6a2476bf5487df9ee69030b8b6791473f3bf273608c3"},
    "asn1/src/asn1ct_rtt.erl" =>
      {134_820, "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"}
  }
  @helpers [
    {:asn1ct_eval_ext, :transform_to_EXTERNAL1994, 1},
    {:asn1ct_eval_ext, :transform_to_EXTERNAL1994_maps, 1}
  ]

  def lane_record("core") do
    %{
      lane: "core",
      original_id: "EX-107",
      original_entry_raw: "{{:prefix, \":asn1ct_\"}, :compiler_pass}",
      owner: "01.1.1.4",
      semantic_status: :pending,
      selected_mfas: @helpers,
      caller_input_trace:
        "BER and PER dec_external/2 generate calls using fixed record fields or fixed map keys. At runtime the decoded EXTERNAL data is passed to one of two fixed helpers; from_type/3 selects a helper name only from M:maps(). The helpers return tuple/map values without atom constructors. The PER generator's list_to_atom(record_name(Gen, Typename)) constructs a schema-derived record tag before emitting the call and does not consume the decoded payload.",
      method: :source_only,
      started_at: @core_started_at,
      completed_at: @core_completed_at,
      elapsed_seconds: 312,
      reviews: [
        review(
          {:asn1ct_eval_ext, :transform_to_EXTERNAL1994, 1},
          "asn1/src/asn1ct_eval_ext.erl",
          10..29,
          [
            {"asn1/src/asn1ct_eval_ext.erl:10", "transform_to_EXTERNAL1994("},
            {"asn1/src/asn1ct_eval_ext.erl:24", "case Encoding of"},
            {"asn1/src/asn1ct_eval_ext.erl:25", "when is_list(Val); is_binary(Val)"},
            {"asn1/src/asn1ct_eval_ext.erl:28", "V"}
          ],
          "The complete helper only reshapes the already decoded EXTERNAL record and returns the original value outside its octet-aligned list/binary clause. Its fields are values copied into a tuple; it calls no atom constructor and has no path from caller-selected payload to atom creation."
        ),
        review(
          {:asn1ct_eval_ext, :transform_to_EXTERNAL1994_maps, 1},
          "asn1/src/asn1ct_eval_ext.erl",
          31..62,
          [
            {"asn1/src/asn1ct_eval_ext.erl:31", "transform_to_EXTERNAL1994_maps(V0)"},
            {"asn1/src/asn1ct_eval_ext.erl:46", "case V0 of"},
            {"asn1/src/asn1ct_eval_ext.erl:49", "identification => Identification"},
            {"asn1/src/asn1ct_eval_ext.erl:57", "#"},
            {"asn1/src/asn1ct_eval_ext.erl:60", "V =/= asn1_NOVALUE"}
          ],
          "The complete map helper copies fixed keys and caller-provided values into a result map, filtering the fixed asn1_NOVALUE sentinel. The dynamic selection chooses this fixed helper name from M:maps(); the supplied decoded fields are never converted into atoms."
        )
      ],
      generated_call_evidence: [
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:314",
         "dec_external(#gen{pack=record}, RecordName)"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:318", "{call,ext,transform_to_EXTERNAL1994"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:320",
         "dec_external(#gen{pack=map}, _RecordName)"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:328",
         "{call,ext,transform_to_EXTERNAL1994_maps"},
        {"asn1/src/asn1ct_constructed_per.erl:449",
         "dec_external(#gen{pack=record}=Gen, Typename)"},
        {"asn1/src/asn1ct_constructed_per.erl:455", "{call,ext,transform_to_EXTERNAL1994"},
        {"asn1/src/asn1ct_constructed_per.erl:458", "dec_external(#gen{pack=map}, _Typename)"},
        {"asn1/src/asn1ct_constructed_per.erl:466", "{call,ext,transform_to_EXTERNAL1994_maps"}
      ],
      pre_generated_atom_evidence: [
        {"asn1/src/asn1ct_constructed_per.erl:450",
         "RecordName = list_to_atom(record_name(Gen, Typename)),"}
      ],
      dynamic_dispatch_evidence: [
        {"asn1/src/asn1ct_value.erl:70", "Typename == ['EXTERNAL']"},
        {"asn1/src/asn1ct_value.erl:72", "T = case M:maps() of"},
        {"asn1/src/asn1ct_value.erl:76", "asn1ct_eval_ext:T(Val)"}
      ],
      runtime_template_evidence: [
        {"asn1/src/asn1ct_rtt.erl:76",
         "assert_defined({ext,transform_to_EXTERNAL1994,1}) -> ok;"},
        {"asn1/src/asn1ct_rtt.erl:77",
         "assert_defined({ext,transform_to_EXTERNAL1994_maps,1}) -> ok;"},
        {"asn1/src/asn1ct_rtt.erl:811", "{{ext,transform_to_EXTERNAL1994,1},"},
        {"asn1/src/asn1ct_rtt.erl:812", "transform_to_EXTERNAL1994({'EXTERNAL'"},
        {"asn1/src/asn1ct_rtt.erl:813", "{{ext,transform_to_EXTERNAL1994_maps,1},"},
        {"asn1/src/asn1ct_rtt.erl:814", "transform_to_EXTERNAL1994_maps(V0) ->"}
      ],
      ordinary_xref: :no_incoming_edges_is_not_semantic_evidence
    }
  end

  def lane_record("floor") do
    %{
      lane: "floor",
      original_id: "EX-107",
      original_entry_raw: "{{:prefix, \":asn1ct_\"}, :compiler_pass}",
      owner: "01.1.1.4",
      semantic_status: :pending,
      selected_mfas: @helpers,
      caller_input_trace:
        "Floor BER and PER dec_external/2 generate calls using fixed record fields or fixed map keys. At runtime decoded EXTERNAL data is passed to a fixed helper; from_type/3 selects the helper only from M:maps(). Neither complete helper has an atom constructor. Floor PER's list_to_atom(record_name(Gen, Typename)) builds a schema-derived record tag before emitting the call and is independent of the decoded payload.",
      method: :source_only,
      started_at: "2026-11-10T05:00:43Z",
      completed_at: "2026-11-10T05:04:29Z",
      elapsed_seconds: 226,
      reviews: [
        floor_review(
          {:asn1ct_eval_ext, :transform_to_EXTERNAL1994, 1},
          "asn1/src/asn1ct_eval_ext.erl",
          10..29,
          [
            {"asn1/src/asn1ct_eval_ext.erl:10", "transform_to_EXTERNAL1994("},
            {"asn1/src/asn1ct_eval_ext.erl:24", "case Encoding of"},
            {"asn1/src/asn1ct_eval_ext.erl:25", "when is_list(Val); is_binary(Val)"},
            {"asn1/src/asn1ct_eval_ext.erl:28", "V"}
          ],
          "The complete floor helper independently confirms a fixed tuple reshape of decoded EXTERNAL values. Only an octet-aligned list or binary takes the transformed branch; all other inputs return V. Neither branch constructs an atom or feeds a caller value to an atom constructor."
        ),
        floor_review(
          {:asn1ct_eval_ext, :transform_to_EXTERNAL1994_maps, 1},
          "asn1/src/asn1ct_eval_ext.erl",
          31..62,
          [
            {"asn1/src/asn1ct_eval_ext.erl:31", "transform_to_EXTERNAL1994_maps(V0)"},
            {"asn1/src/asn1ct_eval_ext.erl:46", "case V0 of"},
            {"asn1/src/asn1ct_eval_ext.erl:49", "identification => Identification"},
            {"asn1/src/asn1ct_eval_ext.erl:57", "#"},
            {"asn1/src/asn1ct_eval_ext.erl:60", "V =/= asn1_NOVALUE"}
          ],
          "The complete floor map helper copies decoded values under fixed keys and removes only the fixed asn1_NOVALUE value. The runtime dynamic call receives the helper selected by M:maps(), so payload values cannot select a helper name or reach atom creation."
        )
      ],
      generated_call_evidence: [
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:309",
         "dec_external(#gen{pack=record}, RecordName)"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:313", "{call,ext,transform_to_EXTERNAL1994"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:315",
         "dec_external(#gen{pack=map}, _RecordName)"},
        {"asn1/src/asn1ct_constructed_ber_bin_v2.erl:323",
         "{call,ext,transform_to_EXTERNAL1994_maps"},
        {"asn1/src/asn1ct_constructed_per.erl:445",
         "dec_external(#gen{pack=record}=Gen, Typename)"},
        {"asn1/src/asn1ct_constructed_per.erl:451", "{call,ext,transform_to_EXTERNAL1994"},
        {"asn1/src/asn1ct_constructed_per.erl:454", "dec_external(#gen{pack=map}, _Typename)"},
        {"asn1/src/asn1ct_constructed_per.erl:462", "{call,ext,transform_to_EXTERNAL1994_maps"}
      ],
      pre_generated_atom_evidence: [
        {"asn1/src/asn1ct_constructed_per.erl:446",
         "RecordName = list_to_atom(record_name(Gen, Typename)),"}
      ],
      dynamic_dispatch_evidence: [
        {"asn1/src/asn1ct_value.erl:66", "Typename == ['EXTERNAL']"},
        {"asn1/src/asn1ct_value.erl:68", "T = case M:maps() of"},
        {"asn1/src/asn1ct_value.erl:72", "asn1ct_eval_ext:T(Val)"}
      ],
      runtime_template_evidence: [
        {"asn1/src/asn1ct_rtt.erl:76",
         "assert_defined({ext,transform_to_EXTERNAL1994,1}) -> ok;"},
        {"asn1/src/asn1ct_rtt.erl:77",
         "assert_defined({ext,transform_to_EXTERNAL1994_maps,1}) -> ok;"},
        {"asn1/src/asn1ct_rtt.erl:799", "{{ext,transform_to_EXTERNAL1994,1},"},
        {"asn1/src/asn1ct_rtt.erl:800", "transform_to_EXTERNAL1994({'EXTERNAL'"},
        {"asn1/src/asn1ct_rtt.erl:801", "{{ext,transform_to_EXTERNAL1994_maps,1},"},
        {"asn1/src/asn1ct_rtt.erl:802", "transform_to_EXTERNAL1994_maps(V0) ->"}
      ],
      ordinary_xref: :no_incoming_edges_is_not_semantic_evidence,
      lane_differences: [
        "BER and PER record/map emission have shifted lines; floor builds map initialization with lists:zip while core uses its lane-specific parallel-list comprehension.",
        "PER record generation calls list_to_atom(record_name(Gen, Typename)) before emitting the helper call. This is schema-derived record construction in the generator, not a payload-to-atom operation inside either selected helper."
      ]
    }
  end

  def helper_mfas, do: @helpers
  def core_identities, do: @core_identities
  def floor_identities, do: @floor_identities

  defp review(mfa, path, range, citations, rationale) do
    {bytes, sha256} = Map.fetch!(@core_identities, path)

    %{
      mfa: mfa,
      source_path: path,
      sha256: sha256,
      bytes: bytes,
      method: :source_only,
      reviewed_ranges: [range],
      citations: citations,
      started_at: @core_started_at,
      completed_at: @core_completed_at,
      elapsed_seconds: 312,
      disposition: :fixed_shape_data_transform,
      removal_witness: :individual_exact_exclusion,
      rationale: rationale
    }
  end

  defp floor_review(mfa, path, range, citations, rationale) do
    {bytes, sha256} = Map.fetch!(@floor_identities, path)

    %{
      mfa: mfa,
      source_path: path,
      sha256: sha256,
      bytes: bytes,
      method: :source_only,
      reviewed_ranges: [range],
      citations: citations,
      started_at: "2026-11-10T05:00:43Z",
      completed_at: "2026-11-10T05:04:29Z",
      elapsed_seconds: 226,
      disposition: :fixed_shape_data_transform,
      removal_witness: :individual_exact_exclusion,
      rationale: rationale
    }
  end
end

defmodule Fablebook.Contract.ExternalTransformEvidenceTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.ExternalTransformEvidence
  alias Fablebook.Test.SweepEvidence

  @archive Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)

  @tag :external_transform_011117
  test "core exact ASN.1 sources resolve only from the approved archive" do
    evidence = archive_only_evidence!("core")

    assert Map.keys(ExternalTransformEvidence.core_identities()) |> MapSet.new() ==
             MapSet.new([
               "asn1/src/asn1ct_eval_ext.erl",
               "asn1/src/asn1ct_constructed_ber_bin_v2.erl",
               "asn1/src/asn1ct_constructed_per.erl",
               "asn1/src/asn1ct_value.erl",
               "asn1/src/asn1ct_rtt.erl"
             ])

    for {path, {bytes, sha256}} <- ExternalTransformEvidence.core_identities() do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end
  end

  @tag :external_transform_011117
  test "floor exact ASN.1 sources resolve independently from the approved archive" do
    evidence = archive_only_evidence!("floor")

    for {path, {bytes, sha256}} <- ExternalTransformEvidence.floor_identities() do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
      assert source.path =~ "/floor/"
    end

    assert map_size(ExternalTransformEvidence.floor_identities()) == 5
  end

  @tag :external_transform_011117
  test "core helper reviews cite complete helpers and distinct generated, dynamic, and template paths" do
    record = ExternalTransformEvidence.lane_record("core")
    evidence = archive_only_evidence!("core")

    assert record.method == :source_only
    assert_interval!(record)

    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) ==
             MapSet.new(ExternalTransformEvidence.helper_mfas())

    for review <- record.reviews do
      assert review.reviewed_ranges != []
      assert review.disposition == :fixed_shape_data_transform
      assert String.length(review.rationale) > 100

      assert review.bytes ==
               elem(
                 Map.fetch!(ExternalTransformEvidence.core_identities(), review.source_path),
                 0
               )

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.sha256 == review.sha256
        assert source.text =~ expected, citation
      end
    end

    assert Enum.any?(record.generated_call_evidence, &String.contains?(elem(&1, 1), "{call,ext,"))

    assert Enum.any?(
             record.dynamic_dispatch_evidence,
             &String.contains?(elem(&1, 1), "asn1ct_eval_ext:T(Val)")
           )

    assert Enum.any?(
             record.runtime_template_evidence,
             &String.contains?(elem(&1, 1), "assert_defined")
           )

    assert record.ordinary_xref == :no_incoming_edges_is_not_semantic_evidence

    for evidence_group <- [
          record.generated_call_evidence,
          record.pre_generated_atom_evidence,
          record.dynamic_dispatch_evidence,
          record.runtime_template_evidence
        ],
        {citation, expected} <- evidence_group do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end
  end

  @tag :external_transform_011117
  test "floor helper reviews use floor citations and preserve generated, dynamic, and template evidence" do
    record = ExternalTransformEvidence.lane_record("floor")
    evidence = archive_only_evidence!("floor")

    assert record.lane == "floor"
    assert record.method == :source_only
    assert_interval!(record)

    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) ==
             MapSet.new(ExternalTransformEvidence.helper_mfas())

    for review <- record.reviews do
      assert review.source_path == "asn1/src/asn1ct_eval_ext.erl"

      assert review.sha256 ==
               elem(
                 Map.fetch!(ExternalTransformEvidence.floor_identities(), review.source_path),
                 1
               )

      assert review.bytes ==
               elem(
                 Map.fetch!(ExternalTransformEvidence.floor_identities(), review.source_path),
                 0
               )

      assert review.disposition == :fixed_shape_data_transform
      assert String.length(review.rationale) > 100

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.sha256 == review.sha256
        assert source.text =~ expected, citation
      end
    end

    assert record.lane_differences != []

    for evidence_group <- [
          record.generated_call_evidence,
          record.pre_generated_atom_evidence,
          record.dynamic_dispatch_evidence,
          record.runtime_template_evidence
        ],
        {citation, expected} <- evidence_group do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end
  end

  defp archive_only_evidence!(lane) do
    evidence = SweepEvidence.load_archive!(@archive, SweepEvidence.archive_sha256())
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    Map.merge(evidence, %{
      lane: %{name: lane},
      installed: %{"asn1" => Path.join(evidence.archive_root, "missing-asn1")}
    })
  end

  defp assert_interval!(record) do
    assert record.started_at < record.completed_at
    {:ok, started, 0} = DateTime.from_iso8601(record.started_at)
    {:ok, completed, 0} = DateTime.from_iso8601(record.completed_at)
    assert DateTime.diff(completed, started, :second) == record.elapsed_seconds

    for review <- record.reviews do
      assert review.started_at == record.started_at
      assert review.completed_at == record.completed_at
      assert review.elapsed_seconds == record.elapsed_seconds
    end
  end
end

defmodule Fablebook.Test.ParserTokenizerEvidence do
  @moduledoc false

  @core_started_at "2026-11-09T02:40:15Z"
  @core_completed_at "2026-11-09T02:41:36Z"
  @floor_started_at "2026-11-09T03:06:46Z"
  @floor_completed_at "2026-11-09T03:07:28Z"
  @core_hashes %{
    "asn1/src/asn1ct_parser2.erl" =>
      "9542877f5446e3a38fff2c892b67f19d52075bd4c05c6b43dc7b46fbf159cfb4",
    "asn1/src/asn1ct_tok.erl" =>
      "4ec523645deaacaf4452cc443ceb27c217b6a6dd6ba63eeaa771c5e4cce58222",
    "asn1/src/asn1ct.erl" => "c6d680ca6798f80e60c71a5f234d82c1d0c3505ef72fdd6ca320393c2b89df54"
  }
  @core_bytes %{
    "asn1/src/asn1ct_parser2.erl" => 73_086,
    "asn1/src/asn1ct_tok.erl" => 11_657
  }
  @floor_hashes %{
    "asn1/src/asn1ct_parser2.erl" =>
      "7fddafa8be67b9388e42e4f1332f93ace5d0607d8090f308b35df4acc9b8fb30",
    "asn1/src/asn1ct_tok.erl" =>
      "4d8bde4d0da13582c1da72d235168521d2ebdbdd98b41635edece96afe5a1bf2"
  }

  def records do
    [
      %{
        lane: "core",
        method: :source_only,
        started_at: @core_started_at,
        completed_at: @core_completed_at,
        elapsed_seconds: 81,
        reviews: [
          review(
            {:asn1ct_parser2, :parse, 2},
            "asn1/src/asn1ct_parser2.erl",
            1..2309,
            [
              {"asn1/src/asn1ct_parser2.erl:38", "try do_parse(Tokens0) of"},
              {"asn1/src/asn1ct_parser2.erl:43", "handle_parse_error(File0, Fun())"},
              {"asn1/src/asn1ct_parser2.erl:45", "handle_parse_error(File0, Tokens)"},
              {"asn1/src/asn1ct_parser2.erl:64", "parse_error(Tokens2)"},
              {"asn1/src/asn1ct_parser2.erl:2283", "list_to_atom([$&|atom_to_list(FieldName)])"},
              {"asn1/src/asn1ct_parser2.erl:2285", "list_to_atom([$&|atom_to_list(FieldName)])"}
            ],
            "The tokenizer derives tokens from file contents and parse/2 retains an error path that converts a field reference into a new atom. Its input is caller-chosen ASN.1 text, so the selected MFA reaches atom creation."
          ),
          review(
            {:asn1ct_parser2, :format_error, 1},
            "asn1/src/asn1ct_parser2.erl",
            1..2309,
            [{"asn1/src/asn1ct_parser2.erl:75", "io_lib:format"}],
            "format_error/1 only formats the supplied syntax error token; it does not convert text into atoms. This MFA is selected as part of the exact EX-107 slice but is a no-sink disposition."
          ),
          review(
            {:asn1ct_tok, :file, 1},
            "asn1/src/asn1ct_tok.erl",
            1..376,
            [
              {"asn1/src/asn1ct_tok.erl:33", "file:open(File0, [read])"},
              {"asn1/src/asn1ct_tok.erl:38", "process(Stream, 1, [])"},
              {"asn1/src/asn1ct_tok.erl:48", "io:get_line(Stream, '')"},
              {"asn1/src/asn1ct_tok.erl:54", "tokenise(Stream, L, Lno0, [])"},
              {"asn1/src/asn1ct_tok.erl:76", "get_name(T, [H])"},
              {"asn1/src/asn1ct_tok.erl:79", "get_name(T, [H])"},
              {"asn1/src/asn1ct_tok.erl:146", "typereference,Lno,X"},
              {"asn1/src/asn1ct_tok.erl:153", "identifier,Lno,X"},
              {"asn1/src/asn1ct_tok.erl:163", "list_to_atom([H])"},
              {"asn1/src/asn1ct_tok.erl:188", "list_to_atom(lists:reverse(Acc))"},
              {"asn1/src/asn1ct_tok.erl:191", "list_to_atom(lists:reverse(Acc))"},
              {"asn1/src/asn1ct_tok.erl:197", "list_to_atom(lists:reverse(Acc))"},
              {"asn1/src/asn1ct_tok.erl:200", "list_to_atom(lists:reverse(Acc))"}
            ],
            "file/1 reads the caller-selected ASN.1 source file, tokenise/4 routes identifier and punctuation characters through list_to_atom/1, and get_name/2 atomizes the lexed name. Caller-controlled file text reaches atom creation."
          ),
          review(
            {:asn1ct_tok, :format_error, 1},
            "asn1/src/asn1ct_tok.erl",
            1..376,
            [{"asn1/src/asn1ct_tok.erl:69", "io_lib:format"}],
            "format_error/1 formats fixed lexical errors or the supplied error term and has no atom conversion path. This MFA remains selected for a source-backed no-sink disposition."
          )
        ],
        caller_edges: [
          edge(
            {:asn1ct, :scan_pass, 1},
            {:asn1ct_tok, :file, 1},
            "asn1/src/asn1ct.erl:384",
            "asn1ct_tok:file(File)"
          ),
          edge(
            {:asn1ct, :set_scan_parse_pass_1, 2},
            {:asn1ct_tok, :file, 1},
            "asn1/src/asn1ct.erl:401",
            "asn1ct_tok:file(F)"
          ),
          edge(
            {:asn1ct, :set_scan_parse_pass_1, 2},
            {:asn1ct_parser2, :parse, 2},
            "asn1/src/asn1ct.erl:405",
            "asn1ct_parser2:parse(File, Tokens)"
          ),
          edge(
            {:asn1ct, :parse_pass, 1},
            {:asn1ct_parser2, :parse, 2},
            "asn1/src/asn1ct.erl:415",
            "asn1ct_parser2:parse(File, Tokens)"
          )
        ],
        wrapper: %{
          caller: {:asn1ct, :set_scan_parse_pass, 1},
          target: {:asn1ct, :set_scan_parse_pass_1, 2},
          citations: [{"asn1/src/asn1ct.erl:393", "set_scan_parse_pass_1(Files, St)"}]
        }
      },
      %{
        lane: "floor",
        method: :source_only,
        started_at: @floor_started_at,
        completed_at: @floor_completed_at,
        elapsed_seconds: 42,
        reviews: [
          floor_review(
            {:asn1ct_parser2, :parse, 2},
            "asn1/src/asn1ct_parser2.erl",
            1..2305,
            [
              {"asn1/src/asn1ct_parser2.erl:34", "try do_parse(Tokens0) of"},
              {"asn1/src/asn1ct_parser2.erl:39", "handle_parse_error(File0, Fun())"},
              {"asn1/src/asn1ct_parser2.erl:41", "handle_parse_error(File0, Tokens)"},
              {"asn1/src/asn1ct_parser2.erl:60", "parse_error(Tokens2)"},
              {"asn1/src/asn1ct_parser2.erl:2279", "list_to_atom([$&|atom_to_list(FieldName)])"},
              {"asn1/src/asn1ct_parser2.erl:2281", "list_to_atom([$&|atom_to_list(FieldName)])"}
            ],
            "The exact floor parser routes tokenizer-derived tokens through do_parse/1 and returns malformed token failures through handle_parse_error/2. Both field-reference branches in get_token/1 convert the token field name to an ampersand-prefixed atom; caller-chosen ASN.1 text reaches that path.",
            72_969
          ),
          floor_review(
            {:asn1ct_parser2, :format_error, 1},
            "asn1/src/asn1ct_parser2.erl",
            1..2305,
            [
              {"asn1/src/asn1ct_parser2.erl:71", "io_lib:format"}
            ],
            "The floor format_error/1 clauses only format the supplied syntax token and introduce no atom conversion.",
            72_969
          ),
          floor_review(
            {:asn1ct_tok, :file, 1},
            "asn1/src/asn1ct_tok.erl",
            1..372,
            [
              {"asn1/src/asn1ct_tok.erl:29", "file:open(File0, [read])"},
              {"asn1/src/asn1ct_tok.erl:34", "process(Stream, 1, [])"},
              {"asn1/src/asn1ct_tok.erl:44", "io:get_line(Stream, '')"},
              {"asn1/src/asn1ct_tok.erl:50", "tokenise(Stream, L, Lno0, [])"},
              {"asn1/src/asn1ct_tok.erl:72", "get_name(T, [H])"},
              {"asn1/src/asn1ct_tok.erl:75", "get_name(T, [H])"},
              {"asn1/src/asn1ct_tok.erl:142", "typereference,Lno,X"},
              {"asn1/src/asn1ct_tok.erl:149", "identifier,Lno,X"},
              {"asn1/src/asn1ct_tok.erl:159", "list_to_atom([H])"},
              {"asn1/src/asn1ct_tok.erl:184", "list_to_atom(lists:reverse(Acc))"},
              {"asn1/src/asn1ct_tok.erl:187", "list_to_atom(lists:reverse(Acc))"},
              {"asn1/src/asn1ct_tok.erl:193", "list_to_atom(lists:reverse(Acc))"},
              {"asn1/src/asn1ct_tok.erl:196", "list_to_atom(lists:reverse(Acc))"}
            ],
            "The floor file/1 reads caller-selected ASN.1 text. Its exact tokenise/4 and get_name/2 branches mirror core and convert caller-derived identifiers and generic punctuation to atoms. This conclusion is separately pinned to floor bytes and was reached by comparing each complete source; no tokenizer operation was invoked.",
            11_540
          ),
          floor_review(
            {:asn1ct_tok, :format_error, 1},
            "asn1/src/asn1ct_tok.erl",
            1..372,
            [
              {"asn1/src/asn1ct_tok.erl:65", "io_lib:format"}
            ],
            "The floor format_error/1 clauses return fixed lexical messages or format an error term; they do not atomize caller text.",
            11_540
          )
        ],
        caller_edges: [
          edge(
            {:asn1ct, :scan_pass, 1},
            {:asn1ct_tok, :file, 1},
            "asn1/src/asn1ct.erl:379",
            "asn1ct_tok:file(File)"
          ),
          edge(
            {:asn1ct, :set_scan_parse_pass_1, 2},
            {:asn1ct_tok, :file, 1},
            "asn1/src/asn1ct.erl:396",
            "asn1ct_tok:file(F)"
          ),
          edge(
            {:asn1ct, :set_scan_parse_pass_1, 2},
            {:asn1ct_parser2, :parse, 2},
            "asn1/src/asn1ct.erl:400",
            "asn1ct_parser2:parse(File, Tokens)"
          ),
          edge(
            {:asn1ct, :parse_pass, 1},
            {:asn1ct_parser2, :parse, 2},
            "asn1/src/asn1ct.erl:410",
            "asn1ct_parser2:parse(File, Tokens)"
          )
        ],
        wrapper: %{
          caller: {:asn1ct, :set_scan_parse_pass, 1},
          target: {:asn1ct, :set_scan_parse_pass_1, 2},
          citations: [{"asn1/src/asn1ct.erl:388", "set_scan_parse_pass_1(Files, St)"}]
        }
      }
    ]
  end

  defp review(mfa, source_path, range, citations, rationale) do
    disposition = disposition_for(mfa)

    %{
      mfa: mfa,
      source_path: source_path,
      sha256: Map.fetch!(@core_hashes, source_path),
      bytes: Map.fetch!(@core_bytes, source_path),
      method: :source_only,
      reviewed_ranges: [range],
      citations: citations,
      started_at: @core_started_at,
      completed_at: @core_completed_at,
      elapsed_seconds: 81,
      disposition: disposition,
      removal_witness: if(disposition == :tier, do: :individual_mfa, else: :specific_exclusion),
      rationale: rationale
    }
  end

  defp floor_review(mfa, source_path, range, citations, rationale, bytes) do
    disposition = disposition_for(mfa)

    %{
      mfa: mfa,
      source_path: source_path,
      sha256: Map.fetch!(@floor_hashes, source_path),
      bytes: bytes,
      method: :source_only,
      reviewed_ranges: [range],
      citations: citations,
      started_at: @floor_started_at,
      completed_at: @floor_completed_at,
      elapsed_seconds: 42,
      disposition: disposition,
      removal_witness: if(disposition == :tier, do: :individual_mfa, else: :specific_exclusion),
      rationale: rationale
    }
  end

  defp disposition_for({_module, function, _arity}) when function in [:parse, :file], do: :tier
  defp disposition_for({_module, :format_error, 1}), do: :pure_data

  defp edge(caller, target, citation, expected),
    do: %{caller: caller, target: target, citations: [{citation, expected}]}
end

defmodule Fablebook.Contract.ParserTokenizerEvidenceTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.ParserTokenizerEvidence
  alias Fablebook.Test.SweepEvidence

  @archive Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
  @core_sources %{
    "asn1/src/asn1ct_parser2.erl" => {
      73_086,
      "9542877f5446e3a38fff2c892b67f19d52075bd4c05c6b43dc7b46fbf159cfb4"
    },
    "asn1/src/asn1ct_tok.erl" => {
      11_657,
      "4ec523645deaacaf4452cc443ceb27c217b6a6dd6ba63eeaa771c5e4cce58222"
    }
  }
  @floor_sources %{
    "asn1/src/asn1ct_parser2.erl" => {
      72_969,
      "7fddafa8be67b9388e42e4f1332f93ace5d0607d8090f308b35df4acc9b8fb30"
    },
    "asn1/src/asn1ct_tok.erl" => {
      11_540,
      "4d8bde4d0da13582c1da72d235168521d2ebdbdd98b41635edece96afe5a1bf2"
    }
  }

  @core_reviewed_ranges %{
    "asn1/src/asn1ct_parser2.erl" => 1..2309,
    "asn1/src/asn1ct_tok.erl" => 1..376
  }

  @core_mfas [
    {:asn1ct_parser2, :parse, 2},
    {:asn1ct_parser2, :format_error, 1},
    {:asn1ct_tok, :file, 1},
    {:asn1ct_tok, :format_error, 1}
  ]

  @core_edges [
    {{:asn1ct, :scan_pass, 1}, {:asn1ct_tok, :file, 1}},
    {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_tok, :file, 1}},
    {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_parser2, :parse, 2}},
    {{:asn1ct, :parse_pass, 1}, {:asn1ct_parser2, :parse, 2}}
  ]

  @tag :parser_tokenizer_011116
  test "core parser and tokenizer identities resolve through the existing archive" do
    evidence = archive_only_evidence!("core")

    for {path, {bytes, sha256}} <- @core_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    assert Enum.any?(ParserTokenizerEvidence.records(), &(&1.lane == "core")),
           "the core parser/tokenizer source-only review record is missing"
  end

  @tag :parser_tokenizer_011116
  test "floor parser and tokenizer identities resolve through the existing archive" do
    evidence = archive_only_evidence!("floor")

    for {path, {bytes, sha256}} <- @floor_sources do
      source = SweepEvidence.resolve!(evidence, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    assert Enum.any?(ParserTokenizerEvidence.records(), &(&1.lane == "floor")),
           "the floor parser/tokenizer source-only review record is missing"
  end

  @tag :parser_tokenizer_011116
  test "core review records cover the selected functions with complete source-only traces" do
    record = lane_record!("core")
    evidence = archive_only_evidence!("core")
    assert_valid_lane_record!(record, evidence)

    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) == MapSet.new(@core_mfas)

    assert MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target})) ==
             MapSet.new(@core_edges)
  end

  @tag :parser_tokenizer_011116
  test "core caller wrapper context stays separate from the four direct graph edges" do
    record = lane_record!("core")
    evidence = archive_only_evidence!("core")

    assert MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target})) ==
             MapSet.new(@core_edges)

    assert record.wrapper.caller == {:asn1ct, :set_scan_parse_pass, 1}
    assert record.wrapper.target == {:asn1ct, :set_scan_parse_pass_1, 2}
    assert record.wrapper.citations != []

    for {citation, expected} <- record.wrapper.citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected
    end
  end

  @tag :parser_tokenizer_011116
  test "core review integrity rejects omitted records, edges, citations and invalid intervals" do
    record = lane_record!("core")
    evidence = archive_only_evidence!("core")
    assert_valid_lane_record!(record, evidence)

    assert_raise ExUnit.AssertionError, fn ->
      assert_valid_lane_record!(%{record | reviews: tl(record.reviews)}, evidence)
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_valid_lane_record!(%{record | caller_edges: tl(record.caller_edges)}, evidence)
    end

    [review | rest] = record.reviews

    assert_raise ExUnit.AssertionError, fn ->
      assert_valid_lane_record!(%{record | reviews: [%{review | citations: []} | rest]}, evidence)
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_valid_lane_record!(
        %{record | reviews: [%{review | elapsed_seconds: 0} | rest]},
        evidence
      )
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_valid_lane_record!(
        %{record | reviews: [%{review | sha256: String.duplicate("0", 64)} | rest]},
        evidence
      )
    end

    assert_raise KeyError, fn ->
      assert_valid_lane_record!(
        %{record | reviews: [%{review | source_path: "asn1/src/unbound.erl"} | rest]},
        evidence
      )
    end
  end

  @tag :parser_tokenizer_011116
  test "floor review records cover the selected functions with exact source-only traces" do
    record = lane_record!("floor")
    evidence = archive_only_evidence!("floor")
    assert_valid_lane_record!(record, evidence)

    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) == MapSet.new(@core_mfas)

    assert MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target})) ==
             MapSet.new(@core_edges)
  end

  @tag :parser_tokenizer_011116
  test "floor caller wrapper citations remain outside the direct edge inventory" do
    record = lane_record!("floor")
    evidence = archive_only_evidence!("floor")

    assert MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target})) ==
             MapSet.new(@core_edges)

    assert record.wrapper.caller == {:asn1ct, :set_scan_parse_pass, 1}
    assert record.wrapper.target == {:asn1ct, :set_scan_parse_pass_1, 2}
    assert record.wrapper.citations != []

    for {citation, expected} <- record.wrapper.citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected
    end
  end

  @tag :parser_tokenizer_011116
  test "core and floor review records provide four explicit bounded dispositions" do
    expected = %{
      {:asn1ct_parser2, :parse, 2} => {:tier, :individual_mfa},
      {:asn1ct_parser2, :format_error, 1} => {:pure_data, :specific_exclusion},
      {:asn1ct_tok, :file, 1} => {:tier, :individual_mfa},
      {:asn1ct_tok, :format_error, 1} => {:pure_data, :specific_exclusion}
    }

    for lane <- ["core", "floor"] do
      record = lane_record!(lane)

      actual =
        Map.new(record.reviews, fn review ->
          {review.mfa, {Map.fetch!(review, :disposition), Map.fetch!(review, :removal_witness)}}
        end)

      assert actual == expected,
             "#{lane} review records must carry one source-backed disposition and witness for each selected MFA"
    end
  end

  defp archive_only_evidence!(lane) do
    evidence = SweepEvidence.load_archive!(@archive, SweepEvidence.archive_sha256())
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    Map.merge(evidence, %{
      lane: %{name: lane},
      installed: %{"asn1" => Path.join(evidence.archive_root, "missing-asn1")}
    })
  end

  defp lane_record!(lane) do
    Enum.find(ParserTokenizerEvidence.records(), &(&1.lane == lane)) ||
      flunk("#{lane} parser/tokenizer review record is missing")
  end

  defp assert_valid_lane_record!(record, evidence) do
    assert record.method == :source_only
    assert record.lane in ["core", "floor"]
    assert record.started_at < record.completed_at
    assert record.elapsed_seconds > 0
    {:ok, record_started, 0} = DateTime.from_iso8601(record.started_at)
    {:ok, record_completed, 0} = DateTime.from_iso8601(record.completed_at)
    assert DateTime.diff(record_completed, record_started, :second) == record.elapsed_seconds
    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) == MapSet.new(@core_mfas)

    assert MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target})) ==
             MapSet.new(@core_edges)

    Enum.each(record.reviews, &assert_valid_review_record!(record, &1, evidence))

    for edge <- record.caller_edges do
      assert edge.citations != []

      for {citation, expected} <- edge.citations do
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.origin == :archive
        assert source.text =~ expected
      end
    end
  end

  defp assert_valid_review_record!(record, review, evidence) do
    assert review.method == :source_only

    expected_range =
      case {record.lane, review.source_path} do
        {"floor", "asn1/src/asn1ct_parser2.erl"} -> 1..2305
        {"floor", "asn1/src/asn1ct_tok.erl"} -> 1..372
        {"core", path} -> Map.fetch!(@core_reviewed_ranges, path)
      end

    assert review.reviewed_ranges == [expected_range]
    assert review.citations != []
    sources = if record.lane == "core", do: @core_sources, else: @floor_sources
    assert review.sha256 == Map.fetch!(sources, review.source_path) |> elem(1)
    assert review.started_at < review.completed_at
    assert review.elapsed_seconds > 0
    {:ok, review_started, 0} = DateTime.from_iso8601(review.started_at)
    {:ok, review_completed, 0} = DateTime.from_iso8601(review.completed_at)
    assert DateTime.diff(review_completed, review_started, :second) == review.elapsed_seconds
    assert review.rationale != ""
    expected_disposition = if elem(review.mfa, 1) == :format_error, do: :pure_data, else: :tier
    assert review.disposition == expected_disposition

    expected_witness =
      if expected_disposition == :tier, do: :individual_mfa, else: :specific_exclusion

    assert review.removal_witness == expected_witness

    for {citation, expected} <- review.citations do
      source = SweepEvidence.resolve!(evidence, citation)
      assert source.origin == :archive
      assert source.sha256 == review.sha256
      assert source.text =~ expected
      assert File.stat!(source.path).size == review.bytes
    end
  end
end

defmodule Fablebook.Contract.TierSweepTest do
  use ExUnit.Case, async: false

  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.BeamWalker
  alias Fablebook.Test.DebuggerPendingOwnership
  alias Fablebook.Test.DebuggerSettings
  alias Fablebook.Test.ExternalTransformEvidence
  alias Fablebook.Test.GeneratorDispatchIntegrationEvidence
  alias Fablebook.Test.InstalledOtp
  alias Fablebook.Test.ParserTokenizerEvidence
  alias Fablebook.Test.SweepEvidence
  @compile {:no_warn_undefined, :xref}

  Code.ensure_loaded?(BannedCalls) ||
    Code.require_file(Path.expand("../../credo/checks/banned_calls.ex", __DIR__))

  # Historical active-disposition membership only. Discovery and inspection use the full install.
  @historical_active_otp_apps ~w(
    kernel stdlib compiler erts crypto public_key asn1 ssl inets syntax_tools tools parsetools
    runtime_tools sasl dialyzer xmerl os_mon
  )a
  @inets_trace_core_mfas [{:inets, :enable_trace, 2}, {:inets, :enable_trace, 3}]
  @inets_trace_core_url "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/inets/src/inets_app/inets_trace.erl"
  @elixir_apps [:elixir, :eex, :mix, :iex, :logger, :ex_unit]
  @floor_roots ~w(phoenix phoenix_live_view phoenix_html telemetry nimble_options)
  @reasons %{
    macro: "compile-time macro body; runs only while the caller is being compiled",
    own_native:
      "loads its own NIF or OTP's own trace or scanner driver by a fixed name; no caller-chosen library",
    callback:
      "process callback or loop; reached only through the module's front door, which the sweep judges separately",
    expansion:
      "expansion inside a module being compiled: evaluates only that module's own definitions; AST from input needs a banned parser or atom creation",
    own_clauses:
      "evaluates guards or patterns already compiled into the caller (error blame, assertion diff); takes no source",
    compiler_pass:
      "compiler, analysis or parse-transform pass: returns forms, Core or a binary and loads nothing",
    project_build: "Mix build step over the host project's own mix.exs, sources and lockfile",
    by_name:
      "loads a module by name from the code path; the code-path mutators are banned, so only beams already on the path load",
    cover_server:
      "cover server API over modules already cover-compiled through a banned :cover compile function",
    console: "boot, console or line-editing code of the running VM",
    crypto_key: "reaches only beam_lib's lookup of the fixed .erlang.crypt key file",
    epp_guard:
      "parses source with epp, whose -if conditions run as guard tests only; loads nothing",
    boot_script: "writes c:erlangrc into a generated boot script as data; loads nothing",
    dist_config: "evaluates the VM's own TLS distribution option file named on its command line",
    iex_console:
      "IEx console internal, reached only inside a running IEx through the banned IEx front doors",
    private_front:
      "private implementation reached only through an already tiered public front that the guard rejects",
    fixed_app:
      "puts only a named OTP application or Mix's own archive directory on the code path; loads no caller code",
    fixed_args: "calls a code-loading front door only with arguments fixed in its own source",
    not_compile_module:
      "named compile but compiles only regexes, assets or the host project's own build, as cited",
    pure_data:
      "transforms or queries the caller's data and returns it; loads, evaluates and changes no code or code path, as cited",
    fixed_default:
      "runs Logger.Formatter.new/0 with only the built-in default pattern and no caller options, as cited",
    unrelated_exunit_config:
      "writes only ExUnit plural-rule or after-suite configuration; it does not carry capture_log formatter options, as cited",
    runtime_internal:
      "operates on processes, ports, tables, tracing, counters or code already loaded; prepares, loads and evaluates nothing, as cited"
  }

  @escript_debug_mfa {:escript, :debug, 3}
  @escript_debug_source_assertions_by_lane %{
    "core" => [
      {"stdlib/src/escript.erl:36", "-export([start/0, start/1, parse_file/1])."},
      {"stdlib/src/escript.erl:422", "parse_and_run(File, Args, EscriptOptions);"},
      {"stdlib/src/escript.erl:475", "debug(Module, {Module, File, File, BeamBin}, Args);"},
      {"stdlib/src/escript.erl:889", "debug(Module, AbsMod, Args) ->"},
      {"stdlib/src/escript.erl:890", "hidden_apply(debugger, debugger, start, [])"},
      {"stdlib/src/escript.erl:892", "hidden_apply(debugger, int, i, [AbsMod])"},
      {"stdlib/src/escript.erl:894", "hidden_apply(debugger, debugger, auto_attach, [[init]])"},
      {"stdlib/src/escript.erl:1084", "apply(fun() -> M end(), F, Args)"}
    ],
    "floor" => [
      {"stdlib/src/escript.erl:32", "-export([start/0, start/1, parse_file/1])."},
      {"stdlib/src/escript.erl:418", "parse_and_run(File, Args, EscriptOptions);"},
      {"stdlib/src/escript.erl:471", "debug(Module, {Module, File, File, BeamBin}, Args);"},
      {"stdlib/src/escript.erl:885", "debug(Module, AbsMod, Args) ->"},
      {"stdlib/src/escript.erl:886", "hidden_apply(debugger, debugger, start, [])"},
      {"stdlib/src/escript.erl:888", "hidden_apply(debugger, int, i, [AbsMod])"},
      {"stdlib/src/escript.erl:890", "hidden_apply(debugger, debugger, auto_attach, [[init]])"},
      {"stdlib/src/escript.erl:1080", "apply(fun() -> M end(), F, Args)"}
    ]
  }
  @escript_debug_citations @escript_debug_source_assertions_by_lane
                           |> Map.values()
                           |> List.flatten()
                           |> Enum.map(fn {citation, _expected_source} -> citation end)
                           |> Enum.uniq()

  @ct_make_expected_mfas [
    {:ct_make, :all, 0},
    {:ct_make, :all, 1},
    {:ct_make, :files, 1},
    {:ct_make, :files, 2}
  ]

  @ct_make_expected_reached_mfas @ct_make_expected_mfas ++
                                   [
                                     {:ct_make, :check_includes, 3},
                                     {:ct_make, :check_includes2, 3},
                                     {:ct_make, :do_load, 3},
                                     {:ct_make, :do_make_files, 2},
                                     {:ct_make, :do_recompile, 4},
                                     {:ct_make, :get_opts_from_emakefile, 3},
                                     {:ct_make, :maybe_load, 3},
                                     {:ct_make, :process, 4},
                                     {:ct_make, :read_emakefile, 2},
                                     {:ct_make, :recompile, 4},
                                     {:ct_make, :recompile2, 5},
                                     {:ct_make, :recompilep, 4},
                                     {:ct_make, :recompilep1, 5},
                                     {:ct_make, :recompilep1, 6}
                                   ]

  @ct_make_source_by_lane %{
    "core" => %{
      sha256: "a6d46d0f31e75119b543ba5783782c7c48b358fa024a71763e5a7f2c6ff4d3a3",
      groups: %{
        all0: [
          {"common_test/src/ct_make.erl:37", "-export([all/0,all/1,files/1,files/2])."},
          {"common_test/src/ct_make.erl:43", "all() ->"},
          {"common_test/src/ct_make.erl:44", "all([])."}
        ],
        all1: [
          {"common_test/src/ct_make.erl:46", "all(Options) ->"},
          {"common_test/src/ct_make.erl:47", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:48", "read_emakefile('Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:50", "do_make_files(Files,MakeOpts)"}
        ],
        files1: [
          {"common_test/src/ct_make.erl:55", "files(Fs) ->"},
          {"common_test/src/ct_make.erl:56", "files(Fs, [])."}
        ],
        files2: [
          {"common_test/src/ct_make.erl:58", "files(Fs0, Options) ->"},
          {"common_test/src/ct_make.erl:59", "filename:rootname(F,\".erl\")"},
          {"common_test/src/ct_make.erl:60", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:61",
           "get_opts_from_emakefile(Fs,'Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:63", "do_make_files(Files,MakeOpts)"}
        ],
        emake_read: [
          {"common_test/src/ct_make.erl:94", "read_emakefile(Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:95", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:97", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:101", "filelib:wildcard(\"*.erl\")"},
          {"common_test/src/ct_make.erl:102", "[{Mods, Opts}]"},
          {"common_test/src/ct_make.erl:108",
           "transform([{Mod,ModOpts}|Emake],Opts,Files,Already) ->"},
          {"common_test/src/ct_make.erl:125", "expand(Mod,Already) when is_atom(Mod) ->"}
        ],
        emake_files: [
          {"common_test/src/ct_make.erl:150", "get_opts_from_emakefile(Mods,Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:151", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:153", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:156", "{error,enoent} ->"},
          {"common_test/src/ct_make.erl:157", "[{Mods, Opts}]"}
        ],
        options: [
          {"common_test/src/ct_make.erl:41", "-define(MakeOpts,[noexec,load,netload,noload])."},
          {"common_test/src/ct_make.erl:72", "sort_options([H|T],Make,Comp) ->"},
          {"common_test/src/ct_make.erl:80", "{Make,lists:reverse(Comp)}."},
          {"common_test/src/ct_make.erl:191", "load_opt(Opts) ->"},
          {"common_test/src/ct_make.erl:192", "lists:member(netload,Opts)"},
          {"common_test/src/ct_make.erl:194", "netload"},
          {"common_test/src/ct_make.erl:196", "lists:member(load,Opts)"},
          {"common_test/src/ct_make.erl:198", "load"},
          {"common_test/src/ct_make.erl:200", "noload"}
        ],
        process: [
          {"common_test/src/ct_make.erl:68", "do_make_files(Fs, Opts) ->"},
          {"common_test/src/ct_make.erl:69",
           "process(Fs, lists:member(noexec, Opts), load_opt(Opts), [])"},
          {"common_test/src/ct_make.erl:205",
           "process([{[],_Opts}|Rest], NoExec, Load, Result) ->"},
          {"common_test/src/ct_make.erl:208", "recompilep(coerce_2_list(H), NoExec, Load, Opts)"}
        ],
        compile: [
          {"common_test/src/ct_make.erl:288", "do_recompile(File, false, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:290",
           "compile:file(File, [report_errors, report_warnings |Opts])"},
          {"common_test/src/ct_make.erl:292", "maybe_load(element(2,Ok), Load, Opts)"}
        ],
        recompile: [
          {"common_test/src/ct_make.erl:226", "recompilep(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:235", "case exists(ObjFile) of"},
          {"common_test/src/ct_make.erl:237", "recompilep1(File, NoExec, Load, Opts, ObjFile)"},
          {"common_test/src/ct_make.erl:242",
           "recompilep1(File, NoExec, Load, Opts, ObjFile) ->"},
          {"common_test/src/ct_make.erl:243",
           "file:read_file_info(lists:append(File, \".erl\"))"},
          {"common_test/src/ct_make.erl:247", "recompilep1(Erl, Obj, File, NoExec, Load, Opts)"},
          {"common_test/src/ct_make.erl:252", "recompilep1(#file_info{mtime=Te},"},
          {"common_test/src/ct_make.erl:255",
           "recompilep1(_Erl, #file_info{mtime=To}, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:260",
           "recompile2(ObjMTime, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:261", "IncludePath = include_opt(Opts),"},
          {"common_test/src/ct_make.erl:262",
           "check_includes(lists:append(File, \".erl\"), IncludePath, ObjMTime)"},
          {"common_test/src/ct_make.erl:269", "include_opt([{i,Path}|Rest]) ->"},
          {"common_test/src/ct_make.erl:270", "[Path|include_opt(Rest)];"},
          {"common_test/src/ct_make.erl:271", "include_opt([_First|Rest]) ->"},
          {"common_test/src/ct_make.erl:273", "include_opt([]) ->"},
          {"common_test/src/ct_make.erl:280", "recompile(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:354", "check_includes(File, IncludePath, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:355", "Path = [filename:dirname(File)|IncludePath],"},
          {"common_test/src/ct_make.erl:356", "epp:open(File, Path, [])"},
          {"common_test/src/ct_make.erl:363", "check_includes2(Epp, File, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:365", "epp:parse_erl_form(Epp)"},
          {"common_test/src/ct_make.erl:368", "{IncFile, A1}"},
          {"common_test/src/ct_make.erl:369", "file:read_file_info(IncFile)"}
        ],
        noload: [
          {"common_test/src/ct_make.erl:200", "noload"},
          {"common_test/src/ct_make.erl:297", "maybe_load(_Mod, noload, _Opts) ->"}
        ],
        load_paths: [
          {"common_test/src/ct_make.erl:299", "maybe_load(Mod, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:302", "compile:output_generated(Opts)"},
          {"common_test/src/ct_make.erl:311", "do_load(Dir, Mod, load) ->"},
          {"common_test/src/ct_make.erl:313", "code:load_abs(filename:join(Dir, Mod),Mod)"},
          {"common_test/src/ct_make.erl:319", "do_load(Dir, Mod, netload) ->"},
          {"common_test/src/ct_make.erl:322", "file:read_file(Fname)"},
          {"common_test/src/ct_make.erl:324",
           "rpc:eval_everywhere(code,load_binary,[Mod,Fname,Bin])"}
        ]
      }
    },
    "floor" => %{
      sha256: "7f5dce364ae35232780c7904b6e45475aed4ba0d95105ee114f04e992492e62b",
      groups: %{
        all0: [
          {"common_test/src/ct_make.erl:33", "-export([all/0,all/1,files/1,files/2])."},
          {"common_test/src/ct_make.erl:39", "all() ->"},
          {"common_test/src/ct_make.erl:40", "all([])."}
        ],
        all1: [
          {"common_test/src/ct_make.erl:42", "all(Options) ->"},
          {"common_test/src/ct_make.erl:43", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:44", "read_emakefile('Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:46", "do_make_files(Files,MakeOpts)"}
        ],
        files1: [
          {"common_test/src/ct_make.erl:51", "files(Fs) ->"},
          {"common_test/src/ct_make.erl:52", "files(Fs, [])."}
        ],
        files2: [
          {"common_test/src/ct_make.erl:54", "files(Fs0, Options) ->"},
          {"common_test/src/ct_make.erl:55", "filename:rootname(F,\".erl\")"},
          {"common_test/src/ct_make.erl:56", "sort_options(Options,[],[])"},
          {"common_test/src/ct_make.erl:57",
           "get_opts_from_emakefile(Fs,'Emakefile',CompileOpts)"},
          {"common_test/src/ct_make.erl:59", "do_make_files(Files,MakeOpts)"}
        ],
        emake_read: [
          {"common_test/src/ct_make.erl:90", "read_emakefile(Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:91", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:93", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:97", "filelib:wildcard(\"*.erl\")"},
          {"common_test/src/ct_make.erl:98", "[{Mods, Opts}]"},
          {"common_test/src/ct_make.erl:104",
           "transform([{Mod,ModOpts}|Emake],Opts,Files,Already) ->"},
          {"common_test/src/ct_make.erl:121", "expand(Mod,Already) when is_atom(Mod) ->"}
        ],
        emake_files: [
          {"common_test/src/ct_make.erl:146", "get_opts_from_emakefile(Mods,Emakefile,Opts) ->"},
          {"common_test/src/ct_make.erl:147", "file:consult(Emakefile)"},
          {"common_test/src/ct_make.erl:149", "transform(Emake,Opts,[],[])"},
          {"common_test/src/ct_make.erl:152", "{error,enoent} ->"},
          {"common_test/src/ct_make.erl:153", "[{Mods, Opts}]"}
        ],
        options: [
          {"common_test/src/ct_make.erl:37", "-define(MakeOpts,[noexec,load,netload,noload])."},
          {"common_test/src/ct_make.erl:68", "sort_options([H|T],Make,Comp) ->"},
          {"common_test/src/ct_make.erl:76", "{Make,lists:reverse(Comp)}."},
          {"common_test/src/ct_make.erl:187", "load_opt(Opts) ->"},
          {"common_test/src/ct_make.erl:188", "lists:member(netload,Opts)"},
          {"common_test/src/ct_make.erl:190", "netload"},
          {"common_test/src/ct_make.erl:192", "lists:member(load,Opts)"},
          {"common_test/src/ct_make.erl:194", "load"},
          {"common_test/src/ct_make.erl:196", "noload"}
        ],
        process: [
          {"common_test/src/ct_make.erl:64", "do_make_files(Fs, Opts) ->"},
          {"common_test/src/ct_make.erl:65",
           "process(Fs, lists:member(noexec, Opts), load_opt(Opts), [])"},
          {"common_test/src/ct_make.erl:201",
           "process([{[],_Opts}|Rest], NoExec, Load, Result) ->"},
          {"common_test/src/ct_make.erl:204", "recompilep(coerce_2_list(H), NoExec, Load, Opts)"}
        ],
        compile: [
          {"common_test/src/ct_make.erl:284", "do_recompile(File, false, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:286",
           "compile:file(File, [report_errors, report_warnings |Opts])"},
          {"common_test/src/ct_make.erl:288", "maybe_load(element(2,Ok), Load, Opts)"}
        ],
        recompile: [
          {"common_test/src/ct_make.erl:222", "recompilep(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:231", "case exists(ObjFile) of"},
          {"common_test/src/ct_make.erl:233", "recompilep1(File, NoExec, Load, Opts, ObjFile)"},
          {"common_test/src/ct_make.erl:238",
           "recompilep1(File, NoExec, Load, Opts, ObjFile) ->"},
          {"common_test/src/ct_make.erl:239",
           "file:read_file_info(lists:append(File, \".erl\"))"},
          {"common_test/src/ct_make.erl:243", "recompilep1(Erl, Obj, File, NoExec, Load, Opts)"},
          {"common_test/src/ct_make.erl:248", "recompilep1(#file_info{mtime=Te},"},
          {"common_test/src/ct_make.erl:251",
           "recompilep1(_Erl, #file_info{mtime=To}, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:256",
           "recompile2(ObjMTime, File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:257", "IncludePath = include_opt(Opts),"},
          {"common_test/src/ct_make.erl:258",
           "check_includes(lists:append(File, \".erl\"), IncludePath, ObjMTime)"},
          {"common_test/src/ct_make.erl:265", "include_opt([{i,Path}|Rest]) ->"},
          {"common_test/src/ct_make.erl:266", "[Path|include_opt(Rest)];"},
          {"common_test/src/ct_make.erl:267", "include_opt([_First|Rest]) ->"},
          {"common_test/src/ct_make.erl:269", "include_opt([]) ->"},
          {"common_test/src/ct_make.erl:276", "recompile(File, NoExec, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:350", "check_includes(File, IncludePath, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:351", "Path = [filename:dirname(File)|IncludePath],"},
          {"common_test/src/ct_make.erl:352", "epp:open(File, Path, [])"},
          {"common_test/src/ct_make.erl:359", "check_includes2(Epp, File, ObjMTime) ->"},
          {"common_test/src/ct_make.erl:361", "epp:parse_erl_form(Epp)"},
          {"common_test/src/ct_make.erl:364", "{IncFile, A1}"},
          {"common_test/src/ct_make.erl:365", "file:read_file_info(IncFile)"}
        ],
        noload: [
          {"common_test/src/ct_make.erl:196", "noload"},
          {"common_test/src/ct_make.erl:293", "maybe_load(_Mod, noload, _Opts) ->"}
        ],
        load_paths: [
          {"common_test/src/ct_make.erl:295", "maybe_load(Mod, Load, Opts) ->"},
          {"common_test/src/ct_make.erl:298", "compile:output_generated(Opts)"},
          {"common_test/src/ct_make.erl:307", "do_load(Dir, Mod, load) ->"},
          {"common_test/src/ct_make.erl:309", "code:load_abs(filename:join(Dir, Mod),Mod)"},
          {"common_test/src/ct_make.erl:315", "do_load(Dir, Mod, netload) ->"},
          {"common_test/src/ct_make.erl:318", "file:read_file(Fname)"},
          {"common_test/src/ct_make.erl:320",
           "rpc:eval_everywhere(code,load_binary,[Mod,Fname,Bin])"}
        ]
      }
    }
  }

  @ct_make_family_specs [
    %{
      mfa: {:ct_make, :all, 0},
      source_group: :all0,
      source_groups: [
        :all0,
        :all1,
        :emake_read,
        :options,
        :noload,
        :process,
        :compile,
        :recompile
      ],
      caller_input: :current_directory_emakefile_and_erl_sources,
      defaults: :fixed_empty_options,
      option_paths: [:noload],
      trace: [
        {:ct_make, :all, 0},
        {:ct_make, :all, 1},
        {:ct_make, :sort_options, 3},
        {:ct_make, :read_emakefile, 2},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3}
      ],
      trace_call_sites: [
        {{:ct_make, :all, 1}, "all([])."},
        {{:ct_make, :all, 1}, "all(Options) ->"},
        {{:ct_make, :sort_options, 3}, "sort_options(Options,[],[])"}
      ],
      verdict: :default_compiles_current_directory_sources_without_loading,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe]
    },
    %{
      mfa: {:ct_make, :all, 1},
      source_group: :all1,
      source_groups: [:all1, :emake_read, :options, :load_paths, :process, :compile, :recompile],
      caller_input: :caller_options_and_current_directory_emakefile_sources,
      defaults: :caller_options_choose_compile_and_load_mode,
      option_paths: [:noload, :load, :netload],
      trace: [
        {:ct_make, :all, 1},
        {:ct_make, :sort_options, 3},
        {:ct_make, :read_emakefile, 2},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :load_opt, 1},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3},
        {:ct_make, :do_load, 3},
        {:code, :load_abs, 2},
        {:rpc, :eval_everywhere, 3}
      ],
      verdict: :caller_options_select_compile_and_local_or_remote_load,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe, :discarded_quote_source_only]
    },
    %{
      mfa: {:ct_make, :files, 1},
      source_group: :files1,
      source_groups: [
        :files1,
        :files2,
        :emake_files,
        :options,
        :noload,
        :process,
        :compile,
        :recompile
      ],
      caller_input: :caller_file_list_and_matching_emakefile_options,
      defaults: :fixed_empty_options,
      option_paths: [:noload],
      trace: [
        {:ct_make, :files, 1},
        {:ct_make, :files, 2},
        {:ct_make, :sort_options, 3},
        {:ct_make, :get_opts_from_emakefile, 3},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :get_opts_from_emakefile2, 4},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3}
      ],
      trace_call_sites: [
        {{:ct_make, :files, 2}, "files(Fs, [])."},
        {{:ct_make, :files, 2}, "files(Fs0, Options) ->"},
        {{:ct_make, :sort_options, 3}, "sort_options(Options,[],[])"}
      ],
      verdict: :default_compiles_caller_file_list_without_loading,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe]
    },
    %{
      mfa: {:ct_make, :files, 2},
      source_group: :files2,
      source_groups: [
        :files2,
        :emake_files,
        :options,
        :load_paths,
        :process,
        :compile,
        :recompile
      ],
      caller_input: :caller_file_list_options_and_matching_emakefile_options,
      defaults: :caller_options_choose_compile_and_load_mode,
      option_paths: [:noload, :load, :netload],
      trace: [
        {:ct_make, :files, 2},
        {:ct_make, :get_opts_from_emakefile, 3},
        {:file, :consult, 1},
        {:ct_make, :transform, 4},
        {:ct_make, :expand, 2},
        {:ct_make, :get_opts_from_emakefile2, 4},
        {:ct_make, :sort_options, 3},
        {:ct_make, :do_make_files, 2},
        {:ct_make, :load_opt, 1},
        {:ct_make, :process, 4},
        {:ct_make, :recompilep, 4},
        {:ct_make, :recompilep1, 5},
        {:ct_make, :recompilep1, 6},
        {:ct_make, :recompile2, 5},
        {:ct_make, :check_includes, 3},
        {:ct_make, :check_includes2, 3},
        {:ct_make, :recompile, 4},
        {:ct_make, :do_recompile, 4},
        {:compile, :file, 2},
        {:ct_make, :maybe_load, 3},
        {:ct_make, :do_load, 3},
        {:code, :load_abs, 2},
        {:rpc, :eval_everywhere, 3}
      ],
      verdict: :caller_files_and_options_select_compile_and_local_or_remote_load,
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe, :discarded_quote_source_only]
    }
  ]

  @ct_make_lanes ~w(core floor)
  @ct_make_expected_ids (for lane <- @ct_make_lanes, spec <- @ct_make_family_specs do
                           {"CT-#{String.upcase(lane)}-ct_make-#{elem(spec.mfa, 1)}-#{elem(spec.mfa, 2)}",
                            lane}
                         end)

  @ct_make_audit (for lane <- @ct_make_lanes, spec <- @ct_make_family_specs do
                    lane_source = Map.fetch!(@ct_make_source_by_lane, lane)

                    citations =
                      Enum.flat_map(spec.source_groups, &Map.fetch!(lane_source.groups, &1))

                    %{
                      original_id:
                        "CT-#{String.upcase(lane)}-ct_make-#{elem(spec.mfa, 1)}-#{elem(spec.mfa, 2)}",
                      original_matcher: {:mfa, spec.mfa},
                      original_reason: :tier,
                      lane: lane,
                      matched_mfas: [spec.mfa],
                      caller_input: spec.caller_input,
                      defaults: spec.defaults,
                      option_paths: spec.option_paths,
                      trace: spec.trace,
                      verdict: spec.verdict,
                      replacements: %{spec.mfa => {:tier, spec.mfa}},
                      tier: [spec.mfa],
                      fixtures: spec.fixtures,
                      citations: citations,
                      source_sha256: lane_source.sha256,
                      applicability: :each_exact_installed_lane,
                      removal_witness: :individual_exact_mfa
                    }
                  end)

  @debugger_family_modules [:dbg_idb, :dbg_istk, :dbg_wx_interpret]
  @saved_settings_changed_modules [:dbg_wx_settings, :dbg_wx_mon, :dbg_iserver, :int, :dbg_icmd]
  @saved_settings_expected_exclusion_matches []
  @debugger_active_modules [:dbg_idb, :dbg_istk, :dbg_wx_interpret]
  @debugger_baseline_active_modules [:dbg_idb, :dbg_istk, :dbg_wx_interpret]
  @debugger_source_only_seed_mfas [
    {:dbg_idb, :insert, 3},
    {:dbg_idb, :lookup, 2},
    {:dbg_idb, :match_object, 2},
    {:dbg_istk, :delayed_to_external, 0}
  ]
  @debugger_expected_exclusion_matches []
  @debugger_remainder_guard_mfas [
    {:int, :test_at_break, 3},
    {:dbg_wx_win, :entry, 4},
    {:dbg_wx_mon_win, :create_win, 3},
    {:dbg_wx_mon_win, :handle_event, 2},
    {:dbg_wx_break, :start, 3},
    {:dbg_wx_break, :start, 4},
    {:dbg_wx_break, :start, 5},
    {:dbg_wx_break_win, :create_win, 5},
    {:dbg_wx_break_win, :handle_event, 2},
    {:dbg_wx_trace, :start, 1},
    {:dbg_wx_trace, :start, 3},
    {:dbg_wx_trace, :start, 4},
    {:dbg_wx_trace_win, :create_win, 4},
    {:dbg_wx_trace_win, :handle_event, 2}
  ]
  @debugger_selected_file_mfa {:dbg_wx_interpret, :start, 4}
  @debugger_explicit_roots [
    {:dbg_wx_interpret, :start, 4},
    {:dbg_wx_interpret, :filter_files, 2},
    {:dbg_wx_interpret, :interpret_all, 5},
    {:dbg_istk, :from_external, 1}
  ]
  @debugger_baseline_roots [
    {:dbg_wx_interpret, :start, 4},
    {:dbg_wx_interpret, :filter_files, 2},
    {:dbg_wx_interpret, :interpret_all, 5},
    {:dbg_istk, :from_external, 1}
  ]
  @debugger_expected_exports [
    {:dbg_idb, :insert, 3},
    {:dbg_idb, :lookup, 2},
    {:dbg_idb, :match_object, 2},
    {:dbg_istk, :init, 0},
    {:dbg_istk, :delayed_to_external, 0},
    {:dbg_istk, :from_external, 1},
    {:dbg_istk, :push, 3},
    {:dbg_istk, :pop, 0},
    {:dbg_istk, :pop, 1},
    {:dbg_istk, :stack_level, 0},
    {:dbg_istk, :delayed_stacktrace, 0},
    {:dbg_istk, :delayed_stacktrace, 2},
    {:dbg_istk, :bindings, 1},
    {:dbg_istk, :stack_frame, 2},
    {:dbg_istk, :backtrace, 2},
    {:dbg_istk, :in_use_p, 2},
    {:dbg_wx_interpret, :start, 4}
  ]
  @debugger_expected_family_mfas [
    {:dbg_idb, :insert, 3},
    {:dbg_idb, :lookup, 2},
    {:dbg_idb, :match_object, 2},
    {:dbg_istk, :init, 0},
    {:dbg_istk, :delayed_to_external, 0},
    {:dbg_istk, :from_external, 1},
    {:dbg_istk, :init, 1},
    {:dbg_istk, :push, 3},
    {:dbg_istk, :pop, 0},
    {:dbg_istk, :pop, 1},
    {:dbg_istk, :pop, 2},
    {:dbg_istk, :stack_level, 0},
    {:dbg_istk, :stack_level, 1},
    {:dbg_istk, :delayed_stacktrace, 0},
    {:dbg_istk, :delayed_stacktrace, 2},
    {:dbg_istk, :stacktrace, 3},
    {:dbg_istk, :normalize, 1},
    {:dbg_istk, :finalize, 1},
    {:dbg_istk, :line, 1},
    {:dbg_istk, :bindings, 1},
    {:dbg_istk, :bindings, 2},
    {:dbg_istk, :stack_frame, 2},
    {:dbg_istk, :stack_frame, 3},
    {:dbg_istk, :backtrace, 2},
    {:dbg_istk, :in_use_p, 2},
    {:dbg_wx_interpret, :start, 4},
    {:dbg_wx_interpret, :filter_files, 2},
    {:dbg_wx_interpret, :interpret_all, 5},
    {:dbg_wx_interpret, :format_error, 1}
  ]
  @debugger_function_reviews %{
    {:dbg_idb, :insert, 3} => %{
      caller_input: :interpreter_database_reference_key_and_value,
      defaults: :none,
      option_paths: [:local_ets_insert, :remote_rpc_to_fixed_ets_insert],
      trace: [{:dbg_idb, :insert, 3}, {:ets, :insert, 2}],
      verdict: :fixed_ets_storage_dispatch_without_term_execution,
      owner: :plan_02
    },
    {:dbg_idb, :lookup, 2} => %{
      caller_input: :interpreter_database_reference_and_key,
      defaults: :none,
      option_paths: [:local_ets_lookup, :remote_rpc_to_fixed_ets_lookup],
      trace: [{:dbg_idb, :lookup, 2}, {:ets, :lookup, 2}, :ok_or_not_found],
      verdict: :fixed_ets_lookup_with_found_and_missing_results,
      owner: :plan_02
    },
    {:dbg_idb, :match_object, 2} => %{
      caller_input: :interpreter_database_reference_and_match_pattern,
      defaults: :none,
      option_paths: [:local_ets_match_object, :remote_rpc_to_fixed_ets_match_object],
      trace: [{:dbg_idb, :match_object, 2}, {:ets, :match_object, 2}],
      verdict: :fixed_ets_pattern_match_without_term_execution,
      owner: :plan_02
    },
    {:dbg_istk, :init, 0} => %{
      caller_input: :interpreter_process_initialization,
      defaults: :empty_stack,
      option_paths: [:delegate_to_init_1],
      trace: [{:dbg_istk, :init, 0}, {:dbg_istk, :init, 1}],
      verdict: :initializes_process_local_stack,
      owner: :plan_02
    },
    {:dbg_istk, :delayed_to_external, 0} => %{
      caller_input: :current_interpreter_process_stack,
      defaults: :none,
      option_paths: [:deferred_term_to_binary],
      trace: [{:dbg_istk, :delayed_to_external, 0}, {:erlang, :term_to_binary, 1}],
      verdict: :internal_stack_encoder_only,
      owner: :plan_02
    },
    {:dbg_istk, :from_external, 1} => %{
      caller_input: :caller_supplied_stack_binary,
      defaults: :no_validation_or_safe_decode_option,
      option_paths: [:binary_to_term_without_safe_option],
      trace: [
        {:dbg_istk, :from_external, 1},
        {:erlang, :binary_to_term, 1},
        :process_dictionary_stack_write
      ],
      verdict: :caller_binary_reaches_unrestricted_decode,
      owner: :plan_02
    },
    {:dbg_istk, :init, 1} => %{
      caller_input: :interpreter_initial_stack,
      defaults: :none,
      option_paths: [:process_dictionary_stack_write],
      trace: [{:dbg_istk, :init, 1}, :process_dictionary_stack_write],
      verdict: :initializes_internal_process_local_state,
      owner: :plan_02
    },
    {:dbg_istk, :push, 3} => %{
      caller_input: :bindings_ieval_frame_and_tail_call_flag,
      defaults: :trace_stack_mode_from_process_dictionary,
      option_paths: [:trace_stack_false, :no_tail_tail_call, :record_frame],
      trace: [{:dbg_istk, :push, 3}, :process_dictionary_stack_read_write],
      verdict: :records_internal_interpreter_frames_by_trace_mode,
      owner: :plan_02
    },
    {:dbg_istk, :pop, 0} => %{
      caller_input: :current_interpreter_stack,
      defaults: :trace_stack_mode_from_process_dictionary,
      option_paths: [:trace_stack_false, :pop_head, :empty_stack_ignore],
      trace: [{:dbg_istk, :pop, 0}, :process_dictionary_stack_read_write],
      verdict: :removes_internal_frame_or_ignores_empty_stack,
      owner: :plan_02
    },
    {:dbg_istk, :pop, 1} => %{
      caller_input: :requested_interpreter_level,
      defaults: :trace_stack_mode_from_process_dictionary,
      option_paths: [:trace_stack_false, :recursive_level_trim],
      trace: [{:dbg_istk, :pop, 1}, {:dbg_istk, :pop, 2}, :process_dictionary_stack_write],
      verdict: :trims_internal_frames_to_requested_level,
      owner: :plan_02
    },
    {:dbg_istk, :pop, 2} => %{
      caller_input: :requested_level_and_internal_stack,
      defaults: :none,
      option_paths: [:discard_frame_when_level_is_not_greater],
      trace: [{:dbg_istk, :pop, 2}, :recursive_stack_walk],
      verdict: :internal_recursive_stack_trimming,
      owner: :plan_02
    },
    {:dbg_istk, :stack_level, 0} => %{
      caller_input: :current_interpreter_stack,
      defaults: :empty_stack_level_is_one,
      option_paths: [:delegate_to_stack_level_1],
      trace: [{:dbg_istk, :stack_level, 0}, {:dbg_istk, :stack_level, 1}],
      verdict: :reports_top_internal_call_level,
      owner: :plan_02
    },
    {:dbg_istk, :stack_level, 1} => %{
      caller_input: :internal_stack_list,
      defaults: :empty_stack_level_is_one,
      option_paths: [:empty_stack, :top_frame_level],
      trace: [{:dbg_istk, :stack_level, 1}],
      verdict: :reads_internal_stack_level_only,
      owner: :plan_02
    },
    {:dbg_istk, :delayed_stacktrace, 0} => %{
      caller_input: :current_interpreter_stack,
      defaults: :none,
      option_paths: [:return_deferred_stacktrace_function],
      trace: [{:dbg_istk, :delayed_stacktrace, 0}, {:dbg_istk, :stacktrace, 3}],
      verdict: :converts_internal_frames_on_deferred_invocation,
      owner: :plan_02
    },
    {:dbg_istk, :delayed_stacktrace, 2} => %{
      caller_input: :argument_flag_and_interpreter_frame,
      defaults: :none,
      option_paths: [:include_args, :no_args],
      trace: [{:dbg_istk, :delayed_stacktrace, 2}, {:dbg_istk, :stacktrace, 3}],
      verdict: :returns_deferred_stacktrace_for_internal_frames,
      owner: :plan_02
    },
    {:dbg_istk, :stacktrace, 3} => %{
      caller_input: :entry_limit_internal_stack_and_accumulator,
      defaults: :none,
      option_paths: [:skip_tail_call_frames, :collapse_repeated_frames, :stop_at_limit],
      trace: [{:dbg_istk, :stacktrace, 3}, {:dbg_istk, :normalize, 1}],
      verdict: :formats_internal_stacktrace_without_invoking_frames,
      owner: :plan_02
    },
    {:dbg_istk, :normalize, 1} => %{
      caller_input: :internal_stack_entry,
      defaults: :none,
      option_paths: [:function_valued_frame, :module_function_frame],
      trace: [{:dbg_istk, :normalize, 1}],
      verdict: :converts_frame_to_trace_data_without_invocation,
      owner: :plan_02
    },
    {:dbg_istk, :finalize, 1} => %{
      caller_input: :normalized_internal_frame,
      defaults: :none,
      option_paths: [:module_tuple_frame, :function_frame],
      trace: [{:dbg_istk, :finalize, 1}, {:dbg_istk, :line, 1}],
      verdict: :formats_frame_metadata,
      owner: :plan_02
    },
    {:dbg_istk, :line, 1} => %{
      caller_input: :internal_location_metadata,
      defaults: :nonpositive_line_has_no_file_line_fields,
      option_paths: [:positive_line, :no_line],
      trace: [{:dbg_istk, :line, 1}, {:erlang, :atom_to_list, 1}],
      verdict: :formats_internal_source_location,
      owner: :plan_02
    },
    {:dbg_istk, :bindings, 1} => %{
      caller_input: :requested_internal_stack_pointer,
      defaults: :empty_stack_uses_new_bindings,
      option_paths: [:delegate_to_bindings_2],
      trace: [{:dbg_istk, :bindings, 1}, {:dbg_istk, :bindings, 2}],
      verdict: :reads_internal_interpreter_bindings,
      owner: :plan_02
    },
    {:dbg_istk, :bindings, 2} => %{
      caller_input: :stack_pointer_and_internal_stack_list,
      defaults: :empty_stack_uses_new_bindings,
      option_paths: [:matching_frame, :skip_frame, :empty_stack],
      trace: [{:dbg_istk, :bindings, 2}, {:erl_eval, :new_bindings, 0}],
      verdict: :reads_bindings_or_returns_empty_interpreter_bindings,
      owner: :plan_02
    },
    {:dbg_istk, :stack_frame, 2} => %{
      caller_input: :direction_and_internal_stack_pointer,
      defaults: :none,
      option_paths: [:up, :down_with_reversed_stack],
      trace: [{:dbg_istk, :stack_frame, 2}, {:dbg_istk, :stack_frame, 3}],
      verdict: :selects_adjacent_internal_frame_or_boundary,
      owner: :plan_02
    },
    {:dbg_istk, :stack_frame, 3} => %{
      caller_input: :stack_pointer_direction_and_internal_stack_list,
      defaults: :none,
      option_paths: [:next_lower_level, :next_higher_level, :top, :bottom],
      trace: [{:dbg_istk, :stack_frame, 3}],
      verdict: :walks_internal_frames_without_executing_them,
      owner: :plan_02
    },
    {:dbg_istk, :backtrace, 2} => %{
      caller_input: :entry_count_or_all_and_interpreter_frame,
      defaults: :none,
      option_paths: [:all_frames, :lists_sublist_count],
      trace: [{:dbg_istk, :backtrace, 2}, {:lists, :sublist, 2}],
      verdict: :returns_internal_frame_data,
      owner: :plan_02
    },
    {:dbg_istk, :in_use_p, 2} => %{
      caller_input: :module_atoms_and_internal_stack,
      defaults: :trace_disabled_treats_module_as_in_use,
      option_paths: [:same_module_true, :trace_stack_false_true, :scan_stack],
      trace: [{:dbg_istk, :in_use_p, 2}, {:lists, :any, 2}],
      verdict: :checks_internal_stack_module_presence,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :start, 4} => %{
      caller_input: :caller_selected_filenames_directory_and_mode,
      defaults: :monitor_supplied_local_or_global_mode,
      option_paths: [:dialog_accept, :dialog_cancel],
      trace: [{:dbg_wx_interpret, :start, 4}, {:dbg_wx_interpret, :interpret_all, 5}],
      verdict: :caller_selected_files_reach_interpreter,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :filter_files, 2} => %{
      caller_input: :file_dialog_directory_and_name,
      defaults: :other_extension_is_generic_file,
      option_paths: [:erl_source, :header, :beam, :other],
      trace: [{:dbg_wx_interpret, :filter_files, 2}, {:int, :interpretable, 1}],
      verdict: :filters_dialog_names_but_does_not_bound_interpreter_input,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :interpret_all, 5} => %{
      caller_input: :caller_selected_directory_files_and_mode,
      defaults: :empty_file_list_returns_or_reports_errors,
      option_paths: [:local_int_i, :global_int_ni, :per_file_error],
      trace: [
        {:dbg_wx_interpret, :interpret_all, 5},
        {:filename, :join, 2},
        {:int, :i, 1},
        {:int, :ni, 1}
      ],
      verdict: :selected_file_path_reaches_interpreter_entry_points,
      owner: :plan_02
    },
    {:dbg_wx_interpret, :format_error, 1} => %{
      caller_input: :interpreter_error_result,
      defaults: :unknown_error_tuple_has_no_clause,
      option_paths: [:known_file_or_debug_info_errors, :missing_file_error, :app_error],
      trace: [{:dbg_wx_interpret, :format_error, 1}],
      verdict: :maps_interpreter_failures_to_fixed_messages,
      owner: :plan_02
    }
  }

  @debugger_core_source %{
    sha256: %{
      "debugger/src/dbg_idb.erl" =>
        "3505ba8ce32c8ca147a1195a183cc78a841b28de479c29b5e92822afefea3593",
      "debugger/src/dbg_istk.erl" =>
        "a71cef371ac1875a22e851d44e4e47b5a1b87309709fca32073e78d51825e01c",
      "debugger/src/dbg_ieval.erl" =>
        "60362d2aa47470b70a9264c5a4f7c5e60e8362f844e3ec4171cc3733d2ff31d1",
      "debugger/src/dbg_wx_filedialog_win.erl" =>
        "d9a2e6bffb2f673d830c1c76585076c8510681a356a57c31547f838eaa9d858e",
      "debugger/src/dbg_wx_interpret.erl" =>
        "0731379c05425123893f08dab6d149f2e42f095f9245ff18d098691ab87520bb",
      "debugger/src/dbg_wx_mon.erl" =>
        "c47574e6f066df305154bbd893762011cf04ecb8315d8263cab415befbab22ff",
      "debugger/src/dbg_wx_mon_win.erl" =>
        "914439f252dc785d467980e163f001969a484cda8ae485b5833a3fcb65cbea30",
      "debugger/src/dbg_iload.erl" =>
        "a2dd4ad09550a866e5cc16834c0f006a146a21c3abc983f72d8ed44dd1a4b250",
      "debugger/src/dbg_wx_win.erl" =>
        "109bffa861fa1e6d71310a8ca91d57f2b2aa941d7220dfd440a79ad4bc286599"
    },
    citations: [
      {"debugger/src/dbg_wx_mon.erl:338", "gui_cmd('Interpret...', State) ->"},
      {"debugger/src/dbg_wx_interpret.erl:44", "start(Win, Pos, SDir, Mode) ->"},
      {"debugger/src/dbg_wx_interpret.erl:51", "{filter, fun filter_files/2}"},
      {"debugger/src/dbg_wx_interpret.erl:53", "case wxFileDialog:showModal(FD) of"},
      {"debugger/src/dbg_wx_interpret.erl:55", "Files = dbg_wx_filedialog_win:getFilenames(FD)"},
      {"debugger/src/dbg_wx_interpret.erl:56", "Dir   = dbg_wx_filedialog_win:getDirectory(FD)"},
      {"debugger/src/dbg_wx_interpret.erl:58", "interpret_all(Dir, Files, Mode, Win, [])"},
      {"debugger/src/dbg_wx_interpret.erl:59", "self() ! {dbg_ui_interpret, Dir}"},
      {"debugger/src/dbg_wx_filedialog_win.erl:79", "getFilenames(FD) ->"},
      {"debugger/src/dbg_wx_filedialog_win.erl:81", "getDirectory(FD) ->"},
      {"debugger/src/dbg_wx_interpret.erl:108", "File = filename:join(Dir, File0),"},
      {"debugger/src/dbg_wx_interpret.erl:110", "local -> int:i(File);"}
    ],
    export_citations: [
      {"debugger/src/dbg_idb.erl:26", "-export([insert/3, lookup/2, match_object/2])."},
      {"debugger/src/dbg_istk.erl:27", "-export([init/0,delayed_to_external/0,from_external/1,"},
      {"debugger/src/dbg_istk.erl:28", "push/3,pop/0,pop/1,stack_level/0,"},
      {"debugger/src/dbg_istk.erl:29", "delayed_stacktrace/0,delayed_stacktrace/2,"},
      {"debugger/src/dbg_istk.erl:30", "bindings/1,stack_frame/2,backtrace/2,"},
      {"debugger/src/dbg_istk.erl:31", "in_use_p/2])."},
      {"debugger/src/dbg_wx_interpret.erl:31", "-export([start/4])."}
    ],
    family_function_sources: [
      {{:dbg_idb, :insert, 3}, {"debugger/src/dbg_idb.erl:32", "insert(DbRef, Key, Value) ->"}},
      {{:dbg_idb, :lookup, 2}, {"debugger/src/dbg_idb.erl:40", "lookup(DbRef, Key) ->"}},
      {{:dbg_idb, :match_object, 2},
       {"debugger/src/dbg_idb.erl:52", "match_object(DbRef, Key) ->"}},
      {{:dbg_istk, :init, 0}, {"debugger/src/dbg_istk.erl:46", "init() ->"}},
      {{:dbg_istk, :delayed_to_external, 0},
       {"debugger/src/dbg_istk.erl:49", "delayed_to_external() ->"}},
      {{:dbg_istk, :from_external, 1},
       {"debugger/src/dbg_istk.erl:53", "from_external({stack,Stk}) ->"}},
      {{:dbg_istk, :init, 1}, {"debugger/src/dbg_istk.erl:56", "init(Stack) ->"}},
      {{:dbg_istk, :push, 3},
       {"debugger/src/dbg_istk.erl:73", "push(Bs, #ieval{level=Le,module=Mod,function=Name,"}},
      {{:dbg_istk, :pop, 0}, {"debugger/src/dbg_istk.erl:86", "pop() ->"}},
      {{:dbg_istk, :pop, 1}, {"debugger/src/dbg_istk.erl:98", "pop(Le) ->"}},
      {{:dbg_istk, :pop, 2},
       {"debugger/src/dbg_istk.erl:105", "pop(Level, [#e{level=Le}|Stack]) when Level =< Le ->"}},
      {{:dbg_istk, :stack_level, 0}, {"debugger/src/dbg_istk.erl:113", "stack_level() ->"}},
      {{:dbg_istk, :stack_level, 1}, {"debugger/src/dbg_istk.erl:116", "stack_level([]) -> 1;"}},
      {{:dbg_istk, :delayed_stacktrace, 0},
       {"debugger/src/dbg_istk.erl:127", "delayed_stacktrace() ->"}},
      {{:dbg_istk, :delayed_stacktrace, 2},
       {"debugger/src/dbg_istk.erl:134", "delayed_stacktrace(include_args, Ieval) ->"}},
      {{:dbg_istk, :stacktrace, 3},
       {"debugger/src/dbg_istk.erl:155", "stacktrace(N, [#e{lc=true}|T], Acc) ->"}},
      {{:dbg_istk, :normalize, 1},
       {"debugger/src/dbg_istk.erl:169",
        "normalize(#e{mfa={M,Fun,As},line=Li,error_info=ErrorInfo}) when is_function(Fun) ->"}},
      {{:dbg_istk, :finalize, 1},
       {"debugger/src/dbg_istk.erl:176", "finalize({M,F,A,Loc}) -> {M,F,A,line(Loc)};"}},
      {{:dbg_istk, :line, 1}, {"debugger/src/dbg_istk.erl:179", "line({Mod,Line,ErrorInfo}) ->"}},
      {{:dbg_istk, :bindings, 1}, {"debugger/src/dbg_istk.erl:190", "bindings(SP) ->"}},
      {{:dbg_istk, :bindings, 2},
       {"debugger/src/dbg_istk.erl:193", "bindings(SP, [#e{level=SP,bindings=Bs}|_]) ->"}},
      {{:dbg_istk, :stack_frame, 2}, {"debugger/src/dbg_istk.erl:209", "stack_frame(up, SP) ->"}},
      {{:dbg_istk, :stack_frame, 3},
       {"debugger/src/dbg_istk.erl:214",
        "stack_frame(SP, up, [#e{level=Le,mfa={Cm,_,_},line=Li,bindings=Bs}|_])"}},
      {{:dbg_istk, :backtrace, 2},
       {"debugger/src/dbg_istk.erl:236", "backtrace(HowMany, Ieval) ->"}},
      {{:dbg_istk, :in_use_p, 2},
       {"debugger/src/dbg_istk.erl:250", "in_use_p(Mod, Mod) -> true;"}},
      {{:dbg_wx_interpret, :start, 4},
       {"debugger/src/dbg_wx_interpret.erl:44", "start(Win, Pos, SDir, Mode) ->"}},
      {{:dbg_wx_interpret, :filter_files, 2},
       {"debugger/src/dbg_wx_interpret.erl:66", "filter_files(Dir, Name) ->"}},
      {{:dbg_wx_interpret, :interpret_all, 5},
       {"debugger/src/dbg_wx_interpret.erl:107",
        "interpret_all(Dir, [File0|Files], Mode, Window, Errors) ->"}},
      {{:dbg_wx_interpret, :format_error, 1},
       {"debugger/src/dbg_wx_interpret.erl:131",
        "format_error({error,no_beam}) -> \"No BEAM file\";"}}
    ],
    branch_citations: %{
      database_dispatch: [
        {"debugger/src/dbg_idb.erl:33", "case DbRef of"},
        {"debugger/src/dbg_idb.erl:35",
         "rpc:block_call(Node, ets, insert, [ModDb, {Key, Value}]);"},
        {"debugger/src/dbg_idb.erl:37", "ets:insert(ModDb, {Key, Value})"},
        {"debugger/src/dbg_idb.erl:42", "{Node, ModDb} ->"},
        {"debugger/src/dbg_idb.erl:43", "rpc:block_call(Node, ets, lookup, [ModDb, Key]);"},
        {"debugger/src/dbg_idb.erl:45", "ets:lookup(ModDb, Key)"},
        {"debugger/src/dbg_idb.erl:48", "[{Key, Value}] -> {ok, Value};"},
        {"debugger/src/dbg_idb.erl:49", "_ -> not_found"},
        {"debugger/src/dbg_idb.erl:55", "rpc:block_call(Node, ets, match_object, [ModDb, Key]);"},
        {"debugger/src/dbg_idb.erl:57", "ets:match_object(ModDb, Key)"}
      ],
      stack_lifecycle: [
        {"debugger/src/dbg_istk.erl:47", "init([])."},
        {"debugger/src/dbg_istk.erl:50", "Stack = get(?STACK),"},
        {"debugger/src/dbg_istk.erl:51", "fun() -> {stack,term_to_binary(Stack)} end."},
        {"debugger/src/dbg_istk.erl:54", "put(?STACK, binary_to_term(Stk))."},
        {"debugger/src/dbg_istk.erl:57", "put(?STACK, Stack)."},
        {"debugger/src/dbg_istk.erl:76", "case get(trace_stack) of"},
        {"debugger/src/dbg_istk.erl:77", "false ->"},
        {"debugger/src/dbg_istk.erl:79", "no_tail when Lc ->"},
        {"debugger/src/dbg_istk.erl:82", "put(?STACK, [Entry|get(?STACK)]),"},
        {"debugger/src/dbg_istk.erl:91", "[_Entry|Entries] ->"},
        {"debugger/src/dbg_istk.erl:93", "[] ->"},
        {"debugger/src/dbg_istk.erl:102", "put(?STACK, pop(Le, get(?STACK)))"},
        {"debugger/src/dbg_istk.erl:105", "pop(Level, [#e{level=Le}|Stack]) when Level =< Le ->"},
        {"debugger/src/dbg_istk.erl:107", "pop(_Level, Stack) ->"},
        {"debugger/src/dbg_istk.erl:116", "stack_level([]) -> 1;"},
        {"debugger/src/dbg_istk.erl:117", "stack_level([#e{level=Le}|_]) -> Le."}
      ],
      stack_trace: [
        {"debugger/src/dbg_istk.erl:134", "delayed_stacktrace(include_args, Ieval) ->"},
        {"debugger/src/dbg_istk.erl:147", "delayed_stacktrace(no_args, Ieval) ->"},
        {"debugger/src/dbg_istk.erl:155", "stacktrace(N, [#e{lc=true}|T], Acc) ->"},
        {"debugger/src/dbg_istk.erl:159", "stacktrace(N, [E|T], [{P,_}|_]=Acc) when N > 0 ->"},
        {"debugger/src/dbg_istk.erl:166", "stacktrace(_, _, Acc) ->"},
        {"debugger/src/dbg_istk.erl:169",
         "normalize(#e{mfa={M,Fun,As},line=Li,error_info=ErrorInfo}) when is_function(Fun) ->"},
        {"debugger/src/dbg_istk.erl:172",
         "normalize(#e{mfa={M,F,As},line=Li,error_info=ErrorInfo}) ->"},
        {"debugger/src/dbg_istk.erl:176", "finalize({M,F,A,Loc}) -> {M,F,A,line(Loc)};"},
        {"debugger/src/dbg_istk.erl:179", "line({Mod,Line,ErrorInfo}) ->"},
        {"debugger/src/dbg_istk.erl:185", "line(_) -> []."},
        {"debugger/src/dbg_istk.erl:193", "bindings(SP, [#e{level=SP,bindings=Bs}|_]) ->"},
        {"debugger/src/dbg_istk.erl:195", "bindings(SP, [_Entry|Entries]) ->"},
        {"debugger/src/dbg_istk.erl:197", "bindings(_SP, []) ->"},
        {"debugger/src/dbg_istk.erl:209", "stack_frame(up, SP) ->"},
        {"debugger/src/dbg_istk.erl:211", "stack_frame(down, SP) ->"},
        {"debugger/src/dbg_istk.erl:214",
         "stack_frame(SP, up, [#e{level=Le,mfa={Cm,_,_},line=Li,bindings=Bs}|_])"},
        {"debugger/src/dbg_istk.erl:217",
         "stack_frame(SP, down, [#e{level=Le,mfa={Cm,_,_},line=Li,bindings=Bs}|_])"},
        {"debugger/src/dbg_istk.erl:220", "stack_frame(SP, Dir, [#e{level=SP}|Stack]) ->"},
        {"debugger/src/dbg_istk.erl:239", "Stack = case HowMany of"},
        {"debugger/src/dbg_istk.erl:250", "in_use_p(Mod, Mod) -> true;"},
        {"debugger/src/dbg_istk.erl:252", "case get(trace_stack) of"},
        {"debugger/src/dbg_istk.erl:255",
         "lists:any(fun(#e{mfa={M,_,_}}) when M =:= Mod -> true;"}
      ],
      dialog_return: [
        {"debugger/src/dbg_wx_interpret.erl:53", "case wxFileDialog:showModal(FD) of"},
        {"debugger/src/dbg_wx_interpret.erl:54", "?wxID_OK ->"},
        {"debugger/src/dbg_wx_interpret.erl:55",
         "Files = dbg_wx_filedialog_win:getFilenames(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:56",
         "Dir   = dbg_wx_filedialog_win:getDirectory(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:57", "dbg_wx_filedialog_win:destroy(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:58", "interpret_all(Dir, Files, Mode, Win, [])"},
        {"debugger/src/dbg_wx_interpret.erl:59", "self() ! {dbg_ui_interpret, Dir}"},
        {"debugger/src/dbg_wx_filedialog_win.erl:79", "getFilenames(FD) ->"},
        {"debugger/src/dbg_wx_filedialog_win.erl:80", "wx_object:call(FD, getFilenames)"},
        {"debugger/src/dbg_wx_filedialog_win.erl:81", "getDirectory(FD) ->"},
        {"debugger/src/dbg_wx_filedialog_win.erl:82", "wx_object:call(FD, getDirectory)"},
        {"debugger/src/dbg_wx_filedialog_win.erl:83", "destroy(FD) ->"},
        {"debugger/src/dbg_wx_filedialog_win.erl:84", "wx_object:call(FD, destroy)"}
      ],
      dialog_cancel: [
        {"debugger/src/dbg_wx_interpret.erl:61", "_ ->"},
        {"debugger/src/dbg_wx_interpret.erl:62", "dbg_wx_filedialog_win:destroy(FD)"},
        {"debugger/src/dbg_wx_interpret.erl:63", "cancel"}
      ],
      parser_filter: [
        {"debugger/src/dbg_wx_interpret.erl:66", "filter_files(Dir, Name) ->"},
        {"debugger/src/dbg_wx_interpret.erl:67", "case filename:extension(Name) of"},
        {"debugger/src/dbg_wx_interpret.erl:68", "\".erl\" ->"},
        {"debugger/src/dbg_wx_interpret.erl:69", "File = filename:join(Dir, Name),"},
        {"debugger/src/dbg_wx_interpret.erl:70", "case int:interpretable(File) of"},
        {"debugger/src/dbg_wx_interpret.erl:71", "true ->"},
        {"debugger/src/dbg_wx_interpret.erl:73", "_ ->"},
        {"debugger/src/dbg_wx_interpret.erl:76", "\".hrl\" ->"},
        {"debugger/src/dbg_wx_interpret.erl:78", "\".beam\" ->"},
        {"debugger/src/dbg_wx_interpret.erl:80", "_ ->"}
      ],
      selected_files: [
        {"debugger/src/dbg_wx_interpret.erl:107",
         "interpret_all(Dir, [File0|Files], Mode, Window, Errors) ->"},
        {"debugger/src/dbg_wx_interpret.erl:108", "File = filename:join(Dir, File0),"},
        {"debugger/src/dbg_wx_interpret.erl:110", "local -> int:i(File);"},
        {"debugger/src/dbg_wx_interpret.erl:111", "global -> int:ni(File)"},
        {"debugger/src/dbg_wx_interpret.erl:114", "{module, _Mod} ->"},
        {"debugger/src/dbg_wx_interpret.erl:115",
         "interpret_all(Dir, Files, Mode, Window, Errors);"},
        {"debugger/src/dbg_wx_interpret.erl:116", "error ->"},
        {"debugger/src/dbg_wx_interpret.erl:117",
         "interpret_all(Dir, Files, Mode, Window, [File0|Errors])"}
      ],
      empty_and_errors: [
        {"debugger/src/dbg_wx_interpret.erl:119",
         "interpret_all(_Dir, [], _Mode, _Window, []) ->"},
        {"debugger/src/dbg_wx_interpret.erl:120", "true;"},
        {"debugger/src/dbg_wx_interpret.erl:121",
         "interpret_all(Dir, [], _Mode, Window, Errors) ->"},
        {"debugger/src/dbg_wx_interpret.erl:124",
         "Error = format_error(int:interpretable(File)),"},
        {"debugger/src/dbg_wx_interpret.erl:128",
         "dbg_wx_win:confirm(Window, lists:flatten(All)),"},
        {"debugger/src/dbg_wx_win.erl:231", "confirm(Win,Message) ->"},
        {"debugger/src/dbg_wx_interpret.erl:131",
         "format_error({error,no_beam}) -> \"No BEAM file\";"},
        {"debugger/src/dbg_wx_interpret.erl:132",
         "format_error({error,no_debug_info}) -> \"No debug_info in BEAM file\";"},
        {"debugger/src/dbg_wx_interpret.erl:133",
         "format_error({error,badarg}) -> \"File does not exist\";"},
        {"debugger/src/dbg_wx_interpret.erl:134", "format_error({error,{app,App}}) ->"}
      ]
    },
    ui_provenance_citations: [
      {"debugger/src/dbg_wx_mon.erl:173", "State3 = init_contents(int:interpreted(),"},
      {"debugger/src/dbg_wx_mon_win.erl:311",
       "MenuBtn = wxMenu:append(Menu, ?wxID_ANY, atom_to_list(Mod), Sub),"},
      {"debugger/src/dbg_wx_mon_win.erl:312",
       "wxListBox:append(WinInfo#winInfo.listbox, atom_to_list(Mod)),"},
      {"debugger/src/dbg_wx_mon_win.erl:120",
       "Fbtn = wxCheckBox:new(Panel, ?autoId, \"First Call\"),"},
      {"debugger/src/dbg_wx_mon_win.erl:122",
       "Bbtn = wxCheckBox:new(Panel, ?autoId, \"On Break\"),"},
      {"debugger/src/dbg_wx_mon_win.erl:124",
       "Ebtn = wxCheckBox:new(Panel, ?autoId, \"On Exit\"),"},
      {"debugger/src/dbg_wx_mon_win.erl:530",
       "handle_event(_Ev = #wx{event=#wxKey{keyCode=Key, controlDown=true}}, _WinInfo) ->"},
      {"debugger/src/dbg_wx_mon_win.erl:534", "{shortcut, list_to_atom([Key+($a-$A)])}"},
      {"debugger/src/dbg_wx_mon_win.erl:555",
       "handle_event(#wx{event=#wxCommand{type=command_listbox_doubleclicked, cmdString=ModS}},"},
      {"debugger/src/dbg_wx_mon_win.erl:557", "{module, list_to_atom(ModS), view};"},
      {"debugger/src/dbg_wx_mon_win.erl:573", "Check = fun(Button, NamesAcc) ->"},
      {"debugger/src/dbg_wx_mon_win.erl:577", "[list_to_atom(Name)|NamesAcc];"}
    ],
    cross_owner_support_citations: [
      {"debugger/src/dbg_iload.erl:78", "dbg_idb:insert(Db, mod_file, File),"},
      {"debugger/src/dbg_iload.erl:88", "store_forms(Forms, Mod, Db,"},
      {"debugger/src/dbg_iload.erl:97",
       "NewBinary = store_mod_line_no(Mod, Db, binary_to_list(Src)),"},
      {"debugger/src/dbg_iload.erl:98", "dbg_idb:insert(Db, mod_bin, NewBinary),"},
      {"debugger/src/dbg_iload.erl:99",
       "dbg_idb:insert(Db, mod_raw, <<Src/binary,0:8>>). %% Add eos"},
      {"debugger/src/dbg_iload.erl:162", "dbg_idb:insert(Db, {Mod,Name,Arity,Exported}, Cs),"},
      {"debugger/src/dbg_iload.erl:164",
       "store_forms([{attribute,_,record,{Name,Defs}}|Fs], Mod, Db, St) ->"},
      {"debugger/src/dbg_iload.erl:167",
       "dbg_idb:insert(Db, {record,Mod,Name,length(Fields)}, Fields),"},
      {"debugger/src/dbg_ieval.erl:538",
       "case dbg_idb:match_object(DbRef, {{Mod,Name,Arity,'_'},'_'}) of"},
      {"debugger/src/dbg_ieval.erl:546", "get_function(Mod, Name, Args, extern) ->"},
      {"debugger/src/dbg_ieval.erl:554", "case dbg_idb:lookup(DbRef, {Mod,Name,Arity,true}) of"},
      {"debugger/src/dbg_ieval.erl:558", "not_found ->"}
    ],
    seed_citations: [
      {"debugger/src/dbg_idb.erl:32", "insert(DbRef, Key, Value) ->"},
      {"debugger/src/dbg_idb.erl:40", "lookup(DbRef, Key) ->"},
      {"debugger/src/dbg_idb.erl:52", "match_object(DbRef, Key) ->"},
      {"debugger/src/dbg_istk.erl:49", "delayed_to_external() ->"}
    ],
    decoder_citations: [
      {"debugger/src/dbg_istk.erl:27", "-export([init/0,delayed_to_external/0,from_external/1,"},
      {"debugger/src/dbg_istk.erl:53", "from_external({stack,Stk}) ->"},
      {"debugger/src/dbg_istk.erl:54", "put(?STACK, binary_to_term(Stk))."}
    ],
    decoder_provenance_citations: [
      {"debugger/src/dbg_ieval.erl:68", "exit_info(Int, AttPid, OrigPid, Reason, ExitInfo) ->"},
      {"debugger/src/dbg_ieval.erl:76", "{{Mod,Line},Bs,S} ->"},
      {"debugger/src/dbg_ieval.erl:77", "dbg_istk:from_external(S),"},
      {"debugger/src/dbg_istk.erl:49", "delayed_to_external() ->"},
      {"debugger/src/dbg_istk.erl:51", "fun() -> {stack,term_to_binary(Stack)} end."},
      {"debugger/src/dbg_ieval.erl:149", "StackExternal = (dbg_istk:delayed_to_external())(),"},
      {"debugger/src/dbg_ieval.erl:150", "{{Mod, Li}, Bs, StackExternal};"},
      {"debugger/src/dbg_ieval.erl:188",
       "do_exception(Class, Reason, Stacktrace, Bs, #ieval{module=M, line=Line}) ->"},
      {"debugger/src/dbg_ieval.erl:189", "StackFun = dbg_istk:delayed_to_external(),"},
      {"debugger/src/dbg_ieval.erl:190", "ExitInfo = fun() ->"},
      {"debugger/src/dbg_ieval.erl:191", "{{M,Line},Bs,StackFun()}"},
      {"debugger/src/dbg_ieval.erl:193", "put(exit_info, ExitInfo),"}
    ]
  }

  @debugger_core_source Map.put(
                          @debugger_core_source,
                          :family_function_audit,
                          Enum.map(@debugger_expected_family_mfas, fn mfa ->
                            {^mfa, citation} =
                              Enum.find(@debugger_core_source.family_function_sources, fn
                                {candidate, _citation} -> candidate == mfa
                              end)

                            Map.merge(Map.fetch!(@debugger_function_reviews, mfa), %{
                              mfa: mfa,
                              citations: [citation]
                            })
                          end)
                        )

  @debugger_floor_source (
                           shift = fn {citation, expected} ->
                             [path, line] = String.split(citation, ":", parts: 2)

                             offset =
                               cond do
                                 String.ends_with?(path, "dbg_istk.erl") ->
                                   5

                                 String.ends_with?(path, "dbg_wx_mon.erl") ->
                                   4

                                 String.ends_with?(path, "dbg_wx_mon_win.erl") ->
                                   4

                                 String.ends_with?(path, "dbg_iload.erl") and
                                     String.to_integer(line) >= 160 ->
                                   17

                                 String.ends_with?(path, "dbg_iload.erl") ->
                                   1

                                 true ->
                                   2
                               end

                             {"#{path}:#{String.to_integer(line) - offset}", expected}
                           end

                           floor_hashes = %{
                             "debugger/src/dbg_idb.erl" =>
                               "990726cde6815d7616b01d13adf4f8cacc7540b702507ba0fea8ca349bbbe2c5",
                             "debugger/src/dbg_istk.erl" =>
                               "4f68bca517244f361bb915000fe299259242d6a8d733b064ed47d2f8872b8f66",
                             "debugger/src/dbg_ieval.erl" =>
                               "393085c1fc6324687bc12b5184b5a501491f07c8f55dc293ee07774ea96d0b6a",
                             "debugger/src/dbg_wx_filedialog_win.erl" =>
                               "4c4f8d9af1f3f326a952c1b4e181d1533c692f08b8954fd884233f7b2500ab2a",
                             "debugger/src/dbg_wx_interpret.erl" =>
                               "d41c9d6225a8817bd792abb202916020782d72b59e439a891b0ebc4864e38098",
                             "debugger/src/dbg_wx_mon.erl" =>
                               "8beded69315466f8b941d4395e4047453667c31404226a8e53ab229b47a6a05e",
                             "debugger/src/dbg_wx_mon_win.erl" =>
                               "971779c05b5d7c08317c04d33d7354a24a701ed35c2f96c9eef67d77d5a4cb25",
                             "debugger/src/dbg_iload.erl" =>
                               "530955c6525821e0382d53375ce5750cb4fd290ce4c323dd38521538452dae03",
                             "debugger/src/dbg_wx_win.erl" =>
                               "31b4f35b2f1c871404ce5d261aff965d630f6347edcfc9b084e1f8dc90ad061e"
                           }

                           Map.merge(@debugger_core_source, %{
                             sha256: floor_hashes,
                             citations: Enum.map(@debugger_core_source.citations, shift),
                             export_citations:
                               Enum.map(@debugger_core_source.export_citations, shift),
                             family_function_sources:
                               Enum.map(@debugger_core_source.family_function_sources, fn {mfa,
                                                                                           citation} ->
                                 {mfa, shift.(citation)}
                               end),
                             family_function_audit:
                               Enum.map(@debugger_core_source.family_function_audit, fn review ->
                                 %{review | citations: Enum.map(review.citations, shift)}
                               end),
                             branch_citations:
                               Map.new(@debugger_core_source.branch_citations, fn {group,
                                                                                   citations} ->
                                 {group, Enum.map(citations, shift)}
                               end),
                             seed_citations:
                               Enum.map(@debugger_core_source.seed_citations, shift),
                             decoder_citations:
                               Enum.map(@debugger_core_source.decoder_citations, shift),
                             decoder_provenance_citations:
                               Enum.map(@debugger_core_source.decoder_provenance_citations, shift),
                             ui_provenance_citations:
                               Enum.map(@debugger_core_source.ui_provenance_citations, shift),
                             cross_owner_support_citations:
                               Enum.map(
                                 @debugger_core_source.cross_owner_support_citations,
                                 shift
                               )
                           })
                         )

  @debugger_source_by_lane %{
    "core" => @debugger_core_source,
    "floor" => @debugger_floor_source
  }

  @debugger_audit (for lane <- @ct_make_lanes do
                     source = Map.fetch!(@debugger_source_by_lane, lane)
                     mfa = @debugger_selected_file_mfa

                     %{
                       original_id:
                         "NEW-DEBUGGER-#{String.upcase(lane)}-dbg_wx_interpret-start-4",
                       original_matcher: {:mfa, mfa},
                       original_reason: :tier,
                       lane: lane,
                       matched_mfas: [mfa],
                       caller_input: :caller_selected_filenames_and_directory,
                       defaults: :monitor_supplied_local_or_global_mode,
                       option_paths: [:local, :global],
                       trace: [
                         {:dbg_wx_mon, :gui_cmd, 2},
                         {:dbg_wx_interpret, :start, 4},
                         {:dbg_wx_filedialog_win, :getFilenames, 1},
                         {:dbg_wx_filedialog_win, :getDirectory, 1},
                         {:dbg_wx_interpret, :interpret_all, 5},
                         {:filename, :join, 2},
                         {:int, :i, 1},
                         {:int, :ni, 1}
                       ],
                       verdict: :caller_selected_files_reach_interpreter,
                       replacements: %{mfa => {:tier, mfa}},
                       tier: [mfa],
                       fixtures: [
                         :direct,
                         :capture,
                         :apply,
                         :utf8_literal,
                         :discarded_quote,
                         :uninvoked_macro
                       ],
                       citations: source.citations,
                       seed_citations: source.seed_citations,
                       decoder_mfa: {:dbg_istk, :from_external, 1},
                       decoder_caller_input: :arbitrary_exported_stack_binary,
                       decoder_options: :binary_to_term_without_safe_option,
                       decoder_trace: [
                         {:dbg_ieval, :exit_info, 5},
                         {:dbg_istk, :from_external, 1},
                         {:erlang, :binary_to_term, 1},
                         :process_dictionary_stack_write
                       ],
                       decoder_verdict: :caller_binary_is_unconstrained_at_export,
                       decoder_fixtures: [
                         :direct,
                         :capture,
                         :apply,
                         :discarded_quote,
                         :uninvoked_macro,
                         :serializing_only_control
                       ],
                       decoder_removal_witness: :uncalled_probe_mfa_tier_reduction,
                       decoder_citations: source.decoder_citations,
                       decoder_provenance_citations: source.decoder_provenance_citations,
                       internal_provenance: %{
                         producer: {:dbg_istk, :delayed_to_external, 0},
                         encoder: {:erlang, :term_to_binary, 1},
                         observed_consumer: {:dbg_ieval, :exit_info, 5},
                         verdict: :observed_internal_round_trip_does_not_constrain_public_input
                       },
                       export_citations: source.export_citations,
                       family_function_sources: source.family_function_sources,
                       family_function_audit: source.family_function_audit,
                       branch_citations: source.branch_citations,
                       ui_provenance_citations: source.ui_provenance_citations,
                       cross_owner_support_citations: source.cross_owner_support_citations,
                       seed_dispositions:
                         Enum.zip(@debugger_source_only_seed_mfas, source.seed_citations)
                         |> Enum.map(fn {mfa, citation} ->
                           %{
                             mfa: mfa,
                             reached: false,
                             verdict: :source_disposed_without_graph_hit,
                             citation: citation
                           }
                         end),
                       ui_provenance: %{
                         module_list_origin: {:int, :interpreted, 0},
                         module_name_display: :atom_to_list,
                         checkbox_labels: ["First Call", "On Break", "On Exit"],
                         label_conversion: :list_to_atom,
                         callback_owner: :phase_01_1_1_3_1,
                         callback_verdict: :synthetic_events_and_keyboard_inputs_pending
                       },
                       cross_owner_support: %{
                         dbg_iload: :cited_support_only_whole_module_review_pending,
                         dbg_ieval: :decoder_consumer_provenance_only,
                         dbg_wx_filedialog_win: :dialog_getters_only,
                         dbg_wx_mon: :module_list_origin_only,
                         dbg_wx_mon_win: :labels_and_callback_boundary_only,
                         dbg_wx_win: :error_dialog_provenance_only
                       },
                       exclusion_matches: @debugger_expected_exclusion_matches,
                       exclusion_identity_replacements: %{},
                       source_sha256: source.sha256,
                       empty_selection: :source_disposed_without_invocation,
                       limitations: [
                         :no_runtime_filename_decoding_claim,
                         :no_computed_dispatch_claim,
                         :no_write_then_load_claim,
                         :no_runtime_atom_count_claim
                       ],
                       applicability: :each_exact_installed_lane,
                       removal_witness: :uncalled_probe_mfa_tier_reduction
                     }
                   end)

  @debugger_expected_ids Enum.map(@ct_make_lanes, fn lane ->
                           {"NEW-DEBUGGER-#{String.upcase(lane)}-dbg_wx_interpret-start-4", lane}
                         end)

  @escript_debug_exclusion {{:mfa, @escript_debug_mfa}, :private_front, @escript_debug_citations}

  @call_name_exclusions [
    {{Phoenix.Digester, [:compile]}, :not_compile_module,
     ["phoenix/lib/phoenix/digester.ex:20", "phoenix/lib/phoenix/digester.ex:93"]},
    {{Phoenix.LiveView.ColocatedAssets, [:compile]}, :not_compile_module,
     [
       "phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:48",
       "phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:93"
     ]},
    {{Regex, [:compile]}, :not_compile_module,
     ["elixir/lib/regex.ex:219", "elixir/lib/regex.ex:223"]},
    {{:re, [:compile]}, :not_compile_module,
     [
       "stdlib/src/re.erl:128",
       "stdlib/src/re.erl:288",
       "stdlib/src/re.erl:86",
       "stdlib/src/re.erl:236"
     ]}
  ]

  @call_name_lane_specific [{{Mix.Compilers.Protocol, [:compile]}, :latest}]

  @calibration_source_archive_sha "27c45913ed03b510f2f44ccef8f65a95d932c9fb917e6c4e942b0cfd18a73894"

  @cn002_expected_matches_by_lane %{
    "core" => ["Elixir.Phoenix.Digester:compile/3"],
    "floor" => ["Elixir.Phoenix.Digester:compile/3"]
  }

  @cn001_expected_matches_by_lane %{
    "core" => ["Elixir.Mix.Compilers.Protocol:compile/4"],
    "floor" => []
  }

  @cn001_expected_direct_callers_by_lane %{
    "core" => [
      "Elixir.Mix.Compilers.Elixir:maybe_consolidate/4",
      "Elixir.Mix.Compilers.Protocol:umbrella/2"
    ],
    "floor" => []
  }

  @cn003_expected_direct_callers_by_lane %{
    "core" => ["Elixir.Mix.Tasks.Compile.PhoenixLiveView:compile/0"],
    "floor" => ["Elixir.Mix.Tasks.Compile.PhoenixLiveView:compile/0"]
  }

  @cn004_expected_direct_callers_by_lane %{
    "core" => [
      "Elixir.Phoenix.Controller.Pipeline:MACRO-__before_compile__/2",
      "Elixir.Phoenix.Router:build_pipes/2",
      "Elixir.Plug.Builder:MACRO-__before_compile__/2"
    ],
    "floor" => [
      "Elixir.Phoenix.Controller.Pipeline:MACRO-__before_compile__/2",
      "Elixir.Phoenix.Router:build_pipes/2",
      "Elixir.Plug.Builder:MACRO-__before_compile__/2"
    ]
  }

  @cn004_expected_matches_by_lane %{
    "core" => ["Elixir.Plug.Builder:compile/3"],
    "floor" => ["Elixir.Plug.Builder:compile/3"]
  }

  @cn006_expected_matches_by_lane %{
    "core" => ["re:compile/1", "re:compile/2"],
    "floor" => ["re:compile/1", "re:compile/2"]
  }

  @exclusions [
    {{:fun_prefix, "MACRO-"}, :macro},
    {:erl_tracer, :own_native},
    {:prim_buffer, :own_native},
    {:prim_file, :own_native},
    {:prim_net, :own_native},
    {:prim_socket, :own_native},
    {:prim_tty, :own_native},
    {:zlib, :own_native},
    {{:dbg, [:trace_port]}, :own_native},
    {{:inets, [:enable_trace]}, :own_native},
    {:inets_trace, :own_native},
    {:fprof, :own_native},
    {:erl_compile_server, :callback},
    {:peer, :callback},
    {{IEx.Introspection, [:decompose]}, :expansion},
    {{Kernel.Typespec, [:translate_typespecs_for_module]}, :expansion},
    {{Kernel.Utils, [:defguard]}, :expansion},
    {{Macro, [:expand, :expand_once, :expand_literal, :expand_literals]}, :expansion},
    {{Macro.Env, [:expand_import]}, :expansion},
    {{Module, [:add_doc, :compile_definition_attributes]}, :expansion},
    {{Protocol, [:__derive__, :__impl__]}, :expansion},
    {{Record, [:__access__]}, :expansion},
    {{ExUnit.Assertions, [:__expand_pattern__, :__match__]}, :expansion},
    {:elixir_bitstring, :expansion},
    {:elixir_clauses, :expansion},
    {:elixir_def, :expansion},
    {:elixir_dispatch, :expansion},
    {:elixir_expand, :expansion},
    {:elixir_fn, :expansion},
    {:elixir_map, :expansion},
    {:elixir_overridable, :expansion},
    {{:elixir_module, [:expand_callback]}, :expansion},
    {{:elixir_erl, [:definition_to_anonymous]}, :expansion},
    {Exception, :own_clauses},
    {FunctionClauseError, :own_clauses},
    {{Protocol, [:consolidate]}, :compiler_pass},
    {{:elixir_erl, [:compile, :consolidate, :debug_info]}, :compiler_pass},
    {:erl_abstract_code, :compiler_pass},
    {:beam_core_to_ssa, :compiler_pass},
    {:beam_ssa_bsm, :compiler_pass},
    {:beam_ssa_opt, :compiler_pass},
    {:beam_ssa_pre_codegen, :compiler_pass},
    {:v3_core, :compiler_pass},
    {:erl_compile, :compiler_pass},
    {:merl_transform, :compiler_pass},
    {:ms_transform, :compiler_pass},
    {{:qlc, [:parse_transform, :transform_from_evaluator]}, :compiler_pass},
    {:qlc_pt, :compiler_pass},
    {{:prefix, ":dialyzer"}, :compiler_pass},
    {:typer, :compiler_pass},
    {:typer_core, :compiler_pass},
    {Mix.AppLoader, :project_build},
    {Mix.Compilers.Elixir, :project_build},
    {Mix.Compilers.Protocol, :project_build},
    {Mix.Dep.Converger, :project_build},
    {Mix.Dep.Fetcher, :project_build},
    {Mix.Dep.Umbrella, :project_build},
    {Mix.Hex, :project_build},
    {{Mix.Project, [:compile, :deps_apps, :deps_paths, :deps_scms, :deps_tree]}, :project_build},
    {Mix.Release, :project_build},
    {Mix.Task.Compiler, :project_build},
    {{:prefix, "Mix.Tasks.App."}, :project_build},
    {{:prefix, "Mix.Tasks.Compile"}, :project_build},
    {{:prefix, "Mix.Tasks.Deps"}, :project_build},
    {Mix.Tasks.Archive.Build, :project_build},
    {Mix.Tasks.Archive.Uninstall, :project_build},
    {Mix.Tasks.Clean, :project_build},
    {Mix.Tasks.Cmd, :project_build},
    {Mix.Tasks.Do, :project_build},
    {Mix.Tasks.Escript.Build, :project_build},
    {Mix.Tasks.Escript.Uninstall, :project_build},
    {Mix.Tasks.Loadpaths, :project_build},
    {Mix.Tasks.Local.Hex, :project_build},
    {Mix.Tasks.New, :project_build},
    {Mix.Tasks.Release, :project_build},
    {Mix.Tasks.Source, :project_build},
    {Mix.Tasks.Xref, :project_build},
    {{:code, [:ensure_loaded, :ensure_modules_loaded, :load_file]}, :by_name},
    {:cover, :cover_server},
    {{:elixir, [:start, :start_cli]}, :console},
    {:erl_init, :console},
    {:edlin_context, :console},
    {:edlin_expand, :console},
    {:group, :console},
    {:standard_error, :console},
    {:user_drv, :console},
    {:beam_lib, :crypto_key},
    {{:escript, [:extract, :parse_file]}, :epp_guard},
    {:systools, :boot_script},
    {:systools_make, :boot_script},
    {{:ssl_dist_sup, [:start_link]}, :dist_config},
    {:inet_tls_dist, :dist_config},
    {:inet6_tls_dist, :dist_config},
    {:inet_epmd_tls_socket, :dist_config},
    {IEx.Autocomplete, :iex_console},
    {IEx.CLI, :iex_console},
    {IEx.Config, :iex_console},
    {IEx.Info.Atom, :iex_console},
    {IEx.Introspection, :iex_console},
    {{Mix, [:start]}, :callback},
    {:sasl, :callback},
    {{:prefix, "Mix.Tasks.Local."}, :project_build},
    {{Mix.Local,
      [:find_matching_versions!, :find_matching_versions_from_signed_csv!, :decode_pk!]},
     :project_build},
    {{Mix.Utils, [:read_path]}, :fixed_app},
    {:asn1_db, :compiler_pass},
    {{:prefix, ":asn1ct_"}, :compiler_pass},
    {{Mix.Tasks.Phx, [:run]}, :fixed_args, "phoenix/lib/mix/tasks/phx.ex:25"},
    {{Mix.Tasks.Phx.Gen, [:run]}, :fixed_args, "phoenix/lib/mix/tasks/phx.gen.ex:49"},
    {{Mix.Tasks.Phx.Digest, [:run]}, :project_build, "phoenix/lib/mix/tasks/phx.digest.ex:58"},
    {{Mix.Tasks.Phx.Digest.Clean, [:run]}, :project_build,
     "phoenix/lib/mix/tasks/phx.digest.clean.ex:43"},
    {{Mix.Phoenix, [:context_app_path, :context_lib_path, :context_test_path]}, :project_build,
     [
       "phoenix/lib/mix/phoenix.ex:230",
       "phoenix/lib/mix/phoenix.ex:249",
       "phoenix/lib/mix/phoenix.ex:256"
     ]},
    {{Mix.Task, [:reenable]}, :project_build, "mix/lib/mix/task.ex:631"},
    {{Mix.Task, [:preferred_cli_env]}, :project_build, "mix/lib/mix/task.ex:270"},
    {{Mix.Tasks.Test.Coverage, [:run]}, :project_build, "mix/lib/mix/tasks/test.coverage.ex:146"},
    {{Mix.Tasks.Test.Coverage, [:generate_cover_results]}, :cover_server,
     "mix/lib/mix/tasks/test.coverage.ex:273"},
    {{Mix.Dep, [:cached, :load_and_cache]}, :project_build,
     ["mix/lib/mix/dep.ex:95", "mix/lib/mix/dep.ex:113"]},
    {{Mix.Dep.Loader, [:children]}, :project_build, "mix/lib/mix/dep/loader.ex:21"},
    {{Mix.Compilers.Erlang, [:compile_entries]}, :project_build,
     "mix/lib/mix/compilers/erlang.ex:107"},
    {{Mix, [:stop]}, :callback, "mix/lib/mix.ex:470"},
    {{Phoenix.LiveView.TagEngine, [:handle_body]}, :callback,
     "phoenix_live_view/lib/phoenix_live_view/tag_engine.ex:275"},
    {{Phoenix.CodeReloader.Server, [:handle_call]}, :callback,
     [
       "phoenix/lib/phoenix/code_reloader/server.ex:90",
       "phoenix/lib/phoenix/code_reloader/server.ex:114"
     ]},
    {{Phoenix.ActionClauseError, [:blame, :message]}, :own_clauses,
     ["phoenix/lib/phoenix/exceptions.ex:50", "phoenix/lib/phoenix/exceptions.ex:57"]},
    {{Plug.Debugger, [:render, :__catch__]}, :own_clauses,
     ["plug/lib/plug/debugger.ex:170", "plug/lib/plug/debugger.ex:205"]},
    {{Plug.Builder, [:compile]}, :expansion, "plug/lib/plug/builder.ex:324"},
    {{Phoenix.Controller.Pipeline, [:__action_fallback__]}, :expansion,
     "phoenix/lib/phoenix/controller/pipeline.ex:39"},
    {{Module.Types.Apply,
      [
        :remote,
        :return_compare,
        :map_update_or_replace_lazy,
        :signature,
        :remote_apply,
        :remote_capture,
        :remote_domain,
        :format_diagnostic
      ]}, :compiler_pass,
     ["elixir/lib/module/types/apply.ex:364", "elixir/lib/module/types/apply.ex:263"]},
    {{Module.Types.Pattern,
      [:of_changed, :of_domain, :of_match_var, :of_match, :of_guard, :of_generator, :of_head]},
     :compiler_pass, ["elixir/lib/module/types/pattern.ex:65"]},
    {{Module.Types.Of, [:bitstring, :struct_info, :struct_instance]}, :compiler_pass,
     ["elixir/lib/module/types/of.ex:549"]},
    {{Module.Types.Expr, [:of_expr]}, :compiler_pass,
     ["elixir/lib/module/types/expr.ex:61", "elixir/lib/module/types/expr.ex:53"]},
    {{Module.Types.Traverse, [:of_expr]}, :compiler_pass,
     ["elixir/lib/module/types/traverse.ex:10"]},
    {{Module.Types, [:infer, :warnings]}, :compiler_pass,
     ["elixir/lib/module/types.ex:37", "elixir/lib/module/types.ex:36"]},
    {{Module.ParallelChecker, [:verify, :spawn]}, :compiler_pass,
     ["elixir/lib/module/parallel_checker.ex:151", "elixir/lib/module/parallel_checker.ex:114"]},
    {{:erl_syntax, [:is_literal, :concrete, :revert_forms, :revert]}, :compiler_pass,
     ["syntax_tools/src/erl_syntax.erl:7503", "syntax_tools/src/erl_syntax.erl:7154"]},
    {{:erl_syntax_lib,
      [:analyze_forms, :to_comment, :analyze_attribute, :analyze_wild_attribute, :analyze_form]},
     :compiler_pass,
     ["syntax_tools/src/erl_syntax_lib.erl:1013", "syntax_tools/src/erl_syntax_lib.erl:952"]},
    {{:erl_prettypr, [:best, :format, :layout]}, :compiler_pass,
     ["syntax_tools/src/erl_prettypr.erl:290", "syntax_tools/src/erl_prettypr.erl:281"]},
    {{:erl_recomment, [:quick_recomment_forms, :recomment_forms]}, :compiler_pass,
     ["syntax_tools/src/erl_recomment.erl:60", "syntax_tools/src/erl_recomment.erl:54"]},
    {{:erl_expand_records, [:module]}, :compiler_pass,
     ["stdlib/src/erl_expand_records.erl:89", "stdlib/src/erl_expand_records.erl:58"]},
    {{:xref_base,
      [
        :add_module,
        :replace_module,
        :add_application,
        :add_release,
        :replace_application,
        :update,
        :add_directory
      ]}, :compiler_pass, ["tools/src/xref_base.erl:130", "tools/src/xref_base.erl:126"]},
    {{:xref, [:d, :m, :handle_call]}, :compiler_pass,
     ["tools/src/xref.erl:791", "tools/src/xref.erl:732"]},
    {{:file_sorter, [:keycheck, :keymerge, :sort, :check, :keysort, :merge]}, :pure_data,
     ["stdlib/src/file_sorter.erl:437", "stdlib/src/file_sorter.erl:432"]},
    {{:systools_relup, [:mk_relup]}, :compiler_pass,
     ["sasl/src/systools_relup.erl:156", "sasl/src/systools_relup.erl:154"]},
    {{:dets, [:fsck, :istart_link, :system_continue, :init]}, :runtime_internal,
     ["stdlib/src/dets.erl:399", "stdlib/src/dets.erl:394"]},
    {{:dets_v9, [:compact_init, :bchunk_init]}, :runtime_internal,
     ["stdlib/src/dets_v9.erl:759", "stdlib/src/dets_v9.erl:754"]},
    {{:dets_sup, [:init]}, :runtime_internal,
     ["stdlib/src/dets_sup.erl:39", "stdlib/src/dets_sup.erl:37"]},
    {{:application_controller, [:start, :test_change_apps]}, :runtime_internal,
     ["kernel/src/application_controller.erl:198", "kernel/src/application_controller.erl:191"]},
    {{:application_controller, [:handle_call]}, :callback,
     ["kernel/src/application_controller.erl:198", "kernel/src/application_controller.erl:191"]},
    {{:httpd, [:reload_config, :start, :serve, :start_service]}, :runtime_internal,
     ["inets/src/http_server/httpd.erl:991", "inets/src/http_server/httpd.erl:955"]},
    {{:httpd_sup, [:start_child, :init]}, :runtime_internal,
     ["inets/src/http_server/httpd_sup.erl:57", "inets/src/http_server/httpd_sup.erl:52"]},
    {{:httpd_manager, [:handle_call]}, :callback,
     [
       "inets/src/http_server/httpd_manager.erl:185",
       "inets/src/http_server/httpd_manager.erl:182"
     ]},
    {{:inets, [:versions, :print_version_info]}, :pure_data,
     ["inets/src/inets_app/inets.erl:338", "inets/src/inets_app/inets.erl:334"]},
    {{:pool, [:start]}, :runtime_internal, ["stdlib/src/pool.erl:93", "stdlib/src/pool.erl:91"]},
    {{:net_adm, [:world, :host_file]}, :runtime_internal,
     ["kernel/src/net_adm.erl:242", "kernel/src/net_adm.erl:235"]},
    {{:inet_db, [:add_rc, :start_link, :start]}, :runtime_internal,
     ["kernel/src/inet_db.erl:283", "kernel/src/inet_db.erl:278"]},
    {{:inet_config, [:init]}, :runtime_internal,
     ["kernel/src/inet_config.erl:52", "kernel/src/inet_config.erl:48"]},
    {{:erts_code_purger, [:wait_for_request, :start]}, :runtime_internal,
     ["erts/src/erts_code_purger.erl:38", "erts/src/erts_code_purger.erl:36"]},
    {{:system_information, [:sanity_check, :from_file, :load_report, :report, :to_file]},
     :pure_data,
     [
       "runtime_tools/src/system_information.erl:207",
       "runtime_tools/src/system_information.erl:200"
     ]},
    {{:erts_debug, [:lc_graph_merge, :lc_graph_to_dot]}, :pure_data,
     ["kernel/src/erts_debug.erl:481", "kernel/src/erts_debug.erl:471"]},
    {{:otp_internal, [:obsolete]}, :pure_data,
     ["stdlib/src/otp_internal.erl:49", "stdlib/src/otp_internal.erl:29"]},
    {{:edlin_type_suggestion, [:get_atoms, :get_arity, :get_types]}, :console,
     ["stdlib/src/edlin_type_suggestion.erl:340", "stdlib/src/edlin_type_suggestion.erl:321"]},
    {{:shell, [:erl_pp_format_func]}, :console,
     ["stdlib/src/shell.erl:2158", "stdlib/src/shell.erl:2043"]},
    {{:beam_doc, [:main]}, :compiler_pass,
     ["compiler/src/beam_doc.erl:245", "compiler/src/beam_doc.erl:240"]},
    {{:elixir_errors, [:parse_error]}, :compiler_pass,
     ["elixir/lib/code.ex:1468", "elixir/lib/code.ex:1453"]},
    {{:systools_lib, [:read_term, :read_term_from_stream, :file_term2binary]}, :compiler_pass,
     ["sasl/src/systools_lib.erl:56", "sasl/src/systools_lib.erl:54"]},
    {{:qlc, [:info]}, :pure_data, ["stdlib/src/qlc.erl:521", "stdlib/src/qlc.erl:514"]},
    {{:dbg, [:rtp]}, :console,
     ["runtime_tools/src/dbg.erl:979", "runtime_tools/src/dbg.erl:1197"]},
    {{:dbg, [:fun2ms]}, :compiler_pass,
     ["runtime_tools/src/dbg.erl:979", "runtime_tools/src/dbg.erl:1197"]},
    {{:ets, [:fun2ms]}, :compiler_pass, ["stdlib/src/ets.erl:2447", "stdlib/src/ets.erl:2022"]},
    {{:msacc, [:from_file]}, :pure_data,
     ["runtime_tools/src/msacc.erl:209", "runtime_tools/src/msacc.erl:204"]},
    {{ExUnit.DocTest, [:__doctest_file__, :__doctests__]}, :compiler_pass,
     ["ex_unit/lib/ex_unit/doc_test.ex:297", "ex_unit/lib/ex_unit/doc_test.ex:269"]},
    {{UndefinedFunctionError, [:blame, :hint_for_loaded_module]}, :runtime_internal,
     ["elixir/lib/exception.ex:216", "elixir/lib/exception.ex:189"]},
    {{Mix.Generator, [:create_file, :copy_file]}, :project_build,
     ["mix/lib/mix/generator.ex:100", "mix/lib/mix/generator.ex:88"]},
    {{Mix.Phoenix.Context, [:function_count]}, :compiler_pass,
     ["phoenix/lib/mix/phoenix/context.ex:70"]},
    {{Mix.Tasks.Release.Init, [:run]}, :project_build,
     ["mix/lib/mix/tasks/release.init.ex:32", "mix/lib/mix/tasks/release.init.ex:28"]},
    {{Mix.Tasks.Phx.Gen.Context, [:prompt_for_code_injection]}, :project_build,
     ["phoenix/lib/mix/tasks/phx.gen.context.ex:445"]},
    {{Mix.Tasks.Phx.Gen.Cert, [:run]}, :project_build,
     ["phoenix/lib/mix/tasks/phx.gen.cert.ex:47"]},
    {{Phoenix.LiveView.HTMLAlgebra, [:build]}, :pure_data,
     ["phoenix_live_view/lib/phoenix_live_view/html_algebra.ex:24"]},
    {{Phoenix.Component.MacroComponent, [:build_ast]}, :compiler_pass,
     ["phoenix_live_view/lib/phoenix_component/macro_component.ex:214"]},
    {{:c, [:xm]}, :compiler_pass, ["stdlib/src/c.erl:1406", "stdlib/src/c.erl:1372"]},
    {{:kernel, [:init]}, :callback},
    {{:mfa, {Logger.Formatter, :new, 0}}, :fixed_default,
     [
       "logger/lib/logger/formatter.ex:117",
       "logger/lib/logger/formatter.ex:170",
       "logger/lib/logger/formatter.ex:436",
       "logger/lib/logger/formatter.ex:99",
       "logger/lib/logger/formatter.ex:152",
       "logger/lib/logger/formatter.ex:399"
     ]},
    {{:mfa, {ExUnit, :plural_rule, 2}}, :unrelated_exunit_config,
     [
       "ex_unit/lib/ex_unit.ex:456",
       "ex_unit/lib/ex_unit.ex:461",
       "ex_unit/lib/ex_unit.ex:392",
       "ex_unit/lib/ex_unit.ex:397"
     ]},
    {{:mfa, {ExUnit, :after_suite, 1}}, :unrelated_exunit_config,
     [
       "ex_unit/lib/ex_unit.ex:530",
       "ex_unit/lib/ex_unit.ex:532",
       "ex_unit/lib/ex_unit.ex:466",
       "ex_unit/lib/ex_unit.ex:468"
     ]}
  ]

  @creator_expected_lanes ~w(core floor)
  @creator_expected_original_mfas [{:file, :consult, 1}, {:file, :path_consult, 2}]
  @creator_expected_trace [
    {:file, :consult, 1},
    {:file, :path_consult, 2},
    {:file, :consult_stream, 1},
    {:file, :consult_stream, 3},
    {:io, :read, 3},
    {:io, :read, 4},
    {:erl_scan, :scan_atom, 6},
    {:erl_scan, :scan_qatom, 6}
  ]
  @creator_expected_fixtures [
    :path_consult_regression,
    :consult_direct,
    :consult_capture,
    :consult_apply,
    :consult_source_only_quote,
    :generated_mfa_probe
  ]
  @creator_expected_citation_lines %{
    "core" => ~w(
      kernel/src/file.erl:2272 kernel/src/file.erl:2273
      kernel/src/file.erl:2314 kernel/src/file.erl:2315 kernel/src/file.erl:2317
      kernel/src/file.erl:2900 kernel/src/file.erl:2905
      stdlib/src/io.erl:731 stdlib/src/io.erl:732 stdlib/src/io.erl:765
      stdlib/src/erl_scan.erl:788 stdlib/src/erl_scan.erl:1618
    ),
    "floor" => ~w(
      kernel/src/file.erl:2262 kernel/src/file.erl:2263
      kernel/src/file.erl:2304 kernel/src/file.erl:2305 kernel/src/file.erl:2307
      kernel/src/file.erl:2890 kernel/src/file.erl:2895
      stdlib/src/io.erl:700 stdlib/src/io.erl:701 stdlib/src/io.erl:734
      stdlib/src/erl_scan.erl:761 stdlib/src/erl_scan.erl:1591
    )
  }
  @creator_expected_ids for lane <- @creator_expected_lanes, do: {"EX-159", lane}

  @consult_creator_audit Enum.map(@creator_expected_lanes, fn lane ->
                           citations =
                             if lane == "core" do
                               [
                                 {"kernel/src/file.erl:2272", "consult(File) ->"},
                                 {"kernel/src/file.erl:2273", "open(File, [read])"},
                                 {"kernel/src/file.erl:2314", "path_consult(Path, File)"},
                                 {"kernel/src/file.erl:2315", "path_open(Path, File, [read])"},
                                 {"kernel/src/file.erl:2317", "consult_stream(Fd)"},
                                 {"kernel/src/file.erl:2900", "consult_stream(Fd) ->"},
                                 {"kernel/src/file.erl:2905", "io:read(Fd, '', Line)"},
                                 {"stdlib/src/io.erl:731", "read(Io, Prompt, Pos0) ->"},
                                 {"stdlib/src/io.erl:732", "read(Io, Prompt, Pos0, [])"},
                                 {"stdlib/src/io.erl:765", "erl_scan,tokens"},
                                 {"stdlib/src/erl_scan.erl:788", "list_to_atom(Wcs)"},
                                 {"stdlib/src/erl_scan.erl:1618",
                                  "list_to_atom(lists:reverse(Nwcs))"}
                               ]
                             else
                               [
                                 {"kernel/src/file.erl:2262", "consult(File) ->"},
                                 {"kernel/src/file.erl:2263", "open(File, [read])"},
                                 {"kernel/src/file.erl:2304", "path_consult(Path, File)"},
                                 {"kernel/src/file.erl:2305", "path_open(Path, File, [read])"},
                                 {"kernel/src/file.erl:2307", "consult_stream(Fd)"},
                                 {"kernel/src/file.erl:2890", "consult_stream(Fd) ->"},
                                 {"kernel/src/file.erl:2895", "io:read(Fd, '', Line)"},
                                 {"stdlib/src/io.erl:700", "read(Io, Prompt, Pos0) ->"},
                                 {"stdlib/src/io.erl:701", "read(Io, Prompt, Pos0, [])"},
                                 {"stdlib/src/io.erl:734", "erl_scan,tokens"},
                                 {"stdlib/src/erl_scan.erl:761", "list_to_atom(Wcs)"},
                                 {"stdlib/src/erl_scan.erl:1591",
                                  "list_to_atom(lists:reverse(Nwcs))"}
                               ]
                             end

                           %{
                             original_id: "EX-159",
                             original_matcher: {:file, [:path_consult, :consult]},
                             original_reason: :pure_data,
                             lane: lane,
                             matched_mfas: @creator_expected_original_mfas,
                             trace: @creator_expected_trace,
                             verdict: :caller_term_text_reaches_atom_creation,
                             replacements: @creator_expected_original_mfas,
                             tier: @creator_expected_original_mfas,
                             fixtures: @creator_expected_fixtures,
                             citations: citations,
                             applicability: :each_exact_installed_lane,
                             removal_witness: :not_applicable_tiered
                           }
                         end)

  @yecc_expected_original_mfas [
    {:yecc, :compile, 3},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :format_error, 1},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4}
  ]
  @yecc_expected_tier [
    {:yecc, :compile, 3},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4}
  ]
  @yecc_expected_trace [
    {:yecc, :compile, 3},
    {:yecc, :file, 1},
    {:yecc, :file, 2},
    {:yecc, :yecc, 2},
    {:yecc, :yecc, 3},
    {:yecc, :yecc, 4},
    {:yecc, :infile, 3},
    {:yecc, :start, 2},
    {:yecc, :generate, 1},
    {:yecc, :read_grammar, 3},
    {:yecc, :parse_grammar, 2},
    {:yecc, :subst_pseudo_vars, 3},
    {:yecc, :write_file, 1},
    {:yecc, :output_state_actions, 5},
    {:yecc, :inlined_function_name, 3},
    {String, :to_atom, 1}
  ]
  @yecc_expected_replacements %{
    {:yecc, :compile, 3} => {:tier, {:yecc, :compile, :_}},
    {:yecc, :file, 1} => {:tier, {:yecc, :file, 1}},
    {:yecc, :file, 2} => {:tier, {:yecc, :file, 2}},
    {:yecc, :yecc, 2} => {:tier, {:yecc, :yecc, 2}},
    {:yecc, :yecc, 3} => {:tier, {:yecc, :yecc, 3}},
    {:yecc, :yecc, 4} => {:tier, {:yecc, :yecc, 4}},
    {:yecc, :format_error, 1} => {:semantic, :module_error_formatter_dispatch_not_atom_creation}
  }
  @yecc_expected_verdict %{
    atom_creator_fronts: :caller_paths_reach_list_to_atom,
    format_error: :formats_descriptors_with_module_supplied_error_callback
  }
  @yecc_expected_fixtures [
    :yecc_direct,
    :yecc_capture,
    :yecc_apply,
    :yecc_discarded_quote_source_only,
    :generated_mfa_probe
  ]
  @yecc_expected_citation_lines %{
    "core" => ~w(
      parsetools/src/yecc.erl:493 parsetools/src/yecc.erl:498
      parsetools/src/yecc.erl:617 parsetools/src/yecc.erl:633
      parsetools/src/yecc.erl:649 parsetools/src/yecc.erl:665 parsetools/src/yecc.erl:666
      parsetools/src/yecc.erl:711 parsetools/src/yecc.erl:748 parsetools/src/yecc.erl:749
      parsetools/src/yecc.erl:823 parsetools/src/yecc.erl:837 parsetools/src/yecc.erl:845
      parsetools/src/yecc.erl:850 parsetools/src/yecc.erl:854 parsetools/src/yecc.erl:858
      parsetools/src/yecc.erl:860 parsetools/src/yecc.erl:938 parsetools/src/yecc.erl:990
      parsetools/src/yecc.erl:1006 parsetools/src/yecc.erl:1008 parsetools/src/yecc.erl:1011
      parsetools/src/yecc.erl:1020 parsetools/src/yecc.erl:1041 parsetools/src/yecc.erl:1111
      parsetools/src/yecc.erl:1144 parsetools/src/yecc.erl:1167 parsetools/src/yecc.erl:1199
      parsetools/src/yecc.erl:1200 parsetools/src/yecc.erl:1212 parsetools/src/yecc.erl:1421
      parsetools/src/yecc.erl:1437 parsetools/src/yecc.erl:1624 parsetools/src/yecc.erl:2756
      parsetools/src/yecc.erl:2774 parsetools/src/yecc.erl:2968 parsetools/src/yecc.erl:2973
      parsetools/src/yecc.erl:2975 parsetools/src/yecc.erl:2977
    ),
    "floor" => ~w(
      parsetools/src/yecc.erl:488 parsetools/src/yecc.erl:493
      parsetools/src/yecc.erl:612 parsetools/src/yecc.erl:628
      parsetools/src/yecc.erl:644 parsetools/src/yecc.erl:660 parsetools/src/yecc.erl:661
      parsetools/src/yecc.erl:706 parsetools/src/yecc.erl:743 parsetools/src/yecc.erl:744
      parsetools/src/yecc.erl:818 parsetools/src/yecc.erl:832 parsetools/src/yecc.erl:840
      parsetools/src/yecc.erl:845 parsetools/src/yecc.erl:849 parsetools/src/yecc.erl:853
      parsetools/src/yecc.erl:855 parsetools/src/yecc.erl:933 parsetools/src/yecc.erl:985
      parsetools/src/yecc.erl:1001 parsetools/src/yecc.erl:1003 parsetools/src/yecc.erl:1006
      parsetools/src/yecc.erl:1015 parsetools/src/yecc.erl:1036 parsetools/src/yecc.erl:1106
      parsetools/src/yecc.erl:1139 parsetools/src/yecc.erl:1162 parsetools/src/yecc.erl:1194
      parsetools/src/yecc.erl:1195 parsetools/src/yecc.erl:1207 parsetools/src/yecc.erl:1416
      parsetools/src/yecc.erl:1432 parsetools/src/yecc.erl:1619 parsetools/src/yecc.erl:2750
      parsetools/src/yecc.erl:2768 parsetools/src/yecc.erl:2962 parsetools/src/yecc.erl:2967
      parsetools/src/yecc.erl:2969 parsetools/src/yecc.erl:2971
    )
  }
  @yecc_expected_ids for lane <- @creator_expected_lanes, do: {"EX-089", lane}

  @yecc_audit Enum.map(@creator_expected_lanes, fn lane ->
                citations =
                  if lane == "core" do
                    [
                      {"parsetools/src/yecc.erl:493",
                       "-export([compile/3, file/1, file/2, format_error/1])."},
                      {"parsetools/src/yecc.erl:498", "-export([yecc/2, yecc/3, yecc/4])."},
                      {"parsetools/src/yecc.erl:617", "case file(Input, Opts) of"},
                      {"parsetools/src/yecc.erl:633", "format_error(bad_declaration) ->"},
                      {"parsetools/src/yecc.erl:649", "atom_to_list(Tag)"},
                      {"parsetools/src/yecc.erl:665", "format_error({error, Module, Error}) ->"},
                      {"parsetools/src/yecc.erl:666", "Module:format_error(Error);"},
                      {"parsetools/src/yecc.erl:711", "format_error(cannot_parse) ->"},
                      {"parsetools/src/yecc.erl:748", "file(GrammarFile) ->"},
                      {"parsetools/src/yecc.erl:749",
                       "file(GrammarFile, [report_errors, report_warnings])."},
                      {"parsetools/src/yecc.erl:823",
                       "file(File, Options0) when is_list(Options0) ->"},
                      {"parsetools/src/yecc.erl:837",
                       "Pid = spawn_link(fun() -> infile(Self, File, OptionValues) end),"},
                      {"parsetools/src/yecc.erl:845", "file(File, Option) ->"},
                      {"parsetools/src/yecc.erl:850", "yecc(Infile, Outfile) ->"},
                      {"parsetools/src/yecc.erl:854", "yecc(Infile, Outfile, Verbose) ->"},
                      {"parsetools/src/yecc.erl:858",
                       "yecc(Infilex, Outfilex, Verbose, Includefilex) ->"},
                      {"parsetools/src/yecc.erl:860",
                       "case file(Infilex, [{parserfile, Outfilex},"},
                      {"parsetools/src/yecc.erl:938",
                       "when Option =:= includefile; Option =:= parserfile ->"},
                      {"parsetools/src/yecc.erl:990", "is_filename(T) ->"},
                      {"parsetools/src/yecc.erl:1006", "start(Infilex, Options) ->"},
                      {"parsetools/src/yecc.erl:1008",
                       "{_, Outfilex0} = lists:keyfind(parserfile, 1, Options),"},
                      {"parsetools/src/yecc.erl:1011",
                       "[] -> filename:rootname(Infilex, \".yrl\");"},
                      {"parsetools/src/yecc.erl:1020",
                       "Module = list_to_atom(filename:basename(Outfile, \".erl\")),"},
                      {"parsetools/src/yecc.erl:1041", "St0 = start(Infilex, Options),"},
                      {"parsetools/src/yecc.erl:1111", "generate(St0) ->"},
                      {"parsetools/src/yecc.erl:1144",
                       "{NextLocation, Grammar} = read_grammar(Inport, St, Location),"},
                      {"parsetools/src/yecc.erl:1167",
                       "{Tokens1, St} = subst_pseudo_vars(AllTokens,"},
                      {"parsetools/src/yecc.erl:1199", "read_grammar(Inport, St, Location) ->"},
                      {"parsetools/src/yecc.erl:1200",
                       "case yeccscan:scan(Inport, '', Location) of"},
                      {"parsetools/src/yecc.erl:1212", "case yeccparser:parse(Input) of"},
                      {"parsetools/src/yecc.erl:1421", "write_file(St0) ->"},
                      {"parsetools/src/yecc.erl:1437",
                       "St50 = output_actions(St40, StateJumps, StateInfo),"},
                      {"parsetools/src/yecc.erl:1624",
                       "{{var, NewAnno, list_to_atom(PseudoVarName)}, St0};"},
                      {"parsetools/src/yecc.erl:2756",
                       "output_state_actions(St_0, State, IState,"},
                      {"parsetools/src/yecc.erl:2774",
                       "jump_some -> list_to_atom(lists:concat([cont_, To]));"},
                      {"parsetools/src/yecc.erl:2968",
                       "inlined_function_name(St, State, Terminal) ->"},
                      {"parsetools/src/yecc.erl:2973",
                       "list_to_atom(concat([yeccpars2_, State, '_'] ++ End))."},
                      {"parsetools/src/yecc.erl:2975",
                       "-compile({nowarn_unused_function,function_name/3})."},
                      {"parsetools/src/yecc.erl:2977",
                       "list_to_atom(concat([Name, '_', safe_atom_chars(St, Suf)]))."}
                    ]
                  else
                    [
                      {"parsetools/src/yecc.erl:488",
                       "-export([compile/3, file/1, file/2, format_error/1])."},
                      {"parsetools/src/yecc.erl:493", "-export([yecc/2, yecc/3, yecc/4])."},
                      {"parsetools/src/yecc.erl:612", "case file(Input, Opts) of"},
                      {"parsetools/src/yecc.erl:628", "format_error(bad_declaration) ->"},
                      {"parsetools/src/yecc.erl:644", "atom_to_list(Tag)"},
                      {"parsetools/src/yecc.erl:660", "format_error({error, Module, Error}) ->"},
                      {"parsetools/src/yecc.erl:661", "Module:format_error(Error);"},
                      {"parsetools/src/yecc.erl:706", "format_error(cannot_parse) ->"},
                      {"parsetools/src/yecc.erl:743", "file(GrammarFile) ->"},
                      {"parsetools/src/yecc.erl:744",
                       "file(GrammarFile, [report_errors, report_warnings])."},
                      {"parsetools/src/yecc.erl:818",
                       "file(File, Options0) when is_list(Options0) ->"},
                      {"parsetools/src/yecc.erl:832",
                       "Pid = spawn_link(fun() -> infile(Self, File, OptionValues) end),"},
                      {"parsetools/src/yecc.erl:840", "file(File, Option) ->"},
                      {"parsetools/src/yecc.erl:845", "yecc(Infile, Outfile) ->"},
                      {"parsetools/src/yecc.erl:849", "yecc(Infile, Outfile, Verbose) ->"},
                      {"parsetools/src/yecc.erl:853",
                       "yecc(Infilex, Outfilex, Verbose, Includefilex) ->"},
                      {"parsetools/src/yecc.erl:855",
                       "case file(Infilex, [{parserfile, Outfilex},"},
                      {"parsetools/src/yecc.erl:933",
                       "when Option =:= includefile; Option =:= parserfile ->"},
                      {"parsetools/src/yecc.erl:985", "is_filename(T) ->"},
                      {"parsetools/src/yecc.erl:1001", "start(Infilex, Options) ->"},
                      {"parsetools/src/yecc.erl:1003",
                       "{_, Outfilex0} = lists:keyfind(parserfile, 1, Options),"},
                      {"parsetools/src/yecc.erl:1006",
                       "[] -> filename:rootname(Infilex, \".yrl\");"},
                      {"parsetools/src/yecc.erl:1015",
                       "Module = list_to_atom(filename:basename(Outfile, \".erl\")),"},
                      {"parsetools/src/yecc.erl:1036", "St0 = start(Infilex, Options),"},
                      {"parsetools/src/yecc.erl:1106", "generate(St0) ->"},
                      {"parsetools/src/yecc.erl:1139",
                       "{NextLocation, Grammar} = read_grammar(Inport, St, Location),"},
                      {"parsetools/src/yecc.erl:1162",
                       "{Tokens1, St} = subst_pseudo_vars(AllTokens,"},
                      {"parsetools/src/yecc.erl:1194", "read_grammar(Inport, St, Location) ->"},
                      {"parsetools/src/yecc.erl:1195",
                       "case yeccscan:scan(Inport, '', Location) of"},
                      {"parsetools/src/yecc.erl:1207", "case yeccparser:parse(Input) of"},
                      {"parsetools/src/yecc.erl:1416", "write_file(St0) ->"},
                      {"parsetools/src/yecc.erl:1432",
                       "St50 = output_actions(St40, StateJumps, StateInfo),"},
                      {"parsetools/src/yecc.erl:1619",
                       "{{var, NewAnno, list_to_atom(PseudoVarName)}, St0};"},
                      {"parsetools/src/yecc.erl:2750",
                       "output_state_actions(St_0, State, IState,"},
                      {"parsetools/src/yecc.erl:2768",
                       "jump_some -> list_to_atom(lists:concat([cont_, To]));"},
                      {"parsetools/src/yecc.erl:2962",
                       "inlined_function_name(St, State, Terminal) ->"},
                      {"parsetools/src/yecc.erl:2967",
                       "list_to_atom(concat([yeccpars2_, State, '_'] ++ End))."},
                      {"parsetools/src/yecc.erl:2969",
                       "-compile({nowarn_unused_function,function_name/3})."},
                      {"parsetools/src/yecc.erl:2971",
                       "list_to_atom(concat([Name, '_', safe_atom_chars(St, Suf)]))."}
                    ]
                  end

                %{
                  original_id: "EX-089",
                  original_matcher: {:yecc, :epp_guard},
                  original_reason: :epp_guard,
                  lane: lane,
                  matched_mfas: @yecc_expected_original_mfas,
                  trace: @yecc_expected_trace,
                  verdict: @yecc_expected_verdict,
                  replacements: @yecc_expected_replacements,
                  tier: @yecc_expected_tier,
                  fixtures: @yecc_expected_fixtures,
                  citations: citations,
                  applicability: :each_exact_installed_lane,
                  removal_witness: :not_applicable_blanket_retired
                }
              end)

  # Independent boundary for the source-reviewed MFA family on each pinned lane.
  # This inventory deliberately does not come from @logger_family_specs: if a
  # spec and the records generated from it disappear together, the audit must
  # still detect the omitted export. The active graph below checks these
  # version-pinned MFAs against the exports present on the exact installed lane.
  @logger_family_universe %{
    "core" => [
      {"LOGGER", {Logger.Formatter, :compile, 1}},
      {"LOGGER", {Logger.Formatter, :new, 1}},
      {"LOGGER", {Logger, :configure_backend, 2}},
      {"LOGGER", {Logger, :default_formatter, 0}},
      {"LOGGER", {Logger, :default_formatter, 1}},
      {"LOGGER", {Logger.Formatter, :new, 0}},
      {"LOGGER", {Logger.App, :start, 0}},
      {"LOGGER", {Logger.App, :start, 2}},
      {"EXUNIT", {ExUnit.CaptureServer, :handle_call, 3}},
      {"EXUNIT", {ExUnit.CaptureServer, :log_capture_on, 3}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 2}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 2}},
      {"EXUNIT", {ExUnit, :configure, 1}},
      {"EXUNIT", {ExUnit, :start, 0}},
      {"EXUNIT", {ExUnit, :start, 1}},
      {"EXUNIT", {ExUnit, :run, 0}},
      {"EXUNIT", {ExUnit, :run, 1}},
      {"EXUNIT", {ExUnit, :async_run, 0}},
      {"EXUNIT", {ExUnit.Runner, :run, 2}},
      {"EXUNIT", {ExUnit, :plural_rule, 2}},
      {"EXUNIT", {ExUnit, :after_suite, 1}}
    ],
    "floor" => [
      {"LOGGER", {Logger.Formatter, :compile, 1}},
      {"LOGGER", {Logger.Formatter, :new, 1}},
      {"LOGGER", {Logger, :configure_backend, 2}},
      {"LOGGER", {Logger, :default_formatter, 0}},
      {"LOGGER", {Logger, :default_formatter, 1}},
      {"LOGGER", {Logger.Formatter, :new, 0}},
      {"LOGGER", {Logger.App, :start, 0}},
      {"LOGGER", {Logger.App, :start, 2}},
      {"EXUNIT", {ExUnit.CaptureServer, :handle_call, 3}},
      {"EXUNIT", {ExUnit.CaptureServer, :log_capture_on, 3}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :capture_log, 2}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 1}},
      {"EXUNIT", {ExUnit.CaptureLog, :with_log, 2}},
      {"EXUNIT", {ExUnit, :configure, 1}},
      {"EXUNIT", {ExUnit, :start, 0}},
      {"EXUNIT", {ExUnit, :start, 1}},
      {"EXUNIT", {ExUnit, :run, 0}},
      {"EXUNIT", {ExUnit, :run, 1}},
      {"EXUNIT", {ExUnit, :async_run, 0}},
      {"EXUNIT", {ExUnit.Runner, :run, 2}},
      {"EXUNIT", {ExUnit, :plural_rule, 2}},
      {"EXUNIT", {ExUnit, :after_suite, 1}}
    ]
  }

  @logger_family_modules [
    Logger,
    Logger.App,
    Logger.Formatter,
    ExUnit,
    ExUnit.CaptureServer,
    ExUnit.CaptureLog,
    ExUnit.Runner
  ]

  @logger_expected_mfas_by_lane Map.new(@logger_family_universe, fn {lane, rows} ->
                                  {lane, MapSet.new(Enum.map(rows, &elem(&1, 1)))}
                                end)

  @logger_expected_ids (for {lane, rows} <- @logger_family_universe,
                            {family, {module, function, arity}} <- rows do
                          {"NEW-#{family}-#{lane}-#{inspect(module)}-#{function}-#{arity}", lane}
                        end)

  @logger_family_specs [
    %{
      family: "LOGGER",
      mfa: {Logger.Formatter, :compile, 1},
      disposition: :tier,
      provenance: :caller_format_pattern,
      trace: [{Logger.Formatter, :compile, 1}, {String, :to_atom, 1}],
      verdict: :caller_format_pattern_reaches_atom_creation,
      evidence: [:formatter_compile],
      fixtures: [:generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger.Formatter, :new, 1},
      disposition: :tier,
      provenance: :caller_format_options,
      trace: [
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_format_text_reaches_atom_creation,
      evidence: [:formatter_input],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe, :discarded_quote_source_only],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger, :configure_backend, 2},
      disposition: :tier,
      provenance: :caller_options_and_logger_console_config,
      trace: [
        {Logger, :configure_backend, 2},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :console_options_reach_formatter_parser_other_backends_delegate,
      evidence: [:logger_configure_backend],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger, :default_formatter, 0},
      disposition: :tier,
      provenance: :logger_default_formatter_application_config,
      trace: [
        {Logger, :default_formatter, 0},
        {Application, :get_env, 3},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :application_formatter_config_reaches_atom_creation,
      evidence: [:logger_default_formatter],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger, :default_formatter, 1},
      disposition: :tier,
      provenance: :caller_overrides_and_logger_default_formatter_config,
      trace: [
        {Logger, :default_formatter, 1},
        {Application, :get_env, 3},
        {Keyword, :merge, 2},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_override_and_application_config_reach_atom_creation,
      evidence: [:logger_default_formatter],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger.Formatter, :new, 0},
      disposition: :exact_exclusion,
      provenance: :fixed_builtin_default_pattern,
      trace: [
        {Logger.Formatter, :new, 0},
        {Logger.Formatter, :compile, 1},
        {Logger.Formatter, :compile_code, 1}
      ],
      verdict: :fixed_default_pattern_has_no_caller_text,
      reason: :fixed_default,
      evidence: [:formatter_fixed_default],
      fixtures: [:fixed_default_source_trace, :individual_exact_removal_witness],
      removal_witness: :individual_exact_mfa
    },
    %{
      family: "LOGGER",
      mfa: {Logger.App, :start, 0},
      disposition: :tier,
      provenance: :logger_application_environment,
      trace: [
        {Logger.App, :start, 0},
        {Application, :start, 1},
        {Logger.App, :start, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :starting_logger_uses_configured_formatter_options,
      evidence: [:logger_app_start_zero, :logger_app_start],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "LOGGER",
      mfa: {Logger.App, :start, 2},
      disposition: :tier,
      provenance: :logger_application_environment,
      trace: [
        {Logger.App, :start, 2},
        {Application, :get_env, 3},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :application_start_reads_configured_formatter_options,
      evidence: [:logger_app_start],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureServer, :handle_call, 3},
      disposition: :tier,
      provenance: :caller_process_message_options,
      trace: [
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :log_capture_message_options_reach_atom_creation,
      evidence: [:capture_server_handler],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureServer, :log_capture_on, 3},
      disposition: :tier,
      provenance: :caller_options_forwarded_in_genserver_message,
      trace: [
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {:gen_server, :call, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :log_capture_options_cross_process_message_to_formatter,
      evidence: [:capture_server_wrapper, :capture_server_handler],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :capture_log, 1},
      disposition: :tier,
      provenance: :logger_environment_via_default_capture_options,
      trace: [
        {ExUnit.CaptureLog, :capture_log, 1},
        {ExUnit.CaptureLog, :with_log, 1},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :default_capture_reads_configured_formatter,
      evidence: [:capture_log_capture, :capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :capture_log, 2},
      disposition: :tier,
      provenance: :caller_capture_options,
      trace: [
        {ExUnit.CaptureLog, :capture_log, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_capture_options_reach_formatter_parser,
      evidence: [:capture_log_capture, :capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :with_log, 1},
      disposition: :tier,
      provenance: :logger_environment_via_default_capture_options,
      trace: [
        {ExUnit.CaptureLog, :with_log, 1},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :default_capture_reads_configured_formatter,
      evidence: [:capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.CaptureLog, :with_log, 2},
      disposition: :tier,
      provenance: :caller_capture_options,
      trace: [
        {ExUnit.CaptureLog, :with_log, 2},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_capture_options_reach_formatter_parser,
      evidence: [:capture_log_with],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :configure, 1},
      disposition: :tier,
      provenance: :caller_exunit_configuration,
      trace: [
        {ExUnit, :configure, 1},
        {Application, :put_env, 3},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :capture_log_configuration_reaches_formatter_parser,
      evidence: [:exunit_configure, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :start, 0},
      disposition: :tier,
      provenance: :exunit_default_start_and_application_configuration,
      trace: [
        {ExUnit, :start, 0},
        {ExUnit, :start, 1},
        {ExUnit, :configure, 1},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :default_start_uses_configured_capture_log_options,
      evidence: [:exunit_start, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :start, 1},
      disposition: :tier,
      provenance: :caller_exunit_configuration,
      trace: [
        {ExUnit, :start, 1},
        {ExUnit, :configure, 1},
        {Application, :put_env, 3},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :caller_start_options_reach_formatter_parser,
      evidence: [:exunit_start, :exunit_configure, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :run, 0},
      disposition: :tier,
      provenance: :exunit_application_configuration,
      trace: [
        {ExUnit, :run, 0},
        {ExUnit, :configuration, 0},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :run_reads_configured_capture_log_options,
      evidence: [:exunit_run, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :run, 1},
      disposition: :tier,
      provenance: :caller_module_list_and_exunit_application_configuration,
      trace: [
        {ExUnit, :run, 1},
        {ExUnit, :configuration, 0},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :run_reads_configured_capture_log_options,
      evidence: [:exunit_run, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :async_run, 0},
      disposition: :tier,
      provenance: :exunit_application_configuration,
      trace: [
        {ExUnit, :async_run, 0},
        {ExUnit, :configuration, 0},
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {Logger, :default_formatter, 0},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :async_run_reads_configured_capture_log_options,
      evidence: [:exunit_async_run, :exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit.Runner, :run, 2},
      disposition: :tier,
      provenance: :exunit_config_and_test_tag_options,
      trace: [
        {ExUnit.Runner, :run, 2},
        {ExUnit.CaptureLog, :with_log, 2},
        {ExUnit.CaptureServer, :log_capture_on, 3},
        {ExUnit.CaptureServer, :handle_call, 3},
        {Logger, :default_formatter, 1},
        {Logger.Formatter, :new, 1},
        {Logger.Formatter, :compile, 1},
        {String, :to_atom, 1}
      ],
      verdict: :capture_log_config_and_test_tags_reach_formatter_parser,
      evidence: [:exunit_runner],
      fixtures: [:direct, :capture, :apply, :generated_mfa_probe],
      removal_witness: :not_applicable_tiered
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :plural_rule, 2},
      disposition: :exact_exclusion,
      provenance: :pluralization_text_only,
      trace: [{ExUnit, :plural_rule, 2}, {ExUnit, :configure, 1}],
      verdict: :pluralization_config_does_not_set_capture_log,
      reason: :unrelated_exunit_config,
      evidence: [:exunit_plural_rule],
      fixtures: [:source_trace, :individual_exact_removal_witness],
      removal_witness: :individual_exact_mfa
    },
    %{
      family: "EXUNIT",
      mfa: {ExUnit, :after_suite, 1},
      disposition: :exact_exclusion,
      provenance: :suite_callback_registration,
      trace: [{ExUnit, :after_suite, 1}, {ExUnit, :configure, 1}],
      verdict: :after_suite_callback_config_does_not_set_capture_log,
      reason: :unrelated_exunit_config,
      evidence: [:exunit_after_suite],
      fixtures: [:source_trace, :individual_exact_removal_witness],
      removal_witness: :individual_exact_mfa
    }
  ]

  @logger_source_evidence %{
    "core" => %{
      formatter_compile: [
        {"logger/lib/logger/formatter.ex:434", "def compile(pattern_or_function)"},
        {"logger/lib/logger/formatter.ex:444", "String.to_atom(code)"}
      ],
      formatter_input: [
        {"logger/lib/logger/formatter.ex:170", "def new(options"},
        {"logger/lib/logger/formatter.ex:171", "template = compile(options[:format])"},
        {"logger/lib/logger/formatter.ex:444", "String.to_atom(code)"}
      ],
      formatter_fixed_default: [
        {"logger/lib/logger/formatter.ex:117", "@default_pattern"},
        {"logger/lib/logger/formatter.ex:170", "def new(options"},
        {"logger/lib/logger/formatter.ex:436", "def compile(nil), do: compile(@default_pattern)"}
      ],
      logger_configure_backend: [
        {"logger/lib/logger.ex:953", "def configure_backend(:console, options)"},
        {"logger/lib/logger.ex:954",
         "Keyword.merge(Application.get_env(:logger, :console, []), options)"},
        {"logger/lib/logger.ex:957", "Logger.Formatter.new(without_level)"},
        {"logger/lib/logger.ex:961", "def configure_backend(backend, options)"},
        {"logger/lib/logger.ex:962", "Logger.Backends.Internal.configure(backend, options)"}
      ],
      logger_default_formatter: [
        {"logger/lib/logger.ex:578", "def default_formatter(overrides"},
        {"logger/lib/logger.ex:579", "Application.get_env(:logger, :default_formatter, [])"},
        {"logger/lib/logger.ex:580", "Keyword.merge(overrides)"},
        {"logger/lib/logger.ex:581", "Logger.Formatter.new()"}
      ],
      logger_app_start: [
        {"logger/lib/logger/app.ex:11", "def start(_type, _args)"},
        {"logger/lib/logger/app.ex:42", "Application.get_env(:logger, :console)"},
        {"logger/lib/logger/app.ex:45", "Application.fetch_env(:logger, :default_formatter)"},
        {"logger/lib/logger/app.ex:149",
         "Keyword.put_new_lazy(:formatter, &Logger.default_formatter/0)"}
      ],
      logger_app_start_zero: [
        {"logger/lib/logger/app.ex:84", "def start do"},
        {"logger/lib/logger/app.ex:85", "Application.start(:logger)"}
      ],
      capture_server_handler: [
        {"ex_unit/lib/ex_unit/capture_server.ex:73",
         "def handle_call({:log_capture_on, pid, string_io, opts}"},
        {"ex_unit/lib/ex_unit/capture_server.ex:77", "Keyword.pop(opts, :level)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:80", "Logger.default_formatter(opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:82", ":ets.insert(@ets"}
      ],
      capture_server_wrapper: [
        {"ex_unit/lib/ex_unit/capture_server.ex:30", "def log_capture_on(pid, string_io, opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:31",
         "GenServer.call(@name, {:log_capture_on, pid, string_io, opts}"}
      ],
      capture_log_capture: [
        {"ex_unit/lib/ex_unit/capture_log.ex:88", "def capture_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:89", "with_log(opts, fun)"}
      ],
      capture_log_with: [
        {"ex_unit/lib/ex_unit/capture_log.ex:112", "def with_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:124",
         "ExUnit.CaptureServer.log_capture_on(self(), string_io, opts)"}
      ],
      exunit_configure: [
        {"ex_unit/lib/ex_unit.ex:420", "def configure(options)"},
        {"ex_unit/lib/ex_unit.ex:422", "Application.put_env(:ex_unit, k, v)"}
      ],
      exunit_start: [
        {"ex_unit/lib/ex_unit.ex:279", "def start(options"},
        {"ex_unit/lib/ex_unit.ex:282", "configure(options)"}
      ],
      exunit_run: [
        {"ex_unit/lib/ex_unit.ex:476", "def run(additional_modules"},
        {"ex_unit/lib/ex_unit.ex:487", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:575", "ExUnit.Runner.run(options, load_us)"}
      ],
      exunit_async_run: [
        {"ex_unit/lib/ex_unit.ex:499", "def async_run()"},
        {"ex_unit/lib/ex_unit.ex:501", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:503", "Task.async(fn ->"}
      ],
      exunit_runner: [
        {"ex_unit/lib/ex_unit/runner.ex:12", "def run(opts, load_us)"},
        {"ex_unit/lib/ex_unit/runner.ex:79", "capture_log: opts[:capture_log]"},
        {"ex_unit/lib/ex_unit/runner.ex:452", "Map.get(context, :capture_log, capture_log)"},
        {"ex_unit/lib/ex_unit/runner.ex:482", "ExUnit.CaptureLog.with_log(capture_log_opts, fun)"}
      ],
      exunit_plural_rule: [
        {"ex_unit/lib/ex_unit.ex:456", "def plural_rule(word, pluralization)"},
        {"ex_unit/lib/ex_unit.ex:458", "Application.get_env(:ex_unit, :plural_rules, %{})"},
        {"ex_unit/lib/ex_unit.ex:461", "configure(plural_rules: plural_rules)"}
      ],
      exunit_after_suite: [
        {"ex_unit/lib/ex_unit.ex:530", "def after_suite(function)"},
        {"ex_unit/lib/ex_unit.ex:531", "Application.fetch_env!(:ex_unit, :after_suite)"},
        {"ex_unit/lib/ex_unit.ex:532", "configure(after_suite: [function | current_callbacks])"}
      ]
    },
    "floor" => %{
      formatter_compile: [
        {"logger/lib/logger/formatter.ex:397", "def compile(pattern_or_function)"},
        {"logger/lib/logger/formatter.ex:407", "String.to_atom(code)"}
      ],
      formatter_input: [
        {"logger/lib/logger/formatter.ex:152", "def new(options"},
        {"logger/lib/logger/formatter.ex:153", "template = compile(options[:format])"},
        {"logger/lib/logger/formatter.ex:407", "String.to_atom(code)"}
      ],
      formatter_fixed_default: [
        {"logger/lib/logger/formatter.ex:99", "@default_pattern"},
        {"logger/lib/logger/formatter.ex:152", "def new(options"},
        {"logger/lib/logger/formatter.ex:399", "def compile(nil), do: compile(@default_pattern)"}
      ],
      logger_configure_backend: [
        {"logger/lib/logger.ex:880", "def configure_backend(:console, options)"},
        {"logger/lib/logger.ex:881",
         "Keyword.merge(Application.get_env(:logger, :console, []), options)"},
        {"logger/lib/logger.ex:884", "Logger.Formatter.new(without_level)"},
        {"logger/lib/logger.ex:888", "def configure_backend(backend, options)"},
        {"logger/lib/logger.ex:889", "Logger.Backends.Internal.configure(backend, options)"}
      ],
      logger_default_formatter: [
        {"logger/lib/logger.ex:524", "def default_formatter(overrides"},
        {"logger/lib/logger.ex:525", "Application.get_env(:logger, :default_formatter, [])"},
        {"logger/lib/logger.ex:526", "Keyword.merge(overrides)"},
        {"logger/lib/logger.ex:527", "Logger.Formatter.new()"}
      ],
      logger_app_start: [
        {"logger/lib/logger/app.ex:8", "def start(_type, _args)"},
        {"logger/lib/logger/app.ex:22", "Application.get_env(:logger, :console)"},
        {"logger/lib/logger/app.ex:25", "Application.fetch_env(:logger, :default_formatter)"},
        {"logger/lib/logger/app.ex:129",
         "Keyword.put_new_lazy(:formatter, &Logger.default_formatter/0)"}
      ],
      logger_app_start_zero: [
        {"logger/lib/logger/app.ex:64", "def start do"},
        {"logger/lib/logger/app.ex:65", "Application.start(:logger)"}
      ],
      capture_server_handler: [
        {"ex_unit/lib/ex_unit/capture_server.ex:69",
         "def handle_call({:log_capture_on, pid, string_io, opts}"},
        {"ex_unit/lib/ex_unit/capture_server.ex:73", "Keyword.pop(opts, :level)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:74", "Logger.default_formatter(opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:75", ":ets.insert(@ets"}
      ],
      capture_server_wrapper: [
        {"ex_unit/lib/ex_unit/capture_server.ex:26", "def log_capture_on(pid, string_io, opts)"},
        {"ex_unit/lib/ex_unit/capture_server.ex:27",
         "GenServer.call(@name, {:log_capture_on, pid, string_io, opts}"}
      ],
      capture_log_capture: [
        {"ex_unit/lib/ex_unit/capture_log.ex:74", "def capture_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:75", "with_log(opts, fun)"}
      ],
      capture_log_with: [
        {"ex_unit/lib/ex_unit/capture_log.ex:98", "def with_log(opts"},
        {"ex_unit/lib/ex_unit/capture_log.ex:110",
         "ExUnit.CaptureServer.log_capture_on(self(), string_io, opts)"}
      ],
      exunit_configure: [
        {"ex_unit/lib/ex_unit.ex:356", "def configure(options)"},
        {"ex_unit/lib/ex_unit.ex:358", "Application.put_env(:ex_unit, k, v)"}
      ],
      exunit_start: [
        {"ex_unit/lib/ex_unit.ex:217", "def start(options"},
        {"ex_unit/lib/ex_unit.ex:220", "configure(options)"}
      ],
      exunit_run: [
        {"ex_unit/lib/ex_unit.ex:412", "def run(additional_modules"},
        {"ex_unit/lib/ex_unit.ex:423", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:509", "ExUnit.Runner.run(options, load_us)"}
      ],
      exunit_async_run: [
        {"ex_unit/lib/ex_unit.ex:435", "def async_run()"},
        {"ex_unit/lib/ex_unit.ex:437", "options = persist_defaults(configuration())"},
        {"ex_unit/lib/ex_unit.ex:439", "Task.async(fn ->"}
      ],
      exunit_runner: [
        {"ex_unit/lib/ex_unit/runner.ex:8", "def run(opts, load_us)"},
        {"ex_unit/lib/ex_unit/runner.ex:75", "capture_log: opts[:capture_log]"},
        {"ex_unit/lib/ex_unit/runner.ex:430", "Map.get(context, :capture_log, capture_log)"},
        {"ex_unit/lib/ex_unit/runner.ex:460", "ExUnit.CaptureLog.with_log(capture_log_opts, fun)"}
      ],
      exunit_plural_rule: [
        {"ex_unit/lib/ex_unit.ex:392", "def plural_rule(word, pluralization)"},
        {"ex_unit/lib/ex_unit.ex:394", "Application.get_env(:ex_unit, :plural_rules, %{})"},
        {"ex_unit/lib/ex_unit.ex:397", "configure(plural_rules: plural_rules)"}
      ],
      exunit_after_suite: [
        {"ex_unit/lib/ex_unit.ex:466", "def after_suite(function)"},
        {"ex_unit/lib/ex_unit.ex:467", "Application.fetch_env!(:ex_unit, :after_suite)"},
        {"ex_unit/lib/ex_unit.ex:468", "configure(after_suite: [function | current_callbacks])"}
      ]
    }
  }

  @logger_audit (for lane <- @creator_expected_lanes, spec <- @logger_family_specs do
                   {module, function, arity} = mfa = spec.mfa

                   source =
                     Enum.flat_map(spec.evidence, &Map.fetch!(@logger_source_evidence[lane], &1))

                   %{
                     original_id:
                       "NEW-#{spec.family}-#{lane}-#{inspect(module)}-#{function}-#{arity}",
                     original_matcher: {:mfa, mfa},
                     original_reason: spec.disposition,
                     lane: lane,
                     matched_mfas: [mfa],
                     trace: spec.trace,
                     provenance: spec.provenance,
                     verdict: spec.verdict,
                     replacements:
                       if(spec.disposition == :tier,
                         do: %{mfa => {:tier, mfa}},
                         else: %{mfa => {:exact_exclusion, spec.reason}}
                       ),
                     tier: if(spec.disposition == :tier, do: [mfa], else: []),
                     fixtures: spec.fixtures,
                     citations: source,
                     evidence_groups: spec.evidence,
                     applicability: :each_exact_installed_lane,
                     removal_witness: spec.removal_witness
                   }
                 end)

  @leex_expected_mfas [{:leex, :file, 1}, {:leex, :file, 2}]
  @asn1_table_mfas [
    {:asn1ct_table, :new, 1},
    {:asn1ct_table, :new_reuse, 1},
    {:asn1ct_table, :exists, 1},
    {:asn1ct_table, :size, 1},
    {:asn1ct_table, :insert, 2},
    {:asn1ct_table, :lookup, 2},
    {:asn1ct_table, :match, 2},
    {:asn1ct_table, :to_list, 1},
    {:asn1ct_table, :delete, 1}
  ]
  @asn1_check_mfa {:asn1ct_check, :check, 2}
  @asn1_insert_once_mfa {:asn1ct_gen, :insert_once, 2}
  @asn1_external_transform_mfas [
    {:asn1ct_eval_ext, :transform_to_EXTERNAL1994, 1},
    {:asn1ct_eval_ext, :transform_to_EXTERNAL1994_maps, 1}
  ]
  @asn1_expected_selected_mfas @asn1_table_mfas ++
                                 [@asn1_check_mfa, @asn1_insert_once_mfa] ++
                                 @asn1_external_transform_mfas
  @parser_tokenizer_mfas [
    {:asn1ct_parser2, :parse, 2},
    {:asn1ct_parser2, :format_error, 1},
    {:asn1ct_tok, :file, 1},
    {:asn1ct_tok, :format_error, 1}
  ]
  @parser_tokenizer_exclusions_by_lane %{
    "core" => [
      {{:asn1ct_parser2, [:format_error]}, :pure_data, ["asn1/src/asn1ct_parser2.erl:75"]},
      {{:asn1ct_tok, [:format_error]}, :pure_data, ["asn1/src/asn1ct_tok.erl:69"]}
    ],
    "floor" => [
      {{:asn1ct_parser2, [:format_error]}, :pure_data, ["asn1/src/asn1ct_parser2.erl:71"]},
      {{:asn1ct_tok, [:format_error]}, :pure_data, ["asn1/src/asn1ct_tok.erl:65"]}
    ]
  }
  @asn1_expected_direct_edges [
    {{:asn1ct, :check_tagdefault, 1}, {:asn1ct_table, :new, 1}},
    {{:asn1ct, :compile_pass, 1}, {:asn1ct_table, :delete, 1}},
    {{:asn1ct, :discover_dupl_in_mods, 5}, {:asn1ct_table, :insert, 2}},
    {{:asn1ct, :generate, 4}, {:asn1ct_table, :delete, 1}},
    {{:asn1ct, :generate, 4}, {:asn1ct_table, :new, 1}},
    {{:asn1ct, :merge_modules, 2}, {:asn1ct_table, :delete, 1}},
    {{:asn1ct, :merge_modules, 2}, {:asn1ct_table, :size, 1}},
    {{:asn1ct, :read_config_data, 1}, {:asn1ct_table, :exists, 1}},
    {{:asn1ct, :read_config_data, 1}, {:asn1ct_table, :lookup, 2}},
    {{:asn1ct, :remove_name_collisions, 1}, {:asn1ct_table, :new, 1}},
    {{:asn1ct, :remove_name_collisions2, 4}, {:asn1ct_table, :insert, 2}},
    {{:asn1ct, :save_automatic_tagged_types, 1}, {:asn1ct_table, :insert, 2}},
    {{:asn1ct, :save_config, 2}, {:asn1ct_table, :insert, 2}},
    {{:asn1ct, :save_config, 2}, {:asn1ct_table, :new_reuse, 1}},
    {{:asn1ct, :save_imports, 1}, {:asn1ct_table, :insert, 2}},
    {{:asn1ct, :save_imports, 1}, {:asn1ct_table, :new, 1}},
    {{:asn1ct_check, :check, 2}, {:asn1ct_table, :delete, 1}},
    {{:asn1ct_check, :check, 2}, {:asn1ct_table, :new, 1}},
    {{:asn1ct_check, :check, 2}, {:asn1ct_table, :to_list, 1}},
    {{:asn1ct_check, :is_automatic_tagged_in_multi_file, 1}, {:asn1ct_table, :exists, 1}},
    {{:asn1ct_check, :is_automatic_tagged_in_multi_file, 1}, {:asn1ct_table, :lookup, 2}},
    {{:asn1ct_check, :renamed_reference, 3}, {:asn1ct_table, :exists, 1}},
    {{:asn1ct_check, :renamed_reference, 3}, {:asn1ct_table, :match, 2}},
    {{:asn1ct_gen, :insert_once, 2}, {:asn1ct_table, :insert, 2}},
    {{:asn1ct_gen, :insert_once, 2}, {:asn1ct_table, :lookup, 2}},
    {{:asn1ct_table, :delete, 1}, {:asn1ct_table, :delete, 1}},
    {{:asn1ct_table, :new_reuse, 1}, {:asn1ct_table, :exists, 1}},
    {{:asn1ct_table, :new_reuse, 1}, {:asn1ct_table, :new, 1}}
  ]
  @asn1_edge_citations_by_lane %{
    "core" =>
      Enum.map(
        [482, 611, 612, 635, 667, 692, 858, 859, 936, 963, 1088, 1103, 1825, 1826, 1830, 1833],
        &{"asn1/src/asn1ct.erl:#{&1}", "asn1ct_table:"}
      ) ++
        Enum.map(
          [93, 94, 143, 145, 146, 153, 4000, 4003, 4005, 4009, 4780, 4785],
          &{"asn1/src/asn1ct_check.erl:#{&1}", "asn1ct_table:"}
        ) ++
        Enum.map([1380, 1382], &{"asn1/src/asn1ct_gen.erl:#{&1}", "asn1ct_table:"}) ++
        [
          {"asn1/src/asn1ct_table.erl:47", "exists(Table)"},
          {"asn1/src/asn1ct_table.erl:47", "new(Table)"},
          {"asn1/src/asn1ct_table.erl:66", "delete(T)"}
        ],
    "floor" =>
      Enum.map(
        [477, 606, 607, 630, 662, 687, 853, 854, 931, 958, 1083, 1098, 1820, 1821, 1825, 1828],
        &{"asn1/src/asn1ct.erl:#{&1}", "asn1ct_table:"}
      ) ++
        Enum.map(
          [89, 90, 139, 141, 142, 149, 3995, 3998, 4000, 4004, 4775, 4780],
          &{"asn1/src/asn1ct_check.erl:#{&1}", "asn1ct_table:"}
        ) ++
        Enum.map([1367, 1369], &{"asn1/src/asn1ct_gen.erl:#{&1}", "asn1ct_table:"}) ++
        [
          {"asn1/src/asn1ct_table.erl:45", "exists(Table)"},
          {"asn1/src/asn1ct_table.erl:45", "new(Table)"},
          {"asn1/src/asn1ct_table.erl:64", "delete(T)"}
        ]
  }
  @asn1_table_definition_citations_by_lane %{
    "core" => %{
      new: [
        {"asn1/src/asn1ct_table.erl:40", "new(Table) ->"},
        {"asn1/src/asn1ct_table.erl:42", "TableId = ets:new(Table, [])"}
      ],
      new_reuse: [
        {"asn1/src/asn1ct_table.erl:46", "new_reuse(Table) ->"},
        {"asn1/src/asn1ct_table.erl:47", "not exists(Table) andalso new(Table)"}
      ],
      exists: [{"asn1/src/asn1ct_table.erl:49", "exists(Table) -> get(Table) =/= undefined."}],
      size: [{"asn1/src/asn1ct_table.erl:51", "size(Table) -> ets:info(get(Table), size)."}],
      insert: [
        {"asn1/src/asn1ct_table.erl:53", "insert(Table, Tuple) -> ets:insert(get(Table), Tuple)."}
      ],
      lookup: [
        {"asn1/src/asn1ct_table.erl:55", "lookup(Table, Key) -> ets:lookup(get(Table), Key)."}
      ],
      match: [
        {"asn1/src/asn1ct_table.erl:57",
         "match(Table, MatchSpec) -> ets:match(get(Table), MatchSpec)."}
      ],
      to_list: [{"asn1/src/asn1ct_table.erl:59", "to_list(Table) -> ets:tab2list(get(Table))."}],
      delete: [
        {"asn1/src/asn1ct_table.erl:65", "delete(Tables) when is_list(Tables) ->"},
        {"asn1/src/asn1ct_table.erl:68", "delete(Table) when is_atom(Table) ->"}
      ]
    },
    "floor" => %{
      new: [
        {"asn1/src/asn1ct_table.erl:38", "new(Table) ->"},
        {"asn1/src/asn1ct_table.erl:40", "TableId = ets:new(Table, [])"}
      ],
      new_reuse: [
        {"asn1/src/asn1ct_table.erl:44", "new_reuse(Table) ->"},
        {"asn1/src/asn1ct_table.erl:45", "not exists(Table) andalso new(Table)"}
      ],
      exists: [{"asn1/src/asn1ct_table.erl:47", "exists(Table) -> get(Table) =/= undefined."}],
      size: [{"asn1/src/asn1ct_table.erl:49", "size(Table) -> ets:info(get(Table), size)."}],
      insert: [
        {"asn1/src/asn1ct_table.erl:51", "insert(Table, Tuple) -> ets:insert(get(Table), Tuple)."}
      ],
      lookup: [
        {"asn1/src/asn1ct_table.erl:53", "lookup(Table, Key) -> ets:lookup(get(Table), Key)."}
      ],
      match: [
        {"asn1/src/asn1ct_table.erl:55",
         "match(Table, MatchSpec) -> ets:match(get(Table), MatchSpec)."}
      ],
      to_list: [{"asn1/src/asn1ct_table.erl:57", "to_list(Table) -> ets:tab2list(get(Table))."}],
      delete: [
        {"asn1/src/asn1ct_table.erl:63", "delete(Tables) when is_list(Tables) ->"},
        {"asn1/src/asn1ct_table.erl:66", "delete(Table) when is_atom(Table) ->"}
      ]
    }
  }
  @asn1_gen_insert_citations_by_lane %{
    "core" => [
      {"asn1/src/asn1ct_gen.erl:1379", "insert_once(Table,Object) ->"},
      {"asn1/src/asn1ct_gen.erl:1380", "asn1ct_table:lookup(Table, element(1, Object))"},
      {"asn1/src/asn1ct_gen.erl:1382", "asn1ct_table:insert(Table, Object)"}
    ],
    "floor" => [
      {"asn1/src/asn1ct_gen.erl:1366", "insert_once(Table,Object) ->"},
      {"asn1/src/asn1ct_gen.erl:1367", "asn1ct_table:lookup(Table, element(1, Object))"},
      {"asn1/src/asn1ct_gen.erl:1369", "asn1ct_table:insert(Table, Object)"}
    ]
  }
  @asn1_check_trace_citations_by_lane %{
    "core" => [
      {"asn1/src/asn1ct_check.erl:73",
       "check(S,{Types,Values,ParameterizedTypes,Classes,Objects,ObjectSets}) ->"},
      {"asn1/src/asn1ct_check.erl:93", "asn1ct_table:new(parameterized_objects)"},
      {"asn1/src/asn1ct_check.erl:94", "asn1ct_table:new(inlined_objects)"},
      {"asn1/src/asn1ct_check.erl:139", "{Oerror,ExclO,ExclOS} = checko(S,NewObjects ++"},
      {"asn1/src/asn1ct_check.erl:443", "O = check_object(NewS, Object, TS),"},
      {"asn1/src/asn1ct_check.erl:1365", "try match_syntax_type(S, Field, A) of"},
      {"asn1/src/asn1ct_check.erl:1429",
       "InlinedObjName = list_to_atom(lists:concat([S#state.tname,"},
      {"asn1/src/asn1ct_check.erl:1435", "insert_once(S, inlined_objects, ObjKey)"},
      {"asn1/src/asn1ct_check.erl:1458", "Name = list_to_atom(asn1ct_gen:list2name(NameList))"},
      {"asn1/src/asn1ct_check.erl:1461",
       "insert_once(S, parameterized_objects, {Name,type,NewTDef})"},
      {"asn1/src/asn1ct_check.erl:1488",
       "insert_once(S0, parameterized_objects, {ERefName,type,TDef})"},
      {"asn1/src/asn1ct_check.erl:2607", "asn1ct_gen:insert_once(parameterized_objects,"},
      {"asn1/src/asn1ct_check.erl:6093", "insert_once(S,Tab,Key) ->"},
      {"asn1/src/asn1ct_check.erl:6096", "asn1ct_gen:insert_once(Tab,Key),"}
    ],
    "floor" => [
      {"asn1/src/asn1ct_check.erl:69",
       "check(S,{Types,Values,ParameterizedTypes,Classes,Objects,ObjectSets}) ->"},
      {"asn1/src/asn1ct_check.erl:89", "asn1ct_table:new(parameterized_objects)"},
      {"asn1/src/asn1ct_check.erl:90", "asn1ct_table:new(inlined_objects)"},
      {"asn1/src/asn1ct_check.erl:135", "{Oerror,ExclO,ExclOS} = checko(S,NewObjects ++"},
      {"asn1/src/asn1ct_check.erl:439", "O = check_object(NewS, Object, TS),"},
      {"asn1/src/asn1ct_check.erl:1361", "try match_syntax_type(S, Field, A) of"},
      {"asn1/src/asn1ct_check.erl:1425",
       "InlinedObjName = list_to_atom(lists:concat([S#state.tname,"},
      {"asn1/src/asn1ct_check.erl:1431", "insert_once(S, inlined_objects, ObjKey)"},
      {"asn1/src/asn1ct_check.erl:1454", "Name = list_to_atom(asn1ct_gen:list2name(NameList))"},
      {"asn1/src/asn1ct_check.erl:1457",
       "insert_once(S, parameterized_objects, {Name,type,NewTDef})"},
      {"asn1/src/asn1ct_check.erl:1484",
       "insert_once(S0, parameterized_objects, {ERefName,type,TDef})"},
      {"asn1/src/asn1ct_check.erl:2602", "asn1ct_gen:insert_once(parameterized_objects,"},
      {"asn1/src/asn1ct_check.erl:6088", "insert_once(S,Tab,Key) ->"},
      {"asn1/src/asn1ct_check.erl:6091", "asn1ct_gen:insert_once(Tab,Key),"}
    ]
  }
  @leex_expected_replacements Map.new(@leex_expected_mfas, &{&1, {:tier, &1}})
  @leex_expected_trace [
    {Mix.Tasks.Compile.Leex, :run, 1},
    {Mix.Compilers.Erlang, :compile, 6},
    {:leex, :file, 2},
    {:leex, :file, 1},
    {:leex, :file, 2},
    {:leex, :parse_file, 1},
    {:leex, :parse_rules, 7},
    {:leex, :collect_rule, 3},
    {:leex, :collect_action, 4},
    {:leex, :parse_rule, 6},
    {:leex, :out_file, 5},
    {:leex, :out_actions, 4},
    {:leex, :filenames, 3},
    {:erlang, :list_to_atom, 1},
    {:leex, :prep_out_actions, 1},
    {:erlang, :list_to_atom, 1}
  ]
  @leex_expected_verdict %{
    caller_path: :xrl_input_path_reaches_leex_file_2,
    file_one: :delegates_to_file_two,
    filename: :basename_reaches_module_list_to_atom,
    action: :parsed_xrl_rule_feeds_generated_yyaction_atom,
    action_name: :generated_rule_ordinal_not_caller_supplied_name,
    previous_reason: :compiler_pass_unsupported_for_atom_creation
  }
  @leex_expected_fixtures [:leex_file_one, :leex_file_two]
  @leex_expected_removal_witness ["leex:file/1", "leex:file/2"]
  @leex_expected_ids for lane <- @creator_expected_lanes, do: {"EX-165", lane}
  @leex_source_sha256_by_lane %{
    "core" => %{
      "mix/lib/mix/tasks/compile.leex.ex" =>
        "b33cdcb8077d1d31847ffc2673551e1fa5d6d0849bebd8db475260a85cb16d86",
      "mix/lib/mix/compilers/erlang.ex" =>
        "2da279b591b437ce695ba51214eb10bd962e6ce99b493b52355e21720de9b70d",
      "parsetools/src/leex.erl" =>
        "13d5ae6d297f284fb1db18e00d93e856e3fa231cfdffb884cdc9cc78df81bf93"
    },
    "floor" => %{
      "mix/lib/mix/tasks/compile.leex.ex" =>
        "4539da56203ba4f5c8150efad93cf05f7279b7b3a7054c6235e4dee503efb550",
      "mix/lib/mix/compilers/erlang.ex" =>
        "8ffe2208057e76db7c67ba97cbb8f99f03a9418cadf2d66e190e6b760cbf1568",
      "parsetools/src/leex.erl" =>
        "d1a0a20abc09ae3e65fcf0ec043913b2ae551ecfa2f0134fbb43e05b075bca6f"
    }
  }
  @leex_source_assertions_by_lane %{
    "core" => [
      {"mix/lib/mix/tasks/compile.leex.ex:65",
       "Erlang.compile(manifest(), mappings, :xrl, :erl, opts, fn input, output ->"},
      {"mix/lib/mix/tasks/compile.leex.ex:67", ":leex.file(Erlang.to_erl_file(input), options)"},
      {"mix/lib/mix/compilers/erlang.ex:90",
       "target <- extract_entries(src, src_ext, dest, dest_ext, force)"},
      {"mix/lib/mix/compilers/erlang.ex:246",
       "Mix.Utils.extract_files(List.wrap(src_dir), List.wrap(src_ext))"},
      {"mix/lib/mix/compilers/erlang.ex:97",
       "compile_entries(manifest, entries, src_ext, dest_ext, opts, callback)"},
      {"mix/lib/mix/compilers/erlang.ex:283", "case callback.(input, output) do"},
      {"parsetools/src/leex.erl:473", "file(File) -> file(File, [])."},
      {"parsetools/src/leex.erl:565", "file(File, Opts0) when is_list(Opts0) ->"},
      {"parsetools/src/leex.erl:580", "St1 = filenames(File, Opts, St0)"},
      {"parsetools/src/leex.erl:582", "{ok,REAs,Actions,Code,St2} = parse_file(St1)"},
      {"parsetools/src/leex.erl:586", "St3 = out_file(St2, DFA, DF, Actions, Code),"},
      {"parsetools/src/leex.erl:927", "{ok,Line3,REAs,Actions,St4} ="},
      {"parsetools/src/leex.erl:928", "parse_rules(Xfile, Line2, Macs, St3),"},
      {"parsetools/src/leex.erl:931", "{ok,REAs,Actions,Code,St5}"},
      {"parsetools/src/leex.erl:989", "{ok,REA,A,St1} = parse_rule(Re, L0, Atoks, Ms, N, St),"},
      {"parsetools/src/leex.erl:991", "[REA|REAs], [A|As], N+1, St1);"},
      {"parsetools/src/leex.erl:1014", "{ok,[{':',_}|Toks],L1} -> {ok,RegExp,Toks,L1};"},
      {"parsetools/src/leex.erl:1052",
       "{ok,{R,N},{N,Atoks,TokenChars,TokenLen,TokenLine,TokenCol,TokenLoc},St};"},
      {"parsetools/src/leex.erl:867", "Base = filename:basename(File, \".xrl\")"},
      {"parsetools/src/leex.erl:871", "Module = list_to_atom(Base)"},
      {"parsetools/src/leex.erl:1876",
       "\"##act\" -> out_actions(Ofile, St#leex.xfile, Deterministic, Actions);"},
      {"parsetools/src/leex.erl:2128", "As1 = prep_out_actions(As)"},
      {"parsetools/src/leex.erl:2136",
       "({A,Code,TokenChars,TokenLen,TokenLine,TokenCol,TokenLoc}) ->"},
      {"parsetools/src/leex.erl:2144", "Name = list_to_atom(lists:concat([yyaction_,A]))"}
    ],
    "floor" => [
      {"mix/lib/mix/tasks/compile.leex.ex:60",
       "Erlang.compile(manifest(), mappings, :xrl, :erl, opts, fn input, output ->"},
      {"mix/lib/mix/tasks/compile.leex.ex:62", ":leex.file(Erlang.to_erl_file(input), options)"},
      {"mix/lib/mix/compilers/erlang.ex:63",
       "target <- extract_entries(src, src_ext, dest, dest_ext, force)"},
      {"mix/lib/mix/compilers/erlang.ex:219",
       "Mix.Utils.extract_files(List.wrap(src_dir), List.wrap(src_ext))"},
      {"mix/lib/mix/compilers/erlang.ex:70",
       "compile_entries(manifest, entries, src_ext, dest_ext, opts, callback)"},
      {"mix/lib/mix/compilers/erlang.ex:256", "case callback.(input, output) do"},
      {"parsetools/src/leex.erl:467", "file(File) -> file(File, [])."},
      {"parsetools/src/leex.erl:559", "file(File, Opts0) when is_list(Opts0) ->"},
      {"parsetools/src/leex.erl:574", "St1 = filenames(File, Opts, St0)"},
      {"parsetools/src/leex.erl:576", "{ok,REAs,Actions,Code,St2} = parse_file(St1)"},
      {"parsetools/src/leex.erl:580", "St3 = out_file(St2, DFA, DF, Actions, Code),"},
      {"parsetools/src/leex.erl:921", "{ok,Line3,REAs,Actions,St4} ="},
      {"parsetools/src/leex.erl:922", "parse_rules(Xfile, Line2, Macs, St3),"},
      {"parsetools/src/leex.erl:925", "{ok,REAs,Actions,Code,St5}"},
      {"parsetools/src/leex.erl:983", "{ok,REA,A,St1} = parse_rule(Re, L0, Atoks, Ms, N, St),"},
      {"parsetools/src/leex.erl:985", "[REA|REAs], [A|As], N+1, St1);"},
      {"parsetools/src/leex.erl:1008", "{ok,[{':',_}|Toks],L1} -> {ok,RegExp,Toks,L1};"},
      {"parsetools/src/leex.erl:1046",
       "{ok,{R,N},{N,Atoks,TokenChars,TokenLen,TokenLine,TokenCol,TokenLoc},St};"},
      {"parsetools/src/leex.erl:861", "Base = filename:basename(File, \".xrl\")"},
      {"parsetools/src/leex.erl:865", "Module = list_to_atom(Base)"},
      {"parsetools/src/leex.erl:1870",
       "\"##act\" -> out_actions(Ofile, St#leex.xfile, Deterministic, Actions);"},
      {"parsetools/src/leex.erl:2127", "prep_out_actions(As) ->"},
      {"parsetools/src/leex.erl:2130",
       "({A,Code,TokenChars,TokenLen,TokenLine,TokenCol,TokenLoc}) ->"},
      {"parsetools/src/leex.erl:2138", "Name = list_to_atom(lists:concat([yyaction_,A]))"}
    ]
  }
  @leex_audit Enum.map(@creator_expected_lanes, fn lane ->
                %{
                  original_id: "EX-165",
                  original_matcher: {:leex, [:file]},
                  original_reason: :compiler_pass,
                  lane: lane,
                  matched_mfas: @leex_expected_mfas,
                  trace: @leex_expected_trace,
                  verdict: @leex_expected_verdict,
                  replacement_disposition: :exact_mfa_tier,
                  replacements: @leex_expected_replacements,
                  tier: @leex_expected_mfas,
                  fixtures: @leex_expected_fixtures,
                  citations: Map.fetch!(@leex_source_assertions_by_lane, lane),
                  applicability: :each_exact_installed_lane,
                  removal_witness: @leex_expected_removal_witness
                }
              end)

  @creator_audit @consult_creator_audit ++ @yecc_audit ++ @logger_audit ++ @leex_audit

  @eval_funs [:eval_str, :expr, :expr_list, :exprs, :match_clause]
  @barrier_modules [:code_server, :error_handler, :erl_prim_loader, :init, :erl_lint]
  @barrier_functions [
    {:code, :ensure_loaded},
    {:code, :load_file},
    {:code, :ensure_modules_loaded}
  ]
  @citation_re ~r/^[a-z_]+\/[^\s:]+\.(ex|erl|hrl):\d+$/
  @base_sinks [
                {:erlang, :load_module},
                {:erlang, :prepare_loading},
                {:erlang, :load_nif},
                {:erl_ddll, :try_load}
              ] ++ for(fun <- @eval_funs, do: {:erl_eval, fun})
  @boundary_lane_specific [
    {:ordsets, :floor},
    {:sets, :floor},
    {:erl_features, :floor},
    {:records, :floor}
  ]
  @boundary_exclusions [
    {{:code,
      [
        :all_available,
        :all_loaded,
        :clash,
        :clear_cache,
        :delete,
        :get_mode,
        :get_path,
        :is_loaded,
        :is_sticky,
        :modified_modules,
        :module_status,
        :purge,
        :soft_purge,
        :start_link,
        :stick_dir,
        :stick_mod,
        :stop,
        :unstick_dir,
        :unstick_mod
      ]}, :runtime_internal,
     [
       "kernel/src/code.erl:797",
       "kernel/src/code.erl:811",
       "kernel/src/code.erl:1296",
       "kernel/src/code.erl:1669",
       "kernel/src/code.erl:1984",
       "kernel/src/code.erl:2055",
       "kernel/src/code.erl:2153",
       "kernel/src/code.erl:767",
       "kernel/src/code.erl:781",
       "kernel/src/code.erl:1266",
       "kernel/src/code.erl:1639",
       "kernel/src/code.erl:1947",
       "kernel/src/code.erl:2018",
       "kernel/src/code.erl:2116"
     ]},
    {{:code,
      [
        :compiler_dir,
        :get_doc,
        :get_object_code,
        :lib_dir,
        :priv_dir,
        :root_dir,
        :where_is_file,
        :which
      ]}, :pure_data,
     [
       "kernel/src/code.erl:778",
       "kernel/src/code.erl:885",
       "kernel/src/code.erl:927",
       "kernel/src/code.erl:959",
       "kernel/src/code.erl:967",
       "kernel/src/code.erl:1839",
       "kernel/src/code.erl:1782",
       "kernel/src/code.erl:748",
       "kernel/src/code.erl:855",
       "kernel/src/code.erl:897",
       "kernel/src/code.erl:950",
       "kernel/src/code.erl:937",
       "kernel/src/code.erl:1809",
       "kernel/src/code.erl:1752"
     ]},
    {{:code, [:ensure_loaded, :ensure_modules_loaded, :load_file]}, :by_name,
     [
       "kernel/src/code.erl:559",
       "kernel/src/code.erl:581",
       "kernel/src/code.erl:1319",
       "kernel/src/code.erl:533",
       "kernel/src/code.erl:554",
       "kernel/src/code.erl:1289"
     ]},
    {{:erlang,
      [
        :decode_packet,
        :get_module_info,
        :loaded,
        :module_loaded,
        :pre_loaded
      ]}, :pure_data,
     [
       "erts/src/erlang.erl:1983",
       "erts/src/erlang.erl:3271",
       "erts/src/erlang.erl:4286",
       "erts/src/erlang.erl:4497",
       "erts/src/erlang.erl:5474",
       "erts/src/erlang.erl:1882",
       "erts/src/erlang.erl:3065",
       "erts/src/erlang.erl:4000",
       "erts/src/erlang.erl:4188",
       "erts/src/erlang.erl:5094"
     ]},
    {{:erlang,
      [
        :check_old_code,
        :check_process_code,
        :delete_module,
        :has_prepared_code_on_load,
        :nif_error,
        :purge_module
      ]}, :runtime_internal,
     [
       "erts/src/erlang.erl:1591",
       "erts/src/erlang.erl:1601",
       "erts/src/erlang.erl:2021",
       "erts/src/erlang.erl:3508",
       "erts/src/erlang.erl:4884",
       "erts/src/erlang.erl:5689",
       "erts/src/erlang.erl:1511",
       "erts/src/erlang.erl:1521",
       "erts/src/erlang.erl:1921",
       "erts/src/erlang.erl:3302",
       "erts/src/erlang.erl:4554",
       "erts/src/erlang.erl:5243"
     ]},
    {{:kernel, [:init]}, :callback, ["kernel/src/kernel.erl:91", "kernel/src/kernel.erl:89"]},
    {{:error_handler, [:undefined_function, :undefined_lambda]}, :by_name,
     [
       "kernel/src/error_handler.erl:85",
       "kernel/src/error_handler.erl:117",
       "kernel/src/error_handler.erl:83",
       "kernel/src/error_handler.erl:115"
     ]},
    {{:error_handler, [:raise_undef_exception, :stub_function]}, :runtime_internal,
     [
       "kernel/src/error_handler.erl:146",
       "kernel/src/error_handler.erl:203",
       "kernel/src/error_handler.erl:144",
       "kernel/src/error_handler.erl:201"
     ]},
    {{:erts_internal,
      [
        :beamfile_chunk,
        :beamfile_module_md5,
        :binary_to_integer,
        :cmp_term,
        :list_to_integer,
        :map_hashmap_children,
        :map_next,
        :map_to_tuple_keys,
        :mc_iterator,
        :mc_refill,
        :term_to_string,
        :term_type,
        :time_unit,
        :perf_counter_unit
      ]}, :pure_data,
     [
       "erts/src/erts_internal.erl:1097",
       "erts/src/erts_internal.erl:1101",
       "erts/src/erts_internal.erl:1114",
       "erts/src/erts_internal.erl:414",
       "erts/src/erts_internal.erl:1123",
       "erts/src/erts_internal.erl:445",
       "erts/src/erts_internal.erl:457",
       "erts/src/erts_internal.erl:422",
       "erts/src/erts_internal.erl:467",
       "erts/src/erts_internal.erl:512",
       "erts/src/erts_internal.erl:1152",
       "erts/src/erts_internal.erl:436",
       "erts/src/erts_internal.erl:550",
       "erts/src/erts_internal.erl:555",
       "erts/src/erts_internal.erl:1083",
       "erts/src/erts_internal.erl:1087",
       "erts/src/erts_internal.erl:1105",
       "erts/src/erts_internal.erl:1109",
       "erts/src/erts_internal.erl:1130",
       "erts/src/erts_internal.erl:410",
       "erts/src/erts_internal.erl:1110",
       "erts/src/erts_internal.erl:1100",
       "erts/src/erts_internal.erl:1119",
       "erts/src/erts_internal.erl:417",
       "erts/src/erts_internal.erl:1127",
       "erts/src/erts_internal.erl:427",
       "erts/src/erts_internal.erl:449",
       "erts/src/erts_internal.erl:461",
       "erts/src/erts_internal.erl:475",
       "erts/src/erts_internal.erl:520",
       "erts/src/erts_internal.erl:1140",
       "erts/src/erts_internal.erl:1159",
       "erts/src/erts_internal.erl:1150",
       "erts/src/erts_internal.erl:555",
       "erts/src/erts_internal.erl:545"
     ]},
    {{:erts_internal,
      [
        :"@flush_monitor_messages_refopt",
        :abort_pending_connection,
        :atomics_new,
        :await_microstate_accounting_modifications,
        :await_port_send_result,
        :await_result,
        :await_sched_wall_time_modifications,
        :breakpoint,
        :check_dirty_process_code,
        :check_process_code,
        :counters_add,
        :counters_get,
        :counters_info,
        :counters_new,
        :counters_put,
        :crasher,
        :create_dist_channel,
        :dirty_process_handle_signals,
        :dist_ctrl_put_data,
        :dist_spawn_init,
        :dist_spawn_request,
        :dynamic_node_name,
        :erase_persistent_terms,
        :ets_info_binary,
        :ets_lookup_binary_info,
        :ets_raw_first,
        :ets_raw_next,
        :ets_super_user,
        :flush_monitor_messages,
        :garbage_collect,
        :gather_alloc_histograms,
        :gather_carrier_info,
        :gather_io_bytes,
        :gather_microstate_accounting_result,
        :gather_sched_wall_time_result,
        :gather_system_check_result,
        :get_creation,
        :get_dflags,
        :get_internal_state_blocked,
        :group_leader,
        :is_process_alive,
        :is_process_executing_dirty,
        :is_system_process,
        :new_connection,
        :no_aux_work_threads,
        :notify_breakpoint_hit,
        :open_port,
        :port_call,
        :port_close,
        :port_command,
        :port_connect,
        :port_control,
        :port_info,
        :process_display,
        :process_flag,
        :processes_next,
        :purge_module,
        :request_system_task,
        :scheduler_wall_time,
        :set_code_and_literal_cleaner_prio,
        :spawn_init,
        :spawn_request,
        :spawn_system_process,
        :suspend_process,
        :system_check,
        :system_flag_scheduler_wall_time,
        :system_monitor,
        :trace,
        :trace_info,
        :trace_pattern,
        :trace_session_create,
        :trace_session_destroy,
        :wait_release_literal_area_switch
      ]}, :runtime_internal,
     [
       "erts/src/erts_internal.erl:183",
       "erts/src/erts_internal.erl:287",
       "erts/src/erts_internal.erl:393",
       "erts/src/erts_internal.erl:616",
       "erts/src/erts_internal.erl:885",
       "erts/src/erts_internal.erl:889",
       "erts/src/erts_internal.erl:1002",
       "erts/src/erts_internal.erl:1091",
       "erts/src/erts_internal.erl:1177",
       "erts/src/erts_internal.erl:183",
       "erts/src/erts_internal.erl:287",
       "erts/src/erts_internal.erl:393",
       "erts/src/erts_internal.erl:616",
       "erts/src/erts_internal.erl:885",
       "erts/src/erts_internal.erl:889",
       "erts/src/erts_internal.erl:1002",
       "erts/src/erts_internal.erl:1091",
       "erts/src/erts_internal.erl:1177"
     ]},
    {{:init,
      [
        :archive_extension,
        :code_path_choice,
        :fetch_loaded,
        :get_argument,
        :get_arguments,
        :get_configfd,
        :get_plain_arguments,
        :get_status,
        :objfile_extension,
        :script_id,
        :script_name
      ]}, :pure_data,
     [
       "erts/src/init.erl:1834",
       "erts/src/init.erl:641",
       "erts/src/init.erl:451",
       "erts/src/init.erl:391",
       "erts/src/init.erl:340",
       "erts/src/init.erl:325",
       "erts/src/init.erl:368",
       "erts/src/init.erl:446",
       "erts/src/init.erl:1824",
       "erts/src/init.erl:402",
       "erts/src/init.erl:412",
       "erts/src/init.erl:1834",
       "erts/src/init.erl:630",
       "erts/src/init.erl:441",
       "erts/src/init.erl:386",
       "erts/src/init.erl:335",
       "erts/src/init.erl:320",
       "erts/src/init.erl:362",
       "erts/src/init.erl:446",
       "erts/src/init.erl:1824",
       "erts/src/init.erl:397",
       "erts/src/init.erl:407"
     ]},
    {{:init, [:reboot, :set_configfd, :stop, :notify_when_started, :wait_until_started]},
     :runtime_internal,
     [
       "erts/src/init.erl:532",
       "erts/src/init.erl:330",
       "erts/src/init.erl:531",
       "erts/src/init.erl:469",
       "erts/src/init.erl:474",
       "erts/src/init.erl:527",
       "erts/src/init.erl:325",
       "erts/src/init.erl:546",
       "erts/src/init.erl:464",
       "erts/src/init.erl:469"
     ]},
    {{:init, [:ensure_loaded]}, :by_name, ["erts/src/init.erl:463", "erts/src/init.erl:458"]},
    {{:erl_prim_loader,
      [
        :get_cwd,
        :get_file,
        :get_path,
        :is_basename,
        :list_dir,
        :prim_get_cwd,
        :prim_list_dir,
        :prim_read_file,
        :prim_read_file_info,
        :read_file,
        :read_file_info,
        :read_link_info
      ]}, :pure_data,
     [
       "erts/src/erl_prim_loader.erl:242",
       "erts/src/erl_prim_loader.erl:262",
       "erts/src/erl_prim_loader.erl:298",
       "erts/src/erl_prim_loader.erl:344",
       "erts/src/erl_prim_loader.erl:390",
       "erts/src/erl_prim_loader.erl:1405",
       "erts/src/erl_prim_loader.erl:281",
       "erts/src/erl_prim_loader.erl:1225",
       "erts/src/erl_prim_loader.erl:1135",
       "erts/src/erl_prim_loader.erl:1107",
       "erts/src/erl_prim_loader.erl:1189",
       "erts/src/erl_prim_loader.erl:298",
       "erts/src/erl_prim_loader.erl:318",
       "erts/src/erl_prim_loader.erl:335",
       "erts/src/erl_prim_loader.erl:238",
       "erts/src/erl_prim_loader.erl:258",
       "erts/src/erl_prim_loader.erl:294",
       "erts/src/erl_prim_loader.erl:340",
       "erts/src/erl_prim_loader.erl:386",
       "erts/src/erl_prim_loader.erl:1398",
       "erts/src/erl_prim_loader.erl:277",
       "erts/src/erl_prim_loader.erl:1230",
       "erts/src/erl_prim_loader.erl:1128",
       "erts/src/erl_prim_loader.erl:1100",
       "erts/src/erl_prim_loader.erl:1182",
       "erts/src/erl_prim_loader.erl:294",
       "erts/src/erl_prim_loader.erl:318",
       "erts/src/erl_prim_loader.erl:335"
     ]},
    {{:erl_prim_loader, [:start, :prim_init, :purge_archive_cache]}, :runtime_internal,
     [
       "erts/src/erl_prim_loader.erl:153",
       "erts/src/erl_prim_loader.erl:1037",
       "erts/src/erl_prim_loader.erl:381",
       "erts/src/erl_prim_loader.erl:149",
       "erts/src/erl_prim_loader.erl:1030",
       "erts/src/erl_prim_loader.erl:377"
     ]},
    {{:prim_eval, [:receive]}, :runtime_internal,
     ["erts/src/prim_eval.erl:30", "erts/src/prim_eval.erl:30"]},
    {{:qlc,
      [
        :all_selections,
        :append,
        :aux_name,
        :format_error,
        :info,
        :keysort,
        :name_suffix,
        :parse_transform_info,
        :q,
        :sort,
        :table,
        :template_state,
        :var_fold,
        :var_ufold,
        :vars
      ]}, :pure_data,
     [
       "stdlib/src/qlc.erl:1344",
       "stdlib/src/qlc.erl:210",
       "stdlib/src/qlc.erl:1310",
       "stdlib/src/qlc.erl:1470",
       "stdlib/src/qlc.erl:521",
       "stdlib/src/qlc.erl:672",
       "stdlib/src/qlc.erl:266",
       "stdlib/src/qlc.erl:149",
       "stdlib/src/qlc.erl:766",
       "stdlib/src/qlc.erl:975",
       "stdlib/src/qlc.erl:1284",
       "stdlib/src/qlc.erl:163",
       "stdlib/src/qlc.erl:1361",
       "stdlib/src/qlc.erl:1372",
       "stdlib/src/qlc.erl:1336",
       "stdlib/src/qlc.erl:1336",
       "stdlib/src/qlc.erl:203",
       "stdlib/src/qlc.erl:1302",
       "stdlib/src/qlc.erl:1463",
       "stdlib/src/qlc.erl:514",
       "stdlib/src/qlc.erl:665",
       "stdlib/src/qlc.erl:259",
       "stdlib/src/qlc.erl:141",
       "stdlib/src/qlc.erl:759",
       "stdlib/src/qlc.erl:968",
       "stdlib/src/qlc.erl:1277",
       "stdlib/src/qlc.erl:157",
       "stdlib/src/qlc.erl:1353",
       "stdlib/src/qlc.erl:1364",
       "stdlib/src/qlc.erl:1328",
       "stdlib/src/qlc.erl:1328"
     ]},
    {{:qlc, [:delete_cursor]}, :runtime_internal,
     ["stdlib/src/qlc.erl:297", "stdlib/src/qlc.erl:290"]},
    {{:qlc, [:parse_transform, :transform_from_evaluator]}, :compiler_pass,
     [
       "stdlib/src/qlc.erl:751",
       "stdlib/src/qlc.erl:1317",
       "stdlib/src/qlc.erl:744",
       "stdlib/src/qlc.erl:1309"
     ]},
    {{:zlib, [:on_load]}, :own_native, ["erts/src/zlib.erl:176", "erts/src/zlib.erl:174"]},
    {{:zlib,
      [
        :open,
        :close,
        :set_controlling_process,
        :deflateInit,
        :deflateSetDictionary,
        :deflateReset,
        :deflateParams,
        :deflate,
        :deflateEnd,
        :inflateInit,
        :inflateSetDictionary,
        :inflateGetDictionary,
        :inflateReset,
        :inflate,
        :inflateEnd,
        :safeInflate
      ]}, :runtime_internal,
     [
       "erts/src/zlib.erl:183",
       "erts/src/zlib.erl:191",
       "erts/src/zlib.erl:201",
       "erts/src/zlib.erl:209",
       "erts/src/zlib.erl:445",
       "erts/src/zlib.erl:183",
       "erts/src/zlib.erl:189",
       "erts/src/zlib.erl:199",
       "erts/src/zlib.erl:207",
       "erts/src/zlib.erl:443"
     ]},
    {{:zlib, [:compress, :uncompress, :zip, :unzip, :gzip, :gunzip]}, :pure_data,
     [
       "erts/src/zlib.erl:683",
       "erts/src/zlib.erl:699",
       "erts/src/zlib.erl:727",
       "erts/src/zlib.erl:743",
       "erts/src/zlib.erl:759",
       "erts/src/zlib.erl:775",
       "erts/src/zlib.erl:681",
       "erts/src/zlib.erl:697",
       "erts/src/zlib.erl:725",
       "erts/src/zlib.erl:741",
       "erts/src/zlib.erl:757",
       "erts/src/zlib.erl:773"
     ]},
    {:lists, :pure_data, ["stdlib/src/lists.erl:49", "stdlib/src/lists.erl:47"]},
    {:maps, :pure_data, ["stdlib/src/maps.erl:33", "stdlib/src/maps.erl:31"]},
    {:orddict, :pure_data, ["stdlib/src/orddict.erl:43", "stdlib/src/orddict.erl:65"]},
    {:ordsets, :pure_data, ["stdlib/src/ordsets.erl:45", "stdlib/src/ordsets.erl:43"]},
    {:sets, :pure_data, ["stdlib/src/sets.erl:121", "stdlib/src/sets.erl:119"]},
    {:io_lib, :pure_data, ["stdlib/src/io_lib.erl:74", "stdlib/src/io_lib.erl:72"]},
    {:erl_anno, :pure_data, ["stdlib/src/erl_anno.erl:76", "stdlib/src/erl_anno.erl:74"]},
    {:erl_features, :pure_data,
     ["stdlib/src/erl_features.erl:35", "stdlib/src/erl_features.erl:30"]},
    {:erl_internal, :pure_data,
     ["stdlib/src/erl_internal.erl:59", "stdlib/src/erl_internal.erl:57"]},
    {:erl_lint, :pure_data, ["stdlib/src/erl_lint.erl:75", "stdlib/src/erl_lint.erl:71"]},
    {:records, :pure_data, ["stdlib/src/records.erl:38"]}
  ]

  setup_all do
    graph = build_graph()
    {:ok, graph: graph}
  end

  @exclusions @exclusions ++ [@escript_debug_exclusion]

  test "caller-chain index preserves duplicate edges and lowest caller arity" do
    start_mfa = {:fablebook_index_target, :run, 9}
    caller = {:fablebook_index_middle, :route}
    sink = {:fablebook_index_sink, :stop}

    parent = %{
      {:fablebook_index_target, :run} => caller,
      caller => sink,
      sink => nil
    }

    edges = [
      {{:fablebook_index_middle, :route, 3}, sink},
      {{:fablebook_index_middle, :route, 1}, sink},
      {{:fablebook_index_middle, :route, 1}, sink},
      {{:fablebook_index_middle, :route, 0}, {:fablebook_index_other, :stop}}
    ]

    expected_index =
      edges
      |> Enum.group_by(
        fn {{module, function, _arity}, next} -> {{module, function}, next} end,
        fn {caller_mfa, _next} -> caller_mfa end
      )
      |> Map.new(fn {key, candidates} ->
        caller_mfa =
          candidates
          |> Enum.uniq()
          |> Enum.sort_by(fn {module, function, arity} ->
            {Atom.to_string(module), Atom.to_string(function), arity}
          end)
          |> List.first()

        {key, caller_mfa}
      end)

    assert caller_chain_index(edges) == expected_index

    assert caller_chain(parent, start_mfa, caller_chain_index(edges)) == [
             start_mfa,
             {:fablebook_index_middle, :route, 1}
           ]

    assert caller_chain(
             %{{:fablebook_index_target, :run} => nil},
             start_mfa,
             caller_chain_index([])
           ) == [
             start_mfa
           ]

    assert_raise RuntimeError, ~r/installed OTP inventory caller-chain edge missing/, fn ->
      caller_chain(parent, start_mfa, caller_chain_index([]))
    end
  end

  @tag :audit_readiness
  test "discovers and traces a compile-only app outside historical active membership", ctx do
    dir =
      Path.join(
        System.tmp_dir!(),
        "fablebook-inventory-probe-#{System.unique_integer([:positive])}"
      )

    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)

    otp_lib = Path.join(dir, "lib")
    app = "mix_pruned_probe"
    app_atom = :mix_pruned_probe
    module = :fablebook_inventory_pruned_probe
    install_probe_app!(otp_lib, app, app_atom, "1.2.3", module)

    installed = InstalledOtp.discover!(otp_lib)

    discovered = Enum.find(installed, &(&1.app == app))

    assert discovered != nil, "installation discovery omitted #{app}"
    assert discovered.version == "1.2.3"
    assert Enum.any?(discovered.beams, &(&1.module == Atom.to_string(module)))
    assert :code.is_loaded(module) == false

    known = Enum.find(ctx.graph.discovered, &(&1.app == "kernel"))
    assert known != nil, "installed discovery omitted kernel"
    assert Enum.any?(known.beams, &(&1.module == "application"))

    inspected = InstalledOtp.inspect!([discovered], lane: ctx.graph.lane.name)
    {:ok, _} = :xref.start(:inventory_probe, xref_mode: :functions)

    try do
      :ok = :xref.set_default(:inventory_probe, warnings: false, verbose: false, builtins: true)

      ingested =
        InstalledOtp.add_directory!(:inventory_probe, discovered, lane: ctx.graph.lane.name)

      missing_source_ref = "src/#{Atom.to_string(module)}.erl"

      [source_app] =
        InstalledOtp.source_inventory!(
          [discovered],
          [%{hd(inspected) | source: missing_source_ref}],
          lane: ctx.graph.lane.name
        )

      assert source_app.source_dir_status == "missing"
      assert source_app.missing_source_beams == 1

      assert [
               %{source: ^missing_source_ref, status: "missing", bytes: nil}
             ] = source_app.beams

      assert InstalledOtp.assert_parity!(
               [discovered],
               inspected,
               ingested,
               ctx.graph.lane.name
             ) == :ok

      receipt = %{
        lane: ctx.graph.lane,
        lock_sha256: ctx.graph.lock_sha256,
        discovered: [discovered],
        inspected: inspected,
        ingested: ingested
      }

      lines = InstalledOtp.receipt_lines(receipt)
      verified = InstalledOtp.verify_receipt_lines!(lines)
      assert verified.lane == ctx.graph.lane.name
      assert Enum.any?(verified.beams, &(&1["module"] == Atom.to_string(module)))

      assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
        InstalledOtp.assert_parity!(
          [discovered],
          inspected,
          [],
          ctx.graph.lane.name
        )
      end
    after
      :stopped = :xref.stop(:inventory_probe)
    end
  end

  test "full installed graph preserves the historical active view and exposes pending apps",
       ctx do
    graph = ctx.graph
    discovered_apps = MapSet.new(graph.discovered, & &1.app)
    historical_apps = MapSet.new(graph.historical_active_otp_apps)

    active_ct_exports =
      graph.exported
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    assert MapSet.subset?(historical_apps, discovered_apps)
    assert graph.pending_apps != []
    assert Enum.all?(graph.pending_apps, &(not MapSet.member?(historical_apps, &1.app)))
    assert Enum.any?(graph.pending_apps, &(&1.app == "common_test"))
    refute "common_test" in graph.historical_active_otp_apps
    assert MapSet.member?(graph.active_modules, :ct_make)
    refute Enum.any?(graph.pending_modules, &(&1.module_atom == :ct_make))
    assert active_ct_exports == MapSet.new(@ct_make_expected_mfas)
    assert MapSet.subset?(graph.historical_active_exported, graph.exported)
    assert MapSet.subset?(MapSet.new(graph.historical_active_edges), MapSet.new(graph.edges))
    assert MapSet.size(graph.exported) > MapSet.size(graph.historical_active_exported)

    active_apps =
      graph.active_membership
      |> Enum.filter(&(&1["kind"] == "active_app"))
      |> Enum.map(& &1["app"])
      |> MapSet.new()

    expected_active_apps =
      graph.historical_active_otp_apps ++
        Enum.map(@elixir_apps, &Atom.to_string/1) ++ graph.closure

    assert active_apps == MapSet.new(expected_active_apps)

    refute Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_app" and row["app"] == "common_test"
           end)

    assert Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_module" and row["app"] == "common_test" and
               row["module"] == "ct_make"
           end)

    assert MapSet.subset?(graph.historical_active_exported, graph.full_exported)
    assert MapSet.subset?(MapSet.new(graph.historical_active_edges), MapSet.new(graph.full_edges))
    assert MapSet.size(graph.historical_active_modules) > 0
  end

  @tag :audit_readiness
  test "full installed BEAM identities reject omissions before accepting selected source", ctx do
    graph = ctx.graph

    discovered_apps = MapSet.new(graph.discovered, & &1.app)
    app_roots = InstalledOtp.app_roots!(:code.lib_dir() |> to_string(), lane: graph.lane.name)
    app_root_names = MapSet.new(app_roots, & &1.app)

    discovered_beam_apps =
      graph.discovered |> Enum.filter(&(&1.beams != [])) |> MapSet.new(& &1.app)

    inspected_apps = MapSet.new(graph.inspected, & &1.app)
    ingested_apps = MapSet.new(graph.ingested, & &1.app)

    assert discovered_apps == app_root_names
    assert discovered_beam_apps == inspected_apps
    assert discovered_beam_apps == ingested_apps

    first = hd(graph.inspected)
    omitted = Enum.reject(graph.inspected, &(&1.app == first.app and &1.module == first.module))

    error =
      assert_raise InstalledOtp.Error, fn ->
        InstalledOtp.assert_parity!(graph.discovered, omitted, graph.ingested, graph.lane.name)
      end

    assert error.reason == :identity_parity
    assert error.detail.lane == graph.lane.name
    assert Exception.message(error) =~ first.module

    assert :ok =
             InstalledOtp.assert_parity!(
               graph.discovered,
               graph.inspected,
               graph.ingested,
               graph.lane.name
             )

    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    resolved = SweepEvidence.resolve!(evidence, "kernel/src/file.erl:1")

    assert resolved.line == 1
    assert resolved.origin in [:installed, :archive]
    assert resolved.sha256 =~ ~r/^[a-f0-9]{64}$/
  end

  @tag :audit_readiness
  test "source evidence rejects a wrong runtime patch before resolving citations" do
    error =
      assert_raise Fablebook.Test.SweepEvidence.Error, fn ->
        SweepEvidence.lane!(%{elixir: "1.20.4", otp: "29.1.1"})
      end

    assert error.reason == :runtime_identity
  end

  @tag :audit_readiness
  test "source evidence resolves the caller-file atom trace on the exact running lane" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    resolved = SweepEvidence.resolve!(evidence, "kernel/src/file.erl:1")

    assert resolved.line == 1
    assert resolved.sha256 =~ ~r/^[a-f0-9]{64}$/
    assert resolved.origin in [:installed, :archive]
    assert evidence.lane.otp in ["29.1.2", "27.3.4.9"]

    trailing = SweepEvidence.resolve!(evidence, "kernel/src/inet_config.erl:1")
    data = File.read!(trailing.path)
    assert String.ends_with?(data, "\n\n")
    last_line = length(String.split(data, "\n")) - 1
    assert SweepEvidence.resolve!(evidence, "kernel/src/inet_config.erl:#{last_line}").text == ""

    trace =
      if evidence.lane.name == "core" do
        [
          {"kernel/src/file.erl:2314", "path_consult(Path, File)"},
          {"kernel/src/file.erl:2317", "consult_stream(Fd)"},
          {"kernel/src/file.erl:2905", "io:read(Fd"},
          {"stdlib/src/io.erl:765", "erl_scan,tokens"},
          {"stdlib/src/erl_scan.erl:788", "list_to_atom(Wcs)"}
        ]
      else
        [
          {"kernel/src/file.erl:2304", "path_consult(Path, File)"},
          {"kernel/src/file.erl:2307", "consult_stream(Fd)"},
          {"kernel/src/file.erl:2895", "io:read(Fd"},
          {"stdlib/src/io.erl:734", "erl_scan,tokens"},
          {"stdlib/src/erl_scan.erl:761", "list_to_atom(Wcs)"}
        ]
      end

    for {citation, expected} <- trace do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected
    end

    assert SweepEvidence.resolve!(evidence, "elixir/src/elixir_aliases.erl:1").origin == :archive
  end

  test "ct_make four-export caller, default and load traces resolve from exact sources", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    lane = evidence.lane.name
    expected = Map.fetch!(@ct_make_source_by_lane, lane)
    otp_ref = evidence.manifest["refs"][lane]["otp"] |> Enum.at(1)
    records = Enum.filter(@ct_make_audit, &(&1.lane == lane))

    source =
      Enum.find(
        evidence.manifest["files"],
        &(&1["path"] == "#{lane}/common_test/src/ct_make.erl")
      )

    assert source["lane"] == lane
    assert source["source_path"] == "common_test/src/ct_make.erl"
    assert source["sha256"] == expected.sha256
    assert source["status"] == "present"
    assert source["url"] =~ "/#{otp_ref}/lib/common_test/src/ct_make.erl"

    assert MapSet.new(Enum.map(records, &hd(&1.matched_mfas))) ==
             MapSet.new(@ct_make_expected_mfas)

    assert MapSet.new(
             ctx.graph.full_exported
             |> Enum.filter(&(elem(&1, 0) == :ct_make))
           ) == MapSet.new(@ct_make_expected_mfas)

    for record <- records, {citation, expected_source} <- record.citations do
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.origin in [:archive, :installed], citation
      assert resolved.sha256 == expected.sha256, citation
      assert resolved.text =~ expected_source, citation
    end
  end

  test "CT audit maps each export and rejects incomplete matches, sources and redundant retention",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = @ct_make_audit
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    assert_ct_make_audit!(records, ctx.graph, tier, evidence)

    lane_records = Enum.filter(records, &(&1.lane == evidence.lane.name))
    record = Enum.find(lane_records, &(&1.matched_mfas == [{:ct_make, :all, 0}]))
    record_index = Enum.find_index(records, &(&1.original_id == record.original_id))

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(
        Enum.reject(records, &(&1.original_id == record.original_id)),
        ctx.graph,
        tier,
        evidence
      )
    end

    wrong_lane = %{record | lane: "wrong-lane"}
    missing_mfa = %{record | matched_mfas: []}
    two_tuple = %{record | matched_mfas: [{:ct_make, :all}]}
    missing_verdict = %{record | verdict: :unreviewed}
    missing_citations = %{record | citations: []}

    for malformed <- [wrong_lane, missing_mfa, two_tuple, missing_verdict, missing_citations] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_ct_make_audit!(
          List.replace_at(records, record_index, malformed),
          ctx.graph,
          tier,
          evidence
        )
      end
    end

    missing_source = %{
      record
      | citations: [{"common_test/src/ct_make.erl:999999", "all() ->"}]
    }

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      SweepEvidence.resolve!(evidence, "common_test/src/ct_make.erl:999999")
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(
        List.replace_at(records, record_index, missing_source),
        ctx.graph,
        tier,
        evidence
      )
    end

    omitted_tier = Enum.reject(tier, &(&1 == {:ct_make, :all, 0}))

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(records, ctx.graph, omitted_tier, evidence)
    end

    redundant_retention =
      {{:mfa, {:ct_make, :all, 0}}, :private_front, [hd(record.citations) |> elem(0)]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_ct_make_audit!(
        records,
        ctx.graph,
        tier,
        evidence,
        @exclusions ++ [redundant_retention]
      )
    end

    for mfa <- @ct_make_expected_mfas do
      assert mfa in undisposed(ctx.graph, Enum.reject(tier, &(&1 == mfa)), names),
             "removing only #{inspect(mfa)} must expose that previously covered front"
    end
  end

  test "saved-settings monitor source retains a private replay initializer and pending ownership" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    {export_line, init_line, read_line, decode_line} =
      if evidence.lane.name == "core",
        do: {33, 115, 676, 678},
        else: {29, 111, 672, 674}

    resolve = fn line ->
      SweepEvidence.resolve!(evidence, "debugger/src/dbg_wx_mon.erl:#{line}")
    end

    assert resolve.(export_line).text == "-export([start/2, stop/0])."
    assert resolve.(init_line).text == "init(CallingPid, Mode, SFile) ->"
    assert resolve.(read_line).text =~ "file:read_file(SFile)"
    assert resolve.(decode_line).text =~ "binary_to_term(Binary)"
    assert {:dbg_wx_mon, :start, 2} in BannedCalls.banned_mfas()
    refute {:dbg_wx_mon, :init, 3} in BannedCalls.banned_mfas()
    assert :dbg_wx_mon in DebuggerPendingOwnership.baseline_modules()
    assert DebuggerPendingOwnership.owners()[:dbg_wx_mon] == "01.1.1.3.1.2"
  end

  @tag :tmp_dir
  @tag :saved_settings_source
  test "installed successor rows resolve and source corruption controls reject", %{
    tmp_dir: tmp_dir
  } do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    assert SweepEvidence.archive_sha256() ==
             "7d4bd66fe72224cf49f849148b5e737443588ca66c12873938bfa30fa3d0ea58"

    lane = evidence.lane.name

    expected_paths =
      for module <- ~w(dbg_icmd dbg_iserver dbg_wx_settings debugger),
          do: "#{lane}/debugger/src/#{module}.erl"

    rows = Enum.filter(evidence.manifest["files"], &(&1["path"] in expected_paths))
    assert Enum.map(rows, & &1["path"]) |> Enum.sort() == Enum.sort(expected_paths)

    archive_evidence = %{
      evidence
      | installed:
          Map.put(
            evidence.installed,
            "debugger",
            Path.join(evidence.archive_root, "missing-debugger")
          )
    }

    for row <- rows do
      citation = row["source_path"] <> ":1"
      assert SweepEvidence.resolve!(archive_evidence, citation).sha256 == row["sha256"]
    end

    settings_row = Enum.find(rows, &(&1["source_path"] == "debugger/src/dbg_wx_settings.erl"))
    settings_citation = settings_row["source_path"] <> ":1"

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      SweepEvidence.resolve!(archive_evidence, settings_row["source_path"] <> ":999999")
    end

    outside_source = Path.join(tmp_dir, "outside-settings.erl")
    File.write!(outside_source, "outside source")
    installed_root = Path.join(tmp_dir, "untrusted-debugger")
    symlink_path = Path.join(installed_root, "src/dbg_wx_settings.erl")
    File.mkdir_p!(Path.dirname(symlink_path))
    assert :ok = File.ln_s(outside_source, symlink_path)

    escaped_evidence = %{
      evidence
      | installed: Map.put(evidence.installed, "debugger", installed_root)
    }

    assert_raise SweepEvidence.Error, ~r/source_escape/, fn ->
      SweepEvidence.resolve!(escaped_evidence, settings_citation)
    end

    archive_source = Path.join(evidence.archive_root, settings_row["path"])
    File.write!(archive_source, "corrupt source bytes")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(archive_evidence, settings_citation)
    end
  end

  @tag :saved_settings_audit
  test "saved-settings dialog and replay have exact lane source and branch coverage", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    assert Code.ensure_loaded?(DebuggerSettings),
           "the settings audit must provide source-backed records for the complete dialog and replay path"

    record = DebuggerSettings.records(evidence.lane.name)
    changed_universe = saved_settings_changed_family_universe(ctx.graph, record)
    exclusion_matches = DebuggerSettings.exclusion_matches(changed_universe, @exclusions)

    assert exclusion_matches == @saved_settings_expected_exclusion_matches,
           "changed saved-settings exclusions differ from the measured exact set: #{inspect(exclusion_matches)}"

    record = %{record | exclusion_matches: exclusion_matches}

    DebuggerSettings.assert_audit!(
      record,
      ctx.graph,
      BannedCalls.banned_mfas(),
      evidence,
      @exclusions
    )

    assert :ok ==
             DebuggerSettings.assert_exclusion_witnesses!(
               exclusion_matches,
               ctx.graph,
               BannedCalls.banned_mfas(),
               BannedCalls.banned_names(),
               @exclusions
             )

    monitor_front = {:dbg_wx_mon, :start, 2}

    monitor_front_citation =
      record.roots
      |> Enum.find(&(&1.mfa == monitor_front))
      |> Map.fetch!(:citations)
      |> hd()

    source_disposition = ["#{monitor_front_citation.path}:#{monitor_front_citation.line}"]

    exact_overlap =
      {{:mfa, monitor_front}, :redundant_tier_overlap, source_disposition}

    overlap_matches =
      DebuggerSettings.exclusion_matches(changed_universe, @exclusions ++ [exact_overlap])

    [overlap_match] = overlap_matches
    assert overlap_match.matched_mfas == [monitor_front]

    assert_raise ExUnit.AssertionError, ~r/no individual active removal witness/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        overlap_matches,
        ctx.graph,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        @exclusions ++ [exact_overlap]
      )
    end

    assert_raise ExUnit.AssertionError, ~r/incomplete matches/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        [%{overlap_match | matched_mfas: []}],
        ctx.graph,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        @exclusions ++ [exact_overlap]
      )
    end

    blanket_overlap = {{:dbg_wx_mon, :_}, :blanket_overlap, source_disposition}

    blanket_matches =
      DebuggerSettings.exclusion_matches(changed_universe, [blanket_overlap])

    assert_raise ExUnit.AssertionError, ~r/blanket or non-exact/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        blanket_matches,
        ctx.graph,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        [blanket_overlap]
      )
    end

    assert MapSet.new(DebuggerSettings.branch_ids()) ==
             MapSet.new(Map.keys(record.branch_citations))

    assert_invalid_audit = Function.capture(DebuggerSettings, :assert_audit!, 5)

    assert_raise ExUnit.AssertionError, ~r/required audit fields/, fn ->
      assert_invalid_audit.(
        Map.new(),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    branchless = %{record | branch_citations: %{}, source_branches: []}

    assert_raise ExUnit.AssertionError, ~r/complete settings and replay branch map/, fn ->
      DebuggerSettings.assert_audit!(
        branchless,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    for omitted_branch <- [
          :default_path,
          :settings_read_error,
          :conditional_callback_clause
        ] do
      incomplete_branches = %{
        record
        | branch_citations: Map.delete(record.branch_citations, omitted_branch),
          source_branches: Enum.reject(record.source_branches, &(&1.id == omitted_branch))
      }

      assert_raise ExUnit.AssertionError, ~r/complete settings and replay branch map/, fn ->
        DebuggerSettings.assert_audit!(
          incomplete_branches,
          ctx.graph,
          BannedCalls.banned_mfas(),
          evidence,
          @exclusions
        )
      end
    end

    incomplete_functions = %{
      record
      | function_sources: tl(record.function_sources),
        function_audit: tl(record.function_audit)
    }

    omitted_function_error =
      assert_raise ExUnit.AssertionError, ~r/missing_source=/, fn ->
        DebuggerSettings.assert_audit!(
          incomplete_functions,
          ctx.graph,
          BannedCalls.banned_mfas(),
          evidence,
          @exclusions
        )
      end

    assert omitted_function_error.message =~ "lane #{evidence.lane.name}"
    assert omitted_function_error.message =~ "dbg_wx_settings:default_settings_dir/1"
    assert omitted_function_error.message =~ "owner=01.1.1.3.1.1"
    assert omitted_function_error.message =~ "caller-chain="
    assert omitted_function_error.message =~ "remedy="

    wrong_lane = if evidence.lane.name == "core", do: "floor", else: "core"
    wrong_lane_evidence = %{evidence | lane: Map.put(evidence.lane, :name, wrong_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph lane/, fn ->
      DebuggerSettings.assert_audit!(
        record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        wrong_lane_evidence,
        @exclusions
      )
    end

    first_source = hd(record.function_sources)
    [first_citation | rest_citations] = first_source.citation

    wrong_source_record = %{
      record
      | function_sources: [
          %{
            first_source
            | citation: [
                %{first_citation | expected_text: "not the source line"} | rest_citations
              ]
          }
          | tl(record.function_sources)
        ]
    }

    assert_raise ExUnit.AssertionError, ~r/restore matching branch text/, fn ->
      DebuggerSettings.assert_audit!(
        wrong_source_record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    wrong_hash_record = %{
      record
      | function_sources: [
          %{
            first_source
            | citation: [%{first_citation | sha256: String.duplicate("0", 64)} | rest_citations]
          }
          | tl(record.function_sources)
        ]
    }

    assert_raise ExUnit.AssertionError, ~r/restore exact lane SHA/, fn ->
      DebuggerSettings.assert_audit!(
        wrong_hash_record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end

    wrong_line_record = %{
      record
      | function_sources: [
          %{first_source | citation: [%{first_citation | line: 999_999} | rest_citations]}
          | tl(record.function_sources)
        ]
    }

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      DebuggerSettings.assert_audit!(
        wrong_line_record,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions
      )
    end
  end

  @tag :debugger_remainder_tracer
  test "auto-attach setter route binds exact source, installed BEAM and adopted owners", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)

    assert :ok ==
             DebuggerSettings.assert_auto_attach_trace!(
               record,
               ctx.graph,
               BannedCalls.banned_mfas(),
               evidence
             )

    missing_store = %{
      record
      | auto_attach_trace: Map.delete(record.auto_attach_trace, :stored_value)
    }

    assert_raise ExUnit.AssertionError, ~r/stored tuple/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_store,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    missing_gate = %{
      record
      | auto_attach_trace: Map.delete(record.auto_attach_trace, :event_gate)
    }

    assert_raise ExUnit.AssertionError, ~r/event gate/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_gate,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    missing_tuple = %{
      record
      | source_branches: Enum.reject(record.source_branches, &(&1.id == :auto_attach_two_tuple)),
        branch_citations: Map.delete(record.branch_citations, :auto_attach_two_tuple)
    }

    assert_raise ExUnit.AssertionError, ~r/missing source branches/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_tuple,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    missing_dispatch = %{
      record
      | source_branches:
          Enum.reject(record.source_branches, &(&1.id == :auto_attach_event_match_spawn)),
        branch_citations: Map.delete(record.branch_citations, :auto_attach_event_match_spawn)
    }

    assert_raise ExUnit.AssertionError, ~r/missing source branches/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        missing_dispatch,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    wrong_owner = %{
      record
      | source_branches:
          Enum.map(record.source_branches, fn branch ->
            if branch.id == :auto_attach_tuple_store,
              do: %{branch | owner: "01.1.1.3.1.1"},
              else: branch
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/retain the adopted remainder owner/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        wrong_owner,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    [store_citation | remaining_store_citations] =
      record.branch_citations.auto_attach_tuple_store

    wrong_hash = %{
      record
      | branch_citations:
          Map.put(record.branch_citations, :auto_attach_tuple_store, [
            %{store_citation | sha256: String.duplicate("0", 64)} | remaining_store_citations
          ])
    }

    assert_raise ExUnit.AssertionError, ~r/restore exact lane SHA/, fn ->
      DebuggerSettings.assert_auto_attach_trace!(
        wrong_hash,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_monitor
  test "monitor and file-window source branches include exact defaults and routes", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(ctx.graph.lane.name)

    result =
      DebuggerSettings.assert_function_dispositions!(ctx.graph, evidence, record, :monitor)

    assert result.status == :verified

    assert result.module_names == [
             "dbg_wx_filedialog_win",
             "dbg_wx_mon",
             "dbg_wx_mon_win",
             "dbg_wx_win"
           ]

    required_branch_ids = [
      :monitor_start_error,
      :monitor_start_already_started,
      :startup_graphics_error,
      :startup_graphics_ready,
      :startup_init2_stop,
      :startup_init2_error,
      :startup_default_no_replay,
      :startup_default_loop,
      :startup_selected_replay,
      :load_menu_cancel,
      :load_menu_selected,
      :trace_windows_selected,
      :trace_windows_unselected,
      :monitor_dialog_default_path,
      :monitor_dialog_filter_default,
      :monitor_dialog_sort_default,
      :monitor_dialog_cancel,
      :monitor_dialog_selected,
      :monitor_dialog_filter_dispatch,
      :monitor_window_shortcut_atom,
      :monitor_window_module_atom,
      :monitor_window_reload_module_atom,
      :monitor_window_checkbox_atoms,
      :monitor_window_strings_checkbox_atom,
      :monitor_process_pid_parse,
      :monitor_backtrace_integer_scanner,
      :monitor_backtrace_integer_token_match,
      :monitor_edit_variable_term_scanner,
      :monitor_edit_variable_term_parser
    ]

    assert Enum.map(result.source_branches, & &1.id) == Enum.sort(required_branch_ids)

    prior_root_rows = Map.new(record.roots, &{&1.mfa, &1})

    assert Enum.all?(
             [
               {:dbg_wx_mon, :start, 2},
               {:dbg_wx_mon, :load_settings, 2},
               {:dbg_wx_mon, :load_settings2, 2}
             ],
             fn mfa ->
               root = Map.fetch!(prior_root_rows, mfa)
               root.owner == "01.1.1.3.1.1" and root.completion == :pending
             end
           )

    assert result.cross_owner.selected_roots
           |> Enum.any?(&(&1.mfa == "dbg_wx_mon:start/2" and &1.changed_route))

    assert result.cross_owner.selected_branches
           |> Enum.map(& &1.id)
           |> Enum.sort() == [
             :monitor_start_already_started,
             :monitor_start_error,
             :trace_windows_selected,
             :trace_windows_unselected
           ]

    source_functions =
      result.modules
      |> Enum.flat_map(& &1.dispositions)
      |> Map.new(&{&1.mfa, &1})

    expected_atom_lines =
      if ctx.graph.lane.name == "core",
        do: [534, 557, 565, 577, 596],
        else: [530, 553, 561, 573, 592]

    actual_atom_lines =
      source_functions["dbg_wx_mon_win:handle_event/2"].sink_facts
      |> Enum.filter(&(&1.kind == :atom_construction))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    assert actual_atom_lines == expected_atom_lines

    assert Enum.any?(
             source_functions["dbg_wx_mon_win:clear_processes/2"].sink_facts,
             &(&1.kind == :pid_parser)
           )

    assert Enum.any?(
             source_functions["dbg_wx_filedialog_win:get_file_info/5"].sink_facts,
             &(&1.kind == :dynamic_fun_call)
           )

    verify_note = source_functions["dbg_wx_win:verify/2"]
    expected_verify_scanner_line = if ctx.graph.lane.name == "core", do: 279, else: 277
    expected_verify_parser_line = if ctx.graph.lane.name == "core", do: 281, else: 279

    assert Enum.any?(
             verify_note.sink_facts,
             &(&1.kind == :token_scanner and &1.line == expected_verify_scanner_line)
           )

    assert Enum.any?(
             verify_note.sink_facts,
             &(&1.kind == :term_parser and &1.line == expected_verify_parser_line)
           )

    assert String.contains?(verify_note.guard_remedy, "cannot intern")
    assert String.contains?(verify_note.defaults_and_options, "non-term clause")
    assert String.contains?(verify_note.defaults_and_options, "extended_parse_term")
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_trace
  test "trace and breakpoint routes reconcile exact sources and current owner links", ctx do
    required_branch_ids = [
      :trace_breakpoint_menu_dispatch,
      :trace_edit_variable_term_entry,
      :trace_edit_variable_assignment,
      :trace_user_command_eval_dispatch,
      :trace_backtrace_integer_entry,
      :break_dialog_module_atom_live_edit,
      :break_dialog_module_atom_function_submit,
      :break_dialog_module_atom_line_submit,
      :break_dialog_atom_input_types,
      :break_dialog_module_list_lookup,
      :break_dialog_typed_input_wrapper,
      :break_dialog_typed_input_scanner,
      :break_dialog_conditional_callback_tuple,
      :trace_shortcut_atom,
      :trace_resize_fixed_closure_calls,
      :trace_resize_code_fixed_changeh_closure,
      :trace_resize_trace_fixed_changeh_closure,
      :trace_code_area_fixed_style_closure,
      :trace_source_view_fixed_style_closure,
      :trace_output_fixed_callback_invocation,
      :trace_eval_entry_user_command,
      :trace_view_module_source_lookup,
      :trace_trace_module_source_lookup,
      :view_breakpoint_action_dispatch,
      :break_process_fixed_worker,
      :view_process_fixed_worker
    ]

    actual_branch_ids = MapSet.new(DebuggerSettings.branch_ids())
    missing_branch_ids = MapSet.difference(MapSet.new(required_branch_ids), actual_branch_ids)

    assert MapSet.size(missing_branch_ids) == 0,
           "trace and breakpoint source routes are incomplete: #{inspect(MapSet.to_list(missing_branch_ids))}"

    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)

    result =
      DebuggerSettings.assert_function_dispositions!(ctx.graph, evidence, record, :trace)

    assert result.status == :verified
    assert result.group == :trace

    assert result.module_names == [
             "dbg_wx_break",
             "dbg_wx_break_win",
             "dbg_wx_code",
             "dbg_wx_src_view",
             "dbg_wx_trace",
             "dbg_wx_trace_win",
             "dbg_wx_view",
             "dbg_wx_winman"
           ]

    assert Enum.map(result.source_branches, & &1.id) == Enum.sort(required_branch_ids)

    refute Enum.any?(result.modules, fn module ->
             Enum.any?(module.dispositions, &(&1.mfa == "dbg_wx_win:verify/2"))
           end)

    assert result.cross_owner.prior_owner_break_branch == %{
             id: :conditional_callback_clause,
             mfa: "dbg_icmd:break_p/4",
             owner: "01.1.1.3.1.1"
           }

    assert result.cross_owner.remainder_break_dispatch_branch == %{
             id: :condition_break_p_called,
             mfa: "dbg_icmd:cmd/4",
             owner: "01.1.1.3.1.2"
           }

    assert result.cross_owner.current_callback_branch == %{
             id: :break_dialog_conditional_callback_tuple,
             mfa: "dbg_wx_break:gui_cmd/2",
             owner: "01.1.1.3.1.2"
           }

    assert Enum.map(result.cross_owner.interpreter_roots, & &1.mfa) == [
             "dbg_wx_interpret:filter_files/2",
             "dbg_wx_interpret:interpret_all/5",
             "dbg_wx_interpret:start/4"
           ]

    assert Enum.all?(result.cross_owner.interpreter_roots, &(&1.owner == "01.1.1.3.1.2"))
    refute "dbg_wx_interpret" in result.module_names

    source_functions =
      result.modules
      |> Enum.flat_map(& &1.dispositions)
      |> Map.new(&{&1.mfa, &1})

    expected_break_atom_lines =
      if ctx.graph.lane.name == "core", do: [192, 215, 224], else: [188, 211, 220]

    actual_break_atom_lines =
      source_functions["dbg_wx_break_win:handle_event/2"].sink_facts
      |> Enum.filter(&(&1.kind == :atom_construction))
      |> Enum.map(& &1.line)
      |> Enum.sort()

    assert actual_break_atom_lines == expected_break_atom_lines

    expected_shortcut_atom_line = if ctx.graph.lane.name == "core", do: 799, else: 795

    assert Enum.any?(
             source_functions["dbg_wx_trace_win:handle_event/2"].sink_facts,
             &(&1.kind == :atom_construction and &1.line == expected_shortcut_atom_line)
           )

    assert Enum.any?(
             source_functions["dbg_wx_break_win:check_input/2"].sink_facts,
             &(&1.kind == :token_scanner)
           )

    edit_route = source_functions["dbg_wx_trace:gui_cmd/2"]
    break_input = source_functions["dbg_wx_break_win:check_input/2"]
    break_wrapper = source_functions["dbg_wx_break_win:check_input/1"]
    break_route = source_functions["dbg_wx_break:gui_cmd/2"]
    trace_output = source_functions["dbg_wx_trace:meta_cmd/2"]
    code_style = source_functions["dbg_wx_code:code_area/1"]
    source_style = source_functions["dbg_wx_src_view:code_area/2"]
    trace_window = source_functions["dbg_wx_trace_win:handle_event/2"]

    assert String.contains?(trace_output.caller_input_origin, "dbg_ieval:trace/3")
    assert String.contains?(trace_output.caller_input_origin, "dbg_icmd:tell_attached/1")
    assert String.contains?(trace_output.guard_remedy, "resolved cross-owner fixed callback")
    assert String.contains?(code_style.guard_remedy, "resolved benign local capability")
    assert String.contains?(source_style.guard_remedy, "resolved benign local capability")
    assert String.contains?(trace_window.guard_remedy, "resolved benign local capability")

    resolved_fun_sites =
      result.resolved_dynamic
      |> Enum.filter(&(&1.kind == :dynamic_fun_call))
      |> Enum.map(&{&1.mfa, &1.line, &1.status})
      |> Enum.sort()

    expected_resolved_fun_sites =
      if ctx.graph.lane.name == "core" do
        [
          {"dbg_wx_code:code_area/1", 98, :resolved_fixed_local_closure},
          {"dbg_wx_src_view:code_area/2", 59, :resolved_fixed_local_closure},
          {"dbg_wx_trace:meta_cmd/2", 711, :resolved_cross_owner_fixed_callback},
          {"dbg_wx_trace_win:handle_event/2", 706, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 734, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 735, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 736, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 767, :resolved_fixed_local_closure}
        ]
      else
        [
          {"dbg_wx_code:code_area/1", 96, :resolved_fixed_local_closure},
          {"dbg_wx_src_view:code_area/2", 57, :resolved_fixed_local_closure},
          {"dbg_wx_trace:meta_cmd/2", 709, :resolved_cross_owner_fixed_callback},
          {"dbg_wx_trace_win:handle_event/2", 702, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 730, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 731, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 732, :resolved_fixed_local_closure},
          {"dbg_wx_trace_win:handle_event/2", 763, :resolved_fixed_local_closure}
        ]
      end

    assert resolved_fun_sites == Enum.sort(expected_resolved_fun_sites)

    refute Enum.any?(result.unresolved_dynamic, &(&1.kind == :dynamic_fun_call))
    break_inputs = source_functions["dbg_wx_break_win:create_win/5"]
    assert String.contains?(break_inputs.defaults_and_options, "integer")
    assert String.contains?(break_inputs.defaults_and_options, "C-Module")
    assert String.contains?(break_inputs.defaults_and_options, "C-Function")
    assert String.contains?(break_inputs.defaults_and_options, "before matching")
    assert String.contains?(edit_route.caller_input_origin, "Edit Variable")
    assert String.contains?(edit_route.guard_remedy, "int:meta")
    assert String.contains?(break_input.guard_remedy, "tokenization")
    assert String.contains?(break_input.guard_remedy, "existing-atom")
    assert String.contains?(break_input.guard_remedy, "whitelist")
    assert String.contains?(break_input.defaults_and_options, "before matching")
    assert String.contains?(break_wrapper.caller_input_origin, "check_input/2")
    assert String.contains?(break_route.caller_input_origin, "int:functions/1")
    assert String.contains?(break_route.guard_remedy, "membership")
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_callbacks
  test "callback and breakpoint function dispositions reconcile exact lane sources and ownership",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)

    assert function_exported?(DebuggerSettings, :assert_function_dispositions!, 4),
           "callback and breakpoint routes need complete exact-lane function dispositions"

    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)

    dispositions =
      DebuggerSettings.assert_function_dispositions!(ctx.graph, evidence, record, :callbacks)

    assert dispositions.status == :verified
    assert dispositions.group == :callbacks
    assert dispositions.lane == evidence.lane.name

    assert dispositions.module_names ==
             Enum.sort(["int", "i", "debugger", "dbg_iserver", "dbg_icmd"])

    assert Enum.all?(dispositions.modules, fn module ->
             inventory_module = Enum.find(inventory.modules, &(&1.module == module.module))

             module.owner == "01.1.1.3.1.2" and module.functions == inventory_module.functions and
               module.exports == inventory_module.exports and
               module.dispositions |> Enum.map(& &1.mfa) |> Enum.sort() ==
                 Enum.sort(inventory_module.functions)
           end)

    assert dispositions.source_branches != []
    assert dispositions.cross_owner == [{{:dbg_icmd, :break_p, 4}, "01.1.1.3.1.1", :pending}]
    assert dispositions.unresolved_dynamic != []
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_interpreter
  test "interpreter evaluator, loader and debugged-process dispositions reconcile exact lane sources and ownership",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)

    dispositions =
      DebuggerSettings.assert_function_dispositions!(ctx.graph, evidence, record, :interpreter)

    assert dispositions.status == :verified
    assert dispositions.group == :interpreter
    assert dispositions.lane == evidence.lane.name
    assert dispositions.module_names == ["dbg_debugged", "dbg_ieval", "dbg_iload"]

    assert Enum.all?(dispositions.modules, fn module ->
             inventory_module = Enum.find(inventory.modules, &(&1.module == module.module))
             function_mfas = Enum.map(module.dispositions, & &1.mfa) |> Enum.sort()

             module.owner == "01.1.1.3.1.2" and module.functions == inventory_module.functions and
               module.exports == inventory_module.exports and
               function_mfas == Enum.sort(inventory_module.functions) and
               Enum.all?(module.dispositions, &(&1.owner == "01.1.1.3.1.2"))
           end)

    assert MapSet.new(Enum.map(dispositions.source_branches, & &1.id)) ==
             MapSet.new([
               :interpreter_eval_reentry,
               :interpreter_eval_spawn_meta,
               :interpreter_meta_initial_eval,
               :interpreter_uninterpreted_top_apply,
               :interpreter_uninterpreted_nested_apply,
               :interpreter_external_function_lookup,
               :interpreter_remote_call,
               :interpreter_apply_fun,
               :interpreter_apply_three,
               :interpreter_safe_bif_dispatch,
               :interpreter_debugged_ready_apply,
               :interpreter_debugged_command_dispatch,
               :interpreter_debugged_reply_apply,
               :interpreter_debugged_reply_eval,
               :interpreter_loader_worker,
               :interpreter_loader_envelope_decode,
               :interpreter_loader_abstract_decode,
               :interpreter_load_package,
               :interpreter_server_loader_call
             ])

    assert Enum.all?(dispositions.source_branches, &(&1.owner == "01.1.1.3.1.2"))
    assert dispositions.cross_owner == []

    assert Enum.any?(dispositions.unresolved_dynamic, &(&1.kind == :dynamic_apply))
    assert Enum.any?(dispositions.unresolved_dynamic, &(&1.kind == :dynamic_remote_dispatch))

    find_function = fn mfa ->
      dispositions.modules
      |> Enum.flat_map(& &1.dispositions)
      |> Enum.find(&(&1.mfa == mfa))
    end

    assert Enum.any?(find_function.("dbg_ieval:expr/3").sink_facts, &(&1.kind == :dynamic_apply))

    assert Enum.any?(
             find_function.("dbg_iload:store_module/4").sink_facts,
             &(&1.kind == :term_decoder)
           )

    assert Enum.any?(
             find_function.("dbg_debugged:reply/1").sink_facts,
             &(&1.kind == :dynamic_apply)
           )

    assert find_function.("dbg_ieval:eval/3").caller_input_origin =~ "int:eval/3"
    assert find_function.("dbg_iload:store_module/4").caller_input_origin =~ "int:load/2"
    assert Enum.all?(dispositions.unresolved_dynamic, &(&1.status == :unresolved_static_target))
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_inventory
  test "assigned remainder universe has a fail-closed exact-lane reconciliation contract" do
    assert Code.ensure_loaded?(DebuggerSettings)

    assert function_exported?(DebuggerSettings, :assert_remainder_inventory!, 3),
           "the current remainder universe needs an exact-lane source, function, export, root, and owner reconciliation contract"
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_inventory
  test "remainder inventory retains exact sources, private functions, graph sets and both owner namespaces",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)

    assert inventory.status == :verified
    assert inventory.lane == evidence.lane.name
    assert inventory.owner == "01.1.1.3.1.2"
    assert inventory.module_names == Enum.sort(DebuggerSettings.required_source_modules())
    assert inventory.modules != []

    assert Enum.all?(inventory.modules, fn module ->
             module.owner == "01.1.1.3.1.2" and module.source.origin == :installed and
               module.source.sha256 == module.source_assignment["sha256"] and
               module.function_count == length(module.functions) and
               module.export_count == length(module.exports) and
               Enum.all?(module.zero_hit_functions, &(&1 in module.functions)) and
               Enum.all?(module.private_functions, &(&1 in module.functions))
           end)

    original_root_ids =
      MapSet.new(
        inventory.original_roots,
        &{&1["app"], &1["module"], &1["function"], &1["arity"]}
      )

    observed_root_ids =
      MapSet.new(
        inventory.observed_roots,
        &{&1["app"], &1["module"], &1["function"], &1["arity"]}
      )

    assert original_root_ids == observed_root_ids
    assert inventory.interpreter_root_observations != []
    assert Enum.all?(inventory.interpreter_root_observations, &(&1["owner"] == "01.1.1.3.1.2"))
    assert inventory.overlaps != []

    assert inventory.overlap_occurrence_count ==
             Enum.sum(Enum.map(inventory.overlaps, &length(&1["occurrences"] || [])))

    assert MapSet.new(inventory.selected_roots) ==
             MapSet.new([
               {"debugger", "dbg_wx_mon", "start", 2},
               {"debugger", "dbg_wx_mon", "load_settings", 2},
               {"debugger", "dbg_wx_mon", "load_settings2", 2}
             ])

    [break_p] = inventory.source_branches
    assert break_p["owner"] == "01.1.1.3.1.1"
    assert break_p["completion"] == "pending"

    assert inventory.graph.full_edge_count == length(ctx.graph.full_edges)
    assert inventory.graph.full_reached_count == MapSet.size(ctx.graph.full_reached)
    assert inventory.graph.full_export_count == MapSet.size(ctx.graph.full_exported)
    assert inventory.graph.assigned_edge_count == length(inventory.graph.assigned_edges)
    assert inventory.graph.assigned_reached_count == length(inventory.graph.assigned_reached)
    assert inventory.graph.assigned_export_count == length(inventory.graph.assigned_exports)
    assert String.length(inventory.graph.full_edges_sha256) == 64
    assert String.length(inventory.graph.full_reached_sha256) == 64
    assert String.length(inventory.graph.full_exports_sha256) == 64
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_inventory
  test "installed remainder source citations reject lane, path, digest, file, line and text drift" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    %{records: rows} = DebuggerSettings.load_delegation!()

    source =
      Enum.find(
        rows,
        &(&1["t"] == "exact_source" and &1["lane"] == evidence.lane.name and
            &1["owner"] == "01.1.1.3.1.2")
      )

    module = source["module"]

    declaration =
      String.split(
        File.read!(
          Path.join(
            evidence.installed["debugger"],
            String.replace_prefix(source["source_path"], "debugger/", "")
          )
        ),
        "\n",
        trim: false
      )
      |> Enum.find_index(&String.contains?(&1, "-module(#{module}"))

    citation = %{line: declaration + 1, expected_text: "-module(#{module}"}

    assert DebuggerSettings.assert_remainder_source!(evidence, source, citation).origin ==
             :installed

    wrong_lane =
      Map.put(source, "lane", if(evidence.lane.name == "core", do: "floor", else: "core"))

    assert_raise ExUnit.AssertionError, ~r/exact_source row/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, wrong_lane, citation)
    end

    escaped_path = Map.put(source, "source_path", "debugger/src/../outside.erl")

    assert_raise ExUnit.AssertionError, ~r/installed source path/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, escaped_path, citation)
    end

    wrong_digest = Map.put(source, "sha256", String.duplicate("0", 64))

    assert_raise ExUnit.AssertionError, ~r/exact_source digest/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, wrong_digest, citation)
    end

    missing_source =
      source
      |> Map.put("module", "fablebook_missing_probe")
      |> Map.put("source_path", "debugger/src/fablebook_missing_probe.erl")

    assert_raise ExUnit.AssertionError, ~r/installed source read=enoent/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, missing_source, citation)
    end

    assert_raise ExUnit.AssertionError, ~r/source citation remedy=use an existing line/, fn ->
      DebuggerSettings.assert_remainder_source!(evidence, source, %{citation | line: 999_999})
    end

    assert_raise ExUnit.AssertionError,
                 ~r/source citation remedy=restore expected source text/,
                 fn ->
                   DebuggerSettings.assert_remainder_source!(evidence, source, %{
                     citation
                     | expected_text: "missing text"
                   })
                 end
  end

  @tag :debugger_remainder_ownership
  @tag :debugger_remainder_inventory
  test "remainder inventory rejects omitted functions, exports, roots and duplicate identities",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    inventory = DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, record)
    first_module = hd(inventory.modules).module
    inspection = Enum.find(ctx.graph.inspected, &(&1.module == first_module))
    [omitted_function | _] = inspection.function_mfas

    incomplete_inspection = %{
      ctx.graph
      | inspected:
          Enum.map(ctx.graph.inspected, fn current ->
            if current.module == first_module,
              do: %{current | function_mfas: List.delete(current.function_mfas, omitted_function)},
              else: current
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/function universe/, fn ->
      DebuggerSettings.assert_remainder_inventory!(incomplete_inspection, evidence, record)
    end

    [omitted_export | _] =
      Enum.filter(
        ctx.graph.full_exported,
        &(Atom.to_string(elem(&1, 0)) in inventory.module_names)
      )

    incomplete_exports = %{
      ctx.graph
      | full_exported: MapSet.delete(ctx.graph.full_exported, omitted_export)
    }

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_inventory!(incomplete_exports, evidence, record)
    end

    loaded = DebuggerSettings.load_delegation!()

    omitted_root_rows =
      Enum.reject(loaded.records, fn row ->
        row["t"] == "root" and row["lane"] == evidence.lane.name and
          row["owner"] == "01.1.1.3.1.2"
      end)

    omitted_root_record =
      Map.merge(record, %{
        delegation_metadata: loaded.metadata,
        delegation_records: omitted_root_rows
      })

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, omitted_root_record)
    end

    [first_row | _] = loaded.records

    duplicated_record =
      Map.merge(record, %{
        delegation_metadata: loaded.metadata,
        delegation_records: loaded.records ++ [first_row]
      })

    assert_raise ExUnit.AssertionError, ~r/duplicate typed identities/, fn ->
      DebuggerSettings.assert_remainder_inventory!(ctx.graph, evidence, duplicated_record)
    end
  end

  @tag :debugger_remainder_ownership
  test "remainder source branch route edits are rejected by the current validator", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(evidence.lane.name)
    target_id = :monitor_edit_variable_term_parser
    original = Enum.find(record.source_branches, &(&1.id == target_id))
    assert original != nil

    forged = %{
      record
      | source_branches:
          Enum.map(record.source_branches, fn branch ->
            if branch.id == target_id,
              do: %{branch | trace: "forged route with no source link"},
              else: branch
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/branch route trace/, fn ->
      DebuggerSettings.assert_function_dispositions!(
        ctx.graph,
        evidence,
        forged,
        :monitor
      )
    end
  end

  @tag :debugger_remainder_ownership
  @tag timeout: 180_000
  test "current remainder functions, roots, branches, guards and exclusions reconcile", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    lane = evidence.lane.name
    record = DebuggerSettings.records(lane)

    group_results =
      Enum.map([:callbacks, :interpreter, :monitor, :trace], fn group ->
        result =
          DebuggerSettings.assert_function_dispositions!(
            ctx.graph,
            evidence,
            record,
            group
          )

        assert result.status == :verified
        {group, result}
      end)

    inventory = hd(group_results) |> elem(1) |> Map.fetch!(:inventory)

    function_dispositions =
      Enum.flat_map(group_results, fn {_group, result} ->
        Enum.flat_map(result.modules, & &1.dispositions)
      end)

    expected_function_names =
      inventory.modules
      |> Enum.flat_map(& &1.functions)
      |> MapSet.new()

    actual_function_names = MapSet.new(function_dispositions, & &1.mfa)

    assert length(function_dispositions) == MapSet.size(actual_function_names)
    assert actual_function_names == expected_function_names

    pending_function_names =
      MapSet.new([
        "dbg_icmd:break_p/4",
        "dbg_wx_mon:start/2",
        "dbg_wx_mon:load_settings/2",
        "dbg_wx_mon:load_settings2/2"
      ])

    actual_pending_function_names =
      function_dispositions
      |> Enum.filter(&(&1.completion == :pending_cross_owner))
      |> Enum.map(& &1.mfa)
      |> MapSet.new()

    assert actual_pending_function_names == pending_function_names

    assert Enum.all?(function_dispositions, fn disposition ->
             if disposition.mfa in pending_function_names do
               disposition.owner == "01.1.1.3.1.1" and
                 disposition.completion == :pending_cross_owner
             else
               disposition.owner == "01.1.1.3.1.2" and
                 disposition.completion == :source_disposed_static
             end
           end)

    tier = BannedCalls.banned_mfas()
    assert MapSet.subset?(MapSet.new(@debugger_remainder_guard_mfas), MapSet.new(tier))

    guarded_modules = MapSet.new(@debugger_remainder_guard_mfas, &elem(&1, 0))

    refute Enum.any?(tier, fn {module, function, arity} ->
             module in guarded_modules and function == :_ and arity == :_
           end),
           "the remainder routes must stay function-scoped rather than module-wide"

    debugger_roots =
      (inventory.original_roots ++ inventory.observed_roots)
      |> Enum.filter(&(&1["app"] == "debugger"))

    root_names =
      MapSet.new(debugger_roots, fn root ->
        {root["module"], root["function"], root["arity"]}
      end)

    graph_root_names =
      ctx.graph.pending_mfas
      |> Enum.filter(fn {module, function, arity} ->
        MapSet.member?(root_names, {Atom.to_string(module), Atom.to_string(function), arity})
      end)
      |> MapSet.new(fn {module, function, arity} ->
        {Atom.to_string(module), Atom.to_string(function), arity}
      end)

    assert graph_root_names == root_names

    function_mfas =
      ctx.graph.inspected
      |> Enum.filter(&(&1.app == "debugger" and &1.module in inventory.module_names))
      |> Enum.flat_map(& &1.function_mfas)
      |> MapSet.new()

    root_mfas =
      Enum.filter(ctx.graph.pending_mfas, fn {module, function, arity} ->
        MapSet.member?(root_names, {Atom.to_string(module), Atom.to_string(function), arity})
      end)

    branch_mfas = MapSet.new(record.source_branches, & &1.mfa)
    exclusion_universe = MapSet.new() |> MapSet.union(function_mfas)
    exclusion_universe = MapSet.union(exclusion_universe, MapSet.new(root_mfas))
    exclusion_universe = MapSet.union(exclusion_universe, branch_mfas)
    exclusion_universe_list = MapSet.to_list(exclusion_universe) |> Enum.sort()

    exclusion_matches = DebuggerSettings.exclusion_matches(exclusion_universe_list, @exclusions)

    assert :ok ==
             DebuggerSettings.assert_exclusion_witnesses!(
               exclusion_matches,
               ctx.graph,
               tier,
               BannedCalls.banned_names(),
               @exclusions
             )

    exact_injected =
      {{:mfa, {:dbg_wx_mon, :start, 2}}, :injected_exact_control,
       ["synthetic exact-exclusion control"]}

    [exact_match] = DebuggerSettings.exclusion_matches(exclusion_universe_list, [exact_injected])
    assert exact_match.matched_mfas == [{:dbg_wx_mon, :start, 2}]

    assert_raise ExUnit.AssertionError, ~r/no individual active removal witness/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        [exact_match],
        ctx.graph,
        tier,
        BannedCalls.banned_names(),
        [exact_injected]
      )
    end

    broad_injected = {{:dbg_wx_mon, :_}, :injected_broad_control, ["synthetic broad control"]}

    [broad_match | _] =
      DebuggerSettings.exclusion_matches(exclusion_universe_list, [broad_injected])

    assert_raise ExUnit.AssertionError, ~r/blanket or non-exact/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        [broad_match],
        ctx.graph,
        tier,
        BannedCalls.banned_names(),
        [broad_injected]
      )
    end

    incomplete_match = %{broad_match | matched_mfas: []}

    assert_raise ExUnit.AssertionError, ~r/incomplete matches/, fn ->
      DebuggerSettings.assert_exclusion_witnesses!(
        [incomplete_match],
        ctx.graph,
        tier,
        BannedCalls.banned_names(),
        [broad_injected]
      )
    end

    assert inventory.status == :verified
    assert inventory.module_names == Enum.sort(DebuggerSettings.required_source_modules())

    selected_root_ids =
      MapSet.new(record.roots, fn %{mfa: {module, function, arity}} ->
        {"debugger", Atom.to_string(module), Atom.to_string(function), arity}
      end)

    assert MapSet.new(inventory.selected_roots) == selected_root_ids

    if audit_path = System.get_env("FABLEBOOK_REMAINDER_AUDIT_OUT") do
      summary = %{
        lane: lane,
        module_count: length(inventory.modules),
        function_count: MapSet.size(expected_function_names),
        export_count: Enum.sum(Enum.map(inventory.modules, & &1.export_count)),
        original_root_count: length(inventory.original_roots),
        observed_root_count: length(inventory.observed_roots),
        newly_owned_observation_count: length(inventory.new_owned_observations),
        interpreter_root_observation_count: length(inventory.interpreter_root_observations),
        overlap_count: length(inventory.overlaps),
        overlap_occurrence_count: inventory.overlap_occurrence_count,
        source_branch_count: length(record.source_branches),
        function_completion_pending_count: MapSet.size(pending_function_names),
        function_completion_static_count:
          Enum.count(function_dispositions, &(&1.completion == :source_disposed_static)),
        unresolved_dynamic_counts:
          Map.new(group_results, fn {group, result} ->
            {Atom.to_string(group), length(result.unresolved_dynamic)}
          end),
        guard_entry_count: length(@debugger_remainder_guard_mfas),
        exclusion_universe_count: length(exclusion_universe_list),
        exclusion_match_count: length(exclusion_matches),
        exclusion_matches:
          Enum.map(exclusion_matches, fn match ->
            %{
              matcher: inspect(match.original_identity),
              matched_mfas: Enum.map(match.matched_mfas, &inspect/1)
            }
          end)
      }

      File.write!(audit_path, JSON.encode!(summary))
    end
  end

  @tag :saved_settings_audit
  test "deferred callback routes have distinct source branch identities" do
    assert Code.ensure_loaded?(DebuggerSettings)
    branch_ids = DebuggerSettings.branch_ids() |> MapSet.new()

    required =
      MapSet.new([
        :auto_attach_init_event,
        :auto_attach_break_event,
        :auto_attach_exit_event,
        :auto_attach_event_match_spawn,
        :auto_attach_event_nonmatch_ignore,
        :auto_attach_already_attached_ignore,
        :conditional_callback_clause,
        :condition_user_eval_suppressed,
        :condition_null_true,
        :condition_tuple_callback,
        :condition_callback_exception_false,
        :condition_action_disable,
        :condition_action_delete
      ])

    assert MapSet.subset?(required, branch_ids),
           "deferred callback source disposition is missing #{inspect(MapSet.to_list(MapSet.difference(required, branch_ids)))}"
  end

  @tag :debugger_remainder_ownership
  @tag :saved_settings_ownership
  test "saved-settings ownership resolves selected and remainder identities from the live lane",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    record = DebuggerSettings.records(ctx.graph.lane.name)
    ownership = DebuggerSettings.assert_ownership!(ctx.graph, evidence, record)
    control_names = DebuggerSettings.ownership_controls!(ctx.graph, evidence, record)

    expected_controls = [
      "missing-selected-module-original:rejected",
      "missing-selected-module-observed:rejected",
      "missing-remainder-module-original:rejected",
      "missing-remainder-module-observed:rejected",
      "missing-selected-root-original:rejected",
      "missing-selected-root-observed:rejected",
      "missing-remainder-root-original:rejected",
      "missing-remainder-root-observed:rejected",
      "duplicate-canonical-root:rejected",
      "wrong-selected-owner:rejected",
      "wrong-remainder-owner:rejected",
      "wrong-observed-remainder-owner:rejected",
      "wrong-remainder-root-owner:rejected",
      "changed-canonical-chain:rejected",
      "changed-observed-canonical-chain:rejected",
      "changed-current-reference:rejected",
      "missing-overlap-occurrence:rejected",
      "missing-source-branch:rejected",
      "forged-source-branch-completion:rejected",
      "missing-observed-root-delta:rejected",
      "empty-settings-audit:rejected",
      "changed-settings-source-digest:rejected",
      "escaping-settings-citation:rejected",
      "graph-new-settings-export:rejected",
      "graph-new-debugger-root:rejected",
      "graph-omitted-debugger-beam:rejected",
      "graph-omitted-debugger-export:rejected",
      "graph-omitted-active-baseline:rejected"
    ]

    assert Enum.sort(control_names) == Enum.sort(expected_controls)

    if audit_path = System.get_env("FABLEBOOK_SETTINGS_AUDIT_OUT") do
      File.write!(
        audit_path,
        JSON.encode!(%{
          "lane" => ctx.graph.lane.name,
          "receipt_sha256" => ownership.receipt_sha256,
          "pending_observed_delta_count" => ownership.pending_observed_delta_count,
          "observations" => ownership.observations
        }) <> "\n"
      )
    end

    owners = DebuggerPendingOwnership.owners()

    assert MapSet.new(Map.values(owners)) == MapSet.new(["01.1.1.3.1.2"]),
           "pending debugger modules must resolve to current remainder owner 01.1.1.3.1.2"

    assert :ok = DebuggerPendingOwnership.assert_valid!(owners)
    assert ownership.status == :verified
    assert ownership.selected_module == :dbg_wx_settings
    assert length(ownership.selected_roots) == 3
    assert ownership.remainder_module_count == 20
    assert ownership.remainder_root_count == if(ctx.graph.lane.name == "core", do: 233, else: 224)

    module_app = Map.new(ctx.graph.ingested, &{&1.module_atom, &1.app})

    active_debugger_modules =
      ctx.graph.active_modules
      |> Enum.filter(&(Map.get(module_app, &1) == "debugger"))
      |> MapSet.new()

    assert active_debugger_modules ==
             MapSet.new(@debugger_baseline_active_modules ++ [:dbg_wx_settings]),
           "the audited settings module must be the sole addition to the earlier three-module debugger seed"

    pending_debugger_modules =
      ctx.graph.pending_modules
      |> Enum.filter(&(&1.app == "debugger"))
      |> MapSet.new(& &1.module_atom)

    assert MapSet.subset?(
             MapSet.new([:dbg_wx_mon, :dbg_iserver, :dbg_icmd, :debugger]),
             pending_debugger_modules
           ),
           "broad monitor, server, command, and debugger modules remain pending with 01.1.1.3.1.2"

    selected_root_observations =
      Enum.filter(ownership.observations, fn row ->
        identity = row["identity"]

        identity["module"] == "dbg_wx_mon" and
          identity["function"] in ["start", "load_settings", "load_settings2"]
      end)

    assert length(selected_root_observations) == 6
    assert ownership.pending_observed_delta_count > 0

    new_root_observations =
      Enum.filter(ownership.observations, fn row ->
        row["identity"]["kind"] == "root" and is_nil(row["origin_record_sha256"])
      end)

    assert new_root_observations != []

    assert Enum.all?(
             new_root_observations,
             &(&1["owner"] == "01.1.1.3.1.2" and &1["completion"] == "pending")
           )

    assert Enum.count(
             ownership.observations,
             &(&1["completion"] == "selected_settings_functions_exports_and_source_verified")
           ) == 2
  end

  @tag :saved_settings_receipt
  test "saved-settings receipt acceptance binds the live graph to current source and ownership",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    records = DebuggerSettings.records(ctx.graph.lane.name)
    receipt_lines = ctx.graph.receipt_lines

    assert function_exported?(DebuggerSettings, :assert_receipt!, 4),
           "expected a public validator for the current lane's installed receipt"

    ownership =
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, receipt_lines)

    assert ownership.status == :verified
    assert ownership.lane == ctx.graph.lane.name

    assert ownership.receipt_sha256 ==
             InstalledOtp.verify_receipt_lines!(receipt_lines).sha256

    assert ownership.selected_module == :dbg_wx_settings
    assert ownership.remainder_module_count == 20

    assert_raise InstalledOtp.Error, fn ->
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, [])
    end

    other_lane = if ctx.graph.lane.name == "core", do: "floor", else: "core"

    wrong_lane =
      rewrite_settings_meta_receipt(receipt_lines, &Map.put(&1, "lane", other_lane))

    assert_raise InstalledOtp.Error, fn ->
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, wrong_lane)
    end

    wrong_lock =
      rewrite_settings_receipt(receipt_lines, fn [meta | rest] ->
        [Map.put(meta, "lock_sha256", String.duplicate("0", 64)) | rest]
      end)

    assert_raise InstalledOtp.Error, fn ->
      DebuggerSettings.assert_receipt!(ctx.graph, evidence, records, wrong_lock)
    end

    wrong_source_records = Map.put(records, :source_sha256, String.duplicate("0", 64))

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_receipt!(
        ctx.graph,
        evidence,
        wrong_source_records,
        receipt_lines
      )
    end
  end

  @tag :debugger_remainder_receipt
  test "remainder receipt acceptance binds the fresh graph to complete current dispositions",
       ctx do
    test_started = System.monotonic_time(:millisecond)

    assert function_exported?(DebuggerSettings, :assert_remainder_receipt!, 4),
           "expected a remainder validator that starts from the fresh graph receipt"

    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    records = DebuggerSettings.records(ctx.graph.lane.name)
    receipt_lines = ctx.graph.receipt_lines

    result =
      DebuggerSettings.assert_remainder_receipt!(ctx.graph, evidence, records, receipt_lines)

    assert result.status == :verified
    assert result.lane == ctx.graph.lane.name
    assert result.owner == "01.1.1.3.1.2"
    assert result.selected_module == :dbg_wx_settings
    assert result.remainder_module_count == 20
    assert map_size(result.source_sha256) == result.remainder_module_count
    assert result.original_root_count >= 3
    assert result.observed_root_count == result.original_root_count
    assert result.receipt_sha256 == receipt_footer_sha256!(receipt_lines)

    assert result.inherited_pending == %{
             callback_body: "dbg_icmd:break_p/4",
             selected_roots: [
               "dbg_wx_mon:load_settings/2",
               "dbg_wx_mon:load_settings2/2",
               "dbg_wx_mon:start/2"
             ]
           }

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_receipt!(ctx.graph, evidence, records, [])
    end

    other_lane = if ctx.graph.lane.name == "core", do: "floor", else: "core"

    wrong_lane = rewrite_settings_meta_receipt(receipt_lines, &Map.put(&1, "lane", other_lane))

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_receipt!(ctx.graph, evidence, records, wrong_lane)
    end

    wrong_runtime =
      rewrite_settings_meta_receipt(receipt_lines, &Map.put(&1, "elixir", "0.0.0"))

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_receipt!(ctx.graph, evidence, records, wrong_runtime)
    end

    wrong_lock =
      rewrite_settings_meta_receipt(
        receipt_lines,
        &Map.put(&1, "lock_sha256", String.duplicate("0", 64))
      )

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_receipt!(ctx.graph, evidence, records, wrong_lock)
    end

    wrong_source_records = Map.put(records, :source_sha256, String.duplicate("0", 64))

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_receipt!(
        ctx.graph,
        evidence,
        wrong_source_records,
        receipt_lines
      )
    end

    assert_raise ExUnit.AssertionError, fn ->
      DebuggerSettings.assert_remainder_receipt!(
        ctx.graph,
        evidence,
        Map.put(records, :delegation_records, []),
        receipt_lines
      )
    end

    if System.get_env("FABLEBOOK_MEASURE_REMAINDER_RECEIPT") == "1" do
      elapsed_ms = System.monotonic_time(:millisecond) - test_started
      IO.puts("FABLEBOOK_REMAINDER_RECEIPT_TEST_MS=#{elapsed_ms}")
    end
  end

  @tag :debugger_installed_wide_acceptance
  test "debugger installed-wide acceptance composes the current lane evidence", ctx do
    test_started = System.monotonic_time(:millisecond)
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    baseline_records = @debugger_audit
    parent_owner_records = debugger_parent_owner_records!()
    settings_records = DebuggerSettings.records(ctx.graph.lane.name)
    receipt_lines = ctx.graph.receipt_lines

    assertion_started = System.monotonic_time(:millisecond)

    result =
      assert_debugger_installed_wide_acceptance!(
        ctx.graph,
        evidence,
        baseline_records,
        parent_owner_records,
        settings_records,
        receipt_lines
      )

    assertion_ms = System.monotonic_time(:millisecond) - assertion_started
    result = Map.put(result, "assertion_ms", assertion_ms)

    current_baseline = Enum.find(baseline_records, &(&1.lane == ctx.graph.lane.name))
    assert current_baseline != nil, "expected the current lane's parent debugger baseline"
    omitted_baseline_records = List.delete(baseline_records, current_baseline)

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_installed_wide_acceptance!(
        ctx.graph,
        evidence,
        omitted_baseline_records,
        parent_owner_records,
        settings_records,
        receipt_lines
      )
    end

    current_parent_owner_index =
      Enum.find_index(parent_owner_records, fn row ->
        row["t"] == "root" and row["lane"] == ctx.graph.lane.name and
          row["app"] == "debugger" and row["module"] == "dbg_wx_interpret" and
          row["function"] == "start" and row["arity"] == 4
      end)

    assert current_parent_owner_index != nil,
           "expected the adopted current-lane dbg_wx_interpret:start/4 owner row"

    current_parent_owner = Enum.at(parent_owner_records, current_parent_owner_index)
    assert current_parent_owner["owner"] == "01.1.1.3"

    drifted_parent_owner_records =
      List.update_at(parent_owner_records, current_parent_owner_index, fn row ->
        Map.put(row, "owner", "01.1.1.3.1.2")
      end)

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_installed_wide_acceptance!(
        ctx.graph,
        evidence,
        baseline_records,
        drifted_parent_owner_records,
        settings_records,
        receipt_lines
      )
    end

    delegation = DebuggerSettings.load_delegation!()

    selected_start_index =
      Enum.find_index(delegation.records, fn row ->
        row["lane"] == ctx.graph.lane.name and row["t"] == "root" and
          row["app"] == "debugger" and row["module"] == "dbg_wx_mon" and
          row["function"] == "start" and row["arity"] == 2
      end)

    assert selected_start_index != nil,
           "expected the adopted current-lane dbg_wx_mon:start/2 root row"

    selected_start_row = Enum.at(delegation.records, selected_start_index)
    assert selected_start_row["owner"] == settings_records.owner

    drifted_delegation_records =
      List.update_at(delegation.records, selected_start_index, fn row ->
        Map.put(row, "owner", "01.1.1.3.1.2")
      end)

    drifted_start_row = Enum.at(drifted_delegation_records, selected_start_index)
    assert drifted_start_row["owner"] == "01.1.1.3.1.2"
    refute drifted_start_row["owner"] == selected_start_row["owner"]

    drifted_settings_records =
      Map.put(settings_records, :delegation_records, drifted_delegation_records)

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_installed_wide_acceptance!(
        ctx.graph,
        evidence,
        baseline_records,
        parent_owner_records,
        drifted_settings_records,
        receipt_lines
      )
    end

    result =
      result
      |> Map.put(
        "control_ms",
        System.monotonic_time(:millisecond) - assertion_started - assertion_ms
      )
      |> Map.put("test_ms", System.monotonic_time(:millisecond) - test_started)

    IO.puts("FABLEBOOK_DEBUGGER_INSTALLED_WIDE_ACCEPTANCE=#{JSON.encode!(result)}")
  end

  defp receipt_footer_sha256!(lines) do
    marker = "FABLEBOOK_OTP_INVENTORY_V2 "
    {:ok, footer} = JSON.decode(String.replace_prefix(List.last(lines), marker, ""))
    footer["sha256"]
  end

  defp rewrite_settings_receipt(lines, transform) do
    marker = "FABLEBOOK_OTP_INVENTORY_V2 "

    body =
      lines
      |> Enum.drop(-1)
      |> Enum.map(fn line ->
        {:ok, row} = JSON.decode(String.replace_prefix(line, marker, ""))
        row
      end)
      |> transform.()

    encoded = Enum.map(body, &(marker <> JSON.encode!(&1)))

    digest =
      :crypto.hash(:sha256, Enum.join(encoded, "\n") <> "\n") |> Base.encode16(case: :lower)

    {:ok, footer} = JSON.decode(String.replace_prefix(List.last(lines), marker, ""))

    encoded ++ [marker <> JSON.encode!(Map.put(footer, "sha256", digest))]
  end

  defp rewrite_settings_meta_receipt(lines, transform) do
    marker = "FABLEBOOK_OTP_INVENTORY_V2 "
    {body, [footer_line]} = Enum.split(lines, -1)
    [meta_line | records] = body
    {:ok, meta} = JSON.decode(String.replace_prefix(meta_line, marker, ""))
    encoded_body = [marker <> JSON.encode!(transform.(meta)) | records]

    digest =
      encoded_body
      |> Enum.reduce(:crypto.hash_init(:sha256), fn line, context ->
        context
        |> :crypto.hash_update(line)
        |> :crypto.hash_update("\n")
      end)
      |> :crypto.hash_final()
      |> Base.encode16(case: :lower)

    {:ok, footer} = JSON.decode(String.replace_prefix(footer_line, marker, ""))
    encoded_body ++ [marker <> JSON.encode!(Map.put(footer, "sha256", digest))]
  end

  test "debugger selected-file audit resolves its exact source, export and tier witness", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = @debugger_audit
    tier = BannedCalls.banned_mfas()

    assert_debugger_audit!(records, ctx.graph, tier, evidence, @exclusions)

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))

    assert Map.has_key?(lane_record, :family_function_audit),
           "the debugger audit must source-dispose every discovered assigned function"

    record_index = Enum.find_index(records, &(&1.original_id == lane_record.original_id))

    assert Map.get(lane_record, :branch_citations) != nil,
           "the selected-file audit must cover local/global, cancel, empty/error and parser-filter branches"

    actual_family_universe = debugger_family_universe(ctx.graph, tier, @exclusions)
    omitted_mfa = {:dbg_istk, :from_external, 1}

    source_rows_without_mfa =
      lane_record.family_function_sources
      |> Enum.reject(&(elem(&1, 0) == omitted_mfa))
      |> Enum.map(&elem(&1, 0))

    review_rows_without_mfa =
      lane_record.family_function_audit
      |> Enum.reject(&(&1.mfa == omitted_mfa))
      |> Enum.map(& &1.mfa)

    expected_rows_without_mfa = Enum.reject(@debugger_expected_family_mfas, &(&1 == omitted_mfa))

    omission_error =
      assert_raise ExUnit.AssertionError, ~r/assigned function inventory differs/, fn ->
        assert_debugger_function_inventory!(
          actual_family_universe,
          source_rows_without_mfa,
          review_rows_without_mfa,
          expected_rows_without_mfa,
          evidence.lane.name
        )
      end

    assert omission_error.message =~ "owner=plan_02"
    assert omission_error.message =~ "caller-chain="

    graph_candidates = debugger_graph_candidates(ctx.graph)
    omitted_roots = Enum.reject(@debugger_explicit_roots, &(&1 == omitted_mfa))

    root_omission_error =
      assert_raise ExUnit.AssertionError, ~r/assigned root inventory differs/, fn ->
        assert_debugger_root_inventory!(graph_candidates, omitted_roots, evidence.lane.name)
      end

    assert root_omission_error.message =~ "owner=plan_02"
    assert root_omission_error.message =~ "caller-chain="

    assert_raise ExUnit.AssertionError, ~r/active debugger slice omitted baseline modules/, fn ->
      assert_debugger_active_scope!(
        ctx.graph,
        List.delete(@debugger_active_modules, :dbg_istk),
        evidence.lane.name
      )
    end

    assert_raise ExUnit.AssertionError, ~r/pending debugger modules are active/, fn ->
      assert_debugger_active_scope!(
        %{ctx.graph | active_modules: MapSet.put(ctx.graph.active_modules, :dbg_ieval)},
        @debugger_active_modules,
        evidence.lane.name
      )
    end

    new_name_export = {:dbg_istk, :unreviewed_family_entry, 0}

    graph_with_new_name_export = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, new_name_export)
    }

    assert_raise ExUnit.AssertionError, ~r/independent installed universe/, fn ->
      assert_debugger_function_inventory!(
        debugger_family_universe(graph_with_new_name_export, tier, @exclusions),
        Enum.map(lane_record.family_function_sources, &elem(&1, 0)),
        Enum.map(lane_record.family_function_audit, & &1.mfa),
        @debugger_expected_family_mfas,
        evidence.lane.name
      )
    end

    wrong_lane_name = if evidence.lane.name == "core", do: "floor", else: "core"
    wrong_lane = %{evidence | lane: Map.put(evidence.lane, :name, wrong_lane_name)}

    assert_raise ExUnit.AssertionError, ~r/does not match inspected graph lane/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, wrong_lane, @exclusions)
    end

    missing_source_path = "#{evidence.lane.name}/debugger/src/dbg_idb.erl"

    missing_source_evidence = %{
      evidence
      | manifest:
          Map.update!(evidence.manifest, "files", fn files ->
            Enum.reject(files, &(&1["path"] == missing_source_path))
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/missing exact-lane source record/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, missing_source_evidence, @exclusions)
    end

    absent_source_evidence = %{
      evidence
      | manifest:
          Map.update!(evidence.manifest, "files", fn files ->
            Enum.map(files, fn
              %{"path" => ^missing_source_path} = row -> Map.put(row, "status", "absent")
              row -> row
            end)
          end)
    }

    assert_raise ExUnit.AssertionError, ~r/claims absence or non-present status/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, absent_source_evidence, @exclusions)
    end

    corrupt_evidence =
      SweepEvidence.load_archive!(
        Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__),
        SweepEvidence.archive_sha256()
      )
      |> Map.merge(%{lane: evidence.lane, lock_sha256: evidence.lock_sha256})

    corrupt_evidence =
      Map.put(
        corrupt_evidence,
        :installed,
        %{"debugger" => Path.join(corrupt_evidence.archive_root, "missing-installed")}
      )

    on_exit(fn -> File.rm_rf!(corrupt_evidence.archive_root) end)

    File.write!(
      Path.join(
        corrupt_evidence.archive_root,
        "#{evidence.lane.name}/debugger/src/dbg_idb.erl"
      ),
      "corrupt source bytes"
    )

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      assert_debugger_audit!(records, ctx.graph, tier, corrupt_evidence, @exclusions)
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        List.delete_at(records, record_index),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        records,
        %{
          ctx.graph
          | full_exported: MapSet.delete(ctx.graph.full_exported, @debugger_selected_file_mfa)
        },
        tier,
        evidence,
        @exclusions
      )
    end

    filter_mfa = {:dbg_wx_interpret, :filter_files, 2}

    graph_without_filter_root = %{
      ctx.graph
      | full_reached: MapSet.delete(ctx.graph.full_reached, filter_mfa),
        full_edges:
          Enum.reject(ctx.graph.full_edges, fn {caller, callee} ->
            caller == filter_mfa or callee == filter_mfa
          end)
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(records, graph_without_filter_root, tier, evidence, @exclusions)
    end

    unreviewed_export = {:dbg_wx_interpret, :unreviewed_selected_file_front, 0}

    graph_with_unreviewed_export = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, unreviewed_export)
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(records, graph_with_unreviewed_export, tier, evidence, @exclusions)
    end

    branchless_record = %{lane_record | branch_citations: %{}}

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        List.replace_at(records, record_index, branchless_record),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    missing_function_source = %{
      lane_record
      | family_function_sources: List.delete_at(lane_record.family_function_sources, 0)
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(
        List.replace_at(records, record_index, missing_function_source),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      SweepEvidence.resolve!(evidence, "debugger/src/dbg_wx_interpret.erl:999999")
    end

    omitted_tier = Enum.reject(tier, &(&1 == @debugger_selected_file_mfa))

    assert_raise ExUnit.AssertionError, fn ->
      assert_debugger_audit!(records, ctx.graph, omitted_tier, evidence, @exclusions)
    end

    omitted_decoder_tier = Enum.reject(tier, &(&1 == {:dbg_istk, :from_external, 1}))

    assert_raise ExUnit.AssertionError,
                 ~r/exported stack decoder must retain its exact MFA tier/,
                 fn ->
                   assert_debugger_audit!(
                     records,
                     ctx.graph,
                     omitted_decoder_tier,
                     evidence,
                     @exclusions
                   )
                 end

    missing_seed_disposition = %{
      lane_record
      | seed_dispositions: List.delete_at(lane_record.seed_dispositions, 0)
    }

    assert_raise ExUnit.AssertionError, ~r/omitted or invented a source-only debugger seed/, fn ->
      assert_debugger_audit!(
        List.replace_at(records, record_index, missing_seed_disposition),
        ctx.graph,
        tier,
        evidence,
        @exclusions
      )
    end

    redundant_retention =
      {{:mfa, @debugger_selected_file_mfa}, :private_front,
       [hd(lane_record.citations) |> elem(0)]}

    assert_raise ExUnit.AssertionError, ~r/changed debugger exclusion match set/, fn ->
      assert_debugger_audit!(
        records,
        ctx.graph,
        tier,
        evidence,
        @exclusions ++ [redundant_retention]
      )
    end
  end

  test "escript debugger code is a private path behind its already tiered public front", ctx do
    graph = ctx.graph
    debug_mfa = @escript_debug_mfa
    parse_and_run = {:escript, :parse_and_run, 3}
    start = {:escript, :start, 1}

    assert MapSet.member?(graph.full_reached, debug_mfa)
    refute MapSet.member?(graph.historical_reached, debug_mfa)
    refute MapSet.member?(graph.full_exported, debug_mfa)
    refute MapSet.member?(graph.full_exported, {:escript, :hidden_apply, 4})
    assert MapSet.member?(graph.full_exported, start)
    assert {:escript, :start, :_} in BannedCalls.banned_mfas()
    assert MapSet.member?(graph.historical_reached, start)

    assert(
      disposition(
        debug_mfa,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        @exclusions
      ) == :private_front
    )

    debug_callers =
      for {caller, {:escript, :debug}} <- graph.full_edges, into: MapSet.new(), do: caller

    parse_callers =
      for {caller, {:escript, :parse_and_run}} <- graph.full_edges,
          into: MapSet.new(),
          do: caller

    assert debug_callers == MapSet.new([parse_and_run])
    assert parse_callers == MapSet.new([start])

    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    expected_citations =
      Map.fetch!(@escript_debug_source_assertions_by_lane, evidence.lane.name)

    record_citations = @escript_debug_exclusion |> elem(2) |> MapSet.new()

    expected_record_citations =
      @escript_debug_source_assertions_by_lane
      |> Map.values()
      |> List.flatten()
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()

    assert record_citations == expected_record_citations

    for {citation, expected} <- expected_citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
    end

    without_private_front = List.delete(@exclusions, @escript_debug_exclusion)

    assert_raise RuntimeError, ~r/escript, :debug, 3/, fn ->
      assert_no_new_active_failures!(
        graph.full_reached,
        graph.historical_reached,
        graph.historical_active_modules,
        BannedCalls.banned_mfas(),
        BannedCalls.banned_names(),
        graph.lane.name,
        without_private_front
      )
    end
  end

  @tag :cn001
  test "original exclusion and lane metadata identities remain lossless and owned" do
    ledger = original_identity_ledger!()
    assert_original_identity_ledger!(ledger, ledger)

    assert length(ledger.exclusions) == 221

    assert Enum.frequencies_by(ledger.exclusions, & &1.table) == %{
             "CN" => 6,
             "EX" => 182,
             "BD" => 33
           }

    assert length(ledger.metadata) == 5
    assert Enum.frequencies_by(ledger.metadata, & &1.table) == %{"CN-LANE" => 1, "BD-LANE" => 4}

    sampled = Enum.filter(ledger.exclusions, &(&1.semantic_status != :pending))

    assert MapSet.new(Enum.map(sampled, & &1.id)) ==
             MapSet.new([
               "CN-001",
               "CN-002",
               "CN-003",
               "CN-004",
               "CN-005",
               "CN-006",
               "BD-002",
               "EX-159",
               "EX-165"
             ])

    assert Enum.count(ledger.exclusions, &(&1.semantic_status == :pending)) == 212

    assert Enum.all?(
             ledger.metadata,
             &(&1.owner == "01.1.1.4" and &1.semantic_status == :pending)
           )

    cn001 = Enum.find(ledger.exclusions, &(&1.id == "CN-001"))
    cn005 = Enum.find(ledger.exclusions, &(&1.id == "CN-005"))
    cn006 = Enum.find(ledger.exclusions, &(&1.id == "CN-006"))
    ex165 = Enum.find(ledger.exclusions, &(&1.id == "EX-165"))
    cn_lane_001 = Enum.find(ledger.metadata, &(&1.id == "CN-LANE-001"))

    assert cn001.identity_class == :exclusion
    assert cn_lane_001.identity_class == :lane_metadata
    assert cn_lane_001.table == "CN-LANE"
    assert cn_lane_001.original_entry_raw == "{{Mix.Compilers.Protocol, [:compile]}, :latest}"
    assert cn_lane_001.original_matcher_raw == "{Mix.Compilers.Protocol, [:compile]}"
    assert cn_lane_001.lane_payload_raw == ":latest"
    assert cn_lane_001.current_replacement_refs == ["source:CN-LANE:1"]
    refute cn001.id == cn_lane_001.id

    assert cn005.semantic_status == :calibrated_retained
    assert cn005.owner == "01.1.1.5"
    assert cn006.semantic_status == :cn006_retained
    assert cn006.owner == "01.1.1.6"
    assert cn006.current_replacement_refs == [current_call_name_ref!({:re, [:compile]})]
    assert ex165.semantic_status == :leex_replaced_by_tier
    assert ex165.owner == "01.1.1.14"
    assert ex165.original_matcher_raw == "{:leex, [:file]}"
    assert ex165.original_reason_raw == ":compiler_pass"

    assert Map.new(ex165.lane_matches, fn {lane, matches} -> {lane, MapSet.new(matches)} end) ==
             Map.new(@creator_expected_lanes, fn lane ->
               {lane, MapSet.new(["leex:file/1", "leex:file/2"])}
             end)

    assert ex165.current_replacement_refs == ["creator:EX-165:core", "creator:EX-165:floor"]

    assert Enum.all?(ledger.exclusions, fn row ->
             row.remaining_semantic_owner == "01.1.1.4" and row.current_replacement_refs != []
           end)

    assert Enum.all?(ledger.exclusions, fn row ->
             expected_owner =
               case row.id do
                 "CN-001" ->
                   "01.1.1.13"

                 id when id in ["CN-002", "CN-003", "CN-006"] ->
                   "01.1.1.6"

                 "CN-004" ->
                   "01.1.1.13"

                 id when id in ["CN-005", "BD-002", "EX-159"] ->
                   "01.1.1.5"

                 "EX-165" ->
                   "01.1.1.14"

                 _id ->
                   "01.1.1.4"
               end

             row.owner == expected_owner
           end)

    omitted = %{ledger | exclusions: List.delete_at(ledger.exclusions, 0)}

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(omitted, ledger)
    end

    omitted_lane_metadata = %{
      ledger
      | metadata: Enum.reject(ledger.metadata, &(&1.id == "CN-LANE-001"))
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(omitted_lane_metadata, ledger)
    end

    duplicate = %{ledger | exclusions: [hd(ledger.exclusions) | ledger.exclusions]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(duplicate, ledger)
    end

    same_count_substitution =
      update_in(ledger.exclusions, fn rows ->
        List.update_at(rows, 4, &%{&1 | id: "CN-999"})
      end)

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(same_count_substitution, ledger)
    end

    wrong_owner =
      update_in(ledger.exclusions, fn rows ->
        List.update_at(rows, 0, &%{&1 | owner: "01.1.1.5"})
      end)

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(wrong_owner, ledger)
    end

    wrong_payload =
      update_in(ledger.exclusions, fn rows ->
        List.update_at(rows, 0, &%{&1 | original_reason_raw: ":pure_data"})
      end)

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(wrong_payload, ledger)
    end

    metadata_as_exclusion =
      update_in(ledger.metadata, fn rows ->
        List.update_at(rows, 0, &%{&1 | identity_class: :exclusion})
      end)

    assert_raise ExUnit.AssertionError, fn ->
      assert_original_identity_ledger!(metadata_as_exclusion, ledger)
    end
  end

  test "calibration documents bind complete selected exact-lane evidence and recorded source review",
       ctx do
    root = Path.expand("../..", __DIR__)

    phase_dir =
      Path.join(
        root,
        ".planning/milestones/v0.1-phases/01.1.1.5-complete-atom-creator-fronts-and-audit-calibration"
      )

    calibration_path = Path.join(phase_dir, "01.1.1.5-CALIBRATION.md")
    validation_path = Path.join(phase_dir, "01.1.1.5-VALIDATION.md")
    summary_path = Path.join(phase_dir, "01.1.1.5-03-SUMMARY.md")
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    assert_original_identity_ledger!(ledger, ledger)

    calibration_text = File.read!(calibration_path)
    validation_text = File.read!(validation_path)
    summary_text = File.read!(summary_path)
    calibration = single_json_comment!(calibration_text, "fablebook.calibration-evidence")
    validation = single_json_comment!(validation_text, "fablebook.calibration-evidence")
    review = single_json_comment!(summary_text, "fablebook.review-effort")
    reviewed_revision = summary_reviewed_revision!(summary_text)

    assert_calibration_artifact_binding!(
      calibration,
      validation,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    lane = evidence.lane.name
    expected_mfas = expected_sample_matches!(ctx.graph, ledger, lane)

    bad_mfa =
      update_in(calibration, ["lanes", lane, "matched_mfas", "CN-005"], fn mfas ->
        ["Elixir.Regex:compile/999" | tl(mfas)]
      end)

    expect_calibration_rejected!(
      bad_mfa,
      bad_mfa,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_source =
      update_in(calibration, ["lanes", lane, "sources", Access.at(0)], fn source ->
        %{source | "path" => "kernel/src/not-the-matched-source.erl"}
      end)

    expect_calibration_rejected!(
      bad_source,
      bad_source,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_total =
      put_in(
        calibration,
        ["lanes", lane, "source_bytes"],
        calibration["lanes"][lane]["source_bytes"] + 1
      )

    expect_calibration_rejected!(
      bad_total,
      bad_total,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_runtime = put_in(calibration, ["lanes", lane, "otp"], "0.0.0")

    expect_calibration_rejected!(
      bad_runtime,
      bad_runtime,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    ref_index =
      Enum.find_index(
        calibration["lanes"][lane]["evidence_refs"],
        &String.starts_with?(&1, "source:")
      )

    bad_ref =
      update_in(calibration, ["lanes", lane, "evidence_refs", Access.at(ref_index)], fn _ ->
        "source:kernel/src/missing.erl:1"
      end)

    expect_calibration_rejected!(
      bad_ref,
      bad_ref,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_review_ref =
      update_in(calibration, ["lanes", lane, "evidence_refs"], fn refs ->
        Enum.map(
          refs,
          &String.replace(
            &1,
            "01.1.1.5-03-SUMMARY.md#fablebook.review-effort/",
            "missing.md#fablebook.review-effort/"
          )
        )
      end)

    expect_calibration_rejected!(
      bad_review_ref,
      bad_review_ref,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    assert_raise ExUnit.AssertionError, ~r/exactly one fablebook\.review-effort marker/, fn ->
      single_json_comment!(
        String.replace(summary_text, ~r/^<!-- fablebook\.review-effort: .* -->\n?/m, ""),
        "fablebook.review-effort"
      )
    end

    assert_raise ExUnit.AssertionError, ~r/valid JSON/, fn ->
      single_json_comment!(
        String.replace(
          summary_text,
          ~r/(?<=fablebook\.review-effort: ).*(?= -->)/,
          "{malformed}"
        ),
        "fablebook.review-effort"
      )
    end

    core_intervals = review["lanes"]["core"]["intervals"]

    overlapped_review =
      put_in(
        review,
        ["lanes", "core", "intervals", Access.at(1), "start_ns"],
        hd(core_intervals)["end_ns"] - 1
      )

    expect_calibration_rejected!(
      calibration,
      validation,
      overlapped_review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    incomplete_review =
      update_in(review, ["lanes", "core", "intervals", Access.at(0), "sample_ids"], fn ids ->
        List.delete(ids, "EX-159")
      end)

    expect_calibration_rejected!(
      calibration,
      validation,
      incomplete_review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_archive =
      put_in(
        review,
        ["lanes", lane, "provenance", "source_archive_sha256"],
        String.duplicate("0", 64)
      )

    expect_calibration_rejected!(
      calibration,
      validation,
      bad_archive,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_source_digest =
      put_in(
        review,
        ["lanes", lane, "provenance", "source_set_sha256"],
        String.duplicate("0", 64)
      )

    expect_calibration_rejected!(
      calibration,
      validation,
      bad_source_digest,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_review_seconds =
      put_in(
        calibration,
        ["lanes", lane, "review_seconds"],
        calibration["lanes"][lane]["review_seconds"] + 1.0
      )

    expect_calibration_rejected!(
      bad_review_seconds,
      bad_review_seconds,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    bad_review_method = put_in(calibration, ["lanes", lane, "review_method"], "CI and wait time")

    expect_calibration_rejected!(
      bad_review_method,
      bad_review_method,
      review,
      reviewed_revision,
      ctx.graph,
      evidence,
      ledger,
      root
    )

    assert Map.new(expected_mfas) == calibration["lanes"][lane]["matched_mfas"]
  end

  test "CN-005 and BD-002 audit complete exact-lane matchers with source-backed removal witnesses",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    records = calibration_records!(ctx.graph, evidence, ledger)

    assert_calibration_records!(records, ctx.graph, evidence, ledger)
    assert Enum.count(records, &(&1.original_id == "CN-005")) == 1
    assert Enum.count(records, &(&1.original_id == "BD-002")) == 1
    assert Enum.all?(records, &(&1.removal_witness != [] and &1.overlap_mfas == []))

    lane_record = Enum.find(records, &(&1.original_id == "CN-005"))
    omitted_match = %{lane_record | matched_mfas: tl(lane_record.matched_mfas)}

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          omitted_match
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end

    omitted_arity =
      Map.update!(lane_record, :matched_mfas, fn mfas ->
        Enum.map(mfas, fn
          "Elixir.Regex:compile/2" -> "Elixir.Regex:compile/1"
          mfa -> mfa
        end)
      end)

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          omitted_arity
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end

    wrong_lane = %{lane_record | lane: if(lane_record.lane == "core", do: "floor", else: "core")}

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          wrong_lane
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end

    missing_citation = %{lane_record | citations: tl(lane_record.citations)}

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          missing_citation
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end

    false_safe = %{lane_record | verdict: "caller-controlled text is safe"}

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          false_safe
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end

    vacuous_witness = %{lane_record | removal_witness: []}

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          vacuous_witness
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end

    overlap = %{lane_record | overlap_mfas: lane_record.matched_mfas}

    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_records!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.original_id == "CN-005")),
          overlap
        ),
        ctx.graph,
        evidence,
        ledger
      )
    end
  end

  test "EX-165 core caller path resolves to Leex filename and action atom sinks" do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)

    caller_sources =
      Enum.filter(
        evidence.manifest["files"],
        &(&1["source_path"] == "mix/lib/mix/tasks/compile.leex.ex")
      )

    assert Enum.map(caller_sources, & &1["lane"]) |> Enum.sort() == ~w(core floor)

    archive_only_core = %{
      evidence
      | lane: %{evidence.lane | name: "core"},
        installed:
          evidence.installed
          |> Map.put("mix", Path.join(evidence.archive_root, "missing-mix"))
          |> Map.put("parsetools", Path.join(evidence.archive_root, "missing-parsetools"))
    }

    citations = Map.fetch!(@leex_source_assertions_by_lane, "core")

    for {citation, expected_line} <- citations do
      source = SweepEvidence.resolve!(archive_only_core, citation)
      assert source.origin == :archive, citation
      assert source.text =~ expected_line, citation
    end
  end

  test "EX-165 retains its exact lane sets with source-backed Leex tier replacements", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &(&1.original_id == "EX-165"))
    ledger = original_identity_ledger!()
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    exclusions = @exclusions

    assert_leex_audit!(records, ctx.graph, tier, names, evidence, ledger, exclusions)

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(
        Enum.reject(records, &(&1.original_id == "EX-165" and &1.lane == "core")),
        ctx.graph,
        tier,
        names,
        evidence,
        ledger,
        exclusions
      )
    end

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))
    record_index = Enum.find_index(records, &(&1.lane == lane_record.lane))
    without_file_two = %{lane_record | matched_mfas: [{:leex, :file, 1}]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(
        List.replace_at(records, record_index, without_file_two),
        ctx.graph,
        tier,
        names,
        evidence,
        ledger,
        exclusions
      )
    end

    without_verdict = %{lane_record | verdict: nil}

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(
        List.replace_at(records, record_index, without_verdict),
        ctx.graph,
        tier,
        names,
        evidence,
        ledger,
        exclusions
      )
    end

    other_lane = if evidence.lane.name == "core", do: "floor", else: "core"
    wrong_lane_citation = hd(Map.fetch!(@leex_source_assertions_by_lane, other_lane))

    wrong_lane_record = %{
      lane_record
      | citations: [wrong_lane_citation | Enum.drop(lane_record.citations, 1)]
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(
        List.replace_at(records, record_index, wrong_lane_record),
        ctx.graph,
        tier,
        names,
        evidence,
        ledger,
        exclusions
      )
    end

    missing_identity = %{
      ledger
      | exclusions: Enum.reject(ledger.exclusions, &(&1.id == "EX-165"))
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(records, ctx.graph, tier, names, evidence, missing_identity, exclusions)
    end

    for mfa <- @leex_expected_mfas do
      tier_without_mfa = Enum.reject(tier, &(&1 == mfa))

      assert_raise ExUnit.AssertionError, fn ->
        assert_leex_audit!(
          records,
          ctx.graph,
          tier_without_mfa,
          names,
          evidence,
          ledger,
          exclusions
        )
      end
    end

    overlap = {{:mfa, hd(@leex_expected_mfas)}, :callback, "test-only overlap"}

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(records, ctx.graph, tier, names, evidence, ledger, [overlap | exclusions])
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_leex_audit!(records, ctx.graph, tier, [:file | names], evidence, ledger, exclusions)
    end
  end

  @tag :generator_dispatch_011118
  test "EX-107 keeps its full lane unions while tracing the bounded ASN.1 table slice", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    tier = BannedCalls.banned_mfas()

    assert_asn1_table_audit!(ctx.graph, evidence, ledger, tier)
    assert_asn1_parser_tokenizer_audit!(ctx.graph, evidence, ledger, tier)
    assert_asn1_external_transform_audit!(ctx.graph, evidence, ledger, tier)
    assert_asn1_generator_dispatch_audit!(ctx.graph, evidence, ledger, tier)
  end

  @tag :inets_trace_core_only
  @tag :inets_trace_core_source
  test "EX-010 records exact core source evidence without closing callback ownership", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    record = Fablebook.Test.InetsTraceCoreEvidence.record()
    ledger = original_identity_ledger!()
    original = Enum.find(ledger.exclusions, &(&1.id == "EX-010"))

    assert record.lane == "core"
    assert record.original_id == original.id
    assert record.owner == original.owner
    assert record.semantic_status == original.semantic_status
    assert record.owner == "01.1.1.4"
    assert record.semantic_status == :pending
    assert original.original_matcher_raw =~ "enable_trace"
    assert Enum.map(record.selected_function_evidence, & &1.mfa) == record.matched_mfas
    assert MapSet.new(record.matched_mfas) |> MapSet.subset?(ctx.graph.full_exported)
    assert record.remainder_mfas == []
    assert record.incoming_edges == []

    expected_delegates = [
      {{:inets, :enable_trace, 2}, {:inets_trace, :enable, 2}},
      {{:inets, :enable_trace, 3}, {:inets_trace, :enable, 3}}
    ]

    assert Enum.map(record.delegate_edges, &{&1.caller, &1.callee}) == expected_delegates

    graph_delegates =
      MapSet.new(expected_delegates, fn {caller, {module, function, _arity}} ->
        {caller, {module, function}}
      end)

    assert graph_delegates |> MapSet.subset?(MapSet.new(ctx.graph.full_edges))

    exact_sources =
      Map.new(record.exact_sources, fn {path, bytes, sha} -> {path, {bytes, sha}} end)

    assert map_size(exact_sources) == 3

    archive_only = %{
      evidence
      | installed:
          evidence.installed
          |> Map.put("inets", Path.join(evidence.archive_root, "missing-inets"))
          |> Map.put("runtime_tools", Path.join(evidence.archive_root, "missing-runtime-tools"))
    }

    assert_inets_trace_core_evidence!(record, ctx.graph, evidence, archive_only)

    permuted_graph = %{
      ctx.graph
      | full_exported: Enum.reverse(ctx.graph.full_exported),
        full_edges: Enum.reverse(ctx.graph.full_edges)
    }

    permuted_manifest = %{
      evidence
      | manifest: Map.update!(evidence.manifest, "files", &Enum.reverse/1)
    }

    assert_inets_trace_core_evidence!(record, permuted_graph, permuted_manifest, archive_only)

    for review <- record.reviews do
      {bytes, sha} = Map.fetch!(exact_sources, review.source_path)
      assert {review.bytes, review.sha256} == {bytes, sha}
      assert review.reviewed_lines == 1..Range.size(review.reviewed_lines)

      source_row =
        Enum.find(evidence.manifest["files"], fn row ->
          row["lane"] == record.lane and row["source_path"] == review.source_path
        end)

      assert source_row["status"] == "present"
      assert {source_row["bytes"], source_row["sha256"]} == {bytes, sha}

      for {citation, expected_line} <- review.citations do
        resolved = SweepEvidence.resolve!(archive_only, citation)
        assert resolved.origin == :archive
        assert resolved.sha256 == sha
        assert resolved.line in review.reviewed_lines
        assert resolved.text =~ expected_line
      end
    end

    assert Enum.all?(record.selected_function_evidence, fn selected ->
             selected.disposition == :retained_callback_front_pending_integration and
               is_binary(selected.callback_boundary) and byte_size(selected.callback_boundary) > 0 and
               is_binary(selected.fixed_native_boundary) and
               byte_size(selected.fixed_native_boundary) > 0
           end)
  end

  @tag :inets_trace_floor_source
  test "EX-010 records exact floor source evidence without closing callback ownership", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    record = Fablebook.Test.InetsTraceFloorEvidence.record()
    ledger = original_identity_ledger!()
    original = Enum.find(ledger.exclusions, &(&1.id == "EX-010"))

    assert record.lane == "floor"
    assert record.original_id == original.id
    assert record.owner == original.owner
    assert record.semantic_status == original.semantic_status
    assert record.owner == "01.1.1.4"
    assert record.semantic_status == :pending
    assert original.original_matcher_raw =~ "enable_trace"
    assert Enum.map(record.selected_function_evidence, & &1.mfa) == record.matched_mfas
    assert MapSet.new(record.matched_mfas) |> MapSet.subset?(ctx.graph.full_exported)
    assert record.remainder_mfas == []
    assert record.incoming_edges == []

    delegates = [
      {{:inets, :enable_trace, 2}, {:inets_trace, :enable, 2}},
      {{:inets, :enable_trace, 3}, {:inets_trace, :enable, 3}}
    ]

    assert Enum.map(record.delegate_edges, &{&1.caller, &1.callee}) == delegates

    graph_delegates =
      MapSet.new(delegates, fn {caller, {module, function, _arity}} ->
        {caller, {module, function}}
      end)

    assert graph_delegates |> MapSet.subset?(MapSet.new(ctx.graph.full_edges))

    archive_only = %{
      evidence
      | installed:
          evidence.installed
          |> Map.put("inets", Path.join(evidence.archive_root, "missing-inets"))
          |> Map.put("runtime_tools", Path.join(evidence.archive_root, "missing-runtime-tools"))
    }

    assert_inets_trace_floor_sources!(record, ctx.graph, evidence, archive_only)

    permuted_graph = %{
      ctx.graph
      | full_exported: Enum.reverse(ctx.graph.full_exported),
        full_edges: Enum.reverse(ctx.graph.full_edges)
    }

    permuted_manifest = %{
      evidence
      | manifest: Map.update!(evidence.manifest, "files", &Enum.reverse/1)
    }

    assert_inets_trace_floor_sources!(record, permuted_graph, permuted_manifest, archive_only)

    assert_raise ExUnit.AssertionError, ~r/lane mismatch/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | lane: "core"},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor exact source identities changed/, fn ->
      changed_sources = put_elem(hd(record.exact_sources), 2, String.duplicate("0", 64))

      assert_inets_trace_floor_sources!(
        %{record | exact_sources: [changed_sources | tl(record.exact_sources)]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor selected source findings changed/, fn ->
      [first | rest] = record.selected_function_evidence

      assert_inets_trace_floor_sources!(
        %{
          record
          | selected_function_evidence: [%{first | finding: "unsupported body claim"} | rest]
        },
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor live matcher coverage changed/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | matched_mfas: tl(record.matched_mfas)},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor delegate edge evidence changed/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | delegate_edges: tl(record.delegate_edges)},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    ex011 = Enum.find(ledger.exclusions, &(&1.id == "EX-011"))
    assert ex011.owner == "01.1.1.4"
    assert ex011.semantic_status == :pending
  end

  @tag :inets_trace_floor_controls
  @tag :tmp_dir
  test "EX-010 floor findings have individual exclusion-removal witnesses",
       %{tmp_dir: dir} = ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    record = Fablebook.Test.InetsTraceFloorEvidence.record()

    archive_only = %{
      evidence
      | installed:
          evidence.installed
          |> Map.put("inets", Path.join(evidence.archive_root, "missing-inets"))
          |> Map.put("runtime_tools", Path.join(evidence.archive_root, "missing-runtime-tools"))
    }

    assert_inets_trace_floor_witnesses!(record, ctx.graph)
    assert dir != nil

    permuted_graph = %{ctx.graph | full_exported: Enum.reverse(ctx.graph.full_exported)}
    assert :ok == assert_inets_trace_floor_witnesses!(record, permuted_graph)

    assert_raise ExUnit.AssertionError, ~r/floor matcher witness lane changed/, fn ->
      assert_inets_trace_floor_witnesses!(%{record | lane: "core"}, ctx.graph)
    end

    assert_raise ExUnit.AssertionError, ~r/complete live matcher set changed/, fn ->
      assert_inets_trace_floor_witnesses!(
        %{record | matched_mfas: tl(record.matched_mfas)},
        ctx.graph
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor selected matcher identity\/order changed/, fn ->
      assert_inets_trace_floor_witnesses!(
        %{record | matched_mfas: Enum.reverse(record.matched_mfas)},
        ctx.graph
      )
    end

    assert_raise ExUnit.AssertionError, ~r/duplicate floor matcher MFA/, fn ->
      assert_inets_trace_floor_witnesses!(
        %{record | matched_mfas: record.matched_mfas ++ [hd(record.matched_mfas)]},
        ctx.graph
      )
    end

    assert_raise ExUnit.AssertionError, ~r/individual removal witness evidence changed/, fn ->
      [first | rest] = record.individual_exclusion_witnesses

      assert_inets_trace_floor_witnesses!(
        %{
          record
          | individual_exclusion_witnesses: [%{first | removed_matcher_exposes_mfa: false} | rest]
        },
        ctx.graph
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor review citation evidence changed/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | reviews: tl(record.reviews)},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor review citation evidence changed/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | reviews: record.reviews ++ [hd(record.reviews)]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor exact source identities changed/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | exact_sources: tl(record.exact_sources)},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/floor exact source identities changed/, fn ->
      assert_inets_trace_floor_sources!(
        %{record | exact_sources: record.exact_sources ++ [hd(record.exact_sources)]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    [first_review | other_reviews] = record.reviews
    [first_citation | other_citations] = first_review.citations

    assert_raise ExUnit.AssertionError, ~r/floor review citation evidence changed/, fn ->
      altered_review = %{
        first_review
        | citations: [{elem(first_citation, 0), "unsupported cited body"} | other_citations]
      }

      assert_inets_trace_floor_sources!(
        %{record | reviews: [altered_review | other_reviews]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    [first_finding | other_findings] = record.selected_function_evidence
    [first_citation | other_citations] = first_finding.citations

    assert_raise ExUnit.AssertionError, ~r/floor selected source findings changed/, fn ->
      altered_finding = %{
        first_finding
        | citations: [{elem(first_citation, 0), "unsupported cited body"} | other_citations]
      }

      assert_inets_trace_floor_sources!(
        %{record | selected_function_evidence: [altered_finding | other_findings]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    exact_overlap = {{:mfa, hd(record.matched_mfas)}, :injected_overlap, []}

    assert_raise ExUnit.AssertionError, ~r/EX-010 overlap set changed/, fn ->
      assert_inets_trace_floor_witnesses!(record, ctx.graph, @exclusions ++ [exact_overlap])
    end

    assert_inets_trace_floor_archive_negatives!(dir)
  end

  @tag :inets_trace_core_only
  @tag :inets_trace_core_controls
  @tag :tmp_dir
  test "EX-010 integrity rejects changed graph, source, citation and semantic evidence",
       %{tmp_dir: dir} = ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    record = Fablebook.Test.InetsTraceCoreEvidence.record()

    archive_only = %{
      evidence
      | installed:
          evidence.installed
          |> Map.put("inets", Path.join(evidence.archive_root, "missing-inets"))
          |> Map.put("runtime_tools", Path.join(evidence.archive_root, "missing-runtime-tools"))
    }

    assert_inets_trace_core_evidence!(record, ctx.graph, evidence, archive_only)

    assert_raise ExUnit.AssertionError, ~r/lane mismatch/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | lane: "floor"},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/candidate-only status changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | checker_status: :active},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/unsupported semantic status/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | semantic_status: :verified},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    for mutated <- [
          %{record | matched_mfas: tl(record.matched_mfas)},
          %{record | matched_mfas: [hd(record.matched_mfas) | record.matched_mfas]},
          %{record | matched_mfas: Enum.reverse(record.matched_mfas)},
          %{record | selected_function_evidence: tl(record.selected_function_evidence)},
          %{
            record
            | selected_function_evidence: [
                hd(record.selected_function_evidence) | record.selected_function_evidence
              ]
          }
        ] do
      assert_raise ExUnit.AssertionError,
                   ~r/selected MFA identity|live matcher coverage|selected finding evidence changed/,
                   fn ->
                     assert_inets_trace_core_evidence!(mutated, ctx.graph, evidence, archive_only)
                   end
    end

    for mutated <- [
          %{record | exact_sources: tl(record.exact_sources)},
          %{record | exact_sources: [hd(record.exact_sources) | record.exact_sources]},
          %{record | exact_sources: Enum.reverse(record.exact_sources)}
        ] do
      assert_raise ExUnit.AssertionError, ~r/exact source identity set changed/, fn ->
        assert_inets_trace_core_evidence!(mutated, ctx.graph, evidence, archive_only)
      end
    end

    assert_raise ExUnit.AssertionError, ~r/review citation evidence changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | reviews: tl(record.reviews)},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    assert_raise ExUnit.AssertionError, ~r/review citation evidence changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | reviews: Enum.reverse(record.reviews)},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    for delegate_mutation <- [
          tl(record.delegate_edges),
          [hd(record.delegate_edges) | record.delegate_edges],
          Enum.reverse(record.delegate_edges)
        ] do
      assert_raise ExUnit.AssertionError, ~r/delegate evidence/, fn ->
        assert_inets_trace_core_evidence!(
          %{record | delegate_edges: delegate_mutation},
          ctx.graph,
          evidence,
          archive_only
        )
      end
    end

    assert_raise ExUnit.AssertionError, ~r/incoming edge evidence/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | incoming_edges: [hd(record.delegate_edges)]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    [review | rest] = record.reviews
    [{citation, _body} | citation_rest] = review.citations
    bad_body_review = %{review | citations: [{citation, "altered source body"} | citation_rest]}

    assert_raise ExUnit.AssertionError, ~r/review citation evidence changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | reviews: [bad_body_review | rest]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    bad_citation_review = %{review | citations: tl(review.citations)}

    assert_raise ExUnit.AssertionError, ~r/review citation evidence changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | reviews: [bad_citation_review | rest]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    bad_span_review = %{review | reviewed_lines: 1..1}

    assert_raise ExUnit.AssertionError, ~r/review citation evidence changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{record | reviews: [bad_span_review | rest]},
        ctx.graph,
        evidence,
        archive_only
      )
    end

    selected = hd(record.selected_function_evidence)

    assert_raise ExUnit.AssertionError, ~r/selected finding evidence changed/, fn ->
      assert_inets_trace_core_evidence!(
        %{
          record
          | selected_function_evidence: [
              %{selected | finding: "unsupported claim"} | tl(record.selected_function_evidence)
            ]
        },
        ctx.graph,
        evidence,
        archive_only
      )
    end

    trace_review =
      Enum.find(record.reviews, &(&1.source_path == "inets/src/inets_app/inets_trace.erl"))

    trace_citation = hd(trace_review.citations) |> elem(0)

    missing_manifest =
      Map.update!(archive_only.manifest, "files", fn rows ->
        Enum.reject(rows, &(&1["source_path"] == "inets/src/inets_app/inets_trace.erl"))
      end)

    missing_error =
      assert_raise SweepEvidence.Error, ~r/missing_source/, fn ->
        SweepEvidence.resolve!(%{archive_only | manifest: missing_manifest}, trace_citation)
      end

    assert missing_error.reason == :missing_source

    wrong_ref_manifest =
      Map.update!(archive_only.manifest, "files", fn rows ->
        Enum.map(rows, fn row ->
          if row["source_path"] == "inets/src/inets_app/inets_trace.erl",
            do: Map.put(row, "url", "https://example.invalid/altered-source.erl"),
            else: row
        end)
      end)

    assert_raise ExUnit.AssertionError, ~r/source identity manifest mismatch/, fn ->
      assert_inets_trace_core_evidence!(
        record,
        ctx.graph,
        %{evidence | manifest: wrong_ref_manifest},
        archive_only
      )
    end

    for wrong_identity <- [
          fn row -> %{row | "lane" => "floor", "path" => "floor/" <> row["source_path"]} end,
          fn row -> Map.update!(row, "bytes", &(&1 + 1)) end
        ] do
      wrong_manifest =
        Map.update!(evidence.manifest, "files", fn rows ->
          Enum.map(rows, fn row ->
            if row["source_path"] == "inets/src/inets_app/inets_trace.erl",
              do: wrong_identity.(row),
              else: row
          end)
        end)

      assert_raise ExUnit.AssertionError, ~r/source identity manifest mismatch/, fn ->
        assert_inets_trace_core_evidence!(
          record,
          ctx.graph,
          %{evidence | manifest: wrong_manifest},
          archive_only
        )
      end
    end

    resolved = SweepEvidence.resolve!(archive_only, trace_citation)
    File.write!(resolved.path, File.read!(resolved.path) <> "% altered source bytes\n")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      assert_inets_trace_core_evidence!(record, ctx.graph, evidence, archive_only)
    end

    outside_row = Enum.find(original_identity_ledger!().exclusions, &(&1.id == "EX-011"))
    assert outside_row.owner == "01.1.1.4"
    assert outside_row.semantic_status == :pending

    assert_inets_trace_archive_rejects_wrong_ref!(dir)
  end

  test "EX-159 maps its original caller-file functions to exact-lane atom evidence", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &(&1.original_id == "EX-159"))

    assert_creator_audit!(
      records,
      ctx.graph,
      BannedCalls.banned_mfas(),
      evidence
    )

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        Enum.reject(records, &(&1.original_id == "EX-159" and &1.lane == "core")),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))
    without_consult = %{lane_record | matched_mfas: [{:file, :path_consult, 2}]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.lane == lane_record.lane)),
          without_consult
        ),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    graph_without_consult = %{
      ctx.graph
      | exported: MapSet.delete(ctx.graph.exported, {:file, :consult, 1})
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        records,
        graph_without_consult,
        BannedCalls.banned_mfas(),
        evidence
      )
    end

    false_safe =
      {{:file, [:consult]}, :pure_data, ["kernel/src/file.erl:2272"]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_creator_audit!(
        records,
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence,
        @exclusions ++ [false_safe]
      )
    end

    malformed_source =
      update_in(lane_record.citations, fn [{_citation, expected} | rest] ->
        [{"kernel/src/file.erl:9999999", expected} | rest]
      end)

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      assert_creator_audit!(
        List.replace_at(
          records,
          Enum.find_index(records, &(&1.lane == lane_record.lane)),
          malformed_source
        ),
        ctx.graph,
        BannedCalls.banned_mfas(),
        evidence
      )
    end
  end

  test "EX-089 maps Yecc caller fronts and formatter semantics to exact-lane evidence", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &(&1.original_id == "EX-089"))
    tier = BannedCalls.banned_mfas()

    assert_yecc_audit!(records, ctx.graph, tier, evidence)

    lane_record = Enum.find(records, &(&1.lane == evidence.lane.name))
    lane_index = Enum.find_index(records, &(&1.lane == lane_record.lane))

    wrong_lane = %{lane_record | lane: "latest"}

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, wrong_lane),
        ctx.graph,
        tier,
        evidence
      )
    end

    empty_citations = %{lane_record | citations: []}

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, empty_citations),
        ctx.graph,
        tier,
        evidence
      )
    end

    two_tuple = %{
      lane_record
      | matched_mfas: List.replace_at(lane_record.matched_mfas, 1, {:yecc, :file})
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, two_tuple),
        ctx.graph,
        tier,
        evidence
      )
    end

    omitted_mfa = %{
      lane_record
      | matched_mfas: List.delete(lane_record.matched_mfas, {:yecc, :format_error, 1})
    }

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(
        List.replace_at(records, lane_index, omitted_mfa),
        ctx.graph,
        tier,
        evidence
      )
    end

    redundant_retention = {{:yecc, [:format_error]}, :by_name}

    assert_raise ExUnit.AssertionError, fn ->
      assert_yecc_audit!(records, ctx.graph, tier, evidence, @exclusions ++ [redundant_retention])
    end
  end

  test "Logger and ExUnit format fronts have exact-lane records and necessary arity dispositions",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &String.starts_with?(&1.original_id, "NEW-"))
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    assert_logger_audit!(records, ctx.graph, tier, evidence)

    omitted_spec_mfa = {Logger.Formatter, :new, 1}
    specs_without_front = Enum.reject(@logger_family_specs, &(&1.mfa == omitted_spec_mfa))
    records_without_front = Enum.reject(records, &(&1.matched_mfas == [omitted_spec_mfa]))

    assert covered?(omitted_spec_mfa, tier, names)
    assert length(records) - length(records_without_front) == length(@creator_expected_lanes)

    assert_raise ExUnit.AssertionError, ~r/spec MFA set differs from pinned lane universe/, fn ->
      assert_logger_audit!(
        records_without_front,
        ctx.graph,
        tier,
        evidence,
        @exclusions,
        specs_without_front
      )
    end

    lane_records = Enum.filter(records, &(&1.lane == evidence.lane.name))
    safe_spec = Enum.find(@logger_family_specs, &(&1.disposition == :exact_exclusion))
    safe_record = Enum.find(lane_records, &(&1.matched_mfas == [safe_spec.mfa]))

    assert_raise ExUnit.AssertionError, fn ->
      assert_logger_audit!(
        Enum.reject(records, &(&1.original_id == safe_record.original_id)),
        ctx.graph,
        tier,
        evidence
      )
    end

    lane_index = Enum.find_index(records, &(&1.original_id == safe_record.original_id))
    wrong_lane = %{safe_record | lane: "wrong-lane"}
    omitted_mfa = %{safe_record | matched_mfas: []}
    two_tuple = %{safe_record | matched_mfas: [Tuple.delete_at(safe_spec.mfa, 2)]}
    empty_citations = %{safe_record | citations: []}

    for malformed <- [wrong_lane, omitted_mfa, two_tuple, empty_citations] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_logger_audit!(
          List.replace_at(records, lane_index, malformed),
          ctx.graph,
          tier,
          evidence
        )
      end
    end

    malformed_source = %{
      safe_record
      | citations: [{"logger/lib/logger/formatter.ex:999999", "@default_pattern"}]
    }

    assert_raise SweepEvidence.Error, ~r/source_line/, fn ->
      assert_logger_audit!(
        List.replace_at(records, lane_index, malformed_source),
        ctx.graph,
        tier,
        evidence
      )
    end

    missing_tier = Enum.reject(tier, &(&1 == {Logger.Formatter, :new, 1}))

    assert_raise ExUnit.AssertionError, fn ->
      assert_logger_audit!(records, ctx.graph, missing_tier, evidence)
    end

    redundant_retention =
      {{:mfa, {Logger.Formatter, :new, 1}}, :fixed_default,
       ["logger/lib/logger/formatter.ex:170"]}

    assert_raise ExUnit.AssertionError, fn ->
      assert_logger_audit!(
        records,
        ctx.graph,
        tier,
        evidence,
        @exclusions ++ [redundant_retention]
      )
    end

    for spec <- @logger_family_specs, spec.disposition == :exact_exclusion do
      {module, function, _arity} = spec.mfa
      mfa = spec.mfa
      entry = Enum.find(@exclusions, &match?({{:mfa, ^mfa}, _, _}, &1))

      assert entry != nil
      assert exact_mfa_exclusion_reason(mfa, @exclusions) == spec.reason
      assert exclusion_reason(module, function, @exclusions) == nil
      assert mfa in undisposed(ctx.graph, tier, names, List.delete(@exclusions, entry))
    end
  end

  test "Logger and ExUnit audit rejects newly named reached and explicitly disposed exports",
       ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    records = Enum.filter(@creator_audit, &String.starts_with?(&1.original_id, "NEW-"))
    tier = BannedCalls.banned_mfas()
    new_front = {Logger.Formatter, :public_format_front, 1}
    graph_with_new_front = add_exported_sink_caller(ctx.graph, new_front)

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(records, graph_with_new_front, tier, evidence)
    end

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(records, graph_with_new_front, tier ++ [new_front], evidence)
    end

    explicit_exclusion =
      {{:mfa, new_front}, :pure_data, ["logger/lib/logger/formatter.ex:170"]}

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(
        records,
        graph_with_new_front,
        tier,
        evidence,
        @exclusions ++ [explicit_exclusion]
      )
    end

    graph_with_unreached_export = %{
      ctx.graph
      | exported: MapSet.put(ctx.graph.exported, new_front)
    }

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(records, graph_with_unreached_export, tier ++ [new_front], evidence)
    end

    assert_raise ExUnit.AssertionError, ~r/public_format_front/, fn ->
      assert_logger_audit!(
        records,
        graph_with_unreached_export,
        tier,
        evidence,
        @exclusions ++ [explicit_exclusion]
      )
    end
  end

  @tag :audit_readiness
  @tag :tmp_dir
  test "source citations reject missing, escaped, unreadable and altered evidence", %{
    tmp_dir: dir
  } do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    evidence = %{evidence | installed: Map.put(evidence.installed, "kernel", dir)}
    citation = "kernel/src/file.erl:1"
    assert SweepEvidence.resolve!(evidence, citation).origin == :archive

    for {invalid, reason} <- [
          {"kernel/src/../file.erl:1", :citation_path},
          {"/kernel/src/file.erl:1", :citation_format},
          {"kernel/src/file.erl:0", :citation_format},
          {"kernel/src/file.erl:9999999", :source_line},
          {"wrong/src/file.erl:1", :unknown_app},
          {"kernel/src/not-installed.erl:1", :missing_source}
        ] do
      error =
        assert_raise SweepEvidence.Error, fn -> SweepEvidence.resolve!(evidence, invalid) end

      assert error.reason == reason
    end

    missing_manifest =
      Map.update!(evidence.manifest, "files", fn rows ->
        Enum.reject(rows, &(&1["source_path"] == "kernel/src/file.erl"))
      end)

    assert_raise SweepEvidence.Error, ~r/missing_source/, fn ->
      SweepEvidence.resolve!(%{evidence | manifest: missing_manifest}, citation)
    end

    source = Path.join([dir, "src", "file.erl"])
    File.mkdir_p!(Path.dirname(source))
    resolved = SweepEvidence.resolve!(evidence, citation)
    File.cp!(resolved.path, source)
    assert SweepEvidence.resolve!(evidence, citation).origin == :installed
    File.chmod!(source, 0o000)

    assert_raise SweepEvidence.Error, ~r/unreadable_source/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end

    File.chmod!(source, 0o644)
    File.write!(source, "different app/source bytes\n")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end

    debugger_root = Path.join(dir, "debugger")

    debugger_evidence = %{
      evidence
      | installed: Map.put(evidence.installed, "debugger", debugger_root)
    }

    debugger_citation = "debugger/src/dbg_wx_interpret.erl:44"
    debugger_archived = SweepEvidence.resolve!(debugger_evidence, debugger_citation)
    assert debugger_archived.origin == :archive

    debugger_source = Path.join(debugger_root, "src/dbg_wx_interpret.erl")
    File.mkdir_p!(Path.dirname(debugger_source))
    File.cp!(debugger_archived.path, debugger_source)
    assert SweepEvidence.resolve!(debugger_evidence, debugger_citation).origin == :installed

    File.write!(debugger_source, <<>>)

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(debugger_evidence, debugger_citation)
    end

    File.write!(debugger_source, "different exact-lane source bytes\n")

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(debugger_evidence, debugger_citation)
    end

    File.rm!(debugger_source)
    empty_archive = Path.join(dir, "empty-source-archive")
    File.mkdir_p!(empty_archive)
    debugger_missing = %{debugger_evidence | archive_root: empty_archive}

    assert_raise SweepEvidence.Error, ~r/unreadable_source/, fn ->
      SweepEvidence.resolve!(debugger_missing, debugger_citation)
    end

    File.rm!(source)
    File.ln_s!(resolved.path, source)

    assert_raise SweepEvidence.Error, ~r/source_escape/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end

    File.rm!(source)
    File.rm!(resolved.path)

    assert_raise SweepEvidence.Error, ~r/unreadable_source/, fn ->
      SweepEvidence.resolve!(evidence, citation)
    end
  end

  @tag :tmp_dir
  test "source archives reject traversal, duplicate paths, links and corrupt bytes before extraction",
       %{tmp_dir: dir} do
    original = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
    {:ok, files} = :erl_tar.extract(String.to_charlist(original), [:compressed, :memory])

    for {name, entries, reason} <- [
          {"traversal", [{~c"../escape", "bad"} | files], :archive_path},
          {"duplicate", [hd(files) | files], :archive_duplicate},
          {"corrupt",
           List.keyreplace(
             files,
             ~c"core/kernel/src/file.erl",
             0,
             {~c"core/kernel/src/file.erl", "corrupted"}
           ), :source_digest}
        ] do
      path = Path.join(dir, name <> ".tar.gz")
      :ok = :erl_tar.create(String.to_charlist(path), entries, [:compressed])
      sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
      error = assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, sha) end
      assert error.reason == reason
    end

    for {name, transform, reason} <- [
          {"version", &put_in(&1["refs"]["core"]["otp"], ["29.1.1", "wrong"]), :source_identity},
          {"root",
           fn manifest ->
             Map.update!(manifest, "files", fn rows ->
               Enum.map(rows, fn row ->
                 if row["path"] == "core/kernel/src/file.erl",
                   do: Map.put(row, "lane", "floor"),
                   else: row
               end)
             end)
           end, :source_root},
          {"cn001-source-url",
           fn manifest ->
             Map.update!(manifest, "files", fn rows ->
               Enum.map(rows, fn row ->
                 if row["source_path"] == "elixir/lib/protocol.ex",
                   do:
                     Map.put(
                       row,
                       "url",
                       String.replace(
                         row["url"],
                         "759443e724f55bf58e71c0603644e99058918d52",
                         "dfe6612e546cec6557900e67651f7d21805472ef"
                       )
                     ),
                   else: row
               end)
             end)
           end, :source_identity}
        ] do
      entries =
        Enum.map(files, fn
          {~c"manifest.json", data} ->
            {~c"manifest.json", data |> JSON.decode!() |> transform.() |> JSON.encode!()}

          entry ->
            entry
        end)

      path = Path.join(dir, name <> ".tar.gz")
      :ok = :erl_tar.create(String.to_charlist(path), entries, [:compressed])
      sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
      error = assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, sha) end
      assert error.reason == reason
    end

    protocol_source =
      Enum.find(files, fn {name, _} -> name == ~c"core/elixir/lib/protocol.ex" end)

    {_, protocol_bytes} = protocol_source

    {~c"manifest.json", raw_manifest} =
      Enum.find(files, fn {name, _} -> name == ~c"manifest.json" end)

    manifest = JSON.decode!(raw_manifest)
    core_record = Enum.find(manifest["files"], &(&1["source_path"] == "elixir/lib/protocol.ex"))
    floor_record = %{core_record | "lane" => "floor", "path" => "floor/elixir/lib/protocol.ex"}
    wrong_lane_manifest = Map.update!(manifest, "files", &(&1 ++ [floor_record]))

    wrong_lane_entries =
      Enum.reject(files, fn {name, _} -> name == ~c"manifest.json" end) ++
        [
          {~c"floor/elixir/lib/protocol.ex", protocol_bytes},
          {~c"manifest.json", JSON.encode!(wrong_lane_manifest)}
        ]

    wrong_lane_archive = Path.join(dir, "cn001-same-bytes-wrong-lane.tar.gz")

    :ok =
      :erl_tar.create(String.to_charlist(wrong_lane_archive), wrong_lane_entries, [:compressed])

    wrong_lane_sha =
      :crypto.hash(:sha256, File.read!(wrong_lane_archive)) |> Base.encode16(case: :lower)

    wrong_lane_error =
      assert_raise SweepEvidence.Error, fn ->
        SweepEvidence.load_archive!(wrong_lane_archive, wrong_lane_sha)
      end

    assert wrong_lane_error.reason == :source_identity

    link = Path.join(dir, "link")
    File.ln_s!(original, link)
    path = Path.join(dir, "symlink.tar.gz")

    :ok =
      :erl_tar.create(String.to_charlist(path), [{~c"link", String.to_charlist(link)}], [
        :compressed
      ])

    sha = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)

    assert_raise SweepEvidence.Error, ~r/archive_link_or_type/, fn ->
      SweepEvidence.load_archive!(path, sha)
    end

    assert_raise SweepEvidence.Error, ~r/archive_digest/, fn ->
      SweepEvidence.load_archive!(original, "wrong")
    end
  end

  test "every in-scope OTP app, Elixir app and prod-closure dependency has an ebin", ctx do
    graph = ctx.graph

    assert graph.missing_apps == [], "missing ebin: #{inspect(graph.missing_apps)}"
    assert Enum.all?(@floor_roots, &(&1 in graph.roots)), "derived roots: #{inspect(graph.roots)}"
    assert Enum.all?(~w(phoenix phoenix_live_view plug), &(&1 in graph.closure))
  end

  test "every in-scope beam carries debug info", ctx do
    assert ctx.graph.no_debug == [], "beams without debug info: #{inspect(ctx.graph.no_debug)}"
  end

  test "every function named like a wholly banned module is covered or excluded with a cited reason",
       ctx do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    whole_modules =
      for {module, :_, :_} <- tier, do: module

    named =
      ctx.graph.exported
      |> Enum.filter(&banned_module_named?(&1, whole_modules))
      |> Enum.reject(fn {_module, function, _arity} ->
        function in [:__info__, :module_info] or
          String.starts_with?(Atom.to_string(function), "MACRO-")
      end)

    uncovered = Enum.reject(named, &covered?(&1, tier, names))
    matched = matched_uncovered(uncovered, @call_name_exclusions)

    cn004_matches =
      Enum.filter(uncovered, &(&1 == {Plug.Builder, :compile, 3}))

    _cn004_carrier_proof = cn004_carriers!(cn004_matches)
    matched = MapSet.union(matched, MapSet.new(cn004_matches))
    undisposed = Enum.reject(uncovered, &MapSet.member?(matched, &1))

    assert {Regex, :compile, 1} in named
    assert {Logger.Formatter, :compile, 1} in named

    logger_without_entry = Enum.reject(tier, &(&1 == {Logger.Formatter, :compile, :_}))

    assert {Logger.Formatter, :compile, 1} in Enum.reject(
             named,
             &covered?(&1, logger_without_entry, names)
           )

    unmatched_exclusions =
      Enum.reject(@call_name_exclusions, fn entry ->
        matched_uncovered(uncovered, [entry]) |> MapSet.size() > 0 or
          lane_specific_call_name?(entry, named) or
          call_name_exclusion_covered_by_exact_tier?(entry, named, tier)
      end)

    assert undisposed == [],
           "undisposed banned-module-named functions: #{inspect(Enum.sort(undisposed))}"

    assert unmatched_exclusions == [],
           "call-name exclusions matching no uncovered function: #{inspect(unmatched_exclusions)}"
  end

  @tag :cn002
  test "CN-002 preserves its identity and traces the complete live lane disposition", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn002_record!(ctx.graph, evidence, ledger)

    assert_cn002_record!(record, ctx.graph, evidence, ledger)
    assert record.original_id == "CN-002"

    assert record.current_replacement_refs == [
             current_call_name_ref!({Phoenix.Digester, [:compile]})
           ]

    assert record.retained_exclusion
    assert record.matched_mfas != []
    assert record.removal_witness != []
    assert record.overlap_mfas == []
  end

  @tag :cn002
  test "CN-002 rejects omitted row evidence and cross-lane source substitution", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn002_record!(ctx.graph, evidence, ledger)
    other_lane = if evidence.lane.name == "core", do: "floor", else: "core"

    for omitted <- [
          %{record | matched_mfas: tl(record.matched_mfas)},
          %{
            record
            | citations:
                Enum.reject(
                  record.citations,
                  &(elem(&1, 0) == "phoenix/lib/phoenix/digester.ex:20")
                )
          },
          %{record | removal_witness: []},
          %{record | lane: other_lane}
        ] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_cn002_record!(omitted, ctx.graph, evidence, ledger)
      end
    end

    missing_identity = %{
      ledger
      | exclusions: Enum.reject(ledger.exclusions, &(&1.id == "CN-002"))
    }

    assert_raise ExUnit.AssertionError, ~r/original CN-002 identity is missing/, fn ->
      cn002_record!(ctx.graph, evidence, missing_identity)
    end

    wrong_lane_evidence = %{evidence | lane: Map.put(evidence.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn002_record!(ctx.graph, wrong_lane_evidence, ledger)
    end

    wrong_lane_graph = %{ctx.graph | lane: Map.put(ctx.graph.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn002_record!(wrong_lane_graph, evidence, ledger)
    end

    for lane <- ["core", "floor"] do
      assert Enum.any?(evidence.manifest["files"], fn row ->
               row["lane"] == lane and
                 row["source_path"] == "phoenix/lib/phoenix/digester.ex" and
                 row["status"] == "present"
             end),
             "#{lane} source availability must be proved by its lane record"
    end

    missing_lane_source_manifest =
      Map.update!(evidence.manifest, "files", fn rows ->
        Enum.reject(rows, fn row ->
          row["lane"] == evidence.lane.name and
            row["source_path"] == "phoenix/lib/phoenix/digester.ex"
        end)
      end)

    missing_lane_source = %{evidence | manifest: missing_lane_source_manifest}

    error =
      assert_raise SweepEvidence.Error, fn ->
        SweepEvidence.resolve!(missing_lane_source, "phoenix/lib/phoenix/digester.ex:20")
      end

    assert error.reason == :missing_source
  end

  @tag :cn001
  test "CN-001 preserves identity and records its source-backed build carrier", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()

    record = cn001_record!(ctx.graph, evidence, ledger)

    assert_cn001_record!(record, ctx.graph, evidence, ledger)
    assert record.original_id == "CN-001"

    assert record.current_replacement_refs ==
             ledger.exclusions
             |> Enum.find(&(&1.id == "CN-001"))
             |> Map.fetch!(:current_replacement_refs)

    assert record.semantic_status == :cn001_project_build_replaced
    assert record.verdict == :source_backed_project_build
    assert record.disposition == :replaced
    assert length(record.coverage_carrier_refs) == 1

    assert record.carrier_loss_witness ==
             if(evidence.lane.name == "core",
               do: ["Elixir.Mix.Compilers.Protocol:compile/4"],
               else: []
             )

    if evidence.lane.name == "core" do
      omitted_core_citation = %{
        record
        | citations:
            Enum.reject(
              record.citations,
              &(elem(&1, 0) == "mix/lib/mix/compilers/protocol.ex:107")
            )
      }

      assert_raise ExUnit.AssertionError, fn ->
        assert_cn001_record!(omitted_core_citation, ctx.graph, evidence, ledger)
      end

      for omitted <- [
            %{record | matched_mfas: []},
            %{record | direct_callers: []},
            %{record | mfa_citations: %{}},
            %{record | caller_citations: %{}},
            %{record | coverage_carrier_refs: []},
            %{record | source_authority_gaps: [%{source_path: "missing"}]}
          ] do
        assert_raise ExUnit.AssertionError, fn ->
          assert_cn001_record!(omitted, ctx.graph, evidence, ledger)
        end
      end

      for citation_path <- [
            "mix/lib/mix/compilers/elixir.ex",
            "elixir/lib/protocol.ex"
          ] do
        citation =
          Enum.find(record.citations, &(citation_source_path!(elem(&1, 0)) == citation_path))

        assert citation != nil

        omitted_source = %{record | citations: List.delete(record.citations, citation)}

        assert_raise ExUnit.AssertionError, fn ->
          assert_cn001_record!(omitted_source, ctx.graph, evidence, ledger)
        end

        app = hd(String.split(citation_path, "/"))

        archived = %{
          evidence
          | installed:
              Map.put(evidence.installed, app, Path.join(evidence.archive_root, "missing-#{app}"))
        }

        assert SweepEvidence.resolve!(archived, elem(citation, 0)).origin == :archive

        missing_manifest = %{
          evidence
          | manifest:
              Map.update!(evidence.manifest, "files", fn rows ->
                Enum.reject(rows, &(&1["source_path"] == citation_path and &1["lane"] == "core"))
              end)
        }

        missing_error =
          assert_raise SweepEvidence.Error, fn ->
            SweepEvidence.resolve!(missing_manifest, elem(citation, 0))
          end

        assert missing_error.reason == :missing_source
      end

      caller_citations = List.flatten(Map.values(record.caller_citations))

      delegate_citations =
        record.citations
        |> Enum.filter(fn {citation, _} ->
          citation_source_path!(citation) in ["elixir/lib/protocol.ex", "elixir/lib/code.ex"]
        end)
        |> Enum.map(&elem(&1, 0))

      for citation <- Enum.uniq(caller_citations ++ delegate_citations) do
        omitted = %{
          record
          | citations: Enum.reject(record.citations, &(elem(&1, 0) == citation))
        }

        assert_raise ExUnit.AssertionError, fn ->
          assert_cn001_record!(omitted, ctx.graph, evidence, ledger)
        end
      end

      protocol_citation =
        Enum.find(
          record.citations,
          &(citation_source_path!(elem(&1, 0)) == "elixir/lib/protocol.ex")
        )

      protocol_archived = %{
        evidence
        | installed:
            Map.put(
              evidence.installed,
              "elixir",
              Path.join(evidence.archive_root, "missing-elixir")
            )
      }

      protocol_source = SweepEvidence.resolve!(protocol_archived, elem(protocol_citation, 0))
      assert protocol_source.origin == :archive
      File.write!(protocol_source.path, "altered exact source bytes")

      assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
        SweepEvidence.resolve!(protocol_archived, elem(protocol_citation, 0))
      end

      missing_carrier = %{
        ledger
        | exclusions:
            Enum.map(ledger.exclusions, fn
              %{id: "CN-001"} = row -> %{row | current_replacement_refs: []}
              row -> row
            end)
      }

      assert_raise ExUnit.AssertionError, fn ->
        cn001_record!(ctx.graph, evidence, missing_carrier)
      end

      unexpected_match = {Mix.Compilers.Protocol, :compile, 99}

      graph_with_new_match = %{
        ctx.graph
        | full_exported: MapSet.put(ctx.graph.full_exported, unexpected_match)
      }

      assert_raise ExUnit.AssertionError, fn ->
        cn001_record!(graph_with_new_match, evidence, ledger)
      end

      assert_raise ExUnit.AssertionError, fn ->
        assert_cn001_record!(%{record | carrier_loss_witness: []}, ctx.graph, evidence, ledger)
      end

      assert_raise ExUnit.AssertionError, fn ->
        cn001_project_build_loss_witness!(
          ctx.graph,
          hd(record.coverage_carrier_refs),
          List.delete(@exclusions, {Mix.Compilers.Protocol, :project_build})
        )
      end
    else
      invented_floor_export = %{
        record
        | module_exports: ["Elixir.Mix.Compilers.Protocol:compile/4"],
          matched_mfas: ["Elixir.Mix.Compilers.Protocol:compile/4"]
      }

      assert_raise ExUnit.AssertionError, fn ->
        assert_cn001_record!(invented_floor_export, ctx.graph, evidence, ledger)
      end
    end

    missing_identity = %{
      ledger
      | exclusions: Enum.reject(ledger.exclusions, &(&1.id == "CN-001"))
    }

    assert_raise ExUnit.AssertionError, ~r/original CN-001 identity is missing/, fn ->
      cn001_record!(ctx.graph, evidence, missing_identity)
    end
  end

  @tag :cn001
  test "CN-001 rejects a substituted project-build carrier reference", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn001_record!(ctx.graph, evidence, ledger)

    for wrong_ref <- ["source:EX:0", "source:CN:1", "source:EX:999"] do
      assert_raise ExUnit.AssertionError, fn ->
        cn001_project_build_loss_witness!(ctx.graph, wrong_ref)
      end

      substituted = %{record | coverage_carrier_refs: [wrong_ref]}

      assert_raise ExUnit.AssertionError, fn ->
        assert_cn001_record!(substituted, ctx.graph, evidence, ledger)
      end
    end
  end

  @tag :cn003
  test "CN-003 preserves its identity and traces the complete live lane disposition", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn003_record!(ctx.graph, evidence, ledger)

    assert_cn003_record!(record, ctx.graph, evidence, ledger)
    assert record.original_id == "CN-003"

    assert record.current_replacement_refs == [
             current_call_name_ref!({Phoenix.LiveView.ColocatedAssets, [:compile]})
           ]

    assert record.semantic_status == :cn003_retained
    assert record.retained_exclusion
    assert record.matched_mfas != []
    assert record.removal_witness != []
    assert record.overlap_mfas == []
  end

  @tag :cn004
  test "CN-004 preserves its identity and records complete exact-lane source authority", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn004_record!(ctx.graph, evidence, ledger)

    assert_cn004_record!(record, ctx.graph, evidence, ledger)
    assert record.original_id == "CN-004"
    assert record.current_replacement_refs == [cn004_carrier_ref!()]
    assert record.semantic_status == :cn004_replaced_by_expansion_carrier
    assert record.verdict in [:exact_compile_boundary_redundant]
    assert record.disposition == :replaced
    assert record.matched_mfas == ["Elixir.Plug.Builder:compile/3"]
    assert record.mode_branches |> Enum.map(& &1.mode) == [:compile, :runtime, :invalid]
    assert record.source_authority_gaps == []
    assert record.removal_witness == []
    assert record.overlap_mfas == ["Elixir.Plug.Builder:compile/3"]
    assert Enum.all?(record.caller_citations, fn {_caller, citations} -> citations != [] end)
  end

  @tag :cn001
  @tag :cn004
  test "CN-001 and CN-004 satisfy integrated original-identity acceptance", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()

    records = integrated_cn001_cn004_records!(ctx.graph, evidence, ledger)

    assert Map.keys(records) |> Enum.sort() == ["CN-001", "CN-004"]

    for id <- ["CN-001", "CN-004"] do
      omitted_identity = %{
        ledger
        | exclusions: Enum.reject(ledger.exclusions, &(&1.id == id))
      }

      assert_raise ExUnit.AssertionError, fn ->
        integrated_cn001_cn004_records!(ctx.graph, evidence, omitted_identity)
      end

      for {field, value} <- [
            {:semantic_status, :pending},
            {:current_replacement_refs, []}
          ] do
        incomplete_outcome = %{
          ledger
          | exclusions:
              Enum.map(ledger.exclusions, fn
                %{id: ^id} = row -> Map.put(row, field, value)
                row -> row
              end)
        }

        assert_raise ExUnit.AssertionError, fn ->
          integrated_cn001_cn004_records!(ctx.graph, evidence, incomplete_outcome)
        end
      end
    end

    changed_other_owner = %{
      ledger
      | exclusions:
          Enum.map(ledger.exclusions, fn
            %{id: "CN-002"} = row -> %{row | owner: "01.1.1.13"}
            row -> row
          end)
    }

    assert_raise ExUnit.AssertionError, fn ->
      integrated_cn001_cn004_records!(ctx.graph, evidence, changed_other_owner)
    end

    changed_metadata_owner = %{
      ledger
      | metadata: List.update_at(ledger.metadata, 0, &%{&1 | owner: "01.1.1.13"})
    }

    assert_raise ExUnit.AssertionError, fn ->
      integrated_cn001_cn004_records!(ctx.graph, evidence, changed_metadata_owner)
    end

    removed_cn004_source = %{
      evidence
      | manifest:
          Map.update!(evidence.manifest, "files", fn rows ->
            Enum.reject(
              rows,
              &(&1["lane"] == evidence.lane.name and
                  &1["source_path"] == "phoenix/lib/phoenix/router.ex")
            )
          end)
    }

    assert_raise SweepEvidence.Error, fn ->
      integrated_cn001_cn004_records!(ctx.graph, removed_cn004_source, ledger)
    end
  end

  @tag :cn004
  test "CN-004 rejects omitted match, caller, source, mode, and carrier evidence", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn004_record!(ctx.graph, evidence, ledger)
    other_lane = if evidence.lane.name == "core", do: "floor", else: "core"

    caller_citation_omissions =
      Enum.flat_map(record.caller_citations, fn {caller, citations} ->
        Enum.map(citations, fn citation ->
          Map.update!(record.caller_citations, caller, &List.delete(&1, citation))
        end)
      end)

    mode_branch_omissions = Enum.map(record.mode_branches, &List.delete(record.mode_branches, &1))

    delegate_branch_omissions =
      Enum.map(record.delegate_trace, &List.delete(record.delegate_trace, &1))

    citation_omissions =
      Enum.map(record.citations, &List.delete(record.citations, &1))

    for omitted <-
          [
            %{record | matched_mfas: []},
            %{record | mfa_citations: %{}},
            %{record | citations: List.delete_at(record.citations, 0)},
            %{record | mode_branches: Enum.take(record.mode_branches, 1)},
            %{
              record
              | direct_callers:
                  List.delete(record.direct_callers, "Elixir.Phoenix.Router:build_pipes/2")
            },
            %{
              record
              | caller_citations:
                  Map.delete(record.caller_citations, "Elixir.Phoenix.Router:build_pipes/2")
            },
            %{record | caller_input_trace: ""},
            %{record | delegate_trace: []},
            %{record | quoted_source_callsites: []},
            %{record | coverage_carriers: []},
            %{record | coverage_carrier_refs: []},
            %{record | verdict_explanation: ""},
            %{record | mfa_dispositions: %{}},
            %{
              record
              | source_sha256s: Map.delete(record.source_sha256s, "phoenix/lib/phoenix.ex")
            },
            %{record | overlap_mfas: []},
            %{record | lane: other_lane}
          ] ++
            Enum.map(caller_citation_omissions, &%{record | caller_citations: &1}) ++
            Enum.map(mode_branch_omissions, &%{record | mode_branches: &1}) ++
            Enum.map(delegate_branch_omissions, &%{record | delegate_trace: &1}) ++
            Enum.map(citation_omissions, &%{record | citations: &1}) do
      assert_raise ExUnit.AssertionError, fn ->
        assert_cn004_record!(omitted, ctx.graph, evidence, ledger)
      end
    end

    unexpected_match = {Plug.Builder, :compile, 4}

    graph_with_new_match = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, unexpected_match)
    }

    assert_raise ExUnit.AssertionError, fn ->
      cn004_record!(graph_with_new_match, evidence, ledger)
    end

    graph_missing_match = %{
      ctx.graph
      | full_exported: MapSet.delete(ctx.graph.full_exported, {Plug.Builder, :compile, 3})
    }

    assert_raise ExUnit.AssertionError, fn ->
      cn004_record!(graph_missing_match, evidence, ledger)
    end

    without_carrier =
      Enum.reject(@exclusions, fn
        {{Plug.Builder, [:compile]}, :expansion, "plug/lib/plug/builder.ex:324"} -> true
        _entry -> false
      end)

    assert_raise ExUnit.AssertionError, ~r/needs one exact active carrier/, fn ->
      cn004_carriers!([{Plug.Builder, :compile, 3}], without_carrier)
    end

    assert_raise ExUnit.AssertionError, ~r/exact Plug.Builder compile source/, fn ->
      cn004_carriers!(
        [{Plug.Builder, :compile, 3}],
        [{{Plug.Builder, [:compile]}, :expansion, "phoenix/lib/phoenix.ex:72"}]
      )
    end

    missing_identity = %{
      ledger
      | exclusions: Enum.reject(ledger.exclusions, &(&1.id == "CN-004"))
    }

    assert_raise ExUnit.AssertionError, ~r/original CN-004 identity is missing/, fn ->
      cn004_record!(ctx.graph, evidence, missing_identity)
    end

    wrong_lane_evidence = %{evidence | lane: Map.put(evidence.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn004_record!(ctx.graph, wrong_lane_evidence, ledger)
    end

    wrong_lane_graph = %{ctx.graph | lane: Map.put(ctx.graph.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn004_record!(wrong_lane_graph, evidence, ledger)
    end
  end

  @tag :tmp_dir
  @tag :cn004
  test "CN-004 router/config sources resolve offline with lane-bound archive integrity", %{
    tmp_dir: tmp_dir
  } do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    lane = evidence.lane.name

    archive_evidence = %{
      evidence
      | installed: Map.put(evidence.installed, "phoenix", Path.join(tmp_dir, "absent-phoenix"))
    }

    Enum.each(cn004_source_sha_by_lane!(lane), fn {source_path, expected_sha} ->
      line = if source_path == "phoenix/lib/phoenix/router.ex", do: 818, else: 72
      citation = source_path <> ":#{line}"
      archived = SweepEvidence.resolve!(archive_evidence, citation)
      assert archived.origin == :archive
      assert archived.sha256 == expected_sha

      missing_manifest = %{
        archive_evidence.manifest
        | "files" =>
            Enum.reject(archive_evidence.manifest["files"], fn row ->
              row["lane"] == lane and row["source_path"] == source_path
            end)
      }

      assert_raise SweepEvidence.Error, ~r/missing_source/, fn ->
        SweepEvidence.resolve!(%{archive_evidence | manifest: missing_manifest}, citation)
      end

      File.write!(archived.path, "changed archived source")

      assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
        SweepEvidence.resolve!(archive_evidence, citation)
      end
    end)

    original = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
    {:ok, entries} = :erl_tar.extract(String.to_charlist(original), [:compressed, :memory])

    wrong_lane_entries =
      Enum.map(entries, fn
        {~c"manifest.json", data} ->
          manifest = JSON.decode!(data)

          wrong_lane_manifest =
            Map.update!(manifest, "files", fn rows ->
              Enum.map(rows, fn row ->
                if row["lane"] == "floor" and row["source_path"] == "phoenix/lib/phoenix.ex",
                  do: Map.put(row, "url", "https://repo.hex.pm/tarballs/phoenix-1.8.16.tar"),
                  else: row
              end)
            end)

          {~c"manifest.json", JSON.encode!(wrong_lane_manifest)}

        entry ->
          entry
      end)

    wrong_lane_archive = Path.join(tmp_dir, "cn004-wrong-lane.tar.gz")

    :ok =
      :erl_tar.create(String.to_charlist(wrong_lane_archive), wrong_lane_entries, [:compressed])

    wrong_lane_sha =
      :crypto.hash(:sha256, File.read!(wrong_lane_archive)) |> Base.encode16(case: :lower)

    assert_raise SweepEvidence.Error, ~r/source_identity/, fn ->
      SweepEvidence.load_archive!(wrong_lane_archive, wrong_lane_sha)
    end
  end

  @tag :cn006
  test "CN-006 preserves both exact-lane re:compile arities with source and row witnesses", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn006_record!(ctx.graph, evidence, ledger)

    assert_cn006_record!(record, ctx.graph, evidence, ledger)
    assert record.original_id == "CN-006"
    assert record.current_replacement_refs == [current_call_name_ref!({:re, [:compile]})]
    assert record.semantic_status == :cn006_retained
    assert record.matched_mfas == Map.fetch!(@cn006_expected_matches_by_lane, evidence.lane.name)
    assert record.verdict == :retained_regex_data_native_boundary
    assert record.disposition == :retained_non_module_compile
    assert record.removal_witness == record.matched_mfas
    assert record.overlap_mfas == []
    assert record.direct_callers != []
  end

  @tag :cn006
  test "CN-006 rejects an omitted arity, source branch, caller set and witness", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn006_record!(ctx.graph, evidence, ledger)
    other_lane = if evidence.lane.name == "core", do: "floor", else: "core"

    for omitted <- [
          %{record | matched_mfas: List.delete_at(record.matched_mfas, 1)},
          %{record | citations: List.delete_at(record.citations, 0)},
          %{record | arity_traces: Map.delete(record.arity_traces, "re:compile/2")},
          %{record | direct_callers: []},
          %{record | caller_input_trace: ""},
          %{record | delegate_trace: []},
          %{record | removal_witness: []},
          %{record | overlap_mfas: record.matched_mfas},
          %{record | lane: other_lane}
        ] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_cn006_record!(omitted, ctx.graph, evidence, ledger)
      end
    end

    graph_with_new_match = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, {:re, :compile, 3})
    }

    assert_raise ExUnit.AssertionError, fn ->
      cn006_record!(graph_with_new_match, evidence, ledger)
    end

    missing_identity = %{
      ledger
      | exclusions: Enum.reject(ledger.exclusions, &(&1.id == "CN-006"))
    }

    assert_raise ExUnit.AssertionError, ~r/original CN-006 identity is missing/, fn ->
      cn006_record!(ctx.graph, evidence, missing_identity)
    end

    wrong_lane_evidence = %{evidence | lane: Map.put(evidence.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn006_record!(ctx.graph, wrong_lane_evidence, ledger)
    end

    wrong_lane_graph = %{ctx.graph | lane: Map.put(ctx.graph.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn006_record!(wrong_lane_graph, evidence, ledger)
    end
  end

  @tag :cn003
  test "CN-003 rejects omitted row evidence, new matches and cross-lane substitutions", ctx do
    evidence = SweepEvidence.source_roots!()
    on_exit(fn -> File.rm_rf!(evidence.archive_root) end)
    ledger = original_identity_ledger!()
    record = cn003_record!(ctx.graph, evidence, ledger)
    other_lane = if evidence.lane.name == "core", do: "floor", else: "core"

    for omitted <- [
          %{record | matched_mfas: tl(record.matched_mfas)},
          %{record | citations: List.delete_at(record.citations, 0)},
          %{record | direct_callers: []},
          %{record | removal_witness: []},
          %{record | lane: other_lane}
        ] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_cn003_record!(omitted, ctx.graph, evidence, ledger)
      end
    end

    unexpected_match = {Phoenix.LiveView.ColocatedAssets, :compile, 99}

    graph_with_new_match = %{
      ctx.graph
      | full_exported: MapSet.put(ctx.graph.full_exported, unexpected_match)
    }

    assert_raise ExUnit.AssertionError, fn ->
      cn003_record!(graph_with_new_match, evidence, ledger)
    end

    missing_identity = %{
      ledger
      | exclusions: Enum.reject(ledger.exclusions, &(&1.id == "CN-003"))
    }

    assert_raise ExUnit.AssertionError, ~r/original CN-003 identity is missing/, fn ->
      cn003_record!(ctx.graph, evidence, missing_identity)
    end

    wrong_lane_evidence = %{evidence | lane: Map.put(evidence.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn003_record!(ctx.graph, wrong_lane_evidence, ledger)
    end

    wrong_lane_graph = %{ctx.graph | lane: Map.put(ctx.graph.lane, :name, other_lane)}

    assert_raise ExUnit.AssertionError, ~r/graph and source evidence lanes differ/, fn ->
      cn003_record!(wrong_lane_graph, evidence, ledger)
    end
  end

  test "exact guard coverage supersedes a preserved call-name exclusion" do
    fronts = [
      {Phoenix.LiveView.ColocatedAssets, :compile, 0}
    ]

    for {module, function, arity} = front <- fronts do
      exclusion =
        Enum.find(@call_name_exclusions, fn
          {{^module, functions}, _reason, _citations} -> function in functions
          _entry -> false
        end)

      assert exclusion
      assert call_name_exclusion_covered_by_exact_tier?(exclusion, [front], [front])

      refute call_name_exclusion_covered_by_exact_tier?(exclusion, [front], [])

      refute call_name_exclusion_covered_by_exact_tier?(exclusion, [front], [
               {module, function, :_}
             ])

      refute call_name_exclusion_covered_by_exact_tier?(
               exclusion,
               [front, {module, function, arity + 1}],
               [front]
             )
    end
  end

  test "every barrier-module and sink-delegate export is covered or excluded with a cited reason",
       ctx do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    boundary = boundary_set(ctx.graph, tier, names)
    delegates = delegate_modules(ctx.graph)
    front = front_of_barrier(ctx.graph, tier, names)
    uncovered = Enum.reject(boundary, &covered?(&1, tier, names))
    matched = matched_boundary(uncovered, @boundary_exclusions)
    undisposed = Enum.reject(uncovered, &MapSet.member?(matched, &1))

    assert :erts_internal in delegates,
           "derived sink delegates: #{inspect(Enum.sort(delegates))}"

    assert {:code, :get_path, 0} in front
    assert {:code, :add_patha, 1} in boundary

    assert {:erts_internal, :prepare_loading, 2} in boundary_undisposed(
             boundary,
             Enum.reject(tier, &(&1 == {:erts_internal, :prepare_loading, :_})),
             names
           )

    assert {:code_server, :call, 1} in boundary_undisposed(
             boundary,
             Enum.reject(tier, &(&1 == {:code_server, :_, :_})),
             names
           )

    assert {:code, :add_patha, 1} in boundary_undisposed(
             boundary,
             Enum.reject(tier, &(&1 == {:code, :add_patha, :_})),
             names
           )

    assert undisposed == [],
           "undisposed boundary exports:\n" <>
             Enum.map_join(Enum.sort(undisposed), "\n", &inspect/1) <>
             "\nundisposed sizes by module: #{inspect(Enum.frequencies_by(undisposed, &elem(&1, 0)))}" <>
             "\nderived delegate set: #{inspect(Enum.sort(delegates), limit: :infinity)}"

    module_exclusion = Enum.find(@boundary_exclusions, &is_atom(elem(&1, 0)))
    assert module_exclusion != nil, "expected at least one module-level boundary exclusion"
    {matcher, _reason, _citation} = module_exclusion
    matched_by_module = Enum.filter(uncovered, &boundary_match?(matcher, &1))
    without_module_exclusion = List.delete(@boundary_exclusions, module_exclusion)

    undisposed_without_module =
      Enum.reject(
        uncovered,
        &MapSet.member?(matched_boundary(uncovered, without_module_exclusion), &1)
      )

    assert matched_by_module != []
    assert Enum.all?(matched_by_module, &(&1 in undisposed_without_module))

    unmatched_exclusions =
      Enum.reject(@boundary_exclusions, fn entry ->
        Enum.any?(uncovered, &boundary_match?(elem(entry, 0), &1)) or
          lane_specific_boundary?(entry, boundary)
      end)

    assert unmatched_exclusions == [],
           "boundary exclusions matching no uncovered export: #{inspect(unmatched_exclusions)}"
  end

  test "removing a tier entry leaves its front door undisposed", ctx do
    tier = Enum.reject(BannedCalls.banned_mfas(), &(&1 == {Mix.Tasks.Run, :_, :_}))
    undisposed = undisposed(ctx.graph, tier, BannedCalls.banned_names())

    assert {Mix.Tasks.Run, :run, 1} in undisposed
  end

  test "every function the sweep reaches is covered by the tier or excluded with a reason", ctx do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    rows = dispositions(ctx.graph, tier, names)
    undisposed = for {mfa, nil} <- rows, do: mfa
    counts = counts(ctx.graph, rows, undisposed)

    assert undisposed == [],
           "#{counts}\n" <> Enum.map_join(undisposed, "\n", &witness_line(ctx.graph, &1))
  end

  test "every exclusion names a known reason and every citation is an app-relative source line" do
    invalid =
      Enum.reject(
        @exclusions ++ @call_name_exclusions ++ @boundary_exclusions,
        &valid_exclusion?/1
      )

    assert invalid == [], "invalid exclusion records: #{inspect(invalid)}"
  end

  defp build_graph do
    evidence = SweepEvidence.source_roots!()

    try do
      build_graph(evidence)
    after
      File.rm_rf!(evidence.archive_root)
    end
  end

  defp build_graph(evidence) do
    graph_started = System.monotonic_time()
    Mix.ensure_application!(:tools)
    otp_lib = :code.lib_dir() |> to_string()
    discovery_started = System.monotonic_time()
    discovered = InstalledOtp.discover!(otp_lib, lane: evidence.lane.name)
    :ok = InstalledOtp.assert_discovery_complete!(otp_lib, discovered, lane: evidence.lane.name)
    discovery_ms = elapsed_ms(discovery_started)

    inspection_started = System.monotonic_time()
    inspected = InstalledOtp.inspect!(discovered, lane: evidence.lane.name)
    inspection_ms = elapsed_ms(inspection_started)

    source_scan_started = System.monotonic_time()

    sources =
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: evidence.lane.name,
        required_modules:
          Enum.uniq(~w(file io erl_scan yecc) ++ DebuggerSettings.required_source_modules())
      )

    source_scan_ms = elapsed_ms(source_scan_started)
    otp_apps = discovered
    elixir_dirs = for app <- @elixir_apps, do: app_dir(app)
    roots = dependency_roots()
    closure = dependency_closure(roots)
    dep_dirs = for app <- closure, do: Path.join([Mix.Project.build_path(), "lib", app, "ebin"])

    extra_apps =
      Enum.map(@elixir_apps, &%{app: Atom.to_string(&1), ebin: app_dir(&1)}) ++
        Enum.map(
          closure,
          &%{app: &1, ebin: Path.join([Mix.Project.build_path(), "lib", &1, "ebin"])}
        )

    dirs = Enum.map(otp_apps, & &1.ebin) ++ elixir_dirs ++ dep_dirs
    missing_apps = missing_apps(otp_lib, elixir_dirs, dep_dirs)
    otp_active_names = Enum.map(@historical_active_otp_apps, &Atom.to_string/1) |> MapSet.new()
    historical_otp_apps = Enum.filter(otp_apps, &MapSet.member?(otp_active_names, &1.app))
    pending_apps = Enum.reject(otp_apps, &MapSet.member?(otp_active_names, &1.app))

    historical_otp_dirs = Enum.map(historical_otp_apps, & &1.ebin)
    historical_app_names = MapSet.new(historical_otp_apps, & &1.app)
    {historical_otp_edges, no_debug_otp} = form_edges(historical_otp_dirs)
    {other_form_edges, no_debug_other} = form_edges(elixir_dirs ++ dep_dirs)
    {other_xref_edges, _no_debug_other_xref} = xref_form_edges(elixir_dirs ++ dep_dirs)
    otp_form_edges = Enum.flat_map(inspected, & &1.edges)
    otp_xref_edges = Enum.flat_map(inspected, & &1.xref_edges)

    expected_historical_edges =
      Enum.flat_map(inspected, fn inspection ->
        if MapSet.member?(historical_app_names, inspection.app),
          do: inspection.xref_edges,
          else: []
      end) ++ other_xref_edges

    expected_full_edges = otp_xref_edges ++ other_xref_edges
    historical_graph_dirs = historical_otp_dirs ++ elixir_dirs ++ dep_dirs
    full_graph_dirs = Enum.map(otp_apps, & &1.ebin) ++ elixir_dirs ++ dep_dirs

    expected_historical_exports =
      InstalledOtp.export_inventory!(historical_graph_dirs,
        lane: evidence.lane.name,
        edges: expected_historical_edges
      )

    expected_full_exports =
      InstalledOtp.export_inventory!(full_graph_dirs,
        lane: evidence.lane.name,
        edges: expected_full_edges
      )

    xref_started = System.monotonic_time()

    xref_graph =
      checked_xref_graph(
        historical_otp_apps ++ extra_apps,
        pending_apps,
        evidence.lane.name,
        expected_historical_edges,
        expected_historical_exports,
        expected_full_edges,
        expected_full_exports
      )

    xref_ms = elapsed_ms(xref_started)

    InstalledOtp.assert_parity!(
      discovered,
      inspected,
      Enum.filter(xref_graph.ingested, &(&1.app in Enum.map(otp_apps, fn app -> app.app end))),
      evidence.lane.name
    )

    historical_xref_edges =
      for {caller, {m, f, _}} <- xref_graph.historical_edges, do: {caller, {m, f}}

    full_xref_edges = for {caller, {m, f, _}} <- xref_graph.full_edges, do: {caller, {m, f}}
    historical_edges = historical_otp_edges ++ other_form_edges ++ historical_xref_edges
    full_edges = otp_form_edges ++ other_form_edges ++ full_xref_edges
    full_reverse = reverse(full_edges)
    full_forward = forward(full_edges)
    historical_modules = MapSet.new(xref_graph.historical_ingested, & &1.module_atom)
    historical_exported = MapSet.new(xref_graph.historical_exports)
    full_exported = MapSet.new(xref_graph.full_exports)
    module_app = Map.new(xref_graph.ingested, &{&1.module_atom, &1.app})
    no_debug = no_debug_otp ++ no_debug_other

    historical_reached_graph = %{
      reverse: reverse(historical_edges),
      exported: historical_exported
    }

    full_reached_graph = %{reverse: full_reverse, exported: full_exported}
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    {historical_reached, _historical_parent} = reach(historical_reached_graph, tier, names)
    {full_reached, full_parent} = reach(full_reached_graph, tier, names)

    settings_audit_graph = %{
      lane: evidence.lane,
      inspected: inspected,
      full_edges: full_edges,
      full_exported: full_exported,
      full_reached: full_reached
    }

    :ok =
      DebuggerSettings.assert_audit!(
        DebuggerSettings.records(evidence.lane.name),
        settings_audit_graph,
        tier,
        evidence,
        @exclusions
      )

    active_modules =
      Enum.reduce(
        @debugger_active_modules,
        MapSet.put(historical_modules, :ct_make),
        &MapSet.put(&2, &1)
      )
      |> MapSet.put(:dbg_wx_settings)

    active_ingested =
      Enum.filter(xref_graph.ingested, &MapSet.member?(active_modules, &1.module_atom))

    active_edges =
      Enum.filter(full_edges, fn {{module, _, _}, _} ->
        MapSet.member?(active_modules, module)
      end)

    active_exported =
      Enum.filter(full_exported, fn {module, _, _} ->
        MapSet.member?(active_modules, module)
      end)

    active_reverse = reverse(active_edges)
    active_forward = forward(active_edges)
    active_exported = MapSet.new(active_exported)
    active_reached_graph = %{reverse: active_reverse, exported: active_exported}
    {active_reached, _active_parent} = reach(active_reached_graph, tier, names)

    assert_active_sets_preserved!(
      %{reached: historical_reached, exported: historical_exported, edges: historical_edges},
      %{reached: active_reached, exported: active_exported, edges: active_edges},
      %{reached: full_reached, exported: full_exported, edges: full_edges},
      evidence.lane.name
    )

    active_expansion_failures =
      assert_no_new_active_failures!(
        full_reached,
        historical_reached,
        historical_modules,
        tier,
        names,
        evidence.lane.name
      )

    active_membership =
      active_membership_records(
        xref_graph.historical_ingested,
        active_ingested,
        active_exported,
        active_edges,
        module_app
      )

    export_records = mfa_records("export", full_exported, module_app)
    reached_records = mfa_records("reached", full_reached, module_app)

    boundary_graph = %{
      edges: full_edges,
      exported: full_exported,
      forward: full_forward,
      reverse: full_reverse
    }

    boundary_mfas = boundary_set(boundary_graph, tier, names)
    boundary_records = boundary_inventory_records(boundary_mfas, module_app)

    sources_by_module =
      Map.new(sources, fn source ->
        {source.app, Map.new(source.beams, &{&1.module, &1})}
      end)

    pending_modules =
      for inspection <- inspected,
          not MapSet.member?(active_modules, inspection.module_atom),
          do: inspection

    pending_mfas = MapSet.difference(full_reached, active_reached)

    pending_records =
      pending_inventory_records(
        pending_apps,
        pending_modules,
        pending_mfas,
        full_parent,
        full_edges,
        module_app,
        sources_by_module
      )

    discovery_count = length(discovered)
    beam_count = length(inspected)
    function_count = Enum.sum(Enum.map(inspected, & &1.function_count))
    function_bytes = Enum.sum(Enum.map(inspected, & &1.function_bytes))
    beam_bytes = Enum.sum(Enum.map(inspected, fn beam -> File.stat!(beam.path).size end))
    source_file_count = Enum.sum(Enum.map(sources, & &1.source_file_count))
    source_bytes = Enum.sum(Enum.map(sources, & &1.source_bytes))
    mapped_beams = Enum.sum(Enum.map(sources, & &1.mapped_beams))
    missing_source_beams = Enum.sum(Enum.map(sources, & &1.missing_source_beams))
    unavailable_source_beams = Enum.sum(Enum.map(sources, & &1.unavailable_source_beams))

    metrics = %{
      "app_count" => discovery_count,
      "beam_count" => beam_count,
      "function_count" => function_count,
      "function_bytes" => function_bytes,
      "beam_bytes" => beam_bytes,
      "source_file_count" => source_file_count,
      "source_bytes" => source_bytes,
      "mapped_beams" => mapped_beams,
      "missing_source_beams" => missing_source_beams,
      "unavailable_source_beams" => unavailable_source_beams,
      "exported_matches" => MapSet.size(full_exported),
      "reached_matches" => MapSet.size(full_reached),
      "boundary_matches" => length(boundary_records),
      "active_app_count" => Enum.count(active_membership, &(&1["kind"] == "active_app")),
      "active_module_count" => Enum.count(active_membership, &(&1["kind"] == "active_module")),
      "active_export_count" => Enum.count(active_membership, &(&1["kind"] == "active_export")),
      "active_edge_count" => Enum.count(active_membership, &(&1["kind"] == "active_edge")),
      "pending_app_count" => Enum.count(pending_records, &(&1["kind"] == "pending_app")),
      "pending_module_count" => Enum.count(pending_records, &(&1["kind"] == "pending_module")),
      "pending_mfa_count" => Enum.count(pending_records, &(&1["kind"] == "pending_mfa")),
      "discovery_ms" => discovery_ms,
      "inspection_ms" => inspection_ms,
      "source_scan_ms" => source_scan_ms,
      "xref_ms" => xref_ms,
      "graph_ms" => elapsed_ms(graph_started),
      "pending_owner" => "01.1.1.3"
    }

    receipt = %{
      lane: evidence.lane,
      lock_sha256: evidence.lock_sha256,
      discovered: discovered,
      inspected: inspected,
      sources: sources,
      ingested:
        Enum.filter(xref_graph.ingested, &(&1.app in Enum.map(otp_apps, fn app -> app.app end))),
      active_membership: active_membership,
      export_records: export_records,
      reached_records: reached_records,
      boundary_records: boundary_records,
      pending_records: pending_records,
      metrics: metrics
    }

    receipt_lines = InstalledOtp.receipt_lines(receipt)
    Enum.each(receipt_lines, &IO.puts/1)

    pending_apps = Enum.reject(discovered, &MapSet.member?(otp_active_names, &1.app))

    %{
      dirs: dirs,
      edges: active_edges,
      exported: active_exported,
      reverse: active_reverse,
      forward: active_forward,
      no_debug: no_debug,
      missing_apps: missing_apps,
      roots: roots,
      closure: closure,
      out_of_scope: Enum.map(pending_apps, & &1.app),
      historical_active_otp_apps: MapSet.to_list(otp_active_names),
      historical_active_modules: historical_modules,
      historical_active_edges: historical_edges,
      historical_active_exported: historical_exported,
      active_modules: active_modules,
      active_edges: active_edges,
      active_exported: active_exported,
      active_membership: active_membership,
      active_reached: active_reached,
      discovered: discovered,
      inspected: inspected,
      ingested: receipt.ingested,
      module_app: module_app,
      full_edges: full_edges,
      full_exported: full_exported,
      full_reverse: full_reverse,
      full_forward: full_forward,
      pending_apps: pending_apps,
      sources: sources,
      metrics: metrics,
      historical_reached: historical_reached,
      full_reached: full_reached,
      pending_mfas: pending_mfas,
      pending_modules: pending_modules,
      boundary_records: boundary_records,
      active_expansion_failures: active_expansion_failures,
      receipt_lines: receipt_lines,
      lane: evidence.lane,
      lock_sha256: evidence.lock_sha256
    }
  end

  defp assert_active_sets_preserved!(historical, active, full, lane) do
    preserved =
      MapSet.subset?(historical.reached, active.reached) and
        MapSet.subset?(active.reached, full.reached) and
        MapSet.subset?(historical.exported, active.exported) and
        MapSet.subset?(active.exported, full.exported) and
        MapSet.subset?(MapSet.new(historical.edges), MapSet.new(active.edges)) and
        MapSet.subset?(MapSet.new(active.edges), MapSet.new(full.edges))

    unless preserved,
      do:
        raise(
          "installed OTP active projection lost historical or full-scope coverage for #{lane}"
        )
  end

  defp assert_no_new_active_failures!(
         full_reached,
         historical_reached,
         historical_modules,
         tier,
         names,
         lane,
         exclusions \\ @exclusions
       ) do
    failures =
      full_reached
      |> MapSet.difference(historical_reached)
      |> Enum.filter(fn {module, _function, _arity} = mfa ->
        MapSet.member?(historical_modules, module) and
          disposition(mfa, tier, names, exclusions) == nil
      end)

    if failures != [] do
      raise "installed OTP expansion reached undisposed historical active MFAs on #{lane}: " <>
              Enum.map_join(failures, ", ", &inspect/1)
    end

    failures
  end

  defp elapsed_ms(started) do
    System.monotonic_time()
    |> Kernel.-(started)
    |> System.convert_time_unit(:native, :millisecond)
  end

  defp active_membership_records(
         historical_ingested,
         active_ingested,
         active_exports,
         active_edges,
         module_app
       ) do
    apps =
      historical_ingested
      |> Enum.map(& &1.app)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.map(&%{"kind" => "active_app", "app" => &1})

    modules =
      active_ingested
      |> Enum.uniq_by(&{&1.app, &1.module})
      |> Enum.map(
        &%{"kind" => "active_module", "app" => &1.app, "module" => Atom.to_string(&1.module_atom)}
      )
      |> Enum.sort_by(&{&1["app"], &1["module"]})

    exports = mfa_records("active_export", active_exports, module_app)

    edges =
      active_edges
      |> Enum.uniq()
      |> Enum.map(fn {{module, function, arity}, {callee_module, callee_function}} ->
        %{
          "kind" => "active_edge",
          "app" => Map.fetch!(module_app, module),
          "module" => Atom.to_string(module),
          "function" => Atom.to_string(function),
          "arity" => arity,
          "callee_app" => Map.get(module_app, callee_module),
          "callee_module" => Atom.to_string(callee_module),
          "callee_function" => Atom.to_string(callee_function)
        }
      end)
      |> Enum.sort_by(
        &{&1["app"], &1["module"], &1["function"], &1["arity"], &1["callee_module"],
         &1["callee_function"]}
      )

    apps ++ modules ++ exports ++ edges
  end

  defp mfa_records(kind, mfas, module_app) do
    mfas
    |> Enum.sort_by(fn {module, function, arity} ->
      {Atom.to_string(module), Atom.to_string(function), arity}
    end)
    |> Enum.map(fn {module, function, arity} ->
      %{
        "kind" => kind,
        "app" => Map.fetch!(module_app, module),
        "module" => Atom.to_string(module),
        "function" => Atom.to_string(function),
        "arity" => arity
      }
    end)
  end

  defp boundary_inventory_records(mfas, module_app) do
    mfas
    |> Enum.sort_by(fn {module, function, arity} ->
      {Atom.to_string(module), Atom.to_string(function), arity}
    end)
    |> Enum.map(fn {module, function, arity} = mfa ->
      record =
        mfa_records("boundary", [mfa], module_app)
        |> hd()

      explicit_exclusion =
        Enum.any?(@boundary_exclusions, fn {matcher, _reason, _citations} ->
          boundary_match?(matcher, mfa)
        end)

      record
      |> Map.put("explicit_boundary_exclusion", explicit_exclusion)
      |> Map.put("function", Atom.to_string(function))
      |> Map.put("module", Atom.to_string(module))
      |> Map.put("arity", arity)
    end)
  end

  defp pending_inventory_records(
         pending_apps,
         pending_modules,
         pending_mfas,
         parent,
         edges,
         module_app,
         sources_by_module
       ) do
    caller_index = caller_chain_index(edges)

    app_records =
      pending_apps
      |> Enum.sort_by(& &1.app)
      |> Enum.map(fn app ->
        %{"kind" => "pending_app", "app" => app.app, "owner" => "01.1.1.3"}
      end)

    module_records =
      pending_modules
      |> Enum.sort_by(&{&1.app, &1.module})
      |> Enum.map(fn beam ->
        source = get_in(sources_by_module, [beam.app, beam.module])

        %{
          "kind" => "pending_module",
          "app" => beam.app,
          "module" => beam.module,
          "function_count" => beam.function_count,
          "function_bytes" => beam.function_bytes,
          "source_status" => source.status,
          "source" => source.source,
          "source_bytes" => source.bytes,
          "owner" => "01.1.1.3"
        }
      end)

    mfa_records =
      pending_mfas
      |> Enum.sort_by(fn {module, function, arity} ->
        {Atom.to_string(module), Atom.to_string(function), arity}
      end)
      |> Enum.map(fn {module, function, arity} ->
        caller_chain =
          parent
          |> caller_chain({module, function, arity}, caller_index)
          |> Enum.map(fn {caller_module, caller_function, caller_arity} ->
            "#{Atom.to_string(caller_module)}.#{Atom.to_string(caller_function)}/#{caller_arity}"
          end)

        %{
          "kind" => "pending_mfa",
          "app" => Map.fetch!(module_app, module),
          "module" => Atom.to_string(module),
          "function" => Atom.to_string(function),
          "arity" => arity,
          "caller_chain" => caller_chain,
          "owner" => "01.1.1.3"
        }
      end)

    app_records ++ module_records ++ mfa_records
  end

  defp caller_chain_index(edges) do
    Enum.reduce(edges, %{}, &index_caller_edge/2)
  end

  defp index_caller_edge({{module, function, _arity} = caller_mfa, next}, index) do
    key = {{module, function}, next}
    Map.update(index, key, caller_mfa, &lowest_caller_mfa(caller_mfa, &1))
  end

  defp lowest_caller_mfa(candidate, current) do
    if caller_mfa_sort_key(candidate) < caller_mfa_sort_key(current),
      do: candidate,
      else: current
  end

  defp caller_mfa_sort_key({module, function, arity}),
    do: {Atom.to_string(module), Atom.to_string(function), arity}

  defp caller_chain(parent, {module, function, _arity} = start_mfa, caller_index) do
    path = witness(parent, {module, function}, []) |> Enum.reverse()

    callers =
      path
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.with_index()
      |> Enum.map(fn
        {[{start_module, start_function}, _next], 0} ->
          {start_module, start_function, elem(start_mfa, 2)}

        {[caller_pair, next], _index} ->
          case Map.fetch(caller_index, {caller_pair, next}) do
            {:ok, caller_mfa} ->
              caller_mfa

            :error ->
              raise "installed OTP inventory caller-chain edge missing for #{inspect(caller_pair)} -> #{inspect(next)}"
          end
      end)

    if callers == [], do: [start_mfa], else: callers
  end

  defp checked_xref_graph(
         historical_apps,
         pending_apps,
         lane,
         expected_historical_edges,
         expected_historical_exports,
         expected_full_edges,
         expected_full_exports
       ) do
    start_xref!(lane)

    try do
      set_xref_defaults!(lane)
      historical_ingested = ingest_xref_apps!(historical_apps, lane)

      historical_edges =
        xref_query!(
          ~c"E",
          :historical_edges,
          lane,
          expected_historical_edges,
          &xref_edge_identity!/1
        )

      historical_exports =
        xref_query!(~c"X", :historical_exports, lane, expected_historical_exports)

      pending_ingested = ingest_xref_apps!(pending_apps, lane)

      full_edges =
        xref_query!(~c"E", :full_edges, lane, expected_full_edges, &xref_edge_identity!/1)

      full_exports = xref_query!(~c"X", :full_exports, lane, expected_full_exports)

      %{
        historical_ingested: historical_ingested,
        historical_edges: historical_edges,
        historical_exports: historical_exports,
        pending_ingested: pending_ingested,
        ingested: historical_ingested ++ pending_ingested,
        full_edges: full_edges,
        full_exports: full_exports
      }
    after
      stop_xref!(lane)
    end
  end

  defp ingest_xref_apps!(apps, lane) do
    Enum.flat_map(apps, &InstalledOtp.add_directory!(:tier_sweep, &1, lane: lane))
  end

  defp start_xref!(lane) do
    case :xref.start(:tier_sweep, xref_mode: :functions) do
      {:ok, _} -> :ok
      result -> raise "installed OTP inventory xref start failed for #{lane}: #{inspect(result)}"
    end
  end

  defp set_xref_defaults!(lane) do
    case :xref.set_default(:tier_sweep, warnings: false, verbose: false, builtins: true) do
      :ok ->
        :ok

      result ->
        raise "installed OTP inventory xref defaults failed for #{lane}: #{inspect(result)}"
    end
  end

  defp xref_query!(query, label, lane, expected_rows, normalize \\ &Function.identity/1) do
    InstalledOtp.assert_xref_query!(
      fn -> :xref.q(:tier_sweep, query) end,
      label,
      lane,
      expected_rows,
      normalize
    )
  end

  defp xref_edge_identity!({caller, {module, function}} = row)
       when is_tuple(caller) and is_atom(module) and is_atom(function),
       do: row

  defp xref_edge_identity!({caller, {module, function, _arity}})
       when is_tuple(caller) and is_atom(module) and is_atom(function),
       do: {caller, {module, function}}

  defp xref_edge_identity!(row),
    do: raise("unexpected installed OTP Xref edge row: #{inspect(row)}")

  defp stop_xref!(lane) do
    case :xref.stop(:tier_sweep) do
      :stopped -> :ok
      result -> raise "installed OTP inventory xref stop failed for #{lane}: #{inspect(result)}"
    end
  end

  defp missing_apps(otp_lib, elixir_dirs, dep_dirs) do
    otp_apps = Enum.map(@historical_active_otp_apps, &Atom.to_string/1)
    installed = otp_lib |> File.ls!() |> Enum.map(&String.replace(&1, ~r/-[0-9][0-9.]*$/, ""))

    Enum.reject(otp_apps, &(&1 in installed)) ++
      for(dir <- elixir_dirs ++ dep_dirs, not File.dir?(dir), do: dir)
  end

  defp app_dir(app) do
    app
    |> :code.lib_dir()
    |> to_string()
    |> Path.join("ebin")
  end

  defp dependency_roots do
    Mix.Project.config()[:deps]
    |> Enum.filter(fn dep ->
      opts = dependency_options(dep)

      opts[:runtime] != false and
        :prod in List.wrap(Keyword.get(opts, :only, :prod))
    end)
    |> Enum.map(&(elem(&1, 0) |> Atom.to_string()))
  end

  defp dependency_options({_app, opts}) when is_list(opts), do: opts
  defp dependency_options({_app, _version, opts}), do: opts
  defp dependency_options(_dep), do: []

  defp dependency_closure(roots), do: dependency_walk(roots, [], &hex_requirements/1)
  defp dependency_walk([], seen, _requirements), do: Enum.reverse(seen)

  defp dependency_walk([app | rest], seen, requirements) do
    if app in seen,
      do: dependency_walk(rest, seen, requirements),
      else: dependency_walk(rest ++ requirements.(app), [app | seen], requirements)
  end

  defp hex_requirements(app) do
    {:ok, metadata} =
      :file.consult(Path.join([Mix.Project.deps_path(), app, "hex_metadata.config"]))

    "requirements"
    |> :proplists.get_value(metadata, [])
    |> Enum.flat_map(fn
      {name, entry} -> required_app(Map.put_new(Map.new(entry), "app", name))
      entry when is_list(entry) -> required_app(Map.new(entry))
    end)
  end

  defp required_app(%{"optional" => false} = entry), do: [entry["app"] || entry["name"]]
  defp required_app(_entry), do: []

  defp form_edges(dirs) do
    beams =
      for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), do: {dir, file}

    Enum.reduce(beams, {[], []}, fn {dir, file}, acc -> collect_beam_edges(dir, file, acc) end)
  end

  defp xref_form_edges(dirs) do
    beams =
      for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), do: {dir, file}

    Enum.reduce(beams, {[], []}, fn {dir, file}, {edges, missing} ->
      case BeamWalker.xref_edges(Path.join(dir, file)) do
        {:ok, found} -> {found ++ edges, missing}
        {:error, _reason} -> {edges, [file | missing]}
      end
    end)
  end

  defp collect_beam_edges(dir, file, {edges, missing}) do
    path = String.to_charlist(Path.join(dir, file))

    case debug_edges(path) do
      {:ok, found} -> {found ++ edges, missing}
      :error -> {edges, [file | missing]}
    end
  end

  defp debug_edges(path) do
    with {:ok, {mod, [debug_info: {:debug_info_v1, backend, data}]}} when data != :none <-
           :beam_lib.chunks(path, [:debug_info]),
         {:ok, forms} <- backend.debug_info(:erlang_v1, mod, data, []) do
      found =
        Enum.flat_map(forms, fn
          {:function, _, name, arity, _} = form when {name, arity} != {:__info__, 1} ->
            function_edges(mod, form)

          _form ->
            []
        end)

      {:ok, found}
    else
      _result -> :error
    end
  end

  defp reverse(edges) do
    Enum.reduce(edges, %{}, fn {caller, callee}, acc ->
      if barrier?(callee), do: acc, else: Map.update(acc, callee, [caller], &[caller | &1])
    end)
  end

  defp add_exported_sink_caller(graph, {module, function, arity} = mfa) do
    sink = {:erlang, :load_module}

    %{
      graph
      | exported: MapSet.put(graph.exported, mfa),
        reverse: Map.update(graph.reverse, sink, [{module, function, arity}], &[mfa | &1])
    }
  end

  defp forward(edges) do
    Enum.reduce(edges, %{}, fn {{module, function, _arity}, callee}, acc ->
      Map.update(acc, {module, function}, [callee], &[callee | &1])
    end)
  end

  defp barrier?({m, f}) do
    {m, f} in @barrier_functions or m in @barrier_modules
  end

  defp walk(reverse, initial) do
    sink_keys = initial
    parents = Map.new(sink_keys, &{&1, nil})
    do_walk(:queue.from_list(sink_keys), reverse, parents, MapSet.new())
  end

  defp do_walk(queue, reverse, parents, reached) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        {reached, parents}

      {{:value, key}, rest} ->
        callers = Map.get(reverse, key, [])

        new_keys =
          callers
          |> Enum.map(fn {m, f, _arity} -> {m, f} end)
          |> Enum.uniq()
          |> Enum.reject(&Map.has_key?(parents, &1))

        next_queue = Enum.reduce(new_keys, rest, &:queue.in/2)
        next_parents = Enum.reduce(new_keys, parents, &Map.put(&2, &1, key))
        next_reached = Enum.reduce(callers, reached, &MapSet.put(&2, &1))
        do_walk(next_queue, reverse, next_parents, next_reached)
    end
  end

  defp undisposed(graph, tier, names, exclusions \\ @exclusions) do
    graph
    |> dispositions(tier, names, exclusions)
    |> Enum.filter(&(elem(&1, 1) == nil))
    |> Enum.map(&elem(&1, 0))
  end

  defp dispositions(graph, tier, names, exclusions \\ @exclusions) do
    {reached, _parent} = reach(graph, tier, names)

    reached
    |> Enum.filter(&MapSet.member?(graph.exported, &1))
    |> Enum.reject(fn {m, f, _arity} ->
      m in [:erlang, :erl_eval, :erl_ddll] or f == :module_info
    end)
    |> Enum.map(fn mfa -> {mfa, disposition(mfa, tier, names, exclusions)} end)
  end

  defp disposition({m, f, _a} = mfa, tier, names, exclusions) do
    if covered?(mfa, tier, names) do
      :tier
    else
      exact_mfa_exclusion_reason(mfa, exclusions) || exclusion_reason(m, f, exclusions)
    end
  end

  defp debugger_family_universe(graph, tier, exclusions) do
    inspections = Enum.filter(graph.inspected, &(&1.module_atom in @debugger_family_modules))
    inspected_modules = MapSet.new(inspections, & &1.module_atom)

    assert inspected_modules == MapSet.new(@debugger_family_modules),
           "lane #{graph.lane.name} app debugger is missing an assigned inspected BEAM"

    scanned_functions =
      Enum.reduce(inspections, MapSet.new(), fn inspection, functions ->
        case BeamWalker.scan(inspection.path) do
          {:ok, scan} ->
            assert scan.module == inspection.module_atom,
                   "lane #{graph.lane.name} app #{inspection.app} module #{inspection.module} " <>
                     "scanned as #{inspect(scan.module)}"

            scanned_family_functions =
              scan.function_mfas
              |> Enum.filter(&debugger_family_mfa?/1)
              |> MapSet.new()

            MapSet.union(functions, scanned_family_functions)

          {:error, reason} ->
            flunk(
              "lane #{graph.lane.name} app #{inspection.app} module #{inspection.module} " <>
                "could not be inventoried from #{inspection.path}: #{inspect(reason)}"
            )
        end
      end)

    graph_candidates =
      graph
      |> debugger_graph_candidates()
      |> Enum.filter(&debugger_family_mfa?/1)
      |> MapSet.new()

    all_candidates = MapSet.union(scanned_functions, graph_candidates)
    names = BannedCalls.banned_names()

    tier_roots =
      Enum.filter(all_candidates, &covered?(&1, tier, names))
      |> MapSet.new()

    exclusion_roots =
      Enum.filter(all_candidates, fn {module, function, _arity} = mfa ->
        exact_mfa_exclusion_reason(mfa, exclusions) != nil or
          exclusion_reason(module, function, exclusions) != nil
      end)
      |> MapSet.new()

    MapSet.new()
    |> MapSet.union(scanned_functions)
    |> MapSet.union(graph_candidates)
    |> MapSet.union(MapSet.new(@debugger_explicit_roots))
    |> MapSet.union(tier_roots)
    |> MapSet.union(exclusion_roots)
  end

  defp saved_settings_changed_family_universe(graph, record) do
    inspections =
      Enum.filter(graph.inspected, &(&1.module_atom in @saved_settings_changed_modules))

    inspected_modules = MapSet.new(inspections, & &1.module_atom)

    assert inspected_modules == MapSet.new(@saved_settings_changed_modules),
           "lane #{graph.lane.name} must inspect every source module in the saved-settings callback family"

    scanned_functions =
      Enum.reduce(inspections, MapSet.new(), fn inspection, functions ->
        assert {:ok, scan} = BeamWalker.scan(inspection.path)
        assert scan.module == inspection.module_atom
        MapSet.union(functions, MapSet.new(scan.function_mfas))
      end)

    graph_candidates =
      graph
      |> debugger_graph_candidates()
      |> Enum.filter(fn {module, _function, _arity} ->
        module in @saved_settings_changed_modules
      end)
      |> MapSet.new()

    source_only_obligations = MapSet.new(record.source_branches, & &1.mfa)

    scanned_functions
    |> MapSet.union(graph_candidates)
    |> MapSet.union(source_only_obligations)
    |> MapSet.to_list()
    |> Enum.sort()
  end

  defp debugger_family_mfa?({module, _function, _arity}),
    do: module in @debugger_family_modules

  defp debugger_family_mfa?(_candidate), do: false

  defp debugger_graph_candidates(graph) do
    graph.full_edges
    |> Enum.flat_map(fn {caller, callee} -> [caller, callee] end)
    |> Kernel.++(MapSet.to_list(graph.full_reached))
    |> Kernel.++(MapSet.to_list(graph.full_exported))
    |> Enum.filter(&match?({_, _, _}, &1))
    |> MapSet.new()
  end

  defp debugger_exclusion_matches(universe, exclusions) do
    Enum.flat_map(exclusions, &debugger_exclusion_match(universe, &1))
  end

  defp debugger_exclusion_match(universe, exclusion) do
    matches = Enum.filter(universe, &debugger_exclusion_matches_mfa?(&1, exclusion))
    debugger_exclusion_record(exclusion, matches)
  end

  defp debugger_exclusion_matches_mfa?({module, function, _arity} = mfa, exclusion) do
    exact_mfa_exclusion_reason(mfa, [exclusion]) != nil or
      exclusion_reason(module, function, [exclusion]) != nil
  end

  defp debugger_exclusion_matches_mfa?(_mfa, _exclusion), do: false

  defp debugger_exclusion_record(_exclusion, []), do: []

  defp debugger_exclusion_record(exclusion, matches) do
    reason = if tuple_size(exclusion) >= 2, do: elem(exclusion, 1), else: :unknown
    citations = if tuple_size(exclusion) >= 3, do: elem(exclusion, 2), else: []

    [
      %{
        original_identity: exclusion,
        cited_triple: {elem(exclusion, 0), reason, citations},
        matched_mfas: Enum.sort(matches)
      }
    ]
  end

  defp assert_debugger_exclusion_witnesses!(matches, graph, tier, names, exclusions) do
    active = %{reverse: graph.reverse, exported: graph.exported}

    for match <- matches do
      without_original = List.delete(exclusions, match.original_identity)
      newly_uncovered = undisposed(active, tier, names, without_original)

      assert Enum.any?(match.matched_mfas, &(&1 in newly_uncovered)),
             "lane #{graph.lane.name} retained exclusion #{inspect(match.original_identity)} " <>
               "has no individual active removal witness for its complete matched set " <>
               "#{inspect(match.matched_mfas)}"
    end
  end

  defp assert_debugger_function_inventory!(
         actual_universe,
         source_mfas,
         review_mfas,
         expected_mfas,
         lane
       ) do
    source_set = MapSet.new(source_mfas)
    review_set = MapSet.new(review_mfas)
    expected_set = MapSet.new(expected_mfas)

    assert length(source_mfas) == MapSet.size(source_set),
           "lane #{lane} app debugger source inventory contains duplicate functions"

    assert length(review_mfas) == MapSet.size(review_set),
           "lane #{lane} app debugger semantic inventory contains duplicate functions"

    assert length(expected_mfas) == MapSet.size(expected_set),
           "lane #{lane} app debugger expected function specification contains duplicates"

    missing_source = MapSet.difference(actual_universe, source_set)
    missing_review = MapSet.difference(actual_universe, review_set)
    missing_expected = MapSet.difference(actual_universe, expected_set)
    not_installed = MapSet.difference(MapSet.union(source_set, review_set), actual_universe)

    assert source_set == review_set and source_set == expected_set and
             actual_universe == source_set,
           "lane #{lane} app debugger assigned function inventory differs from the independent " <>
             "installed universe; missing source=#{debugger_function_diagnostics(missing_source)}; " <>
             "missing semantic review=#{debugger_function_diagnostics(missing_review)}; " <>
             "missing expected spec=#{debugger_function_diagnostics(missing_expected)}; " <>
             "not installed=#{debugger_function_diagnostics(not_installed)}"
  end

  defp assert_debugger_root_inventory!(graph_candidates, assigned_roots, lane) do
    baseline = MapSet.new(@debugger_baseline_roots)
    assigned = MapSet.new(assigned_roots)
    missing_assignment = MapSet.difference(baseline, assigned)
    missing_graph = MapSet.difference(assigned, graph_candidates)

    assert MapSet.size(missing_assignment) == 0 and MapSet.size(missing_graph) == 0,
           "lane #{lane} app debugger assigned root inventory differs from the pinned baseline " <>
             "or independent graph; omitted assigned roots=#{debugger_function_diagnostics(missing_assignment)}; " <>
             "roots absent from graph=#{debugger_function_diagnostics(missing_graph)}"
  end

  defp assert_debugger_active_scope!(graph, assigned_modules, lane) do
    assigned = MapSet.new(assigned_modules)
    baseline = MapSet.new(@debugger_baseline_active_modules)
    active = graph.active_modules
    pending = MapSet.new(DebuggerPendingOwnership.baseline_modules())
    pending_rows = MapSet.new(graph.pending_modules, & &1.module_atom)

    pending_owner_error =
      DebuggerPendingOwnership.validation_error(DebuggerPendingOwnership.owners())

    omitted_baseline = MapSet.difference(baseline, assigned)
    inactive_assigned = MapSet.difference(assigned, active)
    active_pending = MapSet.intersection(active, pending)
    missing_pending_rows = MapSet.difference(pending, pending_rows)

    assert MapSet.size(omitted_baseline) == 0 and MapSet.size(inactive_assigned) == 0 and
             MapSet.size(active_pending) == 0 and MapSet.size(missing_pending_rows) == 0 and
             is_nil(pending_owner_error),
           "lane #{lane} app debugger active/pending ownership differs; " <>
             "active debugger slice omitted baseline modules=#{inspect(Enum.sort(omitted_baseline))}; " <>
             "assigned modules absent from active view=#{inspect(Enum.sort(inactive_assigned))}; " <>
             "pending debugger modules are active=#{debugger_pending_diagnostics(active_pending)}; " <>
             "pending modules absent from pending rows=#{debugger_pending_diagnostics(missing_pending_rows)}; " <>
             "pending debugger ownership map differs=#{pending_owner_error || "none"}"
  end

  defp debugger_function_diagnostics(mfas) do
    mfas
    |> Enum.sort()
    |> Enum.map_join("; ", &debugger_function_diagnostic/1)
  end

  defp debugger_function_diagnostic({module, function, arity} = mfa) do
    case Map.get(@debugger_function_reviews, mfa) do
      %{owner: owner, trace: trace} ->
        "#{module}:#{function}/#{arity} owner=#{Atom.to_string(owner)} " <>
          "caller-chain=#{debugger_trace_diagnostic(trace)}"

      _ ->
        "#{module}:#{function}/#{arity} owner=unassigned caller-chain=unrecorded"
    end
  end

  defp debugger_trace_diagnostic(trace) do
    Enum.map_join(trace, " -> ", fn
      {module, function, arity} -> "#{module}:#{function}/#{arity}"
      other -> inspect(other)
    end)
  end

  defp debugger_pending_diagnostics(modules) do
    modules
    |> Enum.sort()
    |> Enum.map_join("; ", fn module ->
      "#{module} owner=#{Map.get(DebuggerPendingOwnership.owners(), module, "unassigned")}"
    end)
  end

  defp assert_debugger_installed_wide_acceptance!(
         graph,
         evidence,
         baseline_records,
         parent_owner_records,
         settings_records,
         receipt_lines
       ) do
    lane = graph.lane.name
    tier = BannedCalls.banned_mfas()

    baseline_record = Enum.find(baseline_records, &(&1.lane == lane))
    assert baseline_record != nil, "expected the current lane's parent debugger baseline"

    parent_owner_rows =
      Enum.filter(parent_owner_records, fn row ->
        row["t"] == "root" and row["lane"] == lane and row["app"] == "debugger" and
          row["module"] == "dbg_wx_interpret" and row["function"] == "start" and
          row["arity"] == 4
      end)

    assert length(parent_owner_rows) == 1,
           "expected exactly one adopted parent owner row for #{lane} dbg_wx_interpret:start/4"

    parent_owner_record = hd(parent_owner_rows)
    assert parent_owner_record["owner"] == "01.1.1.3"

    assert_debugger_audit!(baseline_records, graph, tier, evidence, @exclusions)

    ownership = DebuggerSettings.assert_ownership!(graph, evidence, settings_records)

    saved_settings =
      DebuggerSettings.assert_receipt!(graph, evidence, settings_records, receipt_lines)

    remainder =
      DebuggerSettings.assert_remainder_receipt!(graph, evidence, settings_records, receipt_lines)

    installed_receipt = InstalledOtp.verify_receipt_lines!(receipt_lines)

    assert graph.lane.name == evidence.lane.name
    assert ownership.status == :verified
    assert saved_settings.status == :verified
    assert remainder.status == :verified
    assert installed_receipt.lane == lane
    assert ownership.lane == lane
    assert saved_settings.lane == lane
    assert remainder.lane == lane
    assert settings_records.lane == lane
    assert settings_records.owner == "01.1.1.3.1.1"
    assert remainder.owner == "01.1.1.3.1.2"

    assert MapSet.new(ownership.selected_roots) ==
             MapSet.new([
               {"debugger", "dbg_wx_mon", "start", 2},
               {"debugger", "dbg_wx_mon", "load_settings", 2},
               {"debugger", "dbg_wx_mon", "load_settings2", 2}
             ])

    assert remainder.inherited_pending == %{
             callback_body: "dbg_icmd:break_p/4",
             selected_roots: [
               "dbg_wx_mon:load_settings/2",
               "dbg_wx_mon:load_settings2/2",
               "dbg_wx_mon:start/2"
             ]
           }

    receipt_sha256 = InstalledOtp.verify_receipt_lines!(graph.receipt_lines).sha256

    assert ownership.receipt_sha256 == receipt_sha256
    assert saved_settings.receipt_sha256 == receipt_sha256
    assert remainder.receipt_sha256 == receipt_sha256
    assert installed_receipt.sha256 == receipt_sha256

    archive_path = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)

    source_archive_sha256 =
      archive_path
      |> File.read!()
      |> then(fn bytes -> :crypto.hash(:sha256, bytes) end)
      |> Base.encode16(case: :lower)

    assert source_archive_sha256 == SweepEvidence.archive_sha256()

    selected_roots =
      ownership.selected_roots
      |> Enum.map(fn {app, module, function, arity} ->
        "#{app}:#{module}:#{function}/#{arity}"
      end)
      |> Enum.sort()

    %{
      "lane" => lane,
      "scope" => "debugger_static_source_and_beam_acceptance",
      "proof_limitations" => [
        "debugger_entrypoints_callbacks_and_user_supplied_input_not_invoked",
        "no_runtime_safety_claim",
        "parent_global_gate_later_debugger_assignments_and_sec_01_not_closed"
      ],
      "receipt_sha256" => receipt_sha256,
      "source_archive_sha256" => source_archive_sha256,
      "baseline_source_sha256" => baseline_record.source_sha256,
      "selected_settings_source_sha256" => settings_records.source_sha256,
      "remainder_source_sha256" => remainder.source_sha256,
      "owners" => [
        %{
          "owner" => parent_owner_record["owner"],
          "status" => "inherited-baseline-validated",
          "identities" => ["dbg_wx_interpret:start/4"]
        },
        %{
          "owner" => settings_records.owner,
          "status" => "verified",
          "identities" => ["dbg_wx_settings"] ++ selected_roots
        },
        %{
          "owner" => remainder.owner,
          "status" => "verified",
          "source_modules" => Enum.sort(Map.keys(remainder.source_sha256))
        }
      ],
      "inherited_pending" => remainder.inherited_pending
    }
  end

  defp debugger_parent_owner_records! do
    ledger_path =
      Path.expand(
        "../../.planning/milestones/v0.1-phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz",
        __DIR__
      )

    rows =
      ledger_path
      |> File.read!()
      |> :zlib.gunzip()
      |> String.split("\n", trim: true)
      |> Enum.map(&JSON.decode!/1)
      |> Enum.filter(fn row ->
        row["t"] == "root" and row["app"] == "debugger" and
          row["module"] == "dbg_wx_interpret" and row["function"] == "start" and
          row["arity"] == 4
      end)

    assert MapSet.new(Enum.map(rows, & &1["lane"])) == MapSet.new(["core", "floor"]),
           "expected one adopted parent owner row for each exact lane"

    assert Enum.all?(rows, &(&1["owner"] == "01.1.1.3")),
           "expected the adopted parent owner to remain 01.1.1.3"

    rows
  end

  defp assert_debugger_audit!(records, graph, tier, evidence, exclusions) do
    lane = evidence.lane.name
    lane_source = Map.fetch!(@debugger_source_by_lane, lane)
    lane_records = Enum.filter(records, &(&1.lane == lane))
    mfa = @debugger_selected_file_mfa
    family_universe = debugger_family_universe(graph, tier, exclusions)

    assert graph.lane.name == lane,
           "evidence lane #{lane} does not match inspected graph lane #{graph.lane.name}"

    assert length(records) == length(@debugger_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@debugger_expected_ids)

    assert length(lane_records) == 1

    assert MapSet.new(Enum.map(lane_records, &{&1.original_id, &1.lane})) ==
             MapSet.new(Enum.filter(@debugger_expected_ids, &(elem(&1, 1) == lane)))

    expected_exports = MapSet.new(@debugger_expected_exports)

    actual_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) in @debugger_family_modules))
      |> MapSet.new()

    assert actual_exports == expected_exports,
           "the complete exact-lane debugger family export set differs from reviewed sources"

    graph_candidates = debugger_graph_candidates(graph)
    assert_debugger_root_inventory!(graph_candidates, @debugger_explicit_roots, lane)

    assert MapSet.member?(graph.full_reached, mfa)

    decoder_mfa = {:dbg_istk, :from_external, 1}
    assert MapSet.member?(graph.full_exported, decoder_mfa)
    assert decoder_mfa in @debugger_explicit_roots

    active_exports =
      graph.exported
      |> Enum.filter(&(elem(&1, 0) in @debugger_family_modules))
      |> MapSet.new()

    assert active_exports == expected_exports,
           "lane #{lane} active debugger exports do not preserve the exact assigned family"

    assert_debugger_active_scope!(graph, @debugger_active_modules, lane)

    record = hd(lane_records)
    assert record.original_id == "NEW-DEBUGGER-#{String.upcase(lane)}-dbg_wx_interpret-start-4"
    assert record.original_matcher == {:mfa, mfa}
    assert record.original_reason == :tier
    assert record.matched_mfas == [mfa]
    assert record.caller_input == :caller_selected_filenames_and_directory
    assert record.defaults == :monitor_supplied_local_or_global_mode
    assert record.option_paths == [:local, :global]

    assert record.trace == [
             {:dbg_wx_mon, :gui_cmd, 2},
             {:dbg_wx_interpret, :start, 4},
             {:dbg_wx_filedialog_win, :getFilenames, 1},
             {:dbg_wx_filedialog_win, :getDirectory, 1},
             {:dbg_wx_interpret, :interpret_all, 5},
             {:filename, :join, 2},
             {:int, :i, 1},
             {:int, :ni, 1}
           ]

    assert record.verdict == :caller_selected_files_reach_interpreter
    assert record.replacements == %{mfa => {:tier, mfa}}
    assert record.tier == [mfa]

    assert record.fixtures == [
             :direct,
             :capture,
             :apply,
             :utf8_literal,
             :discarded_quote,
             :uninvoked_macro
           ]

    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == :uncalled_probe_mfa_tier_reduction
    assert record.source_sha256 == lane_source.sha256
    assert record.citations == lane_source.citations
    assert record.export_citations == lane_source.export_citations
    assert record.family_function_sources == lane_source.family_function_sources
    assert record.family_function_audit == lane_source.family_function_audit
    assert record.branch_citations == lane_source.branch_citations
    assert record.ui_provenance_citations == lane_source.ui_provenance_citations
    assert record.cross_owner_support_citations == lane_source.cross_owner_support_citations
    assert record.empty_selection == :source_disposed_without_invocation
    assert record.decoder_mfa == decoder_mfa
    assert record.decoder_caller_input == :arbitrary_exported_stack_binary
    assert record.decoder_options == :binary_to_term_without_safe_option

    assert record.decoder_trace == [
             {:dbg_ieval, :exit_info, 5},
             {:dbg_istk, :from_external, 1},
             {:erlang, :binary_to_term, 1},
             :process_dictionary_stack_write
           ]

    assert record.decoder_verdict == :caller_binary_is_unconstrained_at_export

    assert record.decoder_fixtures == [
             :direct,
             :capture,
             :apply,
             :discarded_quote,
             :uninvoked_macro,
             :serializing_only_control
           ]

    assert record.decoder_removal_witness == :uncalled_probe_mfa_tier_reduction

    assert record.internal_provenance == %{
             producer: {:dbg_istk, :delayed_to_external, 0},
             encoder: {:erlang, :term_to_binary, 1},
             observed_consumer: {:dbg_ieval, :exit_info, 5},
             verdict: :observed_internal_round_trip_does_not_constrain_public_input
           }

    assert record.decoder_citations == lane_source.decoder_citations
    assert record.decoder_provenance_citations == lane_source.decoder_provenance_citations

    assert record.limitations == [
             :no_runtime_filename_decoding_claim,
             :no_computed_dispatch_claim,
             :no_write_then_load_claim,
             :no_runtime_atom_count_claim
           ]

    assert MapSet.new(Map.keys(record.branch_citations)) ==
             MapSet.new([
               :database_dispatch,
               :stack_lifecycle,
               :stack_trace,
               :dialog_return,
               :dialog_cancel,
               :parser_filter,
               :selected_files,
               :empty_and_errors
             ])

    assert Enum.all?(record.branch_citations, fn {_group, citations} -> citations != [] end)

    source_function_mfas = Enum.map(record.family_function_sources, &elem(&1, 0))
    reviewed_function_mfas = Enum.map(record.family_function_audit, & &1.mfa)
    actual_function_mfas = family_universe

    assert_debugger_function_inventory!(
      actual_function_mfas,
      source_function_mfas,
      reviewed_function_mfas,
      @debugger_expected_family_mfas,
      lane
    )

    assert MapSet.new(source_function_mfas) == MapSet.new(@debugger_expected_family_mfas),
           "lane #{lane} app debugger source identities differ from the assigned reviewed set"

    assert debugger_function_audit_complete?(record.family_function_audit),
           "lane #{lane} app debugger has a function row without input/default/option/trace/verdict/source/owner"

    expected_seed_dispositions =
      Enum.zip(@debugger_source_only_seed_mfas, lane_source.seed_citations)
      |> Enum.map(fn {seed_mfa, citation} ->
        %{
          mfa: seed_mfa,
          reached: false,
          verdict: :source_disposed_without_graph_hit,
          citation: citation
        }
      end)

    assert record.seed_dispositions == expected_seed_dispositions,
           "lane #{lane} omitted or invented a source-only debugger seed disposition"

    for seed_mfa <- @debugger_source_only_seed_mfas do
      refute MapSet.member?(graph.full_reached, seed_mfa),
             "lane #{lane} source-only seed #{inspect(seed_mfa)} was absent from full_reached"
    end

    assert record.ui_provenance == %{
             module_list_origin: {:int, :interpreted, 0},
             module_name_display: :atom_to_list,
             checkbox_labels: ["First Call", "On Break", "On Exit"],
             label_conversion: :list_to_atom,
             callback_owner: :phase_01_1_1_3_1,
             callback_verdict: :synthetic_events_and_keyboard_inputs_pending
           }

    assert record.cross_owner_support == %{
             dbg_iload: :cited_support_only_whole_module_review_pending,
             dbg_ieval: :decoder_consumer_provenance_only,
             dbg_wx_filedialog_win: :dialog_getters_only,
             dbg_wx_mon: :module_list_origin_only,
             dbg_wx_mon_win: :labels_and_callback_boundary_only,
             dbg_wx_win: :error_dialog_provenance_only
           }

    exclusion_matches = debugger_exclusion_matches(actual_function_mfas, exclusions)
    assert record.exclusion_matches == @debugger_expected_exclusion_matches

    assert exclusion_matches == record.exclusion_matches,
           "lane #{lane} changed debugger exclusion match set or original identity"

    assert record.exclusion_identity_replacements == %{}

    assert_debugger_exclusion_witnesses!(
      exclusion_matches,
      graph,
      tier,
      BannedCalls.banned_names(),
      exclusions
    )

    for {relative_path, expected_sha} <- lane_source.sha256 do
      archived_path = "#{lane}/#{relative_path}"

      row = Enum.find(evidence.manifest["files"], &(&1["path"] == archived_path))
      assert row != nil, "missing exact-lane source record #{archived_path}"

      assert row["status"] == "present",
             "lane #{lane} source record #{archived_path} claims absence or non-present status"

      assert row["source_path"] == relative_path
      assert row["sha256"] == expected_sha
    end

    assert map_size(lane_source.sha256) == 9

    branch_citations = record.branch_citations |> Map.values() |> List.flatten()
    family_citations = Enum.map(record.family_function_sources, &elem(&1, 1))
    function_citations = Enum.flat_map(record.family_function_audit, & &1.citations)

    all_source_citations =
      record.citations ++
        record.export_citations ++
        family_citations ++
        function_citations ++
        branch_citations ++
        record.decoder_citations ++
        record.decoder_provenance_citations ++
        record.ui_provenance_citations ++
        record.cross_owner_support_citations

    for {citation, expected_source} <- all_source_citations do
      [relative_file, _line] = String.split(citation, ":", parts: 2)
      expected_sha = Map.fetch!(lane_source.sha256, relative_file)
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.origin in [:archive, :installed], citation
      assert resolved.sha256 == expected_sha, citation
      assert resolved.text =~ expected_source, citation
    end

    assert covered?(mfa, tier, BannedCalls.banned_names()),
           "lane #{lane} selected-file root must retain its exact MFA tier"

    assert exact_mfa_exclusion_reason(mfa, exclusions) == nil
    assert exclusion_reason(elem(mfa, 0), elem(mfa, 1), exclusions) == nil

    assert covered?(decoder_mfa, tier, BannedCalls.banned_names()),
           "lane #{lane} exported stack decoder must retain its exact MFA tier"

    assert {:dbg_istk, :from_external, 1} in BannedCalls.banned_mfas()
    assert :binary_to_term in BannedCalls.banned_names()
    assert exact_mfa_exclusion_reason(decoder_mfa, exclusions) == nil
    assert exclusion_reason(elem(decoder_mfa, 0), elem(decoder_mfa, 1), exclusions) == nil
  end

  defp debugger_function_audit_complete?(reviews) do
    Enum.all?(reviews, fn review ->
      review.caller_input != nil and review.defaults != nil and review.option_paths != nil and
        review.trace != [] and review.verdict != nil and review.owner == :plan_02 and
        review.citations != []
    end)
  end

  defp assert_ct_make_audit!(records, graph, tier, evidence, exclusions \\ @exclusions) do
    lane = evidence.lane.name
    lane_source = Map.fetch!(@ct_make_source_by_lane, lane)
    lane_records = Enum.filter(records, &(&1.lane == lane))

    expected_ids =
      @ct_make_expected_ids
      |> Enum.filter(&(elem(&1, 1) == lane))
      |> MapSet.new()

    assert length(records) == length(@ct_make_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@ct_make_expected_ids)

    assert length(lane_records) == length(@ct_make_family_specs)
    assert MapSet.new(Enum.map(lane_records, &{&1.original_id, &1.lane})) == expected_ids

    actual_exports =
      graph.full_exported
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    active_exports =
      graph.exported
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    reached_exports = MapSet.intersection(actual_exports, graph.full_reached)
    active_reached_exports = MapSet.intersection(active_exports, graph.active_reached)
    expected_exports = MapSet.new(@ct_make_expected_mfas)
    expected_reached = MapSet.new(@ct_make_expected_reached_mfas)

    actual_reached =
      graph.full_reached
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    active_reached =
      graph.active_reached
      |> Enum.filter(&(elem(&1, 0) == :ct_make))
      |> MapSet.new()

    assert actual_exports == expected_exports,
           "the complete exact-lane ct_make export set differs from its four audited rows"

    assert MapSet.new(Enum.flat_map(lane_records, & &1.matched_mfas)) == actual_exports
    assert reached_exports == expected_exports
    assert active_exports == expected_exports
    assert active_reached_exports == expected_exports

    assert actual_reached == expected_reached,
           "the exact-lane ct_make reached set differs from the reviewed caller/load paths"

    assert active_reached == expected_reached
    assert MapSet.member?(graph.active_modules, :ct_make)
    assert Enum.any?(graph.pending_apps, &(&1.app == "common_test"))
    refute Enum.any?(graph.pending_modules, &(&1.module_atom == :ct_make))

    refute Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_app" and row["app"] == "common_test"
           end)

    assert Enum.any?(graph.active_membership, fn row ->
             row["kind"] == "active_module" and row["app"] == "common_test" and
               row["module"] == "ct_make"
           end)

    for spec <- @ct_make_family_specs do
      mfa = spec.mfa
      {module, function, _arity} = mfa

      record =
        Enum.find(
          lane_records,
          &(&1.original_id == "CT-#{String.upcase(lane)}-ct_make-#{function}-#{elem(mfa, 2)}")
        )

      assert record != nil, "missing CT record for #{inspect(mfa)} on #{lane}"
      assert record.original_matcher == {:mfa, mfa}
      assert record.original_reason == :tier
      assert record.matched_mfas == [mfa]
      assert record.caller_input == spec.caller_input
      assert record.defaults == spec.defaults
      assert record.option_paths == spec.option_paths
      assert record.trace == spec.trace
      assert record.verdict == spec.verdict
      assert record.replacements == %{mfa => {:tier, mfa}}
      assert record.tier == [mfa]
      assert record.fixtures == spec.fixtures
      assert record.applicability == :each_exact_installed_lane
      assert record.removal_witness == :individual_exact_mfa
      assert record.source_sha256 == lane_source.sha256

      assert covered?(mfa, tier, BannedCalls.banned_names()),
             "#{inspect(mfa)} has no replacement tier"

      assert exact_mfa_exclusion_reason(mfa, exclusions) == nil,
             "#{inspect(mfa)} has a redundant exact exclusion"

      assert exclusion_reason(module, function, exclusions) == nil,
             "#{inspect(mfa)} has a redundant broad exclusion"

      expected_citations = Enum.flat_map(spec.source_groups, &Map.fetch!(lane_source.groups, &1))
      assert record.citations == expected_citations
      assert_ct_make_trace_call_sites!(spec, record, mfa)

      for {citation, expected_source} <- record.citations do
        resolved = SweepEvidence.resolve!(evidence, citation)
        assert resolved.origin in [:archive, :installed], citation
        assert resolved.sha256 == lane_source.sha256, citation
        assert resolved.text =~ expected_source, citation
      end

      tier_without_front = Enum.reject(tier, &(&1 == mfa))

      assert mfa in undisposed(graph, tier_without_front, BannedCalls.banned_names(), exclusions),
             "removing only #{inspect(mfa)} must expose that previously covered front"
    end
  end

  defp assert_ct_make_trace_call_sites!(spec, record, mfa) do
    for {target_mfa, expected_callsite} <- Map.get(spec, :trace_call_sites, []) do
      assert target_mfa in record.trace,
             "#{inspect(target_mfa)} is missing from the trace for #{inspect(mfa)}"

      assert Enum.any?(record.citations, fn {_citation, source_line} ->
               String.contains?(source_line, expected_callsite)
             end),
             "#{inspect(mfa)} lacks an exact source citation for #{inspect(target_mfa)}"
    end
  end

  defp assert_creator_audit!(records, graph, tier, evidence, exclusions \\ @exclusions) do
    assert length(records) == length(@creator_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@creator_expected_ids)

    record = Enum.find(records, &(&1.lane == evidence.lane.name))
    assert record != nil, "no creator audit row for #{evidence.lane.name}"
    assert record.original_id == "EX-159"
    assert record.original_matcher == {:file, [:path_consult, :consult]}
    assert record.original_reason == :pure_data
    assert MapSet.new(record.matched_mfas) == MapSet.new(@creator_expected_original_mfas)
    assert record.trace == @creator_expected_trace
    assert record.verdict == :caller_term_text_reaches_atom_creation
    assert MapSet.new(record.replacements) == MapSet.new(@creator_expected_original_mfas)
    assert MapSet.new(record.tier) == MapSet.new(@creator_expected_original_mfas)
    assert record.fixtures == @creator_expected_fixtures
    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == :not_applicable_tiered

    for {citation, expected} <- record.citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
    end

    citation_lines = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))

    assert citation_lines ==
             MapSet.new(Map.fetch!(@creator_expected_citation_lines, evidence.lane.name))

    live_matches =
      graph.exported
      |> Enum.filter(&creator_original_match?(record.original_matcher, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> MapSet.new()

    assert live_matches == MapSet.new(record.matched_mfas),
           "#{record.original_id} original matcher differs from live exports"

    for {module, function, arity} = mfa <- record.matched_mfas do
      assert covered?(mfa, tier, BannedCalls.banned_names()),
             "#{inspect(mfa)} has no replacement tier"

      assert exclusion_reason(module, function, exclusions) == nil,
             "#{inspect(mfa)} was given a false safe disposition"

      assert arity > 0
    end
  end

  defp assert_leex_audit!(records, graph, tier, names, evidence, ledger, exclusions) do
    assert length(records) == length(@leex_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@leex_expected_ids)

    record = Enum.find(records, &(&1.lane == evidence.lane.name))
    assert record != nil, "no EX-165 Leex audit row for #{evidence.lane.name}"
    assert record.original_id == "EX-165"
    assert record.original_matcher == {:leex, [:file]}
    assert record.original_reason == :compiler_pass
    assert record.matched_mfas == @leex_expected_mfas
    assert record.trace == @leex_expected_trace
    assert record.verdict == @leex_expected_verdict
    assert record.replacement_disposition == :exact_mfa_tier
    assert record.replacements == @leex_expected_replacements
    assert record.tier == @leex_expected_mfas
    assert record.fixtures == @leex_expected_fixtures
    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == @leex_expected_removal_witness
    assert record.citations == Map.fetch!(@leex_source_assertions_by_lane, evidence.lane.name)

    original = Enum.find(ledger.exclusions, &(&1.id == "EX-165"))
    assert original != nil, "the original EX-165 identity is missing"

    assert original.original_entry_raw ==
             "{{:leex, [:file]}, :compiler_pass, [\"parsetools/src/leex.erl:473\", \"parsetools/src/leex.erl:467\"]}"

    assert original.original_matcher_raw == inspect(record.original_matcher)
    assert original.original_reason_raw == ":compiler_pass"
    assert original.semantic_status == :leex_replaced_by_tier
    assert original.owner == "01.1.1.14"
    assert original.current_replacement_refs == ["creator:EX-165:core", "creator:EX-165:floor"]

    expected_lane_matches =
      Map.new(@creator_expected_lanes, fn lane ->
        {lane, MapSet.new(["leex:file/1", "leex:file/2"])}
      end)

    actual_lane_matches =
      Map.new(original.lane_matches, fn {lane, matches} -> {lane, MapSet.new(matches)} end)

    assert actual_lane_matches == expected_lane_matches

    archive_only = %{
      evidence
      | installed:
          evidence.installed
          |> Map.put("mix", Path.join(evidence.archive_root, "missing-mix"))
          |> Map.put("parsetools", Path.join(evidence.archive_root, "missing-parsetools"))
    }

    source_hashes = Map.fetch!(@leex_source_sha256_by_lane, evidence.lane.name)

    citation_paths =
      MapSet.new(
        Enum.map(record.citations, fn {citation, _} -> citation_source_path!(citation) end)
      )

    assert citation_paths == MapSet.new(Map.keys(source_hashes))

    for {citation, expected_text} <- record.citations do
      resolved = SweepEvidence.resolve!(archive_only, citation)
      assert resolved.origin == :archive, citation
      assert resolved.text =~ expected_text, citation

      assert resolved.sha256 == Map.fetch!(source_hashes, citation_source_path!(citation)),
             citation
    end

    live_matches =
      graph.full_exported
      |> Enum.filter(&creator_original_match?(record.original_matcher, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> MapSet.new()

    assert live_matches == MapSet.new(@leex_expected_mfas),
           "EX-165 original matcher differs from the full installed export set"

    lane_matches = Map.fetch!(original.lane_matches, evidence.lane.name)

    assert MapSet.new(Enum.map(record.matched_mfas, &mfa_string!/1)) == MapSet.new(lane_matches),
           "EX-165/#{evidence.lane.name} differs from its pinned original match set"

    refute Enum.any?(exclusions, fn
             {{:leex, functions}, _reason, _citations} when is_list(functions) ->
               :file in functions

             {{:leex, functions}, _reason} when is_list(functions) ->
               :file in functions

             _entry ->
               false
           end),
           "the superseded EX-165 exclusion remains active"

    for {module, function, _arity} = mfa <- record.matched_mfas do
      assert mfa in tier, "#{inspect(mfa)} is missing its exact active tier entry"
      assert covered?(mfa, tier, names), "#{inspect(mfa)} has no replacement guard tier"
      assert disposition(mfa, tier, names, exclusions) == :tier
      assert exact_mfa_exclusion_reason(mfa, exclusions) == nil
      assert exclusion_reason(module, function, exclusions) == nil

      refute Enum.any?(@call_name_exclusions, fn {matcher, _reason, _citations} ->
               call_name_exclusion_match?(matcher, mfa)
             end),
             "#{inspect(mfa)} overlaps a call-name exclusion"

      tier_without_mfa = Enum.reject(tier, &(&1 == mfa))

      refute covered?(mfa, tier_without_mfa, names),
             "removing only #{inspect(mfa)} must expose the exact match"

      assert disposition(mfa, tier_without_mfa, names, exclusions) == nil,
             "another tier or exclusion still covers #{inspect(mfa)}"
    end

    assert Enum.map(record.matched_mfas, &mfa_string!/1) == record.removal_witness
  end

  defp assert_asn1_table_audit!(graph, evidence, ledger, tier) do
    lane = evidence.lane.name

    archive_only = %{
      evidence
      | installed:
          Map.put(evidence.installed, "asn1", Path.join(evidence.archive_root, "missing-asn1"))
    }

    row = Enum.find(ledger.exclusions, &(&1.id == "EX-107"))
    assert row != nil, "the original EX-107 identity is missing"
    assert row.original_entry_raw == "{{:prefix, \":asn1ct_\"}, :compiler_pass}"
    assert row.semantic_status == :pending
    assert row.owner == "01.1.1.4"

    lane_matches = Map.fetch!(row.lane_matches, lane) |> MapSet.new()

    live_matches =
      graph.full_exported
      |> Enum.filter(&asn1_original_match?/1)
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.map(&mfa_string!/1)
      |> MapSet.new()

    assert live_matches == lane_matches,
           "EX-107/#{lane} differs from its unchanged full lane export match set"

    assert MapSet.size(lane_matches) == 177

    selected = MapSet.new(Enum.map(@asn1_expected_selected_mfas, &mfa_string!/1))
    assert MapSet.size(selected) == 13
    assert MapSet.subset?(selected, lane_matches)
    pending = MapSet.difference(lane_matches, selected)
    assert MapSet.size(pending) == 164

    external_transform_selected =
      MapSet.new(Enum.map(@asn1_external_transform_mfas, &mfa_string!/1))

    assert MapSet.subset?(external_transform_selected, lane_matches),
           "EX-107/#{lane} is missing one of the exact external-transform selections"

    assert MapSet.size(MapSet.difference(lane_matches, external_transform_selected)) == 175,
           "EX-107/#{lane} external-transform slice must preserve the other 175 matches"

    parser_tokenizer_selected =
      MapSet.new([
        "asn1ct_parser2:parse/2",
        "asn1ct_parser2:format_error/1",
        "asn1ct_tok:file/1",
        "asn1ct_tok:format_error/1"
      ])

    assert MapSet.subset?(parser_tokenizer_selected, lane_matches),
           "EX-107/#{lane} is missing a selected parser/tokenizer export"

    assert MapSet.size(MapSet.difference(lane_matches, parser_tokenizer_selected)) == 173,
           "EX-107/#{lane} parser/tokenizer slice must preserve the other 173 matches"

    scoped_parser_edges =
      graph.full_edges
      |> Enum.filter(fn
        {_caller, {module, function}} ->
          {module, function} in [
            {:asn1ct_parser2, :parse},
            {:asn1ct_parser2, :format_error},
            {:asn1ct_tok, :file},
            {:asn1ct_tok, :format_error}
          ]

        _edge ->
          false
      end)
      |> MapSet.new()

    expected_parser_edges =
      MapSet.new([
        {{:asn1ct, :scan_pass, 1}, {:asn1ct_tok, :file}},
        {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_tok, :file}},
        {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_parser2, :parse}},
        {{:asn1ct, :parse_pass, 1}, {:asn1ct_parser2, :parse}}
      ])

    assert scoped_parser_edges == expected_parser_edges,
           "EX-107/#{lane} parser/tokenizer incoming edge set differs from the four reviewed caller edges; " <>
             "missing=#{inspect(MapSet.difference(expected_parser_edges, scoped_parser_edges))}; " <>
             "unexpected=#{inspect(MapSet.difference(scoped_parser_edges, expected_parser_edges))}"

    direct_edges =
      graph.full_edges
      |> Enum.filter(fn
        {_caller, {:asn1ct_table, function}}
        when function in [
               :new,
               :new_reuse,
               :exists,
               :size,
               :insert,
               :lookup,
               :match,
               :to_list,
               :delete
             ] ->
          true

        _edge ->
          false
      end)
      |> MapSet.new()

    expected_direct_edges =
      Enum.map(@asn1_expected_direct_edges, fn {caller, {module, function, _arity}} ->
        {caller, {module, function}}
      end)
      |> MapSet.new()

    assert direct_edges == expected_direct_edges,
           "EX-107/#{lane} table edge set differs from the reviewed 28-edge source trace; " <>
             "missing=#{inspect(MapSet.difference(expected_direct_edges, direct_edges))}; " <>
             "unexpected=#{inspect(MapSet.difference(direct_edges, expected_direct_edges))}"

    assert MapSet.size(direct_edges) == 28
    assert direct_edges |> Enum.map(&elem(&1, 0)) |> MapSet.new() |> MapSet.size() == 17

    for {citation, expected} <- Map.fetch!(@asn1_edge_citations_by_lane, lane) do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end

    table_citations = Map.fetch!(@asn1_table_definition_citations_by_lane, lane)

    for mfa = {:asn1ct_table, function, _arity} <- @asn1_table_mfas do
      citations = Map.fetch!(table_citations, function)

      for {citation, expected} <- citations do
        source = SweepEvidence.resolve!(archive_only, citation)
        assert source.origin == :archive
        assert source.text =~ expected, citation
      end

      refute mfa in tier, "#{inspect(mfa)} must remain covered by EX-107"
      assert exclusion_reason(elem(mfa, 0), elem(mfa, 1), @exclusions) == :compiler_pass
    end

    for {citation, expected} <- Map.fetch!(@asn1_gen_insert_citations_by_lane, lane) do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end

    refute @asn1_insert_once_mfa in tier

    assert exclusion_reason(
             elem(@asn1_insert_once_mfa, 0),
             elem(@asn1_insert_once_mfa, 1),
             @exclusions
           ) ==
             :compiler_pass

    check_citations = Map.fetch!(@asn1_check_trace_citations_by_lane, lane)

    for {citation, expected} <- check_citations do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end

    assert @asn1_check_mfa in tier
    assert disposition(@asn1_check_mfa, tier, BannedCalls.banned_names(), @exclusions) == :tier

    assert Enum.any?(check_citations, fn {_citation, text} ->
             String.contains?(text, "list_to_atom")
           end),
           "check/2 disposition must cite its stored-value atom path, not fixed table names"

    tier_without_check = Enum.reject(tier, &(&1 == @asn1_check_mfa))

    refute covered?(@asn1_check_mfa, tier_without_check, BannedCalls.banned_names()),
           "removing the exact check/2 matcher must remove its active guard disposition"

    assert [mfa_string!(@asn1_check_mfa)] == ["asn1ct_check:check/2"]
  end

  defp assert_asn1_parser_tokenizer_audit!(graph, evidence, ledger, tier) do
    lane = evidence.lane.name
    row = Enum.find(ledger.exclusions, &(&1.id == "EX-107"))
    assert row != nil, "the original EX-107 identity is missing"
    assert row.original_entry_raw == "{{:prefix, \":asn1ct_\"}, :compiler_pass}"
    assert row.semantic_status == :pending
    assert row.owner == "01.1.1.4"

    record = Enum.find(ParserTokenizerEvidence.records(), &(&1.lane == lane))
    assert record != nil, "#{lane} parser/tokenizer evidence record is missing"
    assert_parser_tokenizer_record!(record)

    archive_only = %{
      evidence
      | installed:
          Map.put(evidence.installed, "asn1", Path.join(evidence.archive_root, "missing-asn1"))
    }

    assert_parser_source_reviews!(record, evidence, archive_only, lane)
    assert_parser_record_edges!(record, lane)
    assert_parser_graph_edges!(graph, lane)

    selected_exclusions =
      Enum.reject(@exclusions, fn
        {{:prefix, ":asn1ct_"}, :compiler_pass} -> true
        _ -> false
      end) ++ Map.fetch!(@parser_tokenizer_exclusions_by_lane, lane)

    assert_parser_dispositions!(record, tier, selected_exclusions, lane)
    assert_parser_caller_citations!(record, evidence, archive_only, lane)
    assert_parser_omission_controls!(record)
  end

  defp assert_asn1_external_transform_audit!(graph, evidence, ledger, tier) do
    lane = evidence.lane.name
    row = Enum.find(ledger.exclusions, &(&1.id == "EX-107"))
    assert row != nil, "the original EX-107 identity is missing"
    assert row.original_entry_raw == "{{:prefix, \":asn1ct_\"}, :compiler_pass}"
    assert row.semantic_status == :pending
    assert row.owner == "01.1.1.4"

    lane_matches = Map.fetch!(row.lane_matches, lane) |> MapSet.new()

    assert MapSet.subset?(
             MapSet.new(Enum.map(@asn1_external_transform_mfas, &mfa_string!/1)),
             lane_matches
           )

    record = ExternalTransformEvidence.lane_record(lane)
    assert_external_transform_record!(record)
    assert record.original_id == "EX-107"
    assert record.original_entry_raw == row.original_entry_raw
    assert record.owner == row.owner
    assert record.semantic_status == row.semantic_status
    assert MapSet.new(record.selected_mfas) == MapSet.new(@asn1_external_transform_mfas)
    assert String.length(record.caller_input_trace) > 200

    archive_only = %{
      evidence
      | installed:
          Map.put(evidence.installed, "asn1", Path.join(evidence.archive_root, "missing-asn1"))
    }

    identities =
      if lane == "core",
        do: ExternalTransformEvidence.core_identities(),
        else: ExternalTransformEvidence.floor_identities()

    for {path, {bytes, sha256}} <- identities do
      [source_row] =
        Enum.filter(evidence.manifest["files"], &(&1["path"] == "#{lane}/#{path}"))

      assert source_row["bytes"] == bytes
      assert source_row["sha256"] == sha256
      source = SweepEvidence.resolve!(archive_only, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end

    generated_callers =
      record.generated_call_evidence
      |> Enum.map(fn {citation, expected} ->
        source = SweepEvidence.resolve!(archive_only, citation)
        assert source.origin == :archive
        assert source.text =~ expected, citation
        identity = Map.fetch!(identities, source_path(citation))
        assert source.sha256 == elem(identity, 1), citation
        source_path(citation)
      end)
      |> MapSet.new()

    expected_pre_generated_atom_citation =
      if lane == "core",
        do:
          {"asn1/src/asn1ct_constructed_per.erl:450",
           "RecordName = list_to_atom(record_name(Gen, Typename)),"},
        else:
          {"asn1/src/asn1ct_constructed_per.erl:446",
           "RecordName = list_to_atom(record_name(Gen, Typename)),"}

    assert record.pre_generated_atom_evidence == [expected_pre_generated_atom_citation]

    for {citation, expected} <- record.pre_generated_atom_evidence do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
      identity = Map.fetch!(identities, source_path(citation))
      assert source.sha256 == elem(identity, 1), citation
    end

    assert generated_callers ==
             MapSet.new([
               "asn1/src/asn1ct_constructed_ber_bin_v2.erl",
               "asn1/src/asn1ct_constructed_per.erl"
             ])

    for group <- [record.dynamic_dispatch_evidence, record.runtime_template_evidence],
        {citation, expected} <- group do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
      identity = Map.fetch!(identities, source_path(citation))
      assert source.sha256 == elem(identity, 1), citation
    end

    xref_incoming =
      graph.full_edges
      |> Enum.filter(fn
        {_caller, {:asn1ct_eval_ext, function}} ->
          function in [:transform_to_EXTERNAL1994, :transform_to_EXTERNAL1994_maps]

        _edge ->
          false
      end)
      |> MapSet.new()

    assert xref_incoming == MapSet.new(),
           "EX-107/#{lane} ordinary Xref edges changed; source-generated and dynamic paths remain separately cited"

    assert record.ordinary_xref == :no_incoming_edges_is_not_semantic_evidence

    Enum.each(record.reviews, fn review ->
      mfa = review.mfa
      assert review.disposition == :fixed_shape_data_transform
      assert review.removal_witness == :individual_exact_exclusion

      assert mfa not in tier,
             "#{inspect(mfa)} is not source-justified as an active atom-creation guard"

      exclusion = {
        {:mfa, mfa},
        :pure_data,
        Enum.map(review.citations, &elem(&1, 0))
      }

      exclusions = [exclusion]
      assert disposition(mfa, tier, BannedCalls.banned_names(), exclusions) == :pure_data

      assert disposition(
               mfa,
               tier,
               BannedCalls.banned_names(),
               List.delete(exclusions, exclusion)
             ) == nil,
             "removing only the #{lane} #{inspect(mfa)} exclusion must remove its disposition"
    end)

    assert_external_transform_omission_controls!(record, archive_only)
  end

  defp assert_asn1_generator_dispatch_audit!(graph, evidence, ledger, tier) do
    lane = evidence.lane.name

    [record] =
      Enum.filter(GeneratorDispatchIntegrationEvidence.lane_records(), &(&1.lane == lane))

    row = Enum.find(ledger.exclusions, &(&1.id == "EX-107"))
    assert row != nil
    assert row.original_entry_raw == "{{:prefix, \":asn1ct_\"}, :compiler_pass}"
    assert row.semantic_status == :pending
    assert row.owner == "01.1.1.4"

    lane_matches = Map.fetch!(row.lane_matches, lane) |> MapSet.new()

    live_matches =
      graph.full_exported
      |> Enum.filter(&asn1_original_match?/1)
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.map(&mfa_string!/1)
      |> MapSet.new()

    assert live_matches == lane_matches,
           "EX-107/#{lane} differs from the complete live lane match set"

    assert MapSet.size(lane_matches) == 177

    selected_mfas = GeneratorDispatchIntegrationEvidence.selected_mfas()

    selected =
      selected_mfas
      |> Enum.map(&mfa_string!/1)
      |> MapSet.new()

    assert MapSet.size(selected) == 11
    assert MapSet.subset?(selected, lane_matches)
    assert MapSet.size(MapSet.difference(lane_matches, selected)) == 166

    support = record.support
    caller_a = record.caller_a
    caller_b = record.caller_b
    assert support.lane == lane
    assert support.original_id == "EX-107"
    assert support.owner == row.owner
    assert support.semantic_status == row.semantic_status

    selected_records = support.selected_function_evidence
    assert_generator_dispatch_selection!(selected_records, selected)

    dispositions = GeneratorDispatchIntegrationEvidence.dispositions()

    assert MapSet.new(Map.keys(dispositions)) ==
             MapSet.new(GeneratorDispatchIntegrationEvidence.selected_mfas())

    archive_only = %{
      evidence
      | installed:
          evidence.installed
          |> Map.put("asn1", Path.join(evidence.archive_root, "missing-asn1"))
          |> Map.put("stdlib", Path.join(evidence.archive_root, "missing-stdlib"))
    }

    assert_generator_dispatch_sources!(archive_only, [support, caller_a, caller_b], lane)

    assert_generator_dispatch_reviews!(
      archive_only,
      selected_records,
      caller_a.reviews ++ caller_b.reviews,
      lane
    )

    {edges, actual_edges} = assert_generator_dispatch_edges!(graph, record, archive_only, lane)
    assert_generator_dispatch_tampering!(archive_only, edges, lane)
    {guarded, safe_exclusion} = assert_generator_dispatch_guards!(graph, tier, lane)
    assert_generator_dispatch_lib_scope!(graph, guarded)
    assert_generator_dispatch_fixed!(selected_mfas, tier, safe_exclusion, lane)

    assert_generator_dispatch_omissions!(
      selected_records,
      selected,
      edges,
      actual_edges,
      archive_only,
      lane
    )
  end

  defp assert_generator_dispatch_selection!(records, selected) do
    assert selected == MapSet.new(Enum.map(records, &mfa_string!(&1.mfa)))
    assert length(records) == 11
  end

  defp assert_generator_dispatch_sources!(archive_only, records, lane) do
    assert_raise SweepEvidence.Error, ~r/archive_digest/, fn ->
      archive = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
      SweepEvidence.load_archive!(archive, String.duplicate("0", 64))
    end

    sources =
      records
      |> Enum.flat_map(& &1.exact_sources)
      |> Enum.uniq_by(&elem(&1, 0))

    assert length(sources) == 13

    for {path, bytes, sha256} <- sources do
      [source_row] =
        Enum.filter(archive_only.manifest["files"], &(&1["path"] == "#{lane}/#{path}"))

      assert source_row["bytes"] == bytes
      assert source_row["sha256"] == sha256
      source = SweepEvidence.resolve!(archive_only, path <> ":1")
      assert source.origin == :archive
      assert source.sha256 == sha256
      assert File.stat!(source.path).size == bytes
    end
  end

  defp assert_generator_dispatch_reviews!(archive_only, selected_records, reviews, lane) do
    for function <- selected_records do
      assert String.length(function.trace) > 100

      assert_generator_dispatch_citations!(
        archive_only,
        function.citations,
        "#{lane} #{inspect(function.mfa)}"
      )
    end

    for review <- reviews do
      assert_generator_dispatch_citations!(
        archive_only,
        review.citations,
        "#{lane} #{review.source_path}"
      )
    end
  end

  defp assert_generator_dispatch_citations!(archive_only, citations, description) do
    assert citations != [], "#{description} has no source citation"

    for {citation, expected} <- citations do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.text =~ expected, citation
    end
  end

  defp assert_generator_dispatch_edges!(graph, record, archive_only, lane) do
    edges = GeneratorDispatchIntegrationEvidence.all_edges(record)

    actual_edges =
      graph.full_edges
      |> Enum.filter(fn
        {_caller, {module, function}} ->
          module == :asn1ct_func and
            function in Enum.map(
              GeneratorDispatchIntegrationEvidence.selected_mfas(),
              &elem(&1, 1)
            )

        _edge ->
          false
      end)
      |> MapSet.new()

    assert_generator_dispatch_edges_match!(actual_edges, edges, lane)

    for edge <- edges do
      assert_generator_dispatch_citations!(archive_only, edge.citations, "#{lane} incoming edge")
    end

    {edges, actual_edges}
  end

  defp assert_generator_dispatch_edges_match!(actual_edges, edges, lane) do
    assert length(edges) == 28
    assert MapSet.size(MapSet.new(edges, &{&1.caller, &1.callee})) == 28
    assert Enum.all?(edges, &(&1.citations != []))

    expected_edges = MapSet.new(edges, &{&1.caller, {elem(&1.callee, 0), elem(&1.callee, 1)}})

    assert actual_edges == expected_edges,
           "EX-107/#{lane} generator-dispatch edge graph changed; missing=#{inspect(MapSet.difference(expected_edges, actual_edges))}; unexpected=#{inspect(MapSet.difference(actual_edges, expected_edges))}"
  end

  defp assert_generator_dispatch_tampering!(archive_only, edges, lane) do
    {tamper_citation, _expected} = hd(hd(edges).citations)
    tampered_path = hd(String.split(tamper_citation, ":"))

    expected_path = "#{lane}/#{tampered_path}"

    rows =
      Enum.map(
        archive_only.manifest["files"],
        &tamper_generator_dispatch_digest(&1, expected_path)
      )

    tampered_manifest = Map.put(archive_only.manifest, "files", rows)

    assert_raise SweepEvidence.Error, ~r/source_digest/, fn ->
      SweepEvidence.resolve!(%{archive_only | manifest: tampered_manifest}, tamper_citation)
    end
  end

  defp tamper_generator_dispatch_digest(row, expected_path) do
    if row["path"] == expected_path,
      do: Map.put(row, "sha256", String.duplicate("0", 64)),
      else: row
  end

  defp assert_generator_dispatch_guards!(graph, tier, lane) do
    guarded = GeneratorDispatchIntegrationEvidence.guarded_mfas()
    guard_patterns = GeneratorDispatchIntegrationEvidence.guard_patterns()

    assert MapSet.new(guarded) ==
             MapSet.new(
               Enum.filter(graph.full_exported, fn {module, function, _arity} ->
                 module == :asn1ct_func and function in [:call_gen, :handle_call]
               end)
             )

    assert MapSet.new(guard_patterns) ==
             MapSet.new([{:asn1ct_func, :call_gen, :_}, {:asn1ct_func, :handle_call, 3}])

    assert MapSet.new(guarded) ==
             MapSet.new([
               {:asn1ct_func, :call_gen, 3},
               {:asn1ct_func, :call_gen, 4},
               {:asn1ct_func, :handle_call, 3}
             ])

    safe_exclusion = Enum.find(@exclusions, &(&1 == {{:prefix, ":asn1ct_"}, :compiler_pass}))
    assert safe_exclusion != nil

    for mfa <- guarded do
      pattern =
        Enum.find(guard_patterns, fn {module, function, arity} ->
          module == elem(mfa, 0) and function == elem(mfa, 1) and arity in [:_, elem(mfa, 2)]
        end)

      assert pattern != nil
      assert pattern in tier
      assert pattern in BannedCalls.banned_mfas()

      without_guard = Enum.reject(tier, &(&1 == pattern))

      assert disposition(mfa, without_guard, BannedCalls.banned_names(), @exclusions) ==
               :compiler_pass,
             "EX-107's pending exclusion should be the only fallback after removing #{inspect(pattern)}"

      assert disposition(
               mfa,
               without_guard,
               BannedCalls.banned_names(),
               List.delete(@exclusions, safe_exclusion)
             ) == nil,
             "removing the active guard and EX-107 fallback must expose #{lane} #{inspect(mfa)}"
    end

    {guarded, safe_exclusion}
  end

  defp assert_generator_dispatch_lib_scope!(graph, guarded) do
    guarded_names = Enum.map(guarded, &elem(&1, 1))

    lib_front_calls =
      Enum.filter(graph.full_edges, fn
        {{module, _function, _arity}, {target, function}} ->
          String.starts_with?(Atom.to_string(module), "Elixir.Fablebook.") and
            target == :asn1ct_func and function in guarded_names

        _edge ->
          false
      end)

    assert lib_front_calls == [], "D-11 collision: lib/ calls an active ASN.1 generator front"
  end

  defp assert_generator_dispatch_fixed!(selected_mfas, tier, safe_exclusion, lane) do
    for mfa <- GeneratorDispatchIntegrationEvidence.fixed_exclusions() do
      assert mfa in selected_mfas
      assert mfa not in tier
      assert disposition(mfa, tier, BannedCalls.banned_names(), @exclusions) == :compiler_pass

      assert disposition(
               mfa,
               tier,
               BannedCalls.banned_names(),
               List.delete(@exclusions, safe_exclusion)
             ) == nil,
             "removing EX-107's retained exclusion must expose #{inspect(mfa)} in #{lane}"
    end
  end

  defp assert_generator_dispatch_omissions!(
         records,
         selected,
         edges,
         actual_edges,
         archive_only,
         lane
       ) do
    assert_raise ExUnit.AssertionError, fn ->
      assert_generator_dispatch_selection!(tl(records), selected)
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_generator_dispatch_edges_match!(actual_edges, tl(edges), lane)
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_generator_dispatch_citations!(archive_only, [], "#{lane} omitted citation")
    end
  end

  defp assert_external_transform_record!(record) do
    assert record.method == :source_only
    assert record.lane in ["core", "floor"]
    assert record.original_id == "EX-107"
    assert record.original_entry_raw == "{{:prefix, \":asn1ct_\"}, :compiler_pass}"
    assert record.owner == "01.1.1.4"
    assert record.semantic_status == :pending
    assert String.length(record.caller_input_trace) > 200
    assert MapSet.new(record.selected_mfas) == MapSet.new(@asn1_external_transform_mfas)

    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) ==
             MapSet.new(@asn1_external_transform_mfas)

    identities =
      if record.lane == "core",
        do: ExternalTransformEvidence.core_identities(),
        else: ExternalTransformEvidence.floor_identities()

    assert map_size(identities) == 5
    assert length(record.reviews) == 2

    for review <- record.reviews do
      {expected_bytes, expected_sha256} = Map.fetch!(identities, review.source_path)
      assert review.method == :source_only
      assert review.bytes == expected_bytes
      assert review.sha256 == expected_sha256
      assert review.reviewed_ranges != []

      expected_citation_count =
        if elem(review.mfa, 1) == :transform_to_EXTERNAL1994, do: 4, else: 5

      assert length(review.citations) == expected_citation_count
      assert review.disposition == :fixed_shape_data_transform
      assert review.removal_witness == :individual_exact_exclusion
      assert String.length(review.rationale) > 100
    end

    assert length(record.generated_call_evidence) == 8
    assert length(record.pre_generated_atom_evidence) == 1
    assert length(record.dynamic_dispatch_evidence) == 3
    assert length(record.runtime_template_evidence) == 6
  end

  defp assert_external_transform_omission_controls!(record, archive_only) do
    assert_raise ExUnit.AssertionError, fn ->
      assert_external_transform_record!(%{record | reviews: tl(record.reviews)})
    end

    for field <- [
          :generated_call_evidence,
          :pre_generated_atom_evidence,
          :dynamic_dispatch_evidence,
          :runtime_template_evidence
        ] do
      assert_raise ExUnit.AssertionError, fn ->
        assert_external_transform_record!(Map.put(record, field, []))
      end

      Enum.each(Map.fetch!(record, field), &assert_evidence_item_omission!(record, field, &1))
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_external_transform_record!(%{record | selected_mfas: [hd(record.selected_mfas)]})
    end

    assert_review_omission_controls!(record)

    citation = hd(hd(record.reviews).citations) |> elem(0)
    path = source_path(citation)

    manifest =
      Map.update!(archive_only.manifest, "files", fn rows ->
        Enum.reject(rows, &(&1["lane"] == record.lane and &1["source_path"] == path))
      end)

    assert_raise SweepEvidence.Error, ~r/missing_source/, fn ->
      SweepEvidence.resolve!(%{archive_only | manifest: manifest}, citation)
    end

    assert_raise SweepEvidence.Error, ~r/archive_digest/, fn ->
      SweepEvidence.load_archive!(
        Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__),
        String.duplicate("0", 64)
      )
    end
  end

  defp assert_evidence_item_omission!(record, field, item) do
    assert_raise ExUnit.AssertionError, fn ->
      assert_external_transform_record!(Map.update!(record, field, &List.delete(&1, item)))
    end
  end

  defp assert_review_omission_controls!(record) do
    for {review, index} <- Enum.with_index(record.reviews) do
      assert_raise ExUnit.AssertionError, fn ->
        assert_external_transform_record!(%{
          record
          | reviews: List.delete_at(record.reviews, index)
        })
      end

      for citation <- review.citations do
        assert_citation_omission!(record, review, index, citation)
      end
    end
  end

  defp assert_citation_omission!(record, review, index, citation) do
    assert_raise ExUnit.AssertionError, fn ->
      changed_review = %{review | citations: List.delete(review.citations, citation)}

      assert_external_transform_record!(%{
        record
        | reviews: List.replace_at(record.reviews, index, changed_review)
      })
    end
  end

  defp source_path(citation), do: citation |> String.split(":") |> hd()

  defp assert_parser_source_reviews!(record, evidence, archive_only, lane) do
    for review <- record.reviews do
      [source_row] =
        Enum.filter(evidence.manifest["files"], &(&1["path"] == "#{lane}/#{review.source_path}"))

      assert review.sha256 == source_row["sha256"]
      assert review.bytes == source_row["bytes"]

      for {citation, expected} <- review.citations do
        source = SweepEvidence.resolve!(archive_only, citation)
        assert source.origin == :archive, citation
        assert source.sha256 == review.sha256, citation
        assert source.text =~ expected, citation
      end
    end
  end

  defp assert_parser_record_edges!(record, lane) do
    expected =
      MapSet.new([
        {{:asn1ct, :scan_pass, 1}, {:asn1ct_tok, :file, 1}},
        {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_tok, :file, 1}},
        {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_parser2, :parse, 2}},
        {{:asn1ct, :parse_pass, 1}, {:asn1ct_parser2, :parse, 2}}
      ])

    actual = MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target}))

    assert actual == expected,
           "EX-107/#{lane} review record must contain the four direct caller edges"
  end

  defp assert_parser_graph_edges!(graph, lane) do
    expected =
      MapSet.new([
        {{:asn1ct, :scan_pass, 1}, {:asn1ct_tok, :file}},
        {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_tok, :file}},
        {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_parser2, :parse}},
        {{:asn1ct, :parse_pass, 1}, {:asn1ct_parser2, :parse}}
      ])

    actual =
      graph.full_edges
      |> Enum.filter(fn
        {_caller, {module, function}} ->
          {module, function} in [
            {:asn1ct_parser2, :parse},
            {:asn1ct_parser2, :format_error},
            {:asn1ct_tok, :file},
            {:asn1ct_tok, :format_error}
          ]

        _ ->
          false
      end)
      |> MapSet.new()

    assert actual == expected,
           "EX-107/#{lane} parser/tokenizer incoming edges differ; missing=#{inspect(MapSet.difference(expected, actual))}; unexpected=#{inspect(MapSet.difference(actual, expected))}"
  end

  defp assert_parser_dispositions!(record, tier, exclusions, lane) do
    Enum.each(record.reviews, &assert_parser_disposition!(&1, tier, exclusions, lane))
  end

  defp assert_parser_disposition!(review, tier, exclusions, lane) do
    mfa = review.mfa
    expected = if elem(mfa, 1) == :format_error, do: :pure_data, else: :tier
    assert review.disposition == expected
    assert disposition(mfa, tier, BannedCalls.banned_names(), exclusions) == expected

    if expected == :tier do
      assert mfa in tier
      without_mfa = Enum.reject(tier, &(&1 == mfa))

      assert disposition(mfa, without_mfa, BannedCalls.banned_names(), exclusions) == nil,
             "removing only #{inspect(mfa)} must remove its #{lane} guard disposition"

      assert review.removal_witness == :individual_mfa
    else
      assert review.removal_witness == :specific_exclusion
      exclusion = Enum.find(exclusions, &parser_exclusion_for?(&1, mfa))
      assert exclusion != nil
      without_exclusion = List.delete(exclusions, exclusion)

      assert disposition(mfa, tier, BannedCalls.banned_names(), without_exclusion) == nil,
             "removing only the #{lane} #{inspect(mfa)} exclusion must expose the selected function"
    end
  end

  defp parser_exclusion_for?(
         {{module, functions}, _reason, _citations},
         {module, function, _arity}
       ),
       do: function in functions

  defp parser_exclusion_for?(_exclusion, _mfa), do: false

  defp assert_parser_caller_citations!(record, evidence, archive_only, lane) do
    caller_row =
      Enum.find(evidence.manifest["files"], &(&1["path"] == "#{lane}/asn1/src/asn1ct.erl"))

    for {citation, expected} <- record.wrapper.citations do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.sha256 == caller_row["sha256"]
      assert source.text =~ expected
    end

    for edge <- record.caller_edges, {citation, expected} <- edge.citations do
      source = SweepEvidence.resolve!(archive_only, citation)
      assert source.origin == :archive
      assert source.sha256 == caller_row["sha256"]
      assert source.text =~ expected
    end
  end

  defp assert_parser_omission_controls!(record) do
    for index <- 0..3 do
      assert_raise ExUnit.AssertionError, fn ->
        assert_parser_tokenizer_record!(%{
          record
          | reviews: List.delete_at(record.reviews, index)
        })
      end

      assert_raise ExUnit.AssertionError, fn ->
        assert_parser_tokenizer_record!(%{
          record
          | caller_edges: List.delete_at(record.caller_edges, index)
        })
      end
    end

    [first_review | remaining_reviews] = record.reviews

    assert_raise ExUnit.AssertionError, fn ->
      assert_parser_tokenizer_record!(%{
        record
        | reviews: [%{first_review | citations: []} | remaining_reviews]
      })
    end

    assert_raise ExUnit.AssertionError, fn ->
      assert_parser_tokenizer_record!(%{
        record
        | reviews: [%{first_review | removal_witness: nil} | remaining_reviews]
      })
    end
  end

  defp assert_parser_tokenizer_record!(record) do
    assert record.method == :source_only
    assert record.lane in ["core", "floor"]
    assert MapSet.new(Enum.map(record.reviews, & &1.mfa)) == MapSet.new(@parser_tokenizer_mfas)

    assert MapSet.new(Enum.map(record.caller_edges, &{&1.caller, &1.target})) ==
             MapSet.new([
               {{:asn1ct, :scan_pass, 1}, {:asn1ct_tok, :file, 1}},
               {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_tok, :file, 1}},
               {{:asn1ct, :set_scan_parse_pass_1, 2}, {:asn1ct_parser2, :parse, 2}},
               {{:asn1ct, :parse_pass, 1}, {:asn1ct_parser2, :parse, 2}}
             ])

    for review <- record.reviews do
      assert review.method == :source_only
      assert review.citations != []
      assert review.reviewed_ranges != []
      assert review.removal_witness in [:individual_mfa, :specific_exclusion]
      expected_disposition = if elem(review.mfa, 1) == :format_error, do: :pure_data, else: :tier
      assert review.disposition == expected_disposition
    end

    for edge <- record.caller_edges, do: assert(edge.citations != [])
  end

  defp asn1_original_match?({module, _function, _arity}),
    do: String.starts_with?(inspect(module), ":asn1ct_")

  defp assert_yecc_audit!(records, graph, tier, evidence, exclusions \\ @exclusions) do
    assert length(records) == length(@yecc_expected_ids)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@yecc_expected_ids)

    record = Enum.find(records, &(&1.lane == evidence.lane.name))
    assert record != nil, "no Yecc audit row for #{evidence.lane.name}"
    assert record.original_id == "EX-089"
    assert record.original_matcher == {:yecc, :epp_guard}
    assert record.original_reason == :epp_guard
    assert MapSet.new(record.matched_mfas) == MapSet.new(@yecc_expected_original_mfas)
    assert record.trace == @yecc_expected_trace
    assert record.verdict == @yecc_expected_verdict
    assert record.replacements == @yecc_expected_replacements
    assert MapSet.new(record.tier) == MapSet.new(@yecc_expected_tier)
    assert record.fixtures == @yecc_expected_fixtures
    assert record.applicability == :each_exact_installed_lane
    assert record.removal_witness == :not_applicable_blanket_retired
    refute {:yecc, :epp_guard} in exclusions

    for {citation, expected} <- record.citations do
      assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
    end

    citation_lines = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))

    assert citation_lines ==
             MapSet.new(Map.fetch!(@yecc_expected_citation_lines, evidence.lane.name))

    live_matches =
      graph.exported
      |> Enum.filter(&yecc_original_match?(record.original_matcher, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> MapSet.new()

    assert live_matches == MapSet.new(record.matched_mfas),
           "#{record.original_id} original matcher differs from exact-lane exports"

    for {module, function, arity} = mfa <- @yecc_expected_tier do
      assert covered?(mfa, tier, BannedCalls.banned_names()),
             "#{inspect(mfa)} has no replacement tier"

      assert exclusion_reason(module, function, exclusions) == nil,
             "#{inspect(mfa)} was given a false safe disposition"

      assert arity > 0
    end

    {reached, _parents} = reach(graph, tier, BannedCalls.banned_names())
    formatter_mfa = {:yecc, :format_error, 1}
    refute covered?(formatter_mfa, tier, BannedCalls.banned_names())
    assert exclusion_reason(:yecc, :format_error, exclusions) == nil

    refute MapSet.member?(reached, formatter_mfa),
           "format_error/1 was retained although the changed atom-creator fronts do not reach it"
  end

  defp assert_logger_audit!(
         records,
         graph,
         tier,
         evidence,
         exclusions \\ @exclusions,
         family_specs \\ @logger_family_specs
       ) do
    spec_mfas = MapSet.new(Enum.map(family_specs, & &1.mfa))

    for lane <- @creator_expected_lanes do
      expected_mfas = Map.fetch!(@logger_expected_mfas_by_lane, lane)

      assert spec_mfas == expected_mfas,
             "Logger/ExUnit spec MFA set differs from pinned lane universe for #{lane}; " <>
               "missing=#{inspect(MapSet.difference(expected_mfas, spec_mfas))} " <>
               "unexpected=#{inspect(MapSet.difference(spec_mfas, expected_mfas))}"
    end

    lane_universe = Map.fetch!(@logger_expected_mfas_by_lane, evidence.lane.name)
    missing_exports = MapSet.difference(lane_universe, MapSet.new(graph.exported))

    assert MapSet.size(missing_exports) == 0,
           "pinned Logger/ExUnit MFA universe is absent from #{evidence.lane.name} exports: " <>
             inspect(missing_exports)

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(@logger_expected_ids)

    lane_records = Enum.filter(records, &(&1.lane == evidence.lane.name))
    recorded_mfas = lane_records |> Enum.flat_map(& &1.matched_mfas) |> MapSet.new()
    assert recorded_mfas == lane_universe

    for spec <- family_specs do
      {module, function, _arity} = mfa = spec.mfa

      id =
        "NEW-#{spec.family}-#{evidence.lane.name}-#{inspect(module)}-#{function}-#{elem(mfa, 2)}"

      record = Enum.find(lane_records, &(&1.original_id == id))
      assert record != nil, "missing #{id}"

      for {citation, expected} <- record.citations do
        assert SweepEvidence.resolve!(evidence, citation).text =~ expected, citation
      end

      expected_citations =
        Enum.flat_map(spec.evidence, &Map.fetch!(@logger_source_evidence[evidence.lane.name], &1))

      assert record.original_matcher == {:mfa, mfa}
      assert record.original_reason == spec.disposition
      assert record.matched_mfas == [mfa]
      assert record.trace == spec.trace
      assert record.provenance == spec.provenance
      assert record.verdict == spec.verdict
      assert record.fixtures == spec.fixtures
      assert record.citations == expected_citations
      assert record.evidence_groups == spec.evidence
      assert record.applicability == :each_exact_installed_lane
      assert record.removal_witness == spec.removal_witness

      if spec.disposition == :tier do
        assert record.tier == [mfa]
        assert record.replacements == %{mfa => {:tier, mfa}}
        assert covered?(mfa, tier, BannedCalls.banned_names()), "#{inspect(mfa)} lacks a tier"

        assert exact_mfa_exclusion_reason(mfa, exclusions) == nil,
               "#{inspect(mfa)} has a redundant safe exclusion"

        assert exclusion_reason(module, function, exclusions) == nil,
               "#{inspect(mfa)} overlaps a broad safe exclusion"
      else
        assert record.tier == []
        assert record.replacements == %{mfa => {:exact_exclusion, spec.reason}}
        refute covered?(mfa, tier, BannedCalls.banned_names())
        assert exact_mfa_exclusion_reason(mfa, exclusions) == spec.reason
        assert exclusion_reason(module, function, exclusions) == nil
      end
    end

    {reached, _parents} = reach(graph, tier, BannedCalls.banned_names())
    family_modules = MapSet.new(@logger_family_modules)

    family_exports =
      graph.exported
      |> Enum.filter(fn {module, _function, _arity} -> MapSet.member?(family_modules, module) end)
      |> MapSet.new()

    reached_family = MapSet.intersection(reached, family_exports)

    explicit_tier_roots =
      family_tier_roots(tier, family_modules, family_exports, BannedCalls.banned_names())

    explicit_exclusion_roots = explicit_family_exclusion_roots(exclusions, family_exports)

    live_family =
      reached_family
      |> MapSet.union(MapSet.new(explicit_tier_roots))
      |> MapSet.union(MapSet.new(explicit_exclusion_roots))

    recorded_family = recorded_mfas
    unrecorded_family = MapSet.difference(live_family, lane_universe)
    missing_family = MapSet.difference(lane_universe, live_family)

    assert live_family == lane_universe,
           "Logger/ExUnit family live MFA set differs from exact-lane universe; " <>
             "unrecorded=#{inspect(unrecorded_family)} " <>
             "roots=#{inspect(Enum.filter(unrecorded_family, &covered?(&1, tier, BannedCalls.banned_names())))} " <>
             "paths=#{inspect(Enum.map(unrecorded_family, &witness_line(graph, &1)))} " <>
             "missing=#{inspect(missing_family)}"

    assert live_family == recorded_family,
           "Logger/ExUnit family records differ from reached exact-lane exports; " <>
             "unrecorded=#{inspect(MapSet.difference(live_family, recorded_family))} " <>
             "stale=#{inspect(MapSet.difference(recorded_family, live_family))}"
  end

  defp yecc_original_match?({:yecc, :epp_guard}, {:yecc, function, _arity})
       when function not in [:module_info, :__info__],
       do: true

  defp yecc_original_match?(_matcher, _mfa), do: false

  defp creator_original_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp creator_original_match?(_matcher, _mfa), do: false

  defp covered?({m, f, a}, tier, names) do
    f in names or m in names or
      Enum.any?(tier, fn {pm, pf, pa} -> pm == m and pf in [:_, f] and pa in [:_, a] end)
  end

  defp banned_module_named?({_module, function, _arity}, whole_modules),
    do: function in whole_modules

  defp matched_uncovered(uncovered, entries) do
    Enum.reduce(entries, MapSet.new(), fn {matcher, _reason, _citation}, matched ->
      matched_for_entry =
        uncovered
        |> Enum.filter(&call_name_exclusion_match?(matcher, &1))
        |> MapSet.new()

      MapSet.union(matched, matched_for_entry)
    end)
  end

  defp call_name_exclusion_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp call_name_exclusion_match?(_matcher, _mfa), do: false

  defp call_name_exclusion_covered_by_exact_tier?({matcher, _reason, _citations}, named, tier) do
    matching = Enum.filter(named, &call_name_exclusion_match?(matcher, &1))

    matching != [] and Enum.all?(matching, &exact_mfa_in_tier?(&1, tier))
  end

  defp exact_mfa_in_tier?({module, function, arity}, tier) do
    Enum.any?(tier, fn {tier_module, tier_function, tier_arity} ->
      tier_module == module and tier_function == function and tier_arity == arity
    end)
  end

  defp matched_boundary(uncovered, entries) do
    Enum.reduce(entries, MapSet.new(), fn {matcher, _reason, _citation}, matched ->
      matched_for_entry =
        uncovered
        |> Enum.filter(&boundary_match?(matcher, &1))
        |> MapSet.new()

      MapSet.union(matched, matched_for_entry)
    end)
  end

  defp boundary_match?(matcher, {module, _function, _arity}) when is_atom(matcher),
    do: matcher == module

  defp boundary_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp boundary_match?(_matcher, _mfa), do: false

  defp boundary_set(graph, tier, names) do
    delegates = delegate_modules(graph)
    front = MapSet.new(front_of_barrier(graph, tier, names))

    graph.exported
    |> Enum.reject(fn {_module, function, _arity} ->
      function in [:__info__, :module_info] or
        String.starts_with?(Atom.to_string(function), "MACRO-")
    end)
    |> Enum.filter(fn {module, function, _arity} = mfa ->
      module in @barrier_modules or {module, function} in @barrier_functions or
        module in delegates or (module == :erlang and erlang_boundary_function?(function)) or
        MapSet.member?(front, mfa)
    end)
  end

  defp erlang_boundary_function?(function) do
    name = Atom.to_string(function)
    Enum.any?(["load", "module", "code", "nif", "purge", "path"], &String.contains?(name, &1))
  end

  defp delegate_modules(graph) do
    exported_modules = Enum.map(graph.exported, &elem(&1, 0)) |> MapSet.new()

    Enum.reduce(@base_sinks, MapSet.new(), fn {module, function}, delegates ->
      walk_module_calls(
        [{module, function}],
        module,
        graph.forward,
        exported_modules,
        MapSet.new(),
        delegates
      )
    end)
  end

  defp walk_module_calls([], _module, _forward, _exported_modules, _visited, delegates),
    do: delegates

  defp walk_module_calls(
         [current | rest],
         root,
         forward,
         exported_modules,
         visited,
         delegates
       ) do
    if MapSet.member?(visited, current) do
      walk_module_calls(rest, root, forward, exported_modules, visited, delegates)
    else
      {local, external} =
        Enum.split_with(Map.get(forward, current, []), fn {callee_module, _callee_function} ->
          callee_module == root
        end)

      external_modules =
        external
        |> Enum.map(&elem(&1, 0))
        |> Enum.reject(&(&1 == :erlang))
        |> Enum.filter(&MapSet.member?(exported_modules, &1))

      walk_module_calls(
        rest ++ local,
        root,
        forward,
        exported_modules,
        MapSet.put(visited, current),
        Enum.reduce(external_modules, delegates, &MapSet.put(&2, &1))
      )
    end
  end

  defp front_of_barrier(graph, tier, names) do
    barrier_targets =
      graph.exported
      |> Enum.filter(fn {module, function, _arity} = mfa ->
        barrier?({module, function}) and covered?(mfa, tier, names)
      end)
      |> Enum.map(fn {module, function, _arity} -> {module, function} end)
      |> MapSet.new()

    local_reverse =
      Enum.reduce(graph.edges, %{}, fn
        {{module, function, _arity}, {module, callee_function}}, acc ->
          Map.update(
            acc,
            {module, callee_function},
            [{module, function}],
            &[{module, function} | &1]
          )

        _edge, acc ->
          acc
      end)

    roots =
      Enum.flat_map(graph.edges, fn
        {{module, function, _arity}, callee} ->
          if MapSet.member?(barrier_targets, callee), do: [{module, function}], else: []
      end)

    in_front = local_callers(:queue.from_list(Enum.uniq(roots)), local_reverse, MapSet.new())

    Enum.filter(graph.exported, fn {module, function, _arity} ->
      MapSet.member?(in_front, {module, function})
    end)
  end

  defp local_callers(queue, reverse, visited) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        visited

      {{:value, current}, rest} ->
        if MapSet.member?(visited, current) do
          local_callers(rest, reverse, visited)
        else
          next_queue = Enum.reduce(Map.get(reverse, current, []), rest, &:queue.in/2)
          local_callers(next_queue, reverse, MapSet.put(visited, current))
        end
    end
  end

  defp boundary_undisposed(boundary, tier, names) do
    Enum.reject(boundary, fn mfa ->
      covered?(mfa, tier, names) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp lane_specific_boundary?({matcher, _reason, _citation}, boundary) do
    module = if is_atom(matcher), do: matcher, else: elem(matcher, 0)
    lane = if System.get_env("FABLEBOOK_FLOOR") in [nil, ""], do: :latest, else: :floor

    Enum.any?(@boundary_lane_specific, fn {only_module, only_lane} ->
      only_module == module and only_lane == lane and
        not Enum.any?(boundary, &(elem(&1, 0) == module))
    end)
  end

  defp lane_specific_call_name?({matcher, _reason, _citation}, named) do
    case List.keyfind(@call_name_lane_specific, matcher, 0) do
      {^matcher, :latest} ->
        System.get_env("FABLEBOOK_FLOOR") not in [nil, ""] and
          not Enum.any?(named, &call_name_exclusion_match?(matcher, &1))

      _entry ->
        false
    end
  end

  defp exact_mfa_exclusion_reason(mfa, exclusions) do
    Enum.find_value(exclusions, fn
      {{:mfa, ^mfa}, reason, _citations} -> known_reason(reason)
      _entry -> nil
    end)
  end

  defp explicit_family_exclusion_roots(exclusions, family_exports) do
    exact_roots =
      Enum.flat_map(exclusions, fn
        {{:mfa, {module, _function, _arity} = mfa}, _reason, _citations}
        when module in @logger_family_modules ->
          [mfa]

        _entry ->
          []
      end)

    module_scoped_roots =
      Enum.filter(family_exports, fn {module, function, _arity} ->
        Enum.any?(exclusions, &explicit_family_exclusion_match?(&1, module, function))
      end)

    exact_roots ++ module_scoped_roots
  end

  defp family_tier_roots(tier, family_modules, family_exports, names) do
    tier_roots = Enum.flat_map(tier, &family_tier_root(&1, family_modules, family_exports))
    named_roots = Enum.filter(family_exports, &covered?(&1, tier, names))
    tier_roots ++ named_roots
  end

  defp family_tier_root({module, _function, _arity} = root, family_modules, family_exports) do
    if MapSet.member?(family_modules, module) do
      matching_exports = Enum.filter(family_exports, &tier_root_matches?(&1, root))
      if matching_exports == [], do: [root], else: matching_exports
    else
      []
    end
  end

  defp tier_root_matches?(
         {module, function, arity},
         {root_module, root_function, root_arity}
       ),
       do:
         root_module == module and root_function in [:_, function] and
           root_arity in [:_, arity]

  defp explicit_family_exclusion_match?(
         {{matcher_module, matcher_function}, _reason, _citations},
         module,
         function
       )
       when matcher_module in @logger_family_modules and is_atom(matcher_function),
       do: matcher_module == module and matcher_function == function

  defp explicit_family_exclusion_match?(
         {{matcher_module, functions}, _reason, _citations},
         module,
         function
       )
       when matcher_module in @logger_family_modules and is_list(functions),
       do: matcher_module == module and function in functions

  defp explicit_family_exclusion_match?(
         {{:prefix, prefix}, _reason, _citations},
         module,
         _function
       ),
       do: String.starts_with?(inspect(module), prefix)

  defp explicit_family_exclusion_match?({module, _reason}, module, _function)
       when module in @logger_family_modules,
       do: true

  defp explicit_family_exclusion_match?({{:prefix, prefix}, _reason}, module, _function),
    do: String.starts_with?(inspect(module), prefix)

  defp explicit_family_exclusion_match?(_entry, _module, _function), do: false

  defp exclusion_reason(m, f, exclusions) do
    Enum.find_value(exclusions, fn
      {matcher, reason, _citation} ->
        if exclusion_match?(matcher, m, f), do: known_reason(reason)

      {{^m, functions}, reason} when is_list(functions) ->
        if f in functions, do: known_reason(reason)

      {^m, reason} ->
        known_reason(reason)

      {{:prefix, prefix}, reason} ->
        if String.starts_with?(inspect(m), prefix), do: known_reason(reason)

      {{:fun_prefix, prefix}, reason} ->
        if String.starts_with?(Atom.to_string(f), prefix), do: known_reason(reason)

      _entry ->
        nil
    end)
  end

  defp exclusion_match?({matcher_m, functions}, m, f) when is_list(functions),
    do: matcher_m == m and f in functions

  defp exclusion_match?({:prefix, prefix}, m, _f), do: String.starts_with?(inspect(m), prefix)

  defp exclusion_match?({:fun_prefix, prefix}, _m, f),
    do: String.starts_with?(Atom.to_string(f), prefix)

  defp exclusion_match?({matcher_m, matcher_f}, m, f), do: matcher_m == m and matcher_f == f

  defp exclusion_match?(_matcher, _m, _f), do: false

  defp known_reason(reason) do
    if Map.has_key?(@reasons, reason), do: reason
  end

  defp valid_exclusion?({_matcher, reason}), do: Map.has_key?(@reasons, reason)

  defp valid_exclusion?({_matcher, reason, citations}) do
    Map.has_key?(@reasons, reason) and
      Enum.all?(List.wrap(citations), &Regex.match?(@citation_re, &1))
  end

  defp function_edges(mod, {:function, _, name, arity, clauses}) do
    caller = {mod, name, arity}
    for callee <- callees(mod, clauses, []) |> Enum.uniq(), do: {caller, callee}
  end

  defp callees(mod, [{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: callees(mod, [next | rest], [{m, f} | acc])

  defp callees(mod, [head | tail], acc), do: callees(mod, tail, callees(mod, head, acc))

  defp callees(mod, {:call, _, {:atom, _, f}, args}, acc),
    do: callees(mod, args, [{mod, f} | acc])

  defp callees(mod, {:fun, _, {:function, f, a}}, acc) when is_atom(f) and is_integer(a),
    do: [{mod, f} | acc]

  defp callees(mod, tuple, acc) when is_tuple(tuple), do: callees(mod, Tuple.to_list(tuple), acc)
  defp callees(_mod, _other, acc), do: acc

  defp parse_only?({m, f, _a}) do
    f in [
      :to_atom,
      :to_existing_atom,
      :binary_to_atom,
      :list_to_atom,
      :binary_to_existing_atom,
      :list_to_existing_atom,
      :binary_to_term,
      :concat,
      :safe_concat
    ] or String.starts_with?(Atom.to_string(f), "string_to_quoted") or
      m in [
        :elixir_tokenizer,
        :elixir_parser,
        :io,
        :io_lib,
        :xmerl_scan,
        :epp_dodger,
        :epp,
        :erl_scan,
        :erl_parse,
        Code.Fragment
      ] or
      (m == :erl_eval and f not in @eval_funs) or
      {m, f} in [
        {Code, :format_string!},
        {Code, :format_file!},
        {:elixir, :string_to_tokens},
        {:elixir, :tokens_to_quoted},
        {Logger.Formatter, :compile},
        {:xref_compiler, :compile},
        {:leex, :compile},
        {:yecc, :compile},
        {EEx.Compiler, :compile}
      ]
  end

  defp reach(graph, tier, names) do
    tier_sinks =
      for {m, f, _a} = mfa <- graph.exported,
          covered?(mfa, tier, names),
          not parse_only?(mfa),
          uniq: true,
          do: {m, f}

    walk(graph.reverse, @base_sinks ++ tier_sinks)
  end

  defp counts(graph, rows, undisposed) do
    {reached_set, _parent} = reach(graph, BannedCalls.banned_mfas(), BannedCalls.banned_names())
    reached = Enum.count(reached_set, &MapSet.member?(graph.exported, &1))
    covered = Enum.count(rows, &(elem(&1, 1) == :tier))
    excluded = Enum.count(rows, &(elem(&1, 1) not in [nil, :tier]))

    "elixir #{System.version()} otp #{:erlang.system_info(:otp_release)}: " <>
      "beams_without_debug_info=#{length(graph.no_debug)} reached=#{reached} " <>
      "covered=#{covered} excluded=#{excluded} undisposed=#{length(undisposed)}"
  end

  defp witness_line(graph, {m, f, _a} = mfa) do
    {_reached, parent} = reach(graph, BannedCalls.banned_mfas(), BannedCalls.banned_names())

    chain =
      witness(parent, {m, f}, [])
      |> Enum.take(-4)
      |> Enum.map_join(" > ", fn {mod, fun} -> "#{inspect(mod)}.#{fun}" end)

    "#{inspect(mfa)} via #{chain}"
  end

  defp witness(parent, key, acc) do
    case parent[key] do
      nil -> [key | acc]
      next -> witness(parent, next, [key | acc])
    end
  end

  defp install_probe_app!(otp_lib, app, app_atom, version, module) do
    app_root = Path.join(otp_lib, "#{app}-#{version}")
    ebin = Path.join(app_root, "ebin")
    File.mkdir_p!(ebin)

    forms = [
      {:attribute, 1, :module, module},
      {:attribute, 1, :export, [probe: 0]},
      {:function, 1, :probe, 0, [{:clause, 1, [], [], [{:atom, 1, :ok}]}]}
    ]

    {:ok, ^module, beam} = :compile.forms(forms, [:debug_info])
    File.write!(Path.join(ebin, "#{Atom.to_string(module)}.beam"), beam)

    app_resource =
      {:application, app_atom, [{:vsn, String.to_charlist(version)}, {:modules, [module]}]}

    File.write!(Path.join(ebin, "#{app}.app"), :io_lib.format("~tp.~n", [app_resource]))
  end

  defp original_identity_ledger! do
    root = Path.expand("../..", __DIR__)

    snapshot_path =
      Path.join([
        root,
        ".planning",
        "milestones",
        "v0.1-phases",
        "01.1.1.5-complete-atom-creator-fronts-and-audit-calibration",
        "01.1.1.5-ORIGINAL-IDENTITY-SOURCE.txt"
      ])

    budget_path =
      Path.join([
        root,
        ".planning",
        "milestones",
        "v0.1-phases",
        "01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an",
        "01.1.1.1-AUDIT-BUDGET.json"
      ])

    snapshot = File.read!(snapshot_path)
    budget_bytes = File.read!(budget_path)

    snapshot_sha256 =
      :crypto.hash(:sha256, snapshot) |> Base.encode16(case: :lower)

    budget_sha256 =
      :crypto.hash(:sha256, budget_bytes) |> Base.encode16(case: :lower)

    assert snapshot_sha256 ==
             "913068aad01c7034ed9ab1bae9c6a4522dbcd2246264e8d62e3054b05cba5049"

    assert budget_sha256 ==
             "c25de2e909b972d308a4c28820e99ae7731b78edfdbdcb941c2eb1b77c506aa0"

    assert snapshot =~ "Stash: c1b69b5ebef830cedc38a93860c3f2c61fba0ca5"
    assert snapshot =~ "Untracked-file tree commit: af583bdc1eb10fa00acade2183d7e1840839fa17"
    assert snapshot =~ "Source path: test/support/exclusion_audit.ex"
    assert snapshot =~ "Git blob: ba394b820867576355a32f63ffc11e023c656faa"

    assert snapshot =~
             "Full source SHA-256: 35dfa00b1f64352cf5c6c134a01d42ec96a63bfd562e880df6b0320d84e1944f"

    excerpt =
      snapshot
      |> String.split("--- BEGIN VERBATIM SOURCE EXCERPT ---\n", parts: 2)
      |> then(fn
        [_header, tail] -> tail
        _ -> raise ExUnit.AssertionError, message: "original identity source excerpt is missing"
      end)
      |> String.split("\n--- END SOURCE EXCERPT ---", parts: 2)
      |> hd()

    current_source = File.read!(Path.join(root, "test/contract/tier_sweep_test.exs"))

    original_tables = %{
      "CN" => source_table_entries!(excerpt, "call_name_exclusions"),
      "EX" => source_table_entries!(excerpt, "exclusions"),
      "BD" => source_table_entries!(excerpt, "boundary_exclusions"),
      "CN-LANE" => source_table_entries!(excerpt, "call_name_lane_specific"),
      "BD-LANE" => source_table_entries!(excerpt, "boundary_lane_specific")
    }

    current_tables = %{
      "CN" => source_table_entries!(current_source, "call_name_exclusions"),
      "EX" => source_table_entries!(current_source, "exclusions"),
      "BD" => source_table_entries!(current_source, "boundary_exclusions"),
      "CN-LANE" => source_table_entries!(current_source, "call_name_lane_specific"),
      "BD-LANE" => source_table_entries!(current_source, "boundary_lane_specific")
    }

    current_values = %{
      "CN" => @call_name_exclusions,
      "EX" => Enum.take(@exclusions, length(current_tables["EX"])),
      "BD" => @boundary_exclusions,
      "CN-LANE" => @call_name_lane_specific,
      "BD-LANE" => @boundary_lane_specific
    }

    Enum.each(current_tables, fn {table, rows} ->
      assert length(current_values[table]) >= length(rows),
             "compiled #{table} table is shorter than its source identity table"
    end)

    budget = JSON.decode!(budget_bytes)
    lane_rows = Map.new(@creator_expected_lanes, &{&1, budget["lanes"][&1]["rows"]})

    expected_exclusion_ids =
      Enum.flat_map(["CN", "EX", "BD"], fn table ->
        for index <- 1..length(original_tables[table]),
            do: table <> "-" <> String.pad_leading(Integer.to_string(index), 3, "0")
      end)

    Enum.each(@creator_expected_lanes, fn lane ->
      rows = Map.fetch!(lane_rows, lane)

      assert length(rows) == length(expected_exclusion_ids)
      assert Enum.map(rows, & &1["id"]) == expected_exclusion_ids

      for table <- ["CN", "EX", "BD"] do
        table_rows = Enum.filter(rows, &(&1["table"] == table))
        assert length(table_rows) == length(original_tables[table])
      end
    end)

    lane_baselines =
      Map.new(@creator_expected_lanes, fn lane ->
        {lane, Map.new(Map.fetch!(lane_rows, lane), &{&1["id"], &1})}
      end)

    exclusions =
      Enum.flat_map(["CN", "EX", "BD"], fn table ->
        current = Map.fetch!(current_tables, table)
        current_indices = source_row_indices(current)

        original_tables[table]
        |> Enum.with_index(1)
        |> Enum.map(&original_exclusion_record!(&1, table, current_indices, lane_baselines))
      end)

    missing_live_ids =
      Enum.filter(exclusions, fn row ->
        not Enum.any?(row.current_replacement_refs, &String.starts_with?(&1, "source:"))
      end)
      |> Enum.map(& &1.id)
      |> Enum.sort()

    assert missing_live_ids == ["EX-089", "EX-159", "EX-165"]

    original_ex_rows = Map.fetch!(original_tables, "EX") |> MapSet.new()

    added_live_rows =
      current_tables["EX"]
      |> Enum.reject(&MapSet.member?(original_ex_rows, &1))
      |> Enum.map(&%{table: "EX", original_entry_raw: &1})

    assert length(added_live_rows) == 3

    metadata =
      Enum.flat_map(["CN-LANE", "BD-LANE"], fn table ->
        originals = Map.fetch!(original_tables, table)
        current = Map.fetch!(current_tables, table)
        current_indices = source_row_indices(current)

        assert originals == current,
               "original #{table} metadata identity order or payload changed"

        Enum.with_index(originals, 1)
        |> Enum.map(fn {original_entry, index} ->
          [original_matcher, lane_payload] = source_tuple_parts!(original_entry)
          id = table <> "-" <> String.pad_leading(Integer.to_string(index), 3, "0")
          [live_index] = Map.fetch!(current_indices, original_entry)
          assert Enum.at(current_values[table], live_index - 1) != nil

          %{
            id: id,
            table: table,
            identity_class: :lane_metadata,
            original_entry_raw: original_entry,
            original_matcher_raw: original_matcher,
            lane_payload_raw: lane_payload,
            current_replacement_refs: ["source:#{table}:#{live_index}"],
            semantic_status: :pending,
            owner: "01.1.1.4"
          }
        end)
      end)

    %{
      schema: "fablebook.original-identity-ledger/1",
      exclusions: exclusions,
      metadata: metadata,
      live_nonoriginal_entries: added_live_rows,
      provenance: %{
        snapshot_path:
          ".planning/phases/01.1.1.5-complete-atom-creator-fronts-and-audit-calibration/01.1.1.5-ORIGINAL-IDENTITY-SOURCE.txt",
        snapshot_sha256: snapshot_sha256,
        source_path: "test/support/exclusion_audit.ex",
        source_git_blob: "ba394b820867576355a32f63ffc11e023c656faa",
        source_sha256: "35dfa00b1f64352cf5c6c134a01d42ec96a63bfd562e880df6b0320d84e1944f",
        stash: "c1b69b5ebef830cedc38a93860c3f2c61fba0ca5",
        source_tree: "af583bdc1eb10fa00acade2183d7e1840839fa17",
        budget_path:
          ".planning/phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.json",
        budget_sha256: budget_sha256
      }
    }
  end

  defp original_exclusion_record!({original_entry, index}, table, current_indices, lane_baselines) do
    id = table <> "-" <> String.pad_leading(Integer.to_string(index), 3, "0")
    [original_matcher, original_reason | citations] = source_tuple_parts!(original_entry)
    direct_indices = Map.get(current_indices, original_entry, [])

    assert length(direct_indices) <= 1,
           "duplicate live replacement for original identity #{id}"

    creator_refs =
      @creator_audit
      |> Enum.filter(&(&1.original_id == id))
      |> Enum.map(&"creator:#{id}:#{&1.lane}")
      |> Enum.sort()

    direct_refs = original_direct_refs!(id, table, direct_indices)
    replacement_refs = direct_refs ++ creator_refs

    assert replacement_refs != [], "original identity #{id} has no live replacement reference"

    lane_matches = original_lane_matches!(lane_baselines, id)
    sampled_status = original_semantic_status(id)

    %{
      id: id,
      table: table,
      identity_class: :exclusion,
      original_entry_raw: original_entry,
      original_matcher_raw: original_matcher,
      original_reason_raw: original_reason,
      original_citations_raw: List.first(citations),
      lane_matches: lane_matches,
      current_replacement_refs: replacement_refs,
      semantic_status: sampled_status,
      owner: original_semantic_owner(sampled_status),
      remaining_semantic_owner: "01.1.1.4"
    }
  end

  defp original_direct_refs!("CN-001", _table, _direct_indices) do
    carrier = {Mix.Compilers.Protocol, :project_build}
    carrier_index = Enum.find_index(@exclusions, &(&1 == carrier))
    assert is_integer(carrier_index), "CN-001 carrier reference is missing: #{inspect(carrier)}"
    ["source:EX:#{carrier_index + 1}"]
  end

  defp original_direct_refs!("CN-004", _table, _direct_indices) do
    carrier_index = Enum.find_index(@exclusions, &cn004_expansion_carrier?/1)
    assert is_integer(carrier_index), "CN-004 exact expansion carrier is missing"
    ["source:EX:#{carrier_index + 1}"]
  end

  defp original_direct_refs!(_id, table, direct_indices),
    do: Enum.map(direct_indices, &"source:#{table}:#{&1}")

  defp cn004_expansion_carrier?(
         {{Plug.Builder, [:compile]}, :expansion, "plug/lib/plug/builder.ex:324"}
       ),
       do: true

  defp cn004_expansion_carrier?(_entry), do: false

  defp assert_original_identity_ledger!(ledger, expected) do
    assert ledger == expected

    assert MapSet.size(MapSet.new(Enum.map(ledger.exclusions, & &1.id))) ==
             length(ledger.exclusions)

    assert MapSet.size(MapSet.new(Enum.map(ledger.metadata, & &1.id))) == length(ledger.metadata)

    assert MapSet.disjoint?(
             MapSet.new(Enum.map(ledger.exclusions, & &1.id)),
             MapSet.new(Enum.map(ledger.metadata, & &1.id))
           )
  end

  defp source_table_entries!(source, attribute) do
    needle = "@" <> attribute <> " ["

    case :binary.match(source, needle) do
      {start, length} ->
        open_index = start + length - 1
        {entries, _close_index} = split_static_container!(source, open_index)
        entries

      :nomatch ->
        raise ExUnit.AssertionError, message: "missing static identity table @#{attribute}"
    end
  end

  defp source_tuple_parts!(source) do
    source = String.trim(source)
    assert String.starts_with?(source, "{") and String.ends_with?(source, "}")
    {parts, _close_index} = split_static_container!(source, 0)
    parts
  end

  defp split_static_container!(source, open_index) do
    open = :binary.at(source, open_index)
    close = static_closer!(open)

    split_static_container!(source, open_index + 1, [close], open_index + 1, [], nil, false)
  end

  defp split_static_container!(source, index, _stack, _entry_start, _entries, _quote, _escaped)
       when index >= byte_size(source),
       do: raise(ExUnit.AssertionError, message: "unterminated static identity table")

  defp split_static_container!(source, index, stack, entry_start, entries, quote, escaped) do
    byte = :binary.at(source, index)
    split_static_step!(source, index, stack, entry_start, entries, quote, escaped, byte)
  end

  defp split_static_step!(source, index, stack, entry_start, entries, quote, true, _byte)
       when not is_nil(quote) do
    advance_static_container!(source, index, stack, entry_start, entries, quote, false)
  end

  defp split_static_step!(source, index, stack, entry_start, entries, quote, false, 92)
       when not is_nil(quote) do
    advance_static_container!(source, index, stack, entry_start, entries, quote, true)
  end

  defp split_static_step!(source, index, stack, entry_start, entries, quote, false, byte)
       when not is_nil(quote) and byte == quote do
    advance_static_container!(source, index, stack, entry_start, entries, nil, false)
  end

  defp split_static_step!(source, index, stack, entry_start, entries, quote, _escaped, _byte)
       when not is_nil(quote) do
    advance_static_container!(source, index, stack, entry_start, entries, quote, false)
  end

  defp split_static_step!(source, index, stack, entry_start, entries, nil, false, byte) do
    split_static_unquoted!(source, index, stack, entry_start, entries, byte)
  end

  defp split_static_unquoted!(source, index, stack, entry_start, entries, byte) do
    case {byte, stack} do
      {open, _stack} when open in [?[, ?{, ?(] ->
        advance_static_container!(
          source,
          index,
          [static_closer!(open) | stack],
          entry_start,
          entries,
          nil,
          false
        )

      {quote, _stack} when quote in [34, 39] ->
        advance_static_container!(source, index, stack, entry_start, entries, quote, false)

      {closer, [closer]} ->
        close_static_container!(source, index, entry_start, entries)

      {closer, [closer | rest]} ->
        advance_static_container!(source, index, rest, entry_start, entries, nil, false)

      {44, [_only_closer]} ->
        entry = normalize_static_expression(binary_part(source, entry_start, index - entry_start))
        advance_static_container!(source, index, stack, index + 1, [entry | entries], nil, false)

      _other ->
        advance_static_container!(source, index, stack, entry_start, entries, nil, false)
    end
  end

  defp close_static_container!(source, index, entry_start, entries) do
    entry = normalize_static_expression(binary_part(source, entry_start, index - entry_start))
    entries = if entry == "", do: entries, else: [entry | entries]
    {Enum.reverse(entries), index}
  end

  defp advance_static_container!(source, index, stack, entry_start, entries, quote, escaped) do
    split_static_container!(source, index + 1, stack, entry_start, entries, quote, escaped)
  end

  defp static_closer!(40), do: 41
  defp static_closer!(123), do: 125
  defp static_closer!(91), do: 93

  defp normalize_static_expression(expression),
    do: expression |> String.trim() |> String.replace(~r/\s+/u, " ")

  defp source_row_indices(rows) do
    rows
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn {row, index}, acc ->
      Map.update(acc, row, [index], &[index | &1])
    end)
    |> Map.new(fn {row, indices} -> {row, Enum.reverse(indices)} end)
  end

  defp budget_mfa_string!([module, function, arity])
       when is_binary(module) and is_binary(function) and is_integer(arity) do
    module <> ":" <> function <> "/" <> Integer.to_string(arity)
  end

  defp budget_mfa_string!(other),
    do:
      raise(ExUnit.AssertionError, message: "invalid original audit-budget MFA #{inspect(other)}")

  defp original_semantic_status("CN-001"), do: :cn001_project_build_replaced
  defp original_semantic_status("CN-002"), do: :cn002_retained
  defp original_semantic_status("CN-003"), do: :cn003_retained
  defp original_semantic_status("CN-004"), do: :cn004_replaced_by_expansion_carrier
  defp original_semantic_status("CN-006"), do: :cn006_retained
  defp original_semantic_status("CN-005"), do: :calibrated_retained
  defp original_semantic_status("BD-002"), do: :calibrated_retained
  defp original_semantic_status("EX-159"), do: :calibrated_replaced_by_tier
  defp original_semantic_status("EX-165"), do: :leex_replaced_by_tier
  defp original_semantic_status(_id), do: :pending

  defp original_semantic_owner(:cn002_retained), do: "01.1.1.6"
  defp original_semantic_owner(:cn001_project_build_replaced), do: "01.1.1.13"
  defp original_semantic_owner(:cn003_retained), do: "01.1.1.6"
  defp original_semantic_owner(:cn004_replaced_by_expansion_carrier), do: "01.1.1.13"
  defp original_semantic_owner(:cn006_retained), do: "01.1.1.6"
  defp original_semantic_owner(:leex_replaced_by_tier), do: "01.1.1.14"
  defp original_semantic_owner(:pending), do: "01.1.1.4"
  defp original_semantic_owner(_sampled_status), do: "01.1.1.5"

  defp original_lane_matches!(lane_baselines, id) do
    Map.new(@creator_expected_lanes, fn lane ->
      baseline = Map.fetch!(lane_baselines[lane], id)
      matches = Enum.map(baseline["matches"], &budget_mfa_string!/1)

      assert length(matches) == MapSet.size(MapSet.new(matches)),
             "duplicate baseline matches for #{id}/#{lane}"

      {lane, matches}
    end)
  end

  defp current_call_name_entry!(matcher) do
    Enum.find(@call_name_exclusions, fn {current_matcher, _reason, _citations} ->
      current_matcher == matcher
    end) ||
      raise ExUnit.AssertionError,
        message: "missing current call-name matcher #{inspect(matcher)}"
  end

  defp current_call_name_ref!(matcher) do
    index =
      Enum.find_index(@call_name_exclusions, fn {current_matcher, _reason, _citations} ->
        current_matcher == matcher
      end)

    assert is_integer(index), "missing current call-name matcher #{inspect(matcher)}"
    "source:CN:#{index + 1}"
  end

  defp integrated_cn001_cn004_records!(graph, evidence, ledger) do
    expected_ledger = original_identity_ledger!()
    assert_original_identity_ledger!(ledger, expected_ledger)

    assert Enum.map(ledger.exclusions, & &1.id) ==
             Enum.map(expected_ledger.exclusions, & &1.id),
           "integrated acceptance changed complete original exclusion identity membership"

    assert Enum.map(ledger.metadata, & &1.id) ==
             Enum.map(expected_ledger.metadata, & &1.id),
           "integrated acceptance changed separate original metadata identity membership"

    for row <- ledger.exclusions, row.id not in ["CN-001", "CN-004"] do
      assert row.semantic_status == original_semantic_status(row.id),
             "integrated acceptance changed #{row.id} semantic status"

      assert row.owner == original_semantic_owner(row.semantic_status),
             "integrated acceptance changed #{row.id} semantic owner"
    end

    for row <- ledger.metadata do
      assert row.semantic_status == :pending,
             "integrated acceptance changed #{row.id} metadata status"

      assert row.owner == "01.1.1.4",
             "integrated acceptance changed #{row.id} metadata owner"
    end

    cn001 = cn001_record!(graph, evidence, ledger)
    cn004 = cn004_record!(graph, evidence, ledger)
    assert_cn001_record!(cn001, graph, evidence, ledger)
    assert_cn004_record!(cn004, graph, evidence, ledger)

    assert cn001.original_id == "CN-001"
    assert cn004.original_id == "CN-004"
    assert cn001.semantic_status == :cn001_project_build_replaced
    assert cn004.semantic_status == :cn004_replaced_by_expansion_carrier
    assert cn001.coverage_carrier_refs == cn001.current_replacement_refs
    assert cn004.coverage_carrier_refs == cn004.current_replacement_refs

    assert cn001.carrier_loss_witness ==
             if(evidence.lane.name == "core",
               do: ["Elixir.Mix.Compilers.Protocol:compile/4"],
               else: []
             )

    assert cn004.coverage_carriers ==
             cn004_carriers!(
               Enum.filter(graph.full_exported, fn {module, function, arity} ->
                 call_name_exclusion_match?({Plug.Builder, [:compile]}, {module, function, arity})
               end)
               |> Enum.reject(fn {_module, function, _arity} ->
                 function in [:module_info, :__info__]
               end)
             )

    %{"CN-001" => cn001, "CN-004" => cn004}
  end

  defp cn001_record!(graph, evidence, ledger) do
    row = Enum.find(ledger.exclusions, &(&1.id == "CN-001"))
    assert row != nil, "original CN-001 identity is missing"
    assert graph.lane == evidence.lane, "CN-001 graph and source evidence lanes differ"

    [original_matcher, original_reason | original_citations] =
      source_tuple_parts!(row.original_entry_raw)

    assert original_matcher == "{Mix.Compilers.Protocol, [:compile]}"
    assert original_reason == ":not_compile_module"
    assert List.first(original_citations) =~ "mix/lib/mix/compilers/protocol.ex:107"
    assert row.original_matcher_raw == original_matcher
    assert row.original_reason_raw == original_reason
    assert row.original_citations_raw == List.first(original_citations)

    carrier_index =
      Enum.find_index(@exclusions, &(&1 == {Mix.Compilers.Protocol, :project_build}))

    assert is_integer(carrier_index), "CN-001 project-build carrier is missing"
    carrier_ref = "source:EX:#{carrier_index + 1}"
    assert row.current_replacement_refs == [carrier_ref]
    assert row.semantic_status == :cn001_project_build_replaced
    assert row.owner == "01.1.1.13"

    refute Enum.any?(@call_name_exclusions, fn {matcher, _, _} ->
             call_name_exclusion_match?(matcher, {Mix.Compilers.Protocol, :compile, 4})
           end)

    lane = evidence.lane.name
    mix_root = Map.fetch!(evidence.installed, "mix")
    mix_ebin = Path.join(mix_root, "ebin")
    assert Path.expand(mix_root) == :code.lib_dir(:mix) |> to_string() |> Path.expand()
    mix_beams = File.ls!(mix_ebin) |> MapSet.new()

    inventory_module_exports =
      InstalledOtp.export_inventory!([mix_ebin], lane: lane)
      |> Enum.filter(fn {module, _function, _arity} -> module == Mix.Compilers.Protocol end)
      |> Enum.sort_by(&mfa_string!/1)

    graph_module_exports =
      graph.full_exported
      |> Enum.filter(fn {module, _function, _arity} -> module == Mix.Compilers.Protocol end)
      |> Enum.sort_by(&mfa_string!/1)

    assert graph_module_exports == inventory_module_exports,
           "CN-001/#{lane} graph exports differ from the exact installed Mix inventory"

    matched_mfas =
      graph_module_exports
      |> Enum.filter(&call_name_exclusion_match?({Mix.Compilers.Protocol, [:compile]}, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.sort_by(&mfa_string!/1)

    inventory_matches =
      inventory_module_exports
      |> Enum.filter(&call_name_exclusion_match?({Mix.Compilers.Protocol, [:compile]}, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.sort_by(&mfa_string!/1)

    matched_strings = Enum.map(matched_mfas, &mfa_string!/1)

    assert matched_strings == Map.fetch!(@cn001_expected_matches_by_lane, lane),
           "CN-001/#{lane} live full-export matches changed: #{inspect(matched_strings)}"

    assert Enum.map(inventory_matches, &mfa_string!/1) == matched_strings,
           "CN-001/#{lane} graph call-name matches differ from the installed Mix inventory"

    callers =
      graph.full_reverse
      |> Map.get({Mix.Compilers.Protocol, :compile}, [])
      |> Enum.uniq()
      |> Enum.sort_by(&mfa_string!/1)

    caller_strings = Enum.map(callers, &mfa_string!/1)

    assert caller_strings == Map.fetch!(@cn001_expected_direct_callers_by_lane, lane),
           "CN-001/#{lane} direct caller set changed: #{inspect(caller_strings)}"

    protocol_beam = "Elixir.Mix.Compilers.Protocol.beam"

    if lane == "floor" do
      refute MapSet.member?(mix_beams, protocol_beam),
             "CN-001/floor target BEAM unexpectedly exists in the exact Mix inventory"

      assert graph_module_exports == []
      assert inventory_module_exports == []
      assert matched_mfas == []
      assert callers == []
    else
      assert lane == "core"
      assert MapSet.member?(mix_beams, protocol_beam)

      assert {Mix.Compilers.Protocol, :compile, 4} in BannedCalls.banned_mfas(),
             "CN-001 core front lost its mirrored enforcement tier"
    end

    citations = cn001_citations!(lane)

    resolved =
      Enum.map(citations, fn {citation, expected_source} ->
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.text =~ expected_source, citation
        {citation, source}
      end)

    carrier_loss_witness =
      if lane == "core", do: cn001_project_build_loss_witness!(graph, carrier_ref), else: []

    %{
      original_id: row.id,
      original_entry_raw: row.original_entry_raw,
      original_matcher_raw: row.original_matcher_raw,
      original_reason_raw: row.original_reason_raw,
      original_citations_raw: row.original_citations_raw,
      current_replacement_refs: row.current_replacement_refs,
      semantic_status: row.semantic_status,
      semantic_owner: row.owner,
      lane: lane,
      elixir: evidence.lane.elixir,
      otp: evidence.lane.otp,
      module_exports: Enum.map(graph_module_exports, &mfa_string!/1),
      matched_mfas: matched_strings,
      direct_callers: caller_strings,
      citations: citations,
      source_sha256s:
        resolved
        |> Enum.map(fn {citation, source} -> {citation_source_path!(citation), source.sha256} end)
        |> Map.new(),
      mfa_citations:
        Map.new(matched_strings, fn mfa ->
          {mfa, Enum.map(citations, &elem(&1, 0))}
        end),
      caller_citations:
        if lane == "core" do
          %{
            "Elixir.Mix.Compilers.Protocol:umbrella/2" => [
              "mix/lib/mix/compilers/protocol.ex:14",
              "mix/lib/mix/compilers/protocol.ex:16",
              "mix/lib/mix/compilers/protocol.ex:46"
            ],
            "Elixir.Mix.Compilers.Elixir:maybe_consolidate/4" => [
              "mix/lib/mix/compilers/elixir.ex:1432",
              "mix/lib/mix/compilers/elixir.ex:1438",
              "mix/lib/mix/compilers/elixir.ex:1441"
            ]
          }
        else
          %{}
        end,
      source_authority_gaps: [],
      source_gap_local_hash_accepted: false,
      coverage_carrier_refs: [carrier_ref],
      carrier_loss_witness: carrier_loss_witness,
      caller_input_trace:
        "The exact full graph reports Mix.Compilers.Protocol.umbrella/2 and Mix.Compilers.Elixir.maybe_consolidate/4 as direct callers of compile/4. The umbrella route parses build arguments, resolves protocol and implementation BEAM paths, and passes force state, prior manifest state, current project module metadata, and compiler options. The Elixir compiler route derives protocol metadata from just-compiled and pending project modules, then passes its consolidation state and project compiler options.",
      delegate_trace:
        "Exact Protocol source shows extraction from BEAM attributes without loading implementation modules, consolidation reads protocol debug information and version-matched checker data, and :elixir_erl.consolidate/4 returns the generated binary. Mix writes those generated BEAMs to its build output and Code.prepend_path/1 adds that output directory. No runtime evaluation of caller source is established by this trace.",
      enforcement_dependency:
        if(lane == "core", do: {Mix.Compilers.Protocol, :compile, 4}, else: nil),
      verdict: :source_backed_project_build,
      disposition: :replaced,
      retained_exclusion: false,
      removal_witness: [],
      limitations: [
        "The floor absence claim is based on exact Mix BEAM and export inventories, not missing source text.",
        "The independently justified Mix.Compilers.Protocol project-build carrier must remain present; removing it makes compile/4 undisposed when its exact enforcement tier is also removed."
      ]
    }
  end

  defp assert_cn001_record!(record, graph, evidence, ledger) do
    expected = cn001_record!(graph, evidence, ledger)
    assert record == expected
    assert record.matched_mfas == Map.fetch!(@cn001_expected_matches_by_lane, evidence.lane.name)

    if evidence.lane.name == "floor" do
      assert record.module_exports == []
    else
      assert "Elixir.Mix.Compilers.Protocol:compile/4" in record.module_exports
    end

    assert record.current_replacement_refs == record.coverage_carrier_refs
    assert record.semantic_status == :cn001_project_build_replaced
    assert record.verdict == :source_backed_project_build
    assert record.disposition == :replaced
    assert record.removal_witness == []

    assert record.carrier_loss_witness ==
             if(evidence.lane.name == "core",
               do: ["Elixir.Mix.Compilers.Protocol:compile/4"],
               else: []
             )

    Enum.each(record.citations, fn {citation, expected_source} ->
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.text =~ expected_source, citation
      assert record.source_sha256s[citation_source_path!(citation)] == resolved.sha256
    end)

    Enum.each(record.caller_citations, fn {_caller, citations} ->
      assert citations != []

      assert Enum.all?(
               citations,
               &Enum.any?(record.citations, fn {citation, _} -> citation == &1 end)
             )
    end)

    assert record.source_gap_local_hash_accepted == false
    :ok
  end

  defp cn001_citations!("core") do
    [
      {"mix/lib/mix/compilers/protocol.ex:14", "def umbrella(args, res) do"},
      {"mix/lib/mix/compilers/protocol.ex:16", "OptionParser.parse(args"},
      {"mix/lib/mix/compilers/protocol.ex:31", "old_protocols_and_impls} = read_manifest"},
      {"mix/lib/mix/compilers/protocol.ex:46", "protocols_and_impls_from_paths(deps_paths)"},
      {"mix/lib/mix/compilers/protocol.ex:48", "case compile(on_or_force == :force"},
      {"mix/lib/mix/compilers/protocol.ex:107", "def compile(force?"},
      {"mix/lib/mix/compilers/protocol.ex:116", "Protocol.extract_protocols()"},
      {"mix/lib/mix/compilers/protocol.ex:117", "consolidate(paths, output, opts)"},
      {"mix/lib/mix/compilers/protocol.ex:120", "diff_manifest("},
      {"mix/lib/mix/compilers/protocol.ex:121",
       "consolidate(consolidation_paths(), output, opts)"},
      {"mix/lib/mix/compilers/protocol.ex:124", "Code.prepend_path(output)"},
      {"mix/lib/mix/compilers/protocol.ex:162", "defp consolidate_each(protocol"},
      {"mix/lib/mix/compilers/protocol.ex:163", "Protocol.extract_impls(protocol, paths)"},
      {"mix/lib/mix/compilers/protocol.ex:166", "Protocol.consolidate(protocol, impls)"},
      {"mix/lib/mix/compilers/protocol.ex:168", "File.write!(Path.join(output"},
      {"mix/lib/mix/compilers/elixir.ex:1157", "defp after_compile(manifest, state, opts) do"},
      {"mix/lib/mix/compilers/elixir.ex:1160",
       "maybe_consolidate(consolidation, modules, pending_modules, opts)"},
      {"mix/lib/mix/compilers/elixir.ex:1432", "defp maybe_consolidate("},
      {"mix/lib/mix/compilers/elixir.ex:1438",
       "protocols_and_impls_from_modules(modules, protocols_and_impls)"},
      {"mix/lib/mix/compilers/elixir.ex:1441", "Mix.Compilers.Protocol.compile("},
      {"elixir/lib/protocol.ex:462", "def extract_protocols(paths) do"},
      {"elixir/lib/protocol.ex:491",
       "def extract_impls(protocol, paths) when is_atom(protocol) do"},
      {"elixir/lib/protocol.ex:502",
       "defp extract_matching_by_attribute(paths, prefix, callback) do"},
      {"elixir/lib/protocol.ex:578",
       "def consolidate(protocol, types) when is_atom(protocol) do"},
      {"elixir/lib/protocol.ex:592",
       "case :beam_lib.chunks(beam_file(protocol), chunk_ids, opts) do"},
      {"elixir/lib/protocol.ex:601",
       "{@elixir_checker_version, contents} <- :erlang.binary_to_term(checker)"},
      {"elixir/lib/protocol.ex:795",
       "{:ok, :elixir_erl.consolidate(module_map, checker, specs, docs_chunk)}"},
      {"elixir/lib/code.ex:448", "def prepend_path(path, opts"},
      {"elixir/lib/code.ex:449", "apply(:code, :add_patha,"}
    ]
  end

  defp cn001_citations!("floor"), do: []

  defp cn001_project_build_loss_witness!(graph, carrier_ref, exclusions \\ @exclusions) do
    carrier = {Mix.Compilers.Protocol, :project_build}
    carrier_index = Enum.find_index(exclusions, &(&1 == carrier))
    assert is_integer(carrier_index)
    assert carrier_ref == "source:EX:#{carrier_index + 1}"

    target = {Mix.Compilers.Protocol, :compile, 4}
    assert target in graph.full_exported
    assert target in BannedCalls.banned_mfas()

    tier_without_front = List.delete(BannedCalls.banned_mfas(), target)
    exclusions_without_carrier = List.delete(exclusions, carrier)

    refute covered?(target, tier_without_front, BannedCalls.banned_names())
    assert exclusion_reason(elem(target, 0), elem(target, 1), exclusions_without_carrier) == nil

    refute Enum.any?(@call_name_exclusions, fn {matcher, _, _} ->
             call_name_exclusion_match?(matcher, target)
           end)

    refute Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), target))

    [mfa_string!(target)]
  end

  defp cn002_record!(graph, evidence, ledger) do
    row = Enum.find(ledger.exclusions, &(&1.id == "CN-002"))
    assert row != nil, "original CN-002 identity is missing"

    assert graph.lane == evidence.lane,
           "CN-002 graph and source evidence lanes differ"

    [original_matcher, original_reason, original_citations] =
      source_tuple_parts!(row.original_entry_raw)

    assert original_matcher == "{Phoenix.Digester, [:compile]}"
    assert original_reason == ":not_compile_module"
    assert original_citations =~ "phoenix/lib/phoenix/digester.ex:20"
    assert row.original_matcher_raw == original_matcher
    assert row.original_reason_raw == original_reason
    assert row.original_citations_raw == original_citations

    assert row.current_replacement_refs == [
             current_call_name_ref!({Phoenix.Digester, [:compile]})
           ]

    assert row.semantic_status == :cn002_retained
    assert row.owner == "01.1.1.6"

    {{Phoenix.Digester, [:compile]}, :not_compile_module, _current_citations} =
      current_call_name_entry!({Phoenix.Digester, [:compile]})

    lane = evidence.lane.name

    matched_mfas =
      graph.full_exported
      |> Enum.filter(&call_name_exclusion_match?({Phoenix.Digester, [:compile]}, &1))
      |> Enum.reject(fn {_module, function, _arity} ->
        function in [:module_info, :__info__]
      end)
      |> Enum.sort_by(&mfa_string!/1)

    matched_strings = Enum.map(matched_mfas, &mfa_string!/1)

    assert matched_strings == Map.fetch!(@cn002_expected_matches_by_lane, lane),
           "CN-002/#{lane} live full-export matches changed: #{inspect(matched_strings)}"

    assert length(matched_strings) == MapSet.size(MapSet.new(matched_strings)),
           "CN-002/#{lane} full export contains duplicate matches"

    callers =
      graph.full_reverse
      |> Map.get({Phoenix.Digester, :compile}, [])
      |> Enum.uniq()
      |> Enum.sort_by(&mfa_string!/1)

    assert callers == [{Mix.Tasks.Phx.Digest, :run, 1}],
           "CN-002/#{lane} direct caller set changed: #{inspect(callers)}"

    citations = cn002_citations!(lane)

    resolved =
      Enum.map(citations, fn {citation, expected_source} ->
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.text =~ expected_source, citation
        {citation, source}
      end)

    removal_witness = cn002_removal_witness!(graph, matched_mfas)
    overlap_mfas = cn002_overlaps!(matched_mfas)

    assert removal_witness != [], "CN-002/#{lane} retained row has no removal consequence"
    assert overlap_mfas == [], "CN-002/#{lane} overlaps another retained exclusion"

    %{
      original_id: row.id,
      original_entry_raw: row.original_entry_raw,
      original_matcher_raw: row.original_matcher_raw,
      original_reason_raw: row.original_reason_raw,
      original_citations_raw: row.original_citations_raw,
      current_replacement_refs: row.current_replacement_refs,
      semantic_status: row.semantic_status,
      semantic_owner: row.owner,
      lane: lane,
      elixir: evidence.lane.elixir,
      otp: evidence.lane.otp,
      matched_mfas: matched_strings,
      mfa_citations: Map.new(matched_strings, &{&1, ["phoenix/lib/phoenix/digester.ex:20"]}),
      direct_callers: Enum.map(callers, &mfa_string!/1),
      caller_input_trace:
        "Mix.Tasks.Phx.Digest.run/1 receives all_args; unless --no-compile is present it separately runs the host Mix compile task, parses positional input and output/version options, then passes those values to Phoenix.Digester.compile/3.",
      delegate_trace: [
        "Mix.Tasks.Phx.Digest.run/1 -> Phoenix.Digester.compile/3",
        "Phoenix.Digester.compile/3 -> filesystem checks, static-file traversal, digest generation, JSON manifest decoding, and manifest writes",
        "write_to_disk/2 -> configured static_compressors -> compressor.compress_file/2"
      ],
      verdict:
        "Asset digest and compression API, not a BEAM or module compiler. Retain CN-002 to account for the compile-name collision; its default Mix caller's project compile step is a separate caller action.",
      citations: citations,
      source_sha256s:
        resolved
        |> Enum.map(fn {citation, source} -> {citation_source_path!(citation), source.sha256} end)
        |> Map.new(),
      removal_witness: Enum.map(removal_witness, &mfa_string!/1),
      overlap_mfas: Enum.map(overlap_mfas, &mfa_string!/1),
      retained_exclusion: true,
      applicability: :each_exact_installed_lane,
      limitations: [
        "Caller-selected file paths and configured JSON/compressor implementations are not evaluated as safe by this row disposition.",
        "This contract does not claim runtime atom-count, never-eval, or general file-system safety."
      ]
    }
  end

  defp assert_cn002_record!(record, graph, evidence, ledger) do
    expected = cn002_record!(graph, evidence, ledger)
    assert record == expected
    assert record.matched_mfas == Map.fetch!(@cn002_expected_matches_by_lane, evidence.lane.name)
    assert record.removal_witness != []
    assert record.overlap_mfas == []

    Enum.each(record.citations, fn {citation, expected_source} ->
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.text =~ expected_source, citation
      assert record.source_sha256s[citation_source_path!(citation)] == resolved.sha256
    end)

    Enum.each(record.mfa_citations, fn {_mfa, citations} ->
      assert citations != []

      assert Enum.all?(
               citations,
               &Enum.any?(record.citations, fn {citation, _} -> citation == &1 end)
             )
    end)

    :ok
  end

  defp cn003_record!(graph, evidence, ledger) do
    row = Enum.find(ledger.exclusions, &(&1.id == "CN-003"))
    assert row != nil, "original CN-003 identity is missing"
    assert graph.lane == evidence.lane, "CN-003 graph and source evidence lanes differ"

    [original_matcher, original_reason, original_citations] =
      source_tuple_parts!(row.original_entry_raw)

    assert original_matcher == "{Phoenix.LiveView.ColocatedAssets, [:compile]}"
    assert original_reason == ":not_compile_module"
    assert original_citations =~ "phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:48"
    assert row.original_matcher_raw == original_matcher
    assert row.original_reason_raw == original_reason
    assert row.original_citations_raw == original_citations

    assert row.current_replacement_refs == [
             current_call_name_ref!({Phoenix.LiveView.ColocatedAssets, [:compile]})
           ]

    assert row.semantic_status == :cn003_retained
    assert row.owner == "01.1.1.6"

    {{Phoenix.LiveView.ColocatedAssets, [:compile]}, :not_compile_module, _current_citations} =
      current_call_name_entry!({Phoenix.LiveView.ColocatedAssets, [:compile]})

    lane = evidence.lane.name
    live_view_ebin = :code.lib_dir(:phoenix_live_view) |> to_string() |> Path.join("ebin")

    inventory_module_exports =
      InstalledOtp.export_inventory!([live_view_ebin], lane: lane)
      |> Enum.filter(fn {module, _function, _arity} ->
        module == Phoenix.LiveView.ColocatedAssets
      end)
      |> Enum.sort_by(&mfa_string!/1)

    graph_module_exports =
      graph.full_exported
      |> Enum.filter(fn {module, _function, _arity} ->
        module == Phoenix.LiveView.ColocatedAssets
      end)
      |> Enum.sort_by(&mfa_string!/1)

    assert graph_module_exports == inventory_module_exports,
           "CN-003/#{lane} graph exports differ from the exact installed LiveView inventory"

    matched_mfas =
      graph_module_exports
      |> Enum.filter(
        &call_name_exclusion_match?({Phoenix.LiveView.ColocatedAssets, [:compile]}, &1)
      )
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.sort_by(&mfa_string!/1)

    matched_strings = Enum.map(matched_mfas, &mfa_string!/1)

    assert matched_strings != [], "CN-003/#{lane} has no live full-export match"

    callers =
      graph.full_reverse
      |> Map.get({Phoenix.LiveView.ColocatedAssets, :compile}, [])
      |> Enum.uniq()
      |> Enum.sort_by(&mfa_string!/1)

    caller_strings = Enum.map(callers, &mfa_string!/1)

    assert caller_strings == Map.fetch!(@cn003_expected_direct_callers_by_lane, lane),
           "CN-003/#{lane} direct caller set changed: #{inspect(caller_strings)}"

    front = {Phoenix.LiveView.ColocatedAssets, :compile, 0}
    assert front in BannedCalls.banned_mfas(), "CN-003/#{lane} exact guard front disappeared"

    citations = cn003_citations!(lane)

    resolved =
      Enum.map(citations, fn {citation, expected_source} ->
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.text =~ expected_source, citation
        {citation, source}
      end)

    source_authority_gaps = cn003_source_authority_gaps!(evidence)
    removal_witness = cn003_removal_witness!(graph, matched_mfas)
    overlap_mfas = cn003_overlaps!(matched_mfas)

    assert removal_witness != [], "CN-003/#{lane} retained row has no tier-removal consequence"
    assert overlap_mfas == [], "CN-003/#{lane} overlaps another retained exclusion"

    %{
      original_id: row.id,
      original_entry_raw: row.original_entry_raw,
      original_matcher_raw: row.original_matcher_raw,
      original_reason_raw: row.original_reason_raw,
      original_citations_raw: row.original_citations_raw,
      current_replacement_refs: row.current_replacement_refs,
      semantic_status: row.semantic_status,
      semantic_owner: row.owner,
      lane: lane,
      elixir: evidence.lane.elixir,
      otp: evidence.lane.otp,
      module_exports: Enum.map(graph_module_exports, &mfa_string!/1),
      matched_mfas: matched_strings,
      mfa_dispositions: Map.new(matched_strings, &{&1, :cn003_retained}),
      mfa_citations:
        Map.new(
          matched_strings,
          &{&1, ["phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:48"]}
        ),
      direct_callers: caller_strings,
      caller_input_trace:
        "The exact full graph reports Mix.Tasks.Compile.PhoenixLiveView.compile/0 as the only direct caller in each lane. compile/0 has no caller-supplied arguments; the module lookup root comes from :phoenix_live_view Application configuration, Mix.Project.config()[:app], and Mix.Project.build_path(). The approved source doc says the LiveView compiler invokes compile/0, but the caller task source file is not present in the approved archive.",
      delegate_trace: [
        "Phoenix.LiveView.ColocatedAssets.extract/5 writes transformed component data under target_dir()/inspect(module).",
        "compile/0 enumerates target subdirectories, takes each Path.basename/1, and calls Module.concat/1 to derive a module name.",
        "process_module/2 requires Code.ensure_loaded?/1 and delegates metadata discovery to Phoenix.Component.MacroComponent.get_data/1.",
        "get_data/1 calls __phoenix_macro_components__/0 only when the discovered module exports it; compile/0 then uses that metadata to clean outdated files and write callback manifests."
      ],
      verdict:
        "Build-time colocated-asset manifest processing, not module compilation. Retain CN-003 to document the compile-name collision and the directory-basename module lookup; the exact guard front remains an independent enforcement dependency.",
      citations: citations,
      source_sha256s:
        resolved
        |> Enum.map(fn {citation, source} -> {citation_source_path!(citation), source.sha256} end)
        |> Map.new(),
      source_authority_gaps: source_authority_gaps,
      removal_witness: Enum.map(removal_witness, &mfa_string!/1),
      overlap_mfas: Enum.map(overlap_mfas, &mfa_string!/1),
      retained_exclusion: true,
      applicability: :each_exact_installed_lane,
      limitations: [
        "The approved source archive omits the direct Mix compiler task source, so its exact call-site body is not asserted; the full graph still proves the complete direct-caller set.",
        "Application and Mix configuration values and target-directory contents are not evaluated by this static trace.",
        "This contract does not claim runtime atom-count, path-safety, or general file-system safety."
      ]
    }
  end

  defp assert_cn003_record!(record, graph, evidence, ledger) do
    expected = cn003_record!(graph, evidence, ledger)
    citation_keys = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))
    assert record == expected
    assert record.matched_mfas != []
    assert record.removal_witness != []
    assert record.overlap_mfas == []
    assert record.retained_exclusion

    Enum.each(record.citations, fn {citation, expected_source} ->
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.text =~ expected_source, citation
      assert record.source_sha256s[citation_source_path!(citation)] == resolved.sha256
    end)

    Enum.each(record.mfa_citations, fn {_mfa, citations} ->
      assert citations != []

      Enum.each(citations, fn citation ->
        assert MapSet.member?(citation_keys, citation)
      end)
    end)

    :ok
  end

  defp cn003_citations!("core") do
    [
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:24", "The flow is:"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:29",
       "LiveView compiler invokes ColocatedAssets.compile/0."},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:35",
       "def extract(callback_module, module, filename, text, data) do"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:39",
       "|> Path.join(inspect(module))"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:48", "def compile do"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:89",
       "modules = subdirectories(target_dir)"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:93",
       "module = Module.concat([Path.basename(module_folder)])"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:100",
       "with true <- Code.ensure_loaded?(module),"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:101",
       "data when data != %{} <- Phoenix.Component.MacroComponent.get_data(module),"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:217", "Application.get_env("},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:234", "defp target_dir do"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:235",
       "app = to_string(Mix.Project.config()[:app])"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:236",
       "default = Path.join(Mix.Project.build_path(), \"phoenix-colocated\")"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:239",
       "|> Keyword.get(:target_directory, default)"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:243",
       "defp subdirectories(path) do"},
      {"phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex:244",
       "Path.wildcard(Path.join(path, \"*\")) |> Enum.filter(&File.dir?(&1))"},
      {"phoenix_live_view/lib/phoenix_component/macro_component.ex:203",
       "@spec get_data(module()) :: map()"},
      {"phoenix_live_view/lib/phoenix_component/macro_component.ex:205",
       "if Code.ensure_loaded?(component_module) and"},
      {"phoenix_live_view/lib/phoenix_component/macro_component.ex:206",
       "function_exported?(component_module, :__phoenix_macro_components__, 0) do"},
      {"phoenix_live_view/lib/phoenix_component/macro_component.ex:207",
       "component_module.__phoenix_macro_components__()"}
    ]
  end

  defp cn003_citations!("floor") do
    Enum.map(cn003_citations!("core"), fn {citation, expected} ->
      citation =
        citation
        |> String.replace("colocated_assets.ex:217", "colocated_assets.ex:190")
        |> String.replace("colocated_assets.ex:234", "colocated_assets.ex:207")
        |> String.replace("colocated_assets.ex:235", "colocated_assets.ex:208")
        |> String.replace("colocated_assets.ex:236", "colocated_assets.ex:209")
        |> String.replace("colocated_assets.ex:239", "colocated_assets.ex:212")
        |> String.replace("colocated_assets.ex:243", "colocated_assets.ex:216")
        |> String.replace("colocated_assets.ex:244", "colocated_assets.ex:217")

      {citation, expected}
    end)
  end

  defp cn003_source_authority_gaps!(evidence) do
    path = "phoenix_live_view/lib/mix/tasks/compile/phoenix_live_view.ex"

    error =
      assert_raise SweepEvidence.Error, fn ->
        SweepEvidence.resolve!(evidence, path <> ":1")
      end

    assert error.reason == :missing_source

    [
      %{
        source_path: path,
        needed_for: "direct caller Mix.Tasks.Compile.PhoenixLiveView.compile/0 call-site body",
        authority: :missing_from_approved_archive
      }
    ]
  end

  defp cn003_removal_witness!(graph, matched_mfas) do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    exact_front = {Phoenix.LiveView.ColocatedAssets, :compile, 0}
    assert exact_front in tier
    tier_without_front = List.delete(tier, exact_front)
    whole_modules = for {module, :_, :_} <- tier_without_front, do: module
    cn003_entry = current_call_name_entry!({Phoenix.LiveView.ColocatedAssets, [:compile]})
    other_rows = Enum.reject(@call_name_exclusions, &(&1 == cn003_entry))

    uncovered =
      graph.full_exported
      |> Enum.filter(&banned_module_named?(&1, whole_modules))
      |> Enum.reject(fn {module, function, arity} ->
        function in [:module_info, :__info__] or
          String.starts_with?(Atom.to_string(function), "MACRO-") or
          covered?({module, function, arity}, tier_without_front, names)
      end)

    Enum.filter(uncovered, fn mfa ->
      mfa in matched_mfas and
        call_name_exclusion_match?({Phoenix.LiveView.ColocatedAssets, [:compile]}, mfa) and
        not Enum.any?(other_rows, fn {other_matcher, _reason, _citations} ->
          call_name_exclusion_match?(other_matcher, mfa)
        end)
    end)
  end

  defp cn003_overlaps!(matched_mfas) do
    other_call_name_rows =
      Enum.reject(
        @call_name_exclusions,
        &(&1 == current_call_name_entry!({Phoenix.LiveView.ColocatedAssets, [:compile]}))
      )

    Enum.filter(matched_mfas, fn {module, function, _arity} = mfa ->
      exclusion_reason(module, function, @exclusions) != nil or
        Enum.any?(other_call_name_rows, fn {matcher, _reason, _citations} ->
          call_name_exclusion_match?(matcher, mfa)
        end) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp cn004_record!(graph, evidence, ledger) do
    row = Enum.find(ledger.exclusions, &(&1.id == "CN-004"))
    assert row != nil, "original CN-004 identity is missing"
    assert graph.lane == evidence.lane, "CN-004 graph and source evidence lanes differ"

    [original_matcher, original_reason, original_citations] =
      source_tuple_parts!(row.original_entry_raw)

    assert original_matcher == "{Plug.Builder, [:compile]}"
    assert original_reason == ":not_compile_module"
    assert original_citations =~ "plug/lib/plug/builder.ex:324"
    assert row.original_matcher_raw == original_matcher
    assert row.original_reason_raw == original_reason
    assert row.original_citations_raw == original_citations
    assert row.current_replacement_refs == [cn004_carrier_ref!()]
    assert row.semantic_status == :cn004_replaced_by_expansion_carrier
    assert row.owner == "01.1.1.13"

    refute Enum.any?(@call_name_exclusions, fn {matcher, _reason, _citations} ->
             matcher == {Plug.Builder, [:compile]}
           end)

    lane = evidence.lane.name
    plug_ebin = :code.lib_dir(:plug) |> to_string() |> Path.join("ebin")

    inventory_module_exports =
      InstalledOtp.export_inventory!([plug_ebin], lane: lane)
      |> Enum.filter(fn {module, _function, _arity} -> module == Plug.Builder end)
      |> Enum.sort_by(&mfa_string!/1)

    graph_module_exports =
      graph.full_exported
      |> Enum.filter(fn {module, _function, _arity} -> module == Plug.Builder end)
      |> Enum.sort_by(&mfa_string!/1)

    assert graph_module_exports == inventory_module_exports,
           "CN-004/#{lane} graph exports differ from the exact installed Plug inventory"

    matched_mfas =
      graph_module_exports
      |> Enum.filter(&call_name_exclusion_match?({Plug.Builder, [:compile]}, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.sort_by(&mfa_string!/1)

    matched_strings = Enum.map(matched_mfas, &mfa_string!/1)

    assert matched_strings == Map.fetch!(@cn004_expected_matches_by_lane, lane),
           "CN-004/#{lane} complete matcher/export set changed: #{inspect(matched_strings)}"

    callers =
      graph.full_reverse
      |> Map.get({Plug.Builder, :compile}, [])
      |> Enum.uniq()
      |> Enum.sort_by(&mfa_string!/1)

    caller_strings = Enum.map(callers, &mfa_string!/1)

    assert caller_strings == Map.fetch!(@cn004_expected_direct_callers_by_lane, lane),
           "CN-004/#{lane} direct caller set changed: #{inspect(caller_strings)}"

    project_callers = Enum.filter(caller_strings, &String.starts_with?(&1, "Elixir.Fablebook."))
    assert project_callers == [], "CN-004/#{lane} has a direct project lib/ caller"

    assert {String, :to_atom, 1} in BannedCalls.banned_mfas(),
           "CN-004/#{lane} lost its independent String.to_atom/1 guard dependency"

    citations = cn004_citations!(lane)

    resolved =
      Enum.map(citations, fn {citation, expected_source} ->
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.text =~ expected_source, citation
        {citation, source}
      end)

    source_authority_gaps = cn004_source_authority_gaps!(evidence)
    overlap_mfas = cn004_overlaps!(matched_mfas)
    coverage_carriers = cn004_carriers!(matched_mfas)
    quoted_source_callsites = cn004_quoted_source_callsites!(lane)
    citation_names = Enum.map(citations, &elem(&1, 0))

    %{
      original_id: row.id,
      original_entry_raw: row.original_entry_raw,
      original_matcher_raw: row.original_matcher_raw,
      original_reason_raw: row.original_reason_raw,
      original_citations_raw: row.original_citations_raw,
      current_replacement_refs: row.current_replacement_refs,
      semantic_status: row.semantic_status,
      semantic_owner: row.owner,
      lane: lane,
      elixir: evidence.lane.elixir,
      otp: evidence.lane.otp,
      module_exports: Enum.map(graph_module_exports, &mfa_string!/1),
      matched_mfas: matched_strings,
      mfa_dispositions: Map.new(matched_strings, &{&1, :replaced_by_exact_boundary_carrier}),
      mfa_citations: Map.new(matched_strings, &{&1, citation_names}),
      direct_callers: caller_strings,
      caller_citations: cn004_caller_citations!(lane),
      caller_input_trace: cn004_caller_input_trace!(lane),
      mode_branches: [
        %{
          mode: :compile,
          invalid_mode: :raises_before_pipeline_reduction,
          module_init: :executes_plug_init_with_caller_opts,
          module_name_path: [:module_split, :string_to_atom, :alias_ast, :macro_expand],
          function_plug: :escapes_caller_opts_then_quotes_call,
          citations: [
            "plug/lib/plug/builder.ex:326",
            "plug/lib/plug/builder.ex:358",
            "plug/lib/plug/builder.ex:382",
            "plug/lib/plug/builder.ex:384"
          ]
        },
        %{
          mode: :runtime,
          invalid_mode: :raises_before_pipeline_reduction,
          module_init: :quotes_plug_init_with_caller_opts,
          module_name_path: :no_compile_mode_alias_expansion,
          function_plug: :escapes_caller_opts_then_quotes_call,
          citations: [
            "plug/lib/plug/builder.ex:326",
            "plug/lib/plug/builder.ex:368",
            "plug/lib/plug/builder.ex:372"
          ]
        },
        %{
          mode: :invalid,
          behavior: :raises_argument_error_before_plug_dispatch,
          citations: [
            "plug/lib/plug/builder.ex:328",
            "plug/lib/plug/builder.ex:329",
            "plug/lib/plug/builder.ex:332"
          ]
        }
      ],
      delegate_trace: [
        %{
          path: :pipeline_accumulation,
          citations: [
            "plug/lib/plug/builder.ex:249",
            "plug/lib/plug/builder.ex:252",
            "plug/lib/plug/builder.ex:263",
            "plug/lib/plug/builder.ex:264"
          ]
        },
        %{
          path: :builder_attributes_and_options,
          citations: [
            "plug/lib/plug/builder.ex:172",
            "plug/lib/plug/builder.ex:173",
            "plug/lib/plug/builder.ex:182",
            "plug/lib/plug/builder.ex:183"
          ]
        },
        %{
          path: :init_mode_selection_and_validation,
          citations: [
            "plug/lib/plug/builder.ex:326",
            "plug/lib/plug/builder.ex:328",
            "plug/lib/plug/builder.ex:332"
          ]
        },
        %{
          path: :module_function_dispatch,
          citations: [
            "plug/lib/plug/builder.ex:346",
            "plug/lib/plug/builder.ex:349",
            "plug/lib/plug/builder.ex:353"
          ]
        },
        %{
          path: :compile_mode_module_init,
          citations: [
            "plug/lib/plug/builder.ex:357",
            "plug/lib/plug/builder.ex:358",
            "plug/lib/plug/builder.ex:360"
          ]
        },
        %{
          path: :runtime_mode_module_init,
          citations: ["plug/lib/plug/builder.ex:367", "plug/lib/plug/builder.ex:368"]
        },
        %{
          path: :function_plug_options_and_call,
          citations: [
            "plug/lib/plug/builder.ex:371",
            "plug/lib/plug/builder.ex:372",
            "plug/lib/plug/builder.ex:376",
            "plug/lib/plug/builder.ex:420",
            "plug/lib/plug/builder.ex:424"
          ]
        },
        %{
          path: :compile_mode_module_alias_and_atom_path,
          citations: [
            "plug/lib/plug/builder.ex:382",
            "plug/lib/plug/builder.ex:383",
            "plug/lib/plug/builder.ex:384"
          ]
        },
        %{
          path: :dynamic_callback_boundary,
          status: :caller_selected_callback_not_resolved_here,
          citations: [
            "plug/lib/plug/builder.ex:358",
            "plug/lib/plug/builder.ex:368",
            "plug/lib/plug/builder.ex:420",
            "plug/lib/plug/builder.ex:424"
          ]
        }
      ],
      verdict: :exact_compile_boundary_redundant,
      verdict_explanation:
        "Exact-lane sources show Plug.Builder.compile/3 immediately invokes caller-selected module plug.init/1 in compile mode, emits the init call in runtime mode, invokes caller-selected function plugs later, constructs module alias atoms with String.to_atom/1, and calls Macro.expand/2. The single current match is independently covered by the existing exact Plug.Builder.compile/3 boundary carrier. This replaces only CN-004's duplicate matcher and makes no closure or safety claim about the broader expansion owner.",
      disposition: :replaced,
      retained_exclusion: :not_retained,
      citations: citations,
      source_sha256s:
        resolved
        |> Enum.map(fn {citation, source} -> {citation_source_path!(citation), source.sha256} end)
        |> Map.new(),
      source_authority_gaps: source_authority_gaps,
      removal_witness: [],
      coverage_carriers: coverage_carriers,
      coverage_carrier_refs: [cn004_carrier_ref!()],
      quoted_source_callsites: quoted_source_callsites,
      overlap_mfas: Enum.map(overlap_mfas, &mfa_string!/1),
      project_lib_callers: project_callers,
      applicability: :each_exact_installed_lane,
      limitations: [
        "Phoenix.Router.build_pipes/2 passes caller-authored route pipeline entries; core accepts explicit plug/options pairs while floor supplies empty options for each plug atom.",
        "Phoenix.plug_init_mode/0 reads :phoenix, :plug_init_mode with :compile default; the source trace does not run that configuration lookup.",
        "Compile-mode plug.init/1 and emitted function calls are dynamic caller-selected callbacks; their callback bodies are not resolved or invoked here.",
        "The separate project-authored Macro caller-AST and broader expansion owner remains assigned to Phase 01.1.4; this row replacement makes no claim about that owner's scope.",
        "This static record makes no runtime atom-count, arbitrary callback-safety, or general safety claim."
      ]
    }
  end

  defp assert_cn004_record!(record, graph, evidence, ledger) do
    expected = cn004_record!(graph, evidence, ledger)
    citation_keys = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))
    assert record == expected
    assert record.matched_mfas == Map.fetch!(@cn004_expected_matches_by_lane, evidence.lane.name)

    assert record.direct_callers ==
             Map.fetch!(@cn004_expected_direct_callers_by_lane, evidence.lane.name)

    assert record.mode_branches |> Enum.map(& &1.mode) == [:compile, :runtime, :invalid]
    assert record.source_authority_gaps == []
    assert record.disposition == :replaced
    assert record.retained_exclusion == :not_retained
    assert record.removal_witness == []
    assert record.overlap_mfas == ["Elixir.Plug.Builder:compile/3"]
    assert record.current_replacement_refs == [cn004_carrier_ref!()]
    assert record.coverage_carrier_refs == [cn004_carrier_ref!()]

    expected_mfas =
      graph.full_exported
      |> Enum.filter(&call_name_exclusion_match?({Plug.Builder, [:compile]}, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)

    assert record.coverage_carriers == cn004_carriers!(expected_mfas)
    assert record.quoted_source_callsites == cn004_quoted_source_callsites!(evidence.lane.name)
    assert Map.keys(record.caller_citations) |> Enum.sort() == Enum.sort(record.direct_callers)
    assert Enum.all?(record.caller_citations, fn {_caller, citations} -> citations != [] end)
    assert record.verdict_explanation =~ "single current match"
    assert record.verdict_explanation =~ "broader expansion owner"
    assert Enum.any?(record.delegate_trace, &(&1.path == :dynamic_callback_boundary))
    assert record.project_lib_callers == []

    Enum.each(record.citations, fn {citation, expected_source} ->
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.text =~ expected_source, citation
      assert record.source_sha256s[citation_source_path!(citation)] == resolved.sha256
    end)

    Enum.each(record.mfa_citations, fn {_mfa, citations} ->
      assert citations != []

      Enum.each(citations, fn citation ->
        assert MapSet.member?(citation_keys, citation)
      end)
    end)

    Enum.each(record.caller_citations, fn {_caller, citations} ->
      Enum.each(citations, fn citation ->
        assert MapSet.member?(citation_keys, citation)
      end)
    end)

    Enum.each(record.mode_branches, fn branch ->
      Enum.each(branch.citations, fn citation ->
        assert MapSet.member?(citation_keys, citation)
      end)
    end)

    Enum.each(record.delegate_trace, fn trace ->
      assert trace.citations != []

      Enum.each(trace.citations, fn citation ->
        assert MapSet.member?(citation_keys, citation)
      end)
    end)

    :ok
  end

  defp cn004_citations!(lane) do
    [
      {"plug/lib/plug/builder.ex:148", "defmacro __using__(opts) do"},
      {"plug/lib/plug/builder.ex:166",
       "Module.register_attribute(__MODULE__, :plugs, accumulate: true)"},
      {"plug/lib/plug/builder.ex:167", "@before_compile Plug.Builder"},
      {"plug/lib/plug/builder.ex:172", "defmacro __before_compile__(env) do"},
      {"plug/lib/plug/builder.ex:173", "plugs = Module.get_attribute(env.module, :plugs)"},
      {"plug/lib/plug/builder.ex:176", "if builder_ref = get_plug_builder_ref(env.module) do"},
      {"plug/lib/plug/builder.ex:177", "traverse(plugs, builder_ref)"},
      {"plug/lib/plug/builder.ex:182",
       "builder_opts = Module.get_attribute(env.module, :plug_builder_opts)"},
      {"plug/lib/plug/builder.ex:183",
       "{conn, body} = Plug.Builder.compile(env, plugs, builder_opts)"},
      {"plug/lib/plug/builder.ex:249", "defmacro plug(plug, opts"},
      {"plug/lib/plug/builder.ex:252", "plug = expand_alias(plug, __CALLER__)"},
      {"plug/lib/plug/builder.ex:263", "quote do"},
      {"plug/lib/plug/builder.ex:264", "@plugs {unquote(plug), unquote(opts), true}"},
      {"plug/lib/plug/builder.ex:268", "defp expand_alias({:__aliases__, _, _} = alias, env),"},
      {"plug/lib/plug/builder.ex:269", "do: Macro.expand(alias, %{env | function: {:init, 1}})"},
      {"plug/lib/plug/builder.ex:324", "def compile(env, pipeline, builder_opts) do"},
      {"plug/lib/plug/builder.ex:326", "init_mode = builder_opts[:init_mode] || :compile"},
      {"plug/lib/plug/builder.ex:328", "unless init_mode in [:compile, :runtime] do"},
      {"plug/lib/plug/builder.ex:329", "raise ArgumentError, \"\"\""},
      {"plug/lib/plug/builder.ex:332", "Supported values include :compile or :runtime."},
      {"plug/lib/plug/builder.ex:337",
       "Enum.reduce(pipeline, conn, fn {plug, opts, guards}, acc ->"},
      {"plug/lib/plug/builder.ex:339", "|> init_plug(init_mode)"},
      {"plug/lib/plug/builder.ex:340", "|> quote_plug(init_mode, acc, env, builder_opts)"},
      {"plug/lib/plug/builder.ex:346",
       "defp module_plug?(plug), do: match?(~c\"Elixir.\" ++ _, Atom.to_charlist(plug))"},
      {"plug/lib/plug/builder.ex:349", "defp init_plug({plug, opts, guards}, init_mode) do"},
      {"plug/lib/plug/builder.ex:353", "init_fun_plug(plug, opts, guards)"},
      {"plug/lib/plug/builder.ex:357", "defp init_module_plug(plug, opts, guards, :compile) do"},
      {"plug/lib/plug/builder.ex:358", "initialized_opts = plug.init(opts)"},
      {"plug/lib/plug/builder.ex:360", "if function_exported?(plug, :call, 2) do"},
      {"plug/lib/plug/builder.ex:367", "defp init_module_plug(plug, opts, guards, :runtime) do"},
      {"plug/lib/plug/builder.ex:368",
       "{:module, plug, quote(do: unquote(plug).init(unquote(escape(opts)))), guards}"},
      {"plug/lib/plug/builder.ex:371", "defp init_fun_plug(plug, opts, guards) do"},
      {"plug/lib/plug/builder.ex:372", "{:function, plug, escape(opts), guards}"},
      {"plug/lib/plug/builder.ex:376", "Macro.escape(opts, unquote: true)"},
      {"plug/lib/plug/builder.ex:382",
       "parts = [:\"Elixir\" | Enum.map(Module.split(plug), &String.to_atom/1)]"},
      {"plug/lib/plug/builder.ex:383", "alias = {:__aliases__, [line: env.line], parts}"},
      {"plug/lib/plug/builder.ex:384", "_ = Macro.expand(alias, env)"},
      {"plug/lib/plug/builder.ex:420", "quote do: unquote(plug)(conn, unquote(opts))"},
      {"plug/lib/plug/builder.ex:424", "quote do: unquote(plug).call(conn, unquote(opts))"},
      {"phoenix/lib/phoenix/controller/pipeline.ex:75", "defmacro __before_compile__(env) do"},
      {"phoenix/lib/phoenix/controller/pipeline.ex:77",
       "plugs = [action | Module.get_attribute(env.module, :plugs)]"},
      {"phoenix/lib/phoenix/controller/pipeline.ex:80", "Plug.Builder.compile(env, plugs,"},
      {"phoenix/lib/phoenix/controller/pipeline.ex:82", "init_mode: Phoenix.plug_init_mode()"},
      {"phoenix/lib/phoenix.ex:72", "def plug_init_mode do"},
      {"phoenix/lib/phoenix.ex:73", "Application.get_env(:phoenix, :plug_init_mode, :compile)"}
    ] ++ cn004_router_citations!(lane)
  end

  defp cn004_caller_citations!(lane) do
    router_citations =
      if lane == "core" do
        [
          "phoenix/lib/phoenix/router.ex:818",
          "phoenix/lib/phoenix/router.ex:823",
          "phoenix/lib/phoenix/router.ex:824",
          "phoenix/lib/phoenix/router.ex:827",
          "phoenix/lib/phoenix/router.ex:828"
        ]
      else
        [
          "phoenix/lib/phoenix/router.ex:818",
          "phoenix/lib/phoenix/router.ex:819",
          "phoenix/lib/phoenix/router.ex:820",
          "phoenix/lib/phoenix/router.ex:821"
        ]
      end

    %{
      "Elixir.Plug.Builder:MACRO-__before_compile__/2" => [
        "plug/lib/plug/builder.ex:172",
        "plug/lib/plug/builder.ex:173",
        "plug/lib/plug/builder.ex:182",
        "plug/lib/plug/builder.ex:183",
        "plug/lib/plug/builder.ex:249",
        "plug/lib/plug/builder.ex:252",
        "plug/lib/plug/builder.ex:264"
      ],
      "Elixir.Phoenix.Controller.Pipeline:MACRO-__before_compile__/2" => [
        "phoenix/lib/phoenix/controller/pipeline.ex:75",
        "phoenix/lib/phoenix/controller/pipeline.ex:77",
        "phoenix/lib/phoenix/controller/pipeline.ex:80",
        "phoenix/lib/phoenix/controller/pipeline.ex:82"
      ],
      "Elixir.Phoenix.Router:build_pipes/2" => router_citations
    }
  end

  defp cn004_router_citations!("core") do
    [
      {"phoenix/lib/phoenix/router.ex:818", "defp build_pipes(name, pipe_through) do"},
      {"phoenix/lib/phoenix/router.ex:823", "{plug, opts} -> {plug, opts, true}"},
      {"phoenix/lib/phoenix/router.ex:824", "plug -> {plug, [], true}"},
      {"phoenix/lib/phoenix/router.ex:827",
       "opts = [init_mode: Phoenix.plug_init_mode(), log_on_halt: :debug]"},
      {"phoenix/lib/phoenix/router.ex:828",
       "{conn, body} = Plug.Builder.compile(__ENV__, plugs, opts)"},
      {"phoenix/lib/phoenix/router.ex:945", "defmacro pipeline(plug, do: block) do"},
      {"phoenix/lib/phoenix/router.ex:966",
       "Plug.Builder.compile(__ENV__, @phoenix_pipeline, init_mode: Phoenix.plug_init_mode())"}
    ]
  end

  defp cn004_router_citations!("floor") do
    [
      {"phoenix/lib/phoenix/router.ex:818", "defp build_pipes(name, pipe_through) do"},
      {"phoenix/lib/phoenix/router.ex:819",
       "plugs = pipe_through |> Enum.reverse() |> Enum.map(&{&1, [], true})"},
      {"phoenix/lib/phoenix/router.ex:820",
       "opts = [init_mode: Phoenix.plug_init_mode(), log_on_halt: :debug]"},
      {"phoenix/lib/phoenix/router.ex:821",
       "{conn, body} = Plug.Builder.compile(__ENV__, plugs, opts)"},
      {"phoenix/lib/phoenix/router.ex:938", "defmacro pipeline(plug, do: block) do"},
      {"phoenix/lib/phoenix/router.ex:959",
       "Plug.Builder.compile(__ENV__, @phoenix_pipeline, init_mode: Phoenix.plug_init_mode())"}
    ]
  end

  defp cn004_source_sha_by_lane!("core") do
    %{
      "phoenix/lib/phoenix/router.ex" =>
        "046564dae97dbd0ba58eb78e630fb226a2c8360a86b933dd9604e998c68b17bd",
      "phoenix/lib/phoenix.ex" =>
        "f831736998100ebf303c30d67802035f87830620b203d78f3d1d41df94a6df62"
    }
  end

  defp cn004_source_sha_by_lane!("floor") do
    %{
      "phoenix/lib/phoenix/router.ex" =>
        "78469c9caa87b05e16ddca8159822263165addc08b07ae8a5e06f76daeab5937",
      "phoenix/lib/phoenix.ex" =>
        "f831736998100ebf303c30d67802035f87830620b203d78f3d1d41df94a6df62"
    }
  end

  defp cn004_quoted_source_callsites!("core") do
    [
      %{
        caller: "Elixir.Phoenix.Router:pipeline/2",
        citation: "phoenix/lib/phoenix/router.ex:966",
        target: "Elixir.Plug.Builder:compile/3"
      }
    ]
  end

  defp cn004_quoted_source_callsites!("floor") do
    [
      %{
        caller: "Elixir.Phoenix.Router:pipeline/2",
        citation: "phoenix/lib/phoenix/router.ex:959",
        target: "Elixir.Plug.Builder:compile/3"
      }
    ]
  end

  defp cn004_caller_input_trace!("core") do
    "The three direct graph callers are Plug.Builder.__before_compile__/1, Phoenix.Controller.Pipeline.__before_compile__/1, and Phoenix.Router.build_pipes/2. Builder attributes carry each plug/options/guard tuple plus builder_opts; the controller prepends its action plug and uses Phoenix.plug_init_mode/0. Router route pipe_through entries accept {plug, opts} pairs or bare plug atoms, mapping bare atoms to empty options, then pass __ENV__, init_mode from Phoenix.plug_init_mode/0, and log_on_halt: :debug. Phoenix.Router.pipeline/2 also quotes a separate Plug.Builder.compile/3 call, which source inspection records despite its absence as a direct compiled graph edge. Phoenix.plug_init_mode/0 reads :phoenix/:plug_init_mode with :compile default."
  end

  defp cn004_caller_input_trace!("floor") do
    "The three direct graph callers are Plug.Builder.__before_compile__/1, Phoenix.Controller.Pipeline.__before_compile__/1, and Phoenix.Router.build_pipes/2. Builder attributes carry each plug/options/guard tuple plus builder_opts; the controller prepends its action plug and uses Phoenix.plug_init_mode/0. Router route pipe_through entries are reversed and every plug atom is paired with empty options, then __ENV__, init_mode from Phoenix.plug_init_mode/0, and log_on_halt: :debug are passed to Plug.Builder.compile/3. Phoenix.Router.pipeline/2 also quotes a separate Plug.Builder.compile/3 call, which source inspection records despite its absence as a direct compiled graph edge. Phoenix.plug_init_mode/0 reads :phoenix/:plug_init_mode with :compile default."
  end

  defp cn004_carrier_ref! do
    carrier_index =
      Enum.find_index(@exclusions, fn
        {{Plug.Builder, [:compile]}, :expansion, "plug/lib/plug/builder.ex:324"} -> true
        _entry -> false
      end)

    assert is_integer(carrier_index), "CN-004 exact expansion carrier is missing"
    "source:EX:#{carrier_index + 1}"
  end

  defp cn004_carriers!(matched_mfas, exclusions \\ @exclusions) do
    Enum.map(matched_mfas, fn mfa ->
      assert mfa == {Plug.Builder, :compile, 3},
             "CN-004 has no independently reviewed carrier for #{mfa_string!(mfa)}"

      carriers =
        Enum.filter(exclusions, fn
          {matcher, _reason, _citation} -> call_name_exclusion_match?(matcher, mfa)
          _other -> false
        end)

      assert length(carriers) == 1,
             "CN-004 needs one exact active carrier for #{mfa_string!(mfa)}"

      [{matcher, :expansion, citation}] = carriers

      assert citation == "plug/lib/plug/builder.ex:324",
             "CN-004 carrier must cite the exact Plug.Builder compile source"

      %{
        mfa: mfa_string!(mfa),
        ref: cn004_carrier_ref!(),
        matcher: inspect(matcher),
        citation: citation,
        source_proof: [
          "plug/lib/plug/builder.ex:358",
          "plug/lib/plug/builder.ex:382",
          "plug/lib/plug/builder.ex:384"
        ],
        scope: :this_exact_mfa_only
      }
    end)
  end

  defp cn004_source_authority_gaps!(evidence) do
    Enum.each(["phoenix/lib/phoenix/router.ex", "phoenix/lib/phoenix.ex"], fn path ->
      assert SweepEvidence.resolve!(evidence, path <> ":1").line == 1
    end)

    []
  end

  defp cn004_overlaps!(matched_mfas) do
    Enum.filter(matched_mfas, fn {module, function, _arity} = mfa ->
      exclusion_reason(module, function, @exclusions) != nil or
        Enum.any?(@call_name_exclusions, fn {matcher, _reason, _citations} ->
          call_name_exclusion_match?(matcher, mfa)
        end) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp cn006_record!(graph, evidence, ledger) do
    row = Enum.find(ledger.exclusions, &(&1.id == "CN-006"))
    assert row != nil, "original CN-006 identity is missing"
    assert graph.lane == evidence.lane, "CN-006 graph and source evidence lanes differ"

    [original_matcher, original_reason, original_citations] =
      source_tuple_parts!(row.original_entry_raw)

    assert original_matcher == "{:re, [:compile]}"
    assert original_reason == ":not_compile_module"

    assert original_citations =~ "stdlib/src/re.erl:128" or
             original_citations =~ "stdlib/src/re.erl:86"

    assert row.original_matcher_raw == original_matcher
    assert row.original_reason_raw == original_reason
    assert row.original_citations_raw == original_citations
    assert row.current_replacement_refs == [current_call_name_ref!({:re, [:compile]})]
    assert row.semantic_status == :cn006_retained
    assert row.owner == "01.1.1.6"

    {{:re, [:compile]}, :not_compile_module, _current_citations} =
      Enum.find(@call_name_exclusions, fn {matcher, _reason, _citations} ->
        matcher == {:re, [:compile]}
      end)

    lane = evidence.lane.name
    stdlib_ebin = :code.lib_dir(:stdlib) |> to_string() |> Path.join("ebin")

    inventory_module_exports =
      InstalledOtp.export_inventory!([stdlib_ebin], lane: lane)
      |> Enum.filter(fn {module, _function, _arity} -> module == :re end)
      |> Enum.sort_by(&mfa_string!/1)

    graph_module_exports =
      graph.full_exported
      |> Enum.filter(fn {module, _function, _arity} -> module == :re end)
      |> Enum.sort_by(&mfa_string!/1)

    assert graph_module_exports == inventory_module_exports,
           "CN-006/#{lane} graph exports differ from the exact installed stdlib inventory"

    matched_mfas =
      graph_module_exports
      |> Enum.filter(&call_name_exclusion_match?({:re, [:compile]}, &1))
      |> Enum.reject(fn {_module, function, _arity} -> function in [:module_info, :__info__] end)
      |> Enum.sort_by(&mfa_string!/1)

    matched_strings = Enum.map(matched_mfas, &mfa_string!/1)

    assert matched_strings == Map.fetch!(@cn006_expected_matches_by_lane, lane),
           "CN-006/#{lane} complete match set changed: #{inspect(matched_strings)}"

    callers =
      graph.full_reverse
      |> Map.get({:re, :compile}, [])
      |> Enum.uniq()
      |> Enum.sort_by(&mfa_string!/1)

    caller_strings = Enum.map(callers, &mfa_string!/1)
    assert caller_strings != [], "CN-006/#{lane} has no exact full-graph caller evidence"

    project_callers = Enum.filter(caller_strings, &String.starts_with?(&1, "Elixir.Fablebook."))
    assert project_callers == [], "CN-006/#{lane} has a direct project lib/ caller"

    citations = cn006_citations!(lane)

    resolved =
      Enum.map(citations, fn {citation, expected_source} ->
        source = SweepEvidence.resolve!(evidence, citation)
        assert source.text =~ expected_source, citation
        {citation, source}
      end)

    removal_witness = cn006_removal_witness!(matched_mfas)
    overlap_mfas = cn006_overlaps!(matched_mfas)

    assert removal_witness == matched_mfas,
           "CN-006/#{lane} retained arities lack individual row-removal witnesses"

    assert overlap_mfas == [], "CN-006/#{lane} overlaps another exclusion"

    arity_traces = %{
      "re:compile/1" => %{
        source_contract: :caller_supplied_iodata_pattern,
        options: :defaults_to_compile_2_with_empty_options,
        delegate: :native_regex_compiler_nif
      },
      "re:compile/2" => %{
        source_contract: :caller_supplied_iodata_or_unicode_charlist_pattern,
        options:
          if(lane == "core", do: :compile_options_including_export, else: :otp_27_compile_options),
        delegate: :native_regex_compiler_nif
      }
    }

    %{
      original_id: row.id,
      original_entry_raw: row.original_entry_raw,
      original_matcher_raw: row.original_matcher_raw,
      original_reason_raw: row.original_reason_raw,
      original_citations_raw: row.original_citations_raw,
      current_replacement_refs: row.current_replacement_refs,
      semantic_status: row.semantic_status,
      semantic_owner: row.owner,
      lane: lane,
      elixir: evidence.lane.elixir,
      otp: evidence.lane.otp,
      module_exports: Enum.map(graph_module_exports, &mfa_string!/1),
      matched_mfas: matched_strings,
      mfa_dispositions: Map.new(matched_strings, &{&1, :retained_regex_data_native_boundary}),
      mfa_citations: %{
        "re:compile/1" => [
          lane_citation!(lane, "stdlib/src/re.erl:123", "The same as"),
          lane_citation!(lane, "stdlib/src/re.erl:124", "-spec compile(Regexp)"),
          lane_citation!(lane, "stdlib/src/re.erl:128", "compile(_) ->"),
          lane_citation!(lane, "stdlib/src/re.erl:129", "erlang:nif_error(undef).")
        ],
        "re:compile/2" => [
          lane_citation!(lane, "stdlib/src/re.erl:132", "Compiles a regular expression"),
          lane_citation!(lane, "stdlib/src/re.erl:133", "format to be used later as a parameter"),
          lane_citation!(lane, "stdlib/src/re.erl:282", "-spec compile(Regexp, Options)"),
          lane_citation!(lane, "stdlib/src/re.erl:284", "Options :: [Option]"),
          lane_citation!(lane, "stdlib/src/re.erl:288", "compile(_, _) ->"),
          lane_citation!(lane, "stdlib/src/re.erl:289", "erlang:nif_error(undef).")
        ]
      },
      direct_callers: caller_strings,
      direct_caller_count: length(caller_strings),
      direct_callers_scope: :combined_compile_arities_in_full_reverse_graph,
      caller_input_trace:
        "The full graph records all direct callers of re:compile/1 and /2 together because its reverse map is keyed by module and function, not target arity. The exact lane source specs define the API inputs as caller-supplied Regexp data (iodata for /1; iodata or Unicode charlist for /2) and, for /2, a caller-supplied option list. The OTP API contract compiles that regex data to the internal format used by run/2 and run/3; these arguments are not module names or BEAM module source.",
      arity_traces: arity_traces,
      delegate_trace: [
        "compile/1 is documented as compile/2 with an empty option list.",
        "compile/1 and compile/2 are Erlang NIF stubs that call erlang:nif_error(undef) if their native implementation is unavailable.",
        "The documented output is an internal regular-expression representation for later run/2 or run/3 matching; compile/2 supports the export option only on the core OTP lane (OTP 28.1 and later).",
        "The visible Erlang source does not compile, load, or evaluate BEAM modules. The NIF implementation is outside this static source trace."
      ],
      verdict: :retained_regex_data_native_boundary,
      verdict_explanation:
        "Both original matches compile caller-supplied regular-expression data to an internal pattern through the OTP native regex boundary. The public contract and NIF stubs do not implement Elixir/Erlang module compilation or code loading. Retain the original row for that narrow reason; the hidden native implementation is not inspected, invoked, or used for a runtime atom-count or general safety conclusion.",
      disposition: :retained_non_module_compile,
      retained_exclusion: true,
      citations: citations,
      source_sha256s:
        resolved
        |> Enum.map(fn {citation, source} -> {citation_source_path!(citation), source.sha256} end)
        |> Map.new(),
      removal_witness: Enum.map(removal_witness, &mfa_string!/1),
      overlap_mfas: Enum.map(overlap_mfas, &mfa_string!/1),
      project_lib_callers: project_callers,
      applicability: :each_exact_installed_lane,
      limitations: [
        "The reverse graph combines direct caller functions across both compile arities because target arity is not retained in its reverse-map key.",
        "The native NIF implementation is not present in the Erlang source body and is not invoked or characterized here.",
        "This static record makes no runtime atom-count, regex denial-of-service, or general safety claim."
      ]
    }
  end

  defp assert_cn006_record!(record, graph, evidence, ledger) do
    expected = cn006_record!(graph, evidence, ledger)
    citation_keys = MapSet.new(Enum.map(record.citations, &elem(&1, 0)))
    assert record == expected
    assert record.matched_mfas == Map.fetch!(@cn006_expected_matches_by_lane, evidence.lane.name)
    assert record.removal_witness == record.matched_mfas
    assert record.disposition == :retained_non_module_compile
    assert record.retained_exclusion
    assert record.overlap_mfas == []
    assert record.project_lib_callers == []
    assert record.direct_caller_count == length(record.direct_callers)
    assert record.direct_callers_scope == :combined_compile_arities_in_full_reverse_graph
    assert Map.keys(record.arity_traces) |> Enum.sort() == ["re:compile/1", "re:compile/2"]

    Enum.each(record.citations, fn {citation, expected_source} ->
      resolved = SweepEvidence.resolve!(evidence, citation)
      assert resolved.text =~ expected_source, citation
      assert record.source_sha256s[citation_source_path!(citation)] == resolved.sha256
    end)

    Enum.each(record.mfa_citations, fn {mfa, citations} ->
      assert citations != []

      Enum.each(citations, fn {citation, _expected_source} ->
        assert MapSet.member?(citation_keys, citation)
      end)

      assert Map.has_key?(record.mfa_dispositions, mfa)
    end)

    :ok
  end

  defp cn006_citations!("core") do
    [
      {"stdlib/src/re.erl:123", "The same as"},
      {"stdlib/src/re.erl:124", "-spec compile(Regexp)"},
      {"stdlib/src/re.erl:128", "compile(_) ->"},
      {"stdlib/src/re.erl:129", "erlang:nif_error(undef)."},
      {"stdlib/src/re.erl:132", "Compiles a regular expression"},
      {"stdlib/src/re.erl:133", "format to be used later as a parameter"},
      {"stdlib/src/re.erl:282", "-spec compile(Regexp, Options)"},
      {"stdlib/src/re.erl:284", "Options :: [Option]"},
      {"stdlib/src/re.erl:285", "Option :: compile_option() | export"},
      {"stdlib/src/re.erl:280", "supported since OTP 28.1"},
      {"stdlib/src/re.erl:288", "compile(_, _) ->"},
      {"stdlib/src/re.erl:289", "erlang:nif_error(undef)."}
    ]
  end

  defp cn006_citations!("floor") do
    [
      {"stdlib/src/re.erl:80", "The same as"},
      {"stdlib/src/re.erl:81", "-spec compile(Regexp)"},
      {"stdlib/src/re.erl:86", "compile(_) ->"},
      {"stdlib/src/re.erl:87", "erlang:nif_error(undef)."},
      {"stdlib/src/re.erl:90", "Compiles a regular expression"},
      {"stdlib/src/re.erl:91", "format to be used later as a parameter"},
      {"stdlib/src/re.erl:229", "-spec compile(Regexp, Options)"},
      {"stdlib/src/re.erl:231", "Options :: [Option]"},
      {"stdlib/src/re.erl:232", "Option :: compile_option()"},
      {"stdlib/src/re.erl:236", "compile(_, _) ->"},
      {"stdlib/src/re.erl:237", "erlang:nif_error(undef)."}
    ]
  end

  defp cn006_removal_witness!(matched_mfas) do
    matcher = {:re, [:compile]}

    row =
      Enum.find(@call_name_exclusions, fn {entry_matcher, _reason, _citations} ->
        entry_matcher == matcher
      end)

    assert row != nil, "CN-006 row is absent from the active call-name exclusions"
    other_rows = Enum.reject(@call_name_exclusions, &(&1 == row))
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()

    Enum.filter(matched_mfas, fn {module, function, _arity} = mfa ->
      not covered?(mfa, tier, names) and
        exact_mfa_exclusion_reason(mfa, @exclusions) == nil and
        exclusion_reason(module, function, @exclusions) == nil and
        not Enum.any?(other_rows, fn {other_matcher, _reason, _citations} ->
          call_name_exclusion_match?(other_matcher, mfa)
        end) and
        not Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp cn006_overlaps!(matched_mfas) do
    other_call_name_rows =
      Enum.reject(@call_name_exclusions, fn {matcher, _reason, _citations} ->
        matcher == {:re, [:compile]}
      end)

    Enum.filter(matched_mfas, fn {module, function, _arity} = mfa ->
      exact_mfa_exclusion_reason(mfa, @exclusions) != nil or
        exclusion_reason(module, function, @exclusions) != nil or
        Enum.any?(other_call_name_rows, fn {matcher, _reason, _citations} ->
          call_name_exclusion_match?(matcher, mfa)
        end) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp lane_citation!("core", citation, expected), do: {citation, expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:123", expected),
    do: {"stdlib/src/re.erl:80", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:124", expected),
    do: {"stdlib/src/re.erl:81", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:128", expected),
    do: {"stdlib/src/re.erl:86", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:129", expected),
    do: {"stdlib/src/re.erl:87", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:132", expected),
    do: {"stdlib/src/re.erl:90", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:133", expected),
    do: {"stdlib/src/re.erl:91", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:282", expected),
    do: {"stdlib/src/re.erl:229", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:284", expected),
    do: {"stdlib/src/re.erl:231", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:285", _expected),
    do: {"stdlib/src/re.erl:232", "Option :: compile_option()"}

  defp lane_citation!("floor", "stdlib/src/re.erl:280", _expected),
    do: {"stdlib/src/re.erl:232", "Option :: compile_option()"}

  defp lane_citation!("floor", "stdlib/src/re.erl:288", expected),
    do: {"stdlib/src/re.erl:236", expected}

  defp lane_citation!("floor", "stdlib/src/re.erl:289", expected),
    do: {"stdlib/src/re.erl:237", expected}

  defp cn002_removal_witness!(graph, matched_mfas) do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    whole_modules = for {module, :_, :_} <- tier, do: module
    cn002_entry = current_call_name_entry!({Phoenix.Digester, [:compile]})
    other_rows = Enum.reject(@call_name_exclusions, &(&1 == cn002_entry))

    uncovered =
      graph.full_exported
      |> Enum.filter(&banned_module_named?(&1, whole_modules))
      |> Enum.reject(fn {module, function, arity} ->
        function in [:module_info, :__info__] or
          String.starts_with?(Atom.to_string(function), "MACRO-") or
          covered?({module, function, arity}, tier, names)
      end)

    Enum.filter(uncovered, fn mfa ->
      mfa in matched_mfas and
        call_name_exclusion_match?({Phoenix.Digester, [:compile]}, mfa) and
        not Enum.any?(other_rows, fn {other_matcher, _reason, _citations} ->
          call_name_exclusion_match?(other_matcher, mfa)
        end)
    end)
  end

  defp cn002_overlaps!(matched_mfas) do
    other_call_name_rows =
      Enum.reject(
        @call_name_exclusions,
        &(&1 == current_call_name_entry!({Phoenix.Digester, [:compile]}))
      )

    Enum.filter(matched_mfas, fn {module, function, _arity} = mfa ->
      exclusion_reason(module, function, @exclusions) != nil or
        Enum.any?(other_call_name_rows, fn {matcher, _reason, _citations} ->
          call_name_exclusion_match?(matcher, mfa)
        end) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp calibration_records!(graph, evidence, ledger) do
    Enum.map(["CN-005", "BD-002"], fn id ->
      row = Enum.find(ledger.exclusions, &(&1.id == id))
      assert row != nil
      assert graph.lane == evidence.lane

      {matcher, _reason, current_table} = calibration_entry!(id, row)
      lane = evidence.lane.name

      matched_mfas =
        graph.full_exported
        |> Enum.filter(fn {_module, _function, _arity} = mfa ->
          calibration_match?(id, matcher, mfa)
        end)
        |> Enum.reject(fn {_module, function, _arity} ->
          function in [:module_info, :__info__]
        end)
        |> Enum.sort_by(&mfa_string!/1)

      matched_strings = Enum.map(matched_mfas, &mfa_string!/1)
      baseline_matches = Map.fetch!(row.lane_matches, lane)

      assert MapSet.new(matched_strings) == MapSet.new(baseline_matches),
             "#{id}/#{lane} live complete matcher differs from the preserved audit-budget set"

      assert length(matched_strings) == MapSet.size(MapSet.new(matched_strings)),
             "#{id}/#{lane} complete matcher contains duplicate exports"

      citations = calibration_citations!(id, lane)

      removal_witness =
        calibration_removal_witness!(id, matcher, current_table, graph, matched_mfas)

      overlap_mfas = calibration_overlaps!(id, matcher, matched_mfas, current_table)

      assert removal_witness != [],
             "#{id}/#{lane} retained exclusion has a vacuous removal witness"

      assert overlap_mfas == [], "#{id}/#{lane} overlaps another retained exclusion"

      %{
        original_id: id,
        original_entry_raw: row.original_entry_raw,
        original_matcher_raw: row.original_matcher_raw,
        original_reason_raw: row.original_reason_raw,
        current_replacement_refs: row.current_replacement_refs,
        lane: lane,
        elixir: evidence.lane.elixir,
        otp: evidence.lane.otp,
        matched_mfas: matched_strings,
        caller_input_trace: calibration_input_trace!(id),
        trace: calibration_trace!(id),
        verdict: calibration_verdict!(id),
        citations: citations,
        source_refs:
          citations
          |> Enum.map(&elem(&1, 0))
          |> Enum.map(&(String.split(&1, ":", parts: 2) |> hd()))
          |> Enum.uniq()
          |> Enum.sort(),
        applicability: :each_exact_installed_lane,
        removal_witness: Enum.map(removal_witness, &mfa_string!/1),
        overlap_mfas: Enum.map(overlap_mfas, &mfa_string!/1),
        retained_exclusion: true,
        semantic_owner: "01.1.1.5",
        limitations: calibration_limitations!(id)
      }
    end)
  end

  defp assert_calibration_artifact_binding!(
         calibration,
         validation,
         review,
         reviewed_revision,
         graph,
         evidence,
         ledger,
         root
       ) do
    assert calibration == validation,
           "calibration and validation evidence records differ"

    assert_calibration_envelope!(calibration, review, reviewed_revision)
    budget = calibration_budget!(root)
    partitions = calibration["partitions"]
    assert_calibration_partition_sets!(partitions, budget)

    Enum.each(calibration["lanes"], fn {lane, lane_record} ->
      review_lane = Map.fetch!(review["lanes"], lane)

      assert_calibration_lane_record!(
        lane_record,
        review_lane,
        lane,
        reviewed_revision,
        partitions
      )
    end)

    assert_calibration_telemetry!(calibration["telemetry"])
    assert_calibration_live_lane!(calibration, review, graph, evidence, ledger, root)
    :ok
  end

  defp assert_calibration_envelope!(calibration, review, reviewed_revision) do
    assert calibration["schema"] == "fablebook.phase-calibration/1"
    assert calibration["phase"] == "01.1.1.5"

    assert calibration["owners"] == %{
             "unsampled" => "01.1.1.4",
             "macro" => "01.1.1.4",
             "wording" => "01.1.1.4",
             "sec01" => "Phase 5",
             "phase2_dependency" => "01.1.1.4"
           }

    assert Map.keys(calibration["lanes"]) |> Enum.sort() == ["core", "floor"]
    assert review["schema"] == "fablebook.phase-review-effort/1"
    assert review["phase"] == "01.1.1.5"
    assert review["plan"] == "03"
    assert Map.keys(review["lanes"]) |> Enum.sort() == ["core", "floor"]
    assert String.match?(reviewed_revision, ~r/^[0-9a-f]{40}$/)
  end

  defp calibration_budget!(root) do
    budget_path =
      Path.join(
        root,
        ".planning/milestones/v0.1-phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-AUDIT-BUDGET.json"
      )

    budget_path |> File.read!() |> JSON.decode!()
  end

  defp assert_calibration_partition_sets!(partitions, budget) do
    assert is_list(partitions) and partitions != []
    expected_module_functions = expected_partition_matches!(budget)
    partition_modules = Enum.flat_map(partitions, &Map.keys(&1["module_function_counts"]))
    assert length(partition_modules) == MapSet.size(MapSet.new(partition_modules))

    expected_modules =
      expected_module_functions
      |> Map.values()
      |> Enum.flat_map(&Map.keys/1)
      |> MapSet.new()

    assert MapSet.new(partition_modules) == expected_modules

    Enum.each(
      ["core", "floor"],
      &assert_partition_counts!(partitions, expected_module_functions, &1)
    )
  end

  defp expected_partition_matches!(budget) do
    expected_module_functions =
      Map.new(["core", "floor"], fn lane ->
        matches = Enum.flat_map(budget["lanes"][lane]["rows"], & &1["matches"])

        functions =
          Enum.reduce(matches, %{}, fn [module, function, arity], acc ->
            Map.update(
              acc,
              module,
              MapSet.new(["#{function}/#{arity}"]),
              &MapSet.put(&1, "#{function}/#{arity}")
            )
          end)

        {lane,
         Map.new(functions, fn {module, mfas} -> {module, MapSet.to_list(mfas) |> Enum.sort()} end)}
      end)

    expected_module_functions
  end

  defp assert_partition_counts!(partitions, expected_module_functions, lane) do
    actual_counts =
      for partition <- partitions,
          {module, counts} <- partition["module_function_counts"],
          counts[lane] not in [nil, 0],
          into: %{},
          do: {module, counts[lane]}

    expected_counts =
      Map.new(expected_module_functions[lane], fn {module, mfas} -> {module, length(mfas)} end)

    assert actual_counts == expected_counts,
           "#{lane} proposed module partitions differ from the complete original MFA sets"
  end

  defp assert_calibration_lane_record!(
         lane_record,
         review_lane,
         lane,
         reviewed_revision,
         partitions
       ) do
    assert MapSet.new(lane_record["samples"]) == MapSet.new(["CN-005", "BD-002", "EX-159"])

    assert Map.keys(lane_record["matched_mfas"]) |> Enum.sort() == [
             "BD-002",
             "CN-005",
             "EX-159"
           ]

    assert is_number(lane_record["graph_seconds"]) and lane_record["graph_seconds"] > 0
    assert is_number(lane_record["inventory_seconds"]) and lane_record["inventory_seconds"] > 0
    assert is_integer(lane_record["source_bytes"]) and lane_record["source_bytes"] > 0
    assert is_number(lane_record["review_seconds"]) and lane_record["review_seconds"] > 0
    assert nonempty_evidence_string?(lane_record["source_method"])
    assert nonempty_evidence_string?(lane_record["review_method"])
    assert nonempty_evidence_string?(lane_record["uncertainty"])

    source_rows = lane_record["sources"]
    assert_calibration_source_rows!(source_rows, lane_record["source_bytes"])
    source_paths = Enum.map(source_rows, & &1["path"])
    assert abs(lane_record["review_seconds"] - review_lane["review_seconds"]) <= 0.000001
    assert lane_record["review_method"] == review_lane["review_method"]

    assert_review_effort_lane!(review_lane, lane, lane_record, reviewed_revision, source_paths)
    Enum.each(partitions, &assert_partition_record!(&1, lane))
  end

  defp assert_calibration_source_rows!(source_rows, source_bytes) do
    assert is_list(source_rows) and source_rows != []
    source_paths = Enum.map(source_rows, & &1["path"])
    assert length(source_paths) == MapSet.size(MapSet.new(source_paths))
    Enum.each(source_rows, &assert_calibration_source_row!/1)
    assert source_bytes == Enum.sum(Enum.map(source_rows, & &1["size_bytes"]))
  end

  defp assert_calibration_source_row!(source) do
    assert nonempty_evidence_string?(source["path"])
    assert String.match?(source["sha256"], ~r/^[0-9a-f]{64}$/)
    assert is_integer(source["size_bytes"]) and source["size_bytes"] > 0
  end

  defp assert_partition_record!(partition, lane) do
    assert partition["owner"] == "01.1.1.4"

    assert MapSet.new(partition["source_modules"]) ==
             MapSet.new(Map.keys(partition["module_function_counts"]))

    assert nonempty_evidence_string?(partition["matched_set_ref"][lane])

    assert partition["matched_set_ref"][lane] =~
             "01.1.1.1-AUDIT-BUDGET.json#lanes/#{lane}/rows"

    assert nonempty_evidence_string?(partition["review_effort_method"])
    assert nonempty_evidence_string?(partition["uncertainty"])
    assert is_list(partition["source_refs"]) and partition["source_refs"] != []
    assert is_list(partition["shared_source_refs"])

    assert Enum.any?(
             partition["source_refs"],
             &String.contains?(&1, "01.1.1.1-AUDIT-BUDGET.json#lanes/#{lane}/sources")
           )
  end

  defp assert_calibration_live_lane!(calibration, review, graph, evidence, ledger, root) do
    lane = evidence.lane.name
    lane_record = Map.fetch!(calibration["lanes"], lane)
    versions = SweepEvidence.lane!()
    assert lane_record["elixir"] == versions.elixir
    assert lane_record["otp"] == versions.otp
    assert graph.lane == versions

    expected_mfas = expected_sample_matches!(graph, ledger, lane)
    assert_calibration_live_matches!(lane_record, expected_mfas, lane)

    {source_rows, citations} = calibration_source_rows!(graph, evidence, ledger, lane)

    assert_calibration_live_sources!(
      lane_record,
      review,
      source_rows,
      citations,
      evidence,
      lane,
      root
    )
  end

  defp assert_calibration_live_matches!(lane_record, expected_mfas, lane) do
    Enum.each(expected_mfas, fn {id, mfas} ->
      actual = Map.fetch!(lane_record["matched_mfas"], id)

      assert Enum.sort(actual) == mfas,
             "#{id}/#{lane} artifact MFA set differs from the complete original matcher"

      assert length(actual) == MapSet.size(MapSet.new(actual)),
             "#{id}/#{lane} artifact MFA set contains duplicates"
    end)
  end

  defp assert_calibration_live_sources!(
         lane_record,
         review,
         source_rows,
         citations,
         evidence,
         lane,
         root
       ) do
    actual_source_rows =
      Enum.map(lane_record["sources"], &Map.take(&1, ["path", "sha256", "size_bytes"]))

    assert Enum.sort_by(actual_source_rows, & &1["path"]) ==
             Enum.sort_by(source_rows, & &1["path"]),
           "#{lane} calibration source tuples differ from graph locations and resolved citations"

    assert lane_record["source_bytes"] == Enum.sum(Enum.map(source_rows, & &1["size_bytes"]))

    assert review["lanes"][lane]["provenance"]["source_set_sha256"] ==
             canonical_source_set_digest!(source_rows)

    review_path = calibration_review_path!(lane)
    expected_refs = calibration_evidence_refs!(citations, review_path)
    actual_refs = lane_record["evidence_refs"]
    assert actual_refs == Enum.sort(Enum.uniq(actual_refs))

    assert actual_refs == expected_refs,
           "#{lane} evidence references differ from the selected citations and review marker"

    Enum.each(citations, &assert_resolved_citation!(evidence, &1))
    assert_review_summary_path!(review_path, root)
  end

  defp calibration_review_path!(lane) do
    ".planning/phases/01.1.1.5-complete-atom-creator-fronts-and-audit-calibration/01.1.1.5-03-SUMMARY.md#fablebook.review-effort/#{lane}"
  end

  defp calibration_evidence_refs!(citations, review_path) do
    (Enum.map(citations, fn {citation, _expected_text} -> "source:#{citation}" end) ++
       ["review:#{review_path}"])
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp assert_resolved_citation!(evidence, {citation, expected_text}) do
    resolved = SweepEvidence.resolve!(evidence, citation)
    assert resolved.text =~ expected_text, citation
  end

  defp assert_review_summary_path!(review_path, root) do
    summary_reference =
      review_path
      |> String.split("#", parts: 2)
      |> hd()
      |> String.replace_prefix(".planning/phases/", ".planning/milestones/v0.1-phases/")

    summary_absolute = Path.expand(summary_reference, root)
    assert summary_absolute == Path.join(root, summary_reference)
    assert {:ok, %{type: :regular}} = File.lstat(summary_absolute)
  end

  defp assert_calibration_telemetry!(telemetry) do
    assert telemetry["value"] == "unknown"
    assert telemetry["unit"] == "model_context_tokens"
    assert telemetry["scope"] == "not_measured"
    assert telemetry["delegated_coverage"] == "none_by_policy"
    assert telemetry["status"] == "estimate_only"
    assert nonempty_evidence_string?(telemetry["source"])
    assert nonempty_evidence_string?(telemetry["reason"])
  end

  defp expected_sample_matches!(graph, ledger, lane) do
    Enum.map(["CN-005", "BD-002", "EX-159"], fn id ->
      row = Enum.find(ledger.exclusions, &(&1.id == id))
      assert row != nil

      matcher =
        case id do
          id when id in ["CN-005", "BD-002"] ->
            {matcher, _reason, _table} = calibration_entry!(id, row)
            matcher

          "EX-159" ->
            creator = Enum.find(@creator_audit, &(&1.original_id == id and &1.lane == lane))
            assert creator != nil
            assert row.original_matcher_raw == inspect(creator.original_matcher)
            creator.original_matcher
        end

      matched =
        graph.full_exported
        |> Enum.filter(fn mfa -> original_sample_match?(id, matcher, mfa) end)
        |> Enum.reject(fn {_module, function, _arity} ->
          function in [:module_info, :__info__]
        end)
        |> Enum.map(&mfa_string!/1)
        |> Enum.sort()

      assert matched != []

      assert MapSet.new(matched) == MapSet.new(row.lane_matches[lane]),
             "#{id}/#{lane} live full-export matcher differs from the preserved budget set"

      {id, matched}
    end)
  end

  defp original_sample_match?(id, matcher, mfa) when id in ["CN-005", "BD-002"],
    do: calibration_match?(id, matcher, mfa)

  defp original_sample_match?("EX-159", matcher, mfa),
    do: creator_original_match?(matcher, mfa)

  defp calibration_source_rows!(graph, evidence, ledger, lane) do
    expected_mfas = expected_sample_matches!(graph, ledger, lane)

    matched_modules =
      expected_mfas
      |> Enum.flat_map(fn {_id, mfas} -> mfas end)
      |> Enum.map(fn mfa ->
        [module, _rest] = String.split(mfa, ":", parts: 2)
        module
      end)
      |> Enum.uniq()

    graph_paths = Enum.map(matched_modules, &graph_source_path!(graph, evidence, &1))
    citations = Enum.flat_map(["CN-005", "BD-002", "EX-159"], &sample_citations!(&1, lane))

    citation_paths =
      Enum.map(citations, fn {citation, _text} -> citation_source_path!(citation) end)

    paths = Enum.uniq(graph_paths ++ citation_paths) |> Enum.sort()

    source_rows =
      Enum.map(paths, fn path ->
        resolved = SweepEvidence.resolve!(evidence, path <> ":1")
        assert {:ok, %{type: :regular, size: size}} = File.lstat(resolved.path)
        bytes = File.read!(resolved.path)
        sha256 = :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
        assert sha256 == resolved.sha256
        assert byte_size(bytes) == size

        %{"path" => path, "sha256" => sha256, "size_bytes" => size}
      end)

    {Enum.sort_by(source_rows, & &1["path"]), citations}
  end

  defp graph_source_path!(graph, evidence, module_name) do
    module =
      Enum.find(graph.module_app, fn {module, _app} -> Atom.to_string(module) == module_name end)

    assert module != nil, "full Xref graph has no app identity for #{module_name}"
    {module_atom, app} = module

    inventory_rows =
      for source_app <- graph.sources,
          beam <- source_app.beams,
          beam.module == module_name,
          do: {source_app.app, beam}

    case inventory_rows do
      [{^app, %{source: source, status: "present"}}] ->
        path = app <> "/" <> source
        assert SweepEvidence.resolve!(evidence, path <> ":1").path
        path

      [] ->
        graph_source_path_from_compile_info!(module_atom, app, evidence)

      other ->
        raise ExUnit.AssertionError,
          message:
            "graph source inventory has ambiguous or unavailable identity for #{module_name}: #{inspect(other)}"
    end
  end

  defp graph_source_path_from_compile_info!(module_atom, app, evidence) do
    beam_path = :code.which(module_atom) |> to_string()

    assert File.regular?(beam_path),
           "loaded exact-lane BEAM is absent for #{Atom.to_string(module_atom)}"

    {:ok, {^module_atom, chunks}} =
      :beam_lib.chunks(String.to_charlist(beam_path), [:compile_info])

    compile_info = Keyword.fetch!(chunks, :compile_info)
    source_path = compile_info |> Keyword.fetch!(:source) |> to_string()

    prefix = app <> "/"

    matching_rows =
      Enum.filter(evidence.manifest["files"], fn row ->
        row["lane"] == evidence.lane.name and row["status"] == "present" and
          String.starts_with?(row["source_path"] || "", prefix) and
          String.ends_with?(source_path, String.replace_prefix(row["source_path"], prefix, ""))
      end)

    assert length(matching_rows) == 1,
           "compiler source location for #{Atom.to_string(module_atom)} does not identify one exact-lane manifest row: #{source_path}"

    path = hd(matching_rows)["source_path"]
    assert SweepEvidence.resolve!(evidence, path <> ":1").path
    path
  end

  defp sample_citations!("CN-005", lane), do: calibration_citations!("CN-005", lane)
  defp sample_citations!("BD-002", lane), do: calibration_citations!("BD-002", lane)

  defp sample_citations!("EX-159", lane) do
    creator = Enum.find(@creator_audit, &(&1.original_id == "EX-159" and &1.lane == lane))
    assert creator != nil
    creator.citations
  end

  defp citation_source_path!(citation) do
    case Regex.run(~r/^([a-z_]+\/(?:src|lib)\/[^:]+):[1-9][0-9]*$/, citation) do
      [_, path] -> path
      _ -> raise ExUnit.AssertionError, message: "invalid selected source citation #{citation}"
    end
  end

  defp canonical_source_set_digest!(source_rows) do
    bytes =
      source_rows
      |> Enum.map(fn source ->
        source["path"] <>
          <<0>> <> source["sha256"] <> <<0>> <> Integer.to_string(source["size_bytes"])
      end)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.join("\n")

    :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
  end

  defp assert_review_effort_lane!(
         lane_record,
         lane,
         calibration_lane,
         reviewed_revision,
         source_paths
       ) do
    expected_versions =
      case lane do
        "core" -> {"1.20.4", "29.1.2"}
        "floor" -> {"1.18.5", "27.3.4.9"}
      end

    assert {lane_record["elixir"], lane_record["otp"]} == expected_versions
    assert lane_record["sample_ids"] |> MapSet.new() == MapSet.new(["CN-005", "BD-002", "EX-159"])
    assert nonempty_evidence_string?(lane_record["clock_source"])
    assert nonempty_evidence_string?(lane_record["clock_context_id"])
    assert lane_record["clock_unit"] == "nanoseconds"
    assert nonempty_evidence_string?(lane_record["review_method"])
    assert nonempty_evidence_string?(lane_record["uncertainty"])

    intervals = lane_record["intervals"]
    assert is_list(intervals) and intervals != []
    ids = Enum.map(intervals, & &1["id"])
    assert length(ids) == MapSet.size(MapSet.new(ids))

    Enum.each(intervals, fn interval ->
      assert nonempty_evidence_string?(interval["id"])
      assert interval["clock_context_id"] == lane_record["clock_context_id"]
      assert is_integer(interval["start_ns"]) and is_integer(interval["end_ns"])
      assert interval["end_ns"] > interval["start_ns"]
      assert is_list(interval["sample_ids"]) and interval["sample_ids"] != []
      assert is_list(interval["source_refs"]) and interval["source_refs"] != []

      assert MapSet.subset?(
               MapSet.new(interval["sample_ids"]),
               MapSet.new(lane_record["sample_ids"])
             )

      assert MapSet.subset?(MapSet.new(interval["source_refs"]), MapSet.new(source_paths))
    end)

    intervals
    |> Enum.sort_by(& &1["start_ns"])
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.each(fn [left, right] ->
      assert left["end_ns"] <= right["start_ns"], "#{lane} review intervals overlap"
    end)

    sample_coverage = intervals |> Enum.flat_map(& &1["sample_ids"]) |> MapSet.new()
    source_coverage = intervals |> Enum.flat_map(& &1["source_refs"]) |> MapSet.new()
    assert sample_coverage == MapSet.new(lane_record["sample_ids"])
    assert source_coverage == MapSet.new(source_paths)

    elapsed = Enum.sum(Enum.map(intervals, &(&1["end_ns"] - &1["start_ns"])))
    assert lane_record["review_elapsed_ns"] == elapsed
    assert abs(lane_record["review_seconds"] - elapsed / 1_000_000_000) <= 0.000001
    assert abs(calibration_lane["review_seconds"] - lane_record["review_seconds"]) <= 0.000001
    assert calibration_lane["review_method"] == lane_record["review_method"]

    provenance = lane_record["provenance"]
    assert nonempty_evidence_string?(provenance["recorded_by"])
    assert provenance["reviewed_revision"] == reviewed_revision
    assert String.match?(provenance["reviewed_revision"], ~r/^[0-9a-f]{40}$/)
    assert provenance["source_archive_sha256"] == @calibration_source_archive_sha
    assert String.match?(provenance["source_set_sha256"], ~r/^[0-9a-f]{64}$/)

    doc_digest = canonical_source_set_digest!(calibration_lane["sources"])
    assert provenance["source_set_sha256"] == doc_digest
    :ok
  end

  defp single_json_comment!(text, marker) do
    marker_regex = Regex.compile!("^<!-- " <> Regex.escape(marker) <> ": (.+) -->$", "m")
    rows = Regex.scan(marker_regex, text, capture: :all_but_first)
    assert length(rows) == 1, "expected exactly one #{marker} marker"

    try do
      JSON.decode!(hd(hd(rows)))
    rescue
      error ->
        reraise ExUnit.AssertionError,
                [
                  message: "#{marker} marker must contain valid JSON: #{Exception.message(error)}"
                ],
                __STACKTRACE__
    end
  end

  defp summary_reviewed_revision!(text) do
    case Regex.run(~r/^reviewed_revision: ([0-9a-f]{40})$/m, text) do
      [_, revision] ->
        revision

      _ ->
        raise ExUnit.AssertionError,
          message: "Plan 03 SUMMARY frontmatter lacks reviewed_revision"
    end
  end

  defp expect_calibration_rejected!(
         calibration,
         validation,
         review,
         revision,
         graph,
         evidence,
         ledger,
         root
       ) do
    assert_raise ExUnit.AssertionError, fn ->
      assert_calibration_artifact_binding!(
        calibration,
        validation,
        review,
        revision,
        graph,
        evidence,
        ledger,
        root
      )
    end
  end

  defp nonempty_evidence_string?(value),
    do:
      is_binary(value) and String.trim(value) != "" and
        String.downcase(String.trim(value)) != "unknown"

  defp assert_calibration_records!(records, graph, evidence, ledger) do
    expected = calibration_records!(graph, evidence, ledger)
    assert records == expected

    assert MapSet.new(Enum.map(records, &{&1.original_id, &1.lane})) ==
             MapSet.new(Enum.map(expected, &{&1.original_id, &1.lane}))

    Enum.each(records, fn record ->
      assert record.citations != []

      Enum.each(record.citations, fn {citation, expected_source} ->
        resolved = SweepEvidence.resolve!(evidence, citation)
        assert resolved.text =~ expected_source, citation
      end)
    end)
  end

  defp calibration_entry!("CN-005", row) do
    entry = current_call_name_entry!({Regex, [:compile]})
    assert {{Regex, [:compile]}, :not_compile_module, _citations} = entry
    assert hd(row.current_replacement_refs) == current_call_name_ref!({Regex, [:compile]})
    {elem(entry, 0), elem(entry, 1), :call_name}
  end

  defp calibration_entry!("BD-002", row) do
    entry = Enum.at(@boundary_exclusions, 1)
    assert {{:code, functions}, :pure_data, _citations} = entry

    assert functions == [
             :compiler_dir,
             :get_doc,
             :get_object_code,
             :lib_dir,
             :priv_dir,
             :root_dir,
             :where_is_file,
             :which
           ]

    assert hd(row.current_replacement_refs) == "source:BD:2"
    {elem(entry, 0), elem(entry, 1), :boundary}
  end

  defp calibration_match?("CN-005", matcher, mfa), do: call_name_exclusion_match?(matcher, mfa)
  defp calibration_match?("BD-002", matcher, mfa), do: boundary_match?(matcher, mfa)

  defp exclusion_record_matches_mfa?({{:mfa, pattern}, _reason, _citations}, mfa)
       when is_tuple(pattern) and tuple_size(pattern) == 3 do
    pattern
    |> Tuple.to_list()
    |> Enum.zip(Tuple.to_list(mfa))
    |> Enum.all?(fn {expected, actual} -> expected == :_ or expected == actual end)
  end

  defp exclusion_record_matches_mfa?({matcher, _reason}, {module, function, _arity}),
    do: exclusion_match?(matcher, module, function)

  defp exclusion_record_matches_mfa?({matcher, _reason, _citations}, {module, function, _arity}),
    do: exclusion_match?(matcher, module, function)

  defp exclusion_record_matches_mfa?(_record, _mfa), do: false

  defp assert_inets_trace_floor_witnesses!(record, graph, exclusions \\ @exclusions) do
    original = {{:inets, [:enable_trace]}, :own_native}
    assert record.lane == "floor", "floor matcher witness lane changed"
    assert original in exclusions

    selected_mfas = Enum.map(record.selected_function_evidence, & &1.mfa)

    actual_matches =
      graph.full_exported
      |> Enum.filter(&call_name_exclusion_match?({:inets, [:enable_trace]}, &1))
      |> Enum.uniq()
      |> Enum.sort()

    assert length(record.matched_mfas) == MapSet.size(MapSet.new(record.matched_mfas)),
           "duplicate floor matcher MFA"

    assert Enum.sort(record.matched_mfas) == actual_matches,
           "complete live matcher set changed"

    assert record.matched_mfas == selected_mfas,
           "floor selected matcher identity/order changed"

    actual_overlaps =
      Enum.filter(exclusions, fn exclusion ->
        Enum.any?(selected_mfas, &exclusion_record_matches_mfa?(exclusion, &1))
      end)

    assert actual_overlaps == [original], "EX-010 overlap set changed"

    call_name_overlaps =
      Enum.filter(@call_name_exclusions, fn {matcher, _reason, _citations} ->
        Enum.any?(selected_mfas, &call_name_exclusion_match?(matcher, &1))
      end)

    boundary_overlaps =
      Enum.filter(@boundary_exclusions, fn {matcher, _reason, _citations} ->
        Enum.any?(selected_mfas, &boundary_match?(matcher, &1))
      end)

    assert call_name_overlaps == [], "EX-010 overlaps a call-name exclusion"
    assert boundary_overlaps == [], "EX-010 overlaps a boundary exclusion"

    without_original = List.delete(exclusions, original)

    witnesses =
      Enum.map(selected_mfas, fn mfa ->
        assert call_name_exclusion_match?({:inets, [:enable_trace]}, mfa)

        remaining_overlaps =
          Enum.filter(without_original, &exclusion_record_matches_mfa?(&1, mfa))

        call_name_overlaps =
          Enum.filter(@call_name_exclusions, fn {matcher, _reason, _citations} ->
            call_name_exclusion_match?(matcher, mfa)
          end)

        boundary_overlaps =
          Enum.filter(@boundary_exclusions, fn {matcher, _reason, _citations} ->
            boundary_match?(matcher, mfa)
          end)

        overlaps = remaining_overlaps ++ call_name_overlaps ++ boundary_overlaps

        assert overlaps == [],
               "removing only EX-010 must expose #{inspect(mfa)}; overlap=#{inspect(overlaps)}"

        %{
          mfa: mfa,
          original_matcher: original,
          removed_matcher_exposes_mfa: not Enum.any?(overlaps),
          overlapping_matchers: overlaps
        }
      end)

    assert record.individual_exclusion_witnesses == witnesses,
           "individual removal witness evidence changed"

    :ok
  end

  defp assert_inets_trace_floor_membership!(record, graph) do
    selected_mfas = Enum.map(record.selected_function_evidence, & &1.mfa)

    actual_matches =
      graph.full_exported
      |> Enum.filter(&call_name_exclusion_match?({:inets, [:enable_trace]}, &1))
      |> Enum.uniq()
      |> Enum.sort()

    assert selected_mfas == record.matched_mfas, "floor live matcher coverage changed"

    assert record.matched_mfas == selected_mfas ++ record.remainder_mfas,
           "floor selected/remainder partition changed"

    assert length(record.matched_mfas) == MapSet.size(MapSet.new(record.matched_mfas)),
           "floor matcher evidence contains duplicate MFAs"

    assert record.matched_mfas == actual_matches,
           "live floor EX-010 matcher coverage changed"

    selected_set = MapSet.new(selected_mfas)
    remainder_set = MapSet.new(record.remainder_mfas)
    assert MapSet.disjoint?(selected_set, remainder_set)
    assert record.remainder_mfas == actual_matches -- selected_mfas

    selected_mfas
  end

  defp assert_inets_trace_floor_sources!(record, graph, evidence, archive_only) do
    canonical = Fablebook.Test.InetsTraceFloorEvidence.record()
    ledger = original_identity_ledger!()
    original = Enum.find(ledger.exclusions, &(&1.id == "EX-010"))
    assert evidence.lane.name == "floor"
    assert record.lane == evidence.lane.name, "lane mismatch"
    assert record.original_id == original.id
    assert record.owner == original.owner
    assert record.owner == "01.1.1.4"
    assert record.semantic_status == :pending
    assert record.checker_status == :candidate_only
    assert original.original_matcher_raw == "{:inets, [:enable_trace]}"

    ex011 = Enum.find(ledger.exclusions, &(&1.id == "EX-011"))
    assert ex011.owner == "01.1.1.4"
    assert ex011.semantic_status == :pending
    assert ex011.original_matcher_raw == ":inets_trace"

    assert record.selected_function_evidence == canonical.selected_function_evidence,
           "floor selected source findings changed"

    assert record.reviews == canonical.reviews,
           "floor review citation evidence changed"

    assert record.exact_sources == canonical.exact_sources,
           "floor exact source identities changed"

    selected_mfas = assert_inets_trace_floor_membership!(record, graph)

    actual_incoming =
      graph.full_edges
      |> Enum.filter(fn {_caller, {module, function}} ->
        module == :inets and function == :enable_trace
      end)
      |> MapSet.new()

    expected_incoming =
      MapSet.new(record.incoming_edges, fn edge ->
        {edge.caller, {elem(edge.callee, 0), elem(edge.callee, 1)}}
      end)

    assert actual_incoming == expected_incoming, "floor incoming edge evidence changed"

    expected_delegates =
      MapSet.new(record.delegate_edges, fn edge ->
        {edge.caller, {elem(edge.callee, 0), elem(edge.callee, 1)}}
      end)

    actual_delegates =
      graph.full_edges
      |> Enum.filter(fn {caller, _callee} -> caller in selected_mfas end)
      |> MapSet.new()

    assert actual_delegates == expected_delegates, "floor delegate edge evidence changed"
    assert length(record.delegate_edges) == MapSet.size(expected_delegates)

    expected_exclusion = {{:inets, [:enable_trace]}, :own_native}
    assert expected_exclusion in @exclusions

    overlaps =
      Enum.filter(@exclusions, fn exclusion ->
        Enum.any?(selected_mfas, &exclusion_record_matches_mfa?(exclusion, &1))
      end)

    assert overlaps == [expected_exclusion],
           "floor EX-010 overlap set changed; each overlap must enter the witness"

    assert Enum.all?(record.selected_function_evidence, fn finding ->
             Enum.all?(
               [
                 finding.input_trace,
                 finding.destination_dispatch,
                 finding.service_validation,
                 finding.callback_boundary,
                 finding.fixed_native_boundary,
                 finding.finding
               ],
               &(is_binary(&1) and byte_size(&1) > 0)
             )
           end),
           "incomplete floor source finding"

    expected_url =
      "https://raw.githubusercontent.com/erlang/otp/4aa809ae4eb4a20ad89c23837376acf179877f39/lib/"

    expected_sources =
      Map.new(canonical.exact_sources, fn {path, bytes, sha} -> {path, {bytes, sha}} end)

    reviews = Map.new(record.reviews, &{&1.source_path, &1})
    assert Map.keys(reviews) |> Enum.sort() == Map.keys(expected_sources) |> Enum.sort()

    for {source_path, {bytes, sha}} <- expected_sources do
      [source_row] =
        Enum.filter(evidence.manifest["files"], fn row ->
          row["lane"] == "floor" and row["source_path"] == source_path
        end)

      assert Map.take(source_row, ["lane", "status", "path", "url", "bytes", "sha256"]) == %{
               "lane" => "floor",
               "status" => "present",
               "path" => "floor/" <> source_path,
               "url" => expected_url <> source_path,
               "bytes" => bytes,
               "sha256" => sha
             },
             "floor source identity manifest mismatch"

      resolved = SweepEvidence.resolve!(archive_only, source_path <> ":1")
      assert resolved.origin == :archive
      assert resolved.sha256 == sha
      source = File.read!(resolved.path)
      assert byte_size(source) == bytes
      assert :crypto.hash(:sha256, source) |> Base.encode16(case: :lower) == sha

      lines = String.split(source, "\n")
      line_count = if String.ends_with?(source, "\n"), do: length(lines) - 1, else: length(lines)
      review = Map.fetch!(reviews, source_path)
      assert review.reviewed_lines == 1..line_count

      for {citation, body} <- review.citations do
        cited = SweepEvidence.resolve!(archive_only, citation)
        assert cited.origin == :archive
        assert cited.sha256 == sha
        assert cited.line in review.reviewed_lines
        assert cited.text =~ body
      end
    end

    for finding <- record.selected_function_evidence,
        {citation, body} <- finding.citations do
      cited = SweepEvidence.resolve!(archive_only, citation)
      assert cited.origin == :archive
      assert cited.text =~ body
    end

    :ok
  end

  defp assert_inets_trace_core_evidence!(record, graph, evidence, archive_only) do
    canonical = Fablebook.Test.InetsTraceCoreEvidence.record()
    ledger = original_identity_ledger!()
    original = Enum.find(ledger.exclusions, &(&1.id == "EX-010"))

    assert evidence.lane.name == "core"
    assert record.lane == evidence.lane.name, "lane mismatch"
    assert record.original_id == original.id
    assert record.owner == original.owner
    assert record.semantic_status == :pending, "unsupported semantic status"
    assert record.checker_status == :candidate_only, "candidate-only status changed"
    assert original.owner == "01.1.1.4"
    assert original.original_entry_raw == "{{:inets, [:enable_trace]}, :own_native}"
    assert original.original_matcher_raw == "{:inets, [:enable_trace]}"
    assert original.semantic_status == :pending

    ex011 = Enum.find(ledger.exclusions, &(&1.id == "EX-011"))
    assert ex011.owner == "01.1.1.4"
    assert ex011.semantic_status == :pending
    assert ex011.original_matcher_raw == ":inets_trace"

    assert ex011.lane_matches == %{
             "core" => [
               "inets_trace:disable/0",
               "inets_trace:enable/2",
               "inets_trace:enable/3",
               "inets_trace:report_event/4",
               "inets_trace:set_level/1",
               "inets_trace:set_level/2"
             ],
             "floor" => [
               "inets_trace:disable/0",
               "inets_trace:enable/2",
               "inets_trace:enable/3",
               "inets_trace:report_event/4",
               "inets_trace:set_level/1",
               "inets_trace:set_level/2"
             ]
           }

    assert record.selected_function_evidence == canonical.selected_function_evidence,
           "selected finding evidence changed"

    assert record.exact_sources == canonical.exact_sources,
           "exact source identity set changed"

    assert record.reviews == canonical.reviews,
           "review citation evidence changed"

    selected_mfas = Enum.map(record.selected_function_evidence, & &1.mfa)

    actual_matches =
      graph.full_exported
      |> Enum.filter(&call_name_exclusion_match?({:inets, [:enable_trace]}, &1))
      |> Enum.sort()

    assert selected_mfas == @inets_trace_core_mfas

    assert record.matched_mfas == selected_mfas ++ record.remainder_mfas,
           "selected MFA identity/order changed"

    assert length(record.matched_mfas) == MapSet.size(MapSet.new(record.matched_mfas)),
           "duplicate selected MFA evidence"

    assert record.matched_mfas == actual_matches,
           "live matcher coverage changed; missing=#{inspect(actual_matches -- record.matched_mfas)}; unexpected=#{inspect(record.matched_mfas -- actual_matches)}"

    selected_set = MapSet.new(selected_mfas)
    remainder_set = MapSet.new(record.remainder_mfas)

    assert MapSet.disjoint?(selected_set, remainder_set),
           "selected and remainder MFA sets overlap"

    assert record.remainder_mfas == actual_matches -- selected_mfas

    actual_incoming =
      graph.full_edges
      |> Enum.filter(fn {_caller, {module, function}} ->
        module == :inets and function == :enable_trace
      end)
      |> Enum.sort()

    expected_incoming =
      Enum.map(record.incoming_edges, fn edge ->
        {edge.caller, {elem(edge.callee, 0), elem(edge.callee, 1)}}
      end)

    assert actual_incoming == Enum.sort(expected_incoming), "incoming edge evidence changed"

    assert record.delegate_edges == canonical.delegate_edges, "delegate evidence changed"

    expected_delegates =
      Enum.map(record.delegate_edges, fn edge ->
        {edge.caller, {elem(edge.callee, 0), elem(edge.callee, 1)}}
      end)

    actual_delegates =
      graph.full_edges
      |> Enum.filter(fn {caller, _callee} -> caller in selected_mfas end)
      |> MapSet.new()

    expected_delegate_set = MapSet.new(expected_delegates)

    assert length(expected_delegates) == MapSet.size(MapSet.new(expected_delegates)),
           "duplicate delegate evidence"

    assert actual_delegates == expected_delegate_set,
           "delegate evidence changed; missing=#{inspect(MapSet.difference(expected_delegate_set, actual_delegates))}; unexpected=#{inspect(MapSet.difference(actual_delegates, expected_delegate_set))}"

    original_exclusion = {{:inets, [:enable_trace]}, :own_native}
    assert original_exclusion in @exclusions

    covering_exclusions =
      Enum.filter(@exclusions, fn exclusion ->
        Enum.any?(selected_mfas, &exclusion_record_matches_mfa?(exclusion, &1))
      end)

    assert covering_exclusions == [original_exclusion],
           "EX-010 overlap set changed; every overlap must participate in the removal witness"

    call_name_overlaps =
      Enum.filter(@call_name_exclusions, fn {matcher, _reason, _citations} ->
        Enum.any?(selected_mfas, &call_name_exclusion_match?(matcher, &1))
      end)

    assert call_name_overlaps == [],
           "EX-010 overlaps a call-name exclusion; include it in each removal witness"

    boundary_overlaps =
      Enum.filter(@boundary_exclusions, fn {matcher, _reason, _citations} ->
        Enum.any?(selected_mfas, &boundary_match?(matcher, &1))
      end)

    assert boundary_overlaps == [],
           "EX-010 overlaps a boundary exclusion; include it in each removal witness"

    without_original = Enum.reject(@exclusions, &(&1 == original_exclusion))

    for mfa <- selected_mfas do
      assert call_name_exclusion_match?({:inets, [:enable_trace]}, mfa)

      refute Enum.any?(without_original, &exclusion_record_matches_mfa?(&1, mfa)),
             "removing only EX-010 must expose #{inspect(mfa)}; an overlap cannot fake the witness"
    end

    expected_sources =
      Map.new(record.exact_sources, fn {path, bytes, sha} -> {path, {bytes, sha}} end)

    assert map_size(expected_sources) == length(record.exact_sources)

    assert Map.keys(expected_sources) |> Enum.sort() ==
             Enum.map(canonical.exact_sources, &elem(&1, 0)) |> Enum.sort()

    reviews_by_source = Map.new(record.reviews, &{&1.source_path, &1})
    assert Map.keys(reviews_by_source) |> Enum.sort() == Map.keys(expected_sources) |> Enum.sort()

    for {source_path, {bytes, sha}} <- expected_sources do
      source_rows =
        Enum.filter(evidence.manifest["files"], fn row ->
          row["lane"] == "core" and row["source_path"] == source_path
        end)

      assert length(source_rows) == 1 and hd(source_rows)["lane"] == "core",
             "source identity manifest mismatch"

      [source_row] = source_rows

      expected_url =
        if source_path == "inets/src/inets_app/inets_trace.erl" do
          @inets_trace_core_url
        else
          "https://raw.githubusercontent.com/erlang/otp/d199a49a01a2079afb6f2c5c9ae047cd4555e68d/lib/" <>
            source_path
        end

      manifest_identity =
        Map.take(source_row, ["lane", "status", "path", "url", "bytes", "sha256"])

      expected_manifest_identity = %{
        "lane" => "core",
        "status" => "present",
        "path" => "core/" <> source_path,
        "url" => expected_url,
        "bytes" => bytes,
        "sha256" => sha
      }

      assert manifest_identity == expected_manifest_identity,
             "source identity manifest mismatch"

      resolved_source = SweepEvidence.resolve!(archive_only, source_path <> ":1")
      assert resolved_source.origin == :archive
      assert resolved_source.sha256 == sha
      source_bytes = File.read!(resolved_source.path)
      assert byte_size(source_bytes) == bytes
      assert :crypto.hash(:sha256, source_bytes) |> Base.encode16(case: :lower) == sha

      source_lines = String.split(source_bytes, "\n")

      line_count =
        if String.ends_with?(source_bytes, "\n"),
          do: length(source_lines) - 1,
          else: length(source_lines)

      review = Map.fetch!(reviews_by_source, source_path)
      assert review.reviewed_lines == 1..line_count

      assert review.citations != []

      for {citation, expected_line} <- review.citations do
        resolved = SweepEvidence.resolve!(archive_only, citation)
        assert resolved.origin == :archive
        assert resolved.sha256 == sha
        assert resolved.line in review.reviewed_lines
        assert resolved.text =~ expected_line, "review citation body changed: #{citation}"
      end
    end

    for selected <- record.selected_function_evidence,
        {citation, expected_line} <- selected.citations do
      resolved = SweepEvidence.resolve!(archive_only, citation)
      assert resolved.origin == :archive
      assert resolved.text =~ expected_line, "selected citation body changed: #{citation}"
    end

    :ok
  end

  defp assert_inets_trace_archive_rejects_wrong_ref!(dir) do
    archive = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
    {:ok, files} = :erl_tar.extract(String.to_charlist(archive), [:compressed, :memory])
    trace_path = ~c"core/inets/src/inets_app/inets_trace.erl"
    {^trace_path, trace_bytes} = Enum.find(files, fn {name, _bytes} -> name == trace_path end)

    for {name, transform_row, relocate_source, expected_reason} <- [
          {"wrong-ref",
           fn row -> Map.put(row, "url", "https://example.invalid/altered-source.erl") end,
           fn entries, _bytes -> entries end, :source_identity},
          {"wrong-lane", fn row -> %{row | "lane" => "floor"} end,
           fn entries, _bytes -> entries end, :source_root}
        ] do
      transformed_entries =
        Enum.map(files, fn
          {~c"manifest.json", data} ->
            manifest = JSON.decode!(data)

            rows =
              Enum.map(manifest["files"], fn row ->
                if row["lane"] == "core" and
                     row["source_path"] == "inets/src/inets_app/inets_trace.erl",
                   do: transform_row.(row),
                   else: row
              end)

            {~c"manifest.json", JSON.encode!(Map.put(manifest, "files", rows))}

          entry ->
            entry
        end)
        |> then(&relocate_source.(&1, trace_bytes))

      path = Path.join(dir, "inets-trace-#{name}.tar.gz")
      :ok = :erl_tar.create(String.to_charlist(path), transformed_entries, [:compressed])
      digest = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)

      error =
        assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, digest) end

      assert error.reason == expected_reason
    end

    missing_entry = Enum.reject(files, fn {path, _bytes} -> path == trace_path end)
    path = Path.join(dir, "inets-trace-missing-archive-member.tar.gz")
    :ok = :erl_tar.create(String.to_charlist(path), missing_entry, [:compressed])
    digest = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)
    error = assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, digest) end
    assert error.reason == :manifest_inventory
  end

  defp assert_inets_trace_floor_archive_negatives!(dir) do
    archive = Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)
    {:ok, files} = :erl_tar.extract(String.to_charlist(archive), [:compressed, :memory])
    floor_path = ~c"floor/inets/src/inets_app/inets_trace.erl"
    core_path = ~c"core/inets/src/inets_app/inets_trace.erl"
    {^floor_path, _floor_bytes} = Enum.find(files, fn {name, _} -> name == floor_path end)
    {^core_path, core_bytes} = Enum.find(files, fn {name, _} -> name == core_path end)

    assert_floor_archive_rejected!(
      dir,
      "missing-floor-member",
      Enum.reject(files, fn {name, _} -> name == floor_path end),
      :manifest_inventory
    )

    substituted =
      Enum.map(files, fn
        {^floor_path, _floor_bytes} -> {floor_path, core_bytes}
        entry -> entry
      end)

    assert_floor_archive_rejected!(dir, "core-bytes-in-floor-slot", substituted, :source_digest)

    Enum.each(
      [
        {"floor-wrong-ref",
         fn row -> Map.put(row, "url", "https://example.invalid/wrong.erl") end},
        {"floor-wrong-size", fn row -> Map.update!(row, "bytes", &(&1 + 1)) end},
        {"floor-wrong-hash", fn row -> Map.put(row, "sha256", String.duplicate("0", 64)) end}
      ],
      fn {name, mutate_row} ->
        entries =
          mutate_floor_inets_manifest(files, fn rows ->
            Enum.map(rows, fn row ->
              if row["lane"] == "floor" and
                   row["source_path"] == "inets/src/inets_app/inets_trace.erl",
                 do: mutate_row.(row),
                 else: row
            end)
          end)

        assert_floor_archive_rejected!(dir, name, entries, :source_identity)
      end
    )

    missing_row =
      mutate_floor_inets_manifest(files, fn rows ->
        Enum.reject(rows, fn row ->
          row["lane"] == "floor" and row["source_path"] == "inets/src/inets_app/inets_trace.erl"
        end)
      end)

    assert_floor_archive_rejected!(
      dir,
      "missing-floor-source-record",
      missing_row,
      :manifest_inventory
    )

    duplicate_row =
      mutate_floor_inets_manifest(files, fn rows ->
        row =
          Enum.find(rows, fn row ->
            row["lane"] == "floor" and
              row["source_path"] == "inets/src/inets_app/inets_trace.erl"
          end)

        rows ++ [row]
      end)

    assert_floor_archive_rejected!(
      dir,
      "duplicate-floor-source-record",
      duplicate_row,
      :manifest_duplicate
    )
  end

  defp mutate_floor_inets_manifest(entries, mutate_rows) do
    Enum.map(entries, fn
      {~c"manifest.json", data} ->
        manifest = JSON.decode!(data)
        rows = mutate_rows.(manifest["files"])
        {~c"manifest.json", JSON.encode!(Map.put(manifest, "files", rows))}

      entry ->
        entry
    end)
  end

  defp assert_floor_archive_rejected!(dir, name, entries, expected_reason) do
    path = Path.join(dir, "inets-trace-#{name}.tar.gz")
    :ok = :erl_tar.create(String.to_charlist(path), entries, [:compressed])
    digest = :crypto.hash(:sha256, File.read!(path)) |> Base.encode16(case: :lower)

    error = assert_raise SweepEvidence.Error, fn -> SweepEvidence.load_archive!(path, digest) end
    assert error.reason == expected_reason
  end

  defp mfa_string!({module, function, arity}) do
    Atom.to_string(module) <> ":" <> Atom.to_string(function) <> "/" <> Integer.to_string(arity)
  end

  defp calibration_removal_witness!("CN-005", matcher, :call_name, graph, matched_mfas) do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    whole_modules = for {module, :_, :_} <- tier, do: module

    uncovered =
      graph.full_exported
      |> Enum.filter(&banned_module_named?(&1, whole_modules))
      |> Enum.reject(fn {module, function, arity} ->
        function in [:__info__, :module_info] or
          String.starts_with?(Atom.to_string(function), "MACRO-") or
          covered?({module, function, arity}, tier, names)
      end)

    others =
      Enum.reject(@call_name_exclusions, &(&1 == current_call_name_entry!({Regex, [:compile]})))

    Enum.filter(uncovered, fn mfa ->
      mfa in matched_mfas and call_name_exclusion_match?(matcher, mfa) and
        not Enum.any?(others, fn {other_matcher, _reason, _citations} ->
          call_name_exclusion_match?(other_matcher, mfa)
        end)
    end)
  end

  defp calibration_removal_witness!("BD-002", matcher, :boundary, graph, matched_mfas) do
    tier = BannedCalls.banned_mfas()
    names = BannedCalls.banned_names()
    boundary = boundary_set(graph, tier, names)
    uncovered = Enum.reject(boundary, &covered?(&1, tier, names))
    others = Enum.reject(@boundary_exclusions, &(&1 == Enum.at(@boundary_exclusions, 1)))

    Enum.filter(uncovered, fn mfa ->
      mfa in matched_mfas and boundary_match?(matcher, mfa) and
        not Enum.any?(others, fn {other_matcher, _reason, _citations} ->
          boundary_match?(other_matcher, mfa)
        end)
    end)
  end

  defp calibration_overlaps!("CN-005", _matcher, matched_mfas, :call_name) do
    Enum.filter(matched_mfas, fn mfa ->
      exclusion_reason(elem(mfa, 0), elem(mfa, 1), @exclusions) != nil or
        Enum.any?(
          Enum.reject(
            @call_name_exclusions,
            &(&1 == current_call_name_entry!({Regex, [:compile]}))
          ),
          fn
            {other_matcher, _reason, _citations} -> call_name_exclusion_match?(other_matcher, mfa)
          end
        ) or
        Enum.any?(@boundary_exclusions, &boundary_match?(elem(&1, 0), mfa))
    end)
  end

  defp calibration_overlaps!("BD-002", _matcher, matched_mfas, :boundary) do
    Enum.filter(matched_mfas, fn mfa ->
      exclusion_reason(elem(mfa, 0), elem(mfa, 1), @exclusions) != nil or
        Enum.any?(@call_name_exclusions, fn {other_matcher, _reason, _citations} ->
          call_name_exclusion_match?(other_matcher, mfa)
        end) or
        Enum.any?(Enum.reject(@boundary_exclusions, &(&1 == Enum.at(@boundary_exclusions, 1))), fn
          {other_matcher, _reason, _citations} -> boundary_match?(other_matcher, mfa)
        end)
    end)
  end

  defp cn002_citations!(lane) when lane in ["core", "floor"] do
    [
      {"phoenix/lib/phoenix/digester.ex:16", "Digests and compresses the static files"},
      {"phoenix/lib/phoenix/digester.ex:20",
       "def compile(input_path, output_path, with_vsn?) do"},
      {"phoenix/lib/phoenix/digester.ex:21", "if File.exists?(input_path) do"},
      {"phoenix/lib/phoenix/digester.ex:93", "Phoenix.json_library().decode!()"},
      {"phoenix/lib/phoenix/digester.ex:195",
       "Application.fetch_env!(:phoenix, :static_compressors)"},
      {"phoenix/lib/phoenix/digester.ex:201",
       "compressor.compress_file(file.digested_filename, file.digested_content)"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:58", "def run(all_args) do"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:60", "if \"--no-compile\" not in all_args do"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:61", "Mix.Task.run(\"compile\", all_args)"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:68", "OptionParser.parse(all_args"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:69",
       "input_path = List.first(args) || @default_input_path"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:70", "output_path = opts[:output] || input_path"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:71",
       "with_vsn? = Keyword.merge(@default_opts, opts)[:vsn]"},
      {"phoenix/lib/mix/tasks/phx.digest.ex:73",
       "Phoenix.Digester.compile(input_path, output_path, with_vsn?)"}
    ]
  end

  defp calibration_citations!(id, lane) do
    Map.fetch!(calibration_citation_map!(), lane)
    |> Map.fetch!(id)
  end

  defp calibration_citation_map! do
    %{
      "core" => %{
        "CN-005" => [
          {"elixir/lib/regex.ex:219", "def compile(source, opts"},
          {"elixir/lib/regex.ex:223", "defp do_compile(source, opts) when is_binary(opts)"},
          {"elixir/lib/regex.ex:233", "defp do_compile(source, opts) when is_list(opts)"},
          {"elixir/lib/regex.ex:234", "case :re.compile(source, opts) do"},
          {"elixir/lib/regex.ex:1040", "[:unicode, :ucp | acc]"},
          {"elixir/lib/regex.ex:1063", "{:error, t}"},
          {"stdlib/src/re.erl:128", "compile(_) ->"},
          {"stdlib/src/re.erl:288", "compile(_, _) ->"}
        ],
        "BD-002" => [
          {"kernel/src/code.erl:967", "compiler_dir() -> call({dir,compiler_dir})."},
          {"kernel/src/code.erl:1860", "get_doc(Mod) when is_atom(Mod) ->"},
          {"kernel/src/code.erl:778", "get_object_code(Mod) when is_atom(Mod) ->"},
          {"kernel/src/code.erl:885", "lib_dir() -> call({dir,lib_dir})."},
          {"kernel/src/code.erl:927", "lib_dir(App) when is_atom(App)"},
          {"kernel/src/code.erl:959", "lib_dir(App, SubDir) when is_atom(App)"},
          {"kernel/src/code.erl:980", "priv_dir(App) when is_atom(App)"},
          {"kernel/src/code.erl:871", "root_dir() -> call({dir,root_dir})."},
          {"kernel/src/code.erl:1807", "where_is_file(File) when is_list(File)"},
          {"kernel/src/code.erl:1782", "which(Module) when is_atom(Module)"},
          {"kernel/src/code.erl:1791", "which(Module, Path) when is_atom(Module)"},
          {"kernel/src/code.erl:1664", "call(Req) ->"},
          {"kernel/src/code.erl:1903", "binary_to_term(Bin)"},
          {"kernel/src/code.erl:1916", "binary_to_term(Bin)"}
        ]
      },
      "floor" => %{
        "CN-005" => [
          {"elixir/lib/regex.ex:223", "def compile(source, opts"},
          {"elixir/lib/regex.ex:227", "defp compile(source, opts, version) when is_binary(opts)"},
          {"elixir/lib/regex.ex:237", "defp compile(source, opts, version) when is_list(opts)"},
          {"elixir/lib/regex.ex:238", "case :re.compile(source, opts) do"},
          {"elixir/lib/regex.ex:901", "[:unicode, :ucp | acc]"},
          {"elixir/lib/regex.ex:914", "{:error, t}"},
          {"stdlib/src/re.erl:86", "compile(_) ->"},
          {"stdlib/src/re.erl:236", "compile(_, _) ->"}
        ],
        "BD-002" => [
          {"kernel/src/code.erl:937", "compiler_dir() -> call({dir,compiler_dir})."},
          {"kernel/src/code.erl:1830", "get_doc(Mod) when is_atom(Mod) ->"},
          {"kernel/src/code.erl:748", "get_object_code(Mod) when is_atom(Mod) ->"},
          {"kernel/src/code.erl:855", "lib_dir() -> call({dir,lib_dir})."},
          {"kernel/src/code.erl:897", "lib_dir(App) when is_atom(App)"},
          {"kernel/src/code.erl:929", "lib_dir(App, SubDir) when is_atom(App)"},
          {"kernel/src/code.erl:950", "priv_dir(App) when is_atom(App)"},
          {"kernel/src/code.erl:841", "root_dir() -> call({dir,root_dir})."},
          {"kernel/src/code.erl:1776", "where_is_file(File) when is_list(File)"},
          {"kernel/src/code.erl:1752", "which(Module) when is_atom(Module)"},
          {"kernel/src/code.erl:1760", "which(Module, Path) when is_atom(Module)"},
          {"kernel/src/code.erl:1634", "call(Req) ->"},
          {"kernel/src/code.erl:1866", "binary_to_term(Bin)"},
          {"kernel/src/code.erl:1879", "binary_to_term(Bin)"}
        ]
      }
    }
  end

  defp calibration_input_trace!("CN-005"),
    do:
      "Caller pattern bytes and fixed/default or explicit option terms reach Regex.compile; modifier bytes map only to fixed option atoms and invalid bytes return an error."

  defp calibration_input_trace!("BD-002"),
    do:
      "Caller supplies module/app/name queries to :code getters; get_doc/1 selects the existing module's code-path artifact, not caller-provided bytes."

  defp calibration_trace!("CN-005"),
    do: ["Regex.compile/1,2", "Regex option translator", ":re.compile/1,2 (regex NIF)"]

  defp calibration_trace!("BD-002"),
    do: [
      ":code getter MFA",
      "code_server:call/1 with a getter-shaped request",
      "get_doc/1 -> which/1 -> beam_lib:chunks or file:read_file -> binary_to_term/1"
    ]

  defp calibration_verdict!("CN-005"),
    do: "Regex pattern compilation only; no source evaluation or caller-derived atom conversion."

  defp calibration_verdict!("BD-002"),
    do:
      "Code-path and application metadata queries. get_doc/1 decodes installed BEAM documentation and is safe only under the recorded trusted-artifact boundary."

  defp calibration_limitations!("CN-005"), do: []

  defp calibration_limitations!("BD-002"),
    do: [
      "get_doc/1 reaches binary_to_term/1 on Docs or doc/chunks bytes; this review does not claim safety for attacker-writable BEAM/code-path artifacts.",
      "The approved source archive does not contain kernel/src/code_server.erl; code_server:call/1 handlers are not independently source-reviewed here."
    ]
end

defmodule Fablebook.Test.InstalledOtpReceiptTest do
  use ExUnit.Case, async: false
  alias Fablebook.Test.{BeamWalker, DebuggerPendingOwnership, InstalledOtp, SweepEvidence}

  @moduletag :inventory_support
  @marker "FABLEBOOK_OTP_INVENTORY_V2 "
  @probe_app_atoms %{"probe" => :probe, "probe_one" => :probe_one, "probe_two" => :probe_two}

  test "pending debugger ownership controls pin modules and owner assignments" do
    owners = DebuggerPendingOwnership.owners()

    assert :ok = DebuggerPendingOwnership.assert_valid!(owners)

    assert_raise ExUnit.AssertionError,
                 ~r/dbg_ieval expected=01\.1\.1\.3\.1\.2 actual=<missing>/,
                 fn ->
                   DebuggerPendingOwnership.assert_valid!(Map.delete(owners, :dbg_ieval))
                 end

    assert_raise ExUnit.AssertionError,
                 ~r/dbg_ieval expected=01\.1\.1\.3\.1\.2 actual=01\.1\.1\.3\.1\.1/,
                 fn ->
                   DebuggerPendingOwnership.assert_valid!(
                     Map.put(owners, :dbg_ieval, "01.1.1.3.1.1")
                   )
                 end
  end

  test "concurrent source evidence extraction uses isolated roots" do
    tasks = for _ <- 1..2, do: Task.async(fn -> SweepEvidence.source_roots!() end)
    evidences = Task.await_many(tasks, 30_000)
    roots = Enum.map(evidences, & &1.archive_root)
    on_exit(fn -> Enum.each(roots, &File.rm_rf!/1) end)

    assert MapSet.size(MapSet.new(roots)) == 2

    for {root, index} <- Enum.with_index(roots) do
      marker = "concurrent-probe-#{index}"
      path = Path.join(root, marker)
      File.write!(path, Integer.to_string(index))
      assert File.read!(path) == Integer.to_string(index)

      for other_root <- List.delete(roots, root) do
        refute File.exists?(Path.join(other_root, marker))
      end
    end
  end

  test "extracts a receipt from CI lines with job and timestamp prefixes" do
    lines = receipt_lines("core")
    dir = Path.join(System.tmp_dir!(), "fablebook-receipt-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)

    log_path = Path.join(dir, "core.log")
    receipt_path = Path.join(dir, "core.jsonl")
    prefix = "core\tUNKNOWN STEP\t2026-10-30T18:56:49.0917397Z "
    File.write!(log_path, Enum.map_join(lines, "\n", &(prefix <> &1)) <> "\n")

    assert InstalledOtp.extract_receipt!(log_path, receipt_path) == receipt_path
    assert File.read!(receipt_path) == Enum.join(lines, "\n") <> "\n"
    assert InstalledOtp.verify_receipt_lines!(lines).lane == "core"
  end

  @tag :audit_readiness
  test "Xref query parity rejects successful empty and truncated results" do
    expected = [{:probe, :run, 0}, {:probe, :stop, 1}]

    assert InstalledOtp.assert_xref_query!(fn -> {:ok, expected} end, :exports, "core", expected) ==
             expected

    assert_raise InstalledOtp.Error, ~r/xref_query_parity/, fn ->
      InstalledOtp.assert_xref_query!(fn -> {:ok, []} end, :exports, "core", expected)
    end

    assert_raise InstalledOtp.Error, ~r/xref_query_parity/, fn ->
      InstalledOtp.assert_xref_query!(
        fn -> {:ok, Enum.take(expected, 1)} end,
        :exports,
        "core",
        expected
      )
    end
  end

  test "Xref edge query parity normalizes callee arity without losing caller MFA" do
    caller = {:probe, :caller, 2}
    expected = [{caller, {:sink, :run}}]
    returned = [{caller, {:sink, :run, 0}}, {caller, {:sink, :run, 1}}]

    normalize = fn
      {from, {module, function, _arity}} -> {from, {module, function}}
      row -> row
    end

    assert InstalledOtp.assert_xref_query!(
             fn -> {:ok, returned} end,
             :edges,
             "core",
             expected,
             normalize
           ) == returned

    assert_raise InstalledOtp.Error, ~r/xref_query_parity/, fn ->
      InstalledOtp.assert_xref_query!(
        fn -> {:ok, [hd(returned), hd(returned)]} end,
        :edges,
        "core",
        expected,
        normalize
      )
    end
  end

  test "independent beam AST inventory follows local, remote, operator, and dynamic calls" do
    anno = 1

    forms = [
      {:attribute, anno, :module, :probe},
      {:function, anno, :local, 0, [{:clause, anno, [], [], [{:atom, anno, :ok}]}]},
      {:function, anno, :caller, 0,
       [
         {:clause, anno, [], [],
          [
            {:call, anno, {:atom, anno, :local}, []},
            {:call, anno, {:remote, anno, {:atom, anno, :sink}, {:atom, anno, :run}},
             [{:atom, anno, :x}]},
            {:op, anno, :+, {:integer, anno, 1}, {:integer, anno, 2}},
            {:call, anno, {:remote, anno, {:atom, anno, :erlang}, {:atom, anno, :is_list}},
             [{nil, anno}]},
            {:call, anno, {:remote, anno, {:var, anno, :module}, {:atom, anno, :run}},
             [{:atom, anno, :x}]},
            {:call, anno, {:var, anno, :function}, [{:atom, anno, :x}]}
          ]}
       ]}
    ]

    caller = {:probe, :caller, 0}

    assert BeamWalker.xref_edges(:probe, forms) ==
             Enum.sort([
               {caller, {:probe, :local, 0}},
               {caller, {:sink, :run, 1}},
               {caller, {:erlang, :+, 2}},
               {caller, {:"$M_EXPR", :run, 1}},
               {caller, {:"$M_EXPR", :"$F_EXPR", 1}}
             ])
  end

  test "receipts reject missing measurement records even when identity rows are intact" do
    lines =
      receipt_lines("core")
      |> Enum.reject(fn line ->
        case JSON.decode(String.replace_prefix(line, @marker, "")) do
          {:ok, %{"kind" => "metrics"}} -> true
          _ -> false
        end
      end)

    body = Enum.drop(lines, -1)
    {:ok, footer} = JSON.decode(String.replace_prefix(List.last(lines), @marker, ""))
    digest = :crypto.hash(:sha256, Enum.join(body, "\n") <> "\n") |> Base.encode16(case: :lower)
    footer_line = @marker <> JSON.encode!(Map.put(footer, "sha256", digest))

    assert_raise InstalledOtp.Error, ~r/receipt_metrics/, fn ->
      InstalledOtp.verify_receipt_lines!(body ++ [footer_line])
    end
  end

  test "receipts reject wrong lanes, duplicate or missing identities, and inconsistent totals" do
    lines = receipt_lines("core")

    wrong_lane =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "meta"} = row -> Map.put(row, "lane", "nearby")
          row -> row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_lane/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_lane)
    end

    duplicate_beam =
      rewrite_receipt(lines, fn rows ->
        beam = Enum.find(rows, &(&1["kind"] == "beam"))
        rows ++ [beam]
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_beam_records/, fn ->
      InstalledOtp.verify_receipt_lines!(duplicate_beam)
    end

    missing_beam =
      rewrite_receipt(lines, fn rows -> Enum.reject(rows, &(&1["kind"] == "beam")) end)

    assert_raise InstalledOtp.Error, ~r/receipt_empty_inventory/, fn ->
      InstalledOtp.verify_receipt_lines!(missing_beam)
    end

    wrong_total =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "metrics"} = row ->
            Map.put(row, "function_bytes", row["function_bytes"] + 1)

          row ->
            row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_metrics/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_total)
    end

    wrong_membership_link =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "active_module"} = row -> Map.put(row, "module", "missing_probe")
          row -> row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_links/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_membership_link)
    end

    wrong_caller_chain =
      rewrite_receipt(lines, fn rows ->
        Enum.map(rows, fn
          %{"kind" => "pending_mfa"} = row -> Map.put(row, "caller_chain", ["probe.run"])
          row -> row
        end)
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_membership_records/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_caller_chain)
    end

    wrong_source_link =
      rewrite_receipt(lines, fn rows ->
        rows =
          Enum.map(rows, fn
            %{"kind" => "app", "app" => "probe"} = row ->
              %{
                row
                | "source_dir_status" => "present",
                  "source_file_count" => 1,
                  "source_bytes" => 1
              }

            %{"kind" => "beam", "app" => "probe"} = row ->
              %{
                row
                | "source" => "src/probe.erl",
                  "source_status" => "present",
                  "source_bytes" => 1
              }

            %{"kind" => "source_app", "app" => "probe"} = row ->
              %{
                row
                | "source_dir_status" => "present",
                  "source_file_count" => 1,
                  "source_bytes" => 1,
                  "mapped_beams" => 1,
                  "unavailable_source_beams" => 0
              }

            %{"kind" => "metrics"} = row ->
              %{
                row
                | "source_file_count" => 1,
                  "source_bytes" => 1,
                  "mapped_beams" => 1,
                  "unavailable_source_beams" => 0
              }

            row ->
              row
          end)

        rows ++
          [%{"kind" => "source_file", "app" => "probe", "path" => "src/other.erl", "bytes" => 1}]
      end)

    assert_raise InstalledOtp.Error, ~r/receipt_links/, fn ->
      InstalledOtp.verify_receipt_lines!(wrong_source_link)
    end

    assert_raise InstalledOtp.Error, ~r/receipt_json/, fn ->
      InstalledOtp.verify_receipt_lines!([@marker <> "{"])
    end
  end

  test "source inventory maps every readable installed source file to a BEAM and counts bytes" do
    dir = temp_dir!()
    root = Path.join(dir, "lib")
    app_root = Path.join(root, "probe-1.0.0")
    ebin = Path.join(app_root, "ebin")
    src = Path.join(app_root, "src")
    File.mkdir_p!(ebin)
    File.mkdir_p!(src)
    source = Path.join(src, "probe.erl")

    source_text =
      "-module(probe).\n-export([run/0, behaviour_info/1]).\n" <>
        "behaviour_info(callbacks) -> [].\nrun() -> ok.\n"

    File.write!(source, source_text)
    File.write!(Path.join(ebin, "probe.app"), app_resource(:probe, "1.0.0", [:probe]))

    :ok =
      File.cd!(app_root, fn ->
        {:ok, :probe} =
          :compile.file(~c"src/probe.erl", [:debug_info, {:outdir, String.to_charlist(ebin)}])

        :ok
      end)

    discovered = InstalledOtp.discover!(root, lane: "core")
    assert InstalledOtp.assert_discovery_complete!(root, discovered, lane: "core") == :ok
    inspected = InstalledOtp.inspect!(discovered, lane: "core")
    exports = InstalledOtp.export_inventory!([ebin], lane: "core")

    assert {:probe, :run, 0} in exports
    refute {:probe, :module_info, 0} in exports
    refute {:probe, :module_info, 1} in exports
    assert {:probe, :behaviour_info, 1} in exports

    used_predefined_exports =
      InstalledOtp.export_inventory!([ebin],
        lane: "core",
        edges: [{{:consumer, :run, 0}, {:probe, :module_info, 0}}]
      )

    assert {:probe, :module_info, 0} in used_predefined_exports
    refute {:probe, :module_info, 1} in used_predefined_exports

    [source_app] =
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: "core",
        required_modules: [:probe]
      )

    assert source_app.source_dir_status == "present"
    assert source_app.source_file_count == 1
    assert source_app.source_bytes == byte_size(source_text)
    assert source_app.mapped_beams == 1

    assert source_app.beams == [
             %{
               module: "probe",
               source: "src/probe.erl",
               status: "present",
               bytes: byte_size(source_text)
             }
           ]
  end

  test "source inventory and receipts include contained generated sources outside src" do
    root = temp_dir!() |> Path.join("lib")
    %{ebin: ebin} = create_probe_app!(root, "probe", "1.0.0", :probe, true)
    generated_source = "-module(probe).\n"
    File.write!(Path.join(ebin, "generated_probe.erl"), generated_source)

    discovered = InstalledOtp.discover!(root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")
    inspected = [%{hd(inspected) | source: "src/../ebin/generated_probe.erl"}]

    [source_app] = InstalledOtp.source_inventory!(discovered, inspected, lane: "core")

    assert source_app.source_dir_status == "missing"
    assert source_app.source_file_count == 1
    assert source_app.source_bytes == byte_size(generated_source)
    assert source_app.mapped_beams == 1

    assert source_app.beams == [
             %{
               module: "probe",
               source: "ebin/generated_probe.erl",
               status: "present",
               bytes: byte_size(generated_source)
             }
           ]

    receipt_lines =
      InstalledOtp.receipt_lines(%{
        lane: %{name: "core", elixir: "1.20.4", otp: "29.1.2"},
        lock_sha256: SweepEvidence.lock_digests!()["core"],
        discovered: discovered,
        inspected: inspected,
        ingested: [%{app: "probe", module: "probe", module_atom: :probe}],
        sources: [source_app]
      })

    receipt = InstalledOtp.verify_receipt_lines!(receipt_lines)
    beam = Enum.find(receipt.beams, &(&1["module"] == "probe"))

    assert beam["source"] == "ebin/generated_probe.erl"
    assert beam["source_status"] == "present"

    assert Enum.any?(receipt_lines, fn line ->
             {:ok, row} = JSON.decode(String.replace_prefix(line, @marker, ""))
             row["kind"] == "source_file" and row["path"] == "ebin/generated_probe.erl"
           end)
  end

  @tag :audit_readiness
  test "source inventory fails on unreadable files and required active source gaps" do
    root = temp_dir!() |> Path.join("lib")
    app_root = Path.join(root, "probe-1.0.0")
    ebin = Path.join(app_root, "ebin")
    File.mkdir_p!(ebin)
    File.write!(Path.join(ebin, "probe.app"), app_resource(:probe, "1.0.0", [:probe]))
    write_probe_beam!(ebin, :probe, debug_info: true)
    discovered = InstalledOtp.discover!(root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")

    assert_raise InstalledOtp.Error, ~r/required_source_missing/, fn ->
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: "core",
        required_modules: [:probe]
      )
    end

    source_root = Path.join(app_root, "src")
    File.mkdir_p!(source_root)
    File.write!(Path.join(source_root, "probe.erl"), "source")
    inspected = [%{hd(inspected) | source: "src/probe.erl"}]

    assert_raise InstalledOtp.Error, ~r/source_file_unreadable/, fn ->
      InstalledOtp.source_inventory!(discovered, inspected,
        lane: "core",
        required_modules: [:probe],
        source_reader: fn _path -> {:error, :eacces} end
      )
    end

    escaped = [%{hd(inspected) | source: "../../outside.erl"}]

    assert_raise InstalledOtp.Error, ~r/source_escape/, fn ->
      InstalledOtp.source_inventory!(discovered, escaped, lane: "core")
    end

    outside = Path.join(Path.dirname(app_root), "outside.erl")
    File.write!(outside, "outside")
    source_path = Path.join(source_root, "probe.erl")
    File.rm!(source_path)
    File.ln_s!(outside, source_path)

    assert_raise InstalledOtp.Error, ~r/source_escape/, fn ->
      InstalledOtp.source_inventory!(discovered, inspected, lane: "core")
    end
  end

  @tag :audit_readiness
  test "parity rejects omission of a discovered app or BEAM during inspection and Xref intake" do
    root = temp_dir!() |> Path.join("lib")
    app_one = create_probe_app!(root, "probe_one", "1.0.0", :probe_one, true)
    app_two = create_probe_app!(root, "probe_two", "1.0.0", :probe_two, true)
    discovered = InstalledOtp.discover!(root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")

    assert_raise InstalledOtp.Error, ~r/discovery_parity/, fn ->
      InstalledOtp.assert_discovery_complete!(
        root,
        Enum.reject(discovered, &(&1.app == app_two.app)),
        lane: "core"
      )
    end

    app_one_discovered = Enum.find(discovered, &(&1.app == app_one.app))

    omitted_app_beams = [
      %{app_one_discovered | beams: []} | Enum.reject(discovered, &(&1.app == app_one.app))
    ]

    assert_raise InstalledOtp.Error, ~r/discovery_parity/, fn ->
      InstalledOtp.assert_discovery_complete!(root, omitted_app_beams, lane: "core")
    end

    incomplete_inspection = Enum.reject(inspected, &(&1.app == app_two.app))
    complete_ingestion = Enum.map(inspected, &%{app: &1.app, module: &1.module})

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, incomplete_inspection, complete_ingestion, "core")
    end

    app_one_inspected = Enum.filter(inspected, &(&1.app == app_one.app))
    incomplete_ingestion = Enum.map(app_one_inspected, &%{app: &1.app, module: &1.module})

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, inspected, incomplete_ingestion, "core")
    end

    discovered_one = Enum.find(discovered, &(&1.app == app_one.app))
    [first_beam | _] = discovered_one.beams

    omitted_beam_inspection =
      Enum.reject(inspected, &(&1.app == app_one.app and &1.module == first_beam.module))

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, omitted_beam_inspection, complete_ingestion, "core")
    end
  end

  @tag :audit_readiness
  test "discovery and ingestion reject duplicate, unreadable, corrupt, missing-debug, and incomplete identities" do
    root = temp_dir!() |> Path.join("lib")
    create_probe_app!(root, "probe_one", "1.0.0", :same_probe, true)
    create_probe_app!(root, "probe_two", "1.0.0", :same_probe, true)

    assert_raise InstalledOtp.Error, ~r/duplicate_module/, fn ->
      InstalledOtp.discover!(root, lane: "core")
    end

    clean_root = temp_dir!() |> Path.join("lib")
    app = create_probe_app!(clean_root, "probe", "1.0.0", :probe, true)
    [discovered] = InstalledOtp.discover!(clean_root, lane: "core")
    beam = hd(discovered.beams)

    assert_raise InstalledOtp.Error, ~r/beam_identity/, fn ->
      InstalledOtp.discover!(clean_root,
        lane: "core",
        beam_chunks: fn _path, _chunks -> {:error, :beam_lib, :eacces} end
      )
    end

    File.write!(beam.path, "not a beam")

    assert_raise InstalledOtp.Error, ~r/beam_identity/, fn ->
      InstalledOtp.discover!(clean_root, lane: "core")
    end

    write_probe_beam!(app.ebin, :probe, debug_info: false)
    discovered = InstalledOtp.discover!(clean_root, lane: "core")

    assert_raise InstalledOtp.Error, ~r/inspection_failed/, fn ->
      InstalledOtp.inspect!(discovered, lane: "core")
    end

    write_probe_beam!(app.ebin, :probe, debug_info: true)
    discovered = InstalledOtp.discover!(clean_root, lane: "core")
    inspected = InstalledOtp.inspect!(discovered, lane: "core")
    app = hd(discovered)

    assert_raise InstalledOtp.Error, ~r/xref_ingest/, fn ->
      InstalledOtp.add_directory!(:ignored, app,
        lane: "core",
        add_directory: fn _xref, _path -> {:error, :injected_failure} end
      )
    end

    incomplete =
      InstalledOtp.add_directory!(:ignored, app,
        lane: "core",
        add_directory: fn _xref, _path -> {:ok, []} end
      )

    assert_raise InstalledOtp.Error, ~r/identity_parity/, fn ->
      InstalledOtp.assert_parity!(discovered, inspected, incomplete, "core")
    end
  end

  defp receipt_lines(lane) do
    {elixir, otp} =
      case lane do
        "core" -> {"1.20.4", "29.1.2"}
        "floor" -> {"1.18.5", "27.3.4.9"}
      end

    rows = [
      %{
        "kind" => "meta",
        "schema" => "fablebook.otp-inventory.v2",
        "lane" => lane,
        "elixir" => elixir,
        "otp" => otp,
        "lock_sha256" => SweepEvidence.lock_digests!()[lane]
      },
      %{
        "kind" => "app",
        "app" => "probe",
        "version" => "1.0.0",
        "path" => "probe-1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0
      },
      %{
        "kind" => "beam",
        "app" => "probe",
        "version" => "1.0.0",
        "module" => "probe",
        "path" => "probe-1.0.0/ebin/probe.beam",
        "inspection" => "ok",
        "xref" => "ok",
        "function_count" => 1,
        "function_bytes" => 1,
        "beam_bytes" => 1,
        "source" => nil,
        "source_status" => "unavailable",
        "source_bytes" => nil
      },
      %{
        "kind" => "app",
        "app" => "pending_probe",
        "version" => "1.0.0",
        "path" => "pending_probe-1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0
      },
      %{
        "kind" => "beam",
        "app" => "pending_probe",
        "version" => "1.0.0",
        "module" => "pending_probe",
        "path" => "pending_probe-1.0.0/ebin/pending_probe.beam",
        "inspection" => "ok",
        "xref" => "ok",
        "function_count" => 1,
        "function_bytes" => 1,
        "beam_bytes" => 1,
        "source" => "src/pending_probe.erl",
        "source_status" => "missing",
        "source_bytes" => nil
      },
      %{
        "kind" => "source_app",
        "app" => "probe",
        "version" => "1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0,
        "mapped_beams" => 0,
        "missing_source_beams" => 0,
        "unavailable_source_beams" => 1
      },
      %{
        "kind" => "source_app",
        "app" => "pending_probe",
        "version" => "1.0.0",
        "source_dir_status" => "missing",
        "source_file_count" => 0,
        "source_bytes" => 0,
        "mapped_beams" => 0,
        "missing_source_beams" => 1,
        "unavailable_source_beams" => 0
      },
      %{"kind" => "active_app", "app" => "probe"},
      %{"kind" => "active_module", "app" => "probe", "module" => "probe"},
      %{
        "kind" => "active_export",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0
      },
      %{
        "kind" => "active_edge",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0,
        "callee_app" => "pending_probe",
        "callee_module" => "pending_probe",
        "callee_function" => "run"
      },
      %{
        "kind" => "export",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0
      },
      %{
        "kind" => "reached",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0
      },
      %{
        "kind" => "boundary",
        "app" => "probe",
        "module" => "probe",
        "function" => "run",
        "arity" => 0,
        "explicit_boundary_exclusion" => true
      },
      %{"kind" => "pending_app", "app" => "pending_probe", "owner" => "01.1.1.3"},
      %{
        "kind" => "pending_module",
        "app" => "pending_probe",
        "module" => "pending_probe",
        "function_count" => 1,
        "function_bytes" => 1,
        "source_status" => "missing",
        "source" => "src/pending_probe.erl",
        "source_bytes" => nil,
        "owner" => "01.1.1.3"
      },
      %{
        "kind" => "pending_mfa",
        "app" => "pending_probe",
        "module" => "pending_probe",
        "function" => "run",
        "arity" => 0,
        "caller_chain" => ["probe.run/0"],
        "owner" => "01.1.1.3"
      },
      %{
        "kind" => "metrics",
        "app_count" => 2,
        "beam_count" => 2,
        "function_count" => 2,
        "function_bytes" => 2,
        "beam_bytes" => 2,
        "source_file_count" => 0,
        "source_bytes" => 0,
        "mapped_beams" => 0,
        "missing_source_beams" => 1,
        "unavailable_source_beams" => 1,
        "exported_matches" => 1,
        "reached_matches" => 1,
        "boundary_matches" => 1,
        "active_app_count" => 1,
        "active_module_count" => 1,
        "active_export_count" => 1,
        "active_edge_count" => 1,
        "pending_app_count" => 1,
        "pending_module_count" => 1,
        "pending_mfa_count" => 1,
        "discovery_ms" => 0,
        "inspection_ms" => 0,
        "source_scan_ms" => 0,
        "xref_ms" => 0,
        "graph_ms" => 0,
        "pending_owner" => "01.1.1.3"
      }
    ]

    body = Enum.map(rows, &(@marker <> JSON.encode!(&1)))
    digest = :crypto.hash(:sha256, Enum.join(body, "\n") <> "\n") |> Base.encode16(case: :lower)

    footer =
      @marker <>
        JSON.encode!(%{
          "kind" => "footer",
          "apps" => 2,
          "beams" => 2,
          "source_files" => 0,
          "active_records" => 4,
          "export_records" => 1,
          "reached_records" => 1,
          "boundary_records" => 1,
          "pending_records" => 3,
          "sha256" => digest
        })

    body ++ [footer]
  end

  defp rewrite_receipt(lines, transform) do
    body =
      lines
      |> Enum.drop(-1)
      |> Enum.map(fn line ->
        {:ok, row} = JSON.decode(String.replace_prefix(line, @marker, ""))
        row
      end)
      |> transform.()

    encoded = Enum.map(body, &(@marker <> JSON.encode!(&1)))
    counts = Enum.frequencies_by(body, & &1["kind"])

    footer = %{
      "kind" => "footer",
      "apps" => counts["app"] || 0,
      "beams" => counts["beam"] || 0,
      "source_files" => counts["source_file"] || 0,
      "active_records" =>
        Enum.sum(
          Enum.map(~w(active_app active_module active_export active_edge), &(counts[&1] || 0))
        ),
      "export_records" => counts["export"] || 0,
      "reached_records" => counts["reached"] || 0,
      "boundary_records" => counts["boundary"] || 0,
      "pending_records" =>
        Enum.sum(Enum.map(~w(pending_app pending_module pending_mfa), &(counts[&1] || 0))),
      "sha256" =>
        :crypto.hash(:sha256, Enum.join(encoded, "\n") <> "\n") |> Base.encode16(case: :lower)
    }

    encoded ++ [@marker <> JSON.encode!(footer)]
  end

  defp temp_dir! do
    dir =
      Path.join(System.tmp_dir!(), "fablebook-inventory-#{System.unique_integer([:positive])}")

    File.mkdir_p!(dir)
    on_exit(fn -> File.rm_rf!(dir) end)
    dir
  end

  defp create_probe_app!(root, app, version, module, debug_info?) do
    app_root = Path.join(root, "#{app}-#{version}")
    ebin = Path.join(app_root, "ebin")
    File.mkdir_p!(ebin)

    File.write!(
      Path.join(ebin, "#{app}.app"),
      app_resource(Map.fetch!(@probe_app_atoms, app), version, [module])
    )

    write_probe_beam!(ebin, module, debug_info: debug_info?)
    %{app: app, root: app_root, ebin: ebin}
  end

  defp write_probe_beam!(ebin, module, opts) do
    forms = [
      {:attribute, 1, :module, module},
      {:attribute, 1, :export, [probe: 0]},
      {:function, 1, :probe, 0, [{:clause, 1, [], [], [{:atom, 1, :ok}]}]}
    ]

    compile_opts = if Keyword.get(opts, :debug_info), do: [:debug_info], else: []
    {:ok, ^module, beam} = :compile.forms(forms, compile_opts)
    File.write!(Path.join(ebin, "#{Atom.to_string(module)}.beam"), beam)
  end

  defp app_resource(app, version, modules) do
    resource = {:application, app, [{:vsn, String.to_charlist(version)}, {:modules, modules}]}
    :io_lib.format("~tp.~n", [resource])
  end
end
