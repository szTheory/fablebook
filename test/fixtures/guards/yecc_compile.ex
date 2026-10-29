defmodule Fablebook.GuardFixture.YeccCompile do
  def run(input, output, options), do: :yecc.compile(input, output, options)
end
