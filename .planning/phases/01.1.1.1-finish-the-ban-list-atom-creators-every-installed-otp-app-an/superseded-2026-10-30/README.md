# Superseded execution plan history

Archived byte-for-byte on 2026-10-30 under INT-20261029-02, INT-20261030-02 and ADR 0021. The original plan set exceeded its measured context budget. These files are historical inputs, outside OpenGSD's top-level executable PLAN/SUMMARY scan.

| Historical task/plan | Actual state | Binding successor |
|---|---|---|
| 01 task 01-01 | Delivered source/PathConsult tracer, merged PR 23 | Reused by new 06/07; tested head ca9a85e8520e63039c8b52dae407c93cca17341d, merge 39b37d65429467722897132f51fa784756926e9b; CI run 41059395548 |
| 01 task 01-02 | Partial, halted at explicit source/context budget; WIP unmerged | Named consult/Yecc and Logger/ExUnit work → 06/07; full identity/exclusion corpus → 01.1.1.4 children |
| 01 task 01-03 | Unanswered Macro AST judgment | Substantive AST-family audit child of 01.1.1.4; actual lib-collision hard stop remains global |
| 02 | Never executed | Installed inventory/Common Test → 01.1.1.2; remaining installed fronts → 01.1.1.3 children; CN/BD audit → 01.1.1.4 children |
| 03/04 | Never executed; row-halving budget invalidated | All EX originals and complete lane/MFA sets → source-family children of 01.1.1.4 |
| 05 | Never executed | Unconditional whole-table coverage/removal, truthful explanation and exact wording approval → 01.1.1.5 |

The halted 01 SUMMARY remains halted. No unexecuted plan receives a successful summary, and the historical partial plan does not count as an active completed plan. New active plans are 06 and 07; no identity is reused. The complete adopted ownership/acceptance map is in the parent directory's 01.1.1.1-REPLAN.md and ROADMAP.

Delivered evidence: [PR 23](https://github.com/szTheory/fablebook/pull/23), [final CI run](https://github.com/szTheory/fablebook/actions/runs/41059395548). Historical source-unavailability or pending-merge statements in archived files describe their own revision; they do not supersede these final receipts.

Next command after new plans pass checking: `$gsd-execute-phase 01.1.1.1` — execute 06/07 only, then stop at the GSD boundary.
