# Fablebook

> **Precedence:** verbatim intent (`.planning/intent/sources/`) > ADR (`docs/adr/`) > REQUIREMENTS > this file. `GLOSSARY.md` is the only vocabulary. Citations: `INT-YYYYMMDD-NN` → `.planning/intent/sources/`; `ADR NNNN` → `docs/adr/`. Every requirement keeps its citations.

## What This Is

Fablebook is a Storybook-style workbench for Phoenix LiveView. It renders every real state of a UI, from a single primitive to a whole screen, through the app's own layout, CSS and hooks. It also catalogs the design system's knowledge (tokens, brand, voice, a user-facing glossary, personas and jobs) and turns any scenario into a high-signal context bundle for LLM-assisted design. (INT-20261028-01, INT-20261028-04)

## Core Value

> **Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.**

If everything else fails, a scenario must still render with production fidelity and export an accurate context bundle. The owner keeps using phoenix_storybook until Fablebook clears `.planning/intent/CLEARANCE.md`. (INT-20261028-04)

## Requirements

### Validated

(None yet. Ship to validate.)

### Active

Every item below is a v1.0 commitment.

**CORE: story model and catalog**
- [ ] **CORE-01** Authors declare stories as compiled `.ex` modules in `storybook/` (dev/test `elixirc_paths` only) with `use Fablebook.Story, subject:, tier:`. The macro injects at most 20 lines. (ADR 0001, INT-20261028-01)
- [ ] **CORE-02** Scenarios are plain functions. Arity 0 returns attrs/slots data; arity 1 returns a `~H` template. Slots are never strings: plain text is escaped, and rich slots are captured functions. (ADR 0002, INT-20261028-01)
- [ ] **CORE-03** Each scenario has a required situation `desc` plus `persona:`, `job:`, `twin:` (a fixed citation: the "Sample data" control filters by it and never swaps data), `state:` (one or more state classes), `group:` and `tags:`. Citation shape is checked at compile time and existence when the catalog is built. Persona and job citations are required on Area and Screen scenarios: a warning until the canon has its first persona, an error after that, waivable per scenario only. A scenario may cite several jobs. (ADR 0002, INT-20261028-04)
- [ ] **CORE-04** The catalog is a pure function that behaves the same in dev and test. It is assembled once per workbench mount and rebuilt on code reload; there is no cache process, ETS or `:persistent_term`. Ids come from module namespace plus function name, and every scenario has a stable URL, including scenarios inside groups. (ADR 0008)
- [ ] **CORE-05** Components with no story come from the Book's `components:` list and render as **Unstoried** auto-stories. Required attrs are filled from the declared `default`, then `examples`, then `values`; if none of these exist, the component shows a "Needs a story" tile. Fablebook never invents a value. (ADR 0008, INT-20261028-01)
- [ ] **CORE-06** Four tiers, each answering one question: Primitive · Pattern · Area (the Shell is an Area) · Screen. The sidebar is tier-first, with product-noun Section folders inside each tier. Foundations is a separate section that presents the canon. (ADR 0023, INT-20261028-04, INT-20261028-07)
- [ ] **CORE-07** Every story has exactly one subject, and every component has at most one story. Area and Screen subjects must be presentational function components. LiveComponents (with declared controls) are allowed up to Area. A LiveView subject needs a Waiver. Pages (Markdown/HEEx) are catalog entries without a subject. (ADR 0002, INT-20261028-06)
- [ ] **CORE-12** Strict by default: every rule in ADR 0024 is on, the only escape hatch is a per-story or per-scenario **Waiver** with a written reason, waivers are visible and counted, and there is no global off switch. (ADR 0024, INT-20261028-07, INT-20261028-08)
- [ ] **CORE-13** **Draft** stories and scenarios turn strict-rule errors into warnings and stay listed in To review. `mix fablebook.gen.screens` scaffolds a Shell plus one Draft Screen story per canon job, for greenfield work. Bundles accept `--focus explore`. (ADR 0024, INT-20261028-09, INT-20261028-11)
- [ ] **CORE-14** Render mode `render: :live | :static`. A static story is served by a controller with no LiveSocket, exactly as a dead view runs in production. A check flags `phx-*` LiveView bindings in static stories. (ADR 0022, INT-20261028-10, INT-20261028-11)
- [ ] **CORE-08** A coverage matrix crosses stories with the closed state-class set (happy, empty, one, many, boundary, loading, error, denied, stale, long, intl, huge). Each cell is a scenario or a reasoned **waiver**, and gaps are reported. (GLOSSARY, INT-20261028-04)
- [ ] **CORE-09** A render seam, `Fablebook.Render.render(scenario, globals, purpose)`, runs outside any LiveView and is shared by the canvas, tests and bundles (later also export). (ADR 0022)
- [ ] **CORE-10** Stories and the Book can wrap scenarios in containers. Placement is `:centered`, `:padded` or `:fullscreen`. (ADR 0002)
- [ ] **CORE-11** Pages can embed live scenarios, so guides stay accurate. (ADR 0013, INT-20261028-04)

**CTRL: controls and URL state**
- [ ] **CTRL-01** Typed controls are generated from attr metadata: boolean, integer, float, string, and a select for `values:`. Complex attrs use compiled **presets**. (ADR 0004)
- [ ] **CTRL-02** An override shows an "Edited" chip and offers **Restore scenario**. Attrs that can't be edited say "Set in the story file" and offer Open in editor. (ADR 0013)
- [ ] **CTRL-03** All view state lives in the URL (scenario, `o` overrides ≤2 KB, `vw`, `frame`, `scheme`, `theme`, `direction`, `dir`, `locale`, `motion`, `zoom`, `twin` (filter), `check`), so a reload reproduces it exactly. See the parameter table in UX-DESIGN. (ADR 0013, INT-20261028-04)
- [ ] **CTRL-04** Globals are a closed set: theme, design direction (a candidate look), color scheme (light/dark/system), locale (Gettext), text direction, viewport, device frame and motion (full/reduce/off). (ADR 0002, INT-20261028-13)
- [ ] **CTRL-06** Editing a Control offers "Copy as scenario": Elixir text for a new Draft scenario with the overridden attrs and a TODO situation. Values print from typed controls only, no atoms are created, and nothing is written to disk. (ADR 0004, ADR 0013, INT-20261028-16)

