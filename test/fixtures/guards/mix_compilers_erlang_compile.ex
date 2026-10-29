defmodule Fablebook.GuardFixture.MixCompilersErlangCompile do
  def run(manifest, entries, callback),
    do: Mix.Compilers.Erlang.compile(manifest, entries, callback)
end
