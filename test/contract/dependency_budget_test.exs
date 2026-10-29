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

  defp classify(deps), do: Enum.group_by(deps, &kind/1, &elem(&1, 0))

  defp kind(dep) do
    opts = opts(dep)

    cond do
      opts[:optional] -> :optional
      :prod in List.wrap(Keyword.get(opts, :only, :prod)) -> :required
      true -> :tool
    end
  end

  defp opts({_name, opts}) when is_list(opts), do: opts
  defp opts({_name, _requirement, opts}), do: opts
  defp opts(_dep), do: []

  defp violations(deps) do
    groups = classify(deps)
    required = Map.get(groups, :required, [])
    optional = Map.get(groups, :optional, [])

    Enum.concat([
      for(dep <- deps, banned?(elem(dep, 0)), do: {:banned_direct, elem(dep, 0)}),
      for(name <- required -- @required, do: {:unexpected_required, name}),
      for(name <- @required -- required, do: {:missing_required, name}),
      for(name <- optional -- @optional_allowed, do: {:optional_not_allowed, name}),
      for(
        dep <- deps,
        opts(dep)[:optional] && Keyword.has_key?(opts(dep), :only),
        do: {:optional_with_only, elem(dep, 0)}
      )
    ])
  end

  defp roots, do: Enum.map(@required, &Atom.to_string/1)

  defp closure(roots, requirements), do: walk(roots, [], requirements)

  defp walk([], seen, _requirements), do: Enum.reverse(seen)

  defp walk([app | rest], seen, requirements) do
    if app in seen,
      do: walk(rest, seen, requirements),
      else: walk(rest ++ requirements.(app), [app | seen], requirements)
  end

  defp hex_requirements(app) do
    {:ok, metadata} =
      :file.consult(Path.join([Mix.Project.deps_path(), app, "hex_metadata.config"]))

    "requirements" |> :proplists.get_value(metadata, []) |> requirements()
  end

  defp requirements(entries), do: Enum.flat_map(entries, &required_app/1)

  defp required_app({name, entry}), do: required_app(Map.put_new(Map.new(entry), "app", name))
  defp required_app(entry) when is_list(entry), do: required_app(Map.new(entry))
  defp required_app(%{"optional" => false} = entry), do: [entry["app"] || entry["name"]]
  defp required_app(%{}), do: []

  defp banned_in(apps), do: Enum.filter(apps, &banned?/1)

  defp banned?(app) do
    name = to_string(app)

    name in Enum.map(@banned, &Atom.to_string/1) or
      Regex.match?(Regex.compile!(@banned_pattern), name)
  end
end
