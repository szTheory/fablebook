# Roadmap: Fablebook

> **Precedence:** verbatim intent (`.planning/intent/sources/`) > ADR (`docs/adr/`) > REQUIREMENTS > PROJECT. `GLOSSARY.md` is the only vocabulary. The phase shape follows INT-20261028-16 (the split rule wins) and ADR 0021.

## Overview

Fablebook goes from an empty repo to a 1.0 that clears `.planning/intent/CLEARANCE.md`. The path runs through 12 families, kept as headings in the seed's order, split into 35 sequential phases of 3 to 5 plans each. It starts with a published 0.1.0 and a guarded CI, then one story rendering end to end in two host apps. The story model and catalog follow, then controls and URL state, then the canvas with its fidelity receipt, and an installer that reproduces the hand-wired tree. The workbench UX comes next, then the design canon with its twins, then the probe, checks and visual regression, then the motion lane. LLM context bundles grow from a thin early slice into every focus. Generators, docs, hardening, the last two twins and dogfood setup close the build. The clearance soak (C1 to C10, including the 14-day criteria) is checked by the milestone audit before 1.0 is tagged; it is not a phase.

## Conventions

- **Phase exit rule (every phase, ADR 0021):** the phase ends in a merged, green PR to main. The evidence is a link to the CI run, not prose. A phase that cannot meet its gates splits; it is never compressed and no gate is lowered. A contract test is never edited in the same PR as the implementation it guards.
- **Spikes sit first inside the phase that needs them** (Phases 2, 7, 8, 23, 25). If a spike fails, the phase splits. There are no proof-only phases.
- **Mapping rule:** each v1 requirement is mapped to exactly one phase, the one that delivers its last new mechanism. Earlier phases that deliver part of it say so under **Partial delivery**. A later phase that only feeds new data into an existing mechanism (for example, canon entries appearing in the palette) is named in that phase's criteria and does not change the mapping.
- **Provisional on:** the phase can be planned on the research's recommended answer, but the owner has not answered the listed open questions (`.planning/intent/OPEN-QUESTIONS.md`, Q7 to Q30). No requirement wording assumes an answer. Q6 is resolved by INT-20261028-16. Q15 (what counts as a contract test) touches every phase that records goldens, snapshots or baselines; until it is answered, plan any contract-test edit as its own PR touching no `lib/`.
- **Pending requirements (not v1, not mapped):** CTRL-05 (Phase 8, Q10), CORE-15 (Phase 4, Q14) and CORE-16 (Phase 9, Q14) are noted under the phases they would land in. They are mapped only if the owner adds them.
- **Pulled-forward phases:** three phases execute earlier than their home family (Phases 6, 10 and 19). They sit under the heading of the family whose band they execute in, and each says which family it came from.

### Deviations from the research re-cut (`.planning/research/SUMMARY.md`)

| Deviation | Reason |
|---|---|
| The whole of SEC-04 (redaction plus the `redact:` hook) is in Phase 6, not Phase 19. | A bundle leaves the machine the first time anyone runs the thin slice. Redaction must precede that, and the hook lives in the same module. SEC-04 then completes in Phase 6. |
| SBOM generation is in Phase 1 (release pipeline), not Phase 33. | REL-01 is one requirement and the release workflow attaches the SBOM. Mapping it to Phase 1 avoids a requirement that stays open until Phase 33. |
| `mix fablebook.gen.screens` moves from Phase 29 to Phase 28. | It pairs with the `explore` focus (the greenfield loop), completes CORE-13, and balances Phases 28 and 29. |
| INST-05 (day-0 "aha") is mapped to Phase 11. | The re-cut placed it nowhere. The aha needs the sidebar and grid, so it first works end to end in Phase 11. |
| WB-13, JOURNEY-03, LLM-02, LLM-04, WB-05 and WB-17 map to the phase that adds their last mechanism (Phases 29, 29, 27, 27, 20, 20). | WB-13 and JOURNEY-03 each own a bundle focus built in Phase 29. LLM-02 and LLM-04 need `--browser` capture. WB-05 and WB-17 need the Checks tab and the run action. |
| Plan estimates: Phases 11 and 20 are 5, Phase 17 is 4 and Phase 18 is 3. | The re-cut gave ranges or 4 for phases carrying more mapped requirements. |

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): planned milestone work
- Decimal phases (2.1, 2.2): urgent insertions (marked INSERTED)

**Family 1: Walking skeleton**
- [ ] **Phase 1: Release pipeline, CI gate and guards** - 0.1.0 published, three workflows with caps, intent test, prod guard, eval and atom bans
- [ ] **Phase 01.1: Close phase 1 guard gaps** (INSERTED) - atom and code-loading ban bypasses closed, hex-publish hardened, SEC-02 recorded
- [x] **Phase 01.1.1: Close the eval and code-loading ban list** (INSERTED) - sweep-derived eval, compile-and-load and native-load tier over the whole dev code path, deps included, plus the call-name over-catch fix (CR-02, re-homed from 01.1 per INT-20261029-03; the `__info__` arity skip, quoted and module-body pair-tier calls, and the Credo wording (CR-04, VR-01, WR-11, truth 6, re-homed per INT-20261029-04)) (completed 2026-10-29)
- [x] **Phase 01.1.1.1: Exact-source evidence and named atom-creator guards** (INSERTED) - preserve merged source/PathConsult tracer; finish consult/Yecc and Logger/ExUnit fronts (completed 2026-10-30)
- [x] **Phase 01.1.1.2: Installed OTP inventory and Common Test guard slice** (INSERTED) - independent exact-lane installation discovery and real Common Test guard (completed 2026-10-30)
- [ ] **Phase 01.1.1.3: Debugger selected-file interpreter and seed provenance** (INSERTED) - unplanned scope reservation; split into bounded source-family phases before execution
- [ ] **Phase 01.1.1.4: Carried exclusion truth in calibrated source families** (INSERTED) - unplanned scope reservation; preserve every original identity and matched function across bounded audit phases
- [ ] **Phase 01.1.1.5: Complete audit enforcement and truthful guard explanation** (INSERTED) - unconditional full coverage/removal gates and approved changed wording; closes original three transfers
- [ ] **Phase 2: Walking skeleton and runner spike** - one story rendering in two host apps, one guarded visual check, runner criteria answered

**Family 2: Story model and catalog**
- [ ] **Phase 3: Story model and catalog** - compiled stories, pure catalog, Unstoried, ComponentInfo, errors and telemetry
- [ ] **Phase 4: Render seam, rules engine and generated tests** - render seam with hash, Waivers and Draft, manifest drift, generated tests

**Family 3: Controls and URL state**
- [ ] **Phase 5: Controls and URL state** - typed controls, presets, URL codec, never-eval and never-atom proofs
- [ ] **Phase 6: Thin bundle slice** - one redacted no-browser bundle for a scenario (pulled forward from Family 9)

**Family 4: Canvas fidelity**
- [ ] **Phase 7: Canvas isolation and containment** - iframe through the host pipeline, grid decision, crash containment, static canvas
- [ ] **Phase 8: Canvas diagnostics, hot reload and Globals** - connection diagnostic, recompile updates, Globals applied
- [ ] **Phase 9: Operator host, fidelity receipt and real components** - complete `hosts/operator`, fidelity E2E, a 0.x release in a dogfood repo
- [ ] **Phase 10: Installer core** - `mix igniter.install fablebook` reproduces the hand-wired tree (pulled forward from Family 10)

**Family 5: Workbench UX**
- [ ] **Phase 11: Chrome shell, sidebar, story page and grid** - three panes, tier-first sidebar, story page as docs, performance gates, day-0 aha
- [ ] **Phase 12: Inspector, toolbar, palette and keyboard** - Attrs/HEEx/Events, toolbar tools, command palette, keyboard map, settings
- [ ] **Phase 13: Mobile layout, QR, microcopy, Compare by Globals and Diagnostics** - phone layout, canonical microcopy, chrome WCAG 2.2 AA

**Family 6: Design canon**
- [ ] **Phase 14: Canon core** - frontmatter parser, canon kinds, DTCG tokens, canon layers, page embeds
- [ ] **Phase 15: Foundations, Themes, Directions, citations, coverage and To review** - Foundations pages, citation enforcement, coverage matrix, journeys declared
- [ ] **Phase 16: Canon lints, tokens task and DESIGN.md** - abracabrand interop, pure-Elixir lints, copy benchmarks, `mix fablebook.tokens`
- [ ] **Phase 17: Content track I - Fablebook brand book and the Logistify family** - brand book, three Logistify Books
- [ ] **Phase 18: Content track II - Chatly and Clinicly** - two more twins with full canon
- [ ] **Phase 19: Bundle core with canon** - all selectors, `context/`, schema, goldens, manifest at the mount, `llms.txt` (pulled forward from Family 9)

**Family 7: Probe, checks and visual regression**
- [ ] **Phase 20: Probe, Evidence and the Checks tab** - axe probe in the browser, simulations, Evidence keyed by render hash, honest status dots
- [ ] **Phase 21: Capture and visual baselines** - pinned-container visual diffs, baseline guards, nightly and release lanes
- [ ] **Phase 22: Sweep, Ratchet and verdicts** - manifest-driven sweep, ratchet, verdicts log, To review findings, revision Compare
- [ ] **Phase 23: UX checks I - interaction states, forms, layout shift, RTL** - forced states and four check families
- [ ] **Phase 24: UX checks II, journeys and design.json** - destructive and feedback checks, journey step checks, filmstrip, `.impeccable/design.json`

**Family 8: Motion lane**
- [ ] **Phase 25: Motion spike, time shim and Motion panel** - scrub, slow motion and filmstrip in the workbench
- [ ] **Phase 26: Motion tokens, checks and CI lane** - motion tokens, strict motion checks, LiveView lints, baselined filmstrips

**Family 9: LLM context bundles and skills**
- [ ] **Phase 27: Bundle browser tier and allocator** - `--browser` capture, token-budget allocator, contact sheets
- [ ] **Phase 28: Focus framework, review focuses and gen.screens** - closed focus list with digests, Draft, `gen.screens`
- [ ] **Phase 29: Compare, journey and motion focuses** - the remaining focuses, credited digests, skills authored

