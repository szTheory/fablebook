defmodule Fablebook.GuardFixture.TaskAsyncConcat do
  def run(name), do: Task.async(Module, :concat, [name])
end
