# 0009. Canonical JSON manifest; no MCP server and no public plugin API in 1.0

**Status:** Accepted · **Cites:** INT-20261028-04, INT-20261028-02

## Context
- Storybook's addon ecosystem breaks on every major upgrade.
- Storybook 10.3+ ships an MCP server and component manifests. Published Storybooks expose only the docs tools.
- phoenix_storybook #715 asks for agent-readable Markdown export.

## Decision
- **Manifest files.**
  - `index.json`: stories, scenarios, tier, state class, citations, tags, source `file:line`, and URL template.
  - `components.json`: per-component contracts, with attrs in line order, slots, and `@doc` via `Code.fetch_docs`.
  - Both use stdlib `JSON` with recursively sorted keys and no timestamps or absolute paths.
- **Access.** The manifest is served at `<mount>/manifest/*.json` and written by `mix fablebook.manifest`. A drift check runs as an ExUnit assertion (`Fablebook.Testing.assert_manifest_current/2`).
- **Agent entry points.** `llms.txt` and `llms-full.txt` (ExDoc-generated for the library docs; the mount serves a catalog-level `llms.txt` linking the manifest and bundle commands).
- **Panels.** Panels are built against an internal `Fablebook.Panel` behaviour. It becomes public only after two real external requests for it.
- **MCP.** No MCP server in 1.0. A later MCP server would be a thin adapter over `Fablebook.Bundle` (OPEN-QUESTIONS Q5).

## Reversal trigger
Two or more independent requests, from adopters or agent tooling, that the manifest and bundle files can't satisfy.
