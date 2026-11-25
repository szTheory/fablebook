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

> Visual and interaction contract for the first inspectable Book. A persistent Fablebook sidebar makes the Book → group → Scenario hierarchy legible, while the selected Logistify screen renders through the real host Canvas in the main panel.

---

## Design System

| Property | Value |
|----------|-------|
| Tool | none (manual Phoenix/HEEx styling) |
| Preset | not applicable |
| Component library | none detected |
| Icon library | none; use text labels and simple CSS geometry only where needed |
| Font | Schibsted Grotesk from the pinned Fablebook brand source; system monospace for IDs and codes |

Fablebook is the UI catalog; a Book is one adopter-defined catalog, and “Books” labels the collection in the sidebar. Use the unchanged Fablebook wordmark and Schibsted Grotesk from the exact commit in `brand_sources.lock.json`. Keep the Fablebook chrome neutral and the Logistify styling inside the same-origin Canvas. Gilt appears only in the official logo. Keep the main panel and Canvas document white. Mark the selected Journey or Scenario in the sidebar with a Paper tint, complete outline, and bookmark-shaped marker. Do not use Logistify logos, imagery, sound, or font files. Label fixture records and all depicted actions as illustrative; no action may imply a real dispatch or external write.

The local operator host uses Phoenix LiveView and one authored CSS file. Keep this UI slice dependency-free and server-rendered. The pinned Fablebook brand example at `preview/apps-workbench.jpg` establishes the useful hierarchy: logo and tree at left, selected screen in the Canvas at right. Phase 8 intentionally omits the broader toolbar, Inspector, palette, and settings shown in long-term product decisions.

### Owner clarification — 2026-11-22

