---
phase: 03
plan: 03-04
date: 2026-11-15
status: metadata-only supplemental gap route planned; original bounded source stop preserved; no new source reads
---

# Plan 03-04 bounded context and source replan

> **Version note:** The original 99,500-token in-limit replan and the later
> 5,500-token Task 2 ledger below are historical. The active allocation is the
> one-time 110,000-token recovery envelope in the final section, authorized by
> INT-20261115-02. No earlier schedule or count authorizes source emission.

## Trigger and preserved scope

The original working projection was 76,000 tokens; adding the fixed 31,000
reserve totals 107,000, exceeding the 100,000 ceiling by 7,000. This replan
keeps the existing three tasks and all independent review, accepted-fix,
retest, report, GSR-01 through GSR-06, and D-01 through D-04 requirements. It
does not lower checks, erase evidence, change candidate scope, or weaken safety
stops. Each task retains a maximum of five exact source files, including
rereads.

## Original in-limit replan envelope — historical after the source-search incident

| Component | Maximum tokens |
|---|---:|
| Compact required context, execution framing, exact keyed projections | 34,000 |
| Task 03-04-01 complete independent-review source spans, including identity helper | 22,000 |
| Task 03-04-02 cumulative correction, trace and reread spans | 5,500 |
| Task 03-04-03 new source-body reads | 0 |
| Output and bounded verification output | 5,000 |
| Post-count cushion | 2,000 |
| **Working envelope** | **68,500** |
| Fixed reserve | 31,000 |
| **Total planned envelope** | **99,500** |
| Remaining slack below 100,000 ceiling | 500 |

At the original replan, this allocation was authorized by INT-20261115-01 and the bounded trace
amendment at the end of this file. The V20 cumulative Task2 source baseline is
2,387 tokens; 3,113 remain for the entire trace, repair, rereads and review.
Earlier allocations/count receipts below are historical and remain charged.
The cumulative output ledger is not reset. Task3 retains zero new source reads.

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
sections/excerpts, not full bodies. A compact context above 34,000 tokens is a
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
schedule only complete correction/trace/reread spans justified by accepted findings,
capped cumulatively at 16,000 tokens and five exact files, counting every reread; persist
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
34,000; Task 1 spans cap at 22,000; cumulative Task 2 spans cap at 16,000; Task 3 new source
reads are zero; cumulative output is 5,000; cushion is 2,000. This totals 79,000 working
tokens plus the 31,000 reserve = 110,000 under the one-time Phase 3 ceiling.
The current total includes the conservative incident charge recorded at the
end of this file. A mismatch or overage closes the gate; it does not authorize
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

## Historical V20 allocation and unchanged safety/authority gates

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

## Owner-authorized Task 2 cap reallocation — active

On 2026-11-15 the owner authorized “Replan within limits.” Reallocate 300
tokens from the existing 1,000-token global slack to Task 2, raising its
correction/reread cap from 500 to 800. Keep context 38,500; Task 1 spans
22,000; Task 3 new source reads 0; generated output 5,000; cushion 2,000;
and the 31,000 reserve unchanged. The new total is 68,300 working + 31,000
reserve = 99,300, leaving 700 below the 100,000 ceiling.

The prior v4 selection remains fully charged at 611 source tokens, including
the 2,125-byte Task2 diagnostic reread; no overlap/reuse reclassification is
made. Its source span now fits the newly authorized 800-token ceiling, but its
old schedule/input hashes do not authorize patch emission. Rebind current
STATE, PLAN, REPLAN, REVIEW and SIZING, retain the exact corrected v4 candidate,
obtain independent review of this reallocation and active schedule, fresh
execute preflight, and fresh direct context/span/output/combined counts. Only
after every cap passes may the test hunk run RED and the source correction run
GREEN. Preserve the source-join finding and all safety stops until the checks
and required independent review pass. No Plan 03-05 or follow-on implementation
is authorized if the finding remains unresolved.

## Candidate v6 hunk correction — active; count pending

The v5 candidate's patch application check failed because the existing caller
test context line had one missing indentation byte. No source was changed.
Temp-only v6 fixes that context line in addition to v5's newline correction;
`git apply --check` now passes. Its exact candidate identity is 2,288 bytes,
SHA-256 `05998c2c9adf88e6e1c3e96998fb94ef4c6e2cb734a522cc34aa64b2a54dbac3`.
The source semantics, true/false regression, complete 611-token reread and
800-token cap do not change. Preserve v4/v5 counts and the v5 apply-check
failure as history. Bind current planning inputs, obtain independent review,
fresh execute preflight and direct counts before applying this candidate.

## Candidate v8 test map-order correction — active; count pending

