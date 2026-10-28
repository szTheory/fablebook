# Owner DNA: patterns from the owner's Elixir OSS libraries

These are conventions mined from sigra, crosswake, mailglass, lockspire, scrypath, rindle, threadline, accrue, lattice_stripe, oarlock and others in `~/projects`, along with the velocity lessons learned building them. **Adopt** means copy the pattern into Fablebook; **Avoid** means a lesson learned the hard way. (INT-20261028-01, INT-20261028-02)

## Identity and PII
- **Adopt:** author commits with the owner's GitHub noreply identity (configured locally, never written into files), MIT license held by "sztheory", `.planning/` committed.
- **Adopt:** `.gitignore` covering `/.claude/`, `/prompts/`, `.cursor/`, `.gsd/`, `.env*` (with `!.env.example` re-included), `*.tar`, `.DS_Store`, `.planning/milestone.lock`, `.planning/research/**/.cache/`.
- **Adopt:** no email addresses or absolute home paths in committed files.

## mix.exs and project shape
- **Adopt:**
  - `@version` and `@source_url`; `elixirc_paths(:test) -> ["lib", "test/support"]` (plus `storybook/` in dev/test for hosts)
  - docs: `main: "readme"`, `source_ref: "v#{@version}"`, favicon, `extras`, `groups_for_extras` ordered by reader intent (the first matching regex wins)
  - an explicit `package files:` allowlist
  - optional deps marked `optional: true`, with `no_warn_undefined`
  - `def cli, do: [preferred_envs: [...]]`
- **Adopt:** a `mix ci` alias that mirrors the PR gate (`format --check-formatted`, `deps.get --check-locked`, `deps.unlock --check-unused`, `compile --warnings-as-errors`, `credo --strict`, `test`). Sigra pins this leg set with a contract test.
- **Adopt:** NimbleOptions for every options schema.
- **Adopt:** `%Lib.Error{}` with a closed `:type` set.
- **Adopt:** telemetry events named `[:lib, :domain, :action, :start|:stop|:exception]`, with whitelisted metadata and **never PII**; a raising handler must not break business logic.
- **Adopt:** optional deps go through `Lib.OptionalDeps.*` gateways, with a `--no-optional-deps` CI lane.
- **Adopt:** a Fake adapter as the merge-blocking gate; real-provider tests are advisory and run on cron.
- **Adopt:** no `name: __MODULE__` singletons; no `Application.compile_env` outside the config module.
- **Adopt:** custom Credo checks for project rules (mailglass has 12 or more, e.g. `NoPiiInTelemetryMeta`, `TelemetryEventConvention`, `NoDirectDateTimeNow`).
- **Adopt:** `use X` injects 20 lines or fewer.
- **Avoid:** comments tagged with decision ids (D-xx) all over the code, `verify.phaseN` mix tasks, and phase history leaking into the build. Scrypath has 30 `verify.phaseN` entries in `preferred_envs`.
- **Adopt:** toolchain pinned in `.tool-versions`.

## Embedded LiveView UI packaging (mailglass_admin, oban_powertools, accrue_admin…)
- **Adopt:**
  - `import Lib.Router` and `lib_routes "/path", opts` (opts validated by NimbleOptions)
  - expands to `scope path, alias: false, as: false` + asset `get`s + a `live_session` with a configurable name, user `on_mount` hooks prepended, and its own root layout
  - session passed as a whitelisted MFA map
  - "zero endpoint.ex edits"
- **Adopt:** precompiled CSS committed to `priv/static/`, built with the **standalone `tailwind` Hex binary (no Node)**.
  - Tailwind v4: `@import "tailwindcss" source(none); @source "../../lib";`
  - daisyUI and heroicons vendored in `assets/vendor/`
  - drift check: `assets.build && git diff --exit-code priv/static/`
  - the tarball ships `priv/static`, never `assets/`
- **Adopt:** a compile-time asset controller (`@external_resource` + `File.read!`) with MD5 URLs, `immutable` caching, and a font allowlist that guards against path traversal. `phoenix.js` comes from the host's deps via `Application.app_dir`. A CSP nonce plug (accrue_admin).
- **Avoid:** an `if` around router macros as a dev-only guard. Macros expand anyway, so mailglass needed a `Code.ensure_loaded?` hack (see ADR 0006).

