---
phase: "08"
slug: "first-inspectable-book-and-local-host-path"
status: verified
threats_open: 0
asvs_level: 1
created: "2026-11-25"
---

# Phase 8 — Security

> Static evidence reconciliation of the mitigations declared in all five Phase 8 plans at ASVS L1. This record does not clear the separate product safety stops or authorize runtime use.

## Scope and trust boundaries

Phase 8 handles pinned public source, a minimal cited excerpt, a literal-only mount macro, fixed compiled Story/Scenario identifiers, an isolated development host, a same-origin Canvas, and public PR evidence. Production builds must exclude the Book and development adapter. No user-provided code or values are evaluated, no persistent or external action is performed, and no source repository or screenshot is published.

All five plans contain threat models. Their summaries contain no threat flags. The configured verification depth is ASVS L1 with `security_block_on: high`. The threat register below preserves repeated plan-level `T-08-SC` registrations; they describe the same bounded package-installation control.

## Threat Register

| Threat ID | Plan | Category | Component | Severity | Disposition | Mitigation evidence | Status |
|---|---|---|---|---|---|---|---|
| T-08-01 | 08-01 | Tampering | Source identity and excerpts | high | mitigate | `bin/verify_logistify_source --check-pinned` and the source summary bind the public commit, original hashes, manifest, and cited excerpt bytes. | closed |
| T-08-02 | 08-01 | Information disclosure | Public source cache and reviewed candidate | medium | mitigate | The cache is ignored; the tracked manifest contains only the approved minimal excerpt. The screenshot-free PR and source summary record the bounded public content. | closed |
| T-08-SC | 08-01 | Tampering | Package installation | high | mitigate | The source and checker use installed standard-library/runtime tooling; the phase adds no root package dependency. | closed |
| T-08-03 | 08-02 | Elevation of Privilege | Public mount expansion | high | mitigate | The mount macro validates caller AST before resolving aliases; the separate contract tests exercise rejected computed inputs and preserve the canonical production error. | closed |
| T-08-04 | 08-02 | Tampering | Delivery split and baseline | high | mitigate | The implementation and contract-test deliveries were split into separately reviewed PRs with exact-head green hosted CI. | closed |
| T-08-SC | 08-02 | Tampering | Package installation | high | mitigate | The macro and contract work uses existing Elixir/ExUnit dependencies; no package was installed for the implementation or test-only PRs. | closed |
| T-08-05 | 08-03 | Tampering | Separate active test PR | high | mitigate | The test-only PR was based on the merged implementation and has its own green exact-head CI and merge receipt. | closed |
| T-08-06 | 08-03 | Information disclosure | Production routes and compiled modules | high | mitigate | The fixture verifies positive development/test inclusion, clean production route/module exclusion, and the isolated reachable-mount compile rejection. | closed |
| T-08-SC | 08-03 | Tampering | Package installation | high | mitigate | The test-only fixture uses existing Mix/ExUnit tooling and unchanged package locks. | closed |
| T-08-07 | 08-04 | Elevation of Privilege | Catalog and Scenario dispatch | high | mitigate | Catalog selection compares exact fixed strings and dispatches only through trusted compiled metadata and HEEx; the route regression covers duplicate Scenario names across Journeys and rejects ambiguous legacy selection. | closed |
| T-08-08 | 08-04 | Information disclosure | Host and Canvas frame scope | high | mitigate | The actual host is compile-gated to development/test, binds its optional listener to loopback, and applies nonce CSP plus same-origin frame policy. Real-host browser evidence records the response headers and same-origin Canvas. | closed |
| T-08-09 | 08-04 | Tampering | Development listener dependency | medium | mitigate | Bandit 1.15.0 is confined to the operator host's `:dev` dependency scope. The locked host dependencies were checked with `MIX_ENV=dev mix deps.get --check-locked`; `MIX_ENV=dev mix hex.audit` reported no retired or advisory packages. Test and production controls verify the adapter is unavailable there. | closed |
| T-08-SC | 08-04 | Tampering | Package installation | high | mitigate | Official Hex publisher/release metadata is recorded in `08-RESEARCH.md`; the resolved host lock matches the reviewed pins and the host Hex audit passed. Root dependency pins remain separate from the operator host. | closed |
| T-08-10 | 08-05 | Information disclosure | Actual operator production compile | high | mitigate | `bin/verify_operator_host_prod` checks clean production routes and BEAM modules and confirms one canonical failure for an isolated reachable mount. Core and floor controls and exact-head hosted CI passed. | closed |
| T-08-11 | 08-05 | Tampering | Source-cited records and actions | medium | mitigate | Pinned-source validation and host assertions bind visible facts and citations to exact source bytes; missing facts remain explicit and actions are labeled illustrative. | closed |
| T-08-12 | 08-05 | Information disclosure | Public remote and evidence visibility | medium | mitigate | The reviewed PR contains only the approved public citations and minimal cited demo content; it contains no source repositories, PDFs, private data, or screenshots, and the demo remains undeployed. | closed |
| T-08-13 | 08-05 | Tampering | Browser security and capture evidence | medium | mitigate | `08-BROWSER.md` records actual same-origin headers/assets, Canvas states, keyboard/focus, and viewport behavior. The owner accepted the live visual baseline separately in INT-20261125-04; the PR contains no capture artifact. | closed |
| T-08-SC | 08-05 | Tampering | Package installation | high | mitigate | The final host reuses the audited host-only development lock, while production excludes the listener and the root locks contain no Book-specific dependency changes. Exact-head hosted security CI passed. | closed |

The five `T-08-SC` rows are the same package-installation boundary carried across plans, not five separate dependency changes. The operator host's listener is a reviewed development-only dependency; the root runtime package set remains bounded by the separately delivered Phoenix security prerequisite.

## Accepted Risks Log

No accepted security risks. INT-20261125-05 accepts the existing direct Chrome record as manual verification evidence for the Canvas ready/failure lifecycle; it does not accept a security threat or change any security threshold.

## Security Audit Trail

| Audit Date | Threat Registrations | Closed | Open | Run By |
|---|---:|---:|---:|---|
| 2026-11-25 | 18 | 18 | 0 | Codex — ASVS L1 plan, source, host-lock, production-boundary, browser, and hosted-CI evidence review |

## Sign-Off

- [x] Threat registrations from all five plan threat models are accounted for.
- [x] No summary threat flags were found.
- [x] The operator host lock matches the reviewed pins and its Hex audit passed.
- [x] Production exclusion, same-origin browser, and exact-head hosted security evidence passed.
- [x] `threats_open: 0` at the configured high threshold.
- [x] `status: verified` is set in frontmatter.

**Approval:** Declared mitigations verified at ASVS L1 on 2026-11-25. The clean-plan L1 path applies; no deeper auditor pass was required.