The exact current failure log is `03-04-TASK2-INVALID-RED.log`: the v6 test
failed to compile because the string-key entry followed a keyword entry in a
map. A temp-only v8 patch reorders those keys, passes `Code.string_to_quoted!`
on the corrected full test file, and passes `git apply --check` against the
dirty test-only hunk. No source edit or test run has followed that repair.
Candidate: 1,132 bytes / SHA-256
`780d00f33ce8a6d1f3686a8648f7cb68a9f8c431c76506969b46c45090f7c534`.
Preserve the prior 611-token diagnostic-inclusive source count as history and
bind the incremental current test span exactly. The cumulative source ceiling
remains 800; all other caps and safety stops are unchanged. Obtain independent
metadata review, fresh execute preflight and direct counts before applying v8.

## Candidate v9 exact-line test correction — active; count pending

V8 preserved history but its 193-token incremental span plus prior 611-token
Task2 selection totaled 804, four above the 800 cap; the patch was not applied.
Temp-only v9 uses a zero-context **line replacement**, not an insertion: the
exact current line 5944 is hash-bound, while the module anchor remains bound by
the prior reviewed/count receipt. `git apply --unidiff-zero --check` and syntax
parsing of the corrected full test file both pass. Candidate: 909 bytes / SHA
`9affdec4f4d579ebff5748b9e8ecba4548421956278b5015429b6e86ffc2d371`. Rebind
current artifacts; cumulative source is prior 611 plus the exact current-line
reread and must remain ≤800. Obtain independent metadata PASS, execute
preflight and fresh direct counts before applying.

## Candidate syntax repair after count — fresh gate required

After the owner-authorized v6 count passed, patch inspection found a malformed
line at the new test boundary: the added `end` had been concatenated with the
existing caller-test tag. No patch was applied and no test ran. Preserve the
v4 count as historical; it does not cover corrected candidate bytes. A
temp-only v5 repairs only that newline and retains the same test placement,
behavior and two source spans. Bind its exact new bytes/hash, current planning
inputs, schedule and harness; obtain fresh independent metadata review,
execute preflight and direct counts before any source edit. Keep all caps and
safety stops unchanged.

## Candidate v9 RED receipt — valid assertion failure

The v9 test-only correction was applied only after its fresh count passed.
The focused core run returned exit 2 and an unchanged TAP report; the exact
target `test source join completeness follows gaps` failed at the
`source_join_complete` assertion, with no compile/load failure or report parse
errors. `gsd_run check tdd-red-evidence` returned `RED_EVIDENCE_OK` (109 tests,
2 pass, 1 target failure; all other selected cases skipped). Full report and
semantic record are `03-04-TASK2-RED.tap` and `03-04-TASK2-RED.json`. No
support-source change has occurred. Next bind the post-test tree and
temp-only support correction, independently review, run execute preflight
and count all current spans/output/combined under the unchanged 800/5,000/
99,300 limits before applying the implementation.

## Final Task2 cap reallocation — active v11 schedule; count pending

The v10 fresh post-test count bound the unchanged support span and returned
95 tokens; cumulative Task2 source was 611 prior +133 v9 +95 =839, exceeding
the then-active 800 cap. No support source changed. Under the owner's standing
“Replan within limits” authorization, the final Task2 source cap is now 1,000,
allocating 200 tokens from the remaining global slack. Other caps remain
context 38,500, Task1 22,000, Task3 0, output 5,000, cushion 2,000, reserve
31,000; total working 68,500 + reserve 31,000 =99,500 with 500 below the
100,000 ceiling. Prior 500/800 failures stay as history; no additional cap
increase is allowed. Bind the exact current schedule and count harness,
obtain independent review, run execute preflight and fresh direct counts
before applying the support correction. If any cap fails again, keep the
accepted finding open and do not start Plan 03-05.

## V10 support patch verification — focused core test still failing

The final 1,000-cap schedule passed fresh independent review, execute
preflight and direct counts (context 35,139; Task2 source 839/1,000; output
1,090/5,000; combined 35,380; projected total 94,206/99,500). The temp-only
support patch was applied after that gate. The focused core write check then
failed one target test before its intended source-join assertion: `build.([])`
raised `MatchError` on `false` in `validate_aggregate_lane!/1` at support line
138. The runner reported 2/3 passed, 1 failed, 106 excluded. Floor did not run.
No additional source body has been read. Next bind/review/count the exact
post-v10 tree and this diagnostic line before any further correction; no cap
increase is permitted. Preserve the valid RED record and all prior count
failures. The accepted join finding remains open and Plan 03-05 is blocked.

## V12 diagnostic result and V14 validator correction candidate

