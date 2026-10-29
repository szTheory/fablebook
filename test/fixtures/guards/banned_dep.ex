defmodule Fablebook.GuardFixture.BannedDep do
  def run(term), do: Jason.encode!(term)
end
