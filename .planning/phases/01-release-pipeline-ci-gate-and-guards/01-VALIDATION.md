---
phase: "1"
slug: "release-pipeline-ci-gate-and-guards"
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
# audit-milestone §5.5 distinguishes NOT-VALIDATED (draft) from PARTIAL (validated + nyquist_compliant: false) (#2117)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-10-28"
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | ExUnit (Elixir 1.20.4 / OTP 29 latest lane; Elixir 1.18.5 / OTP 27 floor lane) |
| **Config file** | none yet. Wave 0 creates `mix.exs` (with `test_ignore_filters` and a `ci` alias) and `test/test_helper.exs` |
| **Quick run command** | `mix test` (fast guards; excludes `:prod_guard` and `:release`) |
| **Full suite command** | `mix ci` (adds `--include prod_guard --include release`) |
| **Floor command** | `FABLEBOOK_FLOOR=1 mix test --warnings-as-errors --include prod_guard` |
| **Estimated runtime** | quick ~10 s; full ~60 s warm (each prod-guard lane takes ~8 s plus fixture compiles) |

---

## Sampling Rate

- **After every task commit:** run `mix test`, plus the specific test file under work.
- **After every plan wave:** run `mix ci` locally, then push to the draft PR. CI is the real gate.
- **Before `/gsd-verify-work`:**
  - green `ci-gate` on PR #1;
  - the D-22 red-run link;
  - the release PR green, including `nightly`;
  - the hex-publish run link;
  - the follow-up PR that removes `release-as`, merged green.
- **Max feedback latency:** 120 seconds.

---

## Per-Task Verification Map

The planner fills Task IDs. Rows map requirements to the proving command (from 01-RESEARCH.md § Validation Architecture).

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| TBD | TBD | TBD | SEC-02 | prod exposure | False `dev_routes` mount compiles in prod; an unguarded mount raises the canonical error once; no routes, no story beams | integration | `mix test test/contract/prod_guard_test.exs --include prod_guard` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | SEC-02 | — | The CompileError's first line equals the Troubleshooting heading | unit | `mix test test/contract/prod_guard_message_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | SEC-01 (partial) | eval/atom DoS | No banned call or banned dep in `lib/` beams; 8 bypass fixtures fail | unit | `mix test test/contract/banned_calls_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | SEC-01 (partial) | — | Credo source bans | lint | `mix credo --strict` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | SEC-01 (partial) | CSP | No `style=` in `lib/` | unit | `mix test test/contract/style_attr_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | SEC-01 / SC4 | supply chain | Prod closure has no banned dep; direct deps exact; `only:` correct | unit | `mix test test/contract/dependency_budget_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | REL-01 / SC4 | PII, leaks | Tarball allowlist, metadata, PII scan | integration | `mix test test/contract/tarball_test.exs --include release` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | CI-01 | workflow tampering | Caps, ci-gate, pins, bypass bans, no Node, no phase names | unit | `mix test test/contract/ci_shape_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | CI-01 | template injection | Workflows lint clean | lint | actionlint and zizmor in the `security` job | n/a | ⬜ pending |
| TBD | TBD | TBD | INTENT-01 | — | Add-only sources, INT id form, REQ citations, ADR existence | unit | `mix test test/planning/intent_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | D-21 (Q15) | guard weakening | A guard `M`/`D` plus its paired implementation in one PR fails | unit | `mix test test/planning/contract_rule_test.exs` | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | COMPAT floor | — | The floor lane really resolves Phoenix 1.8.9 / LiveView 1.2.9 | unit | `FABLEBOOK_FLOOR=1 mix test test/contract/dependency_budget_test.exs` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `mix.exs`, `.formatter.exs`, `mix.lock`, `mix.floor.lock`, `test/test_helper.exs`: framework bootstrap. `test_ignore_filters` must be set before the first `mix test --warnings-as-errors`.
- [ ] `test/support/mix_cmd.ex`, `test/support/git_diff.ex`, `test/support/beam_walker.ex`: shared helpers.
- [ ] Fixture directories `test/fixtures/prod_guard_host/`, `test/fixtures/guards/` and `test/fixtures/ci_shape/`.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| 0.1.0 is on hex.pm via release-please, with smoke, recovery and SBOM | REL-01 | Needs real GitHub and Hex runs and human-held credentials | Link the hex-publish run, the hex.pm page, and the release asset `fablebook-0.1.0.cdx.json` |
| Weekly p50/p95 published | CI-01 | Needs real CI history and a scheduled run | Dispatch `ci.yml` (`ci-health`); link the run and the `ci-timing` issue comment (`not-run (n=K)` is acceptable while n<10) |
| Ruleset requires exactly `ci-gate` | CI-01 | A GitHub-side setting | `ci-health` drift-check link |
| An edited INT source fails real CI | INTENT-01 | Proves the wiring, not the fixture | Red-run link from a throwaway draft PR, closed unmerged (D-22) |
| Owner sign-offs (D-12, D-16, D-21, D-26/27, D-31) | — | Owner decisions | Signed ADR amendments and struck OPEN-QUESTIONS rows |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
