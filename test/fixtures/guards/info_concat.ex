defmodule Fablebook.GuardFixture.InfoConcat do
  def __info__(base, parts), do: apply(Module, :concat, [base | parts])
end
