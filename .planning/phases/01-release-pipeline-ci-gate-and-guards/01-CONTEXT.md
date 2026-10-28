# Phase 1: Release pipeline, CI gate and guards - Context

**Gathered:** 2026-10-28
**Status:** Ready for planning

<domain>
## Phase Boundary

A published 0.1.0 reserves the `fablebook` Hex name. From the first merge, CI enforces the guards that every later phase relies on:
- the CI shape caps;
- intent integrity;
- the prod guard;
- the eval and atom bans plus the `style=` check;
- the dependency budget;
- the tarball allowlist.

Requirements: REL-01, CI-01, INTENT-01, SEC-02, and SEC-01 in part (properties and mutation-proven tests complete it in Phase 5). The phase is provisional on Q7, Q12, Q15, Q19 and Q21.

**Out of scope:**
- the `hosts/operator` skeleton (Phase 2, see Q31);
- the Igniter installer;
- the chrome, the canvas and the runner spike;
- SEC-01's properties and mutation tests.

</domain>

<decisions>
## Implementation Decisions

**Basis.** Four parallel research passes, each with an adversarial review, produced these decisions. They are adopted under the owner's fan-out-and-auto-follow direction (INT-20261028-17). Three decisions amend an ADR or a CLAUDE.md non-negotiable: D-12, D-21 and D-31. They are marked **owner sign-off** and rated `one-way`. The planner must put a `checkpoint:decision` before the task that lands each one, so the owner signs the ADR amendment in that PR and strikes the OPEN-QUESTIONS row. Where a decision rests on a local prototype (in the session scratchpad), it says **prototyped**. That is not CI evidence.

### A. Prod guard and its CI proof (SEC-02, Q7)
- **D-01: Where the guard runs.**
  - `Fablebook.Router.fablebook/2` reads `Mix.env()` **inside the `defmacro` body**. In prod it returns *only* `quote do raise CompileError, file:, line:, description: ... end`.
  - It does not validate options, expand the Book alias or reference any Fablebook module, so a prod expansion can never depend on `storybook/`.
  - Never hoist the env read into a module attribute. Fablebook compiles as a dep in `:prod`, so every dev mount would then raise.
  - Prototyped on Elixir 1.18.4/OTP 27 and 1.20.4/OTP 29.
  - **Reversibility:** reversible.
- **D-02: The dev branch.**
  - It expands the Book with `%{__CALLER__ | function: {:fablebook, 2}}`. This is Phoenix's `expand_alias` trick, and it keeps the dependency runtime-only, so story edits don't recompile the router.
  - It emits `Phoenix.Router.get(path, Fablebook.Placeholder, book, as: :fablebook)`.
- **D-03: Credo.** `.credo.exs` exempts `lib/fablebook/router.ex` from `Credo.Check.Warning.MixEnv`. That is the only exemption.
- **D-04: The canonical message.**
  - The first line is `Fablebook cannot be mounted in a prod build`. It is a stable string that doubles as the Troubleshooting heading (DOCS-01).
  - The body names the reachable call and shows the `if Application.compile_env(:<app>, :dev_routes)` fix with the host's real app name, taken from `Mix.Project.config()[:app]`.
  - It renders the Book with `Macro.to_string/1` on the raw AST.
  - The full text is a recorded output (snapshot). A test asserts that the first line equals the guide heading.
- **D-05: The fixture.**
  - `test/fixtures/prod_guard_host/` is about 7 files. The app is `:guard_host`; the name must not contain "fablebook".
  - It shares the root `deps/` and lockfile through `deps_path`/`lockfile` pointing at `../../../`. Under `FABLEBOOK_FLOOR=1` it uses `mix.floor.lock`, so the guard runs on **both** lanes (in `core` and `floor`) and the floor lane is not `not-run`.
  - `elixirc_paths(:prod)` is `["lib"]`, plus `["unguarded"]` when `FABLEBOOK_UNGUARDED=1`. Other envs add `storybook/`.
  - The router has a `get "/"` route to a 5-line plug, plus the mount inside the false `dev_routes` `if` under `scope "/dev"`.
