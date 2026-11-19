# Project Retrospective

## Milestone: v0.4 — Guard Aggregate Reconciliation

**Shipped:** 2026-11-19 local (bounded development milestone)
**Phases:** 3 | **Plans:** 9 | **Implementation tasks:** 14

### What Was Built

- Rejoined 226 original identities per pinned lane and preserved exact live, historical, delivered and pending MFA partitions.
- Produced lane-pinned provenance or keyed gaps across the 9,716-row source/caller set, then selected four EX-177 rows with the other 9,712 preserved as a hash-bound complement.
- Delivered through PRs #90–#92 with exact-head hosted CI. The aggregate gate remains open, candidate remains null, and implementation remains unauthorized.
- A separately authorized discovery recorded the exact EX-177 helper span and one direct caller on each lane; broader caller closure remains open. See the [closeout](milestones/v0.4-CLOSEOUT.md) and [discovery report](research/2026-11-19-ex177-source-discovery.md).

### What Worked

- Cheap byte equality, hash, JSON-schema and planning preflight checks found actionable mismatches before any long suite. The current Phase 4 stable payload equals ENV06, and its current validation receipt passes; no suite was needed to answer that question.
- Keeping one primary checkout avoided handoff and merge overhead while the work was sequential. No extra worktree was needed.
- Reviewing exact-head hosted CI and the merged receipt at closeout prevented unnecessary reruns. The old Phase 3 result and append-sensitive Phase 5 validator were preserved instead of rewritten.
- The owner decision was captured once in an intent record; the stale historical Phase 3 report was not used to restart a completed phase.

### What Was Inefficient

- An assistant-side cumulative output ceiling was mistakenly set to the same size as the project execution budget. It caused repeated ceiling increases and a run that stopped before useful work. INT-20261117-11 removed that assistant-side ceiling; do not restore it or keep extending it. Keep only the scoped source, provenance, count, context-fit and one-use gates that protect evidence.
- Some long test work happened before cheap checks established that the requested suite could answer the blocker. Future work should first verify exact input identity, hash, span, lane, schema and the specific question a suite will answer; skip the suite when it cannot resolve that question.
- The closeout CLI left active phase fields after moving phase directories. The post-archive preflight caught the transition mismatch; canonical STATE.md was reset to a supported between-milestones state and `state.json` refreshed. Run the appropriate start preflight after completing the archive transition.
- The generic audit writer cannot acknowledge a table-shaped deferred item. Follow the existing immutable-archive exception, record the carry in a closeout receipt, and keep the original bytes unchanged.

### Patterns Established

- Run the cheapest relevant check first: exact file/hash/span and schema consistency before source counts, focused checks before broad suites, and a clear decision about whether a full suite can change the answer.
- Separate immutable phase evidence from append-only delivery receipts; never rerun an old validator if a receipt append would rewrite its historical result.
- Close a bounded milestone against its own requirements while carrying wider gates and safety stops forward unchanged.
- Keep one workspace for sequential work. Add parallel workspaces only when work is truly independent and concurrent.

### Key Lessons

1. Diagnose the actual bottleneck before changing any budget or limit. A context limit, source-size cap and project execution allowance serve different purposes; never make one a copy of another.
2. Check whether the expensive operation can answer the open question. If a test cannot establish missing source identity or caller coverage, stop before running it.
3. After a milestone archive moves files, refresh the generated state projection and check the explicit between-milestone route before starting the next scope.
4. A closeout override records a decision; it does not change the report verdict, fix a gap, close the aggregate gate or authorize implementation.

### Cost Observations

- v0.4 contains three phases, nine plans and 14 tasks. Model usage, session count and billed token cost were not recorded, so no cost estimate is available.
- PR #92 hosted CI took about 9.5 minutes; the core lane was the critical path. One sample did not justify a cache, concurrency, dependency or coverage change. Keep measuring each hosted CI receipt and optimize only repeatable, safe bottlenecks.
- The local `act` compatibility limitation remains documented. Hosted exact-head receipts passed; closeout did not rerun suites or add dependencies.

## Milestone: v0.3 — Bounded ASN.1 RTT Guard Evidence

