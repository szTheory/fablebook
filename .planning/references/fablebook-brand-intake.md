# Fablebook brand source intake

**Status:** Source pinned for future planning. The owner explicitly chose to wait for version 2.1 and keep the intake and assets staged; no brand has been applied. See [INT-20261111-07](../intent/sources/2026-11-11-07-fablebook-brand-version-hold.md). Guard Phase 1 continues independently.

## Provenance

- Source repository: https://github.com/szTheory/fablebook-brand
- Observed upstream main commit: 5a13d2f32db0783bd7eebaa416d53b0701288a67 (2026-11-11)
- Source-reported version: **2.0** in BRAND.md, brand.json, and assets/README.md.
- The owner expected version 2.1. Upstream main still reports 2.0, so 2.0 is the pinned evidence and 2.1 remains unresolved. Do not apply assets or copy book text until the version is reconciled.
- SHA-256:
  - BRAND.md: 1715a945b89bddd625a24daa1d6559ffea26c9974e6219821b2c4d997aa02074
  - brand.json: 173dbee5c20de8e6c3998c9b499b86ebb2c3eeb94cef92d2f6a5aa38777e35c6
  - tokens.json: ed7170d1283b5454496425f80d89b57e5285ea790b7a385a6998555eed8a34dd
  - assets/index.html: 53f72c190dea689134fb8ca4cdde121ee6731575f451af073e871d3492fd8b58
  - assets/README.md: 6b2882477c8a489ce2556c462b9e305eeb2ea75386aad3b4d2da94a0711fba80

The local source checkout is ignored and is not part of the product. This reference uses only the upstream URL and immutable commit; it does not direct readers to a local clone. The book is captured as a summary, not copied into this repository.

## What the source says

The public name is **Fablebook**; package/code spelling is `fablebook` and application atom `:fablebook`. The descriptor is “A UI catalog for Phoenix LiveView.” It specifies light and dark themes; a neutral catalog that lets the previewed application provide its own color; gilt reserved for the logo, docs and social card; an Ink/Vellum current-scenario ribbon; and word-led status markers. It defines contrast pairs by stable role ids, typography for docs and catalog use, plain US English, logo variants, browser icons and a social card. The structured data mirrors the book, while tokens.json contains the color and type values.

The sourcebook recommends “case” for the circumstances represented by one screen and retains “story” for one screen, but leaves user flow as an unresolved model choice. It also recommends replacing “canon” with “domain language.” Those are book recommendations; the owner separately leaves the story/user-flow and canon names open.

The source describes claims about previewing user flows, realistic data, coverage, personas, jobs, and structured component styles. These are not evidence that those capabilities have shipped. Use only claims backed by current implementation and acceptance evidence.

## Owner instructions, vocabulary and book recommendations

The owner explicitly requests the ignored read-only reference clone, full book/data review, deliberate asset copies, no shipped references to the clone, and conflict reporting. Verbatim excerpts are recorded in [INT-20261111-06](../intent/sources/2026-11-11-06-fablebook-brand-intake.md):

- Use “UI catalog” and the descriptor “A UI catalog for Phoenix LiveView.”
- Book recommendation, consistent with the earlier owner request for neutral chrome: keep the catalog neutral and preserve the previewed application's colors. Reserve gilt for docs, logo and social card; keep the current-scenario ribbon Ink or Vellum.
- Book recommendation: edited marks a temporary preview change and “Restore scenario” clears it. Edited is round and outlined. Gap uses brick and a squared coverage mark; Waived uses slate and a dashed coverage mark. Terminal coverage output is an aligned table with literal “gap” and “waived”; color is backup.
- Book recommendation: page and scenario navigation is instant. Catalog hover, focus and selection use 120 ms ease-out. The component's own motion remains as defined by the app; no sound.
- Book recommendation: use contrast ids body, descriptor, caption, application-copy, hero, link, focus, and artwork; treat their ratios as evidence for those pairs only.
- Use “case” for the circumstances around a scenario; one scenario is one screen in one case. The current case set is happy, empty, many, error and long. Do not use “situation” or “moment”; “variant” remains prohibited.
- Use plain US English. No slogans, AI-style phrasing or middle dots. Do not state unshipped capabilities as facts.

The supplied handoff reports that the owner glanced over the book rather than conducting a deep review; it is not a deep acceptance receipt. Canon naming and whether a story represents a screen or a user flow remain open.

## Conflict matrix

