# Future product milestones

This is the rolling product roadmap outside the active milestone. Executable phase IDs use one project-wide integer sequence: v0.2 Phase 1 was delivered and v0.3 is Phase 2. The roadmap's phase values and dependency references are milestone-local slots until activation; allocate global IDs after the highest delivered phase and update the selected map, gates, seeds and dependencies when a milestone activates. Milestone names/keys are stable planning references; versions are assigned on activation. These are carried commitments, not approved executable plans or shipped features. INT-20261111-01 split the oversized cycle; INT-20261112-04 sets the continuing numbering policy. Original wording and IDs remain in milestones/v0.1-ROADMAP.md.

v0.2–v0.6 delivered bounded evidence, provenance, compatibility, and closeout work; none closes the complete guard aggregate. The original `walking-skeleton` key remains blocked. On 2026-11-20 the owner approved one narrow, expiring exception for the separate `first-inspectable-book` key; see [INT-20261120-14](../intent/sources/2026-11-20-14-approve-first-book-gate-exception.md) and the typed [planning gate](PLANNING-GATES.json). The aggregate stays open. v0.6 Phase 7 reconciled the current core inventory and accepted floor membership, all 226 saved rows per lane, one proposed family with its complete complement, bounded source/caller/delegate observations, and refreshed sizing. Its verification, hosted delivery, integration review, and archive closeout passed. Three inherited v0.1 deferrals remain unresolved and acknowledged for carry-forward. The historic whole-universe inventory is unavailable, three consumed source requests have no durable hashes or spans and remain closed to retry, and bounded observations do not prove exhaustive callers. Further guard increments require a separate bounded justification and owner authorization; there is no automatic follow-up. Do not insert nested decimal phases or weaken acceptance to advance.

## Milestone-start planning practice

At every new milestone start, use the last owner-reviewed [rolling roadmap](PRODUCT-ROADMAP.md) and preserved high-signal research as the baseline; do not restart the portfolio review by default. Reconcile the live checkout, delivery receipts, new owner direction, changed evidence, intents, ADRs, brand intakes, typed gates, and relevant source freshness. Classify the important findings as still valid, changed, superseded, or newly learned, and update only the roadmap portions affected by those deltas. Reopen the whole product direction only when new evidence undermines its assumptions or the owner asks for a ground-up review. Then do the requested bounded, parallel research fan-out across relevant product, technical, security, operations, and design lenses, including an adversarial pass and primary sources where useful. Present one evidence-backed immediate-scope recommendation and the refreshed directional roadmap at the outset. This is upstream planning only: future horizons are not requirements, phase plans, or authorization. Create executable requirements and downstream OpenGSD phase work only for the bounded scope the owner selects after its typed prerequisites pass. Do not chain the next milestone automatically. Keep dependencies lean and run cheap, high-signal consistency checks before long suites. See [INT-20261120-11](../intent/sources/2026-11-20-11-delta-curated-rolling-roadmap.md), [INT-20261120-12](../intent/sources/2026-11-20-12-upstream-milestone-scope.md), [INT-20261119-06](../intent/sources/2026-11-19-06-research-first-rolling-roadmap.md), and [INT-20261113-01](../intent/sources/2026-11-13-01-ai-assisted-ui-quality-and-dogfood.md).

## Rolling outlook

The [active roadmap](../ROADMAP.md) owns v0.7 Phase 8. Later horizons are sequencing guidance subject to the typed prerequisites and delivery gates below. The owner’s broader UI quality and dogfood direction is captured in INT-20261113-01. The earlier brand and adopter direction remains in INT-20261111-13. The ground-up recommendation and its evidence are in [the 2026-11-20 product roadmap review](../research/2026-11-20-ground-up-product-roadmap-review.md).

| Horizon | Recommended direction |
|---|---|
| Active milestone, Phase 8 | **v0.7 First inspectable Book.** Deliver a locally openable Fablebook UI catalog around one source-grounded Logistify operator job. Provide a short user flow through two or three addressable screens using the compiled Story/Scenario and real host Canvas path. Use fixed, cited, illustrative data, neutral catalog chrome and branded preview styling. Pin the source subset and pass the mount and production-exclusion checks before Book implementation. The exception expires at closeout, and the aggregate stays open. See [the active roadmap](../ROADMAP.md). |
| Following | **Prove the short feedback loop:** make one deterministic, cited bundle for the first Book, review one focused design change with the owner, and rerun the same cheap checks and representative capture. This pulls the thin bundle forward relative to the inherited 35-phase order, as the original FEATURES and ARCHITECTURE research recommends; defer the allocator, every focus, and broad capture matrices. Then validate one actual high-reuse mailglass component as an early host-fidelity pilot; keep full dogfood clearance separate. |
| Mid | **Complete the Logistify showcase:** apply the pinned shared brand canon and author the operator, shipper, and driver Books with distinct jobs, screens, Journeys, and representative states. Recover the exact source files reproducibly and preserve asset/name rights and review limits. Keep the workbench chrome neutral; the Book content follows the Logistify source where accepted. Do not build complete logistics applications, production backends, or claim sourcebook mockups are shipped UI (INT-20261120-08). |
| Later | Extend the proven loop only where real authoring or review exposes a need: safe typed Controls/URL state, Journey checks, accessibility and visual coverage, host isolation/diagnostics, installer/DX, additional bundle focuses, and the remaining accepted showcase products. Keep Chatly and Clinicly next for CJK/mobile, RTL, and accessibility coverage; Finanza and Shopadelic follow for money, imagery, and white-label. Continue full mailglass/accrue_admin dogfood, hardening, and C1–C10 release evidence as separate proof. |

This reorders when a person first gets value without deleting the original 127 requirements or 35-phase traceability map. Preserve the existing architecture, security stops, and release criteria. The detailed inherited phase table below remains the legacy dependency inventory except for the re-scoped first slot and its dependencies. The active v0.7 requirements and executable phase decomposition still belong to `$gsd-new-milestone`; this roadmap does not activate other future phases.

**Verified product state (2026-11-20):** Fablebook and Logistify source-intake decisions are preserved in planning references, but are not applied canon. The intake reports 31 Fablebook assets staged in an ignored local clone and unresolved destinations/rights; Logistify's source files were uncommitted at capture. The current working tree and refreshed `origin/main` contain no `hosts/` directory, no authored Books or Logistify scenarios in `lib/` or `test/`, and the router is still an unreleased placeholder. ADR 0020 describes host apps, so reconcile that historical decision with the current tree before claiming host readiness. A first branded showcase, once prerequisites pass, should be the Logistify operator console; the shipper portal and driver app remain separate Books under the shared canon. Per INT-20261120-08, these are authored Books for representative screens/workflows/states, not commitments to build full demo applications.

## Guard prerequisite and next-scope boundary

The owner approved a one-milestone `first-inspectable-book` exception (INT-20261120-14). This is not aggregate closure or a general prerequisite change: the exception is limited to a fixed, developer-authored compiled Book in development/test and expires at v0.7 closeout. The public mount macro must be constrained to literal module alias/reference AST forms and contract-tested; production route/story exclusion must pass positive controls and a negative reachable-mount control before Book implementation. The original `walking-skeleton` milestone key remains blocked. Controls, user values/code, audited-API use, persistence, publication, release, and follow-on scope remain outside the exception.

The product blocker is the open guard-aggregate gate, which blocks the Walking Skeleton. v0.2 completed its selected EX-010 set, inets:enable_trace/2 and /3, without closing other row owners. v0.3 selected three of the 177 EX-107 matches per lane: asn1ct_rtt:assert_defined/1, code/0 and dependencies/1. The other 174 remain in the full-row complement. The older 13/164/161 partition is separate and must not be substituted for that 3/174 partition.

The archived aggregate inventory and old EX-165 Leex candidate are historical sizing evidence, not a current next-scope selection. Before an increment can be proposed, the owner decides whether to fund further guard work; then the full surviving row/function sets and source identities must be rejoined on both pinned lanes, with one exact selected family, its complete complement, caller/delegate evidence and fresh source/context/effort sizing. Preserve the inherited limits: 100,000 planning tokens, at most five exact source files per task, 2–3 tasks per plan, at most five plans per phase, and roughly three working days per plan. Keep guard PRs contract-only, never invoke audited APIs, and preserve the real-library collision stop.

