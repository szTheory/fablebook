#!/usr/bin/env python3
"""Build and validate the current, evidence-only Phase 7 rebaseline."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import struct
import sys
from pathlib import Path


HERE = Path(__file__).resolve().parent
PHASE = HERE.parent
ROOT = PHASE.parents[2]
LOCK = ROOT / "mix.lock"
FLOOR_LOCK = ROOT / "mix.floor.lock"
BASE_LOCK = HERE / "07-BASE-CORE-LOCK.lock"
PATCH = HERE / "07-DEPENDENCY-PATCH.json"
MANIFEST = HERE / "07-CORE-CURRENT-BEAM-MANIFEST.jsonl"
ROOTS = HERE / "07-CORE-CURRENT-BEAM-ROOTS.json"
EXPORTS = HERE / "07-CORE-EXPORTS.jsonl"
EXPORT_SUMMARY = HERE / "07-CORE-CURRENT.json"
EXPORT_REVIEW = HERE / "07-CORE-EXPORT-REVIEW.md"
EXPORT_APPROVAL = HERE / "07-CORE-EXPORT-READER-APPROVAL.json"
SCHEDULE = HERE / "07-CURRENT-SOURCE-SCHEDULE.json"
SCHEDULE_REVIEW = HERE / "07-CURRENT-SOURCE-SCHEDULE-REVIEW.md"
SCHEDULE_APPROVAL = HERE / "07-CURRENT-SOURCE-APPROVAL.json"
RECONCILIATION = HERE / "07-RECONCILIATION.json"
SAVED_MEMBERSHIP = PHASE / "07-CORE-CURRENT-ROW-MEMBERSHIP.jsonl"
OLD_RECONCILIATION = PHASE / "07-RECONCILIATION.json"
OLD_SCHEDULE = PHASE / "07-SOURCE-SCHEDULE.json"
OLD_OBSERVATIONS = (PHASE / "07-OBSERVATIONS-01.jsonl", PHASE / "07-OBSERVATIONS-02.jsonl")
OLD_CONSUMPTION = PHASE / "07-SOURCE-READ-CONSUMPTION"
EXPECTED_CURRENT_LOCK = "3c55e9ec28da1fe2f8ded5a8b5e6504542c3536df25c704933cd7ace85224207"
EXPECTED_FLOOR_LOCK = "ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847"
EXPECTED_MIX_EXS = "0d8aae670b99fd5d3d519c0ec16bd44455397bc98f1a8f8b33864255f3e61ac9"
EXPECTED_TOOL_VERSIONS = "0d8e4f1d2fbde0cd63e4c45a60bbb4827058a592ee8b37057980627fcb517233"
LIVEVIEW_PACKAGE_SHA = "80a248539e566eea8598079b12bfb1a9c1f3180d4db3ecd215d28798dcebc44b"
LIVEVIEW_REPO_SHA = "1ca75ed52d3916f93299de990f152f3f49202d12849e526bf5f9b89b4ccf25f2"
REQUEST_IDS = [f"core-source-{n:02d}" for n in range(1, 6)]
STOP_STATE = {
    "actual_library_collision": "unknown",
    "aggregate_gate": "open",
    "automatic_followup": False,
    "candidate": None,
    "candidate_fit": "unresolved",
    "legacy_digest": "unresolved",
    "macro_caller_ast": "unresolved",
    "macro_explanation": "unresolved",
    "r9": {"authorization": "denied", "consumption": "not_consumed", "id": "R9", "one_use_gate_validation": "valid_denial"},
    "sec_01": "Pending",
    "walking_skeleton": "blocked",
}


def sha(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def json_bytes(value) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()


def write_new(path: Path, data: bytes) -> None:
    if path.exists():
        raise ValueError(f"refusing to overwrite existing evidence: {path.name}")
    path.write_bytes(data)


def load_jsonl(path: Path):
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line]


def current_exports():
    return load_jsonl(EXPORTS)


def canonical_mfa_bytes(rows):
    encoded = bytearray()
    mf_as = sorted({(row["module"], row["function"], row["arity"]) for row in rows})
    for module, function, arity in mf_as:
        for value in (module, function):
            raw = value.encode("utf-8", "strict")
            encoded.extend(struct.pack(">I", len(raw)))
            encoded.extend(raw)
        encoded.extend(struct.pack(">I", arity))
    return bytes(encoded)


def validate_current_export_summary():
    manifest_data = MANIFEST.read_bytes()
    manifest_rows = load_jsonl(MANIFEST)
    if not manifest_rows or manifest_rows[0].get("type") != "identity":
        raise ValueError("current manifest identity row is missing")
    manifest_identity = manifest_rows[0]
    manifest_digest = sha(manifest_data)
    beam_rows = [row for row in manifest_rows if row.get("type") == "beam"]
    manifest_roots = [row for row in manifest_rows if row.get("type") == "root"]
    producer_path = HERE / "07-CORE-EXPORT-INVENTORY.py"
    if producer_path.is_symlink() or not producer_path.is_file():
        raise ValueError("reviewed export producer is not a regular, non-symlink file")
    producer_source = producer_path.read_bytes()
    producer_digest = sha(producer_source)
    if (manifest_identity.get("schema") != "fablebook.phase7.compiled_manifest.v3"
            or manifest_identity.get("lock_sha256") != EXPECTED_CURRENT_LOCK
            or manifest_identity.get("mix_exs_sha256") != EXPECTED_MIX_EXS
            or manifest_identity.get("tool_versions_sha256") != EXPECTED_TOOL_VERSIONS
            or manifest_identity.get("producer_sha256") != producer_digest):
        raise ValueError("current manifest identity differs from the approved lock/toolchain")

    root_summary = {
        "schema": "fablebook.phase7.compiled_roots.v2",
        "manifest_sha256": manifest_digest,
        "root_count": len(manifest_roots),
        "beam_file_count": sum(row["beam_count"] for row in manifest_roots),
        "beam_bytes": sum(row["beam_bytes"] for row in manifest_roots),
        "roots": manifest_roots,
    }
    roots_data = (json.dumps(root_summary, sort_keys=True, separators=(",", ":")) + "\n").encode()
    if ROOTS.read_bytes() != roots_data:
        raise ValueError("current root summary does not match the exact reviewed manifest")
    approval = read_json(EXPORT_APPROVAL)
    review_data = EXPORT_REVIEW.read_bytes()
    expected_approval = {
        "schema": "fablebook.phase7.exports_review.v2", "verdict": "PASS",
        "review_file_sha256": sha(review_data), "producer_sha256": producer_digest,
        "manifest_sha256": manifest_digest, "root_summary_sha256": sha(roots_data),
    }
    if (set(approval) != set(expected_approval) | {"reviewer"}
            or any(approval.get(key) != value for key, value in expected_approval.items())
            or not isinstance(approval.get("reviewer"), str)
            or not approval["reviewer"].strip()):
        raise ValueError("current producer/manifest approval is invalid before producer import")
    review_text = review_data.decode("utf-8", "strict")
    if any(value not in review_text for value in (
            "PASS", manifest_digest, producer_digest, sha(roots_data), approval["reviewer"])):
        raise ValueError("current review does not bind PASS to the exact producer and manifest")

    # Only execute the inventory code after its digest is bound to the exact independent approval.
    spec = importlib.util.spec_from_file_location("phase7_core_export_inventory", producer_path)
    if spec is None or spec.loader is None:
        raise ValueError("reviewed export producer could not be loaded for deterministic validation")
    producer = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = producer
    exec(compile(producer_source, str(producer_path), "exec"), producer.__dict__)
    context = producer.context()
    if context.get("producer_sha256") != producer_digest:
        raise ValueError("loaded producer identity differs from its pre-import approval")
    fresh_manifest_rows = producer.manifest_rows(context)
    producer.validate_exact_manifest_membership(manifest_data, fresh_manifest_rows)
    producer.validate_approval(context, manifest_digest, sha(roots_data))

    exports_rows = []
    total_table_bytes = 0
    for row in beam_rows:
        path = producer.resolve_manifest_path(row["path"], context)
        file_exports, table_bytes = producer.reader_for_file(path, row)()
        total_table_bytes += table_bytes
        if total_table_bytes > producer.MAX_TOTAL_TABLE_BYTES:
            raise ValueError("approved BEAM selected-table read limit was exceeded")
        file_digest = producer.sha256(producer.canonical_export_bytes(file_exports))
        for module, function, arity in file_exports:
            exports_rows.append({
                "kind": row["kind"], "app": row["app"], "app_version": row["app_version"],
                "package": row["package"], "package_version": row["package_version"],
                "lock_checksums": row["lock_checksums"], "beam_path": row["path"],
                "beam_bytes": row["bytes"], "beam_device": row["device"], "beam_inode": row["inode"],
                "beam_mtime_ns": row["mtime_ns"], "beam_ctime_ns": row["ctime_ns"],
                "exports_sha256": file_digest, "module": module,
                "function": function, "arity": arity,
            })
    exports_rows.sort(key=lambda row: (row["module"], row["function"], row["arity"], row["beam_path"]))
    mfa_keys = [(row["module"], row["function"], row["arity"]) for row in exports_rows]
    if len(mfa_keys) != len(set(mfa_keys)):
        raise ValueError("approved BEAM scan contains a duplicate MFA")
    module_paths = {}
    for row in exports_rows:
        previous_path = module_paths.setdefault(row["module"], row["beam_path"])
        if previous_path != row["beam_path"]:
            raise ValueError("approved BEAM scan maps a module to multiple files")
    exports_data = producer.canonical_jsonl(exports_rows)
    identity = manifest_identity
    expected_summary = {
        "schema": "fablebook.phase7.compiled_exports.v3",
        "lock_sha256": identity["lock_sha256"], "tool_versions_sha256": identity["tool_versions_sha256"],
        "mix_exs_sha256": identity["mix_exs_sha256"], "otp_version": identity["otp_version"],
        "elixir_version": identity["elixir_version"], "producer_sha256": producer_digest,
        "manifest_sha256": manifest_digest,
        "generation_id": "phase7-security-rebaseline-" + manifest_digest[:16],
        "beam_file_count": len(beam_rows), "export_count": len(exports_rows),
        "exports_jsonl_sha256": sha(exports_data),
        "exports_mfa_sha256": sha(canonical_mfa_bytes(exports_rows)),
        "selected_chunk_bytes": total_table_bytes,
        "input_atom_boundary": "BEAM atom names remain UTF-8 strings; no term or atom decoder is used",
        "source_file_hashes_complete": False,
        "old_whole_inventory_member_list_available": False,
    }
    actual_exports_data = EXPORTS.read_bytes()
    actual_summary_data = EXPORT_SUMMARY.read_bytes()
    actual_summary = read_json(EXPORT_SUMMARY)
    if actual_exports_data != exports_data or actual_summary != expected_summary:
        raise ValueError("current export files or summary differ from the exact approved BEAM scan")
    liveview_roots = [row for row in manifest_roots if row.get("package") == "phoenix_live_view"]
    liveview_exports = [row for row in exports_rows if row.get("package") == "phoenix_live_view"]
    if (len(liveview_roots) != 1 or not liveview_exports
            or liveview_roots[0].get("package_version") != "1.2.14"
            or liveview_roots[0].get("lock_checksums") != [LIVEVIEW_PACKAGE_SHA, LIVEVIEW_REPO_SHA]
            or any(row.get("package_version") != "1.2.14"
                   or row.get("lock_checksums") != [LIVEVIEW_PACKAGE_SHA, LIVEVIEW_REPO_SHA]
                   for row in liveview_exports)):
        raise ValueError("LiveView root/export rows do not match the approved 1.2.14 checksums")
    return actual_summary, manifest_digest, producer_digest


def current_lock_checks():
    before = BASE_LOCK.read_bytes()
    current = LOCK.read_bytes()
    if sha(current) != EXPECTED_CURRENT_LOCK:
        raise ValueError("current mix.lock digest differs from the approved rebaseline")
    if sha(FLOOR_LOCK.read_bytes()) != EXPECTED_FLOOR_LOCK:
        raise ValueError("floor lock changed")
    old_entry = re.search(rb'^  "phoenix_live_view": (.*)$', before, re.M)
    current_entry = re.search(rb'^  "phoenix_live_view": (.*)$', current, re.M)
    if not old_entry or not current_entry:
        raise ValueError("LiveView lock entry is absent")
    if not old_entry.group(1).startswith(b'{:hex, :phoenix_live_view, "1.2.13",'):
        raise ValueError("base lock does not carry the expected LiveView version")
    if b'{:hex, :phoenix_live_view, "1.2.14", "' + LIVEVIEW_PACKAGE_SHA.encode() not in current_entry.group(1):
        raise ValueError("current LiveView version/checksum differs from the approved pin")
    if (ROOT / "mix.exs").is_file() and sha((ROOT / "mix.exs").read_bytes()) != EXPECTED_MIX_EXS:
        raise ValueError("mix.exs changed")
    return sha(before), sha(current)


def compare_saved_membership():
    rows = load_jsonl(SAVED_MEMBERSHIP)
    core_rows = [row for row in rows if row.get("lane") == "core"]
    if len(core_rows) != 226 or len({row.get("identity_id") for row in core_rows}) != 226:
        raise ValueError("saved core membership does not contain exactly 226 unique rows")
    export_map = {(row["module"], row["function"], row["arity"]): row for row in current_exports()}
    members = []
    missing = []
    unexpected = []
    for row in core_rows:
        identity_id = row["identity_id"]
        if row.get("membership_status") != "reconciled":
            raise ValueError(f"saved row is not reconciled: {identity_id}")
        for raw_mfa in row.get("saved_live_mfas", []):
            mfa = tuple(raw_mfa)
            current = export_map.get(mfa)
            if current is None:
                missing.append((identity_id, mfa))
                continue
            expected = None
            for field in row.get("mfa_fields", {}).values():
                for check in field.get("checks", []):
                    if tuple(check.get("mfa", [])) == mfa and check.get("package_identity"):
                        expected = check.get("package_identity")
                        break
                if expected:
                    break
            if expected is None:
                for check in row.get("lane_match_checks", {}).get("core", {}).get("checks", []):
                    if tuple(check.get("mfa", [])) == mfa and check.get("package_identity"):
                        expected = check.get("package_identity")
                        break
            if expected is None:
                for addition in row.get("current_known_additions", []):
                    if tuple(addition.get("mfa", [])) == mfa:
                        expected = addition.get("package_identity")
                        break
            if expected is None:
                raise ValueError(f"saved MFA lacks expected identity: {identity_id} {mfa}")
            expected_liveview = expected.get("package") == "phoenix_live_view"
            checks = ("kind", "app", "package")
            if any(current.get(field) != expected.get(field) for field in checks):
                unexpected.append((identity_id, mfa, "package kind/app changed"))
            if expected_liveview:
                if (current.get("app_version") != "1.2.14"
                        or current.get("package_version") != "1.2.14"
                        or current.get("lock_checksums") != [LIVEVIEW_PACKAGE_SHA, LIVEVIEW_REPO_SHA]):
                    unexpected.append((identity_id, mfa, "LiveView identity is not the approved 1.2.14 pin"))
            elif any(current.get(field) != expected.get(field) for field in ("app_version", "package_version", "lock_checksums")):
                unexpected.append((identity_id, mfa, "non-LiveView package/runtime identity changed"))
            members.append({"identity_id": identity_id, "mfa": list(mfa)})
    if missing:
        raise ValueError(f"saved core MFA missing from current exports: {missing[:5]}")
    if unexpected:
        raise ValueError(f"unexpected saved core MFA identity change: {unexpected[:5]}")
    members.sort(key=lambda x: (x["identity_id"], *x["mfa"]))
    previous = read_json(OLD_RECONCILIATION)["lanes"]["core"]["membership"]
    previous_sorted = sorted(previous, key=lambda x: (x["identity_id"], *x["mfa"]))
    if members != previous_sorted:
        raise ValueError("current saved-row membership differs from the prior complete core membership")
    return core_rows, members


def derive_schedule():
    base_digest, lock_digest = current_lock_checks()
    core_rows, members = compare_saved_membership()
    old_schedule = read_json(OLD_SCHEDULE)
    old_entries = [entry for entry in old_schedule["entries"] if entry.get("lane") == "core"]
    if len(old_entries) != 5:
        raise ValueError("expected exactly five prior core schedule entries")
    observations = {}
    for path in OLD_OBSERVATIONS:
        for row in load_jsonl(path):
            if row.get("lane") == "core":
                observations[row["request_id"]] = row
    current_summary = read_json(EXPORT_SUMMARY)
    liveview = next(row for row in current_exports() if row.get("package") == "phoenix_live_view")
    entries = []
    for old in old_entries:
        request_id = old["request_id"]
        observation = observations[request_id]
        old_identity = old["source_identity"]
        current_identity = dict(old_identity)
        current_identity["lock_sha256"] = lock_digest
        if old_identity.get("package") == "phoenix_live_view":
            current_identity.update({
                "version": "1.2.14", "package_checksum": LIVEVIEW_PACKAGE_SHA,
                "repo_checksum": LIVEVIEW_REPO_SHA,
            })
            evidence_status = "gap_no_retry_identity_changed"
            reason = "Prior core-source-03 is consumed and has no durable source hash; its LiveView package identity changed. Do not reuse or reopen the request."
            source_sha = None
        elif old_identity.get("package") == "plug":
            provenance = observation.get("file_provenance") or {}
            current_export = next(row for row in current_exports() if row.get("package") == "plug")
            if (observation.get("observation_status") != "parsed"
                    or not provenance.get("sha256")
                    or provenance["sha256"] != observation.get("file_provenance", {}).get("sha256")
                    or old_identity.get("package_checksum") != current_export.get("lock_checksums", [None])[0]):
                raise ValueError("Plug carry-forward lacks matching durable source/package identity")
            evidence_status = "carry_forward_exact_source_and_package_identity"
            reason = "Prior parsed observation carries forward: durable source SHA and package checksum remain exact; original and current lock bindings are both retained."
            source_sha = provenance["sha256"]
        elif old_identity.get("package") == "phoenix":
            current_identity["version"] = "1.8.16"
            current_export = next(row for row in current_exports() if row.get("package") == "phoenix")
            current_identity.update({"package_checksum": current_export["lock_checksums"][0], "repo_checksum": current_export["lock_checksums"][1]})
            evidence_status = "gap_consumed_no_durable_hash_no_retry"
            reason = "Prior core-source-02 has no durable source hash and remains consumed; do not reuse or reopen it."
            source_sha = None
        else:
            evidence_status = "gap_prior_observation_not_carry_forwardable"
            provenance = observation.get("file_provenance") or {}
            source_sha = provenance.get("sha256")
            reason = "Prior observation is retained as a gap without rereading; any captured source SHA is provenance only because parsing did not establish the required evidence and no matching Hex package checksum exists."
        entries.append({
            "lane": "core", "source_path_value": old["target_path"],
            "prior_consumed_request_id": request_id, "new_request_id": None,
            "request_reused": False, "source_identity_captured_lock_sha256": old_identity.get("lock_sha256"),
            "source_identity_current_lock_sha256": lock_digest,
            "current_source_identity": current_identity,
            "mfa_selectors": old["mfa_span_selectors"],
            "prior_observation_status": observation.get("observation_status"),
            "prior_source_sha256": source_sha,
            "evidence_status": evidence_status, "reason": reason,
        })
    schedule = {
        "schema": "fablebook.phase7.current_source_schedule/1",
        "status": "review_required",
        "lane": "core",
        "identity": {
            "lock_file": "mix.lock", "lock_sha256": lock_digest,
            "prior_lock_sha256": base_digest, "package": "phoenix_live_view",
            "package_version": liveview["package_version"],
            "package_checksum": liveview["lock_checksums"][0],
            "repo_checksum": liveview["lock_checksums"][1],
            "manifest_sha256": sha(MANIFEST.read_bytes()),
            "exports_sha256": sha(EXPORTS.read_bytes()),
            "export_generation": current_summary["generation_id"],
            "otp_version": current_summary["otp_version"],
            "elixir_version": current_summary["elixir_version"],
        },
        "scope": {
            "saved_core_rows": len(core_rows), "saved_core_mfas": len(members),
            "historical_request_ids_preserved_only_as_provenance": REQUEST_IDS,
            "new_requests": 0, "target_source_bodies_read": False,
            "reopen_or_retry_authorized": False,
        },
        "entries": entries,
    }
    return schedule


def build_schedule():
    write_new(SCHEDULE, json_bytes(derive_schedule()))


def derive_reconciliation():
    core_rows, members = compare_saved_membership()
    schedule_digest = sha(SCHEDULE.read_bytes())
    schedule = read_json(SCHEDULE)
    approval = read_json(SCHEDULE_APPROVAL)
    review = SCHEDULE_REVIEW.read_text(encoding="utf-8")
    if (approval.get("verdict") != "PASS" or approval.get("schedule_sha256") != schedule_digest
            or approval.get("review_file_sha256") != sha(SCHEDULE_REVIEW.read_bytes())
            or approval.get("reviewer") not in review):
        raise ValueError("source schedule review/approval is absent or bound to another digest")
    previous = read_json(OLD_RECONCILIATION)
    previous_core = previous["lanes"]["core"]
    family = previous_core["family"]
    family_keys = {(item["identity_id"], tuple(item["mfa"])) for item in family}
    member_keys = {(item["identity_id"], tuple(item["mfa"])) for item in members}
    if not family_keys <= member_keys:
        raise ValueError("prior family differs from current saved-row membership")
    export_map = {(row["module"], row["function"], row["arity"]): row for row in current_exports()}
    for item in family:
        if tuple(item["mfa"]) not in export_map:
            raise ValueError(f"prior family MFA is missing from current exports: {item}")
    complement = [item for item in members if (item["identity_id"], tuple(item["mfa"])) not in family_keys]
    if len(family) != 7 or len(complement) != len(members) - len(family):
        raise ValueError("family/complement sizing differs from the saved membership")
    locks = current_lock_checks()
    summary = read_json(EXPORT_SUMMARY)
    membership_digest = membership_sha("core", members)
    family_digest = membership_sha("core", family)
    complement_digest = membership_sha("core", complement)
    # Keep accepted floor facts byte-for-byte sourced from the prior reconciliation.
    floor = previous["lanes"]["floor"]
    current = {
        "schema": "fablebook.phase7.scope_reconciliation.security_rebaseline/1",
        "status": "reconciled_with_explicit_source_gaps",
        "phase": "v0.6/7",
        "current_core_identity": {
            "lock_sha256": locks[1], "prior_lock_sha256": locks[0],
            "manifest_sha256": sha(MANIFEST.read_bytes()),
            "root_summary_sha256": sha(ROOTS.read_bytes()),
            "producer_sha256": sha((HERE / "07-CORE-EXPORT-INVENTORY.py").read_bytes()),
            "exports_sha256": sha(EXPORTS.read_bytes()),
            "generation_id": summary["generation_id"],
            "package_version": "1.2.14", "package_checksum": LIVEVIEW_PACKAGE_SHA,
            "repo_checksum": LIVEVIEW_REPO_SHA, "otp": summary["otp_version"],
            "elixir": summary["elixir_version"],
        },
        "core_membership": {
            "row_count": len(core_rows), "mfa_count": len(members), "membership_count": len(members),
            "membership": members, "membership_sha256": membership_digest,
            "family": family, "family_count": len(family), "family_sha256": family_digest,
            "complement": complement, "complement_count": len(complement),
            "complement_sha256": complement_digest,
            "partition": {"disjoint": not bool(family_keys & {(x["identity_id"], tuple(x["mfa"])) for x in complement}),
                          "union_equals_membership": family_keys | {(x["identity_id"], tuple(x["mfa"])) for x in complement} == member_keys},
            "scope_matches_prior_membership": members == previous_core["membership"],
        },
        "retained_floor_evidence": {
            "source_reconciliation_sha256": sha(OLD_RECONCILIATION.read_bytes()),
            "identity": floor["identity"], "membership_sha256": floor["membership_sha256"],
            "membership_count": floor["membership_count"], "family_sha256": floor["family_sha256"],
            "family_count": floor["family_count"], "complement_sha256": floor["complement_sha256"],
            "complement_count": floor["complement_count"],
            "reused_without_rescan": True,
        },
        "current_source_schedule": {
            "path": SCHEDULE.relative_to(ROOT).as_posix(), "sha256": schedule_digest,
            "review_path": SCHEDULE_REVIEW.relative_to(ROOT).as_posix(),
            "review_sha256": sha(SCHEDULE_REVIEW.read_bytes()),
            "approval_path": SCHEDULE_APPROVAL.relative_to(ROOT).as_posix(),
            "approval_sha256": sha(SCHEDULE_APPROVAL.read_bytes()),
            "entry_count": len(schedule["entries"]), "new_requests": 0,
            "carry_forward_count": sum(x["evidence_status"].startswith("carry_forward") for x in schedule["entries"]),
            "current_gap_count": sum(x["evidence_status"].startswith("gap_") for x in schedule["entries"]),
        },
        "request_history": {
            "consumed_ids_preserved": REQUEST_IDS,
            "new_ids_consumed": [], "reopened_ids": [],
            "liveview_prior_request": "core-source-03 remains an explicit no-retry gap under changed package identity",
        },
        "sizing": {
            "manifest_beam_files": summary["beam_file_count"],
            "manifest_export_count": summary["export_count"],
            "saved_core_rows": len(core_rows), "saved_core_mfas": len(members),
            "family_memberships": len(family), "complement_memberships": len(complement),
            "schedule_entries": len(schedule["entries"]), "new_source_reads": 0,
            "carried_observations": sum(x["evidence_status"].startswith("carry_forward") for x in schedule["entries"]),
            "explicit_gaps": sum(x["evidence_status"].startswith("gap_") for x in schedule["entries"]),
        },
        "source_read_boundary": {
            "new_generation_target_source_bodies_read": False,
            "historical_phase_target_source_bodies_read": True,
            "runtime_apis_called": False, "generated_code_executed": False,
        },
        "preserved_stops": STOP_STATE,
        "owner_decision": previous["owner_decision"],
    }
    return current


def build_reconciliation():
    write_new(RECONCILIATION, json_bytes(derive_reconciliation()))


def membership_sha(lane: str, values: list[dict]) -> str:
    rows = sorted(values, key=lambda x: (lane, x["identity_id"], *x["mfa"]))
    data = b"".join(json_bytes([lane, row["identity_id"], *row["mfa"]]) for row in rows)
    return sha(data)


def check():
    current_lock_checks()
    core_rows, members = compare_saved_membership()
    summary, manifest_digest, producer_digest = validate_current_export_summary()
    manifest_data = MANIFEST.read_bytes()
    roots_data = ROOTS.read_bytes()
    exports_data = EXPORTS.read_bytes()
    export_approval = read_json(EXPORT_APPROVAL)
    if (export_approval.get("verdict") != "PASS"
            or export_approval.get("manifest_sha256") != manifest_digest
            or export_approval.get("root_summary_sha256") != sha(roots_data)
            or export_approval.get("producer_sha256") != producer_digest):
        raise ValueError("current export summary is not bound to the patched core identity")
    schedule = read_json(SCHEDULE)
    if schedule != derive_schedule():
        raise ValueError("current source schedule differs from the exact lock-bound derivation")
    if schedule.get("status") != "review_required" or schedule.get("scope", {}).get("new_requests") != 0:
        raise ValueError("current schedule status or request count is invalid")
    if set(x.get("prior_consumed_request_id") for x in schedule["entries"]) != set(REQUEST_IDS):
        raise ValueError("current schedule does not preserve exactly the five historical core IDs")
    if any(x.get("new_request_id") is not None or x.get("request_reused") for x in schedule["entries"]):
        raise ValueError("current schedule reuses or issues a request ID")
    old_schedule = read_json(OLD_SCHEDULE)
    old_entries = {x["request_id"]: x for x in old_schedule["entries"] if x.get("lane") == "core"}
    old_observations = {}
    for path in OLD_OBSERVATIONS:
        for obs in load_jsonl(path):
            if obs.get("lane") == "core":
                old_observations[obs["request_id"]] = obs
    for entry in schedule["entries"]:
        prior_id = entry["prior_consumed_request_id"]
        old = old_entries[prior_id]
        obs = old_observations[prior_id]
        if (entry["source_identity_captured_lock_sha256"] != old["source_identity"].get("lock_sha256")
                or entry["source_identity_current_lock_sha256"] != EXPECTED_CURRENT_LOCK):
            raise ValueError(f"source identity lock provenance mismatch: {prior_id}")
        if entry["evidence_status"].startswith("carry_forward"):
            provenance = obs.get("file_provenance") or {}
            current = next((x for x in current_exports() if x.get("package") == entry["current_source_identity"].get("package")), None)
            if (not current or obs.get("observation_status") != "parsed"
                    or not provenance.get("sha256") or provenance.get("sha256") != entry.get("prior_source_sha256")
                    or old["source_identity"].get("package_checksum") != current.get("lock_checksums", [None])[0]
                    or entry["current_source_identity"].get("package_checksum") != current.get("lock_checksums", [None])[0]):
                raise ValueError(f"carry-forward lacks exact durable source/package identity: {prior_id}")
        elif prior_id == "core-source-05":
            provenance = obs.get("file_provenance") or {}
            if (obs.get("observation_status") != "parse_failed"
                    or entry.get("prior_source_sha256") != provenance.get("sha256")
                    or entry.get("evidence_status", "").startswith("carry_forward")):
                raise ValueError("core-source-05's parse-failed SHA must stay provenance only")
        elif prior_id == "core-source-03":
            if (entry.get("evidence_status") != "gap_no_retry_identity_changed"
                    or entry["current_source_identity"].get("package_checksum") != LIVEVIEW_PACKAGE_SHA
                    or entry.get("prior_source_sha256") is not None):
                raise ValueError("LiveView prior no-retry gap was hidden or misbound")
        marker = read_json(OLD_CONSUMPTION / f"{prior_id}.json")
        if marker.get("request_id") != prior_id:
            raise ValueError(f"consumption marker is not bound to its original ID: {prior_id}")
    approval = read_json(SCHEDULE_APPROVAL)
    review = SCHEDULE_REVIEW.read_text(encoding="utf-8")
    if (approval.get("verdict") != "PASS" or approval.get("schedule_sha256") != sha(SCHEDULE.read_bytes())
            or approval.get("review_file_sha256") != sha(SCHEDULE_REVIEW.read_bytes())
            or approval.get("reviewer") not in review):
        raise ValueError("current source schedule approval is invalid")
    reconciliation = read_json(RECONCILIATION)
    if reconciliation != derive_reconciliation():
        raise ValueError("current reconciliation differs from the exact lock-bound derivation")
    current_core = reconciliation["core_membership"]
    expected_family = read_json(OLD_RECONCILIATION)["lanes"]["core"]["family"]
    if current_core["membership"] != members or current_core["family"] != expected_family:
        raise ValueError("current family or membership differs from the exact saved scope")
    family_keys = {(x["identity_id"], tuple(x["mfa"])) for x in current_core["family"]}
    complement_keys = {(x["identity_id"], tuple(x["mfa"])) for x in current_core["complement"]}
    member_keys = {(x["identity_id"], tuple(x["mfa"])) for x in current_core["membership"]}
    if family_keys & complement_keys or family_keys | complement_keys != member_keys:
        raise ValueError("core family/complement partition is invalid")
    if (current_core["membership_sha256"] != membership_sha("core", current_core["membership"])
            or current_core["family_sha256"] != membership_sha("core", current_core["family"])
            or current_core["complement_sha256"] != membership_sha("core", current_core["complement"])):
        raise ValueError("current membership/family/complement digest differs")
    if (current_core["membership_count"] != 1763 or current_core["family_count"] != 7
            or current_core["complement_count"] != 1756
            or current_core["partition"] != {"disjoint": True, "union_equals_membership": True}):
        raise ValueError("current family/complement sizing or partition is invalid")
    if reconciliation["preserved_stops"] != STOP_STATE:
        raise ValueError("an inherited safety stop changed")
    if reconciliation["retained_floor_evidence"].get("reused_without_rescan") is not True:
        raise ValueError("floor evidence is not clearly marked as retained")
    # Immutable prior IDs and stop artifacts remain available and unmodified by this plan.
    for request_id in REQUEST_IDS:
        if not (OLD_CONSUMPTION / f"{request_id}.json").is_file():
            raise ValueError(f"consumption marker is missing: {request_id}")
    print(f"PASS: {len(core_rows)} core rows and {len(members)} saved MFAs reconcile exactly; family/complement remain {len(current_core['family'])}/{len(current_core['complement'])}; 5 historical request IDs remain closed.")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--build-schedule", action="store_true")
    parser.add_argument("--build-reconciliation", action="store_true")
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    try:
        if args.build_schedule:
            build_schedule()
        elif args.build_reconciliation:
            build_reconciliation()
        elif args.check:
            check()
        else:
            parser.error("choose --build-schedule, --build-reconciliation, or --check")
    except (OSError, ValueError, KeyError, TypeError, StopIteration) as exc:
        print(f"STOP: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
