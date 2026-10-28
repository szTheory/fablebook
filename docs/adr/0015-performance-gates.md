# 0015. Performance: deterministic proxy gates; tail latency is a trend, not a gate

**Status:** Accepted · **Cites:** INT-20261028-01 ("99.999 … very high bar … practical")

## Context
Measuring p99.999 needs roughly 10^6 samples on quiet hardware. On shared GitHub runners it measures neighbour noise. The owner's threadline and scrypath benches already treat numbers as "evidence, not CI thresholds".

## Decision
PR gates (ExUnit `:perf` tag, about 20 s total), except the host-compile row, which runs on the nightly and release-PR lanes because it needs a forced compile of a 500-story host:

| Flow | Gate |
|---|---|
| Catalog build | t(5000)/t(500) < 15 (median of 5); 5000 scenarios ≤ 1.5 s; zero `Code` module calls during the build (traced) |
| Workbench mount (N=500) | reductions ≤ 1.25× committed reference measurement (pinned lane, keyed by OTP major) |
| Scenario render | max over 10k iterations ≤ 50 ms; reductions ≤ 1.25× reference measurement |
| Control change | WebSocket diff ≤ 4 KB per attr change; sidebar not re-sent |
| Session memory | workbench LiveView heap ≤ 3 MB after GC (N=500); 10k random events → post-GC ≤ 1.2× steady state; Fablebook-owned ETS = 0 |
| Host compile | +500 stories ≤ +15% `compile --force` (ratio); touching one component recompiles ≤ 1 story module |
| Processes | 0 added to the host supervision tree |
| Static export (v1.x) | 500 scenarios < 30 s; byte-identical across two runs |

- p50, p99, p99.9 and max are tracked in a sibling `bench/` Mix project (Benchee). Reference measurements are committed with SHA, versions and machine; the bench runs weekly as an artifact and is advisory.
- Benches carry sensitivity controls: each must detect the regression size it guards.
