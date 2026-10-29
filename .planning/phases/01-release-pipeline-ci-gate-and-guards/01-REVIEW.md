---
phase: 01-release-pipeline-ci-gate-and-guards
reviewed: 2026-10-29T02:39:03Z
depth: standard
files_reviewed: 46
files_reviewed_list:
  - .credo.exs
  - .formatter.exs
  - .github/actions/setup/action.yml
  - .github/workflows/ci.yml
  - .github/workflows/hex-publish.yml
  - .github/workflows/release-please.yml
  - .github/zizmor.yml
  - .release-please-manifest.json
  - .tool-versions
  - bin/ci_health
  - bin/floor_lock
  - bin/smoke_consumer
  - credo/checks/banned_calls.ex
  - lib/fablebook.ex
  - lib/fablebook/placeholder.ex
  - lib/fablebook/router.ex
  - mix.exs
  - release-please-config.json
  - test/contract/banned_calls_test.exs
  - test/contract/ci_shape_test.exs
  - test/contract/dependency_budget_test.exs
  - test/contract/prod_guard_message_test.exs
  - test/contract/prod_guard_test.exs
  - test/contract/style_attr_test.exs
  - test/contract/tarball_test.exs
  - test/fixtures/ci_shape/base.yml
  - test/fixtures/guards/alias.ex
  - test/fixtures/guards/apply.ex
  - test/fixtures/guards/banned_dep.ex
  - test/fixtures/guards/capture.ex
  - test/fixtures/guards/dynamic_module.ex
  - test/fixtures/guards/import.ex
  - test/fixtures/guards/interpolated_atom.ex
  - test/fixtures/guards/macro_quote.ex
  - test/fixtures/prod_guard_host/config/config.exs
  - test/fixtures/prod_guard_host/lib/guard_host/ok.ex
  - test/fixtures/prod_guard_host/lib/guard_host_web/router.ex
  - test/fixtures/prod_guard_host/mix.exs
  - test/fixtures/prod_guard_host/storybook/book.ex
  - test/fixtures/prod_guard_host/unguarded/router.ex
  - test/planning/contract_rule_test.exs
  - test/planning/intent_test.exs
  - test/support/beam_walker.ex
  - test/support/git_diff.ex
  - test/support/mix_cmd.ex
  - test/test_helper.exs
findings:
  critical: 1
  warning: 6
  info: 5
  total: 12
status: issues_found
---

# Phase 1: Code Review Report

**Reviewed:** 2026-10-29T02:39:03Z
**Depth:** standard
**Files Reviewed:** 46
**Status:** issues_found

## Summary

I reviewed the Phase 1 source: the router macro and its prod guard, the guard fixtures, the contract and planning tests, the three workflows, the composite action, and the `bin/` scripts. I did not take any claim on trust. Each finding below was checked against the current source, and the key claims were reproduced locally or against the live repository:

- **Ban-gate bypasses.** Probe modules were compiled with Elixir 1.20.4 / OTP 29.1.1 and run through `Fablebook.Test.BeamWalker` with the contract test's ban sets.
- **Path-dependency env.** A two-project poncho layout was compiled in `MIX_ENV=dev` to see what `Mix.env()` a path dependency gets.
- **mix.exs scan.** The text-scan regex was run against qualified calls.
- **Repository state.** The `hex-production` deployment policies and the rulesets were read with `gh api`.

What works:
- The prod guard macro is correct for the standard `phx.new` layout.
- The fixture test has real positive controls (steps 1–3, plus the host-route assertion in step 5).
- The workflows avoid `${{ }}` inside `run:`.
- The ci-gate jq expression is right.

The most serious defect: the SEC-01 atom ban, which this phase presents as its compiled-BEAM gate, can be bypassed in one line (`apply(String, :to_atom, [input])`), and neither layer catches it.

## Narrative Findings (AI reviewer)

## Critical Issues

### CR-01: The atom ban gate and Credo both miss `apply/3` (and `Function.capture/3`) dispatch to `String.to_atom` / `List.to_atom`

**File:** `test/contract/banned_calls_test.exs:41-52` (MFA tier), `test/fixtures/guards/apply.ex:2`, `credo/checks/banned_calls.ex:15-42`

