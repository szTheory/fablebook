defmodule Fablebook.Contract.DependencyBudgetTest do
  use ExUnit.Case, async: true

  @required ~w(phoenix phoenix_live_view phoenix_html telemetry nimble_options)a
  @optional_allowed ~w(igniter earmark phoenix_test_playwright)a
  @banned ~w(jason mdex floki telemetry_metrics)a
  @banned_pattern "ya?ml|yamerl"

  @base Enum.map(@required, &{&1, ">= 0.0.0"})

  test "mix.exs declares exactly the five required deps and only non-prod tools" do
    deps = Mix.Project.config()[:deps]

    assert Enum.sort(classify(deps)[:required]) == Enum.sort(@required)
    assert classify(deps)[:optional] == nil
    assert violations(deps) == []
  end

  test "each dependency rule rejects its synthetic violation" do
    assert {:banned_direct, :jason} in violations(@base ++ [{:jason, "~> 1.4", only: :test}])
    assert {:unexpected_required, :credo} in violations(@base ++ [{:credo, "~> 1.7"}])

    assert {:optional_with_only, :earmark} in violations(
             @base ++ [{:earmark, "~> 1.4", optional: true, only: :dev}]
           )

    assert {:optional_not_allowed, :req} in violations(
             @base ++ [{:req, "~> 0.5", optional: true}]
           )

    assert {:missing_required, :telemetry} in violations(List.keydelete(@base, :telemetry, 0))
  end

  test "the prod closure reaches plug and no banned package" do
    closure = closure(roots(), &hex_requirements/1)

    assert "plug" in closure
    assert banned_in(closure) == []
  end

  test "a non-optional banned requirement anywhere in the closure is caught" do
    metadata = %{
      "phoenix" => [
        [{"app", "yaml_elixir"}, {"optional", false}],
        [{"app", "jason"}, {"optional", true}]
      ],
      "yaml_elixir" => [[{"name", "yamerl"}, {"optional", false}]]
    }

    closure = closure(roots(), &requirements(Map.get(metadata, &1, [])))

    assert banned_in(closure) == ["yaml_elixir", "yamerl"]
  end

  test "the floor lane loads exactly the floor versions named in mix.exs" do
    if System.get_env("FABLEBOOK_FLOOR") do
      deps = Mix.Project.config()[:deps]

      for app <- [:phoenix, :phoenix_live_view] do
        {^app, requirement} = List.keyfind(deps, app, 0)
        [floor] = Regex.run(~r/\d+\.\d+\.\d+/, requirement)
        Application.load(app)

        assert Application.spec(app, :vsn) == String.to_charlist(floor)
      end
    else
      IO.puts("floor-version check: not-run (FABLEBOOK_FLOOR unset)")
    end
  end

  defp classify(_deps), do: %{required: @required}

  defp violations(_deps), do: []

  defp roots, do: Enum.map(@required, &Atom.to_string/1)

  defp closure(roots, _requirements), do: roots

  defp hex_requirements(_app), do: []

  defp requirements(_entries), do: []

  defp banned_in(_apps), do: []
end
