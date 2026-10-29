defmodule Fablebook.Test.BeamWalker do
  @moduledoc false

  def scan(beam_path) do
    path = to_charlist(beam_path)

    case :beam_lib.chunks(path, [:debug_info]) do
      {:ok, {_module, [debug_info: {:debug_info_v1, _backend, :none}]}} ->
        {:error, :no_debug_info}

      {:ok, {module, [debug_info: {:debug_info_v1, backend, data}]}} ->
        with {:ok, forms} <- backend.debug_info(:erlang_v1, module, data, []) do
          {:ok, {^module, [imports: imports, compile_info: info]}} =
            :beam_lib.chunks(path, [:imports, :compile_info])

          code = function_code(forms)

          {:ok,
           %{
             module: module,
             source: to_string(info[:source]),
             atoms: atoms(forms, MapSet.new()),
             mfas: imports,
             pairs: pairs(code, MapSet.new()),
             literals: literals(code, MapSet.new())
           }}
        end

      {:error, :beam_lib, {:missing_chunk, _, _}} ->
        {:error, :no_debug_info}

      {:error, :beam_lib, reason} ->
        {:error, reason}
    end
  end

  defp function_code(forms),
    do: for({:function, _, name, arity, _} = f <- forms, {name, arity} != {:__info__, 1}, do: f)

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
