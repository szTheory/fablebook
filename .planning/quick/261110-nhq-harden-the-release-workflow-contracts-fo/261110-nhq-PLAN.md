---
phase: quick-261110-nhq
plan: "01"
type: execute
wave: 1
depends_on: []
files_modified:
  - test/contract/hex_publish_test.exs
autonomous: true
requirements:
  - INT-20261110-05
estimate:
  tokens: 17000
  raw_tokens: 34000
  tasks: 3
  confidence: high
must_haves:
  truths:
    - The unchanged release workflow passes all contract validators on core and floor.
    - Each reproduced release-control mutation is rejected by a meaningful, attributable rule.
    - Local execution models the workflow's unspecified Linux shell and independently tests tag syntax, project version and commit ancestry.
    - Harmless comments and legitimate root env ordering pass while secret leakage after jobs is rejected.
    - Workflow and library bytes remain unchanged; all new execution stays within fake-command and temporary Git boundaries.
  artifacts:
    - path: test/contract/hex_publish_test.exs
      provides: Runner-accurate release contracts with rejected mutations and accepted syntax controls
  key_links:
    - from: test/contract/hex_publish_test.exs
      to: .github/workflows/hex-publish.yml
      via: Existing hand parser and execution of extracted real step bodies
    - from: fake Mix version output and temporary Git refs
      to: real ref/tag step scripts
      via: Independently supplied project version, tag text and origin/main ancestry
---

<objective>
Harden release-workflow regression detection for the release group in the November 10 UAT audit, per INT-20261110-05. Deliver one contract-only change whose implementation source scope is exactly test/contract/hex_publish_test.exs. The workflow is the read-only authority and already contains the intended controls.

Purpose: prevent a passing contract suite from accepting the reproduced weakened release controls.
Output: idiomatic, minimal contract helpers and mutation checks, with local and hosted delivery evidence owned by the orchestrator.
</objective>

<execution_context>
@~/.codex/gsd-core/workflows/execute-plan.md
@~/.codex/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@CLAUDE.md
@.planning/VERIFICATION.md
@.planning/STATE.md
@.planning/audits/2026-11-10-UAT-AUDIT.md
@.planning/intent/sources/2026-11-10-05-release-contract-hardening.md
@docs/adr/0014-testing-strategy.md
@docs/adr/0017-ci-cd-layout.md
@docs/adr/0021-delivery-rules.md
@test/contract/hex_publish_test.exs
@.github/workflows/hex-publish.yml

Work in the isolated quick-task worktree on worktree-agent-quick-261110-nhq-release-contracts. Other agents own delivery and planning bookkeeping; preserve their changes. No roadmap or phase creation, source audit resumption, additional UAT group, owner UAT, dependency, parser framework or database change is part of this plan. Keep the oversized parent plans stopped, SEC-01 Pending with Phase 5, and Phase 2 gated. No release publication or message is authorized.

Discovery level 0: the existing hand parser, fake curl/Mix commands, local Git repositories and lane wrapper cover this work. Calibration factor 0.5 and confidence high derive from 19 project samples. Tasks share one file and execute in order in one wave.
</context>

<tasks>

