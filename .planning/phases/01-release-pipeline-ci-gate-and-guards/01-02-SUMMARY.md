---
phase: 01-release-pipeline-ci-gate-and-guards
plan: 02
subsystem: infra
tags: [github-actions, ci, release-please, hex, ruleset, smoke-test]

requires:
  - phase: 01-01
    provides: "mix ci alias, mix.floor.lock and FABLEBOOK_FLOOR switch, prod guard contract tests"
provides:
  - ".github/workflows/ci.yml: core, floor, dialyzer, security, nightly, ci-gate, ci-health (188 lines)"
  - ".github/workflows/release-please.yml (PAT only) calling .github/workflows/hex-publish.yml (build, publish, smoke matrix, finalize)"
  - ".github/actions/setup: lane-aware setup with split cache restore/save, saves on main only"
  - "bin/smoke_consumer --path DIR | --hex V [--checksum SHA]"
  - "bin/ci_health (nearest-rank p50/p95, ruleset drift) and bin/ci_health --file-regression <job> [note]"
  - "Public repo szTheory/fablebook with D-15 settings, ruleset 26086901 (ci-gate, integration 15368), environment hex-production"
  - "Draft PR #1 with a green ci-gate"
affects: [01-03, 01-04, 01-05]

actuals:
  tokens: 5400
  tasks: 4
  commits: 3
plan_head_before: aaabb6cffeb80e46faebc3a33dcfb0d12ecc68db
plan_head_after: aa1ee71991d13f20770fb60d9df1af601a545505

tech-stack:
  added: [actionlint 1.7.12 (image), zizmor 1.31.1 (image), erlef/setup-beam v1.24.1, release-please-action v5.0.0, erlef/mix_sbom v0.12.0, dependency-review-action v5.0.0]
  patterns:
    - "Every event value reaches scripts through env:, never ${{ }} inside run:"
    - "Every uses: is the local setup action, owner/repo@<40-hex> # vX.Y.Z, or docker://...@sha256:<64-hex>"
    - "Release workflows run setup with cache 'false'; caches are saved only on refs/heads/main"
    - "One open-or-create quality-regression path (bin/ci_health --file-regression), shared by ci.yml and hex-publish.yml"

key-files:
  created:
    - .github/workflows/ci.yml
    - .github/workflows/release-please.yml
    - .github/workflows/hex-publish.yml
    - .github/actions/setup/action.yml
    - .github/zizmor.yml
    - bin/ci_health
    - bin/smoke_consumer
    - release-please-config.json
    - .release-please-manifest.json
    - .planning/intent/sources/2026-10-28-19-repo-public.md
  modified: []

key-decisions:
  - "Owner chose public (INT-20261028-19): szTheory/fablebook created public, docs-only history pushed to main"
  - "Dependency graph enabled (through Dependabot alerts) so dependency-review can run; adds a control, turns none off"
  - "Repo metadata mirrors sigra: hexdocs homepage, topics, squash-only merges; no workflow files copied"
  - "bin/ci_health --file-regression takes an optional note; hex-publish smoke uses it for the tag and the revert command"

patterns-established:
  - "Pre-push scan before every push; all-checks merge rule as the green check"

requirements-completed: []
requirements-advanced: [CI-01, REL-01]

coverage:
  - id: D1
    description: "Three workflows plus one composite action and the zizmor config, lint-clean under pinned actionlint and zizmor, ci.yml at most 250 lines, setup action at most 60 lines, no line over 120 characters"
    requirement: CI-01
    verification:
      - kind: other
        ref: "local actionlint and zizmor --offline at the pinned digests (exit 0); security job on run 40792556613 (actionlint and online zizmor green)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Consumer smoke: phx.new 1.8.16 host mounts Fablebook in dev_routes, dev compiles with --warnings-as-errors and routes /dev/fablebook, prod compiles with no Fablebook route"
    requirement: REL-01
    verification:
      - kind: integration
        ref: "bin/smoke_consumer --path . (local, Elixir 1.20.4 / OTP 29.1.1)"
        status: pass
      - kind: integration
        ref: "nightly job and hex-publish smoke matrix (CI)"
        status: not-run
    human_judgment: false
  - id: D3
    description: "Ruleset on main requires exactly ci-gate from integration 15368"
    requirement: CI-01
    verification:
      - kind: other
        ref: "gh api repos/szTheory/fablebook/rules/branches/main -> [\"ci-gate\"], ruleset 26086901"
        status: pass
    human_judgment: false
  - id: D4
    description: "Draft PR #1 satisfies the all-checks merge rule (core, floor, dialyzer, security, ci-gate pass; nightly and ci-health skipped)"
    requirement: CI-01
    verification:
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40792556613 (attempt 2)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Release pipeline (release-please, hex-publish build/publish/smoke/finalize) works end to end"
    requirement: REL-01
    verification:
      - kind: other
        ref: "first release in Plan 01-05"
        status: not-run
    human_judgment: false
  - id: D6
    description: "Weekly ci-health timing and ruleset drift run live"
    requirement: CI-01
    verification:
      - kind: other
        ref: "bin/ci_health first live run in Plan 01-05 Task 1"
        status: not-run
    human_judgment: false

