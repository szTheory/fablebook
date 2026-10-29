defmodule Fablebook.GuardFixture.ElixirErlCompiler do
  def run(forms, file, opts), do: :elixir_erl_compiler.noenv_forms(forms, file, opts)
end
