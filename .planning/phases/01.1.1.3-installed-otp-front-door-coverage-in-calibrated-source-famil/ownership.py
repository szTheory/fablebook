#!/usr/bin/env python3
"""Offline planning ledger: exact receipt membership, never a semantic verdict."""
import argparse
import collections
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
RECEIPTS = ROOT / ".planning/phases/01.1.1.2-installed-otp-inventory-and-common-test-guard-slice"
OUTPUT = HERE / "01.1.1.3-OWNERSHIP.jsonl.gz"
PREFIX = b"FABLEBOOK_OTP_INVENTORY_V2 "
PHASE = "01.1.1.3"
BASELINE = "existing-active-baseline"
SEEDS = {"dbg_idb", "dbg_istk", "dbg_wx_interpret"}
SUPPORT = {"dbg_wx_mon", "dbg_wx_filedialog_win", "dbg_wx_mon_win"}
ROUTES = [
    ("1", "Debugger remaining settings, trace, breakpoint and monitor routes", ["debugger"]),
    ("2", "Common Test remaining runner, specification and source-input routes", ["common_test"]),
    ("3", "EUnit remaining runner and test-description input routes", ["eunit"]),
    ("4", "EDoc remaining source, generation and callback routes", ["edoc"]),
    ("5", "Diameter remaining dictionary and service-input routes", ["diameter"]),
    ("6", "Reltool remaining configuration and code-path routes", ["reltool"]),
    ("7", "SNMP remaining compiler and service-input routes", ["snmp"]),
    ("8", "Megaco remaining codec and configuration-input routes", ["megaco"]),
    ("9", "Observer and ET remaining trace and match-specification routes", ["observer", "et"]),
    ("10", "Mnesia remaining schema and configuration-input routes", ["mnesia"]),
    ("11", "SSH remaining service, shell and configuration-input routes", ["ssh"]),
    ("12", "FTP, TFTP, ODBC and ELDAP unresolved source-input routes", ["ftp", "tftp", "odbc", "eldap"]),
    ("13", "wx native/source-input coverage, erl_interface accounting and final installed-scope gate", ["wx", "erl_interface"]),
]
APP_OWNER = {app: f"{PHASE}.{n}" for n, _, apps in ROUTES for app in apps}
OVERRIDES = {("stdlib", "escript", "debug", 3): PHASE + ".1"}
FINAL = PHASE + ".13"
SOURCE_FRONTS = [("debugger", "dbg_istk", "from_external", 1)]


def canon(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True)


def digest(value):
    return hashlib.sha256(value).hexdigest()


def multiset(values):
    values = sorted(values)
    return {"count": len(values), "sha256": digest("\n".join(values).encode())}


def key(row):
    return "|".join(str(row.get(k, "")) for k in ("t", "lane", "app", "module", "function", "arity"))


def owner(app, module=None, function=None, arity=None):
    if (app, module, function, arity) in OVERRIDES:
        return OVERRIDES[(app, module, function, arity)]
    if app == "debugger" and module in SEEDS:
        return PHASE
    return APP_OWNER.get(app, BASELINE)


def receipt(lane):
    path = RECEIPTS / f"01.1.1.2-INVENTORY-{lane}.jsonl"
    rows = []
    file_hash, body_hash = hashlib.sha256(), hashlib.sha256()
    with path.open("rb") as stream:
        for line in stream:
            file_hash.update(line)
            if not line.startswith(PREFIX):
                raise ValueError(f"{lane}: untagged receipt row")
            row = json.loads(line[len(PREFIX):])
            if row["kind"] != "footer":
                body_hash.update(line)
            rows.append(row)
    footer = rows[-1]
    if footer["kind"] != "footer" or footer["sha256"] != body_hash.hexdigest():
        raise ValueError(f"{lane}: receipt body digest failed")
    return path, file_hash.hexdigest(), rows