- **D-06: The prod-guard test.**
  - It is one `async: false` test tagged `:prod_guard`. It is excluded from bare `mix test` and included by the `mix ci` alias.
  - It drives the fixture with `System.cmd("mix", ..., cd:, env:)`, in this order:
    1. dev compile with `--warnings-as-errors` exits 0;
    2. dev `mix phx.routes GuardHostWeb.Router` contains `/dev/fablebook`;
    3. in dev, a beam whose `:beam_lib.chunks(_, [:compile_info])` source is under `/storybook/` exists;
    4. prod compile with `--warnings-as-errors` exits 0;
    5. prod `phx.routes` lists the host route and no line matches `~r/fablebook/i`;
    6. no prod beam's source is under `/storybook/` or `/design/`;
    7. a `FABLEBOOK_UNGUARDED=1` prod compile exits non-zero, and its output contains `(CompileError) unguarded/...` and the canonical first line exactly once.
  - Steps 1–3 are positive controls and required. Without them, "no routes" passes trivially.
- **D-07: What 0.1.0 contains.** Only what the gate proved: a release that is minimal but real.
  - `Fablebook` is public, with a moduledoc saying the name is reserved and the workbench is unreleased.
  - `Fablebook.Router` is public, with `fablebook/2` only and **no options**.
  - `Fablebook.Placeholder` is `@moduledoc false`. It is a plug that answers 200 text/plain.
  - `.formatter.exs` exports `locals_without_parens: [fablebook: 2, fablebook: 3]`.
  - **Reversibility:** one-way. A published Hex version and public module names are permanent, so only the ADR 0005 signature ships.

### B. Release pipeline (REL-01, ADR 0017, Q21b)
- **D-08: `hex-publish.yml` is the only publish code.**
  - It is both `workflow_call` and `workflow_dispatch` (recovery), so recovery runs on every release and stays tested.
  - `release-please.yml` calls it on `release_created`, with `tag` as an input and `HEX_API_KEY` passed by name and marked `required: true`.
  - The caller job sets no `timeout-minutes` (GitHub rejects it on reusable-workflow callers). The D-17 shape test exempts `uses:` jobs.
- **D-09: `release-please-config.json`.**
  - `release-type: elixir`, `include-v-in-tag: true`, `draft: true`, `force-tag-creation: true`, `bump-minor-pre-major: true`, `bump-patch-for-minor-pre-major: true`, `changelog-path: CHANGELOG.md`.
  - A one-time `release-as: "0.1.0"`, removed right after publish.
  - The manifest is `{".": "0.0.0"}`, and `mix.exs` has exactly one `@version`.
  - Note: the bootstrap skill's `bump-minor-pre-major: false` proposes 1.0.0 on the first `feat!:` (verified in release-please `default.ts`). Override it here and fix the skill separately.
- **D-10: Release-please token.**
  - Release-please uses a fine-grained PAT, `RELEASE_PLEASE_TOKEN` (Contents, Pull requests and Issues read/write), with **no** `|| github.token` fallback. A `GITHUB_TOKEN` PR never triggers `ci.yml`, so the release PR would never run the heavy suite or report `ci-gate`.
  - Set a reminder before the PAT expires.
  - Pin the action at `googleapis/release-please-action@45996ed1f6d02564a971a2fa1b5860e934307cf7` (v5.0.0).
- **D-11: Jobs in `hex-publish.yml`.** `concurrency: hex-publish` (no cancel), and default `permissions: contents: read`.
  - **`build`:**
    - check out the tag with `persist-credentials: false`;
    - assert the tag matches `^v\d+\.\d+\.\d+$` and equals `"v" <> @version`;
    - run `deps.get --check-locked`;
    - run `mix test --only release --only prod_guard` on the tag SHA;
    - `mix hex.build`, recording the sha256 as an output;
    - run the pre-publish smoke in path mode;
    - generate the SBOM and `gh release upload --clobber` it to the draft.
  - **`publish`:**
    - runs in `environment: hex-production`;
    - fails if the key is empty (`test -n`);
    - skips if the same version and checksum are already on Hex (idempotent recovery) and fails on a different checksum;
    - otherwise runs `mix hex.publish --yes`.
  - **`smoke`:** see D-13.
  - **`finalize`:** `gh release edit --draft=false`.
  - Pin the Hex client with `mix local.hex 2.6.0 --force`. Its reproducible builds make the checksum comparison valid.
