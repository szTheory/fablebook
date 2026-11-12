---
phase: 01-bounded-guard-continuation
plan: "03"
status: validation_pending
source: automated
delivery: pending
---

# Phase 1 candidate evidence

The selected EX-010 row has a source-backed static disposition for both `inets:enable_trace/2,3`: retain the original matcher as a callback front with a fixed native-driver boundary. No new evaluator or atom-creation ban is justified by these findings. Complete candidate validation and publication are still pending in this revision. This document is a candidate receipt, not a phase verification report or merge approval.

## Source interpretation and authority

Plans 01 and 02 independently reviewed the complete three-file path in their separate exact-lane contexts. Integration consumes their structured findings in `InetsTraceCoreEvidence.record/0` and `InetsTraceFloorEvidence.record/0`, not six reopened OTP files. Their pending/candidate-only fields remain historical review provenance. `InetsTraceIntegrationEvidence` supplies the final selected dispositions. The live original-identity ledger advances only EX-010 to `inets_trace_retained`, owned by `v0.2/1`; its original identity/matcher survives. EX-011 and every outside-row owner/status/match retain their authority.

| Lane | Exact source | Bytes | SHA-256 |
|---|---|---:|---|
| core | `inets/src/inets_app/inets.erl` | 18519 | `18d0c8091e7c9ce34fad897734c1b4105fd8c19d0912da28a32856664c760f00` |
| core | `inets/src/inets_app/inets_trace.erl` | 11112 | `1f67a0bda05227eddd8ffb4909ec8a31465ef2d8582e0ff9ff5d2b72638c7599` |
| core | `runtime_tools/src/dbg.erl` | 105185 | `d996e990b75251edb65d4930a1edf5c1914f6c18f77ac526313157612f95f5f2` |
| floor | `inets/src/inets_app/inets.erl` | 18409 | `d8786fea1edde0d055e7198cdb279e9a1999daa070d4dc229f3ec66b75e8bd5e` |
| floor | `inets/src/inets_app/inets_trace.erl` | 11073 | `3e03ac1b03d2a01e7ddb1b1e29543e632aa3a63e16aa1f5a8c19ba935ae4dffd` |
| floor | `runtime_tools/src/dbg.erl` | 112878 | `808aa7980e020fc529e153fc907b606fd0e2ff5fb4ad0b74e548b5eafaea0dae` |

The archive SHA-256 is `7d4bd66fe72224cf49f849148b5e737443588ca66c12873938bfa30fa3d0ea58`. Core OTP 29.1.2 binds ref `d199a49a01a2079afb6f2c5c9ae047cd4555e68d`; floor OTP 27.3.4.9 binds ref `4aa809ae4eb4a20ad89c23837376acf179877f39`. Both selected exports forward inputs to `inets_trace:enable/2,3`. Arity 2 supplies service `all`; arity 3 validates `all/httpc/httpd`. Destination branches choose file output, integer IP port, `io`, or `{Fun, Data}`. `dbg` invokes the supplied handler; that implementation is caller code. The native driver name is the fixed `trace_ip_drv` literal. The level enters a fixed comparison match specification, not source evaluation.

These records justify the static retention decision. They do not establish callback-body semantics, absence of dynamic callers, native-driver internals, or runtime SEC-01 safety. Zero direct incoming graph edges is not a dynamic-caller proof. No audited API, callback, fixture function or atom sink was invoked.

## Selected partition and controls

Both live lanes select exactly the two exports with zero within-row remainder, and retain their two delegate edges. Added exports, omitted/duplicate/wrong-lane records, unsupported findings, missing source/review/delegate evidence and overlapping selected/remainder sets fail. Permuting record, graph, tier and original-ledger enumeration preserves the classification. Whole original-row and metadata mappings remain checked; EX-011 cannot acquire EX-010's disposition through shared source.

For each selected MFA, removing only the original `{{:inets, [:enable_trace]}, :own_native}` matcher exposes that MFA. Extra exact/name matchers and active-tier substitutions fail rather than supplying overlapping credit. The unchanged reason's fixed-driver claim is supported by the reviewed native branch; the integration record separately states the callback boundary. No active guard was added and no explanation wording changed. Uncalled direct/capture/apply fixtures retain real BEAM call edges, remain accepted by the current checkers, and preserve benign controls. Quoted/module-body source strings are inspected by Credo without compilation or invocation.

## Local execution receipts

All commands ran in the pinned reviewed checkout with the existing offline lane copies. Logs, exact exits and UTC end stamps are under `_build/phase1-execution/`; generated logs are ignored runtime output. `source: automated` applies to executable checks, not to semantic interpretation.

