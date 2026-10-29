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

          {:ok,
           %{
             module: module,
             source: to_string(info[:source]),
             atoms: atoms(forms, MapSet.new()),
             mfas: imports
           }}
        end

      {:error, :beam_lib, {:missing_chunk, _, _}} ->
        {:error, :no_debug_info}

      {:error, :beam_lib, reason} ->
        {:error, reason}
    end
  end

  defp atoms(term, acc) when is_atom(term), do: MapSet.put(acc, term)
  defp atoms(term, acc) when is_tuple(term), do: atoms(Tuple.to_list(term), acc)
  defp atoms(term, acc) when is_list(term), do: Enum.reduce(term, acc, &atoms/2)

  defp atoms(term, acc) when is_map(term),
    do: Enum.reduce(term, acc, fn {k, v}, acc -> atoms(v, atoms(k, acc)) end)

  defp atoms(_term, acc), do: acc
end
