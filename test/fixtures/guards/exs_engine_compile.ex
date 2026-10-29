defmodule Fablebook.GuardFixture.ExsEngineCompile do
  def run(path, name), do: Phoenix.Template.ExsEngine.compile(path, name)
end
