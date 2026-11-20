# Phase 7: current lane comparison plan

**Date:** 2026-11-20
**Status:** Safe technical route selected; the producer/validator and exact plan are under independent review. No compiled-file content has been opened in this route.

## The problem in plain English

Phase 7 needs to check whether the guard functions saved from the previous baseline still exist in the currently pinned core build. The saved whole-library record has a count and fingerprint, but not the old list of every function. Its separate guard record has 226 identity rows with lane-specific function references.

The old evidence writer stays unused. It can read installed OTP source and one path writes into archived Phase 3 evidence.

## Recommended route

Use a one-off Python reader built only from the standard library. The first pass reads project and toolchain metadata plus BEAM paths and file metadata; it opens no BEAM contents. After an independent review of the exact sorted manifest and root summary, a second pass reads only each listed BEAM's atom-name table (`Atom` or `AtU8`) and export table (`ExpT`). The parser keeps names as strings, verifies the saved module/function/arity references, and seeks over all other chunks. It does not use `beam_lib`, Erlang term readers, `Mix.Dep.Lock.read`, or any atom-creating parser on file contents.

The parser accepts only the pinned OTP 29.1.2 BEAM formats and fails closed on unknown encodings, malformed lengths, duplicate modules, unexpected roots, or changed file metadata. It hashes a canonical list of exported module/function/arity strings, not the whole BEAM file. This keeps debug information and source bodies out of the read path while avoiding another dependency.

The metadata pass uses bounded text parsers for `.app`, Hex metadata, and the pinned lock file. It binds the runtime dependency list to the reviewed `mix.exs` digest, requires and fully parses every dependency entry, validates dependency names before using them as paths, confirms each metadata path stays inside `deps`, includes only production runtime dependencies and required transitive packages, and excludes Fablebook and development/test-only packages. Any unsupported metadata shape or incomplete closure stops before a manifest is written. Resolved runtime roots are recorded as normalized asdf locators with path hashes and device/inode identity, not a developer's absolute home path.

## Reconciliation and evidence outputs

After the exports pass, a validator retains separate 226-row files for core and floor. It preserves every source row, each MFA field, and both raw lane-match arrays. It parses MFA strings by the module/function separator and final numeric arity, compares each saved field with the appropriate lane evidence, and records per-row present/missing memberships, known additions, removals, and unparseable values. Every saved core live MFA must resolve to exactly one fresh compiled module/package identity. The floor file is based only on accepted ENV06 rows and live source-gap selectors after its lock and exact runtime pins are checked; it is clearly marked as retained and not rescanned.

The validator produces separate core and floor row files, typed unresolved source gaps, an empty source-association file until reviewed observations exist, and a provenance manifest. It verifies every saved row pointer and every accepted ENV06 live selector; any mismatch, missing saved live MFA, or unparseable value stops before it defines a family or source schedule. The historical whole-library record cannot support an exact diff of the old 50,568-function universe; this route reports exact differences only for the saved guard rows.

If all 226 rows reconcile, Phase 7 may check the known EX-177 function family against current membership, then prepare its exact core/floor target and caller paths from the saved Phase 6 receipt. That family is evidence scope, not a code candidate. No target source body is read until the exact schedule, one-use requests, paths, and selectors pass independent review and approval.

## Safety and efficiency checks

- Add no dependency, build, recurring CI job, or runtime guard.
- Run the in-memory parser self-test and cheap schema/lock checks before manifest generation.
- Review the exact BEAM manifest and root summary before reading selected chunk data.
- Recheck file identity before and after every selected-chunk read. Do not write outside the active Phase 7 directory or through symbolic links.
- Never read source files, debug information, abstract code, other BEAM chunks, or archived evidence in the inventory operation. Never load a target module, call a target function, or use R9.
- Keep the accepted floor generation independently pinned and unchanged.

## What this can establish

If all identity and row checks pass, Phase 7 can compare the complete saved guard-row scope against the current core export set and accepted floor evidence, then continue its already-approved exact family, bounded caller/delegate observations, sizing refresh, and final recommendation.

It cannot recreate the historical whole-library member list, hash every source file, prove exhaustive caller closure, resolve the actual-library-collision stop, promote a code candidate, close the aggregate gate, authorize Walking Skeleton, or build the Logistify demo or product UI/Books. Candidate remains null, implementation remains unauthorized, SEC-01 stays Pending, R9 stays unconsumed/denied, and automatic follow-up stays off.

## Primary technical references

- [OTP 29 `beam_lib` documentation](https://www.erlang.org/doc/apps/stdlib/beam_lib.html) describes BEAM chunk identifiers, selected-chunk reads, and atom-valued export results.
- [OTP 29 compiler source](https://github.com/erlang/otp/blob/OTP-29.1.2/lib/compiler/src/beam_asm.erl) shows how the compiler writes the `AtU8` atom table and `ExpT` export entries.
- [OTP 29 compiler release notes](https://www.erlang.org/doc/apps/compiler/notes.html) document the long-atom format change that external readers must handle.
