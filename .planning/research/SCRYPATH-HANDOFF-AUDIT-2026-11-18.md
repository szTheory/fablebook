# Scrypath handoff audit: lessons for the workbench builder

**Checked:** 2026-11-18. **Scope:** Fablebook's design and milestone practice, not Scrypath's milestone plan. The two Scrypath inputs were untracked at sibling HEAD `c7b38394`; they are leads, not evidence. Accepted ADRs are unchanged. Here, “confirmed” means confirmed in Fablebook's records or code; it does not mean a planned feature has shipped.

## Confirmed for Fablebook

### C1. ADR 0011 is the browser-runner decision

It selects `phoenix_test_playwright` provisionally and specifies a runner spike; it is not an accessibility or general visual-evidence ADR. It already calls for a pinned browser image, three byte-identical screenshot captures, and guards for missing CI baselines, dirty screenshot output, and baseline/manifest parity. The prior description was wrong.

**Provenance:** `docs/adr/0011-browser-runner.md`, Fablebook commit `9cd3531730ab627c78a30b847f4123eab43a7c30`; Scrypath handoff, proposal section “What fablebook taught us”. **Date:** 2026-11-18. **Grade:** R. **Check:** confirmed by reading the ADR; no runner spike was run in this audit.

### C2. Several incumbent footguns are already design constraints, not implementation guarantees

Fablebook specifies a host-pipeline iframe and inherits the host's CSS, hooks and LiveSocket (ADR 0003); slots use captured functions rather than HEEx strings (ADR 0002); input is not evaluated (ADR 0004); and `ComponentInfo` is the sole adapter around private `__components__/0` metadata (ADR 0008 and `PITFALLS.md`, Pitfall 17). `PITFALLS.md` already records many reported hazards, including CSP, render isolation, browser determinism, and compile coupling. The package is still a design-stage replacement: the current library entry reserves a router placeholder. These decisions do not establish runtime fidelity yet. A separate LiveSocket is not Fablebook's intended fix for hook issues.

**Provenance:** `docs/adr/0002-scenarios-are-plain-functions.md`, `0003-iframe-canvas-through-host-pipeline.md`, `0004-no-eval-no-new-atoms.md`, `0008-catalog-discovery-and-ids.md`, `.planning/research/PITFALLS.md`, and `lib/fablebook.ex`; design records at `9cd3531730ab627c78a30b847f4123eab43a7c30`, router placeholder at `cee11138332f4c4069195ccf1b3d10cef9aac1cc`. **Date:** 2026-11-18. **Grade:** R. **Check:** confirmed as documented design and current code boundary, not as delivered behavior; Fablebook has no shipped catalog or re-skin and therefore supplies no evidence for their ordering or workload.

### C3. The brand source is documented and pinned, but not mechanically verified

The intake records upstream commit `b2e3441218f9d62f857ab9ff7b4b62fdc320078c` and per-file hashes; assets remain staged and unapplied. I found no tracked pin verifier or update script. This is a documentation-level pin, not a closed, mechanically checked asset bundle. Since Fablebook is not shipping those assets, this is a recorded limitation rather than an immediate implementation request.

**Provenance:** `.planning/references/fablebook-brand-intake.md`, Fablebook commit `3817912c861286608183c057d2e38ff7a260bd6e`; tracked-file search in this checkout. **Date:** 2026-11-18. **Grade:** R. **Check:** pin and staging status confirmed; absence of a verifier confirmed by tracked-file search.

### C4. “Missing macro” and “macro raises during expansion” are distinct failures

ADR 0006's `only: :dev` wording calls the result an “undefined macro”; that blurs the absent dependency/module import problem with a macro that is available and raises while expanding. Fablebook's Elixir 1.19.5 experiment E1 confirms a macro-body raise is expanded inside a false `if`, while a raise in the returned quote is not. Current `Fablebook.Router` follows the latter shape and its host fixture checks it. Scrypath C28's more specific claim about missing `import`/`use`/`require` behind `Code.ensure_loaded?` was not reproduced here. Do not change ADR 0006 from that report alone; clarify the wording if the behavior is later tested.

**Provenance:** `docs/adr/0006-dependency-available-in-all-envs.md`, `.planning/research/PITFALLS.md` E1, `lib/fablebook/router.ex`, `test/contract/prod_guard_test.exs`, ADR 0014 and 0021; ADR/research at `9cd3531730ab627c78a30b847f4123eab43a7c30`, guard/test added at `1b93bc6c7c5506f9cbf4024fab7a48d28c1bf9b6`; Scrypath C28 is an untracked sibling claim. The guard test was added as a new file (`A`), which ADR 0021 explicitly permits; this was not a same-PR edit of an existing contract test. **Date:** 2026-11-18. **Grade:** V for the recorded E1 experiment, R for current code, U for C28's exact module-availability case. **Check:** timing distinction confirmed; C28 remains unverified locally; no ADR amendment made.