| Topic | Current contract and path | Owner direction or source recommendation | Recommended reconciliation |
|---|---|---|---|
| Product label | “Workbench” in [GLOSSARY.md](../../GLOSSARY.md), [ADR 0013](../../docs/adr/0013-workbench-ux.md), and [UX-DESIGN.md](../../docs/research/UX-DESIGN.md) | Owner settles “UI catalog” as the product label and descriptor. | In a future approved brand/UI slice, align the glossary, ADR and UI copy together. Do not change these contracts in this intake. |
| Story unit | One catalog entry for one component in [GLOSSARY.md](../../GLOSSARY.md); compiled story modules in [ADR 0001](../../docs/adr/0001-stories-are-compiled-modules.md); tiered story model in [ADR 0023](../../docs/adr/0023-vocabulary-scenario-and-tiers.md) | Source recommends “story” for one screen. Owner says a story currently represents one screen and leaves story versus user flow open. | Keep the existing model as historical/current contract. Resolve the product object model through an owner decision before changing docs, schema or code. |
| Scenario and circumstance | A scenario is a fixed subject state; “Situation” is defined in [GLOSSARY.md](../../GLOSSARY.md), and [ADR 0023](../../docs/adr/0023-vocabulary-scenario-and-tiers.md) defines state vocabulary. | Owner settles “case” as the surrounding circumstance and one scenario as one screen in one case, with happy, empty, many, error and long as the current case set; “situation” and “moment” are not to be used. | Record an explicit vocabulary decision and reconcile glossary, requirements and ADR 0023 together. Preserve the broader existing state-class acceptance set until separately changed. |
| “Canon” name | Canon is the design-knowledge model in [GLOSSARY.md](../../GLOSSARY.md), [ADR 0012](../../docs/adr/0012-canon-format.md), and [FABLEBOOK-SEED.md](../../FABLEBOOK-SEED.md). | The source recommends “domain language”; owner leaves the canon name open. | Keep “canon” in current contracts until the owner resolves the name. Do not rename the schema from this book alone. |
| Markers and coverage | Marker copy and status behavior are described in [UX-DESIGN.md](../../docs/research/UX-DESIGN.md); coverage terms are in [GLOSSARY.md](../../GLOSSARY.md). | Book recommends round outlined Edited, Restore scenario, brick/squared Gap, slate/dashed Waived, with words carrying meaning and color backing them up. | Apply the owner-approved mapping in a future UI and terminal-output slice, preserving text alternatives and accessible boundaries. |
| Color and motion | Neutral chrome and instant canvas swaps are in [ADR 0013](../../docs/adr/0013-workbench-ux.md) and [UX-DESIGN.md](../../docs/research/UX-DESIGN.md). | Book recommends app-owned canvas colors, gilt only on docs/logo/social, Ink/Vellum current-scenario ribbon, instant page/scenario navigation, 120 ms ease-out catalog interaction, unchanged component motion and no sound. | Map these to the existing chrome rules without changing component behavior. Keep any separate panel timing decision explicit. |
| Contrast claims | The existing chrome guidance is in [UX-DESIGN.md](../../docs/research/UX-DESIGN.md). | The book limits its ratios to the eight named contrast pairs. | Do not infer whole-product accessibility or contrast clearance from the listed pair ratios. |
| Marketing claims | Future promises appear in [FABLEBOOK-SEED.md](../../FABLEBOOK-SEED.md) and [.planning/references/PRODUCT-REQUIREMENTS.md](PRODUCT-REQUIREMENTS.md). | Owner says to state shipped facts only. | Verify claims against implementation and acceptance evidence before using them in README, docs, package listings or social copy. |
| Logo and assets | The source lists filenames and use cases in BRAND.md and assets/README.md; this checkout has no brand asset destination tree. | Owner asks that assets follow the book, but source version is unresolved. | No tracked copies were made. Resolve the version, rights and destination path in the future surface-owning phase. |

## Asset and review limits

The source asset table identifies light/dark and one-color logos, favicon files, a social card, and font files. It gives intended surfaces and source-relative filenames, but no repository-relative destination. This checkout has docs/ without a brand-asset directory and has no priv/ static asset tree; do not invent destination paths or edit README/docs/UI copy as part of this intake.

The three font families have SIL Open Font License 1.1 notices in the source. The source says logo artwork and the book are covered by the repository license, but the observed source commit has no root license or rights manifest. Artwork and social-card rights are therefore unresolved. The name/trademark was not searched. The source also reports no real-device or Safari check, no print proofing, and contrast values for declared pairs only. Do not infer clearance from this review.

Assets are kept in ignored local staging with a destination map for review only. They are not copied into tracked product paths or approved for publication.

Before any future edit to README, docs, catalog chrome, package listing or social card:

1. Read this intake and the source files at the pinned upstream commit.
2. Reconcile the expected 2.1 version with the observed 2.0 source.
3. Surface product-model conflicts; map the actual destination and record rights limits relevant to any assets being published. Do not require unrelated terminology decisions merely to perform a safe factual edit.
4. Use only shipped, evidenced claims and preserve the owner's settled decisions above.
