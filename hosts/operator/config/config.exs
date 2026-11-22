import Config

config :operator_host,
  dev_routes: config_env() in [:dev, :test]

config :operator_host, OperatorHost.Endpoint,
  url: [host: "127.0.0.1"],
  render_errors: [formats: [html: OperatorHost.ErrorHTML], layout: false],
  pubsub_server: OperatorHost.PubSub,
  live_view: [signing_salt: "fablebook-operator-live-view"],
  server: false

if config_env() == :dev do
  port =
    case Integer.parse(System.get_env("FABLEBOOK_OPERATOR_PORT", "4002")) do
      {port, ""} when port in 1..65_535 -> port
      _ -> raise "FABLEBOOK_OPERATOR_PORT must be an integer from 1 to 65535"
    end

  config :operator_host, OperatorHost.Endpoint,
    adapter: Bandit.PhoenixAdapter,
    server: System.get_env("FABLEBOOK_OPERATOR_SERVER") == "1",
    http: [ip: {127, 0, 0, 1}, port: port]
end

if config_env() == :test do
  import_config "test.exs"
end
