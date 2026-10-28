# Phase 1: Release pipeline, CI gate and guards - Research

**Researched:** 2026-10-28
**Domain:** Elixir Hex library bootstrap, GitHub Actions CI shape, release-please and Hex publishing, compile-time guards
**Confidence:** HIGH for versions, SHAs, digests and the local prototypes; MEDIUM for GitHub-side behaviour that only a real CI run can prove (marked)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

(Copied verbatim from `01-CONTEXT.md` `## Implementation Decisions`.)

**Basis.** Four parallel research passes, each with an adversarial review, produced these decisions. They are adopted under the owner's fan-out-and-auto-follow direction (INT-20261028-17). Three decisions amend an ADR or a CLAUDE.md non-negotiable: D-12, D-21 and D-31. They are marked **owner sign-off** and rated `one-way`. The planner must put a `checkpoint:decision` before the task that lands each one, so the owner signs the ADR amendment in that PR and strikes the OPEN-QUESTIONS row. Where a decision rests on a local prototype (in the session scratchpad), it says **prototyped**. That is not CI evidence.

#### A. Prod guard and its CI proof (SEC-02, Q7)
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

#### B. Release pipeline (REL-01, ADR 0017, Q21b)
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

#### C. CI shape and intent guards (CI-01, INTENT-01, Q15)
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

#### D. Code bans and dependency budget (SEC-01 partial, ADR 0004, ADR 0018, Q19)
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

#### E. Delivery shape (ADR 0021)
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

### Deferred Ideas (OUT OF SCOPE)
- **Trusted publishing (Hex OIDC):** once it leaves beta and a package exists. Later release-hardening work.
- **Runtime call trace of banned functions during the suite** (`:erlang.trace_pattern` with a caller check): Phase 5, with the never-eval and atom-count properties.
- **Enforcing recorded-output changes** with the `Recorded-Output-Change:` trailer: when goldens first land.
- **A doctor warning when `dev_routes` is set outside `dev.exs`:** Phase 10 (installer), pending Q32.
- **The operator host's nested-mount prod-build case:** when `hosts/operator` lands (Q31).
- **Fixing `bump-minor-pre-major` and its comment in the bootstrap skill:** outside this repo.
</user_constraints>

<phase_requirements>
## Phase Requirements

Requirement text quoted verbatim from `.planning/REQUIREMENTS.md` [VERIFIED: .planning/REQUIREMENTS.md:161-162, 220, 222, 227].

| ID | Description | Research Support |
|----|-------------|------------------|
| REL-01 | "release-please publishes to Hex via the bootstrap skill. Phase 1 publishes 0.1.0 to reserve the name. Includes a post-publish smoke test, a recovery workflow and an SBOM. (ADR 0017, INT-20261028-01)" | Release flow diagram; `release-please.yml` and `hex-publish.yml` skeletons (actionlint and zizmor clean locally); release-please config verified against oarlock's live tags (`v0.1.0`, branch `release-please--branches--main`); Hex API `checksum` equals the tarball sha256 (verified); `erlef/mix_sbom` inputs read from the pinned `action.yml`; human-action ordering table. |
| CI-01 | "Exactly three workflows; `ci.yml` stays ≤250 lines with one required `ci-gate` check. A test enforces these caps. PR p50 ≤ 7 min, measured from CI history. (ADR 0017, INT-20261028-02)" | `ci.yml` skeleton at 151 lines; setup action at 57 lines; ci-gate jq truth table tested; resolved SHAs and digests; zizmor/actionlint conflict and fix; `ci-health` recipe; ruleset JSON with `integration_id` 15368 (verified). |
| INTENT-01 | "`.planning/intent/` stays authoritative. `test/planning/intent_test.exs` enforces that sources are add-only, that INT ids are valid in full form, and that every REQ line cites at least one INT or ADR. (ADR 0021, INT-20261028-04)" | D-19 rules prototyped against the current corpus: all 17 sources and 129 REQ lines pass, the traceability table holds 129 unique ids, and 8 plural or hyphenated ADR citations would fail the "other ADR forms" rule (Pitfall 9). `.claude/CLAUDE.md` is gitignored (Pitfall 10). |
| SEC-02 | "In prod the router macro raises a `CompileError`, with no override in 1.0. Stories and canon never compile in prod. The CI prod build asserts there are no Fablebook routes and no story beams. (ADR 0006)" | Fixture layout re-proven from inside ExUnit on 1.20.4/OTP 29.1.1 (latest lock) and 1.18.4/OTP 27.3.4.15 (Phoenix 1.8.9 / LiveView 1.2.9 floor lock), about 8 s per lane locally; nested-mix env scrubbing; `build_path` keeps fixture builds under the ignored root `_build/`. |
| SEC-01 (partial) | "No `Code.eval*`, no runtime EEx/HEEx compilation, and no `String.to_atom` on input. Credo bans these, and properties plus mutation-proven tests confirm it. (ADR 0004, INT-20261028-01)" | BEAM walker re-verified on 1.20.4 with LiveView 1.2.13 `~H`: no atom hits, and the TagEngine imports are `component/3` and `__assigns__/3`. Bypass fixtures still trip. Credo 1.7.19 config keys verified in source; `MixEnv.excluded_paths` matches directories only (Pitfall 6). |
</phase_requirements>

## Project Constraints (from CLAUDE.md)

Directives from `./CLAUDE.md` and `./.claude/CLAUDE.md`. They carry the authority of locked decisions:

- **Reading order and vocabulary.** Read NORTH-STAR, CLEARANCE, GLOSSARY and the ADR README first. Never call a scenario a "variant" or "variation", and never call the canvas a "sandbox".
- **Precedence.** Verbatim intent > ADR > REQUIREMENTS > PROJECT. A plan that conflicts with intent goes to `OPEN-QUESTIONS.md`.
- **Recording intent.** New owner direction (including each owner sign-off in this phase) becomes an add-only `.planning/intent/sources/` entry with `id`, `date`, `source`, `captured_by` and `context`.
- **Quality gates.**
  - Never lower a quality gate; split the phase instead.
  - Never edit a contract test in the same PR as the implementation it guards.
  - Never auto-accept a visual baseline.
- **Code bans.** No runtime eval and no atoms from input (ADR 0004).
- **Dependencies.**
  - Copy-paste beats a new dependency, and a new dependency needs an ADR.
  - Runtime deps are exactly phoenix, phoenix_live_view, phoenix_html, telemetry and nimble_options.
  - Banned: jason, mdex, floki, any YAML library, `telemetry_metrics`.
  - Adopters never need Node.
- **Process.**
  - Push early. Every phase ends in a merged green PR.
  - Evidence is a CI run link, not prose.
  - ≤5 plans per phase, about ≤3 days each.
  - Review loops are capped at 2.
- **Privacy.** No PII in git: no email addresses and no absolute home paths (write `~/`). Fixtures are synthetic.
- **Code style.**
  - Idiomatic, minimal and self-documenting.
  - No comments that restate the code.
  - Internal modules get `@moduledoc false`.
  - ≤25 public modules at 1.0.
- **CI.**
  - Exactly 3 workflows, `ci.yml` ≤250 lines and one required gate.
  - No `paths:` filters; actions pinned by SHA; `timeout-minutes` on every job.
  - No phase-numbered workflows or tasks.
  - Build from the bootstrap skill's description, not by copying oarlock's files.
- **Host footprint.**
  - Start zero processes in the host: no `name: __MODULE__` singletons and no `:persistent_term`.
  - No `compile_env` outside config.
  - Public LiveView APIs only.
- **Honesty.** A check that didn't run is `not-run`, never `pass`.

## Summary

Every load-bearing decision is already locked, so this research checked the decisions mechanically and turned them into a buildable inventory. The repo is docs-only today: 75 tracked files, no `mix.exs`, no `.github/`, and **no GitHub remote**. `gh api /repos/szTheory/fablebook` returns 404, and hex.pm `fablebook` returns 404. The first concrete step is therefore to create the repository and push the existing history before any PR can exist.

I re-ran the riskiest pieces locally:
- **Prod guard.** The full guard runs from inside ExUnit through `System.cmd("mix", ...)` on both lanes:
  - Elixir 1.20.4 / OTP 29.1.1 with Phoenix 1.8.16 and LiveView 1.2.13;
  - Elixir 1.18.4 / OTP 27.3.4.15 with Phoenix 1.8.9 and LiveView 1.2.9.
- **Floor lockfile.** `mix.floor.lock` is produced by resolving a temporary copy of `mix.exs` with exact pins through `MIX_EXS`. `FABLEBOOK_FLOOR=1 mix deps.get --check-locked` then passes against the real ranges.
- **BEAM ban walker.** Re-verified on 1.20.4 with LiveView 1.2.13 `~H`.
- **Workflows.** Drafts of all three workflows and the composite action pass the pinned actionlint 1.7.12 and zizmor 1.31.1, after one fix.

Six findings change what the planner must write. None of them reopens a locked decision.
1. **The pinned linters disagree about local `uses:` paths.** zizmor 1.31.1 fails on every `./.github/...` reference (new `self-repository` audit, exit 12). actionlint 1.7.12 rejects GitHub's new `$/` self-repository syntax. Keep `./` and disable that single zizmor audit in a config file (Pitfall 1).
2. **Elixir 1.19+ aborts `mix test --warnings-as-errors`** when non-test files live under `test/`, which the fixtures do. Set `test_ignore_filters` (Pitfall 2).
3. **`mix ci` must run in `:test`** because `mix test` refuses to run under an alias in `:dev`. So credo and ex_doc must be `only: [:dev, :test]`, which still satisfies D-26's rule (Pitfall 3).
4. **Dialyzer fails on `Mix.env/0`** unless `:mix` is in `plt_add_apps` (Pitfall 4).
5. **D-17 bans `uses: ./.github/workflows/` in all three files.** That contradicts D-08, where `release-please.yml` must call `hex-publish.yml` (Pitfall 7).
6. **The current corpus has 8 plural or hyphenated ADR citations** (`ADRs 0014–0017`, `ADR-0002`) that the literal D-19 "other ADR forms fail" rule would reject (Pitfall 9).

