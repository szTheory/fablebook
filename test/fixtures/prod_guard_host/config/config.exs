import Config

if config_env() == :dev do
  config :guard_host, dev_routes: true
end
