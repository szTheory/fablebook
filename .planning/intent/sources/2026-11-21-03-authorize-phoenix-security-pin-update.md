---
id: INT-20261121-03
date: 2026-11-21
source: Direct owner reply in the active Fablebook planning conversation
captured_by: Codex
context: Authorizes the prerequisite Phoenix security-pin uplift proposed for Phase 8 delivery.
---

# Owner authorization: Phoenix security-pin prerequisite

**Date:** 2026-11-21
**Provenance:** Direct owner reply to the proposal to update the existing core and floor Phoenix pins to at least 1.8.17, review the lockfile changes, and deliver that change separately before the remaining Phase 8 PRs.

> “Authorize the prerequisite update.”

This authorizes a separate security-only PR that updates Phoenix to 1.8.17 or later in both core and floor dependency lanes, including only the lockfile changes required to resolve those pins. Review the exact dependency diff, run the required audits and checks, and obtain green required hosted CI before merging. Do not bundle the Book, mount macro, unrelated upgrades, coverage reductions, release, or deployment into that PR. Then continue the separately reviewed Phase 8 PR sequence under its existing ADR 0021 and delivery gates.
