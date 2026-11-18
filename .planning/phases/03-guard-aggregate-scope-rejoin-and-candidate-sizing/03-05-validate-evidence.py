#!/usr/bin/env python3
"""Read-only verifier for the Phase 4 evidence and Phase 3 recovery consumer."""
import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[3]
PH3 = ROOT / ".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
PH4 = ROOT / ".planning/phases/04-evidence-only-source-and-gap-provenance-closure"
MANIFEST = PH4 / "04-PROVENANCE-MANIFEST.json"
VALIDATION = PH4 / "04-VALIDATION.json"
TRACE = PH4 / "04-COVERAGE-CALLER-TRACE.json"
DIGEST_PROOF = PH4 / "04-SIZING-DIGEST-PROOF.json"
REVIEW = PH4 / "04-EVIDENCE-REVIEW.json"
SIZING = PH3 / "03-SIZING.json"
LANE_PATHS = {"core": PH3 / "03-CORE-AGGREGATE-EVIDENCE.json",
              "floor": PH3 / "03-FLOOR-AGGREGATE-EVIDENCE.json"}
CONSUMER_HELPER = ROOT / "test/support/guard_aggregate_reconciliation_evidence.ex"
CONTRACT_TEST = ROOT / "test/contract/tier_sweep_test.exs"


def source_request_paths(number):
    if number == 1:
        prefix = "03-05-T2-"
        return {
            "schedule": PH3 / (prefix + "SOURCE-SCHEDULE.json"),
            "review": PH3 / (prefix + "SOURCE-REVIEW.json"),
            "preflight": PH3 / (prefix + "EXECUTE-PREFLIGHT.json"),
            "count": PH3 / (prefix + "DIRECT-COUNT.json"),
            "gate": PH3 / (prefix + "REQUEST-GATE.json"),
            "emission": PH3 / (prefix + "SOURCE-EMISSION-RECEIPT.json"),
        }
    if number <= 6:
        prefix = f"03-05-T2-R{number}-"
        return {
            "schedule": PH3 / "03-05-T2-SOURCE-SCHEDULE-REMAINDER-REVISE-01.json",
            "review": PH3 / "03-05-T2-SOURCE-SCHEDULE-REMAINDER-REVIEW.json",
            "preflight": PH3 / (prefix + "EXECUTE-PREFLIGHT.json"),
            "count": PH3 / (prefix + "DIRECT-COUNT.json"),
            "gate": PH3 / (prefix + "REQUEST-GATE.json"),
            "emission": PH3 / (prefix + "SOURCE-EMISSION-RECEIPT.json"),
        }
    prefix = "03-05-T2-R7-"
    return {
        "schedule": PH3 / "03-05-T2-VALIDATOR-SOURCE-SCHEDULE.json",
        "review": PH3 / "03-05-T2-VALIDATOR-SOURCE-REVIEW.json",
        "preflight": PH3 / (prefix + "EXECUTE-PREFLIGHT.json"),
        "count": PH3 / (prefix + "DIRECT-COUNT.json"),
        "gate": PH3 / (prefix + "REQUEST-GATE.json"),
        "emission": PH3 / (prefix + "SOURCE-EMISSION-RECEIPT.json"),
    }


