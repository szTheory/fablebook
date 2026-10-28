# Quality, performance, SRE, security, CI

This is the staff-engineer synthesis. The decisions themselves are ADRs 0014–0017. This document holds the detail behind them: recipes, budgets and the gaps found when reviewing against ISO 25010. (INT-20261028-01, INT-20261028-04)

## Testing invariants (StreamData)
1. **Cast round-trip.** `cast(type, encode(type, v)) == {:ok, v}` holds for every control type: boolean, integer with range, `values:` enum, string, atom from declared values, list, map, datetime and color. For arbitrary binaries the result is `{:ok,_}` or `{:error, %Fablebook.Error{}}`. It never raises.
2. **URL state round-trip.** `decode(encode(s)) == s`, and the encoded form stays at or under 2 KB within the documented limits. Oversized input returns `:error`.
3. **Id stability and injectivity.** An id is a pure function of the module plus the declared name. It does not depend on declaration order, file path or N. Ids stay distinct after Unicode slugging and case folding.
4. **Manifest determinism.** Any permutation of the catalog produces byte-identical JSON.
5. **No new atoms, no eval.** Arbitrary params don't change `:erlang.system_info(:atom_count)`. The check runs in a fresh process with atoms pre-warmed. The Credo bans enforce the same thing statically.
6. **Bounded render.** Any generated control state either renders or returns a contained error within the time cap.
7. **Frontmatter round-trip.** Parsing then printing then parsing again is the identity, and inputs outside the YAML subset are rejected with a line and column.
8. **Contrast maths.** The ratio is symmetric, lies within [1, 21], and black on white is exactly 21.
9. **Telemetry metadata.** Only whitelisted keys ever appear.

## Crash containment
- The workbench and the canvas are separate documents and separate LiveView processes.
- **Dry render.** Before assigning, the scenario is rendered in `:erlang.spawn_opt` with `[:monitor, {:max_heap_size, %{size: N, kill: true}}]` and a `render_timeout` (default 2 s). Raise, throw, exit, timeout or heap overflow each produce an error panel showing `%Fablebook.Error{}`, a cleaned stacktrace and an editor link, plus an `[:fablebook, :canvas, :crash]` event.
- **Output cap.** Output over 1 MB is truncated with a notice.
- **Proof.** Bomb components cover raise, throw, exit, an infinite loop, a 10 MB string and a nested LiveComponent that crashes on update.

## Visual regression recipe (determinism)
- **Container.** The E2E job runs in `mcr.microsoft.com/playwright:vX.Y.Z-noble@sha256:…`, which pins the OS, fontconfig and Chromium. setup-beam runs inside the container with `ImageOS=ubuntu24`. Proving this works is part of the phase-1 spike.
- **Fonts.** Only self-hosted woff2 files, with a bundled fallback in every stack. Wait for `document.fonts.ready`, then check `document.fonts.check(...)` for each family.
- **Rendering flags.** DPR 1 (a small DPR-2 set runs nightly). Chromium flags `--font-render-hinting=none --disable-lcd-text --force-color-profile=srgb --hide-scrollbars`.
- **Motion.** `animations: :disabled` and `caret: :hide`, plus injected CSS that zeroes transitions and animations, `prefers-reduced-motion: reduce`, and an explicit color scheme.
- **Ready signal.** Capture only after the canvas sets `data-fablebook-ready`. That happens after page-loading-stop, fonts ready, every `img.decode()` and no `phx-*-loading` classes left. Never sleep.
- **Data.** Scenarios use `frozen_now` and seeded fixtures. All external requests are route-aborted.
- **Capture scope.** Element screenshots via `:selector`, roughly 5–20 KB each. Masks cover only regions a scenario declares.
- **Tolerance.** `threshold: 0.1` and `max_diff_pixels: 0` by default. Any looser value needs a reason recorded on the scenario.
- **Baselines are never auto-accepted** (ADR 0011 guards).
  - `bin/visual update <glob>` runs only inside the container.
  - PRs that change baselines publish an old / new / diff triptych to the job summary.
  - Commits use `test(visual): accept <names>: <reason>`. A fix and its recapture land in the same commit.
