#!/usr/bin/env python3
"""Verify the approved source successor after installation.

The parent preflight source_candidate helper is a pre-install proposal check.
The parent adoption verifier checks historical receipt delegation; it is not a
fresh installed-archive or source-graph completion check.
"""

from __future__ import annotations

import argparse
import copy
import gzip
import hashlib
import importlib.util
import io
import json
import os
import re
import select
import subprocess
import sys
import tarfile
import tempfile
import time
import uuid
from collections import Counter
from contextlib import contextmanager
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PHASE_DIR = ROOT / ".planning/phases/01.1.1.3.1-debugger-remaining-settings-trace-breakpoint-and-monitor-rou"
CHILD_DIR = ROOT / ".planning/phases/01.1.1.3.1.1-debugger-saved-settings-replay-and-deferred-callback-guards"
REMAINDER_PHASE_DIR = ROOT / ".planning/phases/01.1.1.3.1.2-debugger-trace-breakpoint-monitor-and-interpreter-remainder"
REMAINDER_EVIDENCE_DIR = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-evidence"
REMAINDER_GENERATION_ROOT = REMAINDER_EVIDENCE_DIR / "GENERATION"
REMAINDER_DELIVERY_PATH = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-DELIVERY.json"
REMAINDER_REVIEW_PATH = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-REVIEW.md"
REMAINDER_VALIDATION_PATH = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-VALIDATION.md"
REMAINDER_AUDIT_PATH = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-REMAINDER-AUDIT.md"
REMAINDER_SOURCE_AUDIT_PATH = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-SOURCE-AUDIT.md"
REMAINDER_SECURITY_PATH = REMAINDER_PHASE_DIR / "01.1.1.3.1.2-SECURITY.md"
ARCHIVE = ROOT / "test/fixtures/guards/exact_sources.tar.gz"
CANDIDATE = PHASE_DIR / "01.1.1.3.1-SOURCE-CANDIDATE.json"
DECISION = PHASE_DIR / "01.1.1.3.1-SOURCE-DECISION.md"
LEDGER = ROOT / ".planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz"
PARENT_OWNERSHIP = LEDGER.with_name("ownership.py")
RESERVATION_PREFLIGHT = PHASE_DIR / "preflight.py"
RESERVATION_ADOPT = PHASE_DIR / "adopt.py"
sys.dont_write_bytecode = True

BASE_GIT_BLOB = "155874cb8152bcdf65ac3fd1afd063d7add6e7c3"
BASE_SHA256 = "a31f1d1b19e1c8df543f4844af9d47b7ca7a79985b42bd78186f56c04da06342"
SUCCESSOR_SHA256 = "27c45913ed03b510f2f44ccef8f65a95d932c9fb917e6c4e942b0cfd18a73894"
LEDGER_SHA256 = "bd0796639c7ed76a2e312153e7f4a7e9224c4a8ecec7326475aecc55c275521d"
BASE_BYTES = 2_481_736
SUCCESSOR_BYTES = 2_502_649
COMPRESSED_GROWTH = 20_913
NEW_RAW_BYTES = 86_144
PRESERVED_FILE_MEMBERS = 248
PRESERVED_SOURCE_ROWS = 251
LANE_COMMITS = {
    "core": "d199a49a01a2079afb6f2c5c9ae047cd4555e68d",
    "floor": "4aa809ae4eb4a20ad89c23837376acf179877f39",
}
NEW_MODULES = ("dbg_icmd", "dbg_iserver", "dbg_wx_settings", "debugger")
OWNER = "01.1.1.3.1.1"
PARENT_PHASE = "01.1.1.3.1"
SELECTED_OWNER = PARENT_PHASE + ".1"
REMAINDER_OWNER = PARENT_PHASE + ".2"
ADOPTION_SCRIPT = PHASE_DIR / "adopt.py"
ADOPTION_LEDGER = PHASE_DIR / (PARENT_PHASE + "-OWNERSHIP.jsonl.gz")
ADOPTION_PARTITION = PHASE_DIR / (PARENT_PHASE + "-PARTITION.json.gz")
GENERATION_ROOT = CHILD_DIR / f"{OWNER}-evidence"
DELIVERY_PATH = CHILD_DIR / f"{OWNER}-DELIVERY.json"
REVIEW_PATH = CHILD_DIR / f"{OWNER}-REVIEW.md"
GENERATION_POINTER_SCHEMA = "fablebook.debugger-saved-settings-generation-pointer.v1"
DELIVERY_SCHEMA = "fablebook.debugger-saved-settings-delivery.v1"
OBSERVED_SCHEMA = "fablebook.debugger-saved-settings-observed.v1"
ACTIVE_SCOPE = "selected-settings"
GENERATION_ARTIFACTS = {
    "inventory_core": f"{OWNER}-INVENTORY-core.jsonl",
    "inventory_floor": f"{OWNER}-INVENTORY-floor.jsonl",
    "observed": f"{OWNER}-OBSERVED.jsonl.gz",
    "delivery": f"{OWNER}-DELIVERY.json",
    "validation": f"{OWNER}-VALIDATION.md",
}
RECEIPT_PREFIX = b"FABLEBOOK_OTP_INVENTORY_V2 "
MAX_CI_JOB_LOG_BYTES = 128 * 1024 * 1024
REMAINDER_SCOPE_CONTRACT = {
    "scope": "debugger-remainder",
    "owner": "01.1.1.3.1.2",
    "selected_owner": "01.1.1.3.1.1",
    "receipt_test": "debugger_remainder_receipt",
    "disposition_groups": ["callback", "interpreter", "monitor", "trace"],
    "inherited_pending": {
        "callback_body": "dbg_icmd:break_p/4",
        "selected_roots": [
            "dbg_wx_mon:load_settings/2",
            "dbg_wx_mon:load_settings2/2",
            "dbg_wx_mon:start/2",
        ],
    },
    "limits": {
        "runtime_safety": "not-established",
        "installed_wide_acceptance": "pending-for-01.1.1.3.1.3",
        "sec_01": "pending-for-phase-5",
    },
}
REMAINDER_GENERATION_ARTIFACTS = {
    "inventory_core": "01.1.1.3.1.2-INVENTORY-core.jsonl",
    "inventory_floor": "01.1.1.3.1.2-INVENTORY-floor.jsonl",
    "observed": "01.1.1.3.1.2-OBSERVED.jsonl.gz",
    "delivery": "01.1.1.3.1.2-DELIVERY.json",
}
SCOPE_OPTIONS = ("selected-settings", "debugger-remainder")
SUPPORTED_RUNTIMES = {
    "core": {"elixir": "1.20.4", "otp": "29.1.2"},
    "floor": {"elixir": "1.18.5", "otp": "27.3.4.9"},
}
SELECTED_ROOTS = {
    ("dbg_wx_mon", "start", 2),
    ("dbg_wx_mon", "load_settings", 2),
    ("dbg_wx_mon", "load_settings2", 2),
}
SELECTED_MODULE = "dbg_wx_settings"
OBSERVED_REQUIRED_CONTROLS = (
    "incomplete-receipt", "missing-required-check", "wrong-head", "wrong-run", "wrong-runtime",
    "wrong-lock", "wrong-source", "missing-original-assignment",
    "missing-observed-assignment", "missing-completion-history", "changed-chain",
    "active-subset-loss", "wrong-owner", "new-unowned-identity",
    "historical-input-is-not-current-ci", "parent-owner-preserved",
    "unrelated-adopted-app-excluded", "missing-adopted-debugger-assignment",
)
EXPECTED_MAPPING_PATHS = {
    f"{lane}/debugger/src/{module}.erl"
    for lane in ("core", "floor")
    for module in NEW_MODULES
}
SHA256_RE = re.compile(r"^[a-f0-9]{64}$")
GIT_SHA_RE = re.compile(r"^[a-f0-9]{40}$")


class VerificationError(ValueError):
    def __init__(self, reason: str, detail: object):
        super().__init__(f"{reason}: {detail}")
        self.reason = reason
        self.detail = detail


def reject(condition: bool, reason: str, detail: object) -> None:
    if not condition:
        raise VerificationError(reason, detail)


@contextmanager
def scoped_delivery(scope: str):
    """Select one fixed delivery layout while keeping the historical default intact."""
    reject(scope in SCOPE_OPTIONS, "unknown-scope", scope)
    if scope == "selected-settings":
        yield
        return

    replacements = {
        "ACTIVE_SCOPE": "debugger-remainder",
        "OWNER": "01.1.1.3.1.2",
        "CHILD_DIR": REMAINDER_PHASE_DIR,
        "GENERATION_ROOT": REMAINDER_GENERATION_ROOT,
        "DELIVERY_PATH": REMAINDER_DELIVERY_PATH,
        "REVIEW_PATH": REMAINDER_REVIEW_PATH,
        "GENERATION_POINTER_SCHEMA": "fablebook.debugger-remainder-generation-pointer.v1",
        "DELIVERY_SCHEMA": "fablebook.debugger-remainder-delivery.v1",
        "OBSERVED_SCHEMA": "fablebook.debugger-remainder-observed.v1",
        "GENERATION_ARTIFACTS": REMAINDER_GENERATION_ARTIFACTS,
    }
    previous = {key: globals()[key] for key in replacements}
    globals().update(replacements)
    try:
        yield
    finally:
        globals().update(previous)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def read_bytes(path: Path, reason: str) -> bytes:
    try:
        return path.read_bytes()
    except OSError as error:
        raise VerificationError(reason, f"{path}: {error}") from error


