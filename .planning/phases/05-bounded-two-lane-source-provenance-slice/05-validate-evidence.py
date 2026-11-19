#!/usr/bin/env python3
"""Cheap, fail-closed checks for the bounded EX-177 evidence slice.

This validator is standard-library-only. Phase 4 inputs are streamed through
SHA-256 only; source bodies are not decoded, printed, or analyzed here.
"""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[3]
PHASE = ROOT / ".planning/phases/05-bounded-two-lane-source-provenance-slice"
P3 = ROOT / ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
P4 = ROOT / ".planning/phases/04-evidence-only-source-and-gap-provenance-closure"
CORE_PATH = ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json"
FLOOR_PATH = ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json"
MANIFEST_PATH = ".planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-PROVENANCE-MANIFEST.json"
GAPS_PATH = ".planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-TYPED-GAPS-ENV06.jsonl"
VALIDATION_PATH = ".planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-VALIDATION.json"
DELIVERIES_PATH = ".planning/references/PHASE-DELIVERIES.json"
REVIEW_PATH = PHASE / "05-R9-REVIEW.json"
READINESS_PATH = PHASE / "05-R9-READINESS.json"
GATE_PATH = PHASE / "05-R9-ONE-USE-GATE.json"
RESULT_PATH = PHASE / "05-R9-RESULT.json"

MFA = ["Elixir.Mix.Tasks.Phx.Gen.Context", "prompt_for_code_injection", 1]
LANES = ("core", "floor")
DOMAINS = ("source", "caller")
EXPECTED_KEYS = tuple(
    f"{lane}|EX-177|{MFA[0]}|{MFA[1]}|{MFA[2]}|{domain}"
    for lane in LANES
    for domain in DOMAINS
)
EXPECTED_GENERATION = "ENV-20261117-06-supported-20261117T204102Z"
EXPECTED_COMPLEMENT_COUNT = 9712
EXPECTED_TOTAL_GAPS = 9716
EXPECTED_STOPS = {
    "actual_library_collision": "unknown",
    "aggregate_gate": "open",
    "candidate": None,
    "implementation_authorized": False,
    "sec_01": "Pending",
    "static_only": True,
    "walking_skeleton": "blocked",
}
EXPECTED_PHASE3_STOPS = {
    "aggregate_gate": "open",
    "candidate": None,
    "implementation_authorized": False,
    "sec_01": "Pending",
    "walking_skeleton": "blocked",
}


class GateError(Exception):
    pass


