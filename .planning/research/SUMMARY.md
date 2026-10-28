# Project Research Summary

**Project:** Fablebook
**Domain:** Storybook-style workbench and design-canon catalog for Phoenix LiveView, shipped as a Hex library, with LLM context bundles as the owner's primary motivation
**Researched:** 2026-10-28
**Confidence:** MEDIUM-HIGH (HIGH on versions and on the problems found; MEDIUM on fixes that still need a spike)

> **Precedence.** Verbatim intent > ADR > REQUIREMENTS > PROJECT. Nothing here overrides an ADR or owner wording. Every finding that touches one is a proposed owner question (Q6 to Q30, below), with a recommended answer. The phase re-cut assumes the recommended answers and marks which phases are provisional on which question.
>
> **Legend.** `STACK F n` = finding n in STACK.md. `ARCH A/B/O n` = flag n in ARCHITECTURE.md. `PF n` = Pitfall n in PITFALLS.md (E1 to E3 are its experiments). `P n` = a phase in the re-cut below. Detail lives in the four research files; this file does not repeat it.

## Executive Summary

Fablebook is a Storybook-style workbench and design-canon catalog for Phoenix LiveView, built in the LiveDashboard mould. A router macro mounts two live sessions. The library starts zero processes in the host. The catalog is a pure function over compiled story modules, a render seam runs outside any LiveView, and the canvas is a same-origin iframe through the host's own root layout. All four researchers independently confirm this architecture is sound and matches the one proven packaging pattern. The five-package runtime set is right and minimal. PROJECT.md's 127 requirements are a strict superset of what seven comparable tools ship: of 32 table-stakes capabilities, 25 are covered, 5 partial, 1 deliberately deferred (static export) and 1 not applicable. Nothing should be deleted, and no ADR needs overturning.

What research changes is the detail underneath. About 25 points in the locked wording are wrong, stale or unspecified, and several would hurt if found late.
- **Prod guard.** As worded, it breaks every adopter's prod build, because a macro-body raise fires even inside a false `if` (E1).
- **Story discovery.** Discovery through `Application.spec` misses newly added stories until a restart (E2).
- **Stacked grid.** The single-document grid cannot honour CANVAS-03 and cannot show Screens correctly.
- **Render seam.** It cannot render LiveComponent subjects (verified in LiveView source).
- **Dark mode.** No document says how the host applies dark mode or a Theme. Media-feature Globals (reduced motion, forced colors) cannot be switched from page JavaScript, so "finds exactly what CI finds" cannot be literally true.
- **Browser runner.** `phoenix_test_playwright` 0.19.0 has no media emulation, auto-accepts a missing baseline and defaults to a looser threshold (0.2) than the project's visual recipe (0.1 and 0 differing pixels, QUALITY-PERF-SRE).
- **Stale versions.** Elixir is 1.20.4 on OTP 29, not 1.19/28. The `~>` ranges would block Phoenix 1.9 and LiveView 1.3 the day they ship.

The recommended approach is to keep the architecture and the 12 ordering families, but re-cut them into **35 sequential phases of 3 to 5 plans each**. Eight of the 12 families exceed the 5-plan cap as scoped; the rule is split, never compress.
- **Pull forward** what de-risks the Core Value: `Fablebook.Error` and telemetry, crash containment, `generate_tests`, a thin no-browser bundle slice, the installer core, and early dogfood upgrades.
- **Push later** what needs canon or probe data: To review, revision Compare, evidence-staleness Diagnostics, A11Y-02 and JOURNEY-03.
- **Spikes first.** Put each spike first in the phase that depends on it: the runner (P2), grid (P7), CSSOM and host scheme (P8), forced states (P23), motion time shim (P25).
- **Publish 0.1.0 last in P1**, only after the prod-guard cases are green and the unpacked tarball is inspected.

The main residual risks are quiet gate erosion and schedule coupling.
- **Gate erosion.** Defaults looser than the recipe, bulk Waivers and Draft, re-based performance references, phases that overrun. Mitigations: explicit thresholds asserted by a test, ratcheted Waivers, DECISION-only reference changes, and split-not-compress.
- **Schedule coupling.** abracabrand is "not fully developed", the dogfood repos are on LiveView 1.1.x, and the 14-day soak sits at the end. Mitigations: start the upgrades now, keep a minimal-token fallback, and accept per-repo merged PRs as the dogfood-phase evidence.

## Key Findings

### Recommended Stack

The ADR 0018 runtime set holds: `phoenix`, `phoenix_live_view`, `phoenix_html`, `telemetry`, `nimble_options`. `jason` is optional in Phoenix, LiveView and `phoenix_test_playwright`, so the "banned jason" rule is satisfiable only if the dependency-budget test inspects the prod closure and `lib/`, not the lockfile (Q19). Every version below was read from a primary source on 2026-10-28. The corrections to the ADR text are in STACK F1 to F12.

**Core technologies (full table: STACK.md section 2):**
- **Phoenix 1.8.16 and LiveView 1.2.13:** the host's own pipeline is the product. LiveView 1.2.7 and 1.2.9 are security releases, so the 1.2.9 floor is justified. The upper-bound policy and the Phoenix floor (1.8.9 is the actual security floor) are Q12.
- **Elixir 1.20.4 / OTP 29.1.x (latest lane), 1.18 / OTP 27 (floor lane), LiveView `main` (canary):** this replaces the "1.19/28" in ADR 0007. 1.20 adds type-checker warnings, so the library must be warning-free under `--warnings-as-errors` on both lanes. Override the bootstrap skill's copied `.tool-versions`.
- **Stdlib `JSON` plus an internal `Fablebook.JSON.encode_canonical!/1`:** `JSON.Encoder` for maps follows `:maps.iterator` order, which is not a contract. Use OTP 27's `:json.encode_key_value_list/2` with sorted keys, plus a permutation property. This underpins every golden, the manifest and the bundles (STACK F7).
- **`igniter` >= 0.8.4 (0.8.5 current), `earmark` 1.4.49, `phoenix_test_playwright` 0.19.0 (exact pin):** all optional. 0.8.4 fixes CVE-2026-82584. `phoenix_test_playwright` needs Playwright >= 1.64 (current 1.64.1). Each recent minor raised the Playwright floor, so every bump of it is a re-baseline PR.
- **Tailwind CLI 4.3.3 through `tailwind ~> 0.5.2` (below 0.5.2 fails on OTP 27+), and `esbuild` pinned explicitly (0.28.2):** no Node for adopters. The committed chrome bundle's drift check runs on Linux CI only until cross-OS byte equality is proven.
- **Vendored:** axe-core 4.14.0 (MPL-2.0, NOTICE, hash test), heroicons v2.2.0, the fuzzy scorer, the Markdown subset renderer and the frontmatter parser. Proposed additions: an HTML tokenizer (Q20) and Nayuki's MIT QR generator in the chrome JS (Q21).
- **Dev and test only:** `credo` 1.7.19, `dialyxir` 1.4.8, `stream_data` 1.4.0, `mox` 1.3.2, `phoenix_test` 0.13.1, `lazy_html` >= 0.1.13 (CVE-2026-92106), `ex_doc` 0.40.4 (generates `llms.txt` by default), `sbom` 0.12.0, `muex` 0.12.0 (exact pin, weekly lane only), `benchee` in `bench/` only, `sobelow` on host apps only.
- **DTCG 2025.10:** colour `$value` is an object, resolver files are `*.resolver.json`, and unknown `$extensions` must survive a round trip (Q30).

**Do not use:** `mix_audit` as specified (it pulls `yaml_elixir` and `jason`), `qr_code` (BSD-4-Clause, five dependencies), `bypass_csp: true` in Playwright contexts (it defeats the CSP fidelity receipt), `Phoenix.json_library/0` (defaults to Jason), and LiveView's `TagEngine`/`HTMLEngine` internals.

### Expected Features

The 127 REQs are coherent and complete against the field. The detail is in FEATURES.md sections 1 to 6.

