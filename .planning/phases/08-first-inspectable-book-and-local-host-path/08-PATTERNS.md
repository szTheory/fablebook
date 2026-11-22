# Phase 8: First inspectable Book and local host path - Pattern Map

**Mapped:** 2026-11-20
**Files analyzed:** 9 implementation areas (macro, contract tests, production fixture, host, compiled Book, and source check)
**Analogs found:** 6 / 9 areas have a tracked code or architecture analog; the host render, authored Story/Scenario, and source-digest paths have no code analog.

## File Classification

| New/Modified File or Area | Role | Data Flow | Closest Analog | Match Quality |
|---------------------------|------|-----------|----------------|---------------|
| `lib/fablebook/router.ex` | route / macro | compile-time AST validation and route registration | `lib/fablebook/router.ex` | exact role; current AST expansion is the behavior to harden |
| `test/contract/*_test.exs` (new mount-AST contract; filename not chosen) | test | compile-time contract | `test/contract/prod_guard_message_test.exs` | role-match; no existing acceptance/rejection AST contract |
| `test/contract/prod_guard_test.exs` | test | build/route/source assertions | same file | exact |
| `test/fixtures/prod_guard_host/mix.exs` | config / fixture | environment-specific compilation | same file | exact |
| `test/fixtures/prod_guard_host/lib/guard_host_web/router.ex` and `test/fixtures/prod_guard_host/unguarded/router.ex` | route fixture | compile-time guarded and reachable-mount controls | same files | exact |
| `lib/fablebook/placeholder.ex` | Plug endpoint | request-response | same file | role-match; placeholder body is not a host-render pattern |
| `hosts/operator/lib/**` (recommended host area; concrete filenames remain for planning) | route, controller/component, layout, config | request-response / HTML render | `test/fixtures/prod_guard_host/lib/guard_host_web/router.ex` | partial router match only; no Phoenix host or renderer exists |
| `hosts/operator/storybook/**/*.ex` (source-dependent Book/Story/Scenario and fixture modules) | compiled model / fixture | compiled metadata and deterministic render data | `test/fixtures/prod_guard_host/storybook/book.ex` | no Story/Scenario analog; fixture Book is empty |
| New host catalog/render tests and source-subset digest check (paths not assigned upstream) | test / utility | request-response and file-I/O/hash verification | `test/contract/prod_guard_test.exs` (build-test shape only) | partial for host tests; no digest-check analog |

## Pattern Assignments

### `lib/fablebook/router.ex` (route / macro, compile-time AST validation)

**Analog:** `lib/fablebook/router.ex` (tracked; current public macro and production error branch).

**Current mount pattern** (lines 24-41):

```elixir
defmacro fablebook(path, book) do
  if Mix.env() == :prod do
    description = prod_description(path, book, Mix.Project.config()[:app])
    quote do
      raise CompileError,
        file: unquote(__CALLER__.file),
        line: unquote(__CALLER__.line),
        description: unquote(description)
    end
  else
    book = Macro.expand(book, %{__CALLER__ | function: {:fablebook, 2}})
    quote do
      require Phoenix.Router
      Phoenix.Router.get(unquote(path), Fablebook.Placeholder, unquote(book), as: :fablebook)
    end
  end
end
```

Preserve the production CompileError branch and generated route behavior. The current `Macro.expand/2` at line 35 expands arbitrary caller AST and is precisely the line the new literal-alias/reference check must guard before any expansion. Keep `prod_description/3` and the canonical first line at lines 44-61 unchanged in meaning: `Fablebook cannot be mounted in a prod build`.

### `test/contract/*_test.exs` (new mount macro contract; exact filename not selected)

**Partial analog:** `test/contract/prod_guard_message_test.exs`. This shows compile-time macro inspection and safe global environment handling, but it does not test accepted/rejected Book ASTs.

**Compile-time test setup** (lines 8-12, 34-39):

```elixir
setup do
  previous = Mix.env()
  Mix.env(:prod)
  on_exit(fn -> Mix.env(previous) end)
end

ast = quote do: Fablebook.Router.fablebook("/fablebook", MyAppWeb.Storybook)
{:ok, env} = Macro.Env.define_require(__ENV__, [], Fablebook.Router)
{:raise, _, [_, opts]} = Macro.expand_once(ast, env)
Keyword.fetch!(opts, :description)
```

