---
phase: first-inspectable-book-and-local-host-path
plan: "05"
subsystem: book-flow-and-delivery-verification
tags: [elixir, phoenix, liveview, source-provenance, browser, security]
requires:
  - Plan 08-04 local host/catalog implementation
  - Exact pinned-source and pre-Book production controls
provides:
  - Two-screen fixed dispatcher Book with explicit source gaps
  - Real-host browser and Canvas evidence
  - Production-boundary checks for the actual operator host
  - Delivery handoff naming the remaining ADR/security gates
affects: [v0.7-closeout]
actuals:
  tasks: 3
  files: 8
tech-stack:
  added: []
key-decisions:
  - "Keep all displayed records and actions fixed, illustrative and grounded in the pinned public Logistify source."
  - "Do not change root dependency declarations or locks under the current Phase 8 plan."
  - "Do not merge a candidate that combines a contract test with its implementation or fails required security checks."
requirements-completed: []
coverage:
  - id: SRC-01/BOOK-01/CAT-01/CAT-02/CANVAS-01
    description: "The source-gated two-screen flow renders in the actual local host with stable URLs, visible source gaps and same-origin Canvas behavior."
    verification:
      - kind: local
        ref: "08-BROWSER.md and artifacts/08-05-mobile-320.png, artifacts/08-05-desktop-1280.png"
        status: pass
      - kind: local
        ref: "operator host test: 11 passed in core and floor"
        status: pass
  - id: HOST-01/HOST-02
    description: "The actual host excludes the Book and mount in production and rejects a reachable production mount with the canonical compile error."
    verification:
      - kind: local
        ref: "bin/verify_operator_host_prod in core and floor"
        status: pass
  - id: delivery
    description: "Exact-head reviewed green PR and merge are not available yet."
    verification:
      - kind: local
        ref: "Full core/floor lanes fail only on the ADR 0021 separation assertion; root Hex audit reports HIGH advisories."
        status: blocked
human_judgment: false
duration: "multi-session; active time not tracked"
completed: 2026-11-21
status: halted
---

# Phase 8 Plan 08-05 Summary

**The fixed Book, local host and browser evidence are complete locally; Phase 8 delivery is halted before PR because the current candidate violates the required PR split and the unchanged root dependencies fail the security audit.**

## Completed locally

- The pinned-source fetch, original-file hashes, cited-excerpt manifest and upstream Logistify records validator pass. All seven brand repositories were reused from the exact commit cache.
- The Book has two stable source-grounded scenarios: a failed shipment and the 12-shipment reassignment result. The other ten shipment IDs, selected board-row membership and replacement-driver name remain explicitly unspecified.
- The host route and Canvas tests passed 11/11 in both core and floor environments. The actual-host production verifier passed in both environments, including positive exclusion checks and the negative reachable-mount compile control.
- The real-host browser pass covered the catalog, navigation, ready and failure states, same-origin CSP/Canvas behavior, 320/375/768/1280 widths, visible keyboard focus and 200% text zoom. Captures and detail are in [08-BROWSER.md](08-BROWSER.md).
- The focused planning intent/state checks passed 40 tests after recording this handoff.
- The config error found during the final production run was corrected: dev/prod no longer import nonexistent config files; test alone imports the existing test config.

## Delivery blockers

1. **ADR 0021 PR split:** the current local diff changes `test/contract/mount_literal_ast_test.exs` together with `lib/fablebook/router.ex` and `.github/workflows/ci.yml`. The complete core `mix ci` run finished with 463 passing, 1 failing and 10 excluded; the floor prod-guard-inclusive suite finished with 473 passing, 1 failing and 6 excluded. Each lane's only failure is the contract-test/implementation separation assertion. The updated contract must be delivered test-only, then the route implementation in a separate PR.
2. **Root dependency security:** `mix hex.audit` on core reports HIGH `EEF-CVE-2026-128361` and `EEF-CVE-2026-129344` against Phoenix 1.8.16. The floor audit reports those same HIGH findings against Phoenix 1.8.9 plus MEDIUM `EEF-CVE-2026-126334` against LiveView 1.2.9 and `EEF-CVE-2026-120287` against Plug 1.20.3. The approved Phase 8 plan explicitly keeps root `mix.exs`, `mix.lock` and `mix.floor.lock` unchanged, so no dependency update was made. Phoenix's [official 1.8.17 release notes](https://github.com/phoenixframework/phoenix/releases/tag/v1.8.17) say that release fixes both HIGH Phoenix advisories.

No PR was pushed or opened because a candidate cannot satisfy both the ADR split and current required security checks. No `act` retry, release, deployment or external write occurred. The guard aggregate remains open, `walking-skeleton` remains blocked, and the one-Book exception still expires at v0.7 closeout.

`bin/planning_health --stage verify --phase 8` reports `summary_incomplete` for this intentionally halted plan. Phase verification and milestone closeout have not been claimed; that preflight cannot pass until the remaining delivery has green required checks and a complete summary.

## Owner decision and resume point

The next decision is whether to authorize one narrowly scoped prerequisite dependency-security change to the existing root pins (Phoenix 1.8.17 or later in both core and floor, with full lock review and unchanged coverage), followed by separate test-only and Book implementation PRs. If not authorized, keep Phase 8 halted with the local result intact. The captured screenshots are evidence only; no visual baseline was proposed or auto-accepted.

If authorized, the next command is `bin/planning_health --stage plan --phase 8`; it opens the required scoped plan before changing the root pins or preparing either Phase 8 PR.

**Current checkout:** `~/projects/fablebook`, branch `main`, HEAD `f23da6e341997999a084049436037bd6bd55c0af`, 26 local commits ahead of `origin/main`, with uncommitted Phase 8/handoff changes. No reset, stash, clean or push of this branch occurred. The tracked and untracked work remains reviewable in place.
