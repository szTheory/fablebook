# 0018. Dependency budget: flat and shallow; copy-paste beats a dependency

**Status:** Accepted · Amended 2026-10-28 (INT-20261028-18) · **Cites:** INT-20261028-02 ("very flat shallow dep trees … a little copy abnd paste is better than another lib")

## Decision
- **Runtime:** `phoenix >= 1.8.9 and < 2.0.0`, `phoenix_live_view >= 1.2.9 and < 2.0.0` (ADR 0007), `phoenix_html`, `telemetry ~> 1.0`, `nimble_options ~> 1.1`.
- **Optional:** `igniter` (installer), `earmark` (richer Markdown), `phoenix_test_playwright` (browser capture).
- **Dev/test:**
  - ex_doc and credo are `only: [:dev, :test], runtime: false`, because `mix ci` runs in `:test` (INT-20261028-18);
  - dialyxir, tailwind and esbuild are `only: :dev, runtime: false`, because `hex.build` publishes a `runtime: false` dep without `only:` as a required adopter dep;
  - stream_data, mox, phoenix_test, lazy_html and muex (exact pin);
  - Benchee lives only in `bench/mix.exs`.
- **No audit or SBOM deps:** `mix hex.audit` is the audit (ADR 0017), and the SBOM comes from the `erlef/mix_sbom` action, not an `sbom` dep.
- **Banned:** jason (use stdlib `JSON`), mdex (Rust NIF), floki, any YAML library, any JS runtime *required* by adopters (Node is allowed only behind opt-in browser features: `--browser` bundles, the sweep, visual baselines; without it, Copy for LLM yields a no-browser bundle labelled as such), `telemetry_metrics`.
- **What "banned" means:** a banned package is never in the prod closure (the transitive non-optional Hex requirements of the required deps, read from `hex_metadata.config`), never a direct dep in any env, and never referenced from `lib/`. Dev tools may still bring one into the dev/test lockfile.
- **Vendored, with license notices in `priv/static/LICENSES`:**
  - a heroicons subset;
  - axe-core (MPL-2.0, with a NOTICE);
  - a fuzzy scorer (about 80 lines);
  - a Markdown subset renderer (about 200 lines, escaping by default);
  - the strict frontmatter parser (ADR 0012).
- Every new dependency needs a written justification in a new ADR. Optional dependencies go through `Code.ensure_loaded?` gateways, and the `--no-optional-deps` lane proves the library works without them.

## Amendments (release pipeline sign-off, 2026-10-28)
- **Runtime ranges (D-16):** Phoenix and LiveView take ADR 0007's open-below-2.0 ranges. (INT-20261028-18)
- **Audit (D-27, Q19):** `mix_audit` is dropped from the dev/test list; it hard-depends on a YAML library. `mix hex.audit` replaces it. (INT-20261028-18)
- **Tool envs (D-26, Pitfall 3 reading):** credo and ex_doc are `only: [:dev, :test], runtime: false`; dialyxir, tailwind and esbuild are `only: :dev, runtime: false`. (INT-20261028-18)
- **Banned, defined (D-26, Q34(a)):** not in the prod closure read from `hex_metadata.config`, not a direct dep in any env, not referenced from `lib/`. `mix deps.tree --only prod` is not the measure, because it includes optional deps' subtrees. (INT-20261028-18)
- **SBOM (D-12, Q21(b)):** no `sbom` dep; the `erlef/mix_sbom` action generates the SBOM. (INT-20261028-18)