duration: 21min
completed: 2026-10-29
status: complete
---

# Phase 1 Plan 02: CI gate, release pipeline and public repository Summary

**szTheory/fablebook is public with read-only workflow permissions, required SHA pins, immutable releases and a ruleset that requires only `ci-gate`. Draft PR #1 carries all three workflows and is green on the five PR jobs.**

## Performance

- **Duration:** about 21 min of execution (2026-10-28T23:57Z to 2026-10-29T00:19Z). The Task 3 checkpoint wait is not counted.
- **Tasks:** 4 of 4 (Task 3 was the owner checkpoint)
- **Files created:** 10

## Links

- **Repository:** https://github.com/szTheory/fablebook
- **Draft PR #1:** https://github.com/szTheory/fablebook/pull/1
- **Green run:** https://github.com/szTheory/fablebook/actions/runs/40792556613 (attempt 2, head `aa1ee71`). The all-checks merge rule holds.
- **Ruleset:** id `26086901`, named `main`, targeting `~DEFAULT_BRANCH`. It has one rule, `required_status_checks` with context `ci-gate` and integration_id 15368.
- **Environment:** `hex-production`, with deployment policies `main` (branch, id 64727952) and `v*` (tag, id 64727953). It has no reviewers. `HEX_API_KEY` is set by the owner in Plan 01-05.

## Re-resolved pins (2026-10-28T23:57Z, all equal to the 01-RESEARCH.md table)

| Item | Pin |
|---|---|
| actions/checkout v7.0.1 | `3d3c42e5aac5ba805825da76410c181273ba90b1` |
| actions/cache v6.1.0 (restore, save) | `55cc8345863c7cc4c66a329aec7e433d2d1c52a9` |
| erlef/setup-beam v1.24.1 | `54075bcc5e249e4758d363f27d099f55d843f124` |
| googleapis/release-please-action v5.0.0 | `45996ed1f6d02564a971a2fa1b5860e934307cf7` |
| erlef/mix_sbom v0.12.0 (commit, not the tag object) | `96bb84f8e9e72361bfad4142d666dfa2c0838ac2` |
| actions/dependency-review-action v5.0.0 | `a1d282b36b6f3519aa1f3fc636f609c47dddb294` |
| rhysd/actionlint 1.7.12 | `sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667` |
| zizmor 1.31.1 | `sha256:42d409dbb851d4c5d35a058cf042b828bea1e3f2884378c526eb0974780e18d9` |
| GitHub Actions app id | 15368 |

## Accomplishments

- **`ci.yml` (188 lines).**
  - `core` runs `mix ci` on Elixir 1.20.4 / OTP 29 and printed `Result: 2 passed`.
  - `floor` runs on Elixir 1.18.5 / OTP 27.3.4.9 with `mix.floor.lock` and printed `2 tests, 0 failures`.
  - `dialyzer` has its own PLT key.
  - `security` pins Hex 2.6.0, asserts Hex 2.5.1 or later, then runs `hex.audit`, dependency-review, actionlint and online zizmor.
  - `nightly` (cron, dispatch and `release-please--` heads) first blocks on any open quality-regression issue, then runs the consumer smoke.
  - `ci-gate` has `if: always()` and checks the `needs` results with jq.
  - `ci-health` (Monday cron and dispatch) runs `bin/ci_health`, then the CI-shape test. Any failure files quality-regression.
- **Release pipeline.**
  - `release-please.yml` uses `RELEASE_PLEASE_TOKEN` with no fallback and calls `hex-publish.yml` with the tag and `HEX_API_KEY` by name.
  - `build` checks the tag against `@version`, runs the guard tests, builds the tarball and records its sha256, smokes the unpacked tarball and uploads the SBOM.
  - `publish` (environment hex-production) skips when hex.pm already has the same checksum, fails on a different checksum or any other HTTP status, and publishes on 404.
  - `smoke` runs the Hex-mode consumer on the latest and floor lanes.
  - `finalize` takes the release out of draft.
  - The publishing workflow never touches the Actions cache.