The first V12 request counted context and line 138, but its empty-output
request received HTTP 400 and no combined count ran; no body was inspected.
That 33-token line count remains charged. V13 skipped the empty output request
and passed context 33,085, line 138 33, combined 33,112; cumulative Task2
source is 905/1,000 and total 92,066/99,500. Only after that gate, inspection
showed line 138 was `true = record["source_join_complete"] == false`, the
stale invariant that caused the v10 focused test failure. A temp-only V14
candidate changes that assertion to compare against `target_source_gaps == []`.
It has not been counted, applied, or reviewed. Bind exact current artifacts
and patch, independently review, run fresh execute preflight and count before
any further source edit. No cap increase is allowed.

## V14 GREEN and records refresh — focused core/floor checks pass

V14 passed independent metadata review, execute preflight and direct count:
context 34,105; exact line span 33; output 103; combined 34,229; cumulative
Task2 source 938/1,000; cumulative output 1,193/5,000; projected total
93,113/99,500. The one-line validator patch was applied and `git diff
--check` passed. Both focused write-mode checks passed: core 3/3 selected and
floor 3/3 selected, with 106 excluded in each lane. No new source body was
read after the count. Core/floor machine records changed, but SIZING remains
unchanged and its stored lane record hashes are stale. Candidate is still
null and real source_join_complete remains false where evidence gaps persist.
Next obtain an independent review of the bounded code/test diff, reconcile
SIZING using the existing records workflow or preserve its exact gap, then
continue only permitted zero-source-read Task3 report work. No Plan 03-05.


## V15 bundle regression blocker — one-line Task2 diagnostic pending count

The fresh zero-source-read Task3 count passed at context 36,195, marker 19,
combined 36,208 and projected total 95,125/99,500. The first authorized bundle
write check then failed before report publication: `validate_target_sources!/1`
raised MatchError at support line 394. The report and machine records were not
changed by the failed run. No source body was opened. The exact diagnostic is
test/support/guard_aggregate_reconciliation_evidence.ex line 394, 61 bytes /
`d17d00204d49b02e495b9719a0569e450bc694a6ae5c3ab0cb8e6f44a1818c49`; full
support file is 58,768 bytes /
`54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63`. Prior
Task2 source charge is 938/1,000, leaving 62. Count the one-line span against
the exact current context and combined payload with a nonempty diagnostic
marker. If it passes, inspect only that selection, prepare any correction in
temp storage, then independently review and recount before applying. Task3
remains zero source-body reads; candidate remains null and no later plan may
start.


## V15 line 394 diagnostic — counted pass; line 393 only may fit

The fresh direct count passed for exact support line 394: context 37,719;
span 36; combined 37,749; Task2 cumulative source 974/1,000; projected total
96,666/99,500. The one selected assertion is `true =
record["target_source_coverage_complete"] == true`. No further body has been
read. Only 26 source tokens remain. A metadata-only 43-byte line 393 span is
identified (`cd292c6d5b35850c08eca37b4ca58758569d9e27628dd448d6fd52e31fe8957a`);
count it before inspection. If it exceeds the remaining cap or does not resolve
the expected invariant from already-reviewed context, stop with the exact
owner-facing gap; no cap increase is authorized.


## V16 source cap failed — stop; no further reallocation

Fresh direct count for exact support line 393 passed the context cap but failed
the final Task2 source cap: 974 previously charged Task2 tokens + 33 for line
393 = 1,007, exceeding 1,000 by 7. Context was 30,920; combined 30,947;
projected total 89,900/99,500. The line body was not emitted or inspected. No
source patch was prepared; the remaining 26-token arithmetic allowance cannot
cover this selection. The explicit instruction prohibits another cap increase.
The validator finding at support line 394 remains unresolved, the bundle test
failed before report publication, and Task3/Plan03-05 remain blocked. Preserve
the exact owner-facing gap and recommend a separately authorized replan only if
the owner later wants to reopen this work.


## V17 final within-envelope reallocation — active; line 393 count pending

The owner authorized reallocating the remaining 500 global working tokens to
Task2. Active caps are context 38,500; Task1 22,000; Task2 source 1,500;
Task3 new source reads 0; output 5,000; cushion 2,000; reserve 31,000. Working
total is 69,000 plus reserve 31,000 = 100,000 exactly. The reserve is unchanged.
The V16 1,007-token selection failure and all earlier cap failures remain
historical. Preserve all 974 tokens of actual prior Task2 reads and do not
exclude any reread. Obtain fresh independent schedule review, execute preflight
and direct count for exact support line 393 before opening it. This is the final
available allocation; no further budget escalation is permitted.


### V17 correction to cumulative source ledger

