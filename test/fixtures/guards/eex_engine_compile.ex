defmodule Fablebook.GuardFixture.EexEngineCompile do
  def run(path, name), do: Phoenix.Template.EExEngine.compile(path, name)
end
