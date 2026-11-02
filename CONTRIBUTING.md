# Contributing

## Elixir lanes

Fablebook supports a current lane and a floor lane. The exact Elixir and Erlang versions live in `.tool-versions` and `.tool-versions.floor`; the corresponding dependencies are pinned by `mix.lock` and `mix.floor.lock`.

Use `bin/lane` to select a lane and keep its Mix dependencies and compiled files separate:

```sh
bin/lane core doctor
bin/lane core test --warnings-as-errors
bin/lane floor doctor
bin/lane floor test --warnings-as-errors
```

`doctor` checks the selected asdf versions and reports the lane's lockfile and effective Mix paths. It does not install runtimes, fetch packages, or run tests. The first setup for a lane is explicit:

```sh
bin/lane core setup
bin/lane floor setup
```

Setup runs `mix deps.get --check-locked` and compiles dependencies. It stores Mix lane data under `_build/lanes/<lane>/` and Hex's cache/config under `_build/hex-home/`, all ignored by Git. Set `FABLEBOOK_HEX_HOME` if you need a custom Hex home, such as one with private repository credentials. A test or other Mix command never runs setup or fetches dependencies implicitly. If a pinned runtime is missing, install it deliberately with asdf and rerun `doctor`.

Run any Mix task through the same lane selection, for example `bin/lane core mix ci` or `bin/lane floor mix deps.tree`. The wrapper clears an inherited `MIX_BUILD_PATH`, since that setting overrides the lane-specific build root.

## CI health

To calculate the current seven-day CI timing and main-branch required-check signal locally without posting or updating GitHub issues, run:

```sh
GITHUB_REPOSITORY=szTheory/fablebook bin/ci_health --dry-run
```

This needs an authenticated `gh` CLI with read access to Actions and the repository ruleset. The command prints any issue update it would have made; the scheduled workflow remains responsible for publishing the weekly result.

## Tests and changes

Keep the core and floor lockfiles unchanged unless a dependency update is intentional. Do not run `bin/floor_lock` as part of ordinary setup; it regenerates the floor lockfile.