Independent review correctly noted that V16 already counted the line393
selection as 33 tokens and recorded cumulative Task2 source as 1,007. The V17
fresh count must preserve that failed attempt and charge the new exact 33-token
selection again if unchanged: prior 1,007 + fresh span. The 1,500 cap can cover
both; there are 493 tokens available before the fresh selection. No reread is
excluded. The 31,000 reserve and 100,000 ceiling are unchanged.


### V17 line393 fresh count passed; count the full validator context next

The fresh V17 direct count passed: context 28,377; line393 33; combined 28,404;
cumulative Task2 source 1,040/1,500; projected total 87,390/100,000. Line393
was then inspected: `:ok = validate_aggregate_lane!(record)`. The line394
coverage assertion remains the failure. Before diagnosing or patching, count the
complete `validate_target_sources!/1` context including every reread; the prior
line393 and line394 reads remain charged. There is 460 tokens of source allowance
remaining.


### Final V18 validator-context count — pending

V17 line393 was read only after its fresh count. The active cumulative Task2 source baseline is therefore 1,040/1,500, leaving 460. The next exact selection is support lines 392–400, 382 bytes / `3776304570990785c8ab5dedb0ff3246321a9765f99a03411b396c4cb725c841`, full file 58,768 bytes / `54a0fa2ccc965bdad9cf1b2a1b5ce6c927a5b2b7b0eaa02fd54e119cb9f94b63`. It includes rereads of lines393–394; charge all span tokens again. Obtain independent metadata PASS, fresh execute preflight and count before opening the body. No source edit or output candidate before a complete passing count.


### V18 counted span was not the complete validator — stop before repair

V18 direct count passed for exact lines392–400 (111 tokens), bringing cumulative source to 1,151/1,500 and projected total to 87,948/100,000. That selection was then inspected. Metadata shows the validator continues through line476; unselected lines401–476 are 2,574 bytes / `6954af9f5ebb1bf4ca6e6c686794397d1da52a4fec28b047e5f7deaee54c9d06`, leaving only 349 Task2 source tokens. The remainder has not been token-counted or inspected. The current receipt does not authorize a correction because the complete validator context was not selected. Preserve the finding and candidate=null; no cap increase, report publication, or Plan03-05.


### V19 feasibility count failed — final source cap is exhausted

The fresh count-only request for exact support lines401–476 returned 618 tokens. Adding this to the 1,151 prior selected source tokens produces 1,769/1,500, exceeding the final cap by 269. Context 29,549 and projected total 89,291 pass; the Task2 source cap fails. The remainder was not emitted or inspected. No further budget reallocation is authorized. Preserve the line394 owner-facing gap and do not begin Plan03-05.


### V20 final within-ceiling reallocation — recount pending

The owner authorized shifting 1,000 tokens from context to Task2 source allowance. Active caps: context 37,500; Task1 22,000; Task2 source 2,500; Task3 reads 0; output 5,000; cushion 2,000; fixed reserve 31,000; total 100,000. V19’s 618-token count failed the prior 1,500 cap and remains historical. Current cumulative source selection baseline is 1,769; a fresh recount of lines401–476 is charged again and would yield 2,387 if unchanged. Obtain exact metadata review, execute preflight and fresh count before inspection. No further allocation increase, candidate output, report publication, or Plan03-05 until all gates pass.


### V20 fresh count passed; validator confirms unresolved source coverage

Under the final context37,500 / source2,500 allocation, the fresh 618-token remainder count passes with cumulative selected source 2,387/2,500 and total90,757/100,000. The complete validator was inspected only after the count. It intentionally guards `target_source_coverage_complete == true` and validates source mappings, gaps, per-identity statuses and source hashes. The failure exposes incomplete target-source evidence in the bundle input; it does not identify a narrow safe code correction. Task3 new source reads remain zero. Candidate null, no report publication, no Plan03-05.

## Owner-approved bounded target-source trace — original 99,500-token amendment, now historical

INT-20261115-01 records the owner's approval to trace why target-source coverage
is incomplete. This reopens only Task03-04-02 within the existing five-plan
Phase3; Task03-04-03 remains report-only and Plan03-05 remains dependent on
Plan03-04 completion. It supersedes earlier allocation/no-further-reallocation
statements for this continuation while preserving all earlier receipts and
failed selections as charged history.

The active hard allocation is context34,000 + Task1 source22,000 + cumulative
Task2 source5,500 + Task3 source0 + cumulative output5,000 + cushion2,000 =
68,500 working; fixed reserve31,000 gives99,500, with500 slack below100,000.
The V20 source baseline is2,387, leaving3,113 for the entire trace/correction,
including rereads, patch validation and required independent review. Continue
the existing output ledger; neither source nor output restarts at zero. The
five-exact-source-file and existing effort/review caps remain. Reconcile elapsed
recorded effort before execution; this approval does not invent a new effort window.

