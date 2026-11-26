---
id: SEED-261125-rga
status: dormant
planted: 2026-11-25
planted_during: v0.7 Phase 8 — First Inspectable Book
trigger_when: When a future milestone is explicitly scoped around LLM-agent access, after the owner has put the local operator UI in a good place.
scope: Discovery required; a local CLI and a remote authenticated diagnose/fix API may need separate slices.
audit_acknowledged:
  milestone: v0.7
  at: 2026-11-25
  status: dormant
---

# SEED-261125-rga: LLM-oriented Fablebook CLI and authenticated agent workflows

## Why This Matters

The owner proposes a GitHub-style CLI to make Fablebook easier for LLM agents to use, followed later by an API that could let an authenticated agent diagnose and fix issues. The owner explicitly puts the local admin/operator UI first. Keep this as a future direction, not active v0.7 scope.

Fablebook already has a confirmed AI coding-agent job: inspect a machine-readable catalog, contracts, stable render URLs, and a budgeted Bundle so UI changes can be checked without guessing. A CLI should build on that job and the library's personas, Jobs to Be Done, glossary, and source provenance. The current local operator host is a fixed illustrative Book with no logistics backend or external writes; it does not establish the needs or authority of an agent operating an adopter's live application.

## When to Surface

**Trigger:** When the local operator UI has reached the owner's desired baseline and a future milestone is explicitly being scoped for LLM-agent access or workflows.

Surface this seed during milestone research. First distinguish the AI coding agent that helps an adopter build or fix UI from an operations agent that may act on the adopter's application.

## Scope Estimate

**Discovery required.** Reusing documented Mix tasks may be a small first step. A standalone executable and a remote API that can diagnose and perform fixes could be a larger, multi-phase effort. Decide whether those are one product surface or separate slices before estimating implementation.

## Direction and Existing Constraints

- Compare any new CLI with the accepted Mix task direction in [ADR 0019](../../docs/adr/0019-dx-install-upgrade.md), including `mix fablebook.doctor`, `mix fablebook.manifest`, and `mix fablebook.bundle`.
- Preserve [ADR 0009](../../docs/adr/0009-manifest-no-mcp-no-plugin-api.md): 1.0 uses the manifest, `llms.txt`, and Bundle entry points, with no MCP server or public plugin API. Its reversal trigger requires at least two independent requests that files cannot satisfy; this single exploratory idea does not meet that trigger.
- Preserve [ADR 0006](../../docs/adr/0006-dependency-available-in-all-envs.md), which defers authenticated hosted mode to v2, and [ADR 0027](../../docs/adr/0027-operator-host-development-adapter.md), which keeps the operator host loopback and development-only. This seed does not amend those decisions.
- Treat JWT and OAuth as examples only. No protocol, identity model, permission scope, or write authority was selected.

## Discovery Questions

- Does the first CLI mean documented Mix tasks, a standalone `fablebook` executable, or both? Which existing task or Bundle flow should it make easier for the confirmed AI coding-agent persona?
- Does “diagnose and fix” mean report Fablebook Checks and Findings, prepare a code patch for human review, or act on an adopter's live application? Keep those jobs and authorities distinct.
- If remote access is later in scope, define identity, Book/project/tenant isolation, read and write scopes, credential lifecycle, revocation, audit records, data redaction, and any human approval before selecting JWT/OAuth or enabling writes.
- Define success in the user's actual JTBD and domain language, and preserve source provenance in the information an agent receives and edits.
- Reconcile the proposal with ADR 0009's existing two-independent-request trigger and ADR 0006's v2 hosted-auth boundary before planning any API implementation.

## Breadcrumbs

- Owner wording: [INT-20261125-07](../intent/sources/2026-11-25-07-fablebook-agent-cli-idea.md).
- [Fablebook personas and Jobs to Be Done](../../docs/research/PERSONAS-JTBD.md) — confirmed AI coding-agent and library-author jobs; distinguish adopter-authored personas.
- [ADR 0019](../../docs/adr/0019-dx-install-upgrade.md) — accepted Mix task direction.
- [ADR 0009](../../docs/adr/0009-manifest-no-mcp-no-plugin-api.md) — manifest/Bundle entry points and 1.0 API boundary.
- [ADR 0006](../../docs/adr/0006-dependency-available-in-all-envs.md) and [ADR 0027](../../docs/adr/0027-operator-host-development-adapter.md) — hosted-auth deferral and loopback operator host.
- [.planning/intent/OPEN-QUESTIONS.md](../intent/OPEN-QUESTIONS.md) — Q5 public API/MCP revisit trigger.

## Notes

Captured from an owner brainstorming message; no implementation, authentication, API, or roadmap scope was approved. See [the high-signal research note](../notes/2026-11-25-fablebook-agent-cli.md) for the concise product framing and decision boundaries.