**CANVAS: fidelity and isolation**
- [ ] **CANVAS-01** Scenarios always render in an iframe that goes through the host's own pipeline and root layout, so they get the real `app.css`, `app.js`, colocated hooks, fonts and CSP. (ADR 0003, INT-20261028-01)
- [ ] **CANVAS-02** The All-scenarios grid stacks a story's scenarios in one iframe and lazy-loads the tiles. (ADR 0003)
- [ ] **CANVAS-03** A scenario that raises, throws, exits, times out (2 s) or exceeds its heap shows an error panel. The workbench keeps running and other tiles keep rendering. (ADR 0003, INT-20261028-01)
- [ ] **CANVAS-04** The workbench and canvas talk over a `Phoenix.Token`-signed topic. The event log keeps string names only, truncates payloads, and is scoped to the canvas. (ADR 0004)
- [ ] **CANVAS-05** When the canvas fails to connect, a diagnostic names the likely causes (`window.liveSocket`, `frame-ancestors`). (ADR 0003)
- [ ] **CANVAS-06** Recompiling a story or component updates the open workbench without a restart. (ADR 0008, INT-20261028-01)
- [ ] **CANVAS-07** The canvas absorbs events and navigation it has no handler for (catch-all `handle_event/3`, `handle_info/2`, `handle_params/3`, `layout: false`) and logs "Event recorded" or "Would navigate to /x" instead of crashing or leaving. (ADR 0003, ADR 0004, INT-20261028-16)

**WB: workbench UX**
- [ ] **WB-01** The workbench has three panes. The toolbar belongs to the canvas, every tool shows its value as text, and a tool appears only when it applies. (ADR 0013, INT-20261028-01)
- [ ] **WB-02** **All scenarios** grid by default. The story page *is* the docs: description, citations, attr/slot Reference, then the grid. (ADR 0013)
- [ ] **WB-03** A ⌘K palette searches stories, scenarios, pages, canon and commands; `/` filters the sidebar. (ADR 0013)
- [ ] **WB-04** The full keyboard map from UX-DESIGN. Single-key shortcuts can be turned off and are suspended while focus is in the preview. (ADR 0013)
- [ ] **WB-05** Inspector tabs: Attrs · HEEx (copy the exact call) · Events · Checks. (ADR 0013)
- [ ] **WB-06** Toolbar tools (ADR 0013, INT-20261028-04):
  - Width presets 320/375/768/1280/1440, Fill and custom, opening at 375 (mobile first).
  - Color scheme, theme, direction, zoom, outline, measure.
  - Background (shown only for transparent subjects), Isolate (canvas only) and fullscreen.
  - Light/dark side by side.
- [ ] **WB-07** Below 768 px the workbench switches to Mobile layout. "Show on phone" offers a QR code, and says plainly when it can't. (ADR 0013)
- [ ] **WB-08** The workbench's **Appearance** (System/Light/Dark) is a separate control from the preview's **Theme**. (ADR 0013)
- [ ] **WB-09** Chrome visual system: ink on neutral, `fb-` OKLCH tokens, Tailwind namespaces reset, system fonts, two density modes, no daisyUI. The workbench never animates the canvas itself (render swaps are instant), but the subject's own motion always plays unless the Motion global is `reduce` or `off`. (ADR 0013, INT-20261028-01)
- [ ] **WB-10** Canonical microcopy for every empty, error and disconnected state, as listed in UX-DESIGN. (ADR 0013, INT-20261028-01)
- [ ] **WB-11** Open in editor, restricted to localhost and to paths inside the project root. (ADR 0004)
- [ ] **WB-13** **Compare** mode: renditions side by side that differ in exactly one respect (a global, a theme, or a revision against main), at any tier. Bundles accept `--focus compare`. (ADR 0013, INT-20261028-09, INT-20261028-10)
- [ ] **WB-14** **To review** page (the Review queue) with a sidebar count badge and no pop-ups. It lists proposals, stale or assumed canon, findings without a verdict, coverage gaps and waivers due for review. (ADR 0013, INT-20261028-09)
- [ ] **WB-15** **Device frames**: none, phone, tablet, laptop or desktop. Generic outlines (not branded device art). Phone and tablet show safe areas, a status bar and standalone (PWA) display. (ADR 0013, INT-20261028-12, INT-20261028-14)
- [ ] **WB-16** **Export image**: a framed, high-resolution PNG of any scenario, optionally on a background, from the workbench or `mix fablebook.shot <scenario> --frame phone --scheme dark`. It uses browser capture (opt-in). (ADR 0011, INT-20261028-14)
- [ ] **WB-12** A dev Diagnostics page: catalog build time, scenario count, recent crashes, evidence staleness. (ADR 0016)
- [ ] **WB-17** Sidebar dots and tile status read the latest Evidence keyed by render hash and show "Not run" until Evidence exists, never a green dot. "Run checks" runs the probe for the open rendition (and at story level across the width presets) in the user's browser. (ADR 0011, ADR 0010, INT-20261028-04, INT-20261028-16)
- [ ] **WB-18** Width presets carry a height and a rotate action (an `orient` URL parameter). Workbench settings (Appearance, density, single-key shortcut switch, pane sizes) persist and are listed. (ADR 0013, INT-20261028-16)

