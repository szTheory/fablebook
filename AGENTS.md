# Agent instructions

Read and follow [CLAUDE.md](CLAUDE.md) for project intent, architecture, and workflow rules.

The owner has granted standing authorization across Fablebook OpenGSD phases, plans, and milestones to run relevant GitHub Actions locally with `act` when feasible, then push reviewed/tested phase candidates and open or update pull requests to obtain hosted CI receipts without repeated permission requests. Local `act` results do not replace required hosted receipts. Follow existing branch protection and phase delivery gates; this authorization does not cover unrelated releases or production deployments. See intent record `INT-20261109-01`.

## Communication

- Avoid unexplained OpenGSD jargon; describe concrete work, inputs, coverage and estimates.

## Phase recovery

Before declaring a requested phase missing, inspect the checkout branch and fetch the current default branch; reconcile merged planning PRs and preserved worktrees. A stale local checkout is not evidence that an approved phase does not exist. Preserve unrelated working changes when recovering its plan.

## Milestone and phase numbering

Use one project-wide sequence of ordinary integer phase numbers across active-era milestones. v0.2 Phase 1 is the delivered anchor and v0.3 is Phase 2; assign later numbers after the highest delivered phase when each milestone activates. Do not add nested decimal phases or reset numbering without new owner intent. Keep active milestones bounded; preserve the wider product roadmap separately. Historical IDs and unfinished acceptance remain traceable through the archive and carry-forward register. INT-20261112-04 supersedes only the numbering clause of INT-20261111-01.

A progress check is a diagnostic, not the default next task. Recommend the concrete next action when known, preserve required milestone/phase approval boundaries, and continue routine authorized work without asking the owner to rerun status commands. Before reporting status, reconcile the checkout with merged main and the latest saved receipts; preserve dirty historical checkouts.

## Planning lifecycle preflight

Before any planning-state mutation, run `bin/planning_health --stage <stage>` in the current reviewed checkout, adding `--phase N` for a phase operation. Stages are `discuss`, `plan`, `execute`, `verify`, `ship`, `milestone-close` and `milestone-start`; `status` is read-only diagnosis. Resolve errors before proceeding. These project checks supplement the core workflow's freshness, review, security, CI and approval gates. The recurring planning tests run in existing CI. This is a project entry rule, not an installed engine hook; direct CLI calls can bypass it. Workstreams require an explicit scoped adaptation before use.

Treat STATE.md and ROADMAP.md as canonical owners. `.planning/state.json` is an OpenGSD-generated projection; never hand-edit it or treat its cached `next` command as authority. Run `bin/refresh_planning_state` after manual canonical repairs and at lifecycle commit boundaries; it uses the installed SDK publisher. Reconcile the live checkout, immutable delivery receipts and the preflight's `route_phase` before acting on a generic progress recommendation.

After a phase's green PR is merged, append its actual milestone version/key, integer phase, PR, reviewed head, merge commit and hosted CI URL to `.planning/references/PHASE-DELIVERIES.json`. Carry receipt bookkeeping on the next substantive push. Never mark a planning repair or numbering reset as implementation delivery. Do not automatically discuss, plan or execute a delivered phase because shared-source fingerprints later became stale: preserve the old report and trace any real regression to a new scoped task. Explicit re-verification may examine old delivery without reopening its implementation.

Before discussing another guard increment, show its concrete contribution to the remaining product blocker, full selected scope and pending complement, inherited limits, a bounded exit and the owner decision after that exit. Do not generate an automatic sequence of audit phases or milestones. One bounded milestone closes against its own requirements and merged deliveries; the wider gate remains open until its complete scoped proof passes. New product milestones must satisfy typed prerequisites in PHASE-MAP.json and PLANNING-GATES.json. Do not convert an open observation into a generic blocking audit task or weaken a product gate to move forward.

On every pause, record the actual checkout/branch, current milestone and phase, delivered versus unfinished work, unchanged safety stops, concrete next action and who acts next in STATE.md and the relevant receipt. Replace obsolete live handoffs; keep archived evidence immutable. Reconcile the dirty primary checkout through its recovery pointer before making changes there; do not reset, stash or clean it as a recovery shortcut. See `.planning/references/PLANNING-LIFECYCLE.md` for ownership and transition details.
