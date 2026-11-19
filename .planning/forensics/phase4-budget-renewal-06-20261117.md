# ENV-06 one-time headroom extension

**Recorded:** 2026-11-17T21:31:50.736Z
**Checkout:** `/private/tmp/fablebook-phase3-remediation`
**Branch:** `gsd/phase-03-recovery-and-provenance-closure`
**Authority:** INT-20261117-10, `.planning/intent/sources/2026-11-17-10-authorize-env06-650k.md`

## Fixed limits

- Generated-output ceiling: 650,000; working ceiling: 610,000; protected reserve: 40,000.
- Exact measured use: 548,654; working balance: 61,346; total balance including reserve: 101,346.
- Parent baseline: 1,057,978 output tokens at 2026-11-17T18:46:55.030Z. Parent at snapshot: 1,547,783, or 489,805 since baseline. Completed provenance audit: 8,726; completed plan-review thread: 50,123. Total: 548,654.
- The plan review's 12,894-token allowance overrun and Plan 04-02-01's 29,234-token task-cap overrun are sunk historical costs, not retried or hidden.

## Remaining-work caps

| Work | Generated-output ceiling |
|---|---:|
| Gated R1 request/review/source output | 4,000; exact input ≤34,000 and 50,000 combined cap |
| Phase 4 processing and closeout | 4,000 |
| Phase 3 Tasks 03-05-02/03 combined | 38,000 |
| **Total planned maximum** | **46,000** |

This leaves 10,131 unallocated at the snapshot. Reconcile exact live parent and child counters before each task and deduct intervening output. Maintain at least 10,000 working tokens beyond measured next-work cost. Setup, reviews, receipts, diagnostics, and retests count toward these caps. There is no automatic renewal.

## Gates and cheap checks

No source body is emitted until the exact generation and supported partition pass, the one-file R1 schedule and all bindings receive independent review, fresh Phase 4 execute preflight passes, the existing direct counter measures the exact complete request without generation, and the combined cap plus current ENV-06 fit are recomputed. Missing/failed evidence remains blocked or `not_run`; do not trim or retry an unchanged request. Run schema, hash, key-set, and scoped diff checks before source-dependent or broad suites. Phase 3 remains conditional on Phase 4's supported-evidence `--all` result and its own fresh preflight/count/fit gates.

This extension does not authorize work beyond the existing phase scope, delivery, push, PR, or reserve use. The executor continues only while every gate and budget remains valid.
