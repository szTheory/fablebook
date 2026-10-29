defmodule Fablebook.GuardFixture.LoadNif do
  def run(path, info), do: :erlang.load_nif(path, info)
end
