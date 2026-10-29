defmodule Fablebook.Contract.BannedCallsTest do
  use ExUnit.Case, async: false

  alias Credo.SourceFile
  alias Credo.Test.CheckRunner
  alias Fablebook.Credo.BannedCalls
  alias Fablebook.Test.BeamWalker

  Code.ensure_loaded?(BannedCalls) ||
    Code.require_file(Path.expand("../../credo/checks/banned_calls.ex", __DIR__))

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
    :to_atom,
    :to_existing_atom,
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
    {String, :to_atom, 1},
    {String, :to_existing_atom, 1},
    {List, :to_atom, 1},
    {List, :to_existing_atom, 1},
    {Module, :concat, 1},
    {Module, :concat, 2},
    {Module, :safe_concat, 1},
    {Module, :safe_concat, 2},
    {Module, :create, 3},
    {EEx, :_, :_},
    {Phoenix.LiveView.TagEngine, :compile, 2},
    {:compile, :_, :_},
    {:code, :load_binary, 3},
    {:erlang, :load_module, 2},
    {:erlang, :prepare_loading, 2},
    {:erlang, :finish_loading, 1},
    {:code, :load_abs, :_},
    {:code, :atomic_load, 1},
    {:code, :prepare_loading, 1},
    {:code, :finish_loading, 1},
    {Kernel.ParallelCompiler, :_, :_},
    {Code, :load_file, :_},
    {:elixir, :quoted_to_erl, :_},
    {:elixir_compiler, :_, :_},
    {:elixir_module, :compile, :_},
    {:elixir_tokenizer, :_, :_},
    {:elixir_parser, :_, :_},
    {:file, :script, :_},
    {:file, :eval, :_},
    {:file, :path_script, :_},
    {:file, :path_eval, :_},
    {:elixir, :eval_forms, :_},
    {:io, :read, :_},
    {:io, :parse_erl_exprs, :_},
    {:io, :parse_erl_form, :_},
    {:io, :scan_erl_exprs, :_},
    {:io, :scan_erl_form, :_},
    {:io, :fread, :_},
    {:io_lib, :fread, :_},
    {:epp, :_, :_},
    {:xmerl_scan, :_, :_},
    {:elixir, :string_to_tokens, :_},
    {Code, :format_string!, :_},
    {Code, :format_file!, :_},
    {Code.Fragment, :container_cursor_to_quoted, :_},
    {Logger.Formatter, :compile, :_},
    {EEx.Compiler, :compile, :_},
    {Phoenix.Template.ExsEngine, :compile, :_},
    {Phoenix.Template.EExEngine, :compile, :_},
    {Phoenix.LiveView.Engine, :compile, :_},
    {Phoenix.LiveView.HTMLEngine, :compile, :_},
    {Phoenix.LiveView.TagEngine.Compiler, :compile, :_},
    {:xref_compiler, :compile, :_},
    {Mix.Compilers.Elixir, :compile, :_},
    {Mix.Compilers.Erlang, :compile, :_},
    {Mix.Tasks.Deps.Compile, :compile, :_},
    {:erl_compile, :compile, :_},
    {:erl_compile_server, :compile, :_},
    {:leex, :compile, :_},
    {:yecc, :compile, :_},
    {Mix.Project, :compile, :_},
    {:elixir_erl, :compile, :_},
    {:cover, :compile, :_},
    {:merl, :_, :_},
    {:asn1ct, :_, :_},
    {:qlc, :string_to_handle, :_}
  ]

  @allowlist []

  @ban_checks ~w(UnsafeToAtom MixEnv ForbiddenModule BannedCalls)

  @lib_modules [Fablebook, Fablebook.Router, Fablebook.Placeholder]

  @fixtures [
    {"alias.ex", {:atom, :eval_string}},
    {"import.ex", {:atom, :eval_string}},
    {"apply.ex", {:atom, :eval_string}},
    {"capture.ex", {:atom, :eval_string}},
    {"macro_quote.ex", {:atom, :eval_quoted}},
    {"interpolated_atom.ex", {:atom, :binary_to_atom}},
    {"dynamic_module.ex", {:mfa, {Module, :concat, 1}}},
    {"banned_dep.ex", {:atom, Jason}},
    {"apply_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
    {"apply_list_existing_atom.ex", {:mfa, {List, :to_existing_atom, 1}}},
    {"function_capture_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
    {"erlang_apply_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
    {"default_arg_to_atom.ex", {:atom, :to_atom}},
    {"load_module.ex", {:mfa, {:erlang, :load_module, 2}}},
    {"internal_eval.ex", {:mfa, {:elixir_module, :compile, 6}}},
    {"parallel_compiler.ex", {:mfa, {Kernel.ParallelCompiler, :require, 1}}},
    {"file_script.ex", {:mfa, {:file, :script, 1}}},
    {"apply_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"computed_compile.ex", {:mfa, {:compile, :_, :_}}},
    {"apply_concat.ex", {:mfa, {Module, :concat, :_}}},
    {"task_async_concat.ex", {:mfa, {Module, :concat, :_}}},
    {"apply_args_to_atom.ex", {:mfa, {String, :to_atom, :_}}},
    {"capture_file_script.ex", {:mfa, {:file, :script, :_}}},
    {"spawn_file_script.ex", {:mfa, {:file, :script, :_}}},
    {"erpc_file_script.ex", {:mfa, {:file, :script, :_}}},
    {"rpc_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"rpc_remote_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"info_load_module.ex", {:mfa, {:erlang, :load_module, :_}}},
    {"info_concat.ex", {:mfa, {Module, :concat, :_}}},
    {"info_capture_script.ex", {:mfa, {:file, :script, :_}}},
    {"info_arity_zero.ex", {:mfa, {:file, :script, :_}}},
    {"qlc_string.ex", {:mfa, {:qlc, :string_to_handle, 1}}},
    {"logger_formatter_compile.ex", {:mfa, {Logger.Formatter, :compile, 1}}},
    {"eex_compiler_compile.ex", {:mfa, {EEx.Compiler, :compile, 3}}},
    {"exs_engine_compile.ex", {:mfa, {Phoenix.Template.ExsEngine, :compile, 2}}},
    {"eex_engine_compile.ex", {:mfa, {Phoenix.Template.EExEngine, :compile, 2}}},
    {"liveview_engine_compile.ex", {:mfa, {Phoenix.LiveView.Engine, :compile, 2}}},
    {"html_engine_compile.ex", {:mfa, {Phoenix.LiveView.HTMLEngine, :compile, 2}}},
    {"tag_engine_compiler_compile.ex",
     {:mfa, {Phoenix.LiveView.TagEngine.Compiler, :compile, 2}}},
    {"xref_compiler_compile.ex", {:mfa, {:xref_compiler, :compile, 2}}},
    {"mix_compilers_elixir_compile.ex", {:mfa, {Mix.Compilers.Elixir, :compile, 7}}},
    {"mix_compilers_erlang_compile.ex", {:mfa, {Mix.Compilers.Erlang, :compile, 3}}},
    {"deps_compile_compile.ex", {:mfa, {Mix.Tasks.Deps.Compile, :compile, 1}}},
    {"erl_compile_compile.ex", {:mfa, {:erl_compile, :compile, 2}}},
    {"erl_compile_server_compile.ex", {:mfa, {:erl_compile_server, :compile, 1}}},
    {"leex_compile.ex", {:mfa, {:leex, :compile, 3}}},
    {"yecc_compile.ex", {:mfa, {:yecc, :compile, 3}}},
    {"mix_project_compile.ex", {:mfa, {Mix.Project, :compile, 1}}},
    {"elixir_erl_compile.ex", {:mfa, {:elixir_erl, :compile, 2}}},
    {"cover_compile.ex", {:mfa, {:cover, :compile, 1}}},
    {"merl_compile.ex", {:mfa, {:merl, :compile, 1}}},
    {"asn1ct_compile.ex", {:mfa, {:asn1ct, :compile, 1}}}
  ]

  @beam_only_fixtures ~w(
    dynamic_module.ex
    load_module.ex
    internal_eval.ex
    parallel_compiler.ex
    file_script.ex
    apply_load_module.ex
    computed_compile.ex
    apply_concat.ex
    task_async_concat.ex
    capture_file_script.ex
    spawn_file_script.ex
    erpc_file_script.ex
    rpc_load_module.ex
    rpc_remote_load_module.ex
    info_load_module.ex
    info_concat.ex
    info_capture_script.ex
    info_arity_zero.ex
    qlc_string.ex
    logger_formatter_compile.ex
    eex_compiler_compile.ex
    exs_engine_compile.ex
    eex_engine_compile.ex
    liveview_engine_compile.ex
    html_engine_compile.ex
    tag_engine_compiler_compile.ex
    xref_compiler_compile.ex
    mix_compilers_elixir_compile.ex
    mix_compilers_erlang_compile.ex
    deps_compile_compile.ex
    erl_compile_compile.ex
    erl_compile_server_compile.ex
    leex_compile.ex
    yecc_compile.ex
    mix_project_compile.ex
    elixir_erl_compile.ex
    cover_compile.ex
    merl_compile.ex
    asn1ct_compile.ex
  )

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
  test "the compiler-internal eval chain hits all three matchers", %{tmp_dir: dir} do
    [beam] = compile!([Path.join(@fixture_dir, "internal_eval.ex")], dir, true)
    assert {:ok, scan} = BeamWalker.scan(beam)

    for mfa <- [
          {:elixir_tokenizer, :tokenize, 4},
          {:elixir_parser, :parse, 1},
          {:elixir_module, :compile, 6}
        ] do
      assert {:mfa, mfa} in hits(scan)
    end
  end

  test "every MFA matcher names an existing function" do
    load_tier_apps()

    for {mod, name, arity} = entry <- @mfa_tier do
      assert Code.ensure_loaded?(mod), "#{inspect(entry)} names a module that does not load"

      assert Enum.any?(mod.module_info(:exports), &mfa_match?({name, arity}, &1)),
             "#{inspect(entry)} matches no exported function"
    end
  end

  test "every guard fixture is listed" do
    on_disk =
      @fixture_dir |> Path.join("*.ex") |> Path.wildcard() |> MapSet.new(&Path.basename/1)

    assert on_disk == MapSet.new(@fixtures, &elem(&1, 0))
  end

  test "beam-only fixtures carry an MFA hit" do
    hits = Map.new(@fixtures)

    for file <- @beam_only_fixtures do
      assert match?({:mfa, _}, hits[file]), "#{file} carries no MFA hit"
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

  @tag :tmp_dir
  test "the pair and whole-module checks match by adjacency and by name outside call-name positions (known strictness)",
       %{tmp_dir: dir} do
    expected = %{
      Fablebook.GuardFixture.StrictRegex => [],
      Fablebook.GuardFixture.StrictErlangRe => [],
      Fablebook.GuardFixture.StrictLocal => [],
      Fablebook.GuardFixture.StrictRegexCapture => [],
      Fablebook.GuardFixture.StrictCompileCapture => [
        {:mfa, {:compile, :_, :_}},
        {:mfa, {:compile, :file, :_}}
      ],
      Fablebook.GuardFixture.StrictVarModuleCompile => [],
      Fablebook.GuardFixture.StrictKeyword => [{:mfa, {:epp, :_, :_}}],
      Fablebook.GuardFixture.StrictKeywordPair => [{:mfa, {:io, :read, :_}}],
      Fablebook.GuardFixture.StrictCompileKey => [
        {:mfa, {:compile, true, :_}},
        {:mfa, {:compile, :_, :_}}
      ],
      Fablebook.GuardFixture.StrictBang => [],
      Fablebook.GuardFixture.StrictSigil => [],
      Fablebook.GuardFixture.StrictTuple => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictAttribute => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictMapKey => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictMfaTuple => [{:mfa, {:erlang, :load_module, :_}}],
      Fablebook.GuardFixture.StrictVariable => [],
      Fablebook.GuardFixture.StrictHelper => [],
      Fablebook.GuardFixture.StrictList => [],
      Fablebook.GuardFixture.StrictMapFields => [],
      Fablebook.GuardFixture.StrictComputed => [],
      Fablebook.GuardFixture.StrictMixTask => [],
      Fablebook.GuardFixture.StrictQlcString => [
        {:mfa, {:qlc, :string_to_handle, 1}},
        {:mfa, {:qlc, :string_to_handle, :_}}
      ],
      Fablebook.GuardFixture.StrictNativeLoad => [],
      Fablebook.GuardFixture.StrictParser => []
    }

    source = Path.join(dir, "strict.ex")

    File.write!(source, ~S"""
    defmodule Fablebook.GuardFixture.StrictRegex do
      def run(source), do: Regex.compile(source)
    end

    defmodule Fablebook.GuardFixture.StrictErlangRe do
      def run(source), do: :re.compile(source, [])
    end

    defmodule Fablebook.GuardFixture.StrictLocal do
      def run(source), do: compile(source)
      defp compile(source), do: source
    end

    defmodule Fablebook.GuardFixture.StrictRegexCapture do
      def run, do: &Regex.compile/1
    end

    defmodule Fablebook.GuardFixture.StrictCompileCapture do
      def run, do: &:compile.file/1
    end

    defmodule Fablebook.GuardFixture.StrictVarModuleCompile do
      def run(m, s), do: m.compile(s)
    end

    defmodule Fablebook.GuardFixture.StrictKeyword do
      def run, do: [epp: 1]
    end

    defmodule Fablebook.GuardFixture.StrictKeywordPair do
      def run, do: [io: :read]
    end

    defmodule Fablebook.GuardFixture.StrictCompileKey do
      def run, do: [compile: true]
    end

    defmodule Fablebook.GuardFixture.StrictBang do
      def run(source), do: Regex.compile!(source)
    end

    defmodule Fablebook.GuardFixture.StrictSigil do
      def run(source), do: source =~ ~r/fo+/
    end

    defmodule Fablebook.GuardFixture.StrictTuple do
      def run(args) do
        {m, f} = target()
        apply(m, f, args)
      end

      defp target, do: {:erlang, :load_module}
    end

    defmodule Fablebook.GuardFixture.StrictAttribute do
      @target {:erlang, :load_module}

      def run(args) do
        {m, f} = @target
        apply(m, f, args)
      end
    end

    defmodule Fablebook.GuardFixture.StrictMapKey do
      def run(args) do
        [{m, f}] = Map.to_list(target())
        apply(m, f, args)
      end

      defp target, do: %{:erlang => :load_module}
    end

    defmodule Fablebook.GuardFixture.StrictMfaTuple do
      def run(args) do
        {m, f, a} = target(args)
        apply(m, f, a)
      end

      defp target(args), do: {:erlang, :load_module, args}
    end

    defmodule Fablebook.GuardFixture.StrictVariable do
      def run(args) do
        m = :erlang
        apply(m, :load_module, args)
      end
    end

    defmodule Fablebook.GuardFixture.StrictHelper do
      def run(args), do: apply(module(), :load_module, args)
      defp module, do: :erlang
    end

    defmodule Fablebook.GuardFixture.StrictList do
      def run(args) do
        [m, f] = target()
        apply(m, f, args)
      end

      defp target, do: [:erlang, :load_module]
    end

    defmodule Fablebook.GuardFixture.StrictMapFields do
      def run(args) do
        %{m: m, f: f} = target()
        apply(m, f, args)
      end

      defp target, do: %{m: :erlang, f: :load_module}
    end

    defmodule Fablebook.GuardFixture.StrictComputed do
      def run(m, f, args), do: apply(m, f, args)
    end

    defmodule Fablebook.GuardFixture.StrictMixTask do
      def run(code), do: Mix.Task.run("run", ["-e", code])
    end

    defmodule Fablebook.GuardFixture.StrictQlcString do
      def run(query), do: :qlc.string_to_handle(query)
    end

    defmodule Fablebook.GuardFixture.StrictNativeLoad do
      def run(path), do: :erlang.load_nif(path, 0)
    end

    defmodule Fablebook.GuardFixture.StrictParser do
      def run(path), do: :epp_dodger.parse_file(path)
    end
    """)

    scans =
      for beam <- compile!([source], dir, true), into: %{} do
        assert {:ok, scan} = BeamWalker.scan(beam)
        {scan.module, Enum.sort(Enum.uniq(hits(scan)))}
      end

    assert Enum.sort(Map.keys(scans)) == Enum.sort(Map.keys(expected))

    for {module, hits} <- expected do
      assert scans[module] == Enum.sort(hits), "#{inspect(module)}: #{inspect(scans[module])}"
    end
  end

  test "the Credo check bans the same names and flags the source-level fixtures" do
    unless Process.whereis(Credo.Supervisor),
      do: {:ok, _} = Application.ensure_all_started(:credo)

    assert BannedCalls.banned_names() == Enum.sort(@atom_tier)
    assert BannedCalls.banned_mfas() == Enum.sort(@mfa_tier)

    for path <- Path.wildcard(Path.join(@fixture_dir, "*.ex")),
        Path.basename(path) not in @beam_only_fixtures do
      assert credo_issues(path) != [], "no Credo issue for #{Path.relative_to_cwd(path)}"
    end

    for path <- Path.wildcard("lib/**/*.ex") do
      assert credo_issues(path) == [], "Credo issue in #{path}"
    end
  end

  test "no credo:disable in lib/ names a ban check" do
    hits =
      for path <- Path.wildcard("lib/**/*.ex"),
          {line, n} <- path |> File.read!() |> String.split("\n") |> Enum.with_index(1),
          line =~ "credo:disable",
          Enum.any?(@ban_checks, &(line =~ &1)),
          do: "#{path}:#{n}"

    assert hits == []
  end

  test "mix.exs names no banned call or module" do
    assert mix_exs_hits(File.read!("mix.exs")) == []
  end

  test "the mix.exs scan matches bare and qualified calls" do
    assert mix_exs_hits("Code.eval_string(x)") == ["eval_string"]
    assert mix_exs_hits(":erlang.binary_to_atom(x, :utf8)") == ["binary_to_atom"]
    assert mix_exs_hits("Elixir.Telemetry.Metrics") == ["Telemetry.Metrics"]
    assert mix_exs_hits("String.to_atom(x)") == ["to_atom", "String.to_atom"]
    assert mix_exs_hits("eval_strings = 1") == []
    assert mix_exs_hits("my_eval_string(x)") == []
    assert mix_exs_hits(":file.eval(x)") == [":file.eval"]
    assert mix_exs_hits("Module.concat(x)") == ["Module.concat"]
    assert mix_exs_hits(":epp.parse_file(p)") == [":epp"]
    assert mix_exs_hits("compile --force") == []
  end

  defp mix_exs_hits(text) do
    atom_names =
      for atom <- @atom_tier, do: atom |> Atom.to_string() |> String.replace_prefix("Elixir.", "")

    mfa_names = @mfa_tier |> Enum.map(&mfa_name/1) |> Enum.uniq()

    for name <- atom_names ++ mfa_names,
        Regex.match?(~r/(?<!\w)#{Regex.escape(name)}(?![\w!?])/, text),
        do: name
  end

  defp load_tier_apps do
    Enum.each([:xmerl, :tools, :parsetools, :syntax_tools, :asn1], &Mix.ensure_application!/1)
  end

  defp mfa_name({module, :_, _}), do: inspect(module)
  defp mfa_name({module, function, _}), do: "#{inspect(module)}.#{function}"

  defp credo_issues(path) do
    path
    |> File.read!()
    |> SourceFile.parse(path)
    |> CheckRunner.run_check(BannedCalls)
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

  defp hits(%{atoms: atoms, mfas: mfas, pairs: pairs, literals: literals}) do
    atom_hits = for atom <- @atom_tier, atom in atoms, do: {:atom, atom}
    mfa_hits = for mfa <- mfas, Enum.any?(@mfa_tier, &mfa_match?(&1, mfa)), do: {:mfa, mfa}

    pair_hits =
      for {m, f} <- pairs,
          Enum.any?(@mfa_tier, fn {pm, pf, _} -> pm == m and pf in [:_, f] end),
          do: {:mfa, {m, f, :_}}

    literal_hits = for m <- literals, {m, :_, :_} in @mfa_tier, do: {:mfa, {m, :_, :_}}
    atom_hits ++ mfa_hits ++ pair_hits ++ literal_hits
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
