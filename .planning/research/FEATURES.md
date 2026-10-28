# Feature Research

**Domain:** Component workbench and design-system catalog for Phoenix LiveView (Fablebook)
**Researched:** 2026-10-28
**Confidence:** MEDIUM overall. Mapping of REQ ids, ADRs and intent is HIGH (read directly from the repo). Competitor feature claims are MEDIUM at best (see Evidence legend).

**Evidence legend**
- **[F]** fetched from official documentation during this research pass.
- **[R]** taken from the repo's own dated research (`docs/research/LESSONS-LEARNED.md`, `UX-DESIGN.md`, `MOTION-AND-UX-DIMENSIONS.md`, `LLM-CONTEXT-AND-CANON.md`).
- **[K]** recalled from prior knowledge and not re-verified. Re-check before it drives a requirement.
- The research-plan seam classifies every web provider as LOW. Nothing below rests on one competitor claim alone, and each proposed requirement also cites an internal reason.

**Vocabulary note.** Other tools use words that Fablebook forbids. They appear only here, once: Storybook "story" = one state; Histoire "variant" and phoenix_storybook "Variation" = one state; React Cosmos "fixture" = one state; Widgetbook "use case" = one state and "knob" = a control; Lookbook "scenario" = one state. Everywhere else this file uses GLOSSARY words: Scenario, Control, Canvas, Workbench, Globals, Rendition.

---

## 1. Sanity-check verdict

PROJECT.md (127 REQs) is a strong, coherent superset of what the field ships. Against 32 table-stakes capabilities found across Storybook 9-10, Ladle, Histoire, Lookbook, React Cosmos, Widgetbook and phoenix_storybook:

| Status | Count | Meaning |
|---|---|---|
| Covered | 25 | At least one REQ delivers it |
| Partial | 5 | Delivered, but a specific detail is missing or unspecified (section 5) |
| Deferred on purpose | 1 | Static export (ADR 0022, v1.x) |
| Not applicable by design | 1 | Mocking collaborators (function components take data) |

No listed REQ is a true anti-feature: nothing should be deleted. Nine REQs carry a noise, feasibility, consistency or schedule risk (section 6). Those need tightening, and each tightening that touches owner-approved wording goes to `OPEN-QUESTIONS.md`, not a silent edit.

**The three findings that matter most for the roadmap**
1. **No requirement says how the host's dark mode and Theme are applied** (class, `data-theme` attribute, or `prefers-color-scheme` media query). Color scheme and Theme are Globals and the heart of the fidelity promise, so this is the largest table-stakes hole. Proposed `CTRL-05`.
2. **The owner's #1 motivation (LLM bundles) lands in phase 9 of 12.** The Core Value says a scenario must "export an accurate context bundle" even if everything else fails. A thin no-browser slice of LLM-01/02 can ship straight after the render seam exists (phase 2). See section 9.
3. **Check status in the sidebar and on tiles has no stated data source**, yet Storybook 9's test widget made this a table-stakes expectation. Without a source, the dots would either lie or need a full sweep on every load. Proposed `WB-17`.

---

## 2. Feature Landscape

### Table Stakes (users expect these)

Status key: **Covered** · **Partial** (gap named, proposed REQ in section 5) · **Deferred** · **N/A**.

