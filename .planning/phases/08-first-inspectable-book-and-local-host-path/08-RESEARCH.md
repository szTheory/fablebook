# Phase 8: First inspectable Book and local host path - Research

**Researched:** 2026-11-20
**Domain:** Elixir macros, Phoenix host routing/rendering, compiled Stories/Scenarios, local catalog and Canvas
**Confidence:** HIGH for existing repository behavior and locked architecture; MEDIUM for the yet-unimplemented Book/source subset

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Source grounding and content
- Use only the exact Logistify v1.0 text/token subset needed for this operator Book; make that subset reproducible in the reviewed repository and verify its recorded SHA-256 values before use.
- Tie each user-visible source claim and fixed fixture to its exact source file and section. Preserve the source's open name and asset-rights status; keep the fictional name and demo internal/local and do not import unreviewed artwork, sound, or fonts.
- Choose one source-supported dispatcher job, with one ordinary state and one meaningful source-supported edge or error state. Keep all data deterministic and fixed, use the approved Fablebook vocabulary and product-copy corrections, and do not invent logistics policy.

#### Mount and production boundary
- Accept only literal module alias/reference AST forms in the public mount macro; reject macro calls, variables, and other computed expressions before expansion.
- Keep the macro contract test and implementation in distinct PRs. The rejection test is authored first and checked against the proposed implementation locally; the hardened implementation PR and then the active test-only PR each receive their own green required hosted CI.
- Before Book code is added, run the positive production route/story exclusion checks and the negative reachable-mount compile control against the production-guard fixture. Repeat those checks against the completed operator host after Book implementation.
- Keep the canonical production mount error, current no-eval/no-input-atom rules, and existing CI gates intact. Do not add client-controlled module, code, atom, or topic selection.

#### Catalog and navigation
- Keep the Fablebook catalog chrome neutral and apply the approved Logistify text/token styling only in the preview.
- Provide only enough navigation to select the one Book, move between its two or three screens, and open each screen at a stable URL. Unknown screen selection resolves safely. Do not add broad workbench controls, an Inspector, a command palette, a grid, or a general Journey editor.
- Use the existing Elixir/Phoenix stack and no new Fablebook library or production/runtime dependency or required Node setup. The local host may add an isolated development/test adapter when necessary to serve the real Canvas. Keep the host free of Ecto/business services, persistence, and external writes.

#### Verification and visual evidence
- Start with source, citation, digest, fixture, vocabulary, and compile checks; then run focused catalog/render/navigation tests and production controls.
- Use one real-host browser pass for the host assets and CSP, keyboard navigation, focus, labels, text status, and representative narrow and desktop widths.
- Capture one deterministic visual artifact. Never accept a new or changed baseline automatically; finish all other work first and ask the owner only if that visual judgment is actually required.

### the agent's Discretion
- Choose the smallest screen count and navigation affordance that completely explains the source-supported dispatcher flow.
- Choose local module names, fixture shapes, implementation boundaries, and suitable checks while preserving the separate PR sequence and all approved limits.
- Reconcile ADR 0020's host description with the current repository before claiming host readiness; add only the smallest real host needed to exercise the actual Canvas path.

### Deferred Ideas (OUT OF SCOPE)
- Shipper and driver Books, complete Logistify brand canon, broader sourcebook asset application, and public brand or marketing claims.
- General-purpose workbench features, Controls, URL overrides, persistence, backend behavior, bundles, broad visual matrices, and follow-on milestone work.
- Owner approval of a new or changed screenshot baseline, if the implementation produces one that needs judgment; retain as the final visual handoff after all objective work is complete.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SRC-01 | Before the Book uses Logistify source content, the exact text/token subset is reproducible in the repository, version-pinned and SHA-256 checked; every cited content claim and fixture maps to its source file and section. | Source intake records source identities, hashes and section maps; current checkout lacks the underlying `docs/brand/logistify/` sources, so pin/copy only the required subset before authoring fixture/content. |
| MOUNT-01 | The public mount macro accepts only literal module alias/reference AST forms and rejects other expressions before expanding them; its contract tests and implementation land in separate PRs. | Current `fablebook/2` calls `Macro.expand/2`; roadmap requires the test-first rejection failure, implementation-only PR, then test-only PR with separate green hosted CI. |
| HOST-01 | A production build has no Fablebook route and no compiled Story or Book modules, while development and test can compile the fixed Book. | Extend existing fixture exclusion contract, then repeat against the actual operator host; current fixture already separates `storybook/` from prod `elixirc_paths`. |
| HOST-02 | A reachable production mount fails compilation with the canonical Fablebook production-mount error; a negative production control proves the rejection. | Preserve existing canonical message and negative unguarded fixture control, then repeat on operator host. |
| CAT-01 | A developer can start the local host, open the Fablebook UI catalog, select the single operator Book, and move through its two or three addressable screens using minimal navigation. | Existing route is placeholder-only; implement small host/catalog navigation per approved UI spec and safe unknown-screen branch. |
| CAT-02 | The operator Book is developer-authored and compiled from Fablebook Story/Scenario modules, appears in the catalog in development and test, and does not load stories dynamically or evaluate runtime input. | ADRs define ordinary compiled `storybook/` modules and pure catalog discovery; host fixture already compiles `storybook/` in non-prod. |
| CANVAS-01 | Each Book screen renders through the real host Canvas path in a same-origin iframe, inheriting the host pipeline and root layout with its CSS, JavaScript, hooks, fonts and CSP. | ADR 0003 requires the host pipeline/root layout Canvas path; only browser evidence can establish loaded host assets, CSP and layout behavior. |
| BOOK-01 | The Book presents one source-supported dispatcher job with a normal state and a meaningful source-supported edge or error state, deterministic fixed cited data, and visibly illustrative records and actions; it creates no persistent state or external writes. | Intake/research supports dispatcher voice/terms and fixed illustrative data but not a concrete source-backed dispatch policy; source subset must be inspected and pinned before selecting exact state/content. |
</phase_requirements>

