defmodule Fablebook.Contract.CiShapeTest do
  use ExUnit.Case, async: true

  @workflows ~w(ci.yml release-please.yml hex-publish.yml)
  @github_files ~w(
    workflows/ci.yml
    workflows/release-please.yml
    workflows/hex-publish.yml
    actions/setup/action.yml
    zizmor.yml
  )
  @node_jobs ~w(e2e nightly)
  @schedule_only ~w(ci-health)
  @allowed_reusable %{"release-please.yml" => "./.github/workflows/hex-publish.yml"}
  @ci_test_step "test --warnings-as-errors --include prod_guard --include release"
  @allowed_excludes [:prod_guard, :release, :git_diff]

  @base "test/fixtures/ci_shape/base.yml"
  @sha "3d3c42e5aac5ba805825da76410c181273ba90b1"
  @long_line "# " <> String.duplicate("x", 120)
  @padding String.duplicate("#\n", 250)
  @extra_job "\njobs:\n  JOB:\n    runs-on: ubuntu-24.04\n    timeout-minutes: 5\n    steps:\n      - run: echo ok\n"
  @gate_needs "    needs: [core, nightly]\n"
  @nightly_if "    if: github.event.schedule == '17 3 * * *' || startsWith(github.head_ref, 'release-please--')\n"
  @smoke "      - run: bin/smoke_consumer --path .\n"

  @mutations [
    {:tab, "ci.yml", "name: ci\n", "name:\tci\n"},
    {:anchor, "ci.yml", "permissions:\n", "permissions: &perms\n"},
    {:anchor, "ci.yml", "    timeout-minutes: 30\n", "    timeout-minutes: *thirty\n"},
    {:merge_key, "ci.yml", "permissions:\n", "permissions:\n  <<: {}\n"},
    {:workflow_call, "ci.yml", "  pull_request:\n", "  pull_request:\n  workflow_call:\n"},
    {:reusable, "ci.yml", "./.github/actions/setup", "./.github/workflows/hex-publish.yml"},
    {:reusable, "release-please.yml", "./.github/workflows/hex-publish.yml",
     "./.github/workflows/other.yml"},
    {:line_length, "ci.yml", "name: ci\n", "name: ci\n#{@long_line}\n"},
    {:ci_lines, "ci.yml", "name: ci\n", "name: ci\n" <> @padding},
    {:action_lines, "action.yml", "name: setup\n",
     "name: setup\n" <> String.duplicate("#\n", 60)},
    {:no_timeout, "ci.yml", "    timeout-minutes: 15\n", ""},
    {:timeout_not_literal, "ci.yml", "    timeout-minutes: 15\n",
     "    timeout-minutes: ${{ inputs.t }}\n"},
    {:unpinned_uses, "ci.yml", "actions/checkout@#{@sha}", "actions/checkout@v7"},
    {:unpinned_uses, "ci.yml", "actions/checkout@#{@sha}", "actions/checkout@3d3c42e"},
    {:unpinned_uses, "action.yml", "erlef/setup-beam@", "erlef/setup-beam@main # "},
    {:unpinned_image, "ci.yml", "    timeout-minutes: 15\n",
     "    timeout-minutes: 15\n    container: elixir:1.20\n"},
    {:paths_filter, "ci.yml", "  pull_request:\n", "  pull_request:\n    paths: [lib]\n"},
    {:paths_filter, "ci.yml", "  pull_request:\n", "  pull_request:\n    paths-ignore: [docs]\n"},
    {:ci_gate_count, "release-please.yml", "\njobs:\n",
     String.replace(@extra_job, "JOB", "ci-gate")},
    {:ci_gate_count, "ci.yml", "  ci-gate:\n", "  gate:\n"},
    {:ci_gate_always, "ci.yml", "    if: always()\n", "    if: success()\n"},
    {:ci_gate_strategy, "ci.yml", @gate_needs,
     @gate_needs <> "    strategy:\n      matrix:\n        n: [1]\n"},
    {:ci_gate_needs, "ci.yml", @gate_needs, "    needs: [core]\n"},
    {:ci_gate_needs, "ci.yml", @gate_needs, "    needs: [core, nightly, ci-health]\n"},
    {:ci_gate_step, "ci.yml", "${{ toJSON(needs) }}", "${{ needs.core.result }}"},
    {:ci_gate_step, "ci.yml", "jq -e ", "jq "},
    {:bypass, "ci.yml", "    timeout-minutes: 15\n",
     "    timeout-minutes: 15\n    continue-on-error: true\n"},
    {:bypass, "ci.yml", @smoke, "      - run: bin/smoke_consumer --path . || true\n"},
    {:bypass, "ci.yml", @smoke, "      - run: bin/smoke_consumer --path . || :\n"},
    {:bypass, "ci.yml", @smoke, "      - run: set +e; bin/smoke_consumer --path .\n"},
    {:bypass, "ci.yml", @nightly_if, "    if: false\n"},
    {:bypass, "ci.yml", @nightly_if, "    if: ${{ false }}\n"},
    {:core_mix_ci, "ci.yml", "      - run: mix ci\n", "      - run: mix test\n"},
    {:core_fetch_depth, "ci.yml", "          fetch-depth: 0\n", ""},
    {:event_before, "ci.yml", "  EVENT_BEFORE: ${{ github.event.before }}\n", "  OTHER: x\n"},
    {:ci_health_shape, "ci.yml", "      - run: mix test test/contract/ci_shape_test.exs\n",
     "      - run: mix test\n"},
    {:ci_health_failure, "ci.yml",
     "      - if: failure()\n        run: bin/ci_health --file-regression ci-health",
     "      - run: bin/ci_health --file-regression ci-health"},
    {:nightly_failure, "ci.yml",
     "      - if: failure()\n        run: bin/ci_health --file-regression nightly",
     "      - run: bin/ci_health --file-regression nightly"},
    {:node, "ci.yml", "      - run: mix ci\n",
     "      - run: mix ci\n      - run: npx playwright test\n"},
    {:phase_name, "ci.yml", "name: ci\n", "name: ci phase 1\n"},
    {:phase_name, "release-please.yml", "\njobs:\n",
     String.replace(@extra_job, "JOB", "verify-phase2")}
  ]

  test "the real .github workflows and setup action pass every rule" do
    assert workflow_violations(real_files()) == []
  end

  test "the base fixture passes every rule" do
    assert workflow_violations(base_files()) == []
  end

  for {{rule, target, from, to}, i} <- Enum.with_index(@mutations, 1) do
    @tag rule: rule, target: target, from: from, to: to
    test "mutation #{i} of #{target} fires exactly #{rule}", tags do
      files = base_files()
      original = Map.fetch!(files, tags.target)
      mutated = String.replace(original, tags.from, tags.to, global: false)

      assert mutated != original
      assert files |> Map.put(tags.target, mutated) |> fired() == [tags.rule]
    end
  end

  test "Node tooling inside an allowlisted job passes" do
    files =
      Map.update!(
        base_files(),
        "ci.yml",
        &String.replace(&1, @smoke, @smoke <> "      - run: npm ci\n")
      )

    assert workflow_violations(files) == []
  end

  test "p50 is not a phase name" do
    files =
      Map.update!(base_files(), "ci.yml", &String.replace(&1, "name: ci\n", "name: ci p50\n"))

    assert workflow_violations(files) == []
  end

  test "the real .github tree holds exactly the allowed files" do
    {out, 0} = System.cmd("git", ~w(ls-files -z --cached --others --exclude-standard -- .github))

    files =
      out
      |> String.split("\0", trim: true)
      |> Enum.map(&String.replace_prefix(&1, ".github/", ""))

    assert inventory_violations(files) == []
  end

  test "a fourth workflow fails the inventory" do
    assert [{:github_files, _, _}] = inventory_violations(@github_files ++ ["workflows/e2e.yml"])
  end

  test "an extra file under .github/actions fails the inventory" do
    assert [{:github_files, _, _}] =
             inventory_violations(@github_files ++ ["actions/other/action.yml"])
  end

  test "a JavaScript file under .github fails the inventory" do
    assert [{:github_files, _, _}] =
             inventory_violations(@github_files ++ ["actions/setup/index.js"])
  end

  test "a package.json under .github fails the inventory" do
    assert [{:github_files, _, _}] = inventory_violations(@github_files ++ ["package.json"])
  end

  test "the real mix config and ExUnit configuration pin the test wiring" do
    config = Mix.Project.config()
    task_names = if File.dir?("lib/mix/tasks"), do: File.ls!("lib/mix/tasks"), else: []

    assert wiring_violations(config, ExUnit.configuration(), ci?()) == []
    assert Enum.filter(task_names, &phase?/1) == []
  end

  test "a ci alias without its exact test step fails" do
    config = put_alias(wiring_config(), :ci, ["format --check-formatted", "test"])

    assert fired_wiring(config) == [:ci_alias]
  end

  test "a phase-numbered alias name fails" do
    config = put_alias(wiring_config(), :"verify.phase1", ["test"])

    assert fired_wiring(config) == [:phase_name]
  end

  test "an ignore filter that ignores a contract test fails" do
    config =
      Keyword.put(wiring_config(), :test_ignore_filters, [&String.starts_with?(&1, "test/")])

    assert fired_wiring(config) == [:ignore_filters]
  end

  test "an ignore filter that ignores a planning test fails" do
    config =
      Keyword.put(wiring_config(), :test_ignore_filters, ["test/fixtures/x.ex", ~r/planning/])

    assert fired_wiring(config) == [:ignore_filters]
  end

  test "an ignore filter that stops ignoring fixtures fails" do
    config = Keyword.put(wiring_config(), :test_ignore_filters, [])

    assert fired_wiring(config) == [:ignore_filters]
  end

  test "test_paths, test_pattern and test_load_filters overrides fail" do
    for key <- [:test_paths, :test_pattern, :test_load_filters] do
      assert fired_wiring(Keyword.put(wiring_config(), key, ["x"])) == [:test_path_override]
    end
  end

  test "an ExUnit exclude outside the allowed tags fails" do
    assert fired_wiring(wiring_config(), exclude: [:prod_guard, :slow]) == [:excludes]
    assert fired_wiring(wiring_config(), exclude: [:test]) == [:excludes]
    assert fired_wiring(wiring_config(), exclude: [:test], include: [location: {"x", 1}]) == []
  end

  test "excluding :git_diff while CI is set fails" do
    assert fired_wiring(wiring_config(), [exclude: [:git_diff]], true) == [:git_diff_excluded]
    assert fired_wiring(wiring_config(), [exclude: [:git_diff]], false) == []
  end

  defp workflow_violations(_files), do: []

  defp inventory_violations(_paths), do: []

  defp wiring_violations(_config, _exunit, _ci?), do: []

  defp phase?(_text), do: false

  defp fired(files), do: files |> workflow_violations() |> Enum.map(&elem(&1, 0)) |> Enum.uniq()

  defp fired_wiring(config, exunit \\ [exclude: [:prod_guard, :release]], ci? \\ false) do
    config |> wiring_violations(exunit, ci?) |> Enum.map(&elem(&1, 0)) |> Enum.uniq()
  end

  defp wiring_config do
    [
      aliases: [ci: ["format --check-formatted", @ci_test_step]],
      test_ignore_filters: [&String.starts_with?(&1, "test/fixtures/")]
    ]
  end

  defp put_alias(config, name, steps),
    do: Keyword.update!(config, :aliases, &Keyword.put(&1, name, steps))

  defp ci?, do: System.get_env("CI") not in [nil, ""]

  defp real_files do
    workflows = Map.new(@workflows, &{&1, File.read!(".github/workflows/" <> &1)})
    Map.put(workflows, "action.yml", File.read!(".github/actions/setup/action.yml"))
  end

  defp base_files, do: Map.put(real_files(), "ci.yml", File.read!(@base))
end
