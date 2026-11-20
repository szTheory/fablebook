# Phase 7 source schedule review

**Verdict:** PASS
**Reviewer:** verify_export_inventory_contract
**Reviewed schedule SHA-256:** `e8fe99a560ee3edc63fe2ffa9bbfd5bf5978f9b8f036abef2aa1c1a35a9c8e8c`
**Target source bodies read:** no

## Findings

- The reviewed schedule has ten unique absolute target paths: five for `core` and five for `floor`. Each path exists, is not a leaf symlink, and its current device, inode, size, modification time, and change time match the schedule's expected file attributes. No target-path globs or duplicate paths are present.
- Core paths:
  - `~/.asdf/installs/elixir/1.20.4-otp-29/lib/elixir/lib/regex.ex`
  - `~/projects/fablebook/_build/lanes/core/deps/phoenix/lib/phoenix/digester.ex`
  - `~/projects/fablebook/_build/lanes/core/deps/phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex`
  - `~/projects/fablebook/_build/lanes/core/deps/plug/lib/plug/builder.ex`
  - `~/.asdf/installs/erlang/29.1.2/lib/stdlib-8.1.1/src/re.erl`
- Floor paths:
  - `~/.asdf/installs/elixir/1.18.5-otp-27/lib/elixir/lib/regex.ex`
  - `~/projects/fablebook/_build/lanes/floor/deps/phoenix/lib/phoenix/digester.ex`
  - `~/projects/fablebook/_build/lanes/floor/deps/phoenix_live_view/lib/phoenix_live_view/colocated_assets.ex`
  - `~/projects/fablebook/_build/lanes/floor/deps/plug/lib/plug/builder.ex`
  - `~/.asdf/installs/erlang/27.3.4.9/lib/stdlib-6.2.2.3/src/re.erl`
- The seven selectors in both lanes are exactly: `CN-002 Elixir.Phoenix.Digester.compile/3`; `CN-003 Elixir.Phoenix.LiveView.ColocatedAssets.compile/0`; `CN-004 Elixir.Plug.Builder.compile/3`; `CN-005 Elixir.Regex.compile/1` and `/2`; and `CN-006 re:compile/1` and `/2`. For each, the schedule's identity, MFA selector, membership JSONL line, and `/saved_live_mfas` field agree with the corresponding row. The floor pointers also resolve to those exact saved MFA values in the accepted Phase 3 aggregate and carry that artifact's matching digest; this is retained evidence, not a claim of current floor presence.
- The dependency pins agree with each lane's lock metadata: core Phoenix 1.8.16, Phoenix LiveView 1.2.13, and Plug 1.20.4; floor Phoenix 1.8.9, Phoenix LiveView 1.2.9, and Plug 1.20.3. The lock digests match the lane identities in `07-RECONCILIATION.json`. Runtime pins also match: core Elixir 1.20.4 / OTP 29.1.2 / stdlib 8.1.1; floor Elixir 1.18.5 / OTP 27.3.4.9 / stdlib 6.2.2.3.
- The five core targets are in batch `01`, and the five floor targets are in batch `02`; each batch is within the five-file limit. Batches `03`–`05` are empty. Every entry is `one_use: true`, `truncation: forbidden`, with a 2 MiB read ceiling. The largest scheduled file is 72,908 bytes by filesystem metadata, so the ceiling permits a full read without truncation.
- No target source content hash or observed line/byte span has been prefilled. `content_sha256` is null; the MFA span selectors are identifiers only. The schedule defers the content hash and observed spans to the later one-use read.
- The family contains only CN-002 through CN-006. The unresolved CN-004 → EX-124 and EX-125 → EX-124 cross-references remain recorded in the reconciliation, while EX-124 and EX-125 are not scheduled as family members. EX-125 shares `Elixir.Plug.Builder.compile/3` with CN-004; the scheduled association is specifically CN-004, and its resulting observation must not be presented as an EX-125 row-level observation.

## Limits

This review approves only the exact metadata schedule. It does not inspect source semantics, validate static caller closure, establish code-candidate fit, or close the aggregate gate. Floor membership remains the accepted ENV06 record rather than a fresh floor scan. The historical whole-library record still contains only a digest and count, so this schedule cannot establish a complete historical-universe diff. Any later source read remains bounded to the reviewed exact path and selector and must recheck its approval and file identity.
