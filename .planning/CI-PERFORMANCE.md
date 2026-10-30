# CI performance receipt

Owner direction: INT-20261029-09. Optimize measured recurring cost while preserving the existing gates, supported lanes and contract-test separation.

Measured PR head `c314d7308a80f68a28bba5661224740ad5ea4dbe`: [green run 40991600394](https://github.com/szTheory/fablebook/actions/runs/40991600394).

| Job | Wall time | Largest relevant step |
|---|---:|---|
| floor | 68 s | Full floor tests: 48 s; setup: 14 s |
| core | 46 s | mix ci: 33 s; setup: 9 s |
| security | 29 s | setup: 12 s |
| dialyzer | 20 s | setup: 10 s; analysis: 3 s |
| ci-gate | 3 s | Result aggregation |

Existing live seven-day timing receipt: n=41, p50=63 s, p95=122 s. Full measurements are in the Phase 1 `01-LIVE-EVIDENCE.json`. The current latency is comfortably below the 420/600-second budgets.

## Inexpensive opportunities

1. **Batch pushes and receipts.** Avoid a second CI run merely to commit the first run's URL. Record stable PR/check links before the final push and report final results in PR metadata. Preserve checks on every PR; reduce redundant pushes rather than introducing path-based skips.
2. **Release mutation-fixture concurrency.** `test/contract/hex_publish_test.exs` runs each generated mutation serially inside one ExUnit module. Each mutation reruns ancestry and recovery shell cases in fresh git repos. Local profiling found mutation cases around 1.1–2.0 s each among the slowest tests. A separate contract-test-only change could run these independent fixtures with bounded concurrency and unique directories while preserving every mutation and exactly-one-rule assertion. Measure both lanes before keeping it; no speedup is claimed yet.
3. **Sweep derived data.** `tier_sweep_test.exs` already builds its graph in setup_all. The boundary test repeats delegate/front-of-barrier derivations through multiple callers. If profiling during Phase 01.1.1.1 shows material cost, compute identical derived data once in the test context. Preserve fresh graph construction for each toolchain/dependency set. This is a candidate, not a measured improvement.

Local profile: `ASDF_ERLANG_VERSION=29.1.1 mix test --warnings-as-errors --include prod_guard --include release --slowest 10` — 257 passed, 62.8 s. Profiling forces serial module execution (`max_cases: 1`), so its total is not comparable to normal CI. The prod-guard integration was about 5.1 s; release mutation cases dominated the remaining slow-test list. Security or Dialyzer micro-optimizations would not shorten the currently measured floor critical path.

References: [ExUnit concurrency model](https://ex-unit.hexdocs.pm/1.18.4/ExUnit.html), [GitHub cache behavior and trust constraints](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching). Exact toolchain/lock caches and clean release builds already exist. No CI workflow or guarded implementation was changed by this investigation.

## Next work

Merge PR #22 after its final head is green. The Monday timing observation stays pending under the existing scheduled job; it is not a wait condition for starting independent planning. Phase 01.1.1 is verified, so its explicitly assigned successor is ready for `$gsd-plan-phase 01.1.1.1`. Parent Phase 1/01.1 canonical reports still need reconciliation before those parents are declared complete; do not create duplicate fixes for already resolved findings.
