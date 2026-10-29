defmodule Fablebook.GuardFixture.DepsCompileCompile do
  def run(deps), do: Mix.Tasks.Deps.Compile.compile(deps)
end
