defmodule Fablebook.GuardFixture.ApplyConcat do
  def run(parts), do: apply(Module, :concat, parts)
end
