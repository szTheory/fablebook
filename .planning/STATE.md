---
gsd_state_version: "1.0"
current_phase: 01.1.1.3.1.3
current_phase_name: Debugger installed-wide acceptance
status: executing
stopped_at: Phase 01.1.1.3.1.3 planning complete; execution started
last_updated: "2026-11-02T00:01:43.973Z"
last_activity: 2026-11-01
last_activity_desc: Phase 01.1.1.3.1.3 plans verified; implementation started
state_head: 134fd0d670ae23f9be612fb17c875d259f952710
progress:
  total_phases: 41
  completed_phases: 1
  total_plans: 31
  completed_plans: 25
  percent: 2
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-30)

**Core value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.
**Current focus:** Phase 01.1.1.3.1.3 — Debugger installed-wide acceptance

## Current Position

Phase: 01.1.1.3.1.3 (Debugger installed-wide acceptance) — IN PROGRESS
Plan: 1/2
Status: Executing
Last activity: 2026-11-01 — Phase 01.1.1.3.1.3 plans verified; implementation started

Progress: 1/41 phases complete ([░░░░░░░░░░] 2%); 25/31 plans complete; nested phase plans do not change parent completion counts

## Performance Metrics

**Velocity:**
- Total plans completed: 14
- Average duration: 34.2 min
- Total execution time: 8.6 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01.1.1 | 5 | 316 min | 63.2 min |
| 01.1.1.3.1.1 | 4 | - | - |
| 01.1.1.3.1.2 | 5 | - | - |

**Recent Trend:**
- Last 5 plans: 16, 32, 73, 167, 28 min
- Trend: mixed; execution time varies by plan scope

