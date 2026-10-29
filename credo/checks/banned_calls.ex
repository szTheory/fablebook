defmodule Fablebook.Credo.BannedCalls do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Fablebook never evaluates code, compiles templates at runtime, creates
      atoms from input or references a banned dependency (ADR 0004, ADR 0018).

      Any call or atom literal with one of these names is flagged, whatever
      the module. That covers aliases, imports, and `apply/3` or
      `Function.capture/3` with a literal function name.

      The compiled-BEAM guard in `test/contract/banned_calls_test.exs` checks
      the compiled code of each lib/ module (D-23). It matches direct remote
      calls. It also matches every place where a literal module atom is
      directly followed by a literal function atom in one argument list, tuple
      or map entry, anywhere in function code. That covers `apply/3`,
      `:erlang.apply/3`, `spawn/3`, `:erpc` and `:rpc` calls, `Task.async/3`,
      `Function.capture/3` at any arity, `{module, function}` and
      `{module, function, args}` tuples (also when a helper returns them or a
      module attribute holds them), `%{module => function}` entries and
      `[module: function]` keyword pairs. It also flags a literal reference to
      a module that is banned whole, and the banned names anywhere. The
      whole-module check ignores the name of a called or captured function, so
      `Regex.compile/1`, `:re.compile/2`, a local `compile/1` and
      `&Regex.compile/1` are not flagged. It still flags a wholly banned module
      named in any other position, such as `apply(:compile, fun, args)` or a
      keyword such as `[epp: 1]`. The pair check still flags data whose two
      adjacent atoms spell a banned call, such as `[io: :read]` or
      `[compile: true]`. `Regex.compile!/1` and a `~r` sigil are not flagged.
      The fix is a change in lib/, never an allowlist entry without an ADR.

      Neither static layer matches a module and function that are not
      adjacent literals in one list, tuple or map entry, unless the module is
      banned whole. That includes a module held in a variable or returned
      alone by a helper, a plain list such as `[:erlang, :load_module]`,
      separate map fields such as `%{m: :erlang, f: :load_module}`, and names
      passed in or computed at runtime. Nor does either layer match a dispatch
      by name inside OTP or Elixir, such as a Mix task run by its string name.
      The Phase 5 atom-count property and never-eval proof (ADR 0004) cover
      those. The tiers are not complete yet: a direct call that no tier lists
      to an eval, compile-and-load or native-load function, or to an
      atom-creating parser, such as `:qlc.string_to_handle/1`,
      `:erlang.load_nif/2` or `:epp_dodger.parse_file/1`, passes both layers
      until Phase 01.1.1 extends the tier.
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
        ])

  @aliases for name <- @names, match?("Elixir." <> _, Atom.to_string(name)), do: inspect(name)

  def banned_names, do: @names

  def banned_mfas, do: @mfas

  @impl Credo.Check
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{line: nil})
    Credo.Code.prewalk(source_file, &walk/2, ctx).issues
  end

  defp walk({:__aliases__, meta, _parts} = ast, ctx) do
    ctx = track(ctx, meta)
    name = Macro.to_string(ast)
    if name in @aliases, do: {ast, flag(ctx, name)}, else: {ast, ctx}
  end

  defp walk({name, meta, args} = ast, ctx) when is_atom(name) and is_list(args) do
    ctx = track(ctx, meta)
    if name in @names, do: {ast, flag(ctx, name)}, else: {ast, ctx}
  end

  defp walk({_, meta, _} = ast, ctx) when is_list(meta), do: {ast, track(ctx, meta)}

  defp walk(atom, ctx) when is_atom(atom) and atom in @names, do: {atom, flag(ctx, atom)}

  defp walk(ast, ctx), do: {ast, ctx}

  defp track(ctx, meta), do: %{ctx | line: meta[:line] || ctx.line}

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
