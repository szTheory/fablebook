# Phase 1: Release pipeline, CI gate and guards - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md. This log preserves the alternatives considered.

**Date:** 2026-10-28
**Phase:** 01-release-pipeline-ci-gate-and-guards
**Areas discussed:**
1. Prod guard and CI proof
2. Release pipeline
3. CI shape and intent guards
4. Code bans and dependency budget

**Mode:** advisor, at the `minimal_decisive` calibration. Midway through loading context, the owner asked for a deep fan-out across all relevant role lenses and for the recommendations to be adopted automatically (INT-20261028-17). Four `gsd-advisor-researcher` agents ran in parallel with an adversarial pass. The recommended option was adopted in every area, and no per-question prompts were asked.

---

## Prod guard and CI proof

| Option | Description | Selected |
|--------|-------------|----------|
| Decide in the macro body, raise in the returned quote | The prod expansion returns only the raise and touches no Book or options. Prototyped on 1.18 and 1.20. | ✓ |
| Return both branches and check at module-body time | Works, but expands route code and the Book reference in prod. | |
| Fixture `test/fixtures/prod_guard_host/` with a shared lock | Carries both cases, including the deliberately unguarded one. Runs on both lanes. | ✓ |
| Pull the `hosts/operator` skeleton into Phase 1 | Cannot carry the unguarded case, and grows the phase (logged as Q31). | |
| 0.1.0 = router macro, guard and placeholder plug | Ships exactly what the gate proved. | ✓ |
| 0.1.0 = name only | The guard would not be in the artifact. | |

**Choice:** the recommended options (auto-follow, INT-20261028-17).

## Release pipeline

| Option | Description | Selected |
|--------|-------------|----------|
| `hex-publish.yml` as the single publish path (call and dispatch), with draft-first releases | Recovery runs on every release, and the setup works with immutable releases. | ✓ |
| Inline publish plus a separate recovery workflow (oarlock) | Two implementations that drift apart; the recovery path is never exercised. | |
| `phx.new` smoke consumer in path and Hex modes, as a gate | Exercises the macro and the prod guard. | ✓ |
| `mix new` plus compile on a 24 h schedule (the skill's approach) | Gives a false green. | |
| `erlef/mix_sbom` GitHub Action | Adds no Hex dependency. | ✓ |
| `sbom` Hex dependency | Pulls in 4 transitive dependencies and needs an ADR. | |
| Open upper bounds, Phoenix floor 1.8.9, latest lane 1.20.4/OTP 29 | Owner sign-off needed (Q12). | ✓ |
| ADR 0007 as written | Blocks Phoenix 1.9 and LiveView 1.3. | |

**Choice:** the recommended options. Three findings drove them:
- The skill's `bump-minor-pre-major: false` would release 1.0.0 on the first breaking commit.
- A release PR opened with `GITHUB_TOKEN` never runs CI.
- GitHub rejects `timeout-minutes` on a job that calls a reusable workflow.

## CI shape and intent guards

| Option | Description | Selected |
|--------|-------------|----------|
| Restricted dialect plus a line scanner, actionlint/zizmor, and a GitHub ruleset | No dependency. A control outside the PR has the final word. | ✓ |
| Vendored YAML-subset reader | A YAML library in all but name. | |
| `git diff` against a base the PR cannot choose, plus git-free invariants | Fails closed on a shallow clone. | ✓ |
| Committed hash manifest | Can be regenerated in the same PR. | |
| `ci-health` scheduled job in `ci.yml` (p50/p95, ruleset drift) | Stays at 3 workflows. | ✓ |
| GitHub Insights metrics | No percentiles and nothing published. | |
| Contract-rule test reusing the diff seam, with a guard map | Runs locally and in CI. | ✓ |
| Shell step in `ci.yml` | Costs lines and doesn't run locally. | |

**Choice:** the recommended options. The contract-rule definition needs owner sign-off (Q15).

## Code bans and dependency budget

| Option | Description | Selected |
|--------|-------------|----------|
| Compiled-BEAM guard (gate) plus a name-based Credo check | Catches aliases, imports, `apply`, captures and macro bodies (prototyped). | ✓ |
| Credo only | `UnsafeToAtom` is off by default and alias-blind, and there is no eval check. | |
| `mix xref` or a compile tracer | Module granularity only; misses `apply` and dynamic calls (verified). | |
| `style=` source-text scan now; CSP receipt later | The only thing that can fail a PR in Phase 1. | ✓ |
| Dependency-budget walk of `hex_metadata.config` | The real adopter closure. | ✓ |
| `mix deps.tree --only prod` | False-fails on optional deps' subtrees (verified). | |
| `mix hex.audit` alone (Hex ≥ 2.5.1) | Checks advisories, with no YAML dependency. | ✓ |
| `mix_audit` / OSV-Scanner | YAML dependency / adds nothing for Hex. | |
| Explicit `files:` plus an unpacked-tarball test | Checks the real artifact. | ✓ |

**Choice:** the recommended options. The Q19 and Q21(b) refinements are logged as Q34.

## Claude's Discretion
- How the work is split into plans and their order (at most 5).
- The wording of the placeholder response and the moduledocs.
- Names of the `test/support` helpers.

## Deferred Ideas
- Trusted publishing.
- A runtime call trace of banned functions (Phase 5).
- Enforcing the recorded-output trailer.
- A doctor warning for `dev_routes` outside `dev.exs`.
- The operator nested-mount prod case.
- Fixing the bootstrap skill's `bump-minor-pre-major` setting.