<task type="tracer" tdd="true">
  <name>Task 1: Prove the ancestry contract under the runner shell and independent release fixtures</name>
  <files>test/contract/hex_publish_test.exs</files>
  <behavior>
    - A pipeline masking failed merge-base ancestry passes the old harness and is rejected under runner-equivalent execution.
    - Valid on-main tags with matching project version pass; off-main tags, missing origin/main and wrong checkout commit fail independently.
    - An on-main, matching-version tag with an invalid release shape fails the tag-pattern gate; a valid on-main tag with a different project version fails the version gate.
    - Removing the tag regex or version equality check makes the corresponding new contract expectation fail.
  </behavior>
  <action>Per INT-20261110-05, first add the pipeline, removed-pattern and removed-version mutations with nonempty replacement preconditions and demonstrate their missed-detection failures against the old validators before hardening them. Execute the extracted real ref/tag step bodies using bash -e step.sh, matching the unchanged workflow's unspecified Linux shell rather than explicit-bash pipefail semantics. Preserve the existing rejection of shell overrides. Make fake Mix's project version a separate fixture input instead of deriving it from TAG, and pass the intended version explicitly to existing successful ancestry fixtures. Add independent tag-shape and version-mismatch fixtures: place an invalid-shape Git tag on origin/main and supply its matching project version to isolate the regex; use a valid on-main tag with a different project version to isolate equality. Preserve the same-named branch, foreign checkout, local-only main and absent origin/main checks. Tag-shape/version failures can have no workflow error annotation; assert exit status and absent forbidden outputs without inventing diagnostics. Add targeted rule identities for these boundaries and retain exact single-rule mutation assertions wherever practical. Replace the email-shaped @identity value with a non-email local Git identity that still allows commits and commit-tree fixtures; do not reproduce the removed literal in comments. Use only temporary local refs and the existing fake Mix/curl seam. Capture fail-before/pass-after commands and findings for the orchestrator; do not edit the workflow to make tests pass.</action>
  <verify><automated>MIX_ENV=test bin/lane core test --warnings-as-errors test/contract/hex_publish_test.exs</automated></verify>
  <done>The unmodified workflow passes; pipeline masking, removed tag regex and removed version comparison are rejected by attributable tests. Fixture dimensions vary independently and no email-shaped identity remains in the source.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Detect secret leakage across top-level block order without rejecting benign syntax</name>
  <files>test/contract/hex_publish_test.exs</files>
  <behavior>
    - The existing four-space comment control still passes every validator.
    - Moving the legitimate root env block after jobs preserves all passing verdicts.
    - A root env secret added after jobs is rejected even when job and step contents are unchanged.
    - Existing job-env and step-env secret leakage mutations remain rejected by the secret-scope rule.
  </behavior>
  <action>Per INT-20261110-05, add the audited secret-env-after-jobs mutation and show that the old secret validator misses it. Extend the existing indentation-aware hand parser only as needed to inspect top-level blocks on either side of jobs, separating workflow-call secret declarations from root/job/step env scopes. Do not scan only the pre-jobs preamble or rely on a global secret occurrence count that conflates declarations and env consumers. Retain the two intended publish-step holders and the workflow-call declaration contract. Keep run-body text and nested env boundaries distinct so root-block parsing cannot absorb the finalize job or misclassify shell text. Add a passing control that moves the existing TAG/MIX_ENV root block after jobs, then a separate leaking version with the key added there. Assert each mutation actually changes the input and reaches its intended rule. Keep the existing comment control and run it through every new validator added by this plan. Reuse small targeted helpers; add no YAML dependency or generic parsing framework.</action>
  <verify><automated>MIX_ENV=test bin/lane core test --warnings-as-errors test/contract/hex_publish_test.exs</automated></verify>
  <done>The leak after jobs is rejected by secret_scope; valid root-env reordering and the existing comment remain accepted by all validators, with all prior secret-scope mutations intact.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Pin release execution, environment, tests and smoke controls with rejected mutations</name>
  <files>test/contract/hex_publish_test.exs</files>
  <behavior>
    - Finalize cannot run after failed prerequisites and smoke cannot be skipped by a job condition.
    - Publish requires hex-production; post-publish smoke consumes both build version and checksum on latest and floor lanes.
    - Build runs both release and prod_guard filtered tests and a pre-publish smoke of the unpacked package.
    - Each removed/weakened control is detected independently, without relying on unchanged step count.
  </behavior>
  <action>Per INT-20261110-05 and the release decisions in ADR 0017, add one non-vacuous mutation per audited hole: finalize job if always, smoke job if false, smoke command step if false, removed publish environment, removed smoke checksum argument, weakened release test filter, removed pre-publish smoke and removed floor lane. Preserve graph dependency checks while separately asserting the success-dependent job execution contract, unconditional checkout/setup/smoke command steps (while retaining the intended failure-only reporting step), the publish environment, exact intended release/prod_guard filter semantics, unpacked-package pre-publish smoke, post-publish version/checksum env wiring and invocation, and matrix lane wiring and membership. Use narrowly scoped parsed job/step fields; unrelated text must not satisfy a control. Model removal of the pre-publish smoke so its substantive rule is exercised independently of the existing step-count rule, for example replace its body with a harmless no-op while retaining the step. If also testing physical step removal, assert both expected findings explicitly instead of weakening either rule. Keep one attributable rule per other mutation. Preserve all existing recovery, checksum idempotency, checkout, cache, gate and interpolation checks. Add matching passing checks to the real workflow and both benign controls. Establish fail-before/pass-after for newly added checks against the old validator behavior. Format the modified test using the existing lane tooling and fix strict Credo findings without growing a test framework. Only the named test file may change as implementation; leave all workflow, lib and other UAT-group files byte-identical.</action>
  <verify>
    <automated>MIX_ENV=test bin/lane core test --warnings-as-errors test/contract/hex_publish_test.exs</automated>
    <automated>MIX_ENV=test bin/lane floor test --warnings-as-errors test/contract/hex_publish_test.exs</automated>
    <automated>bin/lane core mix format --check-formatted test/contract/hex_publish_test.exs</automated>
    <automated>bin/lane core mix credo --strict</automated>
    <automated>git diff --check origin/main</automated>
    <automated>git diff --exit-code origin/main -- .github lib</automated>
  </verify>
  <done>Every reproduced release mutation is rejected, every benign control passes, focused core/floor checks and format/strict Credo pass, and the protected workflow/library tree has no diff from origin/main. Evidence distinguishes old-validator misses, strengthened-validator detection and unchanged-workflow passes.</done>