**Primary recommendation:**
- Land plans 1–3 on one branch as one PR, opened as a draft on day 1, so every guard enters as status `A` and the D-21 contract rule never trips on Phase 1's own iteration.
- Then let release-please drive PR #2 (the release PR) with the PAT.
- Then open PR #3 to remove `release-as`.
- Do every human-only GitHub and Hex step in the order given in "Human-Action Checkpoints".

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Prod guard (`fablebook/2` raise) | Build / compile time (macro expansion in the host's compiler) | Host router module body | `Mix.env()` is read when the macro expands in the host. The raise sits in the returned quote, so it fires only if the call is reachable (D-01). |
| Placeholder route | Host HTTP pipeline (Plug) | — | `Phoenix.Router.get/4` to `Fablebook.Placeholder`. No processes and no LiveView in 0.1.0. |
| CI shape, intent, contract-rule, ban, budget, tarball and style guards | Test suite (ExUnit, `mix ci`) | CI job `core` (and `floor`) | Pure functions over files, git diff output and BEAM chunks, so they run locally and in CI alike. |
| YAML validity, workflow security | CI `security` job (actionlint, zizmor in pinned containers) | — | D-18: real YAML parsing is delegated to these tools, not the line scanner. |
| Single required check | GitHub ruleset (repo settings) | `ci-gate` job | A control outside the PR. `ci-health` asserts that it hasn't drifted. |
| Release orchestration | `release-please.yml` (PAT) | `hex-publish.yml` (reusable and dispatch) | One publish implementation, called by release-please and by hand for recovery. |
| Package artifact | Hex (hex.pm) | GitHub Release (draft, then final) plus SBOM asset | Immutable releases mean assets go on while the release is still a draft. |
| Weekly timing and drift | `ci-health` scheduled job | Issues `ci-timing` and `quality-regression` | Stays inside the 3-workflow cap. |

## Standard Stack

### Core (runtime closure; exactly the D-26 set)
| Library | Version | `mix.exs` requirement | Purpose | Provenance |
|---------|---------|----------------------|---------|-----------|
| phoenix | 1.8.16 (2026-10-20); floor 1.8.9 (2026-07-07) | `">= 1.8.9 and < 2.0.0"` | Router macro target, `phx.routes` in the fixture | [VERIFIED: hex.pm API] |
| phoenix_live_view | 1.2.13 (2026-10-20); floor 1.2.9 (2026-08-10) | `">= 1.2.9 and < 2.0.0"` | Declared now (D-26); not used by 0.1.0 code | [VERIFIED: hex.pm API] |
| phoenix_html | 4.3.0 (2025-09-28) | `"~> 4.1"` | Declared now (D-26) | [VERIFIED: hex.pm API] |
| telemetry | 1.4.2 (2026-05-11) | `"~> 1.0"` | Declared now (D-26) | [VERIFIED: hex.pm API] |
| nimble_options | 1.1.1 (2024-05-25) | `"~> 1.1"` | Declared now (D-26) | [VERIFIED: hex.pm API] |

The LiveView 1.2.9 and 1.2.13 requirements accept Phoenix `~> 1.6.15 or ~> 1.7.0 or ~> 1.8.0` and phoenix_html `~> 3.3 or ~> 4.0 or ~> 4.1`, so the floor pair resolves together [VERIFIED: hex.pm release API]. Phoenix 1.8.9's non-optional requirements are phoenix_pubsub, phoenix_template, plug, plug_crypto, telemetry and websock_adapter, and jason is optional, so the prod closure contains no banned name [VERIFIED: hex.pm release API].

### Dev and test (never in the prod closure)
| Library | Version | Requirement | Purpose | Note |
|---------|---------|-------------|---------|------|
| credo | 1.7.19 (2026-06-05) | `"~> 1.7", only: [:dev, :test], runtime: false` | Source bans, custom check | `only: [:dev, :test]`, not `:dev`; see Pitfall 3 [VERIFIED: local run] |
| ex_doc | 0.40.4 (2026-09-03) | `"~> 0.40", only: [:dev, :test], runtime: false` | `mix docs --warnings-as-errors` in `mix ci`; `hex.publish` docs | `--warnings-as-errors` exists [VERIFIED: deps/ex_doc mix task source] |
| dialyxir | 1.4.8 (2026-09-05) | `"~> 1.4", only: :dev, runtime: false` | `dialyzer` job (runs with `MIX_ENV=dev`) | Needs `plt_add_apps: [:mix]` (Pitfall 4) [VERIFIED: local run] |

No tailwind or esbuild in Phase 1. There is no chrome yet, so adding them now would only add unused lock entries.

### Toolchain and pinned CI references (all resolved this session)
| Item | Value | Provenance |
|------|-------|-----------|
| Latest lane | `.tool-versions`: `elixir 1.20.4-otp-29`, `erlang 29.1.2`; both exist on builds.hex.pm for ubuntu-24.04 (OTP-29.1.2 built 2026-10-14; v1.20.4-otp-29 built 2026-08-28) | [VERIFIED: builds.hex.pm builds.txt] |
| Floor lane | Elixir `1.18.5-otp-27`, OTP `27.3.4.9`; both exist on builds.hex.pm. Newest 27.3.4.x is .19 (2026-10-14) | [VERIFIED: builds.hex.pm] |
| Hex client | 2.6.0 (2026-10-23); `mix local.hex 2.6.0 --force` is valid syntax (`mix local.hex [version]`) | [VERIFIED: GitHub releases, `mix help local.hex`] |
| actions/checkout v7.0.1 | `3d3c42e5aac5ba805825da76410c181273ba90b1` (commit) | [VERIFIED: gh api git/ref] |
| actions/cache v6.1.0 (and `/restore`, `/save`) | `55cc8345863c7cc4c66a329aec7e433d2d1c52a9` | [VERIFIED: gh api] |
| erlef/setup-beam v1.24.1 | `54075bcc5e249e4758d363f27d099f55d843f124` | [VERIFIED: gh api] |
| googleapis/release-please-action v5.0.0 | `45996ed1f6d02564a971a2fa1b5860e934307cf7` | [VERIFIED: gh api] |
| erlef/mix_sbom v0.12.0 | annotated tag object `3991ce8a…`; **commit** `96bb84f8e9e72361bfad4142d666dfa2c0838ac2`. Pin the commit. | [VERIFIED: gh api git/tags deref] |
| actions/dependency-review-action v5.0.0 (latest) | `a1d282b36b6f3519aa1f3fc636f609c47dddb294` | [VERIFIED: gh api] |
| actionlint 1.7.12 image | `docker://rhysd/actionlint@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667` (OCI index digest) | [VERIFIED: docker buildx imagetools inspect] |
| zizmor 1.31.1 image | `docker://ghcr.io/zizmorcore/zizmor@sha256:42d409dbb851d4c5d35a058cf042b828bea1e3f2884378c526eb0974780e18d9` (OCI index digest) | [VERIFIED: docker buildx imagetools inspect] |
| GitHub Actions app id | `15368` (for the ruleset `integration_id`) | [VERIFIED: gh api /apps/github-actions] |

**Re-resolve commands (day 1, in case a tag moved):**
```bash
res() { j=$(gh api "repos/$1/git/ref/tags/$2"); t=$(jq -r .object.type <<<"$j"); s=$(jq -r .object.sha <<<"$j")
  [ "$t" = tag ] && s=$(gh api "repos/$1/git/tags/$s" --jq .object.sha); echo "$1@$2 $s"; }
res actions/checkout v7.0.1; res actions/cache v6.1.0; res erlef/setup-beam v1.24.1
res googleapis/release-please-action v5.0.0; res erlef/mix_sbom v0.12.0; res actions/dependency-review-action v5.0.0
docker buildx imagetools inspect rhysd/actionlint:1.7.12 | sed -n 3p
docker buildx imagetools inspect ghcr.io/zizmorcore/zizmor:1.31.1 | sed -n 3p
gh api /apps/github-actions --jq .id
```

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `./.github/actions/setup` plus a zizmor config disabling `self-repository` | `$/.github/actions/setup` (GitHub self-repository syntax, July 2026, runner ≥ 2.336.0) | actionlint 1.7.12 rejects `$/` ("ref is missing"), so it would need an actionlint `-ignore`. It also breaks D-17's locked `uses:` dialect. Revisit when actionlint supports `$/`. |
| Disabling one zizmor audit by name | `--min-severity medium` | That would silently drop every future low-severity finding. A named disable is honest. |

**Installation:** none beyond `mix deps.get`. All tools are Hex deps, setup-beam or pinned container images.

## Package Legitimacy Audit

The gsd `package-legitimacy` seam covers npm, pypi and crates only, so the Hex packages were checked directly against the hex.pm API (age, weekly downloads, source repo, license). All are the ecosystem's canonical packages, named in ADR 0018 and CLAUDE.md.

| Package | Registry | Age | Downloads/wk | Source Repo | Verdict | Disposition |
|---------|----------|-----|--------------|-------------|---------|-------------|
| phoenix | Hex | since 2014 | 615k | github.com/phoenixframework/phoenix | OK | Approved |
| phoenix_live_view | Hex | since 2019 | 502k | github.com/phoenixframework/phoenix_live_view | OK | Approved |
| phoenix_html | Hex | since 2015 | 505k | github.com/phoenixframework/phoenix_html | OK | Approved |
| telemetry | Hex | since 2018 | 866k | github.com/beam-telemetry/telemetry | OK | Approved |
| nimble_options | Hex | since 2020 | 593k | github.com/dashbitco/nimble_options | OK | Approved |
| credo | Hex | since 2015 | 494k | github.com/rrrene/credo | OK | Approved |
| dialyxir | Hex | since 2015 | 302k | github.com/jeremyjh/dialyxir | OK | Approved |
| ex_doc | Hex | since 2014 | 261k | github.com/elixir-lang/ex_doc | OK | Approved |

**Packages removed due to [SLOP] verdict:** none.
**Packages flagged as suspicious [SUS]:** none.
None of these packages has a postinstall-style hook; Hex packages don't have one. Dev-only transitive deps (bunt, jason via credo, makeup, earmark_parser, erlex, file_system, nimble_parsec) appear in `mix.lock` but not in the prod closure. D-26 allows this.

## Architecture Patterns

### System Architecture Diagram

```
 developer push / PR ──► ci.yml (pull_request | push main | 2 crons | dispatch)
                           │
     ┌─────────────┬───────┴──────┬──────────────┬───────────────┐
     ▼             ▼              ▼              ▼               ▼
   core          floor         dialyzer       security        nightly (cron '17 3 * * *'
 (mix ci:       (FABLEBOOK_    (MIX_ENV=dev,  (hex.audit,      or head_ref release-please--*)
  format,        FLOOR=1,       PLT cache)     dep-review,      bin/smoke_consumer --path
  credo,         1.18.5/OTP27,                 actionlint,
  compile,       compile,                      zizmor)
  docs, test     --no-optional-deps,
  incl. guards)  test + prod_guard)
     │             │              │              │               │
     └─────────────┴──────────────┴──────┬───────┴───────────────┘
                                         ▼
                       ci-gate (if: always(); jq over toJSON(needs))
                                         │  success?
                                         ▼
                 GitHub ruleset on main: required check "ci-gate" (app 15368)
                                         │ merge
                                         ▼
   push main ──► release-please.yml (RELEASE_PLEASE_TOKEN PAT)
                   │ no release yet → opens/updates release PR (head release-please--branches--main)
                   │                   └─► triggers ci.yml (because PAT) → nightly runs → ci-gate
                   │ release PR merged → draft release + tag vX.Y.Z (force-tag-creation)
                   ▼ release_created == 'true'
             hex-publish.yml (workflow_call; also workflow_dispatch for recovery)
                   build ─► publish (env hex-production) ─► smoke (latest, floor) ─► finalize
                   │ tag==@version   │ checksum idempotency  │ poll hex.pm, compare    │ gh release
                   │ guard tests     │ hex.publish --yes      │ checksum, phx.new       │ edit --draft=false
                   │ hex.build+sha   │                        │ consumer, hexdocs
                   │ smoke --path    │
                   │ SBOM → draft    │
   weekly cron '23 5 * * 1' ──► ci-health: p50/p95 from runs API → ci-timing issue;
                                 breach or ruleset drift → quality-regression issue
```

### File inventory and creation order

Repo-relative paths. "Plan" refers to the suggested split. **(A)** means the file is new and enters as git status `A`.

| # | Path | Plan | Purpose / key content |
|---|------|------|----------------------|
| 0 | GitHub repo `szTheory/fablebook` plus the existing `main` history | human/agent checkpoint | `gh repo create szTheory/fablebook --public --source=. --remote=origin --push` (no remote exists today [VERIFIED: `git remote -v` empty]) |
| 1 | `.tool-versions` | 1 | `elixir 1.20.4-otp-29` / `erlang 29.1.2` |
| 2 | `mix.exs` | 1 | Skeleton below: one `@version`, lockfile switch, `def cli`, aliases, `test_ignore_filters`, dialyzer, package `files:` |
| 3 | `.formatter.exs` | 1 | `import_deps: [:phoenix]`, inputs `{mix,.formatter}.exs`, `{config,lib,test,credo}/**/*.{ex,exs}`; `export: [locals_without_parens: [fablebook: 2, fablebook: 3]]` and the same in `locals_without_parens` |
| 4 | `mix.lock`, `mix.floor.lock` | 1 | `mix deps.get`, then `bin/floor_lock` (recipe below) |
| 5 | `bin/floor_lock` | 1 | Regenerates `mix.floor.lock` deterministically against a given registry state |
| 6 | `lib/fablebook.ex`, `lib/fablebook/router.ex`, `lib/fablebook/placeholder.ex` | 1 | D-01, D-02, D-04, D-07 |
| 7 | `test/test_helper.exs` | 1 | `ExUnit.start(exclude: [:prod_guard, :release, :git_diff?])`, plus the D-19 base resolution (raise in CI, exclude locally) |
| 8 | `test/fixtures/prod_guard_host/{mix.exs,config/config.exs,lib/router.ex,lib/ok.ex,storybook/book.ex,unguarded/router.ex}` | 1 | D-05; layout below |
| 9 | `test/support/mix_cmd.ex` (name at discretion) | 1 | Nested-mix helper with env scrubbing |
| 10 | `test/contract/prod_guard_test.exs` | 1 | D-06 steps 1–7, `@moduletag timeout: 600_000` |
| 11 | `LICENSE` (MIT, holder `sztheory`), `README.md`, `CHANGELOG.md` (skill template minus the sigra Summary), `usage-rules.md` (stub) | 1 | Tarball contents (D-28) |
| 12 | `.gitignore` additions | 1 | Nothing required: fixture builds go under root `/_build/` via `build_path`. Optional: `/deps_floor/` if Pitfall 12's mitigation is adopted |
| 13 | `test/support/git_diff.ex`, `test/planning/intent_test.exs`, `test/planning/contract_rule_test.exs` | 2 | D-19, D-21 |
| 14 | `test/contract/ci_shape_test.exs`, `test/fixtures/ci_shape/*.yml` | 2 | D-17, one failing fixture per rule |
| 15 | `test/support/beam_walker.ex`, `test/contract/banned_calls_test.exs`, `test/fixtures/guards/*.ex` | 2 | D-23, D-24 |
| 16 | `credo/checks/banned_calls.ex`, `.credo.exs` | 2 | D-23 source layer |
| 17 | `test/contract/style_attr_test.exs` | 2 | D-25 (only `lib/` exists in Phase 1) |
| 18 | `test/contract/dependency_budget_test.exs` | 2 | D-26, plus the floor-version assertion (Pitfall 11) |
| 19 | `test/contract/tarball_test.exs` | 2 | D-28 |
| 20 | `.github/actions/setup/action.yml` | 3 | ≤60 lines (draft below is 57) |
| 21 | `.github/workflows/ci.yml` | 3 | Draft below is 151 lines |
| 22 | `.github/zizmor.yml` | 3 | Disables `self-repository` only (Pitfall 1); allowlist it in the shape test's `.github/**` inventory |
| 23 | `bin/ci_health` | 3 | Bash plus `gh` and `jq`; keeps ci.yml short; runs locally with `GH_TOKEN` |
| 24 | `docs/adr/0007…`, `0017…`, `0018…`, `0004…` amendments, `.planning/intent/OPEN-QUESTIONS.md` strikes, new INT source entries for each sign-off | 1–3 | Owner sign-off checkpoints (D-12, D-16, D-21, D-26, D-27, D-31); also update COMPAT-01 wording |
| 25 | `release-please-config.json`, `.release-please-manifest.json` | 4 | Below |
| 26 | `.github/workflows/release-please.yml`, `.github/workflows/hex-publish.yml` | 4 | Drafts below. If PR #1 is to be the single phase PR, they must land in PR #1 (the shape test requires exactly three workflows from the first run) |
| 27 | `bin/smoke_consumer` | 4 (and `nightly` in plan 3) | `--path DIR` or `--hex V [--checksum SHA]` |

**Ordering constraint the planner must respect.** The D-17 shape test asserts that `.github/workflows/**` equals exactly the three files. So whichever PR first adds `ci_shape_test.exs` must also contain all three workflows. Once the test is on `main`, editing it is status `M` and is barred alongside `.github/**` changes (D-21). **Recommendation:** one branch and one PR (#1) carries plans 1–4's files (everything except the publish itself). Open it as a draft on day 1 and keep it green-iterating. The merge then triggers release-please, the release PR (#2) publishes, and a small PR (#3) removes `release-as`.

### Pattern 1: `mix.exs` skeleton
```elixir
# Source: assembled from the verified prototype at scratchpad fl/mix.exs (Elixir 1.20.4 and 1.18.4)
defmodule Fablebook.MixProject do
  use Mix.Project

  @version "0.0.0"
  @source_url "https://github.com/szTheory/fablebook"

  def project do
    [
      app: :fablebook,
      version: @version,
      elixir: "~> 1.18",
      description: "A Storybook-style workbench for Phoenix LiveView (name reserved; unreleased).",
      deps: deps(),
      lockfile: lockfile(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_ignore_filters: [&String.starts_with?(&1, "test/fixtures/")],
      dialyzer: [plt_local_path: "priv/plts", plt_core_path: "priv/plts", plt_add_apps: [:mix]],
      package: package(),
      docs: [main: "readme", source_ref: "v#{@version}", extras: ["README.md", "CHANGELOG.md"]],
      source_url: @source_url
    ]
  end

  def cli, do: [preferred_envs: [ci: :test]]

  def application, do: []

  defp lockfile, do: if(System.get_env("FABLEBOOK_FLOOR"), do: "mix.floor.lock", else: "mix.lock")

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, ">= 1.8.9 and < 2.0.0"},
      {:phoenix_live_view, ">= 1.2.9 and < 2.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:telemetry, "~> 1.0"},
      {:nimble_options, "~> 1.1"},
      {:ex_doc, "~> 0.40", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "format --check-formatted",
        "deps.unlock --check-unused",
        "compile --warnings-as-errors --force",
        "credo --strict",
        "xref graph --format cycles --label compile-connected --fail-above 0",
        "docs --warnings-as-errors",
        "test --warnings-as-errors --include prod_guard --include release"
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib mix.exs .formatter.exs README.md LICENSE CHANGELOG.md usage-rules.md)
    ]
  end
end
```
Notes:
- `@version "0.0.0"` matches the `0.0.0` manifest, and the release PR then bumps it to `0.1.0` visibly. `"0.1.0"`, as the skill does, also works. Either way there is exactly one `@version` (D-09).
- `hex.build` with these deps emits exactly the five requirements, all `optional: false` [VERIFIED: local `mix hex.build --unpack`, Hex 2.5.1].
- `--no-optional-deps` is a `mix compile` flag on 1.18 [VERIFIED: `mix help compile` 1.18.4]. It is not a `mix test` flag.
- `xref graph --format cycles --label compile-connected --fail-above 0` passed on the prototype [VERIFIED: local]. Its inclusion is discretionary; ADR 0017 lists "xref".

### Pattern 2: floor lockfile generation (`bin/floor_lock`)
```bash
#!/usr/bin/env bash
# Source: verified locally 2026-10-28 (Elixir 1.20.4); regenerated twice with identical sha256
set -euo pipefail
tmp="$(mktemp -d)"
sed -e 's/{:phoenix, ">= 1.8.9 and < 2.0.0"}/{:phoenix, "== 1.8.9"}/' \
    -e 's/{:phoenix_live_view, ">= 1.2.9 and < 2.0.0"}/{:phoenix_live_view, "== 1.2.9"}/' \
    mix.exs > "$tmp/mix.exs"
grep -q '"== 1.8.9"' "$tmp/mix.exs" && grep -q '"== 1.2.9"' "$tmp/mix.exs"
rm -f mix.floor.lock
MIX_EXS="$tmp/mix.exs" FABLEBOOK_FLOOR=1 MIX_DEPS_PATH="$tmp/deps" mix deps.get
FABLEBOOK_FLOOR=1 MIX_DEPS_PATH="$tmp/deps" mix deps.get --check-locked
```
- `MIX_EXS` points Mix at the pinned copy. The current directory stays the repo, so `lockfile: "mix.floor.lock"` writes the repo's floor lock.
- `MIX_DEPS_PATH` keeps the floor sources out of `deps/`.
- Result: Phoenix 1.8.9, LiveView 1.2.9, and the latest compatible transitive deps (plug 1.20.3, websock_adapter 0.7.0, phoenix_html 4.3.0). `--check-locked` then exits 0 against the real ranges. Raising a floor without regenerating fails with `Your mix.floor.lock is out of date` [VERIFIED: local].
- "Deterministic" means: same `mix.exs` plus the same Hex registry state gives the same bytes. A new transitive release changes the output. The committed file is the artifact; re-run the script only deliberately.
- Optional, not locked: pinning all five runtime deps at their floors (phoenix_html 4.1.0, telemetry 1.0.0, nimble_options 1.1.0) also resolves [VERIFIED: local resolution]. Compilation on 1.18 of that fuller floor set was not tested.

### Pattern 3: prod-guard fixture layout and nested mix
```elixir
# test/fixtures/prod_guard_host/mix.exs
# Source: verified from ExUnit on 1.20.4/OTP 29.1.1 and 1.18.4/OTP 27.3.4.15 (floor lock)
defmodule GuardHost.MixProject do
  use Mix.Project

  def project do
    [
      app: :guard_host,
      version: "0.1.0",
      elixir: "~> 1.18",
      deps_path: "../../../deps",
      build_path: "../../../_build/guard_host",
      lockfile: lockfile(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: [{:fablebook, path: "../../.."}, {:phoenix, ">= 0.0.0"}]
    ]
  end

  defp lockfile,
    do: if(System.get_env("FABLEBOOK_FLOOR"), do: "../../../mix.floor.lock", else: "../../../mix.lock")

  defp elixirc_paths(:prod),
    do: ["lib"] ++ if(System.get_env("FABLEBOOK_UNGUARDED"), do: ["unguarded"], else: [])

  defp elixirc_paths(_), do: ["lib", "storybook"]
end
```
```elixir
# test/support/mix_cmd.ex (name at discretion)
defmodule Fablebook.Test.MixCmd do
  @moduledoc false
  @scrub ~w(MIX_EXS MIX_LOCKFILE MIX_BUILD_PATH MIX_BUILD_ROOT MIX_DEPS_PATH MIX_TARGET FABLEBOOK_UNGUARDED)

  def run(dir, env, args, extra \\ []) do
    System.cmd("mix", args,
      cd: dir,
      env: Enum.map(@scrub, &{&1, nil}) ++ [{"MIX_ENV", env} | extra],
      stderr_to_stdout: true
    )
  end
end
```
- The router fixture uses `use Phoenix.Router, helpers: false` to mirror `phx.new`. Without it, Phoenix 1.8 still generates `Router.Helpers` [VERIFIED: prototype output listed `Elixir.GuardHostWeb.Router.Helpers.beam`].
- `build_path` puts fixture builds at `_build/guard_host/{dev,prod}`, which root `/_build/` already ignores [VERIFIED: .gitignore:2 `/_build/`]. Use `mix clean` (project only, not `--deps`) before steps 1, 4 and 7 so beam assertions reflect fresh compiles while compiled deps stay warm.
- `compile_info` `source` is an absolute path, so match on the `"/storybook/"` substring [VERIFIED: local output].
- The canonical message appeared exactly once in the unguarded output (`** (CompileError) unguarded/router.ex:4: …`) [VERIFIED: local, 1.20.4].
- Measured locally: about 8.1 s per lane for dev, prod and unguarded compiles plus `phx.routes`, starting from a warm root `deps/`.

### Pattern 4: BEAM walker (re-verified on 1.20.4 with LiveView 1.2.13)
```elixir
# Source: scratchpad v20/scan.exs, run 2026-10-28 on Elixir 1.20.4 / OTP 29.1.1, LiveView 1.2.13
{:ok, {^mod, [debug_info: {:debug_info_v1, backend, data}]}} = :beam_lib.chunks(path, [:debug_info])
{:ok, forms} = backend.debug_info(:erlang_v1, mod, data, [])
# walk forms collecting atoms (tuples, lists, maps); intersect with the atom tier
{:ok, {_, [imports: imports]}} = :beam_lib.chunks(path, [:imports])
# filter {m, f, a} against the MFA tier
```
Observed results:
- A `use Phoenix.Component` module with `~H`, `attr ... values:`, `:global` and `<.link>`, plus a LiveView with `stream/3` and `JS.push/1`: **no atom-tier hits**.
- TagEngine imports in that code: `{Phoenix.LiveView.TagEngine, :component, 3}` and `{Phoenix.LiveView.TagEngine, :__assigns__, 3}`. That is the reason not to ban the module (D-23).
- A copy of the router prototype: no hits.
- The `evil.ex` bypass set (alias, import, `apply`, `:erlang.binary_to_atom`, interpolated atom, macro-generated call, `Module.concat`, capture, `EEx.compile_string`, `binary_to_term`, `to_existing_atom`, `List.to_atom`, dynamic module `m.eval_string/1`):
  - atom hits `[:binary_to_atom, :binary_to_existing_atom, :binary_to_term, :compile_string, :eval_quoted, :eval_string, :list_to_atom, :string_to_quoted!]`;
  - MFA hits `[{EEx, :compile_string, 2}, {Module, :concat, 1}]`;
  - the macro module flagged `:eval_string` from its `quote` body.

### Pattern 5: `ci.yml` skeleton (151 lines; actionlint 1.7.12 and zizmor 1.31.1 clean with `.github/zizmor.yml`)
```yaml
# Source: scratchpad wf/.github/workflows/ci.yml, linted 2026-10-28
name: ci

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: '17 3 * * *'
    - cron: '23 5 * * 1'
  workflow_dispatch:

permissions:
  contents: read

concurrency:
  group: ci-${{ github.event.pull_request.number || github.ref }}-${{ github.event.schedule }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

env:
  EVENT_BEFORE: ${{ github.event.before }}

jobs:
  core:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    env:
      MIX_ENV: test
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          fetch-depth: 0
          filter: blob:none
          persist-credentials: false
      - uses: ./.github/actions/setup
      - run: mix ci

  floor:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    env:
      MIX_ENV: test
      FABLEBOOK_FLOOR: '1'
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          fetch-depth: 0
          filter: blob:none
          persist-credentials: false
      - uses: ./.github/actions/setup
        with:
          lane: floor
      - run: mix compile --warnings-as-errors
      - run: mix compile --no-optional-deps --warnings-as-errors --force
      - run: mix test --warnings-as-errors --include prod_guard

  dialyzer:
    runs-on: ubuntu-24.04
    timeout-minutes: 15
    env:
      MIX_ENV: dev
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - uses: ./.github/actions/setup
        with:
          mix-env: dev
      - id: plt-key
        run: |
          tools="$(sha256sum .tool-versions | cut -c1-16)"
          echo "key=plt-$RUNNER_OS-$RUNNER_ARCH-$tools-$(sha256sum mix.lock | cut -c1-16)" >> "$GITHUB_OUTPUT"
      - id: plt
        uses: actions/cache/restore@55cc8345863c7cc4c66a329aec7e433d2d1c52a9 # v6.1.0
        with:
          path: priv/plts
          key: ${{ steps.plt-key.outputs.key }}
      - run: mix dialyzer --plt
      - if: github.ref == 'refs/heads/main' && steps.plt.outputs.cache-hit != 'true'
        uses: actions/cache/save@55cc8345863c7cc4c66a329aec7e433d2d1c52a9 # v6.1.0
        with:
          path: priv/plts
          key: ${{ steps.plt-key.outputs.key }}
      - run: mix dialyzer --format github

  security:
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    permissions:
      contents: read
      pull-requests: read
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - uses: ./.github/actions/setup
        with:
          mix-env: dev
      - run: mix hex.audit
      - if: github.event_name == 'pull_request'
        uses: actions/dependency-review-action@a1d282b36b6f3519aa1f3fc636f609c47dddb294 # v5.0.0
      - uses: docker://rhysd/actionlint@sha256:b1934ee5f1c509618f2508e6eb47ee0d3520686341fec936f3b79331f9315667
        with:
          args: -color
      - uses: docker://ghcr.io/zizmorcore/zizmor@sha256:42d409dbb851d4c5d35a058cf042b828bea1e3f2884378c526eb0974780e18d9
        with:
          args: .github
        env:
          GH_TOKEN: ${{ github.token }}

  nightly:
    if: github.event.schedule == '17 3 * * *' || startsWith(github.head_ref, 'release-please--')
    runs-on: ubuntu-24.04
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - uses: ./.github/actions/setup
        with:
          mix-env: dev
      - run: bin/smoke_consumer --path .

  ci-gate:
    if: always()
    needs: [core, floor, dialyzer, security, nightly]
    runs-on: ubuntu-24.04
    timeout-minutes: 5
    steps:
      - env:
          NEEDS: ${{ toJSON(needs) }}
          HEAD_REF: ${{ github.head_ref }}
        run: |
          echo "$NEEDS" | jq -e --arg ref "$HEAD_REF" 'to_entries | all(
            .value.result == "success" or
            (.key == "nightly" and .value.result == "skipped" and ($ref | startswith("release-please--") | not)))'

  ci-health:
    if: github.event.schedule == '23 5 * * 1' || github.event_name == 'workflow_dispatch'
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    permissions:
      actions: read
      issues: write
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
        with:
          persist-credentials: false
      - env:
          GH_TOKEN: ${{ github.token }}
        run: bin/ci_health
```
Notes:
- **ci-gate truth table** [VERIFIED: local jq]:
  - nightly skipped on a normal PR gives 0;
  - nightly skipped on `release-please--branches--main` gives 1;
  - any other job skipped, cancelled or failed gives 1;
  - `{}` gives 0, which is why the shape test must assert `needs` set equality.
- **Line lengths.** The zizmor `uses:` line is exactly 120 characters, so it passes a `> 120` rule. Never add a `# 1.31.1` comment to it.
- **The nightly placeholder does real work.** It runs `bin/smoke_consumer --path .` against latest `phx.new`, so the release PR is gated on a consumer build (ADR 0017: the release PR runs the nightly suite). Node is not used, but `nightly` is already on the Node allowlist.
- **Scheduled runs also run the PR jobs.** On the `ci-health` cron, `nightly` is skipped, and ci-gate allows that because `head_ref` is empty. That costs about one extra PR-lane run per week. Guarding every PR job with `if:` would cost lines and skipped-result handling.

### Pattern 6: composite setup action (57 lines; ≤60)
```yaml
# Source: scratchpad wf/.github/actions/setup/action.yml, linted 2026-10-28
name: setup
description: Install a lane's Erlang and Elixir, restore deps and _build, fetch and compile deps
inputs:
  lane:
    description: latest or floor
    default: latest
  mix-env:
    description: MIX_ENV used to compile deps
    default: test
  cache:
    description: false in release workflows
    default: 'true'
runs:
  using: composite
  steps:
    - id: latest
      if: inputs.lane == 'latest'
      uses: erlef/setup-beam@54075bcc5e249e4758d363f27d099f55d843f124 # v1.24.1
      with:
        version-file: .tool-versions
        version-type: strict
    - id: floor
      if: inputs.lane == 'floor'
      uses: erlef/setup-beam@54075bcc5e249e4758d363f27d099f55d843f124 # v1.24.1
      with:
        otp-version: 27.3.4.9
        elixir-version: 1.18.5-otp-27
        version-type: strict
    - id: key
      shell: bash
      env:
        LOCK: ${{ inputs.lane == 'floor' && 'mix.floor.lock' || 'mix.lock' }}
        OTP: ${{ steps.latest.outputs.otp-version || steps.floor.outputs.otp-version }}
        EX: ${{ steps.latest.outputs.elixir-version || steps.floor.outputs.elixir-version }}
        MIX_ENV: ${{ inputs.mix-env }}
      run: |
        lock="$(sha256sum "$LOCK" | cut -c1-16)"
        echo "key=mix-$RUNNER_OS-$RUNNER_ARCH-$OTP-$EX-$MIX_ENV-$lock" >> "$GITHUB_OUTPUT"
    - id: restore
      if: inputs.cache == 'true'
      uses: actions/cache/restore@55cc8345863c7cc4c66a329aec7e433d2d1c52a9 # v6.1.0
      with:
        path: |
          deps
          _build
        key: ${{ steps.key.outputs.key }}
    - shell: bash
      env:
        MIX_ENV: ${{ inputs.mix-env }}
      run: mix deps.get --check-locked && mix deps.compile
    - if: inputs.cache == 'true' && github.ref == 'refs/heads/main' && steps.restore.outputs.cache-hit != 'true'
      uses: actions/cache/save@55cc8345863c7cc4c66a329aec7e433d2d1c52a9 # v6.1.0
      with:
        path: |
          deps
          _build
        key: ${{ steps.key.outputs.key }}
```
- A composite action can't run a post-job step, so "split restore/save" means saving right after `deps.compile`. The fixture's `_build/guard_host` is never cached, which costs the two fixture dep compiles per run.
- `cache: 'false'` is for release workflows, to avoid cache poisoning into a publishing job.

### Pattern 7: release workflows (actionlint and zizmor clean)
```yaml
# .github/workflows/release-please.yml (38 lines)
name: release-please
on:
  push:
    branches: [main]
permissions:
  contents: read
concurrency:
  group: release-please
  cancel-in-progress: false
jobs:
  release-please:
    runs-on: ubuntu-24.04
    timeout-minutes: 10
    outputs:
      release_created: ${{ steps.rp.outputs.release_created }}
      tag: ${{ steps.rp.outputs.tag_name }}
    steps:
      - id: rp
        uses: googleapis/release-please-action@45996ed1f6d02564a971a2fa1b5860e934307cf7 # v5.0.0
        with:
          token: ${{ secrets.RELEASE_PLEASE_TOKEN }}
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
  publish:
    needs: release-please
    if: needs.release-please.outputs.release_created == 'true'
    permissions:
      contents: write
    uses: ./.github/workflows/hex-publish.yml
    with:
      tag: ${{ needs.release-please.outputs.tag }}
    secrets:
      HEX_API_KEY: ${{ secrets.HEX_API_KEY }}
```
- **`hex-publish.yml` structure** (full 141-line draft linted in scratchpad `wf/`):
  - workflow-level `env: TAG: ${{ inputs.tag }}, MIX_ENV: dev`.
  - **`build`** (`contents: write`):
    - checkout the tag, then the setup action with `cache: 'false'`;
    - `mix local.hex 2.6.0 --force`;
    - tag regex plus `mix run --no-start --no-compile -e 'IO.write(Mix.Project.config()[:version])'` equality;
    - the guard tests through a step-level `env: MIX_ENV: test`;
    - `mix hex.build --output`, then sha256;
    - `mix hex.build --unpack --output unpacked`, then `bin/smoke_consumer --path unpacked`;
    - `erlef/mix_sbom` with `id: sbom`, then `cp "${{ steps.sbom.outputs.sbom-path }}" fablebook-$V.cdx.json` and `gh release upload --clobber`.
  - **`publish`** (`environment: hex-production`):
    - `test -n "$HEX_API_KEY"`;
    - `curl hex.pm/api/packages/fablebook/releases/$V | jq -r .checksum`;
    - if present, assert it equals the build sha256; otherwise checkout, setup, `mix local.hex 2.6.0 --force && mix hex.publish --yes`.
  - **`smoke`**: a matrix over `[latest, floor]` running `bin/smoke_consumer --hex "$V" --checksum "$SHA256"`.
  - **`finalize`** (`contents: write`): `gh release edit "$TAG" --draft=false` with `GH_REPO` set.
- **SBOM output path.** `erlef/mix_sbom` writes to `$RUNNER_TEMP/$RANDOM.cdx.json` and exposes it as the `sbom-path` output, so a copy-and-rename step is required [VERIFIED: action.yml at 96bb84f8…].
- **SBOM tool provenance.** The action downloads `mix_sbom_${runner.os}_${runner.arch}` and runs `gh attestation verify` [VERIFIED: action.yml].
- **Hex checksum.** The Hex API `checksum` equals `sha256sum` of the release tarball [VERIFIED: phoenix 1.8.16 API checksum `e7355c35…` equals the local `~/.hex/packages/hexpm/phoenix-1.8.16.tar` sha256].
- **Environment secrets across the reusable call.** "a secret can be passed by name even if it exists only in the environment", and "The job that calls the reusable workflow can't use the `environment` keyword" [CITED: docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows]. D-08's pass-by-name plus `environment: hex-production` in the called job is therefore a supported shape.

### Pattern 8: release-please config (shape verified against oarlock's live releases)
```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "elixir",
  "bump-minor-pre-major": true,
  "bump-patch-for-minor-pre-major": true,
  "draft": true,
  "force-tag-creation": true,
  "packages": {
    ".": { "changelog-path": "CHANGELOG.md", "include-v-in-tag": true, "release-as": "0.1.0" }
  }
}
```
`.release-please-manifest.json`: `{".": "0.0.0"}`.
- oarlock uses the same root-package shape without `package-name` and produced tags `v0.1.0`, `v0.1.1`, `v0.1.2` and the branch `release-please--branches--main` [VERIFIED: gh api on szTheory/oarlock]. Don't add `package-name`, because a component could change the tag format and break D-11's `^v\d+\.\d+\.\d+$` [ASSUMED].
- `draft` and `force-tag-creation` are taken as verified per CONTEXT D-09. Their combined behaviour gets its first real exercise on the 0.1.0 release.

### Pattern 9: `.credo.exs` (keys verified in Credo 1.7.19 source)
```elixir
%{
  configs: [
    %{
      name: "default",
      files: %{included: ["lib/", "test/", "credo/", "mix.exs"], excluded: [~r"/_build/", ~r"/deps/", "test/fixtures/"]},
      requires: ["credo/checks/*.ex"],
      strict: true,
      checks: %{
        extra: [
          {Credo.Check.Warning.UnsafeToAtom, []},
          {Credo.Check.Warning.MixEnv, [files: %{excluded: ["lib/fablebook/router.ex"]}]},
          {Credo.Check.Warning.ForbiddenModule, [modules: [EEx, Jason, Floki, MDEx, YamlElixir, Telemetry.Metrics]]},
          {Fablebook.Credo.BannedCalls, [files: %{included: ["lib/", "mix.exs"]}]}
        ]
      }
    }
  ]
}
```
- Verified in the Credo source: `checks: %{extra: …}`, the per-check `files: %{included:, excluded:}` (`Credo.Check.Params.files_excluded/2`, `files_included/3`) and `requires:` (`config_file.ex`).
- `MixEnv` and `UnsafeToAtom` sit in Credo's own disabled list by default [VERIFIED: deps/credo/.credo.exs:208-209].
- Scope the custom check to `lib/` and `mix.exs`, not `test/`, because the contract tests hold the ban atoms as data.

### Pattern 10: dependency-budget prod closure
```elixir
# Every fetched dep's deps/<name>/hex_metadata.config has "requirements" as a LIST of proplists on current
# packages (24/24 checked, including rebar3-built telemetry). Handle the legacy map form defensively [ASSUMED].
reqs = fn name ->
  {:ok, meta} = :file.consult(Path.join(["deps", name, "hex_metadata.config"]))
  case :proplists.get_value("requirements", meta) do
    l when is_list(l) -> for r <- l, :proplists.get_value("optional", r) == false, do: :proplists.get_value("app", r)
    m when is_map(m) -> for {n, r} <- m, r["optional"] == false, do: r["app"] || n
  end
end
```

### Anti-Patterns to Avoid
- **Hoisting `Mix.env()` into a module attribute** in `Fablebook.Router`. Fablebook compiles as a dep in `:prod`, so every dev mount would raise (D-01).
- **`only: :dev` for tools that `mix ci` runs.** `mix ci` must be `:test` (Pitfall 3).
- **`MIX_ENV=test mix test` inline in a `run:` step.** actionlint's shellcheck flags SC2209 [VERIFIED: actionlint run]. Use step `env:` instead.
- **Relying on default ExUnit timeouts for nested-mix tests.** The default is 60000 ms [VERIFIED: `ExUnit.configuration()[:timeout]` = 60000].
- **Caching in the publishing workflow.** Pass `cache: 'false'`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| YAML validation of workflows | A YAML parser in tests | actionlint and zizmor containers (D-18) | The line scanner checks only the restricted dialect; semantic validity belongs to real parsers. |
| Floor lock resolution | Hand-edited `mix.lock` entries with checksums | `MIX_EXS` pinned copy plus `mix deps.get` (Pattern 2) | Checksums and transitive constraints are Hex's job. |
| Publishing the built tarball | Uploading the `.tar` via the Hex API | `mix hex.publish --yes` with Hex 2.6.0 reproducible builds, plus the checksum comparison | Hex has no "publish this prebuilt tarball" path in the CLI [ASSUMED]; the checksum comparison detects non-reproducibility. |
| SBOM | `sbom` Hex dep or a custom CycloneDX writer | `erlef/mix_sbom` action (D-12) | Attestation-verified binary; no lockfile churn. |
| Percentile maths in YAML | Inline 40-line jq in ci.yml | `bin/ci_health` (bash, `gh`, `jq`) | Keeps ci.yml under the cap and runs locally. |
| Release versioning | Tag scripts | release-please (elixir strategy updates `@version` in `mix.exs`) | Locked by ADR 0017 and the bootstrap skill. |

**Key insight:** every "guard" in this phase is a small pure function over files that already exist (git diff output, BEAM chunks, `hex_metadata.config`, workflow text). The hard-to-get-right parts are the environment around them: nested Mix envs, test-path filters, pinned-linter disagreements and GitHub settings order. That is where this research spent its verification budget.

## Common Pitfalls

### Pitfall 1: zizmor 1.31.1 and actionlint 1.7.12 disagree about local `uses:`
**What goes wrong:** with `./.github/actions/setup` and `./.github/workflows/hex-publish.yml`, zizmor reports seven `help[self-repository]` findings and exits 12, so `security` fails. Switching to `$/…` makes actionlint fail: `specifying action "$/.github/actions/setup" in invalid format because ref is missing`. [VERIFIED: both pinned images run locally on the drafts]
**Why:** GitHub added `$/` self-repository references (changelog 2026-07-30, runner ≥ 2.336.0) [CITED: github.blog/changelog/2026-07-30-reference-same-repository-actions-with-self-repository-syntax]. zizmor added the audit in v1.30.0 [CITED: docs.zizmor.sh/audits/#self-repository]. actionlint's last release (1.7.12, 2026-03-30) predates the syntax.
**How to avoid:** keep `./` (D-17's dialect) and commit `.github/zizmor.yml`:
```yaml
rules:
  self-repository:
    disable: true
```
With it, zizmor exits 0 [VERIFIED: local]. Add the file to the shape test's day-1 `.github/**` inventory. Revisit when actionlint learns `$/`.
**Warning signs:** `security` red on the first PR, with `help[self-repository]`.

### Pitfall 2: Elixir 1.19+ `mix test --warnings-as-errors` aborts on fixture files under `test/`
**What goes wrong:** `warning: the following files do not match any of the configured :test_load_filters / :test_ignore_filters`, then `ERROR! Test suite aborted … due to warnings`, exit 1 [VERIFIED: 1.20.4 local].
**Why:** since 1.19, any file under `test/` that is neither loaded nor ignored warns [VERIFIED: `mix help test`, "In Elixir versions earlier than 1.19.0, this option defaulted to `*_test.exs`"].
**How to avoid:** `test_ignore_filters: [&String.starts_with?(&1, "test/fixtures/")]` in `project/0`. Verified clean on 1.20.4 and on 1.18.4, where it is harmless.

### Pitfall 3: `mix ci` and tool `only:` envs
**What goes wrong:**
- Running `mix ci` in `:dev` fails because `mix test` refuses to run under an alias in the dev env [VERIFIED: local error text recommends `preferred_envs`].
- With `def cli, do: [preferred_envs: [ci: :test]]`, `credo` declared `only: :dev` gives `The task "credo" could not be found` [VERIFIED: local].

**How to avoid:** `only: [:dev, :test]` for credo and ex_doc. D-26's rule ("every other dep must have an `only:` that excludes `:prod`") is satisfied. D-26's prose example `only: :dev` is still right for dialyxir, tailwind and esbuild, which `mix ci` never runs.

### Pitfall 4: Dialyzer `unknown_function Mix.env/0`
**What goes wrong:** `lib/router.ex:4:12:unknown_function Function Mix.env/0 does not exist.`, exit 2 [VERIFIED: local dialyxir 1.4.8].
**How to avoid:** `dialyzer: [plt_add_apps: [:mix], plt_local_path: "priv/plts", plt_core_path: "priv/plts"]`. That passes [VERIFIED]. The PLT filename embeds OTP, Elixir and env (`dialyxir_erlang-29.1.1_elixir-1.20.4_deps-dev.plt`), so the cache key must include `.tool-versions` and `mix.lock`. Pattern 5 does this.

### Pitfall 5: nested `mix` inherits the parent's environment
**What goes wrong:**
- Locally, `mix test` does **not** export `MIX_ENV`, so a nested `mix` without an override runs in `dev`.
- In CI, the job sets `MIX_ENV=test`, so the same nested call runs in `test` [VERIFIED: both observed].
- `MIX_EXS`, `MIX_LOCKFILE`, `MIX_BUILD_PATH`, `MIX_BUILD_ROOT`, `MIX_DEPS_PATH`, `MIX_TARGET` and `FABLEBOOK_UNGUARDED` leak the same way if a developer or a CI step sets them.

**How to avoid:**
- Always pass `MIX_ENV` explicitly and unset the rest (Pattern 3 helper; `System.cmd` treats `{"VAR", nil}` as unset).
- Set `@moduletag timeout: 600_000` on nested-mix tests (the default is 60 s).
- Keep the test `async: false`.
- Give fixture builds their own `build_path` so no build lock is shared with the outer `_build/test`. Verified: no deadlock, about 8 s per lane.
- Nested `--warnings-as-errors` is meaningful on warm builds because `mix compile --all-warnings` defaults to true and re-reports earlier warnings [VERIFIED: `mix help compile.elixir`, 1.20.4].

### Pitfall 6: Credo `MixEnv` `excluded_paths` matches directories, not files
**What goes wrong:** `excluded_paths: ["lib/fablebook/router.ex"]` never matches, because the check compares `Path.dirname(filename)` with `String.starts_with?` [VERIFIED: deps/credo/lib/credo/check/warning/mix_env.ex:66-73]. Using `"lib/fablebook"` would exempt the whole directory, violating D-03's "only exemption".
**How to avoid:** use the generic per-check `files: %{excluded: ["lib/fablebook/router.ex"]}` (Pattern 9).

### Pitfall 7: D-17 bans `uses: ./.github/workflows/` in all three files, but D-08 needs it in `release-please.yml`
**What goes wrong:** read literally, "Rejected anywhere in the 3 files: … `uses: ./.github/workflows/`" fails `release-please.yml`'s `uses: ./.github/workflows/hex-publish.yml` [VERIFIED: 01-CONTEXT.md:139-144 vs 72-75].
**How to avoid:** the planner should implement the evident intent: ban it in `ci.yml` (alongside `workflow_call` in `ci.yml`), and in `release-please.yml` allow exactly `./.github/workflows/hex-publish.yml`. Record this reading in the plan. It is a clarification, not a new decision, but flag it at the D-21 sign-off checkpoint so the owner sees it.

### Pitfall 8: "schedule-only jobs" vs the nightly exception in ci-gate
**What goes wrong:**
- D-17 says ci-gate `needs` excludes "the declared schedule-only jobs", and D-30 calls both `nightly` and `ci-health` schedule-only.
- D-17 also gives `nightly` a `skipped`-is-allowed exception, which only makes sense if nightly **is** in `needs`.
- ADR 0017 requires the release PR to be gated on the nightly suite [CITED: docs/adr/0017-ci-cd-layout.md].

**How to avoid:** declared schedule-only set = {`ci-health`}. `nightly` is in `needs` with the skip exception (Pattern 5 does this).

### Pitfall 9: the literal ADR-form rule fails on today's corpus
**What goes wrong:** a prototype of D-19 over tracked files finds 7 tracked occurrences of non-canonical ADR forms, and 1 more in the untracked `.claude/CLAUDE.md`:
- `ADRs 0014–0017`, `ADRs 0001 to 0025`, `ADRs 0003/0004/…`, `ADRs 0005, 0006, …`;
- `ADR-0002` in `docs/research/OWNER-DNA.md:119`.

INT ids are all valid and existing; trailing `:` and `'s` after a full id are punctuation, not malformed ids. [VERIFIED: local Elixir scan of `git ls-files` output]
**How to avoid:**
- Define "other ADR forms" as the singular non-canonical forms (`ADR-\d`, `ADR\d`, `ADR #\d`, `ADR \d{1,3}\b`, `ADR \d{5,}`).
- Validate every 4-digit number inside an `ADRs …` list against `docs/adr/`.
- Normalize `ADR-0002` to `ADR 0002` in the Phase 1 PR. It is not an intent source, so editing it is legal.
- Write the malformed-INT regex as `\bINT-\d(?!\d{7}-\d{2}\b)`.

### Pitfall 10: `.claude/CLAUDE.md` is gitignored
**What goes wrong:** D-19 scans "both CLAUDE.md files", but `.gitignore:22` is `/.claude/` [VERIFIED: .gitignore:22], so the file never exists in CI. A local run would scan content CI never sees, so local and CI results diverge.
**How to avoid:** scan the root `CLAUDE.md` and scan `.claude/CLAUDE.md` only if it exists, or scan only `git ls-files` paths. Recommend the latter for parity. The file is also regenerated by GSD tooling, so it is not owner-authored text.

### Pitfall 11: the floor lane can silently stop being the floor
**What goes wrong:** `FABLEBOOK_FLOOR=1 mix deps.get --check-locked` passes even if someone regenerates `mix.floor.lock` at Phoenix 1.8.16, because 1.8.16 satisfies `>= 1.8.9`.
**How to avoid:** under `FABLEBOOK_FLOOR`, a test asserts `Application.spec(:phoenix, :vsn) == ~c"1.8.9"` and `Application.spec(:phoenix_live_view, :vsn) == ~c"1.2.9"`, with the versions parsed from the `>= X and` requirement strings in `mix.exs`. Put it in `dependency_budget_test.exs`, which runs on both lanes.

### Pitfall 12: shared `deps/` thrashes between lanes locally
**What goes wrong:** `FABLEBOOK_FLOOR=1 mix deps.get` rewrites `deps/phoenix` to 1.8.9. The next plain `mix test` then fails with `lock mismatch … Can't continue due to errors on dependencies` until `mix deps.get` is run again [VERIFIED: local]. CI is unaffected (one lane per job).
**How to avoid:** document `mix deps.get` when switching lanes. Optionally, under the floor flag set `deps_path: "deps_floor"` in both `mix.exs` files and gitignore it. That costs config lines; not recommended unless it bites.

### Pitfall 13: GitHub-side ordering traps
- **`RELEASE_PLEASE_TOKEN` must exist before PR #1 merges.** That merge adds `release-please.yml` and immediately runs it with no fallback (D-10).
- **`hex-production` with `HEX_API_KEY` must exist before the release PR merges.**
- **The ruleset can be created before PR #1.** The PR run reports `ci-gate` from the GitHub Actions app (15368). It must be created **after** the initial push of the existing history, because the required check would block a direct push.
- **Push to `main` with `github.event.before` all zeros** (new branch, or force-push): the D-19 seam must treat it as unresolvable. That means raise in CI (honest), or fall back to merge-base. Decide in the plan.
- **"Require full-length SHA pins".** I could not confirm whether it inspects `docker://` refs and local `./` actions [ASSUMED: allowed]. Enable it before PR #1's first run so that run proves it.

### Pitfall 14: release-flow details that only the first release can prove
- **`gh release upload "$TAG"` on a draft.** `GET /releases/tags/{tag}` is documented not to return drafts. Whether `gh` falls back to listing releases is unconfirmed [ASSUMED]. Fallback: look up the draft's id with `gh api repos/$R/releases --jq '.[] | select(.draft and .tag_name==env.TAG) | .id'` and upload through the API.
- **The Hex revert window for a new package is 24 hours** (1 hour for a new version of an existing package) [CITED: .planning/research/PITFALLS.md Pitfall 26, from Hex docs]. D-13's "within the hour" is stricter than needed for 0.1.0, which is fine.
- **A fresh `MIX_HOME`/`HEX_HOME` in `smoke`** needs `mix local.hex --force && mix local.rebar --force` before `mix archive.install hex phx_new 1.8.16 --force`.
- **The `phx.new` 1.8.16 router template** puts the `dev_routes` block as `if Application.compile_env(:<app>, :dev_routes) do … scope "/dev" do pipe_through :browser … live_dashboard … end end` [VERIFIED: phx_new-1.8.16 tarball `templates/phx_web/router.ex.eex:33-48`]. Insert `import Fablebook.Router` and `fablebook "/fablebook", <App>Web.Storybook` after the `pipe_through` line. The Book module need not exist (runtime-only dependency, D-02). The generated app has a `heroicons` GitHub dep, so the smoke needs network access to github.com.

### Pitfall 15: formatter output differs across Elixir minors
Run `format --check-formatted` only on the latest lane (inside `mix ci`). The floor job must not run it [ASSUMED: 1.18 and 1.20 formatters can differ on edge constructs; cheap to avoid].

## Code Examples

### D-06 driver (sketch using the verified helper)
```elixir
# Source: scratchpad fl/test/prod_guard_test.exs, passed on 1.20.4 and 1.18.4 (floor lock)
@fixture Path.expand("../fixtures/prod_guard_host", __DIR__)
@moduletag :prod_guard
@moduletag timeout: 600_000

test "a false dev_routes mount compiles in prod; an unguarded mount raises the canonical error" do
  {_, 0} = MixCmd.run(@fixture, "dev", ~w(compile --warnings-as-errors))
  {routes, 0} = MixCmd.run(@fixture, "dev", ~w(phx.routes GuardHostWeb.Router))
  assert routes =~ "/dev/fablebook"
  {_, 0} = MixCmd.run(@fixture, "prod", ~w(compile --warnings-as-errors))
  {routes, 0} = MixCmd.run(@fixture, "prod", ~w(phx.routes GuardHostWeb.Router))
  refute routes =~ ~r/fablebook/i
  {out, code} = MixCmd.run(@fixture, "prod", ~w(compile --warnings-as-errors), [{"FABLEBOOK_UNGUARDED", "1"}])
  assert code != 0
  assert out =~ "(CompileError) unguarded/"
end
```

### `bin/ci_health` core (nearest rank)
```bash
# p-th percentile, nearest rank, over sorted durations (seconds); n<10 → not-run
jq -n --argjson d "$durations" --argjson p 50 '($d|sort) as $s | ($s|length) as $n
  | if $n < 10 then "not-run (n=\($n))" else $s[((($p*$n)/100)|ceil)-1] end'
```
- Runs come from `gh api "repos/$GITHUB_REPOSITORY/actions/workflows/ci.yml/runs?event=pull_request&created=>=$SINCE" --paginate`, filtered to `run_attempt == 1` and `head_branch` not starting with `release-please--`.
- For each run, find job `ci-gate` with conclusion `success` or `failure` in `/actions/runs/{id}/jobs`.
- Duration = `completed_at - run.created_at`.
- Ruleset check: `gh api repos/$R/rules/branches/main --jq '[.[] | select(.type=="required_status_checks") | .parameters.required_status_checks[].context]'` must equal `["ci-gate"]`.
- These field names are [ASSUMED] from the REST schema; verify with `gh workflow run ci.yml` (dispatch) once the repo has runs.

## Human-Action Checkpoints and Ordering

The agent's `gh` token has the `repo` and `workflow` scopes for `szTheory` [VERIFIED: `gh auth status`], so most settings can be scripted. Secret **values** and owner judgments cannot.

| Order | Step | Who | Blocking for | Command / note |
|------|------|-----|-------------|----------------|
| 1 | Owner sign-offs: D-16 (ADR 0007 and COMPAT-01 ranges and lanes), D-12, D-21 (with the Pitfall 7 and 8 readings), D-26, D-27, D-31 | **checkpoint:decision** | Writing `mix.exs` and the ADR amendments in PR #1 | Record each as an add-only INT source; strike the OPEN-QUESTIONS rows |
| 2 | Confirm making the repo public with `.planning/` and intent sources (no PII was found by the D-28-style scan; intent uses `~/`) | **checkpoint:human-verify** | Step 3 | — |
| 3 | Create the repo and push the existing history | agent (authorized in step 2) | Everything on GitHub | `gh repo create szTheory/fablebook --public --source=. --remote=origin --push` |
| 4 | Repo settings (D-15) | agent | PR #1's first CI run | `gh api -X PUT repos/$R/actions/permissions/workflow -f default_workflow_permissions=read -F can_approve_pull_request_reviews=false`; `gh api -X PUT repos/$R/actions/permissions -F enabled=true -f allowed_actions=all -F sha_pinning_required=true`; `gh api -X PUT repos/$R/immutable-releases` [CITED: docs.github.com REST, `enabled` required, `sha_pinning_required` optional; immutable-releases PUT] |
| 5 | Ruleset on `main` | agent | Merging PR #1 | `gh api -X POST repos/$R/rulesets --input ruleset.json` with `{"name":"main","target":"branch","enforcement":"active","conditions":{"ref_name":{"include":["~DEFAULT_BRANCH"],"exclude":[]}},"rules":[{"type":"required_status_checks","parameters":{"strict_required_status_checks_policy":false,"required_status_checks":[{"context":"ci-gate","integration_id":15368}]}}]}` [ASSUMED: body shape per REST docs; verify with `gh api repos/$R/rules/branches/main`] |
| 6 | Labels `quality-regression`, `ci-timing`; create and pin the `ci-timing` issue | agent | First `ci-health` run | `gh label create …`; `gh issue create …`; `gh issue pin …` |
| 7 | Create the fine-grained PAT `RELEASE_PLEASE_TOKEN` (this repo only; Contents, Pull requests and Issues read/write) and set an expiry reminder | **checkpoint:human-action** | Merging PR #1 | `gh secret set RELEASE_PLEASE_TOKEN --repo $R` (value pasted by the owner) |
| 8 | `hex-production` environment: custom branch policies `main` (branch) and `v*` (tag); no reviewers | agent | Merging the release PR | `gh api -X PUT repos/$R/environments/hex-production --input -` with `{"deployment_branch_policy":{"protected_branches":false,"custom_branch_policies":true}}`, then `POST …/deployment-branch-policies -f name=main -f type=branch` and `-f name='v*' -f type=tag` [CITED: docs.github.com deployment branch policies; custom policies must be enabled first] |
| 9 | Generate a Hex `api:write` key and set it as an environment secret | **checkpoint:human-action** | Merging the release PR | `gh secret set HEX_API_KEY --env hex-production --repo $R` |
| 10 | D-22 throwaway draft PR editing an INT source: capture the red run link, close unmerged | agent | Phase evidence | After PR #1 merges |
| 11 | Merge PR #1 (green ci-gate) | agent | Release PR #2 | release-please opens `chore(main): release 0.1.0`; verify the title says 0.1.0 |
| 12 | Merge release PR #2 after its CI (including nightly) is green | agent, after **checkpoint:human-verify** of the PR contents | Publish | Watch `hex-publish` build, publish, smoke, finalize |
| 13 | Rotate to a `fablebook`-scoped Hex key | **checkpoint:human-action** | Future releases | Replace the env secret |
| 14 | PR #3: remove `release-as` | agent | Phase end (merged green PR) | Evidence: CI link, hex.pm page, release with `fablebook-0.1.0.cdx.json` |

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `./` local `uses:` | `$/` self-repository references (recommended by GitHub; `./` still works) | July 2026 | zizmor flags `./`; actionlint can't parse `$/` yet (Pitfall 1). |
| Test-path files default to `*_test.exs` silently | Non-matching files under `test/` warn (abort under `--warnings-as-errors`) | Elixir 1.19 | `test_ignore_filters` is required (Pitfall 2). |
| Hex 2.5.x | Hex 2.6.0 (2026-10-23): reproducible builds; trusted publishing beta | Oct 2026 | Pin it for publish; checksum idempotency depends on it. |
| `mix_audit` | `mix hex.audit` (advisories since 2.5.1) | 2026 | D-27. |

**Deprecated/outdated:** the bootstrap skill's `default_workflow_permissions=write`, `bump-minor-pre-major: false`, `.tool-versions` 1.19.5/28.5 and the 24-hour scheduled smoke routine are all overridden by CONTEXT (D-09, D-13, D-15, D-16).

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The SHA-pinning repo policy accepts `./` local actions and `docker://…@sha256` steps | Pitfall 13 | First CI run fails at workflow load; fix: adjust the policy or the step form. Low cost, caught on day 1. |
| A2 | `gh release upload <tag>` finds a draft release by tag | Pitfall 14, Pattern 7 | SBOM upload fails in `build`; use the release-id fallback. Caught on the first release before publish. |
| A3 | Ruleset JSON body shape as written | Checkpoints step 5 | `gh api` returns 422; adjust the body. |
| A4 | `hex_metadata.config` may use a legacy map form for `requirements` on old packages | Pattern 10 | None if handled defensively. |
| A5 | Adding `package-name` could change the tag format | Pattern 8 | Only if someone adds it. |
| A6 | `ci-health` REST field names (`run_attempt`, `head_branch`, job `completed_at`) | Code Examples | Script error on the first dispatch; fix in the same PR. |
| A7 | Formatter output may differ between 1.18 and 1.20 | Pitfall 15 | None (mitigated by not formatting on floor). |
| A8 | The Hex CLI cannot publish a prebuilt tarball | Don't Hand-Roll | None; the checksum comparison covers it. |
| A9 | setup-beam `version-file: .tool-versions` accepts `elixir 1.20.4-otp-29` | Pattern 6 | The core job fails at setup; switch to explicit `otp-version`/`elixir-version` inputs. Caught on day 1. |

## Open Questions

1. **Why OTP 27.3.4.9 for the floor lane rather than the newest 27.3.4.19?**
   - What we know: both exist on builds.hex.pm. D-16 locks 27.3.4.9.
   - What's unclear: whether `.9` was deliberate (the oldest patch to claim) or arbitrary.
   - Recommendation: keep it as locked; ask at the D-16 sign-off.
2. **Pin all five runtime deps at their floors in `mix.floor.lock`?**
   - What we know: they resolve (phoenix_html 4.1.0, telemetry 1.0.0, nimble_options 1.1.0 with Phoenix 1.8.9 and LiveView 1.2.9).
   - Recommendation: optional; it strengthens the declared-range evidence. Decide at the D-16 sign-off.
3. **Push to `main` with a zero `before` SHA.** Raise in CI or fall back to merge-base? Recommendation: fall back to merge-base only when `before` is all zeros, and print the reason.
4. **`exclude-paths` in the release-please config** (PITFALLS Pitfall 26: tooling commits trigger phantom releases). Recommendation: add `.planning`, `docs` and `bench` now; not locked, so it's the planner's call.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Elixir latest | Local dev on latest lane | ✓ (close) | 1.20.4-otp-29 installed; **OTP 29.1.1** installed, not 29.1.2 | `asdf install erlang 29.1.2` (human, local only; CI uses setup-beam) |
| Elixir floor | Local floor runs | ✓ (close) | 1.18.4-otp-27 with OTP 27.3.4.15; not 1.18.5 / 27.3.4.9 | CI floor job is authoritative |
| gh CLI | Repo creation, settings, ci-health locally | ✓ | 2.101.0, scopes repo and workflow | — |
| docker | Local actionlint/zizmor parity | ✓ | 29.5.2 (daemon up) | Run the pinned images exactly as CI does |
| actionlint | Local lint | ✓ | 1.7.12 (Homebrew) | docker image |
| zizmor | Local lint | ✗ native | — | docker image (verified) |
| jq | ci-gate, ci_health | ✓ | system | — |
| Hex (local) | Local `hex.build` | ✓ | 2.5.1, with an expired auth session warning (harmless for build) | `mix local.hex 2.6.0 --force` |
| GitHub repo | Everything CI | ✗ | 404 | Checkpoint step 3 |
| hex.pm `fablebook` | Name reservation | free | 404 on 2026-10-28 | — |

**Missing dependencies with no fallback:** none that block planning. The GitHub repo is created in-phase.
**Missing dependencies with fallback:** OTP 29.1.2 locally; native zizmor.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | ExUnit (Elixir 1.20.4 latest lane, 1.18.5 floor lane) |
| Config file | `test/test_helper.exs` (Wave 0), `mix.exs` `test_ignore_filters` |
| Quick run command | `mix test` (excludes `:prod_guard` and `:release`; fast guards only) |
| Full suite command | `mix ci` (format, unlock check, compile warnings-as-errors, credo strict, xref, docs, `test --include prod_guard --include release`) |
| Floor command | `FABLEBOOK_FLOOR=1 mix deps.get && FABLEBOOK_FLOOR=1 mix test --warnings-as-errors --include prod_guard` |

### Phase Requirements → Test Map
| Req / SC | Behavior | Type | Automated Command | Negative fixture (must fail) | Only provable by CI link? | File Exists? |
|----------|----------|------|-------------------|------------------------------|---------------------------|-------------|
| SEC-02 / SC2 | False `dev_routes` mount compiles in prod; unguarded raises the canonical error once; no routes, no story beams | integration (nested mix) | `mix test test/contract/prod_guard_test.exs --include prod_guard` | `unguarded/router.ex` (built in); positive controls 1–3 guard against vacuous passes | Both lanes in CI: `core` and `floor` job links | ❌ Wave 0 |
| SEC-02 / D-04 | First line equals the Troubleshooting heading; full-text snapshot | unit | `mix test test/contract/prod_guard_message_test.exs` | Snapshot mismatch | — | ❌ Wave 0 |
| SEC-01 partial / SC4 | No eval, atom creation, runtime EEx/TagEngine compile or banned dep in `lib/` beams | unit (BEAM scan) | `mix test test/contract/banned_calls_test.exs` | `test/fixtures/guards/*.ex`, 8 forms compiled to `tmp_dir` | — | ❌ Wave 0 |
| SEC-01 partial | Credo source bans, `credo:disable` scan, `mix.exs` text scan | lint + unit | `mix credo --strict` and the banned_calls test | A guard fixture run through `mix credo` with `--files-included` | — | ❌ Wave 0 |
| SEC-01 partial | No `style=` in `lib/` | unit (text scan) | `mix test test/contract/style_attr_test.exs` | Inline string fixtures for each regex | — | ❌ Wave 0 |
| SC4 | Banned dep in the prod closure, a bad direct dep or a wrong `only:` fails | unit | `mix test test/contract/dependency_budget_test.exs` | Synthetic deps lists and metadata maps passed to the pure functions | Floor-version assertion proven in the `floor` job | ❌ Wave 0 |
| SC4 / REL-01 | File outside the tarball allowlist fails; metadata matches; no PII | integration (`hex.build --unpack`) | `mix test test/contract/tarball_test.exs --include release` | Pure checker fed a file list with `test/x.exs`, `.DS_Store` and a `/Users/` string | Rerun on the tag in `hex-publish` `build` | ❌ Wave 0 |
| CI-01 / SC3 | 4th workflow, >250 lines, missing or extra ci-gate, unpinned uses, `paths:`, bypasses, Node, phase names all fail | unit (line scanner) | `mix test test/contract/ci_shape_test.exs` | `test/fixtures/ci_shape/*.yml`, one per rule | Real ci-gate behaviour: PR #1 green link | ❌ Wave 0 |
| CI-01 | Workflows are valid and secure | lint | actionlint and zizmor containers in `security` | — | `security` job link | n/a |
| CI-01 / SC3 | PR p50/p95 published weekly | scheduled job | `gh workflow run ci.yml` (dispatch fires ci-health) | n<10 prints `not-run (n=K)` | **Yes**: a ci-health run link and the ci-timing issue comment | ❌ Wave 0 (`bin/ci_health`) |
| CI-01 | Ruleset requires exactly `ci-gate` | scheduled assertion | part of ci-health | Drift opens quality-regression | **Yes** | ❌ |
| INTENT-01 / SC3 | Edited INT source, malformed INT id, uncited REQ line, unknown ADR all fail | unit + git diff | `mix test test/planning/intent_test.exs` | Synthetic corpora in `tmp_dir` (pure functions); diff-status lists `[{"M", ".planning/intent/sources/…"}]` | **Yes**: D-22 red-run link from the throwaway PR | ❌ Wave 0 |
| D-21 | Guard `M`/`D` plus a paired implementation change fails | unit | `mix test test/planning/contract_rule_test.exs` | Status lists `[{"M","test/contract/x_test.exs"},{"A","lib/y.ex"}]` | — | ❌ Wave 0 |
| REL-01 / SC1 | 0.1.0 on hex.pm via release-please; smoke; recovery; SBOM | e2e (release) | Not a unit test. Pre-publish: `bin/smoke_consumer --path <unpacked>` locally | Checksum mismatch path: dispatch `hex-publish` with an existing tag and the same sha gives a skip | **Yes**: hex-publish run link, hex.pm page, release asset `fablebook-0.1.0.cdx.json` | ❌ |
| COMPAT (floor) | Floor lane really runs Phoenix 1.8.9 / LiveView 1.2.9 | unit | Inside the budget test under `FABLEBOOK_FLOOR` | Lock regenerated at latest gives a failing assertion | `floor` job link | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `mix test` (fast guards), plus the specific file under work.
- **Per wave merge:** `mix ci` locally plus a push to the draft PR (CI is the real gate).
- **Phase gate:** green `ci-gate` on PR #1, D-22 red link, release-PR green including `nightly`, the hex-publish run link, and PR #3 merged green.

### Wave 0 Gaps
- [ ] `mix.exs`, `.formatter.exs`, `mix.lock`, `mix.floor.lock`, `test/test_helper.exs`: framework bootstrap.
- [ ] `test/support/mix_cmd.ex`, `test/support/git_diff.ex`, `test/support/beam_walker.ex`: shared helpers.
- [ ] `test/fixtures/{prod_guard_host,guards,ci_shape}/`: negative and positive fixtures.
- [ ] `test_ignore_filters` set before the first `mix test --warnings-as-errors`.

## Security Domain

`security_enforcement: true`, ASVS level 1 [VERIFIED: .planning/config.json via cat].

### Applicable ASVS Categories
| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no (no user auth in 0.1.0) | — |
| V3 Session Management | no | — |
| V4 Access Control | yes (prod exposure) | Compile-time prod guard (D-01) plus the `dev_routes` mount convention |
| V5 Input Validation | yes (future), enforced structurally now | BEAM ban walker plus Credo (no eval, no atoms from input) |
| V6 Cryptography | no | — |
| V10 Malicious Code / V14 Config (supply chain) | yes | SHA-pinned actions, digest-pinned images, zizmor, `hex.audit`, dependency budget, tarball allowlist, SBOM, immutable releases, least-privilege `permissions:` |

### Known Threat Patterns for this stack
| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Workbench mounted in a prod build | Elevation of privilege / information disclosure | Macro raises in prod (returned quote); CI prod build asserts no routes and no story beams |
| Runtime eval / atom exhaustion via input | Tampering / DoS | Compiled-BEAM atom and MFA tiers; Credo `UnsafeToAtom`, `ForbiddenModule` and the custom check |
| Template injection in workflows | Tampering | `${{ }}` only in `env:`, never in `run:` (D-19); zizmor `template-injection` |
| Mutable action refs / impostor commits | Tampering | 40-hex pins plus the SHA-pin policy; zizmor online mode (`GH_TOKEN`) runs the impostor-commit audit |
| Cache poisoning into a release | Tampering | `cache: 'false'` in `hex-publish.yml`; saves only on `main` |
| Credential persistence in checkout | Information disclosure | `persist-credentials: false` everywhere |
| Leaked publish key | Spoofing | Environment-scoped `HEX_API_KEY`, deployment policy `main` and `v*`, rotation to a package-scoped key after 0.1.0 |
| PII in the package | Information disclosure | Tarball PII scan (`/Users/`, `/home/`, email patterns) |

## Sources

### Primary (HIGH confidence)
- hex.pm API: package and release endpoints for phoenix (1.8.9, 1.8.16), phoenix_live_view (1.2.9, 1.2.13), phoenix_html, telemetry, nimble_options, credo, dialyxir, ex_doc and fablebook (404); the phoenix 1.8.16 `checksum`.
- builds.hex.pm `otp/ubuntu-24.04/builds.txt` and `elixir/builds.txt`.
- GitHub API: tag refs for actions/checkout, actions/cache, erlef/setup-beam, googleapis/release-please-action, erlef/mix_sbom (annotated tag dereferenced), actions/dependency-review-action; `/apps/github-actions`; oarlock tags, branches and `release-please-config.json`; `repos/hexpm/hex/releases`.
- `erlef/mix_sbom` `action.yml` at `96bb84f8e9e72361bfad4142d666dfa2c0838ac2`.
- Docker registries: `rhysd/actionlint:1.7.12` and `ghcr.io/zizmorcore/zizmor:1.31.1` index digests.
- Local prototypes (scratchpad `fl/`, `v20/`, `wf/`, `exp/`): Elixir 1.20.4/OTP 29.1.1 and 1.18.4/OTP 27.3.4.15; dialyxir 1.4.8; Credo 1.7.19 source; Hex 2.5.1 `hex.build`.
- `mix help test`, `mix help compile.elixir`, `mix help local.hex`, `mix help compile` (1.18.4).
- phx_new 1.8.16 tarball `templates/phx_web/router.ex.eex`.

### Secondary (MEDIUM confidence)
- [GitHub REST: Actions permissions](https://docs.github.com/en/rest/actions/permissions?apiVersion=2022-11-28): `enabled` required; `sha_pinning_required`; workflow default permissions.
- [GitHub REST: immutable releases](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#enable-immutable-releases).
- [GitHub REST: deployment branch policies](https://docs.github.com/en/rest/deployments/branch-policies?apiVersion=2022-11-28#create-a-deployment-branch-policy).
- [GitHub Docs: reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows): environment secrets passed by name; caller cannot use `environment`.
- [GitHub changelog 2026-07-30: self-repository syntax](https://github.blog/changelog/2026-07-30-reference-same-repository-actions-with-self-repository-syntax); also the [2026-07-01](https://github.blog/changelog/2026-07-01-reference-same-repository-actions-with-self-repository-syntax/) and [2026-07-21](https://github.blog/changelog/2026-07-21-reference-same-repository-actions-with-self-repository-syntax/) entries.
- [zizmor audits: self-repository](https://docs.zizmor.sh/audits/#self-repository).

### Tertiary (LOW confidence)
- [ittrip.xyz guide on `$/` syntax](https://en.ittrip.xyz/tool/github-actions-self-ref) and [MongoDB DRIVERS-3596](https://jira.mongodb.org/browse/DRIVERS-3596): secondary commentary only.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH. Every version, SHA and digest was resolved from the source this session.
- Architecture: HIGH for the local mechanics (prod guard, floor lock, BEAM walker, lint-clean drafts); MEDIUM for GitHub-side release behaviour (A1, A2, A3, A6), which only the first real runs prove.
- Pitfalls: HIGH. Pitfalls 1–6, 9–12 and 14 (phx.new template) were reproduced locally; 7 and 8 are textual contradictions inside CONTEXT.

**Research date:** 2026-10-28
**Valid until:** about 2026-11-11 for pins (14 days; Hex 2.6.0, zizmor and websock_adapter are all moving weekly), 30 days for the patterns.