This fixed two-screen dispatcher recovery flow is a **Journey**, not a “user story.” In Fablebook, a Story is the catalog entry for one component; a Journey is an ordered job across Scenarios. The current compiled `Fablebook.Story` module and `story` URL key are implementation details and remain unchanged. Storybook likewise uses “story” for a rendered component state ([Browse Stories](https://storybook.js.org/docs/9/get-started/browse-stories)); its sidebar/Canvas pattern is reused without borrowing a misleading label. Show the group title “Dispatcher recovery” and its Scenario children, but omit the bare “Story” label from this flow's user-facing navigation.

The sidebar explicitly labels the nested Scenario list “Scenarios,” between the Journey title and its Scenario links, so the child type is visible at a glance. Preserve the exact source citations in authored Scenario data and source-verification checks, but omit raw source paths and JSON Pointers from the user-facing Canvas.

### Owner correction — 2026-11-25

Selecting “Dispatcher recovery” opens a Journey overview in the main panel with links for each Scenario. The Book title in the main-panel breadcrumb is plain text; the Journey breadcrumb on a Scenario page opens that overview. The selected sidebar Journey or Scenario keeps the bookmark marker. The UI catalog main panel and the Canvas document use white backgrounds; Paper remains the selected and hovered item tint.

Show the complete Book → Journey → Scenario path in the main-panel breadcrumb, with the Book as plain text, the Journey linked to its overview, and the selected Scenario last. On the Journey overview, show all of its Scenario links in the main panel. Keep the sidebar tree and provide a compact sibling-Scenario navigation row below the breadcrumb on Scenario pages. This is navigation among authored Scenarios, not an editable Control or URL override. Do not add a Canvas color-scheme picker in Phase 8; the requested System/Light/Dark Global belongs to future scope and is distinct from the UI catalog's Appearance and the Book's Theme.

The v0.7 Book remains a screen-level proof, not coverage of the whole UI. Primitive, Pattern, Area, Screen and their applicable state classes remain a broader product requirement already preserved in the North Star and rolling roadmap.

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

Use sentence case, tabular numerals for quantities, and no negative letter spacing. IDs and codes use the system monospace stack. Long names and facts wrap; do not truncate content required to understand a record.

---

## Color

Catalog chrome uses a light, cool-neutral surface. The embedded Logistify preview owns its own approved color styling and must remain visually bounded by the neutral Canvas frame.

| Role | Value | Usage |
|------|-------|-------|
| Paper | `#F6F4EF` | Selected and hovered navigation item tint |
| Card | `#FFFFFF` | Sidebar, main panel, Canvas frame and Canvas document |
| Ink | `#17181C` | Text, selected Scenario emphasis and focus |
| Hairline | `#D9D6CE` | Dividers and Canvas boundary |
| Destructive | `#B42318` | Reserved for an actual destructive control; none exists in this phase |

There is no general accent color, shadow, or decorative texture in the UI catalog. The official logo is used unchanged. A full outline, Paper tint, and bookmark-shaped marker identify the active sidebar Journey or Scenario; the top navigation uses a full outline and Paper tint. The main panel and Canvas document are white. Meet WCAG AA contrast for text and at least 3:1 for focus and non-text boundaries. Pair every preview status color with a visible status word. Logistify Signal `#F0501E`, if present in the cited Canvas styling, is decorative only and never status text, an action affordance, or Fablebook chrome.

---

## Copywriting Contract

Use concise, calm, sentence-case copy. Buttons and links start with a verb. Do not use hype, exclamation marks, or copy that makes an illustrative action sound operational.

| Element | Copy |
|---------|------|
| Sidebar collection heading | Books |
| Book | Logistify operator console |
| Journey name | Dispatcher recovery |
| Initial screen | A failed shipment |
| Empty state heading | No Book is available |
| Empty state body | This development host has no compiled Book to display. |
| Error state | This screen is unavailable in this Book. Choose an available Scenario from the sidebar. |
| Destructive confirmation | Not applicable. This phase has no destructive actions. |

The Canvas must carry a persistent, readable notice: “Illustrative records and actions · no live dispatch or external changes.” Any action-like control shown as part of the authored Scenario is non-operational and labeled “Illustrative”; use static presentation where interaction is not needed to inspect the screen.

---

## Interaction Contract

- The UI catalog uses a persistent left sidebar with the hierarchy Books → Logistify operator console → Dispatcher recovery → its Scenarios. This group is the fixed Journey; do not expose the implementation's bare “Story” label or call it a “user story.” Do not call the Books collection “catalog.” Do not put the only Book in a dead-end card index.
- Opening `/admin/dev/fablebook` selects the first source-grounded Scenario and shows its real Canvas immediately. Selecting a Journey opens its overview in the main panel, where every Scenario has a stable link; selecting a Scenario opens its real Canvas. Keep the sidebar screen switcher and compact sibling links.
- The main panel breadcrumb includes the Book, Journey title and selected Scenario. Render the Book title as plain text. The Journey breadcrumb opens its overview; the current Scenario is the final non-link item. On the Journey overview, the Journey title is the current non-link item.
- A compact navigation row near the breadcrumb links among the fixed Journey's sibling Scenarios and marks the current Scenario. Keep the same URLs and current-state semantics as the sidebar.
- The Book contains the smallest number of addressable screens that explains the cited dispatcher job: two by default, three only if the source-grounded edge case needs a distinct screen. Do not add a toolbar, Inspector, command palette, search, grid, editable controls, a Canvas color-scheme picker, or a general Journey editor.
- Each screen has a stable direct URL. Current screen is identified in text and with `aria-current="page"`. Unknown Book or screen URLs render the safe unavailable state and a working return link; never infer a module or screen from arbitrary input.
- The host shell and the Canvas document remain distinct. Render each screen through the real same-origin host Canvas and inherited host layout/assets/CSP. Give the embedded document a descriptive `title` that names the Book screen.
- All navigation is usable with Tab, Shift+Tab, Enter, and Space where appropriate. Do not add single-key shortcuts. Keep focus visible with a 2px outline and 4px offset; focus must not be covered by sticky UI.
- Use semantic `header`, labeled `nav`, `main`, and `footer` landmarks, one clear page `h1`, and ordered headings. Tables have captions and scoped column headers; status is text and never color alone. Announce screen changes and unavailable/error status through a polite live region without moving focus unexpectedly.
- At 320px and 375px, stack the sidebar above the Canvas, keep scenario links available and let long labels wrap. At 768px and 1280px, keep the persistent sidebar beside the selected Canvas. No horizontal page overflow. At 200% text zoom, all copy and controls remain available. Respect `prefers-reduced-motion`; screen navigation is instant.
- Review the live local Book at representative narrow and desktop widths. Do not publish screenshot artifacts in public PRs or auto-accept a changed visual baseline; the owner decides at the end-of-milestone review.

---

## UI Considerations

Applicable checks resolved: 20 explicit, 1 backstop, 0 unresolved (21 checks across four classified surfaces).

| Category | Element(s) | Status | Resolution / Reason |
|----------|------------|--------|---------------------|
| empty | Catalog list; Canvas Story content | ✅ resolved | If the local catalog has no compiled Book, show the defined empty heading and body with development/test host guidance. If a source-grounded screen has no records, preserve the screen and its citation while showing a concise empty state; do not invent a record. |
| loading | Catalog list; screen navigation; Canvas Story content | ✅ resolved | Keep the neutral host shell stable and politely announce loading. When Canvas content is ready, announce the rendered screen name without moving focus. |
| error | Catalog list; screen navigation; Canvas Story content | ✅ resolved | Unknown Book or screen URLs show the defined unavailable message and a working catalog/Book return link. A Canvas failure says, “The screen could not load. Check that the local Phoenix host is running, then reload.” Keep the local failure message inside the host shell. |
| populated | Book sidebar; selected Canvas screen | ✅ resolved | Show one compiled operator Book in the sidebar and open the first source-grounded screen in the main Canvas. Its screens contain fixed, source-cited ordinary and edge/error cases with a persistent illustrative notice. Do not add sample records outside the approved fixture. |
| partial | Catalog list; Canvas Story content | ✅ resolved | Never infer missing source-backed values. Show “Not provided in source” for an absent optional fixture value; retain its exact citation in authored Scenario data. |
| overflow | Catalog list; screen navigation; Canvas Scenario content | 🧪 backstop | At the real host, verify 320px and 1280px widths and 200% text zoom. Confirm there is no page-level horizontal overflow, clipped navigation, or covered focus indicator. Long values wrap and dense records stack. Raw citation pointers are not rendered in the Canvas. |
| zero-one-many | Books sidebar; source-grounded Story collections | ✅ resolved | With no Book, show the defined empty copy; with one Book, render the sidebar and first screen directly. Keep the same simple Scenario list at zero, one, or many source-grounded rows, with correct singular/plural text. Keep fixture contents fixed and do not add multi-Book management affordances. |
| long-text | Screen navigation; Book labels, IDs, and Scenario facts | ✅ resolved | Wrap long names and facts; break long IDs at safe boundaries. Preserve all content needed to understand the record; do not truncate it with ellipses. Raw citation paths are not shown in the Canvas. |

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
