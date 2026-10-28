# 0010. The LLM context bundle is a core, deterministic, budgeted artifact

**Status:** Accepted · **Cites:** INT-20261028-04 (core motivation)

## Decision
### Entry points
- `mix fablebook.bundle <selector> [--detail summary|standard|full] [--budget 120k] [--browser] --out dir`
- **Copy for LLM** (text) and **Download context** (zip via `:zip`) in the workbench.
- Selectors: a scenario id, a story, a section prefix, a tier, a tag, or `all`.

### Layout
```
BUNDLE.md          entry point (≤~3k tokens): task framing, reading order, image index, budget table, staleness
bundle.json        schema "fablebook.bundle/1": ids, citations, files, checks, est tokens, source sha, brandbook inventory pin
context/           DESIGN.md (generated), design.tokens.json (tokens used, $extensions preserved), glossary.md (terms hit + retired wording hits),
                   voice.md (relevant tone + calibration examples), personas-jobs.md (cited), product.md (PRODUCT.md excerpt)
scenarios/<id>/    meta.json, shots/{375,1280}-{light,dark}.png, aria.yaml, markup.html (sanitized, deduped), styles.json,
                   measurements.json, a11y.json, copy.json
checks/summary.json  pass|fail|unknown|not-run per check
prior/             optional: .impeccable/critique snapshots, verdicts log suppressions
```

### Capture levels
- **No-browser capture (pure Elixir):** markup, contracts, canon, coverage and copy lint.
- **`--browser` capture:** screenshots, ARIA, measurements and axe, captured via the runner from ADR 0011 using the same capture pipeline as the visual baselines.

### Budget allocator
The allocator fills sections in priority order and reports anything it dropped.
- **Images.** Claude costs ⌈w/28⌉×⌈h/28⌉ tokens (about 1.3k for 1280×800, about 434 for 390×844). Captures are at DPR 1, tall pages are tiled by viewport height rather than shot full-page, and past 20 images the allocator switches to **contact sheets**: browser-tier screenshots of the workbench's All-scenarios grid view (no image library needed; v1.0).
- **Markup.** Stripped of `data-phx-*`, ids and CSRF; whitespace normalized; repeated siblings collapsed to "…47 more rows like this".
- **Contracts.** One per component.
- **Evidence.** Failures in full; passes as counts only.
- **Canon.** Filtered by citation and term hits. Voice rules are always included.

### Honesty and safety
- Evidence is keyed by sha256 of the HTML plus the CSS hash. Stale or missing evidence is labelled as such, never presented as current.
- A redaction pass removes absolute paths, env values, hostnames, secret-shaped strings, and session/CSRF tokens. A `redact:` hook is available.

### Tests
- Golden bundles: 3 reference scenarios in the PR lane.
- A determinism property (permutation, run twice, identical tree hash).
- A redaction test.
- Size budgets: `BUNDLE.md` plus each scenario at or under about 7.5k tokens of text, and each scenario at or under 1.5 MB.

## Focus
The list of focuses is closed: explore · critique · copy · a11y · layout · consistency · brand · compare · journey · motion. Adding one requires an ADR, so the rubrics stay curated (INT-20261028-12).

## Rejected
- Raw full-page HTML dumps: the most expensive input and the least useful.
- A dependency on any LLM API: Fablebook produces context, and judging is the agent's job.
