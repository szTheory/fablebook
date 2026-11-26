# Worktree reconciliation — 2026-11-26

**Owner:** Jon
**Canonical checkout:** `~/projects/fablebook` on `main`
**Reconciled main:** `692501c46a191cbaf79e69dd360168058301e8db`
**Purpose:** Record the primary-checkout recovery after v0.7 closeout PR #107.

## Result

The primary checkout now points to the merged `origin/main` commit and has a
clean working tree. No dirty files or local commits were discarded. The entire
former dirty checkout was captured in a local snapshot commit before `main` was
repointed. Its old divergent head also remains reachable by a separate local
archive ref. Neither recovery ref was pushed.

| Ref | Commit | Meaning |
|---|---|---|
| `main` | `692501c46a191cbaf79e69dd360168058301e8db` | Canonical checkout, matching merged `origin/main` after PR #107 |
| `recovery/primary-dirty-v07-20261126` | `51a4ab4181f807e99690d12e7111de544fe639f1` | Complete snapshot of the dirty primary tree, parent `f23da6e341997999a084049436037bd6bd55c0af` |
| `archive/main-divergent-v07-20261126` | `f23da6e341997999a084049436037bd6bd55c0af` | Previous divergent `main` tip before reconciliation |

The prior checkout had 26 local commits and uncommitted Phase 8 planning, source,
operator-host, screenshot, and browser-evidence files. Its earlier comparison
was against an outdated `origin/main`; after fetching the current default branch,
the old head was six commits behind merged main. The snapshot commit preserves
the complete prior state, including all tracked edits and untracked files. The
older historical worktrees and separate brand-intake worktree were left alone.

The supporting handoff and CI-timing edits are prepared on local branch
`gsd/v07-primary-reconciliation`, based on the reconciled main above. The
project's `bin/planning_health --stage ship` preflight returned
`no_active_milestone`, so this post-closeout branch was not pushed or opened as
a PR. No new milestone was started.

## Delivery evidence

The archive itself was delivered by [PR #107](https://github.com/szTheory/fablebook/pull/107),
reviewed head `d0b49d06d879bf84733aa0c06b60bea4329590d5`, and merged as
`692501c46a191cbaf79e69dd360168058301e8db`. Exact-head CI
[45763508605](https://github.com/szTheory/fablebook/actions/runs/45763508605)
and post-merge main CI
[45765100650](https://github.com/szTheory/fablebook/actions/runs/45765100650)
passed. Release-please
[45765100715](https://github.com/szTheory/fablebook/actions/runs/45765100715)
completed with publishing skipped. The local annotated `v0.7` tag was not
pushed; no release or deployment occurred.

## Checks and boundaries

- `bin/planning_health --stage status` and `--stage milestone-start` returned no
  errors before the handoff update.
- The primary working tree was clean after switching to the fetched merged
  `main`; the old checkout remains recoverable from the refs above.
- No historical worktree was reset, stashed, cleaned, removed, or resumed.
- No Docker resources or long-running test processes were created for this
  reconciliation.
- The guard candidate remains null and implementation unauthorized; aggregate
  gate open; `walking-skeleton` blocked; R9 denied and unconsumed; SEC-01 Pending.
  No next milestone is selected.

## Transition to v0.8

The v0.7 post-closeout handoff was saved on the local `gsd/v07-primary-reconciliation`
branch before the primary checkout returned to `main`. The owner selected
and approved the fixed Scenario bundle. [PR #108](https://github.com/szTheory/fablebook/pull/108)
separately delivered the planning checker prerequisite. The new milestone and
next action are recorded in [STATE.md](../STATE.md) and [ROADMAP.md](../ROADMAP.md).