**CANON: design-system knowledge as content**
- [ ] **CANON-01** The `design/` canon is one Markdown file per entry with strict-subset frontmatter, parsed by our own parser (property-tested, no YAML dependency). (ADR 0012, INT-20261028-05)
- [ ] **CANON-02** Entry kinds: term (user-facing ↔ internal, avoid, retired), voice, tone, microcopy rules, persona, job, twin, imagery. (ADR 0012, INT-20261028-04)
- [ ] **CANON-03** Tokens are DTCG 2025.10 (`design/tokens/*.tokens.json` plus a light/dark resolver). abracabrand's `brandbook/tokens/identity.json` is read, with `$extensions` preserved, and never written. (ADR 0012)
- [ ] **CANON-04** Foundations pages: token swatches, type scale, radius/shadow/motion specimens, contrast cards, the glossary table, voice, and persona/job/twin cards linking to the scenarios that cite them. (ADR 0012, INT-20261028-04)
- [ ] **CANON-05** abracabrand interop: BRAND.md and direction-note sections become Voice, Imagery and Applications pages; logos are filtered by `rights/assets.json`; bundles pin the brand by its `inventory.json` hash. (ADR 0012)
- [ ] **CANON-06** Fablebook generates `DESIGN.md` (Google design.md spec) and `.impeccable/design.json` from tokens plus **rendered** primitives. Both carry an ownership header, and Fablebook refuses to overwrite files it doesn't own. `mix fablebook.tokens` generates and checks CSS from the tokens. (ADR 0012)
- [ ] **CANON-07** Pure-Elixir lints in the PR lane (ADR 0012, INT-20261028-04):
  - Glossary and retired-wording checks over rendered text and accessible names.
  - Deterministic voice rules.
  - Token conformance and drift from DTCG to CSS.
  - A WCAG 2.2 contrast matrix.
- [ ] **CANON-09** Canon layers: a **brand canon** shared by a product family, and **product canons** that inherit it. A Book points at one product canon, and overriding a brand rule needs a Waiver. (ADR 0012, INT-20261028-10)
- [ ] **CANON-10** Themes: a Book can render under several named themes, and a twin may bring its own theme (white-label). **Guardrails** turn unreadable theme choices into findings. (ADR 0012, INT-20261028-10)
- [ ] **CANON-11** **Directions**: named candidate looks and voices (`proposal` until chosen) that can be selected in the toolbar and compared across the catalog. abracabrand's routes import as Directions. Choosing one makes it the canon and archives the rest. (ADR 0012, INT-20261028-09, INT-20261028-11)
- [ ] **CANON-12** The brand canon can come from a path or a dependency (`canon: [brand: {:logistify_brand, "design"}, product: "design"]`), so product families can span repos. (ADR 0012, INT-20261028-11)
- [ ] **CANON-08** Intent coverage: broken citations, orphan personas, uncovered jobs, and persona/job citation enforcement. (ADR 0002, INT-20261028-04)

**CHECK: probe, sweep, findings**
- [ ] **CHECK-01** A probe script with vendored axe-core collects (ADR 0011, INT-20261028-04):
  - axe results (incomplete counts as a finding)
  - overflow, target size and 200% text
  - focus walk and computed-style token conformance
  - contrast and the ARIA snapshot
  The output follows a versioned Evidence schema.
- [ ] **CHECK-02** The Checks tab runs the same probe live, needs no Node, and finds exactly what CI finds. Each finding has "Copy finding link". (ADR 0011)
- [ ] **CHECK-03** Simulations: reduced motion, 200% text, text expansion +35% (readable, no pseudo-accents), forced colors, RTL, vision-deficiency filters, keyboard-only. (ADR 0013)
- [ ] **CHECK-04** A sweep driven by the manifest covers 320/375/768/1280/1440 × light/dark, plus reduced motion. Findings are fingerprinted, and a ratchet ensures the count only shrinks. (ADR 0017, INT-20261028-04)
- [ ] **CHECK-05** `Fablebook.Testing.generate_tests(book)` creates one ExUnit test per scenario (renders, attrs valid, desc present, citations resolve). `mount_scenario/2` uses `live_isolated`. (ADR 0014)
- [ ] **CHECK-06** A verdicts log in the repo records each finding's fingerprint, verdict and reason. A rejected finding is suppressed in later reports and bundles. (ADR 0010, INT-20261028-04)

**VIS: visual regression**
- [ ] **VIS-01** Pixel diffs run in a pinned Playwright container with a deterministic recipe: fonts ready, DPR 1, animations off, a ready attribute, a frozen clock. (ADR 0011, INT-20261028-04)
- [ ] **VIS-02** Baselines are **never auto-accepted**. CI fails if a baseline is missing, if `git status` changes, or if the baseline set doesn't match the manifest. Only a human, via `bin/visual update`, accepts baselines. (ADR 0011)
- [ ] **VIS-03** PRs run visual-core (≤40 renditions). Nightly and release runs cover the full set (≤400). A determinism self-test (identical hashes) blocks release. (ADR 0017)

**LLM: context bundles (core)**
- [ ] **LLM-01** `mix fablebook.bundle <selector>`, plus **Copy for LLM** and **Download context** in the workbench. Selectors: scenario, story, section, tier, tag, all. (ADR 0010, INT-20261028-04)
- [ ] **LLM-02** Bundle layout (ADR 0010):
  - `BUNDLE.md` and `bundle.json` (schema `fablebook.bundle/1`)
  - `context/`: DESIGN.md, the tokens used, glossary hits, voice, personas/jobs, a PRODUCT.md excerpt
  - `scenarios/<id>/`: PNG shots, `aria.yaml`, markup, styles, measurements, a11y, copy
- [ ] **LLM-03** A token-budget allocator with summary/standard/full detail levels. It tiles tall views by viewport height, switches to grid contact sheets past 20 images, and reports what it dropped. (ADR 0010)
- [ ] **LLM-04** Two capture levels: no-browser capture in pure Elixir, and opt-in `--browser` capture that shares the visual capture pipeline. (ADR 0010, ADR 0018)
- [ ] **LLM-05** Evidence is keyed by render hash. Stale or missing evidence is labelled and never presented as current. (ADR 0010)
- [ ] **LLM-06** The manifest (`index.json`, `components.json`) is served at the mount and written by `mix fablebook.manifest`, with drift checking. `llms.txt` and `llms-full.txt` are included. (ADR 0009)
- [ ] **LLM-07** A committed JSON Schema with a `Fablebook.Bundle.validate/1` round-trip, three golden bundles, a determinism property, and size budgets (≤~7.5k text tokens and ≤1.5 MB per scenario). (ADR 0010)
- [ ] **LLM-08** Bundles take one `--focus` from the closed list (explore, critique, copy, a11y, layout, consistency, brand, compare, journey, motion). Each focus has its own rubric digest and reading order in `BUNDLE.md`. Adding a focus requires an ADR. (ADR 0010, INT-20261028-12)

