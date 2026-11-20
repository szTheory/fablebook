#!/usr/bin/env python3
"""Offline controls for Phase 7 reader hardening; never opens target source files."""

from __future__ import annotations

import json
import inspect
import os
from pathlib import Path
import runpy
import stat
import tempfile
from unittest.mock import patch


PHASE = Path(__file__).resolve().parent


def check(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def load_helpers() -> dict[str, dict]:
    names = {
        "reader": "phase7_read_sources.py",
        "launcher": "phase7_source_launcher.py",
        "bootstrap": "phase7_source_bootstrap.py",
        "observer": "phase7_source_observer.py",
        "validator": "07-validate-reconciliation.py",
    }
    return {name: runpy.run_path(str(PHASE / filename)) for name, filename in names.items()}


def exercise_stat_open_race(label: str, module: dict, target: Path,
                            regular_stat: os.stat_result, read_call) -> None:
    real_stat = os.stat
    real_open = os.open
    target_name = target.name
    race_seen = False

    def raced_stat(path, *args, **kwargs):
        if path == target_name and kwargs.get("dir_fd") is not None:
            return regular_stat
        return real_stat(path, *args, **kwargs)

    def checked_open(path, flags, *args, **kwargs):
        nonlocal race_seen
        if path == target_name and kwargs.get("dir_fd") is not None:
            race_seen = True
            check(bool(flags & getattr(os, "O_NONBLOCK", 0)),
                  f"{label} did not open with O_NONBLOCK")
        return real_open(path, flags, *args, **kwargs)

    expected_errors = tuple(
        module[name] for name in ("ReadError", "LaunchError", "ValidationError") if name in module
    ) + (RuntimeError,)
    check(bool(expected_errors), f"{label} has no expected safe-open error type")
    failure_message = ""
    with patch.object(os, "stat", side_effect=raced_stat), patch.object(os, "open", side_effect=checked_open):
        try:
            read_call()
        except expected_errors as exc:
            failure_message = str(exc)
        else:
            raise AssertionError(f"{label} accepted a raced FIFO")
    check(race_seen, f"{label} did not reach the raced descriptor open: {failure_message}")


def test_nonblocking_controls(helpers: dict[str, dict]) -> None:
    with tempfile.TemporaryDirectory(prefix="fablebook-phase7-hardening-") as root:
        directory = Path(os.path.realpath(root))
        reference = directory / "regular-reference"
        reference.write_bytes(b"approved identity")
        regular_stat = os.stat(reference, follow_symlinks=False)
        target = directory / "raced-fifo"
        os.mkfifo(target)

        reader = helpers["reader"]
        exercise_stat_open_race(
            "reader fixed input", reader, target, regular_stat,
            lambda: reader["read_fixed_regular"](target, 1024),
        )

        for name in ("launcher", "bootstrap"):
            module = helpers[name]
            module["read_fixed"].__globals__["PHASE"] = directory
            exercise_stat_open_race(
                f"{name} fixed input", module, target, regular_stat,
                lambda module=module: module["read_fixed"](target.name, 1024),
            )

        validator = helpers["validator"]
        exercise_stat_open_race(
            "validator fixed input", validator, target, regular_stat,
            lambda: validator["read_capped"](target, 1024),
        )


def test_stop_receipt(helpers: dict[str, dict]) -> None:
    reader = helpers["reader"]
    entries = [
        {"request_id": "new-a", "lane": "core", "batch": "03"},
        {"request_id": "new-b", "lane": "floor", "batch": "03"},
    ]
    prior = [{"request_id": "prior-gap"}]
    stop = reader["build_batch_stop"](
        "03", "a" * 64, KeyboardInterrupt("synthetic interrupt"),
        {"new-a", "new-b", "prior-gap"}, {"new-a", "new-b"},
        prior, entries, False, False, None, None,
    )
    check(stop["prior_failures_preserved"] == ["prior-gap"],
          "reconstructed prior failures were not preserved separately")
    check([row["request_id"] for row in stop["unrecorded_requests"]] == ["new-a", "new-b"],
          "STOP does not enumerate every newly consumed unrecorded request")
    for row in stop["unrecorded_requests"]:
        check(row["observation_status"] == "batch_stopped_no_retry"
              and row["durable_source_hash"] is False
              and row["durable_selector_spans"] is False
              and row["retry_permitted"] is False,
              "STOP gap is missing its no-retry durability fields")

    with tempfile.TemporaryDirectory(prefix="fablebook-phase7-stop-") as root:
        receipt_path = Path(os.path.realpath(root)) / "batch.STOP.json"
        real_fsync = os.fsync
        synced_directory = False

        def checked_fsync(fd: int) -> None:
            nonlocal synced_directory
            if stat.S_ISDIR(os.fstat(fd).st_mode):
                synced_directory = True
            real_fsync(fd)

        try:
            with patch.object(os, "fsync", side_effect=checked_fsync):
                reader["persist_stop_then_propagate"](
                    receipt_path, stop, KeyboardInterrupt("synthetic interrupt"),
                )
        except KeyboardInterrupt:
            pass
        else:
            raise AssertionError("KeyboardInterrupt was swallowed instead of re-raised")
        check(synced_directory, "STOP receipt file was synced without syncing its directory entry")
        stored = json.loads(receipt_path.read_text(encoding="utf-8"))
        check(stored == stop, "STOP receipt was not durably written before re-raising")

    durable = reader["build_batch_stop"](
        "03", "a" * 64, RuntimeError("after durable output"),
        {"new-a"}, {"new-a"}, [], entries, True, True, None, None,
    )
    check(durable["unrecorded_requests"] == [],
          "already durable observations were incorrectly recorded as gaps")


def main() -> None:
    helpers = load_helpers()
    check("O_NONBLOCK" in inspect.getsource(helpers["reader"]["read_one"]),
          "scheduled source reads do not use nonblocking opens")
    check("except BaseException as exc" in inspect.getsource(helpers["reader"]["run_batch"]),
          "batch STOP handling does not include interrupts and system exits")
    results = helpers["observer"]["self_test"]()
    check(results == {"elixir_cases": 14, "erlang_cases": 5},
          f"observer synthetic tests returned unexpected counts: {results}")
    test_nonblocking_controls(helpers)
    test_stop_receipt(helpers)
    print("PASS: source-reader hardening self-tests (no target source reads)")


if __name__ == "__main__":
    main()