**Must have (table stakes, all in the REQs):**
- Faithful render in the host's real CSS, fonts and JS (CANVAS-01).
- Several named scenarios with stable addresses, a tree with search (CORE-01 to 06, WB-03).
- Typed controls with reset (CTRL-01, 02).
- All scenarios on one page, with a generated attr/slot Reference (WB-02).
- Viewport, color scheme, Theme and locale switching (CTRL-04, WB-06).
- All state in the URL (CTRL-03).
- Event log, live reload, keyboard map, Pages with live embeds, open in editor.
- axe-based checks, visual regression, scenarios as tests (CHECK-05).
- Installer, migrator, agent-readable manifest, never in prod by accident.

**Partial today (gaps found, proposed fixes in the requirements section):**
- Host scheme/Theme mechanism: CTRL-05.
- Check status provenance: WB-17.
- Viewport height and orientation: WB-18.
- Sidebar filters: WB-03 amendment.
- An interaction-testing path: DOCS-01 amendment.

**Should have (differentiators, all already in the REQs):**
- LLM context bundles with a budget allocator, ten focuses, redaction and goldens (LLM-01 to 08).
- Design canon as content with Citations from scenarios (CANON-*).
- Four tiers up to whole Screens.
- Scenario = named Situation, with Coverage and Gaps.
- Strict-by-default with reasoned Waivers and a Ratchet.
- The motion lane, Journeys with Step checks, and Compare along exactly one axis.
- A Checks tab that runs the same probe as CI, render modes, and forced-state/UX checks.
- The Review queue, generic device frames, the generator-emitted story convention, twins, the phoenix_storybook migrator, and security by construction.

**Defer (already decided):**
- v1.x: static export with a "Needs server" badge (first), the MCP adapter, stories shipped inside dependencies, the L4 judge recipe, and the print, data-viz, density and information-scent checks. Candidates from this research: source permalinks, a grid overlay, click-to-inspect-token.
- v2: a hosted interactive mode, and event record/replay.

**Anti-features to add to Out of Scope (additive):** usage telemetry that phones home, markup snapshot assertions in generated tests, and a free-form `parameters` bag. None conflicts with intent.

### Architecture Approach

One-way chain: declaration, then pure catalog, then render seam, then canvas, tests and bundles. The pure core (layers L0 to L4) never references LiveView server processes or the UI, which is what lets the Checks tab, sweep, generated tests and bundles run identical rules. View state lives in the URL; PubSub is only an optimization over re-navigating the canvas. Render once in a monitored, heap-capped, time-capped process before any live render. Record "index and render are separate": the sidebar of 5000 scenarios never runs a scenario function.

**Major components (ARCH Component table):**
1. **Story, Scenario, Book:** compile-time metadata only; `__fablebook_story__/0`; at most 20 injected lines.
2. **ComponentInfo:** the only reader of `__components__/0`. It returns a normalized Contract with a total-order fallback, and degrades to manual controls, never a crash.
3. **Catalog (pure) and Canon:** `Canon.load/1` is the single IO boundary. `Catalog.fetch(book, id)` resolves one Story by string match, never `Module.concat` or atoms.
4. **Rules registry:** one registry with stable ids, `needs` declarations and one severity resolver (Waiver, Draft, "warning until prerequisite exists", `not-run`). Every surface calls it.
5. **Render seam:** build, Contain, Normalize, hash, with purposes canvas, test, bundle, export. One `Normalize` feeds the hash, goldens and redaction.
6. **CanvasLive and StaticCanvasController:** the canvas live_session sets no `root_layout`. CanvasLive absorbs unhandled events and navigation.
7. **WorkbenchLive with an internal `Panel` behaviour:** panels register as their data arrives.
8. **Evidence, Probe and Capture:** Capture is the single runner boundary shared by baselines, sweep, `--browser` bundles, shots and filmstrips. Evidence is keyed by render hash.
9. **Manifest, Bundle, Testing, Doctor, Installer, Telemetry, Error.**

DOMAIN-MODEL section 3 omits Rules/Waiver, Globals, Capture, Journey, Motion, Verdicts/Ratchet and Doctor. Add them before P3 planning (ARCH B1). Proposed public surface: nine library modules plus ten Mix tasks (19, under the 25 cap). The workbench and canvas are same-origin, so the workbench can read the canvas directly with no postMessage protocol.

### Critical Pitfalls

Top five by consequence (full list of 35: PITFALLS.md).

1. **Prod guard raised at macro-expansion time (PF1, E1).** A raise in the macro body fires even inside the installer's false `dev_routes` block, so every adopter's prod build fails. Emit the `raise` in the macro's returned code. Add two prod-build CI cases and publish 0.1.0 only after both are green (Q7).
2. **Single-document grid (PF4, ARCH A1).** One DOM means shared ids, shared `fixed` and viewport-unit behaviour, one viewport width, and one process that a runtime crash takes down. Use per-tile native-lazy iframes by default and let the P7 spike decide where stacking is safe (Q8).
3. **Stale `Application.spec` discovery (PF2, E2).** New stories are invisible until restart, silently, on the evaluator's first action. Discover from the compiled `.app` or ebin beams behind a `Discovery` seam, with a test that adds and deletes a story module (Q13).
4. **Media-feature Globals give false passes (PF11, STACK F6, CTRL-05).** Page JavaScript cannot set `prefers-reduced-motion`, color scheme, forced colors or real `:hover`. Label interactive Globals "Simulated", give `pass` only from the runner lane, make the host scheme strategy a Book option, and amend CHECK-02 (Q10, Q11, Q9).
5. **Visual-gate erosion (PF7, PF8, PF28).**
   - Wrapper defaults are `threshold 0.2` (the project recipe says 0.1 and 0 differing pixels), and a missing baseline is written and passes.
   - Apple Silicon baselines differ from CI.
   - Capture readiness ignores the LiveSocket join, nested views, lazy tiles and per-family fonts.
   
   Set the thresholds explicitly and assert them, add a ready-state machine, force the pinned platform, and make reference changes DECISION-only (Q29).

Also load-bearing:
- Compile-time coupling storms, so "touching one component recompiles one story" is false in practice (PF3).
- CSP blocks inline `style=` attributes and the probe's injection path is undefined (PF6).
- Nonce/token randomness in render hashes and goldens (PF9).
- The motion shim can disconnect the canvas (PF10).
- Waiver/Draft inflation (PF13).
- A "contract test" rule with no definition (PF15).
- The 14-day soak starting last (PF18).

## Implications for Roadmap

### Ordering moves the researchers agree on

| Move | Evidence | Where it lands |
|---|---|---|
| `Fablebook.Error`, telemetry catalogue and crash containment earlier. `events/0` is data in `lib/` with a generic test, so new events never edit the test. | ARCH O2, Anti-Pattern 6; PF4 (bomb tests) | Error and telemetry P3; Contain with the seam P4; runtime-crash isolation P7 |
| `Testing.generate_tests` and `assert_manifest_current` right after the seam, so every later phase gets per-scenario tests on the host apps for free. Muex floors start with `Cast` and `URLState`; PERF-02/03/04 gates land with the first chrome. | ARCH O2, smaller items | P4, P5, P11 |
| Thin no-browser bundle slice early, full no-browser tier right after canon. | FEATURES section 9.2; ARCH O5 | P6, then P19 |
| Installer core earlier, with the pure `Doctor` core alongside CANVAS-05. A throwaway installer shape spike against `hosts/vanilla` ends the canvas family. | ARCH O4; FEATURES 9.6; PF24 | Doctor core P8; spike in P9; installer core P10 |
| Phase 5 items that depend on later data move later. | ARCH O3; FEATURES section 3; PF14 | See the table below |
| Early dogfood: LiveView 1.2 upgrade PRs from P3, a 0.x release installed read-only in one dogfood repo after P9, real-component acceptance in P9, nightly self-test history from P22. | ARCH O6; PF18 | P3, P9, P22, P35 |
| JOURNEY-03 (filmstrip UI) has no phase in the seed. Place it with the Step checks. The `journey` bundle focus stays with the other focuses. | ARCH B6 | P24 (UI), P29 (focus) |
| Spikes sit inside the phase that needs them, never in a proof-only phase. | ADR 0021; ARCH flags | P2, P7, P8, P23, P25 |

The Phase 5 items that move:

| Item | Needs | Moves to |
|---|---|---|
| To review page (the sidebar badge shell may exist earlier) | canon items, then findings | P15, extended in P22 |
| Compare by Theme and Direction | canon | P15 |
| Compare by revision (against committed Baselines) | Capture | P22 |
| Diagnostics: evidence staleness | Evidence | P22 |
| A11Y-02 (chrome passes its own sweep) | sweep | P22 |
| Journeys sidebar data | canon | P15 |

