#!/usr/bin/env python3
"""Validate the bounded EX-177 supplement using only its explicit evidence allowlist."""

import argparse
import copy
import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
DISCOVERY = ".planning/research/2026-11-19-ex177-source-discovery.md"
PHASE5_SCOPE = ".planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-CONTEXT.md"
PHASE5_RESULT = ".planning/milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-R9-RESULT.json"
PHASE4_GAPS = ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-TYPED-GAPS-ENV06.jsonl"
PHASE4_MANIFEST = ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-PROVENANCE-MANIFEST.json"
PLANNING_GATES = ".planning/references/PLANNING-GATES.json"
SUPPLEMENT = ".planning/phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json"

INPUT_PATHS = frozenset(
    {
        DISCOVERY,
        PHASE5_SCOPE,
        PHASE5_RESULT,
        PHASE4_GAPS,
        PHASE4_MANIFEST,
        PLANNING_GATES,
        SUPPLEMENT,
    }
)

SELECTED_KEYS = (
    "core|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|source",
    "core|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|caller",
    "floor|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|source",
    "floor|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|caller",
)
MFA = ["Elixir.Mix.Tasks.Phx.Gen.Context", "prompt_for_code_injection", 1]
COMPLEMENT_COUNT = 9712
COMPLEMENT_SHA256 = "dd95380d2114a10a54ddbb79cc6ec5aab4805a52847dcacb4e2ca3daeda653b5"
SOURCE_PATH_VALUES = {
    "core": "_build/lanes/core/deps/phoenix/lib/mix/tasks/phx.gen.context.ex",
    "floor": "_build/lanes/floor/deps/phoenix/lib/mix/tasks/phx.gen.context.ex",
}
SOURCE_SHA256 = "c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e"
EXPECTED_LANES = {
    "core": {
        "runtime": {"elixir": "1.20.4", "otp": "29.1.2"},
        "phoenix": {"version": "1.8.16", "lock_file": "mix.lock"},
        "source": {
            "recorded_value": SOURCE_PATH_VALUES["core"],
            "bytes": 14760,
            "sha256": SOURCE_SHA256,
        },
        "helper_definition": {
            "module": MFA[0],
            "function": MFA[1],
            "arity": 1,
            "start_line": 445,
            "end_line": 451,
        },
        "observed_direct_call": {
            "caller_function": "run",
            "caller_arity": 1,
            "call_line": 131,
            "caller_start_line": 112,
            "caller_end_line": 136,
        },
    },
    "floor": {
        "runtime": {"elixir": "1.18.5", "otp": "27.3.4.9"},
        "phoenix": {"version": "1.8.9", "lock_file": "mix.floor.lock"},
        "source": {
            "recorded_value": SOURCE_PATH_VALUES["floor"],
            "bytes": 14760,
            "sha256": SOURCE_SHA256,
        },
        "helper_definition": {
            "module": MFA[0],
            "function": MFA[1],
            "arity": 1,
            "start_line": 445,
            "end_line": 451,
        },
        "observed_direct_call": {
            "caller_function": "run",
            "caller_arity": 1,
            "call_line": 131,
            "caller_start_line": 112,
            "caller_end_line": 136,
        },
    },
}
EXPECTED_STOPS = {
    "candidate_fit": "unresolved",
    "candidate": None,
    "aggregate_gate": "open",
    "r9": {
        "id": "R9",
        "authorization": "denied",
        "one_use_gate_validation": "valid_denial",
        "consumption": "not_consumed",
    },
    "walking_skeleton": "blocked",
    "sec_01": "Pending",
    "actual_library_collision": "unknown",
    "macro_caller_ast": "unresolved",
    "macro_explanation": "unresolved",
    "legacy_digest": "unresolved",
    "automatic_followup": False,
}
EXPECTED_PROVENANCE = {
    "reviewed_discovery": DISCOVERY,
    "archived_phase5_scope": PHASE5_SCOPE,
    "archived_phase5_result": PHASE5_RESULT,
    "phase4_keyed_gaps": PHASE4_GAPS,
    "phase4_lane_manifest": PHASE4_MANIFEST,
    "planning_gates": PLANNING_GATES,
}
EXPECTED_TOP_LEVEL_KEYS = {
    "schema",
    "phase",
    "requirement",
    "source_boundary",
    "provenance",
    "selected_keys",
    "lanes",
    "observations",
    "complement",
    "caller_closure",
    "preserved_stops",
}
EXPECTED_SOURCE_BOUNDARY = {
    "recorded_source_paths_are_values_only": True,
    "claim": "The Phoenix source paths below are provenance values only. The checker never uses them as filesystem targets.",
}
EXPECTED_COMPLEMENT = {
    "path": PHASE4_GAPS,
    "predicate": "All archived raw JSONL rows whose gap_key is outside selected_keys.",
    "rows": COMPLEMENT_COUNT,
    "digest_algorithm": "SHA-256 over concatenated raw line bytes",
    "sha256": COMPLEMENT_SHA256,
}
EXPECTED_CALLER_CLOSURE = {
    "observed_direct_calls_per_lane": 1,
    "exhaustive": False,
    "statement": (
        "One observed direct run/1 call per lane does not establish exhaustive caller closure; "
        "external callers, dynamic edges, callbacks, and delegates remain open."
    ),
}


