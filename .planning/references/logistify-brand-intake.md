# Logistify brand book intake

This is a compact, source-grounded reference for Phase 17 planning. The original v1.0 book and structured exports are the provenance sources for this intake; they are not yet applied Fablebook canon. This file records useful decisions, source locations, and open limits without copying the whole book.

## Capture status

- The owner says the finished Logistify book is for the Phase 17 brand canon and three Books: operator console, shipper portal, and driver app. Nothing has been applied. The owner says the source has not been published to Pages.
- `docs/brand/logistify/` was new and uncommitted in the primary checkout at capture time. This capture adds only the planning reference and its pointers; the source files were not copied, moved, changed, or applied.
- The brand is a fictional freight-logistics Twin. The owner reports that a real courier product and a trademark record share the name; the name has not been cleared. Do not present the fictional name as cleared for real use.
- The v1.0 sign-off followed a light scan because the brand is fictional. The owner describes it as a strong first draft, not taste-tested. The layout examples are recommendations, not product screenshots.

## Provenance

SHA-256 hashes below were computed from the source files on 2026-11-10. Recheck them before Phase 17 consumes the source, since the files are currently uncommitted.

| Source path (relative to repo root) | SHA-256 | Read locations |
| --- | --- | --- |
| `docs/brand/logistify/BRAND.md` | `69b9baf05ebf3461ce1487ec7bb4987a9538c11ed8ab0540199fd021297399e7` | Brand at a glance; Positioning and values; Messaging; The idea; Where the brand shows; Logo; Color; Type; Voice; Key terms; Imagery; Themes; Logo motion; Product motion; Sonic identity; Operator console; Shipper portal; Driver app; Print; Brand assets; To review |
| `docs/brand/logistify/brand.json` | `f072b9b7612b51e249905498d01fb01b098dbc1df87703eaf7fdfd845abb52ea` | `/version`, `/positioning`, `/idea`, `/logo`, `/color/defaultTheme`, `/color/light`, `/color/dark`, `/color/status`, `/color/contrastPairs`, `/type`, `/voice`, `/stateWords`, `/states`, `/motion/product`, `/sound/sounds`, `/sound/rules`, `/products`, `/imagery/photographs`, `/toReview`, `/notChecked`, `/files` |
| `docs/brand/logistify/tokens.json` | `dd923fffd0ed104d664f3178d4beed106131c697d3c2601b54a7efdfa8b8a563` | `/$description`, `/color/light`, `/color/dark`, `/color/signal`, `/color/status`, `/color/contrast-pairs/{body,descriptor,caption,application-copy,hero,link,focus,artwork}`, `/font`, `/typography`, `/dimension`, `/motion` |

The local HTML text was inspected without opening a browser or executing scripts: `docs/brand/logistify/logistify-brand-book.html`, `docs/brand/logistify/logistify-one-page.html`, and `docs/brand/logistify/assets/index.html`. Their visible text agrees with the book summary and shows an asset catalog. Asset inventory and rights notes were read from `assets/README.md`, `assets/imagery/README.md`, and `assets/sound/README.md`; the two font license texts were checked. No assets were rendered or auditioned.

## Brand canon digest

### Identity and visual system

- Positioning: freight software for carriers, shippers, and drivers; tagline “Every stop, in order.” The voice is a calm dispatcher: exact, plain, never excited, and ready with the next step. `BRAND.md` sections Positioning and values, Messaging, and Voice; `brand.json` `/positioning`, `/voice`, `/messaging`.
- The typemark is the word in Archivo 700, with a 45-degree mitre in the L and a square orange unit on the second i. Keep the typemark alone. Use the L slab only where a word cannot fit, such as a favicon or app tile. Under roughly 200 px, use the plain-L small typemark. `BRAND.md` sections The idea, Logo, Symbol and favicon; `brand.json` `/logo/mark`, `/logo/small`, `/logo/symbol`.
- Light is the default. The console is designed for dark as well as light; the portal defaults to light and follows system in dark mode; the driver app defaults to light. The owner lists the light default as revisitable. `brand.json` `/color/defaultTheme`, `/products`.
- Core light values: Paper `#F4F6F8`, Card `#FFFFFF`, Ink `#1B222C`, Steel `#2D4F7C`, Hairline `#C9D1DA`, Signal `#F0501E`. Dark values include Night `#0E1217`, Panel `#171D25`, Fog `#D5DBE3`, Steel Light `#8FB4E8`, and a brighter Signal `#FF6A3D`. Signal `#F0501E` is artwork, never status or text; large light display accents use Signal Deep `#C23B10`. `BRAND.md` Color: light/dark; `brand.json` `/color`; `tokens.json` `/color`.
- Status is always named in words. Pending, Assigned, and In transit are neutral; Delayed is warn; Failed is bad; Delivered is ok. Orange is not a status. The owner says the status set is revisitable. `brand.json` `/stateWords`, `/color/status`; `tokens.json` `/color/status`.
- The eight source contrast-pair IDs are `body`, `descriptor`, `caption`, `application-copy`, `hero`, `link`, `focus`, and `artwork`. The stated ratios are computed for those pairs only, not for a whole product. `brand.json` `/color/contrastPairs`; `tokens.json` `/color/contrast-pairs`.
- Archivo covers the typemark, headlines, and text; Red Hat Mono is for IDs and codes. The hierarchy is 56 px display, 28 px heading, 16 px body, 13 px dense text, 12 px labels, and 13 px IDs/codes. Dense labels may use 88% width before shrinking or truncating. Both font license texts are bundled. `BRAND.md` Type; `brand.json` `/type`; `tokens.json` `/font`, `/typography`.

