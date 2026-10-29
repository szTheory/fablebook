defmodule Fablebook.GuardFixture.Alias do
  alias Code, as: Evaluator

  def run(source), do: Evaluator.eval_string(source)
end
