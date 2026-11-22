---
phase: first-inspectable-book-and-local-host-path
plan: "04"
subsystem: operator-host-and-compiled-catalog
tags: [elixir, phoenix, liveview, catalog, canvas]
requires:
  - Plan 08-01 pinned-source verification
  - Plan 08-03 production fixture controls
provides:
  - Loopback-only development operator host
  - Compiled Book/Story/Scenario catalog and same-origin Canvas routes
  - Source-bound Logistify dispatcher scenarios and host tests
affects: [phase-08-local-book-delivery]
actuals:
  tasks: 3
  files: 13
tech-stack:
  added: []
key-decisions:
  - "Keep the host listener optional and development-only; do not change root dependency declarations or locks."
  - "Resolve only exact compiled Book, Story and Scenario identifiers; never derive modules or atoms from route input."
  - "Keep the two missing shipment IDs, the unidentified board selection and the missing replacement-driver name explicit."
requirements-completed: []
coverage:
  - id: HOST-01/HOST-02
    description: "The actual host uses the dev/test mount and excludes its Book, routes and adapter from production; a reachable negative compile emits one canonical error."
    verification:
      - kind: local
        ref: "bin/verify_operator_host_prod"
        status: pass
      - kind: local
        ref: "FABLEBOOK_FLOOR=1 bin/verify_operator_host_prod"
        status: pass
  - id: CAT-01/CAT-02/CANVAS-01/BOOK-01
    description: "The fixed compiled catalog serves two cited scenarios through the same-origin host Canvas in development and test."
    verification:
      - kind: local
        ref: "hosts/operator/test/operator_host_test.exs: 11 tests in core and floor"
        status: pass
duration: "multi-session; active time not tracked"
completed: 2026-11-21
status: locally_verified
---

# Phase 8 Plan 08-04 Summary

**The local host and compiled catalog now render the source-grounded dispatcher flow through the real Phoenix Canvas path.** The implementation is locally verified; final delivery is recorded as halted in [08-05-SUMMARY.md](08-05-SUMMARY.md) because the review and dependency-security gates do not pass on the current combined candidate.

## Accomplishments

- Added an isolated Phoenix host with an optional loopback-only development listener. Bandit remains host-only and development-only; no root dependency declaration or lockfile changed.
- Added the fixed compiled Book, Story and Scenario metadata, exact-ID catalog resolution, minimal catalog/navigation surfaces, and same-origin Canvas LiveViews.
- Bound visible scenario fields, actions and citations to the public Logistify commit and verified excerpt manifest. Missing record facts remain labeled as not provided.
- Added the source cache/lock verification to CI and host assertions tying every displayed source-backed fact, action and pointer to the manifest and pinned records.
- Corrected host config loading so only the existing `test.exs` is imported; dev and prod use their runtime secret rules without requiring nonexistent environment config files.

## Verification

- `bin/fetch_brand_sources`: all seven repositories already at their exact locked commits; no network fetch was needed.
- `bin/verify_logistify_source --check-pinned`: passed public commit, original-file hashes and cited excerpt checks.
- `node .cache/brand_sources/logistify-brand/records/logistify/check-records.mjs`: passed; 3 depots, 5 drivers, 5 shipments, 35 cases and 4 flows validate.
- `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)`: 11 passed.
- `(cd hosts/operator && FABLEBOOK_FLOOR=1 MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)`: 11 passed.
- `bin/verify_operator_host_prod` and `FABLEBOOK_FLOOR=1 bin/verify_operator_host_prod`: passed. Both verify matching dev/test Story/Scenario IDs, clean production route/Book/adapter exclusion and the reachable negative mount's single canonical compile error.
- Actual host/browser evidence and captures are in [08-BROWSER.md](08-BROWSER.md).

## Source Limits

The source lists two IDs in a 12-shipment reassignment and does not identify the two selected rows in its separate board example or name the replacement driver. The UI uses only the two listed IDs and sourced count/result and labels the remaining facts as not provided. Actions and records stay illustrative.

## Delivery

This local implementation has no PR or hosted receipt yet. The current working diff changes the guarded router implementation and its contract test together, which violates ADR 0021. The full core/floor lanes also encounter that separation assertion. The root Hex audit reports new HIGH Phoenix advisories; the root pin constraint is recorded in [08-05-SUMMARY.md](08-05-SUMMARY.md). No gate was bypassed and no release or deployment occurred.
