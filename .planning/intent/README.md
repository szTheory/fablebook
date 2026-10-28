# Intent: the project's second brain

This folder holds **why Fablebook exists** and **what "good" means**, in the owner's words, with provenance. Every plan, phase and review traces back here.

## Precedence

When two sources disagree, the higher one wins:

1. **Verbatim intent**: `sources/*.md`
2. **ADRs**: `docs/adr/*.md`
3. **REQUIREMENTS**: `.planning/REQUIREMENTS.md`
4. **PROJECT summary**: `.planning/PROJECT.md`, `FABLEBOOK-SEED.md`
5. Research docs: `docs/research/*.md`

A plan that conflicts with intent is never quietly reinterpreted. Log it in `OPEN-QUESTIONS.md` for the owner.

## Files

| File | Role | Who edits |
|---|---|---|
| `sources/YYYY-MM-DD-NN-slug.md` | Immutable verbatim captures of owner direction, with `id`, `date`, `source`, `captured_by`, `context` | **Append only.** Corrections are new entries with `supersedes: INT-…` |
| `NORTH-STAR.md` | ≤7 non-negotiables, each citing INT ids and a "how we'd know" test | Owner-approved changes only |
| `MOTIVATIONS.md` | Curated synthesis by theme | Agents may rewrite; **every sentence cites ≥1 INT id** |
| `CLEARANCE.md` | Scorecard: when Fablebook beats phoenix_storybook for the owner (gates 1.0 and the owner's switch) | Owner-approved changes only |
| `OPEN-QUESTIONS.md` | Unresolved intent-vs-plan conflicts and deferred owner decisions | Anyone adds; owner resolves |

## Maintenance rules

- Record a new `sources/` entry only from the owner's own words, quoted exactly, with a pointer to where they came from (session, issue URL, file).
- No PII: no email addresses, no absolute home paths (use `~/`), no secrets.
- Read `NORTH-STAR.md` and `CLEARANCE.md` first in every `/gsd-new-milestone`, `/gsd-discuss-phase` and milestone audit.
- Enforcement: once the repo has code, `test/planning/intent_test.exs` (fast, inside `mix ci`) asserts:
  - files under `sources/` are add-only against the merge-base;
  - every cited INT id exists;
  - every REQ-ID cites ≥1 INT or ADR id.