*Updated after each plan completion*
**Per-Plan Metrics:**

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 1 P01 | 13min | 3 tasks | 26 files |
| Phase 01 P02 | 21min | 4 tasks | 10 files |
| Phase 01 P03 | 11min | 3 tasks | 15 files |
| Phase 01 P04 | 17min | 3 tasks | 8 files |
| Phase 1 P05 | 85min | 7 tasks | 16 files |
| Phase 01.1 P01 | 10min | 3 tasks | 11 files |
| Phase 01.1 P02 | 6min | 3 tasks | 4 files |
| Phase 01.1 P03 | 11min | 3 tasks | 13 files |
| Phase 01.1 P04 | 6min | 2 tasks | 2 files |
| Phase 01.1 P05 | 17min | 2 tasks | 1 files |
| Phase 01.1.1 P01 | 16 min | 3 tasks | 27 files |
| Phase 01.1.1 P02 | 32min | 3 tasks | 14 files |
| Phase 01.1.1 P03 | 73min | 3 tasks | 18 files |
| Phase 01.1.1 P04 | 167min | 3 tasks | 3 files |
| Phase 01.1.1 P05 | 28min | 4 tasks | 13 files |
| Phase 01.1.1.3.1.2 P01 | 512min | 2 tasks | 7 files |
| Phase 01.1.1.3.1.2 P02 | 96min | 2 tasks | 4 files |
| Phase 01.1.1.3.1.2 P03 | 212min | 2 tasks | 6 files |
| Phase 01.1.1.3.1.2 P04 | 132min | 2 tasks | 5 files |
| Phase 01.1.1.3.1.2 P05 | 51min | 3 tasks | 13 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- [Roadmap]: INT-20261028-16 - the split rule wins; 12 families kept as headings, 35 sequential phases of 3 to 5 plans.
- [Roadmap]: Pulled forward: Phase 6 (thin bundle slice), Phase 10 (installer core), Phase 19 (bundle core with canon).
- [Roadmap]: SEC-04 completes in Phase 6, SBOM sits in Phase 1, `gen.screens` sits in Phase 28 (see ROADMAP Deviations).
- [Roadmap]: CTRL-05, CORE-15 and CORE-16 are not v1; they stay unmapped until the owner answers Q10 and Q14.
- [Phase 1]: Owner chose approve-all (INT-20261028-18): phoenix >= 1.8.9 and < 2.0.0, phoenix_live_view >= 1.2.9 and < 2.0.0, floor lock 1.8.9 / 1.2.9, latest lane Elixir 1.20.4 / OTP 29.1.2
- [Phase 1]: Prod-guard message test adds the router require via Macro.Env.define_require/3; Elixir 1.20 flags a module-level require as unused
- [Phase 01]: Owner chose public (INT-20261028-19): szTheory/fablebook is public; ruleset 26086901 requires only ci-gate (integration 15368)
- [Phase 01]: Dependency graph enabled through Dependabot alerts so dependency-review runs; no D-15 control turned off
- [Phase 01]: bin/ci_health --file-regression <job> [note] is the single open-or-create quality-regression path for ci.yml and hex-publish.yml
- [Phase 01]: Credo ban check is loaded at test compile time; Elixir 1.20 warns on calls to a runtime-only module
- [Phase 01]: Ban tiers, allowlists and regexes live as data in the contract tests; Credo banned_names/0 is asserted equal to the BEAM atom tier
- [Phase 01]: Contract-test rule flags any non-addition status on a guard path (M, D and T)
- [Phase 01]: GitDiff fails closed on a malformed, zero or unknown push before SHA and scrubs GIT_* env
- [Phase 1]: The CHANGELOG seed is empty before the first release; release-please demotes and appends a header-only seed
- [Phase 1]: The package-scoped Hex key never expires and has Publish permission on fablebook only (INT-20261028-20)
- [Phase 01.1]: Code.format_string! and Code.format_file! are banned now; a future need adds an @allowlist entry through its own ADR
- [Phase 01.1]: :file.consult and :file.path_consult stay allowed: trusted compiled term files (Q13(a) .app discovery)
- [Phase 01.1]: The MFA existence test loads :xmerl via Mix.ensure_application!/1 because Mix prunes the code path; mix.exs unchanged
- [Phase 01.1]: hex-production v* deployment policy stays until the owner answers Q37 (D-14 names main plus v*)
- [Phase 01.1]: Recovery publishes docs only when the release exists with a matching checksum and has_docs false; mismatch or other status fails closed
- [Phase 01.1]: WR-01, WR-04 and the WR-05 settings half are owner questions Q36, Q35, Q37, not implemented
- [Phase 01.1]: SEC-01 stays Pending (Phase 5); 01.1-03 advances only its static-ban share
- [Phase 01.1]: CR-02 (truth 7), T-01.1-25 and T-01.1-28 transferred to Phase 01.1.1 per INT-20261029-03; @mfa_tier stays at 45
- [Phase 01.1]: BEAM guard over-catches (Regex.compile/1, [epp: 1], [io: :read], [compile: true]) are pinned by the known-strictness test; a lib/ hit is fixed in lib/, never allowlisted without an ADR
- [Phase 01.1]: hex-publish resolves the tag to one commit in step ref before tag-supplied setup; publish and smoke check out needs.build.outputs.sha; package publish requires the rebuilt sha256 to equal the build's
- [Phase 01.1]: Release window: no release-please PR merges until 01.1-05's hex_publish_test.exs guard is on main
- [Phase 01.1]: hex_publish_test.exs models actions/checkout and runs the build's pre-test steps behind it; exit 0 must mean HEAD is the tag's commit on origin/main
- [Phase 01.1]: Release window closed: hex_publish_test.exs is on main (92588ac); release-please PRs may merge again
- [Phase 01.1.1]: Mix.Project.compile/1,2 and :elixir_erl.compile are tier entries: argv reaches --erl-config (:file.consult) and --tracer (Module.concat); the module map's definitions reach compile:noenv_forms
- [Phase 01.1.1]: The whole-module literal check ignores called and captured function names; m.compile(s) is the one shape it stops catching, pinned by StrictVarModuleCompile (Phase 5 backstop)
- [Phase 01.1.1]: debugger:start/1,2 reads caller-selected settings and interprets their files; add the function wildcard entry, giving 172 tier entries
- [Phase 01.1.1]: Mix.Tasks.Phx.Gen.run/1 is fixed_args on both lanes because its arguments are ignored and it invokes fixed help-search arguments.
- [Phase 01.1.1]: SEC-01 remains Pending; Phase 5 owns requirement completion.
- [Phase 01.1.1]: The cited INT-20261029-06 source was added verbatim so the existing phase-summary citation and intent-corpus CI checks resolve.
- [Phase 01.1.1]: The live boundary contract shares sweep barriers and base sinks and derives delegates from the forward call graph on each supported lane.
- [Phase 01.1.1]: New loader and evaluator fronts are mirrored in the contract tier and Credo; safe sweep rows use cited function-scoped dispositions, and SEC-01 stays Pending for Phase 5.
- [Phase 01.1.1.3.1.2]: The adopted ledger remains the ownership authority; exact-lane acceptance derives current sets instead of freezing historical totals.
- [Phase 01.1.1.3.1.2]: Installed source is accepted only when current lane bytes match the adopted exact-source row and pass path, type, containment, and citation checks.
- [Phase 01.1.1.3.1.2]: Resolve installed debugger source through its adopted exact_source row and retain regular-file and realpath containment checks without expanding the archive.
- [Phase 01.1.1.3.1.2]: Keep dbg_wx_win:verify/2 and its integer scanner, term scanner, and term parser branches in the monitor group; trace records cite callers and cross-link to monitor-owned verifier records.
- [Phase 01.1.1.3.1.2]: Represent the conditional breakpoint route as three records: current dbg_wx_break:gui_cmd/2 tuple construction, current dbg_icmd:cmd/4 dispatch, and prior-owned dbg_icmd:break_p/4 callback body.
- [Phase 01.1.1.3.1.2]: Treat erl_scan:string/1,3 as an atom-interning scanner boundary distinct from extended_parse_term/1; Plan04 needs an atom-free tokenizer/parser boundary or an explicit limit on term editing.
- [Phase 01.1.1.3.1.2]: Classify local SetStyle, Change, ChangeH, and prior-owner StrFun closures as fixed capabilities only where exact construction and invocation sites establish that origin.
- [Phase 01.1.1.3.1.2]: Keep fourteen new debugger guards function-scoped and mirrored.
- [Phase 01.1.1.3.1.2]: Record the empty changed-family exclusion intersection without claiming removal witnesses.
- [Phase 01.1.1.3.1.2]: Preserve the four inherited pending function assignments and adopted ledger.
- [Phase 01.1.1.3.1.2]: Explicit debugger-remainder delivery preserves the selected-settings default and binds evidence to current source, ownership, head, and run.
- [Phase 01.1.1.3.1.2]: T-15 remains recorded against the undigested pre-fix checker state; the final strict controls pass, but no third review or independent final sign-off is claimed.
- [Phase 01.1.1.3.1.2]: Installed-wide acceptance, runtime safety, and SEC-01 remain pending under their existing owners.

