---
phase: 01-bounded-guard-continuation
plan: "03"
status: implementation_complete
source: automated
delivery: pending
reviewed_head: a90ef1dfe7bad10ac3d303b82f8ba7b32c949745
hosted_run: https://github.com/szTheory/fablebook/actions/runs/43124394402
---

# Phase 1 candidate evidence

The selected EX-010 row has a source-backed static disposition for both `inets:enable_trace/2,3`: retain the original matcher as a callback front with a fixed native-driver boundary. No new evaluator or atom-creation ban is justified by these findings. Local validation, independent review and required hosted candidate checks pass on the same published head. Actual phase verification, owner merge approval and delivery remain pending. This document is a candidate receipt, not a phase verification report or merge approval.

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

All commands used the pinned checkout and existing offline lane copies. Exact logs, UTC sidecars and exits remain under `_build/phase1-execution/`; generated output is ignored. Final broad commands have individual `.head` receipts binding `a90ef1dfe7bad10ac3d303b82f8ba7b32c949745`. Executable checks are `source: automated`; semantic interpretation is recorded independent review.

| Check | Command | Actual result |
|---|---|---|
| Execute entry and close-out preflight | `bin/planning_health --stage execute --phase 1` | Exit 0, no errors, route Phase 1 |
| Task 1 RED | Core integration contract with existing TAP formatter | Exit 2 at the intended missing integration-module assertion; machine `RED_EVIDENCE_OK` and semantic assessment passed |
| Task 1 focused core / floor | Both contract files, `--only inets_trace_integration --only inets_trace_guards` | Exit 0 each; 5 selected each; 68.7s core / 34.0s floor |
| Final strict lint | `MIX_ENV=test bin/lane core mix credo --strict` | Exit 0; no issue or suppression |
| Cheap wiring core / floor | `bin/lane <lane> test --warnings-as-errors test/contract/ci_shape_test.exs` | Exit 0 each; 71 passed each; both CI and non-CI wrong-lane and unrelated-tag negatives |
| Final focused core / floor | Task 1 command plus the applicable lane source/control tags | Exit 0 each; 7 selected each; 63.7s core / 40.0s floor |
| Final full core | `MIX_ENV=test bin/lane core mix ci` | Exit 0, 23:39:32Z–23:48:34Z; 438 passed / 3 floor tests excluded; 532.0s tests |
| Final floor compile | `MIX_ENV=test bin/lane floor mix compile --warnings-as-errors` | Exit 0, 23:48:34Z–23:48:35Z |
| Final floor optional isolation | `MIX_ENV=test bin/lane floor mix compile --no-optional-deps --warnings-as-errors --force` | Exit 0, 23:48:35Z–23:48:37Z |
| Final full floor | `MIX_ENV=test bin/lane floor test --warnings-as-errors --include prod_guard` | Exit 0, 23:48:37Z–23:56:24Z; 441 total, 0 failures / 6 expected core/release exclusions; 465.1s tests |
| Protected paths | Diff from approved main `1fb61faf700db5398d3174d94a967a9199b89a85` over `lib`, `.github`, `mix.exs`, both locks and `.credo.exs` | Empty; checker and explanation unchanged |
| Portability/privacy | Added tracked text against approved main | No absolute home paths, prohibited external names or separate brand-intake paths |

The full core alias passed format, unused locks, force compile, strict Credo, compile-connected cycles, docs and full tests including `prod_guard` and `release`. Floor exclusions select the two independently proven core-only tests and the existing release coverage owned by core; floor-specific tests execute on floor. No expected lane witness is silently skipped.

Historical failures are retained rather than overwritten: initial core CI exited 10 at strict Credo (22:56:35Z–22:56:43Z); bounded style fixes preserved values. Full core at `1b2b281` then exited 2 after 609.7s because two floor-only tests lacked their existing `:floor` annotations. The two-line correction at `93fe204` passed full core (436 passed, 3 excluded; 23:15:48Z–23:25:07Z), including the OS process that survived the server restart and was monitored to its real exit without duplication. Full floor at that head exited 2 (23:25:51Z–23:35:58Z; 439 total, one failure, six excluded; 605.6s) because the custom core-only exclusion was rejected by the existing CI-wiring policy.

The owner explicitly approved the concrete three-file symmetric lane-policy remedy and one focused review. The final helper uses `:core` and `:floor` complementarily; CI-shape checks forbid excluding a lane's own tests and still reject unrelated tags. No workflow, dependency, production implementation or static-guard semantic change was made. The review/fix cap was surfaced before this approved continuation.

