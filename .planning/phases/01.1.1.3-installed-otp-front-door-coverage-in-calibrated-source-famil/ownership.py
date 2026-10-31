#!/usr/bin/env python3
"""Offline planning ledger: exact receipt membership, never a semantic verdict."""
import argparse
import collections
import copy
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import re
import stat
import tarfile
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
RECEIPTS = ROOT / ".planning/phases/01.1.1.2-installed-otp-inventory-and-common-test-guard-slice"
OUTPUT = HERE / "01.1.1.3-OWNERSHIP.jsonl.gz"
PREFIX = b"FABLEBOOK_OTP_INVENTORY_V2 "
PHASE = "01.1.1.3"
BASELINE = "existing-active-baseline"
SEEDS = {"dbg_idb", "dbg_istk", "dbg_wx_interpret"}
SUPPORT = {"dbg_wx_mon", "dbg_wx_filedialog_win", "dbg_wx_mon_win"}
OBSERVED_FILES = {lane: HERE / f"{PHASE}-INVENTORY-{lane}.jsonl" for lane in ("core", "floor")}
SOURCE_ARCHIVE = ROOT / "test/fixtures/guards/exact_sources.tar.gz"
SOURCE_ARCHIVE_SHA256 = "a31f1d1b19e1c8df543f4844af9d47b7ca7a79985b42bd78186f56c04da06342"
SOURCE_VERSIONS = {"core": "29.1.2", "floor": "27.3.4.9"}
FAMILY_SOURCE_HASHES = {
    "core": {
        "dbg_idb": "3505ba8ce32c8ca147a1195a183cc78a841b28de479c29b5e92822afefea3593",
        "dbg_istk": "a71cef371ac1875a22e851d44e4e47b5a1b87309709fca32073e78d51825e01c",
        "dbg_wx_interpret": "0731379c05425123893f08dab6d149f2e42f095f9245ff18d098691ab87520bb",
    },
    "floor": {
        "dbg_idb": "990726cde6815d7616b01d13adf4f8cacc7540b702507ba0fea8ca349bbbe2c5",
        "dbg_istk": "4f68bca517244f361bb915000fe299259242d6a8d733b064ed47d2f8872b8f66",
        "dbg_wx_interpret": "d41c9d6225a8817bd792abb202916020782d72b59e439a891b0ebc4864e38098",
    },
}
ACTIVE_KINDS = ("active_app", "active_module", "active_export", "active_edge")
IDENTITY_KINDS = (
    "app", "beam", "source_app", "source_file", "active_app", "active_module",
    "active_export", "active_edge", "export", "reached", "boundary", "pending_app",
    "pending_module", "pending_mfa",
)
SOURCE_DECODER_PATTERN = re.compile(
    rb"from_external\(\{stack,Stk\}\)\s*->\s*put\(\?STACK,\s*binary_to_term\(Stk\)\)"
)
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


def receipt_file(path, lane):
    path = Path(path)
    file_hash, body_hash = hashlib.sha256(), hashlib.sha256()
    rows = []
    with path.open("rb") as stream:
        for line_number, line in enumerate(stream, 1):
            file_hash.update(line)
            if not line.startswith(PREFIX):
                raise ValueError(f"{lane}: untagged receipt row at {path}:{line_number}")
            try:
                row = json.loads(line[len(PREFIX):])
            except json.JSONDecodeError as error:
                raise ValueError(f"{lane}: malformed receipt row at {path}:{line_number}: {error}") from error
            if row.get("kind") != "footer":
                body_hash.update(line)
            rows.append(row)
    if not rows or rows[0].get("kind") != "meta" or rows[0].get("lane") != lane:
        raise ValueError(f"{lane}: receipt metadata is missing or has the wrong lane: {path}")
    footer = rows[-1]
    if footer.get("kind") != "footer" or footer.get("sha256") != body_hash.hexdigest():
        raise ValueError(f"{lane}: receipt body digest failed: {path}")
    if any(row.get("kind") in ("meta", "footer") for row in rows[1:-1]):
        raise ValueError(f"{lane}: receipt has a misplaced metadata or footer row: {path}")
    return file_hash.hexdigest(), rows, footer["sha256"]


def raw_identity(row):
    return canon({"kind": row["kind"], **{k: v for k, v in row.items() if k != "kind"}})


def identity_summaries(rows):
    by_kind = collections.defaultdict(list)
    for row in rows:
        kind = row.get("kind")
        if kind in IDENTITY_KINDS:
            by_kind[kind].append(digest(raw_identity(row).encode()))
    return {
        kind: {
            "count": len(values),
            "identity_count": len(set(values)),
            "identity_sha256": digest("\n".join(sorted(set(values))).encode()),
            "fingerprints": multiset(values),
        }
        for kind, values in sorted(by_kind.items())
    }


def assert_active_subset(lane, original_rows, observed_rows):
    for kind in ACTIVE_KINDS:
        original = {raw_identity(row) for row in original_rows if row.get("kind") == kind}
        observed = {raw_identity(row) for row in observed_rows if row.get("kind") == kind}
        missing = sorted(original - observed)
        if missing:
            sample = [digest(value.encode()) for value in missing[:3]]
            raise ValueError(
                f"{lane}: historical active {kind} identities shrank despite current receipt; "
                f"missing_count={len(missing)} missing_identity_sha256={sample}"
            )


