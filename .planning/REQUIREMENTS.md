# Requirements: Fablebook

**Defined:** 2026-10-28
**Core Value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.

> **Precedence:** verbatim intent (`.planning/intent/sources/`) > ADR (`docs/adr/`) > this file > PROJECT.md. Requirement wording is the owner-approved seed wording, unchanged; every REQ cites at least one INT or ADR id (INTENT-01). Research-proposed amendments to existing wording are **not** applied here: they are open questions Q7–Q30 in `.planning/intent/OPEN-QUESTIONS.md`, with detail in `.planning/research/SUMMARY.md`. CTRL-06, CANVAS-07, WB-17 and WB-18 were added from research by owner choice (INT-20261028-16). CTRL-05, CORE-15 and CORE-16 wait on Q10 and Q14.
>
> **Vocabulary:** `GLOSSARY.md` only. Never "variant"/"variation" for a scenario; never "sandbox" for the canvas.

## v1 Requirements

Every item is a v1.0 commitment. 1.0 ships only after the clearance soak (`.planning/intent/CLEARANCE.md` C1–C10), checked by the milestone audit, not a phase.

### CORE: story model and catalog

- [ ] **CORE-01**: Authors declare stories as compiled `.ex` modules in `storybook/` (dev/test `elixirc_paths` only) with `use Fablebook.Story, subject:, tier:`. The macro injects at most 20 lines. (ADR 0001, INT-20261028-01)
- [ ] **CORE-02**: Scenarios are plain functions. Arity 0 returns attrs/slots data; arity 1 returns a `~H` template. Slots are never strings: plain text is escaped, and rich slots are captured functions. (ADR 0002, INT-20261028-01)
- [ ] **CORE-03**: Each scenario has a required situation `desc` plus `persona:`, `job:`, `twin:` (a fixed citation: the "Sample data" control filters by it and never swaps data), `state:` (one or more state classes), `group:` and `tags:`. Citation shape is checked at compile time and existence when the catalog is built. Persona and job citations are required on Area and Screen scenarios: a warning until the canon has its first persona, an error after that, waivable per scenario only. A scenario may cite several jobs. (ADR 0002, INT-20261028-04)
- [ ] **CORE-04**: The catalog is a pure function that behaves the same in dev and test. It is assembled once per workbench mount and rebuilt on code reload; there is no cache process, ETS or `:persistent_term`. Ids come from module namespace plus function name, and every scenario has a stable URL, including scenarios inside groups. (ADR 0008)
- [ ] **CORE-05**: Components with no story come from the Book's `components:` list and render as **Unstoried** auto-stories. Required attrs are filled from the declared `default`, then `examples`, then `values`; if none of these exist, the component shows a "Needs a story" tile. Fablebook never invents a value. (ADR 0008, INT-20261028-01)
- [ ] **CORE-06**: Four tiers, each answering one question: Primitive · Pattern · Area (the Shell is an Area) · Screen. The sidebar is tier-first, with product-noun Section folders inside each tier. Foundations is a separate section that presents the canon. (ADR 0023, INT-20261028-04, INT-20261028-07)
- [ ] **CORE-07**: Every story has exactly one subject, and every component has at most one story. Area and Screen subjects must be presentational function components. LiveComponents (with declared controls) are allowed up to Area. A LiveView subject needs a Waiver. Pages (Markdown/HEEx) are catalog entries without a subject. (ADR 0002, INT-20261028-06)
- [ ] **CORE-12**: Strict by default: every rule in ADR 0024 is on, the only escape hatch is a per-story or per-scenario **Waiver** with a written reason, waivers are visible and counted, and there is no global off switch. (ADR 0024, INT-20261028-07, INT-20261028-08)
- [ ] **CORE-13**: **Draft** stories and scenarios turn strict-rule errors into warnings and stay listed in To review. `mix fablebook.gen.screens` scaffolds a Shell plus one Draft Screen story per canon job, for greenfield work. Bundles accept `--focus explore`. (ADR 0024, INT-20261028-09, INT-20261028-11)
- [ ] **CORE-14**: Render mode `render: :live | :static`. A static story is served by a controller with no LiveSocket, exactly as a dead view runs in production. A check flags `phx-*` LiveView bindings in static stories. (ADR 0022, INT-20261028-10, INT-20261028-11)
- [ ] **CORE-08**: A coverage matrix crosses stories with the closed state-class set (happy, empty, one, many, boundary, loading, error, denied, stale, long, intl, huge). Each cell is a scenario or a reasoned **waiver**, and gaps are reported. (GLOSSARY, INT-20261028-04)
- [ ] **CORE-09**: A render seam, `Fablebook.Render.render(scenario, globals, purpose)`, runs outside any LiveView and is shared by the canvas, tests and bundles (later also export). (ADR 0022)
- [ ] **CORE-10**: Stories and the Book can wrap scenarios in containers. Placement is `:centered`, `:padded` or `:fullscreen`. (ADR 0002)
- [ ] **CORE-11**: Pages can embed live scenarios, so guides stay accurate. (ADR 0013, INT-20261028-04)

### CTRL: controls and URL state

