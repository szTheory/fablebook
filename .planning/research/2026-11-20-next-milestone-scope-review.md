# Immediate next milestone scope review

**Date:** 2026-11-20  
**Status:** Upstream scope selected and gate exception approved; no new milestone, requirements, or executable phase plans have been activated.  
**Owner direction:** [INT-20261120-12](../intent/sources/2026-11-20-12-upstream-milestone-scope.md); standing delta posture: [INT-20261120-11](../intent/sources/2026-11-20-11-delta-curated-rolling-roadmap.md).  
**Verification direction:** [INT-20261120-13](../intent/sources/2026-11-20-13-automated-verification-and-resource-hygiene.md).

## Reconciled starting point

- v0.6 Phase 7 and its closeout are delivered. GitHub PR #97 is merged into `main`; this checkout remains on its merged head branch `gsd/v0.6-milestone-closeout` with local planning edits. The committed tree is identical to `origin/main`; preserve the local edits and historical worktrees. No new milestone is active.
- No runnable Fablebook UI, host app, Book, or authored Logistify Scenario is present. The router still produces placeholder output.
- The open `guard-aggregate` gate explicitly blocks the original Walking Skeleton key. v0.6 did not close it; the candidate is null, caller evidence is not exhaustive, source gaps remain, SEC-01 is pending, and the caller-AST explanation remains unresolved. At the time of this evidence review there was no typed exception path. The owner approved one narrow exception afterward; see the decision record below. There is no automatic guard follow-up.
- Logistify source intake records the intended three-Book family, but its exact source files are absent from the reviewed tree. Its name is not cleared; the source layouts are recommendations rather than validated product behavior; broader asset rights and translation claims remain unresolved.
- The earlier ground-up review already reset the roadmap direction. This pass applies only the immediate-scope detail and new verification instructions; it does not re-open the product debate.

Evidence: [v0.6 closeout](../milestones/v0.6-CLOSEOUT.md), [planning gate](../references/PLANNING-GATES.json), [product roadmap](../references/PRODUCT-ROADMAP.md), [Logistify intake](../references/logistify-brand-intake.md), and [ground-up product review](2026-11-20-ground-up-product-roadmap-review.md).

## Fan-out synthesis

