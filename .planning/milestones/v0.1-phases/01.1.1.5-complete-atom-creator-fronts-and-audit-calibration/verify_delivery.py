#!/usr/bin/env python3
"""Verify phase delivery receipts against GitHub and local main ancestry."""

from __future__ import annotations

import argparse
import copy
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any, Callable


REQUIRED_CHECKS = ("core", "floor", "dialyzer", "security", "ci-gate")
EXPECTED_SLICES = {
    "plan-01": ("01", "unchanged_reuse"),
    "plan-02": ("02", "unchanged_reuse"),
    "plan-03": ("03", "delivered"),
    "plan-04": ("04", "delivered"),
    "pr-23": (None, "historical_reuse"),
}
FORBIDDEN_PATHS = (
    "lib/",
    ".github/",
    "mix.exs",
    "mix.lock",
    "mix.floor.lock",
    ".credo.exs",
    "credo/checks/banned_calls.ex",
)
REQUIRED_PR_FIELDS = (
    "url,state,headRefOid,baseRefName,mergeCommit,body,files,statusCheckRollup"
)
REQUIRED_RUN_FIELDS = "databaseId,url,headSha,status,conclusion,jobs"
SHA_RE = re.compile(r"^[0-9a-f]{40}$")
PR_URL_RE = re.compile(r"^https://github\.com/szTheory/fablebook/pull/[1-9][0-9]*$")
REF_RE = re.compile(r"^[A-Za-z0-9._/-]+$")


class VerificationError(Exception):
    """A receipt field, live GitHub value, or ancestry check did not validate."""


def need(condition: bool, message: str) -> None:
    if not condition:
        raise VerificationError(message)


def nonempty(value: Any, where: str) -> str:
    need(isinstance(value, str) and value.strip() != "", f"{where} must be a nonempty string")
    return value


def sha(value: Any, where: str) -> str:
    need(isinstance(value, str) and SHA_RE.fullmatch(value) is not None, f"{where} must be a 40-character SHA")
    return value


def require_object(value: Any, where: str) -> dict[str, Any]:
    need(isinstance(value, dict), f"{where} must be an object")
    return value


def require_array(value: Any, where: str) -> list[Any]:
    need(isinstance(value, list), f"{where} must be an array")
    return value


def validate_pr_paths(files: Any, where: str) -> None:
    paths: list[str] = []
    for row in require_array(files, f"{where}.files"):
        if isinstance(row, str):
            path = row
        else:
            path = nonempty(require_object(row, f"{where}.files[]").get("path"), f"{where}.files[].path")
        path = path.lstrip("./")
        paths.append(path)

    has_contract = any(path.startswith("test/contract/") for path in paths)
    guarded_implementations = {
        "credo/checks/banned_calls.ex",
    }
    has_guarded_implementation = any(path in guarded_implementations for path in paths)
    need(
        not (has_contract and has_guarded_implementation),
        f"{where} co-edits a contract guard and its implementation",
    )

    for path in paths:
        matched = next(
            (forbidden for forbidden in FORBIDDEN_PATHS if path == forbidden or path.startswith(forbidden)),
            None,
        )
        need(matched is None, f"{where} changes forbidden path {path}")


def _check_success(value: Any, where: str) -> None:
    need(isinstance(value, dict), f"{where} must be an object")
    need(str(value.get("status", "")).lower() == "completed", f"{where} is not completed")
    need(str(value.get("conclusion", "")).lower() == "success", f"{where} did not succeed")


def _job_url(run_url: str, job_id: Any) -> str:
    return f"{run_url.rstrip('/')}/job/{job_id}"


