case Fablebook.Test.GitDiff.base() do
  {:ok, sha} ->
    Application.put_env(:fablebook, :diff_base, sha)
    ExUnit.start(exclude: [:prod_guard, :release])

  {:error, reason} ->
    if System.get_env("CI") not in [nil, ""], do: raise("diff base unresolved in CI: #{reason}")

    IO.puts("git_diff tests: not-run (#{reason})")
    ExUnit.start(exclude: [:prod_guard, :release, :git_diff])
end

tap_formatter = "Fablebook.Test.ExUnitTapFormatter"
formatter_args = System.argv()

if Enum.any?(formatter_args, fn
     "--formatter=" <> formatter -> formatter == tap_formatter
     _ -> false
   end) or
     Enum.chunk_every(formatter_args, 2, 1, :discard)
     |> Enum.any?(fn
       ["--formatter", formatter] -> formatter == tap_formatter
       _ -> false
     end) do
  Code.require_file("support/exunit_tap_formatter.ex", __DIR__)
end
