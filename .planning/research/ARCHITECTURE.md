# Architecture Research

**Domain:** Storybook-style workbench for Phoenix LiveView (Fablebook), shipped as a Hex library mounted into a host app's router
**Researched:** 2026-10-28
**Confidence:** HIGH that the locked architecture is internally consistent and matches the one proven packaging pattern (LiveDashboard). MEDIUM on the cross-ecosystem comparisons (Lookbook, Storybook and Cosmos were checked only at documentation level). LOW on three runtime behaviours that must be proven by spikes (see "Open technical questions").

> Vocabulary follows `GLOSSARY.md`. Module names follow `docs/domain/DOMAIN-MODEL.md` §3. Where this file disagrees with, or finds a gap in, an ADR or PROJECT.md, it says so under "Flags" with evidence. Nothing here silently overrides a locked decision. Per CLAUDE.md precedence (intent > ADR > REQUIREMENTS > PROJECT), the owner decides each flag; the synthesizer should add the ones that touch an ADR or an INT to `.planning/intent/OPEN-QUESTIONS.md`.

## Verdict

1. **The core architecture is sound and should not change.** Compiled story modules, a pure catalog, a render seam outside any LiveView, a canvas that inherits the host's root layout, zero processes, and URL-as-state are each individually justified by a documented failure of phoenix_storybook, and together they form a clean one-way dependency chain (declaration, then catalog, then seam, then canvas, tests and bundles).
2. **The 12-phase order respects the hard dependencies at the level of "A before B", but not at the level of "what each phase contains".** Eight of the twelve phases exceed the 5-plan cap by the roadmap's own rule (1, 2, 4, 5, 6, 7, 9, 10; 11 is borderline), and four phases contain items whose inputs do not exist until a later phase (see "Phase-by-phase audit"). Splitting is mandatory under ADR 0021; expect roughly 20 to 27 phases, not 12.
3. **There are six real ordering problems** (Flags O1 to O6): the Phase 1 and 2 overload; crash containment and `Fablebook.Error`/telemetry living in the wrong phase; Phase 5 depending on canon, evidence and baselines that arrive in Phases 6 and 7; the installer arriving only in Phase 10 although `hosts/vanilla` is defined as installer output; the owner's primary motivation (bundles) arriving at Phase 9 with the seam's `:bundle` purpose unexercised until then; and real-host validation arriving only at Phase 12.
4. **There are five architecture tensions with locked ADRs** (Flags A1 to A5). The most serious is ADR 0003's stacked single-canvas grid, which shares one DOM between scenarios, conflicts with the "no injected JS" rule for lazy tiles, and cannot show per-tile viewports. The second most serious is that the render seam cannot render LiveComponents (verified in LiveView source), which the ADRs do not acknowledge.
5. **DOMAIN-MODEL §3 omits the modules the requirements need most**: a Rules/Waiver engine, Globals, Capture (the runner boundary shared by baselines, sweep, `--browser` bundles, shots and filmstrips), Journey, Motion, Verdicts/Ratchet and Doctor. They should be added before Phase 2 planning.

## Standard Architecture

### System overview

```
HOST APP (adopter's Phoenix app; Fablebook adds routes and zero processes)
+----------------------------------------------------------------------------------+
|  router.ex:  fablebook "/dev/fablebook", MyAppWeb.Book     (inside dev_routes)    |
|              -> Fablebook.Router macro: raises CompileError if Mix.env() == :prod |
+----------------------------------------------------------------------------------+
        | defines                                   | defines
        v                                           v
+------------------------------+     +----------------------------------------------+
| WORKBENCH live_session       |     | CANVAS live_session (+ static controller)    |
| root layout: Fablebook's own |     | root layout: HOST's own (no override)        |
| WorkbenchLive                |     | CanvasLive  | StaticCanvasController         |
|  sidebar / toolbar /         |     |  host app.css, app.js, hooks, fonts, CSP     |
|  inspector / palette /       |     |  scenario rendered inside Placement wrapper  |
|  Panels (Checks, Motion...)  |     |  [dir, lang, data-* globals set on wrapper]  |
+--------------+---------------+     +----------------------+-----------------------+
               |   iframe src = canvas URL + signed token + URL params               |
               +-------------------------------------------------------------------->|
               |<--- Phoenix.PubSub topic "fablebook:canvas:<signed token>" -------->|
               |     (host's existing PubSub; override casts down, event/crash up)   |
               |                                                                      |
               |   same-origin DOM access from workbench hook (no injected canvas JS)|
               +---- measure height, scrub getAnimations(), call __fablebook.probe() ->

PURE CORE (no processes, no ETS, no persistent_term; all async-safe)
+----------------------------------------------------------------------------------+
| Story/Scenario/Book -> __fablebook_story__/0 (compile time, metadata only)       |
| ComponentInfo (only reader of __components__/0)                                   |
| Catalog.build/1, fetch/2  <-- Canon.load/1 (the only IO boundary) --> %Canon{}    |
| Rules (registry, Waiver, Draft)  Coverage  Journey  Controls.Cast  URLState      |
| Render (seam): build -> Contain (monitored process) -> Normalize -> iodata + hash |
| Evidence (schema, ingest, staleness, fingerprint)  Manifest  Bundle (allocator)  |
+----------------------------------------------------------------------------------+

OUTER SHELLS (thin)
+----------------------------------------------------------------------------------+
| Testing (ExUnit)  Mix tasks  Doctor  Installer (Igniter)  Capture/Test.Visual     |
|   Capture = the single runner boundary: navigate canvas URL (probe=1), wait for   |
|   data-fablebook-ready, return PNG + ARIA + Evidence JSON                          |
+----------------------------------------------------------------------------------+
```

### Component responsibilities and boundaries

