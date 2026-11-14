---
status: source-gate-pending
phase: 03
plan: 03-01
updated: 2026-11-13
---

# Phase 03-01 Bounded Replan Receipt

## Decision and position

The owner selected “Replan within limits.” The canonical checkout is `~/projects/fablebook`, branch `main`, at `527e27c` (24 commits ahead of fetched `origin/main`). The documentation-only recovery is committed as `a6d99e4`; the truncation checkpoint is committed as `527e27c`. No implementation source changed and no tests ran.

The first Task 03-01-04 source event remains consumed: one 12,419-token count-only-estimated acquisition of the eight scheduled `TierSweepTest` ranges returned 11,819 tool-output tokens with 1,819 omitted. Its complete content cannot be verified. It is retained as an incomplete incident event and is not evidence or completed work.

## Revised event schedule

- **03-01-03 recovery segment:** remains completed, committed, and unchanged with zero semantic source events. Its separately gated source-notes continuation has one complete acquisition each of the same eight `TierSweepTest` ranges, `InstalledOtp` ranges 1–130, 245–345, 1683–1701, and `SweepEvidence` ranges 1–110, 245–370. Produce a concise, anchored interface note; make no code or test changes. This continuation is within the existing Task 03-01-03 node, preserving the hard 2–3 task limit per plan.
- **03-01-04, tracer:** event 1 remains the consumed truncated event. Event 2 inspects the complete created collector (maximum 3,000 tokens); event 3 inspects the complete newly added tracer test region (maximum 2,000 tokens). The task therefore has three actual events, below its five-event ceiling.
- **03-01-05, expansion:** retain its existing four-event schedule and per-event caps.

The source-notes continuation has a separate, useful output consumed by the tracer. It does not reset or erase the partial event. The plan remains at three tasks, and every task remains at or below five events. The shared context and all inherited safety stops remain unchanged.

## Fresh context fit

The prior 50,044-token result and 1,956-token slack are historical. An overbroad draft bundle that also loaded full state, verification, phase-context, validation and ADR documents measured 60,964 tokens and could not fit with the inherited caps. The revised plan context uses the compact, cited execution note and current replan receipt, while retaining the small canonical config, delivery and gate registries. It does not lower evidence or safety requirements.

The pre-review candidate snapshot was 45,678 tokens and is historical. After the PASS review and execute preflight, a fresh direct combined count-only request for the six planning inputs, the single matching archive-manifest row, and all scheduled known source spans returned **45,764** `gpt-6-luna` tokens. With the four future source acquisitions capped at 12,000, the task-output allowance at 5,000, and the unchanged 31,000-token reserve, this projects 62,764 of the 69,000-token working allocation and **93,764 of 100,000 total, leaving 6,236 slack**. The combined count is authoritative; standalone subgroup counts are not additive. Use only `POST /v1/responses/input_tokens`; do not call an inference endpoint. The ignored `.env.local` key remains mode 600 and must not be printed. Recount before each subsequent semantic source event and stop if the full untruncated acquisition and remaining allowances no longer fit.

## Data-scope correction

During the replan lookup, a Python command parsed the full archive manifest instead of selecting only the allowed matching row. The shell output was clipped by the tool before its full parent record reached the conversation. This was local metadata; no source body, API key, count request, or network request was involved. This violated the existing single-row handling rule. For all further work, locate the exact row by path and extract only that bounded row; never parse or print the full manifest again. No implementation/source read or test has resumed.

## Gate and next action

Independent review of the corrected three-task revision passed. Execute preflight and a fresh exact cumulative count remain required before Task 03-01-03's source-notes continuation. If the count does not fit, stop and record the exact gap; do not spend the reserve or reduce evidence/safety gates. Keep `candidate=null`, `implementation_authorized=false`, `aggregate_gate=open`, Walking Skeleton blocked, and SEC-01 Pending.

## Credential exposure and pause

During resumed count setup, a search command included ignored `.env.local` and emitted its `OPENAI_API_KEY` assignment in local tool output. That command made no network request. The key value is omitted from this receipt and must be treated as exposed; it will not be used again. The owner must revoke it, issue a replacement, and update `.env.local`. After that credential change, rerun execute preflight and the exact combined count before any semantic source acquisition. No source body, implementation change, or test occurred in this resumed turn.

## Review iteration

The first independent review returned **BLOCK**: the draft added a fourth task beyond GSR-05's 2–3-task limit, used absolute home paths in git-bound notes, and left an ambiguous exception in the source-note read list. This revision keeps three task nodes by placing the source-note continuation inside 03-01-03 without changing its committed zero-read recovery receipt, uses `~/projects/fablebook`, and restricts that continuation to its three exact scheduled path groups. No source read or test occurred while correcting these findings.

The second independent review returned **PASS** on the corrected three-task plan. It confirmed the 45,678-token count snapshot and 93,678-token projection, the consumed Task 03-01-04 event, exact source limits, the explicit 16,000/18,000 output ceilings, and unchanged safety gates. It authorized source work only after execute preflight and a fresh exact count. The count snapshot must be refreshed because this outcome was added to the receipt afterward.