- [ ] **CTRL-01**: Typed controls are generated from attr metadata: boolean, integer, float, string, and a select for `values:`. Complex attrs use compiled **presets**. (ADR 0004)
- [ ] **CTRL-02**: An override shows an "Edited" chip and offers **Restore scenario**. Attrs that can't be edited say "Set in the story file" and offer Open in editor. (ADR 0013)
- [ ] **CTRL-03**: All view state lives in the URL (scenario, `o` overrides ≤2 KB, `vw`, `frame`, `scheme`, `theme`, `direction`, `dir`, `locale`, `motion`, `zoom`, `twin` (filter), `check`), so a reload reproduces it exactly. See the parameter table in UX-DESIGN. (ADR 0013, INT-20261028-04)
- [ ] **CTRL-04**: Globals are a closed set: theme, design direction (a candidate look), color scheme (light/dark/system), locale (Gettext), text direction, viewport, device frame and motion (full/reduce/off). (ADR 0002, INT-20261028-13)
- [ ] **CTRL-06**: Editing a Control offers "Copy as scenario": Elixir text for a new Draft scenario with the overridden attrs and a TODO situation. Values print from typed controls only, no atoms are created, and nothing is written to disk. (ADR 0004, ADR 0013, INT-20261028-16)

### CANVAS: fidelity and isolation

- [ ] **CANVAS-01**: Scenarios always render in an iframe that goes through the host's own pipeline and root layout, so they get the real `app.css`, `app.js`, colocated hooks, fonts and CSP. (ADR 0003, INT-20261028-01)
- [ ] **CANVAS-02**: The All-scenarios grid stacks a story's scenarios in one iframe and lazy-loads the tiles. (ADR 0003)
- [ ] **CANVAS-03**: A scenario that raises, throws, exits, times out (2 s) or exceeds its heap shows an error panel. The workbench keeps running and other tiles keep rendering. (ADR 0003, INT-20261028-01)
- [ ] **CANVAS-04**: The workbench and canvas talk over a `Phoenix.Token`-signed topic. The event log keeps string names only, truncates payloads, and is scoped to the canvas. (ADR 0004)
- [ ] **CANVAS-05**: When the canvas fails to connect, a diagnostic names the likely causes (`window.liveSocket`, `frame-ancestors`). (ADR 0003)
- [ ] **CANVAS-06**: Recompiling a story or component updates the open workbench without a restart. (ADR 0008, INT-20261028-01)
- [ ] **CANVAS-07**: The canvas absorbs events and navigation it has no handler for (catch-all `handle_event/3`, `handle_info/2`, `handle_params/3`, `layout: false`) and logs "Event recorded" or "Would navigate to /x" instead of crashing or leaving. (ADR 0003, ADR 0004, INT-20261028-16)

### WB: workbench UX

- [ ] **WB-01**: The workbench has three panes. The toolbar belongs to the canvas, every tool shows its value as text, and a tool appears only when it applies. (ADR 0013, INT-20261028-01)
- [ ] **WB-02**: **All scenarios** grid by default. The story page *is* the docs: description, citations, attr/slot Reference, then the grid. (ADR 0013)
- [ ] **WB-03**: A ⌘K palette searches stories, scenarios, pages, canon and commands; `/` filters the sidebar. (ADR 0013)
- [ ] **WB-04**: The full keyboard map from UX-DESIGN. Single-key shortcuts can be turned off and are suspended while focus is in the preview. (ADR 0013)
- [ ] **WB-05**: Inspector tabs: Attrs · HEEx (copy the exact call) · Events · Checks. (ADR 0013)
- [ ] **WB-06**: Toolbar tools (ADR 0013, INT-20261028-04):
  - Width presets 320/375/768/1280/1440, Fill and custom, opening at 375 (mobile first).
  - Color scheme, theme, direction, zoom, outline, measure.
  - Background (shown only for transparent subjects), Isolate (canvas only) and fullscreen.
  - Light/dark side by side.
- [ ] **WB-07**: Below 768 px the workbench switches to Mobile layout. "Show on phone" offers a QR code, and says plainly when it can't. (ADR 0013)
- [ ] **WB-08**: The workbench's **Appearance** (System/Light/Dark) is a separate control from the preview's **Theme**. (ADR 0013)
- [ ] **WB-09**: Chrome visual system: ink on neutral, `fb-` OKLCH tokens, Tailwind namespaces reset, system fonts, two density modes, no daisyUI. The workbench never animates the canvas itself (render swaps are instant), but the subject's own motion always plays unless the Motion global is `reduce` or `off`. (ADR 0013, INT-20261028-01)
- [ ] **WB-10**: Canonical microcopy for every empty, error and disconnected state, as listed in UX-DESIGN. (ADR 0013, INT-20261028-01)
- [ ] **WB-11**: Open in editor, restricted to localhost and to paths inside the project root. (ADR 0004)
- [ ] **WB-13**: **Compare** mode: renditions side by side that differ in exactly one respect (a global, a theme, or a revision against main), at any tier. Bundles accept `--focus compare`. (ADR 0013, INT-20261028-09, INT-20261028-10)
- [ ] **WB-14**: **To review** page (the Review queue) with a sidebar count badge and no pop-ups. It lists proposals, stale or assumed canon, findings without a verdict, coverage gaps and waivers due for review. (ADR 0013, INT-20261028-09)
- [ ] **WB-15**: **Device frames**: none, phone, tablet, laptop or desktop. Generic outlines (not branded device art). Phone and tablet show safe areas, a status bar and standalone (PWA) display. (ADR 0013, INT-20261028-12, INT-20261028-14)
- [ ] **WB-16**: **Export image**: a framed, high-resolution PNG of any scenario, optionally on a background, from the workbench or `mix fablebook.shot <scenario> --frame phone --scheme dark`. It uses browser capture (opt-in). (ADR 0011, INT-20261028-14)
- [ ] **WB-12**: A dev Diagnostics page: catalog build time, scenario count, recent crashes, evidence staleness. (ADR 0016)
- [ ] **WB-17**: Sidebar dots and tile status read the latest Evidence keyed by render hash and show "Not run" until Evidence exists, never a green dot. "Run checks" runs the probe for the open rendition (and at story level across the width presets) in the user's browser. (ADR 0011, ADR 0010, INT-20261028-04, INT-20261028-16)
- [ ] **WB-18**: Width presets carry a height and a rotate action (an `orient` URL parameter). Workbench settings (Appearance, density, single-key shortcut switch, pane sizes) persist and are listed. (ADR 0013, INT-20261028-16)

