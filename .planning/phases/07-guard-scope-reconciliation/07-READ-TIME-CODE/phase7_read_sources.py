#!/usr/bin/env python3
"""Perform only the independently approved one-use Phase 7 source reads."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import stat
import sys


PHASE = Path(__file__).resolve().parent
SCHEDULE = PHASE / "07-SOURCE-SCHEDULE.json"
APPROVAL = PHASE / "07-SOURCE-APPROVAL.json"
CONSUMPTION = PHASE / "07-SOURCE-READ-CONSUMPTION"
MAX_FILE_BYTES = 2 * 1024 * 1024
NO_RETRY_REQUEST_ID = "core-source-01"
NO_RETRY_STOP_SHA256 = "609d035c28cdd0b351273d83e2fd30674bc2fa63f57f63a55512446dada6eec4"
NO_RETRY_MARKER_SHA256 = "810a5f74c46afe81426e5e25cb7e29447ae0401028e799f1fb3cae396fb7fe4a"
INITIAL_REVIEW_SHA256 = "d75119bb910ac98740eeb8fa6b388d4871e05774dc410870c7ca41d5edd2024a"
CONSUMED_REVIEW_SHA256 = "39ae7c1356f7d8b8ace6472eb84b1f2a7ec1c4a235223e42b4240dc274262234"
CONSUMED_REVIEW_PATH = "07-SOURCE-READER-REVIEW-CONSUMED.md"
INTERRUPTED_STOP_SHA256 = "b24c444733f896db8898266cf89dc7b7431a8fe9e27149ea4e336254b7fb9cb4"
INTERRUPTED_MARKER_SHA256 = {
    "core-source-02": "36f8039b02f9c0feac2ed7eba8728f9874d64dcf3f2517076e8206c05f2a12c4",
    "core-source-03": "52a70e1f5f91c69dd549da161301abc88dac466bbb281bdf49c2f37d7f3b571b",
}
INTERRUPTED_REQUEST_IDS = ("core-source-01", "core-source-02", "core-source-03")
INTERRUPTED_ERROR = "KeyError: ('Elixir.Phoenix.LiveView.ColocatedAssets', 'compile', 0)"


class ReadError(RuntimeError):
    pass


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def canonical_json(value: object) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode()


def open_directory_nofollow(path: Path) -> int:
    absolute = Path(os.path.abspath(path))
    flags = os.O_RDONLY | getattr(os, "O_DIRECTORY", 0)
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        fd = os.open(absolute.anchor, flags)
        for component in absolute.parts[1:]:
            next_fd = os.open(component, flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        return fd
    except OSError as exc:
        try:
            os.close(fd)
        except (OSError, UnboundLocalError):
            pass
        raise ReadError(f"cannot safely open fixed directory {path}: {exc}") from exc


def open_parent_nofollow(path: Path) -> tuple[int, str]:
    absolute = Path(os.path.abspath(path))
    if not absolute.is_absolute() or len(absolute.parts) < 2:
        raise ReadError(f"expected an absolute fixed file path: {path}")
    return open_directory_nofollow(absolute.parent), absolute.name


def read_fixed_regular(path: Path, cap: int) -> tuple[bytes, dict[str, int]]:
    parent_fd, leaf = open_parent_nofollow(path)
    flags = os.O_RDONLY | (os.O_NOFOLLOW if hasattr(os, "O_NOFOLLOW") else 0)
    try:
        before_path = os.stat(leaf, dir_fd=parent_fd, follow_symlinks=False)
        if not stat.S_ISREG(before_path.st_mode) or before_path.st_size > cap:
            raise ReadError(f"fixed input is not a regular file within its cap: {path.name}")
        fd = os.open(leaf, flags, dir_fd=parent_fd)
    except OSError as exc:
        os.close(parent_fd)
        raise ReadError(f"cannot safely open fixed input {path.name}: {exc}") from exc
    except ReadError:
        os.close(parent_fd)
        raise
    try:
        before = os.fstat(fd)
        expected_keys = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
        if (not stat.S_ISREG(before.st_mode) or before.st_size > cap
                or any(getattr(before, key) != getattr(before_path, key) for key in expected_keys)):
            raise ReadError(f"fixed input changed before it was read: {path.name}")
        chunks = []
        remaining = before.st_size
        while remaining:
            block = os.read(fd, min(remaining, 1024 * 1024))
            if not block:
                raise ReadError(f"fixed input changed while it was read: {path.name}")
            chunks.append(block)
            remaining -= len(block)
        after = os.fstat(fd)
        if any(getattr(before, key) != getattr(after, key) for key in expected_keys):
            raise ReadError(f"fixed input changed during its read: {path.name}")
        return b"".join(chunks), stat_record(after)
    finally:
        os.close(fd)
        os.close(parent_fd)


def load_module_from_bytes(name: str, path: Path, source: bytes):
    module = type(sys)(name)
    module.__file__ = str(path)
    module.__package__ = ""
    sys.modules[name] = module
    code = compile(source, str(path), "exec", dont_inherit=True)
    exec(code, module.__dict__)
    return module


def write_new(path: Path, data: bytes) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    parent_fd, leaf = open_parent_nofollow(path)
    try:
        fd = os.open(leaf, flags, 0o600, dir_fd=parent_fd)
    except FileExistsError as exc:
        os.close(parent_fd)
        raise ReadError(f"refusing to overwrite one-use output {path.name}") from exc
    except OSError as exc:
        os.close(parent_fd)
        raise ReadError(f"cannot safely create one-use output {path.name}: {exc}") from exc
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(data)
            handle.flush()
            os.fsync(handle.fileno())
    finally:
        os.close(parent_fd)


def stat_record(info: os.stat_result) -> dict[str, int]:
    return {"device": info.st_dev, "inode": info.st_ino, "size_bytes": info.st_size,
            "mtime_ns": info.st_mtime_ns, "ctime_ns": info.st_ctime_ns}


def fixed_exists_nofollow(path: Path) -> bool:
    parent_fd, leaf = open_parent_nofollow(path)
    try:
        try:
            os.stat(leaf, dir_fd=parent_fd, follow_symlinks=False)
            return True
        except FileNotFoundError:
            return False
    finally:
        os.close(parent_fd)


def open_consumption_dir(create: bool) -> int | None:
    phase_fd = open_directory_nofollow(PHASE)
    try:
        if create:
            try:
                os.mkdir(CONSUMPTION.name, mode=0o700, dir_fd=phase_fd)
            except FileExistsError:
                pass
        try:
            flags = os.O_RDONLY | getattr(os, "O_DIRECTORY", 0)
            if hasattr(os, "O_NOFOLLOW"):
                flags |= os.O_NOFOLLOW
            return os.open(CONSUMPTION.name, flags, dir_fd=phase_fd)
        except FileNotFoundError:
            return None
        except OSError as exc:
            raise ReadError(f"one-use ledger is not a real directory: {exc}") from exc
    finally:
        os.close(phase_fd)


def request_was_consumed(request_id: str) -> bool:
    ledger_fd = open_consumption_dir(create=False)
    if ledger_fd is None:
        return False
    try:
        try:
            os.stat(f"{request_id}.json", dir_fd=ledger_fd, follow_symlinks=False)
            return True
        except FileNotFoundError:
            return False
    finally:
        os.close(ledger_fd)


def consume_marker(request_id: str, schedule_sha: str, approval_sha: str,
                   reader_review: dict, entry: dict) -> dict:
    marker = {"schema": "fablebook.phase7.read_once/1", "request_id": request_id,
              "schedule_sha256": schedule_sha, "target_path": entry["target_path"],
              "approval_sha256": approval_sha, "reader_review_sha256": reader_review["review_sha256"],
              "started_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
              "status": "consumed_before_open"}
    ledger_fd = open_consumption_dir(create=True)
    if ledger_fd is None:
        raise ReadError("one-use ledger directory disappeared before marker creation")
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        fd = os.open(f"{request_id}.json", flags, 0o600, dir_fd=ledger_fd)
    except FileExistsError as exc:
        os.close(ledger_fd)
        raise ReadError(f"one-use request already consumed; no retry is permitted: {request_id}") from exc
    except OSError as exc:
        os.close(ledger_fd)
        raise ReadError(f"cannot safely create one-use marker: {request_id}: {exc}") from exc
    try:
        with os.fdopen(fd, "wb") as handle:
            handle.write(canonical_json(marker))
            handle.flush()
            os.fsync(handle.fileno())
        os.fsync(ledger_fd)
    finally:
        os.close(ledger_fd)
    return marker


def parser_failure_observation(entry: dict, schedule_sha: str, reader_review: dict,
                              approval_sha: str, marker: dict, error_type: str,
                              error_message: str, file_provenance: dict | None,
                              stop_provenance: dict | None = None,
                              observation_status: str | None = None) -> dict:
    status = observation_status or ("parse_failed_no_retry" if stop_provenance else "parse_failed")
    unavailable = ("unavailable because the exact file did not parse"
                   if status in {"parse_failed", "parse_failed_no_retry"}
                   else "unavailable because no durable observation was recorded for this consumed request")
    failed_selectors = [{
        "identity_id": selector["identity_id"], "mfa": selector["mfa"],
        "definition_spans": [], "same_file_static_references": [],
        "reference_scope": unavailable,
        "claim_limit": "No definition or caller claim is possible for this file.",
    } for selector in entry["mfa_span_selectors"]]
    return {
        "schema": "fablebook.phase7.source_observation/1", "request_id": entry["request_id"],
        "lane": entry["lane"], "batch": entry["batch"], "target_path": entry["target_path"],
        "source_identity": entry["source_identity"],
        "mfa_span_selectors": entry["mfa_span_selectors"],
        "schedule_sha256": schedule_sha, "approval_sha256": approval_sha,
        "reader_review": reader_review,
        "observation_status": status,
        "parse_failure": {
            "error_type": error_type, "error": error_message,
            "source_hash_captured": file_provenance is not None,
            "retry_permitted": False,
            "stop_receipt": stop_provenance,
        },
        "consumption_marker": {"path": f"{CONSUMPTION.name}/{entry['request_id']}.json",
                                "status": marker["status"]},
        "file_provenance": file_provenance,
        "observations": failed_selectors,
        "explicit_gaps": ([
            f"The static parser rejected this exact source file: {error_type}: {error_message}.",
            "No definition or caller spans are claimed for this file.",
            "The consumed request will not be reopened; a content hash is unavailable." if file_provenance is None
            else "The file was read once and hashed, but its definitions and caller references remain unavailable.",
            "No other source file was searched for callers.",
            "Aliases, imports, captures, dynamic dispatch, callbacks, macro expansion, and generated code are unresolved.",
            "Cross-lane source behavior is recorded separately; floor observations do not rescan or upgrade its accepted ENV06 membership provenance.",
        ] if status in {"parse_failed", "parse_failed_no_retry"} else [
            f"The approved batch stopped after this request was consumed: {error_type}: {error_message}.",
            "No durable source hash or selector spans were recorded; this request will not be reopened.",
            "No other source file was searched for callers.",
            "Aliases, imports, captures, dynamic dispatch, callbacks, macro expansion, and generated code are unresolved.",
            "Cross-lane source behavior is recorded separately; floor observations do not rescan or upgrade its accepted ENV06 membership provenance.",
        ]),
        "runtime_calls": False, "generated_code_executed": False,
        "package_wide_search": False, "caller_closure_claim": "none",
    }


def read_one(entry: dict, schedule_sha: str, observer, reader_review: dict,
             approval_sha: str, consumed_requests: set[str]) -> dict:
    request_id = entry["request_id"]
    target = Path(entry["target_path"])
    try:
        parent_fd, leaf = open_parent_nofollow(target)
    except OSError as exc:
        raise ReadError(f"scheduled target parent cannot be opened without links: {request_id}: {exc}") from exc
    expected = entry["expected_file_stat"]
    fd = None
    try:
        before_path = os.stat(leaf, dir_fd=parent_fd, follow_symlinks=False)
        if (stat.S_ISLNK(before_path.st_mode) or not stat.S_ISREG(before_path.st_mode)
                or stat_record(before_path) != expected
                or before_path.st_size > min(MAX_FILE_BYTES, entry["max_read_bytes"])):
            raise ReadError(f"scheduled source identity drifted before open: {request_id}")
        marker = consume_marker(request_id, schedule_sha, approval_sha, reader_review, entry)
        consumed_requests.add(request_id)
        flags = os.O_RDONLY | (os.O_NOFOLLOW if hasattr(os, "O_NOFOLLOW") else 0)
        try:
            fd = os.open(leaf, flags, dir_fd=parent_fd)
        except OSError as exc:
            raise ReadError(f"one-use source open failed after consumption marker: {request_id}: {exc}") from exc
        opened = os.fstat(fd)
        if stat_record(opened) != expected or not stat.S_ISREG(opened.st_mode):
            raise ReadError(f"opened file identity differs from its approved stat record: {request_id}")
        with os.fdopen(fd, "rb", closefd=True) as handle:
            fd = None
            content = handle.read(min(MAX_FILE_BYTES, entry["max_read_bytes"]) + 1)
            after = os.fstat(handle.fileno())
        if len(content) != expected["size_bytes"] or len(content) > min(MAX_FILE_BYTES, entry["max_read_bytes"]):
            raise ReadError(f"one-use bounded read length differs from the reviewed file size: {request_id}")
        if stat_record(after) != expected:
            raise ReadError(f"scheduled file changed during its one-use read: {request_id}")
    finally:
        if fd is not None:
            os.close(fd)
        os.close(parent_fd)

    selectors = [(selector["mfa"][0], selector["mfa"][1], selector["mfa"][2])
                 for selector in entry["mfa_span_selectors"]]
    parser_selectors = [((module[7:] if module.startswith("Elixir.") else module), function, arity)
                        for module, function, arity in selectors]
    language = "erlang" if target.suffix == ".erl" else "elixir"
    try:
        extracted = observer.extract_mfa_spans(content, language, selectors)
        for module, function, arity in parser_selectors:
            result = extracted.get((module, function, arity)) if isinstance(extracted, dict) else None
            if (not isinstance(result, dict) or not isinstance(result.get("definitions"), list)
                    or not isinstance(result.get("references"), list)):
                raise observer.ObserverError(
                    f"parser returned no complete result for selected MFA {module}:{function}/{arity}"
                )
    except observer.ObserverError as exc:
        return parser_failure_observation(
            entry, schedule_sha, reader_review, approval_sha, marker,
            type(exc).__name__, str(exc),
            {"size_bytes": len(content), "sha256": sha256(content),
             "stat_before": stat_record(opened), "stat_after": stat_record(after)},
        )
    observations = []
    for selector_record, parser_mfa in zip(entry["mfa_span_selectors"], parser_selectors):
        mfa = tuple(selector_record["mfa"])
        result = extracted[parser_mfa]
        definitions = []
        for definition in result["definitions"]:
            definitions.append({key: definition[key] for key in ("start_byte", "end_byte", "start_line", "end_line", "kind")
                                if key in definition})
        references = [{key: reference[key] for key in ("start_byte", "end_byte", "line")}
                      for reference in result["references"]]
        observations.append({
            "identity_id": selector_record["identity_id"], "mfa": list(mfa),
            "definition_spans": definitions, "same_file_static_references": references,
            "reference_scope": "statically recognizable same-module calls in this exact file only",
            "claim_limit": "These observations do not establish that all callers or delegates are known.",
        })
    return {
        "schema": "fablebook.phase7.source_observation/1", "request_id": request_id,
        "lane": entry["lane"], "batch": entry["batch"], "target_path": entry["target_path"],
        "source_identity": entry["source_identity"],
        "mfa_span_selectors": entry["mfa_span_selectors"],
        "schedule_sha256": schedule_sha,
        "approval_sha256": approval_sha,
        "reader_review": reader_review,
        "observation_status": "parsed", "parse_failure": None,
        "consumption_marker": {"path": f"{CONSUMPTION.name}/{request_id}.json", "status": marker["status"]},
        "file_provenance": {"size_bytes": len(content), "sha256": sha256(content),
                             "stat_before": stat_record(opened), "stat_after": stat_record(after)},
        "observations": observations,
        "explicit_gaps": [
            "No other source file was searched for callers.",
            "Aliases, imports, captures, dynamic dispatch, callbacks, macro expansion, and generated code are unresolved.",
            "Cross-lane source behavior is recorded separately; floor observations do not rescan or upgrade its accepted ENV06 membership provenance.",
        ],
        "runtime_calls": False, "generated_code_executed": False, "package_wide_search": False,
        "caller_closure_claim": "none",
    }


def precheck_entry(entry: dict) -> None:
    target = Path(entry["target_path"])
    parent_fd, leaf = open_parent_nofollow(target)
    try:
        info = os.stat(leaf, dir_fd=parent_fd, follow_symlinks=False)
    except OSError as exc:
        os.close(parent_fd)
        raise ReadError(f"scheduled target cannot be stat-verified before batch access: {entry['request_id']}: {exc}") from exc
    try:
        if (stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode)
                or stat_record(info) != entry["expected_file_stat"]
                or info.st_size > min(MAX_FILE_BYTES, entry["max_read_bytes"])):
            raise ReadError(f"scheduled source identity drifted before any batch file was opened: {entry['request_id']}")
    finally:
        os.close(parent_fd)


def review_field(review: str, heading: str) -> str:
    prefix = f"**{heading}:** `"
    for line in review.splitlines():
        if line.startswith(prefix) and line.endswith("`"):
            return line[len(prefix):-1]
    plain_prefix = f"**{heading}:** "
    for line in review.splitlines():
        if line.startswith(plain_prefix):
            return line[len(plain_prefix):]
    raise ReadError(f"source-reader review is missing {heading}")


def reviewed_code_bundle() -> tuple[dict, bytes, bytes, bytes]:
    review_path = PHASE / "07-SOURCE-READER-REVIEW-CONTINUATION.md"
    reader_path = PHASE / "phase7_read_sources.py"
    launcher_path = PHASE / "phase7_source_launcher.py"
    bootstrap_path = PHASE / "phase7_source_bootstrap.py"
    parser_path = PHASE / "phase7_source_observer.py"
    validator_path = PHASE / "07-validate-reconciliation.py"
    review_bytes, _ = read_fixed_regular(review_path, 1024 * 1024)
    reader_bytes, _ = read_fixed_regular(reader_path, 4 * 1024 * 1024)
    launcher_bytes, _ = read_fixed_regular(launcher_path, 1024 * 1024)
    bootstrap_bytes, _ = read_fixed_regular(bootstrap_path, 1024 * 1024)
    parser_bytes, _ = read_fixed_regular(parser_path, 4 * 1024 * 1024)
    validator_bytes, _ = read_fixed_regular(validator_path, 8 * 1024 * 1024)
    try:
        review = review_bytes.decode("utf-8", "strict")
    except UnicodeDecodeError as exc:
        raise ReadError("source-reader review is not strict UTF-8") from exc
    if "**Verdict:** PASS" not in review or "**Reviewer opened target source bodies:** no" not in review:
        raise ReadError("independent source-reader review is not a clean PASS")
    expected_prior_evidence = {
        "No-retry request ID": NO_RETRY_REQUEST_ID,
        "Prior STOP SHA-256": NO_RETRY_STOP_SHA256,
        "Prior marker SHA-256": NO_RETRY_MARKER_SHA256,
        "Initial review SHA-256": INITIAL_REVIEW_SHA256,
        "Interrupted request IDs": ",".join(INTERRUPTED_REQUEST_IDS),
        "Interrupted STOP SHA-256": INTERRUPTED_STOP_SHA256,
        "Interrupted marker core-source-02 SHA-256": INTERRUPTED_MARKER_SHA256["core-source-02"],
        "Interrupted marker core-source-03 SHA-256": INTERRUPTED_MARKER_SHA256["core-source-03"],
        "Interrupted review SHA-256": CONSUMED_REVIEW_SHA256,
    }
    for heading, expected_value in expected_prior_evidence.items():
        if review_field(review, heading) != expected_value:
            raise ReadError(f"continuation review does not bind the immutable prior evidence: {heading}")
    reviewer = review_field(review, "Reviewer")
    if not reviewer or reviewer == "schedule author":
        raise ReadError("source-reader reviewer is missing or not independent")
    expected = {
        "Reader SHA-256": sha256(reader_bytes),
        "Launcher SHA-256": sha256(launcher_bytes),
        "Bootstrap SHA-256": sha256(bootstrap_bytes),
        "Parser SHA-256": sha256(parser_bytes),
        "Validator SHA-256": sha256(validator_bytes),
    }
    for heading, digest in expected.items():
        if review_field(review, heading) != digest:
            raise ReadError(f"reviewed source code changed after review: {heading}")
    return ({"reviewer": reviewer, "review_sha256": sha256(review_bytes),
             "reader_sha256": expected["Reader SHA-256"],
             "launcher_sha256": expected["Launcher SHA-256"],
             "bootstrap_sha256": expected["Bootstrap SHA-256"],
             "parser_sha256": expected["Parser SHA-256"],
             "validator_sha256": expected["Validator SHA-256"]}, reader_bytes, parser_bytes, validator_bytes)


def run_batch(batch: str) -> int:
    reviewed, _reader_bytes, parser_bytes, validator_bytes = reviewed_code_bundle()
    validator = load_module_from_bytes("phase7_validator_for_source_reads", PHASE / "07-validate-reconciliation.py", validator_bytes)
    _reconciliation, schedule, _reconciliation_raw, schedule_raw, approval_bytes = validator.validate_scope_artifacts(
        require_review=True, require_approval=True)
    if not isinstance(approval_bytes, bytes):
        raise ReadError("validated source approval bytes were not returned by the review gate")
    reader_review = validator.validate_source_reader_review()
    if reader_review != reviewed:
        raise ReadError("validator's source-reader review check differs from the safely loaded review bundle")
    schedule_sha = sha256(schedule_raw)
    entries = [entry for entry in schedule["entries"] if entry["batch"] == batch]
    if len(entries) > 5:
        raise ReadError(f"batch {batch} exceeds five scheduled files")
    assigned = sorted(entry["request_id"] for entry in entries)
    expected = schedule.get("batches", {}).get(batch, [])
    if assigned != sorted(expected):
        raise ReadError(f"batch {batch} entry list differs from the approved schedule")
    output_path = PHASE / f"07-OBSERVATIONS-{int(batch):02}.jsonl"
    if fixed_exists_nofollow(output_path):
        raise ReadError(f"refusing to rerun a one-use batch with an existing output: {output_path.name}")
    stop_path = PHASE / f"07-OBSERVATIONS-{int(batch):02}.STOP.json"
    continuation_stop_path = PHASE / f"07-OBSERVATIONS-{int(batch):02}.CONTINUATION.STOP.json"
    recovery_stop_path = PHASE / f"07-OBSERVATIONS-{int(batch):02}.RECOVERY.STOP.json"
    if fixed_exists_nofollow(recovery_stop_path):
        raise ReadError(f"batch {batch} has a prior recovery stop; no retry is permitted")
    approval_sha = sha256(approval_bytes)
    if batch == "01":
        if NO_RETRY_REQUEST_ID not in assigned:
            raise ReadError("required no-retry request is absent from batch 01; no reads are permitted")
        marker_path = CONSUMPTION / f"{NO_RETRY_REQUEST_ID}.json"
        if not fixed_exists_nofollow(stop_path) or not fixed_exists_nofollow(marker_path):
            raise ReadError("required no-retry STOP and marker are missing; batch 01 cannot be treated as fresh")
    prior_failures = []
    consumed_before_batch: set[str] = set()
    if fixed_exists_nofollow(stop_path):
        stop, stop_raw = validator.read_json_bytes(stop_path, 64 * 1024)
        consumed_ids = stop.get("consumed_requests")
        if (stop.get("schema") != "fablebook.phase7.source_read_stop/1"
                or stop.get("batch") != batch or stop.get("schedule_sha256") != schedule_sha
                or stop.get("output_exists") is not False or not isinstance(consumed_ids, list)
                or len(consumed_ids) != 1 or not isinstance(stop.get("error"), str)
                or not stop["error"].startswith("ObserverError: ")):
            raise ReadError(f"batch {batch} prior stop is not the exact recoverable parser-failure receipt")
        failed_id = consumed_ids[0]
        if (batch != "01" or failed_id != NO_RETRY_REQUEST_ID
                or sha256(stop_raw) != NO_RETRY_STOP_SHA256):
            raise ReadError("prior failure is not the pinned core-source-01 no-retry receipt")
        failed_entry = next((entry for entry in entries if entry["request_id"] == failed_id), None)
        if failed_entry is None:
            raise ReadError("prior parser-failure request is outside this exact scheduled batch")
        marker_path = CONSUMPTION / f"{failed_id}.json"
        marker, marker_raw = validator.read_json_bytes(marker_path, 16 * 1024)
        initial_review_bytes, _ = read_fixed_regular(PHASE / "07-SOURCE-READER-REVIEW.md", 1024 * 1024)
        initial_review_sha = sha256(initial_review_bytes)
        initial_review = initial_review_bytes.decode("utf-8", "strict")
        if (sha256(marker_raw) != NO_RETRY_MARKER_SHA256
                or initial_review_sha != INITIAL_REVIEW_SHA256
                or marker.get("schema") != "fablebook.phase7.read_once/1"
                or marker.get("request_id") != failed_id or marker.get("schedule_sha256") != schedule_sha
                or marker.get("approval_sha256") != approval_sha
                or marker.get("target_path") != failed_entry["target_path"]
                or marker.get("status") != "consumed_before_open"
                or marker.get("reader_review_sha256") != initial_review_sha
                or "**Verdict:** PASS" not in initial_review
                or "**Target source bodies read:** no" not in initial_review):
            raise ReadError("prior parser-failure marker is not bound to its original approval and code review")
        prior_failures.append(parser_failure_observation(
            failed_entry, schedule_sha, reader_review, approval_sha, marker,
            "ObserverError", stop["error"].split(": ", 1)[1], None,
            {"path": stop_path.name, "stop_sha256": sha256(stop_raw),
             "marker_sha256": sha256(marker_raw), "initial_review_sha256": initial_review_sha},
        ))
        consumed_before_batch.add(failed_id)
    if fixed_exists_nofollow(continuation_stop_path):
        if batch != "01":
            raise ReadError("an unreviewed continuation stop exists for this batch; no source may be reopened")
        stop, stop_raw = validator.read_json_bytes(continuation_stop_path, 64 * 1024)
        if (sha256(stop_raw) != INTERRUPTED_STOP_SHA256
                or stop.get("schema") != "fablebook.phase7.source_read_stop/1"
                or stop.get("batch") != "01" or stop.get("schedule_sha256") != schedule_sha
                or stop.get("output_exists") is not False
                or stop.get("consumed_requests") != list(INTERRUPTED_REQUEST_IDS)
                or stop.get("prior_stop_sha256") != NO_RETRY_STOP_SHA256
                or stop.get("error") != INTERRUPTED_ERROR):
            raise ReadError("batch-01 continuation stop differs from the exact pinned interrupted attempt")
        consumed_review_bytes, _ = read_fixed_regular(PHASE / CONSUMED_REVIEW_PATH, 1024 * 1024)
        consumed_review_sha = sha256(consumed_review_bytes)
        consumed_review = consumed_review_bytes.decode("utf-8", "strict")
        if (consumed_review_sha != CONSUMED_REVIEW_SHA256
                or "**Verdict:** PASS" not in consumed_review
                or "**Reviewer opened target source bodies:** no" not in consumed_review):
            raise ReadError("preserved review for the interrupted attempt is missing or mismatched")
        by_id = {entry["request_id"]: entry for entry in entries}
        for request_id in ("core-source-02", "core-source-03"):
            entry = by_id.get(request_id)
            if entry is None:
                raise ReadError(f"interrupted request is outside the exact batch schedule: {request_id}")
            marker, marker_raw = validator.read_json_bytes(CONSUMPTION / f"{request_id}.json", 16 * 1024)
            if (sha256(marker_raw) != INTERRUPTED_MARKER_SHA256[request_id]
                    or marker.get("schema") != "fablebook.phase7.read_once/1"
                    or marker.get("request_id") != request_id
                    or marker.get("schedule_sha256") != schedule_sha
                    or marker.get("approval_sha256") != approval_sha
                    or marker.get("target_path") != entry["target_path"]
                    or marker.get("status") != "consumed_before_open"
                    or marker.get("reader_review_sha256") != consumed_review_sha):
                raise ReadError(f"interrupted consumed marker is not bound to the exact prior review: {request_id}")
            error_type = "BatchOutputLost" if request_id == "core-source-02" else "SelectorKeyNormalizationMismatch"
            error_message = (
                "No durable observation was written before the batch stopped on core-source-03."
                if request_id == "core-source-02"
                else "Reader lookup used the Elixir-prefixed MFA key, but parser result keys had the prefix normalized."
            )
            prior_failures.append(parser_failure_observation(
                entry, schedule_sha, reader_review, approval_sha, marker,
                error_type, error_message, None,
                {"path": continuation_stop_path.name, "stop_sha256": sha256(stop_raw),
                 "marker_sha256": sha256(marker_raw), "initial_review_sha256": consumed_review_sha},
                "batch_stopped_no_retry",
            ))
            consumed_before_batch.add(request_id)
    elif batch == "01" and any(request_was_consumed(request_id) for request_id in ("core-source-02", "core-source-03")):
        raise ReadError("interrupted batch markers exist without their pinned continuation STOP; no reads are permitted")
    if entries:
        duplicates = sorted(request_id for request_id in assigned
                            if request_id not in consumed_before_batch and request_was_consumed(request_id))
        if duplicates:
            raise ReadError(f"one-use request already consumed; no retry is permitted: {duplicates}")
        for entry in entries:
            if entry["request_id"] not in consumed_before_batch:
                precheck_entry(entry)
    observer = load_module_from_bytes("phase7_source_span_observer", PHASE / "phase7_source_observer.py", parser_bytes)
    consumed_requests: set[str] = set(consumed_before_batch)
    try:
        observations = list(prior_failures)
        for entry in entries:
            if entry["request_id"] not in consumed_before_batch:
                observations.append(read_one(entry, schedule_sha, observer, reader_review, approval_sha, consumed_requests))
        encoded = b"".join(canonical_json(item) for item in observations)
        write_new(output_path, encoded)
    except Exception as exc:
        stop = {"schema": "fablebook.phase7.source_read_stop/1", "batch": batch,
                "schedule_sha256": schedule_sha, "error": f"{type(exc).__name__}: {exc}",
                "consumed_requests": sorted(consumed_requests),
                "output_exists": fixed_exists_nofollow(output_path),
                "prior_stop_sha256": sha256(validator.read_capped(stop_path, 64 * 1024))
                if prior_failures else None,
                "prior_continuation_stop_sha256": sha256(validator.read_capped(continuation_stop_path, 64 * 1024))
                if fixed_exists_nofollow(continuation_stop_path) else None}
        try:
            failure_receipt_path = (
                recovery_stop_path if fixed_exists_nofollow(continuation_stop_path)
                else continuation_stop_path if prior_failures else stop_path
            )
            write_new(failure_receipt_path, canonical_json(stop))
        except Exception as receipt_exc:
            raise ReadError(
                f"batch stopped after consuming {sorted(consumed_requests)}; the one-use markers block retries, "
                f"but STOP receipt persistence failed at {failure_receipt_path.name}: {type(receipt_exc).__name__}: {receipt_exc}"
            ) from receipt_exc
        raise ReadError(f"batch {batch} stopped; consumed files will not be reopened: {type(exc).__name__}: {exc}") from exc
    print(f"PASS: batch {batch} recorded {len(observations)} exact one-use observations; target bodies are not stored in the output.")
    print(f"Observation bytes: {len(encoded)}; output: {output_path.name}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--batch", required=True, choices=["01", "02", "03", "04", "05"])
    args = parser.parse_args()
    try:
        return run_batch(args.batch)
    except (ReadError, OSError, ValueError) as exc:
        print(f"STOP: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
