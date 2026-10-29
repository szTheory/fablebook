---
phase: 01-release-pipeline-ci-gate-and-guards
verified: 2026-10-29T02:47:08Z
status: gaps_found
score: 7/9 must-haves verified
covered_files: [".credo.exs", ".formatter.exs", ".github/actions/setup/action.yml", ".github/workflows/ci.yml", ".github/workflows/hex-publish.yml", ".github/workflows/release-please.yml", ".github/zizmor.yml", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-01-PLAN.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-01-SUMMARY.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-02-PLAN.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-02-SUMMARY.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-03-PLAN.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-03-SUMMARY.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-04-PLAN.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-04-SUMMARY.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-05-PLAN.md", ".planning/phases/01-release-pipeline-ci-gate-and-guards/01-05-SUMMARY.md", ".release-please-manifest.json", ".tool-versions", "README.md", "bin/ci_health", "bin/floor_lock", "bin/smoke_consumer", "credo/checks/banned_calls.ex", "lib/fablebook.ex", "lib/fablebook/placeholder.ex", "lib/fablebook/router.ex", "mix.exs", "mix.floor.lock", "mix.lock", "release-please-config.json", "test/contract/banned_calls_test.exs", "test/contract/ci_shape_test.exs", "test/contract/dependency_budget_test.exs", "test/contract/prod_guard_message_test.exs", "test/contract/prod_guard_test.exs", "test/contract/style_attr_test.exs", "test/contract/tarball_test.exs", "test/fixtures/guards/apply.ex", "test/fixtures/guards/capture.ex", "test/fixtures/prod_guard_host/lib/guard_host_web/router.ex", "test/fixtures/prod_guard_host/mix.exs", "test/fixtures/prod_guard_host/unguarded/router.ex", "test/planning/contract_rule_test.exs", "test/planning/intent_test.exs", "test/snapshots/prod_guard_message.txt", "test/support/beam_walker.ex", "test/support/git_diff.ex", "test/support/mix_cmd.ex", "test/test_helper.exs"]
covered_digest: "v4:sha256:3c1d46f8bed5d3e70c9ba02b85eb19007fdad5ea584a55f8226b9b4ac91b4518"
behavior_unverified: 1
overrides_applied: 0
gaps:
  - truth: "A PR that adds `String.to_atom` on input fails CI (ROADMAP Phase 1 criterion 4; phase goal: the atom ban is enforced by CI)"
    status: partial
    reason: "Direct `String.to_atom(x)` is caught, because Elixir inlines it to `:erlang.binary_to_atom/2`. Dispatch with a literal module and function is not caught. `apply(String, :to_atom, [x])`, `apply(List, :to_existing_atom, [x])`, `Function.capture(String, :to_atom, 1)` and `:erlang.apply(String, :to_atom, [x])` all pass both the BEAM layer and the Credo layer. Reproduced independently (CR-01)."
    artifacts:
      - path: "test/contract/banned_calls_test.exs"
        issue: "@mfa_tier has no `{String, :to_atom, 1}`, `{String, :to_existing_atom, 1}`, `{List, :to_atom, 1}` or `{List, :to_existing_atom, 1}`. The atom tier holds only the Erlang BIF names, which never appear when the Elixir MFA is dispatched through apply or a capture."
      - path: "test/fixtures/guards/apply.ex"
        issue: "The only apply fixture targets `Code.eval_string`. Its banned name is an atom literal, so it proves the eval tier and not the atom tier. Bypass coverage for atom creation is missing."
      - path: "credo/checks/banned_calls.ex"
        issue: "@names has no `:to_atom` or `:to_existing_atom`. The check's explanation says apply/3 and captures are caught, which is false for atom creation. `Credo.Check.Warning.UnsafeToAtom` only matches direct calls and pipes."
    missing:
      - "Add `{String, :to_atom, 1}`, `{String, :to_existing_atom, 1}`, `{List, :to_atom, 1}` and `{List, :to_existing_atom, 1}` to @mfa_tier. `Function.capture/3` and `:erlang.apply/3` with literal arguments resolve to these MFAs in the imports chunk, so they are caught too."
      - "Add fixtures `apply_to_atom.ex`, `apply_list_existing_atom.ex` and `function_capture_to_atom.ex`, each with its expected `{:mfa, ...}` hit."
      - "Make the Credo layer agree: add `:to_atom` and `:to_existing_atom` to the BannedCalls names, or add an apply/Function.capture clause that inspects literal module and function atoms. Keep `banned_names/0` parity with the test."
      - "Ship it as a contract-test-only PR with no `lib/` or `.github/` change (ADR 0021)."
behavior_unverified_items:
  - truth: "PR p50 and p95 are published weekly from CI history, and PR p50 is at most 7 min (ROADMAP criterion 3, timing clause; CI-01)"
    test: "After the first Monday 05:23 UTC cron run of ci.yml, look at the ci-health job and pinned issue #2. Then keep checking until the 7-day window holds at least 10 first-attempt, non-release-please PR runs."
    expected: "The cron run (event `schedule`, not `workflow_dispatch`) succeeds and posts a new comment on issue #2. Once n >= 10, the comment shows numeric p50 <= 420 s and p95 <= 600 s, and no quality-regression issue is opened for timing."
    why_human: "Time-gated. The scheduled trigger has not fired yet (only one dispatched run, 40802440301). Percentiles are not-run with n < 10, as ADR 0010 requires. No test can bring this forward."
coincidental_reliance_items:
  - truth: "Stories never compile in prod: the CI prod build finds no story beams (criterion 2, SEC-02)"
    reason: fixture-only
    harden: "The absence of `/storybook/` beams in prod comes from the fixture's own `elixirc_paths(:prod)`, which excludes `storybook/`. Nothing in Fablebook enforces it for an adopter yet. Declare it as a precondition that the installer (Phase 10) writes and the doctor checks, or have the operator host's prod build (Q31, Phase 2) assert it on a generated layout."
---

# Phase 1: Release pipeline, CI gate and guards: Verification Report

**Phase goal:** A published 0.1.0 reserves the Hex name, and the guards every later phase relies on (CI caps, intent integrity, the prod guard, the eval and atom bans, the dependency budget) are enforced by CI from the first merge.
**Verified:** 2026-10-29T02:47:08Z
**Status:** gaps_found
**Re-verification:** No, this is the initial verification.
**Repo state verified:** local `phase-01-verification` = `origin/main` 2d2bbe0 plus one review-docs commit (ce4db02). Local `main` = `origin/main` = 2d2bbe0.

## MVP-mode note

ROADMAP marks Phase 1 `**Mode:** mvp`, but its goal is not a user story (`user-story.validate` returns `false`). Plan 01-01 records the same: "User story: not authored". The orchestrator asked for this phase to be verified, so I verified it goal-backward against the outcome-form goal and criteria 1 to 4. The User Flow Coverage table does not apply. To get MVP framing, run `/gsd-mvp-phase 1`. This does not change the verdict.

## Goal Achievement

### Observable Truths (ROADMAP success criteria, split into checkable clauses)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | **SC1.** 0.1.0 is on hex.pm, published by release-please only after the prod-guard cases passed and the unpacked tarball was inspected. A post-publish smoke test, a recovery workflow and an attached SBOM exist. | ✓ VERIFIED | `curl hex.pm/api/packages/fablebook`: the only release is 0.1.0, inserted 2026-10-29T02:06:43Z, publisher `sztheory`, checksum `9fd4c3c3…e834`, has_docs true. It has 5 requirements (phoenix, phoenix_live_view, phoenix_html, telemetry, nimble_options). Release run [40803980465](https://github.com/szTheory/fablebook/actions/runs/40803980465) (push to main, release-please) succeeded in every job. In `build`, `mix test --only release --only prod_guard` gave "Result: 5 passed" before `hex.build`, then `bin/smoke_consumer --path unpacked` ran, then `erlef/mix_sbom` ran. `publish` checks the remote checksum against the build's sha256 and fails closed. `smoke (floor)` and `smoke (latest)` ran `--hex 0.1.0 --checksum`. `finalize` undrafted the release. `gh release view v0.1.0`: isDraft false, asset `fablebook-0.1.0.cdx.json` (17244 B). hexdocs: 301 to `fablebook.hexdocs.pm/0.1.0/`, which answers 200. The recovery path is `workflow_dispatch` on `hex-publish.yml`. WR-05 and WR-06 are warnings against it (see below). |
| 2 | **SC2.** A host that mounts Fablebook inside a false `dev_routes` block compiles cleanly in prod. An unguarded mount fails with the canonical `CompileError` from the macro's returned code. The CI prod build asserts no Fablebook routes and no story beams. | ✓ VERIFIED (coincidental-reliance) | `lib/fablebook/router.ex`: the prod branch returns only a `raise CompileError` quote, and the description is computed at expansion time. The dev branch expands the book alias and emits `Phoenix.Router.get`. `test/contract/prod_guard_test.exs` has positive controls (dev routes list `/dev/fablebook`, a dev beam comes from `/storybook/`, prod routes contain `GET / GuardHost.Ok`). It refutes `fablebook` on prod route lines and refutes storybook/design beams. It asserts `(CompileError) unguarded/`, the canonical line exactly once, and the dev_routes hint. The snapshot and README heading are pinned by `prod_guard_message_test.exs`. CI on main 2d2bbe0, [run 40806648656](https://github.com/szTheory/fablebook/actions/runs/40806648656): core `mix ci` includes `[:prod_guard, :release]` (119 passed), and floor (`FABLEBOOK_FLOOR=1`, Phoenix 1.8.9 / LiveView 1.2.9 lock) includes `[:prod_guard]` (119 tests, 0 failures). The deferred flaky assertion was fixed in its own contract-only PR #8 (2d2bbe0), and the positive control was kept. Advisory: "no story beams" holds because the fixture's `elixirc_paths(:prod)` excludes `storybook/` (see coincidental_reliance_items). |
| 3 | **SC3 (guards).** A PR that adds a fourth workflow, grows `ci.yml` past 250 lines, removes the single `ci-gate`, edits an INT source, uses a malformed INT id, or adds a REQ line with no INT or ADR citation fails CI. | ✓ VERIFIED | `ci_shape_test.exs`: an inventory test ("a fourth workflow fails the inventory"), mutations `:ci_lines` (+250 lines), `:ci_gate_count` (rename or second gate), `:ci_gate_needs`, `:ci_gate_always`, `:ci_gate_step`, and unpinned/paths/bypass/Node/phase-name mutations, each asserting exactly one rule fires. `intent_test.exs`: add-only over the diff seam, `malformed_int`/`unknown_int` citations, and `uncited_req`/duplicate/traceability. Real red run: PR #4, [run 40802432347](https://github.com/szTheory/fablebook/actions/runs/40802432347). core and floor failed `intent sources are add-only` on `{"M", ".planning/intent/sources/2026-10-28-01-founding-brief.md"}`, ci-gate failed, and the PR is CLOSED with mergedAt null. Live repo: exactly 3 workflows, `ci.yml` 188 lines, a single `ci-gate` with `needs: [core, floor, dialyzer, security, nightly]` and an `if: always()` jq gate. |
| 4 | **SC3 (timing).** PR p50 and p95 are published weekly from CI history (CI-01: p50 ≤ 7 min). | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `bin/ci_health` computes nearest-rank p50/p95 over first-attempt, non-release-please PR runs in the last 7 days, reports `not-run (n=K)` below 10, posts to the `ci-timing` issue, and files a regression over 420/600 s. The ci-health job runs on cron `23 5 * * 1` and on dispatch. The dispatched run [40802440301](https://github.com/szTheory/fablebook/actions/runs/40802440301) succeeded and posted `p50 not-run (n=2), p95 not-run (n=2)` on issue #2. The weekly cron has not fired yet, and the percentile is **not-run**, never pass (ADR 0010). For information only: the 7 first-attempt non-release PR runs so far finished ci-gate in roughly 50 s to 3.6 min. |
| 5 | **SC4 (eval / runtime templates).** A PR that adds `Code.eval*` or runtime EEx/HEEx compilation fails CI. | ✓ VERIFIED | `banned_calls_test.exs` atom tier (`:eval_string`, `:eval_quoted*`, `:eval_file`, `:string_to_quoted*`, `:compile_string/quoted/file`, `:require_file`, `:erl_eval`…). The banned names are atom literals, so apply, capture, alias and import forms are caught (the fixtures apply/capture/alias/import/macro_quote prove it). MFA tier `{EEx, :_, :_}`, `{Phoenix.LiveView.TagEngine, :compile, 2}`, `Module.create/3`, `:compile.forms/file`, `:code.load_binary/3`. It fails closed without debug_info. The Credo `BannedCalls` and `ForbiddenModule` (EEx) checks run in `mix ci`. Green in core on every PR. WR-03 (`:erlang.load_module/2`, `Kernel.ParallelCompiler.*`, `:code.load_abs/1` not banned) is outside the criterion's literal list but inside ADR 0004. It is a warning. |
| 6 | **SC4 (atoms).** A PR that adds `String.to_atom` on input fails CI. | ✗ FAILED (partial) | The direct form is caught (atom `:binary_to_atom` after inlining), and so is `&String.to_atom/1`. **Bypassed:** I compiled probes with Elixir 1.20.4 / OTP 29.1.1, debug_info on, and scanned them with the repo's `Fablebook.Test.BeamWalker` using the exact test ban sets. `apply(String, :to_atom, [x])` gave atoms=[] mfas=[]. So did `apply(List, :to_existing_atom, [x])`, `Function.capture(String, :to_atom, 1)` and `:erlang.apply(String, :to_atom, [x])`. Credo layer: running `Fablebook.Credo.BannedCalls` and `Credo.Check.Warning.UnsafeToAtom` over the same source flagged only the direct call's line. This confirms CR-01. A one-line `lib/` change creates atoms from input and passes `mix ci` on both lanes, which breaks ADR 0004 (non-negotiable). |
| 7 | **SC4 (dependency budget).** A PR that adds a banned dependency in the prod closure fails CI. | ✓ VERIFIED | `dependency_budget_test.exs` checks exactly the 5 required deps, banned direct deps in any env, the optional allowlist, and tools needing non-prod `only:`. It runs a prod-closure BFS over `hex_metadata.config` with a positive control (`plug` in the closure), plus a synthetic `yaml_elixir`/`yamerl` closure case. It never uses `deps.tree --only prod`. Green in core and floor. |
| 8 | **SC4 (tarball).** A PR that adds a file outside the tarball allowlist fails CI. | ✓ VERIFIED | `tarball_test.exs` (`@moduletag :release`, included by the `mix ci` alias) runs a real `mix hex.build --unpack` and compares the result to the exact allowlist (lib/** plus 6 top-level files plus `hex_metadata.config`). It also checks denied prefixes and extensions, metadata, and a PII scan. It ran in core on main and in the release `build` job before publish. The shipped tarball matches (SUMMARY file list; Hex requirements match). |
| 9 | **"From the first merge."** CI enforces the guards on main before anything lands. | ✓ VERIFIED | Ruleset `main` (id 26086901) was created 2026-10-29T00:12:14Z, before PR #1 merged at 01:42:29Z. It is active on `~DEFAULT_BRANCH`, requires only context `ci-gate` with integration_id 15368, and has `bypass_actors: []`. Merges are squash-only. PR #1's checks: ci-gate, core, floor, dialyzer and security all pass ([run 40797403231](https://github.com/szTheory/fablebook/actions/runs/40797403231)). Every later PR (#3, #5 to #8) reached main through ci-gate. |

**Score:** 7/9 truths verified (1 present but behavior-unverified, 1 failed)

### Plan must-haves (merged)

I checked the 45 PLAN frontmatter truths against the code and live evidence. They add detail to the 9 roadmap truths above and are scored there, not counted again. Notable results:

| Plan | Truth (abridged) | Result |
|------|------------------|--------|
| 01-01 | Prod guard on both locks; snapshot first line equals README heading; sign-off recorded verbatim before amendments | Verified. INT-20261028-18 exists, and ADRs 0006, 0007, 0017, 0018 and 0021 cite it. |
| 01-01 | `mix ci` exits 0 locally | Not re-run locally. CI's `mix ci` on main is green, and that is the authoritative evidence. |
| 01-02 | 3 workflows plus composite action plus zizmor.yml; ci.yml ≤ 250; ruleset requires only ci-gate (15368); release-please uses the PAT with no github.token fallback; hex-publish is both workflow_call and workflow_dispatch | Verified (live files and `gh api`). |
| 01-03 | "Adding … String.to_atom/List.to_atom … to any lib/ module makes `mix test` fail" | **Partial.** True for direct calls only. False for apply/capture dispatch (truth 6). |
| 01-03 | "Each of the 8 bypass fixtures (alias, import, apply, capture, …) is reported" | Literally verified. But the apply and capture fixtures exercise only `Code.eval_string`, so they give false confidence for the atom tier (CR-01). |
| 01-03 | Fail closed without debug_info; style scan; dependency budget; tarball | Verified (tests present, green in CI). |
| 01-04 | Add-only, source rules, citations, REQ lines, contract-rule pairing, real-repo diff seam, shape rules, test-wiring pins | Verified (tests present, D-22 red run). The contract-rule table is narrower than the guard surface (WR-04). |
| 01-05 | Amendments cite the INT; ci-health posts; PR #1 merged; D-22 red and closed; dispatched ci-health and nightly succeeded; 0.1.0 on hex with matching checksum; release not draft with SBOM; smoke both lanes; release-as removed; no open release PR | Verified (`gh` and `curl`). |
| 01-05 | "The owner saw the amendment diff"; "HEX_API_KEY is replaced by a key scoped to package fablebook"; old key revoked | Owner-reported only. The `HEX_API_KEY` secret `updated_at` (02:15:03Z) is after the publish (02:06:46Z), but the key's scope and the revocation cannot be read through the API. Recorded as not independently verified, not as pass. |

### Prohibitions (plan `[unverified]` items, LLM-judge verdict, non-authoritative)

Each one is flagged as an unverified prohibition, and human review is recommended. Verdicts come from greps and reading, not from wired enforcement.

| Prohibition | Judge verdict | Basis |
|---|---|---|
| Router never stores `Mix.env()` in an attribute or constant | holds | `Mix.env()` is read only inside `defmacro fablebook/2` at expansion time. |
| Prod branch never expands the Book alias, validates options or references another Fablebook module | holds | The prod quote is a bare `raise CompileError`. `prod_description/3` runs at expansion time. |
| No absolute home path, scratchpad path or email in repo files | holds | `git grep` over lib, test, credo, bin, .github, .planning, docs and CLAUDE.md found only the PII scanner's own patterns and a deliberately split home-path sample string in `tarball_test.exs`. |
| mix.exs declares no dependency outside the D-26 sets | holds | 5 required deps plus ex_doc, credo and dialyxir as non-prod tools (also test-enforced). |
| Every `uses:` and image pinned by 40-hex SHA or sha256 digest | holds | grep found no unpinned refs (also enforced by the shape test). |
| No `${{ }}` inside `run:` | holds | A scripted scan of every `run:` block found none. |
| The publishing workflow never restores or saves a cache | holds | Every `setup` call in hex-publish passes `cache: 'false'`. Cache steps are gated on `inputs.cache == 'true'`. |
| release-please never falls back to github.token | holds | `token: ${{ secrets.RELEASE_PLEASE_TOKEN }}` only. |
| Ban allowlist stays empty and lives only in the test | holds | `@allowlist []`. |
| TagEngine as a whole never banned | holds | Only `{Phoenix.LiveView.TagEngine, :compile, 2}`. |
| credo/checks/ not in elixirc_paths or package files | holds | mix.exs `elixirc_paths` and `files`. |
| Dependency-budget test never uses `deps.tree --only prod` | holds | grep: none. |
| Intent and contract-rule tests never read gitignored files | not checked in depth | Not traced line by line. |
| No intent source modified or deleted | holds | `git log --diff-filter=MDT -- .planning/intent/sources` is empty. |
| Scanner logic inside guarded test files, not test/support | **partially contradicted** | The CI-shape scanner lives in its test file. The BEAM ban scanner `Fablebook.Test.BeamWalker` lives in `test/support/`, which no D-21 pairing guards (WR-04). |
| No secret value printed or committed | not independently verifiable | No secret patterns are in tracked files. CI logs were not exhaustively audited. |
| D-22 PR never merged | holds | PR #4 CLOSED, mergedAt null. |
| Release never published by hand | holds | The Hex insert time (02:06:43Z) falls inside the `publish` job, which ended at 02:06:46Z. |
| No commit on local main after PR #1 | holds | Local `main` = `origin/main` = 2d2bbe0. |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/fablebook/router.ex` | `fablebook/2`, prod raise quote, dev `Phoenix.Router.get` | ✓ VERIFIED | Substantive and wired: the fixture router imports it, and the 0.1.0 tarball ships it. |
| `lib/fablebook/placeholder.ex` | 200 text/plain plug, `@moduledoc false` | ✓ VERIFIED | Its placeholder text is intentional: the release only reserves the name. |
| `test/contract/prod_guard_test.exs` | D-06 steps via nested mix | ✓ VERIFIED | Runs in core (latest), floor and the release build. |
| `test/fixtures/prod_guard_host/*` | Guarded and unguarded host, floor switch | ✓ VERIFIED | |
| `mix.floor.lock` | Phoenix 1.8.9 / LiveView 1.2.9 | ✓ VERIFIED | Floor job green. |
| `mix.exs` | One @version, lockfile switch, ci alias, ignore filters, package files | ✓ VERIFIED | |
| `.github/workflows/{ci,release-please,hex-publish}.yml`, `.github/actions/setup/action.yml` | Job set, gate, publish flow | ✓ VERIFIED | Live runs green. |
| `bin/smoke_consumer`, `bin/ci_health` | Consumer smoke; p50/p95 plus drift | ✓ VERIFIED | Exercised in nightly, release smoke and the ci-health dispatch. |
| `test/support/beam_walker.ex` | Atom and MFA scan, fail closed | ⚠️ VERIFIED, incomplete coverage | Works as designed, but the ban sets it is driven with miss the Elixir-level atom constructors (truth 6). |
| `test/contract/banned_calls_test.exs` | BEAM plus Credo parity, empty allowlist | ✗ PARTIAL | Missing the atom-constructor MFAs and the matching fixtures (gap). |
| `credo/checks/banned_calls.ex` | Source-level bans | ✗ PARTIAL | Its "apply/3 and captures are all caught" explanation does not hold for atom creation. |
| `test/contract/{dependency_budget,tarball,style_attr,ci_shape}_test.exs`, `test/planning/{intent,contract_rule}_test.exs`, `test/support/git_diff.ex` | Guards | ✓ VERIFIED | Present, substantive, run in core and floor. |
| `release-please-config.json` | release-as removed | ✓ VERIFIED | No `release-as`. Manifest `0.1.0`. No open release PR. |

### Key Link Verification

| From | To | Via | Status |
|------|----|----|--------|
| fixture router | `Fablebook.Router` | `import` inside `if Application.compile_env(:guard_host, :dev_routes)` | WIRED |
| prod_guard_test | MixCmd | `MixCmd.run/4` with explicit MIX_ENV | WIRED |
| fixture mix.exs | mix.floor.lock | `FABLEBOOK_FLOOR` switch | WIRED (floor job sets it) |
| release-please.yml | hex-publish.yml | `uses: ./.github/workflows/hex-publish.yml` on `release_created` | WIRED (run 40803980465) |
| ci.yml core | mix.exs `ci` alias | `run: mix ci` | WIRED |
| ci.yml ci-health | bin/ci_health and ci_shape_test | steps plus `if: failure()` | WIRED (dispatch run 40802440301) |
| Ruleset on main | ci-gate | required context, integration 15368 | WIRED |
| banned_calls_test | BeamWalker | `Application.spec(:fablebook, :modules)` filtered to lib/ | WIRED |
| .credo.exs | BannedCalls | `requires` plus `extra` | WIRED (core credo: 73 checks, no issues) |
| test_helper | GitDiff | base resolution, raise in CI | WIRED (the D-22 run shows the diff base resolved) |
| hex-publish publish | hex.pm | `mix hex.publish --yes` with env secret | WIRED (checksum equal) |

### Data-Flow Trace (Level 4)

Not applicable. This is a library, CI and release phase with no rendered dynamic data. The release data flow (build sha256 → publish checksum compare → smoke `--checksum`) is traced in truth 1.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| 0.1.0 live with matching checksum | `curl hex.pm/api/packages/fablebook/releases/0.1.0` | checksum `9fd4c3c3…e834`, publisher sztheory | ✓ PASS |
| hexdocs answers | `curl -w %{http_code}` (both hosts) | 301 → 200 | ✓ PASS |
| SBOM attached, release not draft | `gh release view v0.1.0` | isDraft false, `fablebook-0.1.0.cdx.json` | ✓ PASS |
| Guards ran on current main | `gh run view 40806648656 --log` | core 119 passed (prod_guard and release included); floor 119 tests, 0 failures | ✓ PASS |
| Intent guard goes red in real CI | `gh run view 40802432347 --log-failed` | add-only failure on founding-brief | ✓ PASS |
| Atom ban catches apply/capture dispatch | Scratch probe, BeamWalker with the test's ban sets (Elixir 1.20.4 / OTP 29.1.1) | ApplyToAtom, ApplyListExisting, FunctionCapture and ErlangApply MISSED; Direct and RemoteCapture caught | ✗ FAIL |
| Credo catches apply/capture to_atom | Scratch probe, `CheckRunner.run_check` with BannedCalls and UnsafeToAtom | Only the direct-call line flagged | ✗ FAIL |
| Runtime code loading via `:erlang.load_module/2` banned | Same probe | MISSED (WR-03) | ✗ FAIL (warning scope) |

All probe files were written to a session scratch directory outside the repository. Nothing was written to the repo.

### Probe Execution

No `scripts/*/tests/probe-*.sh` exist, and no plan declares one. Step 7c: not applicable.

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|-------------|--------|----------|
| REL-01 | 01-01, 01-02, 01-03, 01-05 | release-please publishes to Hex; 0.1.0 reserves the name; smoke, recovery workflow, SBOM | ✓ SATISFIED | Truth 1. WR-05 (tag-ref publish path) and WR-06 (docs-only recovery does not converge) are warnings. |
| CI-01 | 01-02, 01-04, 01-05 | 3 workflows, ci.yml ≤ 250, one ci-gate, caps test-enforced; PR p50 ≤ 7 min from CI history | ⚠️ PARTIAL | Caps verified (truth 3). p50 is **not-run** (n < 10), and REQUIREMENTS correctly shows Pending. |
| INTENT-01 | 01-04, 01-05 | intent_test enforces add-only, valid INT ids, cited REQ lines | ✓ SATISFIED | Truth 3 plus the D-22 red run. |
| SEC-02 | 01-01 | Prod macro raises CompileError, no override; stories and canon never compile in prod; CI prod build asserts no routes and no story beams | ✓ SATISFIED (bookkeeping open) | Truth 2. The macro has no override option. No SUMMARY ever moved SEC-02 from "advanced" to "completed", and REQUIREMENTS line 162 and traceability line 366 still show `[ ]` / Pending, although the CI evidence that 01-01 was waiting for now exists. "Stories never compile in prod" is fixture-proven only (advisory). |
| SEC-01 (partial) | 01-03 | No eval, runtime EEx/HEEx, or `String.to_atom` on input; Credo bans; properties and mutation tests (Phase 5) | ✗ BLOCKED for the Phase 1 share | Eval and runtime-template bans hold. The atom ban is bypassable (truth 6). Phase 5 owns the properties and mutation tests, not this static-ban hole, so it is not deferred. |

Orphans: the REQUIREMENTS traceability table maps exactly REL-01, CI-01, INTENT-01 and SEC-02 to Phase 1, and every one appears in a plan's `requirements:`. SEC-01 maps to Phase 5 and is claimed by 01-03 as a partial. No orphaned IDs.

### Code Review Findings: Disposition Against the Phase Goal

| ID | Verifier classification | Reasoning |
|----|------------------------|-----------|
| CR-01 | **🛑 BLOCKER (gap)** | Reproduced. Criterion 4 names `String.to_atom` on input, and the goal names "the atom bans … enforced by CI". `apply(String, :to_atom, [input])` *is* `String.to_atom` on input. The phase's own bypass-fixture design (apply and capture) claims to cover this class but tests only eval. The fix is a contract-test-only PR, as ADR 0021 allows. |
| WR-01 | ⚠️ WARNING | A path-dependency (poncho) router compiled in dev hits the prod raise, because path deps compile in `:prod`. It fails closed, so no prod exposure. It is a false positive in the public 0.1.0 API and a docs and message fix. Not a criterion clause. Owner question beside Q32. |
| WR-02 | ⚠️ WARNING | Confirmed by reading: `(?<![\w.])` excludes every qualified call, so the mix.exs text scan is near-vacuous. Credo `BannedCalls` includes `mix.exs` in core, so CI still fails on `Code.eval_string` in mix.exs. Defence in depth only. |
| WR-03 | ⚠️ WARNING | Reproduced for `:erlang.load_module/2`. It is runtime code loading under ADR 0004, but not in criterion 4's literal list (`Code.eval*`, runtime EEx/HEEx). Same root cause as CR-01 (incomplete MFA tier), so close it in the same contract-test PR. |
| WR-04 | ⚠️ WARNING | The D-21 contract-rule table does not pair `test/support/` (BeamWalker, GitDiff), `test/fixtures/`, `credo/`, `.credo.exs` or `test_helper.exs`, or its own file with code paths. The table is owner-signed (ADR 0021, INT-20261028-18), so widening it needs an OPEN-QUESTIONS entry and sign-off. It weakens the meta-guard but is not a criterion clause. |
| WR-05 | ⚠️ WARNING (security hardening) | Confirmed read-only: `hex-production` deployment policies are `main` (branch) and `v*` (tag), the only protection rule is `branch_policy`, and there are no required reviewers. Someone with push access could publish from an unreviewed tag ref. SC1's "only after the prod-guard cases passed" held for the real 0.1.0 publish. This is a latent bypass of that ordering, not a failed criterion. Recommend closing it before the next release. |
| WR-06 | ⚠️ WARNING | Confirmed by reading `hex-publish.yml`: `published=true` skips every later step, so a docs-only failure never re-uploads docs. SC1 says a recovery workflow exists, and it does. It is incomplete for one failure mode. |
| IN-01 | ℹ️ Info | In core the floor-version test prints `not-run` but counts as passed (core log: "floor-version check: not-run (FABLEBOOK_FLOOR unset)", 119 passed). The floor lane runs it for real. Honesty-rule polish (ADR 0010). |
| IN-02 to IN-05 | ℹ️ Info | Smoke positive control, substring gate check, job-wide `HEX_API_KEY`, alias forms (the BEAM layer still catches them). None affects a criterion. |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| (all phase files) | n/a | TBD, FIXME, XXX, TODO, HACK, PLACEHOLDER | none found | Debt-marker gate is clean. |
| `lib/fablebook/placeholder.ex` | 13 | "workbench is not released yet" response | ℹ️ Info | Intentional. 0.1.0 is a name reservation (README and moduledoc say so). |
| `credo/checks/banned_calls.ex` | 9-10 | Explanation claims apply/3 and captures are caught | ⚠️ Warning | False for atom creation (CR-01). |
| `test/contract/banned_calls_test.exs` | 133-143 | Look-behind `(?<![\w.])` excludes qualified calls | ⚠️ Warning | WR-02. |

### Test Quality Audit

| Test File | Linked Req | Active | Skipped | Circular | Assertion Level | Verdict |
|-----------|-----------|--------|---------|----------|-----------------|---------|
| prod_guard_test.exs | SEC-02 | 1 (multi-step) | 0 | no | Behavioral, with positive controls | Sound |
| prod_guard_message_test.exs | SEC-02 | 1 | 0 | no (snapshot is a recorded artifact and is cross-checked against the README) | Value | Sound |
| banned_calls_test.exs | SEC-01 | 14 | 0 | no | Value | **Insufficient coverage**: no atom-constructor dispatch fixtures (CR-01) |
| dependency_budget_test.exs | REL-01 / ADR 0018 | 5 | 0 (floor check prints not-run in core) | no | Value plus synthetic negatives | Sound (IN-01 honesty polish) |
| tarball_test.exs | REL-01 | 4 | 0 | no | Value | Sound |
| ci_shape_test.exs | CI-01 | many (one per mutation) | 0 | no | Value (exactly-one-rule) | Sound (IN-03 substring gate) |
| intent_test.exs | INTENT-01 | 20+ | 0 | no | Value plus real-CI red run | Sound |
| contract_rule_test.exs | ADR 0021 | 13 | 0 | no | Behavioral (real tmp git repo) | Sound (table scope: WR-04) |

Disabled tests on requirements: 0. Circular patterns: 0. Insufficient assertions: 1 (banned_calls atom tier), a warning here because the blocker is recorded as the gap above.

### Decision Coverage

`check.decision-coverage-verify`: all 31 trackable CONTEXT.md decisions are honored by shipped artifacts (honored 31 / total 31, not_honored []). Non-blocking.

### Human Verification Required

These are recorded for the follow-up. With status `gaps_found` they do not change the routing.

1. **Weekly CI timing (CI-01 p50).** After the first scheduled Monday ci-health run, and again once n ≥ 10, confirm issue #2 gets a cron-sourced comment with numeric p50 ≤ 420 s and p95 ≤ 600 s. This is time-gated and not-run today.
2. **Hex key scope and old-key revocation.** On the hex.pm dashboard, confirm that `github-actions-fablebook-publish` is Publish-only on `fablebook` and that `github-actions-fablebook` is revoked. Both are owner-reported, and the API cannot see them.
3. **Unverified-prohibition review.** Review the LLM-judge prohibition verdicts above. The "scanner logic not in test/support" item is partially contradicted by `BeamWalker` (WR-04).

### Gaps Summary

The phase delivers almost all of its goal. 0.1.0 is really on hex.pm, through release-please, behind the prod-guard and tarball tests, with a checksum match, smoke on both lanes and an attached SBOM. CI caps, intent integrity, the prod guard, the eval ban, the dependency budget and the tarball allowlist are all enforced by a single required `ci-gate`. That gate existed before the first merge, and the intent guard was shown to go red in real CI.

**One blocker:** the atom ban (SEC-01's Phase 1 share, criterion 4, ADR 0004) is bypassable in one line. `apply(String, :to_atom, [input])`, `apply(List, :to_existing_atom, …)`, `Function.capture(String, :to_atom, 1)` and `:erlang.apply/3` pass both the BEAM gate and Credo. I reproduced it independently. It is not deferred: Phase 5's properties cover `handle_params` behavior and mutation proofs, not this static hole. Close it with one contract-test-only PR (ADR 0021): add the four Elixir atom-constructor MFAs to `@mfa_tier`, add one fixture per dispatch form, and bring the Credo check into parity. Add WR-03's code-loading MFAs (`:erlang.load_module/2`, `:code.load_abs/1`, `Kernel.ParallelCompiler.*`) in the same PR, since they share the root cause.

**Not blocking, still open:** CI-01's p50 is not-run until n ≥ 10. SEC-02 is still Pending in REQUIREMENTS although its CI evidence now exists (bookkeeping). WR-01, WR-02, WR-04, WR-05 and WR-06 are warnings; WR-04 needs owner sign-off because it widens the D-21 table.

---

_Verified: 2026-10-29T02:47:08Z_
_Verifier: Claude (gsd-verifier)_
