defmodule Fablebook.Test.GuardAggregateReconciliationEvidence do
  @moduledoc false

  @schema "fablebook.guard-aggregate-lane/1"
  @report_schema "fablebook.guard-aggregate-crosswalk/1"
  @collector "guard-aggregate-tracer/1"
  @stops %{
    "scope_complete" => false,
    "candidate" => nil,
    "implementation_authorized" => false,
    "aggregate_gate" => "open",
    "walking_skeleton" => "blocked",
    "sec_01" => "Pending"
  }

  def build_lane!(inputs) when is_map(inputs) do
    lane = required!(inputs, :lane)
    true = lane in ["core", "floor"]
    identity = sanitize!(required!(inputs, :identity))
    true = identity["id"] == "EX-010"
    true = identity["identity_class"] == "exclusion"

    selected =
      inputs |> Map.fetch!(:selected_mfas) |> Enum.map(&mfa!/1) |> Enum.uniq() |> Enum.sort()

    live = inputs |> Map.fetch!(:live_mfas) |> Enum.map(&mfa!/1) |> Enum.uniq() |> Enum.sort()
    true = MapSet.subset?(MapSet.new(live), MapSet.new(selected))

    lane_evidence = sanitize!(required!(inputs, :lane_evidence))
    true = lane_evidence["lane"] == lane
    true = is_list(lane_evidence["selected_function_evidence"])
    true = is_list(lane_evidence["reviews"])
    true = is_list(lane_evidence["exact_sources"])
    true = is_list(lane_evidence["matched_mfas"])
    true = is_list(lane_evidence["delegate_edges"])
    true = is_list(lane_evidence["remainder_mfas"])

    delivery = sanitize!(required!(inputs, :delivery))
    true = delivery["status"] == "merged"
    true = is_binary(delivery["ci_run"])

    shared = %{
      "collector" => @collector,
      "identity" => identity,
      "selected_mfas" => selected,
      "delivery" => delivery
    }

    record =
      Map.merge(@stops, %{
        "schema" => @schema,
        "collector" => @collector,
        "lane" => lane,
        "generation" => digest(shared),
        "input_sha256" => digest(shared),
        "runtime" => sanitize!(required!(inputs, :runtime)),
        "lock_sha256" => required!(inputs, :lock_sha256),
        "identity" => identity,
        "owner" => identity["owner"],
        "delivery" => delivery,
        "selected_mfas" => selected,
        "live_mfas" => live,
        "source_and_caller_evidence" => lane_evidence,
        "stops" => @stops
      })

    record =
      case Map.fetch(inputs, :aggregate_rows) do
        {:ok, rows} ->
          identities = Enum.map(rows, &aggregate_identity!/1)
          receipts = sanitize!(Map.fetch!(inputs, :delivery_receipts))
          inventory_input = Map.fetch!(inputs, :inventory_universe)
          exported_mfas = canonical_mfas!(Map.fetch!(inventory_input, "exported_mfas"))
          identity_rows = Enum.map(rows, &aggregate_row!/1)

          Enum.each(identity_rows, &validate_identity_row_inventory!(&1, exported_mfas))

          inventory_summary =
            inventory_input
            |> Map.drop(["exported_mfas"])
            |> Map.put("exported_mfas_sha256", digest(exported_mfas))

          common = %{
            "collector" => @collector,
            "identities" => identities,
            "delivery_receipts" => receipts
          }

          record
          |> Map.put("identity_rows", identity_rows)
          |> Map.put("delivery_receipts", receipts)
          |> Map.put("membership_join_complete", true)
          |> Map.put("source_join_complete", false)
          |> Map.put("inventory_universe", sanitize!(inventory_summary))
          |> Map.put(
            "live_nonoriginal_entries",
            sanitize!(Map.fetch!(inputs, :live_nonoriginal_entries))
          )
          |> Map.put("membership_sha256", digest(Enum.map(rows, &aggregate_row!/1)))
          |> Map.put("generation", digest(common))
          |> Map.put("input_sha256", digest(common))

        :error ->
          record
      end

    :ok = validate_lane!(record)
    if Map.has_key?(record, "identity_rows"), do: :ok = validate_aggregate_lane!(record)
    record
  end

  defp validate_identity_row_inventory!(row, exported_mfas) do
    Enum.each(["original_live_mfas", "live_mfas", "replacement_live_mfas"], fn field ->
      true = MapSet.subset?(MapSet.new(row[field]), MapSet.new(exported_mfas))
    end)
  end

  def validate_lane!(record) when is_map(record) do
    true = record["schema"] == @schema
    true = record["collector"] == @collector
    true = record["lane"] in ["core", "floor"]
    true = is_binary(record["generation"]) and byte_size(record["generation"]) == 64
    true = record["input_sha256"] == record["generation"]
    true = is_binary(record["lock_sha256"]) and byte_size(record["lock_sha256"]) == 64
    true = record["identity"]["id"] == "EX-010"
    true = record["identity"]["identity_class"] == "exclusion"
    true = record["source_and_caller_evidence"]["lane"] == record["lane"]
    true = record["owner"] == record["identity"]["owner"]
    true = is_list(record["selected_mfas"]) and is_list(record["live_mfas"])
    true = record["live_mfas"] == Enum.sort(Enum.uniq(record["live_mfas"]))
    true = MapSet.subset?(MapSet.new(record["live_mfas"]), MapSet.new(record["selected_mfas"]))
    true = record["delivery"]["status"] == "merged"
    true = record["stops"] == @stops
    :ok
  end

  def validate_aggregate_lane!(record) when is_map(record) do
    :ok = validate_lane!(record)
    true = record["membership_join_complete"] == true
    true = record["source_join_complete"] == (record["target_source_gaps"] == [])
    true = is_list(record["identity_rows"]) and record["identity_rows"] != []
    true = is_list(record["delivery_receipts"]) and length(record["delivery_receipts"]) == 2
    true = is_map(record["inventory_universe"])

    true =
      is_integer(record["inventory_universe"]["count"]) and
        record["inventory_universe"]["count"] > 0

    true = is_binary(record["inventory_universe"]["exported_mfas_sha256"])
    true = byte_size(record["inventory_universe"]["exported_mfas_sha256"]) == 64

    rows = record["identity_rows"]
    true = record["membership_sha256"] == digest(rows)

    true =
      record["generation"] ==
        digest(%{
          "collector" => @collector,
          "identities" => Enum.map(rows, & &1["identity"]),
          "delivery_receipts" => record["delivery_receipts"]
        })

    ids = Enum.map(rows, & &1["identity"]["id"])
    true = length(ids) == length(Enum.uniq(ids))

    Enum.each(rows, fn row ->
      identity = row["identity"]
      true = identity["identity_class"] in ["exclusion", "lane_metadata"]
      true = is_binary(identity["id"]) and is_binary(identity["owner"])

      baseline = canonical_mfas!(row["baseline_mfas"])
      canonical_mfas!(row["original_live_mfas"])
      live = canonical_mfas!(row["live_mfas"])
      replacement_live = canonical_mfas!(row["replacement_live_mfas"])
      delivered_scope = canonical_mfas!(row["delivered_scope_mfas"])
      delivered = canonical_mfas!(row["delivered_mfas"])
      delivered_missing = canonical_mfas!(row["delivered_now_missing_mfas"])
      pending = canonical_mfas!(row["pending_mfas"])
      added = canonical_mfas!(row["added_mfas"])
      missing = canonical_mfas!(row["missing_mfas"])

      true = live == replacement_live
      true = added == set_difference(live, baseline)
      true = missing == set_difference(baseline, live)
      true = delivered == set_intersection(delivered_scope, live)
      true = delivered_missing == set_difference(delivered_scope, live)
      true = pending == set_difference(live, delivered_scope)
      true = MapSet.union(MapSet.new(delivered), MapSet.new(pending)) == MapSet.new(live)
      true = MapSet.disjoint?(MapSet.new(delivered), MapSet.new(pending))

      refs = row["identity"]["current_replacement_refs"]
      true = is_list(refs) and refs != []
      true = is_list(row["delivery_refs"])
      true = is_binary(row["mapping_status"]) and row["mapping_status"] == "complete"

      if Map.has_key?(row, "historical_partition_mfas") do
        historical = canonical_mfas!(row["historical_partition_mfas"])
        historical_complement = canonical_mfas!(row["historical_complement_mfas"])
        pending_partition = canonical_mfas!(row["pending_after_delivered_and_historical_mfas"])
        true = historical_complement == set_difference(live, historical)
        true = pending_partition == set_difference(live, Enum.uniq(delivered_scope ++ historical))
        true = MapSet.disjoint?(MapSet.new(historical), MapSet.new(delivered_scope))
      end
    end)

    :ok
  end

  def render_crosswalk!(core, floor) do
    :ok = validate_lane!(core)
    :ok = validate_lane!(floor)
    if Map.has_key?(core, "identity_rows"), do: :ok = validate_aggregate_lane!(core)
    if Map.has_key?(floor, "identity_rows"), do: :ok = validate_aggregate_lane!(floor)
    true = core["lane"] == "core" and floor["lane"] == "floor"
    true = core["generation"] == floor["generation"]
    true = core["input_sha256"] == floor["input_sha256"]
    true = core["identity"] == floor["identity"]
    true = core["delivery"] == floor["delivery"]

    base = %{
      "schema" => @report_schema,
      "collector" => @collector,
      "generation" => core["generation"],
      "input_sha256" => core["input_sha256"],
      "scope" => "one-row-tracer",
      "stops" => @stops,
      "lane_records" => %{
        "core" => %{
          "path" =>
            ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json",
          "sha256" => digest(core)
        },
        "floor" => %{
          "path" =>
            ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json",
          "sha256" => digest(floor)
        }
      },
      "rows" => [
        %{
          "id" => "EX-010",
          "identity" => core["identity"],
          "owner" => core["owner"],
          "delivery" => core["delivery"],
          "core" => %{
            "live_mfas" => core["live_mfas"],
            "evidence" => core["source_and_caller_evidence"]
          },
          "floor" => %{
            "live_mfas" => floor["live_mfas"],
            "evidence" => floor["source_and_caller_evidence"]
          }
        }
      ]
    }

    report =
      if Map.has_key?(core, "identity_rows") and Map.has_key?(floor, "identity_rows") do
        core_rows = Map.new(core["identity_rows"], &{&1["identity"]["id"], &1})
        floor_rows = Map.new(floor["identity_rows"], &{&1["identity"]["id"], &1})
        true = Map.keys(core_rows) |> Enum.sort() == Map.keys(floor_rows) |> Enum.sort()

        rows =
          Enum.map(core["identity_rows"], fn core_row ->
            id = core_row["identity"]["id"]
            floor_row = Map.fetch!(floor_rows, id)
            true = core_row["identity"] == floor_row["identity"]
            true = core_row["delivery_refs"] == floor_row["delivery_refs"]

            %{
              "id" => id,
              "identity" => core_row["identity"],
              "owner" => core_row["identity"]["owner"],
              "delivered_slice_owner" => core_row["delivered_slice_owner"],
              "delivery_refs" => core_row["delivery_refs"],
              "core" =>
                Map.drop(core_row, ["identity", "delivered_slice_owner", "delivery_refs"]),
              "floor" =>
                Map.drop(floor_row, ["identity", "delivered_slice_owner", "delivery_refs"])
            }
          end)

        Map.merge(base, %{
          "scope" => "complete-original-ledger",
          "membership_join_complete" => true,
          "source_join_complete" => false,
          "delivery_receipts" => core["delivery_receipts"],
          "live_nonoriginal_entries" => %{
            "core" => core["live_nonoriginal_entries"],
            "floor" => floor["live_nonoriginal_entries"]
          },
          "rows" => rows
        })
      else
        base
      end

    report
    |> with_source_crosswalk!([core, floor])
    |> with_static_caller_crosswalk!([core, floor])
  end

  def check_bundle!(records, report) when is_list(records) and is_map(report) do
    [core, floor] = Enum.sort_by(records, & &1["lane"])
    expected = render_crosswalk!(core, floor)

    if Enum.all?([core, floor], &(&1["target_source_coverage_complete"] == true)) do
      expected = Map.put(expected, "source_crosswalk", source_crosswalk!([core, floor]))

      if Enum.all?([core, floor], &is_map(&1["static_caller_evidence"])) do
        expected = with_static_caller_crosswalk!(expected, [core, floor])
        true = report == expected
      else
        true = report == expected
      end
    else
      true = report == expected
    end

    :ok
  end

  def with_source_crosswalk!(report, records) when is_map(report) and is_list(records),
    do: Map.put(report, "source_crosswalk", source_crosswalk!(records))

  def attach_target_sources!(record, archive_files, archive_sha256)
      when is_map(record) and is_list(archive_files) and is_binary(archive_sha256) do
    :ok = validate_aggregate_lane!(record)

    {associations, gaps} =
      target_source_associations!(record, archive_files, archive_sha256)

    sources = target_source_records!(record, associations, archive_files, archive_sha256)

    gaps = Enum.sort_by(gaps, & &1["key"])
    associations = Enum.sort_by(associations, &{&1["identity_id"], &1["mfa"] || [], &1["status"]})

    record
    |> Map.put("target_source_records", sources)
    |> Map.put("target_source_associations", associations)
    |> Map.put("target_source_gaps", gaps)
    |> Map.put("source_join_complete", gaps == [])
    |> Map.put("target_source_coverage_complete", true)
    |> tap(fn enriched -> :ok = validate_target_sources!(enriched) end)
  end

  defp target_source_associations!(record, archive_files, archive_sha256) do
    Enum.reduce(record["identity_rows"], {[], []}, fn row, accumulated ->
      target_source_associations_for_row(
        row,
        accumulated,
        record,
        archive_files,
        archive_sha256
      )
    end)
  end

  defp target_source_associations_for_row(
         %{"identity" => %{"id" => identity_id}, "live_mfas" => []},
         {associations, gaps},
         _record,
         _files,
         _archive_sha
       ) do
    association = %{"identity_id" => identity_id, "status" => "not_applicable", "targets" => []}
    {[association | associations], gaps}
  end

  defp target_source_associations_for_row(row, accumulated, record, archive_files, archive_sha256) do
    identity_id = row["identity"]["id"]

    Enum.reduce(row["live_mfas"], accumulated, fn mfa, result ->
      attach_target_source_association(
        result,
        record,
        identity_id,
        mfa,
        archive_files,
        archive_sha256
      )
    end)
  end

  defp attach_target_source_association(
         {associations, gaps},
         record,
         identity_id,
         mfa,
         files,
         archive_sha
       ) do
    case target_source!(record, identity_id, mfa, files, archive_sha) do
      {:ok, source} ->
        association = %{
          "identity_id" => identity_id,
          "mfa" => mfa,
          "status" => "cited_static_evidence",
          "source_key" => source["key"]
        }

        {[association | associations], gaps}

      {:gap, gap} ->
        association = %{
          "identity_id" => identity_id,
          "mfa" => mfa,
          "status" => "source_gap",
          "gap_key" => gap["key"]
        }

        {[association | associations], [gap | gaps]}
    end
  end

  defp target_source_records!(record, associations, archive_files, archive_sha256) do
    source_keys =
      associations
      |> Enum.filter(&(&1["status"] == "cited_static_evidence"))
      |> Enum.map(& &1["source_key"])
      |> Enum.uniq()
      |> Enum.sort()

    Enum.map(source_keys, fn key ->
      {identity_id, mfa} = source_key_index!(associations, key)
      {:ok, source} = target_source!(record, identity_id, mfa, archive_files, archive_sha256)
      source
    end)
  end

  def validate_target_sources!(record) when is_map(record) do
    :ok = validate_aggregate_lane!(record)
    true = record["target_source_coverage_complete"] == true
    true = is_list(record["target_source_records"])
    true = is_list(record["target_source_associations"])
    true = is_list(record["target_source_gaps"])

    :ok = validate_target_source_membership!(record)
    :ok = validate_target_source_row_statuses!(record)
    :ok = validate_unique_target_source_keys!(record)
    :ok = validate_target_source_associations!(record)
    :ok
  end

  defp validate_target_source_membership!(record) do
    expected =
      for row <- record["identity_rows"],
          mfa <- row["live_mfas"],
          do: {row["identity"]["id"], mfa}

    actual =
      record["target_source_associations"]
      |> Enum.map(&{&1["identity_id"], &1["mfa"]})
      |> Enum.reject(fn {_id, mfa} -> is_nil(mfa) end)

    true = length(actual) == length(Enum.uniq(actual))
    true = Enum.sort(actual) == Enum.sort(expected)

    :ok
  end

  defp validate_target_source_row_statuses!(record) do
    Enum.each(record["identity_rows"], fn row ->
      validate_target_source_row_status!(row, record["target_source_associations"])
    end)

    :ok
  end

  defp validate_target_source_row_status!(row, associations) do
    identity_id = row["identity"]["id"]

    case row["live_mfas"] do
      [] ->
        not_applicable =
          Enum.filter(associations, fn association ->
            association["identity_id"] == identity_id and
              association["status"] == "not_applicable"
          end)

        true = length(not_applicable) == 1

      _ ->
        true =
          Enum.all?(associations, fn association ->
            association["identity_id"] != identity_id or
              association["status"] != "not_applicable"
          end)
    end

    :ok
  end

  defp validate_unique_target_source_keys!(record) do
    gap_keys = Enum.map(record["target_source_gaps"], & &1["key"])
    true = length(gap_keys) == length(Enum.uniq(gap_keys))

    source_keys = Enum.map(record["target_source_records"], & &1["key"])
    true = length(source_keys) == length(Enum.uniq(source_keys))

    :ok
  end

  defp validate_target_source_associations!(record) do
    gap_keys = Enum.map(record["target_source_gaps"], & &1["key"])

    Enum.each(record["target_source_associations"], fn association ->
      validate_target_source_association!(association, record, gap_keys)
    end)

    :ok
  end

  defp validate_target_source_association!(association, record, gap_keys) do
    case association["status"] do
      "cited_static_evidence" ->
        source =
          Enum.find(record["target_source_records"], &(&1["key"] == association["source_key"]))

        validate_target_source_identity!(source, record)

      "source_gap" ->
        true = association["gap_key"] in gap_keys

      "not_applicable" ->
        true = association["mfa"] == nil

      _ ->
        raise ArgumentError, "invalid target source association status"
    end
  end

  defp validate_target_source_identity!(source, record) do
    true = is_map(source)
    true = source["lane"] == record["lane"]
    true = source["lock_sha256"] == record["lock_sha256"]
    true = is_binary(source["repository_ref"]) and source["repository_ref"] != ""
    true = is_binary(source["relative_path"]) and source["relative_path"] != ""
    true = is_integer(source["bytes"]) and source["bytes"] > 0
    true = is_binary(source["sha256"]) and byte_size(source["sha256"]) == 64

    identity =
      Map.take(source, [
        "lane",
        "repository_ref",
        "lock_sha256",
        "archive_sha256",
        "relative_path",
        "bytes",
        "sha256"
      ])

    true = source["key"] == "source:" <> digest(identity)
    :ok
  end

  def source_crosswalk!(records) when is_list(records) do
    records = Enum.sort_by(records, & &1["lane"])
    true = length(records) == 2
    true = Enum.map(records, & &1["lane"]) == ["core", "floor"]

    rows =
      Enum.flat_map(records, fn record ->
        :ok = validate_target_sources!(record)

        for row <- record["identity_rows"] do
          identity_id = row["identity"]["id"]

          source_keys =
            record["target_source_associations"]
            |> Enum.filter(
              &(&1["identity_id"] == identity_id and &1["status"] == "cited_static_evidence")
            )
            |> Enum.map(& &1["source_key"])
            |> Enum.uniq()
            |> Enum.sort()

          gap_keys =
            record["target_source_gaps"]
            |> Enum.filter(&(&1["identity_id"] == identity_id))
            |> Enum.map(& &1["key"])
            |> Enum.sort()

          %{
            "lane" => record["lane"],
            "identity_id" => identity_id,
            "target_source_keys" => source_keys,
            "required_source_gap_keys" => gap_keys
          }
        end
      end)

    gaps =
      records
      |> Enum.flat_map(& &1["target_source_gaps"])
      |> Enum.sort_by(& &1["key"])

    %{"rows" => rows, "required_source_gaps" => gaps}
  end

  def attach_static_callers!(record, observation)
      when is_map(record) and is_map(observation) do
    :ok = validate_aggregate_lane!(record)
    :ok = validate_target_sources!(record)
    lane = record["lane"]
    :ok = validate_caller_observation!(observation, lane)

    observed_mfas = canonical_observed_mfas!(observation)
    source_records = caller_source_records(record)
    {edges, incoming} = caller_observation_edges(observation, lane, record, source_records)
    targets = caller_targets(record)

    caller_records =
      Enum.map(targets, fn {identity_id, mfa} ->
        build_caller_record(record, lane, observed_mfas, edges, incoming, identity_id, mfa)
      end)
      |> Enum.sort_by(&{&1["identity_id"], &1["mfa"]})

    gaps = caller_record_gaps(caller_records)

    evidence = %{
      "schema" => "guard-aggregate-static-caller-evidence/1",
      "lane" => lane,
      "graph_observation" => caller_graph_observation(observation, observed_mfas),
      "edges" => Enum.sort_by(edges ++ incoming, & &1["key"]),
      "source_records" => source_records,
      "records" => caller_records,
      "required_evidence_gaps" => gaps,
      "complete" => false,
      "recommendation_gate" => false
    }

    record
    |> Map.put("static_caller_evidence", evidence)
    |> Map.put("required_evidence_gaps", gaps)
    |> tap(fn enriched -> :ok = validate_static_callers!(enriched) end)
  end

  defp validate_caller_observation!(observation, lane) do
    true = observation["lane"] == lane
    true = is_binary(observation["observation_path"])
    true = is_binary(observation["observation_sha256"])
    true = byte_size(observation["observation_sha256"]) == 64
    true = is_binary(observation["log_sha256"])
    true = byte_size(observation["log_sha256"]) == 64
    :ok
  end

  defp canonical_observed_mfas!(observation) do
    observation["selected_mfas"]
    |> Enum.map(&caller_observation_mfa!/1)
    |> Enum.uniq()
    |> Enum.sort()
  end

  defp caller_observation_edges(observation, lane, record, source_records) do
    edges =
      (observation["active_projection_edges"] || [])
      |> Enum.map(&caller_observation_edge!(&1, lane, record, source_records))
      |> Enum.uniq_by(& &1["key"])
      |> Enum.sort_by(& &1["key"])

    incoming =
      (observation["active_projection_incoming_edges"] || [])
      |> Enum.map(&caller_observation_edge!(&1, lane, record, source_records))
      |> Enum.uniq_by(& &1["key"])
      |> Enum.sort_by(& &1["key"])

    {caller_mark_two_edge_cycles(edges ++ incoming), incoming}
  end

  defp caller_targets(record) do
    for row <- record["identity_rows"], mfa <- row["live_mfas"] do
      {row["identity"]["id"], mfa}
    end
  end

  defp build_caller_record(record, lane, observed_mfas, edges, incoming, identity_id, mfa) do
    selected = Enum.any?(observed_mfas, &(&1 == mfa))
    outgoing = Enum.filter(edges, &(&1["from"] == mfa))
    incoming_edges = caller_incoming_edges(incoming, mfa)
    delegate_paths = caller_delegate_paths(record, mfa)
    finding_refs = caller_finding_refs(record, identity_id, lane, mfa)

    gaps =
      caller_target_gaps(
        lane,
        identity_id,
        mfa,
        selected,
        finding_refs,
        outgoing,
        incoming_edges,
        delegate_paths
      )

    %{
      "identity_id" => identity_id,
      "mfa" => mfa,
      "status" => if(selected, do: "observed_scoped_graph", else: "graph_evidence_missing"),
      "observed_incoming_edges" => Enum.map(incoming_edges, & &1["key"]),
      "observed_outgoing_edges" => Enum.map(outgoing, & &1["key"]),
      "delegate_paths" => delegate_paths,
      "finding_refs" => finding_refs,
      "dynamic_boundary" => "unproven",
      "gap_keys" => Enum.map(gaps, & &1["key"]),
      "gaps" => gaps
    }
  end

  defp caller_incoming_edges(incoming, mfa) do
    Enum.filter(incoming, fn edge ->
      edge["to"] == mfa or
        (is_nil(List.last(edge["to"])) and Enum.take(edge["to"], 2) == Enum.take(mfa, 2))
    end)
  end

  defp caller_finding_refs(record, "EX-010", lane, mfa) do
    record["source_and_caller_evidence"]["selected_function_evidence"]
    |> Enum.filter(&caller_finding_matches?(&1, mfa))
    |> Enum.map(fn finding ->
      citations = finding["citations"] || []
      source = caller_source_for_mfa(record, mfa)

      %{
        "key" => "finding:" <> digest(%{"lane" => lane, "mfa" => mfa, "citations" => citations}),
        "source_key" => source,
        "citations" => citations,
        "callback_boundary" => finding["callback_boundary"],
        "fixed_native_boundary" => finding["fixed_native_boundary"]
      }
    end)
  end

  defp caller_finding_refs(_record, _identity_id, _lane, _mfa), do: []

  defp caller_target_gaps(
         lane,
         identity_id,
         mfa,
         selected,
         finding_refs,
         outgoing,
         incoming_edges,
         delegate_paths
       ) do
    callback_missing? =
      finding_refs == [] or Enum.any?(finding_refs, &is_binary(&1["callback_boundary"]))

    edge_source_missing? =
      Enum.any?(outgoing ++ incoming_edges, fn edge ->
        not is_binary(edge["caller_source_key"]) or not is_binary(edge["callee_source_key"])
      end)

    caller_gap_if(not selected, lane, identity_id, mfa, "selected_graph_observation_missing") ++
      [caller_gap!(lane, identity_id, mfa, "current_graph_reconciliation_missing")] ++
      caller_gap_if(
        callback_missing?,
        lane,
        identity_id,
        mfa,
        "callback_and_delegate_provenance_unreviewed"
      ) ++
      caller_gap_if(
        selected and outgoing == [] and incoming_edges == [],
        lane,
        identity_id,
        mfa,
        "selected_graph_edges_missing"
      ) ++
      caller_gap_if(
        outgoing != [] and delegate_paths == [],
        lane,
        identity_id,
        mfa,
        "delegate_path_provenance_missing"
      ) ++
      caller_gap_if(
        edge_source_missing?,
        lane,
        identity_id,
        mfa,
        "edge_source_identity_missing"
      )
  end

  defp caller_gap_if(true, lane, identity_id, mfa, reason),
    do: [caller_gap!(lane, identity_id, mfa, reason)]

  defp caller_gap_if(false, _lane, _identity_id, _mfa, _reason), do: []

  defp caller_record_gaps(caller_records) do
    caller_records
    |> Enum.flat_map(& &1["gaps"])
    |> Enum.uniq_by(& &1["key"])
    |> Enum.sort_by(& &1["key"])
  end

  defp caller_graph_observation(observation, observed_mfas) do
    %{
      "path" => observation["observation_path"],
      "sha256" => observation["observation_sha256"],
      "log_sha256" => observation["log_sha256"],
      "selected_mfas" => observed_mfas,
      "selected_original_id" => "EX-010",
      "scope" => "saved selected projection only; current graph completeness is unproven"
    }
  end

  def validate_static_callers!(record) when is_map(record) do
    evidence = record["static_caller_evidence"]
    true = is_map(evidence)
    true = evidence["lane"] == record["lane"]
    true = evidence["complete"] == false
    true = evidence["recommendation_gate"] == false
    true = record["candidate"] == nil
    true = record["implementation_authorized"] == false

    expected =
      for row <- record["identity_rows"],
          mfa <- row["live_mfas"],
          do: {row["identity"]["id"], mfa}

    actual = Enum.map(evidence["records"], &{&1["identity_id"], &1["mfa"]})
    true = length(actual) == length(Enum.uniq(actual))
    true = Enum.sort(actual) == Enum.sort(expected)
    gap_keys = Enum.map(evidence["required_evidence_gaps"], & &1["key"])
    true = length(gap_keys) == length(Enum.uniq(gap_keys))
    true = gap_keys != []
    true = record["required_evidence_gaps"] == evidence["required_evidence_gaps"]

    Enum.each(evidence["records"], fn caller_record ->
      true = caller_record["dynamic_boundary"] == "unproven"
      true = Enum.all?(caller_record["gap_keys"], &(&1 in gap_keys))

      true =
        Enum.all?(
          caller_record["observed_incoming_edges"],
          &(&1 in Enum.map(evidence["edges"], fn e -> e["key"] end))
        )

      true =
        Enum.all?(
          caller_record["observed_outgoing_edges"],
          &(&1 in Enum.map(evidence["edges"], fn e -> e["key"] end))
        )
    end)

    :ok
  end

  def validate_sizing!(record) when is_map(record) do
    measurements = record["measurements"]

    measured_fields = [
      "context_tokens",
      "task1_source_tokens",
      "task2_source_tokens",
      "combined_tokens",
      "output_tokens",
      "cushion_tokens",
      "reserve_tokens",
      "source_file_count",
      "task_count",
      "plan_count",
      "effort_upper_working_days"
    ]

    with :ok <- validate_measurement_shape(measurements, measured_fields),
         :ok <- validate_sizing_limits(measurements),
         :ok <- validate_sizing_scope_limits(measurements),
         :ok <- validate_sizing_lane_freshness(record, measurements) do
      validate_candidate_selection(record)
    end
  end

  defp validate_measurement_shape(measurements, fields) when is_map(measurements) do
    if Enum.any?(fields, fn field ->
         not is_integer(measurements[field]) or measurements[field] < 0
       end),
       do: {:error, :measurement_unknown},
       else: :ok
  end

  defp validate_measurement_shape(_measurements, _fields), do: {:error, :measurement_unknown}

  defp validate_sizing_limits(measurements) do
    context = measurements["context_tokens"]
    task1 = measurements["task1_source_tokens"]
    task2 = measurements["task2_source_tokens"]
    combined = measurements["combined_tokens"]

    case validate_sizing_source_limits(context, task1, task2, combined) do
      :ok -> validate_sizing_budget_limits(measurements)
      error -> error
    end
  end

  defp validate_sizing_source_limits(context, task1, task2, combined) do
    cond do
      context > 52_000 -> {:error, :context_limit_exceeded}
      task1 > 10_000 -> {:error, :source_limit_exceeded}
      combined < context + task1 -> {:error, :combined_count_underreported}
      task2 != 0 -> {:error, :task2_source_reads_not_zero}
      true -> :ok
    end
  end

  defp validate_sizing_budget_limits(measurements) do
    output = measurements["output_tokens"]
    cushion = measurements["cushion_tokens"]
    reserve = measurements["reserve_tokens"]
    working = measurements["combined_tokens"] + output + cushion
    total = working + reserve

    cond do
      output > 5_000 -> {:error, :output_limit_exceeded}
      cushion > 2_000 -> {:error, :cushion_limit_exceeded}
      reserve != 31_000 -> {:error, :reserve_mismatch}
      working > 69_000 -> {:error, :working_limit_exceeded}
      total > 100_000 -> {:error, :total_limit_exceeded}
      true -> :ok
    end
  end

  defp validate_sizing_scope_limits(measurements) do
    cond do
      measurements["source_file_count"] > 5 -> {:error, :source_file_limit_exceeded}
      measurements["task_count"] not in [2, 3] -> {:error, :task_count_out_of_range}
      measurements["plan_count"] not in 4..5 -> {:error, :plan_count_out_of_range}
      measurements["effort_upper_working_days"] > 3 -> {:error, :effort_limit_exceeded}
      true -> :ok
    end
  end

  defp validate_sizing_lane_freshness(record, measurements) do
    if stale_lane_record?(record["lane_records"], measurements["lane_record_sha256s"]),
      do: {:error, :stale_lane_record},
      else: :ok
  end

  defp stale_lane_record?(lanes, hashes) when is_map(lanes) do
    not is_map(hashes) or
      Enum.any?(["core", "floor"], fn lane ->
        get_in(lanes, [lane, "record", "sha256"]) != hashes[lane]
      end)
  end

  defp stale_lane_record?(_lanes, _hashes), do: false

  defp validate_candidate_selection(record) do
    candidates = record["candidates"]
    candidate = record["candidate"]

    cond do
      not is_list(candidates) or length(candidates) > 1 ->
        {:error, :candidate_cardinality_exceeded}

      candidates == [] and not is_nil(candidate) ->
        {:error, :candidate_presence_mismatch}

      candidates == [] ->
        :ok

      not is_map(hd(candidates)) or hd(candidates) != candidate ->
        {:error, :candidate_presence_mismatch}

      true ->
        validate_candidate_evidence(record, candidate)
    end
  end

  defp validate_candidate_evidence(record, candidate) do
    cond do
      record["evidence_complete"] != true or
        record["source_join_complete"] != true or
        record["caller_closure_complete"] != true or record["global_gaps"] != [] ->
        {:error, :candidate_requires_complete_evidence}

      record["actual_library_collision"] == true ->
        {:error, :actual_library_collision}

      record["actual_library_collision"] != false ->
        {:error, :collision_status_unknown}

      not is_map(record["lanes"]) ->
        {:error, :lane_membership_missing}

      true ->
        validate_candidate_scope!(candidate, record["lanes"])
    end
  end

  defp validate_candidate_scope!(candidate, lanes) do
    Enum.reduce_while(["core", "floor"], :ok, fn lane, :ok ->
      case validate_candidate_lane(candidate[lane], lanes[lane]) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  defp validate_candidate_lane(lane_candidate, lane_record) do
    cond do
      not is_map(lane_record) or not is_list(lane_candidate) or lane_candidate == [] ->
        {:error, :empty_candidate_scope}

      not valid_candidate_lane_members?(lane_record) ->
        {:error, :pending_complement_missing}

      true ->
        validate_candidate_membership(lane_candidate, lane_record)
    end
  end

  defp valid_candidate_lane_members?(lane_record) do
    Enum.all?(
      ["original_live_mfas", "delivered_scope_mfas", "pending_mfas"],
      &is_list(lane_record[&1])
    )
  end

  defp validate_candidate_membership(selected, lane_record) do
    original = lane_record["original_live_mfas"]
    delivered = lane_record["delivered_scope_mfas"]
    pending = lane_record["pending_mfas"]
    original_set = MapSet.new(original)
    delivered_set = MapSet.new(delivered)
    pending_set = MapSet.new(pending)
    selected_set = MapSet.new(selected)
    exact_pending = MapSet.difference(original_set, delivered_set)

    cond do
      duplicate_candidate_members?(original, delivered, pending, selected) ->
        {:error, :duplicate_mfa_membership}

      pending_set != exact_pending ->
        {:error, :pending_complement_mismatch}

      not MapSet.disjoint?(selected_set, delivered_set) ->
        {:error, :delivered_overlap}

      not MapSet.subset?(selected_set, pending_set) ->
        {:error, :candidate_outside_pending_scope}

      true ->
        :ok
    end
  end

  defp duplicate_candidate_members?(original, delivered, pending, selected) do
    Enum.any?(
      [
        {original, length(original)},
        {delivered, length(delivered)},
        {pending, length(pending)},
        {selected, length(selected)}
      ],
      fn {members, length} -> MapSet.size(MapSet.new(members)) != length end
    )
  end

  def build_sizing_record!(core, floor, measurements)
      when is_map(core) and is_map(floor) and is_map(measurements) do
    :ok = validate_sizing_lane_pair!(core, floor)

    lane_records = %{"core" => core, "floor" => floor}

    lane_summaries = build_sizing_lane_summaries(lane_records, measurements)

    evidence_complete = sizing_evidence_complete?(lane_records)

    record = %{
      "schema" => "fablebook.guard-aggregate-candidate-sizing/1",
      "generation" => core["generation"],
      "lane_records" => lane_summaries,
      "candidate" => nil,
      "candidates" => [],
      "evidence_complete" => evidence_complete,
      "source_join_complete" => evidence_complete,
      "caller_closure_complete" => evidence_complete,
      "global_gaps" =>
        if(evidence_complete, do: [], else: ["target_source_and_caller_evidence_incomplete"]),
      "candidate_fit" => %{
        "status" => "not_measured_without_complete_source_and_caller_closure",
        "context_tokens" => nil,
        "source_tokens" => nil,
        "effort_upper_working_days" => nil
      },
      "actual_library_collision" => nil,
      "owner_decision" => %{
        "options" => [
          "Review the complete rejoin and separately authorize a bounded evidence-closure increment.",
          "Approve a scoped remedy or reconsider the strategy."
        ],
        "no_later_work_authorized" => true,
        "automatic_phase_or_disposition" => false
      },
      "forward_effort" => %{
        "working_day_convention" =>
          "Project working-day units; token counts are not converted to time.",
        "upper_bound_limit_working_days" => 3,
        "upper_bound_working_days" => nil,
        "status" => "unknown_fails_closed",
        "items" => [
          %{
            "work" =>
              "Complete lane-pinned target-source identity, size, digest, repository, lock, and archive mappings.",
            "upper_working_days" => nil,
            "blocked_by" => "target-source gaps remain in both lanes"
          },
          %{
            "work" =>
              "Reconcile current graph observations and callback/delegate provenance for the complete caller set.",
            "upper_working_days" => nil,
            "blocked_by" => "current graph and callback/delegate evidence gaps remain"
          },
          %{
            "work" =>
              "Run scoped controls, integrate evidence, review, apply accepted fixes, and retest.",
            "upper_working_days" => nil,
            "blocked_by" =>
              "candidate scope and required source/caller context are not established"
          },
          %{
            "work" =>
              "Run focused and full local checks, then obtain hosted CI and prepare reviewed delivery.",
            "upper_working_days" => nil,
            "bounded_reviews" => 2,
            "waits_estimated_as_active_work" => false,
            "blocked_by" => "no later increment is authorized"
          }
        ],
        "prior_observations" => "Historical durations and token counts are non-certifying."
      },
      "implementation_authorized" => false,
      "measurements" => measurements
    }

    :ok = validate_sizing!(record)
    record
  end

  defp validate_sizing_lane_pair!(core, floor) do
    :ok = validate_aggregate_lane!(core)
    :ok = validate_aggregate_lane!(floor)
    :ok = validate_static_callers!(core)
    :ok = validate_static_callers!(floor)
    true = core["lane"] == "core" and floor["lane"] == "floor"
    true = core["generation"] == floor["generation"]
    true = core["identity"] == floor["identity"]
    true = core["delivery"] == floor["delivery"]
    :ok
  end

  defp sizing_evidence_complete?(lane_records) do
    Enum.all?(lane_records, fn {_lane, record} ->
      record["membership_join_complete"] == true and
        record["source_join_complete"] == true and
        record["target_source_coverage_complete"] == true and
        record["target_source_gaps"] == [] and
        record["static_caller_evidence"]["complete"] == true and
        record["required_evidence_gaps"] == []
    end)
  end

  defp build_sizing_lane_summaries(lane_records, measurements) do
    lane_paths = %{
      "core" =>
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json",
      "floor" =>
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json"
    }

    Map.new(lane_records, fn {lane, record} ->
      rows = record["identity_rows"]

      members = fn field ->
        rows
        |> Enum.flat_map(&Map.fetch!(&1, field))
        |> Enum.uniq()
        |> Enum.sort()
        |> canonical_mfas!()
      end

      original = members.("original_live_mfas")
      delivered = members.("delivered_scope_mfas")
      pending = members.("pending_mfas")
      exact_pending = MapSet.difference(MapSet.new(original), MapSet.new(delivered))
      true = MapSet.new(pending) == exact_pending
      set_metadata = measurements["membership_set_metadata"][lane]
      original_metadata = set_metadata["original_live_mfas"]
      delivered_metadata = set_metadata["delivered_scope_mfas"]
      pending_metadata = set_metadata["pending_complement"]
      true = original_metadata["unique_mfas"] == length(original)
      true = delivered_metadata["unique_mfas"] == length(delivered)
      true = pending_metadata["unique_mfas"] == length(pending)

      target_gaps = record["target_source_gaps"]
      required_gaps = record["required_evidence_gaps"]
      caller = record["static_caller_evidence"]
      source_evidence = record["source_and_caller_evidence"]
      raw_hash = measurements["lane_record_sha256s"][lane]
      true = is_binary(raw_hash) and byte_size(raw_hash) == 64

      summary = %{
        "record" => %{"path" => lane_paths[lane], "sha256" => raw_hash},
        "generation" => record["generation"],
        "identity" => record["identity"],
        "membership_join_complete" => record["membership_join_complete"],
        "source_join_complete" => record["source_join_complete"],
        "target_source_coverage_complete" => record["target_source_coverage_complete"],
        "scope_complete" => record["scope_complete"],
        "inventory_universe" => record["inventory_universe"],
        "identity_rows" => %{
          "selector" => "$.identity_rows[*]",
          "count" => length(rows),
          "sha256" => record["membership_sha256"]
        },
        "existing_selected_mfas" => %{
          "source_selectors" => ["$.selected_mfas", "$.live_mfas"],
          "selected_count" => length(record["selected_mfas"]),
          "selected_sha256" => digest(record["selected_mfas"]),
          "live_count" => length(record["live_mfas"]),
          "live_sha256" => digest(record["live_mfas"])
        },
        "membership" => %{
          "original_live_mfas" => %{
            "selector" => "$.identity_rows[*].original_live_mfas",
            "count" => length(original),
            "canonical_mfa_set_sha256" => original_metadata["canonical_mfa_set_sha256"]
          },
          "delivered_scope_mfas" => %{
            "selector" => "$.identity_rows[*].delivered_scope_mfas",
            "count" => length(delivered),
            "canonical_mfa_set_sha256" => delivered_metadata["canonical_mfa_set_sha256"]
          },
          "pending_complement" => %{
            "selector" => "unique_sorted_union($.identity_rows[*].pending_mfas)",
            "set_difference" =>
              "unique_sorted_union($.identity_rows[*].original_live_mfas) minus unique_sorted_union($.identity_rows[*].delivered_scope_mfas)",
            "count" => length(pending),
            "canonical_mfa_set_sha256" => pending_metadata["canonical_mfa_set_sha256"],
            "source_record_sha256" => raw_hash
          }
        },
        "target_source_associations" => %{
          "count" => length(record["target_source_associations"]),
          "sha256" => digest(record["target_source_associations"])
        },
        "target_source_gaps" => %{
          "count" => length(target_gaps),
          "records_sha256" => digest(target_gaps),
          "reason_counts" => Enum.frequencies_by(target_gaps, & &1["reason"]),
          "bounded_remedy" =>
            "Bind each lane-pinned source path, size, digest, repository ref, lock, and archive row."
        },
        "required_evidence_gaps" => %{
          "count" => length(required_gaps),
          "records_sha256" => digest(required_gaps),
          "reason_counts" => Enum.frequencies_by(required_gaps, & &1["reason"]),
          "bounded_remedy" =>
            "Complete current lane-pinned graph reconciliation and review callback/delegate provenance."
        },
        "source_and_caller_evidence" => %{
          "sha256" => digest(source_evidence),
          "exact_source_count" => length(source_evidence["exact_sources"]),
          "matched_mfa_count" => length(source_evidence["matched_mfas"]),
          "delegate_edge_count" => length(source_evidence["delegate_edges"]),
          "review_count" => length(source_evidence["reviews"])
        },
        "static_caller_evidence" => %{
          "complete" => caller["complete"],
          "recommendation_gate" => caller["recommendation_gate"],
          "edge_count" => length(caller["edges"]),
          "edges_sha256" => digest(caller["edges"]),
          "record_count" => length(caller["records"]),
          "records_sha256" => digest(caller["records"]),
          "graph_observation_bundle" => caller["graph_observation"],
          "graph_observation_bundle_sha256" => digest(caller["graph_observation"]),
          "required_gap_count" => length(caller["required_evidence_gaps"]),
          "required_gaps_sha256" => digest(caller["required_evidence_gaps"])
        },
        "stops" => @stops
      }

      {lane, summary}
    end)
  end

  def with_static_caller_crosswalk!(report, records)
      when is_map(report) and is_list(records) do
    rows =
      records
      |> Enum.sort_by(& &1["lane"])
      |> Enum.flat_map(fn record ->
        :ok = validate_static_callers!(record)

        Enum.map(record["static_caller_evidence"]["records"], fn caller_record ->
          Map.take(caller_record, [
            "identity_id",
            "mfa",
            "status",
            "observed_incoming_edges",
            "observed_outgoing_edges",
            "delegate_paths",
            "finding_refs",
            "dynamic_boundary",
            "gap_keys"
          ])
          |> Map.put("lane", record["lane"])
        end)
      end)

    gaps =
      records
      |> Enum.flat_map(& &1["static_caller_evidence"]["required_evidence_gaps"])
      |> Enum.uniq_by(& &1["key"])
      |> Enum.sort_by(& &1["key"])

    Map.put(report, "static_caller_crosswalk", %{
      "rows" => rows,
      "required_evidence_gaps" => gaps,
      "recommendation_gate" => false
    })
  end

  defp caller_observation_mfa!(text) when is_binary(text) do
    case Regex.run(~r/^([^:]+):([^\/]+)\/(\d+)$/, text) do
      [_, module, function, arity] -> [module, function, String.to_integer(arity)]
      _ -> raise ArgumentError, "invalid selected MFA in graph observation"
    end
  end

  defp caller_observation_edge!(edge, lane, record, source_records) when is_map(edge) do
    from = [edge["module"], edge["function"], edge["arity"]]
    observed_to = [edge["callee_module"], edge["callee_function"], edge["callee_arity"]]
    true = Enum.all?(from, &(!is_nil(&1)))
    true = Enum.all?(Enum.take(observed_to, 2), &(!is_nil(&1)))

    delegate =
      Enum.find(record["source_and_caller_evidence"]["delegate_edges"], fn candidate ->
        candidate["caller"] == from and
          Enum.take(candidate["callee"], 2) == Enum.take(observed_to, 2)
      end)

    to = if delegate, do: delegate["callee"], else: observed_to
    caller_path = Path.basename(hd(from)) <> ".erl"

    caller_source_key =
      caller_source_for_mfa(record, from) ||
        caller_source_for_basename(source_records, caller_path)

    callee_path = Path.basename(hd(Enum.take(to, 2))) <> ".erl"
    callee_source_key = caller_source_for_basename(source_records, callee_path)
    delegate_key = if delegate, do: caller_delegate_key(lane, delegate), else: nil

    identity = %{
      "lane" => lane,
      "from" => from,
      "to" => to,
      "kind" => edge["kind"],
      "caller_source_key" => caller_source_key,
      "callee_source_key" => callee_source_key,
      "delegate_path_key" => delegate_key
    }

    %{
      "key" => "edge:" <> digest(identity),
      "lane" => lane,
      "from" => from,
      "to" => to,
      "kind" => edge["kind"],
      "caller_source_key" => caller_source_key,
      "callee_source_key" => callee_source_key,
      "delegate_path_key" => delegate_key,
      "citations" => if(delegate, do: delegate["citations"], else: []),
      "callee_arity" =>
        if(is_integer(List.last(to)),
          do: "linked_from_scoped_delegate",
          else: "unresolved_in_graph_observation"
        )
    }
  end

  defp caller_mark_two_edge_cycles(edges) do
    pairs = MapSet.new(edges, &{&1["from"], &1["to"]})

    Enum.map(edges, fn edge ->
      reverse = {edge["to"], edge["from"]}

      Map.put(
        edge,
        "cycle_marker",
        if(MapSet.member?(pairs, reverse), do: "two_edge_cycle", else: nil)
      )
    end)
  end

  defp caller_finding_matches?(finding, ["inets", "enable_trace", arity]) do
    expected_call =
      if arity == 2,
        do: "inets_trace:enable(Level, Dest)",
        else: "inets_trace:enable(Level, Dest, Service)"

    Enum.any?(finding["citations"] || [], fn
      [path, reference] ->
        String.ends_with?(path, "/inets.erl") and String.contains?(reference, expected_call)

      _ ->
        false
    end)
  end

  defp caller_finding_matches?(_finding, _mfa), do: false

  defp caller_source_for_mfa(record, mfa) do
    Enum.find_value(record["target_source_associations"], fn association ->
      if association["mfa"] == mfa and association["status"] == "cited_static_evidence",
        do: association["source_key"]
    end)
  end

  defp caller_delegate_paths(record, mfa) do
    record["source_and_caller_evidence"]["delegate_edges"]
    |> Enum.filter(&(&1["caller"] == mfa))
    |> Enum.map(fn edge ->
      %{
        "key" => caller_delegate_key(record["lane"], edge),
        "source_key" => caller_source_for_mfa(record, mfa),
        "caller" => edge["caller"],
        "callee" => edge["callee"],
        "citations" => edge["citations"]
      }
    end)
    |> Enum.sort_by(& &1["key"])
  end

  defp caller_delegate_key(lane, edge) do
    "delegate:" <>
      digest(%{
        "lane" => lane,
        "caller" => edge["caller"],
        "callee" => edge["callee"],
        "citations" => edge["citations"]
      })
  end

  defp caller_source_records(record) do
    base = List.first(record["target_source_records"])
    true = is_map(base)

    record["source_and_caller_evidence"]["exact_sources"]
    |> Enum.map(fn [path, bytes, sha256] ->
      identity = %{
        "lane" => record["lane"],
        "repository_ref" => base["repository_ref"],
        "lock_sha256" => record["lock_sha256"],
        "archive_sha256" => base["archive_sha256"],
        "relative_path" => path,
        "bytes" => bytes,
        "sha256" => sha256
      }

      existing = Enum.find(record["target_source_records"], &(&1["relative_path"] == path))

      %{
        "key" => if(existing, do: existing["key"], else: "source:" <> digest(identity)),
        "lane" => record["lane"],
        "repository_ref" => base["repository_ref"],
        "lock_sha256" => record["lock_sha256"],
        "archive_sha256" => base["archive_sha256"],
        "relative_path" => path,
        "bytes" => bytes,
        "sha256" => sha256,
        "evidence_status" => "existing_lane_scoped_exact_source_hash"
      }
    end)
    |> Enum.uniq_by(& &1["key"])
    |> Enum.sort_by(& &1["key"])
  end

  defp caller_source_for_basename(source_records, basename) do
    case Enum.find(source_records, &String.ends_with?(&1["relative_path"], "/" <> basename)) do
      %{"key" => key} -> key
      nil -> nil
    end
  end

  defp caller_gap!(lane, identity_id, mfa, reason) do
    identity = %{
      "lane" => lane,
      "identity_id" => identity_id,
      "mfa" => mfa,
      "reason" => reason
    }

    %{
      "key" => "caller-gap:" <> digest(identity),
      "lane" => lane,
      "identity_id" => identity_id,
      "mfa" => mfa,
      "reason" => reason,
      "remedy" =>
        "Provide a complete lane- and lock-pinned static graph snapshot with exact incoming/outgoing edges and source provenance for this MFA."
    }
  end

  def parse_mfa_identity!(value) when is_binary(value) do
    case Regex.run(~r/^([^:]+):([^\/]+)\/+([0-9]+)$/, value) do
      [_, module, function, arity] -> [module, function, String.to_integer(arity)]
      _ -> raise ArgumentError, "invalid recorded MFA identity #{inspect(value)}"
    end
  end

  def creator_reference_scope!("creator:" <> ref, lane) when lane in ["core", "floor"] do
    case String.split(ref, ":") do
      [id, ref_lane] when id != "" and ref_lane in ["core", "floor"] ->
        if ref_lane == lane, do: :current_lane, else: :other_lane

      _ ->
        raise ArgumentError, "invalid creator reference #{inspect(ref)}"
    end
  end

  def creator_reference_scope!(ref, _lane),
    do: raise(ArgumentError, "invalid creator reference #{inspect(ref)}")

  def validate_creator_match_set!(id, reported, expected, baseline) do
    true = id in ["EX-159", "EX-165", "EX-089"] or String.starts_with?(id, "NEW-")
    reported = canonical_mfas!(reported)
    expected = canonical_mfas!(expected)
    baseline = canonical_mfas!(baseline)
    true = reported == expected
    if id == "EX-165", do: true = reported == baseline
    :ok
  end

  def equal_count_mfa_mutation!(mfas, replacement) do
    original = canonical_mfas!(mfas)
    [first | rest] = original
    replacement = mfa!(replacement)
    mutated = [replacement | rest] |> Enum.sort()
    true = length(mutated) == length(original)
    true = mutated != original
    true = first != replacement
    mutated
  end

  def partition_mfas!(baseline, live, delivered_scope) do
    baseline = canonical_mfas!(baseline)
    live = canonical_mfas!(live)
    delivered_scope = canonical_mfas!(delivered_scope)
    delivered = set_intersection(delivered_scope, live)
    pending = set_difference(live, delivered_scope)
    true = MapSet.union(MapSet.new(delivered), MapSet.new(pending)) == MapSet.new(live)
    true = MapSet.disjoint?(MapSet.new(delivered), MapSet.new(pending))

    %{
      "added_mfas" => set_difference(live, baseline),
      "missing_mfas" => set_difference(baseline, live),
      "delivered_mfas" => delivered,
      "delivered_now_missing_mfas" => set_difference(delivered_scope, live),
      "pending_mfas" => pending
    }
  end

  defp required!(map, key), do: Map.fetch!(map, key)

  defp mfa!({module, function, arity})
       when is_atom(module) and is_atom(function) and is_integer(arity) and arity >= 0 do
    [Atom.to_string(module), Atom.to_string(function), arity]
  end

  defp mfa!([module, function, arity])
       when is_binary(module) and is_binary(function) and is_integer(arity) and arity >= 0,
       do: [module, function, arity]

  defp mfa!(value), do: raise(ArgumentError, "invalid static MFA: #{inspect(value)}")

  defp sanitize!(%MapSet{} = value), do: value |> MapSet.to_list() |> Enum.sort() |> sanitize!()

  defp sanitize!(value) when is_map(value) do
    value
    |> Map.to_list()
    |> Map.new(fn {key, item} -> {key_string!(key), sanitize!(item)} end)
  end

  defp sanitize!(value) when is_list(value), do: Enum.map(value, &sanitize!/1)
  defp sanitize!(value) when is_tuple(value), do: value |> Tuple.to_list() |> sanitize!()

  defp sanitize!(value) when is_atom(value) and value not in [nil, true, false],
    do: Atom.to_string(value)

  defp sanitize!(value) when is_pid(value) or is_function(value) or is_reference(value),
    do: raise(ArgumentError, "non-static evidence value")

  defp sanitize!(value), do: value

  defp key_string!(key) when is_binary(key), do: key
  defp key_string!(key) when is_atom(key), do: Atom.to_string(key)
  defp key_string!(key) when is_integer(key), do: Integer.to_string(key)

  defp key_string!(key),
    do: inspect(key, limit: :infinity, printable_limit: :infinity, structs: false)

  defp digest(value) do
    :crypto.hash(:sha256, :erlang.term_to_binary(value, [:deterministic]))
    |> Base.encode16(case: :lower)
  end

  defp aggregate_identity!(row) do
    identity = sanitize!(Map.fetch!(row, :identity))
    true = identity["identity_class"] in ["exclusion", "lane_metadata"]
    true = is_binary(identity["id"])
    identity
  end

  defp aggregate_row!(row) do
    identity = aggregate_identity!(row)
    baseline = canonical_mfas!(Map.fetch!(row, :baseline_mfas))
    original_live = canonical_mfas!(Map.fetch!(row, :original_live_mfas))
    replacement_live = canonical_mfas!(Map.fetch!(row, :replacement_live_mfas))
    delivered_scope = canonical_mfas!(Map.fetch!(row, :delivered_scope_mfas))
    live = replacement_live
    partitions = partition_mfas!(baseline, live, delivered_scope)

    Map.merge(
      %{
        "identity" => identity,
        "original_live_mfas" => original_live,
        "replacement_live_mfas" => replacement_live,
        "baseline_mfas" => baseline,
        "live_mfas" => live,
        "delivered_scope_mfas" => delivered_scope,
        "delivered_slice_owner" => Map.get(row, :delivered_slice_owner),
        "delivery_refs" => sanitize!(Map.get(row, :delivery_refs, [])),
        "mapping_status" => Map.fetch!(row, :mapping_status)
      },
      partitions
    )
    |> maybe_add_historical!(row, live, delivered_scope)
  end

  defp maybe_add_historical!(row_record, row, live, delivered_scope) do
    case Map.fetch(row, :historical_partition_mfas) do
      {:ok, historical} ->
        historical = canonical_mfas!(historical)
        historical_union_delivered = Enum.uniq(historical ++ delivered_scope)

        row_record
        |> Map.put("historical_partition_name", Map.fetch!(row, :historical_partition_name))
        |> Map.put("historical_partition_mfas", historical)
        |> Map.put("historical_complement_mfas", set_difference(live, historical))
        |> Map.put(
          "pending_after_delivered_and_historical_mfas",
          set_difference(live, historical_union_delivered)
        )

      :error ->
        row_record
    end
  end

  defp canonical_mfas!(mfas) do
    result = mfas |> Enum.map(&mfa!/1) |> Enum.uniq() |> Enum.sort()
    true = length(result) == length(mfas)
    result
  end

  defp set_difference(left, right),
    do: MapSet.difference(MapSet.new(left), MapSet.new(right)) |> MapSet.to_list() |> Enum.sort()

  defp set_intersection(left, right),
    do:
      MapSet.intersection(MapSet.new(left), MapSet.new(right)) |> MapSet.to_list() |> Enum.sort()

  defp target_source!(record, identity_id, mfa, archive_files, archive_sha256) do
    path_module = Enum.at(mfa, 0)

    case find_target_source_candidate!(record, mfa, path_module, archive_files) do
      {:ok, path, bytes, sha256, archive_row, selected} ->
        {:ok,
         build_target_source_record(
           record,
           path,
           bytes,
           sha256,
           archive_row,
           archive_sha256,
           selected
         )}

      {:gap, reason} ->
        {:gap,
         build_target_source_gap(record, identity_id, mfa, path_module, archive_sha256, reason)}
    end
  end

  defp find_target_source_candidate!(record, mfa, path_module, archive_files) do
    evidence = record["source_and_caller_evidence"]

    selected =
      Enum.find(evidence["selected_function_evidence"], fn item ->
        item["mfa"] == mfa
      end)

    candidates =
      evidence["exact_sources"]
      |> Enum.filter(fn
        [path, _bytes, _sha256] ->
          Path.basename(path) in ["#{path_module}.erl", "#{path_module}.ex"]

        _ ->
          false
      end)

    select_target_source_candidate(selected, candidates, record, archive_files)
  end

  defp select_target_source_candidate(nil, _candidates, _record, _archive_files),
    do: {:gap, "source_mapping_not_present_in_scoped_findings"}

  defp select_target_source_candidate(selected, [source], record, archive_files)
       when is_map(selected) do
    verify_target_source_candidate(selected, source, record, archive_files)
  end

  defp select_target_source_candidate(
         _selected,
         _candidates,
         _record,
         _archive_files
       ),
       do: {:gap, "source_mapping_ambiguous_or_missing"}

  defp verify_target_source_candidate(
         selected,
         [path, bytes, sha256],
         record,
         archive_files
       ) do
    evidence = record["source_and_caller_evidence"]
    source_review = Enum.find(evidence["reviews"], &(&1["source_path"] == path))
    cited? = Enum.any?(selected["citations"], &(citation_path(&1) == path))

    archive_rows =
      Enum.filter(archive_files, fn row ->
        row["lane"] == record["lane"] and row["source_path"] == path and
          row["sha256"] == sha256 and archive_bytes(row) == bytes
      end)

    if source_review && cited? && source_review["bytes"] == bytes &&
         source_review["sha256"] == sha256 && length(archive_rows) == 1 do
      [archive_row] = archive_rows
      {:ok, path, bytes, sha256, archive_row, selected}
    else
      {:gap, "archive_or_citation_mismatch"}
    end
  end

  defp build_target_source_record(
         record,
         path,
         bytes,
         sha256,
         archive_row,
         archive_sha256,
         selected
       ) do
    repository_ref =
      archive_row["repository_ref"] || archive_row["repo_ref"] || archive_row["ref"] ||
        "locked-archive:#{archive_sha256}"

    identity = %{
      "lane" => record["lane"],
      "repository_ref" => repository_ref,
      "lock_sha256" => record["lock_sha256"],
      "archive_sha256" => archive_sha256,
      "relative_path" => path,
      "bytes" => bytes,
      "sha256" => sha256
    }

    Map.merge(identity, %{
      "key" => "source:" <> digest(identity),
      "status" => "source_identity_verified_by_locked_archive",
      "evidence_status" => "cited_static_evidence",
      "citations" => Enum.filter(selected["citations"], &(citation_path(&1) == path))
    })
  end

  defp build_target_source_gap(record, identity_id, mfa, path_module, archive_sha256, reason) do
    lane = record["lane"]

    %{
      "key" => source_gap_key(lane, identity_id, mfa),
      "identity_id" => identity_id,
      "lane" => lane,
      "mfa" => mfa,
      "module" => path_module,
      "relative_path" => nil,
      "lock_sha256" => record["lock_sha256"],
      "archive_sha256" => archive_sha256,
      "status" => reason,
      "remedy" =>
        "Add the exact #{lane} InstalledOtp module-to-source path for #{inspect(path_module)}, then bind that relative path, byte count, digest, repository ref, lane lock, and archive row to this MFA."
    }
  end

  defp source_key_index!(associations, key) do
    case Enum.find(associations, &(&1["source_key"] == key)) do
      %{"identity_id" => identity_id, "mfa" => mfa} -> {identity_id, mfa}
      _ -> raise ArgumentError, "source key has no target association"
    end
  end

  defp source_gap_key(lane, identity_id, mfa),
    do: "source-gap:" <> digest(%{"lane" => lane, "identity_id" => identity_id, "mfa" => mfa})

  defp citation_path([citation, _text]) when is_binary(citation),
    do: citation |> String.split(":", parts: 2) |> hd()

  defp citation_path(_), do: nil

  defp archive_bytes(%{"bytes" => bytes}) when is_integer(bytes), do: bytes
  defp archive_bytes(%{"size" => bytes}) when is_integer(bytes), do: bytes
  defp archive_bytes(_row), do: nil
end
