# Phase 3: Guard aggregate scope rejoin and candidate sizing - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in `03-CONTEXT.md` — this log preserves the alternatives considered.

**Date:** 2026-11-13
**Phase:** 3-guard-aggregate-scope-rejoin-and-candidate-sizing
**Areas discussed:** Evidence package shape, Candidate-sizing decision point

---

## Evidence package shape

| Option | Description | Selected |
|--------|-------------|----------|
| Structured lane receipts plus linked human-readable crosswalk | Keep machine-readable current inventory/provenance and exact membership records canonical; provide a concise row-level report that links to them. | ✓ |
| Single manually maintained Markdown dossier | Put all facts in one document; easier to skim initially, but risks duplicated or stale membership facts. | |
| Assertions only | Rely on passing contracts without a human-inspectable row-level account. | |

**User's choice:** Recommendation applied under the owner's explicit instruction to follow the synthesized recommendations and reduce decision overhead.
**Notes:** Reuse the existing installed-lane inventory and hash-validated source resolver; prior lane inventories remain historical inputs, not current proof. Do not add a dependency or general-purpose audit framework.

---

## Candidate-sizing decision point

| Option | Description | Selected |
|--------|-------------|----------|
| One evidence-backed recommendation, or no candidate if evidence/fit is incomplete | Show exact remaining membership and measured source, context, plan, and effort fit. The owner still decides separately whether to authorize later implementation. | ✓ |
| Ranked shortlist | Measure and compare several candidates before the owner chooses; more comparison data, but higher evidence and review cost. | |

**User's choice:** Recommendation applied under the owner's explicit instruction to follow the synthesized recommendations and reduce decision overhead.
**Notes:** This phase does not select or authorize an implementation slice, add guard dispositions, or close the aggregate gate. A missing identity, source, caller/delegate link, or fit result yields a concrete gap and no candidate.

---

## the agent's Discretion

- Use one GSD assumptions-analysis agent for an independent, read-only scan of existing inventory, provenance, and sizing patterns. No tests, OTP guard calls, or file writes were performed by that scan.
- Choose precise record schemas and filenames, whether a narrow collector is needed, and task/plan grouping while preserving complete evidence and all inherited limits.

## Deferred Ideas

None. Product UI, brand work, dogfood apps, SEC-01, and any later guard implementation retain their existing scope and owners.
