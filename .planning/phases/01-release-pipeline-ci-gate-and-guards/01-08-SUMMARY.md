# Plan 01-08 Summary: Deploy non-blocking CI timing reports

## Outcome

The timing producer is deployed on main at `a5de2d0be26bab99e756720be4b3478bcdbb23a9`. Timing-only p50/p95 breaches now use the `ci-performance` label and continue to publish measured values and the unchanged 420-second p50 / 600-second p95 objectives as non-blocking feedback. Ruleset drift and explicit `--file-regression` reports still use `quality-regression`.

The performance label existed before producer deployment. Main’s `bin/ci_health` SHA-256 matches the reviewed producer candidate, and the Plan 07 guard merge is an ancestor of the deployment.

## Separate PRs

- [Initial timing contract PR #50](https://github.com/szTheory/fablebook/pull/50) added the staged contract before implementation.
- [Compatibility contract PR #51](https://github.com/szTheory/fablebook/pull/51) adapted the staged test helper for both the exact legacy producer and the strict producer. The owner approved this extra test-only PR because the original helper assumed the old script line and wording. Its path remained separate from the producer PR.
- [Producer PR #52](https://github.com/szTheory/fablebook/pull/52) changed only `bin/ci_health`.

## Evidence

- [Deployment receipt](01-08-TIMING-DEPLOYMENT.json) records label verification, PR paths and revisions, hosted CI, pinned runtimes, script digest, and post-merge checks.
- [Compatibility PR CI run 175](https://github.com/szTheory/fablebook/actions/runs/42245202610) passed core, floor, dialyzer, security, and `ci-gate`; `ci-health` and `nightly` were skipped as allowed.
- [Producer PR CI run 177](https://github.com/szTheory/fablebook/actions/runs/42247200617) passed the same required checks with the same allowed skips.
- After merging, the focused core contract/shape suite and floor contract suite passed on fetched main.
- The local compatibility tests also passed against both the exact legacy producer and a temporary copy of the strict producer.

## Remaining

Issue #37 was not read or modified, and no live `bin/ci_health` invocation or release workflow dispatch occurred. Plan 01-09 owns full issue-history classification, any safe migration, final removal of the digest transition, and live report verification. G-01-15 remains open until that plan is complete.

## Self-Check: PASSED

The compatibility and producer PRs are merged with their required hosted checks green. Fetched main contains the reviewed producer bytes and the Plan 07 guard merge; the receipt records the exact evidence.
