defmodule Fablebook.GuardFixture.ErpcFileScript do
  def run(path), do: :erpc.call(node(), :file, :script, [path])
end
