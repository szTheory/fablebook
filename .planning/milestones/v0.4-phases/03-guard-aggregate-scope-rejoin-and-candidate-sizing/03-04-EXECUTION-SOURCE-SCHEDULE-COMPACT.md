---
phase: 03
plan: 03-04
status: pending fresh independent review, execute preflight, and direct count
---

# Plan 03-04 compact active source/count schedule

This replaces only the failed count context package; it does not reuse its
count or schedule-review result. It is planning metadata only. No source/test
body read, patch, test, report write, authorization change, or Plan 03-05 work
is included here.

## Hash bindings

All hashes bind this checkout at schedule creation. Any mismatch invalidates
review and count.

| Input | Bytes | SHA-256 |
|---|---:|---|
| `03-04-PLAN.md` | 25,522 | `6d567ad37b6502a638e3fcebe51601171704daf3efd6faf0fffc3bea575e51d2` |
| `03-04-REPLAN.md` | 44,517 | `91a7cb150c291f1ca68727e52cafe708f733fa92268b8655da74dbcb11c4804b` |
| `03-04-EXECUTION-INCIDENT.md` | 2,194 | `0c5c79523a1a589db79aad64a09ed2a67f2cf049a15531b8485eb83a1ddfca6e` |
| `03-SIZING.json` | 35,319 | `2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078` |
| `03-CORE-AGGREGATE-EVIDENCE.json` | 1,418,156 | `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` |
| `03-FLOOR-AGGREGATE-EVIDENCE.json` | 1,390,810 | `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` |
| Prior count stop / affected IDs | 5,862 | `a346d6edd4610b91cbd09033f980eaee4512f8e065bc864a91429f71cc4eda7a` |
| Task 2 source file | 58,768 | `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63` |
| Current STATE | 20,018 | `6d8b1dd062f9a26447cebd29068714f6e703e5e604ca6b1a407c5e35d4c23fa4` |

Policy/provenance source binding set: `AGENTS.md`
`86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7`;
`CLAUDE.md` `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2`;
NORTH-STAR `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248`;
CLEARANCE `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff`;
GLOSSARY `e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6`;
ADR index `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5`;
ADR 0004 `5d9232471b38fc7e038749bbc85145e6a608b70412c9d15c50b425e442c4fb23`;
ADR 0014 `42c70f5792c98c3ea8a77eb9cc7aec8c94c7d1f8b6101306bb3d8fb76cea34e4`;
ADR 0018 `3ca266284f17d26ee5f2044d00ffa4b7e8d60336fe6e1d3191aa393927ad46cf`;
ADR 0021 `2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56`;
REQUIREMENTS `74ede0ad048f06d31bda9800946aa98b64e39e8b45e8625415e9d0c7c75c512e`;
ROADMAP `b4d9ac03da1141b66b65d57540be1980e9ffe28d9f9e44b0de6cae3af11e681b`;
03-CONTEXT `a2a66a691e9026d3e97821a82aafa14c63460137912813b27f7018677cbef22b`;
02-CONTEXT `d769dfd143534ba5272f88a140f261462a020dc348c305e399dde624af7b9c78`;
INT-20261115-01 `1cca0d01eaa888eda315db831de2f10b676d35e5340e15810e7ae4aa170a4d99`;
INT-20261115-02 `4eed1d66f2fa9830c8fe1877bddf95c5d9aab2d7ade5b8ad0891699d5b1681a4`.
The compact summary below retains their applicable constraints and decisions;
the complete current machine evidence and 226-ID set are included separately.

## Compact required context

Phase 3 remains static evidence only. D-01–D-04 and GSR-01–06 require complete
original identity coverage, exact two-lane ownership/partitions/receipts,
source and caller provenance with typed gaps, honest fit/recommendation gates,
and preserved later owner authority. The current lane records bind all 226
identity rows and complete existing source/caller evidence; both have
`source_join_complete=false`. Neither lane record contains a
target-source-specific, association, or typed-gap key. SIZING has
`evidence_complete=false`, `candidate=null`, and global gap
`target_source_and_caller_evidence_incomplete`. This absence does not prove
which identities are missing provenance; the complete source trace remains
unperformed.

Task 03-04-01 is already complete: its accepted source span ledger is 21,172
tokens under the 22,000 cap. Do not rerun it. Task 03-04-02 is the only
authorized continuation: trace the false target-source completeness from the
current bundle records through static acquisition, reconcile every affected
identity/association/gap/input-source key, and correct only a demonstrated
narrow evidence defect. Preserve the complete validator, source identities,
provenance, gaps and ADR 0021 separation. A proven fix requires valid RED then
GREEN controls, refreshed core/floor/SIZING identities, and exact fit/source/
gap revalidation; never weaken validation or fabricate provenance. If the full
cause cannot be established within the remaining caps, record exact missing
identities and provenance, consequence, and bounded remedy for the owner and
stop. Missing evidence is a stop that leaves Plan03-04 incomplete and
Plan03-05 unstarted. Task03-04-03 has zero new source reads and cannot publish
unless corrected evidence and review gates pass. The phase effort ceiling
remains 3–4 hours total; reconcile recorded intervals and do not extend it.
Independent code review remains capped at two passes. On a bounded-gap exit,
do not publish, push, or represent the phase as complete.

