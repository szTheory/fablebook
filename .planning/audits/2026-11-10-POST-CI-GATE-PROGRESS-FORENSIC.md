---
status: warnings-reconciled
source: automated
audited_at: 2026-11-11T03:05:00+00:00
source_head: 39d7dc7cb7e50785e45a9c3aedcd6465ba64abb8
scope: progress-report-only
current_phase: 01.1.1.18
forensic_checks: 7
warning_checks: 2
current_milestone_uat_groups: 4
archived_uat_items: 0
---

# Post-CI-gate progress and forensic audit

This is a new snapshot after PR #81 and its main CI completed. It supersedes the next-action recommendation and five-group count in the prior [post-release report](2026-11-10-POST-RELEASE-PROGRESS-FORENSIC.md), without changing that historical report. The installed forensic workflow defines seven checks despite the skill description saying six; all seven were performed. No implementation, safety stop, phase, configuration, old verification digest or recovery checkout was changed.

## Progress and recent work

- Phase 01.1.1.18 remains complete: three plans, three summaries and a passed current verification fingerprint. Its source audit remains bounded; parent aggregate and SEC-01 are not closed.
- Release-workflow contract hardening is merged in [PR #80](https://github.com/szTheory/fablebook/pull/80); its candidate and post-merge main checks passed.
- CI-gate predicate contract hardening is merged in [PR #81](https://github.com/szTheory/fablebook/pull/81). The required [candidate run](https://github.com/szTheory/fablebook/actions/runs/42944194233) and [main run](https://github.com/szTheory/fablebook/actions/runs/42947113449) passed. The live main branch still points to that tested merge. Both contract-hardening UAT groups are resolved; no new production failure is demonstrated.
- Logistify's [Phase 17 intake](../references/logistify-brand-intake.md), exact owner excerpts, dormant seed and PROJECT pointer are on main. The three captured source hashes still match BRAND.md, brand.json and tokens.json in the preserved primary checkout. Original source files remain untracked there; no assets or brand canon were applied. The future Phase 17 task must still re-read the original sources and map their shapes deliberately.

## Interpreting the progress counters

The CLI displays 40/45 phase plans with summaries (89%). This is an artifact ratio, not product readiness. Four missing summaries belong to the stopped parent decomposition, and the fifth is the saved-settings Plan 04 summary absent from this checkout. A reconstructed copy exists in the preserved primary checkout and is not automatically adopted. The two quick tasks live outside these phase-plan counters. File modification times in a newly created worktree can surface old summaries as recent; merged delivery records and STATE are the recency authority.

STATE selects completed Phase 01.1.1.18, but the init/roadmap query computes Phase 01/1 as current because its old verification fingerprint is stale. The generic resume scan would route to the parent with five plans and one summary. ROADMAP explicitly keeps that decomposition stopped: its source/context-size stop is unresolved and the old tasks are superseded by bounded siblings. Do not execute that route, use --force, or start Phase 2 based on these counters.

Nine historical verification reports are stale against changed shared guard/source files. Three planned directories have no verification report: the open parent, saved-settings replay and debugger installed-wide acceptance. These are real evidence/bookkeeping gaps, not authority to replay already merged plans or rewrite hashes to appear green. The current selected sibling's report remains passed. Reconcile these records from their authoritative receipts in a separate bounded documentation scope.

## Seven forensic checks

| Check | Result | Evidence and next action |
|---|---|---|
| 1. Selected STATE versus artifacts | Pass, routing qualified above | Completed Phase 01.1.1.18 has 3/3 summaries and current passed verification. Do not use global stale counters as product completion or execution authority. |
| 2. Handoff files | Warning, preserve | Two historical .continue-here.md files remain under the parent and creator-audit directories. They retain stops and stale continuation instructions; the creator handoff still calls merged PR #38 pending. Read and reconcile provenance before historical resumption; do not delete or follow stale instructions automatically. |
| 3. Deferred scope drift | Pass for the defined scan | CONTEXT, DISCUSSION-LOG, BUG-BRIEF, VERIFICATION, SUMMARY and HANDOFF phase files were scanned case-insensitively for the four defer-pattern families. No absent-phase reference was found. This limited textual check is not aggregate scope closure. |
| 4. Planning memory pending work | Pass for the literal checkpoint | No MEMORY.md or memory/*.md files exist. The new references/seed intake is separately accounted for as future Phase 17 input, not an operational blocker or implemented canon. |
| 5. Blocking operational todos | Pass | No pending operational todo files exist. WINDOWS has zero open entries and one retained intentional-placeholder waiver. |
| 6. Uncommitted code | Pass in active checkout | The active task checkout was clean at audit start. The primary checkout deliberately retains planning work, modified AGENTS.md and untracked planning/brand documentation; no tracked production-source modification was found there. Preserve it; no reset, stash, cleanup or unrelated commit. |
| 7. Unresolved deferred items | Warning, four groups | The canonical audit returns four current-milestone groups, zero archived debt and zero parse-gap files. Their existing ownership remains. |

Verdict: five checks pass and two warn. The warnings and global routing discrepancies must be respected; they do not reopen the green merged deliveries. No app/test foreground activation, build, whole-suite rerun, package install or hosted run was needed for this progress audit.

## Four remaining UAT groups

| Work | Current owner and consequence |
|---|---|
| Floor-version check reports a pass when it does not run | Independent test-only reporting correction. Preserve actual pinned floor assertions and allowed-filter policy; an unset core optional check must not be counted as floor evidence. |
| Smoke-consumer route guard lacks a positive host-route control | Existing Phase 2 producer boundary. Phase 2 remains gated. |
| Adopter-wide story/canon exclusion depends on fixture layout | Existing Phase 2/10 host/installer work; no generated-adopter proof is claimed. |
| Historical Hex registry incident | Existing scheduled security observation. Current candidate/main security passed; do not weaken failures or fabricate a fresh incident. |

The dependency-budget test and smoke-consumer source digests still match the prior [UAT audit](2026-11-10-UAT-AUDIT.md), so its reporting/producer-boundary evidence is reusable. ci_shape_test.exs now has the reviewed hardened digest and is not an open finding.

One debug file remains labelled diagnosed, but its timing-policy finding is historical and closed in canonical Phase 1 UAT. The last task's unrelated local saved-settings timeout remains honestly recorded: its isolated unchanged-boundary retest and both required hosted full suites passed. It is not treated as a new unresolved production failure or silently erased.

## Recommendation and boundary

Select the floor-version result-reporting correction next, as a separate contract/test-only quick task. It is the remaining independently automatable UAT gap and does not require resuming the stopped source audit or gated Phase 2. Determine concrete test/helper changes from current code during that task; retain workflow, lib, dependency and lockfile bytes, real pinned floor checks, and required hosted gates. Do not start implementation in this progress command.

Next command: `$gsd-quick "Correct the floor-version check's not-run reporting for the UAT audit finding; keep workflow and lib files unchanged"` — select that bounded reporting fix. No owner action is needed for the completed merges; the owner chooses whether to start this next task. Parent source-size stops remain, SEC-01 stays Pending with Phase 5, and Phase 2 remains gated.

## Evidence commands

Structured CLI reads: init.progress --forensic, roadmap.analyze, state-snapshot, progress.bar, audit-uat, windows status and verification.status for Phase 01.1.1.18. Read-only Git status distinguishes the active and preserved primary checkouts. Read-only GitHub metadata confirms PR #81 merged, its post-merge run succeeded and current main matches its merge. Source hashes were recomputed for the three brand files and relevant unchanged deferred-boundary files. Raw JSON is retained in ignored _build/quick-261110-she/progress-*.json; the material findings are preserved here.