- **D-12 (owner sign-off): SBOM.**
  - Generate it with the `erlef/mix_sbom` GitHub Action, pinned at `96bb84f8e9e72361bfad4142d666dfa2c0838ac2` (v0.12.0), **not** the `sbom` Hex dep. This changes Q21(b) and ADR 0017's literal `mix sbom.cyclonedx`.
  - Inputs: `only: prod`, `classification: library`, `include-system-dependencies: "false"`, `vulnerabilities: "false"`. The asset is `fablebook-$V.cdx.json`.
  - Why: no lockfile churn, no 4 transitive deps, and the action checks its binary's attestation.
  - **Reversibility:** reversible.
- **D-13: Smoke consumer.**
  - One script, `bin/smoke_consumer`, runs in two modes: `--path <unpacked tarball>` before publish and `--hex $V` after.
  - It generates `phx.new 1.8.16 --no-ecto --no-mailer` and inserts the mount inside `dev_routes`.
  - It asserts: dev compile with `--warnings-as-errors`, a `MIX_ENV=prod` compile, and no Fablebook routes in prod `phx.routes`.
  - The post-publish `smoke` job uses a matrix over the floor and latest lanes with fresh `MIX_HOME`/`HEX_HOME`. It polls `hex.pm/api/packages/fablebook/releases/$V` for up to 10 minutes, checks that the checksum equals `build`'s sha256, and curls hexdocs.
  - The Igniter install step is recorded as `not-run` until the installer phase.
  - On failure, the release stays a draft. Use `mix hex.publish --revert` within the hour and open or update `quality-regression`.
  - The bootstrap skill's scheduled 24-hour email smoke routine is replaced by this gate.
- **D-14: Publish credentials.**
  - Publish 0.1.0 with an `api:write` key. Trusted publishing (Hex 2.6.0 beta) cannot create a package.
  - Right after publishing, rotate to a key scoped to `fablebook`.
  - Revisit trusted publishing later.
  - The `hex-production` environment holds only `HEX_API_KEY`, with deployment branches `main` plus tags `v*`. It has no required reviewer, because merging the release PR is the approval.
- **D-15: Repository settings** (day 1, via `gh api`, recorded in the plan):
  - immutable releases on;
  - `default_workflow_permissions=read` (the skill says `write`; override it);
  - Actions policy "require full-length SHA pins" on;
  - a ruleset on `main` with a single required check, `ci-gate`, bound to the GitHub Actions app's `integration_id`. Confirm the id with `gh api`.
- **D-16: Lanes and ranges (Q12).**
  - **Requirements:** `{:phoenix, ">= 1.8.9 and < 2.0.0"}`, `{:phoenix_live_view, ">= 1.2.9 and < 2.0.0"}`, `elixir: "~> 1.18"`.
  - **Floor lane:** Elixir 1.18.5 / OTP 27.3.4.9, with `mix.floor.lock` pinning Phoenix 1.8.9 and LiveView 1.2.9, selected by `FABLEBOOK_FLOOR`.
  - **Latest lane:** `.tool-versions` `elixir 1.20.4-otp-29`, `erlang 29.1.2`.
  - setup-beam is pinned at `54075bcc5e249e4758d363f27d099f55d843f124` (v1.24.1) with `version-type: strict`.
  - The library is warning-free under `--warnings-as-errors` on both lanes.
  - The skill's `.tool-versions` (1.19.5/28.5) is overridden.
  - **Owner sign-off: this amends ADR 0007 and COMPAT-01.**
  - **Reversibility:** costly. Once 0.1.0 publishes, narrowing the range strands adopters, so land the ADR amendment before `mix.exs` merges. If the owner declines, ship ADR 0007's text unchanged and widen in 0.1.1.

