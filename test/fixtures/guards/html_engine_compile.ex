defmodule Fablebook.GuardFixture.HtmlEngineCompile do
  def run(path, name), do: Phoenix.LiveView.HTMLEngine.compile(path, name)
end