### CANON: design-system knowledge as content

- [ ] **CANON-01**: The `design/` canon is one Markdown file per entry with strict-subset frontmatter, parsed by our own parser (property-tested, no YAML dependency). (ADR 0012, INT-20261028-05)
- [ ] **CANON-02**: Entry kinds: term (user-facing ↔ internal, avoid, retired), voice, tone, microcopy rules, persona, job, twin, imagery. (ADR 0012, INT-20261028-04)
- [ ] **CANON-03**: Tokens are DTCG 2025.10 (`design/tokens/*.tokens.json` plus a light/dark resolver). abracabrand's `brandbook/tokens/identity.json` is read, with `$extensions` preserved, and never written. (ADR 0012)
- [ ] **CANON-04**: Foundations pages: token swatches, type scale, radius/shadow/motion specimens, contrast cards, the glossary table, voice, and persona/job/twin cards linking to the scenarios that cite them. (ADR 0012, INT-20261028-04)
- [ ] **CANON-05**: abracabrand interop: BRAND.md and direction-note sections become Voice, Imagery and Applications pages; logos are filtered by `rights/assets.json`; bundles pin the brand by its `inventory.json` hash. (ADR 0012)
- [ ] **CANON-06**: Fablebook generates `DESIGN.md` (Google design.md spec) and `.impeccable/design.json` from tokens plus **rendered** primitives. Both carry an ownership header, and Fablebook refuses to overwrite files it doesn't own. `mix fablebook.tokens` generates and checks CSS from the tokens. (ADR 0012)
- [ ] **CANON-07**: Pure-Elixir lints in the PR lane (ADR 0012, INT-20261028-04):
  - Glossary and retired-wording checks over rendered text and accessible names.
  - Deterministic voice rules.
  - Token conformance and drift from DTCG to CSS.
  - A WCAG 2.2 contrast matrix.
- [ ] **CANON-09**: Canon layers: a **brand canon** shared by a product family, and **product canons** that inherit it. A Book points at one product canon, and overriding a brand rule needs a Waiver. (ADR 0012, INT-20261028-10)
- [ ] **CANON-10**: Themes: a Book can render under several named themes, and a twin may bring its own theme (white-label). **Guardrails** turn unreadable theme choices into findings. (ADR 0012, INT-20261028-10)
- [ ] **CANON-11**: **Directions**: named candidate looks and voices (`proposal` until chosen) that can be selected in the toolbar and compared across the catalog. abracabrand's routes import as Directions. Choosing one makes it the canon and archives the rest. (ADR 0012, INT-20261028-09, INT-20261028-11)
- [ ] **CANON-12**: The brand canon can come from a path or a dependency (`canon: [brand: {:logistify_brand, "design"}, product: "design"]`), so product families can span repos. (ADR 0012, INT-20261028-11)
- [ ] **CANON-08**: Intent coverage: broken citations, orphan personas, uncovered jobs, and persona/job citation enforcement. (ADR 0002, INT-20261028-04)

### CHECK: probe, sweep, findings

- [ ] **CHECK-01**: A probe script with vendored axe-core collects (ADR 0011, INT-20261028-04):
  - axe results (incomplete counts as a finding)
  - overflow, target size and 200% text
  - focus walk and computed-style token conformance
  - contrast and the ARIA snapshot
  The output follows a versioned Evidence schema.
- [ ] **CHECK-02**: The Checks tab runs the same probe live, needs no Node, and finds exactly what CI finds. Each finding has "Copy finding link". (ADR 0011)
- [ ] **CHECK-03**: Simulations: reduced motion, 200% text, text expansion +35% (readable, no pseudo-accents), forced colors, RTL, vision-deficiency filters, keyboard-only. (ADR 0013)
- [ ] **CHECK-04**: A sweep driven by the manifest covers 320/375/768/1280/1440 × light/dark, plus reduced motion. Findings are fingerprinted, and a ratchet ensures the count only shrinks. (ADR 0017, INT-20261028-04)
- [ ] **CHECK-05**: `Fablebook.Testing.generate_tests(book)` creates one ExUnit test per scenario (renders, attrs valid, desc present, citations resolve). `mount_scenario/2` uses `live_isolated`. (ADR 0014)
- [ ] **CHECK-06**: A verdicts log in the repo records each finding's fingerprint, verdict and reason. A rejected finding is suppressed in later reports and bundles. (ADR 0010, INT-20261028-04)

