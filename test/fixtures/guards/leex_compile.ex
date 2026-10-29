defmodule Fablebook.GuardFixture.LeexCompile do
  def run(input, output, options), do: :leex.compile(input, output, options)
end
