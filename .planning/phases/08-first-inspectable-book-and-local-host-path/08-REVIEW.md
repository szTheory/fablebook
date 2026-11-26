---
phase: 08-first-inspectable-book-and-local-host-path
reviewed: 2026-11-26T02:07:16Z
depth: standard
files_reviewed: 3
files_reviewed_list:
  - hosts/operator/priv/static/assets/app.css
  - hosts/operator/test/operator_host_test.exs
  - lib/fablebook/book_live.ex
findings:
  critical: 0
  warning: 1
  info: 0
  total: 1
  necessity: 0
status: issues_found
---

# Phase 8: Code Review Report

**Reviewed:** 2026-11-26T02:07:16Z
**Depth:** standard  
**Files Reviewed:** 3  
**Status:** issues_found

## Summary

This is the incremental standard-depth review of the three source files changed by Plan 08-06. The previous 2026-11-25 report covered `hosts/operator/README.md`, `hosts/operator/test/operator_host_test.exs`, and `lib/fablebook/book_live.ex` at that earlier revision and found no issues. This pass does not claim to re-review the README or the earlier Plan 08-01–08-05 scope. It found one accessibility-contract warning in the Canvas unavailable path. The necessity assessment found no unnecessary guard or abstraction in the reviewed changes. Tests were not run.

## Narrative Findings (AI reviewer)

### Warnings

#### WR-01: Canvas unavailable response has no main landmark

**File:** `lib/fablebook/book_live.ex:194-207`
**Category:** accessibility contract
**Issue:** The Canvas wrapper changed from `<main>` to `<div>` so a valid Scenario can own a `main` landmark and the notice can remain its sibling footer. When a Canvas route is unknown, non-canonical, or otherwise unresolved, `assign_canvas/3` falls back to `unavailable_socket/1`, leaving `@live_action == :canvas`, `@unavailable` true, and `@scenario_result` nil (`lib/fablebook/book_live.ex:290-314`). The branch at line 207 then renders `.unavailable_state` directly under the wrapper; that component renders a section, not a main landmark. The unavailable Canvas page therefore has no `main`, contrary to the UI-SPEC's landmark contract. The existing unknown/missing-route test checks the message and return link but not landmark presence (`hosts/operator/test/operator_host_test.exs:483-499`).

**Fix:** Give the Canvas unavailable state its own `<main>` inside `.canvas-document` (while keeping the successful Scenario `<main>` and sibling footer structure), and assert the unknown Canvas route exposes that landmark.

---

_Reviewed: 2026-11-26T02:07:16Z_
_Reviewer: the agent (gsd-code-reviewer)_
_Depth: standard_
