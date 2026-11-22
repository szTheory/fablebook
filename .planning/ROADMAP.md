# Roadmap: Fablebook

## v0.7 — First Inspectable Book

**Milestone key:** first-inspectable-book

A Phoenix developer can start a local host and inspect one fixed, compiled Logistify operator Book through the Fablebook UI catalog. The Book covers one dispatcher job across two or three addressable screens with cited illustrative data and renders in the host Canvas.

The [owner-approved exception](intent/sources/2026-11-20-14-approve-first-book-gate-exception.md) covers this Book in development and test and expires at v0.7 closeout. The guard aggregate stays open and `walking-skeleton` stays blocked. Scope excludes a logistics backend, external writes, Controls, user-provided values or code, audited-API use, persistence, product publication/deployment, release, other Books, and follow-on milestone work. Public citations and the minimal cited source-derived content are allowed in reviewed PRs under [INT-20261121-01](intent/sources/2026-11-21-01-public-pinned-brand-sources.md); complete source repos stay in the ignored cache. The operator host needs a development-only loopback server adapter. A separate Phoenix security-only prerequisite is authorized by [INT-20261121-03](intent/sources/2026-11-21-03-authorize-phoenix-security-pin-update.md): pin Phoenix to at least 1.8.17 in both core and floor, with only required lock alignment. The optional-only Node policy applies.

## Phases

- [ ] **Phase 8: First inspectable Book and local host path** - Open and navigate one source-grounded operator Book through the compiled Story/Scenario path and development/test-only host Canvas.

## Phase Details

### Phase 8: First inspectable Book and local host path

**Goal**: A developer can browse the Book → Story → Scenario tree in the Fablebook UI catalog's sidebar and inspect the selected dispatcher screen in the main host Canvas; production excludes the Book.

**Mode:** mvp

**Depends on**: Delivered Phase 7, the existing production-guard fixtures, and INT-20261120-14.

**Requirements**: SRC-01, MOUNT-01, HOST-01, HOST-02, CAT-01, CAT-02, CANVAS-01, BOOK-01

**Success Criteria** (what must be TRUE):

1. A host developer can mount the Book using a literal module alias or reference. The public macro rejects other expressions before expansion. A permanent test exercises the real public macro on valid and invalid forms, and the macro change and contract test have separate green merged PRs. (MOUNT-01)
2. Before Book implementation, a known-good fixture exposes a development/test mount and compiled sentinel Story; a clean production build has neither Fablebook routes nor story modules, and making the mount reachable causes the canonical `Fablebook cannot be mounted in a prod build` `CompileError`. The completed operator host shows the same environment boundary for the actual Book, Story modules and routes. (HOST-01, HOST-02)
3. A developer can fetch the commit-pinned Logistify v1.0 source and reproduce the subset after the preserved whole-file SHA-256 checks, then trace each cited content and fixture claim to its public repository, tag, commit, file, and section. The Book shows a normal case and a meaningful source-supported edge or error case for one dispatcher job. The same URLs produce the same sample data, and the UI identifies the records and actions as illustrative. The flow creates no persistent state or external writes. (SRC-01, BOOK-01)
4. A developer can start the host locally and immediately inspect the first screen. A familiar sidebar shows Books → Logistify operator console → Dispatcher recovery → its two Scenarios; selecting either screen updates the stable URL and main Canvas. Development and test resolve the same compiled Story/Scenario identifiers. Unknown selections resolve safely. The UI uses the neutral Fablebook brand rules and the approved product terms. (CAT-01, CAT-02)
5. Each screen renders in a same-origin iframe through the real host Canvas pipeline and root layout, with the host's CSS, JavaScript, hooks, fonts and CSP. A real-host browser check exercises the flow at representative narrow and desktop widths and verifies keyboard navigation, visible focus, labels and text status. (CANVAS-01, CAT-01, BOOK-01)

**Plans**: 3/5 delivered; 08-04/08-05 implementation and local verification are complete in the isolated candidate. Draft PR #106 is open; targeted hosted-CI fixes and the visual-baseline decision remain.
**Wave 1**
- [x] 08-01-PLAN.md — Pin all seven public source repositories and verify the minimal cited Logistify subset (SRC-01 complete; see the preserved historical halt and resumed summary).
- [x] 08-02-PLAN.md — Harden the public mount macro in PR #99 and deliver its separate contract test in PR #100; both are merged with green required CI.

