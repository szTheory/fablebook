---
phase: 03
plan: 03-04
date: 2026-11-15
status: bounded-replan; source-body gate closed
---

# Plan 03-04 bounded context and source replan

## Trigger and preserved scope

The original working projection was 76,000 tokens; adding the fixed 31,000
reserve totals 107,000, exceeding the 100,000 ceiling by 7,000. This replan
keeps the existing three tasks and all independent review, accepted-fix,
retest, report, GSR-01 through GSR-06, and D-01 through D-04 requirements. It
does not lower checks, erase evidence, change candidate scope, or weaken safety
stops. Each task retains a maximum of five exact source files, including
rereads.

## Hard context envelope

| Component | Maximum tokens |
|---|---:|
| Compact required context, execution framing, exact keyed projections | 45,000 |
| Task 03-04-01 complete independent-review source spans | 12,000 |
| Task 03-04-02 correction and reread spans | 5,000 |
| Task 03-04-03 new source-body reads | 0 |
| Output and bounded verification output | 5,000 |
| Post-count cushion | 2,000 |
| **Working envelope** | **69,000** |
| Fixed reserve | 31,000 |
| **Total hard ceiling** | **100,000** |

These are hard caps, not assumed counts. Each task separately may read no more
than five exact files. Charge every reread. If an accepted finding cannot be
reviewed and corrected within Task 1/2 source, read, context, review, or effort
caps, leave it visible in the owner report with concrete consequence and
remedy. Do not omit a source, caller, lane member, complement, or control to
obtain fit.

## Compact context and keyed evidence

Build a compact hash-bound context bundle from only the required complete
sections/excerpts: Phase 3 goal and GSR requirements; D-01 through D-04 and
active stops; current phase/plan status; the relevant prior review findings;
the exact lane/sizing records' required keyed identities, statuses, and gaps;
and the report sections necessary to verify accepted fixes. Bind each excerpt
to source digest, inclusive line boundaries, and excerpt digest. Bind the full
lane records by file digest and generation but query only exact keyed
projections required for review. Do not load complete lane arrays or full large
reports into context. Omit unrelated sections, but retain all original
identities, full lane joins/complements, source/caller/delegate coverage, and
GSR/D checks through complete keyed queries and hash-bound references.

Apply GSD's under-500k read-depth rule to large summary, verification, and
report artifacts: use frontmatter/status and only necessary complete
sections/excerpts, not full bodies. A compact context above 45,000 tokens is a
failed gate requiring another replan without evidence reduction.

## Exact source schedules and body gate

For Task 1, schedule all complete source spans needed for the independent
review, including the collector, tagged contract, and any named evidence
sources, capped at 12,000 tokens and five exact files. Persist its schedule in
the initial metadata section of `03-REVIEW.md`. For Task 2, schedule only the
complete correction/reread spans justified by accepted findings, capped at
5,000 tokens and five exact files, counting every reread; persist this schedule
in `03-SIZING.json` with the correction evidence. Task 3 uses no new source
bodies and relies on accepted findings, corrected records, and Task 1/2
interface notes.

Each schedule must record exact path, file SHA-256 and byte count, complete
function/test or keyed evidence identity, inclusive line/record boundaries,
span bytes, span SHA-256, and count method/result. Obtain independent schedule
review, run `bin/planning_health --stage execute --phase 3`, then directly count
the exact current combined context plus the scheduled spans, review receipts,
output, cushion, and reserve. Emit source bodies only after all three gates
pass. Repeat the direct count after every schedule, plan, receipt, or selected
input change and before each source emission. A mismatch or overage closes the
gate; it does not authorize truncation, a different candidate, or unreviewed
source acquisition.

## Token counts and credential boundary

Use an already-installed, positively identified local `tiktoken`
`o200k_base.encode_ordinary` if available. Otherwise use only the already
approved no-cost `POST /v1/responses/input_tokens` endpoint for model
`gpt-6-luna` with the existing ignored `.env.local` credential. Never create or
rotate a key, print or persist its value, use it at another endpoint, or call a
generation endpoint. Record model, endpoint, exact serialized payload SHA-256,
response count, and a redacted harness/command. If neither method works, leave
counts unknown and stop before body emission.

## Safety and authority unchanged

Keep the full independent review, maximum two review passes, accepted finding
corrections, regression checks, both-lane evidence validation, bundle/report
regeneration, and exact GSR/D coverage. Preserve static-only proof, actual
library collision owner stop, Macro caller-AST and wording checkpoints,
aggregate gate open, candidate-null on gaps, SEC-01 Pending, Walking Skeleton
blocked, and `implementation_authorized=false`. Unresolved findings within
the allowed review cap remain owner-facing with consequence and remedy; they
are not silently cleared or treated as passed readiness.

## Independent Plan 03-04 review — PASS

**Reviewed 2026-11-15.** Plan SHA-256 `a613a4ae0e480fc044d80e56e3b90bdc4dd418dc974ee538f46afe5cef697d33`; pre-receipt replan SHA-256 `fb7645e6cd9ef8985439b1d8c431bba5c2ebc447839234725eb7022f4b489922`. The envelope is 45,000 + 12,000 + 5,000 + 0 + 5,000 + 2,000 = 69,000 working tokens, plus 31,000 reserve = 100,000. Each task retains the five-exact-file cap. The plan requires hash-bound compact context, complete-span schedules, independent schedule review, execute preflight, and fresh direct counts before source emission; count fallback is limited to the approved `POST /v1/responses/input_tokens` endpoint/model/credential policy. Independent review, accepted-finding regression/fix/retest, two-pass maximum, and corrected report publication are covered. GSR-01–06, D-01–04, complete lane/source/caller/complement scope, original delivery/ownership traceability, candidate-null-on-gaps, and all static-only, collision, Macro, SEC-01, aggregate-gate, Walking Skeleton, and owner-authority stops remain intact. No source bodies were read. This PASS reviews plan completeness only; execution and body emission remain gated.
