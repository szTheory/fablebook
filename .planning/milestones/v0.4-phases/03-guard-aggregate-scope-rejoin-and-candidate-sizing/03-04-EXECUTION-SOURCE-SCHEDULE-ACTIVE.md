---
phase: 03
plan: 03-04
status: pending independent metadata review, preflight, and fresh direct count
---

# Active Plan 03-04 source and count schedule

This schedule supersedes no historical receipt. It replaces the stale
V20-era schedule only for a fresh gate attempt. No source/test body is
authorized by this document. The candidate remains null, report unpublished,
implementation unauthorized, and Plan 03-05 unstarted.

## Current binding set

All SHA-256 values bind the checkout at schedule preparation time. A mismatch
invalidates review and count.

| Input | Path | SHA-256 |
|---|---|---|
| Plan | `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-PLAN.md` | `6d567ad37b6502a638e3fcebe51601171704daf3efd6faf0fffc3bea575e51d2` |
| Replan | `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-REPLAN.md` | `91a7cb150c291f1ca68727e52cafe708f733fa92268b8655da74dbcb11c4804b` |
| Incident receipt | `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-EXECUTION-INCIDENT.md` | `0c5c79523a1a589db79aad64a09ed2a67f2cf049a15531b8485eb83a1ddfca6e` |
| SIZING | `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-SIZING.json` | `2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078` |
| Active-ledger projection | canonical compact JSON of INT-20261115-02 allocation, incident/baseline/cumulative source and output accounting, reserve, SIZING generation and current lane hashes; 1,180 bytes | `23be8ff8feebba097394f85f11db2ce57b0ce54e3a543118ad940a71d9afed84` |
| Core lane record | `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json` | `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` |
| Floor lane record | `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json` | `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` |

The active ledger is 34,000 context + 22,000 Task 1 source + 16,000 cumulative
Task 2 source + 0 Task 3 source + 5,000 cumulative output + 2,000 cushion =
79,000 working; fixed reserve 31,000; total ceiling 110,000. Task 2 begins at
2,387 measured V20 source tokens plus the conservative 10,353 unsaved incident
charge = 12,740, leaving 3,260. Output begins at 1,193, leaving 3,807. No
allocation or prior charge is reset. Active SIZING status remains
`source_emission_authorized: false`.

## Exact source selections

Task 03-04-01 is already complete. Its accepted source-span ledger remains
historical evidence in `03-REVIEW.md`; the measured 21,172 tokens are retained
under the 22,000 Task 1 cap and hash-bound by SIZING field
`measurements.task1_span_payload_sha256` =
`ef1d84f91dbe93dafb018a8567c161a9482eac7621a2bf4c1fd39d967f5a94ef`. Do not
re-emit those spans as Task 1 work. Task 2's two spans below are the only new
source-body emission proposed here. They overlap Task 1's historical archive
lookup span, so all tokens are charged again to Task 2.

Selections are complete inclusive UTF-8 line spans; digests include line
endings. Task 2 uses one exact source file, below its five-file cap.

| Task | File | Complete unit | Lines | Bytes | SHA-256 |
|---|---|---|---:|---:|---|
| 2 | `test/support/guard_aggregate_reconciliation_evidence.ex` | complete static target archive lookup | 1495–1585 | 3,127 | `1d82b5b9f235bfc047eba220aa43d4ae7912639796f29e8c1ddc27ac23d7ba90` |
| 2 | same | complete source-key indexing helper | 1586–1592 | 271 | `2a5211c5561084e32535257bb1844c1b12586c6ac699321b551f9ecd8e5fef24` |

Task 2's prior 2,387-token V20 selection and 10,353-token incident charge
remain charged. The new spans total 3,398 bytes, but only the fresh direct
token count can establish fit under the 3,260-token remaining allowance.
Machine evidence is limited to keyed projections of `03-CORE-AGGREGATE-
EVIDENCE.json`, `03-FLOOR-AGGREGATE-EVIDENCE.json`, and `03-SIZING.json`; no
full lane arrays are selected.

Task 2 source file full identity: `test/support/guard_aggregate_reconciliation_evidence.ex`,
58,768 bytes, SHA-256
`54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63`.

## Reproducible active-ledger projection

The following canonical compact JSON is the complete selected projection from
`03-SIZING.json` used for the active budget binding. Its exact bytes are 1,180
and SHA-256 is
`23be8ff8feebba097394f85f11db2ce57b0ce54e3a543118ad940a71d9afed84`.