**Issue:** The atom tier works only because Elixir rewrites a direct `String.to_atom(x)` to `:erlang.binary_to_atom(x, :utf8)` before the debug-info abstract code is produced. That rewrite does not apply to `apply/3` with literal module and function arguments, or to `Function.capture/3`. Those forms keep `'Elixir.String':to_atom/1` (or `List.to_atom/1`, `*.to_existing_atom/1`), and none of those MFAs is in `@mfa_tier`. I compiled probes with Elixir 1.20.4 / OTP 29.1.1 and ran them through `BeamWalker.scan/1` with the test's ban sets:

```
Probe.ApplyToAtom        apply(String, :to_atom, [x])           atoms=[] mfas=[]
Probe.ApplyListExisting  apply(List, :to_existing_atom, [x])    atoms=[] mfas=[]
Probe.FunctionCapture    Function.capture(String, :to_atom, 1)  atoms=[] mfas=[]
Probe.DirectToAtom       String.to_atom(x)                      atoms=[:binary_to_atom]  (caught)
```

The source layer misses them too:
- `Fablebook.Credo.BannedCalls` matches only the atom-tier names, and `:to_atom` is not one of them.
- `Credo.Check.Warning.UnsafeToAtom` (`deps/credo/lib/credo/check/warning/unsafe_to_atom.ex:84-120`) matches only direct `{{:., _, [String, :to_atom]}, _, [_]}` calls and pipes. It ignores `apply`.

So a `lib/` module can create atoms from input and pass `mix ci` on both lanes. The `apply.ex` fixture tests only `apply(Code, :eval_string, ...)`, where the banned name happens to be an atom literal, so it gives false confidence that `apply` forms are covered. This breaks ADR 0004, which is a non-negotiable.

**Fix:** Ban the Elixir-level atom constructors by MFA. Add a fixture for each dispatch form. Per the contract-test rule, this is a contract-test change with no `lib/` change, so it is allowed in its own PR.

```elixir
@mfa_tier [
  {String, :to_atom, 1},
  {String, :to_existing_atom, 1},
  {List, :to_atom, 1},
  {List, :to_existing_atom, 1},
  {Function, :capture, 3},
  # ...existing entries
]

@fixtures [
  {"apply_to_atom.ex", {:mfa, {String, :to_atom, 1}}},
  # ...
]
```

```elixir
# test/fixtures/guards/apply_to_atom.ex
defmodule Fablebook.GuardFixture.ApplyToAtom do
  def run(name), do: apply(String, :to_atom, [name])
end
```

Also add `:to_atom` and `:to_existing_atom` to the Credo check's names, or add an `apply`/`Function.capture` clause that inspects literal function atoms, so the source layer agrees with the BEAM layer.

## Warnings

### WR-01: A router in a path dependency raises "cannot be mounted in a prod build" in dev

**File:** `lib/fablebook/router.ex:25`

**Issue:** The guard treats `Mix.env() == :prod` as meaning "this is a prod build". Mix compiles a path dependency with its `:env` option, which defaults to `:prod`, whatever the top-level `MIX_ENV`. I checked this with a two-project layout: under `MIX_ENV=dev mix compile`, the path dependency printed `Mix.env() while compiling the path dep: :prod`.

In a poncho layout (`{:my_app_web, path: "../my_app_web"}`), the top-level `config/dev.exs` sets `config :my_app_web, dev_routes: true`. The `if` branch is then taken, and the macro expands to the prod `raise`. A correct dev mount fails to compile with a message that blames prod. Umbrella children are not affected, because `in_umbrella` deps inherit the parent env. This is a false positive in the public 0.1.0 API.

**Fix:** At minimum, document it in the Troubleshooting section under the canonical heading: "if your router lives in a path dependency, declare it with `env: Mix.env()`". Then add that hint to the CompileError body itself (a second paragraph after the canonical first line), so the message never blames prod without naming the path-dependency case. Add this case to OPEN-QUESTIONS next to Q32, because it is the same "env is not the build" family.

### WR-02: The mix.exs ban scan cannot match any qualified call

**File:** `test/contract/banned_calls_test.exs:133-143`

**Issue:** The regex `(?<![\w.])NAME(?![\w!?])` excludes matches preceded by `.`. That excludes every remote call. I verified it:
- `Code.eval_string(x)`: false
- `:erlang.binary_to_atom(x, :utf8)`: false
- `Elixir.Telemetry.Metrics`: false
- bare `eval_string(x)`: true

