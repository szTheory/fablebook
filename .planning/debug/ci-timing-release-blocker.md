---
status: diagnosed
trigger: "Diagnose UAT test 15: timing-only CI p50/p95 breaches create quality-regression issues that block release PRs despite INT-20261106-01."
created: 2026-11-06
updated: 2026-11-06T13:43:14Z
audit_acknowledged:
  milestone: v0.2
  at: 2026-11-11
  status: diagnosed
---

## Current Focus

hypothesis: Confirmed — the timing threshold branch still uses the shared quality-regression helper; the release gate correctly blocks that label, so stale producer classification indirectly blocks releases.
test: Unchanged bin/ci_health executed with in-memory GitHub fixtures and --dry-run; exact release guard body executed with fake issue counts.
expecting: Confirmed producer classification and release gate causality.
next_action: Return ROOT CAUSE FOUND to the orchestrator for gap planning; no implementation, test, issue, workflow dispatch, or policy edits authorized in this diagnosis.
mode: find_root_cause_only
bug_class: bohrbug
candidate_causes:
  - code: timing producer classifies objective breaches as correctness regressions.
  - config: release label filter accidentally includes performance labels or ci-health is required by ci-gate.
  - data: the existing issue also contains functional or ruleset failures, requiring mixed-issue handling.
and_gate: yes; the observed release failure needs both a timing alert labeled quality-regression and the release job's open-label guard. Only the former conflicts with the owner decision.
reasoning_checkpoint:
  hypothesis: Timing-only overages block release because bin/ci_health:93 routes them through the quality-regression helper and release nightly rejects any open issue bearing that label.
  confirming_evidence:
    - Unchanged script reports p50=421/p95=421 for ten successful gates, exits 0, and prints a would-be quality-regression issue under dry-run.
    - Exact release guard body exits 1 for one quality-regression issue and 0 for zero; ci-gate includes nightly in its required needs.
  falsification_test: A successful timing-only fixture above 420/600 producing no quality-regression output, or the extracted release guard accepting a nonzero quality issue count, would refute this mechanism.
  fix_rationale: Separate only timing alert routing into ci-performance while retaining the existing helper and quality release guard for actual failures; migrate the existing timing-only issue after inspecting for mixed content.
  blind_spots: No live issue read or edit was performed; current issue 37 comments and ci-performance label existence remain unverified. No hosted release PR executed.
  candidate_causes:
    - code: timing producer uses generic release-blocking regression helper.
    - config: release gate accidentally includes performance issues or requires ci-health directly.
    - data: existing shared quality issue may aggregate timing and genuine regressions.
  and_gate: yes; both wrong producer label and the intended release label guard cause the reported block. Only producer classification is defective; mixed live issue contents are an operational migration risk, not needed for fixture reproduction.

## Symptoms

expected: CI timing p50/p95 objectives remain non-blocking and tracked separately as ci-performance; correctness quality regressions remain release blocking.
actual: Timing-only breaches create/update quality-regression issues and release PR gate fails on any open quality-regression issue.
errors: UAT test 15 reports policy mismatch with owner decision INT-20261106-01.
reproduction: Evaluate timing-only breach with no failed runs, then evaluate a release PR with the generated issue open.
started: Observed during phase 01 UAT; exact introducing change not yet investigated.

## Eliminated

- hypothesis: Timing objectives directly fail ci-health or ci-gate needs ci-health, independently of issue labels.
  evidence: Fixture timing overages exit 0, and ci-gate needs only core/floor/dialyzer/security/nightly.

- hypothesis: The release label filter explicitly includes ci-performance and needs to be relaxed.
  evidence: Workflow guard queries only quality-regression. It matches the approved ADR; changing it would risk weakening the genuine quality gate.

- hypothesis: Actual unsuccessful ci-gate jobs or ruleset drift are necessary to produce this alert.
  evidence: Reproduction uses ten success jobs and exact required contexts [ci-gate], yet the timing-only branch emits quality-regression.

## Evidence

- checked: Session initialization and project skill/config discovery.
  found: No prior .planning/debug directory or project skill directories found; agent_skills is empty.
  implication: No prior debug knowledge-base match available; no additional configured skill rules.

- checked: Knowledge-base discovery.
  found: MemPalace CLI is unavailable; .planning/debug/knowledge-base.md does not exist.
  implication: No semantic or keyword prior resolution to seed this investigation.

- checked: Owner decision INT-20261106-01 and ADR 0017.
  found: Both retain 420/600-second objectives and require timing-only overages to use ci-performance without updating quality-regression; functional/security/ruleset/release failures retain gates.
  implication: The policy boundary is alert classification, not disabling the release quality gate or relaxing objectives.

