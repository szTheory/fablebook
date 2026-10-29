# Deferred items, Phase 01.1

| Found during | Item | Evidence | Why deferred |
|---|---|---|---|
| 01.1-01 | A scheduled `ci` run on main `2d2bbe0` failed the `security` job. The log line is "Failed to fetch record for mime from registry (using cache instead)", then exit 1. | https://github.com/szTheory/fablebook/actions/runs/40812122621 | It predates this plan, and no file in this plan touches it. The PR run and the post-merge main run both passed `security`. Check whether the nightly audit step should tolerate a transient registry fetch, without lowering the gate. |

## IN-01: The floor-version test passes when it does not run

- **Where:** `test/contract/dependency_budget_test.exs:55-69`, the floor-version check.
- **Seen:** Phase 1 review (01-REVIEW IN-01). Without `FABLEBOOK_FLOOR` the test prints `not-run`, but ExUnit records a pass. ADR 0010 says a check that did not run is `not-run`, never `pass`.
- **Fix direction:**
  - tag the test (for example `@tag :floor`) and exclude it unless `FABLEBOOK_FLOOR` is set, so the run reports it as excluded rather than passed;
  - add the tag to `@allowed_excludes` in `ci_shape_test.exs`.
  - Both edits are contract tests, so they go in a contract-test-only PR with no `lib/`, `.github/` or `mix.exs` change (ADR 0021). Owner phase: any phase, as its own PR.

## IN-02: The smoke consumer's prod route check has no positive control

- **Where:** `bin/smoke_consumer:101-106`.
- **Seen:** Phase 1 review (01-REVIEW IN-02). The fixture test asserts the host's `GET /` before it refutes Fablebook routes, but the smoke script only refutes, so empty or reformatted `phx.routes` output passes. D-06 calls positive controls required.
- **Fix direction:**
  - before the refute, fail with "prod routes empty" unless the prod route list matches `\sGET\s+/\s`.
  - It is a `bin/smoke_consumer` PR that changes no `test/contract/` file (ADR 0021). Owner phase: Phase 2, beside the operator host's prod build.

## IN-03: The ci-gate step check is substring-only

- **Where:** `test/contract/ci_shape_test.exs:351-358`, `gate_step?/1`.
- **Seen:** Phase 1 review (01-REVIEW IN-03). It only requires `toJSON(needs)`, `jq -e`, `nightly` and `release-please--` somewhere in the step, so a gate rewritten to `any(...)` or one that checks only `.core` still passes.
- **Fix direction:**
  - compare the step's `run:` body to the exact canonical jq program, the way `@ci_test_step` pins the alias.
  - It is a contract-test-only PR with no `.github/` change (ADR 0021). Owner phase: any phase, as its own PR.

## SEC-02: "No story beams" rests on the fixture's own layout

- **Where:** `test/fixtures/prod_guard_host/mix.exs`, `elixirc_paths(:prod)`; `test/contract/prod_guard_test.exs`.
- **Seen:** Phase 1 verification (coincidental_reliance_items, reason fixture-only). The CI prod build finds no story beams ([run 40806648656](https://github.com/szTheory/fablebook/actions/runs/40806648656)) because the fixture excludes `storybook/` from its prod `elixirc_paths`. Nothing in Fablebook enforces that for an adopter yet.
- **Fix direction:** either
  - the installer (Phase 10) writes `elixirc_paths` without `storybook/` in prod and the doctor checks it, in a `lib/` PR that does not edit the contract test guarding it; or
  - the operator host's prod build (Phase 2, Q31) asserts no story beams on a generated layout, in its own PR.

## WR-05 follow-up: tag code runs before the main-only check fails

- **Where:** `.github/workflows/hex-publish.yml`, build job, the steps before `tag`.
- **Seen:** Phase 01.1 Nyquist audit (2026-10-29). Checkout uses `ref: inputs.tag`, so `./.github/actions/setup` and its `mix deps.get` come from the tag's own commit and run with the build job's `contents: write` token before the ancestry check fails the job. Dispatching already needs write access, and `HEX_API_KEY` exists only in the `publish` job, so this is not a privilege escalation. `test/contract/hex_publish_test.exs` does not claim to cover it.
- **Fix direction:**
  - run the ancestry check in a first step that checks out `main` (or uses the API) before anything from the tag is executed, or drop the build job's token to `contents: read`.
  - It is a `.github/` PR that does not edit `test/contract/hex_publish_test.exs` in the same change (ADR 0021). Owner phase: next release-pipeline touch, or with Q37.
- **Resolved:** the build step `ref` runs before `./.github/actions/setup` (Plan 01.1-04, PR https://github.com/szTheory/fablebook/pull/12)

## hex_publish_test.exs hardening (01.1 re-verification, review iteration 2)

- **Where:** `test/contract/hex_publish_test.exs`.
- **Seen:** 01.1-REVIEW iteration 2 and 01.1-VERIFICATION (2026-10-29T15:52:44Z).
  - WR-06: the step harness runs `bash --noprofile --norc -eo pipefail` (:447), the runner runs plain steps as `bash -e {0}`. A `| cat` on the ancestry line passes the five behavioural tests while `bash -e` passes an off-main sha. Reproduced by the verifier.
  - WR-07: a top-level `env:` holding `HEX_API_KEY` placed after `jobs:` is unscanned.
  - WR-08: `if: always()` on `finalize` or `if: false` on a smoke step goes undetected.
  - WR-09: the fixture puts `origin/main` and the tag on one commit, so the version-equals-tag check, the tag regex and a `sha` from `origin/main` cannot fail.
  - WR-10: removing `environment: hex-production` or the smoke `--checksum` goes undetected.
  - IN-04: the release test filter, pre-publish smoke and smoke lanes are unpinned.
  - IN-05: `:19` sets an email-shaped fixture identity; use `user.email=fixture`.
- **Fix direction:** run the harness as `bash -e` with the pipe mutation, and add one mutation per WR item. One contract-test-only PR touching only `hex_publish_test.exs` (ADR 0021).
- **Receiving home:** release-blocking. It lands before the next release-please PR merges, as its own PR in whichever phase is open then (INT-20261029-02, INT-20261029-04). The ban gaps CR-04, VR-01, WR-11, WR-12 and truth 6 went to Phase 01.1.1 instead.
