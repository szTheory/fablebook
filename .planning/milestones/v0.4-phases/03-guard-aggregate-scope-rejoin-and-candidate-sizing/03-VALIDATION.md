---
phase: "3"
slug: "guard-aggregate-scope-rejoin-and-candidate-sizing"
status: validated
nyquist_compliant: true
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

The current phase has twelve active tasks across five sequential waves: 3 + 2 + 2 + 2 + 3. This count was recomputed from the task names in all five plan files. The prior eleven-task map predates the added 03-05-02 consumer-repair task and its final handoff is now 03-05-03. Plan 03-04's active metadata-only revision contains tasks 03-04-02 and 03-04-03; the original semantic source review remains blocked by missing evidence. Wave 1 keeps three task nodes: recovery/source-note task 03-01-03, tracer 03-01-04, then membership expansion 03-01-05. The old 03-01-01 attempt remains historical failed work: 13 exact-source body-read events exceeded five. Old 03-01-02 was retired without execution. The later truncated Task 03-01-04 event remains consumed and incomplete. Plan 03-02 cannot begin before the successful 03-01 summary. `Q` below means the exact quick run command above. Records-only and bundle selectors are additional tags created by the tracer, not separate workflow tasks. Current outcomes are recorded below and in [03-RECOVERY-READINESS.md](03-RECOVERY-READINESS.md); unresolved source/caller proof remains open.

`W` means: `FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_records --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_records --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_REPORT_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation_bundle --warnings-as-errors && bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors`. The first lane writes only its own record. Report publication follows both validated matching lane records under its separate flag. Wave 1 bundle checks explicitly retain source/sizing pending and candidate null; later plans add their required artifacts.

`L` retains the unchanged Plan 03-02 command: `FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && FABLEBOOK_GUARD_AGGREGATE_WRITE=1 bin/lane floor test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors && bin/lane core test test/contract/tier_sweep_test.exs --only guard_aggregate_reconciliation --warnings-as-errors`.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-03 | 03-01 | 1 | GSR-01, GSR-04, GSR-06 | T-03-01, T-03-02, T-03-03 | Preserve committed zero-read recovery, then produce the bounded source-notes handoff without code/test changes. | bounded source review | Recovery/source-note artifact checks and execute preflight in the plan summary | Recovery receipt and source notes | ✅ documented complete |
| 03-01-04 | 03-01 | 1 | GSR-01, GSR-04, GSR-06 | T-03-01, T-03-03, T-03-04 | Real both-lane tracer with pinned provenance and atomic opt-in records. | contract/static tracer | Focused core/floor selectors and record checks in summary | Existing contract; collector/tags and lane/report artifacts | ✅ focused checks passed |
| 03-01-05 | 03-01 | 1 | GSR-01, GSR-02, GSR-04 | T-03-01, T-03-02 | Complete original identities/owners, exact sets and separate delivered/historical partitions. | contract/exact membership | Focused core/floor selectors and exact-set checks in summary | Tracer, records, and crosswalk | ✅ focused checks passed |
| 03-02-01 | 03-02 | 2 | GSR-03 | T-03-05, T-03-07 | Exact lane sources or individually typed source/provenance gaps. | contract/static source | Core/floor source selectors and source writer checks in summary | Collector, tags, source records | ✅ focused checks passed |
| 03-02-02 | 03-02 | 2 | GSR-03, GSR-06 | T-03-06, T-03-07, T-03-08 | Caller/delegate observations and gaps block recommendation. | contract/static graph | Core/floor caller selectors and keyed post-write checks in summary | Collector, tags, caller records | ✅ focused checks passed |
| 03-03-01 | 03-03 | 3 | GSR-05 | T-03-09, T-03-10 | Fresh exact-source/token/context/reread manifest or explicit missing measurement. | contract/sizing | Focused checks and bounded metadata validation in summary | Sizing and report artifacts | ✅ bounded checks passed |
| 03-03-02 | 03-03 | 3 | GSR-05, GSR-06 | T-03-09, T-03-10, T-03-11, T-03-12 | Enforce inherited fit limits and keep owner authority separate. | contract/fit decision | Focused checks and bounded metadata validation in summary | Sizing and report artifacts | ✅ bounded checks passed |
| 03-04-02 | 03-04 | 4 | GSR-01 through GSR-06 | T-03-14 | Stream retained membership into an unresolved metadata index. | metadata validation | Plan 03-04 automated schema, key, and hash checks | Gap index and receipt | ✅ metadata route complete |
| 03-04-03 | 03-04 | 4 | GSR-01 through GSR-06 | T-03-14, T-03-15 | Publish a bounded no-candidate metadata handoff. | metadata validation | Plan 03-04 report and validation checks | Gap report and validation | ✅ metadata route complete |
| 03-05-01 | 03-05 | 5 | GSR-01 through GSR-06 | T-03-16, T-03-17 | Repair independent local failures and record the actual Phase 4 state without claiming source resolution. | formatting / planning corpus | Format check, intent corpus test, exact source/citation checks and execute preflight | Recovered intent, compact schedule and readiness receipt | ✅ local checks pass; source work remains gated |
| 03-05-02 | 03-05 | 5 | GSR-01 through GSR-06 | T-03-18 | Repair same-lane source/caller consumers, nullable collision fixture and supplement validation while preserving typed gaps; explicitly test crosswalk completeness independently from source-resolution and caller-closure status. | consumer / contract | Validator self-test, `--phase4-only`, `--consumer`, focused core/floor tests (crosswalk regression: 5 passed, 104 excluded) and independent review | Validator, recovery crosswalk, `test "source join completeness follows gaps"`, test/helper changes and review receipt | ✅ local checks pass; source resolution and caller closure remain open |
| 03-05-03 | 03-05 | 5 | GSR-06 | T-03-18 | Reconcile local validation and handoff state without changing safety stops or claiming delivery. | full lane / planning | Core CI (459 passed, 10 excluded), full floor suite (467 passed, 0 failures, 2 excluded), scoped `git diff --check`, execute health and state refresh | Readiness, validation, STATE and generated state projection | ✅ local suites pass; phase verification and hosted delivery remain pending |

