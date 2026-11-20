# Phase 7: Guard Scope Reconciliation

**Current result:** `reconciled_with_explicit_source_gaps`

**Current core pin:** `phoenix_live_view` 1.2.14

**Evidence generation:** `phase7-security-rebaseline-10a940e92bbb948a`

This document describes the current evidence after the owner-authorized LiveView security patch. The original reconciliation remains byte-for-byte in [pre-rebaseline history](history/2026-11-20-before-security-rebaseline/07-RECONCILIATION.md); the original lock and verification are historical evidence for LiveView 1.2.13. The complete machine-readable current reconciliation is [`security-rebaseline/07-RECONCILIATION.json`](security-rebaseline/07-RECONCILIATION.json).

## Current core membership and proposed family

| Current core evidence | Value |
|---|---|
| `mix.lock` SHA-256 | `3c55e9ec28da1fe2f8ded5a8b5e6504542c3536df25c704933cd7ace85224207` |
| LiveView version | `1.2.14` |
| LiveView package checksum | `80a248539e566eea8598079b12bfb1a9c1f3180d4db3ecd215d28798dcebc44b` |
| LiveView repository checksum | `1ca75ed52d3916f93299de990f152f3f49202d12849e526bf5f9b89b4ccf25f2` |
| Compiled BEAM files / exports | `2,061` / `54,763` |
| Saved core rows / MFAs | `226` / `1,763` |
| Core membership digest | `be2e44b8f59c2121ba7b8c8c358baed7cd355de6cceba419c40034e34c140327` |

All saved core rows and MFAs remain present. The seven-member family and full complement are unchanged from the saved scope:

- Family: 7 MFAs, digest `815a13260bebe56391c4a24cfccd349575f19211dc6c0b9e6f8a265035bab674`.
- Complement: 1,756 MFAs, digest `4315ef6fb9604d8be5d3faef6dfa87acd0d191714ace5484b76354cf75af2060`.
- Partition: disjoint and union equals the complete 1,763-MFA membership.
- Family identities: CN-002 through CN-006; CN-001 remains outside the family because neither lane has a live MFA for it. The exact MFA rows and full complement are in the current JSON.

The current export generation was produced from the pinned core lane, bound to the full lock digest, and scanned only after independent review of the exact BEAM manifest and roots. The updated lock contains only the authorized LiveView entry change. `mix.exs`, `mix.floor.lock`, and the accepted ENV06 evidence are unchanged.

## Retained floor evidence

The floor lane was not rescanned. Its accepted ENV06 membership remains 1,718 MFAs (digest `7777eccd50d42a1d38acaba73b0ac6cc7e699ff09e4cd5b9c595890cfb8aaef2`), with the same 7-MFA family (digest `815a13260bebe56391c4a24cfccd349575f19211dc6c0b9e6f8a265035bab674`) and 1,711-MFA complement (digest `4315ef6fb9604d8be5d3faef6dfa87acd0d191714ace5484b76354cf75af2060`). The current reconciliation records the accepted floor lock and source-reconciliation digest and explicitly marks this evidence as reused without rescan.

## Current core source evidence

The core-only current schedule is [`07-CURRENT-SOURCE-SCHEDULE.json`](security-rebaseline/07-CURRENT-SOURCE-SCHEDULE.json), SHA-256 `4234596c2d4dcd7c04fada75468e809d7bbe32896982a5199702310518bc224d`. Its independent review and approval bind to that exact digest. All five spent request IDs remain provenance only; there were no new source reads, reopened requests, or retries. One prior Plug observation carries forward on exact source and package identity. Four entries remain gaps:

| Request | Current treatment | Why |
|---|---|---|
| `core-source-01` | Gap; no retry | Prior parse failed; it does not establish current source evidence. |
| `core-source-02` | Gap; no retry | The consumed request has no durable source hash. |
| `core-source-03` | Gap; no retry | The consumed request has no durable source hash and its LiveView package identity changed to 1.2.14. |
| `core-source-04` | Carried forward | Prior parsed Plug observation retains its exact durable source hash and package checksum. |
| `core-source-05` | Gap; no retry | Prior parse failed; its captured source hash is provenance only. |

No target source body was read for this generation; no runtime API was called and no generated code was executed. These observations do not establish package-wide caller closure. Dynamic dispatch, external callers, callbacks, aliases/imports, macros, generated code, and unsupported syntax remain outside the demonstrated evidence where applicable.

## Refreshed sizing and limits

Current scope sizing is 2,061 BEAM files, 54,763 exports, 226 saved rows, 1,763 saved core MFAs, a 7/1,756 core family/complement, five schedule entries, one carried observation, four explicit gaps, and zero new source reads. Because no source bodies were reopened, there is no new source-byte or token measurement for the remaining gaps; the prior estimates are retained only in the historical reconciliation and must not be treated as current measurements. The five-file batch cap, 2 MiB per-file cap, no-truncation rule, one-use requests, and no-runtime-API boundary remain unchanged.

## Preserved stops

- Candidate remains null; candidate fit unresolved; guard implementation unauthorized.
- Aggregate gate remains open; actual-library collision remains unknown.
- R9 remains denied and unconsumed; SEC-01 remains Pending.
- Macro caller-AST and explanation gaps remain unresolved; legacy digest unresolved.
- Walking Skeleton remains blocked; automatic follow-up is disabled.
- All five core source requests remain closed. No further increment is authorized by this evidence.

## Recommendation and owner decision

Keep the candidate null and aggregate gate open. Four source entries remain gaps, including the LiveView no-retry gap, and the evidence does not show package-wide caller closure. The bounded result stops here and does not promote implementation.

**Owner decision:** After reviewing these explicit source gaps and the complete complement, should any further guard increment be authorized?
