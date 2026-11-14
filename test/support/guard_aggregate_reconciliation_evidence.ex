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

    :ok = validate_lane!(record)
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

  def render_crosswalk!(core, floor) do
    :ok = validate_lane!(core)
    :ok = validate_lane!(floor)
    true = core["lane"] == "core" and floor["lane"] == "floor"
    true = core["generation"] == floor["generation"]
    true = core["input_sha256"] == floor["input_sha256"]
    true = core["identity"] == floor["identity"]
    true = core["delivery"] == floor["delivery"]

    %{
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
  end

  def check_bundle!(records, report) when is_list(records) and is_map(report) do
    [core, floor] = Enum.sort_by(records, & &1["lane"])
    expected = render_crosswalk!(core, floor)
    true = report == expected
    :ok
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
end
