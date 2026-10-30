defmodule Fablebook.Test.BeamWalker do
  @moduledoc false

  def scan(beam_path) do
    path = to_charlist(beam_path)

    case :beam_lib.chunks(path, [:debug_info]) do
      {:ok, {_module, [debug_info: {:debug_info_v1, _backend, :none}]}} ->
        {:error, :no_debug_info}

      {:ok, {module, [debug_info: {:debug_info_v1, backend, data}]}} ->
        scan_debug_info(path, module, backend, data)

      {:error, :beam_lib, {:missing_chunk, _, _}} ->
        {:error, :no_debug_info}

      {:error, :beam_lib, reason} ->
        {:error, reason}
    end
  end

  defp scan_debug_info(path, module, backend, data) do
    with {:ok, forms} <- backend.debug_info(:erlang_v1, module, data, []) do
      {:ok, {^module, [imports: imports, compile_info: info]}} =
        :beam_lib.chunks(path, [:imports, :compile_info])

      code = function_code(forms)
      function_mfas = for {:function, _, name, arity, _} <- code, do: {module, name, arity}
      edges = Enum.flat_map(code, &function_edges(module, &1))

      {:ok,
       %{
         module: module,
         source: to_string(info[:source]),
         atoms: atoms(forms, MapSet.new()),
         mfas: imports,
         function_mfas: function_mfas,
         function_count: length(function_mfas),
         edges: edges,
         pairs: pairs(code, MapSet.new()),
         literals: literals(code, MapSet.new())
       }}
    end
  end

  defp function_code(forms),
    do: for({:function, _, name, arity, _} = f <- forms, {name, arity} != {:__info__, 1}, do: f)

  defp function_edges(module, {:function, _, name, arity, clauses}) do
    caller = {module, name, arity}
    for callee <- callees(module, clauses, []) |> Enum.uniq(), do: {caller, callee}
  end

  defp callees(module, [{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: callees(module, [next | rest], [{m, f} | acc])

  defp callees(module, [head | tail], acc), do: callees(module, tail, callees(module, head, acc))

  defp callees(module, {:call, _, {:atom, _, function}, args}, acc),
    do: callees(module, args, [{module, function} | acc])

  defp callees(module, {:fun, _, {:function, function_name, arity}}, acc)
       when is_atom(function_name) and is_integer(arity),
       do: [{module, function_name} | acc]

  defp callees(module, tuple, acc) when is_tuple(tuple),
    do: callees(module, Tuple.to_list(tuple), acc)

  defp callees(_module, _other, acc), do: acc

  defp atoms(term, acc) when is_atom(term), do: MapSet.put(acc, term)
  defp atoms(term, acc) when is_tuple(term), do: atoms(Tuple.to_list(term), acc)
  defp atoms(term, acc) when is_list(term), do: Enum.reduce(term, acc, &atoms/2)

  defp atoms(term, acc) when is_map(term),
    do: Enum.reduce(term, acc, fn {k, v}, acc -> atoms(v, atoms(k, acc)) end)

  defp atoms(_term, acc), do: acc

  defp pairs([{:atom, _, m}, {:atom, _, f} = next | rest], acc),
    do: pairs([next | rest], MapSet.put(acc, {m, f}))

  defp pairs([head | tail], acc), do: pairs(tail, pairs(head, acc))
  defp pairs(term, acc) when is_tuple(term), do: pairs(Tuple.to_list(term), acc)
  defp pairs(_term, acc), do: acc

  defp literals({:atom, _, atom}, acc), do: MapSet.put(acc, atom)

  defp literals({:call, _, {:remote, _, module, {:atom, _, _}}, args}, acc),
    do: literals(args, literals(module, acc))

  defp literals({:call, _, {:atom, _, _}, args}, acc), do: literals(args, acc)

  defp literals({:fun, _, {:function, module, {:atom, _, _}, arity}}, acc),
    do: literals(arity, literals(module, acc))

  defp literals(term, acc) when is_tuple(term), do: literals(Tuple.to_list(term), acc)
  defp literals(term, acc) when is_list(term), do: Enum.reduce(term, acc, &literals/2)
  defp literals(_term, acc), do: acc
end
