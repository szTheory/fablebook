# Elixir lane and developer experience research

**Date:** 2026-11-01  
**Scope:** Fablebook's core/floor Elixir lanes, the current local dependency mismatch, sibling Elixir project practices, and whether Docker would improve this workflow.

## Recommendation

Start with a small host-native lane command and a single source for each lane's toolchain pins. Keep Docker as an optional later layer if Fablebook develops a real OS/native-library parity need. Do not change CI caching or move checks out of pull requests based on the evidence reviewed here.

The immediate blocker is that both lanes currently use the same local `deps/` and `_build/` directories. The selected lockfile changes with `FABLEBOOK_FLOOR`, but those paths do not. The local Phoenix and LiveView sources are from the core lock while the floor lock expects older exact versions. This is a local path-isolation problem. CI already selects the lane before restoring its lock-keyed cache and runs the two lanes as separate jobs.

A lane command should make the selection explicit, show the chosen Elixir/OTP and lockfile, and give each lane a separate ignored dependency/build path. Its inspection and test commands should never install runtimes or fetch packages implicitly. Any bootstrap command that can fetch packages should be explicit. This gives Fablebook the useful part of a reproducible environment without adding another dependency or requiring Docker for a Mix library that currently has no demonstrated local service stack.

## Findings in Fablebook

- `mix.exs` selects `mix.floor.lock` when `FABLEBOOK_FLOOR` is set, but Mix continues to use its default shared dependency and build paths. In the current checkout, `deps/phoenix` is 1.8.16 and `deps/phoenix_live_view` is 1.2.13; the floor lock selects 1.8.9 and 1.2.9. The mismatch explains the floor lane failure without indicating a CI cache defect.
- `.github/actions/setup/action.yml` selects the toolchain and lock per lane, keys its cache with OS, architecture, OTP, Elixir, `MIX_ENV`, and the chosen lock hash, then runs `mix deps.get --check-locked && mix deps.compile`. `ci.yml` runs core and floor in separate jobs. These are sensible CI boundaries; the cache is not the blocker found here.
- The measured CI run recorded in `.planning/CI-PERFORMANCE.md` spent about 9–12 seconds on setup while the floor test command took 9m56s. If reducing CI time is a separate goal, profile the graph test and evidence output first. A container or wider dependency cache does not address the dominant measured cost.
- `.tool-versions` is the core pin. The floor OTP/Elixir versions currently appear as inline values in the GitHub setup action, so local scripts and CI could drift if a second copy is added without a shared file.
- `bin/floor_lock` deletes and regenerates the floor lockfile. It must not be used as a normal lane setup command.

## Patterns from sibling Elixir projects

I inspected 21 local Elixir project roots, then compared the most relevant toolchain, release, and workflow patterns. Release counts and run durations below are samples from the inspected repositories, not long-term statistical claims.

| Project | Useful evidence | What Fablebook can take from it |
| --- | --- | --- |
| Threadline | 10 GitHub releases from Sep 22–Oct 24. A green PR run on Oct 29 took 7m34s. It has strict `.tool-versions` setup, floor/current/latest coverage, and lock/toolchain-aware caches. | Best observed balance of frequent releases and bounded CI. Keep exact pins and caches keyed to the inputs that change compiled output. [Tool versions](</Users/jon/projects/threadline/.tool-versions>), [CI workflow](</Users/jon/projects/threadline/.github/workflows/ci.yml>). |
| Rindle | 14 releases from Aug 20–Oct 25; one green PR run on Oct 29 took 12m02s. It uses `mix deps.get --check-locked` and `mix deps.unlock --check-unused` on canonical CI, with broader compatibility checks nightly. | Use locked setup as a guard against accidental lock changes; put lower-frequency compatibility work on a schedule only when it is not part of the supported per-change promise. [CI workflow](</Users/jon/projects/rindle/.github/workflows/ci.yml>), [nightly workflow](</Users/jon/projects/rindle/.github/workflows/nightly.yml>). |
| Scrypath | 7 releases from Aug 25–Oct 25; sampled green run Oct 31 took 3m17s, while a Nov 1 run failed after 18m59s. It uses Docker for a mounted example. | A single fast run is not a reliable CI-time target. Its Docker use is scoped to an example environment, not proof that Docker is needed for a library's ordinary Mix workflow. [CI workflow](</Users/jon/projects/scrypath/.github/workflows/ci.yml>). |
| Sigra | 5 releases from Aug 31–Oct 11; sampled PR run took 8m28s and a scheduled run 20m49s because the scheduled lane does more exhaustive work. | Separate broad scheduled checks from required checks when their different feedback cadence is intentional. Fablebook already has daily/weekly scheduled workflows, so no additional lane is evident. [CI workflow](</Users/jon/projects/sigra/.github/workflows/ci.yml>). |
| Kiln | Includes a Dev Container/asdf setup, but its `.tool-versions` OTP pin differs from the Dev Container OTP pin. Its sampled main CI run took 44m31s. | A container does not prevent version drift when pins are duplicated, and it does not imply short CI. Prefer one version authority. |

## Options