**JOURNEY: transitions between screens**
- [ ] **JOURNEY-01** **Journeys** are linear lists of **Steps** (each a scenario plus the user action that leads on), declared in the job's canon file. Each alternative path is its own journey. The catalog build checks that every referenced scenario exists. (ADR 0012, INT-20261028-12, INT-20261028-14)
- [ ] **JOURNEY-02** Step checks: the step's action must exist as an interactive element with that accessible name in the step's rendition (dead-end check), and its label must match (copy-drift check). Across steps, the Shell's navigation must be identical, and the same terms must be used for the same things. (ADR 0024, INT-20261028-14)
- [ ] **JOURNEY-03** The workbench shows a journey as a filmstrip of its steps. The `journey` bundle focus sends the whole flow to an LLM. (ADR 0010, INT-20261028-12)

**MOTION: animation as a first-class lane** (ADR 0025)
- [ ] **MOTION-01** The workbench has a Motion panel. It can pause and scrub every canvas animation on a timeline, play at 0.1×, 0.25× or 0.5× (a time shim stops LiveView timers from cutting animations short), and show a filmstrip at 0/50/100/150/200/300 ms plus the settled state. (ADR 0025, INT-20261028-12, INT-20261028-13)
- [ ] **MOTION-02** The canon has motion tokens, with strong default easing curves that override Tailwind's weak default. Computed durations and easings must be on-token. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-03** Strict motion checks: no `transition: all`, no animated layout properties, no ease-in on enter, no `scale(0)`, UI motion at most 300 ms unless tagged marketing, hover motion only inside `(hover:hover)`, and nothing moves under reduced motion. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-04** LiveView motion lints: `JS` `time:` must equal the CSS duration; `blocking: true` is flagged on decorative transitions; `JS.show` without `display:` is flagged on flex or grid; `stream_delete` without an exit animation is flagged. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-05** Scenarios carry a `motion_tier:` (keyboard, frequent, occasional, rare), linted against the frequency gate. (ADR 0025, INT-20261028-13)
- [ ] **MOTION-06** A CI motion lane baselines and diffs seeked filmstrips. Ordinary visual diffs keep animations off. The installer adds the reduced-motion custom variant and the doctor checks for it. (ADR 0025, ADR 0011, INT-20261028-13)
- [ ] **MOTION-07** The `motion` bundle focus provides `motion.json` (keyframes, timing, easing, 16 ms samples), a filmstrip contact sheet, and reduced-motion frames, never video. The bundle says that judging feel needs a person watching at 0.25×. (ADR 0025, ADR 0010, INT-20261028-13)

**UX: additional quality dimensions** (`docs/research/MOTION-AND-UX-DIMENSIONS.md`)
- [ ] **UX-01** Any scenario can be viewed in forced interaction states (hover, focus-visible, active, disabled) without a mouse. A check confirms each state looks different from rest and that `phx-click-loading` is styled. (ADR 0024, INT-20261028-13)
- [ ] **UX-02** Form checks: label association, `aria-invalid`/`aria-describedby`, errors only after a field is touched (`used_input?`), autocomplete and inputmode, no placeholder-only labels. (ADR 0024, INT-20261028-13)
- [ ] **UX-03** A layout-shift check during a scripted load, and a check that skeletons match the final content size. (ADR 0024, INT-20261028-13)
- [ ] **UX-04** An RTL logical-property lint (`ms-`/`start`, not `ml-`/`left`) and locale-formatting checks: flag English-formatted numbers and dates under non-English locales, and require `<time datetime>`. (ADR 0024, INT-20261028-13)
- [ ] **UX-07** An optional Credo check for apps whose Book declares Gettext: it flags user-visible literal text in `~H` not wrapped in `gettext`. Waivable with a reason, e.g. for brand names. (ADR 0024, INT-20261028-12, INT-20261028-14)
- [ ] **UX-05** A destructive-dialog guard: cancel must not be visually weaker than a destructive confirm. Plus a glossary-based confirmshaming lint. (ADR 0024, INT-20261028-13)
- [ ] **UX-06** Copy lint benchmarks: button word count, title and error length, sentence length, reading grade per persona, and generic labels such as "Click here" or "Submit". (ADR 0024, INT-20261028-13)
- [ ] **UX-08** Feedback and focus checks: toasts use a live region with the right politeness, never steal focus, last at least 5 s or can be paused, and can be dismissed; modals trap focus and return it on close; focus survives a LiveView patch; every error state offers an action. (ADR 0024, INT-20261028-13, INT-20261028-14)

**SKILL: agent skills**
- [ ] **SKILL-01** Fablebook ships small skills (`fablebook`, `fablebook-review`, `fablebook-motion`, `fablebook-canon`), installed via `usage_rules` sync or `mix fablebook.skills.install`. Installs are version-stamped and never overwrite user edits. (ADR 0010, INT-20261028-12, INT-20261028-13)
- [ ] **SKILL-02** Rules live in checks with stable ids, and bundles carry a short, credited digest for each focus. Upstream skills (impeccable, ux-writing, review-animations, emil-design-eng) are named when installed and suggested as optional otherwise. They are never installed silently. (ADR 0010, INT-20261028-13)

