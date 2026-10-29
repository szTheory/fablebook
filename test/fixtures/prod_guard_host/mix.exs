defmodule GuardHost.MixProject do
  use Mix.Project

  def project do
    [
      app: :guard_host,
      version: "0.1.0",
      elixir: "~> 1.18",
      deps_path: "../../../deps",
      build_path: "../../../_build/guard_host",
      lockfile: lockfile(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: [{:fablebook, path: "../../.."}, {:phoenix, ">= 0.0.0"}]
    ]
  end

  defp lockfile,
    do:
      if(System.get_env("FABLEBOOK_FLOOR"),
        do: "../../../mix.floor.lock",
        else: "../../../mix.lock"
      )

  defp elixirc_paths(:prod),
    do: ["lib"] ++ if(System.get_env("FABLEBOOK_UNGUARDED"), do: ["unguarded"], else: [])

  defp elixirc_paths(_), do: ["lib", "storybook"]
end
