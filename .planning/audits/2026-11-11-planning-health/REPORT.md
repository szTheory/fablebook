# Planning lifecycle audit and repair

Authority: INT-20261111-03. This repairs project tracking before guard Phase 1; it does not implement that phase, close the guard aggregate or authorize product activation.

## Findings and remedies

| Finding | Observed evidence | Repair / recurrence proof |
|---|---|---|
| The migration verifier pinned live progress to the initial v0.2 / Phase 1 layout and all original unchecked states; it rejected legitimate later work | Original verify.py assertions; simulated later version/Phase 2/checked requirements | Freeze initial observations in INITIAL-RECEIPT.json; default verifier checks preserved history only. Its explicitly named `--initial-layout` option checks the one-time activation. Later-progress fixture passes default and correctly fails initial-only mode. |
| The SDK-owned state.json cache had been hand-authored, creating a second routing authority | STATE-VIEW-BEFORE.json; installed SDK state-contract publisher / lifecycle callers | Regenerate with bin/refresh_planning_state, never maintain the cached next command. Preflight compares version and phase identity/name projections; accepts the SDK's decorated display-name milestone. |
| Generic SDK routing can move backward after a later phase changes shared source | Real SDK fixture: canonical current Phase 2; initial Phase 1 verification passed; changed shared source made it stale and recommended_current became 01 | Versioned append-only delivery records distinguish real delivery from stale historical fingerprints. Preflight rejects discuss/plan/execute reentry to a delivered phase and derives an undelivered route. Tests prove a later milestone's Phase 1 remains distinct and valid. Old reports/fingerprints are never falsified. |
| The brand seed and a required verification-policy link still addressed old active phases | Legacy Phase 17 seed/ROADMAP breadcrumb; root verification policy old phases path | Map the seed to design-canon:4, update live breadcrumbs to future/archived owners, preserve source hashes and unapplied assets. Seed-target fixtures reject missing owners. |
| A root historical transition could route a new session back to legacy Phase 1 | TRANSITION-01.1.1.md's original routing section | Preserve it byte-for-byte in the v0.1 archive, with ADDITIONAL-ARCHIVE.json. Original 318-file manifest stays unchanged. |
| PROJECT still described 12 active phases, a single 35-phase cycle and waiting to reset after that cycle | Live PROJECT roadmap/process/decision text | Label historical family outlines, replace superseded packaging/routing with the already merged reset, and point current acceptance to its canonical owners. Do not re-run delivered bootstrap work. |
| Future prerequisites were readable prose only; there was no executable check against accidental cycles/missing owners | Future roadmap and exact old `Depends on` fields | Encode all 34 future phase dependencies, preserve typed legacy evidence references, reject cycles/unknown owners, require actual prior delivery receipts before implementation. Tests exercise same- and cross-milestone dependencies. |
| Bounded milestone completion and aggregate readiness could be confused | CARRY-FORWARD.md versus active GRC scope | Explicit gate/requirement-owner register: walking skeleton blocked on the full aggregate, SEC-01 Pending with controls-bundle:1. Own-scope closure requires complete acceptance and merged delivery; does not require closing an unrelated global gate. Missing aggregate/security owner or unrelated partial closure proof fails. |
| The dirty primary checkout could keep presenting stale local planning | Preserved old branch and unrelated working changes | Update only the previously added local recovery pointer to the current repair worktree. Preserve all earlier bytes and every unrelated change; no reset/stash/switch/cleanup. |

## Lifecycle enforcement

AGENTS.md requires the per-stage read-only preflight before state mutation. PLANNING-LIFECYCLE.md records canonical owners, each transition, delivery shape, carry-forward rules and pause/resume behavior. Tests are added to the existing planning suite on core/floor; no workflow, package dependency or production file changes. New guard files are added; existing planning/contract guards are unchanged. The audit does not install a global engine hook or claim to intercept arbitrary direct CLI use.

The selected guard scope must show its concrete contribution to the product blocker, exact membership/complement, inherited limits, bounded exit and subsequent owner decision. No automatic audit ladder or additional phase is created. Active Phase 1 has no CONTEXT or PLAN, remains unstarted, and correctly fails the plan-stage preflight until discussion selects scope.

## Inventory and historical integrity

The full planning corpus was inventoried and hashed locally, including every archived file. A structured scan checked 426 files / 241,439,655 bytes, all 50 JSON documents and ten compressed JSONL streams with zero parse or gzip-integrity errors (snapshot before final report additions). The original 318 archived files remain byte-identical. All 129 initial requirement checked states/citations remain bound to the immutable migration receipt; live backlog tests preserve original identities/citations while allowing new citations, requirements and actual progress. All original future phases retain exactly one owner. There is no cyclic dependency in the actual map.

Two old handoffs remain archived, not active resume instructions; there are no pending todo/workstream routes to promote. Stale/missing old verification stays historical. No broad milestone backfill, stale-report refresh or assumed shipped status was applied. Full local inventories and intermediate failures are in ignored _build/planning-health-20261111; compact provenance and before/after facts are retained here.

## Tool and adapter checks

Read-only installed SDK queries exercised discuss/plan/execute/verify/milestone-close/new-milestone initialization and current health/state projections. They find the active integer Phase 1 with zero plans/context, not a missing or executable old dotted phase. Sentinel-free isolation inspection reports orchestrator-worktree; explicit workflow.use_worktrees is false, compatible with the current runtime. No dispatch sentinel, global settings, package installation or runtime code is changed. The runtime warns that project model settings take precedence over global defaults; it is not evidence of a broken project route.