### VIS: visual regression

- [ ] **VIS-01**: Pixel diffs run in a pinned Playwright container with a deterministic recipe: fonts ready, DPR 1, animations off, a ready attribute, a frozen clock. (ADR 0011, INT-20261028-04)
- [ ] **VIS-02**: Baselines are **never auto-accepted**. CI fails if a baseline is missing, if `git status` changes, or if the baseline set doesn't match the manifest. Only a human, via `bin/visual update`, accepts baselines. (ADR 0011)
- [ ] **VIS-03**: PRs run visual-core (≤40 renditions). Nightly and release runs cover the full set (≤400). A determinism self-test (identical hashes) blocks release. (ADR 0017)

### LLM: context bundles (core)

- [ ] **LLM-01**: `mix fablebook.bundle <selector>`, plus **Copy for LLM** and **Download context** in the workbench. Selectors: scenario, story, section, tier, tag, all. (ADR 0010, INT-20261028-04)
- [ ] **LLM-02**: Bundle layout (ADR 0010):
  - `BUNDLE.md` and `bundle.json` (schema `fablebook.bundle/1`)
  - `context/`: DESIGN.md, the tokens used, glossary hits, voice, personas/jobs, a PRODUCT.md excerpt
  - `scenarios/<id>/`: PNG shots, `aria.yaml`, markup, styles, measurements, a11y, copy
- [ ] **LLM-03**: A token-budget allocator with summary/standard/full detail levels. It tiles tall views by viewport height, switches to grid contact sheets past 20 images, and reports what it dropped. (ADR 0010)
- [ ] **LLM-04**: Two capture levels: no-browser capture in pure Elixir, and opt-in `--browser` capture that shares the visual capture pipeline. (ADR 0010, ADR 0018)
- [ ] **LLM-05**: Evidence is keyed by render hash. Stale or missing evidence is labelled and never presented as current. (ADR 0010)
- [ ] **LLM-06**: The manifest (`index.json`, `components.json`) is served at the mount and written by `mix fablebook.manifest`, with drift checking. `llms.txt` and `llms-full.txt` are included. (ADR 0009)
- [ ] **LLM-07**: A committed JSON Schema with a `Fablebook.Bundle.validate/1` round-trip, three golden bundles, a determinism property, and size budgets (≤~7.5k text tokens and ≤1.5 MB per scenario). (ADR 0010)
- [ ] **LLM-08**: Bundles take one `--focus` from the closed list (explore, critique, copy, a11y, layout, consistency, brand, compare, journey, motion). Each focus has its own rubric digest and reading order in `BUNDLE.md`. Adding a focus requires an ADR. (ADR 0010, INT-20261028-12)

### JOURNEY: transitions between screens

- [ ] **JOURNEY-01**: **Journeys** are linear lists of **Steps** (each a scenario plus the user action that leads on), declared in the job's canon file. Each alternative path is its own journey. The catalog build checks that every referenced scenario exists. (ADR 0012, INT-20261028-12, INT-20261028-14)
- [ ] **JOURNEY-02**: Step checks: the step's action must exist as an interactive element with that accessible name in the step's rendition (dead-end check), and its label must match (copy-drift check). Across steps, the Shell's navigation must be identical, and the same terms must be used for the same things. (ADR 0024, INT-20261028-14)
- [ ] **JOURNEY-03**: The workbench shows a journey as a filmstrip of its steps. The `journey` bundle focus sends the whole flow to an LLM. (ADR 0010, INT-20261028-12)

### MOTION: animation as a first-class lane (ADR 0025)

- [ ] **MOTION-01**: The workbench has a Motion panel. It can pause and scrub every canvas animation on a timeline, play at 0.1×, 0.25× or 0.5× (a time shim stops LiveView timers from cutting animations short), and show a filmstrip at 0/50/100/150/200/300 ms plus the settled state. (ADR 0025, INT-20261028-12, INT-20261028-13)
- [ ] **MOTION-02**: The canon has motion tokens, with strong default easing curves that override Tailwind's weak default. Computed durations and easings must be on-token. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-03**: Strict motion checks: no `transition: all`, no animated layout properties, no ease-in on enter, no `scale(0)`, UI motion at most 300 ms unless tagged marketing, hover motion only inside `(hover:hover)`, and nothing moves under reduced motion. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-04**: LiveView motion lints: `JS` `time:` must equal the CSS duration; `blocking: true` is flagged on decorative transitions; `JS.show` without `display:` is flagged on flex or grid; `stream_delete` without an exit animation is flagged. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-05**: Scenarios carry a `motion_tier:` (keyboard, frequent, occasional, rare), linted against the frequency gate. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-06**: A CI motion lane baselines and diffs seeked filmstrips. Ordinary visual diffs keep animations off. The installer adds the reduced-motion custom variant and the doctor checks for it. (ADR 0025, ADR 0011, INT-20261028-13)
- [ ] **MOTION-07**: The `motion` bundle focus provides `motion.json` (keyframes, timing, easing, 16 ms samples), a filmstrip contact sheet, and reduced-motion frames, never video. The bundle says that judging feel needs a person watching at 0.25×. (ADR 0025, ADR 0010, INT-20261028-13)

