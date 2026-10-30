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
- Never edit a contract test in the same PR as the implementation it guards (definition and enforcement: ADR 0021).
- Never auto-accept a visual baseline.
- No PII in git: no email addresses, no absolute home paths (write `~/`).
- Code is idiomatic, minimal and self-documenting. No comments that restate the code.
