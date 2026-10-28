# Technology Stack

**Project:** Fablebook (Storybook-style workbench for Phoenix LiveView, shipped as a Hex library)
**Researched:** 2026-10-28
**Mode:** Ecosystem, verification pass over the existing ADRs and `docs/research/STACK-FACTS.md`
**Overall confidence:** HIGH on versions (all read from hex.pm, GitHub releases, hexdocs or the published tarball source), MEDIUM on the three untested toolchain recommendations (marked below)

Every version below was read from a primary source on 2026-10-28: the hex.pm API, GitHub releases and changelogs, hexdocs, or the unpacked Hex tarball. Nothing comes from training data. Where this file disagrees with an ADR, the ADR stays in force until the owner resolves the proposed OPEN-QUESTIONS entry (precedence: intent > ADR > REQUIREMENTS > PROJECT).

---

## 1. Verdict on the existing material

The core stack decisions hold. The ADR 0018 runtime set (`phoenix`, `phoenix_live_view`, `phoenix_html`, `telemetry`, `nimble_options`) is correct and minimal. The LiveDashboard packaging model (ADR 0005) is confirmed by the current LiveDashboard and Oban Web mix files. The floors in ADR 0007 are justified (LiveView 1.2.7 and 1.2.9 are real security releases). Nothing banned in ADR 0018 turned out to be needed.

Findings that need action, ordered by roadmap impact:

| # | Severity | Finding | Touches | Action |
|---|----------|---------|---------|--------|
| F1 | STALE | `phoenix_test_playwright` is **0.19.0** (2026-10-17), not 0.16.x. Requires Playwright >= 1.64 and `playwright_ex ~> 0.15`. | ADR 0011, STACK-FACTS | Update the spike target. Pin exactly. |
| F2 | STALE | **Elixir 1.20.4** (1.20.0 on 2026-06-03) and **OTP 29.1.2** exist. "Latest = Elixir 1.19 / OTP 28" is wrong. | ADR 0007, COMPAT-01, ADR 0017 | Latest lane becomes 1.20.4 / OTP 29. Floor lane unchanged. |
| F3 | RISK | `~> 1.8.16` and `~> 1.2.9` forbid Phoenix 1.9 and LiveView 1.3. Phoenix `main` already carries a v1.9 changelog. | ADR 0007, ADR 0018, COMPAT-01 | Proposed OPEN-QUESTIONS OQ-A. |
| F4 | CONTRADICTION | `mix_audit 2.1.5` hard-depends on `yaml_elixir` (YAML library) and `jason`. ADR 0018 lists it as dev/test and bans "any YAML library". | ADR 0018, ADR 0017 | Proposed OPEN-QUESTIONS OQ-B. |
| F5 | GAP | No HTML parser exists in an adopter's **dev** environment. `phx.new` ships `lazy_html` as `only: :test`; Floki is banned. No-browser bundles and the glossary lint need one. | ADR 0010, ADR 0018, CANON-07, LLM-04 | Proposed OPEN-QUESTIONS OQ-C. |
| F6 | GAP | ADR 0025 says the browser runner uses "real media emulation" for reduced motion. PlaywrightEx 0.15.0 exposes **no** `reduced_motion`, `forced_colors`, `contrast` or `emulateMedia`. | ADR 0025, ADR 0011, CHECK-03, MOTION-03/06 | Add to the phase-1 spike. Proposed OQ-D. |
| F7 | RISK | Stdlib `JSON` encodes maps in `:maps.iterator` order, which is not a stable contract. "Byte-identical manifest under permutation" needs a canonical encoder. | ADR 0009, ADR 0010, QA-01 | Write `Fablebook.JSON` (about 15 lines). |
| F8 | GOTCHA | `tailwind` Hex package below **0.5.2** fails to download the binary on OTP 27+ (`header_too_long`). Hex defaults are also stale (Tailwind 4.3.0, esbuild 0.25.0). | ADR 0005, ADR 0017 | Require `~> 0.5.2`; pin tool versions explicitly. |
| F9 | OMISSION | `sbom` (for `mix sbom.cyclonedx`), the QR encoder and (if used) `websockex` are absent from ADR 0018. | ADR 0018, ADR 0017, WB-07 | List them. See sections 3 and 4. |
| F10 | FREE WIN | ExDoc generates `llms.txt` by default since 0.40.0 (2026-01-20). | DOCS-01 | Do not hand-roll `llms.txt` for the library docs. |
| F11 | SECURITY FLOORS | Igniter >= 0.8.4 (CVE-2026-82584); `lazy_html` >= 0.1.13 (CVE-2026-92106); Phoenix security floor is actually **1.8.9**, not 1.8.16. | ADR 0007, ADR 0018 | Raise the Igniter and lazy_html floors. Phoenix floor is an owner question inside OQ-A. |
| F12 | MINOR | DTCG 2025.10 color `$value` is an **object** (`colorSpace`, `components`, optional `alpha`, `hex`), not a hex string. Resolver files use the `.resolver.json` extension. | ADR 0012, CANON-03 | Token reader must accept the object form. Rename `resolver.json` to `*.resolver.json`. |

---

## 2. Recommended Stack

### Runtime dependencies (the prod closure; capped by ADR 0018)

| Technology | Version (latest verified) | `mix.exs` requirement (ADR in force) | Purpose | Why | Confidence |
|------------|---------------------------|--------------------------------------|---------|-----|------------|
| `phoenix` | 1.8.16 (2026-10-20) | `~> 1.8.16` (see OQ-A) | Router macro, `Phoenix.Token`, endpoint/pipeline integration | The host's own pipeline is the product (ADR 0003). 1.8 sets `frame-ancestors 'self'` by default, so a same-origin iframe canvas works. | HIGH |
| `phoenix_live_view` | 1.2.13 (2026-10-20) | `~> 1.2.9` (see OQ-A) | Workbench and canvas LiveViews, `ColocatedHook`, HEEx, `JS` | 1.2.7 (CVE-2026-58228) and 1.2.9 (CVE-2026-64941) are security releases, so 1.2.9 is a justified floor. 1.2.13 is current. | HIGH |
| `phoenix_html` | 4.3.0 (2025-09-28) | `~> 4.1` | `Phoenix.HTML.Safe`, form helpers | ADR 0018 names it without a version. LiveView 1.2.13 allows 3.3 and 4.x. `phoenix_test` requires `~> 4.1`. `phx.new` 1.8.16 uses `~> 4.1`. | HIGH |
| `telemetry` | 1.4.2 (2026-05-11) | `~> 1.0` | `:telemetry.span/3` emission only | ADR 0016: Fablebook emits and never attaches handlers. | HIGH |
| `nimble_options` | 1.1.1 (2024-05-25) | `~> 1.1` | Validate router and Book options | Stable and tiny. Last release is 2.5 years old, which reads as "finished", not "abandoned". `phoenix_test_playwright` also depends on it. | HIGH |

