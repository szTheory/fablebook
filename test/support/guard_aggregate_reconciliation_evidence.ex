defmodule Fablebook.Test.GuardAggregateReconciliationEvidence do
  @moduledoc false

  @schema "fablebook.guard-aggregate-lane/1"
  @report_schema "fablebook.guard-aggregate-crosswalk/1"
  @collector "guard-aggregate-tracer/1"
  @phase4_dir ".planning/phases/04-evidence-only-source-and-gap-provenance-closure"
  @phase3_recovery_dir ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
  @phase4_archive_dir ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure"
  @phase3_recovery_archive_dir ".planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
  @phase3_required_files ~w(
    03-CORE-AGGREGATE-EVIDENCE.json
    03-FLOOR-AGGREGATE-EVIDENCE.json
    03-SIZING.json
    03-04-METADATA-GAP-RECEIPT.json
    03-04-METADATA-GAP-VALIDATION.json
    03-04-METADATA-GAPS.jsonl
    03-05-T2-POST-R8-HELPER-REVISION.json
    03-05-CORE-FOCUSED-R8-FAILURE.json
    03-05-CORE-FOCUSED-R8-RETEST-FAILURE.json
    03-05-CORE-FOCUSED-R8-RETEST-FAILURE-02.json
  )
  @phase4_artifacts %{
    "manifest_sha256" => "04-PROVENANCE-MANIFEST.json",
    "validation_sha256" => "04-VALIDATION.json",
    "review_sha256" => "04-EVIDENCE-REVIEW.json",
    "trace_sha256" => "04-COVERAGE-CALLER-TRACE.json",
    "digest_proof_sha256" => "04-SIZING-DIGEST-PROOF.json"
  }
  @phase4_required_files Map.values(@phase4_artifacts) ++
                           [
                             "04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl",
                             "04-TYPED-GAPS-ENV06.jsonl"
                           ]
  @lane_record_paths %{
    "core" =>
      ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json",
    "floor" =>
      ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json"
  }
  @stops %{
    "scope_complete" => false,
    "candidate" => nil,
    "implementation_authorized" => false,
    "aggregate_gate" => "open",
    "walking_skeleton" => "blocked",
    "sec_01" => "Pending"
  }

  def phase3_evidence_dir! do
    existing_evidence_dir!(
      "Phase 3",
      @phase3_recovery_archive_dir,
      @phase3_recovery_dir,
      @phase3_required_files
    )
  end

  def phase4_evidence_dir! do
    existing_evidence_dir!("Phase 4", @phase4_archive_dir, @phase4_dir, @phase4_required_files)
  end

  def phase3_writable_evidence_dir! do
    legacy = Path.expand(@phase3_recovery_dir, File.cwd!())
    archived = Path.expand(@phase3_recovery_archive_dir, File.cwd!())

    if phase3_evidence_dir!() == legacy do
      legacy
    else
      raise ArgumentError, "Phase 3 evidence is archived and read-only: #{archived}"
    end
  end

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

          Enum.each(identity_rows, &validate_inventory_membership!(&1, exported_mfas))

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

        source_join_complete =
          core["source_join_complete"] == true and floor["source_join_complete"] == true

        Map.merge(base, %{
          "scope" => "complete-original-ledger",
          "membership_join_complete" => true,
          "source_join_complete" => source_join_complete,
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

  def render_crosswalk!(core, floor, supplement) when is_map(supplement) do
    core = phase4_effective_view!(core, supplement)
    floor = phase4_effective_view!(floor, supplement)
    report = render_crosswalk!(core, floor)

    report
    |> with_source_crosswalk!([core, floor], supplement)
    |> with_static_caller_crosswalk!([core, floor], supplement)
    |> Map.put("phase4_supplement", phase4_supplement_summary!(supplement))
    |> Map.merge(%{
      "record_partition_complete" => true,
      "source_resolution" => "unresolved",
      "caller_closure" => "incomplete",
      "target_source_coverage_complete" => false,
      "source_join_complete" => false,
      "caller_closure_complete" => false,
      "legacy_digest" => "unresolved",
      "candidate" => nil,
      "implementation_authorized" => false
    })
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

  def check_bundle!(records, report, supplement)
      when is_list(records) and is_map(report) and is_map(supplement) do
    [core, floor] = Enum.sort_by(records, & &1["lane"])
    expected = render_crosswalk!(core, floor, supplement)
    true = report == expected
    :ok
  end

  def with_source_crosswalk!(report, records) when is_map(report) and is_list(records),
    do: Map.put(report, "source_crosswalk", source_crosswalk!(records))

  def with_source_crosswalk!(report, records, supplement)
      when is_map(report) and is_list(records) and is_map(supplement),
      do: Map.put(report, "source_crosswalk", source_crosswalk!(records, supplement))

  def attach_target_sources!(record, archive_files, archive_sha256)
      when is_map(record) and is_list(archive_files) and is_binary(archive_sha256) do
    :ok = validate_aggregate_lane!(record)
    original_rows = record["identity_rows"]

    {associations, gaps} =
      Enum.reduce(original_rows, {[], []}, fn row, acc ->
        accumulate_target_row!(record, row, archive_files, archive_sha256, acc)
      end)

    source_keys =
      associations
      |> Enum.filter(&(&1["status"] == "cited_static_evidence"))
      |> Enum.map(& &1["source_key"])
      |> Enum.uniq()
      |> Enum.sort()

    sources =
      source_keys
      |> Enum.map(fn key ->
        {identity_id, mfa} = source_key_index!(associations, key)
        {:ok, source} = target_source!(record, identity_id, mfa, archive_files, archive_sha256)
        source
      end)

    gaps = Enum.sort_by(gaps, & &1["key"])
    associations = Enum.sort_by(associations, &{&1["identity_id"], &1["mfa"] || [], &1["status"]})

    record
    |> Map.put("target_source_records", sources)
    |> Map.put("target_source_associations", associations)
    |> Map.put("target_source_gaps", gaps)
    |> Map.put("source_join_complete", gaps == [])
    |> Map.put("target_source_coverage_complete", gaps == [])
    |> tap(fn enriched -> :ok = validate_target_sources!(enriched) end)
  end

  defp accumulate_target_row!(record, row, archive_files, archive_sha256, {associations, gaps}) do
    identity_id = row["identity"]["id"]

    case row["live_mfas"] do
      [] ->
        association = %{
          "identity_id" => identity_id,
          "status" => "not_applicable",
          "targets" => []
        }

        {[association | associations], gaps}

      mfas ->
        Enum.reduce(mfas, {associations, gaps}, fn mfa, acc ->
          accumulate_target_mfa!(record, identity_id, mfa, archive_files, archive_sha256, acc)
        end)
    end
  end

  defp accumulate_target_mfa!(
         record,
         identity_id,
         mfa,
         archive_files,
         archive_sha256,
         {associations, gaps}
       ) do
    case target_source!(record, identity_id, mfa, archive_files, archive_sha256) do
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

  def attach_target_sources!(record, archive_files, archive_sha256, supplement)
      when is_map(record) and is_list(archive_files) and is_binary(archive_sha256) and
             is_map(supplement) do
    phase4_effective_view!(record, supplement)
  end

  def validate_target_sources!(record) when is_map(record) do
    :ok = validate_aggregate_lane!(record)
    :ok = validate_target_source_collections!(record)
    :ok = validate_target_source_partition!(record)
    :ok = validate_not_applicable_sources!(record)

    gap_keys = unique_keys!(record["target_source_gaps"], "key")
    _source_keys = unique_keys!(record["target_source_records"], "key")

    Enum.each(
      record["target_source_associations"],
      &validate_target_association!(&1, record, gap_keys)
    )

    :ok
  end

  defp validate_target_source_collections!(record) do
    true = is_boolean(record["target_source_coverage_complete"])
    true = not (record["target_source_coverage_complete"] and record["target_source_gaps"] != [])
    true = is_list(record["target_source_records"])
    true = is_list(record["target_source_associations"])
    true = is_list(record["target_source_gaps"])
    :ok
  end

  defp validate_target_source_partition!(record) do
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

  defp validate_not_applicable_sources!(record) do
    expected_ids =
      record["identity_rows"]
      |> Enum.filter(&(&1["live_mfas"] == []))
      |> Enum.map(& &1["identity"]["id"])
      |> Enum.sort()

    actual_ids =
      record["target_source_associations"]
      |> Enum.filter(&(&1["status"] == "not_applicable"))
      |> Enum.map(& &1["identity_id"])
      |> Enum.sort()

    true = actual_ids == expected_ids
    :ok
  end

  defp unique_keys!(records, field) do
    keys = Enum.map(records, & &1[field])
    true = length(keys) == length(Enum.uniq(keys))
    keys
  end

  defp validate_target_association!(association, record, gap_keys) do
    case association["status"] do
      "cited_static_evidence" -> validate_cited_target_source!(association, record)
      "source_gap" -> true = association["gap_key"] in gap_keys
      "not_applicable" -> true = association["mfa"] == nil
      _ -> raise ArgumentError, "invalid target source association status"
    end

    :ok
  end

  defp validate_cited_target_source!(association, record) do
    source =
      Enum.find(record["target_source_records"], &(&1["key"] == association["source_key"]))

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

  def validate_target_sources!(record, supplement)
      when is_map(record) and is_map(supplement) do
    record
    |> phase4_effective_view!(supplement)
    |> validate_target_sources!()
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

  def source_crosswalk!(records, supplement) when is_list(records) and is_map(supplement) do
    records
    |> Enum.map(&phase4_effective_view!(&1, supplement))
    |> source_crosswalk!()
  end

  def attach_static_callers!(record, observation)
      when is_map(record) and is_map(observation) do
    :ok = validate_aggregate_lane!(record)
    :ok = validate_target_sources!(record)
    lane = record["lane"]
    true = observation["lane"] == lane
    true = is_binary(observation["observation_path"])
    true = is_binary(observation["observation_sha256"])
    true = byte_size(observation["observation_sha256"]) == 64
    true = is_binary(observation["log_sha256"])
    true = byte_size(observation["log_sha256"]) == 64

    observed_mfas =
      observation["selected_mfas"]
      |> Enum.map(&caller_observation_mfa!/1)
      |> Enum.uniq()
      |> Enum.sort()

    source_records = caller_source_records(record)

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

    edges = caller_mark_two_edge_cycles(edges ++ incoming)

    targets =
      for row <- record["identity_rows"], mfa <- row["live_mfas"] do
        {row["identity"]["id"], mfa}
      end

    caller_records =
      Enum.map(targets, fn {identity_id, mfa} ->
        build_static_caller_record!(
          record,
          lane,
          identity_id,
          mfa,
          observed_mfas,
          edges,
          incoming
        )
      end)
      |> Enum.sort_by(&{&1["identity_id"], &1["mfa"]})

    gaps =
      caller_records
      |> Enum.flat_map(& &1["gaps"])
      |> Enum.uniq_by(& &1["key"])
      |> Enum.sort_by(& &1["key"])

    evidence = %{
      "schema" => "guard-aggregate-static-caller-evidence/1",
      "lane" => lane,
      "graph_observation" => %{
        "path" => observation["observation_path"],
        "sha256" => observation["observation_sha256"],
        "log_sha256" => observation["log_sha256"],
        "selected_mfas" => observed_mfas,
        "selected_original_id" => "EX-010",
        "scope" => "saved selected projection only; current graph completeness is unproven"
      },
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

  defp build_static_caller_record!(record, lane, identity_id, mfa, observed_mfas, edges, incoming) do
    selected = mfa in observed_mfas
    outgoing = Enum.filter(edges, &(&1["from"] == mfa))
    incoming_edges = caller_incoming_edges(incoming, mfa)
    delegate_paths = caller_delegate_paths(record, mfa)
    finding_refs = caller_finding_refs(record, lane, identity_id, mfa)

    gaps =
      caller_record_gaps(
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

  defp caller_finding_refs(_record, _lane, identity_id, _mfa) when identity_id != "EX-010", do: []

  defp caller_finding_refs(record, lane, "EX-010", mfa) do
    record["source_and_caller_evidence"]["selected_function_evidence"]
    |> Enum.filter(&caller_finding_matches?(&1, mfa))
    |> Enum.map(fn finding ->
      citations = finding["citations"] || []

      %{
        "key" => "finding:" <> digest(%{"lane" => lane, "mfa" => mfa, "citations" => citations}),
        "source_key" => caller_source_for_mfa(record, mfa),
        "citations" => citations,
        "callback_boundary" => finding["callback_boundary"],
        "fixed_native_boundary" => finding["fixed_native_boundary"]
      }
    end)
  end

  defp caller_record_gaps(
         lane,
         identity_id,
         mfa,
         selected,
         findings,
         outgoing,
         incoming,
         delegates
       ) do
    callback_unresolved =
      findings == [] or Enum.any?(findings, &is_binary(&1["callback_boundary"]))

    missing_edges = selected and outgoing == [] and incoming == []
    missing_delegate_path = outgoing != [] and delegates == []

    missing_edge_source =
      Enum.any?(outgoing ++ incoming, fn edge ->
        not is_binary(edge["caller_source_key"]) or not is_binary(edge["callee_source_key"])
      end)

    [
      caller_gap_if(not selected, lane, identity_id, mfa, "selected_graph_observation_missing"),
      [caller_gap!(lane, identity_id, mfa, "current_graph_reconciliation_missing")],
      caller_gap_if(
        callback_unresolved,
        lane,
        identity_id,
        mfa,
        "callback_and_delegate_provenance_unreviewed"
      ),
      caller_gap_if(missing_edges, lane, identity_id, mfa, "selected_graph_edges_missing"),
      caller_gap_if(
        missing_delegate_path,
        lane,
        identity_id,
        mfa,
        "delegate_path_provenance_missing"
      ),
      caller_gap_if(missing_edge_source, lane, identity_id, mfa, "edge_source_identity_missing")
    ]
    |> List.flatten()
  end

  defp caller_gap_if(true, lane, identity_id, mfa, reason),
    do: [caller_gap!(lane, identity_id, mfa, reason)]

  defp caller_gap_if(false, _lane, _identity_id, _mfa, _reason), do: []

  def attach_static_callers!(record, _observation, supplement)
      when is_map(record) and is_map(supplement) do
    phase4_effective_view!(record, supplement)
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

  def validate_static_callers!(record, supplement)
      when is_map(record) and is_map(supplement) do
    record
    |> phase4_effective_view!(supplement)
    |> validate_static_callers!()
  end

  def validate_sizing!(record) when is_map(record) do
    measurements = record["measurements"]

    with :ok <- validate_sizing_measurements!(measurements),
         :ok <- validate_sizing_limits!(record, measurements) do
      validate_sizing_candidate!(record)
    end
  end

  defp validate_sizing_measurements!(measurements) do
    fields = [
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

    invalid =
      not is_map(measurements) or
        Enum.any?(fields, fn field ->
          not is_integer(measurements[field]) or measurements[field] < 0
        end)

    if invalid, do: {:error, :measurement_unknown}, else: :ok
  end

  defp validate_sizing_limits!(record, measurements) do
    context = measurements["context_tokens"]
    task1 = measurements["task1_source_tokens"]
    task2 = measurements["task2_source_tokens"]
    combined = measurements["combined_tokens"]
    output = measurements["output_tokens"]
    cushion = measurements["cushion_tokens"]
    reserve = measurements["reserve_tokens"]
    working = combined + output + cushion
    total = working + reserve

    checks = [
      {context > 52_000, :context_limit_exceeded},
      {task1 > 10_000, :source_limit_exceeded},
      {combined < context + task1, :combined_count_underreported},
      {task2 != 0, :task2_source_reads_not_zero},
      {output > 5_000, :output_limit_exceeded},
      {cushion > 2_000, :cushion_limit_exceeded},
      {reserve != 31_000, :reserve_mismatch},
      {working > 69_000, :working_limit_exceeded},
      {total > 100_000, :total_limit_exceeded},
      {measurements["source_file_count"] > 5, :source_file_limit_exceeded},
      {measurements["task_count"] not in [2, 3], :task_count_out_of_range},
      {measurements["plan_count"] not in 4..5, :plan_count_out_of_range},
      {measurements["effort_upper_working_days"] > 3, :effort_limit_exceeded},
      {stale_lane_record?(record, measurements), :stale_lane_record}
    ]

    first_sizing_error(checks)
  end

  defp stale_lane_record?(record, measurements) do
    case record["lane_records"] do
      lanes when is_map(lanes) ->
        expected_hashes = measurements["lane_record_sha256s"]

        not is_map(expected_hashes) or
          Enum.any?(["core", "floor"], fn lane ->
            get_in(lanes, [lane, "record", "sha256"]) != expected_hashes[lane]
          end)

      _ ->
        false
    end
  end

  defp first_sizing_error(checks) do
    Enum.find_value(checks, &sizing_constraint_error/1) || :ok
  end

  defp sizing_constraint_error({true, reason}), do: {:error, reason}
  defp sizing_constraint_error(_check), do: nil

  defp validate_sizing_candidate!(record) do
    case record["candidates"] do
      [] ->
        if is_nil(record["candidate"]),
          do: :ok,
          else: {:error, :candidate_presence_mismatch}

      [candidate] ->
        validate_selected_candidate!(record, candidate)

      _ ->
        {:error, :candidate_cardinality_exceeded}
    end
  end

  defp validate_selected_candidate!(record, candidate) do
    with :ok <- validate_candidate_presence!(record, candidate),
         :ok <- validate_candidate_evidence!(record),
         :ok <- validate_candidate_collision!(record),
         :ok <- validate_candidate_lanes!(record) do
      validate_candidate_scope!(candidate, record["lanes"])
    end
  end

  defp validate_candidate_presence!(record, candidate) do
    if is_map(candidate) and candidate == record["candidate"],
      do: :ok,
      else: {:error, :candidate_presence_mismatch}
  end

  defp validate_candidate_evidence!(record) do
    complete =
      record["evidence_complete"] == true and record["source_join_complete"] == true and
        record["caller_closure_complete"] == true and record["global_gaps"] == []

    if complete, do: :ok, else: {:error, :candidate_requires_complete_evidence}
  end

  defp validate_candidate_collision!(record) do
    case record["actual_library_collision"] do
      true -> {:error, :actual_library_collision}
      false -> :ok
      _ -> {:error, :collision_status_unknown}
    end
  end

  defp validate_candidate_lanes!(record) do
    if is_map(record["lanes"]), do: :ok, else: {:error, :lane_membership_missing}
  end

  defp validate_candidate_scope!(candidate, lanes) do
    Enum.reduce_while(["core", "floor"], :ok, fn lane, :ok ->
      candidate_scope_step!(lane, candidate, lanes)
    end)
  end

  defp candidate_scope_step!(lane, candidate, lanes) do
    case validate_candidate_lane!(candidate[lane], lanes[lane]) do
      :ok -> {:cont, :ok}
      {:error, _reason} = error -> {:halt, error}
    end
  end

  defp validate_candidate_lane!(selected, lane_record) do
    cond do
      not is_map(lane_record) or not is_list(selected) or selected == [] ->
        {:error, :empty_candidate_scope}

      not is_list(lane_record["original_live_mfas"]) or
        not is_list(lane_record["delivered_scope_mfas"]) or
          not is_list(lane_record["pending_mfas"]) ->
        {:error, :pending_complement_missing}

      true ->
        validate_candidate_membership!(
          selected,
          lane_record["original_live_mfas"],
          lane_record["delivered_scope_mfas"],
          lane_record["pending_mfas"]
        )
    end
  end

  defp validate_candidate_membership!(selected, original, delivered, pending) do
    original_set = MapSet.new(original)
    delivered_set = MapSet.new(delivered)
    pending_set = MapSet.new(pending)
    selected_set = MapSet.new(selected)
    exact_pending = MapSet.difference(original_set, delivered_set)

    checks = [
      {MapSet.size(original_set) != length(original) or
         MapSet.size(delivered_set) != length(delivered) or
         MapSet.size(pending_set) != length(pending) or
         MapSet.size(selected_set) != length(selected), :duplicate_mfa_membership},
      {pending_set != exact_pending, :pending_complement_mismatch},
      {not MapSet.disjoint?(selected_set, delivered_set), :delivered_overlap},
      {not MapSet.subset?(selected_set, pending_set), :candidate_outside_pending_scope}
    ]

    first_sizing_error(checks)
  end

  def build_sizing_record!(core, floor, measurements)
      when is_map(core) and is_map(floor) and is_map(measurements) do
    :ok = validate_aggregate_lane!(core)
    :ok = validate_aggregate_lane!(floor)
    :ok = validate_static_callers!(core)
    :ok = validate_static_callers!(floor)
    true = core["lane"] == "core" and floor["lane"] == "floor"
    true = core["generation"] == floor["generation"]
    true = core["identity"] == floor["identity"]
    true = core["delivery"] == floor["delivery"]

    lane_records = %{"core" => core, "floor" => floor}

    lane_paths = %{
      "core" =>
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json",
      "floor" =>
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json"
    }

    lane_summaries =
      Map.new(lane_records, fn {lane, record} ->
        {lane, build_lane_sizing_summary!(lane, record, measurements, lane_paths[lane])}
      end)

    evidence_complete = evidence_complete?(lane_records)

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

  defp build_lane_sizing_summary!(lane, record, measurements, lane_path) do
    rows = record["identity_rows"]
    original = lane_members!(rows, "original_live_mfas")
    delivered = lane_members!(rows, "delivered_scope_mfas")
    pending = lane_members!(rows, "pending_mfas")
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

    %{
      "record" => %{"path" => lane_path, "sha256" => raw_hash},
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
  end

  defp lane_members!(rows, field) do
    rows
    |> Enum.flat_map(&Map.fetch!(&1, field))
    |> Enum.uniq()
    |> Enum.sort()
    |> canonical_mfas!()
  end

  defp evidence_complete?(lane_records) do
    Enum.all?(lane_records, fn {_lane, record} ->
      record["membership_join_complete"] == true and
        record["source_join_complete"] == true and
        record["target_source_coverage_complete"] == true and
        record["target_source_gaps"] == [] and
        record["static_caller_evidence"]["complete"] == true and
        record["required_evidence_gaps"] == []
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

  def with_static_caller_crosswalk!(report, records, supplement)
      when is_map(report) and is_list(records) and is_map(supplement) do
    views = Enum.map(records, &phase4_effective_view!(&1, supplement))

    report
    |> with_static_caller_crosswalk!(views)
    |> Map.put("phase4_supplement", phase4_supplement_summary!(supplement))
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

  defp phase4_supplement_summary!(supplement) do
    %{
      "schema" => supplement["schema"],
      "generation" => supplement["generation"],
      "status" => supplement["status"],
      "source_access" => supplement["source_access"],
      "record_partition_complete" => supplement["record_partition_complete"],
      "source_resolution" => supplement["source_resolution"],
      "caller_closure" => supplement["caller_closure"],
      "legacy_digest" => supplement["legacy_digest"],
      "candidate" => supplement["candidate"],
      "implementation_authorized" => supplement["implementation_authorized"],
      "proof" => supplement["proof"],
      "producer_helper_source_identity" => supplement["producer_helper_source_identity"],
      "typed_gap_count" => length(supplement["typed_gaps"]),
      "source_association_count" => length(supplement["source_associations"])
    }
  end

  defp phase4_effective_view!(record, supplement)
       when is_map(record) and is_map(supplement) do
    :ok = validate_aggregate_lane!(record)
    {lane, proof, manifest} = validate_phase4_header!(record, supplement)
    true = lane == record["lane"]

    expected_roles =
      for row <- record["identity_rows"],
          {role, mfas} <- [{"baseline", row["baseline_mfas"]}, {"live", row["live_mfas"]}],
          value <- mfas,
          reduce: %{} do
        roles ->
          key = {row["identity"]["id"], mfa!(value)}
          Map.update(roles, key, MapSet.new([role]), &MapSet.put(&1, role))
      end

    expected = Map.keys(expected_roles) |> MapSet.new()
    lane_gaps = Enum.filter(supplement["typed_gaps"], &(&1["lane"] == lane))
    :ok = validate_phase4_gap_bindings!(lane_gaps, record, supplement, manifest)
    source_gaps = Enum.filter(lane_gaps, &(&1["domain"] == "source"))
    caller_gaps = Enum.filter(lane_gaps, &(&1["domain"] == "caller"))
    unknown_gaps = Enum.filter(lane_gaps, &(&1["domain"] == "unknown_target_set"))

    source_gap_keys = Enum.map(source_gaps, &phase4_mfa_key!/1)
    caller_gap_keys = Enum.map(caller_gaps, &phase4_mfa_key!/1)

    true = length(source_gap_keys) == length(Enum.uniq(source_gap_keys))
    true = length(caller_gap_keys) == length(Enum.uniq(caller_gap_keys))
    true = MapSet.new(source_gap_keys) == expected
    true = MapSet.new(caller_gap_keys) == expected

    Enum.each(source_gaps ++ caller_gaps, fn gap ->
      key = phase4_mfa_key!(gap)
      expected_roles_for_key = expected_roles[key] |> MapSet.to_list() |> Enum.sort()
      true = Enum.sort(gap["membership_roles"]) == expected_roles_for_key
      true = is_binary(gap["gap_key"]) and gap["gap_key"] != ""
      true = is_binary(gap["reason"]) and gap["reason"] != ""
      true = is_binary(gap["remedy"]) and gap["remedy"] != ""
      true = gap["evidence_status"] == "blocked_unresolved"
    end)

    expected_unknown = supplement["unknown_target_sets"][lane] |> Enum.sort()
    observed_unknown = Enum.map(unknown_gaps, & &1["original_id"]) |> Enum.sort()
    true = observed_unknown == expected_unknown
    true = Enum.all?(unknown_gaps, &is_nil(&1["mfa"]))

    live_keys =
      for row <- record["identity_rows"],
          mfa <- row["live_mfas"],
          do: {row["identity"]["id"], mfa!(mfa)}

    live_key_set = MapSet.new(live_keys)
    live_source_gaps = Enum.filter(source_gaps, &(phase4_mfa_key!(&1) in live_key_set))
    live_caller_gaps = Enum.filter(caller_gaps, &(phase4_mfa_key!(&1) in live_key_set))
    live_source_gap_by_key = Map.new(live_source_gaps, &{phase4_mfa_key!(&1), &1})
    live_caller_gap_by_key = Map.new(live_caller_gaps, &{phase4_mfa_key!(&1), &1})

    source_gaps_for_targets =
      Enum.map(live_source_gaps, &normalize_phase4_gap!/1)
      |> Enum.sort_by(& &1["key"])

    source_associations =
      Enum.map(live_keys, fn {identity_id, mfa} = key ->
        gap = Map.fetch!(live_source_gap_by_key, key)

        %{
          "identity_id" => identity_id,
          "mfa" => mfa,
          "status" => "source_gap",
          "gap_key" => gap["gap_key"]
        }
      end)
      |> Kernel.++(
        for row <- record["identity_rows"],
            row["live_mfas"] == [],
            do: %{
              "identity_id" => row["identity"]["id"],
              "mfa" => nil,
              "status" => "not_applicable",
              "targets" => []
            }
      )
      |> Enum.sort_by(&{&1["identity_id"], &1["mfa"]})

    caller_records =
      Enum.map(live_keys, fn {identity_id, mfa} = key ->
        gap = Map.fetch!(live_caller_gap_by_key, key) |> normalize_phase4_gap!()

        %{
          "identity_id" => identity_id,
          "mfa" => mfa,
          "status" => "unresolved_phase4_evidence",
          "observed_incoming_edges" => [],
          "observed_outgoing_edges" => [],
          "delegate_paths" => [],
          "finding_refs" => [],
          "dynamic_boundary" => "unproven",
          "gap_keys" => [gap["key"]],
          "gaps" => [gap]
        }
      end)
      |> Enum.sort_by(&{&1["identity_id"], &1["mfa"]})

    caller_required_gaps = Enum.map(live_caller_gaps, &normalize_phase4_gap!/1)

    effective =
      record
      |> Map.put("record_partition_complete", true)
      |> Map.put("phase4_supplement", phase4_supplement_summary!(supplement))
      |> Map.put("phase4_unknown_target_sets", expected_unknown)
      |> Map.put("target_source_records", [])
      |> Map.put("target_source_associations", source_associations)
      |> Map.put("target_source_gaps", source_gaps_for_targets)
      |> Map.put("source_join_complete", source_gaps_for_targets == [])
      |> Map.put("target_source_coverage_complete", source_gaps_for_targets == [])
      |> Map.put("static_caller_evidence", %{
        "schema" => "guard-aggregate-static-caller-evidence/1",
        "lane" => lane,
        "graph_observation" => %{
          "path" => proof["trace_path"],
          "sha256" => proof["trace_sha256"],
          "scope" => "Phase 4 keyed gaps; current graph completeness remains unproven"
        },
        "edges" => [],
        "source_records" => [],
        "records" => caller_records,
        "required_evidence_gaps" => caller_required_gaps,
        "complete" => false,
        "recommendation_gate" => false
      })
      |> Map.put("required_evidence_gaps", caller_required_gaps)
      |> Map.put("caller_closure_complete", caller_required_gaps == [])

    :ok = validate_aggregate_lane!(effective)
    :ok = validate_target_sources!(effective)
    :ok = validate_static_callers!(effective)
    effective
  end

  defp validate_phase4_header!(record, supplement) do
    true = supplement["schema"] == "fablebook.phase4.keyed-evidence-supplement/1"
    true = supplement["status"] == "pass_with_open_gaps"
    true = supplement["source_access"] == "closed"
    true = supplement["record_partition_complete"] == true
    true = supplement["source_resolution"] == "unresolved"
    true = supplement["caller_closure"] == "incomplete"
    true = supplement["legacy_digest"] == "unresolved"
    true = is_nil(supplement["candidate"])
    true = supplement["implementation_authorized"] == false
    true = supplement["independent_review"] == "pass"
    proof = Map.fetch!(supplement, "proof")
    manifest = validate_phase4_artifact_proof!(proof, supplement)
    lane = record["lane"]
    true = lane in ["core", "floor"]
    true = is_list(supplement["source_associations"])
    true = supplement["source_associations"] == []
    true = is_list(supplement["typed_gaps"])
    true = is_map(supplement["unknown_target_sets"])

    {lane, proof, manifest}
  end

  defp validate_phase4_artifact_proof!(proof, supplement) do
    Enum.each(@phase4_artifacts, fn {field, filename} ->
      true = proof[field] == phase4_file_sha256!(filename)
    end)

    trace_path = Path.join(@phase4_dir, @phase4_artifacts["trace_sha256"])
    true = proof["trace_path"] == trace_path

    manifest = phase4_json!(@phase4_artifacts["manifest_sha256"])
    validation = phase4_json!(@phase4_artifacts["validation_sha256"])
    review = phase4_json!(@phase4_artifacts["review_sha256"])
    trace = phase4_json!(@phase4_artifacts["trace_sha256"])
    digest_proof = phase4_json!(@phase4_artifacts["digest_proof_sha256"])
    digest_supplement = Map.fetch!(digest_proof, "supplement")
    canonical_payload = Map.fetch!(digest_supplement, "canonical_payload")

    true = manifest["generation"] == supplement["generation"]
    true = validation["generation"] == supplement["generation"]
    true = validation["validation_passed"] == true
    true = validation["full_package_valid"] == true
    true = review["status"] == "pass"
    true = review["subject"]["generation"] == supplement["generation"]
    true = review["subject"]["manifest"]["sha256"] == proof["manifest_sha256"]
    true = valid_sha256?(review["subject_sha256"])
    true = trace["generation"] == supplement["generation"]
    true = digest_proof["generation"] == supplement["generation"]
    true = digest_proof["source_access"] == "closed"
    true = digest_supplement["status"] == "verified_integrity_only"
    true = canonical_payload["generation"] == supplement["generation"]
    true = canonical_payload["schema"] == "fablebook.phase4.sizing-integrity-supplement/1"
    true = proof["supplement_digest"] == digest_supplement["digest"]
    true = canonical_json_sha256!(canonical_payload) == digest_supplement["digest"]
    true = byte_size(canonical_json!(canonical_payload)) == digest_supplement["serialized_bytes"]

    producer_identity =
      canonical_payload
      |> Map.fetch!("selector")
      |> Map.fetch!("helper_source_identity")

    true = supplement["producer_helper_source_identity"] == producer_identity

    :ok =
      validate_phase4_producer_identity!(
        producer_identity,
        Map.put(manifest, "trace", trace),
        supplement["generation"]
      )

    :ok = validate_phase4_lane_records!(manifest)

    manifest
  end

  defp validate_phase4_producer_identity!(producer_identity, manifest, generation) do
    path = "test/support/guard_aggregate_reconciliation_evidence.ex"
    historical_sha256 = "75d23e5b48d17c632fd42c3d052aea7b1f25531ca359d897fc40ae577f61bbd6"

    true = producer_identity["path"] == path
    true = producer_identity["sha256"] == historical_sha256
    true = producer_identity["bytes"] == 58_839
    true = valid_sha256?(producer_identity["sha256"])
    true = is_integer(producer_identity["bytes"]) and producer_identity["bytes"] > 0

    [manifest_input] =
      Enum.filter(manifest["inputs"], &(&1["path"] == path))

    true = valid_sha256?(manifest_input["sha256"])
    true = is_integer(manifest_input["bytes"]) and manifest_input["bytes"] > 0
    current_bytes = File.read!(phase4_root_path!(path))
    current_sha256 = sha256_bytes(current_bytes)
    current_byte_count = byte_size(current_bytes)
    true = manifest["historical_producer_identity"] == producer_identity

    revision = phase3_json!("03-05-T2-POST-R8-HELPER-REVISION.json")
    previous_helper = Map.fetch!(revision, "previous_helper_identity")
    current_helper = Map.fetch!(revision, "current_helper_identity")
    true = revision["schema_version"] == "03-05.post-r8-helper-revision/1"
    true = revision["status"] == "verified"
    true = revision["request_id"] == "R8"
    true = previous_helper["path"] == path
    true = current_helper["path"] == path
    true = manifest_input["role"] == "live_helper_post_observation_revision"
    true = current_helper["sha256"] == manifest_input["sha256"]
    true = current_helper["bytes"] == manifest_input["bytes"]

    manifest_revision = Map.fetch!(manifest_input, "post_observation_revision")

    revision_path =
      ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-T2-POST-R8-HELPER-REVISION.json"

    true = manifest_revision["path"] == revision_path

    true =
      manifest_revision["sha256"] == phase3_file_sha256!("03-05-T2-POST-R8-HELPER-REVISION.json")

    true = manifest_revision["request_id"] == "R8"
    previous_observation = Map.fetch!(manifest_revision, "previous_observation")
    true = previous_observation["sha256"] == previous_helper["sha256"]
    true = previous_observation["bytes"] == previous_helper["bytes"]
    live_identity = Map.fetch!(manifest_revision, "current_identity")
    true = live_identity["sha256"] == current_helper["sha256"]
    true = live_identity["bytes"] == current_helper["bytes"]
    true = current_helper["sha256"] == current_sha256
    true = current_helper["bytes"] == current_byte_count
    true = revision["source_schedule_sha256"] == phase4_file_sha256!("04-R8-SCHEDULE.json")

    true =
      revision["failure_receipt_sha256"] ==
        phase3_file_sha256!("03-05-CORE-FOCUSED-R8-FAILURE.json")

    true =
      revision["followup_failure_receipt_sha256"] ==
        phase3_file_sha256!("03-05-CORE-FOCUSED-R8-RETEST-FAILURE.json")

    true =
      revision["followup_failure_receipt_path"] ==
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-CORE-FOCUSED-R8-RETEST-FAILURE.json"

    true =
      revision["additional_failure_receipt_sha256"] ==
        phase3_file_sha256!("03-05-CORE-FOCUSED-R8-RETEST-FAILURE-02.json")

    true =
      revision["additional_failure_receipt_path"] ==
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-CORE-FOCUSED-R8-RETEST-FAILURE-02.json"

    prior_failure = phase3_json!("03-05-CORE-FOCUSED-R8-RETEST-FAILURE-02.json")
    previous_revision = Map.fetch!(revision, "previous_revision_identity")

    true =
      previous_revision ==
        prior_failure["inputs"]["test/support/guard_aggregate_reconciliation_evidence.ex"]

    manifest_mismatch = Map.fetch!(manifest, "generator_revision_mismatch")
    trace_mismatch = manifest["trace"] |> Map.fetch!("generator_revision_mismatch")
    true = manifest_mismatch["status"] == "unresolved"
    true = trace_mismatch["status"] == "unresolved"
    true = manifest_mismatch["claim_scope"] == "current-helper identity only"
    true = trace_mismatch["claim_scope"] == "current-helper identity only"

    current_observation = Map.fetch!(manifest_mismatch, "current_request_observation")

    true =
      current_observation == Map.fetch!(trace_mismatch, "current_request_observation")

    true = current_observation["status"] == "consumed_verified"
    request_id = Map.fetch!(current_observation, "request_id")
    true = request_id == "R8"
    true = current_observation["path"] == manifest_input["path"]
    true = current_observation["sha256"] == previous_helper["sha256"]
    true = current_observation["bytes"] == previous_helper["bytes"]

    Enum.each(["R2", "R3"], fn historical_request_id ->
      schedule = phase4_json!("04-#{historical_request_id}-SCHEDULE.json")
      request = Map.fetch!(schedule, "request")
      span = Map.fetch!(request, "source_span")
      true = schedule["generation"] == generation
      true = request["candidate_path"] == path
      true = request["source_sha256"] == historical_sha256

      expected_span =
        case historical_request_id do
          "R2" ->
            %{
              "start_line" => 521,
              "end_line" => 1113,
              "start_byte" => 19_368,
              "end_byte_exclusive" => 41_762,
              "encoding" => "UTF-8",
              "complete_file" => false,
              "includes_final_newline" => true,
              "span_sha256" => "a1440abd808ba06ee624cb97a780e022abd20ec76f9f972fa2e1c078d523ab89"
            }

          "R3" ->
            %{
              "start_line" => 1114,
              "end_line" => 1497,
              "start_byte" => 41_762,
              "end_byte_exclusive" => 54_843,
              "encoding" => "UTF-8",
              "complete_file" => false,
              "includes_final_newline" => true,
              "span_sha256" => "8256f4866d59d66300950c641fefafe2c1ad9f7384ff39ab19add1ea05df75df"
            }
        end

      true = span == expected_span
      true = request["source_bytes"] == span["end_byte_exclusive"] - span["start_byte"]
    end)

    current_schedule = phase4_json!("04-R8-SCHEDULE.json")
    current_request = Map.fetch!(current_schedule, "request")
    current_span = Map.fetch!(current_request, "source_span")
    true = current_schedule["generation"] == generation
    true = current_request["request_id"] == "R8"
    true = current_request["candidate_path"] == manifest_input["path"]
    true = current_request["source_sha256"] == current_observation["sha256"]
    true = current_request["source_file_bytes"] == current_observation["bytes"]
    true = current_request["source_file_bytes"] == previous_helper["bytes"]
    true = current_observation["source_span"] == current_span
    true = revision["source_span"] == current_span
    true = current_span["complete_file"] == false
    true = is_integer(current_span["start_byte"]) and current_span["start_byte"] >= 0

    true =
      is_integer(current_span["end_byte_exclusive"]) and
        current_span["end_byte_exclusive"] > current_span["start_byte"]

    true = current_span["end_byte_exclusive"] <= previous_helper["bytes"]
    true = current_span["end_line"] <= current_request["source_file_lines"]

    true =
      current_request["source_bytes"] ==
        current_span["end_byte_exclusive"] - current_span["start_byte"]

    true = valid_sha256?(current_span["span_sha256"])
    true = current_span["encoding"] == "UTF-8"
    true = current_span["includes_final_newline"] == true
    start_line = current_span["start_line"]
    end_line = current_span["end_line"]
    true = is_integer(start_line) and start_line >= 1
    true = is_integer(end_line) and end_line >= start_line

    true = current_request["source_file_lines"] > 0

    :ok
  end

  defp validate_phase4_lane_records!(manifest) do
    Enum.each(@lane_record_paths, fn {lane, path} ->
      binding = manifest["lanes"][lane]["record"]
      true = binding["path"] == path
      true = binding["sha256"] == phase4_root_file_sha256!(path)
    end)

    :ok
  end

  defp validate_phase4_gap_bindings!(gaps, record, supplement, manifest) do
    lane = record["lane"]
    lane_record = manifest["lanes"][lane]["record"]
    expected_path = @lane_record_paths[lane]
    expected_sha256 = lane_record["sha256"]

    identity_pointers =
      record["identity_rows"]
      |> Enum.with_index()
      |> Map.new(fn {row, index} -> {row["identity"]["id"], "/identity_rows/#{index}"} end)

    Enum.each(gaps, fn gap ->
      identity_pointer = Map.fetch!(identity_pointers, gap["original_id"])
      true = gap["generation"] == supplement["generation"]
      true = gap["lane"] == lane
      true = gap["input_file"] == expected_path
      true = gap["input_sha256"] == expected_sha256

      expected_pointer =
        case gap["domain"] do
          "unknown_target_set" -> identity_pointer <> "/baseline_mfas"
          domain when domain in ["source", "caller"] -> identity_pointer
        end

      true = gap["input_pointer"] == expected_pointer
    end)

    :ok
  end

  defp phase4_json!(filename) do
    Path.join(@phase4_dir, filename)
    |> phase4_root_path!()
    |> File.read!()
    |> Jason.decode!()
  end

  defp phase3_json!(filename) do
    Path.join(@phase3_recovery_dir, filename)
    |> phase4_root_path!()
    |> File.read!()
    |> Jason.decode!()
  end

  defp phase3_file_sha256!(filename) do
    filename
    |> then(&Path.join(@phase3_recovery_dir, &1))
    |> phase4_root_path!()
    |> File.read!()
    |> sha256_bytes()
  end

  defp phase4_file_sha256!(filename) do
    filename
    |> then(&Path.join(@phase4_dir, &1))
    |> phase4_root_path!()
    |> File.read!()
    |> sha256_bytes()
  end

  defp phase4_root_file_sha256!(relative_path) do
    relative_path
    |> phase4_root_path!()
    |> File.read!()
    |> sha256_bytes()
  end

  defp phase4_root_path!(relative_path) do
    true = is_binary(relative_path) and Path.type(relative_path) == :relative
    path = Path.expand(relative_path, File.cwd!())
    true = String.starts_with?(path, File.cwd!() <> "/")

    path
    |> resolve_legacy_evidence_path(@phase3_recovery_dir, &phase3_evidence_dir!/0)
    |> resolve_legacy_evidence_path(@phase4_dir, &phase4_evidence_dir!/0)
  end

  defp existing_evidence_dir!(label, archived, legacy, required_files) do
    archived_path = Path.expand(archived, File.cwd!())
    legacy_path = Path.expand(legacy, File.cwd!())

    cond do
      complete_evidence_dir?(archived_path, required_files) -> archived_path
      complete_evidence_dir?(legacy_path, required_files) -> legacy_path
      true -> raise ArgumentError, "Missing complete #{label} evidence under either path"
    end
  end

  defp complete_evidence_dir?(directory, required_files) do
    File.dir?(directory) and
      Enum.all?(required_files, &File.regular?(Path.join(directory, &1)))
  end

  defp resolve_legacy_evidence_path(path, legacy, resolver) do
    legacy_root = Path.expand(legacy, File.cwd!())
    prefix = legacy_root <> "/"

    if String.starts_with?(path, prefix) do
      suffix = Path.relative_to(path, legacy_root)
      Path.join(resolver.(), suffix)
    else
      path
    end
  end

  defp sha256_bytes(bytes) do
    :crypto.hash(:sha256, bytes) |> Base.encode16(case: :lower)
  end

  defp valid_sha256?(value) do
    is_binary(value) and Regex.match?(~r/\A[0-9a-f]{64}\z/, value)
  end

  defp canonical_json_sha256!(value) do
    value |> canonical_json!() |> sha256_bytes()
  end

  defp canonical_json!(value) when is_map(value) do
    entries =
      value
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map_join(",", fn {key, nested} ->
        Jason.encode!(key) <> ":" <> canonical_json!(nested)
      end)

    "{" <> entries <> "}"
  end

  defp canonical_json!(value) when is_list(value) do
    "[" <> Enum.map_join(value, ",", &canonical_json!/1) <> "]"
  end

  defp canonical_json!(value), do: Jason.encode!(value)

  defp phase4_mfa_key!(gap) do
    {Map.fetch!(gap, "original_id"), mfa!(Map.fetch!(gap, "mfa"))}
  end

  defp normalize_phase4_gap!(gap) do
    %{
      "key" => Map.fetch!(gap, "gap_key"),
      "identity_id" => Map.fetch!(gap, "original_id"),
      "lane" => Map.fetch!(gap, "lane"),
      "mfa" => mfa!(Map.fetch!(gap, "mfa")),
      "reason" => Map.fetch!(gap, "reason"),
      "remedy" => Map.fetch!(gap, "remedy"),
      "evidence_status" => Map.fetch!(gap, "evidence_status"),
      "phase4_reference" => %{
        "input_file" => Map.fetch!(gap, "input_file"),
        "input_pointer" => Map.fetch!(gap, "input_pointer"),
        "input_sha256" => Map.fetch!(gap, "input_sha256"),
        "typed_gap_line" => Map.get(gap, "phase4_line"),
        "independent_review" => Map.get(gap, "independent_review")
      }
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

  defp validate_inventory_membership!(row, exported_mfas) do
    exported_set = MapSet.new(exported_mfas)

    for field <- ["original_live_mfas", "live_mfas", "replacement_live_mfas"] do
      true = MapSet.subset?(MapSet.new(row[field]), exported_set)
    end

    :ok
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
    lane = record["lane"]
    evidence = record["source_and_caller_evidence"]
    path_module = Enum.at(mfa, 0)

    selected =
      Enum.find(evidence["selected_function_evidence"], fn item ->
        item["mfa"] == mfa
      end)

    candidates =
      evidence["exact_sources"]
      |> Enum.filter(&target_source_filename?(&1, path_module))

    case verified_source_candidate!(selected, candidates, evidence, lane, archive_files) do
      {:ok, source} ->
        target_source_record!(record, archive_sha256, lane, source)

      {:gap, reason} ->
        target_source_gap!(record, identity_id, mfa, path_module, archive_sha256, reason)
    end
  end

  defp target_source_filename?([path, _bytes, _sha256], path_module),
    do: Path.basename(path) in ["#{path_module}.erl", "#{path_module}.ex"]

  defp target_source_filename?(_source, _path_module), do: false

  defp verified_source_candidate!(nil, _candidates, _evidence, _lane, _archive_files),
    do: {:gap, "source_mapping_not_present_in_scoped_findings"}

  defp verified_source_candidate!(_selected, candidates, _evidence, _lane, _archive_files)
       when length(candidates) != 1,
       do: {:gap, "source_mapping_ambiguous_or_missing"}

  defp verified_source_candidate!(selected, [source], evidence, lane, archive_files) do
    [path, bytes, source_sha] = source
    source_review = Enum.find(evidence["reviews"], &(&1["source_path"] == path))
    cited? = Enum.any?(selected["citations"], &(citation_path(&1) == path))

    archive_rows =
      Enum.filter(archive_files, fn row ->
        row["lane"] == lane and row["source_path"] == path and
          row["sha256"] == source_sha and archive_bytes(row) == bytes
      end)

    if source_review && cited? && source_review["bytes"] == bytes &&
         source_review["sha256"] == source_sha && length(archive_rows) == 1 do
      [archive_row] = archive_rows
      {:ok, {path, bytes, source_sha, archive_row, selected}}
    else
      {:gap, "archive_or_citation_mismatch"}
    end
  end

  defp target_source_record!(
         record,
         archive_sha256,
         lane,
         {path, bytes, source_sha, archive_row, selected}
       ) do
    repository_ref =
      archive_row["repository_ref"] || archive_row["repo_ref"] || archive_row["ref"] ||
        "locked-archive:#{archive_sha256}"

    identity = %{
      "lane" => lane,
      "repository_ref" => repository_ref,
      "lock_sha256" => record["lock_sha256"],
      "archive_sha256" => archive_sha256,
      "relative_path" => path,
      "bytes" => bytes,
      "sha256" => source_sha
    }

    {:ok,
     Map.merge(identity, %{
       "key" => "source:" <> digest(identity),
       "status" => "source_identity_verified_by_locked_archive",
       "evidence_status" => "cited_static_evidence",
       "citations" => Enum.filter(selected["citations"], &(citation_path(&1) == path))
     })}
  end

  defp target_source_gap!(record, identity_id, mfa, path_module, archive_sha256, reason) do
    lane = record["lane"]

    {:gap,
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
     }}
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
