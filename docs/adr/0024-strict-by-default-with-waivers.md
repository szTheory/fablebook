# 0024. Strict by default; the only escape hatch is a reasoned Waiver

**Status:** Accepted, 2026-10-28 · **Cites:** INT-20261028-07, INT-20261028-08

Fablebook exists to enforce good practice, shifting it left ("if somebody wants to use ugly, like broken programming styles, they can just use Phoenix Storybook"). Every rule is on by default. The only way around one is a **Waiver**: a declared exemption with a written reason, scoped to one story, scenario or canon entry (for example, a product canon overriding a brand rule). Waivers show as a badge in the workbench, are counted in coverage reports and bundles, and can never be applied globally. A rule that can't hold on day 0 starts as a warning and becomes an error once its prerequisite exists.

Standing principle (INT-20261028-14): "shift left, automate the world". Whenever a static, runtime or CI check can catch a mistake early, it belongs here, up to the point of diminishing returns.

## Default rules
| Rule | Default |
|---|---|
| Scenario has a situation `desc` | error |
| Area and Screen scenarios cite a persona and job | error; warning until `design/` has a persona |
| Citations resolve; no orphan personas or jobs | error |
| Area and Screen subject is a presentational function component (LiveView subject needs a waiver) | error |
| No two scenarios render identically | error |
| No lorem ipsum or placeholder text in rendered scenarios | error |
| Rendered values are on-token (color, type, radius, shadow, spacing) | error once tokens exist |
| Glossary "avoid" words and retired wording absent from rendered copy | error once terms exist |
| Contrast pairs pass WCAG 2.2 AA | error |
| Serious and critical axe findings | error, through the ratchet |
| Coverage gaps | warning; error on Screens |
| Unstoried components | reported only |
| Journey step action exists and its label matches (dead end, copy drift) | error |
| Forced interaction states differ visibly; `phx-click-loading` styled | error |
| Form checks (labels, `aria-invalid`, errors only after touch, autocomplete, no placeholder-only labels) | error |
| Layout shift during load; skeleton matches final size | error |
| RTL logical properties; locale-formatted numbers and dates | error |
| Destructive dialog: cancel not weaker than confirm; confirmshaming lint | error |
| Copy benchmarks (button words, lengths, reading grade, generic labels) | warning |
| Toasts, focus trap and return, focus after patch, errors offer an action | error |
| Hardcoded strings when the Book uses Gettext | error |
| Motion rules (ADR 0025) | error |

## Considered options
- Lenient defaults with opt-in strictness. Rejected: that is the incumbent's posture, and opt-in rules never get switched on.
- A global off switch. Rejected: it turns every rule into a suggestion.
