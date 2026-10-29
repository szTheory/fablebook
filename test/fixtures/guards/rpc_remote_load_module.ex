defmodule Fablebook.GuardFixture.RpcRemoteLoadModule do
  def run(module, binary), do: :rpc.call(:remote, :erlang, :load_module, [module, binary])
end
