---
phase: 03
plan: 03-03
date: 2026-11-15
status: compact-context-replan; source-read gate closed
---

# Plan 03-03 compact-context replan

## Preserved scope

The prior 70,000-token working projection plus the fixed 31,000-token reserve
totaled 101,000, over the 100,000 ceiling. A subsequent count showed the
selected context exceeded the earlier 46,000-token assumption, so that
assumption is withdrawn. This replan retains the existing two tasks, each
task's five exact-source-file cap, complete lane joins and complements, all
relevant target/caller/delegate evidence, review/fix/test gates, and every
safety stop. It adds no phase and grants no implementation authority. The
untracked failed `03-03-SOURCE-SCHEDULE.md` receipt remains unchanged.

Current source joins and caller coverage are incomplete; no candidate is
currently supportable. `candidate=null` with exact missing evidence and a
bounded remedy is a valid complete outcome. No caller, lane member, complement,
or other required evidence may be dropped to obtain a fit.

## Hard context envelope

| Component | Maximum tokens |
|---|---:|
| Hash-bound compact context bundle: necessary complete sections/excerpts, keyed lane/gap metadata, execution framing | 52,000 |
| Task 03-03-01 exact complete source spans, including spans reused by Task 2 | 10,000 |
| Task 03-03-02 new source-body reads; reuse Task 1 spans and persisted fit-interface notes | 0 |
| Generated output and bounded verification output | 5,000 |
| Post-count receipt/framing cushion | 2,000 |
| **Working envelope** | **69,000** |
| Fixed reserve | 31,000 |
| **Total hard ceiling** | **100,000** |

The 52,000-token context cap is an execution gate, not a target for removing
evidence. Task 2 reuses Task 1 source context and persisted fit-interface notes
with zero new source-body reads. Count Task 1 reads/rereads against its
10,000-token cap. Keep the five-file limit independently for both tasks; count
all actual source reads and rereads. Unknown measurements do not become zero.
If the complete required context, caller/delegate coverage, or source spans do
not fit these caps, preserve the full evidence gaps and replan; do not shave
evidence. A no-candidate result remains valid when evidence or fit is
incomplete.

## Compact context bundle contract

Before source-body emission, build a compact, hash-bound context bundle within
`03-03-EXECUTION-SOURCE-SCHEDULE.md`. Include only necessary complete sections
or excerpts: the Phase 3 goal and GSR-03 through GSR-06 requirements; D-01
through D-04 and active safety stops; current plan/phase status; the relevant
complete-join and source/caller-gap summary; fit-interface notes; and selected
keyed lane/gap metadata needed to preserve exact joins, selected sets,
complements, and caller/delegate coverage. Bind each excerpt to its source
SHA-256, inclusive line boundaries, and excerpt hash. Bind both full lane
records by digest and generation, but load only the required keyed metadata;
never include either full lane JSON body. Omit unreferenced extras.

Apply GSD's <500k read-depth rule to large summaries and verification
documents: use frontmatter/status and only a relevant complete section or
excerpt; never load full summary or verification bodies. If the necessary
complete sections and keyed evidence cannot fit 52,000 tokens, keep the source
gate closed and replan without dropping any required evidence.

## Keyed evidence projection

`03-03-KEYED-EVIDENCE.json` is a tracked measurement-support artifact used by
the count gate. It stores only the compact, hash-bound lane/gap metadata needed
to assemble and count the selected context while preserving exact joins and
complements. It contains no full lane arrays, complete lane record bodies, or
source bodies. It is not a new candidate, evidence source, or scope definition;
the original lane records remain authoritative. Include its digest and measured
token count in the compact-bundle manifest and direct count.

## Latest failed count and available hashes

The latest compacted request measured 61,264 context tokens plus 7,842 Task 1
scheduled source-span tokens; its reported combined count was 69,108 before
output, cushion, or reserve. This exceeds the 69,000 working ceiling. The
components sum to 69,106; retain 69,108 as the conservative reported count and
treat the two-token difference as unclassified overhead. A first payload count
of 2,928,884 included full lane evidence fields and is rejected as an invalid
payload for the intended keyed-metadata context.