def read_input(relative_path):
    if relative_path not in INPUT_PATHS:
        raise ValueError("unapproved evidence input: " + str(relative_path))
    return (ROOT / relative_path).read_bytes()


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON object key: " + key)
        result[key] = value
    return result


def parse_json(raw, label):
    try:
        return json.loads(raw.decode("utf-8"), object_pairs_hook=unique_object)
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError(label + " is not valid UTF-8 JSON: " + str(error)) from error


def parse_jsonl(raw, label):
    rows = []
    for line_number, raw_line in enumerate(raw.splitlines(keepends=True), 1):
        if not raw_line.strip():
            raise ValueError(label + " has a blank line at " + str(line_number))
        try:
            row = json.loads(raw_line.decode("utf-8"), object_pairs_hook=unique_object)
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            raise ValueError(label + " has invalid JSON at line " + str(line_number) + ": " + str(error)) from error
        rows.append((raw_line, row))
    return rows


def exact_equal(expected, observed):
    if type(expected) is not type(observed):
        return False
    if isinstance(expected, dict):
        return (
            expected.keys() == observed.keys()
            and all(exact_equal(expected[key], observed[key]) for key in expected)
        )
    if isinstance(expected, list):
        return len(expected) == len(observed) and all(
            exact_equal(left, right) for left, right in zip(expected, observed)
        )
    return expected == observed


def expect(field, observed, expected):
    if not exact_equal(expected, observed):
        raise ValueError(field + " mismatch: expected " + repr(expected) + "; observed " + repr(observed))


def expected_observation(key):
    lane, _identity, module, function, arity, domain = key.split("|")
    return {
        "key": key,
        "lane": lane,
        "domain": domain,
        "mfa": [module, function, int(arity)],
        "evidence_refs": [
            {"path": DISCOVERY, "section": "Lane and source identity; Observed spans"},
            {"path": PHASE5_SCOPE, "section": "Phase Boundary; D-01 through D-04"},
            {"path": PHASE5_RESULT, "field": "selected_gap_keys"},
            {"path": PHASE4_GAPS, "selector": "gap_key=" + key},
        ],
    }


