---
phase: 01-release-pipeline-ci-gate-and-guards
plan: 05
subsystem: release
tags: [release-please, hex, hexdocs, sbom, adr-amendments, ci-health, github-actions]

requires:
  - phase: 01-01
    provides: "INT-20261028-18 (approve-all sign-off), prod guard, mix ci, floor lock"
  - phase: 01-02
    provides: "ci.yml, release-please.yml, hex-publish.yml, bin/ci_health, bin/smoke_consumer, repo settings, ruleset, hex-production environment, PR #1"
  - phase: 01-03
    provides: "ban, dependency-budget, style and tarball contract tests"
  - phase: 01-04
    provides: "intent, contract-rule and CI-shape guards; the diff seam"
provides:
  - "ADR 0006, ADR 0007, ADR 0017, ADR 0018 and ADR 0021 amended under INT-20261028-18; COMPAT-01 and the PROJECT.md mirrors on the approve-all floors"
  - "OPEN-QUESTIONS: Q7, Q12, Q15, Q19, Q33, Q34 struck; Q21 (b) and (c) resolved; Q31 and Q32 open"
  - "fablebook 0.1.0 on hex.pm and hexdocs, published by release-please through hex-publish.yml, with the SBOM on release v0.1.0"
  - "Labels quality-regression and ci-timing; pinned issue #2 (CI timing) fed by ci-health"
  - "INT-20261028-20: the owner's no-expiry preference for the package-scoped Hex key"
  - "HEX_API_KEY rotated to a key with Publish permission on package fablebook only"
  - "release-please-config.json without the one-time release-as"
affects: [phase-02, release, ci]

actuals:
  tokens: 14500
  tasks: 7
  commits: 5
plan_head_before: 16abf95499efde11b7403c3b146d8202249bdb97
plan_head_after: f8e5a3b61e6f301f9d478733b21cd1359e99edb1

tech-stack:
  added: []
  patterns:
    - "Every change after PR #1 reaches main through a PR merged under the all-checks merge rule; nothing is committed on local main"
    - "release-please refreshes an open release PR only when its body differs, so a base change needs a body edit plus a push to main"

key-files:
  created:
    - .planning/intent/sources/2026-10-28-20-hex-key-no-expiry.md
    - .planning/phases/01-release-pipeline-ci-gate-and-guards/01-05-SUMMARY.md
  modified:
    - docs/adr/0006-dependency-available-in-all-envs.md
    - docs/adr/0007-version-floors.md
    - docs/adr/0017-ci-cd-layout.md
    - docs/adr/0018-dependency-budget.md
    - docs/adr/0021-delivery-rules.md
    - docs/adr/README.md
    - .planning/REQUIREMENTS.md
    - .planning/PROJECT.md
    - .planning/intent/OPEN-QUESTIONS.md
    - CLAUDE.md
    - CHANGELOG.md
    - release-please-config.json
    - .planning/STATE.md
    - .planning/ROADMAP.md
    - .planning/WINDOWS.md
    - .planning/phases/01-release-pipeline-ci-gate-and-guards/deferred-items.md

key-decisions:
  - "The CHANGELOG seed is empty before the first release: release-please appends a seed that has no version header below the new entry, with its H1 demoted"
  - "The package-scoped Hex key never expires (INT-20261028-20); it has Publish permission on fablebook only and lives only in the hex-production environment"
  - "CI-01 stays open: PR p50 and p95 are not-run until ci-health has at least 10 PR runs"

patterns-established:
  - "Evidence is a run link: each Phase 1 success criterion maps to a CI run, a URL or a recorded timestamp"

requirements-completed: [REL-01, INTENT-01]
requirements-advanced: [CI-01]