The trace starts from current core/floor/SIZING keyed projections and exact
record identities. Hash-bind complete affected target-source record,
association and typed-gap identity/key sets through compact manifests; do not
emit full lane arrays or treat counts/representative examples as coverage.
Schedule complete source derivation and acquisition spans for the coverage flag,
including required interfaces, before any body is emitted. Independent metadata
review, execute preflight and fresh direct context/span/combined count are
required after the final schedule/receipt/selected-input change. Metadata and
keyed record projections count against compact context; all source selections,
including failed attempts and rereads, count against cumulative Task2 source.

Use one bounded root-cause trace to distinguish missing static evidence from a
deterministic collector/bridge defect. Before longer selectors, run cheap JSON,
cross-file digest and coverage/gap consistency checks; validate candidate patch
applicability and syntax before counting/retesting it. A demonstrated narrow
defect requires valid selected-test RED then GREEN and current regenerated
lane/SIZING identities through existing write interfaces. Preserve the intended
complete-coverage validator, all original identities/provenance/gaps and every
static-only/collision/Macro/authority stop. No production, workflow, dependency,
guard-disposition or original-receipt changes are included.

Bounded exit: if required evidence is genuinely absent, a complete cause cannot
be established within the remaining source/output/effort limits, the repair
expands scope, or the existing independent review cap cannot clear it, record
the exact missing identities/provenance, consequence and remedy and stop.
Candidate stays null; no report publication, Plan03-04 completion or Plan03-05
start is permitted on that exit. If complete target-source inputs and all
correction gates are established, resume Task3 with zero new source reads and
its own fresh context count. This amendment is planning only and does not open
the execution body gate.

Coverage: this trace implements D-01/D-02 and GSR-01/GSR-03 by tracing the
authoritative lane provenance and existing collector; D-03/GSR-05 retain exact
gap/fit evidence and no candidate; D-04/GSR-06 preserve later owner authority.
GSR-02/GSR-04 exact membership, owners, partitions and historical delivery
receipts remain protected by unchanged Task1 and correction controls.

### Plan-checker scope repair — original SIZING ledger rebound, superseded after incident

The active SIZING budget now agrees with this replan: top-level and correction
schedule source_token_cap5,500; baseline/cumulative source2,387; remaining3,113;
context34,000; total99,500. Its prior V20 active allocation is copied unchanged
to historical_v20_reallocation, and v20_fresh_count_receipt is unchanged.
Candidate remains null. The active schedule/harness/projection hashes are null,
direct_count_pending is true and source_emission_authorized is false until
execution binds the exact current SIZING full hash and active-ledger projection
hash in independent schedule review and fresh direct counts. Task2 explicitly
requires this pre-emission ledger rebind/equality check; the planning change is
not a source-emission receipt.

## One-time budget recovery after unsaved source-search output

The next executor turn accidentally ran an `rg -n` search over
`test/support/guard_aggregate_reconciliation_evidence.ex` and
`test/contract/tier_sweep_test.exs` before its new schedule/count gate. The
output reported 10,353 tokens, was truncated, and was not saved; exact matching
lines and a content hash cannot be recovered. The executor stopped without
editing code or running tests. See `03-04-EXECUTION-INCIDENT.md` for the command,
scope, and accounting decision.

INT-20261115-02 supersedes INT-20261115-01's 100,000-token ceiling only for this
Phase 3 recovery. Charge all 10,353 reported output tokens conservatively to
Task 03-04-02 source usage, in addition to V20's preserved 2,387-token baseline.
The one-time active allocation is context34,000 + Task1 source22,000 + Task2
source16,000 + Task3 new source0 + output5,000 + cushion2,000 =79,000 working;
the fixed31,000 reserve yields a110,000 total ceiling. Task2's charged cumulative
source usage is12,740 and its remaining allowance is3,260. The five-file task
limit, output cap, effort/review limits, all evidence requirements and all
safety stops remain unchanged. Future work retains the100,000 ceiling.

This amendment is planning/accounting only. The exact schedule, independent
plan/schedule review, fresh execute preflight and direct count must bind the
incident charge and current SIZING hashes before any further source body is
emitted. Current schedule/review/count authorization is stale; the active body
gate remains closed. Candidate stays null, the report stays unpublished and
Plan03-05 stays unstarted.


## Current bounded trace stop after current-state count

The current-state schedule and metadata review passed, execute preflight passed, and the direct recount passed with context31,435 tokens, selected spans843, combined32,278 and projected total105,915/110,000. The scheduled helper spans were emitted once and checked with cheap JSON, full-record digest, identity-set and gap-consistency checks; no tests or code edits followed. See `03-04-BOUNDED-TRACE-STOP.md` for the exact findings and remedy.