def source_material(source_dir=None):
    try:
        archive_bytes = SOURCE_ARCHIVE.read_bytes()
    except OSError as error:
        raise ValueError(f"approved debugger source archive is unavailable: {SOURCE_ARCHIVE}") from error
    if digest(archive_bytes) != SOURCE_ARCHIVE_SHA256:
        raise ValueError(f"approved debugger source archive fingerprint changed: {SOURCE_ARCHIVE}")
    sources = {}
    with tarfile.open(fileobj=io.BytesIO(archive_bytes), mode="r:gz") as archive:
        for lane, modules in FAMILY_SOURCE_HASHES.items():
            for module, expected_hash in modules.items():
                member_name = f"{lane}/debugger/src/{module}.erl"
                try:
                    member = archive.getmember(member_name)
                except KeyError as error:
                    raise ValueError(f"approved source archive lacks {member_name}") from error
                if not member.isfile():
                    raise ValueError(f"approved source archive entry is not a regular file: {member_name}")
                stream = archive.extractfile(member)
                if stream is None:
                    raise ValueError(f"approved source archive entry is unreadable: {member_name}")
                data = stream.read()
                if digest(data) != expected_hash:
                    raise ValueError(f"approved source fingerprint differs for {lane}:{module}")
                sources[(lane, module)] = data
    for lane in SOURCE_VERSIONS:
        data = sources[(lane, "dbg_istk")]
        if not SOURCE_DECODER_PATTERN.search(data):
            raise ValueError(f"{lane}: source-discovered debugger decoder front changed; review its caller domain")
        if source_dir:
            external = Path(source_dir) / SOURCE_VERSIONS[lane] / "src" / "dbg_istk.erl"
            try:
                external_data = external.read_bytes()
            except OSError as error:
                raise ValueError(f"{lane}: approved source input is unavailable: {external}") from error
            if digest(external_data) != digest(data):
                raise ValueError(f"{lane}: approved source input differs from the checked archive: {external}")
    return sources


def source_root_records(lane, rows, sources):
    data = sources[(lane, "dbg_istk")]
    source_file = next(
        (row for row in rows if row.get("kind") == "source_file"
         and row.get("app") == "debugger" and row.get("path") == "src/dbg_istk.erl"),
        None,
    )
    if source_file is None or source_file.get("bytes") != len(data):
        raise ValueError(f"{lane}: checked dbg_istk source fingerprint does not match the receipt source identity")
    return [{
        "t": "observed_source_root",
        "namespace": "observed",
        "lane": lane,
        "identity": {"kind": "source_root", "lane": lane, "app": "debugger", "module": "dbg_istk",
                     "function": "from_external", "arity": 1},
        "app": "debugger",
        "module": "dbg_istk",
        "function": "from_external",
        "arity": 1,
        "owner": PHASE,
        "source_path": "debugger/src/dbg_istk.erl",
        "source_sha256": digest(data),
        "source_bytes": len(data),
        "caller_chain": ["dbg_istk.from_external/1", "erlang.binary_to_term/1"],
        "disposition": "exported caller-binary decoder; internal round-trip is not an enforced caller restriction",
        "references": [BASELINE],
        "receipt_pending_root": False,
    }]


def load_ledger(path=OUTPUT):
    with gzip.open(path, "rt") as stream:
        try:
            return [json.loads(line) for line in stream]
        except json.JSONDecodeError as error:
            raise ValueError(f"ownership ledger has malformed JSON: {path}: {error}") from error