### UX: additional quality dimensions (`docs/research/MOTION-AND-UX-DIMENSIONS.md`)

- [ ] **UX-01**: Any scenario can be viewed in forced interaction states (hover, focus-visible, active, disabled) without a mouse. A check confirms each state looks different from rest and that `phx-click-loading` is styled. (ADR 0024, INT-20261028-13)
- [ ] **UX-02**: Form checks: label association, `aria-invalid`/`aria-describedby`, errors only after a field is touched (`used_input?`), autocomplete and inputmode, no placeholder-only labels. (ADR 0024, INT-20261028-13)
- [ ] **UX-03**: A layout-shift check during a scripted load, and a check that skeletons match the final content size. (ADR 0024, INT-20261028-13)
- [ ] **UX-04**: An RTL logical-property lint (`ms-`/`start`, not `ml-`/`left`) and locale-formatting checks: flag English-formatted numbers and dates under non-English locales, and require `<time datetime>`. (ADR 0024, INT-20261028-13)
- [ ] **UX-07**: An optional Credo check for apps whose Book declares Gettext: it flags user-visible literal text in `~H` not wrapped in `gettext`. Waivable with a reason, e.g. for brand names. (ADR 0024, INT-20261028-12, INT-20261028-14)
- [ ] **UX-05**: A destructive-dialog guard: cancel must not be visually weaker than a destructive confirm. Plus a glossary-based confirmshaming lint. (ADR 0024, INT-20261028-13)
- [ ] **UX-06**: Copy lint benchmarks: button word count, title and error length, sentence length, reading grade per persona, and generic labels such as "Click here" or "Submit". (ADR 0024, INT-20261028-13)
- [ ] **UX-08**: Feedback and focus checks: toasts use a live region with the right politeness, never steal focus, last at least 5 s or can be paused, and can be dismissed; modals trap focus and return it on close; focus survives a LiveView patch; every error state offers an action. (ADR 0024, INT-20261028-13, INT-20261028-14)

### SKILL: agent skills

- [ ] **SKILL-01**: Fablebook ships small skills (`fablebook`, `fablebook-review`, `fablebook-motion`, `fablebook-canon`), installed via `usage_rules` sync or `mix fablebook.skills.install`. Installs are version-stamped and never overwrite user edits. (ADR 0010, INT-20261028-12, INT-20261028-13)
- [ ] **SKILL-02**: Rules live in checks with stable ids, and bundles carry a short, credited digest for each focus. Upstream skills (impeccable, ux-writing, review-animations, emil-design-eng) are named when installed and suggested as optional otherwise. They are never installed silently. (ADR 0010, INT-20261028-13)

### SEC: security

- [ ] **SEC-01**: No `Code.eval*`, no runtime EEx/HEEx compilation, and no `String.to_atom` on input. Credo bans these, and properties plus mutation-proven tests confirm it. (ADR 0004, INT-20261028-01)
- [ ] **SEC-02**: In prod the router macro raises a `CompileError`, with no override in 1.0. Stories and canon never compile in prod. The CI prod build asserts there are no Fablebook routes and no story beams. (ADR 0006)
- [ ] **SEC-03**: CSP nonces everywhere (`csp_nonce_assign_key`). No `eval` or `new Function`. Iframe sandbox attributes and `frame-ancestors 'self'`. (ADR 0005)
- [ ] **SEC-04**: Bundle redaction strips paths, env values, hosts, secret-shaped strings and session/CSRF tokens. A `redact:` hook is available. (ADR 0010)
- [ ] **SEC-05**: Size caps per control type (`:state_too_large`), path containment for `--out` and the editor (`:path_rejected`), and descriptions/Markdown escaped by default. (ADR 0004)

### PERF: deterministic gates

- [ ] **PERF-01**: Catalog scaling: t(5000)/t(500) < 15, 5000 scenarios ≤ 1.5 s, no `Code` calls during the build. (ADR 0015, INT-20261028-01)
- [ ] **PERF-02**: Mount and render reductions stay within 1.25× the committed reference measurement, and the maximum render over 10k iterations is ≤ 50 ms. (ADR 0015)
- [ ] **PERF-03**: A control change produces a WebSocket diff ≤ 4 KB, and the sidebar is never re-sent. (ADR 0015)
- [ ] **PERF-04**: Session heap ≤ 3 MB. A leak test over 10k events stays within 1.2× steady state. Fablebook adds 0 ETS tables and 0 processes to the host. (ADR 0015)
- [ ] **PERF-05**: Host compile overhead ≤ 15% with 500 stories (nightly/release lane). Touching one component recompiles at most one story. (ADR 0015)
- [ ] **PERF-06**: A sibling `bench/` project (Benchee) tracks p50/p99/p99.9/max against committed reference measurements with sensitivity controls. It is advisory only. (ADR 0015, INT-20261028-01)

### TEL: telemetry and errors

