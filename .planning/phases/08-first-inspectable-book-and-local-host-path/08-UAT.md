---
status: testing
phase: first-inspectable-book-and-local-host-path
source:
  - 08-01-SUMMARY.md
  - 08-02-SUMMARY.md
  - 08-03-SUMMARY.md
  - 08-04-SUMMARY.md
  - 08-05-SUMMARY.md
started: 2026-11-25T21:26:08Z
updated: 2026-11-25T22:28:31Z
---

## Current Test

5. Reviewed hosted delivery checks

## Tests

### 1. Pinned source and cited Book data
expected: The source pins and excerpt checks pass, and the authored Book uses only supported facts while preserving missing values and illustrative actions.
result: pass
source: automated
evidence: `08-01-SUMMARY.md` records the pin, original-file hash, excerpt, and tamper-control checks. The post-correction pinned-source check passed on PR code head `df078bd45fd9433d98e229d34bea9f5583d40354`; the focused operator suite passes 15 tests after the local route correction and asserts the fixed Scenario data and citations.

### 2. Mount contract and production boundary
expected: The literal-only Book mount contract remains active, the actual host includes its catalog only in development/test, and the isolated production negative control emits the canonical rejection.
result: pass
source: automated
evidence: `08-02-SUMMARY.md` and `08-03-SUMMARY.md` record the separate test-only contract delivery and green CI. `08-04-SUMMARY.md` records both core and floor production-boundary controls; the 15-test host suite passes locally after the route correction.

### 3. Book, Journey, Scenario, and Canvas behavior
expected: The fixed Book opens a stable source-cited Scenario, Journey and Scenario navigation work, Canvas ready state is accessible without a visible status line, actual failure guidance is visible, and actions remain illustrative.
result: pass
source: automated
evidence: The 15-test focused host suite passes locally after the Journey/Scenario collision fix, including two Journeys with a shared `default` Scenario name and an ambiguous legacy URL failure path. `08-BROWSER.md` records live Chrome checks of the ready and failure states, same-origin Canvas, navigation, accessibility tree, and the accepted white main/Canvas surfaces; the route fix does not change the visible layout.

### 4. Responsive, zoom, and keyboard behavior
expected: The browser record demonstrates the planned narrow and desktop widths, 200% zoom, keyboard traversal, and visible focus without page-level horizontal overflow.
result: pass
source: automated
evidence: `08-BROWSER.md` records viewport measurements at 320, 375, 768, and 1280 CSS pixels, 200% zoom, keyboard traversal, and focus. The latest focused host suite protects the changed navigation, bookmark and surface behavior.

### 5. Reviewed hosted delivery checks
expected: The screenshot-free Phase 8 candidate passes the required CI jobs on its exact reviewed code head, with no screenshot or unreviewed source repository in the PR.
result: pending
source: automated
evidence: The corrected source review is clean in `08-REVIEW.md`. The full local core lane passed against source content committed as `a339f67f5c2e8afb6cec68e216639b785cac694c`: 467 passed, 10 configured exclusions, ExUnit 652.3s. Strict Credo and the focused operator-host suite (15 passed) also pass. Previous PR code head `df078bd45fd9433d98e229d34bea9f5583d40354` passed core, floor, Dialyzer, security, and `ci-gate` in [hosted CI run 45691480908](https://github.com/szTheory/fablebook/actions/runs/45691480908), but that receipt predates this fix. Exact-head hosted CI for the corrected candidate is still required after final phase artifacts are committed and pushed.

### 6. Owner visual-baseline acceptance
expected: The owner accepts the live failed-shipment Book shown as the Phase 8 visual baseline.
result: pass
source: owner
evidence: The owner replied “accepted” during the live visual review. The exact response and scope are recorded in [INT-20261125-04](../../intent/sources/2026-11-25-04-accept-phase8-visual-baseline.md).

## Summary

total: 6
passed: 5
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps

Only the required hosted CI check for the corrected candidate remains pending. This UAT does not change the open guard aggregate, blocked `walking-skeleton`, denied and unconsumed R9, or Pending SEC-01 status. The PR still needs phase goal verification, ship review, exact-head merge, and delivery receipt before v0.7 can close.
