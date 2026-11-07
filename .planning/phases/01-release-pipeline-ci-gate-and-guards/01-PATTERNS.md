# Phase 1: Release pipeline, CI gate and guards - Pattern Map

**Mapped:** 2026-11-05
**Files analyzed:** 55 file paths/path groups (two fixture families are globs)
**Analogs found:** 32 / 35 path groups (55 listed target paths, including fixture globs)

The 2026-10-28 research describes a docs-only repository. The current checkout now contains tracked implementations for most Phase 1 targets. The table treats those as targets and names distinct neighboring files as analogs where possible; it does not count a file as its own analog. Analog paths below were verified with git ls-files -- <path> and are tracked sources.

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| .tool-versions, mix.lock, mix.floor.lock, .release-please-manifest.json | config | configuration / generated data | mix.exs | partial |
| mix.exs | config | build configuration | .credo.exs | role-match |
| .formatter.exs | config | build configuration | .credo.exs | role-match |
| .credo.exs | config | lint configuration | .formatter.exs | role-match |
| release-please-config.json | config | release configuration | .github/workflows/release-please.yml | partial |
| lib/fablebook.ex | utility / public module | request-response boundary | lib/fablebook/placeholder.ex | role-match |
| lib/fablebook/router.ex | route / macro | request-response (compile-time expansion) | no separate router macro | none |
| lib/fablebook/placeholder.ex | component / Plug | request-response | no separate Plug module | none |
| bin/floor_lock | utility / CLI | file-I/O, batch | bin/smoke_consumer | role-match |
| bin/smoke_consumer | utility / CLI | batch, file-I/O, HTTP | bin/ci_health | role-match |
| bin/ci_health | utility / CLI | batch, GitHub API request-response | bin/smoke_consumer | role-match |
| test/test_helper.exs | test config | test bootstrap / environment setup | test/support/mix_cmd.ex | partial |
| test/fixtures/prod_guard_host/mix.exs, config/config.exs | config / test fixture | build configuration | root mix.exs | role-match |
| test/fixtures/prod_guard_host/{lib/guard_host_web/router.ex, lib/guard_host/ok.ex, storybook/book.ex, unguarded/router.ex} | route / component / test fixture | request-response, compile-time guard | lib/fablebook/router.ex | partial |
| test/support/mix_cmd.ex | test utility | request-response to subprocess | test/support/git_diff.ex | role-match |
| test/contract/prod_guard_test.exs, prod_guard_message_test.exs | test | file-I/O, nested Mix process | test/contract/tarball_test.exs | role-match |
| test/snapshots/prod_guard_message.txt | test fixture / recorded output | file-I/O | no separate snapshot analog | none |
| LICENSE, README.md, CHANGELOG.md, usage-rules.md | documentation | static content | docs/adr/0006-dependency-available-in-all-envs.md | partial |
| test/support/git_diff.ex | test utility | transform / subprocess | test/support/mix_cmd.ex | role-match |
| test/planning/intent_test.exs | test | file-I/O, batch validation, git diff | test/planning/contract_rule_test.exs | role-match |
| test/planning/contract_rule_test.exs | test | git diff / transform | test/support/git_diff.ex | exact role and flow |
| test/contract/ci_shape_test.exs, test/fixtures/ci_shape/*.yml | test / test fixture | file-I/O, transform | test/contract/ci_health_test.exs | role-match |
| test/support/beam_walker.ex, test/contract/banned_calls_test.exs, test/fixtures/guards/*.ex | test utility / test / fixture | transform, compile and inspect BEAM | credo/checks/banned_calls.ex | partial |
| credo/checks/banned_calls.ex | utility / Credo check | source transform / static analysis | .credo.exs | partial |
| test/contract/style_attr_test.exs | test | file-I/O, text transform | test/contract/dependency_budget_test.exs | role-match |
| test/contract/dependency_budget_test.exs | test | batch transform / metadata file-I/O | test/contract/tarball_test.exs | role-match |
| test/contract/tarball_test.exs | test | file-I/O, subprocess | test/contract/prod_guard_test.exs | exact role and flow |
| .github/actions/setup/action.yml | config / composite action | event-driven CI setup | .github/workflows/ci.yml | partial |
| .github/workflows/ci.yml | workflow | event-driven CI | .github/workflows/release-please.yml | role-match |
| .github/workflows/release-please.yml, .github/workflows/hex-publish.yml | workflow | event-driven release / request-response to Hex | each other | role-match |
| .github/zizmor.yml | config | lint configuration | .credo.exs | partial |
| test/contract/ci_health_test.exs | test | file-I/O, fake GitHub CLI, batch assertions | test/contract/hex_publish_test.exs | role-match |
| test/contract/hex_publish_test.exs | test | file-I/O, fake CLI, workflow contract | test/contract/ci_health_test.exs | exact role and flow |
| docs/adr/{0004-no-eval-no-new-atoms.md, 0007-version-floors.md, 0017-ci-cd-layout.md, 0018-dependency-budget.md} | documentation / decision record | static content | docs/adr/0006-dependency-available-in-all-envs.md | exact role |
| .planning/intent/OPEN-QUESTIONS.md, .planning/intent/sources/*.md, .planning/REQUIREMENTS.md | documentation / intent record | file-I/O, traceability | .planning/intent/sources/2026-10-28-18-release-and-guard-sign-offs.md | exact role |

Repository settings and the branch ruleset are configured through GitHub APIs and have no repository file to classify.

## Pattern Assignments

### lib/fablebook/router.ex and lib/fablebook/placeholder.ex (route / component, request-response)

**Analog:** none; this is the first product router macro and Plug in the library.

The router macro is a one-off compile-time boundary, so there is no distinct router macro to copy. Keep the prod check inside the macro body, return a CompileError in the generated code, and leave the dev expansion small. The placeholder uses the project Plug behavior and connection pipeline:

    defmacro fablebook(path, book) do
      if Mix.env() == :prod do
        description = prod_description(path, book, Mix.Project.config()[:app])

        quote do
          raise CompileError,
            file: unquote(__CALLER__.file),
            line: unquote(__CALLER__.line),
            description: unquote(description)
        end
      else
        book = Macro.expand(book, %{__CALLER__ | function: {:fablebook, 2}})

        quote do
          require Phoenix.Router
          Phoenix.Router.get(unquote(path), Fablebook.Placeholder, unquote(book), as: :fablebook)
        end
      end
    end

Source: lib/fablebook/router.ex, lines 24-41.

The error-message code in lib/fablebook/router.ex, lines 44-61 makes the canonical first line a literal, renders raw AST with Macro.to_string/1, and includes the host app name in the suggested Application.compile_env/2 guard. lib/fablebook/placeholder.ex, lines 3-15 shows @behaviour Plug, import Plug.Conn, @impl Plug, and piped put_resp_content_type / send_resp. There is no auth or input validation in this public placeholder route.

### test/support/mix_cmd.ex, prod-guard tests and the nested host fixture (test utility / integration test)

**Analogs:** test/support/mix_cmd.ex, test/contract/prod_guard_test.exs, and test/contract/tarball_test.exs are tracked current patterns. The helper isolates nested Mix invocations by scrubbing inherited Mix variables, setting MIX_ENV, and merging explicit fixture env:

    @scrubbed ~w(MIX_EXS MIX_LOCKFILE MIX_BUILD_PATH MIX_BUILD_ROOT MIX_TARGET FABLEBOOK_UNGUARDED)

    def run(dir, mix_env, args, extra_env \\ []) do
      scrub = Enum.map(@scrubbed, &{&1, nil})

      System.cmd("mix", args,
        cd: dir,
        env: scrub ++ [{"MIX_ENV", mix_env} | extra_env],
        stderr_to_stdout: true
      )
    end

Source: test/support/mix_cmd.ex, lines 4-14.

test/contract/prod_guard_test.exs, lines 1-35 provides the integration-test shape: async: false, a named ExUnit tag, explicit long timeout, positive controls before the negative compile, and output assertions that explain failure. Keep fixture code outside release elixirc_paths and use the helper rather than duplicating command/env handling.

### test/support/git_diff.ex and planning tests (test utility / batch validation)

**Analog:** test/planning/contract_rule_test.exs, lines 1-61.

The diff seam returns tagged {:ok, value} / {:error, reason} results, scrubs Git environment variables, parses --name-status -z without relying on whitespace splitting, and makes Git failures visible. The planning tests use pure violation functions for most cases and small temporary Git repos only for seam behavior:

    def changes(base, dir \\ File.cwd!()) do
      case git(dir, ["diff", "--no-renames", "--name-status", "-z", base]) do
        {:ok, out} -> parse_name_status(out)
        {:error, reason} -> raise reason
      end
    end

    defp parse_name_status(out) do
      out
      |> String.split("\0", trim: true)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [status, path] -> {status, path} end)
    end

Source: test/support/git_diff.ex, lines 14-26.

test/planning/contract_rule_test.exs, lines 1-47 is the test convention to reuse: use ExUnit.Case, async: true, alias the helper, keep path-pair rules as data, and include cases for failing M/D changes and allowed A changes.

### Contract tests and fixtures (test, file-I/O / transform)

**Analogs:** test/contract/tarball_test.exs, lines 1-49; test/contract/ci_health_test.exs, lines 41-58; and test/contract/hex_publish_test.exs, lines 1-43.

Use ExUnit to exercise pure checker functions with synthetic inputs, then keep one integration assertion for the real built artifact or script. For external commands, put a controlled fake executable at the front of PATH, write JSON/text fixtures under tmp_dir, record calls, and assert both output and side effects. For System.cmd("mix", ...) contract checks, use Fablebook.Test.MixCmd. tarball_test.exs demonstrates exact file-set checks, :file.consult/1 metadata reads, and PII scanning; ci_health_test.exs demonstrates a fake gh shim and captured summary output.

Fixture conventions: keep compile probes under test/fixtures/ (excluded by mix.exs test_ignore_filters), and use source files as data rather than compiling fixtures into the application. The prod_guard_host paths are synthetic. Keep the ci_shape and guard fixtures one-per-rule so each scanner rejection has an isolated failing example.

No distinct analog: test/support/beam_walker.ex is a specialized BEAM abstract-code/import walker, and the compiled-BEAM guard is unique in this codebase. Its role pairs naturally with credo/checks/banned_calls.ex, but the two scanners operate on different representations; do not merge their logic.

### CLI utilities (bin/floor_lock, bin/smoke_consumer, bin/ci_health)

**Analogs:** bin/smoke_consumer and bin/ci_health are tracked shell-script patterns.

Use #!/usr/bin/env bash and set -euo pipefail; validate arguments before side effects; create a private temporary directory and trap its cleanup; pass externally derived values through named variables/environment; fail with a concrete message. bin/smoke_consumer, lines 36-58 shows cleanup and isolated Mix/Hex homes. bin/floor_lock, lines 7-19 shows a temporary generated Mix project, exact version assertions before running Mix, and a final --check-locked. bin/ci_health, lines 29-42 shows the GitHub issue write wrapper and its --dry-run branch; lines 58-99 show filtering, nearest-rank calculation, step-summary output, and ruleset drift check. Keep shell workflow bodies short by delegating CI health logic to bin/ci_health.

### Workflows and action (.github/workflows/*.yml, .github/actions/setup/action.yml)

**Analogs:** .github/workflows/release-please.yml, .github/workflows/hex-publish.yml, .github/workflows/ci.yml, and .github/actions/setup/action.yml are tracked current patterns.

Pin every external action by full SHA with a version comment, set least-privilege permissions at workflow/job scope, set a literal job timeout, and use persist-credentials: false on checkout. The reusable publish workflow receives a required tag and named required secret; its caller keeps uses: at the job level:

    publish:
      needs: release-please
      if: needs.release-please.outputs.release_created == 'true'
      permissions:
        contents: write
        issues: write
      uses: ./.github/workflows/hex-publish.yml
      with:
        tag: value from release-please output
      secrets:
        HEX_API_KEY: named repository secret

Source: .github/workflows/release-please.yml, lines 29-39. .github/workflows/hex-publish.yml, lines 29-45 shows tag checkout, job permissions, SHA outputs, and credentials disabled. .github/actions/setup/action.yml, lines 16-57 shows strict floor/latest toolchain setup and separate cache restore/save; saves are limited to main. .github/workflows/ci.yml, lines 22-55 shows job-level timeouts, full-history checkout for the diff seam, and mix ci in the core job. There is no separate composite-action analog or second CI workflow to copy; keep the single composite action below its 60-line cap.

### Configuration and project docs

**Analogs:** .formatter.exs, .credo.exs, mix.exs, and docs/adr/0006-dependency-available-in-all-envs.md.

Keep Mix configuration as plain project data and small private functions. .formatter.exs, lines 1-6 demonstrates exported local syntax; .credo.exs, lines 1-25 demonstrates strict checks, explicit included/excluded paths, requires, and the one exact MixEnv exemption. mix.exs, lines 7-27 and 34-72 groups project data, environment-aware lockfile selection, aliases, and the explicit tarball allowlist. ADRs keep their decision in short declarative bullets and cite intent IDs; .planning/intent/sources/2026-10-28-18-release-and-guard-sign-offs.md, lines 1-7 is the frontmatter pattern for owner decisions.

No distinct analog: the root README, changelog, usage-rules stub, and the first Fablebook public module are product surfaces without an established earlier copy pattern. Keep them aligned with the release allowlist and ADR decisions.

## Shared Patterns

### Test process boundaries

**Source:** test/support/mix_cmd.ex, lines 4-14.
**Apply to:** nested Mix integration tests and fixture hosts.

Scrub inherited Mix path/build controls, set MIX_ENV explicitly, capture stderr with stdout, and surface command output on assertion failure.

### Git diff behavior

**Source:** test/support/git_diff.ex, lines 4-18 and 28-60.
**Apply to:** intent and contract-change rules.

Use the explicit event base, reject invalid or unresolved bases, parse NUL-delimited name-status output, and do not hide Git errors.

### Contract-test structure

**Source:** test/contract/tarball_test.exs, lines 1-49 and test/contract/ci_health_test.exs, lines 41-58.
**Apply to:** all test/contract/ and test/planning/ guard tests.

Prefer async pure tests, add tags only where mix ci needs explicit inclusion, use generated tmp_dir fixtures for integrations, and assert negative cases separately from the real-system positive control.

### Release and workflow secrets

**Source:** .github/workflows/release-please.yml, lines 7-12 and 29-39; .github/workflows/hex-publish.yml, lines 96-123.
**Apply to:** publish workflows.

Pass secrets by explicit name, expose them only to the step that consumes them, use the hex-production environment for publication, and make existing-version recovery compare checksums before skipping or publishing docs.

## No Analog Found

| File / group | Role | Data Flow | Reason |
|---|---|---|---|
| lib/fablebook/router.ex, lib/fablebook/placeholder.ex | route / Plug | compile-time guard, request-response | First product router macro and Plug in this library; the prod-guard decisions are specific to Fablebook. |
| test/support/beam_walker.ex, test/contract/banned_calls_test.exs | test utility / test | compile and BEAM transform | No other compiled-code security scanner exists; use the corresponding Credo scanner only for its AST-facing concerns. |
| test/snapshots/prod_guard_message.txt | test fixture | file-I/O | No earlier snapshot file establishes a convention. |
| .github/actions/setup/action.yml | config | event-driven setup | There is one composite action and no distinct composite-action analog. |
| .github/zizmor.yml | config | lint | The zizmor policy has one instance; .credo.exs is only a partial config analog. |
| mix.lock, mix.floor.lock | generated config | generated data | Lockfiles are generated artifacts; regenerate by the pinned Mix workflow rather than hand-copying entries. |
| README.md, CHANGELOG.md, usage-rules.md | documentation | static content | These are first-release public documents; follow the locked copy and packaging choices in CONTEXT/RESEARCH. |

## Metadata

**Analog search scope:** tracked root files, lib/, bin/, credo/, .github/, test/, docs/adr/, and .planning/intent/.
**Files scanned:** 25 role-relevant implementation/test and planning files inspected for patterns; candidate analog paths were confirmed tracked before inclusion.
**Pattern extraction date:** 2026-11-05
