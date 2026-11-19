---
phase: "06"
slug: "bounded-ex-177-provenance-supplement"
status: verified
threats_open: 0
asvs_level: 1
created: "2026-11-19"
---

# Phase 06 — Security

> This phase adds a static evidence record and a local checker. Phoenix source paths remain string values; the checker reads only its explicit saved-evidence allowlist.

## Trust Boundaries

| Boundary | Description | Data Crossing |
|---|---|---|
| Reviewed discovery and archived records → supplement | Transcribed facts may be stale or disagree with the authoritative saved evidence | JSON/JSONL records, lane pins, spans, row keys, hashes |
| Checker → recorded Phoenix path values | Provenance path strings must never become filesystem targets | Path strings held in the JSON record |
| Archived JSONL → complement check | Input rows must remain bound to the exact selected set and pending complement | Raw line bytes, row count, SHA-256 |

## Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation | Status |
|---|---|---|---|---|---|---|
| T-06-01 | Tampering | Supplement and saved-evidence bindings | medium | mitigate | The checker validates the exact schema and four-key set, lane facts, citations, preserved stops, and the 9,712-row raw-line digest; its focused controls reject altered data. | closed |
| T-06-02 | Elevation of Privilege | Checker path handling | high | mitigate | Evidence reads use a fixed allowlist. Recorded Phoenix paths are extracted and compared as strings; the checker rejects them as read targets, with a negative control for both lane values. | closed |
| T-06-SC | Tampering | Python dependency installation | low | accept | The checker uses only Python standard-library modules; no package manager or third-party dependency was introduced. | closed |

## Accepted Risks Log

| Risk ID | Threat Ref | Rationale | Accepted By | Date |
|---|---|---|---|---|
| R-06-01 | T-06-SC | The plan explicitly accepts the low dependency-installation threat because the checker adds no external dependency or installation path. | Plan 06-01 disposition | 2026-11-19 |

## Security Audit Trail

| Audit Date | Threats Total | Closed | Open | Run By |
|---|---:|---:|---:|---|
| 2026-11-19 | 3 | 3 | 0 | Codex — static plan, checker, and saved-evidence review |

## Sign-Off

- [x] All threats have a disposition.
- [x] The planned accepted risk is recorded.
- [x] `threats_open: 0` confirmed at the configured high threshold.
- [x] `status: verified` set in frontmatter.

**Approval:** Security controls verified 2026-11-19.

## Security Audit 2026-11-19

| Metric | Count |
|---|---|
| Threats found | 3 |
| Closed | 3 |
| Open | 0 |