- **Location.** `test/__screenshots__/linux-chromium-<pw-major.minor>/…`. A Playwright bump gets its own PR that re-baselines and touches no `lib/` files.
- **Self-test (nightly; blocks release).** Capture 5 scenarios ×3 across 2 browser contexts. The hashes must be identical.
- **Budget.**
  - PR visual-core: ≤40 renditions (key plus worst case per section × {375, 1280} × {light, dark}), about +1 min.
  - Nightly and release: ≤400 renditions, about 6–8 min, sharded once it passes 12 min.
  - Storage: ≤400 baselines and ≤25 MB, enforced by a test. No LFS.

## Sweep (L2, from the manifest, no per-story code)
- **Matrix.** Manifest × {320, 375, 768, 1280, 1440} × {light, dark}, plus a reduced-motion pass and a short list of composed routes.
- **Assertions:**
  - No console errors.
  - No page-level horizontal overflow (1.4.10).
  - axe wcag2a/aa/21aa/22aa, with incomplete counted as a finding.
  - Targets ≥24 px (2.5.8).
  - No clipping at 200% (1.4.4).
  - Computed font-size, radius, shadow, z-index and duration all belong to the token set.
  - The focus walk is visible at 3:1 and never obscured (2.4.11).
  - The nav ARIA snapshot is identical across pages.
  - The glossary lint passes on rendered text and accessible names.
  - No `securitypolicyviolation`.
- **Lanes.** The PR lane runs a curated subset. Nightly and release PRs run all of it. Findings are fingerprinted and ratcheted, so the set can only shrink.

## Canon checks (pure Elixir, PR lane, <10 s for ~300 scenarios)
- **Glossary lint.** Scenarios are rendered server-side. The lint covers text nodes plus `aria-label`, `title`, `placeholder`, `alt` and `value`, is case- and plural-aware, and flags `avoid` terms, `retired` phrases and internal terms leaking into copy. User data marked `data-fablebook-copy="data"` is exempt. Findings are fingerprinted and ratcheted.
- **Voice rules (deterministic only).** Sentence case, buttons start with a verb, length limits per role, banned phrases, no "!" in errors, one term per concept. Tone judgement goes to bundles, not CI.
- **Token checks.** References resolve, there are no alias cycles, `$type` is valid, CSS custom properties match the committed CSS, and raw hex or arbitrary values are banned in owned components (exceptions are named).
- **Contrast matrix.** Declared pairs per scheme, alpha-composited, with no rounding up. axe `color-contrast` serves as a second opinion in the browser.
- **Intent coverage.** Each scenario cites a persona and a job (Area and Screen scenarios; a warning until the canon has a persona, an error after). Uncovered jobs and orphan personas are reported.

## LLM bundle quality (ADR 0010)
- Golden bundles cover 3 reference scenarios: a primitive, a form with errors, and a screen with long non-ASCII text.
- A determinism property checks the tree hash, and a redaction test runs on every bundle.
- Budgets: about 7.5k text tokens per scenario and ≤1.5 MB per scenario.
- With browser capture, measurements are rounded to 0.5 px and contrast to 2 decimals before the golden comparison.
- A JSON Schema is committed, and a `Fablebook.Bundle.validate/1` round-trip test checks it. No schema-library dependency.

## Performance
See ADR 0015 for the gates. Rules that make those gates achievable:
- **Compile-time catalog data.** Build catalog data into module functions at compile time, not `:persistent_term`. Every `put` triggers a global GC scan.
- **No runtime compilation**, ever.
- **Small diffs.** The workbench LiveView keeps the sidebar static (no re-render on control change), uses streams for long lists and `:key` in comprehensions, and holds overrides in a small assign.
- **Benches.** These live in `bench/`, a sibling Mix project: catalog build at N = 500/5000/20000, mount, render, control round-trip, bundle build and export. Baselines are committed with SHA, versions and machine, and each bench has a sensitivity control.

