# Phase 1: Bounded guard continuation - Discussion Log

> Audit trail only. Decisions for downstream work are in `01-CONTEXT.md`.

**Date:** 2026-11-11
**Milestone:** v0.2 / guard-recovery
**Areas discussed:** next bounded source scope; exact-lane source authority and fit; adversarial proof and stops; delivery and post-exit ownership.

## Scope decision

| Option | Description | Selected |
|---|---|---|
| Take the complete inets tracing-entry candidate for Phase 1 | Review EX-010's two entry functions per lane and necessary delegate paths. Certify complete source/effort fit before planning; stop if it does not fit. | Yes |
| Reconsider the aggregate audit strategy first | Address the potentially large remaining investment before committing to another increment, preserving existing gates. | No |

**Owner response, verbatim:** `1`

The preceding recommendation disclosed the preliminary four-source/about-14k-token pilot, missing delegate-source binding, required caller-influence review and sizing, unchanged wider gates, and a bounded green-merged-PR exit. No implementation result or aggregate unlock was promised. INT-20261111-05 records the selection.

## Research synthesis and technical discretion

The owner requested context-efficient fan-out across relevant engineering, security and delivery perspectives, with coherent recommendations and minimal dependencies. Three read-only advisory tasks and one targeted provenance follow-up examined existing records. They identified already delivered ASN.1 slices, preserved the full remaining acceptance, and warned against converting mechanical backlog groupings into an automatic phase schedule.

The targeted follow-up corroborated EX-010's recorded two-MFA membership on each lane and preliminary source identities. The parent independently joined the preserved metadata before saving the narrow candidate snapshot. These are discovery observations, not new semantic findings, live-inventory proof or implementation effort estimates.

The upstream xref documentation was checked for the dynamic-call limitation. No audited API, callback, atom sink, application suite, source download or hosted CI run was invoked for discussion. The owner was not asked to choose helper layout, add dependencies, repeat status commands or reconfirm existing safety stops.

## Deferred work and boundary

Adjacent tracing-row ownership, the remaining exclusions and installed-wide gaps stay with existing owners. The complete aggregate and walking-skeleton gate remain open; SEC-01 stays Pending with its future property/mutation owner. After this selected milestone's actual delivery, the owner chooses the next scope or a strategy review. No automatic follow-on phase was selected.

Next command: `$gsd-plan-phase 1` — research exact connected scope, source binding and effort fit before writing executable plans. Discussion capture does not start implementation.

## Capture validation

The existing planning/intent/contract-rule suites ran directly with the pinned core Elixir runtime and standard-library support files: `elixir -r test/support/git_diff.ex -r test/support/planning_state.ex -r test/test_helper.exs -r test/planning/intent_test.exs -r test/planning/contract_rule_test.exs -r test/planning/planning_state_test.exs -e ''`. Result: 50 passed. This is local discussion validation, not hosted implementation CI or a semantic disposition.

`bin/planning_health --stage plan --phase 1` reported no errors; `state.validate --strict` reported valid with no warnings. Every local canonical reference exists. The candidate snapshot matches the four preserved input hashes, both archived wrapper source identities/bytes match, and both delegate identities are absent from the current archive as disclosed. No source or guard file changed.

The SDK initially treated the adjacent session `Next action` line as a continuation of `Stopped at` and declined that field update. Separating the session fields with blank lines allowed the registered session handler to save the current stopping point; the SDK publisher regenerated `state.json`. No engine patch or additional repair phase was introduced.
