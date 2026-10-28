# 0023. Vocabulary: "Scenario" for states; four tiers (Primitive · Pattern · Area · Screen)

**Status:** Accepted, revised 2026-10-28 · **Cites:** INT-20261028-01, INT-20261028-05, INT-20261028-06, INT-20261028-07

## Decision
- **Scenario.** A named state of a story is a Scenario. "Variant" is banned because it collides with the `attr :variant` that nearly every design system has. "Variation" (phoenix_storybook) and "example" (the `examples:` attr option) are retired.
- **Tiers** are a closed ladder of four. Each tier answers one question:

  | Tier | Question |
  |---|---|
  | Primitive | Is this control right? |
  | Pattern | Do these controls do their small job? |
  | Area | Does this part hold up with real data? |
  | Screen | Can this persona finish the job? |

- **Shell** is the Area that frames every Screen.
- **Sections** (product nouns) are sidebar folders inside each tier, not a tier.
- **Foundations** is the sidebar section that presents the canon, not a tier.
- The sidebar shows: To review · Foundations · Primitives · Patterns · Areas · Screens · Journeys · Pages · Unstoried.
- The migrator maps psb `Variation` → Scenario and `VariationGroup` → Group.
- `GLOSSARY.md` is the single source of truth for vocabulary.

## Considered options
- The six-level ladder (Foundation…Screen, INT-20261028-05). Rejected: a Foundation isn't UI, and a Section isn't one size of UI. Neighbouring levels became indistinguishable to designers and LLMs (INT-20261028-06, INT-20261028-07).
- scrypath's Surface/Job. Rejected because "Job" collides with JTBD.
