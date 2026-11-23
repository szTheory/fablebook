# Local operator host

This host opens the fixed, compiled Logistify operator Book in Fablebook's UI
catalog and same-origin Canvas. A Book is one catalog; “Books” is the sidebar
collection label. The records and action labels are illustrative;
it has no logistics backend, persistence, or external writes.

The host is a development/test fixture. Its server binds to loopback and is
disabled unless `FABLEBOOK_OPERATOR_SERVER=1` is set. No Node installation is
required.

## Prepare

From the repository root, fetch the exact public source pins. Cached commits
are reused without network access:

```sh
bin/fetch_brand_sources
bin/verify_logistify_source --check-pinned
```

Install and audit the isolated development host lock:

```sh
cd hosts/operator
MIX_ENV=dev mix deps.get --check-locked
MIX_ENV=dev mix compile --warnings-as-errors
MIX_ENV=dev mix hex.audit
```

## Start

From the repository root, choose an unused loopback port. The default is 4002;
the example uses 4003 for environments where 4002 is already occupied:

```sh
cd hosts/operator
port="${FABLEBOOK_OPERATOR_PORT:-4003}"
runtime_dir="../../_build/operator_host"
mkdir -p "$runtime_dir"
log_file="$runtime_dir/dev.log"
pid_file="$runtime_dir/dev.pid"

nohup env \
  FABLEBOOK_OPERATOR_SERVER=1 \
  FABLEBOOK_OPERATOR_PORT="$port" \
  MIX_ENV=dev \
  mix run --no-halt \
  > "$log_file" 2>&1 < /dev/null &
host_pid=$!
printf '%s\n' "$host_pid" > "$pid_file"
```

Confirm that the recorded process owns the selected loopback listener:

```sh
lsof -nP -iTCP:"$port" -sTCP:LISTEN
curl --fail --silent --show-error "http://127.0.0.1:$port/admin/dev/fablebook"
```

Open the UI catalog at `http://127.0.0.1:$port/admin/dev/fablebook`. It opens
the first Scenario in the main Canvas, with Books → Book → Dispatcher recovery
(Journey) → Scenarios → Scenario links in the sidebar. Its breadcrumb links back to the Book and the
Journey's first Scenario, and the Scenario links below it switch between the
two screens. The Home route is `/`; the Book's default URL is
`/admin/dev/fablebook/book/operator`. The two stable Scenario URLs are:

- `/admin/dev/fablebook/book/operator?scenario=failed_shipment`
- `/admin/dev/fablebook/book/operator?scenario=bulk_reassignment`

The authored Scenario data and pinned manifest retain exact source citations;
the Canvas omits the raw source path and JSON Pointer list.

The pinned Logistify source is cached at
`../../.cache/brand_sources/logistify-brand`. Its manifest names the repository,
tag, commit, and source file. Missing shipment IDs, board membership, and the
replacement driver's name remain labeled as unavailable in that source.

## Fablebook UI assets

The unchanged Fablebook wordmark and licensed Schibsted Grotesk font come from
the public `fablebook-brand` repository, tag `v2.1`, commit
`b2e3441218f9d62f857ab9ff7b4b62fdc320078c` (the pin in
`brand_sources.lock.json`). The full repository remains in the ignored source
cache; only these files are copied into the host:

| Local file | Source path | SHA-256 |
|---|---|---|
| `priv/static/assets/brand/fablebook-lockup-small-light.svg` | `assets/logo/fablebook-lockup-small-light.svg` | `7b70cc93c4eb4c468911fdb74c04888eb41441160e935c3fd921659639359096` |
| `priv/static/assets/fonts/SchibstedGrotesk-Variable.ttf` | `assets/fonts/variable/SchibstedGrotesk[wght].ttf` | `6ceeadf6be8e1fd7687011c7fa38ed0edd1abe967a0b73d97caec183552e823d` |
| `priv/static/assets/fonts/OFL-SchibstedGrotesk.txt` | `assets/fonts/OFL-SchibstedGrotesk.txt` | `3b4f3063b6ac7c1e403e2c4a5e8ef3a58190ff83ed7b15af66511858699139ce` |

The font's OFL license is included beside the font. The UI follows the pinned
neutral Paper, Card, Ink and Hairline palette; the selected Scenario uses a
Paper tint and complete outline, and Logistify styling stays inside the Canvas.

## Stop

Stop only the PID recorded by the start command:

```sh
host_pid=$(cat ../../_build/operator_host/dev.pid)
kill -TERM "$host_pid"
rm ../../_build/operator_host/dev.pid
```

The log remains at `../../_build/operator_host/dev.log`. Do not use a broad
process-name kill; if the saved PID is missing or stale, inspect the listener
on the selected port before taking any action.
