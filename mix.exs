defmodule Fablebook.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/szTheory/fablebook"

  def project do
    [
      app: :fablebook,
      version: @version,
      elixir: "~> 1.18",
      description:
        "A Storybook-style workbench for Phoenix LiveView. This release reserves the name; the workbench is unreleased.",
      deps: deps(),
      lockfile: lockfile(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_ignore_filters: [&String.starts_with?(&1, "test/fixtures/")],
      dialyzer: [plt_local_path: "priv/plts", plt_core_path: "priv/plts", plt_add_apps: [:mix]],
      package: package(),
      docs: [main: "readme", source_ref: "v#{@version}", extras: ["README.md", "CHANGELOG.md"]],
      source_url: @source_url
    ]
  end

  def cli, do: [preferred_envs: [ci: :test]]

  def application, do: []

  defp lockfile, do: if(System.get_env("FABLEBOOK_FLOOR"), do: "mix.floor.lock", else: "mix.lock")

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, ">= 1.8.9 and < 2.0.0"},
      {:phoenix_live_view, ">= 1.2.9 and < 2.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:telemetry, "~> 1.0"},
      {:nimble_options, "~> 1.1"},
      {:ex_doc, "~> 0.40", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "compile --warnings-as-errors --force",
        "credo --strict",
        "xref graph --format cycles --label compile-connected --fail-above 0",
        "docs --warnings-as-errors",
        "test --warnings-as-errors --include prod_guard --include release"
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib mix.exs .formatter.exs README.md LICENSE CHANGELOG.md usage-rules.md)
    ]
  end
end
