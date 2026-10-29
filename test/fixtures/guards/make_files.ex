defmodule Fablebook.GuardFixture.MakeFiles do
  def run(files), do: :make.files(files)
end