### C. CI shape and intent guards (CI-01, INTENT-01, Q15)
- **D-17: The CI-shape test is `test/contract/ci_shape_test.exs`.**
  - It is a pure-function line and indent scanner over a **restricted workflow dialect**, with no YAML library.
  - **Rejected anywhere in the 3 files:**
    - tabs;
    - anchors and aliases;
    - `<<:`;
    - `workflow_call` in `ci.yml`;
    - `uses: ./.github/workflows/`;
    - lines over 120 characters.
  - **Files:**
    - `.github/workflows/**` equals exactly {`ci.yml`, `release-please.yml`, `hex-publish.yml`};
    - `.github/actions/**` equals exactly {`setup/action.yml`}, at 60 lines or fewer;
    - no JS, TS, `package.json` or scripts under `.github/`.
  - **Line cap:** `ci.yml` has 250 newlines or fewer, comments included.
  - **Jobs:**
    - every job has a literal-integer `timeout-minutes`, except `uses:` caller jobs;
    - every `uses:` is the local setup action, `owner/repo@<40-hex>( # vX)?`, or `docker://…@sha256:<64-hex>`;
    - every `image:` and `container:` is digest-pinned;
    - `paths:` and `paths-ignore:` are banned everywhere.
  - **`ci-gate`:**
    - exactly one job named `ci-gate` across the files;
    - `if: always()` and no `strategy:`;
    - its `needs` equals every `ci.yml` job except itself and the declared schedule-only jobs (set equality);
    - its step fails on any result other than `success` via `toJSON(needs)` and jq, except that `skipped` is allowed for the nightly job when the head ref is not `release-please--*`.
  - **Bypasses banned in `ci.yml`:** `continue-on-error`, `|| true`, `|| :`, `set +e`, `if: false`, `if: ${{ false }}`.
  - **`mix ci` alias:**
    - the `core` job must `run: mix ci`;
    - the alias, read as data from `Mix.Project.config()[:aliases]`, must include `test`.
  - **Node:** Node tooling (`setup-node|npm|npx|pnpm|yarn|node|bun|deno|corepack`) is banned outside a day-1 allowlist, `e2e` and `nightly`.
  - **Phase names:** `(?i)phase[-_. ]?\d+|verify\.phase` is banned in workflow files, `name:` values, job ids, mix aliases and `lib/mix/tasks`. Never ban `\bp\d+\b`, which would match p50.
  - **Fixtures:** every rule has a failing fixture.
  - **Day-1 allowlists:** all allowlists (Node jobs, schedule-only jobs) are fixed on day 1, so later phases never edit this test.
- **D-18: actionlint and zizmor** run in the `security` job as `docker://…@sha256` steps. Real YAML parsing belongs to them.
- **D-19: Intent test, `test/planning/intent_test.exs`.**
  - **Diff seam** (`test/support/git_diff.ex`): `git diff --no-renames --name-status $BASE` against the working tree. `$BASE` is:
    - `HEAD^1` on `pull_request` (assert two parents);
    - `github.event.before` on a push to `main`, passed through `env:`, never `${{ }}` inside `run:`;
    - otherwise `git merge-base origin/main HEAD`.
  - **Checkout:** the `core` job uses `fetch-depth: 0` and `filter: blob:none`.
  - **Unresolvable base:** in CI (`CI` set), `test_helper.exs` raises. Locally, the `:git_diff` tag is excluded and the reason printed (an honest not-run).
  - **Add-only rule:** under `.planning/intent/sources/`, only status `A` passes. `M`, `D` and `T` fail.
  - **Source file rules (no git needed):**
    - the filename matches `^\d{4}-\d{2}-\d{2}-\d{2}-[a-z0-9-]+\.md$`;
    - frontmatter `id` equals the `INT-YYYYMMDD-NN` derived from the filename, and `date` equals the filename date;
    - required keys: `id`, `date`, `source`, `captured_by`, `context`;
    - an optional `supersedes:` names existing, strictly earlier ids;
    - ids are unique, and `NN` is contiguous from 01 per date.
  - **Frontmatter parsing:** split on `---` plus `key: value` lines.
  - **Citations:** across `.planning/**`, `docs/**`, both CLAUDE.md files and `FABLEBOOK-SEED.md`:
    - every `\bINT-\d{8}-\d{2}\b` must exist;
    - a malformed `INT-\d` fails;
    - `ADR \d{4}` must match a `docs/adr/NNNN-*.md` file, and other ADR forms fail.
  - **REQ lines:**
    - every line matching `^- \[[ x]\] \*\*([A-Z]+-\d+)\*\*:` contains at least one valid INT or ADR token anywhere on the line;
    - a `**REQ-ID**` outside canonical form fails outside the traceability table;
    - REQ ids are unique, and each appears once in the traceability table.
  - **Step summary:** newly added INT files are listed in `$GITHUB_STEP_SUMMARY` so the owner sees them.