## Hypotheses to test

### H1. Make each scenario's proof boundary explicit

Fablebook already plans stable story/scenario IDs, tiers, state classes, computed coverage, reasoned waivers, and generated per-scenario tests. It has no declared per-scenario `proof_boundary` field. Test a small model that distinguishes render-only, LiveViewTest, browser, and connected-only evidence; marks impossible states with reasons and excludes them from rendering; identifies static stories visibly and in machine-readable output; and rejects unmapped scenarios. Journey tests should chain steps so each rendered result contains the next control, not merely prove that controls exist. Keep fixture construction app-owned: a catalog can require fixture provenance or a shared fixture source, but cannot infer an adopter's reachable business states. Add a mutation control showing the story and generated test consume the same fixture source. Check declared route/navigation/story mappings in both directions, but do not presume a one-to-one relationship.

One ordinary end-to-end journey is a useful pilot for the scenario and fixture model before scaling. It proves that path's declared steps only; it is not evidence that every user understands the interface.

**Provenance:** Fablebook ADRs 0002, 0008, 0014, 0023 and 0024; Scrypath playbook C29 and proposal “What ‘verified’ means” / phases 192–194. **Date:** 2026-11-18. **Grade:** R for current Fablebook model, U for the proposed additions. **Check:** existing pieces confirmed; additions and chained journey proof not implemented or tested.

### H2. Put fidelity and evidence limits in the workbench's own contracts

The design already chooses iframe CSS isolation, host-loaded hooks and LiveSocket, and data/function slots instead of string round-trips. The implementation still needs host tests for theme application (including dark mode), CSP, route-scope mounting, viewport control, recompilation cost, and supported LiveView versions. The reported global event telemetry attachment and other `phoenix_storybook` internals are not Fablebook reproductions; require a focused spike before turning them into requirements. Likewise, a green catalog can establish declared coverage and measured constraints, but not that a UI feels right. Consider showing the evidence boundary in workbench results and generated reports.

**Provenance:** Fablebook ADR 0003 and `.planning/research/PITFALLS.md` (Pitfalls 6, 7, 17); Scrypath playbook C29 and proposal section “What ‘verified’ means”. **Date:** 2026-11-18. **Grade:** R for Fablebook design, U for the untested requirements. **Check:** no Fablebook host fidelity spike or user-facing proof-boundary UI exists yet.

### H3. Calibrate evidence gates before making them merge blockers

For future browser and asset gates, run a named reject and accept case through the same code path; reject stale or dirty captures; require the baseline set to match its manifest; pin browser and driver; report runner-discovered test identities; and keep CI caps in one source. ADR 0011 already specifies some baseline guards, but not all these controls. Its byte-identical capture criterion needs a pinned-environment repeatability spike that includes actual runner CPU classes; the sibling report of one 55-pixel difference across CPU models is a reason to measure, not sufficient evidence to relax the gate. If a nested consumer server arrives, give it isolated build and asset caches and test that separation. Reuse ADR 0021's two-review-pass cap rather than creating a second review-loop rule.

**Provenance:** Fablebook ADRs 0011, 0014, 0015 and 0021; Scrypath playbook T13, T16–T18 and proposal “What ‘verified’ means”. **Date:** 2026-11-18. **Grade:** R for existing ADRs, U for sibling-specific drift and proposed additions. **Check:** current design guards confirmed; no gate calibration or cross-CPU experiment run here.

### H4. Keep vocabulary and UI-copy inventory separate

`GLOSSARY.md` is Fablebook's source for domain terms, not a catalog of every rendered message. If the product later owns UI copy, test a curated message source plus rendered-text checks; a clean source inventory alone cannot prove coverage. A syntax-aware scan may avoid regex misses, but ADR 0004 bans `Code.string_to_quoted*` outside an allowlist, so an AST scanner cannot be added casually. Do not build it before Fablebook has real interface strings to inventory.

**Provenance:** `GLOSSARY.md`, `.planning/PROJECT.md` CANON requirements, `docs/adr/0004-no-eval-no-new-atoms.md`; Scrypath playbook W-rules and proposal section “Language findings”. **Date:** 2026-11-18. **Grade:** R for current vocabulary design, U for future copy-lint approach. **Check:** glossary role confirmed; no UI-copy inventory exists to validate.

