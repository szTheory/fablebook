defmodule Fablebook.GuardFixture.Capture do
  def run(source), do: (&Code.eval_string/1).(source)
end
