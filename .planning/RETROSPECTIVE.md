# Project Retrospective

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

## Cross-Milestone Trends

| Cycle | Outcome | Process change |
|---|---|---|
| v0.1 legacy | Superseded and incomplete; no whole-product ship claim | Preserve all evidence and unfinished acceptance under the numbering reset |
| v0.2 | Selected increment delivered and archived | Sequential bounded milestone; explicit carry-forward gates and immutable delivery facts |
| v0.3 | Selected increment delivered and archived; scoped audit records nonblocking debt | Per-lane source evidence and integration partitions; explicit between-milestone state validation |

The shared lesson is to keep scope and delivery evidence explicit. Two bounded milestones have completed under this format; that sample does not support a statistically meaningful performance trend.