def phase3_source_requests():
    result = []
    for number in range(1, 8):
        request_id = f"T2-R{number}"
        paths = source_request_paths(number)
        documents = {name: read_json(path) for name, path in paths.items()}
        receipt = documents["emission"]
        gate = documents["gate"]
        preflight = documents["preflight"]
        count = documents["count"]
        schedule = documents["schedule"]
        review = documents["review"]

        if receipt.get("request_id") != request_id or receipt.get("emission_count") != 1:
            raise ValueError(f"{request_id} emission identity/count is invalid")
        if receipt.get("schedule_sha256") != sha256(paths["schedule"]):
            raise ValueError(f"{request_id} schedule binding is stale")
        if receipt.get("review_sha256") != sha256(paths["review"]):
            raise ValueError(f"{request_id} review binding is stale")
        if receipt.get("preflight_sha256") != sha256(paths["preflight"]):
            raise ValueError(f"{request_id} preflight binding is stale")
        if receipt.get("count_sha256") != sha256(paths["count"]):
            raise ValueError(f"{request_id} direct-count binding is stale")
        reviewed_schedule_sha = review.get("subject_sha256", review.get("schedule_sha256"))
        reviewed_schedule_path = review.get("subject_path", review.get("schedule_path"))
        if (reviewed_schedule_sha != sha256(paths["schedule"])
                or reviewed_schedule_path != paths["schedule"].relative_to(ROOT).as_posix()):
            raise ValueError(f"{request_id} independent review does not bind its schedule")
        if (count.get("schedule_sha256") != sha256(paths["schedule"])
                or count.get("review_sha256") != sha256(paths["review"])
                or count.get("preflight_sha256") != sha256(paths["preflight"])):
            raise ValueError(f"{request_id} direct count has stale prerequisite bindings")
        if receipt.get("gate_sha256") is not None and receipt["gate_sha256"] != sha256(paths["gate"]):
            raise ValueError(f"{request_id} one-use gate binding is stale")
        preflight_result = preflight.get("result", {})
        if number == 1:
            count_passed = (
                count.get("status") == "pass"
                and count.get("http_status") == 200
                and count.get("generation_endpoint_called") is False
                and count.get("generated") is False
                and count.get("payload_truncated") is False
                and count.get("fits_configured_context") is True
                and isinstance(count.get("serialized_input_tokens"), int)
            )
            preflight_passed = (
                preflight.get("status") == "pass"
                and preflight.get("exit_code") == 0
                and preflight.get("errors") == []
                and preflight.get("stage") == "execute"
                and preflight.get("phase") == "3"
            )
        else:
            count_passed = (
                count.get("http_status") == 200
                and count.get("generation_endpoint_called") is False
                and isinstance(count.get("input_tokens"), int)
            )
            preflight_passed = (
                preflight_result.get("errors") == []
                and preflight_result.get("stage") == "execute"
                and preflight_result.get("phase") == "3"
                and preflight_result.get("route_phase") == "03"
            )
        if not count_passed or not preflight_passed:
            raise ValueError(f"{request_id} direct count or execute preflight did not pass")
        if number == 1:
            if (receipt.get("status") != "consumed_once_delivery_incomplete"
                    or receipt.get("tool_output_truncated") is not True
                    or receipt.get("content_used_for_analysis") is not False
                    or gate.get("status") != "consumed_incomplete"):
                raise ValueError("T2-R1 must remain excluded as clipped and unused")
            usable = False
        else:
            if (receipt.get("status") != "consumed_once_delivery_complete"
                    or receipt.get("tool_output_truncated") is not False
                    or receipt.get("completion_sentinel_observed") is not True
                    or gate.get("status") != "consumed_once_emission_in_progress"):
                raise ValueError(f"{request_id} is not a complete, single-use delivery")
            usable = True
        if number == 1:
            review_passed = review.get("status") == "pass"
        elif number <= 6:
            review_passed = review.get("result") == "pass"
        else:
            review_passed = review.get("result") == "pass" and review.get("findings") == []
        if not review_passed:
            raise ValueError(f"{request_id} independent source review did not pass")

        selections = []
        for item in receipt.get("source_selections", []):
            span = item.get("source_span", {})
            selections.append({
                "path": item.get("path"),
                "source_sha256": item.get("source_sha256"),
                "source_bytes": item.get("source_bytes"),
                "start_line": span.get("start_line"),
                "end_line": span.get("end_line"),
                "span_sha256": span.get("span_sha256"),
                "complete_file": span.get("complete_file"),
            })
        artifacts = [
            {"role": role, "path": path.relative_to(ROOT).as_posix(),
             "sha256": sha256(path), "bytes": path.stat().st_size}
            for role, path in paths.items()
        ]
        result.append({
            "request_id": request_id,
            "delivery_status": receipt["status"],
            "complete_delivery": usable,
            "replay_forbidden": True,
            "content_used_for_analysis_at_emission": receipt.get("content_used_for_analysis"),
            "analysis_complete_at_emission": receipt.get("analysis_complete"),
            "tool_output_truncated": receipt.get("tool_output_truncated"),
            "completion_sentinel_observed": receipt.get("completion_sentinel_observed"),
            "serialized_input_tokens": count.get("serialized_input_tokens", count.get("input_tokens")),
            "source_selections": selections,
            "receipt_artifacts": artifacts,
            "schedule_status": schedule.get("status"),
            "one_use_gate_status": gate.get("status"),
        })
    return result


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("duplicate JSON key: " + key)
        result[key] = value
    return result


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def json_digest(value):
    data = json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    return hashlib.sha256(data).hexdigest()


def safe_path(value):
    if not isinstance(value, str) or not value or "\\" in value or ":" in value:
        raise ValueError("unsafe relative path")
    relative = PurePosixPath(value)
    if relative.is_absolute() or any(part in ("", ".", "..") for part in relative.parts):
        raise ValueError("unsafe relative path")
    resolved = (ROOT / Path(*relative.parts)).resolve()
    try:
        resolved.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError("path escapes repository") from exc
    return resolved


def mfa(value):
    if (not isinstance(value, list) or len(value) != 3
            or not isinstance(value[0], str) or not isinstance(value[1], str)
            or type(value[2]) is not int):
        raise ValueError("MFA must be a two-name, integer-arity triple")
    return tuple(value)


def exact_partition(expected, associations, gaps):
    if len(associations) != len(set(associations)) or len(gaps) != len(set(gaps)):
        raise ValueError("duplicate association or gap key")
    if set(associations) & set(gaps):
        raise ValueError("association and gap partitions overlap")
    if set(associations) | set(gaps) != set(expected):
        raise ValueError("association/gap keys differ from the exact expected set")


def validate_consumer_partitions(expected, associations, source_gaps, caller_gaps):
    """Keep source resolution and caller closure as separate keyed domains."""
    exact_partition(expected, associations, source_gaps)
    if len(caller_gaps) != len(set(caller_gaps)):
        raise ValueError("duplicate caller gap key")
    if set(caller_gaps) != set(expected):
        raise ValueError("caller gap keys differ from the exact expected set")
    return {
        "record_partition_complete": True,
        "source_resolution": "unresolved" if source_gaps else "resolved",
        "caller_closure": "incomplete" if caller_gaps else "complete",
    }


def verify_supplement_integrity(supplement):
    if not isinstance(supplement, dict):
        raise ValueError("versioned supplement is not an object")
    payload = supplement.get("canonical_payload")
    if (supplement.get("status") != "verified_integrity_only" or not isinstance(payload, dict)
            or json_digest(payload) != supplement.get("digest")):
        raise ValueError("versioned supplement digest does not reproduce")
    return supplement["digest"]