Use `async: false` where tests mutate `Mix.env/1`. For the new contract, exercise the real public macro on literal alias/reference forms and on rejected variable/macro/computed forms; include a harmless macro probe so rejection proves the forbidden macro was not expanded. There is no current same-role AST-contract test to copy. The contract test PR must stay separate from the router implementation PR (ADR 0021, lines 28-29; `.planning/ROADMAP.md` Phase 8 delivery sequence).

### `test/contract/prod_guard_test.exs` and `test/fixtures/prod_guard_host/**` (production controls)

**Analogs:** `test/contract/prod_guard_test.exs`, `test/fixtures/prod_guard_host/mix.exs`, fixture router files, and `test/support/mix_cmd.ex`. All named files are tracked.

**Positive and negative production control** (test lines 13-35):

```elixir
clean!("dev")
assert_ok(mix("dev", ~w(compile --warnings-as-errors)))
assert mix!("dev", ~w(phx.routes GuardHostWeb.Router)) =~ "/dev/fablebook"
assert Enum.any?(beam_sources("dev"), &(&1 =~ "/storybook/"))

clean!("prod")
assert_ok(mix("prod", ~w(compile --warnings-as-errors)))
routes = mix!("prod", ~w(phx.routes GuardHostWeb.Router)) |> route_lines()
refute Enum.any?(routes, &(&1 =~ ~r/fablebook/i)), inspect(routes)
refute Enum.any?(beam_sources("prod"), &(&1 =~ "/storybook/" or &1 =~ "/design/"))

{out, status} = mix("prod", ~w(compile --warnings-as-errors), [{"FABLEBOOK_UNGUARDED", "1"}])
assert status != 0, out
assert length(String.split(out, @canonical)) == 2, out
```

The fixture project uses `elixirc_paths(:prod) == ["lib"]` (plus only the explicit `FABLEBOOK_UNGUARDED` control) and includes `storybook/` in dev/test (`test/fixtures/prod_guard_host/mix.exs:24-27`). Its normal router is guarded by `Application.compile_env(:guard_host, :dev_routes)` (`lib/guard_host_web/router.ex:6-12`); the separate unguarded router provides the reachable negative control (`unguarded/router.ex:1-6`). Keep both the route absence and beam-source absence assertions. `MixCmd.run/4` clears build-related env vars and sets `MIX_ENV` explicitly (`test/support/mix_cmd.ex:4-13`), so fixture runs stay isolated.

Repeat the same positive route/Story exclusion and negative reachable-mount checks against the completed operator host. Do not count the existing fixture as proof of the new host's production boundary.

### `lib/fablebook/placeholder.ex` and proposed operator host

**Analog:** `lib/fablebook/placeholder.ex` (tracked) is the only current request handler. `test/fixtures/prod_guard_host/lib/guard_host_web/router.ex` is a minimal Phoenix router, not a rendering host.

**Current Plug response shape** (lines 3-15):

```elixir
@behaviour Plug
import Plug.Conn

@impl Plug
def init(book), do: book

@impl Plug
def call(conn, _book) do
  conn
  |> put_resp_content_type("text/plain")
  |> send_resp(200, "Fablebook is installed. The workbench is not released yet.")
end
```

This is only a minimal Plug lifecycle/response example. Replace or integrate the placeholder according to the selected host boundary; it does not establish Phoenix root-layout, LiveView, Canvas, or CSP behavior. No host app, HEEx, CSS, endpoint, layout, controller, or `Phoenix.ConnTest`/LiveView render tests exist in the current `lib/` and `test/` tree.

The closest router excerpt is the fixture's `use Phoenix.Router, helpers: false`, `get "/", ...`, and compile-time `if Application.compile_env(...)` guard (`test/fixtures/prod_guard_host/lib/guard_host_web/router.ex:1-12`). For Canvas, use ADR 0003's host pipeline and inherited root layout with a same-origin iframe; do not copy the placeholder or add a separate preview endpoint. The UI contract is in `08-UI-SPEC.md` (semantics, stable links, focus, narrow widths, and safe unknown-screen state).

### `hosts/operator/storybook/**/*.ex` (source-dependent compiled Book, Story, Scenario, and fixtures)

