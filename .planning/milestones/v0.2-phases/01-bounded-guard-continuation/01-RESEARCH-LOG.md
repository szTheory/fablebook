# Phase 1 planning record

Invocation: `$gsd-plan-phase 1`, continuing the EX-010 scope selected in INT-20261111-05. Checkout: `.claude/worktrees/agent-planning-main-261111`, branch `worktree-agent-planning-main-261111`. The dirty primary and recovery worktrees remain preserved. No phase implementation or source archive modification is part of this planning run.

## Research and fit

The researcher verified the candidate source identities against exact local lane sources and found the relevant tracing path extends into `dbg.erl`. The complete known baseline is six full lane-specific files, 75,406 historical tokenizer tokens, rather than the four-file pilot. Exact hashes and byte counts are in `01-RESEARCH.md`; no source was downloaded and no audited tracing API, callback or atom sink was invoked.

An initial reserve estimate added 31,000 tokens to the combined lane sources and treated the resulting 106,406 as a phase-wide context failure. Independent pre-plan review compared the inherited limit with delivered Phase 01.1.1.18: context fit is assessed separately for isolated serial plans, with structured findings passed to integration. The revised allocation retains the entire reserve in each context and reads every lane file in full. `01-SIZING.md` records 67,518 core, 69,888 floor and up to 71,000 integration tokens, assumptions, effort estimates and expansion stops. No literal-data compression is claimed for debugger code. This supports planning, not a semantic disposition.

## Current graph and environment recovery

The clean checkout initially lacked dependency sources. A direct test stopped before running tests. A retry with the primary dependency path and a separate build path reached Rebar's nested dependency cache and was interrupted. Dependency sources were then copied into isolated local directories, excluding nested build/git/dependency caches and dereferencing symlinks. Subsequent builds and tests used only these copies; no dependency fetch was needed.

The existing static full-graph check `test/contract/tier_sweep_test.exs:5234` passed independently with core Elixir 1.20.4 / OTP 29.1.2 and floor Elixir 1.18.5 / OTP 27.3.4.9. Each selection ran four tests successfully. Commands used the copied `MIX_DEPS_PATH`, isolated `MIX_BUILD_PATH`, exact runtime PATH and floor flag where applicable. Local logs and full receipts are retained outside tracked source; compressed receipts are in `_build/phase1-research-receipts/`.

`01-GRAPH-OBSERVATIONS.json` records the current receipt digests, inventory metrics, two selected MFAs per lane and zero outside-selected matches within EX-010. It preserves the distinction between full export discovery, active-projection edges and the researcher's OTP-only Xref query. Zero direct incoming edges does not establish absence of dynamic callers. Other original rows and dispositions remain owned by the unchanged canonical ledger; this observation is not a replacement ledger.

## Planning gates

- Project plan preflight passed before mutations; STATE strict validation passed.
- Frontend gate reported no frontend scope. Context drift reported no stale artifacts; codebase drift skipped because no structure map exists.
- No SPEC exists. The shared section helper confirmed both edge and prohibition sections absent. The deterministic fallback probe proposed nine applicable edges for GRC-01 through GRC-03; the planner must account for all of them without silent dismissal.
- Research, independent fit review, pattern mapping, plan writing and final plan checking use separate agent contexts. The fit review is not the final executable-plan verification.
- Codex collaboration exposes terminal agent messages/status but no asynchronous output-file path. Completion/stall observation uses those actual messages and artifact activity; no output-file path or worktree isolation is fabricated.

Final plan-check results and local verification are appended after the plans are reviewed. No implementation, merged phase delivery, aggregate closure or runtime SEC-01 proof is claimed by planning.

## Review corrections

The initial independent check found an unsuffixed research question that confused future implementation proof with an unanswered planning choice. The research now records the resolved known source allocation and a stop before any newly required source is consumed; semantic results remain execution deliverables. The integration file-count advisory was addressed with a rationale that preserved every actual path rather than concealing scope.

A subsequent review identified a real ordering cycle: Plan 03 attempted `--stage verify` before its own truthful summary could exist, while that stage requires every plan summary (`test/support/planning_state.ex`, `phase_errors/6` and `summary_errors/1`). The ship boundary also needs the single passed phase verification report. Delivery must therefore follow completed implementation summaries and technical verification, with the owner merge decision and actual receipt bookkeeping handled after plan execution. No fake early summary, weakened preflight or extra numbered phase is an acceptable remedy. Planning acceptance remains pending the corrected sequence's independent recheck.

## Final planning acceptance and handoff

The corrected sequence passed fresh independent review after two producer revisions, with zero remaining blockers or warnings; see `01-CHECK.md`. There are three serial plans and six implementation tasks. Plan 03 ends with implementation/candidate work and a truthful summary; its concrete orchestrator handoff defers verify, ship, exact-candidate owner approval, actual merge and observed delivery bookkeeping until their real prerequisites exist. Generic automatic phase completion must wait for actual merged delivery. No additional phase or weaker gate was introduced.

Final local evidence:

- Both exact-lane static full-graph selections passed; `01-GRAPH-OBSERVATIONS.json` records their source-independent observation limits and current two-MFA partitions.
- `elixir -r test/support/git_diff.ex -r test/support/planning_state.ex -r test/test_helper.exs -r test/planning/intent_test.exs -r test/planning/contract_rule_test.exs -r test/planning/planning_state_test.exs -e ''` passed all 50 planning regression tests after canonical bookkeeping updates.
- SDK plan structure/frontmatter checks passed for all three plans; all 18 declared command failure directions passed. The command-path probe does not recognize these wrappers and reports `not_applicable`; it is not represented as a path pass.
- Decision coverage passed 13/13; post-planning gap analysis passed 16/16; no duplicate non-reserved threat IDs were found.
- Strict STATE validation and the Phase 1 execute preflight passed. Requirements and plan completion remain unchecked; implementation has not started and the active-era delivery registry has no new receipt.
- Review/log filenames were changed to `01-CHECK.md` and `01-RESEARCH-LOG.md` because the installed SDK treated the earlier names as plan-shaped files. A fresh `find-phase 1` now returns exactly the three canonical plans with no filename warning.

Bookkeeping uses SDK planned-phase/progress/dependency/session handlers and the generated state publisher. The SDK maps the prose `Ready to execute` to its broad `executing` category; an explicit SDK Status patch retains `planning` because implementation is unstarted, while the phase position and plan count describe readiness. Stale free-prose roadmap/requirements/intake status was reconciled without changing acceptance. The generated projection still offers a generic progress/plan recommendation despite `find-phase 1` returning three plans; it remains advisory and is not hand-edited. Canonical STATE, the reviewed plans and the passing execute preflight govern the next action.

Next actor: the owner may run `$gsd-execute-phase 1`; the agent then implements the selected scope and continues authorized checks/review/publishing until a real safety or exact-candidate merge boundary. Do not rerun discussion, planning or progress merely because the SDK projection's generic next label is stale. No implementation or later phase was started during planning. Planning changes are committed locally and carried on the next substantive push rather than generating receipt-only CI.
