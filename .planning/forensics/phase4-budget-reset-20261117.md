# Rebased recovery work envelope

- **Recorded:** 2026-11-17
- **Checkout:** `/private/tmp/fablebook-phase3-remediation`
- **Branch:** `gsd/phase-03-recovery-and-provenance-closure`
**Authorization:** [INT-20261117-01](../intent/sources/2026-11-17-01-authorize-rebased-recovery-envelope.md)
**Start-point decision:** [INT-20261117-02](../intent/sources/2026-11-17-02-start-budget-after-review.md)
**Status:** Active from `2026-11-17T13:49:13Z`

## New hard ceiling

The owner accepted the recommendation to set a new bounded ceiling before resuming and reconcile usage after each work wave. The owner then selected the recommended post-review/preflight start point in INT-20261117-02. The independent plan reviewer confirmed the 150,000 − 31,000 = 119,000 arithmetic, the 50,000 + 20,000 remaining-plan estimate, historical status of old 100,000 references, and preservation of source/safety gates. Its only block was ambiguity about whether setup output was included; INT-20261117-02 resolves that finding. The required plan and execute preflights passed before reset. The **150,000 generated-output-token envelope is now active**, effective at `2026-11-17T13:49:13Z`, with starting usage **0**, protected reserve **31,000**, and working balance **119,000**. The setup/replanning/review work and the prior dedicated-session lower bound of 191,582 output tokens remain sunk historical use; they are not erased or combined into a fabricated total.

Pre-reset checks: `bin/planning_health --stage plan --phase 4`, `--stage plan --phase 3`, `--stage execute --phase 4`, and `--stage execute --phase 3` each returned no errors and route `03`. This lifecycle preflight is not a source-request receipt. Each actual source request still needs its own exact schedule, independent review, fresh Phase 4 execute preflight, direct count, and fit proof.

The planned remaining raw allocations are approximately 50,000 tokens across Phase 4 Plans 04-01 through 04-03, plus 20,000 tokens across Phase 3 Plan 03-05 Tasks 2–3. The 119,000 working ceiling leaves 49,000 tokens above those existing plan allocations for the required final review/verification and bounded execution variance. No new product scope, implementation authority, or production release is included.

## Historical usage carried forward

The prior receipt establishes a conservative lower bound of **191,582 output tokens** across nine dedicated Phase 4 research/planning/review sessions. Its parent/orchestrator, earlier-attempt, and mixed-purpose-session output was deliberately excluded, so the true historical total is higher. Those sessions remain recorded in [the original budget stop receipt](phase4-budget-stop-20261117.md); they are sunk usage outside this incremental reset, not reclassified as free or deleted. The plan-reset setup is additional sunk use with no complete checkout-attributed total. If the entire new envelope is used, the measured lower bound plus that envelope alone totals at least 341,582 output tokens, excluding the rest of the historical use.

## Reconciliation and stop rule

- The owner-selected post-review/preflight start is recorded above. At each completed in-envelope work wave, record every session's task attribution, exact input/output/cached-input counts, session-log SHA-256, and any mixed-purpose allocation method.
- At each completed in-envelope work wave, record every session's task attribution, exact input/output/cached-input counts, session-log SHA-256, and any mixed-purpose allocation method.
- Charge every post-reset assistant output token to the 150,000 ceiling. Preserve the 31,000 reserve; stop before either limit is crossed.
- Recompute balance from measured usage before starting another wave. Plan estimates are projections and do not replace that ledger.
- Keep the existing exact request gates: source schedule, independent review, fresh execute preflight, direct input-token count, cumulative fit, five exact source files per task, 34,000 compact-context limit, and no truncation. The new ceiling does not waive any gate.
- If usage attribution, direct count, or cumulative fit cannot be established, keep source access closed, complete only the already-planned truthful blocked metadata package within the remaining envelope, and record the exact blocker and next actor. No automatic cap increase or unchanged retry.

This cap supersedes the Phase 4 100,000-token ceiling only for this bounded recovery envelope. The fixed reserve, evidence-only Phase 4 scope, Phase 3 implementation/candidate stops, and all other project limits remain in force.
