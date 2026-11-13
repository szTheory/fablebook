---
id: INT-20261111-06
date: 2026-11-11
source: owner message supplying the Fablebook brand-book handoff
captured_by: Codex
context: Brand source intake during guard Phase 1 execution; keep explicit instructions, reported settled vocabulary and book recommendations distinct.
---

## Verbatim owner excerpts

> The brand book for Fablebook itself is ready (version 2.1). Before you write README, docs, UI catalog chrome, the Hex page or the social card:

> Clone it into a git-ignored folder in this repo so you can read and copy from it. Never commit it, and never edit it:

> Read .fablebook-brand/BRAND.md (the whole book as text) and brand.json (every rule as data). tokens.json has color and type.

> Copy assets into this repo where the book says they go. Do not reference the clone from shipped code.

> The brand book is the source of truth. If something in this repo conflicts with it, tell me rather than silently changing either.

The supplied handoff labels the following section as language the owner settled:

> **UI catalog** is the one name for Fablebook and for the part you open (sidebar, toolbar, inspector, canvas). Never "workbench". Descriptor: "A UI catalog for Phoenix LiveView".

> A **scenario** is one screen in one **case**; a case is what a user is going through (happy path, empty, many, error, long). Never "situation", "moment", "variant" or "knob". **Story** is still the catalog word for one screen; whether "user flow" should replace it is open (see below).

> Say **user flows**, **screens**, **the happy path**, **edge cases and errors**, **coverage map**, **domain language** (not "canon"). The app's people are **users**. No "state" as a headline, no "reviewer", no "workflows" or "journeys" in claims.

> Voice is "Plain" (plain to lively on a dial; never lively inside the UI catalog). No slogans, no AI-sounding lines, no middle dots as separators, US spelling.

The supplied handoff labels catalog color, marker, terminal, motion and contrast rules as recommendations, "your call". Preserve that qualification. The owner had already requested neutral product chrome in the earlier conversation; this intake does not settle every detailed book recommendation or change the component/story model.

## Source inspection, not owner quotations

Upstream main was inspected at commit 5a13d2f32db0783bd7eebaa416d53b0701288a67. BRAND.md, brand.json and the asset guide report version 2.0, while the latest owner introduction says 2.1 and the pasted older handoff says 2.0. The mismatch remains explicit. See [the intake reference](../../references/fablebook-brand-intake.md) for hashes, conflicts, review limits, asset staging and future triggers.

No glossary, accepted ADR, runtime UI, public claim or asset publication changes through this intake. Clone source stays read-only and ignored. Asset destinations and the expected source version need reconciliation before the requested application can be made concrete.
