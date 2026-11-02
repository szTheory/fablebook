# Architecture decision records

ADRs rank above REQUIREMENTS and below verbatim intent (`.planning/intent/README.md`). Each one records its status, context, decision, the alternatives rejected, and a reversal trigger.

| # | Decision |
|---|---|
| [0001](0001-stories-are-compiled-modules.md) | Stories are compiled `.ex` modules in `storybook/` |
| [0002](0002-scenarios-are-plain-functions.md) | Scenarios are plain functions; slots are never strings |
| [0003](0003-iframe-canvas-through-host-pipeline.md) | The canvas is an iframe rendered through the host's pipeline and root layout |
| [0004](0004-no-eval-no-new-atoms.md) | No runtime eval and no atoms created from input |
| [0005](0005-livedashboard-style-packaging.md) | LiveDashboard-style packaging, with zero processes |
| [0006](0006-dependency-available-in-all-envs.md) | The dependency loads in all envs; stories never compile in prod |
| [0007](0007-version-floors.md) | Floors: Elixir 1.18/OTP 27, Phoenix 1.8.9, LiveView 1.2.9, open below 2.0 |
| [0008](0008-catalog-discovery-and-ids.md) | The catalog is a pure function; ids come from module and function names |
| [0009](0009-manifest-no-mcp-no-plugin-api.md) | A canonical manifest; no MCP or plugin API in 1.0 |
| [0010](0010-llm-context-bundle.md) | The LLM context bundle is a core artifact |
| [0011](0011-browser-runner.md) | Browser runner is phoenix_test_playwright, with a reversal trigger |
| [0012](0012-canon-format.md) | Canon lives in `design/` as Markdown with frontmatter, plus DTCG tokens |
| [0013](0013-workbench-ux.md) | Workbench UX |
| [0014](0014-testing-strategy.md) | Testing strategy |
| [0015](0015-performance-gates.md) | Performance gates use deterministic proxies |
| [0016](0016-telemetry-and-errors.md) | Telemetry only emits; the error set is closed |
| [0017](0017-ci-cd-layout.md) | CI/CD layout |
| [0018](0018-dependency-budget.md) | Dependency budget |
| [0019](0019-dx-install-upgrade.md) | DX: install, generators, doctor, migrator |
| [0020](0020-host-apps-dogfood.md) | Host apps and dogfood plan |
| [0021](0021-delivery-rules.md) | Delivery rules for GSD |
| [0022](0022-static-export-v1x.md) | Static export ships in v1.x; the render seam ships now |
| [0023](0023-vocabulary-scenario-and-tiers.md) | Vocabulary: "Scenario" and the four tiers |
| [0024](0024-strict-by-default-with-waivers.md) | Strict by default; Waivers are the only escape hatch |
| [0025](0025-motion-lane.md) | Motion is a first-class lane |
| [0026](0026-validation-only-security-evidence.md) | Stage validation evidence without weakening security gates |