def load_evidence():
    if set(SOURCE_PATH_VALUES.values()) & INPUT_PATHS:
        raise ValueError("recorded Phoenix source path entered the evidence allowlist")

    discovery = read_input(DISCOVERY).decode("utf-8")
    phase5_scope = read_input(PHASE5_SCOPE).decode("utf-8")
    phase5_result = parse_json(read_input(PHASE5_RESULT), PHASE5_RESULT)
    gap_bytes = read_input(PHASE4_GAPS)
    gap_rows = parse_jsonl(gap_bytes, PHASE4_GAPS)
    manifest = parse_json(read_input(PHASE4_MANIFEST), PHASE4_MANIFEST)
    planning_gates = parse_json(read_input(PLANNING_GATES), PLANNING_GATES)

    selected = {}
    complement_lines = []
    for raw_line, row in gap_rows:
        key = row.get("gap_key")
        if key in SELECTED_KEYS:
            if key in selected:
                raise ValueError("duplicate selected gap key in archived JSONL: " + key)
            selected[key] = row
        else:
            complement_lines.append(raw_line)

    if set(selected) != set(SELECTED_KEYS):
        raise ValueError(
            "archived JSONL selected keys mismatch: expected "
            + repr(list(SELECTED_KEYS))
            + "; observed "
            + repr(sorted(selected))
        )
    for key in SELECTED_KEYS:
        lane, _identity, module, function, _arity, domain = key.split("|")
        row = selected[key]
        expect(key + ".lane", row.get("lane"), lane)
        expect(key + ".domain", row.get("domain"), domain)
        expect(key + ".mfa", row.get("mfa"), [module, function, 1])
        expect(key + ".schema_version", row.get("schema_version"), "04.typed-gap.1")
        expect(key + ".original_id", row.get("original_id"), "EX-177")
        expect(
            key + ".runtime",
            row.get("runtime"),
            {
                "elixir": EXPECTED_LANES[lane]["runtime"]["elixir"],
                "otp": EXPECTED_LANES[lane]["runtime"]["otp"].split(".")[0],
            },
        )

    complement_digest = hashlib.sha256(b"".join(complement_lines)).hexdigest()
    if len(gap_rows) != 9716:
        raise ValueError("archived JSONL row count mismatch: expected 9716; observed " + str(len(gap_rows)))
    if len(complement_lines) != COMPLEMENT_COUNT:
        raise ValueError(
            "complement row count mismatch: expected "
            + str(COMPLEMENT_COUNT)
            + "; observed "
            + str(len(complement_lines))
        )
    expect("complement.sha256", complement_digest, COMPLEMENT_SHA256)

    expected_discovery_fragments = (
        "Elixir 1.20.4 / OTP 29.1.2",
        "Phoenix 1.8.16 from",
        "mix.lock",
        SOURCE_PATH_VALUES["core"],
        "Elixir 1.18.5 / OTP 27.3.4.9",
        "Phoenix 1.8.9 from",
        "mix.floor.lock",
        SOURCE_PATH_VALUES["floor"],
        "14,760",
        SOURCE_SHA256,
        "lines 445–451",
        "line 131",
        "lines 112–136",
        "does not prove that every direct caller is known",
    )
    for fragment in expected_discovery_fragments:
        if fragment not in discovery:
            raise ValueError("reviewed discovery is missing expected fact: " + fragment)

    for fragment in (
        "selected scope is exactly four current typed-gap rows",
        "other 9,712 rows remain the pending complement",
        "candidate null",
        "aggregate open",
        "Walking Skeleton blocked",
        "SEC-01 Pending",
        "actual collision unknown",
        "Macro caller-AST/explanation checkpoints unresolved",
        "legacy nested SIZING digest remains unresolved",
    ):
        if fragment not in phase5_scope:
            raise ValueError("archived Phase 5 scope is missing expected fact: " + fragment)

    expect("phase5_result.schema_version", phase5_result.get("schema_version"), "05.r9.result.1")
    expect("phase5_result.selected_gap_keys", phase5_result.get("selected_gap_keys"), list(SELECTED_KEYS))
    expect(
        "phase5_result.complement",
        phase5_result.get("complement"),
        {"count": COMPLEMENT_COUNT, "sha256": COMPLEMENT_SHA256},
    )
    for key, expected in (
        ("candidate_fit", None),
        ("candidate", None),
        ("aggregate_gate", "open"),
        ("implementation_authorized", False),
        ("actual_library_collision", "unknown"),
        ("one_use_gate_validation", "valid_denial"),
        ("request_consumption", "not_consumed"),
        ("request_id", "R9"),
        ("sec_01", "Pending"),
        ("macro_caller_ast", "unresolved"),
        ("macro_explanation", "unresolved"),
        ("legacy_digest", "unresolved"),
        ("walking_skeleton", "blocked"),
    ):
        expect("phase5_result." + key, phase5_result.get(key), expected)

    for lane, expected in EXPECTED_LANES.items():
        archive_runtime = manifest.get("lanes", {}).get(lane, {}).get("archive_fields", {}).get("runtime")
        expect(
            "phase4_manifest." + lane + ".archive_runtime",
            archive_runtime,
            {
                "elixir": expected["runtime"]["elixir"],
                "name": lane,
                "otp": expected["runtime"]["otp"],
            },
        )

    gates = planning_gates.get("gates")
    if not isinstance(gates, list):
        raise ValueError("planning_gates.gates is not a list")
    aggregate = [gate for gate in gates if isinstance(gate, dict) and gate.get("id") == "guard-aggregate"]
    if len(aggregate) != 1:
        raise ValueError("planning_gates must contain exactly one guard-aggregate gate")
    expect("planning_gates.automatic_followup", planning_gates.get("automatic_followup"), False)
    expect("planning_gates.guard_aggregate.status", aggregate[0].get("status"), "open")
    if "walking-skeleton" not in aggregate[0].get("blocks_milestones", []):
        raise ValueError("planning_gates.guard_aggregate does not keep walking-skeleton blocked")

    return {
        "discovery": discovery,
        "phase5_scope": phase5_scope,
        "phase5_result": phase5_result,
        "selected_rows": selected,
        "complement_count": len(complement_lines),
        "complement_sha256": complement_digest,
        "manifest": manifest,
        "planning_gates": planning_gates,
    }


