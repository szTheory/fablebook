---
gsd_state_version: "1.0"
current_phase: 01.1.1.2
current_phase_name: Installed OTP inventory and Common Test guard slice
status: executing
stopped_at: Resuming authorized Phoenix.HTML security maintenance and source-lock provenance refresh under INT-20261030-05
last_updated: "2026-10-30T21:52:18.872Z"
last_activity: 2026-10-30
last_activity_desc: Exact core/floor inventory receipts pass; Plan 01 delivery is blocked by phoenix_html security advisory and failed ci-gate
state_head: 0f33179261c0a99325919d45967a124e2e9ce561
progress:
  total_phases: 42
  completed_phases: 1
  total_plans: 19
  completed_plans: 18
  percent: 2
---

# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-10-30)

**Core value:** Every real state of a Phoenix LiveView UI, from primitive to full screen, visible, verified and explainable to humans and LLMs, built to a quality bar that is never lowered.
**Current focus:** Phase 01.1.1.2 — executing the owner-authorized security prerequisite; inventory delivery and Plan 02 retain their green-merge gates

## Current Position

Phase: 01.1.1.2 (Installed OTP inventory and Common Test guard slice) — IN PROGRESS
Plan: 1 of 2 (Plan 01 halted; Plan 02 blocked)
Status: Owner authorized separate `phoenix_html` 4.4.0 maintenance, lock provenance refresh, and one maintenance review; continuing selected phase without another acknowledgment
Last activity: 2026-10-30 — Exact core/floor tests and receipts passed on PR #27 head 9c326cf; security and ci-gate failed for EEF-CVE-2026-117645

Progress: [░░░░░░░░░░] 2%

## Performance Metrics

**Velocity:**
- Total plans completed: 7
- Average duration: 34.2 min
- Total execution time: 8.6 hours

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 01.1.1 | 5 | 316 min | 63.2 min |
| 01.1.1.1 | 2 | - | - |

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
| Phase 01.1.1.1 P06 | 57 min | 2 tasks | 3 files |
| Phase 01.1.1.1 P07 | 48 min | 2 tasks | 5 files |

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
- [Phase 01.1.1.1]: Measured audit size stop resolved by bounded Plans 06/07 and explicit 01.1.1.2–01.1.1.5 ownership; original partial Plan 01 and blocked Plans 02–05 preserved in the superseded archive — INT-20261029-02, INT-20261030-02 and ADR 0021: preserve all 221 exclusions/226 identities and future full guards; no lowered gate or phase completion
- [Phase 01.1.1.1]: Retire EX-089's blanket epp_guard; tier each atom-creating Yecc public front.
- [Phase 01.1.1.1]: Map Yecc format_error/1 as a formatter callback outside the atom-creator graph.
- [Phase 01.1.1.1]: SEC-01 remains Pending for Phase 5; Plan 06 advances only static contract coverage.
- [Phase 01.1.1.1]: Caller-controlled format, config, and message paths that reach formatter atom creation are represented by exact mirrored tiers on both lanes.
- [Phase 01.1.1.1]: Retain exact exclusions only for Logger.Formatter.new/0, ExUnit.plural_rule/2, and ExUnit.after_suite/1; each has a per-lane source trace and removal witness.
- [Phase 01.1.1.1]: SEC-01 stays Pending for Phase 5; remaining inventory, carried-exclusion, Macro, and wording work stays with its planned owners.

### Pending Todos

None yet.

### Blockers/Concerns

- [Parent verification debt]: Phase 1 and 01.1 reports remain gaps_found; phase.complete routed to Phase 1 for re-verification. Do not mark either parent complete from the child report.
- [Phase 01.1.1.1]: Parser disposition, unswept installed OTP apps/debugger remainder, and full carried-exclusion audit remain open per INT-20261029-02.

- [Before Phase 1 to 4 planning]: owner answers (or accepts the recommended answers) for Q7, Q9, Q12, Q13, Q15, Q19, Q20, Q24. Q14 and Q16 before Phase 4. Q8 before Phase 7. Q17 before Phase 25. Q21 before Phase 1 (SBOM) and Phase 13 (QR).
- [Phase 2]: the runner spike decides Q1; media emulation through the wrapper is the blocker candidate.
- [Phase 3 onward]: LiveView 1.2 upgrade PRs in the dogfood repos should start early (Q2, Q22), so the 14-day soak is not reset at the end.
- [Phase 17 and 18]: depend on abracabrand's two-session process; keep the minimal-token fallback so the phase can merge.
- [Phases 2 and 18]: neither completes a requirement on its own (a vertical slice and a content track); they feed QA-04, VIS-01/02 and QA-06.
- Historical CI run 41127014456 on PR head 76edcb6 stopped both exact lanes at the newly coupled `escript.debug/3` active MFA. The source-backed private-front correction and removal witness are now present on PR head 9c326cf; exact core/floor tests and receipts pass on run 41132579711.
- Plan 01 exact core/floor tests and receipts pass on PR #27 head 9c326cf, but security and ci-gate fail because both locks pin vulnerable phoenix_html 4.3.0 (EEF-CVE-2026-117645). Do not merge or start Plan 02. Recommend a separately authorized lockfile-only update of mix.lock and mix.floor.lock to phoenix_html 4.4.0, followed by exact core/floor and security checks; obtain an explicit review-budget decision because pass 4 is reserved for Common Test.

### Roadmap Evolution

- Phase 01.1 inserted after Phase 1: Close phase 1 guard gaps (atom-ban bypass, code loading, hex-publish hardening); split per INT-20261029-01 to keep the 5-plan cap (URGENT)
- Phase 01.1.1.1 inserted after Phase 01.1.1: Finish the ban list: open items transferred from 01.1.1 at planning (INT-20261029-02) (URGENT)
- Phase 01.1.1.1 replanned: INT-20261029-02 and INT-20261030-02: preserve merged PR23 and partial history; active06/07 finish named creators; explicit01.1.1.2–.5 transfers and bounded bulk-audit children preserve all original gates

## Deferred Items

Items acknowledged and deferred at milestone close, most recent first:

| Category | Item | Status | Deferred At | Milestone |
|----------|------|--------|-------------|-----------|
| *(none)* | | | | |

## Session Continuity

Last session: 2026-10-30T21:52:18.539Z
Stopped at: Exact core/floor inventory evidence is preserved; delivery remains blocked by the phoenix_html security advisory and failed ci-gate
Next independent command: Owner decides whether to authorize a separate lockfile-only phoenix_html 4.4.0 security PR and how to allocate its review; keep Plan 02 blocked until PR #27 is green and merged
Resume file: .planning/phases/01.1.1.2-installed-otp-inventory-and-common-test-guard-slice/01.1.1.2-01-SUMMARY.md

## Completed phase receipt

Phase 01.1.1.1 is complete under its narrowed goal: all four success criteria passed, no human verification remains, both review findings are fixed, and the owner-renewed independent review is clean. PRs 24/25/26 are merged with required exact-head CI green. The canonical VERIFICATION report contains the CLI-generated covered-input digest and explicit future ownership. No new requirement was completed; SEC-01 remains Pending / Phase 5.

The phase-completion query routes the pointer to Phase 1 because parent verification debt remains; no parent report or UAT gap was closed. Independent next work on 01.1.1.2 can be discussed using the verified child prerequisite. Later .3/.4 work still requires calibrated children and all original whole-audit/owner-judgment gates remain. No next-phase workflow was started.

Discussion and planning for 01.1.1.2 are now complete; its independent verification is recorded in the phase CHECK report. Next command: `$gsd-execute-phase 01.1.1.2`. No implementation or next-phase workflow started during planning.
