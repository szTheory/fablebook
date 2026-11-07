---
status: complete
phase: 01-release-pipeline-ci-gate-and-guards
source: [01-01-SUMMARY.md, 01-02-SUMMARY.md, 01-03-SUMMARY.md, 01-04-SUMMARY.md, 01-05-SUMMARY.md, 01-VERIFICATION.md]
started: 2026-10-30T02:19:42Z
updated: 2026-11-07T08:29:25Z
intent: INT-20261029-08
---

# Phase 1 acceptance

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

### 11. Live CI timing and drift (historical sample)
expected: At least ten eligible first-attempt, non-release PR runs yield p50 <= 420 seconds and p95 <= 600 seconds; main requires exactly ci-gate.
result: pass
source: automated
coverage_id: "01-02:D3,D6; 01-04:D6; 01-05:D3,D4"
evidence: The real bin/ci_health against live read APIs reports n=41, p50 63 s, p95 122 s, exit 0. Issue writes intercepted locally. Full receipt: 01-LIVE-EVIDENCE.json. This proves live calculation, not a new published timing comment.
note: A later eligible sample exceeds the p95 limit; see test 14. The earlier passing sample is retained as historical evidence.

### 12. Existing owner sign-offs
expected: Already-approved amendment wording, publication and key rotation have durable provenance and require no repeat UAT.
result: pass
source: recorded-owner-approval
coverage_id: "01-05:D1"
evidence: INT-20261028-18 and INT-20261028-20 plus 01-05-SUMMARY.md owner checkpoints. Key scope/revocation remain prior owner attestations; independent dashboard verification is not claimed.

### 13. First Monday timing publication
expected: The Monday 05:23 UTC ci-health job succeeds and publishes numeric timing evidence to pinned issue #2 after at least ten eligible runs.
result: pass
source: automated
coverage_id: "01-02:D6; 01-04:D6; 01-05:D3,D4"
evidence: On 2026-11-02, scheduled run 41393964754 completed ci-health successfully and the bot published n=78, p50 77 s, p95 754 s to issue #2. It also opened quality-regression issue #37. Read-only checks; no issue writes or workflow dispatch.

### 14. Current CI timing acceptance
expected: The latest eligible seven-day sample is computed with the documented eligibility and percentile rules, compared with the 420/600-second objectives, and recorded for follow-up.
result: pass
source: automated
evidence: A live dry-run and the single authorized normal invocation on main revision 91e08e5d60361e9fd4c32167d2b376ab2237baab sampled 51 first-attempt, non-release PR runs (p50 543 s, p95 783 s). Both exceed the unchanged 420/600 s objectives and are visibly labeled non-blocking. The normal invocation published the matching report to pinned issue #2; run provenance and the no-issue-access dry-run audit are in 01-09-TIMING-CLOSURE.json.

### 15. Keep timing overages out of release-blocking quality regressions
expected: Timing overages remain visible against the 420/600-second objectives and are tracked separately from correctness/security regressions, so timing alone does not block release or phase closure.
result: pass
source: automated
coverage_id: "01-07/08/09:G-01-15"
evidence: Owner policy INT-20261106-01 is deployed and enforced by the strict contract in PR #53, separate from producer PR #52. The complete pre-migration history showed #37 contained only its original timing report and no comments; its original body is preserved. Issue #37 remains open under only `ci-performance`, while the pinned #2 issue has the current numeric report. Fresh live inventories and the actual main release-guard body show performance-only issues pass; synthetic genuine quality and mixed inventories block. Core and floor contracts pass. See 01-09-TIMING-CLOSURE.json.

### 16. Confirm Hex key scope and revocation
expected: The publish key is scoped to the `fablebook` package, and the broader bootstrap key is revoked.
result: pass
source: recorded-owner-approval
evidence: Reused the prior owner attestation recorded in test 12 and INT-20261028-18/20. The existing UAT explicitly says not to repeat these approvals absent a material change; this verification found no such change. Independent dashboard verification is not claimed.

### 17. Classify the SEC-02 probe and story-beam caveat
expected: Review the `unclassified` SEC-02 probe and preserve the story-beam caveat under Phase 2/10 without claiming universal adopter enforcement.
result: pass
source: owner-confirmation
reported: "Yes. Follow your recommendations."
evidence: Owner confirmed the SEC-02 probe stays unclassified/open, story-beam adopter checks remain owned by Phase 2 and Phase 10, and Phase 1 makes no universal adopter-enforcement claim.

