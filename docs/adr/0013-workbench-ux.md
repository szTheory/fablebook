# 0013. Workbench UX

**Status:** Accepted · **Cites:** INT-20261028-01, INT-20261028-04 · **Detail:** `docs/research/UX-DESIGN.md`

## Decision
- **Layout:** three panes (sidebar, canvas, inspector). The inspector sits on the right at 1280 px and wider, becomes a bottom drawer from 768 to 1279 px, and a bottom sheet below 768 px. The toolbar belongs to the canvas, and **every tool shows its current value as text**. A tool appears only when it can change the render.
- **Story view:** a story opens on **All scenarios** (a grid). Each tile shows the situation line, a check status, and a scenario-scoped Copy for LLM action. **The story header is the docs**: description, Reference (attrs and slots), then the grid. There is no separate Docs mode.
- **Commands:**
  - ⌘K palette covering stories, scenarios, pages, canon entries and commands.
  - `/` filters the sidebar.
  - The keyboard map is in UX-DESIGN.md. Single-key shortcuts can be turned off and are suspended while focus is in the preview.
- **URLs:** all state lives in the URL, so a "Copy finding link" reproduces exactly.
- **Narrow screens:** below 768 px the workbench becomes Mobile layout. A QR "Show on phone" action has an honest unavailable state.
- **Appearance:** workbench Appearance (System, Light, Dark) is a separate setting from the preview Theme.
- **Visual system:** ink-on-neutral chrome with no brand hue, system fonts, and `fb-` tokens in OKLCH. Light and dark are designed separately, with `prefers-contrast` and `forced-colors` support. Two density modes. 120 ms and 180 ms motion, and the workbench never animates the canvas (the subject's own motion always plays).
- **CSS:** Tailwind v4 with `source(none)` and the default namespaces reset. **No daisyUI in the chrome.** Heroicons are vendored.
- **Accessibility:** WCAG 2.2 AA for the chrome itself, and the chrome passes its own sweep at 320 px.

## Won't build (1.0)
An addon marketplace, white-labelling, an MDX format, saving playground edits to disk, auto-permutation grids, inline mode, comments, a hosted VRT service, Figma sync, an interaction recorder, localized chrome, or MCP.

## Amendments (grilling, 2026-10-28)
- **Compare** mode: renditions side by side that differ in exactly one respect (a global, a theme or direction, or a revision against main), at any tier. (INT-20261028-10)
- **To review** page (the review queue): a sidebar count badge, no pop-ups. (INT-20261028-09)
- **Device frames:** none, phone, tablet, laptop or desktop. Generic outlines. Phone and tablet show safe areas and standalone (PWA) display. **Export image** writes framed PNGs. (INT-20261028-14)
- **Motion panel** (ADR 0025); **Isolate** mode (`F`); **Mobile layout** below 768 px.
- Sidebar order: To review · Foundations · Primitives · Patterns · Areas · Screens · Journeys · Pages · Unstoried.
