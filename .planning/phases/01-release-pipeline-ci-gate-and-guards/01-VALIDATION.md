---
phase: "1"
slug: "release-pipeline-ci-gate-and-guards"
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-28"
updated: "2026-10-30T02:19:42Z"
---

# Phase 1 validation strategy

Policy: INT-20261029-08 and `.planning/VERIFICATION.md`. Acceptance-to-evidence mapping and honest residuals: `01-UAT.md`.

| Boundary | Executable verification | Evidence |
|---|---|---|
| Clean dev/prod host, unguarded failure | `mix test --include prod_guard test/contract/prod_guard_test.exs` | Fresh mix ci; exact CI floor in run 40987211785 |
| Canonical CompileError | `mix test test/contract/prod_guard_message_test.exs` | Fresh mix ci |
| Eval/atom/source/style bans and reachability | `mix test test/contract/banned_calls_test.exs test/contract/tier_sweep_test.exs test/contract/style_attr_test.exs`; `mix credo --strict` | Fresh mix ci; Phase 01.1.1 verification |
| Dependency closure, package allowlist | `mix test --include release test/contract/dependency_budget_test.exs test/contract/tarball_test.exs` | Fresh mix ci; recorded release tag build |
| CI caps, pins, wiring and negative mutations | `mix test test/contract/ci_shape_test.exs` | Fresh mix ci; main CI |
| Git diff, intent and contract pairing | `mix test test/planning/intent_test.exs test/planning/contract_rule_test.exs` | Fresh mix ci; real red run 40802432347 |
| Release provenance and recovery | `mix test test/contract/hex_publish_test.exs` | Executes actual workflow shell steps with isolated external commands |
| CI timing, sample rules, drift, failure reporting | `mix test test/contract/ci_health_test.exs` | 13 seam tests; three caught mutations |
| Published artifact, docs, SBOM, consumer smoke | Read Hex API, HexDocs, GitHub release/run APIs | `01-LIVE-EVIDENCE.json`; release run 40803980465 |
| Weekly timing publication | Existing Monday ci-health job; read its run and issue #2 | First trigger 2026-11-02T05:23:00Z; pending scheduled observation |

Wave 0 infrastructure, helpers and fixtures all exist. Each task's recurring behavior has executable verification; existing core/floor lanes discover all tests. Run the targeted test after changes and `mix ci` before committing. The full local alias ran in about 49 seconds; network consumer checks remain in nightly/release lanes. Exact floor runtime is supplied by CI.

## Human-only verification

No new human UAT is required. Historical amendment/publication/key-rotation approvals are reused from INT sources and 01-05-SUMMARY. New visual baselines and unresolved product decisions still follow their existing owner gates. The weekly trigger is external evidence, not a manual-only check.

## Sign-off

- [x] All recurring acceptance criteria map to executable checks.
- [x] Bootstrap dependencies and fixtures exist.
- [x] No watch-mode commands.
- [x] Fast/full feedback stays inside the 120-second local budget.
- [x] Time-gated observations remain explicitly pending; automation is not equated with a passing observation.

Validation coverage is complete; phase acceptance remains partial until the scheduled observation and canonical execution re-verification are resolved.
