defmodule Fablebook.GuardFixture.CCompile do
  def run(path), do: :c.c(path)
end