Notes on the prod closure:
- Verified from `hex.pm` requirements: Phoenix, LiveView and `phoenix_test_playwright` all treat `jason` as **optional**, so `jason` is not in Fablebook's `mix deps.tree --only prod`. The "banned jason" rule is satisfiable, but only if the dependency-budget test inspects the prod closure and `lib/`, not the whole lockfile (see F4).
- Elixir requirement in `mix.exs`: `elixir: "~> 1.18"`. Phoenix and LiveView only need 1.15, but `phoenix_test 0.13.1` requires `~> 1.18` and stdlib `JSON` arrived in 1.18 (ADR 0007), so 1.18 is consistent across the whole test toolchain.
- Do not call `Phoenix.json_library/0` for Fablebook's own payloads. It defaults to `Jason` when unset (verified in the 1.8.16 tarball). Call stdlib `JSON` directly. LiveView 1.2 implements both `JSON.Encoder` and `Jason.Encoder` for `JS` structs, so hosts are unaffected.

### Optional dependencies (behind `Code.ensure_loaded?` gateways, ADR 0018)

| Technology | Version | Requirement | Purpose | Why | Confidence |
|------------|---------|-------------|---------|-----|------------|
| `igniter` | 0.8.5 (2026-10-25) | `~> 0.8 and >= 0.8.4` | `mix igniter.install fablebook`, `igniter.upgrade`, migrator | 0.8.4 fixes CVE-2026-82584 (terminal control sequences in Hex install confirmation). Igniter is still 0.x with a monthly cadence, so keep the range loose and the installer thin. It pulls `jason`, `req`, `owl`, `sourceror`, `rewrite`, `spitfire`, `glob_ex`, `ex_ast`, which is fine because it is optional and adopter-side. | HIGH |
| `earmark` | 1.4.49 (2026-06-02) | `~> 1.4` | Richer Markdown for Pages | Maintained (not dormant, as the 2022 pre-release tags might suggest). Zero required dependencies. Default stays the vendored 200-line subset renderer. | HIGH |
| `phoenix_test_playwright` | 0.19.0 (2026-10-17) | `~> 0.19` for adopters; **exact pin** in Fablebook's own lockfile | Opt-in browser capture, sweep, visual baselines | See F1 and section 5. Pre-1.0 with roughly monthly minors, and each recent minor raised the minimum Playwright version. | MEDIUM |

### Dev and test dependencies (Fablebook repo only, never in the prod closure)

| Technology | Version | Requirement | Purpose | Notes | Confidence |
|------------|---------|-------------|---------|-------|------------|
| `ex_doc` | 0.40.4 (2026-09-03) | `~> 0.40` | Docs, `.cheatmd` cheatsheets, `llms.txt` | `llms.txt` and "Copy Markdown" are generated by default since 0.40.0. A Markdown formatter exists (`formatters: ["html", "markdown"]`). | HIGH |
| `credo` | 1.7.19 (2026-06-05) | `~> 1.7` | Eval and atom bans, custom checks | 1.7.19 fixes Elixir 1.20.0 compatibility and warnings. Custom checks that ship to adopters (UX-07) must wrap `use Credo.Check` in `if Code.ensure_loaded?(Credo.Check)`. | HIGH |
| `dialyxir` | 1.4.8 (2026-09-05) | `~> 1.4` | Dialyzer | Key the PLT cache on OTP, Elixir and `hash(mix.lock)` (ADR 0017). | HIGH |
| `stream_data` | 1.4.0 (2026-07-14) | `~> 1.4` | Properties (ADR 0014 T1) | No transitive deps. | HIGH |
| `mox` | 1.3.2 (2026-09-11) | `~> 1.3` | Seams only (ADR 0014) | Depends on `nimble_ownership`. | HIGH |
| `phoenix_test` | 0.13.1 (2026-10-23) | `~> 0.13` | T2 LiveView tests; required by `phoenix_test_playwright` | Requires Elixir `~> 1.18`, `jason`, `lazy_html`. | HIGH |
| `lazy_html` | 0.1.13 (2026-09-25) | `>= 0.1.13` | DOM assertions in tests, oracle for the vendored tokenizer (OQ-C) | 0.1.13 fixes CVE-2026-92106 (`to_html` escaping of `<style>`/`<script>` inside SVG and MathML). Precompiled NIF. LiveView requires `~> 0.1.0`, which allows it. | HIGH |
| `muex` | 0.12.0 (2026-10-21) | `== 0.12.0` (exact, `only: :test`, `runtime: false`) | Mutation testing, weekly lane only | Twelve releases between 0.6.2 (2026-06-26) and 0.12.0. About 3k downloads per week, one dependency (`jason`). Exact pin is right. Never a PR gate. Verify Elixir 1.20 compatibility in the first mutation run. | MEDIUM |
| `tailwind` | 0.5.2 (2026-10-23) | `~> 0.5.2`, `runtime: false` | Build `priv/static/fablebook.css` without Node | Must be >= 0.5.2 (F8). Pin `version: "4.3.3"` in config (Hex default is 4.3.0; Tailwind 4.3.3 is the current release, 2026-07-16, and what `phx.new` 1.8.15+ uses). | HIGH |
| `esbuild` | 0.10.1 (2026-10-19) | `~> 0.10`, `runtime: false` | Build `priv/static/fablebook.js` without Node | Hex default is 0.25.0, npm latest is 0.28.2. Pin explicitly (recommend 0.28.2, rerun the drift check on bump). | MEDIUM |
| `sbom` | 0.12.0 (2026-10-15) | `~> 0.12`, `only: :dev`, `runtime: false` | `mix sbom.cyclonedx` for the release SBOM (ADR 0017) | Missing from the ADR 0018 list (F9). Pulls `hex_core`, `optimus`, `protobuf`, `purl`. | HIGH |
| `mix_audit` | 2.1.5 (2025-06-09) | see OQ-B | `mix deps.audit` | Pulls `yaml_elixir` and `jason`. Conflicts with the YAML ban. | HIGH (the conflict is verified) |
| `benchee` | 1.5.1 (2026-06-06) | `~> 1.5`, **only in `bench/mix.exs`** | Advisory tail latency (ADR 0015) | Correct to isolate it in a sibling project. | HIGH |
| `sobelow` | 0.17.0 (2026-10-28) | latest, on the **host app** only (ADR 0020) | Security scan | Depends on `jason`, which is another reason to run it against `hosts/operator`, not the library. | HIGH |