| Option | Fit for this problem | Costs and risks | Recommendation |
| --- | --- | --- | --- |
| Host lane wrapper with separate Mix paths | Directly prevents the observed core/floor dependency and build outputs from sharing locations. Works with existing Elixir/asdf setup and keeps the dependency tree flat. | Needs careful environment cleanup: `MIX_BUILD_PATH` overrides `MIX_BUILD_ROOT`; a stale explicit path can defeat isolation. A bootstrap step can fetch packages, so it must be explicit and lock-checked. | **Do this first.** Add a read-only `doctor`/lane display and `test` path; make fetching a distinct command. |
| Docker or Dev Container | Useful if host OS, native libraries, or a multi-service local stack cause inconsistent results. Can make onboarding more uniform. | Adds image/build maintenance, package/image supply-chain inputs, filesystem mount behavior, and another setup path. Does not select the right lockfile or Mix paths by itself. | **Defer.** Revisit if an observed OS/native dependency mismatch or concrete onboarding need justifies it. |
| CI cache expansion or workflow changes | Could reduce repeated fetch/compile work after measured cache misses. | Current CI keys already include the selected lock and toolchain; setup is small relative to tests. Risk of complexity or weaker coverage without a demonstrated saving. | **No change now.** Profile comparable runs before considering cache or scheduling changes. |

## Implementation plan and status

The owner authorized an exact locked floor dependency fetch into its ignored lane directory, then approved the host-native recommendations. Plan 01 resumed and completed with the isolated floor dependencies; neither lockfile nor the approved source archive changed.

1. **Isolate lane inputs — complete.** `bin/lane` selects `mix.lock` for `core` and `mix.floor.lock` plus `FABLEBOOK_FLOOR=1` for `floor`. It directs dependencies and build artifacts to `_build/lanes/<lane>/`, clears inherited `MIX_BUILD_PATH`, and validates exact asdf runtime installs before running Mix. `doctor` reports the pins, lockfile, environment, and effective paths without fetching or installing.
2. **Make package setup explicit — complete.** Only `bin/lane <lane> setup` runs `mix deps.get --check-locked` and compiles dependencies. It uses the ignored, checkout-local `_build/hex-home` for Hex cache/config, avoiding writes to a restricted global `~/.hex` path. Tests and other Mix tasks do not set up or fetch dependencies. The core setup completed against `mix.lock` without changing either lockfile.
3. **Use one source for each toolchain pin — complete.** `.tool-versions.floor` now holds the floor Elixir/OTP pins; the GitHub setup action reads that file with strict parsing rather than repeating inline versions. The existing latest-lane `.tool-versions` remains the core pin.
4. **Document and verify the local path — in progress.** `CONTRIBUTING.md` documents `doctor`, `setup`, test, and arbitrary Mix task commands; README links to it. Read-only `doctor` runs verified both exact toolchains using the task's existing asdf data directory, and reported distinct dependency/build paths even with an inherited `MIX_BUILD_PATH`. Shell syntax, ShellCheck, and `git diff --check` passed. The core locked setup completed; the full phase contract checks remain part of phase execution.
5. **Revisit Docker and CI speed only with evidence.** No container or CI cache/check changes are recommended now. Add a Dev Container only for a demonstrated OS/native-library/service parity issue or real onboarding burden. Profile several comparable CI runs and the floor graph work before changing caches or check placement, while retaining both required lanes.

## Primary references

- [Mix environment variables](https://mix.hexdocs.pm/1.20.4/Mix.html#module-environment-variables) documents `MIX_DEPS_PATH`, `MIX_BUILD_ROOT`, and the overriding behavior of `MIX_BUILD_PATH`.
- [Mix.Project](https://mix.hexdocs.pm/1.20.4/Mix.Project.html) documents project lockfile and build/dependency paths.
- [Mix deps.get](https://mix.hexdocs.pm/1.20.4/Mix.Tasks.Deps.Get.html) documents that dependency retrieval can fetch missing/outdated dependencies and that `--check-locked` fails when the lock would change.
- [asdf configuration](https://asdf-vm.com/manage/configuration.html) documents `.tool-versions` and `ASDF_TOOL_VERSIONS_FILENAME` for selecting a version file.
- [erlef/setup-beam](https://github.com/erlef/setup-beam) documents strict version parsing and `version-file` setup from asdf-format files.
- [GitHub Actions dependency caching](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching) describes cache scope and security considerations; [workflow jobs](https://docs.github.com/en/actions/get-started/understand-github-actions) describes independent jobs and their execution model.
- [Docker cache invalidation](https://docs.docker.com/build/cache/invalidation/), [bind mounts](https://docs.docker.com/engine/storage/bind-mounts/), and [build context](https://docs.docker.com/build/concepts/context/) document why Docker adds its own cache and filesystem boundaries and does not manage Mix lane selection automatically.

## Scope and limits

This recommendation is based on the current checkout, local sibling repositories, a small sample of CI runs/releases, and official tool documentation. The approved host-native lane wrapper, contributor instructions, floor version file, and strict CI version-file reference are implemented above. No Docker setup or runtime installation was added, and no CI cache or job changes were made. The exact locked dependency fetch is described in the implementation status; this report does not claim a benchmark of the new wrapper.
