# Milestone start: research and rolling roadmap

This reference implements [INT-20261119-06](../intent/sources/2026-11-19-06-research-first-rolling-roadmap.md). Read it whenever starting a milestone. It preserves the owner's preferred discovery posture without turning downstream direction into premature requirements or implementation.

## Start with current evidence

Before proposing a milestone, reconcile:

- canonical checkout, branch, local/remote relationship, and worktree recovery pointers;
- active `STATE.md`, completed milestone receipts, phase delivery receipts, and required hosted CI;
- project intent, relevant ADRs, verification records, open gates, and typed prerequisites;
- applicable seeds, brand intakes, source custody, and unresolved name/asset rights limits;
- the rolling product roadmap and what has actually shipped.

For this repository, use `~/projects/fablebook` on `main`; do not disturb preserved dirty recovery checkouts.

## Explore and synthesize

For a non-trivial new milestone, fan out read-only research across the specific product, architecture, implementation, security, verification, adopter, design, operations, and maintenance lenses that apply. Use parallel specialist agents where available and authorized. Continue until additional independent work mostly repeats the same evidence. Prefer official docs, primary research, standards, or source repositories; cite sources and distinguish verified claims from inference. Include tradeoffs, failure modes, anti-patterns, dependency cost, reuse, testability, and a skeptical/adversarial review. Avoid unrelated domains and speculative breadth.

Synthesize a concrete recommendation with:

1. the immediate milestone goal and why it is the best next action;
2. exact in-scope evidence/deliverables and explicit non-goals;
3. inherited limits, typed blockers, required exit evidence, and owner decisions;
4. a rolling near/mid/later roadmap with dependency order and major product outcomes;
5. product reality: distinguish source material, applied canon, Fablebook Books/scenarios, runnable UI, and adopter dogfood;
6. efficient checks: cheap consistency checks before long suites, no new dependency without an explicit need, and no recurring automation without lasting value.

The research/roadmap is directional. Only activate the selected milestone; future milestones do not get executable requirements or plans until their own start and prerequisite checks.

## Present and proceed

Present the synthesized recommendation before asking for any decision the existing owner direction has not already resolved. Ask only when the answer changes scope, authority, risk, cost, or a required milestone/phase boundary. A user-selected milestone name, goal, and phase number should not be re-asked. After the owner selects a scope, carry it through the required GSD requirements, roadmap, phase discussion, planning, execution, verification, review, and delivery gates under the approved autonomy. Stop at genuine owner gates, including any explicit no-follow-up boundary.

At each milestone start, update `.planning/references/PRODUCT-ROADMAP.md` with actual delivery state and the recommended rolling outlook. At every pause, update `STATE.md` and the relevant receipt with checkout, milestone/phase, delivered and unfinished work, unchanged stops, next concrete action, and who acts next.

## Fablebook product-progress vocabulary

Use these as separate maturity states:

1. **Sourcebook** — a brand-book artifact authored in its source repository and pinned/read from immutable provenance.
2. **Applied canon** — accepted brand rules/tokens mapped into Fablebook's domain model and checked into the product host.
3. **Book and Scenarios** — concrete Fablebook content for a product with traceable jobs, screens, and states.
4. **Runnable demo** — the Fablebook package or host actually renders those Books/scenarios in a usable browser surface.
5. **Dogfood** — real adopter components are rendered and used to guide reviewed product changes.

Do not report one stage as another. For brand assets, keep source, license, reuse, and name-clearance facts attached; do not imply clearance from an authored book.