def derive(lane, path, file_hash, rows):
    by_kind = collections.defaultdict(list)
    modules = collections.defaultdict(lambda: collections.defaultdict(list))
    apps, pending_apps, pending_modules = {}, {}, {}
    module_apps = collections.defaultdict(set)
    for row in rows:
        kind = row["kind"]
        fingerprint = digest(canon(row).encode())
        by_kind[kind].append(fingerprint)
        if row.get("module") and row.get("app"):
            modules[(row["app"], row["module"])][kind].append(fingerprint)
            module_apps[row["module"]].add(row["app"])
        if kind == "app":
            apps[row["app"]] = row
        elif kind == "pending_app":
            pending_apps[row["app"]] = row
        elif kind == "pending_module":
            pending_modules[(row["app"], row["module"])] = row
    unknown = set(pending_apps) - set(APP_OWNER)
    if unknown:
        raise ValueError(f"{lane}: new pending applications need explicit research owners: {sorted(unknown)}")
    result = [{"t": "receipt", "lane": lane, "path": str(path.relative_to(ROOT)),
               "file_sha256": file_hash, "kinds": {k: multiset(v) for k, v in sorted(by_kind.items())},
               "body_sha256": rows[-1]["sha256"]}]
    for app, row in sorted(apps.items()):
        pending = app in pending_apps
        result.append({"t": "app", "lane": lane, "app": app,
                       "owner": APP_OWNER[app] if pending else BASELINE,
                       "pending": pending, "record_sha256": digest(canon(row).encode()),
                       "pending_record_sha256": digest(canon(pending_apps[app]).encode()) if pending else None,
                       "task": f"resolve-installation:{lane}|{app}" if pending else "preserve-baseline"})
    for (app, module), kinds in sorted(modules.items()):
        pending = (app, module) in pending_modules
        p = pending_modules.get((app, module), {})
        assigned = owner(app, module) if pending else BASELINE
        result.append({"t": "module", "lane": lane, "app": app, "module": module,
                       "owner": assigned, "pending": pending,
                       "task": f"resolve-source:{lane}|{app}|{module}" if pending else "preserve-baseline",
                       "state": "scoped-source-review-required" if assigned == PHASE else ("unresolved-source-task" if pending else "baseline-unmodified"),
                       "zero_graph_hits": pending and not kinds.get("reached") and not kinds.get("boundary"),
                       "source": {k: p.get(k) for k in ("source", "source_status", "source_bytes", "function_count")},
                       "kinds": {k: multiset(v) for k, v in sorted(kinds.items())}})
    chains = []
    for row in rows:
        if row["kind"] != "pending_mfa":
            continue
        app, module = row["app"], row["module"]
        if (app, module) not in pending_modules and (app, module, row["function"], row["arity"]) not in OVERRIDES:
            raise ValueError(f"{lane}: pending root outside module routing needs explicit override: {row}")
        steps = []
        for token in row.get("caller_chain", []):
            match = re.fullmatch(r"(.+)\.([^./]+)/([0-9]+)", token)
            if not match:
                raise ValueError(f"{lane}: unparsed caller token: {token}")
            mod, fun, arity = match.groups()
            candidates = sorted(module_apps.get(mod, set()))
            step_owners = sorted({owner(a, mod, fun, int(arity)) if (a, mod) in pending_modules or (a, mod, fun, int(arity)) in OVERRIDES else BASELINE for a in candidates})
            steps.append({"token": token, "apps": candidates, "owners": step_owners,
                          "resolution": "inventory" if candidates else "unresolved-external-token"})
        record = {"t": "root", "lane": lane, "app": app, "module": module,
                  "function": row["function"], "arity": row["arity"],
                  "owner": owner(app, module, row["function"], row["arity"]),
                  "record_sha256": digest(canon(row).encode()), "steps": steps}
        record["chain_id"] = digest(canon({"root": key(record), "steps": row.get("caller_chain", [])}).encode())
        record["references"] = sorted({o for s in steps for o in s["owners"]} - {record["owner"]})
        chains.append(record)
    result.extend(chains)
    overlaps = collections.defaultdict(list)
    for chain in chains:
        for position, step in enumerate(chain["steps"]):
            overlaps[step["token"]].append([chain["chain_id"], chain["owner"], position])
    for token, occurrences in sorted(overlaps.items()):
        if len({x[0] for x in occurrences}) > 1:
            result.append({"t": "overlap", "lane": lane, "token": token,
                           "owners": sorted({x[1] for x in occurrences}), "occurrences": occurrences})
    return result


