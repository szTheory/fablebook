---
phase: 01-release-pipeline-ci-gate-and-guards
plan: 03
subsystem: security
tags: [beam-guard, credo, adr-0004, adr-0018, dependency-budget, tarball, hex]

requires:
  - phase: 01-01
    provides: "mix ci alias, Fablebook.Test.MixCmd, mix.floor.lock with the FABLEBOOK_FLOOR switch, package files list"
  - phase: 01-02
    provides: "core and floor CI jobs that run mix ci and the floor suite"
provides:
  - "Fablebook.Test.BeamWalker.scan/1: atoms from abstract code, imported MFAs, compile source; {:error, :no_debug_info} fails closed"
  - "test/contract/banned_calls_test.exs: BEAM atom and MFA tiers with @allowlist [], eight bypass fixtures, Credo parity, credo:disable and mix.exs scans"
  - "Fablebook.Credo.BannedCalls (credo/checks/, never compiled or shipped) and .credo.exs extra checks"
  - "test/contract/style_attr_test.exs: D-25 inline-style scan with one positive sample per regex"
  - "test/contract/dependency_budget_test.exs: D-26 classification, prod-closure walk over hex_metadata.config, floor-version proof"
  - "test/contract/tarball_test.exs (:release): D-28 exact file set, deny list, metadata and PII scan of the unpacked hex.build"
affects: [01-04, 01-05, 05]

actuals:
  tokens: 6600
  tasks: 3
  commits: 5
plan_head_before: 9964f44283c8cab978f1883787c68b719e72a3ea
plan_head_after: 09ad8bd23262597c4f3de7a21e11353733ee90d4

tech-stack:
  added: []
  patterns:
    - "Ban lists, allowlists and regexes live as data in the contract test; regexes are strings compiled at runtime"
    - "Negative fixtures compile into an ExUnit tmp_dir with debug_info forced on and restored afterwards"
    - "Every checker is a pure private function with synthetic negative cases beside the real scan"

key-files:
  created:
    - test/support/beam_walker.ex
    - test/contract/banned_calls_test.exs
    - test/contract/style_attr_test.exs
    - test/contract/dependency_budget_test.exs
    - test/contract/tarball_test.exs
    - credo/checks/banned_calls.ex
    - test/fixtures/guards/alias.ex
    - test/fixtures/guards/import.ex
    - test/fixtures/guards/apply.ex
    - test/fixtures/guards/capture.ex
    - test/fixtures/guards/macro_quote.ex
    - test/fixtures/guards/interpolated_atom.ex
    - test/fixtures/guards/dynamic_module.ex
    - test/fixtures/guards/banned_dep.ex
  modified:
    - .credo.exs

key-decisions:
  - "The Credo check is loaded at test-module compile time (Code.require_file in the module body when not loaded), because Elixir 1.20's type checker warns on a call to a module that only exists at runtime"
  - "The Credo guard test starts :credo only when Credo.Supervisor is absent, since mix ci's credo step has already started it in the same VM"
  - "Synthetic PII samples are built by concatenation, so the test file itself never matches the repo's pre-push home-path and email scan"

patterns-established:
  - "Contract-test tier lists are the single source; the Credo check's banned_names/0 is asserted equal to the BEAM atom tier"

requirements-completed: []
requirements-advanced: [SEC-01, REL-01]