- checked: Full bin/ci_health and .github/workflows/ci.yml.
  found: Timing overage calls file_regression at bin/ci_health:93, which hardcodes quality-regression at line 45. The release-only nightly guard blocks any open issue with that label at workflow lines 131-135. ci-gate requires nightly, and does not require ci-health.
  implication: The release block is an indirect issue-label path; a timing breach itself does not return nonzero.

- checked: Full ci_health contract tests and relevant CI-shape validation.
  found: Timing breach tests explicitly assert quality-regression, even though all fixture ci-gate jobs succeeded. Shape tests preserve --file-regression failure hooks but do not execute the release guard with separate quality/performance issue labels.
  implication: Existing tests encode the previous timing policy and lack the cross-label release boundary regression coverage.

- checked: SBFL eligibility.
  found: No desired-policy failing test or per-test coverage spectrum is present; diagnosis is restricted from changing tests.
  implication: Skip SBFL; use deterministic fixture reproduction and source tracing instead. Git bisection is unnecessary for policy newly approved while implementation remains unchanged.

- checked: Deterministic script reproduction without modifying source, tests, or persistent fixtures.
  found: An in-memory Bash gh function supplied ten first-attempt feature PR success jobs and exact ci-gate rules. Real bin/ci_health --dry-run returned 0 for 420-second, 421-second, and 601-second samples. The 420-second sample published only ci-timing; 421 and 601 emitted both ci-timing and quality-regression. All external writes were suppressed, all GitHub calls replaced locally.
  implication: Timing-only p50 and combined p50/p95 overages use the wrong issue class even without any correctness failure. Percentile calculation and strict threshold comparison are functioning; disabling those measurements is unnecessary.

- checked: Exact release guard body extracted directly from ci.yml:131-135.
  found: With fake gh returning one open quality issue the shell exits 1 with the release-blocking error; returning zero exits 0.
  implication: The issue label is sufficient for the downstream release block. No hosted workflow or issue mutation was needed to establish causality.

- checked: Operational migration boundary and existing issue helper behavior.
  found: post_to_issue lists the first open issue for a label (limit 1) and comments into it without classifying its existing content; it does not close or relabel issues. UAT records existing timing issue 37 as open. No ci-performance provisioning or usage exists in executable repository code.
  implication: A producer-only code change prevents future misclassification but does not clear the existing blocker. Inspect issue 37 and any combined comments before removing a quality label; preserve genuine failures in a separate quality issue. Verify/create ci-performance label before rollout so a missing-label/API error does not fail ci-health and invoke its legitimate quality failure hook.

## Resolution

root_cause: The new owner-approved timing policy has not reached executable alert classification or its tests. bin/ci_health:93 still calls file_regression for p50 >420 or p95 >600 with n>=10, and that helper hardcodes quality-regression at line 45. This composes with the intended release-only nightly guard at ci.yml:131-135 and required nightly dependency at :150 to block release whenever that issue is open. Existing timing contract tests explicitly require the old label at ci_health_test.exs:114.
fix: Not applied; diagnosis-only scope.
verification: Deterministically reproduced with unchanged source and successful fixture jobs; timing overage exits 0 but emits quality-regression, and the exact release guard exits 1 for that class. No live workflow, issue access, or implementation/test changes performed.
files_changed: []

## Suggested Change Boundary and Risks

- Implementation: change only timing-overage routing at bin/ci_health:90-94 to ci-performance; retain ci-timing publication, sample eligibility, nearest-rank calculation, n>=10 minimum and strict 420/600 comparisons. Keep file_regression and --file-regression behavior for ruleset drift, nightly/ci-health failures and release smoke. Keep the quality-regression release filter and required ci-gate needs unchanged.
- Contract coverage: update the existing p50/p95 breach cases to require ci-performance and forbid quality-regression for timing alone; cover creation and existing-performance issue updates, exact boundaries and insufficient samples, coexistence with real ruleset drift, dry-run behavior, and release guard execution for performance-only versus genuine quality issues. Existing successful-job fixtures are already suitable for timing-only cases.
- Operational follow-through: after deployment, ensure the ci-performance label exists, inspect issue 37 for mixed timing/quality content, then reclassify timing-only content without deleting a genuine blocker. Changing the producer alone cannot unblock an already-open quality-regression issue.
- No broader policy change needed: do not change objectives, remove failure reporting, suppress API errors, alter schedule/permissions/check inventory, or optimize CI as part of this single UAT fix. Missing-label/API failures are reporting/check failures, not timing-only overages, and must retain existing failure handling.
- Scope limit: current hosted labels and issue content were not independently inspected. Treat UAT live observations as recorded evidence, not a new live verification.

specialist_hint: general (Bash CI automation and GitHub Actions; Elixir contract tests)