def git_base_blob() -> bytes:
    try:
        result = subprocess.run(
            ["git", "cat-file", "blob", BASE_GIT_BLOB],
            cwd=ROOT,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except OSError as error:
        raise VerificationError("base-object-unavailable", str(error)) from error
    if result.returncode != 0:
        detail = result.stderr.decode("utf-8", errors="replace").strip()
        raise VerificationError("base-object-unavailable", detail or BASE_GIT_BLOB)
    return result.stdout


def load_candidate() -> dict:
    raw = read_bytes(CANDIDATE, "candidate-metadata-unavailable")
    try:
        value = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise VerificationError("candidate-metadata-format", str(error)) from error
    if not isinstance(value, dict):
        raise VerificationError("candidate-metadata-format", "top level must be an object")
    return value


def check_approval_and_ledger(metadata: dict) -> None:
    decision = read_bytes(DECISION, "source-decision-unavailable").decode(
        "utf-8", errors="replace"
    )
    for required in (
        "status: approved",
        "intent: INT-20261031-01",
        "01.1.1.3.1-SOURCE-CANDIDATE.json",
        BASE_SHA256,
        SUCCESSOR_SHA256,
        "All 248 old file members and 251 old source rows are preserved.",
    ):
        reject(required in decision, "approval-decision", f"missing approved scope evidence: {required}")

    ledger = read_bytes(LEDGER, "ownership-ledger-unavailable")
    actual_ledger_sha = sha256(ledger)
    reject(
        actual_ledger_sha == LEDGER_SHA256 and metadata.get("ledger_sha256") == LEDGER_SHA256,
        "ledger-digest",
        {"expected": LEDGER_SHA256, "actual": actual_ledger_sha, "metadata": metadata.get("ledger_sha256")},
    )


def safe_member_name(name: object) -> bool:
    if not isinstance(name, str) or not name or name.startswith("/"):
        return False
    if "\\" in name or "\x00" in name or ":" in name:
        return False
    return all(part not in ("", ".", "..") for part in name.split("/"))


def archive_files(data: bytes, label: str) -> dict[str, bytes]:
    files: dict[str, bytes] = {}
    try:
        with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
            members = archive.getmembers()
            for member in members:
                reject(
                    safe_member_name(member.name),
                    "unsafe-member",
                    {"archive": label, "name": member.name},
                )
                reject(
                    member.isfile(),
                    "non-regular-member",
                    {"archive": label, "name": member.name, "type": repr(member.type)},
                )
                reject(
                    member.name not in files,
                    "duplicate-member",
                    {"archive": label, "name": member.name},
                )
                reject(member.size >= 0, "member-size", {"archive": label, "name": member.name})
                stream = archive.extractfile(member)
                reject(
                    stream is not None,
                    "unreadable-member",
                    {"archive": label, "name": member.name},
                )
                assert stream is not None
                body = stream.read()
                reject(
                    len(body) == member.size,
                    "member-size",
                    {"archive": label, "name": member.name, "expected": member.size, "actual": len(body)},
                )
                files[member.name] = body
    except VerificationError:
        raise
    except (OSError, EOFError, tarfile.TarError) as error:
        raise VerificationError("archive-format", {"archive": label, "error": str(error)}) from error
    return files


def decode_manifest(files: dict[str, bytes], label: str) -> dict:
    raw = files.get("manifest.json")
    reject(raw is not None, "manifest-missing", label)
    assert raw is not None
    try:
        manifest = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise VerificationError("manifest-format", {"archive": label, "error": str(error)}) from error
    reject(isinstance(manifest, dict), "manifest-format", label)
    reject(isinstance(manifest.get("files"), list), "manifest-format", {"archive": label, "field": "files"})
    reject(isinstance(manifest.get("refs"), dict), "manifest-format", {"archive": label, "field": "refs"})
    reject(isinstance(manifest.get("locks"), dict), "manifest-format", {"archive": label, "field": "locks"})
    return manifest


def validate_manifest_inventory(manifest: dict, files: dict[str, bytes], label: str) -> None:
    declared: list[str] = []
    seen: set[str] = set()
    for index, row in enumerate(manifest["files"]):
        reject(
            isinstance(row, dict),
            "manifest-row",
            {"archive": label, "index": index},
        )
        status = row.get("status")
        if status in ("present", "license"):
            path = row.get("path")
            reject(
                safe_member_name(path),
                "manifest-path",
                {"archive": label, "index": index, "path": path},
            )
            assert isinstance(path, str)
            reject(
                path not in seen,
                "manifest-duplicate",
                {"archive": label, "path": path},
            )
            seen.add(path)
            declared.append(path)
        elif status == "absent-at-immutable-ref":
            reject(
                "path" not in row,
                "manifest-absence",
                {"archive": label, "index": index, "row": row},
            )
        else:
            raise VerificationError(
                "manifest-status",
                {"archive": label, "index": index, "status": status},
            )

    expected = {"manifest.json", *declared}
    reject(
        set(files) == expected,
        "manifest-inventory",
        {
            "archive": label,
            "missing": sorted(expected - set(files)),
            "unlisted": sorted(set(files) - expected),
        },
    )
    for row in manifest["files"]:
        if row["status"] not in ("present", "license"):
            continue
        path = row["path"]
        body = files[path]
        reject(
            len(body) == row.get("bytes") and sha256(body) == row.get("sha256"),
            "manifest-source-digest",
            {"archive": label, "path": path},
        )


def validate_outer_pins(base_bytes: bytes, successor_bytes: bytes, metadata: dict) -> None:
    reject(
        metadata.get("base_sha256") == BASE_SHA256,
        "candidate-metadata",
        {"base_sha256": metadata.get("base_sha256"), "expected": BASE_SHA256},
    )
    reject(
        metadata.get("candidate_sha256") == SUCCESSOR_SHA256,
        "candidate-metadata",
        {"candidate_sha256": metadata.get("candidate_sha256"), "expected": SUCCESSOR_SHA256},
    )
    actual_base_sha = sha256(base_bytes)
    reject(
        actual_base_sha == BASE_SHA256,
        "base-sha256",
        {"expected": BASE_SHA256, "actual": actual_base_sha},
    )
    actual_successor_sha = sha256(successor_bytes)
    reject(
        actual_successor_sha == SUCCESSOR_SHA256,
        "successor-sha256",
        {"expected": SUCCESSOR_SHA256, "actual": actual_successor_sha},
    )
    reject(
        len(base_bytes) == BASE_BYTES == metadata.get("base_bytes"),
        "incorrect-totals",
        {"base_bytes": len(base_bytes), "metadata": metadata.get("base_bytes")},
    )
    reject(
        len(successor_bytes) == SUCCESSOR_BYTES == metadata.get("candidate_bytes"),
        "incorrect-totals",
        {"successor_bytes": len(successor_bytes), "metadata": metadata.get("candidate_bytes")},
    )
    reject(
        len(successor_bytes) - len(base_bytes)
        == COMPRESSED_GROWTH
        == metadata.get("compressed_delta_bytes"),
        "incorrect-totals",
        {
            "compressed_growth": len(successor_bytes) - len(base_bytes),
            "metadata": metadata.get("compressed_delta_bytes"),
        },
    )


def validate_contents(base_bytes: bytes, successor_bytes: bytes, metadata: dict) -> dict:
    base_files = archive_files(base_bytes, "immutable-base")
    successor_files = archive_files(successor_bytes, "installed-successor")
    base_manifest = decode_manifest(base_files, "immutable-base")
    successor_manifest = decode_manifest(successor_files, "installed-successor")
    base_rows = base_manifest["files"]
    successor_rows = successor_manifest["files"]
    for lane, commit in LANE_COMMITS.items():
        otp_ref = base_manifest["refs"].get(lane, {}).get("otp")
        reject(
            isinstance(otp_ref, list) and len(otp_ref) == 2 and otp_ref[1] == commit,
            "source-reference",
            {"lane": lane, "expected_commit": commit, "actual": otp_ref},
        )

    reject(
        len(base_files) - 1 == PRESERVED_FILE_MEMBERS,
        "incorrect-totals",
        {"base_file_members": len(base_files) - 1, "expected": PRESERVED_FILE_MEMBERS},
    )
    reject(
        len(base_rows) == PRESERVED_SOURCE_ROWS,
        "incorrect-totals",
        {"base_source_rows": len(base_rows), "expected": PRESERVED_SOURCE_ROWS},
    )
    reject(
        metadata.get("unchanged_file_members") == PRESERVED_FILE_MEMBERS
        and metadata.get("unchanged_source_rows") == PRESERVED_SOURCE_ROWS,
        "incorrect-totals",
        {
            "unchanged_file_members": metadata.get("unchanged_file_members"),
            "unchanged_source_rows": metadata.get("unchanged_source_rows"),
        },
    )
    reject(
        successor_rows[: len(base_rows)] == base_rows,
        "changed-old-rows",
        "successor manifest does not preserve the complete base files prefix",
    )
    reject(
        {key: value for key, value in successor_manifest.items() if key != "files"}
        == {key: value for key, value in base_manifest.items() if key != "files"},
        "changed-manifest-metadata",
        "successor changed a non-files manifest field",
    )

    mappings = metadata.get("mappings")
    reject(isinstance(mappings, list), "candidate-metadata", "mappings must be an array")
    reject(len(mappings) == 8, "candidate-metadata", {"mapping_count": len(mappings)})
    mapping_by_path: dict[str, dict] = {}
    for row in mappings:
        reject(isinstance(row, dict), "candidate-metadata", "mapping rows must be objects")
        path = row.get("path")
        reject(
            isinstance(path, str) and path not in mapping_by_path,
            "candidate-metadata",
            {"duplicate_or_invalid_mapping_path": path},
        )
        mapping_by_path[path] = row
    reject(
        set(mapping_by_path) == EXPECTED_MAPPING_PATHS,
        "candidate-metadata",
        {"mapping_paths": sorted(mapping_by_path), "expected": sorted(EXPECTED_MAPPING_PATHS)},
    )

    for path, row in mapping_by_path.items():
        lane = path.split("/", 1)[0]
        source_path = f"debugger/src/{Path(path).name}"
        reject(
            lane in LANE_COMMITS and path.startswith(f"{lane}/"),
            "wrong-lane-mapping",
            {"path": path, "lane": row.get("lane")},
        )
        reject(
            row.get("lane") == lane
            and row.get("source_path") == source_path
            and row.get("status") == "present",
            "mapping-shape",
            {"path": path, "row": row},
        )
        expected_url = (
            f"https://raw.githubusercontent.com/erlang/otp/{LANE_COMMITS[lane]}"
            f"/lib/{source_path}"
        )
        reject(
            row.get("url") == expected_url,
            "mapping-url",
            {"path": path, "expected": expected_url, "actual": row.get("url")},
        )
        body = successor_files.get(path)
        reject(body is not None, "missing-member", path)
        assert body is not None
        reject(
            row.get("bytes") == len(body),
            "mapping-size",
            {"path": path, "expected": row.get("bytes"), "actual": len(body)},
        )
        digest = row.get("sha256")
        reject(
            isinstance(digest, str) and SHA256_RE.fullmatch(digest) is not None,
            "mapping-sha256",
            {"path": path, "digest": digest},
        )
        reject(
            sha256(body) == digest,
            "source-digest",
            {"path": path, "expected": digest, "actual": sha256(body)},
        )

    expected_mapping_rows = [mapping_by_path[row.get("path")] for row in mappings]
    successor_mapping_rows = successor_rows[len(base_rows) :]
    for row in successor_mapping_rows:
        reject(isinstance(row, dict), "mapping-row", row)
        path = row.get("path")
        lane = row.get("lane")
        reject(
            isinstance(path, str)
            and isinstance(lane, str)
            and lane in LANE_COMMITS
            and path.startswith(f"{lane}/"),
            "wrong-lane-mapping",
            {"path": path, "lane": lane},
        )
    reject(
        successor_mapping_rows == expected_mapping_rows,
        "mapping-rows",
        "successor manifest additions differ from the approved mapping metadata",
    )

    base_members = set(base_files) - {"manifest.json"}
    added_members = set(successor_files) - set(base_files)
    reject(
        not (base_members - set(successor_files)),
        "missing-member",
        sorted(base_members - set(successor_files)),
    )
    changed_old = sorted(
        name for name in base_members if successor_files.get(name) != base_files[name]
    )
    reject(not changed_old, "changed-old-member", changed_old)
    reject(
        added_members == EXPECTED_MAPPING_PATHS,
        "mapping-members",
        {"added": sorted(added_members), "expected": sorted(EXPECTED_MAPPING_PATHS)},
    )
    validate_manifest_inventory(base_manifest, base_files, "immutable-base")
    validate_manifest_inventory(successor_manifest, successor_files, "installed-successor")

    raw_bytes = sum(row["bytes"] for row in mappings)
    reject(
        raw_bytes == NEW_RAW_BYTES == metadata.get("new_raw_source_bytes"),
        "incorrect-totals",
        {"new_raw_source_bytes": raw_bytes, "metadata": metadata.get("new_raw_source_bytes")},
    )
    reject(
        len(successor_rows) == PRESERVED_SOURCE_ROWS + 8,
        "incorrect-totals",
        {"successor_source_rows": len(successor_rows), "expected": PRESERVED_SOURCE_ROWS + 8},
    )
    return {
        "mapping_rows": mappings,
        "preservation": {
            "old_file_members": len(base_members),
            "old_file_bytes_identical": True,
            "old_source_rows": len(base_rows),
            "old_source_rows_identical": True,
            "non_files_manifest_fields_identical": True,
            "new_raw_source_bytes": raw_bytes,
            "compressed_growth_bytes": metadata["compressed_delta_bytes"],
        },
    }


def verify_bytes(base_bytes: bytes, successor_bytes: bytes, metadata: dict) -> dict:
    validate_outer_pins(base_bytes, successor_bytes, metadata)
    return validate_contents(base_bytes, successor_bytes, metadata)


def packed_archive(
    files: dict[str, bytes],
    extra_members: tuple[tuple[tarfile.TarInfo, bytes | None], ...] = (),
) -> bytes:
    output = io.BytesIO()
    try:
        with tarfile.open(fileobj=output, mode="w", format=tarfile.USTAR_FORMAT) as archive:
            for name in sorted(files):
                body = files[name]
                info = tarfile.TarInfo(name)
                info.size = len(body)
                info.mode = 0o644
                info.mtime = 0
                info.uid = 0
                info.gid = 0
                archive.addfile(info, io.BytesIO(body))
            for info, body in extra_members:
                if body is None:
                    archive.addfile(info)
                else:
                    info.size = len(body)
                    archive.addfile(info, io.BytesIO(body))
    except (OSError, tarfile.TarError) as error:
        raise VerificationError("negative-control-build", str(error)) from error
    return gzip.compress(output.getvalue(), mtime=0)


def rewritten_manifest(files: dict[str, bytes], mutate) -> dict[str, bytes]:
    altered = dict(files)
    manifest = json.loads(altered["manifest.json"].decode("utf-8"))
    mutate(manifest)
    altered["manifest.json"] = json.dumps(
        manifest, sort_keys=True, separators=(",", ":")
    ).encode("utf-8")
    return altered


def source_controls(base_bytes: bytes, successor_bytes: bytes, metadata: dict) -> dict:
    files = archive_files(successor_bytes, "negative-control-base")
    base_files = archive_files(base_bytes, "negative-control-immutable-base")
    base_manifest = decode_manifest(base_files, "negative-control-immutable-base")
    mappings = metadata["mappings"]
    controls: dict[str, dict[str, str]] = {}

    def expect_rejected(name: str, expected_reason: str, operation) -> None:
        try:
            operation()
        except VerificationError as error:
            if error.reason != expected_reason:
                raise VerificationError(
                    "negative-control-wrong-reason",
                    {"control": name, "expected": expected_reason, "actual": error.reason},
                ) from error
            controls[name] = {"status": "rejected", "reason": error.reason}
        else:
            raise VerificationError("negative-control-accepted", name)

    changed_digest = bytearray(successor_bytes)
    changed_digest[-1] ^= 1
    expect_rejected(
        "successor-digest",
        "successor-sha256",
        lambda: verify_bytes(base_bytes, bytes(changed_digest), metadata),
    )

    source_path = mappings[0]["path"]
    source_mutation = dict(files)
    source_body = bytearray(source_mutation[source_path])
    source_body[0] ^= 1
    source_mutation[source_path] = bytes(source_body)
    expect_rejected(
        "corrupt-source-digest",
        "source-digest",
        lambda: validate_contents(base_bytes, packed_archive(source_mutation), metadata),
    )

    missing_member = dict(files)
    del missing_member[source_path]
    expect_rejected(
        "missing-member",
        "missing-member",
        lambda: validate_contents(base_bytes, packed_archive(missing_member), metadata),
    )

    duplicate = tarfile.TarInfo(source_path)
    duplicate.mode = 0o644
    duplicate.mtime = 0
    expect_rejected(
        "duplicate-member",
        "duplicate-member",
        lambda: validate_contents(
            base_bytes,
            packed_archive(files, ((duplicate, files[source_path]),)),
            metadata,
        ),
    )

    unsafe = tarfile.TarInfo("../escape")
    unsafe.mode = 0o644
    unsafe.mtime = 0
    expect_rejected(
        "unsafe-member",
        "unsafe-member",
        lambda: validate_contents(
            base_bytes,
            packed_archive(files, ((unsafe, b"unsafe"),)),
            metadata,
        ),
    )

    link = tarfile.TarInfo("negative-control/link")
    link.type = tarfile.SYMTYPE
    link.linkname = "target"
    link.mode = 0o777
    link.mtime = 0
    expect_rejected(
        "non-regular-member",
        "non-regular-member",
        lambda: validate_contents(base_bytes, packed_archive(files, ((link, None),)), metadata),
    )

    old_name = next(name for name in sorted(base_files) if name != "manifest.json")
    changed_old = dict(files)
    old_body = bytearray(changed_old[old_name])
    old_body[0] ^= 1
    changed_old[old_name] = bytes(old_body)
    expect_rejected(
        "changed-old-member",
        "changed-old-member",
        lambda: validate_contents(base_bytes, packed_archive(changed_old), metadata),
    )

    def change_old_row(manifest: dict) -> None:
        row = manifest["files"][0]
        row["sha256"] = "0" * 64

    expect_rejected(
        "changed-old-rows",
        "changed-old-rows",
        lambda: validate_contents(
            base_bytes,
            packed_archive(rewritten_manifest(files, change_old_row)),
            metadata,
        ),
    )

    def change_lane(manifest: dict) -> None:
        index = len(base_manifest["files"])
        manifest["files"][index]["lane"] = "floor"

    expect_rejected(
        "wrong-lane-mapping",
        "wrong-lane-mapping",
        lambda: validate_contents(
            base_bytes,
            packed_archive(rewritten_manifest(files, change_lane)),
            metadata,
        ),
    )

    wrong_totals = copy.deepcopy(metadata)
    wrong_totals["new_raw_source_bytes"] += 1
    expect_rejected(
        "incorrect-totals",
        "incorrect-totals",
        lambda: validate_contents(base_bytes, successor_bytes, wrong_totals),
    )
    return controls


def verify_source(include_negative_controls: bool = False) -> dict:
    base_bytes = git_base_blob()
    successor_bytes = read_bytes(ARCHIVE, "successor-unavailable")
    metadata = load_candidate()
    check_approval_and_ledger(metadata)
    result = verify_bytes(base_bytes, successor_bytes, metadata)
    report = {
        "status": "verified",
        "base_sha256": BASE_SHA256,
        "successor_sha256": SUCCESSOR_SHA256,
        "mappings": result["mapping_rows"],
        "preservation": result["preservation"],
        "negative_controls": None,
    }
    if include_negative_controls:
        report["negative_controls"] = source_controls(base_bytes, successor_bytes, metadata)
    return report


def load_readonly_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    reject(spec is not None and spec.loader is not None, "history-import", str(path))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def history_control_rows(expected: list[dict], adopt) -> list[str]:
    def index(rows: list[dict], predicate) -> int:
        match = next((i for i, row in enumerate(rows) if predicate(row)), None)
        if match is None:
            raise VerificationError("history-control-fixture", "required adopted row is absent")
        return match

    controls = [
        (
            "missing-selected-module-original",
            lambda rows: rows.pop(index(rows, lambda r: r.get("t") == "module" and r.get("lane") == "core" and r.get("module") == "dbg_wx_settings")),
        ),
        (
            "missing-remainder-module-observed",
            lambda rows: rows.pop(index(rows, lambda r: r.get("t") == "observed_module" and r.get("lane") == "core" and r.get("module") == "dbg_wx_mon")),
        ),
        (
            "missing-selected-root-observed",
            lambda rows: rows.pop(index(rows, lambda r: r.get("t") == "observed_root" and r.get("lane") == "core" and r.get("module") == "dbg_wx_mon" and r.get("function") == "start")),
        ),
        (
            "duplicate-canonical-root",
            lambda rows: rows.append(copy.deepcopy(rows[index(rows, lambda r: r.get("t") == "root" and r.get("lane") == "core")])),
        ),
        (
            "wrong-selected-owner",
            lambda rows: rows[index(rows, lambda r: r.get("t") == "module" and r.get("lane") == "core" and r.get("module") == "dbg_wx_settings")].update(owner="01.1.1.3.1.2"),
        ),
        (
            "changed-canonical-chain",
            lambda rows: rows[index(rows, lambda r: r.get("t") == "root" and r.get("lane") == "core")].update(chain_id="0" * 64),
        ),
        (
            "changed-current-reference",
            lambda rows: rows[index(rows, lambda r: r.get("t") == "root" and r.get("lane") == "core")].update(references=["tampered-owner"]),
        ),
        (
            "missing-overlap-occurrence",
            lambda rows: rows[index(rows, lambda r: r.get("t") == "overlap" and r.get("lane") == "core")]["occurrences"].pop(),
        ),
        (
            "missing-source-branch",
            lambda rows: rows.pop(index(rows, lambda r: r.get("t") == "source_branch" and r.get("lane") == "core")),
        ),
        (
            "bad-origin-fingerprint",
            lambda rows: rows[index(rows, lambda r: r.get("t") == "module" and r.get("lane") == "core" and r.get("module") == "dbg_wx_settings")].update(origin_record_sha256="0" * 64),
        ),
    ]
    rejected = []
    for name, mutate in controls:
        altered = copy.deepcopy(expected)
        mutate(altered)
        try:
            adopt.validate(expected, altered)
        except ValueError:
            rejected.append(name + ":rejected")
        else:
            raise VerificationError("history-control-accepted", name)
    return rejected


def verify_history(include_negative_controls: bool = False) -> dict:
    """Re-derive both immutable receipt namespaces and verify the adopted rows read-only."""
    ownership = load_readonly_module("fablebook_parent_ownership", PARENT_OWNERSHIP)
    preflight = load_readonly_module("fablebook_settings_preflight", RESERVATION_PREFLIGHT)
    adopt = load_readonly_module("fablebook_settings_adopt", RESERVATION_ADOPT)

    parent_rows = ownership.load_ledger()
    parent_meta = parent_rows[0]
    proposal = preflight.partition()
    proposed_original = [a["record"] for a in proposal["assignments"]]
    receipt_report: dict[str, dict] = {}

    for lane in ("core", "floor"):
        path, file_hash, rows = ownership.receipt(lane)
        derived_original = ownership.derive(lane, path, file_hash, rows)
        derived_original = [r for r in derived_original if r.get("t") in {"module", "root"} and r.get("owner") == preflight.PHASE]
        parent_original = [r for r in parent_rows if r.get("t") in {"module", "root"} and r.get("lane") == lane and r.get("owner") == preflight.PHASE]
        reject(
            Counter(preflight.record_id(r) for r in derived_original) == Counter(preflight.record_id(r) for r in parent_original),
            "history-original-union",
            {"lane": lane, "derived": len(derived_original), "adopted_parent": len(parent_original)},
        )
        proposal_original_lane = [r for r in proposed_original if r.get("lane") == lane]
        reject(
            Counter(preflight.record_id(r) for r in derived_original) == Counter(preflight.record_id(r) for r in proposal_original_lane),
            "history-original-partition",
            {"lane": lane, "derived": len(derived_original), "partition": len(proposal_original_lane)},
        )

        observed_path = ownership.OBSERVED_FILES[lane]
        observed_hash, observed_rows, body_hash = ownership.receipt_file(observed_path, lane)
        derived_observed = ownership.derive_observed(
            lane,
            observed_path,
            observed_hash,
            body_hash,
            observed_rows,
            rows,
            ownership.derive(lane, path, file_hash, rows),
            parent_meta["tested_code_head"],
            parent_meta["ci_run_id"],
        )
        derived_observed = [r for r in derived_observed if r.get("t") in {"observed_module", "observed_root"} and r.get("owner") == preflight.PHASE]
        parent_observed = [r for r in parent_rows if r.get("t") in {"observed_module", "observed_root"} and r.get("lane") == lane and r.get("owner") == preflight.PHASE]
        reject(
            Counter(preflight.record_id(r) for r in derived_observed) == Counter(preflight.record_id(r) for r in parent_observed),
            "history-observed-union",
            {"lane": lane, "derived": len(derived_observed), "adopted_parent": len(parent_observed)},
        )
        proposal_observed_lane = [
            a["record_sha256"]
            for a in proposal["observed_assignments"]
            if a["identity"].get("lane") == lane
        ]
        reject(
            Counter(preflight.record_id(r) for r in derived_observed) == Counter(proposal_observed_lane),
            "history-observed-partition",
            {"lane": lane, "derived": len(derived_observed), "partition": len(proposal_observed_lane)},
        )
        receipt_report[lane] = {
            "original_receipt_sha256": file_hash,
            "observed_receipt_sha256": observed_hash,
            "original_assignments": len(derived_original),
            "observed_assignments": len(derived_observed),
        }

    expected = adopt.materialize()
    delegated_bytes = read_bytes(adopt.OUTPUT, "adopted-delegation-unavailable")
    try:
        actual = [json.loads(line) for line in gzip.decompress(delegated_bytes).splitlines()]
    except (OSError, gzip.BadGzipFile, json.JSONDecodeError) as error:
        raise VerificationError("adopted-delegation-format", str(error)) from error
    adopt.validate(expected, actual)
    expected_bytes = adopt.packed(expected)
    reject(delegated_bytes == expected_bytes, "adopted-delegation-bytes", "compressed serialization differs from read-only derivation")

    parent_bytes = read_bytes(preflight.LEDGER, "parent-ledger-unavailable")
    partition_path = preflight.HERE / (preflight.PHASE + "-PARTITION.json.gz")
    partition_bytes = read_bytes(partition_path, "partition-unavailable")
    metadata = actual[0]
    parent_sha = sha256(parent_bytes)
    partition_sha = sha256(partition_bytes)
    reject(metadata.get("historical_sha256") == parent_sha, "adopted-parent-digest", {"expected": parent_sha, "actual": metadata.get("historical_sha256")})
    reject(metadata.get("partition_sha256") == partition_sha, "adopted-partition-digest", {"expected": partition_sha, "actual": metadata.get("partition_sha256")})
    source_branches = [r for r in actual if r.get("t") == "source_branch"]
    reject(
        len(source_branches) == 2
        and {r.get("lane") for r in source_branches} == {"core", "floor"}
        and all(r.get("owner") == preflight.PHASE + ".1" and r.get("origin_owner") == preflight.PHASE and r.get("completion") == "pending" for r in source_branches),
        "adopted-source-branches",
        source_branches,
    )

    controls = history_control_rows(expected, adopt) if include_negative_controls else None
    return {
        "status": "verified",
        "parent_ledger_sha256": parent_sha,
        "partition_sha256": partition_sha,
        "adopted_delegation_sha256": sha256(delegated_bytes),
        "adopted_records": len(actual),
        "original_observed_receipts": receipt_report,
        "original_partition_records": len(proposed_original),
        "observed_partition_records": len(proposal["observed_assignments"]),
        "source_branch_lanes": sorted(r["lane"] for r in source_branches),
        "adopted_serialization_exact": True,
        "history_controls": controls,
        "parent_history_unchanged": True,
    }


def load_ownership_context():
    ownership = load_readonly_module("fablebook_parent_ownership_current", PARENT_OWNERSHIP)
    adopt = load_readonly_module("fablebook_settings_adopt_current", ADOPTION_SCRIPT)
    return ownership, adopt


def parent_unadopted_rows(ownership, adopt) -> list[dict]:
    """Retain debugger records still owned by the parent phase outside this child partition."""
    adopted_origins = {
        row.get("origin_record_sha256") for row in adopt.materialize()
        if row.get("t") in {"module", "root", "observed_module", "observed_root"}
    }
    return [
        row for row in ownership.load_ledger()
        if row.get("t") in {"module", "root", "observed_module", "observed_root"}
        and row.get("app") == "debugger" and row.get("owner") == ownership.PHASE
        and sha256(canon_bytes(row)) not in adopted_origins
    ]


def canon_bytes(value: object) -> bytes:
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def artifact_target(path: Path) -> Path:
    path = Path(path)
    repo_root = ROOT.resolve()
    reject(not CHILD_DIR.is_symlink(), "artifact-root-symlink", str(CHILD_DIR))
    child_root = CHILD_DIR.resolve()
    try:
        child_root.relative_to(repo_root)
    except ValueError as error:
        raise VerificationError("artifact-root-escape", str(child_root)) from error
    cursor = repo_root
    for component in CHILD_DIR.relative_to(ROOT).parts:
        cursor = cursor / component
        reject(not cursor.is_symlink(), "artifact-root-parent-symlink", str(cursor))
    root = CHILD_DIR.resolve()
    resolved_parent = path.parent.resolve()
    try:
        resolved_parent.relative_to(root)
    except ValueError as error:
        raise VerificationError("artifact-path", str(path)) from error
    relative_parent = path.parent.relative_to(CHILD_DIR)
    cursor = CHILD_DIR
    for component in relative_parent.parts:
        cursor = cursor / component
        reject(not cursor.is_symlink(), "artifact-parent-symlink", str(cursor))
    reject(not path.is_symlink(), "artifact-symlink", str(path))
    reject(not path.exists() or path.is_file(), "artifact-type", str(path))
    return path


def artifact_directory_target(path: Path, create: bool = False) -> Path:
    path = Path(path)
    reject(not CHILD_DIR.is_symlink(), "artifact-root-symlink", str(CHILD_DIR))
    child_root = CHILD_DIR.resolve()
    try:
        child_root.relative_to(ROOT.resolve())
        relative = path.relative_to(CHILD_DIR)
    except ValueError as error:
        raise VerificationError("artifact-directory-path", str(path)) from error

    cursor = ROOT
    for component in CHILD_DIR.relative_to(ROOT).parts + relative.parts:
        cursor = cursor / component
        reject(not cursor.is_symlink(), "artifact-directory-symlink", str(cursor))

    if create:
        path.mkdir(parents=True, exist_ok=True)

    reject(not path.exists() or path.is_dir(), "artifact-directory-type", str(path))
    return path


def generation_artifact_paths(generation_id: str, generation_root: Path | None = None) -> dict[str, Path]:
    generation_root = generation_root or GENERATION_ROOT
    reject(re.fullmatch(r"[a-f0-9]{12}-[0-9]+-[a-f0-9]{32}", generation_id) is not None,
           "artifact-generation-id", generation_id)
    return {
        key: generation_root / generation_id / filename
        for key, filename in GENERATION_ARTIFACTS.items()
    }


def generation_artifact_path_map(generation_id: str, generation_root: Path | None = None) -> dict[str, str]:
    generation_root = generation_root or GENERATION_ROOT
    return {
        key: str(path.relative_to(ROOT))
        for key, path in generation_artifact_paths(generation_id, generation_root).items()
    }


def fsync_directory(path: Path) -> None:
    directory_fd = os.open(path, os.O_RDONLY)
    try:
        os.fsync(directory_fd)
    finally:
        os.close(directory_fd)


def validate_generation_pointer_data(data: bytes, generation_root: Path) -> tuple[dict, dict[str, Path]]:
    try:
        pointer = json.loads(data.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise VerificationError("generation-pointer-format", str(error)) from error

    reject(isinstance(pointer, dict), "generation-pointer-format", type(pointer).__name__)
    reject(pointer.get("schema") == GENERATION_POINTER_SCHEMA, "generation-pointer-schema", pointer.get("schema"))
    generation_root = artifact_directory_target(generation_root)
    generation_relative = pointer.get("generation")
    reject(isinstance(generation_relative, str) and not Path(generation_relative).is_absolute(),
           "generation-pointer-path", generation_relative)
    generation_path = ROOT / generation_relative
    reject(generation_path.parent.resolve() == generation_root.resolve(),
           "generation-pointer-root", pointer.get("generation"))
    artifact_directory_target(generation_path)

    records = pointer.get("artifacts")
    reject(isinstance(records, dict) and set(records) == set(GENERATION_ARTIFACTS),
           "generation-pointer-artifacts", records)
    paths = {}
    for key, filename in GENERATION_ARTIFACTS.items():
        path = generation_path / filename
        artifact_target(path)
        record = records[key]
        reject(isinstance(record, dict)
               and record.get("path") == str(path.relative_to(ROOT))
               and SHA256_RE.fullmatch(record.get("sha256", "")) is not None,
               "generation-pointer-artifact", {"key": key, "record": record})
        reject(sha256(read_bytes(path, "generation-artifact-unavailable")) == record["sha256"],
               "generation-artifact-digest", key)
        paths[key] = path
    return pointer, paths


def load_generation_pointer(pointer_path: Path | None = None,
                            generation_root: Path | None = None) -> tuple[dict, dict[str, Path]]:
    pointer_path = pointer_path or DELIVERY_PATH
    generation_root = generation_root or GENERATION_ROOT
    artifact_target(pointer_path)
    return validate_generation_pointer_data(read_bytes(pointer_path, "delivery-pointer-unavailable"), generation_root)


def load_current_delivery() -> tuple[dict, dict[str, Path], dict]:
    pointer, paths = load_generation_pointer()
    try:
        delivery = json.loads(read_bytes(paths["delivery"], "generation-delivery-unavailable").decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise VerificationError("generation-delivery-format", str(error)) from error

    reject(isinstance(delivery, dict), "generation-delivery-format", type(delivery).__name__)
    expected_paths = {key: record["path"] for key, record in pointer["artifacts"].items()}
    ci_run = delivery.get("ci_run")
    reject(delivery.get("schema") == DELIVERY_SCHEMA
           and delivery.get("artifact_generation") == pointer.get("generation")
           and delivery.get("artifact_paths") == expected_paths
           and delivery.get("tested_head") == pointer.get("tested_head")
           and isinstance(ci_run, dict)
           and str(ci_run.get("databaseId")) == str(pointer.get("ci_run_id")),
           "generation-delivery-pointer-mismatch", pointer)
    return delivery, paths, pointer


def load_previous_delivery() -> dict:
    if not DELIVERY_PATH.exists():
        return {}
    try:
        previous = json.loads(read_bytes(DELIVERY_PATH, "delivery-pointer-unavailable").decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError):
        return {}
    if previous.get("schema") == GENERATION_POINTER_SCHEMA:
        return load_current_delivery()[0]
    return previous


def publish_generation(artifact_data: dict[str, bytes], generation_id: str,
                       metadata: dict, generation_root: Path | None = None,
                       pointer_path: Path | None = None, before_activate=None,
                       validator=None) -> dict:
    generation_root = generation_root or GENERATION_ROOT
    pointer_path = pointer_path or DELIVERY_PATH
    reject(set(artifact_data) == set(GENERATION_ARTIFACTS), "generation-artifact-set", sorted(artifact_data))
    generation_root = artifact_directory_target(generation_root, create=True)
    generation_artifact_paths(generation_id, generation_root)
    staging = Path(tempfile.mkdtemp(prefix=".generation-staging-", dir=generation_root))
    final_dir = generation_root / generation_id

    try:
        for key, filename in GENERATION_ARTIFACTS.items():
            path = staging / filename
            artifact_target(path)
            with path.open("xb") as stream:
                stream.write(artifact_data[key])
                stream.flush()
                os.fsync(stream.fileno())
            reject(sha256(read_bytes(path, "generation-stage-unavailable")) == sha256(artifact_data[key]),
                   "generation-stage-digest", key)

        if validator is not None:
            validator(staging)
        fsync_directory(staging)
        reject(not final_dir.exists(), "generation-already-exists", str(final_dir))
        os.rename(staging, final_dir)
        fsync_directory(generation_root)

        paths = {key: final_dir / filename for key, filename in GENERATION_ARTIFACTS.items()}
        pointer = {
            "schema": GENERATION_POINTER_SCHEMA,
            "generation": str(final_dir.relative_to(ROOT)),
            "tested_head": metadata["tested_head"],
            "ci_run_id": str(metadata["ci_run_id"]),
            "artifacts": {
                key: {"path": str(paths[key].relative_to(ROOT)),
                      "sha256": sha256(artifact_data[key])}
                for key in GENERATION_ARTIFACTS
            },
        }
        pointer_data = json.dumps(pointer, sort_keys=True, indent=2).encode() + b"\n"
        if before_activate is not None:
            before_activate(pointer)

        atomic_write_bytes(
            pointer_path,
            pointer_data,
            lambda candidate: validate_generation_pointer_data(read_bytes(candidate, "generation-pointer-staging"), generation_root),
        )
        return pointer
    finally:
        if staging.exists():
            import shutil
            shutil.rmtree(staging)


def new_generation_id(tested_head: str, ci_run_id: str) -> str:
    reject(isinstance(tested_head, str) and GIT_SHA_RE.fullmatch(tested_head) is not None,
           "generation-tested-head", tested_head)
    reject(str(ci_run_id).isdigit(), "generation-ci-run", ci_run_id)
    return f"{tested_head[:12]}-{ci_run_id}-{uuid.uuid4().hex}"


def self_test_publication() -> dict:
    with tempfile.TemporaryDirectory(prefix=f"{OWNER}-publication-self-test-", dir=CHILD_DIR) as temporary:
        root = Path(temporary)
        generation_root = root / "evidence"
        pointer_path = root / f"{OWNER}-DELIVERY.json"
        metadata = {"tested_head": "a" * 40, "ci_run_id": "12345"}
        old_data = {key: f"old-generation:{key}".encode() for key in GENERATION_ARTIFACTS}
        old_id = new_generation_id(metadata["tested_head"], metadata["ci_run_id"])
        publish_generation(old_data, old_id, metadata, generation_root, pointer_path)
        old_pointer = pointer_path.read_bytes()

        next_data = {key: f"next-generation:{key}".encode() for key in GENERATION_ARTIFACTS}
        next_id = new_generation_id("b" * 40, "67890")

        def interrupt_before_pointer(_pointer):
            raise VerificationError("simulated-publication-interruption", "before pointer replacement")

        try:
            publish_generation(
                next_data,
                next_id,
                {"tested_head": "b" * 40, "ci_run_id": "67890"},
                generation_root,
                pointer_path,
                before_activate=interrupt_before_pointer,
            )
        except VerificationError as error:
            reject(error.reason == "simulated-publication-interruption",
                   "publication-interruption-control", error.reason)
        else:
            raise VerificationError("publication-interruption-control", "simulated interruption was not raised")

        reject(pointer_path.read_bytes() == old_pointer,
               "publication-previous-pointer-changed", str(pointer_path))
        active_pointer, active_paths = load_generation_pointer(pointer_path, generation_root)
        reject(active_pointer.get("tested_head") == metadata["tested_head"],
               "publication-previous-generation-not-active", active_pointer.get("tested_head"))
        for key, path in active_paths.items():
            reject(read_bytes(path, "publication-old-artifact-unavailable") == old_data[key],
                   "publication-previous-artifact-changed", key)

    return {
        "status": "passed",
        "controls": {"interruption-before-pointer-preserves-previous-generation": "rejected"},
    }


def check_artifact_paths() -> None:
    artifact_target(DELIVERY_PATH)
    artifact_target(REVIEW_PATH)
    if DELIVERY_PATH.exists():
        try:
            pointer = json.loads(read_bytes(DELIVERY_PATH, "delivery-pointer-unavailable").decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError):
            return
        if pointer.get("schema") == GENERATION_POINTER_SCHEMA:
            validate_generation_pointer_data(read_bytes(DELIVERY_PATH, "delivery-pointer-unavailable"), GENERATION_ROOT)


def run_json(command: list[str], label: str) -> object:
    try:
        result = subprocess.run(command, cwd=ROOT, check=False, capture_output=True, text=True, timeout=90)
    except (OSError, subprocess.TimeoutExpired) as error:
        raise VerificationError(label, f"{' '.join(command)}: {error}") from error
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip()
        raise VerificationError(label, f"{' '.join(command)}: {detail[-3000:]}")
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise VerificationError(label, f"invalid JSON from {' '.join(command)}") from error


def current_git_head() -> tuple[str, str]:
    branch = subprocess.run(["git", "branch", "--show-current"], cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip()
    head = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT, check=True, capture_output=True, text=True).stdout.strip()
    reject(bool(branch) and GIT_SHA_RE.fullmatch(head) is not None, "git-head", {"branch": branch, "head": head})
    return branch, head


def current_pr(ownership, required_head: str | None = None) -> dict:
    branch, local_head = current_git_head()
    if required_head is not None:
        reject(local_head == required_head, "local-head-changed", {"expected": required_head, "actual": local_head})
    rows = ownership.gh_json([
        "pr", "list", "--head", branch, "--state", "open",
        "--json", "number,url,state,headRefName,headRefOid,baseRefName",
    ])
    reject(isinstance(rows, list) and len(rows) == 1, "current-pr", {"branch": branch, "rows": rows})
    pr = rows[0]
    reject(pr.get("headRefName") == branch and pr.get("headRefOid") == local_head,
           "current-pr-head", {"branch": branch, "local_head": local_head, "pr": pr})
    pr["tested_head"] = local_head
    return pr


def current_run(ownership, pr: dict, required_run: str | None = None) -> tuple[dict, dict, dict]:
    run_rows = ownership.gh_json([
        "run", "list", "--branch", pr["headRefName"], "--event", "pull_request",
        "--workflow", "ci", "--limit", "100", "--json",
        "databaseId,headSha,headBranch,event,workflowName,status,conclusion,url,createdAt",
    ])
    candidates = [row for row in run_rows if row.get("headSha") == pr["tested_head"]
                 and row.get("headBranch") == pr["headRefName"]
                 and row.get("event") == "pull_request" and row.get("workflowName") == "ci"
                 and row.get("status") == "completed" and row.get("conclusion") == "success"]
    if required_run is not None:
        candidates = [row for row in candidates if str(row.get("databaseId")) == str(required_run)]
    reject(bool(candidates), "exact-head-successful-ci-run", {"head": pr["tested_head"], "required_run": required_run})
    run = max(candidates, key=lambda row: row.get("createdAt", ""))
    run_id = str(run.get("databaseId"))
    snapshot = ownership.verify_ci_provenance(pr["number"], pr["tested_head"], run_id)
    full_run = ownership.gh_json(["run", "view", run_id, "--json",
                                  "databaseId,headSha,headBranch,status,conclusion,event,workflowName,url,jobs"])
    jobs = {str(job.get("name")): job for job in full_run.get("jobs", [])}
    required_jobs = {}
    for name in ("core", "floor"):
        job = jobs.get(name)
        reject(isinstance(job, dict) and job.get("conclusion") == "success"
               and isinstance(job.get("databaseId"), int),
               "required-ci-job", {"run_id": run_id, "job": name, "actual": job})
        required_jobs[name] = job
    return run, snapshot, required_jobs


def download_job_log(run_id: str, job: dict, lane: str) -> Path:
    command = [
        "gh", "api", "--allow-escape-sequences",
        f"repos/szTheory/fablebook/actions/jobs/{job['databaseId']}/logs",
    ]
    fd, log_name = tempfile.mkstemp(prefix=f"{OWNER}-{run_id}-{lane}-ci-job-", suffix=".log", dir="/private/tmp")
    log_path = Path(log_name)
    process = None
    try:
        with os.fdopen(fd, "wb") as stream:
            try:
                process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            except OSError as error:
                raise VerificationError("ci-log-unavailable", str(error)) from error
            assert process.stdout is not None and process.stderr is not None
            deadline = time.monotonic() + 300
            log_size = 0
            while True:
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    raise VerificationError("ci-log-timeout", {"lane": lane, "bytes": log_size})
                readable, _writable, _exceptional = select.select([process.stdout], [], [], min(remaining, 1.0))
                if not readable:
                    continue
                chunk = os.read(process.stdout.fileno(), 64 * 1024)
                if not chunk:
                    break
                log_size += len(chunk)
                reject(log_size <= MAX_CI_JOB_LOG_BYTES, "ci-job-log-size", {"lane": lane, "bytes": log_size})
                stream.write(chunk)
            stderr = process.stderr.read()
            try:
                process.wait(timeout=max(0.1, deadline - time.monotonic()))
            except subprocess.TimeoutExpired as error:
                raise VerificationError("ci-log-timeout", {"lane": lane, "bytes": log_size}) from error
            reject(process.returncode == 0, "ci-job-log", {"command": command, "exit": process.returncode,
                   "stderr": stderr[-500:].decode("utf-8", "replace")})
            stream.flush()
            os.fsync(stream.fileno())
        reject(0 < log_size <= MAX_CI_JOB_LOG_BYTES, "ci-job-log-size", {"run_id": run_id, "lane": lane, "bytes": log_size})
        return log_path
    except Exception:
        if process is not None and process.poll() is None:
            process.kill()
            process.wait()
        log_path.unlink(missing_ok=True)
        raise


def extract_job_receipt(run_id: str, job: dict, lane: str, output_path: Path) -> dict:
    output_path = artifact_target(output_path)
    log_path = download_job_log(run_id, job, lane)
    rows = 0
    file_hash = hashlib.sha256()
    body_hash = hashlib.sha256()
    fd, temporary_name = tempfile.mkstemp(prefix=f".{lane}-receipt-", suffix=".tmp", dir=CHILD_DIR)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(fd, "wb") as stream:
            with log_path.open("r", encoding="utf-8-sig") as log_stream:
                for log_line in log_stream:
                    if "FABLEBOOK_OTP_INVENTORY_V2 " not in log_line:
                        continue
                    payload = log_line.split("FABLEBOOK_OTP_INVENTORY_V2 ", 1)[1].rstrip("\r\n")
                    line = RECEIPT_PREFIX + payload.encode("utf-8") + b"\n"
                    stream.write(line)
                    file_hash.update(line)
                    try:
                        row = json.loads(line[len(RECEIPT_PREFIX):])
                    except json.JSONDecodeError as error:
                        raise VerificationError("ci-log-receipt-json", {"lane": lane, "row": rows + 1}) from error
                    if row.get("kind") != "footer":
                        body_hash.update(line)
                    rows += 1
            stream.flush()
            os.fsync(stream.fileno())
        reject(rows >= 4, "ci-log-receipt-missing", {"lane": lane, "rows": rows})
        own, _adopt = load_ownership_context()
        digest, receipt_rows, body_digest = own.receipt_file(temporary, lane)
        meta = receipt_rows[0]
        expected_lock = lock_digests_from_archive()[lane]
        reject(meta.get("schema") == "fablebook.otp-inventory.v2" and meta.get("lane") == lane,
               "receipt-metadata", {"lane": lane, "meta": meta})
        reject(meta.get("elixir") == SUPPORTED_RUNTIMES[lane]["elixir"]
               and meta.get("otp") == SUPPORTED_RUNTIMES[lane]["otp"],
               "receipt-runtime", {"lane": lane, "meta": meta})
        reject(meta.get("lock_sha256") == expected_lock, "receipt-lock", {"lane": lane, "expected": expected_lock, "actual": meta.get("lock_sha256")})
        reject(file_hash.hexdigest() == digest and body_hash.hexdigest() == body_digest,
               "receipt-digest", {"lane": lane})
        os.replace(temporary, output_path)
        return {"lane": lane, "path": str(output_path.relative_to(ROOT)), "sha256": digest,
                "body_sha256": body_digest, "rows": rows, "runtime": SUPPORTED_RUNTIMES[lane],
                "lock_sha256": expected_lock}
    finally:
        log_path.unlink(missing_ok=True)
        if temporary.exists():
            temporary.unlink()


def lock_digests_from_archive() -> dict[str, str]:
    files = archive_files(read_bytes(ARCHIVE, "successor-unavailable"), "successor-locks")
    manifest = decode_manifest(files, "successor-locks")
    return {lane: manifest["locks"][lane]["sha256"] for lane in ("core", "floor")}


def verify_installed_receipts(paths: list[Path]) -> dict:
    for path in paths:
        artifact_target(path)
    elixir_bin = Path("/private/tmp/fablebook-asdf/installs/elixir/1.20.4-otp-29/bin/elixir")
    erlang_bin = Path("/private/tmp/fablebook-asdf/installs/erlang/29.1.2/bin")
    mix_bin = elixir_bin.with_name("mix")
    env = os.environ.copy()
    if elixir_bin.exists() and mix_bin.exists() and erlang_bin.exists():
        env["PATH"] = f"{erlang_bin}:{elixir_bin.parent}:{env.get('PATH', '')}"
        env.setdefault("MIX_HOME", "/private/tmp/fablebook-mix-home")
        env.setdefault("HEX_HOME", "/private/tmp/fablebook-hex-home")
        mix = str(mix_bin)
    else:
        mix = "mix"
    env["MIX_ENV"] = "test"
    expression = "Fablebook.Test.InstalledOtp.verify_receipt_files!(" + json.dumps([str(path) for path in paths]) + ")"
    command = [mix, "run", "--no-start", "-e", expression]
    try:
        result = subprocess.run(command, cwd=ROOT, env=env, check=False, capture_output=True, text=True, timeout=300)
    except (OSError, subprocess.TimeoutExpired) as error:
        raise VerificationError("installed-otp-validation", str(error)) from error
    reject(result.returncode == 0, "installed-otp-validation", {"exit": result.returncode, "stderr": result.stderr[-4000:]})
    return {"command": command, "result": result.stdout.strip()[-6000:]}


def identity_key(row: dict) -> tuple:
    kind = row.get("t", "").removeprefix("observed_")
    return (kind, row.get("lane"), row.get("app"), row.get("module"),
            row.get("function"), row.get("arity"))


def assert_adopted_debugger_assignments(adopted: list[dict], lane: str, by_key: dict[tuple, dict]) -> None:
    for prior in adopted:
        if (prior.get("lane") != lane or prior.get("t") not in {"module", "root"}
                or prior.get("app") != "debugger"
                or prior.get("owner") not in {SELECTED_OWNER, REMAINDER_OWNER}):
            continue
        key = identity_key(prior)
        reject(key in by_key, "missing-current-assignment", {"lane": lane, "identity": key})


def source_for_settings(lane: str, ownership) -> tuple[bytes, str]:
    files = archive_files(read_bytes(ARCHIVE, "successor-unavailable"), "selected-settings-source")
    name = f"{lane}/debugger/src/{SELECTED_MODULE}.erl"
    body = files.get(name)
    reject(body is not None, "selected-settings-source-missing", name)
    assert body is not None
    expected = ownership.EXACT_SOURCE_HASHES[lane].get(SELECTED_MODULE)
    actual = sha256(body)
    reject(actual == expected, "selected-settings-source-sha256", {"lane": lane, "expected": expected, "actual": actual})
    return body, actual


def fresh_namespace(ownership, adopt, receipt_paths: dict[str, Path], receipt_summaries: dict[str, dict],
                    tested_head: str, ci_run_id: str, pr_number: int) -> list[dict]:
    adopted = adopt.materialize()
    parent_unadopted = parent_unadopted_rows(ownership, adopt)
    adopted_by_identity = {}
    for prior in adopted:
        if prior.get("t") in {"module", "root"}:
            adopted_by_identity[identity_key(prior)] = prior
    parent_by_identity = {identity_key(prior): prior for prior in parent_unadopted
                          if prior.get("t") in {"module", "root"}}
    child_modules = {(row.get("lane"), row.get("module")) for row in adopted
                     if row.get("t") == "module" and row.get("owner") in {SELECTED_OWNER, REMAINDER_OWNER}}
    fresh = []
    for lane in ("core", "floor"):
        receipt_path = receipt_paths[lane]
        file_hash, current_rows, body_hash = ownership.receipt_file(receipt_path, lane)
        old_path, old_hash, old_rows = ownership.receipt(lane)
        ownership.assert_active_subset(lane, old_rows, current_rows)
        canonical = ownership.derive(lane, receipt_path, file_hash, current_rows)
        current_assignments = []
        for record in canonical:
            if record.get("t") not in {"module", "root"} or record.get("app") != "debugger":
                continue
            key = identity_key(record)
            prior = adopted_by_identity.get(key)
            parent_prior = parent_by_identity.get(key)
            selected = (record.get("t") == "module" and record.get("module") == SELECTED_MODULE)
            selected = selected or (record.get("t") == "root" and
                                    (record.get("module"), record.get("function"), record.get("arity")) in SELECTED_ROOTS)
            if prior:
                assigned = prior.get("owner")
            elif parent_prior:
                assigned = parent_prior.get("owner")
            elif record.get("t") == "root" and (lane, record.get("module")) in child_modules:
                assigned = REMAINDER_OWNER
            else:
                assigned = record.get("owner", "existing-active-baseline")
            if selected:
                reject(prior is not None and prior.get("owner") == SELECTED_OWNER,
                       "selected-origin-owner", {"lane": lane, "record": record, "prior": prior})
                assigned = SELECTED_OWNER
            if prior and prior.get("pending") and record.get("pending") is False and not selected:
                raise VerificationError("unreviewed-module-completion", {"lane": lane, "identity": key})
            reject(assigned is not None and assigned != "", "unowned-debugger-identity", {"lane": lane, "identity": key})
            identity = ownership.typed_identity(record["t"], record)
            child = {
                "t": "fresh_observed_" + record["t"], "namespace": "fresh-child",
                "lane": lane, "identity": identity,
                "identity_sha256": sha256(canon_bytes(identity)), "owner": assigned,
                "pending": record.get("pending", True),
                "current_record_sha256": record.get("record_sha256"),
                "origin_record_sha256": (prior.get("origin_record_sha256", prior.get("record_sha256")) if prior else
                                          sha256(canon_bytes(parent_prior)) if parent_prior else None),
                "parent_owner": record.get("owner"),
                "historical": ownership.history_projection(prior or parent_prior),
                "tested_head": tested_head, "ci_run_id": ci_run_id, "pr_number": pr_number,
                "record": record,
            }
            if record.get("t") == "root":
                child["chain_id"] = record.get("chain_id")
                child["references"] = record.get("references", [])
                child["origin_chain_id"] = (prior or parent_prior or {}).get("chain_id")
            current_assignments.append(child)

        by_key = {identity_key(row["record"]): row for row in current_assignments}
        assert_adopted_debugger_assignments(adopted, lane, by_key)

        selected_modules = [row for row in current_assignments
                            if row["identity"].get("kind") == "module" and row["identity"].get("module") == SELECTED_MODULE]
        selected_roots = [row for row in current_assignments if row["identity"].get("kind") == "root"
                          and (row["identity"].get("module"), row["identity"].get("function"), row["identity"].get("arity")) in SELECTED_ROOTS]
        reject(len(selected_modules) == 1 and selected_modules[0]["owner"] == SELECTED_OWNER,
               "selected-module-count", {"lane": lane, "count": len(selected_modules)})
        reject(len(selected_roots) == 3 and all(row["owner"] == SELECTED_OWNER for row in selected_roots),
               "selected-root-count", {"lane": lane, "count": len(selected_roots)})

        body, source_digest = source_for_settings(lane, ownership)
        module_active = any(row.get("kind") == "active_module" and row.get("app") == "debugger"
                            and row.get("module") == SELECTED_MODULE for row in current_rows)
        source_row = next((row for row in current_rows if row.get("kind") == "source_file"
                           and row.get("app") == "debugger" and row.get("path") == f"src/{SELECTED_MODULE}.erl"), None)
        reject(module_active and source_row is not None and source_row.get("bytes") == len(body),
               "selected-module-current-source", {"lane": lane, "active": module_active, "source": source_row})
        selected_modules[0]["pending"] = False
        selected_modules[0]["completion"] = "selected-family-source-and-guard-proved"
        selected_modules[0]["source_sha256"] = source_digest
        selected_modules[0]["source_bytes"] = len(body)
        current_assignments.append({
            "t": "fresh_observed_completion", "namespace": "fresh-child", "lane": lane,
            "identity": {"kind": "module_completion", "lane": lane, "app": "debugger", "module": SELECTED_MODULE},
            "identity_sha256": sha256(canon_bytes({"kind": "module_completion", "lane": lane, "app": "debugger", "module": SELECTED_MODULE})),
            "app": "debugger", "module": SELECTED_MODULE, "owner": SELECTED_OWNER,
            "completion": "selected-family-source-and-guard-proved", "source_sha256": source_digest,
            "source_bytes": len(body), "tested_head": tested_head, "ci_run_id": ci_run_id,
            "pr_number": pr_number,
        })
        summary = receipt_summaries[lane]
        fresh.append({"t": "fresh_lane_receipt", "lane": lane, **summary,
                      "tested_head": tested_head, "ci_run_id": ci_run_id, "pr_number": pr_number,
                      "active_subset_preserved": True, "selected_module_source_sha256": source_digest})
        fresh.extend(sorted(current_assignments, key=lambda row: canon_bytes(row["identity"])))
    return fresh


def observed_meta(pr: dict, run: dict, jobs: dict, receipt_summaries: dict,
                  ownership, adopt, review_passes: int) -> dict:
    parent_rows = ownership.load_ledger()
    adoption_bytes = read_bytes(ADOPTION_LEDGER, "adopted-delegation-unavailable")
    parent_bytes = read_bytes(ownership.OUTPUT, "historical-ledger-unavailable")
    partition_bytes = read_bytes(ADOPTION_PARTITION, "adoption-partition-unavailable")
    meta = {
        "t": "fresh_meta", "schema": OBSERVED_SCHEMA, "status": "prepared-before-merge",
        "repository": "szTheory/fablebook", "pr_number": pr["number"], "pr_url": pr["url"],
        "tested_head": pr["tested_head"], "artifact_head": None,
        "artifact_relationship": "workspace-evidence-for-tested-code-head; committing these bytes changes the certified SHA",
        "ci_run_id": str(run["databaseId"]), "ci_run_url": run["url"],
        "jobs": {lane: {"name": jobs[lane]["name"], "id": jobs[lane]["databaseId"],
                         "url": jobs[lane].get("url") or run["url"].rstrip("/") + "/job/" + str(jobs[lane]["databaseId"]),
                         "conclusion": jobs[lane]["conclusion"]}
                 for lane in ("core", "floor")},
        "checks": sorted(ownership.REQUIRED_CI_CHECKS),
        "runtimes": SUPPORTED_RUNTIMES, "locks": lock_digests_from_archive(),
        "source_archive_sha256": SUCCESSOR_SHA256,
        "authority_sha256": sha256(adoption_bytes), "historical_sha256": sha256(parent_bytes),
        "partition_sha256": sha256(partition_bytes), "receipt_summaries": receipt_summaries,
        "review_passes": review_passes, "merge_commit": None,
        "ownership_boundary": {"selected": SELECTED_OWNER, "remainder": REMAINDER_OWNER,
                               "sec_01": "pending-for-phase-5"},
        "historical_parent_rows": len(parent_rows),
        "unadopted_parent_rows": len(parent_unadopted_rows(ownership, adopt)),
        "adopted_rows": len(adopt.materialize()),
        "current_ci_provenance": True,
    }
    if ACTIVE_SCOPE == "debugger-remainder":
        meta["scope_contract"] = copy.deepcopy(REMAINDER_SCOPE_CONTRACT)
        meta["scope_contract_sha256"] = sha256(canon_bytes(REMAINDER_SCOPE_CONTRACT))
    return meta


def history_projection_local(record: dict | None) -> dict | None:
    if record is None:
        return None
    fields = ("owner", "pending", "task", "state", "zero_graph_hits", "source", "kinds",
              "record_sha256", "steps", "chain_id", "references")
    return {field: copy.deepcopy(record[field]) for field in fields if field in record}


def validate_observed_records(rows: list[dict], expected_history: list[dict], required_checks: set[str],
                              expected_head: str = "a" * 40, expected_run: str = "12345") -> None:
    reject(len(rows) > len(expected_history) and rows[0].get("t") == "fresh_meta",
           "observed-format", "missing metadata or namespace")
    meta = rows[0]
    reject(meta.get("schema") == OBSERVED_SCHEMA and meta.get("current_ci_provenance") is True,
           "observed-meta", meta)
    reject(isinstance(meta.get("checks"), list) and meta["checks"] == sorted(required_checks),
           "observed-required-checks", meta.get("checks"))
    reject(meta.get("artifact_head") is None and "workspace-evidence-for-tested-code-head" in meta.get("artifact_relationship", ""),
           "observed-artifact-relationship", meta.get("artifact_relationship"))
    reject(meta.get("tested_head") == expected_head and GIT_SHA_RE.fullmatch(meta.get("tested_head", "")) is not None,
           "observed-head", meta.get("tested_head"))
    reject(str(meta.get("ci_run_id")) == expected_run and expected_run.isdigit() and int(expected_run) > 0,
           "observed-run", meta.get("ci_run_id"))
    reject(meta.get("source_archive_sha256") == SUCCESSOR_SHA256, "observed-source", meta.get("source_archive_sha256"))
    reject(meta.get("locks") == lock_digests_from_archive(), "observed-locks", meta.get("locks"))
    reject(meta.get("runtimes") == SUPPORTED_RUNTIMES, "observed-runtimes", meta.get("runtimes"))
    reject(meta.get("review_passes", 0) in (1, 2), "observed-review-cap", meta.get("review_passes"))
    historical = rows[1:1 + len(expected_history)]
    reject(historical == expected_history, "observed-history", "original/adopted history changed or is incomplete")
    adopted_by_origin = {
        (row.get("origin_record_sha256") or sha256(canon_bytes(row))): row for row in expected_history
        if row.get("t") in {"module", "root"}
    }
    child_module_ids = {(row.get("lane"), row.get("module")) for row in expected_history
                        if row.get("t") == "module" and row.get("owner") in {SELECTED_OWNER, REMAINDER_OWNER}}
    current = rows[1 + len(expected_history):]
    reject(len(current) > 0, "observed-current", "fresh child namespace is empty")
    for lane in ("core", "floor"):
        receipt = [row for row in current if row.get("t") == "fresh_lane_receipt" and row.get("lane") == lane]
        modules = [row for row in current if row.get("t") == "fresh_observed_module" and row.get("lane") == lane
                   and row.get("identity", {}).get("module") == SELECTED_MODULE]
        roots = [row for row in current if row.get("t") == "fresh_observed_root" and row.get("lane") == lane
                 and (row.get("identity", {}).get("module"), row.get("identity", {}).get("function"), row.get("identity", {}).get("arity")) in SELECTED_ROOTS]
        completion = [row for row in current if row.get("t") == "fresh_observed_completion" and row.get("lane") == lane
                      and row.get("identity", {}).get("module") == SELECTED_MODULE]
        reject(len(receipt) == 1 and receipt[0].get("footer_present") is True
               and receipt[0].get("tested_head") == expected_head and receipt[0].get("ci_run_id") == expected_run
               and receipt[0].get("active_subset_preserved") is True,
               "observed-lane-receipt", {"lane": lane, "receipt": receipt})
        reject(len(modules) == 1 and modules[0].get("owner") == SELECTED_OWNER
               and modules[0].get("tested_head") == expected_head and modules[0].get("ci_run_id") == expected_run
               and modules[0].get("origin_record_sha256") in adopted_by_origin,
               "observed-selected-module", {"lane": lane, "modules": modules})
        reject(len(roots) == 3 and all(row.get("owner") == SELECTED_OWNER and row.get("chain_id") for row in roots),
               "observed-selected-roots", {"lane": lane, "count": len(roots)})
        reject(all(SHA256_RE.fullmatch(row.get("chain_id", "")) is not None
                   and row.get("origin_record_sha256") in adopted_by_origin
                   and row.get("origin_chain_id") == row.get("historical", {}).get("chain_id") for row in roots),
               "observed-root-chain", {"lane": lane})
        reject(len(completion) == 1 and completion[0].get("completion") == "selected-family-source-and-guard-proved"
               and completion[0].get("source_sha256") == ownership_source_sha(lane),
               "observed-completion", {"lane": lane, "completion": completion})
    identities = []
    for row in current:
        if row.get("t") not in {"fresh_observed_module", "fresh_observed_root"}:
            continue
        owner = row.get("owner")
        reject(isinstance(owner, str) and bool(owner), "observed-owner", row.get("identity"))
        origin = row.get("origin_record_sha256")
        if origin:
            prior = adopted_by_origin.get(origin)
            reject(prior is not None and row.get("identity") == {
                "kind": prior.get("t"), "lane": prior.get("lane"), "app": prior.get("app"),
                **({"module": prior.get("module")} if prior.get("module") is not None else {}),
                **({"function": prior.get("function"), "arity": prior.get("arity")} if prior.get("t") == "root" else {}),
            }, "observed-origin-identity", row.get("identity"))
            reject(owner == prior.get("owner") and row.get("historical") == history_projection_local(prior),
                   "observed-origin-owner", {"origin": origin, "owner": owner})
        else:
            identity = row.get("identity", {})
            expected_owner = REMAINDER_OWNER if identity.get("kind") == "root" and (row.get("lane"), identity.get("module")) in child_module_ids else row.get("parent_owner")
            reject(owner == expected_owner and isinstance(expected_owner, str) and bool(expected_owner),
                   "observed-new-owner", {"identity": identity, "owner": owner, "expected": expected_owner})
        identity = canon_bytes({"lane": row.get("lane"), **row.get("identity", {})})
        identities.append(identity)
    reject(len(identities) == len(set(identities)), "observed-duplicate-identity", "fresh identity repeated")


def validate_remainder_observed_records(rows: list[dict], expected_history: list[dict],
                                        expected_head: str, expected_run: str) -> None:
    meta = rows[0]
    reject(meta.get("scope_contract") == REMAINDER_SCOPE_CONTRACT
           and meta.get("scope_contract_sha256") == sha256(canon_bytes(REMAINDER_SCOPE_CONTRACT)),
           "remainder-scope-contract", meta.get("scope_contract"))
    reject(meta.get("ownership_boundary") == {
        "selected": SELECTED_OWNER, "remainder": REMAINDER_OWNER,
        "sec_01": "pending-for-phase-5",
    }, "remainder-ownership-boundary", meta.get("ownership_boundary"))

    adopted_debugger = [row for row in expected_history
                        if row.get("t") in {"module", "root"} and row.get("app") == "debugger"
                        and row.get("owner") in {SELECTED_OWNER, REMAINDER_OWNER}]
    current = rows[1 + len(expected_history):]
    for lane in ("core", "floor"):
        receipts = [row for row in current if row.get("t") == "fresh_lane_receipt" and row.get("lane") == lane]
        reject(len(receipts) == 1 and receipts[0].get("tested_head") == expected_head
               and receipts[0].get("ci_run_id") == expected_run
               and receipts[0].get("active_subset_preserved") is True
               and receipts[0].get("footer_present") is True,
               "remainder-current-lane-receipt", {"lane": lane, "receipts": receipts})

        lane_current = [row for row in current if row.get("lane") == lane
                        and row.get("t") in {"fresh_observed_module", "fresh_observed_root"}]
        by_origin = {}
        for row in lane_current:
            origin = row.get("origin_record_sha256")
            if origin is not None:
                by_origin.setdefault(origin, []).append(row)
            reject(row.get("tested_head") == expected_head and row.get("ci_run_id") == expected_run
                   and isinstance(row.get("owner"), str) and bool(row["owner"]),
                   "remainder-current-assignment-provenance", {"lane": lane, "identity": row.get("identity")})

        required = [row for row in adopted_debugger if row.get("lane") == lane]
        for prior in required:
            origin = prior.get("origin_record_sha256") or sha256(canon_bytes(prior))
            matches = by_origin.get(origin, [])
            reject(len(matches) == 1 and matches[0].get("owner") == prior.get("owner")
                   and matches[0].get("historical") == history_projection_local(prior),
                   "remainder-adopted-assignment", {"lane": lane, "identity": identity_key(prior), "matches": len(matches)})

        selected_roots = [row for row in lane_current if row.get("t") == "fresh_observed_root"
                          and row.get("identity", {}).get("module") == "dbg_wx_mon"
                          and row.get("identity", {}).get("function") in {"start", "load_settings", "load_settings2"}
                          and row.get("identity", {}).get("arity") == 2]
        reject(len(selected_roots) == 3 and all(row.get("owner") == SELECTED_OWNER
               and SHA256_RE.fullmatch(row.get("chain_id", "")) is not None for row in selected_roots),
               "remainder-selected-roots", {"lane": lane, "roots": selected_roots})

        pending_callback = [row for row in expected_history if row.get("t") == "source_branch"
                            and row.get("lane") == lane and row.get("module") == "dbg_icmd"
                            and row.get("function") == "break_p" and row.get("arity") == 4]
        reject(len(pending_callback) == 1 and pending_callback[0].get("owner") == SELECTED_OWNER
               and pending_callback[0].get("completion") == "pending",
               "remainder-pending-callback-body", {"lane": lane, "records": pending_callback})


def validate_observed_for_scope(rows: list[dict], expected_history: list[dict], required_checks: set[str],
                                expected_head: str = "a" * 40, expected_run: str = "12345") -> None:
    validate_observed_records(rows, expected_history, required_checks, expected_head, expected_run)
    if ACTIVE_SCOPE == "debugger-remainder":
        validate_remainder_observed_records(rows, expected_history, expected_head, expected_run)


def ownership_source_sha(lane: str) -> str:
    files = archive_files(read_bytes(ARCHIVE, "successor-unavailable"), "selected-settings-source")
    return sha256(files[f"{lane}/debugger/src/{SELECTED_MODULE}.erl"])


def self_test_observed() -> dict:
    ownership, adopt = load_ownership_context()
    adopted = adopt.materialize()
    parent_rows = parent_unadopted_rows(ownership, adopt)
    history = parent_rows + adopted
    head, run_id = "a" * 40, "12345"
    pr = {"number": 31, "url": "https://github.com/szTheory/fablebook/pull/31", "tested_head": head}
    run = {"databaseId": int(run_id), "url": "https://github.com/szTheory/fablebook/actions/runs/12345"}
    jobs = {lane: {"name": lane, "databaseId": index, "conclusion": "success"}
            for lane, index in (("core", 101), ("floor", 102))}
    meta = observed_meta(pr, run, jobs, {"core": {}, "floor": {}}, ownership, adopt, 1)
    reject(meta["checks"] == sorted(ownership.REQUIRED_CI_CHECKS),
           "observed-required-check-fixture", meta["checks"])
    rows = [meta]
    rows.extend(copy.deepcopy(history))
    for lane in ("core", "floor"):
        rows.append({"t": "fresh_lane_receipt", "lane": lane, "footer_present": True,
                     "tested_head": head, "ci_run_id": run_id, "active_subset_preserved": True})
        scoped_owners = ({SELECTED_OWNER, REMAINDER_OWNER}
                         if ACTIVE_SCOPE == "debugger-remainder" else {SELECTED_OWNER})
        scoped_prior = [row for row in adopted if row.get("lane") == lane
                        and row.get("owner") in scoped_owners
                        and row.get("app") == "debugger" and row.get("t") in {"module", "root"}]
        for prior in scoped_prior:
            kind = prior["t"]
            identity = ownership.typed_identity(kind, prior)
            row = {"t": "fresh_observed_" + kind, "lane": lane, "identity": identity,
                   "owner": prior.get("owner"), "tested_head": head, "ci_run_id": run_id,
                   "chain_id": prior.get("chain_id"), "origin_chain_id": prior.get("chain_id"),
                   "origin_record_sha256": prior.get("origin_record_sha256"),
                   "historical": ownership.history_projection(prior)}
            rows.append(row)
        for prior in parent_rows:
            if prior.get("lane") != lane or prior.get("t") not in {"module", "root"}:
                continue
            identity = ownership.typed_identity(prior["t"], prior)
            rows.append({"t": "fresh_observed_" + prior["t"], "lane": lane, "identity": identity,
                         "owner": prior.get("owner"), "parent_owner": prior.get("owner"),
                         "origin_record_sha256": sha256(canon_bytes(prior)),
                         "historical": ownership.history_projection(prior),
                         "chain_id": prior.get("chain_id"), "origin_chain_id": prior.get("chain_id"),
                         "tested_head": head, "ci_run_id": run_id})
        source_sha = ownership_source_sha(lane)
        rows.append({"t": "fresh_observed_completion", "lane": lane,
                     "identity": {"kind": "module_completion", "lane": lane, "app": "debugger", "module": SELECTED_MODULE},
                     "owner": SELECTED_OWNER, "completion": "selected-family-source-and-guard-proved",
                     "source_sha256": source_sha})
    validate_observed_for_scope(rows, history, ownership.REQUIRED_CI_CHECKS, head, run_id)

    controls = {}
    def must_reject(name: str, mutate) -> None:
        altered = copy.deepcopy(rows)
        mutate(altered)
        try:
            validate_observed_for_scope(altered, history, ownership.REQUIRED_CI_CHECKS, head, run_id)
        except VerificationError:
            controls[name] = "rejected"
        else:
            raise VerificationError("observed-negative-control-accepted", name)

    assignment_fixture = [
        {"t": "root", "lane": "core", "app": "stdlib", "module": "escript",
         "function": "debug", "arity": 3, "owner": REMAINDER_OWNER},
        {"t": "module", "lane": "core", "app": "debugger", "module": SELECTED_MODULE,
         "owner": SELECTED_OWNER},
    ]
    debugger_fixture_key = identity_key(assignment_fixture[1])
    assert_adopted_debugger_assignments(assignment_fixture, "core", {debugger_fixture_key: {}})
    controls["unrelated-adopted-app-excluded"] = "passed"
    try:
        assert_adopted_debugger_assignments(assignment_fixture, "core", {})
    except VerificationError as error:
        reject(error.reason == "missing-current-assignment", "observed-assignment-fixture", error.reason)
        controls["missing-adopted-debugger-assignment"] = "rejected"
    else:
        raise VerificationError("observed-negative-control-accepted", "missing-adopted-debugger-assignment")

    current_start = 1 + len(history)
    must_reject("missing-required-check", lambda r: r[0].update(checks=r[0]["checks"][:-1]))
    must_reject("wrong-head", lambda r: r[0].update(tested_head="b" * 40))
    must_reject("wrong-run", lambda r: r[0].update(ci_run_id="0"))
    must_reject("wrong-runtime", lambda r: r[0]["runtimes"].update(core={"elixir": "0", "otp": "0"}))
    must_reject("wrong-lock", lambda r: r[0]["locks"].update(core="0" * 64))
    must_reject("wrong-source", lambda r: r[0].update(source_archive_sha256="0" * 64))
    must_reject("missing-original-assignment", lambda r: r.pop(1 + len(parent_rows) + next(i for i,x in enumerate(adopted) if x.get("t") == "module" and x.get("owner") == SELECTED_OWNER)))
    must_reject("missing-observed-assignment", lambda r: r.pop(next(i for i,x in enumerate(r) if i >= current_start and x.get("t") == "fresh_observed_module")))
    must_reject("missing-completion-history", lambda r: r.pop(next(i for i,x in enumerate(r) if x.get("t") == "fresh_observed_completion")))
    must_reject("changed-chain", lambda r: next(x for x in r[current_start:] if x.get("t") == "fresh_observed_root"
        and (x.get("identity", {}).get("module"), x.get("identity", {}).get("function"),
             x.get("identity", {}).get("arity")) in SELECTED_ROOTS).update(origin_chain_id="0" * 64))
    must_reject("active-subset-loss", lambda r: next(x for x in r[current_start:] if x.get("t") == "fresh_lane_receipt").update(active_subset_preserved=False))
    must_reject("wrong-owner", lambda r: next(x for x in r[current_start:] if x.get("t") == "fresh_observed_root"
        and (x.get("identity", {}).get("module"), x.get("identity", {}).get("function"),
             x.get("identity", {}).get("arity")) in SELECTED_ROOTS).update(owner=REMAINDER_OWNER))
    must_reject("parent-owner-preserved", lambda r: next(x for x in r[current_start:] if x.get("t") == "fresh_observed_module" and x.get("origin_record_sha256") in {sha256(canon_bytes(y)) for y in parent_rows if y.get("t") == "module"}).update(owner=REMAINDER_OWNER))
    must_reject("new-unowned-identity", lambda r: r.append({"t": "fresh_observed_module", "lane": "core", "identity": {"kind": "module", "module": "new"}, "owner": None}))
    must_reject("historical-input-is-not-current-ci", lambda r: r[0].update(current_ci_provenance=False))
    if ACTIVE_SCOPE == "debugger-remainder":
        must_reject("missing-remainder-assignment", lambda r: r.pop(next(i for i, x in enumerate(r)
            if i >= current_start and x.get("owner") == REMAINDER_OWNER
            and x.get("t") in {"fresh_observed_module", "fresh_observed_root"})))
        must_reject("wrong-scope-contract", lambda r: r[0].update(scope_contract_sha256="0" * 64))
        must_reject("missing-inherited-pending-callback", lambda r: r.pop(next(i for i, x in enumerate(r)
            if x.get("t") == "source_branch" and x.get("lane") == "core"
            and x.get("module") == "dbg_icmd" and x.get("function") == "break_p")))
    fd, malformed_name = tempfile.mkstemp(prefix="receipt-negative-", suffix=".jsonl", dir="/private/tmp")
    malformed_path = Path(malformed_name)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(RECEIPT_PREFIX + b'{"kind":"meta","lane":"core"}\n')
        try:
            ownership.receipt_file(malformed_path, "core")
        except (OSError, ValueError):
            pass
        else:
            raise VerificationError("observed-negative-control-accepted", "incomplete-receipt")
    finally:
        malformed_path.unlink(missing_ok=True)
    controls["incomplete-receipt"] = "rejected"
    missing = sorted(set(OBSERVED_REQUIRED_CONTROLS) - set(controls))
    reject(not missing, "observed-negative-controls", missing)
    scoped_controls = ("missing-remainder-assignment", "wrong-scope-contract",
                       "missing-inherited-pending-callback") if ACTIVE_SCOPE == "debugger-remainder" else ()
    missing = sorted(set(scoped_controls) - set(controls))
    reject(not missing, "observed-remainder-negative-controls", missing)
    return {"status": "passed", "historical_rows_fixture_only": True,
            "controls": {name: controls[name] for name in (*OBSERVED_REQUIRED_CONTROLS, *scoped_controls)}}


def self_test_remainder_artifact_controls() -> dict:
    """Exercise contained four-artifact reads without publishing a delivery pointer."""
    if DELIVERY_PATH.exists():
        artifact_target(DELIVERY_PATH)
    pointer_before = read_bytes(DELIVERY_PATH, "delivery-pointer-unavailable") if DELIVERY_PATH.exists() else None
    controls = {}
    with tempfile.TemporaryDirectory(prefix="remainder-scope-self-test-", dir=CHILD_DIR) as temporary:
        root = Path(temporary)
        generation_root = root / "GENERATION"
        generation_root.mkdir()
        generation_id = new_generation_id("a" * 40, "12345")
        generation_path = generation_root / generation_id
        generation_path.mkdir()
        artifact_records = {}
        for key, filename in GENERATION_ARTIFACTS.items():
            payload = f"mock-external-artifact:{key}".encode()
            artifact_path = generation_path / filename
            artifact_path.write_bytes(payload)
            artifact_records[key] = {
                "path": str(artifact_path.relative_to(ROOT)),
                "sha256": sha256(payload),
            }
        pointer = {
            "schema": GENERATION_POINTER_SCHEMA,
            "generation": str(generation_path.relative_to(ROOT)),
            "tested_head": "a" * 40,
            "ci_run_id": "12345",
            "artifacts": artifact_records,
        }
        _checked, paths = validate_generation_pointer_data(
            json.dumps(pointer, sort_keys=True).encode(), generation_root
        )
        reject(set(paths) == set(REMAINDER_GENERATION_ARTIFACTS)
               and {path.name for path in paths.values()} == set(GENERATION_ARTIFACTS.values()),
               "remainder-artifact-set", paths)
        controls["four-artifact-contained-pointer"] = "passed"

        mixed = copy.deepcopy(pointer)
        mixed["artifacts"]["observed"]["sha256"] = "0" * 64
        try:
            validate_generation_pointer_data(json.dumps(mixed, sort_keys=True).encode(), generation_root)
        except VerificationError:
            controls["mixed-generation-digest"] = "rejected"
        else:
            raise VerificationError("remainder-artifact-control-accepted", "mixed-generation-digest")

        escaped = copy.deepcopy(pointer)
        escaped["generation"] = str((generation_root / ".." / "outside").relative_to(ROOT))
        try:
            validate_generation_pointer_data(json.dumps(escaped, sort_keys=True).encode(), generation_root)
        except (VerificationError, ValueError):
            controls["escaped-generation-path"] = "rejected"
        else:
            raise VerificationError("remainder-artifact-control-accepted", "escaped-generation-path")

    pointer_after = read_bytes(DELIVERY_PATH, "delivery-pointer-unavailable") if DELIVERY_PATH.exists() else None
    reject(pointer_after == pointer_before, "self-test-published-delivery", str(DELIVERY_PATH))
    controls["self-test-did-not-publish"] = "passed"
    return {"status": "passed", "controls": controls}


def self_test_observed_for_scope(scope: str) -> dict:
    with scoped_delivery(scope):
        report = self_test_observed()
        if scope == "debugger-remainder":
            report["artifact_controls"] = self_test_remainder_artifact_controls()
            report["validation_controls"] = self_test_validation_limits()
            report["delivery_claim_controls"] = self_test_delivery_claim_block()
            report["scope"] = scope
        return report


def read_review_passes() -> int:
    artifact_target(REVIEW_PATH)
    raw = read_bytes(REVIEW_PATH, "review-record-unavailable").decode("utf-8", errors="replace")
    match = re.search(r"Review passes used:\s*(\d+)\s*/\s*2", raw)
    reject(match is not None, "review-accounting", "REVIEW.md must record Review passes used: N/2")
    count = int(match.group(1))
    reject(1 <= count <= 2, "review-cap", count)
    return count


def jsonl_bytes(rows: list[dict]) -> bytes:
    return b"".join(canon_bytes(row) + b"\n" for row in rows)


def atomic_write_bytes(path: Path, data: bytes, validator=None) -> None:
    path = artifact_target(path)
    fd, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", suffix=".tmp", dir=CHILD_DIR)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(data)
            stream.flush()
            os.fsync(stream.fileno())
        if validator:
            validator(temporary)
        os.replace(temporary, path)
        fsync_directory(path.parent)
    finally:
        if temporary.exists():
            temporary.unlink()


def summarize_receipt(path: Path, lane: str) -> dict:
    artifact_target(path)
    ownership, _adopt = load_ownership_context()
    file_hash, rows, body_hash = ownership.receipt_file(path, lane)
    meta = rows[0]
    footer = rows[-1]
    return {
        "lane": lane, "path": str(path.relative_to(ROOT)), "sha256": file_hash,
        "body_sha256": body_hash, "rows": len(rows), "footer_present": footer.get("kind") == "footer",
        "footer_sha256": footer.get("sha256"), "runtime": {"elixir": meta.get("elixir"), "otp": meta.get("otp")},
        "lock_sha256": meta.get("lock_sha256"),
    }


def observed_document(pr: dict, run: dict, jobs: dict, receipt_paths: dict[str, Path],
                      receipt_summaries: dict[str, dict], ownership, adopt, review_passes: int) -> list[dict]:
    meta = observed_meta(pr, run, jobs, receipt_summaries, ownership, adopt, review_passes)
    current = derive_observed_current(ownership, adopt, receipt_paths, receipt_summaries,
                                     pr["tested_head"], str(run["databaseId"]), pr["number"])
    history = parent_unadopted_rows(ownership, adopt) + adopt.materialize()
    document = [meta] + history + current
    validate_observed_for_scope(document, history, ownership.REQUIRED_CI_CHECKS,
                                pr["tested_head"], str(run["databaseId"]))
    return document


def derive_observed_current(ownership, adopt, receipt_paths: dict[str, Path],
                            receipt_summaries: dict[str, dict], tested_head: str,
                            ci_run_id: str, pr_number: int) -> list[dict]:
    """Derive only fresh debugger rows while preserving adopted rows as immutable input."""
    return fresh_namespace(ownership, adopt, receipt_paths, receipt_summaries,
                           tested_head, ci_run_id, pr_number)


def verify_observed(path: Path, pr: dict, run: dict, jobs: dict,
                    receipt_paths: dict[str, Path], receipt_summaries: dict[str, dict],
                    ownership, adopt, review_passes: int) -> dict:
    actual = parse_jsonl_gzip(path)
    expected = observed_document(pr, run, jobs, receipt_paths, receipt_summaries,
                                 ownership, adopt, review_passes)
    reject(actual == expected, "observed-derivation", "stored projection differs from independent live derivation")
    reject(sha256(path.read_bytes()) == sha256(gzip.compress(jsonl_bytes(expected), mtime=0)),
           "observed-compression", "stored projection does not use its canonical serialization")
    return {"status": "verified", "records": len(actual), "sha256": sha256(path.read_bytes())}


def validation_markdown(delivery: dict, source: dict, history: dict, controls: dict) -> str:
    pr = delivery["pr"]
    run = delivery["ci_run"]
    jobs = delivery["jobs"]
    checks = delivery["check_results"]
    merge_line = (
        f"- Merge verified in commit `{delivery['merge_commit']}`; no later phase has started."
        if delivery.get("status") == "merged"
        else "- No later phase has started. Merge is intentionally pending the user’s final approval."
    )
    lines = [
        f"# {OWNER} Validation",
        "",
        "## Exact-head delivery",
        "",
        f"- PR: [#{pr['number']}]({pr['url']}) (new child-slice PR; merged parent PR #30 is not reused because it contains only the parent phase).",
        f"- Tested code head: `{delivery['tested_head']}`.",
        f"- CI run: [{run['databaseId']}]({run['url']}) on `{run['headSha']}`; completed successfully.",
        f"- Core job: [{jobs['core']['id']}]({jobs['core']['url']}) — {jobs['core']['conclusion']}; floor job: [{jobs['floor']['id']}]({jobs['floor']['url']}) — {jobs['floor']['conclusion']}.",
        f"- Required checks: {', '.join(f'`{name}`={bucket}' for name, bucket in sorted(checks.items()))}.",
        "- Local exact-head receipts and observed projection are workspace artifacts. Committing them would change the SHA they certify; no artifact-only commit is made.",
        f"- Immutable evidence generation: `{delivery.get('artifact_generation', 'pending')}`; the top-level DELIVERY file is its atomic pointer.",
        "",
        "## Fresh receipt verification",
        "",
        f"- Source successor: `{delivery['source_archive_sha256']}`; source controls: {source['status']}.",
        f"- Historical and adopted authority: verified read-only; original ledger SHA `{delivery['historical_sha256']}`, adopted authority SHA `{delivery['authority_sha256']}`.",
        "- InstalledOtp.verify_receipt_files!/1 passed for both complete lane receipts.",
        f"- CI provenance controls: {controls['status']}; history negative controls: {len(history.get('history_controls') or [])} rejected.",
        "- Review use: " + str(delivery["review_passes"]) + "/2 ordinary passes.",
        "",
        "## Scope and ownership",
        "",
        "- This static slice binds the current graph receipt to exact lane/runtime/lock/source and current selected/remainder ownership. It does not establish runtime atom safety, full computed-dispatch proof, or SEC-01 completion.",
        f"- Selected settings and monitor roots: `{SELECTED_OWNER}`. Remaining debugger routes stay with `{REMAINDER_OWNER}`.",
        "- `.3.13` final installed-scope acceptance, `.4`, `.5`, parent verification debt, and SEC-01 remain with their existing downstream owners; SEC-01 remains pending for Phase 5.",
        merge_line,
        "",
    ]
    archived_red = delivery.get("red_capture_archive")
    if archived_red is not None:
        lines.extend([
            "## Preserved TDD RED capture",
            "",
            f"- Archived outside this generation at `{archived_red['path']}` with SHA-256 `{archived_red['sha256']}`; the RED payload is not copied into the final delivery generation.",
            "",
        ])
    return "\n".join(lines)


def artifact_fingerprints() -> dict:
    return {"history": verify_history(include_negative_controls=True),
            "source": verify_source(include_negative_controls=True)}


def validate_delivery_fingerprints(delivery: dict, pr: dict, run: dict, snapshot: dict, jobs: dict,
                                   ownership) -> None:
    checks = {check["name"]: check["bucket"] for check in snapshot["checks"]}
    expected_run = {key: run.get(key) for key in
                    ("databaseId", "headSha", "headBranch", "event", "workflowName", "status", "conclusion", "url", "createdAt")}
    expected_jobs = {
        lane: {"name": jobs[lane]["name"], "id": jobs[lane]["databaseId"],
               "url": jobs[lane].get("url") or run["url"].rstrip("/") + "/job/" + str(jobs[lane]["databaseId"]),
               "conclusion": jobs[lane]["conclusion"]}
        for lane in ("core", "floor")
    }
    expected_remaining = {"selected": SELECTED_OWNER, "remainder": REMAINDER_OWNER,
                          "final_installed_scope": PARENT_PHASE + ".13",
                          "later": ["01.1.1.3.1.4", "01.1.1.3.1.5"], "sec_01": "pending-for-phase-5"}
    adoption_bytes = read_bytes(ADOPTION_LEDGER, "adopted-delegation-unavailable")
    parent_bytes = read_bytes(ownership.OUTPUT, "historical-ledger-unavailable")
    partition_bytes = read_bytes(ADOPTION_PARTITION, "adoption-partition-unavailable")
    comparisons = {
        "tested_head": pr["tested_head"],
        "pr": {key: pr.get(key) for key in ("number", "url", "state", "headRefName", "baseRefName")},
        "ci_run": expected_run,
        "jobs": expected_jobs,
        "check_results": checks,
        "runtimes": SUPPORTED_RUNTIMES,
        "locks": lock_digests_from_archive(),
        "source_archive_sha256": SUCCESSOR_SHA256,
        "authority_sha256": sha256(adoption_bytes),
        "historical_sha256": sha256(parent_bytes),
        "partition_sha256": sha256(partition_bytes),
        "review_passes": read_review_passes(),
        "remaining_owners": expected_remaining,
    }
    for key, expected in comparisons.items():
        actual = delivery.get(key)
        reject(actual == expected, "delivery-fingerprint", {"field": key, "expected": expected, "actual": actual})
    reject(delivery.get("source_archive_sha256") == SUCCESSOR_SHA256,
           "delivery-fingerprint", {"field": "source_archive_sha256", "actual": delivery.get("source_archive_sha256")})
    reject(delivery.get("artifact_head") is None and "not committed" in delivery.get("artifact_relationship", ""),
           "delivery-artifact-relationship", delivery.get("artifact_relationship"))
    if delivery.get("status") == "prepared-before-merge":
        reject(delivery.get("merge_commit") is None, "delivery-merge-state", delivery.get("merge_commit"))


def installed_receipt_fingerprint(receipt_summaries: dict[str, dict]) -> dict:
    reject(set(receipt_summaries) == {"core", "floor"},
           "installed-receipt-lanes", sorted(receipt_summaries))
    fields = ("sha256", "body_sha256", "rows", "footer_present", "footer_sha256", "runtime", "lock_sha256")
    lanes = {}
    for lane in ("core", "floor"):
        summary = receipt_summaries[lane]
        reject(all(field in summary for field in fields),
               "installed-receipt-summary", {"lane": lane, "fields": sorted(summary)})
        lanes[lane] = {field: summary[field] for field in fields}
    return {"status": "passed", "lanes": lanes}


def delivery_verification_fingerprint(receipt_summaries: dict[str, dict], source: dict,
                                      history: dict, observed_controls: dict) -> dict:
    return {
        "installed_otp": installed_receipt_fingerprint(receipt_summaries),
        "source": source,
        "history": history,
        "observed_controls": observed_controls,
    }


def validate_delivery_verification(delivery: dict, receipt_summaries: dict[str, dict], source: dict,
                                   history: dict, observed_controls: dict,
                                   merged_pr: dict | None = None) -> dict:
    expected = delivery_verification_fingerprint(receipt_summaries, source, history, observed_controls)
    if merged_pr is not None:
        expected["merged_pr"] = merged_pr
    actual = delivery.get("verification")
    reject(isinstance(actual, dict) and set(actual) == set(expected),
           "delivery-verification-shape", sorted(actual) if isinstance(actual, dict) else actual)
    for field, value in expected.items():
        reject(actual.get(field) == value,
               "delivery-verification-fingerprint", {"field": field, "expected": value, "actual": actual.get(field)})
    return expected


def self_test_delivery_verification() -> dict:
    receipt_summaries = {
        lane: {"path": f"some/path/{lane}.jsonl", "sha256": lane * 64, "body_sha256": (lane + "b") * 32,
               "rows": 4, "footer_present": True, "footer_sha256": (lane + "c") * 32,
               "runtime": SUPPORTED_RUNTIMES[lane], "lock_sha256": (lane + "d") * 32}
        for lane in ("core", "floor")
    }
    source = {"status": "verified", "successor_sha256": SUCCESSOR_SHA256, "negative_controls": ["rejected"]}
    history = {"status": "verified", "parent_ledger_sha256": "a" * 64, "history_controls": ["rejected"]}
    observed_controls = {"status": "passed", "controls": {"wrong-head": "rejected"}}
    expected = delivery_verification_fingerprint(receipt_summaries, source, history, observed_controls)
    delivery = {"verification": expected}
    validate_delivery_verification(delivery, receipt_summaries, source, history, observed_controls)

    controls = {}
    for field in expected:
        altered = copy.deepcopy(delivery)
        altered["verification"][field] = None
        try:
            validate_delivery_verification(altered, receipt_summaries, source, history, observed_controls)
        except VerificationError as error:
            reject(error.reason == "delivery-verification-fingerprint",
                   "delivery-verification-control", {"field": field, "error": error.reason})
            controls[field] = "rejected"
        else:
            raise VerificationError("delivery-verification-control-accepted", field)

    merged_pr = {"url": "https://example.invalid/pull/1", "head": "a" * 40,
                 "merge_commit": "b" * 40, "run_id": "12345",
                 "installed_otp": expected["installed_otp"]}
    merged_delivery = {"verification": {**expected, "merged_pr": merged_pr}}
    validate_delivery_verification(merged_delivery, receipt_summaries, source, history,
                                   observed_controls, merged_pr)
    altered_merged = copy.deepcopy(merged_delivery)
    altered_merged["verification"]["merged_pr"]["merge_commit"] = "c" * 40
    try:
        validate_delivery_verification(altered_merged, receipt_summaries, source, history,
                                       observed_controls, merged_pr)
    except VerificationError as error:
        reject(error.reason == "delivery-verification-fingerprint",
               "delivery-verification-merged-control", error.reason)
        controls["merged_pr"] = "rejected"
    else:
        raise VerificationError("delivery-verification-control-accepted", "merged_pr")

    altered_path = copy.deepcopy(receipt_summaries)
    altered_path["core"]["path"] = "another/generation/core.jsonl"
    reject(installed_receipt_fingerprint(altered_path) == installed_receipt_fingerprint(receipt_summaries),
           "delivery-verification-path-independence", "receipt fingerprint must not depend on generation paths")
    controls["path-independent-installed-receipts"] = "passed"
    return {"status": "passed", "controls": controls}


def red_capture_archive_metadata(path_text: str | None) -> dict | None:
    if path_text is None:
        return None
    path = Path(path_text)
    expected_parent = Path("/private/tmp")
    reject(path.is_absolute() and path.parent == expected_parent,
           "red-capture-archive-path", str(path))
    cursor = path
    while cursor != Path("/"):
        reject(not cursor.is_symlink(), "red-capture-archive-symlink", str(cursor))
        cursor = cursor.parent
    reject(path.is_file(), "red-capture-archive-unavailable", str(path))
    payload = path.read_bytes()
    return {"path": str(path), "sha256": sha256(payload), "included": False}


def collect_ci(red_capture_archive_path: str | None = None) -> dict:
    check_artifact_paths()
    ownership, adopt = load_ownership_context()
    pr = current_pr(ownership)
    run, snapshot, jobs = current_run(ownership, pr)
    review_passes = read_review_passes()
    red_capture_archive = red_capture_archive_metadata(red_capture_archive_path)

    generation_id = new_generation_id(pr["tested_head"], str(run["databaseId"]))
    artifact_path_map = generation_artifact_path_map(generation_id)
    artifact_generation = str((GENERATION_ROOT / generation_id).relative_to(ROOT))
    receipt_summaries = {}
    with tempfile.TemporaryDirectory(prefix="collect-ci-", dir=CHILD_DIR) as temporary_dir:
        staged_paths = {lane: Path(temporary_dir) / f"{lane}.jsonl" for lane in ("core", "floor")}
        for lane in ("core", "floor"):
            extract_job_receipt(str(run["databaseId"]), jobs[lane], lane, staged_paths[lane])
            receipt_summaries[lane] = summarize_receipt(staged_paths[lane], lane)
            receipt_key = f"inventory_{lane}"
            receipt_summaries[lane]["path"] = artifact_path_map[receipt_key]
        verify_installed_receipts([staged_paths["core"], staged_paths["floor"]])
        fingerprints = artifact_fingerprints()
        source, history = fingerprints["source"], fingerprints["history"]
        observed_controls = self_test_observed()
        document = observed_document(pr, run, jobs, staged_paths, receipt_summaries,
                                     ownership, adopt, review_passes)
        observed_data = gzip.compress(jsonl_bytes(document), mtime=0)
        staged_inventory_bytes = {lane: staged_paths[lane].read_bytes() for lane in ("core", "floor")}
    meta = document[0]
    delivery = {
        "schema": DELIVERY_SCHEMA, "status": "prepared-before-merge",
        "repository": "szTheory/fablebook", "pr": {k: pr.get(k) for k in ("number", "url", "state", "headRefName", "baseRefName")},
        "tested_head": pr["tested_head"], "artifact_head": None,
        "artifact_relationship": "local-evidence-for-exact-tested-code-head; not committed to avoid invalidating receipt provenance",
        "artifact_generation": artifact_generation, "artifact_paths": artifact_path_map,
        "ci_run": {k: run.get(k) for k in ("databaseId", "headSha", "headBranch", "event", "workflowName", "status", "conclusion", "url", "createdAt")},
        "jobs": meta["jobs"], "check_results": {check["name"]: check["bucket"] for check in snapshot["checks"]},
        "runtimes": SUPPORTED_RUNTIMES, "locks": meta["locks"],
        "source_archive_sha256": SUCCESSOR_SHA256,
        "receipt_summaries": receipt_summaries,
        "inventory_sha256": {lane: sha256(staged_inventory_bytes[lane]) for lane in ("core", "floor")},
        "observed_sha256": sha256(observed_data), "authority_sha256": meta["authority_sha256"],
        "historical_sha256": meta["historical_sha256"], "partition_sha256": meta["partition_sha256"],
        "review_passes": review_passes, "merge_commit": None,
        "red_capture_archive": red_capture_archive,
        "verification": delivery_verification_fingerprint(
            receipt_summaries, source, history, observed_controls
        ),
        "remaining_owners": {"selected": SELECTED_OWNER, "remainder": REMAINDER_OWNER,
                              "final_installed_scope": PARENT_PHASE + ".13", "later": ["01.1.1.3.1.4", "01.1.1.3.1.5"],
                              "sec_01": "pending-for-phase-5"},
    }
    if ACTIVE_SCOPE == "debugger-remainder":
        delivery["scope"] = ACTIVE_SCOPE
    validation = validation_markdown(delivery, source, history, observed_controls).encode()
    artifact_data = {
        "inventory_core": staged_inventory_bytes["core"],
        "inventory_floor": staged_inventory_bytes["floor"],
        "observed": observed_data,
        "delivery": json.dumps(delivery, sort_keys=True, indent=2).encode() + b"\n",
        "validation": validation,
    }
    artifact_data = {key: data for key, data in artifact_data.items() if key in GENERATION_ARTIFACTS}

    def validate_staged_generation(staging: Path) -> None:
        staged_inventory_paths = {}
        for lane in ("core", "floor"):
            key = f"inventory_{lane}"
            path = staging / GENERATION_ARTIFACTS[key]
            actual = summarize_receipt(path, lane)
            actual["path"] = artifact_path_map[key]
            reject(actual == receipt_summaries[lane], "staged-inventory-summary", lane)
            staged_inventory_paths[lane] = path

        staged_observed = staging / GENERATION_ARTIFACTS["observed"]
        staged_document = parse_jsonl_gzip(staged_observed)
        expected_history = parent_unadopted_rows(ownership, adopt) + adopt.materialize()
        validate_observed_for_scope(staged_document, expected_history, ownership.REQUIRED_CI_CHECKS,
                                    pr["tested_head"], str(run["databaseId"]))
        staged_delivery = json.loads((staging / GENERATION_ARTIFACTS["delivery"]).read_text())
        reject(staged_delivery == delivery, "staged-delivery-mismatch", str(staging))

    pointer = publish_generation(
        artifact_data,
        generation_id,
        {"tested_head": pr["tested_head"], "ci_run_id": str(run["databaseId"])},
        validator=validate_staged_generation,
    )
    return {"status": delivery["status"], "pr": pr["number"], "tested_head": pr["tested_head"],
            "ci_run_id": run["databaseId"], "jobs": {lane: jobs[lane]["conclusion"] for lane in ("core", "floor")},
            "inventories": {lane: receipt_summaries[lane]["rows"] for lane in ("core", "floor")},
            "observed_records": len(document), "generation": pointer["generation"],
            "artifacts": [str(DELIVERY_PATH.relative_to(ROOT)), *[item["path"] for item in pointer["artifacts"].values()]]}


def parse_jsonl_gzip(path: Path) -> list[dict]:
    artifact_target(path)
    try:
        payload = gzip.decompress(path.read_bytes())
        return [json.loads(line) for line in payload.splitlines()]
    except (OSError, EOFError, gzip.BadGzipFile, json.JSONDecodeError) as error:
        raise VerificationError("observed-format", str(error)) from error


def verify_ci(negative_controls: bool = False) -> dict:
    check_artifact_paths()
    ownership, adopt = load_ownership_context()
    delivery, artifact_paths, pointer = load_current_delivery()
    reject(delivery.get("schema") == DELIVERY_SCHEMA
           and delivery.get("status") in {"prepared-before-merge", "merged"}, "delivery-format", delivery.get("schema"))
    if ACTIVE_SCOPE == "debugger-remainder":
        reject(delivery.get("scope") == ACTIVE_SCOPE, "delivery-scope", delivery.get("scope"))
    inventory_paths = {lane: artifact_paths[f"inventory_{lane}"] for lane in ("core", "floor")}
    observed_path = artifact_paths["observed"]
    tested_head = delivery.get("tested_head")
    pr = current_pr(ownership, tested_head)
    reject(pr["number"] == delivery["pr"]["number"], "delivery-pr", delivery["pr"])
    run, snapshot, jobs = current_run(ownership, pr, str(delivery["ci_run"]["databaseId"]))
    validate_delivery_fingerprints(delivery, pr, run, snapshot, jobs, ownership)
    receipt_summaries = {}
    for lane in ("core", "floor"):
        summary = summarize_receipt(inventory_paths[lane], lane)
        reject(summary == delivery["receipt_summaries"][lane], "inventory-summary", lane)
        receipt_summaries[lane] = summary
    verify_installed_receipts([inventory_paths["core"], inventory_paths["floor"]])
    fresh_logs = {}
    with tempfile.TemporaryDirectory(prefix="verify-ci-", dir=CHILD_DIR) as temporary_dir:
        for lane in ("core", "floor"):
            path = Path(temporary_dir) / f"{lane}.jsonl"
            extract_job_receipt(str(run["databaseId"]), jobs[lane], lane, path)
            fresh_logs[lane] = sha256(path.read_bytes())
            reject(fresh_logs[lane] == delivery["inventory_sha256"][lane], "live-log-inventory-mismatch", lane)
    observed = verify_observed(observed_path, pr, run, jobs, inventory_paths,
                               delivery["receipt_summaries"], ownership, adopt, delivery["review_passes"])
    observed_hash = sha256(observed_path.read_bytes())
    reject(observed_hash == delivery["observed_sha256"], "observed-digest", {"expected": delivery["observed_sha256"], "actual": observed_hash})
    source = verify_source(include_negative_controls=True)
    history = verify_history(include_negative_controls=True)
    observed_controls = self_test_observed()
    validate_delivery_verification(delivery, receipt_summaries, source, history, observed_controls)
    controls = (
        {"observed": observed_controls, "delivery_verification": self_test_delivery_verification()}
        if negative_controls else None
    )
    return {"status": "verified", "pr": pr["number"], "tested_head": tested_head,
            "run_id": run["databaseId"], "jobs": {lane: jobs[lane]["conclusion"] for lane in ("core", "floor")},
            "checks": {check["name"]: check["bucket"] for check in snapshot["checks"]},
            "installed_otp": "passed", "source": source["status"], "history": history["status"],
            "observed_records": observed["records"], "generation": pointer["generation"],
            "negative_controls": controls}


def verify_merged() -> dict:
    check_artifact_paths()
    ownership, adopt = load_ownership_context()
    delivery, artifact_paths, pointer = load_current_delivery()
    if ACTIVE_SCOPE == "debugger-remainder":
        reject(delivery.get("scope") == ACTIVE_SCOPE, "merged-delivery-scope", delivery.get("scope"))
    inventory_paths = {lane: artifact_paths[f"inventory_{lane}"] for lane in ("core", "floor")}
    observed_path = artifact_paths["observed"]
    pr_number = delivery.get("pr", {}).get("number")
    reject(isinstance(pr_number, int) and pr_number > 0, "delivery-pr", pr_number)
    pr = ownership.gh_json(["pr", "view", str(pr_number), "--json", "number,url,state,headRefOid,headRefName,baseRefName,mergeCommit"])
    reject(pr.get("state") == "MERGED" and pr.get("headRefOid") == delivery.get("tested_head"),
           "merged-pr-head", pr)
    run, snapshot, jobs = current_run(ownership, {**pr, "tested_head": delivery["tested_head"]}, str(delivery["ci_run"]["databaseId"]))
    delivery["pr"]["state"] = pr.get("state")
    validate_delivery_fingerprints(delivery, {**pr, "tested_head": delivery["tested_head"]}, run, snapshot, jobs, ownership)
    reject(all(jobs[lane].get("conclusion") == "success" for lane in ("core", "floor")), "merged-required-jobs", jobs)
    receipt_summaries = {lane: summarize_receipt(inventory_paths[lane], lane) for lane in ("core", "floor")}
    reject(receipt_summaries == delivery.get("receipt_summaries"), "merged-receipts", "receipt summaries differ")
    verify_installed_receipts([inventory_paths["core"], inventory_paths["floor"]])
    with tempfile.TemporaryDirectory(prefix="verify-merged-", dir=CHILD_DIR) as temporary_dir:
        for lane in ("core", "floor"):
            path = Path(temporary_dir) / f"{lane}.jsonl"
            extract_job_receipt(str(run["databaseId"]), jobs[lane], lane, path)
            reject(sha256(path.read_bytes()) == delivery["inventory_sha256"][lane],
                   "merged-live-log-inventory-mismatch", lane)
    merged_pr = {**pr, "tested_head": delivery["tested_head"]}
    observed = parse_jsonl_gzip(observed_path)
    expected = observed_document(merged_pr, run, jobs, inventory_paths, receipt_summaries,
                                 ownership, adopt, delivery["review_passes"])
    reject(observed == expected and sha256(observed_path.read_bytes()) == delivery.get("observed_sha256"),
           "merged-observed", "observed projection differs from the final exact-head derivation")
    merge_commit = pr.get("mergeCommit", {}).get("oid")
    reject(GIT_SHA_RE.fullmatch(merge_commit or "") is not None, "merge-commit", merge_commit)
    source = verify_source(include_negative_controls=True)
    history = verify_history(include_negative_controls=True)
    observed_controls = self_test_observed()
    delivery["status"] = "merged"
    delivery["merge_commit"] = merge_commit
    delivery["pr"]["state"] = "MERGED"
    merged_verification = {
        "url": pr.get("url"), "head": pr.get("headRefOid"), "merge_commit": merge_commit,
        "run_id": run["databaseId"],
        "installed_otp": installed_receipt_fingerprint(receipt_summaries),
    }
    delivery["verification"]["merged_pr"] = merged_verification
    validate_delivery_verification(delivery, receipt_summaries, source, history,
                                   observed_controls, merged_verification)
    generation_id = new_generation_id(delivery["tested_head"], str(run["databaseId"]))
    artifact_path_map = generation_artifact_path_map(generation_id)
    artifact_generation = str((GENERATION_ROOT / generation_id).relative_to(ROOT))
    delivery["artifact_generation"] = artifact_generation
    delivery["artifact_paths"] = artifact_path_map
    for lane in ("core", "floor"):
        delivery["receipt_summaries"][lane]["path"] = artifact_path_map[f"inventory_{lane}"]

    merged_observed_document = observed_document(merged_pr, run, jobs, inventory_paths,
                                                 delivery["receipt_summaries"], ownership, adopt,
                                                 delivery["review_passes"])
    merged_observed_data = gzip.compress(jsonl_bytes(merged_observed_document), mtime=0)
    delivery["observed_sha256"] = sha256(merged_observed_data)
    validation = validation_markdown(delivery, source, history, observed_controls).encode()
    artifact_data = {
        "inventory_core": inventory_paths["core"].read_bytes(),
        "inventory_floor": inventory_paths["floor"].read_bytes(),
        "observed": merged_observed_data,
        "delivery": json.dumps(delivery, sort_keys=True, indent=2).encode() + b"\n",
        "validation": validation,
    }
    artifact_data = {key: data for key, data in artifact_data.items() if key in GENERATION_ARTIFACTS}

    def validate_merged_generation(staging: Path) -> None:
        for lane in ("core", "floor"):
            key = f"inventory_{lane}"
            actual = summarize_receipt(staging / GENERATION_ARTIFACTS[key], lane)
            actual["path"] = artifact_path_map[key]
            reject(actual == delivery["receipt_summaries"][lane], "merged-staged-inventory", lane)
        staged_observed = parse_jsonl_gzip(staging / GENERATION_ARTIFACTS["observed"])
        reject(staged_observed == merged_observed_document,
               "merged-staged-observed", "staged projection differs")
        staged_delivery = json.loads((staging / GENERATION_ARTIFACTS["delivery"]).read_text())
        reject(staged_delivery == delivery, "merged-staged-delivery", str(staging))

    publish_generation(
        artifact_data,
        generation_id,
        {"tested_head": delivery["tested_head"], "ci_run_id": str(run["databaseId"])},
        validator=validate_merged_generation,
    )
    return {"status": "merged-verified", "pr": pr_number, "tested_head": delivery["tested_head"],
            "merge_commit": merge_commit, "run_id": run["databaseId"],
            "jobs": {lane: jobs[lane]["conclusion"] for lane in ("core", "floor")},
            "generation": artifact_generation, "previous_generation": pointer["generation"]}


def validate_validation_limits(validation: str) -> dict:
    required = (
        "- Runtime safety: not established; source, BEAM and receipt evidence is static only.",
        "- Installed-wide acceptance: pending for Plan 01.1.1.3.1.3.",
        "- SEC-01: pending for Phase 5.",
    )
    for statement in required:
        reject(statement in validation, "remainder-validation-limit", statement)
    allowed = set(required)
    protected = re.compile(
        r"\bsec[\s_-]*0?1\b|\binstalled[\s-]*wide\b|"
        r"\bsafety\b|\bsafe\b|"
        r"\bruntime\b[^\n]{0,80}\b(?:complete|completed|pass|passed|verify|verified|"
        r"accept|accepted|close|closed|prove|proved|proven|establish|established|"
        r"fulfill|fulfilled|confirm|confirmed|finish|finished|done|achieve|achieved|"
        r"clear|cleared|satisfy|satisfied|meet|met|succeed|succeeded|approve|approved|"
        r"green|successful|assure|assured|resolve|resolved)\b|"
        r"\b(?:complete|completed|pass|passed|verify|verified|accept|accepted|close|closed|"
        r"prove|proved|proven|establish|established|fulfill|fulfilled|confirm|confirmed|"
        r"finish|finished|done|achieve|achieved|clear|cleared|satisfy|satisfied|meet|met|"
        r"succeed|succeeded|approve|approved|green|successful|assure|assured|resolve|resolved)\b"
        r"[^\n]{0,80}\bruntime\b", re.I
    )
    for line_number, line in enumerate(validation.splitlines(), 1):
        if protected.search(line):
            reject(line in allowed,
                   "remainder-validation-claim-line",
                   {"line": line_number, "text": line.strip()})
    return {"status": "passed", "required_limits": len(required), "false_completion_claims": 0}


def self_test_validation_limits() -> dict:
    limits = (
        "- Runtime safety: not established; source, BEAM and receipt evidence is static only.\n"
        "- Installed-wide acceptance: pending for Plan 01.1.1.3.1.3.\n"
        "- SEC-01: pending for Phase 5.\n"
    )
    validate_validation_limits(limits)
    controls = {"explicit-pending-limits": "passed"}
    for name, claim in (
        ("sec01-complete", "SEC-01 complete"),
        ("sec01-validated", "SEC 01 has been validated"),
        ("sec01-fulfilled", "SEC_01 is fulfilled"),
        ("installed-wide-accepted", "Installed-wide acceptance passed"),
        ("installed-wide-approved", "Installed wide acceptance is approved"),
        ("runtime-safety-established", "Runtime safety verified"),
        ("runtime-safety-confirmed", "Runtime safety is confirmed"),
        ("runtime-safety-assured", "Runtime safety is assured"),
        ("runtime-safe", "Runtime is safe"),
        ("safe-runtime", "The runtime is safe"),
        ("installed-wide-done", "Installed-wide acceptance is done"),
        ("sec01-satisfied", "SEC-01 is satisfied"),
        ("sec01-complete-with-no-blockers", "SEC-01 has no outstanding blockers and is complete"),
        ("sec01-complete-next-line", "SEC-01\ncomplete"),
        ("installed-wide-accepted-next-line", "Installed-wide acceptance\npassed"),
        ("runtime-safety-verified-next-line", "Runtime safety\nverified"),
    ):
        try:
            validate_validation_limits(limits + "\n" + claim + "\n")
        except VerificationError as error:
            reject(error.reason == "remainder-validation-claim-line",
                   "remainder-overclaim-control", {"name": name, "reason": error.reason})
            controls[name] = "rejected"
        else:
            raise VerificationError("remainder-overclaim-control-accepted", name)
    validate_validation_limits(limits + "\n- Static-only evidence does not establish execution behavior.\n")
    controls["unrelated-static-only-wording"] = "passed"
    return {"status": "passed", "controls": controls}


def validation_delivery_claims(delivery: dict | None = None, pointer: dict | None = None) -> dict:
    if delivery is None or pointer is None:
        return {"status": "pending"}
    return {
        "status": delivery.get("status"),
        "scope": delivery.get("scope"),
        "pr": {key: delivery.get("pr", {}).get(key)
               for key in ("number", "url", "state", "headRefName", "baseRefName")},
        "tested_head": delivery.get("tested_head"),
        "ci_run": {key: delivery.get("ci_run", {}).get(key)
                   for key in ("databaseId", "headSha", "url", "status", "conclusion")},
        "jobs": delivery.get("jobs"),
        "check_results": delivery.get("check_results"),
        "merge_commit": delivery.get("merge_commit"),
        "generation": pointer.get("generation"),
        "delivery_pointer": str(DELIVERY_PATH.relative_to(ROOT)),
        "delivery_pointer_sha256": sha256(read_bytes(DELIVERY_PATH, "delivery-pointer-unavailable")),
        "artifacts": {key: record.get("path") for key, record in pointer.get("artifacts", {}).items()},
    }


def validate_delivery_claim_block(validation: str, expected: dict) -> None:
    marker_start = "<!-- remainder-delivery-claims:start -->"
    marker_end = "<!-- remainder-delivery-claims:end -->"
    reject(validation.count(marker_start) == 1 and validation.count(marker_end) == 1,
           "remainder-delivery-claim-block-count", "exactly one delivery claims block is allowed")
    matched = re.search(re.escape(marker_start) + r"\s*```json\s*(.*?)\s*```\s*"
                        + re.escape(marker_end), validation, re.S)
    reject(matched is not None, "remainder-delivery-claims", "VALIDATION.md must carry the machine-checked delivery claims block")
    try:
        actual = json.loads(matched.group(1))
    except (json.JSONDecodeError, AttributeError) as error:
        raise VerificationError("remainder-delivery-claims", str(error)) from error
    reject(actual == expected, "remainder-delivery-claim-mismatch",
           {"expected": expected, "actual": actual})


def self_test_delivery_claim_block() -> dict:
    marker_start = "<!-- remainder-delivery-claims:start -->"
    marker_end = "<!-- remainder-delivery-claims:end -->"
    block = f"{marker_start}\n```json\n{{\"status\":\"pending\"}}\n```\n{marker_end}"
    validate_delivery_claim_block(block, {"status": "pending"})
    controls = {"current-delivery-claims-match": "passed"}
    for name, altered in (
        ("duplicate-delivery-claim-block", block + "\n" + block),
        ("unsupported-delivery-claim", block.replace("pending", "merged")),
    ):
        try:
            validate_delivery_claim_block(altered, {"status": "pending"})
        except VerificationError:
            controls[name] = "rejected"
        else:
            raise VerificationError("remainder-delivery-control-accepted", name)
    return {"status": "passed", "controls": controls}


def remainder_scope_descriptor(ownership, adopt) -> dict:
    rows = adopt.materialize()
    remainder_modules = {}
    selected_modules = {}
    selected_roots = {}
    pending_branches = {}
    for lane in ("core", "floor"):
        remainder_modules[lane] = sorted([
            ownership.typed_identity("module", row) for row in rows
            if row.get("t") == "module" and row.get("lane") == lane and row.get("app") == "debugger"
            and row.get("owner") == REMAINDER_OWNER
        ], key=canon_bytes)
        selected_modules[lane] = sorted([
            ownership.typed_identity("module", row) for row in rows
            if row.get("t") == "module" and row.get("lane") == lane and row.get("app") == "debugger"
            and row.get("owner") == SELECTED_OWNER
        ], key=canon_bytes)
        selected_roots[lane] = sorted([
            ownership.typed_identity("root", row) for row in rows
            if row.get("t") == "root" and row.get("lane") == lane and row.get("app") == "debugger"
            and row.get("owner") == SELECTED_OWNER
        ], key=canon_bytes)
        pending_branches[lane] = [
            {key: row.get(key) for key in ("t", "lane", "module", "function", "arity", "owner", "completion")}
            for row in rows if row.get("t") == "source_branch" and row.get("lane") == lane
            and row.get("module") == "dbg_icmd" and row.get("function") == "break_p"
            and row.get("arity") == 4
        ]

    for lane in ("core", "floor"):
        reject(len(remainder_modules[lane]) == 20 and len(selected_modules[lane]) == 1
               and len(selected_roots[lane]) == 3,
               "remainder-scope-owner-counts", {"lane": lane,
                   "remainder_modules": len(remainder_modules[lane]),
                   "selected_modules": len(selected_modules[lane]),
                   "selected_roots": len(selected_roots[lane])})
        reject(selected_modules[lane][0].get("module") == SELECTED_MODULE
               and {row.get("function") for row in selected_roots[lane]}
               == {"start", "load_settings", "load_settings2"},
               "remainder-scope-selected-identities", lane)
        reject(len(pending_branches[lane]) == 1
               and pending_branches[lane][0].get("owner") == SELECTED_OWNER
               and pending_branches[lane][0].get("completion") == "pending",
               "remainder-scope-pending-branch", {"lane": lane, "rows": pending_branches[lane]})

    report_files = {
        "source_audit": REMAINDER_SOURCE_AUDIT_PATH,
        "audit": REMAINDER_AUDIT_PATH,
        "review": REVIEW_PATH,
        "security": REMAINDER_SECURITY_PATH,
    }
    report_hashes = {}
    for name, path in report_files.items():
        artifact_target(path)
        report_hashes[name] = sha256(read_bytes(path, "remainder-report-unavailable"))

    authority = read_bytes(ADOPTION_LEDGER, "adopted-delegation-unavailable")
    historical = read_bytes(ownership.OUTPUT, "historical-ledger-unavailable")
    partition = read_bytes(ADOPTION_PARTITION, "adoption-partition-unavailable")
    verifier = read_bytes(Path(__file__), "scoped-verifier-unavailable")
    helper = read_bytes(ROOT / "test/support/debugger_settings.ex", "remainder-helper-unavailable")
    contract_test = read_bytes(ROOT / "test/contract/tier_sweep_test.exs", "remainder-test-unavailable")
    return {
        "scope": "debugger-remainder",
        "contract": REMAINDER_SCOPE_CONTRACT,
        "source_archive_sha256": SUCCESSOR_SHA256,
        "historical_sha256": sha256(historical),
        "authority_sha256": sha256(authority),
        "partition_sha256": sha256(partition),
        "report_sha256": report_hashes,
        "verifier_sha256": sha256(verifier),
        "helper_sha256": sha256(helper),
        "contract_test_sha256": sha256(contract_test),
        "review_passes": read_review_passes(),
        "required_lanes": SUPPORTED_RUNTIMES,
        "current_owner_counts": {
            lane: {
                "remainder_modules": len(remainder_modules[lane]),
                "remainder_module_identities_sha256": sha256(canon_bytes(remainder_modules[lane])),
                "selected_modules": len(selected_modules[lane]),
                "selected_module_identities_sha256": sha256(canon_bytes(selected_modules[lane])),
                "selected_roots": len(selected_roots[lane]),
                "selected_root_identities_sha256": sha256(canon_bytes(selected_roots[lane])),
                "inherited_pending_source_branches": pending_branches[lane],
            }
            for lane in ("core", "floor")
        },
        "receipt_contract": {
            "test": "debugger_remainder_receipt",
            "helper": "DebuggerSettings.assert_remainder_receipt!/4",
            "graph_input": "ctx.graph.receipt_lines",
        },
    }


def verify_scope(scope: str) -> dict:
    reject(scope == "debugger-remainder", "verify-scope-unsupported", scope)
    with scoped_delivery(scope):
        for path in (REMAINDER_SOURCE_AUDIT_PATH, REMAINDER_AUDIT_PATH,
                     REMAINDER_REVIEW_PATH, REMAINDER_SECURITY_PATH, REMAINDER_VALIDATION_PATH):
            artifact_target(path)
        ownership, adopt = load_ownership_context()
        source = verify_source(include_negative_controls=True)
        history = verify_history(include_negative_controls=True)
        support = read_bytes(ROOT / "test/support/debugger_settings.ex", "remainder-helper-unavailable").decode()
        contract = read_bytes(ROOT / "test/contract/tier_sweep_test.exs", "remainder-test-unavailable").decode()
        reject("def assert_remainder_receipt!" in support and "assert_remainder_inventory!" in support,
               "remainder-helper-contract", "receipt helper does not call the full inventory assertion")
        reject("ctx.graph.receipt_lines" in contract and "debugger_remainder_receipt" in contract,
               "remainder-test-contract", "real current graph receipt selector is missing")

        documents = {
            "source_audit": read_bytes(REMAINDER_SOURCE_AUDIT_PATH, "source-audit-unavailable").decode(),
            "audit": read_bytes(REMAINDER_AUDIT_PATH, "remainder-audit-unavailable").decode(),
            "review": read_bytes(REMAINDER_REVIEW_PATH, "review-record-unavailable").decode(),
            "security": read_bytes(REMAINDER_SECURITY_PATH, "security-record-unavailable").decode(),
            "validation": read_bytes(REMAINDER_VALIDATION_PATH, "validation-record-unavailable").decode(),
        }
        validation_limits = validate_validation_limits(documents["validation"])
        validation_controls = self_test_validation_limits()
        private_path = re.compile(r"(?:/Users/|/home/)[^\s`]*")
        email = re.compile(r"\b[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}\b")
        for name, content in documents.items():
            reject(private_path.search(content) is None and email.search(content) is None,
                   "remainder-report-privacy", name)
        for token in ("dbg_icmd:break_p/4", "dbg_wx_mon:start/2",
                      "dbg_wx_mon:load_settings/2", "dbg_wx_mon:load_settings2/2",
                      "callback", "interpreter", "monitor", "trace", "static", "SEC-01"):
            reject(token.casefold() in documents["audit"].casefold(),
                   "remainder-audit-claim", token)
        threat_rows = {
            threat: next((line for line in documents["security"].splitlines() if threat in line), "")
            for threat in ("T-01.1.1.3.1.2-13", "T-01.1.1.3.1.2-14", "T-01.1.1.3.1.2-15",
                           "T-01.1.1.3.1.2-16", "T-01.1.1.3.1.2-SC")
        }
        for threat, line in threat_rows.items():
            reject("mitigated" in line.casefold(), "remainder-security-threat", {"threat": threat, "row": line})
        reject("mitigated" in documents["security"].casefold()
               and "unmitigated high findings: 0" in documents["security"].casefold(),
               "remainder-security-status", "high threat dispositions are incomplete")
        reject("Review passes used:" in documents["review"], "remainder-review-accounting", "missing review cap")
        reject(read_review_passes() <= 2, "remainder-review-cap", read_review_passes())
        for document in ("audit", "security"):
            content = documents[document].casefold()
            for limit in ("runtime safety", "installed-wide", "sec-01"):
                reject(limit in content, "remainder-scope-limits", {"document": document, "limit": limit})

        marker_start = "<!-- remainder-scope-descriptor:start -->"
        marker_end = "<!-- remainder-scope-descriptor:end -->"
        reject(documents["validation"].count(marker_start) == 1
               and documents["validation"].count(marker_end) == 1,
               "remainder-scope-descriptor-count", "exactly one scope descriptor is allowed")
        matched = re.search(re.escape(marker_start) + r"\s*```json\s*(.*?)\s*```\s*"
                            + re.escape(marker_end), documents["validation"], re.S)
        reject(matched is not None, "remainder-scope-descriptor", "VALIDATION.md must carry the machine-checked JSON descriptor")
        try:
            actual_descriptor = json.loads(matched.group(1))
        except (json.JSONDecodeError, AttributeError) as error:
            raise VerificationError("remainder-scope-descriptor", str(error)) from error
        expected_descriptor = remainder_scope_descriptor(ownership, adopt)
        reject(actual_descriptor == expected_descriptor, "remainder-scope-descriptor-mismatch",
               {"expected": expected_descriptor, "actual": actual_descriptor})
        review_claims = [int(value) for value in re.findall(r"Review passes used:\s*(\d+)\s*/\s*2", documents["validation"])]
        reject(review_claims and all(value == expected_descriptor["review_passes"] for value in review_claims),
               "remainder-validation-review-claim", review_claims)

        delivery_status = "not-collected"
        expected_delivery_claims = {"status": "pending"}
        if DELIVERY_PATH.exists():
            delivery, paths, pointer = load_current_delivery()
            reject(delivery.get("scope") == scope and delivery.get("schema") == DELIVERY_SCHEMA,
                   "remainder-delivery-scope", delivery.get("scope"))
            reject(set(paths) == set(REMAINDER_GENERATION_ARTIFACTS),
                   "remainder-delivery-artifact-set", sorted(paths))
            delivery_status = delivery.get("status", "unknown")
            expected_delivery_claims = validation_delivery_claims(delivery, pointer)
        validate_delivery_claim_block(documents["validation"], expected_delivery_claims)
        return {
            "status": "verified", "scope": scope,
            "source": source["status"], "history": history["status"],
            "descriptor_sha256": sha256(canon_bytes(expected_descriptor)),
            "current_owner_counts": expected_descriptor["current_owner_counts"],
            "delivery": delivery_status,
            "validation_limits": validation_limits,
            "validation_controls": validation_controls,
            "reports": {key: sha256(value.encode()) for key, value in documents.items()},
        }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Verify the approved installed exact-source successor without network access."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    verify = subparsers.add_parser("verify-source")
    verify.add_argument("--negative-controls", action="store_true")
    history = subparsers.add_parser("verify-history")
    history.add_argument("--negative-controls", action="store_true")
    observed_test = subparsers.add_parser("self-test-observed")
    observed_test.add_argument("--scope", choices=SCOPE_OPTIONS, default="selected-settings")
    publication_test = subparsers.add_parser("self-test-publication")
    publication_test.add_argument("--scope", choices=SCOPE_OPTIONS, default="selected-settings")
    subparsers.add_parser("self-test-delivery-verification")
    collect = subparsers.add_parser("collect-ci")
    collect.add_argument("--pr-current", action="store_true", required=True)
    collect.add_argument("--red-capture-archive")
    collect.add_argument("--scope", choices=SCOPE_OPTIONS, default="selected-settings")
    verify_ci_parser = subparsers.add_parser("verify-ci")
    verify_ci_parser.add_argument("--pr-current", action="store_true", required=True)
    verify_ci_parser.add_argument("--negative-controls", action="store_true")
    verify_ci_parser.add_argument("--scope", choices=SCOPE_OPTIONS, default="selected-settings")
    merged = subparsers.add_parser("verify-merged")
    merged.add_argument("--pr-current", action="store_true", required=True)
    merged.add_argument("--scope", choices=SCOPE_OPTIONS, default="selected-settings")
    scope_parser = subparsers.add_parser("verify-scope")
    scope_parser.add_argument("--scope", choices=("debugger-remainder",), required=True)
    args = parser.parse_args(argv)

    try:
        if args.command == "verify-source":
            report = verify_source(include_negative_controls=args.negative_controls)
        elif args.command == "verify-history":
            report = verify_history(include_negative_controls=args.negative_controls)
        elif args.command == "self-test-observed":
            report = self_test_observed_for_scope(args.scope)
        elif args.command == "self-test-publication":
            with scoped_delivery(args.scope):
                report = self_test_publication()
        elif args.command == "self-test-delivery-verification":
            report = self_test_delivery_verification()
        elif args.command == "collect-ci":
            with scoped_delivery(args.scope):
                report = collect_ci(args.red_capture_archive)
        elif args.command == "verify-ci":
            with scoped_delivery(args.scope):
                report = verify_ci(negative_controls=args.negative_controls)
        elif args.command == "verify-scope":
            report = verify_scope(args.scope)
        else:
            with scoped_delivery(args.scope):
                report = verify_merged()
    except (VerificationError, ValueError, OSError, KeyError, IndexError) as error:
        print(
            json.dumps(
                {
                    "status": "rejected",
                    "reason": getattr(error, "reason", type(error).__name__),
                    "detail": getattr(error, "detail", str(error)),
                },
                sort_keys=True,
            ),
            file=sys.stderr,
        )
        return 1
    print(json.dumps(report, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
