[tier_file, exclusions_file] =
  case System.argv() do
    [t, e] ->
      [t, e]

    [] ->
      [
        "test/contract/banned_calls_test.exs",
        Path.join(__DIR__, "01.1.1-tier-sweep-exclusions.exs")
      ]
  end

elixir_apps = [:elixir, :eex, :mix, :iex, :logger, :ex_unit]
for app <- elixir_apps, do: Application.load(app)

otp_apps =
  ~w(kernel stdlib compiler erts crypto public_key asn1 ssl inets syntax_tools tools parsetools
              runtime_tools sasl dialyzer xmerl os_mon)

otp_lib = to_string(:code.lib_dir())
installed = otp_lib |> File.ls!() |> Enum.filter(&File.dir?(Path.join([otp_lib, &1, "ebin"])))
app_of = fn dir -> String.replace(dir, ~r/-[0-9][0-9.]*$/, "") end
{in_scope, out_of_scope} = Enum.split_with(installed, &(app_of.(&1) in otp_apps))

dirs =
  Enum.map(in_scope, &Path.join([otp_lib, &1, "ebin"])) ++
    for app <- elixir_apps, do: app |> :code.lib_dir() |> to_string() |> Path.join("ebin")

{:ok, _} = :xref.start(:sweep, xref_mode: :functions)
:ok = :xref.set_default(:sweep, warnings: false, verbose: false, builtins: true)
for dir <- dirs, do: :xref.add_directory(:sweep, to_charlist(dir))
{:ok, xref_edges} = :xref.q(:sweep, ~c"E")
{:ok, exported} = :xref.q(:sweep, ~c"X")
:xref.stop(:sweep)
exported = MapSet.new(exported)

