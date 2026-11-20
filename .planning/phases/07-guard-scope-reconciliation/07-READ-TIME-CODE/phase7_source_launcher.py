#!/usr/bin/env python3
"""Load the independently reviewed Phase 7 reader from exact verified bytes."""

from __future__ import annotations

import hashlib
import os
from pathlib import Path
import re
import stat
import sys
import types


PHASE = Path(os.path.abspath(__file__)).parent
REVIEW_NAME = "07-SOURCE-READER-REVIEW-CONTINUATION.md"
READER_NAME = "phase7_read_sources.py"
BOOTSTRAP_NAME = "phase7_source_bootstrap.py"
MAX_REVIEW_BYTES = 1024 * 1024
MAX_READER_BYTES = 4 * 1024 * 1024


class LaunchError(RuntimeError):
    pass


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


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
        raise LaunchError(f"cannot safely open fixed directory {path}: {exc}") from exc


def read_fixed(name: str, cap: int) -> bytes:
    directory_fd = open_directory_nofollow(PHASE)
    flags = os.O_RDONLY | (os.O_NOFOLLOW if hasattr(os, "O_NOFOLLOW") else 0)
    try:
        before_path = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if not stat.S_ISREG(before_path.st_mode) or before_path.st_size > cap:
            raise LaunchError(f"fixed launch input is not a bounded regular file: {name}")
        fd = os.open(name, flags, dir_fd=directory_fd)
    except OSError as exc:
        os.close(directory_fd)
        raise LaunchError(f"cannot safely open fixed launch input {name}: {exc}") from exc
    except LaunchError:
        os.close(directory_fd)
        raise
    try:
        before = os.fstat(fd)
        keys = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
        if (not stat.S_ISREG(before.st_mode)
                or any(getattr(before, key) != getattr(before_path, key) for key in keys)):
            raise LaunchError(f"fixed launch input changed before read: {name}")
        chunks = []
        remaining = before.st_size
        while remaining:
            block = os.read(fd, min(remaining, 1024 * 1024))
            if not block:
                raise LaunchError(f"fixed launch input changed while read: {name}")
            chunks.append(block)
            remaining -= len(block)
        after = os.fstat(fd)
        if any(getattr(before, key) != getattr(after, key) for key in keys):
            raise LaunchError(f"fixed launch input changed during read: {name}")
        return b"".join(chunks)
    finally:
        os.close(fd)
        os.close(directory_fd)


def review_digest(review: str, heading: str) -> str:
    prefix = f"**{heading}:** `"
    for line in review.splitlines():
        if line.startswith(prefix) and line.endswith("`"):
            value = line[len(prefix):-1]
            if re.fullmatch(r"[0-9a-f]{64}", value):
                return value
    raise LaunchError(f"review does not contain a valid {heading}")


def run_batch(batch: str) -> int:
    if batch not in {"01", "02", "03", "04", "05"}:
        raise LaunchError("batch must be 01 through 05")
    review_bytes = read_fixed(REVIEW_NAME, MAX_REVIEW_BYTES)
    reader_bytes = read_fixed(READER_NAME, MAX_READER_BYTES)
    launcher_bytes = read_fixed(Path(__file__).name, MAX_READER_BYTES)
    bootstrap_bytes = read_fixed(BOOTSTRAP_NAME, MAX_READER_BYTES)
    try:
        review = review_bytes.decode("utf-8", "strict")
    except UnicodeDecodeError as exc:
        raise LaunchError("source-reader review is not strict UTF-8") from exc
    if "**Verdict:** PASS" not in review or "**Reviewer opened target source bodies:** no" not in review:
        raise LaunchError("independent source-reader review is not a clean pre-read PASS")
    if review_digest(review, "Reader SHA-256") != sha256(reader_bytes):
        raise LaunchError("reader bytes differ from the independent review")
    if review_digest(review, "Launcher SHA-256") != sha256(launcher_bytes):
        raise LaunchError("launcher bytes differ from the independent review")
    if review_digest(review, "Bootstrap SHA-256") != sha256(bootstrap_bytes):
        raise LaunchError("bootstrap bytes differ from the independent review")

    module_name = "phase7_reviewed_source_reader"
    module = types.ModuleType(module_name)
    module.__file__ = str(PHASE / READER_NAME)
    module.__package__ = ""
    sys.modules[module_name] = module
    exec(compile(reader_bytes, module.__file__, "exec", dont_inherit=True), module.__dict__)
    return module.run_batch(batch)


__all__ = ["LaunchError", "run_batch"]