**Shipped:** 2026-11-13 local (bounded development milestone)
**Phases:** 1 | **Plans:** 5 | **Implementation tasks:** 10

### What Was Built

- Source-backed static evidence for `asn1ct_rtt:assert_defined/1`, `code/0` and `dependencies/1` on both pinned lanes, including direct callers and independent positive and negative controls.
- An integration contract that checks exact EX-107 membership, the selected 3 / remaining 174 partition, the historical 13 / 164 / 161 partition, and six lane-specific controls.
- Reviewed and merged delivery through PR #88 with passing final-head and main CI. The bounded audit satisfied all three requirements and recorded six nonblocking debt items; details and boundaries are in the [closeout](milestones/v0.3-CLOSEOUT.md) and [audit](milestones/v0.3-MILESTONE-AUDIT.md).

### What Worked

- Independent core and floor evidence, followed by a separate integration contract, made lane identity and selected-versus-remaining coverage reviewable.
- Existing verification, UAT, security review and hosted CI receipts were reconciled and reused at milestone close; the closeout did not rerun suites.
- The source-only boundary and wider manual stop, aggregate, Walking Skeleton and SEC-01 gates stayed explicit in the archived requirements and receipt.

### What Was Inefficient

- Initial core/floor evidence failures and lane-selection corrections required follow-up work before the reviewed candidate was ready; the original failures and their fixes remain in the phase history.
- The installed local `act` could not parse the existing `concurrency.queue` setting, so it could not supply a local CI receipt. The exact-head and merged-main hosted receipts remain the delivery evidence.
- The archive writer retained active-phase fields after moving the phase directory. The lifecycle check caught the inconsistent state; STATE.md was corrected to the supported between-milestones form and the generated projection was refreshed.

### Patterns Established

- Bind source evidence independently to each pinned lane, then verify exact membership and partitions in a separate integration contract.
- Treat green static checks as evidence for the selected source slice only; they do not establish runtime behavior, dynamic-caller coverage or native safety.
- Preserve owner decisions about unresolved findings in a new closeout receipt when immutable historical files cannot be edited.

### Key Lessons

1. Keep lane identity, source citations, caller paths and controls independently reviewable before integration.
2. Close a bounded milestone against its own requirements while carrying wider blockers and safety stops forward unchanged.
3. Treat archive commands as one step in the lifecycle: run the health checks after moving files and reconcile canonical state before committing.

### Cost Observations

- Recorded plan intervals total 160 minutes; these exclude separate review, verification, audit and closeout work.
- Approved scope and merged delivery span 2026-11-12 to 2026-11-13. Model usage, session count and billed cost were not recorded, so no cost estimate is available.
- The local `act` limitation was recorded without a retry during closeout. No repeatable workflow, cache, concurrency or dependency optimization was established.

## Milestone: v0.2 — Guard coverage recovery

**Shipped:** 2026-11-11 local (bounded development milestone)
**Phases:** 1 | **Plans:** 3 | **Implementation tasks:** 6

### What Was Built

- Independent, exact-archive core and floor findings for the selected tracing front.
- Integrated retained dispositions, individual matcher witnesses and adverse static controls.
- Symmetric core/floor selection and reviewed green actual delivery through PR #85.

### What Worked

- Small sequential phases made the selected increment finish independently of the wider aggregate.
- Source identity and membership checks supported semantic review without pretending to prove runtime safety.
- Existing approvals, implementation summaries and hosted receipts were reconciled chronologically and reused.
- Historical phase files, delivery facts and old archive hashes were preserved at close.

### What Was Inefficient

- Broad suites initially exposed lane selection errors late; cheap CI-shape and strict lint should run first.
- Shared archive extraction made broad controls expensive. No repeatable safe cache, concurrency or dependency change was established.
- The intent contract assumed an active requirements file even between milestones; separate PR #86 preserves validation against the canonical current-version archive.
- The generic closeout writer assumes historical deferred files are editable; this project's frozen archive requires a new acknowledgement receipt instead.

### Patterns Established

- Key source authority by lane plus source path; check full matcher membership and individual removal witnesses.
- Close a bounded milestone against its own requirements while retaining aggregate blockers and future owners.
- Distinguish chronological implementation summaries from subsequent acceptance and actual delivery.

