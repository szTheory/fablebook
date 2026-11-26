defmodule OperatorHost.MixProject do
  use Mix.Project

  def project do
    lane = if System.get_env("FABLEBOOK_FLOOR") == "1", do: "floor", else: "core"

    [
      app: :operator_host,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      build_path: Path.expand("../../_build/operator_host/#{lane}/build", __DIR__),
      deps_path: Path.expand("../../_build/operator_host/#{lane}/deps", __DIR__),
      lockfile: lockfile(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {OperatorHost.Application, []}]
  end

  defp lockfile do
    if System.get_env("FABLEBOOK_FLOOR") == "1",
      do: Path.expand("../../mix.floor.lock", __DIR__),
      else: Path.join(__DIR__, "mix.lock")
  end

  defp elixirc_paths(:prod) do
    if System.get_env("FABLEBOOK_OPERATOR_UNGUARDED") == "1" do
      ["lib", "unguarded"]
    else
      ["lib"]
    end
  end

  defp elixirc_paths(_env), do: ["lib", "storybook"]

  defp deps do
    shared = [
      {:fablebook, path: "../.."},
      {:phoenix, ">= 1.8.17 and < 2.0.0"},
      {:phoenix_live_view, ">= 1.2.9 and < 2.0.0"},
      {:jason, "~> 1.4", only: [:dev, :test]}
    ]

    if System.get_env("FABLEBOOK_FLOOR") == "1",
      do: shared,
      else: shared ++ [{:bandit, "1.15.0", only: :dev}]
  end
end