### Pending Todos

None yet.

### Blockers/Concerns

- [Phase 01.1.1.1 execution]: Plan 01 task 01-02 explicitly requires a split: 221 original exclusions expand to 2,395/core and 2,307/floor matching functions and 10,970,916/core and 10,244,028/floor source bytes. Read the phase AUDIT-BUDGET and halted SUMMARY; original boundary count is 33, not 44. Source archive approval is resolved. Remaining creator WIP and its six Logger/ExUnit findings are preserved separately; do not merge it or dispatch dependent plans.

- [Parent verification debt]: Phase 1 and 01.1 reports remain gaps_found; phase.complete routed to Phase 1 for re-verification. Do not mark either parent complete from the child report.
- [Phase 01.1.1.1]: Parser disposition, unswept installed OTP apps/debugger remainder, and full carried-exclusion audit remain open per INT-20261029-02.

- [Before Phase 1 to 4 planning]: owner answers (or accepts the recommended answers) for Q7, Q9, Q12, Q13, Q15, Q19, Q20, Q24. Q14 and Q16 before Phase 4. Q8 before Phase 7. Q17 before Phase 25. Q21 before Phase 1 (SBOM) and Phase 13 (QR).
- [Phase 2]: the runner spike decides Q1; media emulation through the wrapper is the blocker candidate.
- [Phase 3 onward]: LiveView 1.2 upgrade PRs in the dogfood repos should start early (Q2, Q22), so the 14-day soak is not reset at the end.
- [Phase 17 and 18]: depend on abracabrand's two-session process; keep the minimal-token fallback so the phase can merge.
- [Phases 2 and 18]: neither completes a requirement on its own (a vertical slice and a content track); they feed QA-04, VIS-01/02 and QA-06.

### Roadmap Evolution

- Phase 01.1 inserted after Phase 1: Close phase 1 guard gaps (atom-ban bypass, code loading, hex-publish hardening); split per INT-20261029-01 to keep the 5-plan cap (URGENT)
- Phase 01.1.1.1 inserted after Phase 01.1.1: Finish the ban list: open items transferred from 01.1.1 at planning (INT-20261029-02) (URGENT)
- Numbering from here: keep existing dotted IDs stable because ownership and evidence artifacts reference them; finish the already-assigned debugger descendant 01.1.1.3.1.3, then resume the existing top-level roadmap sequence from Phase 2. Do not add further dotted descendants; express ordering with explicit dependencies.

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-11-02T00:01:43.973Z
Stopped at: Phase 01.1.1.3.1.3 planning complete; execution started
Next command: $gsd-execute-phase 01.1.1.3.1.3 — build, validate, and deliver the debugger-specific aggregate acceptance.
Resume file: None
