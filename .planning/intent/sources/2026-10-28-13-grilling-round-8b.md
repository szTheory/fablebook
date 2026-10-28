---
id: INT-20261028-13
date: 2026-10-28
source: Claude Code session, grill-with-docs round 8 (motion, skills, dimensions), owner answers
captured_by: Claude (Opus 5.5)
context: Motion lane, motion checks, LLM motion feedback, skills strategy, and additional UX dimensions accepted.
---

> Verbatim. Not paraphrased, typos preserved.

q7 yes motion imporant. i like that worth possi ly digging into more or at least yes well i agree with u important motion. q8 follow ur recs. q9 follow ur recs. q10 follow ur recs. seems liek best of both worlds to have hte option to use ours or others/ur own. q11 ur recs sound good .

**Resolutions:**
- **Q7:** The motion lane (timeline, slow motion, filmstrips; filmstrips are baselined in CI) ships in 1.0. It is flagged for deeper exploration.
- **Q8:** Motion checks are strict by default: motion tokens, banned patterns, LiveView JS-command lints, and `motion_tier`.
- **Q9:** The `motion` bundle focus uses `motion.json`, a filmstrip contact sheet, and reduced-motion frames. Never video.
- **Q10:** Fablebook ships 3–4 small skills of its own, installed via usage_rules or `mix fablebook.skills.install`. Rules live in checks. Upstream skills are named when installed and never installed silently.
- **Q11:** 1.0 adds forced interaction states, form checks, the layout-shift check, the RTL logical-property lint, the locale-formatting check, and the destructive-dialog check. Print, data-viz and density checks go to v1.x.