The approved count-only method is `POST /v1/responses/input_tokens` for model
`gpt-6-luna`; no credential value is recorded here or in the schedule.

The count report did not include the serialized request-payload SHA-256. That
hash cannot be reconstructed without the exact request bytes; do not invent it
or include credentials. Available associated digests are: reviewed schedule
`71ddb7685be82515b838f0eefe72e9257dc62f989285e0370eeb390d1d5a38d4`; at-count
plan `8bd88bdc43bbbdf72b64178d883adc82b1c517696d7f9ab042a2ff794e628cf3`;
at-count replan
`030be19dcf9805b3083619f2014c9feb019153078a899d9b15cf1e863f088f99`; core
lane `ef5fb7e08ced66c8669d6c0896140d98c74186763561ab1a5cbe5358937a250a`;
floor lane `47e6b9137353d12396ece7e52f94fc904fdf2ef6ba6557dafb3a822f0ed5a121`;
and scheduled source/span hashes in `03-03-EXECUTION-SOURCE-SCHEDULE.md`.
The old plan/replan digests are historical because this amendment changes
those files. The next count must record each exact serialized request
SHA-256 with model and endpoint, without storing a credential.

## Source schedule and emission gates

Task 1 may use only complete, metadata-scheduled function/test spans in
`test/support/guard_aggregate_reconciliation_evidence.ex` and the required
regions of `test/contract/tier_sweep_test.exs`; never read or emit the full
756 KB test module. The schedule records exact path/file digest, complete
function/test identity, inclusive line boundaries, line/byte counts, and span
digest. Task 2 uses the Task 1 spans and persisted fit-interface notes; it
performs zero new source-body reads. A changed required file digest invalidates
the notes and closes the gate pending replan.

Before any source body is emitted, all of these must pass for the exact current
bundle, schedule, and payload:

1. Independent review approves the compact-bundle manifest and exact schedule.
2. `bin/planning_health --stage execute --phase 3` passes on the current tree.
3. A fresh direct combined count includes current bundle, schedule and review
   receipts, required spans, all remaining output, 2,000-token cushion, and
   31,000-token reserve; totals are at most 69,000 working and 100,000 overall.

Repeat the count after a plan, bundle, schedule, receipt, selected-input, or
source change and before any new emission. If context exceeds 52,000, a required
caller/span is missing, or a gate fails, emit no source body and replan without
evidence reduction.

## Token-count method and credential boundary

Prefer an already-installed, positively identified `tiktoken`
`o200k_base.encode_ordinary`. If unavailable, the only permitted fallback is
the owner-approved no-cost `POST /v1/responses/input_tokens` endpoint for model
`gpt-6-luna`, reusing only the existing ignored `.env.local` credential. Never
print or persist the key, use it elsewhere, create/rotate a key, install a
dependency, or call a generation endpoint. Record the model, endpoint, method,
redacted harness, response count, and SHA-256 of every exact serialized request
payload. If neither count method is available, leave the count unknown and keep
the source gate closed.

## Safety and authority unchanged

Keep all original evidence criteria, complete two-lane joins and complements,
full relevant callers/delegates, independent review, accepted-fix and retest
gates. Static-only proof, actual-library collision stop, Macro caller-AST and
wording checkpoints, aggregate open, Walking Skeleton blocked, SEC-01 Pending,
and `implementation_authorized=false` remain binding. No fit result changes
ownership, closes aggregate evidence, or authorizes later implementation.
No source body was read or emitted while preparing this replan.

## Independent second-amendment review — FAIL