## Telemetry and observability
- The events catalogue is in DOMAIN-MODEL §1.
- A copy-paste recipe in `guides/operate/telemetry.md` covers LiveDashboard metrics: render duration summary, crash counter, bundle size, catalog size.
- Logger metadata is `domain: [:fablebook]`.
- In dev, a hidden "Diagnostics" page lists the catalog build time, scenario count, last crashes and evidence staleness. It is linked from the doctor.

## Security checklist
- [ ] No eval and no atoms from input (ADR 0004): Credo bans, properties, mutation-proven tests.
- [ ] The canvas topic is a `Phoenix.Token`, the event log is string-only and truncated, and every control type has a size cap.
- [ ] Open-in-editor is localhost-only, the path must sit under the project root after realpath, and the editor command comes only from `PLUG_EDITOR` or config.
- [ ] Every path is escaped (`export --out`, bundle `--out`) and contained in its root.
- [ ] Markdown and descriptions are escaped by default. Story descriptions are never treated as raw HTML.
- [ ] CSP: nonces on every inline tag, no `eval` or `new Function`. The iframe uses `sandbox="allow-scripts allow-same-origin allow-forms"`. The workbench sets `frame-ancestors 'self'`.
- [ ] The prod guard raises at compile time, and the CI prod build asserts no routes and no story beams.
- [ ] No prod override in 1.0 (hosted mode is v2). The docs warn that `:live_view` subjects (waiver-only, ADR 0024) run inside the Fablebook session, bypassing host `on_mount` auth.
- [ ] Bundle redaction strips paths, env values, hosts, secret-shaped strings and CSRF/session tokens.
- [ ] Supply chain: a tarball allowlist test, license notices for vendored assets, reproducible `priv/static`, an SBOM at release, actions pinned by SHA, zizmor and actionlint.
- [ ] sobelow runs on the operator host app (it is noisy on the library alone).

## Gaps found in the ISO 25010 review (each owned by a phase)
- **Reliability.**
  - Hot reload: recompiling a story or component updates the catalog without a restart. Test it by recompiling in-test.
  - Reconnect restores state from the URL alone.
- **Compatibility.**
  - `__components__` drift is caught by the adapter contract test and the canary lane.
  - LiveView 1.3 will arrive during 0.x.
  - LiveView 1.2's `:global` MDN alignment affects `rest` attrs.
  - The host's `window.liveSocket` may be absent or on a different socket path.
  - Colocated hooks need the esbuild watcher, and CI must run `assets.build` before probing.
- **Portability.**
  - Umbrella apps: the installer targets the web app.
  - Hosts that use bun instead of esbuild.
  - Apps without Tailwind.
  - Windows paths: ids never come from file paths.
- **Usability.**
  - The workbench chrome passes its own sweep.
  - Workbench appearance and preview theme are labelled separately.
  - Locale and RTL are first-class.
- **Maintainability.**
  - The public API surface has a snapshot test.
  - `@moduledoc false` everywhere internal.
  - ≤25 public modules at 1.0.
- **Tailwind `@source`.** Classes used only in stories either go missing, or leak into prod CSS if `storybook/` is scanned. The rule: stories use only the app's real classes, and placement CSS comes from Fablebook.
- **Gettext.** The locale is per process, so set it in both the dry-render process and the canvas.

## Adversarial cautions
- **The quality engine can turn into the product.** In sigra, 34 of 67 plans were hygiene. Every *added quality check* (canon lints, perf gates, contract tests) costs ≤30 s on PRs, or runs nightly/release-only; the PR wall-clock budget (p50 ≤7 min) is measured from CI history, not asserted by a test.
- **Scope can creep toward Storybook parity.** The real differentiators are no-eval security, prod-grade fidelity, upgrade survival, design canon and LLM bundles. Everything else waits until v1.x or v2.
- **Precision theatre.** Writing "p99.999" into requirements invites agents to build fake precision. The deterministic proxies in ADR 0015 are the requirement instead.