- **`bin/smoke_consumer --path .` passes locally.** It installs phx_new 1.8.16 into a fresh `MIX_HOME`/`HEX_HOME` and inserts the mount after `pipe_through :browser` in the `dev_routes` block. It checks that both edits happened exactly once. `/dev/fablebook` is in the dev routes, and prod `phx.routes` has no Fablebook line.
- **Assumptions confirmed by the first CI run:**
  - A9: setup-beam accepts `.tool-versions` with `elixir 1.20.4-otp-29`.
  - A1: `sha_pinning_required=true` accepts the local `./` action and the `docker://…@sha256` steps.
  - A3: the ruleset body shape was accepted as written.

## Task Commits

1. **Task 1: ci.yml, the setup action, the zizmor config and ci_health:** `0ff720e`
2. **Task 2: Release pipeline files and the consumer smoke:** `e70d4f4`
3. **Task 3: Owner checkpoint.** The owner answered `public`, recorded as INT-20261028-19 in `aa1ee71`.
4. **Task 4: Repository, settings, ruleset, environment and draft PR #1.** This is GitHub-side state only. No repository file changed after the first run.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Enabled the dependency graph so dependency-review can run**
- **Found during:** Task 4, the first run of PR #1
- **Issue:** `security` failed with "Dependency review is not supported on this repository. Please ensure that Dependency graph is enabled". The new public repository had the dependency graph off. The `security_and_analysis.dependency_graph` PATCH was ignored.
- **Fix:** `gh api -X PUT repos/szTheory/fablebook/vulnerability-alerts` (204) enables Dependabot alerts, which turns the dependency graph on. I then re-ran the failed jobs, and attempt 2 is green. This adds a control and turns none off. Every D-15 setting is unchanged. oarlock has the same alerts enabled.
- **Files modified:** none (a GitHub setting)

**2. [Rule 2 - Reuse] `bin/ci_health --file-regression <job> [note]` accepts an optional note**
- **Why:** The `smoke` job in `hex-publish.yml` has to file quality-regression with the tag and the revert command. Reusing the script's open-or-create path avoids a second copy of that logic in YAML.
- **Commit:** `0ff720e` (script), `e70d4f4` (caller)

**3. [Coordinator instruction] Repository metadata**
- Following the owner's reply ("u can see how my other libs are set up"), the repository now has:
  - description "Storybook-style workbench for Phoenix LiveView";
  - homepage `https://hexdocs.pm/fablebook/`;
  - topics elixir, hex, phoenix, phoenix-liveview, storybook, design-system and component-library;
  - squash-only merges, as on sigra.
- No workflow file was copied from another repository.

### Honesty notes (ADR 0010)

- **Green run attempt.** The green run is attempt 2 of run 40792556613. Attempt 1 failed only in `security`, for the reason in deviation 1. `bin/ci_health` counts attempt-1 runs only.
- **Requirements not yet complete.** CI-01 and REL-01 are advanced, not complete:
  - the shape test lands in Plan 01-04;
  - the first live `ci_health` run and the release land in Plan 01-05;
  - `nightly` and the hex-publish jobs have not run in CI yet.

## Issues Encountered

- The first `gh pr checks --watch` returned before GitHub had registered any checks ("no checks reported"). A second watch worked.
- `.planning/state.json` is still untracked and was left alone.

## Pre-push scan

The scan ran before each of the three pushes: the main history, the code branch, and the repository creation step. It printed nothing each time, and every author and committer address is a GitHub noreply address.

## Next Phase Readiness

- Every push to PR #1 now runs `ci-gate`. Plans 01-03 and 01-04 add commits to `release-pipeline-and-guards`. This SUMMARY commit stays local until Plan 01-04's push.
- **Owner actions remaining for Plan 01-05:** set `RELEASE_PLEASE_TOKEN` before PR #1 merges, and set `HEX_API_KEY` in `hex-production` before the release PR merges.

## Self-Check: PASSED

- All 10 created files exist. Commits `0ff720e`, `e70d4f4` and `aa1ee71` are ancestors of HEAD.
- The ruleset contexts are `["ci-gate"]`, the default branch is `main`, `default_workflow_permissions` is `read`, and environment `hex-production` exists.
