# 0001. Stories are compiled `.ex` modules in `storybook/`

**Status:** Accepted, 2026-10-28 · **Cites:** INT-20261028-01, INT-20261028-04

## Context
phoenix_storybook compiles `.story.exs` files at runtime. That one choice causes four of its problems:
- it is an eval surface (CVE-2026-8467);
- the enumeration API exists only in dev, so there is no manifest under `MIX_ENV=test`;
- eager mode recompiles on every add or remove;
- it is incompatible with colocated hooks.

## Decision
Stories are ordinary Elixir modules under `storybook/` at the project root, compiled by `mix`. The installer adds `storybook/` to `elixirc_paths` for `:dev` and `:test` only. `use Fablebook.Story` injects at most 20 lines: an `@on_definition` capture of `@scenario` metadata, plus a `@before_compile` that emits `__fablebook_story__/0`. Fixtures live in host code (e.g. `storybook/support/`).

## Rejected
- `.exs` runtime compile: eval surface, dev-only enumeration, no colocated hooks.
- `lib/storybook`: ships to prod.
- `test/support`: missing in dev.

## Consequences
- Stories get compile-time validation, LiveView's call-site attr verification, `--warnings-as-errors`, xref/dialyzer, editor jump and colocated hooks.
- Compile cost is measured (ADR 0015). A CI check confirms no `lib/` module depends on the storybook namespace.

## Reversal trigger
Compile overhead in the host exceeds 15% even after the xref fixes.
