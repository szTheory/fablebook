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
    {:anchor, "ci.yml", "    runs-on: ubuntu-24.04\n    timeout-minutes: 30\n",
     "    runs-on: *runner\n    timeout-minutes: 30\n"},
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

  defp workflow_violations(files) do
    workflows = Map.take(files, @workflows)

    Enum.flat_map(files, &text_violations/1) ++
      Enum.flat_map(workflows, &timeout_violations/1) ++
      ci_violations(files["ci.yml"]) ++
      gate_count_violations(workflows) ++
      check(newlines(files["ci.yml"]) <= 250, {:ci_lines, "ci.yml", newlines(files["ci.yml"])}) ++
      check(
        newlines(files["action.yml"]) <= 60,
        {:action_lines, "action.yml", newlines(files["action.yml"])}
      )
  end

  defp text_violations({file, text}) do
    numbered = text |> lines() |> Enum.with_index(1)

    Enum.flat_map(numbered, &line_violations(file, &1)) ++
      for(ref <- uses_refs(text), violation <- uses_violations(file, ref), do: violation) ++
      node_violations(file, text) ++
      for(
        [match] <- Regex.scan(~r/(?i)phase[-_. ]?\d+|verify\.phase/, text),
        do: {:phase_name, file, match}
      )
  end

  defp line_violations(file, {line, n}) do
    at = "#{file}:#{n}"

    check(not String.contains?(line, "\t"), {:tab, at, line}) ++
      check(not (line =~ ~r/(?:\A|:\s+|-\s+)[&*][A-Za-z_]/), {:anchor, at, line}) ++
      check(not String.contains?(line, "<<:"), {:merge_key, at, line}) ++
      check(String.length(line) <= 120, {:line_length, at, String.length(line)}) ++
      check(not (line =~ ~r/\A\s*(?:- )?paths(?:-ignore)?:/), {:paths_filter, at, line}) ++
      image_violations(at, line)
  end

  defp image_violations(at, line) do
    case Regex.run(~r/\A\s*(?:- )?(?:image|container):\s*(\S.*)\z/, line) do
      [_, ref] -> check(ref =~ ~r/@sha256:[0-9a-f]{64}\z/, {:unpinned_image, at, ref})
      nil -> []
    end
  end

  defp uses_refs(text) do
    for line <- lines(text), [_, value] <- [Regex.run(~r/\A\s*(?:- )?uses:(.*)\z/, line)] do
      case Regex.run(~r/\A\s*(\S+)(?:\s+#.*)?\z/, value) do
        [_, ref] -> ref
        nil -> String.trim(value)
      end
    end
  end

  defp uses_violations(file, "./.github/workflows/" <> _ = ref),
    do: check(ref == @allowed_reusable[file], {:reusable, file, ref})

  defp uses_violations(file, ref), do: check(pinned?(ref), {:unpinned_uses, file, ref})

  defp pinned?(ref) do
    ref == "./.github/actions/setup" or
      ref =~ ~r/\A[\w.-]+\/[\w.-]+(?:\/[\w.\/-]+)?@[0-9a-f]{40}\z/ or
      ref =~ ~r/\Adocker:\/\/\S+@sha256:[0-9a-f]{64}\z/
  end

  defp node_violations(file, text) do
    for {segment, body} <- segments(file, text),
        segment not in @node_jobs,
        Enum.any?(body, &(&1 =~ ~r/\b(?:setup-node|npm|npx|pnpm|yarn|node|bun|deno|corepack)\b/)),
        do: {:node, file, segment}
  end

  defp segments("action.yml", text), do: [{"action.yml", lines(text)}]

  defp segments(_file, text) do
    [{"(workflow)", text |> lines() |> Enum.take_while(&(&1 != "jobs:"))} | jobs(text)]
  end

  defp timeout_violations({file, text}) do
    for {id, body} <- jobs(text),
        key(body, "uses") == nil,
        violation <- timeout(file, id, key(body, "timeout-minutes")),
        do: violation
  end

  defp timeout(file, id, nil), do: [{:no_timeout, file, id}]
  defp timeout(file, id, value), do: check(value =~ ~r/\A\d+\z/, {:timeout_not_literal, file, id})

  defp gate_count_violations(workflows) do
    gates = for {file, text} <- workflows, {"ci-gate", _} <- jobs(text), do: file

    check(gates == ["ci.yml"], {:ci_gate_count, "ci-gate", gates})
  end

  defp ci_violations(text) do
    jobs = jobs(text)
    job = &(List.keyfind(jobs, &1, 0, {&1, []}) |> elem(1))

    check(not String.contains?(text, "workflow_call"), {:workflow_call, "ci.yml", nil}) ++
      for(
        {line, n} <- Enum.with_index(lines(text), 1),
        bypass?(line),
        do: {:bypass, "ci.yml:#{n}", line}
      ) ++
      check(step?(job.("core"), &("run: mix ci" in &1)), {:core_mix_ci, "core", nil}) ++
      check(step?(job.("core"), &full_checkout?/1), {:core_fetch_depth, "core", nil}) ++
      check(
        "  EVENT_BEFORE: ${{ github.event.before }}" in workflow_env(text),
        {:event_before, "env", nil}
      ) ++
      check(
        step?(job.("ci-health"), &("run: mix test test/contract/ci_shape_test.exs" in &1)),
        {:ci_health_shape, "ci-health", nil}
      ) ++
      check(step?(job.("ci-health"), &regression_step?/1), {:ci_health_failure, "ci-health", nil}) ++
      check(step?(job.("nightly"), &regression_step?/1), {:nightly_failure, "nightly", nil}) ++
      gate_violations(jobs)
  end

  defp gate_violations(jobs) do
    case List.keyfind(jobs, "ci-gate", 0) do
      nil ->
        []

      {_, body} ->
        gate_body_violations(
          body,
          for({id, _} <- jobs, id != "ci-gate", id not in @schedule_only, do: id)
        )
    end
  end

  defp gate_body_violations(body, expected_needs) do
    check(key(body, "if") == "always()", {:ci_gate_always, "ci-gate", key(body, "if")}) ++
      check(key(body, "strategy") == nil, {:ci_gate_strategy, "ci-gate", nil}) ++
      check(
        MapSet.new(needs(body)) == MapSet.new(expected_needs),
        {:ci_gate_needs, "ci-gate", needs(body)}
      ) ++
      check(step?(body, &gate_step?/1), {:ci_gate_step, "ci-gate", nil})
  end

  defp gate_step?(step) do
    text = Enum.join(step, "\n")

    Enum.all?(
      ["toJSON(needs)", "jq -e", "nightly", "release-please--"],
      &String.contains?(text, &1)
    )
  end

  defp full_checkout?(step) do
    Enum.any?(step, &String.starts_with?(&1, "uses: actions/checkout@")) and
      "fetch-depth: 0" in step
  end

  defp regression_step?(step) do
    Enum.any?(step, &(&1 =~ ~r/\Aif: failure\(\)(?:\s|\z)/)) and
      Enum.any?(step, &String.starts_with?(&1, "run: bin/ci_health --file-regression "))
  end

  defp bypass?(line) do
    line =~
      ~r/continue-on-error|\|\|\s*(?:true|:)(?=\s|;|\z)|\bset \+[a-zA-Z]*e|\bif:\s*(?:false|\$\{\{\s*false\s*\}\})\s*\z/
  end

  defp workflow_env(text) do
    text
    |> lines()
    |> Enum.drop_while(&(&1 != "env:"))
    |> Enum.drop(1)
    |> Enum.take_while(&String.starts_with?(&1, "  "))
  end

  defp jobs(text) do
    text
    |> lines()
    |> Enum.drop_while(&(&1 != "jobs:"))
    |> Enum.drop(1)
    |> Enum.take_while(&(not (&1 =~ ~r/\A[^\s#]/)))
    |> Enum.reduce([], &add_job_line/2)
    |> Enum.map(fn {id, body} -> {id, Enum.reverse(body)} end)
    |> Enum.reverse()
  end

  defp add_job_line(line, acc) do
    case {Regex.run(~r/\A  ([\w-]+):\s*\z/, line), acc} do
      {[_, id], _} -> [{id, []} | acc]
      {nil, [{id, body} | rest]} -> [{id, [line | body]} | rest]
      {nil, []} -> []
    end
  end

  defp key(body, name) do
    prefix = "    #{name}:"

    Enum.find_value(
      body,
      &(String.starts_with?(&1, prefix) && String.trim(String.replace_prefix(&1, prefix, "")))
    )
  end

  defp needs(body) do
    case key(body, "needs") do
      nil ->
        []

      "" ->
        body |> Enum.drop_while(&(&1 != "    needs:")) |> Enum.drop(1) |> block_items()

      "[" <> list ->
        list
        |> String.trim_trailing("]")
        |> String.split(",", trim: true)
        |> Enum.map(&String.trim/1)

      one ->
        [one]
    end
  end

  defp block_items(lines) do
    for "      - " <> item <- Enum.take_while(lines, &String.starts_with?(&1, "      - ")),
        do: String.trim(item)
  end

  defp step?(body, predicate), do: Enum.any?(steps(body), predicate)

  defp steps(body) do
    body
    |> Enum.drop_while(&(&1 != "    steps:"))
    |> Enum.drop(1)
    |> Enum.take_while(&(&1 == "" or String.starts_with?(&1, "      ")))
    |> Enum.reduce([], &add_step_line/2)
    |> Enum.map(&Enum.reverse/1)
  end

  defp add_step_line("      - " <> first, acc), do: [[String.trim(first)] | acc]
  defp add_step_line(line, [step | rest]), do: [[String.trim(line) | step] | rest]
  defp add_step_line(_line, []), do: []

  defp inventory_violations(paths) do
    check(
      Enum.sort(paths) == Enum.sort(@github_files),
      {:github_files, ".github", paths -- @github_files}
    )
  end

  defp wiring_violations(config, exunit, ci?) do
    aliases = Keyword.get(config, :aliases, [])
    filters = Keyword.get(config, :test_ignore_filters, [])
    excludes = Enum.map(Keyword.get(exunit, :exclude, []), &tag_name/1)
    include? = Keyword.get(exunit, :include, []) != []

    check(@ci_test_step in List.wrap(aliases[:ci]), {:ci_alias, "mix.exs", aliases[:ci]}) ++
      for(
        {name, steps} <- aliases,
        text <- alias_texts(name, steps),
        phase?(text),
        do: {:phase_name, "mix.exs", text}
      ) ++
      check(
        ignored?(filters, "test/fixtures/x.ex"),
        {:ignore_filters, "mix.exs", "test/fixtures/x.ex"}
      ) ++
      for(
        path <- ~w(test/contract/x_test.exs test/planning/x_test.exs),
        ignored?(filters, path),
        do: {:ignore_filters, "mix.exs", path}
      ) ++
      for(
        key <- [:test_paths, :test_pattern, :test_load_filters],
        Keyword.has_key?(config, key),
        do: {:test_path_override, "mix.exs", key}
      ) ++
      for(
        tag <- excludes,
        tag not in @allowed_excludes,
        not (tag == :test and include?),
        do: {:excludes, "test_helper.exs", tag}
      ) ++
      check(
        not (ci? and :git_diff in excludes),
        {:git_diff_excluded, "test_helper.exs", :git_diff}
      )
  end

  defp alias_texts(name, steps),
    do: [to_string(name) | Enum.filter(List.wrap(steps), &is_binary/1)]

  defp tag_name({tag, _value}), do: tag
  defp tag_name(tag), do: tag

  defp ignored?(filters, path), do: Enum.any?(filters, &filter_matches?(&1, path))

  defp filter_matches?(%Regex{} = regex, path), do: Regex.match?(regex, path)
  defp filter_matches?(file, path) when is_binary(file), do: file == path
  defp filter_matches?(fun, path) when is_function(fun, 1), do: fun.(path)

  defp phase?(text), do: text =~ ~r/(?i)phase[-_. ]?\d+|verify\.phase/

  defp check(true, _violation), do: []
  defp check(false, violation), do: [violation]

  defp lines(text), do: String.split(text, "\n")

  defp newlines(text), do: length(:binary.matches(text, "\n"))

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