Compare by Globals and Diagnostics for catalog and crashes stay in P13.

### Where the researchers differ and the call made

- **Phase count.** ARCH estimates about 27. This cut is 35 because it also splits the bundle work into thin slice and full tier, splits motion into spike/panel and tokens/lane, splits Capture from Sweep, splits UX checks into two phases, makes the installer core its own phase, and splits the twin content track in two. Packing every phase to 5 plans would reach about 30; this file does not recommend that, because P2, P7, P8, P23 and P25 each carry spike-failure risk that needs room to split (Q6).
- **Thin bundle timing.** FEATURES says phase 3 or 4; ARCH says after canon. Resolution: both. P6 ships `mix fablebook.bundle <scenario>` with markup, Contract, desc and Citations as data, and redaction, labelled no-browser. P19 adds the canon `context/`, all selectors, the schema and three goldens. The "Copy for LLM" button arrives with the chrome in P11.
- **Grid default.** ARCH: per-tile native-lazy iframes, with stacking allowed for Primitive and Pattern if the spike passes. PF4: per-tile iframes, or static-render tiles. Resolution: ARCH's default, with static tiles as the fallback past about 12 live tiles (Q8).
- **Spike criteria numbering.** STACK and ARCH each add "criterion 7 and 8" with different content. Resolution: renumber 7 to 13 as in Q9.
- **QR encoder.** STACK: Nayuki MIT JS in the chrome. PF30: a vendored Elixir encoder, a browser script or an ADR-justified dependency. Resolution: Nayuki JS, no Elixir code (Q21).
- **Phoenix floor.** 1.8.16 versus the true security floor 1.8.9 (Q12).

### Consolidated phase re-cut

Granularity is Fine: 35 sequential phases of 3 to 5 plans (plan counts are estimates, MEDIUM confidence), each ending in a merged green PR. Keep the 12 families as headings in ROADMAP.md and number phases sequentially (`phase_naming: sequential`). "Pulled forward" marks a family-9, 10 or 7 item moved earlier. "Provisional on" lists the proposed open questions whose recommended answer the cut assumes.

| P | Phase (family) | Delivers (REQ ids) | Plans | Avoids / provisional on | Research |
|---|---|---|---|---|---|
| 1 | **Release pipeline, CI gate and guards** (F1) | REL-01 via the bootstrap skill (override tool versions); CI-01 with caps test and an actions-dir line cap; INTENT-01; SEC-02 router macro with the guard in returned code and two prod-build cases; SEC-01 extended Credo bans and the `style=` check; dependency-budget test; `Fablebook.JSON`; exact-file-list tarball test, formatter exports, `usage-rules.md`; **0.1.0 published last**, after unpacking the tarball | 4 | PF1, PF3 (xref gate, Book as literal alias), PF12, PF15, PF16, PF26, PF27. Q7, Q12, Q15, Q19 | Standard (checklist) |
| 2 | **Walking skeleton** (F1) | Minimal story and canvas slice in hand-wired `hosts/vanilla`; skeleton `hosts/operator` (nested mount, strict nonce CSP, self-hosted fonts, custom tokens); one LiveViewTest; one visual check with all baseline guards and explicit thresholds; the **runner spike** on the unified criteria (closes Q1) | 4 | PF6, PF7, PF29. Q9 | **Spike** |
| 3 | **Story model and catalog** (F2) | CORE-01 to 07 (citation shape only); Discovery seam with add/delete test; ComponentInfo with the 3-lane contract test and fixture list; Unstoried (CORE-05); `Fablebook.Page` and the `:page` kind; TEL-01 to 03 (`Fablebook.Error`, `events/0`); PERF-01; layering xref test; DOMAIN-MODEL section 3 extended | 5 | PF2, PF3, PF17, PF31. Q13, Q24 | Light (`__components__` shape on canary) |
| 4 | **Render seam, rules engine, generated tests** (F2, CHECK-05 pulled forward) | CORE-09 seam (build, Contain, Normalize, hash); CORE-14 render-mode metadata; CORE-15 `unsupported_subject`; LLM-06 manifest and drift with canonical JSON; CORE-12/13 Rules registry with Waivers, Draft and ratchet; CHECK-05; vendored HTML tokenizer | 5 | PF9, PF13, PF28. Q14, Q16, Q20 | Light (Normalize against real core components) |
| 5 | **Controls and URL state** (F3) | CTRL-01 to 04 (Globals type and codec); CTRL-06; SEC-01/05 properties and mutation-proven tests; Muex floors begin | 4 | PF12 | Standard |
| 6 | **Thin bundle slice** (F9, pulled forward) | LLM-01 (scenario selector, Mix task), LLM-02 skeleton, LLM-04 no-browser level, SEC-04 redaction, `fablebook.bundle/1` schema skeleton, one golden | 3 | PF9. Q20 | Standard |
| 7 | **Canvas isolation and containment** (F4) | CANVAS-01 to 04 and the grid **spike** and decision; CANVAS-07; CORE-10 Placement; signed topic; runtime-crash containment; nonce'd Placement CSS; iframe `src` history hook; static canvas controller | 5 | PF4, PF5, PF6, PF19, PF21. Q8, Q23 | **Spike** |
| 8 | **Canvas diagnostics, hot reload, Globals** (F4) | CANVAS-05 on the pure Doctor core; CANVAS-06; CTRL-05 with the CSSOM spike; locale, dir, motion attribute and device frames applied; the ready-attribute state machine | 4 | PF8, PF11, PF20, PF32. Q10, Q11, Q13 | **Spike** |
| 9 | **Operator host, fidelity receipt, real components** (F4) | Complete `hosts/operator` (QA-04); C3 fidelity E2E spec; CORE-16 fixture helper; 0.x release installed read-only in one dogfood repo; ten real mailglass components; throwaway installer shape spike | 4 | PF18, PF22. Q22 | Standard (CORE-16 MEDIUM) |
| 10 | **Installer core** (F10, pulled forward) | INST-01 (mount, `elixirc_paths`, live_reload, formatter, Book, welcome page, sample story); plain-Mix fallback; installed tree equals the hand-wired tree (golden); apply-twice and partial-state goldens; prod compile of the result | 4 | PF24, PF33. Q17 | Standard (test-driven) |
| 11 | **Chrome shell, sidebar, story page, grid** (F5) | WB-01, 02, 08, 09; A11Y-01 basics; internal `Panel` behaviour; PERF-02/03/04; Markdown subset; Copy for LLM; WB-17 dots | 4 | PF6 | Standard |
| 12 | **Inspector, toolbar, palette, keyboard** (F5) | WB-03 (with filters), 04, 05 (Attrs, HEEx, Events), 06, 11, 15 (toolbar tool), 18; CTRL-02 | 4 | PF6 | Standard |
| 13 | **Mobile layout, QR, microcopy, Compare (Globals), Diagnostics** (F5) | WB-07, 10; WB-13 on Globals axes with a canvas cap; WB-12 catalog and crash parts; A11Y-01 contrast matrix | 4 | PF20, PF30. Q21 | Standard |
| 14 | **Canon core** (F6) | CANON-01, 02, 03, 09, 12; `Canon.load/1`; CORE-11 page embeds | 4 | PF12. Q30 | Light (abracabrand DTCG subset) |
| 15 | **Foundations, Themes, Directions, citations, coverage, To review** (F6) | CANON-04, 08, 10, 11; CORE-03 existence and enforcement; CORE-08; WB-14; WB-13 Theme and Direction axes; JOURNEY-01 | 5 | PF13. Q16, Q26 | Standard |
| 16 | **Canon lints, tokens task, DESIGN.md** (F6) | CANON-05, 06 (DESIGN.md only), 07; UX-06 | 4 | PF31. Q27 | Light (design.md spec is alpha) |
| 17 | **Content track I** (F6) | DOCS-04 brand book; Logistify family (3 Books) with canon, Shell, Areas, Screens; minimal-token fallback | 3 to 5 | External cadence | n/a |
| 18 | **Content track II** (F6) | Chatly and Clinicly twins (QA-06) | 3 to 4 | External cadence | n/a |
| 19 | **Bundle core, no-browser tier with canon** (F9, pulled forward) | LLM-01 all selectors; LLM-02 `context/`; LLM-06 served at the mount, `llms.txt`, `llms-full.txt`; LLM-07 schema, validate/1, 3 goldens, size budgets; SEC-04 `redact:` | 4 | PF9 | Standard |
| 20 | **Probe, Evidence, Checks tab** (F7) | CHECK-01, 02, 03; LLM-05; WB-05 Checks tab; WB-17 run action | 4 | PF6, PF11. Q11 | Light (probe injection under strict CSP) |
| 21 | **Capture and visual baselines** (F7) | VIS-01 to 03; `Capture`; `Fablebook.Test.Visual`; `bin/visual update`; determinism self-test; CI-02 nightly | 4 | PF7, PF8, PF27. Q9, Q29 | Light (spike result) |
| 22 | **Sweep, Ratchet, verdicts** (F7) | CHECK-04, 06; A11Y-02; WB-13 revision axis; WB-12 evidence staleness; WB-14 findings; contact sheets as CI artifacts | 4 | PF28. Q25 | Standard |
| 23 | **UX checks I** (F7) | UX-01 to 04 | 4 | PF11 | **Spike** (forced states, layout shift) |
| 24 | **UX checks II and journeys** (F7) | UX-05, 08; JOURNEY-02, 03; CANON-06 `.impeccable/design.json` (schema pinned) | 5 | Q27 | Standard |
| 25 | **Motion spike, time shim, Motion panel** (F8) | MOTION-01; "Time shim active" label | 4 | PF10. Q18 | **Spike** |
| 26 | **Motion tokens, checks, CI lane** (F8) | MOTION-02 to 06 | 4 | PF23, PF25. Q9, Q17 | Standard after spike |
| 27 | **Bundle browser tier and allocator** (F9) | LLM-03; LLM-04 `--browser`; LLM-05 stale labels | 4 | PF29 | Standard |
| 28 | **Focus framework and review focuses** (F9) | LLM-08: explore, critique, copy, a11y, layout, consistency, brand | 4 | | Standard |
| 29 | **Compare, journey, motion focuses; gen.screens; skills** (F9) | LLM-08 remainder; MOTION-07; CORE-13 `gen.screens`; SKILL-01, 02 | 4 | | Standard |
| 30 | **Generators, doctor shell, migrator** (F10) | INST-02 (Draft); INST-03; INST-04; skills install | 4 | Q28 | Standard |
| 31 | **Image export, Docker demo, string check** (F10) | WB-16 and `mix fablebook.shot`; INST-06; UX-07 | 4 | PF29 | Light (UX-07 tokenization) |
| 32 | **Guides, generator convention, docs brand** (F10) | DOCS-01 to 03 (stubs accumulate from P1); INST-07; DOCS-04 applied to the docs site, README and Hex page | 5 | | Standard |
| 33 | **Hardening** (F11) | PERF-05 (with the add-a-function row), 06; QA-02 floors; QA-03 API snapshot; QA-05 completion; SBOM; sobelow; hex.audit and OSV | 4 | PF28, PF34 | Standard |
| 34 | **Finanza and Shopadelic twins** (F11) | QA-06 remainder; white-label Themes and Guardrails exercised | 4 | External cadence | n/a |
| 35 | **Dogfood setup** (F12) | Migrate mailglass demo, accrue_admin, sigra stories; CI wiring; per-repo merged PRs are the evidence | 4 | PF18. Q22 | Standard |