### Toolchain (not Hex dependencies; pin in `.tool-versions` and CI)

| Tool | Version | Purpose | Notes | Confidence |
|------|---------|---------|-------|------------|
| Elixir (latest lane) | **1.20.4** (2026-08-28) | Latest lane and `.tool-versions` | 1.20 supports OTP 27 to 29. New type checker emits more warnings; the library must be warning-free under `--warnings-as-errors` on **both** lanes. | HIGH |
| Elixir (floor lane) | 1.18.x (1.18.5, 2026-08-28) | Floor lane (ADR 0007) | Security patches only upstream, which is acceptable for a floor. | HIGH |
| Erlang/OTP | 29.1.2 latest; 28.5.0.x and 27.3.4.x maintained | Latest lane on 29, floor lane on 27 | OTP 27 is the minimum Elixir 1.20 supports, so it is also the minimum the project can ever claim. | HIGH |
| Tailwind CLI | 4.3.3 | Chrome CSS | `ColocatedCSS` in LiveView 1.2 needs Tailwind >= 4.2.3 and the `tailwind` Hex package >= 0.5 (docs), which this satisfies. | HIGH |
| Playwright | 1.64.1 (2026-10-14) | Browser runner (opt-in) | `phoenix_test_playwright 0.19.0` and `playwright_ex 0.15.0` both require >= 1.64. | HIGH |
| Playwright image | `mcr.microsoft.com/playwright:v1.64.1-noble` (tag exists; pin by `@sha256` digest at implementation) | Deterministic pixels (ADR 0011) | `resolute` (Ubuntu 26.04) tags now exist; stay on `noble` until a deliberate re-baseline. The image does **not** include the Playwright npm package. | HIGH |
| axe-core | 4.14.0 (2026-10-05, MPL-2.0) | Vendored into `priv/static` | The `wcag22aa` tag exists. Vendor unmodified, keep the license and NOTICE (ADR 0018). | HIGH |
| heroicons | v2.2.0 (MIT) | Vendored subset | Same tag `phx.new` 1.8.16 uses. | HIGH |
| QR encoder | Nayuki QR Code generator (MIT, TypeScript/JS) | "Show on phone" (WB-07) | Missing from every ADR (F9). Vendor into chrome JS. Alternative: `eqrcode 0.2.1` (MIT, zero deps, 2025-02-21) copied in, not depended on. `qr_code 3.2.0` pulls five dependencies and is BSD-4-Clause, so reject it. | MEDIUM |
| GitHub Actions | `erlef/setup-beam` v1.24.1 (supports OTP up to 29, including Ubuntu 22.04/24.04/26.04 runners); `googleapis/release-please-action` v5.0.0; `actions/checkout` v7.0.1; `actions/cache` v6.1.0; `zizmor` 1.31.1; `actionlint` 1.7.12 | CI (ADR 0017) | Tags verified from GitHub releases. Resolve to commit SHAs on day 1 (ADR 0017 requires SHA pins). | HIGH |
| Docs/Hex release | release-please `elixir` release type, `include-v-in-tag`, manifest `0.0.0`, one-time `release-as: 0.1.0` | Per the bootstrap skill | The skill's template copies `~/projects/sigra/.tool-versions` (Elixir 1.19.5 / OTP 28.5). **Override it** to Elixir 1.20.4 / OTP 29 for Fablebook (F2). `fablebook` is still free on Hex (404 on 2026-10-28; no near-name collisions). | HIGH |

---

## 3. Detail on the findings

### F1. phoenix_test_playwright 0.19.0 (STALE, ADR 0011)

Verified from the 0.19.0 tarball, its CHANGELOG, and hexdocs:
- `assert_screenshot/3` only exists since **0.15.0 (2026-06-19)**. It is four months old. Options: `:selector`, `:clip`, `:mask`, `:mask_color`, `:animations` (default `"disabled"`), `:caret`, `:scale`, `:full_page`, `:omit_background`, `:snapshot_dir`, `:threshold`, `:max_diff_pixels`, `:max_diff_pixel_ratio`, `:timeout`.
- **Default `:threshold` is 0.2** (YIQ), not 0.1. `QUALITY-PERF-SRE.md` states 0.1 as the recipe default, so pass `threshold: 0.1, max_diff_pixels: 0` explicitly and never rely on defaults.
- **A missing baseline is written and the test passes** (confirmed in source: `{:ok, actual_b64}` falls through to `write_file!/2`). There is no config switch. ADR 0011's guards are therefore required, and the simplest one is a pre-check in `Fablebook.Test.Visual`: if the baseline file does not exist and the accept flag is not set, fail before calling `assert_screenshot`. Keep the `git status --porcelain` check as the second guard.
- Updating a baseline is "delete the file and rerun", which fits the `bin/visual update` flow.
- Since 0.17.0 (2026-09-08) JS setup uses **pnpm**, not npm. Since 0.19.0 it requires Playwright >= 1.64. Each minor in the last three raised the Playwright floor (1.63, then 1.64), so every `phoenix_test_playwright` bump implies a Playwright bump, which implies a re-baseline PR. ADR 0011/QUALITY already says a Playwright bump gets its own PR; extend that to "any `phoenix_test_playwright` minor bump".
- It depends on `phoenix_test >= 0.12 and < 1.0`, `playwright_ex ~> 0.15`, `phoenix_live_view ~> 1.0`, `phoenix ~> 1.7`, `nimble_options ~> 1.1`. Optional: `websockex`, `ecto_sql`, `phoenix_ecto`.
- It starts a supervisor from `test_helper.exs` (`PhoenixTest.Playwright.Supervisor.start_link/0`). That is test-only and consistent with "zero processes in the host" (ADR 0005).