**SEC: security**
- [ ] **SEC-01** No `Code.eval*`, no runtime EEx/HEEx compilation, and no `String.to_atom` on input. Credo bans these, and properties plus mutation-proven tests confirm it. (ADR 0004, INT-20261028-01)
- [ ] **SEC-02** In prod the router macro raises a `CompileError`, with no override in 1.0. Stories and canon never compile in prod. The CI prod build asserts there are no Fablebook routes and no story beams. (ADR 0006)
- [ ] **SEC-03** CSP nonces everywhere (`csp_nonce_assign_key`). No `eval` or `new Function`. Iframe sandbox attributes and `frame-ancestors 'self'`. (ADR 0005)
- [ ] **SEC-04** Bundle redaction strips paths, env values, hosts, secret-shaped strings and session/CSRF tokens. A `redact:` hook is available. (ADR 0010)
- [ ] **SEC-05** Size caps per control type (`:state_too_large`), path containment for `--out` and the editor (`:path_rejected`), and descriptions/Markdown escaped by default. (ADR 0004)

**PERF: deterministic gates**
- [ ] **PERF-01** Catalog scaling: t(5000)/t(500) < 15, 5000 scenarios ≤ 1.5 s, no `Code` calls during the build. (ADR 0015, INT-20261028-01)
- [ ] **PERF-02** Mount and render reductions stay within 1.25× the committed reference measurement, and the maximum render over 10k iterations is ≤ 50 ms. (ADR 0015)
- [ ] **PERF-03** A control change produces a WebSocket diff ≤ 4 KB, and the sidebar is never re-sent. (ADR 0015)
- [ ] **PERF-04** Session heap ≤ 3 MB. A leak test over 10k events stays within 1.2× steady state. Fablebook adds 0 ETS tables and 0 processes to the host. (ADR 0015)
- [ ] **PERF-05** Host compile overhead ≤ 15% with 500 stories (nightly/release lane). Touching one component recompiles at most one story. (ADR 0015)
- [ ] **PERF-06** A sibling `bench/` project (Benchee) tracks p50/p99/p99.9/max against committed reference measurements with sensitivity controls. It is advisory only. (ADR 0015, INT-20261028-01)

**TEL: telemetry and errors**
- [ ] **TEL-01** Spans named `[:fablebook, domain, action, *]` are catalogued in `Fablebook.Telemetry.events/0`. A test confirms every listed event is emitted and nothing unlisted is. (ADR 0016, INT-20261028-01)
- [ ] **TEL-02** Metadata is whitelisted to ids, counts and enums. Fablebook never attaches handlers. A LiveDashboard metrics recipe is documented. (ADR 0016)
- [ ] **TEL-03** Errors use `%Fablebook.Error{type:}` with the closed set in DOMAIN-MODEL §2. Declaration mistakes raise `CompileError` with file, line, value and a fix. Error messages have snapshot tests. (ADR 0016)

**INST: install, generators, upgrade**
- [ ] **INST-01** `mix igniter.install fablebook` mounts `/dev/fablebook` inside `dev_routes` and sets up `elixirc_paths`, live_reload, the formatter, the Book (`components:` seeded), a welcome page and a sample story. It never touches `app.js` or the Tailwind config. (ADR 0019, INT-20261028-01)
- [ ] **INST-02** `mix fablebook.gen.story Module.fun`. (ADR 0019)
- [ ] **INST-03** `mix fablebook.doctor [--ci]`, built as a pure core with a thin shell. (ADR 0019)
- [ ] **INST-04** `mix fablebook.migrate.phoenix_storybook`, an Igniter converter (Variation → Scenario, VariationGroup → Group). (ADR 0019, ADR 0023)
- [ ] **INST-05** The day-0 "aha" comes in under 5 minutes: auto-discovered components rendering in the host's real CSS. (ADR 0019, INT-20261028-01)
- [ ] **INST-06** `docker compose up` runs a demo of the operator host app, with no database and pinned image digests. (ADR 0019, INT-20261028-01)
- [ ] **INST-07** A documented convention, with a small helper, so that libraries generating UI into a host (sigra, Crosswake) also generate host-owned Fablebook stories for it. Dogfooded first in sigra. (ADR 0019, INT-20261028-12)

**DOCS**
- [ ] **DOCS-01** Exactly the 12 ExDoc guides listed in ADR 0019, plus cheatsheets and `llms.txt`. Troubleshooting headings are the canonical error strings. (ADR 0019, INT-20261028-01)
- [ ] **DOCS-02** Comparison and migration content for phoenix_storybook and Storybook, plus security-model and limits sections. (ADR 0019)
- [ ] **DOCS-03** `UPGRADING.md` per minor release, a compatibility matrix, and a deprecation policy. (ADR 0019, ADR 0007)
- [ ] **DOCS-04** Fablebook's own brand book is made with abracabrand through the two-session process. It covers the mark, docs site, README, Hex page and social card. The workbench chrome stays ink-on-neutral. (ADR 0013, INT-20261028-15)

**A11Y**
- [ ] **A11Y-01** The workbench chrome meets WCAG 2.2 AA (ADR 0013, INT-20261028-04):
  - landmarks and skip links
  - a disclosure-list sidebar and live regions
  - keyboard-resizable separators and a combobox palette
  - 24 px targets and reflow at 320 px
  - a computed contrast matrix across light, dark and high contrast
- [ ] **A11Y-02** The chrome passes Fablebook's own sweep (dogfooding). (ADR 0013)

**QA**
- [ ] **QA-01** StreamData invariants: cast, URL state, id stability, manifest determinism, no new atoms, bounded render, frontmatter, contrast maths, telemetry metadata. (ADR 0014, INT-20261028-01)
- [ ] **QA-02** Muex mutation testing runs weekly on the critical modules. Score floors only go up, and dropping below one blocks the release PR. (ADR 0014, INT-20261028-01)
- [ ] **QA-03** Igniter.Test golden and idempotency tests, a clean-room tarball consumer, a tarball allowlist test and an API-surface snapshot test. (ADR 0014, ADR 0019)
- [ ] **QA-04** Two host apps: `hosts/vanilla`, and an adversarial `hosts/operator` that exists as a skeleton from phase 1. (ADR 0020, INT-20261028-01)
- [ ] **QA-06** Five showcase twins in `hosts/operator`, one Book per product (seven Books: Logistify has three): Chatly, Logistify, Finanza, Shopadelic, Clinicly. Each has an abracabrand-built brand book, full canon, Shell, Areas and Screens, and a visually distinct style. Logistify, Chatly and Clinicly are built in the design-canon phase; the rest come before 1.0. They power the demo, docs screenshots and golden bundles, and never ship in the package. (docs/research/TWINS.md, INT-20261028-08)
- [ ] **QA-05** One regression test per phoenix_storybook footgun listed in CLEARANCE C2. (ADR 0014, INT-20261028-04)

