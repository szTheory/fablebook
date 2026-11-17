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
SESSION_LOG = Path("/Users/jon/.codex/sessions/2026/11/16/rollout-2026-11-16T21-47-09-01a1e766-afb2-77a1-8977-350fde6d15dd.jsonl")


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

    def gate_fixture():
        generation = "a" * 64
        schedule_hash = "b" * 64
        review_hash = "c" * 64
        preflight_hash = "d" * 64
        source_hash = "e" * 64
        context_hash = "f" * 64
        span = {"start_line": 1, "end_line": 20}
        manifest = {"metadata_status": "supported", "partition_outcome": "complete",
                    "generation": generation, "authority": {"status": "corroborated"},
                    "provenance_bridge": {"status": "passed", "sha256": "9" * 64}}
        schedule = {"status": "scheduled", "source_access": "closed",
                    "generation": generation, "sha256": schedule_hash,
                    "created_at_utc": "2026-01-01T00:00:00Z", "author": "executor",
                    "source_file_count": 1,
                    "request": {"request_id": "R1", "status": "scheduled",
                                "candidate_path": "test/support/helper.ex", "source_span": span,
                                "source_bytes": 100, "source_sha256": source_hash,
                                "context_sha256": context_hash, "request_cap_tokens": 34000,
                                "output_cap_tokens": 2000}}
        review = {"status": "pass", "reviewer": "independent-reviewer",
                  "created_at_utc": "2026-01-01T00:01:00Z", "generation": generation,
                  "request_id": "R1", "sha256": review_hash, "schedule_sha256": schedule_hash,
                  "source_sha256": source_hash, "source_span": span,
                  "context_sha256": context_hash, "findings": []}
        preflight = {"status": "pass", "created_at_utc": "2026-01-01T00:02:00Z",
                     "generation": generation, "request_id": "R1", "sha256": preflight_hash,
                     "stage": "execute", "phase": "4", "exit_code": 0, "errors": [],
                     "schedule_sha256": schedule_hash, "review_sha256": review_hash,
                     "source_sha256": source_hash, "source_span": span,
                     "context_sha256": context_hash}
        count = {"status": "pass", "counted_at_utc": "2026-01-01T00:03:00Z",
                 "generation": generation, "request_id": "R1", "generated": False,
                 "payload_truncated": False, "serialized_input_tokens": 1000,
                 "task_charge_tokens": 17000, "analysis_review_allowance_tokens": 14000,
                 "output_allowance_tokens": 2000,
                 "source_sha256": source_hash, "source_span": span,
                 "context_sha256": context_hash, "schedule_sha256": schedule_hash,
                 "review_sha256": review_hash, "preflight_sha256": preflight_hash}
        ledger = {"status": "measured", "measured_at_utc": "2026-01-01T00:04:00Z",
                  "usage_attributed": True, "cumulative_fit": "measured",
                  "source_request_count": 0, "working_ceiling": 610000,
                  "generated_output_ceiling": 650000, "protected_reserve": 40000,
                  "remaining_working_balance": 560000,
                  "post_reset_usage": {"output_tokens": 50000},
                  "task_caps": {"04-02-02": 50000}}
        return [manifest, schedule, review, preflight, count, ledger]

    fixture = gate_fixture()
    initial_blockers = request_gate_blockers(*fixture, "R1")
    if initial_blockers:
        raise AssertionError("fully bound one-use request fixture was blocked: " + "; ".join(initial_blockers))
    checks += 1
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
    changed = gate_fixture(); changed[5]["usage_attributed"] = False
    variants.append(changed)
    changed = gate_fixture(); changed[5]["source_request_count"] = 1
    variants.append(changed)
    changed = gate_fixture(); changed[5]["task_caps"]["04-02-02"] = 2500
    variants.append(changed)
    changed = gate_fixture(); changed[5]["cumulative_fit"] = "unverifiable"
    variants.append(changed)
    changed = gate_fixture(); changed[4]["output_allowance_tokens"] = 200000
    variants.append(changed)
    changed = gate_fixture(); changed[4]["task_charge_tokens"] = 16999
    variants.append(changed)
    changed = gate_fixture(); changed[4]["analysis_review_allowance_tokens"] = 13000
    variants.append(changed)
    changed = gate_fixture(); changed[1]["request"]["source_span"] = None
    variants.append(changed)
    changed = gate_fixture(); changed[3]["created_at_utc"] = "2025-12-31T23:59:00Z"
    variants.append(changed)
    changed = gate_fixture(); changed[1]["request"]["context_sha256"] = "0" * 64
    variants.append(changed)
    for invalid in variants:
        if not request_gate_blockers(*invalid, "R1"):
            raise AssertionError("request-gate negative control unexpectedly passed")
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
                or sha256(current_path) != bridged.get("current_sha256")
                or current_path.stat().st_size != bridged.get("current_bytes")
                or bridged.get("known_cause") != mismatch.get("known_cause")):
            raise ValueError("preservation bridge old/current hash or byte binding differs: " + path)
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
            "subject_sha256": subject_hash}


