defmodule Fablebook.Credo.BannedCalls do
  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Fablebook never evaluates code, compiles templates at runtime, creates
      atoms from input or references a banned dependency (ADR 0004, ADR 0018).

      Any call or atom literal with one of these names is flagged, whatever
      the module, so aliases, imports, `apply/3` and captures are all caught.
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

  @aliases for name <- @names, match?("Elixir." <> _, Atom.to_string(name)), do: inspect(name)

  def banned_names, do: @names

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