## Summary

Plan Phase 8 in two guarded stages. First carry out the exact mount-contract and production-boundary delivery sequence already approved in the roadmap. Only after the hardened router and active contract test are merged with green required CI, and the existing production fixture proves both route/story exclusion and reachable-mount rejection, add the Book/host/catalog/Canvas implementation. The requirements explicitly demand repeating the production controls against the completed host. [VERIFIED: `.planning/ROADMAP.md:17-33,39-43`; `.planning/phases/08-first-inspectable-book-and-local-host-path/08-CONTEXT.md`]

The current tree contains only `Fablebook.Router`, a placeholder Plug, and a production-guard fixture; it has no catalog, `Fablebook.Story`, Canvas, host app, or authored Book implementation. Existing architecture decisions already settle the intended direction: Stories are compiled modules under host `storybook/`, Scenarios are ordinary functions, and Canvas rendering stays in a same-origin iframe inheriting the host pipeline and root layout. Keep the catalog small and fixed, use the Phoenix host's real assets/CSP, and avoid introducing runtime services or input-driven module lookup. [VERIFIED: `lib/fablebook/router.ex:24-40`; `lib/fablebook/placeholder.ex:1-14`; `docs/adr/0001-stories-are-compiled-modules.md`; `docs/adr/0002-scenarios-are-plain-functions.md`; `docs/adr/0003-iframe-canvas-through-host-pipeline.md`]

