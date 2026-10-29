defmodule Fablebook.GuardFixture.ComputedCompile do
  def run(fun, args), do: apply(:compile, fun, args)
end
