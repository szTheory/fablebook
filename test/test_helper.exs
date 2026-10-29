case Fablebook.Test.GitDiff.base() do
  {:ok, sha} ->
    Application.put_env(:fablebook, :diff_base, sha)
    ExUnit.start(exclude: [:prod_guard, :release])

  {:error, reason} ->
    if System.get_env("CI") not in [nil, ""], do: raise("diff base unresolved in CI: #{reason}")

    IO.puts("git_diff tests: not-run (#{reason})")
    ExUnit.start(exclude: [:prod_guard, :release, :git_diff])
end
