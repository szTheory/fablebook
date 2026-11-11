# Roadmap: v0.2 Guard coverage recovery

**Status:** Active. EX-010 is selected under INT-20261111-05 and Phase 1 has three reviewed serial plans. Plans 01 and 02 completed their source-evidence and static-control work; Plan 03 integration and candidate validation remain pending. The numbering reset and planning lifecycle repair are delivered.

## Milestone

**Milestone key:** guard-recovery

One source-connected guard increment, independently sized and delivered with the existing quality gates. The next scope must be selected from preserved evidence before a plan is written. Finishing this milestone does not claim the full remaining audit or unlock the walking skeleton. The complete future product is in references/PRODUCT-ROADMAP.md; the superseded cycle is in MILESTONES.md.

## Phases

- [ ] **Phase 1: Bounded guard continuation** — select, source-size and implement the next coherent remaining guard slice with exact-lane evidence and static regression controls.

## Phase Details

### Phase 1: Bounded guard continuation

**Goal:** Deliver one explicitly selected, source-connected continuation of the remaining guard audit, with truthful dispositions and static positive/negative coverage across core and floor.
**Depends on:** The merged guard baseline through PR #82; preserved legacy audit evidence and all unresolved stops. Source selection and estimates must pass before planning/execution. No old halted plan is resumed.
**Requirements:** GRC-01, GRC-02, GRC-03
**Success Criteria:**
  1. A reviewed source-membership record identifies the entire selected set and pending complement on both lanes, exact source hashes and caller/delegate edges, with no omitted original row or matching function.
  2. Source/context limits and effort estimates satisfy the inherited budget before plans execute; split oversized work using later integer phases or another bounded milestone.
  3. Selected dispositions have complete source authority and individual lane witnesses; static compile-only controls reject deliberate violations and retain benign controls without invoking audited APIs.
  4. Existing required local checks/review/hosted core and floor receipts pass on the reviewed candidate; contract guards do not change beside lib or workflow implementation.
  5. Only selected coverage advances. The aggregate, installed-wide remainder, SEC-01 properties, source/collision safety stops and walking-skeleton gate remain explicit until their own acceptance passes.
**Plans:** 2/3 implementation plans complete; phase delivery pending. Core exact-source evidence and independent floor evidence are recorded; integration/candidate validation remains. Actual delivery follows all truthful summaries, technical verification, ship preflight and the owner-approved merge; no phase completion before its observed delivery receipt.
**Wave 1**
- [x] 01-01-PLAN.md

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 01-02-PLAN.md

**Wave 3** *(blocked on Wave 2 completion)*
- [ ] 01-03-PLAN.md

## Progress

| Phase | Plans Complete | Status | Completed |
|---|---|---|---|
| 1. Bounded guard continuation | 2/3 | In Progress | - |

## Numbering and gate policy

Only sequential integer phases in active milestones. Reset to Phase 1 at every milestone. Historical dotted IDs remain archive references, never new active phase IDs. The legacy Phase 2 gate now addresses Walking skeleton / Phase 1; the legacy Phase 5 SEC-01 owner now addresses Controls and first bundle / Phase 1. This is an address change, not risk acceptance or a weaker gate. No product milestone starts automatically.
