import Config

config :operator_host, OperatorHost.Endpoint,
  secret_key_base: String.duplicate("fablebook-operator-test-key-", 4)
