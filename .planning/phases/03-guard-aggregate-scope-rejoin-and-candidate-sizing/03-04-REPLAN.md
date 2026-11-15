---
phase: 03
plan: 03-04
date: 2026-11-15
status: third bounded replan; source-body gate closed
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
| Compact required context, execution framing, exact keyed projections | 38,500 |
| Task 03-04-01 complete independent-review source spans, including identity helper | 22,000 |
| Task 03-04-02 correction and reread spans | 500 |
| Task 03-04-03 new source-body reads | 0 |
| Output and bounded verification output | 5,000 |
| Post-count cushion | 2,000 |
| **Working envelope** | **68,000** |
| Fixed reserve | 31,000 |
| **Total planned envelope** | **99,000** |
| Remaining slack below 100,000 ceiling | 1,000 |

These are hard caps, not assumed counts. Each task separately may read no more
than five exact files. Charge every reread. If an accepted finding cannot be
reviewed and corrected within Task 1/2 source, read, context, review, or effort
caps, leave it visible in the owner report with concrete consequence and
remedy. Task 1 includes the complete identity-construction helper
`test/contract/tier_sweep_test.exs::aggregate_identity_rows!/4`, included in the
currently measured 21,183-token review spans. The 22,000-token cap leaves 817
tokens of span headroom. If a fresh schedule changes and this helper no longer
fits within the cap and five-file limit, preserve its exact identity as an
unreviewed owner-facing gap with consequence/remedy; do not claim complete
identity review. Do not omit another source, caller, lane member, complement,
or control to obtain fit.

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
sections/excerpts, not full bodies. A compact context above 38,500 tokens is a
failed gate requiring another replan without evidence reduction.

## Exact source schedules and body gate

For Task 1, schedule all complete source spans needed for the independent
review, including the collector, tagged contract, complete
identity-construction helper, and any named evidence sources, capped at 22,000
tokens and five exact files. The currently measured complete review spans are
21,183 tokens and include the helper. A refreshed schedule must preserve that
full helper span within the cap; otherwise record its exact identity,
consequence, and remedy as an owner-facing gap without claiming complete
identity review. Persist the
schedule in the initial metadata section of `03-REVIEW.md`. For Task 2,
schedule only complete correction/reread spans justified by accepted findings,
capped at 500 tokens and five exact files, counting every reread; persist
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
38,500; Task 1 spans cap at 22,000; Task 2 spans cap at 500; Task 3 new source
reads are zero; output is 5,000; cushion is 2,000. This totals 68,000 working
tokens plus the 31,000 reserve = 99,000, leaving 1,000 slack below the 100,000
ceiling. A mismatch or overage closes the gate; it does not authorize
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

## Latest measured count and replacement envelope

The current count reported 41,326 context tokens and 21,183 Task 1 span tokens,
including the complete `aggregate_identity_rows!/4` helper span. Their component
sum is 62,509; the reported combined count is 62,523, so retain the reported
combined value and treat the 14-token difference as unclassified overhead. With
the previous 1,000-token Task 2 allowance, 5,000 output, 2,000 cushion, and
31,000 reserve, the reported projected total was 101,523. The compact context
must be reduced by at least 2,826 tokens to meet its new 38,500 cap.

Reduce context only through necessary hash-bound complete excerpts, exact keyed
projections, and concise receipt summaries. Preserve all delivery, partition,
owner, identity, caller/delegate, and gap facts. Keep the full blocked receipts
in `03-REVIEW.md` and `.planning/STATE.md`, but do not duplicate their complete
historical failure narratives in execution context. If the required bundle
cannot be counted at or below 38,500 tokens without evidence reduction, stop
and replan again.

The current 21,183 Task 1 spans fit under the 22,000 cap with 817 tokens of
headroom. Keep the full helper and all reviewed spans. The new budget is 38,500
context + 22,000 Task 1 spans + 500 Task 2 correction/rereads + 0 Task 3 new
source reads + 5,000 output + 2,000 cushion = 68,000 working tokens; plus the
31,000 reserve = 99,000, leaving 1,000 tokens below the ceiling. Keep the
five-file cap per task. Preserve the blocked `03-REVIEW.md` and `STATE.md`
receipts unchanged. No source body is authorized until the compact bundle and
full span schedule pass independent review, execute preflight, and a fresh
direct combined count.

