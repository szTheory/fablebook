# Phase 7 Ship Status

**Updated:** 2026-11-20

**Branch:** `gsd/v0.6-phase-7-guard-scope-reconciliation`

**Local base:** `6516cbed9b529b7126fb40bf6a40516d257710e1`

**PR:** [#96](https://github.com/szTheory/fablebook/pull/96)

**Status:** rebaseline verified and committed locally; push and exact-head hosted CI pending

## Previous hosted result

The currently published PR head `6516cbed9b529b7126fb40bf6a40516d257710e1` failed the required security check in [CI run 44807468659](https://github.com/szTheory/fablebook/actions/runs/44807468659). Core, floor, and Dialyzer passed; `mix hex.audit` rejected LiveView 1.2.13 under [GHSA-v4p7-3pm2-wq6c / CVE-2026-126334](https://github.com/phoenixframework/phoenix_live_view/security/advisories). That failure remains preserved as history and does not apply to the new local candidate.

## Rebaseline result

Under [INT-20261120-07](../../intent/sources/2026-11-20-07-authorize-phase7-security-rebaseline.md), the core lock now changes only `phoenix_live_view` from 1.2.13 to patched 1.2.14. The current core export inventory binds the new full lock digest; every saved core row/MFA and the existing 7/1,756 family/complement partition reconcile. The independently reviewed current source schedule carries forward only Plug and retains four gaps, including the LiveView no-retry gap. All five consumed request IDs remain closed. The floor lock and accepted ENV06 evidence were not changed.

Final local checks:

- Goal verification: 4/4 criteria passed in [07-VERIFICATION.md](07-VERIFICATION.md).
- Independent code review: clean in [07-REVIEW.md](07-REVIEW.md).
- Reconciliation validator and exact LiveView tuple/checksum checker: passed.
- Focused lock contract: 5 passed, including rejection of altered Plug/LiveView pins and unrelated lock changes.
- Core `mix ci`: 461 passed, 10 excluded; ExUnit completed in 440.3 seconds.
- Core `mix hex.audit`: no retired or security-advisory packages.
- `git diff --check`: passed.

## Delivery gate

The reviewed rebaseline is committed locally as `8760cbc`; push it to PR #96. The current PR head is still the pre-rebaseline `afa9030640ab60b05d6f4d1fefb9ecea32a6b3d4`. After the push, require green `security`, `core`, `floor`, `dialyzer`, and aggregate `ci-gate` checks on the exact new PR head. Squash-merge only that green head under the standing authorization, append the phase delivery receipt, then audit and close v0.6. No deployment or next milestone is included.

All safety stops remain active: candidate null, guard implementation unauthorized, aggregate open, actual-library collision unknown, R9 denied and unconsumed, SEC-01 Pending, Macro caller-AST and explanation gaps, legacy digest unresolved, and Walking Skeleton blocked. No further guard increment is automatic or preapproved.
