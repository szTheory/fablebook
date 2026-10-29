# 0017. CI/CD: three workflows, one required gate, fast PRs, heavy release PRs

**Status:** Accepted · Amended 2026-10-28 (INT-20261028-18) · **Cites:** INT-20261028-01, INT-20261028-02, INT-20261028-04

## Context
- **CI bloat cost the owner the most time on earlier projects.** sigra grew to a 2,807-line `ci.yml` across 17 workflows. crosswake had 28 workflows.
- **The "lean" templates have drifted.** oarlock's `ci.yml` is now 490 lines with Node "proof" scripts. Its PLT cache never saves, because the restore key (`…-plt-…`, line 113) differs from the save key (`…-dev-test-…`, line 136).
- **sigra cut PR p50 from 27 to 8 minutes** by:
  - removing serializing `needs:` edges;
  - demoting pixel lanes;
  - caching browsers;
  - adding a composite setup action.

## Decision
### Workflows
- `ci.yml` (≤250 lines), `release-please.yml`, and `hex-publish.yml`. `hex-publish.yml` is the only publish code: `workflow_call` from release-please, plus `workflow_dispatch` for recovery, so the recovery path runs on every release.
- A test reading `.github/` enforces: exactly these 3 workflows, no Node outside E2E, and no phase-numbered tasks or workflows. The only reusable-workflow call allowed is from `release-please.yml` to `hex-publish.yml`.

### Workflow hygiene
- **Concurrency:** grouped by PR number with cancel-in-progress.
- **Triggers:** no trigger-level `paths:` filters.
- **Timeouts and permissions:** `timeout-minutes` on every job; default `permissions: contents: read`.
- **Pinning:** actions pinned to a SHA; images pinned by digest.
- **Setup:** one composite `.github/actions/setup`, with split cache restore and save, keyed on os, arch, OTP, Elixir and `hash(mix.lock)`. Saves happen on main only. The PLT gets its own correct key.
- **Repository settings:** immutable releases on, the default workflow token read-only, the Actions policy requiring full-length SHA pins, and a ruleset on `main` whose single required check is `ci-gate`.

### PR jobs (parallel)
| Job | Contents | Target |
|---|---|---|
| `core` | `mix ci` (format, `deps.get --check-locked`, `deps.unlock --check-unused`, compile with warnings as errors, credo, xref, tests including properties, perf, goldens and canon lints, `docs --warnings-as-errors`, `hex.build`, asset drift) | ~4 min |
| `floor` | `mix.floor.lock`, the prod guard, and a `--no-optional-deps` compile (folded in) | ~4 min |
| `dialyzer` | — | ~2 min warm |
| `e2e` | pinned Playwright container, operator host app, smoke tests plus visual-core; added later by changing `ci-gate`'s `needs` | ~5 min |
| `security` | `hex.audit`, dependency-review, actionlint, zizmor | ~1 min |
| `nightly` | in `ci-gate`'s `needs`; skipped on ordinary PRs, required on release PRs | — |
| `ci-gate` | `if: always()`; fails unless every job in its `needs` succeeded (skipped counts as failure, except `nightly` outside `release-please--` heads); the **only required check** | — |

- **PR wall-clock target:** p50 ≤ 7 min, p95 ≤ 10 min.
- **Agent merges** follow the all-checks merge rule: every check passes, only `nightly` and `ci-health` may be skipped, and `core`, `floor`, `dialyzer`, `security` and `ci-gate` are present and passing. The ruleset keeps one required check.

### Nightly, dispatch and release
- **Nightly / dispatch (same file):** the `nightly` job runs on its cron and on dispatch:
  - full sweep and visual set (≤400 renditions), Firefox and WebKit;
  - 10k property runs;
  - canary run against LiveView main and the latest `phx.new`;
  - the determinism self-test;
  - Muex and the bench weekly.

  A failure opens or updates **one** `quality-regression` issue.
