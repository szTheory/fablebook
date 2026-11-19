# Phase 5: Bounded two-lane source provenance slice — Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-18
**Phase:** 5-bounded-two-lane-source-provenance-slice
**Areas discussed:** selected source family, source-request boundary, verification order

---

## Selected source family

| Option | Description | Selected |
|--------|-------------|----------|
| Reopen the full 226-identity set | Re-run broad source and caller work across 9,716 gaps | |
| Select one exact two-lane family | Use one identity with exact core/floor membership, full complement, and a concrete source request | ✓ |
| Refresh the helper digest again | Reinspect the helper to try to infer the missing legacy selector/values | |

**User's choice:** The owner authorized the recommended additional bounded evidence scope and asked to proceed. The exact target was delegated to evidence-based recommendation; the owner did not name EX-177.
**Notes:** Three independent read-only reviews agreed that one exact family is the useful boundary, source identity should precede caller closure, and the digest should be deferred because its selector, field order, and exact inputs are unavailable. The orchestrator selected EX-177 because the retained matcher names `prompt_for_code_injection`, its core/floor membership is one known MFA per lane, and it contributes exactly four keyed gaps. This selection makes no vulnerability claim.

---

## Source-request boundary

| Option | Description | Selected |
|--------|-------------|----------|
| Read now using the historical citation | Treat the prior citation line as current source identity and access | |
| Prepare and consume one fresh request only after exact gates | Bind current lane sources/spans, independent review, direct count, execute preflight, and one-use gate first | ✓ |
| Ask the owner to approve every routine gate again | Re-prompt after each mechanical check | |

**User's choice:** Follow the recommendation and proceed within the existing safeguards.
**Notes:** The historical citation `phoenix/lib/mix/tasks/phx.gen.context.ex:445` is only a locator. The current source gate stays closed until the exact pinned files and spans pass the per-request checks. A changed or incomplete request is not replayed.

---

## Verification order

| Option | Description | Selected |
|--------|-------------|----------|
| Run broad Phase 3 suites first | Spend time on a suite that cannot establish the selected source identity by itself | |
| Check identity, four selected rows, complement, hashes, and request bindings first | Stop cheaply on malformed or stale evidence before any source output or broader process | ✓ |
| Add a recurring CI lane for this one-off evidence scope | Maintain a new pipeline check without recurring value established | |

**User's choice:** The owner repeatedly requested cheap consistency checks before long tests and automated verification where useful.
**Notes:** Reuse the fresh Phase 4 package result unless its inputs change. This phase is evidence-only; any focused source check must be justified by the exact plan. No new dependency or recurring CI lane is warranted for this one-off scope.

---

## the agent's Discretion

- Choose the smallest complete pinned source/caller spans and a deterministic request schedule for EX-177.
- Stop with an exact gap if the family exceeds source, caller, context, or file-count limits; do not automatically try another family.
- Leave legacy digest, candidate, implementation, and aggregate gates open.

## Deferred Ideas

- Resolving all 9,716 gaps, all 18 unknown target sets, or another family in this one scope.
- Reproducing the legacy SIZING digest without its exact stored inputs.
- Guard implementation, candidate promotion, runtime execution, and automatic follow-on.
