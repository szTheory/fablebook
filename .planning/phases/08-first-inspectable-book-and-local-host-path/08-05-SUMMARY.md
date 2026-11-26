---
phase: first-inspectable-book-and-local-host-path
plan: "05"
subsystem: book-flow-and-delivery-verification
completed: 2026-11-26
status: complete
requirements-completed: [SRC-01, HOST-01, HOST-02, CAT-01, CAT-02, CANVAS-01, BOOK-01]
coverage:
  - id: BOOK-01
    description: "The selected source-cited Book and Scenario render through the development host with the approved navigation, accessible readiness state, visible failure guidance, and illustrative actions."
    requirement: BOOK-01
    verification:
      - kind: integration
        ref: "hosts/operator/test/operator_host_test.exs: 15 focused tests passed locally after the Journey/Scenario collision fix"
        status: pass
      - kind: automated_ui
        ref: "08-BROWSER.md: current live Chrome ready/failure DOM checks and same-origin Canvas evidence"
        status: pass
      - kind: other
        ref: "https://github.com/szTheory/fablebook/actions/runs/45713720366 on exact PR head 2e648f5efa4c440541d0cd25b397370d8637af05; core, floor, Dialyzer, security, and ci-gate passed"
        status: pass
    human_judgment: false
  - id: VISUAL-BASELINE
    description: "The owner accepts the live failed-shipment Book shown as the Phase 8 visual baseline."
    verification:
      - kind: manual_procedural
        ref: "INT-20261125-04: direct owner acceptance during the live review at /admin/dev/fablebook/book/operator?scenario=failed_shipment"
        status: pass
    human_judgment: true
    rationale: "Visual baseline acceptance requires owner judgment; the owner's explicit acceptance is recorded in INT-20261125-04."
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
The owner explicitly accepted the live failed-shipment visual baseline on
2026-11-25 (INT-20261125-04), clearing that gate. Phase verification, exact-head
delivery and merge remain; this is not phase completion. The screenshot-free
head 6987359 passed required hosted CI in
[run 45087426149](https://github.com/szTheory/fablebook/actions/runs/45087426149).

## Delivered in the candidate

- One compiled, development/test-only Logistify operator Book with two stable
  source-backed Scenarios: failed shipment and bulk reassignment. Missing
  values remain explicitly absent; all records and actions are illustrative.
- Book → Journey → Scenario navigation, a Journey overview with Scenario
  links, plain-text Book breadcrumb, clickable Journey breadcrumb, sibling
  Scenario links, and the real same-origin host Canvas. The active sidebar
  item uses its bookmark marker.
- Pinned public source manifest and verification tooling, source-pointer
  assertions, production exclusion controls, and isolated reachable-mount
  negative control. Exact citations stay in Scenario data and source checks;
  raw source paths and JSON Pointers are not rendered in the Canvas.
- A Canvas status handshake that retries every 250 ms while incomplete and
  stops on ready, failure, or the existing eight-second timeout.

## Validation after the readiness fix

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
sidebar label, and omitted the raw source-pointer footer. On 2026-11-25 the
owner explicitly accepted the live failed-shipment baseline; see
[INT-20261125-04](../../intent/sources/2026-11-25-04-accept-phase8-visual-baseline.md).

## Owner correction and regression repair — 2026-11-25

The live Phase 8 UI had drifted from the owner-reviewed behavior. The active
branch sent a Journey click to its first Scenario, omitted the selected
bookmark marker, used Paper for the main panel and Canvas document, and kept an
ineffective Book breadcrumb link. Port 4003 was serving the intended Phase 8
checkout; this was a source/spec regression, not a stale server or wrong port.

Restored the Journey overview with links to both Scenarios, a plain Book
breadcrumb, a Journey breadcrumb that opens the overview, the bookmark marker
for the active sidebar item, and white main/Canvas surfaces. Added a focused
regression test for those behaviors and recorded the correction in the dated
intent source, UI-SPEC, and owner feedback ledger. The canonical dirty primary
checkout was left untouched.

The operator-host suite now passes 13 tests. The local browser rendered the
Journey route with two Scenario cards, white main panel, visible bookmark and a
non-link Book crumb. The bulk Scenario announced `Screen ready`; both the main
panel and same-origin Canvas document computed to white. Port 4003's listener
cwd was confirmed as this isolated Phase 8 checkout. No screenshot artifact
was added to the public PR.

The owner feedback ledger now requires resumed UI work to reconcile current
source, plan, UI-SPEC and last reviewed live behavior before edits, and to
verify the browser against a persistent server whose listener matches the
intended checkout. The project session instructions now require the same
reconciliation before resumed UI implementation. The owner said the restored
preview looks better and is on the right path; the end-of-milestone visual
baseline decision remains deferred and has not been treated as acceptance.

## Owner feedback follow-up — 2026-11-25

The owner then flagged the visible “Loading screen: A failed shipment…” line
above an already painting Scenario and said the “Canvas” heading was
self-evident. Eight fresh pre-fix browser loads had all reached `Screen ready`
by the time they were sampled, with the embedded document complete. The image
therefore showed the transient readiness handshake rather than a stuck Canvas.

Removed the visible Canvas heading. The section now has the accessible name
“Scenario screen”; transient loading/readiness lines stay in the polite live
region for assistive technology but use a visually hidden utility. A real
failure removes that utility and keeps the recovery guidance visible. A focused
regression test checks the status semantics, state-based visibility and absence
of a visible Canvas heading. The operator-host suite passes 14 tests, and formatter plus
`git diff --check` passed. The previous server had the right checkout as its
working directory but retained old in-memory markup; restarting the recorded
PID from that checkout loaded the correction. The live Chrome DOM now shows the
failed-shipment frame complete, the ready status in the accessibility tree,
and no visible Canvas heading; actual failure guidance remains visible. The
local preview is open at
`http://127.0.0.1:4003/admin/dev/fablebook/book/operator?scenario=failed_shipment`.
No screenshot was added to PR #106. The correction is at screenshot-free head
`df078bd45fd9433d98e229d34bea9f5583d40354`; all required jobs passed exact-head
hosted CI in [run 45691480908](https://github.com/szTheory/fablebook/actions/runs/45691480908).
The PR body describes the quiet status behavior and the prior CI receipt. The
owner later accepted the visual baseline. Phase verification and merge remain
open while the reviewed Journey/Scenario collision fix receives fresh review
and exact-head CI.

The completed CI run took 12m27s: core 12m18s (`mix ci` 11m04s), floor 9m50s
(floor test 8m47s), security 42s, Dialyzer 23s, and gate 4s. Core and floor
overlapped. This sample is slower than the prior green head, mainly in the core
test step, but does not establish a recurring regression or justify changing
the required lanes. Measurements are recorded in
[CI-PERFORMANCE.md](../../CI-PERFORMANCE.md).

## Delivery still open

- Screenshot-free PR #106 remains draft at head
  `2e648f5efa4c440541d0cd25b397370d8637af05`. All required jobs passed on that
  exact head in [run 45713720366](https://github.com/szTheory/fablebook/actions/runs/45713720366).
  The clean source review, owner acceptance and completed UAT are recorded.
  Phase goal verification passed at 46/46 and the ship preflight is clear.
  Any evidence commit that advances the PR head needs its own green required
  CI before merge.
- Follow branch protection when merging the exact reviewed green head.
- Record the actual PR, reviewed head, merge commit and hosted CI URL in the
  append-only delivery registry, then close v0.7 against its scoped
  requirements.

No release, deployment, publication or follow-on phase is included. The guard
aggregate remains open, `walking-skeleton` blocked, R9 denied and unconsumed,
SEC-01 Pending, and the one-Book exception expires at v0.7 closeout. The
2026-11-21 halted summary remains immutable at
[08-05-HALTED-SUMMARY-2026-11-21.md](08-05-HALTED-SUMMARY-2026-11-21.md).

## Journey/Scenario route collision fix — 2026-11-25

The Phase 8 source review found that two valid Journeys could both contain a
Scenario named `default`, while Book selection used that Scenario name alone.
Scenario links now include their Journey path; selection and sidebar state use
the Journey/Scenario pair, and ambiguous legacy query-only URLs fail safely.
The focused operator-host suite passes 15 tests, including a two-Journey
duplicate-name fixture. The accepted visual layout is unchanged. The final
standard-depth source review is clean. Strict Credo and the full core lane pass
on the corrected source; the lane reports 467 passed, 10 configured exclusions
and 652.3s in ExUnit. Its first attempt stopped at Credo's nesting limit before
tests; extracting `assign_journey_selection/5` fixed that issue. The corrected
candidate passed core, floor, Dialyzer, security and `ci-gate` on exact PR head
`2e648f5efa4c440541d0cd25b397370d8637af05` in hosted run
[45713720366](https://github.com/szTheory/fablebook/actions/runs/45713720366).
Phase goal verification subsequently passed at 46/46, UAT completed 6/6, and
the ship preflight passed. The final evidence candidate still needs green
required CI on its exact pushed PR head before merge.