- **D-20: Weekly CI timing (p50/p95), as the `ci-health` job in `ci.yml`.**
  - **Trigger:** a second cron, `'23 5 * * 1'`, plus `workflow_dispatch`. The job's `if:` matches that literal cron. `ci-health` is a declared schedule-only job.
  - **Permissions:** `actions: read` and `issues: write` on this job only.
  - **Which runs count:**
    - `ci.yml` runs on `event=pull_request` from the last 7 days, attempt 1;
    - `ci-gate` concluded `success` or `failure`, with cancelled runs excluded;
    - `release-please--*` heads are excluded.
  - **Duration:** `ci-gate.completed_at - run.created_at`. Never use the `/timing` endpoint, which GitHub is closing down.
  - **Statistic:** nearest-rank percentiles. If n is below 10, publish `not-run (n=K)`.
  - **Output:** a comment on one pinned `ci-timing` issue, plus the job summary.
  - **Breach:** p50 over 7 minutes or p95 over 10 (n ≥ 10) opens or updates `quality-regression`.
  - **Ruleset drift:** the same job asserts that `gh api repos/$R/rules/branches/main` reports exactly `["ci-gate"]`. Drift opens or updates `quality-regression`.
- **D-21 (owner sign-off): The contract-test rule (Q15).**
  - A test reuses the D-19 seam. If a guard path has status `M` or `D`, the paired paths must not change in the same PR:

    | Guard path changed (`M`/`D`) | Must not also change |
    |---|---|
    | `test/contract/**` | `lib/**` and `.github/**` |
    | `test/planning/**` | `.planning/intent/**` and `.planning/REQUIREMENTS.md` |

  - `A` is allowed. Test-first work is normal, and this also lets Phase 1's own PR add the guards together with `.github/`.
  - Recorded outputs (goldens, snapshots) are not enforced in Phase 1. When they are, use a `Recorded-Output-Change:` commit trailer, never a hand edit to `CHANGELOG.md` (release-please owns that file).
  - This amends a CLAUDE.md non-negotiable's definition and extends Q15, so it needs owner sign-off.
  - **Reversibility:** reversible.
- **D-22: Real-CI evidence.** Fixtures alone don't prove the wiring. The phase links one red run from a throwaway draft PR that edits an INT source, closed unmerged, and one green run of the merged phase PR.

### D. Code bans and dependency budget (SEC-01 partial, ADR 0004, ADR 0018, Q19)
- **D-23: Two ban layers. The compiled-BEAM guard is the gate.**
  - **Compiled-BEAM guard:** `test/contract/banned_calls_test.exs` plus a `test/support` walker of about 60 lines.
    - **Scope:** it scans every module in `Application.spec(:fablebook, :modules)` whose compile source is under `lib/`.
    - **Missing debug info:** a missing `debug_info` chunk fails the test (fail closed).
    - **Atom tier:** any occurrence in the abstract code fails. The names are:
      - `eval_string`, `eval_quoted`, `eval_quoted_with_env`, `eval_file`;
      - `string_to_quoted`, `string_to_quoted!` and the `_with_comments` variants;
      - `compile_string`, `compile_quoted`, `compile_file`, `require_file`;
      - `binary_to_atom`, `list_to_atom`, `binary_to_existing_atom`, `list_to_existing_atom`, `binary_to_term`;
      - `:erl_eval`, `:erl_scan`, `:erl_parse`;
      - for "no banned dep referenced from lib/": `Jason`, `Floki`, `MDEx`, `YamlElixir`, `:yamerl`, `Telemetry.Metrics`.
    - **MFA tier** (the imports chunk):
      - `Module.concat/1,2`, `Module.safe_concat/1,2`, `Module.create/3`;
      - all of `EEx.*`;
      - `Phoenix.LiveView.TagEngine.compile/2`;
      - `:compile.forms/*` and `:compile.file/*`;
      - `:code.load_binary/3`.
    - Do **not** ban the TagEngine module. Compiled `~H` imports `TagEngine.component/3` at runtime.
    - The allowlist is empty, kept as data in the contract test.
    - It runs on both lanes. It was prototyped on 1.18 and 1.19, so re-verify it on 1.20 and LiveView 1.2 in this phase.
  - **Credo:** the source layer keeps ADR 0004's "Credo bans" literally true and catches env-branch code.
    - Enable `Warning.UnsafeToAtom`, which is off by default.
    - Configure `Warning.ForbiddenModule` with `[EEx, Jason, Floki, MDEx, YamlElixir, Telemetry.Metrics]`.
    - Add one custom check, `credo/checks/banned_calls.ex`, outside `lib/` so it never ships. It flags any call or atom literal named in the atom tier, whatever the module, and is loaded through `.credo.exs` `requires:`.
    - The guard test fails on any `credo:disable` comment in `lib/` that names these checks.
    - `mix.exs` ships to adopters, so it is also text-scanned with the same ban set.
