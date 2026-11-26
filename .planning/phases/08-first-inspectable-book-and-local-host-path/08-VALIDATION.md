---
phase: "8"
slug: "first-inspectable-book-and-local-host-path"
status: validated
nyquist_compliant: false
wave_0_complete: true
created: "2026-11-20"
---

# Phase 8 — Validation Strategy

> Per-phase validation contract for the local Book, mount boundary, catalog, and Canvas path.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | ExUnit; Elixir/Phoenix host uses `mix` |
| **Config file** | `test/test_helper.exs`; operator-host test configuration is part of this phase |
| **Quick run command** | `mix test test/contract/prod_guard_test.exs --include prod_guard` |
| **Full suite command** | `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci` |
| **Estimated runtime** | About 8 minutes locally; v0.6's final core lane took 440.3 seconds in one sample. Measure each Phase 8 head; this sample does not establish a trend. |

The focused command above exercises the existing production-guard contract. The source, macro, catalog and Story/Scenario commands below bind the additional checks to their tasks. The actual host suite is `hosts/operator/test/operator_host_test.exs`; the two added rendering checks can also be run by test line for fast feedback. Run the full core lane at the implementation-only PR, test-only PR and final Book PR gates. Each reviewed PR needs its own required hosted CI receipt on the exact head.

After every completed CI run for the early macro PRs, record queue wait, critical path, job/step durations and repeated setup or work in [the CI performance ledger](../../CI-PERFORMANCE.md). Include a measured improvement or why a safe change is unsupported. Keep these receipts out of both early PR diffs and batch them with the next authorized substantive push.

---

## Sampling Rate

- **After every task commit:** Run the focused source, compile, fixture, or host test that covers the changed requirement.
- **After each plan wave:** Run the relevant focused suite and production controls; run the full core lane at the planned phase/PR gates.
- **Before `$gsd-verify-work`:** The exact final PR head must have green required hosted CI, production controls must pass on the completed operator host, and the real-host browser pass must be complete.
- **Max feedback latency:** Aim for under 2 minutes for focused checks; measure the first candidate and keep full-lane runs out of per-task feedback.

---

## Per-Task Verification Map

