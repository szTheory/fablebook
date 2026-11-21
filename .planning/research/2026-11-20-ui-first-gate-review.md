# UI-first gate review

> **Superseded as a complete recommendation:** this was the preliminary UI-first review. The ground-up review at [2026-11-20-ground-up-product-roadmap-review.md](2026-11-20-ground-up-product-roadmap-review.md) adds the unresolved compile-time `Macro.expand(book, caller_env)` boundary in `Fablebook.Router` and re-evaluates the full product sequence. Keep this document as provenance; do not treat its fixed-runtime-input argument as sufficient to settle the mount-macro boundary or as gate-change authorization.

**Status:** Recommendation for owner decision; not an active milestone or executable plan.  
**Owner direction:** [INT-20261120-09](../intent/sources/2026-11-20-09-prioritize-visible-ui-work.md)  
**Related product scope:** [INT-20261120-08](../intent/sources/2026-11-20-08-define-showcase-books-not-full-demo-apps.md)

## Recommendation

Stop broad guard inventory work unless a proposed increment is tied to a concrete Fablebook code path and can demonstrably close a named part of the complete gate. Seek owner approval for one narrow exception: allow a dev/test-only Walking Skeleton that renders one fixed, compiled sample story while the broad guard aggregate remains explicitly open.

The exception would not claim the aggregate is complete or lower the security bar for user-controlled behavior. Keep the existing direct protections: no `Code.eval_*` or equivalent on user input, no atom creation from input, production builds reject reachable Fablebook mounts, and stories/canon stay out of production. The first skeleton must use a fixed compiled scenario and accept no URL/control input that can select code, modules, atoms, or topics. Do not treat the exception as authorization for Controls, dynamic presets, arbitrary story execution, LLM-generated code execution, or release.

Keep a separate blocking acceptance checkpoint before any feature that consumes user-controlled values or invokes audited APIs. At that checkpoint, prove the concrete parse/render boundary and retain the no-eval/no-new-atom properties. The remaining broad OTP audit stays open; no row is marked safe by this proposal.

## Why this is the recommended tradeoff

- Fablebook's purpose is visual: the first meaningful result should be a compiled scenario visible in a real Phoenix host, not another inventory report.
- The current implementation is still a placeholder, and v0.2–v0.6 produced evidence and maintenance work without a product UI or aggregate closure.
- The broad aggregate has no finite completion increment in the v0.6 receipts: its proposed seven-function family remains unpromoted against a 1,756-function complement, four source gaps remain, prior requests are closed, and caller observations are not exhaustive.
- A fixed compiled scenario in a dev-only host does not need client-provided code, atom creation, or dynamic module selection. Those pathways can remain blocked until their own direct security acceptance passes.
- This is still a real gate change: dependency APIs outside the selected static evidence would remain unaudited during the skeleton. The owner must explicitly accept that bounded residual risk; it must not be inferred from a general preference for UI work.

## First visible result if approved

Use the existing Walking Skeleton outcome as the product slice: render one compiled sample scenario in a plain host and an adversarial operator host, retain the production-route exclusion, exercise the nonce CSP, and capture one deterministic visual check. This demonstrates Fablebook's render seam in an actual Phoenix app. It is not yet a browsable workbench or a Logistify Book.

After that, proceed through the story model/catalog and render seam. Then author the three Logistify Books (operator console, shipper portal, driver app) as screen/workflow/state/interaction records. Complete logistics business apps and backends are not required.

## Decision boundary

The existing `guard-aggregate` gate remains open and blocks Walking Skeleton. This proposal does not change `.planning/references/PLANNING-GATES.json`, the typed phase map, or any requirements. If approved, record an owner-signed intent and update the typed gate/phase map before starting a milestone. If not approved, preserve the current block and do not resume broad guard increments without a concrete completion path.

The next global phase number after delivered Phase 7 would be Phase 8 if the owner activates a product milestone; this brief does not reserve or activate it.