def _required_check_records(delivery: dict[str, Any], where: str) -> dict[str, dict[str, Any]]:
    rows = require_array(delivery.get("required_checks"), f"{where}.required_checks")
    by_name: dict[str, dict[str, Any]] = {}
    for index, raw in enumerate(rows):
        row = require_object(raw, f"{where}.required_checks[{index}]")
        name = nonempty(row.get("name"), f"{where}.required_checks[{index}].name")
        need(name in REQUIRED_CHECKS, f"{where} has unknown required check {name}")
        need(name not in by_name, f"{where} has duplicate required check {name}")
        for key in (
            "run_id",
            "run_url",
            "head_sha",
            "status",
            "conclusion",
            "job_id",
            "job_name",
            "job_url",
            "job_conclusion",
        ):
            nonempty(row.get(key), f"{where}.required_checks[{index}].{key}")
        need(str(row["status"]).lower() == "completed", f"{where}/{name} recorded status is not completed")
        need(str(row["conclusion"]).lower() == "success", f"{where}/{name} recorded conclusion is not success")
        need(str(row["job_conclusion"]).lower() == "success", f"{where}/{name} recorded job conclusion is not success")
        sha(row["head_sha"], f"{where}/{name}.head_sha")
        need(str(row["run_id"]).isdigit(), f"{where}/{name}.run_id must be numeric")
        need(str(row["job_id"]).isdigit(), f"{where}/{name}.job_id must be numeric")
        by_name[name] = row

    missing = sorted(set(REQUIRED_CHECKS) - set(by_name))
    need(not missing, f"{where} missing required check(s): {', '.join(missing)}")
    return by_name


def _check_run_record(run_id: str, expected_url: str, expected_sha: str, client: Any) -> dict[str, Any]:
    try:
        live = require_object(client.run_view(run_id), f"run {run_id}")
    except VerificationError:
        raise
    except Exception as error:
        raise VerificationError(f"gh run view failed for run {run_id}: {error}") from error

    need(str(live.get("databaseId")) == run_id, f"run {run_id} identity mismatch")
    need(live.get("url") == expected_url, f"run {run_id} URL mismatch")
    need(live.get("headSha") == expected_sha, f"run {run_id} head SHA mismatch")
    _check_success(live, f"run {run_id}")
    return live


def _validate_delivery(delivery: dict[str, Any], expected: dict[str, Any], client: Any, base_ref: str) -> None:
    delivery_id = nonempty(delivery.get("id"), "delivery.id")
    where = f"delivery {delivery_id}"
    need(delivery_id == expected.get("id"), f"{where} delivery identity mismatch")
    need(delivery.get("expected_id") == expected["id"], f"{where} expected identity mismatch")
    need(delivery.get("plan_ids") == expected.get("plan_ids"), f"{where} plan identities mismatch")
    need(delivery.get("pr_url") == expected.get("pr_url"), f"{where} PR URL differs from expected delivery")

    tested_sha = sha(delivery.get("tested_head_sha"), f"{where}.tested_head_sha")
    merge_sha = sha(delivery.get("merge_sha"), f"{where}.merge_sha")
    base_branch = nonempty(delivery.get("base_branch"), f"{where}.base_branch")
    need(base_branch == "main", f"{where} base branch must be main")
    pr_url = nonempty(delivery.get("pr_url"), f"{where}.pr_url")
    checks = _required_check_records(delivery, where)

    try:
        pr = require_object(client.pr_view(pr_url), f"PR {pr_url}")
    except VerificationError:
        raise
    except Exception as error:
        raise VerificationError(f"gh pr view failed for {pr_url}: {error}") from error

    need(pr.get("url") == pr_url, f"{where} live PR URL mismatch")
    need(str(pr.get("state", "")).upper() == "MERGED", f"{where} PR is not merged")
    need(pr.get("headRefOid") == tested_sha, f"{where} PR head differs from tested head")
    need(pr.get("baseRefName") == base_branch, f"{where} PR base branch mismatch")
    merge = require_object(pr.get("mergeCommit"), f"{where}.mergeCommit")
    need(merge.get("oid") == merge_sha, f"{where} recorded/live merge SHA mismatch")
    body = nonempty(pr.get("body"), f"{where}.body")
    need(tested_sha in body, f"{where} PR body omits tested head SHA")

    run_urls = {row["run_url"] for row in checks.values()}
    for run_url in sorted(run_urls):
        need(run_url in body, f"{where} PR body omits required run URL {run_url}")

    validate_pr_paths(pr.get("files"), where)

    rollup = require_array(pr.get("statusCheckRollup"), f"{where}.statusCheckRollup")
    live_checks: dict[str, dict[str, Any]] = {}
    for index, raw in enumerate(rollup):
        row = require_object(raw, f"{where}.statusCheckRollup[{index}]")
        name = row.get("name")
        if name in REQUIRED_CHECKS:
            need(name not in live_checks, f"{where} has duplicate live check {name}")
            live_checks[name] = row

    for name, recorded in checks.items():
        live_check = live_checks.get(name)
        need(live_check is not None, f"{where} missing required live check {name}")
        _check_success(live_check, f"{where}/{name} live check")
        need(live_check.get("detailsUrl") == recorded["job_url"], f"{where}/{name} required job URL mismatch")
        need(recorded["head_sha"] == tested_sha, f"{where}/{name} recorded head differs from tested head")

        run_id = str(recorded["run_id"])
        run_url = recorded["run_url"]
        run = _check_run_record(run_id, run_url, tested_sha, client)
        jobs = require_array(run.get("jobs"), f"run {run_id}.jobs")
        job_id = str(recorded["job_id"])
        matches = [job for job in jobs if isinstance(job, dict) and str(job.get("databaseId")) == job_id]
        need(len(matches) == 1, f"{where}/{name} job identity mismatch")
        job = matches[0]
        need(job.get("name") == recorded["job_name"], f"{where}/{name} job name mismatch")
        need(job.get("url") == recorded["job_url"], f"{where}/{name} job URL mismatch")
        need(job.get("url") == _job_url(run_url, job_id), f"{where}/{name} job URL does not belong to recorded run")
        _check_success(job, f"{where}/{name} job")
        need(str(job.get("conclusion", "")).lower() == str(recorded["job_conclusion"]).lower(), f"{where}/{name} job conclusion mismatch")
        details_run_match = re.search(r"/actions/runs/(\d+)/job/(\d+)(?:$|\?)", str(live_check.get("detailsUrl", "")))
        need(
            details_run_match is not None
            and details_run_match.group(1) == run_id
            and details_run_match.group(2) == job_id,
            f"{where}/{name} check URL does not identify the recorded run/job",
        )

    try:
        ancestor = client.is_ancestor(merge_sha, base_ref)
    except Exception as error:
        raise VerificationError(f"git merge ancestry check failed for {where}: {error}") from error
    need(ancestor is True, f"{where} merge SHA is not an ancestor of {base_ref}")


