---
status: complete
phase: 02-bounded-asn-1-rtt-guard-evidence
source:
  - 02-01-SUMMARY.md
  - 02-02-SUMMARY.md
  - 02-03-SUMMARY.md
  - 02-04-SUMMARY.md
  - 02-05-SUMMARY.md
started: 2026-11-13T05:38:18.512Z
updated: 2026-11-13T15:47:27.951Z
---

## Current Test

[testing complete]

## Tests

### 1. Core lane evidence and controls
expected: The core lane resolves exact pinned source bytes for the three selected MFAs, rejects invalid evidence, and completes its required full suite.
result: pass
source: automated
evidence: `02-01-SUMMARY.md`, `02-05-SUMMARY.md`, and local full core suite on tested tree `3c87cdb0e1ba20eaefa50d4b918b8970b006bcfd` (442 passed, 14 excluded). The final reviewed head `ded4af612df3346b8516f4a027772ed3d2bbd53f` passed the core job in [PR CI 43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316); merged main `3817912c861286608183c057d2e38ff7a260bd6e` passed core in [main CI 43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473).

### 2. Floor lane evidence and controls
expected: The floor lane independently resolves its exact pinned source bytes for the same three MFAs, rejects invalid evidence, and completes its required full suite.
result: pass
source: automated
evidence: `02-02-SUMMARY.md`, `02-05-SUMMARY.md`, and local full floor suite on tested tree `3c87cdb0e1ba20eaefa50d4b918b8970b006bcfd` (456 passed, 6 excluded). The final reviewed head `ded4af612df3346b8516f4a027772ed3d2bbd53f` passed the floor job in [PR CI 43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316); merged main `3817912c861286608183c057d2e38ff7a260bd6e` passed floor in [main CI 43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473).

### 3. Cross-lane membership and partitions
expected: Core and floor independently retain exact 177-member sets, the selected three and 174-member complement, plus the distinct historical 13/164/161 partition, with individually falsifiable controls.
result: pass
source: automated
evidence: `02-03-SUMMARY.md`; the core and floor integration contracts each passed two tests. The final PR head passed both lanes in [CI 43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316), and the merged main head passed both again in [CI 43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473).

### 4. Independent source review and correction
expected: A reviewer checks the six lane/function dispositions against cited source spans, rejects claims beyond static evidence, and repeats focused checks after correcting the lane-specific test invocation.
result: pass
source: independent-review
evidence: `02-REVIEW.md` and `02-04-SUMMARY.md` record R1, its lane-specific invocation fix, the focused core/floor/integration retests, and no source or contract-test correction. No high-severity review finding remains. The manual stop for any future real-library collision remains in force.

### 5. Planning tests isolated from guarded files
expected: Planning-contract tests are delivered in the prerequisite PR separately from the five-plan evidence/test phase, after which both full runtime lanes pass.
result: pass
source: automated
evidence: PR #87 delivered the planning-test prerequisite separately. Reviewed head `2768a58a2dea1d58055c950aac2c30b3bb17e87a` passed [PR CI 43355783802](https://github.com/szTheory/fablebook/actions/runs/43355783802), merged as `9a6f45e314f9a43a0c35fb85006d50e618f5c931`, and passed [main CI 43445896621](https://github.com/szTheory/fablebook/actions/runs/43445896621). Phase 2 PR #88 was then rebased onto main: final head `ded4af612df3346b8516f4a027772ed3d2bbd53f` passed [PR CI 43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316), merged as `3817912c861286608183c057d2e38ff7a260bd6e`, and passed [main CI 43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473). Both merge receipts are green.

## Summary

total: 5
passed: 5
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

No user-facing UI or runtime behavior is part of this static evidence phase, so browser/device interaction was not useful UAT. Existing automated lane tests, the completed independent source review, and the merged delivery receipts provide the relevant evidence. The security record now distinguishes the satisfied high-severity delivery gate from four open, non-blocking medium collision limitations; this UAT does not claim runtime safety, dynamic-caller absence, native-internals safety, complete EX-107 closure, Walking Skeleton readiness, or SEC-01 completion.
