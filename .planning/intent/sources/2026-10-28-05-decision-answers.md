---
id: INT-20261028-05
date: 2026-10-28
source: Claude Code planning session (fablebook seed research), owner answers to four strategic questions
captured_by: Claude (Opus 5.5)
context: Owner choices on tier vocabulary, static export timing, browser runner, canon format.
---

> Owner selections recorded exactly as chosen; the free-text answer is verbatim.

**Q: Fractal tier names?** → Selected: "Foundation…Screen (Recommended)" —
Foundation · Primitive · Pattern · Area · Section · Screen; "Shell" is a Section kind for app-wide layout/nav.

**Q: When does static export ship?** → Selected: "v1.x, seam now (Recommended)" —
render seam designed from the story-model phase; export ships after 1.0.

**Q: Browser runner for screenshots/axe/visual diffs/--browser bundles?** → Free-text answer:

For this one, I'm not sure. I don't know how mature Phoenix Test Playwright is, if that will be overly limiting. I don't know. Maybe we can spike both and see what the actual issues are that we run into. But I guess we can follow your recommendation. But part of me wonders if maybe the JS Playwright system being more mature would be better. but then maybe https://github.com/ftes/phoenix_test_playwright is more better native integrated? is this something we can follow ur rec now then if we get signals that it would be better with native playwright js we port later?

→ Resolution (agreed in session): follow the recommendation (phoenix_test_playwright), spike both in phase 1, keep probe JS + evidence schema runner-agnostic, port to a generated `@playwright/test` spec if a reversal trigger fires. See `docs/adr/0011-browser-runner.md`.

**Q: Where/what format for design-knowledge content?** → Selected: "design/ Markdown + DTCG (Recommended)" —
`design/` folder, one Markdown file per entry with strict YAML-subset frontmatter (own parser, no YAML dep), DTCG 2025.10 `.tokens.json`; abracabrand `brandbook/` and impeccable `PRODUCT.md` are read, never written.
