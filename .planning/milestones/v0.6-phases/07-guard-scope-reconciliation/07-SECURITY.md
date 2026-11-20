---
phase: "07"
slug: "guard-scope-reconciliation"
status: verified
threats_open: 0
asvs_level: 1
created: "2026-11-20"
---

# Phase 7 — Security

> Static evidence reconciliation only. This security check verifies the mitigations declared in all five phase plans at ASVS L1. It does not clear the separate product safety stops or authorize runtime use.

## Scope and trust boundaries

The phase handles pinned dependency identities, saved and generated evidence records, a reviewed source schedule, and narrowly scoped one-use source observations. It does not add application behavior or a public interface. The final plan's owner-approved LiveView update supersedes the earlier plans' “no install task” assumption only for updating that existing dependency; the lock checker and audit still reject unrelated dependency changes.

The five summaries contain no `Threat Flags` entries. The threat register was authored in the plans. Configured verification depth is ASVS L1 with `security_block_on: high`.

## Threat Register

| Threat ID | Plan | Category | Component | Severity | Disposition | Mitigation evidence | Status |
|---|---|---|---|---|---|---|---|
| T-07-01 | 07-01 | Tampering | Per-lane identity and membership | high | mitigate | Current lock/runtime identities are bound and compared; mismatches fail closed in `07-validate-reconciliation.py` and `security-rebaseline/07-VALIDATE-RECONCILIATION.py`. | closed |
| T-07-02 | 07-01 | Tampering | Proposed family and complement | medium | mitigate | Exact family/complement disjointness, union, counts, digests, and mutation controls are checked by `validate_scope_partition()` and its self-tests. | closed |
| T-07-SC | 07-01 | Tampering | Package-manager changes | high | mitigate | The bounded amendment updates only the previously approved existing LiveView package; `07-CHECK-DEPENDENCY-PATCH.py` rejects any other lock-entry change. | closed |
| T-07-03 | 07-02 | Tampering | Source schedule and review binding | high | mitigate | The separate schedule review and approval are digest-bound; both validators compare the approval against current schedule bytes before use. | closed |
| T-07-SC | 07-02 | Tampering | Package-manager changes | high | mitigate | No dependency entry beyond the authorized LiveView patch changed; the exact lock checker and Hex audit passed. | closed |
| T-07-04 | 07-03 | Tampering | Scheduled source evidence | high | mitigate | The read-time reader enforces the reviewed schedule, one-use identity, file-size limit, stable file metadata, and bounded reads; validators preserve stop records. | closed |
| T-07-SC | 07-03 | Tampering | Package-manager changes | high | mitigate | The dependency patch remained confined to the single authorized existing package; no new package was added. | closed |
| T-07-05 | 07-04 | Tampering | Final record and recommendation | high | mitigate | The final validator checks evidence bindings, partition controls, bounded claims, and all inherited stop states; summary validation also checks the owner-decision boundary. | closed |
| T-07-SC | 07-04 | Tampering | Package-manager changes | high | mitigate | The checked lock diff contains only the authorized existing LiveView entry; the floor lock and `mix.exs` remain unchanged. | closed |
| T-07-06 | 07-05 | Tampering | Core lockfile patch | high | mitigate | The standard-library patch checker requires only LiveView 1.2.13→1.2.14; local and hosted `mix hex.audit` pass. | closed |
| T-07-07 | 07-05 | Tampering | Rebaselined evidence | high | mitigate | Current outputs bind the full lock and reviewed manifest digests, preserve the previous generation, and fail on identity or membership drift. | closed |
| T-07-SC | 07-05 | Tampering | Package-manager changes | high | mitigate | The owner-approved patch receipt records one existing package change; the checker rejects resolver expansion and added lock entries. | closed |

The repeated T-07-SC entries are the same package-change boundary declared by each plan, not five independent dependency changes. The actual merged diff changes one existing lock tuple; no package was added and the floor lock remained unchanged.

## Accepted Risks Log

None. The phase has no open blocking threats at the configured threshold. Product-level safety stops are preserved separately and remain open.

## Security Audit Trail

| Audit Date | Threat Registrations | Closed | Open | Run By |
|---|---:|---:|---:|---|
| 2026-11-20 | 12 | 12 | 0 | Codex — ASVS L1 plan, checker, evidence, lock-diff, and hosted-security review |

## Sign-Off

- [x] Threats from all five plan threat models are accounted for.
- [x] No summary threat flags were found.
- [x] The only dependency change is the authorized LiveView patch; its exact-lock and Hex audit controls passed.
- [x] All declared evidence checks and the required hosted security job passed.
- [x] `threats_open: 0` at the configured high threshold.
- [x] `status: verified` is set in frontmatter.

**Approval:** Declared mitigations verified at ASVS L1 on 2026-11-20. The security hook's clean-plan L1 path applies; no deeper auditor pass was required.
