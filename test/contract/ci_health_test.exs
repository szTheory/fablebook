defmodule Fablebook.Contract.CiHealthTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir
  @script Path.expand("../../bin/ci_health", __DIR__)
  @created "2026-01-01T00:00:00Z"

  @gh ~S"""
  #!/usr/bin/env bash
  set -euo pipefail
  jq -cn --args '$ARGS.positional' -- "$@" >> "$CI_HEALTH_FIXTURE/calls.jsonl"
  query='.'
  args=("$@")
  for ((i=0; i<${#args[@]}; i++)); do
    if [ "${args[i]}" = --jq ]; then query="${args[i+1]}"; fi
  done
  if [ "$1" = api ]; then
    shift
    if [ "$1" = --paginate ]; then shift; fi
    case "$1" in
      */actions/workflows/ci.yml/runs\?event=pull_request\&created=%3E%3D*\&per_page=100)
        file=runs.json ;;
      */actions/runs/*/jobs\?per_page=100)
        id="${1%/jobs*}"; file="jobs-${id##*/}.json" ;;
      */rules/branches/main) file=rules.json ;;
      *) echo "unexpected API request: $1" >&2; exit 2 ;;
    esac
    jq -r "$query" "$CI_HEALTH_FIXTURE/$file"
  elif [ "$1 $2" = 'issue list' ]; then
    label=''
    for ((i=0; i<${#args[@]}; i++)); do
      if [ "${args[i]}" = --label ]; then label="${args[i+1]}"; fi
    done
    jq -r "$query" "$CI_HEALTH_FIXTURE/issues-$label.json"
  elif [ "$1 $2" != 'issue comment' ] && [ "$1 $2" != 'issue create' ]; then
    echo "unexpected command" >&2
    exit 2
  fi
  """

  setup %{tmp_dir: dir} do
    File.write!(Path.join(dir, "gh"), @gh)
    File.chmod!(Path.join(dir, "gh"), 0o755)
    write_json(dir, "rules.json", [required_checks(["ci-gate"])])
    write_json(dir, "issues-ci-timing.json", [%{number: 2}])
    write_json(dir, "issues-quality-regression.json", [])
    %{env: fixture_env(dir)}
  end

  for n <- [0, 9] do
    test "#{n} eligible runs report not-run without a timing regression", ctx do
      history(ctx.tmp_dir, List.duplicate(900, unquote(n)))
      assert {output, 0} = run(ctx)
      assert output =~ "p50 not-run (n=#{unquote(n)}), p95 not-run (n=#{unquote(n)})"
      assert [comment] = writes(ctx)
      assert Enum.take(comment, 3) == ["issue", "comment", "2"]
      assert File.read!(Path.join(ctx.tmp_dir, "summary.md")) == output
    end
  end

  test "dry run calculates live timing and ruleset evidence without issue access", ctx do
    history(ctx.tmp_dir, List.duplicate(100, 10))
    assert {output, 0} = run(ctx, ["--dry-run"])

    assert output =~ "(n=10): p50 100 s, p95 100 s."
    assert output =~ "Dry run: issue updates were suppressed."
    assert File.read!(Path.join(ctx.tmp_dir, "summary.md")) =~ "p50 100 s, p95 100 s"
    assert writes(ctx) == []
    refute Enum.any?(calls(ctx), &(Enum.take(&1, 2) == ["issue", "list"]))
  end

  test "dry run suppresses a file-regression write when it precedes the command", ctx do
    assert {output, 0} =
             run(ctx, ["--dry-run", "--file-regression", "nightly", "consumer smoke failed"])

    assert output =~ "Dry run: issue updates were suppressed."
    assert output =~ "Would publish label=quality-regression title=Quality regression"
    assert output =~ "consumer smoke failed"
    assert writes(ctx) == []
    assert calls(ctx) == []
  end

  test "dry run placed after a command is rejected before any GitHub access", ctx do
    assert {output, 2} =
             run(ctx, ["--file-regression", "nightly", "consumer smoke failed", "--dry-run"])

    assert output =~ "--dry-run must be the first argument"
    assert calls(ctx) == []
  end

  test "ten runs use nearest-rank percentiles and accept exact budgets", ctx do
    history(ctx.tmp_dir, [600, 420, 100, 420, 600, 420, 100, 600, 420, 100])
    assert {output, 0} = run(ctx)

    assert output =~
             "(n=10): p50 420 s, p95 600 s. https://github.com/fixture/project/actions/runs/123"

    assert length(writes(ctx)) == 1
  end

  for {name, durations, p50, p95} <- [
        {"p50", List.duplicate(421, 10), 421, 421},
        {"p95", List.duplicate(100, 9) ++ [601], 100, 601}
      ] do
    @durations durations
    @p50 p50
    @p95 p95
    test "#{name} over budget files a regression with measured evidence", ctx do
      history(ctx.tmp_dir, @durations)
      assert {output, 0} = run(ctx)
      assert output =~ "p50 #{@p50} s, p95 #{@p95} s"
      assert [_, regression] = writes(ctx)
      assert Enum.take(regression, 2) == ["issue", "create"]
      assert option(regression, "--label") == "quality-regression"
      assert option(regression, "--body") =~ "CI timing over budget"
      assert option(regression, "--body") =~ String.trim(output)
    end
  end

  test "release PRs, reruns and unfinished gates do not inflate the sample", ctx do
    runs = history(ctx.tmp_dir, List.duplicate(100, 9))

    release = %{
      id: 10,
      created_at: @created,
      head_branch: "release-please--branches--main",
      run_attempt: 1
    }

    rerun = %{release | id: 11, head_branch: "feature", run_attempt: 2}
    unfinished = %{release | id: 12, head_branch: "feature"}
    write_json(ctx.tmp_dir, "runs.json", %{workflow_runs: runs ++ [release, rerun, unfinished]})

    write_json(ctx.tmp_dir, "jobs-12.json", %{
      jobs: [%{name: "ci-gate", conclusion: nil, completed_at: nil}]
    })

    assert {output, 0} = run(ctx)
    assert output =~ "p50 not-run (n=9)"
    refute Enum.any?(calls(ctx), &(Enum.join(&1, " ") =~ "/runs/10/jobs"))
    refute Enum.any?(calls(ctx), &(Enum.join(&1, " ") =~ "/runs/11/jobs"))
    assert length(writes(ctx)) == 1
  end

  test "failed gates count but skipped gates and unrelated jobs do not", ctx do
    runs = history(ctx.tmp_dir, List.duplicate(100, 9))
    failed = %{id: 10, created_at: @created, head_branch: "feature", run_attempt: 1}
    skipped = %{failed | id: 11}
    write_json(ctx.tmp_dir, "runs.json", %{workflow_runs: runs ++ [failed, skipped]})
    write_json(ctx.tmp_dir, "jobs-10.json", %{jobs: [job("ci-gate", "failure", 200)]})

    write_json(ctx.tmp_dir, "jobs-11.json", %{
      jobs: [job("ci-gate", "skipped", 900), job("core", "success", 900)]
    })

    assert {output, 0} = run(ctx)
    assert output =~ "(n=10): p50 100 s, p95 200 s"
    assert length(writes(ctx)) == 1
  end

  for contexts <- [[], ["core"], ["ci-gate", "core"]] do
    @contexts contexts
    test "ruleset drift #{inspect(contexts)} updates the existing regression", ctx do
      history(ctx.tmp_dir, [])
      write_json(ctx.tmp_dir, "rules.json", [required_checks(@contexts)])
      write_json(ctx.tmp_dir, "issues-quality-regression.json", [%{number: 7}])
      assert {_, 0} = run(ctx)
      assert [_, regression] = writes(ctx)
      assert Enum.take(regression, 3) == ["issue", "comment", "7"]
      assert option(regression, "--body") =~ "Ruleset drift"
    end
  end

  test "a missing timing issue is created", ctx do
    history(ctx.tmp_dir, [])
    write_json(ctx.tmp_dir, "issues-ci-timing.json", [])
    assert {_, 0} = run(ctx)
    assert [create] = writes(ctx)
    assert Enum.take(create, 2) == ["issue", "create"]
    assert option(create, "--label") == "ci-timing"
  end

  test "an API failure exits nonzero without manufacturing timing evidence", ctx do
    assert {_, status} = run(ctx)
    assert status != 0
    assert writes(ctx) == []
    refute File.exists?(Path.join(ctx.tmp_dir, "summary.md"))
  end

  test "failure reporting includes the job, ref, run and note without querying history", ctx do
    assert {_, 0} = run(ctx, ["--file-regression", "nightly", "consumer smoke failed"])
    assert [create] = writes(ctx)

    assert option(create, "--body") ==
             "Job `nightly` failed on `refs/heads/main`: https://github.com/fixture/project/actions/runs/123\n\nconsumer smoke failed"

    refute Enum.any?(calls(ctx), &(hd(&1) == "api"))
  end

  defp history(dir, durations) do
    runs =
      durations
      |> Enum.with_index(1)
      |> Enum.map(fn {seconds, id} ->
        write_json(dir, "jobs-#{id}.json", %{jobs: [job("ci-gate", "success", seconds)]})
        %{id: id, created_at: @created, head_branch: "feature", run_attempt: 1}
      end)

    write_json(dir, "runs.json", %{workflow_runs: runs})
    runs
  end

  defp job(name, conclusion, seconds) do
    completed =
      @created
      |> DateTime.from_iso8601()
      |> elem(1)
      |> DateTime.add(seconds)
      |> DateTime.to_iso8601()

    %{name: name, conclusion: conclusion, completed_at: completed}
  end

  defp required_checks(contexts) do
    %{
      type: "required_status_checks",
      parameters: %{required_status_checks: Enum.map(contexts, &%{context: &1})}
    }
  end

  defp write_json(dir, name, value), do: File.write!(Path.join(dir, name), JSON.encode!(value))

  defp fixture_env(dir) do
    [
      {"PATH", dir <> ":" <> System.fetch_env!("PATH")},
      {"CI_HEALTH_FIXTURE", dir},
      {"GITHUB_REPOSITORY", "fixture/project"},
      {"GITHUB_SERVER_URL", "https://github.com"},
      {"GITHUB_RUN_ID", "123"},
      {"GITHUB_REF", "refs/heads/main"},
      {"GITHUB_STEP_SUMMARY", Path.join(dir, "summary.md")},
      {"GH_TOKEN", nil},
      {"GITHUB_TOKEN", nil}
    ]
  end

  defp run(ctx, args \\ []),
    do: System.cmd("bash", [@script | args], env: ctx.env, stderr_to_stdout: true)

  defp calls(ctx) do
    path = Path.join(ctx.tmp_dir, "calls.jsonl")

    case File.read(path) do
      {:ok, contents} ->
        contents
        |> String.split("\n", trim: true)
        |> Enum.map(&JSON.decode!/1)

      {:error, :enoent} ->
        []
    end
  end

  defp writes(ctx),
    do:
      Enum.filter(calls(ctx), &(Enum.take(&1, 2) in [["issue", "create"], ["issue", "comment"]]))

  defp option(args, name), do: args |> Enum.drop_while(&(&1 != name)) |> Enum.at(1)
end
