defmodule Fablebook.GuardFixture.CoverageStart do
  def run(path, opts), do: Mix.Tasks.Test.Coverage.start(path, opts)
end
