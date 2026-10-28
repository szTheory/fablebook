# 0019. DX: Igniter install, generators, doctor, migrator, a 60-second Docker demo

**Status:** Accepted · **Cites:** INT-20261028-01

## Decision
### Installer: `mix igniter.install fablebook`
- **Patches:**
  - the dependency;
  - the router (`import` plus `fablebook "/fablebook", MyAppWeb.Storybook` inside the `dev_routes` `/dev` scope, so the default URL is `/dev/fablebook`);
  - `elixirc_paths`;
  - `live_reload` patterns for `storybook/**/*.ex` and `design/**`;
  - the `.formatter.exs` `import_deps`;
  - a Book module, a welcome page, and a sample story built from `CoreComponents.button/1`.
- **Never touches** `app.js`, `package.json` or the Tailwind config. It emits notices instead.
- **Without Igniter**, a plain Mix fallback prints the manual steps.

### Mix tasks
- `mix fablebook.gen.story Module.fun`: generates one scenario per `values:` member, plus the required-attr defaults.
- `mix fablebook.doctor [--ci]`: a pure `Fablebook.Doctor` core plus a thin shell. It checks:
  - the mount and the `dev_routes` guard;
  - `elixirc_paths`;
  - that the host `app.js` exposes `window.liveSocket`;
  - that CSS is reachable;
  - CSP nonce wiring;
  - version ranges;
  - duplicate ids;
  - broken citations.
- `mix fablebook.migrate.phoenix_storybook`: an Igniter converter. It is both the adoption wedge and the owner's own dogfood tool.

### Day 0
Within 5 minutes, the evaluator sees **their own components**, auto-discovered, rendering in their real CSS.

### Docker
`docker compose up` in `demo/` runs the operator host app with no database, on a base image pinned by digest.

### Docs and API surface
- Exactly these 12 guides at 1.0 (sub-topics are sections, not guides), grouped by reader intent:
  - **Overview:** 1 Introduction (what it is, concepts, tour) · 2 Comparison & migration (phoenix_storybook, Storybook)
  - **Adopt:** 3 Install · 4 Writing stories (scenarios, situations, tiers, groups, pages, sample data) · 5 Controls & presets
  - **Design canon:** 6 Design canon (tokens, glossary, voice, personas & jobs, twins, imagery, DESIGN.md)
  - **Quality:** 7 Checks & visual baselines (generated tests, sweep, baselines) · 8 LLM context (bundles, manifest, agent recipes)
  - **Operate:** 9 Security model & CSP · 10 Telemetry & operations · 11 Troubleshooting (headings are the canonical error strings)
  - **Upgrade:** 12 Upgrading (per-minor sections, compatibility matrix, deprecation policy)
  - Contributing lives in `CONTRIBUTING.md`. Cheatsheets (`.cheatmd`: Story DSL, keyboard, URL params), `llms.txt` and `llms-full.txt` don't count as guides.
- An API-surface snapshot test fails on any public-API change not noted in the CHANGELOG.

### SemVer
- **0.x:** breaking changes allowed in minor releases. Each minor gets an `UPGRADING.md` section, and anything removed was `@deprecated` for at least one minor first.
- **1.0 onward:** strict SemVer. Deprecations last at least 2 minors.