**Wave 2** *(after 08-02; independent of the 08-01 source-custody gate)*
- [x] 08-03-PLAN.md — Merge the separate contract test (PR #100) and prove dev/test fixture inclusion plus positive/negative production controls (PR #101).

**Wave 3** *(local implementation complete; delivery uses the Wave 4 acceptance)*
- [ ] 08-04-PLAN.md — Render the first compiled Scenario through the local Phoenix catalog and Canvas.

**Wave 4** *(local checks complete; prerequisite PR splits and Phoenix security pins are delivered; PR #106 is open and its first required CI run exposed two setup issues now being corrected; owner baseline decision and Phase 8 delivery remain)*
- [ ] 08-05-PLAN.md — Complete the dispatcher flow, prove the actual host boundary and verify the final candidate.

**UI hint**: yes

#### Delivery sequence

1. Fetch the seven public repositories at the full commit pins in `brand_sources.lock.json`; keep their contents in the ignored cache. Prepare the minimal Logistify excerpt manifest with public repository/tag/commit/path citations and verify preserved whole-file and excerpt hashes before Book content. Independently author the executable mount contract and run it against the current router before changing the implementation. Record that the rejection assertion fails for the intended reason because the current router reaches `Macro.expand/2`. Use the same tests against the proposed fix in local verification and review. Use a fixed, harmless local fixture for the disallowed expression.
2. Land the implementation first in a PR that contains no mount contract test change and passes the existing required CI. Rebase and land the active contract test in a separate test-only PR against hardened `main`, with its own green required CI. Review run timing and repeated setup after each completed CI run. Preserve the canonical production error and compile timing. Run the positive and negative production controls on the merged result. Only then begin Book implementation. The phase's final Book delivery has its own reviewed, green merged PR.
3. Deliver the smallest real Story/Scenario, stable sidebar navigation and host Canvas path needed by the approved flow. Use the [source intake](references/logistify-brand-intake.md) and approved textual/token subset. Apply Logistify styling only in the Canvas; keep all values/actions illustrative and do not deploy or release the demonstration. Follow the Fablebook UI hierarchy and feedback ledger in [INT-20261121-02](intent/sources/2026-11-21-02-ui-catalog-hierarchy-and-feedback-loop.md).
4. Start verification with source/digest and fixture checks, compile and focused automated tests. Repeat production exclusion and reachable-mount rejection on the real operator host. Run one real-host browser pass and capture the representative visual evidence under the existing baseline policy. Owner approval is required for a new or changed baseline. Use the existing hosted CI gates and preserve the recorded local `act` stop until its cause changes. See the [scope review](research/2026-11-20-next-milestone-scope-review.md) and [verification policy](VERIFICATION.md).

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 8. First inspectable Book and local host path | 3/5 delivered | Draft PR #106 open; targeted CI fixes and owner baseline decision remain; see [08-05-SUMMARY.md](phases/08-first-inspectable-book-and-local-host-path/08-05-SUMMARY.md) | - |

## Completed milestones

- **v0.6 Guard Scope Reconciliation** — closed 2026-11-20 as a bounded evidence milestone; Phase 7 delivered through PR #96 with green exact-head and post-merge CI, archive closeout tracked in [PR #97](https://github.com/szTheory/fablebook/pull/97). The aggregate remains open and product demos were not built. [Archive](milestones/v0.6-ROADMAP.md) · [requirements](milestones/v0.6-REQUIREMENTS.md) · [audit](milestones/v0.6-MILESTONE-AUDIT.md) · [closeout](milestones/v0.6-CLOSEOUT.md)
- **v0.5 Bounded EX-177 Provenance Follow-through** — closed 2026-11-19; wider guard and product gates remain open. [Archive](milestones/v0.5-ROADMAP.md) · [closeout](milestones/v0.5-CLOSEOUT.md)
- **v0.4 Guard Aggregate Reconciliation** — archived 2026-11-19; wider guard aggregate remains open. [Archive](milestones/v0.4-ROADMAP.md) · [closeout](milestones/v0.4-CLOSEOUT.md)
- **v0.3 Bounded ASN.1 RTT Guard Evidence** — archived 2026-11-13. [Archive](milestones/v0.3-ROADMAP.md) · [closeout](milestones/v0.3-CLOSEOUT.md)
- **v0.2 Guard coverage recovery** — archived 2026-11-11. [Archive](milestones/v0.2-ROADMAP.md) · [closeout](milestones/v0.2-CLOSEOUT.md)
- **v0.1 Legacy planning cycle** — superseded and incomplete; not a whole-product ship claim. [Historical archive](milestones/v0.1-ROADMAP.md)

The [rolling product roadmap](references/PRODUCT-ROADMAP.md) holds the future product horizons. v0.7 ends at its own milestone closeout.
