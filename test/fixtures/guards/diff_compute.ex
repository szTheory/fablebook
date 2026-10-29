defmodule Fablebook.GuardFixture.DiffCompute do
  def run(left, right, context), do: ExUnit.Diff.compute(left, right, context)
end
