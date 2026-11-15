---
phase: 03
plan: 03-04
date: 2026-11-15
status: second bounded replan; source-body gate closed
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
| Compact required context, execution framing, exact keyed projections | 38,000 |
| Task 03-04-01 complete independent-review source spans, including identity helper if it fits | 21,000 |
| Task 03-04-02 correction and reread spans | 1,000 |
| Task 03-04-03 new source-body reads | 0 |
| Output and bounded verification output | 5,000 |
| Post-count cushion | 2,000 |
| **Working envelope** | **67,000** |
| Fixed reserve | 31,000 |
| **Total planned envelope** | **98,000** |
| Remaining slack below 100,000 ceiling | 2,000 |

These are hard caps, not assumed counts. Each task separately may read no more
than five exact files. Charge every reread. If an accepted finding cannot be
reviewed and corrected within Task 1/2 source, read, context, review, or effort
caps, leave it visible in the owner report with concrete consequence and
remedy. Task 1 includes the omitted identity-construction helper if its
complete span fits within the 21,000-token span cap and five-file limit. If it
does not fit, preserve its exact identity as an unreviewed owner-facing gap,
with consequence/remedy, and do not claim complete identity review. Do not omit
another source, caller, lane member, complement, or control to obtain fit.

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
sections/excerpts, not full bodies. A compact context above 38,000 tokens is a
failed gate requiring another replan without evidence reduction.

## Exact source schedules and body gate

For Task 1, schedule all complete source spans needed for the independent
review, including the collector, tagged contract, the omitted
identity-construction helper, and any named evidence sources, capped at 21,000
tokens and five exact files. Include the helper only if it fits inside the
combined cap; otherwise record its exact identity, consequence, and remedy as
an owner-facing gap without claiming complete identity review. Persist the
schedule in the initial metadata section of `03-REVIEW.md`. For Task 2,
schedule only complete correction/reread spans justified by accepted findings,
capped at 1,000 tokens and five exact files, counting every reread; persist
this schedule in `03-SIZING.json` with the correction evidence. Task 3 uses no
new source bodies and relies on accepted findings, corrected records, and Task
1/2 interface notes.

Each schedule must record exact path, file SHA-256 and byte count, complete
function/test or keyed evidence identity, inclusive line/record boundaries,
span bytes, span SHA-256, and count method/result. Obtain independent schedule
review, run `bin/planning_health --stage execute --phase 3`, then directly count
the exact current combined context plus the scheduled spans, review receipts,
output, cushion, and reserve. Emit source bodies only after all three gates
pass. Repeat the direct count after every schedule, plan, receipt, or selected
input change and before each source emission. The compact context cap is
38,000; Task 1 spans cap at 21,000; Task 2 spans cap at 1,000; Task 3 new
source reads are zero; output is 5,000; cushion is 2,000. This totals 67,000
working tokens plus the 31,000 reserve = 98,000, leaving 2,000 slack below the
100,000 ceiling. A mismatch or overage closes the gate; it does not authorize
truncation, a different candidate, or unreviewed source acquisition.

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

## Latest execution count failure and replacement envelope

The 2026-11-15 execution count recorded in the existing `03-REVIEW.md` and
`.planning/STATE.md` found 52,623 context tokens and 18,258 Task 1 span tokens,
70,881 combined before output, cushion, and reserve. Adding 5,000 output,
2,000 cushion, and 31,000 reserve produced 108,881, above the 100,000 ceiling.
Those executor records remain unchanged. This measured failure supersedes the
earlier planning-only PASS as evidence of fit; that PASS is retained above as
historical review evidence.

The replacement envelope is 38,000 compact context + 21,000 Task 1 spans +
1,000 Task 2 correction/reread spans + 0 Task 3 new source reads + 5,000 output
+ 2,000 cushion = 67,000 working tokens. Adding the fixed 31,000 reserve gives
98,000, leaving 2,000 tokens below the ceiling. Task 1 must include the
identity-construction helper within its combined 21,000 span-token and
five-file caps; if it cannot fit, the helper remains an explicit owner-facing
review gap with consequence and remedy. No source emission is authorized until
a new independent schedule review, fresh execute preflight, and direct count
confirm this replacement envelope.

## Independent second budget replan review — PASS

**Reviewed 2026-11-15.** Plan SHA-256 `dc4d309ee57c78bc88df84f9a3157dfc902182fdb0cec4c82b56978d351e18fb`; pre-receipt replan SHA-256 `990acf6937fcb9c26c77f8b7fd689c049f372eda8bbfb9c499e77cf71c2eec60`. The failed direct count is recorded accurately: 52,623 context + 18,258 Task 1 spans = 70,881 before allowances; with 5,000 output + 2,000 cushion + 31,000 reserve = 108,881 total. The replacement is 38,000 + 21,000 + 1,000 + 0 + 5,000 + 2,000 = 67,000 working + 31,000 reserve = 98,000. Each task retains the five-exact-file limit. Task 1 must include `test/contract/tier_sweep_test.exs::aggregate_identity_rows!/4` within its cap or preserve that exact identity as an owner-facing gap with consequence/remedy and no completeness claim. Full GSR-01–06 and D-01–04 review, independent review/fix/retest/report flow, two-pass cap, complete lane/source/caller/complement scope, and all owner/authority/safety stops remain intact. The only count fallback is the already approved `POST /v1/responses/input_tokens` endpoint for `gpt-6-luna` with the existing ignored credential. Body emission remains gated on independent schedule review, execute preflight, and fresh direct count. Existing blocked count receipts in `03-REVIEW.md` and `STATE.md` were verified and left untouched; no source bodies were read.
