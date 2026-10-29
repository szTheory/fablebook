defmodule Fablebook.GuardFixture.LoggerFormatterCompile do
  def run(pattern), do: Logger.Formatter.compile(pattern)
end
