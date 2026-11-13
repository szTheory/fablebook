---
phase: "2"
slug: bounded-asn-1-rtt-guard-evidence
status: open_threats
threats_open: 1
asvs_level: 1
created: "2026-11-13"
---

# Phase 2 — Security

> Scope: static evidence and contract tests for three ASN.1 RTT functions on the pinned core and floor lanes. This review does not claim runtime safety, dynamic-caller absence, native-internals safety, complete EX-107 closure, Walking Skeleton readiness, or SEC-01 completion.

## Verdict

**OPEN_THREATS.** Eleven of sixteen unique threats are closed for this phase. One high-severity delivery threat remains open because PR #87 and PR #88 are unmerged and no actual merge identity or hosted main receipt exists. The four collision threats are closed as not presently triggered: this phase adds no production guard, review found no collision, and the manual owner stop remains binding for future guard work. This does not claim that an executable collision handler was tested.

The security gate is not satisfied while `T-02-08` is open. Do not run the phase verifier or mark Phase 2 verified until delivery evidence is reconciled.

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
| T-02-03 | medium | Core guard collision | closed, not triggered | No production guard was added and review found no collision (`02-REVIEW.md`). D-06 and `02-VALIDATION.md` retain the manual stop for future guard work. The phase does not test an executable collision handler. |
| T-02-04 | high | Floor archive resolver | closed | `02-02-SUMMARY.md`: floor lane identity, digest, containment, line bounds, and exact spans are checked. |
| T-02-05 | high | Floor compile-only controls | closed | `02-02-SUMMARY.md`: controls remain static/compile-only and do not invoke audited paths. |
| T-02-06 | medium | Floor guard collision | closed, not triggered | No production guard was added and review found no collision. D-06 and the manual stop remain binding for future guard work; no executable collision handler is claimed. |
| T-02-07 | high | Cross-lane EX-107 partition | closed | `02-03-SUMMARY.md` and passing core/floor integration tests preserve exact membership and the separate 3/174 and 13/164/161 partitions. |
| T-02-08 | high | Candidate and main delivery evidence | **open** | PR #88 head `2e35c62135c436a2ef953381024f82c237db188f` passed hosted CI run [43362320210](https://github.com/szTheory/fablebook/actions/runs/43362320210), but PR #87 and #88 remain open. The local branch has two later validation-document commits; those do not change test/runtime source and do not supply a hosted receipt. Actual merge identity and hosted main CI are absent. |
| T-02-09 | medium | Cross-lane guard collision | closed, not triggered | This phase adds static source probes, not production guards; review found no collision. D-06 and the future manual owner stop remain in force. |
| T-02-10 | high | Independent partition review | closed | `02-REVIEW.md`: exact selected/complement and historical partition claims were reviewed against the approved sources. |
| T-02-11 | high | Review/correction provenance | closed | `02-REVIEW.md` and `02-04-SUMMARY.md` bind R1 to the lane-invocation correction, approved review output, focused retests, and reviewed commit `15834f4`. No source correction was warranted. |
| T-02-12 | medium | Review-discovered guard collision | closed, not triggered | Review found no collision and no production guard was introduced. The report-field assertion is not an executable handler; D-06/manual owner stop remains binding for future guard work. |
| T-02-13 | high | Full-check scope and lane selection | closed | `02-05-SUMMARY.md`: local full core and floor suites both passed on the recorded PR-shaped tested tree; hosted core/floor checks passed on the remote PR head. |
| T-02-14 | high | Local readiness and final-head handoff | closed | `02-CANDIDATE.md` identifies the exact local tested tree and separates local readiness from final candidate and merge claims. |
| T-02-15 | medium | Static verification boundary | closed | Phase artifacts preserve the explicit limits on runtime, dynamic callers, native internals, aggregate closure, Walking Skeleton, and SEC-01. |
| T-02-SC | high | Dependency installation | closed for recorded event | `02-01-SUMMARY.md` records that seven already-declared dependencies were missing, the owner approved `MIX_ENV=test mix deps.get`, and `mix.exs`/`mix.lock` hashes remained unchanged. This is not a general supply-chain audit or approval for future dependency changes. |

## Required Stops

- **Delivery stop:** Do not mark the phase verified or delivered until the prerequisite PR is merged, Phase 2 is rebased/reconciled against the resulting main, required hosted checks pass on the final candidate head, and the actual merge plus hosted main receipt are recorded.
- **Collision stop:** If future guard work finds a new guard matching a real `lib/` call site, stop and report the exact MFA, call site, input trace, and triggering guard for an owner decision (`02-CONTEXT.md` D-06; `02-VALIDATION.md` manual-only verification).
- Keep runtime, dynamic-caller, native-internals, full-row, Walking Skeleton, and SEC-01 conclusions open unless separately evidenced and authorized.
