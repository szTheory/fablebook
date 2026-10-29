defmodule Fablebook.GuardFixture.EexCompilerCompile do
  def run(tokens, source, opts), do: EEx.Compiler.compile(tokens, source, opts)
end
