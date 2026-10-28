# Stack facts (verified 2026-10-28)

Re-verify these before each milestone. Anything marked **[verify]** wasn't fully confirmed during research.

## Versions
| Package | Latest | Notes |
|---|---|---|
| Phoenix | **1.8.16** (2026-10-20) | No 1.9 release or prerelease. [hex](https://hex.pm/packages/phoenix) |
| Phoenix LiveView | **1.2.13** (2026-10-20) | 1.2.0 shipped 2026-06-10. 1.2.7 and 1.2.9 were **security releases**, so the floor is ≥1.2.9. The 1.3 changelog is "Empty so far". |
| phoenix_storybook | 1.5.0 (2026-09-15) | 881 stars, 226 issues |
| PhoenixTest | 0.13.1 (2026-10-23) | |
| phoenix_test_playwright | 0.16.x | **[verify]** that this is the latest. Each Playwright JS version pins a browser. |
| Muex | 0.12.0 (2026-10-21) | Active, about 3k downloads/week. Darwin and Exavier have been dormant since ~2020. Muzak's free tier is capped at 25 mutations. |
| Elixir / OTP | 1.19 / 28 latest | Elixir 1.18 added `JSON` to stdlib |
| DTCG | Format + Resolver 2025.10 | First stable release, 2025-10-28 |
| Storybook | 10.x | 10.3+ has MCP and manifests (preview) |
| `fablebook` on Hex | **free** (404 on 2026-10-28) | Reserve it with 0.1.0 in phase 1 |

## Phoenix 1.8
- Generators default to Tailwind v4 with no config file (`@import "tailwindcss"`, `@source`), plus daisyUI.
- `phx.gen.auth` uses magic links and sudo mode.
- **Scopes:** contexts take `%Scope{}` and templates receive `current_scope`. Screen stories need scope fixtures.
- `put_secure_browser_headers` sets `frame-ancestors 'self'` by default (`controller.ex:1413`), so a same-origin iframe canvas works.

## LiveView 1.1 / 1.2
- **Colocated hooks:** `<script :type={Phoenix.LiveView.ColocatedHook} name=".Name">`. A name starting with a dot is prefixed with the module name. They are extracted to `_build/$env/phoenix-colocated/<app>/` and imported with `import {hooks as colocatedHooks} from "phoenix-colocated/my_app"`. **They work only if the host's `app.js` imports them**, which is why the canvas loads the host's `app.js`.
- **Other 1.1 additions:** colocated JS, keyed comprehensions (`:key`), `<.portal>`, TypeScript types, better slot and debug annotations. **The macro components API is still private**, so don't build on it.
- **1.2 additions:**
  - `Phoenix.LiveView.ColocatedCSS` (a `transform/4` behaviour, no built-in `@scope`)
  - `JS.to_encodable/1`
  - per-module `@debug_heex_annotations`
  - `:test_warnings`
  - the TagFormatter behaviour
  - `:colocated_js` deprecated in favour of `:colocated_assets`
  - `:global` attrs aligned with MDN (breaking)
  - 1.2.10 added `navigation_type/2`
- **`__components__/0`:**
  - Generated for every module that `use Phoenix.Component`.
  - Shape: `%{name => %{kind, attrs: [%{name, type, required, doc, line, slot, opts: [default, values, examples…]}], slots: [%{name, required, doc, attrs, opts, line}], line}}`.
  - **Undocumented. Attrs and slots are sorted by name, not declaration order**, so re-sort by `line`.
  - Only functions that declare `attr` or `slot` appear.
  - Source: `deps/phoenix_live_view/lib/phoenix_component/declarative.ex`, lines ~400–410 and ~745–823.
- **Rendering:** `Phoenix.LiveView.Rendered` implements `Phoenix.HTML.Safe`, so `fun.(assigns) |> Phoenix.HTML.Safe.to_iodata()` renders outside LiveViewTest. Tableau is prior art for static HEEx sites.

## Tooling
- **Igniter:** `mix igniter.install <pkg>`. `Igniter.Test` provides `test_project/1`, `assert_has_patch/3`, `assert_unchanged/1` and `assert_creates/2`. phoenix_storybook 1.5 and LiveDebugger both ship Igniter installers.
- **phoenix_test_playwright `assert_screenshot/3`:**
  - Options: `:selector`, `:clip`, `:mask`, `:animations`, `:caret`, `:scale`, `:snapshot_dir`, `:threshold` (0.2), `:max_diff_pixels`, `:max_diff_pixel_ratio`. Diffs go to `__diff__/`.
  - **When a baseline is missing, it is saved and the test passes**, so guard against this (ADR 0011).
  - **[verify]** whether it exposes `ariaSnapshot`. If not, use axe nodes plus an accessible-name snippet via `evaluate`.
- **Standalone binaries:** the `tailwind` and `esbuild` Hex packages build assets with no Node.
- **GitHub Actions:** standard runners are free for public repos, so "cheap" here means wall-clock time and owner attention.
- **The bootstrap skill** (`~/.claude/skills/bootstrap-elixir-hex-lib/SKILL.md`) is the canonical release pipeline. Build from its description, not from oarlock's current files.

## GSD (installed `@opengsd/gsd-core` 1.19.0)
- **`/gsd-new-project --auto @FABLEBOOK-SEED.md`:**
  - Skips questioning but still asks for config: granularity, parallelism, git and agents.
  - Always runs research.
  - **Includes table-stakes features plus the features named in the seed, and defers any differentiators the seed doesn't name.**
  - Vertical-MVP mode.
  - Auto-approves requirements and roadmap.
- **Research step:** writes `.planning/research/{STACK,FEATURES,ARCHITECTURE,PITFALLS,SUMMARY}.md`.
- **Alternative:** `/gsd-ingest-docs` reads `docs/adr`, `docs/prd` and `docs/specs`. Precedence is ADR > SPEC > PRD > DOC, and conflicts go to `INGEST-CONFLICTS.md`.
- **Template files:** `~/.claude/gsd-core/templates/project.md` and `~/.claude/gsd-core/workflows/new-project.md`.
