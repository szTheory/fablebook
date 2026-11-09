# Contributing

## Elixir lanes

Fablebook supports a current lane and a floor lane. The exact Elixir and Erlang versions live in `.tool-versions` and `.tool-versions.floor`; the corresponding dependencies are pinned by `mix.lock` and `mix.floor.lock`.

### Install the pinned runtimes

Install the asdf plugins once if they are not already present:

```sh
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
```

On macOS, Erlang/OTP builds need the Xcode command line tools and `autoconf`:

```sh
xcode-select --install
brew install autoconf
```

From the repository root, install both checked-in pin sets. The first command reads `.tool-versions`; the second selects `.tool-versions.floor` without editing the core pins:

```sh
asdf install
ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=.tool-versions.floor \
ASDF_TOOL_VERSIONS_FILENAME=.tool-versions.floor \
  asdf install
```

The two filename variables cover asdf releases that use either spelling. After installation, verify the actual runtimes and lane paths before fetching dependencies:

```sh
bin/lane core doctor
bin/lane floor doctor
```

`doctor` must report the exact versions in the corresponding pin file. If it reports a missing or mismatched runtime, fix that asdf installation before running `setup` or tests; changing the pins is not a setup fix. The [asdf-erlang setup notes](https://github.com/asdf-vm/asdf-erlang#before-asdf-install) list build prerequisites for other operating systems.

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

Setup runs `mix deps.get --check-locked` and compiles dependencies. It stores Mix lane data under `_build/lanes/<lane>/` and Hex's cache/config under `_build/hex-home/`, all ignored by Git. Set `FABLEBOOK_HEX_HOME` if you need a custom Hex home, such as one with private repository credentials. A test or other Mix command never runs setup or fetches dependencies implicitly.

Run any Mix task through the same lane selection, for example `bin/lane core mix ci` or `bin/lane floor mix deps.tree`. The wrapper clears an inherited `MIX_BUILD_PATH`, since that setting overrides the lane-specific build root.

## CI health

To calculate the current seven-day CI timing and main-branch required-check signal locally without posting or updating GitHub issues, run:

```sh
GITHUB_REPOSITORY=szTheory/fablebook bin/ci_health --dry-run
```

This needs an authenticated `gh` CLI with read access to Actions and the repository ruleset. The command prints any issue update it would have made; the scheduled workflow remains responsible for publishing the weekly result.

## Tests and changes

Keep the core and floor lockfiles unchanged unless a dependency update is intentional. Do not run `bin/floor_lock` as part of ordinary setup; it regenerates the floor lockfile.
