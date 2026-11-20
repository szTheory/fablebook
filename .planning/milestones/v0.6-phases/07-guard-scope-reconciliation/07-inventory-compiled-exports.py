#!/usr/bin/env python3
"""Build a bounded, metadata-only Phase 7 BEAM export inventory.

The reader decodes the BEAM atom table as UTF-8 strings and the export table
as integer references. It seeks over every other chunk, including debug info.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
import shutil
import stat
import struct
import subprocess
import sys
from pathlib import Path


PHASE_REL = Path(".planning/phases/07-guard-scope-reconciliation")
MANIFEST_NAME = "07-CORE-CURRENT-BEAM-MANIFEST.jsonl"
ROOTS_NAME = "07-CORE-CURRENT-BEAM-ROOTS.json"
EXPORTS_NAME = "07-CORE-CURRENT-EXPORTS.jsonl"
SUMMARY_NAME = "07-CORE-CURRENT-EXPORTS-SUMMARY.json"
REVIEW_NAME = "07-CORE-EXPORT-READER-REVIEW.md"
APPROVAL_NAME = "07-CORE-EXPORT-READER-APPROVAL.json"
PHASE_FILES = {MANIFEST_NAME, ROOTS_NAME, EXPORTS_NAME, SUMMARY_NAME, REVIEW_NAME, APPROVAL_NAME}
MAX_BEAM_FILES = 5_000
MAX_BEAM_BYTES = 256 * 1024 * 1024
MAX_CHUNK_BYTES = 8 * 1024 * 1024
MAX_TOTAL_TABLE_BYTES = 64 * 1024 * 1024
MAX_ATOMS = 100_000
MAX_ATOM_BYTES = 1_048_576
EXPECTED_LOCK_SHA256 = "31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112"
EXPECTED_TOOL_VERSIONS_SHA256 = "0d8e4f1d2fbde0cd63e4c45a60bbb4827058a592ee8b37057980627fcb517233"
EXPECTED_MIX_EXS_SHA256 = "0d8aae670b99fd5d3d519c0ec16bd44455397bc98f1a8f8b33864255f3e61ac9"
EXPECTED_OTP = "29.1.2"
EXPECTED_ELIXIR = "1.20.4-otp-29"
DIRECT_RUNTIME_APPS = ("phoenix", "phoenix_live_view", "phoenix_html", "telemetry", "nimble_options")
ELIXIR_APPS = ("elixir", "eex", "mix", "iex", "logger", "ex_unit")
APP_TERM_RE = re.compile(rb'^\{\s*application\s*,\s*([A-Za-z0-9_]+)\s*,\s*(\[.*\])\s*\}$', re.S)
APP_PROPERTY_RE = re.compile(rb'^\{\s*([a-z][a-zA-Z0-9_]*)\s*,\s*(.*?)\s*\}$', re.S)
APP_VSN_RE = re.compile(rb'^"([^"\\]+)"$')
HEX_TOP_FIELD_RE = re.compile(rb'^\{\s*<<"([a-z_]+)">>\s*,\s*(.*?)\s*\}$', re.S)
SAFE_APP_RE = re.compile(r"[a-z][a-z0-9_]*\Z")
LOCK_ENTRY_RE = re.compile(
    r'^\s*"([a-z0-9_]+)"\s*:\s*\{:hex,\s*:[a-z0-9_]+,\s*'
    r'"([^"\\]+)",\s*"([0-9a-f]{64})".*?"([0-9a-f]{64})"\s*\},?\s*$'
)


class Stop(RuntimeError):
    pass


def fail(message: str) -> None:
    raise Stop(message)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def canonical_export_bytes(exports: list[tuple[str, str, int]]) -> bytes:
    encoded = bytearray()
    for module, function, arity in sorted(set(exports)):
        for value in (module, function):
            raw = value.encode("utf-8", "strict")
            encoded.extend(struct.pack(">I", len(raw)))
            encoded.extend(raw)
        encoded.extend(struct.pack(">I", arity))
    return bytes(encoded)


def file_identity(info: os.stat_result) -> dict[str, int]:
    return {
        "bytes": info.st_size,
        "device": info.st_dev,
        "inode": info.st_ino,
        "mtime_ns": info.st_mtime_ns,
        "ctime_ns": info.st_ctime_ns,
    }


def no_symlink(path: Path) -> None:
    absolute = Path(os.path.abspath(path))
    current = Path(absolute.anchor)
    for part in absolute.parts[1:]:
        current = current / part
        try:
            info = os.lstat(current)
        except OSError as exc:
            fail(f"could not check pinned path {current}: {exc}")
        if stat.S_ISLNK(info.st_mode):
            fail(f"a pinned path contains a symbolic link: {current}")


def is_inside(root: Path, path: Path) -> bool:
    root = root.resolve(strict=True)
    path = path.resolve(strict=False)
    return path == root or root in path.parents


def read_file(path: Path, cap: int | None = None) -> bytes:
    no_symlink(path)
    try:
        before_path = os.lstat(path)
    except OSError as exc:
        fail(f"could not stat metadata file {path.name}: {exc}")
    if stat.S_ISLNK(before_path.st_mode) or not stat.S_ISREG(before_path.st_mode):
        fail(f"expected a regular metadata file: {path.name}")
    if cap is not None and before_path.st_size > cap:
        fail(f"metadata file is larger than its limit: {path.name}")
    flags = os.O_RDONLY
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        fd = os.open(path, flags)
    except OSError as exc:
        fail(f"could not safely open metadata file {path.name}: {exc}")
    try:
        before_fd = os.fstat(fd)
        identity_keys = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
        if (not stat.S_ISREG(before_fd.st_mode)
                or any(getattr(before_fd, key) != getattr(before_path, key) for key in identity_keys)):
            fail(f"metadata file changed before it was read: {path.name}")
        chunks = []
        remaining = before_fd.st_size
        while remaining:
            chunk = os.read(fd, min(remaining, 1024 * 1024))
            if not chunk:
                fail(f"metadata file changed while being read: {path.name}")
            chunks.append(chunk)
            remaining -= len(chunk)
        after_fd = os.fstat(fd)
        if any(getattr(before_fd, key) != getattr(after_fd, key) for key in identity_keys):
            fail(f"metadata file changed while being read: {path.name}")
        return b"".join(chunks)
    finally:
        os.close(fd)


def parse_tool_versions(data: bytes) -> dict[str, str]:
    try:
        lines = data.decode("utf-8", "strict").splitlines()
    except UnicodeDecodeError as exc:
        fail(f".tool-versions is not UTF-8: {exc}")
    result: dict[str, str] = {}
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        fields = line.split()
        if len(fields) != 2 or fields[0] in result:
            fail(".tool-versions has a malformed or duplicate entry")
        result[fields[0]] = fields[1]
    return result


def asdf_root(tool: str, version: str) -> Path:
    executable = shutil.which("asdf")
    if executable is None:
        fail("asdf is required to resolve the exact pinned compiler/runtime roots")
    try:
        raw = subprocess.check_output([executable, "where", tool, version], text=True, stderr=subprocess.PIPE).strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        fail(f"could not resolve pinned {tool} {version} root: {exc}")
    root = Path(raw)
    no_symlink(root)
    if not root.is_dir():
        fail(f"pinned {tool} root is not a directory")
    return root


def resolved_root_record(root: Path, tool: str, version: str) -> dict:
    asdf_data = Path(os.environ.get("ASDF_DATA_DIR", str(Path.home() / ".asdf"))).resolve(strict=True)
    actual = root.resolve(strict=True)
    if not is_inside(asdf_data, actual):
        fail(f"resolved {tool} root is outside the configured asdf data directory")
    info = os.stat(actual)
    relative = actual.relative_to(asdf_data).as_posix()
    return {
        "locator": f"@ASDF_DATA_DIR/{relative}", "tool": tool, "version": version,
        "path_sha256": sha256(str(actual).encode("utf-8")), "device": info.st_dev, "inode": info.st_ino,
    }


def parse_app_metadata(path: Path) -> tuple[str, str]:
    data = read_file(path, 2 * 1024 * 1024)
    return parse_app_metadata_data(data, path.name)


def strip_erlang_comments(data: bytes, label: str) -> bytes:
    """Blank Erlang comments outside strings/quoted atoms without evaluating terms."""
    output = bytearray(data)
    quote = None
    escaped = False
    comment = False
    position = 0
    while position < len(data):
        byte = data[position]
        if comment:
            if byte in (ord("\n"), ord("\r")):
                comment = False
            else:
                output[position] = ord(" ")
            position += 1
            continue
        if quote is not None:
            if escaped:
                escaped = False
            elif byte == ord("\\"):
                escaped = True
            elif byte == quote:
                quote = None
            position += 1
            continue
        if byte in (ord('"'), ord("'")):
            quote = byte
        elif byte == ord("%"):
            comment = True
            output[position] = ord(" ")
        elif byte == ord("$"):
            # A percent sign immediately after $ is a character literal, not a comment.
            # Replace the literal bytes with spaces so brackets/commas in a character
            # escape cannot affect the surrounding metadata delimiters.
            end = position + 1
            if end >= len(data):
                fail(f"application metadata ends with an incomplete character literal: {label}")
            if data[end] == ord("\\"):
                end += 1
                if end >= len(data):
                    fail(f"application metadata has an incomplete character escape: {label}")
                escape = data[end]
                if escape == ord("x") and end + 1 < len(data) and data[end + 1] == ord("{"):
                    close = data.find(b"}", end + 2)
                    if close < 0:
                        fail(f"application metadata has an incomplete hexadecimal character escape: {label}")
                    end = close
                elif escape == ord("x"):
                    end = min(end + 2, len(data) - 1)
                elif escape == ord("^"):
                    end = min(end + 1, len(data) - 1)
                elif ord("0") <= escape <= ord("7"):
                    while end + 1 < len(data) and end < position + 5 and ord("0") <= data[end + 1] <= ord("7"):
                        end += 1
            for index in range(position, end + 1):
                output[index] = ord(" ")
            position = end + 1
            continue
        position += 1
    return bytes(output)


def parse_app_metadata_data(data: bytes, label: str) -> tuple[str, str]:
    data = strip_erlang_comments(data, label)
    position = 0
    for line in data.splitlines(keepends=True):
        stripped = line.lstrip()
        if not stripped.strip() or stripped.startswith(b"%"):
            position += len(line)
            continue
        break
    term_start = position
    term_end = balanced_delimiter(data, term_start, ord("{"), ord("}"), label)
    term = data[term_start:term_end]
    term_match = APP_TERM_RE.fullmatch(term)
    if not term_match:
        fail(f"application metadata has an unsupported shape: {label}")
    app_name = term_match.group(1).decode("ascii")
    props = term_match.group(2).strip()
    props_inner, props_end = balanced_list(props, 0, label)
    if props_end != len(props):
        fail(f"application metadata properties are malformed: {label}")
    version_values = []
    for raw_property in split_top_level(props_inner, label):
        match = APP_PROPERTY_RE.fullmatch(raw_property)
        if not match:
            fail(f"application metadata property has an unsupported shape: {label}")
        if match.group(1) == b"vsn":
            version_values.append(match.group(2).strip())
    if len(version_values) != 1:
        fail(f"application metadata must contain exactly one version field: {label}")
    version_match = APP_VSN_RE.fullmatch(version_values[0])
    if not version_match:
        fail(f"application metadata version is not a supported string: {label}")
    tail = data[term_end:].lstrip()
    if not tail.startswith(b"."):
        fail(f"application metadata tuple is not terminated: {label}")
    for line in tail[1:].splitlines():
        stripped = line.strip()
        if stripped and not stripped.startswith(b"%"):
            fail(f"application metadata has trailing data after its tuple: {label}")
    try:
        return app_name, version_match.group(1).decode("ascii")
    except UnicodeDecodeError:
        fail(f"application identity is not ASCII: {label}")


def portable_path(path: Path, allowed_root: Path, label: str) -> str:
    relative = path.relative_to(allowed_root).as_posix()
    return label if relative == "." else f"{label}/{relative}"


def app_record(ebin: Path, kind: str, package: str, package_version: str, checksums: list[str], allowed_root: Path, root_label: str) -> tuple[dict, list[dict]]:
    ebin = Path(os.path.abspath(ebin))
    no_symlink(ebin)
    if not ebin.is_dir() or not is_inside(allowed_root, ebin):
        fail("application ebin root is missing or escaped its pinned root")
    app_files = sorted(path for path in ebin.iterdir() if path.name.endswith(".app"))
    if len(app_files) != 1:
        fail("application ebin must contain exactly one .app metadata file")
    app, version = parse_app_metadata(app_files[0])
    app_root = ebin.parent
    no_symlink(app_root)
    beams: list[dict] = []
    for path in sorted(ebin.iterdir()):
        if not path.name.endswith(".beam"):
            continue
        no_symlink(path)
        info = os.lstat(path)
        if not stat.S_ISREG(info.st_mode):
            fail("a compiled input is not a regular file")
        identity = file_identity(info)
        beams.append({
            "type": "beam", "kind": kind, "app": app, "app_version": version,
            "package": package, "package_version": package_version,
            "lock_checksums": checksums, "root": portable_path(app_root, allowed_root, root_label),
            "ebin": portable_path(ebin, allowed_root, root_label),
            "path": portable_path(path, allowed_root, root_label),
            "expected_module": path.name[:-5], **identity,
        })
    root_record = {
        "type": "root", "kind": kind, "app": app, "version": version,
        "package": package, "package_version": package_version,
        "lock_checksums": checksums, "root": portable_path(app_root, allowed_root, root_label),
        "ebin": portable_path(ebin, allowed_root, root_label),
        "beam_count": len(beams), "beam_bytes": sum(row["bytes"] for row in beams),
    }
    return root_record, beams


def otp_roots(otp_lib: Path) -> list[tuple[dict, list[dict]]]:
    no_symlink(otp_lib)
    results = []
    for app_dir in sorted(otp_lib.iterdir()):
        if not app_dir.is_dir():
            continue
        ebin = app_dir / "ebin"
        if ebin.is_dir():
            results.append(app_record(ebin, "otp", "", "", [], otp_lib, "@OTP_ROOT/lib"))
    if not results:
        fail("the pinned OTP installation has no applications")
    return results


def elixir_roots(elixir_lib: Path) -> list[tuple[dict, list[dict]]]:
    results = []
    for app in ELIXIR_APPS:
        ebin = elixir_lib / app / "ebin"
        if not ebin.is_dir():
            fail(f"expected exactly one pinned Elixir application root: {app}")
        root, beams = app_record(ebin, "elixir", "", "", [], elixir_lib, "@ELIXIR_ROOT/lib")
        if root["app"] != app:
            fail("an Elixir application name did not match its pinned root")
        results.append((root, beams))
    return results


def parse_lock(data: bytes) -> dict[str, tuple[str, list[str]]]:
    try:
        lines = data.decode("utf-8", "strict").splitlines()
    except UnicodeDecodeError as exc:
        fail(f"mix.lock is not UTF-8: {exc}")
    result: dict[str, tuple[str, list[str]]] = {}
    for line in lines:
        if not line.lstrip().startswith('"'):
            continue
        match = LOCK_ENTRY_RE.match(line)
        if not match:
            fail("mix.lock has an unsupported Hex entry")
        package, version, package_checksum, repo_checksum = match.groups()
        if package in result:
            fail("mix.lock contains a duplicate package entry")
        result[package] = (version, [package_checksum.decode() if isinstance(package_checksum, bytes) else package_checksum, repo_checksum])
    return result


def parse_hex_metadata(path: Path) -> tuple[str, str, list[tuple[str, str, bool]]]:
    data = read_file(path, 8 * 1024 * 1024)
    return parse_hex_metadata_data(data, path.name)


def parse_hex_metadata_data(data: bytes, label: str) -> tuple[str, str, list[tuple[str, str, bool]]]:
    fields = {}
    binary_re = re.compile(rb'^<<"([^"\\]+)">>$')
    position = 0
    while position < len(data):
        while position < len(data) and data[position] in b" \t\r\n":
            position += 1
        if position == len(data):
            break
        if data[position] != ord("{"):
            fail(f"Hex metadata has an unsupported top-level shape: {label}")
        end = balanced_delimiter(data, position, ord("{"), ord("}"), label)
        record = data[position:end]
        match = HEX_TOP_FIELD_RE.fullmatch(record)
        if not match:
            fail(f"Hex metadata field has an unsupported top-level shape: {label}")
        key = match.group(1).decode("ascii")
        if key in fields:
            fail(f"Hex metadata has a duplicate top-level field: {key}")
        fields[key] = match.group(2).strip()
        position = end
        while position < len(data) and data[position] in b" \t\r\n":
            position += 1
        if position >= len(data) or data[position] != ord("."):
            fail(f"Hex metadata top-level field is missing its terminator: {label}")
        position += 1
    for required in ("name", "version"):
        if required not in fields:
            fail(f"Hex metadata must contain exactly one {required}: {label}")
    if "requirements" not in fields:
        fail(f"Hex metadata must contain its requirements field: {label}")
    parsed_identity = {}
    for key in ("name", "version"):
        value = binary_re.fullmatch(fields[key])
        if not value:
            fail(f"Hex metadata {key} is not a UTF-8 binary string: {label}")
        try:
            parsed_identity[key] = value.group(1).decode("ascii")
        except UnicodeDecodeError:
            fail(f"Hex metadata {key} is not ASCII: {label}")
    requirements_value = read_hex_requirements(data, label)
    return parsed_identity["name"], parsed_identity["version"], requirements_value


def split_top_level(data: bytes, label: str) -> list[bytes]:
    """Split a bounded Erlang-like metadata list without evaluating its terms."""
    parts = []
    start = 0
    stack = []
    quoted = False
    escaped = False
    pairs = {ord("]"): ord("["), ord("}"): ord("{"), ord(")"): ord("(")}
    for position, byte in enumerate(data):
        if quoted:
            if escaped:
                escaped = False
            elif byte == ord("\\"):
                escaped = True
            elif byte == ord('"'):
                quoted = False
            continue
        if byte == ord('"'):
            quoted = True
        elif byte in (ord("["), ord("{"), ord("(")):
            stack.append(byte)
        elif byte in pairs:
            if not stack or stack.pop() != pairs[byte]:
                fail(f"Hex requirements have unbalanced delimiters: {label}")
        elif byte == ord(",") and not stack:
            part = data[start:position].strip()
            if not part:
                fail(f"Hex requirements contain an empty entry: {label}")
            parts.append(part)
            start = position + 1
    if quoted or stack:
        fail(f"Hex requirements are truncated or malformed: {label}")
    tail = data[start:].strip()
    if tail:
        parts.append(tail)
    elif data.strip():
        fail(f"Hex requirements have a trailing separator: {label}")
    return parts


def balanced_list(data: bytes, open_position: int, label: str) -> tuple[bytes, int]:
    if open_position >= len(data) or data[open_position] != ord("["):
        fail(f"Hex requirements list is missing: {label}")
    depth = 0
    quoted = False
    escaped = False
    for position in range(open_position, len(data)):
        byte = data[position]
        if quoted:
            if escaped:
                escaped = False
            elif byte == ord("\\"):
                escaped = True
            elif byte == ord('"'):
                quoted = False
            continue
        if byte == ord('"'):
            quoted = True
        elif byte == ord("["):
            depth += 1
        elif byte == ord("]"):
            depth -= 1
            if depth == 0:
                return data[open_position + 1:position], position + 1
            if depth < 0:
                break
    fail(f"Hex requirements list is unterminated: {label}")


def balanced_delimiter(data: bytes, open_position: int, opening: int, closing: int, label: str) -> int:
    if open_position >= len(data) or data[open_position] != opening:
        fail(f"Hex metadata record is missing its opening delimiter: {label}")
    depth = 0
    quoted = False
    escaped = False
    for position in range(open_position, len(data)):
        byte = data[position]
        if quoted:
            if escaped:
                escaped = False
            elif byte == ord("\\"):
                escaped = True
            elif byte == ord('"'):
                quoted = False
            continue
        if byte == ord('"'):
            quoted = True
        elif byte == opening:
            depth += 1
        elif byte == closing:
            depth -= 1
            if depth == 0:
                return position + 1
            if depth < 0:
                break
    fail(f"Hex metadata record is unterminated: {label}")


def read_hex_requirements(data: bytes, label: str) -> list[tuple[str, str, bool]]:
    marker = b'{<<"requirements">>,'
    start = data.find(marker)
    if start < 0 or data.find(marker, start + len(marker)) >= 0:
        fail(f"Hex metadata must contain exactly one requirements field: {label}")
    list_start = start + len(marker)
    while list_start < len(data) and data[list_start] in b" \t\r\n":
        list_start += 1
    body, end = balanced_list(data, list_start, label)
    if not data[end:].lstrip().startswith(b"}"):
        fail(f"Hex requirements field has an unsupported ending: {label}")
    if not body.strip():
        return []
    result = []
    field_re = re.compile(rb'^\{\s*<<"([a-z_]+)">>\s*,\s*(.*?)\s*\}$', re.S)
    binary_re = re.compile(rb'^<<"([^"\\]+)">>$')
    for entry in split_top_level(body, label):
        if not entry.startswith(b"[") or not entry.endswith(b"]"):
            fail(f"Hex requirement entry is not a property list: {label}")
        fields = {}
        for raw_field in split_top_level(entry[1:-1], label):
            match = field_re.fullmatch(raw_field)
            if not match:
                fail(f"Hex requirement field has an unsupported shape: {label}")
            key = match.group(1).decode("ascii")
            if key in fields:
                fail(f"Hex requirement contains a duplicate field: {label}")
            fields[key] = match.group(2).strip()
        if not {"name", "app", "optional"} <= fields.keys():
            fail(f"Hex requirement lacks name, app, or optional: {label}")
        name_match = binary_re.fullmatch(fields["name"])
        app_match = binary_re.fullmatch(fields["app"])
        optional = fields["optional"]
        if not name_match or not app_match or optional not in (b"true", b"false"):
            fail(f"Hex requirement identity or optional flag is malformed: {label}")
        try:
            package = name_match.group(1).decode("ascii")
            app = app_match.group(1).decode("ascii")
        except UnicodeDecodeError:
            fail(f"Hex requirement name is not ASCII: {label}")
        if not SAFE_APP_RE.fullmatch(package) or not SAFE_APP_RE.fullmatch(app):
            fail(f"Hex requirement name is unsafe as a dependency path: {label}")
        result.append((package, app, optional == b"true"))
    return result


def dependency_roots(project: Path, build_lib: Path, deps_dir: Path, lock_data: bytes) -> list[tuple[dict, list[dict]]]:
    lock = parse_lock(lock_data)
    queue = list(DIRECT_RUNTIME_APPS)
    seen: set[str] = set()
    packages: dict[str, tuple[str, list[str]]] = {}
    while queue:
        app = queue.pop(0)
        if app in seen:
            continue
        if not SAFE_APP_RE.fullmatch(app):
            fail(f"runtime dependency app name is unsafe as a path: {app!r}")
        seen.add(app)
        metadata_path = deps_dir / app / "hex_metadata.config"
        no_symlink(metadata_path)
        if not is_inside(deps_dir, metadata_path):
            fail("runtime dependency metadata path escaped the dependency directory")
        package, version, requirements = parse_hex_metadata(metadata_path)
        if package != app:
            fail(f"runtime dependency app/package alias requires explicit review: {app}")
        locked = lock.get(package)
        if locked is None or locked[0] != version:
            fail(f"runtime dependency does not match the full lock identity: {package}")
        packages[app] = (version, locked[1])
        for requirement_package, required_app, optional in requirements:
            if not optional:
                if requirement_package != required_app:
                    fail("required dependency app/package alias requires explicit review")
                queue.append(required_app)

    results = []
    for app in sorted(seen):
        version, checksums = packages[app]
        ebin = build_lib / app / "ebin"
        root, beams = app_record(ebin, "dependency", app, version, checksums, build_lib, "_build/test/lib")
        if root["app"] != app or root["version"] != version:
            fail("compiled dependency app/version does not match its locked package")
        results.append((root, beams))
    return results


def context() -> dict:
    project = Path.cwd()
    no_symlink(project)
    project = project.resolve(strict=True)
    if os.environ.get("FABLEBOOK_FLOOR"):
        fail("the core inventory cannot run with FABLEBOOK_FLOOR set")
    lock_path = project / "mix.lock"
    tool_path = project / ".tool-versions"
    mix_path = project / "mix.exs"
    lock_data = read_file(lock_path, 2 * 1024 * 1024)
    tool_data = read_file(tool_path, 4096)
    mix_data = read_file(mix_path, 256 * 1024)
    if sha256(lock_data) != EXPECTED_LOCK_SHA256:
        fail("root mix.lock differs from the selected core baseline")
    if sha256(tool_data) != EXPECTED_TOOL_VERSIONS_SHA256:
        fail(".tool-versions differs from the selected runtime baseline")
    if sha256(mix_data) != EXPECTED_MIX_EXS_SHA256:
        fail("mix.exs differs from the reviewed runtime dependency declaration")
    versions = parse_tool_versions(tool_data)
    otp_version = versions.get("erlang")
    elixir_version = versions.get("elixir")
    if otp_version != EXPECTED_OTP or elixir_version != EXPECTED_ELIXIR:
        fail("toolchain versions do not match the selected release")
    otp_install = asdf_root("erlang", otp_version)
    elixir_install = asdf_root("elixir", elixir_version)
    otp_lib = otp_install / "lib"
    elixir_lib = elixir_install / "lib"
    no_symlink(otp_lib)
    no_symlink(elixir_lib)
    if not otp_lib.is_dir() or not elixir_lib.is_dir():
        fail("pinned runtime library root is missing")
    phase = project / PHASE_REL
    no_symlink(phase)
    if not phase.is_dir():
        fail("active Phase 7 output directory is missing")
    producer = project / PHASE_REL / "07-inventory-compiled-exports.py"
    no_symlink(producer)
    if not producer.is_file():
        fail("the compiled inventory producer is missing")
    build_lib = project / "_build/test/lib"
    deps_dir = project / "deps"
    no_symlink(build_lib)
    no_symlink(deps_dir)
    return {
        "project": str(project), "lock_path": "mix.lock", "lock_sha256": sha256(lock_data),
        "tool_versions_path": ".tool-versions", "tool_versions_sha256": sha256(tool_data),
        "mix_exs_path": "mix.exs", "mix_exs_sha256": sha256(mix_data),
        "otp_version": otp_version, "elixir_version": elixir_version,
        "otp_root": "@OTP_ROOT/lib", "elixir_root": "@ELIXIR_ROOT/lib",
        "resolved_roots": {
            "otp_lib": resolved_root_record(otp_lib, "erlang", otp_version),
            "elixir_lib": resolved_root_record(elixir_lib, "elixir", elixir_version),
        },
        "otp_root_actual": str(otp_lib), "elixir_root_actual": str(elixir_lib),
        "producer_path": (PHASE_REL / producer.name).as_posix(),
        "producer_sha256": sha256(read_file(producer, 2 * 1024 * 1024)),
        "build_lib": str(build_lib), "deps_dir": str(deps_dir), "lock_data": lock_data,
    }


def canonical_jsonl(rows: list[dict]) -> bytes:
    return b"".join((json.dumps(row, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode() for row in rows)


def validate_beam_manifest_rows(beams: list[dict]) -> None:
    if len({row.get("path") for row in beams}) != len(beams):
        fail("compiled-file manifest contains duplicate paths")
    if len({row.get("expected_module") for row in beams}) != len(beams):
        fail("compiled-file roots contain a duplicate module name")


def validate_exact_manifest_membership(reviewed_data: bytes, fresh_rows: list[dict]) -> None:
    if canonical_jsonl(fresh_rows) != reviewed_data:
        fail("current package/runtime/file metadata no longer matches the reviewed manifest")


def manifest_rows(ctx: dict) -> list[dict]:
    roots = otp_roots(Path(ctx["otp_root_actual"])) + elixir_roots(Path(ctx["elixir_root_actual"]))
    roots += dependency_roots(Path(ctx["project"]), Path(ctx["build_lib"]), Path(ctx["deps_dir"]), ctx["lock_data"])
    app_names = [root["app"] for root, _beams in roots]
    app_roots = [root["root"] for root, _beams in roots]
    if len(app_names) != len(set(app_names)) or len(app_roots) != len(set(app_roots)):
        fail("an application is assigned to multiple roots")
    beams = [row for _root, rows in roots for row in rows]
    if len(beams) == 0 or len(beams) > MAX_BEAM_FILES or sum(row["bytes"] for row in beams) > MAX_BEAM_BYTES:
        fail("compiled-file manifest is empty or exceeds the reviewed bounds")
    beams.sort(key=lambda row: row["path"])
    validate_beam_manifest_rows(beams)
    identity = {
        "type": "identity", "schema": "fablebook.phase7.compiled_manifest.v2",
        "lock_path": ctx["lock_path"], "lock_sha256": ctx["lock_sha256"],
        "tool_versions_path": ctx["tool_versions_path"], "tool_versions_sha256": ctx["tool_versions_sha256"],
        "mix_exs_path": ctx["mix_exs_path"], "mix_exs_sha256": ctx["mix_exs_sha256"],
        "otp_version": ctx["otp_version"], "elixir_version": ctx["elixir_version"],
        "otp_root": ctx["otp_root"], "elixir_root": ctx["elixir_root"],
        "resolved_roots": ctx["resolved_roots"],
        "producer_path": ctx["producer_path"], "producer_sha256": ctx["producer_sha256"],
    }
    root_rows = [root for root, _beams in roots]
    rows = [identity] + sorted(root_rows, key=lambda row: (row["kind"], row["app"])) + beams
    return rows


def phase_path(name: str) -> Path:
    if name not in PHASE_FILES:
        fail("producer attempted to use an unapproved output filename")
    project = Path.cwd()
    no_symlink(project)
    project = project.resolve(strict=True)
    no_symlink(project)
    phase = project / PHASE_REL
    no_symlink(phase)
    if not is_inside(project, phase) or not phase.is_dir():
        fail("active Phase 7 output path escaped the project")
    path = phase / name
    try:
        info = os.lstat(path)
    except FileNotFoundError:
        return path
    if stat.S_ISLNK(info.st_mode) or not stat.S_ISREG(info.st_mode):
        fail("an approved output path is not a regular file")
    return path


def write_new(name: str, data: bytes) -> None:
    path = phase_path(name)
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    try:
        fd = os.open(path, flags, 0o600)
    except FileExistsError:
        fail(f"refusing to overwrite existing evidence: {name}")
    with os.fdopen(fd, "wb") as handle:
        handle.write(data)
        handle.flush()
        os.fsync(handle.fileno())


def stat_matches(path: Path, row: dict) -> bool:
    try:
        info = os.lstat(path)
    except OSError:
        return False
    return stat.S_ISREG(info.st_mode) and file_identity(info) == {
        key: row[key] for key in ("bytes", "device", "inode", "mtime_ns", "ctime_ns")
    }


def decode_u(data: bytes, position: int) -> tuple[int, int]:
    if position >= len(data):
        fail("BEAM compact integer is truncated")
    first = data[position]
    position += 1
    if first & 0x07 != 0:
        fail("BEAM atom length uses an unsupported compact integer tag")
    if first & 0x08 == 0:
        return first >> 4, position
    if first & 0x10 == 0:
        if position >= len(data):
            fail("BEAM compact integer is truncated")
        return ((first & 0xE0) << 3) | data[position], position + 1
    byte_count = first >> 5
    if byte_count == 7:
        extension, position = decode_u(data, position)
        byte_count = extension + 9
    else:
        byte_count += 2
    if byte_count < 2 or byte_count > 8:
        fail("BEAM atom length exceeds the supported compact integer range")
    end = position + byte_count
    if end > len(data):
        fail("BEAM compact integer payload is truncated")
    return int.from_bytes(data[position:end], "big"), end


def parse_atom_chunk(chunk: bytes, chunk_id: bytes) -> list[str]:
    if len(chunk) < 4:
        fail("BEAM atom table is truncated")
    raw_count = struct.unpack(">I", chunk[:4])[0]
    if chunk_id == b"AtU8" and raw_count >= 0x80000000:
        count = (0x100000000 - raw_count)
        extended_lengths = True
    else:
        count = raw_count
        extended_lengths = False
    if count == 0 or count > MAX_ATOMS:
        fail("BEAM atom count is outside the parser limit")
    names: list[str] = []
    position = 4
    for _ in range(count):
        if extended_lengths:
            length, position = decode_u(chunk, position)
        else:
            if position >= len(chunk):
                fail("BEAM atom length is truncated")
            length = chunk[position]
            position += 1
        if length > MAX_ATOM_BYTES or position + length > len(chunk):
            fail("BEAM atom name is truncated or oversized")
        raw = chunk[position : position + length]
        position += length
        try:
            names.append(raw.decode("utf-8" if chunk_id == b"AtU8" else "latin-1", "strict"))
        except UnicodeDecodeError as exc:
            fail(f"BEAM atom name is not valid UTF-8: {exc}")
    if position != len(chunk):
        fail("BEAM atom table has trailing bytes")
    return names


def parse_exports_chunk(chunk: bytes, atom_names: list[str], module: str) -> list[tuple[str, str, int]]:
    if len(chunk) < 4:
        fail("BEAM exports table is truncated")
    count = struct.unpack(">I", chunk[:4])[0]
    if count > (MAX_CHUNK_BYTES - 4) // 12 or len(chunk) != 4 + count * 12:
        fail("BEAM exports table has an invalid count or length")
    exports = []
    seen = set()
    for index in range(count):
        function_index, arity, label = struct.unpack_from(">III", chunk, 4 + index * 12)
        if function_index == 0 or function_index > len(atom_names) or arity > 255:
            fail("BEAM exports table contains an invalid function index or arity")
        function = atom_names[function_index - 1]
        key = (module, function, arity)
        if not function or key in seen:
            fail("BEAM exports table contains an empty or duplicate MFA")
        seen.add(key)
        exports.append(key)
    return sorted(exports)


def parse_beam(reader, size: int, expected_module: str) -> tuple[list[tuple[str, str, int]], int]:
    header = reader(0, 12)
    if len(header) != 12 or header[:4] != b"FOR1" or header[8:12] != b"BEAM":
        fail("compiled file is not a BEAM container")
    declared = struct.unpack(">I", header[4:8])[0]
    if declared + 8 != size:
        fail("BEAM container size differs from the reviewed file metadata")
    position = 12
    atom_chunks: list[tuple[bytes, int, int]] = []
    export_chunks: list[tuple[int, int]] = []
    chunk_count = 0
    while position < size:
        if position + 8 > size:
            fail("BEAM chunk header is truncated")
        chunk_header = reader(position, 8)
        if len(chunk_header) != 8:
            fail("BEAM chunk header read was incomplete")
        chunk_id = chunk_header[:4]
        chunk_size = struct.unpack(">I", chunk_header[4:])[0]
        start = position + 8
        padded = chunk_size + ((4 - chunk_size % 4) % 4)
        end = start + padded
        if end > size or chunk_size > MAX_CHUNK_BYTES:
            fail("BEAM chunk exceeds its container or parser limit")
        if chunk_id in (b"AtU8", b"Atom"):
            atom_chunks.append((chunk_id, start, chunk_size))
        elif chunk_id == b"ExpT":
            export_chunks.append((start, chunk_size))
        position = end
        chunk_count += 1
        if chunk_count > 4096:
            fail("BEAM file has too many chunks")
    if position != size or len(atom_chunks) != 1 or len(export_chunks) != 1:
        fail("BEAM file must have exactly one atom table and one exports table")
    atom_id, atom_start, atom_size = atom_chunks[0]
    export_start, export_size = export_chunks[0]
    if atom_size + export_size > MAX_TOTAL_TABLE_BYTES:
        fail("BEAM atom and export tables exceed their combined read limit")
    atom_names = parse_atom_chunk(reader(atom_start, atom_size), atom_id)
    if atom_names[0] != expected_module:
        fail("BEAM module name does not match its reviewed file path")
    exports = parse_exports_chunk(reader(export_start, export_size), atom_names, expected_module)
    return exports, atom_size + export_size


def reader_for_file(path: Path, row: dict):
    def read() -> tuple[list[tuple[str, str, int]], int]:
        no_symlink(path)
        if not stat_matches(path, row):
            fail("compiled input metadata changed after manifest approval")
        flags = os.O_RDONLY
        if hasattr(os, "O_NOFOLLOW"):
            flags |= os.O_NOFOLLOW
        fd = os.open(path, flags)
        try:
            before = os.fstat(fd)
            if file_identity(before) != {key: row[key] for key in ("bytes", "device", "inode", "mtime_ns", "ctime_ns")}:
                fail("opened BEAM identity differs from the approved manifest")
            def range_read(offset: int, length: int) -> bytes:
                if length < 0 or length > MAX_CHUNK_BYTES + 12 or offset < 0 or offset + length > row["bytes"]:
                    fail("BEAM parser requested an out-of-range read")
                return os.pread(fd, length, offset)
            result = parse_beam(range_read, row["bytes"], row["expected_module"])
            after = os.fstat(fd)
            if file_identity(before) != file_identity(after) or not stat_matches(path, row):
                fail("BEAM file changed during its selected-chunk read")
            return result
        finally:
            os.close(fd)
    return read


def parse_json_line(line: bytes) -> dict:
    try:
        value = json.loads(line.decode("utf-8", "strict"), object_pairs_hook=unique_object)
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        fail(f"reviewed JSONL has an invalid row: {exc}")
    if not isinstance(value, dict):
        fail("reviewed JSONL contains a non-object row")
    return value


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            fail(f"reviewed JSON contains duplicate key: {key}")
        result[key] = value
    return result


def validate_approval(ctx: dict, manifest_digest: str, root_digest: str) -> None:
    approval_path = phase_path(APPROVAL_NAME)
    review_path = phase_path(REVIEW_NAME)
    approval = json.loads(read_file(approval_path, 64 * 1024), object_pairs_hook=unique_object)
    review = read_file(review_path, 256 * 1024)
    expected = {
        "schema": "fablebook.phase7.exports_review.v2", "verdict": "PASS",
        "review_file_sha256": sha256(review), "producer_sha256": ctx["producer_sha256"],
        "manifest_sha256": manifest_digest, "root_summary_sha256": root_digest,
    }
    if not isinstance(approval, dict) or set(approval) != set(expected) | {"reviewer"}:
        fail("independent reader approval has missing or extra fields")
    if any(approval.get(key) != value for key, value in expected.items()) or not isinstance(approval.get("reviewer"), str) or not approval["reviewer"].strip():
        fail("independent reader approval does not match the exact current review and manifest")
    review_text = review.decode("utf-8", "strict")
    for required in ("PASS", manifest_digest, ctx["producer_sha256"], approval["reviewer"]):
        if required not in review_text:
            fail("independent review does not identify its verdict and exact digests")


def manifest_only() -> None:
    existing = [name for name in (MANIFEST_NAME, ROOTS_NAME) if (Path.cwd() / PHASE_REL / name).exists()]
    if existing:
        fail(f"refusing to overwrite existing manifest evidence: {', '.join(existing)}")
    ctx = context()
    rows = manifest_rows(ctx)
    data = canonical_jsonl(rows)
    roots = [row for row in rows if row.get("type") == "root"]
    root_summary = {
        "schema": "fablebook.phase7.compiled_roots.v1",
        "manifest_sha256": sha256(data),
        "root_count": len(roots),
        "beam_file_count": sum(row["beam_count"] for row in roots),
        "beam_bytes": sum(row["beam_bytes"] for row in roots),
        "roots": roots,
    }
    root_data = (json.dumps(root_summary, sort_keys=True, separators=(",", ":")) + "\n").encode()
    write_new(MANIFEST_NAME, data)
    write_new(ROOTS_NAME, root_data)
    print(f"Manifest SHA-256: {sha256(data)}")
    print(f"Root summary SHA-256: {sha256(root_data)}")
    print(f"BEAM files: {sum(row['type'] == 'beam' for row in rows)}")
    print("Manifest mode read project declarations and package/application metadata plus BEAM file stats; it did not open BEAM contents or target source files.")


def resolve_manifest_path(value: str, ctx: dict) -> Path:
    for label, actual_root in (("@OTP_ROOT/lib", ctx["otp_root_actual"]), ("@ELIXIR_ROOT/lib", ctx["elixir_root_actual"])):
        if value == label:
            return Path(actual_root)
        if value.startswith(label + "/"):
            return Path(actual_root) / value[len(label) + 1 :]
    if value.startswith("_build/test/lib/"):
        return Path(ctx["project"]) / value
    fail("manifest path does not use an approved root label")


def scan(manifest_digest: str) -> None:
    if not re.fullmatch(r"[0-9a-f]{64}", manifest_digest):
        fail("manifest approval must be a lowercase SHA-256 digest")
    existing = [name for name in (EXPORTS_NAME, SUMMARY_NAME) if (Path.cwd() / PHASE_REL / name).exists()]
    if existing:
        fail(f"refusing to overwrite existing export evidence: {', '.join(existing)}")
    ctx = context()
    manifest_data = read_file(phase_path(MANIFEST_NAME), 32 * 1024 * 1024)
    if sha256(manifest_data) != manifest_digest:
        fail("manifest differs from the independently approved digest")
    manifest = [parse_json_line(line) for line in manifest_data.splitlines() if line]
    fresh_rows = manifest_rows(ctx)
    validate_exact_manifest_membership(manifest_data, fresh_rows)
    roots = [row for row in manifest if row.get("type") == "root"]
    root_summary = {
        "schema": "fablebook.phase7.compiled_roots.v1",
        "manifest_sha256": manifest_digest,
        "root_count": len(roots),
        "beam_file_count": sum(row["beam_count"] for row in roots),
        "beam_bytes": sum(row["beam_bytes"] for row in roots),
        "roots": roots,
    }
    root_data = (json.dumps(root_summary, sort_keys=True, separators=(",", ":")) + "\n").encode()
    if read_file(phase_path(ROOTS_NAME), 4 * 1024 * 1024) != root_data:
        fail("root summary differs from the approved manifest")
    validate_approval(ctx, manifest_digest, sha256(root_data))
    beam_rows = [row for row in manifest if row.get("type") == "beam"]
    exports_rows = []
    total_table_bytes = 0
    for row in beam_rows:
        path = resolve_manifest_path(row["path"], ctx)
        exports, table_bytes = reader_for_file(path, row)()
        total_table_bytes += table_bytes
        if total_table_bytes > MAX_TOTAL_TABLE_BYTES:
            fail("selected BEAM tables exceed the scan-wide read limit")
        per_file_digest = sha256(canonical_export_bytes(exports))
        for module, function, arity in exports:
            exports_rows.append({
                "kind": row["kind"], "app": row["app"], "app_version": row["app_version"],
                "package": row["package"], "package_version": row["package_version"],
                "lock_checksums": row["lock_checksums"], "beam_path": row["path"],
                "beam_bytes": row["bytes"], "beam_device": row["device"], "beam_inode": row["inode"],
                "beam_mtime_ns": row["mtime_ns"], "beam_ctime_ns": row["ctime_ns"],
                "exports_sha256": per_file_digest, "module": module,
                "function": function, "arity": arity,
            })
    exports_rows.sort(key=lambda row: (row["module"], row["function"], row["arity"], row["beam_path"]))
    mfa_keys = [(row["module"], row["function"], row["arity"]) for row in exports_rows]
    if len(mfa_keys) != len(set(mfa_keys)):
        fail("one MFA appears in more than one compiled file")
    module_paths = {}
    for row in exports_rows:
        previous_path = module_paths.setdefault(row["module"], row["beam_path"])
        if previous_path != row["beam_path"]:
            fail("one module is provided by more than one reviewed BEAM file")
    exports_data = canonical_jsonl(exports_rows)
    identity = manifest[0]
    summary = {
        "schema": "fablebook.phase7.compiled_exports.v2",
        "lock_sha256": identity["lock_sha256"], "tool_versions_sha256": identity["tool_versions_sha256"],
        "mix_exs_sha256": identity["mix_exs_sha256"], "otp_version": identity["otp_version"],
        "elixir_version": identity["elixir_version"], "producer_sha256": ctx["producer_sha256"],
        "manifest_sha256": manifest_digest,
        "generation_id": "phase7-core-" + manifest_digest[:16],
        "beam_file_count": len(beam_rows), "export_count": len(exports_rows),
        "exports_jsonl_sha256": sha256(exports_data),
        "exports_mfa_sha256": sha256(canonical_export_bytes(mfa_keys)),
        "selected_chunk_bytes": total_table_bytes,
        "input_atom_boundary": "BEAM atom names remain UTF-8 strings; no term or atom decoder is used",
        "source_file_hashes_complete": False,
        "old_whole_inventory_member_list_available": False,
    }
    write_new(EXPORTS_NAME, exports_data)
    write_new(SUMMARY_NAME, (json.dumps(summary, sort_keys=True, separators=(",", ":")) + "\n").encode())
    print(f"Wrote exports: {EXPORTS_NAME}")
    print(f"Export rows: {len(exports_rows)}")
    print(f"Export SHA-256: {sha256(exports_data)}")


def chunk(chunk_id: bytes, data: bytes) -> bytes:
    return chunk_id + struct.pack(">I", len(data)) + data + b"\0" * ((4 - len(data) % 4) % 4)


def encode_u(value: int) -> bytes:
    if value < 16:
        return bytes([(value << 4)])
    if value < 2048:
        return bytes([((value >> 3) & 0xE0) | 0x08, value & 0xFF])
    raw = value.to_bytes((value.bit_length() + 7) // 8, "big")
    if len(raw) <= 8:
        return bytes([((len(raw) - 2) << 5) | 0x18]) + raw
    return bytes([0xF8]) + encode_u(len(raw) - 9) + raw


def build_fixture() -> tuple[bytes, tuple[int, int]]:
    names = ["phase7_fixture", "run", "value"]
    atom_data = struct.pack(">i", -len(names)) + b"".join(
        encode_u(len(value.encode())) + value.encode() for value in names
    )
    exports = struct.pack(">I", 2) + struct.pack(">III", 2, 1, 1) + struct.pack(">III", 3, 0, 2)
    chunks = chunk(b"AtU8", atom_data) + chunk(b"ExpT", exports)
    debug = chunk(b"Dbgi", b"must-not-be-read")
    body = b"BEAM" + chunks + debug
    data = b"FOR1" + struct.pack(">I", len(body)) + body
    debug_payload_start = 12 + len(chunks) + 8
    return data, (debug_payload_start, len(b"must-not-be-read"))


def self_test() -> None:
    fixture, debug_range = build_fixture()
    reads = []
    def memory_reader(offset: int, length: int) -> bytes:
        reads.append((offset, length))
        return fixture[offset : offset + length]
    exports, _ = parse_beam(memory_reader, len(fixture), "phase7_fixture")
    if exports != [("phase7_fixture", "run", 1), ("phase7_fixture", "value", 0)]:
        fail("offline parser self-test returned the wrong exports")
    for boundary in (0, 15, 16, 2047, 2048, 65535, 65536, 1_000_000):
        encoded = encode_u(boundary)
        decoded, end = decode_u(encoded, 0)
        if decoded != boundary or end != len(encoded):
            fail("offline parser self-test failed a compact-length boundary")
    requirement_fixture = (
        b'{<<"requirements">>,\n'
        b' [[{<<"name">>,<<"plug">>},{<<"app">>,<<"plug">>},{<<"optional">>,false},'
        b'{<<"requirement">>,<<"~> 1.0">>}],'
        b'[{<<"name">>,<<"optional_dep">>},{<<"app">>,<<"optional_dep">>},{<<"optional">>,true}]]}.\n'
    )
    requirements = read_hex_requirements(requirement_fixture, "self-test")
    if requirements != [("plug", "plug", False), ("optional_dep", "optional_dep", True)]:
        fail("offline parser self-test failed the complete Hex requirements list")
    metadata_fixture = (
        b'{<<"name">>,<<"sample">>}.\n'
        b'{<<"version">>,<<"1.2.3">>}.\n'
        b'{<<"requirements">>,[[{<<"name">>,<<"plug">>},{<<"app">>,<<"plug">>},{<<"optional">>,false}]]}.\n'
    )
    if parse_hex_metadata_data(metadata_fixture, "self-test") != ("sample", "1.2.3", [("plug", "plug", False)]):
        fail("offline parser self-test failed top-level Hex metadata and nested requirements parsing")
    app_fixture = (
        b"%% generated Erlang application metadata\n\n"
        b'{application,asn1,[{description,"100% safe"},{atom_name,\'quoted%value\'},{printable,$%},\n'
        b' %% this comment contains fake properties, commas, and braces: {vsn,"9.9"}\n'
        b' {vsn,"5.5.2"},\n {modules,[asn1ct]}\n'
        b' %% this closing comment must not be parsed as another property\n ]}.\n'
    )
    if parse_app_metadata_data(app_fixture, "self-test") != ("asn1", "5.5.2"):
        fail("offline parser self-test failed a comment-prefixed OTP application file")
    for malformed_app in (
        b'{application,asn1,[{vsn,"1.0"}]',
        b'{application,asn1,[{vsn,"1.0"},{vsn,"2.0"}]}.',
        b'{application,asn1,[{vsn,"1.0"}]}.{application,other,[{vsn,"1.0"}]}.',
    ):
        try:
            parse_app_metadata_data(malformed_app, "self-test")
        except Stop:
            continue
        fail("offline parser self-test accepted malformed application metadata")
    try:
        read_hex_requirements(b'{<<"requirements">>,[[{<<"name">>,<<"../escape">>},{<<"app">>,<<"../escape">>},{<<"optional">>,false}]]}.', "self-test")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a path-traversal dependency name")
    try:
        read_hex_requirements(b'{<<"requirements">>,[[{<<"name">>,<<"plug">>},{<<"app">>,<<"plug">>}]]}.', "self-test")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a dependency with a missing optional flag")
    legacy_atoms = parse_atom_chunk(b"\0\0\0\2\5mod_x\3run", b"Atom")
    if legacy_atoms != ["mod_x", "run"]:
        fail("offline parser self-test failed the legacy Latin-1 atom table")
    debug_start, debug_length = debug_range
    if any(offset < debug_start + debug_length and offset + length > debug_start for offset, length in reads):
        fail("offline parser self-test touched the debug information chunk")
    try:
        parse_atom_chunk(struct.pack(">i", -1) + b"\x18\x00", b"AtU8")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted malformed atom lengths")
    try:
        parse_exports_chunk(struct.pack(">I", 1), ["phase7_fixture"], "phase7_fixture")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a truncated exports table")
    duplicate_exports = struct.pack(">I", 2) + struct.pack(">III", 2, 1, 1) * 2
    try:
        parse_exports_chunk(duplicate_exports, ["phase7_fixture", "run"], "phase7_fixture")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a duplicate export")
    try:
        parse_beam(memory_reader, len(fixture), "different_module")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a module/path mismatch")
    duplicate_fixture = fixture[:12] + chunk(b"AtU8", struct.pack(">i", -1) + encode_u(1) + b"x") + fixture[12:]
    def duplicate_reader(offset: int, length: int) -> bytes:
        return duplicate_fixture[offset : offset + length]
    try:
        parse_beam(duplicate_reader, len(duplicate_fixture), "phase7_fixture")
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted duplicate atom chunks")
    fixture_manifest = [
        {"type": "beam", "path": "runtime/lib/one.beam", "expected_module": "one"},
        {"type": "beam", "path": "runtime/lib/two.beam", "expected_module": "two"},
    ]
    fixture_manifest_data = canonical_jsonl(fixture_manifest)
    validate_exact_manifest_membership(fixture_manifest_data, fixture_manifest)
    try:
        validate_exact_manifest_membership(fixture_manifest_data, fixture_manifest + [
            {"type": "beam", "path": "runtime/lib/third.beam", "expected_module": "third"}
        ])
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a changed reviewed-file membership set")
    try:
        validate_beam_manifest_rows([
            {"path": "runtime/a.beam", "expected_module": "same"},
            {"path": "dependency/b.beam", "expected_module": "same"},
        ])
    except Stop:
        pass
    else:
        fail("offline parser self-test accepted a duplicate compiled module identity")
    print("Phase 7 compiled inventory self-test passed (string-only tables; debug chunk skipped).")


def main(args: list[str]) -> int:
    if args == ["--self-test"]:
        self_test()
    elif args == ["--manifest-only"]:
        manifest_only()
    elif len(args) == 3 and args[:2] == ["--scan", "--manifest-sha256"]:
        scan(args[2])
    else:
        fail("usage: --self-test | --manifest-only | --scan --manifest-sha256 DIGEST")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except Stop as exc:
        print(f"Phase 7 compiled inventory stopped: {exc}", file=sys.stderr)
        raise SystemExit(1)
