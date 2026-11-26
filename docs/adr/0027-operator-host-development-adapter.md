# 0027. Keep the operator host's HTTP adapter development-only

**Status:** Accepted · 2026-11-21 · **Cites:** INT-20261120-14, ADR 0018

## Context

The v0.7 exception calls for a locally openable Phoenix host so a developer can inspect one fixed compiled Book through the real catalog and Canvas. The reviewed root `mix.lock` and `mix.floor.lock` contain no installed Bandit or Plug.Cowboy package entries; Phoenix lists them only as optional adapter dependencies. A Phoenix endpoint without an adapter cannot serve the local URL required for a browser inspection.

The source-grounded scope and adapter audit are recorded in [Phase 8 research](../../.planning/milestones/v0.7-phases/08-first-inspectable-book-and-local-host-path/08-RESEARCH.md). Hex currently lists Bandit 1.15.0 as an MIT package, with no advisory affecting that version. Its dependency requirements include HPAX and Thousand Island; the selected host pins are kept separate from the library locks.

## Decision

- Add Bandit 1.15.0 only to `hosts/operator` with `only: :dev`, in a dedicated `hosts/operator/mix.lock`.
- Pin the audited HPAX and Thousand Island versions in that host lock. Keep the shared Phoenix, LiveView and Plug core versions aligned with the reviewed library locks.
- Enable the listener only when the operator host's explicit server flag is set, bind it to `127.0.0.1`, and use the documented loopback port.
- Keep Bandit and serving disabled in test and production, even if the server flag is present.
- Do not add an adapter dependency to Fablebook's `mix.exs`, `mix.lock` or `mix.floor.lock`. The library remains usable without an HTTP server; host endpoint tests call the endpoint directly.
- Keep Node and browser tooling optional. The development adapter serves the Phoenix host; it does not add a frontend build requirement.

## Alternatives considered

- **No listener:** rejected because server-only test calls cannot establish that a developer can open the host in a browser.
- **Add Bandit or Plug.Cowboy to Fablebook's library dependencies:** rejected because the library does not own the adopter's HTTP server and the dependency budget requires the library's runtime closure to remain unchanged.
- **Use a JavaScript development server:** rejected because the UI and Canvas use the host's Phoenix pipeline and same-origin assets; an extra server would not prove that path.

## Reversal trigger

Remove the host-only adapter when the host no longer needs a local HTTP listener, or replace the pin if the package is retired, an advisory affects it, or a lower-scope compatible adapter becomes available. Re-evaluate this ADR before changing any root library dependency.

## Evidence

- [Bandit 1.15.0 package and license](https://hex.pm/packages/bandit/1.15.0)
- [Bandit 1.15.0 dependency requirements](https://hex.pm/packages/bandit/1.15.0/dependencies)
- [Bandit 1.15.0 security advisories](https://hex.pm/packages/bandit/1.15.0/advisories)
- [Phoenix endpoint adapter documentation](https://phoenix.hexdocs.pm/Phoenix.Endpoint.html)
