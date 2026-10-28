# 0022. Static export ships in v1.x; the render seam ships now

**Status:** Accepted · **Cites:** INT-20261028-01 ("dont over index on this if it overly compromises the design"), INT-20261028-05

## Decision
- **The render seam exists from phase 2.** `Fablebook.Render.render(scenario, globals, purpose)` returns `{:ok, iodata} | {:error, %Fablebook.Error{}}` and runs outside any LiveView. The canvas dry-run, generated tests, bundle markup and, later, export all use it.
- **Export ships after 1.0.** `mix fablebook.export` writes `canvas/<id>/<theme>.html` wrapped in the host's digested CSS from `cache_manifest.json`, a static workbench, and the manifest.
- **Interactivity is stated honestly.** Without a LiveSocket, `phx-*` bindings and JS commands are inert. Only native HTML interactivity works (`<details>`, `popover`, `<dialog>`, CSS states). Scenarios whose markup contains `phx-` bindings get a **Needs server** badge.
- **Render modes and subject kinds.** The seam also serves `render: :static` stories, which are controller-rendered with no LiveSocket. Renderers are dispatched by subject kind internally, and this is not a public extension point. The scope rule: Fablebook renders only what the Elixir/Phoenix app renders (INT-20261028-11).
- **Use case.** Export serves reviewers on phones and design-system docs sites. It also allows `impeccable detect` to scan static HTML.