**Primary recommendation:** treat the macro hardening, the existing fixture controls, and source pinning as prerequisites; then build the smallest real local host around fixed compiled Story/Scenario modules, a pure catalog, stable screen URLs, and the accepted Canvas iframe path. Do not plan a generic workbench or logistics application. [VERIFIED: `.planning/ROADMAP.md:39-43`; `.planning/research/2026-11-20-next-milestone-scope-review.md`]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Public mount macro and route definition | API / Backend | — | Elixir macro expansion and Phoenix route registration happen at compile time in the host router. |
| Fixed Story/Scenario declarations and catalog | API / Backend | Database / Storage — | Compiled modules and a pure catalog determine available screens; no persistence is in scope. |
| Local catalog shell and screen navigation | Frontend Server (SSR) | Browser / Client | The Phoenix host serves HTML and stable URLs; browser navigation is ordinary links/forms, with no arbitrary client-selected module. |
| Canvas content and host fidelity | Frontend Server (SSR) | Browser / Client | The host renders the screen using its root layout and assets; browser verification checks iframe, CSS/JS/fonts and CSP. |
| Production exclusion | API / Backend | — | Compile-time environment paths and the reachable-mount macro guard own whether route/story modules can enter prod. |

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Elixir / Mix | Repo floor `~> 1.18`; workstation observed Elixir 1.20.4 on OTP 29 | Compiled Story/Scenario modules, Phoenix host, macros, Mix tests | Existing repo toolchain and ADRs require the Elixir/Phoenix architecture. Source declares `elixir: "~> 1.18"`. [VERIFIED: `mix.exs:6-15`; `docs/adr/0001-stories-are-compiled-modules.md`] |
| Phoenix | Repo declaration `>= 1.8.9 and < 2.0.0`; current lock pins 1.8.16 | Host router, plug/controller/LiveView render and root layout | Existing dependency and accepted host integration. Lock source: `"phoenix": {:hex, :phoenix, "1.8.16"`. Follow project/host lock rather than selecting a new framework. [VERIFIED: `mix.exs:40-51`; `mix.lock:16`] |
| Phoenix LiveView | Repo declaration `>= 1.2.9 and < 2.0.0`; current lock pins 1.2.14 | Live host navigation/render path if required by the selected screen flow | Existing dependency and accepted Story/Scenario decisions. Lock source: `"phoenix_live_view": {:hex, :phoenix_live_view, "1.2.14"`. [VERIFIED: `mix.exs:40-51`; `mix.lock:18`; `docs/adr/0002-scenarios-are-plain-functions.md`] |
| Phoenix HTML | Repo declaration `~> 4.1`; current lock pins 4.4.0 | HEEx and route pipeline | Reuse existing host stack; lock source: `"phoenix_html": {:hex, :phoenix_html, "4.4.0"`. [VERIFIED: `mix.exs:40-51`; `mix.lock:17`] |
| Phoenix HTML / Plug | Existing transitive/project host stack | HEEx and route pipeline | Reuse Phoenix host stack; do not add UI packages. [VERIFIED: `mix.exs:40-51`; `docs/adr/0003-iframe-canvas-through-host-pipeline.md`] |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| ExUnit / Phoenix.LiveViewTest | Existing Elixir toolchain | Pure catalog/render/navigation assertions and LiveView behavior | Use for deterministic behavior; reserve a browser for host asset/CSP/layout claims. [CITED: `.planning/research/2026-11-20-ui-roadmap-primary-sources.md`; `docs/adr/0011-browser-runner.md`] |
| `phoenix_test_playwright` | Optional dev/test package per ADR 0011; no new dependency approved | Real-host browser and screenshot evidence | Use only if already available in the host/test harness; this phase does not authorize making it a runtime or required Node dependency. [VERIFIED: `docs/adr/0011-browser-runner.md`; `docs/adr/0018-dependency-budget.md`] |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Existing Fablebook compiled Story/Scenario + Canvas | Direct static host route or screenshot mock | Faster isolated render, but it does not prove the catalog, compiled module, or accepted Canvas path required by the roadmap. [VERIFIED: `.planning/ROADMAP.md:27-33`; `.planning/research/2026-11-20-ui-roadmap-primary-sources.md`] |
| Minimal fixed Phoenix navigation | General workbench with controls/grid/command palette | Broader features add input/state surface excluded from this milestone. [VERIFIED: `08-CONTEXT.md`, `08-UI-SPEC.md`] |

**Installation:** Install the listener only in the separate operator host's development environment. Keep the Fablebook dependency declarations and both root locks intact. Existing Phoenix endpoint tests can run without a listener. [Bandit Phoenix adapter documentation](https://bandit.hexdocs.pm/1.12.4/Bandit.PhoenixAdapter.html)

## Package Legitimacy Audit

Verified publisher records, released versions, build requirements and dependency metadata in the official Hex registry. These releases are compatible with the project's Elixir floor and shared Plug, Telemetry and WebSock pins. The returned release metadata listed no advisories or retirements at plan review. Refresh that evidence and audit the resolved host lock at installation time.

