defmodule Fablebook.Contract.TarballTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.MixCmd

  @moduletag :release
  @moduletag :tmp_dir
  @moduletag timeout: 180_000

  @top_level ~w(mix.exs .formatter.exs README.md LICENSE CHANGELOG.md usage-rules.md)
  @denied_prefixes ~w(storybook/ design/ hosts/ test/ bench/ docs/ .planning/ priv/)
  @denied_extensions ~w(.beam .tar)

  @required ~w(phoenix phoenix_live_view phoenix_html telemetry nimble_options)
  @optional_allowed ~w(igniter earmark phoenix_test_playwright)
  @banned ~w(jason mdex floki telemetry_metrics)
  @banned_pattern "ya?ml|yamerl"

  @pii_patterns [~S|/Users/|, ~S|/home/|, ~S|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|]

  test "the built package holds exactly the allowlisted files and metadata", %{tmp_dir: dir} do
    out = Path.join(dir, "fablebook")

    {log, status} =
      MixCmd.run(File.cwd!(), "dev", ["hex.build", "--unpack", "--output", out])

    assert status == 0, log

    files = relative_files(out)
    {:ok, metadata} = :file.consult(Path.join(out, "hex_metadata.config"))

    assert file_violations(files, expected_files()) == []
    assert metadata_violations(metadata) == []
    assert pii_hits(Enum.map(files, &{&1, File.read!(Path.join(out, &1))})) == []
  end

  test "the file checker rejects unlisted and denied files" do
    files = expected_files() ++ ["test/x.exs", ".DS_Store", "priv/static/app.js", "lib/x.beam"]
    found = file_violations(files, expected_files())

    for file <- ["test/x.exs", ".DS_Store", "priv/static/app.js", "lib/x.beam"] do
      assert {:denied, file} in found
    end

    assert {:missing, "LICENSE"} in file_violations(
             expected_files() -- ["LICENSE"],
             expected_files()
           )
  end

  test "the metadata checker rejects each mismatch" do
    good = metadata(@required, [])
    assert metadata_violations(good) == []

    assert :licenses in metadata_violations(
             List.keyreplace(good, "licenses", 0, {"licenses", ["Apache-2.0"]})
           )

    assert :version in metadata_violations(
             List.keyreplace(good, "version", 0, {"version", "9.9.9"})
           )

    assert :required in metadata_violations(metadata(@required -- ["telemetry"], []))
    assert :optional in metadata_violations(metadata(@required, ["req"]))
    assert :banned in metadata_violations(metadata(@required, ["jason"]))

    assert :files in metadata_violations(
             List.keyreplace(good, "files", 0, {"files", ["lib", "test"]})
           )
  end

  test "the PII scan flags home paths and email addresses" do
    home = "/Users/" <> "sample/project"
    email = "dev" <> "@" <> "example.com"

    assert pii_hits([{"README.md", "see #{home}"}, {"LICENSE", "mail #{email}"}, {"ok", "~/"}]) ==
             ["README.md", "LICENSE"]
  end

  defp metadata(required, optional) do
    requirements =
      Enum.map(required, &[{"app", &1}, {"optional", false}]) ++
        Enum.map(optional, &[{"app", &1}, {"optional", true}])

    [
      {"name", "fablebook"},
      {"app", "fablebook"},
      {"version", Mix.Project.config()[:version]},
      {"licenses", ["MIT"]},
      {"files", ["lib", "lib/fablebook.ex" | @top_level]},
      {"requirements", requirements}
    ]
  end

  defp expected_files do
    lib = for path <- Path.wildcard("lib/**", match_dot: true), File.regular?(path), do: path
    Enum.sort(lib ++ @top_level ++ ["hex_metadata.config"])
  end

  defp relative_files(root) do
    for path <- Path.wildcard(Path.join(root, "**"), match_dot: true),
        File.regular?(path),
        do: Path.relative_to(path, root)
  end

  defp file_violations(files, expected) do
    Enum.concat([
      for(file <- expected -- files, do: {:missing, file}),
      for(file <- files -- expected, do: {:unexpected, file}),
      for(file <- files, denied?(file), do: {:denied, file})
    ])
  end

  defp denied?(file) do
    base = Path.basename(file)

    String.starts_with?(file, @denied_prefixes) or Path.extname(file) in @denied_extensions or
      base == ".DS_Store" or String.starts_with?(base, ".env")
  end

  defp metadata_violations(metadata) do
    meta = Map.new(metadata)
    requirements = Enum.map(meta["requirements"], &Map.new/1)
    names = fn optional -> for r <- requirements, r["optional"] == optional, do: r["app"] end

    [
      identity: meta["name"] == "fablebook" and meta["app"] == "fablebook",
      version: meta["version"] == Mix.Project.config()[:version],
      licenses: meta["licenses"] == ["MIT"],
      required: Enum.sort(names.(false)) == Enum.sort(@required),
      optional: names.(true) -- @optional_allowed == [],
      banned: not Enum.any?(requirements, &banned?(&1["app"] || &1["name"])),
      files: Enum.all?(meta["files"], &packaged?/1)
    ]
    |> Enum.reject(&elem(&1, 1))
    |> Enum.map(&elem(&1, 0))
  end

  defp packaged?(file),
    do: file == "lib" or String.starts_with?(file, "lib/") or file in @top_level

  defp banned?(app),
    do: app in @banned or Regex.match?(Regex.compile!(@banned_pattern), app)

  defp pii_hits(contents) do
    regexes = Enum.map(@pii_patterns, &Regex.compile!/1)

    for {path, text} <- contents,
        Enum.any?(regexes, &Regex.match?(&1, text)),
        do: path
  end
end