def manifest(source_dir=None):
    children = [{"id": PHASE, "title": "Debugger selected-file interpreter and seed provenance",
                 "readiness": "measured candidate; roadmap materialization before PLAN",
                 "depends_on": ["01.1.1.2"]}]
    for n, title, apps in ROUTES:
        ident = f"{PHASE}.{n}"
        deps = ["01.1.1.2"]
        if n == "1":
            deps.append(PHASE)
        if ident == FINAL:
            deps += [PHASE] + [f"{PHASE}.{i}" for i in range(1, 13)]
        children.append({"id": ident, "title": title, "apps": apps,
                         "readiness": "research-only unresolved source tasks; no semantic or executable-size claim",
                         "depends_on": deps, "global_gate": ident == FINAL})
    records = [{"t": "meta", "schema": "fablebook.otp-ownership.v2", "children": children,
                "final_gate_owner": FINAL, "baseline_owner": BASELINE,
                "routing_note": "App groups route unresolved source tasks; only source-connected measured families become executable.",
                "root_overrides": [{"app": a, "module": m, "function": f, "arity": n, "owner": o} for (a, m, f, n), o in OVERRIDES.items()],
                "source_discovered_roots": [{"app": a, "module": m, "function": f, "arity": n, "owner": PHASE} for a, m, f, n in SOURCE_FRONTS],
                "supporting_source_modules": sorted(SUPPORT), "measured_source_modules": sorted(SEEDS | SUPPORT)}]
    for lane in ("core", "floor"):
        path, file_hash, rows = receipt(lane)
        records.extend(derive(lane, path, file_hash, rows))
        for app, module, function, arity in SOURCE_FRONTS:
            records.append({"t": "source_root", "lane": lane, "app": app, "module": module,
                            "function": function, "arity": arity, "owner": PHASE,
                            "caller_chain": ["dbg_istk.from_external/1", "erlang.binary_to_term/1"],
                            "source_path": "debugger/src/dbg_istk.erl",
                            "disposition": "exported caller-binary decoder; internal round-trip is not an enforced caller restriction",
                            "references": [BASELINE], "receipt_pending_root": False})
    if source_dir:
        for lane, version in (("core", "29.1.2"), ("floor", "27.3.4.9")):
            source_paths = sorted((source_dir / version / "src").glob("*.erl"))
            expected_modules = {r["module"]: r for r in records if r["t"] == "module" and r.get("lane") == lane and r.get("app") == "debugger" and r["pending"]}
            if {p.stem for p in source_paths} != set(expected_modules):
                raise ValueError(f"{lane}: exact debugger source/module union mismatch")
            for path in source_paths:
                module = path.stem
                data = path.read_bytes()
                if len(data) != expected_modules[module]["source"]["source_bytes"]:
                    raise ValueError(f"{lane}: exact source size differs from receipt: {module}")
                if module == "dbg_istk" and not re.search(rb"from_external\(\{stack,Stk\}\)\s*->\s*put\(\?STACK,\s*binary_to_term\(Stk\)\)", data):
                    raise ValueError(f"{lane}: source-discovered decoder route changed; review the caller domain")
                records.append({"t": "exact_source", "lane": lane, "app": "debugger", "module": module,
                                "owner": owner("debugger", module), "bytes": len(data), "sha256": digest(data),
                                "source_path": f"debugger/src/{path.name}",
                                "url": f"https://raw.githubusercontent.com/erlang/otp/OTP-{version}/lib/debugger/src/{path.name}",
                                "evidence_reference_owners": [PHASE] if module in SUPPORT else []})
    return records


def assert_equal(expected, actual):
    def identity(record):
        if record["t"] == "overlap":
            return f"overlap|{record['lane']}|{record['token']}"
        return key(record)
    left, right = {}, {}
    for label, records, index in (("expected", expected, left), ("ledger", actual, right)):
        for record in records:
            ident = identity(record)
            if ident in index:
                raise ValueError(f"{label}: duplicate canonical identity {ident}")
            index[ident] = record
    if left.keys() != right.keys():
        raise ValueError(f"ownership union mismatch: missing={sorted(left.keys()-right.keys())[:4]} unexpected={sorted(right.keys()-left.keys())[:4]}")
    for ident in left:
        if left[ident] != right[ident]:
            raise ValueError(f"changed ownership/evidence: {ident}; regenerate routing only after assigning new input to a source task")