Stock health has zero errors and zero repairable items. Remaining diagnostics are preserved-worktree age warnings and W019 for CI-PERFORMANCE.md and VERIFICATION.md, both required project policies. No deletion or broad repair is justified to silence these. Moving the obsolete transition removes its root-file warning. Introducing workstreams is not silently supported: preflight requires an explicit scoped adaptation rather than checking the wrong root.

## Validation

- Planning suite, transition fixtures and actual-corpus checks on both pinned lanes; format, warnings-as-errors compilation and strict Credo. Final exact commands/results are recorded in VALIDATION.json.
- Standalone CLI: current status/discuss succeeds; unscoped plan and premature close fail. Unknown options fail with usage rather than pretending to check state.
- Default and initial-layout migration checks pass for the current actual activation; the later-progress negative/positive probe proves separation. Original archive and additional-transition hashes match.
- Actual SDK shared-source staleness probe is fixture-only; no audited API or product code runs. Its source result is preserved in ROUTING-PROBE.json; it is not a product verification pass.
- `act pull_request -W .github/workflows/ci.yml --dryrun` exits 1 before jobs because the installed parser rejects existing concurrency.queue. Local Actions are unavailable, not passed; no workflow workaround or retry. Required full hosted receipts remain the delivery gate.
- Inline review only, within the two-pass cap; no independent agent sign-off is claimed. See REVIEW.md.

## CI and remaining boundaries

PR #83's required candidate and post-merge main CI passed. Main run 43042576747 is independently bound to its merge; core/floor overlapped at 539s/648s with short setup. Comparing the prior candidate/main receipts establishes test-time variation, not a repeatable safe workflow shortcut. No extra receipt-only run, dependency, cache or concurrency change is justified.

This repair candidate must pass the full required hosted checks before owner merge. The guard aggregate and walking-skeleton stop remain open; SEC-01 and three carried UAT/observation groups retain their owners. Original brand assets remain uncommitted/unapplied in the preserved primary checkout. No release, production deployment, live safety test, scope acceptance or automatic implementation is authorized by this audit.

Next action: finish candidate CI and present its concrete merge decision. After landing, `$gsd-discuss-phase 1` selects a bounded source scope; the owner need not rerun a status command. This is recurrence protection for observed failure modes, not a guarantee against every possible future planning error.

## Final candidate receipt

[PR #84](https://github.com/szTheory/fablebook/pull/84) passed all required [hosted CI](https://github.com/szTheory/fablebook/actions/runs/43054428068) at the exact reviewed source head. GitHub reports clean and mergeable. Full core/floor, Dialyzer, security and ci-gate succeeded; scheduled-only jobs were correctly skipped. Source hashes still match local validation. Earlier pending-hosted statements are historical validation snapshots, superseded by this receipt. DELIVERY.json binds the PR, source/base, run event, jobs and exact guarded merge command. Owner merge is still pending; no approval is inferred from green CI.

Core/floor overlapped, taking 593s/689s; their main CI/test steps took 574s/666s and setup 10s/11s. Compare PR #83 candidate 571s/599s and main 539s/648s: test time remains the critical path, with short cached setup and run-to-run variation. No evidence supports a repeatable safe step removal, added cache/concurrency or dependency. Preserve timing objectives and all gates. No receipt-only CI rerun is warranted.

A separate read-only inventory of the preserved primary checkout covers 403 planning files / 250,254,257 bytes, 52 planning working changes, 65 JSON documents and 25 compressed JSONL streams; zero structured/gzip errors. Those local candidates remain preserved for provenance reconciliation before any future use. Only the prior agent-added recovery pointer was updated, preserving its pre-existing prefix. No primary branch/source/artifact or brand asset was reset, stashed, cleaned, moved or adopted.

The final verification/receipt is retained locally and carried on the next substantive push; the PR source stays at its green reviewed head. Agent work on this repair is ready for the owner's squash-merge decision. The active guard milestone/Phase 1 stays unstarted; global product blockers and all old safety stops remain. No user status command is needed. After landing, `$gsd-discuss-phase 1` scopes the next bounded increment.

## Approved merge and final main verification

INT-20261111-04 records the owner's approval. PR #84 was squash-merged as recorded in DELIVERY.json with the exact reviewed-head guard. Fresh origin/main's complete tree matches the green reviewed candidate. Required [main CI 43061493617](https://github.com/szTheory/fablebook/actions/runs/43061493617) passed at that merge: core, floor, security, Dialyzer and ci-gate all succeeded. Earlier pending-approval/main statements above are historical snapshots, superseded here.

Main core/floor overlapped at 598s/663s; their CI/test steps took 578s/638s with 11s setup each. Compared with this PR's candidate at 593s/689s and the prior reset receipts, test time still dominates and varies. No repeatable gate-preserving shortcut is established; keep quality gates and visible non-blocking timing objectives. No extra workflow/cache/concurrency/dependency change or receipt-only run is justified.

A supported fresh checkout based directly on the approved main merge is now the active recovery baseline: `.claude/worktrees/agent-planning-main-261111`, branch `worktree-agent-planning-main-261111`. Only verified receipt/approval bookkeeping was carried forward; reviewed source hashes remain identical. The primary checkout's previous agent-added recovery block points there, preserving all earlier bytes. Primary and old PR/recovery worktrees remain intact. No agent-isolation or new phase dispatch is claimed.

The merge/repair delivery is complete. Final proof and owner approval are saved locally for the next substantive push, and the closed PR links both green CI runs for remote reconciliation. There is no remaining merge approval or status-only task. The owner may run `$gsd-discuss-phase 1` to select the next bounded guard scope; Phase 1 remains unstarted, the full guard aggregate stays open and the product gate stays blocked.
