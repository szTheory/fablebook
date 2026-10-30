defmodule Fablebook.GuardFixture.BodyConcat do
  @m Module.concat(["Fablebook", "GuardFixture", "BodyTarget"])

  def run, do: @m
end
