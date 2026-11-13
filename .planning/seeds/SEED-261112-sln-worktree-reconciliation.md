---
id: SEED-261112-sln
status: dormant
planted: 2026-11-12
planted_during: v0.3 Phase 2 planning
trigger_when: After v0.3 Phase 2 is verified, merged, and its actual main CI receipt is confirmed; complete during v0.3 milestone closeout and before activating or planning the next milestone.
scope: One-time repository/worktree reconciliation and canonical-checkout handoff.
---

# SEED-261112-sln: Reconcile worktrees at milestone closeout

## Why This Matters

Several worktrees now hold different generations of planning, phase, and brand-intake work. The primary checkout contains unrelated uncommitted work, the reviewed Phase 2 checkout is the current planning source, and some preserved temporary worktrees contain large deletion sets. Keeping them all indefinitely makes it easy to resume from the wrong state; deleting or resetting them without review could lose user work. This needs a deliberate end point after the active v0.3 milestone, rather than an open-ended instruction to preserve everything.

## When to Surface

**Trigger:** Once Phase 2 has passed verification, shipped in a merged green PR, and its actual main CI receipt has been checked. Run this as a required v0.3 closeout follow-up before `$gsd-new-milestone` activates the next milestone or another checkout is made the active workspace. If it cannot be completed safely, record the specific remaining worktrees, their protected contents, an owner decision, and a dated revisit point; do not silently carry the reminder forward.

## Scope Estimate

**Bounded repository-hygiene pass:** Inventory all registered worktrees, branch heads, uncommitted changes, and commits not in actual main. Preserve or back up unique work, then classify each checkout as consolidated, intentionally retained with an owner and revisit date, or safe to remove after verifying its work is represented elsewhere. Finish with one declared active checkout and accurate recovery instructions. Estimate after the inventory; this is not product or guard implementation scope.

## Completion Criteria

- Every worktree has a recorded disposition and no unique dirty content is lost.
- Intended current work is available from one declared active checkout; other checkouts are either clean and intentionally retained or safely retired after merge/backup verification.
- No reset, stash, branch switch, cleanup, or worktree removal is used to bypass review of dirty content. Any proposed discard of unique work gets an explicit owner decision.
- `AGENTS.md`, the active `STATE.md` continuity pointer, and the next-session instruction agree on the canonical checkout and the next command.
- This seed is marked complete only after the inventory and disposition record are linked from the closeout; any remaining deferral has an owner and revisit date.

## Breadcrumbs

- `.planning/STATE.md` — current v0.3 Phase 2 state, reviewed plan set, and preserved checkout pointer.
- `AGENTS.md` — recovery instructions for the dirty primary checkout and reviewed baseline.
- `.planning/references/PLANNING-LIFECYCLE.md` — phase and milestone closeout gates.
- `.planning/seeds/SEED-261110-iry-logistify-phase17-brand-intake.md` — an example of a forward-looking seed with a concrete trigger.

## Notes

The Phase 2 owner decision to use separate lane-owned test files is already recorded and the five plans passed review. This seed does not delay or change Phase 2 execution. The Shopadelic handoff in the primary checkout is separate brand-intake work and is not part of the Phase 2 implementation scope.