The clearance soak (CLEARANCE C1 to C10) follows P35 and is checked by the milestone audit, not a phase.

### Phase Ordering Rationale

- **Dependencies.**
  - Kernel (Error, Globals, ids) comes first, then Catalog and the seam, Controls, Canvas, and the workbench.
  - Rules need canon before they can enforce persona and job citations (P15), and Evidence before they can use `needs: evidence` (P20).
  - Capture precedes sweep, motion filmstrips and browser bundles.
  - Motion tokens (P26) need canon (P14) and Capture (P21).
- **Spikes first.** Each phase that depends on an unproven capability opens with it, and its plan list splits if the spike fails: the runner in P2, grid isolation in P7, the CSSOM rewrite in P8, forced pseudo-states in P23, the virtual-clock shim in P25.
- **Value early.** The seam's `:bundle` purpose is exercised from P6, not P27. The installer goldens catch mount-shape surprises in P9 to P10, not P30.
- **Provisional phases.** P1, P2, P4, P7, P8, P21, P25 and P26 each depend on at least one open question. They can be planned on the recommended answers. Q6, Q7, Q9, Q12, Q13, Q15, Q19, Q20 and Q24 must be answered before P1 to P4 planning, Q14 and Q16 before P4, and Q8 before P7.
- **Contract-test rule.** Several phases create recorded outputs (goldens, snapshots, floors, Baselines). Q15 defines which kind of test the rule covers; until it is answered, plan any contract test edit as its own PR touching no `lib/`.

### Research Flags

Phases likely needing `/gsd-plan-phase --research-phase <N>` or a spike plan:
- **P2:** runner criteria 7 to 13 (media emulation, per-rendition viewport, Mix-task use, dev availability, remote-server option, maintainer-platform determinism, nonce-reuse probe injection).
- **P3:** light. E2 already proves the discovery problem; confirm the `__components__` shape on the canary lane and `import only:` export-edge behaviour with `mix xref`.
- **P4:** light. Normalize rules against real core components; the `live_component` behaviour is verified.
- **P7:** grid isolation with adversarial fixtures. The duplicate-id behaviour in LiveView patching is MEDIUM, not re-verified.
- **P8:** CSSOM media-rule rewrite (LOW until spiked); confirm the Phoenix 1.8 `data-theme` convention against a fresh `phx.new`.
- **P14 and P16:** abracabrand's DTCG subset and `inventory.json` hash pinning; the alpha design.md spec.
- **P20:** probe loading under strict nonce CSP; ARIA JSON to `aria.yaml` serializer.
- **P21:** determinism in the pinned container on both CI and the maintainer's platform.
- **P23:** forcing `:hover` and `:focus-visible` without a mouse (CDP versus stylesheet rewrite on Tailwind v4 output); layout-shift measurement.
- **P25:** virtual clock; 60-second heartbeat at 0.1x (the transport timeout figure is recalled, not verified).
- **P31:** UX-07 hardcoded-string detection without a public HEEx tokenizer.

Phases with standard patterns (skip research-phase): P1, P5, P6, P9 to P13, P15, P19, P22, P24, P26 to P30, P32, P33, P35.

## Proposed OPEN-QUESTIONS entries

For the orchestrator to append to `.planning/intent/OPEN-QUESTIONS.md` (Q6 onward, most important first). The researchers overlapped heavily (version range, grid shape, `Application.spec`, reduced-motion emulation, QR encoder, phase splits); each is merged into one row with every source listed. Existing rows: Q1 closes when the P2 spike runs, on the criteria in Q9. Q2 is extended by Q22. Q4 gains facts from Q21. Q3 and Q5 are unchanged.

