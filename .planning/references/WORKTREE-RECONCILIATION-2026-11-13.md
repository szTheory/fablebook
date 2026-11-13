# Worktree reconciliation — 2026-11-13

**Owner:** Jon  
**Active planning checkout:** `~/projects/fablebook` on `main`  
**Reviewed baseline:** `main` at `35cb6d8`; `origin/main` at `3817912` (main was four local commits ahead)  
**Review date for retained historical work:** 2026-12-13

## Summary

The repository listed 18 registered worktrees. Two had dirty working trees: the primary checkout and the old `agent-planning-main-261111` worktree. Thirteen valid Git worktrees were clean. Three filesystem remnants were marked prunable because their `.git` pointers referenced missing Git metadata; their branch refs remain available, and their directories were preserved. One clean branch (`gsd/phase2-bounded-asn1-rtt-evidence`) had a tree exactly matching `origin/main`; the other branch trees differ from `origin/main`. No branch or worktree was deleted.

The four pre-existing primary changes (`STATE.md`, `ROADMAP.md`, generated `state.json`, and the untracked v0.3 audit) were incorporated into the v0.3 closeout. All 22 active Phase 2 files have archived counterparts. Twenty-one are byte-identical; `deferred-items.md` carries the owner-approved acknowledgement added at close. The original root requirements file is retained until the archive safety commit.

## Registered worktrees

Ahead/behind and tree differences are measured against `origin/main` at `3817912`. A branch tree difference is not proof that every line is unique; divergent history is retained until reviewed.

| Checkout | Branch @ head | State vs `origin/main` | Disposition |
|---|---|---|---|
| `~/projects/fablebook` | `main` @ `35cb6d8` | 4 ahead; 0 behind; 4 local planning edits | Canonical active checkout; edits incorporated into closeout. |
| `/private/tmp/fablebook-phase-closure-final` | `phase-01.1.1.3.1.3-postmerge-record-v2` @ `76d1a450` | 2 ahead; 53 behind; 495-file tree delta; Git metadata missing; directory had no regular files | Preserve directory and branch; Git cleanliness cannot be asserted. |
| `/private/tmp/fablebook-phase2-candidate` | `gsd/phase2-bounded-asn1-rtt-evidence` @ `350d8931` | 10 ahead; 2 behind; tree matches `origin/main`; clean | Consolidated tree; retain branch/worktree as provenance. |
| `/private/tmp/fablebook-phase2-ci-final` | `gsd/phase2-ci-final` @ `3c87cdb0` | 6 ahead; 2 behind; 14-file tree delta; clean | Retain divergent CI evidence. |
| `/private/tmp/fablebook-phase2-ci-merge` | `gsd/phase2-ci-merge` @ `b797e4f7` | 3 ahead; 2 behind; 17-file tree delta; clean | Retain divergent merge evidence. |
| `/private/tmp/fablebook-phase2-ci-merge-final` | `gsd/phase2-ci-merge-final` @ `31eb9f5a` | 4 ahead; 2 behind; 15-file tree delta; clean | Retain divergent merge evidence. |
| `/private/tmp/fablebook-phase2-planning-tests` | `gsd/phase2-planning-tests` @ `2768a58a` | 2 ahead; 2 behind; 86-file tree delta; clean | Retain planning-test history. |
| `/private/tmp/fablebook-plan05-full` | `agent-plan05-full-phase` @ `9305a109` | 33 ahead; 56 behind; 501-file tree delta; Git metadata missing; directory had no regular files | Preserve directory and branch; Git cleanliness cannot be asserted. |
| `/private/tmp/fablebook-plan05-pr` | `agent-plan05-phase01.1.1.3.1.2` @ `8017e922` | 3 ahead; 56 behind; 503-file tree delta; Git metadata missing; directory had no regular files | Preserve directory and branch; Git cleanliness cannot be asserted. |
| `.claude/worktrees/agent-milestone-contract-261111` | `agent-milestone-requirements-contract-261111` @ `5af1ec16` | 1 ahead; 3 behind; 90-file tree delta; clean | Retain milestone-contract history. |
| `.claude/worktrees/agent-milestone-reset-261111` | `worktree-agent-milestone-reset-261111` @ `f4458fa9` | 6 ahead; 6 behind; 118-file tree delta; clean | Retain migration history. |
| `.claude/worktrees/agent-phase-011118-inline` | `worktree-agent-phase-011118-execution` @ `9799a1a7` | 19 ahead; 10 behind; 464-file tree delta; clean | Retain phase history. |
| `.claude/worktrees/agent-planning-health-261111` | `worktree-agent-planning-health-261111` @ `7afb646b` | 5 ahead; 5 behind; 101-file tree delta; clean | Retain health-repair history. |
| `.claude/worktrees/agent-planning-main-261111` | `gsd/phase-1-bounded-guard-continuation` @ `df17c245` | 69 ahead; 2 behind; 31-file tree delta; 9 dirty/untracked paths | Preserve dirty Phase 1/Phase 2 planning, brand-intake and test changes; do not reset, stash, clean or resume as canonical. |
| `.claude/worktrees/agent-quick-261110-nhq` | `worktree-agent-quick-261110-nhq-release-contracts` @ `32d38b57` | 13 ahead; 9 behind; 457-file tree delta; clean | Retain quick-task history. |
| `.claude/worktrees/agent-quick-261110-she` | `worktree-agent-quick-261110-she-ci-gate-contracts` @ `3f3bfeb1` | 12 ahead; 8 behind; 450-file tree delta; clean | Retain quick-task history. |
| `.claude/worktrees/agent-quick-261110-v8d` | `worktree-agent-quick-261110-v8d-floor-reporting` @ `31062f4a` | 9 ahead; 7 behind; 442-file tree delta; clean | Retain quick-task history. |
| `.claude/worktrees/fablebook-brand-intake-261111` | `agent-brand-intake-261111` @ `1ad8bde1` | 4 ahead; 4 behind; 101-file tree delta; clean | Retain under the separate brand-intake handoff. |

## Staging clone and next owner action

The v0.3 archive was completed on the isolated local branch `gsd/v0.3-milestone-closeout` at `2f794ad`, with an annotated local `v0.3` tag. Its archive files are being transferred to the canonical primary checkout; the staging clone remains preserved at `/private/tmp/fablebook-v03-closeout` for provenance. No remote ref was changed.

Every retained checkout and divergent branch is owned by Jon, with review by 2026-12-13. The only canonical planning checkout is now `~/projects/fablebook` on `main`. This inventory does not authorize deleting preserved work or starting a product scope. The next milestone workflow will wait for the owner to state what should be built next.
