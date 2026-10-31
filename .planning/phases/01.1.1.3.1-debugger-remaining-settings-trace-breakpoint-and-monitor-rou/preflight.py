#!/usr/bin/env python3
"""Prepare offline research evidence; never install sources or transfer ownership."""
import argparse
from collections import Counter
import copy
import gzip
import hashlib
import io
import importlib.util
import json
from pathlib import Path
import sys
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PARENT = HERE.parent / "01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil"
LEDGER = PARENT / "01.1.1.3-OWNERSHIP.jsonl.gz"
ARCHIVE = ROOT / "test/fixtures/guards/exact_sources.tar.gz"
PHASE = "01.1.1.3.1"
BASE_SHA = "a31f1d1b19e1c8df543f4844af9d47b7ca7a79985b42bd78186f56c04da06342"
VERSIONS = {"core": "29.1.2", "floor": "27.3.4.9"}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def encoded(value):
    return (json.dumps(value, sort_keys=True, indent=2) + "\n").encode()


def record_id(row):
    return sha(json.dumps(row, sort_keys=True, separators=(",", ":")).encode())


def load_ledger():
    return [json.loads(line) for line in gzip.decompress(LEDGER.read_bytes()).splitlines()]


def source_candidate(source_dir, modules):
    base = ARCHIVE.read_bytes()
    if sha(base) != BASE_SHA:
        raise ValueError("approved base archive changed; re-review candidate")
    with tarfile.open(fileobj=io.BytesIO(base), mode="r:gz") as archive:
        entries = archive.getmembers()
        if any(not e.isfile() for e in entries) or len({e.name for e in entries}) != len(entries):
            raise ValueError("archive contains duplicate or non-file entries")
        files = {e.name: archive.extractfile(e).read() for e in entries}
    old_files = dict(files)
    manifest = json.loads(files["manifest.json"])
    old_manifest = copy.deepcopy(manifest)
    sources = {(r["lane"], r["module"]): r for r in load_ledger() if r.get("t") == "exact_source"}
    mappings = []
    for lane, version in VERSIONS.items():
        commit = manifest["refs"][lane]["otp"][1]
        for module in sorted(modules):
            relative = f"debugger/src/{module}.erl"
            target = f"{lane}/{relative}"
            if target in files:
                raise ValueError(f"source already mapped: {target}")
            data = (source_dir / version / "src" / f"{module}.erl").read_bytes()
            original = sources[(lane, module)]
            if sha(data) != original["sha256"] or len(data) != original["bytes"]:
                raise ValueError(f"source differs from canonical research fingerprint: {lane}:{module}")
            row = {"lane": lane, "path": target, "source_path": relative,
                   "url": f"https://raw.githubusercontent.com/erlang/otp/{commit}/lib/{relative}",
                   "bytes": len(data), "sha256": sha(data), "status": "present"}
            mappings.append(row)
            manifest["files"].append(row)
            files[target] = data
    files["manifest.json"] = encoded(manifest)
    output = io.BytesIO()
    with tarfile.open(fileobj=output, mode="w", format=tarfile.USTAR_FORMAT) as archive:
        for name, data in sorted(files.items()):
            entry = tarfile.TarInfo(name)
            entry.size, entry.mode = len(data), 0o644
            archive.addfile(entry, io.BytesIO(data))
    packed = gzip.compress(output.getvalue(), mtime=0)
    with tarfile.open(fileobj=io.BytesIO(packed), mode="r:gz") as archive:
        actual = {e.name: archive.extractfile(e).read() for e in archive.getmembers()}
    assert actual == files
    assert all(actual[k] == v for k, v in old_files.items() if k != "manifest.json")
    assert manifest["files"][:len(old_manifest["files"])] == old_manifest["files"]
    assert {k: v for k, v in manifest.items() if k != "files"} == {k: v for k, v in old_manifest.items() if k != "files"}
    report = {"status": "prepared-awaiting-owner-source-decision", "base_sha256": sha(base),
              "base_bytes": len(base), "candidate_sha256": sha(packed), "candidate_bytes": len(packed),
              "compressed_delta_bytes": len(packed) - len(base),
              "new_raw_source_bytes": sum(r["bytes"] for r in mappings), "mappings": mappings,
              "unchanged_file_members": len(old_files) - 1,
              "unchanged_source_rows": len(old_manifest["files"]), "no_downloads": True,
              "ledger_sha256": sha(LEDGER.read_bytes())}
    return report, packed


