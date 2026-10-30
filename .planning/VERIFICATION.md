# Verification policy

Owner direction: INT-20261029-08. Applies to every GSD discussion, plan, execution, review, verification and resume. The target is zero human UAT wherever the behavior can be checked automatically.

1. Map each acceptance criterion to existing executable evidence before adding work. Use the cheapest boundary that proves observable behavior: unit/property, integration, seam, consumer smoke, then browser E2E (ADR 0014).
2. Run checks autonomously inside the requested step. Replace reproducible manual instructions with durable tests. Test the real script or application at its boundary, including negative controls and failure paths; mock external writes so verification cannot publish or message by accident.
3. Put checks in existing CI lanes when they protect recurring behavior. Keep one-off historical reads in the phase evidence; preserve the three-workflow cap, latency budgets and contract-test separation (ADR 0017, ADR 0021).
4. Record test commands, results, tested revision, relevant file paths and CI run links in the phase UAT/verification files. Use `source: automated` for automated passes. Distinguish local checks from CI. Historical evidence stays historical; rerun checks when guarded code, dependencies or environment changed, a regression is reported, or evidence was incomplete.
5. Reuse recorded approvals and resolved findings. Before opening a gap, reconcile it against executed plans, merged PRs and explicit roadmap transfers. A previously approved decision needs no repeat sign-off without a material change. Record why remaining checks are unnecessary, unavailable or owned elsewhere.
6. Time-gated evidence belongs to scheduled automation with an explicit owner, command and observation point. Missing history remains `not-run`; it is not a human test or a pass. Escalate only if the automation cannot observe or enforce the requirement.
7. Hand off only irreducible human judgment (such as accepting a visual baseline or the owner's preference), inaccessible authority, or a real unresolved product decision. State the exact residual and why tools cannot resolve it. Keep existing gates, visual-baseline rules and honesty requirements intact.

INT-20261029-05 still applies: finish the requested GSD step and show its next command; the owner chooses when to advance. Autonomous verification does not enable workflow auto-advance.

## Phase 1 receipt

`phases/01-release-pipeline-ci-gate-and-guards/01-UAT.md` maps acceptance to executable checks and live read-only evidence. `test/contract/ci_health_test.exs` exercises `bin/ci_health` through a fake GitHub CLI, including percentile boundaries, history eligibility, drift and regression reporting; it runs in the existing core/floor test suites. Existing package, prod-guard, release-workflow, ban and planning contracts remain the primary proofs. Consult this receipt before proposing another manual Phase 1 walkthrough.