- [ ] **TEL-01**: Spans named `[:fablebook, domain, action, *]` are catalogued in `Fablebook.Telemetry.events/0`. A test confirms every listed event is emitted and nothing unlisted is. (ADR 0016, INT-20261028-01)
- [ ] **TEL-02**: Metadata is whitelisted to ids, counts and enums. Fablebook never attaches handlers. A LiveDashboard metrics recipe is documented. (ADR 0016)
- [ ] **TEL-03**: Errors use `%Fablebook.Error{type:}` with the closed set in DOMAIN-MODEL §2. Declaration mistakes raise `CompileError` with file, line, value and a fix. Error messages have snapshot tests. (ADR 0016)

### INST: install, generators, upgrade

- [ ] **INST-01**: `mix igniter.install fablebook` mounts `/dev/fablebook` inside `dev_routes` and sets up `elixirc_paths`, live_reload, the formatter, the Book (`components:` seeded), a welcome page and a sample story. It never touches `app.js` or the Tailwind config. (ADR 0019, INT-20261028-01)
- [ ] **INST-02**: `mix fablebook.gen.story Module.fun`. (ADR 0019)
- [ ] **INST-03**: `mix fablebook.doctor [--ci]`, built as a pure core with a thin shell. (ADR 0019)
- [ ] **INST-04**: `mix fablebook.migrate.phoenix_storybook`, an Igniter converter (Variation → Scenario, VariationGroup → Group). (ADR 0019, ADR 0023)
- [ ] **INST-05**: The day-0 "aha" comes in under 5 minutes: auto-discovered components rendering in the host's real CSS. (ADR 0019, INT-20261028-01)
- [ ] **INST-06**: `docker compose up` runs a demo of the operator host app, with no database and pinned image digests. (ADR 0019, INT-20261028-01)
- [ ] **INST-07**: A documented convention, with a small helper, so that libraries generating UI into a host (sigra, Crosswake) also generate host-owned Fablebook stories for it. Dogfooded first in sigra. (ADR 0019, INT-20261028-12)

### DOCS

- [ ] **DOCS-01**: Exactly the 12 ExDoc guides listed in ADR 0019, plus cheatsheets and `llms.txt`. Troubleshooting headings are the canonical error strings. (ADR 0019, INT-20261028-01)
- [ ] **DOCS-02**: Comparison and migration content for phoenix_storybook and Storybook, plus security-model and limits sections. (ADR 0019)
- [ ] **DOCS-03**: `UPGRADING.md` per minor release, a compatibility matrix, and a deprecation policy. (ADR 0019, ADR 0007)
- [ ] **DOCS-04**: Fablebook's own brand book is made with abracabrand through the two-session process. It covers the mark, docs site, README, Hex page and social card. The workbench chrome stays ink-on-neutral. (ADR 0013, INT-20261028-15)

### A11Y

- [ ] **A11Y-01**: The workbench chrome meets WCAG 2.2 AA (ADR 0013, INT-20261028-04):
  - landmarks and skip links
  - a disclosure-list sidebar and live regions
  - keyboard-resizable separators and a combobox palette
  - 24 px targets and reflow at 320 px
  - a computed contrast matrix across light, dark and high contrast
- [ ] **A11Y-02**: The chrome passes Fablebook's own sweep (dogfooding). (ADR 0013)

### QA

- [ ] **QA-01**: StreamData invariants: cast, URL state, id stability, manifest determinism, no new atoms, bounded render, frontmatter, contrast maths, telemetry metadata. (ADR 0014, INT-20261028-01)
- [ ] **QA-02**: Muex mutation testing runs weekly on the critical modules. Score floors only go up, and dropping below one blocks the release PR. (ADR 0014, INT-20261028-01)
- [ ] **QA-03**: Igniter.Test golden and idempotency tests, a clean-room tarball consumer, a tarball allowlist test and an API-surface snapshot test. (ADR 0014, ADR 0019)
- [ ] **QA-04**: Two host apps: `hosts/vanilla`, and an adversarial `hosts/operator` that exists as a skeleton from phase 1. (ADR 0020, INT-20261028-01)
- [ ] **QA-06**: Five showcase twins in `hosts/operator`, one Book per product (seven Books: Logistify has three): Chatly, Logistify, Finanza, Shopadelic, Clinicly. Each has an abracabrand-built brand book, full canon, Shell, Areas and Screens, and a visually distinct style. Logistify, Chatly and Clinicly are built in the design-canon phase; the rest come before 1.0. They power the demo, docs screenshots and golden bundles, and never ship in the package. (docs/research/TWINS.md, INT-20261028-08)
- [ ] **QA-05**: One regression test per phoenix_storybook footgun listed in CLEARANCE C2. (ADR 0014, INT-20261028-04)

### CI / REL / COMPAT

- [ ] **CI-01**: Exactly three workflows; `ci.yml` stays ≤250 lines with one required `ci-gate` check. A test enforces these caps. PR p50 ≤ 7 min, measured from CI history. (ADR 0017, INT-20261028-02)
- [ ] **CI-02**: Nightly runs the full suite, Firefox/WebKit and the canary. Release PRs run the heavy suite, and any open `quality-regression` issue blocks the release. (ADR 0017, INT-20261028-04)
- [ ] **REL-01**: release-please publishes to Hex via the bootstrap skill. Phase 1 publishes 0.1.0 to reserve the name. Includes a post-publish smoke test, a recovery workflow and an SBOM. (ADR 0017, INT-20261028-01)
- [ ] **COMPAT-01**: Floor: Elixir 1.18 / OTP 27, Phoenix 1.8.16, LiveView 1.2.9 (`mix.floor.lock`). Latest lane: Elixir 1.19 / OTP 28. Canary: LiveView main. The `ComponentInfo` contract test runs on all three. (ADR 0007, ADR 0008)

