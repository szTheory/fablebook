# 0006. The Fablebook dependency is available in all envs; stories are never compiled in prod

**Status:** Accepted · **Cites:** INT-20261028-01

## Context
Router macros expand even inside a false `if` block. With `only: :dev`, a prod compile hits an undefined macro. The mailglass demo had to work around this with a hand-written `Code.ensure_loaded?(PhoenixStorybook.Router)` guard macro.

## Decision
- The dependency is declared without `only:`, following the LiveDashboard pattern. In prod it loads only inert router macros: no processes, no stories, no canon parsing.
- The installer mounts Fablebook inside the host's `if Application.compile_env(:my_app, :dev_routes)` block.
- The macro raises at compile time when `Mix.env() == :prod`. There is no override in 1.0; an authenticated hosted mode is deferred to v2.
- Stories and canon live in `storybook/` and `design/`, and `storybook/` is not in the prod `elixirc_paths`.
- **CI guard:** build the operator host app with `MIX_ENV=prod`, then assert that `mix phx.routes` lists no Fablebook routes and that no story beams exist.
- An `only: [:dev, :test]` recipe, with its guard snippet, is documented as an alternative.

## Reversal trigger
Adopter feedback shows prod tarball presence is a blocker for compliance reviews.
