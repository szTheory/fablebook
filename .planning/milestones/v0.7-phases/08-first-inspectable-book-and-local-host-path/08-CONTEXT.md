# Phase 8: First inspectable Book and local host path - Context

**Gathered:** 2026-11-20; source policy updated 2026-11-21
**Status:** Ready for execution after the pinned source gate passed

<domain>
## Phase Boundary

Deliver v0.7's one fixed, developer-authored Logistify operator Book in development and test: a local Fablebook catalog with minimal navigation across two or three addressable screens, fixed cited illustrative data, compiled Story/Scenario modules, and the real host Canvas path. Before Book implementation, constrain and test the public mount macro, keep its contract-test and implementation PRs separate, and pass positive production route/story exclusion plus a negative reachable-production-mount control. The guard aggregate remains open and `walking-skeleton` remains blocked.

</domain>

<decisions>
## Implementation Decisions

### Source grounding and content
- Use the owner-supplied public brand repositories from `brand_sources.lock.json`; fetch exact commits into the ignored `.cache/brand_sources/` cache. Do not request a folder path or rely on `docs/brand/` copies.
- Keep full repositories, PDFs, and assets in the ignored cache. The reviewed public PR may carry only the minimal Logistify source excerpt manifest and the cited Book content needed for this demo. Public citations are authorized by INT-20261121-01; this does not authorize deployment, release, or marketing claims.
- Keep the three original whole-file SHA-256 pins in `bin/verify_logistify_source`, run them against `.cache/brand_sources/logistify-brand`, and bind each manifest excerpt to the locked repository, tag, commit, repo-relative path, and exact source bytes.
- The pinned records support the dispatcher job and a dispatcher recovery slice after a failed driver stop. They state 12 selected/reassigned but provide only two shipment IDs in the bulk case and one focal ID in the completion case; do not invent other IDs or replacement-driver details. Use the supplied records and label all values/actions illustrative.
- Preserve the source's demo-only and uncleared name status. Do not import Logistify logos, imagery, sound, or font files. Use the approved Fablebook vocabulary and product-copy corrections, and do not invent logistics policy.

### Mount and production boundary
- Accept only literal module alias/reference AST forms in the public mount macro; reject macro calls, variables, and other computed expressions before expansion.
- Keep the macro contract test and implementation in distinct PRs. The rejection test is authored first and checked against the proposed implementation locally; the hardened implementation PR and then the active test-only PR each receive their own green required hosted CI.
- Before Book code is added, run the positive production route/story exclusion checks and the negative reachable-mount compile control against the production-guard fixture. Repeat those checks against the completed operator host after Book implementation.
- Keep the canonical production mount error, current no-eval/no-input-atom rules, and existing CI gates intact. Do not add client-controlled module, code, atom, or topic selection.

### Catalog and navigation
- Use the owner-settled language: Fablebook is a UI catalog; one Book is one adopter-defined catalog; “Books” names the collection. Keep the persistent Book → group title → Scenario tree in a familiar left sidebar and show the selected screen in the main Canvas. The fixed dispatcher flow is a Journey; don't expose its implementation `Story` as a “user story.” At the root URL, open the first Scenario directly rather than requiring a one-card index step. See [INT-20261121-02](../../intent/sources/2026-11-21-02-ui-catalog-hierarchy-and-feedback-loop.md), [INT-20261122-01](../../intent/sources/2026-11-22-01-navigation-language-and-multiscale-coverage.md) and [the feedback ledger](../../references/OWNER-UX-FEEDBACK.md).
- Follow the pinned Fablebook brand in the UI catalog: official unchanged wordmark, Schibsted Grotesk, neutral Paper/Card/Ink/Hairline palette, and a full-outline Paper tint for the current Scenario. Keep approved Logistify treatment inside the Canvas only. Do not add broad controls, an Inspector, a command palette, a grid, or a general Journey editor.
- Keep only enough navigation to open the one Book, select its two or three screens, and revisit each at a stable URL. Unknown screen selection resolves safely. At narrow widths, stack the sidebar above the Canvas; at desktop widths, keep it persistent beside the Canvas.
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
- Use only the ignored public pin cache for source reads; do not alter preserved historical worktrees or activate the dormant brand-canon seed.

</code_context>

<specifics>
## Specific Ideas

- Keep the product surface visibly real: a local catalog, an authored compiled Book, addressable screens, and the host's Canvas—not a screenshot mock or a direct route that bypasses Fablebook.
- Prefer a source-supported short dispatcher flow; decide its exact screen content only after inspecting and hashing the reproducible source subset.
- Follow `.planning/research/2026-11-20-next-milestone-scope-review.md`, `.planning/references/logistify-brand-intake.md`, `GLOSSARY.md`, and the approved exception in INT-20261120-14.
- The owner has authorized a separate Phoenix security-pin prerequisite in [INT-20261121-03](../../intent/sources/2026-11-21-03-authorize-phoenix-security-pin-update.md). Update Phoenix to at least 1.8.17 in both dependency lanes, review only required lockfile changes, and deliver that security-only PR before remaining Phase 8 PRs. Do not broaden to unrelated dependencies.

</specifics>

<deferred>
## Deferred Ideas

- Shipper and driver Books, complete Logistify brand canon, broader sourcebook asset application, and public brand or marketing claims.
- General-purpose workbench features, Controls, URL overrides, persistence, backend behavior, bundles, broad visual matrices, and follow-on milestone work.
- Owner approval of a new or changed screenshot baseline, if the implementation produces one that needs judgment; retain as the final visual handoff after all objective work is complete.

</deferred>
