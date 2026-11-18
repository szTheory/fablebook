# Plan 03-04 Task 2 bounded trace stop

## Gate record

- Current-state schedule: `03-04-EXECUTION-SOURCE-SCHEDULE-RECOUNT.md`, SHA-256 `1bd31ee4c2f28356094de9e51c380a16937a7d24fb0d60724dbf82922196d4fa`.
- Bound STATE before recount: SHA-256 `003a4c427b0ecadc92cba612b862df0ba5bf908748961cdbb9f5171c13d65def`.
- Independent metadata review passed; fresh `bin/planning_health --stage execute --phase 3` passed.
- Direct count used only the approved no-cost input-token endpoint; no generation endpoint.
- Context: 102,046 bytes, SHA-256 `ccc41bc381bd6cfaac5a6a1b26ac884ba4c3be61f44e0492271d654bbbd5107b`, 31,435 tokens.
- Exact two-span selection: 3,399 bytes, SHA-256 `d4b3318e7bac3114d65fde8acda9607346a12b99a863cad1e1ef0a8fc3fed5cd`, 843 tokens.
- Combined context and selection: 105,482 bytes, SHA-256 `d4f506338a55faa555347de2c9f1e994ab4f34a6e4fb48d124cb6cf5268d496e`, 32,278 tokens.
- Task 2 charged 14,465 before this selection. Charge 843: cumulative 15,308/16,000, 692 remain. Task 1 remains 21,172/22,000; Task 3 new reads remain zero; output remains within the 5,000 cap (1,193 previously used); cushion 2,000 and reserve 31,000 are preserved. Projected total is 105,915/110,000.
- Only `target_source!/5` (lines 1495–1585) and `source_key_index!/2` (lines 1586–1592) from the bound source file were emitted once. No other source span, implementation, report, candidate, or test was touched.

## Trace and cheap consistency results

The selected helper resolves a source by exact MFA against `selected_function_evidence`, then filters exact source paths by module basename. It accepts a source only when the citation, review metadata, and exactly one lane/path/digest/byte-matching archive row agree. It otherwise returns a gap keyed by lane, identity ID, and MFA with a reason and remedy. The key index resolves a source key back to identity/MFA and raises if no association exists. This describes the helper's behavior; it does not establish why the caller's current coverage flag or source inputs are incomplete.

Cheap checks after the batch:

- Core/floor/SIZING JSON parsed successfully.
- Both complete lane-file digests match the digests recorded in SIZING.
- Each lane has 226 unique identity IDs, and the core/floor sets are equal; the exact sorted set remains in `03-04-TASK2-GATE-STOP.md` (2,060 bytes, SHA-256 `4277d546a212f99f36b9a3b113d80902e71b4bff5e4f89cd0c6429fda4017d67`).
- Both lane `source_join_complete` values are false; SIZING `evidence_complete` is false, candidate is null, and its global gap is `target_source_and_caller_evidence_incomplete`.
- Each lane's source/caller evidence currently contains 2 selected-function entries, 3 exact-source entries, 3 reviews, 2 matched MFAs, 2 delegate edges, and 0 remainder MFAs.
- SIZING records target-source association counts of 1,844 (core) and 1,802 (floor), and target-source gap counts of 1,761 and 1,716 respectively. The lane evidence records contain no keyed target-source association or gap rows. SIZING reports `target_source_coverage_complete=true` for each lane while also recording nonzero target-source gap counts with `nil` reasons. The summary counts/hashes do not expose identity-to-source or identity-to-gap mappings, so this apparent flag/gap tension is unresolved rather than treated as proof of a defect.
- Required evidence gap counts remain 5,287 (core) and 5,152 (floor), covering unreviewed callback/delegate provenance, missing current graph reconciliation, and missing selected graph observations. Their keyed rows are not materialized in the current lane package.
- The full lane-record digests stored in SIZING match. An exploratory attempt to recompute SIZING's nested `identity_rows` and `source_and_caller_evidence` digests using a simple canonical JSON serialization did not match those nested values; that attempt did not establish the required selector/encoding, while the independently reviewed compact projection hashes do match. Treat those nested digest recipes as unresolved and reconcile them before claiming the cross-record subprojection check passes.

## Stop and remedy

The complete cause is not established. The emitted helper cannot identify which of the complete 226-ID set lacks a current lane-pinned source record, association, or typed gap because the current package retains only aggregate counts/hashes for those records. The next required source spans are the caller/coverage-flag derivation and the acquisition inputs that produce keyed source associations and gaps; those were not part of the authorized two-span batch. Only 692 Task 2 source tokens remain, and no further selection is presumed to fit. Do not perform an unreviewed selector or request an automatic budget increase.

Bounded remedy: preserve all 226 IDs and supply/derive complete lane-pinned target-source association and gap rows with identity ID, MFA, relative path, bytes, digest, repository ref, lane lock, archive row, citation/review provenance, status, reason, and remedy. Then trace the coverage-flag caller against those complete keyed rows within the remaining approved budget, using a newly reviewed schedule, fresh execute preflight, and fresh direct count. If the complete trace cannot fit, return the exact missing keys and consequences to the owner for a new scope decision.

Candidate remains null; implementation remains unauthorized; aggregate gate remains open; the corrected report remains unpublished; Plan 03-04 and Plan 03-05 remain incomplete/unstarted. Static-only, collision, Macro, authority, and aggregate stops remain binding. No tests were run and no code was changed.
