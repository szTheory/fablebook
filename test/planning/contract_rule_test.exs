defmodule Fablebook.Planning.ContractRuleTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.GitDiff

  @moduletag :planning

  @pairs [
    {"test/contract/", ["lib/", ".github/"]},
    {"test/planning/", [".planning/intent/", ".planning/REQUIREMENTS.md"]}
  ]

  @git_env [{"GIT_DIR", nil}, {"GIT_WORK_TREE", nil}, {"GIT_INDEX_FILE", nil}]
  @identity ~w(-c user.name=fixture -c user.email=fixture@localhost -c commit.gpgsign=false)

  @tag :git_diff
  test "no guard file changes in the same change set as the paths it guards" do
    changes = GitDiff.changes(Application.fetch_env!(:fablebook, :diff_base))

    assert violations(changes) == []
  end

  test "a modified contract test together with a lib/ change violates" do
    changes = [{"M", "test/contract/x_test.exs"}, {"A", "lib/y.ex"}]

    assert violations(changes) == [{"test/contract/x_test.exs", "lib/y.ex"}]
  end

  test "a deleted planning test together with a REQUIREMENTS change violates" do
    changes = [{"D", "test/planning/intent_test.exs"}, {"M", ".planning/REQUIREMENTS.md"}]

    assert violations(changes) == [{"test/planning/intent_test.exs", ".planning/REQUIREMENTS.md"}]
  end

  test "a modified contract test together with a workflow change violates" do
    changes = [{"M", "test/contract/x_test.exs"}, {"M", ".github/workflows/ci.yml"}]

    assert violations(changes) == [{"test/contract/x_test.exs", ".github/workflows/ci.yml"}]
  end

  test "an added contract test together with a lib/ change is allowed" do
    assert violations([{"A", "test/contract/x_test.exs"}, {"A", "lib/y.ex"}]) == []
  end

  test "a modified contract test together with an unpaired path is allowed" do
    assert violations([{"M", "test/contract/x_test.exs"}, {"M", "README.md"}]) == []
  end

  @tag :tmp_dir
  test "the seam reports A, M and D, and a rename as D plus A", %{tmp_dir: dir} do
    first = init!(dir)

    File.write!(Path.join(dir, "a"), "changed\n")
    File.write!(Path.join(dir, "b"), "b\n")
    File.rm!(Path.join(dir, "c"))
    git!(dir, ["mv", "r", "s"])
    commit!(dir, "two")

    assert Enum.sort(GitDiff.changes(first, dir)) ==
             [{"A", "b"}, {"A", "s"}, {"D", "c"}, {"D", "r"}, {"M", "a"}]
  end

  @tag :tmp_dir
  test "a pull_request base is the first parent of the merge HEAD", %{tmp_dir: dir} do
    first = init!(dir)

    git!(dir, ["checkout", "-q", "-b", "topic"])
    File.write!(Path.join(dir, "b"), "b\n")
    commit!(dir, "topic")
    git!(dir, ["checkout", "-q", "main"])
    git!(dir, @identity ++ ["merge", "-q", "--no-ff", "-m", "merge", "topic"])

    assert GitDiff.base(%{"GITHUB_EVENT_NAME" => "pull_request"}, dir) == {:ok, first}
  end

  @tag :tmp_dir
  test "a pull_request HEAD with one parent is rejected", %{tmp_dir: dir} do
    init!(dir)
    File.write!(Path.join(dir, "b"), "b\n")
    commit!(dir, "two")

    assert {:error, _} = GitDiff.base(%{"GITHUB_EVENT_NAME" => "pull_request"}, dir)
  end

  @tag :tmp_dir
  test "a push with a zero before SHA is rejected", %{tmp_dir: dir} do
    init!(dir)

    assert GitDiff.base(push(String.duplicate("0", 40)), dir) ==
             {:error, "push with zero before SHA"}
  end

  @tag :tmp_dir
  test "a push base is the before SHA when it is a commit", %{tmp_dir: dir} do
    first = init!(dir)
    File.write!(Path.join(dir, "b"), "b\n")
    commit!(dir, "two")

    assert GitDiff.base(push(first), dir) == {:ok, first}
  end

  @tag :tmp_dir
  test "a push with an unknown before SHA is rejected", %{tmp_dir: dir} do
    init!(dir)

    assert {:error, _} = GitDiff.base(push(String.duplicate("deadbeef", 5)), dir)
  end

  @tag :tmp_dir
  test "any other event resolves the merge-base with origin/main", %{tmp_dir: dir} do
    first = init!(dir)
    git!(dir, ["update-ref", "refs/remotes/origin/main", first])
    File.write!(Path.join(dir, "b"), "b\n")
    commit!(dir, "two")

    assert GitDiff.base(%{}, dir) == {:ok, first}
  end

  defp violations(changes) do
    for {status, path} <- changes,
        status != "A",
        {guard, paired} <- @pairs,
        String.starts_with?(path, guard),
        {_, other} <- changes,
        String.starts_with?(other, paired),
        do: {path, other}
  end

  defp push(before), do: %{"GITHUB_EVENT_NAME" => "push", "EVENT_BEFORE" => before}

  defp init!(dir) do
    git!(dir, ["init", "-q", "-b", "main"])
    for name <- ~w(a c r), do: File.write!(Path.join(dir, name), name <> "\n")
    commit!(dir, "one")
  end

  defp commit!(dir, message) do
    git!(dir, ["add", "-A"])
    git!(dir, @identity ++ ["commit", "-q", "-m", message])
    git!(dir, ["rev-parse", "HEAD"])
  end

  defp git!(dir, args) do
    {out, status} = System.cmd("git", args, cd: dir, env: @git_env, stderr_to_stdout: true)
    assert status == 0, "git #{Enum.join(args, " ")} failed:\n#{out}"
    String.trim(out)
  end
end
