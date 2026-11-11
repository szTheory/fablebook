defmodule Fablebook.Contract.FloorSelectionTest do
  use ExUnit.Case, async: false

  @moduletag :tmp_dir
  @probe ~S"""
  defmodule Fablebook.Test.GitDiff do
    def base do
      if System.get_env("FABLEBOOK_SELECTION_DIFF_ERROR"),
        do: {:error, :fixture_unavailable},
        else: {:ok, String.duplicate("a", 40)}
    end
  end

  [helper, budget, floor | _] = System.argv()

  case floor do
    "unset" -> System.delete_env("FABLEBOOK_FLOOR")
    value -> System.put_env("FABLEBOOK_FLOOR", value)
  end

  Code.require_file(helper)
  Code.require_file(budget)

  [floor_check] =
    Fablebook.Contract.DependencyBudgetTest.__ex_unit__().tests
    |> Enum.filter(&(to_string(&1.name) == "test the floor lane loads exactly the floor versions named in mix.exs"))

  IO.puts("FLOOR_CHECK_TAG=#{Map.get(floor_check.tags, :floor, false)}")

  ExUnit.configure(
    exclude: [{:module, Fablebook.Contract.DependencyBudgetTest} | ExUnit.configuration()[:exclude]],
    formatters: [Fablebook.Test.ExUnitTapFormatter]
  )

  defmodule FloorSelectionProbe do
    use ExUnit.Case

    @tag :floor
    test "floor probe", do: assert(true)

    @tag :git_diff
    test "git diff probe", do: assert(true)

    test "ordinary probe", do: assert(true)
  end
  """

  test "the real helper excludes floor only when its lane flag is unset", %{tmp_dir: dir} do
    for floor <- [nil, "1", ""] do
      {output, status} = probe(dir, floor)

      assert status == 0, output
      assert excluded?(output, "floor probe") == is_nil(floor)
      refute excluded?(output, "ordinary probe")
      refute excluded?(output, "git diff probe")
    end
  end

  test "the real version assertion is registered as a floor test", %{tmp_dir: dir} do
    {output, 0} = probe(dir, nil)
    assert output =~ "FLOOR_CHECK_TAG=true"
  end

  test "local unresolved diffs retain their exclusion alongside floor selection", %{tmp_dir: dir} do
    for floor <- [nil, "1"] do
      {output, status} = probe(dir, floor, diff_error: "1")

      assert status == 0, output
      assert excluded?(output, "floor probe") == is_nil(floor)
      assert excluded?(output, "git diff probe")
      refute excluded?(output, "ordinary probe")
    end
  end

  test "CI unresolved diffs still fail before tests execute", %{tmp_dir: dir} do
    for floor <- [nil, "1"] do
      {output, status} = probe(dir, floor, diff_error: "1", ci: "1")

      assert status != 0
      assert output =~ "diff base unresolved in CI: fixture_unavailable"
      refute output =~ " - test ordinary probe"
    end
  end

  defp probe(dir, floor, opts \\ []) do
    path = Path.join(dir, "probe.exs")
    File.write!(path, @probe)

    System.cmd(
      "elixir",
      [
        path,
        Path.expand("test/test_helper.exs"),
        Path.expand("test/contract/dependency_budget_test.exs"),
        floor || "unset",
        "--formatter=Fablebook.Test.ExUnitTapFormatter"
      ],
      env: [
        {"FABLEBOOK_FLOOR", nil},
        {"CI", opts[:ci]},
        {"FABLEBOOK_SELECTION_DIFF_ERROR", opts[:diff_error]},
        {"FABLEBOOK_TAP_REPORT", nil}
      ],
      stderr_to_stdout: true
    )
  end

  defp excluded?(output, name) do
    line = output |> String.split("\n") |> Enum.find(&String.contains?(&1, " - test #{name}"))
    assert is_binary(line), output
    String.contains?(line, "# SKIP")
  end
end
