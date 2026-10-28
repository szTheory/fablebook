# Motivations (curated synthesis)

Every sentence below cites an INT id. When this file and `sources/` disagree, `sources/` wins.

## Why build it
- The owner finds phoenix_storybook "okay but … not cranked up 100x like the react storybook" and wants the ultimate Phoenix LiveView workbench, ideally better than Storybook. (INT-20261028-01, INT-20261028-02)
- The immediate users are the owner's own Phoenix LiveView apps and the admin/operator UIs of their Elixir OSS libraries, which also act as the dogfood fleet. (INT-20261028-01)
- The biggest motivation is AI/LLM-assisted UI development: exporting high-signal context (screenshots, markup, components, measurements) so LLMs can help build the design system and the app's layouts, not just buttons. (INT-20261028-04)

## What it must enable
- A catalog that covers the whole UI fractally: layout, nav, each section, subsections, groups of controls, and primitives. (INT-20261028-04)
- Design knowledge kept in the catalog as content: the user-facing domain language mapped to the internal one, brand voice, microcopy conventions, JTBD and personas (kept current and pruned), and a brand book covering typography, color, spacing, padding, shadows, radius, imagery and antipatterns. (INT-20261028-04)
- Happy paths, errors and boundary conditions shown with realistic seed and fixture data grounded in personas, JTBD, brand and glossary, so that design blind spots surface and are easy to browse. (INT-20261028-04)
- Screenshots that are easy to send to multimodal LLMs, plus pixel-level regression detection in CI to cut change risk. (INT-20261028-04)
- Mobile-first, responsive, light/dark/system, accessible, with contrast and on-brand checks, and measurements given back to the LLM in a useful form. (INT-20261028-04)
- Optional static publishing without a live backend, only if it doesn't compromise the design. (INT-20261028-01)

## How it must be built
- Idiomatic Elixir, Phoenix and Plug; latest Phoenix and LiveView only, with no legacy support; dogfood LiveView and avoid React; use OTP to contain crashes. (INT-20261028-01)
- Templated off Storybook as a baseline, improved wherever there's an opportunity; Pareto over white-labelling; KISS/YAGNI, elegant, "nothing should feel accidental". (INT-20261028-01)
- A consistent domain language (nouns, verbs, events) and consistent UX microcopy. (INT-20261028-01)
- Very high quality: the test suite covers happy paths, errors and boundaries from unit tests up to E2E, plus property-based and mutation testing. (INT-20261028-01)
- Performance treated seriously: a high tail-latency bar, throughput and memory measured on the critical flows, folded into CI while staying practical. (INT-20261028-01)
- Efficient CI: no wasted runner time; release-please automation to Hex; integration and E2E tests in CI; digital-twin host apps that dogfood it without overdoing it. (INT-20261028-01)
- Great DX from day 0 to day 2+: Docker-friendly evaluation, easy install and upgrade, great docs, community conventions. (INT-20261028-01)
- Flat, shallow dependency trees; a little copy-paste is better than another lib. (INT-20261028-02)
- Learn from the owner's prior libraries, including the velocity footguns: slow CI, wasted cycles, reinvented wheels. (INT-20261028-02, INT-20261028-01)
- Never commit the owner's PII. (INT-20261028-01)

- Shift left and automate the world: wherever a static analysis, runtime or CI check can save people from themselves and give early feedback, add one, up to the point of diminishing returns. (INT-20261028-14, INT-20261028-07)

## How to plan
- Upstream research is far cheaper than downstream rework, so do multi-pass, multi-role fan-out until returns diminish, with opinionated, coherent recommendations. (INT-20261028-03, INT-20261028-01)
- Record intent with provenance so later work stays pointed the right way and can fan out again consistently. (INT-20261028-04)
- Getting things working fast matters, but never at the cost of the north-star bar. (INT-20261028-04)
