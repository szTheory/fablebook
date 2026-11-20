---
phase: "07"
slug: "guard-scope-reconciliation"
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-11-20"
---

# Phase 7 — Validation Strategy

> Retrospective Nyquist audit: all 12 plan tasks have automated acceptance checks; the phase-local validators and required core/floor CI passed. No additional test or dependency was needed.

## Test Infrastructure

| Property | Value |
|---|---|
| Framework | Python standard-library evidence validators and the existing Mix/ExUnit core and floor lanes |
| Configuration | No new test framework or recurring CI job |
| Quick focused check | `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --check` and `--self-test` |
| Full phase check | Phase task validators, core `mix ci`, `mix hex.audit`, and required hosted core/floor/security/Dialyzer checks |
| Dependency change | None added; the authorized LiveView patch updates one existing lock entry |

## Sampling Strategy

- Run each plan task's targeted validator after producing its evidence.
- Run cheap hash, schema, identity, and partition checks before the full core suite.
- Re-run the final reconciliation checks and full core suite after the authorized LiveView rebaseline.
- Final local core suite: 461 passed, 10 lane-excluded; hosted candidate and post-merge checks also passed.

## Per-Task Verification Map

| Task | Requirement | Automated coverage | Result |
|---|---|---|---|
| 07-01 Task 1 | RSC-01, RSC-02 | Retained-inputs; reader and validator self-tests; metadata-only manifest generation | COVERED |
| 07-01 Task 2 | RSC-01 | Reviewed-manifest scan and current-generation reconciliation | COVERED |
| 07-01 Task 3 | RSC-01, RSC-02 | Partition, malformed-MFA, identity, and negative-control self-tests | COVERED |
| 07-02 Task 1 | RSC-03 | Independent schedule-review digest and shape validation | COVERED |
| 07-02 Task 2 | RSC-03 | One-use source approval and complete path-to-batch validation | COVERED |
| 07-03 Task 1 | RSC-03 | Batch 01 read-time identity, size, and provenance validation | COVERED |
| 07-03 Task 2 | RSC-03 | Batch 02 read-time identity, size, and provenance validation | COVERED |
| 07-04 Task 1 | RSC-03, RSC-04 | Final record validator and adversarial self-tests | COVERED |
| 07-04 Task 2 | RSC-04 | Generated summary and recommendation consistency check | COVERED |
| 07-05 Task 1 | RSC-01, RSC-02, RSC-03, RSC-04 | Exact dependency-patch checker, unchanged floor and declaration checks, setup, and Hex audit | COVERED |
| 07-05 Task 2 | RSC-01 | Current export producer self-test and JSON schema parse | COVERED |
| 07-05 Task 3 | RSC-01, RSC-02, RSC-03, RSC-04 | Rebaseline validator, Hex audit, full core CI, and whitespace check | COVERED |

The exact commands and failure conditions remain in each plan's `<verify>` blocks. Their combined results are recorded in the plan summaries and [phase verification](07-VERIFICATION.md). The summaries use `requirements` frontmatter; their union, the requirement tables in `07-VERIFICATION.md`, and `.planning/REQUIREMENTS.md` cover RSC-01 through RSC-04.

## Manual-Only

No missing automated acceptance checks. Human review remains limited to interpreting the bounded static observations and deciding whether to authorize any later scope; those are deliberate phase boundaries, not unverified code behavior.

## Validation Sign-Off

- [x] All 12 plan tasks have automated checks.
- [x] Requirement coverage matches the phase verification and summaries.
- [x] Cheap validators precede the long core suite.
- [x] No new dependency or recurring CI work was introduced.
- [x] `nyquist_compliant: true` is set.

**Approval:** Automated coverage validated 2026-11-20 from the completed task receipts and green hosted runs.

## Validation Audit 2026-11-20

| Metric | Count |
|---|---:|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

---

# Detailed Validation Map

This document defines the one-off local acceptance checks for Guard Scope Reconciliation. It adds no dependency or recurring CI job and does not authorize target source reads.

## Lane identity and membership

The current core identity binds the full root `mix.lock`, `.tool-versions`, the exact `mix.exs` dependency declaration, Elixir/OTP releases, resolved application roots, required production dependency closure, producer digest, reviewed compiled-file manifest, and root summary. The manifest records normalized asdf root locators, hashes of the resolved paths, and root device/inode identity. Each scanned BEAM row also records its path, byte length, stable file metadata, package/release identity, and SHA-256 of that file's canonical exported module/function/arity list. It is not a hash of the complete BEAM file or its debug information.

The one-off Python reader uses only the standard library. Its first pass reads lock, toolchain, Hex/application metadata and filesystem metadata. Only after an independent review of the exact manifest may its second pass read each listed file's `Atom`/`AtU8` and `ExpT` chunk payloads. It decodes names as strings, validates indices and bounds, and seeks over all other chunks. It does not use `beam_lib`, `:file.consult`, `Mix.Dep.Lock.read`, eval, atom conversion, target module loading, or target function calls. Any unknown encoding or metadata shape fails closed. A synthetic in-memory self-test confirms chunk selection and that the debug payload is never read.

The compiled manifest review binds exact file paths and stat fields. The scan checks device, inode, size, modification/change timestamps before and after each read. The scan receipt binds the producer, manifest, root summary, and review-file digests. The current core inventory is not combined with floor evidence.

