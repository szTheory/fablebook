# Owner UX feedback ledger

This is a short, reusable checklist distilled from direct owner feedback. The dated sources remain authoritative: [INT-20261121-02](../intent/sources/2026-11-21-02-ui-catalog-hierarchy-and-feedback-loop.md), [INT-20261122-01](../intent/sources/2026-11-22-01-navigation-language-and-multiscale-coverage.md), [INT-20261122-04](../intent/sources/2026-11-22-04-sidebar-scenarios-and-quiet-canvas.md), and [the 2026-11-25 Journey review correction](../intent/sources/2026-11-25-01-restore-book-journey-navigation.md). Update this ledger when feedback reveals a durable pattern; do not turn one-off preferences into product rules.

## Resuming reviewed UI

- On resumed or post-OpenGSD UI work, reconcile the latest owner-reviewed live behavior with the active checkout, UI-SPEC and plan before implementation. New owner corrections supersede stale plan language; previously working navigation and visual cues become explicit regression checks.
- A local preview is ready only after confirming the listener belongs to the intended checkout and the requested route renders in a browser from that running server. Keep the server in a persistent session; a one-time HTTP response from a process that is about to exit is not a ready preview.
- Keep browser captures local and out of public PRs unless the owner explicitly asks to publish them.

## Product language

- Call the product surface the **UI catalog**. Fablebook is a UI catalog for Phoenix LiveView. Do not use “workbench” as user-facing copy.
- A **Book** is one adopter-defined catalog. **Books** is the navigation label for the collection of available Books. Do not label that collection “Catalog.”
- The runtime `Fablebook.Catalog` is the resolved contents of one Book. In product copy, call that one catalog the Book or its contents; do not imply a second nested Catalog.
- Keep Book, Story, Scenario and Canvas distinct, and check every user-facing label against [GLOSSARY.md](../../GLOSSARY.md) and the pinned Fablebook source. Do not invent a second meaning for an existing product term.
- A Storybook “story” is a rendered component state, not an agile “user story.” Use Fablebook’s **Journey** for a real ordered job across screens; reserve **Story** for the component catalog entry defined in the Fablebook glossary. In a Journey tree, show the group title and label its child list **Scenarios**, without a bare “Story” label. Do not expose an implementation module name as user-facing taxonomy when it misdescribes the content.
- Reuse community structure terms when they fit: sidebar tree, breadcrumb, Canvas, and linked Scenario navigation. Keep product-specific terms where the underlying object differs; “component explorer” is a useful category comparison, not a replacement name for Fablebook's broader UI catalog.

## Information hierarchy and flow

- Prefer familiar, proven navigation when there is no concrete user benefit to a new pattern: a persistent left sidebar for the catalog tree, with the selected UI in the main Canvas.
- Show the useful content immediately. With one available Book, the local UI should open on its first inspectable screen instead of making the user pass through a one-card index first.
- Make the hierarchy legible at a glance: Book → Journey → Scenarios → Scenario, with the selected item and its Canvas easy to identify. Selecting a Journey opens its Scenario overview in the main panel; preserve stable direct links.
- Put the Book → Journey → Scenario location in the main-panel breadcrumb. Keep the Book title plain, link the Journey to its overview, mark the current Scenario as the final item, and offer sibling Scenario links near the breadcrumb.
- Before implementation, state the primary user flow and job to be done. The current developer job is: “When I open a local UI example, I want to browse its structure in a familiar sidebar and see the selected screen in the main Canvas, so I can understand and inspect what the catalog contains.” This is a derived summary, not a new owner quote.

## Fablebook UI design

- Apply Fablebook’s pinned brand according to its actual guidance: calm, neutral catalog chrome; use the Fablebook mark/wordmark and Schibsted Grotesk where the surface calls for them; keep application styling inside the Canvas. Gilt remains in the approved logo/ribbon use only.
- Familiarity and precision matter more than novelty on an operating surface. Avoid filler text, extra navigation, and styling that could belong to any generated dashboard. Journey overview Scenario cards are direct navigation for a selected Journey, not a generic Book index. Keep the active sidebar bookmark marker visible.
- Keep source provenance reviewable in authored data and checks, but keep raw file paths and JSON Pointer dumps out of the user-facing Scenario unless they help someone inspect or act.
- Treat the selected Canvas color scheme as a future Global, not the Fablebook chrome Appearance or the Book's Theme. Record a request for System/Light/Dark selection, but honor active phase limits on Controls and URL overrides.
- Be explicit about coverage: a first screen-level Book is not a component catalog. Future work should expose the Primitive → Pattern → Area → Screen ladder and relevant happy, error, boundary and other state classes without fabricating unsupported examples.
- Use the Impeccable skill for hierarchy, copy, layout, responsive behavior and rendered-result review. Treat its findings as design evidence; do not use detector suppressions to avoid fixing a real issue.

## Pre-presentation adversarial pass

Before showing UI work to the owner, check:

1. Can a new user tell what Fablebook is, what the current Book is, what is selected, and where the actual UI is rendered?
2. Does the first viewport let them inspect useful content without an unnecessary catalog-to-Book detour?
3. Does navigation follow the product terms and hierarchy in the glossary, brand book and active scope? Is each breadcrumb either a useful link or plain text, can the Journey overview reach every Scenario, and is the active sidebar item obvious?
4. Does the visible Fablebook identity follow the pinned neutral-catalog rules without competing with the application Canvas?
5. Do keyboard order, focus, responsive layout, long labels, empty/error states and citations remain clear?

Capture the actual rendered result at representative widths. Keep a new or changed visual baseline unaccepted until the owner reviews it, and ask for that judgment only after the objective work is complete.

## Feedback history

| Date | Source | Reusable lesson | Applied to |
|---|---|---|---|
| 2026-11-21 | [INT-20261121-02](../intent/sources/2026-11-21-02-ui-catalog-hierarchy-and-feedback-loop.md) | Use a sidebar-to-Canvas hierarchy; distinguish the Fablebook UI catalog from the Books collection and each Book catalog; preserve reusable feedback as a pre-presentation review. | Phase 8 local operator UI and vocabulary; future UI planning checklist. |
| 2026-11-22 | [INT-20261122-01](../intent/sources/2026-11-22-01-navigation-language-and-multiscale-coverage.md) | Make the full breadcrumb and sibling Scenario navigation work; call the authored cross-screen job a Journey, not a user story; keep Canvas color scheme and tier coverage visible as future requirements. | Phase 8 local UI refinement; future Globals and multiscale Book planning. |
| 2026-11-22 | [INT-20261122-04](../intent/sources/2026-11-22-04-sidebar-scenarios-and-quiet-canvas.md) | Label the Scenario child list in the Journey tree; preserve source traceability without rendering raw pointer lists in the Canvas. | Phase 8 local operator UI and future source-backed Book presentation. |
| 2026-11-25 | [Journey review correction](../intent/sources/2026-11-25-01-restore-book-journey-navigation.md) | A selected Journey opens a main-panel Scenario overview; the Book breadcrumb is plain text; keep the selected bookmark cue and white main/Canvas surfaces. | Phase 8 live review correction. |