Task IDs follow each plan's task order. The red baseline entry runs the named test and asserts its expected diagnostic rather than treating an arbitrary test failure as success.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 08-01 | 1 | SRC-01 | T-08-01 | Original files are allowed and exact, or source-dependent work stops | Byte controls | `bin/verify_logistify_source --self-test`; `bin/verify_logistify_source --check-original .cache/brand_sources/logistify-brand` | Existing verifier | ✅ passed locally; see 08-01-SUMMARY.md |
| 08-01-02 | 08-01 | 1 | SRC-01 | T-08-01, T-08-SC | Seven public sources are commit-pinned, fetchable, ignored, and reused offline; core/floor CI cache them by lock hash | Fetch/cache contract | `bin/fetch_brand_sources --self-test`; `bin/fetch_brand_sources --update logistify-brand v1.0`; `bin/fetch_brand_sources`; rerun the fetcher for offline cache hits | Task adds fetcher, lock, ignore and CI steps | ✅ passed locally and in final hosted CI; see 08-01-SUMMARY.md and 08-05-SUMMARY.md |
| 08-01-03 | 08-01 | 1 | SRC-01 | T-08-01, T-08-02 | Public provenance and exact text/JSON excerpt bytes match the locked source and original file hashes | Byte/manifest | `bin/verify_logistify_source --check-pinned` | Task creates manifest and verifier contract | ✅ passed locally and on the completed candidate; see 08-01-SUMMARY.md and 08-05-SUMMARY.md |
| 08-02-01 | 08-02 | 1 | MOUNT-01 | T-08-03, T-08-04 | Current public macro reaches harmless expansion probe | Baseline red | `bash -c 'out=$(mix test test/contract/mount_literal_ast_test.exs --only mount_rejection_probe 2>&1); result=$?; printf "%s\n" "$out"; [[ "$result" -ne 0 && "$out" == *"disallowed Book macro expanded"* ]]'` | Task creates contract in isolation | ✅ expected diagnostic recorded against the unchanged original router; see 08-02-SUMMARY.md |
| 08-02-02 | 08-02 | 1 | MOUNT-01 | T-08-03, T-08-04 | Proposed router rejects before expansion and retains production diagnostic | Focused and PR gate | `mix test test/contract/mount_literal_ast_test.exs test/contract/prod_guard_message_test.exs`; `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci` | Authored and existing tests | ✅ focused tests, core lane, and exact-head hosted CI passed; see 08-02-SUMMARY.md |
| 08-03-01 | 08-03 | 2 | MOUNT-01 | T-08-05 | Exact test-only PR on hardened main | Focused and PR gate | `mix test test/contract/mount_literal_ast_test.exs test/contract/prod_guard_message_test.exs`; separately run the full core gate once | Authored and existing tests | ✅ focused contract and exact-head hosted CI passed; see 08-03-SUMMARY.md |
| 08-03-02 | 08-03 | 2 | HOST-01, HOST-02 | T-08-06 | Dev/test sentinel inclusion, clean positive prod and real reachable negative, indexed host-adapter ADR | Compile/fixture | `mix test test/contract/prod_guard_test.exs --include prod_guard`; `(cd test/fixtures/prod_guard_host && MIX_ENV=test mix run -e 'true = Enum.any?(Phoenix.Router.routes(GuardHostWeb.Router), &(&1.path == "/dev/fablebook")); :compiled = GuardHostWeb.SentinelStory.witness()')`; `(cd test/fixtures/prod_guard_host && MIX_ENV=dev mix run -e 'true = GuardHostWeb.SentinelStory.witness() == :compiled')`; ADR presence/index command in plan | Existing fixture plus sentinel and ADR | ✅ core/floor fixture checks and exact-head hosted CI passed; see 08-03-SUMMARY.md |
| 08-04-01 | 08-04 | 3 | HOST-01, CANVAS-01 | T-08-08, T-08-09, T-08-SC | Actual host root route runs through Phoenix. Bandit is audited and pinned only in the operator development host. Test runs without serving or the adapter. | Endpoint and dependency boundary | `(cd hosts/operator && MIX_ENV=test mix run -e 'conn = OperatorHost.Endpoint.call(Plug.Test.conn(:get, "/"), []); 200 = conn.status; true = conn.resp_body =~ "Operator host"; true = conn.resp_body =~ "data-operator-root"')`; host lock audit and test adapter exclusion commands in plan | Task creates host and development lock | ✅ host integration suite, dependency boundary and production controls passed; see 08-04-SUMMARY.md and 08-05-SUMMARY.md |
| 08-04-02 | 08-04 | 3 | SRC-01, CAT-01, CAT-02, CANVAS-01, BOOK-01 | T-08-07, T-08-08 | Compiled ordinary Scenario opens through actual catalog and Canvas | Host integration | `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)` | Task creates test | ✅ core/floor host suites passed; later 15-test route suite and exact-head hosted CI passed; see 08-04-SUMMARY.md and 08-05-SUMMARY.md |
| 08-04-03 | 08-04 | 3 | CAT-01, CAT-02, CANVAS-01 | T-08-07, T-08-08, T-08-09 | Exact compiled IDs, inherited root layout, same-origin asset path and catalog reachable at the development loopback URL | Host integration | `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)`; `(cd hosts/operator && MIX_ENV=dev mix compile --warnings-as-errors)`; loopback catalog command in plan | 08-04-02 test and host | ✅ host integration and dev compile passed; exact-head hosted CI passed; see 08-04-SUMMARY.md and 08-05-SUMMARY.md |
| 08-05-01 | 08-05 | 4 | SRC-01, CAT-01, CAT-02, CANVAS-01, BOOK-01 | T-08-07, T-08-11 | Complete fixed Story renders deterministically with provenance and precise UI states | Source/host integration | `bin/verify_logistify_source --check-pinned`; `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)`; focused additions: `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs:116 --warnings-as-errors)` and `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs:232 --warnings-as-errors)` | Host tests and source verifier; new cases in `hosts/operator/test/operator_host_test.exs` | ✅ source/host checks passed; new empty-Book and zero/one/many long-row tests each passed. Canvas JS lifecycle remains manual-only by INT-20261125-05. |
| 08-05-02 | 08-05 | 4 | HOST-01, HOST-02, CAT-02 | T-08-09, T-08-10 | Actual host excludes the feature and adapter in production and fails the reachable control. The Book PR contains no root dependency edits beyond the separately merged security prerequisite. | Compile/host | `bin/verify_operator_host_prod`; `mix test test/contract/prod_guard_test.exs --include prod_guard`; inspect root dependency diff against the security-only merged base | Actual-host checker and fixture controls | ✅ core/floor actual-host controls and exact-head hosted CI passed; see 08-05-SUMMARY.md |
| 08-05-03 | 08-05 | 4 | CANVAS-01, CAT-01, BOOK-01 | T-08-12, T-08-13 | Exact candidate review, real-host evidence and separately authorized delivery | Browser and PR gate | `git diff --check origin/main...HEAD`; `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci`; collect actual browser evidence per 08-05-03 | Existing Git/Mix and actual-browser evidence | ✅ actual-host browser evidence and exact-head required hosted CI passed; see 08-BROWSER.md and 08-05-SUMMARY.md |
| 08-06-01 | 08-06 | 5 | CANVAS-01 | T-08-14 | Both fixed Scenario responses render the approved persistent notice in a semantic footer outside `main` | Host integration | `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)` | `hosts/operator/test/operator_host_test.exs` | ✅ passed locally; see 08-06-SUMMARY.md |
| 08-06-02 | 08-06 | 5 | CAT-01, CANVAS-01 | T-08-15 | Catalog contrast, focus, targets, typography and spacing meet the UI-SPEC; the first Scenario fact fits at both mobile widths | CSS contract and browser geometry | `(cd hosts/operator && MIX_ENV=test mix test test/operator_host_test.exs --warnings-as-errors)`; Playwright at 320×900, 375×812 and simulated 200% text sizing | `hosts/operator/test/operator_host_test.exs`; live host at `/admin/dev/fablebook` | ✅ 19 host tests and browser geometry passed; see 08-06-SUMMARY.md |