## Independent third budget replan review — PASS

**Reviewed 2026-11-15.** Plan SHA-256 `b9093150394e0e331aba12bbdd1195156c2071cbe43fc4dd6fda3cadb8476190`; pre-receipt replan SHA-256 `967abdd45ab7783fbbcc12cfbf63d7236943cca992e6af9a3b48cc13d0cf059d`. The latest failed count is recorded accurately: 41,326 context + 21,183 Task 1 spans = 62,509 components, reported combined 62,523 with 14 tokens unclassified; the previous 1,000 Task 2 allowance, 5,000 output, 2,000 cushion, and 31,000 reserve yield the recorded 101,523 total. Reducing context to 38,500 requires at least 2,826 tokens. The revised caps total 38,500 + 22,000 + 500 + 0 + 5,000 + 2,000 = 68,000 working + 31,000 reserve = 99,000. The complete `aggregate_identity_rows!/4` helper is required in the measured 21,183 Task 1 spans and stays inside the 22,000 cap; a changed schedule that cannot preserve it must leave an explicit owner-facing gap without claiming complete identity review. The five-file/task limits, full identity/acquisition/crosswalk/caller/delegate and GSR/D coverage, complete evidence scope, approved count-only fallback, and schedule-review/preflight/fresh-count gates remain intact. The full blocked `03-REVIEW.md` and `STATE.md` receipts remain preserved. No source bodies were read. This PASS does not authorize source emission; the new compact context and schedule still require independent review, execute preflight, and a fresh direct count.

## Fourth bounded context replan after the fresh direct-count failure

The reviewed receipt-bearing schedule was counted on 2026-11-15. Direct counts
were 40,422 context, 21,172 Task 1 span, and 61,588 combined tokens, with
serialized request SHA-256 values recorded in `03-REVIEW.md`. Context exceeded
the 38,500 cap by 1,922 tokens. The 22,000 span cap passed with 828 tokens of
headroom. Adding the unchanged 500 Task 2 allowance, 5,000 output, 2,000
cushion, and 31,000 reserve yields 100,088, 1,088 above the 99,000 envelope.
No source review or test ran.

The exact request hashes were context
`590b41cee9e2384fb28f8339299d54a88dbfc959ad604be8f89d4220e11f71c7`, spans
`ef1d84f91dbe93dafb018a8567c161a9482eac7621a2bf4c1fd39d967f5a94ef`, and
combined
`d02e167e3301b62ddbb8bb5a12f0af70a34ba9e90077b8ae4086972a5bf9400d`.

The no-loss reduction narrows the glossary selection from all of lines 1–370
to the complete relevant sections at lines 118–150 and 261–354: Tiers; Checks
and evidence; Catalog and context; and Scope. This retains the tier-sweep
terminology, check/evidence/finding terms, bundle and budget terms, and the
explicit native-mobile scope boundary. The full glossary remains bound to
15,891 bytes and SHA-256
`e1f8dbee98abf437ee6851f103a93e119dff97a0416b93754a8dd41ae55e25c6`; the
selected excerpts are 1,389 bytes / SHA-256
`71de3c4a5253fe24c58d863d316935e67cd6093f97b3c8579323f654a169f883` and 3,248
bytes / SHA-256
`df439721b4874967bb5fef7a454c6b9bacbd85f4e26fe053f672d0854460982a`.

All lane/sizing/delivery projections, source and caller coverage, identities,
receipts, partitions, plan requirements, owner checkpoints, five-file cap,
all ten spans, zero-read Task 3, output/cushion allowances, reserve, and safety
stops remain unchanged. The deterministic count serializer uses only the
manifest's exact selected excerpts and keyed projections; schedule context
omits duplicated envelope and lane-recipe text already present in the selected
Plan/Replan and `03-REVIEW.md` excerpts. Obtain independent review of the exact
updated selections, run execute preflight, and directly count the receipt-
bearing context and complete spans before any source body is emitted.

For the next exact count, retain the schedule's span table and context manifest
(lines 40–102), five-file/delivery/sizing ledger (153–196), and inherited phase
partition check (215–218). The selected Plan, Replan, STATE, REVIEW, and latest
schedule PASS receipt already carry the matching envelopes, task gates, concise
receipt state, lane recipe, and review procedure. Omitting their repeated
schedule prose reduces duplication only; every full file stays hash-bound, all
required selections and projections remain present, and source spans are
unchanged.