def controls(expected):
    reports = []
    def reject(label, left, right):
        try:
            assert_equal(left, right)
        except ValueError:
            reports.append(label)
        else:
            raise ValueError(f"negative control falsely passed: {label}")
    at = next(i for i, r in enumerate(expected) if r["t"] == "module" and r["pending"])
    reject("missing-module", expected, expected[:at] + expected[at+1:])
    reject("duplicate-module", expected, expected + [expected[at]])
    extra = dict(expected[at], module="unregistered_new_module")
    reject("unexpected-module", expected, expected + [extra])
    at = next(i for i, r in enumerate(expected) if r["t"] == "root")
    extra = dict(expected[at], function="unregistered_new_root")
    reject("new-root-without-owner", expected + [extra], expected)
    changed = copy.deepcopy(expected)
    changed[at]["steps"].append({"token": "new_wrapper.call/1", "apps": [], "owners": []})
    reject("new-caller-path", changed, expected)
    at = next(i for i, r in enumerate(expected) if r["t"] == "module" and "export" in r["kinds"])
    changed = copy.deepcopy(expected)
    changed[at]["kinds"]["export"] = {"count": expected[at]["kinds"]["export"]["count"] + 1, "sha256": digest(b"new-export")}
    reject("new-export-without-review", changed, expected)
    at = next(i for i, r in enumerate(expected) if r["t"] == "app" and r["app"] == "erl_interface")
    reject("missing-zero-beam-app", expected, expected[:at] + expected[at+1:])
    at = next(i for i, r in enumerate(expected) if r["t"] == "module" and r["owner"] == BASELINE)
    reject("baseline-shrink", expected, expected[:at] + expected[at+1:])
    if missing_observed_assignment_control():
        reports.append("missing-observed-assignment")
    return reports


def missing_observed_assignment_control():
    path = HERE / f"{PHASE}-INVENTORY-core.jsonl"
    with path.open("rb") as stream:
        for line in stream:
            if not line.startswith(PREFIX):
                raise ValueError(f"core observed receipt has an untagged row: {path}")
            row = json.loads(line[len(PREFIX):])
            if row.get("kind") == "pending_module" and row.get("app") == "debugger":
                observed = {
                    "t": "observed_module",
                    "namespace": "observed",
                    "lane": "core",
                    "identity": {"kind": "module", "app": row["app"], "module": row["module"]},
                    "app": row["app"],
                    "module": row["module"],
                    "owner": owner(row["app"], row["module"]),
                    "record_sha256": digest(canon(row).encode()),
                }
                try:
                    assert_equal([observed], [])
                except ValueError as error:
                    message = str(error)
                    return all(
                        value in message
                        for value in (
                            "lane=core",
                            "type=module",
                            "identity=",
                            f"owner={observed['owner']}",
                        )
                    )
                return False
    raise ValueError(f"core observed receipt lacks debugger:dbg_idb pending identity: {path}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["generate", "verify"])
    parser.add_argument("--source-dir", type=Path)
    parser.add_argument("--negative-controls", action="store_true")
    args = parser.parse_args()
    expected = manifest(args.source_dir)
    if args.command == "generate":
        if not args.source_dir:
            parser.error("generate requires --source-dir for exact research fingerprints")
        with OUTPUT.open("wb") as raw:
            with gzip.GzipFile(filename="", fileobj=raw, mode="wb", mtime=0) as stream:
                stream.write(("\n".join(map(canon, expected)) + "\n").encode())
    with gzip.open(OUTPUT, "rt") as stream:
        actual = [json.loads(line) for line in stream]
    if not args.source_dir:
        saved = [r for r in actual if r["t"] == "exact_source"]
        source_keys = {(r["lane"], r["module"]) for r in expected if r["t"] == "module" and r.get("app") == "debugger" and r["pending"]}
        if {(r["lane"], r["module"]) for r in saved} != source_keys or len(saved) != len(source_keys):
            raise ValueError("exact debugger research source identities incomplete")
        expected += saved
    assert_equal(expected, actual)
    summary = {"manifest_bytes": OUTPUT.stat().st_size, "canonical_records": len(actual),
               "negative_controls": controls(expected) if args.negative_controls else [], "lanes": {}}
    for lane in ("core", "floor"):
        subset = [r for r in actual if r.get("lane") == lane]
        summary["lanes"][lane] = {"apps": sum(r["t"] == "app" for r in subset),
            "pending_modules": sum(r["t"] == "module" and r["pending"] for r in subset),
            "pending_roots": sum(r["t"] == "root" for r in subset),
            "zero_hit_pending_modules": sum(r["t"] == "module" and bool(r["zero_graph_hits"]) for r in subset),
            "first_family_modules": sum(r["t"] == "module" and r["owner"] == PHASE for r in subset),
            "first_family_roots": sum(r["t"] == "root" and r["owner"] == PHASE for r in subset)}
        summary["lanes"][lane]["source_discovered_roots"] = sum(r["t"] == "source_root" for r in subset)
    print(canon(summary))


if __name__ == "__main__":
    main()
