---
phase: "01"
slug: bounded-guard-continuation
status: verified
threats_open: 0
asvs_level: 1
created: "2026-11-11"
---

# Phase 1 — Security

> Security verification of the selected static EX-010 candidate. This does not assert runtime SEC-01 safety, phase delivery, or broader product completion.

## Trust Boundaries

| Boundary | Description | Data Crossing |
|----------|-------------|---------------|
| Offline source bytes to archive and resolver | Source records must identify the exact lane, pinned revision, bytes and citations. | OTP source bytes, refs, hashes and sizes |
| Caller input to tracing delegate and callback/native port | Static findings preserve caller-controlled values and stop at the caller callback and fixed native boundary. | Service, destination, callback/data and trace level |
| Live graph to selected-row evidence | Graph membership and static edges must not impersonate source semantics or erase other owners. | MFA sets, edges, dispositions and ownership |
| Candidate checks to delivery state | Candidate head, reviews and required hosted checks must agree; owner approval and expected-head checks precede merge. | Commit identities, review results, CI receipts and delivery records |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|-----------|----------|-----------|----------|-------------|------------|--------|
| T-1-01 | Tampering | Core source archive and citations | high | mitigate | Exact refs/hash/size, archive-only resolution, and missing, wrong-lane and altered-member controls; [Plan 01 summary](01-01-SUMMARY.md), [candidate evidence](01-CANDIDATE.md) | closed |
| T-1-02 | Elevation of Privilege | Trace callback and port boundary | high | mitigate | Core input/service/destination/callback/driver path is recorded; direct, capture and apply fixtures remain uncalled; callback implementation and native internals remain outside the claim. | closed |
| T-1-03 | Spoofing | Graph-only semantic claim | high | mitigate | Hash-scoped source findings and unsupported-finding controls are recorded; zero incoming graph edges is explicitly not treated as absence of dynamic callers. | closed |
| T-1-04 | Denial of Service | Proposed guard versus production library | high | mitigate | No active guard was added; benign controls pass, protected production paths are unchanged, and a future real collision retains the owner-stop requirement. | closed |
| T-1-05 | Spoofing | Floor source identity and findings | high | mitigate | Exact floor bytes/ref and lane-specific resolution are bound; cross-lane source substitution controls and the final floor suite pass; [Plan 02 summary](01-02-SUMMARY.md). | closed |
| T-1-06 | Tampering | Floor row, citations and witnesses | high | mitigate | Complete floor membership and individual removal/overlap witnesses reject omissions, duplicates, altered citations, wrong-lane records and changed bytes. | closed |
| T-1-07 | Elevation of Privilege | Floor destination and callback influence | high | mitigate | The floor input path and fixed boundaries are recorded; compile-only direct/capture/apply forms are not invoked. | closed |
| T-1-08 | Denial of Service | Floor guard candidate versus production library | high | mitigate | No active guard was added; benign controls and unchanged production paths preserve the collision stop. | closed |
| T-1-09 | Tampering | Integrated partition and semantic records | high | mitigate | Core/floor selected and remainder sets, outside-row ownership and hash-scoped findings are reconciled; wrong-lane, omission, overlap and permutation controls pass. | closed |
| T-1-10 | Elevation of Privilege | Incomplete static guard forms | high | mitigate | Per-MFA retained-matcher removal and uncalled direct/capture/apply/source controls pass on both lanes; no runtime execution is claimed. | closed |
| T-1-11 | Denial of Service | Newly active guard versus production library | high | mitigate | No new pattern or production change was made; the recorded collision check found no selected call in `lib/`, and the owner-remedy stop remains. | closed |
| T-1-12 | Spoofing | Candidate CI and merge authority | high | mitigate | Local checks, independent reviews, PR identity and all required hosted candidate checks bind to head `a90ef1dfe7bad10ac3d303b82f8ba7b32c949745`. PR #85 remains open; owner approval and expected-head merge checks have not been exercised, and no merge or delivery is claimed. The existing stop prevents merge until those controls run. | closed for candidate verification; delivery pending |
| T-1-13 | Repudiation | Delivery and cost records | medium | mitigate | Actual intervals, test exits, source identities, review outcomes and hosted receipts are recorded. No merge or delivery fact was fabricated; registry update remains deferred until a real approved merge. | closed |
| T-1-14 | Elevation of Privilege | Broader completion and automatic continuation | high | mitigate | Only EX-010 receives the selected disposition; requirements, aggregate and walking-skeleton gates remain open, SEC-01 stays future work, and no phase completion or follow-on scope is asserted. | closed |
| T-1-SC | Tampering | Package installation | high | mitigate | No package or dependency was added; offline lane copies and existing locks were used. The candidate leaves dependency and production configuration files unchanged. | closed |

The same T-1-SC supply-chain threat appears in all three plans and is represented once here. Verification reused the existing hash-bound source reviews, candidate evidence, focused control receipts, full local core/floor receipts and hosted run [43124394402](https://github.com/szTheory/fablebook/actions/runs/43124394402). No OTP source was reopened, no test was rerun, and no new code review was launched.

The candidate's final full core and floor sidecars both record exit 0 and head `a90ef1dfe7bad10ac3d303b82f8ba7b32c949745`. The hosted run succeeded on that same head, and the fresh required-check query exited 0. See [candidate evidence](01-CANDIDATE.md) and raw receipts under `_build/phase1-execution/`.

## Accepted Risks Log

No accepted risks.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|------------|---------------|--------|------|--------|
| 2026-11-11 | 15 | 15 | 0 | GSD secure-phase report-only hook |

## Sign-Off

- [x] All threats have a disposition (`mitigate` / `accept` / `transfer`)
- [x] Accepted risks documented in Accepted Risks Log
- [x] `threats_open: 0` confirmed for the selected static candidate
- [x] `status: verified` set in frontmatter

Approval: verified 2026-11-11 for candidate security evidence; owner approval, merge, main CI and delivery bookkeeping remain pending.