---

## Wave 0 Requirements

- [x] Fetch the exact public brand commits from `brand_sources.lock.json`; keep their content in the ignored cache and add the minimal, hash-checked Logistify excerpt manifest before authoring Book fixtures. The source prerequisite does not hold the independent macro and fixture lane.
- [x] Add the public mount macro contract and run its rejection assertion against the current router to capture the intended failure before implementation.
- [x] Add focused catalog, Story/Scenario, render, URL, unknown-selection, and dev/test identifier checks. This validation pass also adds no-compiled-Book and zero/one/many long-row renderer checks.
- [x] Extend the production fixture to retain positive route/Story exclusion and the negative reachable-mount compile control, then repeat both controls on the completed operator host.
- [x] Provide the real-host browser pass and deterministic artifact without auto-accepting a new or changed visual baseline. The owner explicitly accepted the current baseline; see INT-20261125-04.
- [x] Use the existing Phoenix and Elixir setup with the audited Bandit listener pinned separately for the operator host in `:dev` only. Verify the Phoenix security change is isolated in its approved prerequisite PR, the Book PR adds no dependency changes, and no Node setup is needed.

---

## Browser and owner verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Host Canvas fidelity, keyboard/focus behavior, labels, status text, narrow/desktop layout | CANVAS-01, CAT-01 | Browser behavior, inherited assets/CSP, and keyboard focus must be observed in the real host | Run the local host in the background and open it in the owner's browser. Check 320, 375, 768 and 1280px and 200% text zoom. Record actual Canvas assets, CSP, keyboard and preview output in `08-BROWSER.md`; do not publish screenshot artifacts. |
| Canvas ready/failure status transition | CANVAS-01 | Owner-approved manual-only item. The owner accepted existing Chrome/UAT evidence as sufficient and said no new automated JavaScript transition test is requested in [INT-20261125-05](../../intent/sources/2026-11-25-05-accept-canvas-lifecycle-browser-evidence.md). The test suite does not execute these transitions. | Existing ready and injected-failure observations are recorded in [08-BROWSER.md](08-BROWSER.md) and [08-UAT.md](08-UAT.md). Status: SKIP automation by explicit owner decision; no additional test is implied. |
| Initial Scenario fact at narrow widths and focus at 200% text sizing | CAT-01, CANVAS-01 | The accepted scope is browser geometry, keyboard focus and content availability; measurements are recorded in the 08-06 summary | Playwright at `http://127.0.0.1:4003/admin/dev/fablebook`; 320×900, 375×812, then doubled computed text sizes in host and Canvas DOM | `08-06-SUMMARY.md` records first-fact coordinates, page/Canvas widths, link dimensions and visible focus. Screenshot artifacts are excluded. |
| Any owner-only judgment on a new or changed visual baseline | CANVAS-01 | Baseline acceptance is a visual owner decision | Finish objective work first, then use the live local Book at the end-of-milestone review. The owner decides whether to accept or reject the baseline; do not treat opening the Book as acceptance. |
| Final delivery of the cited source-derived candidate | SRC-01, BOOK-01 | Public citations and the minimal approved excerpt/Book content may appear in a reviewed public PR under INT-20261121-01; complete repos/assets stay in the ignored cache | Review the complete outbound diff and keep it within the approved subset. No private route or extra source-visibility decision is needed; deployment, release, and marketing claims remain excluded. |

---

## Source coverage audit

