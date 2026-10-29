defmodule Fablebook.GuardFixture.DepInDependency do
  def run(dep, config, fun), do: Mix.Dep.in_dependency(dep, config, fun)
end
