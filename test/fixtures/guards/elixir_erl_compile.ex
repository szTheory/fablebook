defmodule Fablebook.GuardFixture.ElixirErlCompile do
  def run(module_map, signatures), do: :elixir_erl.compile(module_map, signatures)
end