</task>

</tasks>

<threat_model>
ASVS level 1; unresolved high or critical findings block delivery. No new external service integration, database schema or package installation is introduced.

| Trust boundary | Description |
|---|---|
| Workflow text to contract parser | Indentation, block order and job conditions can hide weakened controls. |
| Extracted shell to local process | Real step bodies run with fake commands and temporary Git state. |
| Fixture inputs to release verdict | Correlated tag/version/SHA fixtures can produce false confidence. |

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|---|---|---|---|---|---|
| T-261110-nhq-01 | Tampering | Shell and parser validators | high | mitigate | Tasks 1–3 reject reproduced mutations, use runner-equivalent shell semantics and accept benign syntax controls. |
| T-261110-nhq-02 | Information disclosure | Secret-scope traversal and Git identity | high | mitigate | Task 2 checks root env before and after jobs; Task 1 removes the email-shaped fixture identity. |
| T-261110-nhq-03 | Elevation of privilege | Executed workflow step bodies | high | mitigate | Keep existing fake curl/Mix commands first in PATH, execute only modeled ref/tag/recovery/publish snippets, use local temporary Git refs, and never execute real publication, messaging, installs, ASN.1 APIs or atom sinks. Inspect added executable paths during review. |
| T-261110-nhq-04 | Tampering | Tag/version/ancestry fixtures | high | mitigate | Task 1 independently controls each dimension and proves the removed-pattern/equality mutants against isolated failures. |
| T-261110-nhq-SC | Tampering | Package installation | high | mitigate | No dependency additions or install tasks; any proposed package change exceeds this plan and requires the package-legitimacy gate. |
</threat_model>

<verification>
Executor supplies focused red/green mutation evidence and passing core/floor contract, format, strict Credo and protected-tree checks. Check durations are observations, not new approval gates; do not claim a run passed before its exit result exists.

The orchestrator owns full delivery: run the current core CI alias with MIX_ENV=test bin/lane core mix ci, then the current floor compile/test sequence with FABLEBOOK_FLOOR=1: bin/lane floor mix compile --warnings-as-errors; bin/lane floor mix compile --no-optional-deps --warnings-as-errors --force; bin/lane floor test --warnings-as-errors --include prod_guard. Use the normal lane environments and preserve existing isolation. Review the final diff and accepted fixes before candidate publication, within the existing two-pass review cap. Run relevant Actions locally with act when feasible; the recorded act concurrency.queue parsing rejection occurs before jobs and does not authorize workflow edits or count as a passing receipt. The orchestrator obtains hosted candidate core, floor, dialyzer, security and ci-gate receipts and follows the existing all-checks merge rule. No owner UAT or real release run is needed. Record outcomes and measured CI timing in the orchestrator-owned summary without another receipt-only run.
</verification>

<source_audit>
| Source | Item | Coverage |
|---|---|---|
| GOAL | Quick task INT-20261110-05; harden only release contracts | Tasks 1–3; exact implementation file scope |
| REQ | No new roadmap requirement assignment in quick mode | Existing release obligations from ADR 0017 retained; no requirement-completion claim |
| RESEARCH | No quick research artifact requested | Existing audit supplies reproduced failures; Level 0 patterns reused |
| CONTEXT | Shell fidelity, pipeline masking, independent fixtures, identity | Task 1 |
| CONTEXT | Secret placement after jobs, benign ordering/comments | Task 2; all-validator controls retained in Task 3 |
| CONTEXT | Finalize/smoke conditions, environment, checksum, filters, pre-smoke, floor | Task 3 |
| CONTEXT | Contract separation, stops, no live side effects, local/hosted checks | Objective, tasks, threat model and orchestrator-owned verification |

Other UAT groups, parent source-audit plans, Phase 2 and SEC-01 completion are excluded by the explicit task boundary, not silently deferred from this implementation.
</source_audit>

<success_criteria>
The release hardening source diff touches only test/contract/hex_publish_test.exs. The original workflow and every benign control pass; all audited release-control weakenings fail for the intended reason. Local checks and hosted receipts are recorded with their actual outcomes. Historical safety stops and ownership remain intact.
</success_criteria>

<output>
Return execution evidence to the orchestrator for .planning/quick/261110-nhq-harden-the-release-workflow-contracts-fo/261110-nhq-SUMMARY.md. The orchestrator owns quick-task bookkeeping, audit debt dispositions, commits, publication and hosted receipts. The planner writes only this plan and any detector-required COVERAGE.md.
</output>
