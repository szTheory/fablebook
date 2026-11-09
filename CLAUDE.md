# Fablebook: agent instructions

## Read first, every session that plans or reviews
1. `.planning/intent/NORTH-STAR.md` and `.planning/intent/CLEARANCE.md`
2. `GLOSSARY.md`, the only source of vocabulary. Never call a scenario a "variant" or "variation".
3. `docs/adr/README.md` (locked decisions)
4. `.planning/VERIFICATION.md` when discussing, planning, executing, reviewing, verifying or resuming work; automate acceptance checks and reuse recorded evidence before handing work to the owner.

GSD researchers, synthesizers and the roadmapper also read `FABLEBOOK-SEED.md`, `docs/adr/*` and `docs/research/*` before writing anything. Every REQ keeps its INT/ADR citations.

## Precedence
Verbatim intent (`.planning/intent/sources/`) > ADR > REQUIREMENTS > PROJECT. When a plan conflicts with intent, add an entry to `.planning/intent/OPEN-QUESTIONS.md`. Never reinterpret the owner's words.

## Recording intent
When the owner gives direction, add a verbatim entry to `.planning/intent/sources/` (`id: INT-YYYYMMDD-NN`, `date`, `source`, `captured_by`, `context`). Entries are add-only. Corrections use `supersedes:`.

## Non-negotiables
- Never lower a quality gate to finish a phase. Split the phase instead.
- No runtime eval, and no atoms created from input (ADR 0004).
- Copy-paste beats a new dependency. A new dependency needs an ADR. Adopters never need Node (ADR 0018).
- Push early. Every phase ends in a merged green PR. Evidence means a CI run link, not prose.
- End every GSD flow with the next command and its purpose, including partial/blocked flows (INT-20261029-09).
- Report model profiles and effort levels only when the owner asks; omit routine GSD model-routing footers (INT-20261029-11).
- Never edit a contract test in the same PR as the implementation it guards (definition and enforcement: ADR 0021).
- Never auto-accept a visual baseline.
- No PII in git: no email addresses, no absolute home paths (write `~/`).
- Code is idiomatic, minimal and self-documenting. No comments that restate the code.

## Execution preferences
- Prefer a clear, opinionated default; optimize the adopter's DX and UX, use idiomatic Elixir, and keep useful investigation evidence.
- Explain risks and decisions in plain, concrete language. Prefer local contract tests and dry-runs when they establish the same behavior; do not change public release state just to create a test case. (INT-20261108-01)
- Before hosted CI, run the relevant GitHub Actions locally with `act` whenever feasible to catch failures and reduce CI work. Local `act` results supplement, but do not replace, required hosted receipts.
- The owner has granted standing authorization across Fablebook OpenGSD phases, plans, and milestones to publish reviewed/tested phase candidates by pushing the phase branch and opening or updating a PR to trigger hosted CI, without asking for permission again each time (INT-20261109-01). Follow existing branch protection and phase delivery gates; this does not authorize unrelated releases or production deployments.
- Once a phase is approved, complete its required local validation and bookkeeping without asking about routine steps. Ask only for a real scope change or an external action not covered by standing authorization. End with one exact next command and its purpose.
- Preserve recovery worktrees and investigation artifacts unless their disposition is explicitly changed. Delegate only when the workflow and runtime allow it and authorization is present.