### Key Lessons

1. Validate lane-selection wiring before expensive suites and spend the final focused review after local green.
2. An archive approval carries existing obligations forward; it does not imply runtime proof or next-scope approval.
3. Preserve original archived bytes and record later decisions in a new receipt.

### Cost Observations

Recorded implementation intervals total 219 minutes; source summaries use diff-size token proxies, not measured context or billed cost. Owner waits, independent audit and archive work are not separately instrumented. Actual main CI took 676 seconds; floor was the critical job at 668 seconds, mainly tests. No extra hosted run was started to manufacture a receipt.

## Milestone: v0.5 — Bounded EX-177 Provenance Follow-through

**Shipped:** 2026-11-19 (bounded development milestone)
**Phases:** 1 | **Plans:** 1 | **Implementation tasks:** 1

### What Was Built

- A machine-readable supplement records exactly four reviewed EX-177 source/caller observations across the core and floor lanes and binds the unchanged 9,712-row complement.
- A standard-library checker validates the saved evidence, exact key set, complement digest, and preserved stop states without reading the recorded Phoenix source paths.
- Phase 6 shipped through PR #93 with green exact-head CI. A separate compatibility PR #94 repaired the archived-evidence path expectation in existing tests and also passed hosted CI.

### What Worked

- Keeping the four-row scope and the complement digest explicit made the acceptance check small and independently reviewable.
- The saved discovery and archived Phase 5 records supplied the facts without repeating source reads or consuming R9.
- Separating the compatibility repair from the phase delivery made the test-support change visible and independently reviewable.
- The audit reused the phase verification, Nyquist validation, integration check, delivery receipt, and hosted CI instead of rerunning them at closeout.

### What Was Inefficient

- The first exact-head CI run found existing tests that expected a Phase 4 evidence helper at its old active-phase path. The compatibility support needed a separate PR, and Phase 6 needed a small test adjustment to keep the recorded provenance path separate from the archived storage path.
- Local `act` could not parse the repository's existing `concurrency.queue` syntax, so hosted exact-head CI remained the authoritative delivery evidence.

### Patterns Established

- Keep a recorded provenance path distinct from the physical archive path used to read the saved file.
- Keep test compatibility changes separately reviewable when they support a bounded evidence delivery.
- Close a bounded evidence milestone against its own requirement while carrying wider gates and inherited deferred records forward.

### Key Lessons

1. Preserve historical provenance values even when files move; add an explicit storage-path mapping in test support instead of rewriting historical evidence.
2. Run focused static consistency checks before broader tests, then rely on the exact reviewed hosted CI receipt for delivery.
3. A passed scoped audit does not authorize the next milestone or close caller, runtime, security, or aggregate gates.

### Cost Observations

- The phase contains one plan and one implementation task. Model usage and billed cost were not recorded.
- Exact-head CI 44589600030 took about 11 minutes 25 seconds at its longest required lane; one run is insufficient evidence for a CI optimization.
- The phase added no dependency, product code, runtime invocation, or recurring CI lane.

## Cross-Milestone Trends

| Cycle | Outcome | Process change |
|---|---|---|
| v0.1 legacy | Superseded and incomplete; no whole-product ship claim | Preserve all evidence and unfinished acceptance under the numbering reset |
| v0.2 | Selected increment delivered and archived | Sequential bounded milestone; explicit carry-forward gates and immutable delivery facts |
| v0.3 | Selected increment delivered and archived; scoped audit records nonblocking debt | Per-lane source evidence and integration partitions; explicit between-milestone state validation |
| v0.4 | Aggregate rejoin and three bounded evidence phases delivered; wider gate remains open | Measure the true bottleneck, run exact consistency checks before long suites, preserve stale reports, and transition explicitly to between-milestone state |
| v0.5 | Four-key EX-177 supplement delivered and archived; caller closure and wider guard gate remain open | Keep observed provenance machine-readable, separate test compatibility from phase evidence, and close the bounded milestone without advancing scope |

The shared lesson is to keep scope, delivery evidence and unresolved gates explicit. Four bounded milestones have completed under this format; that sample does not support a statistically meaningful performance trend.
