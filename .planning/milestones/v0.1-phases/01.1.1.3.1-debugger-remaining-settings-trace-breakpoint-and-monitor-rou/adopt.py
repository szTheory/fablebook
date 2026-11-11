#!/usr/bin/env python3
"""Resolve an exact delegated child partition without rewriting historical receipts."""
import argparse
from collections import Counter
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PHASE = "01.1.1.3.1"
SELECTED, REMAINDER = PHASE + ".1", PHASE + ".2"
OUTPUT = HERE / (PHASE + "-OWNERSHIP.jsonl.gz")
sys.dont_write_bytecode = True
spec = importlib.util.spec_from_file_location("settings_preflight", HERE / "preflight.py")
preflight = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preflight)


def current_owner(owner, module, function=None, arity=None):
    if owner != PHASE:
        return owner
    if module == "dbg_wx_settings" or (module, function, arity) in {
        ("dbg_wx_mon", "start", 2), ("dbg_wx_mon", "load_settings", 2),
        ("dbg_wx_mon", "load_settings2", 2), ("dbg_icmd", "break_p", 4),
    }:
        return SELECTED
    return REMAINDER


def resolve_step(step):
    match = re.fullmatch(r"(.+)\.([^./]+)/([0-9]+)", step["token"])
    if not match:
        raise ValueError("unresolved caller token: " + step["token"])
    module, function, arity = match.groups()
    result = copy.deepcopy(step)
    result["owners"] = sorted({current_owner(o, module, function, int(arity)) for o in step["owners"]})
    return result


def materialize():
    proposal_path = HERE / (PHASE + "-PARTITION.json.gz")
    proposal = json.loads(gzip.decompress(proposal_path.read_bytes()))
    if proposal != preflight.partition():
        raise ValueError("partition does not reproduce from both complete receipt namespaces")
    decision_path = HERE / (PHASE + "-SOURCE-DECISION.md")
    decision = decision_path.read_text()
    source = json.loads((HERE / (PHASE + "-SOURCE-CANDIDATE.json")).read_text())
    if "status: approved" not in decision or source["candidate_sha256"] not in decision:
        raise ValueError("exact source approval is missing or disagrees with the candidate")
    roadmap = (ROOT / ".planning/ROADMAP.md").read_text()
    for child in (SELECTED, REMAINDER):
        if f"### Phase {child}:" not in roadmap:
            raise ValueError("GSD child not materialized: " + child)
    historical = preflight.load_ledger()
    by_hash = {preflight.record_id(r): r for r in historical}
    result = []
    for assignment in proposal["assignments"] + proposal["observed_assignments"]:
        original = by_hash[assignment["record_sha256"]]
        row = copy.deepcopy(original)
        target = current_owner(original["owner"], original["module"], original.get("function"), original.get("arity"))
        if target != assignment["proposed_owner"]:
            raise ValueError("adopted selector differs from the reviewed partition")
        row.update(owner=target, origin_owner=original["owner"],
                   origin_record_sha256=assignment["record_sha256"], completion="pending")
        if "steps" in row:
            row["origin_steps"] = row["steps"]
            row["steps"] = [resolve_step(s) for s in row["steps"]]
            row["origin_references"] = row["references"]
            row["references"] = sorted(({o for s in row["steps"] for o in s["owners"]}
                                        | set(row["references"])) - {target})
        result.append(row)
    if Counter(r["origin_record_sha256"] for r in result) != Counter(
            a["record_sha256"] for a in proposal["assignments"] + proposal["observed_assignments"]):
        raise ValueError("delegation dropped or duplicated an original/observed assignment")
    root_owners = {(r["lane"], r["t"].removeprefix("observed_"), r["chain_id"]): r["owner"]
                   for r in result if r["t"] in {"root", "observed_root"}}
    for original in historical:
        if original.get("t") == "exact_source" and original.get("owner") == PHASE:
            row = copy.deepcopy(original)
            row.update(owner=current_owner(PHASE, original["module"]), origin_owner=PHASE,
                       origin_record_sha256=preflight.record_id(original))
            result.append(row)
        elif original.get("t") in {"overlap", "observed_overlap"} and PHASE in original.get("owners", []):
            row = copy.deepcopy(original)
            row["origin_record_sha256"] = preflight.record_id(original)
            row["origin_occurrences"] = row["occurrences"]
            row["occurrences"] = [[chain, root_owners.get((row["lane"], "root", chain), owner), position]
                                  for chain, owner, position in row["occurrences"]]
            row["owners"] = sorted({entry[1] for entry in row["occurrences"]})
            result.append(row)
    for original in proposal["source_discovered_obligations"]:
        row = copy.deepcopy(original)
        row.update(t="source_branch", owner=row.pop("proposed_owner"), completion="pending")
        row["origin_owner"] = row.pop("current_owner")
        result.append(row)
    meta = {"t": "delegation", "schema": "fablebook.debugger-settings-delegation.v1", "status": "adopted",
            "parent": PHASE, "children": [SELECTED, REMAINDER],
            "historical_authority": str(preflight.LEDGER.relative_to(ROOT)),
            "historical_sha256": proposal["ledger_sha256"],
            "partition_sha256": hashlib.sha256(proposal_path.read_bytes()).hexdigest(),
            "source_decision": str(decision_path.relative_to(ROOT)),
            "source_candidate_sha256": source["candidate_sha256"],
            "completion": "pending; structural delegation is not semantic evidence",
            "counts": proposal["counts"], "original_receipt_union": "passed",
            "observed_receipt_union": "passed"}
    return [meta] + result


def packed(rows):
    return gzip.compress(b"".join((json.dumps(r, sort_keys=True, separators=(",", ":")) + "\n").encode()
                                  for r in rows), mtime=0)


def validate(expected, actual):
    if Counter(preflight.record_id(r) for r in expected) != Counter(preflight.record_id(r) for r in actual):
        raise ValueError("effective delegation differs: missing/duplicate/unexpected/changed record")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["adopt", "verify"])
    args = parser.parse_args()
    expected = materialize()
    controls = []
    for name, mutate in (("missing", lambda rows: rows.pop()),
                         ("duplicate", lambda rows: rows.append(copy.deepcopy(rows[-1]))),
                         ("wrong-owner", lambda rows: rows[-1].update(owner=REMAINDER)),
                         ("changed-chain", lambda rows: next(r for r in rows if r.get("t") == "root").update(chain_id="changed"))):
        bad = copy.deepcopy(expected)
        mutate(bad)
        try:
            validate(expected, bad)
        except ValueError:
            controls.append(name + ":rejected")
        else:
            raise ValueError("negative control passed: " + name)
    data = packed(expected)
    if args.command == "adopt":
        OUTPUT.write_bytes(data)
    actual = [json.loads(line) for line in gzip.decompress(OUTPUT.read_bytes()).splitlines()]
    validate(expected, actual)
    if OUTPUT.read_bytes() != data:
        raise ValueError("delegation serialization changed")
    print(json.dumps({"status": "adopted-and-verified", "file": str(OUTPUT.relative_to(ROOT)),
                      "counts": expected[0]["counts"], "negative_controls": controls,
                      "source_branches": sum(r.get("t") == "source_branch" for r in actual),
                      "historical_ledger_unchanged": True}, sort_keys=True))


if __name__ == "__main__":
    main()