| Component (module) | Responsibility | Talks to | Must not |
|---|---|---|---|
| **Story / Scenario / Book** (`Fablebook.Story`, `.Scenario`, `.Book`) | Compile-time declaration. `use Fablebook.Story` injects at most 20 lines and emits `__fablebook_story__/0`: a Story's id parts, tier, Subject reference, and each Scenario's name, arity and metadata. It never calls a scenario function. | `ComponentInfo` (at catalog time, not compile time) | Read canon (ADR 0002: no canon `@external_resource`); eval anything; call the subject |
| **ComponentInfo** (`Fablebook.ComponentInfo`) | The only code that touches `__components__/0` and the LiveView slot shape. Re-sorts attrs/slots by `line`, returns a **Contract**. On contract break, signals "manual controls" and never crashes. | Subject modules | Be bypassed by any other module (a Credo/xref check should enforce it) |
| **Catalog** (`.Catalog`, `.Id`, `.Auto`, `.Coverage`) | Pure. `build(book)` returns stories, pages, Unstoried, ids and URLs. `fetch(book, story_id)` resolves one Story **without** building the whole Catalog (see A5). Coverage is Stories x State classes. | Story modules, ComponentInfo | Read files, call `Code.*`, hold state, create atoms from ids |
| **Canon** (`Fablebook.Canon`, `.Frontmatter`, `.Tokens`, `.Lint`, `.Contrast`) | `Canon.load(book)` is the **only IO boundary** in the pure core: reads `design/**` (and a canon dependency's dir), returns an immutable `%Canon{}`. Everything else (layers, citations, lints, contrast) is a pure function of `%Canon{}`. | File system (via one reader function), Catalog (citation existence) | Be called from `Catalog.build/1` (keeps the Catalog pure and PERF-01 honest) |
| **Rules** (not in DOMAIN-MODEL; `Fablebook.Rules`, internal) | One registry of rules with stable ids. A rule declares `scope` (story, scenario, canon, rendition), `needs` (catalog, canon, markup, evidence) and default severity, including "warning until prerequisite P exists". One function resolves final severity from Waivers and Draft. | Catalog, Canon, Evidence, Render output | Live inside LiveViews or Mix tasks; every consumer calls the registry |
| **Globals** (not in DOMAIN-MODEL; internal) | The closed set: theme, direction, scheme, locale, text direction, viewport, device frame, motion. Defaults, validation, and the split between **server-applied** (locale, dir, scheme, theme, motion attribute) and **browser-only** (viewport, frame, zoom) globals. | URLState, Render, Canvas | Be extended at runtime |
| **Controls** (`Fablebook.Controls`, `.Cast`, `Fablebook.URLState`) | Typed casting from Contract metadata; Presets; Overrides; the URL codec (`o` at most 2 KB). Pure. | ComponentInfo (Contract), Globals | Create atoms or eval; accept an Override the Contract did not declare |
| **Render** (`Fablebook.Render`, `.Slots`, `.Contain`, plus internal Normalize) | The render seam. Builds the `%Rendered{}` for a Scenario (+ Overrides + Globals), runs it in a monitored, heap-capped, time-capped process, normalizes the markup, returns `{:ok, iodata, render_hash} \| {:error, %Fablebook.Error{}}`. `Slots` is the only builder of the LiveView slot shape. | Catalog structs, Controls, Globals | Depend on any LiveView process or socket; differ between purposes beyond the purpose tag |
| **CanvasLive / StaticCanvasController** (`Fablebook.UI.CanvasLive`, `.Layouts`) | The Canvas. Verifies the signed token, resolves one Scenario, dry-runs it through Render, then renders live inside a Placement wrapper carrying Globals as attributes. Subscribes to the token topic. Catches unknown events and logs their names. | Render, Controls, PubSub | Own or change the host's `<html>`; inject JS (except opt-in probe); trust broadcast payloads without casting |
| **WorkbenchLive** (`Fablebook.UI.WorkbenchLive`, `.Assets`, internal `Panel` behaviour) | Chrome: sidebar, toolbar, inspector, palette, Panels (Checks, Motion, To review, Foundations, Diagnostics). Holds Catalog and Canon in assigns; URL is the state. Mints the token, builds the canvas URL, broadcasts casted Overrides. | Catalog, Canon, Controls, Evidence, PubSub | Render a Scenario itself; share a document with the Canvas |
| **Evidence** (`Fablebook.Evidence`, `Fablebook.Probe` JS) | Versioned schema, ingest, staleness by render hash, fingerprints. The Probe is runner-agnostic JS served from the mount; Evidence is runner-agnostic JSON. | Render (hash), Rules | Know which runner produced it |
| **Capture** (not in DOMAIN-MODEL; `Fablebook.Test.Visual` is its public face) | The single runner boundary: URL for a Rendition, wait for `data-fablebook-ready`, return PNG, ARIA, Evidence. Used by baselines, Sweep, `--browser` Bundles, `fablebook.shot`, Filmstrips. | Playwright (optional dep), Evidence | Be duplicated per feature (ADR 0010 already says "same capture pipeline") |
| **Manifest / Bundle** (`Fablebook.Manifest`, `.Bundle`) | `index.json`, `components.json`; the Bundle allocator, focus rubrics, redaction, schema validation. | Catalog, Canon, Render (`:bundle`), Evidence, Capture (browser tier) | Call a browser in the no-browser tier; call `Code.fetch_docs` from Catalog build (only the manifest and Reference do, lazily) |
| **Testing** (`Fablebook.Testing`) | `generate_tests/1`, `mount_scenario/2` (`live_isolated`), `assert_manifest_current/2`. | Catalog, Render, Rules | Be required at runtime in the host |
| **Doctor + Mix shells + Installer** | Pure `Fablebook.Doctor` core (checks host wiring); each Mix task is a thin shell. The canvas connection diagnostic (CANVAS-05) reuses the same Doctor rules. | Everything below, through public functions | Hold logic that the workbench or CI also needs |
| **Telemetry / Error** (`Fablebook.Telemetry`, `Fablebook.Error`) | Closed event catalogue and closed error set. | Used by all | Attach handlers; carry attr values, paths or HTML in metadata |

### Layering rule (enforce with `xref` and a boundary test from Phase 2)

| Layer | Contents | May depend on |
|---|---|---|
| L0 Kernel | Error, Telemetry, Globals, Catalog.Id, Controls.Cast, Canon.Frontmatter/Tokens/Contrast | nothing in Fablebook |
| L1 Declaration | Story, Scenario, Book, ComponentInfo | L0 |
| L2 Model | Catalog, Canon.load, Rules, Coverage, Journey, Evidence (data only) | L0, L1 |
| L3 Render | Render, Slots, Contain, Normalize | L0 to L2 |
| L4 Delivery (pure) | Manifest, Bundle (no-browser tier), Testing | L0 to L3 |
| L5 UI | Router, WorkbenchLive, CanvasLive, Layouts, Assets | L0 to L4 |
| L6 Browser shells | Capture/Test.Visual, Probe, Motion shim, Bundle browser tier | L0 to L4, optional Playwright |
| L7 Entry points | Mix tasks, Installer, Doctor shell | any |

The pure core (L0 to L4) never references `Phoenix.LiveView` server processes or the UI. That is what lets the same Rules run in the Checks tab, the sweep, generated tests and bundles with identical results (CHECK-02: "finds exactly what CI finds").

### Process and state model (zero processes in the host)

| Thing | Where it lives | Notes |
|---|---|---|
| View state | The URL (`vw`, `scheme`, `o`, `check`, ...) | Source of truth. Reload reproduces it. The PubSub push is only an optimization over re-navigating the canvas. |
| Catalog, Canon | WorkbenchLive assigns (built once per mount, rebuilt on reload) | No cache process, no ETS, no `:persistent_term` (ADR 0008). Never held by CanvasLive beyond one resolved Scenario. |
| Render process | A short-lived `spawn_opt` with `:monitor` and `max_heap_size` | Dies after each render. Not a host process. Sets Gettext locale and any per-process state itself. |
| Channel | The host's existing `Phoenix.PubSub` (from the endpoint's `pubsub_server`), topic derived from a `Phoenix.Token`-signed 128-bit token | Zero Fablebook processes. Messages are tagged by direction so neither side echoes. |
| Files in the repo | Baselines, verdicts log, Known findings, written manifest, generated DESIGN.md | Evidence is keyed by render hash and goes stale, never silently current. |