coverage:
  - id: D1
    description: "BEAM guard scans every lib/ module (Fablebook, Fablebook.Router, Fablebook.Placeholder) with zero hits, catches all eight bypass fixtures, and fails closed on a beam without debug info"
    requirement: SEC-01
    verification:
      - kind: unit
        ref: "mix test --warnings-as-errors test/contract/banned_calls_test.exs (Elixir 1.20.4 / OTP 29.1.1)"
        status: pass
      - kind: unit
        ref: "temporary def x(s), do: Code.eval_string(s) in lib/fablebook.ex -> banned in lib/: [{Fablebook, {:atom, :eval_string}}] (reverted)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Credo source layer (UnsafeToAtom, MixEnv with router-only exemption, ForbiddenModule, Fablebook.Credo.BannedCalls) is clean on the repo and fires on lib/ probes; credo:disable and style= probes fail the suite"
    requirement: SEC-01
    verification:
      - kind: other
        ref: "mix credo --strict (exit 0, found no issues); temporary lib probes produced BannedCalls, ForbiddenModule, UnsafeToAtom and MixEnv issues (reverted)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Dependency budget: exact required set, no banned direct dep, prod closure contains plug and no banned or yaml package; floor lane loads phoenix 1.8.9 and phoenix_live_view 1.2.9"
    requirement: SEC-01
    verification:
      - kind: unit
        ref: "mix test --warnings-as-errors test/contract/dependency_budget_test.exs (latest, 5 passed; floor check prints not-run)"
        status: pass
      - kind: unit
        ref: "FABLEBOOK_FLOOR=1 on Elixir 1.18.4 / OTP 27.3.4.15: 5 tests, 0 failures, no not-run line"
        status: pass
    human_judgment: false
  - id: D4
    description: "Tarball allowlist: unpacked hex.build holds exactly lib/** plus the six top-level files and hex_metadata.config, metadata matches D-26, no PII"
    requirement: REL-01
    verification:
      - kind: integration
        ref: "mix test --warnings-as-errors --include release test/contract/tarball_test.exs (4 passed)"
        status: pass
    human_judgment: false
  - id: D5
    description: "mix ci green with every new contract test on the latest lane, and the full suite green on the floor lane"
    requirement: SEC-01
    verification:
      - kind: other
        ref: "mix ci (exit 0, Result: 28 passed, Elixir 1.20.4 / OTP 29.1.1)"
        status: pass
      - kind: other
        ref: "FABLEBOOK_FLOOR=1 mix test --warnings-as-errors --include prod_guard --include release (28 tests, 0 failures, Elixir 1.18.4 / OTP 27.3.4.15)"
        status: pass
      - kind: other
        ref: "CI evidence through ci-gate after Plan 01-04 pushes the branch"
        status: not-run
    human_judgment: false

duration: 11min
completed: 2026-10-29
status: complete
---

# Phase 1 Plan 03: Code bans, dependency budget and tarball allowlist Summary

**A compiled-BEAM guard with eight bypass fixtures, a parity-checked Credo layer, a `style=` scan, a dependency-budget test with floor-version proof, and a tarball allowlist now run in `mix ci`. Any eval, atom-from-input, banned dependency or stray packaged file fails the suite.**

## Performance

- **Duration:** about 11 min (2026-10-29T00:20:54Z to 00:31:40Z)
- **Tasks:** 3 of 3
- **Files:** 14 created, 1 modified

## Accomplishments

- **The BEAM guard is the gate.** `Fablebook.Test.BeamWalker` reads the `debug_info`, `imports` and `compile_info` chunks. The contract test scans every `lib/` module from `Application.spec(:fablebook, :modules)` and asserts the three known modules are in the scanned set, so the scan can't pass vacuously. Missing debug info returns `{:error, :no_debug_info}` and counts as a failure.
- **Every bypass form is caught.** Each fixture reports its expected hit after being compiled into a tmp dir: alias, import, `apply`, capture (`:eval_string`), macro quote (`:eval_quoted`), interpolated atom (`:binary_to_atom`), dynamic module (`{Module, :concat, 1}`) and banned dep (`Jason`). Re-verified on Elixir 1.20.4 with LiveView 1.2.13, and on 1.18.4 with LiveView 1.2.9.
- **Eval probe, as observed:** with `def x(s), do: Code.eval_string(s)` added to `lib/fablebook.ex`, the guard failed with `banned in lib/: [{Fablebook, {:atom, :eval_string}}]` (10 of 11 passed). The probe was reverted before the commit.
- **The Credo layer matches the BEAM tier.**
  - `Fablebook.Credo.BannedCalls.banned_names/0` is asserted equal to the sorted atom tier.
  - It flags all fixtures except `dynamic_module.ex`, which the MFA tier covers, and finds nothing in `lib/`.
  - A lib probe produced BannedCalls, ForbiddenModule, UnsafeToAtom and MixEnv issues. `router.ex` stays the only MixEnv exemption, through the per-check `files:` parameter (Pitfall 6).
- **`credo:disable` and `style=` probes fail the suite.** A `# credo:disable-for-next-line Credo.Check.Warning.UnsafeToAtom` line and a `<div style="x">` string in `lib/fablebook.ex` failed both tests, naming `lib/fablebook.ex:9` and `:10`. Both were reverted.
- **Dependency budget.**
  - The real `mix.exs` classifies to exactly the five required deps, no optional deps, and only non-prod tools.
  - The prod closure, walked over `hex_metadata.config`, reaches `plug` (the positive control) and contains no banned or yaml package.
  - A metadata-shaped synthetic graph proves that non-optional `yaml_elixir -> yamerl` edges are caught and an optional `jason` edge is skipped.
