# Workbench UX, visual system, microcopy and accessibility

This is the design-lead synthesis. The decision is ADR 0013, and the vocabulary comes from `GLOSSARY.md`, and the UI labels below. The bar, in the owner's words: "great high quality graphic design ui/ux … very 'designed' feeling… nothing should feel accidental" (INT-20261028-01).

## House style inherited from the owner's brandbooks
The owner's brandbooks (mailglass, sigra, accrue, scrypath) share a calm "maintainer" voice:
- Exact nouns, no hype, no "Oops" or "!".
- Semantic tokens in `tokens.json`/`tokens.css`, with **contrast computed, not asserted**.
- System font stacks or a shipped WOFF2 trio.
- SVG as outlined paths with no plate. Flat surfaces: no glassmorphism or gradients.
- Status colour always paired with text.
- One accent, used sparingly, avoiding the usual blue-purple SaaS look.

## Layout
```
┌ Sidebar (260, resizable) ┬ Canvas toolbar: Width 375 ▾ · Theme Dark ▾ · LTR · Zoom 100% · Outline · ⋯ ┬ Inspector (360) ┐
│ ⌕ Filter  ⌘K  To review 3│ Story header: Status badge · Primitives · 6 scenarios      [All] [One]   │ Attrs HEEx Events Checks│
│ Foundations              │ ┌──────────── preview (host root layout, iframe) ────────────┐          │                         │
│ Primitives ▸ Badge ●     │ │                                                            │          │                         │
│ Patterns · Areas ·       │ └────────────────────────────────────────────────────────────┘          │                         │
│ Screens                  │                                                                         │                         │
│ Journeys · Pages         │
│ Unstoried (14)           │                                                                         │                         │
└──────────────────────────┴─────────────────────────────────────────────────────────────────────────┴─────────────────────────┘
```
- **Inspector placement:** right side at ≥1280 px, a bottom drawer at 768–1279 px, a bottom sheet below 768 px. On Screen-tier stories the inspector starts collapsed.
- **Sidebar:** the top-level headings are the tiers, and an empty tier is hidden. Folders inside a tier use the **product's own nouns**. Each row has a quiet tier glyph and a check dot, and the dot always has a text equivalent ("Checks: 2 issues").
- **All scenarios is the default view.** It shows a grid of tiles, each carrying the scenario name, its situation line, a check status and a ⋯ menu (Copy for LLM, Copy link). Selecting a tile switches to **One scenario**, which is the playground. `[` and `]` move between scenarios.
- **The story header is the docs:** description, then citations (persona, job), then "Reference" (attrs and slots, collapsed), then the grid. There is no separate Docs mode.
- **Playground:**
  - Overrides show an "Edited" chip and a **Restore scenario** action.
  - Controls exist only for literal-typed attrs and preset-backed complex attrs.
  - Everything else is read-only, labelled "Set in the story file", with **Open in editor**. It says this plainly so it doesn't look like a bug.
- **URL state:** `/dev/fablebook/deliveries/status_badge/retrying?vw=375&scheme=dark&theme=brand&dir=rtl&locale=ar&motion=reduce&zoom=100&twin=chatly&o=<encoded overrides>`. **Copy link** copies the current state. **Copy finding link** also includes the open Checks item.
- **⌘K palette** follows the Raycast/Linear model:
  - It searches Stories, Scenarios, Pages, Canon entries and Commands ("Set width to 375", "Toggle outline", "Copy HEEx", "Copy for LLM", "Open in editor").
  - Recent items come first. Fuzzy matching covers function names (`.badge`), modules and situation text.
  - Shortcuts are shown on the right. `/` is a separate in-place sidebar filter.
