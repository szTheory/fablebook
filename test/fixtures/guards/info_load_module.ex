defmodule Fablebook.GuardFixture.InfoLoadModule do
  def __info__(m, args), do: apply(:erlang, :load_module, [m | args])
end
