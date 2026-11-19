#!/usr/bin/env python3
"""Read-only metadata and fail-closed gate checks for Phase 4 evidence artifacts."""
import argparse
import hashlib
import json
import os
import tempfile
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[3]
PH3 = ROOT / ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
PH4 = ROOT / ".planning/phases/04-evidence-only-source-and-gap-provenance-closure"
ORIGINAL_MANIFEST = PH4 / "04-PROVENANCE-MANIFEST-04-01-ORIGINAL.json"
ENV04_LEDGER = PH4 / "04-RESOURCE-LEDGER-ENV04-STOP.json"
PRESERVATION_BRIDGE = PH4 / "04-PRESERVATION-PROVENANCE-BRIDGE.json"
ACTIVE_SCHEDULE = PH4 / "04-R1-SCHEDULE.json"
CALLER_TRACE = PH4 / "04-COVERAGE-CALLER-TRACE.json"
DIGEST_PROOF = PH4 / "04-SIZING-DIGEST-PROOF.json"
VALIDATION = PH4 / "04-VALIDATION.json"
REQUEST_GATE = PH4 / "04-R1-REQUEST-GATE.json"
EVIDENCE_REVIEW = PH4 / "04-EVIDENCE-REVIEW.json"
SESSION_LOG = Path.home().joinpath(".codex", "sessions", "2026", "11", "16", "rollout-2026-11-16T21-47-09-01a1e766-afb2-77a1-8977-350fde6d15dd.jsonl")
POST_SNAPSHOT_PATHS = {
    "test/contract/tier_sweep_test.exs",
    "test/support/guard_aggregate_reconciliation_evidence.ex",
}
ADDITIONAL_REBIND_PATHS = {
    ".planning/forensics/phase4-budget-reset-20261117.md",
    ".planning/phases/04-evidence-only-source-and-gap-provenance-closure/04-01-PLAN.md",
}
PRIMARY_REBIND_PATH = ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-PLAN.md"
SOURCE_SELECTION_DELIMITER = "\n\n# Exact scheduled source selection\n"
SOURCE_REQUEST_IDS = ("R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8")


def request_artifact_path(request_id, suffix):
    if request_id not in SOURCE_REQUEST_IDS:
        raise ValueError("unsupported exact source request id")
    return PH4 / f"04-{request_id}-{suffix}.json"


def _unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON object key: " + key)
        result[key] = value
    return result


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=_unique_object)


def read_jsonl(path):
    rows = []
    with path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                raise ValueError("blank JSONL line at " + str(line_number))
            rows.append((line_number, json.loads(line, object_pairs_hook=_unique_object)))
    return rows


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def json_sha256(value):
    payload = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()


def safe_path(value, root=ROOT):
    if not isinstance(value, str) or not value or "\\" in value or ":" in value:
        raise ValueError("unsafe relative path")
    posix = PurePosixPath(value)
    if posix.is_absolute() or ".." in posix.parts or "." in posix.parts:
        raise ValueError("unsafe relative path")
    resolved_root = root.resolve()
    resolved = (root / Path(*posix.parts)).resolve()
    try:
        resolved.relative_to(resolved_root)
    except ValueError as exc:
        raise ValueError("path escapes reviewed root") from exc
    return resolved


def mfa_key(value):
    if not isinstance(value, list) or len(value) != 3:
        raise ValueError("MFA must be [module, function, integer_arity]")
    if not isinstance(value[0], str) or not isinstance(value[1], str):
        raise ValueError("MFA names must be strings")
    if isinstance(value[2], bool) or not isinstance(value[2], int):
        raise ValueError("MFA arity must be an integer, not boolean")
    return (value[0], value[1], value[2])


def exact_partition(expected, associations, source_gaps):
    if len(associations) != len(set(associations)) or len(source_gaps) != len(set(source_gaps)):
        raise ValueError("duplicate partition key")
    assoc, gaps = set(associations), set(source_gaps)
    if assoc & gaps:
        raise ValueError("association and source-gap partitions overlap")
    if assoc | gaps != set(expected):
        raise ValueError("partition has missing, extra, replaced, or wrong-lane keys")
    return True


def exact_unknown(expected, observed):
    if len(observed) != len(set(observed)) or set(expected) != set(observed):
        raise ValueError("unknown target-set identities were dropped or fabricated")
    return True


def source_closed(value):
    if value != "closed":
        raise ValueError("source gate is not closed")
    return True


def validate_snapshot_advance(record, original, current_sha256, current_bytes):
    if (record.get("snapshot_sha256") != original.get("current_sha256")
            or record.get("snapshot_bytes") != original.get("current_bytes")
            or record.get("current_sha256") != current_sha256
            or record.get("current_bytes") != current_bytes
            or not isinstance(current_sha256, str) or len(current_sha256) != 64
            or type(current_bytes) is not int or current_bytes < 0):
        raise ValueError("post-snapshot file binding differs from its preserved snapshot or current bytes")
    return True


def validate_exact_paths(records, expected_paths, label):
    if not isinstance(records, list):
        raise ValueError(label + " is not a list")
    paths = []
    for record in records:
        if not isinstance(record, dict) or not isinstance(record.get("path"), str):
            raise ValueError(label + " contains a row without a string path")
        paths.append(record["path"])
    if (len(paths) != len(expected_paths) or len(paths) != len(set(paths))
            or set(paths) != set(expected_paths)):
        raise ValueError(label + " has missing, duplicate, or unapproved paths")
    return True


def validate_input_rebind(binding, historical, current_sha256, current_bytes):
    if (binding.get("path") != historical.get("path")
            or binding.get("original_sha256") != historical.get("sha256")
            or binding.get("original_bytes") != historical.get("bytes")
            or binding.get("current_sha256") != current_sha256
            or binding.get("current_bytes") != current_bytes
            or not isinstance(current_sha256, str) or len(current_sha256) != 64
            or type(current_bytes) is not int or current_bytes < 0):
        raise ValueError("metadata input rebind differs from its original or current bytes")
    return True


def validate_preservation_snapshot(item, current_sha256, current_bytes, advance=None):
    if advance is None:
        if (current_sha256 != item.get("current_sha256")
                or current_bytes != item.get("current_bytes")):
            raise ValueError("preservation snapshot differs from current bytes")
        snapshot_sha256 = current_sha256
    else:
        validate_snapshot_advance(advance, item, current_sha256, current_bytes)
        snapshot_sha256 = item.get("current_sha256")
    if (snapshot_sha256 == item.get("expected_sha256")) != item.get("matches"):
        raise ValueError("preservation match status differs from its recorded snapshot")
    return snapshot_sha256


def consumed_source_binding_matches(source_sha256, current_sha256, active_sha256, advance=None):
    if active_sha256 != current_sha256:
        return False
    if advance is None:
        return source_sha256 == current_sha256
    return (advance.get("current_sha256") == current_sha256
            and source_sha256 in (advance.get("snapshot_sha256"), current_sha256))


def validate_consumed_source_binding(source_sha256, current_sha256, active_sha256, advance=None):
    if not consumed_source_binding_matches(source_sha256, current_sha256, active_sha256, advance):
        raise ValueError("consumed source hash is neither current nor the reviewed historical snapshot")
    return True


