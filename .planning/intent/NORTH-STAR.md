# North star

> **Fablebook is where every real state of a Phoenix LiveView UI, from primitive to full screen, is visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.**

The owner keeps using phoenix_storybook until Fablebook clears `CLEARANCE.md`. That means there is no pressure to ship anything mediocre. Speed comes from small phases, never from weaker gates. (INT-20261028-04)

## Non-negotiables

1. **The quality bar is never compromised.** If a phase can't meet its gates, it splits. A gate is lowered only by an owner-signed decision that cites an INT id.
   *How we'd know:* no threshold commit without a DECISION entry; release PRs run the full suite. (INT-20261028-04, INT-20261028-01)

2. **Fidelity is the product.** A scenario renders exactly as the real app would: the same CSS bytes, fonts, hooks, layout and CSP.
   *How we'd know:* the operator host app passes the font, CSS, hook and CSP fidelity specs; nothing like phoenix_storybook's `.psb-sandbox` overrides exists. (INT-20261028-01)

3. **LLM-ready by construction.** Any scenario, story, section or the whole catalog exports a high-signal, budgeted, deterministic context bundle: screenshots, markup, ARIA, measurements, a11y and contrast, and the cited brand, glossary, persona and job context.
   *How we'd know:* golden bundle tests; a "Copy for LLM" action exists on every scenario. (INT-20261028-04)

4. **The whole design system across its whole life.** Fablebook covers:
   - **Every level of UI:** Primitive → Pattern → Area (including the Shell) → Screen.
   - **Every level of product:** brand → product → product family, including white-label.
   - **Design knowledge as first-class, pruned content:** the user-facing glossary mapped to internal terms, voice and microcopy, personas and JTBD, the brand book and tokens, and imagery rules.
   - **Every stage of a product's life:** greenfield, growth, maturity and refresh, with a comparison possible along any single axis at any level.
   - **The intended user:** a solo developer or a very small team with an AI agent, replacing the need for Figma.

   *How we'd know:* canon lints and coverage reports run in the PR lane; the Logistify product family and the Shopadelic white-label storefront twins pass their checks; Compare mode works at every tier. (INT-20261028-04, INT-20261028-09, INT-20261028-10)

5. **Realistic situations, not prop permutations.** Scenarios cover happy, empty, error and boundary situations with realistic persona-grounded data. They are mobile-first, light/dark/system, and accessible by default.
   *How we'd know:* every authored scenario names its situation, and the strict-by-default rule (ADR 0024) fails any Area or Screen scenario that cites no persona and job; the sweep covers 320 to 1440 px × light and dark; axe runs at wcag22aa. (INT-20261028-04, INT-20261028-01)

6. **Secure and correct by construction.** Nothing from the client is ever evaluated, no atoms are created from input, and nothing compiles into prod by accident.
   *How we'd know:* Credo bans, never-eval and never-atom properties, the prod-build route check. (INT-20261028-01)

7. **Idiomatic, lean and a joy to use.** Phoenix-native (LiveView, no React), flat dependencies (copy-paste beats another dep), no Node for adopters, fast cheap CI, aha in under 5 minutes on day 0, and painless upgrades from day 2 on.
   *How we'd know:* the dependency budget test, a PR p50 of 7 minutes or less, the clean-room install spec. (INT-20261028-01, INT-20261028-02)
