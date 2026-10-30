---
phase: 01-release-pipeline-ci-gate-and-guards
review: 01-REVIEW.md
recorded: 2026-10-29
---

# Phase 1: Code review disposition

| id | severity | finding | disposition | note |
|----|----------|---------|-------------|------|
| CR-01 | critical | `apply(String, :to_atom, ...)`, `apply(List, :to_existing_atom, ...)` and `Function.capture/3` bypass both ban layers | fixed | Phase 01.1 literal-dispatch fixes and Phase 01.1.1 regression verification; fresh 257-test mix ci. Do not reopen without a new reproduction. |
| WR-01 | warning | Path-dep host routers compile Fablebook's macro in `:prod`, so a correct dev mount fails | open | Owner question next to Q32; docs at minimum |
| WR-02 | warning | `mix.exs` text scan misses qualified calls (`Code.eval_string`) | fixed | Phase 01.1.1 SC6 source AST coverage over mix.exs; apply/alias/newline fixtures pass. |
| WR-03 | warning | `:erlang.load_module/2`, `Kernel.ParallelCompiler.*`, `:code.load_abs` not banned | fixed | Phase 01.1 and 01.1.1 tier expansion, fixtures and generated probes; broader transferred audit remains Phase 01.1.1.1. |
| WR-04 | warning | Contract-test rule does not pair `test/support/`, `test/fixtures/`, `credo/`, `.credo.exs`, `test_helper.exs` | open | Widening changes D-21; needs owner sign-off |
| WR-05 | warning | `hex-production` accepts any pushed `v*` tag; tag not checked to be on `main` | partially fixed | Main-commit provenance fixed in PRs #10/#12/#13 and current release seam tests; distinct deployment-policy question Q37 remains open. |
| WR-06 | warning | Recovery after a docs-only publish failure never converges | fixed | Docs-only todo=docs recovery in Phase 01.1; actual workflow step behavior pinned by hex_publish_test.exs. |
| IN-01 | info | Floor-version test reports pass when it did not run | open | Honesty rule (ADR 0010) |
| IN-02 | info | `bin/smoke_consumer` prod route check lacks a positive control | open | |
| IN-03 | info | ci-gate step content checked by substring only | open | |
| IN-04 | info | `HEX_API_KEY` exposed to the whole publish job | fixed | HEX_API_KEY is confined to the key check and gated publish step; Phase 01.1 and current workflow contracts. |
| IN-05 | info | Credo ForbiddenModule misses some alias forms (BEAM layer catches them) | open | |

Reconciled 2026-10-30 against merged follow-up phases and `01-UAT.md`. Remaining owner questions stay in OPEN-QUESTIONS.md; no repeat sign-off is requested here.
