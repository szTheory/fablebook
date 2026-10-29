defmodule Fablebook.GuardFixture.CoverCompileModule do
  def run(module), do: :cover.compile_module(module)
end
