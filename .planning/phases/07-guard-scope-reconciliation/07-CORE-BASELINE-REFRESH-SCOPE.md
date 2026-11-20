# Fresh core baseline refresh scope

**Date:** 2026-11-20  
**Status:** R11 complete; no safe current-core generation path under the reviewed limits

## Purpose

Produce a new, immutable evidence generation that can establish current core-lane membership against the exact current core lock and pinned runtime. The accepted ENV06 generation remains unchanged historical evidence. The only proven lock delta is the Plug 1.20.3 to 1.20.4 security update; both pinned lane runtimes still match. The Plug diff explains the identity mismatch but does not make ENV06 a current-core inventory.

This is a metadata/evidence refresh only. It does not implement a guard, select or promote a candidate, close the aggregate gate, build a demo, or change any inherited safety stop.

## Fan-out synthesis

| Lens | Finding | Recommendation |
|---|---|---|
| Lane identity / security | The one-line Plug patch explains the full-lock mismatch; weakening the full digest would make the inventory ambiguous. | Bind a new core result to the current full lock and exact runtime. |
| Evidence provenance | ENV06 is immutable, has zero core target-source associations, and records source access closed; its old rows cannot establish current membership. | Create a separate current-core generation with its own producer and provenance; never relabel ENV06 rows. |
| Execution / gates | Old Phase 4 requests R1–R8 are spent and R9 remains denied. Phase 7 has its own exact schedule, independent review, execute preflight, and one-use gate. | Do not reuse any old request. Use a fresh ID only after its exact metadata producer and inputs are reviewed. |
| Product | This is guard-evidence work and cannot make the authored brands or a runnable demo visible. | Keep the refresh small; keep demo work in the downstream product roadmap. |

The independent reviews agree on the fresh-generation requirement. They differ on whether Phase 4's “no further source request” closes all later phases; the bounded interpretation is that it closes Phase 4/R1–R8 while v0.6 may use a new Phase 7 request only after its separate gates pass. R9 remains specifically denied and cannot be reused.

## Exact baseline contract

- Bind the new core record to current `mix.lock` SHA-256 `31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112`, `.tool-versions`, and the verified Elixir 1.20.4 / OTP 29.1.2 runtime.
- Reconstruct the complete relevant core identity and membership set under that identity, with provenance and reproducible row counts/digests. The historic ENV06 core record has 4,944 typed-gap rows but zero target-source association rows; it cannot serve as the fresh membership result.
- Bind the evidence producer too. R8 recorded `test/support/guard_aggregate_reconciliation_evidence.ex` at SHA-256 `734ec4f26aaae55a93ced922f72857471e899e63f0569c55339d0787b2402370`; the current tracked file is 86,693 bytes with SHA-256 `2b6eb2b1033ad429edc6f751ed2f55298a272610123085027c87ece59b379fdb`. The R8 hash does not match any of the 11 reachable revisions of that file. Git records later evidence-path/provenance changes, but this investigation did not read the helper body.
- Retain ENV06 byte-for-byte as the prior generation. Do not rewrite its lock fields, reuse its core rows as if current, or combine generation IDs. Keep the unchanged floor evidence separately pinned to its exact lock/runtime and validate it independently; do not merge it into the new core generation.
- Record producer identity, exact command/configuration, inputs, generation ID, lock/runtime pins, set counts, digests, and all unavailable fields. If the original producer cannot be identified and reproduced within the authorized boundary, stop; do not substitute an inferred command or manually relabel rows.
- Run cheap hash, toolchain, schema, membership, and provenance checks before any longer analysis. A mismatch stops before partitioning. Only after the fresh current-core membership and the independent floor check pass may Plan 07-01 calculate a family/complement.

## Source-access gate

The Phase 4 receipt records source access closed for that phase: R1–R8 are consumed, its handoff says no further Phase 4 source request, source emission, direct count, or source-body read was authorized, and the ENV06 manifest records `direct_count: not_run`. The owner selected a new v0.6 Phase 7 core-baseline scope, which permits fresh Phase 7 requests only through separate exact-scope gates. R9 remains specifically denied and unconsumed. R10 was the first new request; its output was incomplete. R11 is a new unique request for the same exact file and purpose, with a full-buffer transport to avoid output truncation.

A current-core membership refresh cannot be manufactured from the existing metadata alone, and the current producer revision differs from the saved R8 identity. R10 was reviewed and preflighted for one complete read of `test/support/guard_aggregate_reconciliation_evidence.ex` (86,693 bytes; SHA-256 above), but the tool returned only lines 1–437 and 1884–2357. Lines 438–1883 are missing, so the complete-file/no-truncation contract failed. No exact safe command or input closure can be established from this attempt.

The R11 request and revised five-plan reviews passed, the execute preflight passed, and the full helper was captured and analyzed. Its lane builder requires caller-supplied current-core membership maps, but this file defines no command or inputs that produce those maps. Its overlay route reads additional Phase 3/4 artifacts and uses runtime hashing, so the reviewed metadata-only generation path is not established. The owner then selected a read-only sufficiency check over the exact lock/toolchain and Phase 3/4/6 metadata named in Plan 07-01. That allowlist contains historical ENV06 rows and compact Phase 3/6 summaries, but no complete current-core maps; the association file is empty. See [metadata input sufficiency](07-CORE-METADATA-INPUT-SUFFICIENCY.md). Task 2 remains inactive; no generator may be inferred or improvised. R10 and R11 are spent. Further guard work would need a separately reviewed scope for exact additional inputs and operations, or a broader source/runtime boundary set by the owner.

## Decision and exit

The owner selected this refresh scope, so routine bounded work did not need repeated confirmation. The Phase 4 closure remains immutable for R1–R8. R10 was incomplete and is spent. R11 then captured the complete same helper file under its own PASS review and preflight. The complete analysis found no command or current-core input maps. The separately selected metadata sufficiency check then confirmed that the exact existing Phase 3/4/6 inputs do not provide those maps. No safe generation path is established under either reviewed boundary. Both producer request IDs are spent; neither may be reused.

Successful exit requires an immutable current-core generation with exact lane identity and complete relevant membership, independently validated floor identity, full provenance, and a passing membership validator. The reviewed producer path and selected metadata inputs did not establish that generation, so Plans 07-02–07-05 remain blocked. The next action is an owner decision whether to scope a separately reviewed exact input/operation boundary or retain the stop and redirect product focus. No new guard scope follows automatically. R9, all candidate/implementation/gate stops, SEC-01 Pending, and Walking Skeleton blocked remain unchanged.

## Product-progress boundary

This scope repairs the evidence prerequisite only. It produces no applied brand canon, Fablebook Book, Logistify scenario, or runnable demo. Those remain downstream product work in the rolling roadmap.