def pointer_value(value, pointer):
    if not isinstance(pointer, str) or not pointer.startswith("/"):
        raise ValueError("invalid JSON pointer")
    current = value
    for raw in pointer[1:].split("/"):
        part = raw.replace("~1", "/").replace("~0", "~")
        if isinstance(current, list):
            if not part.isdigit():
                raise ValueError("JSON pointer list index is invalid")
            current = current[int(part)]
        elif isinstance(current, dict):
            current = current[part]
        else:
            raise ValueError("JSON pointer does not resolve")
    return current


def expected_lane_records(manifest):
    authority = manifest.get("authority", {})
    authority_ids = set(authority.get("archive_original_ids", [])) | set(authority.get("preserved_lane_ids", []))
    if len(authority.get("archive_original_ids", [])) != 221 or len(authority_ids) != 226:
        raise ValueError("retained identity authority is not 221 archived plus five preserved IDs")
    if authority_ids != set(authority.get("stop_ids", [])) or authority_ids != set(authority.get("corroborated_ids", [])):
        raise ValueError("retained identity authorities disagree")
    expected, roles, unknown = {}, {}, {}
    for lane, path in LANE_PATHS.items():
        record = read_json(path)
        if record.get("lane") != lane:
            raise ValueError("lane evidence label is wrong for " + lane)
        rows = record.get("identity_rows")
        if not isinstance(rows, list):
            raise ValueError("identity rows are not a list for " + lane)
        observed_ids = [row.get("identity", {}).get("id") for row in rows]
        if len(observed_ids) != len(set(observed_ids)) or set(observed_ids) != authority_ids:
            raise ValueError("lane identity rows differ from the exact retained authority: " + lane)
        unknown_ids = set(manifest.get("lanes", {}).get(lane, {}).get("unknown_baseline_target_ids", []))
        if not unknown_ids.issubset(authority_ids):
            raise ValueError("unknown target set has a non-authoritative identity")
        expected[lane], roles[lane] = set(), {}
        unknown[lane] = unknown_ids
        for row in rows:
            original_id = row["identity"]["id"]
            baseline = row.get("baseline_mfas")
            live = row.get("live_mfas")
            if not isinstance(baseline, list) or not isinstance(live, list):
                raise ValueError("baseline/live MFA selector is not an explicit list")
            if original_id in unknown_ids and (baseline or live):
                raise ValueError("identity-level unknown target set was converted into an observed MFA set")
            seen_for_id = set()
            for selector, values in (("baseline", baseline), ("live", live)):
                for item in values:
                    key_mfa = mfa(item)
                    key = (lane, original_id, key_mfa)
                    if (original_id, key_mfa) not in seen_for_id:
                        expected[lane].add(key)
                        roles[lane].setdefault(key, set()).add(selector)
                        seen_for_id.add((original_id, key_mfa))
                    else:
                        roles[lane][key].add(selector)
    return expected, roles, unknown, authority_ids


