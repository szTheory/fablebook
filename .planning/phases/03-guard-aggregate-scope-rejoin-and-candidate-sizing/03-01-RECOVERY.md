---
phase: 03
plan: 03-01
task: 03-01-03
status: stopped-before-source-work
updated: 2026-11-13
---

# Phase 03-01 Bounded Recovery Receipt

## Position and retained incident

- Checkout: `~/projects/fablebook`, branch `main`; v0.4 Phase 3, Plan 03-01, Wave 1.
- The prior attempt, retired as 03-01-01, made 13 exact-source body-read events: nine in `test/contract/tier_sweep_test.exs`, two in `test/support/installed_otp.ex`, and two in `test/support/sweep_evidence.ex`. This exceeded its five-event ceiling by eight. No task files, task commits, or summary were produced. Per-file regions and the unknown cross-file order remain in [03-01-READ-LEDGER.md](03-01-READ-LEDGER.md); the original stop and owner choice remain in [03-01-CHECKPOINT.md](03-01-CHECKPOINT.md).
- The original identity excerpt and `test/contract/asn1_rtt_integration_test.exs` body were not read in that attempt. Its compact interface notes remain unverified leads. This recovery does not edit or supersede either historical record.
- The bounded re-plan passed independent review. The owner chose to preserve all existing per-task and context limits.

## New task sequence and event ledgers

No new source-body event has occurred. Counts below are independent task ceilings; the retired attempt creates no allowance.

| Task | Purpose | Actual source-body events | Maximum |
|---|---|---:|---:|
| 03-01-03 | Documentation-only recovery and fit check | 0 | 0 |
| 03-01-04 | One-row core/floor tracer | 0 | 5 |
| 03-01-05 | Full original-row and partition expansion | 0 | 5 |

The reviewed schedule for 03-01-04 is: (1) one batched `tier_sweep_test.exs` acquisition of lines 1360–1485, 2840–2905, 5030–5125, 7670–7905, 8390–8560, 10620–10695, 13440–13620, and 14070–14330; (2) `installed_otp.ex` lines 1–130, 245–345, and 1683–1701 in one acquisition; (3) `sweep_evidence.ex` lines 1–110 and 245–370 in one acquisition; (4) one complete read of the newly authored collector; and (5) one complete read of the newly added aggregate test region. The exact schedule and reasons are in the revised [03-01-PLAN.md](03-01-PLAN.md).

The reviewed schedule for 03-01-05 is: (1) one batched TierSweepTest acquisition of the original ledger/current matcher, EX-107 partition, and aggregate regions identified in the tracer notes; (2) one complete collector read; (3) `test/contract/asn1_rtt_integration_test.exs` lines 1–114; (4) the full immutable `01.1.1.5-ORIGINAL-IDENTITY-SOURCE.txt` excerpt after validating its archive digest; and (5) one final complete collector reread. Five is a maximum, not a target. No supplementary or sixth read is permitted; a missing region becomes a named evidence gap.

## Context-fit measurement

The accepted ceiling is 100,000 tokens for the whole isolated Plan 03-01 context, with a fixed 31,000-token reserve for instructions, evidence/review, verification output, and bounded fixes. The other required context, source/data, rereads, and conservative output allowance must therefore fit within 69,000 tokens across all three tasks. Task boundaries do not reset either number.

The selected runtime is GPT-6 Luna. The local Codex model catalog exposes a context window but no tokenizer identity or exact prompt-token meter. The GSD `prompt-budget` utility uses `ceil(text.length / 4)`, which is a heuristic and is not an exact fit certificate; local Python `tiktoken`, `tokenizers`, and `transformers` modules are unavailable. No package was installed. Tool-provided `original_token_count` values are explicitly approximate and are not treated as exact measurements.

An exact-count route exists through the official [OpenAI input-token count endpoint](https://developers.openai.com/api/docs/guides/token-counting), which documents exact model input counts including request framing. The model catalog lists [GPT-6 Luna](https://developers.openai.com/api/docs/models/gpt-6-luna), but the endpoint's examples use GPT-6 Astra; support for this exact GPT-6 Luna runtime must be confirmed before relying on it. The local environment has no `OPENAI_API_KEY`. No API request was made: using that route would send the selected project context to the OpenAI API and may incur API usage charges, so it needs owner authorization and credentials. No other exact local counter was found.

For scale only, the full on-disk byte total of the planning inputs inventoried for the task is 208,970 bytes for PROJECT, STATE, config, REQUIREMENTS, ROADMAP, the plan, validation, CONTEXT, RESEARCH, PATTERNS, checkpoint, read ledger, delivery registry, planning gates, and the two scoped ADRs; the separately read North Star, clearance, glossary, ADR index, and verification policy add 29,553 bytes. These are file-size totals, not token counts or a claim that every byte was loaded into the model context. Full-file byte sizes for scheduled source inputs are also not token counts: TierSweepTest 724,059 bytes, InstalledOtp 59,165 bytes, SweepEvidence 100,851 bytes, ASN.1 integration test 8,464 bytes, and the identity excerpt 33,534 bytes. The compressed exact-source archive is 3,027,494 bytes; its body was not opened here.

The required tokenizer-derived input total, the source-event token totals, and the resulting conservative output allowance are therefore **unmeasured**. No rigorous upper bound showing that they fit the 69,000-token allocation is available from this runtime. The fixed reserve remains 31,000; the current remaining allowance cannot be truthfully computed. The plan prohibits replacing this measurement with bytes/4 or the GSD heuristic. Accordingly, no source-body event has been started, and 03-01-04 remains gated.

## Safety and authority state

- No implementation source, original identity excerpt body, ASN.1 integration body, or archived OTP source body was opened by task 03-01-03.
- No audited OTP API, callback, atom sink, or generated-code path was invoked. The prior initial scan remains only an initial scan, not collision clearance. Stop on any actual-library collision with its exact MFA, site, input, and triggering guard.
- Keep `candidate=null`, `implementation_authorized=false`, `aggregate_gate=open`, Walking Skeleton blocked, SEC-01 Pending, and all existing guard/caller-AST/wording stops unchanged. No disposition, guard change, or follow-on authority is created.

## Pause and next action

Plan 03-01 stops before its first source-body event because its required fit proof cannot be made with the available local measurement. Recommended next step: the owner provides a trusted local model-tokenizer/context meter, or authorizes use of the official API count endpoint after credentials are available. Do not raise the limits or continue to the tracer until the required 69,000-token fit is rigorously established. Owner acts next on the measurement route; no implementation-source work is underway.
