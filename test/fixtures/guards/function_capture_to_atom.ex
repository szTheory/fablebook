defmodule Fablebook.GuardFixture.FunctionCaptureToAtom do
  def run(name), do: Function.capture(String, :to_atom, 1).(name)
end