| Source | Required outcome or constraint | Plan | Status |
|--------|------------------------------|------|--------|
| ROADMAP goal and delivery sequence | Local compiled dispatcher flow, independent source check and ordered contract/implementation-only PR/test-only PR/fixture gates, then Book and completed-host proof | 08-01 through 08-05 | Covered |
| REQUIREMENTS | SRC-01 source custody, exact bytes and citations | 08-01, 08-04, 08-05 | Covered |
| REQUIREMENTS | MOUNT-01 literal caller AST and separately delivered contract | 08-02, 08-03 | Covered |
| REQUIREMENTS | HOST-01 and HOST-02 dev/test inclusion and positive/negative prod boundary | 08-03, 08-04, 08-05 | Covered |
| REQUIREMENTS | CAT-01 and CAT-02 fixed compiled catalog, same IDs and stable navigation with safe unknowns | 08-04, 08-05, 08-06 | Covered |
| REQUIREMENTS | CANVAS-01 actual same-origin Phoenix inherited Canvas and real browser | 08-04, 08-05, 08-06 | Covered |
| REQUIREMENTS | BOOK-01 one deterministic sourced dispatcher job and meaningful ordinary/edge situations | 08-01, 08-04, 08-05 | Covered |
| RESEARCH | Exact public source commits, preserved hashes, exact excerpt bytes, and no inferred claims | 08-01 and 08-04 dependency | Covered |
| RESEARCH | Public macro validation before resolution, canonical prod error and separate delivery | 08-02, 08-03 | Covered |
| RESEARCH | Existing fixture, actual endpoint, compile-path limits, plain functions, no runtime load or eval | 08-03, 08-04, 08-05 | Covered |
| RESEARCH | Minimal real host, audited host-only dev listener, optional browser and real layout/asset/CSP fidelity | 08-03, 08-04, 08-05 | Covered |
| CONTEXT | Minimal exact sourced subset, claim/fixture citations, open rights and approved vocabulary | 08-01, 08-04, 08-05 | Covered |
| CONTEXT | Literal AST, separate hosted CI, canonical compile timing and both production controls | 08-02, 08-03, 08-05 | Covered |
| CONTEXT | Neutral shell, preview-only sourced tokens, minimal navigation and safe selection | 08-04, 08-05 | Covered |
| CONTEXT | Cheap checks first, one actual browser pass and owner-only baseline acceptance | 08-01, 08-03, 08-04, 08-05 | Covered |
| UI-SPEC | 20 explicit states and one overflow backstop, with two non-blocking checker flags | 08-05, 08-06 | Covered by focused host and CSS checks plus browser geometry; lifecycle automation is the explicit manual-only exception in INT-20261125-05 |

API coverage and schema review found no external or audited API integration, new schema, or database. The catalog addresses only this fixed Book. Source provenance is locked, its three original file hashes and cited excerpts pass locally, and the source-derived limits are recorded in the manifest. The listener is supplied by the isolated development host lock. INT-20261121-01 authorizes the minimal public PR content; the complete repositories and assets stay ignored, and deployment/release remain excluded. The two-stage per-requirement recall kept 15 scope, safety and transparency prohibitions. All 15 are present as descriptor-less, flagged-unverified entries across the five plans. Routine layout and correctness cases are represented in the focused checks. Standard injection and cross-origin threats are owned by the phase threat models.

## Execution estimate

The revised projection is **69,500 calibrated tokens** from 139,000 raw using the measured 0.5 factor across 19 samples. The source and macro plans read only their relevant research and inputs, and the host plans use named sections instead of reloading the full research, pattern map, verification map and historical CI ledger. The development adapter and its audit are included in the revised estimate. Each execution record needs the command, result and evidence locator, with full logs read only when diagnosing a failure. The five plans still cover independent source custody, the two distinct macro PR gates, the first real host path and final browser/production delivery.

---

## Validation Sign-Off

- [x] All objective machine-checkable tasks have automated verify or Wave 0 dependencies; Canvas lifecycle transitions are the sole owner-approved manual-only exception.
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all missing references
- [x] No watch-mode flags
- [x] Focused feedback latency measured against the 2-minute target: both new tests completed individually in under one second of ExUnit runtime.
- [ ] `nyquist_compliant: true` set in frontmatter during validation closeout. It remains `false` because the owner accepted manual-only evidence for the JS lifecycle transition; this is an explicit, bounded exception, not automated coverage.

**Approval:** validated (partial) — all objective coverage gaps are green; the ready/failure transition remains manual-only by explicit owner decision.

## Validation Audit 2026-11-25

| Metric | Count |
|---|---|
| Gaps found | 3 |
| Resolved | 2 |
| Escalated | 0 |

## Validation Audit 2026-11-26

| Metric | Count |
|---|---|
| Gaps found | 0 |
| Resolved | 0 |
| Escalated | 0 |