- **D-24: Negative fixtures.** They live under `test/fixtures/guards/`, outside `elixirc_paths`, one per bypass form:
  - an alias;
  - an import;
  - `apply` with literal args;
  - a capture;
  - a macro `quote` body;
  - an interpolated atom;
  - a dynamic module;
  - a banned dep reference.

  Each is compiled into a `tmp_dir` and must make the guard fail.
- **D-25: The `style=` check is a source-text scan.**
  - **`lib/**/*.{ex,heex}`:** `\bstyle\s*=`, `\bstyle:`, `["']style["']`, `:style\b`, `<style\b`.
  - **Fablebook-authored `assets/js/**`:** `setAttribute\(\s*["']style`, `style\s*=\s*["'\x60]`, `cssText`.
  - **Not scanned:** generated `priv/static` bundles (the drift check ties them to their sources) and vendored files, which are excluded by exact path.
  - CSSOM writes are not banned.
  - The runtime backstop is the canvas phase's CSP `securitypolicyviolation` receipt.
- **D-26 (owner sign-off, Q19 refinement): Dependency budget test, `test/contract/dependency_budget_test.exs`.**
  - **Deps in `mix.exs`:**
    - required deps (no `only:`, or `only` includes `:prod`, and not optional) must equal exactly {phoenix, phoenix_live_view, phoenix_html, telemetry, nimble_options};
    - optional deps must be a subset of {igniter, earmark, phoenix_test_playwright} and carry no `only:`;
    - every other dep must have an `only:` that excludes `:prod`.
  - **Prod closure:** a breadth-first walk of `hex_metadata.config` `requirements` with `optional == false`, starting from the required apps. It must not intersect {jason, mdex, floki, telemetry_metrics} or `~r/ya?ml|yamerl/`.
  - **Direct deps:** no banned name as a direct dep in any env.
  - It runs on both lanes.
  - **Why not `mix deps.tree --only prod`:** it is rejected because it false-fails. In the library repo it includes optional deps' subtrees (verified).
  - **ADR 0018 consequence:** tailwind, esbuild, credo and dialyxir are declared `only: :dev, runtime: false`. Without `only:`, `hex.build` publishes a `runtime: false` dep as a required adopter dep (verified).
- **D-27 (owner sign-off, Q19): Audit.**
  - Drop `mix_audit`, and drop `deps.audit` from ADR 0017's `security` job.
  - Use `mix hex.audit` alone, after asserting Hex ≥ 2.5.1. It fails on retired packages and on advisories (verified on 2.6.0), and fails closed on lookup errors.
  - Exceptions go in `hex: [ignore_advisories: [...]]` in `mix.exs`. Never set `HEX_OFFLINE` in CI.
  - OSV-Scanner is not added. Hex ingests OSV, so it would add nothing for Hex.
  - `dependency-review` covers Actions only. Never claim Hex coverage from it.
