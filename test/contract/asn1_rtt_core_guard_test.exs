defmodule Fablebook.Test.Asn1RttCoreGuardTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.Asn1RttCoreEvidence
  alias Fablebook.Test.SweepEvidence

  @archive Path.expand("../fixtures/guards/exact_sources.tar.gz", __DIR__)

  setup do
    archive = SweepEvidence.load_archive!(@archive, SweepEvidence.archive_sha256())
    on_exit(fn -> File.rm_rf!(archive.archive_root) end)

    {:ok,
     evidence:
       Map.merge(archive, %{
         lane: %{name: "core"},
         installed:
           Map.new(~w(asn1 stdlib), &{&1, Path.join(archive.archive_root, "missing-#{&1}")})
       })}
  end

  test "assert_defined/1 source and need/1 caller resolve to their complete pinned spans", %{
    evidence: evidence
  } do
    entry =
      Enum.find(Asn1RttCoreEvidence.entries(), &(&1.mfa == {:asn1ct_rtt, :assert_defined, 1}))

    assert entry.mfa == {:asn1ct_rtt, :assert_defined, 1}

    source = SweepEvidence.resolve!(evidence, entry.source.citation)
    assert entry.source.identity.lane == evidence.lane.name
    assert source.origin == :archive
    assert source.sha256 == entry.source.identity.sha256
    assert File.stat!(source.path).size == entry.source.identity.bytes

    source_span = span!(source.path, entry.source.first_line, entry.source.last_line)
    assert sha256(source_span) == entry.source.span_sha256

    caller_span = hd(entry.caller.spans)
    caller = SweepEvidence.resolve!(evidence, caller_span.citation)
    assert caller.origin == :archive
    assert caller.sha256 == entry.caller.identity.sha256
    assert File.stat!(caller.path).size == entry.caller.identity.bytes

    caller_text = span!(caller.path, caller_span.first_line, caller_span.last_line)
    assert sha256(caller_text) == caller_span.span_sha256
    assert Asn1RttCoreEvidence.guard_matches?(entry, caller_text)

    negative = SweepEvidence.resolve!(evidence, entry.control.negative_citation)
    refute Asn1RttCoreEvidence.guard_matches?(entry, negative.text)

    refute Asn1RttCoreEvidence.guard_matches?(
             entry,
             String.replace(caller_text, entry.control.guard, "", global: false)
           )
  end

  test "the three selected functions have complete pinned spans and individual caller controls",
       %{
         evidence: evidence
       } do
    entries = Asn1RttCoreEvidence.entries()

    assert Enum.map(entries, & &1.mfa) == [
             {:asn1ct_rtt, :assert_defined, 1},
             {:asn1ct_rtt, :code, 0},
             {:asn1ct_rtt, :dependencies, 1}
           ]

    assert Enum.map(entries, & &1.caller.path) == [
             [{:asn1ct_func, :need, 1}],
             [{:asn1ct_func, :generate, 1}],
             [{:asn1ct_func, :handle_cast, 2}, {:asn1ct_func, :pull_in_deps, 2}]
           ]

    for entry <- entries do
      assert String.length(entry.disposition) > 0

      source = SweepEvidence.resolve!(evidence, entry.source.citation)
      assert entry.source.identity.lane == evidence.lane.name
      assert source.origin == :archive
      assert source.sha256 == entry.source.identity.sha256
      assert File.stat!(source.path).size == entry.source.identity.bytes

      assert sha256(span!(source.path, entry.source.first_line, entry.source.last_line)) ==
               entry.source.span_sha256

      for caller_span <- entry.caller.spans do
        caller = SweepEvidence.resolve!(evidence, caller_span.citation)
        assert entry.caller.identity.lane == evidence.lane.name
        assert caller.origin == :archive
        assert caller.sha256 == entry.caller.identity.sha256
        assert File.stat!(caller.path).size == entry.caller.identity.bytes

        assert sha256(span!(caller.path, caller_span.first_line, caller_span.last_line)) ==
                 caller_span.span_sha256
      end

      positive_span = Enum.at(entry.caller.spans, entry.control.positive_span)
      caller = SweepEvidence.resolve!(evidence, positive_span.citation)
      positive_text = span!(caller.path, positive_span.first_line, positive_span.last_line)
      assert Asn1RttCoreEvidence.guard_matches?(entry, positive_text)

      negative = SweepEvidence.resolve!(evidence, entry.control.negative_citation)
      refute Asn1RttCoreEvidence.guard_matches?(entry, negative.text)

      refute Asn1RttCoreEvidence.guard_matches?(
               entry,
               String.replace(positive_text, entry.control.guard, "", global: false)
             )
    end
  end

  test "the complete code/0 table is checked as bytes and rejects malformed shapes", %{
    evidence: evidence
  } do
    entry = Enum.find(Asn1RttCoreEvidence.entries(), &(&1.mfa == {:asn1ct_rtt, :code, 0}))
    source = SweepEvidence.resolve!(evidence, entry.source.citation)
    bytes = File.read!(source.path)
    body = rtt_body!(bytes)
    grammar = rtt_grammar()

    assert Regex.match?(grammar, body)

    assert length(Regex.scan(Regex.compile!(row_pattern()), body)) ==
             entry.literal_table.row_count

    refute Regex.match?(
             grammar,
             String.replace(body, <<60, 60, 34>>, "<<integer_to_binary(1)>>", global: false)
           )

    refute Regex.match?(
             grammar,
             String.replace(body, "{{ber,ber_encode,1}", "{{erlang,apply(),1}", global: false)
           )

    refute Regex.match?(grammar, body <> " erlang:halt().")
    truncated = String.trim_trailing(body) |> then(&binary_part(&1, 0, byte_size(&1) - 2))
    refute Regex.match?(grammar, truncated)
  end

  defp span!(path, first_line, last_line) do
    bytes = File.read!(path)
    newlines = :binary.matches(bytes, "\n")
    start_offset = if first_line == 1, do: 0, else: elem(Enum.at(newlines, first_line - 2), 0) + 1
    end_offset = elem(Enum.at(newlines, last_line - 1), 0) + 1
    binary_part(bytes, start_offset, end_offset - start_offset)
  end

  defp sha256(bytes), do: :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)

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
end