The floor identity is reused only from the accepted ENV06 generation after confirming its full `mix.floor.lock` digest, exact Elixir/OTP versions, and the full Phase 6 supplement digest and EX-177 source/MFA/caller values. Each of its 226 rows is preserved separately and marked as retained, not rescanned. The core map is also 226 rows, freshly checked against compiled exports. Each output preserves the row identity, both raw `identity.lane_matches` arrays, and each original field (`baseline_mfas`, `added_mfas`, `delivered_mfas`, `delivered_now_missing_mfas`, `delivered_scope_mfas`, `live_mfas`, `missing_mfas`, `original_live_mfas`, `pending_mfas`, and `replacement_live_mfas`). Lane-match text is split by trying every colon position against the combined known MFA set; this preserves colons and slashes inside function names and rejects unknown or ambiguous parses. Every manifest BEAM path must have at least one export row and a per-file digest. Core membership is compared to fresh exports. Floor values point to the exact retained aggregate field and are labeled as accepted saved-row membership with no claim about current floor presence. The provenance records each field separately, current-known additions relative to saved `live_mfas`, removals from saved `live_mfas`, and unparseable values. It also states that unknown additions outside the retained saved-row scope cannot be compared because the historical whole-library record contains only a count and digest.

Each matched current MFA must resolve to exactly one compiled module and its exact OTP/Elixir application or locked Hex package identity. The core export map is fresh. The floor map is bound to the accepted ENV06 row evidence and unchanged floor lock/runtime; it is not represented as a newly scanned floor build.

## Review gates and outputs

The manifest review consists of `07-CORE-CURRENT-BEAM-MANIFEST.jsonl` and `07-CORE-CURRENT-BEAM-ROOTS.json`. The reviewer records PASS and both exact digests in `07-CORE-EXPORT-READER-REVIEW.md`; the machine approval binds the review, producer, manifest, and root summary. The second pass refuses to run without that approval.

After the scan, the validator produces row-by-row membership, a live-source-gap view, an empty target-source-association file until observations exist, and a provenance manifest. The gap JSONL intentionally carries one row per saved-live source MFA. It is not a full ENV06 gap restatement: provenance binds the full accepted gap receipt and reports its per-lane source/caller/unknown-target-set counts, along with baseline-only source rows omitted from the live view. Any identity mismatch, missing expected live MFA, missing/unlisted manifest export coverage, duplicate/unmapped module, or unparseable saved value stops before family selection and source scheduling.

## Requirement to evidence map

| Requirement | Automated proof | Focused negative control | Human judgment retained |
|---|---|---|---|
| RSC-01 | `python3 .planning/phases/07-guard-scope-reconciliation/07-validate-reconciliation.py --stage current-generation` verifies pins, reviewed manifest, export coverage for every listed BEAM path, separate 226-row core and floor maps, per-field membership, package identity, exact saved-row differences, source-gap selectors, and explicit live-only gap-output scope. | Swap lane identity; mutate a member or lock/runtime; omit a BEAM export group; duplicate a module; use an ambiguous colon MFA; change generation; break an archived row pointer; reject the row and stop before partitioning. | None for identity or set equality. |
| RSC-02 | The validator checks exact family/complement arrays, disjointness, union, counts, and documented canonical digests. | Remove/duplicate a member; overlap family/complement; mutate count/digest; reject. | The evidence-family rationale is stated as a proposal, not code-candidate selection. |
| RSC-03 | `--stage schedule-review`, `--stage source-approval`, and `--stage observations --batch <ID>` validate exact paths, selectors, request IDs, one-use boundaries, provenance and per-batch limits. | Change lane, path, selector, hash, span, request ID, schedule digest, or caller-closure claim; reject. | Independent review of the source schedule precedes each read; bounded observations do not establish exhaustive closure. |
| RSC-04 | `--self-test`, `--check`, and `--check-summary` validate sizing fields, final report consistency, and preserved stops. | Mutate candidate-null, collision, aggregate, R9, SEC-01, Macro, Walking Skeleton, or automatic-follow-up state; reject. | The recommendation ends at the owner's next-scope decision. |

## Cheap-first sequence

1. Run `--stage retained-inputs` to confirm ENV06 acceptance, archived row hashes/relationships, all live source-gap pointers, current core lock, unchanged floor lock/runtime pins, and the pinned Phase 6 EX-177 supplement facts. This reads planning metadata only.
2. Run the in-memory reader and row-parser self-tests. Produce the sorted core BEAM path/stat manifest and roots summary without opening BEAM contents or target source bodies.
3. Independently review the exact manifest, roots, package identities, bounds, and digests. Do not read BEAM chunk payloads until this review passes.
4. Scan only reviewed files, reading only `Atom`/`AtU8` and `ExpT` payloads as strings and integers. Hash canonical exports rows, not complete BEAM files. Validate core identity and compare every saved guard-row field. Independently verify the accepted floor lock/runtime and each ENV06 source-gap selector without scanning floor; caller and unknown-target-set rows remain bound by the retained full receipt and reported counts. The old whole-library record has only a count/digest, so report exact differences for saved rows only and mark whole-universe historical member differences unavailable.
5. Validate all 226 row maps and the accepted unchanged floor identity before partitioning. On any unexplained mismatch or unmappable value, stop before selecting a family or producing a source schedule.
6. If membership reconciles, validate the proposed-family partition and exact source path/MFA-selector schedule. Independently review and approve that schedule before any target source body read. Immediately before each read task, recheck pins, membership, review, approval, schedule digest, and its batch of no more than five files. Plans 03 and 05 cover at most twenty-five exact files. If more are required, stop with a phase-split recommendation. Read each scheduled file once into a bounded buffer; capture byte length, SHA-256, exact observed line/byte span, and provenance. Empty batches are valid only when they have no assigned entries.
7. Validate each observation batch, then the final record and human summary.

Every mismatch stops the workflow before the next source read. No runtime or generated-code execution, package-wide search, R9 use, exhaustive caller-closure claim, dependency installation, or recurring CI change is part of this validation map.