What the phase-1 spike can already close from source (PlaywrightEx 0.15.0, 2026-10-17):

| ADR 0011 criterion | Evidence | Status |
|---|---|---|
| 1. ARIA snapshot access | `PlaywrightEx.Frame.aria_snapshot_json/2` exists (`ariaSnapshotJSON`). `phoenix_test_playwright` does not wrap it, so call it through `unwrap/2`. Output is JSON; the bundle's `aria.yaml` is emitted by our own serializer (string building, no YAML library). | Likely passes |
| 2. Byte-identical screenshots in the pinned container | Not testable from source. Playwright's own comparator (`expect_screenshot`) does the diff. | Spike must test |
| 3. `securitypolicyviolation` listener | `add_init_script/2` (context and page) and `evaluate/4` exist. | Likely passes |
| 4. WebSocket frame byte counts | No Playwright API in the wrapper. But PERF-03 is measured server-side in LiveViewTest (ADR 0015), so this criterion is not needed for the gate. Recommend dropping it from the reversal triggers. | Not needed |
| 5. axe injection under a strict nonce CSP | Init scripts and `evaluate` run through the Playwright protocol, which is not subject to the page CSP. Do **not** use `bypass_csp: true` (it exists on `new_context`), because it would defeat the fidelity receipt. | Likely passes |
| 6. Sharding | `parameterize:` and browser pools exist; sharding is ExUnit's `--partitions`. | Spike must test |
| 7. (new) Media emulation: reduced motion, forced colors, contrast | **Absent**, see F6. | Blocker candidate |
| 8. (new) Per-rendition viewport | No `Page.set_viewport_size`. `viewport` and `device_scale_factor` are only settable on `Browser.new_context/2`. A sweep over five widths therefore needs a context (session) per width, or must size the iframe via the `vw` URL parameter. Both work. | Design note |

Alternative worth adding to the spike (MEDIUM, documented but untested here): **remote Playwright server mode**. The README documents `ws_endpoint` plus `{:websockex, "~> 0.4", only: :test}` and `browser_pool: false`, and says that with `ws_endpoint` "no local node and playwright is required". Variant B of ADR 0011's container recipe would be: Elixir runs on the normal runner or laptop with `setup-beam` (no BEAM inside the Playwright image), and a pinned `playwright run-server` container supplies browser and fonts. That removes Node/pnpm from the machine running Elixir entirely, which is closer to ADR 0018's "no Node" than the pnpm path. It needs the container to reach the app server (host networking on Linux, `host.docker.internal` on macOS), and the image needs `npx playwright@1.64.1 run-server` because the image ships browsers but not the npm package. The spike should time both variants.

### F2. Elixir 1.20 and OTP 29 (STALE, ADR 0007, COMPAT-01)

- Elixir 1.20.0 shipped 2026-06-03; 1.20.4 on 2026-08-28. Elixir 1.20 supports OTP 27 to 29; 1.19 supports 26 to 28; 1.18 supports 25 to 27. Upstream fixes bugs only on the latest minor and ships security patches for the last five minors.
- OTP 29 is current (29.1.2 on 2026-10-14; 29.0.5 shipped 2026-08-04).
- Proposed lanes, unchanged in structure: **floor** Elixir 1.18.x / OTP 27.3.x with `mix.floor.lock`; **latest** Elixir 1.20.4 / OTP 29.1.x; **canary** LiveView `main` plus latest `phx.new` (nightly).
- Elixir 1.20 adds type-checker warnings (incompatible types, redundant clauses, dead code, unused requires). `mix compile --warnings-as-errors` on the latest lane can therefore fail on code that is clean on 1.18. Keep the gate, and expect the first latest-lane run to need cleanup. Phoenix 1.8.6, Credo 1.7.18+, Igniter 0.8.3 and `phoenix_test_playwright` 0.16.0 all shipped 1.20 compatibility fixes, so the ecosystem is ready.
- Hard deprecations in 1.20 worth a grep before writing code: `xref: [exclude: ...]` is replaced by `elixirc_options: [no_warn_undefined: ...]`; `Kernel.ParallelCompiler.async/1` is replaced by `pmap/2`; bit-pattern `size(var)` now requires the pin operator.
- New compile option `module_definition: :interpreted` can reduce compile time on large projects. Relevant to PERF-05 (host compile overhead); do not enable it in the library, but note it in the docs as an adopter mitigation.

### F3. Version-range policy (RISK, ADR 0007 and ADR 0018)

ADR 0007 and PROJECT.md constrain the library to `Phoenix ~> 1.8.16` and `LiveView ~> 1.2.9`. In Elixir, `~> 1.8.16` means `>= 1.8.16 and < 1.9.0`, and `~> 1.2.9` means `>= 1.2.9 and < 1.3.0`. Evidence:
- Phoenix `main` already has a "Changelog for v1.9" (with fixes and enhancements listed). LiveView `main` has "Changelog for v1.3 / Empty so far". Hex has no 1.9 or 1.3 release or release candidate today, but both are in motion.
- `phoenix_storybook 1.5.0` uses `phoenix ~> 1.8.1` and `phoenix_live_view ~> 1.1.21 or ~> 1.2.0`. `LESSONS-LEARNED.md` lists "Tight Phoenix/LiveView version pins" as an owner-hit footgun and "breaks on every Phoenix/LiveView minor" as the most common maintenance complaint.
- LiveDashboard 0.9.1 (`phoenix_live_view ~> 1.0`) and Oban Web 2.13.1 (`phoenix ~> 1.7`, `phoenix_live_view ~> 1.0`), the two models ADR 0005 cites, use wide ranges.
- `QUALITY-PERF-SRE.md` already says "LiveView 1.3 will arrive during 0.x".
- With the current ranges, the day Phoenix 1.9 or LiveView 1.3 ships, every adopter who upgrades hits a resolver conflict until Fablebook publishes a release. That is the incumbent's failure mode, and the canary lane exists precisely to catch breakage early rather than to block resolution.

**Proposed OQ-A** (add to `.planning/intent/OPEN-QUESTIONS.md`, recommended answer in the last column):

