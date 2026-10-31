#!/usr/bin/env python3
"""Prepare a reviewable exact-source extension; never replace the repository archive."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
ARCHIVE = ROOT / "test/fixtures/guards/exact_sources.tar.gz"
MAP = HERE / "01.1.1.3-SOURCE-MAP.json"
MODULES = sorted({"dbg_idb", "dbg_istk", "dbg_wx_interpret", "dbg_wx_mon", "dbg_wx_filedialog_win", "dbg_wx_mon_win", "i", "int", "dbg_iload", "dbg_ieval", "dbg_wx_win"})
VERSIONS = {"core": "29.1.2", "floor": "27.3.4.9"}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def prepare(source_dir, candidate):
    with tarfile.open(ARCHIVE, "r:gz") as archive:
        files = {}
        for entry in archive.getmembers():
            if not entry.isfile():
                raise ValueError(f"unexpected non-file archive member: {entry.name}")
            if entry.name in files:
                raise ValueError(f"duplicate archive member: {entry.name}")
            files[entry.name] = archive.extractfile(entry).read()
    original = dict(files)
    manifest = json.loads(files["manifest.json"])
    old_rows = list(manifest["files"])
    mappings = []
    for lane, version in VERSIONS.items():
        commit = manifest["refs"][lane]["otp"][1]
        for module in MODULES:
            data = (source_dir / version / "src" / (module + ".erl")).read_bytes()
            relative = f"debugger/src/{module}.erl"
            target = f"{lane}/{relative}"
            if target in files:
                raise ValueError(f"mapping already exists: {target}")
            row = {"lane": lane, "path": target, "source_path": relative,
                   "url": f"https://raw.githubusercontent.com/erlang/otp/{commit}/lib/{relative}",
                   "bytes": len(data), "sha256": sha(data), "status": "present"}
            manifest["files"].append(row)
            mappings.append(dict(row, tagged_research_url=f"https://raw.githubusercontent.com/erlang/otp/OTP-{version}/lib/{relative}"))
            files[target] = data
    if sum(r["bytes"] for r in mappings) != 514371 or len(mappings) != 22:
        raise ValueError("enumerated source extension changed; obtain a revised concrete budget")
    files["manifest.json"] = (json.dumps(manifest, sort_keys=True, indent=2) + "\n").encode()
    output = io.BytesIO()
    with tarfile.open(fileobj=output, mode="w", format=tarfile.USTAR_FORMAT) as archive:
        for name, data in sorted(files.items()):
            entry = tarfile.TarInfo(name)
            entry.size = len(data)
            entry.mode = 0o644
            archive.addfile(entry, io.BytesIO(data))
    packed = gzip.compress(output.getvalue(), mtime=0)
    base = ARCHIVE.read_bytes()
    if len(packed) > 2562990 or len(packed) - len(base) > 200000:
        raise ValueError("candidate exceeds source storage budget")
    for name, data in original.items():
        if name != "manifest.json" and files[name] != data:
            raise ValueError(f"old member changed: {name}")
    if manifest["files"][:len(old_rows)] != old_rows:
        raise ValueError("old source mappings changed")
    report = {"schema": "fablebook.debugger-source-extension.v1", "approval": "pending-owner-decision",
              "base_archive": "test/fixtures/guards/exact_sources.tar.gz", "base_sha256": sha(base),
              "base_bytes": len(base), "candidate_sha256": sha(packed), "candidate_bytes": len(packed),
              "compressed_delta_bytes": len(packed) - len(base), "new_raw_source_bytes": 514371,
              "max_compressed_delta_bytes": 200000, "max_total_compressed_bytes": 2562990,
              "new_source_count": len(mappings), "mappings": mappings,
              "unchanged_members": len(original) - 1, "unchanged_source_rows": len(old_rows)}
    candidate.write_bytes(packed)
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["prepare", "verify"])
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, default=Path("/tmp/gsd-01113-candidate-exact-sources.tar.gz"))
    args = parser.parse_args()
    if args.candidate.resolve() == ARCHIVE.resolve() or ROOT in args.candidate.resolve().parents:
        raise ValueError("candidate must remain outside repository; repository archive mutation is forbidden here")
    report = prepare(args.source_dir, args.candidate)
    if args.command == "prepare":
        MAP.write_text(json.dumps(report, sort_keys=True, indent=2) + "\n")
    elif json.loads(MAP.read_text()) != report:
        raise ValueError("source approval artifact differs from current inputs")
    print(json.dumps({k: v for k, v in report.items() if k != "mappings"}, sort_keys=True))


if __name__ == "__main__":
    main()
