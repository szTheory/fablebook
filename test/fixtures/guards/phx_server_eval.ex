defmodule Fablebook.GuardFixture.PhxServerEval do
  def run(code), do: Mix.Tasks.Phx.Server.run(["-e", code])
end
