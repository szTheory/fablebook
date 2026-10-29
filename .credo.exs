%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/", "credo/", "mix.exs"],
        excluded: [~r"/_build/", ~r"/deps/", "test/fixtures/"]
      },
      requires: ["credo/checks/*.ex"],
      strict: true,
      checks: %{
        extra: [
          {Credo.Check.Warning.UnsafeToAtom, []},
          {Credo.Check.Warning.MixEnv, [files: %{excluded: ["lib/fablebook/router.ex"]}]},
          {Credo.Check.Warning.ForbiddenModule,
           [
             modules: [EEx, Jason, Floki, MDEx, YamlElixir, Telemetry.Metrics],
             files: %{included: ["lib/", "mix.exs"]}
           ]},
          {Fablebook.Credo.BannedCalls, [files: %{included: ["lib/", "mix.exs"]}]}
        ]
      }
    }
  ]
}