### Recommended project structure

```
lib/fablebook/
  story.ex scenario.ex book.ex                 # L1 public: the only declaration surface
  component_info.ex                            # L1 internal adapter (@moduledoc false)
  catalog.ex catalog/{id,auto,coverage}.ex     # L2
  canon.ex canon/{frontmatter,tokens,lint,contrast,layers,design_md}.ex
  rules.ex rules/*.ex                          # one module per rule family, stable ids
  globals.ex controls.ex controls/cast.ex url_state.ex
  render.ex render/{slots,contain,normalize}.ex
  evidence.ex manifest.ex bundle.ex bundle/{allocator,focus,redact}.ex
  testing.ex test/visual.ex capture.ex doctor.ex
  telemetry.ex error.ex
  router.ex
  ui/{workbench_live,canvas_live,static_canvas_controller,layouts,assets,panel}.ex
  ui/panels/{checks,motion,to_review,foundations,diagnostics}.ex
lib/mix/tasks/fablebook.*.ex                   # thin shells over public functions
priv/static/{fablebook.css,fablebook.js,fablebook-probe.js,LICENSES}
hosts/{vanilla,operator,shared}                # CI host apps (not shipped)
bench/                                         # sibling Mix project (advisory)
```

**Rationale:** one directory per bounded context in DOMAIN-MODEL §3, plus the four contexts that file omits. Everything except the surface listed under "Public module budget" carries `@moduledoc false`.

## Architectural Patterns

### Pattern 1: LiveDashboard-style mounting (HIGH, verified against LiveDashboard router source)
**What:** A router macro expands to a `live_session` (with `session: {Mod, :fun, args}` carrying pre-parsed options and CSP nonces, a named `root_layout`, and `on_mount` from options), two hashed asset routes, and the LiveView routes. It starts no process; the session function only builds a map.
**When:** The workbench live_session. Fablebook's canvas live_session is the one deliberate departure: it sets **no** `root_layout`, so the host pipeline's root layout applies.
**Trade-offs:** Macro expansion cost lands in every host compile; keep the macro body tiny and delegate to functions. The compile-time `CompileError` in prod (ADR 0006) is inert code in prod, which is why the dependency has no `only:`.

### Pattern 2: Index and render are separate (Storybook; MEDIUM, from Storybook indexer docs)
**What:** Storybook builds `index.json` from indexers without rendering anything, and only imports a story's file when its URL is opened. Fablebook's analogue: `__fablebook_story__/0` and `Catalog.build/1` (metadata only) versus `Render` (executes scenario functions), and `Manifest` (metadata) versus `Bundle` (renditions).
**When:** Always. A sidebar of 5000 Scenarios must never run a scenario function. The PERF-01 "zero `Code` calls" gate and "catalog does not render" are the same rule.
**Trade-offs:** Some outputs (Reference, `components.json` with `@doc`) need `Code.fetch_docs`; fetch them lazily on story open or manifest write, never in `Catalog.build/1`.

### Pattern 3: One render path, two tails
**What:** Split the seam internally into `build` (resolve Scenario + Overrides + Globals into a `%Rendered{}` and Placement wrapper; pure) and `to_iodata` (contain, normalize, hash). CanvasLive's `render/1` uses `build`; Testing, Bundle and Export use both. The public function stays `Render.render(scenario, globals, purpose)`.
**When:** From Phase 2. Without it, "the canvas renders X but the bundle captured Y" bugs appear because the canvas needs change tracking and hooks, which iodata conversion cannot give.
**Trade-offs:** One more internal function boundary; zero extra public modules.

### Pattern 4: Contain, then render (HIGH on mechanism; ADR 0003 and QUALITY-PERF-SRE)
**What:** Render once in a monitored process with `max_heap_size` and a 2 s timeout. Only on `{:ok, _}` does CanvasLive assign the live render. Raise, throw, exit, timeout and heap each become a `%Fablebook.Error{}` panel plus a `[:fablebook, :canvas, :crash]` event.
**When:** Every canvas mount and every non-canvas purpose. Cost is a double render; the ADR 0015 gate (max 50 ms) bounds it.
**Trade-offs:** A subject with side effects at render time runs twice. Document it. Process-dictionary state (Gettext locale, frozen clock) must be set inside the spawned process.

### Pattern 5: One rules registry, many consumers
**What:** Every check (strict defaults in ADR 0024, canon lints, motion lints, UX checks, journey checks) is a registered rule with a stable id, a `needs` declaration and a severity function. The registry is called by `Catalog` validation, the Checks tab, Sweep, `Testing.generate_tests`, `mix fablebook.doctor`, and Bundle digests.
**When:** Build the registry in Phase 2 with the first few rules (`desc` required, subject kind, duplicate render). Later phases add rules, not engines. SKILL-02 ("rules live in checks with stable ids") and CORE-12/13 (Waivers, Draft) both depend on this single resolution point.
**Trade-offs:** The registry's `needs` declaration is what makes "warning until the canon has a persona, error after" and "`not-run`, never `pass`" fall out naturally.

### Pattern 6: Same-origin direct access instead of an injected protocol
**What:** Because the canvas is a same-origin document, the workbench's own hook can read the canvas height, call `document.getAnimations()` to pause and scrub (ADR 0025), and call `window.__fablebook.probe()`. Storybook needs a postMessage channel because its preview can be remote; Fablebook does not.
**When:** Motion panel, height measurement, Checks tab. The probe script tag is rendered server-side by CanvasLive only when the URL has `probe=1` (UX-DESIGN), with the nonce. This keeps ADR 0003's "no injected JS except the opt-in probe" true, and avoids a second protocol.
**Trade-offs:** Anything that must run before page scripts (a time shim that has to wrap timers created at load) cannot be injected this way. The time shim only needs to wrap timers created on interaction, so patching `iframe.contentWindow.setTimeout` after load is enough. Verify in the Phase 8 spike.

### Pattern 7: Render hash as the identity of a Rendition's content
**What:** The seam computes sha256 over **normalized** markup (strip `data-phx-*`, generated ids, CSRF values) plus the host CSS hash, returns it, and the canvas stamps it as `data-fablebook-render-hash`. Evidence, "no two scenarios render identically", staleness and baseline-manifest matching all use it.
**When:** From Phase 2 (Normalize and hash); Evidence in Phase 7.
**Trade-offs:** Normalization must be the same code for the seam and for any DOM-derived markup in bundles (ADR 0010 already requires this stripping), so it lives in one internal module.

### Pattern 8: Capability-labelled output
**What:** The seam and every pure-tier consumer may answer "cannot render this server-side" (for example a LiveComponent subject) with a typed `%Fablebook.Error{type: :unsupported_subject}`. Consumers report `not-run` and the Bundle labels the gap. Never fabricate markup.
**When:** Tests, no-browser Bundles, Export. See Flag A2.

## Data Flow

### Compile time (host `mix compile`, :dev and :test only)

```
storybook/**/*.ex --use Fablebook.Story--> __fablebook_story__/0   (metadata only)
host components  --attr/slot--------------> __components__/0        (private; read only by ComponentInfo)
```