**Closest fixture:** `test/fixtures/prod_guard_host/storybook/book.ex` is an empty module; it provides no Book, Story, Scenario, or fixture implementation to copy.

**Compile-path pattern** (`test/fixtures/prod_guard_host/mix.exs:24-27`):

```elixir
defp elixirc_paths(:prod), do: ["lib"]
defp elixirc_paths(_), do: ["lib", "storybook"]
```

ADR 0001 (lines 12-22) is the implementation contract rather than a code analog: authored Stories are ordinary compiled `.ex` modules under host `storybook/`, excluded from prod, with fixtures owned by host code. ADR 0002 (lines 8-28) specifies ordinary Scenario functions, HEEx for composed templates, required situation metadata, and source/canon citations. ADR 0008 (lines 13-20) requires fixed compiled module discovery and stable IDs; route strings must resolve against known entries, never become module names.

**Source/digest gate — updated 2026-11-21:** The earlier mapping described source as absent and used the historical `docs/brand/logistify/` handoff path. INT-20261121-01 supersedes that retrieval assumption. Read from `.cache/brand_sources/logistify-brand/`, populated by `bin/fetch_brand_sources` from the full SHA in `brand_sources.lock.json`; do not depend on the old folder. `bin/verify_logistify_source --check-original .cache/brand_sources/logistify-brand` verifies the three preserved whole-file hashes, and `--check-pinned` verifies repository/tag/commit provenance and exact manifest excerpt bytes. The records source supports the dispatcher recovery slice. It declares 12 selected/reassigned but provides two IDs in the bulk case and one in the completion case; display only supplied values and do not infer missing shipment or replacement-driver details.

## Shared Patterns

### Production mount guard

**Sources:** `lib/fablebook/router.ex:24-61`, `test/contract/prod_guard_test.exs:13-35`, `test/fixtures/prod_guard_host/mix.exs:24-27`.

Apply the AST allowlist before expansion, preserve the existing canonical production CompileError, compile Story sources only in dev/test, and test both positive exclusion and a reachable production mount that must fail.

### Compiled, fixed catalog inputs

**Sources:** ADR 0001, ADR 0002, ADR 0004, and ADR 0008; current fixture compile paths at `test/fixtures/prod_guard_host/mix.exs:24-27`.

Keep Book/Story/Scenario modules and source-backed values compiled and fixed. No runtime eval, user-selected module/code, or atoms derived from URL input. Unknown Book/screen IDs should resolve through the known catalog to the UI spec's safe unavailable state.

### Canvas and host rendering

**Source:** ADR 0003, `docs/adr/0003-iframe-canvas-through-host-pipeline.md:13-27`; there is no current host-rendering code analog.

Render through the actual host pipeline/root layout in a same-origin iframe so the host CSS, JS, hooks, fonts, and CSP apply. Server render tests can prove content/navigation behavior; they do not replace the one real-browser evidence pass for assets and CSP.

## No Analog Found

| File / Area | Role | Data Flow | Reason |
|-------------|------|-----------|--------|
| `hosts/operator/lib/**` host catalog, Canvas renderer, layout/assets | host / component | request-response | Repo has only the mount placeholder and a minimal route fixture; no Phoenix app or render surface exists. |
| `hosts/operator/storybook/**/*.ex` authored Book/Story/Scenario/fixture modules | compiled model / fixture | compiled metadata and render data | No compiled Story/Scenario implementation exists; source content is blocked on the absent digest-verified subset. |
| New source subset, citation map, SHA-256 manifest, and digest check (paths TBD) | fixture / utility / test | file-I/O and hash verification | Required source is absent; no existing source pinning/check pattern is present. Keep this prerequisite ahead of source-backed Story fixtures. |
| Phoenix host/render and Canvas browser tests (test path TBD) | test | request-response / browser | No existing Phoenix.ConnTest, LiveViewTest, host endpoint, HEEx, or Canvas implementation exists in `lib/` or `test/`. |

## Metadata

**Analog search scope:** `lib/`, `test/`, `docs/adr/`, and the Phase 8 planning artifacts.
**Pattern extraction date:** 2026-11-20.
**Tracked-source check:** all existing code analog paths named above were verified with `git ls-files`; no gitignored mirror paths are used.
