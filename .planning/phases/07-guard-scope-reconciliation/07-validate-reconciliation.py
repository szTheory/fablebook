#!/usr/bin/env python3
"""Validate the bounded R11 producer-inspection result."""

from __future__ import annotations

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import os
import re
import stat
import sys
from pathlib import Path


PHASE = Path(__file__).resolve().parent
PROPOSAL = PHASE / "07-CORE-PRODUCER-REQUEST-R11-PROPOSAL.json"
REVIEW = PHASE / "07-CORE-PRODUCER-REQUEST-R11-REVIEW.md"
ANALYSIS = PHASE / "07-CORE-PRODUCER-ANALYSIS-R11.md"
R10_RECEIPT = PHASE / "07-CORE-PRODUCER-ANALYSIS.md"
ROOT = PHASE.parents[2]
CORE_EXPORTS = PHASE / "07-CORE-CURRENT-EXPORTS.jsonl"
CORE_EXPORT_SUMMARY = PHASE / "07-CORE-CURRENT-EXPORTS-SUMMARY.json"
CORE_MANIFEST = PHASE / "07-CORE-CURRENT-BEAM-MANIFEST.jsonl"
CORE_ROOTS = PHASE / "07-CORE-CURRENT-BEAM-ROOTS.json"
CORE_REVIEW = PHASE / "07-CORE-EXPORT-READER-REVIEW.md"
CORE_APPROVAL = PHASE / "07-CORE-EXPORT-READER-APPROVAL.json"
ROW_MEMBERSHIP = PHASE / "07-CORE-CURRENT-ROW-MEMBERSHIP.jsonl"
TYPED_GAPS = PHASE / "07-CORE-CURRENT-TYPED-GAPS.jsonl"
ASSOCIATIONS = PHASE / "07-CORE-CURRENT-TARGET-SOURCE-ASSOCIATIONS.jsonl"
FLOOR_MEMBERSHIP = PHASE / "07-FLOOR-RETAINED-ROW-MEMBERSHIP.jsonl"
PROVENANCE = PHASE / "07-CORE-CURRENT-PROVENANCE-MANIFEST.json"
RECONCILIATION = PHASE / "07-RECONCILIATION.json"
RECONCILIATION_MD = PHASE / "07-RECONCILIATION.md"
REDACTION_RECEIPT = PHASE / "07-REDACTION-RECEIPT.json"
PRIOR_RECONCILIATION = PHASE / "07-RECONCILIATION-PRIOR-STOP.json"
SOURCE_SCHEDULE = PHASE / "07-SOURCE-SCHEDULE.json"
SCHEDULE_REVIEW = PHASE / "07-SOURCE-SCHEDULE-REVIEW.md"
SOURCE_READER_REVIEW = PHASE / "07-SOURCE-READER-REVIEW-CONTINUATION.md"
SOURCE_READER_REVIEW_INITIAL = PHASE / "07-SOURCE-READER-REVIEW.md"
SOURCE_READER_REVIEW_CONSUMED = PHASE / "07-SOURCE-READER-REVIEW-CONSUMED.md"
SOURCE_READER = PHASE / "phase7_read_sources.py"
SOURCE_LAUNCHER = PHASE / "phase7_source_launcher.py"
SOURCE_BOOTSTRAP = PHASE / "phase7_source_bootstrap.py"
SOURCE_SPAN_OBSERVER = PHASE / "phase7_source_observer.py"
SOURCE_VALIDATOR = PHASE / "07-validate-reconciliation.py"
READ_TIME_CODE_SNAPSHOT = PHASE / "07-READ-TIME-CODE-SNAPSHOT.json"
READ_TIME_CODE_DIR = PHASE / "07-READ-TIME-CODE"
SOURCE_APPROVAL = PHASE / "07-SOURCE-APPROVAL.json"
OBSERVATION_FILES = {f"07-OBSERVATIONS-{index:02}.jsonl": PHASE / f"07-OBSERVATIONS-{index:02}.jsonl" for index in range(1, 6)}
READ_CONSUMPTION = PHASE / "07-SOURCE-READ-CONSUMPTION"
PHASE7_OUTPUTS = {
    ROW_MEMBERSHIP.name, FLOOR_MEMBERSHIP.name, TYPED_GAPS.name, ASSOCIATIONS.name, PROVENANCE.name,
    RECONCILIATION.name, SOURCE_SCHEDULE.name, SOURCE_APPROVAL.name,
    RECONCILIATION_MD.name, PRIOR_RECONCILIATION.name, SCHEDULE_REVIEW.name,
    SOURCE_READER_REVIEW.name, *OBSERVATION_FILES,
}
AGGREGATE_DIR = ROOT / ".planning/milestones/v0.4-phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing"
ENV06_DIR = ROOT / ".planning/milestones/v0.4-phases/04-evidence-only-source-and-gap-provenance-closure"
PHASE6_DIR = ROOT / ".planning/milestones/v0.5-phases/06-bounded-ex-177-provenance-supplement"
CORE_AGGREGATE = AGGREGATE_DIR / "03-CORE-AGGREGATE-EVIDENCE.json"
FLOOR_AGGREGATE = AGGREGATE_DIR / "03-FLOOR-AGGREGATE-EVIDENCE.json"
ENV06_MANIFEST = ENV06_DIR / "04-PROVENANCE-MANIFEST.json"
ENV06_REVIEW = ENV06_DIR / "04-EVIDENCE-REVIEW-ENV06-ONLY.json"
ENV06_VALIDATION = ENV06_DIR / "04-VALIDATION-ENV06-ONLY.json"
ENV06_TYPED_GAPS = ENV06_DIR / "04-TYPED-GAPS-ENV06.jsonl"
PHASE6_SUPPLEMENT = PHASE6_DIR / "06-EX177-SUPPLEMENT.json"
MFA_FIELDS = (
    "baseline_mfas", "added_mfas", "delivered_mfas", "delivered_now_missing_mfas",
    "delivered_scope_mfas", "live_mfas", "missing_mfas", "original_live_mfas",
    "pending_mfas", "replacement_live_mfas",
)
EXPECTED_FLOOR_LOCK_SHA256 = "ed16eae1dcb479e37c695cf818aab14e45ee818e3c794c3dddbee4dc2ffd3847"
EXPECTED_PHASE6_SUPPLEMENT_SHA256 = "304a82168d9e19b11cd208ed02d577d880bc0407f3d088012cae4206cfb7735b"
EXPECTED_NO_RETRY_REQUEST_ID = "core-source-01"
EXPECTED_NO_RETRY_STOP_SHA256 = "609d035c28cdd0b351273d83e2fd30674bc2fa63f57f63a55512446dada6eec4"
EXPECTED_NO_RETRY_MARKER_SHA256 = "810a5f74c46afe81426e5e25cb7e29447ae0401028e799f1fb3cae396fb7fe4a"
EXPECTED_INITIAL_READER_REVIEW_SHA256 = "d75119bb910ac98740eeb8fa6b388d4871e05774dc410870c7ca41d5edd2024a"
EXPECTED_INTERRUPTED_REVIEW_SHA256 = "39ae7c1356f7d8b8ace6472eb84b1f2a7ec1c4a235223e42b4240dc274262234"
EXPECTED_INTERRUPTED_STOP_SHA256 = "b24c444733f896db8898266cf89dc7b7431a8fe9e27149ea4e336254b7fb9cb4"
EXPECTED_INTERRUPTED_MARKERS = {
    "core-source-02": "36f8039b02f9c0feac2ed7eba8728f9874d64dcf3f2517076e8206c05f2a12c4",
    "core-source-03": "52a70e1f5f91c69dd549da161301abc88dac466bbb281bdf49c2f37d7f3b571b",
}
EXPECTED_INTERRUPTED_REQUESTS = ("core-source-01", "core-source-02", "core-source-03")
FINAL_RECONCILIATION_STATUS = "reconciled_with_explicit_source_gaps"
FINAL_OWNER_QUESTION = "After reviewing these explicit source gaps and the complete complement, should any further guard increment be authorized?"
FINAL_OWNER_RECOMMENDATION = (
    "Keep the candidate null and aggregate gate open. Three scheduled requests lack durable source hashes and spans, "
    "and the reader's module-key normalization mismatch prevented durable spans for one scheduled file. This bounded "
    "evidence does not support implementation. Stop here for "
    "the owner to decide whether a separately scoped evidence increment is worthwhile; all consumed requests remain closed."
)
EXPECTED_CURRENT_CORE_LOCK_SHA256 = "31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112"
EXPECTED_CURRENT_CORE_TOOL_SHA256 = "0d8e4f1d2fbde0cd63e4c45a60bbb4827058a592ee8b37057980627fcb517233"
EXPECTED_CURRENT_CORE_MIX_SHA256 = "0d8aae670b99fd5d3d519c0ec16bd44455397bc98f1a8f8b33864255f3e61ac9"
EXPECTED_PRESERVED_STOPS = {
    "candidate_fit": "unresolved", "candidate": None, "aggregate_gate": "open",
    "r9": {"id": "R9", "authorization": "denied", "one_use_gate_validation": "valid_denial", "consumption": "not_consumed"},
    "walking_skeleton": "blocked", "sec_01": "Pending", "actual_library_collision": "unknown",
    "macro_caller_ast": "unresolved", "macro_explanation": "unresolved",
    "legacy_digest": "unresolved", "automatic_followup": False,
}
EXPECTED_PHASE6_LANES = {
    "core": {
        "runtime": {"elixir": "1.20.4", "otp": "29.1.2"},
        "phoenix": {"version": "1.8.16", "lock_file": "mix.lock"},
        "source": {"recorded_value": "_build/lanes/core/deps/phoenix/lib/mix/tasks/phx.gen.context.ex",
                   "bytes": 14760, "sha256": "c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e"},
        "helper_definition": {"module": "Elixir.Mix.Tasks.Phx.Gen.Context", "function": "prompt_for_code_injection",
                              "arity": 1, "start_line": 445, "end_line": 451},
        "observed_direct_call": {"caller_function": "run", "caller_arity": 1, "call_line": 131,
                                 "caller_start_line": 112, "caller_end_line": 136},
    },
    "floor": {
        "runtime": {"elixir": "1.18.5", "otp": "27.3.4.9"},
        "phoenix": {"version": "1.8.9", "lock_file": "mix.floor.lock"},
        "source": {"recorded_value": "_build/lanes/floor/deps/phoenix/lib/mix/tasks/phx.gen.context.ex",
                   "bytes": 14760, "sha256": "c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e"},
        "helper_definition": {"module": "Elixir.Mix.Tasks.Phx.Gen.Context", "function": "prompt_for_code_injection",
                              "arity": 1, "start_line": 445, "end_line": 451},
        "observed_direct_call": {"caller_function": "run", "caller_arity": 1, "call_line": 131,
                                 "caller_start_line": 112, "caller_end_line": 136},
    },
}
LANE_METADATA_IDS_WITHOUT_MATCHES = {"CN-LANE-001", "BD-LANE-001", "BD-LANE-002", "BD-LANE-003", "BD-LANE-004"}


class ValidationError(Exception):
    pass


