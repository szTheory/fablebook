---
phase: 01-release-pipeline-ci-gate-and-guards
review: 01-REVIEW.md
recorded: 2026-10-29
---

# Phase 1: Code review disposition

| id | severity | finding | disposition | note |
|----|----------|---------|-------------|------|
| CR-01 | critical | `apply(String, :to_atom, ...)`, `apply(List, :to_existing_atom, ...)` and `Function.capture/3` bypass both ban layers | open | Undermines success criterion 4; gap closure (contract-test edit only, no `lib/`) |
| WR-01 | warning | Path-dep host routers compile Fablebook's macro in `:prod`, so a correct dev mount fails | open | Owner question next to Q32; docs at minimum |
| WR-02 | warning | `mix.exs` text scan misses qualified calls (`Code.eval_string`) | open | Credo still covers `mix.exs` |
| WR-03 | warning | `:erlang.load_module/2`, `Kernel.ParallelCompiler.*`, `:code.load_abs` not banned | open | Gap closure with CR-01 |
| WR-04 | warning | Contract-test rule does not pair `test/support/`, `test/fixtures/`, `credo/`, `.credo.exs`, `test_helper.exs` | open | Widening changes D-21; needs owner sign-off |
| WR-05 | warning | `hex-production` accepts any pushed `v*` tag; tag not checked to be on `main` | open | Settings plus workflow change; gap closure |
| WR-06 | warning | Recovery after a docs-only publish failure never converges | open | Gap closure |
| IN-01 | info | Floor-version test reports pass when it did not run | open | Honesty rule (ADR 0010) |
| IN-02 | info | `bin/smoke_consumer` prod route check lacks a positive control | open | |
| IN-03 | info | ci-gate step content checked by substring only | open | |
| IN-04 | info | `HEX_API_KEY` exposed to the whole publish job | open | |
| IN-05 | info | Credo ForbiddenModule misses some alias forms (BEAM layer catches them) | open | |
