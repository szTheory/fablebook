# Core OTP root metadata check

**Date:** 2026-11-20
**Purpose:** Estimate the possible input size for a safe Phase 7 inventory route without opening source or compiled-file contents.

## Result

The pinned Erlang/OTP 29.1.2 installation resolves to `~/.asdf/installs/erlang/29.1.2/lib`. A metadata-only directory walk and file `lstat` found:

| File type | Count | Total bytes |
|---|---:|---:|
| `.erl` source | 1,359 | 46,899,653 |
| `.hrl` include | 195 | 2,796,257 |
| `.beam` compiled module | 1,356 | 52,328,492 |
| `.app` application metadata | 35 | 60,401 |

No symlinks were present under the inspected root. The active Phase 7 source-observation plan allows at most 25 exact target files. Reading the whole OTP source tree would exceed that limit by a wide margin. This count is an upper bound for a whole-tree approach, not the exact file list a complete relevant inventory would need.

The machine-readable path/size listing is [07-CORE-OTP-ROOT-METADATA.jsonl](07-CORE-OTP-ROOT-METADATA.jsonl), SHA-256 `38c0b6f896ecac55e5938d8d296af92dc2c5d65b97179c7d7bbaaa01e6e2c91a`. That digest covers only the generated path/type/size manifest, not OTP file contents. No source content was read or hashed.

## Limits and next step

This metadata pass does not establish current membership or source identity. The historical Phase 3 core aggregate has 226 identity rows and 312 distinct module names across its recorded MFA fields, but it is bound to an older lane identity and is comparison context only. The exact current source subset is not established.

The existing `BeamWalker` is not a source-free shortcut: it reads the BEAM `debug_info` chunk and reconstructs source forms. Do not use it for a metadata-only task. Any different compiled-metadata approach must name its exact chunks and operations, prove it produces the complete relevant membership and lane identities, and stay within the approved read and task limits before it can be considered.

No source body or BEAM content was read. No helper, test, build, compile, or target function was run. No archived file was changed. The current Phase 7 plan still prohibits source reads in Plan 07-01 Task 2; revise and independently review the plan before any new operation.
