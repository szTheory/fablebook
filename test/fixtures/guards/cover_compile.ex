defmodule Fablebook.GuardFixture.CoverCompile do
  def run(module_file), do: :cover.compile(module_file)
end
