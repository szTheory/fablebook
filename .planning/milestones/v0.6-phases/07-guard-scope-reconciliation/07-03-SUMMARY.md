---
phase: 07-guard-scope-reconciliation
plan: 03
subsystem: bounded-source-observations
status: complete
requirements: [RSC-03]
---

# Plan 07-03: Bounded source observations

The two populated batches each contain five approved requests. Across ten scheduled files, four parsed successfully, three had parser failures with captured hashes, one parser failure stopped without a hash, and two requests from an interrupted batch stopped without durable output. Seven files have captured hashes (218,450 bytes); three no-retry gaps account for 56,581 scheduled bytes without a captured hash. No consumed request was reopened.

The parser failure and interrupted-batch gaps remain distinct: core-source-01 stopped on an unbalanced delimiter; core-source-02 lost its in-memory row before durable output; core-source-03 hit a mismatch between an Elixir-prefixed lookup key and the parser's normalized key. The exact STOP files, one-use markers and read-time reviews are preserved. The parser and lookup defects were corrected for unused requests only.

Observed definitions and same-file references are bounded to each exact scheduled file. They do not establish exhaustive or package-wide caller closure. Dynamic dispatch, external callers, callbacks, aliases/imports, macros and unsupported syntax remain gaps where applicable. No runtime API, generated code, broad caller search or R9 use occurred.

## Verification

Both populated batches and all three empty batches pass the final validator. Synthetic parser checks cover 10 Elixir and 5 Erlang cases, including the regressions found during this run.