Task2 usage is now15,308/16,000: V20 baseline2,387 + conservative incident charge10,353 + later selections882 +843 +843. Only692 tokens remain. Keyed target-source association/gap provenance and the coverage-flag caller remain unresolved, and the nested SIZING digest recipe is not established. Candidate remains null; implementation unauthorized; aggregate gate open; report unpublished; Plan03-04 incomplete and Plan03-05 unstarted. STATE changed after the count, so no further source body may be emitted without a new exact schedule, independent review, execute preflight and direct count. No automatic budget increase is authorized.

## INT-20261116-03 active metadata-only recovery route

This amendment replaces only pending Plan03-04 Task2/Task3 execution with a supplemental metadata handoff. Earlier source-trace schedules, count failures/passes and bounded stops above remain historical and unchanged. No source body is newly authorized. Completed Task1 is retained as historical evidence and is not rerun. The original source trace, corrected13MB reconciliation publication, GSR-03/GSR-05 acceptance and Plan03-05 remain blocked. Metadata-route completion is not Phase3 implementation/delivery completion. Phase4 and implementation remain unauthorized.

### Input discovery and dependency

Discovery level0: the route uses installed jq and Python standard library, existing retained metadata and no external library/API, source/code/test change, dependency or archive extraction. The plan preflight passed with no errors and route_phase03 on the existing phase branch. No graph/source discovery is needed for this metadata projection; existing source/graph limitations remain unknown.

Pending Task2 needs the unchanged lane files, SIZING statuses, bounded stop and owner intent; creates the supplemental index/receipt. Pending Task3 needs those outputs; creates the supplemental report/validation receipt. Execution stays wave4 after03-03, with both tasks serial within03-04. Completed Task1 is not rescheduled. No other plan or phase is added. Files modified by execution total4; each task owns2. Parent/orchestrator alone owns canonical STATE/ROADMAP/projection bookkeeping.

The calibrated incremental estimate is raw14,000 tokens ×0.5 =7,000, high confidence from19 samples. It is an estimate for the new route and does not replace measured historical ledger usage. Active caps remain context34,000; Task1 source22,000; cumulative Task2 source16,000; Task3 new source0; cumulative output5,000; cushion2,000; reserve31,000; one-time Phase3 ceiling110,000. Task2 remains15,308 charged/692 remaining. Both pending tasks have zero new source-body reads. Keep actual effort/review/output history and the3–4-hour/two-pass bounds; unknown or exhausted headroom is a stop, not permission to reset. Source-emission schedule/review/preflight/direct-count gates remain closed and unchanged.

### Grounded streamed identity projection

From repository root, for each CORE/FLOOR input use the installed jq projection: jq -cn --stream 'fromstream(2|truncate_stream(inputs | select(.[0][0]=="identity_rows"))) | {identity_id:.identity.id,owner:.identity.owner,baseline_mfas:.baseline_mfas}' followed by that lane-file path. Python consumes one output line at a time, preserving its enumeration index. This reconstructs one identity row at a time and emits only allowed metadata. Do not parse the complete lane document or print complete arrays/reports into context.

Planning baseline from that exact projection: each lane has226 identities; core has2,443 baseline tuples and floor2,354. Empty core lists: EX-097, CN-LANE-001, BD-LANE-001, BD-LANE-002, BD-LANE-003, BD-LANE-004. Empty floor lists: CN-001, EX-054, EX-076, EX-095, EX-116, EX-131, BD-033, CN-LANE-001, BD-LANE-001, BD-LANE-002, BD-LANE-003, BD-LANE-004. These are6+12 identity/lane unknowns, not eighteen invented MFAs or proven empty live sets.

Existing unkeyed observations remain separate: current reconciliation target_source_keys has452 identity/lane entries,450 empty and two populated EX-010 entries. SIZING has aggregate association counts1,844 core/1,802 floor and gap counts1,761 core/1,716 floor with nil reasons. These facts do not bind a gap reason or source identity to any particular baseline tuple. Do not distribute their counts across index keys or label unknown mapping as absent source. The metadata route need not parse the old report body; preserve its full-file digest.

### Supplemental row schema

Use schema_version string03-04.metadata-gap.1 on every JSONL row. Required keys:

