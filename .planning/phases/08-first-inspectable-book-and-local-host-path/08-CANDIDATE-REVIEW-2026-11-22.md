---
phase: 08-first-inspectable-book-and-local-host-path
reviewed: 2026-11-22T22:10:04Z
depth: deep
files_reviewed: 18
files_reviewed_list:
  - .github/workflows/ci.yml
  - bin/verify_operator_host_prod
  - hosts/operator/README.md
  - hosts/operator/config/config.exs
  - hosts/operator/config/runtime.exs
  - hosts/operator/config/test.exs
  - hosts/operator/lib/operator_host.ex
  - hosts/operator/mix.exs
  - hosts/operator/priv/static/assets/app.css
  - hosts/operator/priv/static/assets/app.js
  - hosts/operator/storybook/operator_book.ex
  - hosts/operator/test/operator_host_test.exs
  - hosts/operator/test/test_helper.exs
  - hosts/operator/unguarded/reachable_mount.ex
  - lib/fablebook/book_live.ex
  - lib/fablebook/catalog.ex
  - lib/fablebook/router.ex
  - lib/fablebook/story.ex
findings:
  critical: 0
  warning: 2
  info: 0
  total: 2
status: issues_found
---

# Phase 8: Code Review Report

**Reviewed:** 2026-11-22T22:10:04Z
**Depth:** deep
**Files Reviewed:** 18
**Status:** issues_found

## Summary

Reviewed the candidate source changes, traced the mount through the compiled catalog, LiveView routes, host pipeline, Canvas status hook, and production boundary script, and cross-checked the Phase 8 plans and relevant ADRs. Two warnings remain: CI no longer runs the source tooling self-tests, and the Book test does not verify displayed source values against the cited source pointers. No blocker was confirmed. Tests were not run, and the final real-browser readiness recheck and current screenshots remain outstanding; this review does not treat either as passed.

## Warnings

### WR-01: CI drops source tooling self-tests

**File:** `.github/workflows/ci.yml:39-40`
**Severity:** WARNING
**Issue:** The previous core job ran `bin/fetch_brand_sources --self-test` and `bin/verify_logistify_source --self-test`. The updated job runs only the pinned-source fetch and verifier. Those self-tests exercise failure cases including incorrect commit/repository pins, cache tampering, excerpt corruption, and bad provenance; running the successful pinned path does not cover those controls. No other caller for these self-tests exists in the repository.
**Fix:** Restore both self-test commands in the core job before the normal pinned-source checks. Keep the host checks in addition to those regression checks.

### WR-02: Citation test does not bind displayed values to cited data

**File:** `hosts/operator/test/operator_host_test.exs:307-315`
**Severity:** WARNING
**Issue:** For each citation, the test verifies that its JSON Pointer resolves to something other than `:missing`, then verifies only that the manifest has a nonempty claim. The displayed fact/action text is separately compared with a hard-coded expectation, but the test never compares that text or value with the value at its cited pointer. A source-backed field can therefore drift away from the source while the citation test still passes, contrary to the plan's requirement to assert displayed fields and actions against the pinned source capsule.
**Fix:** Resolve each expected pointer from the decoded source records and assert the displayed field/action equals the pointed source value (or the explicitly documented transformation of that value). For the manifest, decode and compare the cited excerpt value as well as checking that the pointer exists.

---

_Reviewed: 2026-11-22T22:10:04Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: deep_