defmodule Sweep.Forms do
  def edges(mod, {:function, _, name, arity, clauses}) do
    caller = {mod, name, arity}
    for callee <- callees(mod, clauses, []) |> Enum.uniq(), do: {caller, callee}
  end

  defp callees(mod, [{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: callees(mod, [next | rest], [{m, f} | acc])

  defp callees(mod, [h | t], acc), do: callees(mod, t, callees(mod, h, acc))

  defp callees(mod, {:call, _, {:atom, _, f}, args}, acc),
    do: callees(mod, args, [{mod, f} | acc])

  defp callees(mod, {:fun, _, {:function, f, a}}, acc) when is_atom(f) and is_integer(a),
    do: [{mod, f} | acc]

  defp callees(mod, t, acc) when is_tuple(t), do: callees(mod, Tuple.to_list(t), acc)
  defp callees(_mod, _, acc), do: acc
end

{form_edges, no_debug} =
  for dir <- dirs, file <- File.ls!(dir), String.ends_with?(file, ".beam"), reduce: {[], []} do
    {edges, missing} ->
      path = to_charlist(Path.join(dir, file))

      with {:ok, {mod, [debug_info: {:debug_info_v1, backend, data}]}} when data != :none <-
             :beam_lib.chunks(path, [:debug_info]),
           {:ok, forms} <- backend.debug_info(:erlang_v1, mod, data, []) do
        {for(
           {:function, _, n, _, _} = f <- forms,
           n != :__info__,
           e <- Sweep.Forms.edges(mod, f),
           do: e
         ) ++ edges, missing}
      else
        _ -> {edges, [file | missing]}
      end
  end

eval_funs = [:eval_str, :expr, :expr_list, :exprs, :match_clause]

sinks =
  [
    {:erlang, :load_module},
    {:erlang, :prepare_loading},
    {:erlang, :load_nif},
    {:erl_ddll, :try_load}
  ] ++
    for f <- eval_funs, do: {:erl_eval, f}

{:ok, ast} = tier_file |> File.read!() |> Code.string_to_quoted()

attr = fn name ->
  {_, found} =
    Macro.prewalk(ast, nil, fn
      {:@, _, [{^name, _, [list]}]} = node, nil -> {node, list}
      node, acc -> {node, acc}
    end)

  found |> Code.eval_quoted() |> elem(0)
end

mfa_tier = attr.(:mfa_tier)
atom_tier = attr.(:atom_tier)

covered? = fn {m, f, a} ->
  f in atom_tier or m in atom_tier or
    Enum.any?(mfa_tier, fn {pm, pf, pa} -> pm == m and pf in [:_, f] and pa in [:_, a] end)
end

parse_only? = fn {m, f, _} ->
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
  ] or
    String.starts_with?(to_string(f), "string_to_quoted") or
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
    (m == :erl_eval and f not in eval_funs) or
    {m, f} in [
      {Code, :format_string!},
      {Code, :format_file!},
      {:elixir, :string_to_tokens},
      {:elixir, :tokens_to_quoted}
    ]
end

tier_sinks =
  for {m, f, _} = mfa <- exported, covered?.(mfa), not parse_only?.(mfa), uniq: true, do: {m, f}

sinks = sinks ++ tier_sinks

barrier? = fn {m, f} ->
  (m == :code and f in [:ensure_loaded, :load_file, :ensure_modules_loaded]) or
    m in [:code_server, :error_handler, :erl_prim_loader, :init, :erl_lint]
end

all_edges = form_edges ++ for({caller, {m, f, _}} <- xref_edges, do: {caller, {m, f}})

reverse =
  Enum.reduce(all_edges, %{}, fn {caller, callee}, acc ->
    if barrier?.(callee), do: acc, else: Map.update(acc, callee, [caller], &[caller | &1])
  end)

walk = fn walk, queue, parent, reached ->
  case :queue.out(queue) do
    {:empty, _} ->
      {reached, parent}

    {{:value, key}, q} ->
      callers = Map.get(reverse, key, [])

      new_keys =
        callers
        |> Enum.map(fn {m, f, _} -> {m, f} end)
        |> Enum.uniq()
        |> Enum.reject(&Map.has_key?(parent, &1))

      walk.(
        walk,
        Enum.reduce(new_keys, q, &:queue.in/2),
        Enum.reduce(new_keys, parent, &Map.put(&2, &1, key)),
        Enum.reduce(callers, reached, &MapSet.put(&2, &1))
      )
  end
end

{reached, parent} = walk.(walk, :queue.from_list(sinks), Map.new(sinks, &{&1, nil}), MapSet.new())

witness = fn witness, key ->
  if parent[key], do: [key | witness.(witness, parent[key])], else: [key]
end

static =
  reached
  |> Enum.filter(&MapSet.member?(exported, &1))
  |> Enum.reject(fn {m, f, _} -> m in [:erlang, :erl_eval, :erl_ddll] or f == :module_info end)

excluded = exclusions_file |> Code.eval_file() |> elem(0)

reason = fn {m, f, _} ->
  Enum.find_value(excluded, fn
    {{^m, fs}, why} when is_list(fs) -> if f in fs, do: why
    {^m, why} -> why
    {{:prefix, p}, why} -> if String.starts_with?(inspect(m), p), do: why
    {{:fun_prefix, p}, why} -> if String.starts_with?(to_string(f), p), do: why
    _ -> nil
  end)
end

rows = for mfa <- static, not covered?.(mfa), do: {mfa, reason.(mfa)}
undisposed = for {mfa, nil} <- rows, do: mfa

mode = System.get_env("SWEEP_MODE", "undisposed")

for {m, group} <- rows |> Enum.group_by(fn {{m, _, _}, _} -> m end) |> Enum.sort(),
    mode == "all" or Enum.any?(group, &(elem(&1, 1) == nil)) do
  fs =
    group
    |> Enum.map(fn {{_, f, a}, why} -> "#{f}/#{a}#{if why, do: "", else: "!"}" end)
    |> Enum.sort()

  whys = group |> Enum.map(&elem(&1, 1)) |> Enum.uniq() |> Enum.map(&inspect/1) |> Enum.join(",")
  IO.puts("#{inspect(m)}\t#{whys}\t#{Enum.join(fs, " ")}")
end

IO.puts(
  "out of scope (not on a Mix dev code path): #{out_of_scope |> Enum.map(app_of) |> Enum.sort() |> Enum.join(" ")}"
)

IO.puts(
  "elixir #{System.version()} otp #{:erlang.system_info(:otp_release)}: beams_without_debug_info=#{length(no_debug)} " <>
    "reached=#{length(static)} covered=#{Enum.count(static, covered?)} excluded=#{length(rows) - length(undisposed)} " <>
    "undisposed=#{length(undisposed)}"
)

if mode == "witness" do
  for {{m, f, _}, why} <- rows do
    chain =
      witness.(witness, {m, f})
      |> Enum.map(fn {wm, wf} -> "#{inspect(wm)}.#{wf}" end)
      |> Enum.take(-4)

    IO.puts("W\t#{inspect(m)}.#{f}\t#{inspect(why)}\t#{Enum.join(chain, " > ")}")
  end
end

if undisposed != [], do: System.halt(1)
