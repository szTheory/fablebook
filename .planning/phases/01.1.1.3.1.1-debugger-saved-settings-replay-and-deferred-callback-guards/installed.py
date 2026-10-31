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
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PHASE_DIR = ROOT / ".planning/phases/01.1.1.3.1-debugger-remaining-settings-trace-breakpoint-and-monitor-rou"
CHILD_DIR = ROOT / ".planning/phases/01.1.1.3.1.1-debugger-saved-settings-replay-and-deferred-callback-guards"
ARCHIVE = ROOT / "test/fixtures/guards/exact_sources.tar.gz"
CANDIDATE = PHASE_DIR / "01.1.1.3.1-SOURCE-CANDIDATE.json"
DECISION = PHASE_DIR / "01.1.1.3.1-SOURCE-DECISION.md"
LEDGER = ROOT / ".planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz"

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
EXPECTED_MAPPING_PATHS = {
    f"{lane}/debugger/src/{module}.erl"
    for lane in ("core", "floor")
    for module in NEW_MODULES
}
SHA256_RE = re.compile(r"^[a-f0-9]{64}$")


class VerificationError(ValueError):
    def __init__(self, reason: str, detail: object):
        super().__init__(f"{reason}: {detail}")
        self.reason = reason
        self.detail = detail


def reject(condition: bool, reason: str, detail: object) -> None:
    if not condition:
        raise VerificationError(reason, detail)


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


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Verify the approved installed exact-source successor without network access."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)
    verify = subparsers.add_parser("verify-source")
    verify.add_argument("--negative-controls", action="store_true")
    args = parser.parse_args(argv)

    try:
        report = verify_source(include_negative_controls=args.negative_controls)
    except VerificationError as error:
        print(
            json.dumps(
                {"status": "rejected", "reason": error.reason, "detail": error.detail},
                sort_keys=True,
            ),
            file=sys.stderr,
        )
        return 1
    print(json.dumps(report, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