| # | Feature | Seen in | Complexity | Fablebook REQ ids | Status |
|---|---------|---------|------------|-------------------|--------|
| TS-01 | Tree navigation with search and filter | All seven [F][R] | MEDIUM | CORE-06, WB-03 | Covered |
| TS-02 | Several named states per component, each with a stable address | All seven [F][R] | MEDIUM | CORE-01, CORE-02, CORE-03, CORE-04 | Covered |
| TS-03 | Faithful render in the app's real CSS, fonts and JS | Storybook and Lookbook render in an iframe through the host's layout [R]; phoenix_storybook renders inline and fails here (issues #494, #615, #284) [R] | HIGH | CANVAS-01, CANVAS-05, CANVAS-02 | Covered. Table stakes for Lookbook-class tools, differentiating only against phoenix_storybook |
| TS-04 | All states of one component on one screen | Histoire grid of every state [F], Storybook docs page [F], phoenix_storybook groups [F], Lookbook "several examples in one window" ask [R] | MEDIUM | WB-02, CANVAS-02, CORE-03 (`group:`) | Covered |
| TS-05 | Typed controls from declared component metadata, with reset | Storybook, Histoire, Cosmos, Widgetbook, Lookbook, phoenix_storybook [F][R] | MEDIUM | CTRL-01, CTRL-02 | Covered |
| TS-06 | Generated attr and slot reference | Storybook autodocs [F], phoenix_storybook [F], Lookbook [R] | LOW-MEDIUM | WB-02, LLM-06 | Covered. Docs come from `attr`/`slot`, so they cannot drift |
| TS-07 | Event log for callbacks | Storybook Actions [F], phoenix_storybook event log [R] | LOW-MEDIUM | CANVAS-04, WB-05 (Events tab) | Covered. Payloads are truncated; pick the cap deliberately because the payload is the log's value |
| TS-08 | Viewport presets, fill and custom width | Storybook, Histoire, Cosmos, Widgetbook [F]; Lookbook top ask [R] | LOW | WB-06, CTRL-03 (`vw`) | **Partial**: width only, no height or orientation. Proposed `WB-18` |
| TS-09 | Color scheme and Theme switching in the Canvas, separate from the workbench's own look | Storybook, Ladle, Histoire, Widgetbook, phoenix_storybook [F][R]; Lookbook top ask [R] | MEDIUM | CTRL-04, WB-06, WB-08, CANON-10 | **Partial**: mechanism unspecified. Proposed `CTRL-05` |
| TS-10 | Backgrounds, including a checkerboard for transparent subjects | Storybook, Histoire [F] | LOW | WB-06 | Covered |
| TS-11 | Outline, measure, zoom | Storybook "Measure & outline" [F], Widgetbook zoom, grid and inspector addons [F] | LOW-MEDIUM | WB-06 | Covered. Grid overlay not specified (P3, section 5) |
| TS-12 | Locale and RTL | Storybook globals [K], Ladle RTL [R], Widgetbook localization [F] | MEDIUM | CTRL-04, CHECK-03, UX-04, UX-07 | Covered |
| TS-13 | Copy-ready code and a source link | Storybook, phoenix_storybook source tab with permalinks [F], Lookbook source panel [F] | LOW | WB-05 (HEEx tab), WB-11 | Covered. Repo permalink waits for v1.x with export |
| TS-14 | URL carries all state, so a reload or a shared link reproduces it | Ladle "all state in the URL" [R], Storybook URL args [K] | MEDIUM | CTRL-03, WB-07, CHECK-02 | Covered |
| TS-15 | Live reload on code change | All seven | MEDIUM | CANVAS-06 | Covered. Canon edits are covered by the installer's live_reload patterns (INST-01) |
| TS-16 | Keyboard shortcuts | Storybook since 5.0 [R], Ladle [R] | LOW-MEDIUM | WB-04, A11Y-01 | Covered |
| TS-17 | Prose pages that embed live examples | Storybook MDX [F], Histoire markdown [F], Lookbook pages [F], phoenix_storybook page kind [F] | MEDIUM | CORE-11, CANON-04 | Covered |
| TS-18 | Automated accessibility checks | Storybook a11y addon on axe-core [F], Widgetbook semantics [F] | MEDIUM | CHECK-01, CHECK-02, CHECK-03, A11Y-01, A11Y-02 | Covered, and ahead (axe "incomplete" counts as a finding) |
| TS-19 | Visual regression | Storybook with Chromatic [F], Histoire with Percy and Lost Pixel [F], Widgetbook Cloud goldens [F] | HIGH | VIS-01, VIS-02, VIS-03, CHECK-04 | Covered, with a stricter baseline rule than any of them |
| TS-20 | Scenarios double as tests | Storybook 9 Vitest addon [F] | MEDIUM | CHECK-05, QA-01, QA-03 | Covered. See the free-coverage note in section 5 |
| TS-21 | Check status in the sidebar and one click to run checks | Storybook 9 test widget with sidebar status indicators and watch mode [F] | MEDIUM | WB-02 (tile status), WB-05 (Checks tab), CHECK-02, LLM-05 | **Partial**: no stated source for the dots. Proposed `WB-17` |
| TS-22 | A way to exercise interaction | Storybook `play` functions and the Interactions panel [F] | HIGH | CHECK-05 (`mount_scenario/2` via `live_isolated`), CANVAS-04 | **Partial, deliberately** (no recorder, ADR 0013). Needs a documented path (section 5, G4) |
| TS-23 | A shareable or deployable catalog with no dev server | Storybook, Ladle, Histoire, Cosmos [F]; Lookbook top ask "deployability" [R] | HIGH | CORE-09 (render seam now), ADR 0022 (export v1.x) | **Deferred** (owner-approved, INT-20261028-05). Persona 6 (reviewer) is the casualty; see interim in section 5, G8 |
| TS-24 | Zero-config start and auto-discovery | Ladle "batteries included" [R], Cosmos file convention [F], Widgetbook codegen [R] | MEDIUM | CORE-05, INST-01, INST-05 | Covered |
| TS-25 | A broken component does not take down the workbench | Storybook error display [K] | LOW-MEDIUM | CANVAS-03, WB-10 | Covered |
| TS-26 | Install, upgrade and migration tooling | phoenix_storybook Igniter installer [F]; Storybook upgrade command and codemods [K] | MEDIUM | INST-01, INST-03, INST-04, DOCS-03 | Covered |
| TS-27 | Open in editor | Storybook 10 [F], phoenix_storybook 1.4 [R] | LOW | WB-11 | Covered |
| TS-28 | Agent-readable catalog | Storybook 10.3+ component manifests and MCP (early access) [F]; phoenix_storybook #715 ask [R] | MEDIUM | LLM-06, LLM-01, SKILL-01 | Covered. MCP deferred (ADR 0009, OPEN-QUESTIONS Q5) |
| TS-29 | Never ships to production by accident | phoenix_storybook #311 (stories fail in prod) [R] | LOW | SEC-02, COMPAT-01 | Covered |
| TS-30 | Wrapping containers and placement | Storybook decorators [K], Cosmos decorators [F], Lookbook display params [F], Widgetbook alignment addon [F] | LOW | CORE-10 | Covered |
| TS-31 | Mocking a story's collaborators | Storybook `sb.mock` [F], Widgetbook mocking [F] | n/a | CORE-02 (data in), CORE-07 (presentational subjects) | **N/A by design**: function components take data, and Fixtures are built without a database. LiveComponent subjects that reach into PubSub or the database are the exception (pitfall, not a feature) |
| TS-32 | Filter by tag or status | Storybook tags, with tag exclusion in 10 [F]; Lookbook tags [F] | LOW | CORE-03 (`tags:`), LLM-01 (tag selector), WB-14 | **Partial**: tags select bundles but do not filter the sidebar. Amend `WB-03` |

### Differentiators (competitive advantage)

Aligned with the Core Value. "Closest rival" shows the nearest thing the field ships, so the claim stays honest.

| Feature | Value Proposition | Complexity | REQ ids | Closest rival |
|---------|-------------------|------------|---------|---------------|
| LLM context bundles with budget allocator, focuses, redaction and goldens | Owner's core motivation: screenshots, ARIA, measurements and cited canon in one deterministic package | HIGH | LLM-01 to LLM-08, SEC-04 | Storybook 10.3 manifests and MCP carry props, snippets and docs only; no screenshots, ARIA, measurements or canon [F] |
| Design canon as content (terms, voice, personas, jobs, twins, imagery, DTCG tokens) with Citations from Scenarios | The catalog explains why a state exists and who it serves | HIGH | CANON-01 to CANON-12, CORE-03, CANON-08 | None. Lookbook and Storybook pages hold prose but no checked links |
| Four Tiers up to Screens, with the Shell as an Area | One question per tier; whole screens are first-class | MEDIUM | CORE-06, CORE-07 | Pattern Lab and Fractal had a pages level [R]; no modern workbench has tier semantics |
| Scenario = named Situation with Citations, State classes, Coverage and Gaps | Surfaces missing states instead of listing whatever the author wrote | MEDIUM | CORE-03, CORE-08, CORE-12 | None. Widgetbook and Histoire list states but never report absent ones |
| Strict by default with reasoned Waivers and a Ratchet | Shifts best practice left; the incumbent's lenient posture is what the owner is leaving | MEDIUM | CORE-12, CORE-13, CHECK-04, CHECK-06 | None. Storybook tests are opt-in |
| Motion lane: scrub, slow motion, filmstrip, token and LiveView JS lints, baselined filmstrips | The owner's "HUGEly important" blind spot | HIGH | MOTION-01 to MOTION-07 | Widgetbook time dilation (slows only) [F]; Chromatic pauses at the end state [R] |
| Journeys with Step checks (dead end, copy drift) | Transitions between screens get reviewed, not just screens | MEDIUM | JOURNEY-01 to JOURNEY-03 | None |
| Compare along exactly one axis at any tier, plus Directions and Themes | Refresh, white-label and greenfield exploration without a design tool | MEDIUM | WB-13, CANON-10, CANON-11 | Chromatic branch compare (hosted, per-story) [K] |
| The Checks tab equals CI, with reproducible "Copy finding link" | One probe, one Evidence schema, no "works in the panel, fails in CI" | MEDIUM | CHECK-01, CHECK-02 | None |
| Render mode `:live` or `:static` | Shows a dead view exactly as production serves it; unique to Phoenix | MEDIUM | CORE-14, CORE-09 | None |
| Forced interaction states plus form, focus, layout-shift, RTL and destructive-dialog checks | The long tail of UX defects found mechanically | HIGH (as a group) | UX-01 to UX-08 | Community pseudo-state addons for Storybook [K] |
| Review queue ("To review"), Verdicts log, no pop-ups | Curation without nagging | LOW-MEDIUM | WB-14, CHECK-06 | None |
| Device frames (generic) with safe areas and PWA display, and framed image export | Reviewing and sharing mobile states; marketing collateral | MEDIUM | WB-15, WB-16 | Widgetbook device frames (being replaced by its viewport addon) [F] |
| Mobile layout of the workbench and QR "Show on phone" | Solo developer reviews on their own phone | MEDIUM | WB-07 | Storybook 10 added a QR share [F] |
| Generator-emitted stories convention | Libraries that generate UI into a host ship its stories too | LOW-MEDIUM | INST-07 | None |
| Twins and the Sample data filter, five showcase products | Stress-tests against real-world variety; doubles as the public demo | HIGH (cost) | CORE-03, QA-06 | None |
| phoenix_storybook migrator | Adoption wedge and the owner's own tool | MEDIUM | INST-04 | None |
| Security by construction (no eval, no new atoms, CSP, prod guard) | Direct answer to CVE-2026-8467 | MEDIUM | SEC-01 to SEC-05 | None |

### Anti-Features (commonly requested, often problematic)

**A. Market-wide traps and Fablebook's stance**

| Feature | Why Requested | Why Problematic | Fablebook stance |
|---------|---------------|-----------------|------------------|
| Addon or plugin marketplace | Extensibility | Storybook addons break on upgrade [R] | Out of Scope; internal `Fablebook.Panel` stays private (ADR 0009) |
| Inline (non-iframe) rendering | Simpler, faster | The incumbent's CSS and hook root cause [R] | Out of Scope (ADR 0003) |
| Code-eval playground | Edit anything live | CVE-2026-8467 [R] | SEC-01, ADR 0004 |
| MDX-style docs format | Rich docs | A second authoring format that drifts | Out of Scope; Markdown and HEEx Pages (ADR 0013) |
| Save control edits back to the story file | Storybook shipped "save from controls", which writes args into the story file and can clone a story [F] | A browser-to-disk write surface, "risk close to eval" (ADR 0004) | Out of Scope. Safe alternative proposed as `CTRL-06` (copy as text, never write) |
| Auto-permutation or control-combination grids | Cheap coverage | Scenarios become permutations, not Situations (INT-20261028-04) | Out of Scope. See flagged `INST-02` in section 6 |
| Lenient defaults or a global off switch | Easy adoption | Opt-in rules never get switched on (ADR 0024) | CORE-12 |
| Hosted visual-regression service or auto-accepted baselines | Convenience | Baselines become whatever shipped last | Out of Scope; VIS-02 |
| Comments and collaboration in the workbench | Review in one place | A second review system beside the PR | Out of Scope (ADR 0013) |
| Figma or Sketch sync | Designer hand-off | The audience is solo developers who replace Figma | Out of Scope (INT-20261028-10) |
| White-labelling the workbench | Branding | No payoff for this audience | Out of Scope (INT-20261028-01) |
| Video as review evidence | Shows motion | Not deterministic, and LLMs cannot read it | Out of Scope; Filmstrips (ADR 0025) |
| Interaction recorder and replay | Cheap interaction tests | Brittle, and needs a LiveSocket | Out of Scope (ADR 0013); replay deferred to v2 |
| Prod-mounted workbench | Lookbook's "deployed-environment" ask [R] | Auth and exposure surface | Deferred to v2; static export is the v1.x answer (ADR 0006) |
| Native iOS or Android renders | Mobile teams | Not rendered by Phoenix | Out of Scope (INT-20261028-10, INT-20261028-11) |

**B. Anti-features this research proposes adding to Out of Scope** (each is a one-line addition to PROJECT.md; none conflicts with intent)

| Feature | Why Requested | Why Problematic | Proposed stance |
|---------|---------------|-----------------|-----------------|
| Usage telemetry that phones home | Maintainers want adoption numbers | Storybook collects anonymous usage data by default and users must opt out [F]. Conflicts with the privacy stance and the "Fablebook never attaches handlers" rule (TEL-02) | Out of Scope: Fablebook sends nothing anywhere. Add a clean-room test that the tarball opens no outbound connection |
| Markup snapshot assertions in generated tests | Storybook ships snapshot tests [F] | Brittle, and the review burden returns | `generate_tests` (CHECK-05) never asserts markup. Goldens are for bundles and manifests only |
| A free-form `parameters` bag | Storybook's per-story config [K] | Config sprawl [R]; every option becomes unlinted surface | Globals stay a closed set (CTRL-04); Book options go through `nimble_options` |

**C. Listed requirements that carry anti-feature risk** are in section 6.

---

## 3. Feature Dependencies

```
CORE-09 render seam
    +--requires--> CORE-02 scenario functions
    +--enables---> CORE-14 static render mode
    +--enables---> CHECK-05 generated tests
    +--enables---> LLM-04 no-browser capture --> LLM-01/02 bundles (thin slice)
    +--enables---> WB-16 export image (browser) and v1.x static export

CANVAS-01 iframe through the host pipeline
    +--requires--> CANVAS-04 signed topic, CANVAS-05 diagnostic
    +--enables---> every visual feature: CTRL-04 globals, WB-06 tools, WB-15 frames,
                   CHECK-01 probe, VIS-01 baselines, MOTION-01 panel

CTRL-04 globals --requires--> CTRL-05 host scheme/theme strategy (proposed)
    +--feeds--> CANON-10 themes, CANON-11 directions, WB-13 compare, VIS-01 renditions

CTRL-03 URL state
    +--enables--> WB-13 compare, CHECK-02 finding links, WB-16 shots, CHECK-04 sweep
                  (a Rendition is a URL)

CANON-01 frontmatter parser
    +--requires--> CANON-02 entry kinds --> CORE-03 citation existence --> CANON-08 intent coverage
    +--enables---> JOURNEY-01 (journeys live in job files), CORE-13 gen.screens, LLM-02 context/
    CANON-03 DTCG tokens --> MOTION-02 motion tokens, CANON-07 lints, CANON-06 DESIGN.md

CHECK-01 probe + Evidence schema
    +--enables--> CHECK-02, CHECK-04, UX-01..UX-08, MOTION-03, JOURNEY-02, LLM-04 --browser
    CHECK-04 sweep --requires--> VIS-01 capture pipeline (LLM-04 reuses it)
    LLM-05 evidence keyed by render hash --requires--> CHECK-01
    WB-17 check status (proposed) --requires--> LLM-05 + CHECK-02

MOTION-01 time shim --requires--> a spike against real LiveView JS transitions
    +--enables--> MOTION-06 baselined filmstrips, MOTION-07 motion focus
    MOTION-04 LiveView lints --requires--> render: :live (static cannot exercise streams)

LLM-08 focuses --require--> their lanes: compare (WB-13), journey (JOURNEY), motion (MOTION-07),
                            brand and consistency (CANON), copy (CANON-07, UX-06)
```

### Dependency Notes

- **CTRL-05 must precede the operator host fidelity spec.** Dark-mode fidelity cannot be asserted until the strategy is known. It also gates VIS-01: if the host uses a media query, the only way to render dark is browser emulation, so the interactive toggle must say so.
- **`render: :static` conflicts with interactive checks.** UX-08 (focus survives a patch), UX-02 (touched-field behavior) and MOTION-04 (`stream_delete`) need a LiveSocket. CORE-14 already flags `phx-*` in static stories; the checks must mark themselves `not-run` there, never `pass` (Honesty constraint).
- **CORE-08 coverage precedes the Review queue.** WB-14 lists coverage gaps, so the coverage computation must exist first.
- **QA-06 twins depend on abracabrand**, which the owner says is "not fully developed". The Logistify, Chatly and Clinicly brand books gate the design-canon phase's exit; Finanza and Shopadelic gate 1.0. Plan a fallback (hand-authored minimal tokens) so the phase can still merge.
- **MOTION-01 conflicts with ADR 0003's "Fablebook injects no JS into the canvas except the opt-in probe."** The time shim patches `setTimeout`, `performance.now` and `requestAnimationFrame`. Treat the shim, scrubber, Outline and Measure as part of the opt-in probe, loaded only when needed, with a visible "Time shim active" label because it changes timing behavior. Fold this into ADR 0003 or ADR 0025 rather than leaving the contradiction.

---

## 4. Mapping the field to REQ ids (what each tool contributes)

| Tool | What to take (and where it lands) | What to leave |
|------|-----------------------------------|---------------|
| **Storybook 9-10** | Stories as tests (CHECK-05, VIS); test status in the sidebar (WB-17); tags with exclusion (WB-03 amendment); QR share and open-in-editor (WB-07, WB-11); manifests (LLM-06). Telemetry, `parameters`, MDX and addons are the traps. | Addon API, MDX, telemetry, save-to-disk |
| **Ladle** | Zero config, instant start, all state in the URL, `meta.json` export, 16k-story scale (CTRL-03, LLM-06, PERF-01) [R] | React only |
| **Histoire** | The grid of every state (WB-02), checkerboard backgrounds (WB-06), fuzzy search (WB-03) | Small ecosystem |
| **Lookbook** | Closest analog: iframe through the host layout (CANVAS-01), typed params (CTRL-01), pages and embeds (CORE-11), JSON endpoints (LLM-06). Its top asks (theme switcher, viewport presets, several examples per window, deployability) map to CTRL-04, WB-06, WB-02 and the deferred export. | Stringly-typed annotations in comments |
| **React Cosmos** | The render seam decoupled from the shell (CORE-09), decorators (CORE-10), static export (v1.x) | Plugin system |
| **Widgetbook** | Time dilation (MOTION-01), text scale (CHECK-03), grid overlay and inspector (P3), device frames (WB-15). Lesson: visual tests need fixed named states, not control combinations. | Hosted Cloud review |
| **phoenix_storybook** | Source permalinks (v1.x), Igniter installer (INST-01), the migration path (INST-04). Every footgun in CLEARANCE C2 is a regression test (QA-05). | Inline rendering, string slots, playground eval |

---

## 5. Gaps: table stakes and workflow holes missing from PROJECT.md

Each item is a proposal. Anything marked **OQ** touches owner-approved wording and needs an `OPEN-QUESTIONS.md` entry before it changes PROJECT.md or an ADR.

| ID (proposed) | Gap | Evidence | Complexity | Priority | Lands in phase | OQ? |
|---|---|---|---|---|---|---|
| **CTRL-05** | **Host scheme and Theme strategy.** A Book setting declares how the host applies dark mode and a named Theme: a class on the root (`{:class, "dark"}`), a data attribute (`{:data_attr, "data-theme", values}`), or `:media`. The installer proposes a value by reading the root layout. Under `:media`, JavaScript cannot set `prefers-color-scheme` inside the Canvas, so the toolbar tool says so in plain words and only the browser runner emulates it. The doctor checks the configured strategy actually flips the Canvas. | CTRL-04 lists color scheme and Theme but defines no mechanism (grep of PROJECT.md, ADRs, UX-DESIGN). phoenix_storybook needed a CSS isolation class option plus a theme assign [F]; Storybook ships theme decorators [K]. The same iframe limit is already documented for reduced motion [R]. STACK-FACTS records daisyUI as the Phoenix generator default but not the toggle mechanism; verify the `data-theme` convention against a fresh `phx.new` during phase 4 planning [K]. | MEDIUM | **P1** | 4 (Globals); installer part in 10 | No (needs a small ADR 0002 amendment) |
| **WB-17** | **Check status provenance and a run action.** Sidebar dots and tile status read the latest Evidence keyed by render hash (LLM-05) and show "Not run" until Evidence exists, never a green dot. A "Run checks" action runs the probe for the open Rendition (CHECK-02) and, at story level, across the width presets in the user's own browser (no Node). | Storybook 9 test widget with sidebar indicators is the current baseline [F]. UX-DESIGN promises a check dot with a text equivalent, but no REQ names its source. Honesty constraint: a check that did not run is `not-run`. | MEDIUM | **P1** | 5 (dots from stored Evidence); 7 (run action) | No |
| **WB-18** | **Viewport height and orientation.** Width presets get a height (device frames already imply one, "375 x 812") and a rotate action; add `orient` to the URL table. Persist workbench settings (Appearance, density, single-key shortcut switch, pane sizes) and list them in WB-08/WB-09. | Storybook viewport rotates [K]; Widgetbook devices have orientation [K]. Screens using `100dvh`, bottom sheets and the Shell cannot be judged by width alone. WB-04 already implies a persisted shortcut switch. | LOW | P2 | 4 / 5 | No |
| **CTRL-06** | **Copy override as scenario.** When a Control is edited, offer "Copy as scenario": Elixir text for a new scenario function with the overridden attrs, `desc:` set to a TODO, marked Draft. Values print from typed controls only; no atoms are created; nothing is written to disk. | Storybook's save-from-controls is among its best-loved workflow loops [F]; Fablebook rules out the disk write (ADR 0004) and has no replacement. UX-DESIGN already has a "Copy scenario template" action for empty stories. | LOW-MEDIUM | P2 | 3 (with Controls) | No (stays inside the "never write to disk" line) |
| **CORE-08 amendment** | **Expected State classes per Tier.** Default the set of State classes each Tier is expected to cover (for example a Primitive is not expected to have `denied` or `stale`) so Gaps are meaningful and the Waiver count is not noise. Anything outside the default is reported only when declared. | CORE-08 as written crosses every story with all 12 classes. Fourteen CoreComponents x 12 classes is a wall of Gaps. ADR 0024 already makes Gaps a warning, but "Waivers are counted" turns noise into waiver fatigue. Design inference [K]; test against the first dogfood Book. | LOW | P2 | 6 | **Yes** (alters INT-20261028-04's coverage reading) |
| **VIS-02 amendment** | **Selective baseline accept.** `bin/visual update` requires scenario ids or `--all`, prints the list of changed Renditions first, and CI uploads actual, expected and diff images for each failure. Committed baselines also render as image diffs in the pull request. | ADR 0011 shows the auto-accept footgun in `assert_screenshot`; a blanket update flag is the same footgun by hand [R][K]. | LOW | P2 | 1 / 7 | No (tightens an existing rule) |
| **WB-03 amendment** | **Sidebar filters.** Filter by Tier, State class, tag, Draft, "has findings" and "has Waiver", in addition to `/` text. | Storybook tag filtering and exclusion [F]; Lookbook tags [F]. Tags already exist in CORE-03 but cannot narrow the sidebar. | LOW | P3 | 5 | No |
| **DOCS-01 amendment (G4)** | **Interaction path.** Guide 4 documents the harness pattern (a small LiveComponent defined in the story file wrapped by an arity-1 scenario, so server-side events work in the Playground). Guide 7 documents driving a scenario with `mount_scenario/2` and PhoenixTest. The Events tab's "No handler" row links to the harness guide. | Storybook 9's headline is interaction testing [F]. Fablebook rules out a recorder (ADR 0013) and has no `play` equivalent. LiveComponents and `JS` commands already work; only server-driven function-component state does not. No new API: ADR 0002 already allows `<.live_component>` inside a template. | LOW | P1 (docs) | 10 | No |
| **DOCS-01 additions** | Two free wins: (1) `mix test --cover` over generated tests gives per-component code coverage from Scenarios, matching Storybook 9's coverage [F]; (2) an "Icons" Foundations recipe built from a Page with embeds (phoenix_storybook ships icon-library support [F]; Phoenix 1.8 apps ship heroicons). | Both need no new code. | LOW | P3 | 10 | No |
| **TS-23 interim (G8)** | **Reviewer path before static export.** The sweep (CHECK-04) publishes contact sheets as CI artifacts, and `mix fablebook.shot` output (WB-16) is the documented way to show a state to a reviewer. Export stays first on the v1.x list. | Persona 6 needs "a link that opens exactly the state under review on my phone"; QR works only on a reachable LAN (OPEN-QUESTIONS Q4). Lookbook's #1 ask is deployability [R]. | LOW | P2 | 7 | No |
| **OOS additions** | The three Anti-feature rows in section 2.B. | See section 2.B. | LOW | P2 | 1 (add now) | No (adds to Out of Scope; none contradicts intent) |
| Source permalink, grid overlay, "inspect element token" | Repo permalink from a Scenario to the hosting forge; a layout-grid overlay; click-to-inspect showing the resolved token | phoenix_storybook `source_permalink_base_url` [F]; Widgetbook grid and inspector addons [F] | LOW to MEDIUM | P3 | v1.x | No |

**Ideas considered and rejected** (insufficient evidence or against intent): "Used in" graph from Primitive to Screens (high cost; Compare and the Areas tier already give the view); hidden Scenarios (Lookbook `@hidden`; against "every Scenario is a real Situation", and Draft covers work in progress); Storybook-style composition of several catalogs (Books share canon, CANON-12 spans repos); a deprecation badge (Phoenix `attr` has no deprecated option [K]; revisit on request).

---

## 6. Listed requirements that look risky, with a recommendation

None should be removed. "OQ" means the fix alters owner-approved wording or an ADR table, so it needs an `OPEN-QUESTIONS.md` entry first.

| REQ | Concern | Evidence | Recommendation | OQ? |
|---|---|---|---|---|
| **UX-06** reading grade per persona and sentence length | Readability formulas are built for passages of about 100 words; on 2 to 12 word button, label and error strings they are noise. A noisy rule teaches users to ignore all rules. | Readability-formula design [K]; the ux-writing benchmarks are targets for prose, not per-string metrics [R] | Keep button word count, title and error length, and generic-label checks. Apply reading grade only to strings of at least 25 words (Pages, long help text). Stays a warning as in ADR 0024 | Yes (narrows the REQ) |
| **UX-05** confirmshaming lint (glossary-based) | Natural-language heuristic with false positives, listed as **error** in ADR 0024's table | Heuristic lint [K] | Ship the structural half (cancel not weaker than confirm) as an error; ship confirmshaming as a warning until false-positive rate is measured on the twins | Yes (ADR 0024 table row) |
| **UX-07** hardcoded-string Credo check | Reading literal text out of `~H` needs a HEEx tokenizer. The constraints ban floki and permit public LiveView APIs only (ADR 0007); the tokenizer Phoenix uses internally is likely not public [K]. | ADR 0007, ADR 0018 | Spike first. Fallback that stays inside public APIs: render the Scenario under two Gettext locales and flag text nodes that do not change when a translation exists. Keep it optional and waivable as written | No (REQ already optional); note in phase 10 research |
| **INST-02** `gen.story` (ADR 0019: "one scenario per `values:` member") | One Scenario per `values:` member is single-axis permutation. It conflicts with "Scenarios are equivalence classes for real situations" and with the strict rules (a generated `desc` is not a Situation; two Scenarios must not render identically). | INT-20261028-04; ADR 0024 | Generated Scenarios are marked Draft with a TODO `desc`, so they warn in To review rather than failing strict rules, and the generator prints that they need a Situation | Yes (ADR 0019 wording) |
| **WB-07** QR "Show on phone" | Phoenix dev servers bind to localhost, so the default state is a refusal message. Cheap to build, easy to over-invest in. | OPEN-QUESTIONS Q4; UX-DESIGN canonical string for "QR unavailable" | Keep, minimal: QR when reachable, honest text otherwise. No extra network logic. Never bind to the LAN for the user | No |
| **CANON-06** DESIGN.md and `.impeccable/design.json` generation | Couples a stable product to an alpha spec (google design.md) and a private schema (impeccable `design.json` v2) | LLM-CONTEXT-AND-CANON [R] | Ship DESIGN.md first behind a spec-version stamp in the ownership header; add `.impeccable/design.json` only when impeccable publishes the schema or a test pins it. Refusal-to-overwrite stays | No (sequencing inside phase 6) |
| **MOTION-01** time shim vs ADR 0003 | See section 3 dependency note: contradicts "no JS injected except the probe" unless the shim is declared part of it, and changes timing fidelity while active | ADR 0003, ADR 0025 | Amend ADR 0003 wording; visible "Time shim active" label; shim loads only while the Motion panel is open. Keep the phase 8 spike as written | Yes (ADR wording) |
| **QA-06** five twins with abracabrand brand books | Schedule coupling to a library still in development and to a two-session process | INT-20261028-08, INT-20261028-11; TWINS.md | Keep scope. Add a fallback so the design-canon phase can merge with hand-authored minimal tokens if a brand book slips, and keep Finanza and Shopadelic last | No |
| **CORE-08** coverage matrix | See the amendment in section 5: wall-of-Gaps and waiver fatigue | ADR 0024 | Per-Tier expected State classes | Yes |

Non-user-facing scope for context only: PERF-06 (`bench/`) and QA-02 (Muex) are internal quality work. Neither is a feature; keep them behind every user-visible phase.

---

## 7. MVP Definition

The owner approved all 127 REQs for 1.0, so "MVP" here means the order in which value must become visible, inside PROJECT.md's roadmap constraints.

### Launch with (the walking skeleton, phases 1-4)

- [ ] Fidelity Canvas (CANVAS-01, -03, -05, -06): the product is "renders exactly as production".
- [ ] Story model and zero-file catalog (CORE-01 to CORE-07 minus citation existence, CORE-05, CORE-09): day-0 aha for Persona 1.
- [ ] Controls and URL state (CTRL-01 to CTRL-04, plus proposed CTRL-05, CTRL-06): Persona 1 and 3's daily loop.
- [ ] Width, color scheme, theme (WB-06 core): fidelity claim needs dark mode working.
- [ ] A thin LLM slice: `mix fablebook.bundle <scenario>` and Copy for LLM with no-browser capture (LLM-01, LLM-02 partial, LLM-04 level 1, SEC-04). See section 9.
- [ ] Security spine (SEC-01 to SEC-03) and the prod guard from phase 1.

### Add in the middle phases (5-9)

- [ ] Workbench UX completion, Compare, To review, Mobile layout (WB-02 to WB-16, WB-17, WB-18)
- [ ] Canon, lints, journeys declaration (CANON-*, JOURNEY-01)
- [ ] Probe, Checks, UX checks, visual regression, verdicts (CHECK-*, UX-*, VIS-*)
- [ ] Motion lane after its spike (MOTION-*)
- [ ] Full bundles, all focuses, skills (LLM-03, LLM-05 to LLM-08, SKILL-*)

### Add after validation (v1.x, already decided)

- [ ] Static export with "Needs server" badge (ADR 0022): trigger is Persona 6 and docs-site demand; ship before any other v1.x item
- [ ] MCP adapter over `Fablebook.Bundle` (ADR 0009): trigger is two independent requests
- [ ] Stories shipped inside dependencies (`priv/fablebook`)
- [ ] L4 judge recipe; print, data-visualization, content-density and information-scent checks
- [ ] Source permalinks, grid overlay, inspect-element-token (section 5)

### Future consideration (v2+)

- [ ] Hosted interactive mode behind auth (ADR 0006)
- [ ] Event record and replay for static exports
- [ ] Elixir-rendered email and PDF subject kinds (INTEROP.md); native renders stay out

---

## 8. Feature Prioritization Matrix (proposed items and flagged tightenings)

| Feature | User value | Implementation cost | Priority |
|---------|------------|---------------------|----------|
| CTRL-05 host scheme and Theme strategy | HIGH | MEDIUM | P1 |
| WB-17 check status provenance and run action | HIGH | MEDIUM | P1 |
| DOCS-01 interaction path (harness and `mount_scenario`) | HIGH | LOW | P1 |
| Thin LLM bundle slice in the early phases | HIGH | MEDIUM | P1 |
| WB-18 viewport height, orientation, persisted settings | MEDIUM | LOW | P2 |
| CTRL-06 copy override as scenario | MEDIUM-HIGH | LOW-MEDIUM | P2 |
| CORE-08 per-Tier expected State classes | MEDIUM | LOW | P2 |
| VIS-02 selective accept and diff artifacts | MEDIUM | LOW | P2 |
| Reviewer interim path (contact sheets as artifacts) | MEDIUM | LOW | P2 |
| Out of Scope additions (telemetry, markup snapshots, `parameters` bag) | MEDIUM | LOW | P2 |
| ADR 0003 wording for the time shim | MEDIUM | LOW | P2 |
| UX-05 and UX-06 narrowing | MEDIUM | LOW | P2 |
| WB-03 sidebar filters | LOW-MEDIUM | LOW | P3 |
| Free coverage and icons recipes | LOW | LOW | P3 |
| Source permalink, grid overlay, inspect element token | LOW | LOW-MEDIUM | P3 |

**Priority key:** P1 = resolve before the phase that builds it is planned; P2 = fold into that phase's plan; P3 = backlog.

---

## 9. Implications for the roadmap

1. **Phase 4 (Canvas fidelity and Globals) must carry CTRL-05.** The operator host fidelity spec (C3) cannot be green for dark mode without it.
2. **Pull a thin LLM slice forward.** The render seam lands in phase 2 and the no-browser capture level needs only markup, contracts and cited canon. Shipping `fablebook.bundle` for one Scenario plus Copy for LLM in phase 3 or 4 tests the Core Value ("export an accurate context bundle") nine phases earlier than the current order, and starts the C4 clearance evidence (three owner iterations driven by bundles) sooner. The allocator, contact sheets and the ten Focuses stay in phase 9. This is an ordering recommendation, not an intent change.
3. **Phase 5 (Workbench UX) is the densest.** It has the most REQs (WB-01 to WB-16, plus WB-17, WB-18, WB-03 amendment). Plan it as at least two phases per the "split, never compress" rule: shell, grid, inspector, palette and keyboard first; Compare, To review, Mobile layout, frames and Diagnostics second.
4. **Phase 7 groups three large lanes** (probe and checks, UX checks, visual regression plus verdicts). UX-01 to UX-08 are the long tail and can slip behind probe, sweep and baselines without hurting the Core Value.
5. **Phase 8 (Motion) keeps its spike first.** The shim contradiction with ADR 0003 should be settled before the spike ends.
6. **Phase 10 (Installer and DX) arrives late for the doctor.** CANVAS-05's diagnostic leans on the same checks as INST-03. Land the pure `Fablebook.Doctor` core with CANVAS-05 in phase 4 and leave only the Mix shell and Igniter work for phase 10.
7. **Research flags for later phases:** UX-07 (HEEx tokenization without a public API), CANON-06 (alpha spec), MOTION-01 (time shim), CTRL-05 (confirm the Phoenix 1.8 root layout toggle).

---

## 10. Competitor Feature Analysis

| Capability | Storybook 9-10 | Ladle | Histoire | Lookbook | Cosmos | Widgetbook | phoenix_storybook | Fablebook approach |
|---|---|---|---|---|---|---|---|---|
| Rendering fidelity | iframe, own bundler | Vite | Vite | iframe through host layout [R] | iframe | Flutter runtime | Inline, with a CSS isolation class option [F] | iframe through the host pipeline (CANVAS-01) |
| Controls | args and docgen | yes [K] | built-in and custom [F] | typed params [R] | control panel [F] | typed controls [F] | playground [F] | typed from `attr`/`slot`, presets (CTRL-01) |
| Docs | autodocs and MDX [F] | none | markdown [F] | pages [F] | none | none | page kind [F] | story page is the docs (WB-02), Pages (CORE-11) |
| Testing | Vitest addon, a11y, coverage [F] | index for Playwright [F] | snapshots [F] | none | none | goldens in Cloud [F] | none | generated ExUnit per Scenario, probe, sweep (CHECK-*) |
| Visual regression | Chromatic [F] | none | Percy, Lost Pixel [F] | none | none | Cloud [F] | none (#215 closed) [R] | pinned container, human-only accept (VIS-*) |
| Agent support | manifests and MCP [F] | none | none | JSON endpoints [F] | none | LLM use-case guide [F] | ask #715 [R] | manifest and budgeted bundles (LLM-*); MCP later |
| Sharing | static build | static build | static build | embeds, run in production [F] | static export [F] | Cloud | none | URLs, QR, image export now; static export v1.x |
| Motion | none mainstream [R] | none | none | none | none | time dilation [F] | none | scrub, slow motion, filmstrip, lints (MOTION-*) |
| Design knowledge | none | none | none | none | none | none | pages | Canon with Citations, lints, tokens (CANON-*) |
| Extensibility | addons (fragile) [R] | none by design | plugins | custom panels and inputs [F] | plugins [F] | custom addons [F] | none | none in 1.0 (ADR 0009) |
| Telemetry | on by default [F] | n/a | n/a | n/a | n/a | n/a | n/a | none, ever (proposed Out of Scope) |

---

## Sources

**Fetched during this pass ([F])**
- [Storybook 9 release coverage and testing summary](https://storybook.js.org/blog/storybook-9/), [release page](https://storybook.js.org/releases/9.0), [InfoQ](https://infoq.com/news/2025/07/storybook-v9-released)
- [Storybook 10 announcement](https://storybook.js.org/blog/storybook-10/)
- [Storybook writing tests](https://storybook.js.org/docs/writing-tests), [essentials](https://storybook.js.org/docs/essentials), [autodocs](https://storybook.js.org/docs/writing-docs/autodocs)
- [Storybook component manifests](https://storybook.js.org/docs/ai/manifests), [telemetry](https://storybook.js.org/docs/configure/telemetry)
- [Storybook "Save from controls" PR #26827](https://github.com/storybookjs/storybook/pull/26827)
- [Ladle](https://ladle.dev/docs/), [Histoire](https://histoire.dev/guide/), [Lookbook guide](https://lookbook.build/guide), [React Cosmos](https://reactcosmos.org/docs)
- [Widgetbook docs index](https://docs.widgetbook.io/llms.txt), [Widgetbook](https://docs.widgetbook.io/)
- [phoenix_storybook on HexDocs](https://phoenix-storybook.hexdocs.pm/PhoenixStorybook.html), [GitHub](https://github.com/phenixdigital/phoenix_storybook)

**Repo research and intent ([R], HIGH for internal facts)**
- `docs/research/LESSONS-LEARNED.md`, `UX-DESIGN.md`, `MOTION-AND-UX-DIMENSIONS.md`, `LLM-CONTEXT-AND-CANON.md`, `PERSONAS-JTBD.md`, `TWINS.md`, `INTEROP.md`
- `docs/adr/0002`, `0003`, `0009`, `0010`, `0011`, `0013`, `0019`, `0022`, `0024`, `0025`
- `.planning/intent/NORTH-STAR.md`, `CLEARANCE.md`, `OPEN-QUESTIONS.md`, `sources/` (INT-20261028-01 to INT-20261028-15)

**Unverified ([K]; re-check before relying)**
- Ladle's addon panel contents; Storybook viewport rotation and pseudo-state addons; Phoenix 1.8 root layout `data-theme` toggle; whether the HEEx tokenizer is public API; readability-formula limits on short strings.

---
*Feature research for: Phoenix LiveView component workbench (Fablebook)*
*Researched: 2026-10-28*
