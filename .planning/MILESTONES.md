# Milestone history

## v0.4 Guard Aggregate Reconciliation — Fablebook (Shipped: 2026-11-19)

**Phases completed:** 3 phases, 9 plans, 14 tasks

**Closeout:** `override_closeout`; scoped audit is `tech_debt` with 6/6 requirements satisfied. The historical Phase 3 pass is preserved under the approved stale-fingerprint override; the wider guard aggregate remains open.

Known verification overrides: 1 newly acknowledged stale Phase 4 gap report, 3 legacy items carried forward from the v0.2 immutable-source exception, and 3 prior writer acknowledgements still suppressed. The Phase 4 report keeps its original `gaps_found` verdict; no archived v0.1 source was changed.

**Key accomplishments:**
- Rejoined all 226 original identities on each pinned lane and preserved exact live, delivered, historical, and pending MFA partitions without selecting a candidate.
- Produced lane-pinned source, caller, and delegate provenance or explicit keyed gaps; the complete pending provenance partition remains visible and the legacy digest remains unresolved.
- Validated the Phase 4 ENV06 evidence package and stable consumer aliases; the saved `gaps_found` report is historical, and the current alias bytes match the validated generation.
- Bound exactly four EX-177 rows while preserving the 9,712-row complement. The later bounded discovery located the exact helper span and one direct caller per lane; it did not establish package-wide caller closure or consume R9.
- Delivered Phases 3–5 through reviewed, green PRs #90–#92 with exact-head hosted CI receipts. Candidate remains null; implementation remains unauthorized; the aggregate gate remains open.

| Phase | PR | Merged commit | Exact-head CI |
|---|---:|---|---|
| 3 | [#90](https://github.com/szTheory/fablebook/pull/90) | `488387b1d446f5c03bdf11bb20e7f0c1e7087b88` | [44438380336](https://github.com/szTheory/fablebook/actions/runs/44438380336) |
| 4 | [#91](https://github.com/szTheory/fablebook/pull/91) | `b1cd9b410b556608c87047bd871fa38bf954e32e` | [44451045250](https://github.com/szTheory/fablebook/actions/runs/44451045250) |
| 5 | [#92](https://github.com/szTheory/fablebook/pull/92) | `df9bba9fbf5fa6efd665e7d5bfea7e827d3035c0` | [44475714163](https://github.com/szTheory/fablebook/actions/runs/44475714163) |

[Roadmap](milestones/v0.4-ROADMAP.md), [requirements](milestones/v0.4-REQUIREMENTS.md), [audit](milestones/v0.4-MILESTONE-AUDIT.md), [phase evidence](milestones/v0.4-phases/), [closeout](milestones/v0.4-CLOSEOUT.md).

---

## v0.3 Bounded ASN.1 RTT Guard Evidence (Shipped: 2026-11-13)

**Delivered:** Source-backed static evidence for the approved three-function ASN.1 RTT slice on both pinned lanes, with review and green delivery receipts; wider safety boundaries remain open.

**Phases completed:** Phase 2 (1 phase, 5 plans, 10 tasks)

**Closeout:** `override_closeout`; scoped audit status remains `tech_debt` with 3/3 requirements and no critical gaps.

Known verification overrides: 2 newly acknowledged, 5 carried forward from the v0.2 closeout (see STATE.md Deferred Items and the closeout receipt). The six audit debt items remain recorded.

**Key accomplishments:**
- Core ASN.1 RTT evidence binds all three approved functions and direct callers to the pinned OTP archive, with independent controls and a byte-only table check.
- Floor archive citations and individual static controls now cover all three selected RTT functions, with `code/0` validated as bytes only.
- The integration contract verifies exact EX-107 lane membership, independent 3/174 and 13/164/161 partitions, and six lane-specific static controls.
- The five lane and integration outputs pass independent static-security review, with lane-correct focused checks and all wider safety stops preserved.
- The original core/floor failures remain recorded; the separately delivered prerequisite, lane ownership and bounded timeout fixes were followed by passing full suites on a PR-shaped tested tree. Candidate and merged-main delivery remain separate gates.

**Stats:**
- 86 files in the Phase 2 delivery diff, including planning and archive records; focused test/support changes were 5 files and 816 added lines.
- 1 phase, 5 plans, 10 tasks.
- One day from approved v0.3 scope (2026-11-12) to merged delivery and verification (2026-11-13).

**Git range:** PR #87 prerequisite delivery → PR #88 phase delivery and final verification closeout.

[Roadmap](milestones/v0.3-ROADMAP.md), [requirements](milestones/v0.3-REQUIREMENTS.md), [audit](milestones/v0.3-MILESTONE-AUDIT.md), [phase evidence](milestones/v0.3-phases/), [closeout](milestones/v0.3-CLOSEOUT.md).

**Post-close worktree reconciliation:** [checkout inventory and active planning path](references/WORKTREE-RECONCILIATION-2026-11-13.md).

**What's next:** `$gsd-new-milestone` — the owner chooses and defines the next bounded scope. No next milestone is selected automatically.

---

## v0.2 Guard coverage recovery (Shipped: 2026-11-11)

**Phases completed:** 1 phase, 3 plans, 6 tasks

**Closeout:** `override_closeout` for acknowledged older artifacts; scoped audit passed.

Known verification overrides: 5 newly acknowledged, 0 carried forward from a prior close (see STATE.md Deferred Items). Two writer acknowledgements and three immutable-source acknowledgements remain unresolved.

[Roadmap](milestones/v0.2-ROADMAP.md), [requirements](milestones/v0.2-REQUIREMENTS.md), [audit](milestones/v0.2-MILESTONE-AUDIT.md), [phase evidence](milestones/v0.2-phases/), [closeout and full deferrals](milestones/v0.2-CLOSEOUT.md). This completes a bounded development milestone, not a package release.

**Key accomplishments:**
- The core EX-010 row now has exact OTP source findings and independently falsifiable archive, graph, citation, and matcher-removal controls.
- OTP 27.3.4.9 floor EX-010 findings now have exact archived source authority, complete matcher equality, per-MFA removal witnesses, and falsifiable adverse controls.
- Both EX-010 exports retain source-backed callback-front dispositions with individual lane witnesses; the exact reviewed candidate passes local and hosted checks.

---

## v0.1 Legacy planning cycle (Superseded: 2026-11-11)

**Status:** SUPERSEDED — INCOMPLETE. This is an archive label for the formerly unversioned planning cycle, not a new software release or a claim that the whole product shipped.

Release infrastructure and bounded guard deliveries have merged receipts. The parent source audit, installed-scope acceptance, SEC-01 properties and future product remain incomplete. Nine historical fingerprints were stale and three reports missing at migration. Their historical claims are preserved; none is refreshed to manufacture a pass.

[Original roadmap](milestones/v0.1-ROADMAP.md), [requirements](milestones/v0.1-REQUIREMENTS.md), [state](milestones/v0.1-STATE.md), [phase evidence](milestones/v0.1-phases/), and [carry-forward register](migrations/2026-11-11-milestone-reset/CARRY-FORWARD.md). Archive hashes verify every moved file. The dirty primary checkout and its extra uncommitted evidence are preserved separately.
