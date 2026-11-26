# Phase 8 real-host browser record

**Status: browser behavior verified; owner accepted the live visual baseline
on 2026-11-25 (INT-20261125-04).** The readiness retry works in Chrome on the actual local Phoenix
host. After the owner reported a missing Scenario taxonomy label and noisy raw
source pointers, the active candidate now labels the sidebar's child list
“Scenarios” and keeps raw paths and JSON Pointers out of the Canvas. Exact
citations remain in the authored data and pinned manifest. No screenshot files
are included in the candidate or public PR. The owner accepted the live
failed-shipment baseline on 2026-11-25; see INT-20261125-04.

## Tested surface

- Checkout: active `gsd/phase-8-first-inspectable-book` candidate, based on
  `origin/main` `0e406e648d52b93da52f4d641116cfa28cf9bb6c`.
- Host: `http://127.0.0.1:4003/admin/dev/fablebook`, started with the operator
  host's development configuration. It is currently running for the owner's
  local visual review.
- Book route: `/admin/dev/fablebook/book/operator`.
- Stable Scenario routes: `/book/operator/journey/dispatcher_recovery?scenario=failed_shipment`
  and `/book/operator/journey/dispatcher_recovery?scenario=bulk_reassignment`.
- Both Scenarios loaded in Chrome and announced `Screen ready` automatically.
  The sidebar now reads Book → Journey → journey title → Scenarios → Scenario
  links. The Book breadcrumb is plain text, the Journey breadcrumb opens its overview,
  and sibling Scenario navigation remains present. The bulk Scenario shows the 12 reassignment count and source
  gaps, without printing raw paths or JSON Pointers in the Canvas.
- An unknown Scenario URL showed `Screen unavailable` and the approved
  unavailable copy while retaining the Book navigation path.
- The real host and same-origin Canvas LiveViews connected. The initial Book
  and Canvas requests returned HTTP 200; the server used its nonce-based
  same-origin CSP and `X-Frame-Options: SAMEORIGIN`.

## Canvas readiness and failure paths

The earlier browser run left the parent status on Loading although the Canvas
document and both LiveViews were connected. The cause was a one-shot status
request sent before the child hook had attached its listener. The host script
now retries the same-origin status request every 250 ms while the Canvas is
incomplete, and stops on ready, failure, or the existing eight-second timeout.

After a fresh Book load in Chrome, the valid failed-shipment Canvas announced
`Screen ready: Logistify operator console — A failed shipment.` without a
synthetic message or manual retry. I then changed only the iframe URL in
DevTools to an unknown Canvas route. The child displayed `Screen unavailable`,
and the parent reached the expected failure copy: `The screen could not load.
Check that the local Phoenix host is running, then reload.` The valid Book URL
was restored and returned to `Screen ready`.

## Responsive, zoom and keyboard checks

At each CSS viewport, the page and body scroll widths matched the viewport.
Canvas document width matched its own scroll width. These measurements were
taken before the JavaScript-only readiness fix; the responsive CSS is unchanged.

| Viewport | Page/body scroll width | Canvas document width/scroll width |
|---:|---:|---:|
| 320 px | 320 px | 254 / 254 px |
| 375 px | 375 px | 309 / 309 px |
| 768 px | 768 px | 408 / 408 px |
| 1280 px | 1280 px | 886 / 886 px |

Before the owner feedback correction, Chrome's zoom control was set to exactly
200%. The sidebar, selected Scenario, Canvas status, screen content and actions
remained available in the rendered/accessibility tree; the browser was returned
to 100% afterward. Keyboard traversal and a visible focus indicator were
observed in the earlier real-host check. The correction adds one sidebar label
and removes the Canvas citation footer; it does not change navigation or Canvas
layout CSS.

## Live owner visual review

Chrome is open to the local Book at
`http://127.0.0.1:4003/admin/dev/fablebook/book/operator?scenario=bulk_reassignment`.
The active checkout's host reported `Screen ready`; the rendered sidebar shows
“Scenarios” above the two Scenario links, and the Canvas shows the bulk result,
source gaps and illustrative action without the raw pointer list. Keep the
local host available for any further phase inspection. The owner accepted the
live failed-shipment baseline on 2026-11-25; see
[INT-20261125-04](../../intent/sources/2026-11-25-04-accept-phase8-visual-baseline.md).

## Owner correction live check — 2026-11-25

The listener at `127.0.0.1:4003` was verified against the active isolated
checkout at `/private/tmp/fablebook-v07-phase8-screenshot-free/hosts/operator`.
The persistent server runs the source after the correction, not an older build.

The Journey URL
`/admin/dev/fablebook/book/operator/journey/dispatcher_recovery` rendered two
Scenario cards in the main panel. Browser inspection confirmed the main panel
background is white, the selected Journey has the dark bookmark-shaped marker,
and the Book breadcrumb is not a link. The Scenario URL
`/admin/dev/fablebook/book/operator?scenario=bulk_reassignment` announced
`Screen ready`; its selected sidebar Scenario retained the bookmark marker,
and both the main panel and Canvas document computed to white.

The changed interactions and style are covered by the operator-host route and
stylesheet regression checks. This is live local review evidence; no screenshot
was kept in the checkout or added to the public PR. The owner accepted the
live failed-shipment baseline on 2026-11-25; no baseline was auto-accepted.

## Journey-scoped Scenario route regression — 2026-11-25

Code review found that the catalog permits the same Scenario function name in
different Journeys, while a query-only Scenario URL selected by name alone.
Scenario links now include the Journey in their route, selection and sidebar
highlighting compare the Story/Scenario pair, and an ambiguous legacy query-only
URL safely shows the unavailable state. The focused operator-host suite passes
15 tests, including a compiled two-Journey fixture where both Journeys define
`default`. The accepted Book presentation is unchanged; no screenshot was kept
or added to the public PR. The corrected route is
`/admin/dev/fablebook/book/operator/journey/dispatcher_recovery?scenario=failed_shipment`.

## Remaining human judgment and safety stops

The required owner visual judgment is complete: the current failed-shipment
baseline was explicitly accepted, not auto-accepted. Browser mechanics,
readiness, failure copy and responsive behavior have automated or directly
observed evidence.

The known local `act` ARM64/amd64 setup failure is unchanged and was not retried.
The guard aggregate remains open, `walking-skeleton` remains blocked, R9 remains
denied and unconsumed, and SEC-01 remains Pending. No release, deployment,
publication or follow-on phase is included.
