---
id: INT-20261028-10
date: 2026-10-28
source: Claude Code session, grill-with-docs round 5, owner answers
captured_by: Claude (Opus 5.5)
context: Brand/product canon layers; Logistify product family; PWA mobile, future Crosswake native interop; interop with other owner libs; non-LiveView Phoenix (controller-rendered HEEx); white-label; comparison; solo-dev/tiny-team audience, Figma replacement; review queue.
---

> Verbatim. Not paraphrased, typos preserved.

For question one, yeah, your recommendation seems fine. Question two. Yeah, that's a good one. I like that. For a mobile app, that's right. PWA style, that's right. eventually we'll be doing interop with Crosswake which u can see at ~/projects/crosswake but that's kind of out of scope now but keep it in mind we'll want to eventually make that as seamless as possible for kind of previewing the android/ios idk how we'll approach that exactly for the more native like components but yeah... also idk if this applies but also some of the other elixir oss libs i'm making in ~/projects might have interop opportunities? just something to consider/keep in mind i dont want to force it but maybe u can look into that do a scan and consider it as part of eventual roadmap? but yeah defintely mobile PWA for ur  Q3 is a good fit. and also keep in mind sometimes we'll have to support like normal phoenix (not live view) for things liek offline support etc there might be pats of UI where websockets isnt a good fit but still the functional component heex or whatever is the latest called for phoenix ... (i forget)... For question four, yeah, that's a really good one. I like that for the white label. For question five. Yeah, that seems reasonable. For question six, I guess I don't fully understand. I'd have to see more examples, but it seems reasonable at surface level. what do u mean by a "Sketch" kit r u talking about that app sketch i dont thnk ayone uses that anymore everyone's on figma now (and i personally dont really use figma so i dont care b/c that's kind of the point of fablebook it will replace need for figma i'm makin this more for solo devs or VERY VERY small teams personally i'm solo dev solopreneuer so i dont really care about figma much )... but yeah nobody uses sketch anyonmre really idont so dont worry about sketch or even figma  i'd say... i dont see much value . For question eight, yeah, sounds good. We'll follow your recommendations there. For question nine, let's follow your recommendations. Seems reasonable. And then, yeah, I don't know if we have more, keep going until the point of diminishing returns with all the grilling

**Resolutions:**
- **Accepted:** Q1 (brand canon → product canon layers), Q2 (Logistify product family: operator console, shipper portal, driver app), Q3 (mobile = mobile web/PWA; Crosswake native interop deferred but its seam kept in mind), Q4 (Shopadelic storefront is white-label via twin themes, with guardrail checks), Q5 (Comparison along one axis), Q8 (lifecycle folded into NORTH-STAR #4), Q9 (Review queue, shown as "To review").
- **Re-asked with examples:** Q6 (Direction) and Q7 (a "sketch" kit meant low-fidelity wireframes, not the Sketch app).
- **New direction:**
  - The primary audience is solo developers and very small teams. Fablebook replaces the need for Figma, so no Figma or Sketch integration.
  - Non-LiveView Phoenix (controller-rendered HEEx function components) must be supported.
  - Interop with the owner's other libraries is scanned for the eventual roadmap.
