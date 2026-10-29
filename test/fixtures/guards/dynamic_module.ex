defmodule Fablebook.GuardFixture.DynamicModule do
  def run(name), do: Module.concat([Fablebook, name])
end
