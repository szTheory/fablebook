# LLM context bundles and design canon

The owner's core motivation (INT-20261028-04) is to feed screenshots, markup, components, measurements, and brand, glossary and JTBD context to LLMs, so they can help build the whole design system and the app UI. The decisions behind this document are ADRs 0010 (bundles) and 0012 (canon).

## 1. State of the art (verified 2026-10-28)

**Image cost**
- **Claude** ([vision docs](https://platform.claude.com/docs/en/build-with-claude/vision)):
  - Cost is ⌈w/28⌉×⌈h/28⌉ tokens.
  - Claude 4.7+ takes images up to a 2,576 px long edge, about 4,784 tokens at the maximum.
  - Measured costs: 1280×800 ≈ 1,334 tokens; 1440×900 ≈ 1,716; 390×844 ≈ 434.
  - A request with more than 20 images must keep each one at or under 2000 px. Put images before text and label them "Image N:".
  - A 1280×4000 full-page shot gets downscaled until text is unreadable, so **tile by viewport height**.
- **OpenAI** ([images-vision](https://developers.openai.com/api/docs/guides/images-vision)): ⌈w/32⌉×⌈h/32⌉×1.2, with `high` capped at 2,500 patches.
- **Rule:** capture at 1× DPR for whole-view review. Use 2× crops only for type and detail checks.

**Structure: ARIA snapshot vs HTML**
- Playwright's ARIA snapshot is YAML along the lines of `- heading "todos" [level=1]`. It costs roughly 200–400 tokens per scoped snapshot, against 3–5k for a screenshot and far more for raw HTML.
- The working consensus: send a screenshot for layout, a scoped ARIA snapshot for structure, and minimal sanitized markup for the component under review only. ([Playwright MCP snapshots](https://playwright.dev/mcp/snapshots))

**Computed styles**
- There is no standard format. Impeccable's live mode uses outerHTML plus computed styles.
- Fablebook emits one entry per landmark or marked element: `{role, name, box, font, color/bg + resolved token, padding, radius, shadow}`, plus a list of the values that fall outside the token set.

**Other prior art**
- **Storybook manifests (preview, 10.3+):** `components.json` (`id, name, path, stories[{id,name,snippet}], import, description, props`) and `docs.json`, curated with a `manifest` tag. They warn that excessive context degrades agent performance.
- **Figma Dev Mode MCP:** screenshot, metadata outline, variables used, and the code-connect map. This combination is the pattern to copy.
- **DTCG 2025.10:**
  - Format and Resolver modules became stable on 2025-10-28.
  - Media type `application/design-tokens+json`, file extension `.tokens.json`.
  - **Unknown `$extensions` must be preserved.**
  - The resolver handles modes such as light and dark.
- **DESIGN.md** ([google-labs-code/design.md](https://github.com/google-labs-code/design.md), alpha):
  - YAML frontmatter keys: `name, description, colors, typography, rounded, spacing, components`.
  - Eight body sections in a fixed order: Overview, Colors, Typography, Layout, Elevation & Depth, Shapes, Components, Do's and Don'ts.
  - "Tokens are normative; prose provides context."
  - A CLI provides `lint`, `diff` and `export`.
  - It loses shadow, motion, modes and breakpoints. Those go in the sidebar file.
- **llms.txt** ([llmstxt.org](https://llmstxt.org/)) belongs at the root of the published site.
- **v0** uses a shadcn `registry.json`. The lesson: models revert to their trained defaults unless they're given explicit tokens and do/don't rules.

## 2. Owner tooling to interoperate with

**abracabrand** (`~/projects/abracabrand`): a six-mode skill (brief, name, direct, logo, build, check) that produces a `brandbook/` folder:
- `index.html`, `BRAND.md`, and `tokens/identity.json`.
- **Token rules:** a narrow DTCG 2025.10 subset (color, dimension, typography; `$type`, `$description` and `$value` required; aliases as `{color.ink}`; at most 512 tokens, 1 MiB, 32 nesting levels). Its `$extensions.abracabrand.*` keys:
  - `profile`
  - `mode`: light/dark role pairs
  - `typeface`
  - `uses`: contrast-checked rows `{id, kind, foreground, background, fontSize, fontWeight}`, with required ids body, descriptor, caption, application-copy, hero, link, focus and artwork.
- `logos/*.svg`, outlined paths only.
- `rights/assets.json`.
- `inventory.json`: sha256 per file.
- `notes/direction.md`:
  - A `abracabrand-direction: 1` marker.
  - Seven H2 sections, each prefixed with an `Evidence:` line.
  - Palette, Type, Composition and Imagery lines.
  - Applications with `Use | Imagery | Framing | Copy | Avoid | Rationale`.
- **Check outcomes:** `pass | fail | unknown | unsupported`, and `not-run` is never counted as a pass.
- **Richest voice schema of any owner repo:** `research/08-voice-and-microcopy.md`, covering a voice sentence, anchor and foil, eight 1–5 sliders, X-not-Y attributes, policies, vocabulary, signature moves and anti-moves, a tone map and calibration rewrites. It also defines a glossary row in §F.

**What Fablebook does with it:**
- **Reads** `tokens/identity.json`, preserving `$extensions`.
- **Renders** `uses` rows as contrast cards and `mode` as a light/dark toggle.
- **Parses** BRAND.md and the direction note into Foundations pages (Voice, Imagery, Applications).
- **Shows** logos filtered by rights.
- **Pins** the `inventory.json` hash in every bundle.
- **Never writes** inside `brandbook/`.
- **Keeps product-only tokens separate:** radius, shadow, motion and layer go in `design/tokens/product.tokens.json`, aliasing into identity.

**impeccable** (`~/.claude/skills/impeccable`, v4.7.0; [impeccable.style](https://impeccable.style/)):
- **Files it owns:**
  - `PRODUCT.md` (`<!-- impeccable:product-schema 1 -->`, holding product truth, not visual decisions).
  - `DESIGN.md` (the Google spec, with a "Creative North Star" line and Named Rules).
  - `.impeccable/design.json` (schemaVersion 2, with `extensions.{colorMeta, typographyMeta, shadows, motion, breakpoints}`, `components[]` as self-contained html/css, and `narrative`).
  - `.impeccable/critique/*.md` (score frontmatter).
- **Its rubric:**
  - Critique: Nielsen's 10 heuristics scored 0–4, a design-specificity verdict, cognitive load, P0–P3 issues and persona red flags.
  - Audit: five dimensions, a11y, perf, theming, responsive and implementation integrity, each 0–4.
  - Craft floor: contrast, a 65–75ch measure, every state present, and banned defaults.
- **How it gathers context:** `impeccable detect --json`, browser overlay injection, batched screenshot rounds at desktop and mobile widths, and live events carrying outerHTML, computed styles and rects.

**What Fablebook exposes to make impeccable-style agents effective:**
1. A stable, chrome-free canvas URL for each rendition, with `data-fablebook-ready`, plus a manifest mapping URL → source file. (impeccable prefers source paths because "ports drift".)
2. A generated, lint-clean `DESIGN.md` plus `.impeccable/design.json`, built from **really rendered** primitives. Fablebook refuses to overwrite either file if it didn't generate it.
3. `PRODUCT.md`, read but never owned.
4. The manifest.
5. Static HTML per scenario (v1.x export), so `detect` can scan without a server.
6. A bundle `prior/` slot that carries critique snapshots and the verdicts log.

**The owner's other conventions:**
- **lockspire PRODUCT.md:**
  - "Personas and jobs" with a "Last reviewed" date and confirmed/assumed labels.
  - Each persona has *Knows*, jobs in "When…, I want…, so…" form, and *Pages*.
  - A **vocabulary map**: `Internal or protocol term | UI says | Protocol term shown?`.
  - A **retired wording** table enforced by `vocabulary_contract_test.exs`.
- **scrypath GLOSSARY:** `**Term**: definition` plus `_Avoid_:`.
- **Recurring brandbook structure:** essence and rules, voice (principles, say/not-that, sliders, vocabulary, CTAs), domain nouns, tokens with a job per role, a type scale, space/radius/focus, a computed contrast matrix, a gallery, the logo system, specimens, copy blocks, and usage policy.

## 3. Canon schema (`design/`, ADR 0012)

Every entry carries `id`, `status: confirmed|assumed|proposal`, `owner`, `reviewed: YYYY-MM-DD`, and optionally `evidence: {class, source, date}`, using abracabrand's evidence classes. Frontmatter is a strict YAML subset.

```yaml
# design/glossary/app.md   (lockspire map + scrypath avoid + abracabrand §F)
kind: term
id: app
term: app
internal: [client, client_id]
ui_label: app
docs_form: app
code_identifier: Client
avoid: [client]
retired: [OAuth client]
capitalization: lower
i18n: translate
surfaces: [apps, app-registration]
---
User-facing definition in prose.
```

```yaml
# design/voice/voice.md
kind: voice
sentence: "…sounds like … explaining … to … when …"
anchor: "…"
foil: "…"
sliders: {serious_funny: 2, formal_casual: 3, terse_expansive: 2, plain_technical: 4}
policies: {contractions: true, apology: once, exclamation: 0, emoji: none, case: sentence}
prefer: []
avoid: []
---
Attributes (X, not Y), signature moves, anti-moves, tone map — prose with lists.
```

```yaml
# design/personas/on-call.md
kind: persona
id: on-call
handle: On-call engineer
device: phone
trigger: paged
jobs: [JOB-03]
knows_confirmed: []
knows_assumed: []
red_flags: []
```

```yaml
# design/jobs/JOB-03.md
kind: job
id: JOB-03
when: "…"
want: "…"
so: "…"
personas: [on-call]
surfaces: [failed-deliveries]
success_signals: []
```

```yaml
# design/twins/chatly.md
kind: twin
id: chatly
product: "B2C chat app"
model: b2c
hosting: multi-tenant
volume: "2M users, 40k deliveries/day"
locales: [en, ja, ar]
failure_profile: "bursty provider timeouts at peak"
```

Other files:
- `design/foundations/imagery.md`: `kind: imagery`, `subject`, `treatment`, `avoid` and `rights_ref`. Defaults come from abracabrand's Imagery and Application clauses.
- `design/voice/copy_rules.json`: banned and required patterns used by the copy lint. It can be exported for Vale.

## 4. Scenario citations
On each scenario, `persona:`, `job:` and `twin:` are canon string ids and `state:` is a state class. Their shape is checked at compile time; their existence at catalog build and in generated tests (ADR 0002). The story carries `tier:`. An Area or Screen scenario that cites no persona and job fails once the canon has a persona, and only warns before that (ADR 0024).

## 5. Bundle format (ADR 0010)

| Scope | Defaults | Typical size |
|---|---|---|
| Scenario | Shots at 375 and 1280, light and dark (4); ARIA; markup; styles; measurements; a11y; copy; cited canon | ~5–8k tokens |
| Story | One default shot per scenario plus a grid contact sheet; contract once | ~10–20k |
| Section (product folder) | One shot per screen in the folder; nav ARIA identity. Use `--focus journey` for flows | budgeted |
| Catalog | DESIGN.md, full tokens, manifest, Foundations, one thumbnail per story; no per-scenario markup | budgeted |

Fill priority:
1. Cited canon and voice
2. Contracts
3. Failing evidence
4. Shots
5. Markup
6. Passing evidence counts

The allocator writes what it dropped into `BUNDLE.md`.

`BUNDLE.md` reading order:
1. Task framing (what feedback is wanted)
2. Canon (who, why, words, voice, tokens)
3. Per scenario: situation, then images, then ARIA, then findings
4. Coverage gaps
5. Staleness notes

## 6. Later (v1.x and beyond)
- An MCP adapter over `Fablebook.Bundle`, with tools: list stories, get a scenario bundle, get tokens, get a screenshot, get ARIA.
- An L4 judge recipe (impeccable-based): binary judgments with evidence, pairwise head-versus-main comparisons in both orders, a pinned model and prompt, calibration against owner-labelled examples, and output keyed to finding fingerprints.