def verify_receipt(receipt: Any, client: Any, base_ref: str) -> int:
    receipt = require_object(receipt, "receipt")
    need(receipt.get("schema") == "fablebook.phase-delivery/1", "receipt.schema is unsupported")
    need(receipt.get("phase") == "01.1.1.5", "receipt.phase must be 01.1.1.5")
    nonempty(base_ref, "base_ref")
    need(
        REF_RE.fullmatch(base_ref) is not None and not base_ref.startswith("-") and ".." not in base_ref,
        "base_ref is not a safe Git ref name",
    )

    expected_rows = require_array(receipt.get("expected_deliveries"), "receipt.expected_deliveries")
    expected_by_id: dict[str, dict[str, Any]] = {}
    for index, raw in enumerate(expected_rows):
        row = require_object(raw, f"receipt.expected_deliveries[{index}]")
        identity = nonempty(row.get("id"), f"receipt.expected_deliveries[{index}].id")
        need(identity in EXPECTED_SLICES, f"receipt has unknown expected delivery identity {identity}")
        need(identity not in expected_by_id, f"receipt has duplicate expected delivery identity {identity}")
        plan_id, disposition = EXPECTED_SLICES[identity]
        need(row.get("disposition") == disposition, f"receipt/{identity} has wrong disposition")
        if plan_id is not None:
            need(row.get("plan_ids") == [plan_id], f"receipt/{identity} has wrong plan identity")
        expected_by_id[identity] = row

        if disposition == "unchanged_reuse":
            nonempty(row.get("evidence"), f"receipt/{identity}.evidence")
        else:
            pr_url = nonempty(row.get("pr_url"), f"receipt/{identity}.pr_url")
            need(PR_URL_RE.fullmatch(pr_url) is not None, f"receipt/{identity}.pr_url is not a canonical repository PR URL")
            if identity == "plan-03":
                need(pr_url == "https://github.com/szTheory/fablebook/pull/38", "receipt/plan-03 must reference merged PR #38")
            if identity == "pr-23":
                need(pr_url == "https://github.com/szTheory/fablebook/pull/23", "receipt/pr-23 must reference historical PR #23")

    missing_expected = sorted(set(EXPECTED_SLICES) - set(expected_by_id))
    need(not missing_expected, f"receipt omits expected delivery slice(s): {', '.join(missing_expected)}")

    deliveries = require_array(receipt.get("deliveries"), "receipt.deliveries")
    actual_by_expected: dict[str, dict[str, Any]] = {}
    delivery_ids: set[str] = set()
    for index, raw in enumerate(deliveries):
        delivery = require_object(raw, f"receipt.deliveries[{index}]")
        delivery_id = nonempty(delivery.get("id"), f"receipt.deliveries[{index}].id")
        need(delivery_id not in delivery_ids, f"receipt has duplicate delivery identity {delivery_id}")
        delivery_ids.add(delivery_id)
        expected_id = nonempty(delivery.get("expected_id"), f"receipt/{delivery_id}.expected_id")
        need(expected_id in ("plan-03", "plan-04"), f"receipt has unknown delivery identity {expected_id}")
        need(expected_id not in actual_by_expected, f"receipt has duplicate delivery for {expected_id}")
        actual_by_expected[expected_id] = delivery

    expected_active = {identity for identity, (_, disposition) in EXPECTED_SLICES.items() if disposition == "delivered"}
    need(set(actual_by_expected) == expected_active, "receipt omits or adds a substantive delivery")

    for expected_id, delivery in actual_by_expected.items():
        _validate_delivery(delivery, expected_by_id[expected_id], client, base_ref)

    historical = expected_by_id["pr-23"]
    historical_url = nonempty(historical.get("pr_url"), "receipt/pr-23.pr_url")
    need(historical_url == "https://github.com/szTheory/fablebook/pull/23", "receipt/pr-23 must reference historical PR #23")
    try:
        historical_pr = require_object(client.pr_view(historical_url), "historical PR #23")
    except VerificationError:
        raise
    except Exception as error:
        raise VerificationError(f"gh pr view failed for historical PR #23: {error}") from error
    need(historical_pr.get("url") == historical_url, "historical PR #23 URL mismatch")
    need(str(historical_pr.get("state", "")).upper() == "MERGED", "historical PR #23 link is not merged")

    return len(actual_by_expected)


