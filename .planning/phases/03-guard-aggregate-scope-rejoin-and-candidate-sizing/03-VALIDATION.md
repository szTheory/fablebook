---
phase: "3"
slug: "guard-aggregate-scope-rejoin-and-candidate-sizing"
status: complete
nyquist_compliant: true
wave_0_complete: true
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
| **Quick run command** | `bin/lane core test test/contract/guard_aggregate_metadata_test.exs --only guard_aggregate_reconciliation_metadata --warnings-as-errors && bin/lane floor test test/contract/guard_aggregate_metadata_test.exs --only guard_aggregate_reconciliation_metadata --warnings-as-errors` |
| **Full suite command** | `MIX_ENV=test bin/lane core mix ci && bin/lane floor test --warnings-as-errors --include prod_guard --include release` |
| **Estimated runtime** | Use current core and floor CI receipt timings; no tests were run during planning research. |

---

## Sampling Rate

- **After every task commit:** For 03-01-03, confirm the committed zero-read recovery receipt remains unchanged, then check the bounded three-event source-notes continuation and preflight; after each implementation task run its focused aggregate checks with explicit pinned lane selection.
- **After every plan wave:** Run the focused aggregate contract test on both pinned lanes and inspect the generated evidence without invoking audited OTP functions.
- **Before `$gsd-verify-work`:** Run both full pinned-lane suites and record the local tested head. Final-head delivery checks and hosted CI receipts remain with verification and ship.
- **Max feedback latency:** Use current pinned-lane CI timing; record task intervals and keep each plan within the inherited effort bound.

---

## Per-Task Verification Map

The current phase index has eleven active tasks across five sequential waves: 3 + 2 + 2 + 2 + 2. The earlier twelve-task map was stale after the approved Plan 03-04 metadata-only replan; its active plan contains tasks 03-04-02 and 03-04-03, while the original semantic source review remains blocked by missing evidence. Wave 1 keeps three task nodes: recovery/source-note task 03-01-03, tracer 03-01-04, then membership expansion 03-01-05. The old 03-01-01 attempt remains historical failed work: 13 exact-source body-read events exceeded five. Old 03-01-02 was retired without execution. The later truncated Task 03-01-04 event remains consumed and incomplete. Plan 03-02 cannot begin before the successful 03-01 summary. `Q` below means the exact quick run command above. Records-only and bundle selectors are additional tags created by the tracer, not separate workflow tasks. Actual current outcomes are recorded below and in [03-READINESS.md](03-READINESS.md); unresolved source/caller proof remains open.

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
| 03-05-01 | 03-05 | 5 | GSR-01 through GSR-06 | T-03-16, T-03-17 | Record real local checks and act feasibility without implying hosted delivery. | full lane | Core/floor focused and full commands; exact results in [03-READINESS.md](03-READINESS.md) | Readiness receipt and logs | ✅ local readiness passed; hosted delivery pending |
| 03-05-02 | 03-05 | 5 | GSR-06 | T-03-18 | Reconcile the current handoff and validation state without changing safety stops. | planning/static | `git diff --check HEAD` and `bin/planning_health --stage execute --phase 3`; base-to-main diff check retained as inherited whitespace evidence | Readiness, validation, STATE, generated state projection | ✅ canonical handoff refreshed; inherited base diff whitespace recorded |

*Status: ⬜ not run · ✅ evidence recorded within scope · ❌ required check failed · ⚠️ partial or unresolved*

## Current execution outcome

Plan 03-05's current local results are in [03-READINESS.md](03-READINESS.md).
The corrected core command runs under `MIX_ENV=test`, matching GitHub Actions;
the full core and floor suites pass, as do the standalone metadata checks on
both pinned lanes, the CI-shape contract, formatting, intent corpus and scoped
strict Credo. The earlier failed attempts remain in the readiness history and
are superseded only by these current receipts. The branch-to-main whitespace
check still reports inherited planning/archive Markdown whitespace; the
worktree-only check and planning preflight pass. The known `act`
`concurrency.queue` incompatibility was reused without another unsupported
attempt. All 11 active task nodes across five waves have task-specific checks
and execution evidence, so Nyquist coverage and Wave 0 are complete. This
coverage result does not close GSR-03/GSR-05: the 4,797 known mapping gaps and
18 unknown target sets remain unresolved, the collision remains unknown, and
no candidate or implementation is authorized.

---

## Wave 0 Requirements

- [x] Independent review accepted the revised Wave 1 before source reads; the completed zero-read recovery and gated source-notes continuation remain under task node 03-01-03 ahead of tracer task 03-01-04.
- [x] Leading tracer added the three tagged checks inside existing `test/contract/tier_sweep_test.exs`, reusing its private authoritative ledger and current graph.
- [x] Leading tracer added only `test/support/guard_aggregate_reconciliation_evidence.ex` for the missing aggregate receipt/renderer and reused InstalledOtp and SweepEvidence for inventory/source authority.
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

- [x] All tasks have a focused automated command or an explicit Wave 0 dependency.
- [x] Sampling continuity: no 3 consecutive tasks without automated verification.
- [x] Wave 0 covers missing aggregate inventory, membership, source-link, and sizing contracts.
- [x] No watch-mode flags.
- [x] Feedback latency is based on current pinned-lane CI receipts.
- [x] `nyquist_compliant: true` is set after validation confirmed the plan's verification coverage.

**Validation status:** Complete for planned task coverage and recorded execution evidence. GSR-03/GSR-05 evidence gaps, unknown collision status, and owner-only implementation decisions remain open by design; they are not misreported as verified facts.

## Spec-less assumptions and prohibition review

Plan 03-05 retains all 13 supplied unresolved edge prompts, including both unclassified items, with planned task checks. It also records the two-stage recall/precision pass for all six requirements and six unresolved bespoke safety/transparency prohibitions. These remain unresolved until execution evidence and independent judgment establish an honest resolution; merely writing a check does not resolve the probe. Generic archive/path/privacy canon remains with the existing resolver/project rules and security review. No new user-facing values or thresholds are assumed.