- **D-28: Tarball allowlist.**
  - **`package files:`** is explicit: `lib mix.exs .formatter.exs README.md LICENSE CHANGELOG.md`, plus `usage-rules.md`. It never lists `priv` wholesale; exact `priv/static` paths arrive with the chrome.
  - **Test:** `test/contract/tarball_test.exs`, tagged `:release`, runs in `core` on every PR and again in `build` on the tag. It runs `System.cmd("mix", ["hex.build", "--unpack", "--output", tmp], env: [{"MIX_ENV", "dev"}])` and asserts:
    - the exact file set, with `hex_metadata.config` checked against the allowlist globs, plus a deny list (`storybook/ design/ hosts/ test/ bench/ docs/ .planning/ *.beam *.tar .DS_Store .env*`);
    - `LICENSE` is present;
    - `hex_metadata.config`, read with `:file.consult/1`:
      - name and app are `fablebook`;
      - the version matches;
      - `licenses == ["MIT"]`;
      - the required and optional requirements match D-26;
      - no banned name appears;
    - a PII scan finds no `/Users/`, `/home/` or email patterns.
  - **`usage-rules.md`** ships per Q21(c): a short stub now.

### E. Delivery shape (ADR 0021)
- **D-29: Push on day 1.** The first PR lands the `mix.exs` skeleton, `ci.yml` with `ci-gate`, and the guard tests together. That is allowed because new contract tests are status `A`.
  - Phase 1 ends in a merged green PR and a published 0.1.0.
  - Evidence: the CI run links, the hex.pm page, and the release with its SBOM asset.
- **D-30: CI job set** from ADR 0017, adjusted:
  - `core` runs `mix ci`, which includes the prod-guard, tarball, intent, shape and ban tests;
  - `floor` runs the `FABLEBOOK_FLOOR=1` lane, the prod guard and `--no-optional-deps`;
  - `dialyzer` uses its own correct PLT key;
  - `security` runs `hex.audit`, `dependency-review`, actionlint and zizmor;
  - `ci-gate`;
  - `nightly` and `ci-health` are schedule-only.
  - The `e2e` job does not exist yet. Adding it later only changes `needs` in `ci.yml`, plus the day-1 Node allowlist already naming it.
  - **Composite action:** `.github/actions/setup` restores and saves the cache separately, keyed on os, arch, OTP, Elixir and `hash(mix.lock)` (or the floor lock). Saves happen only on `main`.
- **D-31 (owner sign-off): Log the new conflicts.** These conflicts are new, so they are added to OPEN-QUESTIONS as Q31–Q34, not resolved here:
  - **Q31:** ADR 0020 puts the operator skeleton in Phase 1; the roadmap puts it in Phase 2.
  - **Q32:** custom non-prod envs, such as `staging` with `dev_routes`.
  - **Q33:** the ADR 0017 release-flow amendments (D-08 to D-15).
  - **Q34:** the Q19 and Q21(b) refinements (D-12, D-26, D-27).

### Claude's Discretion
- Splitting the work into at most 5 plans and their order. Suggested:
  1. `mix.exs`, the router and the prod-guard fixture;
  2. the guard tests (shape, intent, contract rule, bans, dependency budget, tarball, style);
  3. `ci.yml`, the composite action, security, `ci-health` and repository settings;
  4. the release pipeline and the 0.1.0 publish.
- The exact wording of the placeholder response and the moduledocs, within the house voice.
- Naming of the `test/support` helpers.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Intent and rules
- `.planning/intent/NORTH-STAR.md`: non-negotiables 1, 6 and 7.
- `.planning/intent/CLEARANCE.md`: what 1.0 must clear.
- `.planning/intent/OPEN-QUESTIONS.md`: Q7, Q12, Q15, Q19 and Q21 (this phase is provisional on them), plus Q31–Q34 added by this discussion.
- `.planning/intent/README.md`: intent-folder rules that the intent test enforces.
- `.planning/intent/sources/2026-10-28-17-fan-out-and-auto-follow.md`: the basis for adopting these decisions.
- `CLAUDE.md` and `.claude/CLAUDE.md`: non-negotiables and the stack findings F1–F12.