**2026-11-15.** The revised envelope arithmetic is correct: 52,000 compact
context + 10,000 Task 1 spans + 0 new Task 2 body reads + 5,000 output + 2,000
cushion = 69,000 working tokens; adding the 31,000 reserve gives 100,000. The
compact-bundle contract retains GSR-03 through GSR-06, D-01 through D-04, active
safety stops, complete lane membership/complements, and caller/delegate
coverage. It excludes unreferenced context and the full test-module body.
Previous failed counts are preserved without inventing missing data: 61,264
context + 7,842 Task 1 spans was reported as 69,108 (the components sum to
69,106, with two tokens unclassified), the 2,928,884 full-evidence payload is
rejected, and the absent request-payload digest is explicitly unreconstructed.

Task 2 reuse is not executable as written. Both tasks modify
`guard_aggregate_reconciliation_evidence.ex` and `tier_sweep_test.exs`; Task 1
therefore changes the same file digests bound by its source schedule. Task 2
requires those digests to match the current tree, invalidates the notes if they
changed, and prohibits rereading under this plan. The planned Task 1 edits thus
predictably close Task 2's source gate. Before execution, the plan must define a
valid post-Task-1 context rebind path for Task 2, or another bounded route that
preserves its read and token limits. The compact-context review, fresh execute
preflight, and direct count remain separate gates; no source-body read is
authorized by this review.

## Follow-up amendment — Task 2 reuse path

The preceding FAIL receipt remains preserved as evidence of the earlier
non-executable handoff. The plan now defines a metadata-only post-Task-1 rebind
path while keeping Task 2 at zero new source-body reads:

1. Before Task 1 edits either implementation file, its schedule retains the
   original whole-file SHA-256 and every complete scheduled span's identity,
   boundaries, and SHA-256.
2. Task 1 persists fit-interface notes that cite those original span hashes,
   the SHA-256 of the exact binary patch for both implementation files, and
   the opaque post-Task-1 whole-file SHA-256 for each changed implementation
   file. Notes also retain the interfaces and insertion/behavior contracts Task
   2 needs; they do not
   replace complete source/caller evidence.
3. Before Task 2 uses the notes, it computes current whole-file SHA-256 values
   without loading either file body and compares each value with the recorded
   post-Task-1 digest. An independent reviewer checks the note bindings and
   hash comparison from metadata. Only if both current hashes match may Task 2
   rebind the notes to that exact current snapshot and use Task 1's code/test
   changes without semantic rereading.
4. A mismatch, missing digest, or failed review stops source-dependent Task 2
   work immediately. It causes no body read, automatic reschedule, or implicit
   expansion of the read/token caps; it requires an explicit bounded replan.

This path preserves 52,000 compact context + 10,000 Task 1 spans (including
all source context reused by Task 2) + 0 Task 2 body reads + 5,000 output +
2,000 cushion = 69,000 working tokens, plus the fixed 31,000 reserve = 100,000.
All prior source, caller/delegate, join/complement, review, test, and safety
gates remain unchanged. The compact-bundle review, fresh execute preflight,
and direct count remain independent prerequisites; this amendment authorizes
no source-body emission.

## Independent follow-up review — PASS

**2026-11-15; rebind contract only.** Task 1 now persists the original complete
span hashes, the exact binary patch hash for both implementation files, and
opaque post-Task-1 whole-file hashes. Before Task 2 uses the notes, it checks
current file hashes metadata-only, reuses the fit notes and Task 1 outputs
without semantic rereading, and stops on any missing or mismatched binding. An
independent reviewer must validate the bindings and comparison before rebind.
This closes the earlier planned digest-drift gap while keeping Task 2 at zero
new body reads.

The envelope still sums to 52,000 + 10,000 + 0 + 5,000 + 2,000 = 69,000,
plus the unchanged 31,000 reserve = 100,000. The compact context retains phase
requirements, D-01 through D-04, safety stops, complete joins/complements, and
caller/delegate coverage; it excludes the full test-module body. Prior failed
counts and the missing serialized-request digest remain recorded as facts,
without reconstructing or substituting values.

This PASS does not authorize source bodies. The compact-context schedule still
needs independent review, followed by fresh execute preflight and a direct
combined count that includes this receipt and the exact current payload.
