import Config

if config_env() in [:dev, :test] do
  config :guard_host, dev_routes: true
end
