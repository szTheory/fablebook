defmodule OperatorHost.Layouts do
  use Phoenix.Component

  def root(assigns) do
    ~H"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={Plug.CSRFProtection.get_csrf_token()} />
        <link rel="icon" href="data:," />
        <.live_title default="Fablebook UI catalog" suffix=" — Fablebook">
          {assigns[:page_title]}
        </.live_title>
        <link rel="stylesheet" href="/assets/app.css" />
        <script defer src="/phoenix/phoenix.js"></script>
        <script defer src="/phoenix_live_view/phoenix_live_view.js"></script>
        <script defer src="/assets/app.js"></script>
      </head>
      <body data-operator-root>
        {@inner_content}
      </body>
    </html>
    """
  end
end

defmodule OperatorHost.ErrorHTML do
  use Phoenix.Component

  def render(template, _assigns) do
    assigns = %{status_message: Phoenix.Controller.status_message_from_template(template)}

    ~H"""
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@status_message} — Fablebook</title>
        <link rel="icon" href="data:," />
        <link rel="stylesheet" href="/assets/app.css" />
      </head>
      <body data-operator-root>
        <main class="unavailable-state">
          <h1>{@status_message}</h1>
          <a class="text-link" href="/">Return to the operator host</a>
        </main>
      </body>
    </html>
    """
  end
end

defmodule OperatorHost.SecurityHeaders do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    nonce = Base.url_encode64(:crypto.strong_rand_bytes(18), padding: false)

    conn
    |> put_resp_header(
      "content-security-policy",
      "default-src 'none'; base-uri 'self'; form-action 'self'; " <>
        "script-src 'self' 'nonce-#{nonce}'; style-src 'self' 'nonce-#{nonce}'; " <>
        "img-src 'self' data:; font-src 'self' data:; connect-src 'self' ws://127.0.0.1:* ws://localhost:*; " <>
        "frame-src 'self'; frame-ancestors 'self'; object-src 'none'"
    )
    |> put_resp_header("x-frame-options", "SAMEORIGIN")
    |> put_resp_header("x-content-type-options", "nosniff")
  end
end

defmodule OperatorHost.Home do
  @behaviour Plug

  import Plug.Conn

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    body = """
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Fablebook local host</title>
        <link rel="icon" href="data:,">
        <link rel="stylesheet" href="/assets/app.css">
      </head>
      <body>
        <main class="host-home" data-operator-root>
          <h1>Fablebook local host</h1>
          <p>Open the UI catalog to inspect the local operator Book.</p>
          <a class="primary-link" href="/admin/dev/fablebook">Open the UI catalog</a>
        </main>
      </body>
    </html>
    """

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, body)
  end
end

defmodule OperatorHost.Router do
  use Phoenix.Router, helpers: false

  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OperatorHost.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug OperatorHost.SecurityHeaders
  end

  scope "/", OperatorHost do
    pipe_through :browser
    get "/", Home, []
  end

  if Application.compile_env(:operator_host, :dev_routes, false) do
    scope "/admin/dev" do
      pipe_through :browser
      import Fablebook.Router
      fablebook "/fablebook", OperatorHost.Book
    end

    scope "/admin/dev/fablebook" do
      pipe_through :browser

      live_session :operator_book, session: %{"book" => OperatorHost.Book} do
        live "/book", Fablebook.BookLive, :unavailable
        live "/book/:book_id", Fablebook.BookLive, :book
        live "/book/*rest", Fablebook.BookLive, :unavailable
        live "/canvas", Fablebook.BookLive, :unavailable
        live "/canvas/:book_id/:story_id/:scenario_id", Fablebook.BookLive, :canvas
        live "/canvas/*rest", Fablebook.BookLive, :unavailable
      end
    end
  end
end

defmodule OperatorHost.Endpoint do
  use Phoenix.Endpoint, otp_app: :operator_host

  @session_options [
    store: :cookie,
    key: "_operator_host_key",
    signing_salt: "operator-host-session",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  plug Plug.Static, at: "/", from: :operator_host, only: ~w(assets)
  plug Plug.Static, at: "/phoenix", from: :phoenix, only: ~w(phoenix.js)

  plug Plug.Static,
    at: "/phoenix_live_view",
    from: :phoenix_live_view,
    only: ~w(phoenix_live_view.js)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers, parsers: [:urlencoded, :multipart], pass: ["*/*"]

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug OperatorHost.Router
end

defmodule OperatorHost.Application do
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: OperatorHost.PubSub},
      OperatorHost.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: OperatorHost.Supervisor)
  end

  @impl Application
  def config_change(changed, _new, removed) do
    OperatorHost.Endpoint.config_change(changed, removed)
    :ok
  end
end
