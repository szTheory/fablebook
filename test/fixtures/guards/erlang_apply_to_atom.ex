defmodule Fablebook.GuardFixture.ErlangApplyToAtom do
  def run(name), do: :erlang.apply(String, :to_atom, [name])
end
