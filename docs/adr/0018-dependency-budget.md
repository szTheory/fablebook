# 0018. Dependency budget: flat and shallow; copy-paste beats a dependency

**Status:** Accepted · **Cites:** INT-20261028-02 ("very flat shallow dep trees … a little copy abnd paste is better than another lib")

## Decision
- **Runtime:** `phoenix ~> 1.8.16`, `phoenix_live_view ~> 1.2.9`, `phoenix_html`, `telemetry ~> 1.0`, `nimble_options ~> 1.1`.
- **Optional:** `igniter` (installer), `earmark` (richer Markdown), `phoenix_test_playwright` (browser capture).
- **Dev/test:** ex_doc, credo, dialyxir, stream_data, mox, phoenix_test, lazy_html, muex (exact pin), mix_audit, tailwind and esbuild (`runtime: false`). Benchee lives only in `bench/mix.exs`.
- **Banned:** jason (use stdlib `JSON`), mdex (Rust NIF), floki, any YAML library, any JS runtime *required* by adopters (Node is allowed only behind opt-in browser features: `--browser` bundles, the sweep, visual baselines; without it, Copy for LLM yields a no-browser bundle labelled as such), `telemetry_metrics`.
- **Vendored, with license notices in `priv/static/LICENSES`:**
  - a heroicons subset;
  - axe-core (MPL-2.0, with a NOTICE);
  - a fuzzy scorer (about 80 lines);
  - a Markdown subset renderer (about 200 lines, escaping by default);
  - the strict frontmatter parser (ADR 0012).
- Every new dependency needs a written justification in a new ADR. Optional dependencies go through `Code.ensure_loaded?` gateways, and the `--no-optional-deps` lane proves the library works without them.
