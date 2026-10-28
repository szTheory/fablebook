# Pitfalls Research

**Domain:** Storybook-style workbench for Phoenix LiveView, shipped as a Hex library (Fablebook)
**Researched:** 2026-10-28
**Overall confidence:** HIGH for items marked "verified" (reproduced by experiment or read in primary docs/source), MEDIUM where reasoned from source reading, LOW where flagged.

> Scope note. `docs/research/LESSONS-LEARNED.md` already lists the incumbent's failures (phoenix_storybook CSS isolation, hook re-registration, string slots, CVE, CI cost) and `OWNER-DNA.md` lists the owner's velocity lessons. This file does **not** repeat them. It sanity-checks the locked ADRs against how the failure modes actually behave, and records new pitfalls, several of them **contradictions or gaps inside the locked decisions**. Those are collected in "Candidate OPEN-QUESTIONS entries" at the end, because precedence (intent > ADR > REQUIREMENTS > PROJECT) means research must not silently reinterpret an ADR.
>
> Phase numbers refer to the 12 phases in `PROJECT.md` "Roadmap constraints": 1 Walking skeleton, 2 Story model and catalog, 3 Controls and URL state, 4 Canvas fidelity, 5 Workbench UX, 6 Design canon, 7 Probe/checks/visual regression, 8 Motion lane, 9 LLM bundles and skills, 10 Installer and DX, 11 Hardening and full twin set, 12 Dogfood setup.

## Experiments run for this file (re-runnable, Elixir 1.19.5 / OTP 28, 2026-10-28)

| # | Question | Result |
|---|----------|--------|
| E1 | Does a router macro that `raise`s in its **body** survive being placed inside `if false do ... end`? | No. A raise at macro-expansion time fires even inside a false `if`. A `raise` emitted in the **returned quote** does not fire. (`Code.compile_string` of `if false do G.macro() end`.) |
| E2 | After an in-VM `Mix.Task.run("compile")` adds a new module, does `Application.spec(app, :modules)` list it? | No. The `.app` file on disk is regenerated and `Code.ensure_loaded?(NewMod)` is true, but the in-memory spec is stale until the app is reloaded (and `Application.unload` is refused for a running app). |
| E3 | What recompiles when a component module changes? | Body-only edit of module `A`: only the module that evaluates `A.meta()` at compile time recompiles. A module that `import A` recompiles only when `A`'s **exports** change (a function added or removed). A module that calls `A.a()` remotely never recompiles. `mix xref graph --label export` shows the import as an `export` edge. |

---

## Critical Pitfalls

### Pitfall 1: The prod guard raises at macro-expansion time and breaks every adopter's prod build
**What goes wrong:** ADR 0006 and SEC-02 say "the router macro raises a `CompileError` when `Mix.env() == :prod`", while the installer mounts the macro inside the host's `if Application.compile_env(:app, :dev_routes)` block. Macros inside a false `if` are still **expanded** (E1). If the `raise` lives in the macro body, every prod compile of every adopter fails, including adopters who did everything right.
**Why it happens:** "Macro raises" is ambiguous. Authors write `defmacro fablebook(...) do if Mix.env() == :prod, do: raise ... end` and test only the dev path.
**Consequences:** Hex 0.1.0 is unusable in prod builds. The ADR 0006 "documented only: [:dev, :test] recipe" would also be wrong in the other direction (undefined macro).
**Prevention:** Emit the guard in the code the macro **returns** (`quote do ... raise CompileError ... end`), so it runs only when the branch executes (when `dev_routes` is true in a prod build). Add two CI cases to the prod-guard build: (a) mount inside a false `dev_routes` block compiles cleanly in prod, (b) a deliberately unguarded mount raises with the canonical message. The ADR 0006 CI assertion ("no Fablebook routes, no story beams") covers only (a).
**Warning signs:** The operator host app's prod build is green only because its mount is not under a `dev_routes` `if`. Installer goldens never run `MIX_ENV=prod mix compile`.
**Phase:** 1 (router macro with prod guard). Confidence: HIGH (E1).

### Pitfall 2: Newly added stories never appear without a restart (stale `Application.spec`)
**What goes wrong:** ADR 0008 builds the catalog from `Application.spec(otp_app, :modules)`. After a code reload in dev, the in-memory app spec is not refreshed (E2), so a **new** story file compiles fine but is invisible until the VM restarts. Deleted stories can linger similarly. CANVAS-06 ("recompiling updates the open workbench without a restart") passes in the obvious test (edit an existing story) and fails in the common one (add a story).
**Why it happens:** `.app` is a loaded-application snapshot. Code reloading purges and reloads beams, not the application resource. The owner's own mailglass_admin discovery uses the same `get_key(app, :modules)` call, so the pattern looks proven.
**Consequences:** The headline "instant feedback" promise breaks on the first thing an evaluator does: add a story. Silent, no error.
**Prevention:** Discover from the compiled output, not the loaded spec: read the `.app` file from disk (`:code.lib_dir(app, :ebin)`) or list `*.beam` in that directory, filter by namespace prefix on the **binary** name before loading, then `Code.ensure_loaded?`. Keep it pure in the catalog function (ADR 0008) behind a tiny `Discovery` seam so tests can stub the module list. The contract test must **add a module in-test, recompile, and assert it appears and a deleted one disappears**.
**Warning signs:** Catalog tests only edit existing fixtures. The doctor reports a scenario count that differs from `mix fablebook.manifest`.
**Phase:** 2 (catalog) with the hot-reload test in 4 (CANVAS-06). Confidence: HIGH (E2).