def read_record():
    return parse_json(read_input(SUPPLEMENT), SUPPLEMENT)


def validate_record(record, evidence):
    if not isinstance(record, dict):
        raise ValueError("supplement root must be an object")
    expect("supplement keys", set(record), EXPECTED_TOP_LEVEL_KEYS)
    expect("schema", record.get("schema"), "fablebook.ex177-provenance-supplement/1")
    expect("phase", record.get("phase"), "06")
    expect("requirement", record.get("requirement"), "GSR-07")
    expect("source_boundary", record.get("source_boundary"), EXPECTED_SOURCE_BOUNDARY)
    expect("provenance", record.get("provenance"), EXPECTED_PROVENANCE)
    expect("selected_keys", record.get("selected_keys"), list(SELECTED_KEYS))
    expect("lanes", record.get("lanes"), EXPECTED_LANES)

    observations = record.get("observations")
    if not isinstance(observations, list):
        raise ValueError("observations must be a list")
    keys = [item.get("key") if isinstance(item, dict) else None for item in observations]
    expect("observation keys", keys, list(SELECTED_KEYS))
    expect(
        "observations",
        observations,
        [expected_observation(key) for key in SELECTED_KEYS],
    )
    expect("complement", record.get("complement"), EXPECTED_COMPLEMENT)
    expect("caller_closure", record.get("caller_closure"), EXPECTED_CALLER_CLOSURE)
    expect("preserved_stops", record.get("preserved_stops"), EXPECTED_STOPS)
    expect("evidence.complement_count", evidence["complement_count"], COMPLEMENT_COUNT)
    expect("evidence.complement_sha256", evidence["complement_sha256"], COMPLEMENT_SHA256)


def self_test():
    evidence = load_evidence()
    baseline = read_record()
    validate_record(baseline, evidence)
    checks = 1

    def rejects(label, mutation):
        nonlocal checks
        candidate = copy.deepcopy(baseline)
        mutation(candidate)
        try:
            validate_record(candidate, evidence)
        except (KeyError, TypeError, ValueError):
            checks += 1
            return
        raise AssertionError(label + " unexpectedly passed")

    rejects("missing key", lambda record: record["observations"].pop())
    rejects(
        "extra key",
        lambda record: record["observations"].append(
            {"key": "core|EX-177|extra|extra|1|source"}
        ),
    )
    rejects(
        "wrong lane",
        lambda record: record["observations"][0].update({"lane": "floor"}),
    )
    rejects(
        "changed source fact",
        lambda record: record["lanes"]["core"]["source"].update({"bytes": 14761}),
    )
    rejects(
        "changed citation",
        lambda record: record["observations"][0]["evidence_refs"].pop(1),
    )
    rejects(
        "complement count drift",
        lambda record: record["complement"].update({"rows": COMPLEMENT_COUNT + 1}),
    )
    rejects(
        "complement digest drift",
        lambda record: record["complement"].update({"sha256": "0" * 64}),
    )
    rejects(
        "changed stop state",
        lambda record: record["preserved_stops"].update({"aggregate_gate": "closed"}),
    )

    if set(SOURCE_PATH_VALUES.values()) & INPUT_PATHS:
        raise AssertionError("recorded Phoenix source path appears in the read allowlist")
    for source_path in SOURCE_PATH_VALUES.values():
        try:
            read_input(source_path)
        except ValueError as error:
            if "unapproved evidence input" not in str(error):
                raise
            checks += 1
        else:
            raise AssertionError("source path was accepted as a checker input")

    print("PASS: positive supplement fixture and " + str(checks - 1) + " focused negative controls")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="validate the saved supplement and evidence")
    mode.add_argument("--self-test", action="store_true", help="run positive and negative controls in memory")
    args = parser.parse_args()

    if args.self_test:
        self_test()
        return

    evidence = load_evidence()
    validate_record(read_record(), evidence)
    print(
        "PASS: exactly four EX-177 keys; both lane bindings; "
        + str(evidence["complement_count"])
        + "-row complement "
        + evidence["complement_sha256"]
        + "; preserved stops"
    )


if __name__ == "__main__":
    main()