| Lens | Finding that changes the immediate recommendation |
|---|---|
| Product and adopter | The first useful proof should be a real, locally openable Fablebook catalog containing a Book. One fictional Book proves authoring/rendering, not compatibility with a real adopter. Pull a one-scenario context bundle and a single real mailglass component pilot into the very next follow-up; keep full dogfood clearance separate. |
| UI and brand | The smallest coherent demonstration is one dispatcher job across two or three addressable screen states. The UI catalog chrome stays neutral while Logistify styling belongs in the preview. Label all records/actions as illustrative. Use the owner’s settled user-facing terms; keep internal schema terms unchanged unless separately decided. |
| Phoenix architecture | Render through the accepted compiled Story/Scenario and host Canvas pipeline from the outset. A shortcut static page would prove the wrong architecture. Keep the operator host free of Ecto/business services and use deterministic fixtures. |
| Security | The typed aggregate still blocks the skeleton. Separately, `Fablebook.Router.fablebook/2` calls `Macro.expand(book, caller_env)`; the official [Elixir Macro docs](https://hexdocs.pm/elixir/1.18.1/Macro.html#expand/2) confirm this expands macros, not only aliases. If the public macro is used, constrain accepted AST forms and prove rejection of arbitrary macro expressions. Keep its contract test and implementation in separate PRs (ADR 0021). Retain production route/story exclusion checks and all no-eval/no-input-atom rules. |
| Verification and operations | Most objective acceptance should be automated, in this order: schema/fixture/format checks, compile, focused renderer and LiveView tests, one browser run for real asset/CSP/layout/accessibility facts, then unchanged core/floor/security/Dialyzer hosted gates. Fablebook's recorded `act` attempt cannot run tests due the current runner-architecture mismatch; do not retry unchanged setup. The browser baseline remains human-approved. Do not introduce Docker unless it materially helps. |
| Dependencies and maintenance | No new runtime dependency, Node requirement, database, or full backend is justified. Reuse the current Phoenix/Elixir stack and optional existing browser tooling. Put checks in recurring CI only when they guard recurring behavior; compare measured CI critical paths without trading away coverage. |

Primary-source technical notes already verified for this roadmap are preserved in [UI roadmap research](2026-11-20-ui-roadmap-primary-sources.md), including Phoenix LiveView security, LiveViewTest, Phoenix Storybook host-bundle tradeoffs, Storybook's initial-state/interaction distinction, Elixir macro semantics, and WCAG 2.2. No second ecosystem sweep is needed unless a selected requirement changes.

## Recommendation: candidate v0.7 — First inspectable Book

**Outcome:** A Phoenix developer can start the local host, open Fablebook's UI catalog, select a Logistify operator Book, and inspect a short, source-cited user flow across two or three screens with fixed sample data. The screens render in the accepted host Canvas pipeline and host assets. The workflow is plainly illustrative; it does not claim to save or update shipment records.

This is the smallest result that simultaneously shows actual Fablebook UI, the core Book/Scenario concept, and the host-fidelity differentiator. It moves product value ahead of more broad guard inventory while preserving existing architecture. If activated, the next global phase number is 8; assign it only during milestone activation.

### In-scope outcome boundaries

- Make the Logistify source content required for this slice reproducible and hash-pinned in the reviewed repository before applying it. Use only the approved textual/token subset; do not import unreviewed artwork, sound, or fonts. Keep the uncleared fictional name and demo content internal/local until their use is cleared.
- Map one source-supported dispatcher job, persona, and domain terms to a compact Book and a linear user flow with two or three addressable screens. Keep Story, Scenario, Screen, and Journey internals aligned to accepted ADRs and `GLOSSARY.md`; follow the owner’s explicit product-copy corrections from [INT-20261111-06](../intent/sources/2026-11-11-06-fablebook-brand-intake.md) rather than copying conflicting sourcebook language into UI claims. Do not silently rename schema or glossary objects.
- Render compiled, reviewed Scenarios with deterministic local fixtures through the real host Canvas; keep the Fablebook catalog neutral, the preview branded, and any actions clearly illustrative. Include one normal case and one meaningful source-supported edge/error case; do not invent logistics policy.
- Provide only enough catalog navigation to select the Book and move between its screen states. Keep full Inspector, general Controls/URL overrides, command palette, comparison grid, broad Journey editor, and bundle allocator out of this milestone.
- The reviewed tree has no host apps yet. Reconcile ADR 0020 with the current repository, then build the smallest real local host path needed for the Book and its actual Canvas pipeline; do not substitute a direct route or screenshot mock for host rendering. Add a second adversarial host only if a specific acceptance criterion requires it.
- Keep the mount reachable only in developer/test builds. Test positive production route/story exclusion and the negative case where a reachable production mount is rejected. No client input may select code, modules, atoms, or topics.

### Owner decision recorded: one-milestone exception

The owner approved the proposed **one-milestone exception** in [INT-20261120-14](../intent/sources/2026-11-20-14-approve-first-book-gate-exception.md): fixed, developer-authored, compiled Book in development/test only. The typed [PLANNING-GATES.json](../references/PLANNING-GATES.json) and [PHASE-MAP.json](../migrations/2026-11-11-milestone-reset/PHASE-MAP.json) now record the exact key, scope, preconditions, exclusions, and v0.7 expiry. The aggregate remains open; this is not full closure. The old `walking-skeleton` key remains blocked. Controls, user-provided values or code, audited-API use, persistence, publishing, release, and follow-on work remain outside the exception.

Before Book implementation, separately define and contract-test the public mount macro's accepted AST forms (literal module alias/reference only; reject arbitrary macro calls), then implement against that passing contract. Prove positive production route/story exclusion and a negative reachable production mount rejection first. This is a concrete product-code boundary, not a claim that user input currently reaches macro expansion. Do not treat the exception as authorization for any other milestone or feature.

### Automated exit evidence

1. Cheap first: formatting, fixture/source schema and digest checks, vocabulary/claim checks, and compile.
2. Focused Elixir tests: Book/catalog IDs and citations, deterministic rendering, route behavior, 2–3 screen navigation, unknown selection rejection, and absence of persistence or external writes.
3. Production contracts: mount rejection and positive route/story-beam exclusion controls. Keep guarded test and implementation changes in separate PRs.
4. One real-host browser pass for actual host CSS/fonts/layout, nonce CSP, keyboard navigation, semantic labels, visible focus, text-based status (not color alone), and representative narrow/desktop widths. Capture one deterministic screenshot; a missing baseline fails and any baseline change requires one owner visual-judgment checkpoint.
5. Run applicable local Actions with `act` only if the known architecture mismatch is resolved; hosted core, floor, security, and Dialyzer remain required. After CI, compare critical path and repeat-run evidence; record any safe gain or why none is justified. Preserve all gates and coverage.

No general manual UAT script is needed. The scope exception is approved. The first subjective visual-baseline approval is the expected owner handoff; automate the rest and state why any remaining check cannot be resolved by tools.

### Explicit non-goals

No full logistics app or backend, Ecto, real shipment persistence, customer authentication/authorization, arbitrary runtime story loading, public Logistify marketing/release, broad controls, complete workbench, complete state matrix, all three Books, all demo twins, full context-bundle system, adopter migration, new required dependency, or general CI/Docker refactor.

## Rolling priority after this candidate

1. **First inspectable Book:** establish the real, locally openable product surface.
2. **Thin feedback loop:** one deterministic cited Scenario bundle, one reviewed improvement, and a same-evidence rerun; then one selected real mailglass component pilot.
3. **Logistify family:** complete the distinct operator, shipper, and driver Books under the shared canon.
4. **Full dogfood:** mailglass then accrue_admin; retain the original C4 iteration threshold and keep this proof distinct from fictional Books.
5. **Need-driven product depth:** controls, broader Journeys/checks, visual/accessibility coverage, installer and remaining bundle focuses only when real usage justifies them.
6. **Showcase breadth/release:** Chatly and Clinicly, then Finanza and Shopadelic; hardening and C1–C10 release evidence last.

These are directional horizons, not activated milestones. The selected immediate scope and exception are approved, but the milestone is not activated. Requirements and phase decomposition belong to `$gsd-new-milestone` and its roadmapper; do not pre-create them in this upstream review.

## Reusable GSD handoff

The scope and exception are owner-approved. After context reset, begin with `$gsd-new-milestone First Inspectable Book` so OpenGSD creates the active requirements and phase roadmap. **Do not call `$gsd-autonomous` before that step**: its workflow requires an active `ROADMAP.md` and `STATE.md`. Once the new milestone roadmap is created and approved within OpenGSD's normal boundary, run `$gsd-autonomous` with no range flags through every phase and the normal verification, review, delivery, and closeout gates.

For every phase discussion, start from this scope and do a small, domain-specific evidence fan-out; do not redo the full portfolio review. For every verification step, follow [VERIFICATION.md](../VERIFICATION.md) and [CI-PERFORMANCE.md](../CI-PERFORMANCE.md): automate useful objective checks, start cheap, use throwaway checks when useful, keep recurring CI only where it protects recurring behavior, and preserve the known `act` stop unless the runner changes. Do not ask for routine confirmations. Stop only at a missing material owner authority, changed risk, or required boundary; no instruction here authorizes bypassing it.
