---
status: partial
phase: 01-release-pipeline-ci-gate-and-guards
source: [01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md, 01-04-SUMMARY.md, 01-05-SUMMARY.md]
started: 2026-10-30T02:19:42Z
updated: 2026-10-30T02:22:42.236Z
mode: automated
intent: INT-20261029-08
---

# Phase 1 automated acceptance

## Current Test

[testing complete]

## Tests

### 1. Cold-start host integration
expected: A clean dev host mounts /dev/fablebook; a clean prod host has a real homepage but no Fablebook route or story beam; an unguarded prod mount fails once with the canonical error.
result: pass
source: automated
coverage_id: "01-01:D1"
evidence: `test/contract/prod_guard_test.exs` cleans dev/prod before compiling and tests both directions. Fresh `ASDF_ERLANG_VERSION=29.1.1 mix ci`: 257 passed.

### 2. Prod-guard message contract
expected: The CompileError first line matches the committed snapshot and README Troubleshooting heading.
result: pass
source: automated
coverage_id: "01-01:D3"
evidence: `test/contract/prod_guard_message_test.exs` in the fresh 257-test CI alias.

### 3. Floor compatibility
expected: The floor lock uses Phoenix 1.8.9 / LiveView 1.2.9 and the prod guard passes on the exact CI floor.
result: pass
source: automated
coverage_id: "01-01:D2; 01-03:D3"
evidence: Existing unchanged guards/locks passed the floor job in main CI run 40987211785. New CI-health coverage is validated by this change's PR CI separately; local OTP 29 is not claimed as the floor.

### 4. Package and dependency boundaries
expected: Only allowlisted package files and runtime dependencies ship, with no banned prod dependency or private data.
result: pass
source: automated
coverage_id: "01-01:D4; 01-03:D3,D4"
evidence: `test/contract/{tarball,dependency_budget}_test.exs`, release tag tests and the fresh CI alias.