### Catalog build (pure, per workbench mount and on reload)

```
Book --Catalog.build--> %Catalog{stories, pages, unstoried, ids, urls}
        uses ComponentInfo.contract/1 per Subject (re-sorted by line)
design/** --Canon.load (IO)--> %Canon{layers resolved}
(Catalog, Canon) --Rules.run(scope: :catalog|:canon)--> findings (severity resolved by Waiver/Draft)
(Catalog, Canon) --Coverage.compute--> matrix of Stories x State classes
```

### Render (runs outside any LiveView)

```
(Scenario, Overrides, Globals, purpose)
   --Render.build-->  %Rendered{} in Placement wrapper (Globals as attributes on the wrapper)
   --Contain.run-->   monitored process (heap cap, 2 s) -> raise|throw|exit|timeout|heap => %Error{}
   --Normalize-->     markup + render_hash
   consumers by purpose:
     :canvas  CanvasLive (dry-run gate, then live render; keeps hooks and change tracking)
     :test    Testing.generate_tests, mount_scenario via live_isolated
     :bundle  Bundle no-browser tier (markup, copy lint input)
     :export  v1.x static export
```

### Interactive loop (workbench and canvas)

```
URL (?scenario, o, vw, scheme, theme, ...)  <- single source of truth
  WorkbenchLive.handle_params
     -> Controls.Cast(o) -> Overrides (cast terms only)
     -> iframe src = canvas URL with the same params + signed token
  control change:
     WorkbenchLive: push_patch (URL updated) + PubSub {:overrides, cast_terms, globals}
     CanvasLive:    handle_info -> Render.build -> patch in place (focus and open dialogs survive)
  subject event:
     CanvasLive handle_event/handle_info catch-all -> PubSub {:event, name, truncated_params}
     WorkbenchLive: Events tab (string names, payload <= 4 KB, scoped to the token topic)
  crash: CanvasLive error panel + PubSub {:crash, %Error{}} + telemetry
  reload: both documents re-mount from the URL alone; no server state lost
```

### Evidence loop

```
Checks tab (live):  WorkbenchLive hook -> iframe (probe=1) -> __fablebook.probe() -> Evidence JSON
                    -> pushEvent -> Evidence.ingest -> Rules (needs: evidence) -> Findings
CI (runner):        Capture -> canvas URL (probe=1) -> wait data-fablebook-ready -> probe -> same JSON
Findings -> fingerprint -> Ratchet (Known findings may only shrink) -> Verdicts log (repo file)
Staleness:          Evidence.render_hash != current Render hash  => labelled stale, never "current"
```

### Bundle

```
selector (scenario|story|section|tier|tag|all)
  -> Catalog.select -> Canon filter by Citations + term hits -> Contracts
  -> Render (:bundle) for markup, copy         [no-browser tier, pure]
  -> Capture (opt-in --browser) for PNG, ARIA, measurements, axe   [same pipeline as baselines]
  -> Allocator (priority fill: canon+voice, contracts, failing evidence, shots, markup, pass counts)
  -> Redact -> BUNDLE.md + bundle.json (fablebook.bundle/1) + per-scenario dirs
```

### Key data-flow decisions

1. **URL first, push second.** The canvas can always be re-created from its URL; PubSub only avoids reloading it on each control change.
2. **Cast on both sides, from different inputs.** WorkbenchLive casts the URL `o` param and broadcasts cast terms; CanvasLive re-casts its own URL on mount. Neither side evals or creates atoms from a payload (ADR 0004).
3. **Resolution by string comparison.** Story and Scenario ids from the URL are matched against the Catalog's strings, never converted with `String.to_atom`, `Module.concat` or `to_existing_atom` (ADR 0004).
4. **Canon never flows through compile.** Citations are shape-checked at compile time and existence-checked at catalog time against `%Canon{}`, so editing canon recompiles nothing.

## Scaling Considerations

The relevant axis is catalog size and rendition count, not users.

| Scale | Catalog / workbench | Grid | Sweep and baselines | Bundles |
|---|---|---|---|---|
| 50 scenarios (day 0, vanilla host) | Mount is trivial; no concern | One stacked or lazy canvas per story is fine | PR visual-core covers everything | Whole-catalog bundle fits one budget |
| 500 scenarios / 100 stories (target; ADR 0015 N=500) | Heap gate 3 MB, reductions 1.25x reference | Grid of the 40 largest story must meet ADR 0015 (reversal trigger in ADR 0003) | Sweep = 500 x 5 widths x 2 schemes = 5000 renditions plus reduced motion. At about 1 s each that is over 80 minutes single-threaded, so the nightly sweep **must shard**; PR runs the curated subset only | Section and tier bundles; "all" needs the contact-sheet path |
| 5000 scenarios (gate, not expected) | t(5000)/t(500) < 15; 1.5 s; sidebar must stream | Lazy tiles mandatory | Full sweep is a release-lane job; visual stays at the <= 400 cap | Catalog-scope bundle drops per-scenario markup by design |

**First bottleneck:** the stacked grid (a single LiveView diffing N scenarios in one process). Fix: chunked tiles (stream plus `phx-viewport-bottom`) or per-tile lazy canvases (Flag A1).
**Second bottleneck:** sweep wall-clock, not server cost. Fix: sharding and the curated PR subset, which the CI design already assumes.

## Anti-Patterns

### Anti-Pattern 1: A process to cache, watch or coordinate
**What people do:** A GenServer for the catalog, a file watcher (Lookbook uses Listen; phoenix_storybook runs its own servers), an ETS table for ids.
**Why it's wrong:** Breaks "zero processes", adds global GC churn (`:persistent_term`) and dev/test divergence.
**Do this instead:** Rebuild the pure Catalog on mount; let the host's existing `live_reload` patterns (installer adds `storybook/**/*.ex` and `design/**`) trigger a reload; URL state makes a reload lossless.