## Final bounded Task 2 recount

The prior v1/v2 requests bundled generated diff output with source rereads, so
their 759/743-token totals do not establish a source-span cap failure; their
complete receipts remain in `03-REVIEW.md`. One final smaller v3 candidate is
bound in the current schedule. Build the recount context from
current full-file identities plus only the latest blocker/handoff excerpts;
omit repeated historical narratives while retaining the complete current
STATE handoff, locked decisions, exact lane/sizing projections, and all safety
stops. Independently review the exact candidate schedule, run execute
preflight, and directly count context and source spans separately from the
candidate output. Do not emit v3 unless source rereads fit 500 tokens, the
generated patch fits the 5,000-token output allowance, and the combined
context/output/cushion/reserve envelope passes. If they do not,
leave the source-join finding open with its consequence and remedy; Plan 03-05
remains unstarted.

## Corrected Task 2 source and patch binding

The separately counted v3 candidate is preserved as historical evidence only.
Its test hunk had zero context; applying the hunk placed it at EOF outside the
test module. The test file was restored and no test or Task 2 commit occurred.
Diagnosis read test lines 5905–5960 (2,125 bytes,
`c6c5fa526f2ebaf6f19e76abe650a79b3a65a76f1472cc715fd24a3c1103a6b3`). Bind
that exact diagnostic span plus the actual insertion anchor (the caller-graph
tag and declaration at line 5937) into the new Task 2 source selection. Anchor
the next test hunk immediately before that declaration. Rebind all current
STATE, REPLAN, REVIEW and SIZING identities/projections, obtain independent
metadata PASS and execute preflight, then directly count the corrected source
selection separately from generated output. The existing 500-token source,
5,000-token output, 38,500-token context, 2,000-token cushion, 31,000 reserve
and 99,000 projected-total limits remain binding. Do not emit source or tests
until every fresh count passes. Preserve the prior v3 receipt and this failed
placement as history; do not treat old counts as authorization.

## v4 source-span cap result

The corrected v4 schedule received independent metadata PASS and fresh
execute preflight. Four count-only requests measured 34,069 context tokens,
611 source-span tokens, 638 generated-output tokens, and 35,306 combined.
Context, output and projected total (72,668 with 4,362 remaining output,
2,000 cushion and 31,000 reserve) pass. The source selection exceeds the
500-token cap by 111, so no candidate patch was applied and no regression ran.
The within-limit route is to bind only the minimum exact correction/test
context needed to preserve the caller-test anchor and both true/false gap
cases, while retaining the full accidental-read receipt as history. If that
selection cannot fit 500, keep the finding owner-facing with its consequence
and remedy; do not authorize Plan 03-05.

Independent review rejected v5 reuse: the plan says “including every
reread,” and the Task2 diagnostic read occurred after Task1 even though it
overlaps reviewed lines. Keep v4's 611-token result as the controlling cap
failure. Do not recount or emit v5. Preserve the finding and concrete
consequence/remedy, then continue only with Task3 work that has zero new
source-body reads and its own required count/review gates. Do not begin
Plan03-05.

## Task 1 span reuse review checkpoint

The v4 count included the full accidental test read, producing 611 source
tokens and failing the 500-token Task 2 cap. Before abandoning the correction,
verify the plan's accounting semantics against its recorded Task 1 review:
Task 1 already scheduled and counted test lines 5936–6137 (7,797 bytes,
`39d0c8cb47e88d1a42b4849e2afe0736439eb65aff2dbac41f0490ea5a94798c`), which
contains the exact two-line insertion anchor at 5936–5937. The full file
identity remains unchanged (`f3d5b9901c0373b39331163a4b4cdbd2f3b29c6682337d0134e6691f45bfc4f5`).
The accidental 5905–5960 diagnostic read remains disclosed as history. Obtain
independent confirmation that the existing Task 1 span may be reused without
another Task 2 reread under “including every reread.” Only if accepted, bind
the old/new identities and count only the genuinely new support correction
span plus exact generated output, then refresh execute preflight and direct
counts. Otherwise keep the finding open with its consequence/remedy and do not
start Plan 03-05.
