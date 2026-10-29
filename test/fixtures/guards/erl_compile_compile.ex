defmodule Fablebook.GuardFixture.ErlCompileCompile do
  def run(args, cwd), do: :erl_compile.compile(args, cwd)
end
