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


def check_blocked_partition():
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    if manifest.get("schema_version") != "04.provenance.1":
        raise ValueError("unsupported provenance schema")
    if manifest.get("metadata_status") != "blocked" or manifest.get("partition_outcome") != "unresolved":
        raise ValueError("blocked metadata outcome was rewritten as success")
    source_closed(manifest.get("source_access"))
    stop = manifest.get("metadata_stop_receipt", {})
    if stop.get("status") != "blocked" or stop.get("source_access") != "closed":
        raise ValueError("exact metadata stop receipt missing")
    if not stop.get("mismatches") or not stop.get("next_actor") or not stop.get("remedy"):
        raise ValueError("stop receipt lacks mismatch, remedy, or next actor")

    for item in manifest.get("inputs", []):
        path = safe_path(item["path"])
        if not path.is_file() or sha256(path) != item.get("sha256"):
            raise ValueError("stale/missing input binding: " + item["path"])

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
    if associations:
        raise ValueError("blocked candidate unexpectedly contains source associations")
    if sha256(assoc_path) != manifest["partitions"]["associations"]["sha256"]:
        raise ValueError("association file hash is stale")
    if sha256(gap_path) != manifest["partitions"]["typed_gaps"]["sha256"] or len(gaps) != manifest["partitions"]["typed_gaps"]["rows"]:
        raise ValueError("typed gap file hash or row count is stale")
    domains = {"source": {}, "caller": {}, "unknown_target_set": {}}
    for row in gaps:
        if row.get("generation") != manifest["generation"] or not row.get("gap_key"):
            raise ValueError("typed row lacks generation or key")
        if row.get("evidence_status", "").startswith("resolved") or row.get("source_path") is not None:
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
        exact_partition(expected[lane], [], source_keys)
        exact_partition(expected[lane], [], caller_keys)
        actual_unknown = [key[1] for key in domains["unknown_target_set"] if key[0] == lane]
        exact_unknown(unknown[lane], actual_unknown)
        for key in expected[lane]:
            expected_roles = sorted(roles[key])
            if sorted(domains["source"][key].get("membership_roles", [])) != expected_roles:
                raise ValueError("source gap lost a membership role")
            if sorted(domains["caller"][key].get("membership_roles", [])) != expected_roles:
                raise ValueError("caller gap lost a membership role")
    return {"status": "blocked_consistent", "source_access": "closed", "typed_gap_rows": len(gaps),
            "known_keys": {lane: len(expected[lane]) for lane in ("core", "floor")},
            "unknown_target_sets": sum(len(values) for values in unknown.values()),
            "preservation_mismatches": len(found_mismatches)}


def check_schedule():
    manifest = read_json(PH4 / "04-PROVENANCE-MANIFEST.json")
    schedule = read_json(PH4 / "04-SOURCE-SCHEDULE.json")
    ledger = read_json(PH4 / "04-RESOURCE-LEDGER.json")
    for record in (schedule, ledger):
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
    if ledger.get("generated_output_ceiling") != 150000 or ledger.get("protected_reserve") != 31000 or ledger.get("working_ceiling") != 119000:
        raise ValueError("resource envelope arithmetic changed")
    usage = ledger.get("post_reset_usage", {})
    if ledger.get("status") != "cumulative_usage_unverifiable" or usage.get("output_tokens") is not None or ledger.get("remaining_working_balance") is not None:
        raise ValueError("unknown resource usage was falsely treated as measured")
    if ledger.get("cumulative_fit") != "unverifiable" or ledger.get("count_status") != "not_run":
        raise ValueError("unmeasured source fit/count was claimed")
    return {"status": "blocked_consistent", "source_access": "closed", "review": "not_run", "preflight": "not_run", "count": "not_run", "fit": "unverifiable"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--partition", action="store_true")
    parser.add_argument("--blocked", action="store_true")
    parser.add_argument("--schedule", action="store_true")
    parser.add_argument("--request-gate", action="store_true")
    parser.add_argument("--all", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            result = self_test()
        elif args.partition and args.blocked:
            result = check_blocked_partition()
        elif args.partition:
            result = {"status": "blocked", "source_access": "closed", "reason": "metadata stop requires --partition --blocked"}
            print(json.dumps(result, separators=(",", ":")))
            return 1
        elif args.schedule:
            result = check_schedule()
        elif args.request_gate:
            check_schedule()
            result = {"status": "blocked", "source_access": "closed", "reason": "review, preflight, direct count, and fit are not established"}
        elif args.all:
            partition = check_blocked_partition()
            schedule = check_schedule()
            result = {"status": "blocked_consistent", "source_access": "closed", "partition": partition, "schedule": schedule}
        else:
            parser.error("select a mode")
        print(json.dumps(result, separators=(",", ":")))
        return 0
    except (OSError, ValueError, AssertionError, KeyError, TypeError) as exc:
        print(json.dumps({"status": "fail", "error": str(exc)}, separators=(",", ":")))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