**Family 10: Installer and DX**
- [ ] **Phase 30: Generators, doctor shell and migrator** - `gen.story`, `doctor`, phoenix_storybook migrator, skills install
- [ ] **Phase 31: Image export, Docker demo and string check** - `mix fablebook.shot`, Export image, `docker compose up` demo, Gettext string check
- [ ] **Phase 32: Guides, docs brand and compatibility** - the 12 guides, comparison and migration content, upgrade policy

**Family 11: Hardening and the full twin set**
- [ ] **Phase 33: Hardening** - compile and bench gates, Muex floors, API-surface snapshot, one regression test per footgun
- [ ] **Phase 34: Finanza and Shopadelic twins** - the last two twins, white-label Themes and Guardrails

**Family 12: Dogfood setup**
- [ ] **Phase 35: Dogfood setup** - mailglass demo and accrue_admin migrated, sigra stories generated

## Phase Details

### Family 1: Walking skeleton
*Phases 1 to 2.*

### Phase 1: Release pipeline, CI gate and guards
**Goal**: A published 0.1.0 reserves the Hex name, and the guards every later phase relies on (CI caps, intent integrity, the prod guard, the eval and atom bans, the dependency budget) are enforced by CI from the first merge.
**Mode:** mvp
**Depends on**: Nothing (first phase)
**Requirements**: REL-01, CI-01, INTENT-01, SEC-02
**Partial delivery**: SEC-01 (Credo bans and the `style=` check land here; the properties and mutation-proven tests complete it in Phase 5).
**Provisional on:** Q7, Q12, Q15, Q19, Q21
**Success Criteria** (what must be TRUE):
  1. A maintainer can see 0.1.0 on hex.pm, published by release-please through the bootstrap skill only after the prod-guard cases passed and the unpacked tarball was inspected; a post-publish smoke test, a recovery workflow and an attached SBOM exist.
  2. A host that mounts Fablebook inside a false `dev_routes` block compiles cleanly in prod, while an unguarded mount fails with the canonical `CompileError` emitted from the macro's returned code; the CI prod build asserts no Fablebook routes and no story beams.
  3. A PR that adds a fourth workflow, grows `ci.yml` past 250 lines, removes the single `ci-gate`, edits an INT source, uses a malformed INT id, or adds a REQ line with no INT or ADR citation fails CI; PR p50 and p95 are published weekly from CI history.
  4. A PR that adds `Code.eval*`, runtime EEx/HEEx compilation, `String.to_atom` on input, a banned dependency in the prod closure, or a file outside the tarball allowlist fails CI.
**Gap closure:** moved to Phase 01.1 per INT-20261029-01 (criterion 4's atom-ban share and the review's WR items).
**Plans:** 5/5 plans executed

Plans:
- [x] 01-01-PLAN.md — Walking skeleton: owner sign-offs, fablebook/2 with the prod guard on both lanes, package docs
- [x] 01-02-PLAN.md — All of `.github/`, release config and scripts; public repo, settings, ruleset; draft PR #1 green
- [x] 01-03-PLAN.md — Compiled-BEAM and Credo bans, `style=` scan, dependency budget, tarball allowlist
- [x] 01-04-PLAN.md — Intent, contract-rule and CI-shape guards; diff seam proven in a real repo; test-wiring pins; PR #1 green with every guard
- [x] 01-05-PLAN.md — Signed ADR amendments, owner diff review and secrets, merge PR #1, D-22 red run, ci-health, publish 0.1.0, rotate key, PR #3 drops release-as with the last SUMMARY