`mix.exs` ships to adopters, and D-23 says it is "text-scanned with the same ban set". As written, the scan only catches imported or local calls, which almost never appear in a mixfile. The Credo layer does include `mix.exs`, so `mix ci` would still flag `Code.eval_string` there. But this test is effectively vacuous, and it does not run where Credo does not (the floor lane).

**Fix:** Use a word boundary that allows a leading `.`, and add a sample-based self-test like `style_attr_test` has:

```elixir
Regex.match?(~r/(?<![\w])#{Regex.escape(name)}(?![\w!?])/, text)
```

Add an assertion that the pattern matches `"Code.eval_string(x)"` and `":erlang.binary_to_atom(x, :utf8)"`.

### WR-03: Code-loading primitives other than `:code.load_binary/3` are not banned

**File:** `test/contract/banned_calls_test.exs:41-52`

**Issue:** The MFA tier bans `:code.load_binary/3`, but not:
- the BIF it wraps, `:erlang.load_module/2`;
- `Kernel.ParallelCompiler.compile/2`, `compile_to_path/3` and `require/2`, which compile and load arbitrary `.ex` files just as `Code.compile_file`/`require_file` do;
- `:code.load_abs/1`.

A probe calling `:erlang.load_module(m, bin)` produced `atoms=[] mfas=[]`. Each of these is runtime code loading, which is banned under ADR 0004.

**Fix:** Extend `@mfa_tier`, and add one fixture:

```elixir
{:erlang, :load_module, 2},
{:code, :load_abs, :_},
{Kernel.ParallelCompiler, :_, :_},
```

### WR-04: The contract-test rule does not guard the guard implementations, or itself

**File:** `test/planning/contract_rule_test.exs:8-11`

**Issue:** Only `test/contract/` and `test/planning/` count as guard paths. The guards actually live in several more places:
- `test/support/beam_walker.ex` (the ban scanner);
- `test/support/git_diff.ex` (the diff seam);
- `test/fixtures/guards/` and `test/fixtures/ci_shape/base.yml` (the fixtures that prove each rule fires);
- `credo/checks/banned_calls.ex` and `.credo.exs`;
- `test/test_helper.exs`.

A PR can quietly weaken `BeamWalker` (for example, skip one module) together with a `lib/` change that the original walker would have flagged, and the rule passes. Second, the rule's own file is under `test/planning/`, which is paired only with `.planning/intent/` and `REQUIREMENTS.md`. So one PR can change `lib/`, a contract test, and this test's `@pairs` all together. The rule then runs from the PR's weakened copy and passes.

**Fix:** Widen the guard prefixes, and pair `test/planning/` with code paths as well. This extends D-21's owner-signed table, so it needs an OPEN-QUESTIONS entry and owner sign-off before it lands.

```elixir
@code ["lib/", ".github/", "mix.exs"]
@pairs [
  {"test/contract/", @code},
  {"test/support/", @code},
  {"test/fixtures/", @code},
  {"test/test_helper.exs", @code},
  {"credo/", @code},
  {".credo.exs", @code},
  {"test/planning/", @code ++ [".planning/intent/", ".planning/REQUIREMENTS.md"]}
]
```

### WR-05: `hex-production` admits any `v*` tag, so a pushed tag can run a modified publish workflow with `HEX_API_KEY`

**File:** `.github/workflows/hex-publish.yml:12-16, 50-55, 87`; repository environment `hex-production`

**Issue:** `gh api .../environments/hex-production/deployment-branch-policies` returns `main` (branch) and `v*` (tag), and the only ruleset targets `main`. `hex-publish.yml` accepts `workflow_dispatch`. Anyone with push access can:
1. push `v9.9.9` on an unreviewed commit whose `hex-publish.yml` is edited;
2. dispatch the workflow from that tag ref;
3. the `publish` job then receives `HEX_API_KEY`.

Even without a modified workflow, the `tag` step only checks that the tag's shape matches the tag commit's `@version`. It never checks that the commit is on `main`, so dispatching from `main` with `tag: vX` publishes an unreviewed commit.

Neither real entry path needs the `v*` policy. Both the `workflow_call` from a push to `main` and a recovery dispatch from `main` run with `github.ref == refs/heads/main`.

