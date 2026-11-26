---
date: 2026-11-25
source: Owner brainstorming message in this Codex session ([INT-20261125-07](../intent/sources/2026-11-25-07-fablebook-agent-cli-idea.md))
captured_by: Codex
status: proposed, not approved scope
related_seed: SEED-261125-rga
---

# Fablebook CLI and agent access

## Captured direction

The owner wants a GitHub-style CLI that makes Fablebook more accessible to LLM agents. The local admin/operator UI should reach a good place first. Later, the owner is interested in an API through which an authenticated agent could diagnose and fix issues. JWT/OAuth were examples, not a protocol choice. The user wants CLI workflows grounded in Fablebook's personas, Jobs to Be Done, and domain language. See the verbatim source [INT-20261125-07](../intent/sources/2026-11-25-07-fablebook-agent-cli-idea.md) and the trigger-based [seed](../seeds/SEED-261125-rga-fablebook-agent-cli.md).

## Existing direction to build on

- The confirmed AI coding-agent job is to use a machine-readable catalog, contracts, stable render URLs, and budgeted Bundle to verify UI work without guessing ([personas and JTBD](../../docs/research/PERSONAS-JTBD.md)).
- [ADR 0019](../../docs/adr/0019-dx-install-upgrade.md) already plans Mix tasks such as `mix fablebook.doctor`, `mix fablebook.manifest`, and `mix fablebook.bundle`. A new standalone executable should be compared with these existing entry points.
- [ADR 0009](../../docs/adr/0009-manifest-no-mcp-no-plugin-api.md) chooses manifests, `llms.txt`, and Bundle commands as 1.0 agent entry points, and defers MCP/public plugin API unless at least two independent requests establish that files are insufficient.
- [ADR 0006](../../docs/adr/0006-dependency-available-in-all-envs.md) defers authenticated hosted mode to v2. [ADR 0027](../../docs/adr/0027-operator-host-development-adapter.md) keeps the current operator host bound to loopback for local development.

## Keep these product jobs distinct

The AI coding agent that helps an adopter build or fix UI is an existing Fablebook persona. An agent that operates an adopter's live application is a different job with different authority. The current operator UI is a fixed illustrative Book, not a logistics backend or a production operations console. Do not infer live operational requirements from it.

Before planning implementation, decide whether “diagnose and fix” means:

1. inspect Fablebook Checks/Findings and return evidence;
2. propose or prepare a code patch for review; or
3. perform actions in an adopter's running application.

The API and authentication questions only apply once the target and authority are clear. If remote or write-capable actions remain in scope, define identity, project/tenant isolation, read/write scopes, token lifecycle and revocation, auditability, redaction, and human approval before choosing a protocol. This note does not select JWT/OAuth or grant write authority.

## Status and provenance

This is a future product idea, not an active milestone requirement. It preserves the owner's “UI first” sequence and does not amend ADR 0009, ADR 0006, the current v0.7 Phase 8 boundary, or the existing public-API revisit trigger. It should surface during future milestone research when that scope is explicitly selected.
