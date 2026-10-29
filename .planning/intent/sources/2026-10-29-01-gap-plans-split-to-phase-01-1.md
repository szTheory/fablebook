---
id: INT-20261029-01
date: 2026-10-29
source: Claude Code session, /gsd-plan-phase 1 --gaps, owner answer to a multiple-choice question after the plan checker flagged the 5-plan cap
captured_by: Claude (Opus 5.5)
context: Phase 1 verification found gaps (CR-01 atom-ban bypass, WR-03 code loading, WR-05/WR-06 hex-publish hardening, SEC-02 bookkeeping). The gap-closure plans 01-06 and 01-07 would have taken Phase 1 to 7 plans, against the ≤5-plan cap in ADR 0021 and INT-20261028-16. The owner was asked to choose between splitting into an inserted phase 01.1, a signed exception keeping 7 plans in Phase 1, or folding the work into one sixth plan.
---

> Verbatim (selected option).

Split: new phase 01.1 (Recommended)

**Resolution:** The two gap-closure plans move unchanged in scope into an inserted phase 01.1, so the ≤5-plan cap holds without an exception. Phase 1's criterion-4 share for the atom ban (CR-01) and the related gap items are re-homed to Phase 01.1. Phase 1 keeps its 5 executed plans. No Q38 cap-exception question is raised.
