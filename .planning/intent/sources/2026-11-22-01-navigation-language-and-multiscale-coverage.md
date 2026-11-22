---
id: INT-20261122-01
date: 2026-11-22
source: Direct owner messages while inspecting the local Phase 8 UI
captured_by: Codex
supersedes: INT-20261121-02 user-facing hierarchy label for the fixed dispatcher flow only
context: Clarifies navigation behavior, community terminology, the visible name for the multi-screen dispatcher flow, a future Canvas appearance control, and the long-term need for coverage at every UI tier.
---

# Owner feedback: make navigation and the scope legible

**Date:** 2026-11-22
**Provenance:** Direct owner messages while reviewing `http://127.0.0.1:4005/admin/dev/fablebook` and its selected dispatcher scenarios.

> “are the breadcrumbs supposed to work? they do nothing for me i would thin kthey should work for nav? [Image #1] btw what is convention for these thihngs are they called workbenches or UI catalog? i went with UI catalog b/c i didnt know but i think maybe we should start to align with whatever the broader storybook/storybook-like community calls them so that we aren't inventing our own language/conventions unnecessarily.”

> “Maybe we just haven't gotten around to that yet, but I'm just kind of giving you a stream of consciousness, off the cuff feedback, having seen this screen for the first time.”

> “also the way this sidebar is designed i guess yeah the point was fablebook has a relativel \"neutral\" brand to let the actual UI being presented itself shine, but the design here is not very clear like it's kind of sloppy and not pro graphic designed, it just looks .... rough and not clear what the content hierarchy is can u clean it up and also apply impeccable UI skill to it.. [Image #1]”

> “So, yeah, also when I'm looking at this sidebar, it says story dispatcher recovery. That's not clickable. Should it be clickable or what? If it's not clickable, I guess that's fine. I just want to understand. And also, story, I feel like, is that the right language here? Like, what is that? A user flow? User story? Maybe we should put user story to make it a little clearer instead of just story by itself.”

> “Also, I would have expected that, like, whenever we're building out scenarios or whatever we're calling these. well first of all i feel like you should also be able to click around somewhere in the top not just the sidebar so like we're int he dispatcher recovery \"story\" or whatever right... shouldnt the scenario itself be part of the breadcrumb lke if we're in http://127.0.0.1:4005/admin/dev/fablebook/book/operator?story=dispatcher_recovery&scenario=failed_shipment then it hsouldnt just be Logistify operator console / Dispatcher recovery it hsould be Logistify operator console / Dispatcher recovery / A failed shipment”

> “and also u should be able to easily clck around at the top of the screen perhaps underneath the breadcrumb tho i'd think be able to click between the scenarios too the peer/sister scenarios or wahtever....”

> “But yeah, I also wanted to say, like, whenever we're working on a scenario, shouldn't we be breaking out all of the individual primitives, patterns, areas, screens, or whatever into Fablebook as well? Like, because I think that's where the AI LLM driven design would shine is like, yeah, the holistic stuff is important, but we have to be able to also consider the individual, like, sub components, like, The granularity from small to large across the whole spectrum because otherwise it's harder for us to iterate rapidly on the smaller primitives or groups of primitives or whatever we're calling them as well. There's a lot of things to consider, like the happy paths, error cases, boundary conditions. It can become a lot. And then if we don't have the ability to drill down into those individual cases, we're going to lose a lot of the edge cases. We'll get blind spots in our design.”

> “Maybe there should be some kind of like picker for light or dark mode or system mode? Maybe in the top right or something? Because right now it looks like it's kind of just defaulting to dark mode version of Logistify, which is fine, but it would be nice if we had a picker for that.”

## Reconciliation

- Make the path explicit in the main panel: Book → Dispatcher recovery → Scenario. The current Scenario is the last breadcrumb item; Book and the scenario group are links. The group link navigates to its first Scenario. Add a compact navigation row for sibling Scenarios near the breadcrumb while retaining the sidebar tree.
- Do not call this a “user story.” The owner is asking about a dispatcher job across screens. Fablebook defines a Journey for an ordered job across Scenarios; `Story` is a component's catalog entry. This fixed dispatcher group represents a Journey, but the compiled `Fablebook.Story` module and `story` query key remain implementation details. Omit the bare `Story` label from this screen's user-facing tree.
- Reuse Storybook's familiar structure and terms where they match: sidebar tree, breadcrumb, Scenario links and Canvas. Keep Fablebook's Book, Journey and Scenario meanings distinct. Storybook's docs describe a Story as a rendered component state and use “component explorer” for the category of tool; this two-screen application flow is broader than a component explorer.
- A Canvas light/dark/system selector is a future Global, distinct from Fablebook catalog Appearance and from a Book's brand Theme. The current Phase 8 scope excludes Controls and URL overrides, so this is recorded for future planning and is not implemented here.
- The current v0.7 Book proves one fixed screen-level journey. It does not claim component-level coverage. Future Book work must make the Primitive → Pattern → Area → Screen ladder and happy, error, boundary and other applicable state classes inspectable, so the first screen flow does not conceal the broader product requirement. This reinforces the existing North Star and rolling roadmap; it does not expand v0.7.
- Keep the Impeccable pre-presentation pass focused on readable hierarchy, clear link affordances, keyboard access, responsive content priority, accurate domain labels and explicit coverage limits.

## Evidence references

- [Storybook: Browse Stories](https://storybook.js.org/docs/9/get-started/browse-stories)
- [Storybook: Naming components and hierarchy](https://storybook.js.org/docs/8/writing-stories/naming-components-and-hierarchy)
- [Storybook tutorial: Component explorers](https://storybook.js.org/tutorials/visual-testing-handbook/react/en/component-explorers)
- [Fablebook glossary](../../../GLOSSARY.md)
- [Fablebook product roadmap](../../references/PRODUCT-ROADMAP.md)
