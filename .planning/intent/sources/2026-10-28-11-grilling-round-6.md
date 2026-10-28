---
id: INT-20261028-11
date: 2026-10-28
source: Claude Code session, grill-with-docs round 6, owner answers (two messages)
captured_by: Claude (Opus 5.5)
context: Accepts the round-6 recommendations; questions the scope of external renditions; describes the cross-session abracabrand workflow for building twin brand books.
---

> Verbatim. Not paraphrased, typos preserved.

Yeah, we can follow your recommendations on that. Actually, I don't understand. What do you mean by external rendition? Can you explain that more? Oh, this is some kind of integration. can u explain more actually....

Oh, by the way, once it's time to work with Abra Cabrand, I think what I'm going to do is I'm just going to have this in a Claude session for Fablebook, and then I'll have a separate Claude session for Abra Cabrand open, and then I'll just let the two LLM sessions communicate with each other to get those brand books all made, like go through the whole process and iterate. And then that will also help, like, kind of give some lessons learned to the. Abra Cabrand as well. And then, like, I'll also want to kind of check in at key moments to make sure, like, sanity check that the results are good and that the process went well. And then we'll be able to feed all the lessons learned from that process back into the Abra Cabrand development itself. Yeah, I don't know. I guess that sounds interesting with the external rendition. It seems a little out of scope somehow, but I don't know. Maybe if it's. Like, the thing is, isn't the whole point of Fable Book that it's handling what is controlled by Phoenix? So it seems like handling things that would be outside of Phoenix might be out of scope, but maybe that signal would be useful in some way. I don't know.

**Resolutions:**
- **Accepted:**
  1. **Direction** is a named candidate look and voice that can be switched to and compared across the whole catalog.
  2. **No wireframe kit.** Use a **Draft** marker plus `mix fablebook.gen.screens` and the bundle option `--focus explore` instead.
  3. **`render: :static`** serves controller-rendered (dead view) pages with no LiveSocket.
  4. **The brand canon may come from a path or a dependency.**
  5. **Theme and Direction** are separate terms.
- **Scope rule:** Fablebook covers UI that the Elixir/Phoenix app renders. The "external rendition" promise is withdrawn. Renderers stay dispatched by subject kind, internally only. Emails and PDFs rendered by Elixir may later become subject kinds. Native (Swift/Kotlin) previews are out of scope.
- **Process:** twin brand books are built by a Fablebook Claude session and an abracabrand Claude session working together. The owner checks in at key moments, and lessons learned feed back into abracabrand.
