# 0014. Testing strategy: the cheapest boundary that proves the contract

Test layers are named T0–T6 here. They are distinct from the owner methodology's L1–L5 check layers (L4 = LLM judge).

**Status:** Accepted · **Cites:** INT-20261028-01 · **Detail:** `docs/research/QUALITY-PERF-SRE.md`

## Decision
- **T0, static checks:**
  - `compile --warnings-as-errors`, `credo --strict` with custom checks (the eval and atom bans, no `name: __MODULE__`, no `compile_env` outside config), and Dialyzer;
  - `xref graph --label compile-connected --fail-above 0`.
- **T1, unit:** pure-core ExUnit tests run `async: true`. Mox is used only at real seams (`ComponentInfo`, the clock/filesystem for export, the editor launcher). Each seam has one contract test against the real implementation.
- **T1, properties (StreamData; 100 runs per PR, 10k nightly):**
  - cast round-trip;
  - URL-state round-trip within 2 KB;
  - id stability and injectivity;
  - manifest determinism under permutation;
  - no new atoms or eval for arbitrary input;
  - bounded render;
  - frontmatter round-trip;
  - contrast ratio symmetric and within [1, 21].
- **T2, LiveView:** LiveViewTest plus PhoenixTest covering navigation, control changes, URL patch and back, the crash panel, and reconnect-from-URL.
- **T3, installer:** `Igniter.Test` golden patches, idempotency, and conflicting-router cases.
- **T4, E2E:** phoenix_test_playwright against the host apps. The PR lane runs about 8 smoke specs plus visual-core. Nightly runs the full sweep plus Firefox and WebKit.
- **T5, package:** a clean-room consumer of the tarball, and a tarball allowlist test.
- **T6, mutation:** **Muex** (pinned exactly, `only: :test`), weekly and on dispatch, scoped to `Controls.Cast`, `URLState`, `Catalog.Id`, `Router` and `Canon.Frontmatter`. Score floors live in `test/mutation_floor.exs` and can only go up. A floor breach blocks the release PR, never an ordinary PR. Security tests stay "mutation-proven": each records the mutant it catches.
- **Adopters:** `Fablebook.Testing.generate_tests(book)` creates one ExUnit test per scenario (renders, attrs valid, desc present, citations resolve). `mount_scenario/2` runs via `live_isolated`.

## Rule
A contract test is never edited in the same PR as the implementation it guards (lesson from sigra v1.47).
