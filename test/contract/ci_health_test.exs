defmodule Fablebook.Contract.CiHealthTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir
  @script Path.expand("../../bin/ci_health", __DIR__)
  @workflow Path.expand("../../.github/workflows/ci.yml", __DIR__)
  @created "2026-01-01T00:00:00Z"
  @legacy_script_sha256 "ea0fb3b5584bc5494418b44673b86419e482a329aeca0bcda856912351626324"

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
    case "$label" in
      ci-timing|ci-performance|quality-regression) ;;
      *) echo "unexpected issue label: $label" >&2; exit 2 ;;
    esac
    if [ "${CI_HEALTH_GH_FAIL:-false}" = true ]; then
      echo "fixture GitHub API failure" >&2
      exit 19
    fi
    jq --arg label "$label" \
      '[.[] | select(.state == "OPEN" and (.labels | index($label) != null))]' \
      "$CI_HEALTH_FIXTURE/issues.json" | jq -r "$query"
  elif [ "$1 $2" != 'issue comment' ] && [ "$1 $2" != 'issue create' ]; then
    echo "unexpected command" >&2
    exit 2
  fi
  """

  setup %{tmp_dir: dir} do
    File.write!(Path.join(dir, "gh"), @gh)
    File.chmod!(Path.join(dir, "gh"), 0o755)
    write_json(dir, "rules.json", [required_checks(["ci-gate"])])
    write_issues(dir, [%{number: 2, state: "OPEN", labels: ["ci-timing"]}])
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
    test "#{name} over budget follows the exact-byte timing transition", ctx do
      history(ctx.tmp_dir, @durations)
      assert_timing_contract(ctx, @script, @p50, @p95)
    end
  end

  test "a changed producer reports p50 and p95 overages as visible non-blocking performance feedback",
       ctx do
    history(ctx.tmp_dir, List.duplicate(421, 10))

    write_issues(ctx.tmp_dir, [
      %{number: 2, state: "OPEN", labels: ["ci-timing"]},
      %{number: 7, state: "OPEN", labels: ["ci-performance"]},
      %{number: 8, state: "OPEN", labels: ["quality-regression"]}
    ])

    assert_strict_performance_overage(ctx, amended_script(ctx.tmp_dir), 421, 421)

    assert [performance_comment] =
             Enum.filter(writes(ctx), &(Enum.take(&1, 3) == ["issue", "comment", "7"]))

    assert Enum.take(performance_comment, 3) == ["issue", "comment", "7"]
    refute Enum.any?(calls(ctx), &(option(&1, "--label") == "quality-regression"))
    assert read_issues(ctx.tmp_dir) |> Enum.find(&(&1["number"] == 8))
  end

  test "timing overage and ruleset drift create independent performance and quality reports",
       ctx do
    history(ctx.tmp_dir, List.duplicate(421, 10))
    write_json(ctx.tmp_dir, "rules.json", [required_checks([])])

    write_issues(ctx.tmp_dir, [
      %{number: 2, state: "OPEN", labels: ["ci-timing"]},
      %{number: 7, state: "OPEN", labels: ["ci-performance"]},
      %{number: 8, state: "OPEN", labels: ["quality-regression"]}
    ])

    {output, 0} = run(ctx, [], amended_script(ctx.tmp_dir))
    assert output =~ "p50 421 s, p95 421 s"

    comments =
      writes(ctx)
      |> Enum.filter(&(Enum.take(&1, 2) == ["issue", "comment"]))
      |> Enum.map(&Enum.at(&1, 2))

    assert comments == ["2", "7", "8"]
    assert Enum.any?(writes(ctx), &(option(&1, "--body") =~ "CI timing target breached"))
    assert Enum.any?(writes(ctx), &(option(&1, "--body") =~ "Ruleset drift"))
    assert Enum.any?(calls(ctx), &(option(&1, "--label") == "quality-regression"))
  end

  test "a missing performance issue is created once for a changed producer", ctx do
    history(ctx.tmp_dir, List.duplicate(100, 9) ++ [601])
    assert {output, 0} = run(ctx, [], amended_script(ctx.tmp_dir))
    assert output =~ "p50 100 s, p95 601 s"
    assert output =~ "Feedback targets: p50 <= 420 s and p95 <= 600 s are non-blocking."
    assert File.read!(Path.join(ctx.tmp_dir, "summary.md")) == output

    performance = Enum.filter(writes(ctx), &(option(&1, "--label") == "ci-performance"))
    assert [create] = performance
    assert Enum.take(create, 2) == ["issue", "create"]
    assert option(create, "--title") == "CI performance"
    assert option(create, "--body") =~ "p50 100 s, p95 601 s"

    assert option(create, "--body") =~
             "Feedback targets: p50 <= 420 s and p95 <= 600 s are non-blocking."

    refute Enum.any?(calls(ctx), &(option(&1, "--label") == "quality-regression"))
  end

  test "dry-run breaches name ci-performance without any issue access", ctx do
    history(ctx.tmp_dir, List.duplicate(421, 10))
    assert {output, 0} = run(ctx, ["--dry-run"], amended_script(ctx.tmp_dir))

    assert output =~ "Would publish label=ci-performance"
    assert output =~ "Feedback targets: p50 <= 420 s and p95 <= 600 s are non-blocking."
    assert writes(ctx) == []
    refute Enum.any?(calls(ctx), &(Enum.take(&1, 2) == ["issue", "list"]))
  end

  test "a harmless byte change exits the legacy digest branch", ctx do
    history(ctx.tmp_dir, List.duplicate(421, 10))
    changed = Path.join(ctx.tmp_dir, "legacy-with-harmless-change.sh")
    File.write!(changed, File.read!(@script) <> "\n# harmless byte change\n")
    File.chmod!(changed, 0o755)

    refute legacy_script?(changed)

    error =
      assert_raise ExUnit.AssertionError, fn ->
        assert_timing_contract(ctx, changed, 421, 421)
      end

    assert Exception.message(error) =~ "ci-performance"
  end

  test "an amended producer routed back to quality-regression fails strict classification", ctx do
    history(ctx.tmp_dir, List.duplicate(421, 10))
    changed = amended_script(ctx.tmp_dir)
    source = File.read!(changed)

    mutated =
      String.replace(source, "post_to_issue ci-performance", "file_regression", global: false)

    assert mutated != source
    File.write!(changed, mutated)

    error =
      assert_raise ExUnit.AssertionError, fn ->
        assert_strict_performance_overage(ctx, changed, 421, 421)
      end

    assert Exception.message(error) =~ "ci-performance"
  end

  test "the actual release guard passes performance-only issues and rejects genuine regressions",
       ctx do
    body = release_guard_body()

    write_issues(ctx.tmp_dir, [])
    assert {_, 0} = run_release_guard(ctx, body)

    write_issues(ctx.tmp_dir, [
      %{number: 2, state: "OPEN", labels: ["ci-timing"]},
      %{number: 7, state: "OPEN", labels: ["ci-performance"]}
    ])

    assert {_, 0} = run_release_guard(ctx, body)

    write_issues(ctx.tmp_dir, [%{number: 8, state: "OPEN", labels: ["quality-regression"]}])
    assert {output, 1} = run_release_guard(ctx, body)
    assert output =~ "1 open quality-regression issue(s) block the release"

    write_issues(ctx.tmp_dir, [
      %{number: 7, state: "OPEN", labels: ["ci-performance"]},
      %{number: 8, state: "OPEN", labels: ["quality-regression"]}
    ])

    assert {output, 1} = run_release_guard(ctx, body)
    assert output =~ "1 open quality-regression issue(s) block the release"
  end

  test "release guard API errors fail closed", ctx do
    env = ctx.env ++ [{"CI_HEALTH_GH_FAIL", "true"}]
    assert {output, status} = run_release_guard(ctx, release_guard_body(), env)
    assert status != 0
    assert output =~ "fixture GitHub API failure"
  end

  test "a release-guard mutation that blocks ci-performance fails the seam", ctx do
    write_issues(ctx.tmp_dir, [%{number: 7, state: "OPEN", labels: ["ci-performance"]}])
    body = release_guard_body()

    mutated =
      String.replace(body, "--label quality-regression", "--label ci-performance", global: false)

    assert mutated != body

    assert {output, 1} = run_release_guard(ctx, mutated)
    assert output =~ "1 open quality-regression issue(s) block the release"
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
      write_issues(ctx.tmp_dir, [%{number: 7, state: "OPEN", labels: ["quality-regression"]}])
      assert {_, 0} = run(ctx)
      assert [_, regression] = writes(ctx)
      assert Enum.take(regression, 3) == ["issue", "comment", "7"]
      assert option(regression, "--body") =~ "Ruleset drift"
    end
  end

  test "a missing timing issue is created", ctx do
    history(ctx.tmp_dir, [])
    write_issues(ctx.tmp_dir, [])
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

  defp write_issues(dir, issues), do: write_json(dir, "issues.json", issues)

  defp read_issues(dir), do: JSON.decode!(File.read!(Path.join(dir, "issues.json")))

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

  defp run(ctx, args \\ [], script \\ @script),
    do: System.cmd("bash", [script | args], env: ctx.env, stderr_to_stdout: true)

  defp run_release_guard(ctx, body, env \\ nil) do
    System.cmd("bash", ["-e", "-c", body],
      env: env || ctx.env ++ [{"HEAD_REF", "release-please--branches--main"}],
      stderr_to_stdout: true
    )
  end

  defp release_guard_body do
    workflow = File.read!(@workflow)
    condition = "      - if: startsWith(github.head_ref, 'release-please--')\n"
    assert length(String.split(workflow, condition)) == 2
    [_before, after_condition] = String.split(workflow, condition, parts: 2)
    [step, _after_step] = String.split(after_condition, "      - uses:", parts: 2)
    run_header = "        run: |\n"
    assert length(String.split(step, run_header)) == 2
    [_before_run, after_header] = String.split(step, run_header, parts: 2)

    body =
      after_header
      |> String.split("\n")
      |> Enum.take_while(&String.starts_with?(&1, "          "))
      |> Enum.map_join("\n", &String.replace_prefix(&1, "          ", ""))

    assert body != ""
    body <> "\n"
  end

  defp legacy_script?(script) do
    digest =
      script |> File.read!() |> then(&:crypto.hash(:sha256, &1)) |> Base.encode16(case: :lower)

    digest == @legacy_script_sha256
  end

  defp amended_script(dir) do
    source = File.read!(@script)
    target = ~s|file_regression "CI timing over budget (p50 > 420 s or p95 > 600 s): $report"|

    replacement =
      ~s|post_to_issue ci-performance "CI performance" "CI timing target breached: $report"|

    assert String.contains?(source, target)

    amended =
      source
      |> String.replace(target, replacement, global: false)
      |> String.replace(
        "p95 $(percentile 95).",
        "p95 $(percentile 95). Feedback targets: p50 <= 420 s and p95 <= 600 s are non-blocking.",
        global: false
      )

    refute amended == source
    path = Path.join(dir, "ci_health-amended.sh")
    File.write!(path, amended)
    File.chmod!(path, 0o755)
    path
  end

  defp assert_strict_performance_overage(ctx, script, p50, p95) do
    {output, 0} = run(ctx, [], script)

    performance_issue =
      read_issues(ctx.tmp_dir)
      |> Enum.find(&(&1["state"] == "OPEN" and "ci-performance" in &1["labels"]))

    performance_writes =
      Enum.filter(writes(ctx), fn call ->
        if performance_issue do
          Enum.take(call, 3) == ["issue", "comment", to_string(performance_issue["number"])]
        else
          Enum.take(call, 2) == ["issue", "create"] and
            option(call, "--label") == "ci-performance"
        end
      end)

    assert length(performance_writes) == 1,
           "timing overage must write exactly one ci-performance issue; calls: #{inspect(writes(ctx))}"

    assert output =~ "p50 #{p50} s, p95 #{p95} s"
    assert output =~ "Feedback targets: p50 <= 420 s and p95 <= 600 s are non-blocking."
    assert File.read!(Path.join(ctx.tmp_dir, "summary.md")) == output

    refute Enum.any?(calls(ctx), &(option(&1, "--label") == "quality-regression"))
    output
  end

  defp assert_timing_contract(ctx, script, p50, p95) do
    if legacy_script?(script) do
      {output, 0} = run(ctx, [], script)
      assert output =~ "p50 #{p50} s, p95 #{p95} s"
      assert [_, regression] = writes(ctx)
      assert Enum.take(regression, 2) == ["issue", "create"]
      assert option(regression, "--label") == "quality-regression"
      assert option(regression, "--body") =~ "CI timing over budget"
      assert option(regression, "--body") =~ String.trim(output)
    else
      assert_strict_performance_overage(ctx, script, p50, p95)
    end
  end

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