class GitHubReadOnlyClient:
    """Thin read-only client; command execution is injected for offline self-tests."""

    def __init__(self, run_command: Callable[[list[str]], Any]):
        self.run_command = run_command

    def _json(self, argv: list[str]) -> Any:
        result = self.run_command(argv)
        if result.returncode != 0:
            raise VerificationError(
                f"command failed ({result.returncode}): {' '.join(argv)}: {result.stderr.strip()}"
            )
        try:
            return json.loads(result.stdout)
        except (TypeError, json.JSONDecodeError) as error:
            raise VerificationError(f"command returned invalid JSON: {' '.join(argv)}") from error

    def pr_view(self, url: str) -> Any:
        return self._json(["gh", "pr", "view", url, "--json", REQUIRED_PR_FIELDS])

    def run_view(self, run_id: str) -> Any:
        return self._json(["gh", "run", "view", run_id, "--json", REQUIRED_RUN_FIELDS])

    def is_ancestor(self, merge_sha: str, base_ref: str) -> bool:
        result = self.run_command(["git", "merge-base", "--is-ancestor", merge_sha, base_ref])
        if result.returncode == 0:
            return True
        if result.returncode == 1:
            return False
        raise VerificationError(
            f"command failed ({result.returncode}): git merge-base --is-ancestor {merge_sha} {base_ref}: {result.stderr.strip()}"
        )


def _real_command(argv: list[str]) -> Any:
    return subprocess.run(argv, capture_output=True, text=True, check=False)


