# Walking Skeleton: Fablebook

**Phase:** 1
**Generated:** 2026-10-28

Fablebook is a Hex library, not an application. Its walking skeleton therefore has no database, no UI and no deployed server. The full stack of a library is: repository, mix project, public macro, a host that consumes it, a prod build of that host, CI, and the package registry. This skeleton touches every one of those layers, and nothing else is claimed.

## Capability Proven End-to-End

A Phoenix host that writes `fablebook "/fablebook", MyAppWeb.Storybook` inside its `dev_routes` block gets a placeholder route in dev and compiles cleanly in prod with no Fablebook route and no story beam. An unguarded mount fails the prod build with the canonical `Fablebook cannot be mounted in a prod build` CompileError. `ci-gate` proves both cases on the latest and floor lanes for every PR, and the same code ships as `fablebook` 0.1.0 on Hex.

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Packaging | LiveDashboard-style router macro `Fablebook.Router.fablebook/2`; dependency declared in all envs | ADR 0005 and ADR 0006: router macros expand inside a false `if`, so an `only: :dev` dep breaks prod compiles |
| Prod guard | `Mix.env()` read inside the macro body; prod returns only a `raise CompileError` quote | D-01 and Q7: a raise in the macro body would fire inside a false `dev_routes` block |
| Book reference | `Macro.expand` with `function: {:fablebook, 2}` (runtime-only dependency) | D-02: story edits never recompile the host router |
| Processes | none; a plain Plug placeholder | ADR 0005: zero processes in the host |
| Data layer | none | A library with no persistence. Later phases read compiled modules (ADR 0001, ADR 0008), never a database |
| Auth | none; dev-only mount, prod refused at compile time | ADR 0006: hosted or authenticated mode is deferred to v2 |
| UI | none; a text/plain placeholder response | The chrome arrives in Phase 11; Phase 2 adds the first rendered story |
| Deployment target | Hex package plus a GitHub release, through release-please and `hex-publish.yml` | ADR 0017 and D-08 to D-15: one publish implementation, draft until smoke and SBOM pass |
| Version lanes | latest Elixir 1.20.4 / OTP 29.1.2 (`mix.lock`); floor Elixir 1.18.5 / OTP 27.3.4.9 (`mix.floor.lock`, Phoenix 1.8.9, LiveView 1.2.9) | D-16, pending the owner sign-off in Plan 01-01: approve-except-ranges keeps `~> 1.8.16` / `~> 1.2.9` and a Phoenix 1.8.16 floor; approve-except-d16 also keeps ADR 0007's latest lane, Elixir 1.19 / OTP 28 |
| CI shape | exactly 3 workflows; `ci.yml` at 250 lines or fewer; one required check, `ci-gate`; agent merges also require every PR job to be present and passing; ci-health re-runs the shape scan on main | ADR 0017 and D-17; enforced by `test/contract/ci_shape_test.exs` |
| Guards | contract tests in `test/contract/`, intent and process tests in `test/planning/`; the D-21 pairing rule protects both | ADR 0021 and D-21 |
| Directory layout | `lib/fablebook/*` (shipped); `test/{contract,planning,support,fixtures}`; `credo/checks/` (never shipped); `bin/` (operational scripts); `.github/` (5 files) | the package `files:` allowlist (D-28) ships only `lib`, `mix.exs`, `.formatter.exs` and four top-level docs |

## Stack Touched in Phase 1

- [x] Project scaffold: mix project, formatter, Credo, Dialyzer, ExUnit, two lockfiles (Plan 01-01)
- [x] Routing: one real route through `Phoenix.Router.get` to `Fablebook.Placeholder` in a real host fixture and in a generated `phx.new` host (Plans 01-01, 01-02)
- [ ] Database: not applicable. Fablebook has no persistence, and none is planned (ADR 0001, ADR 0008)
- [ ] UI: not applicable in Phase 1. The placeholder answers text/plain; the canvas and chrome come in Phases 2, 7 and 11
- [x] Deployment: CI on every PR (`ci-gate`), and publication of 0.1.0 to Hex with smoke checks and an SBOM (Plans 01-02, 01-05)

## Out of Scope (Deferred to Later Slices)

- `hosts/operator` and any second host app (Phase 2; Q31 is open)
- Stories, scenarios, the catalog, the canvas iframe and the chrome
- The Igniter installer (the smoke consumer records it as `not-run`)
- Book options for `fablebook/3` (the formatter already allows the arity; no options ship in 0.1.0)
- SEC-01 properties and mutation tests (Phase 5); a runtime call trace of banned functions (Phase 5)
- Trusted publishing on Hex; enforcement of recorded-output changes; a doctor warning for custom non-prod envs (Q32)

## Subsequent Slice Plan

Each later phase adds one vertical slice on top of this skeleton without changing its decisions:

- Phase 2: one story rendering in two host apps, one guarded visual check, the browser-runner criteria answered
- Phase 3: compiled stories and the pure catalog behind the same router mount
- Phase 4: the render seam, rules engine and generated tests
- Phase 5: typed controls and URL state, with the never-eval and never-atom properties completing SEC-01
- Phase 6: one redacted no-browser context bundle for a scenario
