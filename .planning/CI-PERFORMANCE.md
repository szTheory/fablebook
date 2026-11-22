# CI and release efficiency

Owner direction: INT-20261029-08, INT-20261029-09, INT-20261118-01, and [INT-20261120-13](intent/sources/2026-11-20-13-automated-verification-and-resource-hygiene.md). This is the standing home for CI/CD timing reviews, measured opportunities, and resolved performance decisions. Review it after each completed CI or release/CD run; use measured history, preserve quality, and do not trigger a run just to produce a receipt.

## Operating policy

1. After each completed CI run and release/CD run, review job and step durations, the critical path, runner time, repeated setup or work, retries, serialization, and evidence-output volume. Review several comparable runs before treating one slow result as a trend.
2. Improve recurring feedback time only when there is a measured benefit. Keep every supported runtime lane and the same behavior, security, publication, and recovery guarantees. Record a useful result or why no change is justified; do not create a CI run just to write down its URL.
3. Prefer removing duplicate work and avoidable waits. Do not add caches, concurrency, dependencies, trigger skips, or weaker checks by default. Demonstrate that the optimization preserves trust boundaries and coverage before keeping it.
4. Put checks in CI when stable behavior needs protection on recurring changes. Use local or throwaway checks for one-off investigations and historical evidence. A useful check does not automatically belong in CI.
5. Keep workflow timing and quality budgets visible. The scheduled `ci-health` job is the rolling signal; investigate a repeated regression rather than reacting to one noisy run. Batch receipts with the substantive PR and link the measured run there.

## Assessment: phase 01.1.1.3.1.1

