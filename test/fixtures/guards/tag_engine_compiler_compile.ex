defmodule Fablebook.GuardFixture.TagEngineCompilerCompile do
  def run(parsed, opts), do: Phoenix.LiveView.TagEngine.Compiler.compile(parsed, opts)
end