## CI/CD
- **Adopt:** **a single aggregate required check** (threadline's `ci-required`) with `if: always()`, where `skipped` counts as failure.
- **Avoid:** trigger-level `paths:` filters. A required workflow that gets filtered out never reports, so the PR waits on "Expected — waiting" forever. Instead, use a fail-open `changes` job consumed at **step** level.
- **Adopt:** concurrency `cancel-in-progress` for PRs.
  - **Footgun:** `cancel-in-progress: false` still queues one pending run.
  - **Footgun:** the *string* `"false"` is truthy.
- **Adopt:** `timeout-minutes` on every job, `permissions: contents: read`, actions pinned to a SHA with a version comment, Postgres images pinned by digest, Dependabot for `mix.lock` and workflows.
- **Adopt:** a floor lane plus a latest lane. Test-only deps must also install on the floor; threadline pins `yaml_elixir ~> 2.11.0` for this reason.
- **Adopt:** split `cache/restore` and `cache/save`; a PLT key built from OTP, Elixir and `hashFiles('mix.lock')`.
- **Avoid:** oarlock's PLT bug. The restore key `…-plt-…` (ci.yml:113) doesn't match the save key `…-dev-test-…` (ci.yml:136), which also collides with the deps cache, so the PLT is never saved.
- **Avoid: CI bloat, the biggest velocity tax.**
  - Sizes: sigra `ci.yml` is 2,807 lines across 17 workflows; crosswake has 28 workflows (`phaseNN-proof.yml`); mailglass `publish-hex.yml` is 1,415 lines; oarlock's "lean" ci.yml is now 490 lines with Node proof scripts.
  - The leanest repos (scrypath, lattice_stripe) churned least.
  - Fix-CI commits: accrue 46 (plus 26 reverts), rindle 46, mailglass 44, sigra 36, scrypath 2, lattice_stripe 0.
- **Adopt the measured wins** from the sigra v1.47 retro (p50 27.3 → 7.8 min):
  - remove gratuitous serializing `needs:` edges (the biggest single win)
  - demote pixel-diff and render-heavy jobs off PRs
  - cache Playwright browsers pinned by SHA
  - one composite setup action instead of four duplicated preludes
  - fold trivial guard jobs into one `fast_checks` job
  - shard behind a name-preserving aggregator
  - **measure the baseline first**
- **Adopt:** fix visual flake with self-hosted webfonts and in-CI recapture, not by widening tolerance.

## Release (`~/.claude/skills/bootstrap-elixir-hex-lib/SKILL.md`)
- **Adopt:** release-please `release-type: elixir`, `include-v-in-tag: true`, manifest at `0.0.0`, `bump-minor-pre-major: false`, `bump-patch-for-minor-pre-major: true`, and changelog sections feat/fix/perf/deps (chore hidden).
- **Gotchas built into the skill:**
  1. Check the Hex name is free (it returns 404); `fablebook` was free on 2026-10-28.
  2. Set `name:` in `package/0` if it differs from the app name.
  3. **Day 1:** `gh api -X PUT /repos/szTheory/<n>/actions/permissions/workflow -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true`.
  4. Baseline the manifest at `0.0.0`.
  5. Set `release-as: "0.1.0"` for the first release only.
  6. Don't copy sigra's `sync-release-summary` job.
- **Adopt:**
  - `HEX_API_KEY` is the only human step
  - a post-publish smoke consumer
  - a manual `hex-publish.yml` recovery workflow (`tag` + `version` inputs)
  - the tag must exist before `hex.publish`, or "View source" returns 404
  - PRs run the fork-safe `mix hex.build`, not a publish dry-run, which needs auth
  - an `environment: hex-production` approval gate
- **Avoid:** Node scripts in the release path (oarlock's `release_integrity.cjs`, `release_evidence.cjs`).
- **Avoid:** release-status prose inside the published docs, which goes stale once the tag is immutable (lattice_stripe).
- **Avoid:** tooling commits on the root package triggering phantom releases (mailglass); use `exclude-paths`.
- **Avoid:** skipping release close-out, which stranded the 2.5.0 ledger for about four weeks (mailglass).

## Testing
- **Adopt:** StreamData properties (used in most of the libraries); Mox with behaviours for functional DI; pure core plus a thin Mix shell (sigra `Doctor`); LiveViewTest with `lazy_html`.
- **Adopt:** **"mutation-proven"** contract tests: break the code by hand, see the test go red, restore it. Fablebook adds **Muex** on a weekly cadence (ADR 0014).
- **Adopt:** Playwright and axe against a real host app (sigra example, threadline, mailglass reference apps, relyra).
- **Adopt:** installer golden and idempotency tests; a clean-room consumer that builds the tarball and compiles it (threadline, relyra).
- **Adopt:** Benchee in a **sibling Mix project** (`threadline/bench/`) with committed baselines (SHA, versions, machine) and sensitivity controls; **not CI gates**, because shared runners are too noisy.
- **Avoid:** "cite-and-flip" verification, i.e. reading the code instead of running the spec. It masked about 15 broken Playwright specs in sigra.

## Docs
- **Adopt:**
  - ExDoc groups by reader intent (Overview / Evaluate / Adopt / Operate / Contribute), matching the README's "Start here" table
  - `formatters: ["html","markdown"]` and a committed `llms.txt` (sigra)
  - Mermaid loaded with SRI
  - per-version `upgrading-to-vX.md`, plus production-checklist, troubleshooting, code-walkthrough and `jobs.md`
  - README sections "When it fits / When it does not / Choose a route / Quick path" (scrypath)
- **Avoid:** guide sprawl; scrypath has 31 guides. Fablebook caps at 12 at 1.0.

## DX and local tooling
- **Adopt:** an ephemeral service on a **dynamic host port** that writes `tmp/*.env` (sigra `scripts/db/up.sh`).
- **Adopt:** `compose.toolchain.yml` that reproduces the CI runner, plus `compose.demo.yml`, each with a per-stack `name:` and loopback-bound, env-overridable ports (mailglass).

## Methodology already written down by the owner (Fablebook implements it)
Sources (owner-local files; not available to contributors or CI, summarized here):
- `~/Documents/ui-storybook-stresstest-methodology-prompt.txt`
- `~/projects/mailglass/.planning/research/{storybook-fractal,ui-quality-engine}/`
- `~/projects/scrypath/.planning/research/ui-quality-engine/`
- `~/projects/accrue/.planning/notes/2026-10-26-ui-storybook-quality-direction.md`

Key points:
- **Fractal stories** follow product IA and JTBD nouns, and stories must be **equivalence classes, not permutations**: every scenario names a persona and JTBD situation, and anything the app can't render is pruned. Any second inventory is retired.
- **Presentational screens.** The LiveView keeps mount, params and events; screens render from plain assigns. "If a screen needs heavy mocks, split it."
- **DB-free persona fixtures** ("digital twins of adopters") with tested realism invariants: no lorem ipsum, ordered timestamps, closed enums. They are **dev/test-only and reachable from every story host** (scrypath ADR-0002: a separate Mix project, because a path dep compiles in `:prod`).
- **One design language:** visual tokens plus verbal tokens (voice, microcopy, a user-facing glossary), with a single source of truth (DTCG) and a drift test.
- **Layered checks:**
  - L1: static lints, a token reset, a contrast matrix
  - L2: a generic sweep over manifest × widths × themes, plus reduced motion (console errors, overflow, axe wcag22aa, 24 px targets, 200% text, token conformance, focus walk, nav ARIA identity, glossary lint)
  - L3: opt-in screenshots, **never auto-accepted**
  - L4: an advisory LLM judge giving binary judgments with evidence and pairwise comparisons, never gating
  - L5: the owner, with a verdicts log
  - Ratchets that only shrink; findings reproducible as URL + viewport + theme + motion
  - At most 5 extra minutes per PR
- **Review rubric:** tasteful light and dark; intentional typography; elegant hierarchy; no redundancy; great happy paths and power use (an "iPhone-designed" bar); consistent microcopy (sentence case, verb-first buttons, no "Oops" or "!"); curated personas; a coherent journey; mobile-first at 320 px; least surprise.
- **Recorded owner verdict:** "a sidebar label long enough to truncate is a naming smell; shorten it."

## Process and GSD lessons
- **Avoid oversized phases.** sigra 235.1 ran 449 commits and parked; sigra Phase 245 had 46 plans; mailglass Phase 164 had 44.
- **Avoid proof ceremony** that eats whole milestones. Keep the lean posture of lattice_stripe and scrypath.
- **Avoid** "a rewritten guard hides a regression better than no guard at all" (sigra v1.47). Re-read the shipped artifact before a `gaps_found → passed` flip.
- **Avoid** "green locally ≠ green in CI". Push or open a PR on day 1.
- **Avoid** one long branch merged once (mailglass #302).
- **Adopt** "design the authority model before installing the authority" (mailglass v2.7, where four reinstall ceremonies were wasted).
- **Adopt** "prove the demo host end to end", because library-green paths can still be denied by the host the owner actually clicks through (mailglass v2.9).
- **Adopt:** run the audit *before* `complete-milestone`.
- **Adopt:** a review loop of more than 3 passes gives diminishing returns, so cap it at 2.
- **Adopt:** single-day milestones work when the API shape is locked in advance by a dossier (lattice_stripe). That is what this seed set is for.
- **Adopt:** `worktree.baseRef: "head"` to keep parallel execution working.
- **Adopt:** close-out docs need a PR when rulesets block direct pushes.
- **Adopt:** recorded owner decisions outrank prompts; research first, decide, and escalate rarely (apply a reversibility test before asking).
- **Adopt:** zero human UAT; consult the owner only on ship/no-ship, brand, secrets, the publish approval and physical devices (mailglass D-52).

## Dependency philosophy (explicit owner quotes)
- "Minimal transitive deps. Copy-paste over deps when code is small and stable." (`sigra/CLAUDE.md`)
- "another copy and paste is better than another dep" — a necessary dependency needs a written justification; adopters must not need Node. (accrue note)
- Vendoring precedents:
  - daisyUI and heroicons vendored
  - nimble_totp's four functions copy-pasted
  - OTP `:crypto` used instead of a crypto dependency
  - about 30 hand-written lines for overflow and target-size checks
  - bench and fixtures isolated in sibling projects
  - Phoenix JS borrowed from the host's deps
