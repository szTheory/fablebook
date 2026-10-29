defmodule Fablebook.GuardFixture.HelpApp do
  def run(name), do: Mix.Tasks.Help.run(["app:" <> name])
end
