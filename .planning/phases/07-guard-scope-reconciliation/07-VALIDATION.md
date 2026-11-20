# Phase 7 Validation Map

This document defines the one-off local acceptance checks for Guard Scope Reconciliation. It adds no dependency or recurring CI job and does not authorize target source reads.

## Requirement to evidence map

| Requirement | Automated proof | Focused negative control | Human judgment retained |
|---|---|---|---|
| RSC-01 | `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --stage membership` checks accepted ENV06 inputs, current lane pins, exact per-lane membership, and saved-inventory differences. | Swap lane identity; mutate one member; change active generation; reject exact expected/observed mismatch and stop. | None for identity or set equality. |
| RSC-02 | `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --self-test` checks exact family/complement arrays, disjointness, union, counts, and documented canonical digests. | Remove/duplicate a member; overlap family/complement; mutate count or digest; reject. | The rationale for the one evidence family is stated as a proposal only. |
| RSC-03 | `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --stage observations --batch <ID>` checks one-use request, approved manifest binding, exact provenance, and explicit gap/claim fields for each planned batch. | Change lane, path, selector, hash, span, request ID, or caller-closure claim; reject. | Independent review of the source schedule precedes each read; bounded observations do not establish exhaustive closure. |
| RSC-04 | `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --self-test` and `--check-summary` check sizing fields, preserved stops, and report consistency. | Mutate candidate-null, collision, aggregate, R9, SEC-01, Macro, Walking Skeleton, or automatic-follow-up state; reject. | The recommendation is presented to the owner, who decides whether any increment is authorized. |

## Cheap-first sequence

1. Confirm ENV06 is the accepted evidence generation and validate current lane identities from `mix.lock`, `mix.floor.lock`, and recorded runtime pins.
2. Parse only the explicit evidence allowlist; compare full per-lane memberships and stop on any unexplained mismatch.
3. Validate proposed-family partition, counts, canonical digests, and the exact source path/MFA-selector manifest.
4. Independently review the manifest and bind approval to its digest before any target source body read.
5. Immediately before each read task, recheck pins, membership, review, approval, manifest digest, and its exact batch of no more than five files. Plan 03 prepares batches 01–02 and Plan 05 prepares batches 03–05, covering up to twenty-five exact files in fixed, reviewed plans. If more than twenty-five exact files are required, stop with a phase-split recommendation and do not read sources. Read each scheduled file once into a bounded buffer; capture byte length, SHA-256, exact observed line/byte span, and provenance. Compare any saved file hash when present; if none exists, bind the new hash to the verified lane/package identity. Empty prepared batches are valid only when no manifest entry is assigned to them.
6. Validate each observation batch, then the final record and human summary.

Every mismatch stops the workflow before the next source read. No runtime or generated-code execution, package-wide search, R9 use, exhaustive caller-closure claim, dependency installation, or recurring CI change is part of this validation map.
