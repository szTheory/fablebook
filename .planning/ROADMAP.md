# Roadmap: Fablebook

## v0.7 — First Inspectable Book

**Milestone key:** first-inspectable-book

A Phoenix developer can start a local host and inspect one fixed, compiled Logistify operator Book through the Fablebook UI catalog. The Book covers one dispatcher job across two or three addressable screens with cited illustrative data and renders in the host Canvas.

The [owner-approved exception](intent/sources/2026-11-20-14-approve-first-book-gate-exception.md) covers this Book in development and test and expires at v0.7 closeout. The guard aggregate stays open and `walking-skeleton` stays blocked. Scope excludes a logistics backend, external writes, Controls, user-provided values or code, audited-API use, persistence, publication, release, other Books, and follow-on milestone work. The existing dependency budget and optional-only Node policy apply.

## Phases

- [ ] **Phase 8: First inspectable Book and local host path** - Open and navigate one source-grounded operator Book through the compiled Story/Scenario path and development/test-only host Canvas.

## Phase Details

### Phase 8: First inspectable Book and local host path

**Goal**: A developer can open the local catalog and inspect a short dispatcher flow with two or three addressable screens rendered in the host's own environment and excluded from production.

**Mode:** mvp

**Depends on**: Delivered Phase 7, the existing production-guard fixtures, and INT-20261120-14.

**Requirements**: SRC-01, MOUNT-01, HOST-01, HOST-02, CAT-01, CAT-02, CANVAS-01, BOOK-01

**Success Criteria** (what must be TRUE):

1. A host developer can mount the Book using a literal module alias or reference. The public macro rejects other expressions before expansion. A permanent test exercises the real public macro on valid and invalid forms, and the macro change and contract test have separate green merged PRs. (MOUNT-01)
2. Before Book implementation, a known-good fixture exposes a development/test mount and compiled sentinel Story; a clean production build has neither Fablebook routes nor story modules, and making the mount reachable causes the canonical `Fablebook cannot be mounted in a prod build` `CompileError`. The completed operator host shows the same environment boundary for the actual Book, Story modules and routes. (HOST-01, HOST-02)
3. A developer can reproduce the SHA-256-checked Logistify v1.0 text/token subset from the repository and trace cited content and fixture claims to exact source files and sections. The Book shows a normal case and a meaningful source-supported edge or error case for one dispatcher job. The same URLs produce the same sample data, and the UI identifies the records and actions as illustrative. The flow creates no persistent state or external writes. (SRC-01, BOOK-01)
4. A developer can start the host locally, open the UI catalog, select the one operator Book, navigate its two or three screens, and return directly to each screen at its stable URL. Development and test resolve the same compiled Story/Scenario identifiers. Unknown selections resolve to a safe unavailable state. The catalog uses neutral chrome and the approved UI terms. (CAT-01, CAT-02)
5. Each screen renders in a same-origin iframe through the real host Canvas pipeline and root layout, with the host's CSS, JavaScript, hooks, fonts and CSP. A real-host browser check exercises the flow at representative narrow and desktop widths and verifies keyboard navigation, visible focus, labels and text status. (CANVAS-01, CAT-01, BOOK-01)

**Plans**: TBD (at most five)

**UI hint**: yes

#### Delivery sequence

1. Prepare the reproducible source subset and citations. Author the executable mount contract separately from implementation and run it against the current router. Record that the rejection assertion fails for the intended reason because the current router reaches `Macro.expand/2`. Use the same tests against the proposed fix in local verification and review. Use a fixed, harmless local fixture for the disallowed expression.
2. Land the implementation first in a PR that contains no mount contract test change and passes the existing required CI. Rebase and land the active contract test in a separate test-only PR against hardened `main`, with its own green required CI. Preserve the canonical production error and compile timing. Run the positive and negative production controls on the merged result. Only then begin Book implementation. The phase's final Book delivery has its own reviewed, green merged PR.
3. Deliver the smallest real Story/Scenario, stable catalog navigation and host Canvas path needed by the approved flow. Use the [source intake](references/logistify-brand-intake.md) and approved textual/token subset. Apply Logistify styling in the preview and keep the demonstration local and internal.
4. Start verification with source/digest and fixture checks, compile and focused automated tests. Repeat production exclusion and reachable-mount rejection on the real operator host. Run one real-host browser pass and capture the representative visual evidence under the existing baseline policy. Owner approval is required for a new or changed baseline. Use the existing hosted CI gates and preserve the recorded local `act` stop until its cause changes. See the [scope review](research/2026-11-20-next-milestone-scope-review.md) and [verification policy](VERIFICATION.md).

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 8. First inspectable Book and local host path | 0/TBD | Not started | - |

## Completed milestones

- **v0.6 Guard Scope Reconciliation** — closed 2026-11-20 as a bounded evidence milestone; Phase 7 delivered through PR #96 with green exact-head and post-merge CI, archive closeout tracked in [PR #97](https://github.com/szTheory/fablebook/pull/97). The aggregate remains open and product demos were not built. [Archive](milestones/v0.6-ROADMAP.md) · [requirements](milestones/v0.6-REQUIREMENTS.md) · [audit](milestones/v0.6-MILESTONE-AUDIT.md) · [closeout](milestones/v0.6-CLOSEOUT.md)
- **v0.5 Bounded EX-177 Provenance Follow-through** — closed 2026-11-19; wider guard and product gates remain open. [Archive](milestones/v0.5-ROADMAP.md) · [closeout](milestones/v0.5-CLOSEOUT.md)
- **v0.4 Guard Aggregate Reconciliation** — archived 2026-11-19; wider guard aggregate remains open. [Archive](milestones/v0.4-ROADMAP.md) · [closeout](milestones/v0.4-CLOSEOUT.md)
- **v0.3 Bounded ASN.1 RTT Guard Evidence** — archived 2026-11-13. [Archive](milestones/v0.3-ROADMAP.md) · [closeout](milestones/v0.3-CLOSEOUT.md)
- **v0.2 Guard coverage recovery** — archived 2026-11-11. [Archive](milestones/v0.2-ROADMAP.md) · [closeout](milestones/v0.2-CLOSEOUT.md)
- **v0.1 Legacy planning cycle** — superseded and incomplete; not a whole-product ship claim. [Historical archive](milestones/v0.1-ROADMAP.md)

The [rolling product roadmap](references/PRODUCT-ROADMAP.md) holds the future product horizons. v0.7 ends at its own milestone closeout.