### 18. Review inherited plan prohibitions
expected: Confirm which judgment-only prohibitions are accepted as resolved and whether any need a separately authorized follow-up, especially the D-21 test/support pairing boundary.
result: pass
source: owner-confirmation
reported: "What do you recommend? Let's follow that."
evidence: Owner confirmed the recommended disposition: keep Q35 open for separate planning and leave the D-21 table unchanged in Phase 1. No universal adopter-enforcement claim is added.

## Summary

total: 18
passed: 18
issues: 0
pending: 0
skipped: 0
blocked: 0
human_actions: 0

## Gaps

- None. G-01-15 is closed by the separated contract and producer PRs, verified issue migration, live report, and real release-guard controls in 01-09-TIMING-CLOSURE.json.

## Reconciliation and reuse

Historical SUMMARY coverage blocks were classified with the current CLI; `01-COVERAGE-CLASSIFICATION.json` records its errors (legacy `not-run` statuses, missing rationale or refs). They are not silently auto-passed from metadata. The explicit test-to-evidence mapping above replaces those classifications using fresh checks and recorded approvals while preserving immutable historical claims.

- Phase 1 CR-01 (literal atom dispatch) and WR-03 (code-loading entries): fixed in Phase 01.1, extended and verified in Phase 01.1.1. Reuse its 8/8 verification and the current passing regression suite.
- Phase 1 WR-02 (mix.exs scan): replaced by source AST coverage in Phase 01.1.1 SC6, including apply, alias and newline fixtures.
- Phase 1 WR-05 workflow provenance, WR-06 docs recovery and IN-04 key scope: fixed in Phase 01.1 PRs #10/#12/#13; current workflow seam tests pass. Q37 concerns the distinct deployment-policy residual.
- OPEN-QUESTIONS Q35, Q36 and Q37 remain existing owner decisions; Q37 is distinct from GitHub issue #37. This session neither resolves nor duplicates those prompts.
- Broader parser, unswept OTP and exclusion work is already owned by Phase 01.1.1.1, and complete SEC-01 properties by Phase 5. Do not replan those as new Phase 1 gaps.
- Package key scope/revocation and signed amendments have prior owner evidence. Do not repeat completed approvals without a material change.
- The original 01-VERIFICATION.md body remains historical. G-01-15 is closed by plans 01-07/08/09; canonical full Phase 01 verification is recorded separately below. This UAT does not imply milestone completion.

## Automated continuation

At the time of the earlier read-only recomputation, the 2026-11-02 scheduled `ci-health` job (run 41393964754) had published n=78 to issue #2 and opened issue #37; the Nov 6 scheduled run 42156185410 skipped `ci-health`, so that published sample was stale. The earlier n=50, p50 489 s and p95 783 s calculation and its no-write status remain historical. Plan 01-09 later published a fresh n=51, p50 543 s, p95 783 s report to #2 and moved #37 to `ci-performance`. No workflow dispatch occurred. The GSD debugger's producer/gate analysis remains in `.planning/debug/ci-timing-release-blocker.md`.

## CI efficiency review

The Nov 6 scheduled run's core and floor jobs ran in parallel. `mix ci` took 6m42s; the floor `mix test --warnings-as-errors --include prod_guard` command took 8m51s. The setup action took 8–10 seconds per lane, and dependency/build caching is already configured. No safe check removal or quality-preserving quick win is established from this run; keep existing gates and the 420/600-second performance objectives, and use per-step/queue evidence before proposing a targeted optimization. Timing-only overages remain non-blocking per INT-20261106-01; the producer, final contract, and issue migration are now deployed and tracked in 01-09-TIMING-CLOSURE.json.

## Verification receipt

- Local toolchain: Elixir 1.20.4 / OTP 29.1.1 via ASDF_ERLANG_VERSION override; repository CI pins OTP 29.1.2 and exact floor versions. No local exact-floor run claimed.
- Tested starting revision: 44d4f7bcefc41efa705dd88383312f58edf0d629, plus the new test and planning changes recorded in this change.
- Fresh full command: `ASDF_ERLANG_VERSION=29.1.1 mix ci` — 257 passed; format, unused lock check, forced compile, strict Credo, compile cycles and docs all passed.
- Mutation receipt: `01-CI-HEALTH-MUTATIONS.json`; mutations ran only in temporary files, never against tracked implementation.
- Live reads: `01-LIVE-EVIDENCE.json`; no issue comments, publication, secrets or baseline acceptance performed.
- Automation implementation CI (commit `72b9c820c36b97600a37e1fc4964d69f2101ff6f`): https://github.com/szTheory/fablebook/actions/runs/40991407462 — core, floor, dialyzer, security and ci-gate passed; nightly/ci-health skipped as designed for this PR. Draft PR: https://github.com/szTheory/fablebook/pull/22
- Existing green main CI: https://github.com/szTheory/fablebook/actions/runs/40987211785
- Historical green release: https://github.com/szTheory/fablebook/actions/runs/40803980465
- Historical intent red control: https://github.com/szTheory/fablebook/actions/runs/40802432347
- Baseline scheduled nightly run 40812122621: consumer smoke passed; overall CI failed at security's `mix hex.audit`. Current main security passed; the older failure is not a claim that Monday ci-health ran.

