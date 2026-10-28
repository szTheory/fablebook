# Lessons learned: prior art, footguns, community feedback

These are research findings dated 2026-10-28. Each item is phrased as **Do** or **Don't** and cites its source. Items marked **[unverified]** came from memory rather than a source fetched during research, so re-check them before relying on them.

---

## 1. phoenix_storybook (the incumbent)

Version 1.5.0 (2026-09-15), 881★, 226 open issues. [hex](https://hex.pm/packages/phoenix_storybook) · [GitHub](https://github.com/phenixdigital/phoenix_storybook)

### How it works
- Stories are `.story.exs` files compiled at runtime, lazily in dev and eagerly elsewhere. Sidebar config lives in `.index.exs`.
- Kinds: `:component`, `:live_component`, `:page`/`:example`.
- Data shapes:
  - `%Variation{id, attributes, slots: ["<:x>raw heex</:x>"], let, template}`
  - `%VariationGroup{}`
  - `template/0` with a `<.psb-variation/>` placeholder
  - `container/0` is `:div` by default, or `:iframe` via srcdoc
- UI: the playground runs in a child LiveView with an event log.
- Mounting and assets:
  - Router macro `live_storybook`.
  - Its own UI is prebuilt Tailwind 4 with a `psb:` prefix, scoped under `.psb-sandbox`.
  - The host's CSS and JS load into the `app` cascade layer.
- Recent history: 1.0 brought LiveComponent `handle_info`. 1.2 added MDEx and Tailwind v4. 1.3 added LiveView 1.2. 1.4 added a themeable layout, "open in editor", and runtime asset hashes. 1.5 added an Igniter installer.

### Footguns, with evidence
1. **Remote code execution through the playground.** GHSA-55hg-8qxv-qj4p / CVE-2026-8467, CVSS 9.5, affected 0.5.0 up to 1.1.0. Client attr strings were interpolated into HEEx and evaluated with full `Kernel` access. Related advisories:
   - GHSA-833p-95jq-929q: `String.to_atom` on event params, which can exhaust the atom table.
   - GHSA-mrhx-6pw9-q5fh: the PubSub topic was taken from the query string, so a user could hijack another session's playground.

   **Don't** round-trip templates through strings. **Do** build renders from data (ADR 0004).
2. **CSS isolation is the most common complaint.** Issues: #494 (fonts, 22 comments, "it still applies the storybook default font"), #615 (Phoenix 1.8/Tailwind v4, serif fonts), #652 (Firefox and Tailwind v4 layers), #699 (live_reload rewrote `?vsn=`), #419, #426, #289, #178, #135, #17. ElixirForum users asked whether to prefix every component class with the sandbox class. **Do** render in an iframe through the host's real layout (ADR 0003).
3. **JS hooks break repeatedly.** Issues: #284 (hooks don't work after a standard install), #268, #287 (`phx-click`), #663 (ViewHook subclasses), #657 (load order), #495 (a variation id that isn't a valid JS identifier). The root cause is a separate `storybook.js` with its own LiveSocket that re-registers hooks. **Do** load the host's own `app.js`, which already includes colocated hooks.
4. **Slots and complex attrs fail.** Issues: #206 (slot rendered twice), #128 and #48 (nested components), #477 and #536 (function callbacks), #157 and #333 (large attrs), #189, #353 (a missing attr caused "a death spiral that was not reported in an obvious way"). The root cause is the string round-trip. **Do** use compile-time `~H` and captured functions, plus presets for complex values.
5. **Setup and upgrade friction on every Phoenix/LiveView minor.** Issues: #615, #312, #190, #204, #665 (`asset_hash/1` undefined from a wrong `otp_app`), #537, #555, #609, #674, #833, #262, #279 (internal TagEngine/HTMLEngine). **Don't** depend on LiveView internals. **Do** wrap the one undocumented API you need (`__components__/0`) in a single adapter.
6. **Compile, CI and prod cost.** Issues: #250 ("adds about 1 minute to all of our CI runs"), #860 (compile-time hashing forced recompiles), #311 (stories fail in prod), #429 (protocol consolidation).
7. **Performance.** #647: the event-log telemetry handler was attached to *all* LiveView `handle_event`s in the host. #529: large source files render slowly. **Don't** attach global handlers.
8. **CSP.** #149 stayed open for years: "I don't know anything about CSP." **Do** support nonces from day one.
9. **Owner-hit footguns** (`~/projects/mailglass/.planning/research/ui-quality-engine/ARCHITECTURE.md`):
   - It can't nest under a non-`/` scope; links drop `/dev`.
   - `.psb-sandbox{font-family:serif}` overrides production fonts.
   - `css_path` hashing warns on controller-served URLs, and CSS arrives via `@import`, which is invisible to `link[rel=stylesheet]` checks.
   - Only top-level variation ids are addressable.
   - The enumeration API is dev-only, so there is no manifest under `MIX_ENV=test`.
   - There is no viewport control (#49).
   - Tight Phoenix/LiveView version pins.
   - It pulls in the mdex NIF.
   - Eager mode recompiles on every add or remove.
   - It owns a separate LiveSocket.
10. **Open feature requests** (unmet demand): #772 auto-generate stories from components, #566 global HEEx injection (SVG sprites), #715 Markdown export for coding agents, #782 sidebar grouping, #49 resizable sandbox, #574/#573 galleries and Markdown pages, #520 Elixir values in the playground, #215 visual-regression endpoints (closed without a fix).
11. **Maintainer posture.** Responsive but stretched thin ("I'm not super fast to answer"). Several decisions were defensive: no code evaluation, iframe as a last resort, a workaround for layered CSS.

---

## 2. Storybook's evolution (React and others)

| Version | Change | Lesson |
|---|---|---|
| 5.0 (2019) | Full UI redesign; keyboard shortcuts | The workbench UI is the product; keyboard support from day one |
| 6.x | `args`, Controls, essentials, CSF default; 6.4 on-demand story loading; play functions **[unverified detail]** | Args turned stories into *data*, which enabled controls, docs and tests |
| 7.0 (2023) | CSF3 default; on-demand loading the norm; quieter UI, bigger search, regrouped toolbar, light/dark | A static, analysable index is required for speed |
| 8.0 (2024) | Performance and stability; forced config cleanup | Every major release taxes users on upgrade |
| 9.0 (2025-06) | Testing-centric: Vitest addon, a11y (axe), visual, coverage as sidebar statuses; tag filtering; per-story globals; **48–50% smaller** after the "bloat" criticism | "Stories as tests" is the winning pitch; cut weight ruthlessly |
| 10.0 (2025-10-28) | ESM-only; 29% smaller install; CSF Factories (typed); `sb.mock`; tag exclusion; QR share; open-in-editor | A typed story format and "show on phone" |
| 10.3–10.4 (2026) | MCP server (dev, docs and testing toolsets; published builds expose docs only); component manifests `/manifests/components.json` (preview; "excessive or misleading context degrades agent performance") | Agents are first-class consumers; curate context and keep it small |

Sources: [SB9](https://storybook.js.org/blog/storybook-9/), [SB10](https://storybook.js.org/blog/storybook-10/), [7.0 design](https://storybook.js.org/blog/7-0-design-alpha/), [AI docs](https://storybook.js.org/docs/ai), [manifests](https://storybook.js.org/docs/ai/manifests), [MCP](https://storybook.js.org/docs/ai/mcp/overview), [bloat post](https://blogs.apievangelist.com/blogs/storybook-2025-07-16-storybook-bloat-fixed/).

### Complaints, and what Fablebook does instead
- **Bloat and dependency conflicts.** The maintainers themselves called the criticism "true". → Ship as one Hex package with a dependency budget (ADR 0018).
- **Slow boot and builds.** Ladle cold-starts in 6 s vs Storybook's 58 s, and opens the first story with 388 kB vs 14.3 MB. → Server-rendered stories need no bundler, so boot is instant.
- **Addons break on upgrade** (e.g. storybook-addon-mock on 6.5.14; storybook-dark-mode still needed manual fixes in SB9). → Batteries included, with no public plugin API in 1.0 (ADR 0009).
- **Config sprawl** (main, preview, manager, framework, builder, docgen). → One Book module, reusing the host's own pipeline.
- **Docs drift** from hand-written MDX. → Docs come from `attr doc:` and `@doc`, so they can't drift.
- **UI clutter:**
  - an ambiguous icon-only toolbar;
  - a11y results buried in a panel tab;
  - a Docs vs Canvas split that confuses newcomers;
  - empty controls when docgen fails;
  - confusion between the component theme and the workbench theme.

  → Fablebook uses text-valued tools, shows checks on each tile, uses the story page as the docs, takes controls from declared attrs, and keeps Appearance separate from Theme (ADR 0013).
- **Praise:** "stories as tests" (one artifact serves as sandbox, docs, visual baseline and a11y check), the integrations and the community. → Keep the single artifact; it feeds tests, checks and bundles.

---

## 3. Other workbenches

| Tool | What to steal | What to avoid |
|---|---|---|
| **Lookbook** (Rails ViewComponent; the closest server-rendered analog) | Preview classes whose methods are *scenarios*; typed `@param` inputs (text, select, toggle, color, range…) with choices from a method, a constant or a file; `@display` layout params; `@hidden` keeps a scenario out of nav but still addressable by URL; Markdown pages with frontmatter; embeds; custom inspector panels. Top-voted asks: in-browser editable params, auto-refresh, extra pages, a **theme switcher**, **deployed-environment support**, **viewport presets**, **several examples in one window**, an HTML beautifier. | Stringly-typed annotations in comments; use real data instead. [guide](https://lookbook.build/guide) · [issues](https://github.com/lookbook-hq/lookbook/issues?q=is%3Aissue+sort%3Areactions-%2B1-desc) |
| **Ladle** (React) | Zero config; batteries included with no addons; **all state in the URL** "for testing"; `meta.json` export; RTL; keyboard support; handles 16k stories at Uber. | React-only. [intro](https://ladle.dev/blog/introducing-ladle) |
| **Histoire** (Vue/Svelte) | **A grid of all variants**; responsive presets; checkerboard backgrounds; full-text search; reuses the host's Vite config. | A small ecosystem. [guide](https://histoire.dev/guide/) |
| **React Cosmos** | Fixture-first; the **renderer is decoupled from the shell**. | Small mindshare. Lesson: keep a render seam (ADR 0022). |
| **Widgetbook** (Flutter) | Use-cases generated by codegen; device, theme and locale addons; v4 renamed knobs to typed args. | Its cloud only partly supports knobs in snapshots. **Visual tests need fixed, named states, not knob combinations.** |
| **SwiftUI `#Preview` / Compose `@Preview`** | Previews live next to the code; parameter providers turn a sequence into a set of previews; a shared context is built once. | IDE-bound. |
| **django-pattern-library** | YAML context plus **template-tag overrides** (mocking); a POST render API that takes JSON. | Untyped YAML. A render API is a good primitive for agents. |
| **Pattern Lab / Fractal** | A pages level showing whole screens; pseudo-patterns. | Static and dated. |
| **Storybook for Angular / Web Components** | — | Second-class compared with React. Fablebook has one target; use that focus. |

---

## 4. Embedded dev-tool prior art (Elixir)

- **Phoenix LiveDashboard** is the gold standard:
  - router macro options: `csp_nonce_assign_key`, `on_mount`, `live_socket_path`, `additional_pages`;
  - assets embedded at compile time via `File.read!` plus `@external_resource`, MD5-hashed, served `immutable`, with no host pipeline involved.

  [router](https://phoenix-live-dashboard.hexdocs.pm/Phoenix.LiveDashboard.Router.html)
- **Oban Web**: mounted with `oban_dashboard "/oban"`, "doesn't hook into your asset pipeline at all", and controls access through a resolver behaviour.
- **ErrorTracker**: the same pattern, with a Tailwind-built UI and minimal JS.
- **LiveDebugger**: runs its own endpoint on 127.0.0.1:4007 and injects into the host via `live_debugger_tags`. This loses host fidelity, so don't use it for a canvas.
- **Surface Catalogue**: discovers catalogues inside dependencies (`priv/catalogue`), which is worth copying later. It is now dormant.
- **UI libraries** (SaladUI, Mishka Chelekom, Fluxon, Corex) mostly hand-roll their own docs sites. Mishka ships an MCP server and AI metadata. A Fablebook static export they could host fills a real gap.

---

## 5. Lessons from the owner's prior libraries

See `OWNER-DNA.md`. In brief:
- CI bloat is the biggest drag on velocity.
- Two hand-maintained inventories always drift.
- Push early: green locally does not mean green in CI.
- A rewritten guard hides a regression better than having no guard.
- Design the authority model before installing it.
- Prove the demo host end to end.
- Copy-paste beats adding a dependency.
