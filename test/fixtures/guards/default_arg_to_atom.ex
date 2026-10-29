defmodule Fablebook.GuardFixture.DefaultArgToAtom do
  def run(name, fun \\ :to_atom), do: apply(String, fun, [name])
end