## Rejected or scoped out

### R1. Do not require every phase to change a rendered screen

Reject a universal “visible UI every phase” rule or an automatic stop after two evidence-only plans. It would conflict with valid bounded research, security, packaging, and source-provenance work. Fablebook already rejects ceremony-only phases and caps phase size; use a visible user-facing checkpoint in product milestones and an explicit exit for evidence work instead of forcing UI into every phase.

**Provenance:** Fablebook ADR 0021 and current `.planning/STATE.md` recovery scope at checkout HEAD `7317bd0ea112dbe9c2a60e15322ec6bfccc4681d`; Scrypath S22 and proposal guardrails. **Date:** 2026-11-18. **Grade:** R for Fablebook rules, U for the generalized guard's effect. **Check:** blanket rule rejected; a product-milestone progress check remains a possible future process improvement.

### R2. Do not set a byte-size limit for planning files

Before adding this audit's index link, `PROJECT.md` was 59,317 bytes and `STATE.md` 18,397 bytes at this checkout. I found no Fablebook evidence that those sizes caused agent stalls; sibling size/stall anecdotes do not establish a threshold. Keep `STATE.md` a useful handoff pointer and move detailed receipts to their owners; compact when measured context loss or a repeated stall justifies it.

**Provenance:** `.planning/PROJECT.md`, `.planning/STATE.md`, checkout HEAD `7317bd0ea112dbe9c2a60e15322ec6bfccc4681d`; Scrypath proposal’s planning-state section. **Date:** 2026-11-18. **Grade:** R for byte counts and local records, U for cross-project causal claims. **Check:** sizes confirmed; no causal size threshold supported.

### R3. Do not treat sibling catalog size or waiver rate as a target

The reported roughly 9,000 hand-written catalog lines and 65% waiver rate are not Fablebook requirements or measured outcomes here. Fablebook's existing contract is strict-by-default with scoped, reasoned waivers; keep that rule and measure actual coverage and maintenance cost before changing it.

**Provenance:** Fablebook ADR 0024; Scrypath playbook C29 and its accrue/exifcleaner sources, supplied only through the untracked Scrypath handoff at `c7b38394`. **Date:** 2026-11-18. **Grade:** R for Fablebook's waiver rule, U for sibling totals. **Check:** no independent verification of those totals; rejected as design targets.

### R4. Do not import Scrypath's component-extraction choice as Fablebook guidance

The proposal's `__render_component__` discussion concerns how Scrypath should expose its own screens as stories. It does not establish an API Fablebook should call. Historical OTP inventory files mention `Phoenix.LiveViewTest.__render_component__/4` as a LiveViewTest export, but no Fablebook `.ex` or `.exs` implementation calls it. The transferable point is to isolate any framework-private renderer metadata behind one adapter and a compatibility contract, already captured by ADR 0008 and Pitfall 17.

**Provenance:** Fablebook ADR 0008 and `.planning/research/PITFALLS.md` Pitfall 17 at `9cd3531730ab627c78a30b847f4123eab43a7c30`; `.planning/milestones/v0.1-phases/01.1.1.2-installed-otp-inventory-and-common-test-guard-slice/01.1.1.2-INVENTORY-core.jsonl` at `42eed41986476e40c2d291685df7f1b245b61ca0`; Scrypath proposal “What fablebook taught us”, untracked at sibling HEAD `c7b38394`; search of tracked `.ex`/`.exs` files. **Date:** 2026-11-18. **Grade:** R for Fablebook's design/search, U for Scrypath's implementation advice. **Check:** inventory mention confirmed, no implementation call found; treated as adopter-specific, not copied.

### R5. Do not add a second rule for generated planning projections

The proposal reports a hand-edited generated document that drifted, but I found no supporting Fablebook history in the current checkout. The durable Fablebook instruction already names `STATE.md` and `ROADMAP.md` as canonical and `.planning/state.json` as a generated projection that must not be hand-edited. That is sufficient; the sibling incident does not justify another rule.

**Provenance:** Fablebook `AGENTS.md` and `.planning/references/PLANNING-LIFECYCLE.md` at `d4b6694bba718ed49b47de74ffdeff911fc0f385`; Scrypath proposal “What fablebook taught us”, untracked at sibling HEAD `c7b38394`; local history search. **Date:** 2026-11-18. **Grade:** R for current instructions, U for the reported incident. **Check:** existing rule confirmed; incident not confirmed here, no duplicate instruction added.
