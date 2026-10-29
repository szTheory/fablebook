defmodule Fablebook.GuardFixture.ErlDdllLoad do
  def run(dir, name), do: :erl_ddll.load(dir, name)
end
