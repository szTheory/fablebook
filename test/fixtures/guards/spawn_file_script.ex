defmodule Fablebook.GuardFixture.SpawnFileScript do
  def run(path), do: spawn(:file, :script, [path])
end
