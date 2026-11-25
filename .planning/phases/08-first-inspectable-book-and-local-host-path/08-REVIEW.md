---
phase: 08-first-inspectable-book-and-local-host-path
reviewed: 2026-11-25T21:33:58Z
depth: standard
files_reviewed: 21
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
  - hosts/operator/priv/static/assets/brand/fablebook-lockup-small-light.svg
  - hosts/operator/priv/static/assets/fonts/OFL-SchibstedGrotesk.txt
  - hosts/operator/priv/static/assets/fonts/SchibstedGrotesk-Variable.ttf
  - hosts/operator/storybook/operator_book.ex
  - hosts/operator/test/operator_host_test.exs
  - hosts/operator/test/test_helper.exs
  - hosts/operator/unguarded/reachable_mount.ex
  - lib/fablebook/book_live.ex
  - lib/fablebook/catalog.ex
  - lib/fablebook/router.ex
  - lib/fablebook/story.ex
findings:
  critical: 1
  warning: 0
  info: 0
  total: 1
status: issues_found
---

# Phase 8: Code Review Report

**Reviewed:** 2026-11-25T21:33:58Z
**Depth:** standard
**Files Reviewed:** 21
**Status:** issues_found

## Summary

Reviewed the Phase 8 source changes against the active plans, UI contract, project instructions, and relevant ADRs. The library accepts multiple Stories, but Scenario selection in the Book UI identifies a Scenario by function name alone even though catalog validation allows that name to repeat in different Stories. A valid multi-Journey Book can therefore send every duplicate-named Scenario link to the first matching screen. Earlier Phase 8 review findings were checked against the current source and are recorded as resolved in the existing resolution artifact. No tests were run, per task scope.

## Critical Issues

### CR-01: [BLOCKER] Scenario links collide across Journeys

**File:** `lib/fablebook/catalog.ex:161-169`; `lib/fablebook/book_live.ex:75-80,147-153,365-370,385-387`
**Issue:** `ensure_unique_ids/1` considers `{story.id, scenario.id}` unique, so two different Stories may both contain a common function name such as `default`. But the Book UI flattens those entries, generates links containing only `?scenario=<id>`, and `select_entry/2` chooses the first entry with that ID. As a result, clicking the second Journey's `default` Scenario changes to the first Journey's screen; the sidebar can also mark both duplicate IDs as current. The catalog accepts this configuration, so the broken navigation is reachable for a valid multi-Story Book.
**Fix:** Carry both Story and Scenario IDs through Scenario selection and its stable route, and compare the pair when selecting/highlighting; alternatively, reject duplicate Scenario IDs globally before rendering if the query-only URL contract must remain.

---

_Reviewed: 2026-11-25T21:33:58Z_  
_Reviewer: the agent (gsd-code-reviewer)_  
_Depth: standard_
