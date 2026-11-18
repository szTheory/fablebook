---
phase: "3"
slug: guard-aggregate-scope-rejoin-and-candidate-sizing
status: verified
threats_open: 0
asvs_level: 1
created: "2026-11-17"
---

# Phase 3 — Security

> Scope: read-only inventory, exact lane membership, source/caller evidence or typed gaps, sizing, and local validation. This audit does not close source gaps, caller gaps, the actual-collision stop, Macro/explanation checkpoints, the aggregate gate, Walking Skeleton, SEC-01, or delivery.

## Verdict

**VERIFIED at ASVS Level 1.** The five active plans contain 25 threat-register entries (21 unique IDs after consolidating the repeated `T-03-SC`). All mitigations are present in the executed artifacts, tests, review and handoff. No high-severity mitigation is missing. There are no accepted risks: unresolved evidence remains an active stop and no implementation is authorized.

The Phase 4 package contains no resolved source associations and 9,716 explicit typed gaps. The consumer keeps source resolution unresolved, caller closure incomplete and candidate null. Those gaps are not counted as security closure or source proof; the security mitigation is that they cannot silently become either.

## Trust Boundaries

| Boundary | Description | Data crossing |
|---|---|---|
| Pinned lane inventory → aggregate record | Lane identity, exact MFA sets and original row ownership must not be substituted or reduced to counts. | Lane refs, row IDs, MFA keys, record hashes |
| Phase 4 artifacts → Phase 3 consumer | Complete record accounting must not impersonate resolved sources, caller closure or a valid legacy digest. | Generation IDs, manifest/row digests, typed gaps, selectors |
| Local checks → readiness statement | A failed, excluded, wrong-lane or unrun check must not be represented as a pass. | Commands, selected test counts, code/artifact hashes, logs |
| Local readiness → hosted delivery | Local checks do not prove final-head CI, actual merge identity or merged-main CI. | Branch/head, hosted run URLs, merge commit |
| Evidence handoff → future authority | A recommendation or report must not authorize a new implementation or phase automatically. | Candidate state, owner decision, safety stops |
| Existing toolchain → local validation | Tool use must not add dependencies, invoke audited runtime paths or expose credentials. | Lockfile-pinned tools, bounded source requests, logs |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation evidence | Status |
|---|---|---|---|---|---|---|
| T-03-01 | Spoofing | Lane builder and validator | high | mitigate | Exact core/floor lane identities and pinned toolchain are recorded; consumer checks bind records to lane-specific inputs. | closed |
| T-03-02 | Tampering | Row join and partition renderer | high | mitigate | Exact 226-ID lane sets, owners, MFA membership and partition controls are validated; crosswalk links exact row pointers and hashes. | closed |
| T-03-03 | Elevation of privilege | Tagged collection entry | high | mitigate | Collection stays static and read-only; no audited API, callback, dynamic atom sink or generated-code path is invoked. | closed |
| T-03-04 | Tampering | Evidence publication | medium | mitigate | Writes remain opt-in and atomic; matching lane records are validated before bundle rendering. | closed |
| T-03-05 | Tampering | Source identity join | high | mitigate | Same-lane generation, path, identity and digest bindings are checked; missing source proof remains a typed gap. | closed |
| T-03-06 | Spoofing | Caller/delegate path records | high | mitigate | Missing current graph/callback/delegate proof remains explicitly keyed; caller closure is incomplete and candidate selection stays disabled. | closed |
| T-03-07 | Tampering | Required evidence gaps | high | mitigate | Source/caller/unknown partitions must be complete and disjoint; any required gap prevents a recommendation. | closed |
| T-03-08 | Denial of service | Graph traversal and record expansion | medium | mitigate | Evidence is not silently capped or truncated; incomplete records fail closed and the complete generated gap index is checked. | closed |
| T-03-09 | Tampering | Sizing and fit validator | high | mitigate | Missing source/caller closure produces `not_measured_without_complete_source_and_caller_closure`; unknown effort fails closed and candidate remains null. | closed |
| T-03-10 | Spoofing | Recommendation gate | high | mitigate | Negative controls and exact consumer checks reject stale, incomplete or substituted evidence; no candidate is selected. | closed |
| T-03-11 | Elevation of privilege | Owner decision report | high | mitigate | `implementation_authorized=false`; a later guard increment remains a separate owner decision. | closed |
| T-03-12 | Tampering | Sizing record publisher | medium | mitigate | The active generation and input digests are bound; interrupted or mixed-generation records are rejected. | closed |
| T-03-19 | Tampering | Metadata target projection | high | mitigate | Full input hashes, identity tuples and the explicit unknown-target set are validated; aggregate counts alone cannot pass. | closed |
| T-03-20 | Spoofing | Selected-function references | high | mitigate | References bind to exact same-lane MFA and row pointers; a selected function cannot close unrelated missing mapping. | closed |
| T-03-21 | Repudiation | Supplemental handoff | high | mitigate | Recovery outputs have separate filenames and preserve old inputs; the report states no source proof and retains no-candidate authority. | closed |
| T-03-16 | Spoofing | Local readiness receipt | high | mitigate | Readiness records exact commands, outcomes, tested source hashes, crosswalk identity and complete test log digests. | closed |
| T-03-17 | Repudiation | Local/hosted delivery handoff | medium | mitigate | Local suites are explicitly separate from pending hosted candidate CI, merge and main CI receipts. | closed |
| T-03-18 | Elevation of privilege | Canonical owner handoff | high | mitigate | STATE edits preserve owners and stops, the generated projection is refreshed through the SDK, and no follow-on implementation is authorized. | closed |
| T-03-22 | Tampering | Supplement validator and consumer | high | mitigate | The validator recomputes artifact digests and binds generation, lane, record hash and identity pointer; negative controls and final independent review cover stale or substituted inputs. | closed |
| T-03-23 | Tampering | Recovered intent and historical readiness | high | mitigate | The recovered user reply is added verbatim; the prior failed readiness and source evidence are retained separately. | closed |
| T-03-SC | Tampering | Package/tool setup and count credential (Plans 03-01 through 03-05) | high | mitigate | No dependency was added or installed; pinned existing tools were reused. Count-only sizing does not call generation, and no credential is emitted in logs. | closed |

*Status: open · closed · open below the high blocking threshold (non-blocking).*  
*Disposition: mitigate (control present); no risk was accepted or transferred.*

## Accepted Risks Log

No accepted risks. Source and caller gaps, unknown collision status, static-only limits and unresolved owner checkpoints remain open evidence boundaries, not accepted implementation risks.

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|---|---:|---:|---:|---|
| 2026-11-17 | 25 plan-register entries / 21 unique IDs | 25 | 0 at or above high threshold | Codex |

## Sign-Off

- [x] All planned threats have a disposition.
- [x] No accepted risks were added.
- [x] `threats_open: 0` confirmed at ASVS Level 1.
- [x] `status: verified` set in frontmatter.

**Approval:** verified 2026-11-17. The phase's source, caller, collision, Macro, explanation and delivery limitations remain explicit; this audit does not waive them.

## Security Audit 2026-11-18

| Metric | Count |
|---|---|
| Threats found | 25 |
| Closed | 25 |
| Open | 0 |
