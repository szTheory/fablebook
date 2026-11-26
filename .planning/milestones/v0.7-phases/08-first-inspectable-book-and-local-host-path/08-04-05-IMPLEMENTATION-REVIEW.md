---
phase: 08-first-inspectable-book-and-local-host-path
reviewed: 2026-11-21T14:39:40Z
depth: deep
files_reviewed: 21
files_reviewed_list:
  - lib/fablebook/router.ex
  - lib/fablebook/story.ex
  - lib/fablebook/catalog.ex
  - lib/fablebook/book_live.ex
  - hosts/operator/lib/operator_host.ex
  - hosts/operator/priv/static/assets/app.js
  - hosts/operator/priv/static/assets/app.css
  - hosts/operator/unguarded/reachable_mount.ex
  - hosts/operator/mix.lock
  - hosts/operator/config/config.exs
  - hosts/operator/test/test_helper.exs
  - hosts/operator/test/operator_host_test.exs
  - hosts/operator/mix.exs
  - hosts/operator/storybook/operator_book.ex
  - test/contract/mount_literal_ast_test.exs
  - .github/workflows/ci.yml
  - bin/verify_operator_host_prod
  - bin/fetch_brand_sources
  - bin/verify_logistify_source
  - brand_sources.lock.json
  - .planning/phases/08-first-inspectable-book-and-local-host-path/08-LOGISTIFY-SOURCE.json
findings:
  critical: 2
  warning: 3
  info: 0
  total: 5
  necessity: 0
status: issues_found
---

# Phase 8: Implementation Review

## Summary

Reviewed the current 08-04/08-05 source against both plans, ADR 0021, the source manifest, and the approved one-Book/local-host limits. The candidate has two delivery blockers: the contract-test diff is bundled with guarded implementation changes, and CI does not run the pinned-source/manifest verification required for the displayed claims. Three warnings cover the static session secret, the Canvas failure state, and host/core lock drift. No broad or focused suites were rerun; prior focused results were supplied for this review.

## Narrative Findings (AI reviewer)

### CR-01 [BLOCKER]: Contract test is changed with its implementation

**File:** `test/contract/mount_literal_ast_test.exs:90-136`; `lib/fablebook/router.ex:26-57`; `.github/workflows/ci.yml:32-46`
**Issue:** The current candidate changes a file under `test/contract/**` together with `lib/**` and `.github/**`. ADR 0021 explicitly forbids that combination, and its path rule applies to modified as well as added files. The router change is in the same candidate as the AST contract test update.
**Fix:** Keep the contract test unchanged in the implementation delivery, or deliver any required contract-test edit in its own test-only PR, preserving the ADR 0021 separation.

### CR-02 [BLOCKER]: CI omits the pinned-source manifest check

**File:** `.github/workflows/ci.yml:39-46,68-75`; `hosts/operator/storybook/operator_book.ex:20-77`; `hosts/operator/test/operator_host_test.exs:23-41,125-135`
**Issue:** Both lanes fetch the pinned repositories and run only `--check-original`, which checks the three brand files. CI never runs `bin/verify_logistify_source --check-pinned`, the 08-05 required check that verifies the locked commit and the cited `records/logistify/logistify-records.json` excerpts against `08-LOGISTIFY-SOURCE.json`. The host tests assert only a subset of visible facts/actions and citations, so a changed record or unsupported displayed claim can escape the recurring checks.
**Fix:** Run `--check-pinned` in the core and floor jobs, and assert every displayed source-derived field/action and its exact citation against the verified manifest.

### WR-01 [WARNING]: Session signing key is checked into shared config

**File:** `hosts/operator/config/config.exs:10-12`
**Issue:** `secret_key_base` is a deterministic literal in config loaded for dev, test, and prod. Anyone with the source can derive valid signed session material if this endpoint is exposed. The current production controls disable serving, but the value also misses 08-04's requirement that local signing material be generated or supplied locally.
**Fix:** Load a local ignored/env-provided key in dev and require a secret from the environment in prod; use a deterministic test-only value for tests.

### WR-02 [WARNING]: Canvas load failures remain labeled incomplete

**File:** `hosts/operator/priv/static/assets/app.js:36-61,63-78`; `hosts/operator/lib/operator_host.ex:29-53`
**Issue:** The shell reaches the required failure copy only from the iframe `error` listener or a thrown `postMessage`. A same-origin HTTP error document loads without the Canvas hook that sends `ready`/`failed`, so the load handler starts the incomplete timer and the UI stays in “still loading” instead of showing the 08-05 Canvas failure message.
**Fix:** Have the same-origin error/unavailable document signal failure to the shell, or verify a Canvas readiness marker after load and transition missing/failed content to the prescribed failure state.

### WR-03 [WARNING]: Operator core lock does not preserve the reviewed core pins

**File:** `hosts/operator/mix.lock:7,9,12`; `mix.lock:16,18,21`; `.planning/phases/08-first-inspectable-book-and-local-host-path/08-04-PLAN.md:112`
**Issue:** The operator lock uses Phoenix 1.8.17 and LiveView 1.2.15 while the root core lock uses Phoenix 1.8.16 and LiveView 1.2.14 (Plug matches). That means the core host integration check is not running against the reviewed core dependency set, contrary to the plan's pin-alignment requirement.
**Fix:** Align the operator's non-adapter core entries with the existing root core lock; leave the root lockfiles unchanged.

## Remaining blockers

- The checkout does not yet contain `hosts/operator/README.md`, `08-BROWSER.md`, or `08-05-SUMMARY.md`. The documented launch path, real-browser fidelity/accessibility checks, and final acceptance receipt remain unproven.
- The inherited root security constraint remains: root core is on LiveView 1.2.14 after the recorded rebaseline, while the root floor lock remains on 1.2.9. This review does not expand scope to dependency upgrades.

_Reviewed: 2026-11-21T14:39:40Z_
_Reviewer: gsd-code-reviewer_
_Depth: deep_
