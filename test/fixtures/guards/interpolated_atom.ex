defmodule Fablebook.GuardFixture.InterpolatedAtom do
  def run(name), do: :"event_#{name}"
end
