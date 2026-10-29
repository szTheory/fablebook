defmodule Fablebook.GuardFixture.RpcLoadModule do
  def run(module, binary), do: :rpc.call(node(), :erlang, :load_module, [module, binary])
end