def verify_partition(manifest):
    expected, roles, unknown, authority_ids = expected_lane_records(manifest)
    partitions = manifest.get("partitions", {})
    assoc_path = safe_path(partitions.get("associations", {}).get("path"))
    gap_path = safe_path(partitions.get("typed_gaps", {}).get("path"))
    if sha256(assoc_path) != partitions["associations"].get("sha256"):
        raise ValueError("association raw-byte hash is stale")
    if sha256(gap_path) != partitions["typed_gaps"].get("sha256"):
        raise ValueError("typed-gap raw-byte hash is stale")
    lane_records = {lane: read_json(path) for lane, path in LANE_PATHS.items()}
    lane_paths = {lane: path.relative_to(ROOT).as_posix() for lane, path in LANE_PATHS.items()}
    lane_hashes = {lane: sha256(path) for lane, path in LANE_PATHS.items()}
    associations = []
    with assoc_path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                raise ValueError("blank association row at line " + str(line_number))
            row = json.loads(line, object_pairs_hook=unique_object)
            key = (row.get("lane"), row.get("original_id"), mfa(row.get("mfa")))
            if row.get("generation") != manifest.get("generation"):
                raise ValueError("association generation is stale")
            if row.get("source_access") not in (None, "closed"):
                raise ValueError("association opens source access")
            if row.get("lane") not in ("core", "floor") or not isinstance(row.get("original_id"), str):
                raise ValueError("association has an invalid lane or identity")
            if not isinstance(row.get("source_key"), str) or not row["source_key"]:
                raise ValueError("association lacks its stable source key")
            associations.append(key)
    domains = {"source": [], "caller": [], "unknown_target_set": []}
    gap_roles = {}
    stable_gap_keys = set()
    with gap_path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                raise ValueError("blank typed-gap row at line " + str(line_number))
            row = json.loads(line, object_pairs_hook=unique_object)
            if row.get("generation") != manifest.get("generation"):
                raise ValueError("typed-gap generation is stale")
            if row.get("domain") not in domains:
                raise ValueError("unavailable/fabricated typed-gap domain")
            lane, original_id = row.get("lane"), row.get("original_id")
            if lane not in ("core", "floor") or original_id not in authority_ids:
                raise ValueError("typed gap has an unknown lane or identity")
            if row.get("evidence_status") not in ("blocked_unresolved", "blocked_identity_level_unknown"):
                raise ValueError("typed gap is marked as resolved or has an unknown status")
            if not isinstance(row.get("reason"), str) or not row["reason"] or not isinstance(row.get("remedy"), str) or not row["remedy"]:
                raise ValueError("typed gap lacks a reason or bounded remedy")
            if row.get("domain") == "unknown_target_set":
                if row.get("mfa") is not None or original_id not in unknown[lane]:
                    raise ValueError("unknown target set is not an explicit identity-level unknown")
                key = (lane, original_id)
            else:
                key_mfa = mfa(row.get("mfa"))
                key = (lane, original_id, key_mfa)
                if key not in expected[lane]:
                    raise ValueError("source/caller gap key is not in the exact lane membership union")
                if sorted(row.get("membership_roles", [])) != sorted(roles[lane][key]):
                    raise ValueError("gap row lost baseline/live membership roles")
            if row.get("domain") == "source" and row.get("source_path") is not None:
                raise ValueError("unresolved source gap claims a source path")
            if not row.get("gap_key"):
                raise ValueError("typed gap lacks its stable gap key")
            if row["gap_key"] in stable_gap_keys:
                raise ValueError("duplicate stable typed-gap key")
            stable_gap_keys.add(row["gap_key"])
            lane_record = lane_records[lane]
            lane_path = lane_paths[lane]
            lane_sha = lane_hashes[lane]
            if row.get("input_file") != lane_path or row.get("input_sha256") != lane_sha:
                raise ValueError("typed gap input binding is stale")
            selected = pointer_value(lane_record, row.get("input_pointer"))
            if row["domain"] == "unknown_target_set":
                parts = row["input_pointer"].split("/")
                identity_pointer = "/" + "/".join(parts[1:3])
                identity_row = pointer_value(lane_record, identity_pointer)
                if selected != []:
                    raise ValueError("unknown target set points to a nonempty MFA selector")
            else:
                identity_row = selected
            if not isinstance(identity_row, dict) or identity_row.get("identity", {}).get("id") != original_id:
                raise ValueError("typed gap identity pointer does not resolve")
            if row.get("owner") != identity_row.get("identity", {}).get("owner"):
                raise ValueError("typed gap owner differs from the linked identity")
            if row.get("lock_sha256") != lane_record.get("lock_sha256"):
                raise ValueError("typed gap lane lock differs from its linked record")
            if row.get("runtime") != lane_record.get("runtime"):
                raise ValueError("typed gap runtime differs from its linked record")
            archive_row = row.get("archive_row")
            preserved_ids = set(manifest.get("authority", {}).get("preserved_lane_ids", []))
            if not (type(archive_row) is int and archive_row >= 0) and not (
                archive_row is None and original_id in preserved_ids
            ):
                raise ValueError("typed gap archive row is invalid")
            if not isinstance(row.get("missing_fields"), list) or not row["missing_fields"]:
                raise ValueError("typed gap lacks explicit missing fields")
            if row["domain"] == "source" and not {"source_path", "source_bytes", "source_sha256"}.issubset(row["missing_fields"]):
                raise ValueError("source gap omits its unresolved source fields")
            if row["domain"] == "caller" and "caller_mapping" not in row["missing_fields"]:
                raise ValueError("caller gap omits its unresolved caller mapping")
            if row["domain"] == "unknown_target_set" and "target_mfa_list" not in row["missing_fields"]:
                raise ValueError("unknown target set omits its missing MFA list")
            selectors = row.get("membership_selectors")
            if row["domain"] != "unknown_target_set":
                if not isinstance(selectors, list) or not selectors:
                    raise ValueError("typed gap lacks exact membership selectors")
                for selector in selectors:
                    if selector.get("path") != lane_path or selector.get("sha256") != lane_sha:
                        raise ValueError("typed gap membership selector has a stale file binding")
                    if selector.get("role") not in ("baseline", "live"):
                        raise ValueError("typed gap membership selector has an unknown role")
                    selected_mfa = pointer_value(lane_record, selector.get("pointer"))
                    if mfa(selected_mfa) != mfa(row["mfa"]):
                        raise ValueError("typed gap membership selector does not identify its MFA")
                key = (lane, original_id, mfa(row["mfa"]))
                if sorted(row.get("membership_roles", [])) != sorted(roles[lane][key]):
                    raise ValueError("typed gap lost baseline/live membership roles")
            domains[row["domain"]].append(key)
            if row["domain"] in ("source", "caller"):
                gap_roles[(row["domain"], key)] = row.get("membership_roles")
    for lane in ("core", "floor"):
        lane_assocs = [key for key in associations if key[0] == lane]
        source_gaps = [key for key in domains["source"] if key[0] == lane]
        caller_gaps = [key for key in domains["caller"] if key[0] == lane]
        validate_consumer_partitions(expected[lane], lane_assocs, source_gaps, caller_gaps)
    for lane in ("core", "floor"):
        observed_unknown = [key[1] for key in domains["unknown_target_set"] if key[0] == lane]
        if len(observed_unknown) != len(set(observed_unknown)) or set(observed_unknown) != unknown[lane]:
            raise ValueError("identity-level unknown target sets differ from the bound list")
    return {"association_rows": len(associations), "typed_gap_rows": sum(map(len, domains.values())),
            "source_gap_rows": len(domains["source"]), "caller_gap_rows": len(domains["caller"]),
            "unknown_target_sets": len(domains["unknown_target_set"]),
            "known_mfa_keys": {lane: len(expected[lane]) for lane in ("core", "floor")}}


