---
phase: "3"
slug: "guard-aggregate-scope-rejoin-and-candidate-sizing"
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-13"
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | ExUnit contract tests on pinned core and floor Elixir/OTP lanes |
| **Config file** | `mix.exs`, `test/test_helper.exs` |
| **Quick run command** | `bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` |
| **Full suite command** | `bin/lane core mix ci && bin/lane floor test --warnings-as-errors --include prod_guard --include release` |
| **Estimated runtime** | Use current core and floor CI receipt timings; no tests were run during planning research. |

---

## Sampling Rate

- **After every task commit:** For 03-01-03, confirm the committed zero-read recovery receipt remains unchanged, then check the bounded three-event source-notes continuation and preflight; after each implementation task run its focused aggregate checks with explicit pinned lane selection.
- **After every plan wave:** Run the focused aggregate contract test on both pinned lanes and inspect the generated evidence without invoking audited OTP functions.
- **Before `$gsd-verify-work`:** Run both full pinned-lane suites and record the local tested head. Final-head delivery checks and hosted CI receipts remain with verification and ship.
- **Max feedback latency:** Use current pinned-lane CI timing; record task intervals and keep each plan within the inherited effort bound.

---

## Per-Task Verification Map

Plans assign twelve tasks across five sequential waves because the existing authoritative identity ledger, narrow collector and tagged contract share file ownership. Wave 1 keeps three task nodes: documentation recovery 03-01-03 is already complete with zero source-body events; its revised source-notes continuation then produces a bounded handoff; tracer 03-01-04 follows, then membership expansion 03-01-05. Plan 03-02 cannot begin before the successful 03-01 summary. The old 03-01-01 attempt is historical failed work, not a completed task: 13 exact-source body-read events exceeded five by eight, with no task outputs, commits or summaries. Its per-file regions and uncertain cross-file order remain in the unchanged CHECKPOINT and READ-LEDGER. Old 03-01-02 is retired without execution. The later truncated Task 03-01-04 event also remains consumed and incomplete; its event stays separate from the three source-note continuation events under the existing 03-01-03 task node. All current outcomes remain pending; this revision performs no source/runtime or test execution. `Q` below means the exact quick run command above. Records-only and bundle selectors are additional tags created by the tracer, not separate workflow tasks.

`W` means: `FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_records --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_records --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_REPORT_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_bundle --warnings-as-errors && bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors`. The first lane writes only its own record. Report publication follows both validated matching lane records under its separate flag. Wave 1 bundle checks explicitly retain source/sizing pending and candidate null; later plans add their required artifacts.

