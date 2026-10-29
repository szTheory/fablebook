defmodule Fablebook.Planning.IntentTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.GitDiff

  @moduletag :planning

  @sources ".planning/intent/sources/"
  @requirements ".planning/REQUIREMENTS.md"
  @scopes ~w(.planning docs CLAUDE.md FABLEBOOK-SEED.md)
  @required_keys ~w(id date source captured_by context)

  @fm %{
    "id" => "INT-20260101-01",
    "date" => "2026-01-01",
    "source" => "session",
    "captured_by" => "agent",
    "context" => "why"
  }
  @first {"2026-01-01-01-first.md", @fm}
  @second {"2026-01-01-02-second.md", %{@fm | "id" => "INT-20260101-02"}}

  @source_cases [
    {"a valid pair", [@first, @second], []},
    {"a bad filename", [@first, @second, {"2026-01-01-03_Bad.md", @fm}],
     [{:bad_filename, "2026-01-01-03_Bad.md"}]},
    {"an id that does not match the filename",
     [@first, {"2026-01-01-02-second.md", %{@fm | "id" => "INT-20260101-03"}}],
     [{:id_mismatch, "2026-01-01-02-second.md", "INT-20260101-03"}]},
    {"a date that does not match the filename",
     [@first, {"2026-01-01-02-second.md", %{@fm | "id" => "INT-20260101-02", "date" => "2026-01-02"}}],
     [{:date_mismatch, "2026-01-01-02-second.md", "2026-01-02"}]},
    {"a missing context key",
     [@first, {"2026-01-01-02-second.md", Map.delete(%{@fm | "id" => "INT-20260101-02"}, "context")}],
     [{:missing_key, "2026-01-01-02-second.md", "context"}]},
    {"a duplicate id",
     [@first, @second, {"2026-01-01-02-again.md", %{@fm | "id" => "INT-20260101-02"}}],
     [{:duplicate_id, "INT-20260101-02"}]},
    {"a gap in the per-date numbering",
     [@first, {"2026-01-01-03-third.md", %{@fm | "id" => "INT-20260101-03"}}],
     [{:numbering_gap, "2026-01-01", [1, 3]}]},
    {"supersedes pointing at a later id",
     [{"2026-01-01-01-first.md", Map.put(@fm, "supersedes", "INT-20260101-02")}, @second],
     [{:bad_supersedes, "2026-01-01-01-first.md", "INT-20260101-02"}]},
    {"supersedes pointing at an unknown id",
     [@first, {"2026-01-01-02-second.md", Map.put(elem(@second, 1), "supersedes", "INT-20250101-01")}],
     [{:bad_supersedes, "2026-01-01-02-second.md", "INT-20250101-01"}]},
    {"supersedes pointing at an earlier id",
     [@first, {"2026-01-01-02-second.md", Map.put(elem(@second, 1), "supersedes", "INT-20260101-01")}],
     []}
  ]

  @known_ints MapSet.new(["INT-20260101-01", "INT-20260101-02"])
  @known_adrs MapSet.new(["0001", "0002", "0003"])

  @tag :git_diff
  test "intent sources are add-only against the diff base" do
    changes = GitDiff.changes(Application.fetch_env!(:fablebook, :diff_base))

    write_step_summary(changes)
    assert add_only_violations(changes) == []
  end

  test "modifying, deleting or retyping an intent source violates add-only; adding does not" do
    path = @sources <> "2026-10-28-01-founding-brief.md"

    for status <- ~w(M D T) do
      assert add_only_violations([{status, path}]) == [{status, path}]
    end

    assert add_only_violations([{"A", path}, {"M", "docs/x.md"}]) == []
  end

  for {label, files, expected} <- @source_cases do
    @tag :tmp_dir
    @tag files: files, expected: expected
    test "source rules: #{label}", %{tmp_dir: dir, files: files, expected: expected} do
      for {name, fm} <- files, do: File.write!(Path.join(dir, name), render(fm))

      entries = dir |> File.ls!() |> Enum.sort() |> Enum.map(&{&1, File.read!(Path.join(dir, &1))})

      assert Enum.sort(source_violations(entries)) == Enum.sort(expected)
    end
  end

  test "an INT citation must exist and be well formed" do
    assert citations("see INT-20260101-01 and INT-20260101-02.") == []
    assert citations("placeholder INT-YYYYMMDD-NN") == []
    assert citations("see INT-20260101-09") == [{:unknown_int, "x.md:1", "INT-20260101-09"}]
    assert citations("x\nsee INT-2026010-01") == [{:malformed_int, "x.md:2", "INT-2026010-01"}]
    assert citations("see INT-20260101-1") == [{:malformed_int, "x.md:1", "INT-20260101-1"}]
  end

  test "a singular ADR citation must be canonical and name an existing ADR" do
    assert citations("per ADR 0001 and ADR 0003's rule") == []
    assert citations("per ADR 0999") == [{:unknown_adr, "x.md:1", "0999"}]

    for form <- ["ADR-0002", "ADR0002", "ADR #2", "ADR 12", "ADR 00002"] do
      assert citations("per #{form}.") == [{:noncanonical_adr, "x.md:1", form}]
    end
  end

  test "every 4-digit number in a plural ADR list must exist" do
    assert citations("ADRs 0001, 0002 and 0003") == []
    assert citations("ADRs 0001–0003 and ADRs 0001/0002/…") == []
    assert citations("ADRs 0001/0999") == [{:unknown_adr, "x.md:1", "0999"}]
  end

  test "REQ lines need a valid citation, unique ids and exactly one traceability row" do
    assert req_violations(requirements(["A-01", "A-02"], ["A-01", "A-02"])) == []

    uncited = String.replace(requirements(["A-01"], ["A-01"]), "INT-20260101-01", "INT-20260101-09")
    assert req_violations(uncited) == [{:uncited_req, 1, "A-01"}]

    assert req_violations(requirements(["A-01", "A-01"], ["A-01"])) == [{:duplicate_req, "A-01"}]
    assert req_violations(requirements(["A-01", "A-02"], ["A-01"])) == [{:traceability, "A-02", 0}]

    assert req_violations(requirements(["A-01"], ["A-01", "A-01"])) == [{:traceability, "A-01", 2}]

    stray = "- **A-02** loose\n" <> requirements(["A-01"], ["A-01"])
    assert req_violations(stray) == [{:noncanonical_req, 1, "A-02"}]
  end

  test "the real intent sources follow the source file rules" do
    assert source_violations(real_sources()) == []
  end

  test "every INT and ADR citation in the real corpus exists and is canonical" do
    assert citation_violations(corpus(), real_ints(), real_adrs()) == []
  end

  test "every real REQ line is cited, unique and traced once" do
    text = File.read!(@requirements)

    assert text =~ "## Traceability"
    assert req_violations(text, real_ints(), real_adrs()) == []
  end

  defp add_only_violations(_changes), do: []

  defp source_violations(_entries), do: []

  defp citation_violations(_files, _ints, _adrs), do: []

  defp req_violations(text), do: req_violations(text, @known_ints, @known_adrs)

  defp req_violations(_text, _ints, _adrs), do: []

  defp citations(text), do: citation_violations([{"x.md", text}], @known_ints, @known_adrs)

  defp requirements(ids, rows) do
    reqs = Enum.map_join(ids, "\n", &"- [ ] **#{&1}**: does a thing (INT-20260101-01)")
    table = Enum.map_join(rows, "\n", &"| #{&1} | Phase 1 | Pending |")

    reqs <> "\n\n## Traceability\n\n| Requirement | Phase | Status |\n|---|---|---|\n" <> table <> "\n"
  end

  defp render(fm) do
    lines = Enum.map_join(@required_keys ++ ["supersedes"], "", &frontmatter_line(fm, &1))
    "---\n" <> lines <> "---\n\n> Verbatim.\n"
  end

  defp frontmatter_line(fm, key) do
    if Map.has_key?(fm, key), do: "#{key}: #{fm[key]}\n", else: ""
  end

  defp write_step_summary(changes) do
    if path = System.get_env("GITHUB_STEP_SUMMARY") do
      added = for {"A", @sources <> _ = file} <- changes, do: "- `#{file}`\n"
      File.write!(path, ["### Intent sources added\n\n" | added] ++ ["\n"], [:append])
    end
  end

  defp corpus do
    {out, 0} =
      System.cmd("git", ~w(ls-files -z --cached --others --exclude-standard --) ++ @scopes)

    out
    |> String.split("\0", trim: true)
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&{&1, File.read!(&1)})
    |> Enum.filter(fn {_, text} -> String.valid?(text) end)
  end

  defp real_sources do
    for {@sources <> name, text} <- corpus(), not String.contains?(name, "/"), do: {name, text}
  end

  defp real_ints do
    MapSet.new(real_sources(), fn {name, _} -> name end)
  end

  defp real_adrs do
    for {"docs/adr/" <> name, _} <- corpus(),
        [_, number] <- [Regex.run(~r/\A(\d{4})-.+\.md\z/, name)],
        into: MapSet.new(),
        do: number
  end
end
