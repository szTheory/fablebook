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

## Plan 03-05 recovery boundary (2026-11-16)

| Option | Description | Selected |
|--------|-------------|----------|
| Repair the local format and record failures, then close keyed Phase 4 provenance before rerunning source-dependent contracts | Fix the issues that can be resolved from existing evidence immediately. Keep slow suites behind a cheap, identity-level provenance check. | ✓ |
| Rerun the same focused and full suites first | Produces no new evidence because the recorded target-source/caller gaps and local failures have not changed. | |
| Stop with a handoff only | Preserves the stops but leaves already authorized local and evidence-only repairs undone. | |

**User's choice:** The user selected the recommended bounded recovery, then explicitly authorized fixing the recorded issues and proceeding.
**Notes:** Preserve the original dirty checkout. Use the exact transfer snapshot in the isolated candidate. Do not rewrite the failed readiness receipt; append new receipts for remediation results.

## Repair and check order

| Option | Description | Selected |
|--------|-------------|----------|
| Increasing-cost gates: format/whitespace, keyed artifact consistency, focused contracts, core CI, full floor suite | Finds malformed files or incomplete evidence before the expensive tests and makes failures attributable. | ✓ |
| Run every check in parallel | Shortens wall time only when prerequisites are independent; here source-dependent checks can fail for the same unresolved keyed evidence. | |
| Skip failing checks and record them | Leaves the phase blocked without learning whether the evidence repair solved the reported failures. | |

**User's choice:** Recommendation applied under the user's instruction to use cheap sanity checks first and remove the repeated-work bottleneck.
**Notes:** Stop at the first failure, identify its cause, and rerun only the affected checks after a fix. Corpus, test-support, and planning repairs may proceed; production guard behavior, thresholds, dependencies, and safety stops remain fixed.

## Phase 4 evidence boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Complete the already selected evidence-only provenance closure | Key every lane association or typed gap, trace the coverage caller and digest selector, and stop with exact unknowns when evidence cannot establish a claim. | ✓ |
| Treat aggregate counts and coverage flags as sufficient | Cheaper in the short term, but does not establish which identity maps to which source or gap. | |
| Guess missing provenance or legacy digest encoding | Can make checks appear green while changing the meaning of prior evidence. | |

**User's choice:** Phase 4 evidence-only closure was selected earlier; the latest authorization explicitly permits carrying it out within its original limits.
**Notes:** No candidate promotion, runtime-safety claim, guard implementation, aggregate-gate closure, or automatic next phase. Source-body reads still require the exact reviewed schedule, planning preflight, and fresh direct count.

---

## the agent's Discretion

- Use one GSD assumptions-analysis agent for an independent, read-only scan of existing inventory, provenance, and sizing patterns. No tests, OTP guard calls, or file writes were performed by that scan.
- Choose precise record schemas and filenames, whether a narrow collector is needed, and task/plan grouping while preserving complete evidence and all inherited limits.

## Deferred Ideas

None. Product UI, brand work, dogfood apps, SEC-01, and any later guard implementation retain their existing scope and owners.