**CI / REL / COMPAT**
- [ ] **CI-01** Exactly three workflows; `ci.yml` stays ≤250 lines with one required `ci-gate` check. A test enforces these caps. PR p50 ≤ 7 min, measured from CI history. (ADR 0017, INT-20261028-02)
- [ ] **CI-02** Nightly runs the full suite, Firefox/WebKit and the canary. Release PRs run the heavy suite, and any open `quality-regression` issue blocks the release. (ADR 0017, INT-20261028-04)
- [ ] **REL-01** release-please publishes to Hex via the bootstrap skill. Phase 1 publishes 0.1.0 to reserve the name. Includes a post-publish smoke test, a recovery workflow and an SBOM. (ADR 0017, INT-20261028-01)
- [ ] **COMPAT-01** Floor: Elixir 1.18 / OTP 27, Phoenix 1.8.16, LiveView 1.2.9 (`mix.floor.lock`). Latest lane: Elixir 1.19 / OTP 28. Canary: LiveView main. The `ComponentInfo` contract test runs on all three. (ADR 0007, ADR 0008)

**INTENT**
- [ ] **INTENT-01** `.planning/intent/` stays authoritative. `test/planning/intent_test.exs` enforces that sources are add-only, that INT ids are valid in full form, and that every REQ line cites at least one INT or ADR. (ADR 0021, INT-20261028-04)

### Out of Scope

**Deferred on purpose.** They are named here so they don't get lost.
- Static export with a "Needs server" badge: deferred to v1.x. The render seam ships now. (ADR 0022, INT-20261028-05)
- An MCP adapter over bundles: deferred to v1.x. The manifest and bundles are the 1.0 contract. (ADR 0009)
- An L4 LLM-judge recipe built on impeccable: deferred to v1.x. Fablebook produces the context; judging stays advisory. (ADR 0010)
- Discovering stories shipped inside dependencies (`priv/fablebook`): deferred to v1.x. (LESSONS-LEARNED)
- A public `Fablebook.Panel` behaviour: deferred until two real external requests. (ADR 0009)
- A hosted interactive mode (a prod mount behind auth): deferred to v2. 1.0 refuses to compile in prod. (ADR 0006)
- Print-style, data-visualization, content-density, information-scent and pre-checked-consent checks: deferred to v1.x. (INT-20261028-13)
- Event record/replay for interactivity in static exports: deferred to v2.

**Not doing:**
- Inline (non-iframe) rendering in 1.0. It is the incumbent's root cause of CSS and hook breakage. (ADR 0003)
- An addon/plugin marketplace. Storybook's addons break on every upgrade. (ADR 0009)
- White-labelling the workbench chrome. By the Pareto principle, there's no payoff for this audience. (INT-20261028-01)
- An MDX-style docs format. Plain Markdown and HEEx pages are enough, and docs come from source. (ADR 0013)
- Saving playground edits to disk from the browser. That would add a write surface with risk close to eval. (ADR 0004)
- Auto-permutation and knob-combination grids. Scenarios are equivalence classes for real situations. (INT-20261028-04)
- Comments or collaboration inside Fablebook. Use the PR. (ADR 0013)
- A hosted visual-regression service, or auto-accepted baselines. Humans accept baselines. (ADR 0011)
- React or any JS framework in the chrome. We dogfood LiveView. (INT-20261028-01)
- LiveView 1.1 or older Phoenix. No legacy support. (ADR 0007, INT-20261028-01)
- A Node toolchain for adopters. Playwright is opt-in and dev/CI-only. (ADR 0018, INT-20261028-02)
- Rendering anything the Phoenix app doesn't render. Native iOS/Android previews, LiveView Native, and pre-rendered external artifacts are out of scope. Renderers are dispatched by subject kind internally, so Elixir-rendered emails and PDFs could become subject kinds later. Mobile means mobile web and PWAs in 1.0. Crosswake interop is limited to web-only shell-frame previews. (INT-20261028-10)
- Figma or Sketch integration. Fablebook replaces the need for design tools for solo developers and tiny teams. (INT-20261028-10)
- A watch device frame. Watches don't run web apps or PWAs. (INT-20261028-14)
- Video capture as review evidence. Filmstrips and `motion.json` are the evidence; video is at most an optional artifact for people. (ADR 0025)
- Localized chrome in 1.0. Copy is English-first, with i18n-ready strings. (ADR 0013)
- Any LLM API dependency, or a paid service in CI. Fablebook produces context; the judge is advisory. (ADR 0010)

## Context

- **Ecosystem (verified 2026-10-28):**
  - Phoenix 1.8.16 and LiveView 1.2.13 are current; there is no Phoenix 1.9.
  - Tailwind v4 plus daisyUI are the generator defaults.
  - Colocated hooks and CSS work only through the host's `app.js`/`app.css`.
  - `__components__/0` exposes attr/slot metadata, but it is undocumented and sorted by name.
  - Details: `docs/research/STACK-FACTS.md`.
- **The incumbent, phoenix_storybook 1.5:**
  - Its playground allowed remote code execution until 1.1 (CVE-2026-8467).
  - Inline CSS isolation is its most common pain.
  - Hooks, slots and complex attrs break.
  - It breaks on every Phoenix/LiveView minor.
  - It has no manifest in test, no viewport control and weak CSP.
  - Open asks include auto-generated stories, agent export and visual regression.
  - Details: `docs/research/LESSONS-LEARNED.md`.
- **Other ecosystems:**
  - Storybook 9–10 reorganized around "stories as tests" and AI manifests/MCP after criticism of its bloat.
  - Ladle showed that batteries included, URL state and instant boot win users.
  - Lookbook (Rails) is the closest server-rendered analog. Its top asks: theme switcher, viewport presets, several examples per window, deployability.
  - Histoire contributes the grid of variants; React Cosmos, the renderer seam; Widgetbook, the lesson that visual tests need fixed states.
