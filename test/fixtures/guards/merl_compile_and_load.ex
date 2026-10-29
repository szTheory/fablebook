defmodule Fablebook.GuardFixture.MerlCompileAndLoad do
  def run(forms), do: :merl.compile_and_load(forms)
end
