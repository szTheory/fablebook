defmodule Fablebook.Test.PlanningState do
  @moduledoc false

  @stages ~w(status discuss plan execute verify ship milestone-start milestone-close)
  @map ".planning/migrations/2026-11-11-milestone-reset/PHASE-MAP.json"
  @gates ".planning/references/PLANNING-GATES.json"
  @bad_summary ~w(halted blocked incomplete failed error)

  def check(root, stage \\ "status", requested_phase \\ nil) do
    root = Path.expand(root)
    state = text!(root, ".planning/STATE.md")
    roadmap = optional_text(root, ".planning/ROADMAP.md")
    requirements = optional_text(root, ".planning/REQUIREMENTS.md")
    config = json!(root, ".planning/config.json")
    snapshot = json!(root, ".planning/state.json")
    mapping = json!(root, @map)
    gates = json!(root, @gates)
    deliveries = json!(root, ".planning/references/PHASE-DELIVERIES.json")

    titles =
      for [_, id, title] <- Regex.scan(~r/^### Phase ([\d.]+): (.+)$/m, roadmap),
          into: %{},
          do: {id, title}

    phases = for [_, id] <- Regex.scan(~r/^### Phase ([\d.]+):/m, roadmap), do: id
    current = field(state, "current_phase")
    selected = select_phase(requested_phase, current)
    key = capture(roadmap, ~r/^\*\*Milestone key:\*\*\s+([a-z0-9-]+)\s*$/m)
    nodes = Map.new(mapping["future_phases"], &{node_id(&1), &1["depends_on"] || []})

    common_errors =
      require_true(stage in @stages, "unknown_stage", stage) ++
        require_true(safe_regular?(root, ".planning/PROJECT.md"), "project_missing", nil) ++
        registry_errors(gates, deliveries) ++
        configuration_errors(config, gates) ++
        dependency_errors(root, nodes, mapping["legacy_dependencies"] || %{}) ++
        seed_errors(root, mapping) ++
        delivery_errors(deliveries) ++
        future_owner_errors(mapping, gates) ++
        require_true(
          not File.exists?(Path.join(root, ".planning/active-workstream")),
          "workstream_requires_scoped_check",
          nil
        )

    if between_milestones?(root, state, phases) do
      errors =
        common_errors ++
          gate_errors(root, gates, nil) ++
          require_true(stage in ~w(status milestone-start), "no_active_milestone", stage) ++
          require_true(
            snapshot_version(snapshot) == field(state, "milestone"),
            "snapshot_milestone",
            snapshot["milestone"]
          ) ++
          require_true(snapshot_ids(snapshot) == [], "snapshot_phases", snapshot_ids(snapshot))

      %{stage: stage, milestone: field(state, "milestone"), phase: nil, errors: errors}
    else
      roadmap_milestone =
        capture(roadmap, ~r/^# Roadmap:\s+(v[\d.]+)\b/m) ||
          capture(roadmap, ~r/^## (v[\d.]+)\b/m)

      errors =
        require_true(
          phases != [] and Enum.all?(phases, &integer_id?/1),
          "active_phase_ids",
          phases
        ) ++
          require_true(
            length(phases) == length(Enum.uniq(normalize(phases))),
            "duplicate_phase",
            phases
          ) ++
          state_phase_errors(state, current, phases) ++
          require_true(
            roadmap_milestone == field(state, "milestone"),
            "roadmap_milestone",
            field(state, "milestone")
          ) ++
          require_true(
            snapshot_version(snapshot) == field(state, "milestone"),
            "snapshot_milestone",
            snapshot["milestone"]
          ) ++
          require_true(
            snapshot_ids(snapshot) == normalize(phases),
            "snapshot_phases",
            snapshot_ids(snapshot)
          ) ++
          snapshot_name_errors(snapshot, titles) ++
          require_true(
            key in gates["known_increment_milestones"] or known_key?(key, mapping),
            "milestone_key",
            key
          ) ++
          phase_sequence_errors(phases, deliveries, field(state, "milestone")) ++
          active_owner_errors(key, phases, mapping, gates) ++
          active_delivery_errors(deliveries, key, field(state, "milestone")) ++
          directory_errors(root, phases) ++
          requirement_errors(requirements, phases) ++
          common_errors ++
          gate_errors(root, gates, key) ++
          stage_errors(root, stage, selected, phases, roadmap, requirements, %{
            key: key,
            deliveries: deliveries,
            nodes: nodes,
            version: field(state, "milestone")
          })

      %{
        stage: stage,
        milestone: field(state, "milestone"),
        phase: selected,
        route_phase: resume_phase(current, phases, deliveries, field(state, "milestone")),
        errors: errors
      }
    end
  rescue
    error ->
      %{
        stage: stage,
        errors: [%{code: "planning_input_invalid", detail: Exception.message(error)}]
      }
  end

  defp between_milestones?(root, state, phases) do
    directories =
      Path.wildcard(Path.join(root, ".planning/phases/*")) |> Enum.filter(&File.dir?/1)

    no_phases? =
      phases == [] and directories == [] and safe_regular?(root, ".planning/MILESTONES.md")

    defining? = field(state, "status") == "planning" and field(state, "current_phase") == nil
    no_phases? and (defining? or archived_milestone?(root, state))
  end

  defp archived_milestone?(root, state) do
    version = field(state, "milestone") || ""
    history = optional_text(root, ".planning/MILESTONES.md")

    section =
      capture(
        history,
        Regex.compile!("^## " <> Regex.escape(version) <> " ([\\s\\S]*?)(?=^## |\\z)", "m")
      ) || ""

    field(state, "status") == "complete" and String.contains?(section, "(Shipped:") and
      safe_regular?(root, ".planning/milestones/#{version}-ROADMAP.md") and
      safe_regular?(root, ".planning/milestones/#{version}-REQUIREMENTS.md")
  end

  defp select_phase(nil, current), do: current
  defp select_phase(requested, _current), do: requested

  defp state_phase_errors(state, current, phases) do
    body = body_phase(state)

    require_true(current == nil or member?(current, phases), "state_phase", current) ++
      require_true(body == nil or same?(body, current), "state_body_phase", current)
  end

  defp registry_errors(gates, deliveries) do
    aggregate = Enum.find(gates["gates"], &(&1["id"] == "guard-aggregate")) || %{}

    require_true(gates["schema"] == "fablebook.planning-gates/1", "gate_schema", gates["schema"]) ++
      require_true(
        deliveries["schema"] == "fablebook.phase-deliveries/1",
        "delivery_schema",
        deliveries["schema"]
      ) ++
      require_true(
        "walking-skeleton" in (aggregate["blocks_milestones"] || []),
        "aggregate_gate_missing",
        nil
      ) ++
      require_true(
        Map.has_key?(gates["requirement_owners"], "SEC-01"),
        "security_owner_missing",
        nil
      )
  end

  defp configuration_errors(config, gates) do
    workflow = config["workflow"] || %{}

    Enum.flat_map(~w(plan_check verifier security_enforcement), fn name ->
      require_true(workflow[name] == true, "required_gate_disabled", name)
    end) ++
      require_true(
        workflow["auto_advance"] == false,
        "automatic_advance",
        workflow["auto_advance"]
      ) ++
      require_true(
        gates["automatic_followup"] == false,
        "automatic_followup",
        gates["automatic_followup"]
      )
  end

  defp directory_errors(root, phases) do
    directories =
      Path.wildcard(Path.join(root, ".planning/phases/*")) |> Enum.filter(&File.dir?/1)

    ids = Enum.map(directories, &capture(Path.basename(&1), ~r/^([\d.]+)-/))

    require_true(
      length(ids) == length(Enum.uniq(normalize(ids))),
      "duplicate_phase_directory",
      ids
    ) ++
      Enum.flat_map(directories, fn path ->
        id = capture(Path.basename(path), ~r/^([\d.]+)-/)

        require_true(
          id == "999" or (integer_id?(id) and member?(id, phases)),
          "unowned_active_directory",
          Path.basename(path)
        )
      end)
  end

  defp requirement_errors(text, phases) do
    ids = for [_, id] <- Regex.scan(~r/^- \[[ x]\] \*\*([A-Z]+-\d+)\*\*:/m, text), do: id
    rows = Regex.scan(~r/^\| ([A-Z]+-\d+) \| Phase ([\d.]+) \|/m, text)
    traced = Enum.map(rows, &Enum.at(&1, 1))

    require_true(ids != [] and Enum.sort(ids) == Enum.sort(traced), "requirement_trace", traced) ++
      Enum.flat_map(rows, fn [_, id, phase] ->
        require_true(member?(phase, phases), "requirement_owner", {id, phase})
      end)
  end

  defp dependency_errors(root, nodes, legacy) do
    unknown =
      for {node, dependencies} <- nodes,
          dependency <- dependencies,
          not Map.has_key?(nodes, dependency),
          not Map.has_key?(legacy, dependency),
          do: %{code: "unknown_prerequisite", detail: "#{node} -> #{dependency}"}

    missing =
      Enum.flat_map(legacy, fn {id, evidence} ->
        require_true(safe_regular?(root, evidence["evidence"]), "legacy_evidence_missing", id)
      end)

    unknown ++ missing ++ require_true(not cyclic?(nodes), "dependency_cycle", Map.keys(nodes))
  end

  defp cyclic?(nodes) do
    Enum.any?(Map.keys(nodes), &reaches?(&1, &1, nodes, MapSet.new()))
  end

  defp reaches?(node, target, nodes, seen) do
    if MapSet.member?(seen, node) do
      false
    else
      Enum.any?(Map.get(nodes, node, []), fn next ->
        next == target or reaches?(next, target, nodes, MapSet.put(seen, node))
      end)
    end
  end

  defp gate_errors(root, registry, active_key) do
    Enum.flat_map(registry["gates"], fn gate ->
      closed? = gate["status"] == "closed"

      require_true(gate["status"] in ~w(open closed), "gate_status", gate["id"]) ++
        require_true(safe_regular?(root, gate["evidence"]), "gate_evidence_missing", gate["id"]) ++
        require_true(
          closed? or active_key not in gate["blocks_milestones"],
          "milestone_prerequisite_open",
          gate["id"]
        ) ++ closure_errors(root, gate)
    end)
  end

  defp closure_errors(root, %{"status" => "closed"} = gate) do
    report = (gate["closure"] || %{})["report"]

    if safe_regular?(root, report) do
      text = text!(root, report)

      require_true(
        field(text, "status") == "passed" and field(text, "goal_scope") == gate["id"],
        "gate_closure_scope",
        gate["id"]
      )
    else
      [%{code: "gate_closure_missing", detail: gate["id"]}]
    end
  end

  defp closure_errors(_root, _gate), do: []

  defp seed_errors(root, mapping) do
    Path.wildcard(Path.join(root, ".planning/seeds/SEED-*.md"))
    |> Enum.flat_map(fn path ->
      seed = File.read!(path)
      milestone = field(seed, "target_milestone")
      phase = field(seed, "target_phase")

      if milestone == nil and phase == nil do
        []
      else
        valid =
          Enum.any?(mapping["future_phases"], &owns?(&1, milestone, phase))

        require_true(valid, "seed_target", Path.basename(path))
      end
    end)
  end

  defp delivery_errors(deliveries) do
    records = deliveries["phases"]
    phase_numbers = records |> Enum.map(&phase_number(&1["phase"])) |> Enum.reject(&is_nil/1)

    expected_numbers =
      if phase_numbers == [], do: [], else: Enum.to_list(1..length(phase_numbers))

    require_true(
      length(phase_numbers) == length(Enum.uniq(phase_numbers)),
      "duplicate_delivery",
      nil
    ) ++
      require_true(
        Enum.sort(phase_numbers) == expected_numbers,
        "delivery_sequence",
        phase_numbers
      ) ++
      Enum.flat_map(records, fn record ->
        valid =
          integer_id?(record["phase"]) and version?(record["milestone"]) and
            is_binary(record["milestone_key"]) and
            record["status"] == "merged" and is_integer(record["pr"]) and record["pr"] > 0 and
            Enum.all?(~w(reviewed_head merge_commit), &sha?(record[&1])) and
            is_binary(record["ci_run"]) and
            String.starts_with?(record["ci_run"], "https://github.com/")

        require_true(valid, "invalid_delivery", record["phase"])
      end)
  end

  defp phase_sequence_errors(phases, deliveries, current_milestone) do
    prior_numbers =
      deliveries["phases"]
      |> Enum.reject(&(&1["milestone"] == current_milestone))
      |> Enum.map(&phase_number(&1["phase"]))
      |> Enum.reject(&is_nil/1)

    next_number = if prior_numbers == [], do: 1, else: Enum.max(prior_numbers) + 1

    expected =
      if phases == [], do: [], else: Enum.map(0..(length(phases) - 1), &(next_number + &1))

    require_true(Enum.map(phases, &phase_number/1) == expected, "phase_sequence", phases)
  end

  defp delivered?(deliveries, version, phase) do
    Enum.any?(
      deliveries["phases"],
      &(&1["milestone"] == version and same?(&1["phase"], phase) and &1["status"] == "merged")
    )
  end

  defp resume_phase(current, phases, deliveries, version) do
    if current != nil and not delivered?(deliveries, version, current) do
      current
    else
      Enum.find(phases, &(not delivered?(deliveries, version, &1)))
    end
  end

  defp prerequisite_receipts(nodes, key, phase, deliveries, version) do
    Enum.flat_map(Map.get(nodes, "#{key}:#{normalized(phase)}", []), fn dependency ->
      case String.split(dependency, ":", parts: 2) do
        ["legacy", _] ->
          []

        [owner, number] ->
          found =
            Enum.any?(
              deliveries["phases"],
              &prerequisite_delivered?(&1, owner, number, key, version)
            )

          require_true(found, "prerequisite_not_delivered", dependency)
      end
    end)
  end

  defp prerequisite_delivered?(entry, owner, number, key, version) do
    entry["milestone_key"] == owner and same?(entry["phase"], number) and
      (owner != key or entry["milestone"] == version) and entry["status"] == "merged"
  end

  defp owns?(item, key, phase),
    do: item["milestone_key"] == key and same?(to_string(item["phase"]), phase)

  defp future_owner_errors(mapping, gates) do
    entries = mapping["future_phases"]
    ids = Enum.map(entries, &node_id/1)
    original_ids = Enum.map(entries, & &1["legacy_phase"])
    nodes = MapSet.new(ids)

    require_true(length(ids) == length(Enum.uniq(ids)), "duplicate_future_phase", nil) ++
      require_true(
        length(original_ids) == length(Enum.uniq(original_ids)),
        "duplicate_legacy_owner",
        nil
      ) ++
      Enum.flat_map(entries, fn entry ->
        require_true(integer_id?(to_string(entry["phase"])), "future_phase_id", node_id(entry))
      end) ++
      Enum.flat_map(gates["requirement_owners"], fn {requirement, owner} ->
        require_true(MapSet.member?(nodes, owner), "global_requirement_owner", requirement)
      end)
  end

  defp active_owner_errors(key, phases, mapping, gates) do
    if key in gates["known_increment_milestones"] do
      []
    else
      Enum.flat_map(phases, fn phase ->
        require_true(
          Enum.any?(
            mapping["future_phases"],
            &(&1["milestone_key"] == key and same?(to_string(&1["phase"]), phase))
          ),
          "active_phase_owner",
          phase
        )
      end)
    end
  end

  defp version?(value), do: is_binary(value) and Regex.match?(~r/^v\d+\.\d+(?:\.\d+)?$/, value)

  defp active_delivery_errors(deliveries, key, version) do
    Enum.flat_map(deliveries["phases"], fn entry ->
      require_true(
        entry["milestone"] != version or entry["milestone_key"] == key,
        "delivery_milestone_owner",
        entry["phase"]
      )
    end)
  end

  defp sha?(value), do: is_binary(value) and Regex.match?(~r/^[0-9a-f]{40}$/, value)

  defp stage_errors(root, stage, phase, phases, roadmap, requirements, lifecycle) do
    %{key: key, deliveries: deliveries, nodes: nodes, version: version} = lifecycle

    if stage in ~w(status milestone-start milestone-close) do
      if stage in ~w(milestone-start milestone-close) do
        milestone_errors(root, phases, roadmap, requirements) ++
          Enum.flat_map(
            phases,
            &require_true(delivered?(deliveries, version, &1), "phase_not_delivered", &1)
          )
      else
        []
      end
    else
      phase_errors(root, stage, phase, phases, key) ++
        completed_reentry_errors(stage, phase, roadmap) ++
        require_true(
          stage not in ~w(discuss plan execute) or not delivered?(deliveries, version, phase),
          "delivered_phase_reentry",
          phase
        ) ++
        if(stage == "execute",
          do: prerequisite_receipts(nodes, key, phase, deliveries, version),
          else: []
        )
    end
  end

  defp completed_reentry_errors(stage, phase, roadmap) do
    complete = for [_, id] <- Regex.scan(~r/^- \[x\] \*\*Phase ([\d.]+):/m, roadmap), do: id

    require_true(
      stage not in ~w(discuss plan execute) or not member?(phase, complete),
      "completed_phase_reentry",
      phase
    )
  end

  defp phase_errors(root, stage, phase, phases, key) do
    if member?(phase, phases) do
      dir = phase_dir(root, phase)
      plans = if dir, do: Path.wildcard(Path.join(dir, "*-PLAN.md")), else: []
      contexts = if dir, do: Path.wildcard(Path.join(dir, "*-CONTEXT.md")), else: []

      require_true(
        stage == "discuss" or key != "guard-recovery" or contexts != [],
        "context_missing",
        phase
      ) ++
        require_true(stage in ~w(discuss plan) or plans != [], "plans_missing", phase) ++
        plan_owner_errors(plans, phase) ++
        if(stage in ~w(verify ship), do: summary_errors(plans), else: []) ++
        if(stage == "ship", do: verification_errors(dir, phase), else: [])
    else
      [%{code: "requested_phase", detail: phase}]
    end
  end

  defp plan_owner_errors(plans, phase) do
    Enum.flat_map(plans, fn plan ->
      owner = capture(field(File.read!(plan), "phase") || "", ~r/^([\d.]+)/)
      require_true(same?(owner, phase), "plan_owner", Path.basename(plan))
    end)
  end

  defp summary_errors(plans) do
    Enum.flat_map(plans, fn plan ->
      summary = String.replace_suffix(plan, "-PLAN.md", "-SUMMARY.md")

      if File.regular?(summary) do
        require_true(
          field(File.read!(summary), "status") not in @bad_summary,
          "summary_incomplete",
          Path.basename(summary)
        )
      else
        [%{code: "summary_missing", detail: Path.basename(summary)}]
      end
    end)
  end

  defp milestone_errors(root, phases, roadmap, requirements) do
    complete = for [_, id] <- Regex.scan(~r/^- \[x\] \*\*Phase ([\d.]+):/m, roadmap), do: id

    require_true(normalize(phases) == normalize(complete), "milestone_unfinished", complete) ++
      require_true(
        not Regex.match?(~r/^- \[ \] \*\*[A-Z]+-\d+\*\*:/m, requirements),
        "requirements_unfinished",
        nil
      ) ++
      Enum.flat_map(phases, fn phase ->
        dir = phase_dir(root, phase)
        plans = if dir, do: Path.wildcard(Path.join(dir, "*-PLAN.md")), else: []

        require_true(plans != [], "plans_missing", phase) ++
          summary_errors(plans) ++ verification_errors(dir, phase)
      end)
  end

  defp verification_errors(nil, phase), do: [%{code: "verification_missing", detail: phase}]

  defp verification_errors(dir, phase) do
    reports = Path.wildcard(Path.join(dir, "*-VERIFICATION.md"))

    case reports do
      [report] ->
        require_true(
          field(File.read!(report), "status") == "passed",
          "verification_not_passed",
          phase
        )

      _ ->
        [%{code: "verification_missing", detail: phase}]
    end
  end

  defp phase_dir(root, phase) do
    Path.wildcard(Path.join(root, ".planning/phases/*"))
    |> Enum.find(fn path ->
      File.dir?(path) and same?(capture(Path.basename(path), ~r/^(\d+)-/), phase)
    end)
  end

  defp snapshot_version(snapshot), do: capture(snapshot["milestone"] || "", ~r/^(v[\d.]+)\b/)

  defp snapshot_name_errors(snapshot, titles) do
    Enum.flat_map(snapshot["phases"], fn entry ->
      expected =
        Enum.find_value(titles, &matching_title(&1, entry["number"]))

      require_true(entry["name"] == expected, "snapshot_phase_name", entry["number"])
    end)
  end

  defp matching_title({id, title}, number) do
    if same?(id, number), do: title
  end

  defp snapshot_ids(snapshot) do
    snapshot["phases"] |> Enum.map(& &1["number"]) |> normalize()
  end

  defp known_key?(key, mapping),
    do: Enum.any?(mapping["future_phases"], &(&1["milestone_key"] == key))

  defp node_id(item), do: "#{item["milestone_key"]}:#{item["phase"]}"
  defp json!(root, path), do: root |> text!(path) |> JSON.decode!()
  defp text!(root, path), do: File.read!(Path.join(root, path))

  defp optional_text(root, path) do
    case File.read(Path.join(root, path)) do
      {:ok, text} -> text
      {:error, :enoent} -> ""
      {:error, reason} -> raise File.Error, reason: reason, action: "read", path: path
    end
  end

  defp safe_regular?(root, path) when is_binary(path) do
    Path.type(path) == :relative and String.starts_with?(path, ".planning/") and
      ".." not in Path.split(path) and File.regular?(Path.join(root, path))
  end

  defp safe_regular?(_, _), do: false

  defp field(text, name) do
    capture(text, Regex.compile!("^" <> Regex.escape(name) <> ":[ \t]*([^\\n]+)", "m"))
    |> strip_quotes()
  end

  defp body_phase(text), do: capture(text, ~r/^Phase:\s+([\d.]+)/m)

  defp capture(text, regex) do
    case Regex.run(regex, text) do
      [_, value] -> value
      _ -> nil
    end
  end

  defp strip_quotes(nil), do: nil

  defp strip_quotes(value) do
    result = value |> String.trim() |> String.trim("\"") |> String.trim("'")
    if result in ["null", "~", ""], do: nil, else: result
  end

  defp integer_id?(value),
    do: is_binary(value) and Regex.match?(~r/^\d+$/, value) and String.to_integer(value) > 0

  defp phase_number(value), do: if(integer_id?(value), do: String.to_integer(value))

  defp normalize(values), do: values |> Enum.map(&normalized/1) |> Enum.sort()

  defp normalized(value),
    do: if(integer_id?(value), do: Integer.to_string(String.to_integer(value)), else: value)

  defp same?(a, b), do: a != nil and b != nil and normalized(a) == normalized(b)
  defp member?(value, values), do: integer_id?(value) and Enum.any?(values, &same?(value, &1))
  defp require_true(true, _, _), do: []
  defp require_true(false, code, detail), do: [%{code: code, detail: inspect(detail)}]
end
