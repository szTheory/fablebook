---
phase: "8"
slug: "first-inspectable-book-and-local-host-path"
status: approved
shadcn_initialized: false
preset: none
created: "2026-11-20"
reviewed_at: "2026-11-21T03:43:31Z"
---

# Phase 8 — UI Design Contract

> Visual and interaction contract for the first inspectable Book. The neutral Fablebook catalog shell stays visually distinct from the Logistify-styled content rendered by the real host Canvas.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | none (manual Phoenix/HEEx styling) |
| Preset | not applicable |
| Component library | none detected |
| Icon library | none; use text labels and simple CSS geometry only where needed |
| Font | system sans stack for UI; system monospace for IDs, codes, and source paths; no font downloads |

The catalog is a small local product surface, not a general workbench. Use restrained ink-on-neutral Fablebook chrome. Keep Logistify colors and typography inside the same-origin Canvas preview, using only the approved, cited text/token subset. Do not use unreviewed logos, imagery, sound, or fonts. Label fixture records and all depicted actions as illustrative; no preview action may imply a real dispatch or external write.

Inventory evidence: `find lib test -type f \( -name '*.heex' -o -name '*.html' -o -name '*.css' -o -name '*.scss' \) -print` returned no files. `find . -maxdepth 1 -type f \( -name 'components.json' -o -name 'tailwind.config.*' -o -name 'postcss.config.*' \) -print` returned no files. This checkout is an Elixir/Phoenix library with no existing frontend, design-system configuration, or component package; no component inventory applies.

---

## Spacing Scale

Declared values (must be multiples of 4):

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon-to-label gaps, compact inline spacing |
| sm | 8px | Label/control gaps, compact padding |
| md | 16px | Default content and control spacing |
| lg | 24px | Screen section spacing |
| xl | 32px | Major content grouping |
| 2xl | 48px | Large screen section breaks |
| 3xl | 64px | Page-level breathing room on wide screens |

Exceptions: 44px minimum height for primary navigation and interactive targets; 32px dense data rows only when all row actions remain keyboard reachable. At 320px width, reduce outer page gutters to 16px and let content reflow rather than clip.

---

## Typography

Use four sizes and two weights throughout the catalog. The embedded operator UI may use its approved source typography tokens, but only within the Canvas document.

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Dense metadata and IDs | 13px | 400 | 1.4 |
| Body and navigation | 14px | 400 | 1.5 |
| Emphasized labels | 16px | 600 | 1.4 |
| Screen title | 22px | 600 | 1.2 |

Use sentence case, tabular numerals for quantities, and no negative letter spacing. IDs and paths use the system monospace stack. Long names and citations wrap; do not truncate content required to understand a record or its source.

---

## Color

Catalog chrome uses a light, cool-neutral surface. The embedded Logistify preview owns its own approved color styling and must remain visually bounded by the neutral Canvas frame.

| Role | Value | Usage |
|------|-------|-------|
| Dominant (60%) | `#F4F6F8` | Catalog/page background and low-emphasis canvas surround |
| Secondary (30%) | `#FFFFFF` | Book card, navigation surface, and content panels, separated by a hairline |
| Accent (10%) | `#315C87` | Keyboard focus indicator and focused link outline only; do not use as a general fill |
| Destructive | `#B42318` | Reserved for an actual destructive control; none exists in this phase |

Accent reserved for: visible keyboard focus indicators only. Selected/current navigation uses an ink fill (`#1B222C`) with white text, not an accent fill. Text uses `#1B222C`; muted metadata uses `#4B5563`; borders use `#C9D1DA`. Meet WCAG AA contrast for text and at least 3:1 for focus and non-text boundaries. Pair every preview status color with a visible status word. Logistify Signal `#F0501E`, if present in the cited Canvas styling, is decorative only and never status text, an action affordance, or Fablebook chrome.

---

## Copywriting Contract

Use concise, calm, sentence-case copy. Buttons and links start with a verb. Do not use hype, exclamation marks, or copy that makes an illustrative action sound operational.

| Element | Copy |
|---------|------|
| Primary CTA | Open operator Book |
| Empty state heading | No Book is available |
| Empty state body | The local catalog has no compiled Book. Check the development or test host configuration. |
| Error state | This screen is unavailable. Return to the operator Book. |
| Destructive confirmation | Not applicable. This phase has no destructive actions. |

The preview must carry a persistent, readable notice: “Illustrative records and actions · no live dispatch or external changes.” Any action-like control shown as part of the authored scenario is non-operational and labeled “Illustrative”; use static presentation where interaction is not needed to inspect the state.

---

## Interaction Contract

