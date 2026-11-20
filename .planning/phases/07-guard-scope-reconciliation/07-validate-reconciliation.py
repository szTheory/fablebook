#!/usr/bin/env python3
"""Validate the bounded R11 producer-inspection result."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from pathlib import Path


PHASE = Path(__file__).resolve().parent
PROPOSAL = PHASE / "07-CORE-PRODUCER-REQUEST-R11-PROPOSAL.json"
REVIEW = PHASE / "07-CORE-PRODUCER-REQUEST-R11-REVIEW.md"
ANALYSIS = PHASE / "07-CORE-PRODUCER-ANALYSIS-R11.md"
R10_RECEIPT = PHASE / "07-CORE-PRODUCER-ANALYSIS.md"


class ValidationError(Exception):
    pass


def expect(condition: bool, message: str) -> None:
    if not condition:
        raise ValidationError(message)


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValidationError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def read_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    except (OSError, json.JSONDecodeError) as exc:
        raise ValidationError(f"cannot read valid JSON from {path.name}: {exc}") from exc


def require_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except OSError as exc:
        raise ValidationError(f"cannot read {path.name}: {exc}") from exc


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def one(pattern: str, text: str, label: str) -> str:
    match = re.search(pattern, text, re.MULTILINE)
    if not match:
        raise ValidationError(f"missing {label}")
    return match.group(1)


def validate_producer_review() -> None:
    proposal = read_json(PROPOSAL)
    source = proposal.get("source", {})
    expected_sha = "2b6eb2b1033ad429edc6f751ed2f55298a272610123085027c87ece59b379fdb"
    expect(proposal.get("request_id") == "R11", "proposal request ID is not R11")
    expect(source.get("path") == "test/support/guard_aggregate_reconciliation_evidence.ex", "unexpected producer path")
    expect(source.get("bytes") == 86693, "unexpected producer byte count")
    expect(source.get("lines") == 2357, "unexpected producer line count")
    expect(source.get("sha256") == expected_sha, "proposal producer hash differs")
    expect(source.get("span") == "complete_file" and source.get("truncation_allowed") is False, "proposal permits an incomplete read")
    exclusions = proposal.get("excluded_inputs_and_actions", [])
    expect(any("Do not replay or reuse R10 or R9" in item for item in exclusions), "proposal does not exclude R10 and R9 reuse")
    expect(len(proposal.get("source", {})) > 0, "proposal source identity is empty")

    review = require_text(REVIEW)
    proposal_sha = digest(PROPOSAL)
    expect("**Verdict:** PASS" in review, "R11 request review is not PASS")
    reviewed_sha = one(r"\*\*Frozen proposal SHA-256:\*\* `([0-9a-f]{64})`", review, "frozen proposal digest")
    expect(reviewed_sha == proposal_sha, "R11 review is bound to a different proposal digest")

    analysis = require_text(ANALYSIS)
    expect("**Request:** R11" in analysis, "analysis is not bound to R11")
    expect("**Capture status:** COMPLETE" in analysis, "full-file capture is not marked complete")
    expect("**Captured bytes:** 86,693" in analysis, "captured byte count differs")
    expect("**Captured lines:** 2,357" in analysis, "captured line count differs")
    captured_sha = one(r"\*\*Captured SHA-256:\*\* `([0-9a-f]{64})`", analysis, "captured producer digest")
    expect(captured_sha == expected_sha, "captured producer digest differs")
    expect("**Coverage:** PASS" in analysis and "24 sequential, non-overlapping chunks" in analysis, "complete sequential coverage is not recorded")
    expect("**Decision:** NO-GO" in analysis, "producer analysis lacks an explicit safe/no-go decision")
    expect("does not provide the required current-core input maps" in analysis, "no-go rationale is missing")

    r10 = require_text(R10_RECEIPT)
    expect("R10 is spent" in r10 and "will not be retried" in r10, "R10 closure receipt does not preserve its no-retry status")
    expect("R10 is not reused" in r10, "R10 reuse is not explicitly excluded")

    print("PASS: proposal digest, independent review, complete R11 capture, and explicit no-go result are consistent.")
    print("STOP: no current-core generation or partition is supported under the reviewed source and execution limits.")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--stage", choices=["producer-review"], required=True)
    args = parser.parse_args()
    try:
        if args.stage == "producer-review":
            validate_producer_review()
    except ValidationError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
