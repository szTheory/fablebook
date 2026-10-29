---
id: INT-20261029-06
date: 2026-10-29
source: Codex session, owner message
captured_by: Codex
context: Owner is switching OpenGSD from Claude to Codex for now and specifies the model and effort for each tier.
---

> Verbatim.

claude to codex
----
switch us from claude to codex for now going forward with opengsd. we want to use gpt-6.1-sol for opus-tier work, and gpt-6-luna for sonnet-tier work, and gpt-6-luna for haiku-tier work. list the model profile at end also with effort levels made clear. i switch between codex/claude often but we're going to use CODEX for now
| GSD tier | Model        | Effort |
|----------|--------------|--------|
| light    | gpt-6-luna   | xhigh  |
| standard | gpt-6-luna   | xhigh  |
| heavy    | gpt-6.1-sol  | high   |

**Resolution:** Set `runtime` to `codex` in `.planning/config.json` and retain the `adaptive` model profile. Codex tier overrides map opus to `gpt-6.1-sol` and sonnet/haiku to `gpt-6-luna`. Routing effort is `xhigh` for light and standard and `high` for heavy. Preserve the Claude tier overrides for future runtime switches. Global defaults already match the requested Codex profile.