Local Actions remain unavailable: the existing `act pull_request -W .github/workflows/ci.yml --dryrun` receipt exits 1 because the installed parser rejects `concurrency.queue`. The workflow is unchanged; the known limitation was reused without another unchanged retry or a CI workaround. Hosted receipts below are actual required proof.

## Independent review and exact-head binding

| Review | Scope and head | Result |
|---|---|---|
| Whole-phase pass 1 | Approved main through integrated candidate | One rationale-integrity warning: a substring assertion could accept a contradictory SEC-01 claim |
| Whole-phase pass 2 | Final rationale pin and bounded refactor at `1b2b2812e9c4023b858a95ec19c6229c3ffdf1bf` | Warning resolved; no remaining findings |
| Owner-approved focused two-tag delta | `1b2b281..93fe204` | PASS, no findings; exactly two floor annotations; no assertion/body change |
| Owner-approved focused policy delta, after broad local green | `93fe204..a90ef1d` | PASS, no findings; symmetric lane policy, wrong-lane and unrelated-tag controls |

The two whole-phase passes consumed exact-hash semantic records and archive metadata, not reopened OTP bodies. They supported the retained callback-front decision and verified that exactly two archive members were added while all prior source members remained byte-identical. The exact rationale pin rejects a false runtime-SEC-01 claim. The focused delta reviews compose through the actual final head; no third whole-phase audit occurred. Raw results are `plan03-independent-review-pass{1,2}.json`, `plan03-independent-two-tag-delta-review.json` and `plan03-independent-final-policy-review.json` in the ignored execution directory.

The owner's recorded answers were “Allow one focused review of the two-tag fix (Recommended)” and “Allow the bounded policy fix and focused review (Recommended).” Their immutable intent captures are reserved as INT-20261111-09 and INT-20261111-10 in local post-CI bookkeeping. Neither grants merge authority.

| Final reviewed/tested file | SHA-256 |
|---|---|
| `test/support/sweep_evidence.ex` | `a2e2ec0386abcd16fd7f21ef6b8b1380af08f4a0ea6c7f2e97f38ca5536c4b12` |
| `test/contract/tier_sweep_test.exs` | `88dcf6ea20fd8cb5c7797156628578c379de3ba82e64dcb033dc9447edfa8fb0` |
| `test/contract/banned_calls_test.exs` | `ca63b378805ee696e90405e48215da74384f2bfd231b628ef3d269ec61f01ed9` |
| `test/test_helper.exs` | `29471c75f73cdb827eeb661a395c28377bb384e4fc60718b646e104b139aceab` |
| `test/contract/ci_shape_test.exs` | `ab72cb189ca09da4098817b7722227ddfa0ffdc3d1be82f6d127a9ac4dfbb1ba` |
| `test/fixtures/guards/exact_sources.tar.gz` | `7d4bd66fe72224cf49f849148b5e737443588ca66c12873938bfa30fa3d0ea58` |

## Threat mitigation evidence

These are static implementation/candidate mitigations, not runtime safety or completed delivery.

| Threat | Actual evidence and remaining boundary |
|---|---|
| T-1-01 core archive/citations | Exact refs/hash/size and archive-only citation controls; missing/wrong-lane/altered-member negatives; Plan 01 full source review; final core suite passed |
| T-1-02 callback/native influence | Core input/service/destination/callback/fixed-driver trace; uncalled forms; callback bodies/native internals remain outside proof |
| T-1-03 graph-only semantic claim | Hash-scoped body findings and unsupported-finding negatives; dynamic callers remain explicitly unknown |
| T-1-04 core guard/lib collision | No new active guard; benign controls and protected-path scan; any future real collision retains owner remedy stop |
| T-1-05 floor identity | Independent floor full source review, exact archive entry and cross-lane substitution negatives; final floor suite passed |
| T-1-06 floor partition/witness | Complete matcher set, hash/citation/omission/duplicate/permutation negatives, individual removal and overlap controls |
| T-1-07 floor callback influence | Exact floor body/input trace to caller callback and fixed native boundary; compile-only forms never invoked |
| T-1-08 floor guard/lib collision | No new active guard, benign controls and unchanged protected paths; actual collision stop preserved |
| T-1-09 integration tampering | Both lane findings, live selected/remainder equality, full original/outside mapping preservation, wrong-lane/omission/overlap/permutation negatives, exact rationale pin; independent review passed |
| T-1-10 incomplete guard forms | No new guard justified; individual retained-matcher removal and real uncalled direct/capture/apply/source/benign controls passed on both lanes |
| T-1-11 production collision | No new pattern or production change; no selected call found in lib; explanation and Macro safety stops unchanged |
| T-1-12 candidate spoofing | Exact-head local sidecars, composed independent review, PR head and all five hosted successes; owner merge approval and post-plan verify/ship still pending |
| T-1-13 receipts/cost | Actual exits, UTC windows, source identities, raw review results, PR/run/job URLs and measured diff proxy; no fabricated harness-token measurement |
| T-1-14 broader completion | Only EX-010 advances; all outside-row owners, aggregate/installed-wide remainder, skeleton gate and SEC-01 future controls/property owner remain open; no automatic phase or milestone |
| T-1-SC package integrity | No install/new dependency; offline lane copies and unchanged dependency/config files |