*Status: ⬜ not run · ✅ evidence recorded within scope · ❌ required check failed · ⚠️ partial or unresolved*

## Current execution outcome

Plan 03-05's current local results are in [03-RECOVERY-READINESS.md](03-RECOVERY-READINESS.md); the original failed [03-READINESS.md](03-READINESS.md) remains historical. Phase 3 self-test (38 controls), Phase 4 self-test (69 controls), Phase 4 validation (`pass_with_open_gaps`), and the Phase 3 consumer check (`consumer_consistent`) pass on generation `ENV-20261117-06-supported-20261117T204102Z`, with 9,716 explicit typed gaps, zero source associations, 18 unknown target sets, unresolved source resolution, incomplete caller closure and candidate null. The crosswalk completeness regression passes in the focused selection (5 passed, 104 excluded). Current-hash focused core and floor selections passed 9 tests each (100 excluded each). Core CI passed (459 passed, 10 excluded); the full floor suite passed (467 passed, 0 failures, 2 excluded). The final focused intent-corpus check passed (22 tests, 0 failures). A scoped whitespace check on changed code and planning files passed; the earlier whole-tree check found inherited historical whitespace findings and was not repeated. The existing local `act` incompatibility was not retried; hosted CI and merge receipts do not exist. The code review has no unresolved blocking finding. Phase verification remains separate, and the actual-collision, Macro caller-AST, explanation, static-only, SEC-01 and aggregate-closure stops remain open. The validation map records coverage completeness only; it does not waive these stops or claim phase delivery. `wave_0_complete` remains false.

---

## Wave 0 Requirements

- [ ] Independent review accepts the revised Wave 1 before any source read or implementation resumes. The completed zero-read recovery and its gated source-notes continuation remain under task node 03-01-03 and precede tracer task 03-01-04.
- [x] Leading tracer adds `:guard_aggregate_reconciliation`, `:guard_aggregate_reconciliation_records` and `:guard_aggregate_reconciliation_bundle` tagged checks inside existing `test/contract/tier_sweep_test.exs`, reusing its private authoritative ledger and current graph.
- [x] Leading tracer adds only `test/support/guard_aggregate_reconciliation_evidence.ex` for the missing aggregate receipt/renderer; reuse InstalledOtp and SweepEvidence for inventory/source authority.
- [x] Confirm each focused selector runs nonzero relevant tests; their results are recorded, including the source-coverage failure.
- [x] Confirm both pinned lane toolchains are available; no lane substitution occurred.
- [x] Keep contract-test changes separate from `lib/**` and `.github/**`; current branch/worktree comparison found no protected-path changes.

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

- [x] All twelve active tasks have a focused automated command or an explicit process/artifact dependency.
- [x] Sampling continuity has no three consecutive tasks without automated verification.
- [x] Wave 0 coverage includes inventory, membership, source-link and sizing contracts.
- [x] No watch-mode flags.
- [x] Feedback latency is based on the current pinned-lane CI and focused-test receipts.
- [x] `nyquist_compliant: true` set after the independent coverage audit found no missing automated gap.

**Approval:** validated. The open source/caller, actual-collision, Macro caller-AST and explanation stops remain documented; validation coverage does not waive them or claim Phase 3 delivery.

## Spec-less assumptions and prohibition review

Plan 03-05 retains all 13 supplied unresolved edge prompts, including both unclassified items, with planned task checks. It also records the two-stage recall/precision pass for all six requirements and six unresolved bespoke safety/transparency prohibitions. These remain unresolved until execution evidence and independent judgment establish an honest resolution; merely writing a check does not resolve the probe. Generic archive/path/privacy canon remains with the existing resolver/project rules and security review. No new user-facing values or thresholds are assumed.

## Validation Audit 2026-11-18

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