- **Tarball allowlist.** `mix hex.build --unpack` (run with MIX_ENV=dev through `MixCmd`) yields exactly `lib/**`, the six top-level files and `hex_metadata.config`. The metadata (name, app, version, MIT, requirements, files) and the PII scan both pass. Synthetic cases cover each checker.

## Test counts

| File | Tests | Lane results |
|---|---|---|
| test/contract/banned_calls_test.exs | 14 | latest pass; floor pass |
| test/contract/style_attr_test.exs | 3 | latest pass; floor pass |
| test/contract/dependency_budget_test.exs | 5 | latest pass (floor check prints `not-run`); floor pass, floor versions asserted |
| test/contract/tarball_test.exs (`:release`) | 4 | latest pass; floor pass |
| Full suite with `prod_guard` and `release` | 28 | `mix ci` exit 0 (latest, `Result: 28 passed`); floor `28 tests, 0 failures` |

**Floor-lane result:** `FABLEBOOK_FLOOR=1` on Elixir 1.18.4 / OTP 27.3.4.15 loaded phoenix 1.8.9 and phoenix_live_view 1.2.9, matching the first versions in the `mix.exs` requirement strings. No `not-run` line was printed. `mix deps.get` was re-run on the latest lane afterwards.

## Task Commits

1. **Task 1: Compiled-BEAM ban guard.** RED `646f585` (10 of 11 failing: walker undefined, fixtures absent), then GREEN `8165f17`.
2. **Task 2: Credo layer, credo:disable and mix.exs scans, `style=` check.** `18de756`.
3. **Task 3: Dependency budget and tarball allowlist.** RED `eb5a12e` (checkers stubbed: 3 of 5 and 3 of 4 failing on behaviour), then GREEN `09ad8bd`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] ExUnit reserves the `:file` tag**
- **Found during:** Task 1 RED run
- **Issue:** `@tag file: ...` raised `cannot set tag :file because it is reserved by ExUnit`.
- **Fix:** Renamed the tag to `:fixture`.
- **Files modified:** test/contract/banned_calls_test.exs
- **Commit:** 646f585

**2. [Rule 3 - Blocking] Elixir 1.20 type warning on the runtime-loaded Credo check**
- **Found during:** Task 2
- **Issue:** Loading the check inside a test function and then calling `check.banned_names()` raised a warning that the module is undefined, which aborts `--warnings-as-errors`.
- **Fix:** The test module body now runs `Code.ensure_loaded?(BannedCalls) || Code.require_file(...)` at compile time, so the module exists before its calls are checked. "Load once when not loaded" still holds.
- **Files modified:** test/contract/banned_calls_test.exs
- **Commit:** 18de756

**3. [Rule 1 - Bug] The Credo parity test failed only inside `mix ci`**
- **Found during:** Task 3 verification (`mix ci`)
- **Issue:** The `credo --strict` alias step had already started `Credo.Supervisor` in the same VM. `Application.ensure_all_started(:credo)` therefore returned `already_started`, and the match failed.
- **Fix:** The test starts `:credo` only when `Credo.Supervisor` is not running.
- **Files modified:** test/contract/banned_calls_test.exs
- **Commit:** 09ad8bd

### Notes

- `credo/checks/banned_calls.ex` has no `@moduledoc false`. `use Credo.Check` generates its own `@moduledoc`, so a manual one would be overwritten. The file is outside `lib/`, `elixirc_paths` and the package files.
- The `style=` and tarball regexes are held as strings and compiled at runtime. Compiled regexes cannot be stored in module attributes on OTP 28+.
- The Credo check flags only names in the atom tier. So `String.to_atom` reaches the source layer through `UnsafeToAtom`, and `Module.concat` only through the BEAM MFA tier. This matches D-23.
- SEC-01 and REL-01 are advanced, not complete (ADR 0010 honesty rule):
  - SEC-01 still needs Phase 5's properties and mutation tests.
  - REL-01 still needs the 0.1.0 publish.
  - CI evidence for this plan arrives when Plan 01-04 pushes the branch.

## Issues Encountered

- `.planning/state.json` was untracked before the plan started and was left alone.

## Next Phase Readiness

- Plan 01-04 can push the branch tip. `ci-gate` will then run every new contract test in `core`, and the floor-version proof in `floor`.

## Self-Check: PASSED

- All 14 created files and `.credo.exs` exist. Commits `646f585`, `8165f17`, `18de756`, `eb5a12e` and `09ad8bd` are ancestors of HEAD.