Safety and authority stops: do not invoke audited OTP targets/callbacks,
atom sinks, runtime eval, generated code, or dynamic behavior as evidence; do
not weaken completeness, identity, provenance, collision, Macro caller-AST,
wording, aggregate, or fit gates; stop for an actual-library collision at any
severity; `implementation_authorized=false`; `candidate=null`;
`aggregate_gate=open`; Walking Skeleton blocked; SEC-01 Pending. No production,
workflow, dependency, original receipt, immutable archive, intent, or
requirements change is in scope. The corrected report remains unpublished;
Plan 03-05 remains unstarted. Recommendation is not authorization.

## Active ledger and exact selection

The prior count stop charged 882 Task 2 source tokens. Current cumulative
source is 13,622/16,000; 2,378 remain. Task 1 is 21,172/22,000; Task 3 new
source reads are zero. Output is 1,193/5,000 used, 3,807 remains; cushion is
2,000; fixed reserve is 31,000. Context cap is 34,000. The Phase 3 total
ceiling is 110,000. No escalation is permitted.

The following is the exact compact active-ledger projection, canonical JSON,
UTF-8, recursively sorted keys, compact separators, no trailing newline. It
combines the unchanged SIZING snapshot with the charged prior count stop.
SHA-256 and byte length must reproduce before review/count: 979 bytes,
SHA-256 `d5d9d0570d474d9ca7b9e01970b13799e88c64fb8aaa3437b97c1e6ff9fb4199`.

```json
{"authorization":"INT-20261115-02","current_task2_source":{"charged_tokens":13622,"latest_count_stop_sha256":"a346d6edd4610b91cbd09033f980eaee4512f8e065bc864a91429f71cc4eda7a","latest_new_selection_tokens":882,"remaining_tokens":2378,"source_cap":16000},"fresh_source_count_required":true,"limits":{"context":34000,"cushion":2000,"output":5000,"reserve":31000,"task1_source":22000,"task2_source":16000,"task3_new_source":0,"total":110000,"working":79000},"prior_sizing_snapshot":{"candidate":null,"generation":"09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b","implementation_authorized":false,"output_remaining_tokens":3807,"output_used_tokens":1193,"prior_incident_charge_tokens":10353,"prior_task2_source_tokens":12740,"prior_v20_baseline_tokens":2387,"sizing_sha256":"2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078","task1_source_tokens":21172,"task1_span_payload_sha256":"ef1d84f91dbe93dafb018a8567c161a9482eac7621a2bf4c1fd39d967f5a94ef"}}
```

The fresh count payload must include the complete current compact context,
this complete schedule, the new independent review receipt, the 226 sorted
identity IDs selected from `03-04-TASK2-GATE-STOP.md` (2,060 bytes,
SHA-256 `4277d546a212f99f36b9a3b113d80902e71b4bff5e4f89cd0c6429fda4017d67`),
both complete keyed lane projections, the active ledger above, and the
canonical delivered-receipt projection (567 bytes,
`aab96f0a2199a2cd1bd3a177cb4811265bd4c346fae2ea7a1f3fef95d27446f0`).

Lane projection selector: `lane`, `source_join_complete`, `candidate`,
`aggregate_gate`; every `identity_rows[*]` reduced to
`identity.{id,identity_class,table,owner}` in original order; complete
`source_and_caller_evidence`. Canonical JSON uses recursively sorted object
keys, compact separators and `ensure_ascii=false`. Core is 24,408 bytes,
SHA-256 `e4dab96c07fc680d69de7eb73aab3aaaa55e7e29e3510a2975084eae38a78440`;
floor is 23,885 bytes, SHA-256
`55b5b1bcf73f58dbfb199f75fa6f38f8c8f0217780c956f0b1552556e16d5880`. These
are complete identity/source/caller projections, not samples. The recorded
recursive-key scan separately confirms no target-source, association, or
typed-gap key.

| New Task 2 source span | Lines | Bytes | SHA-256 |
|---|---:|---:|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex::target_source!/5` | 1495–1585 | 3,127 | `1d82b5b9f235bfc047eba220aa43d4ae7912639796f29e8c1ddc27ac23d7ba90` |
| same file `source_key_index!/2` | 1586–1592 | 271 | `2a5211c5561084e32535257bb1844c1b12586c6ac699321b551f9ecd8e5fef24` |

These spans overlap Task 1's historical lookup span and every new selection
must be charged again. A new count of the two spans is required; the previous
882-token result is history only. After the new selection charge, Task 2 must
remain at or below 16,000 and retain at least the true remaining budget for
any further rereads. No source-body emission occurs during this replan.

## Required gate sequence

1. Independent typed metadata review of this exact schedule and all hashes.
2. Fresh `bin/planning_health --stage execute --phase 3` after review.
3. Rebuild the exact payload above and verify hashes before counting.
4. Use only the approved no-cost `POST /v1/responses/input_tokens` endpoint if
   no local tokenizer is available. Count compact context, fresh source
   spans, and their combined payload. Include charged Task 1/Task 2 history,
   full remaining output allowance, cushion and reserve in the total check.
5. Pass context ≤34,000, Task 2 cumulative source ≤16,000, Task 3 reads=0,
   output ≤5,000, and total ≤110,000. Any mismatch stops before source-body
   emission. No tests, report publication, candidate promotion, or Plan 03-05
   work is authorized by this schedule.
