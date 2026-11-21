# Phase 8: First inspectable Book and local host path - Context

**Gathered:** 2026-11-20  
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver v0.7's one fixed, developer-authored Logistify operator Book in development and test: a local Fablebook catalog with minimal navigation across two or three addressable screens, fixed cited illustrative data, compiled Story/Scenario modules, and the real host Canvas path. Before Book implementation, constrain and test the public mount macro, keep its contract-test and implementation PRs separate, and pass positive production route/story exclusion plus a negative reachable-production-mount control. The guard aggregate remains open and `walking-skeleton` remains blocked.

</domain>

<decisions>
## Implementation Decisions

### Source grounding and content
- Use only the exact Logistify v1.0 text/token subset needed for this operator Book; make that subset reproducible in the reviewed repository and verify its recorded SHA-256 values before use.
- Tie each user-visible source claim and fixed fixture to its exact source file and section. Preserve the source's open name and asset-rights status; keep the fictional name and demo internal/local and do not import unreviewed artwork, sound, or fonts.
- Choose one source-supported dispatcher job, with one ordinary state and one meaningful source-supported edge or error state. Keep all data deterministic and fixed, use the approved Fablebook vocabulary and product-copy corrections, and do not invent logistics policy.

### Mount and production boundary
- Accept only literal module alias/reference AST forms in the public mount macro; reject macro calls, variables, and other computed expressions before expansion.
- Keep the macro contract test and implementation in distinct PRs. The rejection test is authored first and checked against the proposed implementation locally; the hardened implementation PR and then the active test-only PR each receive their own green required hosted CI.
- Before Book code is added, run the positive production route/story exclusion checks and the negative reachable-mount compile control against the production-guard fixture. Repeat those checks against the completed operator host after Book implementation.
- Keep the canonical production mount error, current no-eval/no-input-atom rules, and existing CI gates intact. Do not add client-controlled module, code, atom, or topic selection.

### Catalog and navigation
- Keep the Fablebook catalog chrome neutral and apply the approved Logistify text/token styling only in the preview.
- Provide only enough navigation to select the one Book, move between its two or three screens, and open each screen at a stable URL. Unknown screen selection resolves safely. Do not add broad workbench controls, an Inspector, a command palette, a grid, or a general Journey editor.
- Use the existing Elixir/Phoenix stack and no new runtime dependency or required Node setup. Keep the host free of Ecto/business services, persistence, and external writes.

### Verification and visual evidence
- Start with source, citation, digest, fixture, vocabulary, and compile checks; then run focused catalog/render/navigation tests and production controls.
- Use one real-host browser pass for the host assets and CSP, keyboard navigation, focus, labels, text status, and representative narrow and desktop widths.
- Capture one deterministic visual artifact. Never accept a new or changed baseline automatically; finish all other work first and ask the owner only if that visual judgment is actually required.

### the agent's Discretion
- Choose the smallest screen count and navigation affordance that completely explains the source-supported dispatcher flow.
- Choose local module names, fixture shapes, implementation boundaries, and suitable checks while preserving the separate PR sequence and all approved limits.
- Reconcile ADR 0020's host description with the current repository before claiming host readiness; add only the smallest real host needed to exercise the actual Canvas path.

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Fablebook.Router.fablebook/2` in `lib/fablebook/router.ex` is the public mount macro and currently calls `Macro.expand/2` on the Book argument outside production.
- `test/fixtures/prod_guard_host/` and `test/contract/prod_guard_test.exs` already exercise a development/test mount, absence of production Fablebook routes and story sources, and rejection of a reachable production mount.
- `test/support/mix_cmd.ex` runs the fixture host's Mix commands in separate environments.

### Established Patterns
- The current production guard returns a `CompileError` with the canonical first line `Fablebook cannot be mounted in a prod build`.
- Stories are compiled modules by ADR 0001; the host Canvas is an iframe through the host's root layout and asset pipeline by ADR 0003.
- No `hosts/` app, catalog, Book, Story, Scenario, or Canvas implementation is present in the reviewed main tree. The router currently mounts a placeholder.

### Integration Points
- Replace the placeholder route output through `lib/fablebook/router.ex`, `lib/fablebook/placeholder.ex`, and the appropriate new compiled modules.
- Extend the existing production-guard fixture/checks without weakening its existing positive and negative assertions.
- Obtain the source subset from a preserved, read-only source location if needed; do not alter preserved historical worktrees or the dormant brand-canon seed.

</code_context>

<specifics>
## Specific Ideas

- Keep the product surface visibly real: a local catalog, an authored compiled Book, addressable screens, and the host's Canvas—not a screenshot mock or a direct route that bypasses Fablebook.
- Prefer a source-supported short dispatcher flow; decide its exact screen content only after inspecting and hashing the reproducible source subset.
- Follow `.planning/research/2026-11-20-next-milestone-scope-review.md`, `.planning/references/logistify-brand-intake.md`, `GLOSSARY.md`, and the approved exception in INT-20261120-14.

</specifics>

<deferred>
## Deferred Ideas

- Shipper and driver Books, complete Logistify brand canon, broader sourcebook asset application, and public brand or marketing claims.
- General-purpose workbench features, Controls, URL overrides, persistence, backend behavior, bundles, broad visual matrices, and follow-on milestone work.
- Owner approval of a new or changed screenshot baseline, if the implementation produces one that needs judgment; retain as the final visual handoff after all objective work is complete.

</deferred>
