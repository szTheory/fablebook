#!/usr/bin/env python3
"""Validate the fixed-input Plan01 identity stop without opening target sources."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[3]
PHASE_DIR = ROOT / ".planning/phases/07-guard-scope-reconciliation"
RECORD_PATH = PHASE_DIR / "07-RECONCILIATION.json"
ENV_DIR = ROOT / ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure"
INPUTS = {
    "verification": ENV_DIR / "04-VERIFICATION.md",
    "typed_gaps": ENV_DIR / "04-TYPED-GAPS-ENV06.jsonl",
    "associations": ENV_DIR / "04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl",
    "manifest": ENV_DIR / "04-PROVENANCE-MANIFEST.json",
    "phase3": ROOT / ".planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-03-KEYED-EVIDENCE.json",
    "phase6": ROOT / ".planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement/06-EX177-SUPPLEMENT.json",
    "core_lock": ROOT / "mix.lock",
    "floor_lock": ROOT / "mix.floor.lock",
}
ENV06 = "ENV-20261117-06-supported-20261117T204102Z"
TYPED_SHA = "128032ab929f831bb516186bbe9844b6bd36e0b55327a9cc998f16c65b0d4011"
ASSOCIATION_SHA = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
CORE_EXPECTED_LOCK = "4638a2d1c25b5be2bfaf6b6a3309e9147612f343aa694d64b2af99cc46f33a85"
FLOOR_EXPECTED_LOCK = "ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847"
EXPECTED_STOP = {
    "candidate": None,
    "candidate_fit": "unresolved",
    "actual_library_collision": "unknown",
    "implementation_authorized": False,
    "aggregate_gate": "open",
    "r9_consumption": "not_consumed",
    "sec_01": "Pending",
    "macro_caller_ast": "unresolved",
    "macro_explanation": "unresolved",
    "legacy_digest": "unresolved",
    "walking_skeleton": "blocked",
    "automatic_followup": False,
}
EXPECTED_MANIFEST_STOPS = {
    "actual_library_collision": "unknown",
    "aggregate_gate": "open",
    "candidate": None,
    "implementation_authorized": False,
    "sec_01": "Pending",
    "static_only": True,
    "walking_skeleton": "blocked",
}


class InvalidEvidence(ValueError):
    pass


def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise InvalidEvidence(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_json_bytes(data: bytes, label: str) -> Any:
    try:
        return json.loads(data.decode("utf-8"), object_pairs_hook=reject_duplicate_keys)
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise InvalidEvidence(f"{label}: malformed UTF-8 JSON: {exc}") from exc


def read_fixed_inputs() -> dict[str, bytes]:
    loaded: dict[str, bytes] = {}
    for label, path in INPUTS.items():
        try:
            loaded[label] = path.read_bytes()
        except OSError as exc:
            raise InvalidEvidence(f"fixed allowlist input unavailable: {label} ({path.name}): {exc}") from exc
    return loaded


def require_keys(obj: Any, expected: set[str], label: str) -> dict[str, Any]:
    if not isinstance(obj, dict):
        raise InvalidEvidence(f"{label}: expected JSON object")
    actual = set(obj)
    if actual != expected:
        missing = sorted(expected - actual)
        extra = sorted(actual - expected)
        raise InvalidEvidence(f"{label}: schema mismatch; missing={missing}; extra={extra}")
    return obj


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def lock_phoenix_version(data: bytes, label: str) -> str:
    matches = re.findall(rb'^\s*"phoenix": \{:hex, :phoenix, "([^"]+)",', data, re.MULTILINE)
    if len(matches) != 1:
        raise InvalidEvidence(f"{label}: expected exactly one pinned Phoenix package row, observed {len(matches)}")
    try:
        return matches[0].decode("ascii")
    except UnicodeDecodeError as exc:
        raise InvalidEvidence(f"{label}: Phoenix version is not ASCII") from exc


def parse_jsonl(data: bytes, label: str) -> list[dict[str, Any]]:
    rows: list[dict[str, Any]] = []
    for line_number, line in enumerate(data.splitlines(), start=1):
        if not line.strip():
            raise InvalidEvidence(f"{label}:{line_number}: blank rows are not allowed")
        row = load_json_bytes(line, f"{label}:{line_number}")
        if not isinstance(row, dict):
            raise InvalidEvidence(f"{label}:{line_number}: expected object")
        rows.append(row)
    return rows


def load_record() -> dict[str, Any]:
    try:
        record = load_json_bytes(RECORD_PATH.read_bytes(), RECORD_PATH.name)
    except OSError as exc:
        raise InvalidEvidence(f"stop record unavailable: {exc}") from exc
    return require_keys(
        record,
        {
            "schema", "phase", "status", "accepted_evidence", "lane_pins", "membership",
            "proposed_family", "source_schedule", "source_read_boundary", "preserved_stops", "owner_decision",
        },
        "stop record",
    )


def require_values(actual: Any, expected: dict[str, Any], label: str) -> dict[str, Any]:
    obj = require_keys(actual, set(expected), label)
    for key, value in expected.items():
        if obj[key] != value:
            raise InvalidEvidence(f"{label}: unexpected {key} value")
    return obj


def validate() -> str:
    raw = read_fixed_inputs()
    record = load_record()

    verification = raw["verification"].decode("utf-8")
    if "**Status:** passed" not in verification or ENV06 not in verification:
        raise InvalidEvidence("accepted Phase 4 verification does not bind the passed ENV06 generation")

    manifest = load_json_bytes(raw["manifest"], "04-PROVENANCE-MANIFEST.json")
    if not isinstance(manifest, dict):
        raise InvalidEvidence("04-PROVENANCE-MANIFEST.json: expected object")
    if manifest.get("schema_version") != "04.provenance.1" or manifest.get("generation") != ENV06:
        raise InvalidEvidence("accepted manifest schema or generation mismatch")
    if manifest.get("metadata_status") != "supported" or manifest.get("partition_outcome") != "complete":
        raise InvalidEvidence("accepted manifest is not a supported complete partition")
    if manifest.get("source_access") != "closed":
        raise InvalidEvidence("accepted ENV06 manifest no longer records source access closed")
    if not isinstance(manifest.get("lanes"), dict) or set(manifest["lanes"]) != {"core", "floor"}:
        raise InvalidEvidence("accepted manifest lane set changed")
    if manifest.get("safety_stops") != EXPECTED_MANIFEST_STOPS:
        raise InvalidEvidence("accepted manifest safety-stop fields changed")

    typed = raw["typed_gaps"]
    associations = raw["associations"]
    typed_rows = parse_jsonl(typed, "04-TYPED-GAPS-ENV06.jsonl")
    association_rows = parse_jsonl(associations, "04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl")
    if len(typed_rows) != 9716 or sha256(typed) != TYPED_SHA:
        raise InvalidEvidence("accepted ENV06 typed-gap row count or digest changed")
    if len(associations) != 0 or association_rows or sha256(associations) != ASSOCIATION_SHA:
        raise InvalidEvidence("accepted ENV06 association input changed from its zero-row receipt")

    partition = manifest.get("partitions", {}).get("typed_gaps", {})
    if partition.get("rows") != len(typed_rows) or partition.get("sha256") != sha256(typed):
        raise InvalidEvidence("ENV06 manifest no longer binds the exact typed-gap input")
    association_partition = manifest.get("partitions", {}).get("associations", {})
    if association_partition.get("rows") != 0 or association_partition.get("sha256") != sha256(associations):
        raise InvalidEvidence("ENV06 manifest no longer binds the zero-row association input")

    lane_rows: dict[str, list[dict[str, Any]]] = {"core": [], "floor": []}
    for row in typed_rows:
        if row.get("generation") != ENV06 or row.get("lane") not in lane_rows:
            raise InvalidEvidence("typed-gap row has an unexpected generation or lane")
        lane_rows[row["lane"]].append(row)
    if {lane: len(rows) for lane, rows in lane_rows.items()} != {"core": 4944, "floor": 4772}:
        raise InvalidEvidence("ENV06 per-lane row distribution changed")
    if any(len({row.get("original_id") for row in rows}) != 226 for rows in lane_rows.values()):
        raise InvalidEvidence("ENV06 per-lane identity row coverage changed")
    row_schemas = {tuple(sorted(row)) for row in typed_rows}
    expected_row_schema = {
        "archive_row", "blocked_by", "direct_evidence_refs", "domain", "evidence_status", "gap_key",
        "generation", "historical_citations_raw", "independent_review", "input_file", "input_pointer",
        "input_sha256", "lane", "lock_sha256", "membership_roles", "membership_selectors", "mfa",
        "missing_fields", "original_id", "owner", "prior_gap_selector", "reason", "remedy",
        "repository_ref", "runtime", "schema_version", "source_bytes", "source_path", "source_sha256",
        "source_span",
    }
    if row_schemas != {tuple(sorted(expected_row_schema))}:
        raise InvalidEvidence("ENV06 typed-gap row schema changed")
    row_pin_digests = {
        lane: {row["lock_sha256"] for row in rows}
        for lane, rows in lane_rows.items()
    }
    if row_pin_digests != {"core": {CORE_EXPECTED_LOCK}, "floor": {FLOOR_EXPECTED_LOCK}}:
        raise InvalidEvidence("ENV06 typed-gap rows disagree with their accepted lane lock pins")

    phase3 = load_json_bytes(raw["phase3"], "03-03-KEYED-EVIDENCE.json")
    phase6 = load_json_bytes(raw["phase6"], "06-EX177-SUPPLEMENT.json")
    if not isinstance(phase3, dict) or not isinstance(phase6, dict):
        raise InvalidEvidence("historical inventory records must be JSON objects")
    if set(phase3) != {
        "bounded_remedy", "caller_closure_complete", "candidate", "generation", "implementation_authorized",
        "lanes", "no_candidate_reason", "schema", "selection", "source_closure_complete",
    }:
        raise InvalidEvidence("historical Phase 3 summary schema changed")
    if set(phase6) != {
        "caller_closure", "complement", "lanes", "observations", "phase", "preserved_stops", "provenance",
        "requirement", "schema", "selected_keys", "source_boundary",
    }:
        raise InvalidEvidence("historical Phase 6 supplement schema changed")
    if phase3.get("generation") != "09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b":
        raise InvalidEvidence("historical Phase 3 inventory generation changed")
    if phase6.get("selected_keys") != [
        "core|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|source",
        "core|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|caller",
        "floor|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|source",
        "floor|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|caller",
    ]:
        raise InvalidEvidence("historical Phase 6 selection changed; it is not a current family baseline")

    pin_results: dict[str, dict[str, Any]] = {}
    for lane, lock_label, expected_sha, expected_version in (
        ("core", "core_lock", CORE_EXPECTED_LOCK, "1.8.16"),
        ("floor", "floor_lock", FLOOR_EXPECTED_LOCK, "1.8.9"),
    ):
        lane_receipt = manifest["lanes"][lane]["current_lane_fields"]
        if lane_receipt["lock_sha256"] != expected_sha:
            raise InvalidEvidence(f"{lane} expected lock pin disagrees with accepted manifest")
        observed_sha = sha256(raw[lock_label])
        observed_version = lock_phoenix_version(raw[lock_label], lock_label)
        historical_pin = phase6["lanes"][lane]["phoenix"]["version"]
        if historical_pin != expected_version or observed_version != expected_version:
            raise InvalidEvidence(f"{lane} Phoenix package version differs from the recorded pin")
        recorded = record["lane_pins"][lane]
        require_keys(
            recorded,
            {
                "lock_file", "expected_lock_sha256", "observed_lock_sha256", "expected_phoenix_version",
                "observed_phoenix_version", "env06_recorded_runtime", "phase6_recorded_runtime",
                "observed_current_runtime", "status",
            },
            f"{lane} lane pin record",
        )
        env_runtime = lane_receipt["runtime"]
        phase6_runtime = phase6["lanes"][lane]["runtime"]
        require_values(recorded["env06_recorded_runtime"], env_runtime, f"{lane} ENV06 runtime")
        require_values(recorded["phase6_recorded_runtime"], phase6_runtime, f"{lane} Phase 6 runtime")
        expected_record = {
            "lock_file": "mix.lock" if lane == "core" else "mix.floor.lock",
            "expected_lock_sha256": expected_sha,
            "observed_lock_sha256": observed_sha,
            "expected_phoenix_version": expected_version,
            "observed_phoenix_version": observed_version,
        }
        for key, value in expected_record.items():
            if recorded.get(key) != value:
                raise InvalidEvidence(f"{lane} stop record has stale or inaccurate {key}")
        if recorded.get("observed_current_runtime") is not None:
            raise InvalidEvidence(f"{lane} stop record claims a current runtime not present in the fixed inputs")
        pin_results[lane] = {"expected": expected_sha, "observed": observed_sha, "version": observed_version}

    core_mismatch = pin_results["core"]["expected"] != pin_results["core"]["observed"]
    floor_mismatch = pin_results["floor"]["expected"] != pin_results["floor"]["observed"]
    if not core_mismatch or floor_mismatch:
        raise InvalidEvidence("recorded fail-closed pin outcome no longer matches the fixed inputs")

    if record["schema"] != "fablebook.guard-scope-reconciliation/1" or record["phase"] != "07":
        raise InvalidEvidence("stop record schema or phase is invalid")
    if record["status"] != "stopped_identity_mismatch":
        raise InvalidEvidence("stop record does not identify the pin discrepancy")
    if record["proposed_family"] is not None or record["source_schedule"] is not None:
        raise InvalidEvidence("partition or source schedule exists despite the identity stop")
    if record["preserved_stops"] != EXPECTED_STOP:
        raise InvalidEvidence("one or more inherited safety stops changed")
    if record["source_read_boundary"] != {"target_source_bodies_read": False, "recorded_source_paths_are_values_only": True}:
        raise InvalidEvidence("source-read boundary changed")
    require_keys(record["membership"], {"status", "accepted_env06_row_counts", "reason"}, "membership stop")
    if record["membership"].get("status") != "not_reconciled_after_identity_stop":
        raise InvalidEvidence("stop record incorrectly claims exact membership reconciliation")
    require_keys(record["accepted_evidence"], {
        "receipt_path", "receipt_status", "generation", "typed_gaps", "target_source_associations", "per_lane_rows",
    }, "accepted evidence record")
    require_values(record["accepted_evidence"]["typed_gaps"], {
        "path": ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-TYPED-GAPS-ENV06.jsonl",
        "rows": len(typed_rows), "bytes": len(typed), "sha256": sha256(typed),
    }, "typed-gap summary")
    require_values(record["accepted_evidence"]["target_source_associations"], {
        "path": ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure/04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl",
        "rows": 0, "bytes": 0, "sha256": sha256(associations),
    }, "association summary")
    if record["accepted_evidence"]["generation"] != ENV06 or record["accepted_evidence"]["receipt_status"] != "passed":
        raise InvalidEvidence("stop record has an inaccurate accepted receipt or generation")
    if record["accepted_evidence"]["per_lane_rows"] != {lane: len(rows) for lane, rows in lane_rows.items()}:
        raise InvalidEvidence("stop record has inaccurate per-lane row counts")
    if record["membership"]["accepted_env06_row_counts"] != {lane: len(rows) for lane, rows in lane_rows.items()}:
        raise InvalidEvidence("membership stop has inaccurate ENV06 row counts")
    if record["lane_pins"]["core"]["status"] != "stop_digest_mismatch" or record["lane_pins"]["floor"]["status"] != "matches_recorded_pin":
        raise InvalidEvidence("lane pin statuses do not match the observed digest outcome")
    require_values(record["owner_decision"], {
        "required": True,
        "question": "Should the core lane pin/evidence provenance be re-scoped and freshly reconciled before Plan01 resumes?",
        "recommendation": "Keep this stop. Do not edit the saved baseline or combine generations. Reconcile the intended core lock digest at the rescoping boundary, then rerun Plan01's identity and membership checks before defining any family or source schedule.",
    }, "owner decision")
    return (
        "FAIL-CLOSED STOP CONFIRMED: core mix.lock digest differs from the accepted lane pin; "
        "floor pin matches. ENV06 is bound, no partition or source schedule is present, and target source bodies were not read."
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", choices=["membership"], required=True)
    args = parser.parse_args()
    try:
        print(validate())
    except (InvalidEvidence, KeyError, TypeError, ValueError) as exc:
        print(f"INVALID EVIDENCE OR STOP RECORD: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
