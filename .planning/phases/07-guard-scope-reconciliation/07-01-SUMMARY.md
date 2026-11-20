---
phase: 07-guard-scope-reconciliation
plan: 01
subsystem: evidence-reconciliation
status: complete
requirements: [RSC-01, RSC-02]
---

# Plan 07-01: Current lanes and proposed partition

The reviewed standard-library reader scanned only approved BEAM atom/export chunks for the current core lane. Its independently reviewed manifest contains 2,061 BEAM files; the resulting export inventory contains 54,764 functions. The floor lane was not rescanned: it remains bound to its accepted ENV06 generation and unchanged floor lock/runtime.

All 226 saved identity rows reconcile in each lane. The current maps preserve original row fields and lane-match values, source-gap references, known additions, removals and per-row provenance. The older whole-library inventory retained only a count and digest, so this plan cannot report exact differences across that entire historic universe; it reports exact comparisons for saved guard rows.

The proposed evidence family is CN-002 through CN-006, with seven current memberships in each lane. CN-001 remains in the complement because it has no live MFA in either lane. EX-124/125 remain unresolved context. The complete complements are 1,756 core memberships and 1,711 floor memberships. This is a proposed evidence scope, not a code candidate.

The exact ten-file schedule was created only after both lane maps passed. Its later independent review and approval are recorded in Plan 07-02. R10/R11 no-go receipts remain immutable; the unsafe historical writer was not used. The current candidate remains null, implementation unauthorized and aggregate gate open.

## Verification

The final validator passes both lane maps, exact family/complement partitions, current and retained lane pins, all preserved stops, and the reviewed schedule. The approved inventory reader uses no new dependency and does not inspect BEAM debug or source-body chunks.