`L` retains the unchanged Plan 03-02 command: `FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors`.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-03 | 03-01 | 1 | GSR-01, GSR-04, GSR-06 | T-03-01, T-03-02, T-03-03 | Preserve committed zero-read recovery, then produce an exact-source handoff in a three-event continuation; no code/test changes. | bounded source review | `test -s .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-01-RECOVERY.md && test -s .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-01-03-SOURCE-NOTES.md && git diff --check HEAD -- .planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-01-03-SOURCE-NOTES.md && bin/planning_health --stage execute --phase 3` | Recovery receipt and source notes | ⬜ pending |
| 03-01-04 | 03-01 | 1 | GSR-01, GSR-04, GSR-06 | T-03-01, T-03-03, T-03-04 | Real both-lane tracer after recovery, pinned provenance, static acquisition and atomic opt-in records. | contract/static tracer | W | Existing contract; new collector/tags and lane/report artifacts | ⬜ pending |
| 03-01-05 | 03-01 | 1 | GSR-01, GSR-02, GSR-04 | T-03-01, T-03-02 | Complete original identities/owners, exact sets and separate delivered/historical partitions after verified tracer. | contract/exact membership | W | Tracer creates collector/tags and lane/report artifacts | ⬜ pending |
| 03-02-01 | 03-02 | 2 | GSR-03 | T-03-05, T-03-07 | Exact lane sources or individually typed source/provenance gaps. | contract/static source | L | Earlier plan creates collector/tag | ⬜ pending |
| 03-02-02 | 03-02 | 2 | GSR-03, GSR-06 | T-03-06, T-03-07, T-03-08 | Full observed caller/delegate references, cycles and scoped empty/unknown outcomes; all required gaps block recommendation. | contract/static graph | L | Earlier plan creates collector/tag | ⬜ pending |
| 03-03-01 | 03-03 | 3 | GSR-05 | T-03-09, T-03-10 | Fresh exact-source/token/context/reread manifest or explicit missing measurement. | contract/sizing | Q | Earlier plan creates collector/tag | ⬜ pending |
| 03-03-02 | 03-03 | 3 | GSR-05, GSR-06 | T-03-09, T-03-10, T-03-11, T-03-12 | Below/at/above limits, unknowns, global gaps, atomic generation and separate owner authority. | contract/fit decision | Q | Earlier plan creates collector/tag | ⬜ pending |
| 03-04-01 | 03-04 | 4 | GSR-01 through GSR-06 | T-03-13 | Independent completeness/provenance/authority and static call-graph review. | contract + independent judgment | Q | Earlier plan creates collector/tag | ⬜ pending |
| 03-04-02 | 03-04 | 4 | GSR-01 through GSR-06 | T-03-14 | Accepted findings falsified, corrected records invalidate stale sizing. | focused records | `FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_records --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_records --warnings-as-errors` | Earlier plan creates records sub-tag | ⬜ pending |
| 03-04-03 | 03-04 | 4 | GSR-01 through GSR-06 | T-03-14, T-03-15 | Corrected report reproduces machine evidence and bounded review dispositions. | full bundle | `FABLEBOOK_GUARD_AGGREGATE_REPORT_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_bundle --warnings-as-errors`, then Q | Earlier plan creates bundle sub-tag | ⬜ pending |
| 03-05-01 | 03-05 | 5 | GSR-01 through GSR-06 | T-03-16, T-03-17 | Observed local reviewed/tested tree, full lanes and truthful act feasibility; hosted/merge receipts separate. | full lane | `bin/lane core mix ci && bin/lane floor test --warnings-as-errors --include prod_guard --include release` | Existing commands | ⬜ pending |
| 03-05-02 | 03-05 | 5 | GSR-06 | T-03-18 | Accurate canonical handoff and validation state; original safety/owner stops preserved. | planning/static | `git diff --check origin/main...HEAD && git diff --check HEAD && bin/planning_health --stage execute --phase 3` | Existing commands | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Independent review accepts the revised Wave 1 before any source read or implementation resumes. The completed zero-read recovery and its gated source-notes continuation remain under task node 03-01-03 and precede tracer task 03-01-04.
- [ ] Leading tracer adds `:guard_aggregate_reconciliation`, `:guard_aggregate_reconciliation_records` and `:guard_aggregate_reconciliation_bundle` tagged checks inside existing `test/contract/tier_sweep_test.exs`, reusing its private authoritative ledger and current graph.
- [ ] Leading tracer adds only `test/support/guard_aggregate_reconciliation_evidence.ex` for the missing aggregate receipt/renderer; reuse InstalledOtp and SweepEvidence for inventory/source authority.
- [ ] Confirm each focused selector runs nonzero relevant tests; ordinary checks are read-only, record/report writes require their explicit separate flags.
- [ ] Confirm both pinned lane toolchains are available before lane-specific implementation verification; do not substitute one lane for the other.
- [ ] Keep any contract-test addition separate from changes to `lib/**` or `.github/**` in a PR, per ADR 0021.

## Wave 1 Source-Read and Context Gates

