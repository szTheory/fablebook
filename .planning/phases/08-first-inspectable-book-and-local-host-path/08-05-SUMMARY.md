---
phase: first-inspectable-book-and-local-host-path
plan: "05"
subsystem: book-flow-and-delivery-verification
completed: 2026-11-22
status: executing
requirements-completed: []
---

# Phase 8 Plan 08-05 — Current execution summary

The fixed, source-cited operator Book now loads through the local Phoenix
Canvas path, and the readiness retry is verified in Chrome. Local tests and
production-boundary checks pass after that fix. The candidate has not yet been
pushed or opened as a PR. Required hosted CI and owner approval of the current
visual baseline are still outstanding, so this is not phase completion.

## Delivered in the candidate

- One compiled, development/test-only Logistify operator Book with two stable
  source-backed Scenarios: failed shipment and bulk reassignment. Missing
  values remain explicitly absent; all records and actions are illustrative.
- Familiar Book → Journey → Scenario navigation, linked parent breadcrumbs,
  sibling Scenario links, and the real same-origin host Canvas.
- Pinned public source manifest and verification tooling, source-pointer
  assertions, production exclusion controls, and isolated reachable-mount
  negative control.
- A Canvas status handshake that retries every 250 ms while incomplete and
  stops on ready, failure, or the existing eight-second timeout.

## Verification after the readiness fix

| Check | Result |
|---|---|
| `bin/planning_health --stage execute --phase 8` | Passed |
| `bin/fetch_brand_sources --self-test` | Passed |
| `bin/verify_logistify_source --self-test` | Passed |
| `bin/verify_logistify_source --check-pinned` | Passed |
| Operator host tests, core dependency lane | 12 passed |
| Operator host tests, floor dependency lane | 12 passed |
| `bin/verify_operator_host_prod` | Passed |
| `FABLEBOOK_FLOOR=1 bin/verify_operator_host_prod` | Passed |
| `MIX_ENV=test bin/lane core mix ci` | 467 passed, 10 configured exclusions; ExUnit 550.0 s |

The prior full floor lane passed 477 tests with 6 configured exclusions. The
readiness fix only changed host JavaScript; the post-fix floor host suite and
production verifier both passed again. The local `act` ARM64/amd64 setup
failure is unchanged and was not retried.

The original deep review's two findings are resolved. The later JavaScript
readiness retry received an additional focused review; no new issue was found.
See [candidate review](08-CANDIDATE-REVIEW-2026-11-22.md) and
[resolution](08-CANDIDATE-REVIEW-RESOLUTION-2026-11-22.md).

## Real-host browser evidence

Chrome confirmed both stable Scenarios automatically announce `Screen ready`.
An unknown Scenario route displayed the unavailable copy and retained Book
navigation. For the failure path, DevTools changed only the iframe URL to an
unknown Canvas route; the Canvas showed `Screen unavailable`, the parent
reached its approved reload guidance, and restoring the Book route returned to
ready. At 200% browser zoom, the navigation, status and screen content remained
available. Responsive measurements at 320, 375, 768 and 1280 CSS pixels showed
no page-level horizontal overflow; keyboard traversal and visible focus were
observed. Details and exact measurements are in [08-BROWSER.md](08-BROWSER.md).

Current captures:

- [320 px viewport](artifacts/08-05-mobile-320-ready.png)
- [320 px full page](artifacts/08-05-mobile-320-ready-full.png)
- [1280 px full page](artifacts/08-05-desktop-1280-ready-full.png)

Codex inspected the captures for clarity and hierarchy. They remain a proposed
baseline; owner approval is required and has not been inferred.

## Delivery still open

- Rerun `git diff --check` after the final documentation edits and review the
  exact outbound diff.
- Push the isolated candidate and open its Phase 8 PR under the existing
  authorization. Obtain green required hosted checks on the exact reviewed
  head; merge only that head and follow branch protection.
- Present the current captures for the required owner visual-baseline decision
  before claiming visual acceptance or closing the phase.
- Record the actual PR, reviewed head, merge commit and hosted CI URL in the
  append-only delivery registry, then close v0.7 against its scoped
  requirements.

No release, deployment, publication or follow-on phase is included. The guard
aggregate remains open, `walking-skeleton` blocked, R9 denied and unconsumed,
SEC-01 Pending, and the one-Book exception expires at v0.7 closeout. The
2026-11-21 halted summary remains immutable at
[08-05-HALTED-SUMMARY-2026-11-21.md](08-05-HALTED-SUMMARY-2026-11-21.md).