def verify_request_receipts(trace):
    expected = {"R1": "consumed_incomplete", "R2": "consumed_verified", "R3": "consumed_verified"}
    entries = {row.get("request_id"): row for row in trace.get("source_requests", [])}
    if set(entries) != set(expected):
        raise ValueError("source request status record is incomplete")
    for request_id, status in expected.items():
        entry = entries[request_id]
        if entry.get("status") != status or entry.get("usable_for_claims") != (request_id in ("R2", "R3")):
            raise ValueError("source request status/use policy is wrong for " + request_id)
        for key, suffix in (("schedule_sha256", "SCHEDULE"), ("review_sha256", "SCHEDULE-REVIEW"),
                            ("preflight_sha256", "EXECUTE-PREFLIGHT"), ("count_sha256", "DIRECT-COUNT"),
                            ("gate_receipt_sha256", "REQUEST-GATE")):
            path = PH4 / f"04-{request_id}-{suffix}.json"
            if not path.is_file() or sha256(path) != entry.get(key):
                raise ValueError(request_id + " " + suffix + " receipt hash is stale")
        count = read_json(PH4 / f"04-{request_id}-DIRECT-COUNT.json")
        if (count.get("status") != "pass" or count.get("generated") is not False
                or count.get("payload_truncated") is not False
                or count.get("fits_configured_context") is not True
                or count.get("serialized_input_tokens") != entry.get("serialized_input_tokens")
                or count.get("configured_model_context_tokens") != entry.get("configured_model_context_tokens")):
            raise ValueError(request_id + " direct count no longer proves individual context fit")
    return {"R1": "consumed_incomplete_excluded", "R2": "consumed_verified", "R3": "consumed_verified"}


def verify_phase4():
    manifest = read_json(MANIFEST)
    validation = read_json(VALIDATION)
    trace = read_json(TRACE)
    proof = read_json(DIGEST_PROOF)
    review = read_json(REVIEW)
    if (manifest.get("schema_version") != "04.provenance.1" or manifest.get("metadata_status") != "supported"
            or manifest.get("partition_outcome") != "complete" or manifest.get("source_access") != "closed"):
        raise ValueError("Phase 4 manifest is not a supported closed generation")
    if (validation.get("schema_version") != "04.validation.2" or validation.get("validation_passed") is not True
            or validation.get("full_package_valid") is not True or validation.get("source_access") != "closed"
            or validation.get("generation") != manifest.get("generation")
            or validation.get("semantic_closure") != "open"):
        raise ValueError("Phase 4 final validation is absent, stale, or overclaims closure")
    for key, path in (("coverage_caller_trace", TRACE), ("sizing_digest_proof", DIGEST_PROOF)):
        binding = manifest.get(key, {})
        if (binding.get("path") != path.relative_to(ROOT).as_posix() or binding.get("sha256") != sha256(path)
                or binding.get("bytes") != path.stat().st_size):
            raise ValueError(key + " hash binding is stale")
    status_ref = manifest.get("current_source_request_status", {})
    if (status_ref.get("path") != TRACE.relative_to(ROOT).as_posix() or status_ref.get("sha256") != sha256(TRACE)
            or status_ref.get("status_by_request") != {"R1": "consumed_incomplete", "R2": "consumed_verified", "R3": "consumed_verified"}):
        raise ValueError("manifest confuses historical source-gate snapshot with current receipts")
    if trace.get("generation") != manifest.get("generation") or trace.get("source_access") != "closed":
        raise ValueError("coverage/caller trace generation or access status is invalid")
    if trace.get("source_resolution", {}).get("status") != "unresolved" or trace.get("caller_closure", {}).get("status") != "incomplete":
        raise ValueError("Phase 4 evidence claims source or caller closure")
    if trace.get("claims_not_made") != ["source resolution", "caller closure", "runtime safety", "absence of dynamic callers"]:
        raise ValueError("required source/caller limitations are missing")
    partition = verify_partition(manifest)
    if trace.get("record_partition", {}).get("typed_gap_rows") != partition["typed_gap_rows"]:
        raise ValueError("trace partition counts differ from the exact files")
    request_status = verify_request_receipts(trace)
    if proof.get("generation") != manifest.get("generation") or proof.get("source_access") != "closed":
        raise ValueError("digest proof generation or access status is invalid")
    if proof.get("legacy_recipe", {}).get("status") != "unresolved" or proof.get("legacy_recipe", {}).get("digest") is not None:
        raise ValueError("legacy digest is falsely claimed as reproduced")
    supplement = proof.get("supplement", {})
    verify_supplement_integrity(supplement)
    bindings = validation.get("bindings", {})
    if (bindings.get("manifest_sha256") != sha256(MANIFEST)
            or bindings.get("evidence_review_sha256") != sha256(REVIEW)
            or bindings.get("caller_trace_sha256") != sha256(TRACE)
            or bindings.get("digest_proof_sha256") != sha256(DIGEST_PROOF)):
        raise ValueError("Phase 4 final validation hashes are stale")
    if (review.get("status") != "pass" or review.get("source_access") != "closed"
            or review.get("subject_sha256") is None):
        raise ValueError("independent Phase 4 evidence review did not pass")
    for lane in ("core", "floor"):
        stops = read_json(LANE_PATHS[lane]).get("stops", {})
        if (stops.get("candidate") is not None or stops.get("implementation_authorized") is not False
                or stops.get("aggregate_gate") != "open" or stops.get("walking_skeleton") != "blocked"
                or stops.get("sec_01") != "Pending"):
            raise ValueError("Phase 3 safety stops changed in " + lane)
    sizing = read_json(SIZING)
    if sizing.get("candidate") is not None or sizing.get("implementation_authorized") is not False:
        raise ValueError("candidate or implementation authority was changed")
    return {"status": "pass_with_open_gaps", "source_access": "closed",
            "generation": manifest["generation"], "partition": partition,
            "source_requests": request_status, "source_resolution": "unresolved",
            "caller_closure": "incomplete", "legacy_digest": "unresolved",
            "candidate": None, "implementation_authorized": False}


