#!/usr/bin/env python3
"""Verify the core lock changes only phoenix_live_view to 1.2.14."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


BASE = Path(__file__).with_name("07-BASE-CORE-LOCK.lock")
LOCK = Path(__file__).parents[4] / "mix.lock"
LIVE_VIEW = "phoenix_live_view"
EXPECTED_OLD = (
    "1.2.13",
    "850284c529f013e82d9596325bd92cb5859c0872176616b6e2ec4294e2ef616e",
    "a5cd2a3df10552bce6b7e68e5d376ff3b46cca3ca62d6c43bd4398d80c197fbe",
)
EXPECTED_NEW = (
    "1.2.14",
    "80a248539e566eea8598079b12bfb1a9c1f3180d4db3ecd215d28798dcebc44b",
    "1ca75ed52d3916f93299de990f152f3f49202d12849e526bf5f9b89b4ccf25f2",
)
LIVEVIEW_ENTRY = re.compile(
    rb'^  "phoenix_live_view": \{:hex, :phoenix_live_view, "([^"\\]+)", '
    rb'"([0-9a-f]{64})", \[:mix\], \[.*\], "hexpm", "([0-9a-f]{64})"\},?$'
)


def entries(data: bytes) -> dict[bytes, bytes]:
    found: dict[bytes, bytes] = {}
    for line in data.splitlines():
        match = re.match(rb'^  "([^"\n]+)":', line)
        if match:
            key = match.group(1)
            if key in found:
                raise ValueError(f"duplicate lock key: {key.decode()}")
            found[key] = line
    return found


def liveview_identity(line: bytes) -> tuple[str, str, str]:
    match = LIVEVIEW_ENTRY.fullmatch(line)
    if not match:
        raise ValueError("phoenix_live_view entry is not the expected Hex lock tuple")
    return tuple(value.decode("ascii") for value in match.groups())


def check() -> None:
    before = BASE.read_bytes()
    after = LOCK.read_bytes()
    old_entries = entries(before)
    new_entries = entries(after)
    key = LIVE_VIEW.encode()
    if old_entries.keys() != new_entries.keys():
        raise ValueError("dependency key set changed")
    changed = [name for name in old_entries if old_entries[name] != new_entries[name]]
    if changed != [key]:
        raise ValueError(
            "expected only phoenix_live_view to change; found "
            + ", ".join(name.decode() for name in changed)
        )
    if liveview_identity(old_entries[key]) != EXPECTED_OLD:
        raise ValueError("saved phoenix_live_view version or checksum differs from the 1.2.13 baseline")
    if liveview_identity(new_entries[key]) != EXPECTED_NEW:
        raise ValueError("current phoenix_live_view version or checksum differs from the approved 1.2.14 pin")
    print("PASS: phoenix_live_view alone changed from 1.2.13 to 1.2.14")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", required=True)
    parser.parse_args()
    try:
        check()
    except (OSError, ValueError) as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
