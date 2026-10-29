defmodule Fablebook.Contract.BannedCallsTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.BeamWalker

  @atom_tier [
    :eval_string,
    :eval_quoted,
    :eval_quoted_with_env,
    :eval_file,
    :string_to_quoted,
    :string_to_quoted!,
    :string_to_quoted_with_comments,
    :string_to_quoted_with_comments!,
    :compile_string,
    :compile_quoted,
    :compile_file,
    :require_file,
    :binary_to_atom,
    :list_to_atom,
    :binary_to_existing_atom,
    :list_to_existing_atom,
    :binary_to_term,
    :erl_eval,
    :erl_scan,
    :erl_parse,
    :yamerl,
    Jason,
    Floki,
    MDEx,
    YamlElixir,
    Telemetry.Metrics
  ]

  @mfa_tier [
    {Module, :concat, 1},
    {Module, :concat, 2},
    {Module, :safe_concat, 1},
    {Module, :safe_concat, 2},
    {Module, :create, 3},
    {EEx, :_, :_},
    {Phoenix.LiveView.TagEngine, :compile, 2},
    {:compile, :forms, :_},
    {:compile, :file, :_},
    {:code, :load_binary, 3}
  ]

  @allowlist []

  @lib_modules [Fablebook, Fablebook.Router, Fablebook.Placeholder]

  @fixtures [
    {"alias.ex", {:atom, :eval_string}},
    {"import.ex", {:atom, :eval_string}},
    {"apply.ex", {:atom, :eval_string}},
    {"capture.ex", {:atom, :eval_string}},
    {"macro_quote.ex", {:atom, :eval_quoted}},
    {"interpolated_atom.ex", {:atom, :binary_to_atom}},
    {"dynamic_module.ex", {:mfa, {Module, :concat, 1}}},
    {"banned_dep.ex", {:atom, Jason}}
  ]

  @fixture_dir Path.expand("../fixtures/guards", __DIR__)

  test "no lib/ module references a banned call, atom or dependency" do
    findings = Enum.flat_map(lib_modules(), &findings(:code.which(&1)))

    assert findings == [], "banned in lib/: #{inspect(findings)}"
  end

  test "the scan covers every lib/ module" do
    assert MapSet.subset?(MapSet.new(@lib_modules), MapSet.new(lib_modules()))
  end

  for {file, hit} <- @fixtures do
    @tag :tmp_dir
    @tag fixture: file, hit: hit
    test "the guard catches the #{Path.rootname(file)} bypass", %{tmp_dir: dir} = ctx do
      [beam] = compile!([Path.join(@fixture_dir, ctx.fixture)], dir, true)

      assert {:ok, scan} = BeamWalker.scan(beam)
      assert ctx.hit in hits(scan)
      assert {scan.module, ctx.hit} in findings(beam)
    end
  end

  @tag :tmp_dir
  test "a module without debug info fails the guard", %{tmp_dir: dir} do
    source = Path.join(dir, "stripped.ex")
    File.write!(source, "defmodule Fablebook.GuardFixture.Stripped, do: def(ok, do: :ok)\n")

    [beam] = compile!([source], dir, false)

    assert BeamWalker.scan(beam) == {:error, :no_debug_info}
    assert [{_, :no_debug_info}] = findings(beam)
  end

  defp lib_modules do
    lib = Path.join(File.cwd!(), "lib") <> "/"

    for mod <- Application.spec(:fablebook, :modules),
        String.starts_with?(to_string(mod.module_info(:compile)[:source]), lib),
        do: mod
  end

  defp findings(beam) do
    case BeamWalker.scan(beam) do
      {:ok, scan} ->
        for hit <- hits(scan), {scan.module, hit} not in @allowlist, do: {scan.module, hit}

      {:error, reason} ->
        [{Path.basename(to_string(beam)), reason}]
    end
  end

  defp hits(%{atoms: atoms, mfas: mfas}) do
    atom_hits = for atom <- @atom_tier, atom in atoms, do: {:atom, atom}
    mfa_hits = for mfa <- mfas, Enum.any?(@mfa_tier, &mfa_match?(&1, mfa)), do: {:mfa, mfa}
    atom_hits ++ mfa_hits
  end

  defp mfa_match?(pattern, mfa) do
    pattern
    |> Tuple.to_list()
    |> Enum.zip(Tuple.to_list(mfa))
    |> Enum.all?(fn {expected, actual} -> expected == :_ or expected == actual end)
  end

  defp compile!(files, dir, debug_info) do
    previous = Code.get_compiler_option(:debug_info)
    Code.put_compiler_option(:debug_info, debug_info)

    {result, _stderr} =
      try do
        ExUnit.CaptureIO.with_io(:stderr, fn ->
          Kernel.ParallelCompiler.compile_to_path(files, dir)
        end)
      after
        Code.put_compiler_option(:debug_info, previous)
      end

    assert {:ok, modules, _warnings} = result
    Enum.map(modules, &Path.join(dir, "#{&1}.beam"))
  end
end