The exact PR head `1180b4da6f7761c77b72439b65f438240a5baba5` passed [CI run 41249965688](https://github.com/szTheory/fablebook/actions/runs/41249965688). The required jobs ran concurrently. Core took 7m53s, floor took 10m16s, and the run reached its gate in 10m23s. Setup was about 9–12 seconds per job; the floor test command itself took 9m56s. Security, Dialyzer, and gate jobs took about 24s, 26s, and 2s respectively.

The run emitted a 63.4 MB floor job log. Its installed-runtime receipt reported `graph_ms=370589` (about 6m11s), versus `xref_ms=7946`, `inspection_ms=6990`, `discovery_ms=113`, and `source_scan_ms=79`. The core and floor suites each build their exact-lane graph. Six recent CI runs on 2026-10-31 (five PR runs and one post-merge push) reached `ci-gate` in 488–623 seconds, so the longer duration recurred across this phase's changes. These measurements show where to investigate; they do not by themselves prove which graph operation dominates or justify skipping either lane.

**Follow-up:** profile the graph traversal and projection work in `test/contract/tier_sweep_test.exs`, and assess whether full inventory evidence can be stored without streaming every row into normal CI logs. Keep the exact core/floor inventories, failure controls, and verdicts. Compare the same outputs and critical-path timings on both lanes before retaining an optimization. No speedup or coverage reduction is claimed yet.

**Workflow review:** CI's required jobs already run concurrently; setup is not the material cost in this run. The release path's build → publish → smoke → finalize ordering carries the tested artifact and checksum into publication, verifies the published package in both lanes, and only then makes the release public. No safe release/CD serialization reduction was evident from the workflow inspection; record timings after the next relevant release run.

## Existing measured opportunities

- **Batch pushes and receipts.** Avoid a second CI run just to commit the first run's URL. Preserve required checks on each PR and link final evidence in the PR.
- **Release mutation fixtures.** Earlier local profiling found independent mutations in `test/contract/hex_publish_test.exs` among the slowest tests. Bounded concurrency is still only a candidate; measure both lanes and preserve every mutation and exactly-one-rule assertion before changing it.
- **Tier-sweep derived data.** Reuse equivalent setup-derived values where profiling shows material repeated work, while still constructing fresh graphs for each runtime and dependency set.

## Historical baseline

PR head `c314d7308a80f68a28bba5661224740ad5ea4dbe`, [run 40991600394](https://github.com/szTheory/fablebook/actions/runs/40991600394), recorded floor at 68s and core at 46s. The then-current seven-day receipt was n=41, p50=63s, p95=122s. That run predates the full installed-runtime graph work measured above, so it is a historical comparison rather than a controlled same-code benchmark. The timing budget remains p50 ≤420s and p95 ≤600s over at least 10 eligible runs, as enforced by `bin/ci_health`.

## Local exact-lane assessment: phase 01.1.1.3.1.2

The required local core `mix ci` run in `MIX_ENV=test` completed with 318 passing tests; ExUnit took 520.2s and the captured full log was 60,436,908 bytes. Its installed-runtime metrics reported `graph_ms=158290`, `xref_ms=18095`, `inspection_ms=3051`, and `source_scan_ms=395`. The required floor prod_guard-inclusive run completed with 318 tests, 0 failures and 4 excluded; ExUnit took 549.9s and the captured log was 54,876,794 bytes. Its metrics reported `graph_ms=148566`, `xref_ms=5323`, `inspection_ms=3067`, and `source_scan_ms=420`.

Focused core receipt and ownership selectors took 269.8s (1 pass) and 399.4s (11 passes), respectively; both include exact graph setup, so these totals should not be added to the full CI runs as recurring job time. The local results confirm that graph construction and large inventory output are material costs. No graph or log optimization was made in this phase; the standing follow-up to profile the graph and assess contained inventory output remains open. These local measurements do not update the remote seven-day timing budget or establish a trend.

## Remote exact-head timing: Plan 01.1.1.3.1.2-05

PR #32 head `845de26003bbaeb8a4ca60ef88c693e819679dea` passed [run 41355007460](https://github.com/szTheory/fablebook/actions/runs/41355007460), and the same run was independently bound to merge `5e89d970d763ec4ac05acf037d39c58575347b68`. The core `mix ci` step took 730 s (748 s total job); the floor prod_guard test took 689 s (715 s total job). Dialyzer and security took 25 s and 35 s; `ci-gate` took 2 s. Core and floor passed, as did dialyzer, security, and ci-gate; ci-health and nightly were skipped. The test steps exceeded the existing 420/600 s target window. The new focused receipt selectors add 8.3–8.4 s, within the 30 s increment policy. Local full-run times were 520 s core and 550 s floor; recent CI totals ranged 528–623 s. The generated receipts contain 318,402 core inventory bytes, 292,683 floor inventory bytes, and 2,011 observed assignments; captured local full logs were 60,436,908 and 54,876,794 bytes. The measured evidence points to the established inventory graph and runner variance, so this phase made no timing-driven code change. Follow up by profiling graph construction and reducing contained inventory-log volume without weakening receipts.

## Local rolling CI-health check — 2026-11-01

Ran the actual `bin/ci_health` calculation against GitHub's read APIs with a temporary `gh` wrapper that allowed the required GETs and issue lookup but blocked issue comments/creation. The current seven-day PR sample is **n=72, p50=76 s, p95=564 s**, within the 420 s / 600 s budgets; the main-branch required-check ruleset check also passed. The script attempted its normal timing comment, which the wrapper suppressed; no GitHub issue was changed.

This confirms that the rolling timing calculation can be checked locally without waiting for Monday. It does not satisfy Phase 01 UAT test 13, which specifically requires the scheduled workflow run and its published issue comment. That publication gate does not block independently owned planning or implementation work.

**Local command follow-up:** `bin/ci_health --dry-run` now performs the same Actions and ruleset reads while printing any issue publication it would make instead of looking up, creating, or commenting on issues. The documented command was run live under macOS Bash 3.2 and returned the same n=72, p50=76s, p95=564s sample without issue writes. Its focused contract tests passed on Elixir 1.20.4 / OTP 29.1.1; the repository's exact OTP 29.1.2 install remains incomplete on this workstation. The command and tests are merged in [PR #34](https://github.com/szTheory/fablebook/pull/34).


## Local profile: pending caller-chain inventory

### Exact-head current-main baseline

Before the indexed change, PR #35 head `76d1a450c41dab8c5a84fcc39e15f7c982b237cc` passed [CI run 41376744055](https://github.com/szTheory/fablebook/actions/runs/41376744055) and was merged as `1d971c9663f3eb376daa69ab5ebd689d190e4ce0`. The core `mix ci` step took 744 s (765 s total job); the floor prod_guard test step took 577 s (597 s total job). The required security, Dialyzer, and gate checks passed in 31 s, 24 s, and 4 s. Compare the optimized PR's exact-head core and floor step times against these as one baseline sample; runner variance means this is directional evidence, not a stable speedup estimate.

A focused core profile confirmed the expensive part of the installed-OTP graph. With 236,176 call edges and 1,078 pending MFAs, the old `pending_inventory_records/…` path repeatedly scanned the full edge list for each caller hop. One instrumented run attributed 136.7 seconds of a 157.2-second graph build to this step; a repeat attributed 166.0 seconds of a 189.8-second graph build.

A scoped test-only change builds a map from caller/callee function pairs to the lowest caller MFA once, preserving the existing module/function/arity sort rule and missing-edge failure. Across two same-command local core profile pairs, graph time changed from 151.014 s to 19.455 s and from 189.763 s to 25.130 s, roughly 87% less graph time. The indexed full `tier_sweep_test.exs` profile also measured 27.680 s for graph construction. These are local graph-phase timings; they do not establish the end-to-end CI speedup. The isolated change keeps both runtime lanes, receipt checks, and all current CI jobs.

The pending-MFA identities and all non-path inventory rows matched across baseline and indexed runs. Caller-chain paths differed between independent runs with both the old and new implementation (70 pending rows in the old pair; 31 in the indexed pair). That observed variation means a receipt hash is not a byte-for-byte cross-run equivalence check for caller paths. The untagged core tier-sweep module passed 53 tests, and the focused index fixture passed on both core and floor (one selected, 52 excluded in each lane; graph setup measured 20.932 s and 20.032 s). It pins duplicate handling, lowest-arity tie-breaking against the previous scan semantics, start-arity preservation, single-node fallback, and missing-edge failure. PR CI must still pass on both exact lanes before retaining the change; compare its core/floor job durations with the current-main baseline then.

No dependency, cache, workflow, runtime lane, security check, or test exclusion changed. The optimization is in an isolated branch pending its exact-head CI run.

## Phase 2 delivery timing review — 2026-11-13

The prerequisite PR #87's post-merge main run [43445896621](https://github.com/szTheory/fablebook/actions/runs/43445896621) completed with core in 10m27s and floor in 10m14s; both required lanes overlapped. PR #88's final-head run [43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316) completed with core in 7m54s and floor in 12m12s, also in parallel.

After PR #88 merged, main run [43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473) completed in about 11m36s. Core ran for 10m10s (the mix ci step took 9m49s); floor ran for 11m28s (the prod_guard test step took 11m06s). They overlapped from 15:22:08Z; floor was the critical path, with ci-gate finishing five seconds later. Dialyzer took 19s, security 29s, and the gate 3s. ci-health and nightly were skipped. The paired release-please workflow completed successfully; no package publish or deployment was part of this run.

Core and floor already run concurrently, setup was brief, and these few samples do not establish a repeatable trend that justifies removing work or changing coverage. The latest floor test exceeded the 600s timing objective, but timing-only overages remain non-blocking under the existing policy. No safe low-risk CI change is justified by these measurements; keep both lanes and their current gates.

## Local act preflight — 2026-11-18

The PR job subset was attempted with `act` 0.2.87. The installed version could not parse the unrelated scheduled/manual `ci-health` job's `concurrency.queue` field, so a temporary copy excluded only that job. The first run was blocked by the sandbox rejecting writes to the default `~/.cache/act`; a retry used a scoped cache under `/private/tmp` and reused the existing runner image. Jobs then failed during `setup-beam`: `act` reported ARM64 OTP builds inside the requested amd64 runner container (`erlexec` was not found). The test, Dialyzer and security steps did not run, so this is an `act` environment limitation, not a candidate result. No project workflow was changed. Do not spend another cycle coercing this local runner; the existing focused/core/floor receipts cover the phase code, and hosted PR CI remains the required Linux runner evidence.

## Phase 3 recovery iteration review — 2026-11-19

The local verification order now has a concrete fast-feedback lesson. Run the Phase 3/4 validator self-tests and cross-artifact checks first, then formatting/Credo and the focused planning-intent corpus check, then the focused core/floor selections, and only then the full core and floor lanes. The focused intent check took 14.6s for 22 passing checks; the core CI run took 413s total, and a prior failed core run spent about 419s before finding malformed intent frontmatter. Running the intent check first could have caught that failure roughly 404s earlier; this is an estimate from those two recorded durations, not a repeat benchmark. The earlier Credo failure was a formatting-only issue and likewise belongs before long test stages.

Current local measurements: the core focused selection took 60s, floor focused took 53.6s, core CI took 413s total (403.5s test stage), and the full floor suite took 403.2s. The exact-head hosted run is recorded below. The `act` setup failure above is a runner/toolchain mismatch; hosted Actions is the useful evidence, so no further local `act` attempt is planned.

## Hosted PR #90 final-head CI — 2026-11-19

Candidate `def07c39af01f95952070ed5156f0d605c399a7a` passed [CI run 44438380336](https://github.com/szTheory/fablebook/actions/runs/44438380336). Core ran for 12m47s (the `mix ci` step took 11m45s); floor ran concurrently for 9m42s (the prod_guard test step took 8m59s). Core was the critical path. Dialyzer took 2m29s, security 59s, and `ci-gate` 5s; `ci-health` and `nightly` were skipped. The jobs started promptly, so queueing was not the delay.

This core job is slower than the previous 10m10s hosted core sample and the 413s local run, while floor is faster than the previous 11m28s hosted floor sample. It is one run with runner variance, not evidence of a recurring regression. Core and floor already overlap, setup is small next to the test steps, and every required lane passed. No safe cache, concurrency, dependency, or coverage change is justified; preserve the current checks and compare future exact-head runs before acting on the timing difference.

## Hosted PR #91 final-head CI — 2026-11-19

Exact PR head `3d72641d978c5a0cbce62219590227a7d0efbea7` passed [CI run 44451045250](https://github.com/szTheory/fablebook/actions/runs/44451045250), then squash-merged as `b1cd9b410b556608c87047bd871fa38bf954e32e`. Core took 10m06s and floor 11m28s while running concurrently; floor was the critical path. Dialyzer took 24s, security 1m11s, and `ci-gate` 2s. `ci-health` and `nightly` were skipped. Jobs started promptly, so queueing was not the delay.

Compared with PR #90, core was faster and floor was slower; these two samples do not show a repeatable regression. The lanes still overlap and all required checks passed, so no safe cache, concurrency, dependency, or coverage change is justified. The ship-note commit's `[ci skip]` initially left the new PR head with zero checks, requiring the documented recovery commit to trigger CI. The squash commit inherited that skip token, so no separate main push run was created. The final PR-head CI covered the exact same tree as the squash merge; no additional main rerun was needed.

## Hosted PR #92 final-head CI — 2026-11-19

Exact PR head `fef3fda20633fb66bd2e968870146d54bd7b2cbd` passed [run 44475714163](https://github.com/szTheory/fablebook/actions/runs/44475714163), then squash-merged as `df9bba9fbf5fa6efd665e7d5bfea7e827d3035c0`. The run reached its final gate in about 9m32s. Core took 9m25s (`mix ci` 9m05s); floor took 9m17s (floor test step 8m53s). They overlapped and core was the critical path. Dialyzer took 22s, security 36s, and `ci-gate` 3s; `ci-health` and `nightly` were skipped. Jobs started promptly, with little queue or setup time.

Against PR #91, core improved from 10m06s and floor from 11m28s, but one run per change is not enough to infer a trend. Both lanes already overlap, and the test steps dominate. All required checks passed; no safe CI change is justified by this sample. Keep the checks and compare future runs before acting on timing.

## Hosted PR #93 initial exact-head CI — 2026-11-19

Head `faf84e257292ae34f4d1ca77ac8fad5eb18d39f5` failed [run 44562711455](https://github.com/szTheory/fablebook/actions/runs/44562711455) in 12m50s, including about 24s of queue time. Core ran 8m52s and floor 12m21s in parallel; floor was the critical path. Security took 33s and Dialyzer 25s. Core and floor failed because guard tests still read Phase 3 evidence from the former active-phase path after the v0.4 closeout moved it to the milestone archive. Core also found missing metadata on two new intent records; after adding the required frontmatter locally, the focused intent suite passed 22/22 in 18.1s.

This run is slower than the latest successful main runs (8m44s, 10m51s and 10m56s) and PR #92 (9m32s), but it is one sample and the long-running core/floor checks already overlap. The failure is a path compatibility issue, not a safe basis for dropping or reducing coverage. No pipeline change is justified; batch the next full run with any separately authorized compatibility fix.

## Hosted PR #94 final-head CI — 2026-11-19

Exact compatibility PR head `2165c89843837705670a5b54756705ab3eee4e0a` passed [CI run 44582183055](https://github.com/szTheory/fablebook/actions/runs/44582183055). The run reached `ci-gate` in 9m20s with negligible queue time. Core took 8m50s and floor 9m12s while running concurrently; floor was the critical path. Security took 36s, Dialyzer 21s, and `ci-gate` 3s. `nightly` and `ci-health` were skipped as configured.

Compared with PR #92, core improved by 35s and floor by 5s; one run is not enough to infer a recurring improvement. Core and floor already overlap, and their test steps dominate setup. All required checks passed with full coverage, so no safe workflow change is indicated. The two earlier PR #94 attempts found a provenance-helper identity change and an unsupported ExUnit cleanup macro; the final candidate preserves the historical helper bytes and uses `on_exit` cleanup.

PR #94 was squash-merged as `6ca51ac` after the exact-head checks passed. No additional main run was needed because the required PR checks covered the merged tree.

## Hosted PR #93 final-head CI — 2026-11-19

The first reconciled Phase 6 head `31cd185` failed [run 44586751740](https://github.com/szTheory/fablebook/actions/runs/44586751740) in about 9m58s. Core took 8m33s and floor 9m52s concurrently; both failed the same historical trace-path assertion. Security and Dialyzer passed. The failure was caused by a test using the Phase 4 archive's storage path as a saved provenance value; the historical helper correctly expects the pre-archive path. A focused local regression selection passed after the test separated those values.

Corrected PR #93 head `3970a381945cfcf63eb69c456a5b2a7465d8352d` passed [run 44589600030](https://github.com/szTheory/fablebook/actions/runs/44589600030) in 11m33s. Core took 8m46s and floor 11m25s while running concurrently; floor was the critical path. Security and Dialyzer took 35s each, and `ci-gate` took 3s. `ci-health` and `nightly` were skipped as configured. The run started promptly. PR #93 was squash-merged as `b8852ac22aac1cb2b8151d85b189889ca0774aa8`; the reviewed head and merged tree are identical.

Compared with PR #94, the corrected PR #93 run was slower, while the initial run failed before completion. The two full-lane samples do not establish a recurring regression. Core and floor already overlap, the test steps dominate, and all required checks passed on the final head. No safe cache, concurrency, dependency, trigger, or coverage change is justified.

## Local v0.6 Phase 7 final core CI — 2026-11-20

The final `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci` run passed 461 tests with 10 excluded by the core lane configuration. ExUnit reported 440.3s; the full command also ran Credo, cycle checks, doc generation, and the guard acceptance tests. The earlier 413s local sample is recorded as total command time, so these values are not directly comparable. This is one final sample, not evidence of a timing trend. No workflow change is justified; the exact evidence and complete lane checks remain in place.


## Hosted Phase 7 delivery and post-merge CI — 2026-11-20

The reviewed PR #96 head `d74b21a07a67d4b526576fc09833ffafe99cded1` passed [hosted run 44827619883](https://github.com/szTheory/fablebook/actions/runs/44827619883) in 9m06s. Required jobs ran concurrently: core 8m58s, floor 8m43s, Dialyzer 2m41s, security 55s, and `ci-gate` 3s. PR #96 merged as `0ea95d4c8cdf6ce9a1af363c7ea0033d632b0e6d`.

Post-merge main CI [run 44828949627](https://github.com/szTheory/fablebook/actions/runs/44828949627) passed in 10m52s: core 10m44s, floor 9m01s, Dialyzer 3m31s, security 51s, and `ci-gate` 3s. Both runs started promptly; core or floor test work dominated, with no recurring queue or serialization delay. This candidate/main pair is too small to justify a CI change, and no quality or coverage reduction is indicated.

## Hosted PR #98 initial planning-head CI — 2026-11-21

Planning-only head `27262d8018baffc0893790270d675490d40f223a` failed [run 44870620607](https://github.com/szTheory/fablebook/actions/runs/44870620607) in about 9m18s. Core and floor ran concurrently: core took 8m43s total (`mix ci` 8m25s), and floor took 9m11s total (floor test step 8m44s). Dialyzer took 27s, security 36s, and the gate 5s; the jobs started together without a material queue. Both test lanes completed their full suites and exposed the same project-citation failure: a shorthand intent range and a plan reference to a not-yet-created ADR. The floor lane found both citation issues. This is a planning-document defect, not a product or runtime failure; the focused intent contract passes after correcting those references. The existing core and floor suites dominate elapsed time and already overlap. One failed run gives no measured basis for a safe CI change, so retain the full checks and record no optimization.

## Hosted PR #98 successful planning delivery and main CI — 2026-11-21

Corrected planning head `9511cf6738c0bbccd3b080641b5a5d305a50d892` passed [exact-head CI run 44872457695](https://github.com/szTheory/fablebook/actions/runs/44872457695) in 10m56s. The jobs started about 2 seconds after the run: core took 10m48s (`mix ci` 10m30s), floor took 9m24s (prod-guard test 8m59s), Dialyzer 29s, security 35s, and `ci-gate` 3s. Core was the critical path; core and floor overlapped.

After PR #98 merged as `a0db257f90f293dfd97a7a2653d1bda7ec00de95`, [main CI run 44873452900](https://github.com/szTheory/fablebook/actions/runs/44873452900) passed in 11m44s. The jobs started about 2 seconds after creation: floor took 11m36s (test step 11m11s), core 11m15s (`mix ci` 10m52s), Dialyzer 28s, security 34s, and `ci-gate` 4s. Floor was the critical path. The separate release-please workflow completed in 37s with publication skipped; no release or deploy occurred.

These planning-only runs expose test execution as the dominant time. The required lanes already overlap, setup stayed at 9–13 seconds, and queue time was negligible. This pair does not justify changing caching, workflow structure, or coverage.

## Hosted PR #99 router implementation and merge — 2026-11-21

Router-only PR #99 head `1c786ffdb7b10c681390e9fe4238c2d7d2184019` passed [required CI run 44874757036](https://github.com/szTheory/fablebook/actions/runs/44874757036) and was squash-merged as `a60d21b8cf513f400fee3363c3f6b6aa23031857`. Queue time was about 3 seconds. Core took 8m38s (`mix ci` 8m19s); floor took 8m55s (prod-guard test 8m23s); Dialyzer took 29s, security 36s, and `ci-gate` 3s. The gate finished 9m03s after run creation, with floor as the critical path. Core and floor ran concurrently; setup was 7–11 seconds.

The post-merge `release-please` workflow [run 44875504890](https://github.com/szTheory/fablebook/actions/runs/44875504890) completed in 30 seconds; its publish job was skipped. No separate main CI workflow ran on this merge, and no package release or deployment occurred. The exact PR-head checks cover the merged router tree.

The local full core lane passed before publication: 464 passed, 10 configured exclusions, with 397.9 seconds in ExUnit. The local `act` environment stop remains in effect and was not retried.

Across the completed PR #98 and #99 samples, setup and queue time are small relative to test steps. Core and floor already overlap. Timing varies between runs and does not support a safe CI change; retain all lanes and coverage.

## Local Plan 08-03 core lane — 2026-11-21

The test-only macro branch passed `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci`: 464 passed, 10 configured exclusions. ExUnit took 1,164.3s (109.4s async and 1,054.9s sync). This is slower than the earlier local Phase 8 core result of 397.9s and the hosted core job for PR #99 (8m38s). The available output shows test execution dominates, but it does not identify a repeatable per-test regression; local and hosted runtimes also differ. The run streamed over 59 MB of inventory output into the tool capture, consistent with the already recorded large-evidence behavior.

This is one slower local sample, not evidence for changing the workflow or reducing checks. Keep the complete core and floor lanes; revisit only if comparable exact-lane measurements show the overrun is recurring and a focused profile identifies safe redundant work.

## Hosted Phase 8 contract and fixture gates — 2026-11-21

The separate macro contract PR #100 head `06b7cb4422241585356efc96ae757ab4aff73b46` passed [exact-head CI run 44879867181](https://github.com/szTheory/fablebook/actions/runs/44879867181). Core took 10m56s (`mix ci` 10m40s); floor took 9m28s (the prod_guard test step 9m06s); Dialyzer took 27s, security 29s, and `ci-gate` 4s. Core and floor ran concurrently; core was the candidate critical path. The test-only PR merged as `2b05a2ee302c0eacd8d53e03c5694678d01a55cc`. Post-merge main CI [run 44880742370](https://github.com/szTheory/fablebook/actions/runs/44880742370) passed: core took 8m32s (`mix ci` 8m13s), floor 10m39s (prod_guard test 10m13s), Dialyzer 22s, security 27s, and the gate 3s. Floor was the main critical path. The paired release-please run [44880742446](https://github.com/szTheory/fablebook/actions/runs/44880742446) completed in about 33s; publication was skipped.

Fixture-control PR #101 head `1380a45ec188151ad755c05862f719198d2cce7e` passed [exact-head CI run 44882143058](https://github.com/szTheory/fablebook/actions/runs/44882143058). Core took 8m38s (`mix ci` 8m18s); floor took 8m47s (the prod_guard test step 8m19s); Dialyzer took 24s, security 35s, and `ci-gate` 5s. The jobs started promptly and overlapped. The PR merged as `5b08774fa915c53d54fcbdcb34c0844ec969f5eb`. Post-merge [main CI run 44884141633](https://github.com/szTheory/fablebook/actions/runs/44884141633) passed: core took 8m20s (`mix ci` 7m56s), floor 11m12s (prod_guard test 10m47s), Dialyzer 26s, security 23s, and gate 2s. Core/floor overlapped, with floor setting the 11m17s critical path. The paired release-please run [44884141744](https://github.com/szTheory/fablebook/actions/runs/44884141744) completed in 39s; publication was skipped.

Across these two candidate/main pairs, core and floor already run concurrently, queues and setup are small, and full-lane tests dominate. The main floor duration varied from 10m13s to 10m47s; two samples are not enough to establish a recurring regression or justify changing workflow structure, adding caches, or reducing coverage. Keep all required checks. The known `act` setup limitation is unchanged and was not retried.

## Local Phase 8 full-lane verification — 2026-11-21

The full core command `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci` took 7m35.62s and ran 464 tests: 463 passed, 1 failed, and 10 configured tests were excluded. The full floor prod-guard-inclusive command took 7m29.15s and ran 474 tests: 473 passed, 1 failed, and 6 configured tests were excluded. In each lane the only failure was ADR 0021's assertion against the current combined contract-test and implementation diff. ExUnit took 444.5s in core and 447.3s in floor. The full test phases dominate local elapsed time; this one pair does not establish a recurring regression.

The host-only tests completed in 0.1s with 11 passes per lane, and the core/floor production-boundary scripts passed. Current core and floor Hex audits now fail on newly published Phoenix security advisories; floor also reports MEDIUM LiveView and Plug advisories. The workflow keeps both test lanes and all security checks. Required root lockfiles remain unchanged by the active plan, so no safe pipeline optimization or quality reduction was made. The known `act` setup limitation did not change and was not retried.

## Local Phase 8 final core lane — 2026-11-22

After the Canvas readiness retry fix, `MIX_ENV=test bin/lane core mix ci`
passed 467 tests with 10 configured exclusions. ExUnit took 550.0 seconds
(116.0 seconds async and 433.9 seconds sync). The exact pinned core lane was
initialized first with `bin/lane core setup` on Elixir 1.20.4 / OTP 29.1.2.
The inventory test streamed a very large report; the tool omitted 59.4 MB from
its captured output. There is no queue time in this local run, and test
execution is the critical path.

The prior Phase 8 local core sample took 444.5 seconds in ExUnit and had one
planning-separation failure. This passing run is about 106 seconds slower, but
one local pair is not enough to distinguish added coverage, machine variance,
or a recurring regression. Hosted Phase 8 checks will provide the comparable
candidate measurement. Core and floor already overlap in hosted CI, and setup
has not been shown to dominate. No safe coverage-preserving pipeline change is
supported by this sample; keep the required lanes and the known `act` stop.
