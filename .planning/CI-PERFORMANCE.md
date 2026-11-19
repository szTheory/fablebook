# CI and release efficiency

Owner direction: INT-20261029-08, INT-20261029-09, and INT-20261118-01. This is the standing home for CI/CD timing reviews, measured opportunities, and resolved performance decisions. Review it after each completed CI or release/CD run; use measured history, preserve quality, and do not trigger a run just to produce a receipt.

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