### Anti-Pattern 2: Inline rendering, or any Fablebook-owned root layout for the canvas
**What people do:** Render scenarios in the workbench DOM with CSS prefixes (the incumbent's root cause).
**Why it's wrong:** Fidelity loss, hook re-registration, serif overrides.
**Do this instead:** The canvas live_session without `root_layout`, always.

### Anti-Pattern 3: Two render paths
**What people do:** One path for the canvas, another for tests and bundles.
**Why it's wrong:** Evidence for one rendition gets attached to another; golden bundles pass while the canvas is broken.
**Do this instead:** Pattern 3 (shared `build`, different tails) and Pattern 7 (hash).

### Anti-Pattern 4: Rules inside LiveViews or Mix tasks
**What people do:** Implement a check where it is first needed.
**Why it's wrong:** The Checks tab, sweep and bundle then disagree; Waiver and Draft handling gets duplicated.
**Do this instead:** Register a rule; every surface calls the registry.

### Anti-Pattern 5: Resolving ids by constructing modules or atoms
**What people do:** `Module.concat([app, "Storybook" | segments])` from the URL, or `String.to_existing_atom`.
**Why it's wrong:** Violates ADR 0004's spirit and invites enumeration of arbitrary modules.
**Do this instead:** `Catalog.fetch/2` compares strings against the namespace-derived ids.

### Anti-Pattern 6: Retrofitting cross-cutting concerns
**What people do:** Add telemetry, the error set, mutation floors and perf gates in a final "hardening" phase.
**Why it's wrong:** Every earlier phase then needs rework, and editing the contract test that guards the catalogue in the same PR as the code violates the "never edit a contract test with its implementation" rule.
**Do this instead:** Make `Fablebook.Telemetry.events/0` the data (in `lib/`) and the test generic (compare emitted events to the list). New events edit `lib/`, not the test.

### Anti-Pattern 7: A public Panel API
**What people do:** Expose panels as an extension point early (Storybook addons).
**Why it's wrong:** Locks the internals; ADR 0009 defers it.
**Do this instead:** An internal `Fablebook.UI.Panel` behaviour so Phases 6 to 8 can add panels without touching WorkbenchLive each time; keep it `@moduledoc false`.

## Integration Points

### External services and tools

| Service | Integration pattern | Notes |
|---|---|---|
| Host router/pipeline | `fablebook "/path", Book` macro; canvas live_session inherits pipeline root layout | `canvas_pipeline` and `canvas_root_layout` overrides exist for hosts whose root layout has side effects |
| Host PubSub | Endpoint's `pubsub_server`, token topic | No process added |
| Host `app.js`/`app.css` | Loaded by the canvas through the host root layout; never edited | Doctor checks `window.liveSocket` and CSS reachability |
| Host Gettext backend | Book declares the backend; seam sets locale inside the render process and CanvasLive sets it in its own process | Locale is per process (QUALITY-PERF-SRE) |
| Playwright (opt-in) | `Capture` / `Test.Visual` via phoenix_test_playwright | See Flag A4: documented as ExUnit-only and `only: :test` |
| abracabrand `brandbook/` | Read-only canon input, pinned by `inventory.json` hash | Never written |
| impeccable `PRODUCT.md` | Read-only | `DESIGN.md` and `.impeccable/design.json` are written only with an ownership header |
| Igniter | Optional; plain Mix fallback prints steps | Never touches `app.js` or the Tailwind config |

### Internal boundaries

| Boundary | Communication | Notes |
|---|---|---|
| Story module <-> Catalog | `__fablebook_story__/0` (metadata only) | The only contract; keep it versioned in the manifest |
| Catalog <-> Canon | Pure function over `%Canon{}` | Canon IO is isolated in `Canon.load/1` |
| WorkbenchLive <-> CanvasLive | URL params at mount + PubSub token topic | Direction-tagged messages; payloads are cast terms or truncated strings |
| WorkbenchLive <-> canvas document | Same-origin DOM access from the workbench hook | Probe, height, animation scrub; no postMessage protocol |
| Render <-> everything | `render/3` plus `build/…` internal | Purpose atom is a closed set (canvas, test, bundle, export) |
| Rules <-> surfaces | Registry call | One severity resolver |
| Capture <-> Playwright | Behaviour with one implementation in 1.0 | ADR 0011 reversal path ports to a generated JS spec without touching Probe or Evidence |

## Flags: where this research disagrees with, or adds to, the locked decisions

Each flag states the evidence and a recommendation; none is applied silently.

### A. Architecture tensions with ADRs

**A1. ADR 0003, stacked single-canvas grid (severity HIGH; owner decision; reversal trigger already exists).**
Evidence and reasoning:
- Scenarios of one Subject routinely share DOM ids (form ids, `<.input id=...>`, `aria-controls` targets). Stacking them in one document puts duplicate ids into one LiveView DOM, which LiveView's patching assumes cannot happen (MEDIUM; not re-verified in LiveView docs during this pass, so prove it in the spike).
- Hooks, `<.portal>`, `position: fixed`, `<dialog>` and viewport units (`min-h-screen`, `100vh`) behave per document, not per tile. A stacked Screen-tier Scenario with `min-h-screen` and an auto-sizing iframe is a feedback loop.
- A stacked canvas has one viewport width, so tiles cannot differ in `vw`; Compare mode, device frames and the 320 to 1440 sweep need per-rendition documents anyway.
- "Lazy-renders tiles" inside one canvas needs viewport observation. ADR 0003 also says no Fablebook JS in the canvas. The only JS-free options are LiveView's own `phx-viewport-bottom` over a stream (chunked, not per tile) or native lazy iframes.
Recommendation: make the Phase 4 spike decide, with an adversarial fixture set (duplicate ids, a hook, a portal, a modal, `min-h-screen`). Default to **native `loading="lazy"` canvases per tile for Area and Screen tiers and for `placement: :fullscreen`**, and allow stacking only for Primitive and Pattern if the spike passes. This keeps CANVAS-02 true in intent (lazy tiles, bounded cost) and is within ADR 0003's own reversal trigger.

**A2. The render seam cannot render LiveComponents (severity HIGH; HIGH confidence on the fact).**
Evidence: in LiveView's `engine.ex`, `Phoenix.HTML.Safe` for `Phoenix.LiveView.Rendered` calls `dynamic.(false)` and interleaves static and dynamic parts, so function components render to iodata outside a LiveView (confirms ADR 0022's premise). The same file's `Phoenix.HTML.Safe` implementation for `Phoenix.LiveView.Component` raises `ArgumentError: cannot convert component ... with id ... to HTML`. Therefore any Subject that is a `:live_component`, and any template that contains `<.live_component>`, cannot be turned into iodata by the seam. `render_component` in LiveViewTest would work but needs `lazy_html`, which the generated apps list as test-only.
Impact: ADR 0002 allows LiveComponents up to Area; ADR 0022 and DOMAIN-MODEL describe the seam as universal. Tests, no-browser Bundles and Export would silently skip them or crash.
Recommendation: the seam returns `{:error, %Error{type: :unsupported_subject}}` for server-only purposes and consumers label the gap `not-run` (Pattern 8). The `:canvas` purpose hosts them. Write this into the Phase 2 seam contract and the Bundle honesty rules. Streams passed as attrs are the other known case; the canvas materializes them (ADR 0002), and the seam needs the same adapter.

