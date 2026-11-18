---
phase: 03
plan: 03-04
status: recount passed and two spans emitted once; stale after bounded-stop STATE update
---

# Plan 03-04 current-state recount schedule

> This schedule's independent review, execute preflight, and direct count passed;
> its two scheduled spans were emitted once. The subsequent bounded-stop STATE
> update makes it stale for any further source access. See
> `03-04-BOUNDED-TRACE-STOP.md`; no further source emission is authorized.

This schedule rebinds the already-reviewed compact source selection to the
current STATE and the post-count Task 2 ledger. It authorizes only a fresh
count of the same two exact spans and, if every gate passes, their single
bounded source-emission batch. It does not authorize any other source reads,
code edit, test, report publication, candidate promotion, or Plan 03-05 work.

## Immutable inputs and bindings

| Input | SHA-256 |
|---|---|
| Current `.planning/STATE.md` | `003a4c427b0ecadc92cba612b862df0ba5bf908748961cdbb9f5171c13d65def` |
| Compact schedule | `2843c9d29fc3e1b6a86727c905939213f3ac28b679ca75a5a5d499e80ebff478` |
| Prior independent compact-schedule review receipt | `53e06a047e2d5bc4e4e5e7964f6f69c67a3e4ac75dee98bf91d28dfa25f98307` |
| Prior fresh direct-count receipt | `6f536ce2c552b470d3497164f641e19f354d034ad858f8b556a1b2ede1405442` |
| Plan `03-04-PLAN.md` | `6d567ad37b6502a638e3fcebe51601171704daf3efd6faf0fffc3bea575e51d2` |
| Replan `03-04-REPLAN.md` | `91a7cb150c291f1ca68727e52cafe708f733fa92268b8655da74dbcb11c4804b` |
| Incident receipt | `0c5c79523a1a589db79aad64a09ed2a67f2cf049a15531b8485eb83a1ddfca6e` |
| SIZING snapshot | `2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078` |
| Core evidence full record | `70930cb58c7f1d396fd589e8d7bb797a804dac417d18e15fc067e9e128c771fd` |
| Floor evidence full record | `955191252b9f3ef48ca5050fc4919725ac317a69980fda6e20d9ad7537f2df9d` |
| Prior Task 2 gate-stop receipt / exact IDs | `a346d6edd4610b91cbd09033f980eaee4512f8e065bc864a91429f71cc4eda7a` |
| Task 2 source file | `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63` |
| Delivered phase receipts source | `16d5e37be6579c9ed78b3418ec31c2e541a916c1d5eddef3a7fb4e0531bce088` |

The schedule and review receipts bind the complete static-only policy and
acceptance constraints, all 226 identity IDs, the complete keyed core/floor
source-and-caller projections, the delivery-receipt projection and all
existing safety stops. The prior count receipt is retained as history; its
count cannot be reused because STATE and the active ledger changed afterward.

## Current ledger

The exact active ledger is recursively sorted canonical JSON, UTF-8, compact
separators, no trailing newline: 986 bytes, SHA-256
`1aad5c036cb1650e1bac3b3017b38391963c8248bd29be3bdae203fc896ef293`.

```json
{"authorization":"INT-20261115-02","current_task2_source":{"charged_tokens":14465,"latest_prior_selection_sha256":"6f536ce2c552b470d3497164f641e19f354d034ad858f8b556a1b2ede1405442","latest_prior_selection_tokens":843,"remaining_tokens":1535,"source_cap":16000},"fresh_source_count_required":true,"limits":{"context":34000,"cushion":2000,"output":5000,"reserve":31000,"task1_source":22000,"task2_source":16000,"task3_new_source":0,"total":110000,"working":79000},"prior_sizing_snapshot":{"candidate":null,"generation":"09f46024e419d4fe81c273befabe0019ab953e5a6f8c4dd1c01c114df184709b","implementation_authorized":false,"output_remaining_tokens":3807,"output_used_tokens":1193,"prior_incident_charge_tokens":10353,"prior_task2_source_tokens":12740,"prior_v20_baseline_tokens":2387,"sizing_sha256":"2e758b1968d8bb100c7f32a0d7eed5fbb4b8bf40881e01b015cf8db12a220078","task1_source_tokens":21172,"task1_span_payload_sha256":"ef1d84f91dbe93dafb018a8567c161a9482eac7621a2bf4c1fd39d967f5a94ef"}}
```

Task 2 is currently 14,465/16,000, leaving 1,535. This fresh source-span
selection is charged once to the remaining amount even though it repeats the
same spans from the prior count. If it passes and they are emitted immediately
in the single authorized batch, do not reselect or reread them. Any additional
span, reread, or correction selection must fit within the then-current
remainder; stop if it cannot.

The fixed ceiling remains 110,000: context 34,000; Task 1 source 22,000;
cumulative Task 2 source 16,000; Task 3 new reads 0; cumulative output 5,000;
cushion 2,000; reserve 31,000. Task 1 remains 21,172. Output remains 1,193
used/3,807 remaining. Do not increase the ceiling or any sub-cap.

## Exact source selection

Only these previously scheduled inclusive source ranges may be selected:

| File / function | Lines | Bytes | SHA-256 |
|---|---:|---:|---|
| `test/support/guard_aggregate_reconciliation_evidence.ex::target_source!/5` | 1495–1585 | 3,127 | `1d82b5b9f235bfc047eba220aa43d4ae7912639796f29e8c1ddc27ac23d7ba90` |
| same file `source_key_index!/2` | 1586–1592 | 271 | `2a5211c5561084e32535257bb1844c1b12586c6ac699321b551f9ecd8e5fef24` |

The complete 226-ID set and both complete lane projections remain required
context; counts or examples cannot replace them. No source emission is allowed
until this exact schedule passes independent metadata review, fresh execute
preflight, and a new direct count.

## Recount construction and stop rules

1. Obtain a fresh independent metadata-only review of this exact file/hash.
2. Run `bin/planning_health --stage execute --phase 3` after review.
3. Rebuild the exact context by joining with two LF characters, in order:
   this complete schedule; the complete compact schedule; its independent
   review receipt; the preceding count receipt; the current complete STATE;
   the prior gate-stop receipt; the canonical 226 sorted IDs; the complete
   canonical core projection; the complete canonical floor projection; this
   active ledger; and the canonical delivered-receipt projection. Projection
   definitions and expected hashes are in the compact schedule and prior
   count receipt. Recompute every binding before counting.
4. Count compact context, the two selected spans (joined by one LF), and the
   exact combined payload using only the approved no-cost
   `POST /v1/responses/input_tokens` endpoint. Do not use a generation
   endpoint; keep the ignored local credential in process memory only.
5. Pass context ≤34,000, cumulative Task 2 ≤16,000 after charging the fresh
   span selection, Task 3 reads =0, output ≤5,000, and total ≤110,000 using
   the full 5,000 output allowance, 2,000 cushion and 31,000 reserve. If any
   binding/count/cap fails, stop before source emission and record the exact
   blocker. On pass, emit only these exact two spans once as a bounded batch.

After that batch, run the Plan's cheap JSON/digest/coverage-gap consistency
checks before any longer selectors or tests. Do not change code or publish
unless a complete narrow evidence defect is demonstrated and its separate
fresh fix/retest gates pass. Candidate remains null; report remains
unpublished; implementation remains unauthorized; Plan 03-05 remains
unstarted; all static-only, collision, Macro, authority and aggregate stops
remain binding. This schedule authorizes no update to STATE or selected inputs
before the source batch unless a new count stop occurs.