- **Toolbar:** every tool shows its value as **text**.
  - Visible tools: Width (presets 320/375/768/1280/1440, Fill, or custom px), Theme (only if the host has more than one), Direction (only if the canon has candidate directions), text direction (LTR/RTL), Frame (none/phone/tablet/laptop/desktop), Zoom, Outline.
  - Under ⋯: Measure, Background (only for transparent subjects), Reduced motion, Text 200%, Forced colors, Locale (Gettext locales, if configured), Text expansion +35% (readable: repeats the string's own words; no pseudo-accents), Sample data filter (only if twins exist), Fullscreen, Open in new tab, Show on phone (QR), and Compare light/dark side by side.
- **Inspector tabs:** **Attrs · HEEx · Events · Checks**.
  - **HEEx** shows the exact call for the current state, with Copy, plus "Defined in `lib/…:42`".
  - **Events** logs pushes and info messages. A missing handler shows a row: "No handler for "save" in this preview".
- **Mobile layout** applies below 768 px:
  - The canvas goes full width, with a top bar holding the story name and a scenario picker.
  - The inspector becomes a bottom sheet with HEEx and Checks.
  - A Find button opens the palette.
- **Show on phone:** the QR code appears only when the server is reachable from the network. On localhost it explains why instead of showing a dead QR code.

## Keyboard map
Single-key shortcuts can be turned off (WCAG 2.1.4). They are suspended while focus is in an input or in the preview. `?` shows the cheat sheet.

| Key | Action |
|---|---|
| ⌘K / Ctrl K | Palette |
| `/` | Filter sidebar |
| ⌥↑ / ⌥↓ | Previous / next story |
| `[` / `]` | Previous / next scenario |
| `G` | Toggle All / One scenario |
| `1`–`5`, `0` | Width 320…1440 / Fill |
| `C` / `T` / `R` / `O` / `M` | Cycle color scheme (light → dark → system) / theme / RTL / outline / reduced motion |
| `S` / `I` | Toggle sidebar / inspector |
| `F` | Isolate: canvas only (`Esc` to exit) |
| ⇧C / ⇧L / ⇧A | Copy HEEx / link / for LLM |
| `E` | Open in editor (dev only) |
| ⌘. or F6 | Cycle focus between regions |

## Visual system (chrome)
- **The chrome has no brand hue.** The previewed component owns all colour on screen, and the chrome is ink on neutral.
  - The canvas sits on a slightly sunken ground with a 1 px hairline frame and a "375 × 812" readout.
  - Selection is an inverted ink fill, never a hue.
- **Tokens (OKLCH):**
  - A cool neutral ramp of 11 steps, with light and dark designed separately rather than inverted.
  - Roles: `--fb-bg`, `--fb-surface`, `--fb-surface-raised`, `--fb-sunken`, `--fb-border(-strong)`, `--fb-text(-muted)`, `--fb-focus`, `--fb-selected-bg/fg`, and status pairs.
  - **Focus is the only chromatic token**: a clear blue at ≥3:1 on every surface.
  - `prefers-contrast: more` raises contrast to 7:1. `forced-colors` uses system colours.
  - Tokens use the same DTCG → CSS pipeline and contrast matrix as adopters' canon. Fablebook dogfoods its own canon.
- **Type:**
  - System stacks only, with zero font network requests, plus a mono stack for attrs, HEEx and paths.
  - Sizes: 12 / 13 / 14 (base) / 16 / 20 rem-equivalents. Weights: 400 and 600.
  - Tabular numerals; no negative tracking.
- **Density:** Comfortable (32 px rows, 44 px coarse targets) and Compact (28 px rows, 24 px minimum).
- **Motion:**
  - 120 ms ease-out for state changes and 180 ms for panels and sheets.
  - **The workbench never animates the canvas.** Render swaps are instant, because chrome motion would misrepresent the render. The **subject's own motion always plays** unless the Motion global is `reduce` or `off` (see MOTION-AND-UX-DIMENSIONS.md).
  - Animate only transform and opacity. `prefers-reduced-motion` reduces this to opacity or nothing.
- **Icons:** a vendored heroicons subset (micro 16, mini 20). Every icon button has a visible label, or a tooltip plus `aria-label`.
- **Focus:** a 2 px outline at 2 px offset. A separate "preview has focus" ring on the canvas frame tells users the shortcuts are suspended.
- **CSS:**
  - Tailwind v4 standalone build with `source(none)`.
  - **Reset the default namespaces** (`--color-*: initial`, `--font-*`, `--radius-*`, `--shadow-*`, …) and define only `fb-` tokens, so utilities outside the token set can't exist.
  - No daisyUI: its semantic names fight the reset, and its visual opinions would then need overriding.
  - The chrome needs about 25 bespoke components: tree row, segmented control, menu, tabs, sheet, palette, tooltip, table, code block, toast, separator.
- **Brand:**
  - Essence: "Every state, on one page."
  - Voice: a calm stage manager.
  - Mark: a bookmark ribbon. A rectangle with a V-notch, which reads as "book" and is the same shape as the marker for the current scenario.
  - A gilt or ochre accent appears only in the mark, the docs and the social card, never in the chrome UI.
  - The brandbook follows the house format (outlined SVG, `index.html`, DTCG tokens).

## UI labels (domain term → what the workbench says)

| Concept (code) | UI label | Never in UI |
|---|---|---|
| Story | Story | fable, module |
| Scenario | Scenario | variant, variation, example |
| Group | Group | VariationGroup |
| Attrs, Slots | Attrs, Slots | args, props, knobs |
| Override (active) | "Edited" chip + **Restore scenario** | dirty, modified |
| Playground | (the one-scenario view) | sandbox |
| Grid of a story's scenarios | **All scenarios** / **One scenario** | docs mode, canvas mode |
| Canvas | Preview (in copy only) | iframe, canvas, sandbox |
| Globals toolbar | Width · Frame · Theme · Direction · LTR/RTL · Zoom · Outline · ⋯ | globals, environment |
| Workbench appearance | **Appearance** (System, Light, Dark) in Settings | theme (that is the preview theme) |
| Twin filter (filters scenarios by cited twin; never swaps data) | **Sample data** | twin, seed, fixture |
| Component with no story | **Unstoried** (tile shows "Needs a story" when a required attr can't be filled) | auto-story, orphan |
| Checks tab | **Checks** | tests, audit |
| Unstoried | **Unstoried** | orphan |
| Bundle | **Copy for LLM** / **Download context** | bundle, dump |
| Static export (v1.x) | Static export · "Needs server" badge | — |
| Tiers + canon section | Foundations (canon) · Primitives · Patterns · Areas · Screens; Sections are folders inside tiers | atoms, molecules |

---

## UX writing
**Rules:**
1. Sentence case everywhere.
2. Buttons start with a verb.
3. No "Oops", "!", "simply", "just" or "please".
4. Errors follow the order cause → location → one next step.
5. Use Phoenix words (attr, slot, assigns, LiveView, HEEx).
6. Numbers carry units ("375 px", "2 issues").
7. Paths and modules are set in mono and are actionable.
8. Don't toast instant visible changes. Toast only for clipboard actions ("Copied").

**Canonical strings:**
- **Empty catalog, components found:**
  - Title: "Your components are ready to preview".
  - Body: "Fablebook found 14 components in `MyAppWeb.CoreComponents`. Each one renders with its declared defaults. Open one, or create a story to add named scenarios."
  - Actions: **Open Button**, **Copy `mix fablebook.gen.story`**.
- **Nothing found:** "No components found yet. Fablebook looks in modules that `use Phoenix.Component` listed in your Book's `components:`." Action: **Read the setup guide**.
- **Render error:** "This scenario raised while rendering", followed by the exception and message in mono, then `lib/…/button.ex:42`. Actions: **Open in editor**, **Copy error**. The error stays in its own tile, and the rest of the grid keeps rendering.
- **Timeout:** "This scenario took longer than 2 s to render. Fablebook stopped it." Action: **Copy error**.
- **Missing required attr:** "Missing required attr `label`. Set it in the scenario or give the attr a default."
- **Compile error:** "Your code didn't compile. Fablebook is showing the last working version." Clears automatically on recompile.
- **Disconnected:** "Lost connection to the server. Reconnecting…" then "Reconnected". After 30 s: "Still disconnected. Is `mix phx.server` running?"
- **No scenarios:** "This story has no scenarios yet. It's showing the component with its default attrs. Add a scenario for each real situation this component appears in." Action: **Copy scenario template**.
- **Search, no results:** "No stories or commands match "modl"." If a likely match exists: "Did you mean **modal**?"
- **Needs server (v1.x export):** "This scenario sends events to a LiveView. In a static export it shows the first render only."
- **QR unavailable:** "Your phone can't reach `localhost`. Start the server with `--host 0.0.0.0` on a trusted network, or share a static export."
- **Canvas didn't connect:** "The preview didn't connect. Check that your `app.js` sets `window.liveSocket` and that your CSP allows `frame-ancestors 'self'`." Action: **Run `mix fablebook.doctor`**.
- **Checks disclaimer:** "Automated checks find some issues, not all. Test with a keyboard and a screen reader too."
- **Coverage gap:** "No scenario for **empty**. Add one, or waive it with a reason."

## Accessibility (the chrome itself, WCAG 2.2 AA)
- **Landmarks:** `nav` "Stories", `main` "Preview", `aside` "Inspector". Skip links. F6 / ⌘. cycles regions.
- **Sidebar:** nested lists with disclosure buttons (`aria-expanded`) and `aria-current="page"`. **Not** `role="tree"`, which is fragile across screen readers.
- **Iframe:** `title="Preview: Status badge, Retrying scenario"`. A polite, debounced live region announces "Rendered Retrying at 375 px".
- **Pane separators:** `role="separator"` with `aria-valuenow`, resized with arrow keys and collapsed with Enter.
- **⌘K palette:** combobox with listbox, `aria-activedescendant`, and the result count announced.
- **WCAG criteria:** 2.1.4 (shortcuts can be turned off), 2.4.11 (focus never obscured), 2.5.7 (dragging has a keyboard alternative), 2.5.8 (24 px minimum targets), 1.4.10 (Mobile layout works at 320 px), 1.4.4 (200% text doesn't clip).
- **Contrast** is computed at build time for text (4.5:1) and for non-text and focus (3:1), in all three contrast modes.

## Checks offered for previewed components
- **What a check reports:** axe with wcag2a, aa, 21aa and 22aa tags, with **"Needs review" (incomplete) shown as its own group**. Fablebook adds its own checks: target size, overflow at the current width, clipping at 200% text, missing accessible names, a focus walk, and token conformance of computed values.
- **Each result** highlights the element on hover and includes plain words, the WCAG criterion, and **Copy finding link**.
- **Simulations:** reduced motion, 200% text, forced colors, RTL, vision-deficiency filters, keyboard-only.
- **The Checks tab and CI** produce identical findings from the same probe (ADR 0011).

## Onboarding and docs
- **Welcome page:** three cards: "Your components" (count), "Write your first story" (a 12-line snippet plus the generator command), and "Press ⌘K to find anything".
- **Generated examples** cover Phoenix 1.8 core_components (`button`, `input`, `flash`) and show the situation-description convention, e.g. "Flash: error after a failed save, long message".
- **ExDoc:** the 12-guide outline is fixed in ADR 0019. Sub-topics such as "Sample data", "Tiers" or "CSP" are sections inside those guides.
- **Cheatsheets** (`.cheatmd`): Story DSL, Keyboard, URL parameters. Plus `llms.txt` and `llms-full.txt`.

## URL parameters (canonical)
| Key | Values | Default |
|---|---|---|
| path | `/<mount>/<story-id>/<scenario-id>`; omit scenario for All scenarios | — |
| `vw` | `320`, `375`, `768`, `1280`, `1440`, `fill`, or px | `375` |
| `scheme` | `light`, `dark`, `system` | `system` |
| `theme` | a theme name from the Book (only when the host has >1) | Book default |
| `dir` | `ltr`, `rtl` | `ltr` |
| `locale` | a Gettext locale | Book default |
| `motion` | `full`, `reduce`, `off` | `full` |
| `frame` | `none`, `phone`, `tablet`, `laptop`, `desktop` | `none` |
| `direction` | a candidate direction id (only when the canon has directions) | the canon |
| `zoom` | `50`–`200` | `100` |
| `twin` | a twin id; filters the grid to scenarios citing it (Sample data) | none |
| `o` | encoded overrides (≤2 KB, else `:state_too_large`) | none |
| `check` | a finding fingerprint (Copy finding link) | none |
| `probe` | `1` injects the probe (CI and Checks tab) | off |

## Where Fablebook beats Storybook and phoenix_storybook (Pareto order)
1. A zero-file catalog built from `attr`/`slot` declarations (psb #772).
2. Iframe rendering with the host's real layout, CSS, fonts and hooks. Fidelity is the product.
3. Everything lives in the URL, ids are stable, and the manifest is available in the test env.
4. All scenarios as the default grid, and the story page is the docs.
5. LLM context bundles plus canon (glossary, voice, personas and jobs, tokens) as first-class content.
6. No string → HEEx round trip. Secure by construction, and honestly labelled.
7. Text-valued tools, shown only when they're relevant.
8. Fractal tiers and situation-described scenarios with coverage and waivers.
9. Checks in the Checks tab match CI output exactly, with reproducible finding links.
10. ⌘K for everything.
11. Mobile layout plus QR.
12. Preview theme is kept separate from workbench appearance.

## Adversarial notes (kept for later discussion)
- **"No brand colour" might read as generic.** Carry the craft in type, spacing and hairlines. If the L4 judge calls it sterile, add the gilt accent *only* to the current-scenario ribbon.
- **A grid of iframes is expensive.** Use one stacked iframe per story with lazy tiles, and measure with 40 scenarios.
- **Read-only complex attrs can frustrate power users.** Presets restore most of that power safely.
- **Single-key shortcuts vs screen-reader quick keys.** The toggle needs to be prominent on the `?` sheet.
