# Plan 03-04 compact-context direct count receipt

## Gate bindings

- Schedule: `03-04-EXECUTION-SOURCE-SCHEDULE-COMPACT.md`, SHA-256 `2843c9d29fc3e1b6a86727c905939213f3ac28b679ca75a5a5d499e80ebff478`.
- Independent metadata review: `03-04-COMPACT-SCHEDULE-REVIEW-RECEIPT.md`, SHA-256 `53e06a047e2d5bc4e4e5e7964f6f69c67a3e4ac75dee98bf91d28dfa25f98307`, PASS.
- Fresh execute preflight after review: `bin/planning_health --stage execute --phase 3` → `{"errors":[],"stage":"execute","milestone":"v0.4","phase":"3","route_phase":"03"}`.
- Count method: approved no-cost `POST https://api.openai.com/v1/responses/input_tokens`, model `gpt-6-luna`. No generation endpoint was called. Credential was read from the existing ignored `.env.local` into process memory and was never printed or copied.

## Exact payload and counts

The deterministic count context is UTF-8 text formed by joining these blocks with two LF characters: the complete compact schedule; the complete independent review receipt; the complete prior gate-stop receipt; the canonical compact JSON 226-ID sorted list; the canonical complete core lane projection; the canonical complete floor lane projection; the canonical active ledger; and the canonical delivered-receipt projection. The package has 69,476 bytes, SHA-256 `2469b7658e921acae6d9e6c1e5e9a85759316b68572d982109f79cc1801a6cfd`, and 22,697 input tokens.

Projection rules and bindings:

- IDs: sorted list from `03-04-TASK2-GATE-STOP.md`, 226 IDs, 2,060 bytes, SHA-256 `4277d546a212f99f36b9a3b113d80902e71b4bff5e4f89cd0c6429fda4017d67`.
- Each lane: select `lane`, `source_join_complete`, `candidate`, `aggregate_gate`, `identity_rows[*].identity.{id,identity_class,table,owner}` preserving row order, and complete `source_and_caller_evidence`; recursively sorted canonical compact UTF-8 JSON. Core is 24,408 bytes, SHA-256 `e4dab96c07fc680d69de7eb73aab3aaaa55e7e29e3510a2975084eae38a78440`; floor is 23,885 bytes, SHA-256 `55b5b1bcf73f58dbfb199f75fa6f38f8c8f0217780c956f0b1552556e16d5880`.
- Active ledger is the recursively sorted canonical JSON embedded in the schedule, 979 bytes, SHA-256 `d5d9d0570d474d9ca7b9e01970b13799e88c64fb8aaa3437b97c1e6ff9fb4199`.
- Delivered receipts: select the v0.2/Phase 1 and v0.3/Phase 2 entries and fields `milestone,milestone_key,phase,status,pr,reviewed_head,merge_commit,ci_run`; recursively sorted canonical compact JSON array, 567 bytes, SHA-256 `aab96f0a2199a2cd1bd3a177cb4811265bd4c346fae2ea7a1f3fef95d27446f0`.

The source selection is the exact inclusive UTF-8 lines 1495–1585 and 1586–1592 from `test/support/guard_aggregate_reconciliation_evidence.ex`, separated by one LF. The individual spans are respectively 3,127 bytes / SHA-256 `1d82b5b9f235bfc047eba220aa43d4ae7912639796f29e8c1ddc27ac23d7ba90` and 271 bytes / SHA-256 `2a5211c5561084e32535257bb1844c1b12586c6ac699321b551f9ecd8e5fef24`. Combined selection: 3,399 bytes, SHA-256 `d4b3318e7bac3114d65fde8acda9607346a12b99a863cad1e1ef0a8fc3fed5cd`, 843 input tokens.

The exact combined count payload joins the context, two LF characters, `# Exact scheduled source selection`, one LF, and the source selection. It has 72,912 bytes, SHA-256 `799a974bf4ed9eb712643c4e1998047ee389fb09a130f44291482534d8fb45a6`, and 23,540 input tokens.

## Limits and result

| Measure | Fresh result | Limit | Result |
|---|---:|---:|---|
| Compact context | 22,697 tokens | 34,000 | pass |
| Context plus selected spans | 23,540 tokens | 36,378 (34,000 context + 2,378 currently remaining Task 2 source) | pass |
| Task 1 historical source ledger | 21,172 tokens | 22,000 | pass |
| Task 2 before this selection | 13,622 tokens | 16,000 | pass |
| New selected Task 2 spans | 843 tokens | 2,378 remaining before selection | pass; charge selection |
| Task 2 after charge | 14,465 tokens | 16,000 | pass; 1,535 remain |
| Task 3 new source reads | 0 tokens | 0 | pass |
| Cumulative output allowance | 5,000 tokens | 5,000 | pass; 1,193 already used |
| Cushion / fixed reserve | 2,000 / 31,000 tokens | 2,000 / 31,000 | preserved |
| Projected total | 96,334 tokens | 110,000 | pass |

The source spans were read only to construct the count-only request. No source body was emitted for model analysis, no implementation changed, and no tests were run. This replan stops at the count gate as directed; it does not authorize source inspection, a fix, report publication, candidate promotion, or Plan 03-05. Candidate remains null, report unpublished, implementation unauthorized, and all safety stops remain binding.
