---
phase: "01"
slug: bounded-guard-continuation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: "2026-11-11"
---

# Phase 1 validation strategy

Existing ExUnit, Credo, InstalledOtp, SweepEvidence and BeamWalker are the test infrastructure. No framework or dependency is added. This is an execution strategy, not a completed-validation receipt.

## Sampling and commands

- Per source/evidence task: the applicable exact lane's focused EX-010 source/witness contracts, with a nonzero test selection. Plans must name the tag they install before using it.
- Per lane plan: `bin/lane core test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs`, substituting `floor` for the floor plan.
- Integration implementation: both lane commands above, required format/compile/Credo/docs/release/security checks and independent review. Required hosted candidate CI supplements local checks; exact-head local/review/source-proof/hosted receipts belong in `01-CANDIDATE.md`, not a phase verification report. No receipt-only pushes.
- Post-plan delivery: only after all three truthful implementation summaries exist, run `bin/planning_health --stage verify --phase 1`, then independent technical phase verification in the single `01-VERIFICATION.md` with delivery pending. Only after that report passes run `bin/planning_health --stage ship --phase 1`; preserve exact-candidate owner merge approval and actual delivery bookkeeping after ship. Neither a green implementation summary nor technical pass authorizes phase closure.
- Existing graph-only discovery was measured at about 115 seconds core and 42 seconds floor after cold local dependency compilation. Full contract runtime is not inferred from this filtered run. Use background logs and investigate attributable failures before bounded retests.

## Per-task verification map

| Task | Requirements | Threat references | Secure behavior | Automated command | Status |
|---|---|---|---|---|---|
| 01-01-01 | GRC-01, GRC-03 | T-1-01–03 | Exact core sources, full row and source-backed findings | `bin/lane core test --warnings-as-errors test/contract/tier_sweep_test.exs --only inets_trace_core_source` | pending; tag created in task |
| 01-01-02 | GRC-02, GRC-03 | T-1-01–04 | Individual uncalled witnesses, benign/overlap/omission controls | `bin/lane core test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs --only inets_trace_core_controls` | pending; tag created in task |
| 01-02-01 | GRC-01, GRC-03 | T-1-05–07 | Independent floor bytes, full row and findings | `bin/lane floor test --warnings-as-errors test/contract/tier_sweep_test.exs --only inets_trace_floor_source` | pending; tag created in task |
| 01-02-02 | GRC-02, GRC-03 | T-1-05–08 | Floor witnesses, wrong-lane/removal/overlap controls | `bin/lane floor test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs --only inets_trace_floor_controls` | pending; tag created in task |
| 01-03-01 | GRC-01–03 | T-1-09–11 | Integrate structured findings and prove both-lane individual static controls | `bin/lane core test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs --only inets_trace_integration --only inets_trace_guards`; repeat on floor per Plan 03 | pending; tags created in task |
| 01-03-02 | GRC-01–03 | T-1-12–13 | Full candidate validation/review and exact-head source-proof/hosted receipts | `MIX_ENV=test bin/lane core mix ci`; exact floor validation commands and `gh pr checks --required` in Plan 03 | pending; implementation only, delivery pending |

These are six implementation tasks across three serial plans, with raw context budgets 67,518 / 69,888 / 71,000 and the full 31,000 reserve in each. All automated commands have observable failure conditions in their plans; a zero-test selection is never a pass. Tests establish source/fixture integrity and detection; independent source review establishes semantic judgments. Focused feedback is measured during execution; no unmeasured full-suite latency guarantee is asserted.

## Post-plan delivery verification map — orchestrator owned

These rows preserve existing phase obligations; they are not additional implementation tasks, plans or phases. Every row remains pending until real execution evidence is recorded.

| Boundary | Requirements | Threat references | Prerequisite and secure behavior | Check / evidence | Status |
|---|---|---|---|---|---|
| Truthful implementation summaries | GRC-01–03 | T-1-12–14 | All three plans actually finish; no fabricated interim complete summary or halted predecessor | Real `01-01-SUMMARY.md`, `01-02-SUMMARY.md`, `01-03-SUMMARY.md`; candidate evidence states delivery pending | pending |
| Verify | GRC-01–03 | T-1-09–14 | Run only after all truthful summaries; independently verify technical static scope | `bin/planning_health --stage verify --phase 1`, then single independent `01-VERIFICATION.md`; a technical pass explicitly leaves merge/whole-phase delivery pending | pending; not execution proof |
| Ship | GRC-02, GRC-03 | T-1-12–14 | All summaries and that single passed technical report exist before ship; same reviewed/tested green candidate | `bin/planning_health --stage ship --phase 1`; `gh pr checks --required`; actual exact-head/source-proof receipts | pending; not execution proof |
| Owner exact-candidate approval | GRC-02, GRC-03 | T-1-12 | Owner decides after ship prerequisites on concrete green candidate; silence or prior unrelated approval confers no authority | Actual owner decision and exact approved head in `01-MERGE.md`; ordinary authorized builds/tests/publishing require no additional approval | pending manual delivery boundary |
| Actual merge and main CI | GRC-02, GRC-03 | T-1-12–13 | Approved unchanged head, head-match squash merge, actual merge commit and required main successes | `gh pr checks --required` immediately before merge; `gh pr view --json number,url,state,mergedAt,mergeCommit,headRefOid,statusCheckRollup` afterward; required hosted main CI URLs bound to actual merge | pending actual delivery |
| Registry, canonical completion and bounded exit | GRC-02, GRC-03 | T-1-13–14 | Append real delivery only after approved merge and matching required candidate/main CI; only then advance phase/requirements | `01-MERGE.md`, append-only `PHASE-DELIVERIES.json`, canonical progress, `bin/planning_health --stage status --phase 1` and SDK refresh at commit boundary | pending; stop at owner phase/milestone choice |

Every automated boundary command and its failing direction is specified in Plan 03's post-plan handoff. The generic execute-phase `phase.complete` step must defer to D-12 and the project's actual-delivery gates until the merged registry fact exists. A technical verification pass cannot assert whole GRC-02 delivery acceptance or phase closure. No lifecycle preflight is weakened and no second `*VERIFICATION.md` report is created.

## Wave 0

Existing infrastructure covers the framework requirements. The lane plans must add EX-010-specific contracts/tags and bind both verified `inets_trace.erl` identities through the existing archive manifest/resolver. A zero-test selection, missing source, wrong lane, omitted match/citation or unsupported finding fails closed.

## Human boundaries

An actual newly justified guard collision with `lib/` stops for an owner remedy. Macro caller-AST and changed explanation wording retain their separate checkpoints; explanation changes are excluded. Merge approval remains a delivery boundary. SEC-01 runtime/property proof, aggregate closure, walking skeleton and later milestone selection are not covered by this static phase.

## Sign-off

- [ ] Every task has an automated verification or a preceding test-infrastructure dependency.
- [ ] Each lane's individual witnesses and omission/tamper/wrong-lane/overlap controls pass.
- [ ] Required independent review and local/hosted checks pass on the same candidate.
- [ ] Actual merged delivery is recorded before phase completion.

Approval: pending execution and verification; no completed phase or runtime-safety claim.