- **The owner's prior work:**
  - The owner already uses phoenix_storybook in four repos.
  - They wrote the UI-quality methodology Fablebook implements: fractal stories, persona fixtures, L1–L5 layered checks, ratchets.
  - They have established conventions for embedded LiveView UIs and a canonical Hex release skill.
  - Details: `docs/research/OWNER-DNA.md`.
- **Interop:**
  - abracabrand: brand books with a narrow DTCG subset and `uses` contrast rows.
  - impeccable: PRODUCT.md, DESIGN.md, a critique rubric.
  - Details: `docs/research/LLM-CONTEXT-AND-CANON.md`.
- **Personas:** see `docs/research/PERSONAS-JTBD.md`. The evaluator, the AI agent and the owner-as-library-author decide adoption.
- **Dogfood fleet:** mailglass demo, accrue_admin, scrypath_ops and threadline. All are on LiveView 1.1.x today and need to upgrade first (OPEN-QUESTIONS Q2).
- **Vocabulary:** `GLOSSARY.md` is the only source of terms. Key words: Book, Workbench, Canvas, Story, Subject, Scenario, Situation, Group, Attrs/Slots, Control, Preset, Override, Globals, Tier, State class, Waiver, Coverage, Canon, Term, Voice, Persona, Job, Twin (a fictional organization the UI serves), Citation, Rendition, Probe, Check, Evidence, Finding, Ratchet, Known findings, Baseline, Golden, Verdict, Review queue, Journey, Step, Direction, Theme, Draft, Catalog, Manifest, Bundle, Host app (a CI app).

## Constraints

- **Quality**: The north-star bar is never lowered. If a phase can't meet its gates, it splits. A gate can only be lowered by an owner-signed DECISION that cites an INT id. (ADR 0021, INT-20261028-04)
- **Tech**: Phoenix ~> 1.8.16, LiveView ~> 1.2.9, Elixir ≥ 1.18 / OTP ≥ 27 only. Use public LiveView APIs only, except for one adapter around `__components__/0`. (ADR 0007, ADR 0008)
- **Tech**: No runtime eval and no atoms from input, ever. (ADR 0004)
- **Tech**: Start zero processes in the host. No `name: __MODULE__` singletons. No `compile_env` outside config. No `:persistent_term`. (ADR 0005, ADR 0008)
- **Tech**: The canvas is always an iframe through the host's pipeline and root layout. Stories use only the app's real CSS classes; Fablebook provides placement CSS. (ADR 0003)
- **Dependencies**: Runtime deps are `phoenix`, `phoenix_live_view`, `phoenix_html`, `telemetry` and `nimble_options`. Optional: `igniter`, `earmark`, `phoenix_test_playwright`. Banned: jason, mdex, floki, any YAML library, `telemetry_metrics`. Copy-paste beats adding a dependency, and any new dependency needs an ADR. Adopters never need Node; Node is allowed only behind opt-in browser features. (ADR 0018, INT-20261028-02)
- **CSS**: The chrome uses a standalone Tailwind v4 build committed to `priv/static`, with a drift check. Never touch the host's `app.js` or Tailwind config. (ADR 0005)
- **Performance**: Gate on deterministic proxies (scaling ratios, reductions, diff bytes, heap, process count). Track tail latency in `bench/` only, never as a CI gate. (ADR 0015, INT-20261028-01)
- **CI**:
  - Exactly 3 workflows; `ci.yml` ≤250 lines; one required gate.
  - No `paths:` filters on triggers; actions pinned by SHA; `timeout-minutes` on every job.
  - No phase-numbered workflows or `verify.phaseN` tasks.
  - Build from the bootstrap skill's description, not by copying oarlock's current files (they have a PLT cache-key bug and Node scripts).
  (ADR 0017, INT-20261028-02)
- **Process**:
  - ≤5 plans per phase, about ≤3 days each. Every phase ends in a merged, green PR to main. Push on day 1.
  - No proof-only phases. Review loops are capped at 2.
  - A contract test is never edited in the same PR as the implementation it guards.
  - Clearance is a soak checked at the milestone audit, not a phase.
  (ADR 0021, INT-20261028-02, INT-20261028-03)
- **Honesty**: Report only what a tool or a human actually verified. A check that didn't run is `not-run`, never `pass`. (ADR 0010, INT-20261028-01)
- **Privacy**: No PII in git: no email addresses, no absolute home paths. Fixtures are synthetic. (INT-20261028-01)
- **Vocabulary**: Never call a scenario a "variant" or "variation". Never call the canvas a "sandbox". "Twin" means a fictional organization the UI serves; CI apps are "host apps". (ADR 0023)
- **Code style**: Idiomatic, minimal and self-documenting, with no comments that restate the code. ≤25 public modules at 1.0; everything internal gets `@moduledoc false`. (INT-20261028-01)

## Key Decisions