coverage:
  - id: D1
    description: "The signed amendments cite INT-20261028-18 and pass the intent test"
    requirement: INTENT-01
    verification:
      - kind: unit
        ref: "mix test --warnings-as-errors test/planning/intent_test.exs test/planning/contract_rule_test.exs (32 passed)"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40797403231"
        status: pass
    human_judgment: true
  - id: D2
    description: "A PR that edits an INT source fails ci-gate in real CI (D-22)"
    requirement: INTENT-01
    verification:
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40802432347 (PR #4, closed unmerged)"
        status: pass
    human_judgment: false
  - id: D3
    description: "ci-health on main: timing comment, ruleset equals [\"ci-gate\"], shape scan; nightly consumer smoke"
    requirement: CI-01
    verification:
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40802440301"
        status: pass
    human_judgment: false
  - id: D4
    description: "PR p50 at most 7 min and p95 at most 10 min, from CI history"
    requirement: CI-01
    verification:
      - kind: other
        ref: "https://github.com/szTheory/fablebook/issues/2#issuecomment-6485608501 (n=2, below 10)"
        status: not-run
    human_judgment: false
  - id: D5
    description: "0.1.0 is on hex.pm with a checksum equal to the build's sha256, post-publish smoke ran on both lanes, the release carries the SBOM and hexdocs answers"
    requirement: REL-01
    verification:
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/40803980465"
        status: pass
    human_judgment: false

duration: 85min
completed: 2026-10-29
status: complete
---

# Phase 1 Plan 05: Signed amendments, merge, D-22 and the 0.1.0 release Summary

**fablebook 0.1.0 is on hex.pm. release-please published it through `hex-publish.yml` after the tag-time release and prod-guard tests, a tarball smoke and the SBOM, and smoke tests on the floor and latest lanes followed. Its Hex checksum equals the build's sha256. The owner-signed amendments are in ADR 0006, ADR 0007, ADR 0017, ADR 0018 and ADR 0021. Real CI proved the intent guard red. The publish key is now scoped to the package.**

## Performance

- **Duration:** about 85 min of wall clock (2026-10-29T00:55Z to about 02:20Z), including three owner checkpoint waits.
- **Tasks:** 7 of 7 (Tasks 2, 4 and 6 were owner checkpoints).
- **Files:** 16 created or modified.

## Evidence (ROADMAP Phase 1 success criteria)

| # | Criterion | Evidence |
|---|---|---|
| 1 | 0.1.0 on hex.pm, published by release-please after the prod-guard and tarball checks; smoke, recovery workflow, SBOM | Release run https://github.com/szTheory/fablebook/actions/runs/40803980465: release-please, build, publish, smoke (floor), smoke (latest) and finalize all succeeded, with finalize at 02:08:47Z. https://hex.pm/packages/fablebook/0.1.0 reports checksum `9fd4c3c31d7e4ded6e40d2ab4548a4de4a78d34d51e2824a1b580ac6e4ffe834`. The build job's sha256, as passed to the publish and smoke jobs, is the same value. Release https://github.com/szTheory/fablebook/releases/tag/v0.1.0 is not a draft and has asset `fablebook-0.1.0.cdx.json`. The recovery path is `workflow_dispatch` on the same `hex-publish.yml` that the release called. `https://hexdocs.pm/fablebook/0.1.0/` answers 301 to `https://fablebook.hexdocs.pm/0.1.0/`, which answers 200. Release PR #3 was green with nightly before the merge: https://github.com/szTheory/fablebook/actions/runs/40803284536 |
| 2 | False `dev_routes` mount compiles in prod; an unguarded mount fails with the canonical CompileError; CI prod build asserts | core and floor ran the prod_guard tests on PR #1's last head: https://github.com/szTheory/fablebook/actions/runs/40797403231. The build job re-ran `--only release --only prod_guard` on tag v0.1.0 in the release run above |
| 3 | A fourth workflow, a long `ci.yml`, a removed ci-gate, an edited INT source, a malformed INT id or an uncited REQ line fails CI; weekly p50/p95 | D-22 red run, https://github.com/szTheory/fablebook/actions/runs/40802432347: the core log shows `intent sources are add-only` failing on `{"M", ".planning/intent/sources/2026-10-28-01-founding-brief.md"}`, and PR #4 was closed unmerged. The shape and intent rules run in every core job (above). Dispatched ci-health on main: https://github.com/szTheory/fablebook/actions/runs/40802440301. Timing comments: https://github.com/szTheory/fablebook/issues/2#issuecomment-6484861618 (local run) and https://github.com/szTheory/fablebook/issues/2#issuecomment-6485608501 (CI). Both are `not-run` because n is below 10 |
| 4 | Eval, runtime EEx, `String.to_atom`, a banned prod dep or a file outside the tarball allowlist fails CI | The ban, dependency-budget and tarball contract tests run in core on every PR (Plan 01-03), green at https://github.com/szTheory/fablebook/actions/runs/40797403231 |

The closing PR that carries this SUMMARY is the last piece of evidence. Its run is visible on that PR.

## Owner checkpoints

- **Task 2 (diff review and secrets):** the owner was shown the full amendment diff and PR #1. Their reply is recorded verbatim in INT-20261028-20 ("Okay, I did that. By the way, for the hex API key, 30 days is. ..."). They did not type the literal resume signal. The orchestrator and I checked the secret names only: RELEASE_PLEASE_TOKEN as a repository secret and HEX_API_KEY in hex-production. The PAT is fine-grained, scoped to szTheory/fablebook with Contents, Pull requests and Issues set to read and write, and expires on 2027-10-28.
- **Task 4 (publish):** the owner replied "publish".
- **Task 6 (rotation):** the owner replied "okay i did the hex api key one  and ir evoked the old one too".
  - The new key was created on the hex.pm dashboard. Its name is `github-actions-fablebook-publish`, its expiration is "No expiration", and its permission is Packages, fablebook, Publish only. That is narrower than `package:fablebook`: it has no API read or write and no other packages.
  - HEX_API_KEY `updated_at` is 2026-10-29T02:15:03Z, after the publish finished at 02:08:47Z. I re-checked it.
  - The revoke of the bootstrap key `github-actions-fablebook` is owner-reported. Nobody verified it independently.
  - **Residual risk (accepted in INT-20261028-20):** the publish key never expires, so a leaked key stays valid until someone revokes it by hand. Mitigations:
    - it can only publish to fablebook;
    - it is stored only as the hex-production environment secret, which deploys only from `main` and tags `v*`;
    - every publish compares the Hex checksum with the build output and fails closed on a mismatch.

## Accomplishments

- **Amendments (Task 1).** Each amended ADR's status line now reads `Amended 2026-10-28 (INT-20261028-18)`, its Decision bullets were edited in place, and it ends with an `## Amendments (release pipeline sign-off, 2026-10-28)` section.
  - ADR 0006: the guard code lives in the returned quote, the canonical first line is set, and the fixture is the CI target until hosts/operator exists.
  - ADR 0007: approve-all ranges and lanes, with a new title and index row.
  - ADR 0017: the publish flow, repo settings, job set, ci-health, the merge rule with T-01-37 accepted, and reusable calls.
  - ADR 0018: tool envs, no mix_audit, no sbom dep, and a definition of "banned".
  - ADR 0021: the D-21 guard-path table.
  - COMPAT-01 and the PROJECT.md mirrors cite INT-20261028-18. CLAUDE.md points the contract-test rule at ADR 0021.
- **ci-health live.** `bin/ci_health` ran against the live repository, posted `not-run (n=1)`, and found the ruleset contexts equal to `["ci-gate"]`.
- **PR #1 merged** as cee1113 under the all-checks merge rule. The push runs on main succeeded: release-please https://github.com/szTheory/fablebook/actions/runs/40802035201 and ci https://github.com/szTheory/fablebook/actions/runs/40802034909.
- **0.1.0 released.** The tarball holds `.formatter.exs`, `CHANGELOG.md`, `LICENSE`, `README.md`, `hex_metadata.config`, `mix.exs`, `usage-rules.md` and `lib/` (`fablebook.ex`, `fablebook/router.ex`, `fablebook/placeholder.ex`). It has 5 runtime requirements and no optional deps.
- **release-as dropped** in the closing PR. After that merge, release-please proposes no new version.

## PR and issue numbering

The plan's nominal numbers shifted once issue #2 took a number:

| Number | What |
|---|---|
| #1 | Phase PR, merged (cee1113) |
| #2 | Issue "CI timing", pinned |
| #3 | Release PR `chore(main): release 0.1.0`, merged (f4bb34f) |
| #4 | D-22 throwaway PR, closed unmerged |
| #5 | Empty CHANGELOG seed plus INT-20261028-20, merged (e331fdb) |
| #6 | STATE.md position at the publish gate, merged (05e1a79) |
| next | The closing PR: drops release-as, carries this SUMMARY (the plan's "PR #3") |

## Task Commits

The commits on main are squash merges, so topic-branch hashes are not ancestors of main.
1. **Task 1:** `233823c` on the PR branch, landed in `cee1113`.
2. **Task 3:**
   - D-22 commit `4302664`, on a deleted branch and never merged.
   - `e331fdb` (PR #5) and `05e1a79` (PR #6).
3. **Task 5:** `f4bb34f`, the release PR merge.
4. **Task 7:** the closing PR's commits.

`actuals.commits` is `git rev-list --count 16abf95..<plan_head_after>`: cee1113, e331fdb, 05e1a79, f4bb34f and the closing commit (release-as plus this SUMMARY). The STATE, ROADMAP and REQUIREMENTS bookkeeping commit follows it on the same branch. cee1113 also contains Plans 01-02 to 01-04, which were squashed with PR #1.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] The first release PR's CHANGELOG ended in a stray `## Changelog`**
- **Found during:** Task 3 (release PR review)
- **Issue:** the seed CHANGELOG.md held only `# Changelog`. When a file has no version header, release-please (`src/updaters/changelog.ts`) appends it below the new entry with H1 demoted. The mistake would have shipped permanently in the 0.1.0 tarball and on hexdocs.
- **Fix:**
  - PR #5 emptied the seed, which takes release-please's clean branch.
  - release-please refreshes an open PR only when the body differs, and runs only on a push to main. So I appended one line to PR #3's body and merged PR #6, a STATE.md position update.
  - release-please then rebuilt PR #3 on the new main, and the release PR went green again with nightly.
- **Files modified:** CHANGELOG.md, .planning/STATE.md
- **Commits:** e331fdb, 05e1a79

**2. [Plan text] Bootstrap key name**
- The plan says `fablebook-ci-bootstrap`. The owner named the key `github-actions-fablebook`, and the Task 6 instructions used that name.

**3. [Owner direction] No-expiry package key**
- **Plan said:** `--permission package:fablebook` with no stated expiry.
- **Owner chose:** a key with no expiration and Publish-only permission on fablebook (INT-20261028-20).

### Notes

- **hexdocs:** the plan's `curl -fsSI https://hexdocs.pm/fablebook/0.1.0/` sees a 301 to `fablebook.hexdocs.pm`, where the page answers 200. The release smoke's hexdocs check passed.
- **Untracked file:** `git status --porcelain` shows `.planning/state.json`. It was untracked before this plan and is left alone.
- **`.claude/CLAUDE.md`** is gitignored. It keeps the old `Phoenix ~> 1.8.16` Tech line until the next GSD profile sync.
- **CI-01 is not marked complete:** "PR p50 ≤ 7 min, measured from CI history" is `not-run` with n=2. The weekly ci-health job will publish real percentiles once n is at least 10.

## Issues Encountered

- `git pull --ff-only` on local main first failed because main had no upstream. I set `origin/main` as its upstream.
- **Flaky contract test (deferred, WINDOWS entry 2):** on the closing PR, floor attempt 1 failed in `prod_guard_test.exs:23`. The prod `phx.routes` output contained the dep-compile banner `==> fablebook / Generated fablebook app`, which matches `~r/fablebook/i` (https://github.com/szTheory/fablebook/actions/runs/40805617266). I re-ran it once to tell a flake from a real failure, and attempt 2 passed. The cause and fix direction are in `deferred-items.md`. The test is unchanged here, and the fix needs its own PR with no `lib/` or `.github/` changes.

## Next Phase Readiness

- main carries Phase 1 behind a green ci-gate, 0.1.0 is on Hex, and every Phase 1 SUMMARY is on main once the closing PR merges.
- Later bookkeeping (verification, STATE) must go through PRs, because the ruleset blocks direct pushes to main.
- **Open items:**
  - Q31 and Q32 stay open.
  - The PAT expires on 2027-10-28. Rotate it before then (D-10). Whether a reminder was set was not reported.

## Self-Check: PASSED

- The intent source, this SUMMARY and the amended ADRs exist. cee1113, e331fdb, 05e1a79, f4bb34f and f8e5a3b are ancestors of the closing branch head.
