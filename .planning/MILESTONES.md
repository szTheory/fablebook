# Milestone history

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
