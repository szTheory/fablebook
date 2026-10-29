defmodule Fablebook.GuardFixture.MerlCompile do
  def run(forms), do: :merl.compile(forms)
end
