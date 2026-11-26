---
status: complete
phase: first-inspectable-book-and-local-host-path
source:
  - 08-01-SUMMARY.md
  - 08-02-SUMMARY.md
  - 08-03-SUMMARY.md
  - 08-04-SUMMARY.md
  - 08-05-SUMMARY.md
started: 2026-11-25T21:26:08Z
updated: 2026-11-26T03:06:42Z
---

## Current Test

[testing complete]

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
source: automated and owner-accepted browser evidence
evidence: The 15-test focused host suite passes locally after the Journey/Scenario collision fix, including two Journeys with a shared `default` Scenario name and an ambiguous legacy URL failure path. `08-BROWSER.md` records live Chrome checks of the ready and failure states, same-origin Canvas, navigation, accessibility tree, and the accepted white main/Canvas surfaces. The owner accepted those recorded ready/failure observations as sufficient manual lifecycle evidence in [INT-20261125-05](../../intent/sources/2026-11-25-05-accept-canvas-lifecycle-browser-evidence.md); the repository has no automated JavaScript transition test.

### 4. Responsive, zoom, and keyboard behavior
expected: The browser record demonstrates the planned narrow and desktop widths, 200% zoom, keyboard traversal, and visible focus without page-level horizontal overflow.
result: pass
source: automated
evidence: `08-BROWSER.md` records viewport measurements at 320, 375, 768, and 1280 CSS pixels, 200% zoom, keyboard traversal, and focus. The latest focused host suite protects the changed navigation, bookmark and surface behavior.

### 5. Reviewed hosted delivery checks
expected: The screenshot-free Phase 8 candidate passes the required CI jobs on its exact reviewed code head, with no screenshot or unreviewed source repository in the PR.
result: pass
source: automated
evidence: The corrected source review is clean in `08-REVIEW.md`. The full local core lane passed against source content committed as `a339f67f5c2e8afb6cec68e216639b785cac694c`: 467 passed, 10 configured exclusions, ExUnit 652.3s. Strict Credo and the focused operator-host suite (15 passed) also pass. Screenshot-free PR #106 head `2e648f5efa4c440541d0cd25b397370d8637af05` passed core, floor, Dialyzer, security, and `ci-gate` in [exact-head hosted CI run 45713720366](https://github.com/szTheory/fablebook/actions/runs/45713720366). The prior head's green receipt predates the route fix.

### 6. Owner visual-baseline acceptance
expected: The owner accepts the live failed-shipment Book shown as the Phase 8 visual baseline.
result: pass
source: owner
evidence: The owner replied “accepted” during the live visual review. The exact response and scope are recorded in [INT-20261125-04](../../intent/sources/2026-11-25-04-accept-phase8-visual-baseline.md).

## Summary

total: 6
passed: 6
issues: 0
pending: 0
skipped: 0
blocked: 0

## Gaps

No Phase 8 UAT gaps remain. This UAT does not change the open guard aggregate, blocked `walking-skeleton`, denied and unconsumed R9, or Pending SEC-01 status. Phase goal verification passed and ship preflight is clear. Final exact-head hosted CI, merge, delivery receipt, and v0.7 closeout remain.