def self_test():
    checks = 0

    def rejects(call):
        nonlocal checks
        try:
            call()
        except (ValueError, OSError):
            checks += 1
            return
        raise AssertionError("negative control unexpectedly passed")

    rejects(lambda: json.loads('{"a":1,"a":2}', object_pairs_hook=_unique_object))
    rejects(lambda: mfa_key(["Mod", "fun", True]))
    rejects(lambda: safe_path("../escape"))
    rejects(lambda: safe_path("/absolute"))
    rejects(lambda: safe_path("C:\\escape"))
    with tempfile.TemporaryDirectory() as temporary:
        base = Path(temporary)
        outside = base / "outside"
        outside.mkdir()
        root = base / "root"
        root.mkdir()
        link = root / "escape"
        try:
            link.symlink_to(outside, target_is_directory=True)
            rejects(lambda: safe_path("escape/file", root))
        except (NotImplementedError, OSError):
            pass
    key = ("core", "EX-001", ("Elixir.Mod", "run", 1))
    if not exact_partition([key], [], [key]):
        raise AssertionError("complete unresolved fixture failed")
    checks += 1
    rejects(lambda: exact_partition([key], [], []))
    rejects(lambda: exact_partition([key], [], [("floor", "EX-001", ("Elixir.Mod", "run", 1))]))
    rejects(lambda: exact_partition([key], [key], [key]))
    rejects(lambda: exact_partition([key], [], [key, key]))
    rejects(lambda: exact_unknown(["EX-001", "CN-001"], ["EX-001"]))
    if sorted(("baseline", "live")) != sorted(set(("baseline", "live"))):
        raise AssertionError("overlapping membership roles were lost")
    checks += 1
    rejects(lambda: source_closed("open"))
    if hashlib.sha256(b"old").hexdigest() == hashlib.sha256(b"new").hexdigest():
        raise AssertionError("stale-hash control failed")
    checks += 1
    snapshot = {"current_sha256": "a" * 64, "current_bytes": 2}
    advance = {"snapshot_sha256": "a" * 64, "snapshot_bytes": 2,
               "current_sha256": "b" * 64, "current_bytes": 3}
    validate_snapshot_advance(advance, snapshot, "b" * 64, 3)
    checks += 1
    rejects(lambda: validate_snapshot_advance(
        {**advance, "snapshot_sha256": "c" * 64}, snapshot, "b" * 64, 3))
    rejects(lambda: validate_snapshot_advance(advance, snapshot, "d" * 64, 3))
    exact_rows = [{"path": "one"}, {"path": "two"}]
    validate_exact_paths(exact_rows, {"one", "two"}, "test fixture")
    checks += 1
    rejects(lambda: validate_exact_paths([{"path": "one"}, {"path": "one"}],
                                         {"one", "two"}, "test fixture"))
    rejects(lambda: validate_exact_paths([{"path": "one"}], {"one", "two"}, "test fixture"))
    input_snapshot = {"path": "plan.md", "sha256": "a" * 64, "bytes": 2}
    input_rebind = {"path": "plan.md", "original_sha256": "a" * 64,
                    "original_bytes": 2, "current_sha256": "b" * 64,
                    "current_bytes": 3}
    validate_input_rebind(input_rebind, input_snapshot, "b" * 64, 3)
    checks += 1
    rejects(lambda: validate_input_rebind(
        {**input_rebind, "original_sha256": "c" * 64}, input_snapshot, "b" * 64, 3))
    rejects(lambda: validate_input_rebind(input_rebind, input_snapshot, "d" * 64, 3))
    preserved = {"expected_sha256": "0" * 64, "current_sha256": "a" * 64,
                 "current_bytes": 2, "matches": False}
    advance_preserved = {"snapshot_sha256": "a" * 64, "snapshot_bytes": 2,
                         "current_sha256": "b" * 64, "current_bytes": 3}
    if validate_preservation_snapshot(preserved, "b" * 64, 3, advance_preserved) != "a" * 64:
        raise AssertionError("post-snapshot preservation did not retain the historical mismatch")
    checks += 1
    rejects(lambda: validate_preservation_snapshot(
        preserved, "b" * 64, 3, {**advance_preserved, "snapshot_sha256": "c" * 64}))
    rejects(lambda: validate_preservation_snapshot(preserved, "b" * 64, 3))
    reviewed_change = {"snapshot_sha256": "a" * 64, "current_sha256": "b" * 64}
    if not consumed_source_binding_matches("a" * 64, "b" * 64, "b" * 64, reviewed_change):
        raise AssertionError("consumed historical source hash did not match the reviewed overlay")
    checks += 1
    rejects(lambda: validate_consumed_source_binding("c" * 64, "b" * 64, "b" * 64, reviewed_change))
    rejects(lambda: validate_consumed_source_binding("b" * 64, "b" * 64, "d" * 64, reviewed_change))
    consumed_request = {"request_id":"R2","context_bytes":20,"source_bytes":40,"context_sha256":"a" * 64,
                        "source_sha256":"b" * 64,"source_span":{"span_sha256":"c" * 64}}
    consumed_schedule = {"sha256":"d" * 64,"generation":"fixture","request":consumed_request}
    consumed_count = {"status":"pass","generation":"fixture","request_id":"R2",
                      "payload_bytes":20+len(SOURCE_SELECTION_DELIMITER.encode())+40,
                      "serialized_request_bytes":100,"serialized_request_sha256":"e" * 64,
                      "serialized_input_tokens":10,"generated":False,
                      "generation_endpoint_called":False,"payload_truncated":False,
                      "fits_configured_context":True,"schedule_sha256":"d" * 64,
                      "source_sha256":"b" * 64,"source_span":consumed_request["source_span"],
                      "context_sha256":"a" * 64}
    if consumed_count_payload_blockers(consumed_schedule, consumed_count):
        raise AssertionError("historical consumed-count receipt fixture failed")
    checks += 1
    rejects(lambda: requires_no_count_blockers(
        consumed_count_payload_blockers(consumed_schedule,{**consumed_count,"status":"fail"})))
    rejects(lambda: requires_no_count_blockers(
        consumed_count_payload_blockers(consumed_schedule,{**consumed_count,"generation":"other"})))
    rejects(lambda: requires_no_count_blockers(
        consumed_count_payload_blockers(consumed_schedule,{**consumed_count,"request_id":"R1"})))
    rejects(lambda: requires_no_count_blockers(
        consumed_count_payload_blockers(consumed_schedule,
                                         {**consumed_count,"payload_bytes":1})))

    def gate_fixture(request_id="R1"):
        generation = "a" * 64
        schedule_hash = "b" * 64
        review_hash = "c" * 64
        preflight_hash = "d" * 64
        source_hash = "e" * 64
        context_hash = "f" * 64
        span = {"start_line": 1, "end_line": 20, "span_sha256": "8" * 64}
        manifest = {"metadata_status": "supported", "partition_outcome": "complete",
                    "generation": generation, "authority": {"status": "corroborated"},
                    "provenance_bridge": {"status": "passed", "sha256": "9" * 64}}
        schedule = {"status": "scheduled", "source_access": "closed",
                    "generation": generation, "sha256": schedule_hash,
                    "created_at_utc": "2026-01-01T00:00:00Z", "author": "executor",
                    "source_file_count": 1,
                    "request": {"request_id": request_id, "status": "scheduled",
                                "candidate_path": "test/support/helper.ex", "source_span": span,
                                "source_bytes": 100, "source_sha256": source_hash,
                                "context_sha256": context_hash}}
        review = {"status": "pass", "reviewer": "independent-reviewer",
                  "created_at_utc": "2026-01-01T00:01:00Z", "generation": generation,
                  "request_id": request_id, "sha256": review_hash, "schedule_sha256": schedule_hash,
                  "source_sha256": source_hash, "source_span": span,
                  "context_sha256": context_hash, "findings": []}
        preflight = {"status": "pass", "created_at_utc": "2026-01-01T00:02:00Z",
                     "generation": generation, "request_id": request_id, "sha256": preflight_hash,
                     "stage": "execute", "phase": "4", "exit_code": 0, "errors": [],
                     "schedule_sha256": schedule_hash, "review_sha256": review_hash,
                     "source_sha256": source_hash, "source_span": span,
                     "context_sha256": context_hash}
        count = {"status": "pass", "counted_at_utc": "2026-01-01T00:03:00Z",
                 "generation": generation, "request_id": request_id, "generated": False,
                 "generation_endpoint_called": False,
                 "payload_truncated": False, "serialized_input_tokens": 1000,
                 "serialized_request_bytes": 2048, "serialized_request_sha256": "7" * 64,
                 "configured_model_context_tokens": 200000, "fits_configured_context": True,
                 "source_sha256": source_hash, "source_span": span,
                 "context_sha256": context_hash, "schedule_sha256": schedule_hash,
                 "review_sha256": review_hash, "preflight_sha256": preflight_hash}
        ledger = {"status": "measured", "measured_at_utc": "2026-01-01T00:04:00Z",
                  "usage_attributed": True, "cumulative_fit": "measured",
                  "source_request_count": 0, "consumed_request_ids": [], "working_ceiling": 610000,
                  "generated_output_ceiling": 650000, "protected_reserve": 40000,
                  "remaining_working_balance": 560000,
                  "post_reset_usage": {"output_tokens": 50000},
                  "aggregate_output_budget_policy": "disabled_by_owner",
                  "task_caps": {"04-02-02": 50000}}
        return [manifest, schedule, review, preflight, count, ledger]

    fixture = gate_fixture()
    fixture[5]["remaining_working_balance"] = -1
    fixture[5]["post_reset_usage"]["output_tokens"] = 900000
    initial_blockers = request_gate_blockers(*fixture, "R1")
    if initial_blockers:
        raise AssertionError("aggregate output history incorrectly blocked a fully bound request: " + "; ".join(initial_blockers))
    checks += 1
    resumed = gate_fixture("R2")
    resumed[5]["source_request_count"] = 1
    resumed[5]["consumed_request_ids"] = ["R1"]
    if request_gate_blockers(*resumed, "R2"):
        raise AssertionError("a fresh exact R2 request was blocked by the prior incomplete R1 delivery")
    checks += 1
    resumed_r3 = gate_fixture("R3")
    resumed_r3[5]["source_request_count"] = 2
    resumed_r3[5]["consumed_request_ids"] = ["R1", "R2"]
    if request_gate_blockers(*resumed_r3, "R3"):
        raise AssertionError("a disjoint exact R3 request was blocked by prior consumed source spans")
    checks += 1
    resumed_r4 = gate_fixture("R4")
    resumed_r4[5]["source_request_count"] = 3
    resumed_r4[5]["consumed_request_ids"] = ["R1", "R2", "R3"]
    if request_gate_blockers(*resumed_r4, "R4"):
        raise AssertionError("a fresh exact R4 request was blocked by prior consumed source spans")
    checks += 1
    resumed_r5 = gate_fixture("R5")
    resumed_r5[5]["source_request_count"] = 4
    resumed_r5[5]["consumed_request_ids"] = ["R1", "R2", "R3", "R4"]
    if request_gate_blockers(*resumed_r5, "R5"):
        raise AssertionError("a fresh exact R5 request was blocked by prior consumed source spans")
    checks += 1
    resumed_r6 = gate_fixture("R6")
    resumed_r6[5]["source_request_count"] = 5
    resumed_r6[5]["consumed_request_ids"] = ["R1", "R2", "R3", "R4", "R5"]
    if request_gate_blockers(*resumed_r6, "R6"):
        raise AssertionError("a fresh targeted R6 request was blocked by prior consumed source spans")
    checks += 1
    resumed_r7 = gate_fixture("R7")
    resumed_r7[5]["source_request_count"] = 6
    resumed_r7[5]["consumed_request_ids"] = ["R1", "R2", "R3", "R4", "R5", "R6"]
    if request_gate_blockers(*resumed_r7, "R7"):
        raise AssertionError("the single authorized R7 request was blocked after the exact R1-R6 prefix")
    checks += 1
    resumed_r8 = gate_fixture("R8")
    resumed_r8[5]["source_request_count"] = 7
    resumed_r8[5]["consumed_request_ids"] = ["R1", "R2", "R3", "R4", "R5", "R6", "R7"]
    if request_gate_blockers(*resumed_r8, "R8"):
        raise AssertionError("the one authorized R8 recovery request was blocked after the exact R1-R7 prefix")
    checks += 1
    if not request_gate_blockers(*gate_fixture("R9"), "R9"):
        raise AssertionError("an unplanned ninth Phase 4 source request was authorized")
    checks += 1
    replayed_r7 = gate_fixture("R7")
    replayed_r7[5]["source_request_count"] = 7
    replayed_r7[5]["consumed_request_ids"] = ["R1", "R2", "R3", "R4", "R5", "R6", "R7"]
    if not request_gate_blockers(*replayed_r7, "R7"):
        raise AssertionError("a consumed R7 request was replayed")
    checks += 1
    replayed_r8 = gate_fixture("R8")
    replayed_r8[5]["source_request_count"] = 8
    replayed_r8[5]["consumed_request_ids"] = ["R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8"]
    if not request_gate_blockers(*replayed_r8, "R8"):
        raise AssertionError("a consumed R8 recovery request was replayed")
    checks += 1
    uncapped = gate_fixture()
    uncapped[4]["serialized_input_tokens"] = 40000
    uncapped[5]["post_reset_usage"]["output_tokens"] = 700000
    uncapped[5]["remaining_working_balance"] = -90000
    uncapped[5]["remaining_total_balance"] = -50000
    uncapped[5]["protected_reserve_preserved"] = False
    if request_gate_blockers(*uncapped, "R1"):
        raise AssertionError("owner-disabled cumulative token ceiling still blocks a fully counted request")
    checks += 1
    informational = gate_fixture()
    informational[5].update({"status": "informational", "measured_at_utc": None,
                             "usage_attributed": False, "cumulative_fit": "unmeasured",
                             "post_reset_usage": {}, "remaining_working_balance": None,
                             "remaining_total_balance": None, "protected_reserve_preserved": None})
    if request_gate_blockers(*informational, "R1"):
        raise AssertionError("informational aggregate counters still block a fully counted request")
    checks += 1
    ready = {"status": "one_use_ready", "source_emission": False,
             "bindings": {"generation": "a" * 64, "request_id": "R1",
                          "schedule_sha256": "b" * 64, "review_sha256": "c" * 64,
                          "preflight_sha256": "d" * 64, "count_sha256": "8" * 64,
                          "source_sha256": "e" * 64, "source_span": {"start_line": 1, "end_line": 20},
                          "context_sha256": "f" * 64,
                          "serialized_request_sha256": "7" * 64}}
    consumed_bindings = dict(ready["bindings"])
    consumed = {"status": "consumed", "request_id": "R1", "source_emission": True,
                "source_request_count": 1, "one_use_ready_receipt": ready,
                "source_emission_receipt": {"status": "consumed_once", "emission_count": 1,
                    "content_used_for_analysis": True, "tool_output_truncated": False,
                    "analysis_complete": True, "one_use_ready_receipt_sha256": hashlib.sha256(
                        json.dumps(ready, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
                    ).hexdigest(), **consumed_bindings}}
    if consumed_receipt_blockers(consumed, ready["bindings"]):
        raise AssertionError("a correctly bound one-use source emission was not recognized")
    r8_span = {"start_byte": 120, "end_byte_exclusive": 127, "span_sha256": "9" * 64}
    r8_ready = json.loads(json.dumps(ready))
    r8_ready["bindings"].update({"request_id": "R8", "source_span": r8_span})
    r8_emission = {**r8_ready["bindings"], "status": "consumed_once", "emission_count": 1,
                   "source_bytes": 7, "source_bytes_delivered": 7,
                   "delivered_span_sha256": r8_span["span_sha256"],
                   "source_body_emitted_once": True, "begin_sentinel_observed": True,
                   "end_sentinel_observed": True, "generation_endpoint_called": False,
                   "content_used_for_analysis": True, "tool_output_truncated": False,
                   "analysis_complete": True,
                   "one_use_ready_receipt_sha256": json_sha256(r8_ready)}
    r8_consumed = {"status": "consumed", "request_id": "R8", "source_emission": True,
                   "source_request_count": 8, "one_use_ready_receipt": r8_ready,
                   "source_emission_receipt": r8_emission}
    if consumed_receipt_blockers(r8_consumed, r8_ready["bindings"]):
        raise AssertionError("a complete R8 delivery with matching bytes/hash was rejected")
    checks += 1
    wrong_r8_size = json.loads(json.dumps(r8_consumed))
    wrong_r8_size["source_emission_receipt"]["source_bytes_delivered"] = 6
    if not consumed_receipt_blockers(wrong_r8_size, r8_ready["bindings"]):
        raise AssertionError("R8 delivery passed with a byte count different from the scheduled span")
    checks += 1
    wrong_r8_hash = json.loads(json.dumps(r8_consumed))
    wrong_r8_hash["source_emission_receipt"]["delivered_span_sha256"] = "0" * 64
    if not consumed_receipt_blockers(wrong_r8_hash, r8_ready["bindings"]):
        raise AssertionError("R8 delivery passed with a span hash different from the scheduled span")
    checks += 1
    missing_r8_sentinel = json.loads(json.dumps(r8_consumed))
    missing_r8_sentinel["source_emission_receipt"]["end_sentinel_observed"] = False
    if not consumed_receipt_blockers(missing_r8_sentinel, r8_ready["bindings"]):
        raise AssertionError("R8 delivery passed without its closing sentinel")
    checks += 1
    incomplete = json.loads(json.dumps(consumed))
    incomplete.update({"status": "consumed_incomplete"})
    incomplete["source_emission_receipt"].update({"status": "consumed_once_delivery_incomplete",
                                                   "tool_output_truncated": True,
                                                   "analysis_complete": False})
    if consumed_receipt_blockers(incomplete, ready["bindings"]) or consumed_receipt_status(incomplete) != "consumed_incomplete":
        raise AssertionError("a truthful truncated one-use delivery was not retained as consumed_incomplete")
    incomplete["source_emission_receipt"]["content_used_for_analysis"] = False
    if consumed_receipt_blockers(incomplete, ready["bindings"]):
        raise AssertionError("an incomplete delivery with no analysis was not recorded truthfully")
    checks += 1
    unverified = json.loads(json.dumps(consumed))
    unverified.update({"status": "consumed_delivery_unverified"})
    unverified["source_emission_receipt"].update({
        "status": "delivery_unverified", "tool_output_truncated": None,
        "analysis_complete": False, "content_used_for_analysis": False,
        "source_body_emitted_once": True, "source_bytes_delivered": None,
        "begin_sentinel_observed": True, "end_sentinel_observed": True})
    if (consumed_receipt_blockers(unverified, ready["bindings"])
            or consumed_receipt_status(unverified) != "consumed_delivery_unverified"):
        raise AssertionError("an emitted but unverified delivery was not preserved without claim use")
    checks += 1
    consumed["source_emission_receipt"]["emission_count"] = 2
    if not consumed_receipt_blockers(consumed, ready["bindings"]):
        raise AssertionError("a repeated source emission passed the one-use check")
    checks += 1
    chunk_source = b"alpha\nbeta\ngamma\n"
    chunk_span = {"start_byte": 0, "end_byte_exclusive": len(chunk_source),
                  "start_line": 1, "end_line": 3}
    chunk_specs = []
    offset = 0
    for index, data in enumerate((b"alpha\n", b"beta\ngamma\n"), start=1):
        first_line = 1 if index == 1 else 2
        last_line = first_line + len(data.splitlines(keepends=True)) - 1
        chunk_specs.append({"index": index, "start_byte": offset,
                            "end_byte_exclusive": offset + len(data),
                            "start_line": first_line, "end_line": last_line,
                            "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()})
        offset += len(data)
    if source_chunk_map_blockers(chunk_source, chunk_span, chunk_specs):
        raise AssertionError("a complete contiguous chunk map was rejected")
    checks += 1
    rejects(lambda: requires_no_count_blockers(
        source_chunk_map_blockers(chunk_source, chunk_span,
                                  [{**chunk_specs[0], "end_byte_exclusive": 5}, chunk_specs[1]])))
    variants = []
    changed = gate_fixture(); changed[2] = {}
    variants.append(changed)
    changed = gate_fixture(); changed[3] = {}
    variants.append(changed)
    changed = gate_fixture(); changed[4] = {}
    variants.append(changed)
    changed = gate_fixture(); changed[4]["source_sha256"] = "0" * 64
    variants.append(changed)
    changed = gate_fixture(); changed[4]["payload_truncated"] = True
    variants.append(changed)
    changed = gate_fixture(); changed[5]["source_request_count"] = 1
    changed[5]["consumed_request_ids"] = ["R1"]
    variants.append(changed)
    changed = gate_fixture(); changed[5]["aggregate_output_budget_policy"] = "capped"
    variants.append(changed)
    changed = gate_fixture(); changed[4]["serialized_request_sha256"] = "invalid"
    variants.append(changed)
    changed = gate_fixture(); changed[4]["configured_model_context_tokens"] = 500
    variants.append(changed)
    changed = gate_fixture(); changed[1]["request"]["source_span"] = None
    variants.append(changed)
    changed = gate_fixture(); changed[3]["created_at_utc"] = "2025-12-31T23:59:00Z"
    variants.append(changed)
    changed = gate_fixture(); changed[1]["request"]["context_sha256"] = "0" * 64
    variants.append(changed)
    for variant_index, invalid in enumerate(variants):
        if not request_gate_blockers(*invalid, "R1"):
            raise AssertionError("request-gate negative control unexpectedly passed: " + str(variant_index))
        checks += 1
    return {"status": "pass", "checks": checks, "writes_repository_inputs": False}


def expected_metadata():
    expected, roles, unknown, ids = {}, {}, {}, {}
    for lane, filename in (("core", "03-CORE-AGGREGATE-EVIDENCE.json"),
                           ("floor", "03-FLOOR-AGGREGATE-EVIDENCE.json")):
        record = read_json(PH3 / filename)
        lane_ids = []
        keys = set()
        empty = []
        for row_index, row in enumerate(record["identity_rows"]):
            identity_id = row["identity"]["id"]
            lane_ids.append(identity_id)
            for role in ("baseline", "live"):
                values = row[role + "_mfas"]
                parsed = [mfa_key(value) for value in values]
                if len(parsed) != len(set(parsed)):
                    raise ValueError("duplicate MFA in " + role + " input")
                if role == "baseline" and not parsed:
                    empty.append(identity_id)
                for value in parsed:
                    key = (lane, identity_id, value)
                    keys.add(key)
                    roles.setdefault(key, set()).add(role)
        if len(lane_ids) != 226 or len(set(lane_ids)) != 226:
            raise ValueError("lane identity set is not 226 unique IDs")
        ids[lane] = lane_ids
        expected[lane] = keys
        unknown[lane] = empty
    return expected, roles, unknown, ids


def check_provenance_bridge():
    bridge = read_json(PRESERVATION_BRIDGE)
    if bridge.get("schema_version") != "04.preservation-bridge.1":
        raise ValueError("unsupported preservation bridge schema")
    source_closed(bridge.get("source_access"))
    if bridge.get("source_body_read") is not False or bridge.get("source_body_emitted") is not False:
        raise ValueError("bridge claims R1 body access")

    originals = bridge.get("original_records", {})
    original_manifest = originals.get("manifest", {})
    original_ledger = originals.get("env04_ledger", {})
    for record, path in ((original_manifest, ORIGINAL_MANIFEST), (original_ledger, ENV04_LEDGER)):
        if record.get("path") != path.relative_to(ROOT).as_posix() or sha256(path) != record.get("sha256"):
            raise ValueError("immutable Phase 4 stop record is missing or changed")
    transfer = bridge.get("transfer_receipt", {})
    readiness = bridge.get("task_readiness", {})
    expected_session_pointer = "~/" + SESSION_LOG.relative_to(Path.home()).as_posix()
    if bridge.get("session_log") != expected_session_pointer:
        raise ValueError("bridge session-log pointer is not normalized and home-relative")
    for record in (transfer, readiness):
        path = safe_path(record.get("path", ""))
        if not path.is_file() or sha256(path) != record.get("sha256"):
            raise ValueError("bridge evidence input is missing or changed")

    original = read_json(ORIGINAL_MANIFEST)
    transfer_doc = read_json(safe_path(transfer["path"]))
    transfer_rows = {row["path"]: row for row in transfer_doc["transfer"]["files"]}
    mismatch_rows = original.get("metadata_stop_receipt", {}).get("mismatches", [])
    bridge_rows = bridge.get("mismatches", [])
    expected_paths = {
        ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-EXECUTION-SOURCE-SCHEDULE-COMPACT.md",
        "test/support/guard_aggregate_reconciliation_evidence.ex",
        "test/contract/tier_sweep_test.exs",
    }
    if {row.get("path") for row in mismatch_rows} != expected_paths or {row.get("path") for row in bridge_rows} != expected_paths:
        raise ValueError("bridge includes an extra, missing, or unapproved preservation mismatch")
    if len(mismatch_rows) != 3 or len(bridge_rows) != 3:
        raise ValueError("bridge mismatch set is not exactly the three approved records")
    post_snapshot = bridge.get("post_snapshot_changes")
    post_snapshot_by_path = {}
    if post_snapshot is not None:
        if post_snapshot.get("schema_version") != "04.post-snapshot-changes.1":
            raise ValueError("unsupported post-snapshot change record")
        if post_snapshot.get("source_access") != "closed" or post_snapshot.get("semantic_claims") != []:
            raise ValueError("post-snapshot changes make a source or semantic claim")
        if readiness.get("path") != (PH3 / "03-RECOVERY-READINESS.md").relative_to(ROOT).as_posix():
            raise ValueError("post-snapshot changes are not bound to the Phase 3 readiness record")
        review_binding = post_snapshot.get("code_review", {})
        review_path = PH3 / "03-EXECUTION-CODE-REVIEW.md"
        if (review_binding.get("path") != review_path.relative_to(ROOT).as_posix()
                or not review_path.is_file() or sha256(review_path) != review_binding.get("sha256")):
            raise ValueError("post-snapshot changes lack the bound Phase 3 code review")
        review_text = review_path.read_text(encoding="utf-8")
        if "\nstatus: clean\n" not in review_text or "\n  total: 0\n" not in review_text:
            raise ValueError("post-snapshot Phase 3 code review is not clean")
        reviewed_paths = {line[4:] for line in review_text.splitlines()
                          if line.startswith("  - test/")}
        readiness_text = safe_path(readiness["path"]).read_text(encoding="utf-8")
        readiness_hashes = {}
        for line in readiness_text.splitlines():
            cells = [cell.strip().strip("`") for cell in line.split("|")]
            if len(cells) >= 3 and cells[1].startswith("test/"):
                readiness_hashes[cells[1]] = cells[2]
        change_rows = post_snapshot.get("files", [])
        validate_exact_paths(change_rows, POST_SNAPSHOT_PATHS, "post-snapshot change set")
        if not POST_SNAPSHOT_PATHS.issubset(reviewed_paths):
            raise ValueError("Phase 3 code review does not cover every post-snapshot file")
        original_by_path = {row["path"]: row for row in mismatch_rows}
        for row in change_rows:
            path = row.get("path")
            if path not in original_by_path:
                raise ValueError("post-snapshot change is outside the original mismatch set")
            current_path = safe_path(path)
            current_hash = sha256(current_path)
            current_bytes = current_path.stat().st_size
            validate_snapshot_advance(row, original_by_path[path], current_hash, current_bytes)
            if readiness_hashes.get(path) != current_hash:
                raise ValueError("Phase 3 readiness does not bind the post-snapshot file hash: " + path)
            post_snapshot_by_path[path] = row
    for mismatch in mismatch_rows:
        path = mismatch["path"]
        source = transfer_rows.get(path, {})
        bridged = next(row for row in bridge_rows if row.get("path") == path)
        current_path = safe_path(path)
        if (source.get("sha256") != mismatch.get("expected_sha256")
                or source.get("bytes") != bridged.get("old_bytes")
                or mismatch.get("expected_sha256") != bridged.get("old_sha256")
                or mismatch.get("current_sha256") != bridged.get("current_sha256")
                or mismatch.get("current_bytes") != bridged.get("current_bytes")
                or bridged.get("known_cause") != mismatch.get("known_cause")):
            raise ValueError("preservation bridge old/current hash or byte binding differs: " + path)
        advanced = post_snapshot_by_path.get(path)
        if advanced is None:
            if (sha256(current_path) != bridged.get("current_sha256")
                    or current_path.stat().st_size != bridged.get("current_bytes")):
                raise ValueError("preservation bridge current hash or byte binding differs: " + path)
        else:
            validate_snapshot_advance(advanced, mismatch, sha256(current_path), current_path.stat().st_size)
        events = bridged.get("events", [])
        if not events:
            raise ValueError("preservation delta lacks saved command evidence: " + path)
        for event in events:
            line_number = event.get("line")
            if not isinstance(line_number, int) or line_number < 1 or not SESSION_LOG.is_file():
                raise ValueError("saved command event log is unavailable")
            lines = SESSION_LOG.read_bytes().splitlines(keepends=True)
            if line_number > len(lines) or sha256_bytes(lines[line_number - 1]) != event.get("record_sha256"):
                raise ValueError("saved command event digest changed")
            log_record = json.loads(lines[line_number - 1])
            payload = log_record.get("payload", {})
            if payload.get("call_id") != event.get("call_id") or payload.get("type") != event.get("record_type"):
                raise ValueError("saved command event identity changed")

    review = bridge.get("independent_review", {})
    subject = dict(bridge)
    subject.pop("independent_review", None)
    subject_hash = json_sha256(subject)
    if review.get("status") == "pass":
        if (review.get("status") != "pass" or not review.get("reviewer")
                or review.get("reviewer") == bridge.get("author")
                or review.get("subject_sha256") != subject_hash
                or review.get("findings") != []):
            raise ValueError("independent bridge review is missing, stale, or not clean")
        bridge_status = "passed"
    elif bridge.get("status") == "review_pending" and review.get("status") == "pending":
        bridge_status = "review_pending"
    else:
        raise ValueError("bridge is neither pending independent review nor passed")
    return {"status": bridge_status, "source_access": "closed",
            "mismatches": len(bridge_rows), "independent_review": review.get("status"),
            "subject_sha256": subject_hash,
            "post_snapshot_changes": post_snapshot_by_path}


def sha256_bytes(value):
    return hashlib.sha256(value).hexdigest()


def check_metadata_input_reconciliation():
    path = PH4 / "04-METADATA-INPUT-RECONCILIATION.json"
    record = read_json(path)
    if record.get("schema_version") != "04.metadata-input-reconciliation.2":
        raise ValueError("unsupported metadata-input reconciliation schema")
    source_closed(record.get("source_access"))
    if record.get("prior_bytes_available") is not False:
        raise ValueError("reconciliation must preserve the unavailable prior-byte fact")
    original_path = ORIGINAL_MANIFEST
    original_ref = record.get("original_manifest", {})
    if (original_ref.get("path") != original_path.relative_to(ROOT).as_posix()
            or original_ref.get("sha256") != sha256(original_path)):
        raise ValueError("reconciliation is not bound to the immutable original manifest")
    original = read_json(original_path)
    binding = record.get("input_binding", {})
    if binding.get("path") != PRIMARY_REBIND_PATH:
        raise ValueError("primary metadata input rebind is not the Phase 3 plan")
    additional = record.get("additional_input_bindings", [])
    validate_exact_paths(additional, ADDITIONAL_REBIND_PATHS, "additional metadata input rebinds")
    historical_inputs = {item.get("path"): item for item in original.get("inputs", [])}
    for current_binding in [binding, *additional]:
        historical = historical_inputs.get(current_binding.get("path"))
        if historical is None:
            raise ValueError("reconciliation input is absent from the immutable original manifest")
        current = safe_path(current_binding.get("path", ""))
        if not current.is_file():
            raise ValueError("reconciled metadata input is missing")
        validate_input_rebind(current_binding, historical, sha256(current), current.stat().st_size)
    review = record.get("independent_review", {})
    subject = dict(record); subject.pop("independent_review", None)
    subject_hash = json_sha256(subject)
    if review.get("status") == "pass":
        if (review.get("status") != "pass" or not review.get("reviewer")
                or review.get("reviewer") == record.get("author")
                or review.get("subject_sha256") != subject_hash
                or review.get("findings") != []):
            raise ValueError("metadata-input rebind lacks a clean independent review")
        rebind_status = "reviewed" if record.get("status") == "review_pending" else record.get("status")
    elif record.get("status") != "review_pending" or review.get("status") != "pending":
        raise ValueError("metadata-input reconciliation is neither pending nor reviewed")
    else:
        rebind_status = "review_pending"
    return {"status": rebind_status, "source_access": "closed",
            "input_paths": [item.get("path") for item in [binding, *additional]],
            "subject_sha256": subject_hash,
            "prior_bytes_available": False}


def check_manifest_partition(manifest, mode):
    if manifest.get("schema_version") != "04.provenance.1":
        raise ValueError("unsupported provenance schema")
    source_closed(manifest.get("source_access"))
    bridge_post_snapshot = {}
    documented_historical_inputs = {}
    stop = manifest.get("metadata_stop_receipt", {})
    if mode == "blocked":
        if manifest.get("metadata_status") != "blocked" or manifest.get("partition_outcome") != "unresolved":
            raise ValueError("blocked metadata outcome was rewritten as success")
        if stop.get("status") != "blocked" or stop.get("source_access") != "closed":
            raise ValueError("exact metadata stop receipt missing")
        if not stop.get("mismatches") or not stop.get("next_actor") or not stop.get("remedy"):
            raise ValueError("stop receipt lacks mismatch, remedy, or next actor")
        bridge = check_provenance_bridge()
        rebind_result = check_metadata_input_reconciliation()
        if bridge.get("status") != "passed" or rebind_result.get("status") not in ("reviewed", "passed"):
            raise ValueError("historical inputs changed without passed provenance and rebind receipts")
        bridge_post_snapshot = bridge.get("post_snapshot_changes", {})
        for path, row in bridge.get("post_snapshot_changes", {}).items():
            documented_historical_inputs[path] = (row.get("current_sha256"), row.get("current_bytes"))
        rebind_doc = read_json(PH4 / "04-METADATA-INPUT-RECONCILIATION.json")
        for row in [rebind_doc.get("input_binding", {}), *rebind_doc.get("additional_input_bindings", [])]:
            documented_historical_inputs[row.get("path")] = (row.get("current_sha256"), row.get("current_bytes"))
    else:
        bridge = check_provenance_bridge()
        if bridge.get("status") != "passed":
            raise ValueError("supported partition is gated on an independently passed preservation bridge")
        bridge_post_snapshot = bridge.get("post_snapshot_changes", {})
        binding = manifest.get("provenance_bridge", {})
        if (manifest.get("metadata_status") != "supported" or manifest.get("partition_outcome") != "complete"
                or binding.get("status") != "passed" or binding.get("sha256") != sha256(PRESERVATION_BRIDGE)):
            raise ValueError("supported manifest lacks its exact bridge binding")
        rebind = manifest.get("metadata_input_reconciliation", {})
        rebind_path = PH4 / "04-METADATA-INPUT-RECONCILIATION.json"
        rebind_result = check_metadata_input_reconciliation()
        if (rebind_result.get("status") not in ("reviewed", "passed")
                or rebind.get("sha256") != sha256(rebind_path)
                or rebind.get("path") != rebind_path.relative_to(ROOT).as_posix()):
            raise ValueError("supported manifest lacks its reviewed metadata-input reconciliation")
        original = read_json(ORIGINAL_MANIFEST)
        for key in ("authority", "selectors", "lanes", "unavailable_domains", "safety_stops", "source_gates"):
            if manifest.get(key) != original.get(key):
                raise ValueError("supported generation changed retained " + key + " evidence")

    stale_inputs = []
    for item in manifest.get("inputs", []):
        path = safe_path(item["path"])
        if not path.is_file():
            raise ValueError("missing input binding: " + item["path"])
        current_hash = sha256(path)
        current_bytes = path.stat().st_size
        if current_hash != item.get("sha256") or current_bytes != item.get("bytes"):
            stale = {"path": item["path"], "expected_sha256": item.get("sha256"),
                     "expected_bytes": item.get("bytes"), "current_sha256": current_hash,
                     "current_bytes": current_bytes}
            documented = documented_historical_inputs.get(item["path"])
            if (mode != "blocked" or documented != (current_hash, current_bytes)):
                raise ValueError("stale/missing input binding: " + item["path"])
            stale_inputs.append(stale)
    if mode == "supported":
        rebind_doc = read_json(PH4 / "04-METADATA-INPUT-RECONCILIATION.json")
        recorded = rebind_doc.get("input_binding", {})
        additional = rebind_doc.get("additional_input_bindings", [])
        if (rebind_result.get("status") not in ("reviewed", "passed") or len(stale_inputs) != 0
                or recorded.get("path") != PRIMARY_REBIND_PATH):
            raise ValueError("active metadata inputs have not been rebound to current bytes")
        for item in [recorded, *additional]:
            if sha256(safe_path(item["path"])) != item.get("current_sha256"):
                raise ValueError("rebound metadata input no longer matches current bytes: " + item["path"])
            active_input = next((row for row in manifest.get("inputs", []) if row.get("path") == item.get("path")), None)
            if (active_input is None or active_input.get("sha256") != item.get("current_sha256")
                    or active_input.get("bytes") != item.get("current_bytes")):
                raise ValueError("supported generation did not bind reconciled current metadata input: " + item["path"])

    receipt = read_json(PH3 / "03-04-METADATA-GAP-RECEIPT.json")
    found_mismatches = []
    for item in manifest["preservation"]["recorded_entries"]:
        if item["expected_sha256"] != receipt["preservation_manifest"].get(item["path"]):
            raise ValueError("preservation expectation differs from immutable receipt")
        path = safe_path(item["path"])
        current = sha256(path) if path.is_file() else None
        snapshot_hash = validate_preservation_snapshot(
            item, current, path.stat().st_size if path.is_file() else -1,
            bridge_post_snapshot.get(item["path"]))
        if snapshot_hash != item["expected_sha256"]:
            found_mismatches.append((item["path"], item["expected_sha256"], snapshot_hash))
    stated_mismatches = [(item["path"], item["expected_sha256"], item["current_sha256"])
                         for item in manifest["preservation"]["mismatches"]]
    if sorted(found_mismatches) != sorted(stated_mismatches):
        raise ValueError("preservation mismatch list is incomplete or fabricated")

    expected, roles, unknown, ids = expected_metadata()
    authority = manifest["authority"]
    authority_ids = set(authority["archive_original_ids"]) | set(authority["preserved_lane_ids"])
    if len(authority["archive_original_ids"]) != 221 or len(authority_ids) != 226:
        raise ValueError("archived authority count is not 221 plus five")
    if authority_ids != set(authority["stop_ids"]) or authority_ids != set(authority["corroborated_ids"]):
        raise ValueError("authority observations do not agree")
    if sha256(safe_path(authority["archive_path"])) != authority["archive_sha256"]:
        raise ValueError("archived audit hash is stale")
    if sha256(safe_path(authority["archive_manifest_path"])) != authority["archive_manifest_sha256"]:
        raise ValueError("archive manifest hash is stale")
    for lane in ("core", "floor"):
        if ids[lane] != authority["observed_lane_ids"][lane] or set(ids[lane]) != authority_ids:
            raise ValueError(lane + " observed identity set differs from authority")
        diff = authority["directional_differences"][lane]
        if diff["authority_missing_from_lane"] or diff["lane_extra_over_authority"]:
            raise ValueError(lane + " directional identity differences were hidden")
        projection = manifest["lanes"][lane]
        if len(expected[lane]) != projection["union_key_count"] or len(unknown[lane]) != len(projection["unknown_baseline_target_ids"]):
            raise ValueError(lane + " key/unknown count changed")

    assoc_path = safe_path(manifest["partitions"]["associations"]["path"])
    gap_path = safe_path(manifest["partitions"]["typed_gaps"]["path"])
    associations = read_jsonl(assoc_path)
    gaps = [row for _, row in read_jsonl(gap_path)]
    if sha256(assoc_path) != manifest["partitions"]["associations"]["sha256"]:
        raise ValueError("association file hash is stale")
    if sha256(gap_path) != manifest["partitions"]["typed_gaps"]["sha256"] or len(gaps) != manifest["partitions"]["typed_gaps"]["rows"]:
        raise ValueError("typed gap file hash or row count is stale")
    domains = {"source": {}, "caller": {}, "unknown_target_set": {}}
    for row in gaps:
        if row.get("generation") != manifest["generation"] or not row.get("gap_key"):
            raise ValueError("typed row lacks generation or key")
        if mode == "blocked" and (row.get("evidence_status", "").startswith("resolved") or row.get("source_path") is not None):
            raise ValueError("blocked row claims resolved source provenance")
        domain = row.get("domain")
        if domain not in domains:
            if domain in ("graph", "callback", "delegate"):
                raise ValueError("unavailable gap domain was fabricated as keyed evidence")
            raise ValueError("unknown gap domain")
        if domain == "unknown_target_set":
            key = (row.get("lane"), row.get("original_id"))
        else:
            key = (row.get("lane"), row.get("original_id"), mfa_key(row.get("mfa")))
        if key in domains[domain]:
            raise ValueError("duplicate typed gap key")
        domains[domain][key] = row
    for lane in ("core", "floor"):
        source_keys = {key for key in domains["source"] if key[0] == lane}
        caller_keys = {key for key in domains["caller"] if key[0] == lane}
        association_keys = set()
        for row in associations:
            key = (row.get("lane"), row.get("original_id"), mfa_key(row.get("mfa")))
            association_keys.add(key)
        exact_partition(expected[lane], [key for key in association_keys if key[0] == lane], source_keys)
        exact_partition(expected[lane], [key for key in association_keys if key[0] == lane], caller_keys)
        actual_unknown = [key[1] for key in domains["unknown_target_set"] if key[0] == lane]
        exact_unknown(unknown[lane], actual_unknown)
        for key in expected[lane]:
            expected_roles = sorted(roles[key])
            if sorted(domains["source"][key].get("membership_roles", [])) != expected_roles:
                raise ValueError("source gap lost a membership role")
            if sorted(domains["caller"][key].get("membership_roles", [])) != expected_roles:
                raise ValueError("caller gap lost a membership role")
    return {"status": "blocked_consistent" if mode == "blocked" else "supported_consistent",
            "source_access": "closed", "typed_gap_rows": len(gaps),
            "known_keys": {lane: len(expected[lane]) for lane in ("core", "floor")},
            "unknown_target_sets": sum(len(values) for values in unknown.values()),
            "preservation_mismatches": len(found_mismatches), "stale_input_bindings": stale_inputs}


def check_blocked_partition():
    manifest_path = ORIGINAL_MANIFEST if ORIGINAL_MANIFEST.exists() else PH4 / "04-PROVENANCE-MANIFEST.json"
    return check_manifest_partition(read_json(manifest_path), "blocked")


def check_supported_partition():
    return check_manifest_partition(read_json(PH4 / "04-PROVENANCE-MANIFEST.json"), "supported")


def check_schedule():
    manifest = read_json(ORIGINAL_MANIFEST if ORIGINAL_MANIFEST.exists() else PH4 / "04-PROVENANCE-MANIFEST.json")
    schedule = read_json(PH4 / "04-SOURCE-SCHEDULE.json")
    historical_ledger = read_json(ENV04_LEDGER if ENV04_LEDGER.exists() else PH4 / "04-RESOURCE-LEDGER.json")
    for record in (schedule, historical_ledger):
        source_closed(record.get("source_access"))
    if schedule.get("generation") != manifest.get("generation") or schedule.get("status") != "blocked":
        raise ValueError("schedule generation/status mismatch")
    if schedule.get("review_status") != "not_run" or schedule.get("source_request_execute_preflight") != "not_run" or schedule.get("direct_count_status") != "not_run":
        raise ValueError("a closed source gate is falsely marked complete")
    request = next((row for row in schedule.get("requests", []) if row.get("request_id") == "R1"), None)
    if request is None or request.get("status") != "blocked" or request.get("source_span") is not None or request.get("source_bytes") is not None:
        raise ValueError("blocked R1 hides an exact span/byte count")
    if not request.get("missing_fields") or not request.get("reason"):
        raise ValueError("blocked R1 lacks exact missing gates")
    if (historical_ledger.get("generated_output_ceiling") != 210000
            or historical_ledger.get("protected_reserve") != 31000
            or historical_ledger.get("working_ceiling") != 179000):
        raise ValueError("immutable ENV-04 resource envelope arithmetic changed")
    old_usage = historical_ledger.get("post_reset_usage", {})
    old_output = old_usage.get("output_tokens")
    if (not isinstance(old_output, int)
            or historical_ledger.get("remaining_working_balance") != 179000 - old_output
            or historical_ledger.get("remaining_total_balance") != 210000 - old_output
            or historical_ledger.get("working_ceiling") + historical_ledger.get("protected_reserve") != historical_ledger.get("generated_output_ceiling")):
        raise ValueError("immutable ENV-04 usage arithmetic is inconsistent")
    if historical_ledger.get("source_request_count") != 0 or historical_ledger.get("count_status") != "not_run":
        raise ValueError("historical record claims an R1 source request")

    active = read_json(PH4 / "04-RESOURCE-LEDGER.json")
    source_closed(active.get("source_access"))
    if active.get("aggregate_output_budget_policy") != "disabled_by_owner":
        raise ValueError("aggregate output ceiling policy has not been disabled by the owner")
    consumed = active.get("consumed_request_ids")
    expected_consumed = list(SOURCE_REQUEST_IDS[:len(consumed)]) if isinstance(consumed, list) else None
    if (not isinstance(consumed, list) or len(consumed) != len(set(consumed))
            or len(consumed) > len(SOURCE_REQUEST_IDS)
            or consumed != expected_consumed
            or active.get("source_request_count") != len(consumed)):
        raise ValueError("active ENV-06 source request ledger is inconsistent")
    usage = active.get("post_reset_usage", {})
    output = usage.get("output_tokens")
    return {"status": "historical_blocked_consistent", "source_access": "closed",
            "historical_env04": {"output_tokens": old_output, "remaining_working": 179000 - old_output},
            "active_env06_informational": {"output_tokens": output,
                                            "recorded_working_balance": active.get("remaining_working_balance")},
            "aggregate_output_budget_policy": active.get("aggregate_output_budget_policy"),
            "source_request_count": active.get("source_request_count"),
            "consumed_request_ids": consumed}


def source_span_blockers(schedule):
    request = schedule.get("request", {})
    span = request.get("source_span", {})
    try:
        source_path = safe_path(request.get("candidate_path"))
        source = source_path.read_bytes()
    except (OSError, ValueError, TypeError) as exc:
        return ["scheduled source is unavailable or unsafe: " + str(exc)]
    if hashlib.sha256(source).hexdigest() != request.get("source_sha256"):
        return ["current full-source hash differs from the reviewed schedule"]
    start_line, end_line = span.get("start_line"), span.get("end_line")
    start_byte, end_byte = span.get("start_byte"), span.get("end_byte_exclusive")
    if any(type(value) is not int for value in (start_line, end_line, start_byte, end_byte)):
        return ["scheduled source span has invalid line or byte bounds"]
    lines = source.splitlines(keepends=True)
    if start_line < 1 or end_line < start_line or end_line > len(lines):
        return ["scheduled source line range is outside the current file"]
    expected_start = sum(len(line) for line in lines[:start_line - 1])
    expected_end = sum(len(line) for line in lines[:end_line])
    if start_byte != expected_start or end_byte != expected_end or end_byte < start_byte:
        return ["scheduled source byte offsets do not match its line range"]
    selected = source[start_byte:end_byte]
    if (len(selected) != request.get("source_bytes")
            or hashlib.sha256(selected).hexdigest() != span.get("span_sha256")):
        return ["scheduled source span byte count or hash is stale"]
    try:
        selected.decode("utf-8")
    except UnicodeDecodeError:
        return ["scheduled source span is not valid UTF-8"]
    chunk_blockers = source_chunk_map_blockers(source, span, request.get("source_chunks"))
    if chunk_blockers:
        return chunk_blockers
    context = request.get("context_text")
    if not isinstance(context, str):
        return ["exact request context is missing"]
    context_bytes = context.encode("utf-8")
    if (len(context_bytes) != request.get("context_bytes")
            or hashlib.sha256(context_bytes).hexdigest() != request.get("context_sha256")):
        return ["exact request context bytes or hash are stale"]
    return []


def source_chunk_map_blockers(source, span, chunks):
    if chunks is None:
        return []
    if not isinstance(chunks, list) or len(chunks) < 2:
        return ["chunked source delivery needs at least two exact chunks"]
    cursor_byte = span.get("start_byte")
    cursor_line = span.get("start_line")
    blockers = []
    for index, chunk in enumerate(chunks, start=1):
        if not isinstance(chunk, dict):
            return ["source chunk metadata is malformed"]
        start = chunk.get("start_byte")
        end = chunk.get("end_byte_exclusive")
        first = chunk.get("start_line")
        last = chunk.get("end_line")
        if (chunk.get("index") != index or type(start) is not int or type(end) is not int
                or type(first) is not int or type(last) is not int
                or start != cursor_byte or first != cursor_line or end <= start or last < first):
            blockers.append("source chunks are not an ordered, contiguous partition")
            continue
        selected = source[start:end]
        lines = selected.splitlines(keepends=True)
        if (end > len(source) or len(selected) != chunk.get("bytes")
                or hashlib.sha256(selected).hexdigest() != chunk.get("sha256")
                or len(lines) != last - first + 1):
            blockers.append("source chunk byte, line, or hash binding is stale")
        cursor_byte = end
        cursor_line = last + 1
    if (cursor_byte != span.get("end_byte_exclusive")
            or cursor_line != span.get("end_line") + 1):
        blockers.append("source chunks do not cover the complete scheduled file span")
    return blockers


def consumed_request_source_blockers(schedule):
    request = schedule.get("request", {})
    path = request.get("candidate_path")
    source_sha256 = request.get("source_sha256")
    try:
        current_path = safe_path(path)
    except (OSError, ValueError, TypeError) as exc:
        return ["consumed source path is unavailable or unsafe: " + str(exc)]
    if not current_path.is_file():
        return ["consumed source file is missing"]
    bridge = check_provenance_bridge()
    if bridge.get("status") != "passed" or bridge.get("source_access") != "closed":
        return ["consumed source request lacks a passed, closed preservation bridge"]
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    active_input = next((row for row in manifest.get("inputs", []) if row.get("path") == path), None)
    current_sha256 = sha256(current_path)
    current_bytes = current_path.stat().st_size
    if (active_input is None or active_input.get("sha256") != current_sha256
            or active_input.get("bytes") != current_bytes):
        return ["current consumed-source bytes are not bound by the active manifest"]
    advance = bridge.get("post_snapshot_changes", {}).get(path)
    try:
        validate_consumed_source_binding(source_sha256, current_sha256,
                                         active_input.get("sha256"), advance)
    except ValueError as exc:
        return [str(exc)]
    return []


def schedule_input_blockers(schedule):
    blockers = []
    inputs = schedule.get("inputs")
    if not isinstance(inputs, list) or not inputs:
        return ["schedule does not bind its input files"]
    seen = set()
    for item in inputs:
        if not isinstance(item, dict) or not isinstance(item.get("path"), str):
            blockers.append("schedule contains a malformed input binding")
            continue
        path = item["path"]
        if path in seen:
            blockers.append("schedule repeats an input binding: " + path)
            continue
        seen.add(path)
        try:
            file_path = safe_path(path)
            data = file_path.read_bytes()
        except (OSError, ValueError, TypeError) as exc:
            blockers.append("scheduled input is unavailable or unsafe: " + path + ": " + str(exc))
            continue
        if len(data) != item.get("bytes") or hashlib.sha256(data).hexdigest() != item.get("sha256"):
            blockers.append("scheduled input hash/byte binding is stale: " + path)
    return blockers


def consumed_count_payload_blockers(schedule, count):
    request = schedule.get("request", {})
    context_bytes = request.get("context_bytes")
    source_bytes = request.get("source_bytes")
    expected_payload_bytes = (context_bytes + len(SOURCE_SELECTION_DELIMITER.encode("utf-8")) + source_bytes
                              if type(context_bytes) is int and type(source_bytes) is int else None)
    blockers = []
    if (count.get("status") != "pass"
            or count.get("generation") != schedule.get("generation")
            or count.get("request_id") != request.get("request_id")):
        blockers.append("consumed direct-count status/generation/request identity is invalid")
    if (expected_payload_bytes is None or type(count.get("payload_bytes")) is not int
            or count.get("payload_bytes") != expected_payload_bytes):
        blockers.append("consumed direct-count payload byte receipt is missing or stale")
    if (type(count.get("serialized_request_bytes")) is not int
            or count.get("serialized_request_bytes") <= 0
            or not isinstance(count.get("serialized_request_sha256"), str)
            or len(count.get("serialized_request_sha256", "")) != 64):
        blockers.append("consumed direct-count serialized request receipt is incomplete")
    if (type(count.get("serialized_input_tokens")) is not int
            or count.get("serialized_input_tokens") <= 0
            or count.get("generated") is not False
            or count.get("generation_endpoint_called") is not False
            or count.get("payload_truncated") is not False
            or count.get("fits_configured_context") is not True):
        blockers.append("consumed direct-count context/one-use receipt is invalid")
    if (count.get("schedule_sha256") != schedule.get("sha256")
            or count.get("source_sha256") != request.get("source_sha256")
            or count.get("source_span") != request.get("source_span")
            or count.get("context_sha256") != request.get("context_sha256")):
        blockers.append("consumed direct-count schedule/source/context binding is stale")
    return blockers


def requires_no_count_blockers(blockers):
    if blockers:
        raise ValueError("; ".join(blockers))


def count_payload_blockers(schedule, count):
    request = schedule.get("request", {})
    span = request.get("source_span", {})
    source_path = safe_path(request.get("candidate_path"))
    data = source_path.read_bytes()
    selected = data[span["start_byte"]:span["end_byte_exclusive"]].decode("utf-8")
    input_text = request["context_text"] + SOURCE_SELECTION_DELIMITER + selected
    model = schedule.get("count_contract", {}).get("model")
    serialized = json.dumps({"model": model, "input": input_text},
                            separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    expected = {
        "payload_bytes": len(input_text.encode("utf-8")),
        "serialized_request_bytes": len(serialized),
        "serialized_request_sha256": hashlib.sha256(serialized).hexdigest(),
    }
    return ["direct-count " + field + " does not match the exact serialized request"
            for field, value in expected.items() if count.get(field) != value]


def request_gate_blockers(manifest, schedule, review, preflight, count, ledger, request_id):
    blockers = []
    if request_id not in SOURCE_REQUEST_IDS:
        blockers.append("request id is not an authorized exact request")
    bridge = manifest.get("provenance_bridge", {})
    if (manifest.get("metadata_status") != "supported" or manifest.get("partition_outcome") != "complete"
            or bridge.get("status") != "passed" or len(bridge.get("sha256", "")) != 64):
        blockers.append("upstream metadata authority/selector/partition stop")
    if schedule.get("status") not in ("scheduled", "ready") or schedule.get("source_access") != "closed":
        blockers.append("exact source schedule is not ready and closed")
    if schedule.get("generation") != manifest.get("generation"):
        blockers.append("schedule generation is stale")
    request = schedule.get("request", {})
    if request.get("request_id") != request_id or request.get("status") not in ("scheduled", "ready"):
        blockers.append("exact request is missing or blocked")
    span = request.get("source_span")
    if (not isinstance(span, dict) or not span
            or type(request.get("source_bytes")) is not int or request["source_bytes"] <= 0
            or not isinstance(span.get("span_sha256"), str) or len(span["span_sha256"]) != 64):
        blockers.append("exact source span, hash, or byte count is missing")
    if not isinstance(request.get("source_sha256"), str) or len(request["source_sha256"]) != 64:
        blockers.append("exact full-source hash is missing")
    if schedule.get("source_file_count") != 1 or schedule.get("source_file_count", 0) > 5:
        blockers.append("source-file count is missing or over the five-file cap")
    if review.get("status") != "pass":
        blockers.append("independent exact schedule review is not passed")
    if not review.get("reviewer") or review.get("reviewer") == schedule.get("author"):
        blockers.append("reviewer is missing or is the schedule author")
    if preflight.get("status") != "pass" or preflight.get("stage") != "execute" or str(preflight.get("phase")) != "4" or preflight.get("exit_code") != 0 or preflight.get("errors") != []:
        blockers.append("fresh Phase 4 execute preflight is not passed")
    if (count.get("status") != "pass" or count.get("generated") is not False
            or count.get("generation_endpoint_called") is not False or count.get("payload_truncated") is not False):
        blockers.append("fresh complete no-generation direct count is not passed")
    generation = schedule.get("generation")
    expected_bindings = {"generation": generation, "request_id": request_id,
                         "source_sha256": request.get("source_sha256"),
                         "source_span": span, "context_sha256": request.get("context_sha256")}
    for name, record in (("review", review), ("preflight", preflight), ("count", count)):
        for field, expected in expected_bindings.items():
            if not expected or record.get(field) != expected:
                blockers.append(f"{name} has a stale or missing {field} binding")
    schedule_hash = schedule.get("sha256")
    review_hash = review.get("sha256")
    preflight_hash = preflight.get("sha256")
    if not schedule_hash or review.get("schedule_sha256") != schedule_hash or preflight.get("schedule_sha256") != schedule_hash or count.get("schedule_sha256") != schedule_hash:
        blockers.append("schedule hash binding is missing or stale")
    if not review_hash or preflight.get("review_sha256") != review_hash or count.get("review_sha256") != review_hash:
        blockers.append("independent review hash binding is missing or stale")
    if not preflight_hash or count.get("preflight_sha256") != preflight_hash:
        blockers.append("execute preflight hash binding is missing or stale")
    timestamps = [schedule.get("created_at_utc"), review.get("created_at_utc"),
                  preflight.get("created_at_utc"), count.get("counted_at_utc")]
    if any(not isinstance(value, str) or not value for value in timestamps) or timestamps != sorted(timestamps):
        blockers.append("schedule, review, preflight and count ordering is missing or stale")
    input_tokens = count.get("serialized_input_tokens")
    if type(input_tokens) is not int or input_tokens < 0:
        blockers.append("exact serialized request token count is missing")
    model_context = count.get("configured_model_context_tokens")
    if (type(model_context) is not int or model_context <= 0
            or type(input_tokens) is not int or input_tokens > model_context
            or count.get("fits_configured_context") is not True):
        blockers.append("exact request does not fit the configured model context")
    if type(count.get("serialized_request_bytes")) is not int or count["serialized_request_bytes"] <= 0:
        blockers.append("serialized request byte count is missing")
    if not isinstance(count.get("serialized_request_sha256"), str) or len(count["serialized_request_sha256"]) != 64:
        blockers.append("serialized request hash is missing")
    if ledger.get("aggregate_output_budget_policy") != "disabled_by_owner":
        blockers.append("the owner has not disabled the aggregate output ceiling")
    consumed_ids = ledger.get("consumed_request_ids")
    consumed_count = ledger.get("source_request_count")
    if (not isinstance(consumed_ids, list) or len(consumed_ids) != len(set(consumed_ids))
            or type(consumed_count) is not int or consumed_count != len(consumed_ids)):
        blockers.append("source request count and unique consumed request ids are inconsistent")
    elif request_id in consumed_ids:
        blockers.append("this exact source request has already been consumed; unchanged retry is forbidden")
    return list(dict.fromkeys(blockers))


def consumed_receipt_status(receipt):
    emission = receipt.get("source_emission_receipt", {})
    if (receipt.get("status") == "consumed_incomplete"
            and emission.get("status") == "consumed_once_delivery_incomplete"
            and emission.get("tool_output_truncated") is True
            and emission.get("analysis_complete") is False):
        return "consumed_incomplete"
    if (receipt.get("status") == "consumed_delivery_unverified"
            and emission.get("status") == "delivery_unverified"
            and emission.get("emission_count") == 1
            and emission.get("tool_output_truncated") is None
            and emission.get("source_bytes_delivered") is None
            and emission.get("source_body_emitted_once") is True
            and emission.get("begin_sentinel_observed") is True
            and emission.get("end_sentinel_observed") is True
            and emission.get("analysis_complete") is False
            and emission.get("content_used_for_analysis") is False):
        return "consumed_delivery_unverified"
    if (receipt.get("status") == "consumed" and emission.get("status") == "consumed_once"
            and emission.get("tool_output_truncated") is False
            and emission.get("analysis_complete") is True):
        return "consumed_verified"
    return "blocked"


def consumed_receipt_blockers(receipt, expected):
    ready = receipt.get("one_use_ready_receipt", {})
    emission = receipt.get("source_emission_receipt", {})
    ready_bindings = ready.get("bindings", {})
    actual_ready = {key: ready_bindings.get(key) for key in expected}
    actual_emission = {key: emission.get(key) for key in expected}
    ready_hash = json_sha256(ready)
    state = consumed_receipt_status(receipt)
    content_use = emission.get("content_used_for_analysis")
    content_use_valid = (state == "consumed_verified" and content_use is True
                         or state == "consumed_incomplete" and type(content_use) is bool
                         or state == "consumed_delivery_unverified" and content_use is False)
    if (receipt.get("request_id", ready_bindings.get("request_id")) != expected.get("request_id")
            or receipt.get("status") not in ("consumed", "consumed_incomplete", "consumed_delivery_unverified")
            or receipt.get("source_emission") is not True
            or type(receipt.get("source_request_count")) is not int
            or receipt.get("source_request_count") < 1
            or ready.get("status") != "one_use_ready" or ready.get("source_emission") is not False
            or actual_ready != expected or actual_emission != expected
            or emission.get("emission_count") != 1
            or not content_use_valid
            or emission.get("one_use_ready_receipt_sha256") != ready_hash
            or state == "blocked"):
        return ["consumed request lacks an exact complete or explicitly incomplete one-use emission receipt"]
    if state == "consumed_verified" and expected.get("request_id") == "R8":
        span = expected.get("source_span", {})
        selected_bytes = span.get("end_byte_exclusive", 0) - span.get("start_byte", 0)
        if (selected_bytes <= 0
                or emission.get("source_bytes") != selected_bytes
                or emission.get("source_bytes_delivered") != selected_bytes
                or emission.get("delivered_span_sha256") != span.get("span_sha256")
                or emission.get("source_body_emitted_once") is not True
                or emission.get("begin_sentinel_observed") is not True
                or emission.get("end_sentinel_observed") is not True
                or emission.get("generation_endpoint_called") is not False):
            return ["R8 verified delivery lacks the scheduled byte count/hash, complete sentinels, or one-use evidence"]
    return []


def check_request_gate(request_id):
    if request_id not in SOURCE_REQUEST_IDS:
        raise ValueError("request id is not in the exact Phase 4 source-request sequence")
    check_schedule()
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    schedule_path = request_artifact_path(request_id, "SCHEDULE")
    review_path = request_artifact_path(request_id, "SCHEDULE-REVIEW")
    preflight_path = request_artifact_path(request_id, "EXECUTE-PREFLIGHT")
    count_path = request_artifact_path(request_id, "DIRECT-COUNT")
    gate_path = request_artifact_path(request_id, "REQUEST-GATE")
    schedule = read_json(schedule_path) if schedule_path.exists() else {}
    schedule["sha256"] = sha256(schedule_path) if schedule_path.exists() else None
    review = read_json(review_path) if review_path.exists() else {}
    preflight = read_json(preflight_path) if preflight_path.exists() else {}
    count = read_json(count_path) if count_path.exists() else {}
    if review_path.exists():
        review["sha256"] = sha256(review_path)
    if preflight_path.exists():
        preflight["sha256"] = sha256(preflight_path)
    ledger = read_json(PH4 / "04-RESOURCE-LEDGER.json")
    consumed_ids = ledger.get("consumed_request_ids", [])
    if request_id in consumed_ids:
        receipt = read_json(gate_path) if gate_path.exists() else {}
        expected = {"generation": schedule.get("generation"), "request_id": request_id,
                    "schedule_sha256": schedule.get("sha256"),
                    "review_sha256": sha256(review_path) if review_path.exists() else None,
                    "preflight_sha256": sha256(preflight_path) if preflight_path.exists() else None,
                    "count_sha256": sha256(count_path) if count_path.exists() else None,
                    "source_sha256": schedule.get("request", {}).get("source_sha256"),
                    "source_span": schedule.get("request", {}).get("source_span"),
                    "context_sha256": schedule.get("request", {}).get("context_sha256"),
                    "serialized_request_sha256": count.get("serialized_request_sha256")}
        errors = consumed_receipt_blockers(receipt, expected)
        state = consumed_receipt_status(receipt)
        if errors:
            return {"status": "blocked", "source_access": "closed", "source_emission": False,
                    "blockers": errors, "bindings": expected}
        if state == "consumed_incomplete":
            return {"status": "consumed_incomplete", "source_access": "closed",
                    "source_emission": True,
                    "blockers": ["tool output was truncated; no complete source analysis may claim this request"],
                    "bindings": expected}
        if state == "consumed_delivery_unverified":
            return {"status": "consumed_delivery_unverified", "source_access": "closed",
                    "source_emission": True,
                    "blockers": ["delivery markers were observed but byte count/hash were not verified; exclude from claims and never replay"],
                    "bindings": expected}
        # The one-use-ready receipt and complete emission receipt are immutable.
        # A later source edit must not invalidate a historical request by making
        # the scheduled path point at newer bytes; only an unused gate rechecks
        # the live file before emission.
        return {"status": "consumed_verified", "source_access": "closed",
                "source_emission": True, "source_request_count": ledger.get("source_request_count"),
                "bindings": expected}
    if (type(ledger.get("source_request_count")) is not int
            or ledger.get("source_request_count") != len(consumed_ids)):
        return {"status": "blocked", "source_access": "closed", "source_emission": False,
                "blockers": ["source request count and consumed request ids are inconsistent"]}
    blockers = request_gate_blockers(manifest, schedule, review, preflight, count, ledger, request_id)
    blockers.extend(schedule_input_blockers(schedule))
    blockers.extend(source_span_blockers(schedule))
    blockers.extend(count_payload_blockers(schedule, count))
    bridge = check_provenance_bridge()
    if bridge.get("status") != "passed":
        blockers.append("independent preservation-bridge review has not passed")
    else:
        try:
            check_supported_partition()
        except (OSError, ValueError, KeyError, TypeError) as exc:
            blockers.append("supported metadata partition failed: " + str(exc))
    original_manifest = read_json(ORIGINAL_MANIFEST)
    stop = original_manifest.get("metadata_stop_receipt", {})
    return {"schema_version": "04.request-gate.2", "request_id": request_id,
            "status": "blocked" if blockers else "one_use_ready",
            "source_access": "closed", "source_emission": False,
            "blockers": list(dict.fromkeys(blockers)),
            "missing_fields": ["independent exact schedule review", "fresh Phase 4 execute preflight",
                               "serialized request token count", "serialized request hash and byte count"] if blockers else [],
            "gates_not_run": ["schedule review", "source-request execute preflight", "direct count",
                              "source emission"] if blockers else [],
            "upstream_stop": {"status": stop.get("status"), "reason": stop.get("reason"),
                              "mismatches": stop.get("mismatches", []),
                              "missing_selectors": stop.get("missing_selectors", []),
                              "selectors": manifest.get("selectors"),
                              "unavailable_domains": manifest.get("unavailable_domains")},
            "bindings": {"generation": schedule.get("generation"), "request_id": request_id,
                         "source_sha256": schedule.get("request", {}).get("source_sha256"),
                         "source_span": schedule.get("request", {}).get("source_span"),
                         "context_sha256": schedule.get("request", {}).get("context_sha256"),
                         "manifest_sha256": sha256(PH4 / "04-PROVENANCE-MANIFEST.json"),
                         "schedule_sha256": schedule.get("sha256"),
                         "review_sha256": review.get("sha256"),
                         "preflight_sha256": preflight.get("sha256"),
                         "count_sha256": sha256(count_path) if count_path.exists() else None,
                         "serialized_request_sha256": count.get("serialized_request_sha256"),
                         "consumed_request_ids": consumed_ids,
                         "informational_usage_snapshot_utc": ledger.get("measured_at_utc"),
                         "informational_post_reset_output_tokens": ledger.get("post_reset_usage", {}).get("output_tokens"),
                         "informational_recorded_working_balance": ledger.get("remaining_working_balance")}}

def check_blocked_payloads():
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    source_closed(manifest.get("source_access"))
    for key, path in (("coverage_caller_trace", CALLER_TRACE), ("sizing_digest_proof", DIGEST_PROOF)):
        binding = manifest.get(key, {})
        if binding.get("path") != path.relative_to(ROOT).as_posix():
            raise ValueError(key + " path is not bound in the active manifest")
        if binding.get("sha256") != sha256(path) or binding.get("bytes") != path.stat().st_size:
            raise ValueError(key + " hash/byte binding is stale")
        record = read_json(path)
        source_closed(record.get("source_access"))
        if record.get("generation") != manifest.get("generation") or record.get("status") != "blocked":
            raise ValueError(key + " is not blocked on the active generation")
        if not record.get("missing_fields") or not record.get("reason"):
            raise ValueError(key + " lacks exact missing fields or cause")
    return {"status": "blocked_records_consistent", "source_access": "closed",
            "generation": manifest.get("generation")}


def evidence_review_subject():
    manifest_path = PH4 / "04-PROVENANCE-MANIFEST.json"
    manifest = read_json(manifest_path)
    payloads = {}
    for key, path in (("associations", safe_path(manifest["partitions"]["associations"]["path"])),
                      ("typed_gaps", safe_path(manifest["partitions"]["typed_gaps"]["path"])),
                      ("coverage_caller_trace", CALLER_TRACE),
                      ("sizing_digest_proof", DIGEST_PROOF)):
        payloads[key] = {"path": path.relative_to(ROOT).as_posix(),
                         "sha256": sha256(path), "bytes": path.stat().st_size}
    requests = {}
    for request_id in SOURCE_REQUEST_IDS:
        gate_path = request_artifact_path(request_id, "REQUEST-GATE")
        schedule_path = request_artifact_path(request_id, "SCHEDULE")
        review_path = request_artifact_path(request_id, "SCHEDULE-REVIEW")
        preflight_path = request_artifact_path(request_id, "EXECUTE-PREFLIGHT")
        count_path = request_artifact_path(request_id, "DIRECT-COUNT")
        requests[request_id] = {
            "gate_sha256": sha256(gate_path), "schedule_sha256": sha256(schedule_path),
            "review_sha256": sha256(review_path), "preflight_sha256": sha256(preflight_path),
            "count_sha256": sha256(count_path),
        }
    return {"generation": manifest.get("generation"),
            "manifest": {"path": manifest_path.relative_to(ROOT).as_posix(),
                         "sha256": sha256(manifest_path), "bytes": manifest_path.stat().st_size},
            "payloads": payloads, "source_requests": requests}


def check_final_evidence_payloads():
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    source_closed(manifest.get("source_access"))
    if manifest.get("metadata_status") != "supported" or manifest.get("partition_outcome") != "complete":
        raise ValueError("active metadata generation is not structurally supported")
    for key, path in (("coverage_caller_trace", CALLER_TRACE), ("sizing_digest_proof", DIGEST_PROOF)):
        binding = manifest.get(key, {})
        if (binding.get("path") != path.relative_to(ROOT).as_posix()
                or binding.get("sha256") != sha256(path)
                or binding.get("bytes") != path.stat().st_size):
            raise ValueError(key + " raw-byte binding is missing or stale")
    current_status = manifest.get("current_source_request_status", {})
    if (current_status.get("path") != CALLER_TRACE.relative_to(ROOT).as_posix()
            or current_status.get("sha256") != sha256(CALLER_TRACE)
            or current_status.get("bytes") != CALLER_TRACE.stat().st_size
            or current_status.get("status_by_request") != {
                "R1": "consumed_incomplete", "R2": "consumed_verified",
                "R3": "consumed_verified", "R4": "consumed_incomplete",
                "R5": "consumed_verified", "R6": "consumed_verified",
                "R7": "consumed_delivery_unverified", "R8": "consumed_verified"}
            or "preserves the original metadata-stop snapshot" not in current_status.get("snapshot_note", "")):
        raise ValueError("manifest does not distinguish the original source-gate snapshot from current request status")
    trace = read_json(CALLER_TRACE)
    proof = read_json(DIGEST_PROOF)
    for name, record in (("caller trace", trace), ("digest proof", proof)):
        source_closed(record.get("source_access"))
        if record.get("generation") != manifest.get("generation"):
            raise ValueError(name + " generation is stale")
    if trace.get("schema_version") != "04.coverage-caller-trace.2":
        raise ValueError("caller trace schema is stale")
    if trace.get("record_partition", {}).get("status") != "supported_consistent":
        raise ValueError("caller trace does not bind the supported record partition")
    if trace.get("source_resolution", {}).get("status") != "unresolved":
        raise ValueError("source resolution is incorrectly claimed complete")
    if trace.get("caller_closure", {}).get("status") != "incomplete":
        raise ValueError("caller closure is incorrectly claimed complete")
    if trace.get("claims_not_made") != ["source resolution", "caller closure", "runtime safety", "absence of dynamic callers"]:
        raise ValueError("caller trace omitted a required limitation")
    expected_requests = {"R1": "consumed_incomplete", "R2": "consumed_verified",
                         "R3": "consumed_verified", "R4": "consumed_incomplete",
                         "R5": "consumed_verified", "R6": "consumed_verified",
                         "R7": "consumed_delivery_unverified", "R8": "consumed_verified"}
    traced = {item.get("request_id"): item for item in trace.get("source_requests", [])}
    if set(traced) != set(expected_requests):
        raise ValueError("caller trace request set differs from the consumed request ledger")
    gates = {}
    for request_id, expected_status in expected_requests.items():
        result = check_request_gate(request_id)
        if result.get("status") != expected_status:
            raise ValueError(request_id + " source request status changed")
        item = traced[request_id]
        gate_path = request_artifact_path(request_id, "REQUEST-GATE")
        schedule_path = request_artifact_path(request_id, "SCHEDULE")
        if (item.get("status") != expected_status
                or item.get("gate_receipt_sha256") != sha256(gate_path)
                or item.get("schedule_sha256") != sha256(schedule_path)
                or item.get("usable_for_claims") != (request_id in ("R2", "R3", "R5", "R6", "R8"))):
            raise ValueError(request_id + " trace binding or evidence-use status is stale")
        gates[request_id] = result
    mismatch = trace.get("generator_revision_mismatch", {})
    historical = mismatch.get("historical_producer_identity", {})
    current = mismatch.get("current_request_observation", {})
    if (mismatch.get("status") != "unresolved"
            or historical.get("sha256") != proof.get("supplement", {}).get("canonical_payload", {}).get("selector", {}).get("helper_source_identity", {}).get("sha256")
            or historical.get("sha256") != traced["R2"].get("source_sha256")
            or historical.get("sha256") != traced["R3"].get("source_sha256")
            or current.get("request_id") != "R8"
            or current.get("sha256") != traced["R8"].get("source_sha256")
            or current.get("sha256") == historical.get("sha256")
            or current.get("status") != "consumed_verified"
            or current.get("claim_scope") != "current-helper identity only"
            or current.get("source_span") != traced["R8"].get("source_span")
            or current.get("source_span") != read_json(request_artifact_path("R8", "SCHEDULE")).get("request", {}).get("source_span")):
        raise ValueError("historical producer identity and current helper revision mismatch are not explicitly preserved")
    if proof.get("schema_version") != "04.sizing-digest-proof.2":
        raise ValueError("sizing digest proof schema is stale")
    legacy = proof.get("legacy_recipe", {})
    if (legacy.get("status") != "unresolved" or legacy.get("selector") is not None
            or legacy.get("field_order") is not None or not legacy.get("encoding")):
        raise ValueError("legacy digest is not honestly marked unresolved")
    supplement = proof.get("supplement", {})
    payload = supplement.get("canonical_payload")
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":"),
                         ensure_ascii=False).encode("utf-8") if isinstance(payload, dict) else b""
    if (supplement.get("status") != "verified_integrity_only"
            or supplement.get("encoding") != "UTF-8 JSON; sorted keys; compact separators; no digest field in hashed payload"
            or hashlib.sha256(encoded).hexdigest() != supplement.get("digest")
            or len(encoded) != supplement.get("serialized_bytes")):
        raise ValueError("versioned supplement digest cannot be reproduced from its declared selector")
    review = read_json(EVIDENCE_REVIEW)
    subject = evidence_review_subject()
    if (review.get("schema_version") != "04.evidence-review.1"
            or review.get("status") != "pass" or review.get("source_access") != "closed"
            or not review.get("reviewer") or review.get("reviewer") == review.get("author")
            or review.get("subject_sha256") != json_sha256(subject)
            or review.get("subject") != subject or review.get("findings") != []):
        raise ValueError("independent final evidence review is absent, stale, or not clean")
    return {"status": "pass_with_open_gaps", "source_access": "closed",
            "generation": manifest.get("generation"), "request_gates": gates,
            "record_partition": trace["record_partition"],
            "source_resolution": "unresolved", "caller_closure": "incomplete",
            "legacy_digest": "unresolved", "supplement_digest": supplement.get("digest"),
            "independent_review": "pass"}


def build_supported_validation():
    checks = {}
    probes = {
        "preservation_bridge": check_provenance_bridge,
        "input_reconciliation": check_metadata_input_reconciliation,
        "historical_blocked_partition": check_blocked_partition,
        "supported_partition": check_supported_partition,
        "schedule_and_ledger": check_schedule,
        "final_evidence_payloads": check_final_evidence_payloads,
    }
    for name, probe in probes.items():
        try:
            checks[name] = {"status": "observed", "result": probe()}
        except (OSError, ValueError, AssertionError, KeyError, TypeError) as exc:
            checks[name] = {"status": "failed", "error": str(exc)}
    failures = [name for name, record in checks.items() if record.get("status") != "observed"]
    manifest_path = PH4 / "04-PROVENANCE-MANIFEST.json"
    manifest = read_json(manifest_path)
    review_hash = sha256(EVIDENCE_REVIEW) if EVIDENCE_REVIEW.exists() else None
    return {
        "schema_version": "04.validation.2",
        "result": "blocked" if failures else "pass_with_open_gaps",
        "validation_passed": not failures,
        "full_package_valid": not failures,
        "source_access": "closed",
        "generation": manifest.get("generation"),
        "semantic_closure": "open",
        "source_resolution": "unresolved",
        "caller_closure": "incomplete",
        "candidate": None,
        "implementation_authorized": False,
        "checks": checks,
        "bindings": {"manifest_sha256": sha256(manifest_path),
                     "evidence_review_sha256": review_hash,
                     "association_sha256": sha256(safe_path(manifest["partitions"]["associations"]["path"])),
                     "typed_gaps_sha256": sha256(safe_path(manifest["partitions"]["typed_gaps"]["path"])),
                     "caller_trace_sha256": sha256(CALLER_TRACE),
                     "digest_proof_sha256": sha256(DIGEST_PROOF),
                     "request_gate_sha256s": {rid: sha256(request_artifact_path(rid, "REQUEST-GATE"))
                                               for rid in SOURCE_REQUEST_IDS}},
        "resource_status": {"aggregate_output_budget_policy": "disabled_by_owner",
                             "informational_usage_snapshot_utc": read_json(PH4 / "04-RESOURCE-LEDGER.json").get("measured_at_utc"),
                             "source_request_count": len(SOURCE_REQUEST_IDS),
                             "per_request_context_fit": {rid: read_json(request_artifact_path(rid, "DIRECT-COUNT")).get("fits_configured_context")
                                                          for rid in SOURCE_REQUEST_IDS},
                             "aggregate_output_limit_enforced": False},
        "missing_fields": [checks[name].get("error") for name in failures],
        "final_package_check": {"status": "passed" if not failures else "failed",
                                 "command": "--all", "exit_code": 0 if not failures else 1},
    }


def write_supported_validation():
    record = build_supported_validation()
    tmp = VALIDATION.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(record, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    tmp.replace(VALIDATION)
    return {"status": record["result"], "source_access": "closed",
            "generation": record["generation"],
            "failed_checks": [name for name, value in record["checks"].items()
                              if value.get("status") != "observed"]}


def check_supported_package():
    computed = build_supported_validation()
    saved = read_json(VALIDATION)
    if (computed.get("validation_passed") is not True
            or saved.get("schema_version") != "04.validation.2"
            or saved.get("result") != "pass_with_open_gaps"
            or saved.get("validation_passed") is not True
            or saved.get("full_package_valid") is not True
            or saved.get("bindings") != computed.get("bindings")
            or saved.get("generation") != computed.get("generation")):
        raise ValueError("final supported package is stale, incomplete, or failed validation")
    return {"status": "pass_with_open_gaps", "source_access": "closed",
            "generation": computed.get("generation"),
            "validation_sha256": sha256(VALIDATION),
            "checks": computed["checks"]}


def write_blocked_validation():
    manifest_path = PH4 / "04-PROVENANCE-MANIFEST.json"
    ledger_path = PH4 / "04-RESOURCE-LEDGER.json"
    probes = {
        "preservation_bridge": check_provenance_bridge,
        "input_reconciliation": check_metadata_input_reconciliation,
        "historical_blocked_partition": check_blocked_partition,
        "supported_partition": check_supported_partition,
        "schedule_and_ledger": check_schedule,
        "blocked_payloads": check_blocked_payloads,
        "r1_request_gate": lambda: check_request_gate("R1"),
    }
    checks = {}
    for name, probe in probes.items():
        try:
            checks[name] = {"status": "observed", "result": probe()}
        except (OSError, ValueError, AssertionError, KeyError, TypeError) as exc:
            checks[name] = {"status": "failed", "error": str(exc)}
    request_result = checks.get("r1_request_gate", {}).get("result")
    if isinstance(request_result, dict) and request_result.get("status") != "consumed_verified":
        REQUEST_GATE.write_text(json.dumps(request_result, indent=2, ensure_ascii=False) + "\n")
    manifest = read_json(manifest_path)
    ledger = read_json(ledger_path)
    record = {
        "schema_version": "04.validation.1", "result": "blocked",
        "validation_passed": False, "full_package_valid": False,
        "source_access": "closed", "generation": manifest.get("generation"),
        "checks": checks,
        "bindings": {"manifest_sha256": sha256(manifest_path),
                     "caller_trace_sha256": sha256(CALLER_TRACE),
                     "digest_proof_sha256": sha256(DIGEST_PROOF),
                     "r1_request_gate_sha256": sha256(REQUEST_GATE),
                     "resource_ledger_sha256": sha256(ledger_path)},
        "resource_status": {"aggregate_output_budget_policy": ledger.get("aggregate_output_budget_policy"),
                            "informational_usage_snapshot_utc": ledger.get("measured_at_utc"),
                            "informational_post_reset_output_tokens": ledger.get("post_reset_usage", {}).get("output_tokens"),
                            "request_context_fit": "not_counted", "source_request_count": 0},
        "missing_fields": ["independent R1 schedule review", "fresh Phase 4 execute preflight",
                           "exact complete-request input count", "caller/source proof",
                           "legacy digest recipe"],
        "final_package_check": {"status": "not_run", "command": "--all --blocked",
                                 "stdout": None, "exit_code": None},
    }
    tmp = VALIDATION.with_suffix(".json.tmp")
    tmp.write_text(json.dumps(record, indent=2, ensure_ascii=False) + "\n")
    tmp.replace(VALIDATION)
    return {"status": "blocked_validation_written", "source_access": "closed",
            "generation": record["generation"], "failed_checks": [k for k,v in checks.items() if v["status"] == "failed"]}


def check_blocked_package():
    base = check_provenance_bridge()
    historical = check_blocked_partition()
    schedule = check_schedule()
    partition = check_supported_partition()
    payloads = check_blocked_payloads()
    request = check_request_gate("R1")
    review = read_json(PH4 / "04-EVIDENCE-REVIEW.json")
    validation = read_json(VALIDATION)
    gate_receipt = read_json(REQUEST_GATE)
    if review.get("status") != "blocked" or review.get("source_access") != "closed":
        raise ValueError("blocked evidence review is missing or opens source access")
    if (validation.get("result") != "blocked" or validation.get("validation_passed") is not False
            or validation.get("full_package_valid") is not False or validation.get("source_access") != "closed"):
        raise ValueError("blocked validation receipt claims success or is incomplete")
    for filename in ("04-HANDOFF.md", "04-03-SUMMARY.md"):
        content = (PH4 / filename).read_text(encoding="utf-8").lower()
        if "blocked" not in content or "source access: closed" not in content:
            raise ValueError(filename + " does not state the blocked result and closed source gate")
    if request.get("status") == "blocked":
        if gate_receipt.get("status") != "blocked" or gate_receipt.get("source_access") != "closed":
            raise ValueError("saved blocked R1 request gate is missing or opens source access")
    elif request.get("status") == "consumed_verified":
        if gate_receipt.get("status") != "consumed" or gate_receipt.get("source_emission") is not True:
            raise ValueError("consumed R1 has no exact closed one-use emission receipt")
    else:
        raise ValueError("R1 is neither blocked before use nor verifiably consumed once")
    return {"status": "blocked_consistent", "source_access": "closed", "bridge": base,
            "historical_partition": historical, "partition": partition,
            "schedule": schedule, "payloads": payloads, "request_gate": request}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--provenance-bridge", action="store_true")
    parser.add_argument("--input-reconciliation", action="store_true")
    parser.add_argument("--partition", action="store_true")
    parser.add_argument("--blocked", action="store_true")
    parser.add_argument("--schedule", action="store_true")
    parser.add_argument("--request-gate", action="store_true")
    parser.add_argument("--request")
    parser.add_argument("--write-validation", action="store_true")
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            result = self_test()
        elif args.provenance_bridge:
            result = check_provenance_bridge()
        elif args.input_reconciliation:
            result = check_metadata_input_reconciliation()
        elif args.partition and args.blocked:
            result = check_blocked_partition()
        elif args.partition:
            result = check_supported_partition()
        elif args.schedule:
            result = check_schedule()
        elif args.write_validation:
            result = write_blocked_validation() if args.blocked else write_supported_validation()
        elif args.request_gate:
            if not args.request:
                parser.error("--request-gate requires --request R1, R2, R3, R4, R5, R6, R7, or R8")
            result = check_request_gate(args.request)
        elif args.all:
            if args.blocked:
                result = check_blocked_package()
            else:
                bridge = check_provenance_bridge()
                historical_partition = check_blocked_partition()
                schedule = check_schedule()
                manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
                if manifest.get("metadata_status") == "supported":
                    partition = check_supported_partition()
                    package = check_supported_package()
                    result = {"status": "pass_with_open_gaps", "source_access": "closed",
                              "bridge": bridge, "historical_partition": historical_partition,
                              "partition": partition, "schedule": schedule, "package": package}
                else:
                    result = {"status": "blocked_consistent", "source_access": "closed",
                              "bridge": bridge, "partition": historical_partition, "schedule": schedule}
        else:
            parser.error("select a mode")
        print(json.dumps(result, separators=(",", ":")))
        return 1 if args.request_gate and result.get("status") == "blocked" else 0
    except (OSError, ValueError, AssertionError, KeyError, TypeError) as exc:
        print(json.dumps({"status": "fail", "error": str(exc)}, separators=(",", ":")))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
