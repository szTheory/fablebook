# Phase 4 budget stop

**Recorded:** 2026-11-17  
**Checkout:** isolated recovery candidate, branch `gsd/phase-03-recovery-and-provenance-closure`  
**Phase 4 status:** source execution not started; cumulative budget gate fails closed

## Measured usage

The Phase 4 ceiling is 100,000 tokens, including a fixed 31,000-token reserve, leaving at most 69,000 working tokens. Local Codex session records contain exact cumulative `total_token_usage.output_tokens` values. Summing the final output count from nine distinct Phase 4 research, planning, revision, and review sessions gives **191,582 output tokens**. This deliberately excludes the parent conversation, earlier Phase 4 attempts, and one plan-checker session later reused for a Phase 3 review. It is therefore a lower bound for Phase 4 planning work, not an estimate.

Output alone exceeds the full ceiling by 91,582 tokens and the 69,000-token working allowance by 122,582. The plan's 25,000-token execution estimate is prospective and cannot replace this measured prior usage. There is no remaining Phase 4 source budget under the approved cap.

| Session task | Output tokens | Session log SHA-256 |
|---|---:|---|
| `phase4_evidence_research` | 21,984 | `001775942fb257212bb8f7f14d7638edf4121f16893d06f5c30604f8e323083b` |
| `phase4_pattern_map` | 21,491 | `eb23c049034f2ecf18135dd8c2f7986add436b05bce3d411a05ba34d3cb466a6` |
| `plan_phase4_provenance` | 29,194 | `5e55b1a9607ced6f7fe7bd782074aa1fd40b9106999acf9b037279cfeeb9ff9b` |
| `review_phase4_plans` | 32,472 | `a48c021263c569f7106ba4d3ab018a207b114af42bde319c727e3c3f8879791b` |
| `revise_phase4_plan_round1` | 15,693 | `0504a1b5558e0bd65cb0ab5ef0b32d3c0fd4b55d03c35f743a4276586e5a788d` |
| `recheck_phase4_plans` | 26,819 | `09aa0a9924c4920482969e51bca1b6f70f4dcaac2d8b98c4f23328395b2938b3` |
| `revise_phase4_plan_round2` | 16,409 | `77039ef36aa2b6a88b365d0521752276196756b913feefef7355891a6fc7b4a0` |
| `resolve_phase4_research_questions_round3` | 1,773 | `abc11f82ddad46cc2880d011feb490b821af35a3d11133375eb3da39a71d0690` |
| `verify_phase4_after_final_revision` | 25,747 | `f78018028bd0bb7becefdd1ab99f97a7df5e296807fbfde42a82342264c41745` |
| **Lower-bound total** | **191,582** | |

The session logs were inspected for token metadata only; no prompts or source bodies were emitted. No Phase 4 source schedule review, execute-stage source preflight, direct count, source-body read, or source-dependent test ran. The fixed reserve and all source-read gates remain untouched.

## Cause and lesson

Research, planning, and repeated review work was not reconciled against the cumulative phase ceiling before the next agent wave. Plan estimates showed prospective execution effort but did not include measured prior agent output. Before future bounded phase fanout, reconcile exact per-session usage after each agent wave and compare it with the ceiling and protected reserve before dispatching another planner, reviewer, or source task. An estimate is not a usage balance.

## Consequence and next actor

Phase 3 Task 1's formatting, intent-record, citation, and intent-corpus repairs pass; its source/caller and collision-fixture work remains incomplete. Phase 4's six consumer artifacts are not produced. Phase 3 Tasks 2–3 and all source-dependent suites remain not-run. The owner must decide whether to keep the explicit 100,000-token Phase 4 ceiling (which leaves these checks blocked) or authorize a new bounded Phase 4 budget/scope. Codex continues only after that cost boundary is resolved.