| # | Question | Recommended answer |
|---|---|---|
| OQ-A | Express the version floors as `">= 1.8.16 and < 2.0.0"` (Phoenix) and `">= 1.2.9 and < 2.0.0"` (LiveView) instead of `~>`, so Phoenix 1.9 and LiveView 1.3 are never blocked by the resolver? The floor lane, canary lane and compatibility matrix remain the safety net. Should the Phoenix floor be 1.8.16 (latest patch, bug-fix floor) or 1.8.9 (the actual security floor: CVE-2026-56811 and CVE-2026-56812)? | Yes to the open upper bound (same policy LiveDashboard uses). Keep 1.8.16 for Phoenix only if the owner wants the phoenix.js connection-race fixes in 1.8.16; otherwise 1.8.9 widens adopter compatibility at no security cost. Note that at 1.8.16 the "floor lane" equals the latest Phoenix, which weakens it as a signal. |

Do not silently apply this. ADR 0007 and PROJECT.md stay as written until the owner decides.

### F4. mix_audit versus the YAML ban (CONTRADICTION, ADR 0018)

- `mix_audit 2.1.5` requires `jason ~> 1.4` and `yaml_elixir ~> 2.11` (and therefore `yamerl`). ADR 0018 lists `mix_audit` under dev/test and also says "Banned: ... any YAML library".
- Also, `igniter` (`jason ~> 1.4.5`), `phoenix_test` (`jason ~> 1.4`), `muex` (`jason ~> 1.4`) and `sobelow` (`jason ~> 1.0`) put `jason` into Fablebook's own dev/test `mix.lock`.
- So the literal reading of the bans cannot be enforced against `mix.lock`. It can be enforced against (a) the prod closure (`mix deps.tree --only prod`), (b) Fablebook's own `mix.exs` direct dependencies, and (c) `lib/` references.

**Proposed OQ-B:**

| # | Question | Recommended answer |
|---|---|---|
| OQ-B | Define the ADR 0018 bans precisely: "no banned package in the prod closure, none declared directly in `mix.exs`, none referenced from `lib/`", with the dependency-budget test written to that definition? And replace `mix_audit` with `mix hex.audit` (built in, retired packages) plus OSV-Scanner in the `security` job (no Elixir dependency)? | Yes to both. It keeps the lockfile free of `yamerl` and removes the only contradiction. If the owner prefers `mix_audit`, the test definition above still works and only the lockfile gains `yaml_elixir`. |

### F5. HTML parsing in an adopter's dev environment (GAP, ADR 0010 and ADR 0018)

- `phx.new` 1.8.16 generates `{:lazy_html, ">= 0.1.0", only: :test}`, `{:phoenix_html, "~> 4.1"}`, `{:phoenix_live_view, "~> 1.2.0"}`, `{:tailwind, "~> 0.5"}` and `{:esbuild, "~> 0.10"}` (verified from the `phx_new-1.8.16` tarball template). So `lazy_html` is **not loaded in `MIX_ENV=dev`**.
- Fablebook needs to parse **rendered scenario HTML** in the adopter's dev workbench for: the no-browser bundle (markup sanitising, copy extraction, repeated-sibling collapse, ADR 0010), the glossary and retired-wording lint over text nodes and `aria-label`/`title`/`placeholder`/`alt`/`value` (CANON-07), the `phx-*` binding check for static stories (CORE-14), and the Checks tab "no Node" fallbacks.
- Floki is banned. `lazy_html` is dev/test only per ADR 0018. Using `Phoenix.LiveView.TagEngine.Tokenizer` or other LiveView internals contradicts ADR 0007/0008 ("public LiveView APIs only"; "internal TagEngine/HTMLEngine" is footgun item 5 in `LESSONS-LEARNED.md`).
- HEEx output is machine-generated and well-formed, so a purpose-built tokenizer is small: tag open/close, void elements, quoted and boolean attributes, text, comments, raw-text elements (`script`, `style`). Roughly 150 to 250 lines.

**Proposed OQ-C:**

| # | Question | Recommended answer |
|---|---|---|
| OQ-C | Add a vendored `Fablebook.HTML.Tokenizer` (about 200 lines, MIT-compatible original code, `@moduledoc false`) to ADR 0018's vendored list, with `lazy_html` as the property-test oracle in Fablebook's own test suite? The alternative is an optional `lazy_html` gateway, which means the no-browser bundle and glossary lint silently degrade in adopter dev environments that lack it. | Yes, vendor the tokenizer. It matches "copy-paste beats a new dependency" and makes the Checks tab and Copy for LLM work on day 0 without an extra dep. |

### F6. Media emulation gap in the browser runner (GAP, ADR 0025 and ADR 0011)

Verified by unpacking `playwright_ex-0.15.0` and grepping `lib/` for `emulate`, `reduced`, `forced` and `media`: no matches except `aria_snapshot_json`. `Browser.new_context/2` options are `accept_downloads`, `base_url`, `bypass_csp`, `color_scheme`, `device_scale_factor`, `extra_http_headers`, `http_credentials`, `ignore_https_errors`, `is_mobile`, `java_script_enabled`, `locale`, `service_workers`, `user_agent`, `viewport`. `phoenix_test_playwright`'s `browser_context_opts` simply forwards these. `BrowserContext` exposes `clock_install/2` and `clock_fast_forward/2` only, no pause, set-fixed-time or run-for.

Consequences:
- ADR 0025 ("the browser runner uses real media emulation instead" of `[data-motion=reduce]`) is **not achievable through the wrapper today** for `prefers-reduced-motion`. The same applies to `forced-colors` and `prefers-contrast` (CHECK-03 forced colors, MOTION-03 "nothing moves under reduced motion", MOTION-06 CI lane).
- `color_scheme` and `locale` emulation do work, so light/dark and locale sweeps are fine.
- Options, in order of preference: (1) contribute `emulate_media` upstream to `playwright_ex` (small: it is a one-method channel call, and the maintainer is active, with five releases between 2026-09-16 and 2026-10-17); (2) call the protocol method `emulateMedia` on the page through `PlaywrightEx.send/2` (documented "don't use", so wrap it behind one function with a contract test); (3) fall back to the `motion=reduce` canvas global plus injected CSS, and honestly mark the media-query path `not-run` (ADR 0010 honesty rule).

**Proposed OQ-D:**

