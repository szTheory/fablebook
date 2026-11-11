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
