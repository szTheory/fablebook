---
id: INT-20261028-06
date: 2026-10-28
source: Claude Code session, grill-with-docs round 1 (domain language), owner answers
captured_by: Claude (Opus 5.5)
context: Owner answers on glossary structure, tiers/Foundations, story subject, twins, state classes, overloaded terms, Book per mount.
---

> Verbatim. Not paraphrased, typos preserved.

for Q2 what do u recommend? follow ur rec sounds like maybe u have an intuition here about the dounations thing i was personallly not clear on what it meant tbh... like is it smaller than primitives/ or something else or we just drop it? i do want to have course <-> granular but to a certain extent only beyond that it might be overkill and not clear? iut has to be clear to designers/users what each level's purpose is and has to be usful to AI as well context but overly course or overly granular would be not helpful and actually harmful. For Q1, yeah, follow your recommendation. For question three, I don't know. What do you recommend? Maybe break it down, think about it, follow your recommendation. I personally, I guess I don't really understand what you mean. Every story has a subject. What's considered like best practice or what would be cleanest? I don't really understand what you mean by question four, a twin as a render input or a citation. I was just thinking, like, digital twin or whatever just means kind of like an example adopter from different industries, different domains, in terms of like product domains or whatever you would call it, like use cases, so that we really are hashing it out and proving the design, like, stress testing fable book across realistic scenarios. I don't know. I guess twin, adopter. I don't know. We can rename it, but that's kind of what I was thinking of it as. Whatever would be clearest to the user, and then also internally consistent. And also clearest internally and maybe externally as well. I guess really, twin is not really something that would be exposed to the user so much. So it's more an internal thing. So whatever is most helpful to us. So, I guess think about that and then follow your recommendations there. For question six, I don't really understand the question. I mean, whatever makes sense to you. I guess you're talking about internationalization translation. I do think that we should be able to support that out of the box. Like, a lot of people won't do translation, so we should be good with that too. But we should make it easy to support, you know, viewing different languages and stuff too. Or at least stress testing it, like left to right, right to left, or viewing across a few, maybe a couple different example languages. Yeah, I would agree. Question seven, maybe decision is overloaded. So just kind of think about that. Follow your recommendations. Question eight. Yeah, I guess for all these overloaded terms, just if you are getting the feeling that it's like overloaded and you can have clearer language or whatever, then you should do that. I guess similar for question nine. Follow your recommendations. And similar for question 10. And then, yeah, I guess keep going, grilling questions, exploring the problem space across the breadth and depth of all decisions, almost high impact ones, and then keep grilling until the point of diminishing returns.

**Resolutions (Claude's recommendations, accepted by the owner's "follow your rec"):**
- **Q1:** Split the glossary. The root `GLOSSARY.md` holds language only. Telemetry, errors and modules move to `docs/domain/DOMAIN-MODEL.md`; UI labels move to `docs/research/UX-DESIGN.md`.
- **Q2:** Foundations is not a tier. It is the canon section of the sidebar. Tiers measure only how large a piece of UI is. The exact tier list is re-asked in round 2.
- **Q3:** Exactly one story per component. Every story has one subject component; compositions are extracted into components. Pages are the only stories without a subject.
- **Q4:** A twin is a fixed citation on a scenario. "Sample data" filters scenarios; it never swaps their data.
- **Q5:** Keep "Twin": a realistic example organization the UI serves, whose data fills scenarios. The CI apps are "host apps".
- **Q6:** A scenario can carry several state classes.
- **Q7:** An owner judgment on a finding is a **Verdict**. "Decision" is reserved for ADRs and gate changes.
- **Q8:** A ratchet holds **Known findings**. "Baseline" means only an accepted screenshot.
- **Q9:** Keep "Canon" in code and docs. The UI says "Foundations".
- **Q10:** One Book is one catalog is one mount. Several Books per app are allowed.