def expect(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValidationError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def read_json(path: Path):
    try:
        value, _data = read_json_bytes(path)
        return value
    except (OSError, json.JSONDecodeError, UnicodeDecodeError, ValidationError) as exc:
        raise ValidationError(f"cannot read valid JSON from {path.name}: {exc}") from exc


def require_text(path: Path) -> str:
    try:
        return read_capped(path, 16 * 1024 * 1024).decode("utf-8", "strict")
    except (OSError, UnicodeDecodeError, ValidationError) as exc:
        raise ValidationError(f"cannot read {path.name}: {exc}") from exc


def digest(path: Path) -> str:
    return sha256(read_capped(path))


def read_redaction_receipt() -> dict:
    receipt = read_json(REDACTION_RECEIPT)
    expect(receipt.get("schema") == "fablebook.phase7.path_redaction/1",
           "Phase 7 path-redaction receipt has an unexpected schema")
    return receipt


def redaction_entry(path: Path) -> dict | None:
    relative = path.relative_to(ROOT).as_posix()
    receipt = read_redaction_receipt()
    entries = receipt.get("files")
    expect(isinstance(entries, list), "path-redaction receipt has no file list")
    matches = [entry for entry in entries if entry.get("path") == relative]
    expect(len(matches) <= 1, f"path-redaction receipt duplicates {relative}")
    if not matches:
        return None
    entry = matches[0]
    expect(isinstance(entry.get("replacement_count"), int) and entry["replacement_count"] > 0
           and re.fullmatch(r"[0-9a-f]{64}", entry.get("original_sha256", "")) is not None
           and re.fullmatch(r"[0-9a-f]{64}", entry.get("redacted_sha256", "")) is not None,
           f"path-redaction receipt has an invalid transformation record for {relative}")
    expect(digest(path) == entry["redacted_sha256"],
           f"redacted artifact changed after its receipt: {relative}")
    return entry


def historical_digest(path: Path) -> str:
    entry = redaction_entry(path)
    return entry["original_sha256"] if entry else digest(path)


def validate_redaction_receipt() -> None:
    receipt = read_redaction_receipt()
    entries = receipt.get("files", [])
    paths = [entry.get("path") for entry in entries if isinstance(entry, dict)]
    expect(paths == sorted(set(paths)), "path-redaction receipt paths are not unique and sorted")
    for entry in entries:
        path = ROOT / entry["path"]
        expect(path.is_relative_to(PHASE), "path-redaction receipt points outside Phase 7")
        redaction_entry(path)
    for path in PHASE.rglob("*"):
        if path.is_file() and path.suffix != ".pyc":
            data = read_capped(path, 64 * 1024 * 1024)
            expect((b"/" + b"Users" + b"/") not in data,
                   f"Phase 7 still contains an absolute home path: {path.name}")


def path_for_local_check(value: str) -> Path:
    path = Path(value)
    if value.startswith("~/"):
        path = Path.home() / value[2:]
    return path


def shortened_home_path(value: str) -> str:
    home = Path.home().as_posix()
    if value == home:
        return "~"
    if value.startswith(home + "/"):
        return "~" + value[len(home):]
    return value


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def reject_symlink_components(path: Path) -> None:
    absolute = Path(os.path.abspath(path))
    current = Path(absolute.anchor)
    for part in absolute.parts[1:]:
        current = current / part
        try:
            mode = os.lstat(current).st_mode
        except OSError as exc:
            raise ValidationError(f"cannot verify fixed input path {current}: {exc}") from exc
        if stat.S_ISLNK(mode):
            raise ValidationError(f"fixed input path contains a symbolic link: {current}")


def open_directory_nofollow(path: Path) -> int:
    absolute = Path(os.path.abspath(path))
    if not absolute.is_absolute():
        raise ValidationError(f"expected an absolute fixed directory path: {path}")
    directory_flags = os.O_RDONLY | getattr(os, "O_DIRECTORY", 0)
    if hasattr(os, "O_NOFOLLOW"):
        directory_flags |= os.O_NOFOLLOW
    try:
        directory_fd = os.open(absolute.anchor, directory_flags)
        for component in absolute.parts[1:]:
            next_fd = os.open(component, directory_flags, dir_fd=directory_fd)
            os.close(directory_fd)
            directory_fd = next_fd
        return directory_fd
    except OSError as exc:
        try:
            os.close(directory_fd)
        except (OSError, UnboundLocalError):
            pass
        raise ValidationError(f"cannot safely open fixed directory {path}: {exc}") from exc


def read_capped(path: Path, cap: int = 64 * 1024 * 1024) -> bytes:
    absolute = Path(os.path.abspath(path))
    if not absolute.is_absolute() or len(absolute.parts) < 2:
        raise ValidationError(f"expected an absolute fixed input path: {path}")
    parent_fd = open_directory_nofollow(absolute.parent)
    leaf = absolute.name
    flags = (os.O_RDONLY | getattr(os, "O_NONBLOCK", 0)
             | (os.O_NOFOLLOW if hasattr(os, "O_NOFOLLOW") else 0))
    try:
        info = os.stat(leaf, dir_fd=parent_fd, follow_symlinks=False)
        if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
            raise ValidationError(f"expected a regular non-symlink file: {path.name}")
        if info.st_size > cap:
            raise ValidationError(f"input exceeds the reader limit: {path.name}")
        fd = os.open(leaf, flags, dir_fd=parent_fd)
    except ValidationError:
        os.close(parent_fd)
        raise
    except OSError as exc:
        os.close(parent_fd)
        raise ValidationError(f"cannot safely open {path.name}: {exc}") from exc
    try:
        before = os.fstat(fd)
        keys = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
        if (not stat.S_ISREG(before.st_mode)
                or any(getattr(before, key) != getattr(info, key) for key in keys)):
            raise ValidationError(f"input changed before it was read: {path.name}")
        chunks = []
        remaining = before.st_size
        while remaining:
            block = os.read(fd, min(remaining, 1024 * 1024))
            if not block:
                raise ValidationError(f"input changed while being read: {path.name}")
            chunks.append(block)
            remaining -= len(block)
        after = os.fstat(fd)
        if any(getattr(before, key) != getattr(after, key) for key in keys):
            raise ValidationError(f"input changed while being read: {path.name}")
        return b"".join(chunks)
    finally:
        os.close(fd)
        os.close(parent_fd)


def read_json_bytes(path: Path, cap: int = 64 * 1024 * 1024) -> tuple[dict, bytes]:
    data = read_capped(path, cap)
    try:
        value = json.loads(data.decode("utf-8", "strict"), object_pairs_hook=unique_object)
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ValidationError(f"invalid JSON in {path.name}: {exc}") from exc
    if not isinstance(value, dict):
        raise ValidationError(f"expected a JSON object in {path.name}")
    return value, data


def read_jsonl_bytes(path: Path, cap: int = 64 * 1024 * 1024) -> tuple[list[dict], bytes]:
    data = read_capped(path, cap)
    rows = []
    for line_number, line in enumerate(data.splitlines(), 1):
        if not line:
            raise ValidationError(f"blank JSONL row in {path.name}:{line_number}")
        try:
            row = json.loads(line.decode("utf-8", "strict"), object_pairs_hook=unique_object)
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise ValidationError(f"invalid JSONL in {path.name}:{line_number}: {exc}") from exc
        if not isinstance(row, dict):
            raise ValidationError(f"non-object JSONL row in {path.name}:{line_number}")
        rows.append(row)
    return rows, data


def mfa_from_tuple(value, label: str) -> tuple[str, str, int]:
    if not isinstance(value, list) or len(value) != 3:
        raise ValidationError(f"unmappable MFA tuple in {label}: {value!r}")
    module, function, arity = value
    if (not isinstance(module, str) or not module or not isinstance(function, str) or not function
            or not isinstance(arity, int) or isinstance(arity, bool) or not 0 <= arity <= 255):
        raise ValidationError(f"unmappable MFA tuple in {label}: {value!r}")
    return module, function, arity


def mfa_from_text(value, label: str, known_mfas: set[tuple[str, str, int]]) -> tuple[str, str, int]:
    if not isinstance(value, str):
        raise ValidationError(f"unmappable MFA text in {label}: {value!r}")
    if "/" not in value:
        raise ValidationError(f"unmappable MFA text in {label}: {value!r}")
    qualified_name, arity_text = value.rsplit("/", 1)
    if not arity_text.isdigit():
        raise ValidationError(f"unmappable MFA text in {label}: {value!r}")
    arity = int(arity_text)
    if arity > 255:
        raise ValidationError(f"MFA arity is outside the supported range in {label}: {value!r}")
    candidates = set()
    for separator, character in enumerate(qualified_name):
        if character == ":" and separator > 0 and separator < len(qualified_name) - 1:
            candidate = (qualified_name[:separator], qualified_name[separator + 1:], arity)
            if candidate in known_mfas:
                candidates.add(candidate)
    if len(candidates) != 1:
        reason = "does not resolve to a saved/current MFA" if not candidates else "resolves ambiguously"
        raise ValidationError(f"MFA text {reason} in {label}: {value!r}")
    return next(iter(candidates))


def mfa_json(mfa: tuple[str, str, int]) -> list:
    return [mfa[0], mfa[1], mfa[2]]


def canonical_jsonl(rows: list[dict]) -> bytes:
    return b"".join((json.dumps(row, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode() for row in rows)


def write_new(name: str, data: bytes) -> None:
    if name not in PHASE7_OUTPUTS:
        raise ValidationError(f"refusing unapproved Phase 7 output: {name}")
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    directory_fd = open_directory_nofollow(PHASE)
    try:
        fd = os.open(name, flags, 0o600, dir_fd=directory_fd)
    except FileExistsError as exc:
        os.close(directory_fd)
        raise ValidationError(f"refusing to overwrite existing Phase 7 evidence: {name}") from exc
    except OSError as exc:
        os.close(directory_fd)
        raise ValidationError(f"cannot safely create Phase 7 output {name}: {exc}") from exc
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
    finally:
        os.close(directory_fd)


def replace_phase_file_atomically(name: str, data: bytes) -> None:
    if name not in PHASE7_OUTPUTS:
        raise ValidationError(f"refusing an unapproved Phase 7 replacement: {name}")
    directory_fd = open_directory_nofollow(PHASE)
    temp_name = f".{name}.pending"
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        fd = os.open(temp_name, flags, 0o600, dir_fd=directory_fd)
        try:
            with os.fdopen(fd, "wb") as handle:
                handle.write(data)
                handle.flush()
                os.fsync(handle.fileno())
        except Exception:
            try:
                os.unlink(temp_name, dir_fd=directory_fd)
            except OSError:
                pass
            raise
        os.rename(temp_name, name, src_dir_fd=directory_fd, dst_dir_fd=directory_fd)
        os.fsync(directory_fd)
    except FileExistsError as exc:
        raise ValidationError(f"refusing to overwrite existing reconciliation staging file: {temp_name}") from exc
    except OSError as exc:
        raise ValidationError(f"cannot atomically replace Phase 7 evidence {name}: {exc}") from exc
    finally:
        os.close(directory_fd)


def relpath(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def input_record(path: Path, data: bytes) -> dict:
    return {"path": relpath(path), "bytes": len(data), "sha256": sha256(data)}


def load_phase_inputs() -> dict:
    records: dict[str, tuple[Path, bytes]] = {}
    json_values = {}
    jsonl_values = {}

    for key, path, cap in (
        ("core_aggregate", CORE_AGGREGATE, 32 * 1024 * 1024),
        ("floor_aggregate", FLOOR_AGGREGATE, 32 * 1024 * 1024),
        ("env06_manifest", ENV06_MANIFEST, 8 * 1024 * 1024),
        ("env06_review", ENV06_REVIEW, 2 * 1024 * 1024),
        ("env06_validation", ENV06_VALIDATION, 8 * 1024 * 1024),
        ("phase6_supplement", PHASE6_SUPPLEMENT, 4 * 1024 * 1024),
        ("core_export_summary", CORE_EXPORT_SUMMARY, 1024 * 1024),
        ("core_roots", CORE_ROOTS, 8 * 1024 * 1024),
        ("core_approval", CORE_APPROVAL, 64 * 1024),
    ):
        value, data = read_json_bytes(path, cap)
        records[key] = (path, data)
        json_values[key] = value

    for key, path, cap in (
        ("env06_typed_gaps", ENV06_TYPED_GAPS, 32 * 1024 * 1024),
        ("core_manifest", CORE_MANIFEST, 32 * 1024 * 1024),
        ("core_exports", CORE_EXPORTS, 32 * 1024 * 1024),
    ):
        value, data = read_jsonl_bytes(path, cap)
        records[key] = (path, data)
        jsonl_values[key] = value

    for key, path in (
        ("core_lock", ROOT / "mix.lock"),
        ("floor_lock", ROOT / "mix.floor.lock"),
        ("core_tool_versions", ROOT / ".tool-versions"),
        ("floor_tool_versions", ROOT / ".tool-versions.floor"),
        ("mix_exs", ROOT / "mix.exs"),
        ("reader_producer", PHASE / "07-inventory-compiled-exports.py"),
        ("core_review", CORE_REVIEW),
        ("env06_associations", ENV06_DIR / "04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl"),
    ):
        data = read_capped(path, 2 * 1024 * 1024)
        records[key] = (path, data)

    return {"records": records, "json": json_values, "jsonl": jsonl_values}


def load_retained_inputs() -> dict:
    records: dict[str, tuple[Path, bytes]] = {}
    json_values = {}
    jsonl_values = {}
    for key, path, cap in (
        ("core_aggregate", CORE_AGGREGATE, 32 * 1024 * 1024),
        ("floor_aggregate", FLOOR_AGGREGATE, 32 * 1024 * 1024),
        ("env06_manifest", ENV06_MANIFEST, 8 * 1024 * 1024),
        ("env06_review", ENV06_REVIEW, 2 * 1024 * 1024),
        ("env06_validation", ENV06_VALIDATION, 8 * 1024 * 1024),
        ("phase6_supplement", PHASE6_SUPPLEMENT, 4 * 1024 * 1024),
    ):
        value, data = read_json_bytes(path, cap)
        records[key] = (path, data)
        json_values[key] = value
    gap_rows, gap_data = read_jsonl_bytes(ENV06_TYPED_GAPS, 32 * 1024 * 1024)
    records["env06_typed_gaps"] = (ENV06_TYPED_GAPS, gap_data)
    jsonl_values["env06_typed_gaps"] = gap_rows
    for key, path in (
        ("core_lock", ROOT / "mix.lock"),
        ("floor_lock", ROOT / "mix.floor.lock"),
        ("core_tool_versions", ROOT / ".tool-versions"),
        ("floor_tool_versions", ROOT / ".tool-versions.floor"),
        ("mix_exs", ROOT / "mix.exs"),
        ("env06_associations", ENV06_DIR / "04-TARGET-SOURCE-ASSOCIATIONS-ENV06.jsonl"),
    ):
        records[key] = (path, read_capped(path, 2 * 1024 * 1024))
    return {"records": records, "json": json_values, "jsonl": jsonl_values}


def require_digest(record: dict, expected: str, label: str) -> None:
    if record.get("sha256") != expected:
        raise ValidationError(f"{label} digest differs from its accepted receipt")


def parse_tool_versions(data: bytes, label: str) -> dict[str, str]:
    try:
        lines = data.decode("utf-8", "strict").splitlines()
    except UnicodeDecodeError as exc:
        raise ValidationError(f"{label} is not UTF-8") from exc
    versions = {}
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        fields = line.split()
        if len(fields) != 2 or fields[0] in versions:
            raise ValidationError(f"{label} has a malformed or duplicate version entry")
        versions[fields[0]] = fields[1]
    return versions


def validate_saved_envelopes(inputs: dict) -> dict:
    records = inputs["records"]
    values = inputs["json"]
    manifest = values["env06_manifest"]
    review = values["env06_review"]
    validation = values["env06_validation"]
    supplement = values["phase6_supplement"]
    core = values["core_aggregate"]
    floor = values["floor_aggregate"]

    expected_generation = "ENV-20261117-06-supported-20261117T204102Z"
    if manifest.get("generation") != expected_generation or manifest.get("source_access") != "closed":
        raise ValidationError("ENV06 is not the retained source-closed evidence generation")
    if review.get("status") != "pass" or review.get("source_access") != "closed":
        raise ValidationError("ENV06 does not have its accepted source-closed independent review")
    if (validation.get("generation") != expected_generation or validation.get("result") != "pass_with_open_gaps"
            or validation.get("validation_passed") is not True or validation.get("full_package_valid") is not True
            or validation.get("source_access") != "closed" or validation.get("semantic_closure") != "open"):
        raise ValidationError("ENV06 validation receipt does not establish the accepted open-gap package")
    require_digest({"sha256": sha256(records["env06_manifest"][1]),
                    "path": relpath(records["env06_manifest"][0])},
                   validation.get("bindings", {}).get("manifest_sha256", ""), "ENV06 manifest")
    require_digest({"sha256": sha256(records["env06_review"][1])},
                   validation.get("bindings", {}).get("evidence_review_sha256", ""), "ENV06 review")
    require_digest({"sha256": sha256(records["env06_typed_gaps"][1])},
                   validation.get("bindings", {}).get("typed_gaps_sha256", ""), "ENV06 typed gaps")
    require_digest({"sha256": sha256(records["env06_associations"][1])},
                   validation.get("bindings", {}).get("association_sha256", ""), "ENV06 source associations")
    if records["env06_associations"][1] != b"":
        raise ValidationError("ENV06 has source associations; the retained floor cannot be treated as unmapped")

    env_lanes = manifest.get("lanes", {})
    for lane, aggregate in (("core", core), ("floor", floor)):
        lane_record = env_lanes.get(lane, {}).get("record", {})
        if lane_record.get("path") != f".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-{lane.upper()}-AGGREGATE-EVIDENCE.json":
            raise ValidationError(f"ENV06 {lane} aggregate path does not match the fixed historical alias")
        if lane_record.get("sha256") != sha256(records[f"{lane}_aggregate"][1]):
            raise ValidationError(f"archived {lane} aggregate bytes differ from ENV06")
        if aggregate.get("lane") != lane or aggregate.get("generation") != "09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b":
            raise ValidationError(f"saved {lane} aggregate lane or generation changed")
        lane_fields = env_lanes[lane].get("current_lane_fields", {})
        if aggregate.get("lock_sha256") != lane_fields.get("lock_sha256"):
            raise ValidationError(f"saved {lane} aggregate lock is not the ENV06 accepted identity")
        if aggregate.get("runtime", {}).get("elixir") != lane_fields.get("runtime", {}).get("elixir"):
            raise ValidationError(f"saved {lane} aggregate Elixir version differs from ENV06")
        if aggregate.get("runtime", {}).get("otp") != lane_fields.get("runtime", {}).get("otp"):
            raise ValidationError(f"saved {lane} aggregate OTP version differs from ENV06")
        if len(aggregate.get("identity_rows", [])) != 226:
            raise ValidationError(f"saved {lane} aggregate does not contain exactly 226 identity rows")
        if len({row.get("identity", {}).get("id") for row in aggregate["identity_rows"]}) != 226:
            raise ValidationError(f"saved {lane} aggregate has missing or duplicate identity IDs")
        saved_ids = [row["identity"]["id"] for row in aggregate["identity_rows"]]
        lane_manifest = env_lanes[lane]
        if saved_ids != lane_manifest.get("identity_ids"):
            raise ValidationError(f"saved {lane} row order/IDs differ from the accepted ENV06 list")
        encoded_ids = json.dumps(saved_ids, separators=(",", ":"), ensure_ascii=True).encode()
        if sha256(encoded_ids) != lane_manifest.get("identity_ids_sha256"):
            raise ValidationError(f"saved {lane} identity ID digest differs from ENV06")
        baseline_memberships = sum(len(row["baseline_mfas"]) for row in aggregate["identity_rows"])
        live_memberships = sum(len(row["live_mfas"]) for row in aggregate["identity_rows"])
        union_memberships = {(row["identity"]["id"], tuple(mfa))
                             for row in aggregate["identity_rows"]
                             for field in ("baseline_mfas", "live_mfas")
                             for mfa in row[field]}
        if (baseline_memberships != lane_manifest.get("baseline_key_count")
                or live_memberships != lane_manifest.get("live_key_count")
                or len(union_memberships) != lane_manifest.get("union_key_count")):
            raise ValidationError(f"saved {lane} row membership counts differ from ENV06")

    floor_lock = records["floor_lock"][1]
    floor_lane = env_lanes["floor"]["current_lane_fields"]
    if sha256(floor_lock) != EXPECTED_FLOOR_LOCK_SHA256 or sha256(floor_lock) != floor_lane.get("lock_sha256"):
        raise ValidationError("current floor lock differs from the accepted ENV06 floor lock")
    floor_versions = parse_tool_versions(records["floor_tool_versions"][1], ".tool-versions.floor")
    floor_runtime = supplement.get("lanes", {}).get("floor", {}).get("runtime", {})
    if (floor_versions.get("elixir") != "1.18.5-otp-27" or floor_versions.get("erlang") != "27.3.4.9"
            or floor_runtime != {"elixir": "1.18.5", "otp": "27.3.4.9"}
            or floor_lane.get("runtime") != {"elixir": "1.18.5", "otp": "27"}):
        raise ValidationError("floor runtime pins no longer match ENV06 and the Phase 6 exact patch receipt")
    if sha256(records["phase6_supplement"][1]) != EXPECTED_PHASE6_SUPPLEMENT_SHA256:
        raise ValidationError("Phase 6 supplement bytes differ from the reviewed EX-177 receipt")
    if supplement.get("lanes") != EXPECTED_PHASE6_LANES:
        raise ValidationError("Phase 6 source, Phoenix, target MFA, or caller values differ from the reviewed EX-177 receipt")
    stops = supplement.get("preserved_stops")
    if stops != EXPECTED_PRESERVED_STOPS:
        raise ValidationError("an inherited safety stop differs from the preserved Phase 6 decision")

    core_lock = records["core_lock"][1]
    tool_data = records["core_tool_versions"][1]
    mix_data = records["mix_exs"][1]
    if (sha256(core_lock) != EXPECTED_CURRENT_CORE_LOCK_SHA256
            or sha256(tool_data) != EXPECTED_CURRENT_CORE_TOOL_SHA256
            or sha256(mix_data) != EXPECTED_CURRENT_CORE_MIX_SHA256):
        raise ValidationError("current core lock, runtime declaration, or project dependency declaration changed")
    tool_versions = parse_tool_versions(tool_data, ".tool-versions")
    if tool_versions.get("elixir") != "1.20.4-otp-29" or tool_versions.get("erlang") != "29.1.2":
        raise ValidationError("current core toolchain does not match the reviewed exact versions")
    return {"generation": expected_generation, "stops": stops, "core_tool_versions": tool_versions,
            "floor_tool_versions": floor_versions, "core_lane_manifest": env_lanes["core"],
            "floor_lane_manifest": env_lanes["floor"]}


def validate_aggregate_rows(aggregate: dict, lane: str) -> None:
    for index, row in enumerate(aggregate["identity_rows"]):
        identity = row.get("identity")
        if not isinstance(identity, dict) or not isinstance(identity.get("id"), str):
            raise ValidationError(f"{lane} row {index} lacks a stable identity")
        for field in MFA_FIELDS:
            if not isinstance(row.get(field), list):
                raise ValidationError(f"{lane} row {identity['id']} lacks list field {field}")
            for item in row[field]:
                mfa_from_tuple(item, f"{lane} {identity['id']} {field}")
        fields = {field: {tuple(item) for item in row[field]} for field in MFA_FIELDS}
        if fields["live_mfas"] != fields["replacement_live_mfas"]:
            raise ValidationError(f"{lane} row {identity['id']} live/replacement membership differs")
        if fields["added_mfas"] != fields["live_mfas"] - fields["baseline_mfas"]:
            raise ValidationError(f"{lane} row {identity['id']} added membership is inconsistent")
        if fields["missing_mfas"] != fields["baseline_mfas"] - fields["live_mfas"]:
            raise ValidationError(f"{lane} row {identity['id']} missing membership is inconsistent")
        delivered = fields["delivered_scope_mfas"] & fields["live_mfas"]
        if fields["delivered_mfas"] != delivered:
            raise ValidationError(f"{lane} row {identity['id']} delivered membership is inconsistent")
        if fields["delivered_now_missing_mfas"] != fields["delivered_scope_mfas"] - fields["live_mfas"]:
            raise ValidationError(f"{lane} row {identity['id']} delivered-now-missing membership is inconsistent")
        if fields["pending_mfas"] != fields["live_mfas"] - fields["delivered_scope_mfas"]:
            raise ValidationError(f"{lane} row {identity['id']} pending membership is inconsistent")
        if fields["delivered_mfas"] & fields["pending_mfas"] or fields["delivered_mfas"] | fields["pending_mfas"] != fields["live_mfas"]:
            raise ValidationError(f"{lane} row {identity['id']} delivered/pending partition is inconsistent")
        lane_matches = identity.get("lane_matches")
        if lane_matches is None:
            if identity["id"] not in LANE_METADATA_IDS_WITHOUT_MATCHES or identity.get("identity_class") != "lane_metadata":
                raise ValidationError(f"{lane} row {identity['id']} unexpectedly lacks lane_matches")
            if any(fields[field] for field in MFA_FIELDS):
                raise ValidationError(f"{lane} metadata-only row {identity['id']} unexpectedly has MFA memberships")
        elif (not isinstance(lane_matches, dict) or not isinstance(lane_matches.get("core"), list)
              or not isinstance(lane_matches.get("floor"), list)):
            raise ValidationError(f"{lane} row {identity['id']} has malformed lane_matches arrays")


def canonical_mfa_digest(mfas: list[tuple[str, str, int]]) -> str:
    import struct
    encoded = bytearray()
    for module, function, arity in sorted(set(mfas)):
        for value in (module, function):
            raw = value.encode("utf-8", "strict")
            encoded.extend(struct.pack(">I", len(raw)))
            encoded.extend(raw)
        encoded.extend(struct.pack(">I", arity))
    return sha256(bytes(encoded))


def assert_manifest_export_coverage(manifest_paths: set[str], exports_by_beam: dict[str, list]) -> None:
    exported_paths = set(exports_by_beam)
    missing = manifest_paths - exported_paths
    extra = exported_paths - manifest_paths
    if missing or extra:
        preview = sorted(missing)[:5]
        raise ValidationError(
            f"compiled-file export coverage differs from the reviewed manifest "
            f"(no export rows for {len(missing)} listed file(s), {len(extra)} unlisted path(s)); "
            f"missing examples: {preview}"
        )


def validate_current_export_records(inputs: dict) -> tuple[dict, dict, list[dict]]:
    records = inputs["records"]
    values = inputs["json"]
    rows = inputs["jsonl"]["core_exports"]
    summary = values["core_export_summary"]
    roots_obj = values["core_roots"]
    manifest_rows = inputs["jsonl"]["core_manifest"]
    manifest_data = records["core_manifest"][1]
    roots_data = records["core_roots"][1]
    exports_data = records["core_exports"][1]
    identity_rows = [row for row in manifest_rows if row.get("type") == "identity"]
    root_rows = [row for row in manifest_rows if row.get("type") == "root"]
    beam_rows = [row for row in manifest_rows if row.get("type") == "beam"]
    if len(identity_rows) != 1 or not beam_rows or len({row.get("path") for row in beam_rows}) != len(beam_rows):
        raise ValidationError("reviewed core manifest has missing identity, no files, or duplicate paths")
    identity = identity_rows[0]
    manifest_digest = sha256(manifest_data)
    roots_digest = sha256(roots_data)
    exports_digest = sha256(exports_data)
    approval = values["core_approval"]
    review_bytes = records["core_review"][1]
    review_digest = sha256(review_bytes)
    if (identity.get("lock_sha256") != EXPECTED_CURRENT_CORE_LOCK_SHA256
            or identity.get("tool_versions_sha256") != EXPECTED_CURRENT_CORE_TOOL_SHA256
            or identity.get("mix_exs_sha256") != EXPECTED_CURRENT_CORE_MIX_SHA256):
        raise ValidationError("compiled manifest identity does not match the exact current core pins")
    if identity.get("producer_sha256") != sha256(records["reader_producer"][1]):
        raise ValidationError("compiled manifest is bound to a different producer file")
    if (summary.get("lock_sha256") != identity.get("lock_sha256")
            or summary.get("schema") != "fablebook.phase7.compiled_exports.v2"
            or summary.get("tool_versions_sha256") != identity.get("tool_versions_sha256")
            or summary.get("mix_exs_sha256") != identity.get("mix_exs_sha256")
            or summary.get("producer_sha256") != identity.get("producer_sha256")
            or summary.get("manifest_sha256") != manifest_digest
            or summary.get("exports_jsonl_sha256") != exports_digest
            or summary.get("export_count") != len(rows)
            or summary.get("beam_file_count") != len(beam_rows)
            or summary.get("generation_id") != "phase7-core-" + manifest_digest[:16]
            or summary.get("source_file_hashes_complete") is not False
            or summary.get("old_whole_inventory_member_list_available") is not False):
        raise ValidationError("current core export summary does not bind its exact inputs and row counts")
    expected_approval = {
        "schema": "fablebook.phase7.exports_review.v2", "verdict": "PASS",
        "review_file_sha256": review_digest, "producer_sha256": identity.get("producer_sha256"),
        "manifest_sha256": manifest_digest, "root_summary_sha256": roots_digest,
    }
    if (not isinstance(approval, dict) or set(approval) != set(expected_approval) | {"reviewer"}
            or any(approval.get(key) != value for key, value in expected_approval.items())
            or not isinstance(approval.get("reviewer"), str) or not approval["reviewer"].strip()):
        raise ValidationError("machine approval does not bind the exact reader, manifest, roots, and review")
    try:
        review_text = review_bytes.decode("utf-8", "strict")
    except UnicodeDecodeError as exc:
        raise ValidationError("independent manifest review is not UTF-8") from exc
    if not all(value in review_text for value in ("PASS", manifest_digest, roots_digest,
                                                   identity.get("producer_sha256", ""), approval["reviewer"])):
        raise ValidationError("independent manifest review does not name PASS and the exact reviewed digests")
    if (roots_obj.get("manifest_sha256") != manifest_digest
            or roots_obj.get("roots") != root_rows
            or roots_obj.get("root_count") != len(root_rows)
            or roots_obj.get("beam_file_count") != len(beam_rows)
            or roots_obj.get("beam_bytes") != sum(row.get("beam_bytes", 0) for row in root_rows)):
        raise ValidationError("reviewed roots summary does not match the exact compiled manifest")
    if identity.get("otp_version") != "29.1.2" or identity.get("elixir_version") != "1.20.4-otp-29":
        raise ValidationError("compiled manifest runtime identity differs from the selected core versions")
    resolved_roots = identity.get("resolved_roots")
    if (not isinstance(resolved_roots, dict)
            or set(resolved_roots) != {"otp_lib", "elixir_lib"}
            or any(not isinstance(value, dict) or not value.get("locator")
                   or not re.fullmatch(r"[0-9a-f]{64}", value.get("path_sha256", ""))
                   or not isinstance(value.get("device"), int) or not isinstance(value.get("inode"), int)
                   for value in resolved_roots.values())
            or resolved_roots["otp_lib"].get("tool") != "erlang"
            or resolved_roots["otp_lib"].get("version") != "29.1.2"
            or not resolved_roots["otp_lib"].get("locator", "").endswith("/installs/erlang/29.1.2/lib")
            or resolved_roots["elixir_lib"].get("tool") != "elixir"
            or resolved_roots["elixir_lib"].get("version") != "1.20.4-otp-29"
            or not resolved_roots["elixir_lib"].get("locator", "").endswith("/installs/elixir/1.20.4-otp-29/lib")):
        raise ValidationError("compiled manifest does not reveal the exact installed runtime roots")

    manifest_by_path = {row["path"]: row for row in beam_rows}
    if len(manifest_by_path) != len(beam_rows):
        raise ValidationError("reviewed compiled manifest contains duplicate BEAM paths")
    root_by_identity = {}
    for root in root_rows:
        key = (root.get("kind"), root.get("app"), root.get("version"), root.get("package"),
               root.get("package_version"), tuple(root.get("lock_checksums", [])), root.get("root"), root.get("ebin"))
        if key in root_by_identity:
            raise ValidationError("compiled manifest has duplicate package/root identities")
        root_by_identity[key] = root
    module_paths = {}
    export_map = {}
    exports_mfas = []
    exports_by_beam = {}
    for row in rows:
        try:
            mfa = mfa_from_tuple([row.get("module"), row.get("function"), row.get("arity")], "fresh core export")
        except ValidationError as exc:
            raise ValidationError(str(exc)) from exc
        beam_path = row.get("beam_path")
        manifest_row = manifest_by_path.get(beam_path)
        if manifest_row is None:
            raise ValidationError("export row points outside the exact reviewed compiled-file manifest")
        for key in ("kind", "app", "app_version", "package", "package_version", "lock_checksums", "beam_bytes", "beam_device", "beam_inode", "beam_mtime_ns", "beam_ctime_ns"):
            manifest_key = {"beam_bytes": "bytes", "beam_device": "device", "beam_inode": "inode", "beam_mtime_ns": "mtime_ns", "beam_ctime_ns": "ctime_ns"}.get(key, key)
            if row.get(key) != manifest_row.get(manifest_key):
                raise ValidationError(f"fresh export row identity differs from its manifest for {key}")
        if manifest_row.get("expected_module") != mfa[0]:
            raise ValidationError("fresh export module differs from its exact compiled filename")
        root_key = (manifest_row.get("kind"), manifest_row.get("app"), manifest_row.get("app_version"),
                    manifest_row.get("package"), manifest_row.get("package_version"),
                    tuple(manifest_row.get("lock_checksums", [])), manifest_row.get("root"), manifest_row.get("ebin"))
        if root_key not in root_by_identity:
            raise ValidationError("compiled file package identity has no exact reviewed root record")
        if not beam_path.startswith(manifest_row.get("ebin", "") + "/"):
            raise ValidationError("compiled file path escapes its reviewed application ebin directory")
        previous = module_paths.setdefault(mfa[0], beam_path)
        if previous != beam_path:
            raise ValidationError("one exported module maps to multiple compiled files")
        kind = row.get("kind")
        app = row.get("app")
        if not isinstance(app, str) or not app or not isinstance(row.get("app_version"), str) or not row["app_version"]:
            raise ValidationError("export has no exact application/release identity")
        if kind == "dependency":
            checksums = row.get("lock_checksums")
            if (row.get("package") != app or not isinstance(row.get("package_version"), str) or not row["package_version"]
                    or not isinstance(checksums, list) or len(checksums) != 2
                    or any(not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{64}", value) for value in checksums)):
                raise ValidationError("Hex export lacks its exact locked package identity")
        elif kind in ("otp", "elixir"):
            if row.get("package") != "" or row.get("package_version") != "" or row.get("lock_checksums") != []:
                raise ValidationError("OTP/Elixir export unexpectedly carries Hex package identity")
        else:
            raise ValidationError("fresh core export has an unapproved package kind")
        if mfa in export_map:
            raise ValidationError("one MFA is exported by more than one current package/module record")
        export_map[mfa] = row
        exports_mfas.append(mfa)
        exports_by_beam.setdefault(beam_path, []).append(mfa)
    assert_manifest_export_coverage(set(manifest_by_path), exports_by_beam)
    per_file_digests = {beam_path: canonical_mfa_digest(beam_mfas) for beam_path, beam_mfas in exports_by_beam.items()}
    if any(row.get("exports_sha256") != per_file_digests.get(row.get("beam_path")) for row in rows):
        raise ValidationError("per-file canonical export digest differs from its rows")
    sort_keys = [(row.get("module"), row.get("function"), row.get("arity"), row.get("beam_path")) for row in rows]
    if sort_keys != sorted(sort_keys):
        raise ValidationError("fresh export rows are not in the canonical order")
    if summary.get("exports_mfa_sha256") != canonical_mfa_digest(exports_mfas):
        raise ValidationError("fresh canonical export-membership digest differs from the receipt")
    return export_map, summary, beam_rows


def parse_values(values: list, parse_fn, label: str, *parse_args) -> tuple[list[tuple[str, str, int]], list]:
    parsed = []
    unparseable = []
    for raw in values:
        try:
            parsed.append(parse_fn(raw, label, *parse_args))
        except ValidationError:
            unparseable.append(raw)
    return parsed, unparseable


def package_identity(export: dict) -> dict:
    return {
        "kind": export["kind"], "app": export["app"], "app_version": export["app_version"],
        "package": export["package"], "package_version": export["package_version"],
        "lock_checksums": export["lock_checksums"], "beam_path": export["beam_path"],
        "exports_sha256": export["exports_sha256"],
    }


def typed_gap_live_rows(gap_rows: list[dict], aggregate: dict, lane: str, aggregate_hash: str) -> tuple[dict, dict]:
    by_id = {row["identity"]["id"]: (index, row) for index, row in enumerate(aggregate["identity_rows"])}
    result = {}
    all_source = {}
    for line_number, gap in enumerate(gap_rows, 1):
        if gap.get("lane") != lane or gap.get("domain") != "source":
            continue
        if gap.get("generation") != "ENV-20261117-06-supported-20261117T204102Z":
            raise ValidationError(f"ENV06 {lane} source gap has a different generation at line {line_number}")
        original_id = gap.get("original_id")
        if original_id not in by_id:
            raise ValidationError(f"ENV06 {lane} source gap has an unknown identity at line {line_number}")
        row_index, aggregate_row = by_id[original_id]
        expected_old_path = f".planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-{lane.upper()}-AGGREGATE-EVIDENCE.json"
        if gap.get("input_file") != expected_old_path or gap.get("input_sha256") != aggregate_hash:
            raise ValidationError(f"ENV06 {lane} source gap uses an unapproved historical input path/hash at line {line_number}")
        expected_lane_lock = aggregate.get("lock_sha256")
        expected_runtime = aggregate.get("runtime")
        if gap.get("lock_sha256") != expected_lane_lock or gap.get("runtime") != expected_runtime:
            raise ValidationError(f"ENV06 {lane} source gap lock/runtime differs from its preserved aggregate at line {line_number}")
        if any(gap.get(field) is not None for field in ("source_path", "source_sha256", "source_bytes", "source_span")):
            raise ValidationError(f"ENV06 {lane} unresolved source gap unexpectedly contains an observation at line {line_number}")
        pointer = gap.get("input_pointer")
        match = re.fullmatch(r"/identity_rows/([0-9]+)", pointer or "")
        if not match or int(match.group(1)) != row_index:
            raise ValidationError(f"ENV06 {lane} source gap row pointer does not resolve to its identity at line {line_number}")
        if gap.get("mfa") is None:
            raise ValidationError(f"ENV06 {lane} source gap lacks an MFA at line {line_number}")
        mfa = mfa_from_tuple(gap["mfa"], f"ENV06 {lane} source gap line {line_number}")
        if not isinstance(gap.get("membership_roles"), list) or not isinstance(gap.get("membership_selectors"), list):
            raise ValidationError(f"ENV06 {lane} source gap lacks exact membership selectors at line {line_number}")
        selector_roles = set()
        actual_selectors = []
        for selector in gap["membership_selectors"]:
            if not isinstance(selector, dict) or selector.get("path") != expected_old_path or selector.get("sha256") != aggregate_hash:
                raise ValidationError(f"ENV06 {lane} membership selector has a stale or unexpected path/hash at line {line_number}")
            role = selector.get("role")
            ptr = selector.get("pointer")
            pointer_match = re.fullmatch(r"/identity_rows/([0-9]+)/(baseline_mfas|live_mfas)/([0-9]+)", ptr or "")
            if not pointer_match or int(pointer_match.group(1)) != row_index:
                raise ValidationError(f"ENV06 {lane} selector does not resolve inside its identity row at line {line_number}")
            selector_row = aggregate["identity_rows"][row_index]
            field = pointer_match.group(2)
            selector_index = int(pointer_match.group(3))
            field_values = selector_row.get(field)
            if (role != ("baseline" if field == "baseline_mfas" else "live")
                    or not isinstance(field_values, list) or selector_index >= len(field_values)
                    or mfa_from_tuple(field_values[selector_index], f"ENV06 selector line {line_number}") != mfa):
                raise ValidationError(f"ENV06 {lane} selector value/role does not match its gap at line {line_number}")
            selector_roles.add(role)
            actual_selectors.append(ptr)
        expected_selectors = []
        for field, role in (("baseline_mfas", "baseline"), ("live_mfas", "live")):
            for selector_index, value in enumerate(aggregate_row.get(field, [])):
                if mfa_from_tuple(value, f"saved {lane} {original_id} {field}") == mfa:
                    expected_selectors.append(f"/identity_rows/{row_index}/{field}/{selector_index}")
        if sorted(actual_selectors) != sorted(expected_selectors):
            raise ValidationError(f"ENV06 {lane} source gap selector pointers are incomplete or duplicated at line {line_number}")
        if selector_roles != set(gap["membership_roles"]):
            raise ValidationError(f"ENV06 {lane} selector roles differ from recorded roles at line {line_number}")
        key = (original_id, mfa)
        if key in all_source:
            raise ValidationError(f"ENV06 {lane} source gap key is duplicated at line {line_number}")
        all_source[key] = {"line": line_number, "row": gap, "row_index": row_index}
        if "live" in selector_roles:
            result[key] = all_source[key]

    saved_live = set()
    for row in aggregate["identity_rows"]:
        identity = row["identity"]["id"]
        for value in row["live_mfas"]:
            saved_live.add((identity, mfa_from_tuple(value, f"saved {lane} live MFA")))
    if set(result) != saved_live:
        raise ValidationError(f"ENV06 {lane} source-gap live memberships do not exactly match saved live rows")
    return result, all_source


def accepted_gap_inventory(gap_rows: list[dict]) -> dict:
    counts = Counter()
    for line_number, row in enumerate(gap_rows, 1):
        lane = row.get("lane")
        domain = row.get("domain")
        if lane not in ("core", "floor") or domain not in ("source", "caller", "unknown_target_set"):
            raise ValidationError(f"ENV06 gap has an unsupported lane/domain at line {line_number}")
        counts[(lane, domain)] += 1
    return {
        "rows": sum(counts.values()),
        "counts_by_lane_and_domain": {
            lane: {domain: counts[(lane, domain)] for domain in ("source", "caller", "unknown_target_set")}
            for lane in ("core", "floor")
        },
    }


def build_lane_rows(aggregate: dict, lane: str, export_map: dict | None, aggregate_hash: str,
                    current_generation: str, gap_live_map: dict,
                    known_mfas: set[tuple[str, str, int]]) -> tuple[list[dict], set[tuple[str, str, int]], list[str]]:
    output = []
    errors = []
    all_live = set()
    for row_index, saved in enumerate(aggregate["identity_rows"]):
        identity = saved["identity"]
        identity_id = identity["id"]
        row_errors = []
        raw_lane_matches = identity.get("lane_matches")
        lane_matches = raw_lane_matches or {"core": [], "floor": []}
        parsed_lane_matches = {}
        raw_unparseable = {}
        all_known = set()
        for lane_name in ("core", "floor"):
            parsed, bad = parse_values(lane_matches[lane_name], mfa_from_text,
                                       f"{lane} {identity_id} lane_matches.{lane_name}", known_mfas)
            parsed_lane_matches[lane_name] = [mfa_json(mfa) for mfa in parsed]
            if bad:
                raw_unparseable[f"lane_matches.{lane_name}"] = bad
                row_errors.append(f"{lane} {identity_id} has an unparseable lane_matches.{lane_name} value")
        field_reports = {}
        field_values = {}
        for field in MFA_FIELDS:
            parsed, bad = parse_values(saved[field], mfa_from_tuple, f"{lane} {identity_id} {field}")
            if bad:
                raw_unparseable[field] = bad
                row_errors.append(f"{lane} {identity_id} has an unparseable {field} value")
            field_values[field] = set(parsed)
            all_known.update(parsed)
            checks = []
            for mfa_index, mfa in enumerate(parsed):
                present_export = export_map.get(mfa) if export_map is not None else None
                check = {
                    "mfa": mfa_json(mfa),
                    "status": ("present" if present_export else "missing") if export_map is not None else "retained_env06_row_value_no_floor_rescan",
                    "package_identity": package_identity(present_export) if present_export else None,
                }
                if export_map is None:
                    check["membership_evidence"] = {
                        "path": relpath(FLOOR_AGGREGATE), "sha256": aggregate_hash,
                        "pointer": f"/identity_rows/{row_index}/{field}/{mfa_index}",
                        "claim": "retained accepted row value; no current floor presence claim",
                    }
                checks.append(check)
            field_reports[field] = {
                "saved_values": saved[field], "parsed_values": [mfa_json(mfa) for mfa in parsed],
                "checks": checks, "unparseable_values": bad,
                "comparison_scope": "fresh_current_core_exports" if export_map is not None else "retained_env06_row_only_no_floor_rescan",
            }

        selected_matches, selected_bad = parse_values(lane_matches[lane], mfa_from_text,
                                                      f"{lane} {identity_id} lane_matches.{lane}", known_mfas)
        if selected_bad:
            raw_unparseable[f"lane_matches.{lane}"] = selected_bad
            row_errors.append(f"{lane} {identity_id} has an unparseable lane_matches.{lane} value")
        all_known.update(selected_matches)
        saved_live = field_values["live_mfas"]
        lane_match_checks = {}
        for lane_name in ("core", "floor"):
            parsed, bad = parse_values(lane_matches[lane_name], mfa_from_text,
                                       f"{lane} {identity_id} lane_matches.{lane_name}", known_mfas)
            checks = []
            for mfa in parsed:
                matched_export = export_map.get(mfa) if export_map is not None and lane_name == "core" else None
                if export_map is not None and lane_name == "core":
                    status = "present" if matched_export else "missing"
                elif lane_name == lane and mfa in saved_live:
                    status = "accepted_env06_saved_live_membership" if lane == "floor" else "saved_live"
                elif lane_name == lane:
                    status = "accepted_env06_saved_not_live_membership" if lane == "floor" else "saved_not_live"
                else:
                    status = "not_compared_other_lane"
                checks.append({"mfa": mfa_json(mfa), "status": status,
                               "package_identity": package_identity(matched_export) if matched_export else None})
            lane_match_checks[lane_name] = {"raw_values": lane_matches[lane_name],
                                            "parsed_values": [mfa_json(mfa) for mfa in parsed],
                                            "checks": checks, "unparseable_values": bad}
        live_with_current = set()
        if export_map is not None:
            for mfa in saved_live:
                if mfa in export_map:
                    live_with_current.add(mfa)
                else:
                    row_errors.append(f"core {identity_id} saved live MFA is absent from current exports: {mfa!r}")
        else:
            for mfa in saved_live:
                if (identity_id, mfa) not in gap_live_map:
                    row_errors.append(f"floor {identity_id} saved live MFA lacks its accepted ENV06 live source-gap row: {mfa!r}")
        all_live.update((identity_id, mfa) for mfa in saved_live)
        current_known_additions = []
        removed_live = []
        if export_map is not None:
            current_known_additions = [{"mfa": mfa_json(mfa), "package_identity": package_identity(export_map[mfa])}
                                       for mfa in sorted((all_known & export_map.keys()) - saved_live)]
            removed_live = [mfa_json(mfa) for mfa in sorted(saved_live - export_map.keys())]

        record = {
            "schema": "fablebook.phase7.row-membership/1", "lane": lane,
            "lane_generation": current_generation if lane == "core" else "ENV-20261117-06-supported-20261117T204102Z",
            "membership_source": "fresh_compiled_exports" if lane == "core" else "accepted_ENV06_rows_not_rescanned",
            "source_aggregate": {"path": relpath(CORE_AGGREGATE if lane == "core" else FLOOR_AGGREGATE), "sha256": aggregate_hash, "row_pointer": f"/identity_rows/{row_index}"},
            "identity_id": identity_id, "identity": identity, "saved_row": saved,
            "raw_lane_matches": raw_lane_matches, "parsed_lane_matches": parsed_lane_matches,
            "lane_match_checks": lane_match_checks,
            "mfa_fields": field_reports, "saved_live_mfas": saved["live_mfas"],
            "current_known_additions": current_known_additions,
            "removed_saved_live_mfas": removed_live,
            "raw_unparseable_values": raw_unparseable,
            "membership_status": "reconciled" if not row_errors else "review_required",
        }
        if lane == "floor":
            record["accepted_live_gap_refs"] = [
                {"identity_id": identity_id, "mfa": mfa_json(mfa), "path": relpath(ENV06_TYPED_GAPS), "line": gap_live_map[(identity_id, mfa)]["line"], "generation": "ENV-20261117-06-supported-20261117T204102Z"}
                for mfa in sorted(saved_live)
            ]
        output.append(record)
        errors.extend(row_errors)
    return output, all_live, errors


def make_phase7_typed_gaps(core_aggregate: dict, floor_aggregate: dict, core_exports: dict,
                           current_generation: str, aggregate_hashes: dict, gap_maps: dict,
                           source_gap_map: dict) -> list[dict]:
    result = []
    for lane, aggregate, export_map in (("core", core_aggregate, core_exports), ("floor", floor_aggregate, None)):
        aggregate_path = CORE_AGGREGATE if lane == "core" else FLOOR_AGGREGATE
        expected_generation = current_generation if lane == "core" else "ENV-20261117-06-supported-20261117T204102Z"
        for row_index, saved in enumerate(aggregate["identity_rows"]):
            identity_id = saved["identity"]["id"]
            for mfa_index, raw_mfa in enumerate(saved["live_mfas"]):
                mfa = mfa_from_tuple(raw_mfa, f"{lane} live typed gap")
                old = gap_maps[lane].get((identity_id, mfa))
                if old is None:
                    raise ValidationError(f"{lane} live source gap is missing for {identity_id} {mfa!r}")
                exported = export_map.get(mfa) if export_map is not None else None
                result.append({
                    "schema_version": "fablebook.phase7.typed-source-gap/1",
                    "generation": expected_generation, "lane": lane, "domain": "source",
                    "gap_key": f"{lane}|{identity_id}|{mfa[0]}|{mfa[1]}|{mfa[2]}|source",
                    "identity_id": identity_id, "mfa": mfa_json(mfa),
                    "evidence_status": "blocked_unresolved" if old["row"].get("source_path") is None else old["row"].get("evidence_status"),
                    "source_path": None, "source_sha256": None, "source_bytes": None, "source_span": None,
                    "reason": old["row"].get("reason"), "remedy": old["row"].get("remedy"),
                    "preserved_env06_gap": {"path": relpath(ENV06_TYPED_GAPS), "line": old["line"], "generation": old["row"]["generation"], "gap_key": old["row"]["gap_key"]},
                    "membership_pointer": {"path": relpath(aggregate_path), "sha256": aggregate_hashes[lane], "pointer": f"/identity_rows/{row_index}/live_mfas/{mfa_index}"},
                    "current_core_export": package_identity(exported) if exported else None,
                    "floor_reuse_note": "accepted ENV06 membership; no floor build or BEAM files were scanned" if lane == "floor" else None,
                })
    result.sort(key=lambda row: (row["lane"], row["identity_id"], row["mfa"][0], row["mfa"][1], row["mfa"][2]))
    return result


def validate_current_generation() -> int:
    inputs = load_phase_inputs()
    accepted = validate_saved_envelopes(inputs)
    core_aggregate = inputs["json"]["core_aggregate"]
    floor_aggregate = inputs["json"]["floor_aggregate"]
    validate_aggregate_rows(core_aggregate, "core")
    validate_aggregate_rows(floor_aggregate, "floor")

    export_map, export_summary, beam_rows = validate_current_export_records(inputs)
    current_generation = export_summary["generation_id"]
    aggregate_hashes = {
        "core": sha256(inputs["records"]["core_aggregate"][1]),
        "floor": sha256(inputs["records"]["floor_aggregate"][1]),
    }
    gap_rows = inputs["jsonl"]["env06_typed_gaps"]
    gap_maps, all_gap_maps = {}, {}
    for lane, aggregate in (("core", core_aggregate), ("floor", floor_aggregate)):
        gap_maps[lane], all_gap_maps[lane] = typed_gap_live_rows(gap_rows, aggregate, lane, aggregate_hashes[lane])

    known_mfas = set(export_map)
    for aggregate in (core_aggregate, floor_aggregate):
        for identity_row in aggregate["identity_rows"]:
            for field in ("baseline_mfas", "live_mfas"):
                known_mfas.update(mfa_from_tuple(value, f"saved {field} MFA") for value in identity_row[field])

    core_rows, core_live, core_errors = build_lane_rows(core_aggregate, "core", export_map, aggregate_hashes["core"], current_generation, gap_maps["core"], known_mfas)
    floor_rows, floor_live, floor_errors = build_lane_rows(floor_aggregate, "floor", None, aggregate_hashes["floor"], current_generation, gap_maps["floor"], known_mfas)
    errors = core_errors + floor_errors
    current_typed_gaps = make_phase7_typed_gaps(core_aggregate, floor_aggregate, export_map, current_generation,
                                               aggregate_hashes, gap_maps, all_gap_maps)
    accepted_gap_counts = accepted_gap_inventory(gap_rows)
    core_data = canonical_jsonl(core_rows)
    floor_data = canonical_jsonl(floor_rows)
    gaps_data = canonical_jsonl(current_typed_gaps)
    associations_data = b""

    records = inputs["records"]
    input_manifest = {key: input_record(path, data) for key, (path, data) in sorted(records.items())}
    outputs_data = {
        ROW_MEMBERSHIP.name: core_data,
        FLOOR_MEMBERSHIP.name: floor_data,
        TYPED_GAPS.name: gaps_data,
        ASSOCIATIONS.name: associations_data,
    }
    status = "pass" if not errors else "blocked_membership_mismatch"
    provenance = {
        "schema": "fablebook.phase7.current_membership_provenance/1",
        "status": status,
        "created_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "generation": current_generation,
        "core": {
            "lock_sha256": EXPECTED_CURRENT_CORE_LOCK_SHA256,
            "tool_versions_sha256": EXPECTED_CURRENT_CORE_TOOL_SHA256,
            "mix_exs_sha256": EXPECTED_CURRENT_CORE_MIX_SHA256,
            "otp_version": "29.1.2", "elixir_version": "1.20.4-otp-29",
            "producer_sha256": export_summary["producer_sha256"],
            "manifest_sha256": export_summary["manifest_sha256"],
            "root_summary_sha256": sha256(records["core_roots"][1]),
            "exports_jsonl_sha256": sha256(records["core_exports"][1]),
            "exports_mfa_sha256": export_summary["exports_mfa_sha256"],
            "resolved_runtime_roots": inputs["jsonl"]["core_manifest"][0].get("resolved_roots"),
            "compiled_beam_count": len(beam_rows),
            "export_count": len(inputs["jsonl"]["core_exports"]),
        },
        "floor": {
            "lane_generation": "ENV-20261117-06-supported-20261117T204102Z",
            "lock_sha256": EXPECTED_FLOOR_LOCK_SHA256,
            "runtime": {"elixir": "1.18.5", "otp": "27.3.4.9"},
            "tool_versions_sha256": sha256(records["floor_tool_versions"][1]),
            "membership_source": "accepted ENV06 rows and live source-gap selectors; no floor scan",
        },
        "rows": {"core": len(core_rows), "floor": len(floor_rows),
                 "core_saved_live_memberships": len(core_live), "floor_saved_live_memberships": len(floor_live),
                 "source_gaps": len(current_typed_gaps), "source_associations": 0},
        "accepted_env06_gap_inventory": {
            "path": relpath(ENV06_TYPED_GAPS),
            "sha256": sha256(records["env06_typed_gaps"][1]),
            **accepted_gap_counts,
        },
        "phase7_gap_output_scope": {
            "included": "one unresolved source-domain row for each saved live MFA in each lane",
            "included_by_lane": {"core": len(gap_maps["core"]), "floor": len(gap_maps["floor"])},
            "omitted_baseline_only_source_rows": {
                lane: len(all_gap_maps[lane]) - len(gap_maps[lane]) for lane in ("core", "floor")
            },
            "omitted_caller_rows": {lane: accepted_gap_counts["counts_by_lane_and_domain"][lane]["caller"]
                                    for lane in ("core", "floor")},
            "omitted_unknown_target_set_rows": {lane: accepted_gap_counts["counts_by_lane_and_domain"][lane]["unknown_target_set"]
                                                 for lane in ("core", "floor")},
            "not_a_full_env06_gap_restatement": True,
        },
        "scope_limits": {
            "whole_universe_historical_diff": "unavailable; saved whole-library receipt has only count and digest",
            "unknown_current_exports_outside_saved_rows": "not compared; no complete historic module list is available",
            "floor_build": "not rescanned; accepted ENV06 lock/runtime/rows are reused unchanged",
            "target_source_bodies_read": False,
            "target_functions_called": False,
            "candidate_selected": False,
            "implementation_authorized": False,
        },
        "preserved_stops": accepted["stops"],
        "errors": errors,
        "inputs": input_manifest,
        "outputs": {name: {"bytes": len(data), "sha256": sha256(data)} for name, data in sorted(outputs_data.items())},
        "counts_by_lane": {
            "core": {"identity_rows": 226, "row_live_mfas": sum(len(row["saved_live_mfas"]) for row in core_rows)},
            "floor": {"identity_rows": 226, "row_live_mfas": sum(len(row["saved_live_mfas"]) for row in floor_rows)},
        },
    }
    provenance_data = (json.dumps(provenance, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
    outputs_data[PROVENANCE.name] = provenance_data
    existing = [name for name in outputs_data if (PHASE / name).exists()]
    if existing:
        raise ValidationError(f"refusing to overwrite existing Phase 7 evidence: {', '.join(sorted(existing))}")
    for name, data in outputs_data.items():
        write_new(name, data)
    if errors:
        print(f"STOP: {len(errors)} saved-row membership issue(s) recorded; no family or source schedule was created.", file=sys.stderr)
        for item in errors[:20]:
            print(f"- {item}", file=sys.stderr)
        return 1
    print("PASS: 226 core rows match the fresh compiled exports; 226 floor rows match the accepted ENV06 generation.")
    print(f"Core saved-live MFA memberships: {sum(len(row['saved_live_mfas']) for row in core_rows)}")
    print(f"Floor accepted-live MFA memberships: {sum(len(row['saved_live_mfas']) for row in floor_rows)} (not rescanned)")
    print(f"Unresolved source-gap rows: {len(current_typed_gaps)}; target-source associations: 0")
    return 0


FAMILY_ROW_IDS = ["CN-002", "CN-003", "CN-004", "CN-005", "CN-006"]
SOURCE_BY_MFA = {
    ("Elixir.Phoenix.Digester", "compile", 3): ("phoenix", "lib/phoenix/digester.ex", "hex"),
    ("Elixir.Phoenix.LiveView.ColocatedAssets", "compile", 0): (
        "phoenix_live_view", "lib/phoenix_live_view/colocated_assets.ex", "hex"),
    ("Elixir.Plug.Builder", "compile", 3): ("plug", "lib/plug/builder.ex", "hex"),
    ("Elixir.Regex", "compile", 1): ("elixir", "lib/elixir/lib/regex.ex", "elixir"),
    ("Elixir.Regex", "compile", 2): ("elixir", "lib/elixir/lib/regex.ex", "elixir"),
    ("re", "compile", 1): ("stdlib", "src/re.erl", "erlang"),
    ("re", "compile", 2): ("stdlib", "src/re.erl", "erlang"),
}
LANE_PINS = {
    "core": {
        "lock": "mix.lock", "lock_sha256": EXPECTED_CURRENT_CORE_LOCK_SHA256,
        "tool_versions_sha256": EXPECTED_CURRENT_CORE_TOOL_SHA256,
        "mix_exs_sha256": EXPECTED_CURRENT_CORE_MIX_SHA256,
        "elixir": "1.20.4-otp-29", "elixir_app": "1.20.4", "otp": "29.1.2", "stdlib_app": "8.1.1",
    },
    "floor": {
        "lock": "mix.floor.lock", "lock_sha256": EXPECTED_FLOOR_LOCK_SHA256,
        "tool_versions_sha256": None, "mix_exs_sha256": None,
        "elixir": "1.18.5-otp-27", "elixir_app": "1.18.5", "otp": "27.3.4.9", "stdlib_app": "6.2.2.3",
    },
}
HEX_PACKAGE_VERSIONS = {
    "core": {"phoenix": "1.8.16", "phoenix_live_view": "1.2.13", "plug": "1.20.4"},
    "floor": {"phoenix": "1.8.9", "phoenix_live_view": "1.2.9", "plug": "1.20.3"},
}


def canonical_membership_bytes(lane: str, members: list[dict]) -> bytes:
    values = sorted((lane, item["identity_id"], *item["mfa"]) for item in members)
    return b"".join((json.dumps(list(value), separators=(",", ":"), ensure_ascii=True) + "\n").encode() for value in values)


def canonical_membership_digest(lane: str, members: list[dict]) -> str:
    return sha256(canonical_membership_bytes(lane, members))


def source_stat(path: Path) -> dict:
    try:
        resolved = path.resolve(strict=True)
        info = os.stat(resolved, follow_symlinks=False)
    except OSError as exc:
        raise ValidationError(f"scheduled source path does not resolve: {path}: {exc}") from exc
    if not stat.S_ISREG(info.st_mode):
        raise ValidationError(f"scheduled source path is not a regular file: {resolved}")
    if info.st_size < 0 or info.st_size > 2 * 1024 * 1024:
        raise ValidationError(f"scheduled source file exceeds the 2 MiB one-read cap: {resolved}")
    return {
        "declared_path": str(path.absolute()), "resolved_path": str(resolved),
        "device": info.st_dev, "inode": info.st_ino, "size_bytes": info.st_size,
        "mtime_ns": info.st_mtime_ns, "ctime_ns": info.st_ctime_ns,
    }


def locked_hex_packages(data: bytes, label: str) -> dict[str, tuple[str, list[str]]]:
    pattern = re.compile(
        r'^\s*"([a-z0-9_]+)"\s*:\s*\{:hex,\s*:[a-z0-9_]+,\s*'
        r'"([^"\\]+)",\s*"([0-9a-f]{64})".*?"([0-9a-f]{64})"\s*\},?\s*$'
    )
    packages = {}
    try:
        lines = data.decode("utf-8", "strict").splitlines()
    except UnicodeDecodeError as exc:
        raise ValidationError(f"{label} is not UTF-8") from exc
    for line in lines:
        if not line.lstrip().startswith('"'):
            continue
        match = pattern.fullmatch(line)
        if not match:
            raise ValidationError(f"unsupported Hex lock entry while binding schedule: {label}")
        name, version, package_checksum, repo_checksum = match.groups()
        if name in packages:
            raise ValidationError(f"duplicate Hex lock entry in {label}: {name}")
        packages[name] = (version, [package_checksum, repo_checksum])
    return packages


def validate_recorded_current_generation(inputs: dict) -> tuple[list[dict], list[dict], dict, dict]:
    provenance = read_json(PROVENANCE)
    expect(provenance.get("status") == "pass", "current generation is not a passing saved receipt")
    for path in (ROW_MEMBERSHIP, FLOOR_MEMBERSHIP, TYPED_GAPS, ASSOCIATIONS):
        recorded = provenance.get("outputs", {}).get(path.name)
        expect(isinstance(recorded, dict) and recorded.get("sha256") == digest(path),
               f"current generation output changed after receipt: {path.name}")
    core_rows, core_data = read_jsonl_bytes(ROW_MEMBERSHIP, 32 * 1024 * 1024)
    floor_rows, floor_data = read_jsonl_bytes(FLOOR_MEMBERSHIP, 32 * 1024 * 1024)
    expect(len(core_rows) == len(floor_rows) == 226, "current core and retained floor maps must each contain 226 rows")
    expect(provenance.get("outputs", {}).get(ROW_MEMBERSHIP.name, {}).get("sha256") == sha256(core_data),
           "core row membership digest differs from provenance")
    expect(provenance.get("outputs", {}).get(FLOOR_MEMBERSHIP.name, {}).get("sha256") == sha256(floor_data),
           "floor row membership digest differs from provenance")
    return core_rows, floor_rows, provenance, inputs["json"]["core_export_summary"]


def source_target_path(lane: str, package: str, relative_path: str, runtime_kind: str) -> Path:
    if runtime_kind == "hex":
        return ROOT / "_build" / "lanes" / lane / "deps" / package / relative_path
    asdf_root = os.environ.get("ASDF_DATA_DIR")
    if not asdf_root:
        raise ValidationError("ASDF_DATA_DIR is missing; exact runtime source path cannot be pinned")
    pin = LANE_PINS[lane]
    if runtime_kind == "elixir":
        return Path(asdf_root) / "installs" / "elixir" / pin["elixir"] / "lib" / "elixir" / "lib" / "regex.ex"
    if runtime_kind == "erlang":
        return Path(asdf_root) / "installs" / "erlang" / pin["otp"] / "lib" / f"stdlib-{pin['stdlib_app']}" / relative_path
    raise ValidationError(f"unsupported scheduled source kind: {runtime_kind}")


def build_scope_and_schedule() -> int:
    inputs = load_phase_inputs()
    accepted = validate_saved_envelopes(inputs)
    export_map, export_summary, _ = validate_current_export_records(inputs)
    core_rows, floor_rows, current_provenance, _ = validate_recorded_current_generation(inputs)
    expect(current_provenance.get("preserved_stops") == accepted["stops"],
           "current generation does not preserve the exact inherited stop set")

    lane_rows = {"core": core_rows, "floor": floor_rows}
    membership_by_lane = {}
    row_line_by_lane = {}
    row_map_by_lane = {}
    for lane, rows in lane_rows.items():
        members = []
        row_map = {}
        for line_number, row in enumerate(rows, 1):
            identity_id = row.get("identity_id")
            expect(isinstance(identity_id, str) and identity_id and identity_id not in row_map,
                   f"{lane} membership has an invalid or duplicate identity row")
            expect(row.get("membership_status") == "reconciled", f"{lane} row is not reconciled: {identity_id}")
            row_map[identity_id] = row
            row_line_by_lane.setdefault(lane, {})[identity_id] = line_number
            seen = set()
            for raw_mfa in row.get("saved_live_mfas", []):
                mfa = mfa_from_tuple(raw_mfa, f"{lane} saved live membership {identity_id}")
                expect(mfa not in seen, f"duplicate {lane} saved-live MFA in {identity_id}")
                seen.add(mfa)
                if lane == "core":
                    checks = row["mfa_fields"]["live_mfas"]["checks"]
                    status_by_mfa = {tuple(check["mfa"]): check.get("status") for check in checks}
                    expect(status_by_mfa.get(mfa) == "present", f"core live MFA is not present in fresh exports: {identity_id} {mfa}")
                else:
                    checks = row["mfa_fields"]["live_mfas"]["checks"]
                    status_by_mfa = {tuple(check["mfa"]): check.get("status") for check in checks}
                    expect(status_by_mfa.get(mfa) == "retained_env06_row_value_no_floor_rescan",
                           f"floor live MFA is not labeled as retained ENV06 evidence: {identity_id} {mfa}")
                members.append({"identity_id": identity_id, "mfa": mfa_json(mfa)})
        members.sort(key=lambda item: (item["identity_id"], *item["mfa"]))
        membership_by_lane[lane] = members
        row_map_by_lane[lane] = row_map

    family_by_lane = {}
    for lane in ("core", "floor"):
        selected = []
        for identity_id in FAMILY_ROW_IDS:
            row = row_map_by_lane[lane].get(identity_id)
            expect(row is not None, f"selected {lane} family row is absent: {identity_id}")
            identity = row["identity"]
            expect(identity.get("identity_class") == "exclusion" and identity.get("original_reason_raw") == ":not_compile_module",
                   f"selected {lane} family row does not have the common exclusion rationale: {identity_id}")
            expect(row.get("saved_live_mfas"), f"selected family row has no saved-live member: {lane} {identity_id}")
            for raw_mfa in row["saved_live_mfas"]:
                mfa = mfa_from_tuple(raw_mfa, f"selected family row {lane} {identity_id}")
                expect(mfa in SOURCE_BY_MFA, f"selected family MFA lacks an exact source mapping: {mfa}")
                selected.append({"identity_id": identity_id, "mfa": mfa_json(mfa)})
        selected.sort(key=lambda item: (item["identity_id"], *item["mfa"]))
        expect(len(selected) == 7, f"selected family must contain exactly seven {lane} memberships")
        family_by_lane[lane] = selected
    expect(family_by_lane["core"] == family_by_lane["floor"], "the two lanes do not have identical proposed family membership")

    family_keys = {lane: {(item["identity_id"], tuple(item["mfa"])) for item in family_by_lane[lane]} for lane in lane_rows}
    complete_by_lane = {lane: {(item["identity_id"], tuple(item["mfa"])) for item in membership_by_lane[lane]} for lane in lane_rows}
    complement_by_lane = {}
    for lane in lane_rows:
        expect(family_keys[lane] <= complete_by_lane[lane], f"{lane} family includes a non-member")
        complement = [item for item in membership_by_lane[lane]
                      if (item["identity_id"], tuple(item["mfa"])) not in family_keys[lane]]
        expect(not (family_keys[lane] & {(item["identity_id"], tuple(item["mfa"])) for item in complement}),
               f"{lane} family and complement overlap")
        expect(family_keys[lane] | {(item["identity_id"], tuple(item["mfa"])) for item in complement} == complete_by_lane[lane],
               f"{lane} family and complement do not cover complete membership")
        complement_by_lane[lane] = complement

    old_bytes = read_capped(RECONCILIATION, 16 * 1024 * 1024)
    prior_bytes = read_capped(PRIOR_RECONCILIATION, 16 * 1024 * 1024)
    expect(old_bytes == prior_bytes, "prior stop copy does not preserve the original reconciliation byte-for-byte")
    prior_obj = json.loads(prior_bytes, object_pairs_hook=unique_object)
    expect(prior_obj.get("preserved_stops", {}).get("candidate") is None,
           "prior stop record no longer carries candidate=null")
    prior_sha = sha256(prior_bytes)

    schedule_entries = []
    member_by_file_lane = {}
    for lane in ("core", "floor"):
        for member in family_by_lane[lane]:
            mfa = tuple(member["mfa"])
            package, relative_path, runtime_kind = SOURCE_BY_MFA[mfa]
            key = (lane, package, relative_path, runtime_kind)
            member_by_file_lane.setdefault(key, []).append(member)
    expect(len(member_by_file_lane) == 10, "selected family must map to exactly five unique source files per lane")

    core_locks = locked_hex_packages(inputs["records"]["core_lock"][1], "mix.lock")
    floor_locks = locked_hex_packages(inputs["records"]["floor_lock"][1], "mix.floor.lock")
    lane_locks = {"core": core_locks, "floor": floor_locks}
    lane_membership_file = {"core": ROW_MEMBERSHIP, "floor": FLOOR_MEMBERSHIP}
    lane_membership_digest = {"core": digest(ROW_MEMBERSHIP), "floor": digest(FLOOR_MEMBERSHIP)}
    lane_pin_hashes = {
        "core": {"lock_sha256": EXPECTED_CURRENT_CORE_LOCK_SHA256, "tool_versions_sha256": EXPECTED_CURRENT_CORE_TOOL_SHA256,
                 "mix_exs_sha256": EXPECTED_CURRENT_CORE_MIX_SHA256},
        "floor": {"lock_sha256": EXPECTED_FLOOR_LOCK_SHA256, "tool_versions_sha256": sha256(inputs["records"]["floor_tool_versions"][1]),
                  "mix_exs_sha256": None},
    }

    for lane in ("core", "floor"):
        sorted_file_keys = sorted(key for key in member_by_file_lane if key[0] == lane)
        for index, (entry_lane, package, relative_path, runtime_kind) in enumerate(sorted_file_keys, 1):
            members = sorted(member_by_file_lane[(entry_lane, package, relative_path, runtime_kind)],
                             key=lambda item: (item["identity_id"], *item["mfa"]))
            selectors = []
            associations = []
            for member in members:
                mfa = tuple(member["mfa"])
                row = row_map_by_lane[lane][member["identity_id"]]
                selectors.append({"identity_id": member["identity_id"], "mfa": member["mfa"]})
                association = {"identity_id": member["identity_id"], "mfa": member["mfa"],
                               "membership_artifact": relpath(lane_membership_file[lane]),
                               "membership_artifact_sha256": lane_membership_digest[lane],
                               "membership_line": row_line_by_lane[lane][member["identity_id"]],
                               "membership_field": "/saved_live_mfas"}
                if lane == "floor":
                    checks = row["mfa_fields"]["live_mfas"]["checks"]
                    evidence = next(check.get("membership_evidence") for check in checks if tuple(check["mfa"]) == mfa)
                    association["accepted_floor_evidence"] = evidence
                else:
                    export = export_map.get(mfa)
                    expect(export is not None, f"current export missing scheduled core member: {mfa}")
                    association["compiled_export"] = package_identity(export)
                associations.append(association)

            pin = LANE_PINS[lane]
            if runtime_kind == "hex":
                version, checksums = lane_locks[lane].get(package, (None, None))
                expect(version == HEX_PACKAGE_VERSIONS[lane][package] and checksums,
                       f"{lane} source package is not pinned to the expected lock identity: {package}")
                if lane == "core":
                    expected_export = export_map[tuple(members[0]["mfa"])]
                    expect(expected_export["package"] == package and expected_export["package_version"] == version
                           and expected_export["lock_checksums"] == checksums,
                           f"core source package differs from current compiled export identity: {package}")
                package_identity_record = {
                    "kind": "hex", "app": package, "package": package, "version": version,
                    "lock_file": pin["lock"], "lock_sha256": pin["lock_sha256"],
                    "package_checksum": checksums[0], "repo_checksum": checksums[1],
                }
                declared = ROOT / "_build" / "lanes" / lane / "deps" / package / relative_path
            elif runtime_kind == "elixir":
                package_identity_record = {
                    "kind": "elixir_runtime", "app": "elixir", "app_version": pin["elixir_app"],
                    "release": pin["elixir"], "lock_file": pin["lock"], "lock_sha256": pin["lock_sha256"],
                    "runtime_versions": {"elixir": pin["elixir_app"], "otp": pin["otp"]},
                    "tool_versions_sha256": lane_pin_hashes[lane]["tool_versions_sha256"],
                }
                declared = source_target_path(lane, package, relative_path, "elixir")
            else:
                package_identity_record = {
                    "kind": "otp_runtime", "app": "stdlib", "app_version": pin["stdlib_app"],
                    "release": pin["otp"], "lock_file": pin["lock"], "lock_sha256": pin["lock_sha256"],
                    "runtime_versions": {"elixir": pin["elixir_app"], "otp": pin["otp"]},
                    "tool_versions_sha256": lane_pin_hashes[lane]["tool_versions_sha256"],
                }
                declared = source_target_path(lane, package, relative_path, "erlang")
            path_facts = source_stat(declared)
            request_id = f"{lane}-source-{index:02}"
            schedule_entries.append({
                "request_id": request_id, "lane": lane, "batch": "01" if lane == "core" else "02",
                "declared_path": shortened_home_path(path_facts["declared_path"]),
                "target_path": shortened_home_path(path_facts["resolved_path"]),
                "source_identity": package_identity_record,
                "mfa_span_selectors": selectors, "member_associations": associations,
                "purpose": "Record bounded definition and same-file static reference evidence for this evidence-family member; not candidate-fit evidence.",
                "provenance_reference": {
                    "generation": current_provenance["generation"] if lane == "core" else "ENV-20261117-06-supported-20261117T204102Z",
                    "membership_artifact": relpath(lane_membership_file[lane]),
                    "membership_artifact_sha256": lane_membership_digest[lane],
                },
                "one_use": True, "truncation": "forbidden", "max_read_bytes": 2 * 1024 * 1024,
                "expected_file_stat": {key: value for key, value in path_facts.items()
                                       if key in ("device", "inode", "size_bytes", "mtime_ns", "ctime_ns")},
                "content_sha256": None, "content_sha256_capture": "one-use observation only",
            })

    expect(len(schedule_entries) == 10 and len({row["target_path"] for row in schedule_entries}) == 10,
           "source schedule does not contain ten unique exact paths")
    schedule = {
        "schema": "fablebook.phase7.source_schedule/1", "status": "pending_independent_review",
        "family_id": "CN-002-CN-006-not-compile-module-exclusions",
        "scope": "Exact target paths and MFA selectors only; no target source bytes or content hashes have been read.",
        "lane_membership": {
            lane: {"artifact": relpath(lane_membership_file[lane]), "sha256": lane_membership_digest[lane],
                   "count": len(membership_by_lane[lane]), "family_count": len(family_by_lane[lane]),
                   "complement_count": len(complement_by_lane[lane]),
                   "family_sha256": canonical_membership_digest(lane, family_by_lane[lane]),
                   "complement_sha256": canonical_membership_digest(lane, complement_by_lane[lane])}
            for lane in ("core", "floor")
        },
        "limits": {"max_files_per_batch": 5, "max_files_total": 25, "no_globs": True,
                   "one_read_per_exact_file": True, "truncation": "forbidden", "no_runtime_calls": True},
        "batches": {batch: [row["request_id"] for row in schedule_entries if row["batch"] == batch]
                    for batch in ("01", "02", "03", "04", "05")},
        "entries": schedule_entries,
        "source_bodies_read": False,
    }
    schedule_bytes = (json.dumps(schedule, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
    schedule_sha = sha256(schedule_bytes)

    lanes = {}
    for lane in ("core", "floor"):
        pin = LANE_PINS[lane]
        lanes[lane] = {
            "identity": {"lock_file": pin["lock"], "lock_sha256": pin["lock_sha256"],
                         "tool_versions_sha256": lane_pin_hashes[lane]["tool_versions_sha256"],
                         "mix_exs_sha256": lane_pin_hashes[lane]["mix_exs_sha256"],
                         "elixir": pin["elixir_app"], "otp": pin["otp"],
                         "generation": current_provenance["generation"] if lane == "core" else "ENV-20261117-06-supported-20261117T204102Z",
                         "membership_source": "fresh_compiled_exports" if lane == "core" else "accepted_ENV06_rows_not_rescanned"},
            "membership": membership_by_lane[lane],
            "membership_count": len(membership_by_lane[lane]),
            "membership_sha256": canonical_membership_digest(lane, membership_by_lane[lane]),
            "family": family_by_lane[lane], "family_count": len(family_by_lane[lane]),
            "family_sha256": canonical_membership_digest(lane, family_by_lane[lane]),
            "complement": complement_by_lane[lane], "complement_count": len(complement_by_lane[lane]),
            "complement_sha256": canonical_membership_digest(lane, complement_by_lane[lane]),
            "partition": {"disjoint": True, "union_equals_membership": True},
        }
    cross_refs = []
    cn004 = row_map_by_lane["core"]["CN-004"]["identity"]
    refs = cn004.get("current_replacement_refs", [])
    for reference in refs:
        cross_refs.append({"from": "CN-004", "reference": reference,
                           "claim": "unresolved bounded cross-reference; target rows are not added to this family or its source schedule"})
    old_core_rows = inputs["json"]["core_aggregate"].get("identity_rows", [])
    old_by_id = {row.get("identity", {}).get("id"): row for row in old_core_rows}
    for target_id in ("EX-124", "EX-125"):
        row = old_by_id.get(target_id)
        if row:
            cross_refs.append({"row_id": target_id, "identity_class": row.get("identity", {}).get("identity_class"),
                               "live_mfas": row.get("live_mfas", []),
                               "current_replacement_refs": row.get("identity", {}).get("current_replacement_refs", []),
                               "claim": "saved row relationship preserved as unresolved context; no source inspection performed"})

    total_source_bytes = sum(row["expected_file_stat"]["size_bytes"] for row in schedule_entries)
    initial_sizing = {
        "complete_saved_live_memberships": {lane: lanes[lane]["membership_count"] for lane in ("core", "floor")},
        "proposed_family_memberships": {lane: lanes[lane]["family_count"] for lane in ("core", "floor")},
        "unique_target_files": len(schedule_entries), "nonempty_batches": 2, "empty_prepared_batches": 3,
        "scheduled_source_bytes_from_stat_only": total_source_bytes,
        "estimated_source_context_tokens": {
            "method": "Source file size metadata divided by 3.5 bytes/token, with a broad 3.0–4.5 byte/token range; no source bytes inspected yet.",
            "point_estimate": round(total_source_bytes / 3.5),
            "low": round(total_source_bytes / 4.5), "high": round(total_source_bytes / 3.0),
        },
        "effort": {"method": "Ten exact one-use file observations in two batches, one separate schedule review, then one join/validation pass.",
                   "estimate_hours": 3.0, "range_hours": [2.0, 5.0],
                   "uncertainty": "Parser span density and same-file reference counts are unknown until approved reads."},
        "refresh_after_reads": True,
    }
    reconciliation = {
        "schema": "fablebook.phase7.scope_reconciliation/1", "phase": "v0.6/7",
        "status": "family_partition_ready_schedule_review_pending",
        "prior_stop": {"path": relpath(PRIOR_RECONCILIATION), "sha256": prior_sha,
                       "preserved_byte_for_byte": True, "historical_status": prior_obj.get("status")},
        "accepted_evidence": {"receipt_path": relpath(ENV06_MANIFEST),
                              "generation": "ENV-20261117-06-supported-20261117T204102Z",
                              "core_membership_provenance": relpath(PROVENANCE),
                              "core_membership_provenance_sha256": digest(PROVENANCE)},
        "lanes": lanes,
        "canonical_membership_digest_recipe": "For each sorted member, encode compact UTF-8 JSON array [lane, identity_id, module, function, arity] plus LF; sort rows lexicographically by all five fields; SHA-256 the concatenated bytes.",
        "family_rationale": {
            "name": "CN-002 through CN-006: nonempty not-compile-module exclusions",
            "reason": "Five identity rows share exclusion class and :not_compile_module rationale; each has at least one saved-live compile MFA, yielding seven exact memberships in both lanes.",
            "scope_kind": "proposed evidence family only; not a code candidate, candidate fit, or implementation choice",
            "excluded_boundary": "CN-001 shares the exclusion rationale but has no live MFA in either lane, so it remains in the complement.",
            "cross_references": cross_refs,
        },
        "source_schedule": {"path": relpath(SOURCE_SCHEDULE), "sha256": schedule_sha,
                            "entry_count": len(schedule_entries), "review_status": "pending_independent_review"},
        "source_read_boundary": {"target_source_bodies_read": False, "recorded_source_paths_are_values_only": True,
                                 "runtime_apis_called": False, "generated_code_executed": False},
        "initial_sizing": initial_sizing,
        "preserved_stops": accepted["stops"],
        "owner_decision": {"required": True, "question": "After reviewing the bounded evidence, should any further guard increment be authorized?",
                           "recommendation": "Complete only the scheduled, independently reviewed source observations and present their bounded result. Then stop for the owner to decide; do not promote a candidate, close the aggregate gate, or start the Walking Skeleton."},
    }
    reconciliation_bytes = (json.dumps(reconciliation, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
    for name, data in ((SOURCE_SCHEDULE.name, schedule_bytes),):
        write_new(name, data)
    replace_phase_file_atomically(RECONCILIATION.name, reconciliation_bytes)
    print(f"PASS: exact family/complement partitions recorded for core ({len(family_by_lane['core'])}/{len(complement_by_lane['core'])}) and floor ({len(family_by_lane['floor'])}/{len(complement_by_lane['floor'])}).")
    print(f"PASS: source schedule contains {len(schedule_entries)} exact source files across batches 01–02; no source bodies read.")
    print(f"Schedule SHA-256: {schedule_sha}")
    return 0


def member_keys(members: list[dict], label: str) -> set[tuple[str, tuple[str, str, int]]]:
    keys = set()
    values = []
    for item in members:
        identity_id = item.get("identity_id")
        expect(isinstance(identity_id, str) and identity_id, f"{label} member has no identity ID")
        mfa = mfa_from_tuple(item.get("mfa"), label)
        key = (identity_id, mfa)
        expect(key not in keys, f"{label} contains a duplicate member: {key}")
        keys.add(key)
        values.append((identity_id, *mfa))
    expect(values == sorted(values), f"{label} is not canonically sorted")
    return keys


def validate_scope_partition(lane: str, membership: list[dict], family: list[dict], complement: list[dict],
                             counts: dict, digests: dict) -> None:
    expect(lane in ("core", "floor"), "partition has an unknown lane")
    full = member_keys(membership, f"{lane} complete membership")
    selected = member_keys(family, f"{lane} family")
    remainder = member_keys(complement, f"{lane} complement")
    expect(selected <= full, f"{lane} family contains a non-member")
    expect(remainder <= full, f"{lane} complement contains a non-member")
    expect(not (selected & remainder), f"{lane} family overlaps its complement")
    expect(selected | remainder == full, f"{lane} family and complement do not equal membership")
    expect(counts == {"membership": len(full), "family": len(selected), "complement": len(remainder)},
           f"{lane} partition counts do not match its member lists")
    expected = {"membership": canonical_membership_digest(lane, membership),
                "family": canonical_membership_digest(lane, family),
                "complement": canonical_membership_digest(lane, complement)}
    expect(digests == expected, f"{lane} partition digest drift")


def validate_preserved_stop_state(stops: dict) -> None:
    expect(stops == EXPECTED_PRESERVED_STOPS, "a protected stop differs from the approved inherited stop set")


def validate_no_retry_identity(batch: str, request_id: str) -> None:
    expect(batch == "01" and request_id == EXPECTED_NO_RETRY_REQUEST_ID,
           "no-retry failure is not the exact consumed core-source-01 request")


def validate_scope_artifacts(require_review: bool = False, require_approval: bool = False,
                              allow_observed_reads: bool = False) -> tuple[dict, dict, bytes, bytes, bytes | None]:
    validate_redaction_receipt()
    reconciliation_raw = read_capped(RECONCILIATION, 16 * 1024 * 1024)
    schedule_raw = read_capped(SOURCE_SCHEDULE, 4 * 1024 * 1024)
    reconciliation = json.loads(reconciliation_raw, object_pairs_hook=unique_object)
    schedule = json.loads(schedule_raw, object_pairs_hook=unique_object)
    expect(reconciliation.get("schema") == "fablebook.phase7.scope_reconciliation/1", "unexpected reconciliation schema")
    expect(schedule.get("schema") == "fablebook.phase7.source_schedule/1", "unexpected source-schedule schema")
    prior = reconciliation.get("prior_stop", {})
    expect(prior.get("path") == relpath(PRIOR_RECONCILIATION)
           and prior.get("sha256") == digest(PRIOR_RECONCILIATION)
           and prior.get("preserved_byte_for_byte") is True,
           "previous stopped reconciliation is not preserved byte-for-byte")
    current_schedule_sha = historical_digest(SOURCE_SCHEDULE)
    expect(reconciliation.get("source_schedule", {}).get("path") == relpath(SOURCE_SCHEDULE)
           and reconciliation.get("source_schedule", {}).get("sha256") == current_schedule_sha
           and reconciliation.get("source_schedule", {}).get("entry_count") == 10,
           "reconciliation does not bind the exact source schedule")
    validate_preserved_stop_state(reconciliation.get("preserved_stops"))
    boundary_read = reconciliation.get("source_read_boundary", {}).get("target_source_bodies_read")
    expect(((boundary_read is False or boundary_read is True) if allow_observed_reads else boundary_read is False)
           and schedule.get("source_bodies_read") is False,
           "source-read boundary or pre-read schedule state is invalid for this validation stage")
    expect(schedule.get("family_id") == "CN-002-CN-006-not-compile-module-exclusions",
           "schedule family identity differs")

    lanes = reconciliation.get("lanes", {})
    expect(set(lanes) == {"core", "floor"}, "reconciliation must keep exactly the core and floor lane records")
    for lane, lane_record in lanes.items():
        counts = {"membership": lane_record.get("membership_count"), "family": lane_record.get("family_count"),
                  "complement": lane_record.get("complement_count")}
        digests = {"membership": lane_record.get("membership_sha256"), "family": lane_record.get("family_sha256"),
                   "complement": lane_record.get("complement_sha256")}
        validate_scope_partition(lane, lane_record.get("membership", []), lane_record.get("family", []),
                                 lane_record.get("complement", []), counts, digests)
        expect(lane_record.get("partition") == {"disjoint": True, "union_equals_membership": True},
               f"{lane} partition proof flags are missing")
        expected_source = "fresh_compiled_exports" if lane == "core" else "accepted_ENV06_rows_not_rescanned"
        expect(lane_record.get("identity", {}).get("membership_source") == expected_source,
               f"{lane} membership provenance is incorrectly labeled")
        expect(set(item["identity_id"] for item in lane_record.get("family", [])) == set(FAMILY_ROW_IDS),
               f"{lane} family identity rows differ from the selected evidence family")
    schedule_lanes = schedule.get("lane_membership", {})
    expect(set(schedule_lanes) == {"core", "floor"}, "schedule lane identity set differs")
    for lane in ("core", "floor"):
        lane_record = lanes[lane]
        bound = schedule_lanes[lane]
        expect(bound.get("artifact") == relpath(ROW_MEMBERSHIP if lane == "core" else FLOOR_MEMBERSHIP)
               and bound.get("sha256") == digest(ROW_MEMBERSHIP if lane == "core" else FLOOR_MEMBERSHIP)
               and bound.get("count") == lane_record["membership_count"]
               and bound.get("family_count") == lane_record["family_count"]
               and bound.get("complement_count") == lane_record["complement_count"]
               and bound.get("family_sha256") == lane_record["family_sha256"]
               and bound.get("complement_sha256") == lane_record["complement_sha256"],
               f"{lane} schedule membership binding differs")

    entries = schedule.get("entries")
    expect(isinstance(entries, list) and len(entries) == 10, "schedule must contain exactly ten entries")
    requests, paths, scheduled_members = set(), set(), {"core": set(), "floor": set()}
    assignments = {batch: [] for batch in ("01", "02", "03", "04", "05")}
    lock_packages = {}
    for lane in ("core", "floor"):
        lock_path = ROOT / LANE_PINS[lane]["lock"]
        lock_data = read_capped(lock_path, 2 * 1024 * 1024)
        expect(sha256(lock_data) == LANE_PINS[lane]["lock_sha256"], f"{lane} lock identity changed")
        lock_packages[lane] = locked_hex_packages(lock_data, lock_path.name)
    asdf_root = os.environ.get("ASDF_DATA_DIR")
    expect(bool(asdf_root), "ASDF_DATA_DIR is missing while validating the exact schedule")

    for entry in entries:
        request_id = entry.get("request_id")
        lane, batch = entry.get("lane"), entry.get("batch")
        expect(isinstance(request_id, str) and len(request_id) <= 64
               and re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", request_id) is not None
               and request_id not in requests,
               "schedule has an unsafe, missing, or duplicate request ID")
        expect(lane in ("core", "floor") and batch in assignments, "schedule has an invalid lane or batch")
        expect(batch == ("01" if lane == "core" else "02"), "source entry is assigned to the wrong planned batch")
        requests.add(request_id)
        assignments[batch].append(request_id)
        target_path = entry.get("target_path")
        declared_path = entry.get("declared_path")
        expect(isinstance(target_path, str) and path_for_local_check(target_path).is_absolute()
               and not any(c in target_path for c in "*?[]"),
               "schedule path must be an exact file path without glob syntax")
        expect(target_path not in paths, "schedule repeats a target file path")
        paths.add(target_path)
        selectors = entry.get("mfa_span_selectors")
        associations = entry.get("member_associations")
        expect(isinstance(selectors, list) and selectors and isinstance(associations, list) and len(selectors) == len(associations),
               "schedule entry has no exact selectors or member associations")
        selector_pairs = []
        for selector, association in zip(selectors, associations):
            identity_id = selector.get("identity_id")
            mfa = mfa_from_tuple(selector.get("mfa"), f"schedule {request_id} selector")
            expect(association.get("identity_id") == identity_id and association.get("mfa") == list(mfa),
                   f"schedule member association differs from selector: {request_id}")
            key = (identity_id, mfa)
            expect(key not in scheduled_members[lane], f"family member has multiple scheduled reads in {lane}: {key}")
            scheduled_members[lane].add(key)
            selector_pairs.append((identity_id, mfa))
        expect(selector_pairs == sorted(selector_pairs, key=lambda item: (item[0], *item[1])),
               f"schedule selectors are not canonically sorted: {request_id}")
        source_matches = [mfa for mfa in SOURCE_BY_MFA if Path(SOURCE_BY_MFA[mfa][1]).name == Path(target_path).name]
        # Package/runtime identity is checked against the selected MFA's exact path recipe below.
        for identity_id, mfa in selector_pairs:
            expect(mfa in SOURCE_BY_MFA, f"schedule contains an unapproved family MFA: {mfa}")
            package, relative_path, source_kind = SOURCE_BY_MFA[mfa]
            expect(all(SOURCE_BY_MFA[item[1]][1:] == (relative_path, source_kind) for item in selector_pairs),
                   f"one scheduled file combines incompatible selectors: {request_id}")
            expected_path = source_target_path(lane, package, relative_path, source_kind)
            expected_stat = source_stat(expected_path)
            expect(declared_path == shortened_home_path(expected_stat["declared_path"])
                   and target_path == shortened_home_path(expected_stat["resolved_path"]),
                   f"schedule path is not the exact pinned source path: {request_id}")
            stat_expected = {key: expected_stat[key] for key in ("device", "inode", "size_bytes", "mtime_ns", "ctime_ns")}
            expect(entry.get("expected_file_stat") == stat_expected, f"schedule source metadata differs: {request_id}")
            identity = entry.get("source_identity", {})
            pin = LANE_PINS[lane]
            expect(identity.get("lock_file") == pin["lock"] and identity.get("lock_sha256") == pin["lock_sha256"],
                   f"schedule source identity is bound to the wrong lane lock: {request_id}")
            if source_kind == "hex":
                version, checksums = lock_packages[lane].get(package, (None, None))
                expect(version == HEX_PACKAGE_VERSIONS[lane][package]
                       and identity == {"kind": "hex", "app": package, "package": package, "version": version,
                                        "lock_file": pin["lock"], "lock_sha256": pin["lock_sha256"],
                                        "package_checksum": checksums[0], "repo_checksum": checksums[1]},
                       f"scheduled Hex package identity differs from pinned lock: {request_id}")
            elif source_kind == "elixir":
                expect(identity.get("kind") == "elixir_runtime" and identity.get("app") == "elixir"
                       and identity.get("app_version") == pin["elixir_app"] and identity.get("release") == pin["elixir"]
                       and identity.get("runtime_versions") == {"elixir": pin["elixir_app"], "otp": pin["otp"]},
                       f"scheduled Elixir runtime identity differs: {request_id}")
            else:
                expect(identity.get("kind") == "otp_runtime" and identity.get("app") == "stdlib"
                       and identity.get("app_version") == pin["stdlib_app"] and identity.get("release") == pin["otp"]
                       and identity.get("runtime_versions") == {"elixir": pin["elixir_app"], "otp": pin["otp"]},
                       f"scheduled OTP runtime identity differs: {request_id}")
            for field in ("one_use", "truncation", "content_sha256", "content_sha256_capture"):
                if field == "one_use":
                    expect(entry.get(field) is True, f"schedule does not mark one-use read: {request_id}")
                elif field == "truncation":
                    expect(entry.get(field) == "forbidden", f"schedule allows truncation: {request_id}")
                elif field == "content_sha256":
                    expect(entry.get(field) is None, f"content hash was captured before approval: {request_id}")
                else:
                    expect(entry.get(field) == "one-use observation only", f"schedule has invalid content-hash instruction: {request_id}")
            expect(entry.get("max_read_bytes") == 2 * 1024 * 1024,
                   f"schedule one-use read cap differs: {request_id}")
        expect(entry.get("provenance_reference", {}).get("membership_artifact_sha256")
               == schedule_lanes[lane].get("sha256"), f"schedule provenance row-map digest differs: {request_id}")
    for batch, ids in assignments.items():
        expect(len(ids) <= 5, f"batch {batch} exceeds five exact files")
    expect(scheduled_members["core"] == member_keys(lanes["core"]["family"], "core family")
           and scheduled_members["floor"] == member_keys(lanes["floor"]["family"], "floor family"),
           "source schedule does not cover every selected family member exactly once")
    expect(schedule.get("limits", {}).get("max_files_total") == 25
           and schedule.get("limits", {}).get("max_files_per_batch") == 5
           and schedule.get("limits", {}).get("no_globs") is True,
           "schedule caps are absent or differ from the approved plan")

    if require_review or require_approval:
        review = require_text(SCHEDULE_REVIEW)
        expect("**Verdict:** PASS" in review, "independent source-schedule review is not PASS")
        reviewed_digest = one(r"\*\*Reviewed schedule SHA-256:\*\* `([0-9a-f]{64})`", review,
                              "reviewed source-schedule digest")
        expect(reviewed_digest == current_schedule_sha, "schedule review covers a different digest")
        reviewer = one(r"\*\*Reviewer:\*\* ([^\n]+)", review, "independent reviewer")
        expect(reviewer.strip() and reviewer.strip() != "schedule author", "reviewer identity is empty or not independent")
        expect("**Target source bodies read:** no" in review, "schedule reviewer read target source bodies")
    approval_raw = None
    if require_approval:
        approval, approval_raw = read_json_bytes(SOURCE_APPROVAL, 64 * 1024)
        review = require_text(SCHEDULE_REVIEW)
        reviewer = one(r"\*\*Reviewer:\*\* ([^\n]+)", review, "independent reviewer").strip()
        request_ids = sorted(entry["request_id"] for entry in entries)
        expected_batches = {batch: sorted(assignments[batch]) for batch in assignments}
        expect(approval.get("schema") == "fablebook.phase7.source_read_approval/1"
               and approval.get("verdict") == "PASS"
               and approval.get("reviewer") == reviewer
               and approval.get("schedule_sha256") == current_schedule_sha
               and approval.get("review_sha256") == historical_digest(SCHEDULE_REVIEW)
               and approval.get("approved_request_ids") == request_ids
               and approval.get("batch_assignments") == expected_batches
               and approval.get("max_files_total") == 25,
               "source approval does not bind the exact review, schedule and complete batch assignment")
    inputs = load_phase_inputs()
    accepted = validate_saved_envelopes(inputs)
    expect(accepted["stops"] == reconciliation["preserved_stops"], "inherited stop state changed after schedule creation")
    current_rows, floor_rows, current_provenance, _ = validate_recorded_current_generation(inputs)
    expect(current_provenance.get("status") == "pass", "current generation no longer validates")
    for lane, rows in (("core", current_rows), ("floor", floor_rows)):
        expected_members = []
        rows_by_id = {}
        for row in rows:
            identity_id = row["identity_id"]
            rows_by_id[identity_id] = row
            expected_members.extend({"identity_id": identity_id, "mfa": list(mfa_from_tuple(mfa, f"{lane} saved live member"))}
                                    for mfa in row["saved_live_mfas"])
        expected_members.sort(key=lambda item: (item["identity_id"], *item["mfa"]))
        lane_record = lanes[lane]
        expect(lane_record["membership"] == expected_members,
               f"{lane} reconciliation membership differs from the hash-bound row map")
        expected_family = []
        for identity_id in FAMILY_ROW_IDS:
            row = rows_by_id[identity_id]
            expect(row["identity"].get("identity_class") == "exclusion"
                   and row["identity"].get("original_reason_raw") == ":not_compile_module",
                   f"{lane} selected family row rationale changed: {identity_id}")
            expected_family.extend({"identity_id": identity_id, "mfa": list(mfa_from_tuple(mfa, f"{lane} selected family"))}
                                   for mfa in row["saved_live_mfas"])
        expected_family.sort(key=lambda item: (item["identity_id"], *item["mfa"]))
        expect(lane_record["family"] == expected_family,
               f"{lane} family differs from the exact selected saved-live rows")
        family_set = {(item["identity_id"], tuple(item["mfa"])) for item in expected_family}
        expected_complement = [item for item in expected_members if (item["identity_id"], tuple(item["mfa"])) not in family_set]
        expect(lane_record["complement"] == expected_complement,
               f"{lane} complement differs from complete membership minus the family")
    expect(lanes["core"]["identity"].get("lock_sha256") == EXPECTED_CURRENT_CORE_LOCK_SHA256
           and lanes["floor"]["identity"].get("lock_sha256") == EXPECTED_FLOOR_LOCK_SHA256,
           "one lane's exact lock pin changed after schedule creation")
    print("PASS: exact lane partitions, source paths, package/runtime pins, selector coverage, and preserved stops validate.")
    if require_review:
        print(f"PASS: independent schedule review binds {current_schedule_sha}.")
    if require_approval:
        print("PASS: source-read approval covers every scheduled request exactly once.")
    return reconciliation, schedule, reconciliation_raw, schedule_raw, approval_raw


def create_source_approval() -> int:
    reconciliation, schedule, _, schedule_raw, _ = validate_scope_artifacts(require_review=True)
    entries = schedule["entries"]
    assignments = {batch: sorted(entry["request_id"] for entry in entries if entry["batch"] == batch)
                   for batch in ("01", "02", "03", "04", "05")}
    reviewer = one(r"\*\*Reviewer:\*\* ([^\n]+)", require_text(SCHEDULE_REVIEW), "independent reviewer").strip()
    approval = {
        "schema": "fablebook.phase7.source_read_approval/1", "verdict": "PASS", "reviewer": reviewer,
        "schedule_sha256": sha256(schedule_raw), "review_sha256": digest(SCHEDULE_REVIEW),
        "approved_request_ids": sorted(entry["request_id"] for entry in entries),
        "batch_assignments": assignments, "max_files_total": 25,
        "source_bodies_read_at_approval": False,
    }
    encoded = (json.dumps(approval, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
    write_new(SOURCE_APPROVAL.name, encoded)
    validate_scope_artifacts(require_review=True, require_approval=True)
    print(f"PASS: source-read approval bound to exact schedule SHA-256 {sha256(schedule_raw)}.")
    return 0


def validate_source_reader_review() -> dict:
    review = require_text(SOURCE_READER_REVIEW)
    snapshot, _snapshot_raw = read_json_bytes(READ_TIME_CODE_SNAPSHOT, 64 * 1024)
    expect(snapshot.get("schema") == "fablebook.phase7.read_time_code_snapshot/1",
           "read-time source-code snapshot has an unexpected schema")
    expect(snapshot.get("source_reader_review") == SOURCE_READER_REVIEW.name,
           "read-time source-code snapshot points at a different review")
    expect(snapshot.get("source_reader_review_sha256") == digest(SOURCE_READER_REVIEW),
           "read-time source-code snapshot does not bind the exact preserved review")
    expect(snapshot.get("source_read_validator_sha256") == read_redaction_receipt()
           .get("read_time_bindings", {}).get("validator_sha256"),
           "read-time source-code snapshot does not bind the historical validator")
    snapshot_entries = snapshot.get("snapshot_files")
    expected_paths = {
        "phase7_read_sources.py": SOURCE_READER,
        "phase7_source_launcher.py": SOURCE_LAUNCHER,
        "phase7_source_bootstrap.py": SOURCE_BOOTSTRAP,
        "phase7_source_observer.py": SOURCE_SPAN_OBSERVER,
    }
    expect(isinstance(snapshot_entries, list) and len(snapshot_entries) == len(expected_paths)
           and {entry.get("path") for entry in snapshot_entries if isinstance(entry, dict)}
           == {f"07-READ-TIME-CODE/{name}" for name in expected_paths},
           "read-time source-code snapshot does not name the exact reviewed helper set")
    snapshot_digests = {}
    for entry in snapshot_entries:
        expect(isinstance(entry, dict), "read-time source-code snapshot entry is invalid")
        expect(isinstance(entry.get("sha256"), str)
               and re.fullmatch(r"[0-9a-f]{64}", entry["sha256"]) is not None,
               "read-time source-code snapshot digest is invalid")
        name = Path(entry["path"]).name
        expect(name in expected_paths, f"unexpected read-time helper snapshot: {name}")
        code = read_capped(READ_TIME_CODE_DIR / name, 4 * 1024 * 1024)
        actual = sha256(code)
        expect(actual == entry.get("sha256"), f"read-time helper snapshot changed: {name}")
        snapshot_digests[name] = actual
    expect("**Verdict:** PASS" in review, "independent one-use source-reader review is not PASS")
    expect("**Reviewer opened target source bodies:** no" in review,
           "reader-code reviewer opened a target source body")
    reviewed_reader = one(r"\*\*Reader SHA-256:\*\* `([0-9a-f]{64})`", review, "reviewed source reader digest")
    reviewed_launcher = one(r"\*\*Launcher SHA-256:\*\* `([0-9a-f]{64})`", review, "reviewed source launcher digest")
    reviewed_bootstrap = one(r"\*\*Bootstrap SHA-256:\*\* `([0-9a-f]{64})`", review, "reviewed source bootstrap digest")
    reviewed_parser = one(r"\*\*Parser SHA-256:\*\* `([0-9a-f]{64})`", review, "reviewed source parser digest")
    reviewed_validator = one(r"\*\*Validator SHA-256:\*\* `([0-9a-f]{64})`", review, "reviewed source validator digest")
    reviewer = one(r"\*\*Reviewer:\*\* ([^\n]+)", review, "reader-code reviewer").strip()
    prior_evidence = {
        "No-retry request ID": EXPECTED_NO_RETRY_REQUEST_ID,
        "Prior STOP SHA-256": EXPECTED_NO_RETRY_STOP_SHA256,
        "Prior marker SHA-256": EXPECTED_NO_RETRY_MARKER_SHA256,
        "Initial review SHA-256": EXPECTED_INITIAL_READER_REVIEW_SHA256,
        "Interrupted request IDs": ",".join(EXPECTED_INTERRUPTED_REQUESTS),
        "Interrupted STOP SHA-256": EXPECTED_INTERRUPTED_STOP_SHA256,
        "Interrupted marker core-source-02 SHA-256": EXPECTED_INTERRUPTED_MARKERS["core-source-02"],
        "Interrupted marker core-source-03 SHA-256": EXPECTED_INTERRUPTED_MARKERS["core-source-03"],
        "Interrupted review SHA-256": EXPECTED_INTERRUPTED_REVIEW_SHA256,
    }
    for heading, expected_value in prior_evidence.items():
        actual = one(rf"\*\*{re.escape(heading)}:\*\* `([^`]+)`", review, heading)
        expect(actual == expected_value, f"continuation review does not bind immutable prior evidence: {heading}")
    read_time_validator_sha = read_redaction_receipt().get("read_time_bindings", {}).get("validator_sha256")
    expect(reviewed_reader == snapshot_digests["phase7_read_sources.py"]
           and reviewed_launcher == snapshot_digests["phase7_source_launcher.py"]
           and reviewed_bootstrap == snapshot_digests["phase7_source_bootstrap.py"]
           and reviewed_parser == snapshot_digests["phase7_source_observer.py"]
           and reviewed_validator == read_time_validator_sha,
           "source reader review no longer matches its preserved read-time code snapshots")
    expect(reviewer and reviewer != "schedule author", "source-reader reviewer is missing or not independent")
    return {"reviewer": reviewer, "review_sha256": digest(SOURCE_READER_REVIEW),
            "reader_sha256": snapshot_digests["phase7_read_sources.py"],
            "launcher_sha256": snapshot_digests["phase7_source_launcher.py"],
            "bootstrap_sha256": snapshot_digests["phase7_source_bootstrap.py"],
            "parser_sha256": snapshot_digests["phase7_source_observer.py"],
            "validator_sha256": reviewed_validator}


def validate_observation_batch(batch: str) -> int:
    _reconciliation, schedule, _reconciliation_raw, schedule_raw, _approval_raw = validate_scope_artifacts(
        require_review=True, require_approval=True, allow_observed_reads=True)
    reader_review = validate_source_reader_review()
    schedule_sha = historical_digest(SOURCE_SCHEDULE)
    entries = {entry["request_id"]: entry for entry in schedule["entries"] if entry["batch"] == batch}
    output_path = OBSERVATION_FILES[f"07-OBSERVATIONS-{int(batch):02}.jsonl"]
    rows, _raw = read_jsonl_bytes(output_path, 4 * 1024 * 1024)
    expect(len(rows) == len(entries), f"batch {batch} observation count differs from exact schedule")
    seen = set()
    for row in rows:
        request_id = row.get("request_id")
        expect(request_id in entries and request_id not in seen, f"batch {batch} has an unknown or duplicate request")
        seen.add(request_id)
        entry = entries[request_id]
        expect(row.get("schema") == "fablebook.phase7.source_observation/1"
               and row.get("lane") == entry["lane"] and row.get("batch") == batch
               and row.get("target_path") == entry["target_path"]
               and row.get("source_identity") == entry["source_identity"]
               and row.get("mfa_span_selectors") == entry["mfa_span_selectors"]
               and row.get("schedule_sha256") == schedule_sha,
               f"batch {batch} observation does not match its approved source schedule: {request_id}")
        expect(row.get("approval_sha256") == digest(SOURCE_APPROVAL)
               and row.get("reader_review") == reader_review,
               f"batch {batch} observation is not bound to the current approvals/code review: {request_id}")
        expect(row.get("runtime_calls") is False and row.get("generated_code_executed") is False
               and row.get("package_wide_search") is False and row.get("caller_closure_claim") == "none",
               f"batch {batch} observation overstates its execution or caller scope: {request_id}")
        expected_marker_relative = f"{READ_CONSUMPTION.name}/{request_id}.json"
        expect(row.get("consumption_marker", {}).get("path") == expected_marker_relative,
               f"batch {batch} marker path is not the fixed request ledger path: {request_id}")
        marker, _marker_bytes = read_json_bytes(READ_CONSUMPTION / f"{request_id}.json", 16 * 1024)
        expect(row.get("consumption_marker", {}).get("status") == "consumed_before_open"
               and marker.get("schema") == "fablebook.phase7.read_once/1"
               and marker.get("request_id") == request_id
               and marker.get("schedule_sha256") == schedule_sha
               and marker.get("approval_sha256") == digest(SOURCE_APPROVAL)
               and marker.get("target_path") == entry["target_path"]
               and marker.get("status") == "consumed_before_open",
               f"batch {batch} lacks its exact one-use consumption marker: {request_id}")
        status = row.get("observation_status")
        expect(status in {"parsed", "parse_failed", "parse_failed_no_retry", "batch_stopped_no_retry"},
               f"batch {batch} has an unknown observation status: {request_id}")
        provenance = row.get("file_provenance")
        parse_failure = row.get("parse_failure")
        if status in {"parsed", "parse_failed"}:
            expect(isinstance(provenance, dict),
                   f"batch {batch} source provenance is missing or malformed: {request_id}")
            expect(marker.get("reader_review_sha256") == reader_review["review_sha256"],
                   f"batch {batch} marker is not bound to the current source-reader review: {request_id}")
            expect(provenance.get("size_bytes") == entry["expected_file_stat"]["size_bytes"]
                   and re.fullmatch(r"[0-9a-f]{64}", provenance.get("sha256", ""))
                   and provenance.get("stat_before") == entry["expected_file_stat"]
                   and provenance.get("stat_after") == entry["expected_file_stat"],
                   f"batch {batch} source hash or read-time identity is invalid: {request_id}")
            if status == "parsed":
                expect(parse_failure is None, f"parsed observation has a failure record: {request_id}")
            else:
                expect(isinstance(parse_failure, dict) and parse_failure.get("error_type") == "ObserverError"
                       and parse_failure.get("source_hash_captured") is True
                       and parse_failure.get("retry_permitted") is False
                       and parse_failure.get("stop_receipt") is None,
                       f"batch {batch} parser-failure record is incomplete: {request_id}")
        else:
            expect(provenance is None and isinstance(parse_failure, dict)
                   and parse_failure.get("source_hash_captured") is False
                   and parse_failure.get("retry_permitted") is False,
                   f"batch {batch} no-retry record overstates captured evidence: {request_id}")
            stop_info = parse_failure.get("stop_receipt")
            expect(isinstance(stop_info, dict), f"batch {batch} no-retry row lacks its exact stop receipt: {request_id}")
            if status == "parse_failed_no_retry":
                validate_no_retry_identity(batch, request_id)
                initial_review_bytes = read_capped(SOURCE_READER_REVIEW_INITIAL, 1024 * 1024)
                initial_review = initial_review_bytes.decode("utf-8", "strict")
                initial_review_sha = sha256(initial_review_bytes)
                expect(parse_failure.get("error_type") == "ObserverError"
                       and marker.get("reader_review_sha256") == initial_review_sha
                       and initial_review_sha == EXPECTED_INITIAL_READER_REVIEW_SHA256
                       and historical_digest(READ_CONSUMPTION / f"{request_id}.json") == EXPECTED_NO_RETRY_MARKER_SHA256
                       and "**Verdict:** PASS" in initial_review
                       and "**Target source bodies read:** no" in initial_review
                       and stop_info.get("path") == f"07-OBSERVATIONS-{int(batch):02}.STOP.json"
                       and stop_info.get("initial_review_sha256") == initial_review_sha,
                       f"batch {batch} failure marker is not bound to its original pre-read review: {request_id}")
                stop, stop_raw = read_json_bytes(PHASE / stop_info["path"], 64 * 1024)
                expect(sha256(stop_raw) == EXPECTED_NO_RETRY_STOP_SHA256
                       and stop_info.get("stop_sha256") == sha256(stop_raw)
                       and stop_info.get("marker_sha256") == historical_digest(READ_CONSUMPTION / f"{request_id}.json")
                       and stop.get("schema") == "fablebook.phase7.source_read_stop/1"
                       and stop.get("batch") == batch and stop.get("schedule_sha256") == schedule_sha
                       and stop.get("consumed_requests") == [request_id]
                       and stop.get("output_exists") is False
                       and stop.get("error") == "ObserverError: unbalanced delimiter"
                       and parse_failure.get("error") == "unbalanced delimiter",
                       f"batch {batch} no-retry gap differs from its exact parser-failure receipt: {request_id}")
            else:
                expected_errors = {
                    "core-source-02": ("BatchOutputLost", "No durable observation was written before the batch stopped on core-source-03."),
                    "core-source-03": ("SelectorKeyNormalizationMismatch", "Reader lookup used the Elixir-prefixed MFA key, but parser result keys had the prefix normalized."),
                }
                expect(batch == "01" and request_id in expected_errors,
                       f"batch {batch} contains an unapproved stopped request: {request_id}")
                expected_error_type, expected_error = expected_errors[request_id]
                consumed_review_bytes = read_capped(SOURCE_READER_REVIEW_CONSUMED, 1024 * 1024)
                consumed_review = consumed_review_bytes.decode("utf-8", "strict")
                consumed_review_sha = sha256(consumed_review_bytes)
                expect(consumed_review_sha == EXPECTED_INTERRUPTED_REVIEW_SHA256
                       and "**Verdict:** PASS" in consumed_review
                       and "**Reviewer opened target source bodies:** no" in consumed_review
                       and marker.get("reader_review_sha256") == consumed_review_sha
                       and historical_digest(READ_CONSUMPTION / f"{request_id}.json") == EXPECTED_INTERRUPTED_MARKERS[request_id]
                       and parse_failure.get("error_type") == expected_error_type
                       and parse_failure.get("error") == expected_error
                       and stop_info.get("path") == "07-OBSERVATIONS-01.CONTINUATION.STOP.json"
                       and stop_info.get("initial_review_sha256") == consumed_review_sha,
                       f"batch {batch} interrupted gap differs from the pinned consumed attempt: {request_id}")
                stop, stop_raw = read_json_bytes(PHASE / stop_info["path"], 64 * 1024)
                expect(sha256(stop_raw) == EXPECTED_INTERRUPTED_STOP_SHA256
                       and stop_info.get("stop_sha256") == sha256(stop_raw)
                       and stop_info.get("marker_sha256") == historical_digest(READ_CONSUMPTION / f"{request_id}.json")
                       and stop.get("schema") == "fablebook.phase7.source_read_stop/1"
                       and stop.get("batch") == "01" and stop.get("schedule_sha256") == schedule_sha
                       and stop.get("consumed_requests") == list(EXPECTED_INTERRUPTED_REQUESTS)
                       and stop.get("prior_stop_sha256") == EXPECTED_NO_RETRY_STOP_SHA256
                       and stop.get("output_exists") is False
                       and stop.get("error") == "KeyError: ('Elixir.Phoenix.LiveView.ColocatedAssets', 'compile', 0)",
                       f"batch {batch} interrupted gap differs from its exact continuation stop: {request_id}")
        observations = row.get("observations")
        expect(isinstance(observations, list) and len(observations) == len(entry["mfa_span_selectors"]),
               f"batch {batch} selector observation set is incomplete: {request_id}")
        observed_members = []
        for observation in observations:
            mfa = mfa_from_tuple(observation.get("mfa"), f"observation {request_id}")
            observed_members.append((observation.get("identity_id"), mfa))
            definitions = observation.get("definition_spans")
            references = observation.get("same_file_static_references")
            expect(isinstance(definitions, list) and isinstance(references, list) and len(references) <= 100,
                   f"batch {batch} has malformed or over-limit parser output: {request_id}")
            if status == "parsed":
                expect(observation.get("reference_scope") == "statically recognizable same-module calls in this exact file only"
                       and observation.get("claim_limit") == "These observations do not establish that all callers or delegates are known."
                       and definitions,
                       f"batch {batch} parsed observation lacks bounded-claim labels or definitions: {request_id}")
            else:
                expected_scope = ("unavailable because the exact file did not parse"
                                  if status in {"parse_failed", "parse_failed_no_retry"}
                                  else "unavailable because no durable observation was recorded for this consumed request")
                expect(not definitions and not references
                       and observation.get("reference_scope") == expected_scope
                       and observation.get("claim_limit") == "No definition or caller claim is possible for this file.",
                       f"batch {batch} parse-failure row claims source spans: {request_id}")
            for span in definitions:
                expect(set(span) <= {"start_byte", "end_byte", "start_line", "end_line", "kind"}
                       and isinstance(span.get("start_byte"), int) and isinstance(span.get("end_byte"), int)
                       and 0 <= span["start_byte"] < span["end_byte"] <= provenance["size_bytes"]
                       and isinstance(span.get("start_line"), int) and span["start_line"] >= 1
                       and isinstance(span.get("end_line"), int) and span["end_line"] >= span["start_line"],
                       f"batch {batch} definition span is invalid: {request_id}")
            for reference in references:
                expect(set(reference) == {"start_byte", "end_byte", "line"}
                       and isinstance(reference.get("start_byte"), int) and isinstance(reference.get("end_byte"), int)
                       and 0 <= reference["start_byte"] < reference["end_byte"] <= provenance["size_bytes"]
                       and isinstance(reference.get("line"), int) and reference["line"] >= 1,
                       f"batch {batch} reference span is invalid: {request_id}")
        expect(observed_members == [(selector["identity_id"], tuple(selector["mfa"]))
                                     for selector in entry["mfa_span_selectors"]],
               f"batch {batch} observations do not cover its exact selectors: {request_id}")
        gaps = row.get("explicit_gaps", [])
        expect(isinstance(gaps, list) and any("other source file" in item for item in gaps)
               and any("dynamic dispatch" in item for item in gaps),
               f"batch {batch} omits external/dynamic caller gaps: {request_id}")
        if status != "parsed":
            if status in {"parse_failed", "parse_failed_no_retry"}:
                expect(any("parser rejected" in item for item in gaps)
                       and any("No definition or caller spans" in item for item in gaps),
                       f"batch {batch} parser-failure gap is not explicit: {request_id}")
            else:
                expect(any("batch stopped after this request was consumed" in item for item in gaps)
                       and any("No durable source hash or selector spans" in item for item in gaps),
                       f"batch {batch} stopped-request gap is not explicit: {request_id}")
    expect(seen == set(entries), f"batch {batch} misses one or more approved requests")
    if not entries:
        expect(not rows, f"empty batch {batch} must have an empty observation file")
    print(f"PASS: batch {batch} has {len(rows)} complete, exact, non-truncated observations and one-use markers.")
    return 0


def token_estimate(source_bytes: int) -> dict:
    return {"low": round(source_bytes / 4.5), "point": round(source_bytes / 3.5),
            "high": round(source_bytes / 3.0),
            "method": "Approximate source bytes divided by 4.5–3.0 bytes per token; not a model tokenizer measurement."}


def collect_observation_evidence(schedule: dict, schedule_raw: bytes) -> dict:
    rows_by_id = {}
    batches = []
    for batch in ("01", "02", "03", "04", "05"):
        validate_observation_batch(batch)
        path = OBSERVATION_FILES[f"07-OBSERVATIONS-{int(batch):02}.jsonl"]
        rows, raw = read_jsonl_bytes(path, 4 * 1024 * 1024)
        batches.append({"batch": batch, "path": path.name, "sha256": sha256(raw), "request_count": len(rows)})
        for row in rows:
            request_id = row["request_id"]
            expect(request_id not in rows_by_id, f"duplicate observation request across batches: {request_id}")
            rows_by_id[request_id] = row

    schedule_entries = schedule["entries"]
    expect(set(rows_by_id) == {entry["request_id"] for entry in schedule_entries},
           "observations do not cover every exact scheduled request")
    status_counts = Counter(row["observation_status"] for row in rows_by_id.values())
    no_hash_ids = {request_id for request_id, row in rows_by_id.items()
                   if row.get("observation_status") in {"parse_failed_no_retry", "batch_stopped_no_retry"}}
    expect(no_hash_ids == {"core-source-01", "core-source-02", "core-source-03"}
           and status_counts.get("parse_failed_no_retry") == 1
           and status_counts.get("batch_stopped_no_retry") == 2,
           "the three pinned batch-01 consumed requests are not preserved as exact no-retry gaps")
    outcomes = []
    captured_bytes = 0
    missing_hash_bytes = 0
    for entry in schedule_entries:
        request_id = entry["request_id"]
        row = rows_by_id[request_id]
        status = row["observation_status"]
        expected_bytes = entry["expected_file_stat"]["size_bytes"]
        provenance = row.get("file_provenance")
        source_sha256 = None
        if provenance is None:
            missing_hash_bytes += expected_bytes
        else:
            captured_bytes += provenance["size_bytes"]
            source_sha256 = provenance["sha256"]
        if status == "parse_failed_no_retry":
            expect(request_id == EXPECTED_NO_RETRY_REQUEST_ID and source_sha256 is None,
                   "the no-retry gap is not the exact un-hashed consumed request")
        elif status == "batch_stopped_no_retry":
            expect(request_id in EXPECTED_INTERRUPTED_MARKERS and source_sha256 is None,
                   "the stopped no-retry gap is not an exact interrupted request")
        row_bytes = (json.dumps(row, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
        outcomes.append({
            "request_id": request_id, "lane": entry["lane"], "batch": entry["batch"],
            "target_path": entry["target_path"], "status": status,
            "selectors": entry["mfa_span_selectors"], "source_size_bytes": expected_bytes,
            "source_sha256": source_sha256,
            "observation_row_sha256": sha256(row_bytes),
            "reopened": False,
        })

    scheduled_bytes = sum(entry["expected_file_stat"]["size_bytes"] for entry in schedule_entries)
    expect(captured_bytes + missing_hash_bytes == scheduled_bytes,
           "source sizing does not account for all scheduled byte sizes")
    sizing = {
        "scheduled_files": len(schedule_entries), "scheduled_source_bytes": scheduled_bytes,
        "requests_by_status": {key: status_counts.get(key, 0)
                               for key in ("parsed", "parse_failed", "parse_failed_no_retry", "batch_stopped_no_retry")},
        "files_with_captured_hash": sum(row.get("file_provenance") is not None for row in rows_by_id.values()),
        "files_without_captured_hash": sum(row.get("file_provenance") is None for row in rows_by_id.values()),
        "source_bytes_with_captured_hash": captured_bytes,
        "source_bytes_without_captured_hash": missing_hash_bytes,
        "context_estimate_scheduled": token_estimate(scheduled_bytes),
        "context_estimate_hash_captured": token_estimate(captured_bytes),
        "effort": {
            "estimate_hours": 5.0, "range_hours": [4.0, 8.0],
            "method": "Refreshed estimate for ten approved observations, separate schedule and reader reviews, three no-retry gaps after two reader/parser interruptions, joining and full validation.",
            "actual_elapsed_measured": False,
        },
    }
    expect(schedule_raw and len(schedule_entries) == 10, "approved source schedule is unexpectedly empty or incomplete")
    no_retry_evidence = []
    for row in rows_by_id.values():
        if row["observation_status"] not in {"parse_failed_no_retry", "batch_stopped_no_retry"}:
            continue
        failure = row["parse_failure"]
        stop_receipt = failure["stop_receipt"]
        no_retry_evidence.append({
            "request_id": row["request_id"], "status": row["observation_status"],
            "error_type": failure["error_type"], "error": failure["error"],
            "stop_path": stop_receipt["path"], "stop_sha256": stop_receipt["stop_sha256"],
            "marker_path": row["consumption_marker"]["path"],
            "marker_sha256": stop_receipt["marker_sha256"],
            "review_sha256": stop_receipt["initial_review_sha256"],
            "source_hash_or_spans_captured": False, "reopened": False,
        })
    no_retry_evidence.sort(key=lambda item: item["request_id"])
    return {
        "schema": "fablebook.phase7.observation_evidence/1",
        "schedule_sha256": historical_digest(SOURCE_SCHEDULE),
        "approval_sha256": digest(SOURCE_APPROVAL),
        "schedule_review_sha256": historical_digest(SCHEDULE_REVIEW),
        "source_reader_review": validate_source_reader_review(),
        "batch_outputs": batches,
        "requests": outcomes,
        "sizing": sizing,
        "no_retry_evidence": no_retry_evidence,
    }


def render_reconciliation_markdown(reconciliation: dict) -> bytes:
    evidence = reconciliation["observation_evidence"]
    sizing = evidence["sizing"]
    core = reconciliation["lanes"]["core"]
    floor = reconciliation["lanes"]["floor"]
    counts = sizing["requests_by_status"]
    lines = [
        "# Phase 7: Guard Scope Reconciliation",
        "",
        f"**Result:** `{reconciliation['status']}`",
        "",
        "## What this establishes",
        "",
        "This phase reconciles one proposed evidence family and its full complement across the pinned core and floor lanes. The family is evidence scope only; no code candidate was selected, no implementation was authorized, and the aggregate gate remains open.",
        "",
        f"- Core: {core['family_count']} family memberships; {core['complement_count']} complement memberships out of {core['membership_count']}; membership digest `{core['membership_sha256']}`.",
        f"- Floor: {floor['family_count']} family memberships; {floor['complement_count']} complement memberships out of {floor['membership_count']}; membership digest `{floor['membership_sha256']}`.",
        f"- Exact read-time schedule: `{evidence['schedule_sha256']}`; schedule review `{evidence['schedule_review_sha256']}`; approval `{evidence['approval_sha256']}`.",
        f"- Local home paths are shortened to `~/` in delivered files. The [path-redaction receipt]({REDACTION_RECEIPT.name}) binds the original read-time schedule to its redacted form (`{digest(SOURCE_SCHEDULE)}`).",
        "- The selected family is CN-002 through CN-006. CN-001 remains in the complement because neither lane has a live MFA for it. The EX-124/125 cross-references remain unresolved context and were not added to the family or source schedule.",
        "",
        "## Bounded source observations",
        "",
        f"The schedule covered {sizing['scheduled_files']} exact files totaling {sizing['scheduled_source_bytes']} stat-sized bytes. Outcomes: {counts['parsed']} parsed, {counts['parse_failed']} parser failures with a captured hash, {counts['parse_failed_no_retry']} parser failure without retry, and {counts['batch_stopped_no_retry']} batch-stopped requests without durable observations.",
        f"Captured source hashes cover {sizing['source_bytes_with_captured_hash']} bytes. {sizing['source_bytes_without_captured_hash']} scheduled bytes have no captured source hash. These are byte-size estimates, not token measurements: all scheduled files are estimated at {sizing['context_estimate_scheduled']['low']}–{sizing['context_estimate_scheduled']['high']} tokens; hash-captured files at {sizing['context_estimate_hash_captured']['low']}–{sizing['context_estimate_hash_captured']['high']} tokens.",
        "",
        "| Request | Lane | Status | Exact source path | Source SHA-256 |",
        "|---|---|---|---|---|",
    ]
    for request in evidence["requests"]:
        source_hash = request["source_sha256"] or "not captured"
        lines.append(f"| `{request['request_id']}` | {request['lane']} | `{request['status']}` | `{request['target_path']}` | `{source_hash}` |")
    no_retry = evidence["no_retry_evidence"]
    lines.extend([
        "",
        f"{len(no_retry)} consumed requests have no durable source hash or spans and were not reopened:",
    ])
    for gap in no_retry:
        lines.append(f"- `{gap['request_id']}` (`{gap['status']}`, {gap['error_type']}): {gap['error']} STOP `{gap['stop_sha256']}`, marker `{gap['marker_sha256']}`, review `{gap['review_sha256']}`.")
    lines.extend([
        "",
        "Static observations are limited to recognizable references in each exact file. They do not establish package-wide caller closure. Dynamic dispatch, external callers, callbacks, aliases/imports, macros, generated code, and unsupported syntax remain gaps where listed in the observation records.",
        "",
        "## Refreshed effort and fixed limits",
        "",
        f"Estimated total effort is {sizing['effort']['estimate_hours']} hours (range {sizing['effort']['range_hours'][0]}–{sizing['effort']['range_hours'][1]}). Active elapsed time was not measured. The observation cap remains five files per batch and 2 MiB per file; requests are one-use, source truncation is forbidden, runtime APIs and generated code were not used, package-wide search was not performed, and R9 remains unconsumed.",
        "",
        "## Preserved stops",
        "",
        "- Candidate fit unresolved; candidate remains null.",
        "- Aggregate gate open; guard implementation unauthorized.",
        "- R9 denied and not consumed; SEC-01 Pending; actual library collision unknown under the existing owner stop.",
        "- Macro caller-AST and macro explanation remain unresolved; legacy digest unresolved.",
        "- Walking Skeleton remains blocked; automatic follow-up disabled.",
        "",
        "## Recommendation and owner decision",
        "",
        reconciliation["owner_decision"]["recommendation"],
        "",
        f"**Owner decision:** {reconciliation['owner_decision']['question']}",
        "",
    ])
    return "\n".join(lines).encode("utf-8")


def validate_final_reconciliation() -> tuple[dict, dict]:
    reconciliation, schedule, _reconciliation_raw, schedule_raw, _approval_raw = validate_scope_artifacts(
        require_review=True, require_approval=True, allow_observed_reads=True)
    evidence = collect_observation_evidence(schedule, schedule_raw)
    expect(reconciliation.get("status") == FINAL_RECONCILIATION_STATUS,
           "final reconciliation status is missing or unsupported")
    expect(reconciliation.get("source_read_boundary") == {
        "target_source_bodies_read": True, "recorded_source_paths_are_values_only": True,
        "runtime_apis_called": False, "generated_code_executed": False,
    }, "final source-read boundary overstates or omits bounded actions")
    expect(reconciliation.get("source_schedule", {}).get("review_status") == "PASS",
           "final record does not preserve the independent schedule PASS")
    expected_redaction = {
        "receipt": relpath(REDACTION_RECEIPT), "receipt_sha256": digest(REDACTION_RECEIPT),
        "read_time_schedule_sha256": historical_digest(SOURCE_SCHEDULE),
        "delivered_schedule_sha256": digest(SOURCE_SCHEDULE),
    }
    expect(reconciliation.get("path_redaction") == expected_redaction,
           "final record does not bind the documented home-path shortening receipt")
    expect(reconciliation.get("observation_evidence") == evidence,
           "final observation evidence differs from the exact reviewed batch outputs")
    expect(reconciliation.get("refreshed_sizing") == evidence["sizing"],
           "final source/context/effort sizing differs from the validated observation results")
    expect(reconciliation.get("preserved_stops") == EXPECTED_PRESERVED_STOPS,
           "final reconciliation changed an inherited stop")
    owner_decision = reconciliation.get("owner_decision", {})
    expect(owner_decision.get("required") is True
           and owner_decision.get("question") == FINAL_OWNER_QUESTION
           and owner_decision.get("recommendation") == FINAL_OWNER_RECOMMENDATION,
           "final recommendation crosses or changes the owner decision boundary")
    return reconciliation, evidence


def finalize_reconciliation() -> int:
    reconciliation, schedule, _reconciliation_raw, schedule_raw, _approval_raw = validate_scope_artifacts(
        require_review=True, require_approval=True)
    expect(reconciliation.get("status") == "family_partition_ready_schedule_review_pending",
           "finalization only runs once from the reviewed pre-observation state")
    evidence = collect_observation_evidence(schedule, schedule_raw)
    final_record = dict(reconciliation)
    final_record["status"] = FINAL_RECONCILIATION_STATUS
    final_record["source_read_boundary"] = {
        "target_source_bodies_read": True, "recorded_source_paths_are_values_only": True,
        "runtime_apis_called": False, "generated_code_executed": False,
    }
    final_record["source_schedule"] = {**reconciliation["source_schedule"], "review_status": "PASS"}
    final_record["path_redaction"] = {
        "receipt": relpath(REDACTION_RECEIPT), "receipt_sha256": digest(REDACTION_RECEIPT),
        "read_time_schedule_sha256": historical_digest(SOURCE_SCHEDULE),
        "delivered_schedule_sha256": digest(SOURCE_SCHEDULE),
    }
    final_record["observation_evidence"] = evidence
    final_record["refreshed_sizing"] = evidence["sizing"]
    final_record["owner_decision"] = {
        "required": True, "question": FINAL_OWNER_QUESTION,
        "recommendation": FINAL_OWNER_RECOMMENDATION,
    }
    encoded = (json.dumps(final_record, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
    replace_phase_file_atomically(RECONCILIATION.name, encoded)
    replace_phase_file_atomically(RECONCILIATION_MD.name, render_reconciliation_markdown(final_record))
    validate_final_reconciliation()
    print("PASS: final reconciliation and human summary are joined to all five exact observation batches.")
    return 0


def rebind_redacted_reconciliation() -> int:
    reconciliation, schedule, _reconciliation_raw, schedule_raw, _approval_raw = validate_scope_artifacts(
        require_review=True, require_approval=True, allow_observed_reads=True)
    expect(reconciliation.get("status") == FINAL_RECONCILIATION_STATUS,
           "path-redaction rebind requires an already-final reconciliation")
    evidence = collect_observation_evidence(schedule, schedule_raw)
    previous = json.loads(json.dumps(reconciliation.get("observation_evidence")))
    current = json.loads(json.dumps(evidence))
    for record in (previous, current):
        for batch in record["batch_outputs"]:
            batch.pop("sha256", None)
        for request in record["requests"]:
            request.pop("observation_row_sha256", None)
    expect(previous == current and reconciliation.get("refreshed_sizing") == evidence["sizing"],
           "redacted observations changed a claim other than the expected artifact digests")
    final_record = dict(reconciliation)
    final_record["observation_evidence"] = evidence
    final_record["refreshed_sizing"] = evidence["sizing"]
    final_record["path_redaction"] = {
        "receipt": relpath(REDACTION_RECEIPT), "receipt_sha256": digest(REDACTION_RECEIPT),
        "read_time_schedule_sha256": historical_digest(SOURCE_SCHEDULE),
        "delivered_schedule_sha256": digest(SOURCE_SCHEDULE),
    }
    encoded = (json.dumps(final_record, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()
    replace_phase_file_atomically(RECONCILIATION.name, encoded)
    replace_phase_file_atomically(RECONCILIATION_MD.name, render_reconciliation_markdown(final_record))
    validate_reconciliation_summary()
    print("PASS: final evidence and human summary now bind the shortened home-path artifacts.")
    return 0


def validate_reconciliation_summary() -> int:
    reconciliation, _evidence = validate_final_reconciliation()
    expected = render_reconciliation_markdown(reconciliation)
    actual = read_capped(RECONCILIATION_MD, 2 * 1024 * 1024)
    expect(actual == expected, "human summary differs from the validated machine-readable reconciliation")
    print("PASS: human summary exactly matches the validated reconciliation and ends at the owner decision.")
    return 0


def validate_retained_inputs() -> int:
    inputs = load_retained_inputs()
    accepted = validate_saved_envelopes(inputs)
    core = inputs["json"]["core_aggregate"]
    floor = inputs["json"]["floor_aggregate"]
    validate_aggregate_rows(core, "core")
    validate_aggregate_rows(floor, "floor")
    gap_rows = inputs["jsonl"]["env06_typed_gaps"]
    core_gaps, _ = typed_gap_live_rows(gap_rows, core, "core", sha256(inputs["records"]["core_aggregate"][1]))
    floor_gaps, _ = typed_gap_live_rows(gap_rows, floor, "floor", sha256(inputs["records"]["floor_aggregate"][1]))
    print("PASS: accepted ENV06 and both archived 226-row maps match their recorded locks and runtime pins.")
    print(f"Core saved-live row references: {len(core_gaps)}; floor saved-live row references: {len(floor_gaps)}.")
    print("This check read planning metadata only; it did not open compiled files or target source bodies.")
    return 0


def one(pattern: str, text: str, label: str) -> str:
    match = re.search(pattern, text, re.MULTILINE)
    if not match:
        raise ValidationError(f"missing {label}")
    return match.group(1)


def validate_producer_review() -> None:
    proposal = read_json(PROPOSAL)
    source = proposal.get("source", {})
    expected_sha = "2b6eb2b1033ad429edc6f751ed2f55298a272610123085027c87ece59b379fdb"
    expect(proposal.get("request_id") == "R11", "proposal request ID is not R11")
    expect(source.get("path") == "test/support/guard_aggregate_reconciliation_evidence.ex", "unexpected producer path")
    expect(source.get("bytes") == 86693, "unexpected producer byte count")
    expect(source.get("lines") == 2357, "unexpected producer line count")
    expect(source.get("sha256") == expected_sha, "proposal producer hash differs")
    expect(source.get("span") == "complete_file" and source.get("truncation_allowed") is False, "proposal permits an incomplete read")
    exclusions = proposal.get("excluded_inputs_and_actions", [])
    expect(any("Do not replay or reuse R10 or R9" in item for item in exclusions), "proposal does not exclude R10 and R9 reuse")
    expect(len(proposal.get("source", {})) > 0, "proposal source identity is empty")

    review = require_text(REVIEW)
    proposal_sha = digest(PROPOSAL)
    expect("**Verdict:** PASS" in review, "R11 request review is not PASS")
    reviewed_sha = one(r"\*\*Frozen proposal SHA-256:\*\* `([0-9a-f]{64})`", review, "frozen proposal digest")
    expect(reviewed_sha == proposal_sha, "R11 review is bound to a different proposal digest")

    analysis = require_text(ANALYSIS)
    expect("**Request:** R11" in analysis, "analysis is not bound to R11")
    expect("**Capture status:** COMPLETE" in analysis, "full-file capture is not marked complete")
    expect("**Captured bytes:** 86,693" in analysis, "captured byte count differs")
    expect("**Captured lines:** 2,357" in analysis, "captured line count differs")
    captured_sha = one(r"\*\*Captured SHA-256:\*\* `([0-9a-f]{64})`", analysis, "captured producer digest")
    expect(captured_sha == expected_sha, "captured producer digest differs")
    expect("**Coverage:** PASS" in analysis and "24 sequential, non-overlapping chunks" in analysis, "complete sequential coverage is not recorded")
    expect("**Decision:** NO-GO" in analysis, "producer analysis lacks an explicit safe/no-go decision")
    expect("does not provide the required current-core input maps" in analysis, "no-go rationale is missing")

    r10 = require_text(R10_RECEIPT)
    expect("R10 is spent" in r10 and "will not be retried" in r10, "R10 closure receipt does not preserve its no-retry status")
    expect("R10 is not reused" in r10, "R10 reuse is not explicitly excluded")

    print("PASS: proposal digest, independent review, complete R11 capture, and explicit no-go result are consistent.")
    print("STOP: no current-core generation or partition is supported under the reviewed source and execution limits.")


def self_test() -> None:
    known_mfas = {("Elixir.Kernel", "MACRO-..//", 4), ("Elixir.Kernel", "apply", 2),
                  ("Elixir.Kernel.SpecialForms", "MACRO-::", 3)}
    odd_name = mfa_from_text("Elixir.Kernel:MACRO-..///4", "self-test", known_mfas)
    expect(odd_name == ("Elixir.Kernel", "MACRO-..//", 4), "greedy MFA parser lost a slash in the function name")
    expect(mfa_from_tuple(["Elixir.Kernel", "MACRO-..//", 4], "self-test") == odd_name,
           "tuple MFA parser disagrees with string MFA parser")
    colon_name = mfa_from_text("Elixir.Kernel.SpecialForms:MACRO-::/3", "self-test", known_mfas)
    expect(colon_name == ("Elixir.Kernel.SpecialForms", "MACRO-::", 3),
           "known-module MFA parser split a colon from the function name")
    expect(canonical_mfa_digest([odd_name, ("Elixir.Kernel", "apply", 2)])
           == canonical_mfa_digest([("Elixir.Kernel", "apply", 2), odd_name]),
           "canonical MFA digest depends on input order")
    bad_values = ["Elixir.Kernel:apply/nope", "Elixir.Kernel:apply/256", "Elixir.Kernel:/1",
                  "Elixir.Unknown:apply/2"]
    for value in bad_values:
        try:
            mfa_from_text(value, "self-test", known_mfas)
        except ValidationError:
            continue
        raise ValidationError(f"self-test accepted malformed MFA: {value}")
    try:
        mfa_from_text("A:B:C/1", "self-test", {("A", "B:C", 1), ("A:B", "C", 1)})
    except ValidationError as exc:
        expect("ambiguously" in str(exc), "ambiguous MFA split failed for the wrong reason")
    else:
        raise ValidationError("self-test accepted an ambiguous MFA split")
    membership = [
        {"identity_id": "CN-002", "mfa": ["Elixir.Demo", "compile", 1]},
        {"identity_id": "CN-003", "mfa": ["Elixir.Demo", "compile", 2]},
        {"identity_id": "CN-004", "mfa": ["Elixir.Demo", "build", 1]},
    ]
    family = membership[:2]
    complement = membership[2:]
    counts = {"membership": 3, "family": 2, "complement": 1}
    digests = {"membership": canonical_membership_digest("core", membership),
               "family": canonical_membership_digest("core", family),
               "complement": canonical_membership_digest("core", complement)}
    validate_scope_partition("core", membership, family, complement, counts, digests)
    invalid_partitions = [
        ("core", membership, family + complement[:1], complement, counts, digests),
        ("core", membership, family, [], counts, digests),
        ("floor", membership, family, complement, counts, digests),
        ("core", membership, family, complement, {**counts, "complement": 2}, digests),
    ]
    for control in invalid_partitions:
        try:
            validate_scope_partition(*control)
        except ValidationError:
            continue
        raise ValidationError("self-test accepted overlap, missing complement, lane digest drift, or count drift")
    mutated_stops = dict(EXPECTED_PRESERVED_STOPS)
    mutated_stops["walking_skeleton"] = "ready"
    try:
        validate_preserved_stop_state(mutated_stops)
    except ValidationError:
        pass
    else:
        raise ValidationError("self-test accepted a mutated protected stop")
    validate_no_retry_identity("01", EXPECTED_NO_RETRY_REQUEST_ID)
    for batch, request_id in (("02", EXPECTED_NO_RETRY_REQUEST_ID), ("01", "core-source-02")):
        try:
            validate_no_retry_identity(batch, request_id)
        except ValidationError:
            continue
        raise ValidationError("self-test accepted a different or misbatched no-retry request")
    estimate = token_estimate(3500)
    expect(estimate["low"] == 778 and estimate["point"] == 1000 and estimate["high"] == 1167,
           "self-test token range sizing is inconsistent")
    assert_manifest_export_coverage({"one.beam", "two.beam"}, {"one.beam": [("M", "f", 0)], "two.beam": [("N", "g", 1)]})
    for manifest_paths, exports_by_beam in (
        ({"one.beam", "two.beam"}, {"one.beam": [("M", "f", 0)]}),
        ({"one.beam"}, {"one.beam": [("M", "f", 0)], "unlisted.beam": [("N", "g", 1)]}),
    ):
        try:
            assert_manifest_export_coverage(manifest_paths, exports_by_beam)
        except ValidationError:
            continue
        raise ValidationError("self-test accepted incomplete or unlisted manifest export coverage")
    for value in (["Elixir.Kernel", "apply"], ["", "apply", 1], ["Elixir.Kernel", "apply", True], ["Elixir.Kernel", "apply", 256]):
        try:
            mfa_from_tuple(value, "self-test")
        except ValidationError:
            continue
        raise ValidationError(f"self-test accepted malformed MFA tuple: {value!r}")
    print("PASS: offline controls preserve unusual MFA names, reject malformed identities, prove a full partition, and preserve stop state.")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stage", choices=["producer-review", "retained-inputs", "current-generation", "build-scope",
                                             "schedule-review", "source-approval", "observations", "finalize",
                                             "rebind-redaction"])
    parser.add_argument("--batch", choices=["01", "02", "03", "04", "05"])
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--check", action="store_true")
    parser.add_argument("--check-summary", action="store_true")
    args = parser.parse_args()
    try:
        selected = sum((args.self_test, args.check, args.check_summary))
        if selected > 1 or (selected and args.stage):
            raise ValidationError("select exactly one stage, --self-test, --check, or --check-summary")
        if args.self_test:
            self_test()
        elif args.check:
            validate_final_reconciliation()
            print("PASS: complete final reconciliation, exact request coverage, sizing, review bindings, and stops.")
        elif args.check_summary:
            return validate_reconciliation_summary()
        elif args.stage == "producer-review":
            validate_producer_review()
        elif args.stage == "retained-inputs":
            return validate_retained_inputs()
        elif args.stage == "current-generation":
            return validate_current_generation()
        elif args.stage == "build-scope":
            return build_scope_and_schedule()
        elif args.stage == "schedule-review":
            validate_scope_artifacts(require_review=True)
        elif args.stage == "source-approval":
            return create_source_approval()
        elif args.stage == "observations":
            if args.batch is None:
                raise ValidationError("--stage observations requires --batch 01|02|03|04|05")
            return validate_observation_batch(args.batch)
        elif args.stage == "finalize":
            return finalize_reconciliation()
        elif args.stage == "rebind-redaction":
            return rebind_redacted_reconciliation()
        else:
            raise ValidationError("select a supported --stage, --self-test, --check, or --check-summary; observations also requires --batch")
    except ValidationError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
