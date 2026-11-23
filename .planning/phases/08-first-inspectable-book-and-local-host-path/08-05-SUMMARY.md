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
production-boundary checks pass after that fix. Draft PR [#106](https://github.com/szTheory/fablebook/pull/106)
is open for the isolated candidate. Its first required hosted run completed
with core and Dialyzer passing; security and floor failed on the two workflow
setup issues described in the resumption record. The targeted fixes pass local
Actionlint and floor production-boundary checks; exact-head hosted CI passed in
[run 45083323345](https://github.com/szTheory/fablebook/actions/runs/45083323345).
The owner deferred visual feedback until the end of v0.7 without making a final visual decision; phase verification and merge remain gated on that
decision (INT-20261122-02). This is not phase completion. The screenshot-free
head 6987359 passed required hosted CI in
[run 45087426149](https://github.com/szTheory/fablebook/actions/runs/45087426149).

## Delivered in the candidate

- One compiled, development/test-only Logistify operator Book with two stable
  source-backed Scenarios: failed shipment and bulk reassignment. Missing
  values remain explicitly absent; all records and actions are illustrative.
- Familiar Book → Journey → Scenario navigation, linked parent breadcrumbs,
  sibling Scenario links, and the real same-origin host Canvas. After owner
  feedback, the sidebar explicitly labels the child list “Scenarios.”
- Pinned public source manifest and verification tooling, source-pointer
  assertions, production exclusion controls, and isolated reachable-mount
  negative control. Exact citations stay in Scenario data and source checks;
  raw source paths and JSON Pointers are not rendered in the Canvas.
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
| `MIX_ENV=test bin/lane core mix ci` before sidebar/source-display correction | 467 passed, 10 configured exclusions; ExUnit 550.0 s |

After the sidebar/source-display correction, the focused operator-host suite
passed again (12 tests), the pinned source checker passed, and the host compiled
with warnings treated as errors. The test continues to verify the exact source
pointers in authored Scenario data and the pinned manifest while asserting
that the Canvas omits the raw paths and pointers.

The full core lane was repeated against this correction: 467 passed, 10
configured exclusions, ExUnit 597.6 s (99.3 s async, 498.3 s sync). The change
was pushed as head `44eff333b6156382949c04e0d178f6313a565d41`, and the exact
hosted run [45096943180](https://github.com/szTheory/fablebook/actions/runs/45096943180)
passed core, floor, security, Dialyzer, and the final gate.

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

## Live owner visual review

The owner requested a live browser review instead of public screenshots. The
local Book is open in Chrome at
`http://127.0.0.1:4003/admin/dev/fablebook/book/operator?scenario=bulk_reassignment`.
The active checkout reported `Screen ready`, displayed the explicit “Scenarios”
sidebar label, and omitted the raw source-pointer footer. The owner deferred
visual feedback until the end of v0.7; this live review does not accept or
reject the baseline.

## Delivery still open

- Screenshot-free PR #106 head `44eff333b6156382949c04e0d178f6313a565d41`
  passed exact-head hosted CI in run 45096943180. Keep the PR draft until the
  owner's end-of-milestone live visual decision.
- Merge only the exact reviewed green head and follow branch protection.
- At the end-of-milestone review, use the live local Book for the required
  owner visual-baseline decision before phase verification or merge.
- Record the actual PR, reviewed head, merge commit and hosted CI URL in the
  append-only delivery registry, then close v0.7 against its scoped
  requirements.

No release, deployment, publication or follow-on phase is included. The guard
aggregate remains open, `walking-skeleton` blocked, R9 denied and unconsumed,
SEC-01 Pending, and the one-Book exception expires at v0.7 closeout. The
2026-11-21 halted summary remains immutable at
[08-05-HALTED-SUMMARY-2026-11-21.md](08-05-HALTED-SUMMARY-2026-11-21.md).
