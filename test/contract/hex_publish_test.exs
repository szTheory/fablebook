defmodule Fablebook.Contract.HexPublishTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  @workflow ".github/workflows/hex-publish.yml"
  @declared ["    secrets:", "      HEX_API_KEY:"]
  @key_env "HEX_API_KEY: ${{ secrets.HEX_API_KEY }}"
  @key_check ~s(run: test -n "$HEX_API_KEY")
  @gate "if: steps.hex.outputs.todo == 'package' || steps.hex.outputs.todo == 'docs'"
  @todo_env "TODO: ${{ steps.hex.outputs.todo }}"
  @before_tag ["uses: ./.github/actions/setup", "run: mix local.hex 2.6.0 --force"]
  @release "https://hex.pm/api/packages/fablebook/releases/0.1.0"
  @sum String.duplicate("c", 64)
  @tarball "tarball"
  @tarball_sum Base.encode16(:crypto.hash(:sha256, @tarball), case: :lower)

  @git_env [{"GIT_DIR", nil}, {"GIT_WORK_TREE", nil}, {"GIT_INDEX_FILE", nil}]
  @identity ~w(-c user.name=fixture -c user.email=fixture@localhost
               -c commit.gpgsign=false -c tag.gpgsign=false)

  @curl ~S"""
  #!/bin/sh
  printf '%s\n' "$@" > curl.args
  while [ "$#" -gt 0 ]; do
    if [ "$1" = -o ]; then printf '%s' "$FAKE_BODY" > "$2"; fi
    shift
  done
  printf '%s' "$FAKE_STATUS"
  """

  @mix ~S"""
  #!/bin/sh
  printf '%s\n' "$*" >> mix.log
  if [ "$1" = hex.build ]; then
    while [ "$#" -gt 0 ]; do
      if [ "$1" = --output ]; then printf tarball > "$2"; fi
      shift
    done
  fi
  printf '%s' "${TAG#v}"
  """

  @hex_cases [
    {"released with docs", "200", ~s({"checksum":"#{@sum}","has_docs":true}), 0, "todo=none\n"},
    {"released without docs", "200", ~s({"checksum":"#{@sum}","has_docs":false}), 0,
     "todo=docs\n"},
    {"not released", "404", ~s({"message":"Page not found"}), 0, "todo=package\n"},
    {"checksum mismatch", "200", ~s({"checksum":"#{String.duplicate("d", 64)}","has_docs":true}),
     1, ""},
    {"any other status", "500", "", 1, ""}
  ]

  @publish_cases [
    {"package", "package", @tarball_sum, nil, 0,
     ["local.hex 2.6.0 --force", "hex.build --output fablebook-0.1.0.tar", "hex.publish --yes"]},
    {"docs", "docs", @tarball_sum, nil, 0, ["local.hex 2.6.0 --force", "hex.publish docs --yes"]},
    {"checksum mismatch", "package", String.duplicate("d", 64), nil, 1,
     ["local.hex 2.6.0 --force", "hex.build --output fablebook-0.1.0.tar"]},
    {"empty todo", "", @tarball_sum, nil, 1, ["local.hex 2.6.0 --force"]},
    {"foreign commit", "package", @tarball_sum, String.duplicate("0", 40), 1, []}
  ]

  @step_counts %{"build" => 10, "publish" => 5, "smoke" => 4, "finalize" => 1}
  @built "${{ needs.build.outputs.sha }}"
  @lanes "    # lanes\n"
  @smoke_setup "      - uses: ./.github/actions/setup\n        with:\n          lane:"

  @mutations [
    {:ancestry, "ref: refs/tags/${{ inputs.tag }}", "ref: ${{ inputs.tag }}"},
    {:ancestry, ~s("$sha" origin/main), ~s("$sha" HEAD)},
    {:ancestry, ~s|if [ "$(git rev-parse HEAD)" != "$sha" ]; then|, "if false; then"},
    {:ancestry, ~s(is not on main"\n            exit 1\n), ~s(is not on main"\n)},
    {:ancestry, "if ! git merge-base",
     "if git rev-parse -q --verify origin/main && ! git merge-base"},
    {:ancestry_order, {:move, "      - id: ref", "      - run: mix local.hex 2.6.0 --force"}},
    {:ancestry_order, {:move, "      - id: sbom", "      - id: tag"}},
    {:publish_gate, "    needs: build\n", "    needs: build\n    if: always()\n"},
    {:bypass, "      - id: tag\n", "      - id: tag\n        continue-on-error: true\n"},
    {:bypass, "      - id: hex\n", "      - id: hex\n        shell: sh\n"},
    {:todo, "todo=none; else todo=docs", "todo=none; else todo=none"},
    {:todo, "404) todo=package", "404) todo=none"},
    {:todo, "$SHA256\"\n                exit 1\n", "$SHA256\"\n"},
    {:todo, ~s(fablebook $V"; exit 1 ;;), ~s(fablebook $V"; todo=package ;;)},
    {:todo, "releases/$V", "releases/latest"},
    {:todo_gate, "      - #{@gate}\n        uses: actions/checkout@",
     "      - uses: actions/checkout@"},
    {:todo_gate, " || steps.hex.outputs.todo == 'docs'\n        env:", "\n        env:"},
    {:publish_cmd, "mix hex.publish docs --yes", "mix hex.publish --yes"},
    {:publish_cmd, @todo_env, "TODO: ${{ steps.hex.outputs.published }}"},
    {:publish_cmd, ~s($sum, the build produced $SHA256"\n                exit 1\n),
     ~s($sum, the build produced $SHA256"\n)},
    {:publish_cmd, ~s([ "$sum" != "$SHA256" ]), ~s([ "$sum" != "$sum" ])},
    {:publish_cmd,
     ~s|          if [ "$(git rev-parse HEAD)" != "$COMMIT" ]; then\n| <>
       ~s|            echo "::error::the checkout is not the commit the build tested ($COMMIT)"\n| <>
       "            exit 1\n          fi\n", ""},
    {:publish_cmd, "*) echo \"::error::unknown publish todo '$TODO'\"; exit 1 ;;",
     "*) mix hex.publish --yes ;;"},
    {:step_if, "      - id: ref\n", "      - id: ref\n        if: false\n"},
    {:step_if, "      - id: hex\n", "      - id: hex\n        if: false\n"},
    {:step_if, "        #{@key_check}\n", "        if: false\n        #{@key_check}\n"},
    {:todo_gate, "      - #{@gate}\n        uses: actions/checkout@",
     "      - if: steps.hex.outputs.todo != 'none'\n        uses: actions/checkout@"},
    {:job_graph, "    needs: smoke\n", "    needs: build\n"},
    {:checkout, "ref: #{@built}\n          persist-credentials: false\n      - if:",
     "ref: main\n          persist-credentials: false\n      - if:"},
    {:checkout, "ref: #{@built}\n          persist-credentials: false\n      - uses:",
     "ref: ${{ inputs.tag }}\n          persist-credentials: false\n      - uses:"},
    {:secret_scope, "--draft=false\n", "--draft=false\n    env:\n      #{@key_env}\n"},
    {:step_count, "--draft=false\n", "--draft=false\n      - run: echo done\n"},
    {:cache,
     @smoke_setup <> " ${{ matrix.lane }}\n          mix-env: dev\n          cache: 'false'",
     @lanes <>
       @smoke_setup <> " ${{ matrix.lane }}\n          mix-env: dev\n          cache: 'true'"},
    {:secret_scope, "  MIX_ENV: dev\n", "  MIX_ENV: dev\n  #{@key_env}\n"},
    {:secret_scope, "    env:\n      SHA256:", "    env:\n      #{@key_env}\n      SHA256:"},
    {:secret_scope, "          MIX_ENV: test\n",
     "          MIX_ENV: test\n          #{@key_env}\n"},
    {:cache, "cache: 'false'", "cache: 'true'"},
    {:run_expression, ~s("fablebook-$V.tar"),
     ~s("fablebook-${{ steps.tag.outputs.version }}.tar")},
    {:run_expression, ~s(release edit "$TAG"), ~s(release edit "${{ inputs.tag }}")}
  ]

  setup %{tmp_dir: dir} do
    bin = Path.join(dir, "bin")
    File.mkdir_p!(bin)

    for {name, script} <- [{"curl", @curl}, {"mix", @mix}] do
      File.write!(Path.join(bin, name), script)
      File.chmod!(Path.join(bin, name), 0o755)
    end

    :ok
  end

  test "the pre-test gate passes only the tag's own commit, and only when it is on origin/main",
       %{tmp_dir: dir} do
    assert release_gate_violations(workflow(), dir) == []
  end

  test "recovery publishes the package, only the docs or nothing, and fails closed otherwise",
       %{tmp_dir: dir} do
    assert recovery_violations(workflow(), dir) == []
  end

  test "HEX_API_KEY reaches two steps, setups skip the cache and run bodies hold no expression" do
    assert hygiene_violations(workflow()) == []
  end

  test "gate steps run unconditionally, the job graph and checkout refs are pinned" do
    assert graph_violations(workflow()) == []
  end

  test "a four-space comment between steps changes no verdict", %{tmp_dir: dir} do
    commented = String.replace(workflow(), @smoke_setup, @lanes <> @smoke_setup, global: false)

    assert commented != workflow()
    assert release_gate_violations(commented, dir) == []
    assert recovery_violations(commented, dir) == []
    assert hygiene_violations(commented) == []
    assert graph_violations(commented) == []
  end

  for {mutation, i} <- Enum.with_index(@mutations, 1) do
    @tag mutation: mutation, rule: elem(mutation, 0)
    test "mutation #{i} fires exactly #{elem(mutation, 0)}", %{tmp_dir: dir} = tags do
      mutated = mutate(workflow(), tags.mutation)

      assert mutated != workflow()
      assert fired(mutated, dir) == [tags.rule]
    end
  end

  defp mutate(text, {_rule, {:move, first, before}}), do: move_step(text, first, before)
  defp mutate(text, {_rule, from, to}), do: String.replace(text, from, to, global: false)

  defp move_step(text, first, before) do
    {pre, ["  build:" | rest]} = text |> lines() |> Enum.split_while(&(&1 != "  build:"))
    {job, post} = Enum.split_while(rest, &(not job_header?(&1)))
    {lead, [^first | from]} = Enum.split_while(job, &(&1 != first))

    {body, tail} =
      Enum.split_while(from, &(String.starts_with?(&1, "      ") and not step_start?(&1)))

    {head, [^before | _] = target} = Enum.split_while(lead ++ tail, &(&1 != before))

    Enum.join(pre ++ ["  build:" | head] ++ [first | body] ++ target ++ post, "\n")
  end

  defp release_gate_violations(text, dir),
    do: ancestry_violations(text, dir) ++ order_violations(text)

  defp recovery_violations(text, dir),
    do: todo_violations(text, dir) ++ gate_violations(text) ++ publish_violations(text, dir)

  defp hygiene_violations(text),
    do: secret_violations(text) ++ cache_violations(text) ++ expression_violations(text)

  defp fired(text, dir) do
    (release_gate_violations(text, dir) ++
       recovery_violations(text, dir) ++ hygiene_violations(text) ++ graph_violations(text))
    |> Enum.map(&elem(&1, 0))
    |> Enum.uniq()
  end

  defp graph_violations(text),
    do:
      step_if_violations(text) ++
        job_graph_violations(text) ++ checkout_violations(text) ++ step_count_violations(text)

  defp step_if_violations(text) do
    gated = text |> job_steps("publish") |> Enum.filter(&(id(&1) == "hex" or key_check?(&1)))

    for step <- job_steps(text, "build") ++ gated,
        Enum.any?(step, &String.starts_with?(&1, ["      - if:", "        if:"])),
        do: {:step_if, id(step) || action(step)}
  end

  defp job_graph_violations(text) do
    graph = for id <- ~w(publish smoke finalize), do: {id, needs(job(text, id))}

    check(
      graph == [{"publish", ~w(build)}, {"smoke", ~w(build publish)}, {"finalize", ~w(smoke)}],
      {:job_graph, graph}
    )
  end

  defp checkout_violations(text) do
    refs =
      for id <- ~w(publish smoke),
          do: text |> job_steps(id) |> Enum.find([], &checkout?/1) |> ref()

    check(refs == [@built, @built], {:checkout, refs}) ++
      check(
        "sha: ${{ steps.ref.outputs.sha }}" in normalized(job(text, "build")),
        {:checkout, :build_output}
      ) ++
      check("COMMIT: #{@built}" in normalized(job(text, "publish")), {:checkout, :commit_env})
  end

  defp step_count_violations(text) do
    counts = Map.new(jobs(text), fn {id, body} -> {id, length(steps(body))} end)
    check(counts == @step_counts, {:step_count, counts})
  end

  defp ancestry_violations(text, dir) do
    build = job_steps(text, "build")
    ref = build |> Enum.find([], &checkout?/1) |> ref()

    if ref in ["refs/tags/${{ inputs.tag }}", "${{ inputs.tag }}"] do
      gate_cases(pre_test(build), ref, dir)
    else
      [{:ancestry, :unmodeled_ref, ref}]
    end
  end

  defp gate_cases(scripts, ref, dir) do
    {repo, [one, two, three]} = repo!(Path.join(dir, "repo"))

    checkout!(repo, ref, "v1.0.0")
    same_name = gate_run(scripts, dir, repo, "v1.0.0")
    checkout!(repo, ref, "v1.0.1")
    local_main = gate_run(scripts, dir, repo, "v1.0.1")
    git!(repo, ["checkout", "-q", "--detach", three])
    moved = gate_run(scripts, dir, repo, "v1.0.0")
    git!(repo, ~w(update-ref -d refs/remotes/origin/main))
    checkout!(repo, ref, "v1.0.0")
    no_main = gate_run(scripts, dir, repo, "v1.0.0")

    cases = [
      {"tag on main beside a same-named branch", same_name,
       %{exit: 0, head: one, output: "sha=#{one}\nversion=1.0.0\n", errors: []}},
      {"tag only on local main", local_main,
       %{exit: 1, head: two, output: "", errors: ["::error::v1.0.1 is not on main"]}},
      {"checkout is not the tag's commit", moved,
       %{
         exit: 1,
         head: three,
         output: "",
         errors: ["::error::the checkout is not the commit v1.0.0 names"]
       }},
      {"no origin/main", no_main,
       %{exit: 1, head: one, output: "", errors: ["::error::v1.0.0 is not on main"]}}
    ]

    mismatches(:ancestry, for({name, {run, _}, expected} <- cases, do: {name, run, expected})) ++
      for {name, {%{exit: 0}, false}, _} <- cases, do: {:ancestry, name, :built_commit_off_main}
  end

  defp pre_test(build) do
    build
    |> Enum.take_while(&(not (script(&1) =~ ~r/\bmix test\b/)))
    |> Enum.map(&script/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp checkout!(repo, "refs/tags/${{ inputs.tag }}", tag),
    do: git!(repo, ["checkout", "-q", "--detach", "refs/tags/" <> tag])

  defp checkout!(repo, "${{ inputs.tag }}", tag) do
    branch = "refs/remotes/origin/" <> tag

    if ref?(repo, branch),
      do: git!(repo, ["checkout", "-q", "-B", tag, branch]),
      else: git!(repo, ["checkout", "-q", "--detach", "refs/tags/" <> tag])
  end

  defp gate_run(scripts, dir, repo, tag) do
    File.rm(Path.join(repo, "output"))

    {code, log} =
      Enum.reduce_while(scripts, {0, ""}, fn script, {_, log} ->
        {code, more, _} = run(dir, repo, script, [{"TAG", tag}])
        {if(code == 0, do: :cont, else: :halt), {code, log <> more}}
      end)

    head = git!(repo, ~w(rev-parse HEAD))
    built? = head == git!(repo, ["rev-parse", "refs/tags/#{tag}^{commit}"])
    on_main? = ancestor?(repo, head, "refs/remotes/origin/main")
    output = read(Path.join(repo, "output"))

    {%{exit: code, head: head, output: output, errors: errors(log)}, built? and on_main?}
  end

  defp order_violations(text) do
    build = job_steps(text, "build")
    {before_ref, from_ref} = Enum.split_while(build, &(id(&1) != "ref"))
    between = from_ref |> Enum.drop(1) |> Enum.take_while(&(id(&1) != "tag"))
    publish = job(text, "publish")

    check(
      Enum.map(before_ref, &checkout?/1) == [true] and Enum.any?(from_ref, &(id(&1) == "tag")) and
        Enum.all?(between, &(action(&1) in @before_tag)),
      {:ancestry_order, Enum.map(before_ref ++ between, &action/1)}
    ) ++
      check(
        "build" in needs(publish) and key(publish, "if") == nil,
        {:publish_gate, needs(publish), key(publish, "if")}
      ) ++
      for(
        line <- lines(text),
        line =~ ~r/continue-on-error|\A\s*(?:- )?shell:/,
        do: {:bypass, line}
      )
  end

  defp todo_violations(text, dir) do
    script = text |> job_steps("publish") |> find_step("hex") |> script()

    cases =
      for {{name, status, body, exit, output}, i} <- Enum.with_index(@hex_cases) do
        cwd = Path.join(dir, "hex-#{i}")
        env = [{"V", "0.1.0"}, {"SHA256", @sum}, {"FAKE_STATUS", status}, {"FAKE_BODY", body}]
        {code, _log, out} = run(dir, cwd, script, env)
        url = cwd |> Path.join("curl.args") |> read() |> String.split("\n", trim: true)

        {name, %{exit: code, output: out, url: List.last(url)},
         %{exit: exit, output: output, url: @release}}
      end

    mismatches(:todo, cases)
  end

  defp gate_violations(text) do
    {before, from_hex} = text |> job_steps("publish") |> Enum.split_while(&(id(&1) != "hex"))
    after_hex = Enum.drop(from_hex, 1)

    check(after_hex != [], {:todo_gate, :no_hex_step}) ++
      for(step <- before, not key_check?(step), do: {:todo_gate, action(step)}) ++
      for(step <- after_hex, @gate not in normalized(step), do: {:todo_gate, action(step)})
  end

  defp publish_violations(text, dir) do
    step = text |> job_steps("publish") |> Enum.find([], &(script(&1) =~ "hex.publish"))

    cases =
      for {{name, todo, sum, commit, exit, calls}, i} <- Enum.with_index(@publish_cases) do
        cwd = Path.join(dir, "publish-#{i}")
        head = init!(cwd)
        env = [{"TODO", todo}, {"V", "0.1.0"}, {"SHA256", sum}, {"COMMIT", commit || head}]
        {code, _log, _out} = run(dir, cwd, script(step), env)
        mix = cwd |> Path.join("mix.log") |> read() |> String.split("\n", trim: true)

        {name, %{exit: code, mix: mix}, %{exit: exit, mix: calls}}
      end

    check(@todo_env in normalized(step), {:publish_cmd, :todo_env}) ++
      mismatches(:publish_cmd, cases)
  end

  defp secret_violations(text) do
    {preamble, _} = text |> lines() |> Enum.split_while(&(&1 != "jobs:"))
    jobs = jobs(text)
    declared = Enum.filter(preamble, &secret?/1)

    holders =
      for {id, body} <- jobs,
          step <- steps(body),
          Enum.any?(step, &secret?/1),
          do: {id, holder(step)}

    check(declared == @declared, {:secret_scope, declared}) ++
      for(
        {id, body} <- jobs,
        line <- body |> split_steps() |> elem(0),
        secret?(line),
        do: {:secret_scope, id, line}
      ) ++
      check(
        holders == [{"publish", :key_check}, {"publish", :publish}],
        {:secret_scope, holders}
      )
  end

  defp holder(step) do
    lines = normalized(step)

    cond do
      @key_env not in lines -> :other
      @key_check in lines -> :key_check
      script(step) =~ "mix hex.publish" -> :publish
      true -> :other
    end
  end

  defp cache_violations(text) do
    for {id, body} <- jobs(text),
        step <- steps(body),
        "uses: ./.github/actions/setup" in normalized(step),
        "cache: 'false'" not in normalized(step),
        do: {:cache, id}
  end

  defp expression_violations(text) do
    for body <- scripts(lines(text)), String.contains?(body, "${{"), do: {:run_expression, body}
  end

  defp run(dir, cwd, script, env) do
    File.mkdir_p!(cwd)
    File.write!(Path.join(cwd, "step.sh"), script)
    output = Path.join(cwd, "output")
    path = Path.join(dir, "bin") <> ":" <> System.get_env("PATH")

    {log, code} =
      System.cmd("bash", ~w(--noprofile --norc -eo pipefail step.sh),
        cd: cwd,
        env: @git_env ++ [{"PATH", path}, {"GITHUB_OUTPUT", output} | env],
        stderr_to_stdout: true
      )

    {code, log, read(output)}
  end

  defp errors(log), do: List.flatten(Regex.scan(~r/::error::.*/, log))

  defp read(path) do
    case File.read(path) do
      {:ok, text} -> text
      {:error, _} -> ""
    end
  end

  defp repo!(repo) do
    one = init!(repo)
    git!(repo, ~w(update-ref refs/remotes/origin/main HEAD))
    git!(repo, @identity ++ ~w(tag v1.0.0))
    two = commit!(repo, "two")
    git!(repo, @identity ++ ~w(tag v1.0.1))
    three = git!(repo, @identity ++ ~w(commit-tree -p HEAD -m three HEAD^{tree}))
    git!(repo, ["update-ref", "refs/remotes/origin/v1.0.0", three])

    {repo, [one, two, three]}
  end

  defp init!(repo) do
    File.mkdir_p!(repo)
    git!(repo, ~w(init -q -b main))
    commit!(repo, "one")
  end

  defp commit!(repo, message) do
    git!(repo, @identity ++ ["commit", "-q", "--allow-empty", "-m", message])
    git!(repo, ~w(rev-parse HEAD))
  end

  defp git!(dir, args) do
    {out, status} = System.cmd("git", args, cd: dir, env: @git_env, stderr_to_stdout: true)
    assert status == 0, "git #{Enum.join(args, " ")} failed:\n#{out}"
    String.trim(out)
  end

  defp ref?(repo, ref), do: git_status(repo, ["rev-parse", "-q", "--verify", ref]) == 0

  defp ancestor?(repo, commit, ref),
    do: git_status(repo, ["merge-base", "--is-ancestor", commit, ref]) == 0

  defp git_status(repo, args) do
    {_out, status} = System.cmd("git", args, cd: repo, env: @git_env, stderr_to_stdout: true)
    status
  end

  defp mismatches(rule, cases),
    do: for({name, actual, expected} <- cases, actual != expected, do: {rule, name, actual})

  defp checkout?(step), do: String.starts_with?(action(step) || "", "uses: actions/checkout@")

  defp ref(step) do
    Enum.find_value(normalized(step), fn
      "ref: " <> ref -> ref
      _ -> nil
    end)
  end

  defp secret?(line), do: line =~ ~r/HEX_API_KEY|\bsecrets\b/

  defp workflow, do: File.read!(@workflow)

  defp lines(text), do: String.split(text, "\n")

  defp job_header?(line), do: line =~ ~r/\A  [\w-]+:\s*\z/

  defp step_start?(line), do: String.starts_with?(line, "      -")

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

  defp job(text, id), do: text |> jobs() |> List.keyfind(id, 0, {id, []}) |> elem(1)

  defp job_steps(text, id), do: text |> job(id) |> steps()

  defp steps(body) do
    body
    |> split_steps()
    |> elem(1)
    |> Enum.reduce([], &add_step_line/2)
    |> Enum.map(&Enum.reverse/1)
    |> Enum.reverse()
  end

  defp split_steps(body) do
    {lead, rest} = Enum.split_while(body, &(&1 != "    steps:"))
    {inside, tail} = rest |> Enum.drop(1) |> Enum.split_while(&step_line?/1)
    {lead ++ tail, inside}
  end

  defp step_line?(line),
    do: line == "" or line =~ ~r/\A\s*#/ or String.starts_with?(line, "      ")

  defp key_check?(step), do: @key_check in normalized(step)

  defp add_step_line("      - " <> _ = line, acc), do: [[line] | acc]
  defp add_step_line(line, [step | rest]), do: [[line | step] | rest]
  defp add_step_line(_line, []), do: []

  defp find_step(steps, id), do: Enum.find(steps, [], &(id(&1) == id))

  defp normalized(step),
    do: Enum.map(step, &(&1 |> String.trim() |> String.replace_prefix("- ", "")))

  defp id(step) do
    Enum.find_value(normalized(step), fn
      "id: " <> id -> id
      _ -> nil
    end)
  end

  defp action(step), do: Enum.find(normalized(step), &String.starts_with?(&1, ["uses:", "run:"]))

  defp key(body, name) do
    prefix = "    #{name}:"

    Enum.find_value(
      body,
      &(String.starts_with?(&1, prefix) && String.trim(String.replace_prefix(&1, prefix, "")))
    )
  end

  defp needs(body), do: String.split(key(body, "needs") || "", ~r/[\[\],\s]+/, trim: true)

  defp script(step), do: step |> scripts() |> List.first("")

  defp scripts(lines) do
    for {line, i} <- Enum.with_index(lines),
        [_, lead, value] <- [Regex.run(~r/\A(\s*(?:- )?)run:\s*(.*)\z/, line)],
        do: body(value, String.length(lead), Enum.drop(lines, i + 1))
  end

  defp body(value, column, rest) do
    if value =~ ~r/\A[|>]/ do
      block = Enum.take_while(rest, &(String.trim(&1) == "" or indent(&1) > column))

      margin =
        block
        |> Enum.reject(&(String.trim(&1) == ""))
        |> Enum.map(&indent/1)
        |> Enum.min(fn -> 0 end)

      Enum.map_join(block, "\n", &String.slice(&1, margin..-1//1)) <> "\n"
    else
      value <> "\n"
    end
  end

  defp indent(line), do: byte_size(line) - byte_size(String.trim_leading(line))

  defp check(true, _violation), do: []
  defp check(false, violation), do: [violation]
end