A bounded increment closes only its named selection. Walking Skeleton requires the complete original aggregate plus installed-wide acceptance. Do not generate an automatic sequence of increments or describe a partial row as aggregate closure.

## Recommended quality loop for UI slices

This is a cross-cutting product direction, not a newly activated requirement set. The aim is to turn a sourced job into inspectable, realistic UI evidence, then use bounded automation to find and fix defects with little repeated owner input.

1. Start from the business goal, target persona and job, product vocabulary, accepted brand rules, and source provenance. Treat brandbook examples as input rather than proof of product behavior. Keep unclear naming or conflicting recommendations visible for an owner decision.
2. Model the job across Fablebook’s existing hierarchy: Primitive, Pattern, Area, Screen; connect screens with Journeys. Make components, sections, control groups, pages, screens, states and user flows traceable to the job and terminology.
3. Render through the real host pipeline. Keep the catalog’s own neutral chrome distinct from each preview’s brand. Exercise mobile widths, desktop widths, themes, long content, and the accepted state classes, including happy, empty, one, many, boundary, loading, error, denied, stale, long, internationalized and huge content where they apply.
4. Produce repeatable evidence for accessibility, contrast, focus and keyboard use, target size, overflow, responsive layout, terminology and voice, onboarding completion, Journey dead ends and copy drift, and deterministic visual captures. Missing coverage stays visible; a waiver has a reason.
5. Give an LLM a deterministic, cited bundle with the job, brand and glossary context, relevant screens, screenshots, markup, accessibility tree, measurements and current findings. Ask for a focused critique such as layout, typography, copy, accessibility, brand consistency or Journey usability. Keep recommendations advisory and actionable.
6. Fix the findings, rerun the same checks, record the verdict and reason, and ratchet unresolved findings down. A person judges spacing, alignment, proximity, grouping, breathing room and type hierarchy against the brand book, resolves ambiguity with a rationale, and accepts visual baselines; baselines are never accepted automatically.

The intended catalog structure, browser checks, evidence bundles, and baseline rules remain those in the accepted product requirements and ADRs. This roadmap does not add an LLM API or replace owner review.

### Original high-signal research carried forward

This roadmap is a synthesis of the preserved research, not a replacement for it. Keep the original files and their dated provenance as the detailed source of truth:

