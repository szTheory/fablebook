# Phase 7 Ship Status

**Updated:** 2026-11-20

**Phase branch:** `gsd/v0.6-phase-7-guard-scope-reconciliation`

**Local base:** `6516cbed9b529b7126fb40bf6a40516d257710e1`

**PR:** [#96](https://github.com/szTheory/fablebook/pull/96)

**Status:** Phase 7 and v0.6 milestone closeout delivered

## Previous hosted result

The currently published PR head `6516cbed9b529b7126fb40bf6a40516d257710e1` failed the required security check in [CI run 44807468659](https://github.com/szTheory/fablebook/actions/runs/44807468659). Core, floor, and Dialyzer passed; `mix hex.audit` rejected LiveView 1.2.13 under [GHSA-v4p7-3pm2-wq6c / CVE-2026-126334](https://github.com/phoenixframework/phoenix_live_view/security/advisories). That failure remains preserved as history and does not apply to the new local candidate.

## Rebaseline result

Under [INT-20261120-07](../../../intent/sources/2026-11-20-07-authorize-phase7-security-rebaseline.md), the core lock now changes only `phoenix_live_view` from 1.2.13 to patched 1.2.14. The current core export inventory binds the new full lock digest; every saved core row/MFA and the existing 7/1,756 family/complement partition reconcile. The independently reviewed current source schedule carries forward only Plug and retains four gaps, including the LiveView no-retry gap. All five consumed request IDs remain closed. The floor lock and accepted ENV06 evidence were not changed.

Final local checks:

- Goal verification: 4/4 criteria passed in [07-VERIFICATION.md](07-VERIFICATION.md).
- Independent code review: clean in [07-REVIEW.md](07-REVIEW.md).
- Reconciliation validator and exact LiveView tuple/checksum checker: passed.
- Focused lock contract: 5 passed, including rejection of altered Plug/LiveView pins and unrelated lock changes.
- Core `mix ci`: 461 passed, 10 excluded; ExUnit completed in 440.3 seconds.
- Core `mix hex.audit`: no retired or security-advisory packages.
- `git diff --check`: passed.

## Delivery result

The final reviewed Phase 7 head was `d74b21a07a67d4b526576fc09833ffafe99cded1`. Required `security`, `core`, `floor`, `dialyzer`, and aggregate `ci-gate` checks all passed on exact-head [hosted CI run 44827619883](https://github.com/szTheory/fablebook/actions/runs/44827619883). PR #96 was squash-merged as `0ea95d4c8cdf6ce9a1af363c7ea0033d632b0e6d` on 2026-11-20. Post-merge main CI [run 44828949627](https://github.com/szTheory/fablebook/actions/runs/44828949627) also passed all required jobs on that merge commit. The delivery registry records the receipt. The earlier failed security run remains history and does not describe the patched head.

The v0.6 archive closeout is recorded in [the milestone receipt](../../v0.6-CLOSEOUT.md). No deployment or next milestone is included.

All safety stops remain active: candidate null, guard implementation unauthorized, aggregate open, actual-library collision unknown, R9 denied and unconsumed, SEC-01 Pending, Macro caller-AST and explanation gaps, legacy digest unresolved, and Walking Skeleton blocked. No further guard increment is automatic or preapproved.