```json
{"active_schedule_sha256":null,"authorization":"INT-20261115-02","budget":{"baseline_source_tokens":2387,"context_cap":34000,"cumulative_output_tokens":1193,"cumulative_source_tokens":12740,"cushion":2000,"hard_ceiling":110000,"incident_source_charge_tokens":10353,"output_cap":5000,"remaining_output_tokens":3807,"remaining_source_tokens":3260,"reserve":31000,"source_token_cap":16000,"task1_span_cap":22000,"task3_new_source_reads":0,"total_cap":110000,"working_cap":79000},"count_harness_sha256":null,"generation":"09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b","lane_record_sha256s":{"core":"70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd","floor":"955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d"},"measurements":{"cushion_tokens":2000,"effort_upper_working_days":3,"output_tokens":5000,"plan_count":5,"reserve_tokens":31000,"source_file_count":2,"task1_source_tokens":21172,"task1_span_payload_sha256":"ef1d84f91dbe93dafb018a8567c161a9482eac7621a2bf4c1fd39d967f5a94ef"},"sizing_projection_sha256":null,"sizing_sha256":"2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078","source_emission_authorized":false}
```

The lane projection selector is exactly the object with top-level fields
`lane`, `source_join_complete`, `candidate`, and `aggregate_gate`; each
`identity_rows` entry reduced to `identity.{id,identity_class,table,owner}`
in original row order; and the complete `source_and_caller_evidence` object.
Serialize recursively sorted object keys, compact separators, UTF-8
(`ensure_ascii=false`), no trailing newline. Core: 24,408 bytes, SHA-256
`e4dab96c07fc680d69de7eb73aab3aaaa55e7e29e3510a2975084eae38a78440`.
Floor: 23,885 bytes, SHA-256
`55b5b1bcf73f58dbfb199f75fa6f38f8c8f0217780c956f0b1552556e16d5880`.
Each lane has 226 identity rows. The complete recursive-key scan found no
target-source-specific, association, or typed-gap keys; their absence is
recorded as incomplete evidence, never as proof of coverage. The exact
identity-set selector is `identity_rows[*].identity.{id,identity_class,table,owner}`;
its ordered canonical JSON is 17,474 bytes and SHA-256
`37df141d5a40a52c129ad1517c9e627e9c39049fcff4d903547061af085b97b7` for
each lane.

The required delivery-receipt projection selects the two `phases` entries
matching `(milestone=v0.2, phase=1)` and `(milestone=v0.3, phase=2)`, then
exactly `milestone,milestone_key,phase,status,pr,reviewed_head,merge_commit,ci_run`;
serialize as canonical compact JSON with recursively sorted keys. Projection:
567 bytes, SHA-256
`aab96f0a2199a2cd1bd3a177cb4811265bd4c346fae2ea7a1f3fef95d27446f0`.

## Exact compact-context acquisition manifest

Only the listed exact ranges enter the direct context payload. For every row,
full-file SHA-256 binds the source document; excerpt SHA-256 covers the exact
inclusive UTF-8 lines including line endings. Whole-file selections use the
same file and excerpt byte counts/digests. This manifest includes current
intent, D-01–D-04, GSR-01–06, delivery/partition history, previous review
facts, active limits, and owner/safety stops without loading full lane arrays
or the large reconciliation report.

