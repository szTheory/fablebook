defmodule Fablebook.GuardFixture.FileScript do
  def run(path), do: :file.script(path)
end