### 5. Eval, atom, source and style guards
expected: Banned direct/literal-dispatch calls fail the compiled/source checks; missing debug info fails closed; lib modules and mix.exs are clean; inline styles fail.
result: pass
source: automated
coverage_id: "01-03:D1,D2,D5"
evidence: `banned_calls_test.exs`, `tier_sweep_test.exs`, `style_attr_test.exs` and Credo pass. Prior CR-01 and WR-03 closed by 01.1 and 01.1.1 (PRs #9–#20). Full parser/installed-OTP/exclusion audit remains explicitly owned by 01.1.1.1; SEC-01 completion remains Phase 5.

### 6. Intent integrity and real git seam
expected: Intent sources are add-only, citations resolve, REQ lines cite intent/ADRs, unresolved CI diff bases fail closed and contract/implementation pairing is enforced.
result: pass
source: automated
coverage_id: "01-04:D1,D2,D3; 01-05:D1,D2"
evidence: `test/planning/{intent,contract_rule}_test.exs` in mix ci; historical red CI run 40802432347 remains failure. Reuse owner approvals in INT-20261028-18/20; no renewed decision required.

### 7. CI inventory, gate and wiring
expected: Three pinned workflows obey caps; core/floor test wiring and the single required ci-gate are intact.
result: pass
source: automated
coverage_id: "01-02:D1,D3,D4; 01-04:D4,D5"
evidence: `test/contract/ci_shape_test.exs` mutations pass. Live required checks equal ["ci-gate"]. Existing main run 40987211785 passes core, floor, security, dialyzer and ci-gate.

### 8. Published release and consumer smoke
expected: Hex 0.1.0 has the recorded checksum and docs; the GitHub release is public with an SBOM; release smoke passed on both lanes.
result: pass
source: automated
coverage_id: "01-02:D2,D5; 01-05:D5"
evidence: Live Hex checksum 9fd4c3c31d7e4ded6e40d2ab4548a4de4a78d34d51e2824a1b580ac6e4ffe834; HexDocs HTTP 200. Historical release run 40803980465 passed build, publish, both smoke lanes and finalize; release asset fablebook-0.1.0.cdx.json exists. No republish needed.

### 9. Release recovery and provenance seam
expected: Only a built main commit can publish; checksum mismatch fails; docs-only recovery converges and publish secrets remain scoped.
result: pass
source: automated
coverage_id: "01-02:D5; 01-05:D5"
evidence: `test/contract/hex_publish_test.exs` executes real workflow step bodies in temporary repos with fake external commands. Fresh suite passes. Historical WR-05 workflow half and WR-06 closed in PRs #10/#12/#13; settings question Q37 remains separate. No live publish or recovery was performed.

### 10. CI-health regression contract
expected: Insufficient samples stay not-run; exact budgets pass; p50/p95 breaches and ruleset drift report regressions; failed API reads fail without false evidence.
result: pass
source: automated
coverage_id: "01-02:D6; 01-04:D6; 01-05:D3,D4"
evidence: New `test/contract/ci_health_test.exs`: 13 passed through the real bin/ci_health. Three deliberate script mutations fail 3, 1 and 11 tests respectively. Existing mix ci and floor lanes discover the new test without workflow changes.

### 11. Live CI timing and drift
expected: At least ten eligible first-attempt, non-release PR runs yield p50 <= 420 seconds and p95 <= 600 seconds; main requires exactly ci-gate.
result: pass
source: automated
coverage_id: "01-02:D3,D6; 01-04:D6; 01-05:D3,D4"
evidence: The real bin/ci_health against live read APIs reports n=41, p50 63 s, p95 122 s, exit 0. Issue writes intercepted locally. Full receipt: 01-LIVE-EVIDENCE.json. This proves live calculation, not a new published timing comment.

### 12. Existing owner sign-offs
expected: Already-approved amendment wording, publication and key rotation have durable provenance and require no repeat UAT.
result: pass
source: recorded-owner-approval
coverage_id: "01-05:D1"
evidence: INT-20261028-18 and INT-20261028-20 plus 01-05-SUMMARY.md owner checkpoints. Key scope/revocation remain prior owner attestations; independent dashboard verification is not claimed.

### 13. First Monday timing publication
expected: The Monday 05:23 UTC ci-health job succeeds and publishes numeric timing evidence to pinned issue #2 after at least ten eligible runs.
result: blocked
source: automated
coverage_id: "01-02:D6; 01-04:D6; 01-05:D3,D4"
blocked_by: third-party
reason: The first Monday trigger is 2026-11-02T05:23:00Z. No Monday run exists yet; the latest issue comment is the historical n=2 dispatch. The existing scheduled ci-health job owns publication, drift checks and regression reporting. This is pending external observation, not a request for human testing.

## Summary

total: 13
passed: 12
issues: 0
pending: 0
skipped: 0
blocked: 1
human_actions: 0

## Gaps

None found in these acceptance checks. Historical atom/source gaps have merged fixes; use the reconciliation below instead of creating duplicate gap plans.

## Reconciliation and reuse

Historical SUMMARY coverage blocks were classified with the current CLI; `01-COVERAGE-CLASSIFICATION.json` records its errors (legacy `not-run` statuses, missing rationale or refs). They are not silently auto-passed from metadata. The explicit test-to-evidence mapping above replaces those classifications using fresh checks and recorded approvals while preserving immutable historical claims.

- Phase 1 CR-01 (literal atom dispatch) and WR-03 (code-loading entries): fixed in Phase 01.1, extended and verified in Phase 01.1.1. Reuse its 8/8 verification and the current passing regression suite.
- Phase 1 WR-02 (mix.exs scan): replaced by source AST coverage in Phase 01.1.1 SC6, including apply, alias and newline fixtures.
- Phase 1 WR-05 workflow provenance, WR-06 docs recovery and IN-04 key scope: fixed in Phase 01.1 PRs #10/#12/#13; current workflow seam tests pass. Q37 concerns the distinct deployment-policy residual.
- Q35, Q36 and Q37 remain existing owner decisions in intent/OPEN-QUESTIONS.md. This session neither resolves them nor duplicates their prompts.
- Broader parser, unswept OTP and exclusion work is already owned by Phase 01.1.1.1, and complete SEC-01 properties by Phase 5. Do not replan those as new Phase 1 gaps.
- Package key scope/revocation and signed amendments have prior owner evidence. Do not repeat completed approvals without a material change.
- Old 01-VERIFICATION.md is the initial execution report, with historical gaps. This UAT does not silently promote or rewrite that report; canonical re-verification remains a separate GSD gate. The current tests do not imply the whole phase or milestone is complete.

## Automated continuation

The existing `.github/workflows/ci.yml` Monday `ci-health` job runs `bin/ci_health`, then the CI shape test, and files regressions on failure. After 2026-11-02T05:23:00Z, an agent can read scheduled run jobs and issue #2 comments, correlate the comment's run URL with the successful ci-health job, and resolve test 13. Until then retain `partial`; do not ask the owner to click through CI or count runs. The new CI-health tests run on each PR in the existing core/floor lanes.

## Verification receipt

- Local toolchain: Elixir 1.20.4 / OTP 29.1.1 via ASDF_ERLANG_VERSION override; repository CI pins OTP 29.1.2 and exact floor versions. No local exact-floor run claimed.
- Tested starting revision: 44d4f7bcefc41efa705dd88383312f58edf0d629, plus the new test and planning changes recorded in this change.
- Fresh full command: `ASDF_ERLANG_VERSION=29.1.1 mix ci` — 257 passed; format, unused lock check, forced compile, strict Credo, compile cycles and docs all passed.
- Mutation receipt: `01-CI-HEALTH-MUTATIONS.json`; mutations ran only in temporary files, never against tracked implementation.
- Live reads: `01-LIVE-EVIDENCE.json`; no issue comments, publication, secrets or baseline acceptance performed.
- Existing green main CI: https://github.com/szTheory/fablebook/actions/runs/40987211785
- Historical green release: https://github.com/szTheory/fablebook/actions/runs/40803980465
- Historical intent red control: https://github.com/szTheory/fablebook/actions/runs/40802432347
- Baseline scheduled nightly run 40812122621: consumer smoke passed; overall CI failed at security's `mix hex.audit`. Current main security passed; the older failure is not a claim that Monday ci-health ran.
