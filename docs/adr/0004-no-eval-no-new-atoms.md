# 0004. No runtime eval, no atoms created from input, ever

**Status:** Accepted · **Cites:** INT-20261028-01

## Context
phoenix_storybook advisories, May 2026:
- GHSA-55hg-8qxv-qj4p / CVE-2026-8467 (CVSS 9.5): playground attr strings were interpolated into HEEx and evaluated with full `Kernel` access.
- GHSA-833p-95jq-929q: `String.to_atom` on event params, which can exhaust the atom table.
- GHSA-mrhx-6pw9-q5fh: the PubSub topic came from the query string, allowing hijack.

## Decision
- **Credo bans** these outside an allowlist module (there is none in v1): `Code.eval_*`, `Code.string_to_quoted*`, `EEx.compile_string`, `EEx.eval_*`, `String.to_atom`, `List.to_atom`, `:erlang.binary_to_term`.
- **Casting** comes from contract metadata. A `values:` match compares the input string against `to_string` of each allowed value, and the result is the declared term. Complex attrs get compiled **presets** (ADR 0002).
- **Workbench ↔ canvas topic:** a 128-bit random token wrapped in `Phoenix.Token`, verified in the canvas `mount`. Query params never choose a topic.
- **Event log:** names are kept as strings, params are truncated to 4 KB, and events are broadcast only on the canvas token topic.
- **Size caps** apply per control type.
- **Open-in-editor** is localhost-only. Its path must sit inside the project root after `realpath`.
- **Proof:** a StreamData property asserts that the atom count is unchanged for arbitrary params, plus the Credo bans and mutation-proven security tests.

## Rejected
- "Sanitize, then eval": every sanitizer is eventually bypassed.

## Reversal trigger
None. This is a non-negotiable (NORTH-STAR #6).