def sha256_bytes(value):
    return hashlib.sha256(value).hexdigest()


def check_metadata_input_reconciliation():
    path = PH4 / "04-METADATA-INPUT-RECONCILIATION.json"
    record = read_json(path)
    if record.get("schema_version") != "04.metadata-input-reconciliation.1":
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
    historical = next((item for item in original.get("inputs", []) if item.get("path") == binding.get("path")), None)
    if (historical is None or historical.get("sha256") != binding.get("original_sha256")
            or historical.get("bytes") != binding.get("original_bytes")):
        raise ValueError("reconciliation does not preserve the exact historical input binding")
    current = safe_path(binding.get("path", ""))
    if (not current.is_file() or sha256(current) != binding.get("current_sha256")
            or current.stat().st_size != binding.get("current_bytes")):
        raise ValueError("current metadata input differs from the reconciliation")
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
            "input_path": binding.get("path"), "subject_sha256": subject_hash,
            "prior_bytes_available": False}


def check_manifest_partition(manifest, mode):
    if manifest.get("schema_version") != "04.provenance.1":
        raise ValueError("unsupported provenance schema")
    source_closed(manifest.get("source_access"))
    stop = manifest.get("metadata_stop_receipt", {})
    if mode == "blocked":
        if manifest.get("metadata_status") != "blocked" or manifest.get("partition_outcome") != "unresolved":
            raise ValueError("blocked metadata outcome was rewritten as success")
        if stop.get("status") != "blocked" or stop.get("source_access") != "closed":
            raise ValueError("exact metadata stop receipt missing")
        if not stop.get("mismatches") or not stop.get("next_actor") or not stop.get("remedy"):
            raise ValueError("stop receipt lacks mismatch, remedy, or next actor")
    else:
        bridge = check_provenance_bridge()
        if bridge.get("status") != "passed":
            raise ValueError("supported partition is gated on an independently passed preservation bridge")
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
            allowed_historical_plan = (mode == "blocked" and item["path"] ==
                ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-PLAN.md")
            if not allowed_historical_plan:
                raise ValueError("stale/missing input binding: " + item["path"])
            stale_inputs.append(stale)
    if mode == "supported":
        rebind_doc = read_json(PH4 / "04-METADATA-INPUT-RECONCILIATION.json")
        recorded = rebind_doc.get("input_binding", {})
        if (rebind_result.get("status") not in ("reviewed", "passed") or len(stale_inputs) != 0
                or recorded.get("path") != ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-PLAN.md"):
            raise ValueError("active plan input has not been rebound to current bytes")
        if sha256(safe_path(recorded["path"])) != recorded.get("current_sha256"):
            raise ValueError("rebound plan input no longer matches current bytes")
        active_input = next((item for item in manifest.get("inputs", []) if item.get("path") == recorded.get("path")), None)
        if (active_input is None or active_input.get("sha256") != recorded.get("current_sha256")
                or active_input.get("bytes") != recorded.get("current_bytes")):
            raise ValueError("supported generation did not bind the reconciled current plan bytes")

    receipt = read_json(PH3 / "03-04-METADATA-GAP-RECEIPT.json")
    found_mismatches = []
    for item in manifest["preservation"]["recorded_entries"]:
        if item["expected_sha256"] != receipt["preservation_manifest"].get(item["path"]):
            raise ValueError("preservation expectation differs from immutable receipt")
        path = safe_path(item["path"])
        current = sha256(path) if path.is_file() else None
        if current != item["current_sha256"] or (current == item["expected_sha256"]) != item["matches"]:
            raise ValueError("stale current preservation hash: " + item["path"])
        if current != item["expected_sha256"]:
            found_mismatches.append((item["path"], item["expected_sha256"], current))
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
    if (active.get("generated_output_ceiling") != 650000 or active.get("working_ceiling") != 610000
            or active.get("protected_reserve") != 40000
            or active.get("working_ceiling") + active.get("protected_reserve") != active.get("generated_output_ceiling")):
        raise ValueError("active ENV-06 resource envelope arithmetic changed")
    usage = active.get("post_reset_usage", {})
    output = usage.get("output_tokens")
    if (active.get("status") not in ("measured", "measured_with_request_blocked")
            or not active.get("usage_attributed") or not isinstance(output, int)
            or active.get("remaining_working_balance") != 610000 - output
            or active.get("remaining_total_balance") != 650000 - output
            or active.get("protected_reserve_preserved") is not True
            or active.get("source_request_count") != 0):
        raise ValueError("active ENV-06 usage or remaining balance is stale or inconsistent")
    return {"status": "blocked_consistent", "source_access": "closed",
            "historical_env04": {"output_tokens": old_output, "remaining_working": 179000 - old_output},
            "active_env06": {"output_tokens": output, "remaining_working": 610000 - output},
            "review": "not_run", "preflight": "not_run", "count": "not_run"}


def request_gate_blockers(manifest, schedule, review, preflight, count, ledger, request_id):
    blockers = []
    if request_id != "R1":
        blockers.append("request id is not the planned R1")
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
    if not isinstance(span, dict) or not span or not isinstance(request.get("source_bytes"), int) or request.get("source_bytes") <= 0:
        blockers.append("exact source span and byte count are missing")
    if not isinstance(request.get("source_sha256"), str) or len(request["source_sha256"]) != 64:
        blockers.append("exact source hash is missing")
    if schedule.get("source_file_count") != 1 or schedule.get("source_file_count", 0) > 5:
        blockers.append("source-file count is missing or over the five-file cap")
    if review.get("status") != "pass":
        blockers.append("independent exact schedule review is not passed")
    if not review.get("reviewer") or review.get("reviewer") == schedule.get("author"):
        blockers.append("reviewer is missing or is the schedule author")
    if preflight.get("status") != "pass" or preflight.get("stage") != "execute" or str(preflight.get("phase")) != "4" or preflight.get("exit_code") != 0 or preflight.get("errors") != []:
        blockers.append("fresh Phase 4 execute preflight is not passed")
    if count.get("status") != "pass" or count.get("generated") is not False or count.get("payload_truncated") is not False:
        blockers.append("fresh complete no-generation direct count is not passed")
    generation = schedule.get("generation")
    expected_bindings = {"generation": generation, "request_id": request_id,
                         "source_sha256": request.get("source_sha256"),
                         "source_span": span, "context_sha256": request.get("context_sha256")}
    records = (review, preflight, count)
    for name, record in zip(("review", "preflight", "count"), records):
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
    if type(input_tokens) is not int or input_tokens < 0 or input_tokens > 34000:
        blockers.append("exact serialized request count is missing or exceeds 34,000 tokens")
    task_charge = count.get("task_charge_tokens")
    task_cap = ledger.get("task_caps", {}).get("04-02-02")
    analysis_allowance = count.get("analysis_review_allowance_tokens")
    if type(analysis_allowance) is not int or analysis_allowance != 14000:
        blockers.append("analysis/review allowance is not the exact 14,000-token reserve")
    output_allowance = count.get("output_allowance_tokens")
    if type(output_allowance) is not int or output_allowance != 2000:
        blockers.append("R1 output allowance is not the exact 2,000-token reserve")
    expected_charge = (input_tokens + analysis_allowance + output_allowance
                       if type(input_tokens) is int and type(analysis_allowance) is int and type(output_allowance) is int
                       else None)
    if (type(task_charge) is not int or type(task_cap) is not int or task_cap != 50000
            or expected_charge is None or task_charge != expected_charge or task_charge > task_cap):
        blockers.append("task charge does not equal exact input + analysis/review + output allowances within 50,000")
    usage = ledger.get("post_reset_usage", {})
    current_output = usage.get("output_tokens")
    working_ceiling = ledger.get("working_ceiling")
    if (ledger.get("status") not in ("measured", "measured_with_request_blocked")
            or not ledger.get("usage_attributed") or ledger.get("cumulative_fit") != "measured"
            or ledger.get("generated_output_ceiling") != 650000 or ledger.get("protected_reserve") != 40000):
        blockers.append("cumulative post-reset usage/fit is not freshly measured")
    if (type(current_output) is not int or working_ceiling != 610000
            or type(output_allowance) is not int or current_output + output_allowance > working_ceiling):
        blockers.append("prospective request exceeds or cannot prove the aggregate working ceiling")
    if ledger.get("remaining_working_balance") != working_ceiling - current_output if type(current_output) is int and type(working_ceiling) is int else True:
        blockers.append("remaining working balance is not bound to measured usage")
    if not isinstance(ledger.get("measured_at_utc"), str) or not timestamps[-1] or ledger.get("measured_at_utc") < timestamps[-1]:
        blockers.append("usage measurement predates the direct count")
    if ledger.get("source_request_count") != 0:
        blockers.append("R1 has already been consumed; unchanged retry is forbidden")
    return list(dict.fromkeys(blockers))


def check_request_gate(request_id):
    if request_id != "R1":
        raise ValueError("only the planned R1 request is supported")
    check_schedule()
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    schedule_path = ACTIVE_SCHEDULE
    schedule = read_json(schedule_path) if schedule_path.exists() else {}
    schedule["sha256"] = sha256(schedule_path) if schedule_path.exists() else None
    review_path = PH4 / "04-R1-SCHEDULE-REVIEW.json"
    preflight_path = PH4 / "04-R1-EXECUTE-PREFLIGHT.json"
    count_path = PH4 / "04-R1-DIRECT-COUNT.json"
    ledger = read_json(PH4 / "04-RESOURCE-LEDGER.json")
    review = read_json(review_path) if review_path.exists() else {}
    preflight = read_json(preflight_path) if preflight_path.exists() else {}
    count = read_json(count_path) if count_path.exists() else {}
    blockers = request_gate_blockers(manifest, schedule, review, preflight, count, ledger, request_id)
    bridge = check_provenance_bridge()
    if bridge.get("status") != "passed":
        blockers.append("independent preservation-bridge review has not passed")
    else:
        try:
            check_supported_partition()
        except (OSError, ValueError, KeyError, TypeError) as exc:
            blockers.append("supported metadata partition failed: " + str(exc))
    if not blockers:
        source = safe_path(schedule["request"]["candidate_path"])
        if not source.is_file() or sha256(source) != schedule["request"].get("source_sha256"):
            blockers.append("current source bytes differ from the fully reviewed/count-bound schedule")
    original_manifest = read_json(ORIGINAL_MANIFEST)
    stop = original_manifest.get("metadata_stop_receipt", {})
    return {"schema_version": "04.r1-request-gate.1",
            "request_id": request_id, "status": "blocked" if blockers else "one_use_ready",
            "source_access": "closed", "source_emission": False,
            "blockers": blockers,
            "missing_fields": ["approved provenance bridge", "independent exact schedule review",
                               "fresh source-request execute preflight", "serialized request token count",
                               "measured cumulative fit for exact R1 request"] if blockers else [],
            "gates_not_run": ["source enumeration", "schedule review", "source-request execute preflight",
                              "direct count", "source emission"] if blockers else [],
            "upstream_stop": {"status": stop.get("status"), "reason": stop.get("reason"),
                              "mismatches": stop.get("mismatches", []),
                              "missing_selectors": stop.get("missing_selectors", []),
                              "selectors": manifest.get("selectors"),
                              "unavailable_domains": manifest.get("unavailable_domains")},
            "bindings": {"generation": schedule.get("generation"),
                         "manifest_sha256": sha256(PH4 / "04-PROVENANCE-MANIFEST.json"),
                         "schedule_sha256": schedule["sha256"],
                         "resource_snapshot_utc": ledger.get("measured_at_utc"),
                         "post_reset_output_tokens": ledger.get("post_reset_usage", {}).get("output_tokens"),
                         "remaining_working_tokens": ledger.get("remaining_working_balance")}}


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
    if isinstance(request_result, dict):
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
        "resource_status": {"envelope": ledger.get("envelope"),
                            "measured_at_utc": ledger.get("measured_at_utc"),
                            "output_tokens": ledger.get("post_reset_usage", {}).get("output_tokens"),
                            "remaining_working_balance": ledger.get("remaining_working_balance"),
                            "r1_fit": "unverifiable", "source_request_count": 0},
        "missing_fields": ["independent R1 schedule review", "fresh Phase 4 execute preflight",
                           "direct input count", "current cumulative fit", "caller/source proof",
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
    if request.get("status") != "blocked":
        raise ValueError("R1 unexpectedly passed its one-use gate")
    if gate_receipt.get("status") != "blocked" or gate_receipt.get("source_access") != "closed":
        raise ValueError("saved R1 request gate is missing or opens source access")
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
            if not args.blocked:
                parser.error("bounded closeout supports only --write-validation --blocked")
            result = write_blocked_validation()
        elif args.request_gate:
            if not args.request:
                parser.error("--request-gate requires --request R1")
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
                    request = check_request_gate("R1")
                    result = {"status": "supported_consistent", "source_access": "closed",
                              "bridge": bridge, "historical_partition": historical_partition,
                              "partition": partition, "schedule": schedule, "request_gate": request}
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
