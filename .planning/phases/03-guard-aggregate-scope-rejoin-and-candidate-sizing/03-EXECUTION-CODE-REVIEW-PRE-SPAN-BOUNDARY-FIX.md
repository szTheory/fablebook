---
phase: 03-guard-aggregate-scope-rejoin-and-candidate-sizing
reviewed: 2026-11-18T23:35:29Z
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

# Phase 3: R8-bound helper and manifest revision review

**Result:** PASS. The helper keeps the R8 source observation immutable, checks the live helper identity separately, and requires the Phase 4 manifest’s nested post-observation revision to match the R8 snapshot, the current helper, and the revision receipt. The revision binds both focused failures and the prior helper revision. The Python validator enforces the same identity relationships and rejects stale, duplicate or mismatched inputs. The contract selection remains unchanged. R2/R3 remain historical; source resolution, caller closure, legacy digest, candidate selection, implementation authority and the collision stop remain open.

| Artifact | SHA-256 | Bytes |
|---|---|---:|
| `test/contract/tier_sweep_test.exs` | `f66d5c7f8467b1665d4eb593808788ee151a6fccf3301de14bb170a6b9bdc439` | 780,065 |
| `test/support/guard_aggregate_reconciliation_evidence.ex` | `2ee75c2c70990314f8d8905f26d7f074f21cc506159198184a34582297b44999` | 86,734 |
| `03-05-validate-evidence.py` | `3abf579454598fd52ec7bf16db7d0fa53ded00bf183ff82086fe5f1b0d1c1567` | 61,844 |
| `03-05-T2-POST-R8-HELPER-REVISION.json` | `40641260db427327b15c6b596a8b7e55726426e628e185d4ff01eacbc40cb625` | 2,995 |
| `03-05-CORE-FOCUSED-R8-FAILURE.json` | `5965083654495bc092e7f59e9dde4a6bb5536f7e6d4e9eb43651d1c21e26f69c` | 1,676 |
| `03-05-CORE-FOCUSED-R8-RETEST-FAILURE.json` | `88ef306496528cc787ed8c9dde111ecd7d22e5653d89a9cdbd1b25f293c1d000` | 2,971 |

The R8 observed span remains bytes `[63660, 71408)`, 7,748 bytes, SHA-256 `2861e6e06895760381c8ae3bd0fa7e5d9bc126493fc1173cb4ddbeaaec147682`; its pre-edit helper identity remains `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370` / 83,805 bytes.

No tests were run during this review. No findings.
