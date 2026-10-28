---
id: INT-20261028-14
date: 2026-10-28
source: Claude Code session, grill-with-docs round 8 (journeys, frames, export, i18n), owner answers
captured_by: Claude (Opus 5.5)
context: Linear journeys; step-action checks; journeys in job canon; device frames (no watch); framed screenshot export; hardcoded-string check; general shift-left / automate-everything stance.
---

> Verbatim. Not paraphrased, typos preserved.

For question one, yeah, that sounds good. We can always just put like variants of the journey, but I don't know. Maybe that's overly complicated. Let's follow your recommendations. I feel like it could get insanely crazy if we're having tons of branching. Maybe that's appropriate, though. I don't know. It does seem like alternative paths being their own journeys might be a bit more easy to wrap your head around, though. So yeah, we'll follow your recommendation on question one. Yeah, we'll follow your recommendation for question two. just in general "shift left automate the world devops mindset" i think is good like static analysis well or runtime/ci checks basically whenever we can save people from themselves and automate and get early feedback that's good (to point of diminishing returns of course)... For question three. Oh, yeah. Let's follow your recommendation for question three. Yeah, I guess. I don't know. Whatever for the watch. I don't really care. Oh, if they can't run PWAs, then don't bother. For question five, yes. Following recommendations. For question six, yes. Do we still have more grilling to do? If so, you can do it. Hopefully, we're getting close to the end here, though.

**Resolutions:**
- **Q1:** Journeys are linear lists of steps; each alternative path is its own journey.
- **Q2:** Each step's action is checked: the named control must exist (dead-end check) and its label must match (copy-drift check).
- **Q3:** Journeys are declared in the job's canon file.
- **Q4:** Generic phone, tablet, laptop and desktop frames. No watch frame.
- **Q5:** Framed screenshots can be exported.
- **Q6:** Optional hardcoded-string Credo check when the app uses Gettext.
- **Standing principle:** "shift left, automate the world." Wherever a static, runtime or CI check can save people from themselves, add it, up to the point of diminishing returns.