- **Architecture:** compiled Story modules, plain-function Scenarios, deterministic catalog, shared render seam, real host pipeline, and no server process state remain the design foundation ([ARCHITECTURE](../research/ARCHITECTURE.md), ADRs 0001–0006). The first Book combines only the minimum of these layers needed for an inspectable outcome; it does not replace the intended architecture.
- **Earlier proof of value:** move one thin, cited Scenario bundle forward and validate host fidelity with real adopter components early; keep allocator/full-focus work and complete dogfood later ([FEATURES](../research/FEATURES.md#9-implications-for-the-roadmap), [ARCHITECTURE](../research/ARCHITECTURE.md)). This resolves the long wait in the old order without turning the first milestone into the full quality system.
- **Scope discipline:** retain the 127 requirements and 35 sequential-phase inventory for coverage and traceability; keep the rule to split work that exceeds the plan cap instead of compressing it ([SUMMARY](../research/SUMMARY.md), [INT-20261028-16](../intent/sources/2026-10-28-16-approve-35-phase-roadmap.md), ADR 0021). The selected path may be resequenced only through a reviewed phase-map change.
- **Product and user research:** distinguish Fablebook's evaluator, AI-agent, and library-author users from the fictional adopter personas; keep assumed personas visibly assumed ([PERSONAS-JTBD](../../docs/research/PERSONAS-JTBD.md)). A Book is an inspectable record of UI jobs, screens, Journeys, and states, not a simulated business system ([TWINS](../../docs/research/TWINS.md), INT-20261120-08).
- **Brand and design decisions:** retain the neutral Fablebook catalog and branded preview, source citations, accepted vocabulary, state coverage, responsive/accessibility review, human-owned visual baselines, and explicit rights review ([UX-DESIGN](../../docs/research/UX-DESIGN.md), [LESSONS-LEARNED](../../docs/research/LESSONS-LEARNED.md), [Fablebook intake](fablebook-brand-intake.md), [Logistify intake](logistify-brand-intake.md)). Brand recommendations remain source input until mapped into the accepted Fablebook contract.
- **Engineering and operations:** preserve no-eval/no-input-atoms and production exclusion, avoid adding a required runtime or Node dependency, and prefer existing Elixir/Phoenix primitives or small local code when sufficient (ADRs 0004, 0006, 0018). Run format/compile and focused model/render checks before browser work; reserve the browser for real host/CSP/layout claims, then retain both required CI lanes. Automate objective UAT, but keep one-off checks out of recurring CI unless they have ongoing value; use `act` only when its runner is viable, measure CI speedups without removing gates, and name/clean only task-owned Docker resources ([VERIFICATION](../VERIFICATION.md), [CI performance policy](CI-PERFORMANCE.md), [INT-20261120-13](../intent/sources/2026-11-20-13-automated-verification-and-resource-hygiene.md), [primary-source research](../research/2026-11-20-ui-roadmap-primary-sources.md)).
- **Research freshness:** keep the original 2026-10-28 research immutable and linked. Recheck ecosystem versions, competitor behavior, and transient dependency advice when a selected milestone actually depends on them; historical research is not a current version pin ([STACK](../research/STACK.md), [PITFALLS](../research/PITFALLS.md)).

## Dogfood and authored-showcase tracks

The real adopter and the fictional demo serve different proofs. ADR 0020 names the mailglass demo as the first migration and dogfood target because it has the most stories and establishes the migration method; accrue_admin follows. Select the exact high-reuse screen only after inspecting the mailglass catalog. Clearance C4 requires at least three owner design iterations driven by Fablebook bundles in a dogfood repository.

The authored showcase remains Logistify’s operator console first, then its shipper portal and driver app. The shared canon must preserve the three Books’ different jobs and constraints. Chatly and Clinicly follow the Logistify family. Keep this track separate from evidence that the product works in a real adopter repo.

## Current brandbook inventory

The owner has identified seven public, version-tagged sourcebook repositories: fablebook-brand v2.1, logistify-brand v1.0, chatly-brand v0.3, clinicly-brand v0.3, shopadelic-brand v0.3, finanza-brand v0.2, and classwell-brand v0.2. Their exact commits and clone URLs are recorded in the root [`brand_sources.lock.json`](../../brand_sources.lock.json); they are fetched into the ignored `.cache/brand_sources/<name>/` directory by `bin/fetch_brand_sources`. The repo-root books and records are now the canonical source paths; older mapping-guide references to `docs/brand/<name>-handoff/...` mean the same repo-relative paths (INT-20261121-01). This supersedes the earlier assumption that the originals were only in local handoff folders or absent from `main`. The public sourcebooks are inputs, not applied Fablebook canon, approved assets, a Fablebook importer contract, signed-off UI, accessibility proof, or runnable Fablebook demo. A preserved snapshot at commit 71d93704fcd5689fc9c600e558b47ebfe01a6a8d contains a static multi-brand preview; it remains historical evidence. No Snow sourcebook is included in the seven repositories; identify its repository or artifact only if Snow later enters scope.

Keep complete repositories and unreviewed assets out of this checkout; normal source checks use the exact locked commit and never move pins. The v0.7 exception permits only the minimal, cited Logistify excerpt manifest and source-derived Book content in a reviewed public PR. Reuse rights, fonts, artwork and name clearance remain open beyond that limited demo subset. The current workbench chrome remains governed by accepted ADR 0013 and UX-DESIGN; a sourcebook or manual prototype does not override those decisions.

### Brand source custody and mapping

The version/commit lock is the source of provenance for all seven public books. Fetch only into the ignored cache with `bin/fetch_brand_sources`; do not depend on local handoff folders, copies under `docs/brand/`, mutable latest downloads, or floating branches. For Logistify, `bin/verify_logistify_source --check-original .cache/brand_sources/logistify-brand` checks the existing whole-file hashes, and `--check-pinned` checks the cited excerpt capsule. A pin update is an explicit `--update` operation and its lock change and any re-hashed source facts belong in one reviewed PR. Do not copy full sourcebooks, PDFs, artwork or fonts by default; destination and reuse terms remain review items. This change to source custody does not authorize applying any brand canon.

Treat each brandbook's product recommendations as source input, not evidence of an implemented product. Source `flows` and `cases` need an explicit mapping to Fablebook's model before canon work; Fablebook's GLOSSARY owns UI terminology. A Logistify Route is a shipment-domain object, not a Fablebook Journey. The books should remain three Books with different jobs and screen constraints under the shared Logistify brand canon.

| Milestone | Local slot or active phase | Deliverable | Legacy phase |
|---|---|---|---|
| First inspectable Book | Global Phase 8 | First inspectable Book and local host path (single-milestone exception) | 2 |
| Story model and render seam | 1 | Story model and catalog | 3 |
| Story model and render seam | 2 | Render seam, rules engine and generated tests | 4 |
| Controls and first bundle | 1 | Controls and URL state | 5 |
| Controls and first bundle | 2 | Thin bundle slice | 6 |
| Canvas fidelity and installer core | 1 | Canvas isolation and containment | 7 |
| Canvas fidelity and installer core | 2 | Canvas diagnostics, hot reload and Globals | 8 |
| Canvas fidelity and installer core | 3 | Operator host, fidelity receipt and real components | 9 |
| Canvas fidelity and installer core | 4 | Installer core | 10 |
| Workbench UX | 1 | Chrome shell, sidebar, story page and grid | 11 |
| Workbench UX | 2 | Inspector, toolbar, palette and keyboard | 12 |
| Workbench UX | 3 | Mobile layout, QR, microcopy, Compare by Globals and Diagnostics | 13 |
| Design canon and adopter Books | 1 | Canon core | 14 |
| Design canon and adopter Books | 2 | Foundations, Themes, Directions, citations, coverage and To review | 15 |
| Design canon and adopter Books | 3 | Canon lints, tokens task and DESIGN.md | 16 |
| Design canon and adopter Books | 4 | Content track I - Apply the Fablebook sourcebook and build the Logistify family | 17 |
| Design canon and adopter Books | 5 | Content track II - Chatly and Clinicly | 18 |
| Design canon and adopter Books | 6 | Bundle core with canon | 19 |
| Checks and visual regression | 1 | Probe, Evidence and the Checks tab | 20 |
| Checks and visual regression | 2 | Capture and visual baselines | 21 |
| Checks and visual regression | 3 | Sweep, Ratchet and verdicts | 22 |
| Checks and visual regression | 4 | UX checks I - interaction states, forms, layout shift, RTL | 23 |
| Checks and visual regression | 5 | UX checks II, journeys and design.json | 24 |
| Motion | 1 | Motion spike, time shim and Motion panel | 25 |
| Motion | 2 | Motion tokens, checks and CI lane | 26 |
| LLM context bundles | 1 | Bundle browser tier and allocator | 27 |
| LLM context bundles | 2 | Focus framework, review focuses and gen.screens | 28 |
| LLM context bundles | 3 | Compare, journey and motion focuses | 29 |
| Installer and DX | 1 | Generators, doctor shell and migrator | 30 |
| Installer and DX | 2 | Image export, Docker demo and string check | 31 |
| Installer and DX | 3 | Guides, docs brand and compatibility | 32 |
| Hardening and remaining twins | 1 | Hardening | 33 |
| Hardening and remaining twins | 2 | Finanza and Shopadelic twins | 34 |
| Dogfood setup | 1 | Dogfood setup | 35 |

## Dependencies and preserved gates

The crosswalk keeps legacy traceability while the immediate path is resequenced. The old `walking-skeleton` key remains blocked by the complete guard aggregate, including installed-scope acceptance. The first Book uses its separate v0.7 exception with all stated preconditions and exclusions. SEC-01 stays Pending with Controls and first bundle's first local slot (legacy Phase 5). The first Book includes a positive development/test mount check and production route/story exclusion checks. Historical registry observation remains with scheduled security automation. Phase 8 is active. Later slots stay directional until their milestones activate.

Before Design canon and adopter Books / local slot 4 (legacy Phase 17), read references/logistify-brand-intake.md. The brand source is unapplied; schema mapping and the existing review limits remain. The workbench stays visually neutral. No asset move or publication is included.

## Carried phase details

### First inspectable Book / global Phase 8

Legacy Phase 2 is re-scoped as the v0.7 first visible product slice under INT-20261120-14. See [the active Phase 8 roadmap](../ROADMAP.md#phase-8-first-inspectable-book-and-local-host-path) for its requirements, delivery sequence and acceptance.

**Goal**: A Phoenix developer can open a real Fablebook UI catalog locally, select one source-grounded Logistify operator Book, and inspect a short flow across 2–3 addressable screens with fixed, cited data through the compiled Story/Scenario and real host Canvas path.
**Mode:** mvp
**Depends on**: the delivered legacy guard evidence and the recorded single-milestone exception. Before Book implementation, pass the literal module alias/reference macro contract and production exclusion checks defined in INT-20261120-14.
**Scope**: Reproduce the seven public source repos from exact locked commits; preserve the existing Logistify whole-file hashes and cited-excerpt hashes; allow the minimal cited Logistify source subset and Book content in a reviewed public PR; preserve name and asset-rights limits; use neutral catalog chrome and a source-styled preview; provide only enough navigation to inspect the Book and its screens; identify all records/actions as illustrative; include a representative source-backed error or empty state as well as the ordinary state; do not create business persistence or external writes.
**Verification**: cheap source/fixture/vocabulary checks and compile first; focused catalog/render/route tests and positive/negative production controls next; one real-host browser pass for CSP, CSS/fonts/layout, keyboard/focus/semantics and narrow/desktop behavior; then normal required CI. Keep the mount-macro contract test and implementation in separate PRs per ADR 0021. Use no new runtime dependency or required Node setup.
**Explicit non-goals**: full logistics app/backend, database, user authentication, arbitrary runtime story loading, Controls or URL overrides, complete workbench, complete Book family, sourcebook-wide asset import, trademark clearance or marketing claims, product publication/deployment, full browser-runner matrix, broad visual-baseline program, or release.
**Plans**: Phase 8 planning follows the [active roadmap](../ROADMAP.md).

### Story model and render seam / local slot 1: Story model and catalog

Legacy Phase 3. Future, not activated.

**Goal**: Authors declare stories as compiled modules, and the catalog finds, identifies and describes every scenario and every component, with or without a story, deterministically, with typed errors and telemetry in place.
**Mode:** mvp
**Depends on**: First inspectable Book / global Phase 8
**Requirements**: CORE-01, CORE-02, CORE-04, CORE-05, CORE-06, CORE-07, TEL-01, TEL-02, TEL-03, PERF-01, COMPAT-01
**Partial delivery**: CORE-03 (citation shape only; existence and enforcement complete in Design canon and adopter Books / local slot 2).
**Provisional on:** Q12, Q13, Q24
**Success Criteria** (what must be TRUE):
  1. A story with `use Fablebook.Story, subject:, tier:` appears in the catalog with ids from module namespace plus function name and a stable URL for every scenario, including scenarios inside groups; the catalog is identical in dev and test.
  2. A person who adds or deletes a story module in a running host sees the catalog change after a reload, with no restart; a test of the discovery seam proves both directions.
  3. A component with no story in the Book's `components:` list shows as Unstoried, filled only from `default`, then `examples`, then `values`, otherwise a "Needs a story" tile; a string slot, a second story for one component, or a LiveView subject without a Waiver fails compilation with file, line, value and a fix.
  4. The `ComponentInfo` contract test passes on the floor, latest and canary lanes, and an injected fault degrades to manual controls instead of crashing.
  5. A 5000-scenario catalog builds in at most 1.5 s with t(5000)/t(500) under 15 and no `Code` calls; every event in `Fablebook.Telemetry.events/0` is emitted and none unlisted, with whitelisted metadata and a closed `%Fablebook.Error{}` set.
**Plans**: 5 (estimate)

### Story model and render seam / local slot 2: Render seam, rules engine and generated tests

Legacy Phase 4. Future, not activated.

**Goal**: Any scenario can be rendered outside a LiveView and judged by one rules registry, so the canvas, tests and bundles agree; every strict-rule failure is an error unless a visible Waiver or Draft says otherwise.
**Mode:** mvp
**Depends on**: Story model and render seam / local slot 1
**Requirements**: CORE-09, CORE-12, CHECK-05
**Partial delivery**: CORE-14 (render-mode metadata; completes in Canvas fidelity and installer core / local slot 1), LLM-06 (manifest and drift check; completes in Design canon and adopter Books / local slot 6).
**Pending (not v1, unmapped)**: CORE-15 (`unsupported_subject` for LiveComponent subjects), waiting on Q14.
**Provisional on:** Q14, Q16, Q20
**Success Criteria** (what must be TRUE):
  1. `Fablebook.Render.render(scenario, globals, purpose)` returns identical normalized markup and hash for one scenario across different nonces, CSRF values, generated ids and timestamps, and a real attribute change changes the hash.
  2. `Fablebook.Testing.generate_tests(book)` produces one ExUnit test per scenario (renders, attrs valid, desc present, citations resolve) in `hosts/vanilla` with no per-scenario code, and `mount_scenario/2` uses `live_isolated`.
  3. A strict-rule violation is an error; the same violation under a per-story or per-scenario Waiver with a written reason passes and is counted visibly; under Draft it is a warning; no global switch exists.
  4. `mix fablebook.manifest` writes byte-identical output on repeated runs and a drift check fails when the committed manifest is stale.
**Plans**: 5 (estimate)

### Controls and first bundle / local slot 1: Controls and URL state

Legacy Phase 5. Future, not activated.

**Goal**: A person can change a scenario's attrs through typed controls, and the whole view state round-trips through the URL, with the never-eval and never-atom guarantees proven against hostile input.
**Mode:** mvp
**Depends on**: Story model and render seam / local slot 2
**Requirements**: CTRL-01, CTRL-03, CTRL-06, SEC-01
**Partial delivery**: CTRL-04 (Globals type and codec; completes in Canvas fidelity and installer core / local slot 2), CTRL-02 and SEC-05 (complete in Workbench UX / local slot 2), QA-01 (cast and URL state properties; completes in Design canon and adopter Books / local slot 3).
**Success Criteria** (what must be TRUE):
  1. In the minimal workbench, attrs show typed controls (boolean, integer, float, string, and a select for `values:`), complex attrs offer compiled presets, and invalid input is rejected with a typed error rather than a crash.
  2. Reloading any workbench URL reproduces the view exactly, overrides over 2 KB are refused, and Back returns to the previous workbench URL.
  3. "Copy as scenario" yields Elixir text for a Draft scenario with the overridden attrs and a TODO situation; nothing is written to disk and no atoms are created.
  4. Properties show zero new atoms after warm-up through the real `handle_params` for arbitrary URL and control input, an XSS corpus stays escaped, and mutation-proven tests fail when a Credo ban or a guard is removed; Muex floors for `Cast` and `URLState` are committed.
**Plans**: 4 (estimate)

### Controls and first bundle / local slot 2: Thin bundle slice

Legacy Phase 6. Future, not activated.

*Pulled forward from Family 9, ahead of its home band so the Core Value (an accurate export) is exercised before the workbench exists.*
**Goal**: A person can run one command and get a redacted, labelled context bundle for one scenario.
**Mode:** mvp
**Depends on**: Story model and render seam / local slot 2, Controls and first bundle / local slot 1
**Requirements**: SEC-04
**Partial delivery**: LLM-01 (scenario selector and Mix task; completes in Design canon and adopter Books / local slot 6), LLM-02 (skeleton; completes in LLM context bundles / local slot 1), LLM-04 (no-browser level; completes in LLM context bundles / local slot 1).
**Provisional on:** Q20
**Success Criteria** (what must be TRUE):
  1. `mix fablebook.bundle <scenario>` writes `BUNDLE.md` and `bundle.json` (schema `fablebook.bundle/1` skeleton) with markup, Contract, situation and citations as data, labelled "no-browser", with browser-only parts reported as not-run.
  2. Paths, env values, hosts, secret-shaped strings and session or CSRF tokens never appear in a bundle, a `redact:` hook adds custom redaction, and `--out` outside the project root is refused with `:path_rejected`.
  3. Running the command twice on unchanged input yields byte-identical output, and one golden bundle is committed.
**Plans**: 3 (estimate)

### Canvas fidelity and installer core / local slot 1: Canvas isolation and containment

Legacy Phase 7. Future, not activated.

**Goal**: Scenarios render in an iframe through the host's own pipeline, the grid lays out several scenarios, and whatever one scenario does wrong stays inside its own tile.
**Mode:** mvp
**Depends on**: Controls and first bundle / local slot 1
**Requirements**: CANVAS-01, CANVAS-02, CANVAS-03, CANVAS-04, CANVAS-07, CORE-10, CORE-14, SEC-03
**Provisional on:** Q8, Q23
**Spike first**: grid isolation with adversarial fixtures (duplicate ids, a hook, a portal, a modal, `min-h-screen`, a LiveComponent crashing in `handle_event`); the result decides per-tile iframes versus a stacked document.
**Success Criteria** (what must be TRUE):
  1. A scenario shows in an iframe with the host's real `app.css`, `app.js`, colocated hooks and fonts under a nonce CSP with `frame-ancestors 'self'`, and no `eval`, `new Function` or inline `style=` appears in chrome or placement CSS.
  2. The All-scenarios grid lazy-loads its tiles, and the adversarial fixtures do not interfere with each other; the spike decision is recorded.
  3. A scenario that raises, throws, exits, times out at 2 s, exceeds its heap, or crashes a LiveComponent in `handle_event` shows an error panel while the workbench and the other tiles keep rendering.
  4. Events and navigation the canvas has no handler for appear as "Event recorded" or "Would navigate to /x"; the event log keeps string names and truncated payloads scoped to the canvas, and a forged token on the `Phoenix.Token`-signed topic is rejected.
  5. Scenarios render inside Containers with `:centered`, `:padded` or `:fullscreen` Placement; a `render: :static` story is served by a controller with no LiveSocket, and a check flags `phx-*` bindings in it.
**Plans**: 5 (estimate)

### Canvas fidelity and installer core / local slot 2: Canvas diagnostics, hot reload and Globals

Legacy Phase 8. Future, not activated.

**Goal**: When the canvas cannot work the person is told why, edits show up without a restart, and the Globals change what renders.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 1
**Requirements**: CANVAS-05, CANVAS-06, CTRL-04
**Pending (not v1, unmapped)**: CTRL-05 (how the host applies color scheme and Theme), waiting on Q10.
**Provisional on:** Q10, Q11, Q13
**Spike first**: a same-origin CSSOM rewrite of `prefers-color-scheme` rules, and the Phoenix 1.8 `data-theme` convention checked on a fresh `phx.new`.
**Success Criteria** (what must be TRUE):
  1. A canvas that fails to connect shows a diagnostic naming the likely causes (missing `window.liveSocket`, `frame-ancestors`), produced by the pure Doctor core.
  2. Recompiling a story or component updates the open workbench without a restart, and the reloaded view is restored from the URL.
  3. Locale (Gettext), text direction, motion (full, reduce, off), color scheme, theme and device frame (none, phone, tablet, laptop, desktop, with safe areas, status bar and standalone display) each change what renders; Globals that need real emulation are labelled "Simulated".
  4. The canvas reports ready through a tested ready-attribute state machine (LiveSocket joined, nested views settled, fonts and images loaded), and reports not-run with the unmet condition otherwise.
**Plans**: 4 (estimate)

### Canvas fidelity and installer core / local slot 3: Operator host, fidelity receipt and real components

Legacy Phase 9. Future, not activated.

**Goal**: The adversarial host app proves production fidelity, and real components from an owner repo render in a released 0.x.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 2
**Requirements**: QA-04
**Pending (not v1, unmapped)**: CORE-16 (fixture helper for streams, async and forms), waiting on Q14.
**Provisional on:** Q22
**Success Criteria** (what must be TRUE):
  1. `hosts/operator` is complete (custom tokens without daisyUI, self-hosted fonts, strict nonce CSP, custom root layout, `current_scope` `on_mount`, colocated hooks, JS commands, `<.portal>`, streams and async assigns, `to_form`, Gettext with an RTL locale), and its E2E fidelity spec passes on CSS bytes, fonts (`document.fonts` and network), hooks and CSP (C3).
  2. A 0.x release is installed read-only in one dogfood repo, and ten real mailglass components render there without changes to that repo's CSS or JS.
  3. A throwaway installer-shape spike against `hosts/vanilla` leaves a written result that Canvas fidelity and installer core / local slot 4 consumes.
**Plans**: 4 (estimate)

### Canvas fidelity and installer core / local slot 4: Installer core

Legacy Phase 10. Future, not activated.

*Pulled forward from Family 10, so the installer's mount-shape surprises surface here rather than in Phase 30.*
**Goal**: `mix igniter.install fablebook` on a fresh Phoenix app leaves exactly the tree that was hand-wired in the host apps.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 3
**Requirements**: INST-01
**Provisional on:** Q17
**Success Criteria** (what must be TRUE):
  1. On a fresh `phx.new` the installer mounts `/dev/fablebook` inside `dev_routes` and sets up `elixirc_paths`, live_reload, the formatter inputs, the Book with `components:` seeded, a welcome page and a sample story, leaving `app.js` and the Tailwind config byte-identical.
  2. The installed tree equals the hand-wired `hosts/vanilla` tree (golden), and applying the installer twice or from a partial state gives the same result.
  3. `MIX_ENV=prod mix compile` of the installed app succeeds with no Fablebook routes, and a plain-Mix fallback works when Igniter is absent.
**Plans**: 4 (estimate)

### Workbench UX / local slot 1: Chrome shell, sidebar, story page and grid

Legacy Phase 11. Future, not activated.

**Goal**: A person can browse the catalog in the workbench: a tier-first sidebar, a story page that is the docs, and the All-scenarios grid, inside the performance gates.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 1, Canvas fidelity and installer core / local slot 4
**Requirements**: WB-01, WB-02, WB-08, WB-09, PERF-02, PERF-03, PERF-04, INST-05
**Partial delivery**: A11Y-01 (basics; completes in Workbench UX / local slot 3), WB-17 (dots read "Not run"; completes in Checks and visual regression / local slot 1), LLM-01 ("Copy for LLM" button; completes in Design canon and adopter Books / local slot 6), CORE-06 (tier-first sidebar), SEC-05 (Markdown escaped by default; completes in Workbench UX / local slot 2).
**Provisional on:** Q16
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The workbench has three panes with a tier-first sidebar of Section folders, and a story page that shows the description, citations, attr and slot Reference, then the All-scenarios grid by default.
  2. Appearance (System, Light, Dark) restyles the chrome only and never the scenario; the chrome uses ink on neutral, `fb-` OKLCH tokens, system fonts and two density modes with no daisyUI, and render swaps are instant while a subject's own motion plays.
  3. Sidebar dots and tile status say "Not run" until Evidence exists and never show a green dot, and "Copy for LLM" on a scenario copies the thin bundle.
  4. A control change sends a WebSocket diff of at most 4 KB without re-sending the sidebar, mount and render reductions stay within 1.25x the committed reference with a max render of 50 ms over 10k iterations, and session heap stays at or under 3 MB with a leak test within 1.2x and 0 added ETS tables or processes.
  5. A clean-room timed run on a fresh `phx.new` with Node absent from `PATH` goes from install to an auto-discovered component rendering in the host's real CSS in under 5 minutes, passing strict mode with zero Waivers.
**Plans**: 5 (estimate)

### Workbench UX / local slot 2: Inspector, toolbar, palette and keyboard

Legacy Phase 12. Future, not activated.

**Goal**: A person can inspect and edit a scenario, set up the canvas environment from the toolbar, and drive the workbench from the keyboard.
**Mode:** mvp
**Depends on**: Workbench UX / local slot 1
**Requirements**: CTRL-02, WB-03, WB-04, WB-06, WB-11, WB-15, WB-18, SEC-05
**Partial delivery**: WB-05 (Attrs, HEEx and Events tabs; the Checks tab completes it in Checks and visual regression / local slot 1), CTRL-04 (device frame tool).
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The inspector shows Attrs, HEEx (copy the exact call) and Events; an edited control shows an "Edited" chip with Restore scenario, and attrs that cannot be edited say "Set in the story file" with Open in editor, which works only on localhost and only for paths inside the project root.
  2. The toolbar offers width presets 320/375/768/1280/1440 with a height and a rotate action (`orient`), Fill and custom, opening at 375, plus color scheme, theme, direction, zoom, outline, measure, background (only for transparent subjects), Isolate, fullscreen, light/dark side by side and the device frame picker, each tool showing its value as text and appearing only when it applies.
  3. The command palette (cmd-K) searches stories, scenarios, pages, canon and commands, `/` filters the sidebar by tier, state class, tag, Draft, has-findings and has-Waiver, and single-key shortcuts can be switched off and are suspended while focus is in the preview.
  4. Workbench settings (Appearance, density, single-key switch, pane sizes) persist and are listed, and input over a control type's size cap is refused with `:state_too_large`.
**Plans**: 4 (estimate)

### Workbench UX / local slot 3: Mobile layout, QR, microcopy, Compare by Globals and Diagnostics

Legacy Phase 13. Future, not activated.

**Goal**: The workbench works on a phone, every empty and error state speaks in canonical words, and the chrome meets WCAG 2.2 AA.
**Mode:** mvp
**Depends on**: Workbench UX / local slot 2
**Requirements**: WB-07, WB-10, A11Y-01
**Partial delivery**: WB-13 (Compare along Globals axes with a canvas cap; completes in LLM context bundles / local slot 3), WB-12 (catalog build time, scenario count and recent crashes; completes in Checks and visual regression / local slot 3).
**Provisional on:** Q21, Q25
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Below 768 px the workbench switches to Mobile layout, and "Show on phone" shows a QR code when the server is reachable and otherwise names the real causes (server bound to loopback, `check_origin`) without ever binding the LAN.
  2. Every empty, error and disconnected state shows its canonical microcopy from UX-DESIGN.
  3. Compare shows two renditions that differ in exactly one Global side by side, capped at four live canvases, and the Diagnostics page shows catalog build time, scenario count and recent crashes.
  4. The chrome has landmarks, skip links, a disclosure-list sidebar, live regions, keyboard-resizable separators, a combobox palette, 24 px targets and reflow at 320 px, and its computed contrast matrix across light, dark and high contrast has no failing pair.
**Plans**: 4 (estimate)

### Design canon and adopter Books / local slot 1: Canon core

Legacy Phase 14. Future, not activated.

**Goal**: Design knowledge lives in `design/` as Markdown and DTCG tokens that Fablebook parses itself, layered from brand to product, and pages can embed live scenarios.
**Mode:** mvp
**Depends on**: Story model and render seam / local slot 2
**Requirements**: CANON-01, CANON-02, CANON-03, CANON-09, CANON-12, CORE-11
**Partial delivery**: QA-01 (frontmatter property; completes in Design canon and adopter Books / local slot 3).
**Provisional on:** Q30
**Success Criteria** (what must be TRUE):
  1. A canon entry of each kind (term, voice, tone, microcopy rule, persona, job, twin, imagery) loads from a Markdown file with strict-subset frontmatter, and a malformed file fails with its file, line and a fix; the parser is property-tested and uses no YAML dependency.
  2. DTCG 2025.10 tokens with a light/dark resolver load, and external brand-book source's `brandbook/tokens/identity.json` is read with `$extensions` unchanged on a round trip and never written.
  3. A product canon inherits a brand canon that comes from a path or a dependency, and overriding a brand rule without a Waiver fails.
  4. A Markdown or HEEx Page embeds a live scenario, and the embed follows the scenario when it changes.
**Plans**: 4 (estimate)

### Design canon and adopter Books / local slot 2: Foundations, Themes, Directions, citations, coverage and To review

Legacy Phase 15. Future, not activated.

**Goal**: The canon is visible in the workbench and enforced against scenarios: Foundations pages, citation checks, a coverage matrix, Themes, Directions and a first To review page.
**Mode:** mvp
**Depends on**: Workbench UX / local slot 1, Design canon and adopter Books / local slot 1
**Requirements**: CANON-04, CANON-08, CANON-10, CANON-11, CORE-03, CORE-08, JOURNEY-01
**Partial delivery**: WB-14 (To review lists proposals, stale or assumed canon, gaps and due Waivers; findings without a verdict complete it in Checks and visual regression / local slot 3), WB-13 (Theme and Direction axes; completes in LLM context bundles / local slot 3), WB-03 (canon entries appear in the palette).
**Provisional on:** Q16, Q25, Q26
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The Foundations section shows token swatches, type scale, radius, shadow and motion specimens, contrast cards, the glossary table, voice, and persona, job and twin cards that link to the scenarios citing them.
  2. A scenario that cites a persona, job or twin that does not exist fails the catalog build, and Area and Screen scenarios without a persona and job warn until the canon has its first persona and error after that, waivable per scenario only; orphan personas and uncovered jobs are reported.
  3. The coverage matrix crosses stories with the 12 state classes, each cell a scenario or a reasoned Waiver, and Gaps are listed.
  4. A Book renders under several named Themes, a twin's own theme is selectable, an unreadable theme choice becomes a Guardrail finding, and Directions (proposal until chosen, importable from external brand-book source routes) can be picked in the toolbar and compared across the catalog; choosing one archives the rest.
  5. A To review page with a sidebar count badge and no pop-ups lists proposals, stale or assumed canon, Gaps and Waivers due, and a Journey declared in a job file fails the catalog build when a referenced scenario is missing.
**Plans**: 5 (estimate)

### Design canon and adopter Books / local slot 3: Canon lints, tokens task and DESIGN.md

Legacy Phase 16. Future, not activated.

**Goal**: The canon is checked in the PR lane by pure-Elixir lints, imported from external brand-book source, and turned into CSS and a DESIGN.md.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 1, Design canon and adopter Books / local slot 2
**Requirements**: CANON-05, CANON-07, UX-06, QA-01
**Partial delivery**: CANON-06 (`DESIGN.md` and `mix fablebook.tokens`; `.impeccable/design.json` completes it in Checks and visual regression / local slot 5).
**Provisional on:** Q27
**Success Criteria** (what must be TRUE):
  1. external brand-book source's BRAND.md and direction notes appear as Voice, Imagery and Applications pages, logos are filtered by `rights/assets.json`, and a bundle pins the brand by its `inventory.json` hash.
  2. In the PR lane, with no browser, glossary and retired-wording lints over rendered text and accessible names, deterministic voice rules, token conformance and DTCG-to-CSS drift, and a WCAG 2.2 contrast matrix each report findings.
  3. Copy benchmarks flag button word count, title and error length, sentence length, reading grade per persona and generic labels such as "Click here" or "Submit".
  4. `mix fablebook.tokens` generates and checks CSS from the tokens and writes `DESIGN.md` with an ownership header and a spec-version stamp, and it refuses to overwrite a file it does not own.
  5. The StreamData invariants for cast, URL state, id stability, manifest determinism, no new atoms, bounded render, frontmatter, contrast maths and telemetry metadata all run in CI.
**Plans**: 4 (estimate)

### Design canon and adopter Books / local slot 4: Content track I - Apply the Fablebook sourcebook and build the Logistify family

Legacy Phase 17. Future, not activated.

**Goal**: Fablebook's existing pinned v2.1 sourcebook is mapped into accepted product canon and brand surfaces, and the Logistify family exists as three full Books under one shared brand canon.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 3
**Requirements**: DOCS-04
**Partial delivery**: QA-06 (Logistify's three Books; completes in Hardening and remaining twins / local slot 2).
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The authored upstream Fablebook v2.1 sourcebook is made reproducible from its pinned provenance and integrated without reauthoring it; conflicts and asset rights are recorded, only approved assets are copied, and the accepted mark, docs, README, Hex page and social card follow its mapped rules while Workbench chrome stays ink-on-neutral.
  2. In `hosts/operator`, Logistify's brand canon and its three product Books (operator console, shipper portal, driver app) each have personas, jobs, terms, a Shell, Areas and Screens in a visually distinct, dense style with real en, de and fr switching.
  3. The Logistify Books pass the canon lints, citation checks and coverage report, and Foundations shows their cards. If an asset has unresolved rights or provenance, keep that asset out and record the gap without discarding the authored sourcebook or blocking unrelated canon work.
**Plans**: 4 (estimate)

### Design canon and adopter Books / local slot 5: Content track II - Chatly and Clinicly

Legacy Phase 18. Future, not activated.

**Goal**: Two more fictional adopter products, one mobile-first CJK consumer app and one RTL accessibility-critical portal, extend the showcase.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 4
**Requirements**: None completed here (see Partial delivery).
**Partial delivery**: QA-06 (Chatly and Clinicly; completes in Hardening and remaining twins / local slot 2).
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Chatly (ja, mobile-first, playful) and Clinicly (ar with en, RTL, high-contrast, minimal motion) each have an external brand-book source-built brand book, a full canon, a Shell, Areas and Screens and a visually distinct style in `hosts/operator`.
  2. Both Books pass the canon lints and citation checks, and their scenarios cover the state classes their twin stresses (huge counts and stale for Chatly, denied and forms for Clinicly).
  3. The twins stay out of the Hex tarball, shown by the allowlist test.
**Plans**: 3 (estimate)

### Design canon and adopter Books / local slot 6: Bundle core with canon

Legacy Phase 19. Future, not activated.

*Pulled forward from Family 9 so the no-browser tier carries canon context as soon as canon and twins exist.*
**Goal**: A bundle for any selector carries the cited canon, validates against a committed schema, and is guarded by golden bundles from the twins.
**Mode:** mvp
**Depends on**: Controls and first bundle / local slot 2, Design canon and adopter Books / local slot 1, Design canon and adopter Books / local slot 4, Design canon and adopter Books / local slot 5
**Requirements**: LLM-01, LLM-06, LLM-07
**Partial delivery**: LLM-02 (`context/` and no-browser scenario files; completes in LLM context bundles / local slot 1), SEC-04 (already complete).
**Success Criteria** (what must be TRUE):
  1. `mix fablebook.bundle` accepts a scenario, story, section, tier, tag or `all`, and the workbench offers Copy for LLM and Download context.
  2. A bundle's `context/` holds DESIGN.md, the tokens used, glossary hits, voice, personas and jobs and a PRODUCT.md excerpt, and `Fablebook.Bundle.validate/1` round-trips every bundle against the committed JSON Schema.
  3. Three golden bundles from the twins pass, a determinism property holds, and size budgets of about 7.5k text tokens and 1.5 MB per scenario are enforced.
  4. The manifest (`index.json`, `components.json`) is served at the mount, `llms.txt` and `llms-full.txt` are included, and the drift check still passes.
**Plans**: 4 (estimate)

### Checks and visual regression / local slot 1: Probe, Evidence and the Checks tab

Legacy Phase 20. Future, not activated.

**Goal**: A person can run the probe on a rendition in their own browser and read honest Evidence, with no Node and no false green.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 2, Workbench UX / local slot 1, Workbench UX / local slot 2
**Requirements**: CHECK-01, CHECK-02, CHECK-03, WB-05, WB-17, LLM-05
**Provisional on:** Q11
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. "Run checks" in the Checks tab runs the vendored-axe probe against the open rendition with no Node, loaded under the strict CSP, and shows axe results (incomplete counts as a finding), overflow, target size, 200% text, focus walk, computed-style token conformance, contrast and the ARIA snapshot, in a versioned Evidence schema; each finding offers "Copy finding link".
  2. The CI probe uses the same script, schema and rules, and checks that need real emulation report not-run outside the runner, with interactive Globals labelled "Simulated".
  3. The Simulations (reduced motion, 200% text, text expansion +35% with no pseudo-accents, forced colors, RTL, vision-deficiency filters, keyboard-only) can each be applied to a rendition.
  4. Sidebar dots and tile status read the latest Evidence keyed by render hash, say "Not run" until Evidence exists, and label Evidence stale when the rendition changes; "Run checks" at story level covers the width presets.
  5. The inspector offers Attrs, HEEx, Events and Checks.
**Plans**: 5 (estimate)

### Checks and visual regression / local slot 2: Capture and visual baselines

Legacy Phase 21. Future, not activated.

**Goal**: Pixel diffs run deterministically in a pinned container and a baseline can only ever be accepted by a person.
**Mode:** mvp
**Depends on**: First inspectable Book / global Phase 8, Checks and visual regression / local slot 1
**Requirements**: VIS-01, VIS-02, VIS-03, CI-02
**Provisional on:** Q9, Q29
**Success Criteria** (what must be TRUE):
  1. A PR runs visual-core (at most 40 renditions) in the pinned Playwright container with fonts ready, DPR 1, animations off, a ready attribute and a frozen clock, and a test asserts the effective thresholds.
  2. CI fails on a missing baseline, on a changed `git status`, and when the baseline set differs from the manifest; only a person running `bin/visual update` (selective, pinned platform) accepts baselines.
  3. Nightly and release runs cover the full set (at most 400) plus Firefox, WebKit and the LiveView `main` canary; the determinism self-test (identical hashes across three captures) blocks a release, and an open `quality-regression` issue blocks release PRs.
**Plans**: 4 (estimate)

### Checks and visual regression / local slot 3: Sweep, Ratchet and verdicts

Legacy Phase 22. Future, not activated.

**Goal**: Every rendition in the manifest is checked at every standard size and scheme, findings can only shrink, and a person's verdicts are remembered.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 2, Checks and visual regression / local slot 1, Checks and visual regression / local slot 2
**Requirements**: CHECK-04, CHECK-06, A11Y-02, WB-12, WB-14
**Partial delivery**: WB-13 (the revision axis, current rendition against its committed Baseline; completes in LLM context bundles / local slot 3).
**Provisional on:** Q25
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The manifest-driven sweep covers 320/375/768/1280/1440 times light and dark, plus reduced motion, with fingerprinted findings, a PR that grows Known findings fails the Ratchet, and contact sheets publish as CI artifacts.
  2. A verdicts log in the repo records each finding's fingerprint, verdict and reason, and a rejected finding no longer appears in later reports or bundles.
  3. To review also lists findings without a verdict, the Diagnostics page shows evidence staleness, and Compare can show a rendition against its committed Baseline.
  4. The workbench chrome passes Fablebook's own sweep, and the nightly self-test history on `main` begins.
**Plans**: 4 (estimate)

### Checks and visual regression / local slot 4: UX checks I - interaction states, forms, layout shift, RTL

Legacy Phase 23. Future, not activated.

**Goal**: A person can see and check interaction states, forms, loading shifts and right-to-left handling for any scenario.
**Mode:** mvp
**Depends on**: Checks and visual regression / local slot 1, Checks and visual regression / local slot 2
**Requirements**: UX-01, UX-02, UX-03, UX-04
**Spike first**: forcing `:hover` and `:focus-visible` without a mouse (CDP versus stylesheet rewriting on Tailwind v4 output) and measuring layout shift.
**Success Criteria** (what must be TRUE):
  1. Any scenario can be viewed in forced hover, focus-visible, active and disabled states without a mouse, and a check confirms each state differs from rest and that `phx-click-loading` is styled.
  2. Form checks report missing label association, missing `aria-invalid` or `aria-describedby`, errors shown before a field is touched (`used_input?`), missing autocomplete or inputmode, and placeholder-only labels.
  3. A scripted load reports layout shift, and a check reports skeletons whose size does not match the final content.
  4. A lint flags physical properties where logical ones belong (`ml-` instead of `ms-`), English-formatted numbers and dates under non-English locales, and `<time>` without `datetime`.
**Plans**: 4 (estimate)

### Checks and visual regression / local slot 5: UX checks II, journeys and design.json

Legacy Phase 24. Future, not activated.

**Goal**: Destructive and feedback patterns are checked, Journeys are checked and shown as a filmstrip, and impeccable gets a design file made from rendered primitives.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 2, Checks and visual regression / local slot 2, Checks and visual regression / local slot 4
**Requirements**: UX-05, UX-08, JOURNEY-02, CANON-06
**Partial delivery**: JOURNEY-03 (the workbench filmstrip of a Journey's steps; the `journey` focus completes it in LLM context bundles / local slot 3).
**Provisional on:** Q27
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. A destructive dialog whose cancel is visually weaker than its confirm is flagged, and a glossary-based confirmshaming lint reports at the severity the owner chooses.
  2. Toasts must use a live region with the right politeness, never steal focus, last at least 5 s or be pausable, and be dismissable; modals trap focus and return it; focus survives a LiveView patch; every error state offers an action.
  3. A Journey step whose action is not an interactive element with that accessible name is a dead end, a mismatched label is copy drift, and across steps the Shell navigation must be identical and the same terms used for the same things.
  4. The workbench shows a Journey as a filmstrip of its steps.
  5. `.impeccable/design.json` is generated from tokens plus rendered primitives with an ownership header and a pinned schema, and Fablebook refuses to overwrite a file it does not own.
**Plans**: 5 (estimate)

### Motion / local slot 1: Motion spike, time shim and Motion panel

Legacy Phase 25. Future, not activated.

**Goal**: A person can pause, scrub and slow every canvas animation and see a filmstrip, without the canvas disconnecting.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 2, Workbench UX / local slot 2
**Requirements**: MOTION-01
**Provisional on:** Q18
**Spike first**: the virtual clock against real LiveView `JS` transitions.
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The spike shows that the canvas heartbeat survives 60 s at 0.1x, that pause then resume completes a `JS.show` with `time:` exactly once, and that a `blocking: true` transition does not wedge patches.
  2. The Motion panel pauses and scrubs every canvas animation on a timeline and plays at 0.1x, 0.25x or 0.5x, labelled "Time shim active".
  3. A filmstrip shows the rendition at 0, 50, 100, 150, 200 and 300 ms plus the settled state.
**Plans**: 4 (estimate)

### Motion / local slot 2: Motion tokens, checks and CI lane

Legacy Phase 26. Future, not activated.

**Goal**: Motion is governed by canon tokens and strict checks, and seeked filmstrips are baselined in CI.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 1, Checks and visual regression / local slot 2, Motion / local slot 1
**Requirements**: MOTION-02, MOTION-03, MOTION-04, MOTION-05, MOTION-06
**Provisional on:** Q9, Q17
**Success Criteria** (what must be TRUE):
  1. The canon has motion tokens whose strong default easing curves override Tailwind's weak default, and a computed duration or easing off the tokens is a finding.
  2. Strict motion checks flag `transition: all`, animated layout properties, ease-in on enter, `scale(0)`, UI motion over 300 ms unless tagged marketing, hover motion outside `(hover:hover)`, and anything that moves under reduced motion.
  3. LiveView motion lints flag a `JS` `time:` that differs from the CSS duration, `blocking: true` on a decorative transition, `JS.show` without `display:` on flex or grid, and `stream_delete` without an exit animation; a scenario's `motion_tier:` is linted against the frequency gate.
  4. A CI motion lane baselines and diffs seeked filmstrips while ordinary visual diffs keep animations off, and the reduced-motion custom variant is installable and checked by the doctor core.
**Plans**: 4 (estimate)

### LLM context bundles / local slot 1: Bundle browser tier and allocator

Legacy Phase 27. Future, not activated.

**Goal**: A person can opt in to browser capture and get a bundle that fits an LLM's budget, with every gap labelled.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 6, Checks and visual regression / local slot 1, Checks and visual regression / local slot 2
**Requirements**: LLM-02, LLM-03, LLM-04
**Success Criteria** (what must be TRUE):
  1. `--browser` adds PNG shots, `aria.yaml`, styles, measurements and a11y to each scenario's folder through the shared Capture pipeline; without Playwright it prints one canonical "needs Playwright (opt-in)" message and records not-run, and the no-browser level stays pure Elixir.
  2. The allocator offers summary, standard and full detail, tiles tall views by viewport height, switches to grid contact sheets past 20 images, and reports what it dropped.
  3. Stale or missing Evidence is labelled in the bundle and never shown as current, and the committed schema and size budgets still pass with the goldens re-recorded in a reviewed diff.
**Plans**: 4 (estimate)

### LLM context bundles / local slot 2: Focus framework, review focuses and gen.screens

Legacy Phase 28. Future, not activated.

**Goal**: A person can ask an LLM for one kind of feedback, and a greenfield project can scaffold its screens.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 2, LLM context bundles / local slot 1
**Requirements**: CORE-13
**Partial delivery**: LLM-08 (framework and the explore, critique, copy, a11y, layout, consistency and brand focuses; completes in LLM context bundles / local slot 3), SKILL-02 (digests for these focuses; completes in LLM context bundles / local slot 3).
**Success Criteria** (what must be TRUE):
  1. `--focus` accepts exactly one value from the closed list and rejects anything else, and a bundle's `BUNDLE.md` carries the rubric digest and reading order for explore, critique, copy, a11y, layout, consistency and brand.
  2. Draft stories and scenarios turn strict-rule errors into warnings and stay in To review, and `--focus explore` produces a bundle for them.
  3. `mix fablebook.gen.screens` scaffolds a Shell and one Draft Screen story per canon job in a greenfield project.
**Plans**: 4 (estimate)

### LLM context bundles / local slot 3: Compare, journey and motion focuses

Legacy Phase 29. Future, not activated.

**Goal**: The remaining three focuses work, every focus carries a credited digest, and the four agent skills exist.
**Mode:** mvp
**Depends on**: Checks and visual regression / local slot 3, Checks and visual regression / local slot 5, Motion / local slot 2, LLM context bundles / local slot 2
**Requirements**: LLM-08, WB-13, JOURNEY-03, MOTION-07, SKILL-02
**Partial delivery**: SKILL-01 (the four skills are authored here; installing them completes it in Installer and DX / local slot 1).
**Provisional on:** Q25
**Success Criteria** (what must be TRUE):
  1. Compare shows renditions that differ in exactly one respect (a Global, a Theme or Direction, or the current rendition against its committed Baseline) at any tier, and `--focus compare` sends them to an LLM.
  2. `--focus journey` sends a whole Journey, with its steps, actions and screens in order.
  3. `--focus motion` provides `motion.json` (keyframes, timing, easing, 16 ms samples), a filmstrip contact sheet and reduced-motion frames, never video, and says that judging feel needs a person watching at 0.25x.
  4. Every focus in the closed list carries a short credited digest, rules live in checks with stable ids, and upstream skills (impeccable, ux-writing, review-animations, emil-design-eng) are named when installed and suggested as optional otherwise, never installed silently; the `fablebook`, `fablebook-review`, `fablebook-motion` and `fablebook-canon` skills are authored.
**Plans**: 4 (estimate)

### Installer and DX / local slot 1: Generators, doctor shell and migrator

Legacy Phase 30. Future, not activated.

**Goal**: A person can generate a story, diagnose their setup, move off phoenix_storybook, and install the agent skills.
**Mode:** mvp
**Depends on**: Canvas fidelity and installer core / local slot 4, LLM context bundles / local slot 3
**Requirements**: INST-02, INST-03, INST-04, SKILL-01
**Provisional on:** Q28
**Success Criteria** (what must be TRUE):
  1. `mix fablebook.gen.story Module.fun` writes a story from the component's Contract with its generated scenarios marked Draft and a TODO situation.
  2. `mix fablebook.doctor [--ci]` reports mount, `elixirc_paths`, scheme strategy, reduced-motion variant and CSP or `frame-ancestors` problems from a pure core, and exits non-zero under `--ci` when any is found.
  3. `mix fablebook.migrate.phoenix_storybook` converts a phoenix_storybook catalog (its Variation becomes a Scenario, its VariationGroup becomes a Group), and running it again changes nothing.
  4. The four skills install through `usage_rules` sync or `mix fablebook.skills.install`, version-stamped, and never overwrite a user's edits.
**Plans**: 4 (estimate)

### Installer and DX / local slot 2: Image export, Docker demo and string check

Legacy Phase 31. Future, not activated.

**Goal**: A person can export a framed image of any scenario, try the demo in one command, and catch untranslated strings.
**Mode:** mvp
**Depends on**: Design canon and adopter Books / local slot 5, Checks and visual regression / local slot 2
**Requirements**: WB-16, INST-06, UX-07
**Success Criteria** (what must be TRUE):
  1. Export image and `mix fablebook.shot <scenario> --frame phone --scheme dark` produce a framed, high-resolution PNG, optionally on a background, and without Playwright print the canonical opt-in message.
  2. `docker compose up` runs the operator host demo with no database and pinned image digests, with Playwright baked in.
  3. For a Book that declares Gettext, the optional Credo check flags user-visible literal text in `~H` not wrapped in `gettext`, waivable with a reason such as a brand name.
**Plans**: 4 (estimate)

### Installer and DX / local slot 3: Guides, docs brand and compatibility

Legacy Phase 32. Future, not activated.

**Goal**: An adopter can learn, upgrade and troubleshoot from the docs alone, and the docs carry Fablebook's brand.
**Mode:** mvp
**Depends on**: Installer and DX / local slot 1, Installer and DX / local slot 2
**Requirements**: DOCS-01, DOCS-02, DOCS-03
**Partial delivery**: INST-07 (the convention and helper are documented here; dogfooding in sigra completes it in Dogfood setup / local slot 1), DOCS-04 (applied to the docs site, README, Hex page and social card).
**Success Criteria** (what must be TRUE):
  1. The 12 ADR 0019 guides, the cheatsheets and `llms.txt` exist, and a test confirms each troubleshooting heading is a canonical error string.
  2. Comparison and migration content for phoenix_storybook and Storybook, security-model and limits sections, and an interaction-testing recipe are published.
  3. `UPGRADING.md` exists for the minor release, with a compatibility matrix and a deprecation policy.
  4. The docs site, README, Hex page and social card carry Fablebook's brand book from Design canon and adopter Books / local slot 4, while the workbench chrome stays ink-on-neutral.
  5. A documented convention and a small helper let a library that generates UI into a host also generate host-owned Fablebook stories for it.
**Plans**: 5 (estimate)

### Hardening and remaining twins / local slot 1: Hardening

Legacy Phase 33. Future, not activated.

**Goal**: The remaining deterministic gates, mutation floors and regression tests are in place, so quality cannot erode silently.
**Mode:** mvp
**Depends on**: Installer and DX / local slot 3
**Requirements**: PERF-05, PERF-06, QA-02, QA-03, QA-05
**Provisional on:** Q15, Q19
**Success Criteria** (what must be TRUE):
  1. Host compile overhead stays at or under 15% with 500 stories in the nightly and release lane, touching one component recompiles at most one story, and adding a function to `CoreComponents` reports how many stories it recompiles.
  2. A sibling `bench/` project tracks p50, p99, p99.9 and max against committed reference measurements with sensitivity controls, and is advisory only.
  3. Muex runs weekly on the critical modules, score floors only go up, and a drop below a floor blocks the release PR.
  4. Igniter.Test goldens and idempotency tests, a clean-room tarball consumer, a tarball allowlist test and an API-surface snapshot (at most 25 public modules, Mix tasks included) pass.
  5. One regression test per phoenix_storybook footgun in CLEARANCE C2 exists under `test/regressions/`, and the security job runs `mix hex.audit`, OSV-Scanner and sobelow on the host apps.
**Plans**: 4 (estimate)

### Hardening and remaining twins / local slot 2: Finanza and Shopadelic twins

Legacy Phase 34. Future, not activated.

**Goal**: The last two showcase products complete the set, and the white-label Theme and Guardrail path is exercised.
**Mode:** mvp
**Depends on**: Checks and visual regression / local slot 3
**Requirements**: QA-06
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Finanza (es, bold numerics) and Shopadelic (fr, a Shopadelic-branded admin plus a white-label merchant storefront) each have an external brand-book source-built brand book, a full canon, a Shell, Areas and Screens and a visually distinct style in `hosts/operator`.
  2. Merchant Themes in the storefront render, and an unreadable merchant colour surfaces as a Guardrail finding.
  3. All seven Books (three Logistify, Chatly, Finanza, Shopadelic, Clinicly) pass the canon lints and the sweep, and none of them is in the Hex tarball.
**Plans**: 4 (estimate)

### Dogfood setup / local slot 1: Dogfood setup

Legacy Phase 35. Future, not activated.

**Goal**: The owner's repos run Fablebook in CI so the 14-day clearance soak can start.
**Mode:** mvp
**Depends on**: Installer and DX / local slot 1, Hardening and remaining twins / local slot 2
**Requirements**: INST-07
**Provisional on:** Q2, Q22
**Success Criteria** (what must be TRUE):
  1. The mailglass demo and accrue_admin run on LiveView 1.2, with merged PRs that migrate every story they keep (via the migrator plus hand fixes) and a prune log (C1 evidence).
  2. sigra generates host-owned Fablebook stories through the convention helper, shown by a merged sigra PR.
  3. Both migrated repos run Fablebook in CI and are green, and one Fablebook PR merged green links the per-repo PRs as the phase evidence.
  4. A soak checklist records where each of C1 to C10 will be proven, ready for the milestone audit.
**Plans**: 4 (estimate)
