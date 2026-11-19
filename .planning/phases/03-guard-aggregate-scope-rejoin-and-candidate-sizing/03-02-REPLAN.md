---
phase: 03
plan: 03-02
date: 2026-11-14
status: reviewed-pass
---

# Plan 03-02 context and source-budget correction

## Trigger

The reviewed plan projected 75,000 raw context tokens and retained a 31,000-token
fixed reserve under a 100,000-token ceiling. That projection would total 106,000,
so it cannot authorize source reads as written. No Plan 03-02 source body has been
read.

## Count-only baseline

A direct `POST /v1/responses/input_tokens` count for `gpt-6-luna` measured **43,089
tokens** for the following selected execution inputs: `CLAUDE.md`, `.planning/config.json`,
`.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`,
`.planning/STATE.md`, `.planning/VERIFICATION.md`, `.planning/intent/NORTH-STAR.md`,
`.planning/intent/CLEARANCE.md`, `GLOSSARY.md`, `docs/adr/README.md`,
`docs/adr/0004-no-eval-no-new-atoms.md`, Phase 3 `03-CONTEXT.md`, `03-PATTERNS.md`,
`03-01-SUMMARY.md`, `PLANNING-GATES.json`, `CARRY-FORWARD.md`, and `03-02-PLAN.md`.
The count included path labels and complete document text. It was count-only: no
source body or evidence record was emitted. The existing owner credential was used
only with the free token-count endpoint; no key was created, rotated, changed, or
printed.

## Revised hard budget

The existing two-task plan and five-exact-source-files-per-task limit remain. The
plan now limits semantic source payload to **17,000 tokens total**: at most 11,000
for Task 03-02-01 and at most 6,000 for Task 03-02-02. Output remains capped at
5,000 tokens. Reserve 2,000 tokens for post-count plan/receipt growth and execution
framing. Before any semantic source read, count the final selected documents and
the exact complete source spans together; proceed only when:

`measured documents + 17,000 source maximum + 5,000 output + 2,000 cushion <= 69,000`

The separate 31,000-token fixed reserve remains intact, so the hard total stays at
or below 100,000. The current baseline plus these fixed allowances projects to
67,089/69,000 working tokens and 98,089/100,000 total, with 1,911 working tokens
of slack before the plan amendment. This is not the final source-read gate: repeat
the direct combined count after plan/review changes and before each acquisition.

Prepare exact path/range/complete-boundary schedules and measure them count-only;
obtain review and execute preflight before emitting any semantic body. Charge every
read and reread against the task's five-file ceiling and the plan's 17,000-token
source cap. If an exact source event or cumulative projection exceeds its limit,
stop and retain the exact source/caller identity as an explicit gap with a bounded
remedy. Do not truncate, retry, inspect another source, or change candidate or safety
authority to make the budget fit. Materialize bulk graph metadata on disk and inspect
only selected keyed records.

## Preserved scope and stops

No plan/task/file scope or evidence requirement changed. The only adjustment is a
strictly lower source/output context envelope. Preserve static-only collection, no
audited target/callback/atom-sink/runtime-evaluation/generated-code path, the
actual-library-collision owner stop, Macro checkpoints, `candidate=null`,
`implementation_authorized=false`, `aggregate_gate=open`, source gaps as unknown,
Walking Skeleton blocked, and SEC-01 Pending.

## Independent review

The independent plan reviewer returned **PASS** on 2026-11-14. It verified the
43,089 + 17,000 + 5,000 + 2,000 = 67,089 working-token projection, the unchanged
31,000 reserve and 100,000 ceiling, task source/file limits, and unchanged evidence
and safety scope. The reviewer read no source body. It explicitly found the
43,089-token pre-edit count insufficient to authorize a source read.

A post-review document-only count returned **44,499 tokens** for the selected
documents plus this replan. Charging the full 17,000-token source cap, 5,000 output
allowance, and 2,000 cushion yields 68,499/69,000 working tokens; with the fixed
reserve, 99,499/100,000 total and 501 tokens of slack. This is a conservative
envelope, not permission to read a body: the final direct count must include the
exact scheduled complete source spans and all current receipt text.

Run execute preflight and refresh the exact selected-document plus source-span
count after this receipt and all range-schedule changes. The earlier 43,089 count
must not be reused as the final gate. No source-body acquisition is authorized by
this receipt alone.
