---
phase: 03
plan: 03-02
task: 03-02-01
date: 2026-11-14
status: reviewed-pass
---

# Plan 03-02 Task 1 source schedule

This is a count-only source schedule. No source body was emitted to the executor,
reviewer, or parent. The first measured proposal was 11,840 tokens and exceeded
the 11,000-token task cap; it was narrowed before any semantic source read.

## Exact spans

Each span is a complete selected definition or tagged test block, with its start
and end boundary included. The schedule uses three exact source files, within the
task's five-file limit.

| Path and line range | Bytes | Lines | SHA-256 |
|---|---:|---:|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex:16–206` | 7,937 | 191 | `aba901899dab769b4f29e4af4f7672e585506dfac3210eb180af0cfdf25af86e` |
| `test/support/guard_aggregate_reconciliation_evidence.ex:294–359` | 2,459 | 66 | `c7ad54204d917ade323d78ede3225332c84a93fee96b78b216e086088fc62bc4` |
| `test/support/guard_aggregate_reconciliation_evidence.ex:399–469` | 2,572 | 71 | `52317abf64af6f6cebc1490500f941142cfad65bf564b927a3a3fb9409a7c6d4` |
| `test/contract/tier_sweep_test.exs:5087–5141` | 1,903 | 55 | `2b50eb745f4423ae1cdcdcebeef744767c9aea1ae9213547b813e7406208df7e` |
| `test/contract/tier_sweep_test.exs:5542–5648` | 3,552 | 107 | `81ad5c01b68128e243d704e29eacfb22c624ab58fb0c123c0d9e066db656513e` |
| `test/support/sweep_evidence.ex:274–304` | 1,025 | 31 | `553a0d04fe00cc4399f4d6c62ad596f1954291ad2639091bf4173dbf5b61f27a` |
| `test/support/sweep_evidence.ex:328–348` | 704 | 21 | `c8364e5fe31449770a2c4e41df40dd5c8e08fee02a3dea19151c92ff07e85768` |
| `test/support/sweep_evidence.ex:584–699` | 3,492 | 116 | `50994cde8d0376b33b7f8d1f80fd825a1cd6eb7da460a207d50ead4deeda903b` |

## Count-only fit

The free `POST /v1/responses/input_tokens` endpoint measured **50,765 tokens**
for the 19 selected execution documents and these exact source spans together.
The source spans alone measured **6,253 tokens**, under the Task 1 limit of
11,000. The endpoint used the existing owner-only credential; no key was created,
rotated, changed, or printed, and no other endpoint was called.

| Remaining allocation | Tokens |
|---|---:|
| Task 1 source remainder | 4,747 |
| Task 2 source allowance | 6,000 |
| Output allowance | 5,000 |
| Post-count schedule/receipt/framing cushion | 2,000 |
| **Working projection** | **68,512 / 69,000** |
| Fixed reserve | 31,000 |
| **Total projection** | **99,512 / 100,000** |
| **Slack** | **488** |

The 44,499-token document-only count is older than this combined measurement.
The current exact source payload is still subject to an independent schedule
review. After review, run execute preflight and make a fresh direct combined
count before emitting any source body. Include later schedule/receipt text in
the current-document count or charge it to the remaining cushion. Task 2 requires
its own exact schedule, fit measurement, execute preflight, and review.

## Scope and stops

This schedule performs no implementation, tests, archive expansion, source
evaluation, candidate selection, or authority change. Static-only collection,
the actual-library-collision owner stop, Macro checkpoints, `candidate=null`,
`implementation_authorized=false`, `aggregate_gate=open`, unresolved source/caller
gaps, Walking Skeleton blocked, and SEC-01 Pending remain binding.

## Independent review and integrity check

An independent plan reviewer returned **PASS** on 2026-11-14 without reading
source bodies or credentials. It confirmed the eight metadata-only ranges are
within the three-file and 11,000-token task limits, the count arithmetic totals
68,512/69,000 working and 99,512/100,000 overall, and the evidence and safety
scope is unchanged. A separate local metadata check recomputed every range's
byte count, line count, and SHA-256; all eight matched. The schedule does not
authorize a body read by itself: execute preflight and a fresh direct combined
count remain required immediately before emission.

## Plan 03-02 Task 2 source schedule — review pending

Task 1's focused lane records and source-gap crosswalk passed the keyed integrity
checks. Execute preflight passed again before this count. No Task 2 source body
has been emitted.

| Path and line range | Bytes | Lines | SHA-256 |
|---|---:|---:|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex:294–505` | 7,204 | 212 | `28608f0bf39f8355613c36045a3e597af2d6f1ce92441c7fa6174d2aa941b486` |
| `test/contract/tier_sweep_test.exs:5087–5091` | 72 | 5 | `b817a8391ac1efec3cffde4810af75b7e113a3609e9bf0227c2ba6e2995ddd02` |
| `test/contract/tier_sweep_test.exs:5660–5863` | 6,643 | 204 | `55b6f8a5ad470b92a760eaf1be1a3e6224f328457532b3b45e10e8e2f59e4685` |
| `test/support/installed_otp.ex:146–205` | 1,844 | 60 | `7bb502583371cb8cc11b74185869edf41b9a09ce62d2f9690c07c7958ec45827` |
| `test/support/installed_otp.ex:221–279` | 2,127 | 59 | `5bdacf95e6143692973e663b5a7fb3f54453bc8b40339337dc103d5a9872268a` |
| `test/support/installed_otp.ex:1007–1080` | 1,857 | 74 | `0984041fed6a089f7271436a23813430d4b19f0e10e09ee105685cfcfcab097a` |

The schedule uses three exact source files, within Task 2's five-file limit. Its
4,892-token source-only count is below the 6,000-token Task 2 cap. It contains
the collector's target-source and crosswalk contracts, graph setup and the
caller-index test, plus InstalledOtp's discovery, source-inventory, export and
source-mapping contracts. It schedules no target or caller implementation body;
existing hash-scoped findings remain linked, and unknown paths remain gaps.

The fresh direct `gpt-6-luna` count returned 59,391 tokens for the 20 selected
documents (including this schedule), previously emitted Task 1 source context,
the exact Task 2 spans, and selected keyed lane evidence only. The 4,892 exact
Task 2 tokens are already included. With the remaining Task 2 source allowance,
output and cushion:

`59,391 + 1,108 + 5,000 + 2,000 = 67,499 / 69,000 working tokens`

`67,499 + 31,000 = 98,499 / 100,000 total tokens`; slack is 1,501 tokens.
Task 1 consumed 6,253 source tokens; Task 2's maximum adds 6,000, for a plan
total of 12,253 / 17,000 source tokens.

This remains count-only and does not authorize a Task 2 body read. Independent
review and a fresh execute preflight/count after review are required before
emission. Static-only collection, explicit unknowns, `candidate=null`,
`implementation_authorized=false`, `aggregate_gate=open`, Walking Skeleton
blocked, and SEC-01 Pending remain binding.