| # | Question | Recommended answer |
|---|---|---|
| OQ-D | Add "reduced-motion, forced-colors and contrast media emulation" and "per-rendition viewport" as spike criteria 7 and 8 in ADR 0011, and drop criterion 4 (WebSocket frame byte counts, since PERF-03 is measured server-side)? If the media emulation criterion fails the 50-line workaround budget, is a generated `@playwright/test` fallback (already the ADR 0011 reversal path) acceptable for the motion and forced-colors lanes only? | Yes. This is exactly the situation the reversal trigger was written for, and the probe and Evidence schema are runner-agnostic. |

### F7. Canonical JSON (RISK, ADR 0009 and ADR 0010)

Verified in Elixir 1.20's `lib/elixir/lib/json.ex`: the `JSON.Encoder` for `Map` walks `:maps.iterator/1`, whose order is unspecified (small maps happen to iterate in key order, large maps do not). The same file maps atom keys through `Atom.to_string/1`. ADR 0010 and QA-01 require a manifest and bundles that are "byte-identical under any permutation of the catalog" and golden-compared.

Recommendation: one small internal module, `Fablebook.JSON`, with `encode_canonical!/1`. Convert every map to an ordered key/value list (`:maps.to_list(:maps.iterator(map, :ordered))` or `Enum.sort`) and encode it with `:json.encode_key_value_list/2`. That function is exported in the OTP 27 stdlib (verified at tag OTP-27.3.4.19), which is the floor, so nothing extra is needed. Add a property test: shuffle input maps and assert identical bytes. Decoding with `JSON.decode/1` returns string keys and creates no atoms, which satisfies ADR 0004.

### F8. Tailwind and esbuild pins (GOTCHA, ADR 0005 and ADR 0017)

- `tailwind` 0.5.2 (2026-10-23) fixes `{:header_too_long, {:max, 10240}}` when downloading the standalone binary on OTP 27+. Fablebook's floor lane is OTP 27, so older versions fail in CI on a clean cache. Require `~> 0.5.2`.
- Hex package defaults lag: `tailwind` defaults to Tailwind 4.3.0 (latest is 4.3.3, which `phx.new` 1.8.15 adopted); `esbuild` defaults to 0.25.0 (npm latest is 0.28.2). The committed `priv/static` bundle plus drift check (ADR 0005) only works if the versions are pinned explicitly in `config/config.exs`. The drift check should run on one OS (Linux CI) and developers should regenerate through the same mix alias; do not assume byte equality across macOS and Linux without testing it in phase 1.
- LiveView 1.2 `ColocatedCSS` requires Tailwind >= 4.2.3 and the `tailwind` Hex package >= 0.5 (from its moduledoc). Fine, but it is about the host. Fablebook's chrome does not use colocated CSS.
- LiveView's client assets ship as `priv/static/phoenix_live_view.js` (UMD), `.esm.js`, `.cjs.js` and `.min.js`; Phoenix ships `priv/static/phoenix.js`, `.mjs`, `.cjs.js` and `.min.js` (verified in both tarballs). ADR 0005's "read from the host's deps via `Application.app_dir`" works for `phoenix.js` and `phoenix_live_view.js`.

### F9. Items missing from ADR 0018

- `sbom` (dev, for `mix sbom.cyclonedx`).
- A QR encoder, vendored (WB-07). Recommend Nayuki's MIT QR generator in the chrome JS, so no Elixir code and no Hex dependency. Keep the license notice in `priv/static/LICENSES`.
- `websockex` (`only: :test`) only if the remote-server variant of the runner is chosen in the spike.
- `usage-rules.md` (and optionally a `usage-rules/` directory) in the package `files:` list. `usage_rules 1.3.0` collects those files from dependencies when adopters run `mix usage_rules.sync` (SKILL-01), and `phoenix_test_playwright` already follows the convention. Add them to the tarball allowlist test. `usage_rules` itself is an adopter-side tool; Fablebook does not depend on it.

### F10 to F12. Smaller verified items