def receipt(lane):
    path = RECEIPTS / f"01.1.1.2-INVENTORY-{lane}.jsonl"
    file_hash, rows, _ = receipt_file(path, lane)
    return path, file_hash, rows


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
        raise ValueError(
            f"{lane}: new pending applications need explicit research owners: {sorted(unknown)}; "
            "add each application to a named source-task route before updating ownership"
        )
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
        if pending and assigned == BASELINE:
            raise ValueError(
                f"{lane}: pending module {app}:{module} has no source-task owner; "
                "add an explicit module or application route before updating ownership"
            )
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
        assigned = owner(app, module, row["function"], row["arity"])
        if assigned == BASELINE:
            raise ValueError(
                f"{lane}: pending root has no source-task owner: "
                f"{app}:{module}:{row['function']}/{row['arity']}; add an explicit root or module route"
            )
        steps = []
        for token in row.get("caller_chain", []):
            match = re.fullmatch(r"(.+)\.([^./]+)/([0-9]+)", token)
            if not match:
                raise ValueError(f"{lane}: unparsed caller token: {token}")
            mod, fun, arity = match.groups()
            candidates = sorted(module_apps.get(mod, set()))
            step_owners = sorted({owner(a, mod, fun, int(arity)) for a in candidates})
            if len(step_owners) > 1:
                raise ValueError(
                    f"{lane}: ambiguous caller-chain ownership for {token}: "
                    f"apps={candidates} owners={step_owners}; add an explicit app/module route"
                )
            steps.append({"token": token, "apps": candidates, "owners": step_owners,
                          "resolution": "inventory" if candidates else "unresolved-external-token"})
        record = {"t": "root", "lane": lane, "app": app, "module": module,
                  "function": row["function"], "arity": row["arity"],
                  "owner": assigned,
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


def typed_identity(kind, record):
    fields_by_kind = {
        "receipt": ("path",),
        "app": ("app",),
        "module": ("app", "module"),
        "root": ("app", "module", "function", "arity"),
        "overlap": ("token",),
    }
    fields = {field: record[field] for field in fields_by_kind[kind] if field in record}
    fields["lane"] = record.get("lane")
    return {"kind": kind, **fields}


def history_projection(record):
    if record is None:
        return None
    fields = ("owner", "pending", "task", "state", "zero_graph_hits", "source", "kinds",
              "record_sha256", "steps", "chain_id", "references")
    return {field: copy.deepcopy(record[field]) for field in fields if field in record}


def derive_observed(lane, path, file_hash, body_hash, rows, original_rows, original_records, tested_head, ci_run_id):
    old_by_identity = {
        ownership_identity(row): row for row in original_records if row.get("lane") == lane
    }
    raw = derive(lane, path, file_hash, rows)
    observed = []
    beam_counts = collections.Counter(row["app"] for row in rows if row.get("kind") == "beam")
    for record in raw:
        kind = record["t"]
        row = dict(record)
        if kind == "receipt":
            row["tested_head"] = tested_head
            row["ci_run_id"] = ci_run_id
            row["ci_run_url"] = f"https://github.com/szTheory/fablebook/actions/runs/{ci_run_id}"
            row["body_sha256"] = body_hash
            row["typed_identity_sets"] = identity_summaries(rows)
            row["active_history"] = {
                active_kind: {
                    "original": identity_summaries([r for r in original_rows if r.get("kind") == active_kind]).get(active_kind),
                    "observed": identity_summaries([r for r in rows if r.get("kind") == active_kind]).get(active_kind),
                    "original_is_subset": True,
                }
                for active_kind in ACTIVE_KINDS
            }
        identity = typed_identity(kind, row)
        row["t"] = f"observed_{kind}"
        row["namespace"] = "observed"
        row["identity"] = identity
        row["identity_sha256"] = digest(canon(identity).encode())
        if kind == "app":
            row["beam_count"] = beam_counts[record["app"]]
            row["zero_beam"] = row["beam_count"] == 0
        prior = old_by_identity.get(ownership_identity(record))
        if kind in {"app", "module", "root"}:
            row["historical"] = history_projection(prior)
            if prior and prior.get("pending") and record.get("pending") is False:
                if kind == "app":
                    raise ValueError(f"{lane}: pending installed-app owner disappeared without an approved completion: {record['app']}")
                if kind == "module" and record.get("app") == "debugger" and record.get("module") in SEEDS:
                    row["owner"] = prior["owner"]
                    row["completion"] = "selected-family-source-and-guard-proved"
                elif kind == "module":
                    raise ValueError(
                        f"{lane}: pending module left the pending projection without selected-family proof: "
                        f"{record['app']}:{record['module']}; preserve its owner or route an approved completion"
                    )
            elif prior and prior.get("pending") and prior.get("owner") != record.get("owner"):
                raise ValueError(
                    f"{lane}: pending {kind} owner changed for {record.get('app')}:{record.get('module')}; "
                    "preserve the original owner or materialize an explicit owner transfer"
                )
        if kind == "overlap":
            row["historical"] = history_projection(prior)
        observed.append(row)
    return observed


def original_active_history(lane):
    _, _, rows = receipt(lane)
    return rows


def observed_receipt(lane, observed_receipt_dir):
    requested = Path(observed_receipt_dir) / f"{PHASE}-INVENTORY-{lane}.jsonl"
    if requested.is_symlink():
        raise ValueError(f"{lane}: observed receipt may not be a symlink: {requested}")
    path = requested.resolve()
    try:
        path.relative_to(ROOT.resolve())
    except ValueError as error:
        raise ValueError(f"{lane}: observed receipt must stay inside the repository: {path}") from error
    file_hash, rows, body_hash = receipt_file(path, lane)
    return path, file_hash, body_hash, rows


def completion_records(lane, original_records, observed_records, original_rows, observed_rows, sources, tested_head, ci_run_id):
    audit_path = HERE / f"{PHASE}-DEBUGGER-AUDIT.md"
    try:
        audit = audit_path.read_text()
    except OSError as error:
        raise ValueError(f"selected-family completion requires the reviewed debugger audit: {audit_path}") from error
    for module in SEEDS:
        if module not in audit:
            raise ValueError(f"selected-family audit does not establish module {module}: {audit_path}")

    original_modules = {
        row["module"]: row for row in original_records
        if row.get("t") == "module" and row.get("lane") == lane and row.get("app") == "debugger"
    }
    observed_modules = {
        row["module"]: row for row in observed_records
        if row.get("t") == "observed_module" and row.get("lane") == lane and row.get("app") == "debugger"
    }
    active_modules = {
        (row["app"], row["module"]) for row in observed_rows if row.get("kind") == "active_module"
    }
    output = []
    for module in sorted(SEEDS):
        if module not in observed_modules or ("debugger", module) not in active_modules:
            raise ValueError(f"{lane}: selected debugger module is not active in the observed receipt: {module}")
        source = sources[(lane, module)]
        source_file = next(
            (row for row in observed_rows if row.get("kind") == "source_file"
             and row.get("app") == "debugger" and row.get("path") == f"src/{module}.erl"),
            None,
        )
        if source_file is None or source_file.get("bytes") != len(source):
            raise ValueError(f"{lane}: selected source identity differs from the observed receipt: {module}")
        prior = original_modules.get(module)
        output.append({
            "t": "observed_completion",
            "namespace": "observed",
            "lane": lane,
            "identity": {"kind": "module_completion", "lane": lane, "app": "debugger", "module": module},
            "identity_sha256": digest(canon({"kind": "module_completion", "lane": lane, "app": "debugger", "module": module}).encode()),
            "app": "debugger",
            "module": module,
            "owner": prior["owner"] if prior else PHASE,
            "historical": history_projection(prior),
            "status": "complete",
            "source_sha256": digest(source),
            "source_path": f"debugger/src/{module}.erl",
            "audit_path": str(audit_path.relative_to(ROOT)),
            "guard_run_id": ci_run_id,
            "guard_run_url": f"https://github.com/szTheory/fablebook/actions/runs/{ci_run_id}",
            "tested_head": tested_head,
        })

    current_roots = {
        (row.get("app"), row.get("module"), row.get("function"), row.get("arity"))
        for row in observed_records if row.get("t") == "observed_root" and row.get("lane") == lane
    }
    for prior in original_records:
        if prior.get("t") != "root" or prior.get("lane") != lane or prior.get("app") != "debugger":
            continue
        root = (prior["app"], prior["module"], prior["function"], prior["arity"])
        if root in current_roots:
            continue
        if prior["module"] not in SEEDS:
            raise ValueError(
                f"{lane}: pending root disappeared outside the selected family: "
                f"{prior['app']}:{prior['module']}:{prior['function']}/{prior['arity']}"
            )
        if prior["module"] not in audit or prior["function"] not in audit:
            raise ValueError(f"{lane}: selected-family audit does not establish the completed root: {root}")
        module_source = sources[(lane, prior["module"])]
        completion_identity = {
            "kind": "root_completion", "lane": lane, "app": prior["app"], "module": prior["module"],
            "function": prior["function"], "arity": prior["arity"],
        }
        output.append({
            "t": "observed_completion",
            "namespace": "observed",
            "lane": lane,
            "identity": completion_identity,
            "identity_sha256": digest(canon(completion_identity).encode()),
            "app": prior["app"],
            "module": prior["module"],
            "function": prior["function"],
            "arity": prior["arity"],
            "owner": prior["owner"],
            "historical": history_projection(prior),
            "status": "complete",
            "source_sha256": digest(module_source),
            "source_path": f"debugger/src/{prior['module']}.erl",
            "audit_path": str(audit_path.relative_to(ROOT)),
            "guard_run_id": ci_run_id,
            "guard_run_url": f"https://github.com/szTheory/fablebook/actions/runs/{ci_run_id}",
            "tested_head": tested_head,
        })

    source_root_identity = {
        "kind": "source_root_completion", "lane": lane, "app": "debugger", "module": "dbg_istk",
        "function": "from_external", "arity": 1,
    }
    source = sources[(lane, "dbg_istk")]
    output.append({
        "t": "observed_completion",
        "namespace": "observed",
        "lane": lane,
        "identity": source_root_identity,
        "identity_sha256": digest(canon(source_root_identity).encode()),
        "app": "debugger",
        "module": "dbg_istk",
        "function": "from_external",
        "arity": 1,
        "owner": PHASE,
        "status": "complete",
        "source_sha256": digest(source),
        "source_path": "debugger/src/dbg_istk.erl",
        "audit_path": str(audit_path.relative_to(ROOT)),
        "guard_run_id": ci_run_id,
        "guard_run_url": f"https://github.com/szTheory/fablebook/actions/runs/{ci_run_id}",
        "tested_head": tested_head,
        "source_root_identity": True,
    })
    return output


def manifest(source_dir=None, observed_receipt_dir=None, tested_head=None, ci_run_id=None):
    sources = source_material(source_dir)
    if observed_receipt_dir:
        if not tested_head or not re.fullmatch(r"[0-9a-fA-F]{40}", tested_head):
            raise ValueError("observed receipts require the full tested code-head SHA")
        if not ci_run_id or not re.fullmatch(r"[0-9]+", str(ci_run_id)):
            raise ValueError("observed receipts require the exact passing CI run id")
        tested_head = tested_head.lower()
        ci_run_id = str(ci_run_id)
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
    meta = {"t": "meta", "schema": "fablebook.otp-ownership.v3", "children": children,
                "namespace_contract": {
                    "canonical": "historical original .2 receipt-derived identities; immutable authority",
                    "observed": "fresh .3 receipt-derived identities and source-root obligations, independently verified",
                },
                "final_gate_owner": FINAL, "baseline_owner": BASELINE,
                "routing_note": "App groups route unresolved source tasks; only source-connected measured families become executable.",
                "root_overrides": [{"app": a, "module": m, "function": f, "arity": n, "owner": o} for (a, m, f, n), o in OVERRIDES.items()],
                "source_discovered_roots": [
                    {"app": a, "module": m, "function": f, "arity": n, "owner": PHASE,
                     "source_sha256_by_lane": {
                         lane: digest(sources[(lane, m)]) for lane in SOURCE_VERSIONS
                     }}
                    for a, m, f, n in SOURCE_FRONTS
                ],
                "supporting_source_modules": sorted(SUPPORT), "measured_source_modules": sorted(SEEDS | SUPPORT),
                "source_archive": str(SOURCE_ARCHIVE.relative_to(ROOT)),
                "source_archive_sha256": SOURCE_ARCHIVE_SHA256,
                "family_source_fingerprints": FAMILY_SOURCE_HASHES,
                "observed_receipts": [],
                "tested_code_head": tested_head,
                "ci_run_id": ci_run_id,
                "ci_run_url": f"https://github.com/szTheory/fablebook/actions/runs/{ci_run_id}" if ci_run_id else None}
    records = [meta]
    observed_meta = []
    for lane in ("core", "floor"):
        path, file_hash, original_rows = receipt(lane)
        original_records = derive(lane, path, file_hash, original_rows)
        records.extend(original_records)
        for app, module, function, arity in SOURCE_FRONTS:
            records.append({"t": "source_root", "lane": lane, "app": app, "module": module,
                            "function": function, "arity": arity, "owner": PHASE,
                            "caller_chain": ["dbg_istk.from_external/1", "erlang.binary_to_term/1"],
                            "source_path": "debugger/src/dbg_istk.erl",
                            "disposition": "exported caller-binary decoder; internal round-trip is not an enforced caller restriction",
                            "references": [BASELINE], "receipt_pending_root": False})
        if observed_receipt_dir:
            observed_path, observed_file_hash, observed_body_hash, observed_rows = observed_receipt(lane, observed_receipt_dir)
            assert_active_subset(lane, original_rows, observed_rows)
            observed_records = derive_observed(
                lane, observed_path, observed_file_hash, observed_body_hash, observed_rows,
                original_rows, original_records, tested_head, ci_run_id,
            )
            observed_roots = source_root_records(lane, observed_rows, sources)
            for source_root in observed_roots:
                historical = next(
                    (row for row in records if row.get("t") == "source_root" and row.get("lane") == lane
                     and row.get("app") == source_root["app"] and row.get("module") == source_root["module"]
                     and row.get("function") == source_root["function"] and row.get("arity") == source_root["arity"]),
                    None,
                )
                source_root["historical"] = copy.deepcopy(historical)
            completions = completion_records(
                lane, original_records, observed_records, original_rows, observed_rows,
                sources, tested_head, ci_run_id,
            )
            records.extend(observed_records)
            records.extend(observed_roots)
            records.extend(completions)
            for module in sorted(SEEDS):
                source = sources[(lane, module)]
                source_file = next(
                    (row for row in observed_rows if row.get("kind") == "source_file"
                     and row.get("app") == "debugger" and row.get("path") == f"src/{module}.erl"),
                    None,
                )
                if source_file is None or source_file.get("bytes") != len(source):
                    raise ValueError(f"{lane}: selected source identity differs from the observed receipt: {module}")
                identity = {"kind": "exact_source", "lane": lane, "app": "debugger", "module": module}
                records.append({
                    "t": "observed_exact_source", "namespace": "observed", "lane": lane,
                    "identity": identity, "identity_sha256": digest(canon(identity).encode()),
                    "app": "debugger", "module": module, "owner": PHASE,
                    "bytes": len(source), "sha256": digest(source),
                    "source_path": f"debugger/src/{module}.erl",
                    "url": f"https://raw.githubusercontent.com/erlang/otp/OTP-{SOURCE_VERSIONS[lane]}/lib/debugger/src/{module}.erl",
                    "evidence_reference_owners": [PHASE] if module in SUPPORT else [],
                })
            observed_meta.append({
                "lane": lane,
                "path": str(observed_path.relative_to(ROOT)),
                "file_sha256": observed_file_hash,
                "body_sha256": observed_body_hash,
            })
    if source_dir:
        for lane, version in SOURCE_VERSIONS.items():
            source_paths = sorted((source_dir / version / "src").glob("*.erl"))
            expected_modules = {
                r["module"]: r for r in records
                if r["t"] == "module" and r.get("lane") == lane and r.get("app") == "debugger" and r["pending"]
            }
            if {p.stem for p in source_paths} != set(expected_modules):
                raise ValueError(f"{lane}: exact debugger source/module union mismatch")
            for path in source_paths:
                module = path.stem
                data = path.read_bytes()
                if len(data) != expected_modules[module]["source"]["source_bytes"]:
                    raise ValueError(f"{lane}: exact source size differs from receipt: {module}")
                if module == "dbg_istk" and not SOURCE_DECODER_PATTERN.search(data):
                    raise ValueError(f"{lane}: source-discovered decoder route changed; review the caller domain")
                records.append({"t": "exact_source", "lane": lane, "app": "debugger", "module": module,
                                "owner": owner("debugger", module), "bytes": len(data), "sha256": digest(data),
                                "source_path": f"debugger/src/{path.name}",
                                "url": f"https://raw.githubusercontent.com/erlang/otp/OTP-{version}/lib/debugger/src/{path.name}",
                                "evidence_reference_owners": [PHASE] if module in SUPPORT else []})
    records[0]["observed_receipts"] = observed_meta
    return records


def ownership_identity(record):
    if record["t"] == "overlap":
        return f"overlap|{record['lane']}|{record['token']}"
    if record.get("namespace") == "observed":
        return f"observed|{record['identity']['kind']}|{record['lane']}|{canon(record['identity'])}"
    return key(record)


def assert_equal(expected, actual):
    def details(record):
        typed = record.get("identity", {})
        typed_kind = typed.get("kind", record.get("t")) if isinstance(typed, dict) else record.get("t")
        typed_value = canon(typed) if typed else key(record)
        return (
            f"namespace={record.get('namespace', 'canonical')} lane={record.get('lane', 'unknown')} "
            f"type={typed_kind} identity={typed_value} owner={record.get('owner', 'unassigned')}"
        )

    left, right = {}, {}
    for label, records, index in (("expected", expected, left), ("ledger", actual, right)):
        for record in records:
            ident = ownership_identity(record)
            if ident in index:
                raise ValueError(f"{label}: duplicate canonical identity {details(record)}")
            index[ident] = record
    if left.keys() != right.keys():
        missing = [details(left[ident]) for ident in sorted(left.keys() - right.keys())[:4]]
        unexpected = [details(right[ident]) for ident in sorted(right.keys() - left.keys())[:4]]
        raise ValueError(f"ownership union mismatch: missing={missing} unexpected={unexpected}")
    for ident in left:
        if left[ident] != right[ident]:
            raise ValueError(
                f"changed ownership/evidence: {details(left[ident])}; "
                "regenerate routing only after assigning new input to a source task"
            )


def atomic_write(path, writer, validator, before_replace=None):
    path = Path(path)
    mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
    fd, temporary_name = tempfile.mkstemp(prefix=f".{path.name}.", suffix=".tmp", dir=path.parent)
    temporary = Path(temporary_name)
    try:
        with os.fdopen(fd, "wb") as stream:
            os.fchmod(stream.fileno(), mode)
            writer(stream)
            stream.flush()
            os.fsync(stream.fileno())
        if before_replace:
            before_replace(temporary)
        validator(temporary)
        os.replace(temporary, path)
        directory_fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    finally:
        if temporary.exists():
            temporary.unlink()


def atomic_interruption_control():
    with tempfile.TemporaryDirectory(prefix="ownership-interruption-", dir=HERE) as temp_dir:
        target = Path(temp_dir) / "prior-ledger.jsonl.gz"
        previous = io.BytesIO()
        with gzip.GzipFile(filename="", fileobj=previous, mode="wb", mtime=0) as zipped:
            zipped.write((canon({"t": "meta", "schema": "control"}) + "\n").encode())
        valid_prior = previous.getvalue()
        target.write_bytes(valid_prior)

        def writer(stream):
            with gzip.GzipFile(filename="", fileobj=stream, mode="wb", mtime=0) as zipped:
                zipped.write(b'{"t":"meta","schema":"partial"}\n')

        def interrupt(_temporary):
            raise InterruptedError("simulated interruption before validation and replacement")

        try:
            atomic_write(target, writer, lambda _temporary: None, before_replace=interrupt)
        except InterruptedError:
            pass
        else:
            raise ValueError("interrupted-write control falsely completed publication")
        if target.read_bytes() != valid_prior or json.loads(gzip.decompress(target.read_bytes()))["schema"] != "control":
            raise ValueError("interrupted-write control replaced or damaged the prior valid ledger")
        if list(Path(temp_dir).glob(f".{target.name}.*.tmp")):
            raise ValueError("interrupted-write control left a partial temporary artifact")
    return "atomic-interruption-preserves-prior"


def controls(expected, actual=None):
    actual = expected if actual is None else actual
    reports = []

    def reject(label, left, right, reasons):
        try:
            assert_equal(left, right)
        except ValueError as error:
            if not all(reason in str(error) for reason in reasons):
                raise ValueError(
                    f"negative control produced the wrong diagnostic: {label}; "
                    f"expected={reasons} actual={error}"
                ) from error
            reports.append(label)
        else:
            raise ValueError(f"negative control falsely passed: {label}")

    at = next(i for i, r in enumerate(expected) if r["t"] == "module" and r["pending"])
    reject("missing-module", expected, expected[:at] + expected[at+1:], ["missing=", "type=module"])
    reject("duplicate-module", expected, expected + [expected[at]], ["duplicate canonical identity", "type=module"])
    extra = dict(expected[at], module="unregistered_new_module")
    reject("unexpected-module", expected, expected + [extra], ["unexpected=", "unregistered_new_module"])
    at = next(i for i, r in enumerate(expected) if r["t"] == "root")
    extra = dict(expected[at], function="unregistered_new_root")
    reject("new-root-without-owner", expected + [extra], expected, ["missing=", "unregistered_new_root"])
    changed = copy.deepcopy(expected)
    changed[at]["steps"].append({"token": "new_wrapper.call/1", "apps": [], "owners": []})
    reject("new-caller-path", changed, expected, ["changed ownership/evidence", "type=root"])
    at = next(i for i, r in enumerate(expected) if r["t"] == "module" and "export" in r["kinds"])
    changed = copy.deepcopy(expected)
    changed[at]["kinds"]["export"] = {
        "count": expected[at]["kinds"]["export"]["count"] + 1,
        "sha256": digest(b"new-export"),
    }
    reject("new-export-without-review", changed, expected, ["changed ownership/evidence", "type=module"])
    at = next(i for i, r in enumerate(expected) if r["t"] == "app" and r["app"] == "erl_interface")
    reject("missing-zero-beam-app", expected, expected[:at] + expected[at+1:], ["missing=", "erl_interface"])
    at = next(i for i, r in enumerate(expected) if r["t"] == "module" and r["owner"] == BASELINE)
    reject("baseline-shrink", expected, expected[:at] + expected[at+1:], ["missing=", "type=module"])

    observed_assignment = next(
        (row for row in expected if row.get("t") == "observed_module" and row.get("pending") and row.get("owner") != BASELINE),
        None,
    )
    if observed_assignment is None:
        raise ValueError("observed receipt has no pending owned module for the deletion control")
    assignment_actual = [row for row in actual if ownership_identity(row) != ownership_identity(observed_assignment)]
    reject("missing-observed-assignment", expected, assignment_actual,
           ["missing=", "namespace=observed", f"owner={observed_assignment['owner']}"])

    completion = next(
        (row for row in expected if row.get("t") == "observed_completion"
         and row.get("identity", {}).get("kind") == "module_completion"),
        None,
    )
    if completion is None:
        raise ValueError("observed selected-family history has no completed module identity")
    completion_actual = [row for row in actual if ownership_identity(row) != ownership_identity(completion)]
    reject("missing-observed-completion-history", expected, completion_actual,
           ["missing=", "module_completion", f"owner={completion['owner']}"])

    module_index = next(
        i for i, row in enumerate(actual)
        if row.get("t") == "observed_module" and "export" in row.get("kinds", {})
    )
    changed_actual = copy.deepcopy(actual)
    export_set = changed_actual[module_index]["kinds"]["export"]
    changed_actual[module_index]["kinds"]["export"] = {
        "count": export_set["count"] + 1,
        "sha256": digest(b"observed-new-export"),
    }
    reject("observed-new-export", expected, changed_actual, ["changed ownership/evidence", "namespace=observed"])

    root = next(row for row in expected if row.get("t") == "observed_root")
    extra_root = copy.deepcopy(root)
    extra_root["identity"] = dict(root["identity"], function="unregistered_observed_root")
    extra_root["identity_sha256"] = digest(canon(extra_root["identity"]).encode())
    extra_root["function"] = "unregistered_observed_root"
    reject("observed-new-root", expected, actual + [extra_root], ["unexpected=", "unregistered_observed_root"])
    root_actual = copy.deepcopy(actual)
    root_index = next(i for i, row in enumerate(root_actual) if ownership_identity(row) == ownership_identity(root))
    root_actual[root_index]["steps"].append({"token": "new_observed_wrapper.call/1", "apps": [], "owners": []})
    reject("observed-new-caller-path", expected, root_actual, ["changed ownership/evidence", "namespace=observed"])

    source_root = next(row for row in expected if row.get("t") == "observed_source_root")
    source_root_actual = [row for row in actual if ownership_identity(row) != ownership_identity(source_root)]
    reject("missing-observed-source-root", expected, source_root_actual,
           ["missing=", "type=source_root", "namespace=observed"])
    reject("duplicate-observed-source-root", expected, actual + [source_root],
           ["duplicate canonical identity", "type=source_root", "namespace=observed"])
    new_source_root = copy.deepcopy(source_root)
    new_source_root["identity"] = dict(source_root["identity"], function="unregistered_source_root")
    new_source_root["identity_sha256"] = digest(canon(new_source_root["identity"]).encode())
    new_source_root["function"] = "unregistered_source_root"
    reject("unexpected-observed-source-root", expected, actual + [new_source_root],
           ["unexpected=", "unregistered_source_root"])

    original_path, _, original_rows = receipt("core")
    observed_path, _, _, observed_rows = observed_receipt("core", HERE)
    if original_path == observed_path:
        raise ValueError("active substitution control did not load distinct historical and observed receipts")
    mutated_rows = copy.deepcopy(observed_rows)
    target = next(i for i, row in enumerate(mutated_rows) if row.get("kind") == "active_edge")
    mutated_rows[target]["function"] = "unregistered_equal_count_substitution"
    if sum(row.get("kind") == "active_edge" for row in mutated_rows) != sum(row.get("kind") == "active_edge" for row in observed_rows):
        raise ValueError("active substitution control changed the active-edge count")
    try:
        assert_active_subset("core", original_rows, mutated_rows)
    except ValueError as error:
        if "historical active active_edge identities shrank" not in str(error):
            raise ValueError(f"equal-count active substitution produced the wrong diagnostic: {error}") from error
        reports.append("equal-count-active-substitution")
    else:
        raise ValueError("negative control falsely passed: equal-count-active-substitution")

    reports.append(atomic_interruption_control())
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


def observed_dir_from_metadata(meta):
    entries = meta.get("observed_receipts", [])
    if not entries:
        return None
    expected_paths = {lane: str(path.relative_to(ROOT)) for lane, path in OBSERVED_FILES.items()}
    by_lane = {}
    for entry in entries:
        lane = entry.get("lane")
        if lane not in expected_paths or lane in by_lane or entry.get("path") != expected_paths[lane]:
            raise ValueError(f"ownership metadata has an invalid observed receipt path: {entry}")
        by_lane[lane] = entry
    if set(by_lane) != set(OBSERVED_FILES):
        raise ValueError(f"ownership metadata must discover one observed receipt per lane: {sorted(by_lane)}")
    return HERE


def write_ledger(stream, records):
    with gzip.GzipFile(filename="", fileobj=stream, mode="wb", mtime=0) as zipped:
        zipped.write(("\n".join(map(canon, records)) + "\n").encode())


def validate_ledger_file(path, expected):
    assert_equal(expected, load_ledger(path))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["generate", "verify"])
    parser.add_argument("--source-dir", type=Path)
    parser.add_argument("--observed-receipt-dir", type=Path)
    parser.add_argument("--tested-head")
    parser.add_argument("--ci-run-id")
    parser.add_argument("--negative-controls", action="store_true")
    args = parser.parse_args()

    if args.command == "generate":
        if not args.source_dir:
            parser.error("generate requires --source-dir for exact research fingerprints")
        if not args.observed_receipt_dir:
            parser.error("generate requires --observed-receipt-dir for fresh lane receipts")
        if not args.tested_head or not args.ci_run_id:
            parser.error("generate requires --tested-head and --ci-run-id for exact-head provenance")
        expected = manifest(args.source_dir, args.observed_receipt_dir, args.tested_head, args.ci_run_id)
        atomic_write(OUTPUT, lambda stream: write_ledger(stream, expected),
                     lambda path: validate_ledger_file(path, expected))
        actual = load_ledger()
        assert_equal(expected, actual)
    else:
        actual = load_ledger()
        meta = next((row for row in actual if row.get("t") == "meta"), None)
        if meta is None:
            raise ValueError("ownership ledger is missing its metadata record")
        observed_dir = args.observed_receipt_dir or observed_dir_from_metadata(meta)
        tested_head = args.tested_head or meta.get("tested_code_head")
        ci_run_id = args.ci_run_id or meta.get("ci_run_id")
        expected = manifest(args.source_dir, observed_dir, tested_head, ci_run_id)
        if not args.source_dir:
            saved = [row for row in actual if row.get("t") == "exact_source"]
            source_keys = {
                (row["lane"], row["module"]) for row in expected
                if row.get("t") == "module" and row.get("app") == "debugger" and row.get("pending")
            }
            if {(row["lane"], row["module"]) for row in saved} != source_keys or len(saved) != len(source_keys):
                raise ValueError("exact debugger research source identities incomplete")
            expected += saved
        assert_equal(expected, actual)

    negative_results = controls(expected, actual) if args.negative_controls else []
    summary = {
        "manifest_bytes": OUTPUT.stat().st_size,
        "canonical_records": len(actual),
        "observed_records": sum(row.get("namespace") == "observed" for row in actual),
        "tested_code_head": actual[0].get("tested_code_head"),
        "ci_run_id": actual[0].get("ci_run_id"),
        "negative_controls": negative_results,
        "lanes": {},
    }
    for lane in ("core", "floor"):
        subset = [row for row in actual if row.get("lane") == lane]
        summary["lanes"][lane] = {
            "apps": sum(row.get("t") == "app" for row in subset),
            "pending_modules": sum(row.get("t") == "module" and row.get("pending") for row in subset),
            "observed_pending_modules": sum(row.get("t") == "observed_module" and row.get("pending") for row in subset),
            "pending_roots": sum(row.get("t") == "root" for row in subset),
            "zero_hit_pending_modules": sum(row.get("t") == "module" and bool(row.get("zero_graph_hits")) for row in subset),
            "completed_family_identities": sum(row.get("t") == "observed_completion" for row in subset),
            "source_discovered_roots": sum(row.get("t") in {"source_root", "observed_source_root"} for row in subset),
        }
    print(canon(summary))


if __name__ == "__main__":
    main()