| Context input | Full bytes / SHA-256 | Exact selection | Excerpt bytes / SHA-256 |
|---|---|---|---|
| `AGENTS.md` | 6,295 / `86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7` | 1–40 | 6,295 / `86f3c829e1853ff1ba66e54f7301da9d2706e4d3a6b9353fd5d118663936e1c7` |
| `CLAUDE.md` | 3,743 / `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2` | 1–36 | 3,743 / `7acad5dda8d40002f2dd4e0cbc4ea948cca754d35da3a6ae3595e0d9c08181d2` |
| `.planning/intent/NORTH-STAR.md` | 3,559 / `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248` | 1–34 | 3,559 / `c4524bfe9655a5c79eb27a15741f268498e8060c7dd6e23ac05f1e8282f0f248` |
| `.planning/intent/CLEARANCE.md` | 2,154 / `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff` | 1–16 | 2,154 / `1e14a46de5a2af2ff90eb6bf0914bd694b9a269c633d71e69afb02abefcecfff` |
| `GLOSSARY.md` | 15,891 / `e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6` | 118–150; 261–354 | 1,389 / `71de3c4a5253fe24c58d863d316935e67cd6093f97b3c8579323f654a169f883`; 3,248 / `df439721b4874967bb5fef7a454c6b9bacbd85f4e26fe053f672d0854460982a` |
| `docs/adr/README.md` | 2,597 / `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5` | 1–32 | 2,597 / `8e425a7261eff0416e2193b553e026e0411caffc7653f56d8ee4196416a77cb5` |
| `docs/adr/0004-no-eval-no-new-atoms.md` | 1,649 / `5d9232471b38fc7e038749bbc85145e6a608b70412c9d15c50b425e442c4fb23` | 1–24 | 1,649 / `5d9232471b38fc7e038749bbc85145e6a608b70412c9d15c50b425e442c4fb23` |
| `docs/adr/0014-testing-strategy.md` | 2,323 / `42c70f5792c98c3ea8a77eb9cc7aec8c94c7d1f8b6101306bb3d8fb76cea34e4` | 1–29 | 2,323 / `42c70f5792c98c3ea8a77eb9cc7aec8c94c7d1f8b6101306bb3d8fb76cea34e4` |
| `docs/adr/0018-dependency-budget.md` | 3,066 / `3ca266284f17d26ee5f2044d00ffa4b7e8d60336fe6e1d3191aa393927ad46cf` | 1–29 | 3,066 / `3ca266284f17d26ee5f2044d00ffa4b7e8d60336fe6e1d3191aa393927ad46cf` |
| `docs/adr/0021-delivery-rules.md` | 3,072 / `2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56` | 1–34 | 3,072 / `2074bc6920a6bc36cd4e295a5649a2b82036f37899cb3fa9d26fa69441582a56` |
| `.planning/VERIFICATION.md` | 5,352 / `0295edd62cb7b6351075b8ace1ddfa1203ab18fe175b757950cc1caa5b048e66` | 1–7 | 962 / `f65dab37813d753c9474b46d8041feb6e9077b31802f96309c7616734f29b629` |
| `.planning/REQUIREMENTS.md` | 3,954 / `74ede0ad048f06d31bda9800946aa98b64e39e8b45e8625415e9d0c7c75c512e` | 9–26 | 2,978 / `5f7a40479b1729f80cca20c065ff85097b5c36e52db80f8fb2f32c22448128bf` |
| `.planning/ROADMAP.md` | 2,986 / `b4d9ac03da1141b66b65d57540be1980e9ffe28d9f9e44b0de6cae3af11e681b` | 16–23 | 666 / `1fcd9c5340d4c77d37b5fe381081c1e9a97005f15b2ad9f7b88b9844acaac482` |
| `.planning/STATE.md` | 19,910 / `88a2c4a760282dd185b721af4cf88c2f894f2990f34b15c83a984636a5f22fb5` | 34–54; 157–193 | 4,435 / `36cb398ff0c1645fb57762a057e272862b3ada09abfb668e1ef498f96c18f997`; 4,565 / `a6a5e14f0e6cdf6f66beb3d54293a650fe585bed9590ae88a30281ccf423219b` |
| `.planning/intent/sources/2026-11-15-01-trace-target-source-coverage.md` | 717 / `1cca0d01eaa888eda315db831de2f10b676d35e5340e15810e7ae4aa170a4d99` | 1–13 | 717 / `1cca0d01eaa888eda315db831de2f10b676d35e5340e15810e7ae4aa170a4d99` |
| `.planning/intent/sources/2026-11-15-02-authorize-phase3-recovery-envelope.md` | 1,381 / `4eed1d66f2fa9830c8fe1877bddf95c5d9aab2d7ade5b8ad0891699d5b1681a4` | 1–16 | 1,381 / `4eed1d66f2fa9830c8fe1877bddf95c5d9aab2d7ade5b8ad0891699d5b1681a4` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CONTEXT.md` | 10,916 / `a2a66a691e9026d3e97821a82aafa14c63460137912813b27f7018677cbef22b` | 8–28 | 2,924 / `d7982df35142c233b2fb981afa6b615d33c7340d945fd80379d4f9e7e8048968` |
| `.planning/milestones/v0.3-phases/02-bounded-asn-1-rtt-guard-evidence/02-CONTEXT.md` | 14,424 / `d769dfd143534ba5272f88a140f261462a020dc348c305e399dde624af7b9c78` | 11–25; 46–50 | 1,984 / `0007c18e442561b090e40b60779dfcf3eb2c64032436cd6108dcf10f3f00a296`; 1,107 / `4a18c59ce59dae4fcdf08fae01eac3412b743b3e9f95da4289a57a3f9da1abd7` |
| `.planning/references/PLANNING-GATES.json` | 503 / `ca2fc6d23ad474dad7d72688fee03a71dfff38e4d8e4d3237e1ecef0bec1271b` | 1–22 | 503 / same |
| `.planning/references/PHASE-DELIVERIES.json` | 779 / `16d5e37be6579c9ed78b3418ec31c2e541a916c1d5eddef3a7fb4e0531bce088` | two entries selected by `(milestone=v0.2,phase=1)` and `(milestone=v0.3,phase=2)`; each reduced to `milestone,milestone_key,phase,status,pr,reviewed_head,merge_commit,ci_run` | 567 / `aab96f0a2199a2cd1bd3a177cb4811265bd4c346fae2ea7a1f3fef95d27446f0` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-PLAN.md` | 25,522 / `6d567ad37b6502a638e3fcebe51601171704daf3efd6faf0fffc3bea575e51d2` | 1–147 | 22,960 / `b5dc82203f728460fb8a767de594916c36f1811ea5fe8c5c731eb1035713e3cf` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-REPLAN.md` | 44,517 / `91a7cb150c291f1ca68727e52cafe708f733fa92268b8655da74dbcb11c4804b` | 562–616; 630–653 | 3,641 / `aeb44c994ba7467cef1ef1da80a1cf3fc05cd4d462ba1b992e824e32e118f21f`; 1,545 / `426dad5516e5a07cc464ddd65baae55be303e2d3ff860abb80a9e633714d1993` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-EXECUTION-INCIDENT.md` | 2,194 / `0c5c79523a1a589db79aad64a09ed2a67f2cf049a15531b8485eb83a1ddfca6e` | 1–22 | 2,194 / same |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-04-BUDGET-REVIEW.md` | 1,966 / `e373d62732a62317284cad1a209c50f1a5e66fd598fa53eaa0ee71f4b1def66e` | 1–15 | 1,966 / same |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-REVIEW.md` | 54,645 / `800f366aa2c5628e7634f4648e4084c86e50710ad64efbb53c97a0f4e7467ff9` | Task 1 material finding and accepted-span context 329–369; latest V20 blocker 803–825 | 2,645 / `ebdda7e417e040bab679de35c5888296afa5c2796fffdd7c35b26aba2e750f35`; 3,068 / `f5d228a4d96ddf905546276cdb14774a21e7589a0cd4c2ac20aeefb5278ccd0d` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-SIZING.json` | 35,319 / `2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078` | exact active-ledger projection above; keyed current lane/identity projections below | active-ledger 1,180 / `23be8ff8feebba097394f85f11db2ce57b0ce54e3a543118ad940a71d9afed84` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json` | 1,418,156 / `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` | selector and canonicalization above; complete recursive scan separately finds no target-source, association, or typed-gap key | 24,408 / `e4dab96c07fc680d69de7eb73aab3aaaa55e7e29e3510a2975084eae38a78440` |
| `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json` | 1,390,810 / `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` | selector and canonicalization above; complete recursive scan separately finds no target-source, association, or typed-gap key | 23,885 / `55b5b1bcf73f58dbfb199f75fa6f38f8c8f0217780c956f0b1552556e16d5880` |

Before any source-body emission: (1) independently validate this schedule and
all listed digests/budget arithmetic as metadata only; (2) run
`bin/planning_health --stage execute --phase 3`; (3) rebuild and SHA-256-check
the exact context and keyed projections above; (4) include the final schedule
and its independent metadata review receipt in the count payload; (5) count
context, all Task 1 spans, the 12,740 charged Task 2 history plus both new
spans (including the Task 1 overlap as a Task 2 reread), remaining output
allowance, cushion, and reserve directly against the 110,000 ceiling. Use the
approved no-cost input-token-count endpoint only if no local tokenizer is
available. Any digest, identity-set, cap, count, or ceiling mismatch keeps the
body gate closed. The schedule review is metadata-only and does not count as
code/security review or clear any implementation finding.
