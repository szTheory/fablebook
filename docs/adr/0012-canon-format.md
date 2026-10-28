# 0012. Canon lives in `design/`: Markdown with strict frontmatter, plus DTCG 2025.10 tokens

**Status:** Accepted · **Cites:** INT-20261028-04, INT-20261028-05, INT-20261028-02

## Context
- **Owner tools:** abracabrand produces `brandbook/` with `tokens/identity.json` (a narrow DTCG 2025.10 subset with `$extensions.abracabrand.*`), BRAND.md, and a direction note. impeccable owns `PRODUCT.md` and generates `DESIGN.md` (Google design.md spec, alpha) and `.impeccable/design.json`.
- **Persona and vocabulary formats:** lockspire's PRODUCT.md has the best persona and vocabulary-map format; scrypath's GLOSSARY.md uses term plus `_Avoid_`.
- **Spec status:** DTCG 2025.10 became the first stable release on 2025-10-28.

## Decision
```
design/
  tokens/product.tokens.json   # radius, shadow, motion, layer, breakpoints; aliases into brandbook identity (read-only)
  tokens/resolver.json         # DTCG resolver: light/dark (+ reduced-motion)
  foundations/*.md             # color, typography, spacing, motion, imagery (brand ones generated from brandbook/)
  voice/voice.md, voice/tone/<surface>.md, voice/calibration.md, voice/copy_rules.json
  glossary/<term>.md           # one term per file: term, internal, ui_label, avoid, retired, capitalization, i18n, surfaces
  personas/<id>.md             # actor: role, device, trigger, knows {confirmed, assumed}, jobs, red_flags
  jobs/JOB-NN.md               # when / want / so, personas, surfaces, success_signals
  twins/<id>.md                # a fictional organization the UI serves: profile, volume, locale/script mix, failure profile, optional theme
```
- **Required fields:** every entry has `id`, `status` (confirmed, assumed or proposal), `owner` and `reviewed`.
- **Frontmatter:** a strict YAML subset (scalars, inline and block lists, one level of maps, lists of flat maps), parsed by `Fablebook.Canon.Frontmatter` (about 300 lines, property-tested round-trip). It rejects anything outside the subset with a precise error. No YAML dependency.
- **Read, never written:** abracabrand `brandbook/` (pinned by the `inventory.json` hash) and impeccable `PRODUCT.md`.
- **Generated:** `DESIGN.md` and `.impeccable/design.json`, with an ownership header. Generation refuses to overwrite a file whose hash it doesn't own.
- **Exposed:** the canon renders as Foundations pages and feeds bundles. Scenarios cite canon ids, and a broken citation is a `CompileError` or test failure.

## Rejected
- Compiled Elixir canon modules: less portable to abracabrand, impeccable and LLM tools.
- `yaml_elixir`: adds two dependencies, against the flat-dependency rule.

## Reversal trigger
The YAML subset parser exceeds 500 lines, or 2 or more real canon needs fall outside the subset. If triggered, reconsider an optional YAML dependency.

## Amendments (grilling, 2026-10-28)
- **Layers:** a brand canon is shared by a product family. Product canons inherit from it. Overriding a brand rule needs a waiver. The brand canon may come from a path or a dependency (`canon: [brand: {:logistify_brand, "design"}, product: "design"]`). (INT-20261028-10, INT-20261028-11)
- **Themes:** a Book renders under named themes, and a twin may bring its own theme (white-label). **Guardrails** turn unreadable theme choices into findings. (INT-20261028-10)
- **Directions:** candidate looks and voices, with status `proposal` until chosen. They live under `design/directions/<id>/`, are selectable and comparable, and can be imported from abracabrand routes. (INT-20261028-11)
- **Journeys:** declared inside job files as linear steps (scenario id plus action label). The catalog build checks them. (INT-20261028-14)
- **Locale labels:** terms carry a `ui_label` per locale, and missing translations are reported, not failed. Agent-written entries are `proposal` until a person confirms them. Entries not reviewed in 180 days show in the review queue. (INT-20261028-09)