### ADRs
- `docs/adr/0004-no-eval-no-new-atoms.md`: the ban list (D-23 to D-25).
- `docs/adr/0005-livedashboard-style-packaging.md`: the router signature.
- `docs/adr/0006-dependency-available-in-all-envs.md`: the prod guard and the CI route check (D-01 to D-07).
- `docs/adr/0007-version-floors.md`: floors and lanes (D-16 amends it).
- `docs/adr/0010-llm-context-bundle.md`: the honesty rule (`not-run`, never `pass`).
- `docs/adr/0014-testing-strategy.md`: the T5 clean-room tarball consumer.
- `docs/adr/0017-ci-cd-layout.md`: the workflows, jobs and release pipeline (D-08 to D-15, D-27 and D-30 amend it).
- `docs/adr/0018-dependency-budget.md`: the dependency budget (D-12, D-26 and D-27 refine it).
- `docs/adr/0019-dx-install-upgrade.md`: breaking changes go in 0.x minors (the reason for D-09).
- `docs/adr/0020-host-apps-dogfood.md`: the operator skeleton timing (Q31).
- `docs/adr/0021-delivery-rules.md`: phase size, push on day 1, contract tests.

### Requirements and research
- `.planning/REQUIREMENTS.md`: REL-01, CI-01, INTENT-01, SEC-01, SEC-02, COMPAT-01, TEL-03 and DOCS-01.
- `.planning/ROADMAP.md`: Phase 1 success criteria 1–4.
- `.planning/research/PITFALLS.md`: E1, Pitfall 1 and Pitfall 26.
- `docs/research/STACK-FACTS.md` and `docs/research/LESSONS-LEARNED.md`.
- `~/.claude/skills/bootstrap-elixir-hex-lib/SKILL.md`: the canonical pipeline. D-09, D-10, D-13, D-15 and D-16 override it.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None in this repo. It is docs-only: no `mix.exs`, `lib/` or `.github/`.
- Prototype code is in the session scratchpad. It is reference only and not committed:
  - `exp/lib2` and `host2`: the router macro and Phoenix fixture;
  - `proto/scan2.exs`: the abstract-code walker;
  - `proto/evil.ex`: the bypass fixtures.

### Established Patterns
- **Intent sources** use `---` frontmatter with `id`, `date`, `source`, `captured_by` and `context`. All 17 sources pass the D-19 rules today, and none uses `supersedes:` yet.
- **REQ lines** use `- [ ] **ID**: ... (ADR NNNN, INT-...)`. All 129 cite at least one INT or ADR, but 6 have no trailing parenthesis, so the test reads the whole line.
- **Placeholders** such as `INT-YYYYMMDD-NN` and `INT-…` appear in docs and must stay legal. They don't start with a digit, so they pass.

### Integration Points
- `.github/` (3 workflows and 1 composite action), `mix.exs` aliases (`ci`), `.credo.exs`, `test/contract/`, `test/planning/`, `test/fixtures/` and `test/support/`.
- GitHub repository settings and the ruleset (D-15) are configured outside the repo and checked by `ci-health`.

</code_context>

<specifics>
## Specific Ideas

- The CompileError's first line is a documentation anchor. Never rename it silently.
- A `MIX_ENV=dev` deploy cannot be caught at compile time, the same as with LiveDashboard. Say so in the Security guide.
- Adding a merge queue later needs a `merge_group` trigger, or `ci-gate` stays pending.
- Scheduled workflows are disabled after 60 inactive days on public repos.
- Hex 2.6.0 is days old and pinned deliberately. If its reproducible builds misbehave, compare a `hex.package fetch --unpack` tree instead.

</specifics>

<deferred>
## Deferred Ideas

- **Trusted publishing (Hex OIDC):** once it leaves beta and a package exists. Later release-hardening work.
- **Runtime call trace of banned functions during the suite** (`:erlang.trace_pattern` with a caller check): Phase 5, with the never-eval and atom-count properties.
- **Enforcing recorded-output changes** with the `Recorded-Output-Change:` trailer: when goldens first land.
- **A doctor warning when `dev_routes` is set outside `dev.exs`:** Phase 10 (installer), pending Q32.
- **The operator host's nested-mount prod-build case:** when `hosts/operator` lands (Q31).
- **Fixing `bump-minor-pre-major` and its comment in the bootstrap skill:** outside this repo.

</deferred>

---

*Phase: 01-release-pipeline-ci-gate-and-guards*
*Context gathered: 2026-10-28*
