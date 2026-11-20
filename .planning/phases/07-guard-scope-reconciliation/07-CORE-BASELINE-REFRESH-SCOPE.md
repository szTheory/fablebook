# Fresh core baseline refresh scope

**Date:** 2026-11-20  
**Status:** In progress under the owner-authorized compiled-export route. R10 and R11 remain completed and spent; this route does not reuse them.

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

The earlier R11 and metadata-sufficiency findings remain accurate for those reviewed routes: the historic writer did not provide a safe reproducible path, and R10/R11 are spent. They are not reused. The owner later authorized completion of this milestone using a new, read-only compiled-export comparison with independent code and manifest reviews. This is a distinct operation and evidence generation.

Successful exit requires a fresh core export list bound to the current lock/runtime and a separate map of all 226 saved core rows. Floor is reused only from accepted ENV06 evidence after the exact floor lock and runtime are checked. The validator must bind every saved core live MFA to one current compiled module/package identity, keep floor provenance separate, preserve unresolved source gaps and the empty source-association set, and stop before family/schedule creation on any mismatch. The original whole-library membership list remains unavailable, so no exact historical whole-universe diff is possible. No target source body has been authorized by the inventory step; the later family and source schedule retain their own review and one-use gates. R9, candidate/implementation/gate stops, SEC-01 Pending, and Walking Skeleton blocked remain unchanged.

## Product-progress boundary

This scope repairs the evidence prerequisite only. It produces no applied brand canon, Fablebook Book, Logistify scenario, or runnable demo. Those remain downstream product work in the rolling roadmap.

## Later metadata-only route assessment (2026-11-20)

After the owner authorized autonomous completion of this milestone, independent reviewers identified a bounded route that did not exist in the earlier reviewed inputs: compare the 226 saved guard rows against the current compiled BEAM export lists. This does not reuse R10/R11, regenerate archived evidence, or read target source bodies. The historical whole-library record still has no old member list, so only exact guard-row differences can be reported.

The lane identity accepted by this phase is the exact package/release identity: full lock digest, pinned OTP/Elixir release and application versions, required runtime dependency closure, exact reviewed compiled-file manifest, and a digest of each file's canonical exported MFA list. The reviewed manifest records normalized asdf root locators, a hash of each resolved path, and root device/inode without exposing a developer's home directory. It does not hash the complete BEAM file. Source-file hashes and spans remain limited to a separately reviewed source schedule.

The revised plan now requires two distinct passes. First, produce a path-and-stat manifest without opening BEAM contents; a separate reviewer approves its exact digest and roots. Only then may the approved string-only parser read `Atom`/`AtU8` and `ExpT` from those listed files. It does not call `beam_lib`, create atoms from file contents, or read other chunk data. Dependency metadata names are validated before path use, every required Hex dependency must be accounted for, and metadata reads are bounded and checked for file changes. Debug information, abstract code, module loading, target-function calls, and target-source reads remain prohibited during inventory. The plan must pass independent review and the normal execute preflight before this route runs.

Supporting review: [current-lane comparison plan](07-SOURCE-BASELINE-UNBLOCKING-PROPOSAL.md). Primary references: [OTP 29 beam_lib documentation](https://www.erlang.org/doc/apps/stdlib/beam_lib.html), [OTP 29 compiler source](https://github.com/erlang/otp/blob/OTP-29.1.2/lib/compiler/src/beam_asm.erl), and [OTP 29 compiler release notes](https://www.erlang.org/doc/apps/compiler/notes.html).
