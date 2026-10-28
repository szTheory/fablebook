defmodule Fablebook.Placeholder do
  @moduledoc false
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(book), do: book

  @impl Plug
  def call(conn, _book) do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(200, "Fablebook is installed. The workbench is not released yet.")
  end
end