### Pitfall 3: Compile-time coupling makes "touching one component recompiles one story" false in practice
**What goes wrong:** E3 shows three different dependency kinds. A story that evaluates `Subject.__components__()` in its `use` macro recompiles when that component's **body** changes (this is the intended single edge). But a story file that `import MyAppWeb.CoreComponents` (every generated story will) also recompiles whenever a function is **added or removed** in `CoreComponents`, for every story at once. Further coupling traps:
- The router macro taking the Book module at **compile time** puts Book (and transitively every story) into the router's compile graph. In Phoenix 1.8, `~p` sigils make most web modules depend on the router, so a story edit can recompile the web layer.
- Scenario functions that call fixture modules at compile time (module attributes, `@scenarios Fixtures.build()`).
- `@external_resource` on `design/` files inside the story macro: a canon edit recompiles all stories that cite it.
- Stories compiled in `:test` (`elixirc_paths`) multiply every `mix test` compile.
**Why it happens:** Elixir tracks compile, export and runtime edges differently; `PERF-05` is measured on a body edit and passes while real workflows (adding a component) storm.
**Consequences:** The same "adds about 1 minute to all CI runs" complaint (phoenix_storybook #250, #860) that Fablebook claims to fix.
**Prevention:**
1. `use Fablebook.Story` reads exactly one compile-time edge (its subject). Everything else (fixtures, canon, Book, router) is resolved at **runtime** (ADR 0002 scenario functions are already runtime; keep citations as data, existence checked at catalog build).
2. The router macro takes the Book as a literal alias and never `require`s or calls it at expansion.
3. Generated stories (`gen.story`, auto-stories, installer sample) use fully qualified calls or `import ..., only: [...]`, never a bare `import CoreComponents`. Verify with xref on `hosts/operator` rather than assuming `only:` narrows the edge.
4. Extend PERF-05 with a second row: **adding a function to `CoreComponents` recompiles at most N stories** (N reported, not necessarily 1). Gate `mix xref graph --label compile-connected --fail-above 0` from phase 1 on the library and on the host apps' story directories (ADR 0014 T0 already lists it for the library only).
**Warning signs:** `mix compile --verbose` after editing `core_components.ex` lists hundreds of story files. `xref graph --sink lib/<app>_web/router.ex --label compile` shows `storybook/*`.
**Phase:** 1 (xref gate, router macro shape), 2 (story macro), 11 (PERF-05 extension). Confidence: HIGH (E3), MEDIUM for the router transitive claim (reasoned from `~p`).

### Pitfall 4: The grid stacks all of a story's scenarios in one iframe, which breaks fixed positioning, viewport units, ids and crash isolation
**What goes wrong:** ADR 0003 renders "All scenarios" as a single document with lazy tiles. In one document: (a) a `position: fixed` modal or toast scenario covers every tile, (b) `100vh`/`dvh` Screens size to the iframe, not the tile, (c) two scenarios of the same component emit the same `id` (form ids, `aria-labelledby`, `phx-hook` elements, LiveComponent ids, stream containers), which LiveView requires to be unique, so hooks bind to the wrong tile and axe reports duplicate-id, (d) `:target`, focus, `<dialog>` top layer and `scrollIntoView` leak across tiles, (e) one LiveComponent crashing in `handle_event` kills the single canvas LiveView process, so CANVAS-03 ("other tiles keep rendering") cannot hold for runtime crashes. The dry-render guard only covers the first render.
**Why it happens:** A single document is cheap, and the failure only shows with Area/Screen tiers and stateful subjects. phoenix_storybook itself needed a `:variation_id` placeholder to derive unique ids.
**Consequences:** Screens (the product's differentiator) look wrong in the grid, and the grid and the single-scenario view disagree, so the owner stops trusting the grid.
**Prevention:** Decide the grid's contract explicitly before phase 4: either (1) **one iframe per tile**, lazily mounted, with a cap and the existing reversal trigger, or (2) tile = **static render only** (`render: :static` path, no process, no events) and "live" only in the single-scenario Playground. Option 2 satisfies CANVAS-03 and ADR 0003's budget with the least machinery. If tiles stay in one document, scope ids per scenario in the render seam and give Area/Screen tiles `contain: layout` plus `isolation`, and document that `fixed` and viewport units are approximated. Add a bomb-component test "LiveComponent raises in `handle_event`" to the CANVAS-03 spec, not only "raises in render".
**Warning signs:** Visual-core baselines for the grid differ from the single-scenario baselines of the same scenario. Duplicate-id findings appear only in grid mode.
**Phase:** 4 (canvas), with the render budget measured in 11. Confidence: MEDIUM-HIGH (reasoned from LiveView/DOM semantics; phoenix_storybook `:variation_id` documented).

### Pitfall 5: Canvas LiveView receives events and navigations it has no handler for (the "death spiral")
**What goes wrong:** Scenario markup contains `phx-click="save"`, `phx-submit`, `<.link navigate>`, `JS.push`, and LiveComponents with `phx-target={@myself}`. The canvas LiveView owns no `handle_event/3` for them. An unmatched event crashes the LiveView, the client reconnects, remounts, the user clicks again: the same loop phoenix_storybook #353 described as "a death spiral that was not reported in an obvious way". Links navigate the iframe away from the scenario (or fail across `live_session` boundaries), breaking the "reload reproduces it exactly" URL contract. Hosts migrated from Phoenix 1.7 may also carry `layout: {Layouts, :app}` in `use MyAppWeb, :live_view`, so Screens that already render the Shell get a second one.
**Prevention:** The canvas LiveView defines a catch-all `handle_event/3`, `handle_info/2` and `handle_params/3` that record the event (string name, truncated, ADR 0004) and no-op; it explicitly sets `layout: false` for the scenario render; navigation is intercepted (cancelable `phx:before-navigate` exists since LiveView 1.2.8; plain `href` links need a `click` guard) and surfaced as "Would navigate to /x" in the event log. Provide a stub-handler convention for `render: :live` stories that want real behaviour. Add bomb tests for unmatched event, `push_navigate`, `redirect` and a 1.7-style layout host.
**Warning signs:** Reconnect banner after any click. The event log is empty while the canvas flickers.
**Phase:** 4. Confidence: MEDIUM (LiveView semantics; #353 cited in LESSONS-LEARNED).

### Pitfall 6: Strict CSP blocks the chrome's and the host's inline `style` attributes, and the probe's injection path is undefined
**What goes wrong:** Verified in MDN: with `style-src` lacking `'unsafe-inline'`, inline `style="..."` attributes, `setAttribute('style', ...)` and `cssText` are blocked even when a nonce exists (nonces cover `<style>` elements, not attributes). Direct `el.style.prop = v` is **not** blocked. LiveView patches attributes through morphdom, so any server-rendered `style="width: 375px"` on the workbench iframe wrapper (viewport presets, zoom, resizable panes), and any host component that emits `style=`, is silently dropped under the operator host's strict nonce CSP. Separately, ADR 0003 says "no JS injected except the opt-in probe" without saying **how** a script gets into a strict-nonce document it does not control, and the Checks tab must run in the user's own browser (no Playwright).
**Prevention:**
- Chrome sizing via classes plus CSS custom properties set from a hook with `el.style.setProperty(...)` (CSSOM, allowed). Never emit `style=` from Fablebook templates. Lint it in Credo (custom check) from phase 1.
- Placement CSS ships as a nonce'd `<style>` (already in ADR 0003); add a `style-src-attr` note to the troubleshooting guide for host story markup that uses `style=`, and make the canvas diagnostic (CANVAS-05) report `securitypolicyviolation` events.
- Probe loading: from the parent, read the nonce off an existing `script[nonce]` in the same-origin canvas and create `<script nonce=... src=.../fablebook-probe-<md5>.js>`; in browser-runner mode inject via the runner (evaluate/init script) instead. Validate both under the operator host's CSP in the phase 1 spike, which already lists "axe injection under a strict nonce CSP" and "securitypolicyviolation listener" as criteria. Also verify `bypassCSP` is **not** needed (it is a context option defaulting to false in Playwright; using it would hide real CSP regressions the fidelity spec exists to catch).
**Warning signs:** Viewport presets do nothing only on the operator host. The probe works in the vanilla host and returns `not-run` on the operator host.
**Phase:** 1 (operator skeleton CSP + spike), 4 (chrome sizing), 7 (probe). Confidence: HIGH for the CSP semantics (MDN), MEDIUM for the nonce-reuse injection technique (reasoned; prove in the spike).

### Pitfall 7: Visual determinism environment: architecture, version drift and defaults looser than the ADR
**What goes wrong:**
- Baselines must be produced by the pinned Linux container (ADR 0011). A maintainer on Apple Silicon running `bin/visual update` gets an arm64 container (different Chromium build) or an emulated amd64 one (slow, crash-prone). Baselines then differ from CI's amd64 by anti-aliasing. Playwright's own docs warn rendering varies by OS, version and hardware.
- `phoenix_test_playwright`'s `assert_screenshot` defaults to `threshold: 0.2` and no `max_diff_pixels`; ADR 0011/QUALITY-PERF-SRE specify `0.1` and `0`. If the wrapper does not set both explicitly, the effective gate is looser than documented, which is quiet gate erosion.
- A missing baseline is saved and the test passes (documented behaviour); the ADR guards exist but must be tested against the actual wrapper, including the guard "baseline set equals manifest selection".
- The Playwright npm version, the container tag and the Elixir wrapper's expectation must match (the docs warn a mismatch yields "Executable doesn't exist"). Dependabot bumping one of them breaks the e2e job.
- Containers need `--ipc=host` (Chromium OOM otherwise) and `--init`; GitHub container jobs also change `HOME`, which breaks cache paths.
**Prevention:** One source of truth file for the Playwright version consumed by the container tag, the npm install and the Dependabot ignore rule, with a unit test asserting equality. `bin/visual update` forces `--platform linux/amd64` and refuses to run otherwise (print the exact reason); document the emulation slowness and prefer updating through a CI "update baselines" dispatch artifact that a human downloads and commits (still human-accepted, ADR 0011 intact). Wrapper `Fablebook.Test.Visual` sets `threshold` and `max_diff_pixels` itself and a test asserts the effective values. Run the determinism self-test (3 captures, identical hashes) on **both** the CI image and the maintainer path once, in the phase 1 spike, and record the result.
**Warning signs:** "Accept" commits that touch many unrelated baselines. Flake that disappears when re-run on CI but not locally.
**Phase:** 1 (spike and guards), 7 (lane). Confidence: HIGH for defaults and docs (phoenix_test_playwright docs, Playwright docs), MEDIUM for the Apple Silicon behaviour (secondary sources only; verify in spike).

### Pitfall 8: Capture readiness is wrong for LiveView, lazy tiles and iframes
**What goes wrong:** `data-fablebook-ready` is specified as "page-loading-stop, fonts ready, img decode, no `phx-*-loading`". Gaps:
- Dead render and connected render differ (hooks run, `phx-mounted` classes apply, `JS.hide` on mount). Capturing after the dead render but before `phx-connected` produces a baseline of the wrong state. Wait for the LiveSocket join, and for **each** nested LiveView/LiveComponent in the canvas.
- Lazy-rendered tiles (CANVAS-02) are blank until scrolled into view; a per-element `:selector` screenshot of an unrendered tile passes against a blank baseline. The ready attribute must be per tile, and capture must refuse tiles not rendered.
- `:selector` capture of content **inside** the workbench's iframe needs frame-scoped locators (phoenix_test_playwright documents only an `iframe >> internal:control=enter-frame` pattern). Capturing the canvas URL directly (not through the workbench) removes this class of problem and matches what the manifest-driven sweep already does.
- `animations: "disabled"` (the wrapper default) fast-forwards finite animations to their end, firing `transitionend`/`animationend` handlers; a host component that removes itself on `animationend` will be missing in the baseline although it is present for users. Keep ordinary visual diffs on this mode only for scenarios without `motion_tier` exits, and use the seeked filmstrip lane for the rest.
- Client clocks: server-side `frozen_now` does not freeze `Date`/`Intl` relative-time hooks in the browser; freeze them in the runner.
**Prevention:** Define the ready contract as a tested state machine (join complete, no pending `phx-*-loading`, fonts ready and checked per family, images decoded, tile rendered, no in-flight JS transition) and fail with `not-run` and the unmet condition instead of timing out silently. Add a bomb scenario for each gap above to `hosts/operator`.
**Warning signs:** Baselines differ by "flash of unstyled" or missing hook UI; blank grey tiles in contact sheets.
**Phase:** 4 (ready attribute), 7 (capture). Confidence: MEDIUM-HIGH.

### Pitfall 9: Evidence, render hashes and bundle goldens polluted by per-request randomness
**What goes wrong:** LLM-05 keys Evidence by render hash and LLM-07 demands byte-deterministic bundles and golden tests. Rendered markup contains per-request values: CSP nonces, CSRF tokens, `data-phx-session`/`data-phx-static` signed tokens, generated `phx-F...` ids, `?vsn=d` asset digests, `aria-labelledby` generated ids, timestamps. If the hash or the `markup`/`aria.yaml` golden includes them, every capture is "stale" and goldens flap, or (worse) the team widens a normalizer until it hides real change.
**Prevention:** One `Fablebook.Render.normalize/1` in the render seam (CORE-09), used by the hash, the goldens and redaction (SEC-04), with a property: two renders of the same scenario with different nonces/tokens normalize to identical bytes, and a mutation-proven test that a real attribute change **does** change the hash. Document the normalized field list. Keep the normalizer list closed and tested against LiveView version bumps on the canary lane (LiveView changes ids and tokens across minors).
**Warning signs:** Bundle goldens updated "because nonce". Evidence shows "stale" immediately after capture.
**Phase:** 2 (seam), 9 (bundles), 7 (Evidence). Confidence: MEDIUM-HIGH.

### Pitfall 10: Motion time shim can disconnect the canvas and fight LiveView's own timers
**What goes wrong:** Verified in LiveView source: JS commands use global `setTimeout(onEnd, time)` and double `requestAnimationFrame` (`js.js` transition paths), and the phoenix.js client uses timers for heartbeat, reconnect backoff, loading states and `phx-debounce`. A blanket shim that dilates all timers at 0.1x turns a 30 s heartbeat into 300 s, past the server's 60 s transport timeout, so the canvas disconnects mid-animation and remounts (losing the animated state). Pausing at t=0 while LiveView's `time:` timer still fires removes the transition classes, so the element jumps to its end state during scrubbing. Playwright's `animations: "disabled"` and seeked `getAnimations()` are separate mechanisms from timer control, so slowing animations without virtualising timers produces the "snap at 200 ms" bug MOTION-01 wants to avoid.
**Prevention:** Make the shim a small **virtual clock**: dilate only delays under a UI-scale cap (about 1000 ms) so heartbeats, reconnects and long debounces keep real time; queue dilated timers so pausing really pauses `time:` callbacks; set `playbackRate` on animations from `transitionrun`/`animationstart` for animations created after the shim. Install it from the **parent realm** onto the child window (assign functions to `contentWindow.setTimeout`/`requestAnimationFrame`) rather than injecting script text, which avoids CSP entirely and works because LiveView resolves the globals at call time. Extend the phase 8 opening spike criteria with: heartbeat survives 60 s at 0.1x; pause then resume completes a `JS.show` with `time:` exactly once; reduced `blocking: true` transitions do not wedge patches.
**Warning signs:** Slow-motion works for the first 30 s then the canvas flashes. Scrubbing a modal leaves it half-visible after release.
**Phase:** 8 (spike first, as already planned). Confidence: MEDIUM-HIGH (source read; timer arithmetic is deterministic; Phoenix default transport timeout recalled, verify in spike).

### Pitfall 11: "Globals" that map to browser media features cannot be switched from page script, so the workbench can show a false pass
**What goes wrong:** Reduced motion, color scheme, forced colors, `hover`/`pointer` and `prefers-contrast` are media features. Page JavaScript in the iframe cannot change them; only the browser runner (real emulation) can. ADR 0025's `[data-motion=reduce]` variant only affects Tailwind classes that opt in, and the installer is supposed to add it. A host's hand-written `@media (prefers-reduced-motion: reduce)` CSS, JS `matchMedia` checks, and Tailwind's default `dark:` (media-based unless the host defined a class/attribute variant) will **not** respond. The toolbar says "Reduce" and the check "nothing moves under reduced motion" may report a pass for a canvas that still animates. UX-01's forced hover/active needs the same honesty: there is no JavaScript API to force real pseudo-classes, which is why Storybook's pseudo-states addon rewrites stylesheets to add class selectors; it cannot render user-agent default styles and has to cope with nested `@media`/`@layer` rules.
**Prevention:** Treat the interactive globals as **approximations** and label them so ("Simulated: affects classes that opt in"). Only the browser-runner lane may produce a `pass` for reduced-motion, forced-colors and hover checks; in the in-browser Checks tab they report `not-run` or `unknown` (Honesty constraint). Make the color-scheme strategy a Book option (`:class`, `:data_attribute`, `:media_only`) with `:media_only` shown as "not switchable here". For forced states, ship the stylesheet-rewrite technique only if a spike shows it handles Tailwind v4 output (`@media (hover:hover)`, `@layer`, `:is()`); otherwise force states in the runner via DevTools-level pseudo-state emulation and make the in-browser path say so. Record the divergence in the CHECK-02 claim ("finds exactly what CI finds" cannot be literally true).
**Phase:** 4 (globals semantics), 7 (forced states, simulations), 8 (motion). Confidence: HIGH for the platform limitation, MEDIUM for specific host breakage.

### Pitfall 12: Atom and eval bans that cover the obvious functions but not the real leak paths
**What goes wrong:** ADR 0004's Credo list (`String.to_atom`, `List.to_atom`, `Code.eval_*`, `:erlang.binary_to_term`, ...) misses the paths a catalog/URL tool actually uses: `Module.concat/1,2` or `Module.safe_concat` on URL segments to find a story, `:"#{x}"` atom interpolation, `:erlang.binary_to_atom/2`, `:erlang.list_to_atom/1`, `String.to_existing_atom/1` (safe for the atom table but lets a user name any loaded module or function), and `apply/3` where the module or function comes from a query parameter (arbitrary zero-arity function call on any loaded module, such as story-id to scenario-function dispatch). Hand-written parsers add a different class: PCRE backtracking in the fuzzy scorer and the Markdown subset renderer (ReDoS), and `javascript:` URLs or raw-HTML passthrough in Markdown links and images.
**Prevention:** Resolve URL ids through a **map built by the catalog** (`%{id => {module, fun}}`), never through construction. Extend the Credo bans to the list above with a single allowlist-by-construction rule (none in 1.0), ban non-literal `apply/3`, and add the XSS corpus (`javascript:`, `data:`, nested `<`, attribute breakouts) as a StreamData property on the Markdown subset and on description rendering. Write the fuzzy scorer and Markdown subset with binary pattern matching, not regexes. The atom-count property must run in a **fresh process after warm-up** (as QUALITY-PERF-SRE says) and also drive the real LiveView `handle_params` path, not only `Cast`.
**Warning signs:** `Module.concat` anywhere in `lib/fablebook/catalog`. A route that accepts `:scenario` and calls `apply`.
**Phase:** 1 (Credo bans land with the skeleton so phase 2 catalog code cannot violate them), 2 (id lookup), 3 (properties and mutation-proven tests), 6 (Markdown and frontmatter parsers). Confidence: HIGH that these paths exist; MEDIUM on exact exploitability.

### Pitfall 13: Strict-by-default turns into global-off by volume (waivers and Draft), and into a day-0 cliff
**What goes wrong:** CORE-12 forbids a global off switch but allows per-scenario Waivers and a Draft status that downgrades errors to warnings. An LLM agent (the third decisive persona) under CI pressure will waive or mark Draft in bulk; counts being "visible" does not stop it. Conversely, an evaluator who runs the installer and `mix fablebook.doctor --ci` or `generate_tests` sees red from rule violations in auto-stories and the sample story, contradicting the INST-05 "aha in 5 minutes" promise. The owner's own history ("a rewritten guard hides a regression better than no guard", sigra v1.47) is the same mechanism.
**Prevention:**
- Waivers and Draft get a ratchet: counts may only shrink on `main`; every waiver carries a reason, an owner-visible review date, and a minimum reason length; a bulk-added waiver (more than N in one PR) fails the gate unless an INT-citing DECISION exists (ADR 0021 mechanism).
- Draft has an expiry and appears in To review; Draft stories do not count toward Coverage "covered".
- Day-0 contract: `Unstoried` auto-stories, the installer sample story and `generate_tests` for a fresh install must pass strict mode with **zero waivers** (golden test in the clean-room consumer, QA-03); anything stricter that a fresh adopter would fail starts as a finding in To review, not a failing test, until the adopter opts in per rule family.
**Warning signs:** `waiver` count grows monotonically; a PR touches 30 files adding `waive:`; the clean-room install spec needs `--draft`.
**Phase:** 2 (rules engine), 6 (canon lints), 7 (generated tests), 10 (installer/clean-room). Confidence: MEDIUM-HIGH (derived from OWNER-DNA failure history and the spec).

### Pitfall 14: Several phases, as written, exceed the 5-plan / ~3-day rule and invite gate-lowering
**What goes wrong:** PROJECT.md says "split any phase that would need more than 5 plans; never compress one". Counting independent deliverables in the roadmap constraints:
- **Phase 1** carries bootstrap + 0.1.0 publish + CI + intent test + router/prod guard + story render + operator skeleton (nested mount, strict CSP, fonts) + LiveViewTest + visual check with baseline guards + a two-runner spike. At least 6-7 plans.
- **Phase 5** (chrome tokens, grid/docs, inspector, palette, keyboard map, toolbar, Compare, To review, Mobile layout, microcopy, a11y, Diagnostics) is 12+ items.
- **Phase 6** (parser, canon kinds, layers, DTCG, abracabrand, Themes, Directions, Foundations, citation checks, lints, contrast, coverage, journeys, DESIGN.md, tokens task, three brand books through a two-session external process) is the largest.
- **Phase 7, 9, 10** each bundle 8-12 deliverables (10 includes Igniter, doctor, migrator, shot, Credo check, Docker, 12 guides, generator convention).
- **Phase 12** is mostly other repos (upgrading mailglass and accrue_admin to LiveView 1.2 and migrating): its "merged green PR to main of this repo" evidence does not exist as written.
**Prevention:** Pre-split before planning: 1a/1b (skeleton+publish+CI, then operator skeleton+spike), 5a/5b/5c, 6a (parser+kinds+layers+DTCG), 6b (themes/directions/foundations), 6c (lints/coverage/journeys), 6d (brand books), 7a/7b, 9a/9b, 10a/10b/10c. Put the three abracabrand brand books and the 12 guides into their own phases because their cadence is human/external. Phase 12 needs per-repo PRs as its evidence, and the upgrade PRs should start in parallel earlier (see Pitfall 18).
**Warning signs:** A phase plan lists more than 5 plan files; "temporarily relax" appears in a plan; a threshold changes in the same commit as a feature.
**Phase:** Roadmap creation itself. Confidence: HIGH that these exceed the cap; exact split is a roadmapper judgment.

### Pitfall 15: The "contract test is never edited in the same PR" rule is under-specified and will be either violated or paralyse changes
**What goes wrong:** The rule (CLAUDE.md, ADR 0014/0021) is correct for behavioural contracts, but Fablebook also has a large class of **recorded outputs** that legitimately change with implementation: goldens (bundles, manifest, JSON Schema), API-surface snapshot, Muex floors, committed `priv/static` drift, error-message snapshots, and baselines. Without a definition, agents either edit them with the feature (breaking the rule's intent) or split trivial changes into artificial two-PR chains (ceremony, the exact thing ADR 0021 forbids).
**Prevention:** Define in ADR-adjacent docs two kinds: **contract tests** (assert behaviour/invariants: `ComponentInfo`, prod guard, never-eval, id injectivity) which change only in a PR that touches no `lib/`; and **recorded outputs** (goldens, snapshots, baselines, floors) which change in the same PR but require a CHANGELOG/DECISION note and a human-readable diff summary job. A CI check enforces the first kind mechanically (path-based PR check: if `test/contract/**` changed, `lib/**` must not have).
**Phase:** 1 (CI + contributing rules). Confidence: HIGH that the ambiguity exists.

### Pitfall 16: `phoenix_live_view ~> 1.2.9` blocks adopters on the next LiveView minor (the incumbent's "tight pins" footgun)
**What goes wrong:** `~> 1.2.9` means `>= 1.2.9 and < 1.3.0`. When LiveView 1.3 ships (changelog currently empty), adopters cannot resolve until Fablebook publishes a release, exactly the "breaks on every Phoenix/LiveView minor" complaint. The same applies to `phoenix ~> 1.8.16` and a hypothetical 1.9.
**Prevention:** Declare `">= 1.2.9 and < 2.0.0"` (and the Phoenix equivalent), and let the **canary lane** (LiveView main) plus the `ComponentInfo` contract test be the compatibility mechanism; document support as "tested up to" in the compatibility matrix (DOCS-03). This stays compatible with COMPAT-01's floor lockfile. Needs an ADR amendment, not a silent change, because ADR 0018 states `~>`.
**Phase:** 1 (mix.exs), 11 (matrix). Confidence: HIGH on `~>` semantics; the policy choice is the owner's.

### Pitfall 17: `__components__/0` is a moving, undocumented contract with specific blind spots
**What goes wrong:** Beyond "sorted by name" (already known), source reading of `declarative.ex` (LiveView 1.2.13 checkout) shows:
- The map is generated only for modules that `use Phoenix.Component` **and** only for functions with `attr`/`slot` declarations; `defp` components, LiveComponents (no `attr` support), `embed_templates` components (the compiler has dedicated warnings about attr ordering around them), and components built by macros are absent or partial.
- `opts[:default]` is `Macro.escape`d into the function head, so defaults are evaluated values; slot attrs forbid `:default`; global attrs carry `include:`; 1.2.0-rc.1 changed the **global attribute list** (breaking), which changes what `rest` accepts and what an Unstoried default can safely render.
- `line` is the declaration line in the file where the macro ran; attrs declared via a `__using__`-injected block all share the macro's line, so "re-sort by `line`" is not a total order.
- `required` slots default to `[]`, `required: false` slots get empty defaults; "Needs a story" must not treat those as filled.
**Prevention:** `Fablebook.ComponentInfo` contract test, on all three lanes, asserts a fixture module covering: multi-line attrs, an attr group from a macro, an `embed_templates` component, a `:global` with `include:`, a slot with attrs, an attr with `values:`/`examples:`/`default:` of struct and list types, a required slot. The adapter returns a normalized struct, **not** the raw map, and has a total order fallback (`{line, name}`). Fault-injection test: the adapter fed an unexpected shape yields the "manual controls + banner" fallback, never a crash (ADR 0008 states it; no test exists in the plan).
**Phase:** 2. Confidence: HIGH (source read).

### Pitfall 18: The 14-day dogfood soak starts last, so any red resets the clock at the end of the schedule
**What goes wrong:** CLEARANCE C6 and C8 require 14 days of no flake and no red, and C1/C4/C5 need migrations in other repos. Phase 12 starts after everything else and the soak window follows. Each Fablebook-caused red resets the 14 days, and the dogfood repos are on LiveView 1.1.x (OPEN-QUESTIONS Q2; several local owner repos still resolve 1.1.28-1.1.33), so the upgrade is also on the critical path. Findings from real adoption (config sprawl, CSP, root-layout side effects) arrive when the architecture is least changeable.
**Prevention:** Start LiveView 1.2 upgrade PRs in the dogfood repos in parallel from phase 2, cut a 0.x release at the end of phase 4 and install it in one dogfood repo (read-only canvas smoke), and again after phase 7 (nightly sweeps). Phase 12 then becomes "wire CI and migrate", and the soak clock starts earlier. Keep the nightly visual self-test running on `main` from phase 7 so C6's 14 days accumulate during later phases.
**Phase:** 2 (upgrade PRs start), 4 and 7 (early dogfood), 12. Confidence: MEDIUM (schedule reasoning; version evidence from local deps).

---

## Moderate Pitfalls

### Pitfall 19: Changing the canvas iframe `src` through LiveView pollutes browser history
**What goes wrong:** Each `src` change adds a joint-session-history entry (a known long-standing issue, whatwg/html #6501), so selecting scenarios fills the Back stack and "Back" no longer returns from the workbench's previous URL, undermining CTRL-03.
**Prevention:** Keep the iframe wrapper under `phx-update="ignore"` with a hook that calls `contentWindow.location.replace(src)`, or remove/re-insert a keyed iframe; test with Playwright `goBack`. The workbench URL (not the iframe) is the history entry.
**Phase:** 4/5. Confidence: HIGH (ElixirForum thread and the cited spec issue).

### Pitfall 20: Live reload runs in both documents; hardening headers can silently block the canvas
**What goes wrong:** `phoenix_live_reload` injects its own hidden frame into every HTML response, so the workbench and each canvas iframe both reload on a file change (its `target_window` defaults to `:parent`, so the frame reloads the document that contains it, which is right here but doubles the reload work in Compare mode). Hosts that fixed Sobelow warnings may have `X-Frame-Options: DENY` or `frame-ancestors 'none'`, which Phoenix 1.8's default (`frame-ancestors 'self'`) does not set; the canvas goes blank.
**Prevention:** Let the canvas pipeline override framing headers in dev only and report the cause via CANVAS-05; cap Compare at a small number of canvases; verify one reload per document in the E2E spec. Phase 4. Confidence: MEDIUM-HIGH.

### Pitfall 21: The iframe `sandbox` attribute with `allow-scripts allow-same-origin` provides no isolation
**What goes wrong:** MDN states that for same-origin content this combination lets the document remove its own sandbox ("no more secure than not using the sandbox attribute"). The checklist in QUALITY-PERF-SRE lists it as a security control. It also costs capabilities (no modals/popups/downloads unless added).
**Prevention:** Do not claim isolation from it. Treat the real controls as: no eval, signed topic, localhost-only editor, dev-only mount, CSP. Either drop the attribute or document it as defense-in-depth that blocks nothing relevant; test host scenarios that call `window.open`/`alert`/download. Phase 4 and the security guide. Confidence: HIGH.

### Pitfall 22: Socket-only data structures make Areas and Screens impossible to author with public APIs
**What goes wrong:** Real Screens depend on `@streams.x`, `@uploads.x`, `AsyncResult`, `to_form`, `current_scope`. Streams and uploads are normally created by socket functions; constructing the underlying structs by hand uses `@doc false` internals, contradicting "public LiveView APIs only" (ADR 0007). Authors will then give up and use LiveView subjects (Waiver-only), eroding the Screen tier.
**Prevention:** Ship a documented fixture helper that builds these through the public socket functions on a bare `%Phoenix.LiveView.Socket{}` and extracts assigns, tested on the three lanes; prove it with the operator host's streams/async/forms Screen. Phase 4 (operator completion) and 10 (convention). Confidence: MEDIUM.

### Pitfall 23: LiveView JS motion lints that look static but need computed style
**What goes wrong:** MOTION-04 ("`JS` `time:` must equal the CSS duration") cannot be decided from HEEx alone: the duration comes from Tailwind classes resolved by the host's CSS. A static Elixir lint will either guess from class names (wrong for custom tokens) or silently not check. Related platform facts from the 1.2.x changelog: zero-duration JS transitions were only fixed in 1.2.10, `phx-remove` cascades on navigation got an opt-out in 1.2.10, and the View Transitions `onDocumentPatch` hook must call `start` in order (documented in 1.2.13), so host apps using view transitions change the animation behaviour Fablebook observes.
**Prevention:** Implement `time` vs duration as a **probe check** that reads the `phx-click`/`phx-mounted` JS command JSON from the DOM and applies the transition classes against the computed style; in the no-browser path report `not-run`. Pin the floor behaviour with a LiveView-version-keyed motion fixture on the canary lane. Phase 8. Confidence: MEDIUM-HIGH.

### Pitfall 24: Igniter installer idempotency, shape variance and golden-only coverage
**What goes wrong:** Installers that pass `Igniter.Test` golden diffs on `phx.new` output still fail on: a router that already has `dev_routes` in a slightly different shape (older generator, hand-edited, no `if` at all), umbrella apps, multiple routers, a second run, an app with an existing `/dev` scope using different pipelines, and a host that already pipes `:browser` with a non-default root layout. String-matching on router source (instead of AST via Igniter's router helpers) duplicates scopes on the second run. `igniter` is optional: a `use Igniter.Mix.Task` module compiled without Igniter present fails the `--no-optional-deps` lane unless wrapped in the documented `Code.ensure_loaded?(Igniter)` pattern with a plain Mix fallback task.
**Prevention:** For every patch, write the test pair "apply twice -> second run `assert_unchanged`" and "pre-existing partial state". Cases to cover explicitly: no `dev_routes`, `dev_routes` present with other contents, two routers, umbrella, Book already defined, `.formatter.exs` already importing the dep. Emit notices instead of editing when shape is unrecognised (consistent with "never touches `app.js` or Tailwind config"). Add `MIX_ENV=prod mix compile` to the golden suite (Pitfall 1). Because the installer lands in phase 10 but the mount shape is decided in phase 1, run a throwaway installer spike at the end of phase 4 against `hosts/vanilla` so shape surprises appear before Docs and Doctor are built. Phase 10 (spike in 4). Confidence: MEDIUM (generic Igniter patterns; the Igniter docs fetched did not document idempotency rules, so rely on tests, not on assumptions).

### Pitfall 25: Spec conflicts inside INST/MOTION: the installer "never touches the Tailwind config" but must add the reduced-motion variant
**What goes wrong:** INST-01 and ADR 0019 say the installer never touches `app.js` or the Tailwind config. MOTION-06 and ADR 0025 say the installer adds the reduced-motion custom variant and the doctor checks for it. In Tailwind v4 the variant lives in `app.css`, which *is* the Tailwind configuration.
**Prevention:** Decide before phase 8: either the installer prints a copy-paste snippet and the doctor verifies it (consistent with INST-01), or INST-01 is amended for `app.css` only. See candidate OPEN-QUESTIONS below. Phase 8/10. Confidence: HIGH that the conflict exists.

### Pitfall 26: Hex packaging mistakes specific to this package
**What goes wrong and prevention:**
- **First publish is nearly irreversible.** Hex allows reverting or updating a *new package* within 24 hours and a new version of an existing package within 1 hour (docs are always updatable). Phase 1 publishes 0.1.0 to reserve the name; inspect `mix hex.build --unpack` output before the publish approval, because the 24-hour window is the only recovery.
- **Allowlist drift:** Hex's default `files` pulls whatever is in `lib`, `priv`, etc.; `hosts/`, `test/__screenshots__/`, `design/`, `storybook/`, vendored fixtures and demo assets must not ship. The planned tarball allowlist test must assert the **exact file list**, not only the absence of known directories, and include `priv/static/LICENSES`. Size limits are 8 MB compressed / 64 MB uncompressed; axe-core plus fonts plus heroicons subset stay far below, but a stray screenshot directory would not.
- **Optional dependencies:** `igniter`, `earmark`, `phoenix_test_playwright` must be `optional: true` and only referenced through `Code.ensure_loaded?` gateways; verify `mix hex.build` metadata lists them as optional and the clean-room consumer compiles with none installed.
- **Docs `source_ref`:** tag must exist before publish (ADR 0017); `groups_for_extras` first-match regex ordering; troubleshooting headings equal the canonical error strings, so renaming an error silently breaks doc anchors (assert in a test).
- **Vendored MPL-2.0 axe-core:** ship the NOTICE and a version stamp in `priv/static/LICENSES`; add a test that the vendored file hash matches the recorded upstream version.
- **Chrome CSS drift check:** the committed Tailwind build must be reproducible on Linux CI and maintainer macOS; pin the standalone `tailwind` version and run the drift check on CI only, with a documented `mix assets.build` path that matches.
- **`.formatter.exs` exports** (`locals_without_parens` for the router macro and story DSL) must be in the package, or `mix format` rewrites adopters' router calls with parentheses.
- **Tooling commits trigger phantom release-please releases** (mailglass history): configure `exclude-paths` for `hosts/`, `bench/`, `.planning/`.
**Phase:** 1 (publish, allowlist), 10 (formatter exports, docs), 11 (SBOM, API snapshot). Confidence: HIGH for limits and revert windows (Hex docs), MEDIUM for the rest.

### Pitfall 27: CI regrows even with a 250-line cap, and the 7-minute budget is not enforced
**What goes wrong:** Caps tests measure line count and workflow count, so complexity migrates into composite actions, `scripts/`, Makefile-like mix aliases and matrix expansion without tripping them (the oarlock Node-proof-script pattern). The PR p50 ≤ 7 min target is "measured from CI history, not asserted by a test" (QUALITY-PERF-SRE), so erosion is invisible until it hurts. The `ci-gate` "skipped counts as failure" rule also breaks legitimately skipped jobs (fork PRs, release-only jobs) unless explicitly modelled. The e2e job (pinned container + operator host + visual-core + Playwright npm install) is the likeliest single job to exceed budget.
**Prevention:** Add a weekly job in the nightly workflow that computes PR p50/p95 from `gh run list` and updates the single `quality-regression` issue when over budget; extend the caps test to also cap total lines of `.github/actions/**` and forbid `scripts/*.js`/`*.cjs` outside E2E; model conditional jobs in `ci-gate` with an explicit allowlist (`skipped` allowed only for jobs listed with a reason). Cache the Playwright browser by the single version file (Pitfall 7) and the colocated-hooks build output. Order jobs without serialising `needs:` (the sigra measured biggest win). Phase 1 (gate), 7 (e2e), ongoing. Confidence: MEDIUM-HIGH (owner history).

### Pitfall 28: Performance gates become flaky or silently re-based
**What goes wrong:** Reductions-based gates (1.25x a committed reference) vary with Elixir/OTP minor, LiveView version and the diff format (LiveView 1.2 changed rendered diffs), so floor, latest and canary lanes cannot share one reference. WebSocket diff bytes include first-render fingerprints. `t(5000)/t(500) < 15` is sensitive to GC and shared-runner noise. Re-basing the reference on failure is the easiest way to "fix" CI, and equals lowering a gate.
**Prevention:** Gate only on the pinned lane (keyed by OTP major as ADR 0015 says, plus LiveView version in the key); canary/floor lanes report, never gate. A reference change requires a DECISION entry and a comment-free commit that touches only the reference file, with the CI summary printing old and new values. Keep the sensitivity controls in `bench/` (ADR 0015) and also run them as tests of the gates (a deliberately 1.5x slower fixture must fail the reductions gate). Phase 2, 11. Confidence: MEDIUM-HIGH.

### Pitfall 29: Checks "needs no Node" but the capture/probe stack does, and the phoenix_test_playwright path requires JS tooling
**What goes wrong:** phoenix_test_playwright requires installing Playwright from npm/pnpm in an assets directory and downloading browsers; Playwright's JS version pins the browser. That contradicts "adopters never need Node" only if it leaks beyond opt-in features. The leak points: the doctor, `mix fablebook.shot`, `--browser` bundles, the sweep and the Docker demo.
**Prevention:** Every opt-in browser feature prints one canonical "needs Playwright (opt-in), here is how" message and returns `not-run`, never a stack trace; the clean-room consumer spec runs with Node absent from `PATH`; the Docker demo bakes Playwright in the image so nothing is installed on the user's machine. Phase 7, 9, 10. Confidence: HIGH (phoenix_test_playwright README).

### Pitfall 30: Unbudgeted vendored code (QR encoder, DTCG resolver, contrast maths)
**What goes wrong:** WB-07 requires a QR code, CANON-03 a DTCG 2025.10 resolver, A11Y-01 a contrast matrix. ADR 0018's vendored list does not include a QR encoder, and the banned list removes the usual shortcuts (jason, any YAML). A QR encoder with Reed-Solomon is several hundred lines of subtle code. Left undecided, an agent adds `eqrcode` or pastes unreviewed code.
**Prevention:** Decide in phase 5: a minimal, property-tested vendored QR encoder (byte mode, one error-correction level, version cap) with a decode round-trip test, or an ADR-justified dependency, or render the QR in the browser from a ~300-line vendored script. Also state that LAN access requires the dev endpoint to bind beyond loopback and `check_origin` to allow the LAN host; the "says plainly when it can't" microcopy needs those exact causes. Phase 5. Confidence: MEDIUM (reasoned).

---

## Minor Pitfalls

### Pitfall 31: Vocabulary leaks through generated and migrated artifacts
**What goes wrong:** `attr :variant` in host components, phoenix_storybook's own struct names in the migrator, and ExDoc text can reintroduce "variant"/"variation"/"sandbox" for scenario/canvas. **Prevention:** run the glossary lint (CANON-07) over Fablebook's own docs, error strings and generated stories from phase 2, with the Phoenix `attr :variant` exception handled by lint context, not by weakening the rule.

### Pitfall 32: Gettext locale and Intl live in different processes and documents
**What goes wrong:** The locale is per process (QUALITY-PERF-SRE); dry-render, canvas LiveView and client `Intl` each need it. **Prevention:** one `locale` global applied in all three places; the `intl` state class scenario asserts both server-formatted and client-formatted output differ under a non-English locale. Phase 4.

### Pitfall 33: `elixirc_paths` includes `storybook/` in `:test`, so story warnings break the host's `--warnings-as-errors`, Dialyzer and `mix test` compile time
**Prevention:** stories compile in dev and test as designed (ADR 0001), but the installer must also add `storybook/` to formatter inputs and document the Dialyzer and Credo implications; consider excluding stories from the host's Dialyzer path by default. Phase 10.

### Pitfall 34: Muex floors that "only go up" will flake or block releases for non-deterministic mutants
**Prevention:** pin seed and timeouts, treat timed-out mutants as survived with a recorded reason, and allow floor reductions only through a DECISION entry. Phase 11.

### Pitfall 35: Colocated hooks and Tailwind `@source` need ordering in CI
**What goes wrong:** Colocated hooks exist only after the esbuild step extracts them from compiled modules; if `assets.build` runs before the compile, or the cache restores a stale `phoenix-colocated` directory, the canvas works locally and fails in CI. **Prevention:** order `compile -> assets.build -> e2e` and key the cache on the source hash. Phase 1/4.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Discovering stories via `Application.spec` | One line, matches the owner's other tools | New stories invisible without restart (Pitfall 2) | Never |
| Rendering the whole grid in one document | Cheap, one socket | Wrong Screens, shared ids, shared crash (Pitfall 4) | Only if tiles are static-render |
| Widening visual `threshold` to fix flake | Green CI today | Gate erosion; contradicts ADR 0011 | Never; fix fonts/ready/environment |
| Re-basing perf references on failure | Unblocks PR | Silent gate lowering | Only with an INT-citing DECISION |
| Bulk `waive:`/Draft to pass strict checks | Fast green | Strict-by-default becomes nominal | Never in bulk; per-scenario with reason and review date |
| `import CoreComponents` in generated stories | Short story code | Compile storms when components are added | Never in generated code |
| Editing contract tests with the feature | One PR | Hidden regression (sigra v1.47) | Never; recorded outputs excepted by definition (Pitfall 15) |
| Copying oarlock's CI files | Faster start | Inherits PLT key bug and Node scripts | Never; build from the bootstrap skill description |
| Adding a runtime dep for QR/Markdown/YAML | Saves code | Violates ADR 0018; supply-chain surface | Only with an ADR |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Host root layout | Assuming it is side-effect free (analytics, consent scripts, Sentry) | `canvas_root_layout` override and doctor warning; do not execute analytics in dev canvases |
| Host strict CSP | Using `style=` attributes and injecting scripts without nonce | CSSOM property writes; nonce reuse from the parent or runner-side injection (Pitfall 6) |
| Phoenix 1.7-era LiveViews | `layout: {Layouts, :app}` in `use MyAppWeb, :live_view` doubles the Shell | Canvas LiveView sets `layout: false` (Pitfall 5) |
| `phoenix_live_reload` | Expecting a single reload target | One frame per document; verify one reload per document |
| Playwright container | Version drift between npm package and image tag; missing `--ipc=host`; `HOME` change in container jobs | Single version file, documented container flags, cache paths relative to `$GITHUB_WORKSPACE` |
| `phoenix_test_playwright` | Trusting its defaults (`threshold 0.2`, missing baseline passes) | Wrapper sets explicit values and CI guards (Pitfall 7) |
| abracabrand / DTCG | Writing back into `identity.json` or dropping `$extensions` | Read-only; round-trip test that `$extensions` survive |
| Hex / release-please | Tooling commits triggering releases | `exclude-paths`; tag before publish; inspect unpacked tarball for 0.1.0 |
| LiveView minors | Assuming `__components__` and JS internals are stable | One adapter plus contract tests on floor/latest/canary |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Loading every module in the host to find stories | Slow first mount in dev | Prefix-filter on binary names before `Code.ensure_loaded?`; scan `ebin` listing | Roughly several thousand modules |
| Per-tile iframes with a LiveSocket each | Dev server connection pressure, slow grid | Static tiles or a hard cap with virtualised mounting | More than ~12 live tiles |
| Compare mode with N canvases and N live-reload frames | N reloads per save | Cap N, share one reload signal | N >= 4 |
| Event log broadcasting every client event | PubSub and diff churn | Subscribe-only-when-open, truncated string payloads (ADR 0004) | High-frequency events (mousemove-like hooks) |
| Bundle contact sheets built from full-resolution PNGs | Memory and time blowups | Cap pixel budget in the allocator before decoding | More than ~20 images (LLM-03) |
| Ratio gates (`t(5000)/t(500)`) on noisy runners | Random red | Median of 5, pinned lane only | Shared GitHub runners |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Macro-time prod guard (Pitfall 1) | Prod build failures; tempting for adopters to disable the guard | Emit guard in generated code; two prod-build tests |
| URL id -> module via `Module.concat`, `String.to_existing_atom`, dynamic `apply` | Arbitrary function dispatch / atom growth | Catalog-built map; extended Credo bans (Pitfall 12) |
| `:live_view` subjects run inside the Fablebook session and bypass host `on_mount` auth | Auth bypass in dev | Waiver-only (ADR 0024), documented in the security guide (already in QUALITY-PERF-SRE checklist); also keep the mount `dev_routes`-only |
| Iframe `sandbox` treated as a control | False sense of isolation | Do not rely on it (Pitfall 21) |
| Markdown subset renders `javascript:` links or raw HTML | XSS in dev workbench | Allowlist schemes; escape by default; XSS corpus property |
| Bundle redaction missing nonces, session tokens, absolute home paths | Secrets and PII in LLM context and in git | Redact at the normalizer (Pitfall 9) plus a CI scan of golden bundles for `~/`-less absolute paths and token-shaped strings |
| Open-in-editor path checks done before symlink resolution | Path traversal | `realpath` then containment (ADR 0004) with a symlink escape test |
| `bypassCSP: true` in Playwright to make the probe work | Hides real CSP regressions the fidelity spec exists to catch | Inject via init script/evaluate or nonce reuse; keep strict CSP in the operator host |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Toolbar shows "Reduce" or "Dark" that the host ignores | User believes a state is verified | Label simulated globals; per-host strategy option (Pitfall 11) |
| Grid differs from the single-scenario view | Loss of trust | Same render path for both (Pitfall 4) |
| Reconnect banner after clicking a scenario button | Looks like Fablebook is broken | Catch-all handlers and "Event recorded" log (Pitfall 5) |
| Back button leaves the workbench unexpectedly | Navigation frustration | `location.replace` hook (Pitfall 19) |
| Strict red wall on first run | Evaluator bounces before the aha | Day-0 zero-waiver contract; findings go to To review (Pitfall 13) |
| Slow-motion works then the canvas disconnects | Motion lane distrusted | Virtual clock with a delay cap (Pitfall 10) |

## "Looks Done But Isn't" Checklist

- [ ] **Prod guard:** works when the mount is inside a false `dev_routes` block in a prod build (not only when it is absent).
- [ ] **Hot reload:** adding and deleting a story file shows up without restart (not only editing).
- [ ] **Canvas crash containment:** a LiveComponent raising in `handle_event` leaves other tiles alive (not only a render raise).
- [ ] **Fidelity spec:** passes under the operator host's strict nonce CSP with inline `style=` attributes and hooks present.
- [ ] **Visual lane:** effective `threshold`/`max_diff_pixels` asserted by test; baseline-set equals manifest; update path forces the pinned platform.
- [ ] **Ready attribute:** covers LiveSocket join, nested views, lazy tiles and per-family fonts.
- [ ] **Bundle goldens:** unchanged when only nonces and tokens differ; changed when a real attribute differs.
- [ ] **Motion shim:** heartbeat survives 60 s at 0.1x; pause stops `time:` timers; resume completes once.
- [ ] **Reduced-motion/hover/forced-colors checks:** `pass` only from the runner lane; `not-run` elsewhere.
- [ ] **Installer:** second run is a no-op; partial pre-existing state handled; prod compile of the result is green.
- [ ] **Hex tarball:** exact file list asserted; formatter exports present; optional deps optional; unpacked 0.1.0 inspected before publish.
- [ ] **Dependency version ranges:** allow LiveView 1.3 and Phoenix 1.9 resolution; canary proves it.
- [ ] **Waivers/Draft:** counts ratcheted; clean-room install passes strict with zero waivers.
- [ ] **PR p50:** computed from CI history weekly, not asserted.

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Macro-time prod guard shipped in 0.1.0 | MEDIUM | Within 24 h of first publish revert; otherwise publish 0.1.1 and retire 0.1.0 |
| Stale discovery shipped | LOW | Swap `Discovery` seam implementation; contract test already encodes expectation |
| Compile storm discovered late | HIGH | Re-generate stories without bare `import`; move any compile-time fixture/canon reads to runtime; add xref gate |
| Grid architecture wrong (one document) | HIGH | Switch tiles to static render (render seam already exists); keep one live Playground |
| Baselines produced on wrong platform | MEDIUM | Re-baseline in the pinned image in a dedicated PR that touches no `lib/` (already the rule for Playwright bumps) |
| Waiver/Draft inflation | MEDIUM | Introduce the ratchet, then burn down by tier with owner verdicts |
| Perf reference re-based incorrectly | LOW | Revert the reference commit; require DECISION |
| Phase overrun | MEDIUM | Stop at plan 5, split the remainder into a new phase; never relax gates |
| Soak reset at the end | HIGH | Start dogfood earlier next time; until then, fix and restart the clock explicitly |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| 1 Prod guard at expansion time | 1 | Prod build with mount inside false `dev_routes` is green; unguarded mount raises canonical message |
| 2 Stale `Application.spec` discovery | 2 (test in 4) | Contract test adds and deletes a story module and asserts the catalog changes |
| 3 Compile-time coupling | 1 (xref gate), 2, 11 | `xref --fail-above 0`; PERF-05 incl. "add a function" row; `mix compile --verbose` count on host |
| 4 Single-document grid | 4 | Same baselines for grid tile and single view; LiveComponent `handle_event` bomb |
| 5 Unhandled events/navigation | 4 | Click/navigate bomb tests; `layout: false` host case |
| 6 CSP: style attrs and injection path | 1 (skeleton + spike), 4, 7 | Operator-host spec asserts no `securitypolicyviolation`; probe loads under strict nonce CSP |
| 7 Visual environment and defaults | 1 (spike), 7 | Wrapper test of effective thresholds; determinism self-test on the maintainer path |
| 8 Capture readiness | 4, 7 | Bomb scenarios per gap; ready state machine unit tests |
| 9 Nondeterministic render hashes | 2, 7, 9 | Normalizer property and mutation-proven change detection |
| 10 Motion shim and timers | 8 (spike first) | 60 s heartbeat at 0.1x; pause/resume `JS.show` once |
| 11 Media-feature globals | 4, 7, 8 | `pass` only from runner lane; label tests |
| 12 Atom/eval leak paths | 1 (Credo), 2, 3, 6 | Extended Credo bans; atom-count property through `handle_params`; XSS corpus |
| 13 Waiver/Draft erosion, day-0 cliff | 2, 6, 7, 10 | Waiver ratchet test; clean-room zero-waiver strict run |
| 14 Oversized phases | Roadmap | No phase plan exceeds 5 plans; split list applied |
| 15 Contract-test rule definition | 1 | Path-based PR check; written definition |
| 16 Overtight version ranges | 1, 11 | Resolver test against LiveView 1.3-dev on canary |
| 17 `__components__` blind spots | 2 | Fixture covering embed_templates, macro attrs, globals, slots; fault-injection fallback |
| 18 Late soak | 2, 4, 7, 12 | Early 0.x installs in a dogfood repo; nightly self-test history from phase 7 |
| 19 Iframe history pollution | 4/5 | Playwright `goBack` spec |
| 20 Live reload / framing headers | 4 | One reload per document; header-override test |
| 21 Iframe sandbox attribute | 4 | Security guide wording; no reliance in code |
| 22 Socket-only data | 4, 10 | Streams/async/forms Screen in operator host |
| 23 Motion lints needing computed style | 8 | Probe-based check; `not-run` without browser |
| 24 Igniter idempotency | 10 (spike in 4) | Apply-twice and pre-existing-state goldens; prod compile of result |
| 25 INST vs MOTION Tailwind conflict | 8/10 (decide before 8) | Resolved OPEN-QUESTIONS entry |
| 26 Hex packaging | 1, 10, 11 | Exact tarball list test; unpacked 0.1.0 review; clean-room consumer |
| 27 CI regrowth, unenforced budget | 1, 7 | Weekly p50 job; actions-dir line cap |
| 28 Perf gate flake/re-basing | 2, 11 | Sensitivity-control tests; DECISION on reference change |
| 29 Node leakage | 7, 9, 10 | Clean-room spec with Node absent |
| 30 Unbudgeted vendored code | 5 | ADR or vendored-with-property-tests decision |
| 31-35 minor | as noted | as noted |

## Candidate OPEN-QUESTIONS entries (for the synthesizer to add; research did not edit intent or ADRs)

1. **ADR 0006 / SEC-02:** state that the prod guard is emitted in the macro's returned code, not raised during expansion (Pitfall 1).
2. **ADR 0008 / CANVAS-06:** discovery must not use the loaded `Application.spec`; specify disk `.app`/`ebin` listing (Pitfall 2).
3. **ADR 0003 vs CANVAS-03 / ADR 0025:** the stacked single-document grid cannot satisfy "other tiles keep rendering" for runtime crashes nor per-tile fixed/viewport behaviour; and "no JS injected except the probe" does not describe the motion time shim or how the probe gets a nonce (Pitfalls 4, 6, 10).
4. **INST-01 / ADR 0019 vs MOTION-06 / ADR 0025:** "never touches the Tailwind config" vs "installer adds the reduced-motion variant" (Pitfall 25).
5. **ADR 0018 version ranges:** `phoenix_live_view ~> 1.2.9` / `phoenix ~> 1.8.16` block the next minor; propose open upper bounds with a canary lane (Pitfall 16).
6. **VIS-01 / ADR 0011:** `phoenix_test_playwright` defaults (`threshold 0.2`, no `max_diff_pixels`) are looser than the documented 0.1/0; the wrapper must set them (Pitfall 7).
7. **CHECK-02 "finds exactly what CI finds":** cannot be literally true for media-feature and forced-state checks outside the runner (Pitfall 11).
8. **LLM-07 / LLM-05:** determinism requires a closed normalization list for nonces, tokens and generated ids (Pitfall 9).
9. **ADR 0014 / ADR 0021 "contract test" definition:** distinguish contract tests from recorded outputs (Pitfall 15).
10. **Roadmap:** phases 1, 5, 6, 7, 9, 10, 12 exceed the 5-plan cap as scoped; start dogfood installs earlier so the 14-day soak is not at the end (Pitfalls 14, 18).
11. **ADR 0018:** a QR encoder is needed for WB-07 and is not in the vendored list (Pitfall 30).

## Sources

**Primary (HIGH):**
- Experiments E1-E3 above (Elixir 1.19.5 / OTP 28, run 2026-10-28; scripts are 10-20 lines each and can be recreated from the table).
- LiveView 1.2.13 source and CHANGELOG (checkout in an owner repo's `deps/`): `lib/phoenix_component/declarative.ex` (`__components__`, `Macro.escape` of defaults), `assets/js/phoenix_live_view/js.js` (`setTimeout`, double `requestAnimationFrame` in transitions), CHANGELOG entries 1.2.0-rc.1 (global attrs), 1.2.8 (`phx:before-navigate` cancel), 1.2.10 (zero-duration transitions, `phx-remove` cascade opt-out, `navigation_type/2`), 1.2.13 (`onDocumentPatch` ordering).
- Phoenix 1.8 `controller.ex` (`put_secure_browser_headers` sets `base-uri 'self'; frame-ancestors 'self'`).
- `phoenix_live_reload` source and CHANGELOG (iframe injection, `target_window` default `:parent`).
- MDN, CSP `style-src` (https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Security-Policy/style-src): inline style attributes, `setAttribute('style')`, `cssText` blocked; direct `element.style.prop` allowed.
- MDN, `<iframe>` (https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/iframe): `allow-scripts` + `allow-same-origin` warning.
- Hex publish docs (https://hex.hexdocs.pm/Mix.Tasks.Hex.Publish.html): 8 MB compressed / 64 MB uncompressed; 24 h revert for new packages, 1 h for new versions.
- phoenix_test_playwright docs (https://phoenix-test-playwright.hexdocs.pm/readme.html and the `PhoenixTest.Playwright` module page): Playwright via npm/pnpm, browser pinned by Playwright JS version, `assert_screenshot` saves a missing baseline and passes, `threshold` default 0.2, `animations` default disabled, `browser_pools` concurrency advice, iframe selector pattern.
- Playwright Docker docs (https://playwright.dev/docs/docker): `--ipc=host`, `--init`, image tag must match the Playwright version. Playwright snapshot docs (https://playwright.dev/docs/test-snapshots): rendering varies by OS, version, hardware.
- Project files: `PROJECT.md`, ADRs 0003/0004/0005/0006/0008/0011/0014/0015/0017/0018/0019/0020/0021/0024/0025, `docs/research/LESSONS-LEARNED.md`, `QUALITY-PERF-SRE.md`, `STACK-FACTS.md`, `OWNER-DNA.md`, `MOTION-AND-UX-DIMENSIONS.md`, `CLEARANCE.md`.

**Secondary (MEDIUM):**
- ElixirForum, "Changing iframe src in LiveView adds to the page history" (https://elixirforum.com/t/changing-iframe-src-in-liveview-adds-to-the-page-history/41515), citing whatwg/html #6501.
- phoenix_storybook docs on iframe containers and the `:variation_id` placeholder for unique ids (https://hexdocs.pm/phoenix_storybook/components.html).
- Storybook pseudo-states addon README (stylesheet rewriting; no JavaScript API for real pseudo states) via https://storybook.js.org/addons/storybook-addon-pseudo-states.
- Secondary posts on Playwright images and Apple Silicon (arm64 vs emulated amd64); no primary source found, treat as to-verify in the phase 1 spike.

**Gaps (LOW, to confirm in phase-specific research):**
- Igniter idempotency rules: fetched docs did not cover them; rely on `Igniter.Test` apply-twice tests.
- Playwright `bypassCSP` + `addScriptTag` + nonce interaction: search returned nothing authoritative; settle in the phase 1 spike.
- Phoenix websocket transport server timeout (60 s default) and the exact interplay with a dilated heartbeat: confirm in the phase 8 spike.
- Whether `import M, only: [...]` narrows the export edge in current Elixir: confirm with `mix xref` on `hosts/operator`.

---
*Pitfalls research for: Storybook-style workbench for Phoenix LiveView (Fablebook)*
*Researched: 2026-10-28*