| # | Question | Recommended answer | Affects | Source |
|---|---|---|---|---|
| Q6 | **Phase granularity.** ADR 0021 says fine "(8 to 12 phases; the seed proposes 12)" and also "a phase that can't meet its gates splits". PROJECT.md says "split any phase that would need more than 5 plans; never compress one". Eight of the 12 families exceed 5 plans as scoped. Does the split rule win, giving about 35 sequential phases with the 12 families kept as headings? | Yes. The split rule is the non-negotiable. Keep the 12 families as ROADMAP headings, number phases sequentially, size each to 3 to 5 plans. | ADR 0021; PROJECT Roadmap constraints; NORTH-STAR 1 | ARCH Verdict 2, O1; PF14; FEATURES 9.3 to 9.4 |
| Q7 | **Prod guard timing.** ADR 0006 and SEC-02 say the macro "raises at compile time when `Mix.env() == :prod`". A raise in the macro body fires even when the mount is inside the installer's false `dev_routes` `if` (E1), so every adopter's prod build would fail. State that the guard is emitted in the macro's returned code? | Yes. Emit the `CompileError` in the returned quote. CI gets two prod-build cases: (a) a mount inside a false `dev_routes` block compiles cleanly; (b) an unguarded mount raises the canonical message. Publish 0.1.0 only after both pass. | ADR 0006; SEC-02; REL-01; INST-01 | PF1 (E1) |
| Q8 | **Grid shape.** ADR 0003 stacks a story's scenarios in one iframe with lazy tiles. One document means shared DOM ids, shared `fixed` and viewport-unit behaviour, one viewport width, and one LiveView process that a runtime crash takes down, so CANVAS-03's "other tiles keep rendering" cannot hold. Lazy tiles also need viewport observation while ADR 0003 forbids injected JS. Let a P7 spike with adversarial fixtures decide, defaulting to one native-lazy iframe per tile for Area, Screen and fullscreen placement? | Yes. Per-tile `loading="lazy"` iframes by default; stack one document only for Primitive and Pattern and only if the spike passes (duplicate ids, a hook, a portal, a modal, `min-h-screen`, a LiveComponent crash in `handle_event`); static-render tiles past about 12 live tiles. Grid tile and single view share one render path and produce identical Baselines. ADR 0003's reversal trigger already covers this. | ADR 0003; CANVAS-02; CANVAS-03; ADR 0015 | ARCH A1; PF4 |
| Q9 | **Browser-runner spike criteria and media emulation.** ADR 0011's six criteria miss what decides the motion and forced-colors lanes. PlaywrightEx 0.15.0 has no `emulateMedia` (reduced motion, forced colors, contrast) and no per-page viewport, and `phoenix_test_playwright` is documented only for ExUnit although bundles, shots and the sweep are Mix tasks. Amend the spike? | Yes. Keep criteria 1, 2, 3, 5, 6; drop 4 (WebSocket frame bytes; PERF-03 is measured server-side). Add 7 media emulation (`emulateMedia` via `PlaywrightEx.send/2` behind one wrapper with a contract test, or upstream); 8 per-rendition viewport (a context per width, or the `vw` parameter); 9 use from a Mix task with the endpoint in a non-test env; 10 availability of the optional dep in dev; 11 remote Playwright server option (no Node on the Elixir machine; needs `websockex` in test); 12 determinism on the maintainer's platform (Apple Silicon); 13 probe injection by nonce reuse or runner injection with `bypass_csp` left false. If 7 exceeds the 50-line budget, a generated `@playwright/test` fallback is acceptable for the motion and forced-colors lanes only. Pin `threshold: 0.1` and `max_diff_pixels: 0` explicitly. | ADR 0011; ADR 0025; VIS-01; CHECK-03; MOTION-03; MOTION-06; Q1 | STACK F1, F6/OQ-D; ARCH A4; PF6, PF7 |
| Q10 | **Host scheme and Theme strategy (CTRL-05).** CTRL-04 lists color scheme and Theme as Globals but no document says how the host applies them (a class, `data-theme`, or a media query). Wrapper attributes work for class and attribute strategies; Tailwind v4's default `dark:` is media-based, which page JS cannot switch. Add a Book option (a class, a data attribute with values, or `:media`), proposed by the installer from the root layout and verified by the doctor, plus a P8 spike of a same-origin CSSOM rewrite of `prefers-color-scheme` rules? | Yes. Add CTRL-05 and a small ADR 0002 amendment. If the CSSOM spike fails, `:media` shows "Not switchable here" and only the browser runner renders dark. Verify the `data-theme` convention on a fresh `phx.new` in P8. | CTRL-04; CTRL-05 (new); WB-06; WB-08; CANON-10; ADR 0002; ADR 0025; INST-01 | FEATURES 5 (CTRL-05); ARCH A3; PF11 |
| Q11 | **"Finds exactly what CI finds" (CHECK-02).** Reduced motion, forced colors, contrast and real `:hover` or `:focus-visible` are media features or user-agent states that page JS cannot set, so the Checks tab cannot literally match the runner. Amend CHECK-02 to "same probe, same Evidence schema, same rules; checks needing real emulation report `not-run` outside the runner", label interactive Globals "Simulated: affects classes that opt in", and allow `pass` for those checks only from the runner lane? | Yes. This is the Honesty constraint applied to owner-approved wording. | CHECK-02; CHECK-03; MOTION-03; UX-01; ADR 0010; ADR 0025 | PF11; STACK F6; FEATURES 3 |
| Q12 | **ADR 0007 refresh.** (a) `~> 1.8.16` and `~> 1.2.9` forbid Phoenix 1.9 and LiveView 1.3 (both have changelogs on `main`), recreating the incumbent's resolver-blocking footgun. Use `>= 1.8.16 and < 2.0.0` and `>= 1.2.9 and < 2.0.0`, with the canary lane, ComponentInfo contract test and a "tested up to" matrix as the safety net? (b) The Phoenix security floor is 1.8.9 (CVE-2026-56811 and 56812); 1.8.16 is only the latest patch. Keep 1.8.16 or widen? (c) The latest lane is Elixir 1.20.4 / OTP 29.1.x, not 1.19/28. | (a) Yes. (b) Widen to 1.8.9 unless the owner wants the phoenix.js connection-race fixes in 1.8.16; at 1.8.16 the floor lane equals latest Phoenix and loses signal. (c) Yes; override the skill's `.tool-versions`; the library must be warning-free under `--warnings-as-errors` on both lanes. | ADR 0007; ADR 0018; COMPAT-01; ADR 0017; PROJECT Tech | STACK F2, F3/OQ-A, F11; PF16 |
| Q13 | **Story discovery and "update without a restart".** ADR 0008 filters `Application.spec(otp_app, :modules)`; after an in-VM recompile that list is stale (E2), so a new story is invisible until restart. Phoenix also has no public "modules recompiled" hook without a watcher process. (a) Discover from compiled output (the `.app` file or ebin beams, prefix-filtered on binary names before loading) behind a `Discovery` seam? (b) Is a reload of both documents, triggered by the host's `live_reload` patterns and lossless because all state is in the URL, an acceptable reading of CANVAS-06? | (a) Yes, with a contract test that adds and deletes a story module and asserts the catalog changes. (b) Yes. | ADR 0008; CORE-04; CANVAS-06; PERF-01 | PF2 (E2); ARCH A5 |
| Q14 | **Render seam and LiveComponent subjects.** Verified in LiveView source: `Phoenix.HTML.Safe` for a LiveComponent raises, so the seam cannot produce iodata for a LiveComponent subject, a template with `<.live_component>`, or streams without an adapter. ADR 0002 allows LiveComponents up to Area; ADR 0022 and CORE-09 describe the seam as universal. Accept a typed `unsupported_subject` error for server-only purposes (test, bundle, export), with the canvas hosting them and consumers reporting `not-run`? | Yes. Add `:unsupported_subject` to the closed error set, add CORE-15, label the gap in bundles, never fabricate markup. | ADR 0002; ADR 0022; CORE-07; CORE-09; CHECK-05; LLM-04; TEL-03 | ARCH A2, Pattern 8; PF22 |
| Q15 | **What is a "contract test"?** The rule "never edit a contract test in the same PR as the implementation it guards" has no definition, yet goldens, the API-surface snapshot, Muex floors, committed `priv/static` drift, error-message snapshots and Baselines legitimately change with implementation. Define two kinds: contract tests (behaviour and invariants), changed only in a PR touching no `lib/`; and recorded outputs, changed in the same PR with a CHANGELOG or DECISION note and a readable diff summary? | Yes. Enforce the first kind mechanically (if `test/contract/**` changed, `lib/**` must not have). This touches a CLAUDE.md non-negotiable, so it needs owner sign-off. | CLAUDE.md non-negotiables; ADR 0014; ADR 0021 | PF15 |
| Q16 | **Waiver and Draft ratchet; day-0 contract.** CORE-12 and CORE-13 allow per-scenario Waivers and Draft, but nothing stops bulk use by an agent under CI pressure, and nothing guarantees a fresh install passes strict mode. Add: counts may only shrink on `main`; reasons have a minimum length and a review date; a bulk add (more than N in one PR) needs an INT-citing DECISION; Draft expires and does not count toward Coverage; Unstoried auto-stories, the sample story and `generate_tests` pass strict mode with zero Waivers on a fresh install. | Yes. | CORE-12; CORE-13; CORE-08; ADR 0024; INST-05; QA-03 | PF13 |
| Q17 | **Installer and the Tailwind config.** INST-01 and ADR 0019 say the installer never touches the Tailwind config. MOTION-06 and ADR 0025 say it adds the reduced-motion custom variant. In Tailwind v4 the variant lives in `app.css`, which is the configuration. | Keep INST-01 intact: the installer prints a copy-paste snippet and the doctor verifies it. Amend INST-01 for `app.css` only if the owner prefers an edit. Decide before P25. | INST-01; MOTION-06; ADR 0019; ADR 0025 | PF25 |
| Q18 | **Time shim and "no JS injected".** ADR 0003 says Fablebook injects no JS into the canvas except the opt-in probe; MOTION-01 and ADR 0025 call for a time-dilation shim "in the canvas". LiveView `JS` transitions use global `setTimeout` and double `requestAnimationFrame`, and phoenix.js uses timers for heartbeat and reconnect, so a blanket 0.1x dilation disconnects the canvas. Amend: the shim is a virtual clock the workbench installs from the parent realm onto the same-origin canvas window (no script text, so no CSP issue), dilating only delays under about 1000 ms, queueing dilated timers so pause truly pauses `time:` callbacks, labelled "Time shim active"? | Yes. Make "heartbeat survives 60 s at 0.1x", "pause then resume completes a `JS.show` with `time:` exactly once" and "a `blocking: true` transition does not wedge patches" criteria of the P25 spike. | ADR 0003; ADR 0025; MOTION-01 | FEATURES 3, 6; ARCH Pattern 6; PF10 |
| Q19 | **Dependency bans, precisely.** ADR 0018 lists `mix_audit` (which hard-depends on `yaml_elixir` and `jason`) while banning any YAML library; Igniter, phoenix_test, muex and sobelow also pull `jason` into dev and test. The literal ban cannot hold against `mix.lock`. Define: no banned package in the prod closure (`mix deps.tree --only prod`), none declared directly in `mix.exs`, none referenced from `lib/`; and replace `mix_audit` with `mix hex.audit` plus OSV-Scanner in the `security` job? | Yes to both. The prod closure stays clean because Phoenix, LiveView and phoenix_test_playwright treat `jason` as optional. | ADR 0018; ADR 0017 | STACK F4/OQ-B |
| Q20 | **HTML parsing in adopters' dev environment.** `phx.new` lists `lazy_html` as `only: :test`, Floki is banned and LiveView's tokenizer is internal. The no-browser bundle, the glossary and retired-wording lint, the CORE-14 `phx-*` check and the Checks tab all read rendered HTML in dev. Add a vendored `Fablebook.HTML.Tokenizer` (about 200 lines, `@moduledoc false`) to ADR 0018's vendored list, with `lazy_html` as the property-test oracle in Fablebook's own tests? | Yes, and answer before P4 (Normalize uses it). It also serves the UX-07 fallback (render under two Gettext locales and flag text nodes that do not change). | ADR 0018; ADR 0010; CANON-07; LLM-04; CORE-14; UX-07 | STACK F5/OQ-C; FEATURES 6 |
| Q21 | **Other ADR 0018 list additions.** (a) The QR encoder for WB-07 is in no ADR: vendor Nayuki's MIT QR generator into the chrome JS with its notice in `priv/static/LICENSES`; reject `qr_code`; use `eqrcode` only as copied code. (b) Add `sbom` (dev) for `mix sbom.cyclonedx` (REL-01). (c) Ship `usage-rules.md` in the package `files` and in the allowlist test (used by `usage_rules sync`, SKILL-01). (d) `websockex` (test) only if the remote-server runner option wins the spike. | Yes to (a) to (c); (d) conditional on Q9. Q4 stands: never bind the LAN for the user. The unavailable microcopy must name the real causes (server bound to loopback; `check_origin` for the LAN host). | ADR 0018; WB-07; REL-01; SKILL-01; Q4 | STACK F9; PF30 |
| Q22 | **Dogfood timing (extends Q2).** C6 and C8 need 14 clean days and C1, C4 and C5 need migrations in other repos, yet dogfood is last, so any Fablebook-caused red resets the clock at the end. A phase whose work is in other repos also has no "merged green PR to main of this repo". Start LiveView 1.2 upgrade PRs in the dogfood repos from P3, cut a 0.x release after P9 and install it read-only in one dogfood repo, run the nightly self-test on `main` from P22, and accept per-repo merged PRs plus one Fablebook PR as the P35 evidence? | Yes. Answer Q2 as "upgrade the hosts and keep the floor". | ADR 0007; ADR 0020; ADR 0021; CLEARANCE C1, C4, C5, C6, C8; Q2 | ARCH O6; PF18, PF14 |
| Q23 | **Iframe `sandbox` attribute (SEC-03).** For same-origin content, `allow-scripts allow-same-origin` lets the document remove its own sandbox (MDN), so it adds no isolation while blocking modals, popups and downloads that host scenarios may use. Stop listing it as a security control? | Yes. Drop the claim from SEC-03 and the security guide. The real controls are no eval, the signed topic, a localhost-only editor, the dev-only mount and CSP. | SEC-03; ADR 0005; QUALITY-PERF-SRE checklist | PF21 |
| Q24 | **Public API surface.** (a) Pages have no storage story: ADR 0001 forbids runtime file compilation and ADR 0008 names no page kind. Add a public `Fablebook.Page` that compiles Markdown or HEEx into a module, with the `:page` entry kind in the Catalog from P3 so the manifest is not reshaped in the canon phase? (b) Does "at most 25 public modules" count `Mix.Tasks.*`? | (a) Yes. (b) Count them, the stricter reading: nine library modules plus ten tasks is 19, six spare. Encode it in the API-surface snapshot test. | CORE-07; CORE-11; ADR 0001; ADR 0008; QA-03; PROJECT Code style | ARCH B2, B5 |
| Q25 | **Compare "revision against main" (WB-13).** Two revisions cannot render in one running host. The only 1.0-feasible source for "main" is committed Baselines, which needs Capture. Clarify WB-13: revision comparison means the current rendition against its committed Baseline, available from P22; Globals axes from P13; Theme and Direction axes from P15. | Yes. | WB-13; ADR 0013; VIS-02 | ARCH B3 |
| Q26 | **Coverage noise (CORE-08).** Crossing every story with all 12 State classes gives 14 CoreComponents a wall of Gaps and waiver fatigue. Default an expected set of State classes per Tier (a Primitive is not expected to have `denied` or `stale`) and report outside the default only when declared? | Yes. It changes the reading of INT-20261028-04, so validate against the first dogfood Book. | CORE-08; ADR 0024; INT-20261028-04 | FEATURES 5, 6 |
| Q27 | **Noisy copy rules (UX-05, UX-06).** Reading-grade formulas suit passages of about 100 words and are noise on 2 to 12 word labels. The glossary-based confirmshaming lint is a heuristic listed as an error in ADR 0024. Apply reading grade only to strings of 25 words or more; ship the structural half of UX-05 (cancel not visually weaker than confirm) as an error and confirmshaming as a warning until the false-positive rate is measured on the twins? | Yes. | UX-05; UX-06; ADR 0024 | FEATURES 6 |
| Q28 | **gen.story (INST-02).** ADR 0019 generates "one scenario per `values:` member", which is single-axis permutation and conflicts with "scenarios are equivalence classes for real situations" and the strict `desc` rule. Mark generated scenarios Draft with a TODO `desc`, and have the generator say they need a Situation? | Yes. | INST-02; ADR 0019; ADR 0024; INT-20261028-04 | FEATURES 6 |
| Q29 | **Baseline acceptance path (VIS-02).** `bin/visual update` on Apple Silicon yields different anti-aliasing than CI. Require selective accept (scenario ids or `--all`, changed Renditions listed first), force `--platform linux/amd64` and refuse otherwise, and offer a CI "update baselines" dispatch whose artifact a human downloads and commits (still human-accepted)? | Yes. One version file feeds the container tag, the npm install and the Dependabot ignore rule, with an equality test. | VIS-01; VIS-02; ADR 0011 | PF7; FEATURES 5 |
| Q30 | **ADR 0012 refresh (DTCG 2025.10).** Colour `$value` is an object (`colorSpace`, `components`, optional `alpha`, `hex`), resolver files use `.resolver.json`, and unknown `$extensions` must be preserved. Update ADR 0012 (`tokens/resolver.json` becomes `tokens/product.resolver.json`) and CANON-03 at the next amendment. Low priority. | Yes. | ADR 0012; CANON-03 | STACK F12 |

