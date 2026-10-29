# 0006. The Fablebook dependency is available in all envs; stories are never compiled in prod

**Status:** Accepted · Amended 2026-10-28 (INT-20261028-18) · **Cites:** INT-20261028-01

## Context
Router macros expand even inside a false `if` block. With `only: :dev`, a prod compile hits an undefined macro. The mailglass demo had to work around this with a hand-written `Code.ensure_loaded?(PhoenixStorybook.Router)` guard macro.

## Decision
- The dependency is declared without `only:`, following the LiveDashboard pattern. In prod it loads only inert router macros: no processes, no stories, no canon parsing.
- The installer mounts Fablebook inside the host's `if Application.compile_env(:my_app, :dev_routes)` block.
- When `Mix.env() == :prod`, the macro returns code that raises a `CompileError`. The error fires only when the mount is reachable in a prod build, so a mount inside a false `dev_routes` block compiles cleanly. The message's first line is `Fablebook cannot be mounted in a prod build`. There is no override in 1.0; an authenticated hosted mode is deferred to v2.
- Stories and canon live in `storybook/` and `design/`, and `storybook/` is not in the prod `elixirc_paths`.
- **CI guard:** build the operator host app with `MIX_ENV=prod`, then assert that `mix phx.routes` lists no Fablebook routes and that no story beams exist. Until `hosts/operator` exists, the guard runs against `test/fixtures/prod_guard_host/` (OPEN-QUESTIONS Q31).
- An `only: [:dev, :test]` recipe, with its guard snippet, is documented as an alternative.

## Reversal trigger
Adopter feedback shows prod tarball presence is a blocker for compliance reviews.

## Amendments (release pipeline sign-off, 2026-10-28)
- **Guard timing (Q7, D-01):** the `CompileError` is emitted in the macro's returned code, not raised in the macro body, so a mount inside a false `dev_routes` block compiles cleanly in prod and only a reachable mount fails. (INT-20261028-18)
- **Message (D-04):** the canonical first line is `Fablebook cannot be mounted in a prod build`, the README Troubleshooting heading. (INT-20261028-18)
- **CI target:** until `hosts/operator` exists, the prod-build guard runs against `test/fixtures/prod_guard_host/`; Q31 stays open. (INT-20261028-18)
