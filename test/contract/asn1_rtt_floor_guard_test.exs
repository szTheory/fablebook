defmodule Fablebook.Asn1RttFloorGuardTest do
  use ExUnit.Case, async: false

  @moduletag :floor

  alias Fablebook.Test.Asn1RttFloorEvidence
  alias Fablebook.Test.SweepEvidence

  test "assert_defined/1 evidence resolves its complete floor target and caller span" do
    evidence = Asn1RttFloorEvidence.record()
    assert evidence.lane == "floor"
    assert evidence.method == :source_only
    assert Asn1RttFloorEvidence.selected_mfas() == [
             {:asn1ct_rtt, :assert_defined, 1},
             {:asn1ct_rtt, :code, 0},
             {:asn1ct_rtt, :dependencies, 1}
           ]

    source = SweepEvidence.source_roots!()
    target = Asn1RttFloorEvidence.evidence_for(evidence, {:asn1ct_rtt, :assert_defined, 1})
    assert target.target_span == 17..120
    assert {:asn1ct_rtt, :assert_defined, 1} == target.mfa

    assert_source_line!(source, "asn1/src/asn1ct_rtt.erl:17", "assert_defined({ber,ber_decode_erlang,1}) -> ok;")
    assert_source_line!(source, "asn1/src/asn1ct_rtt.erl:120", "assert_defined({uper,skipextensions,3}) -> ok.")

    Enum.each(target.caller_path, fn {citation, expected} ->
      assert_source_line!(source, citation, expected)
    end)
  end

  test "assert_defined/1 control is specific to its selected MFA" do
    mfa = {:asn1ct_rtt, :assert_defined, 1}
    record = Asn1RttFloorEvidence.record()

    assert %{mfa: ^mfa, target_span: 17..120} =
             Asn1RttFloorEvidence.evidence_for(record, mfa)
    refute Asn1RttFloorEvidence.evidence_for(record, {:asn1ct_rtt, :assert_defined, 2})
    refute Asn1RttFloorEvidence.evidence_for(record, {:asn1ct_rtt, :assert_defined, 2})

    without_control =
      Map.update!(record, :selected_function_evidence, &Enum.reject(&1, fn row -> row.mfa == mfa end))

    refute Asn1RttFloorEvidence.evidence_for(without_control, mfa)
  end

  test "code/0 has complete floor evidence and an anchored byte-only table contract" do
    evidence = Asn1RttFloorEvidence.record()
    source = SweepEvidence.source_roots!()
    target = Asn1RttFloorEvidence.evidence_for(evidence, {:asn1ct_rtt, :code, 0})
    assert target.target_span == 533..1038

    assert_source_line!(source, "asn1/src/asn1ct_rtt.erl:533", "code() ->")
    last_line = SweepEvidence.resolve!(source, "asn1/src/asn1ct_rtt.erl:1038").text
    assert String.starts_with?(last_line, "  <<")
    assert String.ends_with?(last_line, ">>}].")

    Enum.each(target.caller_path, fn {citation, expected} ->
      assert_source_line!(source, citation, expected)
    end)

    bytes = File.read!(SweepEvidence.resolve!(source, "asn1/src/asn1ct_rtt.erl:533").path)
    body = rtt_body!(bytes, 533, 1038)
    table = evidence.rtt_literal_body
    assert byte_size(body) == table.bytes
    assert digest(body) == table.sha256
    assert table.row_count == 250

    grammar = code_table_grammar!()
    assert Regex.match?(grammar, body)
    row_pattern =
      Regex.compile!(
        "^[\\t ]*\\{\\{[a-z][A-Za-z0-9_]*,[a-z][A-Za-z0-9_]*,\\d+\\},[\\t ]*$",
        "m"
      )
    assert length(Regex.scan(row_pattern, body)) == table.row_count

    refute Regex.match?(grammar, String.replace(body, ~S/<<"/, "<<integer_to_binary(1)>>", global: false))
    refute Regex.match?(grammar, body <> " erlang:halt().")
    refute Regex.match?(grammar, binary_part(body, 0, byte_size(body) - 2))
    refute Regex.match?(grammar, String.replace(body, "{{ber,ber_encode,1}", "{{erlang,halt(),0}", global: false))
  end

  test "code/0 control is specific to its selected MFA" do
    assert_individual_control!({:asn1ct_rtt, :code, 0}, {:asn1ct_rtt, :code, 1})
  end

  test "dependencies/1 has complete floor evidence and its direct caller path" do
    evidence = Asn1RttFloorEvidence.record()
    source = SweepEvidence.source_roots!()
    target = Asn1RttFloorEvidence.evidence_for(evidence, {:asn1ct_rtt, :dependencies, 1})
    assert target.target_span == 122..531

    assert_source_line!(source, "asn1/src/asn1ct_rtt.erl:122", "dependencies({ber,ber_decode_erlang,1}) ->")
    assert_source_line!(source, "asn1/src/asn1ct_rtt.erl:531", "dependencies(_) -> [].")

    Enum.each(target.caller_path, fn {citation, expected} ->
      assert_source_line!(source, citation, expected)
    end)
  end

  test "dependencies/1 control is specific to its selected MFA" do
    assert_individual_control!({:asn1ct_rtt, :dependencies, 1}, {:asn1ct_rtt, :dependencies, 2})
  end

  test "floor archive identity and full assert_defined/1 citation fail closed when altered" do
    evidence = Asn1RttFloorEvidence.record()
    assert {
             "asn1/src/asn1ct_rtt.erl",
             134_820,
             "828cdca9f7ac0d4e6d867d712b0e991c94fa46665e17e360196aa39c89305d9d"
           } in evidence.exact_sources

    assert {
             "asn1/src/asn1ct_func.erl",
             4_347,
             "5487ba870e7c265cd7fe41761f1c5c528385d164faa07df15858fe48e2d21ebf"
           } in evidence.exact_sources

    source = SweepEvidence.source_roots!()
    assert_raise ExUnit.AssertionError, fn ->
      assert_source_line!(
        source,
        "asn1/src/asn1ct_rtt.erl:121",
        "assert_defined({uper,skipextensions,3}) -> ok."
      )
    end
  end

  defp assert_source_line!(source, citation, expected) do
    resolved = SweepEvidence.resolve!(source, citation)
    assert resolved.text == expected,
           "unexpected source at #{citation}: #{inspect(resolved.text)}"
  end

  defp assert_individual_control!(mfa, unrelated_mfa) do
    record = Asn1RttFloorEvidence.record()
    assert %{mfa: ^mfa, target_span: %Range{}} = Asn1RttFloorEvidence.evidence_for(record, mfa)
    refute Asn1RttFloorEvidence.evidence_for(record, unrelated_mfa)

    without_control =
      Map.update!(record, :selected_function_evidence, &Enum.reject(&1, fn row -> row.mfa == mfa end))

    refute Asn1RttFloorEvidence.evidence_for(without_control, mfa)
  end

  defp rtt_body!(bytes, start_line, end_line) do
    bytes
    |> String.split("\n", trim: false)
    |> Enum.slice(start_line - 1, end_line - start_line + 1)
    |> Enum.join("\n")
    |> Kernel.<>("\n")
  end

  defp code_table_entry_pattern do
    ~S/\{\{[a-z][A-Za-z0-9_]*,[a-z][A-Za-z0-9_]*,\d+\},\s*<<"(?:\\.|[^"\\])*">>\}/
  end

  defp code_table_grammar! do
    entry = code_table_entry_pattern()

    Regex.compile!(
      "\\Acode\\(\\) ->\\s*\\[\\s*" <>
        entry <> "(?:,\\s*" <> entry <> ")*\\s*\\]\\.\\s*\\z",
      "s"
    )
  end

  defp digest(bytes), do: :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
end
