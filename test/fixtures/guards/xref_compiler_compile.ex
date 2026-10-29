defmodule Fablebook.GuardFixture.XrefCompilerCompile do
  def run(query, table), do: :xref_compiler.compile(query, table)
end
