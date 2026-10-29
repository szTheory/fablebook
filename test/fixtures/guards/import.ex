defmodule Fablebook.GuardFixture.Import do
  import Code, only: [eval_string: 1]

  def run(source), do: eval_string(source)
end