| Package | Version and scope | Status | Evidence |
|---------|-------------------|--------|----------|
| `bandit` | `1.15.0`; one direct dependency, `hosts/operator` only, `only: :dev` | VERIFIED | [Hex release](https://hex.pm/packages/bandit/1.15.0), [requirements](https://hex.pm/packages/bandit/1.15.0/dependencies) |
| `hpax` | `1.1.0`; required by Bandit, host development lock only | VERIFIED | [Hex release](https://hex.pm/packages/hpax/1.1.0) |
| `thousand_island` | `1.6.0`; required by Bandit, host development lock only | VERIFIED | [Hex release](https://hex.pm/packages/thousand_island/1.6.0) |

## Architecture Patterns

### System Architecture Diagram

```text
Developer opens local host URL
        │
        ▼
Phoenix host router ── compile-time dev/test mount ──► Fablebook catalog
        │                                               │ fixed Book/Story IDs
        │                                               ▼
        │                                      compiled Story/Scenario modules
        │                                               │ fixed fixture data
        ▼                                               ▼
Host endpoint + root layout ◄── same-origin Canvas iframe ◄── selected screen
        │
        └── production build: no mount route or Story/Book beams
```

The catalog selection and screen URL must resolve only against a compile-time known Book and Story/Scenario map; unknown strings take the UI spec's safe unavailable state. The iframe is same-origin and uses the host's regular pipeline/root layout; do not create a separate static preview endpoint that bypasses it. [VERIFIED: `docs/adr/0003-iframe-canvas-through-host-pipeline.md`; `docs/adr/0008-catalog-discovery-and-ids.md`; `08-UI-SPEC.md`]

### Recommended Project Structure

```text
hosts/operator/
├── lib/                       # minimal Phoenix host, router, root layout, catalog/Canvas UI
└── storybook/                 # fixed compiled Book, Story/Scenario modules and fixtures

test/fixtures/prod_guard_host/  # existing dev/test-positive and prod-positive/negative controls
lib/fablebook/router.ex        # public mount macro boundary
lib/fablebook/placeholder.ex   # current placeholder route target to replace/integrate
```

`hosts/operator/` is an architectural recommendation from ADR 0020, but it is absent from the current reviewed tree; ADR 0020 describes a larger adversarial host. The discretion clause explicitly calls for the smallest real host needed for this Canvas proof, so plan a scope reconciliation rather than silently implementing the full ADR 0020 checklist. [VERIFIED: `docs/adr/0020-host-apps-dogfood.md`; `08-CONTEXT.md`; `08-UI-SPEC.md`]

### Pattern 1: Restrict macro AST before expansion

**What:** Inspect the caller-supplied Book AST and accept only literal module alias/reference shapes before any macro expansion. Current dev/test code calls `Macro.expand(book, caller_env)` directly at `lib/fablebook/router.ex:35`, so a macro-call expression can execute during expansion before the mount is registered. Preserve the prod error branch and generated mount behavior while narrowing only this public argument boundary. [VERIFIED: `lib/fablebook/router.ex:24-40`; [Elixir Macro.expand/2 docs](https://hexdocs.pm/elixir/1.18.1/Macro.html#expand/2)]

**When to use:** Before this macro is used by the local host or any Book mount.

**Example (existing literal mount form):**

```elixir
fablebook "/fablebook", GuardHostWeb.Storybook
```

This is the current fixture's literal module alias mount form. The eventual contract must also cover the accepted literal module reference form, and verify invalid macro-call and variable forms are rejected before expansion. [VERIFIED: `test/fixtures/prod_guard_host/lib/guard_host_web/router.ex:8-13`; `.planning/ROADMAP.md:29-30`]

### Pattern 2: Keep host Stories compiled and excluded in prod

**What:** Host Mix project compiles `storybook/` only outside production; production `elixirc_paths` remains `lib` only. ADR 0001 requires host-owned compiled `.ex` modules, not runtime `.exs` compilation or `test/support` (which is unavailable in dev). [VERIFIED: `test/fixtures/prod_guard_host/mix.exs:24-28`; `docs/adr/0001-stories-are-compiled-modules.md`]

**When to use:** For the fixed Book and fixture Stories in the operator host and the production guard fixture.

### Pattern 3: Keep catalog and navigation deterministic

**What:** Build catalog from the compiled known Story modules and use stable IDs/URLs; route strings are matched to known entries and do not become module names. Keep screen data as fixed compiled fixture values. ADR 0008 describes module/function-derived identifiers and building the catalog as a pure function; Phase 8 narrows this to one Book and two or three screens. [VERIFIED: `docs/adr/0008-catalog-discovery-and-ids.md`; `08-CONTEXT.md`]

**When to use:** To make dev and test expose the same IDs while safely handling unknown URLs.

### Anti-Patterns to Avoid

- **Calling `Macro.expand/2` on arbitrary mount input:** it expands caller macros; reject non-literal AST before expansion. [VERIFIED: `lib/fablebook/router.ex:34-40`; [Elixir Macro docs](https://hexdocs.pm/elixir/1.18.1/Macro.html#expand/2)]
- **Putting contract tests and macro implementation in one PR:** violates ADR 0021; follow roadmap's staged PR sequence. [VERIFIED: `docs/adr/0021-delivery-rules.md`; `.planning/ROADMAP.md:39-43`]
- **Adding Story sources under `lib/` or runtime-evaluating them:** risks production inclusion and reintroduces runtime code execution; use compiled host `storybook/` modules. [VERIFIED: `docs/adr/0001-stories-are-compiled-modules.md`; `docs/adr/0004-no-eval-no-new-atoms.md`]
- **Treating `/dev` or a dev path name as the production boundary:** prove compile-time route absence and Story/Book beam exclusion, plus the reachable negative control. [VERIFIED: `test/contract/prod_guard_test.exs:13-34`; `docs/adr/0006-dependency-available-in-all-envs.md`]
- **Showing a direct page instead of Canvas:** this misses the required host-layout/assets/CSP integration. [VERIFIED: `docs/adr/0003-iframe-canvas-through-host-pipeline.md`; `.planning/ROADMAP.md:33`]
- **Using sourcebook product recommendations as proven logistics behavior:** the intake labels layouts/recommendations as recommendations; choose only claims backed by the inspected, pinned source subset. [VERIFIED: `.planning/references/logistify-brand-intake.md:36-43`; `.planning/research/2026-11-20-next-milestone-scope-review.md`]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Scenario rendering and HTML escaping | A string-to-HEEx template/eval path | Compiled Phoenix function components and Scenario functions | Avoid runtime evaluation and keep slots/data in the established Elixir model. [VERIFIED: `docs/adr/0002-scenarios-are-plain-functions.md`; `docs/adr/0004-no-eval-no-new-atoms.md`] |
| Asset/CSP fidelity | A separate story CSS/JS bundle or hand-built preview endpoint | Host pipeline/root layout inside the Canvas iframe | Host CSS, JavaScript, hooks, LiveSocket, CSRF, CSP and fonts are the fidelity requirement. [VERIFIED: `docs/adr/0003-iframe-canvas-through-host-pipeline.md`] |
| Catalog module discovery | Runtime input-to-module construction | Fixed compiled catalog/module set | Compile-time Story metadata and fixed IDs avoid arbitrary module selection. [VERIFIED: `docs/adr/0008-catalog-discovery-and-ids.md`; `docs/adr/0004-no-eval-no-new-atoms.md`] |

**Key insight:** Phase 8's value is the complete path from compiled Story to a real host Canvas. Any screenshot-only or direct-route shortcut would leave its main architecture requirement unproven. [VERIFIED: `.planning/ROADMAP.md:27-33`]

## Common Pitfalls

### Pitfall 1: Contract failure caused by wrong assertion, not macro expansion

**What goes wrong:** The initial rejection contract test fails, but not because the macro accepted and expanded a forbidden expression.
**Why it happens:** Macro behavior is compile-time; tests must exercise the real public macro with a harmless local macro fixture and distinguish reaching the forbidden macro from an unrelated compiler error.
**How to avoid:** Record the intended baseline failure against current main: forbidden expression reaches `Macro.expand/2`; then run the exact same rejection test against the proposed implementation locally. Keep this test file out of the implementation PR. [VERIFIED: `.planning/ROADMAP.md:39-43`; `lib/fablebook/router.ex:34-40`]
**Warning signs:** Test only inspects strings or uses a hand-written AST rather than compiling through `Fablebook.Router.fablebook/2`.

### Pitfall 2: Prod guard appears green while the host Story compiled into prod

**What goes wrong:** Route output is clean but Book/Story beams still exist, or the negative control does not make the mount reachable.
**Why it happens:** Route enumeration and beam exclusion are separate claims; fixture's existing `elixirc_paths(:prod)` specifically excludes `storybook/`, and its unguarded route is only compiled when `FABLEBOOK_UNGUARDED` is set. [VERIFIED: `test/fixtures/prod_guard_host/mix.exs:24-28`; `test/contract/prod_guard_test.exs:19-34`]
**How to avoid:** Preserve both positive checks and the reachable-mount negative control on the known-good fixture before Book work; repeat with the actual operator Book after implementation. Clean env-specific builds before inspecting generated beams. [VERIFIED: `test/contract/prod_guard_test.exs:13-34`]
**Warning signs:** Checking only `mix phx.routes`, relying on the path name, or omitting Story/Book source inspection.

The existing test's canonical first line is exactly `"Fablebook cannot be mounted in a prod build"`; preserve it byte-for-byte. [VERIFIED: `test/contract/prod_guard_test.exs:9-11`; `lib/fablebook/router.ex:44-49`]

### Pitfall 3: Fixture content outruns source evidence

**What goes wrong:** A dispatcher flow presents invented statuses, actions, timestamps, or business rules as Logistify behavior.
**Why it happens:** The checked-in intake is a summary and explicitly says source layouts are recommendations; the raw source was not present in the reviewed tree. Existing intake hashes date from 2026-11-10 and must be rechecked before consumption. [VERIFIED: `.planning/references/logistify-brand-intake.md:12-22,36-43`; `.planning/research/2026-11-20-next-milestone-scope-review.md`]
**How to avoid:** Retrieve the approved source through the authorized read-only path, copy only the approved text/token subset into the reviewed repository, verify recorded hashes, then cite each Book claim/fixture field to source filename and section. Make no new logistics policy inference. [VERIFIED: `08-CONTEXT.md`; `.planning/ROADMAP.md:31,39-43`]
**Warning signs:** Citing only the summary intake, relying on a stale hash without recalculation, or using candidate state names from broad twin research as a source claim.

### Pitfall 4: Canvas is same-origin in markup but not using host layout/assets

**What goes wrong:** iframe exists, but its document misses host CSS/JS, hooks, fonts or CSP, so it does not prove fidelity.
**Why it happens:** A separate controller/layout or copied asset bundle bypasses the established host path.
**How to avoid:** Use the Canvas route through the host pipeline and inherited root layout; inspect real browser network/document headers and keyboard behavior once. [VERIFIED: `docs/adr/0003-iframe-canvas-through-host-pipeline.md`; `.planning/ROADMAP.md:33`]
**Warning signs:** Server-rendered HTML tests reported as proof of browser font/CSP behavior, a sandbox-specific CSS override, or copied Fablebook JS.

## Code Examples

Current fixture's public macro mount, which is the positive literal-alias shape to preserve:

```elixir
if Application.compile_env(:guard_host, :dev_routes) do
  scope "/dev" do
    import Fablebook.Router
    fablebook "/fablebook", GuardHostWeb.Storybook
  end
end
```

Source: `test/fixtures/prod_guard_host/lib/guard_host_web/router.ex:8-13`. The implementation plan should add contract cases for accepted module alias/reference literals and forbidden macro-call/variable/computed forms; do not copy an implementation recipe until that actual macro contract has been reviewed.

Current fixture compile-path split:

```elixir
defp elixirc_paths(:prod), do: ["lib"] ++ if(System.get_env("FABLEBOOK_UNGUARDED"), do: ["unguarded"], else: [])
defp elixirc_paths(_), do: ["lib", "storybook"]
```

Source: `test/fixtures/prod_guard_host/mix.exs:24-28`. Keep this test fixture's unguarded prod control and the known-good compile paths intact when adding an operator host.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|-------------|-----------|---------|----------|
| Elixir/Mix | Compile, host, ExUnit | ✓ | Elixir 1.20.4 / OTP 29 observed locally | None needed |
| Phoenix/LiveView deps | Host router, LiveView and Canvas | Declared in project; operator-host dependency/build not present | Project declarations `phoenix >=1.8.9,<2`; `phoenix_live_view >=1.2.9,<2` | Use the repo lock/approved host lock; no alternate stack |
| Phoenix server adapter | Start a browser-reachable loopback endpoint | Neither Bandit nor Plug.Cowboy is installed by the reviewed root locks | Bandit 1.15.0 is scoped to the operator host's development lock | Install with Mix in that host; endpoint assertions and production controls run without HTTP serving |
| Browser runner | Real-host iframe/CSP/layout and visual artifact | Optional tooling only; no browser setup verified in this research | — | Existing manual real-browser pass if optional runner unavailable; do not add required Node setup |
| `act` | Local workflow attempt before hosted CI when feasible | Installed, but saved evidence records an architecture mismatch (ARM64 OTP inside requested amd64 container) | Prior recorded `act` 0.2.87 | Preserve known stop; hosted required CI remains authoritative unless cause changes |

**Missing dependencies with no fallback:** None identified for core Elixir work. A browser tool must be available for browser-only host fidelity claims; if absent, planner should include an environment/setup checkpoint using existing optional tooling rather than adding a project runtime dependency. [VERIFIED: `.planning/CI-PERFORMANCE.md` Local act preflight; `docs/adr/0011-browser-runner.md`; `docs/adr/0018-dependency-budget.md`]

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | ExUnit; host uses `mix` and Phoenix dependencies |
| Config file | `test/test_helper.exs`; no existing app/host test config is present |
| Quick run command | `mix test test/contract/prod_guard_test.exs --include prod_guard` |
| Full suite command | `HEX_HOME="$PWD/_build/hex-home" MIX_ENV=test bin/lane core mix ci` (existing verified core-lane command); hosted required CI is still required for each PR |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MOUNT-01 | Public macro accepts alias/reference literal and rejects forbidden forms before expansion | Compile-time contract | Focused contract file command to be added to repo test target; no file exists yet | ❌ Wave 0 |
| HOST-01 | Dev/test mount and Story compile; prod route and Story/Book beams absent | Integration/compile | `mix test test/contract/prod_guard_test.exs --include prod_guard` | ✅ Existing fixture contract; extend for operator host |
| HOST-02 | Reachable prod mount raises canonical CompileError | Integration/compile | Same `prod_guard` contract command | ✅ Existing fixture negative control; repeat on operator host |
| SRC-01 | Required source subset digest and citations match committed manifest | Unit/contract | Add a fast source subset verification task/test; command TBD until implementation shape is chosen | ❌ Wave 0 |
| CAT-01 | One Book selection, stable screen URLs, safe unknown screen, return/navigation links | LiveViewTest/browser smoke | Focused host catalog test command after host app exists | ❌ Wave 0 |
| CAT-02 | Compiled fixed Story/Scenario resolves same identifiers in dev/test; no runtime loading | Compile/catalog contract | Focused catalog test in host dev/test envs | ❌ Wave 0 |
| CANVAS-01 | Same-origin iframe loads host root layout, assets and CSP | Browser/manual integration | One real-host browser pass; retain screenshot and inspect CSP/network/keyboard | ❌ Wave 0 |
| BOOK-01 | One source-cited ordinary and source-supported edge/error screen; deterministic fixed records, no writes | Unit/render + browser | Focused fixture/renderer determinism checks then real-host pass | ❌ Wave 0 |

### Sampling Rate

- **Per task commit:** source/format checks or focused module/fixture test for changed layer.
- **Per wave merge:** compile, focused host catalog/render tests, and relevant production contract.
- **Phase gate:** full required hosted CI green on exact final PR head; run actual-host production controls and one real-host browser pass before declaring complete.

### Wave 0 Gaps

- [ ] Add real host app and start command consistent with ADR 0020's minimal-host discretion.
- [ ] Add executable macro contract; run against current router first and capture the expected rejection failure; later land the test-only PR against hardened main.
- [ ] Add source subset/checksum and exact citation verification before fixture content.
- [ ] Add catalog/Story/Scenario/render/navigation tests; ensure dev and test IDs match and unknown routes resolve safely.
- [ ] Add operator-host prod route/story-beam positive exclusion and reachable-mount negative control, first before Book implementation then repeated after it.
- [ ] Provide one real-browser check and deterministic artifact without auto-accepting a baseline.

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | No | Local developer-only host and no user accounts in this scope; do not add auth/business services. |
| V3 Session Management | Yes (host-managed) | Keep the host's existing Phoenix session/LiveView connection behavior; do not create a separate Canvas session mechanism for this fixed local preview. |
| V4 Access Control | Yes | Compile-time prod guard, dev/test-only story paths, positive route/beam exclusion and negative reachable mount control. |
| V5 Input Validation | Yes | Treat Book/screen URL segments as strings matched to the fixed catalog; unknown entries display unavailable; never construct modules/atoms/eval from request input. |
| V6 Cryptography | No | No new secrets, tokens or cryptographic protocol in this fixed local slice. |

### Known Threat Patterns for Elixir/Phoenix

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Caller-supplied macro AST triggers expansion before validation | Elevation of Privilege | Validate allowed literal AST forms in macro body before expansion; test harmless macro call using actual public macro. |
| Request-selected Book/module/screen creates dynamic dispatch | Tampering / Elevation of Privilege | Resolve string IDs against fixed compiled catalog; safe unavailable result for misses. |
| Story source enters production build | Information Disclosure / Elevation of Privilege | Keep `storybook/` out of prod `elixirc_paths`; assert no routes or Story/Book beam sources in prod build. |
| Action-looking fixture implies live dispatch or external writes | Spoofing / Repudiation | Persistent plain-text illustrative notice, non-operational actions, deterministic local fixtures; no persistence or outbound integrations. |

`security_enforcement` is enabled in `.planning/config.json`; research therefore keeps the security section and treats compile exclusion/input matching as acceptance checks. [VERIFIED: `.planning/config.json`; `docs/adr/0004-no-eval-no-new-atoms.md`; `docs/adr/0006-dependency-available-in-all-envs.md`]

## Project Constraints (from AGENTS.md)

- Read and follow `CLAUDE.md`; project intent/ADRs outrank requirements and project summaries.
- Use the canonical planning checkout `~/projects/fablebook` on `main`; preserve the dirty historical worktrees and do not reset, stash, clean or remove them.
- Keep `STATE.md` and `ROADMAP.md` as canonical planning owners; never hand-edit generated `.planning/state.json`. Refresh the projection after canonical repairs and lifecycle commit boundaries.
- Keep one global sequence of ordinary integer phase numbers; Phase 8 remains the active v0.7 phase.
- Preserve exact separate-PR contract-test/implementation order and existing compile-time production guard; no runtime eval or atoms from input.
- Keep dependency budget and no-adopter-Node requirement; changes to CI must preserve all existing gates.
- Run `bin/planning_health --stage plan --phase 8` before planning-state mutation; it passed with no errors in this research session.
- Phase delivery requires reviewed merged PR and green hosted CI on the exact candidate head; owner has standing authorization to push reviewed candidates, open/update PRs and squash-merge when branch protection permits, so do not pause on routine approvals.
- Append the actual v0.7 delivery receipt after merge and carry receipt bookkeeping on the next substantive push; do not report planning repair as implementation delivery.
- Keep the aggregate guard open, the original `walking-skeleton` key blocked, and the approved first-Book exception scoped to this milestone only.
- Never auto-accept visual baselines; finish objective checks before requesting a human visual judgment.
- End workflow handoffs with the concrete next action and who acts next; continue authorized work without asking for acknowledgments, and stop at the milestone boundary or a genuinely new material risk.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The smallest compatible implementation keeps Fablebook's production/runtime dependency set unchanged. A separate host-only development/test listener may be used when technically necessary. | Standard Stack | A browser cannot reach a Phoenix endpoint with no listener. The identified gap requires Bandit as `:dev` only in `hosts/operator`; its test and production lanes stay adapter-free. |
| A2 | The saved source intake's recorded file paths still identify the approved original source bundle, which can be retrieved from its preserved read-only source location. | Common Pitfalls | If the source cannot be recovered, exact source subset and Book content cannot be verified; do not proceed using summary claims alone. |
| A3 | The optional browser tool can run against the new host in this environment or be made available through the already approved optional test tooling. | Environment Availability | If unavailable, CANVAS-01's actual browser fidelity claims cannot be established. |

## Open Questions (RESOLVED)

1. **Raw Logistify v1.0 source recovery — RESOLVED as a read-only checkpoint.** The exact bundle location and its current bytes remain unknown. The reviewed checkout and known brand-intake worktree lack the originals, and the intake records three approved path and SHA-256 pairs. Plan 08-01 checks only an identified read-only location against all three hashes. If it cannot recover the bundle, stop Book content and request the exact owner-supplied path or read access. Plans 08-02 and 08-03 proceed independently. [Source intake](../../references/logistify-brand-intake.md)
2. **Dispatcher job and edge — RESOLVED as a source-dependent selection.** The exact supported job and meaningful edge or error situation remain unknown. Plan 08-01 selects both only after fresh whole-file SHA-256 verification and review of the exact approved sections. Map each claim and fixture field to the pinned filename/section. If the approved bytes support no complete flow, stop Book content and identify the evidence needed. Candidate states in the wider twin research do not establish a Logistify claim.
3. **Operator host scope — RESOLVED.** Use a single loopback Phoenix endpoint/router with its actual browser pipeline, root layout, local CSS/JavaScript, system fonts, LiveSocket hook, nonce CSP and one fixed compiled Book. The missing listener is a concrete need for a locally openable URL. Use the host-only Bandit development dependency recorded above and a dedicated host lock. Leave the wider ADR 0020 checklist outside this phase.

## Sources

### Primary (HIGH confidence)

- `.planning/ROADMAP.md` Phase 8 and delivery sequence — authoritative goal, success criteria and PR/control ordering.
- `.planning/phases/08-first-inspectable-book-and-local-host-path/08-CONTEXT.md` and `08-UI-SPEC.md` — locked scope and interaction/visual contract.
- `lib/fablebook/router.ex`, `lib/fablebook/placeholder.ex`, `test/contract/prod_guard_test.exs`, `test/fixtures/prod_guard_host/**`, `test/support/mix_cmd.ex` — current mount, placeholder and compile controls.
- `docs/adr/0001`, `0002`, `0003`, `0004`, `0006`, `0008`, `0011`, `0018`, `0020`, `0021` — accepted architecture, dependency and delivery constraints.
- `.planning/references/logistify-brand-intake.md` — approved source file/hash/section inventory and source limitations; raw source bundle not found in current reviewed tree.

### Secondary (MEDIUM confidence)

- `.planning/research/2026-11-20-ui-roadmap-primary-sources.md` — prior primary-source Phoenix/LiveView and browser research; useful technical synthesis without repeating portfolio review.
- `.planning/research/2026-11-20-next-milestone-scope-review.md` — selected bounded product outcome and verification sequence.
- Elixir [`Macro.expand/2`](https://hexdocs.pm/elixir/1.18.1/Macro.html#expand/2) — confirms macro expansion semantics referenced by existing saved research.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — read current `mix.exs`, existing lock/ADR decisions.
- Architecture: HIGH — current macro/fixture and accepted ADRs inspected; no host/Book implementation exists yet.
- Pitfalls: HIGH for macro/production constraints and the host listener requirement; MEDIUM for exact source content pending read-only verification.

**Research date:** 2026-11-20
**Valid until:** 2026-12-20 for stable project contracts; recheck raw source hashes immediately before use.
