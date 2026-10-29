defmodule Fablebook.Contract.TierSweepTest do
  use ExUnit.Case, async: false

  alias Fablebook.Credo.BannedCalls
  @compile {:no_warn_undefined, :xref}

  Code.ensure_loaded?(BannedCalls) ||
    Code.require_file(Path.expand("../../credo/checks/banned_calls.ex", __DIR__))

  @otp_apps ~w(
    kernel stdlib compiler erts crypto public_key asn1 ssl inets syntax_tools tools parsetools
    runtime_tools sasl dialyzer xmerl os_mon
  )a
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
    fixed_app:
      "puts only a named OTP application or Mix's own archive directory on the code path; loads no caller code",
    fixed_args: "calls a code-loading front door only with arguments fixed in its own source"
  }

  @call_name_exclusions []

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
    {:yecc, :epp_guard},
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
     "phoenix/lib/phoenix/controller/pipeline.ex:39"}
  ]

  @eval_funs [:eval_str, :expr, :expr_list, :exprs, :match_clause]
  @citation_re ~r/^[a-z_]+\/[^\s:]+\.(ex|erl|hrl):\d+$/
  @static_sinks [
                  {:erlang, :load_module},
                  {:erlang, :prepare_loading},
                  {:erlang, :load_nif},
                  {:erl_ddll, :try_load}
                ] ++ for(fun <- @eval_funs, do: {:erl_eval, fun})

  setup_all do
    graph = build_graph()
    {:ok, graph: graph}
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
        matched_uncovered(uncovered, [entry]) |> MapSet.size() > 0
      end)

    assert undisposed == [],
           "undisposed banned-module-named functions: #{inspect(Enum.sort(undisposed))}"

    assert unmatched_exclusions == [],
           "call-name exclusions matching no uncovered function: #{inspect(unmatched_exclusions)}"
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
    invalid = Enum.reject(@exclusions ++ @call_name_exclusions, &valid_exclusion?/1)

    assert invalid == [], "invalid exclusion records: #{inspect(invalid)}"
  end

  defp build_graph do
    Mix.ensure_application!(:tools)
    otp_lib = :code.lib_dir() |> to_string()
    otp_dirs = otp_app_dirs(otp_lib)
    elixir_dirs = for app <- @elixir_apps, do: app_dir(app)
    roots = dependency_roots()
    closure = dependency_closure(roots)
    dep_dirs = for app <- closure, do: Path.join([Mix.Project.build_path(), "lib", app, "ebin"])
    dirs = Enum.uniq(otp_dirs ++ elixir_dirs ++ dep_dirs)
    missing_apps = missing_apps(otp_lib, elixir_dirs, dep_dirs)

    {:ok, _} = :xref.start(:tier_sweep, xref_mode: :functions)

    :ok = :xref.set_default(:tier_sweep, warnings: false, verbose: false, builtins: true)

    for dir <- dirs, do: :xref.add_directory(:tier_sweep, String.to_charlist(dir))
    {:ok, xref_edges} = :xref.q(:tier_sweep, ~c"E")
    {:ok, exported} = :xref.q(:tier_sweep, ~c"X")
    :xref.stop(:tier_sweep)
    {form_edges, no_debug} = form_edges(dirs)
    edges = form_edges ++ for({caller, {m, f, _}} <- xref_edges, do: {caller, {m, f}})
    reverse = reverse(edges)

    %{
      dirs: dirs,
      edges: edges,
      exported: MapSet.new(exported),
      reverse: reverse,
      no_debug: no_debug,
      missing_apps: missing_apps,
      roots: roots,
      closure: closure,
      out_of_scope: out_of_scope()
    }
  end

  defp otp_app_dirs(otp_lib) do
    otp_lib
    |> File.ls!()
    |> Enum.filter(fn dir ->
      Enum.any?(@otp_apps, &String.starts_with?(dir, "#{&1}-")) and
        File.dir?(Path.join([otp_lib, dir, "ebin"]))
    end)
    |> Enum.map(&Path.join([otp_lib, &1, "ebin"]))
  end

  defp missing_apps(otp_lib, elixir_dirs, dep_dirs) do
    otp_apps = Enum.map(@otp_apps, &Atom.to_string/1)
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

  defp out_of_scope do
    all = :code.lib_dir() |> to_string() |> File.ls!()
    scoped = Enum.map(@otp_apps, &Atom.to_string/1)

    all
    |> Enum.filter(&File.dir?(Path.join([:code.lib_dir() |> to_string(), &1, "ebin"])))
    |> Enum.map(&String.replace(&1, ~r/-[0-9][0-9.]*$/, ""))
    |> Enum.uniq()
    |> Enum.reject(&(&1 in scoped))
    |> Enum.sort()
  end

  defp form_edges(dirs) do
    beams =
      for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), do: {dir, file}

    Enum.reduce(beams, {[], []}, fn {dir, file}, acc -> collect_beam_edges(dir, file, acc) end)
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

  defp barrier?({m, f}) do
    (m == :code and f in [:ensure_loaded, :load_file, :ensure_modules_loaded]) or
      m in [:code_server, :error_handler, :erl_prim_loader, :init, :erl_lint]
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

  defp undisposed(graph, tier, names) do
    graph
    |> dispositions(tier, names)
    |> Enum.filter(&(elem(&1, 1) == nil))
    |> Enum.map(&elem(&1, 0))
  end

  defp dispositions(graph, tier, names) do
    {reached, _parent} = reach(graph, tier, names)

    reached
    |> Enum.filter(&MapSet.member?(graph.exported, &1))
    |> Enum.reject(fn {m, f, _arity} ->
      m in [:erlang, :erl_eval, :erl_ddll] or f == :module_info
    end)
    |> Enum.map(fn mfa -> {mfa, disposition(mfa, tier, names)} end)
  end

  defp disposition({m, f, a}, tier, names) do
    if covered?({m, f, a}, tier, names), do: :tier, else: exclusion_reason(m, f)
  end

  defp covered?({m, f, a}, tier, names) do
    f in names or m in names or
      Enum.any?(tier, fn {pm, pf, pa} -> pm == m and pf in [:_, f] and pa in [:_, a] end)
  end

  defp banned_module_named?({_module, function, _arity}, whole_modules),
    do: function in whole_modules

  defp matched_uncovered(uncovered, entries) do
    Enum.reduce(entries, MapSet.new(), fn {matcher, _reason, _citation}, matched ->
      Enum.reduce(uncovered, matched, fn mfa, acc ->
        if call_name_exclusion_match?(matcher, mfa), do: MapSet.put(acc, mfa), else: acc
      end)
    end)
  end

  defp call_name_exclusion_match?({module, functions}, {module, function, _arity})
       when is_list(functions),
       do: function in functions

  defp call_name_exclusion_match?(_matcher, _mfa), do: false

  defp exclusion_reason(m, f) do
    Enum.find_value(@exclusions, fn
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

    walk(graph.reverse, @static_sinks ++ tier_sinks)
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
end
