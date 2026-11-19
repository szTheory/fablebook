# Roadmap: Fablebook

## Milestones

- 🚧 **v0.5 Bounded EX-177 Provenance Follow-through** — Phase 6 planning is authorized.
- ✅ **v0.4 Guard Aggregate Reconciliation** — bounded development milestone archived 2026-11-19; `override_closeout`; wider guard gate remains open. [Roadmap](milestones/v0.4-ROADMAP.md) · [closeout](milestones/v0.4-CLOSEOUT.md)
- ✅ **v0.3 Bounded ASN.1 RTT Guard Evidence** — shipped locally 2026-11-13; [full roadmap and phase details](milestones/v0.3-ROADMAP.md).
- ✅ **v0.2 Guard coverage recovery** — shipped locally 2026-11-11; [full roadmap and phase details](milestones/v0.2-ROADMAP.md).
- ⚠️ **v0.1 Legacy planning cycle** — superseded and incomplete; [historical roadmap](milestones/v0.1-ROADMAP.md).

## v0.5 Bounded EX-177 Provenance Follow-through

**Milestone key:** guard-recovery

This increment makes the reviewed static EX-177 discovery usable in later guard decisions. The open aggregate gate continues to block Walking Skeleton and permits this bounded planning increment. [Planning gates](references/PLANNING-GATES.json)

## Phases

- [ ] **Phase 6: Bounded EX-177 provenance supplement** - Record reviewed observations for four existing keys and preserve the exact pending complement.

<details>
<summary>✅ v0.4 Guard Aggregate Reconciliation (Phases 3–5) — ARCHIVED 2026-11-19</summary>

- [x] Phase 3: Guard aggregate scope rejoin and candidate sizing (5/5 plans) — completed 2026-11-18.
- [x] Phase 4: Evidence-only source and gap provenance closure (3/3 plans) — completed 2026-11-19.
- [x] Phase 5: Bounded two-lane source provenance slice (1/1 plan) — completed 2026-11-19.

See the [archived roadmap](milestones/v0.4-ROADMAP.md), [requirements](milestones/v0.4-REQUIREMENTS.md), [audit](milestones/v0.4-MILESTONE-AUDIT.md), and [phase evidence](milestones/v0.4-phases/).

</details>

<details>
<summary>✅ v0.3 Bounded ASN.1 RTT Guard Evidence (Phase 2) — SHIPPED 2026-11-13</summary>

- [x] Phase 2: Bounded ASN.1 RTT guard evidence (5/5 plans) — completed 2026-11-13.

See the [archived roadmap](milestones/v0.3-ROADMAP.md) and [closeout](milestones/v0.3-CLOSEOUT.md).

</details>

<details>
<summary>✅ v0.2 Guard coverage recovery (Phase 1) — SHIPPED 2026-11-11</summary>

- [x] Phase 1: Bounded guard continuation (3/3 plans) — completed 2026-11-11.

See the [archived roadmap](milestones/v0.2-ROADMAP.md) and [closeout](milestones/v0.2-CLOSEOUT.md).

</details>

## Phase Details

### Phase 6: Bounded EX-177 provenance supplement

**Goal:** The owner can use a supplementary machine-readable record to trace previously reviewed source and observed-caller facts for exactly four existing EX-177 keys, with the exact 9,712-row pending complement preserved.

**Depends on:** Delivered v0.4 Phase 5 evidence and its saved scope, as well as the separately reviewed discovery report. These records are the inputs for the supplement. [Archived result](milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-R9-RESULT.json) · [Archived plan](milestones/v0.4-phases/05-bounded-two-lane-source-provenance-slice/05-01-PLAN.md) · [Discovery report](research/2026-11-19-ex177-source-discovery.md)

**Requirements:** GSR-07

**Success Criteria** (what must be TRUE):

1. The record contains exactly the four existing EX-177 keys for `Elixir.Mix.Tasks.Phx.Gen.Context.prompt_for_code_injection/1`, with one `source` row and one `caller` row on each of `core` and `floor`. Every observation cites the saved discovery and its archived Phase 5 scope.
2. Both lane entries identify their pinned runtime and Phoenix package, exact target file path, file byte count and SHA-256, complete helper definition at lines 445–451, and the direct call at line 131 inside `run/1` at lines 112–136. The record identifies these values as previously reviewed observations and states that one observed direct `run/1` call per lane is insufficient to establish exhaustive caller closure.
3. A local standard-library consistency check confirms the four-key membership, lane identities, recorded source and caller facts, and the exact pending 9,712-row complement binding with SHA-256 `dd95380d2114a10a54ddbb79cc6ec5aab4805a52847dcacb4e2ca3daeda653b5`. The archived evidence and complement retain their original bytes and status.
4. The supplement leaves candidate fit unresolved, candidate null, the guard aggregate gate open, and R9 denied and unconsumed. Walking Skeleton remains blocked, SEC-01 remains pending, actual library collision stays unknown, and the Macro caller-AST, Macro explanation, and legacy digest questions remain open.

**Plans:** 0/1 plans executed
- [ ] 06-01-PLAN.md

Saved lane facts from the reviewed discovery report:

| Lane | Pinned runtime | Phoenix | Recorded target file | Bytes | SHA-256 |
|------|----------------|---------|----------------------|------:|---------|
| Core | Elixir 1.20.4 / OTP 29.1.2 | 1.8.16 (`mix.lock`) | `_build/lanes/core/deps/phoenix/lib/mix/tasks/phx.gen.context.ex` | 14,760 | `c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e` |
| Floor | Elixir 1.18.5 / OTP 27.3.4.9 | 1.8.9 (`mix.floor.lock`) | `_build/lanes/floor/deps/phoenix/lib/mix/tasks/phx.gen.context.ex` | 14,760 | `c7c6dc0e75b25769db626143ad37d43b9c45234190e13a6352b0a6629e05b73e` |

**Boundaries:** Planning is the only authorized stage. The saved discovery report and archived Phase 5 evidence supply the facts. Source rereads, R9 or any new source request, package-wide caller search, audited API or runtime invocation, callback or generated-code execution, product or guard implementation, candidate promotion, aggregate closure, a new CI lane or dependency, and automatic follow-up are outside this scope. If the saved records disagree or leave a required fact missing, identify the exact discrepancy and stop for the owner.

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 6. Bounded EX-177 provenance supplement | 0/1 | Planned; awaiting execution authorization | - |

## Next

Phase 6 has one reviewed plan and passed requirement/decision coverage. Execution is the next action, but it requires the owner's separate authorization under INT-20261119-02. After authorization, run `$gsd-execute-phase 6`. The [product roadmap](references/PRODUCT-ROADMAP.md) retains future product scope.