## Proposed requirement additions/amendments

Additions enter REQUIREMENTS.md only after the ADR 0021 interactive review. "Sign-off" means the item changes or extends an ADR or owner-approved wording, so it needs an owner answer first; "No" means additive or stricter, with review at the ADR 0021 pass only. Every proposed REQ carries the ADR and INT citations shown.

### A. New requirement ids

| ID | Proposed wording | Evidence | Sign-off | Phase |
|---|---|---|---|---|
| **CTRL-05** | A Book setting declares how the host applies color scheme and Theme (a root class, a data attribute with values, or `:media`). The installer proposes it from the root layout, the doctor verifies that it flips the canvas, and under `:media` the toolbar says plainly that only the browser runner renders dark. (ADR 0002, ADR 0013, INT-20261028-04) | No document defines the mechanism; FEATURES TS-09; ARCH A3; PF11 | **Yes** (Q10, ADR 0002) | P8; installer part P10 |
| **CTRL-06** | Editing a Control offers "Copy as scenario": Elixir text for a new Draft scenario with the overridden attrs and a TODO situation. Values print from typed controls only, no atoms are created, nothing is written to disk. (ADR 0004, ADR 0013) | Storybook's save-from-controls is among its best-loved loops; this stays inside ADR 0004's no-write line | No | P5 |
| **WB-17** | Sidebar dots and tile status read the latest Evidence keyed by render hash and show "Not run" until Evidence exists, never a green dot. "Run checks" runs the probe for the open rendition (and at story level across the width presets) in the user's browser. (ADR 0011, ADR 0010, INT-20261028-04) | Storybook 9's test widget set the expectation; UX-DESIGN promises a dot but no REQ names its source | No | P11 dots; P20 run action |
| **WB-18** | Width presets carry a height and a rotate action (an `orient` URL parameter). Workbench settings (Appearance, density, single-key shortcut switch, pane sizes) persist and are listed. (ADR 0013) | Screens using `100dvh`, bottom sheets and the Shell cannot be judged by width alone | No | P12 |
| **CORE-15** | Server-only purposes (test, bundle, export) report `:unsupported_subject` for LiveComponent subjects and for templates containing `<.live_component>`. Consumers record `not-run`, and bundles label the gap. (ADR 0002, ADR 0022) | Verified in LiveView `engine.ex` | **Yes** (Q14) | P4 |
| **CORE-16** | A documented fixture helper builds `@streams`, `AsyncResult` and `to_form` assigns through public socket functions on a bare socket, tested on all three lanes. (ADR 0002, ADR 0007) | PF22; MEDIUM confidence, prove with the operator host's streams/async/forms Screen | **Yes** (new public API) | P9 |
| **CANVAS-07** | The canvas absorbs events and navigation it has no handler for (catch-all `handle_event/3`, `handle_info/2`, `handle_params/3`, `layout: false`) and logs "Event recorded" or "Would navigate to /x" instead of crashing or leaving. (ADR 0003, ADR 0004) | PF5: phoenix_storybook #353 "death spiral" | No | P7 |

