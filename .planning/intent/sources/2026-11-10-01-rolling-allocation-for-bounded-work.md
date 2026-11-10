---
id: INT-20261110-01
date: 2026-11-10
source: Codex session, owner direction
captured_by: Codex
supersedes: D-17 full-remainder-allocation-before-any-replacement-planning; D15-07 no-additional-phase-ID limit; INT-20261101-02 phase-insertion stop, only for this bounded slice
context: The owner asked to unblock the stalled Phase 01.1.1.1 work and directed Codex to sanity-check the approach and follow its recommendation.
---

> Verbatim owner direction: “follow ur recs”; “sanity check ur approach and follow whatever recommendations you come up with in the end plz”; “can u unblock us i dont like how we are stopping like this do we need to re-evaluate our approach ...”

**Resolution:** Replace D-17's requirement to allocate and time-estimate the entire remaining scope before planning any work with rolling allocation. A replacement slice may be planned when that slice has exact source identities, source/task/context bounds, a coherent scope, and a pre-plan effort estimate within the existing limits. Keep the complete original rows, lane matches, caller links, and unallocated remainder visible; never infer a verdict from an unreviewed remainder. Preserve the 100,000-token planning bound, no more than five exact source files per task, 2–3 tasks per plan, no more than five plans per phase, and roughly three working days per plan. Do not lower security or verification gates.

Apply this process change first to the source-sized EX-107 ASN.1 external-transform leaf. This permits one same-level sibling phase after 01.1.1.16; it does not close the 01.1.1.1 aggregate, SEC-01, or the Phase 2 gate, and does not authorize runtime invocation of the audited functions. Continue resolving floor `user:start/0` and sizing the remaining scope in parallel with bounded deliveries.
