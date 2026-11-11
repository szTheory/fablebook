# Milestone and phase numbering reset

**Status:** Reset merged in PR #83, with required candidate and post-merge main CI passed. Guard Phase 1 remains unstarted. Earlier validation/approval statements below are historical snapshots.

The owner requested fail-forward recovery and smaller milestones (INT-20261111-01). The old reset resolution waited for the whole product roadmap to finish. Nested inserted phases and stale fingerprints then kept the generic router pointing at old, deliberately stopped work. The primary checkout also remains on an old branch with uncommitted work. A status command cannot fix those conditions.

## Concrete result

- Archive the formerly unversioned cycle as v0.1 with status SUPERSEDED — INCOMPLETE. Do not run milestone.complete, which would label this whole cycle shipped.
- Use supported state.milestone-switch and phases.clear --confirm --archive-version v0.1. Every moved file is bound by ARCHIVE-MANIFEST.json; original ROADMAP, REQUIREMENTS and STATE are preserved byte-for-byte. No force flag or deletion is used.
- Propose v0.2 Guard coverage recovery with one ordinary Phase 1 delivering the next independently sized guard increment. Exact membership and effort must be settled before any PLAN. No old halted plan is resumed.
- Preserve the 34 future product phases in twelve future milestone groups, each starting at Phase 1. references/PRODUCT-REQUIREMENTS.md preserves every original ID, citation and status; PHASE-MAP.json maps each old integer phase 2–35 to one future owner. Future versions are assigned on activation.
- Keep the full guard aggregate, source limits, installed-wide remainder, collision stops, future SEC-01 property owner, walking-skeleton start gate and three UAT groups in CARRY-FORWARD.md. Completing one increment does not remove those gates.
- Update only physical read paths in tier_sweep_test.exs and debugger_settings.ex. Stored source IDs, ownership, provenance/review strings, snapshot bytes and assertions remain unchanged. No lib, workflow, dependency, lockfile or production behavior change is included.
- Record the owner's correction in AGENTS.md: integer phases, bounded milestones, and concrete next actions instead of repeated status commands.

## Preserved working copies

The migration uses a fresh worktree from the PR #82 main merge and carries three verified planning-only completion receipts. Existing primary/recovery source, artifacts and brand files remain unchanged; the only primary-checkout addition is the local AGENTS recovery pointer described below. The supported worktree helper required an initialized manifest before creation; its first read-only refusal made no worktree, and initialization/creation then succeeded. No harness agent isolation or independent subagent review is claimed.

Do not switch/reset/stash/clean the dirty primary checkout as a shortcut. A new session must reconcile its branch against merged main and use the current reviewed checkout. Adoption of the migration on main is a separate owner merge boundary.

## Verification

Read-only structural proof: `python3 .planning/migrations/2026-11-11-milestone-reset/verify.py`. It verifies archive bytes and captured original requirement IDs/statuses/citations and initial future addresses, independently of later live progress. `--initial-layout` additionally checks the one-time v0.2 / Phase 1 activation; do not use that option as an ongoing gate. Live ownership/routing uses `bin/planning_health`. Focused core/floor evidence consumers, format/compile/Credo/planning checks and required hosted CI are recorded below as they finish. Run these before presenting the candidate as ready. A source-sized implementation plan, product readiness, whole-audit completion and archived stale-report refresh are not claimed.

## Next action

After owner approval and migration landing: $gsd-discuss-phase 1 — select the exact source-connected next slice and check inherited size/effort limits before planning. No phase implementation starts automatically.

## Local primary-checkout recovery pointer

An additive local AGENTS.md pointer directs future sessions away from the preserved old branch and toward the current reviewed planning checkout. Its pre-existing bytes are unchanged, verified by a prefix check and before/after hashes in ignored _build/milestone-reset-20261111/primary-agent-pointer.json. It is not committed with unrelated primary changes. No primary source, artifact, brand file or Git branch is reset, stashed, switched, removed or overwritten. The generic durable numbering/action preference is included in this PR's AGENTS.md.

## Local validation receipt

All commands used pinned local lanes, locked caches and background/piped execution. Native Mix operations ran sequentially. Raw receipts are in ignored _build/milestone-reset-20261111/.

| Check | Result |
|---|---|
| `python3 .planning/migrations/2026-11-11-milestone-reset/verify.py` | 318 archived files byte-identical; all 129 original requirement checked states/citations preserved; every legacy future phase 2–35 mapped exactly once; new local numbering contiguous per milestone; active v0.2 / Phase 1 only. |
| Focused core evidence consumers with warnings-as-errors | 6 passed, 88 excluded; 158.1s. `core-evidence-consumers-final.log`. |
| Same focused consumers on floor with warnings-as-errors | 6 passed, 88 excluded; 174.1s. `floor-evidence-consumers.log`. |
| Planning intent / contract-rule checks | 32 passed; `planning-final.log`. |
| Format, both pinned compile checks with warnings-as-errors, strict Credo | Passed; no Credo issues. `format-final.log`, `compile-core.log`, `compile-floor.log`, `credo.log`. |
| OpenGSD progress / roadmap | One active phase; new milestone v0.2; next phase 1. No old unmatched parent plans in the active route. |
| Health | Zero errors and zero undeclared-phase warnings. Seven preserved-worktree warnings and three pre-existing noncanonical-file warnings remain; do not delete history to remove them. `health-final.json`. |
| Cross-phase UAT | Three archived groups remain visible, zero current parse gaps; their future owners and gates are explicit in CARRY-FORWARD.md. |
| `act pull_request -W .github/workflows/ci.yml --dryrun` | Existing concurrency.queue parser rejection, exit 1, before jobs. Unavailable local Actions validation, not a pass. No workflow change or retry. |
| Protected source diff | lib, workflows, bin producers, dependencies, lockfiles and Credo configuration unchanged. |