def partition():
    ledger = load_ledger()
    rows = [r for r in ledger if r.get("t") in {"module", "root"} and r.get("owner") == PHASE]
    spec = importlib.util.spec_from_file_location("parent_ownership", PARENT / "ownership.py")
    helper = importlib.util.module_from_spec(spec)
    sys.dont_write_bytecode = True
    spec.loader.exec_module(helper)
    independent = []
    observed_independent = []
    meta = ledger[0]
    for lane in VERSIONS:
        path, file_hash, receipt_rows = helper.receipt(lane)
        original_records = helper.derive(lane, path, file_hash, receipt_rows)
        independent.extend(r for r in original_records
                           if r.get("t") in {"module", "root"} and r.get("owner") == PHASE)
        observed_path = helper.OBSERVED_FILES[lane]
        observed_hash, observed_rows, body_hash = helper.receipt_file(observed_path, lane)
        derived_observed = helper.derive_observed(
            lane, observed_path, observed_hash, body_hash, observed_rows, receipt_rows,
            original_records, meta["tested_code_head"], meta["ci_run_id"])
        observed_independent.extend(r for r in derived_observed
                                    if r.get("t") in {"observed_module", "observed_root"}
                                    and r.get("owner") == PHASE)
    if Counter(record_id(r) for r in rows) != Counter(record_id(r) for r in independent):
        raise ValueError("canonical partition universe differs from independently streamed original receipts")
    observed = [r for r in ledger if r.get("t") in {"observed_module", "observed_root"} and r.get("owner") == PHASE]
    if Counter(record_id(r) for r in observed) != Counter(record_id(r) for r in observed_independent):
        raise ValueError("observed partition universe differs from independently streamed newer receipts")
    # Whole-module review remains pending except the small settings dialog helper.
    def selected(row):
        if row["t"].removeprefix("observed_") == "module":
            return row["module"] == "dbg_wx_settings"
        return ((row["module"], row["function"], row["arity"]) in {
            ("dbg_wx_mon", "start", 2), ("dbg_wx_mon", "load_settings", 2),
            ("dbg_wx_mon", "load_settings2", 2)})
    assignments = [{"record_sha256": record_id(r), "record": r,
                    "proposed_owner": PHASE + (".1" if selected(r) else ".2")}
                   for r in rows]
    for lane in VERSIONS:
        chosen = [a["record"] for a in assignments
                  if a["record"]["lane"] == lane and a["proposed_owner"] == PHASE + ".1"]
        if sum(r["t"] == "module" for r in chosen) != 1 or sum(r["t"] == "root" for r in chosen) != 3:
            raise ValueError(f"{lane}: calibrated three-root/one-module selection changed; recalibrate before proposal")
    validate_partition(rows, assignments)
    observed_assignments = [{"record_sha256": record_id(r), "record": r,
                             "proposed_owner": PHASE + (".1" if selected(r) else ".2")}
                            for r in observed]
    validate_partition(observed, observed_assignments)
    controls = []
    for name, mutate in (("missing", lambda xs: xs.pop()),
                         ("duplicate", lambda xs: xs.append(copy.deepcopy(xs[0]))),
                         ("changed-chain", lambda xs: xs[0]["record"].update(task="changed")),
                         ("unowned", lambda xs: xs[0].update(proposed_owner=""))):
        bad = copy.deepcopy(assignments)
        mutate(bad)
        try:
            validate_partition(rows, bad)
        except ValueError:
            controls.append(name + ":rejected")
        else:
            raise ValueError(f"negative control passed: {name}")
    observed_controls = []
    for name, mutate in (("missing", lambda xs: xs.pop()),
                         ("duplicate", lambda xs: xs.append(copy.deepcopy(xs[0]))),
                         ("changed-chain", lambda xs: xs[0]["record"].update(chain_id="changed")),
                         ("unowned", lambda xs: xs[0].update(proposed_owner=""))):
        bad = copy.deepcopy(observed_assignments)
        mutate(bad)
        try:
            validate_partition(observed, bad)
        except ValueError:
            observed_controls.append(name + ":rejected")
        else:
            raise ValueError(f"observed negative control passed: {name}")
    counts = {}
    for lane in VERSIONS:
        counts[lane] = {}
        for owner in (PHASE + ".1", PHASE + ".2"):
            subset = [a["record"] for a in assignments if a["record"]["lane"] == lane and a["proposed_owner"] == owner]
            counts[lane][owner] = {"modules": sum(r["t"] == "module" for r in subset),
                                   "roots": sum(r["t"] == "root" for r in subset),
                                   "zero_hit_modules": sum(r["t"] == "module" and r.get("zero_graph_hits", False) for r in subset)}
    source_rows = {(r["lane"], r["module"]): r for r in load_ledger() if r.get("t") == "exact_source"}
    if any(r.get("module") == "dbg_icmd" and r.get("function") == "break_p" for r in rows):
        raise ValueError("source-discovered callback now has a canonical root; reconcile its assignment")
    discovered = [{"lane": lane, "app": "debugger", "module": "dbg_icmd", "function": "break_p", "arity": 4,
                   "state": "source-discovered-unresolved-callback-branch", "current_owner": PHASE,
                   "proposed_owner": PHASE + ".1", "source_sha256": source_rows[(lane, "dbg_icmd")]["sha256"],
                   "source_path": "debugger/src/dbg_icmd.erl",
                   "source_lines": [88, 126] if lane == "core" else [86, 124],
                   "caller": "dbg_icmd.cmd/4", "sensitive_expression": "try CM:CN(Bs) of",
                   "canonical_receipt_root_present": False,
                   "shared_broad_roots_remain_with": PHASE + ".2"} for lane in VERSIONS]
    return {"status": "proposed-not-adopted", "authority": str(LEDGER.relative_to(ROOT)),
            "ledger_sha256": sha(LEDGER.read_bytes()), "counts": counts,
            "source_discovered_obligations": discovered,
            "independent_observed_receipt_union": "passed", "observed_negative_controls": observed_controls,
            "observed_assignments": [{"record_sha256": a["record_sha256"],
                                      "identity": a["record"]["identity"],
                                      "chain_id": a["record"].get("chain_id"),
                                      "proposed_owner": a["proposed_owner"]} for a in observed_assignments],
            "independent_receipt_union": "passed", "negative_controls": controls, "assignments": assignments}