| Field | Exact contract |
|---|---|
| record_type | known_target_gap or unknown_target_set |
| lane | core or floor |
| identity_id | Exact retained identity.id string |
| owner | Exact retained identity.owner value, including null if retained |
| identity_row_index | Zero-based index in that lane identity_rows |
| baseline_mfa_index | Zero-based baseline_mfas index for a known target; null for an unknown list |
| mfa | Exact three-element [module string,function string,integer arity] array; null only for an unknown target list |
| target_set_status | known for retained baseline tuples; unknown for empty retained lists |
| mapping_status | unresolved_mapping for every row |
| lane_input_sha256 | SHA-256 of the entire retained lane file |
| missing_fields | Nonempty list of explicit unresolved proof fields; no unsupported absence conclusion |
| reason | Nonempty typed reason: mapping_not_materialized_in_retained_metadata for a known tuple, target_list_not_established for an unknown list |
| remedy | Concrete bounded action needed to establish the missing association or target list; source work still requires unchanged gates and separate authority |
| direct_evidence_refs | Array of exact selected-function metadata references, or empty array; never a source/caller-completeness assertion |

Known rows should identify unresolved target-source association, lane-pinned source identity/provenance, relevant caller/delegate linkage and coverage-derivation/digest-recipe knowledge as applicable. Missing-fields language means unavailable mapping/proof, not absent source. For unknown-list rows require missing_fields to include target_mfa_list; do not attach a selected-function reference to MFA null.

The unique key is (lane,identity_id,mfa), with an identity-level null key for each unknown list. Preserve per-identity tuple membership; the same MFA under different identities is not deduplicated across owners. Any duplicate within the same exact key is a failure to resolve, not permission to discard a row. Do not treat baseline_mfas as a fresh live inventory or overwrite current/delivered/pending sets.

Each direct_evidence_refs item contains exactly selector, lane_input_sha256 and mfa. Selector format: /source_and_caller_evidence/selected_function_evidence/N, where N is the zero-based array index; its mfa must equal the row tuple, and its hash must equal that row lane_input_sha256. Scope is explicitly selected-function metadata only. Derive references by streaming selected-function MFA/index metadata; do not copy narrative source findings or infer identity binding from aggregate source keys/basenames. All missing association/caller proof and unresolved_mapping remain even when a reference exists.

### Supplemental receipt schema

03-04-METADATA-GAP-RECEIPT.json contains schema_version, status=bounded_no_candidate_metadata_only, input_files, preservation_manifest, row_schema, gap_index, limits, result and exact check commands/results. input_files has core/floor/sizing entries containing repo-relative path and full sha256. row_schema records all required fields, types, nullable rules, enums and direct-reference contract above. gap_index has repo-relative path, sha256, total_rows4815, known_target_rows4797, unknown_target_rows18 and per-lane counts.

preservation_manifest maps every protected repo-relative path to its pre-write full SHA-256. Include lane files, SIZING, original reconciliation/review, support/test files, bounded stop, execution incident, source schedules and independent schedule/direct-count receipts. Capture/check these through byte-stream digest operations only; do not decode/emit source bodies. Record current checkout branch/head and existing dirty state without staging or changing those files.

limits contains at least new_source_body_tokens=0, task2_source_charged=15308, task2_source_remaining=692, phase_ceiling=112915, working_cap=81915, reserve=31000, context_cap=33722, cumulative_output_cap=8193, incremental_work_cap=7000 plus Task1/Task2/Task3/cushion caps, actual remaining output/effort and review usage. Unknown actual headroom is a stop. result must equal candidate:null, implementation_authorized:false, aggregate_gate:open, gsr03_complete:false, gsr05_complete:false, phase4_authorized:false. Retain static-only/collision/Macro/wording/SEC-01/Walking Skeleton stops explicitly.

### Independent direct-reference verification

In addition to the runnable Task2 automated command, independently reconstruct the small selected-function MFA/index map by streaming only the selected_function_evidence path. For each row reference, parse selector N, look up the exact same-lane item N, compare its complete MFA tuple, compare full lane-file hash, and reject any malformed selector, duplicate reference, wrong lane, unknown-list reference or missing target tuple. Require every directly matching selected-function metadata entry to be represented once for each matching retained identity/MFA key; compare expected and actual reference maps exactly. Emit only a compact PASS/failure summary, never narratives or complete arrays. Record the actual executable Python/jq command and exit status in both receipts. This is metadata reference integrity, not source verification.

03-04-METADATA-GAP-VALIDATION.json contains status=pass_metadata_only only when checks row_schema, complete_key_equality, unknown_target_sets, direct_evidence_bindings, preservation_hashes and unchanged_limits are all true. Include index_sha256, receipt_sha256, report_sha256; source_proof=false, digest_recipe_established=false, caller_closure=false, gsr03_complete=false, gsr05_complete=false, phase4_authorized=false and candidate=null. Record exact commands/status, current branch/head, input hashes, all not-run limitations and remaining open review findings. Metadata PASS cannot close an existing code finding or discharge the source bundle gate.

