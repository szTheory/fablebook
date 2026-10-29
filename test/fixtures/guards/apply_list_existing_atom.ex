defmodule Fablebook.GuardFixture.ApplyListExistingAtom do
  def run(name), do: apply(List, :to_existing_atom, [name])
end
