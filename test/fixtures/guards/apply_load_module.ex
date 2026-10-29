defmodule Fablebook.GuardFixture.ApplyLoadModule do
  def run(args), do: apply(:erlang, :load_module, args)
end