**A3. Globals that need `<html>` or media queries (severity MEDIUM; spike in Phase 4).**
Evidence: the root layout is the host's, so Fablebook cannot set `<html lang dir data-theme class="dark">`. Attributes on a Placement wrapper work for `dir`, `lang`, selector-based dark mode (Phoenix 1.8's generated `data-theme` setup) and daisyUI-style `[data-theme]`. They do **not** work for dark mode written as `@media (prefers-color-scheme: dark)` (Tailwind v4's default unless the host defines a selector `@custom-variant dark`) or for the reduced-motion media query. ADR 0019 says the installer never touches the Tailwind config, and ADR 0025 resolves reduced motion with an installer-added `[data-motion=reduce]` selector plus a Doctor check.
Recommendation: before Phase 4 closes, test a same-origin CSSOM approach from the workbench hook: for same-origin stylesheets, rewrite `CSSMediaRule.media.mediaText` for `prefers-color-scheme` and `prefers-reduced-motion` rules. It needs no installer change and no canvas JS. Status LOW until spiked. If it works it removes an installer step and a Doctor failure mode; if not, the documented selector contract stays and `scheme=dark` is honestly unavailable ("Set up dark selector") for media-based hosts.

**A4. ADR 0011 spike criteria miss the architecture-defining question (severity HIGH for Phase 9; MEDIUM confidence).**
Evidence: the phoenix_test_playwright README shows `only: :test`, `use PhoenixTest.Playwright.Case`, a supervisor started from `test_helper.exs`, the Playwright npm package installed under the host's `assets/`, and `server: true` for the endpoint. It does not say the library works outside ExUnit. Yet `mix fablebook.bundle --browser`, `mix fablebook.shot` and the sweep are Mix tasks, and the workbench's "Download context" cannot assume a browser.
Recommendation: add criteria 7 and 8 to the Phase 1 spike: (7) usable from a Mix task with the host endpoint started in a non-test env, and (8) dev-env availability of an optional dependency. If either fails, the fallback in ADR 0011 (a generated JS spec) or a thin port-driver `Capture` implementation becomes the 1.0 path for Bundles and shots. The Probe and Evidence schema are unaffected, which is why they were made runner-agnostic.

**A5. Catalog purity, canon IO, and per-canvas cost (severity MEDIUM; clarification more than disagreement).**
- ADR 0008 says the Catalog is a pure function and canon is read from `design/`. Reading files is IO. Keep `Catalog.build/1` pure over modules and make `Canon.load/1` the single explicit IO boundary (see components table). Otherwise PERF-01 ("zero `Code` calls", 5000 scenarios in 1.5 s) will be measured against disk reads, and the Catalog stops being a pure function.
- CanvasLive must not run `Catalog.build/1` for each of N canvases. Provide `Catalog.fetch(book, story_id)` that resolves one Story by string match against namespace-derived ids.
- ADR 0008 builds the module list from `Application.spec(otp_app, :modules)`. Whether that list includes a story module added after the application was loaded in a long-running dev VM is **unverified** (searches and the Elixir Forum thread on module-recompile notification gave no confirmation either way). Phase 2 should include a test that adds a story module under `MIX_ENV=dev` with the code reloader and asserts it appears. Fallback: list the app's `ebin` beam files.
- CANVAS-06 ("updates the open workbench without a restart") has no hook in Phoenix for "modules recompiled" that does not need a watcher process (the same Forum thread: no bullet-proof public notification). Recommended baseline: host `live_reload` patterns trigger a reload of both documents and the pure Catalog rebuilds on mount. Because all state is in the URL, the reload is lossless. The owner should confirm that a reload satisfies "updates the open workbench".

### B. Gaps in DOMAIN-MODEL §3 and PROJECT.md

**B1.** Missing contexts, each required by an Active requirement: **Rules/Waiver/Draft** (CORE-12/13), **Globals** (CTRL-04, CORE-09), **Capture** (VIS-01, CHECK-04, LLM-04, WB-16, MOTION-06), **Journey** (JOURNEY-01 to 03), **Motion** (MOTION-01 to 07), **Verdicts/Ratchet** (CHECK-04/06), **Doctor** (INST-03, CANVAS-05).
**B2. Pages have no storage story.** A Page "may embed live scenarios" and has no Subject, but ADR 0001 forbids runtime file compilation and ADR 0008 does not name Pages. Recommend a `Fablebook.Page` that compiles Markdown/HEEx into a module (`__fablebook_page__/0`) so the Catalog stays one mechanism. The Catalog data model should include the `:page` entry kind from Phase 2, not Phase 6 (otherwise Phase 6 reshapes the Catalog and the manifest).
**B3. "Compare against main" (WB-13) has no mechanism.** Two revisions cannot render in one running host. The only 1.0-feasible source for "main" is committed Baselines (images) captured by the runner, which makes it a Phase 7 capability, not Phase 5.
**B4. DESIGN.md and `.impeccable/design.json` "from rendered primitives" (CANON-06).** `components[]` as self-contained html/css needs resolved CSS. Markup from the seam is pure; resolved styles need the browser. Split: DESIGN.md from tokens plus seam markup in the canon phase; the `design.json` component CSS arrives with Capture (after Phase 7).
**B5. Public module count.** The ten Mix tasks are `Mix.Tasks.*` modules that ExDoc documents. Library-public modules fit comfortably (see budget below), but "≤25 public modules" should state whether tasks count before the API-surface snapshot test (QA-03) encodes a definition.
**B6. JOURNEY-03 (filmstrip UI) has no phase** in "Roadmap constraints". The Journeys sidebar group appears in Phase 5 with no data until Phase 6.

### C. Ordering problems (detail in the next section)

O1 Phase 1 and 2 overload. O2 Containment, Error and Telemetry are cross-cutting and early. O3 Phase 5 consumes data from Phases 6 and 7. O4 Installer arrives after the hosts that depend on it. O5 Bundles arrive late relative to value and leave the seam's `:bundle` purpose unexercised. O6 Real-host validation arrives last. Smaller items are listed in the audit table.

## Build Order (dependency-ordered)

### Component dependency chain

```
Error, Telemetry, Globals                       (kernel; first, because every signature uses them)
  -> Router + prod guard + Assets shell          (can exist with nothing behind it)
  -> Story/Scenario/Book (+ minimal canvas slice proves fidelity early)
  -> ComponentInfo  -> Catalog (Id, fetch, Auto, :page kind) -> Rules registry (+ Waiver, Draft)
  -> Render (Slots, Contain, Normalize, hash, render modes)  -> Manifest
  -> Controls.Cast + Presets + URLState         (needs ComponentInfo contract and Globals)
  -> CanvasLive (+ static controller, token topic, event log, Doctor rules, Placement/Globals)
  -> WorkbenchLive (+ Panel behaviour)          (needs Catalog, Controls, Canvas)
  -> Testing.generate_tests                     (needs only Catalog + Render; can land right after Render)
  -> Canon (Frontmatter, load, layers, Tokens, Lint, Contrast) -> Foundations, Themes, Directions
  -> Coverage UI, citation existence, Journey declaration, To review (canon items)
  -> Probe + Evidence + Checks tab + Capture   (needs Canvas, Canon tokens, Rules)
  -> Sweep, Ratchet, Verdicts, Visual lanes    (needs Capture + Manifest)
  -> Motion (shim, panel, lints, filmstrip)    (needs Capture, Canon motion tokens, Canvas)
  -> Bundle no-browser                          (needs Render + Canon + Manifest; could be earlier)
  -> Bundle browser + allocator + focuses       (needs Capture, Evidence, Motion for its focus)
  -> Installer core -> gen.story/doctor/migrator/shot -> docs
  -> Hardening (bench, Muex floors tuned, SBOM, API snapshot)
```

### Phase-by-phase audit of the 12-phase list in PROJECT.md

Plan counts are estimates from the listed scope (about 1 plan per bullet group); confidence MEDIUM.

| # | PROJECT.md phase | Needs from earlier | Verdict | Problem |
|---|---|---|---|---|
| 1 | Walking skeleton | none | **Split (about 6 plans)** | Release + CI + caps + intent test + router/prod guard + two host apps + LiveViewTest + visual guard + runner spike. It also needs a minimal `use Fablebook.Story` (Phase 2 owns the macro) and a minimal canvas to "render one compiled story", and ADR 0020 defines `hosts/vanilla` as installer output while the installer is Phase 10. |
| 2 | Story model and catalog | 1 | **Split (about 7 plans)** | Story macro, citations shape, Catalog/ids/PERF-01, ComponentInfo + three-lane contract test, Unstoried, manifest + drift, seam + modes, Rules/Waiver/Draft. Containment belongs here (it is the seam's process boundary) but PROJECT.md lists "crash containment" in Phase 4. `Fablebook.Error` is already in the seam signature, so it lands here too. |
| 3 | Controls and URL state | 2 (Contract, Globals) | **OK** (<= 5 plans) | Produces no visible UI (Inspector is Phase 5, push channel is Phase 4), but must precede 4 because the canvas reads `o`, `vw`, `scheme` from the URL. Acceptable; test via LiveViewTest and properties. Start Muex floors for `Cast` and `URLState` here. |
| 4 | Canvas fidelity | 2, 3 | **Split (about 6 plans)** | iframe + grid decision (A1), token topic + log, containment panel, CSP, diagnostics (reuse Doctor rules), hot reload, static canvas, Globals incl. frames and motion modes (A3), complete `hosts/operator` + E2E. Add the installer core here (it makes the hosts real and proves the day-0 gate). |
| 5 | Workbench UX | 2 to 4 | **Split into 3 and reorder content** | Roughly 10 plans. It also consumes inputs from later phases: **To review** (proposals, stale canon: Phase 6; findings without verdict: Phase 7), **Compare** by theme/direction (Phase 6) and by revision (Phase 7 Baselines), **Diagnostics** evidence staleness (Phase 7), **A11Y-02** "chrome passes its own sweep" (needs the Phase 7 probe), Journeys group (Phase 6 data). Ship Compare for Globals only, To review/Diagnostics with the panels that exist, and register the rest through the `Panel` behaviour when their data lands. Introduce PERF-02/03/04 gates here, not Phase 11. |
| 6 | Design canon | 2, 5 | **Split into 3 to 4** | Parser, kinds, layers, DTCG, resolver, abracabrand read, Themes + Guardrails, Directions, Foundations, citation existence, lints, contrast, coverage, journeys, DESIGN.md, `fablebook.tokens`, page embeds, **plus four human brand-book sessions and three twin apps**. The brand-book sessions are not code and should run as a parallel track that merges as content PRs. Twin Shell/Areas/Screens in `hosts/operator` is app-building and needs its own phase budget. |
| 7 | Probe, checks, visual regression | 4, 6 | **Split into 3** | Probe + Evidence + Checks tab + simulations; sweep + ratchet + verdicts + visual lanes + self-test; the UX checks batch + forced states + journey step checks. Add the Journey filmstrip UI here (B6). `Testing.generate_tests` should move earlier (see O-list). Forced pseudo-states without a mouse likely need CDP (`CSS.forcePseudoState`) or a stylesheet rewrite; research flag. |
| 8 | Motion lane | 4, 6 (motion tokens), 7 (Capture) | **OK as 5 plans if the spike is plan 1; split if the spike fails** | Dependencies are right. Pattern 6 may remove the need for canvas-side shim injection; verify in the spike. |
| 9 | LLM context bundles and skills | 2, 6, 7, 8 | **Split into 3; pull the no-browser tier forward** | Dependency-valid where it sits. Content: bundle core + redaction + schema + goldens; browser tier + allocator + contact sheets; ten focuses + skills + `gen.screens` + `llms.txt`. The no-browser tier needs only Render + Canon + Manifest and is the owner's primary motivation; leaving it until after the browser lane means the seam's `:bundle` purpose is unexercised through Phases 2 to 8. |
| 10 | Installer and DX | 1 to 9 | **Split into 3; installer core moves earlier** | Installer core (mount, `elixirc_paths`, `live_reload`, formatter, Book, welcome page, sample story) depends only on the router API and Book options, stable after Phase 4. `gen.story`/Doctor shell/migrator, then `shot` + export image + Credo check, then Docker demo + the 12 guides. The 12 guides should accumulate per phase (stubs) rather than be written at the end. |
| 11 | Hardening and full twin set | all | **Split into 2; move cross-cutting items earlier** | Telemetry catalogue and `Fablebook.Error` (Phase 2), Muex floors (from Phase 3), PERF-02/03/04 (Phase 5). What stays: bench/, leak test (if not earlier), sobelow, SBOM, API-surface snapshot, per-footgun regression tests (QA-05; each can also land with its feature). Finanza and Shopadelic are app-building; separate phase. |
| 12 | Dogfood setup | all | **OK in position, but too late for feedback** | Add an early real-host acceptance criterion (no new proof phase): during Phase 4 and 5, render ten real components from the mailglass demo (or accrue_admin) via hand-written stories. The owner's host upgrade to LiveView 1.2 (OPEN-QUESTIONS Q2) can run in parallel from day 1. |

### Ordering problems in detail

- **O1. Phases 1 and 2 are overloaded** (above). Minimum split: 1a (release, CI + caps, intent test, router macro + prod guard) and 1b (minimal Story + canvas slice, `hosts/vanilla` hand-wired, skeleton `hosts/operator`, LiveViewTest, visual check + baseline guards, runner spike); 2a (Story/Scenario/Book, Catalog/Id/fetch, ComponentInfo + contract, Unstoried, Error + Telemetry catalogue, `:page` kind) and 2b (seam with Slots/Contain/Normalize/modes, manifest + drift, Rules/Waiver/Draft, PERF-01, `Testing.generate_tests`).
- **O2. Cross-cutting foundations belong where first used**: `Fablebook.Error` and spans in Phase 2; containment with the seam; Muex floors from Phase 3; PERF-02/03/04 from Phase 5; the Doctor rule set with the canvas diagnostic in Phase 4.
- **O3. Phase 5 depends on later data.** Split by what exists: shell + sidebar + story page + grid; Inspector + toolbar + palette + keyboard; Mobile layout + microcopy + Globals-only Compare + Diagnostics (catalog and crash parts). Items needing canon or evidence ship in the phase that creates their data.
- **O4. Installer after its consumers.** Hand-wire `hosts/vanilla` in Phase 1b, then replace the hand wiring with real installer output when the core lands (after Phase 4) and add a golden that asserts the installed tree equals the hand-wired tree, so the two cannot drift.
- **O5. Bundles late.** Keep Phase 9's content, but land the no-browser tier immediately after the canon phase, and include `Normalize` plus a markup golden already in Phase 2b.
- **O6. Real-host validation last.** Fold real-component acceptance into Phase 4 and 5 plans.
- **Smaller:** `Testing.generate_tests` and `assert_manifest_current` need only Catalog + Render, so land them right after Phase 2b and every later phase gets per-Scenario tests on the host apps for free. A single owner for the `Globals` type (Phase 2b), codec (Phase 3), application in the canvas (Phase 4), and toolbar (Phase 5), instead of the same set appearing under CTRL-04, CORE-09 and CANVAS in three phases.

### Suggested re-cut (cut points only; the roadmapper owns the final structure)

```
1a Release, CI gate and caps, intent test, router + prod guard
1b Minimal canvas slice in hosts/vanilla + skeleton hosts/operator, LiveViewTest, visual guard, runner spike (criteria 1-8)
2a Story model, Catalog, ComponentInfo, Error + Telemetry catalogue, :page kind
2b Render seam (+Contain, Normalize, hash), manifest + drift, Rules/Waiver/Draft, PERF-01, Testing.generate_tests
3  Controls and URL state (+ Muex floors start)
4a Canvas: grid isolation spike and decision, token topic, event log, containment panel, CSP, Doctor rules, hot reload, static canvas
4b Globals (incl. frames, motion modes, A3 spike), complete hosts/operator, E2E fidelity, installer core, real-component acceptance
5a Chrome shell, sidebar, story page, grid, Panel behaviour, PERF-02/03/04
5b Inspector, toolbar, palette, keyboard map
5c Mobile layout, microcopy, chrome a11y (axe-less), Globals-only Compare, Diagnostics
6a Canon core: parser, kinds, layers, DTCG + resolver, abracabrand read
6b Foundations, Themes + Guardrails, Directions, citation existence + enforcement, Coverage UI, page embeds, To review (canon items)
6c Lints, contrast matrix, journeys declared, DESIGN.md, fablebook.tokens
6d (parallel track) brand books + first three twins
9a (pulled forward) Bundle no-browser tier, redaction, schema, goldens, Copy for LLM
7a Probe + Evidence + Checks tab + simulations (+ A11Y-02 dogfood)
7b Capture/Visual lanes, sweep, ratchet, verdicts, determinism self-test
7c UX checks, forced states, journey step checks, journey filmstrip, revision Compare
8  Motion lane
9b Browser tier, allocator, contact sheets
9c Ten focuses, skills, gen.screens, llms.txt
10a gen.story, Doctor shell, phoenix_storybook migrator
10b shot, export image, hardcoded-string Credo check
10c Docker demo, guides finalization
11a Hardening (bench, sobelow, SBOM, API snapshot, footgun tests)
11b Finanza and Shopadelic twins
12 Dogfood setup
```

That is about 27 phases at the 5-plan cap. ADR 0021 states "granularity fine (8 to 12 phases; the seed proposes 12)" and also "a phase that can't meet its gates splits". These two statements conflict once scope is counted; the non-negotiable is the split rule. The owner should confirm that the 8 to 12 guidance yields.

## Research flags for phases

| Phase | Flag | Why |
|---|---|---|
| 1b | Needs research (spike) | Runner criteria 7 and 8 (Mix-task use, dev-env availability); byte-identical captures in the pinned container |
| 2a | Needs research | `Application.spec` staleness in a long-running dev VM; `__components__/0` shape on the canary lane |
| 2b | Needs research | Normalize rules (CSRF, auto ids, `data-phx-*`) against real core components; behaviour for LiveComponent subjects (A2) |
| 4a | Needs research (spike) | Grid isolation (A1), native lazy canvases, duplicate-id behaviour |
| 4b | Needs research (spike) | CSSOM media-rule rewrite for dark and reduced motion (A3) |
| 5, 6 | Standard patterns | LiveView UI and parsers; property-testable |
| 7c | Needs research | Forcing `:hover`/`:focus-visible` without a mouse; layout-shift measurement during scripted load |
| 8 | Needs research (spike, already planned) | Time shim and `getAnimations()` seeking against real `JS` transitions and `time:` timers |
| 9 | Standard once Capture exists | Allocator is arithmetic; contact sheets need the browser tier |
| 10 | Standard | Igniter patterns are well documented; golden tests lock the output |

## Public module budget (<= 25 at 1.0)

Proposed public (documented) surface; everything else `@moduledoc false`.

| Public module | Why public |
|---|---|
| `Fablebook.Story` | Authors `use` it |
| `Fablebook.Book` | Adopter defines a Book |
| `Fablebook.Page` | Authors declare prose entries (if B2 is accepted) |
| `Fablebook.Router` | Host imports the macro |
| `Fablebook.Testing` | Adopter test API |
| `Fablebook.Test.Visual` | Adopter visual-baseline helper |
| `Fablebook.Bundle` | `validate/1` is documented |
| `Fablebook.Error` | Pattern-matched by type |
| `Fablebook.Telemetry` | `events/0` catalogue |
| 10 `Mix.Tasks.Fablebook.*` | ExDoc lists them |

That is 19 including tasks (9 without), leaving six spare. `Fablebook.Render`, `Fablebook.Catalog` and `Fablebook.Manifest` are better kept internal in 1.0: ADR 0022 does not require a public seam until export ships, and a public Catalog invites plugin-API pressure (ADR 0009).

## Sources

- LiveView `lib/phoenix_live_view/engine.ex`, `Phoenix.HTML.Safe` implementations for `Rendered` (renders with `dynamic.(false)`) and `Component` (raises `ArgumentError`). HIGH, primary source, fetched 2026-10-28.
- Phoenix LiveDashboard `lib/phoenix/live_dashboard/router.ex` (live_session, `session` MFA, `root_layout`, hashed asset routes, `csp_nonce_assign_key` normalization, no processes). HIGH, primary source.
- Storybook docs, main config indexers (index at `/index.json` built without rendering; story file imported on navigation). MEDIUM; the manager-to-preview channel was not confirmed from that page.
- Lookbook engine via gem.sh (Listen watcher over preview paths, reparse, cache clear, websocket reload broadcast). MEDIUM; iframe/layout rendering not confirmed in this pass.
- phoenix_test_playwright README (`only: :test`, `PhoenixTest.Playwright.Case`, supervisor in `test_helper.exs`, Playwright npm package under `assets/`, `server: true`; non-ExUnit use not documented). HIGH for what it states, LOW for the Mix-task question (absent evidence).
- Elixir Forum thread on being notified when modules are recompiled (no public bullet-proof hook; beam-digest and `:beam_lib.cmp_dirs/2` suggestions). MEDIUM as a statement that no simple hook is documented.
- React Cosmos: the repository README did not describe the renderer/UI split, so the "renderer seam" parallel in ADR 0022 is taken from the project's own research only. LOW.
- Project documents: PROJECT.md, NORTH-STAR.md, GLOSSARY.md, DOMAIN-MODEL.md, ADRs 0001 to 0025, `docs/research/{STACK-FACTS,LLM-CONTEXT-AND-CANON,QUALITY-PERF-SRE,UX-DESIGN}.md`, `.planning/intent/OPEN-QUESTIONS.md`. Treated as authoritative per CLAUDE.md precedence.

---
*Architecture research for: Fablebook (Storybook-style workbench for Phoenix LiveView)*
*Researched: 2026-10-28*