### Multi-source coverage audit for the revised plan set

| Source | Item | Plan coverage | Disposition |
|---|---|---|---|
| GOAL | Complete two-lane join, source/caller inspectability, complement and measured candidate or exact gap |03-01–03-03 retained;03-04 Task2/Task3 supplemental known-key gap handoff;03-05 retained gate | Bounded no-candidate route covers exact-gap outcome; no full source-proof completion claim |
| REQ | GSR-01 current inventory/provenance |03-01 historical retained;03-04 receipt preserves input authority | Existing coverage preserved; metadata route is not fresh inventory |
| REQ | GSR-02 identity/MFA sets |03-02 historical retained;03-04 Task2 exact baseline-key equality and18 unknown sets | No loss/substitution; unknown target sets explicit |
| REQ | GSR-03 source/caller links or exact missing evidence |03-03 retained;03-04 Task2/Task3 mapping-unknown rows/remedies | Missing knowledge inspectable; source/caller acceptance remains incomplete |
| REQ | GSR-04 delivery and distinct partitions |03-01–03-03 historical retained;03-04 preservation manifest/report | Never combine/reopen delivered partitions |
| REQ | GSR-05 candidate fit or concrete gap |03-03 retained;03-04 unchanged ledger/no-candidate handoff | Sizing proof remains incomplete; no fabricated fit or reset |
| REQ | GSR-06 owner boundary and safety stops |03-04 Task3;03-05 retained/unstarted | No automatic Phase4/implementation |
| RESEARCH | Lane separation, exact equality, source authority, graph uncertainty, historical partition preservation |03-01–03-03 retained plus03-04 Task2/Task3 | Metadata route preserves all constraints; no new graph/source conclusion |
| RESEARCH | Exact measured caps, reserve, review/security and delivery gates |03-04 active limits and preservation receipt;03-05 retained | No tests/install/delivery claim; bounded stop retained |
| CONTEXT | D-01 machine-readable authority and inspectable complete rows |03-04 Task2 index and Task3 linked report | Every retained target plus18 unknown lists inspectable |
| CONTEXT | D-02 reuse narrow existing tooling; no framework/dependency |03-04 Task2 installed jq/Python only | No collector/code/test/lane change |
| CONTEXT | D-03 candidate only with proof, otherwise exact gap/remedy |03-04 Task2/Task3 | candidate null |
| CONTEXT | D-04 explicit later owner decision |03-04 Task3 | No later phase or implementation authority |

No source decision is silently dropped. INT-20261116-03 selects the gap-register outcome; this is not a waiver of GSR-03/GSR-05 or a fabricated completion. Product UI/brand/dogfood, runtime safety, source-proof expansion, dispositions and later implementation remain outside this route.

## Owner-authorized bounded continuation — INT-20261116-04

The owner authorized the metadata-only continuation verbatim: “- Authorize
the bounded continuation”. This adds up to7,000 incremental working tokens
and up to four active hours beginning2026-11-17T01:06:32Z. It supersedes the
prior110,000 ceiling and unknown effort remainder only for this supplemental
metadata gap register/handoff. It does not authorize source-body reads, code
changes, tests, implementation, Phase4, reserve consumption or later work.

| Component | Active cap or recorded use |
|---|---:|
| Compact context | 33,722 cap;31,435 recorded;2,287 remaining |
| Task1 source | 22,000 cap;21,172 recorded; no new reads |
| Task2 source | 16,000 cap;15,308 recorded;692 remaining but source gate closed |
| Task3 new source | 0 |
| Cumulative output | 8,193 cap;1,193 recorded;7,000 remaining |
| Cushion | 2,000 |
| Working cap | 81,915 |
| Fixed reserve | 31,000 |
| One-time metadata-route ceiling | 112,915 |

The working component caps sum to81,915; reserve remains31,000. Enforce the
7,000-token increment as a shared limit across new task context and emitted
output, in addition to each component cap and the total ceiling. Record the
exact context/output projection before writes and stop if the shared increment
or any component cannot fit. The active effort clock begins at the
authorization timestamp above and stops after four active hours; do not infer
or carry forward time from the earlier unrecorded window. Obtain independent
review of this revised numeric ledger and fresh execute preflight before
generating any index rows.

### Exit and next actor

After metadata validation, parent/orchestrator updates canonical handoff bookkeeping and reports the bounded no-candidate outcome. The owner acts only on a separately presented scope/phase decision if one is needed. The current source stop stays closed automatically; no confirmation is needed to preserve it. Before any authorized execution, run bin/planning_health --stage execute --phase 3; this is not source-read permission. Do not automatically start Plan03-05 or Phase4.
