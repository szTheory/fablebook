# EX-177 source discovery — 2026-11-19

**Status:** bounded static discovery complete. This is a new research record under [INT-20261119-01](../intent/sources/2026-11-19-01-authorize-bounded-source-discovery.md); it does not rewrite Phase 5's historical result or consume R9.

## Scope

The lookup stayed within the four existing Phase 5 keys for `Elixir.Mix.Tasks.Phx.Gen.Context.prompt_for_code_injection/1`: source and caller on core and floor. The other 9,712 rows remain the unchanged pending complement. No package-wide caller search, audited API call, runtime evaluation, callback, test, or suite was run.

## Lane and source identity

| Lane | Runtime pin | Phoenix pin | Exact source file | Bytes | SHA-256 |
|---|---|---|---|---:|---|
| Core | Elixir 1.20.4 / OTP 29.1.2 | Phoenix 1.8.16 from `mix.lock` | `_build/lanes/core/deps/phoenix/lib/mix/tasks/phx.gen.context.ex` | 14,760 | `c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e` |
| Floor | Elixir 1.18.5 / OTP 27.3.4.9 | Phoenix 1.8.9 from `mix.floor.lock` | `_build/lanes/floor/deps/phoenix/lib/mix/tasks/phx.gen.context.ex` | 14,760 | `c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e` |

Both installed package `mix.exs` versions match their lane lock entries. The exact target files have identical byte counts and hashes even though the locked Phoenix versions differ.

## Observed spans

- The complete `prompt_for_code_injection/1` definition is lines 445–451 in each lane file.
- One direct call is observed at line 131 inside `run/1`, whose containing function spans lines 112–136 in each lane file.
- The function returns immediately when code generation is disabled. In the generation path, it checks whether the context already exists and whether the user elected to merge; a rejected merge path halts. This is a static description only; the function was not invoked.

An independent reviewer confirmed the package versions, source hashes, definition span and observed call span. The lookup read the two lane-specific target files and their two lane-specific package-version declarations; it did not scan other Phoenix files. Consequently, the observed `run/1` call does not prove that every direct caller is known. External callers, dynamic edges, callbacks and delegates remain open.

## Handoff

The missing source path, package version and target span are now discoverable from the pinned lane checkouts. This does not retroactively close the four Phase 5 gap records, establish complete caller closure, select an implementation candidate, or change any safety status. R9 remains denied and unconsumed. Phase 5's saved validator was not rerun because its append-only delivery-registry input changed after merge; its historical passed result remains preserved.

Phase 6 is not in the active v0.4 roadmap, so no phase plan or execution was created. The next lifecycle action is to complete the v0.4 boundary, then plan any follow-up under a newly activated bounded scope. The aggregate gate stays open, candidate stays null, implementation remains unauthorized, and Walking Skeleton remains blocked.
