# Planning owners and lifecycle

Authority: INT-20261111-01 and INT-20261111-03. This project rule applies to every milestone; it does not start a new phase or replace OpenGSD's quality gates.

## One owner for each fact

| Fact | Owner | Derived views / proof |
|---|---|---|
| Current version, phase and stopping point | STATE.md | SDK state queries and generated state.json |
| Active integer phases, goals and progress | ROADMAP.md | phase directories, SDK roadmap and progress queries |
| Active acceptance and citations | REQUIREMENTS.md | phase plans, summaries and verification |
| Original wider product commitments | references/PRODUCT-REQUIREMENTS.md | original IDs/citations retained; checked state advances only with scoped proof |
| Future phase addresses and prerequisites | migrations/2026-11-11-milestone-reset/PHASE-MAP.json | PRODUCT-ROADMAP.md is the readable companion; update both under cited intent when re-scoping |
| Cross-milestone blockers and special requirement owners | references/PLANNING-GATES.json | original evidence in CARRY-FORWARD.md; closing a gate needs a passed report with matching `goal_scope` |
| Delivered active-era phases | references/PHASE-DELIVERIES.json | append-only records corroborated by actual GitHub merge and hosted CI receipts |
| Seeds | seeds/ | explicit future milestone key and phase; original provenance retained |
| Frozen migration facts | INITIAL-RECEIPT.json and ARCHIVE-MANIFEST.json beside the migration | default verify.py checks original bytes/initial facts; `--initial-layout` is only a one-time activation check |

`state.json` is a best-effort SDK cache. Its milestone may include the display name. Its `next` recommendation depends on git/fingerprint context and can be wrong for a delivered phase. Refresh it with `bin/refresh_planning_state`, never with an independently written next command. No extra next-command registry is maintained.

## Each boundary

Run `bin/planning_health --stage <stage> [--phase N]` before the corresponding workflow mutates state. The same pure validator checks the current corpus in the existing planning test lane, with isolated positive/negative transition fixtures. Errors stop the workflow. Core workflow checks still establish source freshness, plan quality, security, CI and owner approval.

| Boundary | Required project evidence | Workflow |
|---|---|---|
| Scope | canonical phase, valid owners/dependencies and no delivered-phase reentry | `$gsd-discuss-phase N` |
| Plan | selected guard context; original safety stops, source limits, bounded exit and owner choice preserved | `$gsd-plan-phase N` |
| Execute | plans belong to this integer phase; typed prior-phase delivery receipts exist | `$gsd-execute-phase N` |
| Verify | each plan has a summary that is not halted/failed/incomplete | `$gsd-verify-work N` |
| Ship | a passed phase verification report, plus all normal fresh evidence/review/CI requirements | `$gsd-ship N` |
| Close milestone | its phases/requirements complete, summaries/reports present, actual merged deliveries recorded | `$gsd-audit-milestone`, then `$gsd-complete-milestone` after required boundary approval |
| Next milestone | prior active scope can close, or supported completed/archive/defining state; carried obligations retain owners | `$gsd-new-milestone` after owner chooses scope; then activate its explicit key and integer phases |

The check intentionally supports a legitimate between-milestone state with no active phases; it never borrows another version's shipped status. A new milestone's Phase 1 is a different identity from a prior version's Phase 1. Product milestones may be discussed/planned before all implementation prerequisites are delivered, except an explicit milestone-activation blocker such as the walking-skeleton guard aggregate. Execution requires the typed prerequisites' actual deliveries.

## Delivery record

The registry schema is `fablebook.phase-deliveries/1`, with a `phases` array. Each record has `milestone` (for example `v0.3`), `milestone_key`, `phase` (integer string), `status: merged`, `pr` (positive integer), `reviewed_head`, `merge_commit` (full Git SHAs) and `ci_run` (hosted Actions URL). Only actual observed receipts are recorded. The registry starts empty: the reset and health repairs do not deliver the unstarted guard phase. Append the record after merge, alongside canonical progress; batch its commit with substantive work to avoid receipt-only CI loops. Existing records are append-only against the PR diff base.

`route_phase` is calculated from current canonical phase plus versioned delivery facts, excluding delivered phases. It is advisory until preflight passes. If all active phases are delivered, follow the explicit milestone-close boundary. Never reopen an old implementation merely because later shared code made its historical fingerprint stale. Preserve that historical result; inspect a real reported regression in a new scoped task. A completed roadmap checkbox also blocks automatic discuss/plan/execute reentry while its merge receipt is pending; shipping remains possible, and milestone closure waits for the actual delivery. Explicit old-phase verification remains possible and must use fresh evidence.

## Bounded progress and carry-forward

A guard milestone ends when its selected scope passes. It does not depend on finishing every future feature or every global observation. Before selecting another increment, show the measurable product blocker removed, selected source membership and complement, limits/estimates, exit proof and the next owner decision. If this cannot be made bounded, surface the concrete scope/safety conflict; do not create a decimal phase ladder or repeat status commands as work.

The complete guard aggregate remains open. Walking skeleton stays blocked until aggregate-scoped proof passes. SEC-01 remains with Controls and first bundle / Phase 1. Scheduled observations keep their own owner/command/window; missing time history remains not-run. Other known unfinished acceptance stays in CARRY-FORWARD.md. Never backfill the superseded v0.1 cycle as shipped or refresh its stale fingerprints to manufacture a pass.

## Limits and recovery

This is a repository preflight plus agent entry instructions and CI regression coverage. It does not patch the installed OpenGSD engine or intercept every raw CLI invocation. GitHub merge/CI facts still require live corroboration; a local JSON row alone is not proof. The check validates metadata/report status and scope, not semantic completeness or source freshness. Core verification/review and owner decisions remain necessary.

Current single-stream operation is supported. Introducing workstreams requires a deliberate scoped extension; the check stops on an active-workstream pointer instead of validating the wrong root. Unknown/malformed input fails closed. Preserve existing primary/recovery worktrees; reconcile current main and delivery receipts before resuming a stale checkout. Global install warnings and preserved-worktree warnings are diagnostics, never reasons to delete evidence.
