---
id: INT-20261028-08
date: 2026-10-28
source: Claude Code session, grill-with-docs round 3, owner answers
captured_by: Claude (Opus 5.5)
context: Strict by default with waivers; presentational Area/Screen subjects; twin naming, breadth and visual diversity; twins as public showcase; abracabrand builds twin brand books.
---

> Verbatim. Not paraphrased, typos preserved. `[pasted]` marks text the owner pasted into the message.

For question one, let's follow your recommendation. For question two, let's also follow your recommendation.

[pasted]
 So, for these digital twins, for the names, I want to make sure that they have like. It's not all these code names. The name should make it clear what we are building it out for. We don't have to worry about overlap. So, like, chat could be like Chatly or Chatify. The freight logistic thing could be like Logistify or ShipAlogistic or. Ship a rite, shipper a dee dee. I don't know. Make up some name. But basically, hopefully, you get what I'm saying. Like, finance could be like Finanza or Finanzo. The Shopify can be like Shoopadoop or like Shopadelic. The Docs thing could be like Doxosaurus Rex. Like, don't use overly long names. Hopefully, you get what I'm saying. The type of domain or industry or whatever that it's in should be clearly in the name so that's not overly coded. Just so that way it's easier to keep track of them mentally and I don't have to translate between these code names.
[/pasted]

 But yeah, otherwise, for your question three, let's follow your suggestions. Like, we definitely want to have as many digital twins as possible to the point of diminishing returns. So, not too many, but we don't want to underdo it. We want to make sure that we're stress testing every relevant aspect. And it sounds like you kind of already have a pretty good handle on that. But just want to kind of sanity check that. For question four, I guess, yeah, that seems reasonable at face value. I don't fully understand, but yeah, we could follow your recommendations. For question five, yeah, that sounds good. I really agree with you on that. The digital twins being a public showcase. Yeah, for Abrika brand, they can build the brand books. That sounds good. It's like that lib is not fully developed yet, but we're building that out, and that'll be kind of a nice stress test as well. Like for Abraka brand, that will help stress test it, and also it'll give us nicer designs as well. And also, it would be nice if the brands among our demos were kind of like they didn't overlap too much visually. They kind of show a different showcase of how different design styles and brands can look, different color schemes and stuff. We don't want them to all look samey. For question seven, I don't know. I don't really fully understand. Let's follow your recommendations as long as you thought it through.

**Resolutions:**
- **Q1 (ADR 0024):** strict by default. The only escape hatch is a reasoned **Waiver**, and there is no global off switch.
- **Q2 (ADR 0002):** Area and Screen subjects are presentational function components. LiveComponent subjects are allowed up to Area. A LiveView subject needs a Waiver.
- **Q3 (`docs/research/TWINS.md`):** five twins whose names say their domain: Chatly, Logistify, Finanza, Shopadelic and Clinicly. Their visual styles are deliberately distinct.
- **Q4:** all twins live in `hosts/operator`, one Book per twin.
- **Q5:** the twins are the public showcase (demo, docs, golden bundles, later the static demo site). They never ship in the Hex package.
- **Q6:** abracabrand builds each twin's brand book, which stress-tests abracabrand as well.
- **Q7 (ADR 0024):** the strict-by-default rule list is accepted.