## CR-01 scoped reconciliation (2026-11-06T03:15:28Z)

Receipt: `01-06-ATOM-EVIDENCE.json`

This current, bounded recheck supplements the earlier UAT reconciliation while keeping its receipts and hosted observations historical. The atom-dispatch implementation shipped in [Phase 01.1 Plan 01](../01.1-close-phase-1-guard-gaps/01.1-01-SUMMARY.md) and was extended in [Phase 01.1.1 Plan 05](../01.1.1-close-the-eval-and-code-loading-ban-list/01.1.1-05-SUMMARY.md). The receipt captures the four tagged compiled fixtures and the source/name/MFA parity check on both exact pinned lanes. The exact checks are:

Runtime core: Elixir 1.20.4; OTP 29.1.2.
Runtime floor: Elixir 1.18.5; OTP 27.3.4.9.
Command core: `MIX_ENV=test bin/lane core test --warnings-as-errors --trace --no-color --only fixture:apply_to_atom.ex --only fixture:apply_list_existing_atom.ex --only fixture:function_capture_to_atom.ex --only fixture:erlang_apply_to_atom.ex test/contract/banned_calls_test.exs`
Command floor: `MIX_ENV=test bin/lane floor test --warnings-as-errors --trace --no-color --only fixture:apply_to_atom.ex --only fixture:apply_list_existing_atom.ex --only fixture:function_capture_to_atom.ex --only fixture:erlang_apply_to_atom.ex test/contract/banned_calls_test.exs`
Command core: `MIX_ENV=test bin/lane core test --warnings-as-errors --trace --no-color test/contract/banned_calls_test.exs:1915`
Command floor: `MIX_ENV=test bin/lane floor test --warnings-as-errors --trace --no-color test/contract/banned_calls_test.exs:1915`
Issue #37: state=open; observed_at=2026-11-06T03:16:27Z; source=https://github.com/szTheory/fablebook/issues/37; read-only; no issue writes or dispatch authorized.

CR-01: closed by scoped evidence; canonical Phase 1 re-verification remains open.
SEC-01: Pending; completion owner: Phase 5.
Phase 01.1.1.1 aggregate audit: open.
Phase 2 gate: open.
Story-beam caveat: open; owners: Phase 2 and Phase 10; no universal adopter enforcement claimed.
CI timing disposition was open when this CR-01 receipt was recorded; the owner decision and current non-blocking implementation are reconciled in the later Plan 01-09 section.

This reconciles only the CR-01 evidence as of 03:15Z. The later Plan 01-09 section closes G-01-15; canonical re-verification remains required.

## Plan 01-09 timing-policy reconciliation (2026-11-06T16:51:15Z)

Receipt: `01-09-TIMING-CLOSURE.json`

G-01-15 is closed on deployed main. PR #52 contains only the timing producer; PR #53 contains only the final strict contract and merged after #52. The current `bin/ci_health` digest matches the reviewed producer. Timing objectives remain 420 seconds p50 and 600 seconds p95, displayed as non-blocking follow-up.

Issue #37's full pre-migration record showed only the original timing report and no comments. Its original body remains intact; it is open under only `ci-performance`, with the timing rationale and deployed PR links in the migration comment. The one normal reporting invocation posted n=51, p50 543 seconds and p95 783 seconds to pinned issue #2, and posted a performance update to #37. The dry run made no issue calls. Current issue inventories contain #37 under `ci-performance` and no open `quality-regression` issue.

The actual main release-guard body passes with the saved live performance-only inventory and blocks synthetic genuine-quality and mixed inventories; its fake `gh` accepts only read-only list calls. Focused core and floor contracts pass on deployed main.

This scoped reconciliation closes only G-01-15. It does not complete canonical Phase 01 verification or change SEC-01 ownership (Phase 5), story-beam caveat ownership (Phases 2/10), aggregate guard audits, or the open Phase 2 gate. Canonical Phase 01 re-verification remains the next action.

## Canonical Phase 01 verification (2026-11-07)

The canonical report in `01-VERIFICATION.md` passed 9/9 roadmap-derived truths and 31/31 trackable decisions, with no gaps, regressions, or human checks. All 18 UAT checks pass. Phase 01 is complete; Phase 01.1 has not started.
