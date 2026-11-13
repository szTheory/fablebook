---
phase: "2"
slug: bounded-asn-1-rtt-guard-evidence
status: verified
threats_open: 0
asvs_level: 1
created: "2026-11-13"
---

# Phase 2 — Security

> Scope: static evidence and contract tests for three ASN.1 RTT functions on the pinned core and floor lanes. This review does not claim runtime safety, dynamic-caller absence, native-internals safety, complete EX-107 closure, Walking Skeleton readiness, or SEC-01 completion.

## Verdict

**VERIFIED.** Twelve of sixteen threats are closed. Four medium-severity collision threats remain open below the configured high blocking threshold, so they do not block Phase 2. The final delivery threat, `T-02-08`, is closed by the reconciled PR, merge, and hosted CI receipts below. No blocking threat remains.

The four open findings do not assert an observed collision. This phase adds no production guard, and the manual owner stop remains binding for any future guard work. Field-name assertions and documentation do not establish an executable collision handler. Runtime behavior, dynamic callers, native internals, complete EX-107 closure, Walking Skeleton readiness, and SEC-01 remain unproven.

## Trust Boundaries

| Boundary | Description | Data crossing |
|---|---|---|
| Pinned OTP source to evidence resolver | Evidence must identify the correct lane, archive bytes, source span, and digest. | Lane refs, source bytes, hashes, line spans |
| Static evidence to contract controls | Tests inspect source and literal data without invoking audited APIs, callbacks, generated code, or atom sinks. | MFA rows, citations, source snippets, control assertions |
| Existing dependencies to local tests | Only the already-declared, lockfile-pinned set may be restored for validation. | `mix.exs`, `mix.lock`, package archives |
| Candidate branch to merged main | Independent review, exact candidate CI, actual merge identity, and hosted main CI must refer to the intended delivery. | PR heads, merge commit, job receipts |

## Threat Register

| Threat ID | Severity | Component | Status | Evidence and limit |
|---|---|---|---|---|
| T-02-01 | high | Core archive resolver | closed | `02-01-SUMMARY.md`: lane, hash, containment, line-bound, and exact-span checks are covered. |
| T-02-02 | high | Core compile-only controls | closed | `02-01-SUMMARY.md`: static-only control paths avoid audited APIs, callbacks, generated code, and atom sinks. |
| T-02-03 | medium | Core guard collision | **open — below high threshold (non-blocking)** | No collision was observed and no production guard was added. `guard_matches?/2` checks caller-source substrings; it does not detect or report real `lib/` collisions. The manual owner stop remains binding for future guard work. |
| T-02-04 | high | Floor archive resolver | closed | `02-02-SUMMARY.md`: floor lane identity, digest, containment, line bounds, and exact spans are checked. |
| T-02-05 | high | Floor compile-only controls | closed | `02-02-SUMMARY.md`: controls remain static/compile-only and do not invoke audited paths. |
| T-02-06 | medium | Floor guard collision | **open — below high threshold (non-blocking)** | No collision was observed and no production guard was added. The floor evidence and controls do not implement an executable collision stop/report path. The manual owner stop remains binding. |
| T-02-07 | high | Cross-lane EX-107 partition | closed | `02-03-SUMMARY.md` and passing core/floor integration tests preserve exact membership and the separate 3/174 and 13/164/161 partitions. |
| T-02-08 | high | Candidate and main delivery evidence | **closed** | PR #87 reviewed head `2768a58a2dea1d58055c950aac2c30b3bb17e87a` passed [candidate CI 43355783802](https://github.com/szTheory/fablebook/actions/runs/43355783802), merged as `9a6f45e314f9a43a0c35fb85006d50e618f5c931`, and passed [main CI 43445896621](https://github.com/szTheory/fablebook/actions/runs/43445896621). PR #88 final reviewed head `ded4af612df3346b8516f4a027772ed3d2bbd53f` passed [exact-head CI 43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316), then merged as `3817912c861286608183c057d2e38ff7a260bd6e` and passed [main CI 43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473). All four runs completed successfully with core, floor, security, Dialyzer, and `ci-gate` passing. |
| T-02-09 | medium | Cross-lane guard collision | **open — below high threshold (non-blocking)** | `@collision_report_fields` and its equality assertion verify field names only; they do not exercise a collision-triggered stop/report path. No collision was observed and the manual owner stop remains binding. |
| T-02-10 | high | Independent partition review | closed | `02-REVIEW.md`: exact selected/complement and historical partition claims were reviewed against the approved sources. |
| T-02-11 | high | Review/correction provenance | closed | `02-REVIEW.md` and `02-04-SUMMARY.md` bind R1 to the lane-invocation correction, approved review output, focused retests, and reviewed commit `15834f4`. No source correction was warranted. |
| T-02-12 | medium | Review-discovered guard collision | **open — below high threshold (non-blocking)** | Review records a manual stop and no observed collision. An executable review-discovered collision handler is not demonstrated. No production guard was introduced; the manual owner stop remains binding. |
| T-02-13 | high | Full-check scope and lane selection | closed | `02-CANDIDATE.md` records the full local core and floor suites on the PR-shaped tested tree. Final-head CI run [43449606316](https://github.com/szTheory/fablebook/actions/runs/43449606316) and merged-main CI run [43451903473](https://github.com/szTheory/fablebook/actions/runs/43451903473) independently passed both required lanes. |
| T-02-14 | high | Local readiness and final-head handoff | closed | `02-CANDIDATE.md` identifies the exact local tested tree and separates local readiness from final candidate and merge claims. |
| T-02-15 | medium | Static verification boundary | closed | Phase artifacts preserve the explicit limits on runtime, dynamic callers, native internals, aggregate closure, Walking Skeleton, and SEC-01. |
| T-02-SC | high | Dependency installation | closed for recorded event | `02-01-SUMMARY.md` records that seven already-declared dependencies were missing, the owner approved `MIX_ENV=test mix deps.get`, and `mix.exs`/`mix.lock` hashes remained unchanged. This is not a general supply-chain audit or approval for future dependency changes. |

## Security Audit Result

The ASVS L1 read-only audit verified all 16 threat dispositions against the implementation and live delivery receipts. Twelve threats are closed; four medium collision findings remain open below the high blocking threshold. No unregistered threat flags were found. The manual collision stop and all wider evidence limits remain binding.

## Required Stops

- **Delivery stop (satisfied 2026-11-13):** PR #87 is merged, PR #88 was reconciled onto main, the final reviewed head passed hosted checks, and the actual merge plus hosted main CI receipts are recorded under T-02-08 and in `.planning/references/PHASE-DELIVERIES.json`.
- **Collision stop:** If future guard work finds a new guard matching a real `lib/` call site, stop and report the exact MFA, call site, input trace, and triggering guard for an owner decision (`02-CONTEXT.md` D-06; `02-VALIDATION.md` manual-only verification).
- Keep runtime, dynamic-caller, native-internals, full-row, Walking Skeleton, and SEC-01 conclusions open unless separately evidenced and authorized.

## Security Audit 2026-11-13

| Metric | Count |
|---|---|
| Threats found | 16 |
| Closed | 12 |
| Open | 4 |
