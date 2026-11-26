---
phase: 08-first-inspectable-book-and-local-host-path
plan: "06"
subsystem: ui
tags: [phoenix, liveview, css, accessibility]
requires:
  - phase: 08-05
    provides: Stable Journey, Scenario, and same-origin Canvas navigation
provides:
  - Persistent Canvas notice exposed as a semantic footer with approved copy
  - Catalog CSS accessibility contracts for contrast, focus, targets, type, and spacing
  - Browser geometry evidence for narrow layouts and 200% text sizing
affects: [operator-host, phase-8-verification, catalog-accessibility]
actuals:
  tokens: 4263
  tasks: 2
  commits: 2
tech-stack:
  added: []
  patterns:
    - CSS contract tests compute contrast from the declared catalog colors
    - Mobile catalog layout is checked against live Canvas geometry
key-files:
  created: []
  modified:
    - lib/fablebook/book_live.ex
    - hosts/operator/priv/static/assets/app.css
    - hosts/operator/test/operator_host_test.exs
key-decisions:
  - "Keep the Canvas document and authored Scenario styling unchanged; fit narrow screens through catalog-shell spacing and wrapping."
  - "Keep 44px compact Scenario targets while reducing mobile horizontal padding to fit both links in one row at 375px."
patterns-established:
  - "Canvas notices are persistent semantic footer content outside the Scenario main landmark."
  - "Catalog boundary and focus contrast are asserted from actual CSS declarations."
requirements-completed: [CAT-01, CANVAS-01]
coverage:
  - id: D1
    description: "Both fixed Scenario pages render the approved persistent notice in a semantic footer outside main."
    requirement: CANVAS-01
    verification:
      - kind: integration
        ref: "hosts/operator/test/operator_host_test.exs — focused host render assertions; 19 tests passed"
        status: pass
      - kind: other
        ref: "MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors"
        status: pass
    human_judgment: false
  - id: D2
    description: "Catalog contrast, focus, target sizes, type and spacing meet the approved scales, and mobile/zoom layouts keep content available without horizontal overflow."
    requirement: CAT-01
    verification:
      - kind: integration
        ref: "hosts/operator/test/operator_host_test.exs — computed contrast and CSS scale regression; 19 tests passed"
        status: pass
      - kind: automated_ui
        ref: "Playwright at http://127.0.0.1:4003/admin/dev/fablebook, served by this checkout's hosts/operator process"
        status: pass
      - kind: automated_ui
        ref: "Playwright text-size simulation: computed font sizes doubled in host and Canvas DOM; keyboard focus checked on compact Scenario link"
        status: pass
    human_judgment: false
duration: 17 min
completed: 2026-11-25
status: complete
---

# Phase 8 Plan 06: Catalog UI Contract Closure Summary

**The Canvas notice now has the approved footer semantics, and the catalog meets its contrast, focus, target, typography, spacing, and narrow-layout contracts.**

## Performance

- **Duration:** 17 min
- **Started:** 2026-11-25T20:26:16-05:00
- **Completed:** 2026-11-25T20:43:05-05:00
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added the exact illustrative notice to a sibling `footer[role="contentinfo"]` outside the Scenario `<main>` in the Canvas document; focused assertions cover both fixed Scenario routes.
- Updated only Fablebook catalog-shell rules to use Ink for essential boundaries and muted copy, set 44px wordmark/Scenario targets and 4px focus offset, and keep type and spacing on the approved scales.
- Added regression coverage that calculates contrast from CSS colors and checks the catalog typography, spacing, target sizes, wrapping, and overflow protections.
- Measured the live local page at 320×900 and 375×812. Page scroll widths matched viewport widths (320 and 375); the first Shipment label/value boxes were y=802–847 and y=754–799 respectively, fully inside each initial viewport. Wordmark and compact Scenario targets measured 44px high.
- At 200% simulated text sizing, the page remained 375px wide with no horizontal overflow; the Canvas remained 333px wide, all eight host links had visible dimensions, and the Shipment record stayed present. A keyboard Tab reached the compact Scenario link with a visible 2px Ink outline, 4px offset, fully within the viewport.

Browser evidence was collected from `http://127.0.0.1:4003/admin/dev/fablebook`; the persistent listener's working directory was this checkout's `hosts/operator`. The text-size check doubled computed font sizes in both the host and same-origin Canvas DOM. Screenshot captures were not added to the branch.

## Task Commits

1. **Task 1: Give the persistent Canvas notice its approved footer semantics and copy** — `9798155` (`feat(08-06): add semantic Canvas notice footer`)
2. **Task 2: Bring Fablebook catalog chrome onto its approved accessibility and visual scales** — `e2cd351` (`fix(08-06): meet catalog UI accessibility scales`)

## Files Created/Modified

- `lib/fablebook/book_live.ex` — semantic Canvas footer and exact persistent notice.
- `hosts/operator/priv/static/assets/app.css` — catalog contrast, target, focus, typography, spacing, and mobile layout corrections.
- `hosts/operator/test/operator_host_test.exs` — footer and catalog CSS regression coverage.

## Decisions Made

- Kept authored Canvas content, `.operator-preview` styling, source checks, source pins, and source-cache behavior unchanged.
- Reduced mobile catalog-shell spacing and compact Scenario link padding to fit the first Shipment fact at 375×812 while preserving 44px targets. At 320px the links wrap and remain available.
- Kept browser captures out of the PR and did not create or accept a new visual baseline.

## Deviations from Plan

None. The 375px browser check showed the sibling links still wrapped after the first spacing reduction; lowering only their mobile horizontal padding from 8px to 4px fit both links on one row while retaining their 44px minimum height. The final geometry check passed.

## Issues Encountered

- The first 375px measurement placed the initial Shipment value below the 812px viewport. The mobile catalog spacing and compact Scenario link padding were tightened, then both required viewport checks were repeated successfully.

## User Setup Required

None.

## Next Phase Readiness

Plan 08-06 is complete. Phase verification, review, shipping, exact-head hosted CI, merge, delivery receipt, and v0.7 closeout remain. The guard aggregate, blocked `walking-skeleton`, denied and unconsumed R9, and Pending SEC-01 remain unchanged. No screenshot baseline was changed or accepted.

## Self-Check: PASSED

- Focused host suite passed: 19 tests; formatter and diff checks passed.
- Browser geometry passed at 320×900 and 375×812 with the first Shipment fact fully visible and no page horizontal overflow.
- 200% text-size simulation preserved host/Canvas width, link availability, Scenario content, and visible keyboard focus.
- Only the three planned implementation files were changed by the task commits.

---
*Phase: 08-first-inspectable-book-and-local-host-path*
*Completed: 2026-11-25*