| Task/check | Command or artifact | Actual result |
|---|---|---|
| Execute entry | `bin/planning_health --stage execute --phase 1` | Exit 0; no errors; route Phase 1, 2026-11-11T22:45:40Z |
| Task 1 RED | Core integration test with existing `Fablebook.Test.ExUnitTapFormatter` | Exit 2; intended missing integration module assertion failed |
| RED validation | `gsd-tools check tdd-red-evidence _build/phase1-execution/plan03-task1-red-evidence.json --raw` | `RED_EVIDENCE_OK`; exact target executed; no load/fixture/syntax failure |
| Task 1 core focused | `bin/lane core test --warnings-as-errors test/contract/tier_sweep_test.exs test/contract/banned_calls_test.exs --only inets_trace_integration --only inets_trace_guards` | Exit 0; 5 selected pass; 68.7s; end 22:54:47Z |
| Task 1 floor focused | Same command with `floor` | Exit 0; 5 selected pass; 34.0s; end 22:55:40Z |
| Initial full core CI | `MIX_ENV=test bin/lane core mix ci` | Exit 10 at strict Credo after format/locks/compile; phase-introduced style issues fixed without suppressions |
| Strict Credo after fixes | `MIX_ENV=test bin/lane core mix credo --strict` | Exit 0, no issues, including final rationale-control fix |
| Expanded core refactor controls | Focused command plus `--only inets_trace_core_source --only inets_trace_core_controls` | Exit 0; 7 selected pass; 56.2s; before final rationale pin |
| Expanded floor refactor controls | Focused command plus `--only inets_trace_floor_source --only inets_trace_floor_controls` | Exit 0; 7 selected pass; 38.4s; includes final rationale pin |
| Full core CI at final candidate | `MIX_ENV=test bin/lane core mix ci` | Pending; must include format, unused locks, force compile, strict Credo, cycles, docs, full tests including prod_guard/release |
| Floor compile | `MIX_ENV=test bin/lane floor mix compile --warnings-as-errors` | Pending |
| Floor optional isolation | `MIX_ENV=test bin/lane floor mix compile --no-optional-deps --warnings-as-errors --force` | Pending |
| Full floor tests | `MIX_ENV=test bin/lane floor test --warnings-as-errors --include prod_guard` | Pending |
| Protected paths | Diff from approved main `1fb61faf700db5398d3174d94a967a9199b89a85` over `lib`, `.github`, `mix.exs`, both locks, `.credo.exs` | Empty; exit 0; checker/explanation unchanged |

Local Actions are unavailable: the existing `act pull_request -W .github/workflows/ci.yml --dryrun` receipt exits 1 because the installed parser rejects `concurrency.queue`. The unchanged workflow still contains that key. This known limitation is reused from the planning-health report; no unchanged retry, CI workaround or hosted-receipt substitution is claimed.

## Independent review and accepted fixes

The independent read-only first pass examined the whole phase diff from approved main, including archive additions, resolver/lane helper changes, both lane controls and final integration. It consumed hash-scoped semantic records without opening OTP source bodies. It found no remaining pass-1 blocker and supported the retained callback-front disposition. Its metadata/hash comparison found exactly two added archive members and no changed or removed prior source members. Review is bounded to two passes; pass 2 must bind the accepted rationale fix to the final candidate head.

Pass 1 identified a warning: a substring-only rationale assertion could accept a contradictory claim while retaining the words `caller code`. Accepted fix: an exact reviewed-rationale contract plus an adverse assertion that falsely claims SEC-01 runtime completion. The current retention text itself was consistent with the lane findings. Strict Credo also required small aliases/helper refactors; record values and source hashes were preserved. One Task 1 range-normalization bug was fixed before passing focused runs.

## Threat mitigation evidence

| Threat | Current evidence and disposition |
|---|---|
| T-1-09 semantic/partition tampering | Both lane source identity/citation controls, full live partition, wrong-lane/omission/overlap/permutation negatives, original mapping preservation, exact rationale pin and independent semantic-record review; final review pending |
| T-1-10 incomplete static guards | No new guard justified; real uncalled forms and individual retained-matcher removal checks pass on both lanes; existing mirrored source/BEAM tiers unchanged |
| T-1-11 production collision | No new active pattern; protected paths unchanged and no `enable_trace`/`:inets` call found in `lib`; actual future collision retains the owner remedy stop |
| T-1-12 candidate spoofing | Final same-head local/review/hosted checks pending; no publication, merge authority or delivery claimed |
| T-1-13 receipts/cost | Actual UTC sidecars and exits retained; final durations/candidate facts pending, never invented |
| T-1-14 broader completion | Aggregate, installed-wide remainder, skeleton gate and SEC-01 remain open; all requirements remain pending actual delivery; no phase.complete or later phase |
| T-1-SC package integrity | No new dependency or install task; protected dependency/config files unchanged |

## Candidate identity, hosted checks and delivery

The Task 1 implementation head is `1f6de5d32da6f0414f5a6aade66b5d7a3c65de23`; RED is `2dd6936`. Accepted bounded Task 2 fixes and this pending-gates receipt will form the substantive candidate before full validation. Final reviewed/tested source hashes, published PR/head and required core/floor/Dialyzer/security/ci-gate URLs must be recorded after those checks actually run. No green hosted candidate is claimed in this revision.

Post-CI receipt bookkeeping will remain local for the next substantive push; it must identify the actual green remote head and cannot claim hosted CI for a later local documentation commit. After a truthful Plan 03 summary exists, the orchestrator owns the single independent phase verification, ship preflight, exact-candidate owner merge decision and actual merge/main-CI registry evidence. Phase delivery and GRC-02 delivery acceptance remain pending until then.

## Cost and bounded handoff

Task 1 interval: 2026-11-11T22:45:40Z through its committed passing controls, 22:55:40Z. Task 2 began at 22:56:35Z and is ongoing. Integration opened zero full OTP source files; it reused the bounded lane findings under the 40,000 findings allowance with the full 31,000 reserve retained in the plan. Actual harness context/token consumption is unavailable; final diff-size actuals will be measured, not represented as harness tokens. No source/scope/effort expansion is approved.

Next: finish the required full local gates, independent review and same-head hosted candidate checks. The executor acts next; the owner is not being asked to approve routine checks. This candidate cannot merge or close the phase yet.