### Voice, terms, and product recommendations

- Copy names the real shipment, stop, time zone, quantity, and next step. Avoid excited error copy or vague promises. Key terms include shipment, stop, route, assignment, delivery window, delivered, failed, proof of delivery, recipient, shipper, carrier, and pallet. `BRAND.md` Voice and Key terms; `brand.json` `/voice`.
- The console recommendation is a dense board with 32 px rows, 13 px text, J/K/X keyboard navigation, and bulk actions. The portal is calmer, with 48 px rows and 15 px text. The driver app is one stop at a time in a 440 px PWA phone layout, with 56 px targets and text no smaller than 16 px. These are recommendations, not current product facts. `BRAND.md` Operator console, Shipper portal, Driver app; `brand.json` `/products`.
- Plan an “every state” page per Book covering empty, loading, error, long labels, many, boundaries, and bulk/action cases. Use these as candidate scenarios to map later; they are not already Fablebook Scenarios. German and French strings are layout samples, not translations or proof of localization. `BRAND.md` product “every state” sections and Shipper portal; `brand.json` `/states`, `/products/portal`.
- Motion references are 100/150/200/250 ms with Enter `cubic-bezier(0.2, 0.7, 0.3, 1)` and Exit `cubic-bezier(0.4, 0, 1, 1)`. The book rules out bounce, overshoot, loops, pulses, and pending spinners. `BRAND.md` Product motion; `brand.json` `/motion/product`; `tokens.json` `/motion/duration`, `/motion/easing`.
- The logo sting accompanies the identity animation. The three product cues are positive confirmations only, never errors, failures, or warnings; provide an off switch. Driver cues have an off switch and honor silent mode; the console cue is off by default. The owner says they have not picked the cue defaults by ear. Sound was synthesized and measured, but not auditioned in real rooms or vehicles. `BRAND.md` Sonic identity; `brand.json` `/sound/sounds`, `/sound/rules`.
- Imagery uses daylight freight photographs with a cool, restrained grade and no overlays. The inventory has 77 files across logos, icons, fonts, six credited photos, motion, social, and sound. Font license files are present; the six photo entries carry author, license, and source checksums. Reuse of the full asset set beyond this demonstration remains undecided. `BRAND.md` Imagery and Brand assets; `brand.json` `/imagery/photographs`, `/files`; the asset README files above.

## Open review points to carry into Phase 17

Keep these explicit rather than silently treating them as accepted product policy:

1. Name/trademark clearance is open. The owner's report and the book's “To review” section both say it is not cleared; the book records only a limited prior check.
2. The owner permits changing the light default, shared portal orange, status set, and sound defaults; these are revisitable choices, not mandatory revisions. The source book itself already flags the portal accent and unpicked sound cues.
3. The product sound defaults have not been picked by ear. The source records levels, but no room or in-vehicle audition.
4. German and French are layout samples only; there is no translation/localization claim.
5. Print is drawn only. There are no print-ready files with outlined type, no stock conversion, and no physical proof.
6. Logo legibility was judged on test sheets and by model readers, not people; the book calls the result borderline against category marks. The product layouts are not screenshots.
7. The owner says there was no real-device or Safari testing and no rebuild-determinism check. These are not established by this capture.
8. Asset reuse beyond the demonstration is undecided, even though font license texts and photo credits are included.

## Phase 17 integration boundaries

- This intake is only the Logistify adopter brand. Phase 17 also includes Fablebook's own brand book; keep the two identities distinct.
- Existing owner direction `INT-20261028-15` keeps Fablebook's workbench chrome ink-on-neutral. Logistify belongs to its adopter Book and Canvas; its strong colors must not overpower the Workbench.
- `tokens.json` describes itself as a small DTCG subset and says its consumer export schema is unspecified. `brand.json`'s contrast IDs are source IDs. Map source values deliberately against `docs/adr/0012-canon-format.md`; do not assume drop-in compatibility, invent export IDs, or claim a Fablebook schema from these files.
- At Phase 17, choose the canonical destination for the source and decide which recommendations become strict canon, open review items, or product-specific content. This capture authorizes no implementation, name clearance, publication, or schema mapping.

## Related planning records

- Owner intent: `.planning/intent/sources/2026-11-10-08-logistify-brand-intake.md` (`INT-20261110-08`).
- Phase context: `.planning/ROADMAP.md`, Phase 17; canon contract: `docs/adr/0012-canon-format.md`.
- Seed: `.planning/seeds/SEED-261110-iry-logistify-phase17-brand-intake.md`.
