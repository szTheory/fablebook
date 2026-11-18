---
status: testing
phase: 03-Guard Aggregate Scope Rejoin and Candidate Sizing
source: [03-VERIFICATION.md]
started: 2026-11-18
updated: 2026-11-18
---

## Current Test

number: 1
name: Final evidence and candidate-fit review
expected: |
  Confirm the row-level crosswalk, lane records, exact pending complements, and typed source/caller gaps are inspectable and internally consistent. Confirm unknown source, caller, context, and effort measurements remain unknown, candidate is null, and implementation is unauthorized.
awaiting: user response

## Tests

### 1. Final evidence and candidate-fit review

Review [03-RECOVERY-RECONCILIATION.md](03-RECOVERY-RECONCILIATION.md), [03-RECOVERY-READINESS.md](03-RECOVERY-READINESS.md), and [03-SIZING.json](03-SIZING.json). Use the saved validator result (`consumer_consistent`) and the reported hashes to trace any row or gap you want to inspect.

expected: The gap identities and remedies are inspectable; missing measurements are not represented as known; no candidate is selected.
result: pending

### 2. Owner-only collision and retained decision stops

Confirm the actual-library collision, Macro caller-AST, and explanation checkpoints remain unresolved and owned; confirm that the current static-only boundary, SEC-01, aggregate gate, and Walking Skeleton stop remain in force. Resolving the collision or opening source access is a separate scoped decision and is not part of this UAT.

expected: Candidate remains null and implementation unauthorized until the owner resolves the relevant stops; all other retained owners and open statuses remain intact.
result: pending

## Summary

total: 2
passed: 0
issues: 0
pending: 2
skipped: 0
blocked: 0

## Gaps