def _fixture() -> tuple[dict[str, Any], dict[str, Any], dict[str, Any], set[str]]:
    """Build an in-memory receipt and matching GitHub data for the offline control."""
    tested = "a" * 40
    merge03 = "b" * 40
    merge04 = "c" * 40
    pr03_url = "https://github.com/szTheory/fablebook/pull/38"
    pr04_url = "https://github.com/szTheory/fablebook/pull/40"
    historical_url = "https://github.com/szTheory/fablebook/pull/23"
    expected = [
        {"id": "plan-01", "plan_ids": ["01"], "disposition": "unchanged_reuse", "evidence": "01-SUMMARY.md"},
        {"id": "plan-02", "plan_ids": ["02"], "disposition": "unchanged_reuse", "evidence": "02-SUMMARY.md"},
        {"id": "plan-03", "plan_ids": ["03"], "disposition": "delivered", "pr_url": pr03_url},
        {"id": "plan-04", "plan_ids": ["04"], "disposition": "delivered", "pr_url": pr04_url},
        {"id": "pr-23", "plan_ids": [], "disposition": "historical_reuse", "pr_url": historical_url},
    ]

    prs: dict[str, dict[str, Any]] = {}
    runs: dict[str, dict[str, Any]] = {}
    deliveries = []
    ancestors = {merge03, merge04}
    for plan, pr_url, merge_sha, run_id in (
        ("plan-03", pr03_url, merge03, "41542627355"),
        ("plan-04", pr04_url, merge04, "41542627356"),
    ):
        run_url = f"https://github.com/szTheory/fablebook/actions/runs/{run_id}"
        jobs: list[dict[str, Any]] = []
        rollup: list[dict[str, Any]] = []
        records: list[dict[str, Any]] = []
        for index, name in enumerate(REQUIRED_CHECKS, start=1):
            job_id = str(int(run_id) + index)
            job_url = _job_url(run_url, job_id)
            jobs.append(
                {
                    "databaseId": int(job_id),
                    "name": name,
                    "url": job_url,
                    "status": "completed",
                    "conclusion": "success",
                }
            )
            rollup.append(
                {
                    "name": name,
                    "detailsUrl": job_url,
                    "status": "COMPLETED",
                    "conclusion": "SUCCESS",
                }
            )
            records.append(
                {
                    "name": name,
                    "run_id": run_id,
                    "run_url": run_url,
                    "head_sha": tested,
                    "status": "completed",
                    "conclusion": "success",
                    "job_id": job_id,
                    "job_name": name,
                    "job_url": job_url,
                    "job_conclusion": "success",
                }
            )
        runs[run_id] = {
            "databaseId": int(run_id),
            "url": run_url,
            "headSha": tested,
            "status": "completed",
            "conclusion": "success",
            "jobs": jobs,
        }
        prs[pr_url] = {
            "url": pr_url,
            "state": "MERGED",
            "headRefOid": tested,
            "baseRefName": "main",
            "mergeCommit": {"oid": merge_sha},
            "body": f"Tested head {tested}\nExact-head CI: {run_url}",
            "files": [{"path": "test/contract/tier_sweep_test.exs"}, {"path": "docs/phase.md"}],
            "statusCheckRollup": rollup,
        }
        deliveries.append(
            {
                "id": plan,
                "expected_id": plan,
                "plan_ids": ["03" if plan == "plan-03" else "04"],
                "pr_url": pr_url,
                "tested_head_sha": tested,
                "base_branch": "main",
                "merge_sha": merge_sha,
                "required_checks": records,
            }
        )

    prs[historical_url] = {"url": historical_url, "state": "MERGED"}
    receipt = {"schema": "fablebook.phase-delivery/1", "phase": "01.1.1.5", "expected_deliveries": expected, "deliveries": deliveries}
    return receipt, prs, runs, ancestors


class FixtureCommands:
    """Injected fake subprocess adapter used only by --self-test."""

    def __init__(self, prs: dict[str, Any], runs: dict[str, Any], ancestors: set[str]):
        self.prs = prs
        self.runs = runs
        self.ancestors = ancestors
        self.calls: list[list[str]] = []
        self.fail_command: str | None = None
        self.invalid_json_command: str | None = None

    def __call__(self, argv: list[str]) -> Any:
        self.calls.append(list(argv))
        command_key = " ".join(argv[:3])
        if self.fail_command == command_key:
            return _fake_result(2, "", "injected command failure")
        if self.invalid_json_command == command_key:
            return _fake_result(0, "not-json", "")
        if argv[:3] == ["gh", "pr", "view"]:
            url = argv[3]
            if url not in self.prs:
                return _fake_result(1, "", "PR not found")
            return _fake_result(0, json.dumps(self.prs[url]), "")
        if argv[:3] == ["gh", "run", "view"]:
            run_id = argv[3]
            if run_id not in self.runs:
                return _fake_result(1, "", "run not found")
            return _fake_result(0, json.dumps(self.runs[run_id]), "")
        if argv[:3] == ["git", "merge-base", "--is-ancestor"]:
            return _fake_result(0 if argv[3] in self.ancestors else 1, "", "")
        raise AssertionError(f"self-test crossed its offline command boundary: {argv!r}")


def _fake_result(returncode: int, stdout: str, stderr: str) -> Any:
    return type("FakeCompletedProcess", (), {"returncode": returncode, "stdout": stdout, "stderr": stderr})()


