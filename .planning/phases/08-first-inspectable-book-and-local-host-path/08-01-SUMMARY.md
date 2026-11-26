---
phase: first-inspectable-book-and-local-host-path
plan: "01"
subsystem: source
tags: [elixir, sha256, source-custody, public-pins]
requires: []
provides:
  - Seven public brand repositories pinned to exact commits and fetched into an ignored cache
  - Fail-closed whole-file and excerpt provenance checks for the Logistify v1.0 source subset
affects: [phase-08-book-content]
actuals:
  tasks: 3
  files: 10
tech-stack:
  added: []
key-decisions:
  - "Use exact full commit pins and a reviewed explicit update command; normal fetch never moves a pin."
  - "Keep complete source repositories and unrelated assets out of Fablebook; allow only minimal cited Logistify source-derived content under INT-20261121-01."
  - "Preserve the original halted report as historical evidence, then resume under the public repository source policy."
patterns-established:
  - "Fetch public sources into .cache/brand_sources/<name> using a detached exact-SHA checkout and no network on a verified cache hit."
  - "Bind cited source excerpts to public repository, tag, commit, path, source digest, exact byte offsets, and excerpt digest."
requirements-completed: [SRC-01]
coverage:
  - id: SRC-01
    description: "Seven public source commits are reproducible, and the minimal Logistify source facts are hash-pinned with public provenance."
    verification:
      - kind: other
        ref: "bin/fetch_brand_sources --self-test; --update logistify-brand v1.0; normal fetch"
        status: pass
      - kind: other
        ref: "bin/verify_logistify_source --check-original .cache/brand_sources/logistify-brand"
        status: pass
      - kind: other
        ref: "bin/verify_logistify_source --check-pinned and --self-test"
        status: pass
      - kind: other
        ref: "node records/logistify/check-records.mjs, --self-test, and --book logistify-brand-book.html from the pinned Logistify repository root"
        status: pass
    human_judgment: false
duration: "resumed 2026-11-21"
completed: 2026-11-21
status: complete
---

# Phase 8 Plan 08-01 Summary

**The public pins, exact-source cache, original hash check, and cited Logistify excerpt capsule now pass.** The source supports a short dispatcher recovery flow, with the record gaps below kept explicit.

## Accomplishments

- Added `brand_sources.lock.json` for all seven owner-supplied repositories, tags, and full commit pins. Added `bin/fetch_brand_sources` with exact-SHA detached fetches, verified offline cache hits, dirty/wrong-origin refusal, and an explicit `--update` command.
- Added the ignored `.cache/brand_sources/` path and lock-hash cache plus fetch/original-check steps to the existing core and floor CI jobs. No runtime dependency or required Node setup was added.
- Kept the three original Logistify whole-file SHA-256 values unchanged. `bin/verify_logistify_source` now checks public pin provenance and an exact excerpt capsule containing only the cited Logistify source subset.
- Recorded repository URL, tag, commit, repository-relative path, original whole-file digest, exact section or JSON pointer, and selected bytes/hashes for the visible claims and values.
- Preserved the former custody halt verbatim in [08-01-HISTORICAL-HALT.md](08-01-HISTORICAL-HALT.md); the public repositories supersede only its missing-source assumption.

## Verification

- `bin/fetch_brand_sources --self-test` passed for full-SHA fetch, detached checkout, offline cache hit, lightweight/annotated tag resolution, wrong origin/pin and dirty-cache refusal.
- `bin/fetch_brand_sources --update logistify-brand v1.0` resolved to the already locked commit and left the lock unchanged.
- `bin/fetch_brand_sources` found all seven exact commits in the clean local cache and reported each already pinned.
- `bin/verify_logistify_source --check-original .cache/brand_sources/logistify-brand` passed all three original file hashes.
- `bin/verify_logistify_source --check-pinned` verified public repository/tag/commit/path provenance, original hashes and all cited excerpt bytes.
- `bin/verify_logistify_source --self-test` passed exact-byte, JSON-pointer, offset, omitted-excerpt and tamper controls.
- From the pinned Logistify repository root, `node records/logistify/check-records.mjs`, its `--self-test` (46/46 cases), and `--book logistify-brand-book.html` passed.
- `bin/planning_health --stage execute --phase 8` passed before resuming this plan.

## Source limits for the Book

The dispatcher source names the job, a failed focal shipment, two shipment IDs in the bulk case, a total of 12 selected, and the “12 shipments reassigned” outcome. It does not name the other ten selected shipment IDs, identify which two rows were selected on the separate five-row board illustration, or provide the replacement driver. The Book may show only supported IDs and the sourced total, label the unspecified values “Not provided in source,” and depict actions as illustrative. This is enough to support a concise dispatcher recovery flow without filling those gaps.

## Next Readiness

Plan 08-01 is complete. The source precondition for Plan 08-04 passes, and Plan 08-03 records the separate macro PRs and before-Book production controls. Proceed with Plan 08-04.

---
*Phase: 08-first-inspectable-book-and-local-host-path*
*Plan: 08-01*
*Completed: 2026-11-21*
