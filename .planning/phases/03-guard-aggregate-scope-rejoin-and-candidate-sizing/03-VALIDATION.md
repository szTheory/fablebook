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

- **After every task commit:** Run the focused aggregate contract test with explicit core or floor lane selection for the affected work.
- **After every plan wave:** Run the focused aggregate contract test on both pinned lanes and inspect the generated evidence without invoking audited OTP functions.
- **Before `$gsd-verify-work`:** Run both full pinned-lane suites and record the local tested head. Final-head delivery checks and hosted CI receipts remain with verification and ship.
- **Max feedback latency:** Use current pinned-lane CI timing; record task intervals and keep each plan within the inherited effort bound.

---

## Per-Task Verification Map

Plans assign eleven tasks across five sequential waves because the existing authoritative identity ledger, narrow collector and tagged contract share file ownership. All outcomes remain pending: no source/runtime or test execution occurred during planning. `Q` below means the exact quick run command above. Records-only and bundle selectors are additional tags created by the leading tracer, not separate workflow tasks.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 03-01 | 1 | GSR-01, GSR-04, GSR-06 | T-03-01, T-03-03, T-03-04 | Real both-lane tracer, pinned provenance, static acquisition and atomic opt-in records. | contract/static tracer | `FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors` | Existing file; new tag in leading tracer | ⬜ pending |
| 03-01-02 | 03-01 | 1 | GSR-01, GSR-02, GSR-04 | T-03-01, T-03-02 | Complete original identities/owners, exact sets and separate delivered/historical partitions. | contract/exact membership | Same explicit write/recheck command as 03-01-01 | Existing file; new tag in leading tracer | ⬜ pending |
| 03-02-01 | 03-02 | 2 | GSR-03 | T-03-05, T-03-07 | Exact lane sources or individually typed source/provenance gaps. | contract/static source | Same explicit write/recheck command as 03-01-01 | Earlier plan creates collector/tag | ⬜ pending |
| 03-02-02 | 03-02 | 2 | GSR-03, GSR-06 | T-03-06, T-03-07, T-03-08 | Full observed caller/delegate references, cycles and scoped empty/unknown outcomes; all required gaps block recommendation. | contract/static graph | Same explicit write/recheck command as 03-01-01 | Earlier plan creates collector/tag | ⬜ pending |
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

- [ ] Leading tracer adds `:guard_aggregate_reconciliation`, `:guard_aggregate_reconciliation_records` and `:guard_aggregate_reconciliation_bundle` tagged checks inside existing `test/contract/tier_sweep_test.exs`, reusing its private authoritative ledger and current graph.
- [ ] Leading tracer adds only `test/support/guard_aggregate_reconciliation_evidence.ex` for the missing aggregate receipt/renderer; reuse InstalledOtp and SweepEvidence for inventory/source authority.
- [ ] Confirm each focused selector runs nonzero relevant tests; ordinary checks are read-only, record/report writes require their explicit separate flags.
- [ ] Confirm both pinned lane toolchains are available before lane-specific implementation verification; do not substitute one lane for the other.
- [ ] Keep any contract-test addition separate from changes to `lib/**` or `.github/**` in a PR, per ADR 0021.

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
