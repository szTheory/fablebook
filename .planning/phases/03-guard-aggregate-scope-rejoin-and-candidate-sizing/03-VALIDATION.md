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
| **Quick run command** | `bin/lane core test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors && bin/lane floor test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors` |
| **Full suite command** | `bin/lane core test --warnings-as-errors --include prod_guard && bin/lane floor test --warnings-as-errors --include prod_guard` |
| **Estimated runtime** | Use current core and floor CI receipt timings; no tests were run during planning research. |

---

## Sampling Rate

- **After every task commit:** Run the focused aggregate contract test with explicit core or floor lane selection for the affected work.
- **After every plan wave:** Run the focused aggregate contract test on both pinned lanes and inspect the generated evidence without invoking audited OTP functions.
- **Before `$gsd-verify-work`:** Run both full pinned-lane suites and record the local tested head. Final-head delivery checks and hosted CI receipts remain with verification and ship.
- **Max feedback latency:** Use current pinned-lane CI timing; record task intervals and keep each plan within the inherited effort bound.

---

## Per-Task Verification Map

Plan, wave, and task IDs are assigned when the planner decomposes the six requirements. Every row remains pending until that mapping and its verification command are confirmed.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| TBD | TBD | TBD | GSR-01 | TBD | Fresh core and floor inventory records bind exact lane/runtime/archive identity and provenance; inventory does not invoke audited targets. | contract/static evidence | `bin/lane core test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors && bin/lane floor test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors` | ❌ Wave 0 | ⬜ pending |
| TBD | TBD | TBD | GSR-02 | TBD | Every original row retains exact owner and per-lane selected, added, missing, delivered, and pending MFA sets. | contract/exact membership | `bin/lane core test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors && bin/lane floor test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors` | ❌ Wave 0 | ⬜ pending |
| TBD | TBD | TBD | GSR-03 | TBD | Surviving targets link to exact lane-specific sources and caller/delegate edges, or retain an explicit evidence gap. | contract/static source | `bin/lane core test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors && bin/lane floor test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors` | ❌ Wave 0 | ⬜ pending |
| TBD | TBD | TBD | GSR-04 | TBD | EX-010 and EX-107 receipts and all historical partitions stay distinct and unchanged. | contract/integration | `bin/lane core test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors && bin/lane floor test test/contract/guard_aggregate_reconciliation_test.exs --warnings-as-errors` | ❌ Wave 0; EX-107 partition pattern exists | ⬜ pending |
| TBD | TBD | TBD | GSR-05 | TBD | Candidate source, context, plan, and effort sizing fits every inherited limit or records the concrete no-candidate gap. | contract/sizing + review | Focused aggregate contract test on both lanes plus plan sizing review | ❌ Wave 0 | ⬜ pending |
| TBD | TBD | TBD | GSR-06 | TBD | Evidence keeps the static-only boundary, collision stop, SEC-01 owner, open aggregate gate, Walking Skeleton block, and separate owner decision inspectable. | contract/document | Focused aggregate contract test on both lanes plus phase verification | ❌ Wave 0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] Add `test/contract/guard_aggregate_reconciliation_test.exs` for inventory provenance, exact row/MFA membership, source links, delivered partitions, candidate sizing, and retained safety boundaries.
- [ ] Add or extend only a narrowly scoped `test/support/` collector if the existing helpers cannot produce a required record.
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
