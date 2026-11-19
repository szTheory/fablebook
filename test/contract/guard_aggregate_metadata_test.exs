defmodule Fablebook.Contract.GuardAggregateMetadataTest do
  use ExUnit.Case, async: true

  alias Fablebook.Test.GuardAggregateReconciliationEvidence

  @tag :guard_aggregate_reconciliation
  @tag :guard_aggregate_reconciliation_bundle
  @tag :guard_aggregate_reconciliation_metadata
  test "lane membership binds to the exact metadata-only source and caller gaps" do
    directory = GuardAggregateReconciliationEvidence.phase3_evidence_dir!()

    read_json = fn name ->
      path = Path.join(directory, name)
      {File.read!(path), path}
    end

    core_bytes = directory |> Path.join("03-CORE-AGGREGATE-EVIDENCE.json") |> File.read!()
    floor_bytes = directory |> Path.join("03-FLOOR-AGGREGATE-EVIDENCE.json") |> File.read!()
    core = Jason.decode!(core_bytes)
    floor = Jason.decode!(floor_bytes)
    lanes = %{"core" => core, "floor" => floor}
    sizing = directory |> Path.join("03-SIZING.json") |> File.read!() |> Jason.decode!()
    {receipt_bytes, _} = read_json.("03-04-METADATA-GAP-RECEIPT.json")
    receipt = Jason.decode!(receipt_bytes)
    {validation_bytes, _} = read_json.("03-04-METADATA-GAP-VALIDATION.json")
    validation = Jason.decode!(validation_bytes)
    {index_bytes, index_path} = read_json.("03-04-METADATA-GAPS.jsonl")

    rows =
      index_path
      |> File.stream!()
      |> Enum.map(&Jason.decode!/1)

    known_rows = Enum.filter(rows, &(&1["record_type"] == "known_target_gap"))
    unknown_rows = Enum.filter(rows, &(&1["record_type"] == "unknown_target_set"))

    expected_known =
      for {lane, record} <- lanes,
          row <- record["identity_rows"],
          mfa <- row["baseline_mfas"],
          do: {lane, row["identity"]["id"], mfa}

    actual_known = Enum.map(known_rows, &{&1["lane"], &1["identity_id"], &1["mfa"]})

    expected_unknown =
      for {lane, record} <- lanes,
          row <- record["identity_rows"],
          row["baseline_mfas"] == [],
          do: {lane, row["identity"]["id"]}

    actual_unknown = Enum.map(unknown_rows, &{&1["lane"], &1["identity_id"]})

    assert length(rows) == 4_815
    assert Enum.all?(rows, &(&1["record_type"] in ["known_target_gap", "unknown_target_set"]))
    assert Enum.sort(actual_known) == Enum.sort(expected_known)
    assert Enum.sort(actual_unknown) == Enum.sort(expected_unknown)
    assert length(known_rows) == 4_797
    assert length(unknown_rows) == 18
    assert Enum.all?(known_rows, &(&1["mapping_status"] == "unresolved_mapping"))

    assert Enum.all?(known_rows, fn row ->
             Enum.sort(row["missing_fields"]) == ["caller_mapping", "source_mapping"]
           end)

    assert Enum.all?(unknown_rows, fn row ->
             row["target_set_status"] == "unknown" and row["mfa"] == nil and
               "target_mfa_list" in row["missing_fields"] and
               "source_mapping" in row["missing_fields"] and
               "caller_mapping" in row["missing_fields"]
           end)

    lane_hashes = %{
      "core" => :crypto.hash(:sha256, core_bytes) |> Base.encode16(case: :lower),
      "floor" => :crypto.hash(:sha256, floor_bytes) |> Base.encode16(case: :lower)
    }

    assert length(core["identity_rows"]) == 226
    assert length(floor["identity_rows"]) == 226

    assert Enum.sort(Enum.map(core["identity_rows"], & &1["identity"]["id"])) ==
             Enum.sort(Enum.map(floor["identity_rows"], & &1["identity"]["id"]))

    assert Enum.all?(rows, &(&1["lane_input_sha256"] == lane_hashes[&1["lane"]]))
    assert sizing["source_join_complete"] == false
    assert sizing["caller_closure_complete"] == false
    assert sizing["evidence_complete"] == false
    assert sizing["actual_library_collision"] == nil
    assert sizing["candidate"] == nil
    assert sizing["implementation_authorized"] == false
    assert core["source_join_complete"] == false
    assert floor["source_join_complete"] == false
    assert is_nil(core["target_source_coverage_complete"])
    assert is_nil(floor["target_source_coverage_complete"])

    assert receipt["gap_index"]["total_rows"] == 4_815

    assert receipt["gap_index"]["sha256"] ==
             :crypto.hash(:sha256, index_bytes) |> Base.encode16(case: :lower)

    assert receipt["gap_index"]["known_target_rows"] == 4_797
    assert receipt["gap_index"]["unknown_target_rows"] == 18
    assert receipt["inputs"]["core"]["sha256"] == lane_hashes["core"]
    assert receipt["inputs"]["floor"]["sha256"] == lane_hashes["floor"]

    assert validation["index_sha256"] ==
             :crypto.hash(:sha256, index_bytes) |> Base.encode16(case: :lower)

    receipt_sha256 = :crypto.hash(:sha256, receipt_bytes) |> Base.encode16(case: :lower)
    assert validation["receipt_sha256"] == receipt_sha256
    assert validation["artifact_sha256"]["03-04-METADATA-GAP-RECEIPT.json"] == receipt_sha256
    assert validation["status"] == "pass_metadata_only"

    assert validation["checks"] == %{
             "row_schema" => true,
             "complete_key_equality" => true,
             "unknown_target_sets" => true,
             "direct_evidence_bindings" => true,
             "preservation_hashes" => true,
             "unchanged_limits" => true
           }

    assert validation["preservation_manifest_unchanged"] == true
    assert validation["gsr03_complete"] == false
    assert validation["gsr05_complete"] == false
    assert validation["phase4_authorized"] == false
    assert validation["source_proof"] == false
    assert validation["caller_closure"] == false
    assert validation["result"]["candidate"] == nil
    assert validation["result"]["implementation_authorized"] == false
    assert validation["result"]["aggregate_gate"] == "open"
  end
end