### INTENT

- [ ] **INTENT-01**: `.planning/intent/` stays authoritative. `test/planning/intent_test.exs` enforces that sources are add-only, that INT ids are valid in full form, and that every REQ line cites at least one INT or ADR. (ADR 0021, INT-20261028-04)

## v2 Requirements

Deferred on purpose (v1.x or v2). Named so they don't get lost; not in the current roadmap.

- Static export with a "Needs server" badge: deferred to v1.x. The render seam ships now. (ADR 0022, INT-20261028-05)
- An MCP adapter over bundles: deferred to v1.x. The manifest and bundles are the 1.0 contract. (ADR 0009)
- An L4 LLM-judge recipe built on impeccable: deferred to v1.x. Fablebook produces the context; judging stays advisory. (ADR 0010)
- Discovering stories shipped inside dependencies (`priv/fablebook`): deferred to v1.x. (LESSONS-LEARNED)
- A public `Fablebook.Panel` behaviour: deferred until two real external requests. (ADR 0009)
- A hosted interactive mode (a prod mount behind auth): deferred to v2. 1.0 refuses to compile in prod. (ADR 0006)
- Print-style, data-visualization, content-density, information-scent and pre-checked-consent checks: deferred to v1.x. (INT-20261028-13)
- Event record/replay for interactivity in static exports: deferred to v2.

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Inline (non-iframe) rendering in 1.0 | It is the incumbent's root cause of CSS and hook breakage. (ADR 0003) |
| An addon/plugin marketplace | Storybook's addons break on every upgrade. (ADR 0009) |
| White-labelling the workbench chrome | By the Pareto principle, there's no payoff for this audience. (INT-20261028-01) |
| An MDX-style docs format | Plain Markdown and HEEx pages are enough, and docs come from source. (ADR 0013) |
| Saving playground edits to disk from the browser | That would add a write surface with risk close to eval. (ADR 0004) |
| Auto-permutation and knob-combination grids | Scenarios are equivalence classes for real situations. (INT-20261028-04) |
| Comments or collaboration inside Fablebook | Use the PR. (ADR 0013) |
| A hosted visual-regression service, or auto-accepted baselines | Humans accept baselines. (ADR 0011) |
| React or any JS framework in the chrome | We dogfood LiveView. (INT-20261028-01) |
| LiveView 1.1 or older Phoenix | No legacy support. (ADR 0007, INT-20261028-01) |
| A Node toolchain for adopters | Playwright is opt-in and dev/CI-only. (ADR 0018, INT-20261028-02) |
| Rendering anything the Phoenix app doesn't render | Native iOS/Android previews, LiveView Native, and pre-rendered external artifacts are out of scope. Renderers are dispatched by subject kind internally, so Elixir-rendered emails and PDFs could become subject kinds later. Mobile means mobile web and PWAs in 1.0. Crosswake interop is limited to web-only shell-frame previews. (INT-20261028-10) |
| Figma or Sketch integration | Fablebook replaces the need for design tools for solo developers and tiny teams. (INT-20261028-10) |
| A watch device frame | Watches don't run web apps or PWAs. (INT-20261028-14) |
| Video capture as review evidence | Filmstrips and `motion.json` are the evidence; video is at most an optional artifact for people. (ADR 0025) |
| Localized chrome in 1.0 | Copy is English-first, with i18n-ready strings. (ADR 0013) |
| Any LLM API dependency, or a paid service in CI | Fablebook produces context; the judge is advisory. (ADR 0010) |

## Traceability

