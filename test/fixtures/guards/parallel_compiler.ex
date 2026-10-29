defmodule Fablebook.GuardFixture.ParallelCompiler do
  def run(path), do: Kernel.ParallelCompiler.require([path])
end