### Phase 01.1: Close phase 1 guard gaps (INSERTED)
**Goal**: The atom and runtime-code bans that Phase 1's criterion 4 promises hold against every literal dispatch form, the release recovery path publishes only commits on main and converges, and Phase 1's open bookkeeping is closed, through merged green PRs that each keep the contract-test pairing (ADR 0021).
**Depends on**: Phase 1
**Requirements**: SEC-02, REL-01 (traceability stays on Phase 1; this phase closes their verification follow-ups)
**Partial delivery**: SEC-01 (Phase 1's criterion-4 atom-ban share, re-homed here per INT-20261029-01; Phase 5 completes it with the atom-count property and mutation-proven tests).
**Success Criteria** (what must be TRUE):
  1. A PR that adds `String.to_atom`, `List.to_atom` or their existing-atom forms on input, through a direct call, `apply/3`, `:erlang.apply/3`, `Function.capture/3` or a default-argument function name, fails CI on both lanes, in the compiled-BEAM guard and in Credo (CR-01).
  2. A PR that compiles, loads or evaluates code at runtime through one of the enumerated MFA-tier functions (`:erlang.load_module/2`, `:code.load_abs`, `:compile.*`, `Kernel.ParallelCompiler`, `:file.script`, the `:elixir_tokenizer` → `:elixir_parser` → `:elixir_module.compile/6` chain and the rest of the list), or creates atoms through one of the enumerated readers, scanners, parsers or formatters (`:io_lib.fread`, `:io.scan_erl_exprs`, `:epp`, `:xmerl_scan`, `Code.format_string!`, `:elixir.string_to_tokens` and the rest of the list), fails CI; every ban matcher is proven live on both lanes, and the `mix.exs` scan matches qualified calls (WR-03, WR-02).
  3. `hex-publish.yml` refuses a tag whose commit is not on main, a recovery run after a docs-only failure uploads the docs, and `HEX_API_KEY` reaches only the steps that use it (WR-05 workflow half, WR-06, IN-04).
  4. SEC-02 shows Complete with its CI run link, owner questions Q35 to Q37 are recorded, and the remaining info findings are tracked; the first PR touches no `lib/` or `.github/` file, the second no `test/contract/` or `test/planning/` file, and both are merged green.
**Gap closure (re-verification):** CR-04, VR-01 and truth 6 moved to Phase 01.1.1 per INT-20261029-04 (5-plan cap and ADR 0021 review cap reached).
**Plans:** 5/5 plans executed (3 gap-closure plans from 01.1-VERIFICATION)

Plans:
**Wave 1**
- [x] 01.1-01-PLAN.md — Atom-constructor, runtime compile/load/eval and atom-creating parser bans in both layers, mix.exs scan made non-vacuous (CR-01, WR-03, WR-02); contract-test-only PR

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 01.1-02-PLAN.md — hex-publish publishes only main commits, docs-only recovery converges, step-scoped HEX_API_KEY (WR-05, WR-06, IN-04); SEC-02 marked complete; owner questions Q35 to Q37

**Gap closure** *(sequential: one working tree, each PR carries the previous SUMMARY)*
- [x] 01.1-03-PLAN.md — BEAM guard matches literal module/function pairs and wholly banned module references, one fixture per dispatch form, truthful Credo explanation with the whole-module over-catch documented and tested (01.1-REVIEW CR-01), mix.exs scan over the MFA tier (WR-04); CR-02 (truth 7) deferred to Phase 01.1.1 per INT-20261029-03; contract-test-only PR
- [x] 01.1-04-PLAN.md — hex-publish builds, publishes and smoke-tests the tag's own commit, checksum-gated publish, fail-closed gates, check before tag code (CR-03, WR-01 gate, WR-05 follow-up); `.github/`-only PR
- [x] 01.1-05-PLAN.md — hex_publish_test.exs lands as the guard over 01.1-04 (checkout model, same-named branch, WR-01/02/03, IN-01/02, step-move ordering mutations); contract-test-only PR, then a planning-only PR carrying the SUMMARY and re-verification

### Phase 01.1.1: Close the eval and code-loading ban list (INSERTED)

**Goal**: No direct, public eval, compile-and-load, interpret, native-load or code-path-changing function, and no atom-creating parser, on the Mix dev code path passes the compiled-BEAM guard. That includes the project's runtime dependencies (Phoenix, LiveView, Plug), every exclusion has a reason that is true, and the whole-module literal check stops flagging ordinary functions named like a banned module, such as `Regex.compile/1`. This closes 01.1-VERIFICATION truth 7 (CR-02) and the over-catch fix, both re-homed here per INT-20261029-03, and the inbound threats T-01.1-28 (was T-01.1-03 in 01.1-SECURITY), T-01.1-22, T-01.1-23 and T-01.1-25. No literal dispatch hides in a user-defined `__info__` of another arity, and no pair-tier call passes when a `lib/` macro quotes it or module-body code makes it, so the bans hold against every literal dispatch form and the Credo explanation is literally true. This closes the re-verification's CR-04, VR-01 and truth 6, with WR-11 fixed rather than accepted, all re-homed here per INT-20261029-04, and reopens threats T-01.1-15 and T-01.1-27 until they land.
**Transfer** (INT-20261029-02, recorded at planning on 2026-10-29): Phase 01.1.1.1 owns and closes three things: the atom-creating-parser clause, the "every exclusion has a reason that is true" clause of SC1, and the eval front doors in installed OTP apps outside this phase's sweep scope. They stay open here, the plans record them as open, and none of them is a known limit.

**Transfer update** (2026-10-30; INT-20261029-02, INT-20261030-02; ADR 0021): the measured 01.1.1.1 audit exceeded its context budget. Its unchanged obligations now span 01.1.1.1–01.1.1.5 and bounded source-family children. Only 01.1.1.5 can close these three transfers after all required implementation and owner judgments; the narrowed named-creator phase alone cannot.
**Depends on**: Phase 01.1
**Requirements**: None completed here (SEC-01 advanced; Phase 5 completes it)
**Success Criteria** (what must be TRUE):
  1. A reachability sweep over every beam on the Mix dev code path on both lanes, deps included, leaves no reached function undisposed, and each exclusion's recorded reason survives a spot check against the source (01.1 checker iteration 2: `Mix.Tasks.Format` `:dot_formatter`, `Mix.Tasks.Help.run(["app:" <> name])`, `Phoenix.LiveView.Engine.compile/2`, `Mix.Tasks.Phx.Server.run(["-e", code])`).
  2. Every public front door the sweep finds is a tier entry with a negative fixture, every entry is proven live on both lanes, and the `:int` and code-path mutator decisions are recorded.
  3. Call-name positions no longer trigger the whole-module literal check: `Regex.compile/1`, `:re.compile/2` and a local `compile/1` give no hit on both lanes, while a literal module reference such as `apply(:compile, fun, args)` still does. Any banned call the narrowed check would stop catching first gets an explicit tier entry with a negative fixture, and the phase records which calls those were, or why there were none. The 01.1-03 known strictness rows and the Credo explanation are updated to match.
  4. Every API 01.1-VERIFICATION truth 7 reproduced is a tier entry with a negative fixture whether or not the sweep reaches it: `:qlc.string_to_handle`, `:merl.compile_and_load`, `:c.c`, `:make.files`, `:cover.compile_module`, `:erlang.load_nif`, `:erl_ddll.load`, `:epp_dodger.parse_file`, `:elixir_erl_compiler.noenv_forms`, `:elixir.tokens_to_quoted`, `IEx.Helpers.c` and `Mix.Tasks.Run.run`. The native loaders (`:erlang.load_nif/2` and the `:erl_ddll` load functions) and the atom-creating parsers (`:epp_dodger` and `:elixir.tokens_to_quoted/3`) are covered in full, not just the reproduced arities. The 01.1-03 known strictness rows for `:qlc.string_to_handle/1`, `:erlang.load_nif/2` and `:epp_dodger.parse_file/1` then report hits, and the Credo explanation's tier-gap sentence is removed.
  5. A function named `__info__` of any arity other than 1 is scanned: `apply(:erlang, :load_module, [m | args])`, `apply(Module, :concat, parts)` and `Function.capture(:file, :script, n).(p)` inside a user-defined `__info__/2` hit on both lanes, through a beam-only negative fixture (CR-04).
  6. A pair-tier call fails CI when a `lib/` macro quotes it (`quote(do: Module.concat(unquote(x)))`, quoted `:file.script/1`, quoted `apply(:erlang, :load_module, ...)`, a `__using__` that injects `:erlang.load_module/2`) and when module-body code makes it (`@r apply(:file, :script, [...])`, `@m Module.concat([...])`), on both lanes, each with a negative fixture (VR-01, WR-11). The `mix.exs` scan also matches the `apply/3`, alias and newline-after-dot spellings (WR-12).
  7. Every caught, over-caught and missed claim in the Credo explanation matches a fixture or a known-strictness row, "anywhere in function code" is true or gone, and a human wording check is recorded (truth 6).
  8. Each PR is contract-test-only (no `lib/`, `.github/` or `mix.exs`) and merged green with a CI run link.
**Plans:** 5/5 plans complete; phase verification passed (8/8 scoped truths)

Plans:
**Wave 1**
- [x] 01.1.1-01-PLAN.md — Walker fixes: scan user-defined `__info__` of other arities (SC5) and stop flagging called function names, with the banned `compile`-named functions made tier entries first (SC3)

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 01.1.1-02-PLAN.md — Tier extension: the 80 swept candidates, `Mix.Task.run`, every code-path mutator, the barrier and sink-primitive front doors (`code_server`, `erts_internal:prepare_loading`, `init` make_permanent and restart) and every interpret, eval and load front door of the debugger app's eight interpreter modules, twelve truth-7 fixtures, the Credo MFA mirror and a generated probe proving every entry live (SC2, SC4); the rest of the debugger app and the other unswept OTP apps stay open with Phase 01.1.1.1 (StrictCtMake)

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 01.1.1-03-PLAN.md — The reachability sweep as a both-lane contract test over OTP, Elixir and the runtime dependencies derived from mix.exs, with every exclusion known false replaced (SC1, SC2); sweeping the other installed OTP apps moves to Phase 01.1.1.1

**Wave 4** *(blocked on Wave 3 completion)*
- [x] 01.1.1-04-PLAN.md — Functions named like a banned module, and every barrier-module, sink-delegate, code-related `:erlang` and in-front-of-barrier export judged once from source, pinned by contract test (SC2 code-path record, SC3 record); the audit of the ported sweep exclusions (SC1's "every exclusion has a reason that is true") and the parser disposition move to Phase 01.1.1.1 (INT-20261029-02)

**Wave 5** *(blocked on Wave 4 completion)*
- [x] 01.1.1-05-PLAN.md — Source-level MFA rules in the Credo check for quoted, module-body and `mix.exs` calls, the explanation rewrite and the human wording check (SC6, SC7)

**Cross-cutting constraints:**
- SC8: the PR changes no lib/, .github/, mix.exs, lockfile or .credo.exs path and is merged green with a recorded ci-gate run link

### Phase 01.1.1.1: Exact-source evidence and named atom-creator guards (INSERTED)

**Goal**: Preserve the merged exact-source/PathConsult tracer and finish source-backed static guards for the named consult/Yecc and Logger/ExUnit caller-input families. The measured audit exceeded its context budget; INT-20261029-02 and ADR 0021 require the structural split recorded in `phases/01.1.1.1-finish-the-ban-list-atom-creators-every-installed-otp-app-an/01.1.1.1-SPLIT.md`. Original acceptance is preserved across 01.1.1.1–01.1.1.5; no whole-ban-list completion is claimed here.
**Depends on**: Phase 01.1.1
**Requirements**: None completed here (SEC-01 advanced; Phase 5 completes it)
**Success Criteria** (what must be TRUE):
  1. The owner-approved exact-lane resolver/archive and StrictPathConsult remain intact; reuse merged PR 23 and its final exact-lane CI evidence.
  2. `:file.consult/1`, exported Yecc file/legacy fronts, `Logger.Formatter.new/1`, `Logger.configure_backend/2`, `Logger.default_formatter/0,1`, `Logger.Formatter.new/0`, `Logger.App.start/2` and `ExUnit.CaptureServer.handle_call/3` have exact-lane caller-input traces and explicit dispositions. Unsafe fronts have mirrored tiers and uncalled source/BEAM probes; conservative existing-atom bans and benign controls remain.
  3. Every changed exclusion is a substantive cited triple with full changed-slice match coverage and an individual nonvacuous removal witness where retained. EX-089/EX-159 original identities and every affected match stay mapped; other original identities remain with 01.1.1.4.
  4. Each new scoped PR changes no `lib/`, `.github/`, dependency, lockfile or `.credo.exs` path and merges with all required checks green and a current-head CI link. A newly banned `lib/` call stops affected work for an owner-recorded ADR-backed allowlist or separate-library-PR decision.
**Transfer**: Original SC1's remaining unnamed fronts and SC2 belong to 01.1.1.2/.3; original SC3's full 221 exclusions plus five metadata identities belong to 01.1.1.4; original SC4's unresolved Macro AST judgment belongs to a substantive AST-family audit there, while the collision hard stop applies everywhere. Original SC5 and final unconditional SC1–SC3 enforcement belong to 01.1.1.5. Original SC6 applies to every inserted executable phase. The three transfers from 01.1.1 and their T-IDs remain open until 01.1.1.5; parent debt and Phase 5 runtime proofs do not move.
**Plans:** 2/2 completed; original Plans 01–05 are superseded history, with Plan 01 honestly partial

Sequential scoped PRs; each depends on the previous green merge.

Plans:
**Wave 1**
- [x] 01.1.1.1-06-PLAN.md — Consult/Yecc caller-file guards and bounded source-backed dispositions

**Wave 2** *(Wave 1 dependency satisfied)*
- [x] 01.1.1.1-07-PLAN.md — Logger/ExUnit caller-format paths and all six discovered wrapper dispositions

**Cross-cutting constraints:**
- D-01–D-03: caller-text/file creators exposed by each named family have compile-only fixtures in both guards; existing-atom bans stay.
- D-10, D-11: no Macro policy is inferred; any newly banned library caller halts affected work.
- D-13, D-14: each scoped PR merges green; command boundaries, dependency budget and Phase 5 runtime-proof ownership remain.

### Phase 01.1.1.2: Installed OTP inventory and Common Test guard slice (INSERTED)

**Goal:** Discover every installed OTP app/BEAM independently on each exact lane, including Mix-pruned and unstarted apps; deliver the real Common Test caller-file/load guard with StrictCtMake hits. (INT-20261029-02; ADR 0004, 0021; D-04, D-05, D-09)
**Requirements**: None completed here (SEC-01 advanced; Phase 5 completes it)
**Depends on:** Phase 01.1.1.1
**Success Criteria**:
  1. Complete discovered app/BEAM inventory, versions, source availability and source/function budget are recorded per exact lane; unreadable files, Xref ingestion and no-debug-info failures are observable and fatal. Omission/synthetic-installation controls demonstrate failure without starting apps.
  2. The Common Test caller-file/load path is source-disposed and statically caught in both guards with uncalled fixtures; StrictCtMake reports hits.
  3. Discovered, successfully inspected and active-disposition sets are distinct. Existing sweep scope never shrinks; pending families are explicit transfers to 01.1.1.3, never exclusions or a full-coverage pass. Full installed equality/zero-undisposed enforcement is owned by its final bounded child and 01.1.1.5.
  4. At most five bounded plans/about three working days; all scoped PRs merge green with exact-lane CI links and the unchanged collision/diff gates. Further newly reached work is split before exceeding the budget.
**Plans:** 2/2 complete; phase goal verification passed

**Execution status:** Complete and verified. Both plans are merged green. Security prerequisite PR #28 updated Phoenix.HTML to 4.4.0 and refreshed lock provenance; inventory PR #27 merged with complete exact-lane receipts. Common Test PR #29 merged as `54c6afbc6b2c2bdd8982ff50f807637d636c05ba` after run 41150169442 passed every required check on its exact tested head, with final validated receipts and the last review finding resolved. Canonical goal verification passed all 12 must-haves, with no human UAT. SEC-01 stays Pending for Phase 5; parent verification debt is unchanged.

Plans:
**Wave 1**
- [x] 01.1.1.2-01-PLAN.md — Independent full installed OTP discovery/inspection, fatal omission controls and exact-lane inventory receipts (merged green; final head receipts recorded)

**Wave 2**
- [x] 01.1.1.2-02-PLAN.md — Exact-source Common Test export dispositions, mirrored static guards and final scoped green delivery

### Phase 01.1.1.3: Debugger selected-file interpreter and seed provenance (INSERTED)

**Goal:** Statically guard the remaining exported dbg_wx_interpret:start/4 selected-file interpreter front on both exact lanes and source-dispose its assigned start/filter/interpret roots plus dbg_idb/dbg_istk seed paths. Retain supporting caller-input provenance, benign controls and complete active coverage without claiming debugger-wide or installed-wide completion. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021; original SC1/SC2)
**Requirements**: SEC-01 advanced only; Phase 5 retains requirement completion
**Depends on:** Phase 01.1.1.2
**Planning gate:** Adopted measured first family only; original installed-scope remainder is owned by 01.1.1.3.1–01.1.1.3.13. Those entries are research-only reservations, never bulk executable audits. Each future connected slice must be calibrated and partitioned before PLAN files. See `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md` and the single machine-readable ownership ledger.
**Success Criteria**:
  1. Every assigned root and seed path has exact-lane source-backed dispositions; unsafe exported fronts have mirrored Credo/BEAM tiers, uncalled direct/capture/apply/source-only probes, independent discovery, benign controls and individual removal witnesses. New exports/roots and omitted assignments fail closed.
  2. Offline citations pass provenance, digest, containment and line checks; changed exclusions retain full match/original identity truth and individual nonvacuous removal witnesses against complete active dispositions. Supporting sources keep their distinct owners.
  3. Existing active coverage cannot shrink; installation semantics remain pending with exact owners. A slice pass cannot satisfy final .3.13 acceptance. A scoped guard PR merges green on the exact tested head within the ordinary review cap; collision/source/policy stops remain.
**Plans:** 4/4 plans executed

Plans:
**Wave 1**
- [x] 01.1.1.3-01-PLAN.md — Approve exact source extension, then guard the selected-file interpreter path and branches

**Wave 2** *(blocked on Wave 1 completion)*
- [x] 01.1.1.3-02-PLAN.md — Guard the public stack decoder and finish assigned seed/source dispositions

**Wave 3** *(blocked on Wave 2 completion)*
- [x] 01.1.1.3-03-PLAN.md — Complete omission controls, bounded internal review and scoped current-head CI

**Wave 4** *(blocked on Wave 3 completion)*
- [x] 01.1.1.3-04-PLAN.md — Prove fresh receipt/ownership history correctness, then finish the same green PR and phase evidence

### Phase 01.1.1.3.1: Debugger remaining settings, trace, breakpoint and monitor routes (INSERTED)

**Goal:** Own and research debugger remaining settings, trace, breakpoint and monitor routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2, Phase 01.1.1.3
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.2: Common Test remaining runner, specification and source-input routes (INSERTED)

**Goal:** Own and research common Test remaining runner, specification and source-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.3: EUnit remaining runner and test-description input routes (INSERTED)

**Goal:** Own and research eUnit remaining runner and test-description input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.4: EDoc remaining source, generation and callback routes (INSERTED)

**Goal:** Own and research eDoc remaining source, generation and callback routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.5: Diameter remaining dictionary and service-input routes (INSERTED)

**Goal:** Own and research diameter remaining dictionary and service-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.6: Reltool remaining configuration and code-path routes (INSERTED)

**Goal:** Own and research reltool remaining configuration and code-path routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.7: SNMP remaining compiler and service-input routes (INSERTED)

**Goal:** Own and research sNMP remaining compiler and service-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.8: Megaco remaining codec and configuration-input routes (INSERTED)

**Goal:** Own and research megaco remaining codec and configuration-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.9: Observer and ET remaining trace and match-specification routes (INSERTED)

**Goal:** Own and research observer and ET remaining trace and match-specification routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.10: Mnesia remaining schema and configuration-input routes (INSERTED)

**Goal:** Own and research mnesia remaining schema and configuration-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.11: SSH remaining service, shell and configuration-input routes (INSERTED)

**Goal:** Own and research sSH remaining service, shell and configuration-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.12: FTP, TFTP, ODBC and ELDAP unresolved source-input routes (INSERTED)

**Goal:** Own and research fTP, TFTP, ODBC and ELDAP unresolved source-input routes. Extract measured connected source families and retain exact ownership of every unresolved remainder before executable plans. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.3.13: wx native/source-input coverage, erl_interface accounting and final installed-scope gate (INSERTED)

**Goal:** Own unresolved substantive wx/native/source-input coverage and erl_interface zero-BEAM accounting, then enforce unconditional full installed-scope acceptance on both lanes. (INT-20261029-02, INT-20261030-02, INT-20261030-06; ADR 0004, 0021)
**Requirements**: SEC-01 advanced only; Phase 5 completes it
**Depends on:** Phase 01.1.1.2, Phase 01.1.1.3, Phase 01.1.1.3.1, Phase 01.1.1.3.2, Phase 01.1.1.3.3, Phase 01.1.1.3.4, Phase 01.1.1.3.5, Phase 01.1.1.3.6, Phase 01.1.1.3.7, Phase 01.1.1.3.8, Phase 01.1.1.3.9, Phase 01.1.1.3.10, Phase 01.1.1.3.11, Phase 01.1.1.3.12
**Planning gate:** Research-only unresolved source-task reservation; no executable plans or bulk dispatch. Exact assignments: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-OWNERSHIP.jsonl.gz`; partition contract: `.planning/phases/01.1.1.3-installed-otp-front-door-coverage-in-calibrated-source-famil/01.1.1.3-SPLIT.md`. Further splits extend .4/.5 dependencies and preserve a substantive final gate owner.
**Success Criteria**:
  1. Every assigned app/module/root/caller chain, including zero-hit and unmapped-source tasks, stays owned in the complete receipt-derived ledger; source evidence and overlaps preserve original identities and active scope.
  2. Before executable plans, calibrate connected caller-input/source closure, materialize exact remaining owners and respect five plans/about three working days, two–three tasks per plan, five files per task and at most half a 200k executor context. This reservation is not a size or schedule claim.
  3. Substantive static guard changes preserve exact-lane citations, mirrored uncalled probes, changed-match/removal controls, existing required green checks, scoped PRs and finite review/collision/source gates.
  4. After substantive source coverage and all preceding source tasks close, unconditionally require installed OTP versus semantically swept OTP app identity equality, discovered/inspected/ingested BEAM identity equality and zero undisposed reached/boundary fronts on both lanes. Omitted apps/BEAMs, failed/corrupt scans, no debug information and unresolved required sources are fatal; no pending selector can pass this gate. Phase .5 rechecks independently.
**Plans:** 0 plans

Plans:
- [ ] Research and calibrate this reservation before executable planning

### Phase 01.1.1.4: Carried exclusion truth in calibrated source families (INSERTED)

**Goal:** Establish the semantic truth of every carried/new exclusion with complete per-lane source/match coverage and independent removal witnesses: CN-001..006, EX-001..182, BD-001..033, and five metadata identities (221 exclusions/226 identities). (INT-20261029-02; ADR 0004, 0021; original SC3/SC4; D-06–D-10)
**Requirements**: None completed here (SEC-01 advanced; Phase 5 completes it)
**Depends on:** Phase 01.1.1.3, Phase 01.1.1.3.1, Phase 01.1.1.3.2, Phase 01.1.1.3.3, Phase 01.1.1.3.4, Phase 01.1.1.3.5, Phase 01.1.1.3.6, Phase 01.1.1.3.7, Phase 01.1.1.3.8, Phase 01.1.1.3.9, Phase 01.1.1.3.10, Phase 01.1.1.3.11, Phase 01.1.1.3.12, Phase 01.1.1.3.13
**Planning gate:** Unplanned scope reservation. Before execution, partition by actual source module/function/caller chain, calibrate a representative substantive family and materialize bounded children. No row-halving or five-plan promise for the 10+ MB corpus. Each original identity may span child records, whose union equals its complete per-lane matched-MFA set, including overlaps and new installed scope. Every executable phase obeys ADR 0021 and the 50% context bound.
**Success Criteria**:
  1. All original/new entries have substantive exact-lane semantic verdicts, caller traces and valid app-relative source citations; false reasons become tier entries with uncalled fixtures or narrower function exclusions. Absence needs inventory/export evidence.
  2. Every retained exclusion has a nonvacuous individual removal witness against the complete active disposition set on every applicable lane. Narrow/merge/remove overlap; no capped matches, fabricated entries or regex-as-semantic-proof claims.
  3. The substantive AST-family child obtains the owner Macro caller-AST judgment before changing its disposition. Any newly banned library call stops for its exact MFA/callsite/input/guard report and owner-recorded remedy; no automatic allowlist/refactor choice.
  4. Every substantive audit child merges green with complete scope transfers and recurring changed-slice checks. 01.1.1.5 owns final unconditional whole-table enforcement and closure.
**Plans:** 0 plans

Plans:
- [ ] TBD (run $gsd-plan-phase 01.1.1.4 to break down)

### Phase 01.1.1.5: Complete audit enforcement and truthful guard explanation (INSERTED)

**Goal:** Implement unconditional whole-table atom/eval/boundary/source/removal enforcement and the evidence-mapped Credo explanation, closing the original three 01.1.1 transfers only after all source-family children are merged green. (INT-20261029-02; ADR 0004, 0021; original SC1–SC6)
**Requirements**: None completed here (SEC-01 advanced; Phase 5 completes it)
**Depends on:** Phase 01.1.1.4, Phase 01.1.1.3, Phase 01.1.1.3.1, Phase 01.1.1.3.2, Phase 01.1.1.3.3, Phase 01.1.1.3.4, Phase 01.1.1.3.5, Phase 01.1.1.3.6, Phase 01.1.1.3.7, Phase 01.1.1.3.8, Phase 01.1.1.3.9, Phase 01.1.1.3.10, Phase 01.1.1.3.11, Phase 01.1.1.3.12, Phase 01.1.1.3.13
**Success Criteria**:
  1. Both-lane recurring contracts enforce complete original/active identity and matched-function equality, true cited triples, exact source validity, complete installed/ingested/swept equality and zero undisposed atom/eval/boundary fronts; no pending/slice selector can make this global gate pass.
  2. Whole-table negative controls reject two-tuples, empty/invalid/missing/wrong-lane source, missing identities/functions/verdicts and every redundant retained exclusion; individual removal witnesses cover every applicable lane.
  3. Two transferred-open-item paragraphs are removed only after their guarantees pass; every changed claim maps to a fixture/strictness/sweep assertion. Preserve computed-dispatch/write-then-load limits and Phase 5 ownership; record explicit owner approval of exact changed wording before merge.
  4. All original SC4 owner decisions/remedies are resolved where needed, and every scoped PR is merged with required checks green and exact tested CI links. This is substantive enforcement/wording work, never a receipt-only phase. Parent verification debt remains separately owned.
**Plans:** 0 plans

Plans:
- [ ] TBD (run $gsd-plan-phase 01.1.1.5 to break down)

### Phase 2: Walking skeleton and runner spike
**Goal**: One compiled story renders end to end in a plain host app and in an adversarial one, a first visual check runs under every baseline guard, and the browser-runner question (Q1) is answered by evidence.
**Mode:** mvp
**Depends on**: Phase 01.1.1.5
**Requirements**: None completed here (a vertical slice and a spike; see Partial delivery).
**Partial delivery**: QA-04 (skeleton `hosts/operator`, completes in Phase 9), VIS-01 and VIS-02 (guards, complete in Phase 21), CANVAS-01 and SEC-03 (nonce CSP exercised, complete in Phase 7).
**Provisional on:** Q9
**Spike first**: the browser-runner spike on the unified criteria (media emulation, per-rendition viewport, use from a Mix task, availability in dev, remote server option, determinism on the maintainer's platform, probe injection under nonce CSP).
**Success Criteria** (what must be TRUE):
  1. A maintainer can open one compiled story's scenario in `hosts/vanilla` through the real root layout, and a LiveViewTest renders it in CI.
  2. `hosts/operator` serves the same scenario from a nested `/admin/dev/fablebook` mount under a strict nonce CSP with self-hosted fonts and custom tokens, with zero CSP violations.
  3. One visual check runs in the pinned Playwright container with explicit `threshold: 0.1` and `max_diff_pixels: 0` asserted by a test; CI fails on a missing baseline, on a `git status` change, and never writes a baseline itself.
  4. A written spike result states pass or fail for each runner criterion and the fallback decision, ready for the owner to record the Q1 resolution.
**Plans**: 4 (estimate)

### Family 2: Story model and catalog
*Phases 3 to 4.*

### Phase 3: Story model and catalog
**Goal**: Authors declare stories as compiled modules, and the catalog finds, identifies and describes every scenario and every component, with or without a story, deterministically, with typed errors and telemetry in place.
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: CORE-01, CORE-02, CORE-04, CORE-05, CORE-06, CORE-07, TEL-01, TEL-02, TEL-03, PERF-01, COMPAT-01
**Partial delivery**: CORE-03 (citation shape only; existence and enforcement complete in Phase 15).
**Provisional on:** Q12, Q13, Q24
**Success Criteria** (what must be TRUE):
  1. A story with `use Fablebook.Story, subject:, tier:` appears in the catalog with ids from module namespace plus function name and a stable URL for every scenario, including scenarios inside groups; the catalog is identical in dev and test.
  2. A person who adds or deletes a story module in a running host sees the catalog change after a reload, with no restart; a test of the discovery seam proves both directions.
  3. A component with no story in the Book's `components:` list shows as Unstoried, filled only from `default`, then `examples`, then `values`, otherwise a "Needs a story" tile; a string slot, a second story for one component, or a LiveView subject without a Waiver fails compilation with file, line, value and a fix.
  4. The `ComponentInfo` contract test passes on the floor, latest and canary lanes, and an injected fault degrades to manual controls instead of crashing.
  5. A 5000-scenario catalog builds in at most 1.5 s with t(5000)/t(500) under 15 and no `Code` calls; every event in `Fablebook.Telemetry.events/0` is emitted and none unlisted, with whitelisted metadata and a closed `%Fablebook.Error{}` set.
**Plans**: 5 (estimate)

### Phase 4: Render seam, rules engine and generated tests
**Goal**: Any scenario can be rendered outside a LiveView and judged by one rules registry, so the canvas, tests and bundles agree; every strict-rule failure is an error unless a visible Waiver or Draft says otherwise.
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: CORE-09, CORE-12, CHECK-05
**Partial delivery**: CORE-14 (render-mode metadata; completes in Phase 7), LLM-06 (manifest and drift check; completes in Phase 19).
**Pending (not v1, unmapped)**: CORE-15 (`unsupported_subject` for LiveComponent subjects), waiting on Q14.
**Provisional on:** Q14, Q16, Q20
**Success Criteria** (what must be TRUE):
  1. `Fablebook.Render.render(scenario, globals, purpose)` returns identical normalized markup and hash for one scenario across different nonces, CSRF values, generated ids and timestamps, and a real attribute change changes the hash.
  2. `Fablebook.Testing.generate_tests(book)` produces one ExUnit test per scenario (renders, attrs valid, desc present, citations resolve) in `hosts/vanilla` with no per-scenario code, and `mount_scenario/2` uses `live_isolated`.
  3. A strict-rule violation is an error; the same violation under a per-story or per-scenario Waiver with a written reason passes and is counted visibly; under Draft it is a warning; no global switch exists.
  4. `mix fablebook.manifest` writes byte-identical output on repeated runs and a drift check fails when the committed manifest is stale.
**Plans**: 5 (estimate)

### Family 3: Controls and URL state
*Phases 5 to 6.*

### Phase 5: Controls and URL state
**Goal**: A person can change a scenario's attrs through typed controls, and the whole view state round-trips through the URL, with the never-eval and never-atom guarantees proven against hostile input.
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: CTRL-01, CTRL-03, CTRL-06, SEC-01
**Partial delivery**: CTRL-04 (Globals type and codec; completes in Phase 8), CTRL-02 and SEC-05 (complete in Phase 12), QA-01 (cast and URL state properties; completes in Phase 16).
**Success Criteria** (what must be TRUE):
  1. In the minimal workbench, attrs show typed controls (boolean, integer, float, string, and a select for `values:`), complex attrs offer compiled presets, and invalid input is rejected with a typed error rather than a crash.
  2. Reloading any workbench URL reproduces the view exactly, overrides over 2 KB are refused, and Back returns to the previous workbench URL.
  3. "Copy as scenario" yields Elixir text for a Draft scenario with the overridden attrs and a TODO situation; nothing is written to disk and no atoms are created.
  4. Properties show zero new atoms after warm-up through the real `handle_params` for arbitrary URL and control input, an XSS corpus stays escaped, and mutation-proven tests fail when a Credo ban or a guard is removed; Muex floors for `Cast` and `URLState` are committed.
**Plans**: 4 (estimate)

### Phase 6: Thin bundle slice
*Pulled forward from Family 9, ahead of its home band so the Core Value (an accurate export) is exercised before the workbench exists.*
**Goal**: A person can run one command and get a redacted, labelled context bundle for one scenario.
**Mode:** mvp
**Depends on**: Phase 4, Phase 5
**Requirements**: SEC-04
**Partial delivery**: LLM-01 (scenario selector and Mix task; completes in Phase 19), LLM-02 (skeleton; completes in Phase 27), LLM-04 (no-browser level; completes in Phase 27).
**Provisional on:** Q20
**Success Criteria** (what must be TRUE):
  1. `mix fablebook.bundle <scenario>` writes `BUNDLE.md` and `bundle.json` (schema `fablebook.bundle/1` skeleton) with markup, Contract, situation and citations as data, labelled "no-browser", with browser-only parts reported as not-run.
  2. Paths, env values, hosts, secret-shaped strings and session or CSRF tokens never appear in a bundle, a `redact:` hook adds custom redaction, and `--out` outside the project root is refused with `:path_rejected`.
  3. Running the command twice on unchanged input yields byte-identical output, and one golden bundle is committed.
**Plans**: 3 (estimate)

### Family 4: Canvas fidelity
*Phases 7 to 9, then Phase 10 pulled forward from Family 10.*

### Phase 7: Canvas isolation and containment
**Goal**: Scenarios render in an iframe through the host's own pipeline, the grid lays out several scenarios, and whatever one scenario does wrong stays inside its own tile.
**Mode:** mvp
**Depends on**: Phase 5
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

### Phase 8: Canvas diagnostics, hot reload and Globals
**Goal**: When the canvas cannot work the person is told why, edits show up without a restart, and the Globals change what renders.
**Mode:** mvp
**Depends on**: Phase 7
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

### Phase 9: Operator host, fidelity receipt and real components
**Goal**: The adversarial host app proves production fidelity, and real components from an owner repo render in a released 0.x.
**Mode:** mvp
**Depends on**: Phase 8
**Requirements**: QA-04
**Pending (not v1, unmapped)**: CORE-16 (fixture helper for streams, async and forms), waiting on Q14.
**Provisional on:** Q22
**Success Criteria** (what must be TRUE):
  1. `hosts/operator` is complete (custom tokens without daisyUI, self-hosted fonts, strict nonce CSP, custom root layout, `current_scope` `on_mount`, colocated hooks, JS commands, `<.portal>`, streams and async assigns, `to_form`, Gettext with an RTL locale), and its E2E fidelity spec passes on CSS bytes, fonts (`document.fonts` and network), hooks and CSP (C3).
  2. A 0.x release is installed read-only in one dogfood repo, and ten real mailglass components render there without changes to that repo's CSS or JS.
  3. A throwaway installer-shape spike against `hosts/vanilla` leaves a written result that Phase 10 consumes.
**Plans**: 4 (estimate)

### Phase 10: Installer core
*Pulled forward from Family 10, so the installer's mount-shape surprises surface here rather than in Phase 30.*
**Goal**: `mix igniter.install fablebook` on a fresh Phoenix app leaves exactly the tree that was hand-wired in the host apps.
**Mode:** mvp
**Depends on**: Phase 9
**Requirements**: INST-01
**Provisional on:** Q17
**Success Criteria** (what must be TRUE):
  1. On a fresh `phx.new` the installer mounts `/dev/fablebook` inside `dev_routes` and sets up `elixirc_paths`, live_reload, the formatter inputs, the Book with `components:` seeded, a welcome page and a sample story, leaving `app.js` and the Tailwind config byte-identical.
  2. The installed tree equals the hand-wired `hosts/vanilla` tree (golden), and applying the installer twice or from a partial state gives the same result.
  3. `MIX_ENV=prod mix compile` of the installed app succeeds with no Fablebook routes, and a plain-Mix fallback works when Igniter is absent.
**Plans**: 4 (estimate)

### Family 5: Workbench UX
*Phases 11 to 13.*

### Phase 11: Chrome shell, sidebar, story page and grid
**Goal**: A person can browse the catalog in the workbench: a tier-first sidebar, a story page that is the docs, and the All-scenarios grid, inside the performance gates.
**Mode:** mvp
**Depends on**: Phase 7, Phase 10
**Requirements**: WB-01, WB-02, WB-08, WB-09, PERF-02, PERF-03, PERF-04, INST-05
**Partial delivery**: A11Y-01 (basics; completes in Phase 13), WB-17 (dots read "Not run"; completes in Phase 20), LLM-01 ("Copy for LLM" button; completes in Phase 19), CORE-06 (tier-first sidebar), SEC-05 (Markdown escaped by default; completes in Phase 12).
**Provisional on:** Q16
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The workbench has three panes with a tier-first sidebar of Section folders, and a story page that shows the description, citations, attr and slot Reference, then the All-scenarios grid by default.
  2. Appearance (System, Light, Dark) restyles the chrome only and never the scenario; the chrome uses ink on neutral, `fb-` OKLCH tokens, system fonts and two density modes with no daisyUI, and render swaps are instant while a subject's own motion plays.
  3. Sidebar dots and tile status say "Not run" until Evidence exists and never show a green dot, and "Copy for LLM" on a scenario copies the thin bundle.
  4. A control change sends a WebSocket diff of at most 4 KB without re-sending the sidebar, mount and render reductions stay within 1.25x the committed reference with a max render of 50 ms over 10k iterations, and session heap stays at or under 3 MB with a leak test within 1.2x and 0 added ETS tables or processes.
  5. A clean-room timed run on a fresh `phx.new` with Node absent from `PATH` goes from install to an auto-discovered component rendering in the host's real CSS in under 5 minutes, passing strict mode with zero Waivers.
**Plans**: 5 (estimate)

### Phase 12: Inspector, toolbar, palette and keyboard
**Goal**: A person can inspect and edit a scenario, set up the canvas environment from the toolbar, and drive the workbench from the keyboard.
**Mode:** mvp
**Depends on**: Phase 11
**Requirements**: CTRL-02, WB-03, WB-04, WB-06, WB-11, WB-15, WB-18, SEC-05
**Partial delivery**: WB-05 (Attrs, HEEx and Events tabs; the Checks tab completes it in Phase 20), CTRL-04 (device frame tool).
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The inspector shows Attrs, HEEx (copy the exact call) and Events; an edited control shows an "Edited" chip with Restore scenario, and attrs that cannot be edited say "Set in the story file" with Open in editor, which works only on localhost and only for paths inside the project root.
  2. The toolbar offers width presets 320/375/768/1280/1440 with a height and a rotate action (`orient`), Fill and custom, opening at 375, plus color scheme, theme, direction, zoom, outline, measure, background (only for transparent subjects), Isolate, fullscreen, light/dark side by side and the device frame picker, each tool showing its value as text and appearing only when it applies.
  3. The command palette (cmd-K) searches stories, scenarios, pages, canon and commands, `/` filters the sidebar by tier, state class, tag, Draft, has-findings and has-Waiver, and single-key shortcuts can be switched off and are suspended while focus is in the preview.
  4. Workbench settings (Appearance, density, single-key switch, pane sizes) persist and are listed, and input over a control type's size cap is refused with `:state_too_large`.
**Plans**: 4 (estimate)

### Phase 13: Mobile layout, QR, microcopy, Compare by Globals and Diagnostics
**Goal**: The workbench works on a phone, every empty and error state speaks in canonical words, and the chrome meets WCAG 2.2 AA.
**Mode:** mvp
**Depends on**: Phase 12
**Requirements**: WB-07, WB-10, A11Y-01
**Partial delivery**: WB-13 (Compare along Globals axes with a canvas cap; completes in Phase 29), WB-12 (catalog build time, scenario count and recent crashes; completes in Phase 22).
**Provisional on:** Q21, Q25
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Below 768 px the workbench switches to Mobile layout, and "Show on phone" shows a QR code when the server is reachable and otherwise names the real causes (server bound to loopback, `check_origin`) without ever binding the LAN.
  2. Every empty, error and disconnected state shows its canonical microcopy from UX-DESIGN.
  3. Compare shows two renditions that differ in exactly one Global side by side, capped at four live canvases, and the Diagnostics page shows catalog build time, scenario count and recent crashes.
  4. The chrome has landmarks, skip links, a disclosure-list sidebar, live regions, keyboard-resizable separators, a combobox palette, 24 px targets and reflow at 320 px, and its computed contrast matrix across light, dark and high contrast has no failing pair.
**Plans**: 4 (estimate)

### Family 6: Design canon
*Phases 14 to 18, then Phase 19 pulled forward from Family 9.*

### Phase 14: Canon core
**Goal**: Design knowledge lives in `design/` as Markdown and DTCG tokens that Fablebook parses itself, layered from brand to product, and pages can embed live scenarios.
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: CANON-01, CANON-02, CANON-03, CANON-09, CANON-12, CORE-11
**Partial delivery**: QA-01 (frontmatter property; completes in Phase 16).
**Provisional on:** Q30
**Success Criteria** (what must be TRUE):
  1. A canon entry of each kind (term, voice, tone, microcopy rule, persona, job, twin, imagery) loads from a Markdown file with strict-subset frontmatter, and a malformed file fails with its file, line and a fix; the parser is property-tested and uses no YAML dependency.
  2. DTCG 2025.10 tokens with a light/dark resolver load, and abracabrand's `brandbook/tokens/identity.json` is read with `$extensions` unchanged on a round trip and never written.
  3. A product canon inherits a brand canon that comes from a path or a dependency, and overriding a brand rule without a Waiver fails.
  4. A Markdown or HEEx Page embeds a live scenario, and the embed follows the scenario when it changes.
**Plans**: 4 (estimate)

### Phase 15: Foundations, Themes, Directions, citations, coverage and To review
**Goal**: The canon is visible in the workbench and enforced against scenarios: Foundations pages, citation checks, a coverage matrix, Themes, Directions and a first To review page.
**Mode:** mvp
**Depends on**: Phase 11, Phase 14
**Requirements**: CANON-04, CANON-08, CANON-10, CANON-11, CORE-03, CORE-08, JOURNEY-01
**Partial delivery**: WB-14 (To review lists proposals, stale or assumed canon, gaps and due Waivers; findings without a verdict complete it in Phase 22), WB-13 (Theme and Direction axes; completes in Phase 29), WB-03 (canon entries appear in the palette).
**Provisional on:** Q16, Q25, Q26
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The Foundations section shows token swatches, type scale, radius, shadow and motion specimens, contrast cards, the glossary table, voice, and persona, job and twin cards that link to the scenarios citing them.
  2. A scenario that cites a persona, job or twin that does not exist fails the catalog build, and Area and Screen scenarios without a persona and job warn until the canon has its first persona and error after that, waivable per scenario only; orphan personas and uncovered jobs are reported.
  3. The coverage matrix crosses stories with the 12 state classes, each cell a scenario or a reasoned Waiver, and Gaps are listed.
  4. A Book renders under several named Themes, a twin's own theme is selectable, an unreadable theme choice becomes a Guardrail finding, and Directions (proposal until chosen, importable from abracabrand routes) can be picked in the toolbar and compared across the catalog; choosing one archives the rest.
  5. A To review page with a sidebar count badge and no pop-ups lists proposals, stale or assumed canon, Gaps and Waivers due, and a Journey declared in a job file fails the catalog build when a referenced scenario is missing.
**Plans**: 5 (estimate)

### Phase 16: Canon lints, tokens task and DESIGN.md
**Goal**: The canon is checked in the PR lane by pure-Elixir lints, imported from abracabrand, and turned into CSS and a DESIGN.md.
**Mode:** mvp
**Depends on**: Phase 14, Phase 15
**Requirements**: CANON-05, CANON-07, UX-06, QA-01
**Partial delivery**: CANON-06 (`DESIGN.md` and `mix fablebook.tokens`; `.impeccable/design.json` completes it in Phase 24).
**Provisional on:** Q27
**Success Criteria** (what must be TRUE):
  1. abracabrand's BRAND.md and direction notes appear as Voice, Imagery and Applications pages, logos are filtered by `rights/assets.json`, and a bundle pins the brand by its `inventory.json` hash.
  2. In the PR lane, with no browser, glossary and retired-wording lints over rendered text and accessible names, deterministic voice rules, token conformance and DTCG-to-CSS drift, and a WCAG 2.2 contrast matrix each report findings.
  3. Copy benchmarks flag button word count, title and error length, sentence length, reading grade per persona and generic labels such as "Click here" or "Submit".
  4. `mix fablebook.tokens` generates and checks CSS from the tokens and writes `DESIGN.md` with an ownership header and a spec-version stamp, and it refuses to overwrite a file it does not own.
  5. The StreamData invariants for cast, URL state, id stability, manifest determinism, no new atoms, bounded render, frontmatter, contrast maths and telemetry metadata all run in CI.
**Plans**: 4 (estimate)

### Phase 17: Content track I - Fablebook brand book and the Logistify family
**Goal**: Fablebook has its own brand book, and the Logistify product family exists as three full Books under one brand canon.
**Mode:** mvp
**Depends on**: Phase 16
**Requirements**: DOCS-04
**Partial delivery**: QA-06 (Logistify's three Books; completes in Phase 34).
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Fablebook's brand book is built through the two-session abracabrand process and covers the mark, docs site, README, Hex page and social card, while the workbench chrome stays ink-on-neutral.
  2. In `hosts/operator`, Logistify's brand canon and its three product Books (operator console, shipper portal, driver app) each have personas, jobs, terms, a Shell, Areas and Screens in a visually distinct, dense style with real en, de and fr switching.
  3. The Logistify Books pass the canon lints, citation checks and coverage report, and Foundations shows their cards; a hand-authored minimal-token fallback keeps the phase mergeable if a brand book slips.
**Plans**: 4 (estimate)

### Phase 18: Content track II - Chatly and Clinicly
**Goal**: Two more fictional adopter products, one mobile-first CJK consumer app and one RTL accessibility-critical portal, extend the showcase.
**Mode:** mvp
**Depends on**: Phase 17
**Requirements**: None completed here (see Partial delivery).
**Partial delivery**: QA-06 (Chatly and Clinicly; completes in Phase 34).
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Chatly (ja, mobile-first, playful) and Clinicly (ar with en, RTL, high-contrast, minimal motion) each have an abracabrand-built brand book, a full canon, a Shell, Areas and Screens and a visually distinct style in `hosts/operator`.
  2. Both Books pass the canon lints and citation checks, and their scenarios cover the state classes their twin stresses (huge counts and stale for Chatly, denied and forms for Clinicly).
  3. The twins stay out of the Hex tarball, shown by the allowlist test.
**Plans**: 3 (estimate)

### Phase 19: Bundle core with canon
*Pulled forward from Family 9 so the no-browser tier carries canon context as soon as canon and twins exist.*
**Goal**: A bundle for any selector carries the cited canon, validates against a committed schema, and is guarded by golden bundles from the twins.
**Mode:** mvp
**Depends on**: Phase 6, Phase 14, Phase 17, Phase 18
**Requirements**: LLM-01, LLM-06, LLM-07
**Partial delivery**: LLM-02 (`context/` and no-browser scenario files; completes in Phase 27), SEC-04 (already complete).
**Success Criteria** (what must be TRUE):
  1. `mix fablebook.bundle` accepts a scenario, story, section, tier, tag or `all`, and the workbench offers Copy for LLM and Download context.
  2. A bundle's `context/` holds DESIGN.md, the tokens used, glossary hits, voice, personas and jobs and a PRODUCT.md excerpt, and `Fablebook.Bundle.validate/1` round-trips every bundle against the committed JSON Schema.
  3. Three golden bundles from the twins pass, a determinism property holds, and size budgets of about 7.5k text tokens and 1.5 MB per scenario are enforced.
  4. The manifest (`index.json`, `components.json`) is served at the mount, `llms.txt` and `llms-full.txt` are included, and the drift check still passes.
**Plans**: 4 (estimate)

### Family 7: Probe, checks and visual regression
*Phases 20 to 24.*

### Phase 20: Probe, Evidence and the Checks tab
**Goal**: A person can run the probe on a rendition in their own browser and read honest Evidence, with no Node and no false green.
**Mode:** mvp
**Depends on**: Phase 8, Phase 11, Phase 12
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

### Phase 21: Capture and visual baselines
**Goal**: Pixel diffs run deterministically in a pinned container and a baseline can only ever be accepted by a person.
**Mode:** mvp
**Depends on**: Phase 2, Phase 20
**Requirements**: VIS-01, VIS-02, VIS-03, CI-02
**Provisional on:** Q9, Q29
**Success Criteria** (what must be TRUE):
  1. A PR runs visual-core (at most 40 renditions) in the pinned Playwright container with fonts ready, DPR 1, animations off, a ready attribute and a frozen clock, and a test asserts the effective thresholds.
  2. CI fails on a missing baseline, on a changed `git status`, and when the baseline set differs from the manifest; only a person running `bin/visual update` (selective, pinned platform) accepts baselines.
  3. Nightly and release runs cover the full set (at most 400) plus Firefox, WebKit and the LiveView `main` canary; the determinism self-test (identical hashes across three captures) blocks a release, and an open `quality-regression` issue blocks release PRs.
**Plans**: 4 (estimate)

### Phase 22: Sweep, Ratchet and verdicts
**Goal**: Every rendition in the manifest is checked at every standard size and scheme, findings can only shrink, and a person's verdicts are remembered.
**Mode:** mvp
**Depends on**: Phase 15, Phase 20, Phase 21
**Requirements**: CHECK-04, CHECK-06, A11Y-02, WB-12, WB-14
**Partial delivery**: WB-13 (the revision axis, current rendition against its committed Baseline; completes in Phase 29).
**Provisional on:** Q25
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The manifest-driven sweep covers 320/375/768/1280/1440 times light and dark, plus reduced motion, with fingerprinted findings, a PR that grows Known findings fails the Ratchet, and contact sheets publish as CI artifacts.
  2. A verdicts log in the repo records each finding's fingerprint, verdict and reason, and a rejected finding no longer appears in later reports or bundles.
  3. To review also lists findings without a verdict, the Diagnostics page shows evidence staleness, and Compare can show a rendition against its committed Baseline.
  4. The workbench chrome passes Fablebook's own sweep, and the nightly self-test history on `main` begins.
**Plans**: 4 (estimate)

### Phase 23: UX checks I - interaction states, forms, layout shift, RTL
**Goal**: A person can see and check interaction states, forms, loading shifts and right-to-left handling for any scenario.
**Mode:** mvp
**Depends on**: Phase 20, Phase 21
**Requirements**: UX-01, UX-02, UX-03, UX-04
**Spike first**: forcing `:hover` and `:focus-visible` without a mouse (CDP versus stylesheet rewriting on Tailwind v4 output) and measuring layout shift.
**Success Criteria** (what must be TRUE):
  1. Any scenario can be viewed in forced hover, focus-visible, active and disabled states without a mouse, and a check confirms each state differs from rest and that `phx-click-loading` is styled.
  2. Form checks report missing label association, missing `aria-invalid` or `aria-describedby`, errors shown before a field is touched (`used_input?`), missing autocomplete or inputmode, and placeholder-only labels.
  3. A scripted load reports layout shift, and a check reports skeletons whose size does not match the final content.
  4. A lint flags physical properties where logical ones belong (`ml-` instead of `ms-`), English-formatted numbers and dates under non-English locales, and `<time>` without `datetime`.
**Plans**: 4 (estimate)

### Phase 24: UX checks II, journeys and design.json
**Goal**: Destructive and feedback patterns are checked, Journeys are checked and shown as a filmstrip, and impeccable gets a design file made from rendered primitives.
**Mode:** mvp
**Depends on**: Phase 15, Phase 21, Phase 23
**Requirements**: UX-05, UX-08, JOURNEY-02, CANON-06
**Partial delivery**: JOURNEY-03 (the workbench filmstrip of a Journey's steps; the `journey` focus completes it in Phase 29).
**Provisional on:** Q27
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. A destructive dialog whose cancel is visually weaker than its confirm is flagged, and a glossary-based confirmshaming lint reports at the severity the owner chooses.
  2. Toasts must use a live region with the right politeness, never steal focus, last at least 5 s or be pausable, and be dismissable; modals trap focus and return it; focus survives a LiveView patch; every error state offers an action.
  3. A Journey step whose action is not an interactive element with that accessible name is a dead end, a mismatched label is copy drift, and across steps the Shell navigation must be identical and the same terms used for the same things.
  4. The workbench shows a Journey as a filmstrip of its steps.
  5. `.impeccable/design.json` is generated from tokens plus rendered primitives with an ownership header and a pinned schema, and Fablebook refuses to overwrite a file it does not own.
**Plans**: 5 (estimate)

### Family 8: Motion lane
*Phases 25 to 26.*

### Phase 25: Motion spike, time shim and Motion panel
**Goal**: A person can pause, scrub and slow every canvas animation and see a filmstrip, without the canvas disconnecting.
**Mode:** mvp
**Depends on**: Phase 8, Phase 12
**Requirements**: MOTION-01
**Provisional on:** Q18
**Spike first**: the virtual clock against real LiveView `JS` transitions.
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. The spike shows that the canvas heartbeat survives 60 s at 0.1x, that pause then resume completes a `JS.show` with `time:` exactly once, and that a `blocking: true` transition does not wedge patches.
  2. The Motion panel pauses and scrubs every canvas animation on a timeline and plays at 0.1x, 0.25x or 0.5x, labelled "Time shim active".
  3. A filmstrip shows the rendition at 0, 50, 100, 150, 200 and 300 ms plus the settled state.
**Plans**: 4 (estimate)

### Phase 26: Motion tokens, checks and CI lane
**Goal**: Motion is governed by canon tokens and strict checks, and seeked filmstrips are baselined in CI.
**Mode:** mvp
**Depends on**: Phase 14, Phase 21, Phase 25
**Requirements**: MOTION-02, MOTION-03, MOTION-04, MOTION-05, MOTION-06
**Provisional on:** Q9, Q17
**Success Criteria** (what must be TRUE):
  1. The canon has motion tokens whose strong default easing curves override Tailwind's weak default, and a computed duration or easing off the tokens is a finding.
  2. Strict motion checks flag `transition: all`, animated layout properties, ease-in on enter, `scale(0)`, UI motion over 300 ms unless tagged marketing, hover motion outside `(hover:hover)`, and anything that moves under reduced motion.
  3. LiveView motion lints flag a `JS` `time:` that differs from the CSS duration, `blocking: true` on a decorative transition, `JS.show` without `display:` on flex or grid, and `stream_delete` without an exit animation; a scenario's `motion_tier:` is linted against the frequency gate.
  4. A CI motion lane baselines and diffs seeked filmstrips while ordinary visual diffs keep animations off, and the reduced-motion custom variant is installable and checked by the doctor core.
**Plans**: 4 (estimate)

### Family 9: LLM context bundles and skills
*Phases 27 to 29. Phases 6 and 19 of this family execute earlier, as noted above.*

### Phase 27: Bundle browser tier and allocator
**Goal**: A person can opt in to browser capture and get a bundle that fits an LLM's budget, with every gap labelled.
**Mode:** mvp
**Depends on**: Phase 19, Phase 20, Phase 21
**Requirements**: LLM-02, LLM-03, LLM-04
**Success Criteria** (what must be TRUE):
  1. `--browser` adds PNG shots, `aria.yaml`, styles, measurements and a11y to each scenario's folder through the shared Capture pipeline; without Playwright it prints one canonical "needs Playwright (opt-in)" message and records not-run, and the no-browser level stays pure Elixir.
  2. The allocator offers summary, standard and full detail, tiles tall views by viewport height, switches to grid contact sheets past 20 images, and reports what it dropped.
  3. Stale or missing Evidence is labelled in the bundle and never shown as current, and the committed schema and size budgets still pass with the goldens re-recorded in a reviewed diff.
**Plans**: 4 (estimate)

### Phase 28: Focus framework, review focuses and gen.screens
**Goal**: A person can ask an LLM for one kind of feedback, and a greenfield project can scaffold its screens.
**Mode:** mvp
**Depends on**: Phase 15, Phase 27
**Requirements**: CORE-13
**Partial delivery**: LLM-08 (framework and the explore, critique, copy, a11y, layout, consistency and brand focuses; completes in Phase 29), SKILL-02 (digests for these focuses; completes in Phase 29).
**Success Criteria** (what must be TRUE):
  1. `--focus` accepts exactly one value from the closed list and rejects anything else, and a bundle's `BUNDLE.md` carries the rubric digest and reading order for explore, critique, copy, a11y, layout, consistency and brand.
  2. Draft stories and scenarios turn strict-rule errors into warnings and stay in To review, and `--focus explore` produces a bundle for them.
  3. `mix fablebook.gen.screens` scaffolds a Shell and one Draft Screen story per canon job in a greenfield project.
**Plans**: 4 (estimate)

### Phase 29: Compare, journey and motion focuses
**Goal**: The remaining three focuses work, every focus carries a credited digest, and the four agent skills exist.
**Mode:** mvp
**Depends on**: Phase 22, Phase 24, Phase 26, Phase 28
**Requirements**: LLM-08, WB-13, JOURNEY-03, MOTION-07, SKILL-02
**Partial delivery**: SKILL-01 (the four skills are authored here; installing them completes it in Phase 30).
**Provisional on:** Q25
**Success Criteria** (what must be TRUE):
  1. Compare shows renditions that differ in exactly one respect (a Global, a Theme or Direction, or the current rendition against its committed Baseline) at any tier, and `--focus compare` sends them to an LLM.
  2. `--focus journey` sends a whole Journey, with its steps, actions and screens in order.
  3. `--focus motion` provides `motion.json` (keyframes, timing, easing, 16 ms samples), a filmstrip contact sheet and reduced-motion frames, never video, and says that judging feel needs a person watching at 0.25x.
  4. Every focus in the closed list carries a short credited digest, rules live in checks with stable ids, and upstream skills (impeccable, ux-writing, review-animations, emil-design-eng) are named when installed and suggested as optional otherwise, never installed silently; the `fablebook`, `fablebook-review`, `fablebook-motion` and `fablebook-canon` skills are authored.
**Plans**: 4 (estimate)

### Family 10: Installer and DX
*Phases 30 to 32. Phase 10 of this family executes earlier, as noted above.*

### Phase 30: Generators, doctor shell and migrator
**Goal**: A person can generate a story, diagnose their setup, move off phoenix_storybook, and install the agent skills.
**Mode:** mvp
**Depends on**: Phase 10, Phase 29
**Requirements**: INST-02, INST-03, INST-04, SKILL-01
**Provisional on:** Q28
**Success Criteria** (what must be TRUE):
  1. `mix fablebook.gen.story Module.fun` writes a story from the component's Contract with its generated scenarios marked Draft and a TODO situation.
  2. `mix fablebook.doctor [--ci]` reports mount, `elixirc_paths`, scheme strategy, reduced-motion variant and CSP or `frame-ancestors` problems from a pure core, and exits non-zero under `--ci` when any is found.
  3. `mix fablebook.migrate.phoenix_storybook` converts a phoenix_storybook catalog (its Variation becomes a Scenario, its VariationGroup becomes a Group), and running it again changes nothing.
  4. The four skills install through `usage_rules` sync or `mix fablebook.skills.install`, version-stamped, and never overwrite a user's edits.
**Plans**: 4 (estimate)

### Phase 31: Image export, Docker demo and string check
**Goal**: A person can export a framed image of any scenario, try the demo in one command, and catch untranslated strings.
**Mode:** mvp
**Depends on**: Phase 18, Phase 21
**Requirements**: WB-16, INST-06, UX-07
**Success Criteria** (what must be TRUE):
  1. Export image and `mix fablebook.shot <scenario> --frame phone --scheme dark` produce a framed, high-resolution PNG, optionally on a background, and without Playwright print the canonical opt-in message.
  2. `docker compose up` runs the operator host demo with no database and pinned image digests, with Playwright baked in.
  3. For a Book that declares Gettext, the optional Credo check flags user-visible literal text in `~H` not wrapped in `gettext`, waivable with a reason such as a brand name.
**Plans**: 4 (estimate)

### Phase 32: Guides, docs brand and compatibility
**Goal**: An adopter can learn, upgrade and troubleshoot from the docs alone, and the docs carry Fablebook's brand.
**Mode:** mvp
**Depends on**: Phase 30, Phase 31
**Requirements**: DOCS-01, DOCS-02, DOCS-03
**Partial delivery**: INST-07 (the convention and helper are documented here; dogfooding in sigra completes it in Phase 35), DOCS-04 (applied to the docs site, README, Hex page and social card).
**Success Criteria** (what must be TRUE):
  1. The 12 ADR 0019 guides, the cheatsheets and `llms.txt` exist, and a test confirms each troubleshooting heading is a canonical error string.
  2. Comparison and migration content for phoenix_storybook and Storybook, security-model and limits sections, and an interaction-testing recipe are published.
  3. `UPGRADING.md` exists for the minor release, with a compatibility matrix and a deprecation policy.
  4. The docs site, README, Hex page and social card carry Fablebook's brand book from Phase 17, while the workbench chrome stays ink-on-neutral.
  5. A documented convention and a small helper let a library that generates UI into a host also generate host-owned Fablebook stories for it.
**Plans**: 5 (estimate)

### Family 11: Hardening and the full twin set
*Phases 33 to 34.*

### Phase 33: Hardening
**Goal**: The remaining deterministic gates, mutation floors and regression tests are in place, so quality cannot erode silently.
**Mode:** mvp
**Depends on**: Phase 32
**Requirements**: PERF-05, PERF-06, QA-02, QA-03, QA-05
**Provisional on:** Q15, Q19
**Success Criteria** (what must be TRUE):
  1. Host compile overhead stays at or under 15% with 500 stories in the nightly and release lane, touching one component recompiles at most one story, and adding a function to `CoreComponents` reports how many stories it recompiles.
  2. A sibling `bench/` project tracks p50, p99, p99.9 and max against committed reference measurements with sensitivity controls, and is advisory only.
  3. Muex runs weekly on the critical modules, score floors only go up, and a drop below a floor blocks the release PR.
  4. Igniter.Test goldens and idempotency tests, a clean-room tarball consumer, a tarball allowlist test and an API-surface snapshot (at most 25 public modules, Mix tasks included) pass.
  5. One regression test per phoenix_storybook footgun in CLEARANCE C2 exists under `test/regressions/`, and the security job runs `mix hex.audit`, OSV-Scanner and sobelow on the host apps.
**Plans**: 4 (estimate)

### Phase 34: Finanza and Shopadelic twins
**Goal**: The last two showcase products complete the set, and the white-label Theme and Guardrail path is exercised.
**Mode:** mvp
**Depends on**: Phase 22
**Requirements**: QA-06
**UI hint**: yes
**Success Criteria** (what must be TRUE):
  1. Finanza (es, bold numerics) and Shopadelic (fr, a Shopadelic-branded admin plus a white-label merchant storefront) each have an abracabrand-built brand book, a full canon, a Shell, Areas and Screens and a visually distinct style in `hosts/operator`.
  2. Merchant Themes in the storefront render, and an unreadable merchant colour surfaces as a Guardrail finding.
  3. All seven Books (three Logistify, Chatly, Finanza, Shopadelic, Clinicly) pass the canon lints and the sweep, and none of them is in the Hex tarball.
**Plans**: 4 (estimate)

### Family 12: Dogfood setup
*Phase 35. The clearance soak follows it and is checked by the milestone audit, not by a phase.*

### Phase 35: Dogfood setup
**Goal**: The owner's repos run Fablebook in CI so the 14-day clearance soak can start.
**Mode:** mvp
**Depends on**: Phase 30, Phase 34
**Requirements**: INST-07
**Provisional on:** Q2, Q22
**Success Criteria** (what must be TRUE):
  1. The mailglass demo and accrue_admin run on LiveView 1.2, with merged PRs that migrate every story they keep (via the migrator plus hand fixes) and a prune log (C1 evidence).
  2. sigra generates host-owned Fablebook stories through the convention helper, shown by a merged sigra PR.
  3. Both migrated repos run Fablebook in CI and are green, and one Fablebook PR merged green links the per-repo PRs as the phase evidence.
  4. A soak checklist records where each of C1 to C10 will be proven, ready for the milestone audit.
**Plans**: 4 (estimate)

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → ... → 35 (decimal insertions, if any, run between their surrounding integers).

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Release pipeline, CI gate and guards | 5/5 | In Progress | - |
| 2. Walking skeleton and runner spike | 0/4 | Not started | - |
| 3. Story model and catalog | 0/5 | Not started | - |
| 4. Render seam, rules engine and generated tests | 0/5 | Not started | - |
| 5. Controls and URL state | 0/4 | Not started | - |
| 6. Thin bundle slice | 0/3 | Not started | - |
| 7. Canvas isolation and containment | 0/5 | Not started | - |
| 8. Canvas diagnostics, hot reload and Globals | 0/4 | Not started | - |
| 9. Operator host, fidelity receipt and real components | 0/4 | Not started | - |
| 10. Installer core | 0/4 | Not started | - |
| 11. Chrome shell, sidebar, story page and grid | 0/5 | Not started | - |
| 12. Inspector, toolbar, palette and keyboard | 0/4 | Not started | - |
| 13. Mobile layout, QR, microcopy, Compare by Globals and Diagnostics | 0/4 | Not started | - |
| 14. Canon core | 0/4 | Not started | - |
| 15. Foundations, Themes, Directions, citations, coverage and To review | 0/5 | Not started | - |
| 16. Canon lints, tokens task and DESIGN.md | 0/4 | Not started | - |
| 17. Content track I - Fablebook brand book and the Logistify family | 0/4 | Not started | - |
| 18. Content track II - Chatly and Clinicly | 0/3 | Not started | - |
| 19. Bundle core with canon | 0/4 | Not started | - |
| 20. Probe, Evidence and the Checks tab | 0/5 | Not started | - |
| 21. Capture and visual baselines | 0/4 | Not started | - |
| 22. Sweep, Ratchet and verdicts | 0/4 | Not started | - |
| 23. UX checks I - interaction states, forms, layout shift, RTL | 0/4 | Not started | - |
| 24. UX checks II, journeys and design.json | 0/5 | Not started | - |
| 25. Motion spike, time shim and Motion panel | 0/4 | Not started | - |
| 26. Motion tokens, checks and CI lane | 0/4 | Not started | - |
| 27. Bundle browser tier and allocator | 0/4 | Not started | - |
| 28. Focus framework, review focuses and gen.screens | 0/4 | Not started | - |
| 29. Compare, journey and motion focuses | 0/4 | Not started | - |
| 30. Generators, doctor shell and migrator | 0/4 | Not started | - |
| 31. Image export, Docker demo and string check | 0/4 | Not started | - |
| 32. Guides, docs brand and compatibility | 0/5 | Not started | - |
| 33. Hardening | 0/4 | Not started | - |
| 34. Finanza and Shopadelic twins | 0/4 | Not started | - |
| 35. Dogfood setup | 0/4 | Not started | - |

Plan counts are estimates (146 in total); `/gsd-plan-phase` refines them, and a phase that needs more than 5 plans splits.
