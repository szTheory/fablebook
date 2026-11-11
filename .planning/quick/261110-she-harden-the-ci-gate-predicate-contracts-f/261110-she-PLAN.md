---
phase: quick-261110-she
plan: "01"
type: execute
wave: 1
depends_on: []
autonomous: true
files_modified:
  - test/contract/ci_shape_test.exs
requirements:
  - INT-20261110-07
must_haves:
  truths:
    - The real CI workflow and base fixture pass every existing rule.
    - The gate contract rejects all-to-any, omitted-required-job and weakened skip policy mutations for the intended rule.
    - Gate environment and executable predicate are checked within their own step rather than satisfied by unrelated marker text.
    - Benign comments, blank lines and env-key order remain accepted.
    - Workflow and library bytes remain unchanged.
---

<objective>
Close the CI-gate predicate contract gap from the November 10 UAT audit without changing its correct production predicate. The implementation scope is exactly test/contract/ci_shape_test.exs. Preserve all other UAT owners, the stopped parent audit, SEC-01 Pending with Phase 5 and the Phase 2 gate.
</objective>

<context>
Read CLAUDE.md, AGENTS.md, .planning/VERIFICATION.md, .planning/STATE.md, GLOSSARY.md, docs/adr/0017-ci-cd-layout.md, docs/adr/0021-delivery-rules.md and .planning/audits/2026-11-10-UAT-AUDIT.md. The live base is origin/main at ea2b09914512b9059be951157e0f1b4cd7d91007; four saved documentation-only receipts have been carried for the next substantive push. Preserve the primary and recovery checkouts.

Default quick mode omits optional discussion/research/checker/verifier stages. Planning and execution run inline and sequentially under the skill adapter's no-automatic-spawn fallback. The supported GSD worktree helper created a separate task checkout; no harness-created subagent isolation is claimed. The negotiated dispatch mode is none, with workflow.use_worktrees false; no orphan cleanup runs. No project skill override is configured.
</context>

<tasks>
<task type="auto" tdd="true">
  <name>Task 1: Pin the scoped gate environment and canonical predicate with regression controls</name>
  <files>test/contract/ci_shape_test.exs</files>
  <action>Add non-vacuous mutations for all-to-any and filtering down to one required job; prove the current substring validator misses them. Add controls for wrong HEAD_REF binding, weakened release-only nightly skip policy and marker text in a comment that cannot replace executable policy. Replace the four-substring gate_step? acceptance with a small comparison of the gate step's required environment and exact canonical shell/jq program, using the existing normalized-step parser. Keep comparison local to that step, tolerate harmless blank rows, YAML/leading shell comments and env-key order while preserving every line inside the quoted jq program, and reject changed command or wiring. Do not add a YAML parser, dependency, new file or generic framework. Keep every old mutation and wiring/needs/always rule. The real workflow and existing base fixture are passing controls; run benign syntax controls through all validators for each. Capture honest fail-before/pass-after evidence in ignored build logs. Any failed diagnostic or empty selection is not RED proof.</action>
  <verify>
    <automated>MIX_ENV=test bin/lane core test --warnings-as-errors test/contract/ci_shape_test.exs</automated>
    <automated>MIX_ENV=test bin/lane floor test --warnings-as-errors test/contract/ci_shape_test.exs</automated>
  </verify>
  <done>Every new weakening reaches exactly ci_gate_step; unchanged real/base workflows and benign syntax pass, and existing contract mutations remain intact.</done>
</task>
<task type="auto">
  <name>Task 2: Review and validate the contract-only delivery</name>
  <files>test/contract/ci_shape_test.exs</files>
  <action>Format and run full core CI, with the floor-focused contract as compatibility proof before hosted full lanes. Review the complete diff for scope, attributable controls and parser boundaries within the two-pass review cap. Check .github, lib, mix.exs and lockfiles remain byte-identical to the fetched base. Attempt relevant local Actions once with act; record its known concurrency.queue parser limitation honestly, without workflow edits or retries. Record actual command exits, tested revision/digest and timing. Publish the reviewed/tested candidate under standing authorization and wait for required hosted core/floor/Dialyzer/security/ci-gate receipts. Do not dispatch scheduled reporting, publish packages, alter issues or start another phase. Batch final receipt-only bookkeeping locally for the next substantive push. The owner handles merge.</action>
  <verify>
    <automated>MIX_ENV=test bin/lane core mix ci</automated>
    <automated>git diff --check origin/main</automated>
    <automated>git diff --exit-code origin/main -- .github lib mix.exs mix.lock mix.floor.lock</automated>
  </verify>
  <done>Local checks and review pass, protected source has no diff, and required hosted candidate checks pass. Quick STATE and summary records describe actual delivery state.</done>
</task>
</tasks>

<verification>
No new production behavior exists. Focused core/floor contracts prove the static test helper and accepted/rejected controls on each toolchain; full local core CI catches repository interactions. The unchanged full floor lane is delegated to the required hosted candidate check rather than repeated natively, reducing duplicate full-suite work while preserving all hosted gates. Do not run native Mix lanes concurrently because nested fixtures share some build paths. Checks use background/piped processes and never take desktop focus. No owner UAT is needed.

Execution note: the complete native core run later reported one timeout in an unchanged saved-settings test; its isolated retest passed under the same limit. The full command remains recorded as failed. Reuse the other passing results and require the canonical full hosted core/floor runs, rather than repeating unrelated native coverage. No gate, timeout or exclusion is relaxed.
</verification>

<threat_model>
ASVS level 1; high/critical findings block delivery.

| Threat | Severity | Mitigation |
|---|---|---|
| Gate marker strings conceal all-to-any or omitted-job acceptance | high | Exact scoped command comparison plus independent rejected mutations. |
| Gate HEAD_REF/NEEDS wiring is weakened while marker text remains | high | Compare required bindings inside the same step; wrong-binding and decoy controls. |
| A test falsely rejects harmless syntax or weakens unrelated guards | high | Both real/base workflows, benign controls and all old mutations pass. |
| Scope or side effects expand during delivery | high | One contract source file only; no workflow/lib/dependency edits, installs, dispatches or external messaging. |
</threat_model>

<planner_contributions>
No external service integration or database/schema change exists. Run the API detector against this plan; produce a no-integration declaration only if its typed result requires one. Assumption-delta cannot resolve a roadmap phase for a quick task, so retain a typed skip rather than inventing a negative. There is no primary identity-model change. Security enforcement is represented above.
</planner_contributions>

<source_audit>
| Source | Coverage |
|---|---|
| GOAL | Owner's CI-gate UAT hardening request; Tasks 1–2. |
| REQ | Existing ADR 0017 gate semantics and ADR 0021 contract separation retained; no roadmap requirement completion claimed. |
| RESEARCH | No optional research stage requested; prior audit supplies attributable misses at an unchanged ci_shape_test.exs digest. |
| CONTEXT | Owner scope is contract-only, preserving workflow/lib, other UAT ownership and all safety gates; Tasks 1–2 and threat model. |
</source_audit>

<output>
The orchestrator owns PLAN, SUMMARY, quick-task STATE bookkeeping, audit landing disposition, publication and CI receipts. Do not edit ROADMAP or claim the other four UAT groups, the parent aggregate or SEC-01 complete.
</output>