The first focused source run failed in setup because moved physical paths differed from recorded logical authority. Stored metadata stayed unchanged; the expected historical-reference conversion fixed it. That invalid run is retained separately, not relabelled green. The first planning run caught noncanonical colon syntax in the new requirements; the new text was corrected and the unchanged planning guard then passed. Full hosted core/floor/Dialyzer/security/ci-gate remain required for the final candidate; no native whole-suite repeat is needed for this physical-read-path migration after the focused integration consumers pass.

[Inline review](REVIEW.md) covers the complete source delta, preserved metadata and requirements/gates. Required hosted checks and owner merge remain pending. No new implementation phase starts automatically.

## Final hosted candidate receipt

[PR #83](https://github.com/szTheory/fablebook/pull/83), reviewed head `431747bca47ab59a5ab80427a990d0a56da8a88e`, passed all required [hosted CI](https://github.com/szTheory/fablebook/actions/runs/43040038122). Full core/floor, Dialyzer, security and ci-gate succeeded; scheduled-only nightly/ci-health were correctly skipped. Read-only run metadata confirms the pull_request event and exact reviewed head. GitHub reports clean and mergeable. The preceding pending-hosted statements are local-validation snapshots, superseded by this receipt.

| Job | Result | Duration | Receipt |
|---|---|---|---|
| dialyzer | success | 23s | [job](https://github.com/szTheory/fablebook/actions/runs/43040038122/job/130589056205) |
| floor | success | 599s | [job](https://github.com/szTheory/fablebook/actions/runs/43040038122/job/130589056520) |
| core | success | 571s | [job](https://github.com/szTheory/fablebook/actions/runs/43040038122/job/130589056689) |
| security | success | 38s | [job](https://github.com/szTheory/fablebook/actions/runs/43040038122/job/130589056775) |
| ci-gate | success | 4s | [job](https://github.com/szTheory/fablebook/actions/runs/43040038122/job/130594743401) |

Core and floor overlapped. Core's CI step took 553s and floor tests 575s, with setup 12s/10s. Preceding floor-reporting candidate totals were 553s/599s and its main totals 442s/654s; this candidate is 571s/599s. Current history still shows test-time variation and short cached setup. No repeatable quality-preserving workflow shortcut is established; preserve gates and non-blocking timing objectives. No extra run, cache, concurrency, dependency or workflow change is warranted.

The archived bytes and original requirement statuses/citations still match the read-only verifier after all edits. No source changed after local validation. The full hosted checks establish compatibility of the evidence relocation under the existing gates. Current progress has one active ordinary phase; health has zero errors/undeclared-phase warnings, retaining only preserved-worktree and pre-existing-file warnings. Three archived UAT groups remain visible and explicitly owned in CARRY-FORWARD.md.

Migration implementation/verification is complete in the candidate. Owner merge is the activation boundary for the new roadmap; the guard phase itself is not started, source membership/effort is not invented and no original gate is removed. Final receipt-only updates are committed locally for the next substantive push, avoiding an identical CI run. The live green receipt is linked from the PR.

Next command after owner approval: `gh pr merge 83 --squash --match-head-commit 431747bca47ab59a5ab80427a990d0a56da8a88e` — activate the reviewed planning reset. After landing, `$gsd-discuss-phase 1` scopes the next bounded guard increment. Do not send the owner back through another status-only loop.

## Approved activation

Owner approval is recorded in INT-20261111-02. [PR #83](https://github.com/szTheory/fablebook/pull/83) was squash-merged as `42eed41986476e40c2d291685df7f1b245b61ca0`, enforcing expected head `431747bca47ab59a5ab80427a990d0a56da8a88e`. All required candidate checks passed. Fresh main matches the reviewed source, active roadmap/requirements and instructions. Earlier pending-owner statements are historical snapshots.

v0.2 and its ordinary Phase 1 are now the active planning structure. The phase is unstarted; exact source scope/estimates have not been selected. The owner then requested a full planning health/repair audit to prevent state loss and repeated audit loops. That repair is the current authorized work; no guard implementation starts. The separate [main CI](https://github.com/szTheory/fablebook/actions/runs/43042576747) is in progress, not yet a passing receipt.

## Post-merge main receipt and lifecycle follow-up

Read-only GitHub metadata confirms [main CI 43042576747](https://github.com/szTheory/fablebook/actions/runs/43042576747) succeeded at the PR #83 merge. Required jobs: core 539s, floor 648s, Dialyzer 23s, security 34s and ci-gate 2s. Core/floor overlapped; setup remained short and test time dominates. Compared with the candidate and preceding run, no repeatable gate-preserving shortcut is established. No extra workflow, dependency, cache or concurrency change is justified.

The owner-requested planning health repair is the current task, ahead of Phase 1 discussion. See ../../audits/2026-11-11-planning-health/ and ../../references/PLANNING-LIFECYCLE.md. INITIAL-RECEIPT.json freezes migration observations; default verification no longer freezes mutable future product progress. Historical archive bytes and incomplete status remain unchanged.