def validate_partition(original, assignments):
    expected = Counter(record_id(r) for r in original)
    actual = Counter(record_id(a["record"]) for a in assignments)
    if actual != expected or any(a["record_sha256"] != record_id(a["record"]) for a in assignments):
        raise ValueError("partition dropped, duplicated, added or changed a canonical record")
    if any(a["proposed_owner"] not in {PHASE + ".1", PHASE + ".2"} for a in assignments):
        raise ValueError("partition contains an unowned or unexpected task")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["prepare", "verify"])
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--modules", nargs="+", default=["debugger", "dbg_wx_settings", "dbg_iserver", "dbg_icmd"])
    args = parser.parse_args()
    if ROOT == args.candidate.resolve() or ROOT in args.candidate.resolve().parents:
        raise ValueError("source candidate must remain outside repository")
    report, packed = source_candidate(args.source_dir, args.modules)
    proposal = partition()
    for obligation in proposal["source_discovered_obligations"]:
        data = (args.source_dir / VERSIONS[obligation["lane"]] / "src" / "dbg_icmd.erl").read_bytes()
        first, last = obligation["source_lines"]
        snippet = "\n".join(data.decode().splitlines()[first - 1:last])
        if (sha(data) != obligation["source_sha256"] or not snippet.startswith("break_p(")
                or obligation["sensitive_expression"] not in snippet):
            raise ValueError("source-discovered callback citation changed")
    map_path = HERE / (PHASE + "-SOURCE-CANDIDATE.json")
    partition_path = HERE / (PHASE + "-PARTITION.json.gz")
    packed_partition = gzip.compress(encoded(proposal), mtime=0)
    if args.command == "prepare":
        args.candidate.write_bytes(packed)
        map_path.write_bytes(encoded(report))
        partition_path.write_bytes(packed_partition)
    elif (map_path.read_bytes() != encoded(report) or partition_path.read_bytes() != packed_partition
          or args.candidate.read_bytes() != packed):
        raise ValueError("prepared evidence or candidate changed")
    print(json.dumps({k: v for k, v in report.items() if k != "mappings"}, sort_keys=True))
    print(json.dumps({k: v for k, v in proposal.items() if k not in {"assignments", "observed_assignments"}}, sort_keys=True))


if __name__ == "__main__":
    main()
