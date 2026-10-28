defmodule GuardHost.Ok do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _opts), do: Plug.Conn.send_resp(conn, 200, "ok")
end
