---
phase: 07-guard-scope-reconciliation
plan: 05
subsystem: bounded-source-observations
status: complete
requirements: [RSC-01, RSC-02, RSC-03, RSC-04]
---

# Plan 07-05: Security-patched core rebaseline

The authorized LiveView security update is recorded in [INT-20261120-07](../../../intent/sources/2026-11-20-07-authorize-phase7-security-rebaseline.md). The core lock now pins `phoenix_live_view` 1.2.14, with no other package tuple changed. `mix.exs` and the floor lock are unchanged. The local Hex audit passed.

The versioned inventory binds the full current lock and the reviewed BEAM manifest. It contains 2,061 BEAM files and 54,763 exports. All 226 saved core rows and 1,763 saved MFAs are present; no non-LiveView identity changed. All seven proposed family MFAs remain, with a 1,756-MFA complement. The independently reviewed core source schedule preserves all five consumed request IDs and issues or reuses none. It carries forward the prior Plug observation only; four source gaps remain, including the LiveView no-retry gap under the patched package identity. No target source body was read for this generation.

The full CI run exposed that the existing test contract normalized only the historical Plug overlay when reconstructing its immutable archived core lock. The contract now also normalizes the exact authorized LiveView 1.2.13-to-1.2.14 version/checksum change. The archived lock digest and floor lock expectation remain unchanged, and the contract rejects an unexpected LiveView version.

## Verification

- Dependency patch checker: passed; only the LiveView lock tuple changed.
- Current reconciliation validator: passed; exact saved-row and family/complement partition retained, all five historical request IDs remain closed.
- Focused lock-identity contract: 5 passed.
- `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci`: passed, 461 tests; 10 tagged tests excluded by the lane configuration.
- `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=dev bin/lane core mix hex.audit`: passed with no retired or security-advisory packages.
- `git diff --check`: passed.

## Preserved limits and stops

No guard or product implementation was added; no candidate was promoted. The aggregate gate remains open, actual-library collision remains unknown, R9 remains denied and unconsumed, SEC-01 remains Pending, Macro caller-AST and explanation gaps remain unresolved, the legacy digest remains unresolved, and Walking Skeleton remains blocked. The five consumed source request IDs remain closed. The prior LiveView request was not retried, no source reads were added, and no automatic follow-up was authorized.
