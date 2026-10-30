defmodule Fablebook.GuardFixture.BodyScript do
  @r apply(:file, :script, ["nonexistent.exs"])

  def run, do: @r
end
