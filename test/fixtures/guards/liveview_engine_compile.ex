defmodule Fablebook.GuardFixture.LiveviewEngineCompile do
  def run(path, name), do: Phoenix.LiveView.Engine.compile(path, name)
end