def duplicate_rejecting_pairs(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise GateError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def parse_json_bytes(raw: bytes, label: str) -> Any:
    try:
        return json.loads(raw.decode("utf-8"), object_pairs_hook=duplicate_rejecting_pairs)
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise GateError(f"{label}: invalid UTF-8 JSON: {exc}") from exc


def load_json(path: Path) -> Any:
    return parse_json_bytes(path.read_bytes(), str(path.relative_to(ROOT)))


def stream_hash(path: Path) -> dict[str, Any]:
    digest = hashlib.sha256()
    size = 0
    with path.open("rb") as stream:
        while chunk := stream.read(1024 * 1024):
            digest.update(chunk)
            size += len(chunk)
    return {"bytes": size, "sha256": digest.hexdigest()}


def canonical_hash(value: Any) -> str:
    raw = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def relative_path(raw_path: str) -> Path:
    path = Path(raw_path)
    if path.is_absolute() or ".." in path.parts:
        raise GateError(f"unsafe/non-relative input path in receipt: {raw_path}")
    return ROOT / path


def read_jsonl(path: Path) -> tuple[list[dict[str, Any]], list[bytes]]:
    try:
        raw = path.read_bytes()
    except OSError as exc:
        raise GateError(f"cannot read {path.relative_to(ROOT)}: {exc}") from exc
    if raw and not raw.endswith(b"\n"):
        raise GateError(f"{path.relative_to(ROOT)} lacks its final LF")
    rows: list[dict[str, Any]] = []
    lines: list[bytes] = []
    for line_number, line in enumerate(raw.splitlines(keepends=True), 1):
        body = line[:-1] if line.endswith(b"\n") else line
        if body.endswith(b"\r"):
            raise GateError(f"{path.relative_to(ROOT)}:{line_number} uses CRLF")
        row = parse_json_bytes(body, f"{path.relative_to(ROOT)}:{line_number}")
        if not isinstance(row, dict):
            raise GateError(f"{path.relative_to(ROOT)}:{line_number} is not a JSON object")
        rows.append(row)
        lines.append(line)
    return rows, lines


def validate_partition_rows(
    rows: list[dict[str, Any]],
    lines: list[bytes],
    *,
    generation: str = EXPECTED_GENERATION,
    expected_complement_count: int = EXPECTED_COMPLEMENT_COUNT,
) -> dict[str, Any]:
    if len(rows) != len(lines):
        raise GateError("decoded row count differs from raw line count")
    seen: set[str] = set()
    selected: dict[str, dict[str, Any]] = {}
    complement: list[bytes] = []
    for index, (row, line) in enumerate(zip(rows, lines), 1):
        key = row.get("gap_key")
        if not isinstance(key, str):
            raise GateError(f"gap row {index} has no string gap_key")
        if key in seen:
            raise GateError(f"duplicate gap_key: {key}")
        seen.add(key)
        if row.get("generation") != generation:
            raise GateError(f"wrong generation for {key}: {row.get('generation')!r}")
        if key in EXPECTED_KEYS:
            selected[key] = row
        else:
            if row.get("original_id") == "EX-177":
                raise GateError(f"unexpected EX-177 row outside the four selected keys: {key}")
            complement.append(line)
    if set(selected) != set(EXPECTED_KEYS):
        missing = sorted(set(EXPECTED_KEYS) - set(selected))
        extra = sorted(set(selected) - set(EXPECTED_KEYS))
        raise GateError(f"selected gap key mismatch; missing={missing}; extra={extra}")
    if len(selected) != 4:
        raise GateError(f"selected gap count is {len(selected)}, expected 4")
    if len(complement) != expected_complement_count:
        raise GateError(
            f"pending complement count is {len(complement)}, expected {expected_complement_count}"
        )
    for key, row in selected.items():
        lane, identity_id, module, function, arity, domain = key.split("|")
        if row.get("lane") != lane or row.get("original_id") != identity_id:
            raise GateError(f"selected row lane/identity mismatch: {key}")
        if row.get("mfa") != [module, function, int(arity)]:
            raise GateError(f"selected row MFA mismatch: {key}")
        if row.get("domain") != domain:
            raise GateError(f"selected row domain mismatch: {key}")
        if row.get("source_path") is not None or row.get("source_sha256") is not None or row.get("source_span") is not None:
            raise GateError(f"Phase 4 unexpectedly claims a source identity/span for {key}")
    comp_hash = hashlib.sha256(b"".join(complement)).hexdigest()
    return {
        "selected_keys": list(EXPECTED_KEYS),
        "selected_row_count": 4,
        "selected_rows": selected,
        "complement_count": len(complement),
        "complement_sha256": comp_hash,
        "total_gap_rows": len(rows),
        "generation": generation,
    }


def validate_lane_membership(lane: str, aggregate: dict[str, Any], manifest_lane: dict[str, Any]) -> dict[str, Any]:
    identity_rows = aggregate.get("identity_rows")
    if not isinstance(identity_rows, list):
        raise GateError(f"{lane}: aggregate has no identity_rows list")
    ids = [row.get("identity", {}).get("id") for row in identity_rows]
    validate_identity_membership(lane, ids, manifest_lane.get("identity_ids", []), manifest_lane.get("identity_count"))
    target = [row for row in identity_rows if row.get("identity", {}).get("id") == "EX-177"]
    if len(target) != 1:
        raise GateError(f"{lane}: expected exactly one EX-177 identity row, observed {len(target)}")
    row = target[0]
    for field in ("baseline_mfas", "live_mfas", "pending_mfas"):
        validate_exact_mfa(lane, field, row.get(field))
    if row.get("added_mfas") != [] or row.get("delivered_mfas") != []:
        raise GateError(f"{lane}: EX-177 has unexpected added/delivered MFA membership")
    if aggregate.get("lane") != lane:
        raise GateError(f"{lane}: aggregate lane label mismatch")
    current = manifest_lane.get("current_lane_fields", {})
    lane_generation = current.get("generation")
    if not isinstance(lane_generation, str) or aggregate.get("generation") != lane_generation:
        raise GateError(f"{lane}: aggregate and manifest lane generation mismatch")
    return {
        "identity_count": len(ids),
        "identity_ids_sha256": manifest_lane.get("identity_ids_sha256"),
        "mfa": MFA,
        "generation": lane_generation,
        "lock_sha256": current.get("lock_sha256"),
        "historical_locator_only": "phoenix/lib/mix/tasks/phx.gen.context.ex:445",
        "current_source_path": None,
        "current_source_sha256": None,
        "complete_span": None,
    }


def validate_identity_membership(lane: str, ids: list[Any], manifest_ids: list[Any], manifest_count: Any) -> None:
    if len(ids) != 226 or len(set(ids)) != 226 or manifest_count != 226:
        raise GateError(f"{lane}: expected 226 unique identity rows, observed {len(ids)}")
    if set(manifest_ids) != set(ids):
        raise GateError(f"{lane}: manifest identity membership differs from aggregate")


def validate_exact_mfa(lane: str, field: str, mfas: Any) -> None:
    if mfas != [MFA]:
        raise GateError(f"{lane}: EX-177 {field} is not exactly the selected MFA")


def inspect_r9_reuse(validation: dict[str, Any]) -> dict[str, Any]:
    ledger = load_json(P4 / "04-RESOURCE-LEDGER.json")
    consumed = ledger.get("consumed_request_ids")
    if consumed != [f"R{i}" for i in range(1, 9)] or ledger.get("source_request_count") != 8:
        raise GateError("Phase 4 request ledger is not the exact consumed R1–R8 prefix")
    gates = validation.get("checks", {}).get("final_evidence_payloads", {}).get("result", {}).get("request_gates", {})
    if set(gates) != {f"R{i}" for i in range(1, 9)}:
        raise GateError("Phase 4 validation does not bind exactly the R1–R8 request gates")
    for request_id, gate in gates.items():
        if gate.get("bindings", {}).get("request_id") != request_id:
            raise GateError(f"Phase 4 request gate binding mismatch: {request_id}")
        if not str(gate.get("status", "")).startswith("consumed_"):
            raise GateError(f"Phase 4 request {request_id} is not recorded consumed")
    # Machine-readable request identifiers across all Phase 3/4 JSON receipts.
    pattern = re.compile(rb'"request_id"\s*:\s*"R9"')
    matches: list[str] = []
    for phase_dir in (P3, P4):
        for path in phase_dir.rglob("*.json"):
            if pattern.search(path.read_bytes()):
                matches.append(str(path.relative_to(ROOT)))
    if matches:
        raise GateError(f"R9 request_id already appears in Phase 3/4 receipts: {matches}")
    return {
        "candidate_request_id": "R9",
        "phase4_source_request_count": 8,
        "consumed_request_ids": consumed,
        "phase3_phase4_request_id_matches": [],
        "allocation_status": "unique_candidate_after_history_check",
        "consumption_status": "not_emitted",
    }


def verify_phase4_freshness() -> dict[str, Any]:
    manifest = load_json(ROOT / MANIFEST_PATH)
    validation = load_json(ROOT / VALIDATION_PATH)
    bindings = validation.get("bindings", {})
    if validation.get("schema_version") != "04.validation.2":
        raise GateError("Phase 4 validation receipt schema changed")
    if validation.get("result") != "pass_with_open_gaps" or validation.get("validation_passed") is not True or validation.get("full_package_valid") is not True:
        raise GateError("Phase 4 saved validation is not a passing open-gaps package")
    if validation.get("source_access") != "closed" or validation.get("generation") != EXPECTED_GENERATION:
        raise GateError("Phase 4 saved validation source/generation state changed")
    if validation.get("final_package_check", {}).get("exit_code") != 0 or validation.get("final_package_check", {}).get("status") != "passed":
        raise GateError("Phase 4 saved final package check is not a pass")

    observed: dict[str, dict[str, Any]] = {}
    def record(relative: str, expected_sha: str | None = None, expected_bytes: int | None = None) -> dict[str, Any]:
        if relative not in observed:
            path = relative_path(relative)
            actual = stream_hash(path)
            observed[relative] = actual
        actual = observed[relative]
        if expected_sha is not None and actual["sha256"] != expected_sha:
            raise GateError(f"Phase 4 input drift at {relative}: expected {expected_sha}; observed {actual['sha256']}")
        if expected_bytes is not None and actual["bytes"] != expected_bytes:
            raise GateError(f"Phase 4 input byte drift at {relative}: expected {expected_bytes}; observed {actual['bytes']}")
        return actual

    manifest_hash = record(MANIFEST_PATH, bindings.get("manifest_sha256"))
    inputs = manifest.get("inputs")
    if not isinstance(inputs, list) or not inputs:
        raise GateError("Phase 4 manifest has no input hash list")
    seen_paths: set[str] = set()
    for entry in inputs:
        if not isinstance(entry, dict) or not isinstance(entry.get("path"), str):
            raise GateError("Phase 4 manifest input entry is malformed")
        path = entry["path"]
        if path in seen_paths:
            raise GateError(f"duplicate Phase 4 manifest input path: {path}")
        seen_paths.add(path)
        record(path, entry.get("sha256"), entry.get("bytes"))

    partitions = manifest.get("partitions", {})
    assoc = partitions.get("associations", {})
    gaps = partitions.get("typed_gaps", {})
    if not assoc.get("path") or not gaps.get("path"):
        raise GateError("Phase 4 manifest lacks active association/gap paths")
    record(assoc["path"], bindings.get("association_sha256"), assoc.get("bytes"))
    record(gaps["path"], bindings.get("typed_gaps_sha256"), gaps.get("bytes"))
    trace_path = manifest.get("current_source_request_status", {}).get("path")
    record(trace_path, bindings.get("caller_trace_sha256"))
    digest_path = ".planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-SIZING-DIGEST-PROOF.json"
    record(digest_path, bindings.get("digest_proof_sha256"))
    expected_review = bindings.get("evidence_review_sha256")
    review_candidates = sorted(P4.glob("04-EVIDENCE-REVIEW*.json"))
    review_matches = [str(p.relative_to(ROOT)) for p in review_candidates if stream_hash(p)["sha256"] == expected_review]
    if len(review_matches) != 1:
        raise GateError(f"Phase 4 evidence review binding matched {len(review_matches)} files, expected one")
    record(review_matches[0], expected_review)
    for request_id, expected_sha in bindings.get("request_gate_sha256s", {}).items():
        if request_id not in {f"R{i}" for i in range(1, 9)}:
            raise GateError(f"unexpected request gate in Phase 4 receipt: {request_id}")
        record(f".planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-{request_id}-REQUEST-GATE.json", expected_sha)

    for kind, active in (("associations", assoc), ("typed_gaps", gaps)):
        stable_path = bindings.get("stable_consumer_payloads", {}).get(kind, {}).get("stable_path")
        if not stable_path:
            raise GateError(f"Phase 4 {kind} stable alias is missing")
        active_hash = record(active["path"])
        stable_hash = record(stable_path)
        if stable_hash != active_hash:
            raise GateError(f"Phase 4 {kind} stable alias differs from active payload")

    if manifest.get("generation") != EXPECTED_GENERATION:
        raise GateError("Phase 4 manifest generation mismatch")
    if manifest.get("safety_stops") != EXPECTED_STOPS:
        raise GateError("Phase 4 safety-stop snapshot changed")
    return {
        "path": VALIDATION_PATH,
        "sha256": stream_hash(ROOT / VALIDATION_PATH)["sha256"],
        "result": validation["result"],
        "generation": validation["generation"],
        "manifest": {"path": MANIFEST_PATH, **manifest_hash},
        "input_count": len(inputs),
        "input_hashes": observed,
        "bindings": bindings,
        "review_path": review_matches[0],
        "request_ledger": inspect_r9_reuse(validation),
        "freshness": "passed",
        "hashing_mode": "streaming SHA-256 only; no source bytes decoded or emitted",
    }


def evaluate_scope() -> dict[str, Any]:
    freshness = verify_phase4_freshness()
    core = load_json(ROOT / CORE_PATH)
    floor = load_json(ROOT / FLOOR_PATH)
    manifest = load_json(ROOT / MANIFEST_PATH)
    lane_membership = {
        "core": validate_lane_membership("core", core, manifest.get("lanes", {}).get("core", {})),
        "floor": validate_lane_membership("floor", floor, manifest.get("lanes", {}).get("floor", {})),
    }
    gaps, raw_lines = read_jsonl(ROOT / GAPS_PATH)
    partition = validate_partition_rows(gaps, raw_lines)
    if partition["total_gap_rows"] != EXPECTED_TOTAL_GAPS:
        raise GateError(f"typed-gap row count is {partition['total_gap_rows']}, expected {EXPECTED_TOTAL_GAPS}")
    for lane in LANES:
        lane_gaps = [row for row in partition["selected_rows"].values() if row["lane"] == lane]
        if len(lane_gaps) != 2 or {row["domain"] for row in lane_gaps} != set(DOMAINS):
            raise GateError(f"{lane}: selected rows are not exactly one source and one caller gap")
        expected_lock = lane_membership[lane]["lock_sha256"]
        if any(row.get("lock_sha256") != expected_lock for row in lane_gaps):
            raise GateError(f"{lane}: selected gap lock hash differs from pinned lane metadata")
    for lane_obj in (core, floor):
        current_stops = {key: lane_obj.get(key) for key in EXPECTED_PHASE3_STOPS}
        if current_stops != EXPECTED_PHASE3_STOPS:
            raise GateError(f"Phase 3 safety stops differ: {current_stops}")
    deliveries = load_json(ROOT / DELIVERIES_PATH)
    if deliveries.get("schema") != "fablebook.phase-deliveries/1":
        raise GateError("phase delivery receipt schema changed")
    phase3_4 = [
        item for item in deliveries.get("phases", [])
        if item.get("milestone") == "v0.4" and item.get("phase") in ("3", "4")
    ]
    if {item.get("phase") for item in phase3_4} != {"3", "4"} or any(item.get("status") != "merged" for item in phase3_4):
        raise GateError("Phase 3/4 delivery receipts are not both merged")
    input_hashes = freshness["input_hashes"]
    input_hashes[CORE_PATH] = stream_hash(ROOT / CORE_PATH)
    input_hashes[FLOOR_PATH] = stream_hash(ROOT / FLOOR_PATH)
    input_hashes[GAPS_PATH] = stream_hash(ROOT / GAPS_PATH)
    input_hashes[DELIVERIES_PATH] = stream_hash(ROOT / DELIVERIES_PATH)
    scope_payload = {
        "generation": partition["generation"],
        "selected_keys": list(EXPECTED_KEYS),
        "selected_mfa_per_lane": {lane: MFA for lane in LANES},
        "complement_count": partition["complement_count"],
        "complement_sha256": partition["complement_sha256"],
        "phase3_input_hashes": {CORE_PATH: input_hashes[CORE_PATH], FLOOR_PATH: input_hashes[FLOOR_PATH]},
        "phase4_gap_hash": input_hashes[GAPS_PATH],
    }
    return {
        "scope_status": "passed",
        "status": "ready_for_metadata_schedule",
        "request_id": "R9",
        "selected": partition["selected_keys"],
        "lane_membership": lane_membership,
        "complement": {"count": partition["complement_count"], "sha256": partition["complement_sha256"]},
        "phase4_validation": freshness,
        "phase3_stops": EXPECTED_STOPS,
        "phase4_safety_stops": manifest["safety_stops"],
        "delivery_receipts": phase3_4,
        "input_hashes": input_hashes,
        "scope_payload": scope_payload,
        "scope_payload_sha256": canonical_hash(scope_payload),
        "source_discovery": "not_run",
        "source_body_reads": 0,
        "source_emission": "not_run",
    }


def atomic_json_write(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    raw = (json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2) + "\n").encode("utf-8")
    fd, tmp_name = tempfile.mkstemp(prefix=f".{path.name}.", suffix=".tmp", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(raw)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(tmp_name, path)
    finally:
        try:
            os.unlink(tmp_name)
        except FileNotFoundError:
            pass


def initialize_scope() -> dict[str, Any]:
    if REVIEW_PATH.exists():
        previous = load_json(REVIEW_PATH)
        if not (
            previous.get("status") == "stopped"
            and previous.get("scope_status") == "failed"
            and previous.get("source_emission") == "not_run"
            and previous.get("source_body_reads") == 0
        ):
            raise GateError("05-R9-REVIEW.json already exists; refusing to replace a valid or consumed scope receipt")
    try:
        review = evaluate_scope()
    except Exception as exc:
        review = {
            "schema_version": "05.r9.review.1",
            "created_at_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "request_id": "R9",
            "status": "stopped",
            "scope_status": "failed",
            "source_access": "closed",
            "stop_reasons": [str(exc)],
            "selected_keys": list(EXPECTED_KEYS),
            "expected_complement_count": EXPECTED_COMPLEMENT_COUNT,
            "source_discovery": "not_run",
            "source_body_reads": 0,
            "source_emission": "not_run",
        }
    else:
        review = {"schema_version": "05.r9.review.1", "created_at_utc": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"), **review}
        review["source_access"] = "closed"
        review["schedule"] = {"status": "not_run", "reason": "Task 2 metadata scheduling not started"}
        review["schedule_review"] = {"status": "not_run", "reviewer": None, "reason": "No schedule exists yet"}
        review["security_review"] = {"status": "not_run", "reviewer": None, "reason": "No schedule exists yet"}
    atomic_json_write(REVIEW_PATH, review)
    return {
        "status": review.get("status"),
        "scope_status": review.get("scope_status"),
        "selected_rows": len(review.get("selected", [])),
        "complement_count": review.get("complement", {}).get("count"),
        "complement_sha256": review.get("complement", {}).get("sha256"),
        "stop_reasons": review.get("stop_reasons", []),
        "source_emission": review.get("source_emission"),
    }


def validate_saved_scope() -> dict[str, Any]:
    if not REVIEW_PATH.exists():
        raise GateError("05-R9-REVIEW.json is missing; run --initialize-scope first")
    saved = load_json(REVIEW_PATH)
    current = evaluate_scope()
    if saved.get("schema_version") != "05.r9.review.1" or saved.get("request_id") != "R9":
        raise GateError("Phase 5 review schema or candidate request ID mismatch")
    for field in ("scope_payload_sha256", "selected", "lane_membership", "complement", "phase3_stops"):
        if saved.get(field) != current.get(field):
            stop = f"saved Phase 5 {field} differs from current bound inputs"
            saved["status"] = "stopped"
            saved.setdefault("stop_reasons", []).append(stop)
            saved["source_emission"] = "not_run"
            atomic_json_write(REVIEW_PATH, saved)
            raise GateError(stop)
    saved_hashes = saved.get("input_hashes", {})
    if saved_hashes != current.get("input_hashes"):
        stop = "saved Phase 5 input hashes differ from current Phase 3/4 inputs"
        saved["status"] = "stopped"
        saved.setdefault("stop_reasons", []).append(stop)
        saved["source_emission"] = "not_run"
        atomic_json_write(REVIEW_PATH, saved)
        raise GateError(stop)
    if saved.get("source_access") != "closed" or saved.get("source_body_reads") != 0:
        raise GateError("Phase 5 source boundary changed")
    return {"saved": saved, "current": current}


def stop_for_missing_metadata() -> dict[str, Any]:
    bound = validate_saved_scope()
    review = bound["saved"]
    if review.get("status") != "ready_for_metadata_schedule":
        raise GateError(f"metadata scheduling cannot proceed from status {review.get('status')!r}")
    reasons = [
        "The exact EX-177 current source path, source hash, package/archive revision, and complete span are null in both pinned Phase 4 lane gap records.",
        "Phase 3 retains only the historical locator phoenix/lib/mix/tasks/phx.gen.context.ex:445; it is not current lane identity/span proof.",
        "No retained Phase 3/4 symbol or span index is bound to EX-177, so a metadata-only schedule cannot be produced without opening source bodies to discover it.",
    ]
    lanes = {
        lane: {
            "pinned_generation": review["lane_membership"][lane]["generation"],
            "lock_sha256": review["lane_membership"][lane]["lock_sha256"],
            "mfa": MFA,
            "source_path": None,
            "source_sha256": None,
            "complete_span": None,
            "historical_locator": "phoenix/lib/mix/tasks/phx.gen.context.ex:445",
            "status": "identity_and_span_unproven",
        }
        for lane in LANES
    }
    metadata_artifacts = [
        {
            "path": CORE_PATH,
            "sha256": review.get("input_hashes", {}).get(CORE_PATH, {}).get("sha256"),
            "target_pointer": "/identity_rows/182",
            "current_source_identity": "not_recorded",
            "historical_locator": "phoenix/lib/mix/tasks/phx.gen.context.ex:445",
        },
        {
            "path": FLOOR_PATH,
            "sha256": review.get("input_hashes", {}).get(FLOOR_PATH, {}).get("sha256"),
            "target_pointer": "/identity_rows/182",
            "current_source_identity": "not_recorded",
            "historical_locator": "phoenix/lib/mix/tasks/phx.gen.context.ex:445",
        },
        {
            "path": GAPS_PATH,
            "sha256": review.get("input_hashes", {}).get(GAPS_PATH, {}).get("sha256"),
            "target_gap_keys": list(EXPECTED_KEYS),
            "source_path_sha256_span": "null for all four selected rows",
        },
    ]
    review["status"] = "stopped"
    review["stop_reasons"] = reasons
    review["schedule"] = {
        "status": "not_created",
        "candidate_files": [],
        "lane_sources": lanes,
        "metadata_artifacts_reviewed": metadata_artifacts,
        "metadata_index_search": {
            "retained_scope": [str(P3.relative_to(ROOT)), str(P4.relative_to(ROOT))],
            "target_metadata_hits": [CORE_PATH, FLOOR_PATH, GAPS_PATH],
            "symbol_or_span_index_candidates": [],
            "basis": "filename inventory and exact target metadata hits; no source bodies opened to discover spans",
        },
        "historical_locator_is_identity": False,
        "source_discovery": "metadata_only",
        "source_body_reads": 0,
        "source_emission": "not_run",
        "reason": reasons,
    }
    review["schedule_review"] = {"status": "not_run", "reviewer": None, "reason": "No exact lane schedule exists to review"}
    review["security_review"] = {"status": "not_run", "reviewer": None, "reason": "No exact lane schedule exists to review"}
    atomic_json_write(REVIEW_PATH, review)
    readiness = {
        "schema_version": "05.r9.readiness.1",
        "request_id": "R9",
        "status": "not_run_after_metadata_stop",
        "execute_preflight": {"status": "not_run", "reason": "metadata scheduling stopped before both independent reviews"},
        "direct_count": {"status": "not_run", "reason": "no exact serialized request exists"},
        "context_fit": {"status": "not_run", "reason": "direct count was not eligible"},
        "source_emission": "not_run",
        "stop_reasons": reasons,
    }
    atomic_json_write(READINESS_PATH, readiness)
    return {"status": review["status"], "reasons": reasons, "readiness": readiness}


def validate_preflight_receipt() -> dict[str, Any]:
    if not READINESS_PATH.exists():
        raise GateError("05-R9-READINESS.json is missing")
    readiness = load_json(READINESS_PATH)
    review = load_json(REVIEW_PATH)
    if readiness.get("schema_version") != "05.r9.readiness.1":
        raise GateError("readiness schema version mismatch")
    if readiness.get("request_id") != "R9":
        raise GateError("readiness request ID mismatch")
    prior_stopped = review.get("status") == "stopped" and review.get("schedule", {}).get("status") == "not_created"
    if readiness.get("status") == "not_run_after_metadata_stop":
        if not prior_stopped or readiness.get("execute_preflight", {}).get("status") != "not_run" or readiness.get("direct_count", {}).get("status") != "not_run":
            raise GateError("not_run readiness is not justified by an earlier metadata stop")
        if readiness.get("context_fit", {}).get("status") != "not_run" or readiness.get("source_emission") != "not_run":
            raise GateError("context fit and source emission must remain not_run after a metadata stop")
        if readiness.get("stop_reasons") != review.get("stop_reasons"):
            raise GateError("readiness stop reasons differ from the earlier metadata stop")
        return {"status": "valid_not_run_after_prior_stop", "readiness": readiness}
    preflight = readiness.get("execute_preflight", {})
    count = readiness.get("direct_count", {})
    if preflight.get("status") != "passed" or count.get("status") != "passed" or readiness.get("context_fit", {}).get("status") != "passed":
        raise GateError("request readiness receipts are incomplete or failed")
    return {"status": "passed", "readiness": readiness}


def validate_one_use_gate() -> dict[str, Any]:
    review = load_json(REVIEW_PATH)
    readiness_result = validate_preflight_receipt()
    readiness = readiness_result["readiness"]
    gate = load_json(GATE_PATH)
    review_hash = stream_hash(REVIEW_PATH)["sha256"]
    readiness_hash = stream_hash(READINESS_PATH)["sha256"]
    sub_hashes = {
        "schedule_review": canonical_hash(review.get("schedule_review")),
        "security_review": canonical_hash(review.get("security_review")),
        "execute_preflight": canonical_hash(readiness.get("execute_preflight")),
        "direct_count": canonical_hash(readiness.get("direct_count")),
    }
    if gate.get("schema_version") != "05.r9.one-use-gate.1":
        raise GateError("one-use gate schema version mismatch")
    if gate.get("request_id") != "R9":
        raise GateError("one-use gate request ID mismatch")
    if gate.get("review_file_sha256") != review_hash or gate.get("readiness_file_sha256") != readiness_hash:
        raise GateError("one-use gate top-level receipt hash mismatch")
    if gate.get("subreceipt_sha256") != sub_hashes:
        raise GateError("one-use gate canonical subreceipt hash mismatch")
    if gate.get("selected_scope_payload_sha256") != review.get("scope_payload_sha256"):
        raise GateError("one-use gate selected-scope hash mismatch")
    if gate.get("status") == "denied_before_count":
        if review.get("status") != "stopped" or readiness_result["status"] != "valid_not_run_after_prior_stop":
            raise GateError("denied gate lacks a valid earlier stop")
        if gate.get("request_consumed") is not False or gate.get("denial_reasons") != review.get("stop_reasons"):
            raise GateError("denied gate consumption/reasons differ from the earlier metadata stop")
        if gate.get("source_emission") != "not_run" or gate.get("source_span_sha256s") != {} or gate.get("serialized_request_sha256") is not None:
            raise GateError("denied gate contains source emission bindings")
        return {"status": "valid_denial", "gate": gate}
    raise GateError("one-use gate is not a valid denial; this plan did not authorize emission in this run")


def finalize_stopped() -> dict[str, Any]:
    if not REVIEW_PATH.exists() or not READINESS_PATH.exists():
        raise GateError("scope review/readiness must exist before a stopped gate can be recorded")
    review = load_json(REVIEW_PATH)
    readiness = validate_preflight_receipt()["readiness"]
    if review.get("status") != "stopped" or review.get("schedule", {}).get("status") != "not_created":
        raise GateError("refusing to finalize a denial without the exact metadata stop")
    subreceipt_hashes = {
        "schedule_review": canonical_hash(review.get("schedule_review")),
        "security_review": canonical_hash(review.get("security_review")),
        "execute_preflight": canonical_hash(readiness.get("execute_preflight")),
        "direct_count": canonical_hash(readiness.get("direct_count")),
    }
    gate = {
        "schema_version": "05.r9.one-use-gate.1",
        "request_id": "R9",
        "status": "denied_before_count",
        "source_emission": "not_run",
        "review_file_sha256": stream_hash(REVIEW_PATH)["sha256"],
        "readiness_file_sha256": stream_hash(READINESS_PATH)["sha256"],
        "subreceipt_sha256": subreceipt_hashes,
        "selected_scope_payload_sha256": review.get("scope_payload_sha256"),
        "source_span_sha256s": {},
        "serialized_request_sha256": None,
        "request_consumed": False,
        "denial_reasons": review.get("stop_reasons", []),
    }
    atomic_json_write(GATE_PATH, gate)
    gaps, _ = read_jsonl(ROOT / GAPS_PATH)
    selected_rows = [row for row in gaps if row.get("gap_key") in EXPECTED_KEYS]
    result = {
        "schema_version": "05.r9.result.1",
        "request_id": "R9",
        "status": "stopped",
        "source_emission": "not_run",
        "request_consumption": "not_consumed",
        "static_only": True,
        "selected_gap_keys": list(EXPECTED_KEYS),
        "selected_unresolved_rows": [
            {
                "gap_key": row["gap_key"],
                "lane": row["lane"],
                "domain": row["domain"],
                "reason": review.get("stop_reasons", []),
                "source_path": None,
                "source_sha256": None,
                "source_span": None,
                "source_body_reads": 0,
            }
            for row in selected_rows
        ],
        "complement": review.get("complement"),
        "scope_payload_sha256": review.get("scope_payload_sha256"),
        "review_sha256": stream_hash(REVIEW_PATH)["sha256"],
        "readiness_sha256": stream_hash(READINESS_PATH)["sha256"],
        "one_use_gate_sha256": stream_hash(GATE_PATH)["sha256"],
        "stop_reasons": review.get("stop_reasons", []),
        "candidate": None,
        "implementation_authorized": False,
        "aggregate_gate": "open",
        "actual_library_collision": "unknown",
        "macro_caller_ast": "unresolved",
        "macro_explanation": "unresolved",
        "sec_01": "Pending",
        "walking_skeleton": "blocked",
        "legacy_digest": "unresolved",
        "source_access": "closed",
        "source_discovery": "metadata_only",
        "source_body_reads": 0,
    }
    atomic_json_write(RESULT_PATH, result)
    return {"status": "stopped_receipts_written", "request_consumed": False, "source_emission": "not_run", "gate": gate, "result": result}


def validate_result_payload(
    result: dict[str, Any],
    review: dict[str, Any],
    readiness: dict[str, Any],
    gate: dict[str, Any],
    hashes: dict[str, str],
) -> None:
    expected_state = {
        "schema_version": "05.r9.result.1",
        "request_id": "R9",
        "status": "stopped",
        "source_emission": "not_run",
        "request_consumption": "not_consumed",
        "static_only": True,
        "candidate": None,
        "implementation_authorized": False,
        "aggregate_gate": "open",
        "actual_library_collision": "unknown",
        "macro_caller_ast": "unresolved",
        "macro_explanation": "unresolved",
        "sec_01": "Pending",
        "walking_skeleton": "blocked",
        "legacy_digest": "unresolved",
        "source_access": "closed",
        "source_discovery": "metadata_only",
        "source_body_reads": 0,
    }
    for field, expected in expected_state.items():
        if result.get(field) != expected:
            raise GateError(f"result weakened or changed preserved field {field}")
    reasons = review.get("stop_reasons")
    if not isinstance(reasons, list) or not reasons or result.get("stop_reasons") != reasons:
        raise GateError("result stop reasons differ from the exact metadata stop")
    if result.get("selected_gap_keys") != list(EXPECTED_KEYS):
        raise GateError("result does not preserve the exact four selected gap keys")
    if result.get("complement") != review.get("complement"):
        raise GateError("result pending complement differs from the validated review")
    complement = review.get("complement", {})
    if complement.get("count") != EXPECTED_COMPLEMENT_COUNT:
        raise GateError("result pending complement count mismatch")
    if result.get("scope_payload_sha256") != review.get("scope_payload_sha256"):
        raise GateError("result scope payload hash differs from the validated review")
    for field in ("review_sha256", "readiness_sha256", "one_use_gate_sha256"):
        hash_key = {"review_sha256": "review", "readiness_sha256": "readiness", "one_use_gate_sha256": "gate"}[field]
        if result.get(field) != hashes.get(hash_key):
            raise GateError(f"result {field} mismatch")
    if readiness.get("status") != "not_run_after_metadata_stop" or readiness.get("source_emission") != "not_run":
        raise GateError("result is not backed by a stopped readiness receipt")
    if readiness.get("schema_version") != "05.r9.readiness.1":
        raise GateError("result is not backed by the expected readiness schema")
    if gate.get("status") != "denied_before_count" or gate.get("request_consumed") is not False:
        raise GateError("result is not backed by an unconsumed denied one-use gate")
    if gate.get("schema_version") != "05.r9.one-use-gate.1":
        raise GateError("result is not backed by the expected one-use gate schema")
    if gate.get("source_emission") != "not_run" or gate.get("denial_reasons") != reasons:
        raise GateError("one-use gate outcome differs from the exact metadata stop")
    rows = result.get("selected_unresolved_rows")
    if not isinstance(rows, list) or [row.get("gap_key") for row in rows] != list(EXPECTED_KEYS):
        raise GateError("result unresolved rows do not match the exact four selected keys")
    for row in rows:
        expected_parts = row["gap_key"].split("|")
        if len(expected_parts) != 6:
            raise GateError(f"result contains a malformed selected gap key: {row.get('gap_key')!r}")
        if row.get("lane") != expected_parts[0] or row.get("domain") != expected_parts[5]:
            raise GateError(f"result unresolved row lane/domain mismatch: {row['gap_key']}")
        if row.get("reason") != reasons:
            raise GateError(f"result unresolved row reason mismatch: {row['gap_key']}")
        if any(row.get(field) is not None for field in ("source_path", "source_sha256", "source_span")):
            raise GateError(f"result unexpectedly claims a source identity/span: {row['gap_key']}")
        if row.get("source_body_reads") != 0:
            raise GateError(f"result source-body read count changed: {row['gap_key']}")


def validate_result() -> dict[str, Any]:
    if not RESULT_PATH.exists():
        raise GateError("05-R9-RESULT.json is missing")
    bound = validate_saved_scope()
    readiness_result = validate_preflight_receipt()
    gate_result = validate_one_use_gate()
    result = load_json(RESULT_PATH)
    hashes = {
        "review": stream_hash(REVIEW_PATH)["sha256"],
        "readiness": stream_hash(READINESS_PATH)["sha256"],
        "gate": stream_hash(GATE_PATH)["sha256"],
    }
    validate_result_payload(
        result,
        bound["saved"],
        readiness_result["readiness"],
        gate_result["gate"],
        hashes,
    )
    order = result.get("validation_order")
    if not isinstance(order, list) or len(order) < 12:
        raise GateError("result validation_order is incomplete")
    required_commands = {
        "scope-self-test": "passed",
        "exact-scope": "passed",
        "phase4-freshness-reuse": "passed",
        "metadata-schedule": "stopped_as_planned",
        "schedule-review": "not_run_after_metadata_stop",
        "security-review": "not_run_after_metadata_stop",
        "request-execute-preflight": "not_run_after_metadata_stop",
        "direct-count": "not_run_after_metadata_stop",
        "one-use-gate": "passed_denied_before_count",
        "result-shape": "passed",
        "phase5-whitespace": "passed",
        "git-diff-check": "passed",
    }
    observed = {entry.get("check"): entry.get("status") for entry in order}
    for check, status in required_commands.items():
        if observed.get(check) != status:
            raise GateError(f"result validation history missing {check}={status}")
    return result


def record_validation_history() -> dict[str, Any]:
    self_test = self_test_scope()
    bound = validate_saved_scope()
    review = bound["saved"]
    if review.get("status") != "stopped" or review.get("schedule", {}).get("status") != "not_created":
        raise GateError("validation history requires the recorded metadata stop")
    preflight = validate_preflight_receipt()
    gate = validate_one_use_gate()
    result = load_json(RESULT_PATH)
    if result.get("request_id") != "R9" or result.get("source_emission") != "not_run":
        raise GateError("validation history requires a non-emitted R9 stop result")
    whitespace = validate_whitespace()
    diff_check = subprocess.run(["git", "diff", "--check"], cwd=ROOT, capture_output=True, text=True)
    if diff_check.returncode != 0:
        raise GateError(f"git diff --check failed: {diff_check.stdout}{diff_check.stderr}")
    order = [
        {"check": "scope-self-test", "command": "python3 05-validate-evidence.py --self-test --scope", "status": "passed", "controls": self_test["checks"]},
        {"check": "exact-scope", "command": "python3 05-validate-evidence.py --scope", "status": "passed", "selected_rows": 4, "complement_count": review["complement"]["count"]},
        {"check": "phase4-freshness-reuse", "command": "reuse saved 04-VALIDATION.json receipt; no broad --all rerun", "status": "passed", "input_count": review["phase4_validation"]["input_count"]},
        {"check": "metadata-schedule", "command": "python3 05-validate-evidence.py --metadata-schedule", "status": "stopped_as_planned", "source_emission": "not_run"},
        {"check": "schedule-review", "status": "not_run_after_metadata_stop"},
        {"check": "security-review", "status": "not_run_after_metadata_stop"},
        {"check": "request-execute-preflight", "command": "per-request Phase 5 preflight", "status": "not_run_after_metadata_stop", "phase_execute_preflight": "passed"},
        {"check": "direct-count", "status": "not_run_after_metadata_stop", "generation": False},
        {"check": "one-use-gate", "command": "python3 05-validate-evidence.py --one-use-gate", "status": "passed_denied_before_count", "request_consumed": False},
        {"check": "result-shape", "status": "passed", "source_emission": "not_run"},
        {"check": "phase5-whitespace", "command": "python3 05-validate-evidence.py --whitespace", "status": "passed", "file_count": whitespace["file_count"]},
        {"check": "git-diff-check", "command": "git diff --check", "status": "passed", "exit_code": diff_check.returncode},
        {"check": "phase3-suites", "status": "not_run_by_plan", "reason": "evidence-only metadata scope; suites do not establish source identity or caller closure"},
    ]
    result["validation_order"] = order
    result["preflight_receipt_validation"] = preflight["status"]
    result["one_use_gate_validation"] = gate["status"]
    atomic_json_write(RESULT_PATH, result)
    return {"status": "validation_history_recorded", "checks": len(order), "one_use_gate": gate["status"], "source_emission": "not_run"}


def reject_fixture(name: str, fn) -> None:
    try:
        fn()
    except GateError:
        return
    raise AssertionError(f"negative control unexpectedly passed: {name}")


def self_test_scope() -> dict[str, Any]:
    live = evaluate_scope()
    rows, lines = read_jsonl(ROOT / GAPS_PATH)
    tests: list[str] = []
    # Exact valid fixture is the complete, currently bound 9,716-row generation.
    validate_partition_rows(rows, lines)
    tests.append("exact live scope and 9,712-row complement")

    duplicate_rows, duplicate_lines = copy.deepcopy(rows), list(lines)
    duplicate_rows.append(copy.deepcopy(rows[0]))
    duplicate_lines.append(lines[0])
    reject_fixture("duplicate gap key", lambda: validate_partition_rows(duplicate_rows, duplicate_lines))
    tests.append("duplicate gap key rejected")

    unexpected_rows, unexpected_lines = copy.deepcopy(rows), list(lines)
    extra = copy.deepcopy(next(row for row in unexpected_rows if row.get("original_id") != "EX-177"))
    extra["gap_key"] = "core|EX-177|Elixir.Mix.Tasks.Phx.Gen.Context|prompt_for_code_injection|1|unexpected"
    extra["original_id"] = "EX-177"
    unexpected_rows.append(extra)
    unexpected_lines.append((json.dumps(extra, sort_keys=True, separators=(",", ":")).encode() + b"\n"))
    reject_fixture("extra EX-177 key", lambda: validate_partition_rows(unexpected_rows, unexpected_lines))
    tests.append("extra EX-177 key rejected")

    missing_rows, missing_lines = list(rows), list(lines)
    selected_index = next(i for i, row in enumerate(missing_rows) if row.get("gap_key") == EXPECTED_KEYS[0])
    del missing_rows[selected_index]
    del missing_lines[selected_index]
    reject_fixture("missing selected row", lambda: validate_partition_rows(missing_rows, missing_lines))
    tests.append("missing selected row rejected")

    wrong_lane_rows, wrong_lane_lines = copy.deepcopy(rows), list(lines)
    row = wrong_lane_rows[selected_index]
    row["gap_key"] = row["gap_key"].replace("core|", "floor|", 1)
    wrong_lane_lines[selected_index] = (json.dumps(row, sort_keys=True, separators=(",", ":")).encode() + b"\n")
    reject_fixture("wrong lane", lambda: validate_partition_rows(wrong_lane_rows, wrong_lane_lines))
    tests.append("wrong lane rejected")

    wrong_generation_rows, wrong_generation_lines = copy.deepcopy(rows), list(lines)
    row = next(r for r in wrong_generation_rows if r.get("gap_key") == EXPECTED_KEYS[0])
    index = wrong_generation_rows.index(row)
    row["generation"] = "stale"
    wrong_generation_lines[index] = (json.dumps(row, sort_keys=True, separators=(",", ":")).encode() + b"\n")
    reject_fixture("stale generation", lambda: validate_partition_rows(wrong_generation_rows, wrong_generation_lines))
    tests.append("stale generation rejected")

    reject_fixture(
        "wrong complement count",
        lambda: validate_partition_rows(rows, lines, expected_complement_count=EXPECTED_COMPLEMENT_COUNT - 1),
    )
    tests.append("wrong complement count rejected")

    ids = [f"ID-{i:03}" for i in range(226)]
    validate_identity_membership("core", ids, list(ids), 226)
    reject_fixture("wrong Phase 3 membership", lambda: validate_identity_membership("core", ids[:-1], ids, 226))
    tests.append("wrong Phase 3 identity membership rejected")
    validate_exact_mfa("core", "live_mfas", [MFA])
    reject_fixture("second MFA", lambda: validate_exact_mfa("core", "live_mfas", [MFA, ["Other", "target", 1]]))
    tests.append("second MFA rejected")

    reject_fixture(
        "duplicate JSON property",
        lambda: parse_json_bytes(b'{"gap_key":"a","gap_key":"b"}', "fixture"),
    )
    tests.append("duplicate JSON property rejected")

    reject_fixture(
        "input hash mismatch",
        lambda: compare_hash_fixture({"sha256": "0" * 64}, {"sha256": "1" * 64}),
    )
    tests.append("input hash mismatch rejected")
    result_tests = self_test_result_payload()
    tests.extend(result_tests)
    return {"status": "passed", "checks": len(tests), "tests": tests, "live_scope_payload_sha256": live["scope_payload_sha256"]}


def compare_hash_fixture(expected: dict[str, Any], observed: dict[str, Any]) -> None:
    if expected.get("sha256") != observed.get("sha256"):
        raise GateError("fixture hash mismatch")


def self_test_result_payload() -> list[str]:
    if not RESULT_PATH.exists():
        raise GateError("cannot test final result invariants without the saved stopped receipt")
    bound = validate_saved_scope()
    readiness = validate_preflight_receipt()["readiness"]
    gate = validate_one_use_gate()["gate"]
    result = load_json(RESULT_PATH)
    hashes = {
        "review": stream_hash(REVIEW_PATH)["sha256"],
        "readiness": stream_hash(READINESS_PATH)["sha256"],
        "gate": stream_hash(GATE_PATH)["sha256"],
    }
    validate_result_payload(result, bound["saved"], readiness, gate, hashes)
    tests = ["valid stopped result and receipt hashes accepted"]

    mutations = [
        ("wrong final complement digest", lambda r: r["complement"].update(sha256="0" * 64)),
        ("changed aggregate stop", lambda r: r.update(aggregate_gate="closed")),
        ("changed collision stop", lambda r: r.update(actual_library_collision="none")),
        ("changed SEC-01 stop", lambda r: r.update(sec_01="Cleared")),
        ("changed Walking Skeleton stop", lambda r: r.update(walking_skeleton="unblocked")),
        ("changed legacy digest stop", lambda r: r.update(legacy_digest="resolved")),
        ("changed Macro checkpoint", lambda r: r.update(macro_caller_ast="resolved")),
        ("changed candidate/implementation stop", lambda r: r.update(candidate="promoted", implementation_authorized=True)),
        ("consumed request state", lambda r: r.update(request_consumption="consumed")),
        ("source emission state", lambda r: r.update(source_emission="emitted")),
        ("source access/read count", lambda r: r.update(source_access="open", source_body_reads=99)),
        ("changed unresolved row source span", lambda r: r["selected_unresolved_rows"][0].update(source_path="lib/target.ex")),
        ("changed review hash", lambda r: r.update(review_sha256="0" * 64)),
        ("changed result schema", lambda r: r.update(schema_version="99.r9.result.1")),
    ]
    for name, mutate in mutations:
        fixture = copy.deepcopy(result)
        mutate(fixture)
        reject_fixture(
            name,
            lambda fixture=fixture: validate_result_payload(fixture, bound["saved"], readiness, gate, hashes),
        )
        tests.append(f"{name} rejected")
    bad_readiness = copy.deepcopy(readiness)
    bad_readiness["schema_version"] = "99.r9.readiness.1"
    reject_fixture(
        "changed readiness schema",
        lambda: validate_result_payload(result, bound["saved"], bad_readiness, gate, hashes),
    )
    tests.append("changed readiness schema rejected")
    bad_gate = copy.deepcopy(gate)
    bad_gate["schema_version"] = "99.r9.one-use-gate.1"
    reject_fixture(
        "changed one-use gate schema",
        lambda: validate_result_payload(result, bound["saved"], readiness, bad_gate, hashes),
    )
    tests.append("changed one-use gate schema rejected")
    return tests


def validate_whitespace() -> dict[str, Any]:
    failures: list[str] = []
    files = sorted(p for p in PHASE.iterdir() if p.is_file())
    for path in files:
        try:
            raw = path.read_bytes()
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            failures.append(f"{path.name}: non-UTF-8 artifact")
            continue
        for number, line in enumerate(text.splitlines(), 1):
            if line.rstrip(" \t") != line:
                failures.append(f"{path.name}:{number}: trailing whitespace")
                break
        if raw and not raw.endswith(b"\n"):
            failures.append(f"{path.name}: missing final LF")
    if failures:
        raise GateError("Phase 5 whitespace check failed: " + "; ".join(failures))
    return {"status": "passed", "file_count": len(files), "files": [p.name for p in files]}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--initialize-scope", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--scope", action="store_true")
    parser.add_argument("--metadata-schedule", action="store_true")
    parser.add_argument("--execute-preflight-receipt", action="store_true")
    parser.add_argument("--one-use-gate", action="store_true")
    parser.add_argument("--finalize-stopped", action="store_true")
    parser.add_argument("--result", action="store_true")
    parser.add_argument("--record-validation-history", action="store_true")
    parser.add_argument("--whitespace", action="store_true")
    args = parser.parse_args()
    try:
        if args.initialize_scope:
            print(json.dumps(initialize_scope(), sort_keys=True))
        elif args.self_test and args.scope:
            print(json.dumps(self_test_scope(), sort_keys=True))
        elif args.scope:
            checked = validate_saved_scope()
            print(json.dumps({"status": "passed", "scope_status": checked["saved"].get("scope_status"), "selected_rows": 4, "complement_count": checked["saved"]["complement"]["count"], "complement_sha256": checked["saved"]["complement"]["sha256"], "phase4_input_count": checked["saved"]["phase4_validation"]["input_count"], "source_access": "closed"}, sort_keys=True))
        elif args.metadata_schedule:
            print(json.dumps(stop_for_missing_metadata(), sort_keys=True))
        elif args.execute_preflight_receipt:
            print(json.dumps(validate_preflight_receipt(), sort_keys=True))
        elif args.one_use_gate:
            print(json.dumps(validate_one_use_gate(), sort_keys=True))
        elif args.finalize_stopped:
            print(json.dumps(finalize_stopped(), sort_keys=True))
        elif args.result:
            print(json.dumps(validate_result(), sort_keys=True))
        elif args.record_validation_history:
            print(json.dumps(record_validation_history(), sort_keys=True))
        elif args.whitespace:
            print(json.dumps(validate_whitespace(), sort_keys=True))
        else:
            parser.error("select one gate; --self-test requires --scope")
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
