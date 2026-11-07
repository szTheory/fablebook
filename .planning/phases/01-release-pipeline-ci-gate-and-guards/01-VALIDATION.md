---
phase: "1"
slug: "release-pipeline-ci-gate-and-guards"
status: validated
nyquist_compliant: true
wave_0_complete: true
created: "2026-10-28"
updated: "2026-11-07T08:24:41Z"
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
| Weekly timing publication | Existing Monday ci-health job; read its run and issue #2 | Scheduled run 41393964754 completed on 2026-11-02 and published n=78, p50 77 s, p95 754 s; timing overages remain tracked separately |

Wave 0 infrastructure, helpers and fixtures all exist. Each task's recurring behavior has executable verification; existing core/floor lanes discover all tests. Run the targeted test after changes and `mix ci` before committing. The full local alias ran in about 49 seconds; network consumer checks remain in nightly/release lanes. Exact floor runtime is supplied by CI.

## Human-only verification

No new human UAT is required. Historical amendment/publication/key-rotation approvals are reused from INT sources and 01-05-SUMMARY. New visual baselines and unresolved product decisions still follow their existing owner gates. The weekly trigger is external evidence, not a manual-only check.

## Sign-off

- [x] All recurring acceptance criteria map to executable checks.
- [x] Bootstrap dependencies and fixtures exist.
- [x] No watch-mode commands.
- [x] Fast/full feedback stays inside the 120-second local budget.
- [x] Timing observations are recorded separately from release gates; overages remain non-blocking operational follow-up.

Validation coverage is complete. The scheduled observation is recorded, timing objectives remain non-blocking, and canonical Phase 01 verification passed with no remaining gaps.

## CR-01 scoped reconciliation (2026-11-06T03:15:28Z)

Receipt: `01-06-ATOM-EVIDENCE.json`

| Atom/source slice | Exact checks | Evidence |
|---|---|---|
| CR-01 literal-dispatch fixtures and source/name/MFA parity | Four fixture cases plus one source/parity case on both exact lanes | `01-06-ATOM-EVIDENCE.json`; implementation history in [01.1-01-SUMMARY.md](../01.1-close-phase-1-guard-gaps/01.1-01-SUMMARY.md) and [01.1.1-05-SUMMARY.md](../01.1.1-close-the-eval-and-code-loading-ban-list/01.1.1-05-SUMMARY.md) |

The receipt is the current scoped evidence for this atom/source row; prior validation receipts remain historical. It does not establish the installed-wide aggregate, hosted CI timing, or canonical full-phase acceptance.

Runtime core: Elixir 1.20.4; OTP 29.1.2.
Runtime floor: Elixir 1.18.5; OTP 27.3.4.9.
Command core: `MIX_ENV=test bin/lane core test --warnings-as-errors --trace --no-color --only fixture:apply_to_atom.ex --only fixture:apply_list_existing_atom.ex --only fixture:function_capture_to_atom.ex --only fixture:erlang_apply_to_atom.ex test/contract/banned_calls_test.exs`
Command floor: `MIX_ENV=test bin/lane floor test --warnings-as-errors --trace --no-color --only fixture:apply_to_atom.ex --only fixture:apply_list_existing_atom.ex --only fixture:function_capture_to_atom.ex --only fixture:erlang_apply_to_atom.ex test/contract/banned_calls_test.exs`
Command core: `MIX_ENV=test bin/lane core test --warnings-as-errors --trace --no-color test/contract/banned_calls_test.exs:1915`
Command floor: `MIX_ENV=test bin/lane floor test --warnings-as-errors --trace --no-color test/contract/banned_calls_test.exs:1915`
Issue #37: state=open; observed_at=2026-11-06T03:16:27Z; source=https://github.com/szTheory/fablebook/issues/37; read-only; no issue writes or dispatch authorized.

CR-01: closed by scoped evidence; canonical Phase 1 re-verification remains open.
SEC-01: Pending; completion owner: Phase 5.
Phase 01.1.1.1 aggregate audit: open.
Phase 2 gate: open.
Story-beam caveat: open; owners: Phase 2 and Phase 10; no universal adopter enforcement claimed.
CI timing acceptance: open; issue state alone supplies no budget acceptance.

The scoped atom evidence is reconciled. Full canonical Phase 1 re-verification remains the orchestrator's next action; the aggregate and timing gates remain open.

## Validation Audit 2026-11-06

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |

## Plan 01-09 validation reconciliation (2026-11-06T16:51:15Z)

Receipt: `01-09-TIMING-CLOSURE.json`

| Boundary | Executable verification | Evidence |
|---|---|---|
| Strict timing classification and release-guard controls | `MIX_ENV=test bin/lane core test --warnings-as-errors test/contract/ci_health_test.exs test/contract/ci_shape_test.exs test/planning/contract_rule_test.exs test/planning/intent_test.exs` | 115 passed on deployed main `91e08e5d`; PR #53 hosted run 42250970487 passed core, floor, dialyzer, security and ci-gate. |
| Floor timing contract | `MIX_ENV=test bin/lane floor test --warnings-as-errors test/contract/ci_health_test.exs` | 24 passed; PR #53 hosted floor check passed. |
| Live report and sample provenance | `bin/ci_health --dry-run`, then one normal invocation on the exact deployed script digest | n=51, p50 543 s, p95 783 s; the 420/600 s targets remain visible; report comments on #2 and #37 match the invocation. Dry-run audit recorded no issue access. |
| Issue migration and real release guard | Read full #37 history and inventories; execute `.github/workflows/ci.yml` guard body against saved live and synthetic inventories | #37 is open under ci-performance only; current performance-only inventory passes, while synthetic genuine-quality and mixed inventories block. All guard writes were intercepted. |

The four separate PRs are recorded with path inventories and hosted CI URLs in the receipt. Timing remains an operational objective and does not block by itself. This scoped validation closes G-01-15 only; canonical Phase 01 verification remains pending.

## Contract scanner compatibility reconciliation (2026-11-07)

PR #73 added regression coverage for YAML-looking content inside quoted scalar values, including block-header text, same-line anchor/merge markers, detached quoted values, and quoted mapping keys. The focused `test/contract/ci_shape_test.exs` suite passed 84 tests. Hosted run 42354468061 passed core, floor, dialyzer, security, and ci-gate; ci-health and nightly were skipped as designed. Its 605-second feedback time exceeded the 600-second p95 objective by five seconds and is recorded as non-blocking timing telemetry in `01-09-TIMING-CLOSURE.json`.

This updates validation evidence for CI-shape scanning; it does not change Phase 5 ownership of full SEC-01 completion or the later phases' aggregate and adopter checks.

## Canonical Phase 01 verification (2026-11-07)

The final report in `01-VERIFICATION.md` passed all 9 roadmap-derived truths, honored 31/31 trackable decisions, and found no remaining gaps, regressions, or human checks. Phase 01 completion is recorded in `ROADMAP.md`; Phase 01.1 remains unstarted pending the owner's next instruction.
