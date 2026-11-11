"""Read-only verification of the milestone reset's preserved evidence and addresses."""
import argparse
import hashlib
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--initial-layout", action="store_true", help="also check the one-time v0.2 / Phase 1 activation layout")
args = parser.parse_args()

root = Path(__file__).resolve().parents[3]
planning = root / ".planning"
folder = Path(__file__).parent
manifest = json.loads((folder / "ARCHIVE-MANIFEST.json").read_text())
assert manifest["status"] == "superseded-incomplete"
for entry in manifest["files"]:
    archive = root / entry["archive_path"]
    assert archive.is_file(), f"Missing archived file: {entry['archive_path']}"
    assert archive.stat().st_size == entry["bytes"], entry["archive_path"]
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == entry["sha256"], entry["archive_path"]


def requirements(text):
    result = {}
    for match in re.finditer(r"^- \[([ x])\] \*\*([A-Z]+-\d+)\*\*:(.*)$", text, re.M):
        status, identity, description = match.groups()
        assert identity not in result, f"Duplicate requirement: {identity}"
        citations = sorted(set(re.findall(r"INT-\d{8}-\d{2}|ADR \d{4}", description)))
        result[identity] = (status, citations)
    return result


original = requirements((planning / "milestones/v0.1-REQUIREMENTS.md").read_text())
initial = json.loads((folder / "INITIAL-RECEIPT.json").read_text())
captured = {identity: ("x" if item["checked"] else " ", item["citations"])
            for identity, item in initial["requirements"].items()}
assert original and original == captured, "Initial requirement identity, status or citations changed"
mapping = initial["phase_map"]
assert sorted(int(entry["legacy_phase"]) for entry in mapping) == list(range(2, 36))
for milestone in {entry["milestone_key"] for entry in mapping}:
    numbers = sorted(entry["phase"] for entry in mapping if entry["milestone_key"] == milestone)
    assert numbers == list(range(1, len(numbers) + 1)), milestone
assert len({(entry["milestone_key"], entry["phase"]) for entry in mapping}) == len(mapping)

history = (planning / "MILESTONES.md").read_text()
legacy = re.search(r"^## v0\.1 (.*?)(?=^## |\Z)", history, re.M | re.S)
assert legacy and "SUPERSEDED — INCOMPLETE" in legacy[0] and "(Shipped:" not in legacy[0]

if args.initial_layout:
    carried = requirements((planning / "references/PRODUCT-REQUIREMENTS.md").read_text())
    assert original == carried, "Initial activation requirement states differ"
    active = [path.name for path in (planning / "phases").iterdir() if path.is_dir()]
    assert active == ["01-bounded-guard-continuation"], "This is no longer the initial activation layout"
    state = (planning / "STATE.md").read_text()
    assert re.search(r"^milestone: v0\.2$", state, re.M), "This is no longer the initial activation milestone"
    assert re.search(r"^current_phase: 1$", state, re.M)
    roadmap = (planning / "ROADMAP.md").read_text()
    assert re.findall(r"^### Phase ([\d.]+):", roadmap, re.M) == ["1"]

print(f"Verified {len(manifest['files'])} archived files, {len(original)} initial requirement states/citations, "
      f"and {len(mapping)} initial future addresses. Live planning is checked separately.")
