# Ground-up product and roadmap review

**Date:** 2026-11-20  
**Status:** Directional recommendation for owner selection; no milestone activated.  
**Owner request:** [INT-20261120-10](../intent/sources/2026-11-20-10-ground-up-ui-first-roadmap-review.md)  
**Research sources:** [Primary-source implementation research](2026-11-20-ui-roadmap-primary-sources.md), [v0.6 reconciliation](2026-11-19-v0.6-guard-scope-reconciliation.md), [source discovery](2026-11-19-ex177-source-discovery.md).

## Executive recommendation

Fablebook's purpose is to make real Phoenix LiveView UI states easy to inspect, reproduce, verify, and explain to people and AI tools. The product payoff is a short loop: select a real job, inspect its screens and states in the adopter's actual Phoenix host, collect useful evidence, make a reviewed design improvement, and verify the same screen again.

The next investment should create that visible loop. Stop broad guard inventory work by default; v0.2–v0.6 delivered evidence and one dependency security patch, but no product UI and no complete aggregate closure. Preserve the direct security rules. Before any product code crosses the current gate, resolve the concrete `Fablebook.Router.fablebook/2` compile-time AST boundary, then ask for an explicit owner decision about a narrow, dev/test-only first-UI exception. Do not claim the aggregate is closed or silently change the typed gate.

If authorized, make the first product milestone a **minimum inspectable Logistify operator Book**: a real Phoenix host, a small catalog/navigation surface, one sourced job represented by an ordered Journey and a few fixed Screen scenarios, and a readable canvas using the host's actual layout and assets. Use deterministic fixture data and no business backend. Include only the security, accessibility, host-fidelity, and visual checks needed to support that slice. Then prove the core value with one cited context bundle, one owner-reviewed design improvement, and a repeat check before expanding the showcase.

This does not discard the existing 127-requirement inventory, ADRs, or 35-phase decomposition selected in [INT-20261028-16](../intent/sources/2026-10-28-16-approve-35-phase-roadmap.md). Keep them as traceability and longer-term completeness. They do not need equal near-term priority, and they are not an automatic sequence of milestones.

## Product purpose and first users

Fablebook is an Elixir/Phoenix library and developer workbench, not a business application or a brand-book viewer. A Book catalogues a product's UI; Stories describe components or screens; Scenarios make particular real states addressable; Journeys connect relevant screens to a user's job. The workbench should render those screens through the host application's real layout, CSS, fonts, hooks, and CSP.

The confirmed early users in [PERSONAS-JTBD.md](../../docs/research/PERSONAS-JTBD.md) are the evaluator, AI coding agent, and owner building Phoenix UIs. Their first useful outcomes are:

- **Evaluator:** install or run a host and immediately open a real screen in context.
- **Owner / small-team developer:** find a screen, inspect its job and states, and see the same host styles and layout that the app uses.
- **AI coding agent:** receive a bounded, cited bundle of the relevant screen, markup, accessibility information, and product/canon context; make a focused proposal that a person can review.

Other personas in the original research are explicitly assumptions. Validate those before making them milestone blockers. The Book must be honest about what is simulated: fixed local data and documented steps can represent a workflow without claiming that shipment records were saved or backend operations occurred.

## Current product reality

- v0.6 closed successfully and its delivery checks passed, but it was an evidence and dependency-maintenance milestone.
- The tracked package has a router macro and a text placeholder, not a usable Workbench. There is no `hosts/` directory, applied Fablebook canon, Fablebook Book, or Logistify scenario in the reviewed tree. See [router](../../lib/fablebook/router.ex), [placeholder](../../lib/fablebook/placeholder.ex), and the verified state in [PRODUCT-ROADMAP.md](../references/PRODUCT-ROADMAP.md).
- The guard aggregate remains open. v0.6 left a proposed seven-MFA family against a 1,756-MFA core complement, four source gaps, non-exhaustive caller observations, and five closed source requests. It does not provide a finite gate-closing increment.
- The gate currently blocks the Walking Skeleton. The user's UI-first direction does not itself change that typed prerequisite.
- Fablebook's v2.1 sourcebook and the Logistify v1.0 sourcebook are inputs, not applied canon or runnable Books. Keep the recorded hashes, source custody, rights, and vocabulary reconciliation attached; do not spend another milestone merely rereading them.

## Evidence and provenance retained

