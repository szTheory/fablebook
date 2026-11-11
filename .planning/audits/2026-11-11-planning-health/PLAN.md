# Planning lifecycle audit and repair

Authority: INT-20261111-03. Current v0.2 Phase 1 remains unstarted. This is the owner-requested planning-control repair, not guard implementation or a new product phase.

## Audit boundaries

Inventory every active/archive planning file; verify recorded archive hashes and structured metadata; reconcile current/primary checkout authority, authoritative state/projections, active/future requirement owners, seeds, handoffs, dependency edges, gates and installed read-only workflow outputs. Historical stale/missing reports remain historical and never auto-pass. Stock health is one input, not proof that semantic routing is sound.

## Concrete repairs under investigation

1. Separate initial migration evidence from mutable live-state validation, so legitimate later progress cannot fail a frozen Phase 1/unchecked-requirement assertion.
2. Eliminate the independently authored next-command JSON snapshot as a second routing authority; preserve its old content and direct consumers to canonical STATE.md / the OpenGSD projection.
3. Repair stale future seed/legacy transition routes and explicit prerequisite ownership after the numbering reset, preserving original IDs and source provenance.
4. Make milestone exit versus unresolved aggregate/product gates explicit. One bounded increment may complete without creating another automatic audit phase; it cannot silently close the parent gate.
5. Add a small read-only project lifecycle preflight and recurring tests in existing CI, with positive and negative fixtures across discussion/planning/execution/verification/shipping and new milestones. Use current metadata, never freeze the next milestone to this phase/version.
6. Check actual installed OpenGSD init/health/state/hook projections without executing workflows. Document tool/adapter limits instead of claiming new engine hooks exist.

## Validation and delivery

Use only standard existing tooling and pinned lanes. Add no dependency, workflow, production feature, global runtime patch or automatic phase advancement. New guard tests must be added independently of guarded runtime/workflow changes; existing planning guards cannot be edited beside intent sources. Focused planning/preflight tests, format, compile/lint and required full hosted CI remain gates. Run local Actions feasibility once; preserve the known concurrency.queue limitation if unchanged. Review within the two-pass cap. Publish the reviewed/tested candidate under standing authorization; owner handles the new PR's merge.

Done means repaired concrete findings have executable receipts and recurrence checks; current lifecycle routes to the actual next step; all original requirements/evidence/gates remain owned; full hosted checks pass. It does not promise that every possible future mistake is impossible or complete the unfinished source audit.