### B. Amendments and acceptance criteria to existing requirements

| REQ | Change | Source | Sign-off |
|---|---|---|---|
| SEC-02 | The guard is emitted in the macro's returned code; two prod-build cases (Q7). | PF1 | Yes (Q7) |
| SEC-01 | Extend the Credo bans: `Module.concat/safe_concat`, `:erlang.binary_to_atom/list_to_atom`, `:"#{}"` interpolation, `String.to_existing_atom` on input, non-literal `apply/3`. IDs resolve through a catalog-built map. Atom-count property runs in a fresh process after warm-up through the real `handle_params`. XSS corpus (`javascript:`, `data:`, breakouts) as a StreamData property. Fuzzy scorer and Markdown subset use binary pattern matching, not regex. | PF12 | No (strengthens ADR 0004) |
| SEC-03 | Chrome templates never emit `style=` (Credo check; sizing by classes and `style.setProperty`). The probe loads by nonce reuse or runner injection; `bypass_csp` stays false. The `sandbox` claim follows Q23. | PF6, PF21 | Yes for the `sandbox` part only |
| CANVAS-02, 03 | Per Q8. CANVAS-03 adds runtime-crash isolation (a LiveComponent raising in `handle_event`), not only render raises. | PF4, ARCH A1 | Yes (Q8) |
| CANVAS-06, CORE-04 | Per Q13: discovery from compiled output; add and delete tests; reload semantics. | PF2, ARCH A5 | Yes (Q13) |
| CTRL-03 | Acceptance: Back returns to the previous workbench URL, since iframe `src` changes use `location.replace` and add no history entries. | PF19 | No |
| CHECK-02 | Per Q11. | PF11 | Yes (Q11) |
| VIS-01 | `Fablebook.Test.Visual` sets `threshold` and `max_diff_pixels` itself and a test asserts the effective values. The ready attribute is a tested state machine (LiveSocket join, nested views, no pending `phx-*-loading`, per-family fonts, images decoded, tile rendered, no in-flight JS transition) failing with `not-run` and the unmet condition. Client clocks are frozen in the runner. A single version file feeds the container tag, npm install and Dependabot. | PF7, PF8; STACK F1 | No (makes the recipe's own numbers true) |
| VIS-02 | Per Q29, plus a pre-check that fails before `assert_screenshot` when a baseline is missing and the accept flag is unset. | STACK F1; PF7 | Yes (Q29) |
| CORE-09, LLM-05, LLM-07 | One `Normalize` (strips nonces, CSRF values, `data-phx-*` tokens, generated ids, `?vsn=`, timestamps) shared by the hash, goldens and redaction. The list is closed, with a property (different nonces give identical bytes) and a mutation-proven test (a real attribute change changes the hash), tracked on the canary lane. `Fablebook.JSON.encode_canonical!/1` with a permutation property for manifest and bundle bytes. | PF9; STACK F7 | No |
| PERF-05 | Add a second row: adding a function to `CoreComponents` recompiles at most N stories (N reported). Add `mix xref graph --label compile-connected --fail-above 0` from P1, on the library and the host apps' story directories. Generated stories use qualified calls or `import ..., only: [...]`, never a bare `import CoreComponents`. | PF3 (E3) | No (stricter) |
| PERF gates | Gate only on the pinned lane keyed by OTP major and LiveView version; floor and canary lanes report only. A reference change needs a DECISION and prints old and new values. Sensitivity-control tests (a deliberately 1.5x slower fixture must fail). | PF28 | No |
| CI-01 | Weekly p50 and p95 job from `gh run list` updates the single `quality-regression` issue. Cap `.github/actions/**` lines; forbid `scripts/*.js` and `*.cjs` outside E2E; `ci-gate` allows `skipped` only for listed jobs with a reason; order compile, then assets.build, then e2e, with cache keyed on source hash. | PF27, PF35 | No |
| COMPAT-01, CORE-05 | Per Q12. The ComponentInfo fixture covers multi-line attrs, a macro-injected attr group, an `embed_templates` component, `:global` with `include:`, a slot with attrs, `values`/`examples`/`default` of struct and list types, and a required slot. It returns a normalized struct with a `{line, name}` fallback; a fault-injection test proves the manual-controls fallback. | PF17 | Yes (Q12) |
| MOTION-01 | Per Q18, with "Time shim active" label and the three spike criteria. | PF10; FEATURES 6 | Yes (Q18) |
| MOTION-04 | The `time:` versus CSS duration check is a probe check that reads the `phx-*` JS command JSON and applies computed style. It reports `not-run` without a browser. | PF23 | No (mechanism) |
| MOTION-06, INST-01 | Per Q17. INST-01 also adds `storybook/` to formatter inputs, documents the Dialyzer and Credo implications of `elixirc_paths`, and runs `MIX_ENV=prod mix compile` plus apply-twice and partial-state goldens. | PF24, PF25, PF33 | Yes (Q17) |
| CANON-03 | Per Q30, with a round-trip test that `$extensions` survive. | STACK F12 | Yes (Q30) |
| CANON-06 | Sequence: DESIGN.md first, with a spec-version stamp in the ownership header; `.impeccable/design.json` only after Capture exists and a test pins the schema. | FEATURES 6; ARCH B4 | No (sequencing) |
| CORE-08, UX-05, UX-06, INST-02 | Per Q26, Q27, Q28. | FEATURES 6 | Yes |
| UX-07 | Spike first. Fallback inside public APIs: render the scenario under two Gettext locales and flag text nodes that do not change. Stays optional and waivable. | FEATURES 6 | No |
| WB-03 | Sidebar filters by Tier, State class, tag, Draft, "has findings" and "has Waiver". | FEATURES 5 | No |
| WB-07 | QR through the vendored encoder (Q21); unavailable copy names the real causes. | PF30 | Yes (Q21) |
| WB-13 | Per Q25. Cap the number of live-reload canvases in Compare (suggest 4). | ARCH B3; PF20 | Yes (Q25) |
| REL-01 | Publish 0.1.0 only after the prod-guard cases are green and `mix hex.build --unpack` is inspected (new-package revert window is 24 hours). release-please `exclude-paths` for `hosts/`, `bench/`, `.planning/`. Axe hash test. Exact-file-list allowlist. | PF26 | No |
| DOCS-01 | Add the interaction path (a harness LiveComponent in the story file, `mount_scenario/2` with PhoenixTest), a `mix test --cover` recipe and an Icons recipe. Guides accumulate as stubs per phase. Only `llms-full.txt` needs separate handling, since ExDoc emits `llms.txt`. | FEATURES 5; ARCH; STACK F10 | No |
| LLM-04, INST-05, QA-03 | Every opt-in browser feature prints one canonical "needs Playwright (opt-in)" message and returns `not-run`. The clean-room spec runs with Node absent from `PATH`; the Docker demo bakes Playwright in. | PF29 | No |
| QA-02 | Pin seed and timeouts; timed-out mutants count as survived with a recorded reason; floor reductions only by DECISION. | PF34 | No |
| QA-06 | Fallback: hand-authored minimal tokens let the canon phase merge if a brand book slips. | FEATURES 6 | No |
| Reviewer path (TS-23 interim) | Sweep contact sheets publish as CI artifacts; `mix fablebook.shot` is the documented way to show a state before static export ships. | FEATURES 5 (G8) | No |
| PROJECT Out of Scope | Add: usage telemetry that phones home (with a clean-room test that the tarball opens no outbound connection); markup snapshot assertions in generated tests; a free-form `parameters` bag. | FEATURES 2.B | No (additive) |

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Versions read from hex.pm, GitHub releases, changelogs and unpacked tarballs on 2026-10-28. MEDIUM for three untested toolchain picks (esbuild 0.28.2 output stability, QR encoder integration, muex on Elixir 1.20). LOW for byte-identical pixels in the pinned container and cross-OS equality of the committed bundle; the spike and the Linux-only drift check own those. |
| Features | MEDIUM | REQ, ADR and INT mapping is HIGH (read from the repo). Competitor claims are MEDIUM at best: fetched ([F]) or recalled ([K]), and the search class is LOW. Each proposed REQ also has an internal reason. |
| Architecture | MEDIUM-HIGH | The core is internally consistent and matches the verified LiveDashboard pattern; the LiveComponent seam limit is verified in LiveView source. LOW on three runtime behaviours: duplicate-id behaviour in a stacked DOM, the CSSOM media-rule rewrite, and the runner outside ExUnit. |
| Pitfalls | MEDIUM-HIGH | HIGH for E1 to E3 and source-read items (CSP semantics, `__components__`, the timer paths, Hex limits). MEDIUM for reasoned items (grid, readiness, shim). LOW for Apple Silicon behaviour, Igniter idempotency rules and the recalled 60-second transport timeout. |

**Overall confidence:** MEDIUM-HIGH. The diagnoses are solid; several resolutions are provisional until a spike or an owner answer.

### Gaps to Address

- **Media emulation through the wrapper (blocker candidate).** Settle in the P2 spike. If it fails the 50-line budget, use the ADR 0011 generated-spec fallback for the motion and forced-colors lanes only, and mark the media path `not-run`.
- **Runner outside ExUnit (LOW).** Whether `phoenix_test_playwright` works from a Mix task, or in dev, decides how `--browser` bundles, `shot` and the sweep are built. Settle in P2; the Probe and Evidence schema are runner-agnostic either way.
- **Byte-identical captures and Apple Silicon (untested).** Run the 3-capture self-test on the CI image and the maintainer path in P2, and record the result.
- **Stacked-grid duplicate ids (MEDIUM).** Settle in the P7 spike with the adversarial fixture set.
- **CSSOM media-rule rewrite (LOW) and the Phoenix 1.8 `data-theme` convention.** Settle in P8. Fallback is the documented selector contract with `scheme=dark` honestly unavailable for media-only hosts.
- **Time shim (MEDIUM).** The 60-second heartbeat arithmetic is deterministic, but the transport timeout is recalled. Confirm in P25.
- **Forced pseudo-states without a mouse.** CDP `CSS.forcePseudoState` versus stylesheet rewriting against Tailwind v4 output. Settle in P23.
- **Probe injection under strict nonce CSP.** The technique is reasoned (nonce reuse from the parent, or runner-side injection), not proven. Settle in P2 and P20.
- **`import M, only: [...]` and the export edge.** Confirm with `mix xref` on `hosts/operator` in P3.
- **Igniter idempotency rules (undocumented).** Rely on apply-twice and partial-state tests, not assumptions.
- **UX-07 tokenization, design.md alpha spec, impeccable `design.json` schema.** Sequence behind spikes and pins as in the requirement amendments.
- **abracabrand maturity and the 14-day soak.** Keep the minimal-token fallback; start upgrades in the dogfood repos now.
- **DTCG "first stable" wording.** Both 2025.10 pages say stable; the exact phrase was not found. No design impact.
- **React Cosmos renderer-seam parallel (LOW).** Taken from project research only; no design depends on it.

## Sources

### Primary (HIGH confidence)
- hex.pm API, release pages and unpacked tarballs for every package in STACK.md; Phoenix `v1.8` and `main` changelogs, `phx_new-1.8.16` template, `phoenix-1.8.16` tarball; LiveView `v1.2` and `main` changelogs, `engine.ex`, `declarative.ex`, `js.js`, the 1.2.13 tarball; Elixir 1.20 changelog and `json.ex`; OTP-27.3.4.19 `json.erl`.
- `phoenix_test_playwright` 0.19.0 and `playwright_ex` 0.15.0 source, CHANGELOG, README and hexdocs.
- Phoenix LiveDashboard `router.ex`; `phoenix_live_reload` source.
- MDN: CSP `style-src` and `<iframe>`. Hex publish docs. Playwright Docker and snapshot docs.
- Design Tokens Format and Resolver Modules 2025.10.
- Experiments E1 to E3 (Elixir 1.19.5 / OTP 28, 2026-10-28).
- Repo documents: `PROJECT.md`, the intent files, `GLOSSARY.md`, `FABLEBOOK-SEED.md`, ADRs 0003, 0006, 0007, 0008, 0011, 0018, 0019, 0020, 0021, 0024, 0025 (and others as cited in the research files), `docs/research/*`.

### Secondary (MEDIUM confidence)
- Storybook 9 and 10 docs and blog, manifests, telemetry and save-from-controls PR #26827; Ladle, Histoire, Lookbook, React Cosmos and Widgetbook docs; phoenix_storybook hexdocs.
- ElixirForum threads on iframe history and module-recompile notification; whatwg/html #6501.
- Project Nayuki QR Code generator README (MIT); Storybook pseudo-states addon README.

### Tertiary (LOW confidence, needs validation)
- Secondary posts on Playwright images and Apple Silicon (no primary source found).
- Remote Playwright server mode: documented in the README, not exercised.
- Recalled figures: Phoenix transport timeout (60 s), Phoenix 1.8 `data-theme` toggle convention, whether the HEEx tokenizer is public, readability-formula limits on short strings.

---
*Research completed: 2026-10-28*
*Ready for roadmap: yes. Q6, Q7, Q9, Q12, Q13, Q15, Q19, Q20 and Q24 should be answered (or their recommended answers accepted) before P1 to P4 planning; Q14 and Q16 before P4; Q8 before P7.*