def _expect_rejection(name: str, receipt: dict[str, Any], client: GitHubReadOnlyClient, base_ref: str, expected_text: str) -> None:
    try:
        verify_receipt(receipt, client, base_ref)
    except VerificationError as error:
        need(expected_text.lower() in str(error).lower(), f"self-test {name} hit the wrong invariant: {error}")
    else:
        raise VerificationError(f"self-test {name} was accepted")


def self_test() -> int:
    def deny_external_audit(event: str, _args: Any) -> None:
        if event.startswith("subprocess.") or event.startswith("socket.") or event in {"os.system", "os.exec", "os.spawn"}:
            raise RuntimeError(f"self-test crossed the offline boundary via audit event {event}")

    sys.addaudithook(deny_external_audit)
    receipt, prs, runs, ancestors = _fixture()
    commands = FixtureCommands(prs, runs, ancestors)
    client = GitHubReadOnlyClient(commands)
    need(verify_receipt(receipt, client, "origin/main") == 2, "self-test valid fixture was rejected")
    need(all(row[:1] != ["gh"] or row[1:2] in (["pr"], ["run"]) for row in commands.calls), "self-test issued an unexpected command")

    cases = 0

    def reject(name: str, expected_text: str, mutate_receipt: Callable[[dict[str, Any]], None] | None = None, mutate_fixture: Callable[[dict[str, Any], dict[str, Any], set[str]], None] | None = None) -> None:
        nonlocal cases
        changed_receipt = copy.deepcopy(receipt)
        changed_prs = copy.deepcopy(prs)
        changed_runs = copy.deepcopy(runs)
        changed_ancestors = set(ancestors)
        if mutate_receipt:
            mutate_receipt(changed_receipt)
        if mutate_fixture:
            mutate_fixture(changed_prs, changed_runs, changed_ancestors)
        fake = FixtureCommands(changed_prs, changed_runs, changed_ancestors)
        _expect_rejection(name, changed_receipt, GitHubReadOnlyClient(fake), "origin/main", expected_text)
        cases += 1

    first_delivery = lambda r: r["deliveries"][0]
    first_check = lambda r: first_delivery(r)["required_checks"][0]
    pr03 = "https://github.com/szTheory/fablebook/pull/38"
    run03 = "41542627355"

    reject("changed PR head", "head differs", mutate_fixture=lambda p, r, a: p[pr03].update(headRefOid="d" * 40))
    reject("unrelated run head", "run 41542627355 head", mutate_fixture=lambda p, r, a: r[run03].update(headSha="d" * 40))
    reject(
        "unrelated run identity",
        "URL mismatch",
        mutate_receipt=lambda r: first_check(r).update(run_url="https://github.com/szTheory/fablebook/actions/runs/999"),
        mutate_fixture=lambda p, r, a: p[pr03].update(body=p[pr03]["body"] + "\nhttps://github.com/szTheory/fablebook/actions/runs/999"),
    )
    reject("missing run URL", "nonempty string", mutate_receipt=lambda r: first_check(r).update(run_url=""))
    reject("missing job URL", "nonempty string", mutate_receipt=lambda r: first_check(r).update(job_url=""))
    reject("wrong merge SHA", "merge SHA mismatch", mutate_receipt=lambda r: first_delivery(r).update(merge_sha="e" * 40))
    reject("merge outside main ancestry", "not an ancestor", mutate_fixture=lambda p, r, a: a.clear())
    reject(
        "contract and guard implementation co-edit",
        "co-edits",
        mutate_fixture=lambda p, r, a: p[pr03].update(files=[{"path": "test/contract/banned_calls_test.exs"}, {"path": "credo/checks/banned_calls.ex"}]),
    )
    reject("forbidden product path", "forbidden path", mutate_fixture=lambda p, r, a: p[pr03].update(files=[{"path": "lib/fablebook.ex"}]))
    reject("malformed schema", "schema is unsupported", mutate_receipt=lambda r: r.update(schema="wrong"))
    reject("missing merge field", "40-character SHA", mutate_receipt=lambda r: first_delivery(r).update(merge_sha=None))
    reject("duplicate expected identity", "duplicate expected", mutate_receipt=lambda r: r["expected_deliveries"].append(copy.deepcopy(r["expected_deliveries"][0])))
    reject("unknown expected identity", "unknown expected", mutate_receipt=lambda r: r["expected_deliveries"][0].update(id="future-plan"))
    reject("omitted substantive slice", "omits expected", mutate_receipt=lambda r: r["expected_deliveries"].pop(3))
    reject("duplicate delivery identity", "duplicate delivery identity", mutate_receipt=lambda r: r["deliveries"].append(copy.deepcopy(r["deliveries"][0])))
    reject("unknown delivery identity", "unknown delivery identity", mutate_receipt=lambda r: r["deliveries"][0].update(expected_id="future-plan"))
    reject("missing required receipt check", "missing required check", mutate_receipt=lambda r: first_delivery(r).update(required_checks=first_delivery(r)["required_checks"][1:]))
    reject("missing live required check", "missing required live check", mutate_fixture=lambda p, r, a: p[pr03]["statusCheckRollup"].pop(0))
    reject("skipped required check", "did not succeed", mutate_fixture=lambda p, r, a: p[pr03]["statusCheckRollup"][0].update(status="COMPLETED", conclusion="SKIPPED"))
    reject("pending required check", "not completed", mutate_fixture=lambda p, r, a: p[pr03]["statusCheckRollup"][0].update(status="IN_PROGRESS", conclusion=""))
    reject("failed required check", "did not succeed", mutate_fixture=lambda p, r, a: p[pr03]["statusCheckRollup"][0].update(status="COMPLETED", conclusion="FAILURE"))
    reject("run identity mismatch", "identity mismatch", mutate_fixture=lambda p, r, a: r[run03].update(databaseId=1))
    reject("recorded run conclusion mismatch", "recorded conclusion", mutate_receipt=lambda r: first_check(r).update(conclusion="failure"))
    reject("job identity mismatch", "job identity mismatch", mutate_receipt=lambda r: first_check(r).update(job_id="999999"))
    reject("job name mismatch", "job name mismatch", mutate_receipt=lambda r: first_check(r).update(job_name="wrong"))
    reject("job conclusion mismatch", "did not succeed", mutate_fixture=lambda p, r, a: r[run03]["jobs"][0].update(conclusion="failure"))
    reject("recorded job conclusion mismatch", "recorded job conclusion", mutate_receipt=lambda r: first_check(r).update(job_conclusion="failure"))
    reject("job URL mismatch", "job URL mismatch", mutate_fixture=lambda p, r, a: p[pr03]["statusCheckRollup"][0].update(detailsUrl="https://example.invalid/job/1"))
    reject("absent PR body tested head", "omits tested head", mutate_fixture=lambda p, r, a: p[pr03].update(body="no evidence"))
    reject("absent PR body run link", "omits required run URL", mutate_fixture=lambda p, r, a: p[pr03].update(body=f"Tested head {'a' * 40}"))

    # Exercise actual CLI adapter failure and JSON decode paths without a real process.
    for failure_name, fail_attr, expected_text in (
        ("CLI failure", "fail_command", "command failed"),
        ("JSON failure", "invalid_json_command", "invalid JSON"),
    ):
        fake = FixtureCommands(copy.deepcopy(prs), copy.deepcopy(runs), set(ancestors))
        setattr(fake, fail_attr, "gh pr view")
        _expect_rejection(failure_name, receipt, GitHubReadOnlyClient(fake), "origin/main", expected_text)
        cases += 1

    need(cases >= 28, f"self-test executed only {cases} negative controls")
    print(f"Offline delivery verifier self-test passed: 1 valid fixture, {cases} rejected mutation/failure controls; no live delivery was checked.")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true", help="run offline receipt validator controls")
    parser.add_argument("--receipt", type=Path, help="phase delivery receipt JSON")
    parser.add_argument("--base-ref", default="origin/main", help="current main ref used for merge ancestry")
    args = parser.parse_args(argv)

    try:
        if args.self_test:
            if args.receipt is not None:
                raise VerificationError("--self-test does not accept --receipt")
            return self_test()
        if args.receipt is None:
            raise VerificationError("--receipt is required unless --self-test is used")
        receipt = json.loads(args.receipt.read_text(encoding="utf-8"))
        checked = verify_receipt(receipt, GitHubReadOnlyClient(_real_command), args.base_ref)
        print(f"Verified {checked} substantive phase deliveries, their exact-head required checks, and main ancestry.")
        return 0
    except (OSError, json.JSONDecodeError, VerificationError) as error:
        print(f"delivery verification failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
