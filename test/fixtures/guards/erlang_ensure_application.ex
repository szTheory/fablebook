defmodule Fablebook.GuardFixture.ErlangEnsureApplication do
  def run(app, input), do: Mix.Compilers.Erlang.ensure_application!(app, input)
end
