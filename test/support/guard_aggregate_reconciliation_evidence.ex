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

          Enum.each(identity_rows, fn row ->
            for field <- ["original_live_mfas", "live_mfas", "replacement_live_mfas"] do
              true = MapSet.subset?(MapSet.new(row[field]), MapSet.new(exported_mfas))
            end
          end)

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
    true = record["source_join_complete"] == false
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
            "core" => Map.drop(core_row, ["identity", "delivered_slice_owner", "delivery_refs"]),
            "floor" => Map.drop(floor_row, ["identity", "delivered_slice_owner", "delivery_refs"])
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
  end

  def check_bundle!(records, report) when is_list(records) and is_map(report) do
    [core, floor] = Enum.sort_by(records, & &1["lane"])
    expected = render_crosswalk!(core, floor)
    true = report == expected
    :ok
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
end
