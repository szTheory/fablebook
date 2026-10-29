defmodule Fablebook.Test.GitDiff do
  @moduledoc false

  @scrubbed_env [{"GIT_DIR", nil}, {"GIT_WORK_TREE", nil}, {"GIT_INDEX_FILE", nil}]

  def base(env \\ System.get_env(), dir \\ File.cwd!()) do
    case {env["GITHUB_EVENT_NAME"], env["EVENT_BEFORE"]} do
      {"pull_request", _} -> pull_request_base(dir)
      {"push", before} when before not in [nil, ""] -> push_base(before, dir)
      _ -> git(dir, ["merge-base", "origin/main", "HEAD"])
    end
  end

  def changes(base, dir \\ File.cwd!()) do
    case git(dir, ["diff", "--no-renames", "--name-status", "-z", base]) do
      {:ok, out} -> parse_name_status(out)
      {:error, reason} -> raise reason
    end
  end

  defp parse_name_status(out) do
    out
    |> String.split("\0", trim: true)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [status, path] -> {status, path} end)
  end

  defp pull_request_base(dir) do
    with {:ok, line} <- git(dir, ["rev-list", "--parents", "-n", "1", "HEAD"]) do
      case String.split(line) do
        [_head, first, _second] -> {:ok, first}
        [_head | parents] -> {:error, "pull_request HEAD has #{length(parents)} parents, expected 2"}
      end
    end
  end

  defp push_base(before, dir) do
    cond do
      before =~ ~r/\A0+\z/ ->
        {:error, "push with zero before SHA"}

      not (before =~ ~r/\A[0-9a-f]{40}([0-9a-f]{24})?\z/) ->
        {:error, "push before #{inspect(before)} is not a full commit SHA"}

      match?({:ok, _}, git(dir, ["cat-file", "-e", before <> "^{commit}"])) ->
        {:ok, before}

      true ->
        {:error, "push before #{before} is not a commit in this checkout"}
    end
  end

  defp git(dir, args) do
    case System.cmd("git", args, cd: dir, env: @scrubbed_env, stderr_to_stdout: true) do
      {out, 0} -> {:ok, String.trim_trailing(out, "\n")}
      {out, _} -> {:error, "git #{Enum.join(args, " ")}: #{String.trim(out)}"}
    end
  end
end
