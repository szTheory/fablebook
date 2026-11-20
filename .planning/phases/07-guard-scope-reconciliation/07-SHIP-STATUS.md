# Phase 7 Ship Status

**Updated:** 2026-11-20T20:15:26Z  
**Branch:** `gsd/v0.6-phase-7-guard-scope-reconciliation`  
**Reviewed head:** `6516cbed9b529b7126fb40bf6a40516d257710e1`  
**PR:** [#96](https://github.com/szTheory/fablebook/pull/96)  
**Hosted run:** [CI 44807468659](https://github.com/szTheory/fablebook/actions/runs/44807468659)  
**Status:** blocked on required security check; not merged

## Check result

The hosted `core`, `floor`, and `dialyzer` jobs passed. The `security` job and aggregate `ci-gate` failed because `mix hex.audit` found `phoenix_live_view` 1.2.13 affected by [GHSA-v4p7-3pm2-wq6c / CVE-2026-126334](https://github.com/phoenixframework/phoenix_live_view/security/advisories/GHSA-v4p7-3pm2-wq6c). The advisory lists 1.2.14 as patched. The failure is deterministic and is not an infrastructure timeout.

Local verification remains green: `mix ci` passed with 460 tests and 10 intentionally excluded; the reconciliation checks and regular/optimized offline hardening controls passed; independent deep code review is clean. The local `act` runner limitation is documented separately and does not replace hosted CI.

## Why a direct bump is unsafe in the completed evidence

- The current core inventory binds `mix.lock` SHA-256 `31c244c80a750309f4cc82c8840fdf78bba642ba78a00df31b3acfe208b94112` and records LiveView 1.2.13.
- The approved source schedule is bound to that lock and package checksum. `core-source-03` was already consumed and remains a no-retry gap; it has no durable source hash or spans.
- The completed Phase 7 plan explicitly excludes dependency installation. Updating the lock without refreshing the inventory and reviewing a new schedule would make the evidence stale.
- `bin/planning_health --stage plan --phase 7` fails closed with `completed_phase_reentry`; no planning artifact was changed to bypass that gate.

No dependency, source evidence, or previously consumed request was changed after CI reported the advisory. All phase safety stops remain active: candidate null, implementation unauthorized, aggregate gate open, R9 denied and unconsumed, SEC-01 Pending, and Walking Skeleton blocked.

## Owner decision

Recommended: explicitly authorize a narrow Phase 7 revision that updates LiveView to patched 1.2.14, regenerates and independently reviews the current-core inventory and any affected source schedule, preserves all prior request IDs and no-retry gaps, then reruns verification and hosted CI. If the completed phase is not to be reopened, leave PR #96 unmerged and carry the dependency fix as separately scoped work.

**Next actor:** owner, to choose the scope path. No next milestone has started.