def identity_membership_index(expected, unknown):
    result = []
    for lane in ("core", "floor"):
        path = LANE_PATHS[lane]
        record = read_json(path)
        lane_path = path.relative_to(ROOT).as_posix()
        lane_hash = sha256(path)
        for index, row in enumerate(record["identity_rows"]):
            identity_id = row["identity"]["id"]
            baseline = [mfa(value) for value in row["baseline_mfas"]]
            live = [mfa(value) for value in row["live_mfas"]]
            identity_keys = sorted(key for key in expected[lane] if key[1] == identity_id)
            result.append({
                "lane": lane,
                "identity_id": identity_id,
                "owner": row["identity"]["owner"],
                "identity_class": row["identity"]["identity_class"],
                "record_pointer": f"/identity_rows/{index}",
                "record_sha256": json_digest(row),
                "record_file": {"path": lane_path, "sha256": lane_hash},
                "baseline_mfa_count": len(baseline),
                "baseline_mfa_sha256": json_digest(baseline),
                "live_mfa_count": len(live),
                "live_mfa_sha256": json_digest(live),
                "exact_key_count": len(identity_keys),
                "unknown_target_set": identity_id in unknown[lane],
            })
    return result


def complete_gap_index(manifest):
    partition = manifest["partitions"]["typed_gaps"]
    path = safe_path(partition["path"])
    result = []
    with path.open(encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            row = json.loads(line, object_pairs_hook=unique_object)
            result.append({
                "domain": row["domain"],
                "lane": row["lane"],
                "identity_id": row["original_id"],
                "mfa": row["mfa"],
                "gap_key": row["gap_key"],
                "evidence_status": row["evidence_status"],
                "reason": row["reason"],
                "remedy": row["remedy"],
                "missing_fields": row["missing_fields"],
                "membership_roles": row["membership_roles"],
                "linked_identity": {
                    "path": row["input_file"],
                    "pointer": row["input_pointer"],
                },
                "typed_gap_line": line_number,
                "row_independent_review": row.get("independent_review"),
            })
    return result


def special_identity_partitions():
    result = {}
    for lane, path in LANE_PATHS.items():
        record = read_json(path)
        result[lane] = {}
        for identity_id in ("EX-010", "EX-107"):
            row = next(item for item in record["identity_rows"]
                       if item["identity"]["id"] == identity_id)
            fields = ("baseline_mfas", "original_live_mfas", "replacement_live_mfas",
                      "delivered_scope_mfas", "delivered_mfas", "pending_mfas",
                      "historical_partition_mfas", "historical_complement_mfas",
                      "pending_after_delivered_and_historical_mfas")
            result[lane][identity_id] = {
                "owner": row["identity"]["owner"],
                "mapping_status": row["mapping_status"],
                "delivered_slice_owner": row.get("delivered_slice_owner"),
                "counts": {field: len(row.get(field, [])) for field in fields},
                "canonical_mfa_set_sha256": {
                    field: json_digest([mfa(value) for value in row.get(field, [])])
                    for field in fields
                },
                "record_pointer": f"/identity_rows/{next(i for i, item in enumerate(record['identity_rows']) if item['identity']['id'] == identity_id)}",
                "record_file": {"path": path.relative_to(ROOT).as_posix(), "sha256": sha256(path)},
            }
    return result


def build_recovery_crosswalk():
    manifest = read_json(MANIFEST)
    trace = read_json(TRACE)
    proof = read_json(DIGEST_PROOF)
    expected, roles, unknown, authority_ids = expected_lane_records(manifest)
    partition = verify_partition(manifest)
    gap_index = complete_gap_index(manifest)
    gap_counts = Counter((row["lane"], row["domain"]) for row in gap_index)
    association_path = safe_path(manifest["partitions"]["associations"]["path"])
    association_counts = Counter()
    with association_path.open(encoding="utf-8") as stream:
        for line in stream:
            if line.strip():
                association_counts[json.loads(line, object_pairs_hook=unique_object)["lane"]] += 1
    inputs = [
        {"path": path.relative_to(ROOT).as_posix(), "sha256": sha256(path), "bytes": path.stat().st_size}
        for path in (MANIFEST, VALIDATION, REVIEW, TRACE, DIGEST_PROOF, SIZING,
                     LANE_PATHS["core"], LANE_PATHS["floor"])
    ]
    inputs.extend({
        "path": safe_path(manifest["partitions"][name]["path"]).relative_to(ROOT).as_posix(),
        "sha256": manifest["partitions"][name]["sha256"],
        "bytes": safe_path(manifest["partitions"][name]["path"]).stat().st_size,
    } for name in ("associations", "typed_gaps"))
    implementation_bindings = [
        {"path": path.relative_to(ROOT).as_posix(), "sha256": sha256(path),
         "bytes": path.stat().st_size}
        for path in (PH3 / "03-05-validate-evidence.py", CONSUMER_HELPER, CONTRACT_TEST)
    ]
    source_requests = phase3_source_requests()
    lane_summaries = {}
    for lane in ("core", "floor"):
        record_path = LANE_PATHS[lane]
        record = read_json(record_path)
        lane_unknown = sorted(unknown[lane])
        source_gaps = gap_counts[(lane, "source")]
        caller_gaps = gap_counts[(lane, "caller")]
        lane_summaries[lane] = {
            "identity_count": len(record["identity_rows"]),
            "identity_authority_count": len(authority_ids),
            "expected_mfa_key_count": len(expected[lane]),
            "membership_selector": "$.identity_rows[*].{baseline_mfas,live_mfas}",
            "identity_membership_path": record_path.relative_to(ROOT).as_posix(),
            "identity_membership_sha256": sha256(record_path),
            "source_associations": association_counts[lane],
            "source_gaps": source_gaps,
            "caller_gaps": caller_gaps,
            "unknown_target_sets": lane_unknown,
            "unknown_target_set_count": len(lane_unknown),
        }
    sizing = read_json(SIZING)
    projection = {
        lane: sizing["lane_records"][lane]["target_source_gaps"]["count"]
        for lane in ("core", "floor")
    }
    supplement = proof["supplement"]
    return {
        "schema": "fablebook.phase3.recovery-keyed-crosswalk/1",
        "generation": manifest["generation"],
        "source_access": "closed",
        "authority": {
            "original_identity_count": len(authority_ids),
            "archive_original_id_count": len(manifest["authority"]["archive_original_ids"]),
            "preserved_lane_id_count": len(manifest["authority"]["preserved_lane_ids"]),
            "identity_membership_index": "identity_membership_index",
        },
        "bindings": inputs,
        "phase3_consumer_implementation": implementation_bindings,
        "phase3_source_requests": source_requests,
        "package_independent_review": {
            "path": REVIEW.relative_to(ROOT).as_posix(),
            "sha256": sha256(REVIEW),
            "status": "pass",
        },
        "complete_gap_index_binding": {
            "path": manifest["partitions"]["typed_gaps"]["path"],
            "sha256": manifest["partitions"]["typed_gaps"]["sha256"],
            "row_count": partition["typed_gap_rows"],
        },
        "record_partition": partition,
        "semantic_status": {
            "record_completeness": "complete",
            "record_partition_complete": True,
            "source_resolution": "unresolved",
            "target_source_coverage_complete": False,
            "source_join_complete": False,
            "caller_closure": "incomplete",
            "caller_closure_complete": False,
            "legacy_digest": "unresolved",
            "candidate": None,
            "implementation_authorized": False,
            "actual_library_collision": None,
        },
        "coverage_flag_derivation": trace["coverage_flag_derivation"],
        "source_resolution_detail": trace["source_resolution"],
        "caller_closure_detail": trace["caller_closure"],
        "unavailable_domains": manifest["unavailable_domains"],
        "lanes": lane_summaries,
        "identity_membership_index": identity_membership_index(expected, unknown),
        "complete_gap_index": gap_index,
        "special_identity_partitions": special_identity_partitions(),
        "phase3_sizing_projection": {
            "path": SIZING.relative_to(ROOT).as_posix(),
            "sha256": sha256(SIZING),
            "source_gap_counts": projection,
            "phase4_source_gap_counts": {lane: lane_summaries[lane]["source_gaps"] for lane in ("core", "floor")},
            "relationship": "unresolved; selectors differ, so these counts are not reconciled",
        },
        "sizing_digest_proof": {
            "legacy_recipe_status": proof["legacy_recipe"]["status"],
            "legacy_digest": proof["legacy_recipe"]["digest"],
            "versioned_supplement_status": supplement["status"],
            "versioned_supplement_schema": supplement["schema"],
            "versioned_supplement_digest": supplement["digest"],
            "versioned_supplement_selector": supplement["selector"],
        },
        "source_requests": trace["source_requests"],
        "claims_not_made": trace["claims_not_made"],
        "safety_stops": manifest["safety_stops"],
        "retained_checkpoints": {
            "macro_caller_ast": "unresolved_unwaived",
            "explanation_wording": "unresolved_unwaived",
        },
    }


def recovery_document(payload):
    partition = payload["record_partition"]
    statuses = payload["semantic_status"]
    special = payload["special_identity_partitions"]
    body = [
        "# Phase 03 recovery reconciliation\n\n",
        "This is the current read-only crosswalk for the supported Phase 4 evidence generation. It keeps record accounting separate from source and caller meaning. It does not change the preserved lane JSON, sizing record, or historical reconciliation.\n\n",
        "## Result\n\n",
        f"- Exact record accounting: {partition['typed_gap_rows']} typed-gap rows, {partition['association_rows']} resolved source associations, and {partition['unknown_target_sets']} explicit unknown target sets.\n",
        f"- Source resolution: {statuses['source_resolution']} ({partition['source_gap_rows']} source gaps). Caller closure: {statuses['caller_closure']} ({partition['caller_gap_rows']} caller gaps).\n",
        "- Legacy sizing digest: unresolved. The separately versioned Phase 4 supplement proves integrity for its own selector only.\n",
        "- Candidate: null. Implementation is unauthorized; actual library collision remains unknown.\n\n",
        "## Phase 3 source-request receipts\n\n",
        "Seven one-use source requests are linked below. T2-R1 was clipped, unused for analysis, and excluded without replay; T2-R2 through T2-R7 have complete delivery receipts. Each request links its schedule, review, count, preflight, gate and emission receipt. The current validator, helper and contract-test hashes are also bound separately from the earlier source spans.\n\n",
        "## Linked membership and gap records\n\n",
        "The machine record below lists every identity and every keyed source, caller, and unknown-target gap. Each identity entry points to the exact row in its immutable lane record; each gap entry points to its exact JSONL line and membership selector. The linked Phase 4 package review covers the evidence package, while a null row review field means that individual gap has no separate review.\n\n",
        "Lane key counts are 2,469 core and 2,380 floor. Phase 4 source gaps are 2,469 core and 2,380 floor; the older Phase 3 sizing projection separately records ",
        f"{payload['phase3_sizing_projection']['source_gap_counts']['core']} core and {payload['phase3_sizing_projection']['source_gap_counts']['floor']} floor gaps. Their selector relationship remains unresolved, so these counts are not reconciled.\n\n",
        "## Historical identity partitions\n\n",
        "EX-010 and EX-107 are reported from the preserved per-lane identity rows independently; the machine record includes counts and canonical MFA-set hashes for baseline, live, delivered, pending, and historical partitions.\n\n",
        "The separate Macro caller-AST and explanation/wording checkpoints remain unresolved and unwaived. Source resolution, caller closure, actual collision, and runtime safety are not inferred from complete row accounting.\n\n",
        f"Machine crosswalk SHA-256: `{json_digest(payload)}`\n\n",
        "<!-- RECOVERY-CROSSWALK:BEGIN -->\n```json\n",
        json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")),
        "\n```\n<!-- RECOVERY-CROSSWALK:END -->\n",
    ]
    return "".join(body)


def verify_consumer():
    result = verify_phase4()
    reconciliation = PH3 / "03-RECOVERY-RECONCILIATION.md"
    if not reconciliation.is_file():
        raise ValueError("Phase 3 recovery reconciliation has not been written")
    text = reconciliation.read_text(encoding="utf-8")
    expected = build_recovery_crosswalk()
    marker = "<!-- RECOVERY-CROSSWALK:BEGIN -->\n```json\n"
    end_marker = "\n```\n<!-- RECOVERY-CROSSWALK:END -->"
    if marker not in text or end_marker not in text:
        raise ValueError("Phase 3 recovery reconciliation has no complete machine crosswalk")
    encoded = text.split(marker, 1)[1].split(end_marker, 1)[0]
    observed = json.loads(encoded, object_pairs_hook=unique_object)
    if observed != expected:
        raise ValueError("Phase 3 recovery crosswalk differs from the exact linked evidence")
    if f"Machine crosswalk SHA-256: `{json_digest(expected)}`" not in text:
        raise ValueError("Phase 3 recovery crosswalk digest is missing or stale")
    required = ("04-PROVENANCE-MANIFEST.json", "source resolution: unresolved",
                "caller closure: incomplete", "legacy sizing digest: unresolved",
                "candidate: null", "unknown")
    if any(item.lower() not in text.lower() for item in required):
        raise ValueError("Phase 3 recovery reconciliation omits a required evidence distinction")
    return {"status": "consumer_consistent", "source_access": "closed",
            "generation": result["generation"], "partition": result["partition"],
            "identity_membership_rows": len(expected["identity_membership_index"]),
            "complete_gap_index_rows": len(expected["complete_gap_index"]),
            "crosswalk_sha256": json_digest(expected)}


def self_test():
    checks = 0
    def rejects(fn):
        nonlocal checks
        try:
            fn()
        except (ValueError, OSError):
            checks += 1
            return
        raise AssertionError("negative control unexpectedly passed")
    rejects(lambda: json.loads('{"x":1,"x":2}', object_pairs_hook=unique_object))
    rejects(lambda: mfa(["Mod", "call", True]))
    rejects(lambda: safe_path("../escape"))
    rejects(lambda: safe_path("/absolute"))
    key = ("core", "EX-001", ("Mod", "call", 1))
    exact_partition([key], [], [key]); checks += 1
    rejects(lambda: exact_partition([key], [], []))
    rejects(lambda: exact_partition([key], [key], [key]))
    rejects(lambda: exact_partition([key], [], [key, key]))
    rejects(lambda: exact_partition([key], [], [("floor", "EX-001", ("Mod", "call", 1))]))
    key2 = ("core", "EX-002", ("Mod", "call", 2))
    open_fixture = validate_consumer_partitions([key, key2], [key], [key2], [key, key2])
    if open_fixture != {"record_partition_complete": True, "source_resolution": "unresolved",
                        "caller_closure": "incomplete"}:
        raise AssertionError("complete-but-unresolved consumer fixture failed")
    checks += 1
    rejects(lambda: validate_consumer_partitions([key, key2], [key], [], [key, key2]))
    rejects(lambda: validate_consumer_partitions([key, key2], [key], [key2], [key]))
    rejects(lambda: validate_consumer_partitions([key, key2], [key], [key2], [key2, key2]))
    fixture_payload = {"schema": "test.supplement/1", "selector": {"keys": ["a", "b"]}}
    fixture = {"status": "verified_integrity_only", "canonical_payload": fixture_payload,
               "digest": json_digest(fixture_payload)}
    verify_supplement_integrity(fixture)
    checks += 1
    rejects(lambda: verify_supplement_integrity({**fixture, "digest": "0" * 64}))
    rejects(lambda: verify_supplement_integrity({**fixture, "status": "resolved"}))
    return {"status": "pass", "checks": checks, "writes_repository_inputs": False}


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group(required=True)
    modes.add_argument("--self-test", action="store_true")
    modes.add_argument("--phase4-only", action="store_true")
    modes.add_argument("--consumer", action="store_true")
    args = parser.parse_args()
    try:
        if args.self_test:
            result = self_test()
        elif args.phase4_only:
            result = verify_phase4()
        else:
            result = verify_consumer()
        print(json.dumps(result, separators=(",", ":")))
        return 0
    except (OSError, ValueError, AssertionError, KeyError, TypeError) as exc:
        print(json.dumps({"status": "fail", "error": str(exc)}, separators=(",", ":")))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
