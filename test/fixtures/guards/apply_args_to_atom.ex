defmodule Fablebook.GuardFixture.ApplyArgsToAtom do
  def run(args), do: apply(String, :to_atom, args)
end
