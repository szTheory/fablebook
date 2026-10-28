# Fablebook's own personas and jobs

These are the people (and agents) who **use Fablebook**. They are not the canon personas an adopter writes for their own app.

**Primary audience (INT-20261028-10): solo developers and very small teams working with an AI agent.** Fablebook replaces the need for Figma. Designer and PM reviewer features exist for a solo developer's own review on their own phone, not for hand-offs to a design team.

Personas are ranked by adoption leverage. Personas 1, 2 and 3 decide whether Fablebook succeeds; 4–8 mostly follow once URLs carry all state and docs come from the source. (INT-20261028-01, INT-20261028-04)

Labels: **[confirmed]** means the owner said it; **[assumed]** means research inferred it.

| # | Persona | Job ("When…, I want…, so I can…") | Day 0 → 1 → 2+ | Aha moment | Values | Churns when |
|---|---|---|---|---|---|---|
| 1 | **New evaluator** (a Phoenix dev) [assumed] | When I'm deciding whether to adopt a workbench, I want my own components rendered within minutes without writing files, so I can judge fit before committing. | D0: `igniter.install`, then open the mount and see their CoreComponents auto-listed. D1: write a first story. D2: add `Fablebook.Testing` to CI. | Their real `<.button>` renders in their real CSS and fonts, with typed controls, before they've written a story. | Speed, no Node, nothing breaks | Setup takes over 5 min; serif fonts; an upgrade breaks it |
| 2 | **AI coding agent** [confirmed: core motivation, INT-20261028-04] | When I'm asked to build or fix UI, I want a machine-readable catalog, contracts, stable render URLs and a budgeted context bundle, so I can verify my change without guessing. | D0: reads `llms.txt` and the manifest. D1: writes stories from templates. D2: runs `mix fablebook.bundle` and the generated tests in its loop. | One command returns screenshots, ARIA, measurements and the brand, glossary and job context for exactly the scenarios it touched. | Determinism, stable ids, errors as data, a small token cost | Names it has to hallucinate; prose-only errors; the index needs a browser |
| 3 | **Owner as library author** building operator/admin UIs (mailglass_admin, accrue_admin, scrypath_ops) and SaaS [confirmed] | When I change a shared pattern, I want every composition from Primitive up to Screen visible side by side, light and dark, at 375 and 1440, so I can fix the lowest tier once. | D0: mount in the library's dev/test host. D1: fractal tree, persona fixtures, canon. D2: sweep plus visual diffs in CI; LLM bundles drive iteration. | One primitive edit re-renders the grid of a whole screen live; "Copy for LLM" gives a design review in one shot. | Fidelity, nested mounts, manifest in test, canon | A `/dev` mount breaks; fixtures leak into the Hex tarball; the canvas doesn't look like prod |
| 4 | **Design-system maintainer** [assumed] | When I publish or change a component, I want its contract, scenarios, a11y status and canon documented from source, so I stop maintaining docs that drift. | D1: the story page is the docs. D2: coverage reports; static export (v1.x). | The attr table and examples come from `attr`/`slot`; DESIGN.md is generated. | No drift, a coverage signal | A second authoring format |
| 5 | **App dev consuming components** [assumed] | When I need a component, I want to find it, see its states and copy correct HEEx, so I can use it without reading source. | D0: ⌘K "modal", pick a scenario, copy the HEEx. | The copied HEEx compiles the first time. | Search, copy | The copied code is wrong |
| 6 | **Designer / PM reviewer** [assumed] | When a PR changes UI, I want a link that opens exactly the state under review on my phone or laptop, so I can approve without running the app. | D0: opens a shared URL. D2: comments in the PR. | A QR code opens the same scenario at 375 on their phone. | Zero setup, plain words | Jargon; URLs that only work on localhost |
| 7 | **QA / accessibility tester** [assumed] | When I verify a component, I want every real state one click away, with checks and simulations, so I can report a finding as URL + width + theme + motion. | D1: Checks tab. D2: findings pasted as links. | "Copy finding link" captures the full state. | Reproducibility, honest checks | Checks that overclaim; state missing from the URL |
| 8 | **Docs writer** [assumed] | When I explain a library's UI, I want Markdown pages with live scenario embeds, so guides stay honest. | D2 | An embedded scenario that stays current. | Markdown | A proprietary page format |

## Journeys and their aha moments
- **Day 0, under 5 minutes:**
  1. `mix igniter.install fablebook`
  2. `mix phx.server`
  3. The welcome page shows the auto-discovered components.
  4. Open Button: a grid in the real fonts.
  5. Press `2` (375 px), then `C` (dark). The URL updates.
  6. Copy HEEx.
- **Day 1:** `mix fablebook.gen.story` → write scenarios from real situations, citing persona and job → `Fablebook.Testing` per-scenario tests in CI.
- **Day 2+:**
  1. Fractal coverage up to Screens, with canon (glossary, voice, tokens, personas, jobs).
  2. The sweep and visual diffs gate PRs.
  3. LLM bundles drive design iteration.
  4. Upgrades follow `UPGRADING.md` and the doctor.
  5. Pruning every milestone.

## Each persona has its own surface
| Persona | Surface |
|---|---|
| Evaluator | Zero-file catalog (auto-stories) |
| Agent | Manifest + bundle + render URL |
| Owner | Fractal tiers + canon + host-owned fixtures |
| Design-system maintainer | Story page as docs + coverage |
| Consumer | ⌘K + Copy HEEx |
| Reviewer | Mobile layout + QR (static export in v1.x) |
| QA | Checks + finding links |
| Docs writer | Pages + embeds |

If two personas ever end up sharing one surface, reconsider whether they are really one persona.