## Published candidate and hosted receipts

[PR #85](https://github.com/szTheory/fablebook/pull/85) is OPEN at `a90ef1dfe7bad10ac3d303b82f8ba7b32c949745`, based on approved main `1fb61faf700db5398d3174d94a967a9199b89a85`. [Run 43124394402](https://github.com/szTheory/fablebook/actions/runs/43124394402) completed successfully, 2026-11-12T00:03:05Z–00:13:33Z. Fresh `gh pr checks 85 --required` exited 0; the configured required `ci-gate` succeeded, and the plan's five named jobs were each observed successful:

| Hosted check | Result | Job duration |
|---|---|---:|
| [core](https://github.com/szTheory/fablebook/actions/runs/43124394402/job/130872670177) | success | 619s |
| [floor](https://github.com/szTheory/fablebook/actions/runs/43124394402/job/130872670551) | success | 518s |
| [Dialyzer](https://github.com/szTheory/fablebook/actions/runs/43124394402/job/130872670605) | success | 23s |
| [security](https://github.com/szTheory/fablebook/actions/runs/43124394402/job/130872670464) | success | 30s |
| [ci-gate](https://github.com/szTheory/fablebook/actions/runs/43124394402/job/130877084474) | success | 3s |

Nightly and scheduled CI-health jobs were correctly skipped for this ordinary PR; no missing required check is called a pass. Full observed job/step timestamps, PR identity and required-check output are saved in `plan03-hosted-candidate-receipt.json`.

The published, reviewed and tested head is the SHA above. This final candidate receipt and summary are post-CI local documentation bookkeeping for the next substantive push; they do not claim hosted CI for a later local metadata commit. The six guarded file hashes above remain the binding. No receipt-only push, merge or production release is authorized by this record.

## Cost, efficiency and bounded handoff

Task 1 ran 2026-11-11T22:45:40Z–22:55:40Z. Task 2 began 22:56:35Z; its final local checks ended 23:56:24Z and hosted acceptance ended 2026-11-12T00:13:33Z. Hosted wait was 628s from run creation to completion. Historical failed full core/floor test intervals total 1,215.3s; these failures exposed lane-selection wiring, not product-code regressions. Source interpretation consumed zero full OTP files in integration and reused the bounded findings allowance with the full planned reserve. Actual harness-token/context use is unavailable; summary actuals use measured textual diff characters divided by four.

The measured hosted critical path was core: 603s in `mix ci`, versus floor's 497s test step. Setup took 10s core / 9s floor; Dialyzer reused its existing PLT cache. The current run and existing CI-history evidence do not establish a safe workflow/cache/concurrency change inside this contract-only scope. Timing remains a visible feedback objective, not a weakened correctness gate.

Concrete lesson: when test selection changes, cheap strict lint and CI-shape checks on both affected lanes must precede expensive graph/full suites. Run the one final focused review after broad local green. This continuation followed that order after the owner approved the bounded remedy; no new cache, concurrency, dependency or workflow was introduced.

Implementation is complete; delivery is pending. Next the parent continues the active `$gsd-execute-phase 1` at the shared post-plan verification pipeline for the single independent technical report, then ship preflight and the existing exact-candidate owner merge decision. The owner is not being asked for routine checks. No merge, requirement closure, aggregate/skeleton/SEC-01 completion or later scope is implied. The separate brand intake remains on its own remote branch and is not part of this candidate.
