import Config

case config_env() do
  :dev ->
    secret =
      System.get_env("FABLEBOOK_OPERATOR_SECRET_KEY_BASE") ||
        Base.url_encode64(:crypto.strong_rand_bytes(64), padding: false)

    config :operator_host, OperatorHost.Endpoint, secret_key_base: secret

  :prod ->
    secret = System.fetch_env!("FABLEBOOK_OPERATOR_SECRET_KEY_BASE")

    if byte_size(secret) < 64 do
      raise "FABLEBOOK_OPERATOR_SECRET_KEY_BASE must contain at least 64 bytes"
    end

    config :operator_host, OperatorHost.Endpoint, secret_key_base: secret

  _ ->
    :ok
end