Exact implementation outputs for 03-01-04 and 03-01-05 are `test/support/guard_aggregate_reconciliation_evidence.ex`, `test/contract/tier_sweep_test.exs`, `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-CORE-AGGREGATE-EVIDENCE.json`, `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-FLOOR-AGGREGATE-EVIDENCE.json`, and `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-RECONCILIATION.md`. Completed recovery 03-01-03 created `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-01-RECOVERY.md`; its source-notes continuation creates only `.planning/phases/03-guard-aggregate-scope-rejoin-and-candidate-sizing/03-01-03-SOURCE-NOTES.md`.

The exact event/path/region ledger is canonical in revised 03-01-PLAN.md and is copied into 03-01-REPLAN.md before acquisition. The already completed recovery segment in 03-01-03 used zero body reads; its newly gated source-notes continuation has three events (TierSweepTest, InstalledOtp, SweepEvidence). Task 03-01-04 has three total events: event 1 was consumed with truncated output, and its only remaining acquisitions are the complete created collector and tracer aggregate test region (events 2–3). Task 03-01-05 keeps four events (expanded TierSweepTest, final collector, ASN.1 assertion region and complete immutable original excerpt). Record sequence/path/regions/reason/token accounting before every read and actual results afterward; preserve actual ledgers in task receipts and the final summary. Repeated paths, source-bearing diffs and created/edited-output body inspections count again. These are ceilings, not permission for unlisted regions or an additional sixth event. Use captured notes after each bounded acquisition; never truncate a required definition or source/caller evidence. If the recorded ranges do not cover it, stop and name the remedy before reading more.

The single plan context has a fixed 31,000-token reserve and at most 69,000 tokens for all other required input, source/data, rereads and conservative output allowances. Total must remain at most 100,000 across the three task nodes; task boundaries do not reset it. Initial measurement is required before the first source read and updated before each event. The historical overruns provide no fresh allowance and remain incidents. No extra audited target/caller bodies are budgeted in Wave 1; exact lane/hash findings may be reused and any unresolved links remain named gaps for Plan 03-02. Membership/source status stays honest and candidate remains null throughout Wave 1. Each implementation task modifies only the collector, existing aggregate contract, two lane records and derived crosswalk; the completed recovery segment owns only 03-01-RECOVERY.md, and its source-notes continuation owns only 03-01-03-SOURCE-NOTES.md.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Actual-library collision stop | GSR-06 | A real matching `lib/` function requires the existing owner stop; static evidence and tests cannot resolve that judgment. | Stop if a real collision appears and record its exact identity and evidence. Do not select a candidate while unresolved. |
| Final evidence and candidate-fit review | GSR-03, GSR-05, GSR-06 | Automated checks can verify links and limits, but a reviewer must judge whether the cited source/caller evidence supports the recommendation and whether the concrete owner decision remains bounded. | Review the linked lane receipts and row-level report against source evidence, exact complements, measured sizing, and all retained gates. If any required evidence or fit is missing, confirm that no candidate is selected. |

---

## Validation Sign-Off

- [ ] All tasks have a focused automated command or an explicit Wave 0 dependency.
- [ ] Sampling continuity: no 3 consecutive tasks without automated verification.
- [ ] Wave 0 covers missing aggregate inventory, membership, source-link, and sizing contracts.
- [ ] No watch-mode flags.
- [ ] Feedback latency is based on current pinned-lane CI receipts.
- [ ] `nyquist_compliant: true` set after validation confirms the plan's verification coverage.

**Approval:** pending

## Spec-less assumptions and prohibition review

Plan 03-05 retains all 13 supplied unresolved edge prompts, including both unclassified items, with planned task checks. It also records the two-stage recall/precision pass for all six requirements and six unresolved bespoke safety/transparency prohibitions. These remain unresolved until execution evidence and independent judgment establish an honest resolution; merely writing a check does not resolve the probe. Generic archive/path/privacy canon remains with the existing resolver/project rules and security review. No new user-facing values or thresholds are assumed.