| Evidence class | High-signal source | How it informs this recommendation |
|---|---|---|
| Owner-confirmed product purpose | [NORTH-STAR.md](../intent/NORTH-STAR.md), [INT-20261028-01](../intent/sources/2026-10-28-01-project-vision.md), [INT-20261028-04](../intent/sources/2026-10-28-04-owner-motivation.md) | Real UI fidelity, AI-readable context, security by construction, small-team Phoenix DX. |
| Owner-confirmed showcase | [INT-20261120-08](../intent/sources/2026-11-20-08-define-showcase-books-not-full-demo-apps.md), [INT-20261111-13](../intent/sources/2026-11-11-13-approve-rtt-guard-slice-and-brand-dogfood-roadmap.md) | Three distinct Logistify Books; record screens/workflows/states, not complete business systems; operator console first. |
| Owner-confirmed priority | [INT-20261120-09](../intent/sources/2026-11-20-09-prioritize-visible-ui-work.md), [INT-20261120-10](../intent/sources/2026-11-20-10-ground-up-ui-first-roadmap-review.md) | Visible UI work is primary; no broad guard increment by inertia; preserve the current gate unless separately changed. |
| Locked architecture/security | [ADRs](../../docs/adr/README.md), especially 0002, 0003, 0004, 0006, 0011, 0013, 0018, 0020, 0021, 0022, 0024 | Compiled stories, plain-function scenarios, real host pipeline, no eval/no input-atoms, production exclusion, lean dependencies, test/PR separation, and static render seam. |
| Original independent project research | [SUMMARY](SUMMARY.md), [ARCHITECTURE](ARCHITECTURE.md), [FEATURES](FEATURES.md), [PITFALLS](PITFALLS.md), [STACK](STACK.md), all researched 2026-10-28 | Keep the Phoenix-native catalog, deterministic model, real-host rendering, realistic state coverage, and context-bundle differentiators. Preserve the detailed source files; revalidate dated competitor/version claims when they affect a real decision. |
| User, design, and adopter research | [PERSONAS-JTBD](../../docs/research/PERSONAS-JTBD.md), [TWINS](../../docs/research/TWINS.md), [UX-DESIGN](../../docs/research/UX-DESIGN.md), [LESSONS-LEARNED](../../docs/research/LESSONS-LEARNED.md), [LLM-CONTEXT-AND-CANON](../../docs/research/LLM-CONTEXT-AND-CANON.md), [MOTION-AND-UX-DIMENSIONS](../../docs/research/MOTION-AND-UX-DIMENSIONS.md), [QUALITY-PERF-SRE](../../docs/research/QUALITY-PERF-SRE.md) | Preserve realism, workbench/preview separation, accessibility, reproducible review, and the AI critique loop; do not elevate assumed personas into confirmed requirements. |
| Brand provenance | [Fablebook intake](../references/fablebook-brand-intake.md), [Logistify intake](../references/logistify-brand-intake.md) | Pinned sourcebooks exist, but source custody, rights, names, and current-tree reproducibility remain separate from applied canon and Books. |
| Current ecosystem primary sources | [Phoenix Storybook source/docs](https://github.com/phenixdigital/phoenix_storybook), [LiveView security model](https://phoenix-live-view.hexdocs.pm/security-model.html), [LiveViewTest](https://phoenix-live-view.hexdocs.pm/Phoenix.LiveViewTest.html), [Storybook interaction testing](https://storybook.js.org/docs/writing-tests/interaction-testing), [Elixir Macro docs](https://hexdocs.pm/elixir/1.18.1/Macro.html#expand/2), [WCAG 2.2](https://www.w3.org/TR/WCAG22/) | Validate the real host setup, untrusted LiveView parameters, server-rendered event tests, useful story/render-test pattern, compile-time macro semantics, and accessibility baseline. Full external source notes are in [primary-source research](2026-11-20-ui-roadmap-primary-sources.md). |

The 2026-10-28 research remains valuable for architecture, failure modes, and design goals. Its competitor versions and ecosystem comparisons are time-sensitive; treat them as historical evidence until rechecked. New inferences in this review are labeled as recommendations below, not owner-confirmed product facts.

## Recommended milestone order

These are **proposed outcomes, not activated milestones or executable requirements**. Do not assign new active phase IDs until the owner selects a scope and its typed prerequisites are updated. Phase numbering continues globally; Phase 8 is next only if a future milestone activates.

| Priority | Proposed outcome | What a person can see or prove | Scope boundary |
|---|---|---|---|
| **0 — unblock safely** | Resolve the mount AST boundary and obtain an explicit decision on the Walking Skeleton gate. | A small review proves exactly what `book` expressions `fablebook/2` accepts. The production exclusion has positive and negative controls. The owner can choose whether a single fixed, developer-authored scenario may proceed with the broad aggregate still open. | This is the only immediate authority boundary. `Macro.expand/2` expands local/remote macros as well as aliases; fixed runtime data does not settle compile-time AST behavior. Do not implement a UI or silently revise `.planning/references/PLANNING-GATES.json` before the decision. |
| **1 — first real Book** | Minimum inspectable Logistify operator Book, using a vertical slice of the existing Walking Skeleton, Story model/catalog, render seam, and Workbench shell. | Open Fablebook in a real Phoenix host. Navigate from one dispatcher job to a short Journey and a few Screen scenarios. See named situations with deterministic sample data, real host CSS/layout, and an honest indication that workflow actions are illustrative. | No database, queues, or full logistics app. No arbitrary code execution, client-selected modules, or general Controls. Use only the minimum Journey model needed to connect screens. Resolve Logistify source custody before applying restricted assets. |
| **2 — prove the value loop early** | A single cited evidence bundle and one reviewed design iteration on the first Book, followed by a small real-host pilot in mailglass. | The owner or agent sees the screen's job, relevant product/canon context, screenshot/markup/accessibility details; applies a focused critique; reruns the same checks. One actual adopter component confirms the solution works outside the fictional host. | Start with one useful bundle focus and representative capture. Do not build the full allocator or every focus. Select a high-reuse mailglass component from its actual catalog; this pilot is early reality checking, not full dogfood clearance. |
| **3 — complete the Logistify showcase** | Three separate Books: operator console, shipper portal, driver app, under the shared brand canon. | Each Book exposes its own jobs, screens, states, and mapped Journey steps. The first user can browse them in the same Fablebook workbench. | Use authored fixtures; do not build business backends. Keep terminology grounded in `GLOSSARY.md`; a logistics Route is not automatically a Fablebook Journey. |
| **4 — full adopter dogfood** | Continue with mailglass, then accrue_admin, until the existing owner-iteration and clearance evidence is met. | Real adopter work produces reviewed UI improvements from Fablebook bundles and repeatable evidence; dogfood and authored showcase remain separately reported. | Inspect catalogs before selecting screens and preserve existing C4/C1–C10 criteria; don't infer coverage counts or treat the early mailglass pilot as clearance. |
| **5 — expand only where the first loop needs it** | Add safe Controls/URL state, broader Journey checks, accessibility and visual coverage, host isolation/diagnostics, installer/DX, and more bundle focuses. | Each capability removes a demonstrated limitation in authoring, review, or adoption. | Keep direct no-eval/no-atom proofs before accepting user-controlled values. Start with cheap parser/model/render checks; run a browser only for host/CSP/layout/interaction facts. Keep screenshot counts and CI cross-products small until measured. |
| **6 — broaden and clear release** | Chatly and Clinicly for CJK/mobile and RTL/accessibility coverage; then Finanza and Shopadelic for money, imagery, and white-label; complete installer/docs/hardening and 1.0 clearance. | The full clearance scorecard has evidence, both adopter repos dogfood Fablebook, and the owner prefers it for daily work. | Maintain source/asset rights and the existing C1–C10 release criteria. Do not confuse a successful showcase with release readiness. |

### Why prioritize a vertical Book over another planning split

The current map separates the skeleton, story model, render seam, Controls, Canvas, Workbench, canon, Journey checks, bundles, and showcase content across many future slots. Each capability has a reason, but in that order it delays the first useful browser result. The smallest re-sequence should combine only the dependencies needed to open one real Book: one compiled Story/Scenario, deterministic catalog identity, a shared render seam, minimal navigation, one Journey linking screen addresses, and the real host pipeline. Keep advanced controls, whole-catalog coverage, multiple twins, motion, broad bundles, and release hardening in their existing later horizons.

This is a recommendation to re-sequence selected future work, not permission to ignore typed dependencies. If chosen, update the phase map and gates explicitly before executable milestone requirements are written.

### How this preserves and updates the original research

The 2026-10-28 research remains the detailed technical and product sourcebook. This review changes priority, not the architecture or approved scope: keep compiled Stories, plain-function Scenarios, deterministic catalog identity, the shared render seam, host-owned rendering, and small bounded increments. Preserve the full 127 requirements and 35-phase mapping for traceability; do not treat their old order as a requirement to delay the first visible result. Keep the rule to split work above the plan cap instead of compressing it (SUMMARY, ARCHITECTURE, INT-20261028-16, ADR 0021).

Two especially useful original sequencing findings are applied here: pull one thin cited bundle close to the first rendered Scenario, and validate a real adopter host earlier than the old dogfood phase. The proposed early mailglass pilot addresses the latter with one inspected, high-reuse component; it does not satisfy full dogfood clearance. The complete bundle allocator, other focuses, broad visual/state matrices, and full mailglass/accrue_admin iterations remain later work (FEATURES §9, ARCHITECTURE §Phase-by-phase audit, INT-20261113-01).

The original product/design research remains binding context: the Book hierarchy and distinct Logistify operator/shipper/driver jobs; Fablebook's neutral chrome versus branded preview; realistic data and state coverage; keyboard/accessibility/responsive review; sourced brand and vocabulary; manual review for taste and visual baselines; and the distinction between authored fictional products and real adopter repositories (PERSONAS-JTBD, TWINS, UX-DESIGN, LESSONS-LEARNED, LLM-CONTEXT-AND-CANON, MOTION-AND-UX-DIMENSIONS, QUALITY-PERF-SRE, INT-20261113-01, INT-20261120-08).

Keep all source intakes and conflicts attached to provenance. The Logistify files are currently absent from the tracked tree, the name is uncleared, recommendations are not shipped product behavior, German/French examples are not translations, and broader artwork reuse remains undecided. Reproducible source capture and rights-aware use belong before applying the brand to Books; a safe token/typography slice can precede any asset publication. The Fablebook 2.1 intake also has product vocabulary and asset-destination decisions that must be reconciled against the current glossary/ADRs before copy or canon changes (brand intakes and their linked owner intents).

The engineering preferences carry forward as well: no arbitrary evaluation or input-created atoms, stories excluded from production, no required Node or unnecessary runtime dependency, focused cheap checks before browser/CI work, and retain both required lanes. The 2026-10-28 stack/competitor comparisons are dated research, not current dependency recommendations; refresh only the facts a selected milestone uses.

## Gate and technical decision

The current `guard-aggregate` gate is open and blocks Walking Skeleton. v0.6 evidence does not close it and does not name a finite completion increment. A fixed scenario is a compelling way to return product value, but it is not itself approval to bypass the gate.

The most direct unresolved product-code boundary is [`Fablebook.Router.fablebook/2`](../../lib/fablebook/router.ex#L35): it expands the `book` argument at compile time. Official Elixir docs say `Macro.expand/2` expands aliases and local/remote macros. Therefore a future narrow path should first constrain and test accepted AST (e.g. accept an alias/module reference and reject arbitrary macro calls) or retain the stop. ADR 0021 requires the implementation and its guarding contract test to land in separate PRs.

**Recommendation:** prefer one owner-signed, one-milestone exception for a fixed compiled scenario after this exact AST boundary and production exclusion are proven. Keep the aggregate visibly open, do not call it complete, and keep Controls, user-provided code, URL-selected modules, generated templates, and release blocked by their own direct safety acceptance. If the owner does not accept that bounded residual risk, preserve the gate and only continue if a genuinely finite full-closure path is evidenced; don't schedule another broad scan on hope.

## Efficient quality loop

For the first slice: (1) schema/fixture validation, formatter and compile; (2) focused pure renderer/LiveView tests; (3) one host browser check for the actual CSS/font/CSP/layout claim; (4) one screenshot with an explicitly present, human-approved baseline; (5) existing full required lanes and hosted delivery. Phoenix.LiveViewTest already supports rendering components and driving bound events; reserve the browser for behavior those tests cannot establish. Do not add a package to adopters' runtime or require Node. The original CI performance evidence says installed-OTP inventory dominates current pipeline time, so don't increase visual cross-product jobs or change concurrency/caching without measurement.

## Provenance integrity

- Preserve the 2026-10-28 research and all accepted ADRs as source history; link findings instead of copying them into new requirements.
- Keep owner statements verbatim in `intent/sources/`; distinguish confirmed intent from researcher assumptions and new recommendation.
- Keep `.planning/milestones/v0.6-*` immutable. This review does not revise its receipts or claim security aggregate closure.
- Keep the detailed future phase map and C1–C10 scorecard for traceability. Reorder only a selected, owner-approved path; never silently delete scope or weaken a gate.
- Do not mark sourcebook, applied canon, Books/Scenarios, runnable UI, and dogfood as the same progress stage.