Which phases cover which requirements. Filled by roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 3 | Pending |
| CORE-02 | Phase 3 | Pending |
| CORE-03 | Phase 15 | Pending |
| CORE-04 | Phase 3 | Pending |
| CORE-05 | Phase 3 | Pending |
| CORE-06 | Phase 3 | Pending |
| CORE-07 | Phase 3 | Pending |
| CORE-12 | Phase 4 | Pending |
| CORE-13 | Phase 28 | Pending |
| CORE-14 | Phase 7 | Pending |
| CORE-08 | Phase 15 | Pending |
| CORE-09 | Phase 4 | Pending |
| CORE-10 | Phase 7 | Pending |
| CORE-11 | Phase 14 | Pending |
| CTRL-01 | Phase 5 | Pending |
| CTRL-02 | Phase 12 | Pending |
| CTRL-03 | Phase 5 | Pending |
| CTRL-04 | Phase 8 | Pending |
| CTRL-06 | Phase 5 | Pending |
| CANVAS-01 | Phase 7 | Pending |
| CANVAS-02 | Phase 7 | Pending |
| CANVAS-03 | Phase 7 | Pending |
| CANVAS-04 | Phase 7 | Pending |
| CANVAS-05 | Phase 8 | Pending |
| CANVAS-06 | Phase 8 | Pending |
| CANVAS-07 | Phase 7 | Pending |
| WB-01 | Phase 11 | Pending |
| WB-02 | Phase 11 | Pending |
| WB-03 | Phase 12 | Pending |
| WB-04 | Phase 12 | Pending |
| WB-05 | Phase 20 | Pending |
| WB-06 | Phase 12 | Pending |
| WB-07 | Phase 13 | Pending |
| WB-08 | Phase 11 | Pending |
| WB-09 | Phase 11 | Pending |
| WB-10 | Phase 13 | Pending |
| WB-11 | Phase 12 | Pending |
| WB-13 | Phase 29 | Pending |
| WB-14 | Phase 22 | Pending |
| WB-15 | Phase 12 | Pending |
| WB-16 | Phase 31 | Pending |
| WB-12 | Phase 22 | Pending |
| WB-17 | Phase 20 | Pending |
| WB-18 | Phase 12 | Pending |
| CANON-01 | Phase 14 | Pending |
| CANON-02 | Phase 14 | Pending |
| CANON-03 | Phase 14 | Pending |
| CANON-04 | Phase 15 | Pending |
| CANON-05 | Phase 16 | Pending |
| CANON-06 | Phase 24 | Pending |
| CANON-07 | Phase 16 | Pending |
| CANON-09 | Phase 14 | Pending |
| CANON-10 | Phase 15 | Pending |
| CANON-11 | Phase 15 | Pending |
| CANON-12 | Phase 14 | Pending |
| CANON-08 | Phase 15 | Pending |
| CHECK-01 | Phase 20 | Pending |
| CHECK-02 | Phase 20 | Pending |
| CHECK-03 | Phase 20 | Pending |
| CHECK-04 | Phase 22 | Pending |
| CHECK-05 | Phase 4 | Pending |
| CHECK-06 | Phase 22 | Pending |
| VIS-01 | Phase 21 | Pending |
| VIS-02 | Phase 21 | Pending |
| VIS-03 | Phase 21 | Pending |
| LLM-01 | Phase 19 | Pending |
| LLM-02 | Phase 27 | Pending |
| LLM-03 | Phase 27 | Pending |
| LLM-04 | Phase 27 | Pending |
| LLM-05 | Phase 20 | Pending |
| LLM-06 | Phase 19 | Pending |
| LLM-07 | Phase 19 | Pending |
| LLM-08 | Phase 29 | Pending |
| JOURNEY-01 | Phase 15 | Pending |
| JOURNEY-02 | Phase 24 | Pending |
| JOURNEY-03 | Phase 29 | Pending |
| MOTION-01 | Phase 25 | Pending |
| MOTION-02 | Phase 26 | Pending |
| MOTION-03 | Phase 26 | Pending |
| MOTION-04 | Phase 26 | Pending |
| MOTION-05 | Phase 26 | Pending |
| MOTION-06 | Phase 26 | Pending |
| MOTION-07 | Phase 29 | Pending |
| UX-01 | Phase 23 | Pending |
| UX-02 | Phase 23 | Pending |
| UX-03 | Phase 23 | Pending |
| UX-04 | Phase 23 | Pending |
| UX-07 | Phase 31 | Pending |
| UX-05 | Phase 24 | Pending |
| UX-06 | Phase 16 | Pending |
| UX-08 | Phase 24 | Pending |
| SKILL-01 | Phase 30 | Pending |
| SKILL-02 | Phase 29 | Pending |
| SEC-01 | Phase 5 | Pending |
| SEC-02 | Phase 1 | Pending |
| SEC-03 | Phase 7 | Pending |
| SEC-04 | Phase 6 | Pending |
| SEC-05 | Phase 12 | Pending |
| PERF-01 | Phase 3 | Pending |
| PERF-02 | Phase 11 | Pending |
| PERF-03 | Phase 11 | Pending |
| PERF-04 | Phase 11 | Pending |
| PERF-05 | Phase 33 | Pending |
| PERF-06 | Phase 33 | Pending |
| TEL-01 | Phase 3 | Pending |
| TEL-02 | Phase 3 | Pending |
| TEL-03 | Phase 3 | Pending |
| INST-01 | Phase 10 | Pending |
| INST-02 | Phase 30 | Pending |
| INST-03 | Phase 30 | Pending |
| INST-04 | Phase 30 | Pending |
| INST-05 | Phase 11 | Pending |
| INST-06 | Phase 31 | Pending |
| INST-07 | Phase 35 | Pending |
| DOCS-01 | Phase 32 | Pending |
| DOCS-02 | Phase 32 | Pending |
| DOCS-03 | Phase 32 | Pending |
| DOCS-04 | Phase 17 | Pending |
| A11Y-01 | Phase 13 | Pending |
| A11Y-02 | Phase 22 | Pending |
| QA-01 | Phase 16 | Pending |
| QA-02 | Phase 33 | Pending |
| QA-03 | Phase 33 | Pending |
| QA-04 | Phase 9 | Pending |
| QA-06 | Phase 34 | Pending |
| QA-05 | Phase 33 | Pending |
| CI-01 | Phase 1 | Pending |
| CI-02 | Phase 21 | Pending |
| REL-01 | Phase 1 | Pending |
| COMPAT-01 | Phase 3 | Pending |
| INTENT-01 | Phase 1 | Pending |

**Coverage:**
- v1 requirements: 131 total
- Mapped to phases: 131
- Unmapped: 0

---
*Requirements defined: 2026-10-28*
*Last updated: 2026-10-28 after initialization*
