defmodule Fablebook.Planning.PlanningStateTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.PlanningState

  @moduletag :planning
  @moduletag :tmp_dir
  @mapping ".planning/migrations/2026-11-11-milestone-reset/PHASE-MAP.json"
  @gates ".planning/references/PLANNING-GATES.json"
  @deliveries ".planning/references/PHASE-DELIVERIES.json"

  setup %{tmp_dir: root} do
    fixture(root)
    %{root: root}
  end

  test "the current project has coherent canonical planning owners" do
    assert %{errors: []} = PlanningState.check(File.cwd!())
  end

  test "the future backlog retains every original requirement and legacy phase owner" do
    original = File.read!(".planning/milestones/v0.1-REQUIREMENTS.md")
    current = File.read!(".planning/references/PRODUCT-REQUIREMENTS.md")
    original_entries = requirement_citations(original)
    current_entries = requirement_citations(current)

    for {id, citations} <- original_entries do
      matches = Enum.filter(current_entries, fn {current_id, _} -> current_id == id end)
      assert [{^id, retained}] = matches
      assert citations -- retained == []
    end

    receipt =
      read_json(
        File.cwd!(),
        ".planning/migrations/2026-11-11-milestone-reset/INITIAL-RECEIPT.json"
      )

    mapping = read_json(File.cwd!(), @mapping)

    assert Enum.sort(Enum.map(receipt["phase_map"], & &1["legacy_phase"])) ==
             Enum.sort(Enum.map(mapping["future_phases"], & &1["legacy_phase"]))
  end

  @tag :git_diff
  test "merged delivery receipts are append-only against the diff base" do
    base = Application.fetch_env!(:fablebook, :diff_base)

    case System.cmd("git", ["show", "#{base}:#{@deliveries}"], stderr_to_stdout: true) do
      {previous, 0} ->
        records = read_json(File.cwd!(), @deliveries)["phases"]
        for entry <- JSON.decode!(previous)["phases"], do: assert(entry in records)

      {_missing_on_initial_add, _} ->
        {_, 0} = System.cmd("git", ["cat-file", "-e", "#{base}^{commit}"])
    end
  end

  test "each workflow boundary requires its actual preceding artifacts", %{root: root} do
    assert_ok(root, "status")
    assert_ok(root, "discuss")
    assert_error(root, "plan", "context_missing")
    context(root)
    assert_ok(root, "plan")
    assert_error(root, "execute", "plans_missing")
    plan(root)
    assert_ok(root, "execute")
    assert_error(root, "verify", "summary_missing")
    summary(root, "halted")
    assert_error(root, "verify", "summary_incomplete")
    summary(root)
    assert_ok(root, "verify")
    assert_error(root, "ship", "verification_missing")
    report(root, "failed")
    assert_error(root, "ship", "verification_not_passed")
    report(root)
    assert_ok(root, "ship")
    assert_error(root, "milestone-close", "milestone_unfinished")
    assert_error(root, "milestone-start", "phase_not_delivered")
    complete(root)
    assert_error(root, "milestone-close", "phase_not_delivered")
    deliver(root)
    assert_ok(root, "milestone-close")
    assert_ok(root, "milestone-start")
  end

  test "a completed phase awaiting its merge receipt cannot silently execute again", %{root: root} do
    context(root)
    plan(root)
    summary(root)
    report(root)
    complete(root)
    assert_error(root, "execute", "completed_phase_reentry")
    assert_ok(root, "ship")
    assert_error(root, "milestone-close", "phase_not_delivered")
  end

  test "a bounded increment closes with its own delivery while the global gate stays open", %{
    root: root
  } do
    context(root)
    plan(root)
    summary(root)
    report(root)
    complete(root)
    deliver(root)
    assert_ok(root, "milestone-close")
    assert read_json(root, @gates)["gates"] |> hd() |> Map.fetch!("status") == "open"
  end

  test "delivered IDs stay unique across milestones", %{root: root} do
    activate(root, "v0.2", "guard-recovery", ["1", "2"], "2")
    deliver(root)
    result = PlanningState.check(root)
    assert result.errors == []
    assert result.route_phase == "2"

    for stage <- ~w(discuss plan execute) do
      assert "delivered_phase_reentry" in codes(PlanningState.check(root, stage, "1"))
    end

    activate(root, "v0.3", "guard-recovery", ["2"], "2")
    assert_ok(root, "discuss")
    assert PlanningState.check(root).route_phase == "2"
    assert_error(root, "discuss", "requested_phase", "01.1.1.18")

    deliver(root, "v0.3", "guard-recovery", "1")
    assert_error(root, "status", "duplicate_delivery")
  end

  test "a decorated generated milestone is accepted but stale phase and milestone caches fail", %{
    root: root
  } do
    update_json(
      root,
      ".planning/state.json",
      &Map.put(&1, "milestone", "v0.2 — A bounded milestone")
    )

    assert_ok(root, "status")
    update_json(root, ".planning/state.json", &Map.put(&1, "milestone", "v0.1 — old"))
    assert_error(root, "status", "snapshot_milestone")
    activate(root, "v0.3", "guard-recovery", ["1", "2"], "2")

    update_json(
      root,
      ".planning/state.json",
      &Map.put(&1, "phases", [%{"number" => "1", "name" => "wrong"}])
    )

    assert_error(root, "status", "snapshot_phases")
    assert_error(root, "status", "snapshot_phase_name")
  end

  test "active numbering, directories, requirement owners and copied old plans fail closed", %{
    root: root
  } do
    activate(root, "v0.3", "guard-recovery", ["1", "3"], "1")
    assert_error(root, "status", "phase_sequence")
    activate(root, "v0.3", "guard-recovery", ["1", "01"], "1")
    assert_error(root, "status", "duplicate_phase")
    activate(root, "v0.3", "guard-recovery", ["01.1"], "01.1")
    assert_error(root, "status", "active_phase_ids")
    activate(root, "v0.3", "guard-recovery", ["1"], "1")
    write(root, ".planning/phases/01.1-old/old.md", "historical")
    assert_error(root, "status", "unowned_active_directory")
    File.rm_rf!(Path.join(root, ".planning/phases/01.1-old"))

    write(
      root,
      ".planning/REQUIREMENTS.md",
      "- [ ] **GRC-01**: scope\n| GRC-01 | Phase 9 | Pending |\n"
    )

    assert_error(root, "status", "requirement_owner")
    write(root, ".planning/REQUIREMENTS.md", "- [ ] **GRC-01**: scope\n")
    assert_error(root, "status", "requirement_trace")
    context(root)
    plan(root, "01.1.1.18-old-owner")
    assert_error(root, "plan", "plan_owner")
  end

  test "future prerequisites reject unknown references and cycles", %{root: root} do
    update_json(root, @mapping, fn mapping ->
      put_in(mapping, ["future_phases", Access.at(0), "depends_on"], ["missing:1"])
    end)

    assert_error(root, "status", "unknown_prerequisite")

    update_json(root, @mapping, fn mapping ->
      mapping
      |> put_in(["future_phases", Access.at(0), "depends_on"], ["story-model:2"])
      |> put_in(["future_phases", Access.at(1), "depends_on"], ["story-model:1"])
    end)

    assert_error(root, "status", "dependency_cycle")
  end

  test "typed prerequisites require merged receipts before later implementation", %{root: root} do
    deliver(root)

    update_json(root, @mapping, fn mapping ->
      mapping
      |> put_in(["future_phases", Access.at(0), "phase"], 2)
      |> put_in(["future_phases", Access.at(1), "phase"], 3)
      |> put_in(["future_phases", Access.at(1), "depends_on"], ["story-model:2"])
      |> put_in(["future_phases", Access.at(2), "phase"], 4)
      |> put_in(["future_phases", Access.at(2), "depends_on"], ["story-model:3"])
    end)

    update_json(root, @gates, &put_in(&1, ["requirement_owners", "SEC-01"], "controls-bundle:4"))

    activate(root, "v0.3", "story-model", ["2", "3"], "3")
    plan(root, "3", "3")
    assert_error(root, "execute", "prerequisite_not_delivered")
    deliver(root, "v0.3", "story-model", "2")
    assert_ok(root, "execute")
    activate(root, "v0.4", "controls-bundle", ["4"], "4")
    plan(root, "4", "4")
    assert_error(root, "execute", "prerequisite_not_delivered")
    deliver(root, "v0.3", "story-model", "3")
    assert_ok(root, "execute")
  end

  test "initial global Phase 1 can start but cannot bypass its aggregate gate", %{root: root} do
    activate(root, "v0.9", "walking-skeleton", ["1"], "1")
    assert_error(root, "discuss", "milestone_prerequisite_open")

    update_json(root, @gates, fn registry ->
      put_in(registry, ["gates", Access.at(0), "status"], "closed")
    end)

    assert_error(root, "discuss", "gate_closure_missing")

    write(
      root,
      ".planning/audits/aggregate.md",
      "---\nstatus: passed\ngoal_scope: partial-slice\n---\n"
    )

    update_json(root, @gates, fn registry ->
      put_in(registry, ["gates", Access.at(0), "closure"], %{
        "report" => ".planning/audits/aggregate.md"
      })
    end)

    assert_error(root, "discuss", "gate_closure_scope")

    write(
      root,
      ".planning/audits/aggregate.md",
      "---\nstatus: passed\ngoal_scope: guard-aggregate\n---\n"
    )

    assert_ok(root, "discuss")
  end

  test "lost seed targets, global requirement owners and disabled gates are rejected", %{
    root: root
  } do
    write(
      root,
      ".planning/seeds/SEED-sample.md",
      "---\ntarget_milestone: missing\ntarget_phase: 17\n---\n"
    )

    assert_error(root, "status", "seed_target")
    update_json(root, @gates, &put_in(&1, ["requirement_owners", "SEC-01"], "missing:5"))
    assert_error(root, "status", "global_requirement_owner")
    update_json(root, ".planning/config.json", &put_in(&1, ["workflow", "verifier"], false))
    assert_error(root, "status", "required_gate_disabled")
  end

  test "removing the aggregate gate or security owner cannot make activation look ready", %{
    root: root
  } do
    update_json(root, @gates, &Map.put(&1, "gates", []))
    assert_error(root, "status", "aggregate_gate_missing")
    update_json(root, @gates, &Map.put(&1, "requirement_owners", %{}))
    assert_error(root, "status", "security_owner_missing")
    update_json(root, @deliveries, &Map.put(&1, "schema", "other"))
    assert_error(root, "status", "delivery_schema")
  end

  test "missing or malformed delivery registry cannot silently unblock a phase", %{root: root} do
    deliver(root)

    update_json(root, @deliveries, fn registry ->
      Map.update!(registry, "phases", fn records -> records ++ records end)
    end)

    assert_error(root, "status", "duplicate_delivery")

    update_json(
      root,
      @deliveries,
      &put_in(&1, ["phases", Access.at(0), "reviewed_head"], "unreviewed")
    )

    assert_error(root, "status", "invalid_delivery")
    write(root, @deliveries, "{")
    assert_error(root, "status", "planning_input_invalid")
  end

  test "a delivery cannot be borrowed from another milestone owner with the same version", %{
    root: root
  } do
    deliver(root, "v0.2", "story-model", "1")
    assert_error(root, "status", "delivery_milestone_owner")
  end

  test "between-milestone planning is supported without borrowing another milestone's shipped status",
       %{root: root} do
    File.rm_rf!(Path.join(root, ".planning/phases"))
    write(root, ".planning/ROADMAP.md", "# Defining next scope\n")

    write(
      root,
      ".planning/STATE.md",
      "---\nmilestone: v0.3\ncurrent_phase: null\nstatus: planning\n---\n"
    )

    write_json(root, ".planning/state.json", %{"milestone" => "v0.3", "phases" => []})
    write(root, ".planning/MILESTONES.md", "## v0.2 Earlier (Shipped: 2026-11-11)\n")
    assert_ok(root, "status")
    assert_ok(root, "milestone-start")
    assert_error(root, "execute", "no_active_milestone")

    write(
      root,
      ".planning/STATE.md",
      "---\nmilestone: v0.3\ncurrent_phase: null\nstatus: complete\n---\n"
    )

    write(root, ".planning/milestones/v0.3-ROADMAP.md", "preserved")
    write(root, ".planning/milestones/v0.3-REQUIREMENTS.md", "preserved")

    write(
      root,
      ".planning/MILESTONES.md",
      "## v0.3 Current incomplete\n\n## v0.2 Earlier (Shipped: 2026-11-11)\n"
    )

    assert_error(root, "status", "active_phase_ids")

    write(
      root,
      ".planning/MILESTONES.md",
      "## v0.3 Current (Shipped: 2026-11-11)\n\n## v0.2 Earlier\n"
    )

    assert_ok(root, "milestone-start")
  end

  test "unsupported workstream routing and unknown operations stop explicitly", %{root: root} do
    assert_error(root, "guess", "unknown_stage")
    write(root, ".planning/active-workstream", "parallel-track\n")
    assert_error(root, "status", "workstream_requires_scoped_check")
  end

  defp requirement_citations(text) do
    for [_, id, description] <- Regex.scan(~r/^- \[[ x]\] \*\*([A-Z]+-\d+)\*\*:(.*)$/m, text) do
      {id,
       Regex.scan(~r/INT-\d{8}-\d{2}|ADR \d{4}/, description)
       |> List.flatten()
       |> Enum.uniq()
       |> Enum.sort()}
    end
    |> Enum.sort()
  end

  defp fixture(root) do
    write(root, ".planning/PROJECT.md", "# Project\n")
    write(root, ".planning/audits/legacy.md", "Preserved legacy gate\n")

    write_json(root, ".planning/config.json", %{
      "workflow" => %{
        "plan_check" => true,
        "verifier" => true,
        "security_enforcement" => true,
        "auto_advance" => false
      }
    })

    write_json(root, @deliveries, %{"schema" => "fablebook.phase-deliveries/1", "phases" => []})

    write_json(root, @mapping, %{
      "future_phases" => [
        node("2", "story-model", 1, []),
        node("3", "story-model", 2, ["story-model:1"]),
        node("4", "controls-bundle", 1, ["story-model:2"]),
        node("5", "walking-skeleton", 1, ["legacy:guard"])
      ],
      "legacy_dependencies" => %{"legacy:guard" => %{"evidence" => ".planning/audits/legacy.md"}}
    })

    write_json(root, @gates, %{
      "schema" => "fablebook.planning-gates/1",
      "known_increment_milestones" => ["guard-recovery"],
      "automatic_followup" => false,
      "requirement_owners" => %{"SEC-01" => "controls-bundle:1"},
      "gates" => [
        %{
          "id" => "guard-aggregate",
          "status" => "open",
          "closure" => nil,
          "evidence" => ".planning/audits/legacy.md",
          "blocks_milestones" => ["walking-skeleton"]
        }
      ]
    })

    activate(root, "v0.2", "guard-recovery", ["1"], "1")
  end

  defp node(legacy, key, phase, dependencies) do
    %{
      "legacy_phase" => legacy,
      "milestone_key" => key,
      "phase" => phase,
      "depends_on" => dependencies
    }
  end

  defp activate(root, version, key, phases, current) do
    File.rm_rf!(Path.join(root, ".planning/phases"))
    Enum.each(phases, &File.mkdir_p!(Path.join(root, ".planning/phases/#{&1}-slice")))

    headings =
      Enum.map_join(
        phases,
        "\n",
        &"- [ ] **Phase #{&1}: Slice #{&1}**\n### Phase #{&1}: Slice #{&1}\n"
      )

    write(
      root,
      ".planning/ROADMAP.md",
      "# Roadmap: #{version} Test\n**Milestone key:** #{key}\n" <> headings
    )

    write(
      root,
      ".planning/STATE.md",
      "---\nmilestone: #{version}\ncurrent_phase: #{current}\nstatus: planning\n---\nPhase: #{current} of #{length(phases)}\n"
    )

    write(
      root,
      ".planning/REQUIREMENTS.md",
      "- [ ] **GRC-01**: scope\n| GRC-01 | Phase #{current} | Pending |\n"
    )

    write_json(root, ".planning/state.json", %{
      "milestone" => version,
      "phases" => Enum.map(phases, &%{"number" => &1, "name" => "Slice #{&1}"})
    })
  end

  defp context(root),
    do: write(root, ".planning/phases/1-slice/1-CONTEXT.md", "Selected bounded scope\n")

  defp plan(root, owner \\ "1", phase \\ "1"),
    do:
      write(
        root,
        ".planning/phases/#{phase}-slice/#{phase}-01-PLAN.md",
        "---\nphase: #{owner}\n---\n"
      )

  defp summary(root, status \\ "complete"),
    do: write(root, ".planning/phases/1-slice/1-01-SUMMARY.md", "---\nstatus: #{status}\n---\n")

  defp report(root, status \\ "passed"),
    do: write(root, ".planning/phases/1-slice/1-VERIFICATION.md", "---\nstatus: #{status}\n---\n")

  defp complete(root) do
    for file <- ~w(ROADMAP.md REQUIREMENTS.md) do
      path = Path.join(root, ".planning/#{file}")
      File.write!(path, path |> File.read!() |> String.replace("- [ ]", "- [x]"))
    end
  end

  defp deliver(root, version \\ "v0.2", key \\ "guard-recovery", phase \\ "1") do
    update_json(root, @deliveries, fn registry ->
      record = %{
        "milestone" => version,
        "milestone_key" => key,
        "phase" => phase,
        "status" => "merged",
        "pr" => 1,
        "reviewed_head" => String.duplicate("a", 40),
        "merge_commit" => String.duplicate("b", 40),
        "ci_run" => "https://github.com/example/project/actions/runs/1"
      }

      Map.update!(registry, "phases", &(&1 ++ [record]))
    end)
  end

  defp assert_ok(root, stage), do: assert(PlanningState.check(root, stage).errors == [])

  defp assert_error(root, stage, code, phase \\ nil),
    do: assert(code in codes(PlanningState.check(root, stage, phase)))

  defp codes(result), do: Enum.map(result.errors, & &1.code)
  defp read_json(root, path), do: root |> Path.join(path) |> File.read!() |> JSON.decode!()
  defp update_json(root, path, fun), do: write_json(root, path, fun.(read_json(root, path)))
  defp write_json(root, path, value), do: write(root, path, JSON.encode!(value))

  defp write(root, path, value) do
    target = Path.join(root, path)
    File.mkdir_p!(Path.dirname(target))
    File.write!(target, value)
  end
end