- **`ci-health`** (weekly cron and dispatch; the only schedule-only job): posts PR p50/p95 on the pinned `ci-timing` issue, asserts the ruleset requires exactly `["ci-gate"]`, and re-runs the CI-shape test from main. Any failing step opens or updates `quality-regression`.
- **Release PR** (`head_ref` starts with `release-please--`): runs the nightly suite and is gated on it. Any open `quality-regression` issue blocks the release.
- **Release pipeline:**
  - release-please (elixir, `include-v-in-tag`, manifest `0.0.0`, `release-as: 0.1.0` for the first release only) runs with the fine-grained PAT `RELEASE_PLEASE_TOKEN` and no `GITHUB_TOKEN` fallback, because a `GITHUB_TOKEN` PR never triggers `ci.yml`.
  - Releases are drafts with `force-tag-creation` until build, publish, smoke and SBOM finish. Tag before publish so the docs `source_ref` resolves.
  - `hex-publish.yml` builds (the tag check, the release and prod-guard tests on the tag, `hex.build` with its sha256, a pre-publish smoke), publishes (environment `hex-production`, Hex client 2.6.0), runs the smoke consumer on the floor and latest lanes, then finalizes the release.
  - **Checksum idempotency:** publish is skipped when the same version and checksum are already on Hex and fails on a different checksum.
  - The gating `phx.new` smoke consumer replaces a scheduled post-release routine. The Igniter install step is `not-run` until the installer phase.
  - Use fork-safe `mix hex.build` on PRs.
  - Attach the SBOM, generated by the `erlef/mix_sbom` action, to releases.

## Amendments (release pipeline sign-off, 2026-10-28)
- **Publish code (D-08):** `hex-publish.yml` is the only publish code, called by release-please and dispatched by hand for recovery; the reusable call is allowed only from `release-please.yml` to `hex-publish.yml`. (INT-20261028-18)
- **Drafts (D-09):** releases are drafts with `force-tag-creation` until build, publish, smoke and SBOM finish, as immutable releases require. (INT-20261028-18)
- **Token (D-10):** release-please uses `RELEASE_PLEASE_TOKEN`, a fine-grained PAT, with no fallback. (INT-20261028-18)
- **Hex client (D-11):** pinned at 2.6.0, with the checksum idempotency rule. (INT-20261028-18)
- **SBOM (D-12):** the `erlef/mix_sbom` action replaces `mix sbom.cyclonedx`. (INT-20261028-18)
- **Smoke (D-13):** the gating smoke consumer replaces the bootstrap skill's scheduled email routine. (INT-20261028-18)
- **Repository settings (D-15):** immutable releases, a read-only default token, the SHA-pin policy and a ruleset with `ci-gate` only. (INT-20261028-18)
- **Security job (D-18, D-27):** `hex.audit`, dependency-review, actionlint and zizmor; `deps.audit` is dropped. (INT-20261028-18)
- **Job set (D-30, Pitfall 8 reading):** core, floor (with no-optional-deps folded in), dialyzer, security, nightly (in `ci-gate`'s `needs`, skipped allowed except on `release-please--` heads), ci-gate, and ci-health as the only schedule-only job; e2e arrives by changing `ci-gate`'s `needs`. (INT-20261028-18)
- **ci-health and nightly (D-20):** ci-health also re-runs the CI-shape test from main and files `quality-regression` when any step fails; nightly runs on its cron and on dispatch and files `quality-regression` on failure. (INT-20261028-18)
- **Merges (T-01-37):** agent merges follow the all-checks merge rule while the ruleset keeps one required check. The residual risk of a PR that neuters the core and floor test steps and ci-health's shape step is owner-accepted. (INT-20261028-18)
- **Reusable calls (Pitfall 7 reading):** the D-17 ban on `uses: ./.github/workflows/` applies to `ci.yml`; `release-please.yml` may call exactly `hex-publish.yml`. (INT-20261028-18)
