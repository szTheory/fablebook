defmodule Fablebook.GuardFixture.Apply do
  def run(source), do: apply(Code, :eval_string, [source])
end