- ExDoc 0.40.0 (2026-01-20) made `llms.txt` default output. DOCS-01 therefore only needs `llms-full.txt` handled separately (ExDoc's Markdown formatter yields per-page `.md`). Do not hand-write `llms.txt` for the library's own docs. The `llms.txt` in LLM-06 is the adopter's catalog manifest, a different artifact.
- DTCG 2025.10: both the Format Module and the Resolver Module pages carry the date 28 October 2025, are labelled "Final Community Group Report", and say "This specification is considered stable." I could not confirm the phrase "first stable" verbatim on either page. Color tokens are objects (`colorSpace`, `components`, optional `alpha` and `hex`). Tools must preserve `$extensions` they do not understand (matches CANON-03's "`$extensions` preserved"). Resolver files use `.resolver.json`, and light/dark is modelled as a modifier with `contexts` and a `default`. Rename ADR 0012's `tokens/resolver.json` to `tokens/product.resolver.json` when the owner next amends that ADR (low priority, no OPEN-QUESTION needed).
- axe-core 4.14.0 is MPL-2.0. Vendoring the unmodified minified file with its license text is compatible with an MIT package. Never edit the vendored file.

---

## 4. What NOT to use

| Do not use | Why | Instead |
|---|---|---|
| `jason` (direct dependency) | ADR 0018. Stdlib `JSON` covers it from Elixir 1.18. Phoenix and LiveView treat it as optional. | `JSON` plus `Fablebook.JSON.encode_canonical!/1` (F7) |
| `mdex` | ADR 0018. Rust NIF; it is what `phoenix_storybook 1.5.0` still pulls in (`mdex ~> 0.12`). | Vendored Markdown subset; optional `earmark` |
| `floki` | ADR 0018. | Vendored tokenizer (OQ-C); `lazy_html` in tests only |
| `yaml_elixir`, `yamerl`, any YAML library | ADR 0012, ADR 0018. | The strict frontmatter parser (about 300 lines, property-tested). Emit `aria.yaml` by string building. |
| `telemetry_metrics` | ADR 0018, ADR 0016. LiveDashboard hard-depends on it; Fablebook does not need to. | Emit spans only. Document a copy-paste metrics recipe. |
| `mix_audit` (as currently specified) | Drags in `yaml_elixir` (F4). | `mix hex.audit` plus OSV-Scanner, pending OQ-B |
| `qr_code` | BSD-4-Clause, five transitive dependencies (F9). | Vendored Nayuki QR generator |
| `bypass_csp: true` in Playwright contexts | Defeats the CSP fidelity receipt (C3). | Normal contexts; init scripts and `evaluate` already run outside page CSP |
| `Phoenix.json_library/0` in Fablebook code | Defaults to `Jason`. | `JSON` directly |
| `Phoenix.LiveView.TagEngine`, `HTMLEngine`, the macro-components API | Internal and unstable; the cause of repeated incumbent breakage. | Public APIs plus the single `__components__/0` adapter (ADR 0008) |
| `Phoenix.LiveViewTest` helpers in dev code paths | Test-only module. | `fun.(assigns) \|> Phoenix.HTML.Safe.to_iodata()` for the render seam (`Phoenix.LiveView.Rendered` implements `Phoenix.HTML.Safe`, verified) |
| A Hex `only: [:dev, :test]` declaration for `fablebook` itself | Router macros expand inside a false `if`, so a prod compile hits an undefined macro (ADR 0006). | Declare without `only:`; the macro raises under `Mix.env() == :prod` |
| `module_definition: :interpreted` in the library | Less precise stacktraces, and it would hide the compile-cost gate (PERF-05). | Leave to adopters |
| Node, npm or pnpm on adopter machines | ADR 0018. | Everything is committed in `priv/static`. Node appears only inside the opt-in Playwright path (or not at all with the remote-server variant). |
| Branded device art, LLM-API clients, hosted visual-regression services | PROJECT.md Out of Scope. | Generic outlines; context bundles only |

---

## 5. Alternatives considered

| Category | Recommended | Alternative | Why not |
|----------|-------------|-------------|---------|
| Browser runner | `phoenix_test_playwright` 0.19.0, with spike (ADR 0011) | Generated `@playwright/test` spec | Keeps everything in ExUnit and reads the manifest from Elixir. The JS runner stays the documented fallback and the media emulation gap (F6) is the most likely trigger. |
| Browser runner | same | Raw `playwright_ex` 0.15.0 | It is what `phoenix_test_playwright` already wraps. Use it directly only for `aria_snapshot_json`, clock and routes through `unwrap/2`. |
| Mutation testing | `muex` 0.12.0, weekly, exact pin | `muzak` (commercial, capped free tier), Darwin/Exavier (dormant since about 2020) | `muex` is the only active option. Accept the pre-1.0 churn by keeping it off the PR lane. |
| Property testing | `stream_data` 1.4.0 | `propcheck`, `proper` | No transitive dependencies, ships with the ecosystem's conventions. |
| DOM in tests | `lazy_html` 0.1.13 | Floki | Floki is banned; LiveView itself moved to `lazy_html`. |
| HTML in dev (no-browser capture) | Vendored tokenizer (OQ-C) | Optional `lazy_html` gateway | Silent degradation in dev environments without it. |
| Markdown | Vendored subset renderer, optional `earmark` 1.4.49 | `mdex`, `earmark_parser` direct | NIF and size (mdex); `earmark` already wraps the parser. |
| Chrome CSS | Standalone `tailwind` CLI 4.3.3 via the Hex package | daisyUI in the chrome | ADR 0013: ink on neutral, `fb-` OKLCH tokens, namespace reset. |
| Chrome JS bundling | `esbuild` Hex package | Bun, Node bundlers | ADR 0005 and 0018: no Node. |
| Dependency audit | `mix hex.audit` + OSV-Scanner (pending OQ-B) | `mix_audit` | YAML transitive dependency. |
| Installer | `igniter` (optional) with a plain-Mix fallback | Hand-written `mix` patching | `igniter` is the ecosystem standard; `phoenix_storybook` 1.5 and LiveDebugger also use it. Test with `Igniter.Test` (ADR 0014 T3). |
| JSON | Stdlib `JSON` plus a canonical wrapper | `jason` | Banned; and canonical ordering is needed either way. |
| Docs | ExDoc 0.40.4 with Markdown formatter | Hand-built docs site | Native `llms.txt`, `.cheatmd`, Copy Markdown. |
| Release | release-please v5 + manual `hex-publish.yml` recovery | `semantic_release`, manual tags | Matches the owner's bootstrap skill and ADR 0017. |
| Token format | DTCG 2025.10 (object colors, `.resolver.json`) | Style Dictionary JSON, custom | Interop with abracabrand and impeccable (ADR 0012), and the spec is now stable. |

---

## 6. Installation (Fablebook's own `mix.exs`, ADR-compliant ranges, proposed deviations flagged)

```elixir
def project do
  [
    app: :fablebook,
    version: @version,
    elixir: "~> 1.18",
    package: package()
  ]
end

defp deps do
  [
    # Runtime (prod closure). OQ-A would widen the first two upper bounds.
    {:phoenix, "~> 1.8.16"},
    {:phoenix_live_view, "~> 1.2.9"},
    {:phoenix_html, "~> 4.1"},
    {:telemetry, "~> 1.0"},
    {:nimble_options, "~> 1.1"},

    # Optional (Code.ensure_loaded? gateways; lane `--no-optional-deps` proves the library without them)
    {:igniter, "~> 0.8 and >= 0.8.4", optional: true},
    {:earmark, "~> 1.4", optional: true},
    {:phoenix_test_playwright, "~> 0.19", optional: true},

    # Dev and test
    {:ex_doc, "~> 0.40", only: :dev, runtime: false},
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
    {:stream_data, "~> 1.4", only: [:dev, :test]},
    {:mox, "~> 1.3", only: :test},
    {:phoenix_test, "~> 0.13", only: :test},
    {:lazy_html, ">= 0.1.13", only: :test},
    {:muex, "== 0.12.0", only: :test, runtime: false},
    {:tailwind, "~> 0.5.2", only: :dev, runtime: false},
    {:esbuild, "~> 0.10", only: :dev, runtime: false},
    {:sbom, "~> 0.12", only: :dev, runtime: false}
    # mix_audit: see OQ-B. benchee: bench/mix.exs only. sobelow: hosts only.
  ]
end

defp package do
  [
    name: "fablebook",
    files: ~w(lib priv/static priv/LICENSES .formatter.exs mix.exs README.md LICENSE CHANGELOG.md usage-rules.md guides),
    licenses: ["MIT"]
  ]
end
```

```elixir
# config/config.exs (Fablebook repo): explicit pins, never the Hex defaults
config :tailwind, version: "4.3.3"
config :esbuild, version: "0.28.2"
```

```
# .tool-versions (override the bootstrap skill's copy)
erlang 29.1.2
elixir 1.20.4-otp-29
```

Browser lane, opt-in and dev/CI only (never an adopter requirement):

```bash
# Variant A (current ADR 0011 plan): Playwright npm package + pinned container
pnpm --dir assets add --save-dev playwright@1.64.1
# run the e2e job inside mcr.microsoft.com/playwright:v1.64.1-noble@sha256:<digest>

# Variant B (add to the spike): remote server, no Node on the Elixir machine
#   container: npx playwright@1.64.1 run-server --port 3000
#   test config: ws_endpoint: "ws://...", browser_pool: false; dep {:websockex, "~> 0.4", only: :test}
```

---

## 7. Roadmap implications

1. **Phase 1 (walking skeleton):** set `.tool-versions` to Elixir 1.20.4 / OTP 29 and the CI matrix to floor (1.18/27) plus latest (1.20/29); require `tailwind ~> 0.5.2`; write the dependency-budget test to the OQ-B definition; add `Fablebook.JSON` canonical encoder with its permutation property from the start (it underpins every golden). Run the ADR 0011 spike with the revised criteria (F1 table, OQ-D) and both container variants.
2. **Phase 2 (story model and catalog):** the `ComponentInfo` adapter around `__components__/0` is confirmed necessary: it is `@doc false`, generated per module, and sorts attrs and slots by name (verified at `declarative.ex` lines 818-819 on the `v1.2` branch), so re-sort by `line`.
3. **Phase 6/7 (canon, probe):** resolve OQ-C before the glossary lint and no-browser bundle are built (it decides whether a tokenizer is in scope). Token reader must accept DTCG color objects.
4. **Phase 8 (motion):** the spike in the roadmap must include the media-emulation gap (F6); do not promise the CI reduced-motion lane until OQ-D is answered.
5. **Phase 10/11:** QR encoder vendored, `sbom` wired, `usage-rules.md` shipped and allowlisted.
6. **Pre-1.0 policy:** keep a monthly "bump lane" PR for `phoenix_test_playwright` plus Playwright plus image digest plus re-baseline, and a separate PR for any `muex` bump.

---

## 8. Confidence summary

| Area | Confidence | Basis |
|------|------------|-------|
| Phoenix, LiveView, Elixir, OTP versions | HIGH | hex.pm API, GitHub releases, changelogs |
| Security floors (LV 1.2.7/1.2.9; Phoenix 1.8.9; Igniter 0.8.4; lazy_html 0.1.13) | HIGH | Changelogs naming CVEs |
| `phoenix_test_playwright` behaviour (missing baseline, threshold, options) | HIGH | Unpacked 0.19.0 source and hexdocs |
| PlaywrightEx capabilities and gaps | HIGH | Unpacked 0.15.0 source, grep across `lib/` |
| Remote-server variant of the runner | MEDIUM | README documents it; not exercised here |
| Byte-identical screenshots in the pinned container | LOW (untested) | The spike owns this; no evidence either way |
| `muex` suitability on Elixir 1.20 | MEDIUM | Active and recent releases, no direct evidence of 1.20 testing |
| esbuild 0.28.2 pin | MEDIUM | Version confirmed on npm; output stability untested |
| QR encoder choice | MEDIUM | Licenses and sizes checked, integration not |
| DTCG "first stable" wording | MEDIUM | Both pages say stable and dated 2025-10-28; "first stable" not found verbatim |
| Cross-OS byte equality of the committed Tailwind/esbuild bundle | LOW (untested) | Assume Linux-only drift check until proven |

## Sources

- hex.pm API: package and release pages for `phoenix`, `phoenix_live_view`, `phoenix_html`, `telemetry`, `nimble_options`, `igniter`, `earmark`, `phoenix_test_playwright`, `playwright_ex`, `phoenix_test`, `lazy_html`, `stream_data`, `credo`, `dialyxir`, `mox`, `muex`, `mix_audit`, `ex_doc`, `tailwind`, `esbuild`, `benchee`, `sbom`, `sobelow`, `usage_rules`, `phoenix_storybook`, `phoenix_live_dashboard`, `oban_web`, `qr_code`, `eqrcode`, `fablebook` (404)
- Phoenix `v1.8` and `main` CHANGELOG; `phx_new-1.8.16` tarball (`templates/phx_single/mix.exs.eex`); `phoenix-1.8.16` tarball (`priv/static`, `lib/phoenix.ex`)
- Phoenix LiveView `v1.2` branch CHANGELOG, `main` CHANGELOG, `declarative.ex`, `colocated_js.ex`, `colocated_css.ex`; `phoenix_live_view-1.2.13` tarball
- Elixir `v1.20` CHANGELOG, compatibility table, `lib/elixir/lib/json.ex`; GitHub releases for Elixir and Erlang/OTP; OTP-27.3.4.19 `json.erl` and `maps.erl`
- `phoenix_test_playwright` CHANGELOG, README, hexdocs and 0.19.0 tarball; `playwright_ex` CHANGELOG, source tree and 0.15.0 tarball
- Igniter CHANGELOG and hexdocs; ExDoc CHANGELOG; Credo CHANGELOG; lazy_html CHANGELOG; Tailwind and esbuild Hex package CHANGELOGs
- GitHub releases: Playwright, Tailwind CSS, erlef/setup-beam, googleapis/release-please-action, actions/checkout, actions/cache, zizmor, actionlint; npm registry: axe-core, esbuild, qrcode-generator, storybook
- Playwright Docker docs and the `mcr.microsoft.com/playwright` tag list
- Design Tokens Format Module 2025.10 and Resolver Module 2025.10 (designtokens.org)
- Project Nayuki QR Code generator README (MIT)
- Project files read: `CLAUDE.md`, `.planning/PROJECT.md`, NORTH-STAR, CLEARANCE, OPEN-QUESTIONS, GLOSSARY, ADRs 0005, 0006, 0007, 0010, 0011, 0012, 0014, 0015, 0017, 0018, 0019, 0020, 0025, `docs/research/STACK-FACTS.md`, `QUALITY-PERF-SRE.md`, `LESSONS-LEARNED.md`, and the `bootstrap-elixir-hex-lib` skill
