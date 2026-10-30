defmodule Fablebook.Credo.BannedCalls do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Fablebook never evaluates code, compiles templates at runtime, creates atoms from input,
      or references a banned dependency (ADR 0004, ADR 0018).

      The Credo source check scans the whole file, including module bodies, `quote` blocks, and
      `mix.exs`. It flags banned names and remote calls to a tier entry through a direct call,
      an alias, `apply/3`, a pipe, or a newline after the dot; this includes a Mix task run through
      `Mix.Task.run`.
      It also flags adjacent module/function literals in argument lists, list literals, tuples,
      maps and keyword pairs, whole-module tier names outside call-name positions, and imports of
      tier modules.

      The compiled-BEAM guard in `test/contract/banned_calls_test.exs` reads compiled functions in
      each `lib/` module, including user-defined `__info__` functions other than the compiler's
      `__info__/1`. It checks imported MFAs, adjacent literal pairs in call arguments, tuples and
      maps, whole-module literals outside call-name positions, and banned names. Its pair walker
      does not flag a plain list such as `[:erlang, :load_module]`, which the source check flags.
      The tier data is checked by the reachability sweep, the banned-module-named check, and the
      boundary contract in `test/contract/tier_sweep_test.exs`.

      Neither static layer follows names held in variables, including a module variable in
      `m.compile(s)`, returned alone by a helper, split across map fields, computed at runtime, or
      built as aliases from `__MODULE__`. Neither layer catches code that writes a `.beam` file
      into a directory already on the code path and then loads it by name; the Phase 5 atom-count
      property and never-eval proof (ADR 0004) are the backstop.
      An open item owned by Phase 01.1.1.1 is a direct call to an unlisted function that turns
      caller-chosen text or files into atoms; `:file.path_consult/2` passes both layers until that
      phase bans it.
      Another open item owned by Phase 01.1.1.1 is a direct call to an eval, compile-and-load, or
      load front door in an installed OTP app outside the swept scope; `:ct_make.files/2` with the
      `load` option passes both layers until that phase sweeps those apps.
      The source strictness rows preserve the over-catches `[epp: 1]`, `[io: :read]`, and
      `[compile: true]`.
      """
    ]

  @names Enum.sort([
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
         ])

  @mfas Enum.sort([
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
          {:erlang, :call_on_load_function, 1},
          {:erlang, :finish_after_on_load, 2},
          {:erlang, :finish_loading, 1},
          {:init, :boot, 1},
          {:init, :run_on_load_handlers, 0},
          {:erl_prim_loader, :get_modules, 2},
          {:erl_prim_loader, :get_modules, 3},
          {Config.Provider, :boot, :_},
          {System, :restart, 0},
          {:eval_bits, :expr_grp, :_},
          {:eval_bits, :match_bits, :_},
          {:eval_bits, :bin_gen, :_},
          {:qlc, :cursor, :_},
          {:qlc, :e, :_},
          {:qlc, :eval, :_},
          {:qlc, :fold, :_},
          {:qlc, :next_answers, :_},
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
          {:file, :consult, 1},
          {:file, :path_consult, 2},
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
          {Logger.Formatter, :new, 1},
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
          {:yecc, :file, 1},
          {:yecc, :file, 2},
          {:yecc, :yecc, 2},
          {:yecc, :yecc, 3},
          {:yecc, :yecc, 4},
          {Mix.Project, :compile, :_},
          {:elixir_erl, :compile, :_},
          {:cover, :compile, :_},
          {:merl, :_, :_},
          {:asn1ct, :_, :_},
          {:qlc, :string_to_handle, :_},
          {:c, :erlangrc, :_},
          {:shell, :start, :_},
          {:shell, :server, :_},
          {:shell, :local_func, :_},
          {:shell, :read_and_add_records, :_},
          {:shell_default, :_, :_},
          {:escript, :start, :_},
          {:ssl_dist_sup, :consult, :_},
          {Config, :__eval__!, :_},
          {Config, :__import__!, :_},
          {Config.Reader, :_, :_},
          {Mix.Config, :_, :_},
          {Kernel.CLI, :_, :_},
          {Record, :extract, :_},
          {Record, :extract_all, :_},
          {Record.Extractor, :_, :_},
          {IEx, :_, :_},
          {IEx.Evaluator, :_, :_},
          {IEx.Helpers, :_, :_},
          {IEx.Pry, :_, :_},
          {IEx.Server, :_, :_},
          {:iex, :_, :_},
          {Mix.CLI, :_, :_},
          {Mix.Tasks.Eval, :_, :_},
          {Mix.Tasks.Run, :_, :_},
          {Mix.Tasks.Loadconfig, :_, :_},
          {Mix.Tasks.Profile.Cprof, :_, :_},
          {Mix.Tasks.Profile.Eprof, :_, :_},
          {Mix.Tasks.Profile.Fprof, :_, :_},
          {Mix.Tasks.Profile.Tprof, :_, :_},
          {Mix.Generator, :copy_template, :_},
          {Mix.Rebar, :_, :_},
          {Mix.Dep.Lock, :_, :_},
          {:release_handler, :_, :_},
          {:release_handler_1, :_, :_},
          {:c, :c, :_},
          {:c, :l, :_},
          {:c, :lc, :_},
          {:c, :lc_batch, :_},
          {:c, :lm, :_},
          {:c, :nc, :_},
          {:c, :nl, :_},
          {:c, :y, :_},
          {:make, :all, :_},
          {:make, :all_or_nothing, :_},
          {:make, :files, :_},
          {:cover, :compile_module, :_},
          {:cover, :compile_beam, :_},
          {:cover, :compile_directory, :_},
          {:cover, :compile_beam_directory, :_},
          {:elixir_erl_compiler, :_, :_},
          {:elixir, :tokens_to_quoted, :_},
          {Kernel.ParallelRequire, :_, :_},
          {Mix, :install, :_},
          {Mix.Project, :in_project, :_},
          {Mix.Local.Installer, :_, :_},
          {Mix.Tasks.Archive.Install, :_, :_},
          {Mix.Tasks.Escript.Install, :_, :_},
          {Mix.Tasks.Test, :_, :_},
          {Mix.Compilers.Test, :_, :_},
          {:erlang, :load_nif, 2},
          {:erl_ddll, :_, :_},
          {:code, :add_path, :_},
          {:code, :add_patha, :_},
          {:code, :add_pathz, :_},
          {:code, :add_paths, :_},
          {:code, :add_pathsa, :_},
          {:code, :add_pathsz, :_},
          {:code, :set_path, :_},
          {:code, :replace_path, :_},
          {Code, :prepend_path, :_},
          {Code, :prepend_paths, :_},
          {Code, :append_path, :_},
          {Code, :append_paths, :_},
          {Mix, :ensure_application!, :_},
          {:epp_dodger, :_, :_},
          {Mix.Task, :run, :_},
          {:code, :del_path, :_},
          {:code, :del_paths, :_},
          {Code, :delete_path, :_},
          {Code, :delete_paths, :_},
          {:erl_prim_loader, :set_path, :_},
          {:erl_prim_loader, :set_primary_archive, :_},
          {:code_server, :_, :_},
          {:erts_internal, :prepare_loading, :_},
          {:init, :make_permanent, :_},
          {:init, :restart, :_},
          {:error_handler, :breakpoint, :_},
          {:int, :i, :_},
          {:int, :ni, :_},
          {:int, :eval, :_},
          {:int, :meta, :_},
          {:i, :ii, :_},
          {:i, :ini, :_},
          {:debugger, :quick, :_},
          {:debugger, :start, :_},
          {:dbg_icmd, :eval, :_},
          {:dbg_icmd, :cmd, :_},
          {:dbg_icmd, :handle_msg, :_},
          {:dbg_ieval, :eval, :_},
          {:dbg_ieval, :eval_expr, :_},
          {:dbg_iserver, :call, :_},
          {:dbg_iserver, :safe_call, :_},
          {:dbg_iserver, :handle_call, :_},
          {:dbg_iload, :load_mod, :_},
          {:dbg_debugged, :eval, :_},
          {Mix.Tasks.Format, :formatter_for_file, :_},
          {Mix.Tasks.Help, :run, :_},
          {Mix.Compilers.Erlang, :ensure_application!, 2},
          {Mix.Tasks.Test.Coverage, :start, 2},
          {Mix.Dep, :in_dependency, 3},
          {ExUnit.Diff, :compute, 3},
          {Mix.Local, :append_paths, 0},
          {Mix.Local, :append_archives, 0},
          {Mix.Local, :remove_paths, 0},
          {Mix.Local, :remove_archives, 0},
          {Mix.Phoenix, :eval_from, 3},
          {Mix.Phoenix, :copy_from, 4},
          {Mix.Phoenix.Context, :new, :_},
          {Mix.Phoenix.Schema, :new, 4},
          {Mix.Tasks.Phx.Server, :run, 1},
          {Mix.Tasks.Phx.Routes, :run, :_},
          {Mix.Tasks.Phx.Gen.Context, :build, 1},
          {Mix.Tasks.Phx.Gen.Context, :build, 2},
          {Mix.Tasks.Phx.Gen.Context, :run, 1},
          {Mix.Tasks.Phx.Gen.Context, :copy_new_files, 3},
          {Mix.Tasks.Phx.Gen.Context, :ensure_context_file_exists, 3},
          {Mix.Tasks.Phx.Gen.Context, :ensure_test_file_exists, 3},
          {Mix.Tasks.Phx.Gen.Context, :ensure_test_fixtures_file_exists, 3},
          {Mix.Tasks.Phx.Gen.Embedded, :build, 1},
          {Mix.Tasks.Phx.Gen.Embedded, :run, 1},
          {Mix.Tasks.Phx.Gen.Embedded, :copy_new_files, 3},
          {Mix.Tasks.Phx.Gen.Live, :run, 1},
          {Mix.Tasks.Phx.Gen.Presence, :run, 1},
          {Mix.Tasks.Phx.Gen.Notifier, :build, 1},
          {Mix.Tasks.Phx.Gen.Notifier, :build, 2},
          {Mix.Tasks.Phx.Gen.Notifier, :run, 1},
          {Mix.Tasks.Phx.Gen.Schema, :build, 2},
          {Mix.Tasks.Phx.Gen.Schema, :build, 3},
          {Mix.Tasks.Phx.Gen.Schema, :copy_new_files, 3},
          {Mix.Tasks.Phx.Gen.Schema, :run, 1},
          {Mix.Tasks.Phx.Gen.Auth, :run, 1},
          {Mix.Tasks.Phx.Gen.Auth, :run, 2},
          {Mix.Tasks.Phx.Gen.Json, :run, 1},
          {Mix.Tasks.Phx.Gen.Json, :copy_new_files, 3},
          {Mix.Tasks.Phx.Gen.Html, :run, 1},
          {Mix.Tasks.Phx.Gen.Html, :copy_new_files, 3},
          {Mix.Tasks.Phx.Gen.Channel, :run, 1},
          {Mix.Tasks.Phx.Gen.Socket, :run, 1},
          {Mix.Tasks.Phx.Gen.Release, :run, 1},
          {Phoenix.LiveView.TagEngine.Parser, :tokenize, 2},
          {Phoenix.LiveView.TagEngine.Parser, :parse, :_},
          {Phoenix.LiveView.TagEngine.Parser, :parse!, :_},
          {Phoenix.LiveView.HTMLFormatter, :format, 2},
          {Phoenix.Router.Helpers, :define, 2},
          {ExUnit.AssertionError, :message, 1},
          {ExUnit.Formatter, :format_assertion_error, 1},
          {ExUnit.Formatter, :format_assertion_diff, 4},
          {ExUnit.Formatter, :format_test_failure, 5},
          {ExUnit.Formatter, :format_test_case_failure, 5},
          {ExUnit.Formatter, :format_test_all_failure, 5},
          {ExUnit.CLIFormatter, :handle_cast, 2},
          {Mix.Task, :rerun, 1},
          {Mix.Task, :rerun, 2},
          {Mix.Task, :run_in_apps, 2},
          {Mix.Task, :run_in_apps, 3},
          {Mix.Tasks.Format, :run, 1},
          {Mix.Tasks.Format, :formatter_opts_for_file, 1},
          {Mix.Tasks.Format, :formatter_opts_for_file, 2},
          {Mix.Dep, :in_dependency, 2},
          {Mix.Dep.Loader, :load, 3}
        ])

  @aliases for name <- @names, match?("Elixir." <> _, Atom.to_string(name)), do: inspect(name)

  @mfa_pairs (for {module, function, _arity} <- @mfas do
                {inspect(module), if(function == :_, do: :_, else: Atom.to_string(function))}
              end)

  @whole_mfa_modules for {module, :_, :_} <- @mfas, do: inspect(module)
  @whole_modules Enum.uniq(@aliases ++ @whole_mfa_modules)
  @tier_modules @mfa_pairs |> Enum.map(&elem(&1, 0)) |> Enum.uniq()

  def banned_names, do: @names

  def banned_mfas, do: @mfas

  @impl Credo.Check
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{line: nil, aliases: %{}})
    Credo.Code.prewalk(source_file, &walk/2, ctx).issues
  end

  defp walk({:__aliases__, meta, _parts} = ast, ctx) do
    ctx = track(ctx, meta)
    name = module_name(ast, ctx.aliases)
    if name in @whole_modules, do: {ast, flag(ctx, name)}, else: {ast, ctx}
  end

  defp walk({{:., _, [module, function]}, meta, args} = ast, ctx) when is_list(args) do
    ctx = track(ctx, meta)
    ctx = flag_remote_call(ctx, module, function)
    {ast, flag_pairs(ctx, args)}
  end

  defp walk({:., meta, [module, function]}, ctx) do
    ctx = track(ctx, meta)
    ctx = if function in @names, do: flag(ctx, function), else: ctx
    {{:., meta, [module, nil]}, ctx}
  end

  defp walk({name, meta, args} = ast, ctx)
       when name in [:alias, :require] and is_list(args) do
    ctx = track(ctx, meta)
    {ast, record_alias(ctx, args)}
  end

  defp walk({:import, meta, [module | _]} = ast, ctx) do
    ctx = track(ctx, meta)
    name = module_name(module, ctx.aliases)
    if name in @tier_modules, do: {ast, flag(ctx, name)}, else: {ast, ctx}
  end

  defp walk({:{}, meta, elems} = ast, ctx) do
    ctx = track(ctx, meta)
    {ast, flag_pairs(ctx, elems)}
  end

  defp walk({name, meta, args} = ast, ctx) when is_atom(name) and is_list(args) do
    ctx = track(ctx, meta)
    ctx = if name in @names, do: flag(ctx, name), else: ctx
    {ast, flag_pairs(ctx, args)}
  end

  defp walk({_, meta, _} = ast, ctx) when is_list(meta), do: {ast, track(ctx, meta)}

  defp walk({module, function} = ast, ctx) do
    {ast, flag_literal_pair(ctx, module, function)}
  end

  defp walk(nodes, ctx) when is_list(nodes), do: {nodes, flag_pairs(ctx, nodes)}

  defp walk(atom, ctx) when is_atom(atom) and atom in @names, do: {atom, flag(ctx, atom)}

  defp walk(atom, ctx) when is_atom(atom) do
    name = inspect(atom)
    if name in @whole_modules, do: {atom, flag(ctx, name)}, else: {atom, ctx}
  end

  defp walk(ast, ctx), do: {ast, ctx}

  defp track(ctx, meta), do: %{ctx | line: meta[:line] || ctx.line}

  defp flag_remote_call(ctx, module, function) when is_atom(function) do
    name = module_name(module, ctx.aliases)

    if name in @whole_modules or tier_pair?(name, function),
      do: flag(ctx, "#{name}.#{function}"),
      else: ctx
  end

  defp flag_remote_call(ctx, _module, _function), do: ctx

  defp flag_pairs(ctx, nodes) do
    nodes
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(ctx, &flag_pair/2)
  end

  defp flag_pair([module, function], ctx) do
    case literal_module_name(module, ctx.aliases) do
      nil -> ctx
      name -> flag_module_or_pair(ctx, name, function)
    end
  end

  defp flag_literal_pair(ctx, module, function) do
    case literal_module_name(module, ctx.aliases) do
      nil -> ctx
      name -> flag_module_or_pair(ctx, name, function)
    end
  end

  defp flag_module_or_pair(ctx, module, function) do
    cond do
      module in @whole_modules -> flag(ctx, module)
      tier_pair?(module, function) -> flag(ctx, "#{module}.#{function}")
      true -> ctx
    end
  end

  defp literal_module_name({:__aliases__, _, _} = ast, aliases), do: module_name(ast, aliases)
  defp literal_module_name(module, _aliases) when is_atom(module), do: inspect(module)
  defp literal_module_name(_module, _aliases), do: nil

  defp module_name({:__aliases__, _, [:"Elixir" | parts]}, _aliases),
    do: Enum.map_join(parts, ".", &alias_segment/1)

  defp module_name({:__aliases__, _, parts}, aliases) do
    name = Enum.map_join(parts, ".", &alias_segment/1)
    expand_alias(name, aliases)
  end

  defp module_name(module, _aliases) when is_atom(module), do: inspect(module)
  defp module_name(_module, _aliases), do: nil

  defp alias_segment({:__MODULE__, _, _}), do: "__MODULE__"
  defp alias_segment(segment) when is_atom(segment), do: Atom.to_string(segment)
  defp alias_segment(segment), do: Macro.to_string(segment)

  defp expand_alias(name, aliases) do
    case Enum.find(aliases, fn {alias_name, _target} ->
           name == alias_name or String.starts_with?(name, alias_name <> ".")
         end) do
      {alias_name, target} -> String.replace_prefix(name, alias_name, target)
      nil -> name
    end
  end

  defp tier_pair?(module, function) when is_atom(function) do
    pair = {module, Atom.to_string(function)}

    Enum.any?(@mfa_pairs, fn {tier_module, tier_function} ->
      tier_module == module and (tier_function == :_ or {tier_module, tier_function} == pair)
    end)
  end

  defp tier_pair?(_module, _function), do: false

  defp record_alias(ctx, args) do
    {target, opts} =
      case args do
        [target, opts] when is_list(opts) -> {target, opts}
        [target] -> {target, []}
      end

    explicit_alias = Keyword.get(opts, :as)
    mappings = alias_mappings(target, explicit_alias, ctx.aliases)
    %{ctx | aliases: Map.merge(ctx.aliases, mappings)}
  end

  defp alias_mappings({{:., _, [base, :{}]}, _, targets}, _explicit_alias, aliases) do
    base_name = module_name(base, aliases)

    Map.new(targets, fn target ->
      target_name = module_name(target, %{})
      full_name = "#{base_name}.#{target_name}"
      {last_module_segment(target_name), full_name}
    end)
  end

  defp alias_mappings(target, explicit_alias, aliases) do
    target_name = module_name(target, aliases)

    short_name =
      if explicit_alias, do: alias_name(explicit_alias), else: last_module_segment(target_name)

    %{short_name => target_name}
  end

  defp alias_name({:__aliases__, _, parts}), do: Enum.join(parts, ".")
  defp alias_name(name) when is_atom(name), do: inspect(name)

  defp last_module_segment(name) do
    name
    |> String.split(".")
    |> List.last()
  end

  defp flag(ctx, name) do
    trigger = if is_atom(name), do: inspect(name), else: name

    put_issue(
      ctx,
      format_issue(ctx,
        message: "`#{trigger}` is banned in Fablebook (ADR 0004, ADR 0018).",
        trigger: trigger,
        line_no: ctx.line
      )
    )
  end
end
