---
phase: 03
plan: 03-01
task: 03-01-03
status: complete
source-events:
  incomplete: [1]
  complete: [2, 3, 4]
---

# Task 03-01-03 Source Notes

This is a static, source-anchored handoff for the existing TierSweepTest,
InstalledOtp, and SweepEvidence seams. It records only complete scheduled
ranges from continuation events 2–4. It does not turn either incomplete event
into evidence and does not authorize implementation.

## Event accounting

| Event | Source | Result |
|---:|---|---|
| 1 | Eight scheduled TierSweepTest ranges | Permanently consumed/incomplete; explicit truncation marker. No claims below derive from it. |
| 2 | `test/contract/tier_sweep_test.exs`: 1360–1485, 2840–2905, 5030–5125, 7670–7905, 8390–8560, 10620–10695, 13440–13620, 14070–14330 | Complete exact ranges emitted together once, with all eight labels, under the existing 16,000 inner / 18,000 outer token ceilings; no truncation marker. |
| 3 | `test/support/installed_otp.ex`: 1–130, 245–345, 1683–1701 | Complete exact ranges emitted together once; all three labels present, no truncation marker. |
| 4 | `test/support/sweep_evidence.ex`: 1–110, 245–370 | Complete exact ranges emitted together once; both labels present, no truncation marker. |

No implementation source was edited and no tests were run. No audited OTP
API, callback, atom sink, or generated-code path was invoked.

## Count-only transfers (separate from source review)

The event-2 rendered payload used plain extraction with one concise anchor label
per range. It contained 1,213 source lines and 8 label lines (1,221 total),
47,039 bytes, SHA-256
`1a30248724a2a5697bc79aba53d791475fa876ade17e7039e1402007203c4537`, and
12,356 `gpt-6-luna` input tokens from `POST /v1/responses/input_tokens`.

The fresh combined count-only bundle covered 16 file inputs: the six
plan-selected documents (config, plan, execution context, replan,
phase-deliveries, planning-gates), plus ten additional project/executor context
and receipt files loaded for this task (AGENTS, CLAUDE, STATE, North Star,
Clearance, Glossary, ADR README, Verification, recovery receipt, checkpoint).
It also covered the exact payloads for source events 2–4 and incomplete-event
receipt text only. It did not include either partial source body or access the
full archive manifest. The direct combined count was 48,851 tokens before event 2, before
event 3 (including complete event 2), and before event 4 (including complete
events 2–3). At each gate the projection remained 48,851 + 12,000 future-source
cap + 5,000 task-output allowance = 65,851 / 69,000 working tokens, plus the
31,000 reserve = 96,851 / 100,000 total, leaving 3,149 tokens of slack.

Count-only transfer scope was limited to the event-2 payload and the combined
fit bundles just described. These counts are sizing measurements, not semantic
evidence. The prior partial event bodies were neither loaded nor reproduced.

## Source handoff

### TierSweepTest

- The archive citation assertion at `test/contract/tier_sweep_test.exs:1360–1485`
  resolves each citation through `SweepEvidence.resolve!/2` and checks archive
  origin, matching digest, expected text, and recorded byte size.
- The matcher fixtures at `2840–2905` keep core/floor expected match sets
  lane-specific and define explicit exclusion reasons. The nearby table and
  caller-chain test region at `5030–5125` preserves duplicate caller edges and
  lowest-arity selection in its expected index.
- `setup_all` creates one graph for the suite at `5030–5125`. The identity
  contract at `7670–7905` calls `original_identity_ledger!/0`, checks 221
  exclusions and five distinct lane-metadata identities, and rejects dropped,
  duplicated, substituted, misowned, or payload-mutated rows. It keeps
  exclusion identities distinct from lane metadata.
- EX-010 assertions at `8390–8560` require both lane records, retained callback
  front dispositions for `inets:enable_trace/2,3`, empty guard patterns, and
  reject missing, duplicated, wrong-lane, reordered, or unsupported evidence.
- The `build_graph` excerpt at `10620–10695` shows lane-bound installed OTP
  discovery, completeness checking, inspection and source inventory calls,
  followed by inclusion of historical-active and pending installed apps. This
  scheduled excerpt ends inside the builder; its remaining graph construction
  was not inspected, so no claim is made about those omitted lines.
- The helper assertions at `13440–13620` compare exact recorded MFA, trace,
  verdict, replacement, fixture, citation and lane sets. The identity loader at
  `14070–14330` verifies the snapshot and budget SHA-256 values before deriving
  original rows and replacement references. Those are source-level checks; the
  loader was not run.

### InstalledOtp

- `test/support/installed_otp.ex:1–130` pins core and floor Elixir/OTP
  identities. `discover!/2` expands the root, rejects symlink and invalid app
  roots, and rejects duplicate applications or modules while preserving
  structured inventory errors.
- At `245–345`, the discovery-completeness contract reports missing or extra
  discovered, inspected and ingested sets. `export_inventory!/2` accepts an
  injectable BEAM-chunk reader, rejects duplicate exports, validates each BEAM
  module name against its filename, and includes the predefined metadata
  exports used by edges.
- At `1683–1701`, lane/version validation uses the pinned identity and receipt
  lock hashes must be lowercase 64-character SHA-256 values equal to the
  expected lane digest. Receipt paths must be relative and exclude traversal,
  empty segments, backslashes, NULs and colons.

### SweepEvidence

- `test/support/sweep_evidence.ex:1–110` pins the exact-source archive digest,
  core/floor OTP and Elixir lock identities, and source identities with paths,
  byte counts and digests. The error type carries a stable reason and detail.
- At `245–370`, `source_roots!/0` validates archive locks and joins the
  lane-bound installed inventory with Elixir and dependency roots. Archive
  entries must be regular files at safe relative paths. `resolve!/2` resolves
  a citation under its real source root, verifies the content digest, and
  rejects out-of-range line references.

## Handoff limits

These observations describe existing source contracts only. The static evidence
boundary remains in force; candidate stays null, implementation authorization
stays false, the aggregate gate stays open, Walking Skeleton stays blocked, and
SEC-01 remains Pending. Keep the actual-library-collision stop and Macro
caller-AST and explanation checkpoints. The next implementation task must first
meet its own reviewed preconditions and retain the early record consistency
checks in the plan.
