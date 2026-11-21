---
phase: "8"
slug: "first-inspectable-book-and-local-host-path"
status: draft
nyquist_compliant: false
wave_0_complete: false
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

The focused command above is the existing production-guard contract. Add focused source, macro, catalog, and Story/Scenario commands to their requirement rows once the implementation chooses file paths. Do not run the full core lane for every task. Each reviewed PR still needs its own hosted required CI receipt on the exact head.

---

## Sampling Rate

- **After every task commit:** Run the focused source, compile, fixture, or host test that covers the changed requirement.
- **After each plan wave:** Run the relevant focused suite and production controls; run the full core lane at the planned phase/PR gates.
- **Before `$gsd-verify-work`:** The exact final PR head must have green required hosted CI, production controls must pass on the completed operator host, and the real-host browser pass must be complete.
- **Max feedback latency:** Aim for under 2 minutes for focused checks; measure the first candidate and keep full-lane runs out of per-task feedback.

---

## Per-Task Verification Map

Plan and task IDs are assigned by the Phase 8 planner. Replace `TBD` with the concrete IDs and focused command when the plan is finalized; keep this map aligned with every task's `<automated>` verification.

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| TBD | TBD | TBD | SRC-01 | — | No source claim or fixture value before source hash and citation checks pass | Unit/manifest | Command set when the minimal source subset and manifest are chosen | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | MOUNT-01 | See plan threat model | Reject computed AST before expansion; test only the public macro | Compile-time contract | Focused macro contract command set when its file is chosen | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | HOST-01 | See plan threat model | No production route or compiled Story/Book modules | Compile/fixture | `mix test test/contract/prod_guard_test.exs --include prod_guard` | ✅ existing fixture; operator host pending | ⬜ pending |
| TBD | TBD | TBD | HOST-02 | See plan threat model | Reachable prod mount raises canonical `CompileError` | Compile/fixture | `mix test test/contract/prod_guard_test.exs --include prod_guard` | ✅ existing fixture; operator host pending | ⬜ pending |
| TBD | TBD | TBD | CAT-01 | See plan threat model | Stable string URLs map only to the fixed Book; unknown selections are unavailable | Host integration | Focused catalog/navigation command set when the host test file is chosen | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | CAT-02 | See plan threat model | The same compiled Story/Scenario IDs resolve in dev/test; no dynamic loading | Compile/catalog | Focused dev/test catalog command set when the host test file is chosen | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | CANVAS-01 | See plan threat model | Same-origin Canvas uses the host pipeline, root layout, assets, and CSP | Browser integration | Real-host browser pass plus retained headers/network evidence | ❌ W0 | ⬜ pending |
| TBD | TBD | TBD | BOOK-01 | See plan threat model | Deterministic cited records/actions stay illustrative; no writes or persistence | Unit/render | Source/citation and Story/Scenario determinism commands set after source recovery | ❌ W0 | ⬜ pending |

---

## Wave 0 Requirements

- [ ] Add a reproducible, SHA-256-checked minimal source subset and citation manifest before authoring Book fixture content; the approved raw source bundle still must be located.
- [ ] Add the public mount macro contract and run its rejection assertion against the current router to capture the intended failure before implementation.
- [ ] Add focused catalog, Story/Scenario, render, URL, unknown-selection, and dev/test identifier checks.
- [ ] Extend the production fixture to retain positive route/Story exclusion and the negative reachable-mount compile control, then repeat both controls on the completed operator host.
- [ ] Provide the real-host browser pass and deterministic artifact without auto-accepting a new or changed visual baseline.
- [ ] Use the existing Phoenix and Elixir setup; no required Node installation or new runtime dependency.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Host Canvas fidelity, keyboard/focus behavior, labels, status text, narrow/desktop layout | CANVAS-01, CAT-01 | Browser behavior, inherited assets/CSP, and keyboard focus must be observed in the real host | Start the local host; inspect each screen at 320px and 1280px, test keyboard navigation and visible focus, verify labels/status and host CSS/JS/fonts/CSP, and capture the deterministic artifact. Do not accept a new or changed baseline automatically. |
| Any owner-only judgment on a new or changed visual baseline | CANVAS-01 | Baseline acceptance is a visual owner decision | Finish all objective work first; present the captured artifact and one concise decision request only if approval is actually required. |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all missing references
- [ ] No watch-mode flags
- [ ] Focused feedback latency measured against the 2-minute target
- [ ] `nyquist_compliant: true` set in frontmatter during validation closeout

**Approval:** pending