**Fix:**
1. Remove the `v*` tag deployment policy from `hex-production` (record the change in the plan, as D-15 does).
2. In the `tag` step, assert ancestry:

```bash
[[ "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
git merge-base --is-ancestor "$TAG" origin/main
```

3. Optionally, add a tag ruleset that limits `v*` creation to the release-please identity.

### WR-06: Recovery cannot complete when the package upload succeeded but the docs upload failed

**File:** `.github/workflows/hex-publish.yml:94-119`; `bin/smoke_consumer:50`

**Issue:** `mix hex.publish --yes` uploads the package, then the docs. If the docs upload fails, the job fails with the package already on Hex. On the documented recovery path (dispatch again), the `hex` step sees HTTP 200 with a matching checksum, sets `published=true`, and skips every later step, so the docs are never uploaded. `smoke` then polls `https://hexdocs.pm/fablebook/$V/` for 10 minutes and fails on every retry. The release is stuck as a draft until someone runs `mix hex.publish docs` by hand outside the pipeline. That contradicts D-11's "idempotent recovery".

**Fix:** Split the decision into package and docs.

```bash
docs="$(curl -s -o /dev/null -w '%{http_code}' "https://hexdocs.pm/fablebook/$V/")"
echo "docs_published=$([ "$docs" = 200 ] && echo true || echo false)" >> "$GITHUB_OUTPUT"
```

Gate the checkout and setup steps on `published == 'false' || docs_published == 'false'`. Run `mix hex.publish --yes` when the package is missing, otherwise `mix hex.publish docs --yes`.

## Info

### IN-01: The floor-version test passes when it does not run

**File:** `test/contract/dependency_budget_test.exs:55-69`

**Issue:** Without `FABLEBOOK_FLOOR`, the test prints `not-run` but ExUnit records a pass. The project's honesty rule (ADR 0010) says a check that did not run is `not-run`, never `pass`.

**Fix:** Tag it (for example `@tag :floor`) and exclude it unless `FABLEBOOK_FLOOR` is set, or call `ExUnit` skip semantics, so the run reports it as skipped. Note that `@allowed_excludes` in `ci_shape_test.exs` would need the new tag. That is a contract-test edit, so it goes in its own PR.

### IN-02: The smoke consumer's prod route check has no positive control

**File:** `bin/smoke_consumer:101-106`

**Issue:** The fixture test asserts that the prod route list contains the host's `GET /` before it refutes Fablebook routes. The smoke script only refutes. Empty or reformatted `phx.routes` output would pass. D-06 calls the positive controls "required, without them 'no routes' passes trivially".

**Fix:** Add `grep -Eq '\sGET\s+/\s' <<<"$prod_routes" || { echo "prod routes empty" >&2; exit 1; }` before the refute.

### IN-03: The ci-gate step check is substring-only

**File:** `test/contract/ci_shape_test.exs:351-358`

**Issue:** `gate_step?/1` only requires the strings `toJSON(needs)`, `jq -e`, `nightly` and `release-please--` to appear somewhere in the step. A gate rewritten to `any(...)`, or one that checks only `.core`, still passes.

**Fix:** Compare the step's `run:` body to the exact canonical jq program, the same way `@ci_test_step` pins the alias.

### IN-04: `HEX_API_KEY` is visible to every step of the `publish` job

**File:** `.github/workflows/hex-publish.yml:88-91`

**Issue:** The secret is set in the job-level `env:`, so `erlef/setup-beam`, `mix deps.get` and `mix deps.compile` all run with it in their environment. Only the final `mix hex.publish` and the `test -n` check need it.

**Fix:** Move `HEX_API_KEY: ${{ secrets.HEX_API_KEY }}` into the `env:` of the `test -n` step and the publish step only.

### IN-05: Some alias forms evade the Credo layer for banned modules

**File:** `credo/checks/banned_calls.ex:54-58`

**Issue:** `alias Telemetry.{Metrics}` and `alias Telemetry, as: T; T.Metrics` never produce an `__aliases__` node that renders as `Telemetry.Metrics`, so the source layer stays silent. The BEAM gate still catches the expanded atom, so this only affects defence in depth.

**Fix:** Also flag any `__aliases__` whose last segment matches the last segment of a banned module (`Metrics`, `Jason`, ...), or accept this and note in the check's explanation that the BEAM guard is authoritative.

---

_Reviewed: 2026-10-29T02:39:03Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
