"""Read the reviewed Phase 7 launcher safely, then execute its exact bytes."""

import hashlib
import os
import stat
import sys
import types
from pathlib import Path


PHASE = Path.cwd() / ".planning" / "phases" / "07-guard-scope-reconciliation"


def open_directory_nofollow(path):
    flags = os.O_RDONLY | getattr(os, "O_DIRECTORY", 0) | getattr(os, "O_NOFOLLOW", 0)
    fd = os.open("/", flags)
    try:
        for component in path.parts[1:]:
            next_fd = os.open(component, flags, dir_fd=fd)
            os.close(fd)
            fd = next_fd
        return fd
    except Exception:
        os.close(fd)
        raise


def read_fixed(name, cap):
    directory_fd = open_directory_nofollow(PHASE)
    try:
        before_path = os.stat(name, dir_fd=directory_fd, follow_symlinks=False)
        if not stat.S_ISREG(before_path.st_mode) or before_path.st_size > cap:
            raise RuntimeError(f"unsafe fixed launch input: {name}")
        flags = os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0)
        file_fd = os.open(name, flags, dir_fd=directory_fd)
        try:
            before = os.fstat(file_fd)
            keys = ("st_dev", "st_ino", "st_size", "st_mtime_ns", "st_ctime_ns")
            if any(getattr(before, key) != getattr(before_path, key) for key in keys):
                raise RuntimeError(f"launch input changed before read: {name}")
            chunks, remaining = [], before.st_size
            while remaining:
                block = os.read(file_fd, min(1024 * 1024, remaining))
                if not block:
                    raise RuntimeError(f"launch input shortened during read: {name}")
                chunks.append(block)
                remaining -= len(block)
            after = os.fstat(file_fd)
            if any(getattr(before, key) != getattr(after, key) for key in keys):
                raise RuntimeError(f"launch input changed during read: {name}")
            return b"".join(chunks)
        finally:
            os.close(file_fd)
    finally:
        os.close(directory_fd)


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in {"01", "02", "03", "04", "05"}:
        raise RuntimeError("usage: python3 - <batch 01..05>")
    review = read_fixed("07-SOURCE-READER-REVIEW-CONTINUATION.md", 1024 * 1024).decode("utf-8", "strict")
    launcher = read_fixed("phase7_source_launcher.py", 1024 * 1024)
    prefix = "**Launcher SHA-256:** `"
    expected = next((line[len(prefix):-1] for line in review.splitlines()
                     if line.startswith(prefix) and line.endswith("`")), None)
    if ("**Verdict:** PASS" not in review or "**Reviewer opened target source bodies:** no" not in review
            or expected is None or len(expected) != 64
            or any(character not in "0123456789abcdef" for character in expected)
            or hashlib.sha256(launcher).hexdigest() != expected):
        raise RuntimeError("source launcher is not covered by a clean independent pre-read PASS")
    module = types.ModuleType("phase7_reviewed_launcher")
    module.__file__ = str(PHASE / "phase7_source_launcher.py")
    exec(compile(launcher, module.__file__, "exec", dont_inherit=True), module.__dict__)
    return module.run_batch(sys.argv[1])


raise SystemExit(main())
