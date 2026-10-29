defmodule Fablebook.Contract.ProdGuardMessageTest do
  use ExUnit.Case, async: false

  @snapshot Path.expand("../snapshots/prod_guard_message.txt", __DIR__)
  @readme Path.expand("../../README.md", __DIR__)
  @first_line "Fablebook cannot be mounted in a prod build"

  setup do
    previous = Mix.env()
    Mix.env(:prod)
    on_exit(fn -> Mix.env(previous) end)
  end

  test "the prod CompileError text matches its snapshot and the README heading" do
    description = prod_description()
    snapshot = File.read!(@snapshot)

    assert description == snapshot, """
    The prod guard message differs from #{Path.relative_to_cwd(@snapshot)}.

    Actual:
    #{description}
    Snapshot:
    #{snapshot}
    """

    [first | _] = String.split(description, "\n")
    assert first == @first_line

    readme_lines = @readme |> File.read!() |> String.split("\n")
    assert ("### " <> first) in readme_lines
  end

  defp prod_description do
    ast = quote do: Fablebook.Router.fablebook("/fablebook", MyAppWeb.Storybook)
    {:ok, env} = Macro.Env.define_require(__ENV__, [], Fablebook.Router)
    {:raise, _, [_, opts]} = Macro.expand_once(ast, env)
    Keyword.fetch!(opts, :description)
  end
end