- The catalog has one neutral Book entry. “Open operator Book” opens it; a clearly labeled return link returns to the catalog.
- The Book contains the smallest number of addressable screens that explains the cited dispatcher job: two screens by default, three only if the source-grounded edge case needs a distinct screen. Provide simple Previous/Next links and a short screen list; do not add a toolbar, Inspector, command palette, search, grid, editable controls, or general Journey editor.
- Each screen has a stable direct URL. Current screen is identified in text and with `aria-current="page"`. Unknown Book or screen URLs render the safe unavailable state and a working return link; never infer a module or screen from arbitrary input.
- The host shell and the Canvas document remain distinct. Render each screen through the real same-origin host Canvas and inherited host layout/assets/CSP. Give the embedded document a descriptive `title` that names the Book screen.
- All navigation is usable with Tab, Shift+Tab, Enter, and Space where appropriate. Do not add single-key shortcuts. Keep focus visible with a 2px outline and 4px offset; focus must not be covered by sticky UI.
- Use semantic `header`, labeled `nav`, `main`, and `footer` landmarks, one clear page `h1`, and ordered headings. Tables have captions and scoped column headers; status is text and never color alone. Announce screen changes and unavailable/error status through a polite live region without moving focus unexpectedly.
- At 320px and 375px, stack record details and action descriptions; at 768px and 1280px, preserve the same hierarchy with a centered, readable content column. No horizontal page overflow. At 200% text zoom, all copy and controls remain available. Respect `prefers-reduced-motion`; no transition is required for screen navigation.
- Capture one deterministic visual artifact at representative narrow and desktop widths. Do not auto-accept a new or changed baseline; owner approval is required only if the artifact is proposed as a baseline or changes an accepted baseline.

---

## UI Considerations

Applicable checks resolved: 20 explicit, 1 backstop, 0 unresolved (21 checks across four classified surfaces).

| Category | Element(s) | Status | Resolution / Reason |
|----------|------------|--------|---------------------|
| empty | Catalog list; Canvas Story content | ✅ resolved | If the local catalog has no compiled Book, show the defined empty heading and body with development/test host guidance. If a source-grounded screen has no records, preserve the screen and its citation while showing a concise empty state; do not invent a record. |
| loading | Catalog list; screen navigation; Canvas Story content | ✅ resolved | Keep the neutral host shell stable and politely announce loading. When Canvas content is ready, announce the rendered screen name without moving focus. |
| error | Catalog list; screen navigation; Canvas Story content | ✅ resolved | Unknown Book or screen URLs show the defined unavailable message and a working catalog/Book return link. A Canvas failure says, “The screen could not load. Check that the local Phoenix host is running, then reload.” Keep the local failure message inside the host shell. |
| populated | Catalog list; Canvas Story content | ✅ resolved | Show only the one compiled operator Book. Its screens contain the fixed, source-cited normal and edge/error situations, with a persistent illustrative notice. Do not add sample records outside the approved fixture. |
| partial | Catalog list; Canvas Story content | ✅ resolved | Never infer missing source-backed values. Show “Not provided in source” for an absent optional fixture value and retain the available citation. |
| overflow | Catalog list; screen navigation; Canvas Story content; citations | 🧪 backstop | At the real host, verify 320px and 1280px widths and 200% text zoom. Confirm there is no page-level horizontal overflow, clipped navigation, hidden citation, or covered focus indicator. Long values wrap and dense records stack. |
| zero-one-many | Catalog list; source-grounded Story collections | ✅ resolved | The empty catalog uses its defined copy; the catalog contains exactly one Book. Keep the same simple collection layout at zero, one, or many source-grounded rows, with correct singular/plural text. Keep fixture contents fixed and do not add multi-Book management affordances. |
| long-text | Screen navigation; Book labels, IDs, paths, and citations | ✅ resolved | Wrap long names and citations; break long IDs and paths at safe boundaries. Preserve all text required to understand a record or source; do not truncate it with ellipses. |

---

## Registry Safety

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| Not applicable | None | No component registry or third-party blocks are used. |

---

## Checker Sign-Off

- [x] Dimension 1 Copywriting: PASS
- [ ] Dimension 2 Visuals: FLAG — primary visual anchor is not declared.
- [x] Dimension 3 Color: PASS
- [ ] Dimension 4 Typography: FLAG — metadata and body sizes differ by 1px.
- [x] Dimension 5 Spacing: PASS
- [x] Dimension 6 Registry Safety: PASS
- [x] Dimension 7 Inventory Provenance: PASS

**Approval:** approved with two non-blocking flags. Reviewed 2026-11-21T03:43:31Z.
