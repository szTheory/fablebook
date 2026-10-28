# 0017. CI/CD: three workflows, one required gate, fast PRs, heavy release PRs

**Status:** Accepted · **Cites:** INT-20261028-01, INT-20261028-02, INT-20261028-04

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
- `ci.yml` (≤250 lines), `release-please.yml`, and `hex-publish.yml` (manual recovery).
- A test reading `.github/` enforces: exactly these 3 workflows, no Node outside E2E, and no phase-numbered tasks or workflows.

### Workflow hygiene
- **Concurrency:** grouped by PR number with cancel-in-progress.
- **Triggers:** no trigger-level `paths:` filters.
- **Timeouts and permissions:** `timeout-minutes` on every job; default `permissions: contents: read`.
- **Pinning:** actions pinned to a SHA; images pinned by digest.
- **Setup:** one composite `.github/actions/setup`, with split cache restore and save, keyed on os, arch, OTP, Elixir and `hash(mix.lock)`. Saves happen on main only. The PLT gets its own correct key.

### PR jobs (parallel)
| Job | Contents | Target |
|---|---|---|
| `core` | `mix ci` (format, `deps.get --check-locked`, `deps.unlock --check-unused`, compile with warnings as errors, credo, xref, tests including properties, perf, goldens and canon lints, `docs --warnings-as-errors`, `hex.build`, asset drift) | ~4 min |
| `floor` | `mix.floor.lock` | ~4 min |
| `no-optional-deps` | compile with `--no-optional-deps` | folded into `floor` |
| `dialyzer` | — | ~2 min warm |
| `e2e` | pinned Playwright container, operator host app, smoke tests plus visual-core | ~5 min |
| `security` | `hex.audit`, `deps.audit`, dependency-review, actionlint, zizmor | ~1 min |
| `ci-gate` | `if: always()`; fails unless all of the above succeeded (skipped counts as failure); the **only required check** | — |

- **PR wall-clock target:** p50 ≤ 7 min, p95 ≤ 10 min.

### Nightly, dispatch and release
- **Nightly / dispatch (same file):**
  - full sweep and visual set (≤400 renditions), Firefox and WebKit;
  - 10k property runs;
  - canary run against LiveView main and the latest `phx.new`;
  - the determinism self-test;
  - Muex and the bench weekly.

  A failure opens or updates **one** `quality-regression` issue.
- **Release PR** (`head_ref` starts with `release-please--`): runs the nightly suite and is gated on it. Any open `quality-regression` issue blocks the release.
- **Release pipeline:** release-please (elixir, `include-v-in-tag`, manifest `0.0.0`, `release-as: 0.1.0` for the first release only), then publish (environment `hex-production`), then a smoke consumer plus an Igniter install.
  - Run the Actions PR-permission `gh api` call on day 1.
  - Tag before publish so the docs `source_ref` resolves.
  - Use fork-safe `mix hex.build` on PRs.
  - Attach the SBOM (`mix sbom.cyclonedx`) to releases.
