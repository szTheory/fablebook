---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
reviewed: 2026-11-18T23:10:01Z
depth: focused
author: /root/phase3_security_audit
files_reviewed: 3
files_reviewed_list:
  - test/contract/tier_sweep_test.exs
  - test/support/guard_aggregate_reconciliation_evidence.ex
  - .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-05-validate-evidence.py
findings:
  critical: 0
  high: 0
  medium: 0
  low: 0
  info: 0
  total: 0
status: clean
---

# Phase 3: R8 helper-revision review

**Result:** PASS. The focused-failure fix keeps the R8 source observation as an immutable pre-edit snapshot and binds the current helper identity separately through the revision receipt. The R8 schedule/span and the first focused failure are bound by exact hashes. The validator fails closed when the helper, request, span, schedule or failure receipt is missing or mismatched. R2/R3 remain attached to their historical helper identity and spans. The review found no new source, caller-closure, digest, candidate or implementation claim; the existing safety stops remain intact.

| Artifact | SHA-256 | Bytes |
|---|---|---:|
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `eb4305c5aef3c0a60d8d7ef378498fef670a633c7e9e574de2a3e07bf68fbf71` | 85,202 |
| `03-05-T2-POST-R8-HELPER-REVISION.json` | `8c28cfff4aed64b70aa2f57753e28ae7ae05af12bdf4669fc5c9a8d4bb0a4f4a` | 2,217 |
| `04-R8-SCHEDULE.json` | `869b30595af03c58ceabf4af69f7fec516968198305d2119ea4f09d65a4d9633` | — |
| `03-05-CORE-FOCUSED-R8-FAILURE.json` | `5965083654495bc092e7f59e9dde4a6bb5536f7e6d4e9eb43651d1c21e26f69c` | 1,676 |

The R8 observed span is bytes `[63660, 71408)`, 7,748 bytes, SHA-256 `2861e6e06895760381c8ae3bd0fa7e5d9bc126493fc1173cb4ddbeaaec147682`. The R8 pre-edit helper snapshot remains `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370` (83,805 bytes).

No tests were run during this review. No findings.
