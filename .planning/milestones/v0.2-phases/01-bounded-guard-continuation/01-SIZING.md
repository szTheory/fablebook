# Phase 1 source-connected sizing

**Status:** Fit is certified against the inherited 100,000-token ceiling per isolated serial plan context, with a 31,000-token conservative reserve retained in every context. This is planning-context sizing, not a semantic verdict or permission to truncate sources.

## Certified source and graph boundary

The exact-source baseline is six full files: core `inets.erl`, `inets_trace.erl`, `dbg.erl` (36,518 historical tokens); floor equivalents (38,888); 75,406 total across both lanes. Exact bytes, SHA-256 identities, pinned refs, archive state and tokenizer provenance are tabulated in `01-RESEARCH.md`. Each lane source review reads three files, below the five-exact-files-per-task limit.

The current core and floor graph contract passed (`test/contract/tier_sweep_test.exs:5234`). Durable lane observations are in `01-GRAPH-OBSERVATIONS.json`; full compressed receipts are `_build/phase1-research-receipts/{core,floor}.jsonl.gz`. Both lanes select exactly `inets:enable_trace/2` and `/3`, report zero additional within-row remainder, and mark the selected/remainder partition equal. Outside-row ledger identities and dispositions remain under their existing owners. Each lane records the two delegate edges from `inets:enable_trace` to `inets_trace:enable/2,/3`; the active projection has no incoming edges. Paired OTP-only Xref also found zero direct incoming edges. Neither result rules out dynamic callers.

The connected source path is bounded at the configured callback and destination boundary: `inets.erl` delegates to `inets_trace`; `inets_trace.erl` routes file, integer port, `io`, or `{Fun, Data}` destination cases through debugger tracing; `dbg.erl` contains the callback invocation and `trace_port` dispatch. `dbg` is therefore the only known additional exact source beyond the direct endpoint/delegate files. The callback implementation is caller input and is not recursively treated as an arbitrary source set. Native trace-port internals are a fixed runtime boundary. No separate evaluator, loader, atom-sink, or callback-implementation file is indicated by the connected path or current graph. Dynamic-caller absence is not claimed.

The archive currently includes both lane `inets.erl` and `dbg.erl`; `inets_trace.erl` is locally available with verified lane hashes but still requires binding to the approved archive/resolver before execution. The passed discovery run made no audited API calls and invoked no trace callback.

## Three isolated serial plan contexts

| Serial plan | Source or structured findings context | Preserved reserve | Total ceiling estimate | Conservative effort |
|---|---:|---:|---:|---|
| Core lane: full review of the three exact core files plus lane evidence | 36,518 | 31,000 | 67,518 | 1–2 working days |
| Floor lane: full review of the three exact floor files plus lane evidence | 38,888 | 31,000 | 69,888 | 1–2 working days |
| Integration: consume only hash-scoped structured semantic findings from the first two plans; do not reopen the six files | up to 40,000 | 31,000 | up to 71,000 | 0.5–1.5 working days |

Each plan is under 100,000 in its own isolated context. The phase-wide arithmetic sum is not the governing measure because these are serial, separate planning contexts; findings move forward as structured, exact-hash-scoped results. Do not silently reduce the 31,000 reserve or count a graph/hash receipt as semantic findings. The 40,000 integration allowance is an explicit conservative assumption for the two lane result sets, partition/evidence reconciliation, and integration review; stop and re-scope before exceeding it. Never truncate relevant source or omit a connected file to meet the ceiling.

The 31,000 reserve in each context covers: 5,000 phase constraints, current ownership and prior evidence; 8,000 source archive binding, graph/partition evidence and lane reconciliation; 10,000 disposition and witness/control design; 8,000 review, local validation, CI receipt and one bounded correction cycle. This is a conservative planning allowance, not a measured token-to-effort conversion. It includes shared helper, research and planning context. Existing prior execution timing is only a qualitative reasonableness check; it does not support a tokens-per-hour estimate.

## Work shape and stops

Use at most five plans in the phase, 2–3 tasks per plan, and at most five exact source files per task including rereads. The proposed three plans fit those limits: lane plans perform full-source semantic review; integration consumes their structured findings without reopening source. Full-source review and independent review occur during execution. The research graph establishes current match membership and connected delegates, not each source's final disposition.

Stop before executable work if archive binding cannot reproduce the exact `inets_trace.erl` bytes, a source review identifies another necessary exact file, the integration finding set exceeds its 40,000 allowance, any per-plan context approaches 100,000, or evidence would require truncation. Recompute the affected isolated plan with its full 31,000 reserve and repartition only while preserving all source and evidence scope. Existing source-size, collision, Macro/explanation, aggregate/skeleton and SEC-01 stops remain binding.
