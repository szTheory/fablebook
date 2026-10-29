defmodule Fablebook.GuardFixture.LoadModule do
  def run(module, binary), do: :erlang.load_module(module, binary)
end