| Decision | Rationale | Outcome |
|---|---|---|
| Stories are compiled `.ex` modules in `storybook/` (ADR 0001) | No eval surface; manifest available in test; colocated hooks work | — Pending |
| Scenarios are functions; slots are never strings (ADR 0002) | The string round-trip caused the incumbent's root bugs and its CVE | — Pending |
| Iframe canvas through the host's pipeline and root layout (ADR 0003) | Fidelity is the product; it removes CSS and hook isolation problems | — Pending |
| No eval, no atoms from input (ADR 0004) | The design lesson of CVE-2026-8467 | — Pending |
| LiveDashboard-style packaging, zero processes (ADR 0005) | A proven pattern in the owner's own libraries | — Pending |
| Dependency in all envs, with a compile-time prod guard (ADR 0006) | Router macros expand even inside a false `if` | — Pending |
| Floors: Elixir 1.18, Phoenix 1.8.16, LiveView 1.2.9 (ADR 0007) | No legacy; stdlib JSON; the LiveView security floor | — Pending |
| Pure catalog; ids from module and function (ADR 0008) | Same in dev and test; every scenario is addressable | — Pending |
| Manifest yes; MCP and plugin API not in 1.0 (ADR 0009) | Avoids Storybook's addon breakage | — Pending |
| The LLM context bundle is core (ADR 0010) | The owner's main motivation | — Pending |
| phoenix_test_playwright with a reversal trigger (ADR 0011) | One ExUnit runner; both options spiked in phase 1 | — Pending |
| Canon in `design/` as Markdown plus DTCG (ADR 0012) | Interop with abracabrand, impeccable and LLMs; no YAML dependency | — Pending |
| Workbench UX (ADR 0013) | Clearer than Storybook | — Pending |
| Deterministic performance proxies (ADR 0015) | Tail latency on shared runners is noise | — Pending |
| Three workflows, one gate (ADR 0017) | CI bloat was the owner's biggest velocity tax | — Pending |
| Strict by default; Waivers only (ADR 0024) | Shifting best practice left is the point of the product | — Pending |
| Motion is a first-class lane (ADR 0025) | The owner's top UX priority; prior tools leave motion as a blind spot | — Pending |
| Static export in v1.x; render seam now (ADR 0022) | Keeps the 1.0 design uncompromised | — Pending |
| Four tiers Primitive…Screen; "Scenario" (ADR 0023) | One clear question per tier; "variant" collides with `attr :variant` | — Pending |
| Split rule beats "8–12 phases": about 35 sequential phases under the 12 family headings, with research's ordering moves (INT-20261028-16, OPEN-QUESTIONS Q6) | Research found 8 of 12 families exceed the 5-plan cap; the split rule is non-negotiable | — Pending |

## Roadmap constraints (for the roadmapper)

These are ordering and scope constraints, not a fixed structure. They fit `Fine` granularity: 12 phases, each with at most 5 plans and each ending in a merged green PR. **Split any phase that would need more than 5 plans; never compress one.**

1. **Walking skeleton**
   - Bootstrap via the skill and publish 0.1.0.
   - CI with the gate and the caps test.
   - Intent files plus `intent_test`.
   - Router macro with the prod guard.
   - One compiled story rendering in `hosts/vanilla`, plus a skeleton `hosts/operator` (nested mount, strict CSP, self-hosted fonts).
   - One LiveViewTest, and one visual check with the baseline guards.
   - **Runner spike** against the ADR 0011 criteria.
2. **Story model and catalog**
   - `use Fablebook.Story`, scenario metadata (citation *shape* only), one story per component, subject-kind rules.
   - Catalog and ids; the `ComponentInfo` adapter with its contract test; Unstoried; manifest plus drift check.
   - Render seam with `render: :live | :static`.
   - The rules engine: strict by default, Waivers, Draft.
   - PERF-01.
3. **Controls and URL state**
   - Casting, presets, overrides, URL codec.
   - Never-eval and never-atom properties, Credo bans, mutation-proven security tests.
4. **Canvas fidelity**
   - Iframe through the host layout, signed topic, event log, crash containment, CSP nonces, connection diagnostic, hot reload.
   - Static (controller-rendered) canvas.
   - Globals, including device frames and motion modes.
   - Complete `hosts/operator` and its E2E fidelity spec.
5. **Workbench UX**
   - Chrome tokens and CSS; grid with the story page as docs; inspector; ⌘K; keyboard map; toolbar tools.
   - **Compare** mode; **To review** page; Mobile layout; microcopy; chrome a11y; Diagnostics.
6. **Design canon**
   - Frontmatter parser; `design/` kinds; brand → product **canon layers**, including a brand canon from a dependency.
   - DTCG and the resolver; abracabrand read; **Themes** and guardrails; **Directions**.
   - Foundations pages; citation *existence* checks and persona/job enforcement.
   - Lints, contrast matrix, coverage and waivers; **journeys** declared in job files; DESIGN.md generation; `mix fablebook.tokens`; page embeds.
   - Brand books built through the two-session abracabrand process: Fablebook's own, plus the first three twins (Logistify family, Chatly, Clinicly).
7. **Probe, checks and visual regression**
   - Probe plus Evidence schema, Checks tab, simulations.
   - Forced interaction states and the UX checks (forms, layout shift, RTL/locale formatting, destructive dialogs, copy benchmarks).
   - **Journey step checks** (dead end, copy drift).
   - Sweep; visual-core on PRs, the full set nightly and on release; determinism self-test.
   - Verdicts log; `Fablebook.Testing`.
8. **Motion lane**
   - Starts with a spike: the time shim and filmstrip seeking against real LiveView JS transitions.
   - Motion panel (timeline, slow motion, filmstrip), motion tokens and checks, LiveView motion lints, `motion_tier`.
   - Reduced-motion variant; baselined filmstrips in CI.
9. **LLM context bundles and skills**
   - Both tiers; allocator and contact sheets; every **focus** (explore, critique, copy, a11y, layout, consistency, brand, compare, journey, motion).
   - Copy for LLM; JSON Schema and goldens; redaction; `llms.txt`.
   - `mix fablebook.gen.screens`; Fablebook's own skills and upstream-skill hints.
10. **Installer and DX**
    - Igniter install (including the reduced-motion variant), gen.story, doctor, skills install, the phoenix_storybook migrator.
    - Export image and `mix fablebook.shot`; the hardcoded-string Credo check.
    - Docker demo; the 12 guides; the generator-emitted story convention.
11. **Hardening and the full twin set**
    - Telemetry catalogue, `bench/`, Muex floors, leak test, sobelow on the host app, SBOM, API-surface snapshot, a regression test per footgun.
    - Finanza and Shopadelic (branded admin plus the white-label storefront).
12. **Dogfood setup:** upgrade the mailglass demo and accrue_admin to LiveView 1.2 and migrate them (sigra's generator-emitted stories next).

**Then the clearance soak.** CLEARANCE C1–C10, including the 14-day criteria, is checked by the milestone audit before 1.0 is tagged.

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-10-28 after research (INT-20261028-16: phase split, four research REQs added)*
