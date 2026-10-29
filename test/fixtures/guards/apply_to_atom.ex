defmodule Fablebook.GuardFixture.ApplyToAtom do
  def run(name), do: apply(String, :to_atom, [name])
end
