%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/", "credo/", "mix.exs"],
        excluded: [~r"/_build/", ~r"/deps/", "test/fixtures/"]
      },
      strict: true
    }
  ]
}
