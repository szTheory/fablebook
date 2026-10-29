defmodule Fablebook.Contract.ProdGuardTest do
  use ExUnit.Case, async: false

  alias Fablebook.Test.MixCmd

  @moduletag :prod_guard
  @moduletag timeout: 600_000

  @fixture Path.expand("../fixtures/prod_guard_host", __DIR__)
  @build Path.expand("../../_build/guard_host", __DIR__)
  @canonical "Fablebook cannot be mounted in a prod build"

  test "a false dev_routes mount leaves no trace in prod and an unguarded mount fails the build" do
    clean!("dev")
    assert_ok(mix("dev", ~w(compile --warnings-as-errors)))
    assert mix!("dev", ~w(phx.routes GuardHostWeb.Router)) =~ "/dev/fablebook"
    assert Enum.any?(beam_sources("dev"), &(&1 =~ "/storybook/"))

    clean!("prod")
    assert_ok(mix("prod", ~w(compile --warnings-as-errors)))
    routes = mix!("prod", ~w(phx.routes GuardHostWeb.Router)) |> route_lines()
    assert Enum.any?(routes, &(&1 =~ ~r/GET\s+\/\s+GuardHost\.Ok/)), inspect(routes)
    refute Enum.any?(routes, &(&1 =~ ~r/fablebook/i)), inspect(routes)
    refute Enum.any?(beam_sources("prod"), &(&1 =~ "/storybook/" or &1 =~ "/design/"))

    clean!("prod")

    {out, status} =
      mix("prod", ~w(compile --warnings-as-errors), [{"FABLEBOOK_UNGUARDED", "1"}])

    assert status != 0, out
    assert out =~ "(CompileError) unguarded/"
    assert length(String.split(out, @canonical)) == 2, out
    assert out =~ "Application.compile_env(:guard_host, :dev_routes)"
  end

  defp mix(env, args, extra_env \\ []), do: MixCmd.run(@fixture, env, args, extra_env)

  defp mix!(env, args) do
    {out, status} = mix(env, args)
    assert status == 0, out
    out
  end

  defp assert_ok({out, status}), do: assert(status == 0, out)

  defp route_lines(out) do
    out
    |> String.split("\n")
    |> Enum.filter(&(&1 =~ ~r/\s(GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS|CONNECT|TRACE|\*)\s+\//))
  end

  defp clean!(env), do: mix!(env, ["clean"])

  defp beam_sources(env) do
    [@build, env, "lib/guard_host/ebin/*.beam"]
    |> Path.join()
    |> Path.wildcard()
    |> Enum.map(fn beam ->
      {:ok, {_, [compile_info: info]}} =
        :beam_lib.chunks(String.to_charlist(beam), [:compile_info])

      to_string(info[:source])
    end)
  end
end
